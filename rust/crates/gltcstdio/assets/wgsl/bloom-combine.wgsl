struct Params {
    U: array<vec4<f32>, 8>,
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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn bloomCombine(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, balance: f32, normalization: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var normalization_1: f32;
    var bkgColor: vec4<f32>;
    var bloomColor: vec4<f32>;
    var added: vec3<f32>;
    var blended: vec3<f32>;
    var maxValue: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    balance_1 = balance;
    normalization_1 = normalization;
    let _e17 = uv_1;
    let _e21 = global.U[0];
    let _e24 = uv_1;
    let _e33 = textureSample(t_source1_, samp, ((vec2<f32>((_e17.x / _e21.x), _e24.y) / vec2(2f)) + vec2(0.5f)));
    bkgColor = _e33;
    let _e35 = uv_1;
    let _e39 = global.U[0];
    let _e42 = uv_1;
    let _e51 = textureSample(t_source2_, samp, ((vec2<f32>((_e35.x / _e39.x), _e42.y) / vec2(2f)) + vec2(0.5f)));
    bloomColor = _e51;
    let _e53 = bkgColor;
    let _e55 = bloomColor;
    let _e57 = intensity_1;
    let _e59 = bloomColor;
    added = (_e53.xyz + ((_e55.xyz * _e57) * _e59.w));
    let _e64 = bkgColor;
    let _e66 = bloomColor;
    let _e68 = intensity_1;
    let _e69 = bloomColor;
    blended = mix(_e64.xyz, _e66.xyz, vec3(min((_e68 * _e69.w), 1f)));
    let _e78 = intensity_1;
    let _e81 = balance_1;
    maxValue = mix((1f + _e78), 1f, _e81);
    let _e84 = added;
    let _e85 = blended;
    let _e86 = balance_1;
    let _e91 = maxValue;
    let _e93 = normalization_1;
    let _e95 = (mix(_e84, _e85, vec3(_e86)) * mix(1f, (1f / _e91), _e93));
    let _e96 = bkgColor;
    return vec4<f32>(_e95.x, _e95.y, _e95.z, _e96.w);
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[5];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e77 = bloomCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, _e75.x);
    fragColor = _e77;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
