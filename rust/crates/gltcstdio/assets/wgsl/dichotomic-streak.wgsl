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
    let _e319 = textureSample(t_source, samp, ((vec2<f32>((_e303.x / _e307.x), _e310.y) / vec2(2f)) + vec2(0.5f)));
    col = _e319;
    let _e322 = mode_1;
    if (_e322 >= 5i) {
        {
            let _e325 = rect;
            let _e327 = rect;
            let _e329 = rect;
            let _e331 = intensity_3;
            let _e332 = distort(_e325.xy, _e327.xy, _e329.zw, _e331);
            aa = _e332;
            let _e334 = rect;
            let _e336 = rect;
            let _e338 = rect;
            let _e340 = intensity_3;
            let _e341 = distort(_e334.zw, _e336.xy, _e338.zw, _e340);
            bb = _e341;
            let _e343 = aa;
            let _e344 = bb;
            rect = vec4<f32>(_e343.x, _e343.y, _e344.x, _e344.y);
        }
    }
    let _e350 = mode_1;
    let _e353 = mode_1;
    if ((_e350 == 0i) || (_e353 == 5i)) {
        {
            let _e357 = p_1;
            let _e359 = rect;
            let _e362 = rect;
            let _e364 = rect;
            k_4 = ((_e357.y - _e359.y) / (_e362.w - _e364.y));
            let _e369 = border;
            if _e369 {
                let _e370 = col;
                let _e372 = color_1;
                let _e374 = color_1;
                let _e377 = mix(_e370.xyz, _e372.xyz, vec3(_e374.w));
                let _e378 = col;
                local_1 = vec4<f32>(_e377.x, _e377.y, _e377.z, _e378.w);
            } else {
                let _e384 = rect;
                let _e386 = rect;
                let _e389 = rect;
                let _e391 = rect;
                if ((_e384.z - _e386.x) < (_e389.w - _e391.y)) {
                    let _e395 = p_1;
                    let _e397 = rect;
                    let _e403 = global.U[0];
                    let _e406 = p_1;
                    let _e408 = rect;
                    let _e419 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e395.x, _e397.y).x / _e403.x), vec2<f32>(_e406.x, _e408.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e420 = p_1;
                    let _e422 = rect;
                    let _e428 = global.U[0];
                    let _e431 = p_1;
                    let _e433 = rect;
                    let _e444 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e420.x, _e422.w).x / _e428.x), vec2<f32>(_e431.x, _e433.w).y) / vec2(2f)) + vec2(0.5f)));
                    let _e445 = k_4;
                    local = mix(_e419, _e444, vec4(_e445));
                } else {
                    let _e448 = rect;
                    let _e450 = p_1;
                    let _e456 = global.U[0];
                    let _e459 = rect;
                    let _e461 = p_1;
                    let _e472 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e448.x, _e450.y).x / _e456.x), vec2<f32>(_e459.x, _e461.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e473 = rect;
                    let _e475 = p_1;
                    let _e481 = global.U[0];
                    let _e484 = rect;
                    let _e486 = p_1;
                    let _e497 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e473.z, _e475.y).x / _e481.x), vec2<f32>(_e484.z, _e486.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e498 = k_4;
                    local = mix(_e472, _e497, vec4(_e498));
                }
                let _e502 = local;
                local_1 = _e502;
            }
            let _e504 = local_1;
            outCol = _e504;
        }
    } else {
        let _e505 = mode_1;
        let _e508 = mode_1;
        if ((_e505 == 1i) || (_e508 == 6i)) {
            {
                let _e512 = rect;
                let _e514 = rect;
                let _e517 = rect;
                let _e519 = rect;
                if ((_e512.z - _e514.x) < (_e517.w - _e519.y)) {
                    let _e523 = p_1;
                    let _e525 = rect;
                    let _e528 = rect;
                    let _e530 = rect;
                    local_2 = ((_e523.y - _e525.y) / (_e528.w - _e530.y));
                } else {
                    let _e534 = p_1;
                    let _e536 = rect;
                    let _e539 = rect;
                    let _e541 = rect;
                    local_2 = ((_e534.x - _e536.x) / (_e539.z - _e541.x));
                }
                let _e546 = local_2;
                k_5 = _e546;
                let _e548 = border;
                if _e548 {
                    let _e549 = col;
                    let _e551 = color_1;
                    let _e553 = color_1;
                    let _e556 = mix(_e549.xyz, _e551.xyz, vec3(_e553.w));
                    let _e557 = col;
                    local_4 = vec4<f32>(_e556.x, _e556.y, _e556.z, _e557.w);
                } else {
                    let _e563 = rect;
                    let _e565 = rect;
                    let _e568 = rect;
                    let _e570 = rect;
                    if ((_e563.z - _e565.x) < (_e568.w - _e570.y)) {
                        let _e574 = p_1;
                        let _e576 = rect;
                        let _e582 = global.U[0];
                        let _e585 = p_1;
                        let _e587 = rect;
                        let _e598 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e574.x, _e576.y).x / _e582.x), vec2<f32>(_e585.x, _e587.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e599 = p_1;
                        let _e601 = rect;
                        let _e607 = global.U[0];
                        let _e610 = p_1;
                        let _e612 = rect;
                        let _e623 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e599.x, _e601.w).x / _e607.x), vec2<f32>(_e610.x, _e612.w).y) / vec2(2f)) + vec2(0.5f)));
                        let _e624 = k_5;
                        local_3 = mix(_e598, _e623, vec4(_e624));
                    } else {
                        let _e627 = rect;
                        let _e629 = p_1;
                        let _e635 = global.U[0];
                        let _e638 = rect;
                        let _e640 = p_1;
                        let _e651 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e627.x, _e629.y).x / _e635.x), vec2<f32>(_e638.x, _e640.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e652 = rect;
                        let _e654 = p_1;
                        let _e660 = global.U[0];
                        let _e663 = rect;
                        let _e665 = p_1;
                        let _e676 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e652.z, _e654.y).x / _e660.x), vec2<f32>(_e663.z, _e665.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e677 = k_5;
                        local_3 = mix(_e651, _e676, vec4(_e677));
                    }
                    let _e681 = local_3;
                    local_4 = _e681;
                }
                let _e683 = local_4;
                outCol = _e683;
            }
        } else {
            let _e684 = mode_1;
            let _e687 = mode_1;
            if ((_e684 == 2i) || (_e687 == 7i)) {
                {
                    let _e691 = p_1;
                    let _e693 = rect;
                    let _e696 = rect;
                    let _e698 = rect;
                    k_6 = ((_e691.y - _e693.y) / (_e696.w - _e698.y));
                    let _e703 = border;
                    if _e703 {
                        let _e704 = col;
                        let _e706 = color_1;
                        let _e708 = color_1;
                        let _e711 = mix(_e704.xyz, _e706.xyz, vec3(_e708.w));
                        let _e712 = col;
                        local_5 = vec4<f32>(_e711.x, _e711.y, _e711.z, _e712.w);
                    } else {
                        let _e718 = p_1;
                        let _e720 = rect;
                        let _e726 = global.U[0];
                        let _e729 = p_1;
                        let _e731 = rect;
                        let _e742 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e718.x, _e720.y).x / _e726.x), vec2<f32>(_e729.x, _e731.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e743 = p_1;
                        let _e745 = rect;
                        let _e751 = global.U[0];
                        let _e754 = p_1;
                        let _e756 = rect;
                        let _e767 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e743.x, _e745.w).x / _e751.x), vec2<f32>(_e754.x, _e756.w).y) / vec2(2f)) + vec2(0.5f)));
                        let _e768 = k_6;
                        local_5 = mix(_e742, _e767, vec4(_e768));
                    }
                    let _e772 = local_5;
                    outCol = _e772;
                }
            } else {
                let _e773 = mode_1;
                let _e776 = mode_1;
                if ((_e773 == 3i) || (_e776 == 8i)) {
                    {
                        let _e780 = p_1;
                        let _e782 = rect;
                        let _e785 = rect;
                        let _e787 = rect;
                        k_7 = ((_e780.x - _e782.x) / (_e785.z - _e787.x));
                        let _e792 = border;
                        if _e792 {
                            let _e793 = col;
                            let _e795 = color_1;
                            let _e797 = color_1;
                            let _e800 = mix(_e793.xyz, _e795.xyz, vec3(_e797.w));
                            let _e801 = col;
                            local_6 = vec4<f32>(_e800.x, _e800.y, _e800.z, _e801.w);
                        } else {
                            let _e807 = rect;
                            let _e809 = p_1;
                            let _e815 = global.U[0];
                            let _e818 = rect;
                            let _e820 = p_1;
                            let _e831 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e807.x, _e809.y).x / _e815.x), vec2<f32>(_e818.x, _e820.y).y) / vec2(2f)) + vec2(0.5f)));
                            let _e832 = rect;
                            let _e834 = p_1;
                            let _e840 = global.U[0];
                            let _e843 = rect;
                            let _e845 = p_1;
                            let _e856 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e832.z, _e834.y).x / _e840.x), vec2<f32>(_e843.z, _e845.y).y) / vec2(2f)) + vec2(0.5f)));
                            let _e857 = k_7;
                            local_6 = mix(_e831, _e856, vec4(_e857));
                        }
                        let _e861 = local_6;
                        outCol = _e861;
                    }
                } else {
                    let _e862 = mode_1;
                    let _e865 = mode_1;
                    if ((_e862 == 4i) || (_e865 == 9i)) {
                        {
                            let _e869 = rect;
                            let _e871 = rect;
                            let _e874 = rect;
                            let _e876 = rect;
                            if ((_e869.z - _e871.x) < (_e874.w - _e876.y)) {
                                let _e880 = p_1;
                                let _e882 = rect;
                                let _e885 = rect;
                                let _e887 = rect;
                                local_7 = ((_e880.y - _e882.y) / (_e885.w - _e887.y));
                            } else {
                                let _e891 = p_1;
                                let _e893 = rect;
                                let _e896 = rect;
                                let _e898 = rect;
                                local_7 = ((_e891.x - _e893.x) / (_e896.z - _e898.x));
                            }
                            let _e903 = local_7;
                            k_8 = _e903;
                            let _e905 = border;
                            if _e905 {
                                let _e906 = col;
                                let _e908 = color_1;
                                let _e910 = color_1;
                                let _e913 = mix(_e906.xyz, _e908.xyz, vec3(_e910.w));
                                let _e914 = col;
                                local_9 = vec4<f32>(_e913.x, _e913.y, _e913.z, _e914.w);
                            } else {
                                let _e920 = rect;
                                let _e922 = rect;
                                let _e925 = rect;
                                let _e927 = rect;
                                if ((_e920.z - _e922.x) < (_e925.w - _e927.y)) {
                                    let _e931 = p_1;
                                    let _e933 = rect;
                                    let _e939 = global.U[0];
                                    let _e942 = p_1;
                                    let _e944 = rect;
                                    let _e955 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e931.x, _e933.y).x / _e939.x), vec2<f32>(_e942.x, _e944.y).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e956 = p_1;
                                    let _e958 = rect;
                                    let _e964 = global.U[0];
                                    let _e967 = p_1;
                                    let _e969 = rect;
                                    let _e980 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e956.x, _e958.w).x / _e964.x), vec2<f32>(_e967.x, _e969.w).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e981 = k_8;
                                    local_8 = mix(_e955, _e980, vec4(_e981));
                                } else {
                                    let _e984 = rect;
                                    let _e986 = p_1;
                                    let _e992 = global.U[0];
                                    let _e995 = rect;
                                    let _e997 = p_1;
                                    let _e1008 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e984.x, _e986.y).x / _e992.x), vec2<f32>(_e995.x, _e997.y).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1009 = rect;
                                    let _e1011 = p_1;
                                    let _e1017 = global.U[0];
                                    let _e1020 = rect;
                                    let _e1022 = p_1;
                                    let _e1033 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1009.z, _e1011.y).x / _e1017.x), vec2<f32>(_e1020.z, _e1022.y).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e1034 = k_8;
                                    local_8 = mix(_e1008, _e1033, vec4(_e1034));
                                }
                                let _e1038 = local_8;
                                local_9 = _e1038;
                            }
                            let _e1040 = local_9;
                            outCol = _e1040;
                        }
                    } else {
                        {
                            let _e1041 = p_1;
                            let _e1043 = rect;
                            let _e1046 = rect;
                            let _e1048 = rect;
                            kx = ((_e1041.x - _e1043.x) / (_e1046.z - _e1048.x));
                            let _e1053 = p_1;
                            let _e1055 = rect;
                            let _e1058 = rect;
                            let _e1060 = rect;
                            ky = ((_e1053.y - _e1055.y) / (_e1058.w - _e1060.y));
                            let _e1065 = border;
                            if _e1065 {
                                let _e1066 = col;
                                let _e1068 = color_1;
                                let _e1070 = color_1;
                                let _e1073 = mix(_e1066.xyz, _e1068.xyz, vec3(_e1070.w));
                                let _e1074 = col;
                                local_10 = vec4<f32>(_e1073.x, _e1073.y, _e1073.z, _e1074.w);
                            } else {
                                let _e1080 = rect;
                                let _e1085 = global.U[0];
                                let _e1088 = rect;
                                let _e1098 = textureSample(t_source, samp, ((vec2<f32>((_e1080.x / _e1085.x), _e1088.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1099 = rect;
                                let _e1104 = global.U[0];
                                let _e1107 = rect;
                                let _e1117 = textureSample(t_source, samp, ((vec2<f32>((_e1099.x / _e1104.x), _e1107.w) / vec2(2f)) + vec2(0.5f)));
                                let _e1119 = ky;
                                let _e1123 = rect;
                                let _e1128 = global.U[0];
                                let _e1131 = rect;
                                let _e1141 = textureSample(t_source, samp, ((vec2<f32>((_e1123.z / _e1128.x), _e1131.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1142 = rect;
                                let _e1147 = global.U[0];
                                let _e1150 = rect;
                                let _e1160 = textureSample(t_source, samp, ((vec2<f32>((_e1142.z / _e1147.x), _e1150.w) / vec2(2f)) + vec2(0.5f)));
                                let _e1162 = ky;
                                let _e1167 = kx;
                                local_10 = mix(mix(_e1098, _e1117, vec4((1f - _e1119))), mix(_e1141, _e1160, vec4((1f - _e1162))), vec4((1f - _e1167)));
                            }
                            let _e1172 = local_10;
                            outCol = _e1172;
                        }
                    }
                }
            }
        }
    }
    let _e1173 = outCol;
    return _e1173;
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
