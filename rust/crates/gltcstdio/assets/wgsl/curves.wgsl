struct Params {
    U: array<vec4<f32>, 5>,
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
var t_curveLut: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

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

fn hsluv_fromLinear1_(c: f32) -> f32 {
    var c_1: f32;
    var local_2: f32;

    c_1 = c;
    let _e9 = c_1;
    if (_e9 <= 0.0031308f) {
        let _e13 = c_1;
        local_2 = (12.92f * _e13);
    } else {
        let _e16 = c_1;
        local_2 = ((1.055f * pow(_e16, 0.41666666f)) - 0.055f);
    }
    let _e25 = local_2;
    return _e25;
}

fn hsluv_fromLinear(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e9 = c_3;
    let _e11 = hsluv_fromLinear1_(_e9.x);
    let _e12 = c_3;
    let _e14 = hsluv_fromLinear1_(_e12.y);
    let _e15 = c_3;
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

fn hsluv_toLinear1_(c_4: f32) -> f32 {
    var c_5: f32;
    var local_3: f32;

    c_5 = c_4;
    let _e9 = c_5;
    if (_e9 > 0.04045f) {
        let _e12 = c_5;
        local_3 = pow(((_e12 + 0.055f) / 1.055f), 2.4f);
    } else {
        let _e21 = c_5;
        local_3 = (_e21 / 12.92f);
    }
    let _e25 = local_3;
    return _e25;
}

fn hsluv_toLinear(c_6: vec3<f32>) -> vec3<f32> {
    var c_7: vec3<f32>;

    c_7 = c_6;
    let _e9 = c_7;
    let _e11 = hsluv_toLinear1_(_e9.x);
    let _e12 = c_7;
    let _e14 = hsluv_toLinear1_(_e12.y);
    let _e15 = c_7;
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

fn curves(pos: vec2<f32>, outPos: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var col: vec4<f32>;
    var rIdx: i32;
    var gIdx: i32;
    var bIdx: i32;
    var hsluv: vec3<f32>;
    var satIdx: i32;
    var hueIdx: i32;
    var lum: f32;
    var lumIdx: i32;
    var newLum: f32;
    var t: f32;
    var ratioResult: vec3<f32>;
    var flatResult: vec3<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    let _e11 = pos_1;
    let _e15 = global.U[0];
    let _e18 = pos_1;
    let _e27 = textureSample(t_source, samp, ((vec2<f32>((_e11.x / _e15.x), _e18.y) / vec2(2f)) + vec2(0.5f)));
    col = _e27;
    let _e29 = col;
    rIdx = clamp(i32((_e29.x * 255f)), 0i, 255i);
    let _e38 = col;
    gIdx = clamp(i32((_e38.y * 255f)), 0i, 255i);
    let _e47 = col;
    bIdx = clamp(i32((_e47.z * 255f)), 0i, 255i);
    let _e57 = rIdx;
    let _e61 = textureLoad(t_curveLut, vec2<i32>(_e57, 1i), 0i);
    col.x = _e61.x;
    let _e64 = gIdx;
    let _e68 = textureLoad(t_curveLut, vec2<i32>(_e64, 2i), 0i);
    col.y = _e68.x;
    let _e71 = bIdx;
    let _e75 = textureLoad(t_curveLut, vec2<i32>(_e71, 3i), 0i);
    col.z = _e75.x;
    let _e77 = col;
    let _e79 = rgbToHsluv(_e77.xyz);
    hsluv = _e79;
    let _e81 = hsluv;
    satIdx = clamp(i32((_e81.y * 2.55f)), 0i, 255i);
    let _e91 = satIdx;
    let _e95 = textureLoad(t_curveLut, vec2<i32>(_e91, 4i), 0i);
    hsluv.y = (_e95.x * 100f);
    let _e99 = hsluv;
    hueIdx = clamp(i32((_e99.x * 0.7083333f)), 0i, 255i);
    let _e111 = hueIdx;
    let _e115 = textureLoad(t_curveLut, vec2<i32>(_e111, 5i), 0i);
    hsluv.x = (_e115.x * 360f);
    let _e119 = col;
    let _e121 = hsluv;
    let _e122 = hsluvToRgb(_e121);
    col.x = _e122.x;
    col.y = _e122.y;
    col.z = _e122.z;
    let _e129 = col;
    lum = dot(_e129.xyz, vec3<f32>(0.299f, 0.587f, 0.114f));
    let _e137 = lum;
    lumIdx = clamp(i32((_e137 * 255f)), 0i, 255i);
    let _e145 = lumIdx;
    let _e149 = textureLoad(t_curveLut, vec2<i32>(_e145, 0i), 0i);
    newLum = _e149.x;
    let _e154 = lum;
    t = smoothstep(0f, 0.01f, _e154);
    let _e157 = col;
    let _e159 = newLum;
    let _e160 = lum;
    ratioResult = (_e157.xyz * (_e159 / max(_e160, 0.0001f)));
    let _e166 = newLum;
    flatResult = vec3(_e166);
    let _e169 = flatResult;
    let _e170 = ratioResult;
    let _e171 = t;
    let _e178 = clamp(mix(_e169, _e170, vec3(_e171)), vec3(0f), vec3(1f));
    let _e179 = col;
    return vec4<f32>(_e178.x, _e178.y, _e178.z, _e179.w);
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
    let _e65 = curves((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)));
    fragColor = _e65;
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
