"""Minimal Java expression tokenizer/splitter shared by the extractors.

The decompiled sources are machine generated, so we only need enough of a
parser to walk balanced argument lists and chained builder calls -- not a
real Java grammar.
"""

from __future__ import annotations


def split_args(text: str) -> list[str]:
    """Split a comma separated argument list on top-level commas only."""
    args: list[str] = []
    depth = 0
    in_str = False
    esc = False
    cur: list[str] = []
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
        elif ch in "([{":
            depth += 1
            cur.append(ch)
        elif ch in ")]}":
            depth -= 1
            cur.append(ch)
        elif ch == "," and depth == 0:
            args.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur).strip()
    if tail:
        args.append(tail)
    return args


def match_paren(text: str, open_idx: int) -> int:
    """Index of the ')' matching the '(' at open_idx."""
    depth = 0
    in_str = False
    esc = False
    for i in range(open_idx, len(text)):
        ch = text[i]
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
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
    return -1


def parse_chain(expr: str) -> tuple[str, list[tuple[str, list[str]]]]:
    """Split `base(...).m1(a).m2(b)` into the base expression and its calls.

    Returns (base_expr, [(method_name, [arg, ...]), ...]).
    """
    expr = expr.strip()
    calls: list[tuple[str, list[str]]] = []
    # Walk forward finding `.name(` sequences at depth 0.
    i = 0
    depth = 0
    in_str = False
    esc = False
    split_points: list[int] = []
    while i < len(expr):
        ch = expr[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            i += 1
            continue
        if ch == '"':
            in_str = True
        elif ch in "([":
            depth += 1
        elif ch in ")]":
            depth -= 1
        elif ch == "." and depth == 0:
            split_points.append(i)
        i += 1

    if not split_points:
        return expr, calls

    # A split point only starts a builder call if it is followed by `name(`.
    base_end = len(expr)
    segments: list[str] = []
    for idx, sp in enumerate(split_points):
        end = split_points[idx + 1] if idx + 1 < len(split_points) else len(expr)
        seg = expr[sp + 1 : end]
        if "(" in seg and seg.split("(", 1)[0].isidentifier():
            if base_end == len(expr):
                base_end = sp
            segments.append(seg)

    for seg in segments:
        name = seg.split("(", 1)[0]
        open_idx = seg.index("(")
        close = match_paren(seg, open_idx)
        inner = seg[open_idx + 1 : close] if close != -1 else ""
        calls.append((name, split_args(inner)))

    return expr[:base_end], calls
