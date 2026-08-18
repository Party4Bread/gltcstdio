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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn getRand(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e9 = x_1;
    return ((2f * fract(((fract(((_e9 * 123.237f) + 10.4343f)) + 23.773f) * 434.4438f))) - 1f);
}

fn getHighVariance(p: vec2<f32>, threshold: f32, k: f32, invModelTransform: mat3x3<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var threshold_1: f32;
    var k_1: f32;
    var invModelTransform_1: mat3x3<f32>;
    var Y: f32;
    var delta: f32 = 0f;
    var scale: f32 = 0.5f;
    var i: i32 = 0i;
    var p0_: f32;
    var p1_: f32;
    var f: f32;
    var l: f32;

    p_1 = p;
    threshold_1 = threshold;
    k_1 = k;
    invModelTransform_1 = invModelTransform;
    let _e14 = p_1;
    p_1 = (_e14 * 10f);
    let _e17 = p_1;
    Y = _e17.y;
    loop {
        let _e26 = i;
        if !((_e26 < 10i)) {
            break;
        }
        {
            let _e33 = p_1;
            p0_ = floor(_e33.y);
            let _e37 = p_1;
            p1_ = ceil(_e37.y);
            let _e41 = p_1;
            f = fract(_e41.y);
            let _e45 = delta;
            let _e46 = p0_;
            let _e47 = getRand(_e46);
            let _e48 = p1_;
            let _e49 = getRand(_e48);
            let _e52 = f;
            let _e55 = scale;
            delta = (_e45 + (mix(_e47, _e49, smoothstep(0f, 1f, _e52)) * _e55));
            let _e58 = scale;
            scale = (_e58 * 0.5f);
            let _e61 = p_1;
            p_1 = (_e61 * 2f);
        }
        continuing {
            let _e30 = i;
            i = (_e30 + 1i);
        }
    }
    let _e64 = threshold_1;
    let _e67 = threshold_1;
    let _e70 = delta;
    l = smoothstep((_e64 - 0.2f), (_e67 + 0.2f), _e70);
    let _e73 = l;
    let _e74 = Y;
    delta = (_e73 * sin((_e74 * 100f)));
    let _e79 = invModelTransform_1;
    let _e86 = mat2x2<f32>(_e79[0].xy, _e79[1].xy);
    let _e91 = invModelTransform_1[0][0];
    let _e96 = invModelTransform_1[0][1];
    let _e99 = vec2(length(vec2<f32>(_e91, _e96)));
    let _e105 = delta;
    let _e106 = k_1;
    return (mat2x2<f32>((_e86[0] / _e99), (_e86[1] / _e99)) * vec2<f32>((_e105 * _e106), 0f));
}

fn logistic(x_2: f32, lambda: f32, n: i32) -> f32 {
    var x_3: f32;
    var lambda_1: f32;
    var n_1: i32;
    var i_1: i32 = 0i;

    x_3 = x_2;
    lambda_1 = lambda;
    n_1 = n;
    loop {
        let _e14 = i_1;
        if !((_e14 < 12i)) {
            break;
        }
        {
            let _e21 = lambda_1;
            let _e22 = x_3;
            let _e25 = x_3;
            x_3 = ((_e21 * _e22) * (1f - _e25));
        }
        continuing {
            let _e18 = i_1;
            i_1 = (_e18 + 1i);
        }
    }
    let _e28 = x_3;
    return _e28;
}

fn getLogistic(u: vec2<f32>, intensity: f32, ratio: f32, invModelTransform_2: mat3x3<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;
    var intensity_1: f32;
    var ratio_1: f32;
    var invModelTransform_3: mat3x3<f32>;
    var Y_1: f32;
    var dx: f32;
    var delta_1: vec2<f32>;

    u_1 = u;
    intensity_1 = intensity;
    ratio_1 = ratio;
    invModelTransform_3 = invModelTransform_2;
    let _e14 = u_1;
    Y_1 = ((_e14.y - (floor((_e14.y / 1f)) * 1f)) * 4f);
    let _e25 = Y_1;
    let _e27 = logistic(0.5f, _e25, 15i);
    let _e29 = Y_1;
    let _e31 = (_e29 * 2.2f);
    let _e38 = logistic(0.5f, (_e31 - (floor((_e31 / 4f)) * 4f)), 15i);
    dx = (_e27 - _e38);
    let _e41 = ratio_1;
    let _e42 = dx;
    let _e44 = intensity_1;
    delta_1 = vec2<f32>(((_e41 * _e42) * _e44), 0f);
    let _e49 = delta_1;
    let _e50 = invModelTransform_3;
    let _e57 = mat2x2<f32>(_e50[0].xy, _e50[1].xy);
    let _e62 = invModelTransform_3[0][0];
    let _e67 = invModelTransform_3[0][1];
    let _e70 = vec2(length(vec2<f32>(_e62, _e67)));
    delta_1 = (_e49 * mat2x2<f32>((_e57[0] / _e70), (_e57[1] / _e70)));
    let _e77 = delta_1;
    return _e77;
}

