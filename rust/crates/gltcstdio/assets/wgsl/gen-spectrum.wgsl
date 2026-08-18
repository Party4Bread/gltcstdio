struct Params {
    U: array<vec4<f32>, 8>,
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

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e11 = h_1;
    if (_e11 < 0f) {
        let _e14 = h_1;
        h_1 = (_e14 + 1f);
    }
    let _e17 = h_1;
    if (_e17 > 1f) {
        let _e20 = h_1;
        h_1 = (_e20 - 1f);
    }
    let _e24 = h_1;
    if ((6f * _e24) < 1f) {
        {
            let _e28 = p_1;
            let _e29 = q_1;
            let _e30 = p_1;
            let _e34 = h_1;
            return (_e28 + (((_e29 - _e30) * 6f) * _e34));
        }
    }
    let _e38 = h_1;
    if ((2f * _e38) < 1f) {
        {
            let _e42 = q_1;
            return _e42;
        }
    }
    let _e44 = h_1;
    if ((3f * _e44) < 2f) {
        {
            let _e48 = p_1;
            let _e49 = q_1;
            let _e50 = p_1;
            let _e57 = h_1;
            return (_e48 + (((_e49 - _e50) * 6f) * (0.6666667f - _e57)));
        }
    }
    let _e61 = p_1;
    return _e61;
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
    let _e7 = inc_1;
    h_2 = (_e7.x - (floor((_e7.x / 360f)) * 360f));
    let _e15 = h_2;
    h_2 = (_e15 / 360f);
    let _e18 = inc_1;
    s = _e18.y;
    let _e21 = inc_1;
    l = _e21.z;
    let _e26 = l;
    if (_e26 < 0.5f) {
        let _e29 = l;
        let _e31 = s;
        q_2 = (_e29 * (1f + _e31));
    } else {
        let _e34 = l;
        let _e35 = s;
        let _e37 = s;
        let _e38 = l;
        q_2 = ((_e34 + _e35) - (_e37 * _e38));
    }
    let _e42 = l;
    let _e44 = q_2;
    p_2 = ((2f * _e42) - _e44);
    let _e48 = p_2;
    let _e49 = q_2;
    let _e50 = h_2;
    let _e55 = hueToRgb(_e48, _e49, (_e50 + 0.33333334f));
    r = max(0f, _e55);
    let _e59 = p_2;
    let _e60 = q_2;
    let _e61 = h_2;
    let _e62 = hueToRgb(_e59, _e60, _e61);
    g = max(0f, _e62);
    let _e66 = p_2;
    let _e67 = q_2;
    let _e68 = h_2;
    let _e73 = hueToRgb(_e66, _e67, (_e68 - 0.33333334f));
    b = max(0f, _e73);
    let _e78 = r;
    outc.x = min(_e78, 1f);
    let _e82 = g;
    outc.y = min(_e82, 1f);
    let _e86 = b;
    outc.z = min(_e86, 1f);
    let _e90 = inc_1;
    outc.w = _e90.w;
    let _e92 = outc;
    return _e92;
}

