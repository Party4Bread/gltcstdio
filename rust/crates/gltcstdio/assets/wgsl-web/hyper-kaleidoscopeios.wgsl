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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn circleIntersections(c1_: vec2<f32>, r1_: f32, c2_: vec2<f32>, r2_: f32) -> vec4<f32> {
    var c1_1: vec2<f32>;
    var r1_1: f32;
    var c2_1: vec2<f32>;
    var r2_1: f32;
    var d: f32;
    var x: f32;
    var y: f32;
    var M: vec2<f32>;
    var dir: vec2<f32>;
    var n: vec2<f32>;

    c1_1 = c1_;
    r1_1 = r1_;
    c2_1 = c2_;
    r2_1 = r2_;
    let _e14 = c1_1;
    let _e15 = c2_1;
    d = length((_e14 - _e15));
    let _e19 = r1_1;
    let _e20 = r2_1;
    let _e22 = d;
    if ((_e19 + _e20) < _e22) {
        return vec4(0f);
    }
    let _e26 = d;
    let _e27 = d;
    let _e29 = r2_1;
    let _e30 = r2_1;
    let _e33 = r1_1;
    let _e34 = r1_1;
    let _e38 = d;
    x = ((((_e26 * _e27) - (_e29 * _e30)) + (_e33 * _e34)) / (2f * _e38));
    let _e42 = r1_1;
    let _e43 = r1_1;
    let _e45 = x;
    let _e46 = x;
    y = sqrt(((_e42 * _e43) - (_e45 * _e46)));
    let _e51 = c1_1;
    let _e52 = c2_1;
    let _e53 = x;
    let _e54 = d;
    M = mix(_e51, _e52, vec2((_e53 / _e54)));
    let _e59 = c2_1;
    let _e60 = c1_1;
    dir = normalize((_e59 - _e60));
    let _e64 = dir;
    let _e67 = dir;
    n = vec2<f32>(-(_e64.x), _e67.y);
    let _e71 = M;
    let _e72 = y;
    let _e73 = n;
    let _e75 = (_e71 + (_e72 * _e73));
    let _e76 = M;
    let _e77 = y;
    let _e78 = n;
    let _e80 = (_e76 - (_e77 * _e78));
    return vec4<f32>(_e75.x, _e75.y, _e80.x, _e80.y);
}

fn polyCenter(pts: array<vec2<f32>, 12>, p: i32) -> vec2<f32> {
    var pts_1: array<vec2<f32>, 12>;
    var p_1: i32;
    var total: vec2<f32> = vec2(0f);
    var i: f32 = 0f;

    pts_1 = pts;
    p_1 = p;
    loop {
        let _e15 = i;
        let _e16 = p_1;
        if !((_e15 < f32(_e16))) {
            break;
        }
        {
            let _e23 = total;
            let _e24 = i;
            let _e27 = pts_1[i32(_e24)];
            total = (_e23 + _e27);
        }
        continuing {
            let _e20 = i;
            i = (_e20 + 1f);
        }
    }
    let _e29 = total;
    let _e30 = p_1;
    return (_e29 / vec2(f32(_e30)));
}

