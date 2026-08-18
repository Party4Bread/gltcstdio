struct Params {
    U: array<vec4<f32>, 16>,
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
var t_palette: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn center(c: f32, delta: f32) -> f32 {
    var c_1: f32;
    var delta_1: f32;
    var local: f32;

    c_1 = c;
    delta_1 = delta;
    let _e11 = delta_1;
    if (_e11 < 0f) {
        let _e15 = c_1;
        let _e16 = delta_1;
        local = mix(0f, _e15, ((_e16 * 2f) + 1f));
    } else {
        let _e22 = c_1;
        let _e24 = delta_1;
        local = mix(_e22, 1f, (_e24 * 2f));
    }
    let _e29 = local;
    return _e29;
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
    let _e17 = A_1;
    let _e18 = E_1;
    EA = (_e17 - _e18);
    let _e21 = EA;
    lea = length(_e21);
    let _e24 = lea;
    if (_e24 == 0f) {
        {
            let _e27 = B_1;
            let _e28 = F_1;
            FB = (_e27 - _e28);
            let _e31 = FB;
            lfb = length(_e31);
            let _e34 = lfb;
            if (_e34 == 0f) {
                return false;
            }
            let _e38 = FB;
            let _e39 = lfb;
            FB = (_e38 / vec2(_e39));
            let _e42 = p_1;
            let _e43 = F_1;
            Fp = (_e42 - _e43);
            let _e46 = Fp;
            lfp = length(_e46);
            let _e49 = lfp;
            if (_e49 == 0f) {
                return true;
            }
            let _e53 = Fp;
            let _e54 = lfp;
            Fp = (_e53 / vec2(_e54));
            let _e57 = E_1;
            let _e58 = F_1;
            FE = normalize((_e57 - _e58));
            let _e62 = FE;
            let _e63 = FB;
            let _e65 = Fp;
            let _e66 = FB;
            return (dot(_e62, _e63) < dot(_e65, _e66));
        }
    } else {
        {
            let _e69 = EA;
            let _e70 = lea;
            EA = (_e69 / vec2(_e70));
            let _e73 = p_1;
            let _e74 = E_1;
            Ep = (_e73 - _e74);
            let _e77 = Ep;
            lep = length(_e77);
            let _e80 = lep;
            if (_e80 == 0f) {
                return true;
            }
            let _e84 = Ep;
            let _e85 = lep;
            Ep = (_e84 / vec2(_e85));
            let _e88 = F_1;
            let _e89 = E_1;
            EF = normalize((_e88 - _e89));
            let _e93 = EF;
            let _e94 = EA;
            let _e96 = Ep;
            let _e97 = EA;
            return (dot(_e93, _e94) < dot(_e96, _e97));
        }
    }
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

fn round2_(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e11 = x_2;
    let _e12 = prec_1;
    let _e17 = prec_1;
    return (floor(((_e11 / _e12) + 0.5f)) * _e17);
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
    let _e13 = b_1;
    let _e14 = a_1;
    ab = (_e13 - _e14);
    let _e17 = ab;
    abLen = length(_e17);
    let _e20 = abLen;
    if (_e20 == 0f) {
        let _e23 = p_3;
        let _e24 = a_1;
        return length((_e23 - _e24));
    }
    let _e27 = ab;
    let _e28 = abLen;
    abNorm = (_e27 / vec2(_e28));
    let _e32 = p_3;
    let _e33 = a_1;
    ap = (_e32 - _e33);
    let _e36 = ap;
    let _e37 = abNorm;
    abProj = dot(_e36, _e37);
    let _e40 = abProj;
    let _e43 = abProj;
    let _e44 = abLen;
    if ((_e40 >= 0f) && (_e43 <= _e44)) {
        {
            let _e47 = ap;
            let _e48 = abNorm;
            let _e50 = abNorm;
            return abs(dot(_e47, vec2<f32>(_e48.y, -(_e50.x))));
        }
    } else {
        {
            let _e56 = ap;
            let _e58 = p_3;
            let _e59 = b_1;
            return min(length(_e56), length((_e58 - _e59)));
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
    let _e11 = b_3;
    s = sign(_e11);
    let _e14 = b_3;
    ab_1 = abs(_e14);
    let _e17 = x_4;
    let _e21 = s;
    let _e23 = ab_1;
    return (pow((_e17 + 0.5f), pow(2f, (-(_e21) * _e23))) - 0.5f);
}

fn shards(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, borderColor: vec4<f32>, thickness: f32, regularity: f32, randomSeed: f32, balance: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>, paletteDim: vec2<f32>) -> vec4<f32> {
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
    var paletteDim_1: vec2<f32>;
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
    var n: i32;
    var doQuantize: bool;
    var minDist: f32 = 1000000000f;
    var bestColor: vec4<f32>;
    var i_1: i32 = 0i;
    var target_: vec4<f32>;
    var dist: f32;

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
    paletteDim_1 = paletteDim;
    let _e29 = sourceDim_1;
    let _e31 = sourceDim_1;
    let _e35 = round2_((_e29.x / _e31.y), 0.01f);
    ratio = _e35;
    let _e38 = sourceDim_1;
    pixel = (2f / _e38.y);
    let _e42 = ratio;
    quad0_ = vec2<f32>(-(_e42), -1f);
    let _e48 = ratio;
    quad1_ = vec2<f32>(_e48, -1f);
    let _e53 = ratio;
    quad2_ = vec2<f32>(-(_e53), 1f);
    let _e58 = ratio;
    quad3_ = vec2<f32>(_e58, 1f);
    let _e70 = modelTransform_1;
    bias = (_e70 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e81 = modelTransform_1[0];
    scale = (1f / length(_e81.xy));
    let _e94 = thickness_1;
    borderThick = (_e94 * 0.05f);
    let _e98 = pixel;
    let _e99 = borderThick;
    borderTransition = (min(_e98, (_e99 * 0.3f)) * 0.5f);
    let _e106 = borderThick;
    let _e107 = pixel;
    let _e110 = pixel;
    let _e111 = borderThick;
    let _e115 = pixel;
    borderAA = (_e106 - ((smoothstep((_e107 * 0.5f), _e110, _e111) * 0.5f) * _e115));
    let _e119 = borderThick;
    let _e120 = pixel;
    borderBB = (_e119 + (_e120 * 0.5f));
    loop {
        let _e127 = i;
        let _e128 = sPos;
        let _e130 = scale;
        if !(((_e127 + _e128) < _e130)) {
            break;
        }
        {
            let _e140 = splitsX;
            let _e141 = splitsY;
            let _e144 = randomSeed_1;
            let _e147 = rand2relSeeded((vec2<f32>(-4f, 3f) + vec2<f32>(_e140, _e141)), (_e144 + 122.1f));
            rnd = _e147;
            let _e149 = quad0_;
            let _e150 = quad3_;
            let _e153 = quad1_;
            let _e154 = quad2_;
            size = max(abs((_e149 - _e150)), abs((_e153 - _e154))).xy;
            let _e160 = size;
            let _e162 = pixel;
            let _e164 = size;
            let _e166 = pixel;
            if ((_e160.x < _e162) || (_e164.y < _e166)) {
                break;
            }
            let _e169 = quad0_;
            let _e171 = quad1_;
            let _e175 = quad2_;
            let _e177 = quad3_;
            lenAB = (length((_e169.xy - _e171.xy)) + length((_e175.xy - _e177.xy)));
            let _e183 = quad0_;
            let _e185 = quad2_;
            let _e189 = quad1_;
            let _e191 = quad3_;
            lenAC = (length((_e183.xy - _e185.xy)) + length((_e189.xy - _e191.xy)));
            let _e197 = rnd;
            let _e201 = regularity_1;
            if ((_e197.x + 0.5f) < (_e201 * 2f)) {
                let _e205 = lenAB;
                let _e206 = lenAC;
                abSplit = (_e205 > _e206);
            }
            let _e210 = regularity_1;
            variability = (1f - max(0f, ((_e210 * 2f) - 1f)));
            let _e218 = balance_1;
            deviate = _e218;
            let _e220 = rnd;
            let _e222 = deviate;
            devEx = clamp((_e220.x + _e222), -1f, 1f);
            let _e229 = rnd;
            let _e231 = deviate;
            devFx = clamp((_e229.y + _e231), -1f, 1f);
            let _e238 = devEx;
            devEy = _e238;
            let _e240 = devFx;
            devFy = _e240;
            cEx = 0.5f;
            cEy = 0.5f;
            cFx = 0.5f;
            cFy = 0.5f;
            let _e250 = mode_1;
            if (_e250 == 1i) {
                {
                    let _e253 = devEx;
                    devEx = -(_e253);
                    let _e255 = devFy;
                    devFy = -(_e255);
                }
            } else {
                let _e257 = mode_1;
                if (_e257 == 3i) {
                    {
                        let _e260 = devEy;
                        devEy = -(_e260);
                    }
                } else {
                    let _e262 = mode_1;
                    if (_e262 == 4i) {
                        {
                            cEx = 0.1f;
                        }
                    } else {
                        let _e266 = mode_1;
                        if (_e266 == 5i) {
                            {
                                cEx = 0.7f;
                                cEy = 0.7f;
                            }
                        } else {
                            let _e271 = mode_1;
                            if (_e271 == 6i) {
                                {
                                    cEx = 0.2f;
                                    let _e276 = cEx;
                                    cFx = (1f - _e276);
                                    cEy = 0.8f;
                                    let _e280 = cEy;
                                    cFy = (1f - _e280);
                                }
                            } else {
                                let _e282 = mode_1;
                                if (_e282 == 7i) {
                                    {
                                        cEx = 0.2f;
                                        let _e287 = cEx;
                                        cFx = (1f - _e287);
                                        cEy = 0.2f;
                                        let _e291 = cEy;
                                        cFy = (1f - _e291);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let _e293 = abSplit;
            if _e293 {
                {
                    let _e294 = quad0_;
                    let _e295 = quad1_;
                    let _e296 = cEx;
                    let _e297 = variability;
                    let _e298 = devEx;
                    let _e299 = bias;
                    let _e301 = withBias(_e298, _e299.x);
                    let _e303 = center(_e296, (_e297 * _e301));
                    E_2 = mix(_e294, _e295, vec2(_e303));
                    let _e307 = quad2_;
                    let _e308 = quad3_;
                    let _e309 = cFx;
                    let _e310 = variability;
                    let _e311 = devFx;
                    let _e312 = bias;
                    let _e314 = withBias(_e311, _e312.x);
                    let _e316 = center(_e309, (_e310 * _e314));
                    F_2 = mix(_e307, _e308, vec2(_e316));
                    let _e320 = pos_1;
                    let _e321 = E_2;
                    let _e323 = F_2;
                    let _e325 = segDist(_e320, _e321.xy, _e323.xy);
                    bDist = _e325;
                    let _e327 = bDist;
                    let _e328 = borderBB;
                    if (_e327 < _e328) {
                        {
                            let _e330 = bDist;
                            let _e331 = borderThick;
                            x_5 = (_e330 - _e331);
                            let _e336 = borderThick;
                            let _e337 = pixel;
                            let _e340 = pixel;
                            let _e343 = x_5;
                            let _e345 = pixel;
                            border = clamp(0f, min(1f, (_e336 / _e337)), (((_e340 * 0.5f) - _e343) / _e345));
                            let _e348 = border;
                            if (_e348 >= 1f) {
                                break;
                            }
                        }
                    }
                    let _e351 = quad0_;
                    let _e353 = E_2;
                    EA_1 = (_e351.xy - _e353.xy);
                    let _e357 = F_2;
                    let _e359 = E_2;
                    EF_1 = (_e357.xy - _e359.xy);
                    let _e363 = pos_1;
                    let _e364 = E_2;
                    let _e366 = F_2;
                    let _e368 = quad0_;
                    let _e370 = quad2_;
                    let _e372 = inQuad(_e363, _e364.xy, _e366.xy, _e368.xy, _e370.xy);
                    if _e372 {
                        {
                            let _e373 = E_2;
                            quad1_ = _e373;
                            let _e374 = F_2;
                            quad3_ = _e374;
                            let _e375 = splitsX;
                            splitsX = (_e375 + 1f);
                            let _e378 = sPos;
                            let _e379 = inverter;
                            let _e380 = sscale;
                            sPos = (_e378 + (_e379 * _e380));
                        }
                    } else {
                        {
                            let _e383 = E_2;
                            quad0_ = _e383;
                            let _e384 = F_2;
                            quad2_ = _e384;
                            let _e385 = splitsX;
                            splitsX = (_e385 + 100f);
                            let _e388 = sPos;
                            let _e390 = inverter;
                            let _e392 = sscale;
                            sPos = (_e388 + ((1f - _e390) * _e392));
                        }
                    }
                }
            } else {
                {
                    let _e395 = quad0_;
                    let _e396 = quad2_;
                    let _e397 = cEy;
                    let _e398 = variability;
                    let _e399 = devEy;
                    let _e400 = bias;
                    let _e402 = withBias(_e399, _e400.y);
                    let _e404 = center(_e397, (_e398 * _e402));
                    E_3 = mix(_e395, _e396, vec2(_e404));
                    let _e408 = quad1_;
                    let _e409 = quad3_;
                    let _e410 = cFy;
                    let _e411 = variability;
                    let _e412 = devFy;
                    let _e413 = bias;
                    let _e415 = withBias(_e412, _e413.y);
                    let _e417 = center(_e410, (_e411 * _e415));
                    F_3 = mix(_e408, _e409, vec2(_e417));
                    let _e421 = pos_1;
                    let _e422 = E_3;
                    let _e424 = F_3;
                    let _e426 = segDist(_e421, _e422.xy, _e424.xy);
                    bDist_1 = _e426;
                    let _e428 = bDist_1;
                    let _e429 = borderBB;
                    if (_e428 < _e429) {
                        {
                            let _e431 = bDist_1;
                            let _e432 = borderThick;
                            x_6 = (_e431 - _e432);
                            let _e437 = borderThick;
                            let _e438 = pixel;
                            let _e441 = pixel;
                            let _e444 = x_6;
                            let _e446 = pixel;
                            border = clamp(0f, min(1f, (_e437 / _e438)), (((_e441 * 0.5f) - _e444) / _e446));
                            let _e449 = border;
                            if (_e449 >= 1f) {
                                break;
                            }
                        }
                    }
                    let _e452 = quad0_;
                    let _e454 = E_3;
                    EA_2 = (_e452.xy - _e454.xy);
                    let _e458 = F_3;
                    let _e460 = E_3;
                    EF_2 = (_e458.xy - _e460.xy);
                    let _e464 = pos_1;
                    let _e465 = E_3;
                    let _e467 = F_3;
                    let _e469 = quad0_;
                    let _e471 = quad1_;
                    let _e473 = inQuad(_e464, _e465.xy, _e467.xy, _e469.xy, _e471.xy);
                    if _e473 {
                        {
                            let _e474 = E_3;
                            quad2_ = _e474;
                            let _e475 = F_3;
                            quad3_ = _e475;
                            let _e476 = splitsY;
                            splitsY = (_e476 + 1f);
                            let _e479 = sPos;
                            let _e480 = inverter;
                            let _e481 = sscale;
                            sPos = (_e479 + (_e480 * _e481));
                        }
                    } else {
                        {
                            let _e484 = E_3;
                            quad0_ = _e484;
                            let _e485 = F_3;
                            quad1_ = _e485;
                            let _e486 = splitsY;
                            splitsY = (_e486 + 100f);
                            let _e489 = sPos;
                            let _e491 = inverter;
                            let _e493 = sscale;
                            sPos = (_e489 + ((1f - _e491) * _e493));
                        }
                    }
                }
            }
            let _e496 = mode_1;
            if (_e496 == 2i) {
                {
                    let _e499 = count;
                    abSplit = (fract((_e499 * 0.1f)) < 0.5f);
                }
            } else {
                {
                    let _e505 = abSplit;
                    abSplit = !(_e505);
                }
            }
            let _e508 = inverter;
            inverter = (1f - _e508);
            let _e510 = sscale;
            sscale = (_e510 * 0.5f);
            let _e513 = bias;
            bias = (_e513 * 0.5f);
            let _e516 = count;
            count = (_e516 + 1f);
        }
        continuing {
            let _e133 = i;
            i = (_e133 + 1f);
        }
    }
    let _e519 = quad0_;
    let _e520 = quad1_;
    let _e524 = quad2_;
    let _e525 = quad3_;
    samplePos = mix(mix(_e519, _e520, vec2(0.5f)), mix(_e524, _e525, vec2(0.5f)), vec2(0.5f)).xy;
    let _e534 = samplePos;
    let _e538 = global.U[0];
    let _e541 = samplePos;
    let _e550 = textureSample(t_source, samp, ((vec2<f32>((_e534.x / _e538.x), _e541.y) / vec2(2f)) + vec2(0.5f)));
    col = _e550;
    let _e552 = col;
    let _e553 = col;
    let _e555 = borderColor_1;
    let _e557 = borderColor_1;
    let _e560 = mix(_e553.xyz, _e555.xyz, vec3(_e557.w));
    let _e561 = col;
    let _e567 = border;
    outCol = mix(_e552, vec4<f32>(_e560.x, _e560.y, _e560.z, _e561.w), vec4(_e567));
    let _e571 = paletteDim_1;
    n = i32(_e571.x);
    let _e575 = n;
    doQuantize = (_e575 > 1i);
    let _e579 = n;
    if (_e579 == 1i) {
        let _e586 = textureLoad(t_palette, vec2<i32>(0i, 0i), 0i);
        doQuantize = (_e586.w > 0.5f);
    }
    let _e590 = doQuantize;
    if _e590 {
        {
            let _e593 = outCol;
            bestColor = _e593;
            loop {
                let _e597 = i_1;
                let _e598 = n;
                if !((_e597 < _e598)) {
                    break;
                }
                {
                    let _e604 = i_1;
                    let _e608 = textureLoad(t_palette, vec2<i32>(_e604, 0i), 0i);
                    target_ = _e608;
                    let _e610 = outCol;
                    let _e611 = target_;
                    dist = length((_e610 - _e611));
                    let _e615 = dist;
                    let _e616 = minDist;
                    if (_e615 < _e616) {
                        {
                            let _e618 = dist;
                            minDist = _e618;
                            let _e619 = target_;
                            bestColor = _e619;
                        }
                    }
                }
                continuing {
                    let _e601 = i_1;
                    i_1 = (_e601 + 1i);
                }
            }
            let _e620 = bestColor;
            outCol = _e620;
        }
    }
    let _e621 = outCol;
    return _e621;
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
    let _e67 = global.U[7];
    let _e72 = global.U[8];
    let _e75 = global.U[9];
    let _e79 = global.U[10];
    let _e83 = global.U[11];
    let _e87 = global.U[12];
    let _e91 = global.U[4];
    let _e95 = global.U[13];
    let _e96 = _e95.xyz;
    let _e99 = global.U[14];
    let _e100 = _e99.xyz;
    let _e103 = global.U[15];
    let _e104 = _e103.xyz;
    let _e120 = global.U[5];
    let _e122 = shards((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72, _e75.x, _e79.x, _e83.x, _e87.x, _e91.xy, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), _e120.xy);
    fragColor = _e122;
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