fn hsluv_lengthOfRayUntilIntersect(theta: f32, x: vec3<f32>, y: vec3<f32>) -> vec3<f32> {
    var theta_1: f32;
    var x_1: vec3<f32>;
    var y_1: vec3<f32>;
    var len: vec3<f32>;

    theta_1 = theta;
    x_1 = x;
    y_1 = y;
    let _e11 = y_1;
    let _e12 = theta_1;
    let _e14 = x_1;
    let _e15 = theta_1;
    len = (_e11 / (vec3(sin(_e12)) - (_e14 * cos(_e15))));
    let _e22 = len;
    if (_e22.x < 0f) {
        {
            len.x = 1000f;
        }
    }
    let _e28 = len;
    if (_e28.y < 0f) {
        {
            len.y = 1000f;
        }
    }
    let _e34 = len;
    if (_e34.z < 0f) {
        {
            len.z = 1000f;
        }
    }
    let _e40 = len;
    return _e40;
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
    let _e9 = H_1;
    hrad = radians(_e9);
    let _e30 = L_1;
    sub1_ = (pow((_e30 + 16f), 3f) / 1560896f);
    let _e38 = sub1_;
    if (_e38 > 0.008856452f) {
        let _e41 = sub1_;
        local = _e41;
    } else {
        let _e42 = L_1;
        local = (_e42 / 903.2963f);
    }
    let _e46 = local;
    sub2_ = _e46;
    let _e51 = m2_[0];
    let _e56 = m2_[2];
    let _e59 = sub2_;
    top1_ = (((284517f * _e51) - (94839f * _e56)) * _e59);
    let _e65 = m2_[2];
    let _e70 = m2_[1];
    let _e73 = sub2_;
    bottom = (((632260f * _e65) - (126452f * _e70)) * _e73);
    let _e79 = m2_[2];
    let _e84 = m2_[1];
    let _e90 = m2_[0];
    let _e93 = L_1;
    let _e95 = sub2_;
    top2_ = (((((838422f * _e79) + (769860f * _e84)) + (731718f * _e90)) * _e93) * _e95);
    let _e98 = top1_;
    let _e99 = bottom;
    bound0x = (_e98 / _e99);
    let _e102 = top2_;
    let _e103 = bottom;
    bound0y = (_e102 / _e103);
    let _e106 = top1_;
    let _e107 = bottom;
    bound1x = (_e106 / (_e107 + vec3(126452f)));
    let _e113 = top2_;
    let _e115 = L_1;
    let _e119 = bottom;
    bound1y = ((_e113 - vec3((769860f * _e115))) / (_e119 + vec3(126452f)));
    let _e125 = hrad;
    let _e126 = bound0x;
    let _e127 = bound0y;
    let _e128 = hsluv_lengthOfRayUntilIntersect(_e125, _e126, _e127);
    lengths0_ = _e128;
    let _e130 = hrad;
    let _e131 = bound1x;
    let _e132 = bound1y;
    let _e133 = hsluv_lengthOfRayUntilIntersect(_e130, _e131, _e132);
    lengths1_ = _e133;
    let _e135 = lengths0_;
    let _e137 = lengths1_;
    let _e139 = lengths0_;
    let _e141 = lengths1_;
    let _e143 = lengths0_;
    let _e145 = lengths1_;
    return min(_e135.x, min(_e137.x, min(_e139.y, min(_e141.y, min(_e143.z, _e145.z)))));
}

fn hsluvToLch(tuple: vec3<f32>) -> vec3<f32> {
    var tuple_1: vec3<f32>;

    tuple_1 = tuple;
    let _e8 = tuple_1;
    let _e10 = tuple_1;
    let _e12 = tuple_1;
    let _e14 = hsluv_maxChromaForLH(_e10.z, _e12.x);
    tuple_1.y = (_e8.y * (_e14 * 0.01f));
    let _e18 = tuple_1;
    return _e18.zyx;
}

fn lchToLuv(tuple_2: vec3<f32>) -> vec3<f32> {
    var tuple_3: vec3<f32>;
    var hrad_1: f32;

    tuple_3 = tuple_2;
    let _e7 = tuple_3;
    hrad_1 = radians(_e7.z);
    let _e11 = tuple_3;
    let _e13 = hrad_1;
    let _e15 = tuple_3;
    let _e18 = hrad_1;
    let _e20 = tuple_3;
    return vec3<f32>(_e11.x, (cos(_e13) * _e15.y), (sin(_e18) * _e20.y));
}

fn hsluv_lToY(L_2: f32) -> f32 {
    var L_3: f32;
    var local_1: f32;

    L_3 = L_2;
    let _e7 = L_3;
    if (_e7 <= 8f) {
        let _e10 = L_3;
        local_1 = (_e10 / 903.2963f);
    } else {
        let _e13 = L_3;
        local_1 = pow(((_e13 + 16f) / 116f), 3f);
    }
    let _e21 = local_1;
    return _e21;
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
    let _e7 = tuple_5;
    L_4 = _e7.x;
    let _e10 = tuple_5;
    let _e13 = L_4;
    U = ((_e10.y / (13f * _e13)) + 0.19783f);
    let _e19 = tuple_5;
    let _e22 = L_4;
    V = ((_e19.z / (13f * _e22)) + 0.46831998f);
    let _e28 = L_4;
    let _e29 = hsluv_lToY(_e28);
    Y = _e29;
    let _e32 = U;
    let _e34 = Y;
    let _e36 = V;
    X = (((2.25f * _e32) * _e34) / _e36);
    let _e40 = V;
    let _e44 = Y;
    let _e46 = X;
    Z = ((((3f / _e40) - 5f) * _e44) - (_e46 / 3f));
    let _e51 = X;
    let _e52 = Y;
    let _e53 = Z;
    return vec3<f32>(_e51, _e52, _e53);
}

