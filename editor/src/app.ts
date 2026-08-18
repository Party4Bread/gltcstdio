// A node editor over the filter bank.  Every filter runs in this page: the
// bank, the shaders and the CPU ports are all inside the wasm module, which
// renders through WebGPU, and a chain built here goes through the same engine
// as the app's own curated looks -- which is why one of those can be loaded
// into the editor and taken apart.
//
// Controls are generated from each filter's extracted parameter spec, so the
// UI stays correct as the bank is rebuilt; nothing here is written per filter.

import init, { Filters, catalog, graph_of } from '../pkg/gltcstdio_wasm.js';
import {
  clamp, compose3, compose4, cycle, decompose3, decompose4, fmt, fromHex,
  slider, stepOf, toHex, uniqueRuns,
} from './controls.js';
import { isBind, isFilterGraph } from './types.js';
import type {
  Bitmap, ChainNode, FilterGraph, FilterNode, FilterSpec, GraphNode, ImageNode,
  Link, ParamSpec, Point, PresetSpec, Value,
} from './types.js';

/** The chain: nodes keyed by id, plus a link per filled input port. */
const chain = {
  nodes: new Map<string, ChainNode>(),
  links: [] as Link[],
  selected: null as string | null,
  next: 1,
};

const state = {
  filters: [] as FilterSpec[],
  byId: new Map<string, FilterSpec>(),
  categories: [] as string[],
  /** Names the bank uses for more than one filter, which the list qualifies. */
  ambiguous: new Set<string>(),
  source: null as Bitmap | null,
  /** The source at preview size: what the chain is rendered from while you
   *  work. The canvas shows a few hundred pixels, so rendering a 1400px
   *  image through a CPU filter spends most of its time on detail nobody
   *  sees. Download renders the full one. */
  preview: null as Bitmap | null,
  /** Bumped whenever a new image is opened, to invalidate the thumbnails. */
  sourceId: 0,
  /** Bumped when an image node's picture changes, to redo the thumbnails. */
  sourcesId: 0,
  category: null as string | null,
  query: '',
  seq: 0,
  gpu: null as Filters | null,
  view: { x: 40, y: 30, k: 1 },
  thumbs: 0,
  /** Bumped to abandon a liveness probe whose node or values moved on. */
  probe: 0,
  /** Controls on the selected node that leave the image untouched as it
   *  currently stands, measured rather than declared. */
  inert: new Set<string>(),
  /** Which node that answer is about. Controls are rebuilt on selection
   *  before the new probe has run, and the last node's answer does not
   *  describe this one. */
  inertFor: null as string | null,
};

/** The page's own elements; every id here exists in `index.html`. */
const $ = <T extends HTMLElement = HTMLElement>(id: string): T =>
  document.getElementById(id) as T;

/* ------------------------------------------------------------ filter list */

function renderCategories(): void {
  const bar = $('categories');
  bar.innerHTML = '';
  const add = (label: string, value: string | null) => {
    const b = document.createElement('button');
    b.className = 'chip' + (state.category === value ? ' on' : '');
    b.textContent = label;
    b.onclick = () => {
      state.category = value;
      renderCategories();
      renderList();
    };
    bar.appendChild(b);
  };
  add('all', null);
  for (const c of state.categories) add(c, c);
}

function visibleFilters(): FilterSpec[] {
  const q = state.query.trim().toLowerCase();
  return state.filters.filter((f) => {
    if (state.category && f.category !== state.category) return false;
    if (!q) return true;
    return f.id.includes(q) || f.name.toLowerCase().includes(q);
  });
}

function renderList(): void {
  const ul = $('filterList');
  ul.innerHTML = '';
  const items = visibleFilters();
  if (!items.length) {
    ul.innerHTML = '<li class="empty">No filters match</li>';
    return;
  }
  const frag = document.createDocumentFragment();
  for (const f of items) {
    const li = document.createElement('li');
    li.dataset.id = f.id;
    const label = document.createElement('span');
    label.textContent = f.name;
    li.appendChild(label);
    // Thirty-four names belong to more than one filter -- `Mesh` to three of
    // them -- so those rows carry the id that tells them apart rather than
    // appearing twice over as the same thing.
    if (state.ambiguous.has(f.name)) {
      const which = document.createElement('span');
      which.className = 'qualifier';
      which.textContent = f.id;
      li.appendChild(which);
    }
    if (f.backend !== 'gpu' && !f.wrapped) {
      const b = document.createElement('span');
      b.className = 'badge';
      b.textContent = f.backend === 'graph' ? 'chain' : f.backend;
      li.appendChild(b);
    }
    const cat = document.createElement('span');
    cat.className = 'cat';
    cat.textContent = f.category;
    li.appendChild(cat);
    li.title = describeFilter(f);
    li.onclick = () => (isLook(f) ? loadChain(f) : addNode(f.id));
    frag.appendChild(li);
  }
  ul.appendChild(frag);
}

/** What a filter is, in the terms the bank actually knows.
 *
 *  The app ships no descriptions -- its parameters carry a label, a range and
 *  a default and nothing else -- so rather than invent prose about what 769
 *  filters do, this states what is on record: where the filter came from, how
 *  faithful it is, and what it is built out of. */
function describeFilter(f: FilterSpec): string {
  const bits: string[] = [f.category];
  if (f.wrapped) {
    const blend = f.params.some((p) => p.name.startsWith('locus'));
    bits.push(blend
      ? `the app's own graph around ${f.wrapped}, confining it to a region`
      : `the app's own graph around ${f.wrapped}, feeding one of its inputs `
        + 'from a blurred copy of the source');
  } else if (f.backend === 'graph') {
    bits.push(`a chain of ${chainLength(f.id)} filters, which opens as its own nodes`);
  } else if (f.backend === 'cpu') {
    bits.push('a CPU filter');
  } else {
    bits.push("the app's own shader, unmodified");
  }
  if (f.fidelity === 'reimplemented') {
    bits.push('reimplemented: the parameters are the app\'s, the algorithm is not, '
      + 'so the output will not match it pixel for pixel');
  } else if (f.fidelity === 'recovered') {
    bits.push('recovered from the decompiled source');
  }
  const extra = portsOf(f.id).slice(1);
  if (extra.length) bits.push(`also reads ${extra.join(' and ')}`);
  if (!portsOf(f.id).length) bits.push('takes no image: it draws its own picture');
  return `${f.name}  (${f.id})\n${bits.join('\n')}`;
}

/** A parameter, in the terms the bank knows: type, range, default. */
function describeParam(p: ParamSpec): string {
  const bits: string[] = [p.type];
  if (p.min !== null && p.max !== null) bits.push(`${p.min} to ${p.max}`);
  if (p.default !== null && !Array.isArray(p.default)) bits.push(`default ${p.default}`);
  if (p.engine) {
    bits.push('applied by the engine around every filter, not by the filter itself');
  }
  if (p.choices?.length) bits.push(p.choices.map((c) => c.label).join(', '));
  return `${p.label || p.name}  (${p.name})\n${bits.join('\n')}`;
}

/** What an input port takes. */
function describePort(port: string, primary: boolean): string {
  return primary
    ? `${port}\nthe image flowing through the chain`
    : `${port}\na second image this filter reads. Leave it unwired and the `
      + 'filter falls back to the image on its main input.';
}

/** A curated look: a graph to open as its own nodes, not a single filter.
 *
 *  The blur wrappers are graphs too, but taking one apart would show the
 *  plumbing -- a blur feeding an elevation input -- and lose the control the
 *  wrapper exists to expose. They behave as ordinary filters here. */
function isLook(f: FilterSpec): boolean {
  return f.backend === 'graph' && !f.wrapped;
}

