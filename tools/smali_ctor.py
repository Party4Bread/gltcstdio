"""Read per-filter parameter overrides out of undecompilable constructors.

jadx gives up on many filter constructors ("Illegal instructions before
constructor call") and emits the register code instead.  That code still spells
out the parameter builder calls, so the overrides are recoverable:

        V4.c2 r1 = V4.AbstractC0565h2.f7990f0
        V4.c2 r1 = r1.j()
        r2 = 4607182418800017408(0x3ff0000000000000, double:1.0)
        java.lang.Double r4 = java.lang.Double.valueOf(r2)
        V4.c2 r1 = r1.p(r4)                      <- default 1.0
        ...
        java.lang.Object[] r0 = new java.lang.Object[]{r0, r1, r4, r5, r2}
        r10.<init>(r0)                           <- the super() argument list

Without this, filters whose constructor failed to decompile fall back to
registry defaults, and several of those render a flat image (`duotone`
collapses to black at saturation 0 when its real default is 0.25).

The register code is rewritten into ordinary assignments and handed to the
same interpreter that reads the readable constructors.
"""

from __future__ import annotations

import re

# `r2 = 4607182418800017408(0x3ff0000000000000, double:1.0)`
WIDE_CONST = re.compile(r"^(\w+)\s*=\s*-?\d+\(0x[0-9a-fA-F]+,\s*(double|float):\s*(-?[\d.eE+-]+)\)$")
# `r2 = 50` / `r4 = 0`
INT_CONST = re.compile(r"^(\w+)\s*=\s*(-?\d+)$")
# `java.lang.Double r4 = java.lang.Double.valueOf(r2)`
BOXED = re.compile(r"^[\w.\[\]]+\s+(\w+)\s*=\s*java\.lang\.\w+\.valueOf\((\w+)\)$")
# `V4.c2 r1 = <expr>` -- drop the leading type
TYPED_ASSIGN = re.compile(r"^[\w.$]+(?:\[\])?\s+(r\d+|\w+)\s*=\s*(.+)$")
# `java.lang.Object[] r0 = new java.lang.Object[]{r0, r1}`
ARRAY_NEW = re.compile(r"^new\s+[\w.$]+\[\]\{(.*)\}$", re.S)
# `r10.<init>(r0)`
SUPER_CALL = re.compile(r"^(\w+)\.<init>\((.*)\)$")

# The register dump sits in a comment inside the method body, followed by a
# `throw new UnsupportedOperationException("Method not decompiled: ...")`.
CTOR_BLOCK = re.compile(
    r"(?:private|public|protected)\s+\w+\(\)\s*\{\s*/\*(.*?)\*/", re.S
)


def find_register_block(src: str) -> str | None:
    """The register dump of a no-argument constructor, if jadx emitted one."""
    for m in CTOR_BLOCK.finditer(src):
        body = m.group(1)
        if "<init>" in body or ".p(" in body or "c2 " in body:
            return body
    return None


def rewrite(block: str) -> tuple[list[str], str | None]:
    """Turn register code into plain assignments.

    Returns (statements, super_args_register).
    """
    consts: dict[str, str] = {}
    stmts: list[str] = []
    super_reg: str | None = None
    # Register -> the type it was allocated with but not yet constructed.
    allocations: dict[str, str] = {}

    for raw in block.splitlines():
        line = raw.strip().rstrip(";")
        if not line or line.startswith("//"):
            continue
        if line in ("return", "return-void") or line.endswith("= this"):
            continue

        m = WIDE_CONST.match(line)
        if m:
            consts[m.group(1)] = m.group(3)
            continue

        m = INT_CONST.match(line)
        if m:
            consts[m.group(1)] = m.group(2)
            continue

        m = BOXED.match(line)
        if m:
            src_reg = m.group(2)
            if src_reg in consts:
                consts[m.group(1)] = consts[src_reg]
                continue
            consts.pop(m.group(1), None)
            stmts.append(f"{m.group(1)} = {src_reg}")
            continue

        m = SUPER_CALL.match(line)
        if m:
            receiver, raw_args = m.group(1), m.group(2)
            args = [a.strip() for a in raw_args.split(",") if a.strip()]
            # Register code splits an allocation from its constructor:
            #   E2.a r6 = new E2.a
            #   r6.<init>(r7, r8)
            # Treating every `<init>` as the super call dropped the value and,
            # with it, the translation in `mandelbrot-orbits`'s transform.
            pending = allocations.pop(receiver, None)
            if pending is not None:
                filled = ", ".join(consts.get(a, a) for a in args)
                stmts.append(f"{receiver} = new {pending}({filled})")
                consts.pop(receiver, None)
                continue
            super_reg = args[0] if args else None
            continue

        m = TYPED_ASSIGN.match(line)
        if m:
            target, expr = m.group(1), m.group(2)
        elif re.match(r"^(r\d+|\w+)\s*=\s*.+$", line):
            target, expr = line.split("=", 1)
            target, expr = target.strip(), expr.strip()
        else:
            continue

        # Substitute numeric registers so the interpreter sees literals.  The
        # right-hand side is resolved against the values in force *before* this
        # assignment, then the target stops being a constant -- registers are
        # reused, and a stale entry would rewrite a later descriptor into a
        # number (`n.d(-1.0, 1.0, r6)` becoming `n.d(-1.0, 1.0, 1.0)`).
        def sub(mo):
            r = mo.group(0)
            return consts.get(r, r)

        bare = re.match(r"^new\s+([\w.$]+)$", expr)
        if bare:
            # Allocation only; the values arrive with the `<init>` call.
            allocations[target] = bare.group(1)
            consts.pop(target, None)
            continue

        expr = re.sub(r"\br\d+\b", sub, expr)
        consts.pop(target, None)
        allocations.pop(target, None)
        stmts.append(f"{target} = {expr}")

    return stmts, super_reg


def super_args_from_registers(src: str) -> list[str] | None:
    """The ordered parameter expressions a smali constructor passes to super."""
    block = find_register_block(src)
    if block is None:
        return None
    stmts, super_reg = rewrite(block)
    if super_reg is None:
        return None

    # The super argument is usually an array built just before the call, but
    # registers are reused: the orbit fractals build an array into r0, wrap it
    # in a list, concatenate a shared group onto it and hand *that* to super.
    # Only the last write to the register counts, and when it is not an array
    # the register itself is the argument, for the interpreter to expand.
    last: dict[str, str] = {}
    for stmt in stmts:
        target, _, expr = stmt.partition(" = ")
        last[target.strip()] = expr.strip()

    final = last.get(super_reg)
    if final is None:
        return None
    m = ARRAY_NEW.match(final)
    if m:
        return [a.strip() for a in m.group(1).split(",") if a.strip()]
    return [super_reg]


def register_statements(src: str) -> list[str]:
    """Assignments from the register block, for seeding an interpreter.

    Array construction is kept: a constructor that passes a list rather than
    an array needs the array in scope so the list can be resolved from it.
    """
    block = find_register_block(src)
    if block is None:
        return []
    stmts, _ = rewrite(block)
    return stmts
