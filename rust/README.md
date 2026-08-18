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
| — GPU (the app's GLSL, translated to WGSL) | 465 |
| — the app's own wrappers around those | 65 |
| — the app's own lambdas over those (blur, sharpen, dehaze, metal) | 4 |
| — curated looks (chained filter graphs) | 174 |
| — CPU | 61 |
| Categories | 33 |
| Presets | 1399 |
| Configurable parameters | 5272 |

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

Without a GPU, `Renderer::new` falls back to CPU-only and the 61 CPU filters
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
11.3 s and the filters costing more than a quarter second from 33 to 10 -- a
before and after measured against each other, but on the timing this file
later found was inflated by first-use shader compilation, so neither figure
lines up with the ones below. In the editor `height-map-wireframe-gl` went
from 26.6 s to 197 ms.

Above that sits a second cache, on what has been rendered rather than what
has been uploaded. Every filter in the bank is deterministic -- `verify.py`
checks all 769 -- so a stage given the same images and the same values cannot
produce anything new, and a chain has no reason to render its early stages
twice. That is most of what an editor asks for: a slider on the last node
leaves everything above it untouched, each node's thumbnail is the chain as
far as that node, and two branches built the same way are the same picture.
A hit costs a memcpy instead of a shader.

It is keyed on the filter, the content of every image reaching it, and the
values as the caller gave them -- the settings rather than the resolved
numbers, since a graph node's knobs reach its children by name and two calls
that resolve alike at one node can still differ below it.
`the_stage_cache_changes_nothing` renders every filter cold and again warm,
and `the_stage_cache_tells_settings_apart` checks the key is fine enough to
keep two settings of a filter apart, both against references taken with the
cache cleared so neither can inherit a mistake.

What a caller asks for by name is not cached; everything inside a graph is.
Hashing an input and copying an output costs about a millisecond at the size
the editor works at, which is nothing against a chain and 20-40% against one
cheap shader -- and a sweep rendering 769 different filters once each never
asks twice. On the editor's own unit of work, the preview plus a thumbnail
per node for a six-stage chain, the difference is:

| | 512² | 900² |
|---|---|---|
| stages dropped, uploads kept | 73 ms | 222 ms |
| stages kept | **8 ms** | **25 ms** |

`cargo run --release --example chain_cost` measures it natively. A slider on
the last of six stages settles in about a millisecond in the browser.

### The slow end

Five rounds of taking the slowest filter and fixing it took a render of the
whole bank at 900x900 from 9.4 s to 5.0 s, the median from 3.5 ms to 2.3 ms,
and the filters costing more than a quarter second from seven to none. The
worst filter in the bank was 604 ms and is now 213 ms.

| | before | after | |
|---|---|---|---|
| `lens-blur` | 604 ms | 213 ms | four channels through one register |
| `metal` | 382 ms | 18 ms | the app's own lambda |
| `dehaze` | 371 ms | 12 ms | the app's own lambda |
| `mobius-torus` | 341 ms | 8 ms | the app's own shader |
| `hyperbolic-lace` | 201 ms | 2.7 ms | the app's own shader |
| `hyper-warp` | 212 ms | 9.5 ms | chains `hyperbolic-lace` |
| `white-infinite` | 294 ms | — | chains `mobius-torus` |

Only the first is an optimisation in the ordinary sense. `convolve1d` iterated
one channel at a time, and its inner loop is a running float sum, which a
compiler may not vectorise because float addition does not associate. Copying
a line with its channels still interleaved lets four of them go through one
register while each channel still accumulates over the taps in the order it
always did -- wider, not reordered -- and every one of the 769 filters comes
back byte for byte the same.

The other four were CPU reimplementations of filters the app does not
implement that way, and they follow `gaussian-blur2`:

- `Metal.java` registers `metal` as `(dehaze (gradient-displacement source1
  ...))`, and `UnsharpMask` registers `dehaze` and `sharpen` alike as
  `(linear-blend source (gaussian-blur2 source blurRadius) :intensity (neg
  intensity))`. An unsharp mask is a blend towards the blur run backwards,
  which is what the negation is for, and `{"bind": ..., "neg": true}` is how
  the graph format now says so. `sharpen` had already been extracted as this
  graph with none of its bindings, so its one knob did nothing and
  `tools/verify.py` had been reporting it; it now has the intensity the app
  declares as well.
- `mobius-torus` and `hyperbolic-lace` had shaders all along. The first was
  shadowed because a sweep saw it return its input unchanged -- true at
  defaults that give its tube zero thickness, and the app presents it through
  three presets that all render. The second was recorded as failing to
  compile, which it did: it carries a `getNormal` that calls its own two-
  argument `sdf` with one argument. Nothing calls `getNormal`, so it is
  dropped, and the shader compiles.

Nine filters look different for all that -- those five and the four curated
looks that chain them, `dreamy`, `hyper-warp`, `impact` and `white-infinite`
-- and every one of them moved towards what the app does rather than away.
The other 760 are byte-identical.

Two of those nine had further to travel. Both new shaders sample inside a
conditional, so they join the 168 the web build writes with an explicit mip
level; a browser rejects the module outright otherwise, which is what
`compile_check` is for and how the list was regenerated. And `white-infinite`
drew nothing at all once it was reaching the real shader: `WhiteInfinite.java`
declares its transform by inheritance, an identity, then invokes itself with
`(mat4 (vec4 1 0 0 0) (vec4 0 1 0 0) (vec4 0 0 1 0) (vec4 0 0 -1 1))`. The
extractor had kept the declaration and lost the call, which put the torus at
the origin inside the camera; nobody noticed while the reimplementation
ignored the transform entirely. `mat4` takes columns where the bank stores
rows, so the -1 belongs at [2][3] -- which is where `mobius-torus`'s own
presets keep theirs.

### Fixing the extraction rather than the entries

The faults above were symptoms; six of them were one bug each in
`tools/extract_graphs.py`, and fixing those repaired filters no audit had
flagged. Every one is checked by re-reading the app's own registration.

- **A graph parsed before the graph it stands on was never re-parsed.** The
  extractor loops until nothing new resolves, so a later pass sees operators
  the earlier ones did not -- but it only ever *added* names, so the short
  first parse stuck. `glass-marble` was its outermost `adjust` alone,
  `schema4-preset` had lost both of the graphs it blends, `reverie` most of
  its chain. Now the fuller parse wins.
- **A lambda that does not name itself was thrown away.** `gaussian-blur2` is
  registered as `q7.u("gaussian-blur2", C2.f("(lambda ((type #<image>) ...)"))`
  with no `(name ...)` inside it, and `parse_lambda` required one. Losing the
  operator lost every graph that stands on it.
- **A knob with a default was baked in as that number.** The defaults were
  consulted before the bindings, so a declared knob that had one was wired to
  the literal instead of the control -- `disco-planet` passes `:intensity
  innerIntensity` and its slider moved nothing. A default says where a control
  starts, not that the node should be nailed to it.
- **Knobs inside an expression were replaced by guesses.** `symbol_value`
  answers for any name it is asked about, 1.0 for one that reads like a scale
  and 0.0 otherwise, so `preset-focus`'s `(mat3 (vec3 locusScale 0 0) (vec3 0
  locusScale 0) (vec3 tx ty 1))` came out the identity and every canvas handle
  in that family moved nothing. A knob now keeps its place as a hole the
  renderer fills, which is what `{"bind": ...}` inside a value means.
- **A struct argument was dropped whole.** `:vignette (make-vignette
  :intensity 0.35 :hardness 0.3)` failed to evaluate and took four parameters
  with it. It is now taken apart into the names the target declares --
  `vignette_intensity` for `adjust`, `intensity` for `vignette`.
- **A filter written as an expression was stored as text.** `preset-mondrian`
  builds its palette with `(color-list-to-palette-image (make-color-list
  ...))` and `palette` is an image port; evaluated as a number it failed and
  was kept as `{"expr": ...}`. Four of those are gone, and a filter-valued
  argument now goes to the input it feeds, since a filter can only be an
  image.

A positional knob is still left alone where the operator is a shader -- the
app's argument order is its own and does not follow the GLSL signature -- but
a lambda writes its order down, so `(gaussian-blur2 source blurRadius)` now
binds `radius`, which is what `soft-focus` turns.

Between them these took the knobs that are both measurably dead and
statically unreachable from 45 across 22 filters to 10 across 7.

### What else the extraction had lost

`white-infinite` drawing nothing was not a one-off, so the same shapes were
looked for across the bank. Each of these is measured or read out of the
decompiled source rather than guessed at.

- **Defaults taken from the declaration instead of the call.** A lambda
  declares its knobs, usually inheriting them from the filter it forwards to,
  and the app then invokes it with values of its own. The extraction kept the
  declaration and dropped the call, so **71 values across 42 filters** opened
  at the wrong setting -- `triangle-op-art` at intensity 0 against the app's
  5, `star-kaleidoscope` at 0 against 1.11, `etched-circles` at thickness 0
  against 0.12. `build_bank.call_site_defaults` now reads them off the call.
- **Stages dropped from a chain.** `glass-marble` is
  `adjust(lens-blur(globe(source)))` and had been extracted as the `adjust`
  alone: a glass marble that was a brightness and contrast tweak, with the
  `intensity` and `modelTransform` it declares reaching nothing.
  `schema4-preset`, `schema4b-preset`, `reverie` and `seraphim` lost stages
  the same way. All are fixed at the root, above.
- **Parameters that are images.** `aura`, `blob` and `candyland` set a knob
  with `(mapped :value X :map (circle-gradient ...))`. The app declares those
  parameters as a union -- `<union :constant <double> :mapped <struct :value
  <double> :map <image-view>>>` -- and compiles a different shader for each
  side of it. What was recovered is the constant side: `marble` takes
  `intensity` as a plain uniform and samples one image, its source. Carrying
  the mapped side needs the shaders the app generates for it, which are not
  in what was extracted, so this one is blocked rather than pending.
- **Shaders shadowed by a reimplementation.** Three remain. `pointer`'s
  extracted entry names a different function with unrelated parameters, so its
  passthrough verdict is right. `square-mosaic` and `wormhole` were recovered
  incomplete -- the first is a bare block with no enclosing function, the
  second has a `float a = ` with nothing after it -- and their CPU versions
  are the only thing to ship.
- **Knobs that reach no node.** 45 across 22 filters were both measurably dead
  and statically unreachable. The extractor fixes above took that to 10 across
  7, listed by `examples/deadknobs.rs`. Not all are faults -- a knob can be
  inert at the defaults, which is why the list is measured and read rather
  than acted on wholesale.
- **Filters the app builds from other filters.** Thirteen more are still CPU
  reimplementations of lambdas: `bloom-simple`, `saint-remy`, `photo-label`,
  `flashback`, `pastel`, `knife-painting` and the rest. Most need value
  constructors (`rgba`, `make-vignette`, `mat3-scale-uniform`) or `let`
  bindings that the graph format does not carry yet.

### Where a shader's time goes

Not in the shader, for almost all of them. A typical filter renders 900x900 in
about 1.4 ms, and the same filter renders 256x256 -- a twelfth of the pixels --
in about 0.7 ms, so half of it is fixed: building the pass, and reading 3.2 MB
back off the device. `emboss`, `checkerboard`, `mandelbrot`, `lake-mirror` and
`label-frame` land within a few tenths of each other despite having very
little in common, which is what a floor looks like.

Two candidate savings were tried against that and neither moved:

- `find-max-xy-gl` converts the best colour so far to HSL on every comparison,
  four times a turn over fifty turns, when it changes only on the turns that
  replace it. Carrying it instead removes a hundred colour-space conversions
  per pixel. The output was byte-identical and the time was 1.59 ms against
  1.58 ms -- the driver's compiler already handles that shape.
- Six shaders (`height-map`, `mesh` and their variants) write `dzdy =` where
  the line above writes `dzdx +=`, so every turn of that loop but the last is
  sampled and thrown away -- up to ten wasted texture reads a pixel at the top
  of `normalSmoothing`. Rendering at both ends of that parameter differs by
  0.04 ms at 900x900, and again at 2048x2048 where the shader is thoroughly
  the cost.

The filters that are genuinely shader-bound are ray marchers -- `quicksilver-3d`
at 12.8 ms and `height-map` at 11.2 ms, both scaling cleanly with pixels -- and
what they spend it on is the marching loop, which is the algorithm rather than
waste. The shaders are left as the app wrote them; the slow end was the CPU
filters and the chains, which is where the section above went.

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
uniform control flow, and 168 of the app's shaders sample inside a conditional
or a loop. Native wgpu accepts them; a browser rejects the whole module, and
the filter draws nothing.

Those filters get a second source that takes the mip level explicitly, and the
build embeds one set or the other by target -- so neither build carries both
and native keeps its mip filtering. Two more take a gradient inside a
conditional; for those the declarations that feed it are lifted out of the
branch, which computes the same value.

The list is measured, not guessed: `Filters.compile_check()` builds every
pipeline and reports what the browser refused, and its output is
`tools/webgpu_uniformity.json`. 464 of 465 shaders compile in Chrome today.
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
cargo run --release --example timeone -- height-map 900 30
```

`sweep` renders every filter from a raw RGBA8 file and reports what failed,
which is how the fidelity numbers were measured; `hop_cost` is where the
speed figures come from. `slowest` times every filter at the size the editor
previews at and lists the worst, which is what a report of lag gets checked
against: 769 filters, 2.3 ms median, and none of them over 250 ms. It builds each pipeline before timing anything
-- a filter's shader is compiled the first time it is used, which costs
several times what running it does -- and takes the best of five runs, because
one run in a sweep of 769 catches whatever the driver was doing for the filter
before it. `timeone` times a single filter the same way in isolation, which is
the number to trust when a sweep and a hunch disagree.

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
