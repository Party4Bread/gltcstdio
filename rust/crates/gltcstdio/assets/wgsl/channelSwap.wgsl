struct Params {
    U: array<vec4<f32>, 12>,
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

fn hsluv_lengthOfRayUntilIntersect(theta: f32, x: vec3<f32>, y: vec3<f32>) -> vec3<f32> {
    var theta_1: f32;
    var x_1: vec3<f32>;
    var y_1: vec3<f32>;
    var len: vec3<f32>;

    theta_1 = theta;
    x_1 = x;
    y_1 = y;
    let _e12 = y_1;
    let _e13 = theta_1;
    let _e15 = x_1;
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

fn getChannelTest(color: vec4<f32>, channel: i32) -> f32 {
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

fn channelSwap(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, channels_red: i32, channels_green: i32, channels_blue: i32, channels_hue: i32, channels_saturation: i32, channels_luminance: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var channels_red_1: i32;
    var channels_green_1: i32;
    var channels_blue_1: i32;
    var channels_hue_1: i32;
    var channels_saturation_1: i32;
    var channels_luminance_1: i32;
    var col: vec4<f32>;
    var hsl: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    channels_red_1 = channels_red;
    channels_green_1 = channels_green;
    channels_blue_1 = channels_blue;
    channels_hue_1 = channels_hue;
    channels_saturation_1 = channels_saturation;
    channels_luminance_1 = channels_luminance;
    let _e24 = pos_1;
    let _e28 = global.U[0];
    let _e31 = pos_1;
    let _e40 = textureSample(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e31.y) / vec2(2f)) + vec2(0.5f)));
    col = _e40;
    let _e42 = col;
    let _e44 = col;
    let _e45 = channels_red_1;
    let _e46 = getChannelTest(_e44, _e45);
    let _e47 = col;
    let _e48 = channels_green_1;
    let _e49 = getChannelTest(_e47, _e48);
    let _e50 = col;
    let _e51 = channels_blue_1;
    let _e52 = getChannelTest(_e50, _e51);
    let _e53 = vec3<f32>(_e46, _e49, _e52);
    col.x = _e53.x;
    col.y = _e53.y;
    col.z = _e53.z;
    let _e60 = col;
    let _e61 = rgbToHsl(_e60);
    hsl = _e61;
    let _e63 = hsl;
    let _e65 = col;
    let _e66 = channels_hue_1;
    let _e67 = getChannelTest(_e65, _e66);
    let _e70 = col;
    let _e71 = channels_saturation_1;
    let _e72 = getChannelTest(_e70, _e71);
    let _e73 = col;
    let _e74 = channels_luminance_1;
    let _e75 = getChannelTest(_e73, _e74);
    let _e76 = vec3<f32>((_e67 * 360f), _e72, _e75);
    hsl.x = _e76.x;
    hsl.y = _e76.y;
    hsl.z = _e76.z;
    let _e83 = col;
    let _e84 = hsl;
    let _e85 = hslToRgb(_e84);
    let _e86 = intensity_1;
    return mix(_e83, _e85, vec4(_e86));
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
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e85 = global.U[9];
    let _e90 = global.U[10];
    let _e95 = global.U[11];
    let _e98 = channelSwap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), i32(_e75.x), i32(_e80.x), i32(_e85.x), i32(_e90.x), i32(_e95.x));
    fragColor = _e98;
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
