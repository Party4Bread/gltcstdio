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

fn rgRand3_(v: vec2<f32>) -> vec3<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;
    var z: f32;

    v_1 = v;
    let _e7 = v_1;
    x = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = y;
    let _e32 = v_1;
    z = fract((sin(dot(vec2<f32>(_e31, _e32.y), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e44 = x;
    let _e45 = y;
    let _e46 = z;
    return vec3<f32>(_e44, _e45, _e46);
}

fn rgVaryNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_1;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn rgVaryVec3NoiseSmoothly(n: vec3<f32>, k_2: f32) -> vec3<f32> {
    var n_1: vec3<f32>;
    var k_3: f32;

    n_1 = n;
    k_3 = k_2;
    let _e9 = n_1;
    let _e11 = k_3;
    let _e12 = rgVaryNoiseSmoothly(_e9.x, _e11);
    let _e13 = n_1;
    let _e15 = k_3;
    let _e16 = rgVaryNoiseSmoothly(_e13.y, _e15);
    let _e17 = n_1;
    let _e19 = k_3;
    let _e20 = rgVaryNoiseSmoothly(_e17.z, _e19);
    return vec3<f32>(_e12, _e16, _e20);
}

fn rgRand3relSeeded(co: vec2<f32>, seed: f32) -> vec3<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rgRand3_(_e9);
    let _e11 = seed_1;
    let _e12 = rgVaryVec3NoiseSmoothly(_e10, _e11);
    return (_e12 - vec3(0.5f));
}

fn rgInterpolatedRand3Seeded(v_2: vec2<f32>, seed_2: f32) -> vec3<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var sfractY: f32;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e11 = v_3;
    sfractY = smoothstep(0f, 1f, fract(_e11.y));
    let _e16 = v_3;
    let _e18 = seed_3;
    let _e19 = rgRand3relSeeded(floor(_e16), _e18);
    let _e20 = v_3;
    let _e23 = v_3;
    let _e27 = seed_3;
    let _e28 = rgRand3relSeeded(vec2<f32>(floor(_e20.x), ceil(_e23.y)), _e27);
    let _e29 = sfractY;
    let _e32 = v_3;
    let _e35 = v_3;
    let _e39 = seed_3;
    let _e40 = rgRand3relSeeded(vec2<f32>(ceil(_e32.x), floor(_e35.y)), _e39);
    let _e41 = v_3;
    let _e43 = seed_3;
    let _e44 = rgRand3relSeeded(ceil(_e41), _e43);
    let _e45 = sfractY;
    let _e50 = v_3;
    return mix(mix(_e19, _e28, vec3(_e29)), mix(_e40, _e44, vec3(_e45)), vec3(smoothstep(0f, 1f, fract(_e50.x))));
}

fn randomGradient(pos: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, colorVariability: f32, randomSeed: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var colorVariability_1: f32;
    var randomSeed_1: f32;
    var rndCol: vec3<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    color1_1 = color1_;
    colorVariability_1 = colorVariability;
    randomSeed_1 = randomSeed;
    let _e16 = pos_1;
    let _e19 = randomSeed_1;
    let _e20 = rgInterpolatedRand3Seeded(vec2<f32>(0f, _e16.y), _e19);
    let _e21 = colorVariability_1;
    let _e23 = color1_1;
    rndCol = ((_e20 * _e21) + _e23.xyz);
    let _e27 = rndCol;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, 1f);
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e68 = global.U[6];
    let _e72 = global.U[7];
    let _e74 = randomGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68.x, _e72.x);
    fragColor = _e74;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