fn getClosestEdge(pts_2: array<vec2<f32>, 12>, u: vec2<f32>, p_2: i32) -> i32 {
    var pts_3: array<vec2<f32>, 12>;
    var u_1: vec2<f32>;
    var p_3: i32;
    var minD: f32 = -1000000000f;
    var minI: f32 = -1f;
    var c_2: vec2<f32>;
    var i_1: f32 = 0f;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var dir_1: vec2<f32>;
    var ort: vec2<f32>;
    var dc: f32;
    var du: f32;
    var d_1: f32;

    pts_3 = pts_2;
    u_1 = u;
    p_3 = p_2;
    let _e18 = pts_3;
    let _e19 = p_3;
    let _e20 = polyCenter(_e18, _e19);
    c_2 = _e20;
    loop {
        let _e24 = i_1;
        let _e25 = p_3;
        if !((_e24 < f32(_e25))) {
            break;
        }
        {
            let _e32 = i_1;
            let _e35 = pts_3[i32(_e32)];
            a = _e35;
            let _e37 = i_1;
            let _e39 = (_e37 + 1f);
            let _e40 = p_3;
            let _e41 = f32(_e40);
            let _e48 = pts_3[i32((_e39 - (floor((_e39 / _e41)) * _e41)))];
            b = _e48;
            let _e50 = b;
            let _e51 = a;
            dir_1 = (_e50 - _e51);
            let _e54 = dir_1;
            let _e57 = dir_1;
            ort = vec2<f32>(-(_e54.y), _e57.x);
            let _e61 = ort;
            let _e62 = c_2;
            let _e63 = a;
            dc = dot(_e61, (_e62 - _e63));
            let _e67 = ort;
            let _e68 = u_1;
            let _e69 = a;
            du = dot(_e67, (_e68 - _e69));
            let _e73 = du;
            let _e75 = dc;
            d_1 = (-(_e73) / _e75);
            let _e78 = d_1;
            let _e79 = minD;
            if (_e78 > _e79) {
                {
                    let _e81 = d_1;
                    minD = _e81;
                    let _e82 = i_1;
                    minI = _e82;
                }
            }
        }
        continuing {
            let _e29 = i_1;
            i_1 = (_e29 + 1f);
        }
    }
    let _e83 = minI;
    return i32(_e83);
}

fn invert(p_4: vec2<f32>, c_3: vec2<f32>, r: f32) -> vec2<f32> {
    var p_5: vec2<f32>;
    var c_4: vec2<f32>;
    var r_1: f32;
    var v: vec2<f32>;
    var l: f32;

    p_5 = p_4;
    c_4 = c_3;
    r_1 = r;
    let _e12 = p_5;
    let _e13 = c_4;
    v = (_e12 - _e13);
    let _e16 = p_5;
    let _e17 = c_4;
    l = length((_e16 - _e17));
    let _e21 = c_4;
    let _e22 = v;
    let _e23 = r_1;
    let _e25 = r_1;
    let _e27 = l;
    let _e28 = l;
    return (_e21 + (((_e22 * _e23) * _e25) / vec2((_e27 * _e28))));
}

fn invert_1(pts_4: array<vec2<f32>, 12>, c_5: vec2<f32>, r_2: f32, p_6: i32) -> array<vec2<f32>, 12> {
    var pts_5: array<vec2<f32>, 12>;
    var c_6: vec2<f32>;
    var r_3: f32;
    var p_7: i32;
    var outPts: array<vec2<f32>, 12>;
    var i_2: i32 = 0i;

    pts_5 = pts_4;
    c_6 = c_5;
    r_3 = r_2;
    p_7 = p_6;
    loop {
        let _e17 = i_2;
        let _e18 = p_7;
        if !((_e17 < _e18)) {
            break;
        }
        {
            let _e24 = i_2;
            let _e27 = i_2;
            let _e29 = pts_5[_e27];
            let _e30 = c_6;
            let _e31 = r_3;
            let _e32 = invert(_e29, _e30, _e31);
            outPts[i32(_e24)] = _e32;
        }
        continuing {
            let _e21 = i_2;
            i_2 = (_e21 + 1i);
        }
    }
    let _e33 = outPts;
    return _e33;
}

fn hyReflect(pts_6: array<vec2<f32>, 12>, circle: vec3<f32>, p_8: i32) -> array<vec2<f32>, 12> {
    var pts_7: array<vec2<f32>, 12>;
    var circle_1: vec3<f32>;
    var p_9: i32;
    var outPts_1: array<vec2<f32>, 12>;
    var i_3: f32 = 0f;

    pts_7 = pts_6;
    circle_1 = circle;
    p_9 = p_8;
    loop {
        let _e15 = i_3;
        let _e16 = p_9;
        if !((_e15 < f32(_e16))) {
            break;
        }
        {
            let _e23 = i_3;
            let _e26 = i_3;
            let _e29 = pts_7[i32(_e26)];
            let _e30 = circle_1;
            let _e32 = circle_1;
            let _e34 = invert(_e29, _e30.xy, _e32.z);
            outPts_1[i32(_e23)] = _e34;
        }
        continuing {
            let _e20 = i_3;
            i_3 = (_e20 + 1f);
        }
    }
    let _e35 = outPts_1;
    return _e35;
}

