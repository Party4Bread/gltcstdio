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
var t_source: texture_2d<f32>;

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn tangentCircleStreak(uv: vec2<f32>, outPos: vec2<f32>, count: i32, modelTransform: mat3x3<f32>, offset: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offset_1: f32;
    var u_2: vec2<f32>;
    var h: f32;
    var c: vec2<f32>;
    var dv: vec2<f32>;
    var angle: f32;
    var N: f32;
    var au: f32;
    var a0_: f32;
    var a1_: f32;
    var k: f32;
    var uv1_: vec2<f32>;
    var uv2_: vec2<f32>;
    var col0_: vec4<f32>;
    var col1_: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_1 = count;
    modelTransform_1 = modelTransform;
    offset_1 = offset;
    let _e16 = modelTransform_1;
    let _e18 = uv_1;
    u_2 = (_naga_inverse_3x3_f32(_e16) * vec3<f32>(_e18.x, _e18.y, 1f)).xy;
    let _e26 = u_2;
    let _e27 = u_2;
    let _e30 = u_2;
    h = (dot(_e26, _e27) / (2f * _e30.y));
    let _e36 = h;
    c = vec2<f32>(0f, _e36);
    let _e39 = u_2;
    let _e40 = c;
    dv = (_e39 - _e40);
    let _e43 = dv;
    let _e45 = dv;
    angle = atan2(_e43.y, _e45.x);
    let _e49 = count_1;
    N = f32(_e49);
    let _e55 = N;
    au = (6.2831855f / _e55);
    let _e58 = angle;
    let _e59 = au;
    let _e61 = offset_1;
    let _e64 = offset_1;
    let _e66 = au;
    a0_ = ((floor(((_e58 / _e59) - _e61)) + _e64) * _e66);
    let _e69 = angle;
    let _e70 = au;
    let _e72 = offset_1;
    let _e75 = offset_1;
    let _e77 = au;
    a1_ = ((ceil(((_e69 / _e70) - _e72)) + _e75) * _e77);
    let _e80 = angle;
    let _e81 = a0_;
    let _e83 = au;
    k = ((_e80 - _e81) / _e83);
    let _e86 = modelTransform_1;
    let _e87 = c;
    let _e88 = h;
    let _e89 = a0_;
    let _e91 = a0_;
    let _e96 = tf(_e86, (_e87 + (_e88 * vec2<f32>(cos(_e89), sin(_e91)))));
    uv1_ = _e96;
    let _e98 = modelTransform_1;
    let _e99 = c;
    let _e100 = h;
    let _e101 = a1_;
    let _e103 = a1_;
    let _e108 = tf(_e98, (_e99 + (_e100 * vec2<f32>(cos(_e101), sin(_e103)))));
    uv2_ = _e108;
    let _e110 = uv1_;
    let _e114 = global.U[0];
    let _e117 = uv1_;
    let _e126 = textureSample(t_source, samp, ((vec2<f32>((_e110.x / _e114.x), _e117.y) / vec2(2f)) + vec2(0.5f)));
    col0_ = _e126;
    let _e128 = uv2_;
    let _e132 = global.U[0];
    let _e135 = uv2_;
    let _e144 = textureSample(t_source, samp, ((vec2<f32>((_e128.x / _e132.x), _e135.y) / vec2(2f)) + vec2(0.5f)));
    col1_ = _e144;
    let _e146 = col0_;
    let _e147 = col1_;
    let _e148 = k;
    outCol = mix(_e146, _e147, vec4(_e148));
    let _e152 = outCol;
    return _e152;
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
    let _e71 = global.U[7];
    let _e72 = _e71.xyz;
    let _e75 = global.U[8];
    let _e76 = _e75.xyz;
    let _e79 = global.U[9];
    let _e80 = _e79.xyz;
    let _e96 = global.U[10];
    let _e98 = tangentCircleStreak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x);
    fragColor = _e98;
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
