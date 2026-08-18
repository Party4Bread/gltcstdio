struct Params {
    U: array<vec4<f32>, 20>,
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
    let _e16 = splits_1;
    let _e17 = seed_3;
    let _e20 = rand2relSeeded(_e16, (_e17 + 122.1f));
    rnd = _e20;
    let _e22 = rect_1;
    let _e24 = rect_1;
    dx = (_e22.z - _e24.x);
    let _e28 = rect_1;
    let _e30 = rect_1;
    dy = (_e28.w - _e30.y);
    let _e34 = dx;
    let _e35 = dy;
    if (_e34 > _e35) {
        let _e37 = pos_1;
        let _e38 = rnd;
        let _e41 = dx;
        let _e43 = dy;
        let _e45 = intensity_1;
        return (_e37 + vec2<f32>(((((sign(_e38.x) * _e41) / _e43) * _e45) * 0.0005f), 0f));
    } else {
        let _e52 = pos_1;
        let _e54 = rnd;
        let _e57 = dy;
        let _e59 = dx;
        let _e61 = intensity_1;
        return (_e52 + vec2<f32>(0f, ((((sign(_e54.y) * _e57) / _e59) * _e61) * 0.0005f)));
    }
}

fn rounded(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e10 = x_2;
    let _e11 = prec_1;
    let _e16 = prec_1;
    return (floor(((_e10 / _e11) + 0.5f)) * _e16);
}

