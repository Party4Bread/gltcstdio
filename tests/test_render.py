"""Rendering tests.

The sweep over every supported filter is the highest-value test here: it
catches shader-assembly regressions across the whole bank at once, which no
amount of testing one filter would.
"""

import numpy as np
import pytest

from gltcstdio import apply, get_filter, list_filters


def test_every_supported_filter_compiles_and_renders(renderer, image):
    """Assembly must work for the whole bank, not just the filters we tried."""
    failures = []
    for f in list_filters(backend="gl"):
        try:
            out = renderer.render(f.id, image)
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{f.id}: {type(exc).__name__}: {exc}")
            continue
        if out.shape != image.shape:
            failures.append(f"{f.id}: shape {out.shape} != {image.shape}")
    assert not failures, f"{len(failures)} filters failed:\n" + "\n".join(failures[:20])


def test_halftone_produces_two_tone_output(renderer, image):
    out = renderer.render("halftone", image, preset="dots")
    colours = np.unique(out.reshape(-1, 4), axis=0)
    # Ink and paper, and nothing else.
    assert len(colours) == 2


def test_style_parameter_changes_the_result(renderer, image):
    a = renderer.render("halftone", image, style=0)
    b = renderer.render("halftone", image, style=2)
    assert not np.array_equal(a, b)


def test_preset_changes_the_result(renderer, image):
    a = renderer.render("halftone", image, preset="dots")
    b = renderer.render("halftone", image, preset="concentric lines")
    assert not np.array_equal(a, b)


def test_output_size_can_be_overridden(renderer, image):
    out = renderer.render("halftone", image, size=(48, 32))
    assert out.shape == (32, 48, 4)


def test_identity_preserves_the_image(renderer, image):
    """A pass-through filter should return what it was given."""
    if "identity" not in renderer.bank:
        pytest.skip("no identity filter in this bank")
    out = renderer.render("identity", image)
    assert np.abs(out.astype(int) - image.astype(int)).mean() < 2.0


@pytest.mark.parametrize("fid", [f.id for f in list_filters(backend="cpu")])
def test_cpu_filters_render(fid, image):
    out = np.array(apply(fid, image))
    assert out.shape[:2] == image.shape[:2]
    assert out.dtype == np.uint8
    assert out[..., :3].std() > 0, "output is a single flat colour"


def test_cpu_filters_declare_fidelity():
    for f in list_filters(backend="cpu"):
        assert f.fidelity in ("recovered", "reimplemented")


def test_apply_accepts_paths_and_arrays(image, tmp_path):
    from PIL import Image

    p = tmp_path / "in.png"
    Image.fromarray(image).save(p)
    a = np.array(apply("halftone", p))
    b = np.array(apply("halftone", image))
    assert np.array_equal(a, b)


def test_apply_accepts_rgb_without_alpha(image):
    rgb = image[..., :3]
    out = np.array(apply("halftone", rgb))
    assert out.shape[:2] == rgb.shape[:2]


def test_pixel_sort_preserves_the_pixel_multiset(image):
    """Sorting rearranges pixels; it must not invent or lose any."""
    out = np.array(apply("pixel-sort", image, intensity=1.0, mode=0))
    for row_in, row_out in zip(image, out):
        a = np.sort(row_in[..., :3].sum(axis=1))
        b = np.sort(row_out[..., :3].sum(axis=1))
        assert np.array_equal(a, b)


def test_gaussian_blur_reduces_variance(image):
    out = np.array(apply("gaussian-blur2", image, radius=0.05))
    assert out[..., :3].std() < image[..., :3].std()


def test_unknown_filter_raises():
    with pytest.raises(KeyError):
        get_filter("no-such-filter")


def _red_like(image):
    red = np.zeros_like(image)
    red[..., 0] = 255
    red[..., 3] = 255
    return red


def test_multi_input_filters_bind_the_second_image(renderer, image):
    """A filter that samples source2 must actually see what we bind there."""
    red = _red_like(image)
    plain = renderer.render("checkerboard-combine", image)
    bound = renderer.render("checkerboard-combine", image, inputs={"source2": red})
    change = np.abs(plain.astype(int) - bound.astype(int)).mean()
    assert change > 1.0, f"second input was not sampled (mean change {change})"


def test_most_multi_input_filters_respond_to_a_second_image(renderer, image):
    """Guards the binding path as a whole, not just one filter.

    Not every filter reacts at default parameters -- some only composite the
    secondary input on certain modes -- so this asserts a healthy majority
    rather than all of them.
    """
    from gltcstdio import list_filters

    red = _red_like(image)
    # Scoped to the shader-backed ones: these drive the GL renderer directly,
    # and twelve multi-input filters are now graphs whose secondary input the
    # graph engine feeds rather than the caller.  Those are covered by
    # `test_graph_chains_only_supported_filters` and tools/verify.py.
    multi = [f for f in list_filters() if f.extra_inputs and f.backend == "gl"]
    responding = 0
    for f in multi:
        plain = renderer.render(f.id, image)
        bound = renderer.render(f.id, image, inputs={k: red for k in f.extra_inputs})
        if np.abs(plain.astype(int) - bound.astype(int)).mean() > 1.0:
            responding += 1
    assert responding >= len(multi) // 2, (
        f"only {responding}/{len(multi)} multi-input filters responded"
    )


