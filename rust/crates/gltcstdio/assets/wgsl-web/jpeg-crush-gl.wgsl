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
    var type_43: i32 = 0i;
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
    let _e41 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e31.y) / vec2(2f)) + vec2(0.5f)), 0f);
    inCol = _e41;
    let _e45 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e45);
    let _e51 = im[0];
    res = max(1f, length(_e51.xy));
    let _e57 = res;
    blockUV = (1f / _e57);
    let _e60 = im;
    let _e61 = pos_1;
    L = (_e60 * vec3<f32>(_e61.x, _e61.y, 1f)).xy;
    let _e69 = L;
    cbidx = floor(_e69);
    let _e72 = L;
    let _e74 = N;
    let _e79 = N;
    lc = clamp(floor((fract(_e72) * f32(_e74))), vec2(0f), vec2((f32(_e79) - 1f)));
    let _e88 = intensity_1;
    keep = i32(clamp((6f - (_e88 * 5f)), 1f, 6f));
    let _e98 = intensity_1;
    quant = (0.02f + (_e98 * 0.6f));
    let _e103 = keep;
    let _e105 = chroma_1;
    keepC = i32(clamp((f32(_e103) - (_e105 * 4f)), 1f, 6f));
    let _e114 = quant;
    let _e116 = chroma_1;
    quantC = (_e114 * (1f + (_e116 * 8f)));
    let _e122 = chroma_1;
    chromaMix = clamp(_e122, 0f, 1f);
    let _e128 = N;
    aN0_ = sqrt((1f / f32(_e128)));
    let _e134 = N;
    aNk = sqrt((2f / f32(_e134)));
    let _e141 = N;
    PI2N = (3.1415927f / (2f * f32(_e141)));
    loop {
        let _e151 = u;
        if !((_e151 < 8i)) {
            break;
        }
        {
            let _e158 = u;
            let _e159 = keep;
            if (_e158 >= _e159) {
                break;
            }
            let _e161 = u;
            if (_e161 == 0i) {
                let _e164 = aN0_;
                local = _e164;
            } else {
                let _e165 = aNk;
                local = _e165;
            }
            let _e167 = local;
            au = _e167;
            v = 0i;
            loop {
                let _e171 = v;
                if !((_e171 < 8i)) {
                    break;
                }
                {
                    let _e178 = v;
                    let _e179 = keep;
                    if (_e178 >= _e179) {
                        break;
                    }
                    let _e181 = v;
                    if (_e181 == 0i) {
                        let _e184 = aN0_;
                        local_1 = _e184;
                    } else {
                        let _e185 = aNk;
                        local_1 = _e185;
                    }
                    let _e187 = local_1;
                    av = _e187;
                    F = vec3(0f);
                    x = 0i;
                    loop {
                        let _e194 = x;
                        if !((_e194 < 8i)) {
                            break;
                        }
                        {
                            let _e202 = x;
                            let _e207 = u;
                            let _e210 = PI2N;
                            bx = cos(((((2f * f32(_e202)) + 1f) * f32(_e207)) * _e210));
                            y_2 = 0i;
                            loop {
                                let _e216 = y_2;
                                if !((_e216 < 8i)) {
                                    break;
                                }
                                {
                                    let _e223 = modelTransform_1;
                                    let _e224 = cbidx;
                                    let _e225 = x;
                                    let _e227 = y_2;
                                    let _e233 = N;
                                    let _e237 = (_e224 + ((vec2<f32>(f32(_e225), f32(_e227)) + vec2(0.5f)) / vec2(f32(_e233))));
                                    s = (_e223 * vec3<f32>(_e237.x, _e237.y, 1f)).xy;
                                    let _e245 = s;
                                    let _e249 = global.U[0];
                                    let _e252 = s;
                                    let _e262 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e245.x / _e249.x), _e252.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    f = _e262.xyz;
                                    let _e265 = F;
                                    let _e266 = f;
                                    let _e267 = bx;
                                    let _e270 = y_2;
                                    let _e275 = v;
                                    let _e278 = PI2N;
                                    F = (_e265 + ((_e266 * _e267) * cos(((((2f * f32(_e270)) + 1f) * f32(_e275)) * _e278))));
                                }
                                continuing {
                                    let _e220 = y_2;
                                    y_2 = (_e220 + 1i);
                                }
                            }
                        }
                        continuing {
                            let _e198 = x;
                            x = (_e198 + 1i);
                        }
                    }
                    let _e283 = F;
                    let _e284 = au;
                    let _e285 = av;
                    F = (_e283 * (_e284 * _e285));
                    let _e288 = F;
                    let _e289 = quant;
                    let _e296 = quant;
                    Frgb = (floor(((_e288 / vec3(_e289)) + vec3(0.5f))) * _e296);
                    let _e299 = chroma_1;
                    if (_e299 > 0f) {
                        {
                            let _e302 = F;
                            let _e303 = jpegRgb2ycc(_e302);
                            ycc = _e303;
                            let _e306 = ycc;
                            let _e308 = quant;
                            let _e313 = quant;
                            ycc.x = (floor(((_e306.x / _e308) + 0.5f)) * _e313);
                            let _e315 = ycc;
                            let _e317 = ycc;
                            let _e319 = quantC;
                            let _e326 = quantC;
                            let _e327 = (floor(((_e317.yz / vec2(_e319)) + vec2(0.5f))) * _e326);
                            ycc.y = _e327.x;
                            ycc.z = _e327.y;
                            let _e332 = u;
                            let _e333 = keepC;
                            let _e335 = v;
                            let _e336 = keepC;
                            if ((_e332 >= _e333) || (_e335 >= _e336)) {
                                let _e339 = ycc;
                                ycc.y = 0f;
                                ycc.z = 0f;
                            }
                            let _e345 = Frgb;
                            let _e346 = ycc;
                            let _e347 = jpegYcc2rgb(_e346);
                            let _e348 = chromaMix;
                            F = mix(_e345, _e347, vec3(_e348));
                        }
                    } else {
                        {
                            let _e351 = Frgb;
                            F = _e351;
                        }
                    }
                    let _e352 = u;
                    let _e353 = v;
                    acw = f32((_e352 + _e353));
                    let _e357 = ringing_1;
                    let _e360 = acw;
                    if ((_e357 > 0f) && (_e360 > 0f)) {
                        let _e364 = F;
                        let _e366 = ringing_1;
                        let _e369 = acw;
                        F = (_e364 * (1f + ((_e366 * 0.3f) * _e369)));
                    }
                    let _e373 = result;
                    let _e374 = au;
                    let _e375 = av;
                    let _e377 = F;
                    let _e380 = lc;
                    let _e385 = u;
                    let _e388 = PI2N;
                    let _e393 = lc;
                    let _e398 = v;
                    let _e401 = PI2N;
                    result = (_e373 + ((((_e374 * _e375) * _e377) * cos(((((2f * _e380.x) + 1f) * f32(_e385)) * _e388))) * cos(((((2f * _e393.y) + 1f) * f32(_e398)) * _e401))));
                }
                continuing {
                    let _e175 = v;
                    v = (_e175 + 1i);
                }
            }
        }
        continuing {
            let _e155 = u;
            u = (_e155 + 1i);
        }
    }
    let _e406 = variability_1;
    if (abs(_e406) > 0f) {
        {
            let _e410 = cbidx;
            gc = (_e410 + vec2(0.5f));
            let _e415 = randomSeed_1;
            s_1 = _e415;
            let _e420 = w;
            let _e421 = gc;
            let _e429 = s_1;
            let _e433 = jpegHash4_(floor((((_e421 * vec2<f32>(0.043f, 0.052f)) + vec2(11.3f)) + vec2(_e429))));
            w = (_e420 * _e433);
            let _e435 = w;
            let _e436 = gc;
            let _e444 = s_1;
            let _e450 = jpegHash4_(floor((((_e436 * vec2<f32>(0.075f, 0.091f)) + vec2(53.1f)) + vec2((_e444 * 2.1f)))));
            w = (_e435 * _e450);
            let _e452 = w;
            let _e453 = gc;
            let _e461 = s_1;
            let _e467 = jpegHash4_(floor((((_e453 * vec2<f32>(0.244f, 0.27f)) + vec2(17.5f)) + vec2((_e461 * 2.9f)))));
            w = (_e452 * _e467);
            let _e469 = variability_1;
            if (_e469 >= 0f) {
                local_2 = vec2<f32>(0.037f, 0.213f);
            } else {
                local_2 = vec2<f32>(0.213f, 0.037f);
            }
            let _e479 = local_2;
            kA = _e479;
            let _e481 = variability_1;
            if (_e481 >= 0f) {
                local_3 = vec2<f32>(0.024f, 0.131f);
            } else {
                local_3 = vec2<f32>(0.131f, 0.024f);
            }
            let _e491 = local_3;
            kB = _e491;
            let _e493 = w;
            let _e494 = gc;
            let _e495 = kA;
            let _e500 = s_1;
            let _e506 = jpegHash4_(floor((((_e494 * _e495) + vec2(31.7f)) + vec2((_e500 * 1.3f)))));
            w = (_e493 * pow(_e506, vec4(2.5f)));
            let _e511 = w;
            let _e512 = gc;
            let _e513 = kB;
            let _e518 = s_1;
            let _e524 = jpegHash4_(floor((((_e512 * _e513) + vec2(7.9f)) + vec2((_e518 * 1.7f)))));
            w = (_e511 * pow(_e524, vec4(1.6f)));
            let _e531 = w;
            best = _e531.x;
            let _e534 = w;
            let _e536 = best;
            if (_e534.y > _e536) {
                {
                    let _e538 = w;
                    best = _e538.y;
                    type_43 = 1i;
                }
            }
            let _e541 = w;
            let _e543 = best;
            if (_e541.z > _e543) {
                {
                    let _e545 = w;
                    best = _e545.z;
                    type_43 = 2i;
                }
            }
            let _e548 = w;
            let _e550 = best;
            if (_e548.w > _e550) {
                {
                    let _e552 = w;
                    best = _e552.w;
                    type_43 = 3i;
                }
            }
            let _e555 = variability_1;
            density = clamp(abs(_e555), 0f, 1f);
            let _e561 = best;
            g = pow(_e561, 0.14f);
            let _e565 = g;
            let _e568 = density;
            if (_e565 > mix(1.02f, 0.25f, pow(_e568, 1.3f))) {
                {
                    let _e573 = type_43;
                    if (_e573 == 0i) {
                        {
                            let _e576 = cbidx;
                            let _e582 = s_1;
                            let _e586 = jpegBlockHash3_((floor((_e576 * vec2<f32>(0.1f, 0.35f))) + vec2<f32>(_e582, 5f)));
                            tint = _e586;
                            let _e588 = cbidx;
                            let _e589 = s_1;
                            let _e593 = jpegBlockHash3_((_e588 + vec2<f32>(_e589, 91f)));
                            let _e598 = blockUV;
                            disp = (((_e593.xy - vec2(0.5f)) * _e598) * 6f);
                            let _e603 = pos_1;
                            let _e604 = disp;
                            let _e609 = global.U[0];
                            let _e612 = pos_1;
                            let _e613 = disp;
                            let _e624 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e603 + _e604).x / _e609.x), (_e612 + _e613).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            src = _e624.xyz;
                            let _e627 = src;
                            let _e628 = tint;
                            result = mix(_e627, _e628, vec3(0.5f));
                        }
                    } else {
                        let _e632 = type_43;
                        if (_e632 == 1i) {
                            {
                                let _e635 = cbidx;
                                let _e636 = s_1;
                                let _e640 = jpegBlockHash3_((_e635 + vec2<f32>(_e636, 17f)));
                                U = (floor((_e640 * 6f)) + vec3(1f));
                                let _e648 = cbidx;
                                let _e649 = s_1;
                                let _e653 = jpegBlockHash3_((_e648 + vec2<f32>(_e649, 41f)));
                                V = (floor((_e653 * 6f)) + vec3(1f));
                                let _e661 = cbidx;
                                let _e662 = s_1;
                                let _e666 = jpegBlockHash3_((_e661 + vec2<f32>(_e662, 5f)));
                                dc = _e666;
                                let _e668 = cbidx;
                                let _e669 = s_1;
                                let _e673 = jpegBlockHash3_((_e668 + vec2<f32>(_e669, 71f)));
                                amp = _e673;
                                let _e675 = dc;
                                let _e676 = amp;
                                let _e678 = lc;
                                let _e683 = U;
                                let _e685 = PI2N;
                                let _e690 = lc;
                                let _e695 = V;
                                let _e697 = PI2N;
                                result = (_e675 + ((_e676 * cos(((((2f * _e678.x) + 1f) * _e683) * _e685))) * cos(((((2f * _e690.y) + 1f) * _e695) * _e697))));
                            }
                        } else {
                            let _e702 = type_43;
                            if (_e702 == 2i) {
                                {
                                    let _e705 = cbidx;
                                    let _e706 = s_1;
                                    let _e710 = jpegBlockHash3_((_e705 + vec2<f32>(_e706, 23f)));
                                    let _e715 = blockUV;
                                    disp_1 = (((_e710.xy - vec2(0.5f)) * _e715) * 5f);
                                    let _e720 = pos_1;
                                    let _e721 = disp_1;
                                    let _e726 = global.U[0];
                                    let _e729 = pos_1;
                                    let _e730 = disp_1;
                                    let _e741 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e720 + _e721).x / _e726.x), (_e729 + _e730).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e743 = pos_1;
                                    let _e744 = disp_1;
                                    let _e749 = global.U[0];
                                    let _e752 = pos_1;
                                    let _e753 = disp_1;
                                    let _e764 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e743 - _e744).x / _e749.x), (_e752 - _e753).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e766 = pos_1;
                                    let _e767 = disp_1;
                                    let _e773 = global.U[0];
                                    let _e776 = pos_1;
                                    let _e777 = disp_1;
                                    let _e789 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e766 + _e767.yx).x / _e773.x), (_e776 + _e777.yx).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    result = vec3<f32>(_e741.x, _e764.y, _e789.z);
                                }
                            } else {
                                {
                                    let _e792 = L;
                                    let _e793 = N;
                                    let _e797 = s_1;
                                    let _e801 = jpegBlockHash3_((floor((_e792 * f32(_e793))) + vec2<f32>(_e797, 3f)));
                                    result = _e801;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e802 = result;
    let _e807 = clamp(_e802, vec3(0f), vec3(1f));
    let _e808 = inCol;
    outCol = vec4<f32>(_e807.x, _e807.y, _e807.z, _e808.w);
    let _e815 = balance_1;
    bal = _e815;
    let _e817 = bal;
    if (_e817 >= 0f) {
        {
            let _e820 = outCol;
            let _e822 = outCol;
            let _e824 = inCol;
            let _e826 = bal;
            let _e828 = mix(_e822.xyz, _e824.xyz, vec3(_e826));
            outCol.x = _e828.x;
            outCol.y = _e828.y;
            outCol.z = _e828.z;
        }
    } else {
        {
            let _e835 = outCol;
            let _e837 = outCol;
            let _e839 = outCol;
            let _e841 = inCol;
            let _e845 = bal;
            let _e848 = mix(_e837.xyz, abs((_e839.xyz - _e841.xyz)), vec3(-(_e845)));
            outCol.x = _e848.x;
            outCol.y = _e848.y;
            outCol.z = _e848.z;
        }
    }
    let _e855 = outCol;
    return _e855;
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
