# gltcstdio

A node editor for building image filter chains, with 769 filters behind it.
Drop filters into a graph, wire them together, and watch the picture change as
you go. It runs entirely in the browser on WebGPU; the Python library and the
Rust crate underneath it are how it is built, and are usable on their own.

The filter bank combines GPU shaders, graph-based effects, and CPU filters in
one runtime. Most GPU effects run their GLSL implementations directly, with
the WebGPU build translating them to WGSL during the build.

## What is in the bank

| | count |
|---|---|
| Filters that render | **769** |
| — GPU (original GLSL, unmodified) | 465 |
| — the app's own wrappers around those | 65 |
| — the app's own lambdas over those (blur, sharpen, dehaze, metal) | 4 |
| — curated looks (chained filter graphs) | 174 |
| — CPU (numpy) | 61 |
| Categories | 33 |
| Presets on those filters | 1399 |
| Configurable parameters | 5272 |
| Filters reading a second image | 120 |
| GLSL support functions | 201 |

The app registers 763 operator names across its five registration forms.
Six -- `array`, `float-list`, `string-append`, `mapped`, `load-image`,
`load-video` -- are the DSL's value constructors and file loaders, which
produce inputs rather than transform an image. All 757 filters are
implemented.

That count was 767 until four of the names turned out not to be operators at
all. A class registers its operator on the environment and declares its
parameters on a descriptor, and decompiled they read alike:
`q7.v("outrun-sun-gl", ...)` beside `f.v("glow", <default>)`. The extraction
took `glow`, `mode`, `phase2` and `style` for filters of their own, each an
exact copy of the filter that declares it, minus its presets. A derived name
that is already a parameter of the shader it would duplicate is now dropped.

## Verification

`tools/verify.py` checks every filter for more than "it returned":

| property | result |
|---|---|
| renders | 769 / 769 |
| correct shape and uint8 output | 769 / 769 |
| finite values, no NaN | 769 / 769 |
| deterministic across runs | 769 / 769 |
| works at a different image size | 769 / 769 |
| presets differ from one another | 768 / 769 |
| responds to its parameters or inputs | **767 / 769** |

It also reports how many change the synthetic gradient it uses -- 715 of 769
-- which reads worse than it is, and the next two paragraphs are why.

On a photograph, two filters return a single colour at their own defaults and
both are right to. `flat` is a solid-fill generator whose shader is
`return color`. `monkelbrot-orbits` is registered with four presets and no
default expression: its iteration `z = ((zt - 1)² - 1)²` escapes on the first
step across the whole default domain, and the app only ever shows it through a
preset — all four render (12k–47k distinct colours).

On the synthetic gradient `verify.py` uses, five come out flat and each responds
to a parameter; those are the ones whose output follows image content, such as
the pixel-stepping traces (`oscilloscope-gl`, `modulation`) that have nothing
to trace in a smooth ramp. A further 54 return the input unchanged at defaults
because their defaults are neutral (`adjust` with no adjustment); they all
respond once a parameter moves.

Every filter that has something to set responds to it. The two that do not
appear above — `sharpen`, `simple-generator` —
declare no parameters and read no second image, in the app as much as here:
their shader signatures carry nothing but the two implicit position
arguments, or they are a wrapper the app exposes at fixed settings. The
engine's view transform still pans and zooms them, which is all the app can
vary on them either.

Getting there meant fixing the curated looks in particular: 42 of them had
knobs that reached nothing, or no knobs at all.

Everything that renders also compiles: all 463 GPU filters build from their
extracted GLSL, and 0 fail.

### Filters the app wraps

Sixty-five operators are not a second name for a shader but a graph around
one, in two kinds.

**Twenty-one are a blur wrapper.** `HeightMap` registers `height-map-raw` for
the shader and `height-map` for `AbstractC1963b.R(...)`, which feeds the
shader's elevation input from `gaussian-blur2(source, radius=smoothen)` and
exposes that radius. `gaussian-blur2` at radius 0 returns its input untouched,
which is what makes this exact rather than approximate: each of the 21 is
bit-identical to its raw shader with the control at 0.

**Forty-four are a locus blend.** `LocusKt.b` confines the effect to a region
-- `locusBlend(source, effect = <shader>(source, …))` -- and adds `locusMode`
and `locusTransform`. Read as a plain alias, the blend and its controls were
lost and the entry was the shader again under a second name. A blend also pins
values onto the shader it wraps, and a pin belongs to whichever filter declares
it: `locusMode` to the blend, `mode` and `style` to the shader. Put on the
wrong node it is dropped, which is how `block-corrupt-3` came to render as
mode 1 when the app pins it to 2, and how `channel-mul-gl` showed style 1
against a pinned 0.

