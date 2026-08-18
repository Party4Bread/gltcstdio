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

fn distToCrossPartial(p: vec2<f32>, center: vec2<f32>, r1_: f32, r2_: f32) -> f32 {
    var p_1: vec2<f32>;
    var center_1: vec2<f32>;
    var r1_1: f32;
    var r2_1: f32;

    p_1 = p;
    center_1 = center;
    r1_1 = r1_;
    r2_1 = r2_;
    let _e14 = p_1;
    p_1 = abs(_e14);
    let _e16 = p_1;
    let _e18 = p_1;
    let _e21 = p_1;
    let _e23 = p_1;
    p_1 = vec2<f32>(max(_e16.x, _e18.y), min(_e21.x, _e23.y));
    let _e27 = p_1;
    let _e28 = center_1;
    let _e30 = r1_1;
    let _e31 = r2_1;
    let _e32 = p_1;
    return length(((_e27 - _e28) - vec2<f32>(clamp(_e30, _e31, _e32.x), 0f)));
}

fn distToSquare(p_2: vec2<f32>, center_2: vec2<f32>, radius: f32) -> f32 {
    var p_3: vec2<f32>;
    var center_3: vec2<f32>;
    var radius_1: f32;

    p_3 = p_2;
    center_3 = center_2;
    radius_1 = radius;
    let _e12 = p_3;
    let _e13 = center_3;
    p_3 = abs((_e12 - _e13));
    let _e16 = p_3;
    let _e18 = p_3;
    let _e21 = p_3;
    let _e23 = p_3;
    p_3 = vec2<f32>(max(_e16.x, _e18.y), min(_e21.x, _e23.y));
    let _e27 = p_3;
    let _e28 = radius_1;
    let _e30 = radius_1;
    let _e31 = p_3;
    return length((_e27 - vec2<f32>(_e28, clamp(0f, _e30, _e31.y))));
}

fn distToTarget1_(p_4: vec2<f32>, center_4: vec2<f32>, r: f32) -> f32 {
    var p_5: vec2<f32>;
    var center_5: vec2<f32>;
    var r_1: f32;

    p_5 = p_4;
    center_5 = center_4;
    r_1 = r;
    let _e12 = p_5;
    let _e13 = center_5;
    let _e14 = r_1;
    let _e17 = distToSquare(_e12, _e13, (_e14 * 0.3f));
    let _e18 = p_5;
    let _e19 = center_5;
    let _e20 = r_1;
    let _e23 = r_1;
    let _e24 = distToCrossPartial(_e18, _e19, (_e20 * 0.3f), _e23);
    return min(_e17, _e24);
}

fn distToArc(p_6: vec2<f32>, center_6: vec2<f32>, radius_2: f32, angBegin: f32, angEnd: f32) -> f32 {
    var p_7: vec2<f32>;
    var center_7: vec2<f32>;
    var radius_3: f32;
    var angBegin_1: f32;
    var angEnd_1: f32;
    var centerToP: vec2<f32>;
    var angle: f32;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_7 = p_6;
    center_7 = center_6;
    radius_3 = radius_2;
    angBegin_1 = angBegin;
    angEnd_1 = angEnd;
    let _e16 = p_7;
    let _e17 = center_7;
    centerToP = (_e16 - _e17);
    let _e20 = centerToP;
    let _e22 = centerToP;
    angle = atan2(_e20.y, _e22.x);
    let _e26 = angle;
    let _e27 = angBegin_1;
    let _e29 = angle;
    let _e30 = angEnd_1;
    if ((_e26 >= _e27) && (_e29 <= _e30)) {
        {
            let _e33 = p_7;
            let _e34 = center_7;
            let _e37 = radius_3;
            return abs((length((_e33 - _e34)) - _e37));
        }
    } else {
        {
            let _e40 = center_7;
            let _e41 = radius_3;
            let _e42 = angBegin_1;
            let _e44 = angBegin_1;
            a = (_e40 + (_e41 * vec2<f32>(cos(_e42), sin(_e44))));
            let _e50 = center_7;
            let _e51 = radius_3;
            let _e52 = angEnd_1;
            let _e54 = angEnd_1;
            b = (_e50 + (_e51 * vec2<f32>(cos(_e52), sin(_e54))));
            let _e60 = p_7;
            let _e61 = a;
            let _e64 = p_7;
            let _e65 = b;
            return min(length((_e60 - _e61)), length((_e64 - _e65)));
        }
    }
}

