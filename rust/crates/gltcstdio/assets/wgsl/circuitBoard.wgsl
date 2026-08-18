struct Params {
    U: array<vec4<f32>, 19>,
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

fn cb_withBias(x: f32, b: f32) -> f32 {
    var x_1: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_1 = x;
    b_1 = b;
    let _e9 = b_1;
    s = sign(_e9);
    let _e12 = b_1;
    ab = abs(_e12);
    let _e15 = x_1;
    let _e19 = s;
    let _e21 = ab;
    return (pow((_e15 + 0.5f), pow(2f, (-(_e19) * _e21))) - 0.5f);
}

fn hash11_(x_2: f32) -> f32 {
    var x_3: f32;

    x_3 = x_2;
    let _e7 = x_3;
    return fract((sin(((_e7 * 45.34f) + 123.131f)) * 94.434f));
}

fn hash21_(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var a: vec2<f32>;
    var b_2: vec2<f32>;

    p_1 = p;
    let _e9 = p_1;
    a = fract((-45.3277f * _e9.xy));
    let _e14 = a;
    let _e15 = a;
    let _e16 = a;
    b_2 = (_e14 + vec2(dot(_e15, (_e16 + vec2(123.3371f)))));
    let _e24 = b_2;
    let _e26 = b_2;
    return fract((_e24.x * _e26.y));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_4: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x_4 = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x_4;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x_4;
    let _e32 = y;
    return vec2<f32>(_e31, _e32);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
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

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e9 = noise_3;
    let _e11 = k_3;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_3;
    let _e16 = varyNoiseSmoothly(_e13.y, _e15);
    return vec2<f32>(_e12, _e16);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rand2_(_e9);
    let _e11 = seed_1;
    let _e12 = varyVec2NoiseSmoothly(_e10, _e11);
    return (_e12 - vec2(0.5f));
}

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e9 = u_1;
    let _e11 = halfSize_1;
    u_1 = (abs(_e9) - _e11);
    let _e13 = u_1;
    let _e17 = u_1;
    if ((_e13.x >= 0f) && (_e17.y >= 0f)) {
        let _e22 = u_1;
        local = length(_e22);
    } else {
        let _e24 = u_1;
        let _e26 = u_1;
        local = max(_e24.x, _e26.y);
    }
    let _e30 = local;
    return _e30;
}

fn sdSegment(u_2: vec2<f32>, a_1: vec2<f32>, b_3: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_2: vec2<f32>;
    var b_4: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_2 = a_1;
    b_4 = b_3;
    let _e11 = u_3;
    let _e12 = a_2;
    ua = (_e11 - _e12);
    let _e15 = b_4;
    let _e16 = a_2;
    ba = (_e15 - _e16);
    let _e19 = ua;
    let _e20 = ba;
    let _e22 = ba;
    let _e23 = ba;
    h = clamp((dot(_e19, _e20) / dot(_e22, _e23)), 0f, 1f);
    let _e30 = ua;
    let _e31 = ba;
    let _e32 = h;
    return length((_e30 - (_e31 * _e32)));
}