function chainLength(id: string): number {
  const raw = graph_of(id);
  if (!raw) return 1;
  let n = 0;
  const walk = (node: GraphNode | undefined): void => {
    if (!isFilterGraph(node)) return;
    n += 1;
    for (const child of Object.values(node.inputs ?? {})) walk(child);
  };
  walk(JSON.parse(raw) as GraphNode);
  return n;
}

/* --------------------------------------------------------------- the chain */

/** A filter's image inputs, the one flowing through the chain first. */
function portsOf(filterId: string): string[] {
  const spec = state.byId.get(filterId);
  // An empty list is an answer, not a missing one: 29 shaders sample no image
  // and take no input.
  if (Array.isArray(spec?.ports)) return spec.ports;
  return ['source', ...(spec?.extraInputs ?? []).filter((n) => n !== 'source')];
}

/** The port carrying the image through the chain -- `source1` for 21 filters. */
function primaryPort(filterId: string): string {
  return portsOf(filterId)[0] ?? 'source';
}

/** The ports a node shows, whichever kind of node it is. */
function portsOfNode(node: ChainNode): string[] {
  if (node.kind === 'filter') return portsOf(node.filter);
  return node.kind === 'output' ? ['source'] : [];
}

/** The image nodes in the chain, which are what a graph's named leaves read. */
function imageNodes(): ImageNode[] {
  return [...chain.nodes.values()].filter((n): n is ImageNode => n.kind === 'image');
}

/** Add an image node, optionally wired straight into a waiting input. */
function addImageNode(into?: { node: string; port: string }): string {
  const id = `img${chain.next++}`;
  const at = into ? chain.nodes.get(into.node) : undefined;
  chain.nodes.set(id, {
    id,
    kind: 'image',
    x: at ? Math.max(40, at.x - 210) : 40,
    y: at ? at.y + 170 : 250,
    bitmap: null,
    name: '',
  });
  if (into) connect(id, into.node, into.port);
  draw();
  // It lands below the node it feeds, which is often past the bottom edge.
  if (!inView(id)) {
    fit();
    applyView();
  }
  renderControls();
  pickImageFor(id);
  return id;
}

/** Ask for a file for one image node; the picker is shared between them. */
let pickingFor: string | null = null;

function pickImageFor(id: string): void {
  pickingFor = id;
  $<HTMLInputElement>('imageInput').value = '';
  $<HTMLInputElement>('imageInput').click();
}

function defaults(filterId: string): Record<string, Value> {
  const spec = state.byId.get(filterId);
  const out: Record<string, Value> = {};
  for (const p of spec?.params ?? []) out[p.name] = p.default;
  return out;
}

function filterNode(id: string | null): FilterNode | null {
  if (!id) return null;
  const node = chain.nodes.get(id);
  return node && node.kind === 'filter' ? node : null;
}

function addNode(filterId: string, at?: Point): string | undefined {
  const spec = state.byId.get(filterId);
  if (!spec) return undefined;
  const id = `n${chain.next++}`;
  const place = at ?? nextFreeSpot();
  chain.nodes.set(id, {
    id,
    kind: 'filter',
    filter: filterId,
    x: place.x,
    y: place.y,
    values: defaults(filterId),
  });

  // A new node joins the end of the chain rather than floating unconnected,
  // on the port its own shader reads the chain's image from.  A filter that
  // samples no image has no such port: it draws its own picture, so it starts
  // a chain instead of continuing one.
  const ports = portsOf(filterId);
  const tail = chain.links.find((l) => l.to === 'out');
  if (ports.length) connect(tail ? tail.from : 'src', id, ports[0]);
  connect(id, 'out', 'source');

  select(id);
  draw();
  // A chain grows to the right, so a new node soon lands past the edge; the
  // view follows it rather than leaving the user to pan after every click.
  if (!inView(id) || !inView('out')) {
    fit();
    applyView();
  }
  render();
  return id;
}

/** Is the whole of this node inside the visible part of the graph? */
function inView(id: string): boolean {
  const el = $('nodes').querySelector<HTMLElement>(`.node[data-id="${id}"]`);
  if (!el) return true;
  const n = el.getBoundingClientRect();
  const g = $('graph').getBoundingClientRect();
  return n.left >= g.left && n.right <= g.right && n.top >= g.top && n.bottom <= g.bottom;
}

/** Just past the rightmost filter, and level with it so a chain runs straight. */
function nextFreeSpot(): Point {
  const filters = [...chain.nodes.values()].filter((n) => n.kind === 'filter');
  if (!filters.length) return { x: 240, y: 90 };
  const rightmost = filters.reduce((m, n) => (n.x > m.x ? n : m), filters[0]);
  return { x: rightmost.x + 210, y: rightmost.y };
}

function connect(from: string, to: string, port: string): void {
  chain.links = chain.links.filter((l) => !(l.to === to && l.port === port));
  chain.links.push({ from, to, port });
}

function disconnect(to: string, port: string): void {
  chain.links = chain.links.filter((l) => !(l.to === to && l.port === port));
}

function removeNode(id: string): void {
  const node = chain.nodes.get(id);
  if (!node) return;
  if (node.kind === 'image') {
    chain.links = chain.links.filter((l) => l.from !== id && l.to !== id);
    chain.nodes.delete(id);
    if (chain.selected === id) select(null);
    draw();
    render();
    return;
  }
  if (node.kind !== 'filter') return;
  // Heal the chain: whatever fed this node now feeds what it fed.
  const primary = primaryPort(node.filter);
  const upstream = chain.links.find((l) => l.to === id && l.port === primary);
  const downstream = chain.links.filter((l) => l.from === id);
  chain.links = chain.links.filter((l) => l.from !== id && l.to !== id);
  if (upstream) {
    for (const d of downstream) connect(upstream.from, d.to, d.port);
  }
  chain.nodes.delete(id);
  if (chain.selected === id) select(null);
  draw();
  render();
}

/** One node of the chain as the engine's shape, walking back from its inputs. */
function nodeGraph(id: string, seen: Set<string>): GraphNode {
  if (id === 'src' || seen.has(id)) return { input: 'source' };
  // An image node is a leaf under its own name, which the engine looks up
  // among the images bound for the render.
  if (chain.nodes.get(id)?.kind === 'image') return { input: id };
  const node = filterNode(id);
  if (!node) return { input: 'source' };
  seen.add(id);
  // Only the wired ports are named. The engine falls back to the node's own
  // image for an input nobody bound, which is not the same as the chain's
  // source once the node has something in front of it.
  const inputs: Record<string, GraphNode> = {};
  for (const port of portsOf(node.filter)) {
    const link = chain.links.find((l) => l.to === id && l.port === port);
    if (link) inputs[port] = nodeGraph(link.from, seen);
  }
  seen.delete(id);
  return { filter: node.filter, inputs, params: node.values };
}

/** The whole chain, or null when nothing stands between source and result. */
function toGraph(): FilterGraph | null {
  const last = chain.links.find((l) => l.to === 'out');
  if (!last || last.from === 'src') return null;
  const graph = nodeGraph(last.from, new Set());
  return isFilterGraph(graph) ? graph : null;
}

/** The chain as far as one node, which is what its thumbnail shows. */
function subGraph(id: string): FilterGraph | null {
  const graph = nodeGraph(id, new Set());
  return isFilterGraph(graph) ? graph : null;
}

/** A node's parameters as plain values; a resolved look has nothing else. */
function literals(params: FilterGraph['params']): Record<string, Value> {
  const out: Record<string, Value> = {};
  for (const [k, v] of Object.entries(params ?? {})) {
    if (!isBind(v)) out[k] = v;
  }
  return out;
}

