// Pure helpers behind the parameter controls: number formatting, colours, and
// the matrix decompositions that turn a preset's matrix back into sliders.
export function clamp(v, lo, hi) {
    if (v < lo)
        return lo;
    if (v > hi)
        return hi;
    return v;
}
export function toHex(rgba) {
    const c = (x) => Math.round(clamp(x, 0, 1) * 255).toString(16).padStart(2, '0');
    return '#' + c(rgba[0] ?? 0) + c(rgba[1] ?? 0) + c(rgba[2] ?? 0);
}
export function fromHex(hex, alpha) {
    const n = parseInt(hex.slice(1), 16);
    return [((n >> 16) & 255) / 255, ((n >> 8) & 255) / 255, (n & 255) / 255, alpha];
}
/** A step small enough to move smoothly across the parameter's own range. */
export function stepOf(p) {
    if (p.step)
        return p.step;
    if (p.type === 'int')
        return 1;
    const span = (p.max ?? 1) - (p.min ?? 0);
    return span > 0 ? span / 200 : 0.005;
}
export function fmt(v) {
    if (typeof v === 'number')
        return Number.isInteger(v) ? String(v) : v.toFixed(3);
    return v === null ? '' : String(v);
}
export function slider(min, max, stepSize, value, title, onchange) {
    const row = document.createElement('div');
    row.className = 'subrow';
    const name = document.createElement('span');
    name.className = 'sublabel';
    name.textContent = title;
    const r = document.createElement('input');
    r.type = 'range';
    r.min = String(min);
    r.max = String(max);
    r.step = String(stepSize);
    r.value = String(value);
    r.oninput = () => onchange(parseFloat(r.value));
    row.appendChild(name);
    row.appendChild(r);
    return row;
}
/** Split a mat3 back into the scale, rotation and offset that built it. */
export function decompose3(m) {
    if (!m)
        return { scale: 1, rot: 0, tx: 0, ty: 0 };
    const a = m[0][0];
    const b = m[1][0];
    const scale = Math.hypot(a, b) || 1;
    return { scale, rot: Math.atan2(b, a), tx: m[0][2] || 0, ty: m[1][2] || 0 };
}
export function compose3(s) {
    const c = Math.cos(s.rot);
    const n = Math.sin(s.rot);
    return [
        [s.scale * c, -n * s.scale, s.tx],
        [s.scale * n, c * s.scale, s.ty],
        [0, 0, 1],
    ];
}
/** Yaw, pitch, distance and scale from a mat4 placement, the exact inverse
 *  of `compose4`; reading any other cells makes a preset's matrix show the
 *  wrong slider positions and jump on the first nudge. */
export function decompose4(m) {
    if (!m)
        return { yaw: 0, pitch: 0, dist: 0, scale: 1 };
    const scale = Math.hypot(m[1][1], m[1][2]) || 1;
    return {
        yaw: Math.atan2(-(m[2][0] || 0), m[0][0] || 1),
        pitch: Math.atan2(-(m[1][2] || 0), m[1][1] || 1),
        dist: m[2][3] || 0,
        scale,
    };
}
export function compose4(s) {
    const cy = Math.cos(s.yaw);
    const sy = Math.sin(s.yaw);
    const cp = Math.cos(s.pitch);
    const sp = Math.sin(s.pitch);
    const r = [
        [cy * s.scale, sy * sp * s.scale, sy * cp * s.scale],
        [0, cp * s.scale, -sp * s.scale],
        [-sy * s.scale, cy * sp * s.scale, cy * cp * s.scale],
    ];
    return [
        [r[0][0], r[0][1], r[0][2], 0],
        [r[1][0], r[1][1], r[1][2], 0],
        [r[2][0], r[2][1], r[2][2], s.dist],
        [0, 0, 0, 1],
    ];
}
/** The distinct leading entries of an array that repeats them. */
export function uniqueRuns(list) {
    if (!list || !list.length)
        return [[1, 1, 1, 1]];
    const key = (e) => JSON.stringify(e);
    const first = key(list[0]);
    for (let n = 1; n <= list.length; n++) {
        let repeats = true;
        for (let i = 0; i < list.length; i++) {
            if (key(list[i]) !== key(list[i % n])) {
                repeats = false;
                break;
            }
        }
        if (repeats && (n > 1 || key(list[0]) === first)) {
            return list.slice(0, n).map((e) => [...e]);
        }
    }
    return list.slice(0, 8).map((e) => [...e]);
}
export function cycle(entries, length) {
    const out = [];
    for (let i = 0; i < length; i++)
        out.push(entries[i % entries.length]);
    return out;
}
//# sourceMappingURL=controls.js.map