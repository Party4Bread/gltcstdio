// The shapes the wasm module hands over, and the shapes the editor keeps.
//
// Everything here mirrors what `described()` in `gltcstdio-wasm` emits and
// what `render_graph` accepts, so a change on the Rust side shows up as a type
// error here rather than as a filter that quietly renders nothing.
export function isFilterGraph(node) {
    return !!node && typeof node === 'object' && 'filter' in node;
}
export function isBind(value) {
    return !!value && typeof value === 'object' && !Array.isArray(value) && 'bind' in value;
}
//# sourceMappingURL=types.js.map