fn distToTarget2_(p_8: vec2<f32>, center_8: vec2<f32>, r_2: f32) -> f32 {
    var p_9: vec2<f32>;
    var center_9: vec2<f32>;
    var r_3: f32;

    p_9 = p_8;
    center_9 = center_8;
    r_3 = r_2;
    let _e12 = p_9;
    let _e13 = center_9;
    let _e14 = r_3;
    let _e20 = distToArc(_e12, _e13, (_e14 * 0.5f), -3.1415927f, 3.1415927f);
    let _e21 = p_9;
    let _e22 = center_9;
    let _e23 = r_3;
    let _e26 = r_3;
    let _e27 = distToCrossPartial(_e21, _e22, (_e23 * 0.5f), _e26);
    return min(_e20, _e27);
}

fn distToFullCircle(p_10: vec2<f32>, center_10: vec2<f32>, radius_4: f32) -> f32 {
    var p_11: vec2<f32>;
    var center_11: vec2<f32>;
    var radius_5: f32;

    p_11 = p_10;
    center_11 = center_10;
    radius_5 = radius_4;
    let _e13 = p_11;
    let _e14 = center_11;
    let _e17 = radius_5;
    return max(0f, (length((_e13 - _e14)) - _e17));
}

fn min4n(a_1: f32, b_1: f32, c: f32, d: f32) -> f32 {
    var a_2: f32;
    var b_2: f32;
    var c_1: f32;
    var d_1: f32;

    a_2 = a_1;
    b_2 = b_1;
    c_1 = c;
    d_1 = d;
    let _e14 = a_2;
    let _e15 = d_1;
    let _e17 = b_2;
    let _e18 = c_1;
    return min(min(_e14, _e15), min(_e17, _e18));
}

fn distToTarget3_(p_12: vec2<f32>, center_12: vec2<f32>, r_4: f32) -> f32 {
    var p_13: vec2<f32>;
    var center_13: vec2<f32>;
    var r_5: f32;

    p_13 = p_12;
    center_13 = center_12;
    r_5 = r_4;
    let _e12 = p_13;
    let _e13 = center_13;
    let _e14 = r_5;
    let _e23 = distToArc(_e12, _e13, (_e14 * 0.3f), -2.6415927f, -0.5f);
    let _e24 = p_13;
    let _e25 = center_13;
    let _e26 = r_5;
    let _e33 = distToArc(_e24, _e25, (_e26 * 0.3f), 0.5f, 2.6415927f);
    let _e34 = p_13;
    let _e35 = center_13;
    let _e36 = r_5;
    let _e39 = r_5;
    let _e40 = distToCrossPartial(_e34, _e35, (_e36 * 0.3f), _e39);
    let _e41 = p_13;
    let _e42 = center_13;
    let _e43 = r_5;
    let _e46 = distToFullCircle(_e41, _e42, (_e43 * 0.1f));
    let _e47 = min4n(_e23, _e33, _e40, _e46);
    return _e47;
}

fn distToTarget4_(p_14: vec2<f32>, center_14: vec2<f32>, r_6: f32) -> f32 {
    var p_15: vec2<f32>;
    var center_15: vec2<f32>;
    var r_7: f32;

    p_15 = p_14;
    center_15 = center_14;
    r_7 = r_6;
    let _e12 = p_15;
    let _e13 = center_15;
    let _e14 = r_7;
    let _e20 = distToArc(_e12, _e13, (_e14 * 0.15f), -3.1415927f, 3.1415927f);
    let _e21 = p_15;
    let _e22 = center_15;
    let _e23 = r_7;
    let _e29 = distToArc(_e21, _e22, (_e23 * 0.3f), -3.1415927f, 3.1415927f);
    let _e30 = p_15;
    let _e31 = center_15;
    let _e32 = r_7;
    let _e38 = distToArc(_e30, _e31, (_e32 * 0.45f), -3.1415927f, 3.1415927f);
    let _e39 = p_15;
    let _e40 = center_15;
    let _e41 = r_7;
    let _e44 = r_7;
    let _e45 = distToCrossPartial(_e39, _e40, (_e41 * 0.15f), _e44);
    let _e46 = min4n(_e20, _e29, _e38, _e45);
    return _e46;
}

