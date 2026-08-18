struct Params {
    U: array<vec4<f32>, 23>,
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
    let _e10 = H_1;
    hrad = radians(_e10);
    let _e31 = L_1;
    sub1_ = (pow((_e31 + 16f), 3f) / 1560896f);
    let _e39 = sub1_;
    if (_e39 > 0.008856452f) {
        let _e42 = sub1_;
        local = _e42;
    } else {
        let _e43 = L_1;
        local = (_e43 / 903.2963f);
    }
    let _e47 = local;
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
    let _e94 = L_1;
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
    let _e116 = L_1;
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

fn hsluvToLch(tuple: vec3<f32>) -> vec3<f32> {
    var tuple_1: vec3<f32>;

    tuple_1 = tuple;
    let _e9 = tuple_1;
    let _e11 = tuple_1;
    let _e13 = tuple_1;
    let _e15 = hsluv_maxChromaForLH(_e11.z, _e13.x);
    tuple_1.y = (_e9.y * (_e15 * 0.01f));
    let _e19 = tuple_1;
    return _e19.zyx;
}

fn lchToLuv(tuple_2: vec3<f32>) -> vec3<f32> {
    var tuple_3: vec3<f32>;
    var hrad_1: f32;

    tuple_3 = tuple_2;
    let _e8 = tuple_3;
    hrad_1 = radians(_e8.z);
    let _e12 = tuple_3;
    let _e14 = hrad_1;
    let _e16 = tuple_3;
    let _e19 = hrad_1;
    let _e21 = tuple_3;
    return vec3<f32>(_e12.x, (cos(_e14) * _e16.y), (sin(_e19) * _e21.y));
}

fn hsluv_lToY(L_2: f32) -> f32 {
    var L_3: f32;
    var local_1: f32;

    L_3 = L_2;
    let _e8 = L_3;
    if (_e8 <= 8f) {
        let _e11 = L_3;
        local_1 = (_e11 / 903.2963f);
    } else {
        let _e14 = L_3;
        local_1 = pow(((_e14 + 16f) / 116f), 3f);
    }
    let _e22 = local_1;
    return _e22;
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
    let _e8 = tuple_5;
    L_4 = _e8.x;
    let _e11 = tuple_5;
    let _e14 = L_4;
    U = ((_e11.y / (13f * _e14)) + 0.19783f);
    let _e20 = tuple_5;
    let _e23 = L_4;
    V = ((_e20.z / (13f * _e23)) + 0.46831998f);
    let _e29 = L_4;
    let _e30 = hsluv_lToY(_e29);
    Y = _e30;
    let _e33 = U;
    let _e35 = Y;
    let _e37 = V;
    X = (((2.25f * _e33) * _e35) / _e37);
    let _e41 = V;
    let _e45 = Y;
    let _e47 = X;
    Z = ((((3f / _e41) - 5f) * _e45) - (_e47 / 3f));
    let _e52 = X;
    let _e53 = Y;
    let _e54 = Z;
    return vec3<f32>(_e52, _e53, _e54);
}

fn hsluv_fromLinear1_(c: f32) -> f32 {
    var c_1: f32;
    var local_2: f32;

    c_1 = c;
    let _e8 = c_1;
    if (_e8 <= 0.0031308f) {
        let _e12 = c_1;
        local_2 = (12.92f * _e12);
    } else {
        let _e15 = c_1;
        local_2 = ((1.055f * pow(_e15, 0.41666666f)) - 0.055f);
    }
    let _e24 = local_2;
    return _e24;
}

fn hsluv_fromLinear(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e8 = c_3;
    let _e10 = hsluv_fromLinear1_(_e8.x);
    let _e11 = c_3;
    let _e13 = hsluv_fromLinear1_(_e11.y);
    let _e14 = c_3;
    let _e16 = hsluv_fromLinear1_(_e14.z);
    return vec3<f32>(_e10, _e13, _e16);
}

fn xyzToRgb(tuple_6: vec3<f32>) -> vec3<f32> {
    var tuple_7: vec3<f32>;
    var m: mat3x3<f32> = mat3x3<f32>(vec3<f32>(3.24097f, -1.5373832f, -0.49861076f), vec3<f32>(-0.96924365f, 1.8759675f, 0.04155506f), vec3<f32>(0.05563008f, -0.20397696f, 1.0569715f));

    tuple_7 = tuple_6;
    let _e26 = tuple_7;
    let _e27 = m;
    let _e29 = hsluv_fromLinear((_e26 * _e27));
    return _e29;
}

fn lchToRgb(tuple_8: vec3<f32>) -> vec3<f32> {
    var tuple_9: vec3<f32>;

    tuple_9 = tuple_8;
    let _e8 = tuple_9;
    let _e9 = lchToLuv(_e8);
    let _e10 = luvToXyz(_e9);
    let _e11 = xyzToRgb(_e10);
    return _e11;
}

fn hsluvToRgb(tuple_10: vec3<f32>) -> vec3<f32> {
    var tuple_11: vec3<f32>;

    tuple_11 = tuple_10;
    let _e8 = tuple_11;
    let _e9 = hsluvToLch(_e8);
    let _e10 = lchToRgb(_e9);
    return _e10;
}

fn lchToHsluv(tuple_12: vec3<f32>) -> vec3<f32> {
    var tuple_13: vec3<f32>;

    tuple_13 = tuple_12;
    let _e9 = tuple_13;
    let _e11 = tuple_13;
    let _e13 = tuple_13;
    let _e15 = hsluv_maxChromaForLH(_e11.x, _e13.z);
    tuple_13.y = (_e9.y / (_e15 * 0.01f));
    let _e19 = tuple_13;
    return _e19.zyx;
}

fn luvToLch(tuple_14: vec3<f32>) -> vec3<f32> {
    var tuple_15: vec3<f32>;
    var L_5: f32;
    var U_1: f32;
    var V_1: f32;
    var C: f32;
    var H_2: f32;

    tuple_15 = tuple_14;
    let _e8 = tuple_15;
    L_5 = _e8.x;
    let _e11 = tuple_15;
    U_1 = _e11.y;
    let _e14 = tuple_15;
    V_1 = _e14.z;
    let _e17 = tuple_15;
    C = length(_e17.yz);
    let _e21 = V_1;
    let _e22 = U_1;
    H_2 = degrees(atan2(_e21, _e22));
    let _e26 = H_2;
    if (_e26 < 0f) {
        {
            let _e30 = H_2;
            H_2 = (360f + _e30);
        }
    }
    let _e32 = L_5;
    let _e33 = C;
    let _e34 = H_2;
    return vec3<f32>(_e32, _e33, _e34);
}

fn hsluv_toLinear1_(c_4: f32) -> f32 {
    var c_5: f32;
    var local_3: f32;

    c_5 = c_4;
    let _e8 = c_5;
    if (_e8 > 0.04045f) {
        let _e11 = c_5;
        local_3 = pow(((_e11 + 0.055f) / 1.055f), 2.4f);
    } else {
        let _e20 = c_5;
        local_3 = (_e20 / 12.92f);
    }
    let _e24 = local_3;
    return _e24;
}

fn hsluv_toLinear(c_6: vec3<f32>) -> vec3<f32> {
    var c_7: vec3<f32>;

    c_7 = c_6;
    let _e8 = c_7;
    let _e10 = hsluv_toLinear1_(_e8.x);
    let _e11 = c_7;
    let _e13 = hsluv_toLinear1_(_e11.y);
    let _e14 = c_7;
    let _e16 = hsluv_toLinear1_(_e14.z);
    return vec3<f32>(_e10, _e13, _e16);
}

fn rgbToXyz(tuple_16: vec3<f32>) -> vec3<f32> {
    var tuple_17: vec3<f32>;
    var m_1: mat3x3<f32> = mat3x3<f32>(vec3<f32>(0.4123908f, 0.35758433f, 0.1804808f), vec3<f32>(0.212639f, 0.71516865f, 0.07219232f), vec3<f32>(0.019330818f, 0.11919478f, 0.95053214f));

    tuple_17 = tuple_16;
    let _e22 = tuple_17;
    let _e23 = hsluv_toLinear(_e22);
    let _e24 = m_1;
    return (_e23 * _e24);
}

fn hsluv_yToL(Y_1: f32) -> f32 {
    var Y_2: f32;
    var local_4: f32;

    Y_2 = Y_1;
    let _e8 = Y_2;
    if (_e8 <= 0.008856452f) {
        let _e11 = Y_2;
        local_4 = (_e11 * 903.2963f);
    } else {
        let _e15 = Y_2;
        local_4 = ((116f * pow(_e15, 0.33333334f)) - 16f);
    }
    let _e24 = local_4;
    return _e24;
}

fn xyzToLuv(tuple_18: vec3<f32>) -> vec3<f32> {
    var tuple_19: vec3<f32>;
    var X_1: f32;
    var Y_3: f32;
    var Z_1: f32;
    var L_6: f32;
    var div: f32;

    tuple_19 = tuple_18;
    let _e8 = tuple_19;
    X_1 = _e8.x;
    let _e11 = tuple_19;
    Y_3 = _e11.y;
    let _e14 = tuple_19;
    Z_1 = _e14.z;
    let _e17 = Y_3;
    let _e18 = hsluv_yToL(_e17);
    L_6 = _e18;
    let _e21 = tuple_19;
    div = (1f / dot(_e21, vec3<f32>(1f, 15f, 3f)));
    let _e34 = X_1;
    let _e35 = div;
    let _e41 = Y_3;
    let _e42 = div;
    let _e48 = L_6;
    return (vec3<f32>(1f, ((52f * (_e34 * _e35)) - 2.57179f), ((117f * (_e41 * _e42)) - 6.08816f)) * _e48);
}

fn rgbToLch(tuple_20: vec3<f32>) -> vec3<f32> {
    var tuple_21: vec3<f32>;

    tuple_21 = tuple_20;
    let _e8 = tuple_21;
    let _e9 = rgbToXyz(_e8);
    let _e10 = xyzToLuv(_e9);
    let _e11 = luvToLch(_e10);
    return _e11;
}

fn rgbToHsluv(tuple_22: vec3<f32>) -> vec3<f32> {
    var tuple_23: vec3<f32>;

    tuple_23 = tuple_22;
    let _e8 = tuple_23;
    let _e9 = rgbToLch(_e8);
    let _e10 = lchToHsluv(_e9);
    return _e10;
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

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local_5: vec4<f32>;
    var P: vec4<f32>;
    var local_6: vec4<f32>;
    var Q: vec4<f32>;
    var C_1: f32;
    var H_3: f32;

    RGB_1 = RGB;
    let _e8 = RGB_1;
    let _e10 = RGB_1;
    if (_e8.y < _e10.z) {
        let _e13 = RGB_1;
        let _e14 = _e13.zy;
        local_5 = vec4<f32>(_e14.x, _e14.y, -1f, 0.6666667f);
    } else {
        let _e23 = RGB_1;
        let _e24 = _e23.yz;
        local_5 = vec4<f32>(_e24.x, _e24.y, 0f, -0.33333334f);
    }
    let _e34 = local_5;
    P = _e34;
    let _e36 = RGB_1;
    let _e38 = P;
    if (_e36.x < _e38.x) {
        let _e41 = P;
        let _e42 = _e41.xyw;
        let _e43 = RGB_1;
        local_6 = vec4<f32>(_e42.x, _e42.y, _e42.z, _e43.x);
    } else {
        let _e49 = RGB_1;
        let _e51 = P;
        let _e52 = _e51.yzx;
        local_6 = vec4<f32>(_e49.x, _e52.x, _e52.y, _e52.z);
    }
    let _e58 = local_6;
    Q = _e58;
    let _e60 = Q;
    let _e62 = Q;
    let _e64 = Q;
    C_1 = (_e60.x - min(_e62.w, _e64.y));
    let _e69 = Q;
    let _e71 = Q;
    let _e75 = C_1;
    let _e80 = Q;
    H_3 = abs((((_e69.w - _e71.y) / ((6f * _e75) + 0.0000000001f)) + _e80.z));
    let _e85 = H_3;
    let _e86 = C_1;
    let _e87 = Q;
    let _e89 = RGB_1;
    return vec4<f32>(_e85, _e86, _e87.x, _e89.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L_7: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e8 = RGB_3;
    let _e9 = rgbToHcv(_e8);
    HCV = _e9;
    let _e11 = HCV;
    let _e13 = HCV;
    L_7 = (_e11.z - (_e13.y * 0.5f));
    let _e19 = HCV;
    let _e22 = L_7;
    S = (_e19.y / ((1f - abs(((_e22 * 2f) - 1f))) + 0.000001f));
    let _e33 = HCV;
    let _e37 = S;
    let _e38 = L_7;
    let _e39 = RGB_3;
    return vec4<f32>((_e33.x * 360f), _e37, _e38, _e39.w);
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
    let _e10 = col_1;
    let _e11 = rgbToHsl(_e10);
    colHsl = _e11.xyz;
    let _e14 = tint_1;
    let _e15 = rgbToHsl(_e14);
    tintHsl = _e15.xyz;
    let _e20 = tintHsl;
    gamma = pow(5f, (0.5f - _e20.z));
    let _e25 = tintHsl;
    let _e26 = _e25.xy;
    let _e27 = colHsl;
    let _e29 = gamma;
    let _e31 = col_1;
    let _e36 = hslToRgb(vec4<f32>(_e26.x, _e26.y, pow(_e27.z, _e29), _e31.w));
    target_ = _e36;
    let _e38 = col_1;
    let _e39 = target_;
    let _e40 = tint_1;
    return mix(_e38, _e39, vec4(_e40.w));
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
    var c_8: f32;
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
    let _e22 = luminosity_1;
    if (_e22 != 0f) {
        {
            let _e25 = col_3;
            let _e27 = col_3;
            let _e29 = luminosity_1;
            let _e31 = (_e27.xyz + vec3(_e29));
            col_3.x = _e31.x;
            col_3.y = _e31.y;
            col_3.z = _e31.z;
        }
    }
    let _e38 = brightness_1;
    if (_e38 != 0f) {
        {
            let _e41 = col_3;
            let _e43 = col_3;
            let _e46 = brightness_1;
            let _e48 = (_e43.xyz * (1f + _e46));
            col_3.x = _e48.x;
            col_3.y = _e48.y;
            col_3.z = _e48.z;
        }
    }
    let _e55 = gamma_2;
    if (_e55 != 0f) {
        {
            let _e59 = gamma_2;
            p_3 = pow(2f, -(_e59));
            let _e64 = col_3;
            let _e66 = p_3;
            col_3.x = pow(_e64.x, _e66);
            let _e69 = col_3;
            let _e71 = p_3;
            col_3.y = pow(_e69.y, _e71);
            let _e74 = col_3;
            let _e76 = p_3;
            col_3.z = pow(_e74.z, _e76);
        }
    }
    let _e78 = contrast_1;
    if (_e78 != 0f) {
        {
            let _e81 = contrast_1;
            if (abs(_e81) > 1f) {
                let _e85 = contrast_1;
                let _e87 = contrast_1;
                local_7 = (sign(_e85) * pow(abs(_e87), 2f));
            } else {
                let _e92 = contrast_1;
                local_7 = _e92;
            }
            let _e94 = local_7;
            c_8 = _e94;
            let _e96 = col_3;
            let _e98 = col_3;
            let _e103 = c_8;
            let _e107 = (((_e98.xyz - vec3(0.5f)) * _e103) + vec3(0.5f));
            col_3.x = _e107.x;
            col_3.y = _e107.y;
            col_3.z = _e107.z;
        }
    }
    let _e114 = col_3;
    let _e118 = col_3;
    let _e123 = col_3;
    white = (((_e114.x == 1f) && (_e118.y == 1f)) && (_e123.z == 1f));
    let _e129 = saturation_1;
    let _e132 = hue_1;
    let _e136 = white;
    requireHsl = (((_e129 != 0f) || (_e132 != 0f)) && !(_e136));
    let _e140 = requireHsl;
    if _e140 {
        {
            let _e141 = col_3;
            let _e143 = rgbToHsluv(_e141.xyz);
            hsl = _e143;
            let _e149 = hsl.y;
            let _e151 = saturation_1;
            hsl[1i] = clamp((_e149 * (1f + _e151)), 0f, 100f);
            let _e161 = hsl.x;
            let _e162 = hue_1;
            hsl[0i] = (_e161 + _e162);
            let _e164 = col_3;
            let _e166 = hsl;
            let _e167 = hsluvToRgb(_e166);
            col_3.x = _e167.x;
            col_3.y = _e167.y;
            col_3.z = _e167.z;
        }
    }
    let _e174 = tint_3;
    if (_e174.w != 0f) {
        {
            let _e178 = col_3;
            let _e179 = tint_3;
            let _e180 = tintColor(_e178, _e179);
            col_3 = _e180;
        }
    }
    let _e181 = col_3;
    return _e181;
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e18 = u_1;
    return vec2<f32>(fract((sin(dot(_e8.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e18.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p_4: vec2<f32>) -> vec2<f32> {
    var p_5: vec2<f32>;
    var rnd: vec2<f32>;
    var len_1: f32;

    p_5 = p_4;
    let _e8 = p_5;
    let _e9 = hash22b(_e8);
    rnd = (_e9 - vec2(0.5f));
    let _e14 = rnd;
    len_1 = length(_e14);
    let _e17 = len_1;
    if (_e17 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e23 = rnd;
        let _e24 = len_1;
        return (_e23 / vec2(_e24));
    }
}

fn dotGridGradient(g_1: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_2: vec2<f32>;
    var u_3: vec2<f32>;

    g_2 = g_1;
    u_3 = u_2;
    let _e10 = u_3;
    let _e11 = g_2;
    let _e13 = g_2;
    let _e14 = rndUnit(_e13);
    return dot((_e10 - _e11), _e14);
}

fn smix(a: f32, b_1: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_2: f32;
    var k_1: f32;

    a_1 = a;
    b_2 = b_1;
    k_1 = k;
    let _e12 = a_1;
    let _e13 = b_2;
    let _e16 = k_1;
    return mix(_e12, _e13, smoothstep(0f, 1f, _e16));
}

fn perlinNoise(p_6: vec2<f32>) -> f32 {
    var p_7: vec2<f32>;
    var s_1: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_7 = p_6;
    let _e12 = p_7;
    f = floor(_e12);
    let _e15 = p_7;
    let _e16 = f;
    d = (_e15 - _e16);
    let _e19 = f;
    let _e20 = p_7;
    let _e21 = dotGridGradient(_e19, _e20);
    let _e22 = f;
    let _e23 = s_1;
    let _e25 = p_7;
    let _e26 = dotGridGradient((_e22 + _e23), _e25);
    let _e27 = d;
    let _e29 = smix(_e21, _e26, _e27.x);
    ix0_ = _e29;
    let _e31 = f;
    let _e32 = s_1;
    let _e35 = p_7;
    let _e36 = dotGridGradient((_e31 + _e32.yx), _e35);
    let _e37 = f;
    let _e38 = s_1;
    let _e41 = p_7;
    let _e42 = dotGridGradient((_e37 + _e38.xx), _e41);
    let _e43 = d;
    let _e45 = smix(_e36, _e42, _e43.x);
    ix1_ = _e45;
    let _e48 = ix0_;
    let _e49 = ix1_;
    let _e50 = d;
    let _e52 = smix(_e48, _e49, _e50.y);
    return (0.5f + (_e52 * 0.5f));
}

fn perlinOctaveNoise(uv: vec2<f32>, n: i32) -> f32 {
    var uv_1: vec2<f32>;
    var n_1: i32;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_2: f32 = 1f;
    var x_2: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;

    uv_1 = uv;
    n_1 = n;
    loop {
        let _e44 = i;
        let _e45 = n_1;
        if !((_e44 < _e45)) {
            break;
        }
        {
            let _e51 = x_2;
            let _e52 = k_2;
            let _e53 = uv_1;
            let _e54 = perlinNoise(_e53);
            x_2 = (_e51 + (_e52 * _e54));
            let _e57 = total;
            let _e58 = k_2;
            total = (_e57 + _e58);
            let _e60 = k_2;
            k_2 = (_e60 * 0.5f);
            let _e63 = transform;
            let _e64 = uv_1;
            uv_1 = (_e63 * _e64);
        }
        continuing {
            let _e48 = i;
            i = (_e48 + 1i);
        }
    }
    let _e66 = x_2;
    let _e67 = total;
    x_2 = (_e66 / _e67);
    let _e69 = x_2;
    return _e69;
}

fn tf(m_2: mat3x3<f32>, u_4: vec2<f32>) -> vec2<f32> {
    var m_3: mat3x3<f32>;
    var u_5: vec2<f32>;

    m_3 = m_2;
    u_5 = u_4;
    let _e10 = m_3;
    let _e11 = u_5;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn simpleVignette(vignette: f32, uv_2: vec2<f32>, vignetteTransform: mat3x3<f32>) -> f32 {
    var vignette_1: f32;
    var uv_3: vec2<f32>;
    var vignetteTransform_1: mat3x3<f32>;
    var d_1: f32;

    vignette_1 = vignette;
    uv_3 = uv_2;
    vignetteTransform_1 = vignetteTransform;
    let _e12 = vignetteTransform_1;
    let _e13 = uv_3;
    let _e14 = tf(_e12, _e13);
    d_1 = length(_e14);
    let _e18 = vignette_1;
    let _e23 = d_1;
    return mix((1f - _e18), 1f, smoothstep(0.5f, 1f, _e23));
}

fn grain(pos: vec2<f32>, outPos: vec2<f32>, layerCount: i32, intensity: f32, balance: f32, stratification: f32, octaves: i32, power: f32, color: vec4<f32>, color2_: vec4<f32>, vignetting: f32, vignetteTransform_2: mat3x3<f32>, layerTransform: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var layerCount_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var stratification_1: f32;
    var octaves_1: i32;
    var power_1: f32;
    var color_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var vignetting_1: f32;
    var vignetteTransform_3: mat3x3<f32>;
    var layerTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var col_4: vec4<f32>;
    var u_6: vec2<f32>;
    var totalHum: f32 = 0f;
    var k_3: f32 = 1f;
    var totalK: f32 = 0f;
    var inverseLayerTransform: mat3x3<f32>;
    var i_1: i32 = 0i;
    var hum: f32;
    var hueShiftedCol: vec4<f32>;
    var local_8: vec4<f32>;
    var targetCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    layerCount_1 = layerCount;
    intensity_1 = intensity;
    balance_1 = balance;
    stratification_1 = stratification;
    octaves_1 = octaves;
    power_1 = power;
    color_1 = color;
    color2_1 = color2_;
    vignetting_1 = vignetting;
    vignetteTransform_3 = vignetteTransform_2;
    layerTransform_1 = layerTransform;
    modelTransform_1 = modelTransform;
    let _e34 = pos_1;
    let _e38 = global.U[0];
    let _e41 = pos_1;
    let _e50 = textureSample(t_source, samp, ((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
    col_4 = _e50;
    let _e52 = modelTransform_1;
    let _e54 = pos_1;
    let _e55 = tf(_naga_inverse_3x3_f32(_e52), _e54);
    u_6 = _e55;
    let _e63 = layerTransform_1;
    inverseLayerTransform = _naga_inverse_3x3_f32(_e63);
    loop {
        let _e68 = i_1;
        let _e69 = layerCount_1;
        if !((_e68 < _e69)) {
            break;
        }
        {
            let _e76 = u_6;
            let _e77 = octaves_1;
            let _e78 = perlinOctaveNoise(_e76, _e77);
            hum = (2f * (_e78 - 0.5f));
            let _e83 = hum;
            let _e84 = stratification_1;
            let _e85 = (_e83 * _e84);
            hum = ((_e85 - (floor((_e85 / 2f)) * 2f)) * 0.5f);
            let _e93 = hum;
            let _e94 = balance_1;
            if (_e93 < _e94) {
                let _e96 = hum;
                let _e97 = balance_1;
                hum = (_e96 / _e97);
            } else {
                let _e100 = hum;
                let _e101 = balance_1;
                let _e104 = balance_1;
                hum = (1f - ((_e100 - _e101) / (1f - _e104)));
            }
            let _e108 = hum;
            let _e109 = power_1;
            hum = pow(_e108, _e109);
            let _e111 = totalHum;
            let _e112 = hum;
            let _e113 = k_3;
            totalHum = (_e111 + (_e112 * _e113));
            let _e116 = totalK;
            let _e117 = k_3;
            totalK = (_e116 + _e117);
            let _e119 = k_3;
            k_3 = (_e119 * 0.6f);
            let _e122 = inverseLayerTransform;
            let _e123 = u_6;
            let _e124 = tf(_e122, _e123);
            u_6 = _e124;
        }
        continuing {
            let _e72 = i_1;
            i_1 = (_e72 + 1i);
        }
    }
    let _e125 = totalHum;
    let _e127 = totalK;
    let _e129 = power_1;
    totalHum = (_e125 / mix(1f, _e127, pow(0.5f, _e129)));
    let _e133 = col_4;
    hueShiftedCol = _e133;
    let _e135 = totalHum;
    if (_e135 < 0.5f) {
        let _e138 = hueShiftedCol;
        let _e139 = hueShiftedCol;
        let _e140 = color2_1;
        let _e141 = mergeColor(_e139, _e140);
        let _e142 = totalHum;
        local_8 = mix(_e138, _e141, vec4((_e142 / 0.5f)));
    } else {
        let _e147 = hueShiftedCol;
        let _e148 = color2_1;
        let _e149 = mergeColor(_e147, _e148);
        let _e150 = hueShiftedCol;
        let _e151 = color_1;
        let _e152 = mergeColor(_e150, _e151);
        let _e153 = totalHum;
        local_8 = mix(_e149, _e152, vec4(((_e153 - 0.5f) / 0.5f)));
    }
    let _e161 = local_8;
    targetCol = _e161;
    let _e163 = col_4;
    let _e164 = targetCol;
    let _e165 = intensity_1;
    let _e166 = vignetting_1;
    let _e167 = pos_1;
    let _e168 = vignetteTransform_3;
    let _e170 = simpleVignette(_e166, _e167, _naga_inverse_3x3_f32(_e168));
    col_4 = mix(_e163, _e164, vec4((_e165 * _e170)));
    let _e174 = col_4;
    return _e174;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e95 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e110 = global.U[16];
    let _e111 = _e110.xyz;
    let _e127 = global.U[17];
    let _e128 = _e127.xyz;
    let _e131 = global.U[18];
    let _e132 = _e131.xyz;
    let _e135 = global.U[19];
    let _e136 = _e135.xyz;
    let _e152 = global.U[20];
    let _e153 = _e152.xyz;
    let _e156 = global.U[21];
    let _e157 = _e156.xyz;
    let _e160 = global.U[22];
    let _e161 = _e160.xyz;
    let _e175 = grain((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, i32(_e83.x), _e88.x, _e92, _e95, _e98.x, mat3x3<f32>(vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z)), mat3x3<f32>(vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z)), mat3x3<f32>(vec3<f32>(_e153.x, _e153.y, _e153.z), vec3<f32>(_e157.x, _e157.y, _e157.z), vec3<f32>(_e161.x, _e161.y, _e161.z)));
    fragColor = _e175;
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
