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
        let _e165 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e148.x / _e152.x), _e155.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e165;
    }
    let _e166 = sxg1_;
    let _e168 = th;
    let _e170 = syg1_;
    let _e171 = th;
    let _e175 = syg1_;
    let _e177 = th;
    let _e179 = sxg1_;
    let _e180 = th;
    frame = (((abs(_e166) < _e168) && (_e170 > -(_e171))) || ((abs(_e175) < _e177) && (_e179 > -(_e180))));
    let _e186 = has2_;
    if _e186 {
        {
            let _e189 = windowTransform2_1[1];
            ws2_ = length(_e189.xy);
            let _e193 = windowTransform2_1;
            let _e195 = uv_1;
            wl2_ = (_naga_inverse_3x3_f32(_e193) * vec3<f32>(_e195.x, _e195.y, 1f)).xy;
            let _e203 = src2Ratio;
            let _e204 = wl2_;
            let _e208 = ws2_;
            sxg2_ = ((_e203 - abs(_e204.x)) * _e208);
            let _e212 = wl2_;
            let _e216 = ws2_;
            syg2_ = ((1f - abs(_e212.y)) * _e216);
            let _e219 = sxg2_;
            let _e222 = syg2_;
            if ((_e219 > 0f) && (_e222 > 0f)) {
                let _e226 = wl2_;
                let _e230 = global.U[0];
                let _e233 = wl2_;
                let _e243 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e226.x / _e230.x), _e233.y) / vec2(2f)) + vec2(0.5f)), 0f);
                return _e243;
            }
            let _e244 = frame;
            let _e245 = sxg2_;
            let _e247 = th;
            let _e249 = syg2_;
            let _e250 = th;
            let _e255 = syg2_;
            let _e257 = th;
            let _e259 = sxg2_;
            let _e260 = th;
            frame = ((_e244 || ((abs(_e245) < _e247) && (_e249 > -(_e250)))) || ((abs(_e255) < _e257) && (_e259 > -(_e260))));
        }
    }
    let _e265 = frame;
    if _e265 {
        {
            let _e266 = uv_1;
            let _e270 = global.U[0];
            let _e273 = uv_1;
            let _e283 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e266.x / _e270.x), _e273.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e283;
            let _e285 = col;
            let _e287 = color_1;
            let _e289 = color_1;
            let _e292 = mix(_e285.xyz, _e287.xyz, vec3(_e289.w));
            let _e293 = col;
            return vec4<f32>(_e292.x, _e292.y, _e292.z, _e293.w);
        }
    }
    let _e299 = windowTransform_1;
    let _e300 = srcRatio_2;
    let _e301 = inscribedRect(_e299, _e300);
    E1_ = _e301;
    let _e303 = has2_;
    if _e303 {
        let _e304 = windowTransform2_1;
        let _e305 = src2Ratio;
        let _e306 = inscribedRect(_e304, _e305);
        local_1 = _e306;
    } else {
        local_1 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e315 = local_1;
    E2_ = _e315;
    let _e317 = uv_1;
    p = _e317;
    let _e326 = variability_1;
    regularity = (1f - _e326);
    loop {
        let _e331 = j;
        let _e332 = iterations_1;
        if !((_e331 < _e332)) {
            break;
        }
        {
            let _e338 = outAR;
            let _e342 = outAR;
            rect_2 = vec4<f32>(-(_e338), -1f, _e342, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e357 = bias;
            b_2 = _e357;
            i = 0f;
            loop {
                let _e361 = i;
                let _e362 = sPos;
                let _e364 = scale;
                if !(((_e361 + _e362) < _e364)) {
                    break;
                }
                {
                    let _e370 = splits_2;
                    let _e371 = randomSeed_1;
                    let _e374 = rand2relSeeded(_e370, (_e371 + 122.1f));
                    rnd_1 = _e374;
                    let _e376 = rect_2;
                    let _e378 = rect_2;
                    size = (_e376.zw - _e378.xy);
                    let _e382 = size;
                    let _e384 = pixel;
                    let _e386 = size;
                    let _e388 = pixel;
                    if ((_e382.x < _e384) || (_e386.y < _e388)) {
                        break;
                    }
                    let _e391 = rnd_1;
                    let _e395 = regularity;
                    if ((_e391.x + 0.5f) < (_e395 * 2f)) {
                        let _e399 = size;
                        let _e401 = size;
                        horSplit = (_e399.y > _e401.x);
                    }
                    let _e406 = regularity;
                    var2_ = (1f - max(0f, ((_e406 * 2f) - 1f)));
                    let _e414 = horSplit;
                    if _e414 {
                        {
                            let _e415 = rect_2;
                            let _e417 = rect_2;
                            let _e419 = var2_;
                            let _e420 = rnd_1;
                            let _e422 = b_2;
                            let _e424 = withBias(_e420.y, _e422.y);
                            Y = mix(_e415.y, _e417.w, ((_e419 * _e424) + 0.5f));
                            let _e430 = rect_2;
                            let _e432 = E1_;
                            let _e435 = rect_2;
                            let _e437 = E1_;
                            let _e441 = Y;
                            let _e442 = E1_;
                            let _e446 = Y;
                            let _e447 = E1_;
                            if ((((_e430.x < _e432.z) && (_e435.z > _e437.x)) && (_e441 > _e442.y)) && (_e446 < _e447.w)) {
                                let _e451 = Y;
                                let _e452 = E1_;
                                let _e455 = E1_;
                                let _e457 = Y;
                                if ((_e451 - _e452.y) < (_e455.w - _e457)) {
                                    let _e460 = E1_;
                                    local_2 = _e460.y;
                                } else {
                                    let _e462 = E1_;
                                    local_2 = _e462.w;
                                }
                                let _e465 = local_2;
                                Y = _e465;
                            }
                            let _e466 = rect_2;
                            let _e468 = E2_;
                            let _e471 = rect_2;
                            let _e473 = E2_;
                            let _e477 = Y;
                            let _e478 = E2_;
                            let _e482 = Y;
                            let _e483 = E2_;
                            if ((((_e466.x < _e468.z) && (_e471.z > _e473.x)) && (_e477 > _e478.y)) && (_e482 < _e483.w)) {
                                let _e487 = Y;
                                let _e488 = E2_;
                                let _e491 = E2_;
                                let _e493 = Y;
                                if ((_e487 - _e488.y) < (_e491.w - _e493)) {
                                    let _e496 = E2_;
                                    local_3 = _e496.y;
                                } else {
                                    let _e498 = E2_;
                                    local_3 = _e498.w;
                                }
                                let _e501 = local_3;
                                Y = _e501;
                            }
                            let _e502 = Y;
                            let _e503 = p;
                            let _e507 = th;
                            if (abs((_e502 - _e503.y)) < _e507) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e510 = p;
                            let _e512 = Y;
                            if (_e510.y < _e512) {
                                {
                                    let _e515 = Y;
                                    rect_2.w = _e515;
                                    let _e517 = splits_2.y;
                                    splits_2.y = (_e517 + 1f);
                                    let _e520 = sPos;
                                    let _e521 = inverter;
                                    let _e522 = sscale;
                                    sPos = (_e520 + (_e521 * _e522));
                                }
                            } else {
                                {
                                    let _e526 = Y;
                                    rect_2.y = _e526;
                                    let _e528 = splits_2;
                                    splits_2.y = (_e528.y + 100f);
                                    let _e532 = sPos;
                                    let _e534 = inverter;
                                    let _e536 = sscale;
                                    sPos = (_e532 + ((1f - _e534) * _e536));
                                }
                            }
                        }
                    } else {
                        {
                            let _e539 = rect_2;
                            let _e541 = rect_2;
                            let _e543 = var2_;
                            let _e544 = rnd_1;
                            let _e546 = b_2;
                            let _e548 = withBias(_e544.x, _e546.x);
                            X = mix(_e539.x, _e541.z, ((_e543 * _e548) + 0.5f));
                            let _e554 = rect_2;
                            let _e556 = E1_;
                            let _e559 = rect_2;
                            let _e561 = E1_;
                            let _e565 = X;
                            let _e566 = E1_;
                            let _e570 = X;
                            let _e571 = E1_;
                            if ((((_e554.y < _e556.w) && (_e559.w > _e561.y)) && (_e565 > _e566.x)) && (_e570 < _e571.z)) {
                                let _e575 = X;
                                let _e576 = E1_;
                                let _e579 = E1_;
                                let _e581 = X;
                                if ((_e575 - _e576.x) < (_e579.z - _e581)) {
                                    let _e584 = E1_;
                                    local_4 = _e584.x;
                                } else {
                                    let _e586 = E1_;
                                    local_4 = _e586.z;
                                }
                                let _e589 = local_4;
                                X = _e589;
                            }
                            let _e590 = rect_2;
                            let _e592 = E2_;
                            let _e595 = rect_2;
                            let _e597 = E2_;
                            let _e601 = X;
                            let _e602 = E2_;
                            let _e606 = X;
                            let _e607 = E2_;
                            if ((((_e590.y < _e592.w) && (_e595.w > _e597.y)) && (_e601 > _e602.x)) && (_e606 < _e607.z)) {
                                let _e611 = X;
                                let _e612 = E2_;
                                let _e615 = E2_;
                                let _e617 = X;
                                if ((_e611 - _e612.x) < (_e615.z - _e617)) {
                                    let _e620 = E2_;
                                    local_5 = _e620.x;
                                } else {
                                    let _e622 = E2_;
                                    local_5 = _e622.z;
                                }
                                let _e625 = local_5;
                                X = _e625;
                            }
                            let _e626 = X;
                            let _e627 = p;
                            let _e631 = th;
                            if (abs((_e626 - _e627.x)) < _e631) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e634 = p;
                            let _e636 = X;
                            if (_e634.x < _e636) {
                                {
                                    let _e639 = X;
                                    rect_2.z = _e639;
                                    let _e641 = splits_2.x;
                                    splits_2.x = (_e641 + 1f);
                                    let _e644 = sPos;
                                    let _e645 = inverter;
                                    let _e646 = sscale;
                                    sPos = (_e644 + (_e645 * _e646));
                                }
                            } else {
                                {
                                    let _e650 = X;
                                    rect_2.x = _e650;
                                    let _e652 = splits_2;
                                    splits_2.x = (_e652.x + 100f);
                                    let _e656 = sPos;
                                    let _e658 = inverter;
                                    let _e660 = sscale;
                                    sPos = (_e656 + ((1f - _e658) * _e660));
                                }
                            }
                        }
                    }
                    let _e663 = horSplit;
                    horSplit = !(_e663);
                    let _e666 = inverter;
                    inverter = (1f - _e666);
                    let _e668 = sscale;
                    sscale = (_e668 * 0.5f);
                    let _e671 = b_2;
                    b_2 = (_e671 * 0.5f);
                }
                continuing {
                    let _e367 = i;
                    i = (_e367 + 1f);
                }
            }
            let _e674 = border;
            if _e674 {
                break;
            }
            let _e675 = splits_2;
            cellId = _e675;
            let _e676 = p;
            let _e677 = rect_2;
            let _e678 = splits_2;
            let _e679 = intensity_3;
            let _e680 = randomSeed_1;
            let _e681 = distort9_(_e676, _e677, _e678, _e679, _e680);
            p = _e681;
        }
        continuing {
            let _e335 = j;
            j = (_e335 + 1i);
        }
    }
    let _e682 = p;
    ps = _e682;
    let _e684 = pixelation_1;
    if (_e684 > 0.0001f) {
        let _e687 = p;
        let _e688 = pixelation_1;
        let _e695 = pixelation_1;
        ps = (floor(((_e687 / vec2(_e688)) + vec2(0.5f))) * _e695);
    }
    let _e697 = border;
    if _e697 {
        {
            let _e698 = uv_1;
            let _e702 = global.U[0];
            let _e705 = uv_1;
            let _e715 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e698.x / _e702.x), _e705.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col_1 = _e715;
            let _e717 = col_1;
            let _e719 = color_1;
            let _e721 = color_1;
            let _e724 = mix(_e717.xyz, _e719.xyz, vec3(_e721.w));
            let _e725 = col_1;
            return vec4<f32>(_e724.x, _e724.y, _e724.z, _e725.w);
        }
    }
    let _e731 = has2_;
    if !(_e731) {
        let _e733 = ps;
        let _e737 = global.U[0];
        let _e740 = ps;
        let _e750 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e733.x / _e737.x), _e740.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e750;
    }
    let _e752 = rect_2;
    let _e754 = rect_2;
    cc = (0.5f * (_e752.xy + _e754.zw));
    let _e759 = cc;
    let _e762 = windowTransform_1[2];
    d1_ = length((_e759 - _e762.xy));
    let _e767 = cc;
    let _e770 = windowTransform2_1[2];
    d2_ = length((_e767 - _e770.xy));
    let _e775 = d1_;
    let _e776 = d2_;
    let _e778 = d1_;
    let _e779 = d2_;
    prox = ((_e775 - _e776) / ((_e778 + _e779) + 0.0001f));
    let _e785 = cellId;
    let _e786 = randomSeed_1;
    let _e789 = rand2relSeeded(_e785, (_e786 + 77.7f));
    rnd2_ = (_e789.x * 2f);
    let _e794 = balance_1;
    biasTerm = ((_e794 - 0.5f) * 2f);
    let _e800 = biasTerm;
    let _e801 = rnd2_;
    let _e802 = prox;
    let _e803 = proximity_1;
    score = (_e800 + mix(_e801, _e802, _e803));
    let _e807 = score;
    if (_e807 > 0f) {
        let _e810 = ps;
        let _e814 = global.U[0];
        let _e817 = ps;
        let _e827 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e810.x / _e814.x), _e817.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_6 = _e827;
    } else {
        let _e828 = ps;
        let _e832 = global.U[0];
        let _e835 = ps;
        let _e845 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e828.x / _e832.x), _e835.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_6 = _e845;
    }
    let _e847 = local_6;
    return _e847;
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