fn getCircle(a_1: vec2<f32>, b_1: vec2<f32>, c_7: vec2<f32>) -> vec3<f32> {
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var c_8: vec2<f32>;
    var x12_: f32;
    var x13_: f32;
    var x31_: f32;
    var x21_: f32;
    var y12_: f32;
    var y13_: f32;
    var y31_: f32;
    var y21_: f32;
    var sx13_: f32;
    var sy13_: f32;
    var sx21_: f32;
    var sy21_: f32;
    var f: f32;
    var g: f32;
    var center: vec2<f32>;

    a_2 = a_1;
    b_2 = b_1;
    c_8 = c_7;
    let _e12 = a_2;
    let _e14 = b_2;
    x12_ = (_e12.x - _e14.x);
    let _e18 = a_2;
    let _e20 = c_8;
    x13_ = (_e18.x - _e20.x);
    let _e24 = c_8;
    let _e26 = a_2;
    x31_ = (_e24.x - _e26.x);
    let _e30 = b_2;
    let _e32 = a_2;
    x21_ = (_e30.x - _e32.x);
    let _e36 = a_2;
    let _e38 = b_2;
    y12_ = (_e36.y - _e38.y);
    let _e42 = a_2;
    let _e44 = c_8;
    y13_ = (_e42.y - _e44.y);
    let _e48 = c_8;
    let _e50 = a_2;
    y31_ = (_e48.y - _e50.y);
    let _e54 = b_2;
    let _e56 = a_2;
    y21_ = (_e54.y - _e56.y);
    let _e60 = a_2;
    let _e64 = c_8;
    sx13_ = (pow(_e60.x, 2f) - pow(_e64.x, 2f));
    let _e70 = a_2;
    let _e74 = c_8;
    sy13_ = (pow(_e70.y, 2f) - pow(_e74.y, 2f));
    let _e80 = b_2;
    let _e84 = a_2;
    sx21_ = (pow(_e80.x, 2f) - pow(_e84.x, 2f));
    let _e90 = b_2;
    let _e94 = a_2;
    sy21_ = (pow(_e90.y, 2f) - pow(_e94.y, 2f));
    let _e100 = sx13_;
    let _e101 = x12_;
    let _e103 = sy13_;
    let _e104 = x12_;
    let _e107 = sx21_;
    let _e108 = x13_;
    let _e111 = sy21_;
    let _e112 = x13_;
    let _e116 = y31_;
    let _e117 = x12_;
    let _e119 = y21_;
    let _e120 = x13_;
    f = (((((_e100 * _e101) + (_e103 * _e104)) + (_e107 * _e108)) + (_e111 * _e112)) / (2f * ((_e116 * _e117) - (_e119 * _e120))));
    let _e126 = sx13_;
    let _e127 = y12_;
    let _e129 = sy13_;
    let _e130 = y12_;
    let _e133 = sx21_;
    let _e134 = y13_;
    let _e137 = sy21_;
    let _e138 = y13_;
    let _e142 = x31_;
    let _e143 = y12_;
    let _e145 = x21_;
    let _e146 = y13_;
    g = (((((_e126 * _e127) + (_e129 * _e130)) + (_e133 * _e134)) + (_e137 * _e138)) / (2f * ((_e142 * _e143) - (_e145 * _e146))));
    let _e152 = g;
    let _e154 = f;
    center = vec2<f32>(-(_e152), -(_e154));
    let _e158 = center;
    let _e159 = a_2;
    let _e160 = center;
    return vec3<f32>(_e158.x, _e158.y, length((_e159 - _e160)));
}

fn getCircleForArc(a_3: vec2<f32>, b_3: vec2<f32>) -> vec3<f32> {
    var a_4: vec2<f32>;
    var b_4: vec2<f32>;

    a_4 = a_3;
    b_4 = b_3;
    let _e10 = a_4;
    let _e11 = b_4;
    let _e12 = a_4;
    let _e17 = invert(_e12, vec2<f32>(0f, 0f), 1f);
    let _e18 = getCircle(_e10, _e11, _e17);
    return _e18;
}

