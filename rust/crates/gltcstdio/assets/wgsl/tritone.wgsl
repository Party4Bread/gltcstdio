struct Params {
    U: array<vec4<f32>, 10>,
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

fn luma(c_4: vec3<f32>) -> f32 {
    var c_5: vec3<f32>;

    c_5 = c_4;
    let _e9 = c_5;
    let _e13 = c_5;
    let _e18 = c_5;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
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

fn hsluv_toLinear1_(c_6: f32) -> f32 {
    var c_7: f32;
    var local_3: f32;

    c_7 = c_6;
    let _e8 = c_7;
    if (_e8 > 0.04045f) {
        let _e11 = c_7;
        local_3 = pow(((_e11 + 0.055f) / 1.055f), 2.4f);
    } else {
        let _e20 = c_7;
        local_3 = (_e20 / 12.92f);
    }
    let _e24 = local_3;
    return _e24;
}

fn hsluv_toLinear(c_8: vec3<f32>) -> vec3<f32> {
    var c_9: vec3<f32>;

    c_9 = c_8;
    let _e8 = c_9;
    let _e10 = hsluv_toLinear1_(_e8.x);
    let _e11 = c_9;
    let _e13 = hsluv_toLinear1_(_e11.y);
    let _e14 = c_9;
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

fn tritone(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, color1_: vec4<f32>, color2_: vec4<f32>, normalization: f32, saturation: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var normalization_1: f32;
    var saturation_1: f32;
    var col: vec4<f32>;
    var l: f32;
    var hsluv1_: vec3<f32>;
    var hsluv2_: vec3<f32>;
    var lim1_: f32;
    var lim2_: f32;
    var tmp: f32;
    var tmpc: vec3<f32>;
    var color1a: vec4<f32>;
    var color2a: vec4<f32>;
    var tCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    color1_1 = color1_;
    color2_1 = color2_;
    normalization_1 = normalization;
    saturation_1 = saturation;
    let _e20 = pos_1;
    let _e24 = global.U[0];
    let _e27 = pos_1;
    let _e36 = textureSample(t_source, samp, ((vec2<f32>((_e20.x / _e24.x), _e27.y) / vec2(2f)) + vec2(0.5f)));
    col = _e36;
    let _e38 = col;
    let _e40 = luma(_e38.xyz);
    l = _e40;
    let _e42 = color1_1;
    let _e44 = rgbToHsluv(_e42.xyz);
    hsluv1_ = _e44;
    let _e47 = hsluv1_;
    let _e49 = saturation_1;
    hsluv1_.y = (_e47.y * _e49);
    let _e51 = color2_1;
    let _e53 = rgbToHsluv(_e51.xyz);
    hsluv2_ = _e53;
    let _e56 = hsluv2_;
    let _e58 = saturation_1;
    hsluv2_.y = (_e56.y * _e58);
    let _e61 = hsluv1_;
    let _e65 = normalization_1;
    lim1_ = mix(0.333333f, (_e61.z * 0.01f), _e65);
    let _e69 = hsluv2_;
    let _e73 = normalization_1;
    lim2_ = mix(0.666667f, (_e69.z * 0.01f), _e73);
    let _e76 = lim1_;
    let _e77 = lim2_;
    if (_e76 > _e77) {
        {
            let _e79 = lim1_;
            tmp = _e79;
            let _e81 = lim2_;
            lim1_ = _e81;
            let _e82 = tmp;
            lim2_ = _e82;
            let _e83 = hsluv1_;
            tmpc = _e83;
            let _e85 = hsluv2_;
            hsluv1_ = _e85;
            let _e86 = tmpc;
            hsluv2_ = _e86;
        }
    }
    let _e87 = hsluv1_;
    let _e88 = hsluvToRgb(_e87);
    let _e89 = color1_1;
    color1a = vec4<f32>(_e88.x, _e88.y, _e88.z, _e89.w);
    let _e96 = hsluv2_;
    let _e97 = hsluvToRgb(_e96);
    let _e98 = color2_1;
    color2a = vec4<f32>(_e97.x, _e97.y, _e97.z, _e98.w);
    let _e106 = l;
    let _e107 = lim1_;
    if (_e106 < _e107) {
        let _e114 = color1a;
        let _e115 = l;
        let _e116 = lim1_;
        tCol = mix(vec4<f32>(0f, 0f, 0f, 1f), _e114, vec4((_e115 / _e116)));
    } else {
        let _e120 = l;
        let _e121 = lim1_;
        if (_e120 == _e121) {
            let _e123 = color1a;
            tCol = _e123;
        } else {
            let _e124 = l;
            let _e125 = lim2_;
            if (_e124 < _e125) {
                let _e127 = color1a;
                let _e128 = color2a;
                let _e129 = l;
                let _e130 = lim1_;
                let _e132 = lim2_;
                let _e133 = lim1_;
                tCol = mix(_e127, _e128, vec4(((_e129 - _e130) / (_e132 - _e133))));
            } else {
                let _e138 = l;
                let _e139 = lim2_;
                if (_e138 == _e139) {
                    let _e141 = color2a;
                    tCol = _e141;
                } else {
                    let _e142 = color2a;
                    let _e148 = l;
                    let _e149 = lim2_;
                    let _e152 = lim2_;
                    tCol = mix(_e142, vec4<f32>(1f, 1f, 1f, 1f), vec4(((_e148 - _e149) / (1f - _e152))));
                }
            }
        }
    }
    let _e157 = col;
    let _e158 = tCol;
    let _e159 = intensity_1;
    return mix(_e157, _e158, vec4(_e159));
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
    let _e73 = global.U[7];
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e82 = tritone((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70, _e73, _e76.x, _e80.x);
    fragColor = _e82;
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
