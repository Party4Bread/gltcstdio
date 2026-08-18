struct Params {
    U: array<vec4<f32>, 11>,
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
var t_displacement: texture_2d<f32>;
@group(0) @binding(3) 
var t_source1_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e10 = c_3;
    let _e14 = c_3;
    let _e19 = c_3;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn rubidium(pos: vec2<f32>, outPos: vec2<f32>, displacement_specified: i32, intensity: f32, balance: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var displacement_specified_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var local: vec4<f32>;
    var disp: vec4<f32>;
    var scale: f32;
    var u1_: vec2<f32>;
    var sR: f32;
    var center: vec2<f32>;
    var u2_: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    displacement_specified_1 = displacement_specified;
    intensity_1 = intensity;
    balance_1 = balance;
    modelTransform_1 = modelTransform;
    let _e19 = displacement_specified_1;
    if (_e19 == 1i) {
        let _e22 = modelTransform_1;
        let _e24 = pos_1;
        let _e25 = tf(_naga_inverse_3x3_f32(_e22), _e24);
        let _e29 = global.U[0];
        let _e32 = modelTransform_1;
        let _e34 = pos_1;
        let _e35 = tf(_naga_inverse_3x3_f32(_e32), _e34);
        let _e44 = _mirror_wrap(((vec2<f32>((_e25.x / _e29.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
        let _e45 = textureSample(t_displacement, samp, _e44);
        local = _e45;
    } else {
        let _e46 = modelTransform_1;
        let _e48 = pos_1;
        let _e49 = tf(_naga_inverse_3x3_f32(_e46), _e48);
        let _e53 = global.U[0];
        let _e56 = modelTransform_1;
        let _e58 = pos_1;
        let _e59 = tf(_naga_inverse_3x3_f32(_e56), _e58);
        let _e68 = _mirror_wrap(((vec2<f32>((_e49.x / _e53.x), _e59.y) / vec2(2f)) + vec2(0.5f)));
        let _e69 = textureSample(t_source1_, samp, _e68);
        local = _e69;
    }
    let _e71 = local;
    disp = _e71;
    let _e74 = intensity_1;
    let _e77 = disp;
    let _e79 = luma(_e77.xyz);
    scale = pow(2f, ((_e74 * 4f) * (_e79 - 0.5f)));
    let _e85 = pos_1;
    let _e86 = scale;
    u1_ = (_e85 * _e86);
    let _e90 = intensity_1;
    let _e93 = disp;
    sR = pow(2f, ((_e90 * 4f) * (_e93.x - 0.5f)));
    let _e101 = disp;
    let _e104 = disp;
    let _e109 = disp;
    center = ((1.5f * _e101.y) * vec2<f32>(cos((_e104.z * 6.2831855f)), (sin((_e109.z * 6.2831855f)) - 0.5f)));
    let _e119 = pos_1;
    let _e120 = center;
    let _e122 = sR;
    let _e124 = center;
    u2_ = (((_e119 - _e120) * _e122) + _e124);
    let _e127 = u1_;
    let _e128 = u2_;
    let _e129 = balance_1;
    let _e135 = global.U[0];
    let _e138 = u1_;
    let _e139 = u2_;
    let _e140 = balance_1;
    let _e151 = _mirror_wrap(((vec2<f32>((mix(_e127, _e128, vec2(_e129)).x / _e135.x), mix(_e138, _e139, vec2(_e140)).y) / vec2(2f)) + vec2(0.5f)));
    let _e152 = textureSample(t_source1_, samp, _e151);
    return _e152;
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
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e103 = rubidium((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)));
    fragColor = _e103;
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
