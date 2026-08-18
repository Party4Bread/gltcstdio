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

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
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

fn tf(m: mat3x3<f32>, u_4: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_5: vec2<f32>;

    m_1 = m;
    u_5 = u_4;
    let _e10 = m_1;
    let _e11 = u_5;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn pencil(uv: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, power: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var power_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var bkg_2: vec4<f32>;
    var delta: f32 = 0.005f;
    var step: vec2<f32>;
    var grad: vec2<f32>;
    var dir: vec2<f32>;
    var u_6: vec2<f32>;
    var k_2: f32;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    color1_1 = color1_;
    color2_1 = color2_;
    power_1 = power;
    modelTransform_1 = modelTransform;
    let _e18 = uv_1;
    let _e22 = global.U[0];
    let _e25 = uv_1;
    let _e34 = textureSample(t_source, samp, ((vec2<f32>((_e18.x / _e22.x), _e25.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e34;
    let _e38 = delta;
    step = vec2<f32>((_e38 / 2f), 0f);
    let _e44 = uv_1;
    let _e45 = step;
    let _e50 = global.U[0];
    let _e53 = uv_1;
    let _e54 = step;
    let _e64 = textureSample(t_source, samp, ((vec2<f32>(((_e44 + _e45).x / _e50.x), (_e53 + _e54).y) / vec2(2f)) + vec2(0.5f)));
    let _e66 = luma(_e64.xyz);
    let _e67 = uv_1;
    let _e68 = step;
    let _e73 = global.U[0];
    let _e76 = uv_1;
    let _e77 = step;
    let _e87 = textureSample(t_source, samp, ((vec2<f32>(((_e67 - _e68).x / _e73.x), (_e76 - _e77).y) / vec2(2f)) + vec2(0.5f)));
    let _e89 = luma(_e87.xyz);
    let _e91 = uv_1;
    let _e92 = step;
    let _e98 = global.U[0];
    let _e101 = uv_1;
    let _e102 = step;
    let _e113 = textureSample(t_source, samp, ((vec2<f32>(((_e91 + _e92.yx).x / _e98.x), (_e101 + _e102.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e115 = luma(_e113.xyz);
    let _e116 = uv_1;
    let _e117 = step;
    let _e123 = global.U[0];
    let _e126 = uv_1;
    let _e127 = step;
    let _e138 = textureSample(t_source, samp, ((vec2<f32>(((_e116 - _e117.yx).x / _e123.x), (_e126 - _e127.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e140 = luma(_e138.xyz);
    grad = vec2<f32>((_e66 - _e89), (_e115 - _e140));
    let _e144 = modelTransform_1;
    let _e146 = grad;
    let _e147 = tf(_naga_inverse_3x3_f32(_e144), _e146);
    dir = _e147;
    let _e149 = uv_1;
    let _e150 = dir;
    u_6 = ((_e149 * _e150) * 3f);
    let _e155 = modelTransform_1;
    let _e157 = uv_1;
    let _e158 = tf(_naga_inverse_3x3_f32(_e155), _e157);
    let _e161 = grad;
    let _e163 = power_1;
    let _e166 = perlinNoise(((_e158 * 100f) * pow(length(_e161), _e163)));
    k_2 = _e166;
    let _e168 = color2_1;
    let _e169 = color1_1;
    let _e170 = k_2;
    col = mix(_e168, _e169, vec4(_e170));
    let _e174 = bkg_2;
    let _e175 = col;
    let _e176 = mergeColor(_e174, _e175);
    return _e176;
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
    let _e69 = global.U[6];
    let _e72 = global.U[7];
    let _e76 = global.U[8];
    let _e77 = _e76.xyz;
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e99 = pencil((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66, _e69, _e72.x, mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)));
    fragColor = _e99;
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