/** Load one of the app's own chains into the editor, at the end of this one. */
function loadChain(spec: FilterSpec): void {
  const raw = graph_of(spec.id);
  if (!raw) {
    addNode(spec.id);
    return;
  }

  // A look joins the chain the same way a single filter does, so loading one
  // adds to what is already built rather than throwing it away.
  const tail = chain.links.find((l) => l.to === 'out');
  const feed = tail ? tail.from : 'src';

  // The engine resolved the look's parameters, so a node opens set to what
  // that stage of the look actually renders with.
  const parsed = JSON.parse(raw) as GraphNode;

  const added: string[] = [];
  let depth = 0;
  const place = (node: GraphNode | undefined, column: number): string => {
    if (!isFilterGraph(node)) return feed;     // a leaf reads the chain so far
    const id = `n${chain.next++}`;
    depth = Math.max(depth, column);
    chain.nodes.set(id, {
      id,
      kind: 'filter',
      filter: node.filter,
      x: 0,
      y: 0,
      column,
      values: { ...defaults(node.filter), ...literals(node.params) },
    });
    added.push(id);
    for (const [port, child] of Object.entries(node.inputs ?? {})) {
      connect(place(child, column + 1), id, port);
    }
    return id;
  };
  const root = place(parsed, 0);
  connect(root, 'out', 'source');

  // Columns run left to right, starting past whatever is laid out already,
  // and siblings within a column stack.
  const x0 = [...chain.nodes.values()]
    .filter((n) => n.kind === 'filter' && !added.includes(n.id))
    .reduce((m, n) => Math.max(m, n.x + 210), 240);
  const rows = new Map<number, number>();
  for (const id of added) {
    const node = filterNode(id);
    if (!node) continue;
    const col = depth - (node.column ?? 0);
    const row = rows.get(col) ?? 0;
    rows.set(col, row + 1);
    node.x = x0 + col * 210;
    node.y = 40 + row * 150;
  }
  select(root);
  draw();
  if (added.some((id) => !inView(id)) || !inView('out')) {
    fit();
    applyView();
  }
  render();
}

/* ------------------------------------------------------------ node drawing */

function draw(): void {
  const host = $('nodes');
  const wires = $('wires');
  host.innerHTML = '';
  wires.innerHTML = '';

  const { x, y, k } = state.view;
  const transform = `translate(${x}px, ${y}px) scale(${k})`;
  host.style.transform = transform;
  wires.style.transform = transform;

  ensureEnds();
  for (const node of chain.nodes.values()) host.appendChild(nodeEl(node));
  drawWires();

  const filters = [...chain.nodes.values()].filter((n) => n.kind === 'filter');
  $('graphHint').textContent = filters.length
    ? `${filters.length} filter${filters.length > 1 ? 's' : ''} in the chain`
    : 'Add a filter to start the chain';
}

/** The source and result nodes always exist; they are the chain's ends. */
function ensureEnds(): void {
  if (!chain.nodes.has('src')) {
    chain.nodes.set('src', { id: 'src', kind: 'source', x: 40, y: 90 });
  }
  if (!chain.nodes.has('out')) {
    chain.nodes.set('out', { id: 'out', kind: 'output', x: 40, y: 250 });
    // An empty chain passes the source through, so say so with a wire rather
    // than leaving the result showing a picture nothing appears to feed.
    if (!chain.links.some((l) => l.to === 'out')) connect('src', 'out', 'source');
  }
  // Keep the result to the right of everything else, level with whatever
  // feeds it, so the last wire runs straight rather than doubling back.
  const out = chain.nodes.get('out');
  if (!out || out.kind !== 'output' || out.moved) return;
  const last = chain.links.find((l) => l.to === 'out');
  const feeder = last ? chain.nodes.get(last.from) : undefined;
  const rightmost = [...chain.nodes.values()]
    .filter((n) => n.kind === 'filter')
    .reduce((m, n) => Math.max(m, n.x), 40);
  out.x = rightmost + 210;
  out.y = feeder ? feeder.y : 90;
}

function nodeEl(node: ChainNode): HTMLElement {
  const el = document.createElement('div');
  el.className = 'node' + (chain.selected === node.id ? ' on' : '')
    + (node.kind === 'filter' ? '' : ' ends');
  el.style.left = `${node.x}px`;
  el.style.top = `${node.y}px`;
  el.dataset.id = node.id;

  const head = document.createElement('header');
  const title = document.createElement('span');
  const spec = node.kind === 'filter' ? state.byId.get(node.filter) : undefined;
  title.textContent = node.kind === 'source' ? 'Source image'
    : node.kind === 'output' ? 'Result'
    : node.kind === 'image' ? (node.name || 'Image')
    : spec?.name ?? (node as FilterNode).filter;
  title.title = spec ? describeFilter(spec)
    : node.kind === 'image' ? (node.name || 'no image loaded')
    : '';
  head.appendChild(title);

  if (node.kind === 'image') {
    const kill = document.createElement('button');
    kill.className = 'remove';
    kill.textContent = '×';
    kill.title = 'Remove this image';
    kill.onclick = (e) => {
      e.stopPropagation();
      removeNode(node.id);
    };
    head.appendChild(kill);
  }

  if (node.kind === 'filter') {
    const kind = document.createElement('span');
    kind.className = 'kind';
    // A wrapper is a graph, but it reads as one filter everywhere else here.
    // Show what runs inside it rather than the shape it is built from.
    const inner = spec?.wrapped ? state.byId.get(spec.wrapped) : undefined;
    kind.textContent = (inner ?? spec)?.backend ?? '';
    head.appendChild(kind);
    const kill = document.createElement('button');
    kill.className = 'remove';
    kill.textContent = '×';
    kill.title = 'Remove from the chain';
    kill.onclick = (e) => {
      e.stopPropagation();
      removeNode(node.id);
    };
    head.appendChild(kill);
  }
  el.appendChild(head);

  if (node.kind !== 'source') {
    const img = document.createElement('canvas');
    img.className = 'thumb';
    img.dataset.thumb = node.id;
    if (node.kind === 'image') {
      img.classList.add('pick');
      img.title = 'Choose a different image';
      img.onclick = (e) => {
        e.stopPropagation();
        pickImageFor(node.id);
      };
    }
    el.appendChild(img);
  }

  const ports = document.createElement('div');
  ports.className = 'ports';
  for (const port of portsOfNode(node)) ports.appendChild(portEl(node, port, 'in'));
  if (node.kind !== 'output') ports.appendChild(portEl(node, 'out', 'out'));
  el.appendChild(ports);

  el.onpointerdown = (e) => startDragNode(e, node, el);
  el.onclick = () => {
    if (node.kind === 'filter') select(node.id);
  };
  return el;
}

type Dir = 'in' | 'out';

function portEl(node: ChainNode, port: string, dir: Dir): HTMLElement {
  const row = document.createElement('div');
  row.className = `port ${dir}`;
  const dot = document.createElement('span');
  dot.className = 'dot';
  dot.dataset.node = node.id;
  dot.dataset.port = port;
  dot.dataset.dir = dir;
  const filled = dir === 'in'
    ? chain.links.some((l) => l.to === node.id && l.port === port)
    : chain.links.some((l) => l.from === node.id);
  if (filled) dot.classList.add('filled');
  const name = document.createElement('span');
  name.textContent = dir === 'out' ? 'out' : port;
  row.title = dir === 'out'
    ? (node.kind === 'source'
        ? 'out\nthe image you opened, as the chain receives it'
        : node.kind === 'image'
        ? 'out\nthis picture, for any input you wire it to'
        : 'out\nwhat this node produces; drag to another node to pass it on')
    : node.kind === 'output'
    ? 'source\nwhat the chain ends on -- this is what the preview shows and '
      + 'what Download saves'
    : describePort(port, node.kind === 'filter' && port === portsOf(node.filter)[0]);
  row.appendChild(dot);
  row.appendChild(name);
  dot.onpointerdown = (e) => startWire(e, node.id, port, dir);
  return row;
}

