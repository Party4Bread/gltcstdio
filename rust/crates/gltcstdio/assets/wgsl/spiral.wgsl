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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn spiral(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count: i32, intensity: f32, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var texTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var angle: f32;
    var ratio: f32;
    var scale360_: f32;
    var a: f32;
    var s: f32;
    var local: f32;
    var local_1: f32;
    var w: vec2<f32>;
    var fcount: f32;
    var local_2: f32;
    var local_3: f32;
    var coord: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_1 = count;
    intensity_1 = intensity;
    texTransform_1 = texTransform;
    let _e18 = uv_1;
    u_2 = _e18;
    let _e20 = u_2;
    d = length(_e20);
    let _e23 = u_2;
    let _e25 = u_2;
    angle = atan2(_e23.y, _e25.x);
    let _e29 = angle;
    angle = (_e29 - (floor((_e29 / 6.2831855f)) * 6.2831855f));
    let _e35 = sourceDim_1;
    let _e37 = sourceDim_1;
    ratio = (_e35.x / _e37.y);
    let _e42 = intensity_1;
    let _e43 = intensity_1;
    scale360_ = (1000f / (_e42 * _e43));
    let _e47 = angle;
    a = (_e47 / 6.2831855f);
    let _e51 = scale360_;
    let _e52 = a;
    s = pow(_e51, _e52);
    let _e55 = ratio;
    if (_e55 < 1f) {
        local = 1f;
    } else {
        let _e59 = ratio;
        local = _e59;
    }
    let _e61 = local;
    let _e62 = angle;
    let _e66 = ratio;
    if (_e66 < 1f) {
        let _e70 = ratio;
        local_1 = (1f / _e70);
    } else {
        local_1 = 1f;
    }
    let _e74 = local_1;
    let _e75 = d;
    let _e76 = s;
    let _e80 = scale360_;
    w = vec2<f32>(((_e61 * _e62) / 3.1415927f), ((_e74 * log((_e75 * _e76))) / log(_e80)));
    let _e85 = count_1;
    fcount = f32(_e85);
    let _e89 = fcount;
    let _e91 = w;
    let _e95 = w;
    let _e97 = fcount;
    let _e98 = (_e95.y * _e97);
    let _e99 = ratio;
    if (_e99 < 1f) {
        let _e103 = ratio;
        local_2 = (1f / _e103);
    } else {
        local_2 = 1f;
    }
    let _e107 = local_2;
    let _e108 = fcount;
    let _e109 = (_e107 * _e108);
    let _e115 = ratio;
    if (_e115 < 1f) {
        let _e119 = ratio;
        local_3 = (1f / _e119);
    } else {
        local_3 = 1f;
    }
    let _e123 = local_3;
    coord = vec2<f32>(((4f * _e89) * _e91.x), ((2f * (_e98 - (floor((_e98 / _e109)) * _e109))) - (_e123 * 1f)));
    let _e129 = texTransform_1;
    let _e131 = coord;
    let _e132 = tf(_naga_inverse_3x3_f32(_e129), _e131);
    let _e136 = global.U[0];
    let _e139 = texTransform_1;
    let _e141 = coord;
    let _e142 = tf(_naga_inverse_3x3_f32(_e139), _e141);
    let _e151 = _mirror_wrap(((vec2<f32>((_e132.x / _e136.x), _e142.y) / vec2(2f)) + vec2(0.5f)));
    let _e152 = textureSample(t_source, samp, _e151);
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = spiral((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
