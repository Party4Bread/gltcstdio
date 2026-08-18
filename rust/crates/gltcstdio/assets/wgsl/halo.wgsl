struct Params {
    U: array<vec4<f32>, 19>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn halo(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, blend: f32, dispersion: f32, fadeThickness: f32, frequency: f32, thickness: f32, variability: f32, modelTransform: mat3x3<f32>, dampeningTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var blend_1: f32;
    var dispersion_1: f32;
    var fadeThickness_1: f32;
    var frequency_1: f32;
    var thickness_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var dampeningTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var lum: f32;
    var v: vec2<f32>;
    var angle: f32;
    var len: f32;
    var qvar: f32;
    var expand: f32;
    var d: f32;
    var dr: f32;
    var kr: f32;
    var dg: f32;
    var kg: f32;
    var db: f32;
    var kb: f32;
    var halo_1: vec3<f32>;
    var dampen: f32;
    var col: vec4<f32>;
    var bkgCol: vec4<f32>;
    var k1_: f32;
    var k2_: f32;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    blend_1 = blend;
    dispersion_1 = dispersion;
    fadeThickness_1 = fadeThickness;
    frequency_1 = frequency;
    thickness_1 = thickness;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    dampeningTransform_1 = dampeningTransform;
    let _e30 = modelTransform_1;
    let _e32 = uv_1;
    let _e33 = tf(_naga_inverse_3x3_f32(_e30), _e32);
    u_2 = _e33;
    let _e35 = intensity_1;
    lum = _e35;
    let _e38 = frequency_1;
    frequency_1 = pow(1.05f, _e38);
    let _e40 = u_2;
    v = _e40;
    let _e42 = v;
    let _e44 = v;
    angle = atan2(_e42.y, _e44.x);
    let _e48 = v;
    len = length(_e48);
    let _e51 = angle;
    let _e52 = frequency_1;
    let _e55 = angle;
    let _e62 = angle;
    let _e63 = frequency_1;
    let _e68 = angle;
    let _e76 = angle;
    let _e77 = frequency_1;
    let _e82 = angle;
    qvar = ((sin(((_e51 * _e52) * (1.5f + sin((_e55 * 3f))))) * sin((((_e62 * _e63) * 0.88f) * (1.5f + sin((_e68 * 7f)))))) * sin((((_e76 * _e77) * 0.81f) * (1.5f + sin((_e82 * 11f))))));
    let _e92 = qvar;
    let _e93 = variability_1;
    let _e98 = angle;
    let _e105 = angle;
    expand = (1f + ((_e92 * _e93) * (0.3f + ((0.25f * (1f + sin((_e98 * 5f)))) * (1f + sin((_e105 * 14f)))))));
    let _e115 = len;
    let _e117 = thickness_1;
    let _e122 = expand;
    let _e125 = thickness_1;
    len = (((_e115 - (1f - (_e117 * 0.5f))) * _e122) + (1f - (_e125 * 0.5f)));
    let _e130 = len;
    d = _e130;
    let _e132 = len;
    let _e134 = dispersion_1;
    dr = (_e132 * (1f + _e134));
    let _e139 = thickness_1;
    let _e142 = thickness_1;
    let _e144 = fadeThickness_1;
    let _e146 = dr;
    let _e150 = fadeThickness_1;
    let _e152 = dr;
    kr = (smoothstep((1f - _e139), ((1f - _e142) + _e144), _e146) * smoothstep(1f, (1f - _e150), _e152));
    let _e156 = len;
    dg = _e156;
    let _e159 = thickness_1;
    let _e162 = thickness_1;
    let _e164 = fadeThickness_1;
    let _e166 = dg;
    let _e170 = fadeThickness_1;
    let _e172 = dg;
    kg = (smoothstep((1f - _e159), ((1f - _e162) + _e164), _e166) * smoothstep(1f, (1f - _e170), _e172));
    let _e176 = len;
    let _e178 = dispersion_1;
    db = (_e176 * (1f - _e178));
    let _e183 = thickness_1;
    let _e186 = thickness_1;
    let _e188 = fadeThickness_1;
    let _e190 = db;
    let _e194 = fadeThickness_1;
    let _e196 = db;
    kb = (smoothstep((1f - _e183), ((1f - _e186) + _e188), _e190) * smoothstep(1f, (1f - _e194), _e196));
    let _e200 = kr;
    let _e201 = kg;
    let _e202 = kb;
    halo_1 = vec3<f32>(_e200, _e201, _e202);
    let _e205 = dampeningTransform_1;
    let _e207 = u_2;
    let _e208 = tf(_naga_inverse_3x3_f32(_e205), _e207);
    d = length(_e208);
    let _e211 = dampening_1;
    let _e214 = d;
    dampen = (1f - (_e211 * smoothstep(1f, 0.5f, _e214)));
    let _e219 = halo_1;
    let _e220 = dampen;
    halo_1 = (_e219 * _e220);
    let _e222 = lum;
    let _e223 = halo_1;
    let _e224 = (_e222 * _e223);
    col = vec4<f32>(_e224.x, _e224.y, _e224.z, 1f);
    let _e231 = uv_1;
    let _e235 = global.U[0];
    let _e238 = uv_1;
    let _e247 = textureSample(t_source, samp, ((vec2<f32>((_e231.x / _e235.x), _e238.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e247;
    let _e249 = blend_1;
    k1_ = _e249;
    let _e252 = blend_1;
    k2_ = (1f - _e252);
    let _e255 = bkgCol;
    let _e256 = bkgCol;
    let _e257 = col;
    let _e259 = k2_;
    let _e260 = k1_;
    let _e261 = lum;
    let _e262 = k2_;
    outCol = mix(_e255, (_e256 + _e257), vec4((_e259 + (_e260 * min(((_e261 * _e262) * 10f), 1f)))));
    let _e273 = outCol;
    return _e273;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e94 = global.U[12];
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e123 = global.U[16];
    let _e124 = _e123.xyz;
    let _e127 = global.U[17];
    let _e128 = _e127.xyz;
    let _e131 = global.U[18];
    let _e132 = _e131.xyz;
    let _e146 = halo((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, _e90.x, _e94.x, mat3x3<f32>(vec3<f32>(_e99.x, _e99.y, _e99.z), vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z)), mat3x3<f32>(vec3<f32>(_e124.x, _e124.y, _e124.z), vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z)));
    fragColor = _e146;
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