/** Port anchors are read from the laid-out DOM, so the wires always meet. */
function anchor(nodeId: string, port: string, dir: Dir): Point {
  const dot = $('nodes').querySelector<HTMLElement>(
    `.dot[data-node="${nodeId}"][data-port="${port}"][data-dir="${dir}"]`);
  const node = chain.nodes.get(nodeId);
  if (!dot || !node) return { x: 0, y: 0 };
  // Offsets are each relative to their own positioned ancestor, so they are
  // summed up the chain until the node itself, whose position we already know.
  const root = dot.closest('.node');
  let x = 0;
  let y = 0;
  for (let el: HTMLElement | null = dot; el && el !== root; el = el.offsetParent as HTMLElement | null) {
    x += el.offsetLeft;
    y += el.offsetTop;
  }
  return {
    x: node.x + x + dot.offsetWidth / 2,
    y: node.y + y + dot.offsetHeight / 2,
  };
}

function wirePath(a: Point, b: Point): string {
  const dx = Math.max(40, Math.abs(b.x - a.x) * 0.5);
  return `M ${a.x} ${a.y} C ${a.x + dx} ${a.y}, ${b.x - dx} ${b.y}, ${b.x} ${b.y}`;
}

function drawWires(live?: { a: Point; b: Point }): void {
  const svg = $('wires');
  svg.innerHTML = '';
  const add = (a: Point, b: Point, cls?: string) => {
    const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
    path.setAttribute('d', wirePath(a, b));
    if (cls) path.setAttribute('class', cls);
    svg.appendChild(path);
  };
  for (const link of chain.links) {
    add(anchor(link.from, 'out', 'out'), anchor(link.to, link.port, 'in'));
  }
  if (live) add(live.a, live.b, 'live');
}

/* -------------------------------------------------------------- dragging */

function graphPoint(e: { clientX: number; clientY: number }): Point {
  const box = $('graph').getBoundingClientRect();
  return {
    x: (e.clientX - box.left - state.view.x) / state.view.k,
    y: (e.clientY - box.top - state.view.y) / state.view.k,
  };
}

function startDragNode(e: PointerEvent, node: ChainNode, el: HTMLElement): void {
  const target = e.target as HTMLElement;
  if (target.classList.contains('dot') || target.classList.contains('remove')) return;
  e.stopPropagation();
  const start = graphPoint(e);
  const from = { x: node.x, y: node.y };
  el.classList.add('dragging');
  el.setPointerCapture(e.pointerId);

  const move = (ev: PointerEvent) => {
    const at = graphPoint(ev);
    node.x = from.x + (at.x - start.x);
    node.y = from.y + (at.y - start.y);
    if (node.kind === 'output') node.moved = true;
    el.style.left = `${node.x}px`;
    el.style.top = `${node.y}px`;
    drawWires();
  };
  const up = () => {
    el.classList.remove('dragging');
    el.removeEventListener('pointermove', move);
    el.removeEventListener('pointerup', up);
  };
  el.addEventListener('pointermove', move);
  el.addEventListener('pointerup', up);
}

/** A node's first unwired input, or its first input if all of them are wired. */
function freeInput(nodeId: string): string | null {
  const node = chain.nodes.get(nodeId);
  if (!node) return null;
  const ports = portsOfNode(node);
  const taken = new Set(chain.links.filter((l) => l.to === nodeId).map((l) => l.port));
  return ports.find((p) => !taken.has(p)) ?? ports[0] ?? null;
}

function startWire(e: PointerEvent, nodeId: string, port: string, dir: Dir): void {
  e.stopPropagation();
  e.preventDefault();
  // Dragging from a filled input picks the wire up rather than starting a
  // second one, which is how a connection is moved or removed.
  let origin = { node: nodeId, port, dir };
  let sink: { node: string; port: string } | null = null;
  if (dir === 'in') {
    const existing = chain.links.find((l) => l.to === nodeId && l.port === port);
    disconnect(nodeId, port);
    if (existing) {
      origin = { node: existing.from, port: 'out', dir: 'out' };
      sink = { node: nodeId, port };
    }
    drawWires();
  }

  const a = anchor(origin.node, origin.port, origin.dir);
  const move = (ev: PointerEvent) => drawWires({ a, b: graphPoint(ev) });
  const up = (ev: PointerEvent) => {
    window.removeEventListener('pointermove', move);
    window.removeEventListener('pointerup', up);
    const target = document.elementFromPoint(ev.clientX, ev.clientY) as HTMLElement | null;
    const dot = target?.classList.contains('dot') ? target : null;
    const onNode = target?.closest<HTMLElement>('.node') ?? null;
    const to = dot?.dataset.node;
    const toPort = dot?.dataset.port;
    if (dot && to && toPort && dot.dataset.dir === 'in' && to !== origin.node) {
      connect(origin.node, to, toPort);
    } else if (dot && to && sink && dot.dataset.dir === 'out' && to !== sink.node) {
      // A wire lifted off an input is re-sourced by dropping it on an output.
      connect(to, sink.node, sink.port);
    } else if (onNode?.dataset.id && onNode.dataset.id !== origin.node) {
      // Dropped on the body of a node: take its first port that is free, so
      // the common case needs no aim.
      const free = freeInput(onNode.dataset.id);
      if (free) connect(origin.node, onNode.dataset.id, free);
    }
    draw();
    render();
  };
  window.addEventListener('pointermove', move);
  window.addEventListener('pointerup', up);
}

function fit(): void {
  const nodes = [...chain.nodes.values()];
  if (!nodes.length) return;
  const box = $('graph').getBoundingClientRect();
  const x0 = Math.min(...nodes.map((n) => n.x)) - 30;
  const y0 = Math.min(...nodes.map((n) => n.y)) - 20;
  const x1 = Math.max(...nodes.map((n) => n.x)) + 210;
  const y1 = Math.max(...nodes.map((n) => n.y)) + 230;
  const k = clamp(Math.min(box.width / (x1 - x0), box.height / (y1 - y0)), 0.3, 1.1);
  state.view = { k, x: -x0 * k + 12, y: -y0 * k + 12 };
}

/* -------------------------------------------------------------- controls */

function select(id: string | null): void {
  chain.selected = id;
  for (const el of $('nodes').children) {
    el.classList.toggle('on', (el as HTMLElement).dataset.id === id);
  }
  renderControls();
}

function selectedNode(): FilterNode | null {
  return filterNode(chain.selected);
}

