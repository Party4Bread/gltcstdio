"""Evaluate shaders that the app assembles from Kotlin string templates.

Roughly two dozen filters do not store their GLSL as one literal.  They build
it at runtime by concatenating literals with fragments produced by small
generator methods, which the decompiler renders as StringBuilder plumbing:

    return f.o(G("bkg", "dir"), "\\n return bkg * ...",
               AbstractC2589q.g("\\n vec4 sphereGl(...", ...));

Taking a single literal from such a class yields a truncated shader, so this
module interprets just enough Java to run the assembly:

    AbstractC2589q.e(a, b, ...)   -> a + b + ...
    AbstractC2589q.g(a, b, ...)   -> StringBuilder(a + b + ...)
    f.A(sb, a, b, ...)            -> sb.append(a).append(b)...
    f.o(a, b, sb)                 -> sb + a + b, trimIndent'd
    f.p(a, sb)                    -> a + sb
    <local static>(args)          -> evaluated recursively

Anything outside that vocabulary makes evaluation fail rather than return a
partial shader.
"""

from __future__ import annotations

import re
from pathlib import Path

from javaexpr import match_paren, split_args

STR_LIT = re.compile(r'"((?:[^"\\]|\\.)*)"', re.S)

METHOD_RE = re.compile(
    r"^\s*(?:public|private|protected)\s+(?:static\s+)?(?:final\s+)?"
    r"(String|StringBuilder)\s+(\w+)\s*\(([^)]*)\)\s*\{",
    re.M,
)


# A class-level `String` constant, initialiser included.  Anchored on the
# four-space indent jadx gives fields so method locals do not match.
FIELD_RE = re.compile(
    r"^    (?:public\s+|private\s+|protected\s+|static\s+|final\s+)*"
    r"(?:String|int|long|float|double|boolean)\s+(\w+)\s*=\s*(.+?);\s*$",
    re.M | re.S,
)
# The same, assigned in a constructor instead of at the declaration.
CTOR_FIELD_RE = re.compile(r"^\s+this\.(\w+)\s*=\s*(.+?);\s*$", re.M | re.S)


# Simple class name -> source, filled in by the caller.  A generator can hand
# part of its text to another operator -- the elevation maps ask `HeightMap`
# for the expression that reads the background -- and without the other class
# those calls came out empty.
CLASS_SOURCES: dict[str, object] = {}
_EVALUATORS: dict[str, "TemplateEvaluator"] = {}


def evaluator_for(class_name: str):
    """A cached evaluator for another class, or None if it is not indexed."""
    if class_name in _EVALUATORS:
        return _EVALUATORS[class_name]
    src = CLASS_SOURCES.get(class_name)
    if src is None:
        return None
    if not isinstance(src, str):
        src = Path(src).read_text()
    ev = _EVALUATORS[class_name] = TemplateEvaluator(src)
    return ev


def _paren_balanced(text: str) -> bool:
    """Parentheses balance outside string literals."""
    depth, in_str, esc = 0, False, False
    for ch in text:
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
        elif ch == '"':
            in_str = True
        elif ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


class Unevaluable(Exception):
    """A construct outside the small vocabulary this evaluator supports."""


def decode(lit: str) -> str:
    out, i = [], 0
    while i < len(lit):
        ch = lit[i]
        if ch == "\\" and i + 1 < len(lit):
            nxt = lit[i + 1]
            mapping = {"n": "\n", "t": "\t", "r": "\r", '"': '"', "\\": "\\", "'": "'"}
            if nxt in mapping:
                out.append(mapping[nxt])
                i += 2
                continue
            if nxt == "u":
                out.append(chr(int(lit[i + 2 : i + 6], 16)))
                i += 6
                continue
        out.append(ch)
        i += 1
    return "".join(out)


def trim_indent(text: str) -> str:
    """Kotlin's trimIndent: drop the common indent and blank edge lines."""
    lines = text.split("\n")
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    indents = [len(l) - len(l.lstrip()) for l in lines if l.strip()]
    cut = min(indents) if indents else 0
    return "\n".join(l[cut:] if len(l) >= cut else l.lstrip() for l in lines)


