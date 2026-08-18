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

fn getIndex(pos: vec2<f32>, blockSize: vec2<f32>, dim: vec2<f32>) -> f32 {
    var pos_1: vec2<f32>;
    var blockSize_1: vec2<f32>;
    var dim_1: vec2<f32>;
    var columns: f32;
    var lines: f32;
    var f: vec2<f32>;

    pos_1 = pos;
    blockSize_1 = blockSize;
    dim_1 = dim;
    let _e12 = dim_1;
    let _e14 = blockSize_1;
    columns = (_e12.x / _e14.x);
    let _e18 = dim_1;
    let _e20 = blockSize_1;
    lines = (_e18.y / _e20.y);
    let _e24 = pos_1;
    let _e25 = blockSize_1;
    f = floor((_e24 / _e25));
    let _e29 = f;
    let _e32 = columns;
    let _e35 = f;
    let _e38 = lines;
    let _e41 = columns;
    return ((_e29.x + (0.5f * _e32)) + ((_e35.y + (0.5f * _e38)) * _e41));
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

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k_4: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_5: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_5 = k_4;
    let _e12 = val1_1;
    let _e14 = k_5;
    let _e22 = val2_1;
    let _e25 = k_5;
    return (((_e12 * (1f + cos((_e14 * 3.1415927f)))) * 0.5f) + ((_e22 * (1f + cos(((1f - _e25) * 3.1415927f)))) * 0.5f));
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e10 = v_3;
    u00_ = floor(_e10);
    let _e13 = v_3;
    let _e16 = v_3;
    u01_ = vec2<f32>(floor(_e13.x), ceil(_e16.y));
    let _e21 = v_3;
    let _e24 = v_3;
    u10_ = vec2<f32>(ceil(_e21.x), floor(_e24.y));
    let _e29 = v_3;
    u11_ = ceil(_e29);
    let _e32 = u00_;
    let _e33 = rand2_(_e32);
    let _e34 = seed_3;
    let _e35 = varyVec2NoiseSmoothly(_e33, _e34);
    r00_ = (_e35 - vec2<f32>(0.5f, 0.5f));
    let _e41 = u01_;
    let _e42 = rand2_(_e41);
    let _e43 = seed_3;
    let _e44 = varyVec2NoiseSmoothly(_e42, _e43);
    r01_ = (_e44 - vec2<f32>(0.5f, 0.5f));
    let _e50 = u10_;
    let _e51 = rand2_(_e50);
    let _e52 = seed_3;
    let _e53 = varyVec2NoiseSmoothly(_e51, _e52);
    r10_ = (_e53 - vec2<f32>(0.5f, 0.5f));
    let _e59 = u11_;
    let _e60 = rand2_(_e59);
    let _e61 = seed_3;
    let _e62 = varyVec2NoiseSmoothly(_e60, _e61);
    r11_ = (_e62 - vec2<f32>(0.5f, 0.5f));
    let _e68 = r00_;
    let _e69 = r01_;
    let _e70 = v_3;
    let _e73 = sineMix(_e68, _e69, fract(_e70.y));
    let _e74 = r10_;
    let _e75 = r11_;
    let _e76 = v_3;
    let _e79 = sineMix(_e74, _e75, fract(_e76.y));
    let _e80 = v_3;
    let _e83 = sineMix(_e73, _e79, fract(_e80.x));
    return _e83;
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local: vec4<f32>;
    var P: vec4<f32>;
    var local_1: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e8 = RGB_1;
    let _e10 = RGB_1;
    if (_e8.y < _e10.z) {
        let _e13 = RGB_1;
        let _e14 = _e13.zy;
        local = vec4<f32>(_e14.x, _e14.y, -1f, 0.6666667f);
    } else {
        let _e23 = RGB_1;
        let _e24 = _e23.yz;
        local = vec4<f32>(_e24.x, _e24.y, 0f, -0.33333334f);
    }
    let _e34 = local;
    P = _e34;
    let _e36 = RGB_1;
    let _e38 = P;
    if (_e36.x < _e38.x) {
        let _e41 = P;
        let _e42 = _e41.xyw;
        let _e43 = RGB_1;
        local_1 = vec4<f32>(_e42.x, _e42.y, _e42.z, _e43.x);
    } else {
        let _e49 = RGB_1;
        let _e51 = P;
        let _e52 = _e51.yzx;
        local_1 = vec4<f32>(_e49.x, _e52.x, _e52.y, _e52.z);
    }
    let _e58 = local_1;
    Q = _e58;
    let _e60 = Q;
    let _e62 = Q;
    let _e64 = Q;
    C = (_e60.x - min(_e62.w, _e64.y));
    let _e69 = Q;
    let _e71 = Q;
    let _e75 = C;
    let _e80 = Q;
    H = abs((((_e69.w - _e71.y) / ((6f * _e75) + 0.0000000001f)) + _e80.z));
    let _e85 = H;
    let _e86 = C;
    let _e87 = Q;
    let _e89 = RGB_1;
    return vec4<f32>(_e85, _e86, _e87.x, _e89.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e8 = RGB_3;
    let _e9 = rgbToHcv(_e8);
    HCV = _e9;
    let _e11 = HCV;
    let _e13 = HCV;
    L = (_e11.z - (_e13.y * 0.5f));
    let _e19 = HCV;
    let _e22 = L;
    S = (_e19.y / ((1f - abs(((_e22 * 2f) - 1f))) + 0.000001f));
    let _e33 = HCV;
    let _e37 = S;
    let _e38 = L;
    let _e39 = RGB_3;
    return vec4<f32>((_e33.x * 360f), _e37, _e38, _e39.w);
}

fn hsluv_lengthOfRayUntilIntersect(theta: f32, x_1: vec3<f32>, y_1: vec3<f32>) -> vec3<f32> {
    var theta_1: f32;
    var x_2: vec3<f32>;
    var y_2: vec3<f32>;
    var len: vec3<f32>;

    theta_1 = theta;
    x_2 = x_1;
    y_2 = y_1;
    let _e12 = y_2;
    let _e13 = theta_1;
    let _e15 = x_2;
    let _e16 = theta_1;
    len = (_e12 / (vec3(sin(_e13)) - (_e15 * cos(_e16))));
    let _e23 = len;
    if (_e23.x < 0f) {
        {
            len.x = 1000f;
        }
    }
    let _e29 = len;
    if (_e29.y < 0f) {
        {
            len.y = 1000f;
        }
    }
    let _e35 = len;
    if (_e35.z < 0f) {
        {
            len.z = 1000f;
        }
    }
    let _e41 = len;
    return _e41;
}

fn hsluv_maxChromaForLH(L_1: f32, H_1: f32) -> f32 {
    var L_2: f32;
    var H_2: f32;
    var hrad: f32;
    var m2_: mat3x3<f32> = mat3x3<f32>(vec3<f32>(3.24097f, -0.96924365f, 0.05563008f), vec3<f32>(-1.5373832f, 1.8759675f, -0.20397696f), vec3<f32>(-0.49861076f, 0.04155506f, 1.0569715f));
    var sub1_: f32;
    var local_2: f32;
    var sub2_: f32;
    var top1_: vec3<f32>;
    var bottom: vec3<f32>;
    var top2_: vec3<f32>;
    var bound0x: vec3<f32>;
    var bound0y: vec3<f32>;
    var bound1x: vec3<f32>;
    var bound1y: vec3<f32>;
    var lengths0_: vec3<f32>;
    var lengths1_: vec3<f32>;

    L_2 = L_1;
    H_2 = H_1;
    let _e10 = H_2;
    hrad = radians(_e10);
    let _e31 = L_2;
    sub1_ = (pow((_e31 + 16f), 3f) / 1560896f);
    let _e39 = sub1_;
    if (_e39 > 0.008856452f) {
        let _e42 = sub1_;
        local_2 = _e42;
    } else {
        let _e43 = L_2;
        local_2 = (_e43 / 903.2963f);
    }
    let _e47 = local_2;
    sub2_ = _e47;
    let _e52 = m2_[0];
    let _e57 = m2_[2];
    let _e60 = sub2_;
    top1_ = (((284517f * _e52) - (94839f * _e57)) * _e60);
    let _e66 = m2_[2];
    let _e71 = m2_[1];
    let _e74 = sub2_;
    bottom = (((632260f * _e66) - (126452f * _e71)) * _e74);
    let _e80 = m2_[2];
    let _e85 = m2_[1];
    let _e91 = m2_[0];
    let _e94 = L_2;
    let _e96 = sub2_;
    top2_ = (((((838422f * _e80) + (769860f * _e85)) + (731718f * _e91)) * _e94) * _e96);
    let _e99 = top1_;
    let _e100 = bottom;
    bound0x = (_e99 / _e100);
    let _e103 = top2_;
    let _e104 = bottom;
    bound0y = (_e103 / _e104);
    let _e107 = top1_;
    let _e108 = bottom;
    bound1x = (_e107 / (_e108 + vec3(126452f)));
    let _e114 = top2_;
    let _e116 = L_2;
    let _e120 = bottom;
    bound1y = ((_e114 - vec3((769860f * _e116))) / (_e120 + vec3(126452f)));
    let _e126 = hrad;
    let _e127 = bound0x;
    let _e128 = bound0y;
    let _e129 = hsluv_lengthOfRayUntilIntersect(_e126, _e127, _e128);
    lengths0_ = _e129;
    let _e131 = hrad;
    let _e132 = bound1x;
    let _e133 = bound1y;
    let _e134 = hsluv_lengthOfRayUntilIntersect(_e131, _e132, _e133);
    lengths1_ = _e134;
    let _e136 = lengths0_;
    let _e138 = lengths1_;
    let _e140 = lengths0_;
    let _e142 = lengths1_;
    let _e144 = lengths0_;
    let _e146 = lengths1_;
    return min(_e136.x, min(_e138.x, min(_e140.y, min(_e142.y, min(_e144.z, _e146.z)))));
}

fn lchToHsluv(tuple: vec3<f32>) -> vec3<f32> {
    var tuple_1: vec3<f32>;

    tuple_1 = tuple;
    let _e9 = tuple_1;
    let _e11 = tuple_1;
    let _e13 = tuple_1;
    let _e15 = hsluv_maxChromaForLH(_e11.x, _e13.z);
    tuple_1.y = (_e9.y / (_e15 * 0.01f));
    let _e19 = tuple_1;
    return _e19.zyx;
}

fn luvToLch(tuple_2: vec3<f32>) -> vec3<f32> {
    var tuple_3: vec3<f32>;
    var L_3: f32;
    var U: f32;
    var V: f32;
    var C_1: f32;
    var H_3: f32;

    tuple_3 = tuple_2;
    let _e8 = tuple_3;
    L_3 = _e8.x;
    let _e11 = tuple_3;
    U = _e11.y;
    let _e14 = tuple_3;
    V = _e14.z;
    let _e17 = tuple_3;
    C_1 = length(_e17.yz);
    let _e21 = V;
    let _e22 = U;
    H_3 = degrees(atan2(_e21, _e22));
    let _e26 = H_3;
    if (_e26 < 0f) {
        {
            let _e30 = H_3;
            H_3 = (360f + _e30);
        }
    }
    let _e32 = L_3;
    let _e33 = C_1;
    let _e34 = H_3;
    return vec3<f32>(_e32, _e33, _e34);
}

fn hsluv_toLinear1_(c: f32) -> f32 {
    var c_1: f32;
    var local_3: f32;

    c_1 = c;
    let _e8 = c_1;
    if (_e8 > 0.04045f) {
        let _e11 = c_1;
        local_3 = pow(((_e11 + 0.055f) / 1.055f), 2.4f);
    } else {
        let _e20 = c_1;
        local_3 = (_e20 / 12.92f);
    }
    let _e24 = local_3;
    return _e24;
}

fn hsluv_toLinear(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e8 = c_3;
    let _e10 = hsluv_toLinear1_(_e8.x);
    let _e11 = c_3;
    let _e13 = hsluv_toLinear1_(_e11.y);
    let _e14 = c_3;
    let _e16 = hsluv_toLinear1_(_e14.z);
    return vec3<f32>(_e10, _e13, _e16);
}

fn rgbToXyz(tuple_4: vec3<f32>) -> vec3<f32> {
    var tuple_5: vec3<f32>;
    var m: mat3x3<f32> = mat3x3<f32>(vec3<f32>(0.4123908f, 0.35758433f, 0.1804808f), vec3<f32>(0.212639f, 0.71516865f, 0.07219232f), vec3<f32>(0.019330818f, 0.11919478f, 0.95053214f));

    tuple_5 = tuple_4;
    let _e22 = tuple_5;
    let _e23 = hsluv_toLinear(_e22);
    let _e24 = m;
    return (_e23 * _e24);
}

fn hsluv_yToL(Y: f32) -> f32 {
    var Y_1: f32;
    var local_4: f32;

    Y_1 = Y;
    let _e8 = Y_1;
    if (_e8 <= 0.008856452f) {
        let _e11 = Y_1;
        local_4 = (_e11 * 903.2963f);
    } else {
        let _e15 = Y_1;
        local_4 = ((116f * pow(_e15, 0.33333334f)) - 16f);
    }
    let _e24 = local_4;
    return _e24;
}

fn xyzToLuv(tuple_6: vec3<f32>) -> vec3<f32> {
    var tuple_7: vec3<f32>;
    var X: f32;
    var Y_2: f32;
    var Z: f32;
    var L_4: f32;
    var div: f32;

    tuple_7 = tuple_6;
    let _e8 = tuple_7;
    X = _e8.x;
    let _e11 = tuple_7;
    Y_2 = _e11.y;
    let _e14 = tuple_7;
    Z = _e14.z;
    let _e17 = Y_2;
    let _e18 = hsluv_yToL(_e17);
    L_4 = _e18;
    let _e21 = tuple_7;
    div = (1f / dot(_e21, vec3<f32>(1f, 15f, 3f)));
    let _e34 = X;
    let _e35 = div;
    let _e41 = Y_2;
    let _e42 = div;
    let _e48 = L_4;
    return (vec3<f32>(1f, ((52f * (_e34 * _e35)) - 2.57179f), ((117f * (_e41 * _e42)) - 6.08816f)) * _e48);
}

fn rgbToLch(tuple_8: vec3<f32>) -> vec3<f32> {
    var tuple_9: vec3<f32>;

    tuple_9 = tuple_8;
    let _e8 = tuple_9;
    let _e9 = rgbToXyz(_e8);
    let _e10 = xyzToLuv(_e9);
    let _e11 = luvToLch(_e10);
    return _e11;
}

fn rgbToHsluv(tuple_10: vec3<f32>) -> vec3<f32> {
    var tuple_11: vec3<f32>;

    tuple_11 = tuple_10;
    let _e8 = tuple_11;
    let _e9 = rgbToLch(_e8);
    let _e10 = lchToHsluv(_e9);
    return _e10;
}

fn getChannel(color: vec4<f32>, channel: i32) -> f32 {
    var color_1: vec4<f32>;
    var channel_1: i32;

    color_1 = color;
    channel_1 = channel;
    let _e10 = channel_1;
    if (_e10 == 0i) {
        let _e13 = color_1;
        return _e13.x;
    } else {
        let _e15 = channel_1;
        if (_e15 == 1i) {
            let _e18 = color_1;
            return _e18.y;
        } else {
            let _e20 = channel_1;
            if (_e20 == 2i) {
                let _e23 = color_1;
                return _e23.z;
            } else {
                let _e25 = channel_1;
                if (_e25 == 3i) {
                    let _e28 = color_1;
                    let _e29 = rgbToHsl(_e28);
                    return (_e29.x / 360f);
                } else {
                    let _e33 = channel_1;
                    if (_e33 == 4i) {
                        let _e36 = color_1;
                        let _e37 = rgbToHsl(_e36);
                        return _e37.y;
                    } else {
                        let _e39 = channel_1;
                        if (_e39 == 5i) {
                            let _e42 = color_1;
                            let _e43 = rgbToHsl(_e42);
                            return _e43.z;
                        } else {
                            let _e45 = channel_1;
                            if (_e45 == 6i) {
                                let _e48 = color_1;
                                let _e50 = rgbToHsluv(_e48.xyz);
                                return (_e50.x / 360f);
                            } else {
                                let _e54 = channel_1;
                                if (_e54 == 7i) {
                                    let _e57 = color_1;
                                    let _e59 = rgbToHsluv(_e57.xyz);
                                    return (_e59.y * 0.01f);
                                } else {
                                    let _e63 = channel_1;
                                    if (_e63 == 8i) {
                                        let _e66 = color_1;
                                        let _e68 = rgbToHsluv(_e66.xyz);
                                        return (_e68.z * 0.01f);
                                    } else {
                                        return 0f;
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

fn getChannelWithHsl(color_2: vec4<f32>, hsl: vec4<f32>, channel_2: i32) -> f32 {
    var color_3: vec4<f32>;
    var hsl_1: vec4<f32>;
    var channel_3: i32;

    color_3 = color_2;
    hsl_1 = hsl;
    channel_3 = channel_2;
    let _e12 = channel_3;
    if (_e12 == 0i) {
        let _e15 = color_3;
        return _e15.x;
    } else {
        let _e17 = channel_3;
        if (_e17 == 1i) {
            let _e20 = color_3;
            return _e20.y;
        } else {
            let _e22 = channel_3;
            if (_e22 == 2i) {
                let _e25 = color_3;
                return _e25.z;
            } else {
                let _e27 = channel_3;
                if (_e27 == 3i) {
                    let _e30 = color_3;
                    let _e31 = rgbToHsl(_e30);
                    return (_e31.x / 360f);
                } else {
                    let _e35 = channel_3;
                    if (_e35 == 4i) {
                        let _e38 = color_3;
                        let _e39 = rgbToHsl(_e38);
                        return _e39.y;
                    } else {
                        let _e41 = channel_3;
                        if (_e41 == 5i) {
                            let _e44 = color_3;
                            let _e45 = rgbToHsl(_e44);
                            return _e45.z;
                        } else {
                            return 0f;
                        }
                    }
                }
            }
        }
    }
}

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e12 = h_1;
    if (_e12 < 0f) {
        let _e15 = h_1;
        h_1 = (_e15 + 1f);
    }
    let _e18 = h_1;
    if (_e18 > 1f) {
        let _e21 = h_1;
        h_1 = (_e21 - 1f);
    }
    let _e25 = h_1;
    if ((6f * _e25) < 1f) {
        {
            let _e29 = p_1;
            let _e30 = q_1;
            let _e31 = p_1;
            let _e35 = h_1;
            return (_e29 + (((_e30 - _e31) * 6f) * _e35));
        }
    }
    let _e39 = h_1;
    if ((2f * _e39) < 1f) {
        {
            let _e43 = q_1;
            return _e43;
        }
    }
    let _e45 = h_1;
    if ((3f * _e45) < 2f) {
        {
            let _e49 = p_1;
            let _e50 = q_1;
            let _e51 = p_1;
            let _e58 = h_1;
            return (_e49 + (((_e50 - _e51) * 6f) * (0.6666667f - _e58)));
        }
    }
    let _e62 = p_1;
    return _e62;
}

fn hslToRgb(inc: vec4<f32>) -> vec4<f32> {
    var inc_1: vec4<f32>;
    var h_2: f32;
    var s: f32;
    var l: f32;
    var q_2: f32 = 0f;
    var p_2: f32;
    var r: f32;
    var g: f32;
    var b: f32;
    var outc: vec4<f32>;

    inc_1 = inc;
    let _e8 = inc_1;
    h_2 = (_e8.x - (floor((_e8.x / 360f)) * 360f));
    let _e16 = h_2;
    h_2 = (_e16 / 360f);
    let _e19 = inc_1;
    s = _e19.y;
    let _e22 = inc_1;
    l = _e22.z;
    let _e27 = l;
    if (_e27 < 0.5f) {
        let _e30 = l;
        let _e32 = s;
        q_2 = (_e30 * (1f + _e32));
    } else {
        let _e35 = l;
        let _e36 = s;
        let _e38 = s;
        let _e39 = l;
        q_2 = ((_e35 + _e36) - (_e38 * _e39));
    }
    let _e43 = l;
    let _e45 = q_2;
    p_2 = ((2f * _e43) - _e45);
    let _e49 = p_2;
    let _e50 = q_2;
    let _e51 = h_2;
    let _e56 = hueToRgb(_e49, _e50, (_e51 + 0.33333334f));
    r = max(0f, _e56);
    let _e60 = p_2;
    let _e61 = q_2;
    let _e62 = h_2;
    let _e63 = hueToRgb(_e60, _e61, _e62);
    g = max(0f, _e63);
    let _e67 = p_2;
    let _e68 = q_2;
    let _e69 = h_2;
    let _e74 = hueToRgb(_e67, _e68, (_e69 - 0.33333334f));
    b = max(0f, _e74);
    let _e79 = r;
    outc.x = min(_e79, 1f);
    let _e83 = g;
    outc.y = min(_e83, 1f);
    let _e87 = b;
    outc.z = min(_e87, 1f);
    let _e91 = inc_1;
    outc.w = _e91.w;
    let _e93 = outc;
    return _e93;
}

fn swapRGBHSL(rgb: vec4<f32>, mode: f32) -> vec4<f32> {
    var rgb_1: vec4<f32>;
    var mode_1: f32;
    var coding: f32;
    var toHsl: bool;
    var hsl_2: vec4<f32>;
    var rChannel: i32;
    var gChannel: i32;
    var bChannel: i32;
    var local_5: f32;
    var color_4: vec4<f32>;
    var local_6: vec4<f32>;

    rgb_1 = rgb;
    mode_1 = mode;
    let _e10 = mode_1;
    coding = floor(((((((_e10 * 0.01f) * 2f) * 6f) * 6f) * 6f) - 1f));
    let _e25 = coding;
    toHsl = (_e25 > 215f);
    let _e29 = toHsl;
    if _e29 {
        let _e30 = coding;
        coding = (_e30 - (floor((_e30 / 216f)) * 216f));
    }
    let _e36 = rgb_1;
    let _e37 = rgbToHsl(_e36);
    hsl_2 = _e37;
    let _e40 = hsl_2;
    hsl_2.x = (_e40.x / 360f);
    let _e44 = coding;
    rChannel = i32((_e44 - (floor((_e44 / 6f)) * 6f)));
    let _e52 = coding;
    let _e54 = (_e52 / 6f);
    gChannel = i32((_e54 - (floor((_e54 / 6f)) * 6f)));
    let _e62 = coding;
    let _e64 = (_e62 / 36f);
    bChannel = i32((_e64 - (floor((_e64 / 6f)) * 6f)));
    let _e72 = rgb_1;
    let _e73 = hsl_2;
    let _e74 = rChannel;
    let _e75 = getChannelWithHsl(_e72, _e73, _e74);
    let _e76 = toHsl;
    if _e76 {
        local_5 = 360f;
    } else {
        local_5 = 1f;
    }
    let _e80 = local_5;
    let _e82 = rgb_1;
    let _e83 = hsl_2;
    let _e84 = gChannel;
    let _e85 = getChannelWithHsl(_e82, _e83, _e84);
    let _e86 = rgb_1;
    let _e87 = hsl_2;
    let _e88 = bChannel;
    let _e89 = getChannelWithHsl(_e86, _e87, _e88);
    let _e90 = rgb_1;
    color_4 = vec4<f32>((_e75 * _e80), _e85, _e89, _e90.w);
    let _e94 = toHsl;
    if _e94 {
        let _e95 = color_4;
        let _e96 = hslToRgb(_e95);
        local_6 = _e96;
    } else {
        let _e97 = color_4;
        local_6 = _e97;
    }
    let _e99 = local_6;
    return _e99;
}

fn tf(m_1: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_2: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_2 = m_1;
    u_1 = u;
    let _e10 = m_2;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn blockBW(pos_2: vec2<f32>, outPos: vec2<f32>, mode_2: i32, count: i32, randomSeed: f32, sourceDim: vec2<f32>, objectTransform: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_3: i32;
    var count_1: i32;
    var randomSeed_1: f32;
    var sourceDim_1: vec2<f32>;
    var objectTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var inCol: vec4<f32>;
    var outCol: vec4<f32>;
    var ratio: f32;
    var dim_2: vec2<f32>;
    var blockSize_2: vec2<f32>;
    var columns_1: f32;
    var lines_1: f32;
    var blocks: f32;
    var uv: vec2<f32>;
    var index: f32;
    var offset: f32;
    var scale: f32;
    var i: i32 = 0i;
    var rnd: vec2<f32>;
    var center: f32;
    var local_7: f32;
    var bSize: f32;
    var ind1_: f32;
    var ind2_: f32;
    var inside: bool;
    var subMode: f32;
    var g_1: f32;
    var local_8: f32;
    var local_9: f32;
    var local_10: f32;
    var local_11: f32;
    var local_12: f32;
    var local_13: f32;
    var local_14: f32;
    var local_15: f32;
    var local_16: f32;
    var local_17: f32;
    var local_18: f32;
    var mode_4: f32;
    var channel_4: i32;
    var delta: vec2<f32>;
    var delta_1: vec2<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    mode_3 = mode_2;
    count_1 = count;
    randomSeed_1 = randomSeed;
    sourceDim_1 = sourceDim;
    objectTransform_1 = objectTransform;
    modelTransform_1 = modelTransform;
    let _e22 = pos_3;
    let _e26 = global.U[0];
    let _e29 = pos_3;
    let _e39 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e22.x / _e26.x), _e29.y) / vec2(2f)) + vec2(0.5f)), 0f);
    inCol = _e39;
    let _e41 = inCol;
    outCol = _e41;
    let _e43 = sourceDim_1;
    let _e45 = sourceDim_1;
    ratio = (_e43.x / _e45.y);
    let _e50 = ratio;
    dim_2 = vec2<f32>((2f * _e50), 2f);
    let _e55 = dim_2;
    blockSize_2 = (_e55 / vec2<f32>(160f, 80f));
    let _e61 = dim_2;
    let _e63 = blockSize_2;
    columns_1 = (_e61.x / _e63.x);
    let _e67 = dim_2;
    let _e69 = blockSize_2;
    lines_1 = (_e67.y / _e69.y);
    let _e73 = columns_1;
    let _e74 = lines_1;
    blocks = (_e73 * _e74);
    let _e77 = modelTransform_1;
    let _e79 = pos_3;
    let _e80 = tf(_naga_inverse_3x3_f32(_e77), _e79);
    uv = _e80;
    let _e82 = uv;
    let _e84 = uv;
    let _e87 = (_e84.y + 3f);
    let _e96 = blockSize_2;
    let _e97 = dim_2;
    let _e98 = getIndex(vec2<f32>(_e82.x, ((_e87 - (floor((_e87 / 6f)) * 6f)) - 3f)), _e96, _e97);
    index = _e98;
    let _e100 = randomSeed_1;
    let _e101 = uv;
    randomSeed_1 = (_e100 + floor(((_e101.y + 3f) / 6f)));
    let _e113 = objectTransform_1[2][0];
    let _e116 = columns_1;
    let _e122 = objectTransform_1[2][1];
    let _e125 = lines_1;
    let _e127 = columns_1;
    let _e131 = blocks;
    offset = ((((_e113 * 0.5f) * _e116) + (((_e122 * 0.5f) * _e125) * _e127)) + (0.5f * _e131));
    let _e137 = objectTransform_1[0];
    scale = length(_e137.xy);
    loop {
        let _e143 = i;
        let _e144 = count_1;
        if !((_e143 < _e144)) {
            break;
        }
        {
            let _e151 = i;
            let _e156 = i;
            let _e161 = randomSeed_1;
            let _e164 = sineSurfaceRand2Seeded(vec2<f32>((10f - f32(_e151)), (15f + (5f * f32(_e156)))), (_e161 + 4.46f));
            rnd = _e164;
            let _e166 = offset;
            let _e167 = rnd;
            let _e169 = blocks;
            center = (_e166 + (_e167.x * _e169));
            let _e173 = rnd;
            let _e177 = i;
            if (_e173.x < (-0.5f + (f32(_e177) * 0.1f))) {
                local_7 = 0.5f;
            } else {
                let _e184 = rnd;
                let _e187 = blocks;
                let _e189 = scale;
                local_7 = ((abs(_e184.y) * _e187) * _e189);
            }
            let _e192 = local_7;
            bSize = _e192;
            let _e194 = center;
            let _e195 = bSize;
            ind1_ = (_e194 - _e195);
            let _e198 = center;
            let _e199 = bSize;
            ind2_ = (_e198 + _e199);
            let _e202 = index;
            let _e203 = ind1_;
            let _e205 = index;
            let _e206 = ind2_;
            inside = ((_e202 >= _e203) && (_e205 <= _e206));
            let _e210 = inside;
            if _e210 {
                {
                    let _e211 = mode_3;
                    if (_e211 == 0i) {
                        {
                            let _e214 = rnd;
                            let _e217 = (_e214.x * 15f);
                            subMode = floor((_e217 - (floor((_e217 / 9f)) * 9f)));
                            g_1 = 0f;
                            let _e227 = subMode;
                            if (_e227 == 0f) {
                                {
                                    let _e230 = uv;
                                    let _e234 = randomSeed_1;
                                    let _e235 = rand2relSeeded(floor((_e230 * 320f)), _e234);
                                    if (fract(_e235.x) > 0.5f) {
                                        local_8 = 1f;
                                    } else {
                                        local_8 = 0f;
                                    }
                                    let _e243 = local_8;
                                    g_1 = _e243;
                                }
                            } else {
                                let _e244 = subMode;
                                if (_e244 == 1f) {
                                    {
                                        let _e247 = uv;
                                        let _e251 = randomSeed_1;
                                        let _e252 = rand2relSeeded(floor((_e247 * 160f)), _e251);
                                        if (fract(_e252.x) > 0.5f) {
                                            local_9 = 1f;
                                        } else {
                                            local_9 = 0f;
                                        }
                                        let _e260 = local_9;
                                        g_1 = _e260;
                                    }
                                } else {
                                    let _e261 = subMode;
                                    if (_e261 == 2f) {
                                        {
                                            let _e264 = uv;
                                            if (fract((_e264.x * 40f)) > 0.5f) {
                                                local_10 = 1f;
                                            } else {
                                                local_10 = 0f;
                                            }
                                            let _e274 = local_10;
                                            g_1 = _e274;
                                        }
                                    } else {
                                        let _e275 = subMode;
                                        if (_e275 == 3f) {
                                            {
                                                let _e278 = uv;
                                                if (fract((_e278.x * 80f)) > 0.5f) {
                                                    local_11 = 1f;
                                                } else {
                                                    local_11 = 0f;
                                                }
                                                let _e288 = local_11;
                                                g_1 = _e288;
                                            }
                                        } else {
                                            let _e289 = subMode;
                                            if (_e289 == 6f) {
                                                {
                                                    let _e292 = uv;
                                                    let _e297 = inCol;
                                                    if (fract((_e292.x * 80f)) > (length(_e297.xyz) / 1.7f)) {
                                                        local_12 = 1f;
                                                    } else {
                                                        local_12 = 0f;
                                                    }
                                                    let _e306 = local_12;
                                                    g_1 = _e306;
                                                }
                                            } else {
                                                let _e307 = subMode;
                                                if (_e307 == 7f) {
                                                    {
                                                        let _e310 = uv;
                                                        let _e315 = inCol;
                                                        if (fract((_e310.x * 10f)) < (length(_e315.xyz) / 1.7f)) {
                                                            local_13 = 1f;
                                                        } else {
                                                            local_13 = 0f;
                                                        }
                                                        let _e324 = local_13;
                                                        g_1 = _e324;
                                                    }
                                                } else {
                                                    let _e325 = subMode;
                                                    if (_e325 == 4f) {
                                                        {
                                                            let _e328 = uv;
                                                            if (fract((_e328.x * 80f)) > 0.5f) {
                                                                local_14 = 1f;
                                                            } else {
                                                                local_14 = 0f;
                                                            }
                                                            let _e338 = local_14;
                                                            let _e339 = uv;
                                                            if (fract((_e339.y * 40f)) > 0.5f) {
                                                                local_15 = 1f;
                                                            } else {
                                                                local_15 = 0f;
                                                            }
                                                            let _e349 = local_15;
                                                            let _e350 = (_e338 + _e349);
                                                            g_1 = (_e350 - (floor((_e350 / 2f)) * 2f));
                                                        }
                                                    } else {
                                                        let _e356 = subMode;
                                                        if (_e356 == 5f) {
                                                            {
                                                                let _e359 = uv;
                                                                let _e363 = randomSeed_1;
                                                                let _e364 = rand2relSeeded(floor((_e359 * 160f)), _e363);
                                                                let _e367 = inCol;
                                                                if (fract(_e364.x) < (length(_e367.xyz) / 1.7f)) {
                                                                    local_16 = 1f;
                                                                } else {
                                                                    local_16 = 0f;
                                                                }
                                                                let _e376 = local_16;
                                                                g_1 = _e376;
                                                            }
                                                        } else {
                                                            {
                                                                let _e377 = uv;
                                                                if (fract((_e377.x * 40f)) > 0.5f) {
                                                                    local_17 = 1f;
                                                                } else {
                                                                    local_17 = 0f;
                                                                }
                                                                let _e387 = local_17;
                                                                let _e388 = uv;
                                                                if (fract((_e388.y * 20f)) > 0.5f) {
                                                                    local_18 = 1f;
                                                                } else {
                                                                    local_18 = 0f;
                                                                }
                                                                let _e398 = local_18;
                                                                let _e399 = (_e387 + _e398);
                                                                g_1 = (_e399 - (floor((_e399 / 2f)) * 2f));
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            let _e405 = g_1;
                            let _e406 = g_1;
                            let _e407 = g_1;
                            outCol = vec4<f32>(_e405, _e406, _e407, 1f);
                        }
                    } else {
                        let _e410 = mode_3;
                        if (_e410 == 1i) {
                            {
                                let _e413 = rnd;
                                mode_4 = ((_e413.x + 0.5f) * 4096f);
                                let _e420 = outCol;
                                let _e421 = mode_4;
                                let _e422 = swapRGBHSL(_e420, _e421);
                                outCol = _e422;
                            }
                        } else {
                            let _e423 = mode_3;
                            if (_e423 == 2i) {
                                {
                                    let _e426 = rnd;
                                    let _e429 = (_e426.x * 100f);
                                    channel_4 = i32((_e429 - (floor((_e429 / 3f)) * 3f)));
                                    let _e437 = rnd;
                                    delta = ((fract((_e437 * 10f)) * 2f) - vec2<f32>(1f, 1f));
                                    let _e448 = channel_4;
                                    let _e450 = channel_4;
                                    let _e451 = pos_3;
                                    let _e452 = delta;
                                    let _e457 = global.U[0];
                                    let _e460 = pos_3;
                                    let _e461 = delta;
                                    let _e472 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e451 + _e452).x / _e457.x), (_e460 + _e461).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    outCol[_e448] = _e472[_e450];
                                }
                            } else {
                                let _e474 = mode_3;
                                if (_e474 == 3i) {
                                    {
                                        let _e477 = rnd;
                                        delta_1 = ((fract((_e477 * 10f)) * 2f) - vec2<f32>(1f, 1f));
                                        let _e488 = pos_3;
                                        let _e489 = delta_1;
                                        let _e494 = global.U[0];
                                        let _e497 = pos_3;
                                        let _e498 = delta_1;
                                        let _e509 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e488 + _e489).x / _e494.x), (_e497 + _e498).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        outCol = _e509;
                                    }
                                }
                            }
                        }
                    }
                    let _e510 = outCol;
                    return _e510;
                }
            }
        }
        continuing {
            let _e147 = i;
            i = (_e147 + 1i);
        }
    }
    let _e511 = inCol;
    return _e511;
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
    let _e76 = global.U[8];
    let _e80 = global.U[4];
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e92 = global.U[11];
    let _e93 = _e92.xyz;
    let _e109 = global.U[12];
    let _e110 = _e109.xyz;
    let _e113 = global.U[13];
    let _e114 = _e113.xyz;
    let _e117 = global.U[14];
    let _e118 = _e117.xyz;
    let _e132 = blockBW((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.xy, mat3x3<f32>(vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z)), mat3x3<f32>(vec3<f32>(_e110.x, _e110.y, _e110.z), vec3<f32>(_e114.x, _e114.y, _e114.z), vec3<f32>(_e118.x, _e118.y, _e118.z)));
    fragColor = _e132;
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
