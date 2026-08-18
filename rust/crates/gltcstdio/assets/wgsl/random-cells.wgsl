struct Params {
    U: array<vec4<f32>, 7>,
}

struct HexTile {
    center: vec2<f32>,
    pos: vec2<f32>,
    angle: f32,
    centerDist: f32,
    borderDist: f32,
}

struct CairoTile {
    center: vec2<f32>,
    borderDist: f32,
}

struct TriangleTile {
    up: bool,
    center: vec2<f32>,
    pos: vec2<f32>,
    angle: f32,
    centerDist: f32,
    borderDist: f32,
}

struct Tile {
    centerDist: f32,
    tileId: vec2<f32>,
    borderDist: f32,
    center: vec2<f32>,
    borderNormal: vec2<f32>,
    secondCenterDist: f32,
    secondTileId: vec2<f32>,
    thirdCenterDist: f32,
}

struct FragmentOutput {
    @location(0) fragColor: vec4<f32>,
}

var<private> v_uv_1: vec2<f32>;
var<private> fragColor: vec4<f32>;
@group(0) @binding(0) 
var<uniform> global: Params;
@group(0) @binding(1) 
var samp: sampler;

fn hash21_(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_1 = p;
    let _e9 = p_1;
    a = fract((-45.3277f * _e9.xy));
    let _e14 = a;
    let _e15 = a;
    let _e16 = a;
    b = (_e14 + vec2(dot(_e15, (_e16 + vec2(123.3371f)))));
    let _e24 = b;
    let _e26 = b;
    return fract((_e24.x * _e26.y));
}

fn cellColor(id: vec2<f32>) -> vec3<f32> {
    var id_1: vec2<f32>;

    id_1 = id;
    let _e7 = id_1;
    let _e11 = hash21_((_e7 + vec2(0.1f)));
    let _e12 = id_1;
    let _e16 = hash21_((_e12 + vec2(3.7f)));
    let _e17 = id_1;
    let _e21 = hash21_((_e17 + vec2(9.2f)));
    return vec3<f32>(_e11, _e16, _e21);
}

fn randomCells(uv: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, detail: i32, randomSeed: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var detail_1: i32;
    var randomSeed_1: f32;
    var ar: f32;
    var halfRect: vec2<f32>;
    var n: f32;
    var t: vec2<f32>;
    var id_2: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    outDim_1 = outDim;
    detail_1 = detail;
    randomSeed_1 = randomSeed;
    let _e15 = outDim_1;
    let _e17 = outDim_1;
    ar = (_e15.x / _e17.y);
    let _e21 = ar;
    halfRect = vec2<f32>((_e21 * 0.5f), 0.5f);
    let _e27 = uv_1;
    let _e30 = halfRect;
    let _e33 = uv_1;
    let _e36 = halfRect;
    if ((abs(_e27.x) > _e30.x) || (abs(_e33.y) > _e36.y)) {
        return vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e46 = detail_1;
    n = max(1f, f32(_e46));
    let _e50 = uv_1;
    let _e51 = halfRect;
    t = clamp((((_e50 / _e51) * 0.5f) + vec2(0.5f)), vec2(0f), vec2(0.999999f));
    let _e64 = t;
    let _e65 = n;
    id_2 = floor((_e64 * _e65));
    let _e69 = id_2;
    let _e70 = randomSeed_1;
    let _e75 = cellColor((_e69 + vec2((_e70 * 13f))));
    return vec4<f32>(_e75.x, _e75.y, _e75.z, 1f);
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[4];
    let _e69 = global.U[5];
    let _e74 = global.U[6];
    let _e76 = randomCells((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65.xy, i32(_e69.x), _e74.x);
    fragColor = _e76;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
}

fn _naga_inverse_3x3_f32(m: mat3x3<f32>) -> mat3x3<f32> {
    var adj: mat3x3<f32>;

    adj[0][0] =   (m[1][1] * m[2][2] - m[2][1] * m[1][2]);
    adj[1][0] = - (m[1][0] * m[2][2] - m[2][0] * m[1][2]);
    adj[2][0] =   (m[1][0] * m[2][1] - m[2][0] * m[1][1]);
    adj[0][1] = - (m[0][1] * m[2][2] - m[2][1] * m[0][2]);
    adj[1][1] =   (m[0][0] * m[2][2] - m[2][0] * m[0][2]);
    adj[2][1] = - (m[0][0] * m[2][1] - m[2][0] * m[0][1]);
    adj[0][2] =   (m[0][1] * m[1][2] - m[1][1] * m[0][2]);
    adj[1][2] = - (m[0][0] * m[1][2] - m[1][0] * m[0][2]);
    adj[2][2] =   (m[0][0] * m[1][1] - m[1][0] * m[0][1]);

    let det: f32 = (m[0][0] * (m[1][1] * m[2][2] - m[1][2] * m[2][1])
    		- m[0][1] * (m[1][0] * m[2][2] - m[1][2] * m[2][0])
    		+ m[0][2] * (m[1][0] * m[2][1] - m[1][1] * m[2][0]));

    return adj * (1 / det);
}