def statements(body: str) -> list[str]:
    out, depth, cur, in_str, esc = [], 0, [], False, False
    for ch in body:
        if in_str:
            cur.append(ch)
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
            cur.append(ch)
        elif ch in "([{":
            depth += 1
            cur.append(ch)
        elif ch in ")]}":
            depth -= 1
            cur.append(ch)
        elif ch == ";" and depth == 0:
            out.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur).strip()
    if tail:
        out.append(tail)
    return out


class TemplateEvaluator:
    """Runs the string-building methods of one decompiled class."""

    def __init__(self, src: str, overrides: dict[str, str] | None = None):
        self.src = src
        # Exact expression text -> value, for the instance fields and abstract
        # methods a base class reads but does not define.  `RayMarcher` takes
        # its distance function and that function's extra parameters from the
        # subclass this way.
        self.overrides = overrides or {}
        self.methods: dict[str, tuple[list[str], str]] = {}
        for m in METHOD_RE.finditer(src):
            name, params = m.group(2), m.group(3)
            open_brace = src.index("{", m.end() - 1)
            end = self._match_brace(src, open_brace)
            if end == -1:
                continue
            names = [
                p.strip().split()[-1] for p in params.split(",") if p.strip()
            ]
            self.methods[name] = (names, src[open_brace + 1 : end])
        # Class-level `String` constants.  Several generators hold the extra
        # arguments they splice into every call in a static field -- e.g.
        # `MengerSponge.f12661l` is the argument list its `rayMarch(origin,
        # dir, ...)` calls end with -- and without them the call came out with
        # a dangling comma.
        # Local name -> class, for the operators this one delegates to.
        self.objects: dict[str, str] = {}
        self.fields: dict[str, str] = {
            m.group(1): m.group(2)
            for m in FIELD_RE.finditer(src)
            if m.group(1) not in self.methods
        }
        # A field can also be filled in the constructor rather than declared
        # with its value -- `OrbitsFractal` assigns the three fragments its
        # subclasses splice into their shader that way.
        for m in CTOR_FIELD_RE.finditer(src):
            self.fields.setdefault(m.group(1), m.group(2))
        # ... and the class holding them is usually the abstract base, so
        # lookups continue up the chain.
        parent = re.search(r"\bclass\s+\w+\s+extends\s+(\w+)", src)
        self.parent = parent.group(1) if parent else None

    def lookup_field(self, name: str):
        """(evaluator, initialiser) for a field, following `extends`."""
        if name in self.fields:
            return self, self.fields[name]
        seen, cls = set(), self.parent
        while cls and cls not in seen:
            seen.add(cls)
            other = evaluator_for(cls)
            if other is None:
                return None
            if name in other.fields:
                return other, other.fields[name]
            cls = other.parent
        return None

    @staticmethod
    def _match_brace(text: str, start: int) -> int:
        depth, i, in_str, esc = 0, start, False, False
        while i < len(text):
            ch = text[i]
            if in_str:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
            elif ch == '"':
                in_str = True
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    return i
            i += 1
        return -1

    # -- evaluation ---------------------------------------------------------
    def call(self, name: str, args: list[str], depth: int = 0) -> str:
        if depth > 12:
            raise Unevaluable("recursion too deep")
        if name not in self.methods:
            raise Unevaluable(f"unknown method {name}")
        params, body = self.methods[name]
        env = dict(zip(params, args))
        return self.run(body, env, depth)

    def run(self, body: str, env: dict[str, str], depth: int) -> str:
        value = self.populate(body, env, depth)
        if value is None:
            raise Unevaluable("method fell through without returning")
        return value

    def populate(self, body: str, env: dict[str, str], depth: int) -> str | None:
        """Run `body`'s assignments into `env`; the returned value, if any.

        A method that builds several fragments and hands them back as a list
        has no single return value, so the caller runs it for the bindings and
        evaluates the list itself.
        """
        for stmt in statements(body):
            stmt = stmt.strip()
            if not stmt or stmt.startswith("//"):
                continue

            # `if (over-layer is on) { str = "..." } else { str = "" }`:
            # an optional block spliced into a shared template.  Both variants
            # are the same shader, so take the one that contributes text --
            # the bank exposes the parameters that block reads.
            if re.match(r"^if\s*\(", stmt):
                value = self._branch(stmt, env, depth)
                if value is not None:
                    return value
                continue

            # sb.append(x)
            m = re.match(r"^(\w+)\.append\((.*)\)$", stmt, re.S)
            if m and m.group(1) in env:
                env[m.group(1)] += self.expr(m.group(2), env, depth)
                continue

            # f.A(sb, a, b, ...)
            m = re.match(r"^[\w.]*\bA\((.*)\)$", stmt, re.S)
            if m:
                parts = split_args(m.group(1))
                target = parts[0].strip()
                if target in env:
                    env[target] += "".join(
                        self.expr(p, env, depth) for p in parts[1:]
                    )
                    continue

            # `HeightMap heightMap = HeightMap.f12658k` binds another
            # operator, whose generator methods this one calls.
            m = re.match(r"^([A-Z]\w*)\s+(\w+)\s*=\s*", stmt, re.S)
            if m and m.group(1) in CLASS_SOURCES:
                self.objects[m.group(2)] = m.group(1)
                continue

            # Type var = expr
            m = re.match(r"^(?:[\w.<>\[\]]+\s+)?(\w+)\s*=\s*(.+)$", stmt, re.S)
            if m and not stmt.startswith("return"):
                env[m.group(1)] = self.expr(m.group(2), env, depth)
                continue

            if stmt.startswith("return"):
                return self.expr(stmt[len("return") :].strip(), env, depth)

            # Declarations without an initialiser, asserts and similar noise.
            # `RandomTilePlacer.f12651h.getClass()` is a null check, not text.
            if (
                re.match(r"^[\w.<>\[\]]+\s+\w+$", stmt)
                or "AbstractC1809j" in stmt
                or stmt.endswith(".getClass()")
            ):
                continue
            raise Unevaluable(f"statement: {stmt[:60]}")
        return None

    # Only comparisons of numbers against the values already bound.
    _COND_OK = re.compile(r"^[\w\s().!=<>&|+\-*/]+$")

    def _ternary(self, text: str, env: dict[str, str]) -> str | None:
        """The branch of a top-level `cond ? a : b`, or None if not one."""
        depth, in_str, esc, q, nested = 0, False, False, -1, 0
        for i, ch in enumerate(text):
            if in_str:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
                continue
            if ch == '"':
                in_str = True
            elif ch in "([":
                depth += 1
            elif ch in ")]":
                depth -= 1
            elif depth == 0 and ch == "?":
                if q < 0:
                    q = i
                else:
                    nested += 1
            elif depth == 0 and ch == ":" and q >= 0:
                if nested:
                    nested -= 1
                    continue
                cond = text[:q].strip()
                if not self._COND_OK.fullmatch(cond):
                    return None
                truth = self._truth(cond, env)
                if truth is None:
                    return None
                return text[q + 1 : i] if truth else text[i + 1 :]
        return None

    @staticmethod
    def _truth(cond: str, env: dict[str, str]) -> bool | None:
        """Evaluate a numeric condition against the bound values."""
        expr_py = cond.replace("&&", " and ").replace("||", " or ")
        expr_py = re.sub(r"!(?!=)", " not ", expr_py)
        names = {}
        for name in set(re.findall(r"\b[A-Za-z_]\w*\b", expr_py)):
            if name in ("and", "or", "not", "true", "false"):
                continue
            value = env.get(name)
            if value is None:
                return None
            try:
                names[name] = int(value)
            except ValueError:
                try:
                    names[name] = float(value)
                except ValueError:
                    return None
        try:
            return bool(eval(expr_py, {"__builtins__": {}}, names))  # noqa: S307
        except Exception:  # noqa: BLE001 - any failure means "cannot decide"
            return None

    def _branch(self, stmt: str, env: dict[str, str], depth: int) -> str | None:
        """Run an `if`/`else`, then whatever follows it.

        `statements` cannot split after a block, so the rest of the method
        arrives glued to it and is run here.
        """
        open_p = stmt.index("(")
        close_p = match_paren(stmt, open_p)
        ob = stmt.index("{", close_p)
        eb = self._match_brace(stmt, ob)
        if eb == -1:
            raise Unevaluable("unterminated if")
        branches = [stmt[ob + 1 : eb]]
        rest = stmt[eb + 1 :].lstrip()
        if rest.startswith("else"):
            rest = rest[4:].lstrip()
            if rest.startswith("{"):
                end = self._match_brace(rest, 0)
                branches.append(rest[1:end])
                rest = rest[end + 1 :]
            else:
                branches.append(rest)
                rest = ""

        for body in branches:
            trial = dict(env)
            try:
                self.populate(body, trial, depth)
            except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
                continue
            if any(v.strip() and env.get(k) != v for k, v in trial.items()):
                env.update(trial)
                break
        else:
            for body in branches:
                trial = dict(env)
                try:
                    self.populate(body, trial, depth)
                except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
                    continue
                env.update(trial)
                break

        return self.populate(rest, env, depth) if rest.strip() else None

    def expr(self, text: str, env: dict[str, str], depth: int) -> str:
        text = text.strip()
        if not text:
            return ""
        if text in self.overrides:
            return self.overrides[text]

        # `mode == 3 ? "..." : "..."`: the generator emits a different block
        # per mode.  The condition is decided from the values the environment
        # would hold, which for a static extraction are the defaults.  This
        # comes before `+` because `?:` binds loosest.
        chosen = self._ternary(text, env)
        if chosen is not None:
            return self.expr(chosen, env, depth)

        # Top-level `+` concatenation.
        parts = self._split_plus(text)
        if len(parts) > 1:
            return "".join(self.expr(p, env, depth) for p in parts)

        if text.startswith("(") and match_paren(text, 0) == len(text) - 1:
            return self.expr(text[1:-1], env, depth)

        m = STR_LIT.fullmatch(text)
        if m:
            return decode(m.group(1))

        # A numeric constant spliced into the source as its own text; Java's
        # type suffix is not part of what the shader sees.
        m = re.fullmatch(r"(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)[dDfFlL]?", text)
        if m:
            return m.group(1)
        if text in ("true", "false"):
            return text

        if text in env:
            return env[text]

        # A class constant, reached bare, through `this`, or through the class
        # name, and possibly declared by a base class or another class -- the
        # bound `circle-list-painter` loops to is `RandomTilePlacer`'s.
        m = re.fullmatch(r"(?:this\.|([A-Z]\w*)\.)?(\w+)", text)
        if m:
            holder = evaluator_for(m.group(1)) if m.group(1) else None
            found = (holder or self).lookup_field(m.group(2))
            if found is not None:
                owner, init = found
                return owner.expr(init, env, depth + 1)

        m = re.match(r"^(\w+)\.toString\(\)$", text)
        if m and m.group(1) in env:
            return env[m.group(1)]

        m = re.match(r"^new StringBuilder\((.*)\)$", text, re.S)
        if m:
            return self.expr(m.group(1), env, depth) if m.group(1).strip() else ""

        # `"a".concat(b)` is plain concatenation.  The receiver has to be a
        # whole expression: in `I("center+len*".concat(str))` the `.concat`
        # belongs to the argument, and matching it there cut the call in half.
        m = re.match(r"^(.*)\.concat\((.*)\)$", text, re.S)
        if m and _paren_balanced(m.group(1)):
            return self.expr(m.group(1), env, depth) + self.expr(m.group(2), env, depth)

        # `String.valueOf(x)` / `String.join` wrappers around a piece.
        m = re.match(r"^String\.valueOf\((.*)\)$", text, re.S)
        if m:
            return self.expr(m.group(1), env, depth)

        m = re.match(r"^\(?\(Object\)\s*(\w+)\)?$", text)
        if m and m.group(1) in env:
            return env[m.group(1)]

        # A call: <qualifier.>name(args)
        m = re.match(r"^([\w.]+)\s*\(", text)
        if m and match_paren(text, text.index("(")) == len(text) - 1:
            qualified = m.group(1)
            short = qualified.split(".")[-1]
            inner = text[text.index("(") + 1 : -1]
            args = split_args(inner)

            # `env.f(2, "mode")` reads a parameter, falling back to the value
            # given first.  The app rebuilds the shader whenever that value
            # changes; a static extraction can only take the fallback.
            if (
                "." in qualified
                and qualified.split(".")[0] in env
                and len(args) == 2
                and STR_LIT.fullmatch(args[1].strip())
            ):
                return self.expr(args[0], env, depth)

            if short in ("e", "g", "c", "d", "b", "C", "q"):
                # Concatenation helpers extracted by the decompiler.
                return "".join(self.expr(a, env, depth) for a in args)
            if short == "s" and len(args) >= 2:
                # f.s(sb, a, b, ...) -> sb + a + b ..., trimIndent'd
                return trim_indent(
                    "".join(self.expr(a, env, depth) for a in args)
                )
            if short == "m" and len(args) == 3:
                # y.m(a, b, sb) -> sb + a + b, kept as written
                return (
                    self.expr(args[2], env, depth)
                    + self.expr(args[0], env, depth)
                    + self.expr(args[1], env, depth)
                )
            if short == "o" and len(args) == 3:
                # f.o(a, b, sb) -> sb + a + b, trimIndent'd
                head = self.expr(args[2], env, depth)
                return trim_indent(
                    head
                    + self.expr(args[0], env, depth)
                    + self.expr(args[1], env, depth)
                )
            if short == "p" and len(args) == 2:
                return self.expr(args[0], env, depth) + self.expr(args[1], env, depth)
            if short == "q0":
                return trim_indent(self.expr(args[0], env, depth))
            if short in self.methods:
                return self.call(
                    short, [self.expr(a, env, depth) for a in args], depth + 1
                )
            owner = self.objects.get(qualified.split(".")[0])
            other = evaluator_for(owner) if owner else None
            if other is not None and short in other.methods:
                return other.call(
                    short, [self.expr(a, env, depth) for a in args], depth + 1
                )
            raise Unevaluable(f"call {qualified}")

        raise Unevaluable(f"expression {text[:60]}")

    @staticmethod
    def _split_plus(text: str) -> list[str]:
        parts, depth, cur, in_str, esc = [], 0, [], False, False
        for ch in text:
            if in_str:
                cur.append(ch)
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
                continue
            if ch == '"':
                in_str = True
                cur.append(ch)
            elif ch in "([":
                depth += 1
                cur.append(ch)
            elif ch in ")]":
                depth -= 1
                cur.append(ch)
            elif ch == "+" and depth == 0:
                parts.append("".join(cur))
                cur = []
            else:
                cur.append(ch)
        parts.append("".join(cur))
        return [p for p in parts if p.strip()]


