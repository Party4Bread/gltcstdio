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
        let _e137 = textureSample(t_source, samp, ((vec2<f32>((_e121.x / _e125.x), _e128.y) / vec2(2f)) + vec2(0.5f)));
        return _e137;
    }
    let _e138 = sxg;
    let _e140 = th;
    let _e142 = syg;
    let _e143 = th;
    let _e147 = syg;
    let _e149 = th;
    let _e151 = sxg;
    let _e152 = th;
    if (((abs(_e138) < _e140) && (_e142 > -(_e143))) || ((abs(_e147) < _e149) && (_e151 > -(_e152)))) {
        {
            let _e157 = uv_1;
            let _e161 = global.U[0];
            let _e164 = uv_1;
            let _e173 = textureSample(t_source, samp, ((vec2<f32>((_e157.x / _e161.x), _e164.y) / vec2(2f)) + vec2(0.5f)));
            col = _e173;
            let _e175 = col;
            let _e177 = color_1;
            let _e179 = color_1;
            let _e182 = mix(_e175.xyz, _e177.xyz, vec3(_e179.w));
            let _e183 = col;
            return vec4<f32>(_e182.x, _e182.y, _e182.z, _e183.w);
        }
    }
    let _e189 = srcRatio;
    let _e192 = windowTransform_1[0];
    winA = (_e189 * length(_e192.xy));
    let _e197 = ws;
    winB = _e197;
    let _e201 = windowTransform_1[0];
    wax = normalize(_e201.xy);
    let _e205 = wax;
    c1_ = abs(_e205.x);
    let _e209 = wax;
    s1_ = abs(_e209.y);
    let _e214 = c1_;
    let _e216 = s1_;
    sin2_ = ((2f * _e214) * _e216);
    let _e221 = winA;
    let _e222 = winB;
    let _e223 = sin2_;
    if (_e221 <= (_e222 * _e223)) {
        {
            let _e226 = winA;
            let _e228 = c1_;
            W = (_e226 / (2f * _e228));
            let _e231 = winA;
            let _e233 = s1_;
            H = (_e231 / (2f * _e233));
        }
    } else {
        let _e236 = winB;
        let _e237 = winA;
        let _e238 = sin2_;
        if (_e236 <= (_e237 * _e238)) {
            {
                let _e241 = winB;
                let _e243 = s1_;
                W = (_e241 / (2f * _e243));
                let _e246 = winB;
                let _e248 = c1_;
                H = (_e246 / (2f * _e248));
            }
        } else {
            {
                let _e251 = c1_;
                let _e252 = c1_;
                let _e254 = s1_;
                let _e255 = s1_;
                det = ((_e251 * _e252) - (_e254 * _e255));
                let _e259 = winA;
                let _e260 = c1_;
                let _e262 = winB;
                let _e263 = s1_;
                let _e266 = det;
                W = (((_e259 * _e260) - (_e262 * _e263)) / _e266);
                let _e268 = winB;
                let _e269 = c1_;
                let _e271 = winA;
                let _e272 = s1_;
                let _e275 = det;
                H = (((_e268 * _e269) - (_e271 * _e272)) / _e275);
            }
        }
    }
    let _e277 = W;
    W = max(_e277, 0f);
    let _e280 = H;
    H = max(_e280, 0f);
    let _e285 = windowTransform_1[2];
    wc = _e285.xy;
    let _e288 = wc;
    let _e290 = W;
    ex0_ = (_e288.x - _e290);
    let _e293 = wc;
    let _e295 = H;
    ey0_ = (_e293.y - _e295);
    let _e298 = wc;
    let _e300 = W;
    ex1_ = (_e298.x + _e300);
    let _e303 = wc;
    let _e305 = H;
    ey1_ = (_e303.y + _e305);
    let _e308 = uv_1;
    p = _e308;
    let _e314 = variability_1;
    regularity = (1f - _e314);
    loop {
        let _e319 = j;
        let _e320 = iterations_1;
        if !((_e319 < _e320)) {
            break;
        }
        {
            let _e326 = outAR;
            let _e330 = outAR;
            rect_2 = vec4<f32>(-(_e326), -1f, _e330, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e345 = bias;
            b_2 = _e345;
            i = 0f;
            loop {
                let _e349 = i;
                let _e350 = sPos;
                let _e352 = scale;
                if !(((_e349 + _e350) < _e352)) {
                    break;
                }
                {
                    let _e358 = splits_2;
                    let _e359 = randomSeed_1;
                    let _e362 = rand2relSeeded(_e358, (_e359 + 122.1f));
                    rnd_1 = _e362;
                    let _e364 = rect_2;
                    let _e366 = rect_2;
                    size = (_e364.zw - _e366.xy);
                    let _e370 = size;
                    let _e372 = pixel;
                    let _e374 = size;
                    let _e376 = pixel;
                    if ((_e370.x < _e372) || (_e374.y < _e376)) {
                        break;
                    }
                    let _e379 = rnd_1;
                    let _e383 = regularity;
                    if ((_e379.x + 0.5f) < (_e383 * 2f)) {
                        let _e387 = size;
                        let _e389 = size;
                        horSplit = (_e387.y > _e389.x);
                    }
                    let _e394 = regularity;
                    var2_ = (1f - max(0f, ((_e394 * 2f) - 1f)));
                    let _e402 = horSplit;
                    if _e402 {
                        {
                            let _e403 = rect_2;
                            let _e405 = rect_2;
                            let _e407 = var2_;
                            let _e408 = rnd_1;
                            let _e410 = b_2;
                            let _e412 = withBias(_e408.y, _e410.y);
                            Y = mix(_e403.y, _e405.w, ((_e407 * _e412) + 0.5f));
                            let _e418 = rect_2;
                            let _e420 = ex1_;
                            let _e422 = rect_2;
                            let _e424 = ex0_;
                            let _e427 = Y;
                            let _e428 = ey0_;
                            let _e431 = Y;
                            let _e432 = ey1_;
                            if ((((_e418.x < _e420) && (_e422.z > _e424)) && (_e427 > _e428)) && (_e431 < _e432)) {
                                let _e435 = Y;
                                let _e436 = ey0_;
                                let _e438 = ey1_;
                                let _e439 = Y;
                                if ((_e435 - _e436) < (_e438 - _e439)) {
                                    let _e442 = ey0_;
                                    local = _e442;
                                } else {
                                    let _e443 = ey1_;
                                    local = _e443;
                                }
                                let _e445 = local;
                                Y = _e445;
                            }
                            let _e446 = Y;
                            let _e447 = p;
                            let _e451 = th;
                            if (abs((_e446 - _e447.y)) < _e451) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e454 = p;
                            let _e456 = Y;
                            if (_e454.y < _e456) {
                                {
                                    let _e459 = Y;
                                    rect_2.w = _e459;
                                    let _e461 = splits_2.y;
                                    splits_2.y = (_e461 + 1f);
                                    let _e464 = sPos;
                                    let _e465 = inverter;
                                    let _e466 = sscale;
                                    sPos = (_e464 + (_e465 * _e466));
                                }
                            } else {
                                {
                                    let _e470 = Y;
                                    rect_2.y = _e470;
                                    let _e472 = splits_2;
                                    splits_2.y = (_e472.y + 100f);
                                    let _e476 = sPos;
                                    let _e478 = inverter;
                                    let _e480 = sscale;
                                    sPos = (_e476 + ((1f - _e478) * _e480));
                                }
                            }
                        }
                    } else {
                        {
                            let _e483 = rect_2;
                            let _e485 = rect_2;
                            let _e487 = var2_;
                            let _e488 = rnd_1;
                            let _e490 = b_2;
                            let _e492 = withBias(_e488.x, _e490.x);
                            X = mix(_e483.x, _e485.z, ((_e487 * _e492) + 0.5f));
                            let _e498 = rect_2;
                            let _e500 = ey1_;
                            let _e502 = rect_2;
                            let _e504 = ey0_;
                            let _e507 = X;
                            let _e508 = ex0_;
                            let _e511 = X;
                            let _e512 = ex1_;
                            if ((((_e498.y < _e500) && (_e502.w > _e504)) && (_e507 > _e508)) && (_e511 < _e512)) {
                                let _e515 = X;
                                let _e516 = ex0_;
                                let _e518 = ex1_;
                                let _e519 = X;
                                if ((_e515 - _e516) < (_e518 - _e519)) {
                                    let _e522 = ex0_;
                                    local_1 = _e522;
                                } else {
                                    let _e523 = ex1_;
                                    local_1 = _e523;
                                }
                                let _e525 = local_1;
                                X = _e525;
                            }
                            let _e526 = X;
                            let _e527 = p;
                            let _e531 = th;
                            if (abs((_e526 - _e527.x)) < _e531) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e534 = p;
                            let _e536 = X;
                            if (_e534.x < _e536) {
                                {
                                    let _e539 = X;
                                    rect_2.z = _e539;
                                    let _e541 = splits_2.x;
                                    splits_2.x = (_e541 + 1f);
                                    let _e544 = sPos;
                                    let _e545 = inverter;
                                    let _e546 = sscale;
                                    sPos = (_e544 + (_e545 * _e546));
                                }
                            } else {
                                {
                                    let _e550 = X;
                                    rect_2.x = _e550;
                                    let _e552 = splits_2;
                                    splits_2.x = (_e552.x + 100f);
                                    let _e556 = sPos;
                                    let _e558 = inverter;
                                    let _e560 = sscale;
                                    sPos = (_e556 + ((1f - _e558) * _e560));
                                }
                            }
                        }
                    }
                    let _e563 = horSplit;
                    horSplit = !(_e563);
                    let _e566 = inverter;
                    inverter = (1f - _e566);
                    let _e568 = sscale;
                    sscale = (_e568 * 0.5f);
                    let _e571 = b_2;
                    b_2 = (_e571 * 0.5f);
                }
                continuing {
                    let _e355 = i;
                    i = (_e355 + 1f);
                }
            }
            let _e574 = border;
            if _e574 {
                break;
            }
            let _e575 = p;
            let _e576 = rect_2;
            let _e577 = splits_2;
            let _e578 = intensity_3;
            let _e579 = randomSeed_1;
            let _e580 = distort9_(_e575, _e576, _e577, _e578, _e579);
            p = _e580;
        }
        continuing {
            let _e323 = j;
            j = (_e323 + 1i);
        }
    }
    let _e581 = p;
    ps = _e581;
    let _e583 = pixelation_1;
    if (_e583 > 0.0001f) {
        let _e586 = p;
        let _e587 = pixelation_1;
        let _e594 = pixelation_1;
        ps = (floor(((_e586 / vec2(_e587)) + vec2(0.5f))) * _e594);
    }
    let _e596 = border;
    if _e596 {
        {
            let _e597 = uv_1;
            let _e601 = global.U[0];
            let _e604 = uv_1;
            let _e613 = textureSample(t_source, samp, ((vec2<f32>((_e597.x / _e601.x), _e604.y) / vec2(2f)) + vec2(0.5f)));
            col_1 = _e613;
            let _e615 = col_1;
            let _e617 = color_1;
            let _e619 = color_1;
            let _e622 = mix(_e615.xyz, _e617.xyz, vec3(_e619.w));
            let _e623 = col_1;
            return vec4<f32>(_e622.x, _e622.y, _e622.z, _e623.w);
        }
    }
    let _e629 = ps;
    let _e633 = global.U[0];
    let _e636 = ps;
    let _e645 = textureSample(t_source, samp, ((vec2<f32>((_e629.x / _e633.x), _e636.y) / vec2(2f)) + vec2(0.5f)));
    return _e645;
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