function renderControls(): void {
  const node = selectedNode();
  const f = node ? state.byId.get(node.filter) : undefined;
  $('filterName').textContent = f ? f.name : 'No node selected';
  $('filterName').title = f ? describeFilter(f) : '';
  $('resetBtn').hidden = !f;

  if (!f || !node) {
    $('filterMeta').textContent = 'Add a filter, or pick a node to adjust it.';
    $('presets').innerHTML = '';
    $('params').innerHTML = '';
    $('secondSlot').hidden = true;
    return;
  }

  const bits = [f.category,
    f.backend === 'cpu' ? 'CPU' : isLook(f) ? 'chain' : 'GPU'];
  if (f.fidelity && f.fidelity !== 'extracted') bits.push(f.fidelity);
  $('filterMeta').textContent = bits.join(' · ');

  // A filter reading more than one image says which ports are still empty,
  // and offers an image node for the first of them; the picture then sits in
  // the graph like everything else rather than in a slot beside it.
  const extra = portsOf(f.id).slice(1);
  const slot = $('secondSlot');
  const free = extra.filter((port) => !chain.links.some((l) => l.to === node.id && l.port === port));
  slot.hidden = extra.length === 0;
  if (extra.length) {
    $('secondNote').textContent = free.length
      ? `Also reads ${extra.join(', ')} — ${free.join(' and ')} still empty`
      : `Also reads ${extra.join(', ')}`;
    slot.classList.toggle('set', free.length === 0);
    const button = $<HTMLButtonElement>('secondLabel');
    button.textContent = free.length ? `Add an image for ${free[0]}` : 'Add another image';
    button.onclick = () => addImageNode({ node: node.id, port: free[0] ?? extra[0] });
  }

  const pr = $('presets');
  pr.innerHTML = '';
  for (const preset of f.presets) {
    const b = document.createElement('button');
    b.className = 'chip' + (node.preset === preset.name ? ' on' : '');
    b.textContent = preset.name;
    b.title = 'Load this preset into the node';
    b.onclick = () => applyPreset(preset);
    pr.appendChild(b);
  }

  const box = $('params');
  box.innerHTML = '';
  const derived = new Set(f.derived ?? []);
  const own = f.params.filter((p) => !p.engine && !derived.has(p.name));
  const engine = f.params.filter((p) => p.engine);

  if (!own.length && !engine.length) {
    box.innerHTML = '<p class="empty">This filter has no parameters.</p>';
    return;
  }
  if (!own.length) {
    const note = document.createElement('p');
    note.className = 'empty';
    note.textContent = 'This filter takes no settings of its own.';
    box.appendChild(note);
  }
  for (const p of own) box.appendChild(control(p, node));

  if (engine.length) {
    const head = document.createElement('h3');
    head.className = 'group';
    head.textContent = 'View';
    head.title = 'Applied by the engine around every filter, not by the filter itself';
    box.appendChild(head);
    for (const p of engine) box.appendChild(control(p, node));
  }
  // Controls rebuilt after a probe has already answered keep its answer.
  markInert();
}

/** Load a preset into the node, so its sliders move and can be taken further. */
function applyPreset(preset: PresetSpec): void {
  const node = selectedNode();
  if (!node) return;
  // The engine layers a preset over the defaults and lets caller values win,
  // so writing them into the node is the same render by a different route.
  node.values = { ...defaults(node.filter), ...preset.params };
  node.preset = preset.name;
  renderControls();
  render();
}

function setValue(name: string, value: Value): void {
  const node = selectedNode();
  if (!node) return;
  node.values[name] = value;
  // The values are no longer the preset's once one of them has been moved.
  if (node.preset) {
    node.preset = null;
    for (const chip of $('presets').children) chip.classList.remove('on');
  }
  render();
}

/** Read a node value as the shape a control needs, whatever the JSON held. */
const asNumber = (v: Value): number => (typeof v === 'number' ? v : 0);
const asVector = (v: Value): number[] => (Array.isArray(v) ? (v as number[]) : []);
const asMatrix = (v: Value): number[][] | null =>
  Array.isArray(v) && Array.isArray(v[0]) ? (v as number[][]) : null;
const asPalette = (v: Value): number[][] =>
  Array.isArray(v) && Array.isArray(v[0]) ? (v as number[][]) : [];

function control(p: ParamSpec, node: FilterNode): HTMLElement {
  const wrap = document.createElement('div');
  wrap.className = 'param';
  wrap.dataset.param = p.name;

  const label = document.createElement('label');
  label.title = describeParam(p);
  const title = document.createElement('span');
  title.textContent = p.label || p.name;
  label.appendChild(title);
  const val = document.createElement('span');
  val.className = 'val';
  label.appendChild(val);
  wrap.appendChild(label);

  const v = node.values[p.name];

  if (p.choices && p.choices.length) {
    val.textContent = '';
    const sel = document.createElement('select');
    for (const c of p.choices) {
      const o = document.createElement('option');
      o.value = String(c.value);
      o.textContent = c.label;
      if (c.value === v) o.selected = true;
      sel.appendChild(o);
    }
    sel.onchange = () => setValue(p.name, parseInt(sel.value, 10));
    wrap.appendChild(sel);
    return wrap;
  }

  if (p.type === 'float' || p.type === 'int') {
    val.textContent = fmt(v);
    const r = document.createElement('input');
    r.type = 'range';
    r.min = String(p.min ?? 0);
    r.max = String(p.max ?? 1);
    r.step = String(stepOf(p));
    r.value = String(asNumber(v));
    r.oninput = () => {
      const n = p.type === 'int' ? parseInt(r.value, 10) : parseFloat(r.value);
      val.textContent = fmt(n);
      setValue(p.name, n);
    };
    wrap.appendChild(r);
    return wrap;
  }

  if (p.type === 'vec4' && p.widget === 'color') {
    const rgba = asVector(v);
    const alpha = rgba[3] ?? 1;
    // The browser's colour input has no alpha, so opacity is its own row --
    // named, and showing its value, because an unlabelled slider under a
    // swatch reads as decoration rather than as the transparency control.
    val.textContent = `${Math.round(alpha * 100)}% opaque`;
    const c = document.createElement('input');
    c.type = 'color';
    c.value = toHex(rgba);
    c.oninput = () => setValue(p.name, fromHex(c.value, asVector(node.values[p.name])[3] ?? 1));
    wrap.appendChild(c);

    const a = slider(0, 1, 0.01, alpha, 'opacity', (x) => {
      const cur = asVector(node.values[p.name]);
      val.textContent = `${Math.round(x * 100)}% opaque`;
      setValue(p.name, [cur[0], cur[1], cur[2], x]);
    });
    a.title = 'Transparency of this colour';
    wrap.appendChild(a);
    return wrap;
  }

  if (p.type === 'vec2' || p.type === 'vec3' || p.type === 'vec4') {
    val.textContent = '';
    const row = document.createElement('div');
    row.className = 'vecrow';
    const n = parseInt(p.type.slice(3), 10);
    for (let i = 0; i < n; i++) {
      const f = document.createElement('input');
      f.type = 'number';
      f.step = '0.01';
      f.value = String(asVector(v)[i] ?? 0);
      f.oninput = () => {
        const cur = [...asVector(node.values[p.name])];
        cur[i] = parseFloat(f.value) || 0;
        setValue(p.name, cur);
      };
      row.appendChild(f);
    }
    wrap.appendChild(row);
    return wrap;
  }

  // A mat3 is scale, rotation and offset -- the same three the app's own
  // `lt2d` builder takes, so a preset's matrix decomposes straight back into
  // these sliders.
  if (p.type === 'mat3') {
    const st = decompose3(asMatrix(v));
    val.textContent = fmt(st.scale);
    const push = () => {
      val.textContent = fmt(st.scale);
      setValue(p.name, compose3(st));
    };
    wrap.appendChild(slider(0.002, 4, 0.002, st.scale, 'scale', (x) => { st.scale = x; push(); }));
    wrap.appendChild(slider(-Math.PI, Math.PI, 0.01, st.rot, 'rotate', (x) => { st.rot = x; push(); }));
    wrap.appendChild(slider(-2, 2, 0.01, st.tx, 'offset x', (x) => { st.tx = x; push(); }));
    wrap.appendChild(slider(-2, 2, 0.01, st.ty, 'offset y', (x) => { st.ty = x; push(); }));
    return wrap;
  }

  // A mat4 places a camera or an object in the 3D filters.  Only rotation and
  // the distance along z are meaningful there, and the distance is what
  // decides whether the camera sits inside the object or outside it.
  if (p.type === 'mat4') {
    const st = decompose4(asMatrix(v));
    val.textContent = fmt(st.dist);
    const push = () => {
      val.textContent = fmt(st.dist);
      setValue(p.name, compose4(st));
    };
    wrap.appendChild(slider(-Math.PI, Math.PI, 0.01, st.yaw, 'yaw', (x) => { st.yaw = x; push(); }));
    wrap.appendChild(slider(-Math.PI / 2, Math.PI / 2, 0.01, st.pitch, 'pitch', (x) => { st.pitch = x; push(); }));
    wrap.appendChild(slider(-8, 8, 0.05, st.dist, 'distance', (x) => { st.dist = x; push(); }));
    wrap.appendChild(slider(0.05, 4, 0.05, st.scale, 'scale', (x) => { st.scale = x; push(); }));
    return wrap;
  }

  if (p.type === 'string') {
    val.textContent = '';
    const t = document.createElement('input');
    t.type = 'text';
    t.className = 'text';
    t.value = typeof v === 'string' ? v : '';
    t.oninput = () => setValue(p.name, t.value);
    wrap.appendChild(t);
    return wrap;
  }

  // A fixed-length uniform array: a palette, a shape table or a sphere list.
  if (p.array) {
    const array = p.array;
    val.textContent = `${array.length} × ${array.elem}`;
    if (array.elem === 'vec4') {
      const row = document.createElement('div');
      row.className = 'palette';
      const distinct = uniqueRuns(asPalette(v));
      distinct.forEach((entry, i) => {
        const c = document.createElement('input');
        c.type = 'color';
        c.value = toHex(entry);
        c.oninput = () => {
          distinct[i] = fromHex(c.value, entry[3] ?? 1);
          setValue(p.name, cycle(distinct, array.length));
        };
        row.appendChild(c);
      });
      const add = document.createElement('button');
      add.className = 'chip';
      add.textContent = '+';
      add.title = 'Add a colour';
      add.onclick = () => {
        distinct.push([1, 1, 1, 1]);
        setValue(p.name, cycle(distinct, array.length));
        renderControls();
      };
      wrap.appendChild(row);
      wrap.appendChild(add);
    } else {
      const t = document.createElement('input');
      t.type = 'text';
      t.className = 'text';
      t.value = asVector(v).join(', ');
      t.oninput = () => {
        const nums = t.value.split(',').map((x) => parseFloat(x) || 0);
        setValue(p.name, cycle(nums, array.length));
      };
      wrap.appendChild(t);
    }
    return wrap;
  }

  val.textContent = p.type;
  return wrap;
}

