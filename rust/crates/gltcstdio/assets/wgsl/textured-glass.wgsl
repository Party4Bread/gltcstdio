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

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e18 = u_1;
    return vec2<f32>(fract((sin(dot(_e8.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e18.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var rnd: vec2<f32>;
    var len: f32;

    p_1 = p;
    let _e8 = p_1;
    let _e9 = hash22b(_e8);
    rnd = (_e9 - vec2(0.5f));
    let _e14 = rnd;
    len = length(_e14);
    let _e17 = len;
    if (_e17 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e23 = rnd;
        let _e24 = len;
        return (_e23 / vec2(_e24));
    }
}

fn dotGridGradient(g: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_1: vec2<f32>;
    var u_3: vec2<f32>;

    g_1 = g;
    u_3 = u_2;
    let _e10 = u_3;
    let _e11 = g_1;
    let _e13 = g_1;
    let _e14 = rndUnit(_e13);
    return dot((_e10 - _e11), _e14);
}

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e12 = a_1;
    let _e13 = b_1;
    let _e16 = k_1;
    return mix(_e12, _e13, smoothstep(0f, 1f, _e16));
}

fn perlinNoise(p_2: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var s: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_3 = p_2;
    let _e12 = p_3;
    f = floor(_e12);
    let _e15 = p_3;
    let _e16 = f;
    d = (_e15 - _e16);
    let _e19 = f;
    let _e20 = p_3;
    let _e21 = dotGridGradient(_e19, _e20);
    let _e22 = f;
    let _e23 = s;
    let _e25 = p_3;
    let _e26 = dotGridGradient((_e22 + _e23), _e25);
    let _e27 = d;
    let _e29 = smix(_e21, _e26, _e27.x);
    ix0_ = _e29;
    let _e31 = f;
    let _e32 = s;
    let _e35 = p_3;
    let _e36 = dotGridGradient((_e31 + _e32.yx), _e35);
    let _e37 = f;
    let _e38 = s;
    let _e41 = p_3;
    let _e42 = dotGridGradient((_e37 + _e38.xx), _e41);
    let _e43 = d;
    let _e45 = smix(_e36, _e42, _e43.x);
    ix1_ = _e45;
    let _e48 = ix0_;
    let _e49 = ix1_;
    let _e50 = d;
    let _e52 = smix(_e48, _e49, _e50.y);
    return (0.5f + (_e52 * 0.5f));
}

fn getSurface(u_4: vec2<f32>) -> f32 {
    var u_5: vec2<f32>;

    u_5 = u_4;
    let _e9 = u_5;
    let _e10 = perlinNoise(_e9);
    let _e12 = u_5;
    let _e15 = perlinNoise((_e12 * 2.1223f));
    return (10f * (_e10 + (0.7f * _e15)));
}

fn getNormal(p_4: vec2<f32>) -> vec3<f32> {
    var p_5: vec2<f32>;
    var d_1: f32 = 0.001f;
    var y: f32;
    var yx: f32;
    var yz: f32;

    p_5 = p_4;
    let _e10 = p_5;
    let _e11 = getSurface(_e10);
    y = _e11;
    let _e13 = p_5;
    let _e15 = d_1;
    let _e17 = p_5;
    let _e20 = getSurface(vec2<f32>((_e13.x + _e15), _e17.y));
    yx = _e20;
    let _e22 = p_5;
    let _e24 = p_5;
    let _e26 = d_1;
    let _e29 = getSurface(vec2<f32>(_e22.x, (_e24.y + _e26)));
    yz = _e29;
    let _e31 = yx;
    let _e32 = y;
    let _e34 = d_1;
    let _e37 = yz;
    let _e38 = y;
    let _e40 = d_1;
    return normalize(vec3<f32>(((_e31 - _e32) / _e34), 1f, ((_e37 - _e38) / _e40)));
}

fn texturedGlass(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, intensity: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensity_1: f32;
    var t: vec2<f32>;
    var delta: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    intensity_1 = intensity;
    let _e14 = modelTransform_1;
    let _e16 = pos_1;
    t = (_naga_inverse_3x3_f32(_e14) * vec3<f32>(_e16.x, _e16.y, 1f)).xy;
    let _e24 = t;
    let _e27 = getNormal((_e24 * 10f));
    delta = _e27.xy;
    let _e30 = pos_1;
    let _e31 = delta;
    let _e32 = intensity_1;
    let _e40 = global.U[0];
    let _e43 = pos_1;
    let _e44 = delta;
    let _e45 = intensity_1;
    let _e58 = _mirror_wrap(((vec2<f32>(((_e30 + ((_e31 * _e32) * 0.1f)).x / _e40.x), (_e43 + ((_e44 * _e45) * 0.1f)).y) / vec2(2f)) + vec2(0.5f)));
    let _e59 = textureSample(t_source, samp, _e58);
    return _e59;
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e93 = texturedGlass((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x);
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
