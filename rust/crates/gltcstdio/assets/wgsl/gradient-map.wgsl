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
var t_gradient: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e14 = c_1;
    let _e19 = c_1;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn gradientMap(pos: vec2<f32>, outPos: vec2<f32>, gradientDim: vec2<f32>, intensity: f32, mode: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var gradientDim_1: vec2<f32>;
    var intensity_1: f32;
    var mode_1: i32;
    var inc: vec4<f32>;
    var lum: f32;
    var ratio: f32;
    var local: f32;
    var x: f32;
    var gradCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    gradientDim_1 = gradientDim;
    intensity_1 = intensity;
    mode_1 = mode;
    let _e17 = pos_1;
    let _e21 = global.U[0];
    let _e24 = pos_1;
    let _e33 = textureSample(t_source, samp, ((vec2<f32>((_e17.x / _e21.x), _e24.y) / vec2(2f)) + vec2(0.5f)));
    inc = _e33;
    let _e35 = inc;
    let _e37 = luma(_e35.xyz);
    lum = _e37;
    let _e39 = gradientDim_1;
    let _e41 = gradientDim_1;
    ratio = (_e39.x / _e41.y);
    let _e45 = mode_1;
    if (_e45 == 0i) {
        let _e48 = ratio;
        let _e51 = gradientDim_1;
        local = (_e48 * (1f - (1f / _e51.x)));
    } else {
        let _e56 = ratio;
        local = _e56;
    }
    let _e58 = local;
    x = _e58;
    let _e60 = x;
    let _e62 = x;
    let _e63 = lum;
    let _e70 = global.U[0];
    let _e73 = x;
    let _e75 = x;
    let _e76 = lum;
    let _e88 = textureSample(t_gradient, samp, ((vec2<f32>((vec2<f32>(mix(-(_e60), _e62, _e63), 0f).x / _e70.x), vec2<f32>(mix(-(_e73), _e75, _e76), 0f).y) / vec2(2f)) + vec2(0.5f)));
    gradCol = _e88;
    let _e90 = inc;
    let _e91 = gradCol;
    let _e92 = intensity_1;
    return mix(_e90, _e91, vec4(_e92));
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
    let _e67 = global.U[4];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e78 = gradientMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.x, i32(_e75.x));
    fragColor = _e78;
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