fn hyReflect_1(pts_8: array<vec2<f32>, 12>, i_4: i32, p_10: i32) -> array<vec2<f32>, 12> {
    var pts_9: array<vec2<f32>, 12>;
    var i_5: i32;
    var p_11: i32;
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;

    pts_9 = pts_8;
    i_5 = i_4;
    p_11 = p_10;
    let _e12 = i_5;
    let _e14 = pts_9[_e12];
    a_5 = _e14;
    let _e16 = i_5;
    let _e19 = f32((_e16 + 1i));
    let _e20 = p_11;
    let _e21 = f32(_e20);
    let _e28 = pts_9[i32((_e19 - (floor((_e19 / _e21)) * _e21)))];
    b_5 = _e28;
    let _e30 = pts_9;
    let _e31 = a_5;
    let _e32 = b_5;
    let _e33 = getCircleForArc(_e31, _e32);
    let _e34 = p_11;
    let _e35 = hyReflect(_e30, _e33, _e34);
    return _e35;
}

fn inStraightPolygon(pts_10: array<vec2<f32>, 12>, u_2: vec2<f32>, p_12: i32) -> bool {
    var pts_11: array<vec2<f32>, 12>;
    var u_3: vec2<f32>;
    var p_13: i32;
    var s: f32 = 0f;
    var i_6: f32 = 0f;
    var a_6: vec2<f32>;
    var b_6: vec2<f32>;
    var delta: vec2<f32>;
    var newS: f32;

    pts_11 = pts_10;
    u_3 = u_2;
    p_13 = p_12;
    loop {
        let _e16 = i_6;
        let _e17 = p_13;
        if !((_e16 < f32(_e17))) {
            break;
        }
        {
            let _e24 = i_6;
            let _e27 = pts_11[i32(_e24)];
            a_6 = _e27;
            let _e29 = i_6;
            let _e31 = (_e29 + 1f);
            let _e32 = p_13;
            let _e33 = f32(_e32);
            let _e40 = pts_11[i32((_e31 - (floor((_e31 / _e33)) * _e33)))];
            b_6 = _e40;
            let _e42 = b_6;
            let _e43 = a_6;
            delta = normalize((_e42 - _e43));
            let _e47 = delta;
            let _e50 = delta;
            let _e53 = u_3;
            let _e54 = a_6;
            newS = dot(vec2<f32>(-(_e47.y), _e50.x), (_e53 - _e54));
            let _e58 = s;
            let _e60 = newS;
            if ((sign(_e58) * sign(_e60)) < 0f) {
                return false;
            }
            let _e66 = newS;
            if (_e66 != 0f) {
                let _e69 = newS;
                s = _e69;
            }
        }
        continuing {
            let _e21 = i_6;
            i_6 = (_e21 + 1f);
        }
    }
    return true;
}