fn getLogisticCompensated(u_2: vec2<f32>, intensity_2: f32, ratio_2: f32, invModelTransform_4: mat3x3<f32>) -> vec2<f32> {
    var u_3: vec2<f32>;
    var intensity_3: f32;
    var ratio_3: f32;
    var invModelTransform_5: mat3x3<f32>;
    var Y_2: f32;
    var dx_1: f32;
    var delta_2: vec2<f32>;

    u_3 = u_2;
    intensity_3 = intensity_2;
    ratio_3 = ratio_2;
    invModelTransform_5 = invModelTransform_4;
    let _e14 = u_3;
    Y_2 = ((_e14.y - (floor((_e14.y / 1f)) * 1f)) * 4f);
    let _e24 = Y_2;
    let _e27 = Y_2;
    if ((_e24 > 1f) && (_e27 < 3.5f)) {
        {
            let _e32 = Y_2;
            Y_2 = (1f + (pow(((_e32 - 1f) / 2.5f), 12f) * 2.5f));
        }
    }
    let _e43 = Y_2;
    let _e45 = logistic(0.5f, _e43, 15i);
    dx_1 = _e45;
    let _e47 = ratio_3;
    let _e48 = dx_1;
    let _e50 = intensity_3;
    delta_2 = vec2<f32>(((_e47 * _e48) * _e50), 0f);
    let _e55 = delta_2;
    let _e56 = invModelTransform_5;
    let _e63 = mat2x2<f32>(_e56[0].xy, _e56[1].xy);
    let _e68 = invModelTransform_5[0][0];
    let _e73 = invModelTransform_5[0][1];
    let _e76 = vec2(length(vec2<f32>(_e68, _e73)));
    delta_2 = (_e55 * mat2x2<f32>((_e63[0] / _e76), (_e63[1] / _e76)));
    let _e83 = delta_2;
    return _e83;
}

fn getMultiSine1_(p_2: vec2<f32>, k_2: f32, invModelTransform_6: mat3x3<f32>) -> vec2<f32> {
    var p_3: vec2<f32>;
    var k_3: f32;
    var invModelTransform_7: mat3x3<f32>;
    var delta_3: vec2<f32>;

    p_3 = p_2;
    k_3 = k_2;
    invModelTransform_7 = invModelTransform_6;
    let _e12 = p_3;
    p_3 = (_e12 * 4f);
    let _e16 = k_3;
    let _e20 = p_3;
    let _e27 = p_3;
    let _e32 = p_3;
    let _e40 = p_3;
    let _e48 = p_3;
    let _e53 = p_3;
    let _e62 = p_3;
    let _e70 = p_3;
    let _e75 = p_3;
    delta_3 = ((0.3f * _e16) * vec2<f32>(((((1f + sin((0.54f * _e20.y))) * sin(((4f * sin((0.98f * _e27.y))) * _e32.y))) + ((0.5f + (0.5f * cos((1.54f * _e40.y)))) * cos(((9f * cos((3.75f * _e48.y))) * _e53.y)))) + ((0.25f + (0.25f * cos((3.421f * _e62.y)))) * cos(((18f * cos((8.5f * _e70.y))) * _e75.y)))), 0f));
    let _e85 = delta_3;
    let _e86 = invModelTransform_7;
    let _e93 = mat2x2<f32>(_e86[0].xy, _e86[1].xy);
    let _e98 = invModelTransform_7[0][0];
    let _e103 = invModelTransform_7[0][1];
    let _e106 = vec2(length(vec2<f32>(_e98, _e103)));
    delta_3 = (_e85 * mat2x2<f32>((_e93[0] / _e106), (_e93[1] / _e106)));
    let _e114 = delta_3;
    return (0.5f * _e114);
}

