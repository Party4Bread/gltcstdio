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

var<private> v_uv_1: vec2<f32>;
var<private> fragColor: vec4<f32>;
@group(0) @binding(0) 
var<uniform> global: Params;
@group(0) @binding(1) 
var samp: sampler;

fn crissCross(u: vec2<f32>, thicknessX: f32, thicknessY: f32, horOver: bool, top: f32, right: f32, bottom: f32, left: f32) -> vec3<f32> {
    var u_1: vec2<f32>;
    var thicknessX_1: f32;
    var thicknessY_1: f32;
    var horOver_1: bool;
    var top_1: f32;
    var right_1: f32;
    var bottom_1: f32;
    var left_1: f32;
    var dx: f32;
    var dy: f32;
    var shadow: f32;
    var shadow_1: f32;
    var shadow_2: f32;
    var shadow_3: f32;

    u_1 = u;
    thicknessX_1 = thicknessX;
    thicknessY_1 = thicknessY;
    horOver_1 = horOver;
    top_1 = top;
    right_1 = right;
    bottom_1 = bottom;
    left_1 = left;
    let _e21 = u_1;
    let _e24 = thicknessX_1;
    dx = (abs(_e21.x) - _e24);
    let _e27 = u_1;
    let _e30 = thicknessY_1;
    dy = (abs(_e27.y) - _e30);
    let _e33 = horOver_1;
    if _e33 {
        {
            let _e34 = dy;
            if (_e34 < 0f) {
                {
                    let _e38 = right_1;
                    let _e40 = u_1;
                    let _e43 = u_1;
                    let _e47 = left_1;
                    shadow = min(((1f - _e38) - _e40.x), (_e43.x - (-1f + _e47)));
                    let _e53 = shadow;
                    let _e54 = u_1;
                    return vec3<f32>(1f, _e53, _e54.y);
                }
            } else {
                let _e57 = dx;
                if (_e57 < 0f) {
                    {
                        let _e60 = dy;
                        let _e62 = top_1;
                        let _e64 = u_1;
                        let _e67 = u_1;
                        let _e71 = bottom_1;
                        shadow_1 = min(_e60, min(((1f - _e62) - _e64.y), (_e67.y - (-1f + _e71))));
                        let _e78 = shadow_1;
                        let _e79 = u_1;
                        return vec3<f32>(0f, _e78, _e79.x);
                    }
                }
            }
        }
    } else {
        {
            let _e82 = dx;
            if (_e82 < 0f) {
                {
                    let _e86 = top_1;
                    let _e88 = u_1;
                    let _e91 = u_1;
                    let _e95 = bottom_1;
                    shadow_2 = min(((1f - _e86) - _e88.y), (_e91.y - (-1f + _e95)));
                    let _e101 = shadow_2;
                    let _e102 = u_1;
                    return vec3<f32>(0f, _e101, _e102.x);
                }
            } else {
                let _e105 = dy;
                if (_e105 < 0f) {
                    {
                        let _e108 = dx;
                        let _e110 = right_1;
                        let _e112 = u_1;
                        let _e115 = u_1;
                        let _e119 = left_1;
                        shadow_3 = min(_e108, min(((1f - _e110) - _e112.x), (_e115.x - (-1f + _e119))));
                        let _e126 = shadow_3;
                        let _e127 = u_1;
                        return vec3<f32>(1f, _e126, _e127.y);
                    }
                }
            }
        }
    }
    return vec3<f32>(-1f, 0f, 0f);
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x;
    let _e32 = y;
    return vec2<f32>(_e31, _e32);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_1;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e9 = noise_3;
    let _e11 = k_3;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_3;
    let _e16 = varyNoiseSmoothly(_e13.y, _e15);
    return vec2<f32>(_e12, _e16);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rand2_(_e9);
    let _e11 = seed_1;
    let _e12 = varyVec2NoiseSmoothly(_e10, _e11);
    return (_e12 - vec2(0.5f));
}

fn getThick(x_1: f32, thickness: f32, var_: f32, seed_2: f32) -> f32 {
    var x_2: f32;
    var thickness_1: f32;
    var var_1: f32;
    var seed_3: f32;
    var k_4: vec2<f32>;

    x_2 = x_1;
    thickness_1 = thickness;
    var_1 = var_;
    seed_3 = seed_2;
    let _e13 = var_1;
    if (_e13 == 0f) {
        let _e16 = thickness_1;
        return _e16;
    }
    let _e17 = x_2;
    let _e18 = x_2;
    let _e20 = seed_3;
    let _e21 = rand2relSeeded(vec2<f32>(_e17, _e18), _e20);
    k_4 = (_e21 + vec2(0.5f));
    let _e26 = thickness_1;
    let _e28 = var_1;
    let _e31 = thickness_1;
    let _e33 = var_1;
    let _e35 = k_4;
    return mix((_e26 * (1f - _e28)), mix(_e31, 0.5f, _e33), _e35.x);
}

