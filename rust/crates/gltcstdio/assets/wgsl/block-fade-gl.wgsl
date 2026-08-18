struct Params {
    U: array<vec4<f32>, 17>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn blockFadeGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, regularity: f32, randomSeed: f32, color1_: vec4<f32>, color2_: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var regularity_1: f32;
    var randomSeed_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var forwardM: mat3x3<f32>;
    var u: vec2<f32>;
    var scaleX: f32;
    var rnd1_: vec2<f32>;
    var xOffset: f32;
    var col: vec4<f32>;
    var dx: f32;
    var rnd2_: vec2<f32>;
    var variability: f32;
    var kx: f32;
    var scanIntensity: f32 = 0.3f;
    var scanK: f32;
    var overCol: vec4<f32>;
    var alpha: f32;
    var blend: f32;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    regularity_1 = regularity;
    randomSeed_1 = randomSeed;
    color1_1 = color1_;
    color2_1 = color2_;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    forwardM = _naga_inverse_3x3_f32(_e24);
    let _e27 = forwardM;
    let _e28 = pos_1;
    u = (_e27 * vec3<f32>(_e28.x, _e28.y, 1f)).xy;
    let _e40 = forwardM[0][0];
    let _e45 = forwardM[1][0];
    scaleX = length(vec2<f32>(_e40, _e45));
    let _e49 = u;
    let _e51 = u;
    let _e55 = randomSeed_1;
    let _e56 = rand2relSeeded(floor(vec2<f32>(_e49.y, _e51.y)), _e55);
    rnd1_ = _e56;
    let _e59 = rnd1_;
    xOffset = floor(((15f * _e59.x) + 0.5f));
    let _e66 = pos_1;
    let _e70 = global.U[0];
    let _e73 = pos_1;
    let _e82 = textureSample(t_source, samp, ((vec2<f32>((_e66.x / _e70.x), _e73.y) / vec2(2f)) + vec2(0.5f)));
    col = _e82;
    let _e84 = xOffset;
    let _e85 = u;
    dx = floor((_e84 - _e85.x));
    let _e90 = dx;
    let _e91 = u;
    let _e95 = randomSeed_1;
    let _e96 = rand2relSeeded(vec2<f32>(_e90, floor(_e91.y)), _e95);
    rnd2_ = _e96;
    let _e99 = regularity_1;
    variability = (1f - _e99);
    let _e102 = dx;
    let _e103 = rnd2_;
    let _e105 = variability;
    let _e109 = dx;
    if ((_e102 + (((_e103.y * _e105) * 400f) / abs(_e109))) <= 0f) {
        let _e115 = col;
        return _e115;
    }
    let _e117 = dx;
    let _e118 = scaleX;
    kx = clamp((1f - (_e117 / _e118)), 0f, 1f);
    let _e128 = scanIntensity;
    let _e130 = scanIntensity;
    let _e132 = u;
    scanK = ((1f - _e128) + (_e130 * cos(((3.1415927f * fract(_e132.x)) * 8f))));
    let _e142 = color1_1;
    let _e143 = color2_1;
    let _e144 = kx;
    let _e147 = scanK;
    let _e148 = scanK;
    let _e149 = scanK;
    overCol = (mix(_e142, _e143, vec4(_e144)) * vec4<f32>(_e147, _e148, _e149, 1f));
    let _e156 = kx;
    let _e158 = dampening_1;
    alpha = clamp((1f - ((1f - _e156) * _e158)), 0f, 1f);
    let _e165 = intensity_1;
    let _e166 = alpha;
    blend = (_e165 * _e166);
    let _e169 = col;
    let _e170 = overCol;
    let _e171 = blend;
    outCol = mix(_e169, _e170, vec4(_e171));
    let _e175 = outCol;
    return _e175;
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
    let _e66 = global.U[8];
    let _e70 = global.U[9];
    let _e74 = global.U[10];
    let _e78 = global.U[11];
    let _e82 = global.U[12];
    let _e85 = global.U[13];
    let _e88 = global.U[14];
    let _e89 = _e88.xyz;
    let _e92 = global.U[15];
    let _e93 = _e92.xyz;
    let _e96 = global.U[16];
    let _e97 = _e96.xyz;
    let _e111 = blockFadeGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82, _e85, mat3x3<f32>(vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z), vec3<f32>(_e97.x, _e97.y, _e97.z)));
    fragColor = _e111;
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