fn kaleidMap(pts_12: array<vec2<f32>, 12>, u_4: vec2<f32>, offang: f32, p_14: i32) -> vec2<f32> {
    var pts_13: array<vec2<f32>, 12>;
    var u_5: vec2<f32>;
    var offang_1: f32;
    var p_15: i32;
    var c_9: vec2<f32>;
    var delta_1: vec2<f32>;
    var triangle: array<vec2<f32>, 3>;
    var i_7: f32 = 0f;
    var side1_: vec2<f32>;
    var side2_: vec2<f32>;
    var l_1: f32;
    var k: f32;
    var angle: f32;
    var local: vec2<f32>;
    var w: vec2<f32>;

    pts_13 = pts_12;
    u_5 = u_4;
    offang_1 = offang;
    p_15 = p_14;
    let _e14 = pts_13;
    let _e15 = p_15;
    let _e16 = polyCenter(_e14, _e15);
    c_9 = _e16;
    let _e18 = u_5;
    let _e19 = c_9;
    delta_1 = (_e18 - _e19);
    let _e25 = c_9;
    triangle[0i] = _e25;
    loop {
        let _e28 = i_7;
        let _e29 = p_15;
        if !((_e28 < f32(_e29))) {
            break;
        }
        {
            let _e38 = i_7;
            let _e41 = pts_13[i32(_e38)];
            triangle[1i] = _e41;
            let _e44 = i_7;
            let _e46 = (_e44 + 1f);
            let _e47 = p_15;
            let _e48 = f32(_e47);
            let _e55 = pts_13[i32((_e46 - (floor((_e46 / _e48)) * _e48)))];
            triangle[2i] = _e55;
            let _e58 = triangle[1];
            let _e59 = c_9;
            side1_ = (_e58 - _e59);
            let _e64 = triangle[2];
            let _e65 = c_9;
            side2_ = (_e64 - _e65);
            let _e68 = delta_1;
            let _e70 = side1_;
            let _e73 = delta_1;
            let _e75 = side1_;
            let _e79 = side1_;
            let _e81 = side2_;
            let _e84 = side1_;
            let _e86 = side2_;
            l_1 = (((_e68.y * _e70.x) - (_e73.x * _e75.y)) / ((_e79.x * _e81.y) - (_e84.y * _e86.x)));
            let _e92 = delta_1;
            let _e94 = l_1;
            let _e95 = side2_;
            let _e99 = side1_;
            k = ((_e92.x - (_e94 * _e95.x)) / _e99.x);
            let _e103 = l_1;
            let _e106 = k;
            let _e110 = l_1;
            let _e111 = k;
            if (((_e103 >= 0f) && (_e106 >= 0f)) && ((_e110 + _e111) <= 1f)) {
                {
                    let _e119 = p_15;
                    angle = (6.2831855f / f32(_e119));
                    let _e123 = l_1;
                    let _e124 = k;
                    if (_e123 < _e124) {
                        let _e126 = k;
                        let _e127 = l_1;
                        local = vec2<f32>(_e126, _e127);
                    } else {
                        let _e129 = l_1;
                        let _e130 = k;
                        local = vec2<f32>(_e129, _e130);
                    }
                    let _e133 = local;
                    w = _e133;
                    let _e135 = w;
                    let _e137 = offang_1;
                    let _e139 = offang_1;
                    let _e143 = w;
                    let _e145 = offang_1;
                    let _e146 = angle;
                    let _e149 = offang_1;
                    let _e150 = angle;
                    return ((_e135.x * vec2<f32>(cos(_e137), sin(_e139))) + (_e143.y * vec2<f32>(cos((_e145 + _e146)), sin((_e149 + _e150)))));
                }
            }
        }
        continuing {
            let _e33 = i_7;
            i_7 = (_e33 + 1f);
        }
    }
    let _e156 = c_9;
    let _e157 = delta_1;
    return (_e156 + vec2(length(_e157)));
}

fn findStraightPolygon(pts_14: array<vec2<f32>, 12>, u_6: vec2<f32>, N: i32, p_16: i32) -> vec2<f32> {
    var pts_15: array<vec2<f32>, 12>;
    var u_7: vec2<f32>;
    var N_1: i32;
    var p_17: i32;
    var code: f32 = 0f;
    var i_8: i32 = 0i;
    var edge: i32;

    pts_15 = pts_14;
    u_7 = u_6;
    N_1 = N;
    p_17 = p_16;
    loop {
        let _e18 = i_8;
        let _e19 = N_1;
        if !((_e18 < _e19)) {
            break;
        }
        {
            let _e25 = pts_15;
            let _e26 = u_7;
            let _e27 = p_17;
            let _e28 = inStraightPolygon(_e25, _e26, _e27);
            if _e28 {
                let _e29 = pts_15;
                let _e30 = u_7;
                let _e32 = p_17;
                let _e33 = kaleidMap(_e29, _e30, 0f, _e32);
                return _e33;
            }
            let _e34 = pts_15;
            let _e35 = u_7;
            let _e36 = p_17;
            let _e37 = getClosestEdge(_e34, _e35, _e36);
            edge = _e37;
            let _e39 = pts_15;
            let _e40 = edge;
            let _e41 = p_17;
            let _e42 = hyReflect_1(_e39, _e40, _e41);
            pts_15 = _e42;
            let _e43 = code;
            let _e44 = edge;
            let _e46 = p_17;
            let _e48 = i_8;
            code = (_e43 + (f32(_e44) * pow(f32(_e46), f32(_e48))));
        }
        continuing {
            let _e22 = i_8;
            i_8 = (_e22 + 1i);
        }
    }
    return vec2<f32>(1000000000f, 1000000000f);
}