fn distToSegment(p_16: vec2<f32>, a_3: vec2<f32>, b_3: vec2<f32>) -> f32 {
    var p_17: vec2<f32>;
    var a_4: vec2<f32>;
    var b_4: vec2<f32>;
    var ab: vec2<f32>;
    var abLen: f32;
    var abNorm: vec2<f32>;
    var ap: vec2<f32>;
    var abProj: f32;

    p_17 = p_16;
    a_4 = a_3;
    b_4 = b_3;
    let _e12 = b_4;
    let _e13 = a_4;
    ab = (_e12 - _e13);
    let _e16 = ab;
    abLen = length(_e16);
    let _e19 = abLen;
    if (_e19 == 0f) {
        let _e22 = p_17;
        let _e23 = a_4;
        return length((_e22 - _e23));
    }
    let _e26 = ab;
    let _e27 = abLen;
    abNorm = (_e26 / vec2(_e27));
    let _e31 = p_17;
    let _e32 = a_4;
    ap = (_e31 - _e32);
    let _e35 = ap;
    let _e36 = abNorm;
    abProj = dot(_e35, _e36);
    let _e39 = abProj;
    let _e42 = abProj;
    let _e43 = abLen;
    if ((_e39 >= 0f) && (_e42 <= _e43)) {
        {
            let _e46 = ap;
            let _e47 = abNorm;
            let _e49 = abNorm;
            return abs(dot(_e46, vec2<f32>(_e47.y, -(_e49.x))));
        }
    } else {
        {
            let _e55 = ap;
            let _e57 = p_17;
            let _e58 = b_4;
            return min(length(_e55), length((_e57 - _e58)));
        }
    }
}

fn distToRadialTicks2_(p_18: vec2<f32>, center_16: vec2<f32>, n: i32, r1_2: f32, r2_2: f32, angBegin_2: f32, angEnd_2: f32) -> f32 {
    var p_19: vec2<f32>;
    var center_17: vec2<f32>;
    var n_1: i32;
    var r1_3: f32;
    var r2_3: f32;
    var angBegin_3: f32;
    var angEnd_3: f32;
    var d_2: f32 = 10000000000f;
    var centerToP_1: vec2<f32>;
    var ang: f32;
    var dAng: f32;
    var nd: f32;
    var dir1_: vec2<f32>;
    var dir2_: vec2<f32>;

    p_19 = p_18;
    center_17 = center_16;
    n_1 = n;
    r1_3 = r1_2;
    r2_3 = r2_2;
    angBegin_3 = angBegin_2;
    angEnd_3 = angEnd_2;
    let _e22 = p_19;
    let _e23 = center_17;
    centerToP_1 = (_e22 - _e23);
    let _e26 = centerToP_1;
    let _e28 = centerToP_1;
    ang = atan2(_e26.y, _e28.x);
    let _e32 = angEnd_3;
    let _e33 = angBegin_3;
    let _e35 = n_1;
    dAng = ((_e32 - _e33) / f32(_e35));
    let _e39 = ang;
    let _e40 = dAng;
    nd = floor((_e39 / _e40));
    let _e44 = nd;
    let _e45 = dAng;
    let _e48 = nd;
    let _e49 = dAng;
    dir1_ = vec2<f32>(cos((_e44 * _e45)), sin((_e48 * _e49)));
    let _e54 = nd;
    let _e57 = dAng;
    let _e60 = nd;
    let _e63 = dAng;
    dir2_ = vec2<f32>(cos(((_e54 + 1f) * _e57)), sin(((_e60 + 1f) * _e63)));
    let _e68 = d_2;
    let _e69 = p_19;
    let _e70 = center_17;
    let _e71 = r1_3;
    let _e72 = dir1_;
    let _e75 = center_17;
    let _e76 = r2_3;
    let _e77 = dir1_;
    let _e80 = distToSegment(_e69, (_e70 + (_e71 * _e72)), (_e75 + (_e76 * _e77)));
    d_2 = min(_e68, _e80);
    let _e82 = d_2;
    let _e83 = p_19;
    let _e84 = center_17;
    let _e85 = r1_3;
    let _e86 = dir2_;
    let _e89 = center_17;
    let _e90 = r2_3;
    let _e91 = dir2_;
    let _e94 = distToSegment(_e83, (_e84 + (_e85 * _e86)), (_e89 + (_e90 * _e91)));
    d_2 = min(_e82, _e94);
    let _e96 = d_2;
    return _e96;
}

