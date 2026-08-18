"""Loading and lookup for the extracted filter bank."""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

from .params import Filter

DATA_DIR = Path(__file__).parent / "data"
GLSL_DIR = DATA_DIR / "glsl"


class Bank:
    """The set of filters extracted from the app."""

    def __init__(self, data: dict, root: Path):
        self._root = root
        self.version = data.get("version", 0)
        self.source = data.get("source", "")
        self._stdlib_name = data.get("stdlib", "stdlib.glsl")
        self._filters = {
            fid: Filter.from_dict(f) for fid, f in data.get("filters", {}).items()
        }
        # CPU filters live in code rather than the extracted bank, but appear
        # in the same registry so callers need not care which backend runs.
        from .backends.cpu import REGISTRY as CPU_REGISTRY

        for fid, spec in CPU_REGISTRY.items():
            # Where the app's own shader was recovered and verified to work,
            # it ships instead of the reimplementation -- same filter, the
            # real algorithm, and orders of magnitude faster.
            extracted = self._filters.get(fid)
            if extracted is not None and getattr(extracted, "prefer_gl", False):
                continue
            self._filters[fid] = Filter.from_dict(
                {**spec, "supported": True, "inputs": 1}
            )

    # -- lookup -------------------------------------------------------------
    def __contains__(self, fid: str) -> bool:
        return fid in self._filters

    def __len__(self) -> int:
        return len(self._filters)

    def __iter__(self):
        return iter(self._filters.values())

    def get(self, fid: str) -> Filter:
        try:
            return self._filters[fid]
        except KeyError:
            near = [k for k in self._filters if fid.lower() in k.lower()][:5]
            hint = f"; did you mean {near}?" if near else ""
            raise KeyError(f"no filter {fid!r}{hint}") from None

    def list(
        self,
        category: str | None = None,
        supported_only: bool = True,
        backend: str | None = None,
    ) -> list[Filter]:
        out = list(self._filters.values())
        if category is not None:
            out = [f for f in out if f.category == category]
        if supported_only:
            out = [f for f in out if f.supported]
        if backend is not None:
            out = [f for f in out if f.backend == backend]
        return sorted(out, key=lambda f: (f.category, f.id))

    @property
    def categories(self) -> list[str]:
        return sorted({f.category for f in self._filters.values()})

    # -- shader sources -----------------------------------------------------
    @property
    def stdlib(self) -> str:
        return (self._root / self._stdlib_name).read_text()

    def glsl(self, fid: str) -> str:
        f = self.get(fid)
        if not f.glsl_path:
            raise ValueError(f"{fid} has no GLSL source (backend={f.backend})")
        return (self._root / f.glsl_path).read_text()


@lru_cache(maxsize=1)
def load_bank() -> Bank:
    path = DATA_DIR / "bank.json"
    if not path.exists():
        raise FileNotFoundError(
            f"filter bank not found at {path}; run tools/build_bank.py first"
        )
    return Bank(json.loads(path.read_text()), GLSL_DIR)
