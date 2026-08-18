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
var t_source: texture_2d<f32>;

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e16 = sa;
    let _e18 = ca;
    return mat2x2<f32>(vec2<f32>(_e14, _e15), vec2<f32>(-(_e16), _e18));
}

fn hueGrad(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, delta: f32, threshold: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var delta_1: f32;
    var threshold_1: f32;
    var g: f32;
    var pixel: f32;
    var radius: f32;
    var maxRadius: f32 = 0f;
    var dir: vec2<f32> = vec2<f32>(0f, 1f);
    var rot: mat2x2<f32>;
    var deltaRadius: f32;
    var MAX_ITER: i32 = 2000i;
    var i: i32 = 0i;
    var u: vec2<f32>;
    var g2_: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    delta_1 = delta;
    threshold_1 = threshold;
    let _e16 = uv_1;
    let _e20 = global.U[0];
    let _e23 = uv_1;
    let _e33 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e16.x / _e20.x), _e23.y) / vec2(2f)) + vec2(0.5f)), 0f);
    let _e35 = luma(_e33.xyz);
    g = _e35;
    let _e38 = sourceDim_1;
    pixel = (2f / _e38.y);
    let _e42 = pixel;
    radius = _e42;
    let _e51 = rotation2_(1f);
    rot = _e51;
    let _e53 = pixel;
    deltaRadius = (_e53 * 0.3333f);
    let _e61 = uv_1;
    let _e62 = radius;
    let _e63 = dir;
    u = (_e61 + (_e62 * _e63));
    loop {
        let _e67 = i;
        let _e68 = MAX_ITER;
        if !((_e67 < _e68)) {
            break;
        }
        {
            let _e71 = u;
            let _e75 = global.U[0];
            let _e78 = u;
            let _e88 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e71.x / _e75.x), _e78.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e90 = luma(_e88.xyz);
            g2_ = _e90;
            let _e92 = g;
            let _e93 = g2_;
            let _e96 = threshold_1;
            if (abs((_e92 - _e93)) > _e96) {
                break;
            }
            let _e98 = radius;
            maxRadius = _e98;
            let _e99 = radius;
            let _e100 = deltaRadius;
            radius = (_e99 + _e100);
            let _e102 = rot;
            let _e103 = dir;
            dir = (_e102 * _e103);
            let _e105 = uv_1;
            let _e106 = radius;
            let _e107 = dir;
            u = (_e105 + (_e106 * _e107));
            let _e110 = i;
            i = (_e110 + 1i);
        }
    }
    let _e113 = maxRadius;
    let _e114 = vec3(_e113);
    return vec4<f32>(_e114.x, _e114.y, _e114.z, 1f);
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e76 = hueGrad((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x);
    fragColor = _e76;
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