def assemble(src: str, op_function: str) -> str | None:
    """Return the full GLSL for `op_function`, or None if it cannot be built.

    Every String-returning method is tried; the answer is the one that defines
    the wanted function with balanced braces.
    """
    ev = TemplateEvaluator(src)
    best = None
    for name, (params, _body) in ev.methods.items():
        # The entry point takes the render environment, which contributes
        # nothing to the text, so bind every parameter to an empty string.
        try:
            text = ev.call(name, [""] * len(params))
        except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
            continue
        if re.search(rf"\b\w+\s+{re.escape(op_function)}\s*\(", text) and _balanced(text):
            if best is None or len(text) > len(best):
                best = text
    return best


LIST_METHOD_RE = re.compile(
    r"^\s*(?:public|private|protected)\s+(?:final\s+)?List\s+(\w+)\s*\(([^)]*)\)\s*\{",
    re.M,
)
LIST_CALL_RE = re.compile(r"\b[\w.]*\.X\((.*)\)$", re.S)
# `return <expr>` in a helper-list method, whatever list shape it builds.
LIST_RETURN_RE = re.compile(r"^return\s+(.*)$", re.S)


def split_functions(text: str) -> list[str]:
    """`A.g.P`: cut a source string after each brace that closes to depth 0.

    `HyperbolicSquare` hands its helpers over as one string and lets the app
    split it, so the pieces only exist after running the same split.
    """
    out, start, depth = [], 0, 0
    for i, ch in enumerate(text):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                out.append(text[start : i + 1])
                start = i + 1
    if start < len(text):
        out.append(text[start:])
    return out


