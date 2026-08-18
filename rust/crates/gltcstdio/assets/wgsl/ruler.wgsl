struct Params {
    U: array<vec4<f32>, 18>,
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
    var a: vec2<f32>;
    var b: vec2<f32>;
    var c: vec2<f32>;
    var d: vec2<f32>;
    var bb: f32;
    var kk: f32;
    var kx: f32;
    var ky: f32;
    var kz: f32;
    var res: f32 = 0f;
    var p: f32;
    var p3_: f32;
    var q: f32;
    var h: f32;
    var x: vec2<f32>;
    var uv: vec2<f32>;
    var t: f32;
    var dd: vec2<f32>;
    var z: f32;
    var v: f32;
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
    a = (_e14 - _e15);
    let _e18 = A_1;
    let _e20 = B_1;
    let _e23 = C_1;
    b = ((_e18 - (2f * _e20)) + _e23);
    let _e26 = a;
    c = (_e26 * 2f);
    let _e30 = A_1;
    let _e31 = pos_1;
    d = (_e30 - _e31);
    let _e34 = b;
    let _e35 = b;
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
    let _e73 = a;
    let _e74 = b;
    kx = (_e72 * dot(_e73, _e74));
    let _e78 = kk;
    let _e80 = a;
    let _e81 = a;
    let _e84 = d;
    let _e85 = b;
    ky = ((_e78 * ((2f * dot(_e80, _e81)) + dot(_e84, _e85))) / 3f);
    let _e92 = kk;
    let _e93 = d;
    let _e94 = a;
    kz = (_e92 * dot(_e93, _e94));
    let _e100 = ky;
    let _e101 = kx;
    let _e102 = kx;
    p = (_e100 - (_e101 * _e102));
    let _e106 = p;
    let _e107 = p;
    let _e109 = p;
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
    h = ((_e126 * _e127) + (4f * _e130));
    let _e134 = h;
    if (_e134 >= 0f) {
        {
            let _e137 = h;
            h = sqrt(_e137);
            let _e139 = h;
            let _e140 = h;
            let _e143 = q;
            x = ((vec2<f32>(_e139, -(_e140)) - vec2(_e143)) / vec2(2f));
            let _e150 = x;
            let _e152 = x;
            uv = (sign(_e150) * pow(abs(_e152), vec2(0.33333334f)));
            let _e161 = uv;
            let _e163 = uv;
            let _e166 = kx;
            t = clamp(((_e161.x + _e163.y) - _e166), 0f, 1f);
            let _e172 = d;
            let _e173 = c;
            let _e174 = b;
            let _e175 = t;
            let _e178 = t;
            dd = (_e172 + ((_e173 + (_e174 * _e175)) * _e178));
            let _e182 = dd;
            let _e183 = dd;
            res = dot(_e182, _e183);
        }
    } else {
        {
            let _e185 = p;
            z = sqrt(-(_e185));
            let _e189 = q;
            let _e190 = p;
            let _e191 = z;
            v = (acos(clamp((_e189 / ((_e190 * _e191) * 2f)), -1f, 1f)) / 3f);
            let _e204 = v;
            m = cos(_e204);
            let _e207 = v;
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
            let _e234 = d;
            let _e235 = c;
            let _e236 = b;
            let _e237 = t_1;
            let _e241 = t_1;
            d1_ = (_e234 + ((_e235 + (_e236 * _e237.x)) * _e241.x));
            let _e246 = d;
            let _e247 = c;
            let _e248 = b;
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

fn sdSegment(u: vec2<f32>, a_1: vec2<f32>, b_1: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h_1: f32;

    u_1 = u;
    a_2 = a_1;
    b_2 = b_1;
    let _e12 = u_1;
    let _e13 = a_2;
    ua = (_e12 - _e13);
    let _e16 = b_2;
    let _e17 = a_2;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h_1 = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h_1;
    return length((_e31 - (_e32 * _e33)));
}

fn ndfCurved(ch: i32, p_1: vec2<f32>) -> f32 {
    var ch_1: i32;
    var p_2: vec2<f32>;
    var ym: f32 = 0f;
    var yt: f32 = 0.7f;
    var yb: f32 = -0.7f;
    var d_1: f32 = 1000000000f;

    ch_1 = ch;
    p_2 = p_1;
    let _e17 = ch_1;
    if (_e17 == 10i) {
        let _e20 = p_2;
        return length((_e20 - vec2<f32>(0f, -0.56f)));
    }
    let _e27 = ch_1;
    if (_e27 == 11i) {
        let _e30 = p_2;
        let _e33 = ym;
        let _e36 = ym;
        let _e38 = sdSegment(_e30, vec2<f32>(-0.2f, _e33), vec2<f32>(0.2f, _e36));
        return _e38;
    }
    let _e41 = ch_1;
    if (_e41 == 0i) {
        {
            let _e44 = d_1;
            let _e45 = p_2;
            let _e47 = yt;
            let _e50 = yt;
            let _e53 = ym;
            let _e55 = ndfSdBezier(_e45, vec2<f32>(0f, _e47), vec2<f32>(0.25f, _e50), vec2<f32>(0.25f, _e53));
            d_1 = min(_e44, _e55);
            let _e57 = d_1;
            let _e58 = p_2;
            let _e60 = ym;
            let _e63 = yb;
            let _e66 = yb;
            let _e68 = ndfSdBezier(_e58, vec2<f32>(0.25f, _e60), vec2<f32>(0.25f, _e63), vec2<f32>(0f, _e66));
            d_1 = min(_e57, _e68);
            let _e70 = d_1;
            let _e71 = p_2;
            let _e73 = yb;
            let _e77 = yb;
            let _e81 = ym;
            let _e83 = ndfSdBezier(_e71, vec2<f32>(0f, _e73), vec2<f32>(-0.25f, _e77), vec2<f32>(-0.25f, _e81));
            d_1 = min(_e70, _e83);
            let _e85 = d_1;
            let _e86 = p_2;
            let _e89 = ym;
            let _e93 = yt;
            let _e96 = yt;
            let _e98 = ndfSdBezier(_e86, vec2<f32>(-0.25f, _e89), vec2<f32>(-0.25f, _e93), vec2<f32>(0f, _e96));
            d_1 = min(_e85, _e98);
        }
    } else {
        let _e100 = ch_1;
        if (_e100 == 1i) {
            {
                let _e103 = d_1;
                let _e104 = p_2;
                let _e106 = yt;
                let _e109 = yb;
                let _e111 = sdSegment(_e104, vec2<f32>(0.03f, _e106), vec2<f32>(0.03f, _e109));
                d_1 = min(_e103, _e111);
                let _e113 = d_1;
                let _e114 = p_2;
                let _e120 = yt;
                let _e122 = sdSegment(_e114, vec2<f32>(-0.16f, 0.5f), vec2<f32>(0.03f, _e120));
                d_1 = min(_e113, _e122);
                let _e124 = d_1;
                let _e125 = p_2;
                let _e128 = yb;
                let _e131 = yb;
                let _e133 = sdSegment(_e125, vec2<f32>(-0.13f, _e128), vec2<f32>(0.19f, _e131));
                d_1 = min(_e124, _e133);
            }
        } else {
            let _e135 = ch_1;
            if (_e135 == 2i) {
                {
                    let _e138 = d_1;
                    let _e139 = p_2;
                    let _e146 = yt;
                    let _e149 = yt;
                    let _e151 = ndfSdBezier(_e139, vec2<f32>(-0.24f, 0.36f), vec2<f32>(-0.24f, _e146), vec2<f32>(0.04f, _e149));
                    d_1 = min(_e138, _e151);
                    let _e153 = d_1;
                    let _e154 = p_2;
                    let _e156 = yt;
                    let _e159 = yt;
                    let _e164 = ndfSdBezier(_e154, vec2<f32>(0.04f, _e156), vec2<f32>(0.3f, _e159), vec2<f32>(0.3f, 0.34f));
                    d_1 = min(_e153, _e164);
                    let _e166 = d_1;
                    let _e167 = p_2;
                    let _e178 = ndfSdBezier(_e167, vec2<f32>(0.3f, 0.34f), vec2<f32>(0.3f, 0.25f), vec2<f32>(0.07f, -0.14f));
                    d_1 = min(_e166, _e178);
                    let _e180 = d_1;
                    let _e181 = p_2;
                    let _e188 = yb;
                    let _e190 = sdSegment(_e181, vec2<f32>(0.07f, -0.14f), vec2<f32>(-0.25f, _e188));
                    d_1 = min(_e180, _e190);
                    let _e192 = d_1;
                    let _e193 = p_2;
                    let _e196 = yb;
                    let _e199 = yb;
                    let _e201 = sdSegment(_e193, vec2<f32>(-0.25f, _e196), vec2<f32>(0.3f, _e199));
                    d_1 = min(_e192, _e201);
                }
            } else {
                let _e203 = ch_1;
                if (_e203 == 3i) {
                    {
                        let _e206 = d_1;
                        let _e207 = p_2;
                        let _e218 = ndfSdBezier(_e207, vec2<f32>(-0.14f, 0.56f), vec2<f32>(0.14f, 0.84f), vec2<f32>(0.28f, 0.44f));
                        d_1 = min(_e206, _e218);
                        let _e220 = d_1;
                        let _e221 = p_2;
                        let _e230 = ym;
                        let _e232 = ndfSdBezier(_e221, vec2<f32>(0.28f, 0.44f), vec2<f32>(0.3f, 0.06f), vec2<f32>(-0.04f, _e230));
                        d_1 = min(_e220, _e232);
                        let _e234 = d_1;
                        let _e235 = p_2;
                        let _e238 = ym;
                        let _e248 = ndfSdBezier(_e235, vec2<f32>(-0.04f, _e238), vec2<f32>(0.3f, -0.06f), vec2<f32>(0.28f, -0.44f));
                        d_1 = min(_e234, _e248);
                        let _e250 = d_1;
                        let _e251 = p_2;
                        let _e265 = ndfSdBezier(_e251, vec2<f32>(0.28f, -0.44f), vec2<f32>(0.14f, -0.84f), vec2<f32>(-0.14f, -0.56f));
                        d_1 = min(_e250, _e265);
                    }
                } else {
                    let _e267 = ch_1;
                    if (_e267 == 4i) {
                        {
                            let _e270 = d_1;
                            let _e271 = p_2;
                            let _e273 = yt;
                            let _e280 = sdSegment(_e271, vec2<f32>(0.19f, _e273), vec2<f32>(-0.26f, -0.22f));
                            d_1 = min(_e270, _e280);
                            let _e282 = d_1;
                            let _e283 = p_2;
                            let _e293 = sdSegment(_e283, vec2<f32>(-0.26f, -0.22f), vec2<f32>(0.27f, -0.22f));
                            d_1 = min(_e282, _e293);
                            let _e295 = d_1;
                            let _e296 = p_2;
                            let _e298 = yt;
                            let _e301 = yb;
                            let _e303 = sdSegment(_e296, vec2<f32>(0.19f, _e298), vec2<f32>(0.19f, _e301));
                            d_1 = min(_e295, _e303);
                        }
                    } else {
                        let _e305 = ch_1;
                        if (_e305 == 5i) {
                            {
                                let _e308 = d_1;
                                let _e309 = p_2;
                                let _e312 = yt;
                                let _e315 = yt;
                                let _e317 = sdSegment(_e309, vec2<f32>(-0.2f, _e312), vec2<f32>(0.24f, _e315));
                                d_1 = min(_e308, _e317);
                                let _e319 = d_1;
                                let _e320 = p_2;
                                let _e323 = yt;
                                let _e329 = sdSegment(_e320, vec2<f32>(-0.2f, _e323), vec2<f32>(-0.2f, 0.06f));
                                d_1 = min(_e319, _e329);
                                let _e331 = d_1;
                                let _e332 = p_2;
                                let _e344 = ndfSdBezier(_e332, vec2<f32>(-0.2f, 0.06f), vec2<f32>(0.3f, 0.1f), vec2<f32>(0.28f, -0.3f));
                                d_1 = min(_e331, _e344);
                                let _e346 = d_1;
                                let _e347 = p_2;
                                let _e357 = yb;
                                let _e359 = ndfSdBezier(_e347, vec2<f32>(0.28f, -0.3f), vec2<f32>(0.28f, -0.7f), vec2<f32>(0f, _e357));
                                d_1 = min(_e346, _e359);
                                let _e361 = d_1;
                                let _e362 = p_2;
                                let _e364 = yb;
                                let _e376 = ndfSdBezier(_e362, vec2<f32>(0f, _e364), vec2<f32>(-0.22f, -0.7f), vec2<f32>(-0.22f, -0.42f));
                                d_1 = min(_e361, _e376);
                            }
                        } else {
                            let _e378 = ch_1;
                            if (_e378 == 6i) {
                                {
                                    let _e381 = d_1;
                                    let _e382 = p_2;
                                    let _e395 = ndfSdBezier(_e382, vec2<f32>(0f, -0.02f), vec2<f32>(0.25f, -0.02f), vec2<f32>(0.25f, -0.34f));
                                    d_1 = min(_e381, _e395);
                                    let _e397 = d_1;
                                    let _e398 = p_2;
                                    let _e404 = yb;
                                    let _e407 = yb;
                                    let _e409 = ndfSdBezier(_e398, vec2<f32>(0.25f, -0.34f), vec2<f32>(0.25f, _e404), vec2<f32>(0f, _e407));
                                    d_1 = min(_e397, _e409);
                                    let _e411 = d_1;
                                    let _e412 = p_2;
                                    let _e414 = yb;
                                    let _e418 = yb;
                                    let _e425 = ndfSdBezier(_e412, vec2<f32>(0f, _e414), vec2<f32>(-0.25f, _e418), vec2<f32>(-0.25f, -0.34f));
                                    d_1 = min(_e411, _e425);
                                    let _e427 = d_1;
                                    let _e428 = p_2;
                                    let _e443 = ndfSdBezier(_e428, vec2<f32>(-0.25f, -0.34f), vec2<f32>(-0.25f, -0.02f), vec2<f32>(0f, -0.02f));
                                    d_1 = min(_e427, _e443);
                                    let _e445 = d_1;
                                    let _e446 = p_2;
                                    let _e448 = yt;
                                    let _e459 = ndfSdBezier(_e446, vec2<f32>(0.18f, _e448), vec2<f32>(-0.22f, 0.34f), vec2<f32>(-0.25f, -0.3f));
                                    d_1 = min(_e445, _e459);
                                }
                            } else {
                                let _e461 = ch_1;
                                if (_e461 == 7i) {
                                    {
                                        let _e464 = d_1;
                                        let _e465 = p_2;
                                        let _e468 = yt;
                                        let _e471 = yt;
                                        let _e473 = sdSegment(_e465, vec2<f32>(-0.22f, _e468), vec2<f32>(0.26f, _e471));
                                        d_1 = min(_e464, _e473);
                                        let _e475 = d_1;
                                        let _e476 = p_2;
                                        let _e478 = yt;
                                        let _e485 = yb;
                                        let _e487 = ndfSdBezier(_e476, vec2<f32>(0.26f, _e478), vec2<f32>(0.06f, 0f), vec2<f32>(-0.1f, _e485));
                                        d_1 = min(_e475, _e487);
                                    }
                                } else {
                                    let _e489 = ch_1;
                                    if (_e489 == 8i) {
                                        {
                                            let _e492 = d_1;
                                            let _e493 = p_2;
                                            let _e495 = yt;
                                            let _e498 = yt;
                                            let _e503 = ndfSdBezier(_e493, vec2<f32>(0f, _e495), vec2<f32>(0.19f, _e498), vec2<f32>(0.19f, 0.35f));
                                            d_1 = min(_e492, _e503);
                                            let _e505 = d_1;
                                            let _e506 = p_2;
                                            let _e511 = ym;
                                            let _e514 = ym;
                                            let _e516 = ndfSdBezier(_e506, vec2<f32>(0.19f, 0.35f), vec2<f32>(0.19f, _e511), vec2<f32>(0f, _e514));
                                            d_1 = min(_e505, _e516);
                                            let _e518 = d_1;
                                            let _e519 = p_2;
                                            let _e521 = ym;
                                            let _e525 = ym;
                                            let _e531 = ndfSdBezier(_e519, vec2<f32>(0f, _e521), vec2<f32>(-0.19f, _e525), vec2<f32>(-0.19f, 0.35f));
                                            d_1 = min(_e518, _e531);
                                            let _e533 = d_1;
                                            let _e534 = p_2;
                                            let _e541 = yt;
                                            let _e544 = yt;
                                            let _e546 = ndfSdBezier(_e534, vec2<f32>(-0.19f, 0.35f), vec2<f32>(-0.19f, _e541), vec2<f32>(0f, _e544));
                                            d_1 = min(_e533, _e546);
                                            let _e548 = d_1;
                                            let _e549 = p_2;
                                            let _e551 = ym;
                                            let _e554 = ym;
                                            let _e560 = ndfSdBezier(_e549, vec2<f32>(0f, _e551), vec2<f32>(0.24f, _e554), vec2<f32>(0.24f, -0.36f));
                                            d_1 = min(_e548, _e560);
                                            let _e562 = d_1;
                                            let _e563 = p_2;
                                            let _e569 = yb;
                                            let _e572 = yb;
                                            let _e574 = ndfSdBezier(_e563, vec2<f32>(0.24f, -0.36f), vec2<f32>(0.24f, _e569), vec2<f32>(0f, _e572));
                                            d_1 = min(_e562, _e574);
                                            let _e576 = d_1;
                                            let _e577 = p_2;
                                            let _e579 = yb;
                                            let _e583 = yb;
                                            let _e590 = ndfSdBezier(_e577, vec2<f32>(0f, _e579), vec2<f32>(-0.24f, _e583), vec2<f32>(-0.24f, -0.36f));
                                            d_1 = min(_e576, _e590);
                                            let _e592 = d_1;
                                            let _e593 = p_2;
                                            let _e601 = ym;
                                            let _e604 = ym;
                                            let _e606 = ndfSdBezier(_e593, vec2<f32>(-0.24f, -0.36f), vec2<f32>(-0.24f, _e601), vec2<f32>(0f, _e604));
                                            d_1 = min(_e592, _e606);
                                        }
                                    } else {
                                        let _e608 = ch_1;
                                        if (_e608 == 9i) {
                                            {
                                                let _e611 = d_1;
                                                let _e612 = p_2;
                                                let _e622 = ndfSdBezier(_e612, vec2<f32>(0f, 0.02f), vec2<f32>(0.25f, 0.02f), vec2<f32>(0.25f, 0.34f));
                                                d_1 = min(_e611, _e622);
                                                let _e624 = d_1;
                                                let _e625 = p_2;
                                                let _e630 = yt;
                                                let _e633 = yt;
                                                let _e635 = ndfSdBezier(_e625, vec2<f32>(0.25f, 0.34f), vec2<f32>(0.25f, _e630), vec2<f32>(0f, _e633));
                                                d_1 = min(_e624, _e635);
                                                let _e637 = d_1;
                                                let _e638 = p_2;
                                                let _e640 = yt;
                                                let _e644 = yt;
                                                let _e650 = ndfSdBezier(_e638, vec2<f32>(0f, _e640), vec2<f32>(-0.25f, _e644), vec2<f32>(-0.25f, 0.34f));
                                                d_1 = min(_e637, _e650);
                                                let _e652 = d_1;
                                                let _e653 = p_2;
                                                let _e665 = ndfSdBezier(_e653, vec2<f32>(-0.25f, 0.34f), vec2<f32>(-0.25f, 0.02f), vec2<f32>(0f, 0.02f));
                                                d_1 = min(_e652, _e665);
                                                let _e667 = d_1;
                                                let _e668 = p_2;
                                                let _e671 = yb;
                                                let _e680 = ndfSdBezier(_e668, vec2<f32>(-0.18f, _e671), vec2<f32>(0.22f, -0.34f), vec2<f32>(0.25f, 0.3f));
                                                d_1 = min(_e667, _e680);
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
    let _e682 = d_1;
    return _e682;
}

fn rulerNumDist(rel: vec2<f32>, value: f32, decimals_2: i32, gscale: f32) -> f32 {
    var rel_1: vec2<f32>;
    var value_1: f32;
    var decimals_3: i32;
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
    var x_1: f32;
    var dx: f32;
    var dy: f32;
    var lx: f32;
    var slot_2: i32;
    var ch_2: i32;
    var gp: vec2<f32>;

    rel_1 = rel;
    value_1 = value;
    decimals_3 = decimals_2;
    gscale_1 = gscale;
    let _e14 = value_1;
    neg_2 = (_e14 < 0f);
    let _e18 = value_1;
    av_2 = abs(_e18);
    let _e21 = decimals_3;
    if (_e21 == 0i) {
        let _e24 = av_2;
        local_1 = floor((_e24 + 0.5f));
    } else {
        let _e28 = av_2;
        local_1 = floor(_e28);
    }
    let _e31 = local_1;
    ipart_2 = _e31;
    let _e33 = decimals_3;
    if (_e33 == 0i) {
        let _e36 = ipart_2;
        av_2 = _e36;
    }
    let _e39 = ipart_2;
    tt = _e39;
    loop {
        let _e43 = i;
        if !((_e43 < 6i)) {
            break;
        }
        {
            let _e50 = tt;
            if (_e50 >= 10f) {
                {
                    let _e53 = tt;
                    tt = floor((_e53 / 10f));
                    let _e57 = nint_2;
                    nint_2 = (_e57 + 1i);
                }
            }
        }
        continuing {
            let _e47 = i;
            i = (_e47 + 1i);
        }
    }
    let _e60 = nint_2;
    let _e61 = neg_2;
    if _e61 {
        local_2 = 1i;
    } else {
        local_2 = 0i;
    }
    let _e65 = local_2;
    let _e67 = decimals_3;
    if (_e67 > 0i) {
        let _e71 = decimals_3;
        local_3 = (1i + _e71);
    } else {
        local_3 = 0i;
    }
    let _e75 = local_3;
    ng = ((_e60 + _e65) + _e75);
    let _e80 = ng;
    let _e82 = gadv;
    let _e84 = gscale_1;
    w = ((f32(_e80) * _e82) * _e84);
    let _e87 = rel_1;
    let _e89 = w;
    x_1 = (_e87.x + (_e89 * 0.5f));
    let _e94 = x_1;
    let _e96 = x_1;
    let _e97 = w;
    dx = max(max(-(_e94), (_e96 - _e97)), 0f);
    let _e103 = rel_1;
    let _e107 = gscale_1;
    dy = max((abs(_e103.y) - (0.75f * _e107)), 0f);
    let _e113 = dx;
    let _e116 = dy;
    if ((_e113 > 0f) || (_e116 > 0f)) {
        let _e120 = dx;
        let _e121 = dy;
        let _e125 = gscale_1;
        return (length(vec2<f32>(_e120, _e121)) + (0.35f * _e125));
    }
    let _e128 = x_1;
    let _e129 = gscale_1;
    lx = (_e128 / _e129);
    let _e132 = lx;
    let _e133 = gadv;
    slot_2 = i32(floor((_e132 / _e133)));
    let _e138 = slot_2;
    let _e141 = slot_2;
    let _e142 = ng;
    if ((_e138 < 0i) || (_e141 >= _e142)) {
        let _e146 = gscale_1;
        return (0.35f * _e146);
    }
    let _e148 = slot_2;
    let _e149 = nint_2;
    let _e150 = neg_2;
    let _e151 = decimals_3;
    let _e152 = ipart_2;
    let _e153 = av_2;
    let _e154 = ndfCharForSlot(_e148, _e149, _e150, _e151, _e152, _e153);
    ch_2 = _e154;
    let _e156 = ch_2;
    if (_e156 == 12i) {
        let _e160 = gscale_1;
        return (0.35f * _e160);
    }
    let _e162 = lx;
    let _e163 = slot_2;
    let _e167 = gadv;
    let _e170 = rel_1;
    let _e173 = gscale_1;
    gp = vec2<f32>((_e162 - ((f32(_e163) + 0.5f) * _e167)), (-(_e170.y) / _e173));
    let _e177 = ch_2;
    let _e178 = gp;
    let _e179 = ndfCurved(_e177, _e178);
    let _e180 = gscale_1;
    return (_e179 * _e180);
}

fn rulerNumGlyphs(value_2: f32, decimals_4: i32) -> i32 {
    var value_3: f32;
    var decimals_5: i32;
    var neg_3: bool;
    var av_3: f32;
    var local_4: f32;
    var ipart_3: f32;
    var nint_3: i32 = 1i;
    var tt_1: f32;
    var i_1: i32 = 0i;
    var local_5: i32;
    var local_6: i32;

    value_3 = value_2;
    decimals_5 = decimals_4;
    let _e10 = value_3;
    neg_3 = (_e10 < 0f);
    let _e14 = value_3;
    av_3 = abs(_e14);
    let _e17 = decimals_5;
    if (_e17 == 0i) {
        let _e20 = av_3;
        local_4 = floor((_e20 + 0.5f));
    } else {
        let _e24 = av_3;
        local_4 = floor(_e24);
    }
    let _e27 = local_4;
    ipart_3 = _e27;
    let _e31 = ipart_3;
    tt_1 = _e31;
    loop {
        let _e35 = i_1;
        if !((_e35 < 6i)) {
            break;
        }
        {
            let _e42 = tt_1;
            if (_e42 >= 10f) {
                {
                    let _e45 = tt_1;
                    tt_1 = floor((_e45 / 10f));
                    let _e49 = nint_3;
                    nint_3 = (_e49 + 1i);
                }
            }
        }
        continuing {
            let _e39 = i_1;
            i_1 = (_e39 + 1i);
        }
    }
    let _e52 = nint_3;
    let _e53 = neg_3;
    if _e53 {
        local_5 = 1i;
    } else {
        local_5 = 0i;
    }
    let _e57 = local_5;
    let _e59 = decimals_5;
    if (_e59 > 0i) {
        let _e63 = decimals_5;
        local_6 = (1i + _e63);
    } else {
        local_6 = 0i;
    }
    let _e67 = local_6;
    return ((_e52 + _e57) + _e67);
}

fn tf(m_1: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_2: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_2 = m_1;
    u_3 = u_2;
    let _e10 = m_2;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn ruler(uv_1: vec2<f32>, outPos: vec2<f32>, elements: i32, justify: i32, numbers: i32, size: f32, numberSize: f32, color1_: vec4<f32>, value_4: f32, range: f32, glow: f32, thickness: f32, modelTransform: mat3x3<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var elements_1: i32;
    var justify_1: i32;
    var numbers_1: i32;
    var size_1: f32;
    var numberSize_1: f32;
    var color1_1: vec4<f32>;
    var value_5: f32;
    var range_1: f32;
    var glow_1: f32;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var im: mat3x3<f32>;
    var u_4: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var aa: f32;
    var showMajors: bool;
    var showSpine: bool;
    var modelScale: f32;
    var vb: f32;
    var minorHalf: f32;
    var majorHalf: f32;
    var digitHalf: f32;
    var gscale_2: f32;
    var gadv_1: f32 = 0.88f;
    var gap: f32;
    var tickMinor: f32;
    var tickMajor: f32;
    var local_7: f32;
    var edgeRef: f32;
    var local_8: f32;
    var glowReach: f32;
    var dataToU: f32;
    var unitV: f32;
    var local_9: f32;
    var minLabelV: f32;
    var raw: f32;
    var b_3: f32;
    var m_3: f32;
    var local_10: f32;
    var local_11: f32;
    var local_12: f32;
    var L: f32;
    var minorL: f32;
    var decimals_6: i32;
    var vv: f32;
    var dMinor: f32 = 1000000000f;
    var dMajor: f32 = 1000000000f;
    var dSpine: f32 = 1000000000f;
    var dDigit: f32 = 1000000000f;
    var k0_: f32;
    var dk: i32 = -2i;
    var kk_1: f32;
    var vk: f32;
    var yk: f32;
    var isMaj: bool;
    var local_13: f32;
    var halfLen: f32;
    var x0_: f32;
    var x1_: f32;
    var d_2: f32;
    var local_14: f32;
    var local_15: f32;
    var xs: f32;
    var local_16: f32;
    var side: f32;
    var edgeX: f32;
    var local_17: vec2<f32>;
    var eB: vec2<f32>;
    var sB: vec2<f32>;
    var eU: vec2<f32>;
    var j0_: f32;
    var dj: i32 = -1i;
    var kk_2: f32;
    var vk_1: f32;
    var yk_1: f32;
    var labelW: f32;
    var local_18: f32;
    var halfX: f32;
    var local_19: f32;
    var halfY: f32;
    var c_1: vec2<f32>;
    var rel0_: vec2<f32>;
    var rel_2: vec2<f32>;
    var dStroke: f32;
    var local_20: f32;
    var covMinor: f32;
    var local_21: f32;
    var covMajor: f32;
    var local_22: f32;
    var covSpine: f32;
    var covDigit: f32;
    var cov: f32;
    var local_23: f32;
    var dmin: f32;
    var local_24: f32;
    var g: f32;
    var outc: vec4<f32>;

    uv_2 = uv_1;
    outPos_1 = outPos;
    elements_1 = elements;
    justify_1 = justify;
    numbers_1 = numbers;
    size_1 = size;
    numberSize_1 = numberSize;
    color1_1 = color1_;
    value_5 = value_4;
    range_1 = range;
    glow_1 = glow;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    outDim_1 = outDim;
    let _e34 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e34);
    let _e37 = im;
    let _e38 = uv_2;
    let _e39 = tf(_e37, _e38);
    u_4 = _e39;
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
    let _e71 = u_4;
    aa = (length((_e70 - _e71)) * 0.75f);
    let _e77 = elements_1;
    showMajors = ((_e77 & 1i) != 0i);
    let _e83 = elements_1;
    showSpine = ((_e83 & 2i) != 0i);
    let _e93 = modelTransform_1[0][0];
    let _e98 = modelTransform_1[0][1];
    modelScale = length(vec2<f32>(_e93, _e98));
    let _e102 = modelScale;
    if (_e102 < 0.00001f) {
        modelScale = 0.00001f;
    }
    let _e107 = modelScale;
    vb = (1f / _e107);
    let _e110 = thickness_1;
    let _e113 = vb;
    minorHalf = ((_e110 * 0.0075f) * _e113);
    let _e116 = minorHalf;
    majorHalf = (_e116 * 1.5f);
    let _e121 = vb;
    digitHalf = (0.003f * _e121);
    let _e125 = vb;
    let _e127 = numberSize_1;
    gscale_2 = ((0.042f * _e125) * _e127);
    let _e133 = vb;
    let _e135 = numberSize_1;
    gap = ((0.012f * _e133) * _e135);
    let _e139 = vb;
    let _e141 = size_1;
    tickMinor = ((0.05f * _e139) * _e141);
    let _e145 = vb;
    let _e147 = size_1;
    tickMajor = ((0.075f * _e145) * _e147);
    let _e150 = showMajors;
    if _e150 {
        let _e151 = tickMajor;
        local_7 = _e151;
    } else {
        let _e152 = tickMinor;
        local_7 = _e152;
    }
    let _e154 = local_7;
    edgeRef = _e154;
    let _e156 = glow_1;
    if (_e156 > 0.006f) {
        let _e159 = glow_1;
        local_8 = min((log((_e159 / 0.006f)) * 0.125f), 1f);
    } else {
        local_8 = 0f;
    }
    let _e169 = local_8;
    glowReach = _e169;
    let _e171 = range_1;
    if (_e171 < 0.0001f) {
        range_1 = 0.0001f;
    }
    let _e177 = range_1;
    dataToU = (-2f / _e177);
    let _e180 = dataToU;
    let _e182 = modelScale;
    unitV = (abs(_e180) * _e182);
    let _e185 = numbers_1;
    if (_e185 == 2i) {
        let _e189 = numberSize_1;
        local_9 = max((0.2f * _e189), 0.05f);
    } else {
        let _e194 = numberSize_1;
        local_9 = max((0.1f * _e194), 0.03f);
    }
    let _e199 = local_9;
    minLabelV = _e199;
    let _e201 = minLabelV;
    let _e202 = unitV;
    raw = (_e201 / max(_e202, 0.000001f));
    let _e208 = raw;
    b_3 = pow(10f, floor((log(max(_e208, 0.000000001f)) / 2.3025851f)));
    let _e218 = raw;
    let _e219 = b_3;
    m_3 = (_e218 / _e219);
    let _e222 = m_3;
    if (_e222 <= 1f) {
        local_12 = 1f;
    } else {
        let _e226 = m_3;
        if (_e226 <= 2f) {
            local_11 = 2f;
        } else {
            let _e230 = m_3;
            if (_e230 <= 5f) {
                local_10 = 5f;
            } else {
                local_10 = 10f;
            }
            let _e236 = local_10;
            local_11 = _e236;
        }
        let _e238 = local_11;
        local_12 = _e238;
    }
    let _e240 = local_12;
    let _e241 = b_3;
    L = (_e240 * _e241);
    let _e244 = L;
    minorL = (_e244 / 5f);
    let _e248 = L;
    decimals_6 = i32(clamp(ceil((-(log(_e248)) / 2.3025851f)), 0f, 3f));
    let _e260 = value_5;
    let _e261 = u_4;
    let _e263 = dataToU;
    vv = (_e260 + (_e261.y / _e263));
    let _e275 = vv;
    let _e276 = minorL;
    k0_ = floor(((_e275 / _e276) + 0.5f));
    loop {
        let _e285 = dk;
        if !((_e285 <= 2i)) {
            break;
        }
        {
            let _e292 = k0_;
            let _e293 = dk;
            kk_1 = (_e292 + f32(_e293));
            let _e297 = kk_1;
            let _e298 = minorL;
            vk = (_e297 * _e298);
            let _e301 = vk;
            let _e302 = value_5;
            let _e304 = dataToU;
            yk = ((_e301 - _e302) * _e304);
            let _e307 = yk;
            if (abs(_e307) > 1f) {
                continue;
            }
            let _e311 = showMajors;
            let _e312 = kk_1;
            let _e313 = abs(_e312);
            isMaj = (_e311 && ((_e313 - (floor((_e313 / 5f)) * 5f)) < 0.5f));
            let _e323 = isMaj;
            if _e323 {
                let _e324 = tickMajor;
                local_13 = _e324;
            } else {
                let _e325 = tickMinor;
                local_13 = _e325;
            }
            let _e327 = local_13;
            halfLen = _e327;
            let _e331 = justify_1;
            if (_e331 == 1i) {
                {
                    let _e334 = edgeRef;
                    x0_ = -(_e334);
                    let _e336 = x0_;
                    let _e338 = halfLen;
                    x1_ = (_e336 + (2f * _e338));
                }
            } else {
                let _e341 = justify_1;
                if (_e341 == 2i) {
                    {
                        let _e344 = edgeRef;
                        x1_ = _e344;
                        let _e345 = x1_;
                        let _e347 = halfLen;
                        x0_ = (_e345 - (2f * _e347));
                    }
                } else {
                    {
                        let _e350 = halfLen;
                        x0_ = -(_e350);
                        let _e352 = halfLen;
                        x1_ = _e352;
                    }
                }
            }
            let _e353 = u_4;
            let _e354 = x0_;
            let _e355 = yk;
            let _e357 = x1_;
            let _e358 = yk;
            let _e360 = sdSegment(_e353, vec2<f32>(_e354, _e355), vec2<f32>(_e357, _e358));
            d_2 = _e360;
            let _e362 = isMaj;
            if _e362 {
                let _e363 = dMajor;
                let _e364 = d_2;
                dMajor = min(_e363, _e364);
            } else {
                let _e366 = dMinor;
                let _e367 = d_2;
                dMinor = min(_e366, _e367);
            }
        }
        continuing {
            let _e289 = dk;
            dk = (_e289 + 1i);
        }
    }
    let _e369 = showSpine;
    if _e369 {
        {
            let _e370 = justify_1;
            if (_e370 == 1i) {
                let _e373 = edgeRef;
                local_15 = -(_e373);
            } else {
                let _e375 = justify_1;
                if (_e375 == 2i) {
                    let _e378 = edgeRef;
                    local_14 = _e378;
                } else {
                    local_14 = 0f;
                }
                let _e381 = local_14;
                local_15 = _e381;
            }
            let _e383 = local_15;
            xs = _e383;
            let _e385 = u_4;
            let _e386 = xs;
            let _e390 = xs;
            let _e393 = sdSegment(_e385, vec2<f32>(_e386, -1f), vec2<f32>(_e390, 1f));
            dSpine = _e393;
        }
    }
    let _e394 = numbers_1;
    if (_e394 >= 1i) {
        {
            let _e397 = justify_1;
            if (_e397 == 2i) {
                local_16 = 1f;
            } else {
                local_16 = -1f;
            }
            let _e404 = local_16;
            side = _e404;
            let _e406 = side;
            let _e407 = edgeRef;
            edgeX = (_e406 * _e407);
            let _e410 = numbers_1;
            if (_e410 == 2i) {
                local_17 = vec2<f32>(0f, 1f);
            } else {
                local_17 = vec2<f32>(1f, 0f);
            }
            let _e420 = local_17;
            eB = _e420;
            let _e422 = modelTransform_1;
            let _e423 = eB;
            sB = normalize((_e422 * vec3<f32>(_e423.x, _e423.y, 0f)).xy);
            let _e432 = sB;
            let _e437 = sB;
            let _e442 = sB;
            if ((_e432.x < -0.001f) || ((abs(_e437.x) <= 0.001f) && (_e442.y > 0f))) {
                let _e448 = eB;
                eB = -(_e448);
            }
            let _e450 = eB;
            let _e453 = eB;
            eU = vec2<f32>(-(_e450.y), _e453.x);
            let _e457 = vv;
            let _e458 = L;
            j0_ = floor(((_e457 / _e458) + 0.5f));
            loop {
                let _e467 = dj;
                if !((_e467 <= 1i)) {
                    break;
                }
                {
                    let _e474 = j0_;
                    let _e475 = dj;
                    kk_2 = (_e474 + f32(_e475));
                    let _e479 = kk_2;
                    let _e480 = L;
                    vk_1 = (_e479 * _e480);
                    let _e483 = vk_1;
                    let _e484 = value_5;
                    let _e486 = dataToU;
                    yk_1 = ((_e483 - _e484) * _e486);
                    let _e489 = yk_1;
                    if (abs(_e489) > 1f) {
                        continue;
                    }
                    let _e493 = vk_1;
                    let _e494 = decimals_6;
                    let _e495 = rulerNumGlyphs(_e493, _e494);
                    let _e497 = gadv_1;
                    let _e499 = gscale_2;
                    labelW = ((f32(_e495) * _e497) * _e499);
                    let _e502 = numbers_1;
                    if (_e502 == 2i) {
                        let _e506 = gscale_2;
                        local_18 = (0.75f * _e506);
                    } else {
                        let _e508 = labelW;
                        local_18 = (_e508 * 0.5f);
                    }
                    let _e512 = local_18;
                    halfX = _e512;
                    let _e514 = numbers_1;
                    if (_e514 == 2i) {
                        let _e517 = labelW;
                        local_19 = (_e517 * 0.5f);
                    } else {
                        let _e521 = gscale_2;
                        local_19 = (0.75f * _e521);
                    }
                    let _e524 = local_19;
                    halfY = _e524;
                    let _e526 = edgeX;
                    let _e527 = side;
                    let _e528 = gap;
                    let _e529 = halfX;
                    let _e533 = yk_1;
                    c_1 = vec2<f32>((_e526 + (_e527 * (_e528 + _e529))), _e533);
                    let _e536 = u_4;
                    let _e537 = c_1;
                    rel0_ = (_e536 - _e537);
                    let _e540 = rel0_;
                    let _e543 = halfX;
                    let _e544 = glowReach;
                    if (abs(_e540.x) > (_e543 + _e544)) {
                        continue;
                    }
                    let _e547 = rel0_;
                    let _e550 = halfY;
                    let _e551 = glowReach;
                    if (abs(_e547.y) > (_e550 + _e551)) {
                        continue;
                    }
                    let _e554 = rel0_;
                    let _e555 = eB;
                    let _e557 = rel0_;
                    let _e558 = eU;
                    rel_2 = vec2<f32>(dot(_e554, _e555), dot(_e557, _e558));
                    let _e562 = dDigit;
                    let _e563 = rel_2;
                    let _e564 = vk_1;
                    let _e565 = decimals_6;
                    let _e566 = gscale_2;
                    let _e567 = rulerNumDist(_e563, _e564, _e565, _e566);
                    dDigit = min(_e562, _e567);
                }
                continuing {
                    let _e471 = dj;
                    dj = (_e471 + 1i);
                }
            }
        }
    }
    let _e569 = dMinor;
    let _e570 = dMajor;
    let _e572 = dSpine;
    dStroke = min(min(_e569, _e570), _e572);
    let _e575 = minorHalf;
    if (_e575 <= 0f) {
        local_20 = 0f;
    } else {
        let _e580 = minorHalf;
        let _e581 = aa;
        let _e583 = minorHalf;
        let _e584 = aa;
        let _e586 = dMinor;
        local_20 = (1f - smoothstep((_e580 - _e581), (_e583 + _e584), _e586));
    }
    let _e590 = local_20;
    covMinor = _e590;
    let _e592 = majorHalf;
    if (_e592 <= 0f) {
        local_21 = 0f;
    } else {
        let _e597 = majorHalf;
        let _e598 = aa;
        let _e600 = majorHalf;
        let _e601 = aa;
        let _e603 = dMajor;
        local_21 = (1f - smoothstep((_e597 - _e598), (_e600 + _e601), _e603));
    }
    let _e607 = local_21;
    covMajor = _e607;
    let _e609 = majorHalf;
    if (_e609 <= 0f) {
        local_22 = 0f;
    } else {
        let _e614 = majorHalf;
        let _e615 = aa;
        let _e617 = majorHalf;
        let _e618 = aa;
        let _e620 = dSpine;
        local_22 = (1f - smoothstep((_e614 - _e615), (_e617 + _e618), _e620));
    }
    let _e624 = local_22;
    covSpine = _e624;
    let _e627 = digitHalf;
    let _e628 = aa;
    let _e630 = digitHalf;
    let _e631 = aa;
    let _e633 = dDigit;
    covDigit = (1f - smoothstep((_e627 - _e628), (_e630 + _e631), _e633));
    let _e637 = covMinor;
    let _e638 = covMajor;
    let _e640 = covSpine;
    let _e641 = covDigit;
    cov = max(max(_e637, _e638), max(_e640, _e641));
    let _e645 = minorHalf;
    if (_e645 <= 0f) {
        let _e648 = dDigit;
        local_23 = _e648;
    } else {
        let _e649 = dStroke;
        let _e650 = dDigit;
        local_23 = min(_e649, _e650);
    }
    let _e653 = local_23;
    dmin = _e653;
    let _e655 = glow_1;
    if (_e655 > 0f) {
        let _e658 = glow_1;
        let _e659 = dmin;
        let _e660 = majorHalf;
        let _e661 = digitHalf;
        let _e672 = cov;
        local_24 = ((_e658 * exp((-(max((_e659 - max(_e660, _e661)), 0f)) * 8f))) * (1f - _e672));
    } else {
        local_24 = 0f;
    }
    let _e677 = local_24;
    g = _e677;
    let _e679 = cov;
    let _e682 = g;
    if ((_e679 <= 0f) && (_e682 <= 0.002f)) {
        let _e686 = bkg_2;
        return _e686;
    }
    let _e687 = bkg_2;
    let _e688 = color1_1;
    let _e689 = _e688.xyz;
    let _e690 = color1_1;
    let _e692 = cov;
    let _e698 = mergeColor(_e687, vec4<f32>(_e689.x, _e689.y, _e689.z, (_e690.w * _e692)));
    outc = _e698;
    let _e700 = outc;
    let _e702 = outc;
    let _e704 = color1_1;
    let _e706 = g;
    let _e708 = (_e702.xyz + (_e704.xyz * _e706));
    outc.x = _e708.x;
    outc.y = _e708.y;
    outc.z = _e708.z;
    let _e716 = outc;
    let _e718 = g;
    outc.w = max(_e716.w, min(_e718, 1f));
    let _e722 = outc;
    return _e722;
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
    let _e81 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e100 = global.U[13];
    let _e104 = global.U[14];
    let _e108 = global.U[15];
    let _e109 = _e108.xyz;
    let _e112 = global.U[16];
    let _e113 = _e112.xyz;
    let _e116 = global.U[17];
    let _e117 = _e116.xyz;
    let _e133 = global.U[4];
    let _e135 = ruler((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), i32(_e76.x), _e81.x, _e85.x, _e89, _e92.x, _e96.x, _e100.x, _e104.x, mat3x3<f32>(vec3<f32>(_e109.x, _e109.y, _e109.z), vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z)), _e133.xy);
    fragColor = _e135;
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