Two of them were attached to the wrong shader entirely --
`preset-lofi-vapor-banding` wraps `ColorPickAngular` and
`preset-pixel-color-shift-pixelate` blends `PixelateWithOrderedDithering`,
neither of them the class they sit in. A derived name is now built from the
shader its registration names rather than from its enclosing class.

At the default mode a locus covers the frame, so a blend there is the effect
rather than the source -- but not bit-for-bit: the effect is rendered to a
texture and sampled, which a kaleidoscope's hard edges show (7.4% of pixels
beyond 8/255) and a smooth filter does not (0.02%). That follows the effect's
content, not the wrapper: the same wrapper shows 0.02% at one mode and 7.4% at
the next.

`tests/test_render.py::test_wrapped_filters_render_and_match_their_raw_shader`
holds each kind to what is true of it -- bit-equality for a blur wrapper with
its control at 0, and for a blend that the frame carries the effect and not the
source.

Four `LocusKt.b` operators are still the shader alone: `color-pick-angular`,
`color-pick-aliased`, `compression-1d-gl` and `displacement-1d-gl` each
register only the wrapped name, so there is no second id for the shader the
blend would name. Giving them one would mean inventing an operator the app
does not have.

One pair is still identical apart from its presets. `preset-lofi-vapor` and
`preset-lofi-vapor-banding` are the same shader re-parameterised by
`AbstractC1963b.P`, and what distinguishes them is a lambda the decompiler
shows only as `new C0301m0(29)` -- a switch over obfuscated case labels with
no readable body.

## Speed

Rendering the whole bank once at 512x512 takes about 5 s; the median filter is
0.55 ms on the GPU, 1.2 ms for a curated look and 12 ms on the CPU.

Most of that came from recovering shaders rather than tuning code. Sixteen
filters were being served by a numpy stand-in while their real shader sat
unused behind a defect in the recovery, and running the app's own GLSL instead
is both faster and closer to the app:

| | before | after |
|---|---|---|
| `infinite-spheroids` | 1787 ms | 1.9 ms |
| `metaballs3d` | 1923 ms | 3.1 ms |
| `menger-sponge` | 2622 ms | 4.7 ms |
| `fractal-solid-gl` | 1134 ms | 2.2 ms |
| `circuit` | 21 ms | 6.9 ms |

Three changes account for the rest, none of which alters what a filter draws:

- **Gaussian blur as a matrix multiply.** The separable pass walked the whole
  image once per kernel tap -- 63 of them at the default radius, 247 at 2048px
  -- which is all memory traffic. Banding the kernel into a matrix and going
  through BLAS a block of rows at a time is 16-28x faster and agrees to 1e-4,
  moving about one pixel in 50,000 by a single step of 1/255. `gaussian-blur2`
  216 ms -> 9.8 ms, `lens-blurh` 178 ms -> 16 ms, and every graph built on them.
- **Circle mosaic within the bounding box.** It built a full-image distance
  field per candidate circle; the disc only ever covers its own bounding box,
  so restricting the test there is bit-identical and 42x faster (2131 ms ->
  50 ms).
- **Reusing GL objects.** A framebuffer, a vertex array and the input textures
  were allocated and freed on every render. Keeping them per size halves the
  median GPU filter, 0.99 ms -> 0.55 ms.

The Rust renderer went the same way one step further: it keeps uploaded images
by content, so the mip chain -- 72-83% of a render, and built on the CPU to
match what GL derives -- is paid for once rather than per render. At
1024x1024 a filter whose input is already there is 1.5 ms instead of 12.0, and
a chain of eight 14.7 ms instead of 100.8. See `rust/README.md`.

## Rust, and the web

`rust/` is the same bank as a Cargo workspace: the app's shaders translated to
WGSL and run through `wgpu`, so they work natively on Vulkan, Metal and DX12
and in a browser on WebGPU. All 773 filters render there, with Python bindings
of their own and a wasm module for the web. See `rust/README.md`.

```bash
uv run python tools/export_rust.py     # rewrap the GLSL for WebGPU
cd rust && cargo run -p xtask --release   # translate it with naga
cargo test --release
```

## Install

```bash
uv venv
uv pip install -e ".[dev]"
```

Requires a GPU or a software GL stack reachable through EGL. Verify with:

```bash
uv run python -c "from gltcstdio.backends.gl import Renderer; Renderer(); print('GL ok')"
```

## Use

```python
from gltcstdio import apply, list_filters, get_filter

apply("halftone", "photo.jpg", style=1, intensity=0.8).save("out.png")
apply("halftone", "photo.jpg", preset="hex dots colored").save("out.png")

for f in list_filters(category="glitch"):
    print(f.id, f.name)

spec = get_filter("halftone")
for p in spec.params:
    print(p.name, p.type, p.default, (p.min, p.max), p.choices)
```

