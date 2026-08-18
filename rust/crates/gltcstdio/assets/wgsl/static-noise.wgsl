struct Params {
    U: array<vec4<f32>, 18>,
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

fn bc(x: f32, brightness: f32, contrast: f32) -> f32 {
    var x_1: f32;
    var brightness_1: f32;
    var contrast_1: f32;
    var y: f32;

    x_1 = x;
    brightness_1 = brightness;
    contrast_1 = contrast;
    let _e12 = x_1;
    let _e13 = brightness_1;
    y = (_e12 * (_e13 + 1f));
    let _e18 = y;
    let _e21 = contrast_1;
    y = (((_e18 - 0.5f) * _e21) + 0.5f);
    let _e25 = y;
    return clamp(_e25, 0f, 1f);
}

fn ccontrast(x_2: f32, c: f32) -> f32 {
    var x_3: f32;
    var c_1: f32;

    x_3 = x_2;
    c_1 = c;
    let _e11 = x_3;
    let _e15 = c_1;
    return clamp((0.5f + ((_e11 - 0.5f) * (1f + _e15))), 0f, 1f);
}

fn colorSchemeF(rgb: vec3<f32>, k: f32) -> vec3<f32> {
    var rgb_1: vec3<f32>;
    var k_1: f32;
    var grey: f32;

    rgb_1 = rgb;
    k_1 = k;
    let _e10 = rgb_1;
    let _e12 = rgb_1;
    let _e15 = rgb_1;
    grey = (((_e10.x + _e12.y) + _e15.z) / 3f);
    let _e21 = k_1;
    if (_e21 < 0.2f) {
        let _e24 = rgb_1;
        let _e27 = grey;
        let _e29 = k_1;
        return mix(vec3(_e24.y), vec3(_e27), vec3((_e29 * 5f)));
    }
    let _e34 = k_1;
    if (_e34 < 0.4f) {
        let _e37 = grey;
        let _e39 = rgb_1;
        let _e40 = k_1;
        return mix(vec3(_e37), _e39, vec3(((_e40 - 0.2f) * 5f)));
    }
    let _e47 = rgb_1;
    return _e47;
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

fn smix(a: f32, b: f32, k_2: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_3: f32;

    a_1 = a;
    b_1 = b;
    k_3 = k_2;
    let _e12 = a_1;
    let _e13 = b_1;
    let _e16 = k_3;
    return mix(_e12, _e13, smoothstep(0f, 1f, _e16));
}

fn perlin(p_2: vec2<f32>) -> f32 {
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

fn perlin4_(p_4: vec2<f32>) -> f32 {
    var p_5: vec2<f32>;

    p_5 = p_4;
    let _e8 = p_5;
    let _e9 = perlin(_e8);
    let _e11 = p_5;
    let _e14 = perlin((_e11 * 2f));
    let _e18 = p_5;
    let _e21 = perlin((_e18 * 4f));
    let _e25 = p_5;
    let _e28 = perlin((_e25 * 8f));
    return ((((_e9 + (0.5f * _e14)) + (0.25f * _e21)) + (0.125f * _e28)) * 0.6f);
}

fn aRatio(a_2: f32) -> vec2<f32> {
    var a_3: f32;

    a_3 = a_2;
    let _e8 = a_3;
    let _e12 = a_3;
    return ((vec2<f32>(_e8, 1f) / vec2((1f + _e12))) * 2f);
}

fn hash1_(p_6: vec2<f32>, randomSeed: f32) -> f32 {
    var p_7: vec2<f32>;
    var randomSeed_1: f32;
    var a_4: vec2<f32>;
    var b_2: vec2<f32>;

    p_7 = p_6;
    randomSeed_1 = randomSeed;
    let _e10 = randomSeed_1;
    let _e13 = p_7;
    a_4 = fract(((_e10 - 145.3277f) * _e13.xy));
    let _e18 = a_4;
    let _e19 = a_4;
    let _e20 = a_4;
    b_2 = (_e18 + vec2(dot(_e19, (_e20 + vec2<f32>(-4.434f, 43.3371f)))));
    let _e30 = b_2;
    let _e32 = b_2;
    return fract((_e30.x * _e32.y));
}

fn noise1_(p_8: vec2<f32>, randomSeed_2: f32) -> f32 {
    var p_9: vec2<f32>;
    var randomSeed_3: f32;
    var s_1: vec2<f32> = vec2<f32>(1f, 0f);
    var f_1: vec2<f32>;
    var d_1: vec2<f32>;
    var h00_: f32;
    var h10_: f32;
    var h01_: f32;
    var h11_: f32;

    p_9 = p_8;
    randomSeed_3 = randomSeed_2;
    let _e14 = p_9;
    f_1 = floor(_e14);
    let _e17 = p_9;
    let _e18 = f_1;
    d_1 = (_e17 - _e18);
    let _e21 = f_1;
    let _e22 = randomSeed_3;
    let _e23 = hash1_(_e21, _e22);
    h00_ = _e23;
    let _e25 = f_1;
    let _e26 = s_1;
    let _e28 = randomSeed_3;
    let _e29 = hash1_((_e25 + _e26), _e28);
    h10_ = _e29;
    let _e31 = f_1;
    let _e32 = s_1;
    let _e35 = randomSeed_3;
    let _e36 = hash1_((_e31 + _e32.yx), _e35);
    h01_ = _e36;
    let _e38 = f_1;
    let _e39 = s_1;
    let _e42 = randomSeed_3;
    let _e43 = hash1_((_e38 + _e39.xx), _e42);
    h11_ = _e43;
    let _e45 = h00_;
    let _e46 = h10_;
    let _e49 = d_1;
    let _e53 = h01_;
    let _e54 = h11_;
    let _e57 = d_1;
    let _e63 = d_1;
    return mix(mix(_e45, _e46, smoothstep(0f, 1f, _e49.x)), mix(_e53, _e54, smoothstep(0f, 1f, _e57.x)), smoothstep(0f, 1f, _e63.y));
}

fn hashBanding(p_10: vec2<f32>, randomSeed_4: f32) -> f32 {
    var p_11: vec2<f32>;
    var randomSeed_5: f32;
    var k_4: f32;
    var a_5: vec2<f32>;
    var b_3: vec2<f32>;

    p_11 = p_10;
    randomSeed_5 = randomSeed_4;
    let _e10 = p_11;
    p_11 = (_e10 + vec2(5000f));
    let _e15 = randomSeed_5;
    k_4 = (10.11f + _e15);
    let _e18 = k_4;
    let _e19 = p_11;
    let _e22 = k_4;
    a_5 = (fract((_e18 * _e19)) * _e22);
    let _e25 = k_4;
    let _e26 = a_5;
    let _e29 = k_4;
    a_5 = (fract((_e25 * _e26)) * _e29);
    let _e31 = a_5;
    let _e33 = a_5;
    let _e34 = a_5;
    b_3 = (_e31 + vec2((0f * dot(_e33, _e34))));
    let _e40 = p_11;
    let _e42 = b_3;
    let _e48 = p_11;
    let _e50 = b_3;
    return abs((sin(((_e40.x * _e42.x) * 0.001f)) * sin(((_e48.y * _e50.y) * 0.001f))));
}

fn noiseBanding(p_12: vec2<f32>, randomSeed_6: f32) -> f32 {
    var p_13: vec2<f32>;
    var randomSeed_7: f32;
    var s_2: vec2<f32> = vec2<f32>(1f, 0f);
    var f_2: vec2<f32>;
    var d_2: vec2<f32>;
    var h00_1: f32;
    var h10_1: f32;
    var h01_1: f32;
    var h11_1: f32;

    p_13 = p_12;
    randomSeed_7 = randomSeed_6;
    let _e14 = p_13;
    f_2 = floor(_e14);
    let _e17 = p_13;
    let _e18 = f_2;
    d_2 = (_e17 - _e18);
    let _e21 = f_2;
    let _e22 = randomSeed_7;
    let _e23 = hashBanding(_e21, _e22);
    h00_1 = _e23;
    let _e25 = f_2;
    let _e26 = s_2;
    let _e28 = randomSeed_7;
    let _e29 = hashBanding((_e25 + _e26), _e28);
    h10_1 = _e29;
    let _e31 = f_2;
    let _e32 = s_2;
    let _e35 = randomSeed_7;
    let _e36 = hashBanding((_e31 + _e32.yx), _e35);
    h01_1 = _e36;
    let _e38 = f_2;
    let _e39 = s_2;
    let _e42 = randomSeed_7;
    let _e43 = hashBanding((_e38 + _e39.xx), _e42);
    h11_1 = _e43;
    let _e45 = h00_1;
    let _e46 = h10_1;
    let _e49 = d_2;
    let _e53 = h01_1;
    let _e54 = h11_1;
    let _e57 = d_2;
    let _e63 = d_2;
    return mix(mix(_e45, _e46, smoothstep(0f, 1f, _e49.x)), mix(_e53, _e54, smoothstep(0f, 1f, _e57.x)), smoothstep(0f, 1f, _e63.y));
}

fn hashMoireCurve(p_14: vec2<f32>, randomSeed_8: f32) -> f32 {
    var p_15: vec2<f32>;
    var randomSeed_9: f32;
    var a_6: vec2<f32>;
    var b_4: vec2<f32>;

    p_15 = p_14;
    randomSeed_9 = randomSeed_8;
    let _e12 = randomSeed_9;
    let _e21 = p_15;
    let _e25 = randomSeed_9;
    a_6 = ((vec2(10.11f) + (20f * sin((_e12 * vec2<f32>(0.1f, 0.166f))))) * ((_e21 + vec2(5000f)) + vec2(_e25)));
    let _e30 = a_6;
    let _e33 = a_6;
    let _e36 = a_6;
    b_4 = ((_e30 * 0.001f) + vec2(dot((_e33 * 0.001f), (_e36 * 0.001f))));
    let _e44 = p_15;
    let _e46 = b_4;
    let _e52 = p_15;
    let _e54 = b_4;
    return clamp((0.5f + (sin(((_e44.x * _e46.x) * 0.001f)) * sin(((_e52.y * _e54.y) * 0.001f)))), 0f, 1f);
}

fn noiseMoireCurve(p_16: vec2<f32>, randomSeed_10: f32) -> f32 {
    var p_17: vec2<f32>;
    var randomSeed_11: f32;
    var s_3: vec2<f32> = vec2<f32>(1f, 0f);
    var f_3: vec2<f32>;
    var d_3: vec2<f32>;
    var h00_2: f32;
    var h10_2: f32;
    var h01_2: f32;
    var h11_2: f32;

    p_17 = p_16;
    randomSeed_11 = randomSeed_10;
    let _e14 = p_17;
    f_3 = floor(_e14);
    let _e17 = p_17;
    let _e18 = f_3;
    d_3 = (_e17 - _e18);
    let _e21 = f_3;
    let _e22 = randomSeed_11;
    let _e23 = hashMoireCurve(_e21, _e22);
    h00_2 = _e23;
    let _e25 = f_3;
    let _e26 = s_3;
    let _e28 = randomSeed_11;
    let _e29 = hashMoireCurve((_e25 + _e26), _e28);
    h10_2 = _e29;
    let _e31 = f_3;
    let _e32 = s_3;
    let _e35 = randomSeed_11;
    let _e36 = hashMoireCurve((_e31 + _e32.yx), _e35);
    h01_2 = _e36;
    let _e38 = f_3;
    let _e39 = s_3;
    let _e42 = randomSeed_11;
    let _e43 = hashMoireCurve((_e38 + _e39.xx), _e42);
    h11_2 = _e43;
    let _e45 = h00_2;
    let _e46 = h10_2;
    let _e49 = d_3;
    let _e53 = h01_2;
    let _e54 = h11_2;
    let _e57 = d_3;
    let _e63 = d_3;
    return mix(mix(_e45, _e46, smoothstep(0f, 1f, _e49.x)), mix(_e53, _e54, smoothstep(0f, 1f, _e57.x)), smoothstep(0f, 1f, _e63.y));
}

fn hashRep(p_18: vec2<f32>, randomSeed_12: f32) -> f32 {
    var p_19: vec2<f32>;
    var randomSeed_13: f32;
    var a_7: vec2<f32>;
    var b_5: vec2<f32>;

    p_19 = p_18;
    randomSeed_13 = randomSeed_12;
    let _e11 = p_19;
    let _e13 = randomSeed_13;
    let _e17 = p_19;
    let _e19 = randomSeed_13;
    a_7 = fract(vec2<f32>((15.3f * (_e11.x + _e13)), ((60.15f * ((_e17.y - _e19) + 333.3f)) + 10.1f)));
    let _e29 = a_7;
    let _e31 = a_7;
    let _e33 = a_7;
    let _e37 = randomSeed_13;
    b_5 = (_e29 + vec2((1f * dot(_e31.yx, ((_e33 + vec2(100f)) + vec2(_e37))))));
    let _e45 = b_5;
    let _e47 = b_5;
    return fract((_e45.x * _e47.y));
}

fn noiseRep(p_20: vec2<f32>, randomSeed_14: f32) -> f32 {
    var p_21: vec2<f32>;
    var randomSeed_15: f32;
    var s_4: vec2<f32> = vec2<f32>(1f, 0f);
    var f_4: vec2<f32>;
    var d_4: vec2<f32>;
    var h00_3: f32;
    var h10_3: f32;
    var h01_3: f32;
    var h11_3: f32;

    p_21 = p_20;
    randomSeed_15 = randomSeed_14;
    let _e14 = p_21;
    f_4 = floor(_e14);
    let _e17 = p_21;
    let _e18 = f_4;
    d_4 = (_e17 - _e18);
    let _e21 = f_4;
    let _e22 = randomSeed_15;
    let _e23 = hashRep(_e21, _e22);
    h00_3 = _e23;
    let _e25 = f_4;
    let _e26 = s_4;
    let _e28 = randomSeed_15;
    let _e29 = hashRep((_e25 + _e26), _e28);
    h10_3 = _e29;
    let _e31 = f_4;
    let _e32 = s_4;
    let _e35 = randomSeed_15;
    let _e36 = hashRep((_e31 + _e32.yx), _e35);
    h01_3 = _e36;
    let _e38 = f_4;
    let _e39 = s_4;
    let _e42 = randomSeed_15;
    let _e43 = hashRep((_e38 + _e39.xx), _e42);
    h11_3 = _e43;
    let _e45 = h00_3;
    let _e46 = h10_3;
    let _e49 = d_4;
    let _e53 = h01_3;
    let _e54 = h11_3;
    let _e57 = d_4;
    let _e63 = d_4;
    return mix(mix(_e45, _e46, smoothstep(0f, 1f, _e49.x)), mix(_e53, _e54, smoothstep(0f, 1f, _e57.x)), smoothstep(0f, 1f, _e63.y));
}

fn staticNoiseF(u_4: vec2<f32>, k_5: f32, shapeAspectRatio: f32, randomSeed_16: f32) -> f32 {
    var u_5: vec2<f32>;
    var k_6: f32;
    var shapeAspectRatio_1: f32;
    var randomSeed_17: f32;
    var baseScale: f32 = 500f;
    var ar: vec2<f32>;

    u_5 = u_4;
    k_6 = k_5;
    shapeAspectRatio_1 = shapeAspectRatio;
    randomSeed_17 = randomSeed_16;
    let _e16 = shapeAspectRatio_1;
    let _e17 = aRatio(_e16);
    ar = _e17;
    let _e19 = k_6;
    if (_e19 < 0.25f) {
        let _e22 = u_5;
        let _e23 = baseScale;
        let _e25 = ar;
        let _e27 = randomSeed_17;
        let _e28 = noise1_(((_e22 * _e23) * _e25), _e27);
        let _e29 = u_5;
        let _e30 = baseScale;
        let _e32 = ar;
        let _e34 = randomSeed_17;
        let _e35 = noiseMoireCurve(((_e29 * _e30) * _e32), _e34);
        let _e36 = k_6;
        return mix(_e28, _e35, (_e36 * 4f));
    }
    let _e40 = k_6;
    if (_e40 < 0.5f) {
        let _e43 = u_5;
        let _e44 = baseScale;
        let _e46 = ar;
        let _e48 = randomSeed_17;
        let _e49 = noiseMoireCurve(((_e43 * _e44) * _e46), _e48);
        let _e50 = u_5;
        let _e51 = baseScale;
        let _e53 = ar;
        let _e55 = randomSeed_17;
        let _e56 = noiseRep(((_e50 * _e51) * _e53), _e55);
        let _e57 = k_6;
        return mix(_e49, _e56, ((_e57 - 0.25f) * 4f));
    }
    let _e63 = k_6;
    if (_e63 < 0.75f) {
        let _e66 = u_5;
        let _e67 = baseScale;
        let _e69 = ar;
        let _e71 = randomSeed_17;
        let _e72 = noiseRep(((_e66 * _e67) * _e69), _e71);
        let _e73 = u_5;
        let _e74 = baseScale;
        let _e76 = ar;
        let _e78 = randomSeed_17;
        let _e79 = noiseBanding(((_e73 * _e74) * _e76), _e78);
        let _e80 = k_6;
        return mix(_e72, _e79, ((_e80 - 0.5f) * 4f));
    } else {
        let _e86 = u_5;
        let _e87 = baseScale;
        let _e89 = ar;
        let _e91 = randomSeed_17;
        let _e92 = noiseBanding(((_e86 * _e87) * _e89), _e91);
        let _e93 = u_5;
        let _e94 = baseScale;
        let _e96 = ar;
        let _e98 = randomSeed_17;
        let _e99 = noise1_(((_e93 * _e94) * _e96), _e98);
        let _e100 = k_6;
        return mix(_e92, _e99, ((_e100 - 0.75f) * 4f));
    }
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn staticNoise(pos: vec2<f32>, outPos: vec2<f32>, mode: f32, intensity: f32, balance: f32, coverage: f32, brightness_2: f32, contrast_2: f32, colorScheme: f32, randomSeed_18: f32, variability: f32, shapeAspectRatio_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: f32;
    var intensity_1: f32;
    var balance_1: f32;
    var coverage_1: f32;
    var brightness_3: f32;
    var contrast_3: f32;
    var colorScheme_1: f32;
    var randomSeed_19: f32;
    var variability_1: f32;
    var shapeAspectRatio_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u_8: vec2<f32>;
    var scale: f32;
    var inCol: vec4<f32>;
    var alpha: f32;
    var local: f32;
    var delta: f32;
    var rnd_1: vec3<f32>;
    var rgb_2: vec3<f32>;
    var d_5: vec2<f32>;
    var baseCol: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    intensity_1 = intensity;
    balance_1 = balance;
    coverage_1 = coverage;
    brightness_3 = brightness_2;
    contrast_3 = contrast_2;
    colorScheme_1 = colorScheme;
    randomSeed_19 = randomSeed_18;
    variability_1 = variability;
    shapeAspectRatio_3 = shapeAspectRatio_2;
    modelTransform_1 = modelTransform;
    let _e32 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e32);
    let _e35 = invModelTransform;
    let _e36 = pos_1;
    let _e37 = tf(_e35, _e36);
    u_8 = _e37;
    let _e41 = invModelTransform[0];
    scale = length(_e41.xy);
    let _e45 = mode_1;
    mode_1 = (_e45 * 0.1f);
    let _e48 = pos_1;
    let _e52 = global.U[0];
    let _e55 = pos_1;
    let _e64 = textureSample(t_source, samp, ((vec2<f32>((_e48.x / _e52.x), _e55.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e64;
    let _e66 = coverage_1;
    let _e67 = u_8;
    let _e70 = variability_1;
    let _e76 = perlin4_(((_e67 * 0.1f) * vec2<f32>((_e70 * 10f), 100f)));
    let _e79 = ccontrast(_e76, -5f);
    alpha = clamp((_e66 + _e79), 0f, 1f);
    let _e87 = alpha;
    let _e91 = intensity_1;
    alpha = (smoothstep(0.15f, 1f, pow(_e87, 2f)) * _e91);
    let _e93 = colorScheme_1;
    if (_e93 < 0.4f) {
        local = 1f;
    } else {
        let _e97 = colorScheme_1;
        local = (_e97 - 0.39f);
    }
    let _e101 = local;
    delta = (_e101 * 10f);
    let _e105 = pos_1;
    let _e106 = mode_1;
    let _e107 = shapeAspectRatio_3;
    let _e108 = randomSeed_19;
    let _e109 = staticNoiseF(_e105, _e106, _e107, _e108);
    let _e110 = pos_1;
    let _e111 = delta;
    let _e114 = mode_1;
    let _e115 = shapeAspectRatio_3;
    let _e116 = randomSeed_19;
    let _e117 = staticNoiseF((_e110 + vec2(_e111)), _e114, _e115, _e116);
    let _e118 = pos_1;
    let _e119 = delta;
    let _e122 = mode_1;
    let _e123 = shapeAspectRatio_3;
    let _e124 = randomSeed_19;
    let _e125 = staticNoiseF((_e118 - vec2(_e119)), _e122, _e123, _e124);
    rnd_1 = vec3<f32>(_e109, _e117, _e125);
    let _e128 = rnd_1;
    let _e130 = brightness_3;
    let _e131 = contrast_3;
    let _e132 = bc(_e128.x, _e130, _e131);
    let _e133 = rnd_1;
    let _e135 = brightness_3;
    let _e136 = contrast_3;
    let _e137 = bc(_e133.y, _e135, _e136);
    let _e138 = rnd_1;
    let _e140 = brightness_3;
    let _e141 = contrast_3;
    let _e142 = bc(_e138.z, _e140, _e141);
    rgb_2 = vec3<f32>(_e132, _e137, _e142);
    let _e145 = rnd_1;
    d_5 = ((_e145.xy - vec2(0.5f)) * 0.5f);
    let _e153 = balance_1;
    balance_1 = ((_e153 + 1f) / 2f);
    let _e158 = pos_1;
    let _e159 = alpha;
    let _e160 = d_5;
    let _e165 = balance_1;
    let _e174 = global.U[0];
    let _e177 = pos_1;
    let _e178 = alpha;
    let _e179 = d_5;
    let _e184 = balance_1;
    let _e198 = textureSample(t_source, samp, ((vec2<f32>(((_e158 + ((_e159 * _e160) * min(1f, (2f * (1f - _e165))))).x / _e174.x), (_e177 + ((_e178 * _e179) * min(1f, (2f * (1f - _e184))))).y) / vec2(2f)) + vec2(0.5f)));
    baseCol = _e198;
    let _e200 = baseCol;
    let _e201 = rgb_2;
    let _e202 = colorScheme_1;
    let _e203 = colorSchemeF(_e201, _e202);
    let _e209 = alpha;
    let _e212 = balance_1;
    outCol = mix(_e200, vec4<f32>(_e203.x, _e203.y, _e203.z, 1f), vec4((_e209 * min(1f, (2f * _e212)))));
    let _e219 = outCol;
    return _e219;
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
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e94 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[14];
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e110 = global.U[16];
    let _e111 = _e110.xyz;
    let _e114 = global.U[17];
    let _e115 = _e114.xyz;
    let _e129 = staticNoise((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, _e90.x, _e94.x, _e98.x, _e102.x, mat3x3<f32>(vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z)));
    fragColor = _e129;
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