fn min3n(a_5: f32, b_5: f32, c_2: f32) -> f32 {
    var a_6: f32;
    var b_6: f32;
    var c_3: f32;

    a_6 = a_5;
    b_6 = b_5;
    c_3 = c_2;
    let _e12 = a_6;
    let _e13 = b_6;
    let _e14 = c_3;
    return min(_e12, min(_e13, _e14));
}

fn distToTarget5_(p_20: vec2<f32>, center_18: vec2<f32>, r_8: f32) -> f32 {
    var p_21: vec2<f32>;
    var center_19: vec2<f32>;
    var r_9: f32;

    p_21 = p_20;
    center_19 = center_18;
    r_9 = r_8;
    let _e12 = p_21;
    let _e13 = center_19;
    let _e15 = r_9;
    let _e18 = r_9;
    let _e24 = distToRadialTicks2_(_e12, _e13, 32i, (_e15 * 0.3f), (_e18 * 0.45f), -3.1415927f, 3.1415927f);
    let _e25 = p_21;
    let _e26 = center_19;
    let _e28 = r_9;
    let _e31 = r_9;
    let _e37 = distToRadialTicks2_(_e25, _e26, 8i, (_e28 * 0.3f), (_e31 * 0.6f), -3.1415927f, 3.1415927f);
    let _e38 = p_21;
    let _e39 = center_19;
    let _e40 = r_9;
    let _e43 = r_9;
    let _e44 = distToCrossPartial(_e38, _e39, (_e40 * 0.3f), _e43);
    let _e45 = min3n(_e24, _e37, _e44);
    return _e45;
}

fn distToRect(p_22: vec2<f32>, center_20: vec2<f32>, rx: f32, ry: f32) -> f32 {
    var p_23: vec2<f32>;
    var center_21: vec2<f32>;
    var rx_1: f32;
    var ry_1: f32;
    var radius_6: f32;

    p_23 = p_22;
    center_21 = center_20;
    rx_1 = rx;
    ry_1 = ry;
    let _e14 = rx_1;
    let _e15 = ry_1;
    radius_6 = min(_e14, _e15);
    let _e18 = p_23;
    let _e19 = center_21;
    p_23 = abs((_e18 - _e19));
    let _e22 = rx_1;
    let _e23 = ry_1;
    if (_e22 > _e23) {
        {
            let _e27 = p_23;
            let _e29 = rx_1;
            let _e31 = ry_1;
            p_23.x = max(0f, ((_e27.x - _e29) + _e31));
        }
    } else {
        {
            let _e36 = p_23;
            let _e38 = ry_1;
            let _e40 = rx_1;
            p_23.y = max(0f, ((_e36.y - _e38) + _e40));
        }
    }
    let _e43 = p_23;
    let _e45 = p_23;
    let _e48 = p_23;
    let _e50 = p_23;
    p_23 = vec2<f32>(max(_e43.x, _e45.y), min(_e48.x, _e50.y));
    let _e54 = p_23;
    let _e55 = radius_6;
    let _e57 = radius_6;
    let _e58 = p_23;
    return length((_e54 - vec2<f32>(_e55, clamp(0f, _e57, _e58.y))));
}

