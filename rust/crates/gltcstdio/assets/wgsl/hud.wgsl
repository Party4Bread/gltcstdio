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

fn sdSegment(u: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_1 = u;
    a_1 = a;
    b_1 = b;
    let _e12 = u_1;
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

fn hudLadderBar(qa: vec2<f32>, v: f32, gap: f32, W: f32, tick: f32) -> f32 {
    var qa_1: vec2<f32>;
    var v_1: f32;
    var gap_1: f32;
    var W_1: f32;
    var tick_1: f32;
    var d: f32 = 1000000000f;
    var dashP: f32 = 0.085f;
    var dashOn: f32 = 0.05f;
    var idx: f32;
    var di: i32 = 0i;
    var ii: f32;
    var s0_: f32;

    qa_1 = qa;
    v_1 = v;
    gap_1 = gap;
    W_1 = W;
    tick_1 = tick;
    let _e18 = v_1;
    if (_e18 > 0.5f) {
        {
            let _e21 = qa_1;
            let _e22 = gap_1;
            let _e25 = W_1;
            let _e28 = sdSegment(_e21, vec2<f32>(_e22, 0f), vec2<f32>(_e25, 0f));
            d = _e28;
            let _e29 = d;
            let _e30 = qa_1;
            let _e31 = W_1;
            let _e34 = W_1;
            let _e35 = tick_1;
            let _e37 = sdSegment(_e30, vec2<f32>(_e31, 0f), vec2<f32>(_e34, _e35));
            d = min(_e29, _e37);
        }
    } else {
        let _e39 = v_1;
        if (_e39 < -0.5f) {
            {
                let _e47 = qa_1;
                let _e49 = gap_1;
                let _e51 = dashP;
                idx = floor(((_e47.x - _e49) / _e51));
                loop {
                    let _e57 = di;
                    if !((_e57 < 2i)) {
                        break;
                    }
                    {
                        let _e64 = idx;
                        let _e65 = di;
                        ii = max((_e64 - f32(_e65)), 0f);
                        let _e71 = gap_1;
                        let _e72 = ii;
                        let _e73 = dashP;
                        s0_ = (_e71 + (_e72 * _e73));
                        let _e77 = s0_;
                        let _e78 = W_1;
                        if (_e77 < _e78) {
                            let _e80 = d;
                            let _e81 = qa_1;
                            let _e82 = s0_;
                            let _e85 = s0_;
                            let _e86 = dashOn;
                            let _e88 = W_1;
                            let _e92 = sdSegment(_e81, vec2<f32>(_e82, 0f), vec2<f32>(min((_e85 + _e86), _e88), 0f));
                            d = min(_e80, _e92);
                        }
                    }
                    continuing {
                        let _e61 = di;
                        di = (_e61 + 1i);
                    }
                }
                let _e94 = d;
                let _e95 = qa_1;
                let _e96 = W_1;
                let _e99 = W_1;
                let _e100 = tick_1;
                let _e103 = sdSegment(_e95, vec2<f32>(_e96, 0f), vec2<f32>(_e99, -(_e100)));
                d = min(_e94, _e103);
            }
        } else {
            {
                let _e105 = qa_1;
                let _e106 = gap_1;
                let _e109 = W_1;
                let _e112 = sdSegment(_e105, vec2<f32>(_e106, 0f), vec2<f32>(_e109, 0f));
                d = _e112;
            }
        }
    }
    let _e113 = d;
    return _e113;
}

fn ndfCharForSlot(slot: i32, nint: i32, neg: bool, decimals: i32, ipart: f32, av: f32) -> i32 {
    var slot_1: i32;
    var nint_1: i32;
    var neg_1: bool;
    var decimals_1: i32;
    var ipart_1: f32;
    var av_1: f32;
    var local: i32;
    var idx_1: i32;
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
    idx_1 = (_e28 - _e33);
    let _e36 = idx_1;
    if (_e36 < 0i) {
        return 12i;
    }
    let _e40 = idx_1;
    let _e41 = nint_1;
    if (_e40 < _e41) {
        {
            let _e43 = nint_1;
            let _e46 = idx_1;
            posFromRight = ((_e43 - 1i) - _e46);
            let _e49 = ipart_1;
            let _e51 = posFromRight;
            dv = floor((_e49 / pow(10f, f32(_e51))));
            let _e57 = dv;
            return i32((_e57 - (floor((_e57 / 10f)) * 10f)));
        }
    } else {
        let _e64 = decimals_1;
        let _e67 = idx_1;
        let _e68 = nint_1;
        if ((_e64 > 0i) && (_e67 == _e68)) {
            {
                return 10i;
            }
        } else {
            {
                let _e72 = idx_1;
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
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var c: vec2<f32>;
    var d_1: vec2<f32>;
    var bb: f32;
    var kk: f32;
    var kx: f32;
    var ky: f32;
    var kz: f32;
    var res: f32 = 0f;
    var p: f32;
    var p3_: f32;
    var q: f32;
    var h_1: f32;
    var x: vec2<f32>;
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
    a_2 = (_e14 - _e15);
    let _e18 = A_1;
    let _e20 = B_1;
    let _e23 = C_1;
    b_2 = ((_e18 - (2f * _e20)) + _e23);
    let _e26 = a_2;
    c = (_e26 * 2f);
    let _e30 = A_1;
    let _e31 = pos_1;
    d_1 = (_e30 - _e31);
    let _e34 = b_2;
    let _e35 = b_2;
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
    let _e73 = a_2;
    let _e74 = b_2;
    kx = (_e72 * dot(_e73, _e74));
    let _e78 = kk;
    let _e80 = a_2;
    let _e81 = a_2;
    let _e84 = d_1;
    let _e85 = b_2;
    ky = ((_e78 * ((2f * dot(_e80, _e81)) + dot(_e84, _e85))) / 3f);
    let _e92 = kk;
    let _e93 = d_1;
    let _e94 = a_2;
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
    h_1 = ((_e126 * _e127) + (4f * _e130));
    let _e134 = h_1;
    if (_e134 >= 0f) {
        {
            let _e137 = h_1;
            h_1 = sqrt(_e137);
            let _e139 = h_1;
            let _e140 = h_1;
            let _e143 = q;
            x = ((vec2<f32>(_e139, -(_e140)) - vec2(_e143)) / vec2(2f));
            let _e150 = x;
            let _e152 = x;
            uv = (sign(_e150) * pow(abs(_e152), vec2(0.33333334f)));
            let _e161 = uv;
            let _e163 = uv;
            let _e166 = kx;
            t = clamp(((_e161.x + _e163.y) - _e166), 0f, 1f);
            let _e172 = d_1;
            let _e173 = c;
            let _e174 = b_2;
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
            let _e234 = d_1;
            let _e235 = c;
            let _e236 = b_2;
            let _e237 = t_1;
            let _e241 = t_1;
            d1_ = (_e234 + ((_e235 + (_e236 * _e237.x)) * _e241.x));
            let _e246 = d_1;
            let _e247 = c;
            let _e248 = b_2;
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

fn ndfCurved(ch: i32, p_1: vec2<f32>) -> f32 {
    var ch_1: i32;
    var p_2: vec2<f32>;
    var ym: f32 = 0f;
    var yt: f32 = 0.7f;
    var yb: f32 = -0.7f;
    var d_2: f32 = 1000000000f;

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
            let _e44 = d_2;
            let _e45 = p_2;
            let _e47 = yt;
            let _e50 = yt;
            let _e53 = ym;
            let _e55 = ndfSdBezier(_e45, vec2<f32>(0f, _e47), vec2<f32>(0.25f, _e50), vec2<f32>(0.25f, _e53));
            d_2 = min(_e44, _e55);
            let _e57 = d_2;
            let _e58 = p_2;
            let _e60 = ym;
            let _e63 = yb;
            let _e66 = yb;
            let _e68 = ndfSdBezier(_e58, vec2<f32>(0.25f, _e60), vec2<f32>(0.25f, _e63), vec2<f32>(0f, _e66));
            d_2 = min(_e57, _e68);
            let _e70 = d_2;
            let _e71 = p_2;
            let _e73 = yb;
            let _e77 = yb;
            let _e81 = ym;
            let _e83 = ndfSdBezier(_e71, vec2<f32>(0f, _e73), vec2<f32>(-0.25f, _e77), vec2<f32>(-0.25f, _e81));
            d_2 = min(_e70, _e83);
            let _e85 = d_2;
            let _e86 = p_2;
            let _e89 = ym;
            let _e93 = yt;
            let _e96 = yt;
            let _e98 = ndfSdBezier(_e86, vec2<f32>(-0.25f, _e89), vec2<f32>(-0.25f, _e93), vec2<f32>(0f, _e96));
            d_2 = min(_e85, _e98);
        }
    } else {
        let _e100 = ch_1;
        if (_e100 == 1i) {
            {
                let _e103 = d_2;
                let _e104 = p_2;
                let _e106 = yt;
                let _e109 = yb;
                let _e111 = sdSegment(_e104, vec2<f32>(0.03f, _e106), vec2<f32>(0.03f, _e109));
                d_2 = min(_e103, _e111);
                let _e113 = d_2;
                let _e114 = p_2;
                let _e120 = yt;
                let _e122 = sdSegment(_e114, vec2<f32>(-0.16f, 0.5f), vec2<f32>(0.03f, _e120));
                d_2 = min(_e113, _e122);
                let _e124 = d_2;
                let _e125 = p_2;
                let _e128 = yb;
                let _e131 = yb;
                let _e133 = sdSegment(_e125, vec2<f32>(-0.13f, _e128), vec2<f32>(0.19f, _e131));
                d_2 = min(_e124, _e133);
            }
        } else {
            let _e135 = ch_1;
            if (_e135 == 2i) {
                {
                    let _e138 = d_2;
                    let _e139 = p_2;
                    let _e146 = yt;
                    let _e149 = yt;
                    let _e151 = ndfSdBezier(_e139, vec2<f32>(-0.24f, 0.36f), vec2<f32>(-0.24f, _e146), vec2<f32>(0.04f, _e149));
                    d_2 = min(_e138, _e151);
                    let _e153 = d_2;
                    let _e154 = p_2;
                    let _e156 = yt;
                    let _e159 = yt;
                    let _e164 = ndfSdBezier(_e154, vec2<f32>(0.04f, _e156), vec2<f32>(0.3f, _e159), vec2<f32>(0.3f, 0.34f));
                    d_2 = min(_e153, _e164);
                    let _e166 = d_2;
                    let _e167 = p_2;
                    let _e178 = ndfSdBezier(_e167, vec2<f32>(0.3f, 0.34f), vec2<f32>(0.3f, 0.25f), vec2<f32>(0.07f, -0.14f));
                    d_2 = min(_e166, _e178);
                    let _e180 = d_2;
                    let _e181 = p_2;
                    let _e188 = yb;
                    let _e190 = sdSegment(_e181, vec2<f32>(0.07f, -0.14f), vec2<f32>(-0.25f, _e188));
                    d_2 = min(_e180, _e190);
                    let _e192 = d_2;
                    let _e193 = p_2;
                    let _e196 = yb;
                    let _e199 = yb;
                    let _e201 = sdSegment(_e193, vec2<f32>(-0.25f, _e196), vec2<f32>(0.3f, _e199));
                    d_2 = min(_e192, _e201);
                }
            } else {
                let _e203 = ch_1;
                if (_e203 == 3i) {
                    {
                        let _e206 = d_2;
                        let _e207 = p_2;
                        let _e218 = ndfSdBezier(_e207, vec2<f32>(-0.14f, 0.56f), vec2<f32>(0.14f, 0.84f), vec2<f32>(0.28f, 0.44f));
                        d_2 = min(_e206, _e218);
                        let _e220 = d_2;
                        let _e221 = p_2;
                        let _e230 = ym;
                        let _e232 = ndfSdBezier(_e221, vec2<f32>(0.28f, 0.44f), vec2<f32>(0.3f, 0.06f), vec2<f32>(-0.04f, _e230));
                        d_2 = min(_e220, _e232);
                        let _e234 = d_2;
                        let _e235 = p_2;
                        let _e238 = ym;
                        let _e248 = ndfSdBezier(_e235, vec2<f32>(-0.04f, _e238), vec2<f32>(0.3f, -0.06f), vec2<f32>(0.28f, -0.44f));
                        d_2 = min(_e234, _e248);
                        let _e250 = d_2;
                        let _e251 = p_2;
                        let _e265 = ndfSdBezier(_e251, vec2<f32>(0.28f, -0.44f), vec2<f32>(0.14f, -0.84f), vec2<f32>(-0.14f, -0.56f));
                        d_2 = min(_e250, _e265);
                    }
                } else {
                    let _e267 = ch_1;
                    if (_e267 == 4i) {
                        {
                            let _e270 = d_2;
                            let _e271 = p_2;
                            let _e273 = yt;
                            let _e280 = sdSegment(_e271, vec2<f32>(0.19f, _e273), vec2<f32>(-0.26f, -0.22f));
                            d_2 = min(_e270, _e280);
                            let _e282 = d_2;
                            let _e283 = p_2;
                            let _e293 = sdSegment(_e283, vec2<f32>(-0.26f, -0.22f), vec2<f32>(0.27f, -0.22f));
                            d_2 = min(_e282, _e293);
                            let _e295 = d_2;
                            let _e296 = p_2;
                            let _e298 = yt;
                            let _e301 = yb;
                            let _e303 = sdSegment(_e296, vec2<f32>(0.19f, _e298), vec2<f32>(0.19f, _e301));
                            d_2 = min(_e295, _e303);
                        }
                    } else {
                        let _e305 = ch_1;
                        if (_e305 == 5i) {
                            {
                                let _e308 = d_2;
                                let _e309 = p_2;
                                let _e312 = yt;
                                let _e315 = yt;
                                let _e317 = sdSegment(_e309, vec2<f32>(-0.2f, _e312), vec2<f32>(0.24f, _e315));
                                d_2 = min(_e308, _e317);
                                let _e319 = d_2;
                                let _e320 = p_2;
                                let _e323 = yt;
                                let _e329 = sdSegment(_e320, vec2<f32>(-0.2f, _e323), vec2<f32>(-0.2f, 0.06f));
                                d_2 = min(_e319, _e329);
                                let _e331 = d_2;
                                let _e332 = p_2;
                                let _e344 = ndfSdBezier(_e332, vec2<f32>(-0.2f, 0.06f), vec2<f32>(0.3f, 0.1f), vec2<f32>(0.28f, -0.3f));
                                d_2 = min(_e331, _e344);
                                let _e346 = d_2;
                                let _e347 = p_2;
                                let _e357 = yb;
                                let _e359 = ndfSdBezier(_e347, vec2<f32>(0.28f, -0.3f), vec2<f32>(0.28f, -0.7f), vec2<f32>(0f, _e357));
                                d_2 = min(_e346, _e359);
                                let _e361 = d_2;
                                let _e362 = p_2;
                                let _e364 = yb;
                                let _e376 = ndfSdBezier(_e362, vec2<f32>(0f, _e364), vec2<f32>(-0.22f, -0.7f), vec2<f32>(-0.22f, -0.42f));
                                d_2 = min(_e361, _e376);
                            }
                        } else {
                            let _e378 = ch_1;
                            if (_e378 == 6i) {
                                {
                                    let _e381 = d_2;
                                    let _e382 = p_2;
                                    let _e395 = ndfSdBezier(_e382, vec2<f32>(0f, -0.02f), vec2<f32>(0.25f, -0.02f), vec2<f32>(0.25f, -0.34f));
                                    d_2 = min(_e381, _e395);
                                    let _e397 = d_2;
                                    let _e398 = p_2;
                                    let _e404 = yb;
                                    let _e407 = yb;
                                    let _e409 = ndfSdBezier(_e398, vec2<f32>(0.25f, -0.34f), vec2<f32>(0.25f, _e404), vec2<f32>(0f, _e407));
                                    d_2 = min(_e397, _e409);
                                    let _e411 = d_2;
                                    let _e412 = p_2;
                                    let _e414 = yb;
                                    let _e418 = yb;
                                    let _e425 = ndfSdBezier(_e412, vec2<f32>(0f, _e414), vec2<f32>(-0.25f, _e418), vec2<f32>(-0.25f, -0.34f));
                                    d_2 = min(_e411, _e425);
                                    let _e427 = d_2;
                                    let _e428 = p_2;
                                    let _e443 = ndfSdBezier(_e428, vec2<f32>(-0.25f, -0.34f), vec2<f32>(-0.25f, -0.02f), vec2<f32>(0f, -0.02f));
                                    d_2 = min(_e427, _e443);
                                    let _e445 = d_2;
                                    let _e446 = p_2;
                                    let _e448 = yt;
                                    let _e459 = ndfSdBezier(_e446, vec2<f32>(0.18f, _e448), vec2<f32>(-0.22f, 0.34f), vec2<f32>(-0.25f, -0.3f));
                                    d_2 = min(_e445, _e459);
                                }
                            } else {
                                let _e461 = ch_1;
                                if (_e461 == 7i) {
                                    {
                                        let _e464 = d_2;
                                        let _e465 = p_2;
                                        let _e468 = yt;
                                        let _e471 = yt;
                                        let _e473 = sdSegment(_e465, vec2<f32>(-0.22f, _e468), vec2<f32>(0.26f, _e471));
                                        d_2 = min(_e464, _e473);
                                        let _e475 = d_2;
                                        let _e476 = p_2;
                                        let _e478 = yt;
                                        let _e485 = yb;
                                        let _e487 = ndfSdBezier(_e476, vec2<f32>(0.26f, _e478), vec2<f32>(0.06f, 0f), vec2<f32>(-0.1f, _e485));
                                        d_2 = min(_e475, _e487);
                                    }
                                } else {
                                    let _e489 = ch_1;
                                    if (_e489 == 8i) {
                                        {
                                            let _e492 = d_2;
                                            let _e493 = p_2;
                                            let _e495 = yt;
                                            let _e498 = yt;
                                            let _e503 = ndfSdBezier(_e493, vec2<f32>(0f, _e495), vec2<f32>(0.19f, _e498), vec2<f32>(0.19f, 0.35f));
                                            d_2 = min(_e492, _e503);
                                            let _e505 = d_2;
                                            let _e506 = p_2;
                                            let _e511 = ym;
                                            let _e514 = ym;
                                            let _e516 = ndfSdBezier(_e506, vec2<f32>(0.19f, 0.35f), vec2<f32>(0.19f, _e511), vec2<f32>(0f, _e514));
                                            d_2 = min(_e505, _e516);
                                            let _e518 = d_2;
                                            let _e519 = p_2;
                                            let _e521 = ym;
                                            let _e525 = ym;
                                            let _e531 = ndfSdBezier(_e519, vec2<f32>(0f, _e521), vec2<f32>(-0.19f, _e525), vec2<f32>(-0.19f, 0.35f));
                                            d_2 = min(_e518, _e531);
                                            let _e533 = d_2;
                                            let _e534 = p_2;
                                            let _e541 = yt;
                                            let _e544 = yt;
                                            let _e546 = ndfSdBezier(_e534, vec2<f32>(-0.19f, 0.35f), vec2<f32>(-0.19f, _e541), vec2<f32>(0f, _e544));
                                            d_2 = min(_e533, _e546);
                                            let _e548 = d_2;
                                            let _e549 = p_2;
                                            let _e551 = ym;
                                            let _e554 = ym;
                                            let _e560 = ndfSdBezier(_e549, vec2<f32>(0f, _e551), vec2<f32>(0.24f, _e554), vec2<f32>(0.24f, -0.36f));
                                            d_2 = min(_e548, _e560);
                                            let _e562 = d_2;
                                            let _e563 = p_2;
                                            let _e569 = yb;
                                            let _e572 = yb;
                                            let _e574 = ndfSdBezier(_e563, vec2<f32>(0.24f, -0.36f), vec2<f32>(0.24f, _e569), vec2<f32>(0f, _e572));
                                            d_2 = min(_e562, _e574);
                                            let _e576 = d_2;
                                            let _e577 = p_2;
                                            let _e579 = yb;
                                            let _e583 = yb;
                                            let _e590 = ndfSdBezier(_e577, vec2<f32>(0f, _e579), vec2<f32>(-0.24f, _e583), vec2<f32>(-0.24f, -0.36f));
                                            d_2 = min(_e576, _e590);
                                            let _e592 = d_2;
                                            let _e593 = p_2;
                                            let _e601 = ym;
                                            let _e604 = ym;
                                            let _e606 = ndfSdBezier(_e593, vec2<f32>(-0.24f, -0.36f), vec2<f32>(-0.24f, _e601), vec2<f32>(0f, _e604));
                                            d_2 = min(_e592, _e606);
                                        }
                                    } else {
                                        let _e608 = ch_1;
                                        if (_e608 == 9i) {
                                            {
                                                let _e611 = d_2;
                                                let _e612 = p_2;
                                                let _e622 = ndfSdBezier(_e612, vec2<f32>(0f, 0.02f), vec2<f32>(0.25f, 0.02f), vec2<f32>(0.25f, 0.34f));
                                                d_2 = min(_e611, _e622);
                                                let _e624 = d_2;
                                                let _e625 = p_2;
                                                let _e630 = yt;
                                                let _e633 = yt;
                                                let _e635 = ndfSdBezier(_e625, vec2<f32>(0.25f, 0.34f), vec2<f32>(0.25f, _e630), vec2<f32>(0f, _e633));
                                                d_2 = min(_e624, _e635);
                                                let _e637 = d_2;
                                                let _e638 = p_2;
                                                let _e640 = yt;
                                                let _e644 = yt;
                                                let _e650 = ndfSdBezier(_e638, vec2<f32>(0f, _e640), vec2<f32>(-0.25f, _e644), vec2<f32>(-0.25f, 0.34f));
                                                d_2 = min(_e637, _e650);
                                                let _e652 = d_2;
                                                let _e653 = p_2;
                                                let _e665 = ndfSdBezier(_e653, vec2<f32>(-0.25f, 0.34f), vec2<f32>(-0.25f, 0.02f), vec2<f32>(0f, 0.02f));
                                                d_2 = min(_e652, _e665);
                                                let _e667 = d_2;
                                                let _e668 = p_2;
                                                let _e671 = yb;
                                                let _e680 = ndfSdBezier(_e668, vec2<f32>(-0.18f, _e671), vec2<f32>(0.22f, -0.34f), vec2<f32>(0.25f, 0.3f));
                                                d_2 = min(_e667, _e680);
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
    let _e682 = d_2;
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
    var d_3: f32 = 1000000000f;

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
        let _e39 = d_3;
        let _e40 = p_4;
        let _e41 = X;
        let _e43 = Yt;
        let _e45 = X;
        let _e46 = Yt;
        let _e48 = sdSegment(_e40, vec2<f32>(-(_e41), _e43), vec2<f32>(_e45, _e46));
        d_3 = min(_e39, _e48);
    }
    let _e50 = m_1;
    if ((_e50 & 2i) != 0i) {
        let _e55 = d_3;
        let _e56 = p_4;
        let _e57 = X;
        let _e58 = Ym;
        let _e60 = X;
        let _e61 = Yt;
        let _e63 = sdSegment(_e56, vec2<f32>(_e57, _e58), vec2<f32>(_e60, _e61));
        d_3 = min(_e55, _e63);
    }
    let _e65 = m_1;
    if ((_e65 & 4i) != 0i) {
        let _e70 = d_3;
        let _e71 = p_4;
        let _e72 = X;
        let _e73 = Yb;
        let _e75 = X;
        let _e76 = Ym;
        let _e78 = sdSegment(_e71, vec2<f32>(_e72, _e73), vec2<f32>(_e75, _e76));
        d_3 = min(_e70, _e78);
    }
    let _e80 = m_1;
    if ((_e80 & 8i) != 0i) {
        let _e85 = d_3;
        let _e86 = p_4;
        let _e87 = X;
        let _e89 = Yb;
        let _e91 = X;
        let _e92 = Yb;
        let _e94 = sdSegment(_e86, vec2<f32>(-(_e87), _e89), vec2<f32>(_e91, _e92));
        d_3 = min(_e85, _e94);
    }
    let _e96 = m_1;
    if ((_e96 & 16i) != 0i) {
        let _e101 = d_3;
        let _e102 = p_4;
        let _e103 = X;
        let _e105 = Yb;
        let _e107 = X;
        let _e109 = Ym;
        let _e111 = sdSegment(_e102, vec2<f32>(-(_e103), _e105), vec2<f32>(-(_e107), _e109));
        d_3 = min(_e101, _e111);
    }
    let _e113 = m_1;
    if ((_e113 & 32i) != 0i) {
        let _e118 = d_3;
        let _e119 = p_4;
        let _e120 = X;
        let _e122 = Ym;
        let _e124 = X;
        let _e126 = Yt;
        let _e128 = sdSegment(_e119, vec2<f32>(-(_e120), _e122), vec2<f32>(-(_e124), _e126));
        d_3 = min(_e118, _e128);
    }
    let _e130 = m_1;
    if ((_e130 & 64i) != 0i) {
        let _e135 = d_3;
        let _e136 = p_4;
        let _e137 = X;
        let _e139 = Ym;
        let _e141 = X;
        let _e142 = Ym;
        let _e144 = sdSegment(_e136, vec2<f32>(-(_e137), _e139), vec2<f32>(_e141, _e142));
        d_3 = min(_e135, _e144);
    }
    let _e146 = d_3;
    return _e146;
}

fn hudNumDist(rel: vec2<f32>, value: f32, decimals_2: i32, nintForce: i32, align: i32, font: i32, gscale: f32) -> f32 {
    var rel_1: vec2<f32>;
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
    var x_1: f32;
    var dx: f32;
    var dy: f32;
    var lx: f32;
    var slot_2: i32;
    var ch_6: i32;
    var gp: vec2<f32>;
    var local_6: f32;

    rel_1 = rel;
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
    let _e97 = rel_1;
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
    x_1 = (_e97.x + _e113);
    let _e116 = x_1;
    let _e118 = x_1;
    let _e119 = w;
    dx = max(max(-(_e116), (_e118 - _e119)), 0f);
    let _e125 = rel_1;
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
    let _e150 = x_1;
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
    let _e192 = rel_1;
    let _e195 = gscale_1;
    gp = vec2<f32>((_e184 - ((f32(_e185) + 0.5f) * _e189)), (-(_e192.y) / _e195));
    let _e199 = font_1;
    if (_e199 == 0i) {
        let _e202 = ch_6;
        let _e203 = gp;
        let _e204 = ndfDigital(_e202, _e203);
        local_6 = _e204;
    } else {
        let _e205 = ch_6;
        let _e206 = gp;
        let _e207 = ndfCurved(_e205, _e206);
        local_6 = _e207;
    }
    let _e209 = local_6;
    let _e210 = gscale_1;
    return (_e209 * _e210);
}

fn hudRect(rel_2: vec2<f32>, hlf: vec2<f32>) -> f32 {
    var rel_3: vec2<f32>;
    var hlf_1: vec2<f32>;
    var q_1: vec2<f32>;

    rel_3 = rel_2;
    hlf_1 = hlf;
    let _e10 = rel_3;
    let _e12 = hlf_1;
    q_1 = (abs(_e10) - _e12);
    let _e15 = q_1;
    let _e20 = q_1;
    let _e22 = q_1;
    return abs((length(max(_e15, vec2(0f))) + min(max(_e20.x, _e22.y), 0f)));
}

fn hudRollTick(px: vec2<f32>, R: f32, deg: f32, len: f32) -> f32 {
    var px_1: vec2<f32>;
    var R_1: f32;
    var deg_1: f32;
    var len_1: f32;
    var a_3: f32;
    var dir: vec2<f32>;

    px_1 = px;
    R_1 = R;
    deg_1 = deg;
    len_1 = len;
    let _e14 = deg_1;
    a_3 = (_e14 * 0.017453292f);
    let _e18 = a_3;
    let _e20 = a_3;
    dir = vec2<f32>(sin(_e18), -(cos(_e20)));
    let _e25 = px_1;
    let _e26 = R_1;
    let _e27 = dir;
    let _e29 = R_1;
    let _e30 = len_1;
    let _e32 = dir;
    let _e34 = sdSegment(_e25, (_e26 * _e27), ((_e29 + _e30) * _e32));
    return _e34;
}

fn hudRollTicks(px_2: vec2<f32>, R_2: f32) -> f32 {
    var px_3: vec2<f32>;
    var R_3: f32;
    var d_4: f32;

    px_3 = px_2;
    R_3 = R_2;
    let _e10 = px_3;
    let _e11 = R_3;
    let _e14 = hudRollTick(_e10, _e11, 0f, 0.055f);
    d_4 = _e14;
    let _e16 = d_4;
    let _e17 = px_3;
    let _e18 = R_3;
    let _e21 = hudRollTick(_e17, _e18, 10f, 0.03f);
    d_4 = min(_e16, _e21);
    let _e23 = d_4;
    let _e24 = px_3;
    let _e25 = R_3;
    let _e28 = hudRollTick(_e24, _e25, 20f, 0.03f);
    d_4 = min(_e23, _e28);
    let _e30 = d_4;
    let _e31 = px_3;
    let _e32 = R_3;
    let _e35 = hudRollTick(_e31, _e32, 30f, 0.045f);
    d_4 = min(_e30, _e35);
    let _e37 = d_4;
    let _e38 = px_3;
    let _e39 = R_3;
    let _e42 = hudRollTick(_e38, _e39, 45f, 0.03f);
    d_4 = min(_e37, _e42);
    let _e44 = d_4;
    let _e45 = px_3;
    let _e46 = R_3;
    let _e49 = hudRollTick(_e45, _e46, 60f, 0.045f);
    d_4 = min(_e44, _e49);
    let _e51 = d_4;
    return _e51;
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

fn tf(m_2: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_3: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_3 = m_2;
    u_3 = u_2;
    let _e10 = m_3;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn hud(uv_1: vec2<f32>, outPos: vec2<f32>, elements: i32, font_2: i32, size: f32, shapeAspectRatio: f32, color1_: vec4<f32>, speed: f32, altitude: f32, glow: f32, thickness: f32, modelTransform: mat3x3<f32>, axisTransform: mat3x3<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var elements_1: i32;
    var font_3: i32;
    var size_1: f32;
    var shapeAspectRatio_1: f32;
    var color1_1: vec4<f32>;
    var speed_1: f32;
    var altitude_1: f32;
    var glow_1: f32;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var axisTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var im: mat3x3<f32>;
    var u_4: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var aa: f32;
    var ar: f32;
    var showLadder: bool;
    var showHeading: bool;
    var showRoll: bool;
    var showSpeed: bool;
    var showAlt: bool;
    var showFpm: bool;
    var showBrackets: bool;
    var showData: bool;
    var modelScale: f32;
    var vb: f32;
    var lineHalf: f32;
    var digitHalf: f32;
    var gscale_2: f32;
    var roll: f32;
    var attScale: f32;
    var pitchDeg: f32;
    var hdg: f32;
    var cr: f32;
    var sr: f32;
    var ur: vec2<f32>;
    var local_7: f32;
    var glowMargin: f32;
    var inBox: bool;
    var dLine: f32 = 1000000000f;
    var dDigit: f32 = 1000000000f;
    var p_5: vec2<f32>;
    var el: f32 = 0.1f;
    var g: vec2<f32>;
    var r: f32 = 0.045f;
    var pa: vec2<f32>;
    var ppd: f32;
    var v_3: f32;
    var k: f32;
    var vk: f32;
    var yk: f32;
    var q_2: vec2<f32>;
    var local_8: f32;
    var W_2: f32;
    var pen: f32;
    var penG: f32;
    var local_9: f32;
    var side: f32;
    var dpu: f32 = 0.03f;
    var penH: f32;
    var hd: f32;
    var km: f32;
    var xm: f32;
    var isMajor: bool;
    var local_10: f32;
    var kM: f32;
    var xM: f32;
    var w_1: f32;
    var R_4: f32 = 0.6f;
    var pr: vec2<f32>;
    var upu: f32 = 0.009f;
    var xT: f32 = -0.74f;
    var penT: f32;
    var vv: f32;
    var k_1: f32;
    var val: f32;
    var y: f32;
    var isMaj: bool;
    var local_11: f32;
    var k5_: f32;
    var val5_: f32;
    var y5_: f32;
    var bc: vec2<f32> = vec2<f32>(-0.875f, 0f);
    var bh: vec2<f32> = vec2<f32>(0.105f, 0.055f);
    var upu_1: f32 = 0.0009f;
    var xT_1: f32 = 0.74f;
    var penT_1: f32;
    var vv_1: f32;
    var k_2: f32;
    var val_1: f32;
    var y_1: f32;
    var isMaj_1: bool;
    var local_12: f32;
    var k5_1: f32;
    var val5_1: f32;
    var y5_1: f32;
    var bc_1: vec2<f32> = vec2<f32>(0.875f, 0f);
    var bh_1: vec2<f32> = vec2<f32>(0.105f, 0.055f);
    var local_13: f32;
    var covLine: f32;
    var covDigit: f32;
    var cov: f32;
    var local_14: f32;
    var dmin: f32;
    var local_15: f32;
    var g_1: f32;
    var outc: vec4<f32>;

    uv_2 = uv_1;
    outPos_1 = outPos;
    elements_1 = elements;
    font_3 = font_2;
    size_1 = size;
    shapeAspectRatio_1 = shapeAspectRatio;
    color1_1 = color1_;
    speed_1 = speed;
    altitude_1 = altitude;
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
    let _e77 = shapeAspectRatio_1;
    ar = _e77;
    let _e79 = elements_1;
    showLadder = ((_e79 & 1i) != 0i);
    let _e85 = elements_1;
    showHeading = ((_e85 & 2i) != 0i);
    let _e91 = elements_1;
    showRoll = ((_e91 & 4i) != 0i);
    let _e97 = elements_1;
    showSpeed = ((_e97 & 8i) != 0i);
    let _e103 = elements_1;
    showAlt = ((_e103 & 16i) != 0i);
    let _e109 = elements_1;
    showFpm = ((_e109 & 32i) != 0i);
    let _e115 = elements_1;
    showBrackets = ((_e115 & 64i) != 0i);
    let _e121 = elements_1;
    showData = ((_e121 & 128i) != 0i);
    let _e131 = modelTransform_1[0][0];
    let _e136 = modelTransform_1[0][1];
    modelScale = length(vec2<f32>(_e131, _e136));
    let _e140 = modelScale;
    if (_e140 < 0.00001f) {
        modelScale = 0.00001f;
    }
    let _e145 = modelScale;
    vb = (1f / _e145);
    let _e148 = thickness_1;
    let _e151 = vb;
    lineHalf = ((_e148 * 0.025f) * _e151);
    let _e155 = vb;
    digitHalf = (0.003f * _e155);
    let _e159 = vb;
    let _e161 = size_1;
    gscale_2 = ((0.042f * _e159) * _e161);
    let _e168 = axisTransform_1[0][1];
    let _e173 = axisTransform_1[0][0];
    roll = atan2(_e168, _e173);
    let _e180 = axisTransform_1[0][0];
    let _e185 = axisTransform_1[0][1];
    attScale = length(vec2<f32>(_e180, _e185));
    let _e189 = attScale;
    if (_e189 < 0.00001f) {
        attScale = 1f;
    }
    let _e197 = axisTransform_1[2][1];
    let _e199 = attScale;
    pitchDeg = ((-(_e197) / _e199) * 90f);
    let _e208 = axisTransform_1[2][0];
    let _e209 = attScale;
    hdg = ((_e208 / _e209) * 120f);
    let _e214 = roll;
    cr = cos(_e214);
    let _e217 = roll;
    sr = sin(_e217);
    let _e220 = cr;
    let _e221 = u_4;
    let _e224 = sr;
    let _e225 = u_4;
    let _e229 = sr;
    let _e231 = u_4;
    let _e234 = cr;
    let _e235 = u_4;
    ur = vec2<f32>(((_e220 * _e221.x) + (_e224 * _e225.y)), ((-(_e229) * _e231.x) + (_e234 * _e235.y)));
    let _e241 = glow_1;
    if (_e241 > 0.006f) {
        let _e244 = glow_1;
        local_7 = clamp((log((_e244 / 0.006f)) * 0.125f), 0.15f, 1f);
    } else {
        local_7 = 0.15f;
    }
    let _e255 = local_7;
    glowMargin = _e255;
    let _e257 = u_4;
    let _e261 = glowMargin;
    let _e263 = aa;
    let _e266 = u_4;
    let _e269 = ar;
    let _e270 = glowMargin;
    let _e272 = aa;
    inBox = ((abs(_e257.x) <= ((1f + _e261) + _e263)) && (abs(_e266.y) <= ((_e269 + _e270) + _e272)));
    let _e281 = inBox;
    if _e281 {
        {
            let _e282 = showBrackets;
            if _e282 {
                {
                    let _e283 = u_4;
                    p_5 = abs(_e283);
                    let _e288 = dLine;
                    let _e289 = p_5;
                    let _e291 = ar;
                    let _e292 = el;
                    let _e296 = ar;
                    let _e298 = sdSegment(_e289, vec2<f32>(1f, (_e291 - _e292)), vec2<f32>(1f, _e296));
                    dLine = min(_e288, _e298);
                    let _e300 = dLine;
                    let _e301 = p_5;
                    let _e303 = el;
                    let _e305 = ar;
                    let _e308 = ar;
                    let _e310 = sdSegment(_e301, vec2<f32>((1f - _e303), _e305), vec2<f32>(1f, _e308));
                    dLine = min(_e300, _e310);
                }
            }
            let _e312 = showFpm;
            if _e312 {
                {
                    let _e313 = u_4;
                    let _e315 = u_4;
                    let _e317 = ar;
                    g = vec2<f32>(_e313.x, (_e315.y + (_e317 * 0.45f)));
                    let _e323 = dLine;
                    let _e324 = g;
                    let _e332 = sdSegment(_e324, vec2<f32>(-0.045f, 0f), vec2<f32>(0.045f, 0f));
                    dLine = min(_e323, _e332);
                    let _e334 = dLine;
                    let _e335 = g;
                    let _e343 = sdSegment(_e335, vec2<f32>(0f, -0.045f), vec2<f32>(0f, 0.045f));
                    dLine = min(_e334, _e343);
                    let _e347 = dLine;
                    let _e348 = u_4;
                    let _e350 = r;
                    dLine = min(_e347, abs((length(_e348) - _e350)));
                    let _e354 = u_4;
                    let _e357 = u_4;
                    pa = vec2<f32>(abs(_e354.x), _e357.y);
                    let _e361 = dLine;
                    let _e362 = pa;
                    let _e363 = r;
                    let _e367 = r;
                    let _e371 = sdSegment(_e362, vec2<f32>(_e363, 0f), vec2<f32>((2.6f * _e367), 0f));
                    dLine = min(_e361, _e371);
                    let _e373 = dLine;
                    let _e374 = u_4;
                    let _e376 = r;
                    let _e382 = r;
                    let _e385 = sdSegment(_e374, vec2<f32>(0f, -(_e376)), vec2<f32>(0f, (-2f * _e382)));
                    dLine = min(_e373, _e385);
                }
            }
            let _e387 = showLadder;
            if _e387 {
                {
                    let _e389 = attScale;
                    ppd = (0.024f * _e389);
                    let _e392 = pitchDeg;
                    let _e393 = ur;
                    let _e395 = ppd;
                    v_3 = (_e392 - (_e393.y / _e395));
                    let _e399 = v_3;
                    k = floor(((_e399 / 10f) + 0.5f));
                    let _e406 = k;
                    vk = (clamp(_e406, -9f, 9f) * 10f);
                    let _e414 = pitchDeg;
                    let _e415 = vk;
                    let _e417 = ppd;
                    yk = ((_e414 - _e415) * _e417);
                    let _e420 = ur;
                    let _e422 = ur;
                    let _e424 = yk;
                    q_2 = vec2<f32>(_e420.x, (_e422.y - _e424));
                    let _e428 = vk;
                    if (abs(_e428) < 0.5f) {
                        local_8 = 0.6f;
                    } else {
                        local_8 = 0.34f;
                    }
                    let _e435 = local_8;
                    W_2 = _e435;
                    let _e437 = ur;
                    let _e440 = ar;
                    let _e446 = u_4;
                    pen = ((max((abs(_e437.y) - (_e440 * 0.62f)), 0f) + max((abs(_e446.x) - 0.6f), 0f)) * 12f);
                    let _e457 = pen;
                    penG = min(_e457, 0.3f);
                    let _e461 = dLine;
                    let _e462 = q_2;
                    let _e465 = q_2;
                    let _e468 = vk;
                    let _e470 = W_2;
                    let _e472 = hudLadderBar(vec2<f32>(abs(_e462.x), _e465.y), _e468, 0.13f, _e470, 0.045f);
                    let _e473 = penG;
                    dLine = min(_e461, (_e472 + _e473));
                    let _e476 = vk;
                    if (abs(_e476) > 0.5f) {
                        {
                            let _e480 = q_2;
                            if (_e480.x >= 0f) {
                                local_9 = 1f;
                            } else {
                                local_9 = -1f;
                            }
                            let _e488 = local_9;
                            side = _e488;
                            let _e490 = dDigit;
                            let _e491 = q_2;
                            let _e493 = side;
                            let _e494 = W_2;
                            let _e499 = q_2;
                            let _e502 = vk;
                            let _e507 = font_3;
                            let _e508 = gscale_2;
                            let _e511 = hudNumDist(vec2<f32>((_e491.x - (_e493 * (_e494 + 0.075f))), _e499.y), abs(_e502), 0i, 0i, 0i, _e507, (_e508 * 0.8f));
                            let _e512 = penG;
                            dDigit = min(_e490, (_e511 + _e512));
                        }
                    }
                }
            }
            let _e515 = showHeading;
            if _e515 {
                {
                    let _e518 = u_4;
                    penH = (max((abs(_e518.x) - 0.66f), 0f) * 3f);
                    let _e528 = hdg;
                    let _e529 = u_4;
                    let _e531 = dpu;
                    hd = (_e528 + (_e529.x / _e531));
                    let _e535 = hd;
                    km = floor(((_e535 / 5f) + 0.5f));
                    let _e542 = km;
                    let _e545 = hdg;
                    let _e547 = dpu;
                    xm = (((_e542 * 5f) - _e545) * _e547);
                    let _e550 = km;
                    isMajor = ((_e550 - (floor((_e550 / 2f)) * 2f)) < 0.5f);
                    let _e559 = dLine;
                    let _e560 = u_4;
                    let _e562 = xm;
                    let _e564 = u_4;
                    let _e568 = ar;
                    let _e574 = isMajor;
                    if _e574 {
                        let _e575 = ar;
                        local_10 = (-(_e575) * 0.845f);
                    } else {
                        let _e579 = ar;
                        local_10 = (-(_e579) * 0.865f);
                    }
                    let _e584 = local_10;
                    let _e586 = sdSegment(vec2<f32>((_e560.x - _e562), _e564.y), vec2<f32>(0f, (-(_e568) * 0.885f)), vec2<f32>(0f, _e584));
                    let _e587 = penH;
                    dLine = min(_e559, (_e586 + _e587));
                    let _e590 = hd;
                    kM = floor(((_e590 / 10f) + 0.5f));
                    let _e597 = kM;
                    let _e600 = hdg;
                    let _e602 = dpu;
                    xM = (((_e597 * 10f) - _e600) * _e602);
                    let _e605 = kM;
                    let _e607 = (_e605 * 10f);
                    let _e614 = ((_e607 - (floor((_e607 / 360f)) * 360f)) + 360f);
                    w_1 = (_e614 - (floor((_e614 / 360f)) * 360f));
                    let _e621 = dDigit;
                    let _e622 = u_4;
                    let _e624 = xM;
                    let _e626 = u_4;
                    let _e628 = ar;
                    let _e633 = w_1;
                    let _e637 = font_3;
                    let _e638 = gscale_2;
                    let _e641 = hudNumDist(vec2<f32>((_e622.x - _e624), (_e626.y + (_e628 * 0.935f))), _e633, 0i, 3i, 0i, _e637, (_e638 * 0.8f));
                    let _e642 = penH;
                    dDigit = min(_e621, (_e641 + _e642));
                    let _e645 = dLine;
                    let _e646 = u_4;
                    let _e649 = u_4;
                    let _e653 = ar;
                    let _e659 = ar;
                    let _e664 = sdSegment(vec2<f32>(abs(_e646.x), _e649.y), vec2<f32>(0f, (-(_e653) * 0.835f)), vec2<f32>(0.022f, (-(_e659) * 0.795f)));
                    dLine = min(_e645, _e664);
                }
            }
            let _e666 = showRoll;
            if _e666 {
                {
                    let _e669 = dLine;
                    let _e670 = u_4;
                    let _e673 = u_4;
                    let _e676 = R_4;
                    let _e677 = hudRollTicks(vec2<f32>(abs(_e670.x), _e673.y), _e676);
                    dLine = min(_e669, _e677);
                    let _e679 = ur;
                    let _e682 = ur;
                    pr = vec2<f32>(abs(_e679.x), _e682.y);
                    let _e686 = dLine;
                    let _e687 = pr;
                    let _e689 = R_4;
                    let _e695 = R_4;
                    let _e700 = sdSegment(_e687, vec2<f32>(0f, -((_e689 - 0.012f))), vec2<f32>(0.02f, -((_e695 - 0.058f))));
                    dLine = min(_e686, _e700);
                    let _e702 = dLine;
                    let _e703 = pr;
                    let _e705 = R_4;
                    let _e711 = R_4;
                    let _e716 = sdSegment(_e703, vec2<f32>(0f, -((_e705 - 0.058f))), vec2<f32>(0.02f, -((_e711 - 0.058f))));
                    dLine = min(_e702, _e716);
                }
            }
            let _e718 = showSpeed;
            if _e718 {
                {
                    let _e724 = u_4;
                    let _e727 = ar;
                    let _e736 = u_4;
                    penT = ((max((abs(_e724.y) - (_e727 * 0.75f)), 0f) * 3f) + (max((0.085f - abs(_e736.y)), 0f) * 3f));
                    let _e746 = speed_1;
                    let _e747 = u_4;
                    let _e749 = upu;
                    vv = (_e746 - (_e747.y / _e749));
                    let _e753 = vv;
                    k_1 = floor(((_e753 / 10f) + 0.5f));
                    let _e760 = k_1;
                    val = (max(_e760, 0f) * 10f);
                    let _e766 = speed_1;
                    let _e767 = val;
                    let _e769 = upu;
                    y = ((_e766 - _e767) * _e769);
                    let _e772 = k_1;
                    isMaj = ((_e772 - (floor((_e772 / 5f)) * 5f)) < 0.5f);
                    let _e781 = dLine;
                    let _e782 = u_4;
                    let _e784 = u_4;
                    let _e786 = y;
                    let _e789 = xT;
                    let _e792 = xT;
                    let _e793 = isMaj;
                    if _e793 {
                        local_11 = 0.045f;
                    } else {
                        local_11 = 0.028f;
                    }
                    let _e797 = local_11;
                    let _e801 = sdSegment(vec2<f32>(_e782.x, (_e784.y - _e786)), vec2<f32>(_e789, 0f), vec2<f32>((_e792 + _e797), 0f));
                    let _e802 = penT;
                    dLine = min(_e781, (_e801 + _e802));
                    let _e805 = vv;
                    k5_ = floor(((_e805 / 50f) + 0.5f));
                    let _e812 = k5_;
                    val5_ = (max(_e812, 0f) * 50f);
                    let _e818 = speed_1;
                    let _e819 = val5_;
                    let _e821 = upu;
                    y5_ = ((_e818 - _e819) * _e821);
                    let _e824 = dDigit;
                    let _e825 = u_4;
                    let _e827 = xT;
                    let _e831 = u_4;
                    let _e833 = y5_;
                    let _e836 = val5_;
                    let _e840 = font_3;
                    let _e841 = gscale_2;
                    let _e844 = hudNumDist(vec2<f32>((_e825.x - (_e827 - 0.025f)), (_e831.y - _e833)), _e836, 0i, 0i, 1i, _e840, (_e841 * 0.8f));
                    let _e845 = penT;
                    dDigit = min(_e824, (_e844 + _e845));
                    let _e857 = dLine;
                    let _e858 = u_4;
                    let _e859 = bc;
                    let _e861 = bh;
                    let _e862 = hudRect((_e858 - _e859), _e861);
                    dLine = min(_e857, _e862);
                    let _e864 = dLine;
                    let _e865 = u_4;
                    let _e866 = bc;
                    let _e868 = bh;
                    let _e873 = xT;
                    let _e876 = sdSegment(_e865, vec2<f32>((_e866.x + _e868.x), 0f), vec2<f32>(_e873, 0f));
                    dLine = min(_e864, _e876);
                    let _e878 = dDigit;
                    let _e879 = u_4;
                    let _e881 = bc;
                    let _e883 = bh;
                    let _e889 = u_4;
                    let _e892 = speed_1;
                    let _e896 = font_3;
                    let _e897 = gscale_2;
                    let _e900 = hudNumDist(vec2<f32>((_e879.x - ((_e881.x + _e883.x) - 0.02f)), _e889.y), _e892, 0i, 0i, 1i, _e896, (_e897 * 0.9f));
                    dDigit = min(_e878, _e900);
                }
            }
            let _e902 = showAlt;
            if _e902 {
                {
                    let _e907 = u_4;
                    let _e910 = ar;
                    let _e919 = u_4;
                    penT_1 = ((max((abs(_e907.y) - (_e910 * 0.75f)), 0f) * 3f) + (max((0.085f - abs(_e919.y)), 0f) * 3f));
                    let _e929 = altitude_1;
                    let _e930 = u_4;
                    let _e932 = upu_1;
                    vv_1 = (_e929 - (_e930.y / _e932));
                    let _e936 = vv_1;
                    k_2 = floor(((_e936 / 100f) + 0.5f));
                    let _e943 = k_2;
                    val_1 = (max(_e943, 0f) * 100f);
                    let _e949 = altitude_1;
                    let _e950 = val_1;
                    let _e952 = upu_1;
                    y_1 = ((_e949 - _e950) * _e952);
                    let _e955 = k_2;
                    isMaj_1 = ((_e955 - (floor((_e955 / 5f)) * 5f)) < 0.5f);
                    let _e964 = dLine;
                    let _e965 = u_4;
                    let _e967 = u_4;
                    let _e969 = y_1;
                    let _e972 = xT_1;
                    let _e973 = isMaj_1;
                    if _e973 {
                        local_12 = 0.045f;
                    } else {
                        local_12 = 0.028f;
                    }
                    let _e977 = local_12;
                    let _e981 = xT_1;
                    let _e984 = sdSegment(vec2<f32>(_e965.x, (_e967.y - _e969)), vec2<f32>((_e972 - _e977), 0f), vec2<f32>(_e981, 0f));
                    let _e985 = penT_1;
                    dLine = min(_e964, (_e984 + _e985));
                    let _e988 = vv_1;
                    k5_1 = floor(((_e988 / 500f) + 0.5f));
                    let _e995 = k5_1;
                    val5_1 = (max(_e995, 0f) * 500f);
                    let _e1001 = altitude_1;
                    let _e1002 = val5_1;
                    let _e1004 = upu_1;
                    y5_1 = ((_e1001 - _e1002) * _e1004);
                    let _e1007 = dDigit;
                    let _e1008 = u_4;
                    let _e1010 = xT_1;
                    let _e1014 = u_4;
                    let _e1016 = y5_1;
                    let _e1019 = val5_1;
                    let _e1023 = font_3;
                    let _e1024 = gscale_2;
                    let _e1027 = hudNumDist(vec2<f32>((_e1008.x - (_e1010 + 0.025f)), (_e1014.y - _e1016)), _e1019, 0i, 0i, 2i, _e1023, (_e1024 * 0.8f));
                    let _e1028 = penT_1;
                    dDigit = min(_e1007, (_e1027 + _e1028));
                    let _e1039 = dLine;
                    let _e1040 = u_4;
                    let _e1041 = bc_1;
                    let _e1043 = bh_1;
                    let _e1044 = hudRect((_e1040 - _e1041), _e1043);
                    dLine = min(_e1039, _e1044);
                    let _e1046 = dLine;
                    let _e1047 = u_4;
                    let _e1048 = xT_1;
                    let _e1051 = bc_1;
                    let _e1053 = bh_1;
                    let _e1058 = sdSegment(_e1047, vec2<f32>(_e1048, 0f), vec2<f32>((_e1051.x - _e1053.x), 0f));
                    dLine = min(_e1046, _e1058);
                    let _e1060 = dDigit;
                    let _e1061 = u_4;
                    let _e1063 = bc_1;
                    let _e1065 = bh_1;
                    let _e1071 = u_4;
                    let _e1074 = altitude_1;
                    let _e1078 = font_3;
                    let _e1079 = gscale_2;
                    let _e1082 = hudNumDist(vec2<f32>((_e1061.x - ((_e1063.x + _e1065.x) - 0.02f)), _e1071.y), _e1074, 0i, 0i, 1i, _e1078, (_e1079 * 0.9f));
                    dDigit = min(_e1060, _e1082);
                }
            }
            let _e1084 = showData;
            if _e1084 {
                {
                    let _e1085 = dDigit;
                    let _e1086 = u_4;
                    let _e1090 = u_4;
                    let _e1092 = ar;
                    let _e1097 = speed_1;
                    let _e1103 = font_3;
                    let _e1104 = gscale_2;
                    let _e1107 = hudNumDist(vec2<f32>((_e1086.x + 0.8f), (_e1090.y - (_e1092 * 0.86f))), (_e1097 / 661f), 2i, 0i, 0i, _e1103, (_e1104 * 0.85f));
                    dDigit = min(_e1085, _e1107);
                    let _e1109 = dDigit;
                    let _e1110 = u_4;
                    let _e1114 = u_4;
                    let _e1116 = ar;
                    let _e1121 = pitchDeg;
                    let _e1125 = font_3;
                    let _e1126 = gscale_2;
                    let _e1129 = hudNumDist(vec2<f32>((_e1110.x - 0.8f), (_e1114.y - (_e1116 * 0.86f))), _e1121, 0i, 0i, 0i, _e1125, (_e1126 * 0.85f));
                    dDigit = min(_e1109, _e1129);
                }
            }
        }
    }
    let _e1131 = lineHalf;
    if (_e1131 <= 0f) {
        local_13 = 0f;
    } else {
        let _e1136 = lineHalf;
        let _e1137 = aa;
        let _e1139 = lineHalf;
        let _e1140 = aa;
        let _e1142 = dLine;
        local_13 = (1f - smoothstep((_e1136 - _e1137), (_e1139 + _e1140), _e1142));
    }
    let _e1146 = local_13;
    covLine = _e1146;
    let _e1149 = digitHalf;
    let _e1150 = aa;
    let _e1152 = digitHalf;
    let _e1153 = aa;
    let _e1155 = dDigit;
    covDigit = (1f - smoothstep((_e1149 - _e1150), (_e1152 + _e1153), _e1155));
    let _e1159 = covLine;
    let _e1160 = covDigit;
    cov = max(_e1159, _e1160);
    let _e1163 = lineHalf;
    if (_e1163 <= 0f) {
        let _e1166 = dDigit;
        local_14 = _e1166;
    } else {
        let _e1167 = dLine;
        let _e1168 = dDigit;
        local_14 = min(_e1167, _e1168);
    }
    let _e1171 = local_14;
    dmin = _e1171;
    let _e1173 = glow_1;
    if (_e1173 > 0f) {
        let _e1176 = glow_1;
        let _e1177 = dmin;
        let _e1178 = lineHalf;
        let _e1179 = digitHalf;
        let _e1190 = cov;
        local_15 = ((_e1176 * exp((-(max((_e1177 - max(_e1178, _e1179)), 0f)) * 8f))) * (1f - _e1190));
    } else {
        local_15 = 0f;
    }
    let _e1195 = local_15;
    g_1 = _e1195;
    let _e1197 = cov;
    let _e1200 = g_1;
    if ((_e1197 <= 0f) && (_e1200 <= 0.002f)) {
        let _e1204 = bkg_2;
        return _e1204;
    }
    let _e1205 = bkg_2;
    let _e1206 = color1_1;
    let _e1207 = _e1206.xyz;
    let _e1208 = color1_1;
    let _e1210 = cov;
    let _e1216 = mergeColor(_e1205, vec4<f32>(_e1207.x, _e1207.y, _e1207.z, (_e1208.w * _e1210)));
    outc = _e1216;
    let _e1218 = outc;
    let _e1220 = outc;
    let _e1222 = color1_1;
    let _e1224 = g_1;
    let _e1226 = (_e1220.xyz + (_e1222.xyz * _e1224));
    outc.x = _e1226.x;
    outc.y = _e1226.y;
    outc.z = _e1226.z;
    let _e1234 = outc;
    let _e1236 = g_1;
    outc.w = max(_e1234.w, min(_e1236, 1f));
    let _e1240 = outc;
    return _e1240;
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
    let _e99 = global.U[13];
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e111 = global.U[16];
    let _e112 = _e111.xyz;
    let _e128 = global.U[17];
    let _e129 = _e128.xyz;
    let _e132 = global.U[18];
    let _e133 = _e132.xyz;
    let _e136 = global.U[19];
    let _e137 = _e136.xyz;
    let _e153 = global.U[4];
    let _e155 = hud((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, _e87.x, _e91.x, _e95.x, _e99.x, mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)), mat3x3<f32>(vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z), vec3<f32>(_e137.x, _e137.y, _e137.z)), _e153.xy);
    fragColor = _e155;
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
