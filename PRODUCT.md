# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Someone who wants to make images. They open gltcstdio, load a picture, and
stack filters until they like what they see. They do not care where the
filters came from, and nothing should require them to.

They are running it inside an authorized environment, so every user has access
to an internal deployment or the repository on their own machine. That makes
them technical enough to start a static server, which is not the same as
wanting to read implementation notes before their first image.

Two secondary audiences exist and neither sets the direction: developers
calling the Python package or the Rust crate, and the author maintaining the
filter-bank build.

## Product Purpose

**gltcstdio** is a node editor for building filter chains, with 769 filters
behind it. It is the product; the Python package and the Rust crate are how it
is built.

You drop filters into a graph, wire them together, and see the result as you
go. Every node carries a thumbnail of the chain up to that point, so a long
chain shows where the look came from rather than only where it arrived.

Success is completeness and being nice to use: every filter, parameter and
preset present and working, in an editor that is a pleasure to build chains in.
Fidelity to the filter specification and rendering speed are already achieved and are
treated as constraints to hold, not as the scoreboard.

## Positioning

The bank contains 465 GLSL filters translated to WGSL, 65 graphs the app
builds around those filters, 174 curated looks, and 61 CPU effects. Opening a graph-based
look in the editor gives back its actual stages, editable, rendering
byte-identically to the look itself.

The whole bank runs in the page. One wasm module carries the bank, every
shader, the CPU filters and the font, and renders through WebGPU with no
server behind it.

## Operating Context

- Started with `./editor/build.sh` then a static server over `editor/`;
  opened in a browser at that address.
- Needs WebGPU: Chrome/Edge 113+, Safari 18+, or Firefox with
  `dom.webgpu.enabled`. Without a device the page says so rather than showing
  a blank frame.
- The user brings their own images. A chain can read more than one, and the
  second picture enters the graph as a node with its own output.
- Work is not saved anywhere. Reloading loses the chain; the result leaves as
  a downloaded PNG.

## Capabilities and Constraints

- 769 filters: 463 GPU (GLSL translated to WGSL), 65 wrappers around those
  (21 feeding an input from a blurred source, 44 confining the effect to a
  region), 174 curated looks (chains of other filters), 61 CPU, and four
  lambdas the app builds from its own filters. 33
  categories, 1399 presets, 5272 parameters, 120 filters that read a second
  image.
- Every parameter type has a control, generated from the bank spec rather
  than written per filter: scalars, enums, colours with alpha, text, palettes,
  and matrices decomposed into the scale/rotation/offset or yaw/pitch/distance
  that built them.
- A chain is sent to the engine in one call, in the same shape the bank stores
  its curated looks, so a chain built in the editor and one shipped with the
  app render by the same path.
- One shader, `flower`, is refused by every browser: it takes a gradient
  inside a conditional nested too deep to lift, which WGSL forbids. The three
  curated looks built on it — `glory`, `radiate`, `seraphim` — cannot render
  in the editor. They work natively.
- `sharpen`, `dehaze`, `metal`, `mobius-torus` and `hyperbolic-lace` are the
  app's own lambdas and shaders rather than CPU reimplementations of them,
  which is both more faithful and between 20 and 75 times quicker. No filter
  in the bank now costs more than a quarter second at the size the editor
  previews at.
- `gaussian-blur2` is the app's own graph over its `gaussian-blurv` and
  `gaussian-blurh` shaders, not a reimplementation of it. Getting there meant
  binding `u_SourceTransform` -- which those two and `blur` read, and both
  renderers left as the identity matrix -- to the map back to texture space;
  until then they translated the image rather than sampling it. A render of
  the whole bank went from 47.0 s to 11.3 s.
- Rendered stages are cached as well as uploaded images, keyed by the filter,
  the content of its inputs and its settings, so a chain renders each stage
  once however many times it is asked for. The editor's own unit of work --
  the preview plus a thumbnail per node -- is about nine times quicker for it.
- The same bank also runs through a Python package (moderngl/EGL) and a Rust
  crate with PyO3 bindings. Those are how the editor is built, not competing
  products.

## Brand Commitments

The product is **gltcstdio**, set lowercase exactly so — a compression of
"glitch studio" that is never spelled out or capitalised in the interface.

The interface and documentation use the gltcstdio identity consistently.
Legacy project names do not appear in product-facing text, defaults, generated
assets, or metadata.

## Evidence on Hand

- `README.md` and `rust/README.md`: what is in the bank, how it is built, and
  measured verification and fidelity.
- `tools/verify.py`: every filter renders, keeps its shape and dtype, stays
  finite, is deterministic, survives a different image size, and responds to
  its parameters — 769/769 on all but the last, which is 767/769 because two
  filters declare nothing to set.
- `rust/crates/gltcstdio/tests/`: 18 tests, including that a curated look
  opened as a chain renders as the look itself, and that the upload cache
  changes no pixel.
- No user research, testimonials, usage data, or comparative benchmarks exist.
  Future work must not invent them.

## Product Principles

1. **The picture is the subject.** Everything else — the graph, the controls,
   the filter list — exists to get a change onto the image and show it.
2. **Nothing hidden outside the graph.** If it affects the render, it is a
   node or a control on a node. A second image is a node, not a setting beside
   the canvas.
3. **Completeness is not optional.** Every filter, parameter and preset is
   reachable and works. A filter that cannot render says why in words its user
   can act on, with the driver's own message still reachable.
4. **Implementation detail is available, never required.** Which backend and
   how faithful a filter is are findable in the developer docs and absent from
   the surface of someone who just wants to make an image.
5. **Hold what has been earned.** Byte-identical looks, measured fidelity, and
   interactive render times are constraints on future work, not achievements
   to trade away for appearance.