fn isHor(id: vec2<f32>, mode: f32) -> bool {
    var id_1: vec2<f32>;
    var mode_1: f32;
    var m: i32;
    var a: f32;
    var b: f32;
    var c: f32;
    var d: f32;
    var e: f32;
    var f: f32;
    var g: f32;
    var h: f32;
    var i: f32;
    var j: f32;
    var k_5: f32;

    id_1 = id;
    mode_1 = mode;
    let _e9 = mode_1;
    m = i32(_e9);
    let _e12 = m;
    a = f32(((_e12 % 4i) + 1i));
    let _e19 = m;
    m = (_e19 / 4i);
    let _e22 = m;
    b = f32(((_e22 % 4i) + 1i));
    let _e29 = m;
    m = (_e29 / 4i);
    let _e32 = m;
    c = f32(((_e32 % 4i) + 1i));
    let _e39 = m;
    m = (_e39 / 4i);
    let _e42 = m;
    d = f32(((_e42 % 4i) + 1i));
    let _e49 = m;
    m = (_e49 / 4i);
    let _e52 = m;
    e = f32(((_e52 % 4i) + 2i));
    let _e59 = m;
    m = (_e59 / 4i);
    let _e62 = m;
    f = f32(((_e62 % 4i) + 1i));
    let _e69 = m;
    m = (_e69 / 4i);
    let _e72 = m;
    g = f32(((_e72 % 4i) + 1i));
    let _e79 = m;
    m = (_e79 / 4i);
    let _e82 = m;
    h = f32(((_e82 % 4i) + 1i));
    let _e89 = m;
    m = (_e89 / 4i);
    let _e92 = m;
    i = (f32(((_e92 % 4i) + 2i)) * 3f);
    let _e101 = m;
    m = (_e101 / 4i);
    let _e104 = m;
    j = (f32(((_e104 % 4i) + 2i)) * 3f);
    let _e113 = m;
    m = (_e113 / 4i);
    let _e116 = m;
    k_5 = f32(((_e116 % 4i) + 1i));
    let _e123 = id_1;
    let _e125 = a;
    let _e128 = id_1;
    let _e130 = b;
    let _e133 = (floor((_e123.x / _e125)) + floor((_e128.y / _e130)));
    let _e134 = e;
    let _e135 = id_1;
    let _e137 = g;
    let _e142 = (_e134 + (_e135.y - (floor((_e135.y / _e137)) * _e137)));
    let _e147 = id_1;
    let _e149 = i;
    let _e152 = id_1;
    let _e154 = j;
    let _e157 = (floor((_e147.x / _e149)) + floor((_e152.y / _e154)));
    let _e158 = k_5;
    let _e163 = id_1;
    let _e165 = c;
    let _e168 = id_1;
    let _e170 = d;
    let _e173 = (floor((_e163.x / _e165)) + floor((_e168.y / _e170)));
    let _e174 = f;
    let _e175 = id_1;
    let _e177 = h;
    let _e182 = (_e174 + (_e175.x - (floor((_e175.x / _e177)) * _e177)));
    return ((_e133 - (floor((_e133 / _e142)) * _e142)) == ((_e157 - (floor((_e157 / _e158)) * _e158)) * (_e173 - (floor((_e173 / _e182)) * _e182))));
}