/* --------------------------------------------------------------- render */

let timer: number | undefined;

/* The module borrows its renderer for the length of a call, so two that
   overlap abort with an aliasing error. Everything entering the wasm goes
   through this queue, which runs one at a time in the order asked for. */
let gpuQueue: Promise<unknown> = Promise.resolve();

function onGpu<T>(work: () => T | Promise<T>): Promise<T> {
  const run = gpuQueue.then(work, work);
  gpuQueue = run.then(() => {}, () => {});
  return run;
}

/** What is bound in the module now, so unchanged images are not re-sent. */
let bound = '';

/** Hand the module the image nodes' pictures, under the names the graph uses. */
async function bindSources(gpu: Filters): Promise<void> {
  const loaded = imageNodes().filter((n) => n.bitmap);
  const key = `${state.sourcesId}|${loaded.map((n) => n.id).join(',')}`;
  if (key === bound) return;
  await onGpu(() => {
    gpu.clear_inputs();
    for (const n of loaded) {
      const b = n.bitmap;
      if (b) gpu.set_input([n.id], b.data, b.width, b.height);
    }
  });
  bound = key;
}

function render(): void {
  if (!state.preview || !state.gpu) return;
  clearTimeout(timer);
  timer = setTimeout(doRender, 60) as unknown as number;   // debounce slider drags
}

async function doRender(): Promise<void> {
  const gpu = state.gpu;
  if (!state.preview || !gpu) return;
  const seq = ++state.seq;
  await bindSources(gpu);
  if (seq !== state.seq) return;
  const graph = toGraph();
  const { width, height, data } = state.preview;

  if (!graph) {
    paint($<HTMLCanvasElement>('preview'), width, height, data);
    $('preview').hidden = false;
    $('dropzone').hidden = true;
    $('statusText').textContent = 'The chain is empty — the source passes through';
    void thumbnails();
    return;
  }

  $('spinner').hidden = false;
  const t0 = performance.now();
  try {
    // A render that was superseded while it waited its turn is dropped
    // rather than run: a slider drag would otherwise pay for every step.
    const out = await onGpu(() => (seq === state.seq
      ? gpu.render_graph(JSON.stringify(graph), data, width, height)
      : null));
    if (out === null || seq !== state.seq) return;
    paint($<HTMLCanvasElement>('preview'), width, height, out);
    $('preview').hidden = false;
    $('dropzone').hidden = true;
    $<HTMLButtonElement>('downloadBtn').disabled = false;
    $('statusText').textContent = `chain rendered · ${Math.round(performance.now() - t0)} ms`;
    $('statusText').title = '';
  } catch (err) {
    // A shader the browser refuses reports a whole page of WGSL; the first
    // line says what it objected to and the rest belongs in the console.
    $('statusText').textContent = readable(err);
    $('statusText').title = String(err);
    console.warn(err);
  } finally {
    // A superseded render leaves the spinner to the one that replaced it.
    if (seq === state.seq) $('spinner').hidden = true;
  }
  void thumbnails();
  void probeInert();
}

/** Which of the selected node's controls do nothing where the chain now sits.
 *
 *  A filter can carry parameters its shader never reads: `basic-ray-marcher`
 *  is the base the ray-marching family is built on, and marches no shape, so
 *  its lighting, shadows and refraction have nothing to act on -- only the
 *  background style shows. Rather than assert that anywhere, each control is
 *  moved to a clearly different value and the result compared.
 *
 *  Only a byte-identical image counts, so this never calls a control dead for
 *  being subtle. It says nothing about other settings either: a control that
 *  does nothing while a switch above it is off is reported as it is now, and
 *  re-measured when that switch moves. */
async function probeInert(): Promise<void> {
  const run = ++state.probe;
  state.inert = new Set();
  state.inertFor = null;
  const node = selectedNode();
  const gpu = state.gpu;
  const spec = node ? state.byId.get(node.filter) : undefined;
  if (!node || !gpu || !spec || !state.preview) return;
  const graph = subGraph(node.id);
  if (!graph) return;

  // Small enough to be quick, large enough that a filter working at the scale
  // of a few pixels still has room to show it.
  const side = 192;
  const { width, height, data } = state.preview;
  const scale = Math.min(1, side / Math.max(width, height));
  const w = Math.max(1, Math.round(width * scale));
  const h = Math.max(1, Math.round(height * scale));
  const small = downscale(data, width, height, w, h);

  const draw = async (g: FilterGraph): Promise<Uint8Array | null> =>
    onGpu(() => (run === state.probe
      ? gpu.render_graph(JSON.stringify(g), small, w, h)
      : null));

  let base: Uint8Array | null;
  try {
    base = await draw(graph);
  } catch {
    return;
  }
  if (!base || run !== state.probe) return;

  const dead: string[] = [];
  for (const param of spec.params) {
    if (run !== state.probe) return;
    const other = otherValue(param, node.values[param.name]);
    if (other === null) continue;
    let out: Uint8Array | null;
    try {
      out = await draw({ ...graph, params: { ...graph.params, [param.name]: other } });
    } catch {
      continue;
    }
    if (!out || run !== state.probe) return;
    if (same(base, out)) dead.push(param.name);
  }
  if (run !== state.probe) return;
  state.inert = new Set(dead);
  state.inertFor = node.id;
  markInert();
}

