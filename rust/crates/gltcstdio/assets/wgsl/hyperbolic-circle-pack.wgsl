struct Params {
    U: array<vec4<f32>, 14>,
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
const RAND_AMP: f32 = 0.2f;

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
        return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
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
        return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
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
        let _e25 = c_5;
        let _e26 = v;
        return (_e25 + (normalize(_e26) * 1000000000000000000f));
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
        return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
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

fn polyCenter3_(pts: array<vec2<f32>, 3>) -> vec2<f32> {
    var pts_1: array<vec2<f32>, 3>;

    pts_1 = pts;
    let _e12 = pts_1[0];
    let _e15 = pts_1[1];
    let _e19 = pts_1[2];
    return (((_e12 + _e15) + _e19) / vec2(3f));
}

fn getClosestEdge3_(pts_2: array<vec2<f32>, 3>, u: vec2<f32>) -> i32 {
    var pts_3: array<vec2<f32>, 3>;
    var u_1: vec2<f32>;
    var max_proj: f32 = -1000000000f;
    var maxI: i32 = -1i;
    var c_6: vec2<f32>;
    var i: i32 = 0i;
    var a_4: vec2<f32>;
    var b_4: vec2<f32>;
    var dir: vec2<f32>;
    var ort: vec2<f32>;
    var dc: f32;
    var du: f32;
    var d: f32;

    pts_3 = pts_2;
    u_1 = u;
    let _e18 = pts_3;
    let _e19 = polyCenter3_(_e18);
    c_6 = _e19;
    loop {
        let _e23 = i;
        if !((_e23 < 3i)) {
            break;
        }
        {
            let _e30 = i;
            let _e32 = pts_3[_e30];
            a_4 = _e32;
            let _e34 = i;
            let _e40 = pts_3[((_e34 + 1i) % 3i)];
            b_4 = _e40;
            let _e42 = b_4;
            let _e43 = a_4;
            dir = (_e42 - _e43);
            let _e46 = dir;
            if (length(_e46) < 0.000000001f) {
                continue;
            }
            let _e50 = dir;
            let _e53 = dir;
            ort = vec2<f32>(-(_e50.y), _e53.x);
            let _e57 = ort;
            let _e58 = c_6;
            let _e59 = a_4;
            dc = dot(_e57, (_e58 - _e59));
            let _e63 = ort;
            let _e64 = u_1;
            let _e65 = a_4;
            du = dot(_e63, (_e64 - _e65));
            let _e69 = dc;
            if (abs(_e69) < 0.000000001f) {
                continue;
            }
            let _e73 = du;
            let _e75 = dc;
            d = (-(_e73) / _e75);
            let _e78 = d;
            let _e79 = max_proj;
            if (_e78 > _e79) {
                {
                    let _e81 = d;
                    max_proj = _e81;
                    let _e82 = i;
                    maxI = _e82;
                }
            }
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    let _e83 = maxI;
    return _e83;
}

fn getInitD3_7_() -> f32 {
    var pi: f32 = 3.1415927f;
    var angle_q: f32;
    var angle_p: f32;
    var tan_q: f32;
    var tan_p: f32;
    var sum_tan: f32;
    var ratio: f32;

    let _e10 = pi;
    let _e13 = pi;
    angle_q = ((_e10 * 0.5f) - (_e13 / 7f));
    let _e18 = pi;
    angle_p = (_e18 / 3f);
    let _e22 = angle_q;
    tan_q = tan(_e22);
    let _e25 = angle_p;
    tan_p = tan(_e25);
    let _e28 = tan_q;
    let _e29 = tan_p;
    sum_tan = (_e28 + _e29);
    let _e32 = sum_tan;
    if (abs(_e32) < 0.000000001f) {
        return 1f;
    }
    let _e37 = tan_q;
    let _e38 = tan_p;
    let _e40 = sum_tan;
    ratio = ((_e37 - _e38) / _e40);
    let _e43 = ratio;
    if (_e43 < 0f) {
        return 0f;
    }
    let _e47 = ratio;
    return sqrt(_e47);
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

fn hexNearestCenter(p_2: vec2<f32>, r_2: f32) -> vec2<f32> {
    var p_3: vec2<f32>;
    var r_3: f32;
    var jc: f32;
    var ic: f32;
    var cube: vec3<f32>;
    var rounded: vec3<f32>;
    var diff: vec3<f32>;

    p_3 = p_2;
    r_3 = r_2;
    let _e12 = p_3;
    let _e14 = r_3;
    jc = (_e12.y / (_e14 * 1.7320508f));
    let _e19 = p_3;
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
        {
            let _e59 = rounded;
            let _e62 = rounded;
            rounded.x = (-(_e59.y) - _e62.z);
        }
    } else {
        let _e65 = diff;
        let _e67 = diff;
        if (_e65.y > _e67.z) {
            {
                let _e71 = rounded;
                let _e74 = rounded;
                rounded.y = (-(_e71.x) - _e74.z);
            }
        } else {
            {
                let _e78 = rounded;
                let _e81 = rounded;
                rounded.z = (-(_e78.x) - _e81.y);
            }
        }
    }
    let _e85 = rounded;
    let _e88 = rounded;
    let _e91 = r_3;
    let _e93 = rounded;
    let _e95 = r_3;
    return vec2<f32>((((2f * _e85.x) + _e88.y) * _e91), ((_e93.y * _e95) * 1.7320508f));
}

fn inStraightPolygon3_(pts_4: array<vec2<f32>, 3>, u_4: vec2<f32>) -> bool {
    var pts_5: array<vec2<f32>, 3>;
    var u_5: vec2<f32>;
    var s: f32 = 0f;
    var sign_set: bool = false;
    var i_1: i32 = 0i;
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;
    var edge_vec: vec2<f32>;
    var delta: vec2<f32>;
    var normal: vec2<f32>;
    var newS: f32;

    pts_5 = pts_4;
    u_5 = u_4;
    loop {
        let _e18 = i_1;
        if !((_e18 < 3i)) {
            break;
        }
        {
            let _e25 = i_1;
            let _e27 = pts_5[_e25];
            a_5 = _e27;
            let _e29 = i_1;
            let _e35 = pts_5[((_e29 + 1i) % 3i)];
            b_5 = _e35;
            let _e37 = b_5;
            let _e38 = a_5;
            edge_vec = (_e37 - _e38);
            let _e41 = edge_vec;
            if (length(_e41) < 0.000000001f) {
                continue;
            }
            let _e45 = edge_vec;
            delta = normalize(_e45);
            let _e48 = delta;
            let _e51 = delta;
            normal = vec2<f32>(-(_e48.y), _e51.x);
            let _e55 = normal;
            let _e56 = u_5;
            let _e57 = a_5;
            newS = dot(_e55, (_e56 - _e57));
            let _e61 = sign_set;
            let _e63 = newS;
            if (!(_e61) && (abs(_e63) > 0.000000001f)) {
                {
                    let _e68 = newS;
                    s = sign(_e68);
                    sign_set = true;
                }
            }
            let _e71 = sign_set;
            let _e72 = newS;
            let _e74 = s;
            if (_e71 && ((sign(_e72) * _e74) < -0.000000001f)) {
                return false;
            }
        }
        continuing {
            let _e22 = i_1;
            i_1 = (_e22 + 1i);
        }
    }
    return true;
}

fn kaleidMap3_(pts_6: array<vec2<f32>, 3>, u_6: vec2<f32>, offang: f32) -> vec2<f32> {
    var pts_7: array<vec2<f32>, 3>;
    var u_7: vec2<f32>;
    var offang_1: f32;
    var c_7: vec2<f32>;
    var delta_1: vec2<f32>;
    var i_2: i32 = 0i;
    var t1_: vec2<f32>;
    var t2_: vec2<f32>;
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
    let _e14 = pts_7;
    let _e15 = polyCenter3_(_e14);
    c_7 = _e15;
    let _e17 = u_7;
    let _e18 = c_7;
    delta_1 = (_e17 - _e18);
    loop {
        let _e23 = i_2;
        if !((_e23 < 3i)) {
            break;
        }
        {
            let _e30 = i_2;
            let _e32 = pts_7[_e30];
            t1_ = _e32;
            let _e34 = i_2;
            let _e40 = pts_7[((_e34 + 1i) % 3i)];
            t2_ = _e40;
            let _e42 = t1_;
            let _e43 = c_7;
            side1_ = (_e42 - _e43);
            let _e46 = t2_;
            let _e47 = c_7;
            side2_ = (_e46 - _e47);
            let _e50 = side1_;
            let _e52 = side2_;
            let _e55 = side1_;
            let _e57 = side2_;
            det_1 = ((_e50.x * _e52.y) - (_e55.y * _e57.x));
            let _e62 = det_1;
            if (abs(_e62) < 0.000000001f) {
                continue;
            }
            let _e66 = delta_1;
            let _e68 = side2_;
            let _e71 = delta_1;
            let _e73 = side2_;
            let _e77 = det_1;
            k = (((_e66.x * _e68.y) - (_e71.y * _e73.x)) / _e77);
            let _e80 = delta_1;
            let _e82 = side1_;
            let _e85 = delta_1;
            let _e87 = side1_;
            let _e91 = det_1;
            l = (((_e80.y * _e82.x) - (_e85.x * _e87.y)) / _e91);
            let _e94 = k;
            let _e98 = l;
            let _e103 = k;
            let _e104 = l;
            if (((_e94 >= -0.000001f) && (_e98 >= -0.000001f)) && ((_e103 + _e104) <= 1.000001f)) {
                {
                    angle = 2.0943952f;
                    let _e117 = l;
                    let _e118 = k;
                    if (_e117 < _e118) {
                        let _e120 = k;
                        let _e121 = l;
                        local = vec2<f32>(_e120, _e121);
                    } else {
                        let _e123 = l;
                        let _e124 = k;
                        local = vec2<f32>(_e123, _e124);
                    }
                    let _e127 = local;
                    w = _e127;
                    let _e129 = w;
                    let _e131 = offang_1;
                    let _e133 = offang_1;
                    let _e137 = w;
                    let _e139 = offang_1;
                    let _e140 = angle;
                    let _e143 = offang_1;
                    let _e144 = angle;
                    return ((_e129.x * vec2<f32>(cos(_e131), sin(_e133))) + (_e137.y * vec2<f32>(cos((_e139 + _e140)), sin((_e143 + _e144)))));
                }
            }
        }
        continuing {
            let _e27 = i_2;
            i_2 = (_e27 + 1i);
        }
    }
    let _e150 = u_7;
    let _e151 = c_7;
    return (_e150 - _e151);
}

fn makeDispCircle(u_8: vec2<f32>) -> vec3<f32> {
    var u_9: vec2<f32>;
    var l_1: f32;
    var d_1: f32;
    var x: f32;
    var r_sq: f32;

    u_9 = u_8;
    let _e10 = u_9;
    l_1 = length(_e10);
    let _e13 = l_1;
    if (_e13 < 0.000000001f) {
        return vec3<f32>(0f, 0f, 1000000000f);
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
    let _e38 = x;
    let _e39 = u_9;
    let _e41 = (_e38 * normalize(_e39));
    let _e42 = r_sq;
    return vec3<f32>(_e41.x, _e41.y, sqrt(_e42));
}

fn makeInitial37_(d_2: f32, offset: f32) -> array<vec2<f32>, 3> {
    var d_3: f32;
    var offset_1: f32;
    var pts_8: array<vec2<f32>, 3>;
    var ang: f32 = 2.0943952f;
    var i_3: i32 = 0i;

    d_3 = d_2;
    offset_1 = offset;
    loop {
        let _e21 = i_3;
        if !((_e21 < 3i)) {
            break;
        }
        {
            let _e28 = i_3;
            let _e30 = d_3;
            let _e31 = ang;
            let _e32 = i_3;
            let _e35 = offset_1;
            let _e38 = ang;
            let _e39 = i_3;
            let _e42 = offset_1;
            pts_8[_e28] = (_e30 * vec2<f32>(cos(((_e31 * f32(_e32)) + _e35)), sin(((_e38 * f32(_e39)) + _e42))));
        }
        continuing {
            let _e25 = i_3;
            i_3 = (_e25 + 1i);
        }
    }
    let _e47 = pts_8;
    return _e47;
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

fn hyperbolicCirclePack(uv: vec2<f32>, outPos: vec2<f32>, viewTransform: mat3x3<f32>, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, size: f32, thickness: f32, variability: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var viewTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var size_1: f32;
    var thickness_1: f32;
    var variability_1: f32;
    var B: vec2<f32>;
    var invTexTransform: mat3x3<f32>;
    var thick: f32;
    var innerR: f32;
    var innerRSq: f32;
    var origR2_: f32;
    var cellLocal: vec2<f32> = vec2(0f);
    var cellTexOff: vec2<f32> = vec2(0f);
    var dispatchStatus: i32 = 0i;
    var l1R: f32;
    var l1Center: vec2<f32>;
    var l1Local: vec2<f32>;
    var l1Sq: f32;
    var l2R: f32;
    var gapDist: f32;
    var i_4: i32 = 0i;
    var ang_1: f32;
    var gapCenter: vec2<f32>;
    var l2Local: vec2<f32>;
    var l2Sq: f32;
    var gapKey: vec2<f32>;
    var initAngle: f32 = 0.7853982f;
    var initD_val: f32;
    var P_canonical: array<vec2<f32>, 3>;
    var edgeCircles: array<vec3<f32>, 3>;
    var i_5: i32 = 0i;
    var a_6: vec2<f32>;
    var b_6: vec2<f32>;
    var dispCircle: vec3<f32>;
    var u_12: vec2<f32>;
    var found: bool = false;
    var i_6: i32 = 0i;
    var edgeIdx: i32;
    var reflectCircle: vec3<f32>;
    var local_1: vec2<f32>;
    var mapped_pos: vec2<f32>;
    var v_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    viewTransform_1 = viewTransform;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    size_1 = size;
    thickness_1 = thickness;
    variability_1 = variability;
    let _e26 = modelTransform_1[2];
    B = _e26.xy;
    let _e29 = texTransform_1;
    invTexTransform = _naga_inverse_3x3_f32(_e29);
    let _e32 = thickness_1;
    thick = clamp(_e32, 0f, 0.99f);
    let _e38 = thick;
    innerR = (1f - _e38);
    let _e41 = innerR;
    let _e42 = innerR;
    innerRSq = (_e41 * _e42);
    let _e45 = uv_1;
    let _e46 = uv_1;
    origR2_ = dot(_e45, _e46);
    let _e57 = origR2_;
    if (_e57 < 1f) {
        {
            let _e60 = origR2_;
            let _e61 = innerRSq;
            if (_e60 > _e61) {
                dispatchStatus = 2i;
            } else {
                {
                    let _e64 = uv_1;
                    let _e65 = innerR;
                    cellLocal = (_e64 / vec2(_e65));
                    dispatchStatus = 1i;
                }
            }
        }
    } else {
        {
            let _e69 = size_1;
            l1R = _e69;
            let _e71 = uv_1;
            let _e72 = l1R;
            let _e73 = hexNearestCenter(_e71, _e72);
            l1Center = _e73;
            let _e75 = uv_1;
            let _e76 = l1Center;
            let _e78 = l1R;
            l1Local = ((_e75 - _e76) / vec2(_e78));
            let _e82 = l1Local;
            let _e83 = l1Local;
            l1Sq = dot(_e82, _e83);
            let _e86 = l1Sq;
            if (_e86 < 1f) {
                {
                    let _e89 = l1Sq;
                    let _e90 = innerRSq;
                    if (_e89 > _e90) {
                        dispatchStatus = 2i;
                    } else {
                        {
                            let _e93 = l1Local;
                            let _e94 = innerR;
                            cellLocal = (_e93 / vec2(_e94));
                            let _e97 = l1Center;
                            let _e98 = hash22_(_e97);
                            let _e105 = variability_1;
                            cellTexOff = ((((_e98 - vec2(0.5f)) * 2f) * RAND_AMP) * _e105);
                            dispatchStatus = 1i;
                        }
                    }
                }
            } else {
                {
                    let _e108 = l1R;
                    l2R = ((_e108 * 0.26794922f) / 1.7320508f);
                    let _e116 = l1R;
                    gapDist = ((_e116 * 2f) / 1.7320508f);
                    loop {
                        let _e124 = i_4;
                        if !((_e124 < 6i)) {
                            break;
                        }
                        {
                            let _e137 = i_4;
                            ang_1 = (0.5235988f + (1.0471976f * f32(_e137)));
                            let _e142 = l1Center;
                            let _e143 = gapDist;
                            let _e144 = ang_1;
                            let _e146 = ang_1;
                            gapCenter = (_e142 + (_e143 * vec2<f32>(cos(_e144), sin(_e146))));
                            let _e152 = uv_1;
                            let _e153 = gapCenter;
                            let _e155 = l2R;
                            l2Local = ((_e152 - _e153) / vec2(_e155));
                            let _e159 = l2Local;
                            let _e160 = l2Local;
                            l2Sq = dot(_e159, _e160);
                            let _e163 = l2Sq;
                            if (_e163 < 1f) {
                                {
                                    let _e166 = l2Sq;
                                    let _e167 = innerRSq;
                                    if (_e166 > _e167) {
                                        {
                                            dispatchStatus = 2i;
                                            break;
                                        }
                                    }
                                    let _e170 = gapCenter;
                                    gapKey = (floor(((_e170 * 1000f) + vec2(0.5f))) * 0.001f);
                                    let _e180 = l2Local;
                                    let _e181 = innerR;
                                    cellLocal = (_e180 / vec2(_e181));
                                    let _e184 = gapKey;
                                    let _e185 = hash22_(_e184);
                                    let _e192 = variability_1;
                                    cellTexOff = ((((_e185 - vec2(0.5f)) * 2f) * RAND_AMP) * _e192);
                                    dispatchStatus = 1i;
                                    break;
                                }
                            }
                        }
                        continuing {
                            let _e128 = i_4;
                            i_4 = (_e128 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e195 = dispatchStatus;
    if (_e195 != 1i) {
        {
            return vec4<f32>(0f, 0f, 0f, 1f);
        }
    }
    let _e207 = getInitD3_7_();
    initD_val = _e207;
    let _e209 = initD_val;
    let _e210 = initAngle;
    let _e211 = makeInitial37_(_e209, _e210);
    P_canonical = _e211;
    loop {
        let _e216 = i_5;
        if !((_e216 < 3i)) {
            break;
        }
        {
            let _e223 = i_5;
            let _e225 = P_canonical[_e223];
            a_6 = _e225;
            let _e227 = i_5;
            let _e233 = P_canonical[((_e227 + 1i) % 3i)];
            b_6 = _e233;
            let _e235 = i_5;
            let _e237 = a_6;
            let _e238 = b_6;
            let _e239 = getCircleForArc(_e237, _e238);
            edgeCircles[_e235] = _e239;
        }
        continuing {
            let _e220 = i_5;
            i_5 = (_e220 + 1i);
        }
    }
    let _e240 = B;
    let _e241 = makeDispCircle(_e240);
    dispCircle = _e241;
    let _e243 = cellLocal;
    u_12 = _e243;
    let _e245 = dispCircle;
    if (_e245.z < 100000000f) {
        let _e249 = cellLocal;
        let _e250 = dispCircle;
        let _e252 = dispCircle;
        let _e254 = invert(_e249, _e250.xy, _e252.z);
        u_12 = _e254;
    }
    loop {
        let _e259 = i_6;
        if !((_e259 < MAX_ITER)) {
            break;
        }
        {
            let _e265 = P_canonical;
            let _e266 = u_12;
            let _e267 = inStraightPolygon3_(_e265, _e266);
            if _e267 {
                {
                    found = true;
                    break;
                }
            }
            let _e269 = P_canonical;
            let _e270 = u_12;
            let _e271 = getClosestEdge3_(_e269, _e270);
            edgeIdx = _e271;
            let _e273 = edgeIdx;
            if (_e273 < 0i) {
                break;
            }
            let _e276 = edgeIdx;
            let _e278 = edgeCircles[_e276];
            reflectCircle = _e278;
            let _e280 = reflectCircle;
            if (_e280.z > 100000000f) {
                break;
            }
            let _e284 = u_12;
            let _e285 = reflectCircle;
            let _e287 = reflectCircle;
            let _e289 = invert(_e284, _e285.xy, _e287.z);
            u_12 = _e289;
        }
        continuing {
            let _e262 = i_6;
            i_6 = (_e262 + 1i);
        }
    }
    let _e290 = found;
    if _e290 {
        let _e291 = P_canonical;
        let _e292 = u_12;
        let _e294 = kaleidMap3_(_e291, _e292, 0f);
        local_1 = _e294;
    } else {
        local_1 = vec2(0f);
    }
    let _e298 = local_1;
    mapped_pos = _e298;
    let _e300 = invTexTransform;
    let _e301 = mapped_pos;
    let _e302 = tf(_e300, _e301);
    let _e303 = cellTexOff;
    v_1 = (_e302 + _e303);
    let _e306 = v_1;
    let _e310 = global.U[0];
    let _e313 = v_1;
    let _e322 = _mirror_wrap(((vec2<f32>((_e306.x / _e310.x), _e313.y) / vec2(2f)) + vec2(0.5f)));
    let _e323 = textureSample(t_source, samp, _e322);
    return _e323;
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
    let _e68 = global.U[1];
    let _e69 = _e68.xyz;
    let _e72 = global.U[2];
    let _e73 = _e72.xyz;
    let _e76 = global.U[3];
    let _e77 = _e76.xyz;
    let _e93 = global.U[5];
    let _e94 = _e93.xyz;
    let _e97 = global.U[6];
    let _e98 = _e97.xyz;
    let _e101 = global.U[7];
    let _e102 = _e101.xyz;
    let _e118 = global.U[8];
    let _e119 = _e118.xyz;
    let _e122 = global.U[9];
    let _e123 = _e122.xyz;
    let _e126 = global.U[10];
    let _e127 = _e126.xyz;
    let _e143 = global.U[11];
    let _e147 = global.U[12];
    let _e151 = global.U[13];
    let _e153 = hyperbolicCirclePack((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat3x3<f32>(vec3<f32>(_e69.x, _e69.y, _e69.z), vec3<f32>(_e73.x, _e73.y, _e73.z), vec3<f32>(_e77.x, _e77.y, _e77.z)), mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)), mat3x3<f32>(vec3<f32>(_e119.x, _e119.y, _e119.z), vec3<f32>(_e123.x, _e123.y, _e123.z), vec3<f32>(_e127.x, _e127.y, _e127.z)), _e143.x, _e147.x, _e151.x);
    fragColor = _e153;
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
