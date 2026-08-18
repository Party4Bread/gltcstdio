struct Params {
    U: array<vec4<f32>, 26>,
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
var t_insideImage: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn hsluv_lengthOfRayUntilIntersect(theta: f32, x: vec3<f32>, y: vec3<f32>) -> vec3<f32> {
    var theta_1: f32;
    var x_1: vec3<f32>;
    var y_1: vec3<f32>;
    var len: vec3<f32>;

    theta_1 = theta;
    x_1 = x;
    y_1 = y;
    let _e13 = y_1;
    let _e14 = theta_1;
    let _e16 = x_1;
    let _e17 = theta_1;
    len = (_e13 / (vec3(sin(_e14)) - (_e16 * cos(_e17))));
    let _e24 = len;
    if (_e24.x < 0f) {
        {
            len.x = 1000f;
        }
    }
    let _e30 = len;
    if (_e30.y < 0f) {
        {
            len.y = 1000f;
        }
    }
    let _e36 = len;
    if (_e36.z < 0f) {
        {
            len.z = 1000f;
        }
    }
    let _e42 = len;
    return _e42;
}

fn hsluv_maxChromaForLH(L: f32, H: f32) -> f32 {
    var L_1: f32;
    var H_1: f32;
    var hrad: f32;
    var m2_: mat3x3<f32> = mat3x3<f32>(vec3<f32>(3.24097f, -0.96924365f, 0.05563008f), vec3<f32>(-1.5373832f, 1.8759675f, -0.20397696f), vec3<f32>(-0.49861076f, 0.04155506f, 1.0569715f));
    var sub1_: f32;
    var local: f32;
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

    L_1 = L;
    H_1 = H;
    let _e11 = H_1;
    hrad = radians(_e11);
    let _e32 = L_1;
    sub1_ = (pow((_e32 + 16f), 3f) / 1560896f);
    let _e40 = sub1_;
    if (_e40 > 0.008856452f) {
        let _e43 = sub1_;
        local = _e43;
    } else {
        let _e44 = L_1;
        local = (_e44 / 903.2963f);
    }
    let _e48 = local;
    sub2_ = _e48;
    let _e53 = m2_[0];
    let _e58 = m2_[2];
    let _e61 = sub2_;
    top1_ = (((284517f * _e53) - (94839f * _e58)) * _e61);
    let _e67 = m2_[2];
    let _e72 = m2_[1];
    let _e75 = sub2_;
    bottom = (((632260f * _e67) - (126452f * _e72)) * _e75);
    let _e81 = m2_[2];
    let _e86 = m2_[1];
    let _e92 = m2_[0];
    let _e95 = L_1;
    let _e97 = sub2_;
    top2_ = (((((838422f * _e81) + (769860f * _e86)) + (731718f * _e92)) * _e95) * _e97);
    let _e100 = top1_;
    let _e101 = bottom;
    bound0x = (_e100 / _e101);
    let _e104 = top2_;
    let _e105 = bottom;
    bound0y = (_e104 / _e105);
    let _e108 = top1_;
    let _e109 = bottom;
    bound1x = (_e108 / (_e109 + vec3(126452f)));
    let _e115 = top2_;
    let _e117 = L_1;
    let _e121 = bottom;
    bound1y = ((_e115 - vec3((769860f * _e117))) / (_e121 + vec3(126452f)));
    let _e127 = hrad;
    let _e128 = bound0x;
    let _e129 = bound0y;
    let _e130 = hsluv_lengthOfRayUntilIntersect(_e127, _e128, _e129);
    lengths0_ = _e130;
    let _e132 = hrad;
    let _e133 = bound1x;
    let _e134 = bound1y;
    let _e135 = hsluv_lengthOfRayUntilIntersect(_e132, _e133, _e134);
    lengths1_ = _e135;
    let _e137 = lengths0_;
    let _e139 = lengths1_;
    let _e141 = lengths0_;
    let _e143 = lengths1_;
    let _e145 = lengths0_;
    let _e147 = lengths1_;
    return min(_e137.x, min(_e139.x, min(_e141.y, min(_e143.y, min(_e145.z, _e147.z)))));
}

fn hsluvToLch(tuple: vec3<f32>) -> vec3<f32> {
    var tuple_1: vec3<f32>;

    tuple_1 = tuple;
    let _e10 = tuple_1;
    let _e12 = tuple_1;
    let _e14 = tuple_1;
    let _e16 = hsluv_maxChromaForLH(_e12.z, _e14.x);
    tuple_1.y = (_e10.y * (_e16 * 0.01f));
    let _e20 = tuple_1;
    return _e20.zyx;
}

fn lchToLuv(tuple_2: vec3<f32>) -> vec3<f32> {
    var tuple_3: vec3<f32>;
    var hrad_1: f32;

    tuple_3 = tuple_2;
    let _e9 = tuple_3;
    hrad_1 = radians(_e9.z);
    let _e13 = tuple_3;
    let _e15 = hrad_1;
    let _e17 = tuple_3;
    let _e20 = hrad_1;
    let _e22 = tuple_3;
    return vec3<f32>(_e13.x, (cos(_e15) * _e17.y), (sin(_e20) * _e22.y));
}

fn hsluv_lToY(L_2: f32) -> f32 {
    var L_3: f32;
    var local_1: f32;

    L_3 = L_2;
    let _e9 = L_3;
    if (_e9 <= 8f) {
        let _e12 = L_3;
        local_1 = (_e12 / 903.2963f);
    } else {
        let _e15 = L_3;
        local_1 = pow(((_e15 + 16f) / 116f), 3f);
    }
    let _e23 = local_1;
    return _e23;
}

fn luvToXyz(tuple_4: vec3<f32>) -> vec3<f32> {
    var tuple_5: vec3<f32>;
    var L_4: f32;
    var U: f32;
    var V: f32;
    var Y: f32;
    var X: f32;
    var Z: f32;

    tuple_5 = tuple_4;
    let _e9 = tuple_5;
    L_4 = _e9.x;
    let _e12 = tuple_5;
    let _e15 = L_4;
    U = ((_e12.y / (13f * _e15)) + 0.19783f);
    let _e21 = tuple_5;
    let _e24 = L_4;
    V = ((_e21.z / (13f * _e24)) + 0.46831998f);
    let _e30 = L_4;
    let _e31 = hsluv_lToY(_e30);
    Y = _e31;
    let _e34 = U;
    let _e36 = Y;
    let _e38 = V;
    X = (((2.25f * _e34) * _e36) / _e38);
    let _e42 = V;
    let _e46 = Y;
    let _e48 = X;
    Z = ((((3f / _e42) - 5f) * _e46) - (_e48 / 3f));
    let _e53 = X;
    let _e54 = Y;
    let _e55 = Z;
    return vec3<f32>(_e53, _e54, _e55);
}

fn hsluv_fromLinear1_(c_2: f32) -> f32 {
    var c_3: f32;
    var local_2: f32;

    c_3 = c_2;
    let _e9 = c_3;
    if (_e9 <= 0.0031308f) {
        let _e13 = c_3;
        local_2 = (12.92f * _e13);
    } else {
        let _e16 = c_3;
        local_2 = ((1.055f * pow(_e16, 0.41666666f)) - 0.055f);
    }
    let _e25 = local_2;
    return _e25;
}

fn hsluv_fromLinear(c_4: vec3<f32>) -> vec3<f32> {
    var c_5: vec3<f32>;

    c_5 = c_4;
    let _e9 = c_5;
    let _e11 = hsluv_fromLinear1_(_e9.x);
    let _e12 = c_5;
    let _e14 = hsluv_fromLinear1_(_e12.y);
    let _e15 = c_5;
    let _e17 = hsluv_fromLinear1_(_e15.z);
    return vec3<f32>(_e11, _e14, _e17);
}

fn xyzToRgb(tuple_6: vec3<f32>) -> vec3<f32> {
    var tuple_7: vec3<f32>;
    var m: mat3x3<f32> = mat3x3<f32>(vec3<f32>(3.24097f, -1.5373832f, -0.49861076f), vec3<f32>(-0.96924365f, 1.8759675f, 0.04155506f), vec3<f32>(0.05563008f, -0.20397696f, 1.0569715f));

    tuple_7 = tuple_6;
    let _e27 = tuple_7;
    let _e28 = m;
    let _e30 = hsluv_fromLinear((_e27 * _e28));
    return _e30;
}

fn lchToRgb(tuple_8: vec3<f32>) -> vec3<f32> {
    var tuple_9: vec3<f32>;

    tuple_9 = tuple_8;
    let _e9 = tuple_9;
    let _e10 = lchToLuv(_e9);
    let _e11 = luvToXyz(_e10);
    let _e12 = xyzToRgb(_e11);
    return _e12;
}

fn hsluvToRgb(tuple_10: vec3<f32>) -> vec3<f32> {
    var tuple_11: vec3<f32>;

    tuple_11 = tuple_10;
    let _e9 = tuple_11;
    let _e10 = hsluvToLch(_e9);
    let _e11 = lchToRgb(_e10);
    return _e11;
}

fn lchToHsluv(tuple_12: vec3<f32>) -> vec3<f32> {
    var tuple_13: vec3<f32>;

    tuple_13 = tuple_12;
    let _e10 = tuple_13;
    let _e12 = tuple_13;
    let _e14 = tuple_13;
    let _e16 = hsluv_maxChromaForLH(_e12.x, _e14.z);
    tuple_13.y = (_e10.y / (_e16 * 0.01f));
    let _e20 = tuple_13;
    return _e20.zyx;
}

fn luvToLch(tuple_14: vec3<f32>) -> vec3<f32> {
    var tuple_15: vec3<f32>;
    var L_5: f32;
    var U_1: f32;
    var V_1: f32;
    var C: f32;
    var H_2: f32;

    tuple_15 = tuple_14;
    let _e9 = tuple_15;
    L_5 = _e9.x;
    let _e12 = tuple_15;
    U_1 = _e12.y;
    let _e15 = tuple_15;
    V_1 = _e15.z;
    let _e18 = tuple_15;
    C = length(_e18.yz);
    let _e22 = V_1;
    let _e23 = U_1;
    H_2 = degrees(atan2(_e22, _e23));
    let _e27 = H_2;
    if (_e27 < 0f) {
        {
            let _e31 = H_2;
            H_2 = (360f + _e31);
        }
    }
    let _e33 = L_5;
    let _e34 = C;
    let _e35 = H_2;
    return vec3<f32>(_e33, _e34, _e35);
}

fn hsluv_toLinear1_(c_6: f32) -> f32 {
    var c_7: f32;
    var local_3: f32;

    c_7 = c_6;
    let _e9 = c_7;
    if (_e9 > 0.04045f) {
        let _e12 = c_7;
        local_3 = pow(((_e12 + 0.055f) / 1.055f), 2.4f);
    } else {
        let _e21 = c_7;
        local_3 = (_e21 / 12.92f);
    }
    let _e25 = local_3;
    return _e25;
}

fn hsluv_toLinear(c_8: vec3<f32>) -> vec3<f32> {
    var c_9: vec3<f32>;

    c_9 = c_8;
    let _e9 = c_9;
    let _e11 = hsluv_toLinear1_(_e9.x);
    let _e12 = c_9;
    let _e14 = hsluv_toLinear1_(_e12.y);
    let _e15 = c_9;
    let _e17 = hsluv_toLinear1_(_e15.z);
    return vec3<f32>(_e11, _e14, _e17);
}

fn rgbToXyz(tuple_16: vec3<f32>) -> vec3<f32> {
    var tuple_17: vec3<f32>;
    var m_1: mat3x3<f32> = mat3x3<f32>(vec3<f32>(0.4123908f, 0.35758433f, 0.1804808f), vec3<f32>(0.212639f, 0.71516865f, 0.07219232f), vec3<f32>(0.019330818f, 0.11919478f, 0.95053214f));

    tuple_17 = tuple_16;
    let _e23 = tuple_17;
    let _e24 = hsluv_toLinear(_e23);
    let _e25 = m_1;
    return (_e24 * _e25);
}

fn hsluv_yToL(Y_1: f32) -> f32 {
    var Y_2: f32;
    var local_4: f32;

    Y_2 = Y_1;
    let _e9 = Y_2;
    if (_e9 <= 0.008856452f) {
        let _e12 = Y_2;
        local_4 = (_e12 * 903.2963f);
    } else {
        let _e16 = Y_2;
        local_4 = ((116f * pow(_e16, 0.33333334f)) - 16f);
    }
    let _e25 = local_4;
    return _e25;
}

fn xyzToLuv(tuple_18: vec3<f32>) -> vec3<f32> {
    var tuple_19: vec3<f32>;
    var X_1: f32;
    var Y_3: f32;
    var Z_1: f32;
    var L_6: f32;
    var div: f32;

    tuple_19 = tuple_18;
    let _e9 = tuple_19;
    X_1 = _e9.x;
    let _e12 = tuple_19;
    Y_3 = _e12.y;
    let _e15 = tuple_19;
    Z_1 = _e15.z;
    let _e18 = Y_3;
    let _e19 = hsluv_yToL(_e18);
    L_6 = _e19;
    let _e22 = tuple_19;
    div = (1f / dot(_e22, vec3<f32>(1f, 15f, 3f)));
    let _e35 = X_1;
    let _e36 = div;
    let _e42 = Y_3;
    let _e43 = div;
    let _e49 = L_6;
    return (vec3<f32>(1f, ((52f * (_e35 * _e36)) - 2.57179f), ((117f * (_e42 * _e43)) - 6.08816f)) * _e49);
}

fn rgbToLch(tuple_20: vec3<f32>) -> vec3<f32> {
    var tuple_21: vec3<f32>;

    tuple_21 = tuple_20;
    let _e9 = tuple_21;
    let _e10 = rgbToXyz(_e9);
    let _e11 = xyzToLuv(_e10);
    let _e12 = luvToLch(_e11);
    return _e12;
}

fn rgbToHsluv(tuple_22: vec3<f32>) -> vec3<f32> {
    var tuple_23: vec3<f32>;

    tuple_23 = tuple_22;
    let _e9 = tuple_23;
    let _e10 = rgbToLch(_e9);
    let _e11 = lchToHsluv(_e10);
    return _e11;
}

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e13 = h_1;
    if (_e13 < 0f) {
        let _e16 = h_1;
        h_1 = (_e16 + 1f);
    }
    let _e19 = h_1;
    if (_e19 > 1f) {
        let _e22 = h_1;
        h_1 = (_e22 - 1f);
    }
    let _e26 = h_1;
    if ((6f * _e26) < 1f) {
        {
            let _e30 = p_1;
            let _e31 = q_1;
            let _e32 = p_1;
            let _e36 = h_1;
            return (_e30 + (((_e31 - _e32) * 6f) * _e36));
        }
    }
    let _e40 = h_1;
    if ((2f * _e40) < 1f) {
        {
            let _e44 = q_1;
            return _e44;
        }
    }
    let _e46 = h_1;
    if ((3f * _e46) < 2f) {
        {
            let _e50 = p_1;
            let _e51 = q_1;
            let _e52 = p_1;
            let _e59 = h_1;
            return (_e50 + (((_e51 - _e52) * 6f) * (0.6666667f - _e59)));
        }
    }
    let _e63 = p_1;
    return _e63;
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
    let _e9 = inc_1;
    h_2 = (_e9.x - (floor((_e9.x / 360f)) * 360f));
    let _e17 = h_2;
    h_2 = (_e17 / 360f);
    let _e20 = inc_1;
    s = _e20.y;
    let _e23 = inc_1;
    l = _e23.z;
    let _e28 = l;
    if (_e28 < 0.5f) {
        let _e31 = l;
        let _e33 = s;
        q_2 = (_e31 * (1f + _e33));
    } else {
        let _e36 = l;
        let _e37 = s;
        let _e39 = s;
        let _e40 = l;
        q_2 = ((_e36 + _e37) - (_e39 * _e40));
    }
    let _e44 = l;
    let _e46 = q_2;
    p_2 = ((2f * _e44) - _e46);
    let _e50 = p_2;
    let _e51 = q_2;
    let _e52 = h_2;
    let _e57 = hueToRgb(_e50, _e51, (_e52 + 0.33333334f));
    r = max(0f, _e57);
    let _e61 = p_2;
    let _e62 = q_2;
    let _e63 = h_2;
    let _e64 = hueToRgb(_e61, _e62, _e63);
    g = max(0f, _e64);
    let _e68 = p_2;
    let _e69 = q_2;
    let _e70 = h_2;
    let _e75 = hueToRgb(_e68, _e69, (_e70 - 0.33333334f));
    b = max(0f, _e75);
    let _e80 = r;
    outc.x = min(_e80, 1f);
    let _e84 = g;
    outc.y = min(_e84, 1f);
    let _e88 = b;
    outc.z = min(_e88, 1f);
    let _e92 = inc_1;
    outc.w = _e92.w;
    let _e94 = outc;
    return _e94;
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local_5: vec4<f32>;
    var P: vec4<f32>;
    var local_6: vec4<f32>;
    var Q: vec4<f32>;
    var C_1: f32;
    var H_3: f32;

    RGB_1 = RGB;
    let _e9 = RGB_1;
    let _e11 = RGB_1;
    if (_e9.y < _e11.z) {
        let _e14 = RGB_1;
        let _e15 = _e14.zy;
        local_5 = vec4<f32>(_e15.x, _e15.y, -1f, 0.6666667f);
    } else {
        let _e24 = RGB_1;
        let _e25 = _e24.yz;
        local_5 = vec4<f32>(_e25.x, _e25.y, 0f, -0.33333334f);
    }
    let _e35 = local_5;
    P = _e35;
    let _e37 = RGB_1;
    let _e39 = P;
    if (_e37.x < _e39.x) {
        let _e42 = P;
        let _e43 = _e42.xyw;
        let _e44 = RGB_1;
        local_6 = vec4<f32>(_e43.x, _e43.y, _e43.z, _e44.x);
    } else {
        let _e50 = RGB_1;
        let _e52 = P;
        let _e53 = _e52.yzx;
        local_6 = vec4<f32>(_e50.x, _e53.x, _e53.y, _e53.z);
    }
    let _e59 = local_6;
    Q = _e59;
    let _e61 = Q;
    let _e63 = Q;
    let _e65 = Q;
    C_1 = (_e61.x - min(_e63.w, _e65.y));
    let _e70 = Q;
    let _e72 = Q;
    let _e76 = C_1;
    let _e81 = Q;
    H_3 = abs((((_e70.w - _e72.y) / ((6f * _e76) + 0.0000000001f)) + _e81.z));
    let _e86 = H_3;
    let _e87 = C_1;
    let _e88 = Q;
    let _e90 = RGB_1;
    return vec4<f32>(_e86, _e87, _e88.x, _e90.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L_7: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e9 = RGB_3;
    let _e10 = rgbToHcv(_e9);
    HCV = _e10;
    let _e12 = HCV;
    let _e14 = HCV;
    L_7 = (_e12.z - (_e14.y * 0.5f));
    let _e20 = HCV;
    let _e23 = L_7;
    S = (_e20.y / ((1f - abs(((_e23 * 2f) - 1f))) + 0.000001f));
    let _e34 = HCV;
    let _e38 = S;
    let _e39 = L_7;
    let _e40 = RGB_3;
    return vec4<f32>((_e34.x * 360f), _e38, _e39, _e40.w);
}

fn tintColor(col: vec4<f32>, tint: vec4<f32>) -> vec4<f32> {
    var col_1: vec4<f32>;
    var tint_1: vec4<f32>;
    var colHsl: vec3<f32>;
    var tintHsl: vec3<f32>;
    var gamma: f32;
    var target_: vec4<f32>;

    col_1 = col;
    tint_1 = tint;
    let _e11 = col_1;
    let _e12 = rgbToHsl(_e11);
    colHsl = _e12.xyz;
    let _e15 = tint_1;
    let _e16 = rgbToHsl(_e15);
    tintHsl = _e16.xyz;
    let _e21 = tintHsl;
    gamma = pow(5f, (0.5f - _e21.z));
    let _e26 = tintHsl;
    let _e27 = _e26.xy;
    let _e28 = colHsl;
    let _e30 = gamma;
    let _e32 = col_1;
    let _e37 = hslToRgb(vec4<f32>(_e27.x, _e27.y, pow(_e28.z, _e30), _e32.w));
    target_ = _e37;
    let _e39 = col_1;
    let _e40 = target_;
    let _e41 = tint_1;
    return mix(_e39, _e40, vec4(_e41.w));
}

fn adjustColorHSLuv(col_2: vec4<f32>, brightness: f32, contrast: f32, luminosity: f32, gamma_1: f32, saturation: f32, hue: f32, tint_2: vec4<f32>) -> vec4<f32> {
    var col_3: vec4<f32>;
    var brightness_1: f32;
    var contrast_1: f32;
    var luminosity_1: f32;
    var gamma_2: f32;
    var saturation_1: f32;
    var hue_1: f32;
    var tint_3: vec4<f32>;
    var p_3: f32;
    var local_7: f32;
    var c_10: f32;
    var white: bool;
    var requireHsl: bool;
    var hsl: vec3<f32>;

    col_3 = col_2;
    brightness_1 = brightness;
    contrast_1 = contrast;
    luminosity_1 = luminosity;
    gamma_2 = gamma_1;
    saturation_1 = saturation;
    hue_1 = hue;
    tint_3 = tint_2;
    let _e23 = luminosity_1;
    if (_e23 != 0f) {
        {
            let _e26 = col_3;
            let _e28 = col_3;
            let _e30 = luminosity_1;
            let _e32 = (_e28.xyz + vec3(_e30));
            col_3.x = _e32.x;
            col_3.y = _e32.y;
            col_3.z = _e32.z;
        }
    }
    let _e39 = brightness_1;
    if (_e39 != 0f) {
        {
            let _e42 = col_3;
            let _e44 = col_3;
            let _e47 = brightness_1;
            let _e49 = (_e44.xyz * (1f + _e47));
            col_3.x = _e49.x;
            col_3.y = _e49.y;
            col_3.z = _e49.z;
        }
    }
    let _e56 = gamma_2;
    if (_e56 != 0f) {
        {
            let _e60 = gamma_2;
            p_3 = pow(2f, -(_e60));
            let _e65 = col_3;
            let _e67 = p_3;
            col_3.x = pow(_e65.x, _e67);
            let _e70 = col_3;
            let _e72 = p_3;
            col_3.y = pow(_e70.y, _e72);
            let _e75 = col_3;
            let _e77 = p_3;
            col_3.z = pow(_e75.z, _e77);
        }
    }
    let _e79 = contrast_1;
    if (_e79 != 0f) {
        {
            let _e82 = contrast_1;
            if (abs(_e82) > 1f) {
                let _e86 = contrast_1;
                let _e88 = contrast_1;
                local_7 = (sign(_e86) * pow(abs(_e88), 2f));
            } else {
                let _e93 = contrast_1;
                local_7 = _e93;
            }
            let _e95 = local_7;
            c_10 = _e95;
            let _e97 = col_3;
            let _e99 = col_3;
            let _e104 = c_10;
            let _e108 = (((_e99.xyz - vec3(0.5f)) * _e104) + vec3(0.5f));
            col_3.x = _e108.x;
            col_3.y = _e108.y;
            col_3.z = _e108.z;
        }
    }
    let _e115 = col_3;
    let _e119 = col_3;
    let _e124 = col_3;
    white = (((_e115.x == 1f) && (_e119.y == 1f)) && (_e124.z == 1f));
    let _e130 = saturation_1;
    let _e133 = hue_1;
    let _e137 = white;
    requireHsl = (((_e130 != 0f) || (_e133 != 0f)) && !(_e137));
    let _e141 = requireHsl;
    if _e141 {
        {
            let _e142 = col_3;
            let _e144 = rgbToHsluv(_e142.xyz);
            hsl = _e144;
            let _e150 = hsl.y;
            let _e152 = saturation_1;
            hsl[1i] = clamp((_e150 * (1f + _e152)), 0f, 100f);
            let _e162 = hsl.x;
            let _e163 = hue_1;
            hsl[0i] = (_e162 + _e163);
            let _e165 = col_3;
            let _e167 = hsl;
            let _e168 = hsluvToRgb(_e167);
            col_3.x = _e168.x;
            col_3.y = _e168.y;
            col_3.z = _e168.z;
        }
    }
    let _e175 = tint_3;
    if (_e175.w != 0f) {
        {
            let _e179 = col_3;
            let _e180 = tint_3;
            let _e181 = tintColor(_e179, _e180);
            col_3 = _e181;
        }
    }
    let _e182 = col_3;
    return _e182;
}

fn dimFromShapeAspectRatio(m_2: f32, ar: f32) -> vec2<f32> {
    var m_3: f32;
    var ar_1: f32;
    var local_8: vec2<f32>;

    m_3 = m_2;
    ar_1 = ar;
    let _e11 = ar_1;
    if (_e11 > 1f) {
        let _e14 = m_3;
        let _e15 = m_3;
        let _e16 = ar_1;
        local_8 = vec2<f32>(_e14, (_e15 / _e16));
    } else {
        let _e19 = m_3;
        let _e20 = ar_1;
        let _e22 = m_3;
        local_8 = vec2<f32>((_e19 * _e20), _e22);
    }
    let _e25 = local_8;
    return _e25;
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn mergeGlow(bkg_2: vec4<f32>, glow: vec4<f32>) -> vec4<f32> {
    var bkg_3: vec4<f32>;
    var glow_1: vec4<f32>;

    bkg_3 = bkg_2;
    glow_1 = glow;
    let _e11 = bkg_3;
    let _e13 = glow_1;
    let _e15 = glow_1;
    let _e18 = (_e11.xyz + (_e13.xyz * _e15.w));
    let _e19 = bkg_3;
    return vec4<f32>(_e18.x, _e18.y, _e18.z, _e19.w);
}

fn sdDisk(u: vec2<f32>, r_1: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_2: f32;

    u_1 = u;
    r_2 = r_1;
    let _e11 = u_1;
    let _e13 = r_2;
    return (length(_e11) - _e13);
}

fn sdEquiTriangle(u_2: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;

    u_3 = u_2;
    let _e10 = u_3;
    u_3.x = (abs(_e10.x) - 1f);
    let _e16 = u_3;
    u_3.y = (_e16.y + 0.57735026f);
    let _e22 = u_3;
    let _e25 = u_3;
    if ((_e22.x + (1.7320508f * _e25.y)) > 0f) {
        let _e31 = u_3;
        let _e34 = u_3;
        let _e40 = u_3;
        let _e43 = u_3;
        u_3 = (vec2<f32>((_e31.x - (1.7320508f * _e34.y)), ((-1.7320508f * _e40.x) - _e43.y)) / vec2(2f));
    }
    let _e51 = u_3;
    let _e53 = u_3;
    u_3.x = (_e51.x - clamp(_e53.x, -2f, 0f));
    let _e60 = u_3;
    let _e63 = u_3;
    return (-(length(_e60)) * sign(_e63.y));
}

fn dot2_(u_4: vec2<f32>) -> f32 {
    var u_5: vec2<f32>;

    u_5 = u_4;
    let _e9 = u_5;
    let _e10 = u_5;
    return dot(_e9, _e10);
}

fn sdHeart(u_6: vec2<f32>) -> f32 {
    var u_7: vec2<f32>;

    u_7 = u_6;
    let _e10 = u_7;
    u_7.x = abs(_e10.x);
    let _e13 = u_7;
    let _e15 = u_7;
    if ((_e13.y + _e15.x) > 1f) {
        let _e20 = u_7;
        let _e25 = dot2_((_e20 - vec2<f32>(0.25f, 0.75f)));
        return (sqrt(_e25) - 0.35355338f);
    }
    let _e32 = u_7;
    let _e37 = dot2_((_e32 - vec2<f32>(0f, 1f)));
    let _e38 = u_7;
    let _e40 = u_7;
    let _e42 = u_7;
    let _e50 = dot2_((_e38 - vec2((0.5f * max((_e40.x + _e42.y), 0f)))));
    let _e53 = u_7;
    let _e55 = u_7;
    return (sqrt(min(_e37, _e50)) * sign((_e53.x - _e55.y)));
}

fn sdNgon(p_4: vec2<f32>, r_3: f32, n: i32) -> f32 {
    var p_5: vec2<f32>;
    var r_4: f32;
    var n_1: i32;
    var an: f32;
    var bn: f32;

    p_5 = p_4;
    r_4 = r_3;
    n_1 = n;
    let _e14 = n_1;
    an = (3.1415927f / f32(_e14));
    let _e18 = p_5;
    let _e20 = p_5;
    let _e23 = an;
    let _e24 = (atan2(_e18.y, _e20.x) + _e23);
    let _e26 = an;
    let _e27 = (2f * _e26);
    let _e32 = an;
    bn = ((_e24 - (floor((_e24 / _e27)) * _e27)) - _e32);
    let _e35 = p_5;
    let _e37 = bn;
    let _e40 = r_4;
    let _e41 = an;
    return ((length(_e35) * cos(_e37)) - (_e40 * cos(_e41)));
}

fn sdRectangle(u_8: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_9: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local_9: f32;

    u_9 = u_8;
    halfSize_1 = halfSize;
    let _e11 = u_9;
    let _e13 = halfSize_1;
    u_9 = (abs(_e11) - _e13);
    let _e15 = u_9;
    let _e19 = u_9;
    if ((_e15.x >= 0f) && (_e19.y >= 0f)) {
        let _e24 = u_9;
        local_9 = length(_e24);
    } else {
        let _e26 = u_9;
        let _e28 = u_9;
        local_9 = max(_e26.x, _e28.y);
    }
    let _e32 = local_9;
    return _e32;
}

fn sdStar(u_10: vec2<f32>, spikeCount: i32, r_5: f32, m_4: f32) -> f32 {
    var u_11: vec2<f32>;
    var spikeCount_1: i32;
    var r_6: f32;
    var m_5: f32;
    var an_1: f32;
    var en: f32;
    var acs: vec2<f32>;
    var ecs: vec2<f32>;
    var bn_1: f32;

    u_11 = u_10;
    spikeCount_1 = spikeCount;
    r_6 = r_5;
    m_5 = m_4;
    let _e16 = spikeCount_1;
    an_1 = (3.1415927f / f32(_e16));
    let _e21 = m_5;
    en = (3.1415927f / _e21);
    let _e24 = an_1;
    let _e26 = an_1;
    acs = vec2<f32>(cos(_e24), sin(_e26));
    let _e30 = en;
    let _e32 = en;
    ecs = vec2<f32>(cos(_e30), sin(_e32));
    let _e36 = u_11;
    let _e38 = u_11;
    let _e40 = atan2(_e36.x, _e38.y);
    let _e42 = an_1;
    let _e43 = (2f * _e42);
    let _e48 = an_1;
    bn_1 = ((_e40 - (floor((_e40 / _e43)) * _e43)) - _e48);
    let _e51 = u_11;
    let _e53 = bn_1;
    let _e55 = bn_1;
    u_11 = (length(_e51) * vec2<f32>(cos(_e53), abs(sin(_e55))));
    let _e60 = u_11;
    let _e61 = r_6;
    let _e62 = acs;
    u_11 = (_e60 - (_e61 * _e62));
    let _e65 = u_11;
    let _e66 = ecs;
    let _e67 = u_11;
    let _e68 = ecs;
    let _e72 = r_6;
    let _e73 = acs;
    let _e76 = ecs;
    u_11 = (_e65 + (_e66 * clamp(-(dot(_e67, _e68)), 0f, ((_e72 * _e73.y) / _e76.y))));
    let _e82 = u_11;
    let _e84 = u_11;
    return (length(_e82) * sign(_e84.x));
}

fn sdVesica(u_12: vec2<f32>, r_7: f32, d: f32) -> f32 {
    var u_13: vec2<f32>;
    var r_8: f32;
    var d_1: f32;
    var b_1: f32;
    var local_10: f32;

    u_13 = u_12;
    r_8 = r_7;
    d_1 = d;
    let _e13 = u_13;
    u_13 = abs(_e13);
    let _e15 = r_8;
    let _e16 = r_8;
    let _e18 = d_1;
    let _e19 = d_1;
    b_1 = sqrt(((_e15 * _e16) - (_e18 * _e19)));
    let _e24 = u_13;
    let _e26 = b_1;
    let _e28 = d_1;
    let _e30 = u_13;
    let _e32 = b_1;
    if (((_e24.y - _e26) * _e28) > (_e30.x * _e32)) {
        let _e35 = u_13;
        let _e37 = b_1;
        local_10 = length((_e35 - vec2<f32>(0f, _e37)));
    } else {
        let _e41 = u_13;
        let _e42 = d_1;
        let _e48 = r_8;
        local_10 = (length((_e41 - vec2<f32>(-(_e42), 0f))) - _e48);
    }
    let _e51 = local_10;
    return _e51;
}

fn tf(m_6: mat3x3<f32>, u_14: vec2<f32>) -> vec2<f32> {
    var m_7: mat3x3<f32>;
    var u_15: vec2<f32>;

    m_7 = m_6;
    u_15 = u_14;
    let _e11 = m_7;
    let _e12 = u_15;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn iteratedShape(uv: vec2<f32>, outPos: vec2<f32>, insideImage_specified: i32, shape: i32, iterations: i32, shadows: f32, roundness: f32, multiplier: f32, brightness_2: f32, contrast_2: f32, saturation_2: f32, hue_2: f32, colorIn: vec4<f32>, colorOut: vec4<f32>, colorShadow: vec4<f32>, colorGlow: vec4<f32>, insideLock: i32, modelTransform: mat3x3<f32>, insideTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var insideImage_specified_1: i32;
    var shape_1: i32;
    var iterations_1: i32;
    var shadows_1: f32;
    var roundness_1: f32;
    var multiplier_1: f32;
    var brightness_3: f32;
    var contrast_3: f32;
    var saturation_3: f32;
    var hue_3: f32;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var colorGlow_1: vec4<f32>;
    var insideLock_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var insideTransform_1: mat3x3<f32>;
    var u_16: vec2<f32>;
    var local_11: mat3x3<f32>;
    var targetTransform: mat3x3<f32>;
    var iTranslation: vec2<f32>;
    var iScale: vec2<f32>;
    var iRotation: f32;
    var ik: f32;
    var ikRot: f32;
    var d_2: f32 = 0f;
    var shadow: f32 = 0f;
    var tint_4: vec4<f32> = vec4(0f);
    var v: vec2<f32>;
    var inside: bool = false;
    var i: i32 = 0i;
    var inside_1: bool;
    var local_12: f32;
    var insideK: f32;
    var local_13: vec4<f32>;
    var color: vec4<f32>;
    var local_14: vec4<f32>;
    var glow_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    insideImage_specified_1 = insideImage_specified;
    shape_1 = shape;
    iterations_1 = iterations;
    shadows_1 = shadows;
    roundness_1 = roundness;
    multiplier_1 = multiplier;
    brightness_3 = brightness_2;
    contrast_3 = contrast_2;
    saturation_3 = saturation_2;
    hue_3 = hue_2;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    colorShadow_1 = colorShadow;
    colorGlow_1 = colorGlow;
    insideLock_1 = insideLock;
    modelTransform_1 = modelTransform;
    insideTransform_1 = insideTransform;
    let _e45 = modelTransform_1;
    let _e47 = uv_1;
    let _e48 = tf(_naga_inverse_3x3_f32(_e45), _e47);
    u_16 = _e48;
    let _e50 = insideLock_1;
    if (_e50 == 0i) {
        let _e53 = modelTransform_1;
        let _e55 = insideTransform_1;
        local_11 = (_naga_inverse_3x3_f32(_e53) * _e55);
    } else {
        let _e57 = insideTransform_1;
        local_11 = _e57;
    }
    let _e59 = local_11;
    targetTransform = _e59;
    let _e63 = targetTransform[2];
    iTranslation = _e63.xy;
    let _e68 = targetTransform[0];
    let _e73 = targetTransform[1];
    iScale = vec2<f32>(length(_e68.xy), length(_e73.xy));
    let _e80 = targetTransform[0];
    let _e82 = iScale;
    let _e87 = targetTransform[0];
    let _e89 = iScale;
    iRotation = atan2((_e80.y / _e82.x), (_e87.x / _e89.x));
    let _e95 = iterations_1;
    ik = (1f / f32(_e95));
    let _e99 = iRotation;
    let _e100 = ik;
    ikRot = (_e99 * _e100);
    let _e103 = iScale;
    let _e105 = ik;
    let _e110 = iScale;
    let _e112 = ik;
    let _e122 = ikRot;
    let _e124 = ikRot;
    let _e127 = ikRot;
    let _e130 = ikRot;
    targetTransform = (mat3x3<f32>(vec3<f32>(pow(_e103.x, _e105), 0f, 0f), vec3<f32>(0f, pow(_e110.y, _e112), 0f), vec3<f32>(0f, 0f, 1f)) * mat3x3<f32>(vec3<f32>(cos(_e122), sin(_e124), 0f), vec3<f32>(-(sin(_e127)), cos(_e130), 0f), vec3<f32>(0f, 0f, 1f)));
    let _e143 = iTranslation;
    let _e144 = ik;
    let _e145 = (_e143 * _e144);
    targetTransform[2i] = vec3<f32>(_e145.x, _e145.y, 1f);
    let _e150 = targetTransform;
    targetTransform = _naga_inverse_3x3_f32(_e150);
    let _e159 = uv_1;
    v = _e159;
    loop {
        let _e165 = i;
        let _e166 = iterations_1;
        if !((_e165 < _e166)) {
            break;
        }
        {
            let _e172 = shape_1;
            if (_e172 == 0i) {
                {
                    let _e175 = u_16;
                    let _e178 = dimFromShapeAspectRatio(0.8f, 1f);
                    let _e179 = sdRectangle(_e175, _e178);
                    d_2 = _e179;
                }
            } else {
                let _e180 = shape_1;
                if (_e180 == 1i) {
                    {
                        let _e183 = u_16;
                        let _e185 = sdDisk(_e183, 0.8f);
                        d_2 = _e185;
                    }
                } else {
                    let _e186 = shape_1;
                    if (_e186 == 2i) {
                        {
                            let _e189 = u_16;
                            let _e192 = sdEquiTriangle((_e189 * 1f));
                            d_2 = _e192;
                        }
                    } else {
                        let _e193 = shape_1;
                        if (_e193 == 3i) {
                            {
                                let _e196 = u_16;
                                let _e201 = u_16;
                                let _e207 = sdHeart(vec2<f32>((_e196.x * 0.66f), (0.5f - (_e201.y * 0.66f))));
                                d_2 = _e207;
                            }
                        } else {
                            let _e208 = shape_1;
                            if (_e208 == 4i) {
                                {
                                    let _e211 = u_16;
                                    let _e217 = sdVesica(_e211, 0.9f, mix(0.7f, 0f, 0.6f));
                                    d_2 = _e217;
                                }
                            } else {
                                let _e218 = shape_1;
                                if (_e218 == 5i) {
                                    {
                                        let _e221 = u_16;
                                        let _e224 = sdNgon(_e221, 0.8f, 4i);
                                        d_2 = _e224;
                                    }
                                } else {
                                    let _e225 = shape_1;
                                    if (_e225 == 6i) {
                                        {
                                            let _e228 = u_16;
                                            let _e230 = u_16;
                                            let _e243 = sdStar(vec2<f32>(_e228.x, -(_e230.y)), 5i, 0.75f, 3.05f);
                                            d_2 = _e243;
                                        }
                                    } else {
                                        let _e244 = shape_1;
                                        if (_e244 == 7i) {
                                            {
                                                let _e247 = u_16;
                                                let _e249 = u_16;
                                                let _e255 = sdNgon(vec2<f32>(_e247.x, -(_e249.y)), 0.8f, 5i);
                                                d_2 = _e255;
                                            }
                                        } else {
                                            let _e256 = shape_1;
                                            if (_e256 == 8i) {
                                                {
                                                    let _e259 = u_16;
                                                    let _e262 = sdNgon(_e259, 0.8f, 6i);
                                                    d_2 = _e262;
                                                }
                                            } else {
                                                let _e263 = shape_1;
                                                if (_e263 == 9i) {
                                                    {
                                                        let _e266 = u_16;
                                                        let _e268 = u_16;
                                                        let _e281 = sdStar(vec2<f32>(_e266.x, -(_e268.y)), 24i, 0.75f, 5.96f);
                                                        d_2 = _e281;
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
            }
            let _e282 = d_2;
            let _e283 = multiplier_1;
            let _e285 = roundness_1;
            d_2 = ((_e282 * _e283) - _e285);
            let _e287 = d_2;
            inside_1 = (_e287 <= 0f);
            let _e291 = inside_1;
            if _e291 {
                {
                    let _e292 = shadows_1;
                    if (_e292 < 0f) {
                        let _e296 = shadows_1;
                        let _e298 = d_2;
                        shadow = (0.7f * smoothstep(_e296, 0f, _e298));
                    }
                    let _e301 = targetTransform;
                    let _e302 = u_16;
                    let _e303 = tf(_e301, _e302);
                    u_16 = _e303;
                    let _e304 = u_16;
                    v = _e304;
                }
            } else {
                {
                    let _e305 = shadows_1;
                    if (_e305 > 0f) {
                        let _e309 = shadows_1;
                        let _e311 = d_2;
                        shadow = (0.7f * smoothstep(_e309, 0f, _e311));
                    }
                    break;
                }
            }
        }
        continuing {
            let _e169 = i;
            i = (_e169 + 1i);
        }
    }
    let _e314 = i;
    let _e316 = inside;
    if _e316 {
        local_12 = 1f;
    } else {
        local_12 = 0f;
    }
    let _e320 = local_12;
    let _e322 = ik;
    insideK = ((f32(_e314) + _e320) * _e322);
    let _e325 = insideK;
    insideK = pow(_e325, 0.5f);
    let _e328 = colorOut_1;
    let _e329 = colorIn_1;
    let _e330 = insideK;
    tint_4 = mix(_e328, _e329, vec4(_e330));
    let _e333 = insideImage_specified_1;
    let _e336 = inside;
    if ((_e333 == 1i) && _e336) {
        let _e338 = v;
        let _e342 = global.U[0];
        let _e345 = v;
        let _e354 = _mirror_wrap(((vec2<f32>((_e338.x / _e342.x), _e345.y) / vec2(2f)) + vec2(0.5f)));
        let _e355 = textureSample(t_insideImage, samp, _e354);
        local_13 = _e355;
    } else {
        let _e356 = v;
        let _e360 = global.U[0];
        let _e363 = v;
        let _e372 = _mirror_wrap(((vec2<f32>((_e356.x / _e360.x), _e363.y) / vec2(2f)) + vec2(0.5f)));
        let _e373 = textureSample(t_source, samp, _e372);
        local_13 = _e373;
    }
    let _e375 = local_13;
    color = _e375;
    let _e377 = color;
    let _e378 = brightness_3;
    let _e379 = insideK;
    let _e382 = contrast_3;
    let _e383 = insideK;
    let _e387 = saturation_3;
    let _e388 = insideK;
    let _e390 = hue_3;
    let _e391 = insideK;
    let _e395 = adjustColorHSLuv(_e377, (_e378 * _e379), mix(1f, _e382, _e383), 0f, 0f, (_e387 * _e388), (_e390 * _e391), vec4(0f));
    color = _e395;
    let _e396 = colorGlow_1;
    if (_e396.w != 0f) {
        let _e400 = colorGlow_1;
        let _e404 = d_2;
        let _e407 = ((_e400.xyz * 0.01f) / vec3(abs(_e404)));
        let _e409 = colorGlow_1;
        let _e413 = d_2;
        local_14 = vec4<f32>(_e407.x, _e407.y, _e407.z, min(1f, ((_e409.w * 0.01f) / abs(_e413))));
    } else {
        local_14 = vec4(0f);
    }
    let _e424 = local_14;
    glow_2 = _e424;
    let _e426 = color;
    let _e427 = tint_4;
    let _e428 = mergeColor(_e426, _e427);
    let _e429 = colorShadow_1;
    let _e430 = _e429.xyz;
    let _e431 = colorShadow_1;
    let _e433 = shadow;
    let _e439 = mergeColor(_e428, vec4<f32>(_e430.x, _e430.y, _e430.z, (_e431.w * _e433)));
    let _e440 = glow_2;
    let _e441 = mergeGlow(_e439, _e440);
    return _e441;
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
    let _e67 = global.U[4];
    let _e72 = global.U[6];
    let _e77 = global.U[7];
    let _e82 = global.U[8];
    let _e86 = global.U[9];
    let _e90 = global.U[10];
    let _e94 = global.U[11];
    let _e98 = global.U[12];
    let _e102 = global.U[13];
    let _e106 = global.U[14];
    let _e110 = global.U[15];
    let _e113 = global.U[16];
    let _e116 = global.U[17];
    let _e119 = global.U[18];
    let _e122 = global.U[19];
    let _e127 = global.U[20];
    let _e128 = _e127.xyz;
    let _e131 = global.U[21];
    let _e132 = _e131.xyz;
    let _e135 = global.U[22];
    let _e136 = _e135.xyz;
    let _e152 = global.U[23];
    let _e153 = _e152.xyz;
    let _e156 = global.U[24];
    let _e157 = _e156.xyz;
    let _e160 = global.U[25];
    let _e161 = _e160.xyz;
    let _e175 = iteratedShape((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), i32(_e72.x), i32(_e77.x), _e82.x, _e86.x, _e90.x, _e94.x, _e98.x, _e102.x, _e106.x, _e110, _e113, _e116, _e119, i32(_e122.x), mat3x3<f32>(vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z)), mat3x3<f32>(vec3<f32>(_e153.x, _e153.y, _e153.z), vec3<f32>(_e157.x, _e157.y, _e157.z), vec3<f32>(_e161.x, _e161.y, _e161.z)));
    fragColor = _e175;
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
