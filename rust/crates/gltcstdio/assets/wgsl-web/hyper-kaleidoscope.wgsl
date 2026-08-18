struct Params {
    U: array<vec4<f32>, 16>,
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

const MAX_ITER: i32 = 30i;
const MAX_POLY_SIDES: i32 = 12i;

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
    let _e11 = c_1;
    let _e13 = vec2(2f);
    return (vec2(1f) - abs(((_e11 - (floor((_e11 / _e13)) * _e13)) - vec2(1f))));
}

fn getCircle(a: vec2<f32>, b: vec2<f32>, c_2: vec2<f32>) -> vec3<f32> {
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var c_3: vec2<f32>;
    var det: f32;
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
    var denom_f: f32;
    var denom_g: f32;
    var f: f32;
    var g: f32;
    var center: vec2<f32>;

    a_1 = a;
    b_1 = b;
    c_3 = c_2;
    let _e14 = a_1;
    let _e16 = b_1;
    let _e19 = a_1;
    let _e21 = c_3;
    let _e25 = a_1;
    let _e27 = c_3;
    let _e30 = a_1;
    let _e32 = b_1;
    det = (((_e14.x - _e16.x) * (_e19.y - _e21.y)) - ((_e25.x - _e27.x) * (_e30.y - _e32.y)));
    let _e38 = det;
    if (abs(_e38) < 0.000000001f) {
        {
            return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
        }
    }
    let _e46 = a_1;
    let _e48 = b_1;
    x12_ = (_e46.x - _e48.x);
    let _e52 = a_1;
    let _e54 = c_3;
    x13_ = (_e52.x - _e54.x);
    let _e58 = c_3;
    let _e60 = a_1;
    x31_ = (_e58.x - _e60.x);
    let _e64 = b_1;
    let _e66 = a_1;
    x21_ = (_e64.x - _e66.x);
    let _e70 = a_1;
    let _e72 = b_1;
    y12_ = (_e70.y - _e72.y);
    let _e76 = a_1;
    let _e78 = c_3;
    y13_ = (_e76.y - _e78.y);
    let _e82 = c_3;
    let _e84 = a_1;
    y31_ = (_e82.y - _e84.y);
    let _e88 = b_1;
    let _e90 = a_1;
    y21_ = (_e88.y - _e90.y);
    let _e94 = a_1;
    let _e96 = a_1;
    let _e99 = c_3;
    let _e101 = c_3;
    sx13_ = ((_e94.x * _e96.x) - (_e99.x * _e101.x));
    let _e106 = a_1;
    let _e108 = a_1;
    let _e111 = c_3;
    let _e113 = c_3;
    sy13_ = ((_e106.y * _e108.y) - (_e111.y * _e113.y));
    let _e118 = b_1;
    let _e120 = b_1;
    let _e123 = a_1;
    let _e125 = a_1;
    sx21_ = ((_e118.x * _e120.x) - (_e123.x * _e125.x));
    let _e130 = b_1;
    let _e132 = b_1;
    let _e135 = a_1;
    let _e137 = a_1;
    sy21_ = ((_e130.y * _e132.y) - (_e135.y * _e137.y));
    let _e143 = y31_;
    let _e144 = x12_;
    let _e146 = y21_;
    let _e147 = x13_;
    denom_f = (2f * ((_e143 * _e144) - (_e146 * _e147)));
    let _e153 = x31_;
    let _e154 = y12_;
    let _e156 = x21_;
    let _e157 = y13_;
    denom_g = (2f * ((_e153 * _e154) - (_e156 * _e157)));
    let _e162 = denom_f;
    let _e166 = denom_g;
    if ((abs(_e162) < 0.000000001f) || (abs(_e166) < 0.000000001f)) {
        {
            return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
        }
    }
    let _e175 = sx13_;
    let _e176 = x12_;
    let _e178 = sy13_;
    let _e179 = x12_;
    let _e182 = sx21_;
    let _e183 = x13_;
    let _e186 = sy21_;
    let _e187 = x13_;
    let _e190 = denom_f;
    f = (((((_e175 * _e176) + (_e178 * _e179)) + (_e182 * _e183)) + (_e186 * _e187)) / _e190);
    let _e193 = sx13_;
    let _e194 = y12_;
    let _e196 = sy13_;
    let _e197 = y12_;
    let _e200 = sx21_;
    let _e201 = y13_;
    let _e204 = sy21_;
    let _e205 = y13_;
    let _e208 = denom_g;
    g = (((((_e193 * _e194) + (_e196 * _e197)) + (_e200 * _e201)) + (_e204 * _e205)) / _e208);
    let _e211 = g;
    let _e213 = f;
    center = vec2<f32>(-(_e211), -(_e213));
    let _e217 = center;
    let _e218 = a_1;
    let _e219 = center;
    return vec3<f32>(_e217.x, _e217.y, length((_e218 - _e219)));
}