fn withBias(x_3: f32, b: f32) -> f32 {
    var x_4: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_1 = b;
    let _e10 = b_1;
    s = sign(_e10);
    let _e13 = b_1;
    ab = abs(_e13);
    let _e16 = x_4;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn schema3_(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>, intensity_2: f32, iterations: i32, pixelation: f32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, aspectRatio: f32, modelTransform: mat3x3<f32>, windowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var intensity_3: f32;
    var iterations_1: i32;
    var pixelation_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var aspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var windowTransform_1: mat3x3<f32>;
    var srcRatio: f32;
    var outAR: f32;
    var pixel: f32;
    var bias: vec2<f32>;
    var scale: f32;
    var th: f32;
    var ws: f32;
    var wl: vec2<f32>;
    var sxg: f32;
    var syg: f32;
    var col: vec4<f32>;
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
    var ex0_: f32;
    var ey0_: f32;
    var ex1_: f32;
    var ey1_: f32;
    var p: vec2<f32>;
    var border: bool = false;
    var rect_2: vec4<f32>;
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
    var local: f32;
    var X: f32;
    var local_1: f32;
    var ps: vec2<f32>;
    var col_1: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    intensity_3 = intensity_2;
    iterations_1 = iterations;
    pixelation_1 = pixelation;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    aspectRatio_1 = aspectRatio;
    modelTransform_1 = modelTransform;
    windowTransform_1 = windowTransform;
    let _e34 = sourceDim_1;
    let _e36 = sourceDim_1;
    let _e40 = rounded((_e34.x / _e36.y), 0.01f);
    srcRatio = _e40;
    let _e42 = outDim_1;
    let _e44 = outDim_1;
    let _e48 = rounded((_e42.x / _e44.y), 0.01f);
    outAR = _e48;
    let _e51 = outDim_1;
    pixel = (2f / _e51.y);
    let _e55 = modelTransform_1;
    bias = (_e55 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e68 = modelTransform_1[0][0];
    let _e73 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e68, _e73)));
    let _e78 = thickness_1;
    th = (_e78 * 0.1f);
    let _e84 = windowTransform_1[1];
    ws = length(_e84.xy);
    let _e88 = windowTransform_1;
    let _e90 = uv_1;
    wl = (_naga_inverse_3x3_f32(_e88) * vec3<f32>(_e90.x, _e90.y, 1f)).xy;
    let _e98 = srcRatio;
    let _e99 = wl;
    let _e103 = ws;
    sxg = ((_e98 - abs(_e99.x)) * _e103);
    let _e107 = wl;
    let _e111 = ws;
    syg = ((1f - abs(_e107.y)) * _e111);
    let _e114 = sxg;
    let _e117 = syg;
    if ((_e114 > 0f) && (_e117 > 0f)) {
        let _e121 = wl;
        let _e125 = global.U[0];
        let _e128 = wl;
        let _e138 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e121.x / _e125.x), _e128.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e138;
    }
    let _e139 = sxg;
    let _e141 = th;
    let _e143 = syg;
    let _e144 = th;
    let _e148 = syg;
    let _e150 = th;
    let _e152 = sxg;
    let _e153 = th;
    if (((abs(_e139) < _e141) && (_e143 > -(_e144))) || ((abs(_e148) < _e150) && (_e152 > -(_e153)))) {
        {
            let _e158 = uv_1;
            let _e162 = global.U[0];
            let _e165 = uv_1;
            let _e175 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e158.x / _e162.x), _e165.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e175;
            let _e177 = col;
            let _e179 = color_1;
            let _e181 = color_1;
            let _e184 = mix(_e177.xyz, _e179.xyz, vec3(_e181.w));
            let _e185 = col;
            return vec4<f32>(_e184.x, _e184.y, _e184.z, _e185.w);
        }
    }
    let _e191 = srcRatio;
    let _e194 = windowTransform_1[0];
    winA = (_e191 * length(_e194.xy));
    let _e199 = ws;
    winB = _e199;
    let _e203 = windowTransform_1[0];
    wax = normalize(_e203.xy);
    let _e207 = wax;
    c1_ = abs(_e207.x);
    let _e211 = wax;
    s1_ = abs(_e211.y);
    let _e216 = c1_;
    let _e218 = s1_;
    sin2_ = ((2f * _e216) * _e218);
    let _e223 = winA;
    let _e224 = winB;
    let _e225 = sin2_;
    if (_e223 <= (_e224 * _e225)) {
        {
            let _e228 = winA;
            let _e230 = c1_;
            W = (_e228 / (2f * _e230));
            let _e233 = winA;
            let _e235 = s1_;
            H = (_e233 / (2f * _e235));
        }
    } else {
        let _e238 = winB;
        let _e239 = winA;
        let _e240 = sin2_;
        if (_e238 <= (_e239 * _e240)) {
            {
                let _e243 = winB;
                let _e245 = s1_;
                W = (_e243 / (2f * _e245));
                let _e248 = winB;
                let _e250 = c1_;
                H = (_e248 / (2f * _e250));
            }
        } else {
            {
                let _e253 = c1_;
                let _e254 = c1_;
                let _e256 = s1_;
                let _e257 = s1_;
                det = ((_e253 * _e254) - (_e256 * _e257));
                let _e261 = winA;
                let _e262 = c1_;
                let _e264 = winB;
                let _e265 = s1_;
                let _e268 = det;
                W = (((_e261 * _e262) - (_e264 * _e265)) / _e268);
                let _e270 = winB;
                let _e271 = c1_;
                let _e273 = winA;
                let _e274 = s1_;
                let _e277 = det;
                H = (((_e270 * _e271) - (_e273 * _e274)) / _e277);
            }
        }
    }
    let _e279 = W;
    W = max(_e279, 0f);
    let _e282 = H;
    H = max(_e282, 0f);
    let _e287 = windowTransform_1[2];
    wc = _e287.xy;
    let _e290 = wc;
    let _e292 = W;
    ex0_ = (_e290.x - _e292);
    let _e295 = wc;
    let _e297 = H;
    ey0_ = (_e295.y - _e297);
    let _e300 = wc;
    let _e302 = W;
    ex1_ = (_e300.x + _e302);
    let _e305 = wc;
    let _e307 = H;
    ey1_ = (_e305.y + _e307);
    let _e310 = uv_1;
    p = _e310;
    let _e316 = variability_1;
    regularity = (1f - _e316);
    loop {
        let _e321 = j;
        let _e322 = iterations_1;
        if !((_e321 < _e322)) {
            break;
        }
        {
            let _e328 = outAR;
            let _e332 = outAR;
            rect_2 = vec4<f32>(-(_e328), -1f, _e332, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e347 = bias;
            b_2 = _e347;
            i = 0f;
            loop {
                let _e351 = i;
                let _e352 = sPos;
                let _e354 = scale;
                if !(((_e351 + _e352) < _e354)) {
                    break;
                }
                {
                    let _e360 = splits_2;
                    let _e361 = randomSeed_1;
                    let _e364 = rand2relSeeded(_e360, (_e361 + 122.1f));
                    rnd_1 = _e364;
                    let _e366 = rect_2;
                    let _e368 = rect_2;
                    size = (_e366.zw - _e368.xy);
                    let _e372 = size;
                    let _e374 = pixel;
                    let _e376 = size;
                    let _e378 = pixel;
                    if ((_e372.x < _e374) || (_e376.y < _e378)) {
                        break;
                    }
                    let _e381 = rnd_1;
                    let _e385 = regularity;
                    if ((_e381.x + 0.5f) < (_e385 * 2f)) {
                        let _e389 = size;
                        let _e391 = size;
                        horSplit = (_e389.y > _e391.x);
                    }
                    let _e396 = regularity;
                    var2_ = (1f - max(0f, ((_e396 * 2f) - 1f)));
                    let _e404 = horSplit;
                    if _e404 {
                        {
                            let _e405 = rect_2;
                            let _e407 = rect_2;
                            let _e409 = var2_;
                            let _e410 = rnd_1;
                            let _e412 = b_2;
                            let _e414 = withBias(_e410.y, _e412.y);
                            Y = mix(_e405.y, _e407.w, ((_e409 * _e414) + 0.5f));
                            let _e420 = rect_2;
                            let _e422 = ex1_;
                            let _e424 = rect_2;
                            let _e426 = ex0_;
                            let _e429 = Y;
                            let _e430 = ey0_;
                            let _e433 = Y;
                            let _e434 = ey1_;
                            if ((((_e420.x < _e422) && (_e424.z > _e426)) && (_e429 > _e430)) && (_e433 < _e434)) {
                                let _e437 = Y;
                                let _e438 = ey0_;
                                let _e440 = ey1_;
                                let _e441 = Y;
                                if ((_e437 - _e438) < (_e440 - _e441)) {
                                    let _e444 = ey0_;
                                    local = _e444;
                                } else {
                                    let _e445 = ey1_;
                                    local = _e445;
                                }
                                let _e447 = local;
                                Y = _e447;
                            }
                            let _e448 = Y;
                            let _e449 = p;
                            let _e453 = th;
                            if (abs((_e448 - _e449.y)) < _e453) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e456 = p;
                            let _e458 = Y;
                            if (_e456.y < _e458) {
                                {
                                    let _e461 = Y;
                                    rect_2.w = _e461;
                                    let _e463 = splits_2.y;
                                    splits_2.y = (_e463 + 1f);
                                    let _e466 = sPos;
                                    let _e467 = inverter;
                                    let _e468 = sscale;
                                    sPos = (_e466 + (_e467 * _e468));
                                }
                            } else {
                                {
                                    let _e472 = Y;
                                    rect_2.y = _e472;
                                    let _e474 = splits_2;
                                    splits_2.y = (_e474.y + 100f);
                                    let _e478 = sPos;
                                    let _e480 = inverter;
                                    let _e482 = sscale;
                                    sPos = (_e478 + ((1f - _e480) * _e482));
                                }
                            }
                        }
                    } else {
                        {
                            let _e485 = rect_2;
                            let _e487 = rect_2;
                            let _e489 = var2_;
                            let _e490 = rnd_1;
                            let _e492 = b_2;
                            let _e494 = withBias(_e490.x, _e492.x);
                            X = mix(_e485.x, _e487.z, ((_e489 * _e494) + 0.5f));
                            let _e500 = rect_2;
                            let _e502 = ey1_;
                            let _e504 = rect_2;
                            let _e506 = ey0_;
                            let _e509 = X;
                            let _e510 = ex0_;
                            let _e513 = X;
                            let _e514 = ex1_;
                            if ((((_e500.y < _e502) && (_e504.w > _e506)) && (_e509 > _e510)) && (_e513 < _e514)) {
                                let _e517 = X;
                                let _e518 = ex0_;
                                let _e520 = ex1_;
                                let _e521 = X;
                                if ((_e517 - _e518) < (_e520 - _e521)) {
                                    let _e524 = ex0_;
                                    local_1 = _e524;
                                } else {
                                    let _e525 = ex1_;
                                    local_1 = _e525;
                                }
                                let _e527 = local_1;
                                X = _e527;
                            }
                            let _e528 = X;
                            let _e529 = p;
                            let _e533 = th;
                            if (abs((_e528 - _e529.x)) < _e533) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e536 = p;
                            let _e538 = X;
                            if (_e536.x < _e538) {
                                {
                                    let _e541 = X;
                                    rect_2.z = _e541;
                                    let _e543 = splits_2.x;
                                    splits_2.x = (_e543 + 1f);
                                    let _e546 = sPos;
                                    let _e547 = inverter;
                                    let _e548 = sscale;
                                    sPos = (_e546 + (_e547 * _e548));
                                }
                            } else {
                                {
                                    let _e552 = X;
                                    rect_2.x = _e552;
                                    let _e554 = splits_2;
                                    splits_2.x = (_e554.x + 100f);
                                    let _e558 = sPos;
                                    let _e560 = inverter;
                                    let _e562 = sscale;
                                    sPos = (_e558 + ((1f - _e560) * _e562));
                                }
                            }
                        }
                    }
                    let _e565 = horSplit;
                    horSplit = !(_e565);
                    let _e568 = inverter;
                    inverter = (1f - _e568);
                    let _e570 = sscale;
                    sscale = (_e570 * 0.5f);
                    let _e573 = b_2;
                    b_2 = (_e573 * 0.5f);
                }
                continuing {
                    let _e357 = i;
                    i = (_e357 + 1f);
                }
            }
            let _e576 = border;
            if _e576 {
                break;
            }
            let _e577 = p;
            let _e578 = rect_2;
            let _e579 = splits_2;
            let _e580 = intensity_3;
            let _e581 = randomSeed_1;
            let _e582 = distort9_(_e577, _e578, _e579, _e580, _e581);
            p = _e582;
        }
        continuing {
            let _e325 = j;
            j = (_e325 + 1i);
        }
    }
    let _e583 = p;
    ps = _e583;
    let _e585 = pixelation_1;
    if (_e585 > 0.0001f) {
        let _e588 = p;
        let _e589 = pixelation_1;
        let _e596 = pixelation_1;
        ps = (floor(((_e588 / vec2(_e589)) + vec2(0.5f))) * _e596);
    }
    let _e598 = border;
    if _e598 {
        {
            let _e599 = uv_1;
            let _e603 = global.U[0];
            let _e606 = uv_1;
            let _e616 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e599.x / _e603.x), _e606.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col_1 = _e616;
            let _e618 = col_1;
            let _e620 = color_1;
            let _e622 = color_1;
            let _e625 = mix(_e618.xyz, _e620.xyz, vec3(_e622.w));
            let _e626 = col_1;
            return vec4<f32>(_e625.x, _e625.y, _e625.z, _e626.w);
        }
    }
    let _e632 = ps;
    let _e636 = global.U[0];
    let _e639 = ps;
    let _e649 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e632.x / _e636.x), _e639.y) / vec2(2f)) + vec2(0.5f)), 0f);
    return _e649;
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
    let _e66 = global.U[4];
    let _e70 = global.U[5];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[6];
    let _e106 = global.U[14];
    let _e107 = _e106.xyz;
    let _e110 = global.U[15];
    let _e111 = _e110.xyz;
    let _e114 = global.U[16];
    let _e115 = _e114.xyz;
    let _e131 = global.U[17];
    let _e132 = _e131.xyz;
    let _e135 = global.U[18];
    let _e136 = _e135.xyz;
    let _e139 = global.U[19];
    let _e140 = _e139.xyz;
    let _e154 = schema3_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.xy, _e74.x, i32(_e78.x), _e83.x, _e87.x, _e91.x, _e95, _e98.x, _e102.x, mat3x3<f32>(vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z)), mat3x3<f32>(vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z), vec3<f32>(_e140.x, _e140.y, _e140.z)));
    fragColor = _e154;
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
