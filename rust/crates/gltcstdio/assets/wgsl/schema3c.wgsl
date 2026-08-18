struct Params {
    U: array<vec4<f32>, 27>,
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
var t_source2_: texture_2d<f32>;

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

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e12 = noise_1;
    phase = acos(((2f * _e12) - 1f));
    let _e18 = noise_1;
    freq = (fract((_e18 * 16f)) + 0.5f);
    let _e26 = phase;
    let _e27 = freq;
    let _e28 = k_1;
    return ((1f + cos((_e26 + (_e27 * _e28)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e11 = noise_3;
    let _e13 = k_3;
    let _e14 = varyNoiseSmoothly(_e11.x, _e13);
    let _e15 = noise_3;
    let _e17 = k_3;
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

fn distort9_(pos: vec2<f32>, rect: vec4<f32>, splits: vec2<f32>, intensity: f32, seed_2: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var rect_1: vec4<f32>;
    var splits_1: vec2<f32>;
    var intensity_1: f32;
    var seed_3: f32;
    var rnd: vec2<f32>;
    var dx: f32;
    var dy: f32;

    pos_1 = pos;
    rect_1 = rect;
    splits_1 = splits;
    intensity_1 = intensity;
    seed_3 = seed_2;
    let _e17 = splits_1;
    let _e18 = seed_3;
    let _e21 = rand2relSeeded(_e17, (_e18 + 122.1f));
    rnd = _e21;
    let _e23 = rect_1;
    let _e25 = rect_1;
    dx = (_e23.z - _e25.x);
    let _e29 = rect_1;
    let _e31 = rect_1;
    dy = (_e29.w - _e31.y);
    let _e35 = dx;
    let _e36 = dy;
    if (_e35 > _e36) {
        let _e38 = pos_1;
        let _e39 = rnd;
        let _e42 = dx;
        let _e44 = dy;
        let _e46 = intensity_1;
        return (_e38 + vec2<f32>(((((sign(_e39.x) * _e42) / _e44) * _e46) * 0.0005f), 0f));
    } else {
        let _e53 = pos_1;
        let _e55 = rnd;
        let _e58 = dy;
        let _e60 = dx;
        let _e62 = intensity_1;
        return (_e53 + vec2<f32>(0f, ((((sign(_e55.y) * _e58) / _e60) * _e62) * 0.0005f)));
    }
}

fn inscribedRect(wt: mat3x3<f32>, srcRatio: f32) -> vec4<f32> {
    var wt_1: mat3x3<f32>;
    var srcRatio_1: f32;
    var ws: f32;
    var winA: f32;
    var winB: f32;
    var wax: vec2<f32>;
    var c1_: f32;
    var s1_: f32;
    var sin2_: f32;
    var W: f32;
    var H: f32;
    var det: f32;
    var wc: vec2<f32>;

    wt_1 = wt;
    srcRatio_1 = srcRatio;
    let _e13 = wt_1[1];
    ws = length(_e13.xy);
    let _e17 = srcRatio_1;
    let _e20 = wt_1[0];
    winA = (_e17 * length(_e20.xy));
    let _e25 = ws;
    winB = _e25;
    let _e29 = wt_1[0];
    wax = normalize(_e29.xy);
    let _e33 = wax;
    c1_ = abs(_e33.x);
    let _e37 = wax;
    s1_ = abs(_e37.y);
    let _e42 = c1_;
    let _e44 = s1_;
    sin2_ = ((2f * _e42) * _e44);
    let _e49 = winA;
    let _e50 = winB;
    let _e51 = sin2_;
    if (_e49 <= (_e50 * _e51)) {
        {
            let _e54 = winA;
            let _e56 = c1_;
            W = (_e54 / (2f * _e56));
            let _e59 = winA;
            let _e61 = s1_;
            H = (_e59 / (2f * _e61));
        }
    } else {
        let _e64 = winB;
        let _e65 = winA;
        let _e66 = sin2_;
        if (_e64 <= (_e65 * _e66)) {
            {
                let _e69 = winB;
                let _e71 = s1_;
                W = (_e69 / (2f * _e71));
                let _e74 = winB;
                let _e76 = c1_;
                H = (_e74 / (2f * _e76));
            }
        } else {
            {
                let _e79 = c1_;
                let _e80 = c1_;
                let _e82 = s1_;
                let _e83 = s1_;
                det = ((_e79 * _e80) - (_e82 * _e83));
                let _e87 = winA;
                let _e88 = c1_;
                let _e90 = winB;
                let _e91 = s1_;
                let _e94 = det;
                W = (((_e87 * _e88) - (_e90 * _e91)) / _e94);
                let _e96 = winB;
                let _e97 = c1_;
                let _e99 = winA;
                let _e100 = s1_;
                let _e103 = det;
                H = (((_e96 * _e97) - (_e99 * _e100)) / _e103);
            }
        }
    }
    let _e105 = W;
    W = max(_e105, 0f);
    let _e108 = H;
    H = max(_e108, 0f);
    let _e113 = wt_1[2];
    wc = _e113.xy;
    let _e116 = wc;
    let _e118 = W;
    let _e120 = wc;
    let _e122 = H;
    let _e124 = wc;
    let _e126 = W;
    let _e128 = wc;
    let _e130 = H;
    return vec4<f32>((_e116.x - _e118), (_e120.y - _e122), (_e124.x + _e126), (_e128.y + _e130));
}

fn rounded(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e11 = x_2;
    let _e12 = prec_1;
    let _e17 = prec_1;
    return (floor(((_e11 / _e12) + 0.5f)) * _e17);
}

fn withBias(x_3: f32, b: f32) -> f32 {
    var x_4: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_1 = b;
    let _e11 = b_1;
    s = sign(_e11);
    let _e14 = b_1;
    ab = abs(_e14);
    let _e17 = x_4;
    let _e21 = s;
    let _e23 = ab;
    return (pow((_e17 + 0.5f), pow(2f, (-(_e21) * _e23))) - 0.5f);
}

fn schema3c(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, source2Dim: vec2<f32>, outDim: vec2<f32>, source2_specified: i32, intensity_2: f32, iterations: i32, pixelation: f32, balance: f32, proximity: f32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, aspectRatio: f32, modelTransform: mat3x3<f32>, windowTransform: mat3x3<f32>, windowTransform2_: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var source2_specified_1: i32;
    var intensity_3: f32;
    var iterations_1: i32;
    var pixelation_1: f32;
    var balance_1: f32;
    var proximity_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var aspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var windowTransform_1: mat3x3<f32>;
    var windowTransform2_1: mat3x3<f32>;
    var srcRatio_2: f32;
    var outAR: f32;
    var pixel: f32;
    var has2_: bool;
    var local: f32;
    var src2Ratio: f32;
    var bias: vec2<f32>;
    var scale: f32;
    var th: f32;
    var ws1_: f32;
    var wl1_: vec2<f32>;
    var sxg1_: f32;
    var syg1_: f32;
    var frame: bool;
    var ws2_: f32;
    var wl2_: vec2<f32>;
    var sxg2_: f32;
    var syg2_: f32;
    var col: vec4<f32>;
    var E1_: vec4<f32>;
    var local_1: vec4<f32>;
    var E2_: vec4<f32>;
    var p: vec2<f32>;
    var border: bool = false;
    var rect_2: vec4<f32>;
    var cellId: vec2<f32> = vec2(0f);
    var regularity: f32;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var b_2: vec2<f32>;
    var i: f32;
    var rnd_1: vec2<f32>;
    var size: vec2<f32>;
    var var2_: f32;
    var Y: f32;
    var local_2: f32;
    var local_3: f32;
    var X: f32;
    var local_4: f32;
    var local_5: f32;
    var ps: vec2<f32>;
    var col_1: vec4<f32>;
    var cc: vec2<f32>;
    var d1_: f32;
    var d2_: f32;
    var prox: f32;
    var rnd2_: f32;
    var biasTerm: f32;
    var score: f32;
    var local_6: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    source2Dim_1 = source2Dim;
    outDim_1 = outDim;
    source2_specified_1 = source2_specified;
    intensity_3 = intensity_2;
    iterations_1 = iterations;
    pixelation_1 = pixelation;
    balance_1 = balance;
    proximity_1 = proximity;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    aspectRatio_1 = aspectRatio;
    modelTransform_1 = modelTransform;
    windowTransform_1 = windowTransform;
    windowTransform2_1 = windowTransform2_;
    let _e45 = sourceDim_1;
    let _e47 = sourceDim_1;
    let _e51 = rounded((_e45.x / _e47.y), 0.01f);
    srcRatio_2 = _e51;
    let _e53 = outDim_1;
    let _e55 = outDim_1;
    let _e59 = rounded((_e53.x / _e55.y), 0.01f);
    outAR = _e59;
    let _e62 = outDim_1;
    pixel = (2f / _e62.y);
    let _e66 = source2_specified_1;
    has2_ = (_e66 != 0i);
    let _e70 = has2_;
    if _e70 {
        let _e71 = source2Dim_1;
        let _e73 = source2Dim_1;
        let _e77 = rounded((_e71.x / _e73.y), 0.01f);
        local = _e77;
    } else {
        let _e78 = srcRatio_2;
        local = _e78;
    }
    let _e80 = local;
    src2Ratio = _e80;
    let _e82 = modelTransform_1;
    bias = (_e82 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e95 = modelTransform_1[0][0];
    let _e100 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e95, _e100)));
    let _e105 = thickness_1;
    th = (_e105 * 0.1f);
    let _e111 = windowTransform_1[1];
    ws1_ = length(_e111.xy);
    let _e115 = windowTransform_1;
    let _e117 = uv_1;
    wl1_ = (_naga_inverse_3x3_f32(_e115) * vec3<f32>(_e117.x, _e117.y, 1f)).xy;
    let _e125 = srcRatio_2;
    let _e126 = wl1_;
    let _e130 = ws1_;
    sxg1_ = ((_e125 - abs(_e126.x)) * _e130);
    let _e134 = wl1_;
    let _e138 = ws1_;
    syg1_ = ((1f - abs(_e134.y)) * _e138);
    let _e141 = sxg1_;
    let _e144 = syg1_;
    if ((_e141 > 0f) && (_e144 > 0f)) {
        let _e148 = wl1_;
        let _e152 = global.U[0];
        let _e155 = wl1_;
        let _e164 = textureSample(t_source, samp, ((vec2<f32>((_e148.x / _e152.x), _e155.y) / vec2(2f)) + vec2(0.5f)));
        return _e164;
    }
    let _e165 = sxg1_;
    let _e167 = th;
    let _e169 = syg1_;
    let _e170 = th;
    let _e174 = syg1_;
    let _e176 = th;
    let _e178 = sxg1_;
    let _e179 = th;
    frame = (((abs(_e165) < _e167) && (_e169 > -(_e170))) || ((abs(_e174) < _e176) && (_e178 > -(_e179))));
    let _e185 = has2_;
    if _e185 {
        {
            let _e188 = windowTransform2_1[1];
            ws2_ = length(_e188.xy);
            let _e192 = windowTransform2_1;
            let _e194 = uv_1;
            wl2_ = (_naga_inverse_3x3_f32(_e192) * vec3<f32>(_e194.x, _e194.y, 1f)).xy;
            let _e202 = src2Ratio;
            let _e203 = wl2_;
            let _e207 = ws2_;
            sxg2_ = ((_e202 - abs(_e203.x)) * _e207);
            let _e211 = wl2_;
            let _e215 = ws2_;
            syg2_ = ((1f - abs(_e211.y)) * _e215);
            let _e218 = sxg2_;
            let _e221 = syg2_;
            if ((_e218 > 0f) && (_e221 > 0f)) {
                let _e225 = wl2_;
                let _e229 = global.U[0];
                let _e232 = wl2_;
                let _e241 = textureSample(t_source2_, samp, ((vec2<f32>((_e225.x / _e229.x), _e232.y) / vec2(2f)) + vec2(0.5f)));
                return _e241;
            }
            let _e242 = frame;
            let _e243 = sxg2_;
            let _e245 = th;
            let _e247 = syg2_;
            let _e248 = th;
            let _e253 = syg2_;
            let _e255 = th;
            let _e257 = sxg2_;
            let _e258 = th;
            frame = ((_e242 || ((abs(_e243) < _e245) && (_e247 > -(_e248)))) || ((abs(_e253) < _e255) && (_e257 > -(_e258))));
        }
    }
    let _e263 = frame;
    if _e263 {
        {
            let _e264 = uv_1;
            let _e268 = global.U[0];
            let _e271 = uv_1;
            let _e280 = textureSample(t_source, samp, ((vec2<f32>((_e264.x / _e268.x), _e271.y) / vec2(2f)) + vec2(0.5f)));
            col = _e280;
            let _e282 = col;
            let _e284 = color_1;
            let _e286 = color_1;
            let _e289 = mix(_e282.xyz, _e284.xyz, vec3(_e286.w));
            let _e290 = col;
            return vec4<f32>(_e289.x, _e289.y, _e289.z, _e290.w);
        }
    }
    let _e296 = windowTransform_1;
    let _e297 = srcRatio_2;
    let _e298 = inscribedRect(_e296, _e297);
    E1_ = _e298;
    let _e300 = has2_;
    if _e300 {
        let _e301 = windowTransform2_1;
        let _e302 = src2Ratio;
        let _e303 = inscribedRect(_e301, _e302);
        local_1 = _e303;
    } else {
        local_1 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e312 = local_1;
    E2_ = _e312;
    let _e314 = uv_1;
    p = _e314;
    let _e323 = variability_1;
    regularity = (1f - _e323);
    loop {
        let _e328 = j;
        let _e329 = iterations_1;
        if !((_e328 < _e329)) {
            break;
        }
        {
            let _e335 = outAR;
            let _e339 = outAR;
            rect_2 = vec4<f32>(-(_e335), -1f, _e339, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e354 = bias;
            b_2 = _e354;
            i = 0f;
            loop {
                let _e358 = i;
                let _e359 = sPos;
                let _e361 = scale;
                if !(((_e358 + _e359) < _e361)) {
                    break;
                }
                {
                    let _e367 = splits_2;
                    let _e368 = randomSeed_1;
                    let _e371 = rand2relSeeded(_e367, (_e368 + 122.1f));
                    rnd_1 = _e371;
                    let _e373 = rect_2;
                    let _e375 = rect_2;
                    size = (_e373.zw - _e375.xy);
                    let _e379 = size;
                    let _e381 = pixel;
                    let _e383 = size;
                    let _e385 = pixel;
                    if ((_e379.x < _e381) || (_e383.y < _e385)) {
                        break;
                    }
                    let _e388 = rnd_1;
                    let _e392 = regularity;
                    if ((_e388.x + 0.5f) < (_e392 * 2f)) {
                        let _e396 = size;
                        let _e398 = size;
                        horSplit = (_e396.y > _e398.x);
                    }
                    let _e403 = regularity;
                    var2_ = (1f - max(0f, ((_e403 * 2f) - 1f)));
                    let _e411 = horSplit;
                    if _e411 {
                        {
                            let _e412 = rect_2;
                            let _e414 = rect_2;
                            let _e416 = var2_;
                            let _e417 = rnd_1;
                            let _e419 = b_2;
                            let _e421 = withBias(_e417.y, _e419.y);
                            Y = mix(_e412.y, _e414.w, ((_e416 * _e421) + 0.5f));
                            let _e427 = rect_2;
                            let _e429 = E1_;
                            let _e432 = rect_2;
                            let _e434 = E1_;
                            let _e438 = Y;
                            let _e439 = E1_;
                            let _e443 = Y;
                            let _e444 = E1_;
                            if ((((_e427.x < _e429.z) && (_e432.z > _e434.x)) && (_e438 > _e439.y)) && (_e443 < _e444.w)) {
                                let _e448 = Y;
                                let _e449 = E1_;
                                let _e452 = E1_;
                                let _e454 = Y;
                                if ((_e448 - _e449.y) < (_e452.w - _e454)) {
                                    let _e457 = E1_;
                                    local_2 = _e457.y;
                                } else {
                                    let _e459 = E1_;
                                    local_2 = _e459.w;
                                }
                                let _e462 = local_2;
                                Y = _e462;
                            }
                            let _e463 = rect_2;
                            let _e465 = E2_;
                            let _e468 = rect_2;
                            let _e470 = E2_;
                            let _e474 = Y;
                            let _e475 = E2_;
                            let _e479 = Y;
                            let _e480 = E2_;
                            if ((((_e463.x < _e465.z) && (_e468.z > _e470.x)) && (_e474 > _e475.y)) && (_e479 < _e480.w)) {
                                let _e484 = Y;
                                let _e485 = E2_;
                                let _e488 = E2_;
                                let _e490 = Y;
                                if ((_e484 - _e485.y) < (_e488.w - _e490)) {
                                    let _e493 = E2_;
                                    local_3 = _e493.y;
                                } else {
                                    let _e495 = E2_;
                                    local_3 = _e495.w;
                                }
                                let _e498 = local_3;
                                Y = _e498;
                            }
                            let _e499 = Y;
                            let _e500 = p;
                            let _e504 = th;
                            if (abs((_e499 - _e500.y)) < _e504) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e507 = p;
                            let _e509 = Y;
                            if (_e507.y < _e509) {
                                {
                                    let _e512 = Y;
                                    rect_2.w = _e512;
                                    let _e514 = splits_2.y;
                                    splits_2.y = (_e514 + 1f);
                                    let _e517 = sPos;
                                    let _e518 = inverter;
                                    let _e519 = sscale;
                                    sPos = (_e517 + (_e518 * _e519));
                                }
                            } else {
                                {
                                    let _e523 = Y;
                                    rect_2.y = _e523;
                                    let _e525 = splits_2;
                                    splits_2.y = (_e525.y + 100f);
                                    let _e529 = sPos;
                                    let _e531 = inverter;
                                    let _e533 = sscale;
                                    sPos = (_e529 + ((1f - _e531) * _e533));
                                }
                            }
                        }
                    } else {
                        {
                            let _e536 = rect_2;
                            let _e538 = rect_2;
                            let _e540 = var2_;
                            let _e541 = rnd_1;
                            let _e543 = b_2;
                            let _e545 = withBias(_e541.x, _e543.x);
                            X = mix(_e536.x, _e538.z, ((_e540 * _e545) + 0.5f));
                            let _e551 = rect_2;
                            let _e553 = E1_;
                            let _e556 = rect_2;
                            let _e558 = E1_;
                            let _e562 = X;
                            let _e563 = E1_;
                            let _e567 = X;
                            let _e568 = E1_;
                            if ((((_e551.y < _e553.w) && (_e556.w > _e558.y)) && (_e562 > _e563.x)) && (_e567 < _e568.z)) {
                                let _e572 = X;
                                let _e573 = E1_;
                                let _e576 = E1_;
                                let _e578 = X;
                                if ((_e572 - _e573.x) < (_e576.z - _e578)) {
                                    let _e581 = E1_;
                                    local_4 = _e581.x;
                                } else {
                                    let _e583 = E1_;
                                    local_4 = _e583.z;
                                }
                                let _e586 = local_4;
                                X = _e586;
                            }
                            let _e587 = rect_2;
                            let _e589 = E2_;
                            let _e592 = rect_2;
                            let _e594 = E2_;
                            let _e598 = X;
                            let _e599 = E2_;
                            let _e603 = X;
                            let _e604 = E2_;
                            if ((((_e587.y < _e589.w) && (_e592.w > _e594.y)) && (_e598 > _e599.x)) && (_e603 < _e604.z)) {
                                let _e608 = X;
                                let _e609 = E2_;
                                let _e612 = E2_;
                                let _e614 = X;
                                if ((_e608 - _e609.x) < (_e612.z - _e614)) {
                                    let _e617 = E2_;
                                    local_5 = _e617.x;
                                } else {
                                    let _e619 = E2_;
                                    local_5 = _e619.z;
                                }
                                let _e622 = local_5;
                                X = _e622;
                            }
                            let _e623 = X;
                            let _e624 = p;
                            let _e628 = th;
                            if (abs((_e623 - _e624.x)) < _e628) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e631 = p;
                            let _e633 = X;
                            if (_e631.x < _e633) {
                                {
                                    let _e636 = X;
                                    rect_2.z = _e636;
                                    let _e638 = splits_2.x;
                                    splits_2.x = (_e638 + 1f);
                                    let _e641 = sPos;
                                    let _e642 = inverter;
                                    let _e643 = sscale;
                                    sPos = (_e641 + (_e642 * _e643));
                                }
                            } else {
                                {
                                    let _e647 = X;
                                    rect_2.x = _e647;
                                    let _e649 = splits_2;
                                    splits_2.x = (_e649.x + 100f);
                                    let _e653 = sPos;
                                    let _e655 = inverter;
                                    let _e657 = sscale;
                                    sPos = (_e653 + ((1f - _e655) * _e657));
                                }
                            }
                        }
                    }
                    let _e660 = horSplit;
                    horSplit = !(_e660);
                    let _e663 = inverter;
                    inverter = (1f - _e663);
                    let _e665 = sscale;
                    sscale = (_e665 * 0.5f);
                    let _e668 = b_2;
                    b_2 = (_e668 * 0.5f);
                }
                continuing {
                    let _e364 = i;
                    i = (_e364 + 1f);
                }
            }
            let _e671 = border;
            if _e671 {
                break;
            }
            let _e672 = splits_2;
            cellId = _e672;
            let _e673 = p;
            let _e674 = rect_2;
            let _e675 = splits_2;
            let _e676 = intensity_3;
            let _e677 = randomSeed_1;
            let _e678 = distort9_(_e673, _e674, _e675, _e676, _e677);
            p = _e678;
        }
        continuing {
            let _e332 = j;
            j = (_e332 + 1i);
        }
    }
    let _e679 = p;
    ps = _e679;
    let _e681 = pixelation_1;
    if (_e681 > 0.0001f) {
        let _e684 = p;
        let _e685 = pixelation_1;
        let _e692 = pixelation_1;
        ps = (floor(((_e684 / vec2(_e685)) + vec2(0.5f))) * _e692);
    }
    let _e694 = border;
    if _e694 {
        {
            let _e695 = uv_1;
            let _e699 = global.U[0];
            let _e702 = uv_1;
            let _e711 = textureSample(t_source, samp, ((vec2<f32>((_e695.x / _e699.x), _e702.y) / vec2(2f)) + vec2(0.5f)));
            col_1 = _e711;
            let _e713 = col_1;
            let _e715 = color_1;
            let _e717 = color_1;
            let _e720 = mix(_e713.xyz, _e715.xyz, vec3(_e717.w));
            let _e721 = col_1;
            return vec4<f32>(_e720.x, _e720.y, _e720.z, _e721.w);
        }
    }
    let _e727 = has2_;
    if !(_e727) {
        let _e729 = ps;
        let _e733 = global.U[0];
        let _e736 = ps;
        let _e745 = textureSample(t_source, samp, ((vec2<f32>((_e729.x / _e733.x), _e736.y) / vec2(2f)) + vec2(0.5f)));
        return _e745;
    }
    let _e747 = rect_2;
    let _e749 = rect_2;
    cc = (0.5f * (_e747.xy + _e749.zw));
    let _e754 = cc;
    let _e757 = windowTransform_1[2];
    d1_ = length((_e754 - _e757.xy));
    let _e762 = cc;
    let _e765 = windowTransform2_1[2];
    d2_ = length((_e762 - _e765.xy));
    let _e770 = d1_;
    let _e771 = d2_;
    let _e773 = d1_;
    let _e774 = d2_;
    prox = ((_e770 - _e771) / ((_e773 + _e774) + 0.0001f));
    let _e780 = cellId;
    let _e781 = randomSeed_1;
    let _e784 = rand2relSeeded(_e780, (_e781 + 77.7f));
    rnd2_ = (_e784.x * 2f);
    let _e789 = balance_1;
    biasTerm = ((_e789 - 0.5f) * 2f);
    let _e795 = biasTerm;
    let _e796 = rnd2_;
    let _e797 = prox;
    let _e798 = proximity_1;
    score = (_e795 + mix(_e796, _e797, _e798));
    let _e802 = score;
    if (_e802 > 0f) {
        let _e805 = ps;
        let _e809 = global.U[0];
        let _e812 = ps;
        let _e821 = textureSample(t_source2_, samp, ((vec2<f32>((_e805.x / _e809.x), _e812.y) / vec2(2f)) + vec2(0.5f)));
        local_6 = _e821;
    } else {
        let _e822 = ps;
        let _e826 = global.U[0];
        let _e829 = ps;
        let _e838 = textureSample(t_source, samp, ((vec2<f32>((_e822.x / _e826.x), _e829.y) / vec2(2f)) + vec2(0.5f)));
        local_6 = _e838;
    }
    let _e840 = local_6;
    return _e840;
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
    let _e71 = global.U[5];
    let _e75 = global.U[6];
    let _e79 = global.U[7];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e93 = global.U[11];
    let _e97 = global.U[12];
    let _e101 = global.U[13];
    let _e105 = global.U[14];
    let _e109 = global.U[15];
    let _e113 = global.U[16];
    let _e116 = global.U[17];
    let _e120 = global.U[8];
    let _e124 = global.U[18];
    let _e125 = _e124.xyz;
    let _e128 = global.U[19];
    let _e129 = _e128.xyz;
    let _e132 = global.U[20];
    let _e133 = _e132.xyz;
    let _e149 = global.U[21];
    let _e150 = _e149.xyz;
    let _e153 = global.U[22];
    let _e154 = _e153.xyz;
    let _e157 = global.U[23];
    let _e158 = _e157.xyz;
    let _e174 = global.U[24];
    let _e175 = _e174.xyz;
    let _e178 = global.U[25];
    let _e179 = _e178.xyz;
    let _e182 = global.U[26];
    let _e183 = _e182.xyz;
    let _e197 = schema3c((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.xy, _e75.xy, i32(_e79.x), _e84.x, i32(_e88.x), _e93.x, _e97.x, _e101.x, _e105.x, _e109.x, _e113, _e116.x, _e120.x, mat3x3<f32>(vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z)), mat3x3<f32>(vec3<f32>(_e150.x, _e150.y, _e150.z), vec3<f32>(_e154.x, _e154.y, _e154.z), vec3<f32>(_e158.x, _e158.y, _e158.z)), mat3x3<f32>(vec3<f32>(_e175.x, _e175.y, _e175.z), vec3<f32>(_e179.x, _e179.y, _e179.z), vec3<f32>(_e183.x, _e183.y, _e183.z)));
    fragColor = _e197;
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