fn invert(p: vec2<f32>, c_4: vec2<f32>, r: f32) -> vec2<f32> {
    var p_1: vec2<f32>;
    var c_5: vec2<f32>;
    var r_1: f32;
    var v: vec2<f32>;
    var l2_: f32;

    p_1 = p;
    c_5 = c_4;
    r_1 = r;
    let _e14 = p_1;
    let _e15 = c_5;
    v = (_e14 - _e15);
    let _e18 = v;
    let _e19 = v;
    l2_ = dot(_e18, _e19);
    let _e22 = l2_;
    if (_e22 < 0.000000000001f) {
        {
            let _e25 = c_5;
            let _e26 = v;
            return (_e25 + (normalize(_e26) * 1000000000000000000f));
        }
    }
    let _e31 = c_5;
    let _e32 = v;
    let _e33 = r_1;
    let _e34 = r_1;
    let _e36 = l2_;
    return (_e31 + (_e32 * ((_e33 * _e34) / _e36)));
}

fn getCircleForArc(a_2: vec2<f32>, b_2: vec2<f32>) -> vec3<f32> {
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var a_inv: vec2<f32>;

    a_3 = a_2;
    b_3 = b_2;
    let _e12 = a_3;
    if (length(_e12) < 0.000000001f) {
        {
            return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
        }
    }
    let _e20 = a_3;
    let _e24 = invert(_e20, vec2(0f), 1f);
    a_inv = _e24;
    let _e26 = a_3;
    let _e27 = b_3;
    let _e28 = a_inv;
    let _e29 = getCircle(_e26, _e27, _e28);
    return _e29;
}