fn isHor2_(id_2: vec2<f32>, a_1: f32, b_1: f32, c_1: f32, d_1: f32, e_1: f32, f_1: f32, g_1: f32, h_1: f32, i_1: f32, j_1: f32, k_6: f32) -> bool {
    var id_3: vec2<f32>;
    var a_2: f32;
    var b_2: f32;
    var c_2: f32;
    var d_2: f32;
    var e_2: f32;
    var f_2: f32;
    var g_2: f32;
    var h_2: f32;
    var i_2: f32;
    var j_2: f32;
    var k_7: f32;

    id_3 = id_2;
    a_2 = a_1;
    b_2 = b_1;
    c_2 = c_1;
    d_2 = d_1;
    e_2 = e_1;
    f_2 = f_1;
    g_2 = g_1;
    h_2 = h_1;
    i_2 = i_1;
    j_2 = j_1;
    k_7 = k_6;
    let _e29 = id_3;
    let _e31 = a_2;
    let _e34 = id_3;
    let _e36 = b_2;
    let _e39 = (floor((_e29.x * _e31)) + floor((_e34.y * _e36)));
    let _e40 = e_2;
    let _e41 = id_3;
    let _e43 = g_2;
    let _e48 = (_e40 + (_e41.y - (floor((_e41.y / _e43)) * _e43)));
    let _e53 = id_3;
    let _e55 = i_2;
    let _e58 = id_3;
    let _e60 = j_2;
    let _e63 = (floor((_e53.x * _e55)) + floor((_e58.y * _e60)));
    let _e64 = k_7;
    let _e69 = id_3;
    let _e71 = c_2;
    let _e74 = id_3;
    let _e76 = d_2;
    let _e79 = (floor((_e69.x * _e71)) + floor((_e74.y * _e76)));
    let _e80 = f_2;
    let _e81 = id_3;
    let _e83 = h_2;
    let _e88 = (_e80 + (_e81.x - (floor((_e81.x / _e83)) * _e83)));
    return ((_e39 - (floor((_e39 / _e48)) * _e48)) == ((_e63 - (floor((_e63 / _e64)) * _e64)) * (_e79 - (floor((_e79 / _e88)) * _e88))));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e9 = bkg_1;
    let _e11 = front_1;
    let _e13 = front_1;
    let _e16 = bkg_1;
    let _e20 = front_1;
    let _e26 = mix(_e9.xyz, _e11.xyz, vec3((_e13.w + ((1f - _e16.w) * (1f - _e20.w)))));
    let _e27 = bkg_1;
    let _e29 = front_1;
    return vec4<f32>(_e26.x, _e26.y, _e26.z, max(_e27.w, _e29.w));
}

fn shade(shadow_4: f32, dist: f32) -> f32 {
    var shadow_5: f32;
    var dist_1: f32;

    shadow_5 = shadow_4;
    dist_1 = dist;
    let _e9 = shadow_5;
    let _e10 = shadow_5;
    let _e13 = dist_1;
    return smoothstep(_e9, (_e10 * 0.35f), _e13);
}

