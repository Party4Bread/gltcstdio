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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn simpleStretch(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var radius: f32 = 1f;
    var maxRadius: f32;
    var p: f32 = 1.1f;
    var dilation: f32;
    var a: f32;
    var coord: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    modelTransform_1 = modelTransform;
    let _e14 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e14);
    let _e17 = invM;
    let _e18 = uv_1;
    let _e19 = tf(_e17, _e18);
    u_2 = _e19;
    let _e21 = u_2;
    d = length(_e21);
    let _e28 = invM[0];
    maxRadius = (length(_e28.xy) * 0.75f);
    let _e37 = intensity_1;
    dilation = pow(2f, (_e37 / 20f));
    let _e42 = d;
    let _e43 = radius;
    if (_e42 >= _e43) {
        {
            let _e45 = maxRadius;
            let _e46 = dilation;
            let _e50 = maxRadius;
            let _e51 = radius;
            let _e53 = p;
            a = ((_e45 * (_e46 - 1f)) * pow((_e50 - _e51), -(_e53)));
            let _e58 = dilation;
            let _e59 = a;
            let _e60 = d;
            let _e61 = radius;
            let _e63 = p;
            let _e66 = d;
            dilation = (_e58 - ((_e59 * pow((_e60 - _e61), _e63)) / _e66));
        }
    }
    let _e69 = modelTransform_1;
    let _e70 = dilation;
    let _e71 = u_2;
    let _e73 = tf(_e69, (_e70 * _e71));
    coord = _e73;
    let _e75 = coord;
    let _e79 = global.U[0];
    let _e82 = coord;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e93 = simpleStretch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)));
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
