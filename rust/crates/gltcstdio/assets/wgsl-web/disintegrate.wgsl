struct Params {
    U: array<vec4<f32>, 21>,
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
@group(0) @binding(3) 
var t_sourceBkg: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn getBaseAngle(cc: vec2<f32>, phasing: f32, mode: i32) -> f32 {
    var cc_1: vec2<f32>;
    var phasing_1: f32;
    var mode_1: i32;
    var mm: i32;

    cc_1 = cc;
    phasing_1 = phasing;
    mode_1 = mode;
    let _e13 = mode_1;
    mm = (_e13 % 100i);
    let _e17 = mm;
    if (_e17 == 20i) {
        let _e20 = cc_1;
        let _e22 = cc_1;
        let _e25 = phasing_1;
        return (((_e20.x + _e22.y) / _e25) * 3.1415927f);
    } else {
        return 0f;
    }
}

fn getBaseTranslate(cc_2: vec2<f32>, phasing_2: f32, mode_2: i32) -> vec2<f32> {
    var cc_3: vec2<f32>;
    var phasing_3: f32;
    var mode_3: i32;
    var mm_1: i32;

    cc_3 = cc_2;
    phasing_3 = phasing_2;
    mode_3 = mode_2;
    let _e13 = mode_3;
    mm_1 = (_e13 % 100i);
    let _e17 = mm_1;
    if (_e17 == 21i) {
        let _e21 = cc_3;
        let _e23 = cc_3;
        let _e26 = phasing_3;
        return vec2<f32>(0f, cos((((_e21.x + _e23.y) / _e26) * 3.1415927f)));
    } else {
        return vec2(0f);
    }
}

fn getGlobalScaling(progress: f32, phasing_4: f32, mode_4: i32) -> f32 {
    var progress_1: f32;
    var phasing_5: f32;
    var mode_5: i32;

    progress_1 = progress;
    phasing_5 = phasing_4;
    mode_5 = mode_4;
    let _e13 = mode_5;
    if (_e13 < 10i) {
        {
            let _e17 = phasing_5;
            let _e19 = progress_1;
            return (1f / smoothstep(_e17, 0f, _e19));
        }
    } else {
        {
            return 1f;
        }
    }
}

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e9 = u_1;
    let _e19 = u_1;
    return vec2<f32>(fract((sin(dot(_e9.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e19.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var rnd: vec2<f32>;
    var len: f32;

    p_1 = p;
    let _e9 = p_1;
    let _e10 = hash22b(_e9);
    rnd = (_e10 - vec2(0.5f));
    let _e15 = rnd;
    len = length(_e15);
    let _e18 = len;
    if (_e18 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e24 = rnd;
        let _e25 = len;
        return (_e24 / vec2(_e25));
    }
}

fn dotGridGradient(g: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_1: vec2<f32>;
    var u_3: vec2<f32>;

    g_1 = g;
    u_3 = u_2;
    let _e11 = u_3;
    let _e12 = g_1;
    let _e14 = g_1;
    let _e15 = rndUnit(_e14);
    return dot((_e11 - _e12), _e15);
}

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e13 = a_1;
    let _e14 = b_1;
    let _e17 = k_1;
    return mix(_e13, _e14, smoothstep(0f, 1f, _e17));
}

fn perlinNoise(p_2: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var s: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_3 = p_2;
    let _e13 = p_3;
    f = floor(_e13);
    let _e16 = p_3;
    let _e17 = f;
    d = (_e16 - _e17);
    let _e20 = f;
    let _e21 = p_3;
    let _e22 = dotGridGradient(_e20, _e21);
    let _e23 = f;
    let _e24 = s;
    let _e26 = p_3;
    let _e27 = dotGridGradient((_e23 + _e24), _e26);
    let _e28 = d;
    let _e30 = smix(_e22, _e27, _e28.x);
    ix0_ = _e30;
    let _e32 = f;
    let _e33 = s;
    let _e36 = p_3;
    let _e37 = dotGridGradient((_e32 + _e33.yx), _e36);
    let _e38 = f;
    let _e39 = s;
    let _e42 = p_3;
    let _e43 = dotGridGradient((_e38 + _e39.xx), _e42);
    let _e44 = d;
    let _e46 = smix(_e37, _e43, _e44.x);
    ix1_ = _e46;
    let _e49 = ix0_;
    let _e50 = ix1_;
    let _e51 = d;
    let _e53 = smix(_e49, _e50, _e51.y);
    return (0.5f + (_e53 * 0.5f));
}

fn getProgress(cc_4: vec2<f32>, phasing_6: f32, mode_6: i32) -> f32 {
    var cc_5: vec2<f32>;
    var phasing_7: f32;
    var mode_7: i32;
    var mm_2: i32;

    cc_5 = cc_4;
    phasing_7 = phasing_6;
    mode_7 = mode_6;
    let _e13 = mode_7;
    mm_2 = (_e13 % 10i);
    let _e17 = mm_2;
    if (_e17 == 0i) {
        let _e20 = cc_5;
        return _e20.x;
    } else {
        let _e22 = mm_2;
        if (_e22 == 1i) {
            let _e25 = cc_5;
            return length(_e25);
        } else {
            let _e27 = mm_2;
            if (_e27 == 2i) {
                let _e30 = phasing_7;
                let _e32 = cc_5;
                return (-(_e30) + length(_e32));
            } else {
                let _e35 = mm_2;
                if (_e35 == 3i) {
                    let _e38 = phasing_7;
                    let _e39 = cc_5;
                    return (_e38 - length(_e39));
                } else {
                    let _e42 = mm_2;
                    if (_e42 == 4i) {
                        let _e45 = phasing_7;
                        let _e46 = cc_5;
                        return (_e45 - length((_e46 * vec2<f32>(2f, 0.5f))));
                    } else {
                        let _e53 = mm_2;
                        if (_e53 == 5i) {
                            let _e56 = phasing_7;
                            let _e57 = cc_5;
                            let _e59 = phasing_7;
                            return (_e56 * cos(((_e57.x / _e59) * 3.1415927f)));
                        } else {
                            let _e65 = mm_2;
                            if (_e65 == 6i) {
                                let _e69 = phasing_7;
                                let _e71 = cc_5;
                                let _e73 = phasing_7;
                                return ((0.5f * _e69) * (cos(((_e71.x / _e73) * 3.1415927f)) + 1f));
                            } else {
                                let _e81 = mm_2;
                                if (_e81 == 7i) {
                                    let _e85 = phasing_7;
                                    let _e87 = cc_5;
                                    let _e89 = phasing_7;
                                    return ((0.5f * _e85) * (cos(((length(_e87) / _e89) * 3.1415927f)) + 1f));
                                } else {
                                    let _e97 = mm_2;
                                    if (_e97 == 8i) {
                                        let _e101 = phasing_7;
                                        let _e103 = cc_5;
                                        let _e105 = phasing_7;
                                        let _e113 = cc_5;
                                        let _e115 = phasing_7;
                                        return (((0.25f * _e101) * (cos(((_e103.x / _e105) * 3.1415927f)) + 1f)) * (cos(((_e113.y / _e115) * 3.1415927f)) + 1f));
                                    } else {
                                        let _e123 = mm_2;
                                        if (_e123 == 9i) {
                                            let _e126 = cc_5;
                                            let _e127 = phasing_7;
                                            let _e130 = perlinNoise((_e126 / vec2(_e127)));
                                            let _e131 = phasing_7;
                                            return (_e130 * _e131);
                                        } else {
                                            let _e133 = phasing_7;
                                            return _e133;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e9 = v_1;
    x = fract((sin(dot(_e9.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e20 = x;
    let _e21 = v_1;
    y = fract((sin(dot(vec2<f32>(_e20, _e21.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e33 = x;
    let _e34 = y;
    return vec2<f32>(_e33, _e34);
}

fn varyNoiseSmoothly(noise: f32, k_2: f32) -> f32 {
    var noise_1: f32;
    var k_3: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_3 = k_2;
    let _e12 = noise_1;
    phase = acos(((2f * _e12) - 1f));
    let _e18 = noise_1;
    freq = (fract((_e18 * 16f)) + 0.5f);
    let _e26 = phase;
    let _e27 = freq;
    let _e28 = k_3;
    return ((1f + cos((_e26 + (_e27 * _e28)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_4: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_5: f32;

    noise_3 = noise_2;
    k_5 = k_4;
    let _e11 = noise_3;
    let _e13 = k_5;
    let _e14 = varyNoiseSmoothly(_e11.x, _e13);
    let _e15 = noise_3;
    let _e17 = k_5;
    let _e18 = varyNoiseSmoothly(_e15.y, _e17);
    return vec2<f32>(_e14, _e18);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e11 = co_1;
    let _e12 = rand2_(_e11);
    let _e13 = seed_1;
    let _e14 = varyVec2NoiseSmoothly(_e12, _e13);
    return (_e14 - vec2(0.5f));
}

fn sdRectangle(u_4: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_5: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_5 = u_4;
    halfSize_1 = halfSize;
    let _e11 = u_5;
    let _e13 = halfSize_1;
    u_5 = (abs(_e11) - _e13);
    let _e15 = u_5;
    let _e19 = u_5;
    if ((_e15.x >= 0f) && (_e19.y >= 0f)) {
        let _e24 = u_5;
        local = length(_e24);
    } else {
        let _e26 = u_5;
        let _e28 = u_5;
        local = max(_e26.x, _e28.y);
    }
    let _e32 = local;
    return _e32;
}

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k_6: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_7: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_7 = k_6;
    let _e13 = val1_1;
    let _e15 = k_7;
    let _e23 = val2_1;
    let _e26 = k_7;
    return (((_e13 * (1f + cos((_e15 * 3.1415927f)))) * 0.5f) + ((_e23 * (1f + cos(((1f - _e26) * 3.1415927f)))) * 0.5f));
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e11 = v_3;
    u00_ = floor(_e11);
    let _e14 = v_3;
    let _e17 = v_3;
    u01_ = vec2<f32>(floor(_e14.x), ceil(_e17.y));
    let _e22 = v_3;
    let _e25 = v_3;
    u10_ = vec2<f32>(ceil(_e22.x), floor(_e25.y));
    let _e30 = v_3;
    u11_ = ceil(_e30);
    let _e33 = u00_;
    let _e34 = rand2_(_e33);
    let _e35 = seed_3;
    let _e36 = varyVec2NoiseSmoothly(_e34, _e35);
    r00_ = (_e36 - vec2<f32>(0.5f, 0.5f));
    let _e42 = u01_;
    let _e43 = rand2_(_e42);
    let _e44 = seed_3;
    let _e45 = varyVec2NoiseSmoothly(_e43, _e44);
    r01_ = (_e45 - vec2<f32>(0.5f, 0.5f));
    let _e51 = u10_;
    let _e52 = rand2_(_e51);
    let _e53 = seed_3;
    let _e54 = varyVec2NoiseSmoothly(_e52, _e53);
    r10_ = (_e54 - vec2<f32>(0.5f, 0.5f));
    let _e60 = u11_;
    let _e61 = rand2_(_e60);
    let _e62 = seed_3;
    let _e63 = varyVec2NoiseSmoothly(_e61, _e62);
    r11_ = (_e63 - vec2<f32>(0.5f, 0.5f));
    let _e69 = r00_;
    let _e70 = r01_;
    let _e71 = v_3;
    let _e74 = sineMix(_e69, _e70, fract(_e71.y));
    let _e75 = r10_;
    let _e76 = r11_;
    let _e77 = v_3;
    let _e80 = sineMix(_e75, _e76, fract(_e77.y));
    let _e81 = v_3;
    let _e84 = sineMix(_e74, _e80, fract(_e81.x));
    return _e84;
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e11 = m_1;
    let _e12 = u_7;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn disintegrate(uv: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, mode_8: i32, sourceBkg_specified: i32, colorBkg: vec4<f32>, regularity: f32, len_1: f32, power: f32, translateVar: f32, scaleVar: f32, angleVar: f32, shadows: f32, minimum: f32, threshold: f32, modelTransform: mat3x3<f32>, randomSeed: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var mode_9: i32;
    var sourceBkg_specified_1: i32;
    var colorBkg_1: vec4<f32>;
    var regularity_1: f32;
    var len_2: f32;
    var power_1: f32;
    var translateVar_1: f32;
    var scaleVar_1: f32;
    var angleVar_1: f32;
    var shadows_1: f32;
    var minimum_1: f32;
    var threshold_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var randomSeed_1: f32;
    var u_8: vec2<f32>;
    var phasing_8: f32;
    var variability: f32;
    var pixel: f32;
    var minProgress: f32;
    var maxProgress: f32;
    var cell: vec2<f32>;
    var N: f32;
    var local_1: vec4<f32>;
    var color: vec4<f32>;
    var i: f32;
    var j: f32;
    var cc_6: vec2<f32>;
    var rnd_1: vec2<f32>;
    var rnd2_: vec2<f32>;
    var progress_2: f32;
    var globalScaling: f32;
    var intensity: f32;
    var cScale: f32;
    var cAngle: f32;
    var cTr: vec2<f32>;
    var locTr: mat3x3<f32>;
    var relU: vec2<f32>;
    var d_1: f32;
    var trIntens: f32;
    var shadowLen: f32;
    var local_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    outDim_1 = outDim;
    mode_9 = mode_8;
    sourceBkg_specified_1 = sourceBkg_specified;
    colorBkg_1 = colorBkg;
    regularity_1 = regularity;
    len_2 = len_1;
    power_1 = power;
    translateVar_1 = translateVar;
    scaleVar_1 = scaleVar;
    angleVar_1 = angleVar;
    shadows_1 = shadows;
    minimum_1 = minimum;
    threshold_1 = threshold;
    modelTransform_1 = modelTransform;
    randomSeed_1 = randomSeed;
    let _e41 = modelTransform_1;
    let _e43 = uv_1;
    u_8 = (_naga_inverse_3x3_f32(_e41) * vec3<f32>(_e43.x, _e43.y, 1f)).xy;
    let _e51 = len_2;
    phasing_8 = _e51;
    let _e54 = regularity_1;
    variability = (1f - _e54);
    let _e58 = outDim_1;
    let _e63 = modelTransform_1[0];
    pixel = ((2f / _e58.y) / length(_e63.xy));
    let _e68 = minimum_1;
    minProgress = _e68;
    let _e70 = threshold_1;
    maxProgress = _e70;
    let _e72 = u_8;
    cell = floor(_e72);
    let _e76 = scaleVar_1;
    let _e82 = translateVar_1;
    N = ceil(((pow(10f, (_e76 * 0.5f)) * 0.75f) + _e82));
    let _e86 = sourceBkg_specified_1;
    if (_e86 == 1i) {
        let _e89 = uv_1;
        let _e93 = global.U[0];
        let _e96 = uv_1;
        let _e105 = _mirror_wrap(((vec2<f32>((_e89.x / _e93.x), _e96.y) / vec2(2f)) + vec2(0.5f)));
        let _e107 = textureSampleLevel(t_sourceBkg, samp, _e105, 0f);
        local_1 = _e107;
    } else {
        let _e108 = uv_1;
        let _e112 = global.U[0];
        let _e115 = uv_1;
        let _e124 = _mirror_wrap(((vec2<f32>((_e108.x / _e112.x), _e115.y) / vec2(2f)) + vec2(0.5f)));
        let _e126 = textureSampleLevel(t_source, samp, _e124, 0f);
        local_1 = _e126;
    }
    let _e128 = local_1;
    let _e129 = colorBkg_1;
    let _e130 = mergeColor(_e128, _e129);
    color = _e130;
    let _e132 = N;
    i = -(_e132);
    loop {
        let _e135 = i;
        let _e136 = N;
        if !((_e135 <= _e136)) {
            break;
        }
        {
            let _e142 = N;
            j = -(_e142);
            loop {
                let _e145 = j;
                let _e146 = N;
                if !((_e145 <= _e146)) {
                    break;
                }
                {
                    let _e152 = cell;
                    let _e153 = i;
                    let _e154 = j;
                    cc_6 = (_e152 + vec2<f32>(_e153, _e154));
                    let _e158 = cc_6;
                    let _e159 = randomSeed_1;
                    let _e160 = rand2relSeeded(_e158, _e159);
                    rnd_1 = _e160;
                    let _e163 = cc_6;
                    let _e168 = randomSeed_1;
                    let _e171 = sineSurfaceRand2Seeded((vec2(0.2f) + (_e163 * 0.75f)), (_e168 * 2f));
                    rnd2_ = _e171;
                    let _e173 = cc_6;
                    let _e174 = phasing_8;
                    let _e175 = mode_9;
                    let _e176 = getProgress(_e173, _e174, _e175);
                    let _e177 = phasing_8;
                    let _e178 = variability;
                    let _e179 = rnd2_;
                    let _e182 = variability;
                    let _e183 = variability;
                    let _e185 = rnd_1;
                    progress_2 = (_e176 + (_e177 * ((_e178 * _e179.x) + ((_e182 * _e183) * _e185.x))));
                    let _e192 = progress_2;
                    let _e194 = phasing_8;
                    let _e197 = power_1;
                    let _e200 = phasing_8;
                    let _e202 = progress_2;
                    progress_2 = ((pow((abs(_e192) / _e194), (1f / _e197)) * _e200) * sign(_e202));
                    let _e205 = progress_2;
                    let _e206 = phasing_8;
                    let _e207 = minProgress;
                    progress_2 = max(_e205, (_e206 * _e207));
                    let _e210 = progress_2;
                    let _e211 = phasing_8;
                    let _e212 = maxProgress;
                    if (_e210 > (_e211 * _e212)) {
                        let _e215 = phasing_8;
                        progress_2 = _e215;
                    }
                    let _e216 = progress_2;
                    let _e217 = phasing_8;
                    let _e218 = mode_9;
                    let _e219 = getGlobalScaling(_e216, _e217, _e218);
                    globalScaling = _e219;
                    let _e222 = phasing_8;
                    let _e223 = progress_2;
                    intensity = smoothstep(0f, _e222, _e223);
                    let _e227 = rnd_1;
                    let _e231 = intensity;
                    let _e233 = scaleVar_1;
                    let _e238 = globalScaling;
                    cScale = (pow(10f, ((((_e227.x * 0.5f) * _e231) * _e233) * 2f)) * _e238);
                    let _e241 = cc_6;
                    let _e242 = phasing_8;
                    let _e243 = mode_9;
                    let _e244 = getBaseAngle(_e241, _e242, _e243);
                    let _e245 = rnd_1;
                    let _e249 = intensity;
                    let _e251 = angleVar_1;
                    cAngle = (_e244 + (((_e245.y * 3.1415927f) * _e249) * _e251));
                    let _e255 = cc_6;
                    let _e256 = phasing_8;
                    let _e257 = mode_9;
                    let _e258 = getBaseTranslate(_e255, _e256, _e257);
                    let _e259 = rnd_1;
                    let _e260 = intensity;
                    let _e262 = translateVar_1;
                    cTr = (_e258 + (((_e259 * _e260) * _e262) * 4f));
                    let _e268 = cScale;
                    let _e269 = cAngle;
                    let _e272 = cScale;
                    let _e274 = cAngle;
                    let _e278 = cScale;
                    let _e279 = cAngle;
                    let _e282 = cScale;
                    let _e283 = cAngle;
                    let _e287 = cTr;
                    let _e289 = cTr;
                    locTr = mat3x3<f32>(vec3<f32>((_e268 * cos(_e269)), (-(_e272) * sin(_e274)), 0f), vec3<f32>((_e278 * sin(_e279)), (_e282 * cos(_e283)), 0f), vec3<f32>(_e287.x, _e289.y, 1f));
                    let _e297 = locTr;
                    let _e298 = u_8;
                    let _e299 = cc_6;
                    let _e303 = ((_e298 - _e299) - vec2(0.5f));
                    relU = (_e297 * vec3<f32>(_e303.x, _e303.y, 1f)).xy;
                    let _e311 = relU;
                    let _e314 = sdRectangle(_e311, vec2(0.5f));
                    d_1 = _e314;
                    let _e316 = cScale;
                    let _e322 = cAngle;
                    let _e327 = cTr;
                    trIntens = ((abs(log(_e316)) + (0.5f * smoothstep(0f, 0.5f, abs(_e322)))) + length(_e327));
                    let _e331 = shadows_1;
                    let _e332 = trIntens;
                    shadowLen = (_e331 * _e332);
                    let _e335 = trIntens;
                    if (_e335 == 0f) {
                        {
                            let _e338 = d_1;
                            if (_e338 < 0f) {
                                let _e341 = modelTransform_1;
                                let _e342 = cc_6;
                                let _e343 = relU;
                                let _e348 = tf(_e341, ((_e342 + _e343) + vec2(0.5f)));
                                let _e352 = global.U[0];
                                let _e355 = modelTransform_1;
                                let _e356 = cc_6;
                                let _e357 = relU;
                                let _e362 = tf(_e355, ((_e356 + _e357) + vec2(0.5f)));
                                let _e371 = _mirror_wrap(((vec2<f32>((_e348.x / _e352.x), _e362.y) / vec2(2f)) + vec2(0.5f)));
                                let _e373 = textureSampleLevel(t_source, samp, _e371, 0f);
                                color = _e373;
                            } else {
                                let _e374 = d_1;
                                let _e375 = shadowLen;
                                if (_e374 < _e375) {
                                    let _e377 = color;
                                    let _e379 = color;
                                    let _e382 = shadowLen;
                                    let _e383 = d_1;
                                    let _e385 = (_e379.xyz * smoothstep(0f, _e382, _e383));
                                    color.x = _e385.x;
                                    color.y = _e385.y;
                                    color.z = _e385.z;
                                }
                            }
                        }
                    } else {
                        let _e392 = d_1;
                        let _e395 = d_1;
                        let _e396 = shadowLen;
                        if ((_e392 > 0f) && (_e395 < _e396)) {
                            let _e399 = color;
                            let _e401 = shadowLen;
                            let _e402 = d_1;
                            let _e404 = vec3(smoothstep(0f, _e401, _e402));
                            local_2 = (_e399 * vec4<f32>(_e404.x, _e404.y, _e404.z, 1f));
                        } else {
                            let _e411 = color;
                            local_2 = _e411;
                        }
                        let _e413 = local_2;
                        let _e414 = modelTransform_1;
                        let _e415 = cc_6;
                        let _e416 = relU;
                        let _e421 = tf(_e414, ((_e415 + _e416) + vec2(0.5f)));
                        let _e425 = global.U[0];
                        let _e428 = modelTransform_1;
                        let _e429 = cc_6;
                        let _e430 = relU;
                        let _e435 = tf(_e428, ((_e429 + _e430) + vec2(0.5f)));
                        let _e444 = _mirror_wrap(((vec2<f32>((_e421.x / _e425.x), _e435.y) / vec2(2f)) + vec2(0.5f)));
                        let _e446 = textureSampleLevel(t_source, samp, _e444, 0f);
                        let _e447 = pixel;
                        let _e450 = pixel;
                        let _e454 = d_1;
                        color = mix(_e413, _e446, vec4(smoothstep((_e447 * 0.75f), (-(_e450) * 0.75f), _e454)));
                    }
                }
                continuing {
                    let _e149 = j;
                    j = (_e149 + 1f);
                }
            }
        }
        continuing {
            let _e139 = i;
            i = (_e139 + 1f);
        }
    }
    let _e458 = color;
    return _e458;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e71 = global.U[6];
    let _e76 = global.U[5];
    let _e81 = global.U[7];
    let _e84 = global.U[8];
    let _e88 = global.U[9];
    let _e92 = global.U[10];
    let _e96 = global.U[11];
    let _e100 = global.U[12];
    let _e104 = global.U[13];
    let _e108 = global.U[14];
    let _e112 = global.U[15];
    let _e116 = global.U[16];
    let _e120 = global.U[17];
    let _e121 = _e120.xyz;
    let _e124 = global.U[18];
    let _e125 = _e124.xyz;
    let _e128 = global.U[19];
    let _e129 = _e128.xyz;
    let _e145 = global.U[20];
    let _e147 = disintegrate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, i32(_e71.x), i32(_e76.x), _e81, _e84.x, _e88.x, _e92.x, _e96.x, _e100.x, _e104.x, _e108.x, _e112.x, _e116.x, mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)), _e145.x);
    fragColor = _e147;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
