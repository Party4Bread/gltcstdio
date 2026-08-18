struct Params {
    U: array<vec4<f32>, 20>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn sdDisk(u: vec2<f32>, r: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_1: f32;

    u_1 = u;
    r_1 = r;
    let _e10 = u_1;
    let _e12 = r_1;
    return (length(_e10) - _e12);
}

fn sdSegment(u_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_1 = a;
    b_1 = b;
    let _e12 = u_3;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn tcdArrow(p: vec2<f32>, a_2: vec2<f32>, b_2: vec2<f32>, ah: f32) -> f32 {
    var p_1: vec2<f32>;
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var ah_1: f32;
    var ab: vec2<f32>;
    var l: f32;
    var dir: vec2<f32>;
    var pp: vec2<f32>;
    var d: f32;

    p_1 = p;
    a_3 = a_2;
    b_3 = b_2;
    ah_1 = ah;
    let _e14 = b_3;
    let _e15 = a_3;
    ab = (_e14 - _e15);
    let _e18 = ab;
    l = max(length(_e18), 0.000001f);
    let _e23 = ab;
    let _e24 = l;
    dir = (_e23 / vec2(_e24));
    let _e28 = dir;
    let _e31 = dir;
    pp = vec2<f32>(-(_e28.y), _e31.x);
    let _e35 = p_1;
    let _e36 = a_3;
    let _e37 = b_3;
    let _e38 = sdSegment(_e35, _e36, _e37);
    d = _e38;
    let _e40 = d;
    let _e41 = p_1;
    let _e42 = a_3;
    let _e43 = a_3;
    let _e44 = dir;
    let _e45 = ah_1;
    let _e48 = pp;
    let _e49 = ah_1;
    let _e54 = sdSegment(_e41, _e42, ((_e43 + (_e44 * _e45)) + ((_e48 * _e49) * 0.38f)));
    d = min(_e40, _e54);
    let _e56 = d;
    let _e57 = p_1;
    let _e58 = a_3;
    let _e59 = a_3;
    let _e60 = dir;
    let _e61 = ah_1;
    let _e64 = pp;
    let _e65 = ah_1;
    let _e70 = sdSegment(_e57, _e58, ((_e59 + (_e60 * _e61)) - ((_e64 * _e65) * 0.38f)));
    d = min(_e56, _e70);
    let _e72 = d;
    let _e73 = p_1;
    let _e74 = b_3;
    let _e75 = b_3;
    let _e76 = dir;
    let _e77 = ah_1;
    let _e80 = pp;
    let _e81 = ah_1;
    let _e86 = sdSegment(_e73, _e74, ((_e75 - (_e76 * _e77)) + ((_e80 * _e81) * 0.38f)));
    d = min(_e72, _e86);
    let _e88 = d;
    let _e89 = p_1;
    let _e90 = b_3;
    let _e91 = b_3;
    let _e92 = dir;
    let _e93 = ah_1;
    let _e96 = pp;
    let _e97 = ah_1;
    let _e102 = sdSegment(_e89, _e90, ((_e91 - (_e92 * _e93)) - ((_e96 * _e97) * 0.38f)));
    d = min(_e88, _e102);
    let _e104 = d;
    return _e104;
}

fn tcdCross(rel: vec2<f32>, r_2: f32) -> f32 {
    var rel_1: vec2<f32>;
    var r_3: f32;
    var d_1: f32;
    var pa: vec2<f32>;

    rel_1 = rel;
    r_3 = r_2;
    let _e10 = rel_1;
    let _e12 = r_3;
    d_1 = abs((length(_e10) - _e12));
    let _e16 = rel_1;
    pa = abs(_e16);
    let _e19 = d_1;
    let _e20 = pa;
    let _e21 = r_3;
    let _e26 = r_3;
    let _e31 = sdSegment(_e20, vec2<f32>((_e21 * 0.45f), 0f), vec2<f32>((_e26 * 1.8f), 0f));
    d_1 = min(_e19, _e31);
    let _e33 = d_1;
    let _e34 = pa;
    let _e36 = r_3;
    let _e41 = r_3;
    let _e45 = sdSegment(_e34, vec2<f32>(0f, (_e36 * 0.45f)), vec2<f32>(0f, (_e41 * 1.8f)));
    d_1 = min(_e33, _e45);
    let _e47 = d_1;
    return _e47;
}

fn ndfCharForSlot(slot: i32, nint: i32, neg: bool, decimals: i32, ipart: f32, av: f32) -> i32 {
    var slot_1: i32;
    var nint_1: i32;
    var neg_1: bool;
    var decimals_1: i32;
    var ipart_1: f32;
    var av_1: f32;
    var local: i32;
    var idx: i32;
    var posFromRight: i32;
    var dv: f32;
    var fpos: i32;
    var dv_1: f32;

    slot_1 = slot;
    nint_1 = nint;
    neg_1 = neg;
    decimals_1 = decimals;
    ipart_1 = ipart;
    av_1 = av;
    let _e18 = slot_1;
    if (_e18 < 0i) {
        return 12i;
    }
    let _e22 = neg_1;
    let _e23 = slot_1;
    if (_e22 && (_e23 == 0i)) {
        return 11i;
    }
    let _e28 = slot_1;
    let _e29 = neg_1;
    if _e29 {
        local = 1i;
    } else {
        local = 0i;
    }
    let _e33 = local;
    idx = (_e28 - _e33);
    let _e36 = idx;
    if (_e36 < 0i) {
        return 12i;
    }
    let _e40 = idx;
    let _e41 = nint_1;
    if (_e40 < _e41) {
        {
            let _e43 = nint_1;
            let _e46 = idx;
            posFromRight = ((_e43 - 1i) - _e46);
            let _e49 = ipart_1;
            let _e51 = posFromRight;
            dv = floor((_e49 / pow(10f, f32(_e51))));
            let _e57 = dv;
            return i32((_e57 - (floor((_e57 / 10f)) * 10f)));
        }
    } else {
        let _e64 = decimals_1;
        let _e67 = idx;
        let _e68 = nint_1;
        if ((_e64 > 0i) && (_e67 == _e68)) {
            {
                return 10i;
            }
        } else {
            {
                let _e72 = idx;
                let _e73 = nint_1;
                fpos = ((_e72 - _e73) - 1i);
                let _e78 = fpos;
                let _e81 = fpos;
                let _e82 = decimals_1;
                if ((_e78 < 0i) || (_e81 >= _e82)) {
                    return 12i;
                }
                let _e86 = av_1;
                let _e88 = fpos;
                dv_1 = floor((_e86 * pow(10f, f32((_e88 + 1i)))));
                let _e96 = dv_1;
                return i32((_e96 - (floor((_e96 / 10f)) * 10f)));
            }
        }
    }
}

fn ndfSdBezier(pos: vec2<f32>, A: vec2<f32>, B: vec2<f32>, C: vec2<f32>) -> f32 {
    var pos_1: vec2<f32>;
    var A_1: vec2<f32>;
    var B_1: vec2<f32>;
    var C_1: vec2<f32>;
    var a_4: vec2<f32>;
    var b_4: vec2<f32>;
    var c: vec2<f32>;
    var d_2: vec2<f32>;
    var bb: f32;
    var kk: f32;
    var kx: f32;
    var ky: f32;
    var kz: f32;
    var res: f32 = 0f;
    var p_2: f32;
    var p3_: f32;
    var q: f32;
    var h_1: f32;
    var x_1: vec2<f32>;
    var uv: vec2<f32>;
    var t: f32;
    var dd: vec2<f32>;
    var z: f32;
    var v_2: f32;
    var m: f32;
    var n: f32;
    var t_1: vec3<f32>;
    var d1_: vec2<f32>;
    var d2_: vec2<f32>;

    pos_1 = pos;
    A_1 = A;
    B_1 = B;
    C_1 = C;
    let _e14 = B_1;
    let _e15 = A_1;
    a_4 = (_e14 - _e15);
    let _e18 = A_1;
    let _e20 = B_1;
    let _e23 = C_1;
    b_4 = ((_e18 - (2f * _e20)) + _e23);
    let _e26 = a_4;
    c = (_e26 * 2f);
    let _e30 = A_1;
    let _e31 = pos_1;
    d_2 = (_e30 - _e31);
    let _e34 = b_4;
    let _e35 = b_4;
    bb = dot(_e34, _e35);
    let _e38 = bb;
    if (_e38 < 0.0000001f) {
        let _e41 = pos_1;
        let _e42 = A_1;
        let _e43 = C_1;
        let _e44 = pos_1;
        let _e45 = A_1;
        let _e47 = C_1;
        let _e48 = A_1;
        let _e51 = C_1;
        let _e52 = A_1;
        let _e54 = C_1;
        let _e55 = A_1;
        return length((_e41 - mix(_e42, _e43, vec2(clamp((dot((_e44 - _e45), (_e47 - _e48)) / max(dot((_e51 - _e52), (_e54 - _e55)), 0.0000001f)), 0f, 1f)))));
    }
    let _e69 = bb;
    kk = (1f / _e69);
    let _e72 = kk;
    let _e73 = a_4;
    let _e74 = b_4;
    kx = (_e72 * dot(_e73, _e74));
    let _e78 = kk;
    let _e80 = a_4;
    let _e81 = a_4;
    let _e84 = d_2;
    let _e85 = b_4;
    ky = ((_e78 * ((2f * dot(_e80, _e81)) + dot(_e84, _e85))) / 3f);
    let _e92 = kk;
    let _e93 = d_2;
    let _e94 = a_4;
    kz = (_e92 * dot(_e93, _e94));
    let _e100 = ky;
    let _e101 = kx;
    let _e102 = kx;
    p_2 = (_e100 - (_e101 * _e102));
    let _e106 = p_2;
    let _e107 = p_2;
    let _e109 = p_2;
    p3_ = ((_e106 * _e107) * _e109);
    let _e112 = kx;
    let _e114 = kx;
    let _e116 = kx;
    let _e119 = ky;
    let _e123 = kz;
    q = ((_e112 * (((2f * _e114) * _e116) - (3f * _e119))) + _e123);
    let _e126 = q;
    let _e127 = q;
    let _e130 = p3_;
    h_1 = ((_e126 * _e127) + (4f * _e130));
    let _e134 = h_1;
    if (_e134 >= 0f) {
        {
            let _e137 = h_1;
            h_1 = sqrt(_e137);
            let _e139 = h_1;
            let _e140 = h_1;
            let _e143 = q;
            x_1 = ((vec2<f32>(_e139, -(_e140)) - vec2(_e143)) / vec2(2f));
            let _e150 = x_1;
            let _e152 = x_1;
            uv = (sign(_e150) * pow(abs(_e152), vec2(0.33333334f)));
            let _e161 = uv;
            let _e163 = uv;
            let _e166 = kx;
            t = clamp(((_e161.x + _e163.y) - _e166), 0f, 1f);
            let _e172 = d_2;
            let _e173 = c;
            let _e174 = b_4;
            let _e175 = t;
            let _e178 = t;
            dd = (_e172 + ((_e173 + (_e174 * _e175)) * _e178));
            let _e182 = dd;
            let _e183 = dd;
            res = dot(_e182, _e183);
        }
    } else {
        {
            let _e185 = p_2;
            z = sqrt(-(_e185));
            let _e189 = q;
            let _e190 = p_2;
            let _e191 = z;
            v_2 = (acos(clamp((_e189 / ((_e190 * _e191) * 2f)), -1f, 1f)) / 3f);
            let _e204 = v_2;
            m = cos(_e204);
            let _e207 = v_2;
            n = (sin(_e207) * 1.7320508f);
            let _e212 = m;
            let _e213 = m;
            let _e215 = n;
            let _e217 = m;
            let _e219 = n;
            let _e220 = m;
            let _e223 = z;
            let _e225 = kx;
            t_1 = clamp(((vec3<f32>((_e212 + _e213), (-(_e215) - _e217), (_e219 - _e220)) * _e223) - vec3(_e225)), vec3(0f), vec3(1f));
            let _e234 = d_2;
            let _e235 = c;
            let _e236 = b_4;
            let _e237 = t_1;
            let _e241 = t_1;
            d1_ = (_e234 + ((_e235 + (_e236 * _e237.x)) * _e241.x));
            let _e246 = d_2;
            let _e247 = c;
            let _e248 = b_4;
            let _e249 = t_1;
            let _e253 = t_1;
            d2_ = (_e246 + ((_e247 + (_e248 * _e249.y)) * _e253.y));
            let _e258 = d1_;
            let _e259 = d1_;
            let _e261 = d2_;
            let _e262 = d2_;
            res = min(dot(_e258, _e259), dot(_e261, _e262));
        }
    }
    let _e265 = res;
    return sqrt(_e265);
}

fn ndfCurved(ch: i32, p_3: vec2<f32>) -> f32 {
    var ch_1: i32;
    var p_4: vec2<f32>;
    var ym: f32 = 0f;
    var yt: f32 = 0.7f;
    var yb: f32 = -0.7f;
    var d_3: f32 = 1000000000f;

    ch_1 = ch;
    p_4 = p_3;
    let _e17 = ch_1;
    if (_e17 == 10i) {
        let _e20 = p_4;
        return length((_e20 - vec2<f32>(0f, -0.56f)));
    }
    let _e27 = ch_1;
    if (_e27 == 11i) {
        let _e30 = p_4;
        let _e33 = ym;
        let _e36 = ym;
        let _e38 = sdSegment(_e30, vec2<f32>(-0.2f, _e33), vec2<f32>(0.2f, _e36));
        return _e38;
    }
    let _e41 = ch_1;
    if (_e41 == 0i) {
        {
            let _e44 = d_3;
            let _e45 = p_4;
            let _e47 = yt;
            let _e50 = yt;
            let _e53 = ym;
            let _e55 = ndfSdBezier(_e45, vec2<f32>(0f, _e47), vec2<f32>(0.25f, _e50), vec2<f32>(0.25f, _e53));
            d_3 = min(_e44, _e55);
            let _e57 = d_3;
            let _e58 = p_4;
            let _e60 = ym;
            let _e63 = yb;
            let _e66 = yb;
            let _e68 = ndfSdBezier(_e58, vec2<f32>(0.25f, _e60), vec2<f32>(0.25f, _e63), vec2<f32>(0f, _e66));
            d_3 = min(_e57, _e68);
            let _e70 = d_3;
            let _e71 = p_4;
            let _e73 = yb;
            let _e77 = yb;
            let _e81 = ym;
            let _e83 = ndfSdBezier(_e71, vec2<f32>(0f, _e73), vec2<f32>(-0.25f, _e77), vec2<f32>(-0.25f, _e81));
            d_3 = min(_e70, _e83);
            let _e85 = d_3;
            let _e86 = p_4;
            let _e89 = ym;
            let _e93 = yt;
            let _e96 = yt;
            let _e98 = ndfSdBezier(_e86, vec2<f32>(-0.25f, _e89), vec2<f32>(-0.25f, _e93), vec2<f32>(0f, _e96));
            d_3 = min(_e85, _e98);
        }
    } else {
        let _e100 = ch_1;
        if (_e100 == 1i) {
            {
                let _e103 = d_3;
                let _e104 = p_4;
                let _e106 = yt;
                let _e109 = yb;
                let _e111 = sdSegment(_e104, vec2<f32>(0.03f, _e106), vec2<f32>(0.03f, _e109));
                d_3 = min(_e103, _e111);
                let _e113 = d_3;
                let _e114 = p_4;
                let _e120 = yt;
                let _e122 = sdSegment(_e114, vec2<f32>(-0.16f, 0.5f), vec2<f32>(0.03f, _e120));
                d_3 = min(_e113, _e122);
                let _e124 = d_3;
                let _e125 = p_4;
                let _e128 = yb;
                let _e131 = yb;
                let _e133 = sdSegment(_e125, vec2<f32>(-0.13f, _e128), vec2<f32>(0.19f, _e131));
                d_3 = min(_e124, _e133);
            }
        } else {
            let _e135 = ch_1;
            if (_e135 == 2i) {
                {
                    let _e138 = d_3;
                    let _e139 = p_4;
                    let _e146 = yt;
                    let _e149 = yt;
                    let _e151 = ndfSdBezier(_e139, vec2<f32>(-0.24f, 0.36f), vec2<f32>(-0.24f, _e146), vec2<f32>(0.04f, _e149));
                    d_3 = min(_e138, _e151);
                    let _e153 = d_3;
                    let _e154 = p_4;
                    let _e156 = yt;
                    let _e159 = yt;
                    let _e164 = ndfSdBezier(_e154, vec2<f32>(0.04f, _e156), vec2<f32>(0.3f, _e159), vec2<f32>(0.3f, 0.34f));
                    d_3 = min(_e153, _e164);
                    let _e166 = d_3;
                    let _e167 = p_4;
                    let _e178 = ndfSdBezier(_e167, vec2<f32>(0.3f, 0.34f), vec2<f32>(0.3f, 0.25f), vec2<f32>(0.07f, -0.14f));
                    d_3 = min(_e166, _e178);
                    let _e180 = d_3;
                    let _e181 = p_4;
                    let _e188 = yb;
                    let _e190 = sdSegment(_e181, vec2<f32>(0.07f, -0.14f), vec2<f32>(-0.25f, _e188));
                    d_3 = min(_e180, _e190);
                    let _e192 = d_3;
                    let _e193 = p_4;
                    let _e196 = yb;
                    let _e199 = yb;
                    let _e201 = sdSegment(_e193, vec2<f32>(-0.25f, _e196), vec2<f32>(0.3f, _e199));
                    d_3 = min(_e192, _e201);
                }
            } else {
                let _e203 = ch_1;
                if (_e203 == 3i) {
                    {
                        let _e206 = d_3;
                        let _e207 = p_4;
                        let _e218 = ndfSdBezier(_e207, vec2<f32>(-0.14f, 0.56f), vec2<f32>(0.14f, 0.84f), vec2<f32>(0.28f, 0.44f));
                        d_3 = min(_e206, _e218);
                        let _e220 = d_3;
                        let _e221 = p_4;
                        let _e230 = ym;
                        let _e232 = ndfSdBezier(_e221, vec2<f32>(0.28f, 0.44f), vec2<f32>(0.3f, 0.06f), vec2<f32>(-0.04f, _e230));
                        d_3 = min(_e220, _e232);
                        let _e234 = d_3;
                        let _e235 = p_4;
                        let _e238 = ym;
                        let _e248 = ndfSdBezier(_e235, vec2<f32>(-0.04f, _e238), vec2<f32>(0.3f, -0.06f), vec2<f32>(0.28f, -0.44f));
                        d_3 = min(_e234, _e248);
                        let _e250 = d_3;
                        let _e251 = p_4;
                        let _e265 = ndfSdBezier(_e251, vec2<f32>(0.28f, -0.44f), vec2<f32>(0.14f, -0.84f), vec2<f32>(-0.14f, -0.56f));
                        d_3 = min(_e250, _e265);
                    }
                } else {
                    let _e267 = ch_1;
                    if (_e267 == 4i) {
                        {
                            let _e270 = d_3;
                            let _e271 = p_4;
                            let _e273 = yt;
                            let _e280 = sdSegment(_e271, vec2<f32>(0.19f, _e273), vec2<f32>(-0.26f, -0.22f));
                            d_3 = min(_e270, _e280);
                            let _e282 = d_3;
                            let _e283 = p_4;
                            let _e293 = sdSegment(_e283, vec2<f32>(-0.26f, -0.22f), vec2<f32>(0.27f, -0.22f));
                            d_3 = min(_e282, _e293);
                            let _e295 = d_3;
                            let _e296 = p_4;
                            let _e298 = yt;
                            let _e301 = yb;
                            let _e303 = sdSegment(_e296, vec2<f32>(0.19f, _e298), vec2<f32>(0.19f, _e301));
                            d_3 = min(_e295, _e303);
                        }
                    } else {
                        let _e305 = ch_1;
                        if (_e305 == 5i) {
                            {
                                let _e308 = d_3;
                                let _e309 = p_4;
                                let _e312 = yt;
                                let _e315 = yt;
                                let _e317 = sdSegment(_e309, vec2<f32>(-0.2f, _e312), vec2<f32>(0.24f, _e315));
                                d_3 = min(_e308, _e317);
                                let _e319 = d_3;
                                let _e320 = p_4;
                                let _e323 = yt;
                                let _e329 = sdSegment(_e320, vec2<f32>(-0.2f, _e323), vec2<f32>(-0.2f, 0.06f));
                                d_3 = min(_e319, _e329);
                                let _e331 = d_3;
                                let _e332 = p_4;
                                let _e344 = ndfSdBezier(_e332, vec2<f32>(-0.2f, 0.06f), vec2<f32>(0.3f, 0.1f), vec2<f32>(0.28f, -0.3f));
                                d_3 = min(_e331, _e344);
                                let _e346 = d_3;
                                let _e347 = p_4;
                                let _e357 = yb;
                                let _e359 = ndfSdBezier(_e347, vec2<f32>(0.28f, -0.3f), vec2<f32>(0.28f, -0.7f), vec2<f32>(0f, _e357));
                                d_3 = min(_e346, _e359);
                                let _e361 = d_3;
                                let _e362 = p_4;
                                let _e364 = yb;
                                let _e376 = ndfSdBezier(_e362, vec2<f32>(0f, _e364), vec2<f32>(-0.22f, -0.7f), vec2<f32>(-0.22f, -0.42f));
                                d_3 = min(_e361, _e376);
                            }
                        } else {
                            let _e378 = ch_1;
                            if (_e378 == 6i) {
                                {
                                    let _e381 = d_3;
                                    let _e382 = p_4;
                                    let _e395 = ndfSdBezier(_e382, vec2<f32>(0f, -0.02f), vec2<f32>(0.25f, -0.02f), vec2<f32>(0.25f, -0.34f));
                                    d_3 = min(_e381, _e395);
                                    let _e397 = d_3;
                                    let _e398 = p_4;
                                    let _e404 = yb;
                                    let _e407 = yb;
                                    let _e409 = ndfSdBezier(_e398, vec2<f32>(0.25f, -0.34f), vec2<f32>(0.25f, _e404), vec2<f32>(0f, _e407));
                                    d_3 = min(_e397, _e409);
                                    let _e411 = d_3;
                                    let _e412 = p_4;
                                    let _e414 = yb;
                                    let _e418 = yb;
                                    let _e425 = ndfSdBezier(_e412, vec2<f32>(0f, _e414), vec2<f32>(-0.25f, _e418), vec2<f32>(-0.25f, -0.34f));
                                    d_3 = min(_e411, _e425);
                                    let _e427 = d_3;
                                    let _e428 = p_4;
                                    let _e443 = ndfSdBezier(_e428, vec2<f32>(-0.25f, -0.34f), vec2<f32>(-0.25f, -0.02f), vec2<f32>(0f, -0.02f));
                                    d_3 = min(_e427, _e443);
                                    let _e445 = d_3;
                                    let _e446 = p_4;
                                    let _e448 = yt;
                                    let _e459 = ndfSdBezier(_e446, vec2<f32>(0.18f, _e448), vec2<f32>(-0.22f, 0.34f), vec2<f32>(-0.25f, -0.3f));
                                    d_3 = min(_e445, _e459);
                                }
                            } else {
                                let _e461 = ch_1;
                                if (_e461 == 7i) {
                                    {
                                        let _e464 = d_3;
                                        let _e465 = p_4;
                                        let _e468 = yt;
                                        let _e471 = yt;
                                        let _e473 = sdSegment(_e465, vec2<f32>(-0.22f, _e468), vec2<f32>(0.26f, _e471));
                                        d_3 = min(_e464, _e473);
                                        let _e475 = d_3;
                                        let _e476 = p_4;
                                        let _e478 = yt;
                                        let _e485 = yb;
                                        let _e487 = ndfSdBezier(_e476, vec2<f32>(0.26f, _e478), vec2<f32>(0.06f, 0f), vec2<f32>(-0.1f, _e485));
                                        d_3 = min(_e475, _e487);
                                    }
                                } else {
                                    let _e489 = ch_1;
                                    if (_e489 == 8i) {
                                        {
                                            let _e492 = d_3;
                                            let _e493 = p_4;
                                            let _e495 = yt;
                                            let _e498 = yt;
                                            let _e503 = ndfSdBezier(_e493, vec2<f32>(0f, _e495), vec2<f32>(0.19f, _e498), vec2<f32>(0.19f, 0.35f));
                                            d_3 = min(_e492, _e503);
                                            let _e505 = d_3;
                                            let _e506 = p_4;
                                            let _e511 = ym;
                                            let _e514 = ym;
                                            let _e516 = ndfSdBezier(_e506, vec2<f32>(0.19f, 0.35f), vec2<f32>(0.19f, _e511), vec2<f32>(0f, _e514));
                                            d_3 = min(_e505, _e516);
                                            let _e518 = d_3;
                                            let _e519 = p_4;
                                            let _e521 = ym;
                                            let _e525 = ym;
                                            let _e531 = ndfSdBezier(_e519, vec2<f32>(0f, _e521), vec2<f32>(-0.19f, _e525), vec2<f32>(-0.19f, 0.35f));
                                            d_3 = min(_e518, _e531);
                                            let _e533 = d_3;
                                            let _e534 = p_4;
                                            let _e541 = yt;
                                            let _e544 = yt;
                                            let _e546 = ndfSdBezier(_e534, vec2<f32>(-0.19f, 0.35f), vec2<f32>(-0.19f, _e541), vec2<f32>(0f, _e544));
                                            d_3 = min(_e533, _e546);
                                            let _e548 = d_3;
                                            let _e549 = p_4;
                                            let _e551 = ym;
                                            let _e554 = ym;
                                            let _e560 = ndfSdBezier(_e549, vec2<f32>(0f, _e551), vec2<f32>(0.24f, _e554), vec2<f32>(0.24f, -0.36f));
                                            d_3 = min(_e548, _e560);
                                            let _e562 = d_3;
                                            let _e563 = p_4;
                                            let _e569 = yb;
                                            let _e572 = yb;
                                            let _e574 = ndfSdBezier(_e563, vec2<f32>(0.24f, -0.36f), vec2<f32>(0.24f, _e569), vec2<f32>(0f, _e572));
                                            d_3 = min(_e562, _e574);
                                            let _e576 = d_3;
                                            let _e577 = p_4;
                                            let _e579 = yb;
                                            let _e583 = yb;
                                            let _e590 = ndfSdBezier(_e577, vec2<f32>(0f, _e579), vec2<f32>(-0.24f, _e583), vec2<f32>(-0.24f, -0.36f));
                                            d_3 = min(_e576, _e590);
                                            let _e592 = d_3;
                                            let _e593 = p_4;
                                            let _e601 = ym;
                                            let _e604 = ym;
                                            let _e606 = ndfSdBezier(_e593, vec2<f32>(-0.24f, -0.36f), vec2<f32>(-0.24f, _e601), vec2<f32>(0f, _e604));
                                            d_3 = min(_e592, _e606);
                                        }
                                    } else {
                                        let _e608 = ch_1;
                                        if (_e608 == 9i) {
                                            {
                                                let _e611 = d_3;
                                                let _e612 = p_4;
                                                let _e622 = ndfSdBezier(_e612, vec2<f32>(0f, 0.02f), vec2<f32>(0.25f, 0.02f), vec2<f32>(0.25f, 0.34f));
                                                d_3 = min(_e611, _e622);
                                                let _e624 = d_3;
                                                let _e625 = p_4;
                                                let _e630 = yt;
                                                let _e633 = yt;
                                                let _e635 = ndfSdBezier(_e625, vec2<f32>(0.25f, 0.34f), vec2<f32>(0.25f, _e630), vec2<f32>(0f, _e633));
                                                d_3 = min(_e624, _e635);
                                                let _e637 = d_3;
                                                let _e638 = p_4;
                                                let _e640 = yt;
                                                let _e644 = yt;
                                                let _e650 = ndfSdBezier(_e638, vec2<f32>(0f, _e640), vec2<f32>(-0.25f, _e644), vec2<f32>(-0.25f, 0.34f));
                                                d_3 = min(_e637, _e650);
                                                let _e652 = d_3;
                                                let _e653 = p_4;
                                                let _e665 = ndfSdBezier(_e653, vec2<f32>(-0.25f, 0.34f), vec2<f32>(-0.25f, 0.02f), vec2<f32>(0f, 0.02f));
                                                d_3 = min(_e652, _e665);
                                                let _e667 = d_3;
                                                let _e668 = p_4;
                                                let _e671 = yb;
                                                let _e680 = ndfSdBezier(_e668, vec2<f32>(-0.18f, _e671), vec2<f32>(0.22f, -0.34f), vec2<f32>(0.25f, 0.3f));
                                                d_3 = min(_e667, _e680);
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
    let _e682 = d_3;
    return _e682;
}

fn ndfSevenSeg(ch_2: i32) -> i32 {
    var ch_3: i32;

    ch_3 = ch_2;
    let _e8 = ch_3;
    if (_e8 == 0i) {
        return 63i;
    }
    let _e12 = ch_3;
    if (_e12 == 1i) {
        return 6i;
    }
    let _e16 = ch_3;
    if (_e16 == 2i) {
        return 91i;
    }
    let _e20 = ch_3;
    if (_e20 == 3i) {
        return 79i;
    }
    let _e24 = ch_3;
    if (_e24 == 4i) {
        return 102i;
    }
    let _e28 = ch_3;
    if (_e28 == 5i) {
        return 109i;
    }
    let _e32 = ch_3;
    if (_e32 == 6i) {
        return 125i;
    }
    let _e36 = ch_3;
    if (_e36 == 7i) {
        return 7i;
    }
    let _e40 = ch_3;
    if (_e40 == 8i) {
        return 127i;
    }
    let _e44 = ch_3;
    if (_e44 == 9i) {
        return 111i;
    }
    let _e48 = ch_3;
    if (_e48 == 11i) {
        return 64i;
    }
    return 0i;
}

fn ndfDigital(ch_4: i32, p_5: vec2<f32>) -> f32 {
    var ch_5: i32;
    var p_6: vec2<f32>;
    var m_1: i32;
    var X: f32 = 0.24f;
    var Yt: f32 = 0.66f;
    var Ym: f32 = 0f;
    var Yb: f32 = -0.66f;
    var d_4: f32 = 1000000000f;

    ch_5 = ch_4;
    p_6 = p_5;
    let _e10 = ch_5;
    if (_e10 == 10i) {
        let _e13 = p_6;
        return length((_e13 - vec2<f32>(0f, -0.66f)));
    }
    let _e20 = ch_5;
    let _e21 = ndfSevenSeg(_e20);
    m_1 = _e21;
    let _e34 = m_1;
    if ((_e34 & 1i) != 0i) {
        let _e39 = d_4;
        let _e40 = p_6;
        let _e41 = X;
        let _e43 = Yt;
        let _e45 = X;
        let _e46 = Yt;
        let _e48 = sdSegment(_e40, vec2<f32>(-(_e41), _e43), vec2<f32>(_e45, _e46));
        d_4 = min(_e39, _e48);
    }
    let _e50 = m_1;
    if ((_e50 & 2i) != 0i) {
        let _e55 = d_4;
        let _e56 = p_6;
        let _e57 = X;
        let _e58 = Ym;
        let _e60 = X;
        let _e61 = Yt;
        let _e63 = sdSegment(_e56, vec2<f32>(_e57, _e58), vec2<f32>(_e60, _e61));
        d_4 = min(_e55, _e63);
    }
    let _e65 = m_1;
    if ((_e65 & 4i) != 0i) {
        let _e70 = d_4;
        let _e71 = p_6;
        let _e72 = X;
        let _e73 = Yb;
        let _e75 = X;
        let _e76 = Ym;
        let _e78 = sdSegment(_e71, vec2<f32>(_e72, _e73), vec2<f32>(_e75, _e76));
        d_4 = min(_e70, _e78);
    }
    let _e80 = m_1;
    if ((_e80 & 8i) != 0i) {
        let _e85 = d_4;
        let _e86 = p_6;
        let _e87 = X;
        let _e89 = Yb;
        let _e91 = X;
        let _e92 = Yb;
        let _e94 = sdSegment(_e86, vec2<f32>(-(_e87), _e89), vec2<f32>(_e91, _e92));
        d_4 = min(_e85, _e94);
    }
    let _e96 = m_1;
    if ((_e96 & 16i) != 0i) {
        let _e101 = d_4;
        let _e102 = p_6;
        let _e103 = X;
        let _e105 = Yb;
        let _e107 = X;
        let _e109 = Ym;
        let _e111 = sdSegment(_e102, vec2<f32>(-(_e103), _e105), vec2<f32>(-(_e107), _e109));
        d_4 = min(_e101, _e111);
    }
    let _e113 = m_1;
    if ((_e113 & 32i) != 0i) {
        let _e118 = d_4;
        let _e119 = p_6;
        let _e120 = X;
        let _e122 = Ym;
        let _e124 = X;
        let _e126 = Yt;
        let _e128 = sdSegment(_e119, vec2<f32>(-(_e120), _e122), vec2<f32>(-(_e124), _e126));
        d_4 = min(_e118, _e128);
    }
    let _e130 = m_1;
    if ((_e130 & 64i) != 0i) {
        let _e135 = d_4;
        let _e136 = p_6;
        let _e137 = X;
        let _e139 = Ym;
        let _e141 = X;
        let _e142 = Ym;
        let _e144 = sdSegment(_e136, vec2<f32>(-(_e137), _e139), vec2<f32>(_e141, _e142));
        d_4 = min(_e135, _e144);
    }
    let _e146 = d_4;
    return _e146;
}

fn tcdNum(rel_2: vec2<f32>, value: f32, decimals_2: i32, nintForce: i32, align: i32, font: i32, gscale: f32) -> f32 {
    var rel_3: vec2<f32>;
    var value_1: f32;
    var decimals_3: i32;
    var nintForce_1: i32;
    var align_1: i32;
    var font_1: i32;
    var gscale_1: f32;
    var neg_2: bool;
    var av_2: f32;
    var local_1: f32;
    var ipart_2: f32;
    var nint_2: i32 = 1i;
    var tt: f32;
    var i: i32 = 0i;
    var local_2: i32;
    var local_3: i32;
    var ng: i32;
    var gadv: f32 = 0.88f;
    var w: f32;
    var local_4: f32;
    var local_5: f32;
    var x_2: f32;
    var dx: f32;
    var dy: f32;
    var lx: f32;
    var slot_2: i32;
    var ch_6: i32;
    var gp: vec2<f32>;
    var local_6: f32;

    rel_3 = rel_2;
    value_1 = value;
    decimals_3 = decimals_2;
    nintForce_1 = nintForce;
    align_1 = align;
    font_1 = font;
    gscale_1 = gscale;
    let _e20 = value_1;
    neg_2 = (_e20 < 0f);
    let _e24 = value_1;
    av_2 = abs(_e24);
    let _e27 = decimals_3;
    if (_e27 == 0i) {
        let _e30 = av_2;
        local_1 = floor((_e30 + 0.5f));
    } else {
        let _e34 = av_2;
        local_1 = floor(_e34);
    }
    let _e37 = local_1;
    ipart_2 = _e37;
    let _e39 = decimals_3;
    if (_e39 == 0i) {
        let _e42 = ipart_2;
        av_2 = _e42;
    }
    let _e45 = ipart_2;
    tt = _e45;
    loop {
        let _e49 = i;
        if !((_e49 < 6i)) {
            break;
        }
        {
            let _e56 = tt;
            if (_e56 >= 10f) {
                {
                    let _e59 = tt;
                    tt = floor((_e59 / 10f));
                    let _e63 = nint_2;
                    nint_2 = (_e63 + 1i);
                }
            }
        }
        continuing {
            let _e53 = i;
            i = (_e53 + 1i);
        }
    }
    let _e66 = nintForce_1;
    if (_e66 > 0i) {
        let _e69 = nintForce_1;
        nint_2 = _e69;
    }
    let _e70 = nint_2;
    let _e71 = neg_2;
    if _e71 {
        local_2 = 1i;
    } else {
        local_2 = 0i;
    }
    let _e75 = local_2;
    let _e77 = decimals_3;
    if (_e77 > 0i) {
        let _e81 = decimals_3;
        local_3 = (1i + _e81);
    } else {
        local_3 = 0i;
    }
    let _e85 = local_3;
    ng = ((_e70 + _e75) + _e85);
    let _e90 = ng;
    let _e92 = gadv;
    let _e94 = gscale_1;
    w = ((f32(_e90) * _e92) * _e94);
    let _e97 = rel_3;
    let _e99 = align_1;
    if (_e99 == 1i) {
        let _e102 = w;
        local_5 = _e102;
    } else {
        let _e103 = align_1;
        if (_e103 == 2i) {
            local_4 = 0f;
        } else {
            let _e107 = w;
            local_4 = (_e107 * 0.5f);
        }
        let _e111 = local_4;
        local_5 = _e111;
    }
    let _e113 = local_5;
    x_2 = (_e97.x + _e113);
    let _e116 = x_2;
    let _e118 = x_2;
    let _e119 = w;
    dx = max(max(-(_e116), (_e118 - _e119)), 0f);
    let _e125 = rel_3;
    let _e129 = gscale_1;
    dy = max((abs(_e125.y) - (0.75f * _e129)), 0f);
    let _e135 = dx;
    let _e138 = dy;
    if ((_e135 > 0f) || (_e138 > 0f)) {
        let _e142 = dx;
        let _e143 = dy;
        let _e147 = gscale_1;
        return (length(vec2<f32>(_e142, _e143)) + (0.35f * _e147));
    }
    let _e150 = x_2;
    let _e151 = gscale_1;
    lx = (_e150 / _e151);
    let _e154 = lx;
    let _e155 = gadv;
    slot_2 = i32(floor((_e154 / _e155)));
    let _e160 = slot_2;
    let _e163 = slot_2;
    let _e164 = ng;
    if ((_e160 < 0i) || (_e163 >= _e164)) {
        let _e168 = gscale_1;
        return (0.35f * _e168);
    }
    let _e170 = slot_2;
    let _e171 = nint_2;
    let _e172 = neg_2;
    let _e173 = decimals_3;
    let _e174 = ipart_2;
    let _e175 = av_2;
    let _e176 = ndfCharForSlot(_e170, _e171, _e172, _e173, _e174, _e175);
    ch_6 = _e176;
    let _e178 = ch_6;
    if (_e178 == 12i) {
        let _e182 = gscale_1;
        return (0.35f * _e182);
    }
    let _e184 = lx;
    let _e185 = slot_2;
    let _e189 = gadv;
    let _e192 = rel_3;
    let _e194 = gscale_1;
    gp = vec2<f32>((_e184 - ((f32(_e185) + 0.5f) * _e189)), (_e192.y / _e194));
    let _e198 = font_1;
    if (_e198 == 0i) {
        let _e201 = ch_6;
        let _e202 = gp;
        let _e203 = ndfDigital(_e201, _e202);
        local_6 = _e203;
    } else {
        let _e204 = ch_6;
        let _e205 = gp;
        let _e206 = ndfCurved(_e204, _e205);
        local_6 = _e206;
    }
    let _e208 = local_6;
    let _e209 = gscale_1;
    return (_e208 * _e209);
}

fn tcdRect(rel_4: vec2<f32>, hlf: vec2<f32>) -> f32 {
    var rel_5: vec2<f32>;
    var hlf_1: vec2<f32>;
    var q_1: vec2<f32>;

    rel_5 = rel_4;
    hlf_1 = hlf;
    let _e10 = rel_5;
    let _e12 = hlf_1;
    q_1 = (abs(_e10) - _e12);
    let _e15 = q_1;
    let _e20 = q_1;
    let _e22 = q_1;
    return abs((length(max(_e15, vec2(0f))) + min(max(_e20.x, _e22.y), 0f)));
}

fn tcdReg(rel_6: vec2<f32>, r_4: f32) -> f32 {
    var rel_7: vec2<f32>;
    var r_5: f32;
    var d_5: f32;
    var pa_1: vec2<f32>;

    rel_7 = rel_6;
    r_5 = r_4;
    let _e10 = rel_7;
    let _e12 = r_5;
    d_5 = abs((length(_e10) - _e12));
    let _e16 = rel_7;
    pa_1 = abs(_e16);
    let _e19 = d_5;
    let _e20 = pa_1;
    let _e24 = r_5;
    let _e29 = sdSegment(_e20, vec2<f32>(0f, 0f), vec2<f32>((_e24 * 1.8f), 0f));
    d_5 = min(_e19, _e29);
    let _e31 = d_5;
    let _e32 = pa_1;
    let _e37 = r_5;
    let _e41 = sdSegment(_e32, vec2<f32>(0f, 0f), vec2<f32>(0f, (_e37 * 1.8f)));
    d_5 = min(_e31, _e41);
    let _e43 = d_5;
    return _e43;
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

fn callouts(uv_1: vec2<f32>, outPos: vec2<f32>, elements: i32, font_2: i32, size: f32, shapeAspectRatio: f32, color1_: vec4<f32>, count: i32, randomSeed: f32, glow: f32, thickness: f32, modelTransform: mat3x3<f32>, axisTransform: mat3x3<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var elements_1: i32;
    var font_3: i32;
    var size_1: f32;
    var shapeAspectRatio_1: f32;
    var color1_1: vec4<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var glow_1: f32;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var axisTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var im: mat3x3<f32>;
    var u_6: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var aa: f32;
    var ar: f32;
    var showFrame: bool;
    var showDims: bool;
    var showCalls: bool;
    var showReg: bool;
    var showTitle: bool;
    var showCross: bool;
    var showFig: bool;
    var showRulers: bool;
    var modelScale: f32;
    var vb: f32;
    var thickHalf: f32;
    var thinHalf: f32;
    var digitHalf: f32;
    var gscale_2: f32;
    var rs: f32;
    var rc: vec2<f32>;
    var rh: vec2<f32>;
    var local_7: f32;
    var glowMargin: f32;
    var inBox: bool;
    var dThick: f32 = 1000000000f;
    var dThin: f32 = 1000000000f;
    var dDigit: f32 = 1000000000f;
    var pv: vec2<f32>;
    var iz: i32 = 1i;
    var xz: f32;
    var ph: vec2<f32>;
    var iz_1: i32 = 1i;
    var yz: f32;
    var iz_2: i32 = 0i;
    var cx: f32;
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;
    var yD: f32;
    var valW: f32;
    var xD: f32;
    var valH: f32;
    var pr: vec2<f32>;
    var i_1: i32 = 0i;
    var h_2: vec2<f32>;
    var t_2: vec2<f32>;
    var local_8: f32;
    var side: f32;
    var slot_3: i32;
    var nSide: i32;
    var j: i32;
    var hj: vec2<f32>;
    var tj: vec2<f32>;
    var local_9: f32;
    var ey: f32;
    var xEnd: f32;
    var ex: f32;
    var e: vec2<f32>;
    var cc: vec2<f32>;
    var tc: vec2<f32>;
    var th: vec2<f32>;
    var h3_: f32;
    var h4_: f32;
    var h5_: f32;
    var rstep: f32 = 0.05f;
    var xr: f32;
    var maj: bool;
    var local_10: f32;
    var yr: f32;
    var majy: bool;
    var local_11: f32;
    var local_12: f32;
    var covThick: f32;
    var local_13: f32;
    var covThin: f32;
    var covDigit: f32;
    var cov: f32;
    var local_14: f32;
    var dmin: f32;
    var local_15: f32;
    var g: f32;
    var outc: vec4<f32>;

    uv_2 = uv_1;
    outPos_1 = outPos;
    elements_1 = elements;
    font_3 = font_2;
    size_1 = size;
    shapeAspectRatio_1 = shapeAspectRatio;
    color1_1 = color1_;
    count_1 = count;
    randomSeed_1 = randomSeed;
    glow_1 = glow;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    axisTransform_1 = axisTransform;
    outDim_1 = outDim;
    let _e34 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e34);
    let _e37 = im;
    let _e38 = uv_2;
    let _e39 = tf(_e37, _e38);
    u_6 = _e39;
    let _e41 = uv_2;
    let _e45 = global.U[0];
    let _e48 = uv_2;
    let _e57 = textureSample(t_source, samp, ((vec2<f32>((_e41.x / _e45.x), _e48.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e57;
    let _e60 = outDim_1;
    pixel = (2f / _e60.y);
    let _e64 = im;
    let _e65 = uv_2;
    let _e66 = pixel;
    let _e70 = tf(_e64, (_e65 + vec2<f32>(_e66, 0f)));
    let _e71 = u_6;
    aa = (length((_e70 - _e71)) * 0.75f);
    let _e78 = u_6;
    u_6.y = -(_e78.y);
    let _e81 = shapeAspectRatio_1;
    ar = _e81;
    let _e83 = elements_1;
    showFrame = ((_e83 & 1i) != 0i);
    let _e89 = elements_1;
    showDims = ((_e89 & 2i) != 0i);
    let _e95 = elements_1;
    showCalls = ((_e95 & 4i) != 0i);
    let _e101 = elements_1;
    showReg = ((_e101 & 8i) != 0i);
    let _e107 = elements_1;
    showTitle = ((_e107 & 16i) != 0i);
    let _e113 = elements_1;
    showCross = ((_e113 & 32i) != 0i);
    let _e119 = elements_1;
    showFig = ((_e119 & 64i) != 0i);
    let _e125 = elements_1;
    showRulers = ((_e125 & 128i) != 0i);
    let _e135 = modelTransform_1[0][0];
    let _e140 = modelTransform_1[0][1];
    modelScale = length(vec2<f32>(_e135, _e140));
    let _e144 = modelScale;
    if (_e144 < 0.00001f) {
        modelScale = 0.00001f;
    }
    let _e149 = modelScale;
    vb = (1f / _e149);
    let _e152 = thickness_1;
    let _e155 = vb;
    thickHalf = ((_e152 * 0.02f) * _e155);
    let _e158 = thickness_1;
    let _e161 = vb;
    thinHalf = ((_e158 * 0.011f) * _e161);
    let _e165 = vb;
    digitHalf = (0.0028f * _e165);
    let _e169 = vb;
    let _e171 = size_1;
    gscale_2 = ((0.042f * _e169) * _e171);
    let _e178 = axisTransform_1[0][0];
    let _e183 = axisTransform_1[0][1];
    rs = length(vec2<f32>(_e178, _e183));
    let _e187 = rs;
    if (_e187 < 0.00001f) {
        rs = 1f;
    }
    let _e195 = axisTransform_1[2][0];
    let _e200 = axisTransform_1[2][1];
    rc = vec2<f32>(_e195, -(_e200));
    let _e205 = ar;
    let _e209 = rs;
    rh = (vec2<f32>(0.52f, (_e205 * 0.42f)) * _e209);
    let _e212 = glow_1;
    if (_e212 > 0.006f) {
        let _e215 = glow_1;
        local_7 = clamp((log((_e215 / 0.006f)) * 0.125f), 0.15f, 1f);
    } else {
        local_7 = 0.15f;
    }
    let _e226 = local_7;
    glowMargin = _e226;
    let _e228 = u_6;
    let _e232 = glowMargin;
    let _e234 = aa;
    let _e237 = u_6;
    let _e240 = ar;
    let _e241 = glowMargin;
    let _e243 = aa;
    inBox = ((abs(_e228.x) <= ((1f + _e232) + _e234)) && (abs(_e237.y) <= ((_e240 + _e241) + _e243)));
    let _e254 = inBox;
    if _e254 {
        {
            let _e255 = showFrame;
            if _e255 {
                {
                    let _e256 = dThick;
                    let _e257 = u_6;
                    let _e259 = ar;
                    let _e263 = tcdRect(_e257, vec2<f32>(0.98f, (_e259 * 0.98f)));
                    dThick = min(_e256, _e263);
                    let _e265 = dThin;
                    let _e266 = u_6;
                    let _e268 = ar;
                    let _e272 = tcdRect(_e266, vec2<f32>(0.94f, (_e268 * 0.94f)));
                    dThin = min(_e265, _e272);
                    let _e274 = u_6;
                    let _e276 = u_6;
                    pv = vec2<f32>(_e274.x, abs(_e276.y));
                    loop {
                        let _e283 = iz;
                        if !((_e283 < 4i)) {
                            break;
                        }
                        {
                            let _e293 = iz;
                            xz = (-0.98f + (0.49f * f32(_e293)));
                            let _e298 = dThin;
                            let _e299 = pv;
                            let _e300 = xz;
                            let _e301 = ar;
                            let _e305 = xz;
                            let _e306 = ar;
                            let _e310 = sdSegment(_e299, vec2<f32>(_e300, (_e301 * 0.94f)), vec2<f32>(_e305, (_e306 * 0.98f)));
                            dThin = min(_e298, _e310);
                        }
                        continuing {
                            let _e287 = iz;
                            iz = (_e287 + 1i);
                        }
                    }
                    let _e312 = u_6;
                    let _e315 = u_6;
                    ph = vec2<f32>(abs(_e312.x), _e315.y);
                    loop {
                        let _e321 = iz_1;
                        if !((_e321 < 3i)) {
                            break;
                        }
                        {
                            let _e328 = ar;
                            let _e332 = ar;
                            let _e335 = iz_1;
                            yz = ((-(_e328) * 0.98f) + ((_e332 * 0.6533f) * f32(_e335)));
                            let _e340 = dThin;
                            let _e341 = ph;
                            let _e343 = yz;
                            let _e346 = yz;
                            let _e348 = sdSegment(_e341, vec2<f32>(0.94f, _e343), vec2<f32>(0.98f, _e346));
                            dThin = min(_e340, _e348);
                        }
                        continuing {
                            let _e325 = iz_1;
                            iz_1 = (_e325 + 1i);
                        }
                    }
                    loop {
                        let _e352 = iz_2;
                        if !((_e352 < 4i)) {
                            break;
                        }
                        {
                            let _e362 = iz_2;
                            cx = (-0.735f + (0.49f * f32(_e362)));
                            let _e367 = dDigit;
                            let _e368 = u_6;
                            let _e370 = cx;
                            let _e372 = u_6;
                            let _e374 = ar;
                            let _e379 = iz_2;
                            let _e386 = font_3;
                            let _e387 = gscale_2;
                            let _e390 = tcdNum(vec2<f32>((_e368.x - _e370), (_e372.y - (_e374 * 0.96f))), f32((_e379 + 1i)), 0i, 0i, 0i, _e386, (_e387 * 0.45f));
                            dDigit = min(_e367, _e390);
                        }
                        continuing {
                            let _e356 = iz_2;
                            iz_2 = (_e356 + 1i);
                        }
                    }
                }
            }
            let _e392 = showDims;
            if _e392 {
                {
                    let _e393 = rc;
                    let _e394 = rh;
                    a_5 = (_e393 - _e394);
                    let _e397 = rc;
                    let _e398 = rh;
                    b_5 = (_e397 + _e398);
                    let _e401 = a_5;
                    yD = (_e401.y - 0.14f);
                    let _e406 = dThin;
                    let _e407 = u_6;
                    let _e408 = a_5;
                    let _e410 = a_5;
                    let _e415 = a_5;
                    let _e417 = yD;
                    let _e421 = sdSegment(_e407, vec2<f32>(_e408.x, (_e410.y - 0.02f)), vec2<f32>(_e415.x, (_e417 - 0.03f)));
                    dThin = min(_e406, _e421);
                    let _e423 = dThin;
                    let _e424 = u_6;
                    let _e425 = b_5;
                    let _e427 = a_5;
                    let _e432 = b_5;
                    let _e434 = yD;
                    let _e438 = sdSegment(_e424, vec2<f32>(_e425.x, (_e427.y - 0.02f)), vec2<f32>(_e432.x, (_e434 - 0.03f)));
                    dThin = min(_e423, _e438);
                    let _e440 = dThin;
                    let _e441 = u_6;
                    let _e442 = a_5;
                    let _e444 = yD;
                    let _e446 = b_5;
                    let _e448 = yD;
                    let _e451 = tcdArrow(_e441, vec2<f32>(_e442.x, _e444), vec2<f32>(_e446.x, _e448), 0.035f);
                    dThin = min(_e440, _e451);
                    let _e453 = b_5;
                    let _e455 = a_5;
                    valW = floor((((_e453.x - _e455.x) * 100f) + 0.5f));
                    let _e464 = dDigit;
                    let _e465 = u_6;
                    let _e467 = rc;
                    let _e470 = u_6;
                    let _e472 = yD;
                    let _e477 = valW;
                    let _e481 = font_3;
                    let _e482 = gscale_2;
                    let _e485 = tcdNum(vec2<f32>((_e465.x - _e467.x), (_e470.y - (_e472 + 0.045f))), _e477, 0i, 0i, 0i, _e481, (_e482 * 0.7f));
                    dDigit = min(_e464, _e485);
                    let _e487 = b_5;
                    xD = (_e487.x + 0.14f);
                    let _e492 = dThin;
                    let _e493 = u_6;
                    let _e494 = b_5;
                    let _e498 = a_5;
                    let _e501 = xD;
                    let _e504 = a_5;
                    let _e507 = sdSegment(_e493, vec2<f32>((_e494.x + 0.02f), _e498.y), vec2<f32>((_e501 + 0.03f), _e504.y));
                    dThin = min(_e492, _e507);
                    let _e509 = dThin;
                    let _e510 = u_6;
                    let _e511 = b_5;
                    let _e515 = b_5;
                    let _e518 = xD;
                    let _e521 = b_5;
                    let _e524 = sdSegment(_e510, vec2<f32>((_e511.x + 0.02f), _e515.y), vec2<f32>((_e518 + 0.03f), _e521.y));
                    dThin = min(_e509, _e524);
                    let _e526 = dThin;
                    let _e527 = u_6;
                    let _e528 = xD;
                    let _e529 = a_5;
                    let _e532 = xD;
                    let _e533 = b_5;
                    let _e537 = tcdArrow(_e527, vec2<f32>(_e528, _e529.y), vec2<f32>(_e532, _e533.y), 0.035f);
                    dThin = min(_e526, _e537);
                    let _e539 = b_5;
                    let _e541 = a_5;
                    valH = floor((((_e539.y - _e541.y) * 100f) + 0.5f));
                    let _e550 = u_6;
                    let _e552 = rc;
                    let _e555 = xD;
                    let _e558 = u_6;
                    pr = vec2<f32>((_e550.y - _e552.y), ((_e555 + 0.065f) - _e558.x));
                    let _e563 = dDigit;
                    let _e564 = pr;
                    let _e565 = valH;
                    let _e569 = font_3;
                    let _e570 = gscale_2;
                    let _e573 = tcdNum(_e564, _e565, 0i, 0i, 0i, _e569, (_e570 * 0.7f));
                    dDigit = min(_e563, _e573);
                }
            }
            let _e575 = showCalls;
            let _e576 = showCross;
            if (_e575 || _e576) {
                {
                    loop {
                        let _e580 = i_1;
                        if !((_e580 < 12i)) {
                            break;
                        }
                        {
                            let _e587 = i_1;
                            let _e588 = count_1;
                            if (_e587 >= _e588) {
                                break;
                            }
                            let _e590 = i_1;
                            let _e598 = randomSeed_1;
                            let _e599 = rand2relSeeded(vec2<f32>(((f32(_e590) * 1.61f) + 2.3f), 5.1f), _e598);
                            h_2 = (_e599 + vec2(0.5f));
                            let _e604 = rc;
                            let _e605 = h_2;
                            let _e611 = rh;
                            t_2 = (_e604 + ((((_e605 - vec2(0.5f)) * 2f) * _e611) * 0.82f));
                            let _e617 = showCross;
                            if _e617 {
                                {
                                    let _e618 = dThin;
                                    let _e619 = u_6;
                                    let _e620 = t_2;
                                    let _e623 = tcdCross((_e619 - _e620), 0.028f);
                                    dThin = min(_e618, _e623);
                                }
                            }
                            let _e625 = showCalls;
                            if _e625 {
                                {
                                    let _e626 = t_2;
                                    let _e628 = rc;
                                    if (_e626.x >= _e628.x) {
                                        local_8 = 1f;
                                    } else {
                                        local_8 = -1f;
                                    }
                                    let _e635 = local_8;
                                    side = _e635;
                                    slot_3 = 0i;
                                    nSide = 0i;
                                    j = 0i;
                                    loop {
                                        let _e643 = j;
                                        if !((_e643 < 12i)) {
                                            break;
                                        }
                                        {
                                            let _e650 = j;
                                            let _e651 = count_1;
                                            if (_e650 >= _e651) {
                                                break;
                                            }
                                            let _e653 = j;
                                            let _e661 = randomSeed_1;
                                            let _e662 = rand2relSeeded(vec2<f32>(((f32(_e653) * 1.61f) + 2.3f), 5.1f), _e661);
                                            hj = (_e662 + vec2(0.5f));
                                            let _e667 = rc;
                                            let _e668 = hj;
                                            let _e674 = rh;
                                            tj = (_e667 + ((((_e668 - vec2(0.5f)) * 2f) * _e674) * 0.82f));
                                            let _e680 = tj;
                                            let _e682 = rc;
                                            if (_e680.x >= _e682.x) {
                                                local_9 = 1f;
                                            } else {
                                                local_9 = -1f;
                                            }
                                            let _e689 = local_9;
                                            let _e690 = side;
                                            if (_e689 == _e690) {
                                                {
                                                    let _e692 = nSide;
                                                    nSide = (_e692 + 1i);
                                                    let _e695 = tj;
                                                    let _e697 = t_2;
                                                    let _e700 = tj;
                                                    let _e702 = t_2;
                                                    let _e705 = j;
                                                    let _e706 = i_1;
                                                    if ((_e695.y > _e697.y) || ((_e700.y == _e702.y) && (_e705 < _e706))) {
                                                        let _e710 = slot_3;
                                                        slot_3 = (_e710 + 1i);
                                                    }
                                                }
                                            }
                                        }
                                        continuing {
                                            let _e647 = j;
                                            j = (_e647 + 1i);
                                        }
                                    }
                                    let _e713 = ar;
                                    let _e716 = slot_3;
                                    let _e720 = ar;
                                    let _e724 = nSide;
                                    ey = ((_e713 * 0.55f) - ((((f32(_e716) + 0.5f) * _e720) * 1.1f) / f32(_e724)));
                                    let _e729 = side;
                                    xEnd = (_e729 * 0.8f);
                                    let _e733 = t_2;
                                    let _e735 = side;
                                    let _e736 = ey;
                                    let _e737 = t_2;
                                    ex = (_e733.x + (_e735 * abs((_e736 - _e737.y))));
                                    let _e744 = side;
                                    if (_e744 > 0f) {
                                        let _e747 = ex;
                                        let _e748 = xEnd;
                                        ex = min(_e747, (_e748 - 0.02f));
                                    } else {
                                        let _e752 = ex;
                                        let _e753 = xEnd;
                                        ex = max(_e752, (_e753 + 0.02f));
                                    }
                                    let _e757 = ex;
                                    let _e758 = ey;
                                    e = vec2<f32>(_e757, _e758);
                                    let _e761 = dThin;
                                    let _e762 = u_6;
                                    let _e763 = t_2;
                                    let _e764 = e;
                                    let _e765 = sdSegment(_e762, _e763, _e764);
                                    dThin = min(_e761, _e765);
                                    let _e767 = dThin;
                                    let _e768 = u_6;
                                    let _e769 = e;
                                    let _e770 = xEnd;
                                    let _e771 = ey;
                                    let _e773 = sdSegment(_e768, _e769, vec2<f32>(_e770, _e771));
                                    dThin = min(_e767, _e773);
                                    let _e775 = dThick;
                                    let _e776 = u_6;
                                    let _e777 = t_2;
                                    let _e780 = sdDisk((_e776 - _e777), 0.011f);
                                    dThick = min(_e775, _e780);
                                    let _e782 = xEnd;
                                    let _e783 = side;
                                    let _e787 = ey;
                                    cc = vec2<f32>((_e782 + (_e783 * 0.052f)), _e787);
                                    let _e790 = dThin;
                                    let _e791 = u_6;
                                    let _e792 = cc;
                                    let _e795 = sdDisk((_e791 - _e792), 0.048f);
                                    dThin = min(_e790, abs(_e795));
                                    let _e798 = dDigit;
                                    let _e799 = u_6;
                                    let _e800 = cc;
                                    let _e802 = i_1;
                                    let _e809 = font_3;
                                    let _e810 = gscale_2;
                                    let _e813 = tcdNum((_e799 - _e800), f32((_e802 + 1i)), 0i, 0i, 0i, _e809, (_e810 * 0.65f));
                                    dDigit = min(_e798, _e813);
                                }
                            }
                        }
                        continuing {
                            let _e584 = i_1;
                            i_1 = (_e584 + 1i);
                        }
                    }
                }
            }
            let _e815 = showReg;
            if _e815 {
                {
                    let _e816 = dThin;
                    let _e817 = u_6;
                    let _e822 = u_6;
                    let _e825 = ar;
                    let _e831 = tcdReg(vec2<f32>((abs(_e817.x) - 0.885f), (abs(_e822.y) - (_e825 * 0.885f))), 0.026f);
                    dThin = min(_e816, _e831);
                }
            }
            let _e833 = showTitle;
            if _e833 {
                {
                    let _e835 = ar;
                    tc = vec2<f32>(0.62f, (-(_e835) * 0.83f));
                    let _e842 = ar;
                    th = vec2<f32>(0.32f, (_e842 * 0.11f));
                    let _e847 = dThick;
                    let _e848 = u_6;
                    let _e849 = tc;
                    let _e851 = th;
                    let _e852 = tcdRect((_e848 - _e849), _e851);
                    dThick = min(_e847, _e852);
                    let _e854 = dThin;
                    let _e855 = u_6;
                    let _e857 = ar;
                    let _e863 = ar;
                    let _e868 = sdSegment(_e855, vec2<f32>(0.3f, (-(_e857) * 0.83f)), vec2<f32>(0.94f, (-(_e863) * 0.83f)));
                    dThin = min(_e854, _e868);
                    let _e870 = dThin;
                    let _e871 = u_6;
                    let _e873 = ar;
                    let _e879 = ar;
                    let _e884 = sdSegment(_e871, vec2<f32>(0.52f, (-(_e873) * 0.72f)), vec2<f32>(0.52f, (-(_e879) * 0.83f)));
                    dThin = min(_e870, _e884);
                    let _e886 = dThin;
                    let _e887 = u_6;
                    let _e889 = ar;
                    let _e895 = ar;
                    let _e900 = sdSegment(_e887, vec2<f32>(0.76f, (-(_e889) * 0.72f)), vec2<f32>(0.76f, (-(_e895) * 0.83f)));
                    dThin = min(_e886, _e900);
                    let _e905 = randomSeed_1;
                    let _e906 = rand2relSeeded(vec2<f32>(3.7f, 9.2f), _e905);
                    h3_ = (_e906.x + 0.5f);
                    let _e911 = dDigit;
                    let _e912 = u_6;
                    let _e916 = u_6;
                    let _e918 = ar;
                    let _e924 = h3_;
                    let _e932 = font_3;
                    let _e933 = gscale_2;
                    let _e936 = tcdNum(vec2<f32>((_e912.x - 0.41f), (_e916.y + (_e918 * 0.775f))), floor((10f + (_e924 * 89f))), 0i, 0i, 0i, _e932, (_e933 * 0.55f));
                    dDigit = min(_e911, _e936);
                    let _e938 = dDigit;
                    let _e939 = u_6;
                    let _e943 = u_6;
                    let _e945 = ar;
                    let _e950 = count_1;
                    let _e955 = font_3;
                    let _e956 = gscale_2;
                    let _e959 = tcdNum(vec2<f32>((_e939.x - 0.64f), (_e943.y + (_e945 * 0.775f))), f32(_e950), 0i, 0i, 0i, _e955, (_e956 * 0.55f));
                    dDigit = min(_e938, _e959);
                    let _e961 = dDigit;
                    let _e962 = u_6;
                    let _e966 = u_6;
                    let _e968 = ar;
                    let _e977 = font_3;
                    let _e978 = gscale_2;
                    let _e981 = tcdNum(vec2<f32>((_e962.x - 0.85f), (_e966.y + (_e968 * 0.775f))), 1.2f, 1i, 0i, 0i, _e977, (_e978 * 0.55f));
                    dDigit = min(_e961, _e981);
                    let _e986 = randomSeed_1;
                    let _e987 = rand2relSeeded(vec2<f32>(8.1f, 2.6f), _e986);
                    h4_ = (_e987.y + 0.5f);
                    let _e992 = dDigit;
                    let _e993 = u_6;
                    let _e997 = u_6;
                    let _e999 = ar;
                    let _e1005 = h4_;
                    let _e1013 = font_3;
                    let _e1014 = gscale_2;
                    let _e1017 = tcdNum(vec2<f32>((_e993.x - 0.62f), (_e997.y + (_e999 * 0.885f))), floor((1000f + (_e1005 * 8999f))), 0i, 0i, 0i, _e1013, (_e1014 * 0.8f));
                    dDigit = min(_e992, _e1017);
                }
            }
            let _e1019 = showFig;
            if _e1019 {
                {
                    let _e1023 = randomSeed_1;
                    let _e1024 = rand2relSeeded(vec2<f32>(6.4f, 4.9f), _e1023);
                    h5_ = (_e1024.x + 0.5f);
                    let _e1029 = dDigit;
                    let _e1030 = u_6;
                    let _e1034 = u_6;
                    let _e1036 = ar;
                    let _e1042 = h5_;
                    let _e1050 = font_3;
                    let _e1051 = gscale_2;
                    let _e1054 = tcdNum(vec2<f32>((_e1030.x + 0.8f), (_e1034.y - (_e1036 * 0.84f))), floor((1f + (_e1042 * 8.9f))), 0i, 0i, 0i, _e1050, (_e1051 * 1.1f));
                    dDigit = min(_e1029, _e1054);
                    let _e1056 = dThin;
                    let _e1057 = u_6;
                    let _e1060 = ar;
                    let _e1066 = ar;
                    let _e1070 = sdSegment(_e1057, vec2<f32>(-0.86f, (_e1060 * 0.775f)), vec2<f32>(-0.74f, (_e1066 * 0.775f)));
                    dThin = min(_e1056, _e1070);
                }
            }
            let _e1072 = showRulers;
            if _e1072 {
                {
                    let _e1075 = u_6;
                    let _e1077 = rstep;
                    let _e1082 = rstep;
                    xr = (floor(((_e1075.x / _e1077) + 0.5f)) * _e1082);
                    let _e1085 = xr;
                    if (abs(_e1085) <= 0.9f) {
                        {
                            let _e1089 = xr;
                            let _e1091 = rstep;
                            let _e1095 = floor(((abs(_e1089) / _e1091) + 0.5f));
                            maj = ((_e1095 - (floor((_e1095 / 5f)) * 5f)) < 0.5f);
                            let _e1104 = dThin;
                            let _e1105 = u_6;
                            let _e1106 = xr;
                            let _e1107 = ar;
                            let _e1111 = xr;
                            let _e1112 = ar;
                            let _e1113 = maj;
                            if _e1113 {
                                local_10 = 0.885f;
                            } else {
                                local_10 = 0.91f;
                            }
                            let _e1117 = local_10;
                            let _e1120 = sdSegment(_e1105, vec2<f32>(_e1106, (_e1107 * 0.94f)), vec2<f32>(_e1111, (_e1112 * _e1117)));
                            dThin = min(_e1104, _e1120);
                        }
                    }
                    let _e1122 = u_6;
                    let _e1124 = rstep;
                    let _e1129 = rstep;
                    yr = (floor(((_e1122.y / _e1124) + 0.5f)) * _e1129);
                    let _e1132 = yr;
                    let _e1134 = ar;
                    if (abs(_e1132) <= (_e1134 * 0.9f)) {
                        {
                            let _e1138 = yr;
                            let _e1140 = rstep;
                            let _e1144 = floor(((abs(_e1138) / _e1140) + 0.5f));
                            majy = ((_e1144 - (floor((_e1144 / 5f)) * 5f)) < 0.5f);
                            let _e1153 = dThin;
                            let _e1154 = u_6;
                            let _e1157 = yr;
                            let _e1159 = majy;
                            if _e1159 {
                                local_11 = -0.885f;
                            } else {
                                local_11 = -0.91f;
                            }
                            let _e1165 = local_11;
                            let _e1166 = yr;
                            let _e1168 = sdSegment(_e1154, vec2<f32>(-0.94f, _e1157), vec2<f32>(_e1165, _e1166));
                            dThin = min(_e1153, _e1168);
                        }
                    }
                }
            }
        }
    }
    let _e1170 = thickHalf;
    if (_e1170 <= 0f) {
        local_12 = 0f;
    } else {
        let _e1175 = thickHalf;
        let _e1176 = aa;
        let _e1178 = thickHalf;
        let _e1179 = aa;
        let _e1181 = dThick;
        local_12 = (1f - smoothstep((_e1175 - _e1176), (_e1178 + _e1179), _e1181));
    }
    let _e1185 = local_12;
    covThick = _e1185;
    let _e1187 = thinHalf;
    if (_e1187 <= 0f) {
        local_13 = 0f;
    } else {
        let _e1192 = thinHalf;
        let _e1193 = aa;
        let _e1195 = thinHalf;
        let _e1196 = aa;
        let _e1198 = dThin;
        local_13 = (1f - smoothstep((_e1192 - _e1193), (_e1195 + _e1196), _e1198));
    }
    let _e1202 = local_13;
    covThin = _e1202;
    let _e1205 = digitHalf;
    let _e1206 = aa;
    let _e1208 = digitHalf;
    let _e1209 = aa;
    let _e1211 = dDigit;
    covDigit = (1f - smoothstep((_e1205 - _e1206), (_e1208 + _e1209), _e1211));
    let _e1215 = covThick;
    let _e1216 = covThin;
    let _e1217 = covDigit;
    cov = max(_e1215, max(_e1216, _e1217));
    let _e1221 = dDigit;
    let _e1222 = thickHalf;
    if (_e1222 <= 0f) {
        local_14 = 1000000000f;
    } else {
        let _e1226 = dThick;
        let _e1227 = dThin;
        local_14 = min(_e1226, _e1227);
    }
    let _e1230 = local_14;
    dmin = min(_e1221, _e1230);
    let _e1233 = glow_1;
    if (_e1233 > 0f) {
        let _e1236 = glow_1;
        let _e1237 = dmin;
        let _e1238 = thickHalf;
        let _e1239 = digitHalf;
        let _e1250 = cov;
        local_15 = ((_e1236 * exp((-(max((_e1237 - max(_e1238, _e1239)), 0f)) * 8f))) * (1f - _e1250));
    } else {
        local_15 = 0f;
    }
    let _e1255 = local_15;
    g = _e1255;
    let _e1257 = cov;
    let _e1260 = g;
    if ((_e1257 <= 0f) && (_e1260 <= 0.002f)) {
        let _e1264 = bkg_2;
        return _e1264;
    }
    let _e1265 = bkg_2;
    let _e1266 = color1_1;
    let _e1267 = _e1266.xyz;
    let _e1268 = color1_1;
    let _e1270 = cov;
    let _e1276 = mergeColor(_e1265, vec4<f32>(_e1267.x, _e1267.y, _e1267.z, (_e1268.w * _e1270)));
    outc = _e1276;
    let _e1278 = outc;
    let _e1280 = outc;
    let _e1282 = color1_1;
    let _e1284 = g;
    let _e1286 = (_e1280.xyz + (_e1282.xyz * _e1284));
    outc.x = _e1286.x;
    outc.y = _e1286.y;
    outc.z = _e1286.z;
    let _e1294 = outc;
    let _e1296 = g;
    outc.w = max(_e1294.w, min(_e1296, 1f));
    let _e1300 = outc;
    return _e1300;
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
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e100 = global.U[13];
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e108 = global.U[15];
    let _e109 = _e108.xyz;
    let _e112 = global.U[16];
    let _e113 = _e112.xyz;
    let _e129 = global.U[17];
    let _e130 = _e129.xyz;
    let _e133 = global.U[18];
    let _e134 = _e133.xyz;
    let _e137 = global.U[19];
    let _e138 = _e137.xyz;
    let _e154 = global.U[4];
    let _e156 = callouts((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, i32(_e87.x), _e92.x, _e96.x, _e100.x, mat3x3<f32>(vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z)), mat3x3<f32>(vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z), vec3<f32>(_e138.x, _e138.y, _e138.z)), _e154.xy);
    fragColor = _e156;
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