fn getInitD(p_18: f32, q: f32) -> f32 {
    var p_19: f32;
    var q_1: f32;
    var pi: f32 = 3.1415927f;

    p_19 = p_18;
    q_1 = q;
    let _e12 = pi;
    let _e15 = pi;
    let _e16 = q_1;
    let _e20 = pi;
    let _e21 = p_19;
    let _e25 = pi;
    let _e28 = pi;
    let _e29 = q_1;
    let _e33 = pi;
    let _e34 = p_19;
    return sqrt(((tan(((_e12 * 0.5f) - (_e15 / _e16))) - tan((_e20 / _e21))) / (tan(((_e25 * 0.5f) - (_e28 / _e29))) + tan((_e33 / _e34)))));
}

fn makeDispCircle(u_8: vec2<f32>) -> vec3<f32> {
    var u_9: vec2<f32>;
    var l_2: f32;
    var d_2: f32;
    var x_1: f32;
    var r_4: f32;

    u_9 = u_8;
    let _e8 = u_9;
    l_2 = length((_e8 * 100f));
    let _e14 = l_2;
    d_2 = (1f / _e14);
    let _e18 = d_2;
    x_1 = (1f + _e18);
    let _e21 = x_1;
    let _e22 = x_1;
    r_4 = sqrt(((_e21 * _e22) - 1f));
    let _e28 = x_1;
    let _e29 = u_9;
    let _e31 = (_e28 * normalize(_e29));
    let _e32 = r_4;
    return vec3<f32>(_e31.x, _e31.y, _e32);
}

fn makeInitial(d_3: f32, offset: f32, p_20: i32) -> array<vec2<f32>, 12> {
    var d_4: f32;
    var offset_1: f32;
    var p_21: i32;
    var pts_16: array<vec2<f32>, 12>;
    var ang: f32;
    var i_9: f32 = 0f;

    d_4 = d_3;
    offset_1 = offset;
    p_21 = p_20;
    let _e16 = p_21;
    ang = (6.2831855f / f32(_e16));
    loop {
        let _e22 = i_9;
        let _e23 = p_21;
        if !((_e22 < f32(_e23))) {
            break;
        }
        {
            let _e30 = i_9;
            let _e33 = d_4;
            let _e34 = ang;
            let _e35 = i_9;
            let _e37 = offset_1;
            let _e40 = ang;
            let _e41 = i_9;
            let _e43 = offset_1;
            pts_16[i32(_e30)] = (_e33 * vec2<f32>(cos(((_e34 * _e35) + _e37)), sin(((_e40 * _e41) + _e43))));
        }
        continuing {
            let _e27 = i_9;
            i_9 = (_e27 + 1f);
        }
    }
    let _e48 = pts_16;
    return _e48;
}

