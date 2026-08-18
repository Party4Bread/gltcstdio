struct Params {
    U: array<vec4<f32>, 15>,
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

fn center(c: f32, delta: f32) -> f32 {
    var c_1: f32;
    var delta_1: f32;
    var local: f32;

    c_1 = c;
    delta_1 = delta;
    let _e10 = delta_1;
    if (_e10 < 0f) {
        let _e14 = c_1;
        let _e15 = delta_1;
        local = mix(0f, _e14, ((_e15 * 2f) + 1f));
    } else {
        let _e21 = c_1;
        let _e23 = delta_1;
        local = mix(_e21, 1f, (_e23 * 2f));
    }
    let _e28 = local;
    return _e28;
}

fn inQuad(p: vec2<f32>, E: vec2<f32>, F: vec2<f32>, A: vec2<f32>, B: vec2<f32>) -> bool {
    var p_1: vec2<f32>;
    var E_1: vec2<f32>;
    var F_1: vec2<f32>;
    var A_1: vec2<f32>;
    var B_1: vec2<f32>;
    var EA: vec2<f32>;
    var lea: f32;
    var FB: vec2<f32>;
    var lfb: f32;
    var Fp: vec2<f32>;
    var lfp: f32;
    var FE: vec2<f32>;
    var Ep: vec2<f32>;
    var lep: f32;
    var EF: vec2<f32>;

    p_1 = p;
    E_1 = E;
    F_1 = F;
    A_1 = A;
    B_1 = B;
    let _e16 = A_1;
    let _e17 = E_1;
    EA = (_e16 - _e17);
    let _e20 = EA;
    lea = length(_e20);
    let _e23 = lea;
    if (_e23 == 0f) {
        {
            let _e26 = B_1;
            let _e27 = F_1;
            FB = (_e26 - _e27);
            let _e30 = FB;
            lfb = length(_e30);
            let _e33 = lfb;
            if (_e33 == 0f) {
                return false;
            }
            let _e37 = FB;
            let _e38 = lfb;
            FB = (_e37 / vec2(_e38));
            let _e41 = p_1;
            let _e42 = F_1;
            Fp = (_e41 - _e42);
            let _e45 = Fp;
            lfp = length(_e45);
            let _e48 = lfp;
            if (_e48 == 0f) {
                return true;
            }
            let _e52 = Fp;
            let _e53 = lfp;
            Fp = (_e52 / vec2(_e53));
            let _e56 = E_1;
            let _e57 = F_1;
            FE = normalize((_e56 - _e57));
            let _e61 = FE;
            let _e62 = FB;
            let _e64 = Fp;
            let _e65 = FB;
            return (dot(_e61, _e62) < dot(_e64, _e65));
        }
    } else {
        {
            let _e68 = EA;
            let _e69 = lea;
            EA = (_e68 / vec2(_e69));
            let _e72 = p_1;
            let _e73 = E_1;
            Ep = (_e72 - _e73);
            let _e76 = Ep;
            lep = length(_e76);
            let _e79 = lep;
            if (_e79 == 0f) {
                return true;
            }
            let _e83 = Ep;
            let _e84 = lep;
            Ep = (_e83 / vec2(_e84));
            let _e87 = F_1;
            let _e88 = E_1;
            EF = normalize((_e87 - _e88));
            let _e92 = EF;
            let _e93 = EA;
            let _e95 = Ep;
            let _e96 = EA;
            return (dot(_e92, _e93) < dot(_e95, _e96));
        }
    }
}

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

fn round2_(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e10 = x_2;
    let _e11 = prec_1;
    let _e16 = prec_1;
    return (floor(((_e10 / _e11) + 0.5f)) * _e16);
}

fn segDist(p_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ab: vec2<f32>;
    var abLen: f32;
    var abNorm: vec2<f32>;
    var ap: vec2<f32>;
    var abProj: f32;

    p_3 = p_2;
    a_1 = a;
    b_1 = b;
    let _e12 = b_1;
    let _e13 = a_1;
    ab = (_e12 - _e13);
    let _e16 = ab;
    abLen = length(_e16);
    let _e19 = abLen;
    if (_e19 == 0f) {
        let _e22 = p_3;
        let _e23 = a_1;
        return length((_e22 - _e23));
    }
    let _e26 = ab;
    let _e27 = abLen;
    abNorm = (_e26 / vec2(_e27));
    let _e31 = p_3;
    let _e32 = a_1;
    ap = (_e31 - _e32);
    let _e35 = ap;
    let _e36 = abNorm;
    abProj = dot(_e35, _e36);
    let _e39 = abProj;
    let _e42 = abProj;
    let _e43 = abLen;
    if ((_e39 >= 0f) && (_e42 <= _e43)) {
        {
            let _e46 = ap;
            let _e47 = abNorm;
            let _e49 = abNorm;
            return abs(dot(_e46, vec2<f32>(_e47.y, -(_e49.x))));
        }
    } else {
        {
            let _e55 = ap;
            let _e57 = p_3;
            let _e58 = b_1;
            return min(length(_e55), length((_e57 - _e58)));
        }
    }
}

fn withBias(x_3: f32, b_2: f32) -> f32 {
    var x_4: f32;
    var b_3: f32;
    var s: f32;
    var ab_1: f32;

    x_4 = x_3;
    b_3 = b_2;
    let _e10 = b_3;
    s = sign(_e10);
    let _e13 = b_3;
    ab_1 = abs(_e13);
    let _e16 = x_4;
    let _e20 = s;
    let _e22 = ab_1;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn shards(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, borderColor: vec4<f32>, thickness: f32, regularity: f32, randomSeed: f32, balance: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var borderColor_1: vec4<f32>;
    var thickness_1: f32;
    var regularity_1: f32;
    var randomSeed_1: f32;
    var balance_1: f32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var ratio: f32;
    var pixel: f32;
    var quad0_: vec2<f32>;
    var quad1_: vec2<f32>;
    var quad2_: vec2<f32>;
    var quad3_: vec2<f32>;
    var abSplit: bool = true;
    var border: f32 = 0f;
    var splitsX: f32 = 0f;
    var splitsY: f32 = 0f;
    var bias: vec2<f32>;
    var scale: f32;
    var sPos: f32 = 0f;
    var sscale: f32 = 0.5f;
    var inverter: f32 = 0f;
    var count: f32 = 0f;
    var borderThick: f32;
    var borderTransition: f32;
    var borderAA: f32;
    var borderBB: f32;
    var i: f32 = 0f;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var lenAB: f32;
    var lenAC: f32;
    var variability: f32;
    var deviate: f32;
    var devEx: f32;
    var devFx: f32;
    var devEy: f32;
    var devFy: f32;
    var cEx: f32;
    var cEy: f32;
    var cFx: f32;
    var cFy: f32;
    var E_2: vec2<f32>;
    var F_2: vec2<f32>;
    var bDist: f32;
    var x_5: f32;
    var EA_1: vec2<f32>;
    var EF_1: vec2<f32>;
    var E_3: vec2<f32>;
    var F_3: vec2<f32>;
    var bDist_1: f32;
    var x_6: f32;
    var EA_2: vec2<f32>;
    var EF_2: vec2<f32>;
    var samplePos: vec2<f32>;
    var col: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    borderColor_1 = borderColor;
    thickness_1 = thickness;
    regularity_1 = regularity;
    randomSeed_1 = randomSeed;
    balance_1 = balance;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e26 = sourceDim_1;
    let _e28 = sourceDim_1;
    let _e32 = round2_((_e26.x / _e28.y), 0.01f);
    ratio = _e32;
    let _e35 = sourceDim_1;
    pixel = (2f / _e35.y);
    let _e39 = ratio;
    quad0_ = vec2<f32>(-(_e39), -1f);
    let _e45 = ratio;
    quad1_ = vec2<f32>(_e45, -1f);
    let _e50 = ratio;
    quad2_ = vec2<f32>(-(_e50), 1f);
    let _e55 = ratio;
    quad3_ = vec2<f32>(_e55, 1f);
    let _e67 = modelTransform_1;
    bias = (_e67 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e78 = modelTransform_1[0];
    scale = (1f / length(_e78.xy));
    let _e91 = thickness_1;
    borderThick = (_e91 * 0.05f);
    let _e95 = pixel;
    let _e96 = borderThick;
    borderTransition = (min(_e95, (_e96 * 0.3f)) * 0.5f);
    let _e103 = borderThick;
    let _e104 = pixel;
    let _e107 = pixel;
    let _e108 = borderThick;
    let _e112 = pixel;
    borderAA = (_e103 - ((smoothstep((_e104 * 0.5f), _e107, _e108) * 0.5f) * _e112));
    let _e116 = borderThick;
    let _e117 = pixel;
    borderBB = (_e116 + (_e117 * 0.5f));
    loop {
        let _e124 = i;
        let _e125 = sPos;
        let _e127 = scale;
        if !(((_e124 + _e125) < _e127)) {
            break;
        }
        {
            let _e137 = splitsX;
            let _e138 = splitsY;
            let _e141 = randomSeed_1;
            let _e144 = rand2relSeeded((vec2<f32>(-4f, 3f) + vec2<f32>(_e137, _e138)), (_e141 + 122.1f));
            rnd = _e144;
            let _e146 = quad0_;
            let _e147 = quad3_;
            let _e150 = quad1_;
            let _e151 = quad2_;
            size = max(abs((_e146 - _e147)), abs((_e150 - _e151))).xy;
            let _e157 = size;
            let _e159 = pixel;
            let _e161 = size;
            let _e163 = pixel;
            if ((_e157.x < _e159) || (_e161.y < _e163)) {
                break;
            }
            let _e166 = quad0_;
            let _e168 = quad1_;
            let _e172 = quad2_;
            let _e174 = quad3_;
            lenAB = (length((_e166.xy - _e168.xy)) + length((_e172.xy - _e174.xy)));
            let _e180 = quad0_;
            let _e182 = quad2_;
            let _e186 = quad1_;
            let _e188 = quad3_;
            lenAC = (length((_e180.xy - _e182.xy)) + length((_e186.xy - _e188.xy)));
            let _e194 = rnd;
            let _e198 = regularity_1;
            if ((_e194.x + 0.5f) < (_e198 * 2f)) {
                let _e202 = lenAB;
                let _e203 = lenAC;
                abSplit = (_e202 > _e203);
            }
            let _e207 = regularity_1;
            variability = (1f - max(0f, ((_e207 * 2f) - 1f)));
            let _e215 = balance_1;
            deviate = _e215;
            let _e217 = rnd;
            let _e219 = deviate;
            devEx = clamp((_e217.x + _e219), -1f, 1f);
            let _e226 = rnd;
            let _e228 = deviate;
            devFx = clamp((_e226.y + _e228), -1f, 1f);
            let _e235 = devEx;
            devEy = _e235;
            let _e237 = devFx;
            devFy = _e237;
            cEx = 0.5f;
            cEy = 0.5f;
            cFx = 0.5f;
            cFy = 0.5f;
            let _e247 = mode_1;
            if (_e247 == 1i) {
                {
                    let _e250 = devEx;
                    devEx = -(_e250);
                    let _e252 = devFy;
                    devFy = -(_e252);
                }
            } else {
                let _e254 = mode_1;
                if (_e254 == 3i) {
                    {
                        let _e257 = devEy;
                        devEy = -(_e257);
                    }
                } else {
                    let _e259 = mode_1;
                    if (_e259 == 4i) {
                        {
                            cEx = 0.1f;
                        }
                    } else {
                        let _e263 = mode_1;
                        if (_e263 == 5i) {
                            {
                                cEx = 0.7f;
                                cEy = 0.7f;
                            }
                        } else {
                            let _e268 = mode_1;
                            if (_e268 == 6i) {
                                {
                                    cEx = 0.2f;
                                    let _e273 = cEx;
                                    cFx = (1f - _e273);
                                    cEy = 0.8f;
                                    let _e277 = cEy;
                                    cFy = (1f - _e277);
                                }
                            } else {
                                let _e279 = mode_1;
                                if (_e279 == 7i) {
                                    {
                                        cEx = 0.2f;
                                        let _e284 = cEx;
                                        cFx = (1f - _e284);
                                        cEy = 0.2f;
                                        let _e288 = cEy;
                                        cFy = (1f - _e288);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let _e290 = abSplit;
            if _e290 {
                {
                    let _e291 = quad0_;
                    let _e292 = quad1_;
                    let _e293 = cEx;
                    let _e294 = variability;
                    let _e295 = devEx;
                    let _e296 = bias;
                    let _e298 = withBias(_e295, _e296.x);
                    let _e300 = center(_e293, (_e294 * _e298));
                    E_2 = mix(_e291, _e292, vec2(_e300));
                    let _e304 = quad2_;
                    let _e305 = quad3_;
                    let _e306 = cFx;
                    let _e307 = variability;
                    let _e308 = devFx;
                    let _e309 = bias;
                    let _e311 = withBias(_e308, _e309.x);
                    let _e313 = center(_e306, (_e307 * _e311));
                    F_2 = mix(_e304, _e305, vec2(_e313));
                    let _e317 = pos_1;
                    let _e318 = E_2;
                    let _e320 = F_2;
                    let _e322 = segDist(_e317, _e318.xy, _e320.xy);
                    bDist = _e322;
                    let _e324 = bDist;
                    let _e325 = borderBB;
                    if (_e324 < _e325) {
                        {
                            let _e327 = bDist;
                            let _e328 = borderThick;
                            x_5 = (_e327 - _e328);
                            let _e333 = borderThick;
                            let _e334 = pixel;
                            let _e337 = pixel;
                            let _e340 = x_5;
                            let _e342 = pixel;
                            border = clamp(0f, min(1f, (_e333 / _e334)), (((_e337 * 0.5f) - _e340) / _e342));
                            let _e345 = border;
                            if (_e345 >= 1f) {
                                break;
                            }
                        }
                    }
                    let _e348 = quad0_;
                    let _e350 = E_2;
                    EA_1 = (_e348.xy - _e350.xy);
                    let _e354 = F_2;
                    let _e356 = E_2;
                    EF_1 = (_e354.xy - _e356.xy);
                    let _e360 = pos_1;
                    let _e361 = E_2;
                    let _e363 = F_2;
                    let _e365 = quad0_;
                    let _e367 = quad2_;
                    let _e369 = inQuad(_e360, _e361.xy, _e363.xy, _e365.xy, _e367.xy);
                    if _e369 {
                        {
                            let _e370 = E_2;
                            quad1_ = _e370;
                            let _e371 = F_2;
                            quad3_ = _e371;
                            let _e372 = splitsX;
                            splitsX = (_e372 + 1f);
                            let _e375 = sPos;
                            let _e376 = inverter;
                            let _e377 = sscale;
                            sPos = (_e375 + (_e376 * _e377));
                        }
                    } else {
                        {
                            let _e380 = E_2;
                            quad0_ = _e380;
                            let _e381 = F_2;
                            quad2_ = _e381;
                            let _e382 = splitsX;
                            splitsX = (_e382 + 100f);
                            let _e385 = sPos;
                            let _e387 = inverter;
                            let _e389 = sscale;
                            sPos = (_e385 + ((1f - _e387) * _e389));
                        }
                    }
                }
            } else {
                {
                    let _e392 = quad0_;
                    let _e393 = quad2_;
                    let _e394 = cEy;
                    let _e395 = variability;
                    let _e396 = devEy;
                    let _e397 = bias;
                    let _e399 = withBias(_e396, _e397.y);
                    let _e401 = center(_e394, (_e395 * _e399));
                    E_3 = mix(_e392, _e393, vec2(_e401));
                    let _e405 = quad1_;
                    let _e406 = quad3_;
                    let _e407 = cFy;
                    let _e408 = variability;
                    let _e409 = devFy;
                    let _e410 = bias;
                    let _e412 = withBias(_e409, _e410.y);
                    let _e414 = center(_e407, (_e408 * _e412));
                    F_3 = mix(_e405, _e406, vec2(_e414));
                    let _e418 = pos_1;
                    let _e419 = E_3;
                    let _e421 = F_3;
                    let _e423 = segDist(_e418, _e419.xy, _e421.xy);
                    bDist_1 = _e423;
                    let _e425 = bDist_1;
                    let _e426 = borderBB;
                    if (_e425 < _e426) {
                        {
                            let _e428 = bDist_1;
                            let _e429 = borderThick;
                            x_6 = (_e428 - _e429);
                            let _e434 = borderThick;
                            let _e435 = pixel;
                            let _e438 = pixel;
                            let _e441 = x_6;
                            let _e443 = pixel;
                            border = clamp(0f, min(1f, (_e434 / _e435)), (((_e438 * 0.5f) - _e441) / _e443));
                            let _e446 = border;
                            if (_e446 >= 1f) {
                                break;
                            }
                        }
                    }
                    let _e449 = quad0_;
                    let _e451 = E_3;
                    EA_2 = (_e449.xy - _e451.xy);
                    let _e455 = F_3;
                    let _e457 = E_3;
                    EF_2 = (_e455.xy - _e457.xy);
                    let _e461 = pos_1;
                    let _e462 = E_3;
                    let _e464 = F_3;
                    let _e466 = quad0_;
                    let _e468 = quad1_;
                    let _e470 = inQuad(_e461, _e462.xy, _e464.xy, _e466.xy, _e468.xy);
                    if _e470 {
                        {
                            let _e471 = E_3;
                            quad2_ = _e471;
                            let _e472 = F_3;
                            quad3_ = _e472;
                            let _e473 = splitsY;
                            splitsY = (_e473 + 1f);
                            let _e476 = sPos;
                            let _e477 = inverter;
                            let _e478 = sscale;
                            sPos = (_e476 + (_e477 * _e478));
                        }
                    } else {
                        {
                            let _e481 = E_3;
                            quad0_ = _e481;
                            let _e482 = F_3;
                            quad1_ = _e482;
                            let _e483 = splitsY;
                            splitsY = (_e483 + 100f);
                            let _e486 = sPos;
                            let _e488 = inverter;
                            let _e490 = sscale;
                            sPos = (_e486 + ((1f - _e488) * _e490));
                        }
                    }
                }
            }
            let _e493 = mode_1;
            if (_e493 == 2i) {
                {
                    let _e496 = count;
                    abSplit = (fract((_e496 * 0.1f)) < 0.5f);
                }
            } else {
                {
                    let _e502 = abSplit;
                    abSplit = !(_e502);
                }
            }
            let _e505 = inverter;
            inverter = (1f - _e505);
            let _e507 = sscale;
            sscale = (_e507 * 0.5f);
            let _e510 = bias;
            bias = (_e510 * 0.5f);
            let _e513 = count;
            count = (_e513 + 1f);
        }
        continuing {
            let _e130 = i;
            i = (_e130 + 1f);
        }
    }
    let _e516 = quad0_;
    let _e517 = quad1_;
    let _e521 = quad2_;
    let _e522 = quad3_;
    samplePos = mix(mix(_e516, _e517, vec2(0.5f)), mix(_e521, _e522, vec2(0.5f)), vec2(0.5f)).xy;
    let _e531 = samplePos;
    let _e535 = global.U[0];
    let _e538 = samplePos;
    let _e547 = textureSample(t_source, samp, ((vec2<f32>((_e531.x / _e535.x), _e538.y) / vec2(2f)) + vec2(0.5f)));
    col = _e547;
    let _e549 = col;
    let _e550 = col;
    let _e552 = borderColor_1;
    let _e554 = borderColor_1;
    let _e557 = mix(_e550.xyz, _e552.xyz, vec3(_e554.w));
    let _e558 = col;
    let _e564 = border;
    outCol = mix(_e549, vec4<f32>(_e557.x, _e557.y, _e557.z, _e558.w), vec4(_e564));
    let _e568 = outCol;
    return _e568;
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
    let _e66 = global.U[6];
    let _e71 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e86 = global.U[11];
    let _e90 = global.U[4];
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e117 = shards((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74.x, _e78.x, _e82.x, _e86.x, _e90.xy, mat3x3<f32>(vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z), vec3<f32>(_e103.x, _e103.y, _e103.z)));
    fragColor = _e117;
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
