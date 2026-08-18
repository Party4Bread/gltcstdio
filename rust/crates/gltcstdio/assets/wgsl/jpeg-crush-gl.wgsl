struct Params {
    U: array<vec4<f32>, 14>,
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

fn jpegBlockHash3_(b: vec2<f32>) -> vec3<f32> {
    var b_1: vec2<f32>;

    b_1 = b;
    let _e8 = b_1;
    let _e13 = b_1;
    let _e18 = b_1;
    return fract((sin(vec3<f32>(dot(_e8, vec2<f32>(127.1f, 311.7f)), dot(_e13, vec2<f32>(269.5f, 183.3f)), dot(_e18, vec2<f32>(419.2f, 371.9f)))) * 43758.547f));
}

fn jpegHash4_(b_2: vec2<f32>) -> vec4<f32> {
    var b_3: vec2<f32>;

    b_3 = b_2;
    let _e8 = b_3;
    let _e13 = b_3;
    let _e18 = b_3;
    let _e23 = b_3;
    return fract((sin(vec4<f32>(dot(_e8, vec2<f32>(127.1f, 311.7f)), dot(_e13, vec2<f32>(269.5f, 183.3f)), dot(_e18, vec2<f32>(419.2f, 371.9f)), dot(_e23, vec2<f32>(523.7f, 283.3f)))) * 43758.547f));
}

fn jpegRgb2ycc(c: vec3<f32>) -> vec3<f32> {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e8 = c_1;
    let _e14 = c_1;
    let _e22 = c_1;
    return vec3<f32>(dot(_e8, vec3<f32>(0.299f, 0.587f, 0.114f)), dot(_e14, vec3<f32>(-0.168736f, -0.331264f, 0.5f)), dot(_e22, vec3<f32>(0.5f, -0.418688f, -0.081312f)));
}

fn jpegYcc2rgb(y: vec3<f32>) -> vec3<f32> {
    var y_1: vec3<f32>;

    y_1 = y;
    let _e8 = y_1;
    let _e11 = y_1;
    let _e15 = y_1;
    let _e18 = y_1;
    let _e23 = y_1;
    let _e27 = y_1;
    let _e30 = y_1;
    return vec3<f32>((_e8.x + (1.402f * _e11.z)), ((_e15.x - (0.344136f * _e18.y)) - (0.714136f * _e23.z)), (_e27.x + (1.772f * _e30.y)));
}

fn jpegCrushGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, chroma: f32, ringing: f32, balance: f32, variability: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var chroma_1: f32;
    var ringing_1: f32;
    var balance_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inCol: vec4<f32>;
    var N: i32 = 8i;
    var im: mat3x3<f32>;
    var res: f32;
    var blockUV: f32;
    var L: vec2<f32>;
    var cbidx: vec2<f32>;
    var lc: vec2<f32>;
    var keep: i32;
    var quant: f32;
    var keepC: i32;
    var quantC: f32;
    var chromaMix: f32;
    var aN0_: f32;
    var aNk: f32;
    var PI2N: f32;
    var result: vec3<f32> = vec3(0f);
    var u: i32 = 0i;
    var local: f32;
    var au: f32;
    var v: i32;
    var local_1: f32;
    var av: f32;
    var F: vec3<f32>;
    var x: i32;
    var bx: f32;
    var y_2: i32;
    var s: vec2<f32>;
    var f: vec3<f32>;
    var Frgb: vec3<f32>;
    var ycc: vec3<f32>;
    var acw: f32;
    var gc: vec2<f32>;
    var s_1: f32;
    var w: vec4<f32> = vec4(1f);
    var local_2: vec2<f32>;
    var kA: vec2<f32>;
    var local_3: vec2<f32>;
    var kB: vec2<f32>;
    var type_44: i32 = 0i;
    var best: f32;
    var density: f32;
    var g: f32;
    var tint: vec3<f32>;
    var disp: vec2<f32>;
    var src: vec3<f32>;
    var U: vec3<f32>;
    var V: vec3<f32>;
    var dc: vec3<f32>;
    var amp: vec3<f32>;
    var disp_1: vec2<f32>;
    var outCol: vec4<f32>;
    var bal: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    chroma_1 = chroma;
    ringing_1 = ringing;
    balance_1 = balance;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e24 = pos_1;
    let _e28 = global.U[0];
    let _e31 = pos_1;
    let _e40 = textureSample(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e31.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e40;
    let _e44 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e44);
    let _e50 = im[0];
    res = max(1f, length(_e50.xy));
    let _e56 = res;
    blockUV = (1f / _e56);
    let _e59 = im;
    let _e60 = pos_1;
    L = (_e59 * vec3<f32>(_e60.x, _e60.y, 1f)).xy;
    let _e68 = L;
    cbidx = floor(_e68);
    let _e71 = L;
    let _e73 = N;
    let _e78 = N;
    lc = clamp(floor((fract(_e71) * f32(_e73))), vec2(0f), vec2((f32(_e78) - 1f)));
    let _e87 = intensity_1;
    keep = i32(clamp((6f - (_e87 * 5f)), 1f, 6f));
    let _e97 = intensity_1;
    quant = (0.02f + (_e97 * 0.6f));
    let _e102 = keep;
    let _e104 = chroma_1;
    keepC = i32(clamp((f32(_e102) - (_e104 * 4f)), 1f, 6f));
    let _e113 = quant;
    let _e115 = chroma_1;
    quantC = (_e113 * (1f + (_e115 * 8f)));
    let _e121 = chroma_1;
    chromaMix = clamp(_e121, 0f, 1f);
    let _e127 = N;
    aN0_ = sqrt((1f / f32(_e127)));
    let _e133 = N;
    aNk = sqrt((2f / f32(_e133)));
    let _e140 = N;
    PI2N = (3.1415927f / (2f * f32(_e140)));
    loop {
        let _e150 = u;
        if !((_e150 < 8i)) {
            break;
        }
        {
            let _e157 = u;
            let _e158 = keep;
            if (_e157 >= _e158) {
                break;
            }
            let _e160 = u;
            if (_e160 == 0i) {
                let _e163 = aN0_;
                local = _e163;
            } else {
                let _e164 = aNk;
                local = _e164;
            }
            let _e166 = local;
            au = _e166;
            v = 0i;
            loop {
                let _e170 = v;
                if !((_e170 < 8i)) {
                    break;
                }
                {
                    let _e177 = v;
                    let _e178 = keep;
                    if (_e177 >= _e178) {
                        break;
                    }
                    let _e180 = v;
                    if (_e180 == 0i) {
                        let _e183 = aN0_;
                        local_1 = _e183;
                    } else {
                        let _e184 = aNk;
                        local_1 = _e184;
                    }
                    let _e186 = local_1;
                    av = _e186;
                    F = vec3(0f);
                    x = 0i;
                    loop {
                        let _e193 = x;
                        if !((_e193 < 8i)) {
                            break;
                        }
                        {
                            let _e201 = x;
                            let _e206 = u;
                            let _e209 = PI2N;
                            bx = cos(((((2f * f32(_e201)) + 1f) * f32(_e206)) * _e209));
                            y_2 = 0i;
                            loop {
                                let _e215 = y_2;
                                if !((_e215 < 8i)) {
                                    break;
                                }
                                {
                                    let _e222 = modelTransform_1;
                                    let _e223 = cbidx;
                                    let _e224 = x;
                                    let _e226 = y_2;
                                    let _e232 = N;
                                    let _e236 = (_e223 + ((vec2<f32>(f32(_e224), f32(_e226)) + vec2(0.5f)) / vec2(f32(_e232))));
                                    s = (_e222 * vec3<f32>(_e236.x, _e236.y, 1f)).xy;
                                    let _e244 = s;
                                    let _e248 = global.U[0];
                                    let _e251 = s;
                                    let _e260 = textureSample(t_source, samp, ((vec2<f32>((_e244.x / _e248.x), _e251.y) / vec2(2f)) + vec2(0.5f)));
                                    f = _e260.xyz;
                                    let _e263 = F;
                                    let _e264 = f;
                                    let _e265 = bx;
                                    let _e268 = y_2;
                                    let _e273 = v;
                                    let _e276 = PI2N;
                                    F = (_e263 + ((_e264 * _e265) * cos(((((2f * f32(_e268)) + 1f) * f32(_e273)) * _e276))));
                                }
                                continuing {
                                    let _e219 = y_2;
                                    y_2 = (_e219 + 1i);
                                }
                            }
                        }
                        continuing {
                            let _e197 = x;
                            x = (_e197 + 1i);
                        }
                    }
                    let _e281 = F;
                    let _e282 = au;
                    let _e283 = av;
                    F = (_e281 * (_e282 * _e283));
                    let _e286 = F;
                    let _e287 = quant;
                    let _e294 = quant;
                    Frgb = (floor(((_e286 / vec3(_e287)) + vec3(0.5f))) * _e294);
                    let _e297 = chroma_1;
                    if (_e297 > 0f) {
                        {
                            let _e300 = F;
                            let _e301 = jpegRgb2ycc(_e300);
                            ycc = _e301;
                            let _e304 = ycc;
                            let _e306 = quant;
                            let _e311 = quant;
                            ycc.x = (floor(((_e304.x / _e306) + 0.5f)) * _e311);
                            let _e313 = ycc;
                            let _e315 = ycc;
                            let _e317 = quantC;
                            let _e324 = quantC;
                            let _e325 = (floor(((_e315.yz / vec2(_e317)) + vec2(0.5f))) * _e324);
                            ycc.y = _e325.x;
                            ycc.z = _e325.y;
                            let _e330 = u;
                            let _e331 = keepC;
                            let _e333 = v;
                            let _e334 = keepC;
                            if ((_e330 >= _e331) || (_e333 >= _e334)) {
                                let _e337 = ycc;
                                ycc.y = 0f;
                                ycc.z = 0f;
                            }
                            let _e343 = Frgb;
                            let _e344 = ycc;
                            let _e345 = jpegYcc2rgb(_e344);
                            let _e346 = chromaMix;
                            F = mix(_e343, _e345, vec3(_e346));
                        }
                    } else {
                        {
                            let _e349 = Frgb;
                            F = _e349;
                        }
                    }
                    let _e350 = u;
                    let _e351 = v;
                    acw = f32((_e350 + _e351));
                    let _e355 = ringing_1;
                    let _e358 = acw;
                    if ((_e355 > 0f) && (_e358 > 0f)) {
                        let _e362 = F;
                        let _e364 = ringing_1;
                        let _e367 = acw;
                        F = (_e362 * (1f + ((_e364 * 0.3f) * _e367)));
                    }
                    let _e371 = result;
                    let _e372 = au;
                    let _e373 = av;
                    let _e375 = F;
                    let _e378 = lc;
                    let _e383 = u;
                    let _e386 = PI2N;
                    let _e391 = lc;
                    let _e396 = v;
                    let _e399 = PI2N;
                    result = (_e371 + ((((_e372 * _e373) * _e375) * cos(((((2f * _e378.x) + 1f) * f32(_e383)) * _e386))) * cos(((((2f * _e391.y) + 1f) * f32(_e396)) * _e399))));
                }
                continuing {
                    let _e174 = v;
                    v = (_e174 + 1i);
                }
            }
        }
        continuing {
            let _e154 = u;
            u = (_e154 + 1i);
        }
    }
    let _e404 = variability_1;
    if (abs(_e404) > 0f) {
        {
            let _e408 = cbidx;
            gc = (_e408 + vec2(0.5f));
            let _e413 = randomSeed_1;
            s_1 = _e413;
            let _e418 = w;
            let _e419 = gc;
            let _e427 = s_1;
            let _e431 = jpegHash4_(floor((((_e419 * vec2<f32>(0.043f, 0.052f)) + vec2(11.3f)) + vec2(_e427))));
            w = (_e418 * _e431);
            let _e433 = w;
            let _e434 = gc;
            let _e442 = s_1;
            let _e448 = jpegHash4_(floor((((_e434 * vec2<f32>(0.075f, 0.091f)) + vec2(53.1f)) + vec2((_e442 * 2.1f)))));
            w = (_e433 * _e448);
            let _e450 = w;
            let _e451 = gc;
            let _e459 = s_1;
            let _e465 = jpegHash4_(floor((((_e451 * vec2<f32>(0.244f, 0.27f)) + vec2(17.5f)) + vec2((_e459 * 2.9f)))));
            w = (_e450 * _e465);
            let _e467 = variability_1;
            if (_e467 >= 0f) {
                local_2 = vec2<f32>(0.037f, 0.213f);
            } else {
                local_2 = vec2<f32>(0.213f, 0.037f);
            }
            let _e477 = local_2;
            kA = _e477;
            let _e479 = variability_1;
            if (_e479 >= 0f) {
                local_3 = vec2<f32>(0.024f, 0.131f);
            } else {
                local_3 = vec2<f32>(0.131f, 0.024f);
            }
            let _e489 = local_3;
            kB = _e489;
            let _e491 = w;
            let _e492 = gc;
            let _e493 = kA;
            let _e498 = s_1;
            let _e504 = jpegHash4_(floor((((_e492 * _e493) + vec2(31.7f)) + vec2((_e498 * 1.3f)))));
            w = (_e491 * pow(_e504, vec4(2.5f)));
            let _e509 = w;
            let _e510 = gc;
            let _e511 = kB;
            let _e516 = s_1;
            let _e522 = jpegHash4_(floor((((_e510 * _e511) + vec2(7.9f)) + vec2((_e516 * 1.7f)))));
            w = (_e509 * pow(_e522, vec4(1.6f)));
            let _e529 = w;
            best = _e529.x;
            let _e532 = w;
            let _e534 = best;
            if (_e532.y > _e534) {
                {
                    let _e536 = w;
                    best = _e536.y;
                    type_44 = 1i;
                }
            }
            let _e539 = w;
            let _e541 = best;
            if (_e539.z > _e541) {
                {
                    let _e543 = w;
                    best = _e543.z;
                    type_44 = 2i;
                }
            }
            let _e546 = w;
            let _e548 = best;
            if (_e546.w > _e548) {
                {
                    let _e550 = w;
                    best = _e550.w;
                    type_44 = 3i;
                }
            }
            let _e553 = variability_1;
            density = clamp(abs(_e553), 0f, 1f);
            let _e559 = best;
            g = pow(_e559, 0.14f);
            let _e563 = g;
            let _e566 = density;
            if (_e563 > mix(1.02f, 0.25f, pow(_e566, 1.3f))) {
                {
                    let _e571 = type_44;
                    if (_e571 == 0i) {
                        {
                            let _e574 = cbidx;
                            let _e580 = s_1;
                            let _e584 = jpegBlockHash3_((floor((_e574 * vec2<f32>(0.1f, 0.35f))) + vec2<f32>(_e580, 5f)));
                            tint = _e584;
                            let _e586 = cbidx;
                            let _e587 = s_1;
                            let _e591 = jpegBlockHash3_((_e586 + vec2<f32>(_e587, 91f)));
                            let _e596 = blockUV;
                            disp = (((_e591.xy - vec2(0.5f)) * _e596) * 6f);
                            let _e601 = pos_1;
                            let _e602 = disp;
                            let _e607 = global.U[0];
                            let _e610 = pos_1;
                            let _e611 = disp;
                            let _e621 = textureSample(t_source, samp, ((vec2<f32>(((_e601 + _e602).x / _e607.x), (_e610 + _e611).y) / vec2(2f)) + vec2(0.5f)));
                            src = _e621.xyz;
                            let _e624 = src;
                            let _e625 = tint;
                            result = mix(_e624, _e625, vec3(0.5f));
                        }
                    } else {
                        let _e629 = type_44;
                        if (_e629 == 1i) {
                            {
                                let _e632 = cbidx;
                                let _e633 = s_1;
                                let _e637 = jpegBlockHash3_((_e632 + vec2<f32>(_e633, 17f)));
                                U = (floor((_e637 * 6f)) + vec3(1f));
                                let _e645 = cbidx;
                                let _e646 = s_1;
                                let _e650 = jpegBlockHash3_((_e645 + vec2<f32>(_e646, 41f)));
                                V = (floor((_e650 * 6f)) + vec3(1f));
                                let _e658 = cbidx;
                                let _e659 = s_1;
                                let _e663 = jpegBlockHash3_((_e658 + vec2<f32>(_e659, 5f)));
                                dc = _e663;
                                let _e665 = cbidx;
                                let _e666 = s_1;
                                let _e670 = jpegBlockHash3_((_e665 + vec2<f32>(_e666, 71f)));
                                amp = _e670;
                                let _e672 = dc;
                                let _e673 = amp;
                                let _e675 = lc;
                                let _e680 = U;
                                let _e682 = PI2N;
                                let _e687 = lc;
                                let _e692 = V;
                                let _e694 = PI2N;
                                result = (_e672 + ((_e673 * cos(((((2f * _e675.x) + 1f) * _e680) * _e682))) * cos(((((2f * _e687.y) + 1f) * _e692) * _e694))));
                            }
                        } else {
                            let _e699 = type_44;
                            if (_e699 == 2i) {
                                {
                                    let _e702 = cbidx;
                                    let _e703 = s_1;
                                    let _e707 = jpegBlockHash3_((_e702 + vec2<f32>(_e703, 23f)));
                                    let _e712 = blockUV;
                                    disp_1 = (((_e707.xy - vec2(0.5f)) * _e712) * 5f);
                                    let _e717 = pos_1;
                                    let _e718 = disp_1;
                                    let _e723 = global.U[0];
                                    let _e726 = pos_1;
                                    let _e727 = disp_1;
                                    let _e737 = textureSample(t_source, samp, ((vec2<f32>(((_e717 + _e718).x / _e723.x), (_e726 + _e727).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e739 = pos_1;
                                    let _e740 = disp_1;
                                    let _e745 = global.U[0];
                                    let _e748 = pos_1;
                                    let _e749 = disp_1;
                                    let _e759 = textureSample(t_source, samp, ((vec2<f32>(((_e739 - _e740).x / _e745.x), (_e748 - _e749).y) / vec2(2f)) + vec2(0.5f)));
                                    let _e761 = pos_1;
                                    let _e762 = disp_1;
                                    let _e768 = global.U[0];
                                    let _e771 = pos_1;
                                    let _e772 = disp_1;
                                    let _e783 = textureSample(t_source, samp, ((vec2<f32>(((_e761 + _e762.yx).x / _e768.x), (_e771 + _e772.yx).y) / vec2(2f)) + vec2(0.5f)));
                                    result = vec3<f32>(_e737.x, _e759.y, _e783.z);
                                }
                            } else {
                                {
                                    let _e786 = L;
                                    let _e787 = N;
                                    let _e791 = s_1;
                                    let _e795 = jpegBlockHash3_((floor((_e786 * f32(_e787))) + vec2<f32>(_e791, 3f)));
                                    result = _e795;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e796 = result;
    let _e801 = clamp(_e796, vec3(0f), vec3(1f));
    let _e802 = inCol;
    outCol = vec4<f32>(_e801.x, _e801.y, _e801.z, _e802.w);
    let _e809 = balance_1;
    bal = _e809;
    let _e811 = bal;
    if (_e811 >= 0f) {
        {
            let _e814 = outCol;
            let _e816 = outCol;
            let _e818 = inCol;
            let _e820 = bal;
            let _e822 = mix(_e816.xyz, _e818.xyz, vec3(_e820));
            outCol.x = _e822.x;
            outCol.y = _e822.y;
            outCol.z = _e822.z;
        }
    } else {
        {
            let _e829 = outCol;
            let _e831 = outCol;
            let _e833 = outCol;
            let _e835 = inCol;
            let _e839 = bal;
            let _e842 = mix(_e831.xyz, abs((_e833.xyz - _e835.xyz)), vec3(-(_e839)));
            outCol.x = _e842.x;
            outCol.y = _e842.y;
            outCol.z = _e842.z;
        }
    }
    let _e849 = outCol;
    return _e849;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e113 = jpegCrushGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)));
    fragColor = _e113;
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