fn circuitBoard(uv: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, count: i32, coverage: f32, population: f32, integration: f32, variability: f32, randomSeed: f32, colorBkg: vec4<f32>, color: vec4<f32>, color1_: vec4<f32>, thickness: f32, roundness: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var count_1: i32;
    var coverage_1: f32;
    var population_1: f32;
    var integration_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var colorBkg_1: vec4<f32>;
    var color_1: vec4<f32>;
    var color1_1: vec4<f32>;
    var thickness_1: f32;
    var roundness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var cnt: f32;
    var ar: f32;
    var g: f32;
    var gp: vec2<f32>;
    var aaG: f32;
    var halfW: f32;
    var halfH: f32;
    var rect: vec4<f32>;
    var biasBase: vec2<f32>;
    var mtScale: f32;
    var splits: vec2<f32> = vec2(0f);
    var horSplit: bool = true;
    var bias: vec2<f32>;
    var sPos: f32 = 0f;
    var sscale: f32 = 0.5f;
    var inverter: f32 = 0f;
    var regularity: f32;
    var i: f32 = 0f;
    var w: f32;
    var h_1: f32;
    var canV: bool;
    var canH: bool;
    var rnd: vec2<f32>;
    var area: f32;
    var aspect: f32;
    var sizePref: f32;
    var pStop: f32;
    var guard: bool;
    var sh: f32;
    var posVar: f32;
    var lo: f32;
    var hi: f32;
    var Yf: f32;
    var Y: f32;
    var lo_1: f32;
    var hi_1: f32;
    var Xf: f32;
    var X: f32;
    var ix0_: f32;
    var iy0_: f32;
    var ix1_: f32;
    var iy1_: f32;
    var w_1: f32;
    var h_2: f32;
    var cx: f32;
    var cy: f32;
    var cellHash: f32;
    var pinSeed: f32;
    var dTrace: f32 = 1000000000f;
    var dBody: f32 = 1000000000f;
    var dPin1_: f32 = 1000000000f;
    var dPadO: f32 = 1000000000f;
    var dPadI: f32 = 1000000000f;
    var dComp: f32 = 1000000000f;
    var dCompMk: f32 = 1000000000f;
    var dGap: f32 = 1000000000f;
    var dCapPlate: f32 = 1000000000f;
    var compColor: vec4<f32> = vec4(0f);
    var markColor: vec4<f32> = vec4(0f);
    var traceHalf: f32;
    var minWH: f32;
    var maxWH: f32;
    var populated: bool;
    var mxE: f32;
    var myE: f32;
    var lead: f32 = 0.32f;
    var e: vec2<f32>;
    var e_1: vec2<f32>;
    var e_2: vec2<f32>;
    var e_3: vec2<f32>;
    var local_1: f32;
    var inset: f32;
    var bc: vec2<f32>;
    var bhalf: vec2<f32>;
    var rr: f32;
    var dB: f32;
    var aspectB: f32;
    var pkgHash: f32;
    var pc: vec2<f32>;
    var local_2: vec2<f32>;
    var ap: vec2<f32>;
    var along: f32;
    var b_5: i32 = 0i;
    var cspan: f32;
    var ch: i32;
    var csp: f32;
    var cr: f32;
    var dcoil: f32 = 1000000000f;
    var c: i32 = 0i;
    var o: f32;
    var notchC: vec2<f32>;
    var mx: f32;
    var my: f32;
    var vertical: bool;
    var activeCount: f32 = 0f;
    var hx0_: f32;
    var hx1_: f32;
    var vy0_: f32;
    var vy1_: f32;
    var wc: i32;
    var s_1: i32 = 0i;
    var mx_1: f32;
    var hc: i32;
    var s_2: i32 = 0i;
    var my_1: f32;
    var mx_2: f32;
    var my_2: f32;
    var endA: bool;
    var endB: bool;
    var pc2_: vec2<f32>;
    var local_3: vec2<f32>;
    var ap_1: vec2<f32>;
    var pillHalf: f32;
    var b_6: i32 = 0i;
    var span: f32;
    var humps: i32;
    var sp: f32;
    var r: f32;
    var dc: f32 = 1000000000f;
    var c_1: i32 = 0i;
    var off: f32;
    var col: vec4<f32>;
    var tCov: f32;
    var gapCov: f32;
    var capCov: f32;
    var padO: f32;
    var padI: f32;
    var bodyCov: f32;
    var rimHalf: f32;
    var rimCov: f32;
    var compCov: f32;
    var mkCov: f32;
    var p1Cov: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    outDim_1 = outDim;
    count_1 = count;
    coverage_1 = coverage;
    population_1 = population;
    integration_1 = integration;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    colorBkg_1 = colorBkg;
    color_1 = color;
    color1_1 = color1_;
    thickness_1 = thickness;
    roundness_1 = roundness;
    modelTransform_1 = modelTransform;
    let _e36 = count_1;
    cnt = max(2f, f32(_e36));
    let _e40 = outDim_1;
    let _e42 = outDim_1;
    ar = (_e40.x / _e42.y);
    let _e47 = cnt;
    g = (2f / _e47);
    let _e50 = uv_1;
    let _e51 = g;
    gp = (_e50 / vec2(_e51));
    let _e55 = cnt;
    let _e56 = outDim_1;
    aaG = ((_e55 / _e56.y) * 0.75f);
    let _e62 = ar;
    let _e63 = cnt;
    halfW = ((_e62 * _e63) * 0.5f);
    let _e68 = cnt;
    halfH = (_e68 * 0.5f);
    let _e72 = halfW;
    let _e75 = halfH;
    let _e78 = halfW;
    let _e80 = halfH;
    rect = vec4<f32>(floor(-(_e72)), floor(-(_e75)), ceil(_e78), ceil(_e80));
    let _e84 = modelTransform_1;
    biasBase = (_e84 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e98 = modelTransform_1[0][0];
    let _e103 = modelTransform_1[0][1];
    mtScale = (1f / max(0.0001f, length(vec2<f32>(_e98, _e103))));
    let _e114 = biasBase;
    bias = _e114;
    let _e123 = variability_1;
    regularity = (1f - _e123);
    loop {
        let _e128 = i;
        let _e129 = sPos;
        let _e131 = mtScale;
        if !(((_e128 + _e129) < _e131)) {
            break;
        }
        {
            let _e137 = rect;
            let _e139 = rect;
            w = (_e137.z - _e139.x);
            let _e143 = rect;
            let _e145 = rect;
            h_1 = (_e143.w - _e145.y);
            let _e149 = w;
            canV = (_e149 >= 2f);
            let _e153 = h_1;
            canH = (_e153 >= 2f);
            let _e157 = canV;
            let _e159 = canH;
            if (!(_e157) && !(_e159)) {
                break;
            }
            let _e162 = splits;
            let _e163 = randomSeed_1;
            let _e166 = rand2relSeeded(_e162, (_e163 + 122.1f));
            rnd = _e166;
            let _e168 = w;
            let _e169 = h_1;
            area = (_e168 * _e169);
            let _e172 = w;
            let _e173 = h_1;
            let _e176 = w;
            let _e177 = h_1;
            aspect = (max(_e172, _e173) / max(1f, min(_e176, _e177)));
            let _e184 = area;
            let _e189 = area;
            sizePref = (smoothstep(3f, 8f, _e184) * (1f - smoothstep(70f, 150f, _e189)));
            let _e194 = integration_1;
            let _e195 = sizePref;
            pStop = (_e194 * _e195);
            let _e198 = aspect;
            let _e201 = w;
            let _e202 = h_1;
            guard = ((_e198 > 7f) || (max(_e201, _e202) > 13f));
            let _e208 = splits;
            let _e211 = randomSeed_1;
            let _e219 = hash21_((((_e208 * 0.317f) + vec2((_e211 * 0.019f))) + vec2(7.7f)));
            sh = _e219;
            let _e221 = guard;
            let _e223 = area;
            let _e227 = sh;
            let _e228 = pStop;
            if ((!(_e221) && (_e223 >= 4f)) && (_e227 < _e228)) {
                break;
            }
            let _e231 = guard;
            let _e233 = w;
            let _e234 = h_1;
            let _e239 = w;
            let _e240 = h_1;
            let _e245 = w;
            let _e246 = h_1;
            let _e251 = splits;
            let _e254 = randomSeed_1;
            let _e262 = hash21_((((_e251 * 0.51f) + vec2((_e254 * 0.041f))) + vec2(2.2f)));
            if ((((!(_e231) && (min(_e233, _e234) == 1f)) && (max(_e239, _e240) >= 3f)) && (max(_e245, _e246) <= 7f)) && (_e262 < 0.5f)) {
                break;
            }
            let _e266 = rnd;
            let _e270 = regularity;
            if ((_e266.x + 0.5f) < (_e270 * 2f)) {
                let _e274 = h_1;
                let _e275 = w;
                horSplit = (_e274 > _e275);
            }
            let _e277 = horSplit;
            let _e278 = canH;
            if (_e277 && !(_e278)) {
                horSplit = false;
            }
            let _e282 = horSplit;
            let _e284 = canV;
            if (!(_e282) && !(_e284)) {
                horSplit = true;
            }
            let _e290 = regularity;
            posVar = (1f - max(0f, ((_e290 * 2f) - 1f)));
            let _e298 = horSplit;
            if _e298 {
                {
                    let _e299 = rect;
                    lo = (_e299.y + 1f);
                    let _e304 = rect;
                    hi = (_e304.w - 1f);
                    let _e309 = rect;
                    let _e311 = rect;
                    let _e313 = posVar;
                    let _e314 = rnd;
                    let _e316 = bias;
                    let _e318 = cb_withBias(_e314.y, _e316.y);
                    Yf = mix(_e309.y, _e311.w, ((_e313 * _e318) + 0.5f));
                    let _e324 = Yf;
                    let _e328 = lo;
                    let _e329 = hi;
                    Y = clamp(floor((_e324 + 0.5f)), _e328, _e329);
                    let _e332 = gp;
                    let _e334 = Y;
                    if (_e332.y < _e334) {
                        {
                            let _e337 = Y;
                            rect.w = _e337;
                            let _e339 = splits;
                            splits.y = (_e339.y + 1f);
                            let _e343 = sPos;
                            let _e344 = inverter;
                            let _e345 = sscale;
                            sPos = (_e343 + (_e344 * _e345));
                        }
                    } else {
                        {
                            let _e349 = Y;
                            rect.y = _e349;
                            let _e351 = splits;
                            splits.y = (_e351.y + 100f);
                            let _e355 = sPos;
                            let _e357 = inverter;
                            let _e359 = sscale;
                            sPos = (_e355 + ((1f - _e357) * _e359));
                        }
                    }
                }
            } else {
                {
                    let _e362 = rect;
                    lo_1 = (_e362.x + 1f);
                    let _e367 = rect;
                    hi_1 = (_e367.z - 1f);
                    let _e372 = rect;
                    let _e374 = rect;
                    let _e376 = posVar;
                    let _e377 = rnd;
                    let _e379 = bias;
                    let _e381 = cb_withBias(_e377.x, _e379.x);
                    Xf = mix(_e372.x, _e374.z, ((_e376 * _e381) + 0.5f));
                    let _e387 = Xf;
                    let _e391 = lo_1;
                    let _e392 = hi_1;
                    X = clamp(floor((_e387 + 0.5f)), _e391, _e392);
                    let _e395 = gp;
                    let _e397 = X;
                    if (_e395.x < _e397) {
                        {
                            let _e400 = X;
                            rect.z = _e400;
                            let _e402 = splits;
                            splits.x = (_e402.x + 1f);
                            let _e406 = sPos;
                            let _e407 = inverter;
                            let _e408 = sscale;
                            sPos = (_e406 + (_e407 * _e408));
                        }
                    } else {
                        {
                            let _e412 = X;
                            rect.x = _e412;
                            let _e414 = splits;
                            splits.x = (_e414.x + 100f);
                            let _e418 = sPos;
                            let _e420 = inverter;
                            let _e422 = sscale;
                            sPos = (_e418 + ((1f - _e420) * _e422));
                        }
                    }
                }
            }
            let _e425 = horSplit;
            horSplit = !(_e425);
            let _e428 = inverter;
            inverter = (1f - _e428);
            let _e430 = sscale;
            sscale = (_e430 * 0.5f);
            let _e433 = bias;
            bias = (_e433 * 0.5f);
        }
        continuing {
            let _e134 = i;
            i = (_e134 + 1f);
        }
    }
    let _e436 = rect;
    ix0_ = _e436.x;
    let _e439 = rect;
    iy0_ = _e439.y;
    let _e442 = rect;
    ix1_ = _e442.z;
    let _e445 = rect;
    iy1_ = _e445.w;
    let _e448 = ix1_;
    let _e449 = ix0_;
    w_1 = (_e448 - _e449);
    let _e452 = iy1_;
    let _e453 = iy0_;
    h_2 = (_e452 - _e453);
    let _e457 = ix0_;
    let _e458 = ix1_;
    cx = (0.5f * (_e457 + _e458));
    let _e463 = iy0_;
    let _e464 = iy1_;
    cy = (0.5f * (_e463 + _e464));
    let _e468 = splits;
    let _e471 = randomSeed_1;
    let _e479 = hash21_((((_e468 * 0.713f) + vec2((_e471 * 0.037f))) + vec2(1.3f)));
    cellHash = _e479;
    let _e481 = randomSeed_1;
    pinSeed = (_e481 + 313.7f);
    let _e509 = thickness_1;
    traceHalf = (_e509 * 0.22f);
    let _e513 = w_1;
    let _e514 = h_2;
    minWH = min(_e513, _e514);
    let _e517 = w_1;
    let _e518 = h_2;
    maxWH = max(_e517, _e518);
    let _e521 = splits;
    let _e524 = randomSeed_1;
    let _e532 = hash21_((((_e521 * 0.911f) + vec2((_e524 * 0.053f))) + vec2(4.4f)));
    let _e533 = population_1;
    populated = (_e532 < _e533);
    let _e536 = gp;
    let _e541 = ix0_;
    let _e544 = ix1_;
    mxE = clamp((floor(_e536.x) + 0.5f), (_e541 + 0.5f), (_e544 - 0.5f));
    let _e549 = gp;
    let _e554 = iy0_;
    let _e557 = iy1_;
    myE = clamp((floor(_e549.y) + 0.5f), (_e554 + 0.5f), (_e557 - 0.5f));
    let _e562 = populated;
    if !(_e562) {
        {
            let _e566 = mxE;
            let _e567 = iy0_;
            let _e569 = pinSeed;
            let _e570 = rand2relSeeded(vec2<f32>(_e566, _e567), _e569);
            let _e574 = coverage_1;
            if ((_e570.x + 0.5f) < _e574) {
                {
                    let _e576 = mxE;
                    let _e577 = iy0_;
                    let _e578 = lead;
                    e = vec2<f32>(_e576, (_e577 + _e578));
                    let _e582 = dTrace;
                    let _e583 = gp;
                    let _e584 = mxE;
                    let _e585 = iy0_;
                    let _e587 = e;
                    let _e588 = sdSegment(_e583, vec2<f32>(_e584, _e585), _e587);
                    dTrace = min(_e582, _e588);
                    let _e590 = dPadO;
                    let _e591 = gp;
                    let _e592 = e;
                    dPadO = min(_e590, (length((_e591 - _e592)) - 0.2f));
                    let _e598 = dPadI;
                    let _e599 = gp;
                    let _e600 = e;
                    dPadI = min(_e598, (length((_e599 - _e600)) - 0.09f));
                }
            }
            let _e606 = mxE;
            let _e607 = iy1_;
            let _e609 = pinSeed;
            let _e610 = rand2relSeeded(vec2<f32>(_e606, _e607), _e609);
            let _e614 = coverage_1;
            if ((_e610.x + 0.5f) < _e614) {
                {
                    let _e616 = mxE;
                    let _e617 = iy1_;
                    let _e618 = lead;
                    e_1 = vec2<f32>(_e616, (_e617 - _e618));
                    let _e622 = dTrace;
                    let _e623 = gp;
                    let _e624 = mxE;
                    let _e625 = iy1_;
                    let _e627 = e_1;
                    let _e628 = sdSegment(_e623, vec2<f32>(_e624, _e625), _e627);
                    dTrace = min(_e622, _e628);
                    let _e630 = dPadO;
                    let _e631 = gp;
                    let _e632 = e_1;
                    dPadO = min(_e630, (length((_e631 - _e632)) - 0.2f));
                    let _e638 = dPadI;
                    let _e639 = gp;
                    let _e640 = e_1;
                    dPadI = min(_e638, (length((_e639 - _e640)) - 0.09f));
                }
            }
            let _e646 = ix0_;
            let _e647 = myE;
            let _e649 = pinSeed;
            let _e650 = rand2relSeeded(vec2<f32>(_e646, _e647), _e649);
            let _e654 = coverage_1;
            if ((_e650.x + 0.5f) < _e654) {
                {
                    let _e656 = ix0_;
                    let _e657 = lead;
                    let _e659 = myE;
                    e_2 = vec2<f32>((_e656 + _e657), _e659);
                    let _e662 = dTrace;
                    let _e663 = gp;
                    let _e664 = ix0_;
                    let _e665 = myE;
                    let _e667 = e_2;
                    let _e668 = sdSegment(_e663, vec2<f32>(_e664, _e665), _e667);
                    dTrace = min(_e662, _e668);
                    let _e670 = dPadO;
                    let _e671 = gp;
                    let _e672 = e_2;
                    dPadO = min(_e670, (length((_e671 - _e672)) - 0.2f));
                    let _e678 = dPadI;
                    let _e679 = gp;
                    let _e680 = e_2;
                    dPadI = min(_e678, (length((_e679 - _e680)) - 0.09f));
                }
            }
            let _e686 = ix1_;
            let _e687 = myE;
            let _e689 = pinSeed;
            let _e690 = rand2relSeeded(vec2<f32>(_e686, _e687), _e689);
            let _e694 = coverage_1;
            if ((_e690.x + 0.5f) < _e694) {
                {
                    let _e696 = ix1_;
                    let _e697 = lead;
                    let _e699 = myE;
                    e_3 = vec2<f32>((_e696 - _e697), _e699);
                    let _e702 = dTrace;
                    let _e703 = gp;
                    let _e704 = ix1_;
                    let _e705 = myE;
                    let _e707 = e_3;
                    let _e708 = sdSegment(_e703, vec2<f32>(_e704, _e705), _e707);
                    dTrace = min(_e702, _e708);
                    let _e710 = dPadO;
                    let _e711 = gp;
                    let _e712 = e_3;
                    dPadO = min(_e710, (length((_e711 - _e712)) - 0.2f));
                    let _e718 = dPadI;
                    let _e719 = gp;
                    let _e720 = e_3;
                    dPadI = min(_e718, (length((_e719 - _e720)) - 0.09f));
                }
            }
        }
    } else {
        let _e726 = minWH;
        if (_e726 >= 2f) {
            {
                let _e729 = minWH;
                if (_e729 >= 3f) {
                    local_1 = 0.72f;
                } else {
                    local_1 = 0.42f;
                }
                let _e735 = local_1;
                inset = _e735;
                let _e737 = cx;
                let _e738 = cy;
                bc = vec2<f32>(_e737, _e738);
                let _e741 = w_1;
                let _e742 = h_2;
                let _e746 = inset;
                bhalf = ((vec2<f32>(_e741, _e742) * 0.5f) - vec2(_e746));
                let _e751 = roundness_1;
                rr = min(0.28f, (_e751 * 0.35f));
                let _e756 = gp;
                let _e757 = bc;
                let _e759 = bhalf;
                let _e760 = sdRectangle((_e756 - _e757), _e759);
                let _e761 = rr;
                dB = (_e760 - _e761);
                let _e764 = maxWH;
                let _e765 = minWH;
                aspectB = (_e764 / _e765);
                let _e768 = cellHash;
                let _e773 = hash11_(((_e768 * 7.7f) + 1.1f));
                pkgHash = _e773;
                let _e775 = gp;
                let _e776 = bc;
                pc = (_e775 - _e776);
                let _e779 = h_2;
                let _e780 = w_1;
                if (_e779 >= _e780) {
                    let _e782 = pc;
                    local_2 = _e782.yx;
                } else {
                    let _e784 = pc;
                    local_2 = _e784.xy;
                }
                let _e787 = local_2;
                ap = _e787;
                let _e789 = maxWH;
                let _e792 = inset;
                along = ((_e789 * 0.5f) - _e792);
                let _e795 = aspectB;
                let _e798 = pkgHash;
                if ((_e795 >= 2.2f) && (_e798 < 0.3f)) {
                    {
                        let _e802 = dB;
                        dComp = _e802;
                        compColor = vec4<f32>(0.12f, 0.3f, 0.63f, 1f);
                        markColor = vec4<f32>(0.8f, 0.83f, 0.88f, 1f);
                        let _e813 = ap;
                        let _e815 = along;
                        let _e819 = ap;
                        let _e825 = sdRectangle(vec2<f32>(((_e813.x + _e815) - 0.3f), _e819.y), vec2<f32>(0.13f, 1000f));
                        let _e826 = dB;
                        dCompMk = max(_e825, (_e826 + 0.02f));
                    }
                } else {
                    let _e830 = aspectB;
                    let _e833 = pkgHash;
                    if ((_e830 >= 2.2f) && (_e833 < 0.55f)) {
                        {
                            let _e837 = dB;
                            dComp = _e837;
                            compColor = vec4<f32>(0.74f, 0.57f, 0.35f, 1f);
                            let _e843 = colorBkg_1;
                            markColor = _e843;
                            loop {
                                let _e846 = b_5;
                                if !((_e846 < 3i)) {
                                    break;
                                }
                                let _e853 = dCompMk;
                                let _e854 = ap;
                                let _e856 = b_5;
                                let _e863 = ap;
                                let _e869 = sdRectangle(vec2<f32>((_e854.x - ((f32(_e856) - 1f) * 0.55f)), _e863.y), vec2<f32>(0.08f, 1000f));
                                let _e870 = dB;
                                dCompMk = min(_e853, max(_e869, (_e870 + 0.03f)));
                                continuing {
                                    let _e850 = b_5;
                                    b_5 = (_e850 + 1i);
                                }
                            }
                        }
                    } else {
                        let _e875 = aspectB;
                        let _e878 = pkgHash;
                        if ((_e875 >= 2.2f) && (_e878 < 0.8f)) {
                            {
                                let _e882 = dB;
                                dComp = _e882;
                                compColor = vec4<f32>(0.2f, 0.21f, 0.24f, 1f);
                                let _e888 = color_1;
                                markColor = _e888;
                                let _e889 = along;
                                cspan = ((_e889 * 2f) - 0.5f);
                                let _e895 = cspan;
                                ch = i32(clamp(floor((_e895 / 0.9f)), 3f, 7f));
                                let _e904 = cspan;
                                let _e905 = ch;
                                csp = (_e904 / f32(_e905));
                                let _e909 = csp;
                                let _e912 = minWH;
                                let _e915 = inset;
                                cr = min((_e909 * 0.6f), (((_e912 * 0.5f) - (_e915 * 0.5f)) - 0.05f));
                                loop {
                                    let _e927 = c;
                                    let _e928 = ch;
                                    if !((_e927 < _e928)) {
                                        break;
                                    }
                                    {
                                        let _e934 = cspan;
                                        let _e938 = c;
                                        let _e942 = csp;
                                        o = ((-(_e934) * 0.5f) + ((f32(_e938) + 0.5f) * _e942));
                                        let _e946 = dcoil;
                                        let _e947 = ap;
                                        let _e949 = o;
                                        let _e951 = ap;
                                        let _e955 = cr;
                                        dcoil = min(_e946, abs((length(vec2<f32>((_e947.x - _e949), _e951.y)) - _e955)));
                                    }
                                    continuing {
                                        let _e931 = c;
                                        c = (_e931 + 1i);
                                    }
                                }
                                let _e959 = dcoil;
                                let _e962 = dB;
                                dCompMk = max((_e959 - 0.11f), (_e962 + 0.05f));
                            }
                        } else {
                            {
                                let _e966 = dB;
                                dBody = _e966;
                                let _e967 = minWH;
                                if (_e967 >= 3f) {
                                    {
                                        let _e970 = cx;
                                        let _e971 = cy;
                                        let _e972 = bhalf;
                                        notchC = vec2<f32>(_e970, (_e971 + _e972.y));
                                        let _e977 = dBody;
                                        let _e978 = gp;
                                        let _e979 = notchC;
                                        dBody = max(_e977, -((length((_e978 - _e979)) - 0.35f)));
                                        let _e986 = gp;
                                        let _e987 = cx;
                                        let _e988 = bhalf;
                                        let _e993 = cy;
                                        let _e994 = bhalf;
                                        dPin1_ = (length((_e986 - vec2<f32>(((_e987 - _e988.x) + 0.5f), ((_e993 + _e994.y) - 0.5f)))) - 0.18f);
                                    }
                                }
                            }
                        }
                    }
                }
                let _e1004 = gp;
                let _e1009 = ix0_;
                let _e1012 = ix1_;
                mx = clamp((floor(_e1004.x) + 0.5f), (_e1009 + 0.5f), (_e1012 - 0.5f));
                let _e1017 = gp;
                let _e1022 = iy0_;
                let _e1025 = iy1_;
                my = clamp((floor(_e1017.y) + 0.5f), (_e1022 + 0.5f), (_e1025 - 0.5f));
                let _e1030 = mx;
                let _e1031 = iy0_;
                let _e1033 = pinSeed;
                let _e1034 = rand2relSeeded(vec2<f32>(_e1030, _e1031), _e1033);
                let _e1038 = coverage_1;
                if ((_e1034.x + 0.5f) < _e1038) {
                    let _e1040 = dTrace;
                    let _e1041 = gp;
                    let _e1042 = mx;
                    let _e1043 = iy0_;
                    let _e1045 = mx;
                    let _e1046 = iy0_;
                    let _e1047 = inset;
                    let _e1050 = sdSegment(_e1041, vec2<f32>(_e1042, _e1043), vec2<f32>(_e1045, (_e1046 + _e1047)));
                    dTrace = min(_e1040, _e1050);
                }
                let _e1052 = mx;
                let _e1053 = iy1_;
                let _e1055 = pinSeed;
                let _e1056 = rand2relSeeded(vec2<f32>(_e1052, _e1053), _e1055);
                let _e1060 = coverage_1;
                if ((_e1056.x + 0.5f) < _e1060) {
                    let _e1062 = dTrace;
                    let _e1063 = gp;
                    let _e1064 = mx;
                    let _e1065 = iy1_;
                    let _e1067 = mx;
                    let _e1068 = iy1_;
                    let _e1069 = inset;
                    let _e1072 = sdSegment(_e1063, vec2<f32>(_e1064, _e1065), vec2<f32>(_e1067, (_e1068 - _e1069)));
                    dTrace = min(_e1062, _e1072);
                }
                let _e1074 = ix0_;
                let _e1075 = my;
                let _e1077 = pinSeed;
                let _e1078 = rand2relSeeded(vec2<f32>(_e1074, _e1075), _e1077);
                let _e1082 = coverage_1;
                if ((_e1078.x + 0.5f) < _e1082) {
                    let _e1084 = dTrace;
                    let _e1085 = gp;
                    let _e1086 = ix0_;
                    let _e1087 = my;
                    let _e1089 = ix0_;
                    let _e1090 = inset;
                    let _e1092 = my;
                    let _e1094 = sdSegment(_e1085, vec2<f32>(_e1086, _e1087), vec2<f32>((_e1089 + _e1090), _e1092));
                    dTrace = min(_e1084, _e1094);
                }
                let _e1096 = ix1_;
                let _e1097 = my;
                let _e1099 = pinSeed;
                let _e1100 = rand2relSeeded(vec2<f32>(_e1096, _e1097), _e1099);
                let _e1104 = coverage_1;
                if ((_e1100.x + 0.5f) < _e1104) {
                    let _e1106 = dTrace;
                    let _e1107 = gp;
                    let _e1108 = ix1_;
                    let _e1109 = my;
                    let _e1111 = ix1_;
                    let _e1112 = inset;
                    let _e1114 = my;
                    let _e1116 = sdSegment(_e1107, vec2<f32>(_e1108, _e1109), vec2<f32>((_e1111 - _e1112), _e1114));
                    dTrace = min(_e1106, _e1116);
                }
            }
        } else {
            {
                let _e1118 = h_2;
                let _e1119 = w_1;
                vertical = (_e1118 >= _e1119);
                let _e1124 = cx;
                hx0_ = _e1124;
                let _e1126 = cx;
                hx1_ = _e1126;
                let _e1128 = cy;
                vy0_ = _e1128;
                let _e1130 = cy;
                vy1_ = _e1130;
                let _e1133 = w_1;
                wc = i32(min(16f, _e1133));
                loop {
                    let _e1139 = s_1;
                    let _e1140 = wc;
                    if !((_e1139 < _e1140)) {
                        break;
                    }
                    {
                        let _e1146 = ix0_;
                        let _e1147 = s_1;
                        mx_1 = ((_e1146 + f32(_e1147)) + 0.5f);
                        let _e1153 = mx_1;
                        let _e1154 = iy0_;
                        let _e1156 = pinSeed;
                        let _e1157 = rand2relSeeded(vec2<f32>(_e1153, _e1154), _e1156);
                        let _e1161 = coverage_1;
                        if ((_e1157.x + 0.5f) < _e1161) {
                            {
                                let _e1163 = activeCount;
                                activeCount = (_e1163 + 1f);
                                let _e1166 = hx0_;
                                let _e1167 = mx_1;
                                hx0_ = min(_e1166, _e1167);
                                let _e1169 = hx1_;
                                let _e1170 = mx_1;
                                hx1_ = max(_e1169, _e1170);
                            }
                        }
                        let _e1172 = mx_1;
                        let _e1173 = iy1_;
                        let _e1175 = pinSeed;
                        let _e1176 = rand2relSeeded(vec2<f32>(_e1172, _e1173), _e1175);
                        let _e1180 = coverage_1;
                        if ((_e1176.x + 0.5f) < _e1180) {
                            {
                                let _e1182 = activeCount;
                                activeCount = (_e1182 + 1f);
                                let _e1185 = hx0_;
                                let _e1186 = mx_1;
                                hx0_ = min(_e1185, _e1186);
                                let _e1188 = hx1_;
                                let _e1189 = mx_1;
                                hx1_ = max(_e1188, _e1189);
                            }
                        }
                    }
                    continuing {
                        let _e1143 = s_1;
                        s_1 = (_e1143 + 1i);
                    }
                }
                let _e1192 = h_2;
                hc = i32(min(16f, _e1192));
                loop {
                    let _e1198 = s_2;
                    let _e1199 = hc;
                    if !((_e1198 < _e1199)) {
                        break;
                    }
                    {
                        let _e1205 = iy0_;
                        let _e1206 = s_2;
                        my_1 = ((_e1205 + f32(_e1206)) + 0.5f);
                        let _e1212 = ix0_;
                        let _e1213 = my_1;
                        let _e1215 = pinSeed;
                        let _e1216 = rand2relSeeded(vec2<f32>(_e1212, _e1213), _e1215);
                        let _e1220 = coverage_1;
                        if ((_e1216.x + 0.5f) < _e1220) {
                            {
                                let _e1222 = activeCount;
                                activeCount = (_e1222 + 1f);
                                let _e1225 = vy0_;
                                let _e1226 = my_1;
                                vy0_ = min(_e1225, _e1226);
                                let _e1228 = vy1_;
                                let _e1229 = my_1;
                                vy1_ = max(_e1228, _e1229);
                            }
                        }
                        let _e1231 = ix1_;
                        let _e1232 = my_1;
                        let _e1234 = pinSeed;
                        let _e1235 = rand2relSeeded(vec2<f32>(_e1231, _e1232), _e1234);
                        let _e1239 = coverage_1;
                        if ((_e1235.x + 0.5f) < _e1239) {
                            {
                                let _e1241 = activeCount;
                                activeCount = (_e1241 + 1f);
                                let _e1244 = vy0_;
                                let _e1245 = my_1;
                                vy0_ = min(_e1244, _e1245);
                                let _e1247 = vy1_;
                                let _e1248 = my_1;
                                vy1_ = max(_e1247, _e1248);
                            }
                        }
                    }
                    continuing {
                        let _e1202 = s_2;
                        s_2 = (_e1202 + 1i);
                    }
                }
                let _e1250 = activeCount;
                if (_e1250 >= 1f) {
                    {
                        let _e1253 = dTrace;
                        let _e1254 = gp;
                        let _e1255 = hx0_;
                        let _e1256 = cy;
                        let _e1258 = hx1_;
                        let _e1259 = cy;
                        let _e1261 = sdSegment(_e1254, vec2<f32>(_e1255, _e1256), vec2<f32>(_e1258, _e1259));
                        dTrace = min(_e1253, _e1261);
                        let _e1263 = dTrace;
                        let _e1264 = gp;
                        let _e1265 = cx;
                        let _e1266 = vy0_;
                        let _e1268 = cx;
                        let _e1269 = vy1_;
                        let _e1271 = sdSegment(_e1264, vec2<f32>(_e1265, _e1266), vec2<f32>(_e1268, _e1269));
                        dTrace = min(_e1263, _e1271);
                        let _e1273 = gp;
                        let _e1278 = ix0_;
                        let _e1281 = ix1_;
                        mx_2 = clamp((floor(_e1273.x) + 0.5f), (_e1278 + 0.5f), (_e1281 - 0.5f));
                        let _e1286 = gp;
                        let _e1291 = iy0_;
                        let _e1294 = iy1_;
                        my_2 = clamp((floor(_e1286.y) + 0.5f), (_e1291 + 0.5f), (_e1294 - 0.5f));
                        let _e1299 = mx_2;
                        let _e1300 = iy0_;
                        let _e1302 = pinSeed;
                        let _e1303 = rand2relSeeded(vec2<f32>(_e1299, _e1300), _e1302);
                        let _e1307 = coverage_1;
                        if ((_e1303.x + 0.5f) < _e1307) {
                            let _e1309 = dTrace;
                            let _e1310 = gp;
                            let _e1311 = mx_2;
                            let _e1312 = iy0_;
                            let _e1314 = mx_2;
                            let _e1315 = cy;
                            let _e1317 = sdSegment(_e1310, vec2<f32>(_e1311, _e1312), vec2<f32>(_e1314, _e1315));
                            dTrace = min(_e1309, _e1317);
                        }
                        let _e1319 = mx_2;
                        let _e1320 = iy1_;
                        let _e1322 = pinSeed;
                        let _e1323 = rand2relSeeded(vec2<f32>(_e1319, _e1320), _e1322);
                        let _e1327 = coverage_1;
                        if ((_e1323.x + 0.5f) < _e1327) {
                            let _e1329 = dTrace;
                            let _e1330 = gp;
                            let _e1331 = mx_2;
                            let _e1332 = iy1_;
                            let _e1334 = mx_2;
                            let _e1335 = cy;
                            let _e1337 = sdSegment(_e1330, vec2<f32>(_e1331, _e1332), vec2<f32>(_e1334, _e1335));
                            dTrace = min(_e1329, _e1337);
                        }
                        let _e1339 = ix0_;
                        let _e1340 = my_2;
                        let _e1342 = pinSeed;
                        let _e1343 = rand2relSeeded(vec2<f32>(_e1339, _e1340), _e1342);
                        let _e1347 = coverage_1;
                        if ((_e1343.x + 0.5f) < _e1347) {
                            let _e1349 = dTrace;
                            let _e1350 = gp;
                            let _e1351 = ix0_;
                            let _e1352 = my_2;
                            let _e1354 = cx;
                            let _e1355 = my_2;
                            let _e1357 = sdSegment(_e1350, vec2<f32>(_e1351, _e1352), vec2<f32>(_e1354, _e1355));
                            dTrace = min(_e1349, _e1357);
                        }
                        let _e1359 = ix1_;
                        let _e1360 = my_2;
                        let _e1362 = pinSeed;
                        let _e1363 = rand2relSeeded(vec2<f32>(_e1359, _e1360), _e1362);
                        let _e1367 = coverage_1;
                        if ((_e1363.x + 0.5f) < _e1367) {
                            let _e1369 = dTrace;
                            let _e1370 = gp;
                            let _e1371 = ix1_;
                            let _e1372 = my_2;
                            let _e1374 = cx;
                            let _e1375 = my_2;
                            let _e1377 = sdSegment(_e1370, vec2<f32>(_e1371, _e1372), vec2<f32>(_e1374, _e1375));
                            dTrace = min(_e1369, _e1377);
                        }
                        let _e1379 = activeCount;
                        if (_e1379 >= 3f) {
                            let _e1382 = dTrace;
                            let _e1383 = gp;
                            let _e1384 = cx;
                            let _e1385 = cy;
                            let _e1389 = traceHalf;
                            dTrace = min(_e1382, (length((_e1383 - vec2<f32>(_e1384, _e1385))) - (_e1389 * 1.7f)));
                        }
                        let _e1394 = activeCount;
                        if (_e1394 < 1.5f) {
                            {
                                let _e1397 = gp;
                                let _e1398 = cx;
                                let _e1399 = cy;
                                dPadO = (length((_e1397 - vec2<f32>(_e1398, _e1399))) - 0.24f);
                                let _e1405 = gp;
                                let _e1406 = cx;
                                let _e1407 = cy;
                                dPadI = (length((_e1405 - vec2<f32>(_e1406, _e1407))) - 0.11f);
                            }
                        }
                        let _e1415 = vertical;
                        if _e1415 {
                            {
                                let _e1416 = cx;
                                let _e1417 = iy0_;
                                let _e1419 = pinSeed;
                                let _e1420 = rand2relSeeded(vec2<f32>(_e1416, _e1417), _e1419);
                                let _e1424 = coverage_1;
                                endA = ((_e1420.x + 0.5f) < _e1424);
                                let _e1426 = cx;
                                let _e1427 = iy1_;
                                let _e1429 = pinSeed;
                                let _e1430 = rand2relSeeded(vec2<f32>(_e1426, _e1427), _e1429);
                                let _e1434 = coverage_1;
                                endB = ((_e1430.x + 0.5f) < _e1434);
                            }
                        } else {
                            {
                                let _e1436 = ix0_;
                                let _e1437 = cy;
                                let _e1439 = pinSeed;
                                let _e1440 = rand2relSeeded(vec2<f32>(_e1436, _e1437), _e1439);
                                let _e1444 = coverage_1;
                                endA = ((_e1440.x + 0.5f) < _e1444);
                                let _e1446 = ix1_;
                                let _e1447 = cy;
                                let _e1449 = pinSeed;
                                let _e1450 = rand2relSeeded(vec2<f32>(_e1446, _e1447), _e1449);
                                let _e1454 = coverage_1;
                                endB = ((_e1450.x + 0.5f) < _e1454);
                            }
                        }
                        let _e1456 = endA;
                        let _e1457 = endB;
                        if (_e1456 && _e1457) {
                            {
                                let _e1459 = gp;
                                let _e1460 = cx;
                                let _e1461 = cy;
                                pc2_ = (_e1459 - vec2<f32>(_e1460, _e1461));
                                let _e1465 = vertical;
                                if _e1465 {
                                    let _e1466 = pc2_;
                                    local_3 = _e1466.yx;
                                } else {
                                    let _e1468 = pc2_;
                                    local_3 = _e1468.xy;
                                }
                                let _e1471 = local_3;
                                ap_1 = _e1471;
                                let _e1473 = maxWH;
                                if (_e1473 <= 2.5f) {
                                    {
                                        let _e1476 = ap_1;
                                        let _e1480 = sdRectangle(_e1476, vec2<f32>(0.17f, 0.62f));
                                        dGap = _e1480;
                                        let _e1481 = ap_1;
                                        let _e1485 = ap_1;
                                        let _e1491 = sdRectangle(vec2<f32>((_e1481.x - 0.22f), _e1485.y), vec2<f32>(0.055f, 0.5f));
                                        let _e1492 = ap_1;
                                        let _e1496 = ap_1;
                                        let _e1502 = sdRectangle(vec2<f32>((_e1492.x + 0.22f), _e1496.y), vec2<f32>(0.055f, 0.5f));
                                        dCapPlate = min(_e1491, _e1502);
                                    }
                                } else {
                                    let _e1504 = cellHash;
                                    let _e1509 = hash11_(((_e1504 * 43.1f) + 2f));
                                    if (_e1509 < 0.35f) {
                                        {
                                            let _e1512 = maxWH;
                                            pillHalf = clamp(((_e1512 * 0.5f) - 0.9f), 0.5f, 1.4f);
                                            let _e1521 = ap_1;
                                            let _e1522 = pillHalf;
                                            let _e1525 = sdRectangle(_e1521, vec2<f32>(_e1522, 0.3f));
                                            dComp = (_e1525 - 0.26f);
                                            compColor = vec4<f32>(0.74f, 0.57f, 0.35f, 1f);
                                            let _e1533 = colorBkg_1;
                                            markColor = _e1533;
                                            loop {
                                                let _e1536 = b_6;
                                                if !((_e1536 < 3i)) {
                                                    break;
                                                }
                                                let _e1543 = dCompMk;
                                                let _e1544 = ap_1;
                                                let _e1546 = b_6;
                                                let _e1551 = pillHalf;
                                                let _e1557 = ap_1;
                                                let _e1563 = sdRectangle(vec2<f32>((_e1544.x - ((f32(_e1546) - 1f) * min(0.42f, (_e1551 * 0.55f)))), _e1557.y), vec2<f32>(0.06f, 0.34f));
                                                let _e1564 = dComp;
                                                dCompMk = min(_e1543, max(_e1563, (_e1564 + 0.03f)));
                                                continuing {
                                                    let _e1540 = b_6;
                                                    b_6 = (_e1540 + 1i);
                                                }
                                            }
                                        }
                                    } else {
                                        {
                                            let _e1569 = maxWH;
                                            span = (_e1569 - 1.3f);
                                            let _e1573 = span;
                                            humps = i32(clamp(floor((_e1573 / 0.8f)), 2f, 6f));
                                            let _e1582 = span;
                                            let _e1583 = humps;
                                            sp = (_e1582 / f32(_e1583));
                                            let _e1587 = sp;
                                            r = min((_e1587 * 0.62f), 0.45f);
                                            loop {
                                                let _e1597 = c_1;
                                                let _e1598 = humps;
                                                if !((_e1597 < _e1598)) {
                                                    break;
                                                }
                                                {
                                                    let _e1604 = span;
                                                    let _e1608 = c_1;
                                                    let _e1612 = sp;
                                                    off = ((-(_e1604) * 0.5f) + ((f32(_e1608) + 0.5f) * _e1612));
                                                    let _e1616 = dc;
                                                    let _e1617 = ap_1;
                                                    let _e1619 = off;
                                                    let _e1621 = ap_1;
                                                    let _e1625 = r;
                                                    dc = min(_e1616, abs((length(vec2<f32>((_e1617.x - _e1619), _e1621.y)) - _e1625)));
                                                }
                                                continuing {
                                                    let _e1601 = c_1;
                                                    c_1 = (_e1601 + 1i);
                                                }
                                            }
                                            let _e1629 = dTrace;
                                            let _e1630 = dc;
                                            let _e1631 = ap_1;
                                            dTrace = min(_e1629, max(_e1630, -(_e1631.y)));
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
    let _e1636 = colorBkg_1;
    col = _e1636;
    let _e1639 = traceHalf;
    let _e1640 = aaG;
    let _e1642 = traceHalf;
    let _e1643 = aaG;
    let _e1645 = dTrace;
    tCov = (1f - smoothstep((_e1639 - _e1640), (_e1642 + _e1643), _e1645));
    let _e1649 = col;
    let _e1650 = color_1;
    let _e1651 = tCov;
    let _e1652 = color_1;
    col = mix(_e1649, _e1650, vec4((_e1651 * _e1652.w)));
    let _e1658 = aaG;
    let _e1660 = aaG;
    let _e1661 = dGap;
    gapCov = (1f - smoothstep(-(_e1658), _e1660, _e1661));
    let _e1665 = col;
    let _e1666 = colorBkg_1;
    let _e1667 = gapCov;
    col = mix(_e1665, _e1666, vec4(_e1667));
    let _e1671 = aaG;
    let _e1673 = aaG;
    let _e1674 = dCapPlate;
    capCov = (1f - smoothstep(-(_e1671), _e1673, _e1674));
    let _e1678 = col;
    let _e1679 = color_1;
    let _e1680 = capCov;
    let _e1681 = color_1;
    col = mix(_e1678, _e1679, vec4((_e1680 * _e1681.w)));
    let _e1687 = aaG;
    let _e1689 = aaG;
    let _e1690 = dPadO;
    padO = (1f - smoothstep(-(_e1687), _e1689, _e1690));
    let _e1694 = col;
    let _e1695 = color_1;
    let _e1696 = padO;
    let _e1697 = color_1;
    col = mix(_e1694, _e1695, vec4((_e1696 * _e1697.w)));
    let _e1703 = aaG;
    let _e1705 = aaG;
    let _e1706 = dPadI;
    padI = (1f - smoothstep(-(_e1703), _e1705, _e1706));
    let _e1710 = col;
    let _e1711 = colorBkg_1;
    let _e1712 = padI;
    col = mix(_e1710, _e1711, vec4(_e1712));
    let _e1716 = aaG;
    let _e1718 = aaG;
    let _e1719 = dBody;
    bodyCov = (1f - smoothstep(-(_e1716), _e1718, _e1719));
    let _e1723 = col;
    let _e1724 = color1_1;
    let _e1725 = bodyCov;
    let _e1726 = color1_1;
    col = mix(_e1723, _e1724, vec4((_e1725 * _e1726.w)));
    let _e1731 = traceHalf;
    let _e1734 = aaG;
    rimHalf = max((_e1731 * 0.8f), _e1734);
    let _e1738 = rimHalf;
    let _e1739 = aaG;
    let _e1741 = rimHalf;
    let _e1742 = aaG;
    let _e1744 = dBody;
    rimCov = (1f - smoothstep((_e1738 - _e1739), (_e1741 + _e1742), abs(_e1744)));
    let _e1749 = col;
    let _e1750 = color_1;
    let _e1751 = rimCov;
    let _e1752 = color_1;
    col = mix(_e1749, _e1750, vec4((_e1751 * _e1752.w)));
    let _e1758 = aaG;
    let _e1760 = aaG;
    let _e1761 = dComp;
    compCov = (1f - smoothstep(-(_e1758), _e1760, _e1761));
    let _e1765 = col;
    let _e1766 = compColor;
    let _e1767 = compCov;
    let _e1768 = compColor;
    col = mix(_e1765, _e1766, vec4((_e1767 * _e1768.w)));
    let _e1774 = aaG;
    let _e1776 = aaG;
    let _e1777 = dCompMk;
    mkCov = (1f - smoothstep(-(_e1774), _e1776, _e1777));
    let _e1781 = col;
    let _e1782 = markColor;
    let _e1783 = mkCov;
    let _e1784 = compCov;
    col = mix(_e1781, _e1782, vec4((_e1783 * _e1784)));
    let _e1789 = aaG;
    let _e1791 = aaG;
    let _e1792 = dPin1_;
    p1Cov = (1f - smoothstep(-(_e1789), _e1791, _e1792));
    let _e1796 = col;
    let _e1797 = color_1;
    let _e1798 = p1Cov;
    let _e1799 = color_1;
    col = mix(_e1796, _e1797, vec4((_e1798 * _e1799.w)));
    let _e1805 = colorBkg_1;
    col.w = _e1805.w;
    let _e1807 = col;
    return _e1807;
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
    let _e65 = global.U[4];
    let _e69 = global.U[5];
    let _e74 = global.U[6];
    let _e78 = global.U[7];
    let _e82 = global.U[8];
    let _e86 = global.U[9];
    let _e90 = global.U[10];
    let _e94 = global.U[11];
    let _e97 = global.U[12];
    let _e100 = global.U[13];
    let _e103 = global.U[14];
    let _e107 = global.U[15];
    let _e111 = global.U[16];
    let _e112 = _e111.xyz;
    let _e115 = global.U[17];
    let _e116 = _e115.xyz;
    let _e119 = global.U[18];
    let _e120 = _e119.xyz;
    let _e134 = circuitBoard((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65.xy, i32(_e69.x), _e74.x, _e78.x, _e82.x, _e86.x, _e90.x, _e94, _e97, _e100, _e103.x, _e107.x, mat3x3<f32>(vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e116.x, _e116.y, _e116.z), vec3<f32>(_e120.x, _e120.y, _e120.z)));
    fragColor = _e134;
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