fn distToDottedRect(p_24: vec2<f32>, center_22: vec2<f32>, rx_2: f32, ry_2: f32) -> f32 {
    var p_25: vec2<f32>;
    var center_23: vec2<f32>;
    var rx_3: f32;
    var ry_3: f32;

    p_25 = p_24;
    center_23 = center_22;
    rx_3 = rx_2;
    ry_3 = ry_2;
    let _e14 = p_25;
    let _e15 = center_23;
    let _e16 = rx_3;
    let _e17 = ry_3;
    let _e18 = distToRect(_e14, _e15, _e16, _e17);
    let _e20 = p_25;
    let _e21 = center_23;
    let _e22 = rx_3;
    let _e23 = ry_3;
    let _e27 = distToFullCircle(_e20, _e21, (min(_e22, _e23) * 0.0001f));
    return min(_e18, (0.5f * _e27));
}

fn distToDottedSquare(p_26: vec2<f32>, center_24: vec2<f32>, radius_7: f32) -> f32 {
    var p_27: vec2<f32>;
    var center_25: vec2<f32>;
    var radius_8: f32;

    p_27 = p_26;
    center_25 = center_24;
    radius_8 = radius_7;
    let _e12 = p_27;
    let _e13 = center_25;
    let _e14 = radius_8;
    let _e15 = distToSquare(_e12, _e13, _e14);
    let _e17 = p_27;
    let _e18 = center_25;
    let _e19 = radius_8;
    let _e22 = distToFullCircle(_e17, _e18, (_e19 * 0.0001f));
    return min(_e15, (0.5f * _e22));
}

fn distToTarget6_(p_28: vec2<f32>, center_26: vec2<f32>, r_10: f32) -> f32 {
    var p_29: vec2<f32>;
    var center_27: vec2<f32>;
    var r_11: f32;
    var c_4: vec2<f32> = vec2<f32>(0f, 0f);
    var dx: vec2<f32> = vec2<f32>(0.25f, 0f);
    var dy: vec2<f32> = vec2<f32>(0f, 0.15f);

    p_29 = p_28;
    center_27 = center_26;
    r_11 = r_10;
    let _e24 = p_29;
    p_29 = abs(_e24);
    let _e26 = p_29;
    let _e27 = c_4;
    let _e28 = r_11;
    let _e29 = distToDottedSquare(_e26, _e27, _e28);
    let _e30 = p_29;
    let _e31 = c_4;
    let _e33 = dy;
    let _e36 = r_11;
    let _e37 = r_11;
    let _e40 = distToDottedRect(_e30, (_e31 + (2f * _e33)), _e36, (_e37 * 0.7f));
    let _e42 = p_29;
    let _e43 = c_4;
    let _e45 = dx;
    let _e48 = r_11;
    let _e51 = r_11;
    let _e52 = distToDottedRect(_e42, (_e43 + (2f * _e45)), (_e48 * 0.7f), _e51);
    let _e53 = p_29;
    let _e54 = c_4;
    let _e55 = dx;
    let _e57 = dy;
    let _e59 = r_11;
    let _e62 = r_11;
    let _e63 = distToDottedRect(_e53, ((_e54 + _e55) + _e57), (_e59 * 0.7f), _e62);
    return min(min(_e29, _e40), min(_e52, _e63));
}

