struct Params {
    U: array<vec4<f32>, 17>,
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

const MAX_ITER: i32 = 100i;
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

fn cdiv(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var d: f32;

    a_1 = a;
    b_1 = b;
    let _e12 = b_1;
    let _e13 = b_1;
    d = dot(_e12, _e13);
    let _e16 = a_1;
    let _e18 = b_1;
    let _e21 = a_1;
    let _e23 = b_1;
    let _e27 = a_1;
    let _e29 = b_1;
    let _e32 = a_1;
    let _e34 = b_1;
    let _e39 = d;
    return (vec2<f32>(((_e16.x * _e18.x) + (_e21.y * _e23.y)), ((_e27.y * _e29.x) - (_e32.x * _e34.y))) / vec2(_e39));
}

fn csn(z: vec2<f32>, k2_: f32) -> vec2<f32> {
    var z_1: vec2<f32>;
    var k2_1: f32;
    var snu: f32;
    var cnu: f32;
    var dnu: f32;
    var emc: f32;
    var a_2: f32;
    var b_2: f32;
    var c_2: f32;
    var em: array<f32, 4>;
    var en: array<f32, 4>;
    var i: i32 = 0i;
    var u: f32;
    var i_1: i32 = 3i;
    var snv: f32;
    var cnv: f32;
    var dnv: f32;
    var emc_1: f32;
    var a_3: f32;
    var b_3: f32;
    var c_3: f32;
    var em_1: array<f32, 4>;
    var en_1: array<f32, 4>;
    var i_2: i32 = 0i;
    var u_1: f32;
    var i_3: i32 = 3i;
    var A: f32;

    z_1 = z;
    k2_1 = k2_;
    {
        let _e16 = k2_1;
        emc = (1f - _e16);
        a_2 = 1f;
        dnu = 1f;
        loop {
            let _e28 = i;
            if !((_e28 < 4i)) {
                break;
            }
            {
                let _e35 = i;
                let _e37 = a_2;
                em[_e35] = _e37;
                let _e38 = emc;
                emc = sqrt(_e38);
                let _e40 = i;
                let _e42 = emc;
                en[_e40] = _e42;
                let _e44 = a_2;
                let _e45 = emc;
                c_2 = (0.5f * (_e44 + _e45));
                let _e48 = a_2;
                let _e49 = emc;
                emc = (_e48 * _e49);
                let _e51 = c_2;
                a_2 = _e51;
            }
            continuing {
                let _e32 = i;
                i = (_e32 + 1i);
            }
        }
        let _e52 = c_2;
        let _e53 = z_1;
        u = (_e52 * _e53.x);
        let _e57 = u;
        snu = sin(_e57);
        let _e59 = u;
        cnu = cos(_e59);
        let _e61 = snu;
        if (_e61 != 0f) {
            {
                let _e64 = cnu;
                let _e65 = snu;
                a_2 = (_e64 / _e65);
                let _e67 = a_2;
                let _e68 = c_2;
                c_2 = (_e67 * _e68);
                loop {
                    let _e72 = i_1;
                    if !((_e72 >= 0i)) {
                        break;
                    }
                    {
                        let _e79 = i_1;
                        let _e81 = em[_e79];
                        b_2 = _e81;
                        let _e82 = c_2;
                        let _e83 = a_2;
                        a_2 = (_e82 * _e83);
                        let _e85 = dnu;
                        let _e86 = c_2;
                        c_2 = (_e85 * _e86);
                        let _e88 = i_1;
                        let _e90 = en[_e88];
                        let _e91 = a_2;
                        let _e93 = b_2;
                        let _e94 = a_2;
                        dnu = ((_e90 + _e91) / (_e93 + _e94));
                        let _e97 = c_2;
                        let _e98 = b_2;
                        a_2 = (_e97 / _e98);
                    }
                    continuing {
                        let _e76 = i_1;
                        i_1 = (_e76 - 1i);
                    }
                }
                let _e101 = c_2;
                let _e102 = c_2;
                a_2 = (1f / sqrt(((_e101 * _e102) + 1f)));
                let _e108 = snu;
                if (_e108 < 0f) {
                    let _e111 = a_2;
                    snu = -(_e111);
                } else {
                    let _e113 = a_2;
                    snu = _e113;
                }
                let _e114 = c_2;
                let _e115 = snu;
                cnu = (_e114 * _e115);
            }
        }
    }
    {
        let _e120 = k2_1;
        emc_1 = _e120;
        a_3 = 1f;
        dnv = 1f;
        loop {
            let _e131 = i_2;
            if !((_e131 < 4i)) {
                break;
            }
            {
                let _e138 = i_2;
                let _e140 = a_3;
                em_1[_e138] = _e140;
                let _e141 = emc_1;
                emc_1 = sqrt(_e141);
                let _e143 = i_2;
                let _e145 = emc_1;
                en_1[_e143] = _e145;
                let _e147 = a_3;
                let _e148 = emc_1;
                c_3 = (0.5f * (_e147 + _e148));
                let _e151 = a_3;
                let _e152 = emc_1;
                emc_1 = (_e151 * _e152);
                let _e154 = c_3;
                a_3 = _e154;
            }
            continuing {
                let _e135 = i_2;
                i_2 = (_e135 + 1i);
            }
        }
        let _e155 = c_3;
        let _e156 = z_1;
        u_1 = (_e155 * _e156.y);
        let _e160 = u_1;
        snv = sin(_e160);
        let _e162 = u_1;
        cnv = cos(_e162);
        let _e164 = snv;
        if (_e164 != 0f) {
            {
                let _e167 = cnv;
                let _e168 = snv;
                a_3 = (_e167 / _e168);
                let _e170 = a_3;
                let _e171 = c_3;
                c_3 = (_e170 * _e171);
                loop {
                    let _e175 = i_3;
                    if !((_e175 >= 0i)) {
                        break;
                    }
                    {
                        let _e182 = i_3;
                        let _e184 = em_1[_e182];
                        b_3 = _e184;
                        let _e185 = c_3;
                        let _e186 = a_3;
                        a_3 = (_e185 * _e186);
                        let _e188 = dnv;
                        let _e189 = c_3;
                        c_3 = (_e188 * _e189);
                        let _e191 = i_3;
                        let _e193 = en_1[_e191];
                        let _e194 = a_3;
                        let _e196 = b_3;
                        let _e197 = a_3;
                        dnv = ((_e193 + _e194) / (_e196 + _e197));
                        let _e200 = c_3;
                        let _e201 = b_3;
                        a_3 = (_e200 / _e201);
                    }
                    continuing {
                        let _e179 = i_3;
                        i_3 = (_e179 - 1i);
                    }
                }
                let _e204 = c_3;
                let _e205 = c_3;
                a_3 = (1f / sqrt(((_e204 * _e205) + 1f)));
                let _e211 = snv;
                if (_e211 < 0f) {
                    let _e214 = a_3;
                    snv = -(_e214);
                } else {
                    let _e216 = a_3;
                    snv = _e216;
                }
                let _e217 = c_3;
                let _e218 = snv;
                cnv = (_e217 * _e218);
            }
        }
    }
    let _e222 = dnu;
    let _e223 = dnu;
    let _e225 = snv;
    let _e227 = snv;
    A = (1f / (1f - (((_e222 * _e223) * _e225) * _e227)));
    let _e232 = A;
    let _e233 = snu;
    let _e234 = dnv;
    let _e236 = cnu;
    let _e237 = dnu;
    let _e239 = snv;
    let _e241 = cnv;
    return (_e232 * vec2<f32>((_e233 * _e234), (((_e236 * _e237) * _e239) * _e241)));
}

fn ellipticK_m(m: f32) -> f32 {
    var m_1: f32;
    var a_4: f32 = 1f;
    var b_4: f32;
    var i_4: i32 = 0i;
    var aNew: f32;

    m_1 = m;
    let _e13 = m_1;
    b_4 = sqrt((1f - _e13));
    loop {
        let _e19 = i_4;
        if !((_e19 < 8i)) {
            break;
        }
        {
            let _e26 = a_4;
            let _e27 = b_4;
            aNew = ((_e26 + _e27) * 0.5f);
            let _e32 = a_4;
            let _e33 = b_4;
            b_4 = sqrt((_e32 * _e33));
            let _e36 = aNew;
            a_4 = _e36;
        }
        continuing {
            let _e23 = i_4;
            i_4 = (_e23 + 1i);
        }
    }
    let _e39 = a_4;
    return (3.1415927f / (2f * _e39));
}

fn getCircle(a_5: vec2<f32>, b_5: vec2<f32>, c_4: vec2<f32>) -> vec3<f32> {
    var a_6: vec2<f32>;
    var b_6: vec2<f32>;
    var c_5: vec2<f32>;
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

    a_6 = a_5;
    b_6 = b_5;
    c_5 = c_4;
    let _e14 = a_6;
    let _e16 = b_6;
    let _e19 = a_6;
    let _e21 = c_5;
    let _e25 = a_6;
    let _e27 = c_5;
    let _e30 = a_6;
    let _e32 = b_6;
    det = (((_e14.x - _e16.x) * (_e19.y - _e21.y)) - ((_e25.x - _e27.x) * (_e30.y - _e32.y)));
    let _e38 = det;
    if (abs(_e38) < 0.000000001f) {
        return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
    }
    let _e46 = a_6;
    let _e48 = b_6;
    x12_ = (_e46.x - _e48.x);
    let _e52 = a_6;
    let _e54 = c_5;
    x13_ = (_e52.x - _e54.x);
    let _e58 = c_5;
    let _e60 = a_6;
    x31_ = (_e58.x - _e60.x);
    let _e64 = b_6;
    let _e66 = a_6;
    x21_ = (_e64.x - _e66.x);
    let _e70 = a_6;
    let _e72 = b_6;
    y12_ = (_e70.y - _e72.y);
    let _e76 = a_6;
    let _e78 = c_5;
    y13_ = (_e76.y - _e78.y);
    let _e82 = c_5;
    let _e84 = a_6;
    y31_ = (_e82.y - _e84.y);
    let _e88 = b_6;
    let _e90 = a_6;
    y21_ = (_e88.y - _e90.y);
    let _e94 = a_6;
    let _e96 = a_6;
    let _e99 = c_5;
    let _e101 = c_5;
    sx13_ = ((_e94.x * _e96.x) - (_e99.x * _e101.x));
    let _e106 = a_6;
    let _e108 = a_6;
    let _e111 = c_5;
    let _e113 = c_5;
    sy13_ = ((_e106.y * _e108.y) - (_e111.y * _e113.y));
    let _e118 = b_6;
    let _e120 = b_6;
    let _e123 = a_6;
    let _e125 = a_6;
    sx21_ = ((_e118.x * _e120.x) - (_e123.x * _e125.x));
    let _e130 = b_6;
    let _e132 = b_6;
    let _e135 = a_6;
    let _e137 = a_6;
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
    let _e218 = a_6;
    let _e219 = center;
    return vec3<f32>(_e217.x, _e217.y, length((_e218 - _e219)));
}

fn invert(p: vec2<f32>, c_6: vec2<f32>, r: f32) -> vec2<f32> {
    var p_1: vec2<f32>;
    var c_7: vec2<f32>;
    var r_1: f32;
    var v: vec2<f32>;
    var l2_: f32;

    p_1 = p;
    c_7 = c_6;
    r_1 = r;
    let _e14 = p_1;
    let _e15 = c_7;
    v = (_e14 - _e15);
    let _e18 = v;
    let _e19 = v;
    l2_ = dot(_e18, _e19);
    let _e22 = l2_;
    if (_e22 < 0.000000000001f) {
        let _e25 = c_7;
        let _e26 = v;
        return (_e25 + (normalize(_e26) * 1000000000000000000f));
    }
    let _e31 = c_7;
    let _e32 = v;
    let _e33 = r_1;
    let _e34 = r_1;
    let _e36 = l2_;
    return (_e31 + (_e32 * ((_e33 * _e34) / _e36)));
}

fn getCircleForArc(a_7: vec2<f32>, b_7: vec2<f32>) -> vec3<f32> {
    var a_8: vec2<f32>;
    var b_8: vec2<f32>;
    var a_inv: vec2<f32>;

    a_8 = a_7;
    b_8 = b_7;
    let _e12 = a_8;
    if (length(_e12) < 0.000000001f) {
        return vec3<f32>(1000000000f, 1000000000f, 1000000000f);
    }
    let _e20 = a_8;
    let _e24 = invert(_e20, vec2(0f), 1f);
    a_inv = _e24;
    let _e26 = a_8;
    let _e27 = b_8;
    let _e28 = a_inv;
    let _e29 = getCircle(_e26, _e27, _e28);
    return _e29;
}

fn polyCenter(pts: array<vec2<f32>, 12>, p_2: i32) -> vec2<f32> {
    var pts_1: array<vec2<f32>, 12>;
    var p_3: i32;
    var total: vec2<f32> = vec2(0f);
    var i_5: i32 = 0i;

    pts_1 = pts;
    p_3 = p_2;
    loop {
        let _e17 = i_5;
        let _e18 = p_3;
        if !((_e17 < _e18)) {
            break;
        }
        let _e24 = total;
        let _e25 = i_5;
        let _e27 = pts_1[_e25];
        total = (_e24 + _e27);
        continuing {
            let _e21 = i_5;
            i_5 = (_e21 + 1i);
        }
    }
    let _e29 = total;
    let _e30 = p_3;
    return (_e29 / vec2(f32(_e30)));
}

fn getClosestEdge(pts_2: array<vec2<f32>, 12>, u_2: vec2<f32>, p_4: i32) -> i32 {
    var pts_3: array<vec2<f32>, 12>;
    var u_3: vec2<f32>;
    var p_5: i32;
    var max_proj: f32 = -1000000000f;
    var maxI: i32 = -1i;
    var c_8: vec2<f32>;
    var i_6: i32 = 0i;
    var a_9: vec2<f32>;
    var nxt: i32;
    var b_9: vec2<f32>;
    var dir: vec2<f32>;
    var ort: vec2<f32>;
    var dc: f32;
    var du: f32;
    var d_1: f32;

    pts_3 = pts_2;
    u_3 = u_2;
    p_5 = p_4;
    let _e20 = pts_3;
    let _e21 = p_5;
    let _e22 = polyCenter(_e20, _e21);
    c_8 = _e22;
    loop {
        let _e26 = i_6;
        let _e27 = p_5;
        if !((_e26 < _e27)) {
            break;
        }
        {
            let _e33 = i_6;
            let _e35 = pts_3[_e33];
            a_9 = _e35;
            let _e37 = i_6;
            nxt = (_e37 + 1i);
            let _e41 = nxt;
            let _e42 = p_5;
            if (_e41 >= _e42) {
                nxt = 0i;
            }
            let _e45 = nxt;
            let _e47 = pts_3[_e45];
            b_9 = _e47;
            let _e49 = b_9;
            let _e50 = a_9;
            dir = (_e49 - _e50);
            let _e53 = dir;
            if (length(_e53) < 0.000000001f) {
                continue;
            }
            let _e57 = dir;
            let _e60 = dir;
            ort = vec2<f32>(-(_e57.y), _e60.x);
            let _e64 = ort;
            let _e65 = c_8;
            let _e66 = a_9;
            dc = dot(_e64, (_e65 - _e66));
            let _e70 = ort;
            let _e71 = u_3;
            let _e72 = a_9;
            du = dot(_e70, (_e71 - _e72));
            let _e76 = dc;
            if (abs(_e76) < 0.000000001f) {
                continue;
            }
            let _e80 = du;
            let _e82 = dc;
            d_1 = (-(_e80) / _e82);
            let _e85 = d_1;
            let _e86 = max_proj;
            if (_e85 > _e86) {
                {
                    let _e88 = d_1;
                    max_proj = _e88;
                    let _e89 = i_6;
                    maxI = _e89;
                }
            }
        }
        continuing {
            let _e30 = i_6;
            i_6 = (_e30 + 1i);
        }
    }
    let _e90 = maxI;
    return _e90;
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
    var a_10: vec2<f32>;
    var b_10: vec2<f32>;

    p_9 = p_8;
    let _e12 = p_9;
    a_10 = fract((-45.3277f * _e12.xy));
    let _e17 = a_10;
    let _e18 = a_10;
    let _e19 = a_10;
    b_10 = (_e17 + vec2(dot(_e18, (_e19 + vec2(123.3371f)))));
    let _e27 = b_10;
    let _e29 = b_10;
    return fract((_e27.x * _e29.y));
}

fn inStraightPolygon(pts_4: array<vec2<f32>, 12>, u_4: vec2<f32>, p_10: i32) -> bool {
    var pts_5: array<vec2<f32>, 12>;
    var u_5: vec2<f32>;
    var p_11: i32;
    var s: f32 = 0f;
    var sign_set: bool = false;
    var i_7: i32 = 0i;
    var a_11: vec2<f32>;
    var nxt_1: i32;
    var b_11: vec2<f32>;
    var edge_vec: vec2<f32>;
    var delta: vec2<f32>;
    var normal: vec2<f32>;
    var newS: f32;

    pts_5 = pts_4;
    u_5 = u_4;
    p_11 = p_10;
    loop {
        let _e20 = i_7;
        let _e21 = p_11;
        if !((_e20 < _e21)) {
            break;
        }
        {
            let _e27 = i_7;
            let _e29 = pts_5[_e27];
            a_11 = _e29;
            let _e31 = i_7;
            nxt_1 = (_e31 + 1i);
            let _e35 = nxt_1;
            let _e36 = p_11;
            if (_e35 >= _e36) {
                nxt_1 = 0i;
            }
            let _e39 = nxt_1;
            let _e41 = pts_5[_e39];
            b_11 = _e41;
            let _e43 = b_11;
            let _e44 = a_11;
            edge_vec = (_e43 - _e44);
            let _e47 = edge_vec;
            if (length(_e47) < 0.000000001f) {
                continue;
            }
            let _e51 = edge_vec;
            delta = normalize(_e51);
            let _e54 = delta;
            let _e57 = delta;
            normal = vec2<f32>(-(_e54.y), _e57.x);
            let _e61 = normal;
            let _e62 = u_5;
            let _e63 = a_11;
            newS = dot(_e61, (_e62 - _e63));
            let _e67 = sign_set;
            let _e69 = newS;
            if (!(_e67) && (abs(_e69) > 0.000000001f)) {
                {
                    let _e74 = newS;
                    s = sign(_e74);
                    sign_set = true;
                }
            }
            let _e77 = sign_set;
            let _e78 = newS;
            let _e80 = s;
            if (_e77 && ((sign(_e78) * _e80) < -0.000000001f)) {
                return false;
            }
        }
        continuing {
            let _e24 = i_7;
            i_7 = (_e24 + 1i);
        }
    }
    return true;
}

fn kaleidMap(pts_6: array<vec2<f32>, 12>, u_6: vec2<f32>, offang: f32, p_12: i32) -> vec2<f32> {
    var pts_7: array<vec2<f32>, 12>;
    var u_7: vec2<f32>;
    var offang_1: f32;
    var p_13: i32;
    var c_9: vec2<f32>;
    var delta_1: vec2<f32>;
    var i_8: i32 = 0i;
    var t1_: vec2<f32>;
    var nxt_2: i32;
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
    p_13 = p_12;
    let _e16 = pts_7;
    let _e17 = p_13;
    let _e18 = polyCenter(_e16, _e17);
    c_9 = _e18;
    let _e20 = u_7;
    let _e21 = c_9;
    delta_1 = (_e20 - _e21);
    loop {
        let _e26 = i_8;
        let _e27 = p_13;
        if !((_e26 < _e27)) {
            break;
        }
        {
            let _e33 = i_8;
            let _e35 = pts_7[_e33];
            t1_ = _e35;
            let _e37 = i_8;
            nxt_2 = (_e37 + 1i);
            let _e41 = nxt_2;
            let _e42 = p_13;
            if (_e41 >= _e42) {
                nxt_2 = 0i;
            }
            let _e45 = nxt_2;
            let _e47 = pts_7[_e45];
            t2_ = _e47;
            let _e49 = t1_;
            let _e50 = c_9;
            side1_ = (_e49 - _e50);
            let _e53 = t2_;
            let _e54 = c_9;
            side2_ = (_e53 - _e54);
            let _e57 = side1_;
            let _e59 = side2_;
            let _e62 = side1_;
            let _e64 = side2_;
            det_1 = ((_e57.x * _e59.y) - (_e62.y * _e64.x));
            let _e69 = det_1;
            if (abs(_e69) < 0.000000001f) {
                continue;
            }
            let _e73 = delta_1;
            let _e75 = side2_;
            let _e78 = delta_1;
            let _e80 = side2_;
            let _e84 = det_1;
            k = (((_e73.x * _e75.y) - (_e78.y * _e80.x)) / _e84);
            let _e87 = delta_1;
            let _e89 = side1_;
            let _e92 = delta_1;
            let _e94 = side1_;
            let _e98 = det_1;
            l = (((_e87.y * _e89.x) - (_e92.x * _e94.y)) / _e98);
            let _e101 = k;
            let _e105 = l;
            let _e110 = k;
            let _e111 = l;
            if (((_e101 >= -0.000001f) && (_e105 >= -0.000001f)) && ((_e110 + _e111) <= 1.000001f)) {
                {
                    let _e121 = p_13;
                    angle = (6.2831855f / f32(_e121));
                    let _e125 = l;
                    let _e126 = k;
                    if (_e125 < _e126) {
                        let _e128 = k;
                        let _e129 = l;
                        local = vec2<f32>(_e128, _e129);
                    } else {
                        let _e131 = l;
                        let _e132 = k;
                        local = vec2<f32>(_e131, _e132);
                    }
                    let _e135 = local;
                    w = _e135;
                    let _e137 = w;
                    let _e139 = offang_1;
                    let _e141 = offang_1;
                    let _e145 = w;
                    let _e147 = offang_1;
                    let _e148 = angle;
                    let _e151 = offang_1;
                    let _e152 = angle;
                    return ((_e137.x * vec2<f32>(cos(_e139), sin(_e141))) + (_e145.y * vec2<f32>(cos((_e147 + _e148)), sin((_e151 + _e152)))));
                }
            }
        }
        continuing {
            let _e30 = i_8;
            i_8 = (_e30 + 1i);
        }
    }
    let _e158 = u_7;
    let _e159 = c_9;
    return (_e158 - _e159);
}

fn ksqFromAspect(aspect: f32) -> f32 {
    var aspect_1: f32;
    var target_: f32;
    var m_2: f32 = 0.5f;
    var i_9: i32 = 0i;
    var km: f32;
    var kpm: f32;
    var ratio_1: f32;
    var err: f32;
    var eps: f32;
    var mPlus: f32;
    var ratioPlus: f32;
    var deriv: f32;

    aspect_1 = aspect;
    let _e10 = aspect_1;
    target_ = (_e10 * 0.5f);
    loop {
        let _e18 = i_9;
        if !((_e18 < 20i)) {
            break;
        }
        {
            let _e25 = m_2;
            let _e26 = ellipticK_m(_e25);
            km = _e26;
            let _e29 = m_2;
            let _e31 = ellipticK_m((1f - _e29));
            kpm = _e31;
            let _e33 = km;
            let _e34 = kpm;
            ratio_1 = (_e33 / _e34);
            let _e37 = ratio_1;
            let _e38 = target_;
            err = (_e37 - _e38);
            let _e41 = err;
            if (abs(_e41) < 0.00001f) {
                break;
            }
            eps = 0.0001f;
            let _e47 = m_2;
            let _e48 = eps;
            mPlus = clamp((_e47 + _e48), 0.0001f, 0.9999f);
            let _e56 = mPlus;
            let _e57 = ellipticK_m(_e56);
            let _e59 = mPlus;
            let _e61 = ellipticK_m((1f - _e59));
            ratioPlus = (_e57 / _e61);
            let _e64 = ratioPlus;
            let _e65 = ratio_1;
            let _e67 = mPlus;
            let _e68 = m_2;
            deriv = ((_e64 - _e65) / (_e67 - _e68));
            let _e72 = deriv;
            if (abs(_e72) < 0.000000001f) {
                break;
            }
            let _e76 = m_2;
            let _e77 = err;
            let _e78 = deriv;
            m_2 = clamp((_e76 - (_e77 / _e78)), 0.0001f, 0.9999f);
        }
        continuing {
            let _e22 = i_9;
            i_9 = (_e22 + 1i);
        }
    }
    let _e86 = m_2;
    return _e86;
}

fn makeDispCircle(u_8: vec2<f32>) -> vec3<f32> {
    var u_9: vec2<f32>;
    var l_1: f32;
    var d_2: f32;
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
    d_2 = (1f / _e21);
    let _e25 = d_2;
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

fn makeInitial(d_3: f32, offset: f32, p_14: i32) -> array<vec2<f32>, 12> {
    var d_4: f32;
    var offset_1: f32;
    var p_15: i32;
    var pts_8: array<vec2<f32>, 12>;
    var ang: f32;
    var i_10: i32 = 0i;

    d_4 = d_3;
    offset_1 = offset;
    p_15 = p_14;
    let _e18 = p_15;
    ang = (6.2831855f / f32(_e18));
    loop {
        let _e24 = i_10;
        let _e25 = p_15;
        if !((_e24 < _e25)) {
            break;
        }
        {
            let _e31 = i_10;
            let _e33 = d_4;
            let _e34 = ang;
            let _e35 = i_10;
            let _e38 = offset_1;
            let _e41 = ang;
            let _e42 = i_10;
            let _e45 = offset_1;
            pts_8[_e31] = (_e33 * vec2<f32>(cos(((_e34 * f32(_e35)) + _e38)), sin(((_e41 * f32(_e42)) + _e45))));
        }
        continuing {
            let _e28 = i_10;
            i_10 = (_e28 + 1i);
        }
    }
    let _e50 = pts_8;
    return _e50;
}

fn sdRoundedBox(p_16: vec2<f32>, b_12: vec2<f32>, r_2: f32) -> f32 {
    var p_17: vec2<f32>;
    var b_13: vec2<f32>;
    var r_3: f32;
    var q_2: vec2<f32>;

    p_17 = p_16;
    b_13 = b_12;
    r_3 = r_2;
    let _e14 = p_17;
    let _e16 = b_13;
    let _e18 = r_3;
    q_2 = ((abs(_e14) - _e16) + vec2(_e18));
    let _e22 = q_2;
    let _e24 = q_2;
    let _e29 = q_2;
    let _e35 = r_3;
    return ((min(max(_e22.x, _e24.y), 0f) + length(max(_e29, vec2(0f)))) - _e35);
}

fn tf(m_3: mat3x3<f32>, u_10: vec2<f32>) -> vec2<f32> {
    var m_4: mat3x3<f32>;
    var u_11: vec2<f32>;

    m_4 = m_3;
    u_11 = u_10;
    let _e12 = m_4;
    let _e13 = u_11;
    return (_e12 * vec3<f32>(_e13.x, _e13.y, 1f)).xy;
}

fn triFold(t: f32) -> f32 {
    var t_1: f32;
    var a_12: f32;

    t_1 = t;
    let _e10 = t_1;
    let _e12 = (_e10 + 1f);
    a_12 = (_e12 - (floor((_e12 / 4f)) * 4f));
    let _e19 = a_12;
    if (_e19 > 2f) {
        let _e23 = a_12;
        a_12 = (4f - _e23);
    }
    let _e25 = a_12;
    return (_e25 - 1f);
}

fn hyperbolicSquare(uv: vec2<f32>, outPos: vec2<f32>, p_18: i32, q_3: i32, viewTransform: mat3x3<f32>, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, aspectRatio: f32, offset_2: f32, boundary: i32, vignetting: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var p_19: i32;
    var q_4: i32;
    var viewTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var aspectRatio_1: f32;
    var offset_3: f32;
    var boundary_1: i32;
    var vignetting_1: f32;
    var rectUV: vec2<f32>;
    var normUV: vec2<f32>;
    var suv: vec2<f32>;
    var n: vec2<f32>;
    var texVar: mat3x3<f32> = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 0f, 1f));
    var vigAmt: f32 = 0f;
    var local_1: f32;
    var outsideSq: f32;
    var m_5: f32;
    var k_1: f32;
    var lvl: f32;
    var t_2: vec2<f32>;
    var cell: vec2<f32>;
    var local_2: vec2<f32>;
    var loc: vec2<f32>;
    var a_13: f32;
    var ca: f32;
    var sa: f32;
    var t_3: vec2<f32>;
    var ksq: f32;
    var kp: f32;
    var w_1: vec2<f32>;
    var z_uhp: vec2<f32>;
    var ci: vec2<f32> = vec2<f32>(0f, 1f);
    var discZ: vec2<f32>;
    var inB: vec2<f32>;
    var lInB: f32;
    var local_3: vec2<f32>;
    var P: vec2<f32>;
    var fund: array<vec2<f32>, 12>;
    var i_11: i32 = 0i;
    var edge: i32;
    var a_14: vec2<f32>;
    var nxt_3: i32;
    var b_14: vec2<f32>;
    var c_10: vec3<f32>;
    var lP: f32;
    var local_4: vec2<f32>;
    var reducedB: vec2<f32>;
    var P_canonical: array<vec2<f32>, 12>;
    var edgeCircles: array<vec3<f32>, 12>;
    var i_12: i32 = 0i;
    var a_15: vec2<f32>;
    var nxt_4: i32;
    var b_15: vec2<f32>;
    var dispC: vec3<f32>;
    var i_13: i32 = 0i;
    var i_14: i32 = 0i;
    var a_16: vec2<f32>;
    var nxt_5: i32;
    var b_16: vec2<f32>;
    var u_12: vec2<f32>;
    var found: bool = false;
    var iterCount: i32 = 100i;
    var i_15: i32 = 0i;
    var edgeIdx: i32;
    var reflectCircle: vec3<f32>;
    var col: vec4<f32>;
    var invTexTransform: mat3x3<f32>;
    var mapped_pos: vec2<f32>;
    var v_1: vec2<f32>;
    var v_2: vec2<f32>;
    var capFade: f32;
    var t_4: f32;
    var s1_: f32;
    var s2_: f32;
    var cornerRadius: f32;
    var distSquare: f32;
    var darknessCorner: f32;
    var a2_: vec2<f32>;
    var a4_: vec2<f32>;
    var sd: f32;
    var innerSd: f32;
    var outerSd: f32;
    var darknessBody: f32;
    var cornerMask: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    p_19 = p_18;
    q_4 = q_3;
    viewTransform_1 = viewTransform;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    aspectRatio_1 = aspectRatio;
    offset_3 = offset_2;
    boundary_1 = boundary;
    vignetting_1 = vignetting;
    let _e30 = uv_1;
    rectUV = _e30;
    let _e32 = uv_1;
    let _e34 = aspectRatio_1;
    let _e38 = uv_1;
    normUV = vec2<f32>((_e32.x / max(_e34, 0.001f)), _e38.y);
    let _e42 = uv_1;
    suv = _e42;
    let _e44 = normUV;
    n = _e44;
    let _e55 = normUV;
    let _e58 = normUV;
    if (max(abs(_e55.x), abs(_e58.y)) > 1f) {
        local_1 = 1f;
    } else {
        local_1 = 0f;
    }
    let _e67 = local_1;
    outsideSq = _e67;
    let _e69 = boundary_1;
    if (_e69 == 0i) {
        {
            let _e72 = outsideSq;
            if (_e72 > 0.5f) {
                return vec4(0f);
            }
        }
    } else {
        let _e77 = boundary_1;
        if (_e77 == 1i) {
            {
                let _e80 = outsideSq;
                if (_e80 > 0.5f) {
                    return vec4<f32>(0f, 0f, 0f, 1f);
                }
            }
        } else {
            let _e88 = boundary_1;
            if (_e88 == 2i) {
                {
                    vigAmt = 1f;
                }
            } else {
                let _e92 = boundary_1;
                if (_e92 == 3i) {
                    {
                        let _e95 = n;
                        let _e98 = n;
                        m_5 = max(abs(_e95.x), abs(_e98.y));
                        let _e103 = m_5;
                        if (_e103 > 1f) {
                            {
                                let _e106 = m_5;
                                k_1 = floor(log2(_e106));
                                let _e110 = n;
                                let _e111 = k_1;
                                n = (_e110 / vec2(exp2((_e111 + 1f))));
                                let _e117 = k_1;
                                lvl = (_e117 + 1f);
                                let _e122 = lvl;
                                let _e126 = lvl;
                                t_2 = (vec2<f32>(sin((0.49f * _e122)), sin(((0.77f * _e126) + 1.5707963f))) * 0.3f);
                                let _e141 = t_2;
                                let _e143 = t_2;
                                texVar = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e141.x, _e143.y, 1f));
                            }
                        }
                        let _e150 = n;
                        let _e152 = aspectRatio_1;
                        let _e156 = n;
                        suv = vec2<f32>((_e150.x * max(_e152, 0.001f)), _e156.y);
                    }
                } else {
                    let _e159 = boundary_1;
                    let _e162 = boundary_1;
                    if ((_e159 == 4i) || (_e162 == 5i)) {
                        {
                            let _e166 = n;
                            cell = floor(((_e166 + vec2(1f)) * 0.5f));
                            let _e174 = boundary_1;
                            if (_e174 == 4i) {
                                let _e177 = n;
                                let _e180 = (_e177 + vec2(1f));
                                let _e182 = vec2(2f);
                                local_2 = ((_e180 - (floor((_e180 / _e182)) * _e182)) - vec2(1f));
                            } else {
                                let _e190 = n;
                                let _e192 = triFold(_e190.x);
                                let _e193 = n;
                                let _e195 = triFold(_e193.y);
                                local_2 = vec2<f32>(_e192, _e195);
                            }
                            let _e198 = local_2;
                            loc = _e198;
                            let _e200 = loc;
                            n = _e200;
                            let _e201 = boundary_1;
                            if (_e201 == 5i) {
                                {
                                    let _e204 = cell;
                                    let _e205 = hash21_(_e204);
                                    a_13 = (_e205 * 6.2831855f);
                                    let _e209 = a_13;
                                    ca = cos(_e209);
                                    let _e212 = a_13;
                                    sa = sin(_e212);
                                    let _e215 = cell;
                                    let _e219 = hash21_((_e215 + vec2(11.3f)));
                                    let _e220 = cell;
                                    let _e224 = hash21_((_e220 + vec2(27.9f)));
                                    t_3 = (vec2<f32>(_e219, _e224) - vec2(0.5f));
                                    let _e230 = ca;
                                    let _e231 = sa;
                                    let _e233 = sa;
                                    let _e235 = ca;
                                    let _e237 = t_3;
                                    let _e239 = t_3;
                                    texVar = mat3x3<f32>(vec3<f32>(_e230, _e231, 0f), vec3<f32>(-(_e233), _e235, 0f), vec3<f32>(_e237.x, _e239.y, 1f));
                                }
                            }
                            let _e246 = n;
                            let _e248 = aspectRatio_1;
                            let _e252 = n;
                            suv = vec2<f32>((_e246.x * max(_e248, 0.001f)), _e252.y);
                        }
                    }
                }
            }
        }
    }
    let _e255 = aspectRatio_1;
    let _e256 = ksqFromAspect(_e255);
    ksq = _e256;
    let _e259 = ksq;
    let _e261 = ellipticK_m((1f - _e259));
    kp = _e261;
    let _e263 = suv;
    let _e265 = suv;
    let _e270 = kp;
    w_1 = (vec2<f32>(_e263.x, (_e265.y + 1f)) * (_e270 * 0.5f));
    let _e275 = w_1;
    let _e276 = ksq;
    let _e277 = csn(_e275, _e276);
    z_uhp = _e277;
    let _e283 = ci;
    let _e284 = z_uhp;
    let _e286 = ci;
    let _e287 = z_uhp;
    let _e289 = cdiv((_e283 - _e284), (_e286 + _e287));
    discZ = _e289;
    let _e293 = modelTransform_1[2];
    inB = _e293.xy;
    let _e296 = inB;
    lInB = length(_e296);
    let _e299 = lInB;
    if (_e299 < 0.000000001f) {
        local_3 = vec2(0f);
    } else {
        let _e304 = inB;
        let _e305 = lInB;
        local_3 = (_e304 / vec2((_e305 + 1f)));
    }
    let _e311 = local_3;
    P = _e311;
    {
        let _e313 = p_19;
        let _e315 = q_4;
        let _e317 = getInitD(f32(_e313), f32(_e315));
        let _e321 = p_19;
        let _e322 = makeInitial(_e317, 0.7853982f, _e321);
        fund = _e322;
        loop {
            let _e326 = i_11;
            if !((_e326 < 100i)) {
                break;
            }
            {
                let _e333 = fund;
                let _e334 = P;
                let _e335 = p_19;
                let _e336 = inStraightPolygon(_e333, _e334, _e335);
                if _e336 {
                    break;
                }
                let _e337 = fund;
                let _e338 = P;
                let _e339 = p_19;
                let _e340 = getClosestEdge(_e337, _e338, _e339);
                edge = _e340;
                let _e342 = edge;
                if (_e342 < 0i) {
                    break;
                }
                let _e345 = edge;
                let _e347 = fund[_e345];
                a_14 = _e347;
                let _e349 = edge;
                nxt_3 = (_e349 + 1i);
                let _e353 = nxt_3;
                let _e354 = p_19;
                if (_e353 >= _e354) {
                    nxt_3 = 0i;
                }
                let _e357 = nxt_3;
                let _e359 = fund[_e357];
                b_14 = _e359;
                let _e361 = a_14;
                let _e362 = b_14;
                let _e363 = getCircleForArc(_e361, _e362);
                c_10 = _e363;
                let _e365 = P;
                let _e366 = c_10;
                let _e368 = c_10;
                let _e370 = invert(_e365, _e366.xy, _e368.z);
                P = _e370;
            }
            continuing {
                let _e330 = i_11;
                i_11 = (_e330 + 1i);
            }
        }
    }
    let _e371 = P;
    lP = length(_e371);
    let _e374 = lP;
    if (_e374 < 0.000000001f) {
        local_4 = vec2(0f);
    } else {
        let _e379 = P;
        let _e381 = lP;
        local_4 = (_e379 / vec2(max((1f - _e381), 0.000001f)));
    }
    let _e388 = local_4;
    reducedB = _e388;
    let _e390 = p_19;
    let _e392 = q_4;
    let _e394 = getInitD(f32(_e390), f32(_e392));
    let _e398 = p_19;
    let _e399 = makeInitial(_e394, 0.7853982f, _e398);
    P_canonical = _e399;
    loop {
        let _e404 = i_12;
        let _e405 = p_19;
        if !((_e404 < _e405)) {
            break;
        }
        {
            let _e411 = i_12;
            let _e413 = P_canonical[_e411];
            a_15 = _e413;
            let _e415 = i_12;
            nxt_4 = (_e415 + 1i);
            let _e419 = nxt_4;
            let _e420 = p_19;
            if (_e419 >= _e420) {
                nxt_4 = 0i;
            }
            let _e423 = nxt_4;
            let _e425 = P_canonical[_e423];
            b_15 = _e425;
            let _e427 = i_12;
            let _e429 = a_15;
            let _e430 = b_15;
            let _e431 = getCircleForArc(_e429, _e430);
            edgeCircles[_e427] = _e431;
        }
        continuing {
            let _e408 = i_12;
            i_12 = (_e408 + 1i);
        }
    }
    let _e432 = reducedB;
    if (length(_e432) > 0.00001f) {
        {
            let _e436 = reducedB;
            let _e437 = makeDispCircle(_e436);
            dispC = _e437;
            loop {
                let _e441 = i_13;
                let _e442 = p_19;
                if !((_e441 < _e442)) {
                    break;
                }
                {
                    let _e448 = i_13;
                    let _e450 = i_13;
                    let _e452 = P_canonical[_e450];
                    let _e453 = dispC;
                    let _e455 = dispC;
                    let _e457 = invert(_e452, _e453.xy, _e455.z);
                    P_canonical[_e448] = _e457;
                }
                continuing {
                    let _e445 = i_13;
                    i_13 = (_e445 + 1i);
                }
            }
            loop {
                let _e460 = i_14;
                let _e461 = p_19;
                if !((_e460 < _e461)) {
                    break;
                }
                {
                    let _e467 = i_14;
                    let _e469 = P_canonical[_e467];
                    a_16 = _e469;
                    let _e471 = i_14;
                    nxt_5 = (_e471 + 1i);
                    let _e475 = nxt_5;
                    let _e476 = p_19;
                    if (_e475 >= _e476) {
                        nxt_5 = 0i;
                    }
                    let _e479 = nxt_5;
                    let _e481 = P_canonical[_e479];
                    b_16 = _e481;
                    let _e483 = i_14;
                    let _e485 = a_16;
                    let _e486 = b_16;
                    let _e487 = getCircleForArc(_e485, _e486);
                    edgeCircles[_e483] = _e487;
                }
                continuing {
                    let _e464 = i_14;
                    i_14 = (_e464 + 1i);
                }
            }
        }
    }
    let _e488 = discZ;
    u_12 = _e488;
    loop {
        let _e496 = i_15;
        if !((_e496 < MAX_ITER)) {
            break;
        }
        {
            let _e502 = P_canonical;
            let _e503 = u_12;
            let _e504 = p_19;
            let _e505 = inStraightPolygon(_e502, _e503, _e504);
            if _e505 {
                {
                    found = true;
                    let _e507 = i_15;
                    iterCount = _e507;
                    break;
                }
            }
            let _e508 = P_canonical;
            let _e509 = u_12;
            let _e510 = p_19;
            let _e511 = getClosestEdge(_e508, _e509, _e510);
            edgeIdx = _e511;
            let _e513 = edgeIdx;
            let _e516 = edgeIdx;
            let _e517 = p_19;
            if ((_e513 < 0i) || (_e516 >= _e517)) {
                {
                    let _e520 = i_15;
                    iterCount = _e520;
                    break;
                }
            }
            let _e521 = edgeIdx;
            let _e523 = edgeCircles[_e521];
            reflectCircle = _e523;
            let _e525 = reflectCircle;
            if (_e525.z > 100000000f) {
                {
                    let _e529 = i_15;
                    iterCount = _e529;
                    break;
                }
            }
            let _e530 = u_12;
            let _e531 = reflectCircle;
            let _e533 = reflectCircle;
            let _e535 = invert(_e530, _e531.xy, _e533.z);
            u_12 = _e535;
        }
        continuing {
            let _e499 = i_15;
            i_15 = (_e499 + 1i);
        }
    }
    let _e537 = texTransform_1;
    let _e539 = texVar;
    invTexTransform = (_naga_inverse_3x3_f32(_e537) * _e539);
    let _e542 = found;
    if _e542 {
        {
            let _e543 = P_canonical;
            let _e544 = u_12;
            let _e546 = p_19;
            let _e547 = kaleidMap(_e543, _e544, 0f, _e546);
            mapped_pos = _e547;
            let _e549 = mapped_pos;
            let _e550 = suv;
            let _e551 = offset_3;
            mapped_pos = (_e549 + (_e550 * _e551));
            let _e554 = invTexTransform;
            let _e555 = mapped_pos;
            let _e556 = tf(_e554, _e555);
            v_1 = _e556;
            let _e558 = v_1;
            let _e562 = global.U[0];
            let _e565 = v_1;
            let _e574 = _mirror_wrap(((vec2<f32>((_e558.x / _e562.x), _e565.y) / vec2(2f)) + vec2(0.5f)));
            let _e576 = textureSampleLevel(t_source, samp, _e574, 0f);
            col = _e576;
        }
    } else {
        {
            let _e577 = invTexTransform;
            let _e580 = tf(_e577, vec2(0f));
            v_2 = _e580;
            let _e582 = v_2;
            let _e586 = global.U[0];
            let _e589 = v_2;
            let _e598 = _mirror_wrap(((vec2<f32>((_e582.x / _e586.x), _e589.y) / vec2(2f)) + vec2(0.5f)));
            let _e600 = textureSampleLevel(t_source, samp, _e598, 0f);
            col = _e600;
        }
    }
    let _e604 = iterCount;
    capFade = (1f - smoothstep(80f, 100f, f32(_e604)));
    let _e609 = col;
    let _e611 = col;
    let _e613 = capFade;
    let _e614 = (_e611.xyz * _e613);
    col.x = _e614.x;
    col.y = _e614.y;
    col.z = _e614.z;
    let _e621 = vignetting_1;
    t_4 = _e621;
    let _e623 = t_4;
    s1_ = clamp((_e623 * 2f), 0f, 1f);
    let _e630 = t_4;
    s2_ = clamp(((_e630 - 0.5f) * 2f), 0f, 1f);
    let _e641 = s1_;
    cornerRadius = mix(0f, 0.1f, _e641);
    let _e645 = normUV;
    let _e648 = cornerRadius;
    let _e649 = sdRoundedBox(_e645, vec2(1f), _e648);
    distSquare = (1f + _e649);
    let _e654 = distSquare;
    darknessCorner = smoothstep(0.99f, 1f, _e654);
    let _e657 = normUV;
    let _e658 = normUV;
    a2_ = (_e657 * _e658);
    let _e661 = a2_;
    let _e662 = a2_;
    a4_ = (_e661 * _e662);
    let _e665 = a4_;
    let _e667 = a4_;
    sd = sqrt(sqrt((_e665.x + _e667.y)));
    let _e675 = s2_;
    innerSd = mix(1.2f, 0.5f, _e675);
    let _e680 = s2_;
    outerSd = mix(1.4f, 1f, _e680);
    let _e683 = innerSd;
    let _e684 = outerSd;
    let _e685 = sd;
    darknessBody = smoothstep(_e683, _e684, _e685);
    let _e689 = darknessCorner;
    let _e692 = darknessBody;
    cornerMask = ((1f - _e689) * (1f - _e692));
    let _e697 = cornerMask;
    let _e698 = vigAmt;
    cornerMask = mix(1f, _e697, _e698);
    let _e700 = col;
    let _e702 = cornerMask;
    let _e703 = (_e700.xyz * _e702);
    let _e704 = col;
    return vec4<f32>(_e703.x, _e703.y, _e703.z, _e704.w);
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
    let _e68 = global.U[6];
    let _e73 = global.U[7];
    let _e78 = global.U[1];
    let _e79 = _e78.xyz;
    let _e82 = global.U[2];
    let _e83 = _e82.xyz;
    let _e86 = global.U[3];
    let _e87 = _e86.xyz;
    let _e103 = global.U[8];
    let _e104 = _e103.xyz;
    let _e107 = global.U[9];
    let _e108 = _e107.xyz;
    let _e111 = global.U[10];
    let _e112 = _e111.xyz;
    let _e128 = global.U[11];
    let _e129 = _e128.xyz;
    let _e132 = global.U[12];
    let _e133 = _e132.xyz;
    let _e136 = global.U[13];
    let _e137 = _e136.xyz;
    let _e153 = global.U[4];
    let _e157 = global.U[14];
    let _e161 = global.U[15];
    let _e166 = global.U[16];
    let _e168 = hyperbolicSquare((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)), mat3x3<f32>(vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z), vec3<f32>(_e137.x, _e137.y, _e137.z)), _e153.x, _e157.x, i32(_e161.x), _e166.x);
    fragColor = _e168;
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
