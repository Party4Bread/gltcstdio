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

fn ndfDigital(ch_4: i32, p_3: vec2<f32>) -> f32 {
    var ch_5: i32;
    var p_4: vec2<f32>;
    var m_1: i32;
    var X: f32 = 0.24f;
    var Yt: f32 = 0.66f;
    var Ym: f32 = 0f;
    var Yb: f32 = -0.66f;
    var d_2: f32 = 1000000000f;

    ch_5 = ch_4;
    p_4 = p_3;
    let _e10 = ch_5;
    if (_e10 == 10i) {
        let _e13 = p_4;
        return length((_e13 - vec2<f32>(0f, -0.66f)));
    }
    let _e20 = ch_5;
    let _e21 = ndfSevenSeg(_e20);
    m_1 = _e21;
    let _e34 = m_1;
    if ((_e34 & 1i) != 0i) {
        let _e39 = d_2;
        let _e40 = p_4;
        let _e41 = X;
        let _e43 = Yt;
        let _e45 = X;
        let _e46 = Yt;
        let _e48 = sdSegment(_e40, vec2<f32>(-(_e41), _e43), vec2<f32>(_e45, _e46));
        d_2 = min(_e39, _e48);
    }
    let _e50 = m_1;
    if ((_e50 & 2i) != 0i) {
        let _e55 = d_2;
        let _e56 = p_4;
        let _e57 = X;
        let _e58 = Ym;
        let _e60 = X;
        let _e61 = Yt;
        let _e63 = sdSegment(_e56, vec2<f32>(_e57, _e58), vec2<f32>(_e60, _e61));
        d_2 = min(_e55, _e63);
    }
    let _e65 = m_1;
    if ((_e65 & 4i) != 0i) {
        let _e70 = d_2;
        let _e71 = p_4;
        let _e72 = X;
        let _e73 = Yb;
        let _e75 = X;
        let _e76 = Ym;
        let _e78 = sdSegment(_e71, vec2<f32>(_e72, _e73), vec2<f32>(_e75, _e76));
        d_2 = min(_e70, _e78);
    }
    let _e80 = m_1;
    if ((_e80 & 8i) != 0i) {
        let _e85 = d_2;
        let _e86 = p_4;
        let _e87 = X;
        let _e89 = Yb;
        let _e91 = X;
        let _e92 = Yb;
        let _e94 = sdSegment(_e86, vec2<f32>(-(_e87), _e89), vec2<f32>(_e91, _e92));
        d_2 = min(_e85, _e94);
    }
    let _e96 = m_1;
    if ((_e96 & 16i) != 0i) {
        let _e101 = d_2;
        let _e102 = p_4;
        let _e103 = X;
        let _e105 = Yb;
        let _e107 = X;
        let _e109 = Ym;
        let _e111 = sdSegment(_e102, vec2<f32>(-(_e103), _e105), vec2<f32>(-(_e107), _e109));
        d_2 = min(_e101, _e111);
    }
    let _e113 = m_1;
    if ((_e113 & 32i) != 0i) {
        let _e118 = d_2;
        let _e119 = p_4;
        let _e120 = X;
        let _e122 = Ym;
        let _e124 = X;
        let _e126 = Yt;
        let _e128 = sdSegment(_e119, vec2<f32>(-(_e120), _e122), vec2<f32>(-(_e124), _e126));
        d_2 = min(_e118, _e128);
    }
    let _e130 = m_1;
    if ((_e130 & 64i) != 0i) {
        let _e135 = d_2;
        let _e136 = p_4;
        let _e137 = X;
        let _e139 = Ym;
        let _e141 = X;
        let _e142 = Ym;
        let _e144 = sdSegment(_e136, vec2<f32>(-(_e137), _e139), vec2<f32>(_e141, _e142));
        d_2 = min(_e135, _e144);
    }
    let _e146 = d_2;
    return _e146;
}