fn distToTarget7_(p_30: vec2<f32>, center_28: vec2<f32>, r_12: f32, m: f32) -> f32 {
    var p_31: vec2<f32>;
    var center_29: vec2<f32>;
    var r_13: f32;
    var m_1: f32;
    var d_3: f32 = 10000000000f;
    var c_5: vec2<f32> = vec2<f32>(0f, 0f);

    p_31 = p_30;
    center_29 = center_28;
    r_13 = r_12;
    m_1 = m;
    let _e20 = p_31;
    let _e21 = center_29;
    p_31 = abs((_e20 - _e21));
    let _e24 = m_1;
    if ((_e24 - (floor((_e24 / 2f)) * 2f)) >= 1f) {
        let _e32 = d_3;
        let _e33 = p_31;
        let _e34 = c_5;
        let _e35 = r_13;
        let _e38 = r_13;
        let _e39 = distToCrossPartial(_e33, _e34, (_e35 * 0.3f), _e38);
        d_3 = min(_e32, _e39);
    }
    let _e41 = m_1;
    m_1 = (_e41 / 2f);
    let _e44 = m_1;
    if ((_e44 - (floor((_e44 / 2f)) * 2f)) >= 1f) {
        let _e52 = d_3;
        let _e53 = p_31;
        let _e54 = c_5;
        let _e56 = r_13;
        let _e59 = r_13;
        let _e65 = distToRadialTicks2_(_e53, _e54, 32i, (_e56 * 0.3f), (_e59 * 0.45f), -3.1415927f, 3.1415927f);
        d_3 = min(_e52, _e65);
    }
    let _e67 = m_1;
    m_1 = (_e67 / 2f);
    let _e70 = m_1;
    if ((_e70 - (floor((_e70 / 2f)) * 2f)) >= 1f) {
        let _e78 = d_3;
        let _e79 = p_31;
        let _e80 = c_5;
        let _e82 = r_13;
        let _e85 = r_13;
        let _e91 = distToRadialTicks2_(_e79, _e80, 8i, (_e82 * 0.3f), (_e85 * 0.6f), -3.1415927f, 3.1415927f);
        d_3 = min(_e78, _e91);
    }
    let _e93 = m_1;
    m_1 = (_e93 / 2f);
    let _e96 = m_1;
    if ((_e96 - (floor((_e96 / 2f)) * 2f)) >= 1f) {
        let _e104 = d_3;
        let _e105 = p_31;
        let _e106 = c_5;
        let _e107 = r_13;
        let _e110 = distToSquare(_e105, _e106, (_e107 * 0.5f));
        d_3 = min(_e104, _e110);
    }
    let _e112 = m_1;
    m_1 = (_e112 / 2f);
    let _e115 = m_1;
    if ((_e115 - (floor((_e115 / 2f)) * 2f)) >= 1f) {
        let _e123 = d_3;
        let _e124 = p_31;
        let _e125 = c_5;
        let _e126 = r_13;
        let _e129 = distToSquare(_e124, _e125, (_e126 * 0.3f));
        d_3 = min(_e123, _e129);
    }
    let _e131 = m_1;
    m_1 = (_e131 / 2f);
    let _e134 = m_1;
    if ((_e134 - (floor((_e134 / 2f)) * 2f)) >= 1f) {
        let _e142 = d_3;
        let _e143 = p_31;
        let _e144 = c_5;
        let _e145 = r_13;
        let _e151 = distToArc(_e143, _e144, (_e145 * 0.5f), -3.1415927f, 3.1415927f);
        d_3 = min(_e142, _e151);
    }
    let _e153 = m_1;
    m_1 = (_e153 / 2f);
    let _e156 = m_1;
    if ((_e156 - (floor((_e156 / 2f)) * 2f)) >= 1f) {
        let _e164 = d_3;
        let _e165 = p_31;
        let _e166 = c_5;
        let _e167 = r_13;
        let _e173 = distToArc(_e165, _e166, (_e167 * 0.3f), -3.1415927f, 3.1415927f);
        d_3 = min(_e164, _e173);
    }
    let _e175 = m_1;
    m_1 = (_e175 / 2f);
    let _e178 = m_1;
    if ((_e178 - (floor((_e178 / 3f)) * 3f)) >= 2f) {
        let _e186 = d_3;
        let _e187 = p_31;
        let _e188 = r_13;
        let _e191 = r_13;
        let _e195 = r_13;
        let _e198 = distToSquare(_e187, vec2<f32>((_e188 * 0.5f), (_e191 * 0.5f)), (_e195 * 0.1f));
        d_3 = min(_e186, _e198);
    } else {
        let _e200 = m_1;
        if ((_e200 - (floor((_e200 / 3f)) * 3f)) >= 1f) {
            let _e208 = d_3;
            let _e209 = p_31;
            let _e210 = r_13;
            let _e213 = r_13;
            let _e217 = r_13;
            let _e223 = distToArc(_e209, vec2<f32>((_e210 * 0.5f), (_e213 * 0.5f)), (_e217 * 0.1f), -3.1415927f, 3.1415927f);
            d_3 = min(_e208, _e223);
        }
    }
    let _e225 = m_1;
    m_1 = (_e225 / 3f);
    let _e228 = m_1;
    if ((_e228 - (floor((_e228 / 3f)) * 3f)) >= 2f) {
        let _e236 = d_3;
        let _e237 = p_31;
        let _e238 = r_13;
        let _e243 = r_13;
        let _e246 = distToSquare(_e237, vec2<f32>((_e238 * 0.8f), 0f), (_e243 * 0.1f));
        d_3 = min(_e236, _e246);
    } else {
        let _e248 = m_1;
        if ((_e248 - (floor((_e248 / 3f)) * 3f)) >= 1f) {
            let _e256 = d_3;
            let _e257 = p_31;
            let _e258 = r_13;
            let _e263 = r_13;
            let _e269 = distToArc(_e257, vec2<f32>((_e258 * 0.8f), 0f), (_e263 * 0.1f), -3.1415927f, 3.1415927f);
            d_3 = min(_e256, _e269);
        }
    }
    let _e271 = m_1;
    m_1 = (_e271 / 3f);
    let _e274 = d_3;
    return _e274;
}