fn getMultiSine2_(p_4: vec2<f32>, k_4: f32, invModelTransform_8: mat3x3<f32>) -> vec2<f32> {
    var p_5: vec2<f32>;
    var k_5: f32;
    var invModelTransform_9: mat3x3<f32>;
    var z: f32;
    var y: f32;
    var delta_4: vec2<f32>;

    p_5 = p_4;
    k_5 = k_4;
    invModelTransform_9 = invModelTransform_8;
    let _e12 = p_5;
    z = fract(((_e12.y * 0.13123f) + 565.444f));
    let _e20 = z;
    let _e21 = z;
    z = fract(((_e20 * _e21) * 412.55f));
    let _e26 = z;
    z = pow(abs(((_e26 * 2f) - 1f)), 4f);
    let _e34 = p_5;
    y = _e34.y;
    let _e37 = z;
    let _e38 = k_5;
    let _e42 = y;
    let _e48 = y;
    let _e52 = y;
    let _e59 = y;
    let _e66 = y;
    let _e70 = y;
    delta_4 = ((_e37 * _e38) * vec2<f32>((((1f + sin((0.4f * _e42))) * sin(((4f * sin((0.98f * _e48))) * _e52))) + ((0.3f + (0.3f * cos((1.54f * _e59)))) * cos(((9f * cos((3.75f * _e66))) * _e70)))), 0f));
    let _e79 = delta_4;
    let _e80 = invModelTransform_9;
    let _e87 = mat2x2<f32>(_e80[0].xy, _e80[1].xy);
    let _e92 = invModelTransform_9[0][0];
    let _e97 = invModelTransform_9[0][1];
    let _e100 = vec2(length(vec2<f32>(_e92, _e97)));
    delta_4 = (_e79 * mat2x2<f32>((_e87[0] / _e100), (_e87[1] / _e100)));
    let _e108 = delta_4;
    return (0.5f * _e108);
}

fn getPerlin(p_6: vec2<f32>, power: f32, k_6: f32, invModelTransform_10: mat3x3<f32>) -> vec2<f32> {
    var p_7: vec2<f32>;
    var power_1: f32;
    var k_7: f32;
    var invModelTransform_11: mat3x3<f32>;
    var delta_5: f32 = 0f;
    var scale_1: f32 = 0.5f;
    var i_2: i32 = 0i;
    var p0_1: f32;
    var p1_1: f32;
    var f_1: f32;

    p_7 = p_6;
    power_1 = power;
    k_7 = k_6;
    invModelTransform_11 = invModelTransform_10;
    let _e14 = p_7;
    p_7 = (_e14 * 10f);
    loop {
        let _e23 = i_2;
        if !((_e23 < 10i)) {
            break;
        }
        {
            let _e30 = p_7;
            p0_1 = floor(_e30.y);
            let _e34 = p_7;
            p1_1 = ceil(_e34.y);
            let _e38 = p_7;
            f_1 = fract(_e38.y);
            let _e42 = delta_5;
            let _e43 = p0_1;
            let _e44 = getRand(_e43);
            let _e45 = p1_1;
            let _e46 = getRand(_e45);
            let _e49 = f_1;
            let _e52 = scale_1;
            delta_5 = (_e42 + (mix(_e44, _e46, smoothstep(0f, 1f, _e49)) * _e52));
            let _e55 = scale_1;
            scale_1 = (_e55 * 0.5f);
            let _e58 = p_7;
            p_7 = (_e58 * 2f);
        }
        continuing {
            let _e27 = i_2;
            i_2 = (_e27 + 1i);
        }
    }
    let _e61 = invModelTransform_11;
    let _e68 = mat2x2<f32>(_e61[0].xy, _e61[1].xy);
    let _e73 = invModelTransform_11[0][0];
    let _e78 = invModelTransform_11[0][1];
    let _e81 = vec2(length(vec2<f32>(_e73, _e78)));
    let _e87 = delta_5;
    let _e88 = delta_5;
    let _e95 = power_1;
    let _e100 = k_7;
    return (mat2x2<f32>((_e68[0] / _e81), (_e68[1] / _e81)) * vec2<f32>(((_e87 * pow(clamp((abs(_e88) * 1.3f), 0f, 1f), (_e95 - 1f))) * _e100), 0f));
}

fn getRand4_(v: vec4<f32>) -> vec4<f32> {
    var v_1: vec4<f32>;

    v_1 = v;
    let _e8 = v_1;
    let _e10 = getRand(_e8.x);
    let _e11 = v_1;
    let _e13 = getRand(_e11.y);
    let _e14 = v_1;
    let _e16 = getRand(_e14.z);
    let _e17 = v_1;
    let _e19 = getRand(_e17.w);
    return vec4<f32>(_e10, _e13, _e16, _e19);
}

