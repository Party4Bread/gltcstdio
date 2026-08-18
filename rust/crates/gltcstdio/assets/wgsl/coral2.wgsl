struct Params {
    U: array<vec4<f32>, 10>,
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

fn getRGBCoefficients(k: f32, offset: f32) -> mat3x3<f32> {
    var k_1: f32;
    var offset_1: f32;
    var offset1_: f32 = 1.0471976f;
    var offset2_: f32;
    var kk: f32;
    var a: f32;
    var b: f32;
    var c: f32;

    k_1 = k;
    offset_1 = offset;
    let _e14 = offset1_;
    offset2_ = (_e14 * 2f);
    let _e18 = k_1;
    let _e19 = offset_1;
    kk = (_e18 + (_e19 * 3.1415927f));
    let _e24 = kk;
    a = sin(_e24);
    let _e27 = kk;
    let _e28 = offset1_;
    b = sin((_e27 + _e28));
    let _e32 = kk;
    let _e33 = offset2_;
    c = sin((_e32 + _e33));
    let _e37 = a;
    let _e38 = b;
    let _e39 = c;
    let _e40 = vec3<f32>(_e37, _e38, _e39);
    let _e41 = b;
    let _e42 = c;
    let _e43 = a;
    let _e44 = vec3<f32>(_e41, _e42, _e43);
    return mat3x3<f32>(vec3<f32>(_e40.x, _e40.y, _e40.z), vec3<f32>(_e44.x, _e44.y, _e44.z), vec3<f32>(0f, 0f, 0f));
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

fn coral2_(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, angle_2: f32, power: f32, balance: f32, offset_2: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var angle_3: f32;
    var power_1: f32;
    var balance_1: f32;
    var offset_3: f32;
    var p: vec2<f32>;
    var delta: f32 = 0.001f;
    var d: vec2<f32>;
    var N: i32;
    var rot: mat2x2<f32>;
    var exponent: f32;
    var i: i32 = 0i;
    var rgb: vec3<f32>;
    var dir: vec2<f32>;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    angle_3 = angle_2;
    power_1 = power;
    balance_1 = balance;
    offset_3 = offset_2;
    let _e20 = uv_1;
    p = _e20;
    let _e24 = delta;
    d = vec2<f32>(_e24, 0f);
    let _e28 = intensity_1;
    N = i32((abs(_e28) * 500f));
    let _e34 = angle_3;
    let _e35 = rotation2_(_e34);
    rot = _e35;
    let _e38 = power_1;
    exponent = pow(4f, _e38);
    loop {
        let _e43 = i;
        let _e44 = N;
        if !((_e43 < _e44)) {
            break;
        }
        {
            let _e50 = p;
            let _e54 = global.U[0];
            let _e57 = p;
            let _e66 = textureSample(t_source, samp, ((vec2<f32>((_e50.x / _e54.x), _e57.y) / vec2(2f)) + vec2(0.5f)));
            rgb = _e66.xyz;
            let _e69 = i;
            let _e71 = balance_1;
            let _e73 = offset_3;
            let _e74 = getRGBCoefficients((f32(_e69) * _e71), _e73);
            let _e75 = rgb;
            dir = (_e74 * (_e75 - vec3(0.5f))).xy;
            let _e82 = p;
            let _e83 = intensity_1;
            let _e85 = delta;
            let _e87 = rgb;
            let _e89 = exponent;
            let _e92 = rot;
            let _e93 = dir;
            p = (_e82 + (((sign(_e83) * _e85) * pow(length(_e87), _e89)) * (_e92 * _e93)));
        }
        continuing {
            let _e47 = i;
            i = (_e47 + 1i);
        }
    }
    let _e97 = p;
    let _e101 = global.U[0];
    let _e104 = p;
    let _e113 = textureSample(t_source, samp, ((vec2<f32>((_e97.x / _e101.x), _e104.y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e113;
    let _e115 = outColor;
    return _e115;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e84 = coral2_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x);
    fragColor = _e84;
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