Some filters read more than one image; `extra_inputs` names them and anything
you leave out falls back to the primary image:

```python
spec = get_filter("checkerboard-combine")
spec.extra_inputs                      # ('source2',)
apply("checkerboard-combine", photo, inputs={"source2": other})
```

166 filters are curated looks rather than shaders: small graphs that chain
several filters. The app registers them five different ways -- node trees in
Java, single-node wrappers, DSL expressions, graphs held in locals, and whole
definitions written in the app's own Lisp-like language -- and `chain` names
what each one runs:

```python
get_filter("preset-cameleon").chain
# ('blend-with-mask', 'hue-offset-distorted-gl', 'streaking')
```

`apply` accepts a path, a PIL image or a numpy array, and returns a PIL image.
Values are coerced and clamped to each parameter's extracted range; colours
also accept `"#ff8800"`. An unknown parameter name raises rather than being
ignored.

## The editor

gltcstdio runs entirely in the browser: the bank, every shader and the CPU
filters are compiled into one wasm module that renders through WebGPU, so
there is no server behind it.

```bash
./editor/build.sh                   # editor/pkg from the Rust crate, then editor/dist
python -m http.server -d editor 8000
```

The page is TypeScript: `build.sh` runs `wasm-bindgen` (which emits the
module's `.d.ts`) and then `tsc`, so the boundary between the page and the
filter bank is type-checked — a renamed field on the Rust side fails the build
rather than showing up as a filter that renders nothing. While working on the
page alone, `pnpm --dir demo run watch` recompiles on save and
`pnpm --dir demo run check` type-checks without emitting.

Then open http://127.0.0.1:8000 — upload an image, browse filters by category,
and adjust controls generated from each filter's extracted parameter spec.

It needs WebGPU, and there are two ways not to have it. A browser without the
API has no `navigator.gpu`; a browser that has it can still refuse a device,
which is the common one on Linux and reads as "no adapters". Those want
different fixes, so the page names which it hit, lists what to try, and prints
what the driver said underneath.

### A static build

```bash
./editor/build.sh && ./editor/pages.sh      # -> dist/
python -m http.server -d dist 8001
```

`dist/` is the whole site: page, styles, compiled script and the wasm module,
about 11 MB. Every path in it is relative, so it works at a domain root and at
a project subpath alike, and it carries a `.nojekyll` so Jekyll leaves it
alone.

The module contains the complete shader bank and parameter metadata, so the
static build has no runtime dependency on the Python package or Rust toolchain.

### The chain editor

The page is a node editor rather than a single-filter preview. Clicking a
filter drops a node into the graph below the image, wired into whatever the
chain already produces; the preview above always shows the result at the end
of it. Each node carries a thumbnail of the chain up to and including itself,
so a long chain shows where the look came from as well as where it arrived.

- Wires are dragged between the dots: from an output to an input, or picked
  up off a filled input to be moved elsewhere. Dropping one on a node's body
  takes its first free input; dropping it on empty canvas leaves that input
  unwired.
- Removing a node heals the chain around it rather than breaking it.
- A filter reading a second image takes it from another node's output, or
  from an image node: **Add image** drops a picture into the graph with an
  output of its own, and the panel offers one for whichever port is still
  empty. The second picture is a node like everything else rather than a
  setting hidden beside the graph.
- The 175 curated looks are chains in the app too, so clicking one appends it
  as its own nodes: `etched-circles` opens as Circle Mosaic → Emboss, both
  editable, which is how the app builds a look rather than a fixed result.
- Presets load into the selected node's sliders, so one is a starting point
  rather than an end state.
- The 28 shaders that sample no image show no input at all: they draw their
  own picture, so they start a chain rather than continuing one, and the port
  they used to carry did nothing.
- Everything carries a tooltip built from what the bank knows -- where a
  filter came from, how faithful it is, what a parameter's range and default
  are, what each input takes -- rather than prose written about it. The app
  ships no descriptions, and none are invented here.
- Controls that change nothing where the chain currently stands are marked
  **no effect**, measured rather than declared: each is moved to a clearly
  different value and the render compared, and only a byte-identical result
  counts, so nothing subtle is called dead. `basic-ray-marcher` is the base of
  the ray-marching family and marches no shape, so 6 of its 11 controls have
  nothing to act on; `halftone` has none.
- A filter a browser refuses says so in a sentence, keeping the driver's own
  message on hover.

The preview renders at up to 900 pixels rather than at the image's full size.
The canvas shows a few hundred, and a chain redrawn on every slider step was
spending most of its time on detail nobody could see. That, and correcting the
blur the wrappers are built on, took `height-map-wireframe-gl` from 26.6 s to
197 ms. **Download** renders the chain again at the image's real size, so what
is saved is never the preview.

The whole graph goes to the wasm module in one call, and the engine renders it
by the same path a curated look takes, so a chain built here and a chain in
the bank are the same thing.

A look opened as nodes renders exactly what the look renders — not close, the
same bytes. All 176 graphs the bank carries were checked in a browser -- the
175 looks and the app's own blur -- giving 173 byte-identical and 3 that
no browser will render at all, being the `flower` shader WebGPU refuses. Two
things are needed for that, and neither is guessed at:

- A look's own declared defaults are delivered onto its stages when it runs,
  which for 45 of the 175 is not what the stored graph says. `graph_of` hands
  back the chain with that already resolved, by the same code the renderer
  uses, so the editor cannot drift from it. `a_resolved_look_renders_as_the_look`
  checks every look in the bank.
- An input nobody wired falls back to the node's own image, not to the
  chain's source. Binding it to the source instead is wrong the moment the
  node has anything in front of it.

Every filter in the bank is reachable and every parameter type has a control:
sliders and dropdowns for scalars and enums, colour pickers with alpha, text
entry for the text filters, and a palette editor for the fixed-length arrays.
A `mat3` decomposes into the scale, rotation and offset that built it, so a
preset's matrix loads straight back into the sliders; a `mat4` decomposes into
yaw, pitch, distance and scale, and the distance is what decides whether a ray
marcher's camera sits inside its object or outside it. Filters reading a
second image get a slot for one. The engine's view transform applies to every
filter rather than belonging to any, so it sits under its own **View**
heading, and uniforms the app computes from other parameters -- `metaballs-gl`
builds its sphere array from a count and a radius -- show those inputs rather
than the array they produce.

## Fidelity

`get_filter(id).fidelity` reports how close a filter is to the app:

- **extracted** — the app's GLSL, unmodified, and the curated looks built from
  those shaders.
- **recovered** — CPU filter whose inner kernels were readable in the
  decompiled source and are reproduced (`pixel-sort`).
- **reimplemented** — CPU filter whose parameter contract (names, ranges,
  presets) comes from the app but whose algorithm is a fresh implementation.
  Output will not match the app pixel for pixel.

The app runs its CPU filters through an obfuscated dispatch table rather than
readable per-filter methods, which is why only `pixel-sort` could be recovered
rather than reimplemented.

Sixty-six filters run on the CPU. Forty-five have no shader in the app at all;
the other twenty-one keep a numpy reimplementation only because the app builds
their GLSL at render time in a way that does not reduce to one static text:

- three -- `hyperbolic-lace`, `square-mosaic`, `wormhole` -- cannot compile in
  the app either, or vary the shader per mode from a table of code objects;
- two -- `mobius-torus`, `pointer` -- compile but return the source unchanged
  at their defaults, so the reimplementation shows more;
- the rest are curated looks whose node graph does not reproduce the effect.

Everything else that once fell in this group is now the app's own shader. The
ray marchers, the hyperbolic tilings and the orbit fractals were recovered by
running the app's own assembly: their pieces are in the APK, spread across
static fields, constructor assignments, base classes and helper-list methods
that the decompiler shows only as field reads.

Parameter metadata comes from three sources, in increasing precedence: a
shared registry, each filter's own constructor overrides, and its presets.
A filter that is a thin wrapper over another one — `preset-extrusion` over
`topography`, `contour-gl` over `contour` — has no constructor of its own, so
it takes the overrides of the filters sharing its shader entry point, and
skips any parameter those disagree about. Where no source describes a
parameter, a type-appropriate default is used and it is flagged `inferred`
(168 of 5053).

## Rebuilding the bank

The shipped bank is generated. To rebuild from the APK:

```bash
unzip reference.xapk -d work/xapk
unzip work/xapk/application.apk -d work/apk
jadx -j 8 --no-res --no-debug-info -d work/decompiled work/apk/classes.dex
uv run python tools/build_all.py
```

Some filters assemble their GLSL from pieces jadx cannot show -- literals
concatenated with String fields set in constructors it also failed to
decompile. `tools/dex_shaders.py` reads those straight out of the dex
bytecode, so the pipeline runs the shader extraction twice: once to find what
is missing, then again to fold the recovered source back in.

`tools/resolve_helpers.py` then fills the remaining gaps: a filter often calls
helpers, structs or `#define`s that live in some other class entirely, so
every GLSL function in the dex is indexed by name and the missing ones are
appended, following each addition's own calls until nothing dangles.

`build_all.py` builds the bank twice on purpose: once so the sweep has
something to run, then again to fold the sweep's verdicts back in, so
`supported` reflects what actually renders.

## Tests

```bash
uv run pytest
```

The most valuable test compiles and renders every supported filter, which
catches shader-assembly regressions across the whole bank at once.