fn getPerlinSine(p_8: vec2<f32>, threshold_2: f32, k_8: f32, invModelTransform_12: mat3x3<f32>) -> vec2<f32> {
    var p_9: vec2<f32>;
    var threshold_3: f32;
    var k_9: f32;
    var invModelTransform_13: mat3x3<f32>;
    var Y_3: f32;
    var delta_6: vec4<f32> = vec4(0f);
    var scale_2: f32 = 0.5f;
    var i_3: i32 = 0i;
    var p0_2: f32;
    var p1_2: f32;
    var f_2: f32;
    var A: f32;
    var B: f32;
    var s: f32;

    p_9 = p_8;
    threshold_3 = threshold_2;
    k_9 = k_8;
    invModelTransform_13 = invModelTransform_12;
    let _e14 = p_9;
    p_9 = (_e14 * 15f);
    let _e17 = p_9;
    Y_3 = _e17.y;
    loop {
        let _e27 = i_3;
        if !((_e27 < 10i)) {
            break;
        }
        {
            let _e34 = p_9;
            p0_2 = floor(_e34.y);
            let _e38 = p_9;
            p1_2 = ceil(_e38.y);
            let _e42 = p_9;
            f_2 = fract(_e42.y);
            let _e46 = delta_6;
            let _e47 = p0_2;
            let _e48 = p0_2;
            let _e51 = p0_2;
            let _e54 = p0_2;
            let _e58 = getRand4_(vec4<f32>(_e47, (_e48 + 5f), (_e51 + 50f), (_e54 + 123f)));
            let _e59 = p1_2;
            let _e60 = p1_2;
            let _e63 = p1_2;
            let _e66 = p1_2;
            let _e70 = getRand4_(vec4<f32>(_e59, (_e60 + 5f), (_e63 + 50f), (_e66 + 123f)));
            let _e73 = f_2;
            let _e77 = scale_2;
            delta_6 = (_e46 + (mix(_e58, _e70, vec4(smoothstep(0f, 1f, _e73))) * _e77));
            let _e80 = scale_2;
            scale_2 = (_e80 * 0.5f);
            let _e83 = p_9;
            p_9 = (_e83 * 2f);
        }
        continuing {
            let _e31 = i_3;
            i_3 = (_e31 + 1i);
        }
    }
    let _e88 = threshold_3;
    let _e92 = delta_6;
    let _e94 = delta_6;
    A = smoothstep((-1f + _e88), -1f, (_e92.z * _e94.y));
    let _e100 = threshold_3;
    let _e103 = delta_6;
    let _e105 = delta_6;
    B = smoothstep((1f - _e100), 1f, (_e103.w * _e105.x));
    let _e110 = A;
    let _e111 = delta_6;
    let _e114 = Y_3;
    let _e117 = delta_6;
    let _e124 = B;
    let _e125 = delta_6;
    let _e128 = Y_3;
    let _e131 = delta_6;
    s = (((_e110 * _e111.x) * sin((_e114 * (0.5f + (0.125f * _e117.y))))) + ((_e124 * _e125.z) * sin((_e128 * (6f + (2f * _e131.w))))));
    let _e140 = invModelTransform_13;
    let _e147 = mat2x2<f32>(_e140[0].xy, _e140[1].xy);
    let _e152 = invModelTransform_13[0][0];
    let _e157 = invModelTransform_13[0][1];
    let _e160 = vec2(length(vec2<f32>(_e152, _e157)));
    let _e166 = s;
    let _e167 = k_9;
    return (mat2x2<f32>((_e147[0] / _e160), (_e147[1] / _e160)) * vec2<f32>(((_e166 * _e167) * 10f), 0f));
}

