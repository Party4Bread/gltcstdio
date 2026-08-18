struct Params {
    U: array<vec4<f32>, 9>,
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
@group(0) @binding(2) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn pixelate(uv: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, pixelAspectRatio: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var pixelAspectRatio_1: f32;
    var u: vec2<f32>;
    var local: vec2<f32>;
    var pixDim: vec2<f32>;
    var pix: vec2<f32>;
    var v: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    pixelAspectRatio_1 = pixelAspectRatio;
    let _e14 = modelTransform_1;
    let _e16 = uv_1;
    u = (_naga_inverse_3x3_f32(_e14) * vec3<f32>(_e16.x, _e16.y, 1f)).xy;
    let _e24 = pixelAspectRatio_1;
    if (_e24 >= 1f) {
        let _e27 = pixelAspectRatio_1;
        local = vec2<f32>(_e27, 1f);
    } else {
        let _e32 = pixelAspectRatio_1;
        local = vec2<f32>(1f, (1f / _e32));
    }
    let _e36 = local;
    pixDim = _e36;
    let _e38 = u;
    let _e39 = pixDim;
    let _e45 = pixDim;
    pix = (floor(((_e38 / _e39) + vec2(0.5f))) * _e45);
    let _e48 = modelTransform_1;
    let _e49 = pix;
    let _e50 = _e49.xy;
    v = (_e48 * vec3<f32>(_e50.x, _e50.y, 1f)).xy;
    let _e58 = v;
    let _e62 = global.U[0];
    let _e65 = v;
    let _e74 = _mirror_wrap(((vec2<f32>((_e58.x / _e62.x), _e65.y) / vec2(2f)) + vec2(0.5f)));
    let _e75 = textureSample(t_source, samp, _e74);
    return _e75;
}

fn main_1() {
    let _e8 = global.U[1];
    let _e9 = _e8.xyz;
    let _e12 = global.U[2];
    let _e13 = _e12.xyz;
    let _e16 = global.U[3];
    let _e17 = _e16.xyz;
    let _e32 = v_uv_1;
    let _e40 = global.U[0];
    let _e44 = (((_e32 - vec2(0.5f)) * 2f) * vec2<f32>(_e40.x, 1f));
    let _e51 = v_uv_1;
    let _e59 = global.U[0];
    let _e66 = global.U[6];
    let _e67 = _e66.xyz;
    let _e70 = global.U[7];
    let _e71 = _e70.xyz;
    let _e74 = global.U[8];
    let _e75 = _e74.xyz;
    let _e91 = global.U[4];
    let _e93 = pixelate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x);
    fragColor = _e93;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
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
