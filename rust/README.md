# gltcstdio (Rust)

The same 769 filters as the Python package, in Rust: the app's own shaders
translated to WGSL and run through `wgpu`, so they work natively on Vulkan,
Metal and DX12, and in a browser on WebGPU.

```
crates/gltcstdio        the library: bank, wgpu renderer, CPU filters, graphs
crates/gltcstdio-py     Python bindings (PyO3 + maturin)
crates/gltcstdio-wasm   WebGPU bindings (wasm-bindgen)
xtask                        GLSL -> WGSL translation
```

## What is in the bank

| | count |
|---|---|
| Filters that render | **769** |
| — GPU (the app's GLSL, translated to WGSL) | 463 |
| — the app's own wrappers around those | 65 |
| — the app's own blur, a graph over two of them | 1 |
| — curated looks (chained filter graphs) | 175 |
| — CPU | 65 |
| Categories | 33 |
| Presets | 1388 |
| Configurable parameters | 5246 |

Rendering the whole bank once at 256x256 takes about 2.1 s on an RTX 5070 Ti.

Inputs carry a full mip chain, built the way GL derives one: a plain halving
where a dimension is even, and the three-tap weighted filter the spec calls
for where it is odd. Filters that minify -- a mosaic reading one texel per
cell, a kaleidoscope folding the image down -- get an averaged colour rather
than whichever texel they landed on, and get it at any image size.

## Use

```rust
use gltcstdio::{params, Image, Renderer};

let mut r = Renderer::new_blocking()?;                  // opens a GPU device
let src = Image::new(w, h, rgba_bytes);
let out = r.apply("halftone", &src, &params![("intensity", 0.8)])?;
let out = r.apply_preset("contour", &src, "strong", &Default::default())?;
```

`Image` is RGBA8, row-major, top row first. `Renderer` holds the device and
every pipeline it has built, so keep one rather than making one per image.

Secondary inputs -- `source2`, `sourceBkg`, `displacement` and the rest --
are bound by name:

```rust
let mut inputs = std::collections::HashMap::new();
inputs.insert("source2".to_string(), other);
let out = r.apply_with_inputs("blend-with-mask", &src, &Default::default(), &inputs)?;
```

Anything a filter reads but the caller did not supply falls back to the
primary image, so every filter renders from one image alone.

A chain can read from several images. A leaf is `{"input": "source"}` for the
image passed in, or any other name to take one of the images given alongside
it -- which is what a combine needs: two different photographs rather than the
same one twice.

```rust
let graph = serde_json::from_value(serde_json::json!({
    "filter": "checkerboard-combine",
    "inputs": { "source1": {"input": "source"}, "source2": {"input": "other"} },
}))?;
let mut sources = HashMap::new();
sources.insert("other".to_string(), second);
let out = r.apply_graph_with_sources(&graph, &src, &Default::default(), &sources)?;
```

Without a GPU, `Renderer::new` falls back to CPU-only and the 65 CPU filters
still work; `Renderer::cpu_only()` skips the device entirely.

## Speed

The renderer keeps the images it has uploaded, keyed by their content, and a
render only pays for an input it has not seen. That matters because the mip
chain is built on the CPU to match what GL derives, and it dominates
everything else: **78%** of a 1024x1024 render was the pyramid rather than the
shader. Reusing it turns every repeat -- a slider moved, a thumbnail redrawn,
the second image of a combine, every stage of a chain upstream of the one
being edited -- into the shader alone.

`cargo run --release --example hop_cost` measures it, best of many runs on an
idle machine. Cold is an image the renderer has not seen; warm is what a
slider drag, a thumbnail or a second input pays:

| | 512² | 1024² | 2048² |
|---|---|---|---|
| the mip chain alone | 2.5 ms | 10.0 ms | 39.3 ms |
| one filter, cold | 3.4 ms | 12.0 ms | 48.8 ms |
| one filter, warm | **0.73 ms** | **1.5 ms** | **5.8 ms** |
| chain of 8, cold → warm | 28.3 → **6.5 ms** | 100.8 → **14.7 ms** | 408 → 403 ms |
| a value moved on the last of 4 | **3.2 ms** | **8.0 ms** | **33.2 ms** |

The mip chain is 72–83% of a cold render across those sizes, which is the
whole of the difference. In a browser, where a readback also costs a trip
through the event loop:

| | 512² | 1024² |
|---|---|---|
| one filter, cold → warm | 12.0 → **5.0 ms** | 44.4 → **18.2 ms** |
| chain of 6, cold → warm | 66.1 → **29.0 ms** | 246 → **112 ms** |

The one case it does not help is a long chain at 2048x2048: eight
intermediates are 176 MB, past the budget, so nothing survives to the next
render — editing that chain still costs 33 ms, because only the stages after
the one being edited are new.

The slow tail used to be one filter, and is not any more. `gaussian-blur2`
was a CPU reimplementation costing 200 ms at radius 0.02 and 1.6 s at 0.12 on
a 900x900 image, and the 21 blur wrappers and every chain over them route
through it. It is not a filter of the app's own:
`effects/blur/GaussianBlur.java` registers it as `(gaussian-blurh
(gaussian-blurv source radius) radius)` over two shaders that were recovered,
and it is now that graph, at 3.8 ms whatever the radius.

Using them meant fixing them first. They are three of the shaders written
against the engine's earlier uniform convention -- `blur` is the third -- and
they read the source through `u_SourceTransform` while every other legacy
matrix is the identity. The coordinate they are handed spans world units, so
bound to the identity they sampled the texture at those coordinates directly
and translated the picture half a frame instead of blurring it, plausibly
enough that nothing caught it: `gaussian-blurv` at radius 0 should return its
input untouched and came back a mean 31/255 away. That uniform now carries the
map back to texture space, which is the same one the `__source__` macros apply
everywhere else, in both renderers.
`the_blur_shaders_sample_where_they_are_looking` pins it, and the two
renderers agree to within 0.3 on how much each pass flattens a noise field.

Across the bank that took a render of all 769 at 900x900 from 47.0 s to
11.3 s, the median from 6.4 ms to 4.2 ms, and the filters costing more than a
quarter second from 33 to 10. In the editor `height-map-wireframe-gl` went
from 26.6 s to 197 ms.

The cache is exact rather than approximate: a texture is reused only for
identical pixels, and `the_upload_cache_changes_nothing` renders all 769
filters through a renderer holding other images to prove it. It holds at most
128 MB of device memory, oldest out first.

## Python

```bash
cd crates/gltcstdio-py
maturin develop --release        # or: maturin build --release
```

```python
import gltcstdio_rs as of

of.apply("halftone", "photo.jpg", intensity=0.8).save("out.png")
of.apply("menger-sponge", numpy_array)          # returns a numpy array
of.describe("halftone")                          # parameters, ranges, presets
of.list_filters()                                # all 769 ids
```

`apply` returns whatever it was given: a PIL image for a PIL image or a path,
a numpy array for an array. The renderer is opened once and shared.

## Web

The editor at `editor/` is this crate: a static page with no server behind it.

```bash
./editor/build.sh                       # from the repository root
python -m http.server -d editor 8000
```

`build.sh` emits the module with its `.d.ts` and then compiles the page's
TypeScript against it, so the calls below are checked rather than assumed.

```js
import init, { Filters, catalog, describe } from "./pkg/gltcstdio_wasm.js";

await init();
const filters = await Filters.open();          // rejects without WebGPU
const out = await filters.render("halftone", imageData.data, w, h,
                                 '{"intensity": 0.8}');
ctx.putImageData(new ImageData(new Uint8ClampedArray(out), w, h), 0, 0);
```

Everything is embedded in the module -- the bank, every shader and the font --
so the page loads nothing but the module itself. `catalog()` returns all 769
filters with their parameters and presets in one call, which is what the editor
builds its controls from.

A chain goes over in one call, in the same shape the bank stores its curated
looks, so the editor and the bank render by the same path:

```js
const graph = {
  filter: "emboss",
  params: { intensity: 0.4 },
  inputs: { source: { filter: "circle-mosaic", inputs: { source: { input: "source" } } } },
};
const out = await filters.render_graph(JSON.stringify(graph), rgba, w, h);
```

`graph_of("etched-circles")` returns that structure for any of the 175 curated
looks, which is how the editor opens one as editable nodes. It comes back
resolved -- every `bind` replaced by the value that stage actually renders
with, worked out by `graph::resolve_graph`, which is the renderer's own
parameter resolution rather than a second copy of it. Without that, 45 of the
175 open looking different from the look they came from.

### What WebGPU refuses that native wgpu allows

WGSL requires a texture sample that computes its own mip level to sit in
uniform control flow, and 166 of the app's shaders sample inside a conditional
or a loop. Native wgpu accepts them; a browser rejects the whole module, and
the filter draws nothing.

Those filters get a second source that takes the mip level explicitly, and the
build embeds one set or the other by target -- so neither build carries both
and native keeps its mip filtering. Two more take a gradient inside a
conditional; for those the declarations that feed it are lifted out of the
branch, which computes the same value.

The list is measured, not guessed: `Filters.compile_check()` builds every
pipeline and reports what the browser refused, and its output is
`tools/webgpu_uniformity.json`. 462 of 463 shaders compile in Chrome today.
The one that does not, `flower`, takes a gradient inside a conditional nested
too deep to lift. It says so in a sentence rather than drawing a blank frame,
keeping the driver's own message on hover, which is what any refused shader
now does. Three curated looks are built on it -- `glory`, `radiate` and
`seraphim` -- so those are the only three of the 175 a browser cannot show.

## How the shaders got here

The app compiles GLSL ES; WebGPU takes WGSL. `tools/export_rust.py` rewraps
each filter's GLSL in the header WebGPU needs and `xtask` translates it with
naga:

```bash
uv run python tools/export_rust.py     # from the repository root
cargo run -p xtask --release           # writes assets/wgsl/*.wgsl
```

Two things had to change on the way, neither of which alters what a shader
draws:

- **Uniforms into one buffer.** GL looks uniforms up by name; WebGPU has a
  numbered binding per resource. Every uniform is given whole `vec4` slots in
  one buffer -- so the layout is the same under std140 and WGSL, with no
  per-type alignment rules on either side -- and a `#define` puts each name
  back in front of its slot. The bank records which slot holds what.
- **Textures split from samplers.** naga's GLSL frontend only takes the
  Vulkan spelling, so `sampler2D u_source` becomes a `texture2D` plus one
  shared `sampler`, recombined at the use site.

Four constructs naga cannot represent were rewritten in the exporter, each
into the same code written another way: a `switch` whose cases end in
`return` becomes an if/else chain, an array-typed function parameter becomes
a read of the uniform it was passed, a struct constructor holding an array
becomes one assignment per field, and `float a[4], b[4]` becomes two
declarations. All 463 shaders translate.

## Fidelity

Against the Python renderer on the same image, at 256x256. Measured over the
bank as it stood at 773 entries, before four duplicate entries were dropped
and before 25 filters were rebuilt as the wrappers the app registers them as.
Both renderers read the same bank, so those changes move the two together:

| | filters | identical | within 1/255 | within 4/255 | median |
|---|---|---|---|---|---|
| GPU | 532 | 197 | 462 | 484 | 0.00 |
| CPU | 66 | 30 | 63 | 65 | 0.00 |
| graphs | 175 | 40 | 144 | 156 | 0.01 |

669 of the 773 agree to within 1/255 and 705 to within 4/255, and the same
holds at sizes that are neither square nor even -- 664 of 773 within 1/255 at
127x255.

The GPU differences are almost all in filters whose pattern comes from a
`fract(sin(dot(...)))` hash. Rendering that one expression through both paths
on the same GPU gives a mean difference of 63/255, because its argument
reaches several thousand radians and the two compilers reduce that range
differently -- so it is a property of the hash, not of the port. `checkerboard`
and `moire` are bit-identical; `triangles` and the `dichotomic-*` family
subdivide at different pseudorandom points while looking the same.

Only three CPU filters are still more than 1/255 apart, and each says why
where it is implemented:

- **`code-text`** (4.3) draws long lines of text. The atlas is rendered from
  the same font Pillow uses and laid out on the same ink bounds and unrounded
  advances, so single words match closely; over a line of fifty characters
  the font's own fixed-point pen and this one drift apart.
- **`canvas-spray-brush`** (2.5) is the one filter that draws from
  `rng.normal`, whose ziggurat tables are not reproduced here. `random`,
  `integers` and `uniform` are bit-identical to `numpy.random.default_rng` --
  there are tests pinning them to numpy's own values -- and that is what every
  other seeded filter draws from.
- **`alien-text`** (2.1) seeds itself from `hash(str(text))`, which Python
  randomises per process: two runs of the Python build disagree with each
  other. This one is seeded from the text's bytes instead, so it is at least
  the same every time.

Resampling is bilinear where the Python build uses Lanczos.

## Tests

```bash
cargo test --release            # 18 tests; the GPU ones skip without a device
cargo run --release --example sweep -- in.rgba 256 256 out/
cargo run --release --example hop_cost
cargo run --release --example slowest -- 900 25
```

`sweep` renders every filter from a raw RGBA8 file and reports what failed,
which is how the fidelity numbers were measured; `hop_cost` is where the
speed figures come from. `slowest` times every filter at the size the editor
previews at and lists the worst, which is what a report of lag gets checked
against: 769 filters, 4.2 ms median, and 10 of them over 250 ms.

Five of the tests are about the claims above rather than about a filter:
`the_blur_shaders_sample_where_they_are_looking` holds the three shaders that
sample through `u_SourceTransform` to returning their input at a radius under
one pixel and to blurring down their own axis;
`the_padded_convolution_is_the_plain_one` holds the CPU blur's padded inner
loop to the same numbers as the convolution written the obvious way, at sizes
and kernel widths including those wider than the image;
`the_upload_cache_changes_nothing` renders all 769 through a renderer holding
other images, `a_resolved_look_renders_as_the_look` compares every curated
look against its resolved chain, and `renders_at_awkward_sizes` covers the
sizes where the mip chain stops halving cleanly.