function same(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

/** A value plainly different from the one a control holds, or null where one
 *  cannot be picked confidently -- a matrix, a palette, a free string. */
function otherValue(p: ParamSpec, current: Value): Value | null {
  if (p.choices && p.choices.length > 1) {
    const other = p.choices.find((c) => c.value !== current);
    return other ? other.value : null;
  }
  if (p.type === 'float' || p.type === 'int') {
    if (p.min === null || p.max === null || p.min === p.max) return null;
    const now = typeof current === 'number' ? current : p.min;
    // The far end from where it sits, so the move is as large as the range
    // allows rather than a nudge that a coarse filter would round away.
    const far = Math.abs(now - p.min) > Math.abs(now - p.max) ? p.min : p.max;
    return p.type === 'int' ? Math.round(far) : far;
  }
  if (p.type === 'bool') return typeof current === 'number' ? (current ? 0 : 1) : 1;
  if (p.type === 'vec4' || p.type === 'vec3' || p.type === 'vec2') {
    const v = asVector(current);
    if (!v.length) return null;
    // Every component moved, and away from whatever it holds, so a colour
    // already at one extreme still travels.
    return v.map((n, i) => (i === 3 && p.type === 'vec4' ? n : n > 0.5 ? 0 : 1));
  }
  return null;
}

/** Put the probe's answer on the controls already on screen, without
 *  rebuilding them: the pointer may be resting on one. */
function markInert(): void {
  const mine = state.inertFor === chain.selected;
  for (const el of $('params').querySelectorAll<HTMLElement>('.param[data-param]')) {
    const dead = mine && state.inert.has(el.dataset.param ?? '');
    el.classList.toggle('inert', dead);
    const label = el.querySelector('label');
    if (!label) continue;
    const base = label.title.split('\nthis control')[0];
    label.title = dead
      ? base + '\nthis control changes nothing where the chain now stands'
      : base;
  }
}

/** What each node's thumbnail currently shows, so it is drawn only once. */
const painted = new Map<string, string>();

/** Each node shows what the chain looks like up to and including it.
 *
 *  A thumbnail is the chain as far as that node, so a change to one node
 *  leaves every thumbnail upstream of it untouched. Those are recognised by
 *  the graph they were drawn from and skipped, which is what keeps a slider
 *  drag on a long chain to one render rather than one per node. */
async function thumbnails(): Promise<void> {
  const gpu = state.gpu;
  if (!state.preview || !gpu) return;
  const run = ++state.thumbs;
  const { width, height, data } = state.preview;
  const side = 160;
  const scale = Math.min(1, side / Math.max(width, height));
  const tw = Math.max(1, Math.round(width * scale));
  const th = Math.max(1, Math.round(height * scale));
  const small = downscale(data, width, height, tw, th);

  for (const node of [...chain.nodes.values()]) {
    if (run !== state.thumbs) return;
    const canvas = $('nodes').querySelector<HTMLCanvasElement>(`canvas[data-thumb="${node.id}"]`);
    if (!canvas) continue;
    if (node.kind === 'image') {
      // Its own picture, not a render: nothing has been applied to it yet.
      const b = node.bitmap;
      if (b) paint(canvas, b.width, b.height, b.data);
      continue;
    }
    const upto = node.kind === 'output' ? toGraph()
      : node.kind === 'filter' ? subGraph(node.id)
      : null;
    // The source image is part of the key: a new image redraws everything.
    const key = `${state.sourceId}|${state.sourcesId}|${tw}x${th}|${JSON.stringify(upto)}`;
    if (painted.get(node.id) === key && canvas.width === tw) continue;

    let out: Uint8Array | null = small;
    if (upto) {
      try {
        out = await onGpu(() => (run === state.thumbs
          ? gpu.render_graph(JSON.stringify(upto), small, tw, th)
          : null));
        if (out === null) return;
      } catch {
        continue;
      }
    }
    if (run !== state.thumbs) return;
    paint(canvas, tw, th, out);
    painted.set(node.id, key);
  }
}

function downscale(data: Uint8Array, w: number, h: number, tw: number, th: number): Uint8Array {
  const src = new OffscreenCanvas(w, h);
  src.getContext('2d')!.putImageData(new ImageData(new Uint8ClampedArray(data), w, h), 0, 0);
  const dst = new OffscreenCanvas(tw, th);
  const ctx = dst.getContext('2d')!;
  ctx.drawImage(src, 0, 0, tw, th);
  return new Uint8Array(ctx.getImageData(0, 0, tw, th).data.buffer);
}

function paint(canvas: HTMLCanvasElement, width: number, height: number, rgba: Uint8Array): void {
  canvas.width = width;
  canvas.height = height;
  canvas.getContext('2d')!
    .putImageData(new ImageData(new Uint8ClampedArray(rgba), width, height), 0, 0);
}

/* ---------------------------------------------------------------- image */

/** An image file as RGBA8, scaled down if it is larger than the limit. */
async function readImage(file: File, limit = 1400): Promise<Bitmap> {
  const bitmap = await createImageBitmap(file);
  const scale = Math.min(1, limit / Math.max(bitmap.width, bitmap.height));
  const width = Math.max(1, Math.round(bitmap.width * scale));
  const height = Math.max(1, Math.round(bitmap.height * scale));
  const canvas = new OffscreenCanvas(width, height);
  const ctx = canvas.getContext('2d')!;
  ctx.drawImage(bitmap, 0, 0, width, height);
  bitmap.close();
  return {
    width,
    height,
    data: new Uint8Array(ctx.getImageData(0, 0, width, height).data.buffer),
  };
}

/** The longest side the preview is rendered at. */
const PREVIEW_MAX = 900;

function previewOf(image: Bitmap): Bitmap {
  const scale = Math.min(1, PREVIEW_MAX / Math.max(image.width, image.height));
  if (scale === 1) return image;
  const width = Math.max(1, Math.round(image.width * scale));
  const height = Math.max(1, Math.round(image.height * scale));
  return { width, height, data: downscale(image.data, image.width, image.height, width, height) };
}

async function loadFile(file: File | undefined): Promise<void> {
  if (!file || !file.type.startsWith('image/')) return;
  const image = await readImage(file);
  state.source = image;
  state.preview = previewOf(image);
  state.sourceId += 1;
  paint($<HTMLCanvasElement>('original'), image.width, image.height, image.data);
  paint($<HTMLCanvasElement>('preview'), image.width, image.height, image.data);
  $('dropzone').hidden = true;
  $('preview').hidden = false;
  render();
}

/* ------------------------------------------------------------------ init */

/** Say which of the two failures this is, and what to do about it.
 *
 *  A browser without WebGPU has no `navigator.gpu` at all. A browser that has
 *  it and still refuses a device is a different problem -- the GPU is
 *  blocklisted, behind a flag, or the driver said no -- and the advice for one
 *  is no use for the other. */
function explainNoGpu(err: unknown): void {
  const api = 'gpu' in navigator;
  const lead = $('blockerLead');
  const list = $('blockerRemedies');
  $('blockerTitle').textContent = api
    ? 'This browser has WebGPU but would not give a device'
    : 'This browser has no WebGPU';
  lead.textContent = api
    ? 'navigator.gpu exists, so the browser supports WebGPU. Asking it for a '
      + 'device returned nothing, which is usually the GPU being blocklisted '
      + 'or held behind a flag rather than anything missing.'
    : 'navigator.gpu is not defined, so this browser does not support WebGPU '
      + 'at all, or has it switched off.';

  const remedies = api
    ? [
        'Chrome or Edge: open <code>chrome://gpu</code> and look at the WebGPU '
        + 'line. "Disabled" or "Software only" there is the whole answer.',
        'On Linux especially, a working GPU is often still refused: start the '
        + 'browser with <code>--enable-unsafe-webgpu --enable-features=Vulkan</code>, '
        + 'and add <code>--ignore-gpu-blocklist</code> if the driver is blocklisted.',
        'Check <code>chrome://flags/#enable-unsafe-webgpu</code> is Enabled.',
        'If this started after a GPU error and reloading will not clear it, the '
        + 'browser\'s GPU process is down and a reload cannot restart it. Quit '
        + 'the browser fully and open it again.',
        'A remote session, a VM without GPU passthrough, or a headless display '
        + 'will have no adapter to give.',
      ]
    : [
        'Chrome or Edge 113 and later, or Safari 18 and later.',
        'Firefox: set <code>dom.webgpu.enabled</code> to true in '
        + '<code>about:config</code>.',
        'Serving the page over <code>file://</code> can also withhold it — use a '
        + 'local server, which is what <code>python -m http.server</code> is for.',
      ];
  list.innerHTML = '';
  for (const r of remedies) {
    const li = document.createElement('li');
    li.innerHTML = r;
    list.appendChild(li);
  }
  // The driver's own words last: precise, and meaningless to most readers.
  $('blockerWhy').textContent = String(err).replace(/^Error:\s*/, '');
  $('blocker').hidden = false;
}

async function start(): Promise<void> {
  await init();

  try {
    state.gpu = await Filters.open();
  } catch (err) {
    explainNoGpu(err);
    $('statusText').textContent = 'WebGPU unavailable';
    return;
  }

  state.filters = JSON.parse(catalog()) as FilterSpec[];
  for (const f of state.filters) state.byId.set(f.id, f);
  state.categories = [...new Set(state.filters.map((f) => f.category))].sort();
  const seen = new Set<string>();
  for (const f of state.filters) {
    if (seen.has(f.name)) state.ambiguous.add(f.name);
    seen.add(f.name);
  }

  // Counted the way the list presents them: a blur wrapper is a graph, but it
  // reads as one filter here, so it is not offered as a chain to open.
  const counts: Record<string, number> = {};
  for (const f of state.filters) {
    const kind = f.wrapped ? 'gpu' : f.backend;
    counts[kind] = (counts[kind] || 0) + 1;
  }
  $('bankMeta').textContent =
    `${state.filters.length} filters · ${counts.gpu || 0} GPU · ${counts.graph || 0} chained · ` +
    `${counts.cpu || 0} CPU · ${state.categories.length} categories`;
  $('statusText').textContent = 'Open an image, then add filters to the chain';

  renderCategories();
  renderList();
  renderControls();
  draw();

  $<HTMLInputElement>('search').oninput = (e) => {
    state.query = (e.target as HTMLInputElement).value;
    renderList();
  };
  $<HTMLInputElement>('fileInput').onchange = (e) => {
    void loadFile((e.target as HTMLInputElement).files?.[0]);
  };
  $<HTMLInputElement>('imageInput').onchange = async (e) => {
    const file = (e.target as HTMLInputElement).files?.[0];
    const node = pickingFor ? chain.nodes.get(pickingFor) : undefined;
    pickingFor = null;
    if (!file || !node || node.kind !== 'image' || !file.type.startsWith('image/')) return;
    node.bitmap = await readImage(file);
    node.name = file.name;
    state.sourcesId += 1;
    draw();
    renderControls();
    render();
  };
  $('resetBtn').onclick = () => {
    const node = selectedNode();
    if (!node) return;
    node.values = defaults(node.filter);
    node.preset = null;
    renderControls();
    render();
  };
  $('addImageBtn').onclick = () => addImageNode();
  $('clearBtn').onclick = () => {
    chain.nodes.clear();
    chain.links = [];
    state.sourcesId += 1;
    chain.next = 1;
    select(null);
    state.view = { x: 40, y: 30, k: 1 };
    draw();
    render();
  };

  $('downloadBtn').onclick = () => void download();

  const wrap = $('canvasWrap');
  wrap.addEventListener('dragover', (e) => {
    e.preventDefault();
    wrap.classList.add('dragging');
  });
  wrap.addEventListener('dragleave', () => wrap.classList.remove('dragging'));
  wrap.addEventListener('drop', (e) => {
    e.preventDefault();
    wrap.classList.remove('dragging');
    void loadFile(e.dataTransfer?.files[0]);
  });

  const cmp = $<HTMLInputElement>('compareToggle');
  cmp.addEventListener('change', () => {
    const on = cmp.checked && !!state.source;
    $('original').hidden = !on;
    $('preview').hidden = on;
  });

  // Panning and zooming the chain.
  const graph = $('graph');
  graph.addEventListener('pointerdown', (e) => {
    const target = e.target as HTMLElement;
    if (target.closest('.node') || target.closest('.graphbar')) return;
    const start = { x: e.clientX, y: e.clientY, vx: state.view.x, vy: state.view.y };
    graph.classList.add('panning');
    const move = (ev: PointerEvent) => {
      state.view.x = start.vx + (ev.clientX - start.x);
      state.view.y = start.vy + (ev.clientY - start.y);
      applyView();
    };
    const up = () => {
      graph.classList.remove('panning');
      window.removeEventListener('pointermove', move);
      window.removeEventListener('pointerup', up);
    };
    window.addEventListener('pointermove', move);
    window.addEventListener('pointerup', up);
  });
  graph.addEventListener('wheel', (e) => {
    e.preventDefault();
    zoom(Math.exp(-e.deltaY * 0.0015), e.clientX, e.clientY);
  }, { passive: false });
  $('zoomIn').onclick = () => zoom(1.2);
  $('zoomOut').onclick = () => zoom(1 / 1.2);
  $('zoomFit').onclick = () => {
    fit();
    applyView();
  };
}

/** A render failure in the reader's terms, where the failure is understood.
 *
 *  WGSL's own words are exact and unhelpful: someone here to make an image
 *  cannot act on "'dpdy' must only be called from uniform control flow". The
 *  driver's text stays on the element's title for anyone who wants it. */
function readable(err: unknown): string {
  const text = String(err);
  if (/uniform control flow|dpdy|dpdx/.test(text)) {
    return 'This filter cannot run in a browser: it takes a screen-space '
      + 'gradient inside a branch, which WGSL forbids. It is not broken and '
      + 'nothing here can enable it — the same filter works in the native '
      + 'build.';
  }
  if (/device was lost|device lost/i.test(text)) {
    return 'The GPU device was lost. Reload the page; if that does not help, '
      + 'the browser\'s GPU process is down and only restarting the browser '
      + 'will bring it back.';
  }
  return text.split('\n')[0].replace(/^Error:\s*/, '');
}

/** Save the chain at the image's own size, not the preview's.
 *
 *  The preview is deliberately small; what leaves should not be. */
async function download(): Promise<void> {
  const gpu = state.gpu;
  const full = state.source;
  if (!gpu || !full) return;
  const graph = toGraph();
  const was = $('statusText').textContent;
  $('statusText').textContent = `rendering ${full.width}x${full.height}…`;
  $('spinner').hidden = false;
  let out = full.data;
  try {
    if (graph) {
      out = await onGpu(() => gpu.render_graph(JSON.stringify(graph), full.data, full.width, full.height));
    }
  } catch (err) {
    $('statusText').textContent = String(err).split('\n')[0].replace(/^Error:\s*/, '');
    $('spinner').hidden = true;
    return;
  }
  $('spinner').hidden = true;
  $('statusText').textContent = was;

  const canvas = document.createElement('canvas');
  paint(canvas, full.width, full.height, out);
  canvas.toBlob((blob) => {
    if (!blob) return;
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'gltcstdio-chain.png';
    a.click();
    URL.revokeObjectURL(a.href);
  });
}

function applyView(): void {
  const t = `translate(${state.view.x}px, ${state.view.y}px) scale(${state.view.k})`;
  $('nodes').style.transform = t;
  $('wires').style.transform = t;
}

function zoom(by: number, cx?: number, cy?: number): void {
  const box = $('graph').getBoundingClientRect();
  const px = (cx ?? box.left + box.width / 2) - box.left;
  const py = (cy ?? box.top + box.height / 2) - box.top;
  const k = clamp(state.view.k * by, 0.25, 2);
  const ratio = k / state.view.k;
  state.view.x = px - (px - state.view.x) * ratio;
  state.view.y = py - (py - state.view.y) * ratio;
  state.view.k = k;
  applyView();
}

void start();
