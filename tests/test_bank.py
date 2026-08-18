"""The extracted bank should be internally consistent and match the app.

The Halftone assertions are golden values read directly from the decompiled
source, so they catch extractor regressions rather than merely restating
whatever the extractor produced.
"""

import pytest

from gltcstdio import ParamError, get_filter, list_filters


def test_bank_loads(bank):
    assert len(bank) > 250
    assert bank.version >= 1
    assert len(bank.categories) > 20


def test_halftone_matches_source(bank):
    """Golden values taken from Halftone.java and HalftoneKt.java."""
    f = bank.get("halftone")
    assert f.category == "alchemy"
    assert f.supported

    names = [p.name for p in f.params if not p.engine]
    assert names == [
        "smoothen",
        "intensity",
        "modelTransform",
        "color1",
        "color2",
        "sampling",
        "style",
    ]
    # The engine wraps every filter in its view transform, so that one is a
    # parameter of every filter without appearing in the shader signature.
    assert [p.name for p in f.params if p.engine] == ["viewTransform"]

    p = f.param_map
    # `n.d(-3.0, 3.0, intensity).p(1.0)` in the constructor.
    assert (p["intensity"].min, p["intensity"].max) == (-3.0, 3.0)
    assert p["intensity"].default == 1.0
    # Registry entry: range 0..1, label "Smooth".
    assert (p["smoothen"].min, p["smoothen"].max) == (0.0, 1.0)
    assert p["smoothen"].label == "Smooth"
    # colorIn is white, colorOut black.
    assert p["color1"].default == [1.0, 1.0, 1.0, 1.0]
    assert p["color2"].default == [0.0, 0.0, 0.0, 1.0]
    # `n.e(0.02, modelTransform)` -- a scalar default meaning uniform scale.
    assert p["modelTransform"].default[0][0] == pytest.approx(0.02)


def test_halftone_enum_choices(bank):
    """HalftoneKt gives style and sampling labelled choices."""
    p = bank.get("halftone").param_map
    styles = {c["value"]: c["label"] for c in p["style"].choices}
    assert styles == {
        0: "Dots",
        1: "Hex Dots",
        2: "Lines",
        4: "Wavy Lines",
        3: "Concentric Lines",
    }
    assert p["style"].widget == "select"
    sampling = {c["value"]: c["label"] for c in p["sampling"].choices}
    assert sampling == {0: "fixed", 1: "continuous"}


def test_halftone_presets(bank):
    f = bank.get("halftone")
    names = [p.name for p in f.presets]
    assert "hex dots" in names and "concentric lines" in names
    assert f.preset("hex dots").params == {"style": 1}
    # The preview preset passes its transform positionally.
    assert f.preset("preview").params["modelTransform"][0][0] == pytest.approx(0.06)


def test_signature_order_preserved(bank):
    """The generated call must reproduce the shader's argument order."""
    f = bank.get("halftone")
    kinds = [(s["name"], s["kind"]) for s in f.signature_args()]
    assert kinds[:2] == [("uv", "implicit"), ("outPos", "implicit")]
    assert [n for n, k in kinds if k == "param"] == [
        p.name for p in f.params if not p.engine
    ]


def test_engine_uniforms_are_not_user_parameters(bank):
    """Image dimensions and input flags come from the runtime, not sliders."""
    for f in bank.list(supported_only=False):
        for p in f.params:
            assert not p.name.endswith("Dim"), f"{f.id}.{p.name}"
            assert not p.name.endswith("_specified"), f"{f.id}.{p.name}"


def test_every_supported_filter_is_complete(bank):
    for f in bank.list(supported_only=True):
        assert f.id and f.name and f.category
        assert f.backend in ("gl", "cpu", "graph")
        for p in f.params:
            assert p.default is not None, f"{f.id}.{p.name} has no default"


def test_unsupported_filters_state_a_reason(bank):
    for f in bank.list(supported_only=False):
        if not f.supported:
            assert f.unsupported_reason, f"{f.id} unsupported without a reason"


def test_resolve_merges_defaults_preset_and_overrides():
    f = get_filter("halftone")
    assert f.resolve()["style"] == 0
    assert f.resolve(preset="hex dots")["style"] == 1
    assert f.resolve(preset="hex dots", style=2)["style"] == 2


def test_unknown_parameter_is_rejected():
    with pytest.raises(ParamError, match="unknown parameter"):
        get_filter("halftone").resolve(definitely_not_a_param=1)


def test_values_are_clamped_to_range():
    f = get_filter("halftone")
    assert f.resolve(intensity=99.0)["intensity"] == 3.0
    assert f.resolve(intensity=-99.0)["intensity"] == -3.0


def test_hex_colours_are_accepted():
    f = get_filter("halftone")
    assert f.resolve(color1="#ff0000")["color1"] == [1.0, 0.0, 0.0, 1.0]
    assert f.resolve(color1="#fff")["color1"] == [1.0, 1.0, 1.0, 1.0]


def test_listing_filters():
    assert len(list_filters()) > 250
    assert all(f.supported for f in list_filters())
    assert list_filters(category="alchemy")
    assert len(list_filters(backend="cpu")) >= 6