fn distToTarget(u: vec2<f32>, radius_9: f32, m_2: i32) -> f32 {
    var u_1: vec2<f32>;
    var radius_10: f32;
    var m_3: i32;

    u_1 = u;
    radius_10 = radius_9;
    m_3 = m_2;
    let _e12 = m_3;
    if (_e12 == 0i) {
        let _e15 = u_1;
        let _e20 = distToTarget6_(_e15, vec2<f32>(0f, 0f), 0.035f);
        return _e20;
    } else {
        let _e21 = m_3;
        if (_e21 == 1i) {
            let _e24 = u_1;
            let _e28 = radius_10;
            let _e29 = distToTarget1_(_e24, vec2<f32>(0f, 0f), _e28);
            return _e29;
        } else {
            let _e30 = m_3;
            if (_e30 == 2i) {
                let _e33 = u_1;
                let _e37 = radius_10;
                let _e38 = distToTarget2_(_e33, vec2<f32>(0f, 0f), _e37);
                return _e38;
            } else {
                let _e39 = m_3;
                if (_e39 == 3i) {
                    let _e42 = u_1;
                    let _e46 = radius_10;
                    let _e47 = distToTarget3_(_e42, vec2<f32>(0f, 0f), _e46);
                    return _e47;
                } else {
                    let _e48 = m_3;
                    if (_e48 == 4i) {
                        let _e51 = u_1;
                        let _e55 = radius_10;
                        let _e56 = distToTarget4_(_e51, vec2<f32>(0f, 0f), _e55);
                        return _e56;
                    } else {
                        let _e57 = m_3;
                        if (_e57 == 5i) {
                            let _e60 = u_1;
                            let _e64 = radius_10;
                            let _e65 = distToTarget5_(_e60, vec2<f32>(0f, 0f), _e64);
                            return _e65;
                        } else {
                            let _e66 = u_1;
                            let _e70 = radius_10;
                            let _e71 = m_3;
                            let _e73 = distToTarget7_(_e66, vec2<f32>(0f, 0f), _e70, f32(_e71));
                            return _e73;
                        }
                    }
                }
            }
        }
    }
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

fn response(d_4: f32, thickness: f32, blur: f32) -> f32 {
    var d_5: f32;
    var thickness_1: f32;
    var blur_1: f32;

    d_5 = d_4;
    thickness_1 = thickness;
    blur_1 = blur;
    let _e12 = thickness_1;
    let _e13 = thickness_1;
    let _e14 = blur_1;
    let _e16 = d_5;
    return pow(smoothstep(_e12, (_e13 + _e14), _e16), 0.3f);
}

fn tf(m_4: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_5: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_5 = m_4;
    u_3 = u_2;
    let _e10 = m_5;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn targetGraphics(uv: vec2<f32>, outPos: vec2<f32>, count: i32, mode: i32, randomSeed: f32, thickness_2: f32, color: vec4<f32>, glow: f32, variability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var mode_1: i32;
    var randomSeed_1: f32;
    var thickness_3: f32;
    var color_1: vec4<f32>;
    var glow_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u_4: vec2<f32>;
    var scale: f32;
    var cellScale: f32 = 1f;
    var d_6: f32;
    var id: vec2<f32>;
    var m_6: i32;
    var blur_2: f32;
    var k: f32;
    var gg: f32;
    var addK: f32;
    var bkgCol: vec4<f32>;
    var shapeRgb: vec3<f32>;
    var overCol: vec4<f32>;
    var addRgb: vec3<f32>;
    var addCol: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_1 = count;
    mode_1 = mode;
    randomSeed_1 = randomSeed;
    thickness_3 = thickness_2;
    color_1 = color;
    glow_1 = glow;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    let _e26 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e26);
    let _e29 = invModelTransform;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    u_4 = _e31;
    let _e35 = invModelTransform[0];
    scale = length(_e35.xy);
    let _e39 = thickness_3;
    let _e44 = scale;
    thickness_3 = ((pow(_e39, 2f) * 0.25f) * _e44);
    let _e49 = mode_1;
    if (_e49 < 0i) {
        {
            let _e52 = u_4;
            id = floor((_e52 + vec2(0.5f)));
            let _e58 = id;
            let _e60 = id;
            let _e63 = mode_1;
            let _e64 = f32(_e63);
            m_6 = i32((_e58.x + (_e60.y * (50f - (_e64 - (floor((_e64 / 100f)) * 100f))))));
            let _e76 = mode_1;
            cellScale = (1f - (f32((_e76 / 100i)) * 0.1f));
            let _e83 = u_4;
            let _e91 = cellScale;
            let _e94 = m_6;
            let _e95 = distToTarget(((fract((_e83 + vec2(0.5f))) - vec2(0.5f)) * _e91), 0.5f, _e94);
            d_6 = _e95;
        }
    } else {
        {
            let _e96 = u_4;
            let _e98 = mode_1;
            let _e99 = distToTarget(_e96, 0.5f, _e98);
            d_6 = _e99;
        }
    }
    let _e100 = glow_1;
    blur_2 = _e100;
    let _e102 = d_6;
    let _e103 = thickness_3;
    let _e104 = cellScale;
    let _e106 = blur_2;
    let _e109 = scale;
    let _e111 = response(_e102, (_e103 * _e104), ((_e106 * 0.2f) * _e109));
    k = _e111;
    let _e115 = blur_2;
    let _e123 = k;
    gg = ((0.025f * max(0f, ((_e115 * 100f) - 50f))) * pow((1f - _e123), 10f));
    let _e131 = blur_2;
    addK = smoothstep(0.5f, 1f, _e131);
    let _e134 = uv_1;
    let _e138 = global.U[0];
    let _e141 = uv_1;
    let _e150 = textureSample(t_source, samp, ((vec2<f32>((_e134.x / _e138.x), _e141.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e150;
    let _e152 = color_1;
    let _e154 = gg;
    let _e155 = gg;
    let _e156 = gg;
    let _e159 = gg;
    shapeRgb = ((_e152.xyz + vec3<f32>(_e154, _e155, _e156)) * (_e159 + 1f));
    let _e164 = bkgCol;
    let _e165 = shapeRgb;
    let _e166 = color_1;
    let _e169 = k;
    let _e176 = mergeColor(_e164, vec4<f32>(_e165.x, _e165.y, _e165.z, (_e166.w * (1f - _e169))));
    overCol = _e176;
    let _e178 = bkgCol;
    let _e180 = shapeRgb;
    let _e181 = color_1;
    let _e184 = bkgCol;
    let _e188 = color_1;
    addRgb = mix(_e178.xyz, _e180, vec3((_e181.w + ((1f - _e184.w) * (1f - _e188.w)))));
    let _e196 = addRgb;
    let _e198 = k;
    let _e201 = bkgCol;
    let _e203 = bkgCol;
    let _e206 = ((_e196 * (1f - _e198)) + (_e201.xyz * _e203.w));
    let _e208 = bkgCol;
    let _e210 = color_1;
    let _e213 = k;
    addCol = vec4<f32>(_e206.x, _e206.y, _e206.z, min(1f, (_e208.w + (_e210.w * (1f - _e213)))));
    let _e223 = overCol;
    let _e224 = addCol;
    let _e225 = addK;
    outCol = mix(_e223, _e224, vec4(_e225));
    let _e229 = outCol;
    return _e229;
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e118 = targetGraphics((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, _e87.x, _e91.x, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)));
    fragColor = _e118;
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