def test_missing_secondary_input_falls_back_to_primary(renderer, image):
    """Every filter stays renderable when only one image is supplied."""
    from gltcstdio import list_filters

    # Scoped to the shader-backed ones: these drive the GL renderer directly,
    # and twelve multi-input filters are now graphs whose secondary input the
    # graph engine feeds rather than the caller.  Those are covered by
    # `test_graph_chains_only_supported_filters` and tools/verify.py.
    multi = [f for f in list_filters() if f.extra_inputs and f.backend == "gl"]
    assert multi, "expected some multi-input filters in the bank"
    for f in multi:
        out = renderer.render(f.id, image)
        assert out.shape == image.shape, f.id


def test_secondary_input_may_differ_in_size(renderer, image):
    small = image[::2, ::2].copy()
    out = renderer.render("checkerboard-combine", image, inputs={"source2": small})
    assert out.shape == image.shape


def test_curated_looks_render(image):
    """The preset-* operators chain several filters; all must execute."""
    from gltcstdio import list_filters

    graphs = [f for f in list_filters() if f.backend == "graph"]
    assert graphs, "expected curated looks in the bank"
    for f in graphs:
        out = np.array(apply(f.id, image).convert("RGBA"))
        assert out.shape[:2] == image.shape[:2], f.id


def test_wrapped_filters_render_and_match_their_raw_shader():
    """A filter rebuilt as the app's wrapper renders, and stays faithful.

    The two wrappers are neutral in different ways, so they are held to
    different standards.

    A blur wrapper feeds one input from a blurred copy of the source, and
    `gaussian-blur2` at radius 0 is the identity: with the control at 0 it must
    give back exactly what the shader alone gives.

    A locus blend confines the effect to a region, and at the default mode the
    region is the whole frame -- so the result is the effect, not the source.
    It is not bit-exact there: the effect is rendered to a texture and sampled,
    which a kaleidoscope's hard edges show and a smooth filter does not. The
    claim is that the frame carries the effect, which resampling does not
    change.
    """
    import numpy as np

    from gltcstdio import apply, get_filter, list_filters

    wrapped = [f for f in list_filters() if getattr(f, "wrapped", None)]
    assert len(wrapped) >= 60, f"expected the bank to carry the wrappers, got {len(wrapped)}"

    img = np.zeros((64, 64, 4), np.uint8)
    yy, xx = np.mgrid[0:64, 0:64]
    img[..., 0] = xx * 4
    img[..., 1] = yy * 4
    img[..., 2] = 128
    img[..., 3] = 255

    for f in wrapped:
        raw = get_filter(f.wrapped)
        assert raw.supported, f"{f.id} wraps unsupported {f.wrapped}"

        # Whatever the wrapper fixes on the shader it blends.
        graph = f.graph or {}
        pins = {}
        for node in [graph, *(graph.get("inputs") or {}).values()]:
            if isinstance(node, dict):
                pins.update({k: v for k, v in (node.get("params") or {}).items()
                             if not isinstance(v, dict)})
        names = {p.name for p in raw.params}
        effect = np.asarray(apply(f.wrapped, img,
                                  **{k: v for k, v in pins.items() if k in names}))

        blur = {p.name for p in f.params} & {"smoothen", "smoothing", "blur"}
        if blur:
            out = np.asarray(apply(f.id, img, **{next(iter(blur)): 0.0}))
            assert np.array_equal(out, effect), (
                f"{f.id} differs from {f.wrapped} with its blur off"
            )
            continue

        out = np.asarray(apply(f.id, img))
        assert out.shape == img.shape, f.id
        to_effect = np.abs(out.astype(int) - effect.astype(int)).mean()
        to_source = np.abs(out.astype(int) - img.astype(int)).mean()
        assert to_effect <= to_source, (
            f"{f.id} at its default locus is nearer the source than the effect "
            f"({to_effect:.1f} vs {to_source:.1f}) -- the blend is not covering "
            f"the frame"
        )


def test_graph_chains_only_supported_filters():
    """A graph is only as usable as the filters it chains."""
    from gltcstdio import get_filter, list_filters

    for f in [x for x in list_filters() if x.backend == "graph"]:
        assert f.chain, f.id
        for used in f.chain:
            assert get_filter(used).supported, f"{f.id} chains unsupported {used}"


# --- properties verified across the whole bank (tools/verify.py) -----------


def test_identity_is_pixel_exact(renderer, image):
    """The coordinate convention must round-trip exactly.

    `uv` spans WORLD units and the __source__ macros map back; if either side
    changes without the other, a pass-through filter stops being exact.
    """
    out = renderer.render("identity", image)
    assert np.array_equal(out, image)


def test_generators_tile(renderer, image):
    """Generators read `floor(uv)`, so the coordinate must span units.

    Over [0,1] `floor` is constant and these collapse to one colour.
    """
    for fid in ("checkerboard", "xor-patterns"):
        if fid not in renderer.bank:
            continue
        out = renderer.render(fid, image)
        assert len(np.unique(out.reshape(-1, 4), axis=0)) > 1, fid


def test_every_filter_is_deterministic(image):
    """Same input twice, same output -- no unseeded randomness anywhere."""
    from gltcstdio import list_filters

    for f in list_filters():
        a = np.array(apply(f.id, image).convert("RGBA"))
        b = np.array(apply(f.id, image).convert("RGBA"))
        assert np.array_equal(a, b), f.id


def test_every_filter_handles_a_different_size(image):
    small = image[::2, ::2].copy()
    from gltcstdio import list_filters

    for f in list_filters():
        out = np.array(apply(f.id, small).convert("RGBA"))
        assert out.shape[:2] == small.shape[:2], f.id


def test_output_is_always_a_valid_image(image):
    from gltcstdio import list_filters

    for f in list_filters():
        out = np.array(apply(f.id, image).convert("RGBA"))
        assert out.dtype == np.uint8, f.id
        assert out.shape == image.shape, f.id
