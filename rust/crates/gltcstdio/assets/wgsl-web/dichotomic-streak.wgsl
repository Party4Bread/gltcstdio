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
var t_source: texture_2d<f32>;

fn distort(pos: vec2<f32>, a: vec2<f32>, b: vec2<f32>, intensity: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var intensity_1: f32;
    var c: vec2<f32>;
    var p: vec2<f32>;

    pos_1 = pos;
    a_1 = a;
    b_1 = b;
    intensity_1 = intensity;
    let _e14 = a_1;
    let _e15 = b_1;
    c = ((_e14 + _e15) / vec2(2f));
    let _e21 = c;
    let _e22 = pos_1;
    let _e23 = c;
    let _e26 = intensity_1;
    p = (_e21 + ((_e22 - _e23) * pow(1.05f, _e26)));
    let _e31 = p;
    return _e31;
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

fn withBias(x_3: f32, b_2: f32) -> f32 {
    var x_4: f32;
    var b_3: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_3 = b_2;
    let _e10 = b_3;
    s = sign(_e10);
    let _e13 = b_3;
    ab = abs(_e13);
    let _e16 = x_4;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn dichotomicStreak(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity_2: f32, iterations: i32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, mode: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_3: f32;
    var iterations_1: i32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var mode_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var bias: vec2<f32>;
    var scale: f32;
    var ratio: f32;
    var pixel: f32;
    var p_1: vec2<f32>;
    var border: bool = false;
    var rect: vec4<f32>;
    var rndStep: f32 = 1f;
    var regularity: f32;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var i: f32;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var variability_2: f32;
    var Y: f32;
    var X: f32;
    var col: vec4<f32>;
    var outCol: vec4<f32>;
    var aa: vec2<f32>;
    var bb: vec2<f32>;
    var k_4: f32;
    var local: vec4<f32>;
    var local_1: vec4<f32>;
    var local_2: f32;
    var k_5: f32;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;
    var k_6: f32;
    var local_5: vec4<f32>;
    var k_7: f32;
    var local_6: vec4<f32>;
    var local_7: f32;
    var k_8: f32;
    var local_8: vec4<f32>;
    var local_9: vec4<f32>;
    var kx: f32;
    var ky: f32;
    var local_10: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_3 = intensity_2;
    iterations_1 = iterations;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    mode_1 = mode;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    bias = (_e28 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e41 = modelTransform_1[0][0];
    let _e46 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e41, _e46)));
    let _e51 = sourceDim_1;
    let _e53 = sourceDim_1;
    let _e57 = rounded((_e51.x / _e53.y), 0.01f);
    ratio = _e57;
    let _e60 = sourceDim_1;
    pixel = (2f / _e60.y);
    let _e64 = uv_1;
    p_1 = _e64;
    let _e71 = mode_1;
    let _e74 = mode_1;
    let _e78 = mode_1;
    if (((_e71 == 1i) || (_e74 == 8i)) || (_e78 == 9i)) {
        rndStep = 0f;
    }
    let _e84 = variability_1;
    regularity = (1f - _e84);
    loop {
        let _e89 = j;
        let _e90 = iterations_1;
        if !((_e89 < _e90)) {
            break;
        }
        {
            let _e96 = ratio;
            let _e100 = ratio;
            rect = vec4<f32>(-(_e96), -1f, _e100, 1f);
            horSplit = true;
            splits = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            i = 0f;
            loop {
                let _e117 = i;
                let _e118 = sPos;
                let _e120 = scale;
                if !(((_e117 + _e118) < _e120)) {
                    break;
                }
                {
                    let _e126 = splits;
                    let _e127 = randomSeed_1;
                    let _e130 = rndStep;
                    let _e131 = j;
                    let _e135 = rand2relSeeded(_e126, ((_e127 + 122.1f) + (_e130 * f32(_e131))));
                    rnd = _e135;
                    let _e137 = rect;
                    let _e139 = rect;
                    size = (_e137.zw - _e139.xy);
                    let _e143 = size;
                    let _e145 = pixel;
                    let _e147 = size;
                    let _e149 = pixel;
                    if ((_e143.x < _e145) || (_e147.y < _e149)) {
                        break;
                    }
                    let _e152 = rnd;
                    let _e156 = regularity;
                    if ((_e152.x + 0.5f) < (_e156 * 2f)) {
                        let _e160 = size;
                        let _e162 = size;
                        horSplit = (_e160.y > _e162.x);
                    }
                    let _e167 = regularity;
                    variability_2 = (1f - max(0f, ((_e167 * 2f) - 1f)));
                    let _e175 = horSplit;
                    if _e175 {
                        {
                            let _e176 = rect;
                            let _e178 = rect;
                            let _e180 = variability_2;
                            let _e181 = rnd;
                            let _e183 = bias;
                            let _e185 = withBias(_e181.y, _e183.y);
                            Y = mix(_e176.y, _e178.w, ((_e180 * _e185) + 0.5f));
                            let _e191 = Y;
                            let _e192 = p_1;
                            let _e196 = thickness_1;
                            if (abs((_e191 - _e192.y)) < (_e196 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e201 = p_1;
                            let _e203 = Y;
                            if (_e201.y < _e203) {
                                {
                                    let _e206 = Y;
                                    rect.w = _e206;
                                    let _e208 = splits.y;
                                    splits.y = (_e208 + 1f);
                                    let _e211 = sPos;
                                    let _e212 = inverter;
                                    let _e213 = sscale;
                                    sPos = (_e211 + (_e212 * _e213));
                                }
                            } else {
                                {
                                    let _e217 = Y;
                                    rect.y = _e217;
                                    let _e219 = splits;
                                    splits.y = (_e219.y + 100f);
                                    let _e223 = sPos;
                                    let _e225 = inverter;
                                    let _e227 = sscale;
                                    sPos = (_e223 + ((1f - _e225) * _e227));
                                }
                            }
                        }
                    } else {
                        {
                            let _e230 = rect;
                            let _e232 = rect;
                            let _e234 = variability_2;
                            let _e235 = rnd;
                            let _e237 = bias;
                            let _e239 = withBias(_e235.x, _e237.x);
                            X = mix(_e230.x, _e232.z, ((_e234 * _e239) + 0.5f));
                            let _e245 = X;
                            let _e246 = p_1;
                            let _e250 = thickness_1;
                            if (abs((_e245 - _e246.x)) < (_e250 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e255 = p_1;
                            let _e257 = X;
                            if (_e255.x < _e257) {
                                {
                                    let _e260 = X;
                                    rect.z = _e260;
                                    let _e262 = splits.x;
                                    splits.x = (_e262 + 1f);
                                    let _e265 = sPos;
                                    let _e266 = inverter;
                                    let _e267 = sscale;
                                    sPos = (_e265 + (_e266 * _e267));
                                }
                            } else {
                                {
                                    let _e271 = X;
                                    rect.x = _e271;
                                    let _e273 = splits;
                                    splits.x = (_e273.x + 100f);
                                    let _e277 = sPos;
                                    let _e279 = inverter;
                                    let _e281 = sscale;
                                    sPos = (_e277 + ((1f - _e279) * _e281));
                                }
                            }
                        }
                    }
                    let _e284 = horSplit;
                    horSplit = !(_e284);
                    let _e287 = inverter;
                    inverter = (1f - _e287);
                    let _e289 = sscale;
                    sscale = (_e289 * 0.5f);
                    let _e292 = bias;
                    bias = (_e292 * 0.5f);
                }
                continuing {
                    let _e123 = i;
                    i = (_e123 + 1f);
                }
            }
            let _e295 = border;
            if _e295 {
                break;
            }
            let _e296 = p_1;
            let _e297 = rect;
            let _e299 = rect;
            let _e301 = intensity_3;
            let _e302 = distort(_e296, _e297.xy, _e299.zw, _e301);
            p_1 = _e302;
        }
        continuing {
            let _e93 = j;
            j = (_e93 + 1i);
        }
    }
    let _e303 = uv_1;
    let _e307 = global.U[0];
    let _e310 = uv_1;
    let _e320 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e303.x / _e307.x), _e310.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e320;
    let _e323 = mode_1;
    if (_e323 >= 5i) {
        {
            let _e326 = rect;
            let _e328 = rect;
            let _e330 = rect;
            let _e332 = intensity_3;
            let _e333 = distort(_e326.xy, _e328.xy, _e330.zw, _e332);
            aa = _e333;
            let _e335 = rect;
            let _e337 = rect;
            let _e339 = rect;
            let _e341 = intensity_3;
            let _e342 = distort(_e335.zw, _e337.xy, _e339.zw, _e341);
            bb = _e342;
            let _e344 = aa;
            let _e345 = bb;
            rect = vec4<f32>(_e344.x, _e344.y, _e345.x, _e345.y);
        }
    }
    let _e351 = mode_1;
    let _e354 = mode_1;
    if ((_e351 == 0i) || (_e354 == 5i)) {
        {
            let _e358 = p_1;
            let _e360 = rect;
            let _e363 = rect;
            let _e365 = rect;
            k_4 = ((_e358.y - _e360.y) / (_e363.w - _e365.y));
            let _e370 = border;
            if _e370 {
                let _e371 = col;
                let _e373 = color_1;
                let _e375 = color_1;
                let _e378 = mix(_e371.xyz, _e373.xyz, vec3(_e375.w));
                let _e379 = col;
                local_1 = vec4<f32>(_e378.x, _e378.y, _e378.z, _e379.w);
            } else {
                let _e385 = rect;
                let _e387 = rect;
                let _e390 = rect;
                let _e392 = rect;
                if ((_e385.z - _e387.x) < (_e390.w - _e392.y)) {
                    let _e396 = p_1;
                    let _e398 = rect;
                    let _e404 = global.U[0];
                    let _e407 = p_1;
                    let _e409 = rect;
                    let _e421 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e396.x, _e398.y).x / _e404.x), vec2<f32>(_e407.x, _e409.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e422 = p_1;
                    let _e424 = rect;
                    let _e430 = global.U[0];
                    let _e433 = p_1;
                    let _e435 = rect;
                    let _e447 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e422.x, _e424.w).x / _e430.x), vec2<f32>(_e433.x, _e435.w).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e448 = k_4;
                    local = mix(_e421, _e447, vec4(_e448));
                } else {
                    let _e451 = rect;
                    let _e453 = p_1;
                    let _e459 = global.U[0];
                    let _e462 = rect;
                    let _e464 = p_1;
                    let _e476 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e451.x, _e453.y).x / _e459.x), vec2<f32>(_e462.x, _e464.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e477 = rect;
                    let _e479 = p_1;
                    let _e485 = global.U[0];
                    let _e488 = rect;
                    let _e490 = p_1;
                    let _e502 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e477.z, _e479.y).x / _e485.x), vec2<f32>(_e488.z, _e490.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e503 = k_4;
                    local = mix(_e476, _e502, vec4(_e503));
                }
                let _e507 = local;
                local_1 = _e507;
            }
            let _e509 = local_1;
            outCol = _e509;
        }
    } else {
        let _e510 = mode_1;
        let _e513 = mode_1;
        if ((_e510 == 1i) || (_e513 == 6i)) {
            {
                let _e517 = rect;
                let _e519 = rect;
                let _e522 = rect;
                let _e524 = rect;
                if ((_e517.z - _e519.x) < (_e522.w - _e524.y)) {
                    let _e528 = p_1;
                    let _e530 = rect;
                    let _e533 = rect;
                    let _e535 = rect;
                    local_2 = ((_e528.y - _e530.y) / (_e533.w - _e535.y));
                } else {
                    let _e539 = p_1;
                    let _e541 = rect;
                    let _e544 = rect;
                    let _e546 = rect;
                    local_2 = ((_e539.x - _e541.x) / (_e544.z - _e546.x));
                }
                let _e551 = local_2;
                k_5 = _e551;
                let _e553 = border;
                if _e553 {
                    let _e554 = col;
                    let _e556 = color_1;
                    let _e558 = color_1;
                    let _e561 = mix(_e554.xyz, _e556.xyz, vec3(_e558.w));
                    let _e562 = col;
                    local_4 = vec4<f32>(_e561.x, _e561.y, _e561.z, _e562.w);
                } else {
                    let _e568 = rect;
                    let _e570 = rect;
                    let _e573 = rect;
                    let _e575 = rect;
                    if ((_e568.z - _e570.x) < (_e573.w - _e575.y)) {
                        let _e579 = p_1;
                        let _e581 = rect;
                        let _e587 = global.U[0];
                        let _e590 = p_1;
                        let _e592 = rect;
                        let _e604 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e579.x, _e581.y).x / _e587.x), vec2<f32>(_e590.x, _e592.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e605 = p_1;
                        let _e607 = rect;
                        let _e613 = global.U[0];
                        let _e616 = p_1;
                        let _e618 = rect;
                        let _e630 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e605.x, _e607.w).x / _e613.x), vec2<f32>(_e616.x, _e618.w).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e631 = k_5;
                        local_3 = mix(_e604, _e630, vec4(_e631));
                    } else {
                        let _e634 = rect;
                        let _e636 = p_1;
                        let _e642 = global.U[0];
                        let _e645 = rect;
                        let _e647 = p_1;
                        let _e659 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e634.x, _e636.y).x / _e642.x), vec2<f32>(_e645.x, _e647.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e660 = rect;
                        let _e662 = p_1;
                        let _e668 = global.U[0];
                        let _e671 = rect;
                        let _e673 = p_1;
                        let _e685 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e660.z, _e662.y).x / _e668.x), vec2<f32>(_e671.z, _e673.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e686 = k_5;
                        local_3 = mix(_e659, _e685, vec4(_e686));
                    }
                    let _e690 = local_3;
                    local_4 = _e690;
                }
                let _e692 = local_4;
                outCol = _e692;
            }
        } else {
            let _e693 = mode_1;
            let _e696 = mode_1;
            if ((_e693 == 2i) || (_e696 == 7i)) {
                {
                    let _e700 = p_1;
                    let _e702 = rect;
                    let _e705 = rect;
                    let _e707 = rect;
                    k_6 = ((_e700.y - _e702.y) / (_e705.w - _e707.y));
                    let _e712 = border;
                    if _e712 {
                        let _e713 = col;
                        let _e715 = color_1;
                        let _e717 = color_1;
                        let _e720 = mix(_e713.xyz, _e715.xyz, vec3(_e717.w));
                        let _e721 = col;
                        local_5 = vec4<f32>(_e720.x, _e720.y, _e720.z, _e721.w);
                    } else {
                        let _e727 = p_1;
                        let _e729 = rect;
                        let _e735 = global.U[0];
                        let _e738 = p_1;
                        let _e740 = rect;
                        let _e752 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e727.x, _e729.y).x / _e735.x), vec2<f32>(_e738.x, _e740.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e753 = p_1;
                        let _e755 = rect;
                        let _e761 = global.U[0];
                        let _e764 = p_1;
                        let _e766 = rect;
                        let _e778 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e753.x, _e755.w).x / _e761.x), vec2<f32>(_e764.x, _e766.w).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e779 = k_6;
                        local_5 = mix(_e752, _e778, vec4(_e779));
                    }
                    let _e783 = local_5;
                    outCol = _e783;
                }
            } else {
                let _e784 = mode_1;
                let _e787 = mode_1;
                if ((_e784 == 3i) || (_e787 == 8i)) {
                    {
                        let _e791 = p_1;
                        let _e793 = rect;
                        let _e796 = rect;
                        let _e798 = rect;
                        k_7 = ((_e791.x - _e793.x) / (_e796.z - _e798.x));
                        let _e803 = border;
                        if _e803 {
                            let _e804 = col;
                            let _e806 = color_1;
                            let _e808 = color_1;
                            let _e811 = mix(_e804.xyz, _e806.xyz, vec3(_e808.w));
                            let _e812 = col;
                            local_6 = vec4<f32>(_e811.x, _e811.y, _e811.z, _e812.w);
                        } else {
                            let _e818 = rect;
                            let _e820 = p_1;
                            let _e826 = global.U[0];
                            let _e829 = rect;
                            let _e831 = p_1;
                            let _e843 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e818.x, _e820.y).x / _e826.x), vec2<f32>(_e829.x, _e831.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e844 = rect;
                            let _e846 = p_1;
                            let _e852 = global.U[0];
                            let _e855 = rect;
                            let _e857 = p_1;
                            let _e869 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e844.z, _e846.y).x / _e852.x), vec2<f32>(_e855.z, _e857.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e870 = k_7;
                            local_6 = mix(_e843, _e869, vec4(_e870));
                        }
                        let _e874 = local_6;
                        outCol = _e874;
                    }
                } else {
                    let _e875 = mode_1;
                    let _e878 = mode_1;
                    if ((_e875 == 4i) || (_e878 == 9i)) {
                        {
                            let _e882 = rect;
                            let _e884 = rect;
                            let _e887 = rect;
                            let _e889 = rect;
                            if ((_e882.z - _e884.x) < (_e887.w - _e889.y)) {
                                let _e893 = p_1;
                                let _e895 = rect;
                                let _e898 = rect;
                                let _e900 = rect;
                                local_7 = ((_e893.y - _e895.y) / (_e898.w - _e900.y));
                            } else {
                                let _e904 = p_1;
                                let _e906 = rect;
                                let _e909 = rect;
                                let _e911 = rect;
                                local_7 = ((_e904.x - _e906.x) / (_e909.z - _e911.x));
                            }
                            let _e916 = local_7;
                            k_8 = _e916;
                            let _e918 = border;
                            if _e918 {
                                let _e919 = col;
                                let _e921 = color_1;
                                let _e923 = color_1;
                                let _e926 = mix(_e919.xyz, _e921.xyz, vec3(_e923.w));
                                let _e927 = col;
                                local_9 = vec4<f32>(_e926.x, _e926.y, _e926.z, _e927.w);
                            } else {
                                let _e933 = rect;
                                let _e935 = rect;
                                let _e938 = rect;
                                let _e940 = rect;
                                if ((_e933.z - _e935.x) < (_e938.w - _e940.y)) {
                                    let _e944 = p_1;
                                    let _e946 = rect;
                                    let _e952 = global.U[0];
                                    let _e955 = p_1;
                                    let _e957 = rect;
                                    let _e969 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e944.x, _e946.y).x / _e952.x), vec2<f32>(_e955.x, _e957.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e970 = p_1;
                                    let _e972 = rect;
                                    let _e978 = global.U[0];
                                    let _e981 = p_1;
                                    let _e983 = rect;
                                    let _e995 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e970.x, _e972.w).x / _e978.x), vec2<f32>(_e981.x, _e983.w).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e996 = k_8;
                                    local_8 = mix(_e969, _e995, vec4(_e996));
                                } else {
                                    let _e999 = rect;
                                    let _e1001 = p_1;
                                    let _e1007 = global.U[0];
                                    let _e1010 = rect;
                                    let _e1012 = p_1;
                                    let _e1024 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e999.x, _e1001.y).x / _e1007.x), vec2<f32>(_e1010.x, _e1012.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e1025 = rect;
                                    let _e1027 = p_1;
                                    let _e1033 = global.U[0];
                                    let _e1036 = rect;
                                    let _e1038 = p_1;
                                    let _e1050 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1025.z, _e1027.y).x / _e1033.x), vec2<f32>(_e1036.z, _e1038.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e1051 = k_8;
                                    local_8 = mix(_e1024, _e1050, vec4(_e1051));
                                }
                                let _e1055 = local_8;
                                local_9 = _e1055;
                            }
                            let _e1057 = local_9;
                            outCol = _e1057;
                        }
                    } else {
                        {
                            let _e1058 = p_1;
                            let _e1060 = rect;
                            let _e1063 = rect;
                            let _e1065 = rect;
                            kx = ((_e1058.x - _e1060.x) / (_e1063.z - _e1065.x));
                            let _e1070 = p_1;
                            let _e1072 = rect;
                            let _e1075 = rect;
                            let _e1077 = rect;
                            ky = ((_e1070.y - _e1072.y) / (_e1075.w - _e1077.y));
                            let _e1082 = border;
                            if _e1082 {
                                let _e1083 = col;
                                let _e1085 = color_1;
                                let _e1087 = color_1;
                                let _e1090 = mix(_e1083.xyz, _e1085.xyz, vec3(_e1087.w));
                                let _e1091 = col;
                                local_10 = vec4<f32>(_e1090.x, _e1090.y, _e1090.z, _e1091.w);
                            } else {
                                let _e1097 = rect;
                                let _e1102 = global.U[0];
                                let _e1105 = rect;
                                let _e1116 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1097.x / _e1102.x), _e1105.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1117 = rect;
                                let _e1122 = global.U[0];
                                let _e1125 = rect;
                                let _e1136 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1117.x / _e1122.x), _e1125.w) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1138 = ky;
                                let _e1142 = rect;
                                let _e1147 = global.U[0];
                                let _e1150 = rect;
                                let _e1161 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1142.z / _e1147.x), _e1150.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1162 = rect;
                                let _e1167 = global.U[0];
                                let _e1170 = rect;
                                let _e1181 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1162.z / _e1167.x), _e1170.w) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1183 = ky;
                                let _e1188 = kx;
                                local_10 = mix(mix(_e1116, _e1136, vec4((1f - _e1138))), mix(_e1161, _e1181, vec4((1f - _e1183))), vec4((1f - _e1188)));
                            }
                            let _e1193 = local_10;
                            outCol = _e1193;
                        }
                    }
                }
            }
        }
    }
    let _e1194 = outCol;
    return _e1194;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e94 = global.U[12];
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e122 = dichotomicStreak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, i32(_e74.x), _e79.x, _e83.x, _e87, _e90.x, i32(_e94.x), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
    fragColor = _e122;
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