def _list_items(text: str, ev: "TemplateEvaluator", env: dict) -> list[str]:
    """The strings a list expression evaluates to."""
    text = text.strip()
    m = re.match(r"^([\w.]+)\s*\(", text)
    if m and match_paren(text, text.index("(")) == len(text) - 1:
        short = m.group(1).split(".")[-1]
        args = split_args(text[text.index("(") + 1 : -1])
        if short == "X":
            return [i for a in args for i in _list_items(a, ev, env)]
        if short in ("P0", "Q0", "z0") and len(args) == 2:
            return _list_items(args[0], ev, env) + _list_items(args[1], ev, env)
        if short == "P" and len(args) == 1:
            return [
                p
                for i in _list_items(args[0], ev, env)
                for p in split_functions(i)
                if p.strip()
            ]
    try:
        value = ev.expr(text, env, 0)
    except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
        return []
    return [value] if value.strip() else []


def assemble_helpers(src: str, _depth: int = 0) -> list[str]:
    """The GLSL fragments a class's `List`-returning methods build.

    The helpers are not plain literals: the ones that call the distance
    function or the ray marcher are concatenated with the same argument list
    the entry point uses, so each has to be evaluated.  Reading them as
    literals produced a `rayMarch` taking two parameters while every call
    passed twelve.
    """
    ev = TemplateEvaluator(src)
    out: list[str] = []
    for m in LIST_METHOD_RE.finditer(src):
        open_brace = src.index("{", m.end() - 1)
        end = ev._match_brace(src, open_brace)
        if end == -1:
            continue
        body = src[open_brace + 1 : end]
        env = {
            p.strip().split()[-1]: ""
            for p in m.group(2).split(",")
            if p.strip()
        }
        stmts = [s.strip() for s in statements(body) if s.strip()]
        head = ";\n".join(s for s in stmts if not s.startswith("return")) + ";"
        tail = next((s for s in stmts if s.startswith("return")), "")
        try:
            ev.populate(head, env, 0)
        except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
            continue
        listed = LIST_RETURN_RE.match(tail)
        if not listed:
            continue
        out.extend(_list_items(listed.group(1), ev, env))

    # A helper list can also be a field the constructor fills, which is where
    # an abstract base keeps the functions all its subclasses share --
    # `OrbitsFractal` holds `getColor` and `getCombinedColor` that way.  Without
    # them a same-named helper from another filter was resolved instead.
    for init in ev.fields.values():
        listed = LIST_CALL_RE.search(init.strip())
        if not listed:
            continue
        for arg in split_args(listed.group(1)):
            try:
                text = ev.expr(arg.strip(), {}, 0)
            except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
                continue
            if text.strip() and _FUNC_DEF.search(text):
                out.append(text)

    if ev.parent and _depth < 4:
        parent = CLASS_SOURCES.get(ev.parent)
        if parent is not None:
            if not isinstance(parent, str):
                parent = Path(parent).read_text()
            out.extend(assemble_helpers(parent, _depth + 1))
    return out