fn tf(m_2: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_3: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_3 = m_2;
    u_3 = u_2;
    let _e10 = m_3;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn numberFont(uv_1: vec2<f32>, outPos: vec2<f32>, mode: i32, value: f32, decimals_2: i32, color1_: vec4<f32>, thickness: f32, modelTransform: mat3x3<f32>, outDim: vec2<f32>, glow: f32) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var value_1: f32;
    var decimals_3: i32;
    var color1_1: vec4<f32>;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var glow_1: f32;
    var im: mat3x3<f32>;
    var u_4: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var aa: f32;
    var neg_2: bool;
    var av_2: f32;
    var ipart_2: f32;
    var nint_2: i32 = 1i;
    var t2_: f32;
    var i: i32 = 0i;
    var local_1: i32;
    var local_2: i32;
    var nglyph: i32;
    var adv: f32 = 0.88f;
    var total: f32;
    var left: f32;
    var fx: f32;
    var slot_2: i32;
    var halfW: f32;
    var d_3: f32 = 1000000000f;
    var gsum: f32 = 0f;
    var s: i32;
    var sch: i32;
    var sp: vec2<f32>;
    var local_3: f32;
    var sd: f32;
    var cov: f32;
    var g: f32;
    var outc: vec4<f32>;

    uv_2 = uv_1;
    outPos_1 = outPos;
    mode_1 = mode;
    value_1 = value;
    decimals_3 = decimals_2;
    color1_1 = color1_;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    outDim_1 = outDim;
    glow_1 = glow;
    let _e26 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e26);
    let _e29 = im;
    let _e30 = uv_2;
    let _e31 = tf(_e29, _e30);
    u_4 = _e31;
    let _e33 = uv_2;
    let _e37 = global.U[0];
    let _e40 = uv_2;
    let _e49 = textureSample(t_source, samp, ((vec2<f32>((_e33.x / _e37.x), _e40.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e49;
    let _e52 = outDim_1;
    pixel = (2f / _e52.y);
    let _e56 = im;
    let _e57 = uv_2;
    let _e58 = pixel;
    let _e62 = tf(_e56, (_e57 + vec2<f32>(_e58, 0f)));
    let _e63 = u_4;
    aa = (length((_e62 - _e63)) * 0.75f);
    let _e69 = value_1;
    neg_2 = (_e69 < 0f);
    let _e73 = value_1;
    av_2 = abs(_e73);
    let _e76 = av_2;
    ipart_2 = floor(_e76);
    let _e81 = ipart_2;
    t2_ = _e81;
    loop {
        let _e85 = i;
        if !((_e85 < 9i)) {
            break;
        }
        {
            let _e92 = t2_;
            if (_e92 >= 10f) {
                {
                    let _e95 = t2_;
                    t2_ = floor((_e95 / 10f));
                    let _e99 = nint_2;
                    nint_2 = (_e99 + 1i);
                }
            }
        }
        continuing {
            let _e89 = i;
            i = (_e89 + 1i);
        }
    }
    let _e102 = nint_2;
    let _e103 = neg_2;
    if _e103 {
        local_1 = 1i;
    } else {
        local_1 = 0i;
    }
    let _e107 = local_1;
    let _e109 = decimals_3;
    if (_e109 > 0i) {
        let _e113 = decimals_3;
        local_2 = (1i + _e113);
    } else {
        local_2 = 0i;
    }
    let _e117 = local_2;
    nglyph = ((_e102 + _e107) + _e117);
    let _e122 = nglyph;
    let _e124 = adv;
    total = (f32(_e122) * _e124);
    let _e127 = total;
    left = (-(_e127) * 0.5f);
    let _e132 = u_4;
    let _e134 = left;
    fx = (_e132.x - _e134);
    let _e137 = fx;
    let _e138 = adv;
    slot_2 = i32(floor((_e137 / _e138)));
    let _e144 = thickness_1;
    halfW = (0.03f + (_e144 * 0.2f));
    let _e153 = slot_2;
    s = (_e153 - 1i);
    loop {
        let _e157 = s;
        let _e158 = slot_2;
        if !((_e157 <= (_e158 + 1i))) {
            break;
        }
        {
            let _e166 = s;
            let _e169 = s;
            let _e170 = nglyph;
            if ((_e166 < 0i) || (_e169 >= _e170)) {
                continue;
            }
            let _e173 = s;
            let _e174 = nint_2;
            let _e175 = neg_2;
            let _e176 = decimals_3;
            let _e177 = ipart_2;
            let _e178 = av_2;
            let _e179 = ndfCharForSlot(_e173, _e174, _e175, _e176, _e177, _e178);
            sch = _e179;
            let _e181 = sch;
            if (_e181 == 12i) {
                continue;
            }
            let _e184 = fx;
            let _e185 = s;
            let _e189 = adv;
            let _e192 = u_4;
            sp = vec2<f32>((_e184 - ((f32(_e185) + 0.5f) * _e189)), -(_e192.y));
            let _e197 = mode_1;
            if (_e197 == 0i) {
                let _e200 = sch;
                let _e201 = sp;
                let _e202 = ndfDigital(_e200, _e201);
                local_3 = _e202;
            } else {
                let _e203 = sch;
                let _e204 = sp;
                let _e205 = ndfCurved(_e203, _e204);
                local_3 = _e205;
            }
            let _e207 = local_3;
            sd = _e207;
            let _e209 = d_3;
            let _e210 = sd;
            d_3 = min(_e209, _e210);
            let _e212 = gsum;
            let _e213 = sd;
            let _e214 = halfW;
            gsum = (_e212 + exp((-(max((_e213 - _e214), 0f)) * 6f)));
        }
        continuing {
            let _e163 = s;
            s = (_e163 + 1i);
        }
    }
    let _e224 = halfW;
    let _e225 = aa;
    let _e227 = halfW;
    let _e228 = aa;
    let _e230 = d_3;
    cov = (1f - smoothstep((_e224 - _e225), (_e227 + _e228), _e230));
    let _e234 = glow_1;
    let _e235 = gsum;
    let _e238 = cov;
    g = ((_e234 * _e235) * (1f - _e238));
    let _e242 = cov;
    let _e245 = g;
    if ((_e242 <= 0f) && (_e245 <= 0.002f)) {
        let _e249 = bkg_2;
        return _e249;
    }
    let _e250 = bkg_2;
    let _e251 = color1_1;
    let _e252 = _e251.xyz;
    let _e253 = color1_1;
    let _e255 = cov;
    let _e261 = mergeColor(_e250, vec4<f32>(_e252.x, _e252.y, _e252.z, (_e253.w * _e255)));
    outc = _e261;
    let _e263 = outc;
    let _e265 = outc;
    let _e267 = color1_1;
    let _e269 = g;
    let _e271 = (_e265.xyz + (_e267.xyz * _e269));
    outc.x = _e271.x;
    outc.y = _e271.y;
    outc.z = _e271.z;
    let _e279 = outc;
    let _e281 = g;
    outc.w = max(_e279.w, min(_e281, 1f));
    let _e285 = outc;
    return _e285;
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
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e112 = global.U[4];
    let _e116 = global.U[13];
    let _e118 = numberFont((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, i32(_e75.x), _e80, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)), _e112.xy, _e116.x);
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
