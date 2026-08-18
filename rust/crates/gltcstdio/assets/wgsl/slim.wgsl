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

fn slim(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, intensity: f32, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensity_1: f32;
    var sourceDim_1: vec2<f32>;
    var u_2: vec2<f32>;
    var ratio: f32;
    var xMin: f32;
    var xs: f32;
    var s: f32;
    var absX: f32;
    var x2_: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    intensity_1 = intensity;
    sourceDim_1 = sourceDim;
    let _e16 = modelTransform_1;
    let _e18 = pos_1;
    u_2 = (_naga_inverse_3x3_f32(_e16) * vec3<f32>(_e18.x, _e18.y, 1f)).xy;
    let _e26 = sourceDim_1;
    let _e28 = sourceDim_1;
    ratio = (_e26.x / _e28.y);
    let _e33 = intensity_1;
    xMin = (0.5f - (_e33 * 0.5f));
    let _e38 = xMin;
    let _e39 = u_2;
    let _e41 = u_2;
    let _e45 = xMin;
    xs = (_e38 + ((_e39.y * _e41.y) * (0.5f - _e45)));
    let _e50 = u_2;
    s = sign(_e50.x);
    let _e54 = u_2;
    let _e57 = ratio;
    absX = (abs(_e54.x) / _e57);
    let _e60 = ratio;
    let _e61 = absX;
    let _e65 = xs;
    x2_ = (((_e60 * _e61) * 0.5f) / _e65);
    let _e69 = s;
    let _e70 = x2_;
    u_2.x = (_e69 * _e70);
    let _e72 = modelTransform_1;
    let _e73 = u_2;
    let _e74 = tf(_e72, _e73);
    u_2 = _e74;
    let _e75 = u_2;
    let _e79 = global.U[0];
    let _e82 = u_2;
    let _e91 = _mirror_wrap(((vec2<f32>((_e75.x / _e79.x), _e82.y) / vec2(2f)) + vec2(0.5f)));
    let _e92 = textureSample(t_source, samp, _e91);
    return _e92;
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
    let _e91 = global.U[9];
    let _e95 = global.U[4];
    let _e97 = slim((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.xy);
    fragColor = _e97;
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