_FUNC_DEF = re.compile(
    r"\b(?:void|bool|int|float|[ibu]?vec[234]|mat[234])\s+\w+\s*\([^;{]*\{"
)


def _balanced(text: str) -> bool:
    """Braces balance, ignoring the ones inside commented-out code."""
    depth = 0
    for ch in re.sub(r"//[^\n]*|/\*.*?\*/", "", text, flags=re.S):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


ENTRY_RE = re.compile(
    r"\bvec4\s+(\w+)\s*\(\s*vec2\s+\w+\s*,\s*vec2\s+\w+", re.S
)


def assemble_any(src: str) -> str | None:
    """The longest assembled text that defines a filter entry point.

    An abstract base holds the shader for a family of operators and names the
    operator through a variable, so there is no function name to look for --
    `AbstractShape` carries the whole `shape-*` family this way.  The entry
    point is recognisable by shape instead: `vec4 f(vec2, vec2, ...)`.
    """
    ev = TemplateEvaluator(src)
    best = None
    for name, (params, _body) in ev.methods.items():
        try:
            text = ev.call(name, [""] * len(params))
        except (Unevaluable, RecursionError, KeyError, ValueError, IndexError):
            continue
        if ENTRY_RE.search(text) and _balanced(text):
            if best is None or len(text) > len(best):
                best = text
    return best
