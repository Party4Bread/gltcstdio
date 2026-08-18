"""Choose, per filter, the shader source that actually compiles.

A filter's GLSL can be recovered three ways and none is best everywhere:

  * the literals jadx shows, which are complete for most filters;
  * the Java string-template assembly, which is right when the shader is
    built by generator methods taking arguments;
  * the dex bytecode concatenation, which is right when the pieces sit in
    fields the decompiler cannot show.

Rather than guess, every candidate is compiled against a real GL context and
the first that works is kept.  Filters that already compile are left alone.
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
sys.path.insert(0, str(Path(__file__).parent.parent))

from resolve_helpers import complete  # noqa: E402
from template_shader import assemble  # noqa: E402

VERT = """#version 330 core
in vec2 a_pos;
out vec2 v_uv;
void main(){ v_uv = a_pos*0.5+0.5; gl_Position = vec4(a_pos,0,1); }
"""


def make_ctx():
    os.environ.pop("DISPLAY", None)
    os.environ.pop("WAYLAND_DISPLAY", None)
    import moderngl

    return moderngl.create_context(standalone=True, require=330, backend="egl")


def compiles(renderer, filter_id: str) -> bool:
    from gltcstdio.backends.gl import ShaderError

    try:
        renderer.program(renderer.bank.get(filter_id))
    except (ShaderError, Exception):  # noqa: BLE001
        return False
    return True


def main() -> None:
    from gltcstdio.backends.gl import get_renderer

    shaders = json.loads(Path("work/shaders.json").read_text())
    dex_path = Path("work/dex_shaders.json")
    dex = json.loads(dex_path.read_text()) if dex_path.exists() else {}
    glsl_dir = Path("gltcstdio/data/glsl/filters")
    renderer = get_renderer()

    swapped: list[str] = []
    for fid, rec in sorted(shaders.items()):
        path = glsl_dir / f"{fid}.glsl"
        if not path.exists():
            continue
        if compiles(renderer, fid):
            continue

        original = path.read_text()
        candidates: list[str] = []

        # The Java template assembly, when the class builds its shader from
        # generator methods.
        src_path = Path(rec["source_path"])
        if src_path.exists():
            built = assemble(src_path.read_text(), rec["function"])
            if built:
                candidates.append(built)

        # The dex concatenation.
        entry = dex.get(fid)
        if entry:
            main_text = entry["main"] if isinstance(entry, dict) else entry
            helpers = entry.get("helpers", []) if isinstance(entry, dict) else []
            candidates.append("\n\n".join([*helpers, main_text]))

        chosen = None
        for cand in candidates:
            text = complete(cand)
            path.write_text(text)
            renderer._programs.pop(fid, None)
            if compiles(renderer, fid):
                chosen = text
                break

        if chosen is None:
            path.write_text(original)
            renderer._programs.pop(fid, None)
        else:
            swapped.append(fid)

    print(f"swapped in a compiling source for {len(swapped)} filters")
    for fid in swapped:
        print(f"   {fid}")


if __name__ == "__main__":
    main()
