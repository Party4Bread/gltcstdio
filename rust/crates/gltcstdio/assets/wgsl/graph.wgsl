struct Params {
    U: array<vec4<f32>, 36>,
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

fn graphCurveY(mode: i32, xl: f32) -> f32 {
    var mode_1: i32;
    var xl_1: f32;

    mode_1 = mode;
    xl_1 = xl;
    let _e10 = mode_1;
    if (_e10 == 2i) {
        let _e13 = xl_1;
        return log(max(_e13, 0.0001f));
    }
    let _e17 = mode_1;
    if (_e17 == 3i) {
        let _e20 = xl_1;
        return exp(clamp(_e20, -30f, 7f));
    }
    let _e26 = mode_1;
    if (_e26 == 4i) {
        let _e29 = xl_1;
        let _e33 = xl_1;
        let _e40 = xl_1;
        let _e47 = xl_1;
        return (((sin(_e29) + (0.5f * sin((2f * _e33)))) + (0.333f * sin((3f * _e40)))) + (0.25f * sin((4f * _e47))));
    }
    let _e52 = xl_1;
    return sin(_e52);
}

fn graphCurveEval(mode_2: i32, x: f32, ct: mat3x3<f32>) -> f32 {
    var mode_3: i32;
    var x_1: f32;
    var ct_1: mat3x3<f32>;
    var cSx: f32;

    mode_3 = mode_2;
    x_1 = x;
    ct_1 = ct;
    let _e16 = ct_1[0][0];
    cSx = _e16;
    let _e18 = cSx;
    if (abs(_e18) < 0.00001f) {
        cSx = 0.00001f;
    }
    let _e27 = ct_1[1][1];
    let _e28 = mode_3;
    let _e29 = x_1;
    let _e34 = ct_1[2][0];
    let _e38 = cSx;
    let _e40 = graphCurveY(_e28, ((_e29 - (_e34 * 3f)) / _e38));
    let _e46 = ct_1[2][1];
    return ((_e27 * _e40) + (-(_e46) * 3f));
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
    var x_2: vec2<f32>;
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
            x_2 = ((vec2<f32>(_e139, -(_e140)) - vec2(_e143)) / vec2(2f));
            let _e150 = x_2;
            let _e152 = x_2;
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

fn tf(m_1: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_2: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_2 = m_1;
    u_3 = u_2;
    let _e10 = m_2;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn graphCurve(mode_4: i32, render: i32, atF: mat3x3<f32>, u_4: vec2<f32>, dpos: vec2<f32>, minorX: f32, Lx: f32, ct_2: mat3x3<f32>) -> vec2<f32> {
    var mode_5: i32;
    var render_1: i32;
    var atF_1: mat3x3<f32>;
    var u_5: vec2<f32>;
    var dpos_1: vec2<f32>;
    var minorX_1: f32;
    var Lx_1: f32;
    var ct_3: mat3x3<f32>;
    var dCurve: f32 = 1000000000f;
    var dDot: f32 = 1000000000f;
    var xc: f32;
    var val: f32;
    var barW: f32;
    var c0_: vec2<f32>;
    var c1_: vec2<f32>;
    var lo: vec2<f32>;
    var hi: vec2<f32>;
    var ctr: vec2<f32>;
    var hlf: vec2<f32>;
    var q_1: vec2<f32>;
    var j0_: f32;
    var s: i32 = -1i;
    var xa: f32;
    var xb: f32;
    var A_2: vec2<f32>;
    var C_2: vec2<f32>;
    var kx_1: f32;
    var P: vec2<f32>;
    var local: f32;
    var j0_1: f32;
    var s_1: i32 = -1i;
    var xa_1: f32;
    var xm: f32;
    var xb_1: f32;
    var A_3: vec2<f32>;
    var M: vec2<f32>;
    var C_3: vec2<f32>;
    var Bc: vec2<f32>;

    mode_5 = mode_4;
    render_1 = render;
    atF_1 = atF;
    u_5 = u_4;
    dpos_1 = dpos;
    minorX_1 = minorX;
    Lx_1 = Lx;
    ct_3 = ct_2;
    let _e26 = render_1;
    let _e29 = render_1;
    if ((_e26 >= 2i) && (_e29 <= 4i)) {
        {
            let _e33 = dpos_1;
            let _e35 = minorX_1;
            let _e40 = minorX_1;
            xc = (floor(((_e33.x / _e35) + 0.5f)) * _e40);
            let _e43 = mode_5;
            let _e44 = xc;
            let _e45 = ct_3;
            let _e46 = graphCurveEval(_e43, _e44, _e45);
            val = _e46;
            let _e48 = minorX_1;
            barW = (_e48 * 0.4f);
            let _e52 = atF_1;
            let _e53 = xc;
            let _e54 = barW;
            let _e58 = tf(_e52, vec2<f32>((_e53 - _e54), 0f));
            c0_ = _e58;
            let _e60 = atF_1;
            let _e61 = xc;
            let _e62 = barW;
            let _e64 = val;
            let _e66 = tf(_e60, vec2<f32>((_e61 + _e62), _e64));
            c1_ = _e66;
            let _e68 = c0_;
            let _e69 = c1_;
            lo = min(_e68, _e69);
            let _e72 = c0_;
            let _e73 = c1_;
            hi = max(_e72, _e73);
            let _e76 = lo;
            let _e77 = hi;
            ctr = ((_e76 + _e77) * 0.5f);
            let _e82 = hi;
            let _e83 = lo;
            hlf = ((_e82 - _e83) * 0.5f);
            let _e88 = u_5;
            let _e89 = ctr;
            let _e92 = hlf;
            q_1 = (abs((_e88 - _e89)) - _e92);
            let _e95 = q_1;
            let _e100 = q_1;
            let _e102 = q_1;
            dCurve = (length(max(_e95, vec2(0f))) + min(max(_e100.x, _e102.y), 0f));
        }
    } else {
        let _e108 = render_1;
        if (_e108 >= 5i) {
            {
                let _e111 = dpos_1;
                let _e113 = Lx_1;
                j0_ = floor((_e111.x / _e113));
                loop {
                    let _e120 = s;
                    if !((_e120 <= 1i)) {
                        break;
                    }
                    {
                        let _e127 = j0_;
                        let _e128 = s;
                        let _e131 = Lx_1;
                        xa = ((_e127 + f32(_e128)) * _e131);
                        let _e134 = xa;
                        let _e135 = Lx_1;
                        xb = (_e134 + _e135);
                        let _e138 = atF_1;
                        let _e139 = xa;
                        let _e140 = mode_5;
                        let _e141 = xa;
                        let _e142 = ct_3;
                        let _e143 = graphCurveEval(_e140, _e141, _e142);
                        let _e145 = tf(_e138, vec2<f32>(_e139, _e143));
                        A_2 = _e145;
                        let _e147 = atF_1;
                        let _e148 = xb;
                        let _e149 = mode_5;
                        let _e150 = xb;
                        let _e151 = ct_3;
                        let _e152 = graphCurveEval(_e149, _e150, _e151);
                        let _e154 = tf(_e147, vec2<f32>(_e148, _e152));
                        C_2 = _e154;
                        let _e156 = dCurve;
                        let _e157 = u_5;
                        let _e158 = A_2;
                        let _e159 = C_2;
                        let _e160 = sdSegment(_e157, _e158, _e159);
                        dCurve = min(_e156, _e160);
                    }
                    continuing {
                        let _e124 = s;
                        s = (_e124 + 1i);
                    }
                }
                let _e162 = render_1;
                if (_e162 >= 6i) {
                    {
                        let _e165 = dpos_1;
                        let _e167 = Lx_1;
                        let _e172 = Lx_1;
                        kx_1 = (floor(((_e165.x / _e167) + 0.5f)) * _e172);
                        let _e175 = atF_1;
                        let _e176 = kx_1;
                        let _e177 = mode_5;
                        let _e178 = kx_1;
                        let _e179 = ct_3;
                        let _e180 = graphCurveEval(_e177, _e178, _e179);
                        let _e182 = tf(_e175, vec2<f32>(_e176, _e180));
                        P = _e182;
                        let _e184 = render_1;
                        if (_e184 == 6i) {
                            let _e187 = u_5;
                            let _e188 = P;
                            local = length((_e187 - _e188));
                        } else {
                            let _e191 = u_5;
                            let _e193 = P;
                            let _e197 = u_5;
                            let _e199 = P;
                            local = max(abs((_e191.x - _e193.x)), abs((_e197.y - _e199.y)));
                        }
                        let _e205 = local;
                        dDot = _e205;
                    }
                }
            }
        } else {
            {
                let _e206 = dpos_1;
                let _e208 = minorX_1;
                j0_1 = floor((_e206.x / _e208));
                loop {
                    let _e215 = s_1;
                    if !((_e215 <= 1i)) {
                        break;
                    }
                    {
                        let _e222 = j0_1;
                        let _e223 = s_1;
                        let _e226 = minorX_1;
                        xa_1 = ((_e222 + f32(_e223)) * _e226);
                        let _e229 = xa_1;
                        let _e230 = minorX_1;
                        xm = (_e229 + (_e230 * 0.5f));
                        let _e235 = xa_1;
                        let _e236 = minorX_1;
                        xb_1 = (_e235 + _e236);
                        let _e239 = atF_1;
                        let _e240 = xa_1;
                        let _e241 = mode_5;
                        let _e242 = xa_1;
                        let _e243 = ct_3;
                        let _e244 = graphCurveEval(_e241, _e242, _e243);
                        let _e246 = tf(_e239, vec2<f32>(_e240, _e244));
                        A_3 = _e246;
                        let _e248 = atF_1;
                        let _e249 = xm;
                        let _e250 = mode_5;
                        let _e251 = xm;
                        let _e252 = ct_3;
                        let _e253 = graphCurveEval(_e250, _e251, _e252);
                        let _e255 = tf(_e248, vec2<f32>(_e249, _e253));
                        M = _e255;
                        let _e257 = atF_1;
                        let _e258 = xb_1;
                        let _e259 = mode_5;
                        let _e260 = xb_1;
                        let _e261 = ct_3;
                        let _e262 = graphCurveEval(_e259, _e260, _e261);
                        let _e264 = tf(_e257, vec2<f32>(_e258, _e262));
                        C_3 = _e264;
                        let _e267 = M;
                        let _e270 = A_3;
                        let _e271 = C_3;
                        Bc = ((2f * _e267) - (0.5f * (_e270 + _e271)));
                        let _e276 = dCurve;
                        let _e277 = u_5;
                        let _e278 = A_3;
                        let _e279 = Bc;
                        let _e280 = C_3;
                        let _e281 = ndfSdBezier(_e277, _e278, _e279, _e280);
                        dCurve = min(_e276, _e281);
                    }
                    continuing {
                        let _e219 = s_1;
                        s_1 = (_e219 + 1i);
                    }
                }
            }
        }
    }
    let _e283 = dCurve;
    let _e284 = dDot;
    return vec2<f32>(_e283, _e284);
}

fn graphCurveCov(render_2: i32, dCurve_1: f32, dDot_1: f32, curveHalf: f32, lineHalf: f32, u_6: vec2<f32>, aa: f32, vb: f32) -> vec2<f32> {
    var render_3: i32;
    var dCurve_2: f32;
    var dDot_2: f32;
    var curveHalf_1: f32;
    var lineHalf_1: f32;
    var u_7: vec2<f32>;
    var aa_1: f32;
    var vb_1: f32;
    var covCurve: f32 = 0f;
    var covB: f32 = 0f;
    var outline: f32;
    var hs: f32;
    var t_2: f32;
    var hd: f32;
    var local_1: f32;
    var hatch: f32;
    var dotR: f32;

    render_3 = render_2;
    dCurve_2 = dCurve_1;
    dDot_2 = dDot_1;
    curveHalf_1 = curveHalf;
    lineHalf_1 = lineHalf;
    u_7 = u_6;
    aa_1 = aa;
    vb_1 = vb;
    let _e26 = render_3;
    let _e29 = render_3;
    if ((_e26 == 1i) || (_e29 == 5i)) {
        {
            let _e34 = curveHalf_1;
            let _e35 = aa_1;
            let _e37 = curveHalf_1;
            let _e38 = aa_1;
            let _e40 = dCurve_2;
            covCurve = (1f - smoothstep((_e34 - _e35), (_e37 + _e38), _e40));
        }
    } else {
        let _e43 = render_3;
        if (_e43 == 2i) {
            {
                let _e47 = aa_1;
                let _e49 = aa_1;
                let _e50 = dCurve_2;
                covCurve = (1f - smoothstep(-(_e47), _e49, _e50));
            }
        } else {
            let _e53 = render_3;
            if (_e53 == 3i) {
                {
                    let _e57 = aa_1;
                    let _e59 = aa_1;
                    let _e60 = dCurve_2;
                    covCurve = (1f - smoothstep(-(_e57), _e59, _e60));
                    let _e64 = lineHalf_1;
                    let _e65 = aa_1;
                    let _e67 = lineHalf_1;
                    let _e68 = aa_1;
                    let _e70 = dCurve_2;
                    covB = (1f - smoothstep((_e64 - _e65), (_e67 + _e68), abs(_e70)));
                }
            } else {
                let _e74 = render_3;
                if (_e74 == 4i) {
                    {
                        let _e78 = curveHalf_1;
                        let _e79 = aa_1;
                        let _e81 = curveHalf_1;
                        let _e82 = aa_1;
                        let _e84 = dCurve_2;
                        outline = (1f - smoothstep((_e78 - _e79), (_e81 + _e82), abs(_e84)));
                        let _e90 = vb_1;
                        hs = (0.025f * _e90);
                        let _e93 = u_7;
                        let _e95 = u_7;
                        t_2 = (_e93.x - _e95.y);
                        let _e99 = t_2;
                        let _e100 = t_2;
                        let _e101 = hs;
                        let _e106 = hs;
                        hd = (abs((_e99 - (floor(((_e100 / _e101) + 0.5f)) * _e106))) / 1.4142135f);
                        let _e113 = dCurve_2;
                        if (_e113 < 0f) {
                            let _e117 = curveHalf_1;
                            let _e118 = aa_1;
                            let _e120 = curveHalf_1;
                            let _e121 = aa_1;
                            let _e123 = hd;
                            local_1 = (1f - smoothstep((_e117 - _e118), (_e120 + _e121), _e123));
                        } else {
                            local_1 = 0f;
                        }
                        let _e128 = local_1;
                        hatch = _e128;
                        let _e130 = outline;
                        let _e131 = hatch;
                        covCurve = max(_e130, _e131);
                    }
                } else {
                    {
                        let _e134 = curveHalf_1;
                        let _e135 = aa_1;
                        let _e137 = curveHalf_1;
                        let _e138 = aa_1;
                        let _e140 = dCurve_2;
                        covCurve = (1f - smoothstep((_e134 - _e135), (_e137 + _e138), _e140));
                        let _e143 = curveHalf_1;
                        dotR = (_e143 * 2.5f);
                        let _e147 = covCurve;
                        let _e149 = dotR;
                        let _e150 = aa_1;
                        let _e152 = dotR;
                        let _e153 = aa_1;
                        let _e155 = dDot_2;
                        covCurve = max(_e147, (1f - smoothstep((_e149 - _e150), (_e152 + _e153), _e155)));
                    }
                }
            }
        }
    }
    let _e159 = covCurve;
    let _e160 = covB;
    return vec2<f32>(_e159, _e160);
}

fn graphCurveYAt(mode_6: i32, render_4: i32, x_3: f32, ct_4: mat3x3<f32>, minorX_2: f32, Lx_2: f32) -> f32 {
    var mode_7: i32;
    var render_5: i32;
    var x_4: f32;
    var ct_5: mat3x3<f32>;
    var minorX_3: f32;
    var Lx_3: f32;
    var xa_2: f32;

    mode_7 = mode_6;
    render_5 = render_4;
    x_4 = x_3;
    ct_5 = ct_4;
    minorX_3 = minorX_2;
    Lx_3 = Lx_2;
    let _e18 = render_5;
    if (_e18 >= 5i) {
        {
            let _e21 = x_4;
            let _e22 = Lx_3;
            let _e25 = Lx_3;
            xa_2 = (floor((_e21 / _e22)) * _e25);
            let _e28 = mode_7;
            let _e29 = xa_2;
            let _e30 = ct_5;
            let _e31 = graphCurveEval(_e28, _e29, _e30);
            let _e32 = mode_7;
            let _e33 = xa_2;
            let _e34 = Lx_3;
            let _e36 = ct_5;
            let _e37 = graphCurveEval(_e32, (_e33 + _e34), _e36);
            let _e38 = x_4;
            let _e39 = xa_2;
            let _e41 = Lx_3;
            return mix(_e31, _e37, ((_e38 - _e39) / _e41));
        }
    } else {
        let _e44 = render_5;
        let _e47 = render_5;
        if ((_e44 >= 2i) && (_e47 <= 4i)) {
            {
                let _e51 = mode_7;
                let _e52 = x_4;
                let _e53 = minorX_3;
                let _e58 = minorX_3;
                let _e60 = ct_5;
                let _e61 = graphCurveEval(_e51, (floor(((_e52 / _e53) + 0.5f)) * _e58), _e60);
                return _e61;
            }
        }
    }
    let _e62 = mode_7;
    let _e63 = x_4;
    let _e64 = ct_5;
    let _e65 = graphCurveEval(_e62, _e63, _e64);
    return _e65;
}

fn ndfCharForSlot(slot: i32, nint: i32, neg: bool, decimals: i32, ipart: f32, av: f32) -> i32 {
    var slot_1: i32;
    var nint_1: i32;
    var neg_1: bool;
    var decimals_1: i32;
    var ipart_1: f32;
    var av_1: f32;
    var local_2: i32;
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
        local_2 = 1i;
    } else {
        local_2 = 0i;
    }
    let _e33 = local_2;
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
    var m_3: i32;
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
    m_3 = _e21;
    let _e34 = m_3;
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
    let _e50 = m_3;
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
    let _e65 = m_3;
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
    let _e80 = m_3;
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
    let _e96 = m_3;
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
    let _e113 = m_3;
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
    let _e130 = m_3;
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

fn graphNumDist(rel: vec2<f32>, value: i32, font: i32, gscale: f32) -> f32 {
    var rel_1: vec2<f32>;
    var value_1: i32;
    var font_1: i32;
    var gscale_1: f32;
    var neg_2: bool;
    var local_3: i32;
    var av_2: i32;
    var nint_2: i32 = 1i;
    var tt: i32;
    var i: i32 = 0i;
    var local_4: i32;
    var ng: i32;
    var gadv: f32 = 0.88f;
    var w: f32;
    var x_5: f32;
    var dx: f32;
    var dy: f32;
    var lx: f32;
    var slot_2: i32;
    var ch_6: i32;
    var gp: vec2<f32>;
    var local_5: f32;

    rel_1 = rel;
    value_1 = value;
    font_1 = font;
    gscale_1 = gscale;
    let _e14 = value_1;
    neg_2 = (_e14 < 0i);
    let _e18 = neg_2;
    if _e18 {
        let _e19 = value_1;
        local_3 = -(_e19);
    } else {
        let _e21 = value_1;
        local_3 = _e21;
    }
    let _e23 = local_3;
    av_2 = _e23;
    let _e27 = av_2;
    tt = _e27;
    loop {
        let _e31 = i;
        if !((_e31 < 6i)) {
            break;
        }
        {
            let _e38 = tt;
            if (_e38 >= 10i) {
                {
                    let _e41 = tt;
                    tt = (_e41 / 10i);
                    let _e44 = nint_2;
                    nint_2 = (_e44 + 1i);
                }
            }
        }
        continuing {
            let _e35 = i;
            i = (_e35 + 1i);
        }
    }
    let _e47 = nint_2;
    let _e48 = neg_2;
    if _e48 {
        local_4 = 1i;
    } else {
        local_4 = 0i;
    }
    let _e52 = local_4;
    ng = (_e47 + _e52);
    let _e57 = ng;
    let _e59 = gadv;
    let _e61 = gscale_1;
    w = ((f32(_e57) * _e59) * _e61);
    let _e64 = rel_1;
    let _e66 = w;
    x_5 = (_e64.x + (_e66 * 0.5f));
    let _e71 = x_5;
    let _e73 = x_5;
    let _e74 = w;
    dx = max(max(-(_e71), (_e73 - _e74)), 0f);
    let _e80 = rel_1;
    let _e84 = gscale_1;
    dy = max((abs(_e80.y) - (0.75f * _e84)), 0f);
    let _e90 = dx;
    let _e93 = dy;
    if ((_e90 > 0f) || (_e93 > 0f)) {
        let _e97 = dx;
        let _e98 = dy;
        let _e102 = gscale_1;
        return (length(vec2<f32>(_e97, _e98)) + (0.35f * _e102));
    }
    let _e105 = x_5;
    let _e106 = gscale_1;
    lx = (_e105 / _e106);
    let _e109 = lx;
    let _e110 = gadv;
    slot_2 = i32(floor((_e109 / _e110)));
    let _e115 = slot_2;
    let _e118 = slot_2;
    let _e119 = ng;
    if ((_e115 < 0i) || (_e118 >= _e119)) {
        let _e123 = gscale_1;
        return (0.35f * _e123);
    }
    let _e125 = slot_2;
    let _e126 = nint_2;
    let _e127 = neg_2;
    let _e129 = av_2;
    let _e131 = av_2;
    let _e133 = ndfCharForSlot(_e125, _e126, _e127, 0i, f32(_e129), f32(_e131));
    ch_6 = _e133;
    let _e135 = ch_6;
    if (_e135 == 12i) {
        let _e139 = gscale_1;
        return (0.35f * _e139);
    }
    let _e141 = lx;
    let _e142 = slot_2;
    let _e146 = gadv;
    let _e149 = rel_1;
    let _e152 = gscale_1;
    gp = vec2<f32>((_e141 - ((f32(_e142) + 0.5f) * _e146)), (-(_e149.y) / _e152));
    let _e156 = font_1;
    if (_e156 == 0i) {
        let _e159 = ch_6;
        let _e160 = gp;
        let _e161 = ndfDigital(_e159, _e160);
        local_5 = _e161;
    } else {
        let _e162 = ch_6;
        let _e163 = gp;
        let _e164 = ndfCurved(_e162, _e163);
        local_5 = _e164;
    }
    let _e166 = local_5;
    let _e167 = gscale_1;
    return (_e166 * _e167);
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

fn graph(uv_1: vec2<f32>, outPos: vec2<f32>, axisMode: i32, majorGrid: i32, minorGrid: i32, font_2: i32, size: f32, shapeAspectRatio: f32, color1_: vec4<f32>, curveMode: i32, curveRender: i32, curveColor: vec4<f32>, curveTransform: mat3x3<f32>, curveThickness: f32, curveMode2_: i32, curveRender2_: i32, curveColor2_: vec4<f32>, curveTransform2_: mat3x3<f32>, curveThickness2_: f32, diffMode: i32, diffColor: vec4<f32>, glow: f32, thickness: f32, modelTransform: mat3x3<f32>, axisTransform: mat3x3<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_2: vec2<f32>;
    var outPos_1: vec2<f32>;
    var axisMode_1: i32;
    var majorGrid_1: i32;
    var minorGrid_1: i32;
    var font_3: i32;
    var size_1: f32;
    var shapeAspectRatio_1: f32;
    var color1_1: vec4<f32>;
    var curveMode_1: i32;
    var curveRender_1: i32;
    var curveColor_1: vec4<f32>;
    var curveTransform_1: mat3x3<f32>;
    var curveThickness_1: f32;
    var curveMode2_1: i32;
    var curveRender2_1: i32;
    var curveColor2_1: vec4<f32>;
    var curveTransform2_1: mat3x3<f32>;
    var curveThickness2_1: f32;
    var diffMode_1: i32;
    var diffColor_1: vec4<f32>;
    var glow_1: f32;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var axisTransform_1: mat3x3<f32>;
    var outDim_1: vec2<f32>;
    var im: mat3x3<f32>;
    var u_8: vec2<f32>;
    var bkg_2: vec4<f32>;
    var pixel: f32;
    var aa_2: f32;
    var ar: f32;
    var showX: bool;
    var showY: bool;
    var showNum: bool;
    var largeTicks: bool;
    var showBorder: bool;
    var modelScale: f32;
    var vb_2: f32;
    var lineHalf_2: f32;
    var gridHalf: f32;
    var digitHalf: f32;
    var gscale_2: f32;
    var gadv_1: f32 = 0.88f;
    var glyphHalf: f32;
    var local_6: f32;
    var glowReach: f32;
    var gap: f32;
    var tickMinor: f32;
    var tickMajor: f32;
    var atF_2: mat3x3<f32>;
    var iat: mat3x3<f32>;
    var dpos_2: vec2<f32>;
    var sxLen: f32;
    var syLen: f32;
    var dirX: vec2<f32>;
    var dirY: vec2<f32>;
    var obox: vec2<f32>;
    var minLabelV: f32;
    var unitVx: f32;
    var unitVy: f32;
    var rawx: f32;
    var bx: f32;
    var mxn: f32;
    var local_7: f32;
    var local_8: f32;
    var local_9: f32;
    var Lx_4: f32;
    var rawy: f32;
    var by: f32;
    var myn: f32;
    var local_10: f32;
    var local_11: f32;
    var local_12: f32;
    var Ly: f32;
    var minorX_4: f32;
    var minorY: f32;
    var inBox: bool;
    var dLine: f32 = 1000000000f;
    var dGrid: f32 = 1000000000f;
    var covGrid: f32 = 0f;
    var dDigit: f32 = 1000000000f;
    var covDiff: f32 = 0f;
    var level: i32 = 0i;
    var local_13: i32;
    var el: i32;
    var local_14: f32;
    var gLx: f32;
    var local_15: f32;
    var gLy: f32;
    var d_3: f32;
    var w_1: f32;
    var dx_1: f32;
    var dy_1: f32;
    var local_16: f32;
    var local_17: f32;
    var local_18: f32;
    var local_19: f32;
    var local_20: f32;
    var arm: f32;
    var ci: vec2<f32>;
    var ci_1: vec2<f32>;
    var local_21: f32;
    var ci_2: vec2<f32>;
    var local_22: f32;
    var xc_1: f32;
    var a_3: f32;
    var b_3: f32;
    var c0_1: vec2<f32>;
    var c1_1: vec2<f32>;
    var lo_1: vec2<f32>;
    var hi_1: vec2<f32>;
    var ctr_1: vec2<f32>;
    var hlf_1: vec2<f32>;
    var q_2: vec2<f32>;
    var dBar: f32;
    var a_4: f32;
    var b_4: f32;
    var dBand: f32;
    var fill: f32;
    var dhh: f32;
    var t_3: f32;
    var hd_1: f32;
    var local_23: f32;
    var kx_2: f32;
    var atOrigin: bool;
    var c_1: vec2<f32>;
    var major: bool;
    var local_24: f32;
    var tl: f32;
    var ky_1: f32;
    var atOrigin_1: bool;
    var c_2: vec2<f32>;
    var major_1: bool;
    var local_25: f32;
    var tl_1: f32;
    var rowY: f32;
    var k0_: f32;
    var dk: i32 = -1i;
    var kx_3: f32;
    var ival: i32;
    var c_3: vec2<f32>;
    var k0_1: f32;
    var dk_1: i32 = -1i;
    var ky_2: f32;
    var ival_1: i32;
    var c_4: vec2<f32>;
    var ln: bool;
    var local_26: i32;
    var av_3: i32;
    var nint_3: i32;
    var tt_1: i32;
    var i_1: i32;
    var local_27: i32;
    var ng_1: i32;
    var labelW: f32;
    var centerX: f32;
    var covCurve_1: f32 = 0f;
    var covCB: f32 = 0f;
    var dC: f32 = 1000000000f;
    var curveHalf_2: f32;
    var dd_1: vec2<f32>;
    var cc: vec2<f32>;
    var covCurve2_: f32 = 0f;
    var covCB2_: f32 = 0f;
    var dC2_: f32 = 1000000000f;
    var curveHalf2_: f32;
    var dd_2: vec2<f32>;
    var cc_1: vec2<f32>;
    var local_28: f32;
    var covLine: f32;
    var covDigit: f32;
    var cov: f32;
    var local_29: f32;
    var dmin: f32;
    var local_30: f32;
    var g: f32;
    var local_31: f32;
    var gc1_: f32;
    var local_32: f32;
    var gc2_: f32;
    var outc: vec4<f32>;

    uv_2 = uv_1;
    outPos_1 = outPos;
    axisMode_1 = axisMode;
    majorGrid_1 = majorGrid;
    minorGrid_1 = minorGrid;
    font_3 = font_2;
    size_1 = size;
    shapeAspectRatio_1 = shapeAspectRatio;
    color1_1 = color1_;
    curveMode_1 = curveMode;
    curveRender_1 = curveRender;
    curveColor_1 = curveColor;
    curveTransform_1 = curveTransform;
    curveThickness_1 = curveThickness;
    curveMode2_1 = curveMode2_;
    curveRender2_1 = curveRender2_;
    curveColor2_1 = curveColor2_;
    curveTransform2_1 = curveTransform2_;
    curveThickness2_1 = curveThickness2_;
    diffMode_1 = diffMode;
    diffColor_1 = diffColor;
    glow_1 = glow;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    axisTransform_1 = axisTransform;
    outDim_1 = outDim;
    let _e58 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e58);
    let _e61 = im;
    let _e62 = uv_2;
    let _e63 = tf(_e61, _e62);
    u_8 = _e63;
    let _e65 = uv_2;
    let _e69 = global.U[0];
    let _e72 = uv_2;
    let _e81 = textureSample(t_source, samp, ((vec2<f32>((_e65.x / _e69.x), _e72.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e81;
    let _e84 = outDim_1;
    pixel = (2f / _e84.y);
    let _e88 = im;
    let _e89 = uv_2;
    let _e90 = pixel;
    let _e94 = tf(_e88, (_e89 + vec2<f32>(_e90, 0f)));
    let _e95 = u_8;
    aa_2 = (length((_e94 - _e95)) * 0.75f);
    let _e101 = shapeAspectRatio_1;
    ar = _e101;
    let _e103 = axisMode_1;
    showX = ((_e103 & 1i) != 0i);
    let _e109 = axisMode_1;
    showY = ((_e109 & 2i) != 0i);
    let _e115 = axisMode_1;
    showNum = ((_e115 & 4i) != 0i);
    let _e121 = axisMode_1;
    largeTicks = ((_e121 & 8i) != 0i);
    let _e127 = axisMode_1;
    showBorder = ((_e127 & 16i) != 0i);
    let _e137 = modelTransform_1[0][0];
    let _e142 = modelTransform_1[0][1];
    modelScale = length(vec2<f32>(_e137, _e142));
    let _e146 = modelScale;
    if (_e146 < 0.00001f) {
        modelScale = 0.00001f;
    }
    let _e151 = modelScale;
    vb_2 = (1f / _e151);
    let _e154 = thickness_1;
    let _e157 = vb_2;
    lineHalf_2 = ((_e154 * 0.025f) * _e157);
    let _e160 = lineHalf_2;
    gridHalf = (_e160 * 0.5f);
    let _e165 = vb_2;
    digitHalf = (0.003f * _e165);
    let _e169 = vb_2;
    let _e171 = size_1;
    gscale_2 = ((0.042f * _e169) * _e171);
    let _e177 = gscale_2;
    glyphHalf = (0.7f * _e177);
    let _e180 = glow_1;
    if (_e180 > 0.006f) {
        let _e183 = glow_1;
        local_6 = min((log((_e183 / 0.006f)) * 0.125f), 1f);
    } else {
        local_6 = 0f;
    }
    let _e193 = local_6;
    glowReach = _e193;
    let _e196 = vb_2;
    let _e198 = size_1;
    gap = ((0.012f * _e196) * _e198);
    let _e202 = vb_2;
    let _e204 = size_1;
    tickMinor = ((0.014f * _e202) * _e204);
    let _e208 = vb_2;
    let _e210 = size_1;
    tickMajor = ((0.028f * _e208) * _e210);
    let _e217 = axisTransform_1[0][0];
    let _e222 = axisTransform_1[0][1];
    let _e227 = axisTransform_1[0][2];
    let _e228 = vec3<f32>(_e217, _e222, _e227);
    let _e233 = axisTransform_1[1][0];
    let _e239 = axisTransform_1[1][1];
    let _e245 = axisTransform_1[1][2];
    let _e247 = vec3<f32>(-(_e233), -(_e239), -(_e245));
    let _e252 = axisTransform_1[2][0];
    let _e257 = axisTransform_1[2][1];
    let _e262 = axisTransform_1[2][2];
    let _e263 = vec3<f32>(_e252, _e257, _e262);
    atF_2 = mat3x3<f32>(vec3<f32>(_e228.x, _e228.y, _e228.z), vec3<f32>(_e247.x, _e247.y, _e247.z), vec3<f32>(_e263.x, _e263.y, _e263.z));
    let _e278 = atF_2;
    iat = _naga_inverse_3x3_f32(_e278);
    let _e281 = iat;
    let _e282 = u_8;
    let _e283 = tf(_e281, _e282);
    dpos_2 = _e283;
    let _e289 = atF_2[0][0];
    let _e294 = atF_2[0][1];
    sxLen = length(vec2<f32>(_e289, _e294));
    let _e302 = atF_2[1][0];
    let _e307 = atF_2[1][1];
    syLen = length(vec2<f32>(_e302, _e307));
    let _e311 = sxLen;
    if (_e311 < 0.00001f) {
        sxLen = 1f;
    }
    let _e315 = syLen;
    if (_e315 < 0.00001f) {
        syLen = 1f;
    }
    let _e323 = atF_2[0][0];
    let _e328 = atF_2[0][1];
    let _e330 = sxLen;
    dirX = (vec2<f32>(_e323, _e328) / vec2(_e330));
    let _e338 = atF_2[1][0];
    let _e343 = atF_2[1][1];
    let _e345 = syLen;
    dirY = (vec2<f32>(_e338, _e343) / vec2(_e345));
    let _e349 = atF_2;
    let _e353 = tf(_e349, vec2<f32>(0f, 0f));
    obox = _e353;
    let _e356 = size_1;
    minLabelV = max((0.3f * _e356), 0.04f);
    let _e361 = sxLen;
    let _e362 = modelScale;
    unitVx = (_e361 * _e362);
    let _e365 = syLen;
    let _e366 = modelScale;
    unitVy = (_e365 * _e366);
    let _e369 = minLabelV;
    let _e370 = unitVx;
    rawx = (_e369 / max(_e370, 0.000001f));
    let _e376 = rawx;
    bx = pow(10f, floor((log(max(_e376, 1f)) / 2.3025851f)));
    let _e386 = rawx;
    let _e387 = bx;
    mxn = (_e386 / _e387);
    let _e390 = mxn;
    if (_e390 <= 1f) {
        local_9 = 1f;
    } else {
        let _e394 = mxn;
        if (_e394 <= 2f) {
            local_8 = 2f;
        } else {
            let _e398 = mxn;
            if (_e398 <= 5f) {
                local_7 = 5f;
            } else {
                local_7 = 10f;
            }
            let _e404 = local_7;
            local_8 = _e404;
        }
        let _e406 = local_8;
        local_9 = _e406;
    }
    let _e408 = local_9;
    let _e409 = bx;
    Lx_4 = max((_e408 * _e409), 1f);
    let _e414 = minLabelV;
    let _e415 = unitVy;
    rawy = (_e414 / max(_e415, 0.000001f));
    let _e421 = rawy;
    by = pow(10f, floor((log(max(_e421, 1f)) / 2.3025851f)));
    let _e431 = rawy;
    let _e432 = by;
    myn = (_e431 / _e432);
    let _e435 = myn;
    if (_e435 <= 1f) {
        local_12 = 1f;
    } else {
        let _e439 = myn;
        if (_e439 <= 2f) {
            local_11 = 2f;
        } else {
            let _e443 = myn;
            if (_e443 <= 5f) {
                local_10 = 5f;
            } else {
                local_10 = 10f;
            }
            let _e449 = local_10;
            local_11 = _e449;
        }
        let _e451 = local_11;
        local_12 = _e451;
    }
    let _e453 = local_12;
    let _e454 = by;
    Ly = max((_e453 * _e454), 1f);
    let _e459 = Lx_4;
    minorX_4 = (_e459 / 5f);
    let _e463 = Ly;
    minorY = (_e463 / 5f);
    let _e467 = u_8;
    let _e471 = aa_2;
    let _e474 = u_8;
    let _e477 = ar;
    let _e478 = aa_2;
    inBox = ((abs(_e467.x) <= (1f + _e471)) && (abs(_e474.y) <= (_e477 + _e478)));
    let _e493 = showBorder;
    if _e493 {
        {
            let _e494 = dLine;
            let _e495 = u_8;
            let _e498 = ar;
            let _e502 = ar;
            let _e505 = sdSegment(_e495, vec2<f32>(-1f, -(_e498)), vec2<f32>(1f, -(_e502)));
            dLine = min(_e494, _e505);
            let _e507 = dLine;
            let _e508 = u_8;
            let _e511 = ar;
            let _e514 = ar;
            let _e516 = sdSegment(_e508, vec2<f32>(-1f, _e511), vec2<f32>(1f, _e514));
            dLine = min(_e507, _e516);
            let _e518 = dLine;
            let _e519 = u_8;
            let _e522 = ar;
            let _e527 = ar;
            let _e529 = sdSegment(_e519, vec2<f32>(-1f, -(_e522)), vec2<f32>(-1f, _e527));
            dLine = min(_e518, _e529);
            let _e531 = dLine;
            let _e532 = u_8;
            let _e534 = ar;
            let _e538 = ar;
            let _e540 = sdSegment(_e532, vec2<f32>(1f, -(_e534)), vec2<f32>(1f, _e538));
            dLine = min(_e531, _e540);
        }
    }
    let _e542 = inBox;
    if _e542 {
        {
            loop {
                let _e545 = level;
                if !((_e545 < 2i)) {
                    break;
                }
                {
                    let _e552 = level;
                    if (_e552 == 0i) {
                        let _e555 = majorGrid_1;
                        local_13 = _e555;
                    } else {
                        let _e556 = minorGrid_1;
                        local_13 = _e556;
                    }
                    let _e558 = local_13;
                    el = _e558;
                    let _e560 = el;
                    if (_e560 == 0i) {
                        continue;
                    }
                    let _e563 = level;
                    let _e566 = el;
                    let _e569 = el;
                    let _e573 = el;
                    if ((_e563 == 1i) && (((_e566 == 2i) || (_e569 == 6i)) || (_e573 == 7i))) {
                        continue;
                    }
                    let _e578 = level;
                    if (_e578 == 0i) {
                        let _e581 = Lx_4;
                        local_14 = _e581;
                    } else {
                        let _e582 = minorX_4;
                        local_14 = _e582;
                    }
                    let _e584 = local_14;
                    gLx = _e584;
                    let _e586 = level;
                    if (_e586 == 0i) {
                        let _e589 = Ly;
                        local_15 = _e589;
                    } else {
                        let _e590 = minorY;
                        local_15 = _e590;
                    }
                    let _e592 = local_15;
                    gLy = _e592;
                    let _e595 = gridHalf;
                    w_1 = _e595;
                    let _e597 = el;
                    let _e600 = el;
                    if ((_e597 == 1i) || (_e600 == 2i)) {
                        {
                            let _e604 = dpos_2;
                            let _e606 = dpos_2;
                            let _e608 = gLx;
                            let _e613 = gLx;
                            let _e617 = sxLen;
                            dx_1 = (abs((_e604.x - (floor(((_e606.x / _e608) + 0.5f)) * _e613))) * _e617);
                            let _e620 = dpos_2;
                            let _e622 = dpos_2;
                            let _e624 = gLy;
                            let _e629 = gLy;
                            let _e633 = syLen;
                            dy_1 = (abs((_e620.y - (floor(((_e622.y / _e624) + 0.5f)) * _e629))) * _e633);
                            let _e636 = dx_1;
                            let _e637 = dy_1;
                            d_3 = min(_e636, _e637);
                            let _e639 = el;
                            if (_e639 == 2i) {
                                let _e642 = lineHalf_2;
                                local_16 = _e642;
                            } else {
                                let _e643 = gridHalf;
                                local_16 = _e643;
                            }
                            let _e645 = local_16;
                            w_1 = _e645;
                        }
                    } else {
                        let _e646 = el;
                        let _e649 = el;
                        if ((_e646 >= 3i) && (_e649 <= 7i)) {
                            {
                                let _e653 = el;
                                if (_e653 == 3i) {
                                    local_20 = 0.005f;
                                } else {
                                    let _e657 = el;
                                    if (_e657 == 4i) {
                                        local_19 = 0.01f;
                                    } else {
                                        let _e661 = el;
                                        if (_e661 == 5i) {
                                            local_18 = 0.02f;
                                        } else {
                                            let _e665 = el;
                                            if (_e665 == 6i) {
                                                local_17 = 0.045f;
                                            } else {
                                                local_17 = 0.09f;
                                            }
                                            let _e671 = local_17;
                                            local_18 = _e671;
                                        }
                                        let _e673 = local_18;
                                        local_19 = _e673;
                                    }
                                    let _e675 = local_19;
                                    local_20 = _e675;
                                }
                                let _e677 = local_20;
                                let _e678 = vb_2;
                                arm = (_e677 * _e678);
                                let _e681 = atF_2;
                                let _e682 = dpos_2;
                                let _e684 = gLx;
                                let _e689 = gLx;
                                let _e691 = dpos_2;
                                let _e693 = gLy;
                                let _e698 = gLy;
                                let _e701 = tf(_e681, vec2<f32>((floor(((_e682.x / _e684) + 0.5f)) * _e689), (floor(((_e691.y / _e693) + 0.5f)) * _e698)));
                                ci = _e701;
                                let _e703 = u_8;
                                let _e704 = ci;
                                let _e705 = dirY;
                                let _e706 = arm;
                                let _e709 = ci;
                                let _e710 = dirY;
                                let _e711 = arm;
                                let _e714 = sdSegment(_e703, (_e704 - (_e705 * _e706)), (_e709 + (_e710 * _e711)));
                                let _e715 = u_8;
                                let _e716 = ci;
                                let _e717 = dirX;
                                let _e718 = arm;
                                let _e721 = ci;
                                let _e722 = dirX;
                                let _e723 = arm;
                                let _e726 = sdSegment(_e715, (_e716 - (_e717 * _e718)), (_e721 + (_e722 * _e723)));
                                d_3 = min(_e714, _e726);
                                let _e728 = gridHalf;
                                w_1 = _e728;
                            }
                        } else {
                            let _e729 = el;
                            let _e732 = el;
                            if ((_e729 == 8i) || (_e732 == 9i)) {
                                {
                                    let _e736 = atF_2;
                                    let _e737 = dpos_2;
                                    let _e739 = gLx;
                                    let _e744 = gLx;
                                    let _e746 = dpos_2;
                                    let _e748 = gLy;
                                    let _e753 = gLy;
                                    let _e756 = tf(_e736, vec2<f32>((floor(((_e737.x / _e739) + 0.5f)) * _e744), (floor(((_e746.y / _e748) + 0.5f)) * _e753)));
                                    ci_1 = _e756;
                                    let _e758 = u_8;
                                    let _e759 = ci_1;
                                    d_3 = length((_e758 - _e759));
                                    let _e762 = el;
                                    if (_e762 == 8i) {
                                        let _e765 = lineHalf_2;
                                        local_21 = _e765;
                                    } else {
                                        let _e766 = gridHalf;
                                        local_21 = _e766;
                                    }
                                    let _e768 = local_21;
                                    w_1 = _e768;
                                }
                            } else {
                                {
                                    let _e769 = atF_2;
                                    let _e770 = dpos_2;
                                    let _e772 = gLx;
                                    let _e777 = gLx;
                                    let _e779 = dpos_2;
                                    let _e781 = gLy;
                                    let _e786 = gLy;
                                    let _e789 = tf(_e769, vec2<f32>((floor(((_e770.x / _e772) + 0.5f)) * _e777), (floor(((_e779.y / _e781) + 0.5f)) * _e786)));
                                    ci_2 = _e789;
                                    let _e791 = u_8;
                                    let _e793 = ci_2;
                                    let _e797 = u_8;
                                    let _e799 = ci_2;
                                    d_3 = max(abs((_e791.x - _e793.x)), abs((_e797.y - _e799.y)));
                                    let _e804 = el;
                                    if (_e804 == 10i) {
                                        let _e807 = lineHalf_2;
                                        local_22 = _e807;
                                    } else {
                                        let _e808 = gridHalf;
                                        local_22 = _e808;
                                    }
                                    let _e810 = local_22;
                                    w_1 = _e810;
                                }
                            }
                        }
                    }
                    let _e811 = covGrid;
                    let _e813 = w_1;
                    let _e814 = aa_2;
                    let _e816 = w_1;
                    let _e817 = aa_2;
                    let _e819 = d_3;
                    covGrid = max(_e811, (1f - smoothstep((_e813 - _e814), (_e816 + _e817), _e819)));
                    let _e823 = dGrid;
                    let _e824 = d_3;
                    dGrid = min(_e823, _e824);
                }
                continuing {
                    let _e549 = level;
                    level = (_e549 + 1i);
                }
            }
            let _e826 = diffMode_1;
            let _e829 = curveMode_1;
            let _e833 = curveMode2_1;
            if (((_e826 >= 1i) && (_e829 >= 1i)) && (_e833 >= 1i)) {
                {
                    let _e837 = diffMode_1;
                    if (_e837 == 3i) {
                        {
                            let _e840 = dpos_2;
                            let _e842 = minorX_4;
                            let _e847 = minorX_4;
                            xc_1 = (floor(((_e840.x / _e842) + 0.5f)) * _e847);
                            let _e850 = curveMode_1;
                            let _e851 = curveRender_1;
                            let _e852 = xc_1;
                            let _e853 = curveTransform_1;
                            let _e854 = minorX_4;
                            let _e855 = Lx_4;
                            let _e856 = graphCurveYAt(_e850, _e851, _e852, _e853, _e854, _e855);
                            a_3 = _e856;
                            let _e858 = curveMode2_1;
                            let _e859 = curveRender2_1;
                            let _e860 = xc_1;
                            let _e861 = curveTransform2_1;
                            let _e862 = minorX_4;
                            let _e863 = Lx_4;
                            let _e864 = graphCurveYAt(_e858, _e859, _e860, _e861, _e862, _e863);
                            b_3 = _e864;
                            let _e866 = atF_2;
                            let _e867 = xc_1;
                            let _e868 = minorX_4;
                            let _e872 = a_3;
                            let _e873 = b_3;
                            let _e876 = tf(_e866, vec2<f32>((_e867 - (_e868 * 0.4f)), min(_e872, _e873)));
                            c0_1 = _e876;
                            let _e878 = atF_2;
                            let _e879 = xc_1;
                            let _e880 = minorX_4;
                            let _e884 = a_3;
                            let _e885 = b_3;
                            let _e888 = tf(_e878, vec2<f32>((_e879 + (_e880 * 0.4f)), max(_e884, _e885)));
                            c1_1 = _e888;
                            let _e890 = c0_1;
                            let _e891 = c1_1;
                            lo_1 = min(_e890, _e891);
                            let _e894 = c0_1;
                            let _e895 = c1_1;
                            hi_1 = max(_e894, _e895);
                            let _e898 = lo_1;
                            let _e899 = hi_1;
                            ctr_1 = ((_e898 + _e899) * 0.5f);
                            let _e904 = hi_1;
                            let _e905 = lo_1;
                            hlf_1 = ((_e904 - _e905) * 0.5f);
                            let _e910 = u_8;
                            let _e911 = ctr_1;
                            let _e914 = hlf_1;
                            q_2 = (abs((_e910 - _e911)) - _e914);
                            let _e917 = q_2;
                            let _e922 = q_2;
                            let _e924 = q_2;
                            dBar = (length(max(_e917, vec2(0f))) + min(max(_e922.x, _e924.y), 0f));
                            let _e932 = aa_2;
                            let _e934 = aa_2;
                            let _e935 = dBar;
                            covDiff = (1f - smoothstep(-(_e932), _e934, _e935));
                        }
                    } else {
                        {
                            let _e938 = curveMode_1;
                            let _e939 = curveRender_1;
                            let _e940 = dpos_2;
                            let _e942 = curveTransform_1;
                            let _e943 = minorX_4;
                            let _e944 = Lx_4;
                            let _e945 = graphCurveYAt(_e938, _e939, _e940.x, _e942, _e943, _e944);
                            a_4 = _e945;
                            let _e947 = curveMode2_1;
                            let _e948 = curveRender2_1;
                            let _e949 = dpos_2;
                            let _e951 = curveTransform2_1;
                            let _e952 = minorX_4;
                            let _e953 = Lx_4;
                            let _e954 = graphCurveYAt(_e947, _e948, _e949.x, _e951, _e952, _e953);
                            b_4 = _e954;
                            let _e956 = a_4;
                            let _e957 = b_4;
                            let _e959 = dpos_2;
                            let _e962 = dpos_2;
                            let _e964 = a_4;
                            let _e965 = b_4;
                            let _e969 = syLen;
                            dBand = (max((min(_e956, _e957) - _e959.y), (_e962.y - max(_e964, _e965))) * _e969);
                            let _e973 = aa_2;
                            let _e975 = aa_2;
                            let _e976 = dBand;
                            fill = (1f - smoothstep(-(_e973), _e975, _e976));
                            let _e980 = diffMode_1;
                            if (_e980 == 2i) {
                                {
                                    let _e983 = fill;
                                    covDiff = _e983;
                                }
                            } else {
                                {
                                    let _e985 = vb_2;
                                    dhh = (0.004f * _e985);
                                    let _e988 = u_8;
                                    let _e990 = u_8;
                                    t_3 = (_e988.x - _e990.y);
                                    let _e994 = t_3;
                                    let _e995 = t_3;
                                    let _e997 = vb_2;
                                    let _e1004 = vb_2;
                                    hd_1 = (abs((_e994 - (floor(((_e995 / (0.025f * _e997)) + 0.5f)) * (0.025f * _e1004)))) / 1.4142135f);
                                    let _e1012 = dBand;
                                    if (_e1012 < 0f) {
                                        let _e1016 = dhh;
                                        let _e1017 = aa_2;
                                        let _e1019 = dhh;
                                        let _e1020 = aa_2;
                                        let _e1022 = hd_1;
                                        local_23 = (1f - smoothstep((_e1016 - _e1017), (_e1019 + _e1020), _e1022));
                                    } else {
                                        local_23 = 0f;
                                    }
                                    let _e1027 = local_23;
                                    covDiff = _e1027;
                                }
                            }
                        }
                    }
                }
            }
            let _e1028 = showY;
            let _e1029 = obox;
            if (_e1028 && (abs(_e1029.x) <= 1f)) {
                let _e1035 = dLine;
                let _e1036 = dpos_2;
                let _e1039 = sxLen;
                dLine = min(_e1035, (abs(_e1036.x) * _e1039));
            }
            let _e1042 = showX;
            let _e1043 = obox;
            let _e1046 = ar;
            if (_e1042 && (abs(_e1043.y) <= _e1046)) {
                let _e1049 = dLine;
                let _e1050 = dpos_2;
                let _e1053 = syLen;
                dLine = min(_e1049, (abs(_e1050.y) * _e1053));
            }
            let _e1056 = showX;
            let _e1057 = obox;
            let _e1060 = ar;
            if (_e1056 && (abs(_e1057.y) <= _e1060)) {
                {
                    let _e1063 = dpos_2;
                    let _e1065 = minorX_4;
                    let _e1070 = minorX_4;
                    kx_2 = (floor(((_e1063.x / _e1065) + 0.5f)) * _e1070);
                    let _e1073 = kx_2;
                    atOrigin = (abs(_e1073) < 0.000001f);
                    let _e1078 = atOrigin;
                    let _e1080 = showY;
                    if (!(_e1078) || !(_e1080)) {
                        {
                            let _e1083 = atF_2;
                            let _e1084 = kx_2;
                            let _e1087 = tf(_e1083, vec2<f32>(_e1084, 0f));
                            c_1 = _e1087;
                            let _e1089 = atOrigin;
                            let _e1090 = largeTicks;
                            let _e1091 = kx_2;
                            let _e1092 = Lx_4;
                            let _e1094 = kx_2;
                            let _e1095 = Lx_4;
                            major = (_e1089 || (_e1090 && (abs(((_e1091 / _e1092) - floor(((_e1094 / _e1095) + 0.5f)))) < 0.01f)));
                            let _e1107 = major;
                            if _e1107 {
                                let _e1108 = tickMajor;
                                local_24 = _e1108;
                            } else {
                                let _e1109 = tickMinor;
                                local_24 = _e1109;
                            }
                            let _e1111 = local_24;
                            tl = _e1111;
                            let _e1113 = c_1;
                            if (abs(_e1113.x) <= 1f) {
                                let _e1118 = dLine;
                                let _e1119 = u_8;
                                let _e1120 = c_1;
                                let _e1121 = dirY;
                                let _e1122 = tl;
                                let _e1125 = c_1;
                                let _e1126 = dirY;
                                let _e1127 = tl;
                                let _e1130 = sdSegment(_e1119, (_e1120 - (_e1121 * _e1122)), (_e1125 + (_e1126 * _e1127)));
                                dLine = min(_e1118, _e1130);
                            }
                        }
                    }
                }
            }
            let _e1132 = showY;
            let _e1133 = obox;
            if (_e1132 && (abs(_e1133.x) <= 1f)) {
                {
                    let _e1139 = dpos_2;
                    let _e1141 = minorY;
                    let _e1146 = minorY;
                    ky_1 = (floor(((_e1139.y / _e1141) + 0.5f)) * _e1146);
                    let _e1149 = ky_1;
                    atOrigin_1 = (abs(_e1149) < 0.000001f);
                    let _e1154 = atOrigin_1;
                    let _e1156 = showX;
                    if (!(_e1154) || !(_e1156)) {
                        {
                            let _e1159 = atF_2;
                            let _e1161 = ky_1;
                            let _e1163 = tf(_e1159, vec2<f32>(0f, _e1161));
                            c_2 = _e1163;
                            let _e1165 = atOrigin_1;
                            let _e1166 = largeTicks;
                            let _e1167 = ky_1;
                            let _e1168 = Ly;
                            let _e1170 = ky_1;
                            let _e1171 = Ly;
                            major_1 = (_e1165 || (_e1166 && (abs(((_e1167 / _e1168) - floor(((_e1170 / _e1171) + 0.5f)))) < 0.01f)));
                            let _e1183 = major_1;
                            if _e1183 {
                                let _e1184 = tickMajor;
                                local_25 = _e1184;
                            } else {
                                let _e1185 = tickMinor;
                                local_25 = _e1185;
                            }
                            let _e1187 = local_25;
                            tl_1 = _e1187;
                            let _e1189 = c_2;
                            let _e1192 = ar;
                            if (abs(_e1189.y) <= _e1192) {
                                let _e1194 = dLine;
                                let _e1195 = u_8;
                                let _e1196 = c_2;
                                let _e1197 = dirX;
                                let _e1198 = tl_1;
                                let _e1201 = c_2;
                                let _e1202 = dirX;
                                let _e1203 = tl_1;
                                let _e1206 = sdSegment(_e1195, (_e1196 - (_e1197 * _e1198)), (_e1201 + (_e1202 * _e1203)));
                                dLine = min(_e1194, _e1206);
                            }
                        }
                    }
                }
            }
            let _e1208 = showNum;
            let _e1209 = showX;
            let _e1211 = obox;
            let _e1214 = ar;
            if ((_e1208 && _e1209) && (abs(_e1211.y) <= _e1214)) {
                {
                    let _e1217 = obox;
                    let _e1219 = tickMajor;
                    let _e1221 = glyphHalf;
                    let _e1223 = gap;
                    rowY = (((_e1217.y - _e1219) - _e1221) - _e1223);
                    let _e1226 = u_8;
                    let _e1228 = rowY;
                    let _e1231 = glyphHalf;
                    let _e1232 = glowReach;
                    if (abs((_e1226.y - _e1228)) < (_e1231 + _e1232)) {
                        {
                            let _e1235 = dpos_2;
                            let _e1237 = Lx_4;
                            k0_ = floor(((_e1235.x / _e1237) + 0.5f));
                            loop {
                                let _e1246 = dk;
                                if !((_e1246 <= 1i)) {
                                    break;
                                }
                                {
                                    let _e1253 = k0_;
                                    let _e1254 = dk;
                                    let _e1257 = Lx_4;
                                    kx_3 = ((_e1253 + f32(_e1254)) * _e1257);
                                    let _e1260 = kx_3;
                                    ival = i32(floor((_e1260 + 0.5f)));
                                    let _e1266 = ival;
                                    let _e1269 = showY;
                                    if ((_e1266 == 0i) && _e1269) {
                                        continue;
                                    }
                                    let _e1271 = atF_2;
                                    let _e1272 = kx_3;
                                    let _e1275 = tf(_e1271, vec2<f32>(_e1272, 0f));
                                    c_3 = _e1275;
                                    let _e1277 = c_3;
                                    if (abs(_e1277.x) > 1f) {
                                        continue;
                                    }
                                    let _e1282 = dDigit;
                                    let _e1283 = u_8;
                                    let _e1285 = c_3;
                                    let _e1288 = u_8;
                                    let _e1290 = rowY;
                                    let _e1293 = ival;
                                    let _e1294 = font_3;
                                    let _e1295 = gscale_2;
                                    let _e1296 = graphNumDist(vec2<f32>((_e1283.x - _e1285.x), (_e1288.y - _e1290)), _e1293, _e1294, _e1295);
                                    dDigit = min(_e1282, _e1296);
                                }
                                continuing {
                                    let _e1250 = dk;
                                    dk = (_e1250 + 1i);
                                }
                            }
                        }
                    }
                }
            }
            let _e1298 = showNum;
            let _e1299 = showY;
            let _e1301 = obox;
            if ((_e1298 && _e1299) && (abs(_e1301.x) <= 1f)) {
                {
                    let _e1307 = dpos_2;
                    let _e1309 = Ly;
                    k0_1 = floor(((_e1307.y / _e1309) + 0.5f));
                    loop {
                        let _e1318 = dk_1;
                        if !((_e1318 <= 1i)) {
                            break;
                        }
                        {
                            let _e1325 = k0_1;
                            let _e1326 = dk_1;
                            let _e1329 = Ly;
                            ky_2 = ((_e1325 + f32(_e1326)) * _e1329);
                            let _e1332 = ky_2;
                            ival_1 = i32(floor((_e1332 + 0.5f)));
                            let _e1338 = ival_1;
                            let _e1341 = showX;
                            if ((_e1338 == 0i) && _e1341) {
                                continue;
                            }
                            let _e1343 = atF_2;
                            let _e1345 = ky_2;
                            let _e1347 = tf(_e1343, vec2<f32>(0f, _e1345));
                            c_4 = _e1347;
                            let _e1349 = c_4;
                            let _e1352 = ar;
                            if (abs(_e1349.y) > _e1352) {
                                continue;
                            }
                            let _e1354 = u_8;
                            let _e1356 = c_4;
                            let _e1360 = glyphHalf;
                            let _e1361 = glowReach;
                            if (abs((_e1354.y - _e1356.y)) > (_e1360 + _e1361)) {
                                continue;
                            }
                            let _e1364 = ival_1;
                            ln = (_e1364 < 0i);
                            let _e1368 = ln;
                            if _e1368 {
                                let _e1369 = ival_1;
                                local_26 = -(_e1369);
                            } else {
                                let _e1371 = ival_1;
                                local_26 = _e1371;
                            }
                            let _e1373 = local_26;
                            av_3 = _e1373;
                            nint_3 = 1i;
                            let _e1377 = av_3;
                            tt_1 = _e1377;
                            i_1 = 0i;
                            loop {
                                let _e1381 = i_1;
                                if !((_e1381 < 6i)) {
                                    break;
                                }
                                {
                                    let _e1388 = tt_1;
                                    if (_e1388 >= 10i) {
                                        {
                                            let _e1391 = tt_1;
                                            tt_1 = (_e1391 / 10i);
                                            let _e1394 = nint_3;
                                            nint_3 = (_e1394 + 1i);
                                        }
                                    }
                                }
                                continuing {
                                    let _e1385 = i_1;
                                    i_1 = (_e1385 + 1i);
                                }
                            }
                            let _e1397 = nint_3;
                            let _e1398 = ln;
                            if _e1398 {
                                local_27 = 1i;
                            } else {
                                local_27 = 0i;
                            }
                            let _e1402 = local_27;
                            ng_1 = (_e1397 + _e1402);
                            let _e1405 = ng_1;
                            let _e1407 = gadv_1;
                            let _e1409 = gscale_2;
                            labelW = ((f32(_e1405) * _e1407) * _e1409);
                            let _e1412 = obox;
                            let _e1414 = tickMajor;
                            let _e1416 = gap;
                            let _e1418 = labelW;
                            centerX = (((_e1412.x - _e1414) - _e1416) - (_e1418 * 0.5f));
                            let _e1423 = u_8;
                            let _e1425 = centerX;
                            let _e1428 = labelW;
                            let _e1431 = glowReach;
                            if (abs((_e1423.x - _e1425)) > ((_e1428 * 0.5f) + _e1431)) {
                                continue;
                            }
                            let _e1434 = dDigit;
                            let _e1435 = u_8;
                            let _e1437 = centerX;
                            let _e1439 = u_8;
                            let _e1441 = c_4;
                            let _e1445 = ival_1;
                            let _e1446 = font_3;
                            let _e1447 = gscale_2;
                            let _e1448 = graphNumDist(vec2<f32>((_e1435.x - _e1437), (_e1439.y - _e1441.y)), _e1445, _e1446, _e1447);
                            dDigit = min(_e1434, _e1448);
                        }
                        continuing {
                            let _e1322 = dk_1;
                            dk_1 = (_e1322 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e1456 = inBox;
    let _e1457 = curveMode_1;
    let _e1461 = curveRender_1;
    let _e1465 = curveThickness_1;
    if (((_e1456 && (_e1457 >= 1i)) && (_e1461 >= 1i)) && (_e1465 > 0f)) {
        {
            let _e1469 = curveThickness_1;
            let _e1472 = vb_2;
            curveHalf_2 = ((_e1469 * 0.025f) * _e1472);
            let _e1475 = curveMode_1;
            let _e1476 = curveRender_1;
            let _e1477 = atF_2;
            let _e1478 = u_8;
            let _e1479 = dpos_2;
            let _e1480 = minorX_4;
            let _e1481 = Lx_4;
            let _e1482 = curveTransform_1;
            let _e1483 = graphCurve(_e1475, _e1476, _e1477, _e1478, _e1479, _e1480, _e1481, _e1482);
            dd_1 = _e1483;
            let _e1485 = dd_1;
            dC = _e1485.x;
            let _e1487 = curveRender_1;
            let _e1488 = dd_1;
            let _e1490 = dd_1;
            let _e1492 = curveHalf_2;
            let _e1493 = lineHalf_2;
            let _e1494 = u_8;
            let _e1495 = aa_2;
            let _e1496 = vb_2;
            let _e1497 = graphCurveCov(_e1487, _e1488.x, _e1490.y, _e1492, _e1493, _e1494, _e1495, _e1496);
            cc = _e1497;
            let _e1499 = cc;
            covCurve_1 = _e1499.x;
            let _e1501 = cc;
            covCB = _e1501.y;
        }
    }
    let _e1509 = inBox;
    let _e1510 = curveMode2_1;
    let _e1514 = curveRender2_1;
    let _e1518 = curveThickness2_1;
    if (((_e1509 && (_e1510 >= 1i)) && (_e1514 >= 1i)) && (_e1518 > 0f)) {
        {
            let _e1522 = curveThickness2_1;
            let _e1525 = vb_2;
            curveHalf2_ = ((_e1522 * 0.025f) * _e1525);
            let _e1528 = curveMode2_1;
            let _e1529 = curveRender2_1;
            let _e1530 = atF_2;
            let _e1531 = u_8;
            let _e1532 = dpos_2;
            let _e1533 = minorX_4;
            let _e1534 = Lx_4;
            let _e1535 = curveTransform2_1;
            let _e1536 = graphCurve(_e1528, _e1529, _e1530, _e1531, _e1532, _e1533, _e1534, _e1535);
            dd_2 = _e1536;
            let _e1538 = dd_2;
            dC2_ = _e1538.x;
            let _e1540 = curveRender2_1;
            let _e1541 = dd_2;
            let _e1543 = dd_2;
            let _e1545 = curveHalf2_;
            let _e1546 = lineHalf_2;
            let _e1547 = u_8;
            let _e1548 = aa_2;
            let _e1549 = vb_2;
            let _e1550 = graphCurveCov(_e1540, _e1541.x, _e1543.y, _e1545, _e1546, _e1547, _e1548, _e1549);
            cc_1 = _e1550;
            let _e1552 = cc_1;
            covCurve2_ = _e1552.x;
            let _e1554 = cc_1;
            covCB2_ = _e1554.y;
        }
    }
    let _e1556 = lineHalf_2;
    if (_e1556 <= 0f) {
        local_28 = 0f;
    } else {
        let _e1561 = lineHalf_2;
        let _e1562 = aa_2;
        let _e1564 = lineHalf_2;
        let _e1565 = aa_2;
        let _e1567 = dLine;
        local_28 = (1f - smoothstep((_e1561 - _e1562), (_e1564 + _e1565), _e1567));
    }
    let _e1571 = local_28;
    covLine = _e1571;
    let _e1573 = lineHalf_2;
    if (_e1573 <= 0f) {
        covGrid = 0f;
    }
    let _e1578 = digitHalf;
    let _e1579 = aa_2;
    let _e1581 = digitHalf;
    let _e1582 = aa_2;
    let _e1584 = dDigit;
    covDigit = (1f - smoothstep((_e1578 - _e1579), (_e1581 + _e1582), _e1584));
    let _e1588 = covLine;
    let _e1589 = covGrid;
    let _e1591 = covDigit;
    cov = max(max(_e1588, _e1589), _e1591);
    let _e1594 = lineHalf_2;
    if (_e1594 <= 0f) {
        let _e1597 = dDigit;
        local_29 = _e1597;
    } else {
        let _e1598 = dLine;
        let _e1599 = dGrid;
        let _e1600 = dDigit;
        local_29 = min(_e1598, min(_e1599, _e1600));
    }
    let _e1604 = local_29;
    dmin = _e1604;
    let _e1606 = glow_1;
    if (_e1606 > 0f) {
        let _e1609 = glow_1;
        let _e1610 = dmin;
        let _e1611 = lineHalf_2;
        let _e1612 = digitHalf;
        let _e1623 = cov;
        local_30 = ((_e1609 * exp((-(max((_e1610 - max(_e1611, _e1612)), 0f)) * 8f))) * (1f - _e1623));
    } else {
        local_30 = 0f;
    }
    let _e1628 = local_30;
    g = _e1628;
    let _e1630 = glow_1;
    let _e1633 = curveRender_1;
    let _e1637 = curveThickness_1;
    if (((_e1630 > 0f) && (_e1633 >= 1i)) && (_e1637 > 0f)) {
        let _e1641 = glow_1;
        let _e1642 = dC;
        let _e1643 = curveThickness_1;
        let _e1646 = vb_2;
        let _e1657 = covCurve_1;
        local_31 = ((_e1641 * exp((-(max((_e1642 - ((_e1643 * 0.025f) * _e1646)), 0f)) * 8f))) * (1f - _e1657));
    } else {
        local_31 = 0f;
    }
    let _e1662 = local_31;
    gc1_ = _e1662;
    let _e1664 = glow_1;
    let _e1667 = curveRender2_1;
    let _e1671 = curveThickness2_1;
    if (((_e1664 > 0f) && (_e1667 >= 1i)) && (_e1671 > 0f)) {
        let _e1675 = glow_1;
        let _e1676 = dC2_;
        let _e1677 = curveThickness2_1;
        let _e1680 = vb_2;
        let _e1691 = covCurve2_;
        local_32 = ((_e1675 * exp((-(max((_e1676 - ((_e1677 * 0.025f) * _e1680)), 0f)) * 8f))) * (1f - _e1691));
    } else {
        local_32 = 0f;
    }
    let _e1696 = local_32;
    gc2_ = _e1696;
    let _e1698 = cov;
    let _e1701 = covCurve_1;
    let _e1705 = covCurve2_;
    let _e1709 = covCB;
    let _e1713 = covCB2_;
    let _e1717 = covDiff;
    let _e1721 = g;
    let _e1725 = gc1_;
    let _e1729 = gc2_;
    if (((((((((_e1698 <= 0f) && (_e1701 <= 0f)) && (_e1705 <= 0f)) && (_e1709 <= 0f)) && (_e1713 <= 0f)) && (_e1717 <= 0f)) && (_e1721 <= 0.002f)) && (_e1725 <= 0.002f)) && (_e1729 <= 0.002f)) {
        let _e1733 = bkg_2;
        return _e1733;
    }
    let _e1734 = bkg_2;
    let _e1735 = diffColor_1;
    let _e1736 = _e1735.xyz;
    let _e1737 = diffColor_1;
    let _e1739 = covDiff;
    let _e1745 = mergeColor(_e1734, vec4<f32>(_e1736.x, _e1736.y, _e1736.z, (_e1737.w * _e1739)));
    outc = _e1745;
    let _e1747 = outc;
    let _e1748 = color1_1;
    let _e1749 = _e1748.xyz;
    let _e1750 = color1_1;
    let _e1752 = cov;
    let _e1758 = mergeColor(_e1747, vec4<f32>(_e1749.x, _e1749.y, _e1749.z, (_e1750.w * _e1752)));
    outc = _e1758;
    let _e1759 = outc;
    let _e1761 = outc;
    let _e1763 = color1_1;
    let _e1765 = g;
    let _e1767 = (_e1761.xyz + (_e1763.xyz * _e1765));
    outc.x = _e1767.x;
    outc.y = _e1767.y;
    outc.z = _e1767.z;
    let _e1774 = outc;
    let _e1775 = curveColor_1;
    let _e1776 = _e1775.xyz;
    let _e1777 = curveColor_1;
    let _e1779 = covCurve_1;
    let _e1785 = mergeColor(_e1774, vec4<f32>(_e1776.x, _e1776.y, _e1776.z, (_e1777.w * _e1779)));
    outc = _e1785;
    let _e1786 = outc;
    let _e1788 = outc;
    let _e1790 = curveColor_1;
    let _e1792 = gc1_;
    let _e1794 = (_e1788.xyz + (_e1790.xyz * _e1792));
    outc.x = _e1794.x;
    outc.y = _e1794.y;
    outc.z = _e1794.z;
    let _e1801 = outc;
    let _e1802 = color1_1;
    let _e1803 = _e1802.xyz;
    let _e1804 = color1_1;
    let _e1806 = covCB;
    let _e1812 = mergeColor(_e1801, vec4<f32>(_e1803.x, _e1803.y, _e1803.z, (_e1804.w * _e1806)));
    outc = _e1812;
    let _e1813 = outc;
    let _e1814 = curveColor2_1;
    let _e1815 = _e1814.xyz;
    let _e1816 = curveColor2_1;
    let _e1818 = covCurve2_;
    let _e1824 = mergeColor(_e1813, vec4<f32>(_e1815.x, _e1815.y, _e1815.z, (_e1816.w * _e1818)));
    outc = _e1824;
    let _e1825 = outc;
    let _e1827 = outc;
    let _e1829 = curveColor2_1;
    let _e1831 = gc2_;
    let _e1833 = (_e1827.xyz + (_e1829.xyz * _e1831));
    outc.x = _e1833.x;
    outc.y = _e1833.y;
    outc.z = _e1833.z;
    let _e1840 = outc;
    let _e1841 = color1_1;
    let _e1842 = _e1841.xyz;
    let _e1843 = color1_1;
    let _e1845 = covCB2_;
    let _e1851 = mergeColor(_e1840, vec4<f32>(_e1842.x, _e1842.y, _e1842.z, (_e1843.w * _e1845)));
    outc = _e1851;
    let _e1853 = outc;
    let _e1855 = g;
    let _e1856 = gc1_;
    let _e1857 = gc2_;
    outc.w = max(_e1853.w, min(max(_e1855, max(_e1856, _e1857)), 1f));
    let _e1863 = outc;
    return _e1863;
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
    let _e86 = global.U[9];
    let _e90 = global.U[10];
    let _e94 = global.U[11];
    let _e97 = global.U[12];
    let _e102 = global.U[13];
    let _e107 = global.U[14];
    let _e110 = global.U[15];
    let _e111 = _e110.xyz;
    let _e114 = global.U[16];
    let _e115 = _e114.xyz;
    let _e118 = global.U[17];
    let _e119 = _e118.xyz;
    let _e135 = global.U[18];
    let _e139 = global.U[19];
    let _e144 = global.U[20];
    let _e149 = global.U[21];
    let _e152 = global.U[22];
    let _e153 = _e152.xyz;
    let _e156 = global.U[23];
    let _e157 = _e156.xyz;
    let _e160 = global.U[24];
    let _e161 = _e160.xyz;
    let _e177 = global.U[25];
    let _e181 = global.U[26];
    let _e186 = global.U[27];
    let _e189 = global.U[28];
    let _e193 = global.U[29];
    let _e197 = global.U[30];
    let _e198 = _e197.xyz;
    let _e201 = global.U[31];
    let _e202 = _e201.xyz;
    let _e205 = global.U[32];
    let _e206 = _e205.xyz;
    let _e222 = global.U[33];
    let _e223 = _e222.xyz;
    let _e226 = global.U[34];
    let _e227 = _e226.xyz;
    let _e230 = global.U[35];
    let _e231 = _e230.xyz;
    let _e247 = global.U[4];
    let _e249 = graph((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), i32(_e76.x), i32(_e81.x), _e86.x, _e90.x, _e94, i32(_e97.x), i32(_e102.x), _e107, mat3x3<f32>(vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z)), _e135.x, i32(_e139.x), i32(_e144.x), _e149, mat3x3<f32>(vec3<f32>(_e153.x, _e153.y, _e153.z), vec3<f32>(_e157.x, _e157.y, _e157.z), vec3<f32>(_e161.x, _e161.y, _e161.z)), _e177.x, i32(_e181.x), _e186, _e189.x, _e193.x, mat3x3<f32>(vec3<f32>(_e198.x, _e198.y, _e198.z), vec3<f32>(_e202.x, _e202.y, _e202.z), vec3<f32>(_e206.x, _e206.y, _e206.z)), mat3x3<f32>(vec3<f32>(_e223.x, _e223.y, _e223.z), vec3<f32>(_e227.x, _e227.y, _e227.z), vec3<f32>(_e231.x, _e231.y, _e231.z)), _e247.xy);
    fragColor = _e249;
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
