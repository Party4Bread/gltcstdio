// The shapes the wasm module hands over, and the shapes the editor keeps.
//
// Everything here mirrors what `described()` in `gltcstdio-wasm` emits and
// what `render_graph` accepts, so a change on the Rust side shows up as a type
// error here rather than as a filter that quietly renders nothing.

/** A parameter value: a scalar, a string, a vector, a matrix or a palette. */
export type Value = number | string | number[] | number[][] | null;

/** One entry of an enum parameter. */
export interface Choice {
  value: number;
  label: string;
}

/** A fixed-length uniform array: a palette, a shape table, a sphere list. */
export interface ArraySpec {
  elem: string;
  length: number;
}

export interface ParamSpec {
  name: string;
  type: string;
  label: string;
  widget: string | null;
  min: number | null;
  max: number | null;
  step: number | null;
  default: Value;
  /** Applied by the engine around every filter rather than by the filter. */
  engine: boolean;
  array: ArraySpec | null;
  choices: Choice[];
}

export interface PresetSpec {
  name: string;
  params: Record<string, Value>;
}

export type Backend = 'gpu' | 'cpu' | 'graph';
export type Fidelity = 'extracted' | 'recovered' | 'reimplemented';

export interface FilterSpec {
  id: string;
  name: string;
  category: string;
  backend: Backend;
  fidelity: Fidelity;
  /** Named image inputs beyond the one flowing through the chain. */
  extraInputs: string[];
  /** Every image input, the one flowing through the chain first. */
  ports: string[];
  /** Set when this filter is the app's blur wrapper around another shader.
   *  It is a graph, but it is one filter rather than a look to take apart. */
  wrapped: string | null;
  /** Parameters the engine computes from others, so they take no control. */
  derived: string[];
  params: ParamSpec[];
  presets: PresetSpec[];
}

/* ------------------------------------------------------------ engine graph */

/** The image the caller passed in. */
export interface InputRef {
  input: string;
}

/** One of the enclosing graph's own parameters, forwarded by name. */
export interface BindRef {
  bind: string;
}

/** A filter and what feeds it -- the shape `render_graph` takes. */
export interface FilterGraph {
  filter: string;
  inputs?: Record<string, GraphNode>;
  params?: Record<string, Value | BindRef>;
  /** A locus wrapper blends the filter it wraps and forwards its knobs. */
  forward?: boolean;
}

export type GraphNode = FilterGraph | InputRef | BindRef;

export function isFilterGraph(node: GraphNode | null | undefined): node is FilterGraph {
  return !!node && typeof node === 'object' && 'filter' in node;
}

export function isBind(value: Value | BindRef | undefined): value is BindRef {
  return !!value && typeof value === 'object' && !Array.isArray(value) && 'bind' in value;
}

/* -------------------------------------------------------------- the editor */

/** The two ends of the chain: the image going in and the result coming out. */
export interface EndNode {
  id: 'src' | 'out';
  kind: 'source' | 'output';
  x: number;
  y: number;
  /** Set once the user drags the result, which then stays where they put it. */
  moved?: boolean;
}

/** A second image, brought in as a node so a chain can combine two of them. */
export interface ImageNode {
  id: string;
  kind: 'image';
  x: number;
  y: number;
  bitmap: Bitmap | null;
  name: string;
}

export interface FilterNode {
  id: string;
  kind: 'filter';
  filter: string;
  x: number;
  y: number;
  values: Record<string, Value>;
  /** The preset these values came from, until one of them is moved. */
  preset?: string | null;
  /** How deep in a curated look this node sat, used to lay it out. */
  column?: number;
}

export type ChainNode = EndNode | FilterNode | ImageNode;

export interface Link {
  from: string;
  to: string;
  port: string;
}

/** An image as the module wants it: RGBA8, row major. */
export interface Bitmap {
  width: number;
  height: number;
  data: Uint8Array;
}

export interface Point {
  x: number;
  y: number;
}