fn crossStitch(uv: vec2<f32>, outPos: vec2<f32>, mode1_: i32, mode2_: i32, hColor: vec4<f32>, vColor: vec4<f32>, hBorderColor: vec4<f32>, vBorderColor: vec4<f32>, colorShadow: vec4<f32>, colorBkg: vec4<f32>, randomSeed: f32, variability: f32, thickness_2: f32, shadows: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode1_1: i32;
    var mode2_1: i32;
    var hColor_1: vec4<f32>;
    var vColor_1: vec4<f32>;
    var hBorderColor_1: vec4<f32>;
    var vBorderColor_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var randomSeed_1: f32;
    var variability_1: f32;
    var thickness_3: f32;
    var shadows_1: f32;
    var id_4: vec2<f32>;
    var mo: f32;
    var m_1: i32;
    var pa: f32;
    var pb: f32;
    var pc: f32;
    var pd: f32;
    var pe: f32;
    var pf: f32;
    var pg: f32;
    var ph: f32;
    var pi: f32;
    var pj: f32;
    var pk: f32;
    var thickVar: f32;
    var thicknessX_2: f32;
    var thicknessY_2: f32;
    var shadow_6: f32 = 0.5f;
    var u_2: vec2<f32>;
    var unit: vec2<f32> = vec2<f32>(1f, 0f);
    var local: f32;
    var top_2: f32;
    var local_1: f32;
    var bottom_2: f32;
    var local_2: f32;
    var right_2: f32;
    var local_3: f32;
    var left_2: f32;
    var cc: vec3<f32>;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    mode1_1 = mode1_;
    mode2_1 = mode2_;
    hColor_1 = hColor;
    vColor_1 = vColor;
    hBorderColor_1 = hBorderColor;
    vBorderColor_1 = vBorderColor;
    colorShadow_1 = colorShadow;
    colorBkg_1 = colorBkg;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    thickness_3 = thickness_2;
    shadows_1 = shadows;
    let _e33 = thickness_3;
    thickness_3 = (_e33 * 0.5f);
    let _e36 = uv_1;
    id_4 = floor(_e36);
    let _e39 = mode1_1;
    let _e41 = mode2_1;
    mo = (f32(_e39) + (f32(_e41) * 4096f));
    let _e47 = mo;
    m_1 = i32(_e47);
    let _e51 = m_1;
    pa = (1f / f32(((_e51 % 4i) + 1i)));
    let _e59 = m_1;
    m_1 = (_e59 / 4i);
    let _e63 = m_1;
    pb = (1f / f32(((_e63 % 4i) + 1i)));
    let _e71 = m_1;
    m_1 = (_e71 / 4i);
    let _e75 = m_1;
    pc = (1f / f32(((_e75 % 4i) + 1i)));
    let _e83 = m_1;
    m_1 = (_e83 / 4i);
    let _e87 = m_1;
    pd = (1f / f32(((_e87 % 4i) + 1i)));
    let _e95 = m_1;
    m_1 = (_e95 / 4i);
    let _e98 = m_1;
    pe = f32(((_e98 % 4i) + 2i));
    let _e105 = m_1;
    m_1 = (_e105 / 4i);
    let _e108 = m_1;
    pf = f32(((_e108 % 4i) + 1i));
    let _e115 = m_1;
    m_1 = (_e115 / 4i);
    let _e118 = m_1;
    pg = f32(((_e118 % 4i) + 1i));
    let _e125 = m_1;
    m_1 = (_e125 / 4i);
    let _e128 = m_1;
    ph = f32(((_e128 % 4i) + 1i));
    let _e135 = m_1;
    m_1 = (_e135 / 4i);
    let _e139 = m_1;
    pi = ((1f / f32(((_e139 % 4i) + 2i))) * 3f);
    let _e149 = m_1;
    m_1 = (_e149 / 4i);
    let _e153 = m_1;
    pj = ((1f / f32(((_e153 % 4i) + 2i))) * 3f);
    let _e163 = m_1;
    m_1 = (_e163 / 4i);
    let _e166 = m_1;
    pk = f32(((_e166 % 4i) + 1i));
    let _e173 = variability_1;
    thickVar = _e173;
    let _e175 = id_4;
    let _e177 = thickness_3;
    let _e178 = thickVar;
    let _e179 = randomSeed_1;
    let _e180 = getThick(_e175.x, _e177, _e178, _e179);
    thicknessX_2 = _e180;
    let _e182 = id_4;
    let _e184 = thickness_3;
    let _e185 = thickVar;
    let _e186 = randomSeed_1;
    let _e187 = getThick(_e182.y, _e184, _e185, _e186);
    thicknessY_2 = _e187;
    let _e191 = uv_1;
    u_2 = (fract(_e191) - vec2(0.5f));
    let _e201 = id_4;
    let _e202 = unit;
    let _e205 = pa;
    let _e206 = pb;
    let _e207 = pc;
    let _e208 = pd;
    let _e209 = pe;
    let _e210 = pf;
    let _e211 = pg;
    let _e212 = ph;
    let _e213 = pi;
    let _e214 = pj;
    let _e215 = pk;
    let _e216 = isHor2_((_e201 + _e202.yx), _e205, _e206, _e207, _e208, _e209, _e210, _e211, _e212, _e213, _e214, _e215);
    if _e216 {
        let _e217 = id_4;
        let _e221 = thickness_3;
        let _e222 = thickVar;
        let _e223 = randomSeed_1;
        let _e224 = getThick((_e217.y + 1f), _e221, _e222, _e223);
        local = _e224;
    } else {
        local = -1f;
    }
    let _e228 = local;
    top_2 = _e228;
    let _e230 = id_4;
    let _e231 = unit;
    let _e234 = pa;
    let _e235 = pb;
    let _e236 = pc;
    let _e237 = pd;
    let _e238 = pe;
    let _e239 = pf;
    let _e240 = pg;
    let _e241 = ph;
    let _e242 = pi;
    let _e243 = pj;
    let _e244 = pk;
    let _e245 = isHor2_((_e230 - _e231.yx), _e234, _e235, _e236, _e237, _e238, _e239, _e240, _e241, _e242, _e243, _e244);
    if _e245 {
        let _e246 = id_4;
        let _e250 = thickness_3;
        let _e251 = thickVar;
        let _e252 = randomSeed_1;
        let _e253 = getThick((_e246.y - 1f), _e250, _e251, _e252);
        local_1 = _e253;
    } else {
        local_1 = -1f;
    }
    let _e257 = local_1;
    bottom_2 = _e257;
    let _e259 = id_4;
    let _e260 = unit;
    let _e262 = pa;
    let _e263 = pb;
    let _e264 = pc;
    let _e265 = pd;
    let _e266 = pe;
    let _e267 = pf;
    let _e268 = pg;
    let _e269 = ph;
    let _e270 = pi;
    let _e271 = pj;
    let _e272 = pk;
    let _e273 = isHor2_((_e259 + _e260), _e262, _e263, _e264, _e265, _e266, _e267, _e268, _e269, _e270, _e271, _e272);
    if !(_e273) {
        let _e275 = id_4;
        let _e279 = thickness_3;
        let _e280 = thickVar;
        let _e281 = randomSeed_1;
        let _e282 = getThick((_e275.x + 1f), _e279, _e280, _e281);
        local_2 = _e282;
    } else {
        local_2 = -1f;
    }
    let _e286 = local_2;
    right_2 = _e286;
    let _e288 = id_4;
    let _e289 = unit;
    let _e291 = pa;
    let _e292 = pb;
    let _e293 = pc;
    let _e294 = pd;
    let _e295 = pe;
    let _e296 = pf;
    let _e297 = pg;
    let _e298 = ph;
    let _e299 = pi;
    let _e300 = pj;
    let _e301 = pk;
    let _e302 = isHor2_((_e288 - _e289), _e291, _e292, _e293, _e294, _e295, _e296, _e297, _e298, _e299, _e300, _e301);
    if !(_e302) {
        let _e304 = id_4;
        let _e308 = thickness_3;
        let _e309 = thickVar;
        let _e310 = randomSeed_1;
        let _e311 = getThick((_e304.x - 1f), _e308, _e309, _e310);
        local_3 = _e311;
    } else {
        local_3 = -1f;
    }
    let _e315 = local_3;
    left_2 = _e315;
    let _e317 = u_2;
    let _e318 = thicknessX_2;
    let _e319 = thicknessY_2;
    let _e320 = id_4;
    let _e321 = pa;
    let _e322 = pb;
    let _e323 = pc;
    let _e324 = pd;
    let _e325 = pe;
    let _e326 = pf;
    let _e327 = pg;
    let _e328 = ph;
    let _e329 = pi;
    let _e330 = pj;
    let _e331 = pk;
    let _e332 = isHor2_(_e320, _e321, _e322, _e323, _e324, _e325, _e326, _e327, _e328, _e329, _e330, _e331);
    let _e333 = top_2;
    let _e334 = right_2;
    let _e335 = bottom_2;
    let _e336 = left_2;
    let _e337 = crissCross(_e317, _e318, _e319, _e332, _e333, _e334, _e335, _e336);
    cc = _e337;
    let _e339 = colorBkg_1;
    col = _e339;
    let _e341 = cc;
    if (_e341.x == 1f) {
        {
            let _e345 = hColor_1;
            col = _e345;
            let _e346 = cc;
            let _e349 = thicknessX_2;
            if (abs(_e346.z) > (_e349 * 0.8f)) {
                let _e353 = hColor_1;
                let _e354 = hBorderColor_1;
                let _e355 = mergeColor(_e353, _e354);
                col = _e355;
            }
        }
    } else {
        let _e356 = cc;
        if (_e356.x == 0f) {
            {
                let _e360 = vColor_1;
                col = _e360;
                let _e361 = cc;
                let _e364 = thicknessY_2;
                if (abs(_e361.z) > (_e364 * 0.8f)) {
                    let _e368 = vColor_1;
                    let _e369 = vBorderColor_1;
                    let _e370 = mergeColor(_e368, _e369);
                    col = _e370;
                }
            }
        }
    }
    let _e371 = cc;
    if (_e371.x != -1f) {
        {
            let _e376 = col;
            let _e377 = colorShadow_1;
            let _e378 = _e377.xyz;
            let _e379 = colorShadow_1;
            let _e381 = shadows_1;
            let _e382 = cc;
            let _e384 = shade(_e381, _e382.y);
            let _e390 = mergeColor(_e376, vec4<f32>(_e378.x, _e378.y, _e378.z, (_e379.w * _e384)));
            col = _e390;
        }
    }
    let _e391 = col;
    return _e391;
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e84 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e93 = global.U[13];
    let _e97 = global.U[14];
    let _e101 = global.U[15];
    let _e105 = global.U[16];
    let _e107 = crossStitch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), i32(_e70.x), _e75, _e78, _e81, _e84, _e87, _e90, _e93.x, _e97.x, _e101.x, _e105.x);
    fragColor = _e107;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