fn getDelta(u_4: vec2<f32>, intensity_4: f32, mode: f32, ratio_4: f32, invModelTransform_14: mat3x3<f32>) -> vec2<f32> {
    var u_5: vec2<f32>;
    var intensity_5: f32;
    var mode_1: f32;
    var ratio_5: f32;
    var invModelTransform_15: mat3x3<f32>;
    var modeCount: f32 = 11f;
    var scaledMode: f32;
    var fractMode: f32;
    var lowMode: f32;
    var highwMode: f32;

    u_5 = u_4;
    intensity_5 = intensity_4;
    mode_1 = mode;
    ratio_5 = ratio_4;
    invModelTransform_15 = invModelTransform_14;
    let _e18 = mode_1;
    let _e21 = modeCount;
    scaledMode = ((_e18 * 0.1f) * (_e21 - 1f));
    let _e26 = scaledMode;
    fractMode = fract(_e26);
    let _e29 = scaledMode;
    lowMode = floor(_e29);
    let _e32 = scaledMode;
    highwMode = ceil(_e32);
    let _e35 = lowMode;
    if (_e35 == 0f) {
        {
            let _e38 = u_5;
            let _e39 = intensity_5;
            let _e40 = ratio_5;
            let _e41 = invModelTransform_15;
            let _e42 = getLogistic(_e38, _e39, _e40, _e41);
            let _e43 = u_5;
            let _e44 = intensity_5;
            let _e45 = invModelTransform_15;
            let _e46 = getMultiSine2_(_e43, _e44, _e45);
            let _e47 = fractMode;
            return mix(_e42, _e46, vec2(_e47));
        }
    } else {
        let _e50 = lowMode;
        if (_e50 == 1f) {
            {
                let _e53 = u_5;
                let _e54 = intensity_5;
                let _e55 = invModelTransform_15;
                let _e56 = getMultiSine2_(_e53, _e54, _e55);
                let _e57 = u_5;
                let _e58 = intensity_5;
                let _e59 = ratio_5;
                let _e60 = invModelTransform_15;
                let _e61 = getLogisticCompensated(_e57, _e58, _e59, _e60);
                let _e62 = fractMode;
                return mix(_e56, _e61, vec2(_e62));
            }
        } else {
            let _e65 = lowMode;
            if (_e65 == 2f) {
                {
                    let _e68 = u_5;
                    let _e69 = intensity_5;
                    let _e70 = ratio_5;
                    let _e71 = invModelTransform_15;
                    let _e72 = getLogisticCompensated(_e68, _e69, _e70, _e71);
                    let _e73 = u_5;
                    let _e74 = intensity_5;
                    let _e75 = invModelTransform_15;
                    let _e76 = getMultiSine1_(_e73, _e74, _e75);
                    let _e77 = fractMode;
                    return mix(_e72, _e76, vec2(_e77));
                }
            } else {
                let _e80 = lowMode;
                if (_e80 == 3f) {
                    {
                        let _e83 = u_5;
                        let _e84 = intensity_5;
                        let _e85 = invModelTransform_15;
                        let _e86 = getMultiSine1_(_e83, _e84, _e85);
                        let _e87 = u_5;
                        let _e89 = intensity_5;
                        let _e90 = invModelTransform_15;
                        let _e91 = getPerlin(_e87, 1f, _e89, _e90);
                        let _e92 = fractMode;
                        return mix(_e86, _e91, vec2(_e92));
                    }
                } else {
                    let _e95 = lowMode;
                    if (_e95 == 4f) {
                        {
                            let _e98 = u_5;
                            let _e101 = fractMode;
                            let _e103 = intensity_5;
                            let _e104 = invModelTransform_15;
                            let _e105 = getPerlin(_e98, mix(1f, 5f, _e101), _e103, _e104);
                            return _e105;
                        }
                    } else {
                        let _e106 = lowMode;
                        if (_e106 == 5f) {
                            {
                                let _e109 = u_5;
                                let _e111 = intensity_5;
                                let _e112 = invModelTransform_15;
                                let _e113 = getPerlin(_e109, 5f, _e111, _e112);
                                let _e114 = u_5;
                                let _e116 = intensity_5;
                                let _e119 = invModelTransform_15;
                                let _e120 = getPerlin(_e114, 2f, (_e116 * 0.1f), _e119);
                                let _e121 = fractMode;
                                return mix(_e113, _e120, vec2(_e121));
                            }
                        } else {
                            let _e124 = lowMode;
                            if (_e124 == 6f) {
                                {
                                    let _e127 = u_5;
                                    let _e129 = intensity_5;
                                    let _e132 = invModelTransform_15;
                                    let _e133 = getPerlin(_e127, 2f, (_e129 * 0.1f), _e132);
                                    let _e134 = u_5;
                                    let _e137 = invModelTransform_15;
                                    let _e138 = getPerlinSine(_e134, 1f, 1f, _e137);
                                    let _e139 = fractMode;
                                    return mix(_e133, _e138, vec2(_e139));
                                }
                            } else {
                                let _e142 = lowMode;
                                if (_e142 == 7f) {
                                    {
                                        let _e145 = u_5;
                                        let _e148 = fractMode;
                                        let _e150 = intensity_5;
                                        let _e153 = fractMode;
                                        let _e156 = invModelTransform_15;
                                        let _e157 = getPerlinSine(_e145, mix(1f, 5f, _e148), (_e150 * mix(1f, 0.1f, _e153)), _e156);
                                        return _e157;
                                    }
                                } else {
                                    let _e158 = lowMode;
                                    if (_e158 == 8f) {
                                        {
                                            let _e161 = u_5;
                                            let _e163 = intensity_5;
                                            let _e166 = invModelTransform_15;
                                            let _e167 = getPerlinSine(_e161, 5f, (_e163 * 0.1f), _e166);
                                            let _e168 = u_5;
                                            let _e171 = intensity_5;
                                            let _e172 = invModelTransform_15;
                                            let _e173 = getHighVariance(_e168, -0.5f, _e171, _e172);
                                            let _e174 = fractMode;
                                            return mix(_e167, _e173, vec2(_e174));
                                        }
                                    } else {
                                        let _e177 = lowMode;
                                        if (_e177 == 9f) {
                                            {
                                                let _e180 = u_5;
                                                let _e184 = fractMode;
                                                let _e186 = intensity_5;
                                                let _e187 = invModelTransform_15;
                                                let _e188 = getHighVariance(_e180, mix(-0.5f, 0.5f, _e184), _e186, _e187);
                                                return _e188;
                                            }
                                        } else {
                                            {
                                                let _e189 = u_5;
                                                let _e191 = intensity_5;
                                                let _e192 = invModelTransform_15;
                                                let _e193 = getHighVariance(_e189, 0.5f, _e191, _e192);
                                                return _e193;
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
}

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x_4: f32;
    var y_1: f32;

    co_1 = co;
    let _e8 = co_1;
    x_4 = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x_4;
    let _e20 = co_1;
    y_1 = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x_4;
    let _e33 = y_1;
    return (vec2<f32>(_e32, _e33) - vec2<f32>(0.5f, 0.5f));
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn multiShift(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity_6: f32, mode_2: f32, scatter: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_7: f32;
    var mode_3: f32;
    var scatter_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var ratio_6: f32;
    var invModelTransform_16: mat3x3<f32>;
    var u_8: vec2<f32>;
    var delta_7: vec2<f32>;
    var scattering: f32;
    var k_10: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_7 = intensity_6;
    mode_3 = mode_2;
    scatter_1 = scatter;
    modelTransform_1 = modelTransform;
    let _e20 = sourceDim_1;
    let _e22 = sourceDim_1;
    ratio_6 = (_e20.x / _e22.y);
    let _e26 = modelTransform_1;
    invModelTransform_16 = _naga_inverse_3x3_f32(_e26);
    let _e29 = invModelTransform_16;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    u_8 = _e31;
    let _e33 = u_8;
    let _e34 = intensity_7;
    let _e35 = mode_3;
    let _e36 = ratio_6;
    let _e37 = invModelTransform_16;
    let _e38 = getDelta(_e33, _e34, _e35, _e36, _e37);
    delta_7 = _e38;
    let _e40 = scatter_1;
    scatter_1 = (_e40 * 2f);
    let _e43 = scatter_1;
    if (_e43 > 0f) {
        {
            let _e47 = scatter_1;
            let _e50 = scatter_1;
            let _e56 = u_8;
            scattering = smoothstep((1f - _e47), (1f - (_e50 * 0.5f)), (0.5f + (0.5f * sin((_e56.y * 5f)))));
            let _e66 = u_8;
            let _e67 = rand2rel(_e66);
            let _e70 = scattering;
            k_10 = mix(1f, abs(_e67.x), _e70);
            let _e73 = k_10;
            let _e74 = delta_7;
            delta_7 = (_e73 * _e74);
        }
    }
    let _e76 = uv_1;
    let _e77 = delta_7;
    let _e82 = global.U[0];
    let _e85 = uv_1;
    let _e86 = delta_7;
    let _e96 = _mirror_wrap(((vec2<f32>(((_e76 + _e77).x / _e82.x), (_e85 + _e86).y) / vec2(2f)) + vec2(0.5f)));
    let _e97 = textureSample(t_source, samp, _e96);
    return _e97;
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
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = multiShift((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