fn polyCenter(pts: array<vec2<f32>, 12>, p_2: i32) -> vec2<f32> {
    var pts_1: array<vec2<f32>, 12>;
    var p_3: i32;
    var total: vec2<f32> = vec2(0f);
    var count: i32;
    var i: i32 = 0i;

    pts_1 = pts;
    p_3 = p_2;
    let _e15 = p_3;
    if (_e15 <= 0i) {
        let _e18 = total;
        return _e18;
    }
    let _e19 = p_3;
    count = _e19;
    loop {
        let _e23 = i;
        let _e24 = count;
        if !((_e23 < _e24)) {
            break;
        }
        {
            let _e30 = total;
            let _e31 = i;
            let _e33 = pts_1[_e31];
            total = (_e30 + _e33);
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    let _e35 = total;
    let _e36 = count;
    return (_e35 / vec2(f32(_e36)));
}

fn getClosestEdge(pts_2: array<vec2<f32>, 12>, u: vec2<f32>, p_4: i32) -> i32 {
    var pts_3: array<vec2<f32>, 12>;
    var u_1: vec2<f32>;
    var p_5: i32;
    var max_proj: f32 = -1000000000f;
    var maxI: i32 = -1i;
    var c_6: vec2<f32>;
    var i_1: i32 = 0i;
    var a_4: vec2<f32>;
    var b_4: vec2<f32>;
    var dir: vec2<f32>;
    var ort: vec2<f32>;
    var dc: f32;
    var du: f32;
    var d: f32;

    pts_3 = pts_2;
    u_1 = u;
    p_5 = p_4;
    let _e20 = pts_3;
    let _e21 = p_5;
    let _e22 = polyCenter(_e20, _e21);
    c_6 = _e22;
    loop {
        let _e26 = i_1;
        let _e27 = p_5;
        if !((_e26 < _e27)) {
            break;
        }
        {
            let _e33 = i_1;
            let _e35 = pts_3[_e33];
            a_4 = _e35;
            let _e37 = i_1;
            let _e40 = f32((_e37 + 1i));
            let _e41 = p_5;
            let _e42 = f32(_e41);
            let _e49 = pts_3[i32((_e40 - (floor((_e40 / _e42)) * _e42)))];
            b_4 = _e49;
            let _e51 = b_4;
            let _e52 = a_4;
            dir = (_e51 - _e52);
            let _e55 = dir;
            if (length(_e55) < 0.000000001f) {
                continue;
            }
            let _e59 = dir;
            let _e62 = dir;
            ort = vec2<f32>(-(_e59.y), _e62.x);
            let _e66 = ort;
            let _e67 = c_6;
            let _e68 = a_4;
            dc = dot(_e66, (_e67 - _e68));
            let _e72 = ort;
            let _e73 = u_1;
            let _e74 = a_4;
            du = dot(_e72, (_e73 - _e74));
            let _e78 = dc;
            if (abs(_e78) < 0.000000001f) {
                {
                    continue;
                }
            }
            let _e82 = du;
            let _e84 = dc;
            d = (-(_e82) / _e84);
            let _e87 = d;
            let _e88 = max_proj;
            if (_e87 > _e88) {
                {
                    let _e90 = d;
                    max_proj = _e90;
                    let _e91 = i_1;
                    maxI = _e91;
                }
            }
        }
        continuing {
            let _e30 = i_1;
            i_1 = (_e30 + 1i);
        }
    }
    let _e92 = maxI;
    return _e92;
}

fn getInitD(p_6: f32, q: f32) -> f32 {
    var p_7: f32;
    var q_1: f32;
    var pi: f32 = 3.1415927f;
    var angle_q: f32;
    var angle_p: f32;
    var tan_q: f32;
    var tan_p: f32;
    var sum_tan: f32;
    var ratio: f32;

    p_7 = p_6;
    q_1 = q;
    let _e14 = pi;
    let _e17 = pi;
    let _e18 = q_1;
    angle_q = ((_e14 * 0.5f) - (_e17 / _e18));
    let _e22 = pi;
    let _e23 = p_7;
    angle_p = (_e22 / _e23);
    let _e26 = angle_q;
    tan_q = tan(_e26);
    let _e29 = angle_p;
    tan_p = tan(_e29);
    let _e32 = tan_q;
    let _e33 = tan_p;
    sum_tan = (_e32 + _e33);
    let _e36 = sum_tan;
    if (abs(_e36) < 0.000000001f) {
        return 1f;
    }
    let _e41 = tan_q;
    let _e42 = tan_p;
    let _e44 = sum_tan;
    ratio = ((_e41 - _e42) / _e44);
    let _e47 = ratio;
    if (_e47 < 0f) {
        return 0f;
    }
    let _e51 = ratio;
    return sqrt(_e51);
}

fn hash21_(p_8: vec2<f32>) -> f32 {
    var p_9: vec2<f32>;
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;

    p_9 = p_8;
    let _e12 = p_9;
    a_5 = fract((-45.3277f * _e12.xy));
    let _e17 = a_5;
    let _e18 = a_5;
    let _e19 = a_5;
    b_5 = (_e17 + vec2(dot(_e18, (_e19 + vec2(123.3371f)))));
    let _e27 = b_5;
    let _e29 = b_5;
    return fract((_e27.x * _e29.y));
}

fn hash22_(u_2: vec2<f32>) -> vec2<f32> {
    var u_3: vec2<f32>;

    u_3 = u_2;
    let _e10 = u_3;
    let _e14 = u_3;
    let _e23 = u_3;
    let _e27 = u_3;
    return vec2<f32>(fract((sin(((_e10.x * 776.45f) + (_e14.y * 453.24f))) * 45.77f)), fract((sin(((_e23.x * 376.45f) + (_e27.y * 853.24f))) * 88.77f)));
}

fn hexNearestCenter(p_10: vec2<f32>, r_2: f32) -> vec2<f32> {
    var p_11: vec2<f32>;
    var r_3: f32;
    var jc: f32;
    var ic: f32;
    var cube: vec3<f32>;
    var rounded: vec3<f32>;
    var diff: vec3<f32>;

    p_11 = p_10;
    r_3 = r_2;
    let _e12 = p_11;
    let _e14 = r_3;
    jc = (_e12.y / (_e14 * 1.7320508f));
    let _e19 = p_11;
    let _e21 = r_3;
    let _e23 = jc;
    ic = (((_e19.x / _e21) - _e23) * 0.5f);
    let _e28 = ic;
    let _e29 = jc;
    let _e30 = ic;
    let _e32 = jc;
    cube = vec3<f32>(_e28, _e29, (-(_e30) - _e32));
    let _e36 = cube;
    rounded = floor((_e36 + vec3(0.5f)));
    let _e42 = rounded;
    let _e43 = cube;
    diff = abs((_e42 - _e43));
    let _e47 = diff;
    let _e49 = diff;
    let _e52 = diff;
    let _e54 = diff;
    if ((_e47.x > _e49.y) && (_e52.x > _e54.z)) {
        let _e59 = rounded;
        let _e62 = rounded;
        rounded.x = (-(_e59.y) - _e62.z);
    } else {
        let _e65 = diff;
        let _e67 = diff;
        if (_e65.y > _e67.z) {
            let _e71 = rounded;
            let _e74 = rounded;
            rounded.y = (-(_e71.x) - _e74.z);
        } else {
            let _e78 = rounded;
            let _e81 = rounded;
            rounded.z = (-(_e78.x) - _e81.y);
        }
    }
    let _e85 = rounded;
    let _e88 = rounded;
    let _e91 = r_3;
    let _e93 = rounded;
    let _e95 = r_3;
    return vec2<f32>((((2f * _e85.x) + _e88.y) * _e91), ((_e93.y * _e95) * 1.7320508f));
}

fn inStraightPolygon(pts_4: array<vec2<f32>, 12>, u_4: vec2<f32>, p_12: i32) -> bool {
    var pts_5: array<vec2<f32>, 12>;
    var u_5: vec2<f32>;
    var p_13: i32;
    var s: f32 = 0f;
    var sign_set: bool = false;
    var i_2: i32 = 0i;
    var a_6: vec2<f32>;
    var b_6: vec2<f32>;
    var edge_vec: vec2<f32>;
    var delta: vec2<f32>;
    var normal: vec2<f32>;
    var newS: f32;

    pts_5 = pts_4;
    u_5 = u_4;
    p_13 = p_12;
    loop {
        let _e20 = i_2;
        let _e21 = p_13;
        if !((_e20 < _e21)) {
            break;
        }
        {
            let _e27 = i_2;
            let _e29 = pts_5[_e27];
            a_6 = _e29;
            let _e31 = i_2;
            let _e34 = f32((_e31 + 1i));
            let _e35 = p_13;
            let _e36 = f32(_e35);
            let _e43 = pts_5[i32((_e34 - (floor((_e34 / _e36)) * _e36)))];
            b_6 = _e43;
            let _e45 = b_6;
            let _e46 = a_6;
            edge_vec = (_e45 - _e46);
            let _e49 = edge_vec;
            if (length(_e49) < 0.000000001f) {
                continue;
            }
            let _e53 = edge_vec;
            delta = normalize(_e53);
            let _e56 = delta;
            let _e59 = delta;
            normal = vec2<f32>(-(_e56.y), _e59.x);
            let _e63 = normal;
            let _e64 = u_5;
            let _e65 = a_6;
            newS = dot(_e63, (_e64 - _e65));
            let _e69 = sign_set;
            let _e71 = newS;
            if (!(_e69) && (abs(_e71) > 0.000000001f)) {
                {
                    let _e76 = newS;
                    s = sign(_e76);
                    sign_set = true;
                }
            }
            let _e79 = sign_set;
            let _e80 = newS;
            let _e82 = s;
            if (_e79 && ((sign(_e80) * _e82) < -0.000000001f)) {
                {
                    return false;
                }
            }
        }
        continuing {
            let _e24 = i_2;
            i_2 = (_e24 + 1i);
        }
    }
    return true;
}

fn kaleidMap(pts_6: array<vec2<f32>, 12>, u_6: vec2<f32>, offang: f32, p_14: i32) -> vec2<f32> {
    var pts_7: array<vec2<f32>, 12>;
    var u_7: vec2<f32>;
    var offang_1: f32;
    var p_15: i32;
    var c_7: vec2<f32>;
    var delta_1: vec2<f32>;
    var triangle: array<vec2<f32>, 3>;
    var i_3: i32 = 0i;
    var side1_: vec2<f32>;
    var side2_: vec2<f32>;
    var det_1: f32;
    var k: f32;
    var l: f32;
    var angle: f32;
    var local: vec2<f32>;
    var w: vec2<f32>;

    pts_7 = pts_6;
    u_7 = u_6;
    offang_1 = offang;
    p_15 = p_14;
    let _e16 = pts_7;
    let _e17 = p_15;
    let _e18 = polyCenter(_e16, _e17);
    c_7 = _e18;
    let _e20 = u_7;
    let _e21 = c_7;
    delta_1 = (_e20 - _e21);
    let _e27 = c_7;
    triangle[0i] = _e27;
    loop {
        let _e30 = i_3;
        let _e31 = p_15;
        if !((_e30 < _e31)) {
            break;
        }
        {
            let _e39 = i_3;
            let _e41 = pts_7[_e39];
            triangle[1i] = _e41;
            let _e44 = i_3;
            let _e47 = f32((_e44 + 1i));
            let _e48 = p_15;
            let _e49 = f32(_e48);
            let _e56 = pts_7[i32((_e47 - (floor((_e47 / _e49)) * _e49)))];
            triangle[2i] = _e56;
            let _e59 = triangle[1];
            let _e60 = c_7;
            side1_ = (_e59 - _e60);
            let _e65 = triangle[2];
            let _e66 = c_7;
            side2_ = (_e65 - _e66);
            let _e69 = side1_;
            let _e71 = side2_;
            let _e74 = side1_;
            let _e76 = side2_;
            det_1 = ((_e69.x * _e71.y) - (_e74.y * _e76.x));
            let _e81 = det_1;
            if (abs(_e81) < 0.000000001f) {
                continue;
            }
            let _e85 = delta_1;
            let _e87 = side2_;
            let _e90 = delta_1;
            let _e92 = side2_;
            let _e96 = det_1;
            k = (((_e85.x * _e87.y) - (_e90.y * _e92.x)) / _e96);
            let _e99 = delta_1;
            let _e101 = side1_;
            let _e104 = delta_1;
            let _e106 = side1_;
            let _e110 = det_1;
            l = (((_e99.y * _e101.x) - (_e104.x * _e106.y)) / _e110);
            let _e113 = k;
            let _e117 = l;
            let _e122 = k;
            let _e123 = l;
            if (((_e113 >= -0.000001f) && (_e117 >= -0.000001f)) && ((_e122 + _e123) <= 1.000001f)) {
                {
                    let _e133 = p_15;
                    angle = (6.2831855f / f32(_e133));
                    let _e137 = l;
                    let _e138 = k;
                    if (_e137 < _e138) {
                        let _e140 = k;
                        let _e141 = l;
                        local = vec2<f32>(_e140, _e141);
                    } else {
                        let _e143 = l;
                        let _e144 = k;
                        local = vec2<f32>(_e143, _e144);
                    }
                    let _e147 = local;
                    w = _e147;
                    let _e149 = w;
                    let _e151 = offang_1;
                    let _e153 = offang_1;
                    let _e157 = w;
                    let _e159 = offang_1;
                    let _e160 = angle;
                    let _e163 = offang_1;
                    let _e164 = angle;
                    return ((_e149.x * vec2<f32>(cos(_e151), sin(_e153))) + (_e157.y * vec2<f32>(cos((_e159 + _e160)), sin((_e163 + _e164)))));
                }
            }
        }
        continuing {
            let _e34 = i_3;
            i_3 = (_e34 + 1i);
        }
    }
    let _e170 = u_7;
    let _e171 = c_7;
    return (_e170 - _e171);
}

fn makeDispCircle(u_8: vec2<f32>) -> vec3<f32> {
    var u_9: vec2<f32>;
    var l_1: f32;
    var d_1: f32;
    var x: f32;
    var r_sq: f32;
    var r_4: f32;

    u_9 = u_8;
    let _e10 = u_9;
    l_1 = length(_e10);
    let _e13 = l_1;
    if (_e13 < 0.000000001f) {
        {
            return vec3<f32>(0f, 0f, 1000000000f);
        }
    }
    let _e21 = l_1;
    d_1 = (1f / _e21);
    let _e25 = d_1;
    x = (1f + _e25);
    let _e28 = x;
    let _e29 = x;
    r_sq = ((_e28 * _e29) - 1f);
    let _e34 = r_sq;
    if (_e34 < 0f) {
        r_sq = 0f;
    }
    let _e38 = r_sq;
    r_4 = sqrt(_e38);
    let _e41 = x;
    let _e42 = u_9;
    let _e44 = (_e41 * normalize(_e42));
    let _e45 = r_4;
    return vec3<f32>(_e44.x, _e44.y, _e45);
}

fn makeInitial(d_2: f32, offset: f32, p_16: i32) -> array<vec2<f32>, 12> {
    var d_3: f32;
    var offset_1: f32;
    var p_17: i32;
    var pts_8: array<vec2<f32>, 12>;
    var ang: f32;
    var i_4: i32 = 0i;

    d_3 = d_2;
    offset_1 = offset;
    p_17 = p_16;
    let _e18 = p_17;
    ang = (6.2831855f / f32(_e18));
    loop {
        let _e24 = i_4;
        let _e25 = p_17;
        if !((_e24 < _e25)) {
            break;
        }
        {
            let _e31 = i_4;
            let _e33 = d_3;
            let _e34 = ang;
            let _e35 = i_4;
            let _e38 = offset_1;
            let _e41 = ang;
            let _e42 = i_4;
            let _e45 = offset_1;
            pts_8[_e31] = (_e33 * vec2<f32>(cos(((_e34 * f32(_e35)) + _e38)), sin(((_e41 * f32(_e42)) + _e45))));
        }
        continuing {
            let _e28 = i_4;
            i_4 = (_e28 + 1i);
        }
    }
    let _e50 = pts_8;
    return _e50;
}

fn tf(m: mat3x3<f32>, u_10: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_11: vec2<f32>;

    m_1 = m;
    u_11 = u_10;
    let _e12 = m_1;
    let _e13 = u_11;
    return (_e12 * vec3<f32>(_e13.x, _e13.y, 1f)).xy;
}

fn hyKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, p_18: i32, q_2: i32, viewTransform: mat3x3<f32>, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, offset_2: f32, thickness: f32, boundary: i32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var p_19: i32;
    var q_3: i32;
    var viewTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var offset_3: f32;
    var thickness_1: f32;
    var boundary_1: i32;
    var uv_len: f32;
    var texVar: mat3x3<f32> = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 0f, 1f));
    var texOff: vec2<f32> = vec2(0f);
    var k_1: f32;
    var lvl: f32;
    var t: vec2<f32>;
    var g_1: vec2<f32>;
    var cell: vec2<f32>;
    var lu: f32;
    var a_7: f32;
    var ca: f32;
    var sa: f32;
    var t_1: vec2<f32>;
    var size: f32 = 0.3f;
    var variability: f32 = 0.5f;
    var thick: f32;
    var innerR: f32;
    var innerRSq: f32;
    var origR2_: f32;
    var cellLocal: vec2<f32> = vec2(0f);
    var status: i32 = 0i;
    var l1R: f32;
    var l1Center: vec2<f32>;
    var l1Local: vec2<f32>;
    var l1Sq: f32;
    var l2R: f32;
    var gapDist: f32;
    var i_5: i32 = 0i;
    var ang_1: f32;
    var gapCenter: vec2<f32>;
    var l2Local: vec2<f32>;
    var l2Sq: f32;
    var gapKey: vec2<f32>;
    var initAngle: f32;
    var initD_val: f32;
    var P_canonical: array<vec2<f32>, 12>;
    var edgeCircles: array<vec3<f32>, 12>;
    var i_6: i32 = 0i;
    var a_8: vec2<f32>;
    var b_7: vec2<f32>;
    var B: vec2<f32>;
    var dispCircle: vec3<f32>;
    var u_12: vec2<f32>;
    var found: bool = false;
    var i_7: i32 = 0i;
    var edgeIdx: i32;
    var reflectCircle: vec3<f32>;
    var mapped_pos: vec2<f32>;
    var invTexTransform: mat3x3<f32>;
    var v_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    p_19 = p_18;
    q_3 = q_2;
    viewTransform_1 = viewTransform;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    offset_3 = offset_2;
    thickness_1 = thickness;
    boundary_1 = boundary;
    let _e28 = uv_1;
    uv_len = length(_e28);
    let _e41 = boundary_1;
    if (_e41 == 0i) {
        {
            let _e44 = uv_len;
            if (_e44 > 1f) {
                return vec4(0f);
            }
        }
    } else {
        let _e49 = boundary_1;
        if (_e49 == 1i) {
            {
                let _e52 = uv_len;
                if (_e52 > 1f) {
                    return vec4<f32>(0f, 0f, 0f, 1f);
                }
            }
        } else {
            let _e60 = boundary_1;
            if (_e60 == 3i) {
                {
                    let _e63 = uv_len;
                    if (_e63 > 1f) {
                        {
                            let _e66 = uv_len;
                            k_1 = floor(log2(_e66));
                            let _e70 = uv_1;
                            let _e71 = k_1;
                            uv_1 = (_e70 / vec2(exp2((_e71 + 1f))));
                            let _e77 = k_1;
                            lvl = (_e77 + 1f);
                            let _e82 = lvl;
                            let _e86 = lvl;
                            t = (vec2<f32>(sin((0.49f * _e82)), sin(((0.77f * _e86) + 1.5707963f))) * 0.3f);
                            let _e101 = t;
                            let _e103 = t;
                            texVar = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e101.x, _e103.y, 1f));
                        }
                    }
                }
            } else {
                let _e110 = boundary_1;
                if (_e110 == 4i) {
                    {
                        let _e113 = uv_1;
                        g_1 = (_e113 * 2f);
                        let _e117 = g_1;
                        cell = floor(((_e117 + vec2(1f)) * 0.5f));
                        let _e125 = g_1;
                        let _e128 = (_e125 + vec2(1f));
                        let _e130 = vec2(2f);
                        uv_1 = ((_e128 - (floor((_e128 / _e130)) * _e130)) - vec2(1f));
                        let _e138 = uv_1;
                        lu = length(_e138);
                        let _e141 = lu;
                        if (_e141 > 1f) {
                            {
                                let _e144 = lu;
                                let _e146 = thickness_1;
                                if (_e144 < (1f + _e146)) {
                                    return vec4<f32>(0f, 0f, 0f, 1f);
                                }
                                let _e154 = uv_1;
                                let _e156 = thickness_1;
                                let _e163 = invert((_e154 / vec2((1f + _e156))), vec2(0f), 1f);
                                uv_1 = _e163;
                            }
                        }
                        let _e164 = cell;
                        let _e165 = hash21_(_e164);
                        a_7 = (_e165 * 6.2831855f);
                        let _e169 = a_7;
                        ca = cos(_e169);
                        let _e172 = a_7;
                        sa = sin(_e172);
                        let _e175 = cell;
                        let _e179 = hash21_((_e175 + vec2(11.3f)));
                        let _e180 = cell;
                        let _e184 = hash21_((_e180 + vec2(27.9f)));
                        t_1 = (vec2<f32>(_e179, _e184) - vec2(0.5f));
                        let _e190 = ca;
                        let _e191 = sa;
                        let _e193 = sa;
                        let _e195 = ca;
                        let _e197 = t_1;
                        let _e199 = t_1;
                        texVar = mat3x3<f32>(vec3<f32>(_e190, _e191, 0f), vec3<f32>(-(_e193), _e195, 0f), vec3<f32>(_e197.x, _e199.y, 1f));
                    }
                } else {
                    let _e206 = boundary_1;
                    if (_e206 == 5i) {
                        {
                            let _e213 = thickness_1;
                            thick = clamp(_e213, 0f, 0.99f);
                            let _e219 = thick;
                            innerR = (1f - _e219);
                            let _e222 = innerR;
                            let _e223 = innerR;
                            innerRSq = (_e222 * _e223);
                            let _e226 = uv_1;
                            let _e227 = uv_1;
                            origR2_ = dot(_e226, _e227);
                            let _e235 = origR2_;
                            if (_e235 < 1f) {
                                {
                                    let _e238 = origR2_;
                                    let _e239 = innerRSq;
                                    if (_e238 > _e239) {
                                        status = 2i;
                                    } else {
                                        {
                                            let _e242 = uv_1;
                                            let _e243 = innerR;
                                            cellLocal = (_e242 / vec2(_e243));
                                            status = 1i;
                                        }
                                    }
                                }
                            } else {
                                {
                                    let _e247 = size;
                                    l1R = _e247;
                                    let _e249 = uv_1;
                                    let _e250 = l1R;
                                    let _e251 = hexNearestCenter(_e249, _e250);
                                    l1Center = _e251;
                                    let _e253 = uv_1;
                                    let _e254 = l1Center;
                                    let _e256 = l1R;
                                    l1Local = ((_e253 - _e254) / vec2(_e256));
                                    let _e260 = l1Local;
                                    let _e261 = l1Local;
                                    l1Sq = dot(_e260, _e261);
                                    let _e264 = l1Sq;
                                    if (_e264 < 1f) {
                                        {
                                            let _e267 = l1Sq;
                                            let _e268 = innerRSq;
                                            if (_e267 > _e268) {
                                                status = 2i;
                                            } else {
                                                {
                                                    let _e271 = l1Local;
                                                    let _e272 = innerR;
                                                    cellLocal = (_e271 / vec2(_e272));
                                                    let _e275 = l1Center;
                                                    let _e276 = hash22_(_e275);
                                                    let _e284 = variability;
                                                    texOff = ((((_e276 - vec2(0.5f)) * 2f) * 0.2f) * _e284);
                                                    status = 1i;
                                                }
                                            }
                                        }
                                    } else {
                                        {
                                            let _e287 = l1R;
                                            l2R = ((_e287 * 0.26794922f) / 1.7320508f);
                                            let _e295 = l1R;
                                            gapDist = ((_e295 * 2f) / 1.7320508f);
                                            loop {
                                                let _e303 = i_5;
                                                if !((_e303 < 6i)) {
                                                    break;
                                                }
                                                {
                                                    let _e316 = i_5;
                                                    ang_1 = (0.5235988f + (1.0471976f * f32(_e316)));
                                                    let _e321 = l1Center;
                                                    let _e322 = gapDist;
                                                    let _e323 = ang_1;
                                                    let _e325 = ang_1;
                                                    gapCenter = (_e321 + (_e322 * vec2<f32>(cos(_e323), sin(_e325))));
                                                    let _e331 = uv_1;
                                                    let _e332 = gapCenter;
                                                    let _e334 = l2R;
                                                    l2Local = ((_e331 - _e332) / vec2(_e334));
                                                    let _e338 = l2Local;
                                                    let _e339 = l2Local;
                                                    l2Sq = dot(_e338, _e339);
                                                    let _e342 = l2Sq;
                                                    if (_e342 < 1f) {
                                                        {
                                                            let _e345 = l2Sq;
                                                            let _e346 = innerRSq;
                                                            if (_e345 > _e346) {
                                                                {
                                                                    status = 2i;
                                                                    break;
                                                                }
                                                            }
                                                            let _e349 = gapCenter;
                                                            gapKey = (floor(((_e349 * 1000f) + vec2(0.5f))) * 0.001f);
                                                            let _e359 = l2Local;
                                                            let _e360 = innerR;
                                                            cellLocal = (_e359 / vec2(_e360));
                                                            let _e363 = gapKey;
                                                            let _e364 = hash22_(_e363);
                                                            let _e372 = variability;
                                                            texOff = ((((_e364 - vec2(0.5f)) * 2f) * 0.2f) * _e372);
                                                            status = 1i;
                                                            break;
                                                        }
                                                    }
                                                }
                                                continuing {
                                                    let _e307 = i_5;
                                                    i_5 = (_e307 + 1i);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            let _e375 = status;
                            if (_e375 != 1i) {
                                return vec4<f32>(0f, 0f, 0f, 1f);
                            }
                            let _e383 = cellLocal;
                            uv_1 = _e383;
                        }
                    } else {
                        {
                            let _e384 = uv_len;
                            if (_e384 > 1f) {
                                {
                                    let _e387 = uv_len;
                                    let _e389 = thickness_1;
                                    if (_e387 < (1f + _e389)) {
                                        return vec4<f32>(0f, 0f, 0f, 1f);
                                    }
                                    let _e397 = uv_1;
                                    let _e399 = thickness_1;
                                    let _e406 = invert((_e397 / vec2((1f + _e399))), vec2(0f), 1f);
                                    uv_1 = _e406;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e407 = p_19;
    let _e410 = p_19;
    if ((_e407 <= 0i) || (_e410 > MAX_POLY_SIDES)) {
        {
            return vec4<f32>(1f, 0f, 1f, 1f);
        }
    }
    let _e422 = modelTransform_1[0][1];
    let _e427 = modelTransform_1[0][0];
    initAngle = atan2(_e422, _e427);
    let _e430 = p_19;
    let _e432 = q_3;
    let _e434 = getInitD(f32(_e430), f32(_e432));
    initD_val = _e434;
    let _e436 = initD_val;
    let _e437 = initAngle;
    let _e438 = p_19;
    let _e439 = makeInitial(_e436, _e437, _e438);
    P_canonical = _e439;
    loop {
        let _e444 = i_6;
        let _e445 = p_19;
        if !((_e444 < _e445)) {
            break;
        }
        {
            let _e451 = i_6;
            let _e453 = P_canonical[_e451];
            a_8 = _e453;
            let _e455 = i_6;
            let _e458 = f32((_e455 + 1i));
            let _e459 = p_19;
            let _e460 = f32(_e459);
            let _e467 = P_canonical[i32((_e458 - (floor((_e458 / _e460)) * _e460)))];
            b_7 = _e467;
            let _e469 = i_6;
            let _e471 = a_8;
            let _e472 = b_7;
            let _e473 = getCircleForArc(_e471, _e472);
            edgeCircles[_e469] = _e473;
        }
        continuing {
            let _e448 = i_6;
            i_6 = (_e448 + 1i);
        }
    }
    let _e476 = modelTransform_1[2];
    B = _e476.xy;
    let _e479 = B;
    let _e480 = makeDispCircle(_e479);
    dispCircle = _e480;
    let _e482 = uv_1;
    u_12 = _e482;
    let _e484 = dispCircle;
    if (_e484.z < 100000000f) {
        {
            let _e488 = uv_1;
            let _e489 = dispCircle;
            let _e491 = dispCircle;
            let _e493 = invert(_e488, _e489.xy, _e491.z);
            u_12 = _e493;
        }
    }
    loop {
        let _e498 = i_7;
        if !((_e498 < MAX_ITER)) {
            break;
        }
        {
            let _e504 = P_canonical;
            let _e505 = u_12;
            let _e506 = p_19;
            let _e507 = inStraightPolygon(_e504, _e505, _e506);
            if _e507 {
                {
                    found = true;
                    break;
                }
            }
            let _e509 = P_canonical;
            let _e510 = u_12;
            let _e511 = p_19;
            let _e512 = getClosestEdge(_e509, _e510, _e511);
            edgeIdx = _e512;
            let _e514 = edgeIdx;
            let _e517 = edgeIdx;
            let _e518 = p_19;
            if ((_e514 < 0i) || (_e517 >= _e518)) {
                {
                    found = false;
                    break;
                }
            }
            let _e522 = edgeIdx;
            let _e524 = edgeCircles[_e522];
            reflectCircle = _e524;
            let _e526 = reflectCircle;
            if (_e526.z > 100000000f) {
                {
                    found = false;
                    break;
                }
            }
            let _e531 = u_12;
            let _e532 = reflectCircle;
            let _e534 = reflectCircle;
            let _e536 = invert(_e531, _e532.xy, _e534.z);
            u_12 = _e536;
        }
        continuing {
            let _e501 = i_7;
            i_7 = (_e501 + 1i);
        }
    }
    let _e537 = found;
    if _e537 {
        {
            let _e538 = P_canonical;
            let _e539 = u_12;
            let _e541 = p_19;
            let _e542 = kaleidMap(_e538, _e539, 0f, _e541);
            mapped_pos = _e542;
            let _e544 = mapped_pos;
            let _e545 = uv_1;
            let _e546 = offset_3;
            mapped_pos = (_e544 + (_e545 * _e546));
            let _e549 = texTransform_1;
            let _e551 = texVar;
            invTexTransform = (_naga_inverse_3x3_f32(_e549) * _e551);
            let _e554 = invTexTransform;
            let _e555 = mapped_pos;
            let _e556 = tf(_e554, _e555);
            let _e557 = texOff;
            v_1 = (_e556 + _e557);
            let _e560 = v_1;
            let _e564 = global.U[0];
            let _e567 = v_1;
            let _e576 = _mirror_wrap(((vec2<f32>((_e560.x / _e564.x), _e567.y) / vec2(2f)) + vec2(0.5f)));
            let _e578 = textureSampleLevel(t_source, samp, _e576, 0f);
            return _e578;
        }
    } else {
        {
            return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
        }
    }
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[5];
    let _e73 = global.U[6];
    let _e78 = global.U[1];
    let _e79 = _e78.xyz;
    let _e82 = global.U[2];
    let _e83 = _e82.xyz;
    let _e86 = global.U[3];
    let _e87 = _e86.xyz;
    let _e103 = global.U[7];
    let _e104 = _e103.xyz;
    let _e107 = global.U[8];
    let _e108 = _e107.xyz;
    let _e111 = global.U[9];
    let _e112 = _e111.xyz;
    let _e128 = global.U[10];
    let _e129 = _e128.xyz;
    let _e132 = global.U[11];
    let _e133 = _e132.xyz;
    let _e136 = global.U[12];
    let _e137 = _e136.xyz;
    let _e153 = global.U[13];
    let _e157 = global.U[14];
    let _e161 = global.U[15];
    let _e164 = hyKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)), mat3x3<f32>(vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z), vec3<f32>(_e137.x, _e137.y, _e137.z)), _e153.x, _e157.x, i32(_e161.x));
    fragColor = _e164;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