fn tf(m: mat3x3<f32>, u_10: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_11: vec2<f32>;

    m_1 = m;
    u_11 = u_10;
    let _e10 = m_1;
    let _e11 = u_11;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn hyKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, p_22: i32, q_2: i32, viewTransform: mat3x3<f32>, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, offset_2: f32, thickness: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var p_23: i32;
    var q_3: i32;
    var viewTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var offset_3: f32;
    var thickness_1: f32;
    var initAngle: f32;
    var init: array<vec2<f32>, 12>;
    var B: vec2<f32>;
    var Bi: vec2<f32>;
    var M_1: vec2<f32>;
    var P: vec4<f32>;
    var circle_2: vec3<f32>;
    var f_1: vec2<f32>;
    var col: vec3<f32>;
    var v_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    p_23 = p_22;
    q_3 = q_2;
    viewTransform_1 = viewTransform;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    offset_3 = offset_2;
    thickness_1 = thickness;
    let _e24 = uv_1;
    if (length(_e24) > 1f) {
        {
            let _e28 = uv_1;
            let _e31 = thickness_1;
            if (length(_e28) < (1f + _e31)) {
                {
                    return vec4<f32>(0f, 0f, 0f, 1f);
                }
            } else {
                {
                    let _e39 = uv_1;
                    let _e41 = thickness_1;
                    let _e49 = invert((_e39 / vec2((1f + _e41))), vec2<f32>(0f, 0f), 1f);
                    uv_1 = _e49;
                }
            }
        }
    }
    let _e52 = modelTransform_1[0];
    let _e56 = modelTransform_1[0];
    initAngle = atan2(_e52.y, _e56.x);
    let _e60 = p_23;
    let _e62 = q_3;
    let _e64 = getInitD(f32(_e60), f32(_e62));
    let _e65 = initAngle;
    let _e66 = p_23;
    let _e67 = makeInitial(_e64, _e65, _e66);
    init = _e67;
    let _e71 = modelTransform_1[2];
    B = _e71.xy;
    let _e74 = B;
    let _e78 = B;
    if ((_e74.x == 0f) && (_e78.y == 0f)) {
        B = vec2<f32>(0.00001f, 0.00001f);
    }
    let _e86 = B;
    let _e91 = invert(_e86, vec2<f32>(0f, 0f), 1f);
    Bi = _e91;
    let _e93 = B;
    let _e94 = Bi;
    M_1 = mix(_e93, _e94, vec2(0.8f));
    let _e99 = M_1;
    let _e100 = M_1;
    let _e104 = B;
    let _e106 = circleIntersections(_e99, length(_e100), vec2(0f), length(_e104));
    P = _e106;
    let _e108 = B;
    let _e109 = makeDispCircle(_e108);
    circle_2 = _e109;
    let _e111 = init;
    let _e112 = circle_2;
    let _e114 = circle_2;
    let _e116 = p_23;
    let _e117 = invert_1(_e111, _e112.xy, _e114.z, _e116);
    init = _e117;
    let _e118 = init;
    let _e119 = uv_1;
    let _e121 = p_23;
    let _e122 = findStraightPolygon(_e118, _e119, 30i, _e121);
    let _e123 = uv_1;
    let _e124 = offset_3;
    f_1 = (_e122 + (_e123 * _e124));
    let _e129 = f_1;
    if (_e129.x < 1000000000f) {
        {
            let _e133 = f_1;
            col = vec3<f32>(_e133.x, _e133.y, 0.5f);
        }
    } else {
        {
            col = vec3(0f);
        }
    }
    let _e140 = texTransform_1;
    let _e142 = f_1;
    let _e143 = tf(_naga_inverse_3x3_f32(_e140), _e142);
    v_1 = _e143;
    let _e145 = v_1;
    let _e149 = global.U[0];
    let _e152 = v_1;
    let _e161 = _mirror_wrap(((vec2<f32>((_e145.x / _e149.x), _e152.y) / vec2(2f)) + vec2(0.5f)));
    let _e163 = textureSampleLevel(t_source, samp, _e161, 0f);
    return _e163;
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
    let _e76 = global.U[1];
    let _e77 = _e76.xyz;
    let _e80 = global.U[2];
    let _e81 = _e80.xyz;
    let _e84 = global.U[3];
    let _e85 = _e84.xyz;
    let _e101 = global.U[7];
    let _e102 = _e101.xyz;
    let _e105 = global.U[8];
    let _e106 = _e105.xyz;
    let _e109 = global.U[9];
    let _e110 = _e109.xyz;
    let _e126 = global.U[10];
    let _e127 = _e126.xyz;
    let _e130 = global.U[11];
    let _e131 = _e130.xyz;
    let _e134 = global.U[12];
    let _e135 = _e134.xyz;
    let _e151 = global.U[13];
    let _e155 = global.U[14];
    let _e157 = hyKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)), mat3x3<f32>(vec3<f32>(_e127.x, _e127.y, _e127.z), vec3<f32>(_e131.x, _e131.y, _e131.z), vec3<f32>(_e135.x, _e135.y, _e135.z)), _e151.x, _e155.x);
    fragColor = _e157;
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