fn hsluv_fromLinear1_(c: f32) -> f32 {
    var c_1: f32;
    var local_2: f32;

    c_1 = c;
    let _e7 = c_1;
    if (_e7 <= 0.0031308f) {
        let _e11 = c_1;
        local_2 = (12.92f * _e11);
    } else {
        let _e14 = c_1;
        local_2 = ((1.055f * pow(_e14, 0.41666666f)) - 0.055f);
    }
    let _e23 = local_2;
    return _e23;
}

fn hsluv_fromLinear(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e7 = c_3;
    let _e9 = hsluv_fromLinear1_(_e7.x);
    let _e10 = c_3;
    let _e12 = hsluv_fromLinear1_(_e10.y);
    let _e13 = c_3;
    let _e15 = hsluv_fromLinear1_(_e13.z);
    return vec3<f32>(_e9, _e12, _e15);
}

fn xyzToRgb(tuple_6: vec3<f32>) -> vec3<f32> {
    var tuple_7: vec3<f32>;
    var m: mat3x3<f32> = mat3x3<f32>(vec3<f32>(3.24097f, -1.5373832f, -0.49861076f), vec3<f32>(-0.96924365f, 1.8759675f, 0.04155506f), vec3<f32>(0.05563008f, -0.20397696f, 1.0569715f));

    tuple_7 = tuple_6;
    let _e25 = tuple_7;
    let _e26 = m;
    let _e28 = hsluv_fromLinear((_e25 * _e26));
    return _e28;
}

fn lchToRgb(tuple_8: vec3<f32>) -> vec3<f32> {
    var tuple_9: vec3<f32>;

    tuple_9 = tuple_8;
    let _e7 = tuple_9;
    let _e8 = lchToLuv(_e7);
    let _e9 = luvToXyz(_e8);
    let _e10 = xyzToRgb(_e9);
    return _e10;
}

fn hsluvToRgb(tuple_10: vec3<f32>) -> vec3<f32> {
    var tuple_11: vec3<f32>;

    tuple_11 = tuple_10;
    let _e7 = tuple_11;
    let _e8 = hsluvToLch(_e7);
    let _e9 = lchToRgb(_e8);
    return _e9;
}

fn hsluvToRgb4_(c_4: vec4<f32>) -> vec4<f32> {
    var c_5: vec4<f32>;

    c_5 = c_4;
    let _e7 = c_5;
    let _e9 = c_5;
    let _e11 = c_5;
    let _e14 = hsluvToRgb(vec3<f32>(_e7.x, _e9.y, _e11.z));
    let _e15 = c_5;
    return vec4<f32>(_e14.x, _e14.y, _e14.z, _e15.w);
}

fn genSpectrum(uv: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, mode: i32, luminosity: f32, saturation: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var mode_1: i32;
    var luminosity_1: f32;
    var saturation_1: f32;
    var ratio: f32;
    var k: f32;
    var local_3: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    outDim_1 = outDim;
    mode_1 = mode;
    luminosity_1 = luminosity;
    saturation_1 = saturation;
    let _e17 = outDim_1;
    let _e19 = outDim_1;
    ratio = (_e17.x / _e19.y);
    let _e24 = uv_1;
    let _e26 = ratio;
    let _e30 = ratio;
    k = ((360f * (_e24.x + _e26)) / (2f * _e30));
    let _e34 = mode_1;
    if (_e34 == 0i) {
        let _e37 = k;
        let _e38 = saturation_1;
        let _e39 = luminosity_1;
        let _e42 = hslToRgb(vec4<f32>(_e37, _e38, _e39, 1f));
        local_3 = _e42;
    } else {
        let _e43 = k;
        let _e44 = saturation_1;
        let _e47 = luminosity_1;
        let _e52 = hsluvToRgb4_(vec4<f32>(_e43, (_e44 * 100f), (_e47 * 100f), 1f));
        local_3 = _e52;
    }
    let _e54 = local_3;
    return _e54;
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[4];
    let _e69 = global.U[5];
    let _e74 = global.U[6];
    let _e78 = global.U[7];
    let _e80 = genSpectrum((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65.xy, i32(_e69.x), _e74.x, _e78.x);
    fragColor = _e80;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
