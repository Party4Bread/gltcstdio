struct Params {
    U: array<vec4<f32>, 28>,
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

fn moebiusImplicitFn(p: vec3<f32>, radius: f32, twistCount: f32, phase: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var twistCount_1: f32;
    var phase_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;
    var angle: f32;
    var u: vec2<f32>;
    var twist: f32;
    var ct: f32;
    var st: f32;

    p_1 = p;
    radius_1 = radius;
    twistCount_1 = twistCount;
    phase_1 = phase;
    let _e16 = R;
    let _e17 = radius_1;
    r = (_e16 * _e17);
    let _e20 = p_1;
    let _e22 = p_1;
    let _e25 = p_1;
    let _e27 = p_1;
    let _e32 = R;
    a = (sqrt(((_e20.x * _e22.x) + (_e25.y * _e27.y))) - _e32);
    let _e35 = p_1;
    let _e38 = p_1;
    angle = atan2(-(_e35.x), -(_e38.y));
    let _e43 = a;
    let _e44 = p_1;
    u = vec2<f32>(_e43, _e44.z);
    let _e48 = angle;
    let _e51 = twistCount_1;
    let _e53 = phase_1;
    twist = (((_e48 * 0.25f) * _e51) + _e53);
    let _e56 = twist;
    ct = cos(_e56);
    let _e59 = twist;
    st = sin(_e59);
    let _e62 = ct;
    let _e63 = st;
    let _e64 = st;
    let _e66 = ct;
    let _e70 = u;
    u = (mat2x2<f32>(vec2<f32>(_e62, _e63), vec2<f32>(-(_e64), _e66)) * _e70);
    let _e72 = u;
    let _e75 = u;
    let _e79 = r;
    return (max(abs(_e72.x), abs(_e75.y)) - _e79);
}

fn moebiusNormal(p_2: vec3<f32>, radius_2: f32, twistCount_2: f32, phase_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var twistCount_3: f32;
    var phase_3: f32;
    var d: f32 = 0.0001f;
    var d2_: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    twistCount_3 = twistCount_2;
    phase_3 = phase_2;
    let _e16 = d;
    d2_ = (_e16 * 2f);
    let _e20 = p_3;
    let _e22 = d;
    let _e24 = p_3;
    let _e26 = p_3;
    let _e29 = radius_3;
    let _e30 = twistCount_3;
    let _e31 = phase_3;
    let _e32 = moebiusImplicitFn(vec3<f32>((_e20.x - _e22), _e24.y, _e26.z), _e29, _e30, _e31);
    let _e33 = p_3;
    let _e35 = d;
    let _e37 = p_3;
    let _e39 = p_3;
    let _e42 = radius_3;
    let _e43 = twistCount_3;
    let _e44 = phase_3;
    let _e45 = moebiusImplicitFn(vec3<f32>((_e33.x + _e35), _e37.y, _e39.z), _e42, _e43, _e44);
    let _e47 = d2_;
    let _e49 = p_3;
    let _e51 = p_3;
    let _e53 = d;
    let _e55 = p_3;
    let _e58 = radius_3;
    let _e59 = twistCount_3;
    let _e60 = phase_3;
    let _e61 = moebiusImplicitFn(vec3<f32>(_e49.x, (_e51.y - _e53), _e55.z), _e58, _e59, _e60);
    let _e62 = p_3;
    let _e64 = p_3;
    let _e66 = d;
    let _e68 = p_3;
    let _e71 = radius_3;
    let _e72 = twistCount_3;
    let _e73 = phase_3;
    let _e74 = moebiusImplicitFn(vec3<f32>(_e62.x, (_e64.y + _e66), _e68.z), _e71, _e72, _e73);
    let _e76 = d2_;
    let _e78 = p_3;
    let _e80 = p_3;
    let _e82 = p_3;
    let _e84 = d;
    let _e87 = radius_3;
    let _e88 = twistCount_3;
    let _e89 = phase_3;
    let _e90 = moebiusImplicitFn(vec3<f32>(_e78.x, _e80.y, (_e82.z - _e84)), _e87, _e88, _e89);
    let _e91 = p_3;
    let _e93 = p_3;
    let _e95 = p_3;
    let _e97 = d;
    let _e100 = radius_3;
    let _e101 = twistCount_3;
    let _e102 = phase_3;
    let _e103 = moebiusImplicitFn(vec3<f32>(_e91.x, _e93.y, (_e95.z + _e97)), _e100, _e101, _e102);
    let _e105 = d2_;
    return normalize(vec3<f32>(((_e32 - _e45) / _e47), ((_e61 - _e74) / _e76), ((_e90 - _e103) / _e105)));
}

fn moebiusBoundingSphereK(center: vec3<f32>, radius_4: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_5: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a_1: f32;
    var b: f32;
    var c: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local: f32;
    var local_1: f32;
    var l: f32;

    center_1 = center;
    radius_5 = radius_4;
    origin_1 = origin;
    dir_1 = dir;
    let _e14 = origin_1;
    let _e15 = center_1;
    relOrigin = (_e14 - _e15);
    let _e18 = dir_1;
    let _e19 = dir_1;
    a_1 = dot(_e18, _e19);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_5;
    let _e32 = radius_5;
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a_1;
    let _e42 = c;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b;
            let _e54 = sqrtDelta;
            let _e57 = a_1;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b;
            let _e63 = sqrtDelta;
            let _e66 = a_1;
            l2_ = ((-(_e61) + _e63) / (2f * _e66));
            let _e70 = l1_;
            if (_e70 > 0f) {
                let _e73 = l1_;
                local_1 = _e73;
            } else {
                let _e74 = l2_;
                if (_e74 > 0f) {
                    let _e77 = l2_;
                    local = _e77;
                } else {
                    local = -1f;
                }
                let _e81 = local;
                local_1 = _e81;
            }
            let _e83 = local_1;
            l = _e83;
            let _e85 = l;
            if (_e85 > 0f) {
                let _e89 = l1_;
                let _e91 = l2_;
                return vec2<f32>(max(0f, _e89), _e91);
            }
        }
    }
    return vec2<f32>(-1f, -1f);
}

fn moebiusRayMarch(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_6: f32, twistCount_4: f32, phase_4: f32) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_7: f32;
    var twistCount_5: f32;
    var phase_5: f32;
    var minDist: f32 = 1000000000f;
    var k: f32 = 0f;
    var kBounds: vec2<f32>;
    var kk: f32;
    var de: f32 = 0.0001f;
    var maxIter: i32 = 1256i;
    var iter: i32 = 0i;
    var p_4: vec3<f32>;
    var dist: f32;
    var local_2: vec3<f32>;

    origin_3 = origin_2;
    dir_3 = dir_2;
    radius_7 = radius_6;
    twistCount_5 = twistCount_4;
    phase_5 = phase_4;
    let _e24 = radius_7;
    let _e29 = origin_3;
    let _e30 = dir_3;
    let _e31 = moebiusBoundingSphereK(vec3(0f), (0.5f * (1f + (_e24 * 1.42f))), _e29, _e30);
    kBounds = _e31;
    let _e33 = kBounds;
    kk = _e33.x;
    let _e36 = kk;
    if (_e36 < 0f) {
        let _e39 = kk;
        let _e41 = minDist;
        return vec3<f32>(_e39, 0f, _e41);
    }
    let _e49 = origin_3;
    p_4 = _e49;
    let _e51 = p_4;
    let _e52 = radius_7;
    let _e53 = twistCount_5;
    let _e54 = phase_5;
    let _e55 = moebiusImplicitFn(_e51, _e52, _e53, _e54);
    dist = _e55;
    loop {
        let _e57 = dist;
        let _e59 = de;
        let _e61 = iter;
        let _e62 = maxIter;
        if !(((abs(_e57) > _e59) && (_e61 < _e62))) {
            break;
        }
        {
            let _e66 = k;
            let _e67 = dist;
            k = (_e66 + abs((_e67 * 0.25f)));
            let _e72 = origin_3;
            let _e73 = k;
            let _e74 = dir_3;
            p_4 = (_e72 + (_e73 * _e74));
            let _e77 = p_4;
            let _e78 = radius_7;
            let _e79 = twistCount_5;
            let _e80 = phase_5;
            let _e81 = moebiusImplicitFn(_e77, _e78, _e79, _e80);
            dist = _e81;
            let _e82 = minDist;
            let _e83 = dist;
            minDist = min(_e82, abs(_e83));
            let _e86 = iter;
            iter = (_e86 + 1i);
        }
    }
    let _e89 = dist;
    let _e90 = de;
    if (_e89 < _e90) {
        let _e92 = k;
        let _e93 = iter;
        let _e95 = minDist;
        local_2 = vec3<f32>(_e92, f32(_e93), _e95);
    } else {
        let _e99 = iter;
        let _e101 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e99), _e101);
    }
    let _e104 = local_2;
    return _e104;
}

fn tf(m: mat3x3<f32>, u_1: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_2: vec2<f32>;

    m_1 = m;
    u_2 = u_1;
    let _e10 = m_1;
    let _e11 = u_2;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn moebiusTorusGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, texTransform: mat3x3<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, radius_8: f32, count: i32, phase_6: f32, blend: f32, colorScheme: f32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, fogColor: vec4<f32>, specular: f32, lightDistance: f32, lightAngleX: f32, lightAngleY: f32, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var texTransform_1: mat3x3<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var radius_9: f32;
    var count_1: i32;
    var phase_7: f32;
    var blend_1: f32;
    var colorScheme_1: f32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var fogColor_1: vec4<f32>;
    var specular_1: f32;
    var lightDistance_1: f32;
    var lightAngleX_1: f32;
    var lightAngleY_1: f32;
    var backgroundStyle_1: i32;
    var invModelTransform: mat4x4<f32>;
    var invTt: mat3x3<f32>;
    var _caX: f32;
    var _saX: f32;
    var _caY: f32;
    var _saY: f32;
    var lightPos: vec3<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_4: vec3<f32>;
    var twistCount_6: f32;
    var scaledBlend: f32;
    var scaledSpecular: f32;
    var origin_4: vec3<f32>;
    var inters: vec3<f32>;
    var k_1: f32;
    var ratio: f32;
    var width: f32;
    var height: f32;
    var bWidth: f32;
    var bHeight: f32;
    var intersection: vec3<f32>;
    var R_1: f32 = 0.5f;
    var angle_1: f32;
    var twist_1: f32;
    var x: f32;
    var a_2: f32;
    var y: f32;
    var col: vec4<f32>;
    var u00_: vec2<f32>;
    var u10_: vec2<f32>;
    var u01_: vec2<f32>;
    var u11_: vec2<f32>;
    var normal: vec3<f32>;
    var lightDir: vec3<f32>;
    var incidence: f32;
    var dist_1: f32;
    var fog: f32;
    var bkg: vec4<f32> = vec4(0f);
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio: f32;
    var _o_X: f32 = 0.5f;
    var _o_Y: f32 = 0.5f;
    var fog_1: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    texTransform_1 = texTransform;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    reflectivity_1 = reflectivity;
    radius_9 = radius_8;
    count_1 = count;
    phase_7 = phase_6;
    blend_1 = blend;
    colorScheme_1 = colorScheme;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    fogColor_1 = fogColor;
    specular_1 = specular;
    lightDistance_1 = lightDistance;
    lightAngleX_1 = lightAngleX;
    lightAngleY_1 = lightAngleY;
    backgroundStyle_1 = backgroundStyle;
    let _e46 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e46);
    let _e49 = texTransform_1;
    invTt = _naga_inverse_3x3_f32(_e49);
    let _e52 = lightAngleX_1;
    _caX = cos(_e52);
    let _e55 = lightAngleX_1;
    _saX = sin(_e55);
    let _e58 = lightAngleY_1;
    _caY = cos(_e58);
    let _e61 = lightAngleY_1;
    _saY = sin(_e61);
    let _e64 = lightDistance_1;
    let _e65 = _caX;
    let _e67 = _saY;
    let _e69 = lightDistance_1;
    let _e71 = _saX;
    let _e73 = lightDistance_1;
    let _e74 = _caX;
    let _e76 = _caY;
    lightPos = vec3<f32>(((_e64 * _e65) * _e67), (-(_e69) * _e71), ((_e73 * _e74) * _e76));
    let _e80 = invModelTransform;
    cameraPos = (_e80 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e91 = pos_1;
    let _e93 = D;
    let _e95 = pos_1;
    let _e97 = D;
    dir_4 = normalize(vec3<f32>((_e91.x * _e93), (_e95.y * _e97), -1f));
    let _e104 = invModelTransform;
    let _e114 = dir_4;
    dir_4 = (mat3x3<f32>(_e104[0].xyz, _e104[1].xyz, _e104[2].xyz) * _e114);
    let _e116 = count_1;
    twistCount_6 = (f32(_e116) - 1f);
    let _e121 = blend_1;
    scaledBlend = (_e121 * 0.005f);
    let _e125 = specular_1;
    scaledSpecular = (_e125 * 0.01f);
    let _e129 = cameraPos;
    origin_4 = _e129;
    let _e131 = origin_4;
    let _e132 = dir_4;
    let _e133 = radius_9;
    let _e134 = twistCount_6;
    let _e135 = phase_7;
    let _e136 = moebiusRayMarch(_e131, _e132, _e133, _e134, _e135);
    inters = _e136;
    let _e138 = inters;
    k_1 = _e138.x;
    let _e141 = sourceDim_1;
    let _e143 = sourceDim_1;
    ratio = (_e141.x / _e143.y);
    let _e147 = ratio;
    let _e149 = scaledBlend;
    width = (_e147 * (1f - _e149));
    let _e154 = scaledBlend;
    height = (1f - _e154);
    let _e157 = width;
    let _e158 = ratio;
    let _e159 = scaledBlend;
    bWidth = (_e157 - (_e158 * _e159));
    let _e163 = height;
    let _e164 = scaledBlend;
    bHeight = (_e163 - _e164);
    let _e167 = k_1;
    if (_e167 > 0f) {
        {
            let _e170 = origin_4;
            let _e171 = k_1;
            let _e172 = dir_4;
            intersection = (_e170 + (_e171 * _e172));
            let _e178 = intersection;
            let _e181 = intersection;
            angle_1 = atan2(-(_e178.x), -(_e181.y));
            let _e186 = angle_1;
            let _e189 = twistCount_6;
            let _e191 = phase_7;
            twist_1 = (((_e186 * 0.25f) * _e189) + _e191);
            let _e194 = angle_1;
            let _e197 = width;
            x = ((_e194 / 3.1415927f) * _e197);
            let _e200 = intersection;
            let _e202 = intersection;
            let _e205 = intersection;
            let _e207 = intersection;
            let _e212 = R_1;
            a_2 = (sqrt(((_e200.x * _e202.x) + (_e205.y * _e207.y))) - _e212);
            let _e215 = a_2;
            let _e216 = intersection;
            let _e223 = twist_1;
            let _e227 = height;
            y = ((((atan2(_e215, _e216.z) + 0.7853982f) - _e223) / 3.1415927f) * _e227);
            let _e231 = invTt;
            let _e232 = x;
            let _e233 = y;
            let _e235 = tf(_e231, vec2<f32>(_e232, _e233));
            u00_ = _e235;
            let _e237 = scaledBlend;
            if (_e237 == 0f) {
                let _e240 = u00_;
                let _e244 = global.U[0];
                let _e247 = u00_;
                let _e256 = textureSample(t_source, samp, ((vec2<f32>((_e240.x / _e244.x), _e247.y) / vec2(2f)) + vec2(0.5f)));
                col = _e256;
            } else {
                {
                    let _e257 = invTt;
                    let _e258 = x;
                    let _e259 = x;
                    let _e261 = ratio;
                    let _e262 = bWidth;
                    let _e266 = y;
                    let _e268 = tf(_e257, vec2<f32>((_e258 - (sign(_e259) * (_e261 + _e262))), _e266));
                    u10_ = _e268;
                    let _e270 = invTt;
                    let _e271 = x;
                    let _e272 = y;
                    let _e273 = y;
                    let _e276 = bHeight;
                    let _e281 = tf(_e270, vec2<f32>(_e271, (_e272 - (sign(_e273) * (1f + _e276)))));
                    u01_ = _e281;
                    let _e283 = invTt;
                    let _e284 = x;
                    let _e285 = x;
                    let _e287 = ratio;
                    let _e288 = bWidth;
                    let _e292 = y;
                    let _e293 = y;
                    let _e296 = bHeight;
                    let _e301 = tf(_e283, vec2<f32>((_e284 - (sign(_e285) * (_e287 + _e288))), (_e292 - (sign(_e293) * (1f + _e296)))));
                    u11_ = _e301;
                    let _e303 = u00_;
                    let _e307 = global.U[0];
                    let _e310 = u00_;
                    let _e319 = textureSample(t_source, samp, ((vec2<f32>((_e303.x / _e307.x), _e310.y) / vec2(2f)) + vec2(0.5f)));
                    let _e320 = u10_;
                    let _e324 = global.U[0];
                    let _e327 = u10_;
                    let _e336 = textureSample(t_source, samp, ((vec2<f32>((_e320.x / _e324.x), _e327.y) / vec2(2f)) + vec2(0.5f)));
                    let _e339 = scaledBlend;
                    let _e341 = ratio;
                    let _e343 = x;
                    let _e345 = bWidth;
                    let _e350 = u01_;
                    let _e354 = global.U[0];
                    let _e357 = u01_;
                    let _e366 = textureSample(t_source, samp, ((vec2<f32>((_e350.x / _e354.x), _e357.y) / vec2(2f)) + vec2(0.5f)));
                    let _e367 = u11_;
                    let _e371 = global.U[0];
                    let _e374 = u11_;
                    let _e383 = textureSample(t_source, samp, ((vec2<f32>((_e367.x / _e371.x), _e374.y) / vec2(2f)) + vec2(0.5f)));
                    let _e386 = scaledBlend;
                    let _e388 = ratio;
                    let _e390 = x;
                    let _e392 = bWidth;
                    let _e399 = scaledBlend;
                    let _e401 = y;
                    let _e403 = bHeight;
                    col = mix(mix(_e319, _e336, vec4(smoothstep(0f, ((2f * _e339) * _e341), (abs(_e343) - _e345)))), mix(_e366, _e383, vec4(smoothstep(0f, ((2f * _e386) * _e388), (abs(_e390) - _e392)))), vec4(smoothstep(0f, (2f * _e399), (abs(_e401) - _e403))));
                }
            }
            let _e408 = intersection;
            let _e409 = radius_9;
            let _e410 = twistCount_6;
            let _e411 = phase_7;
            let _e412 = moebiusNormal(_e408, _e409, _e410, _e411);
            normal = _e412;
            let _e414 = colorScheme_1;
            if (_e414 != 0f) {
                let _e417 = col;
                let _e419 = col;
                let _e421 = normal;
                let _e423 = colorScheme_1;
                let _e427 = mix(_e419.xyz, _e421.xyz, vec3((_e423 * 0.01f)));
                col.x = _e427.x;
                col.y = _e427.y;
                col.z = _e427.z;
            }
            let _e434 = lightPos;
            let _e435 = intersection;
            lightDir = normalize((_e434 - _e435));
            let _e441 = normal;
            let _e443 = lightDir;
            incidence = smoothstep(0f, 1f, dot(-(_e441), _e443));
            let _e447 = incidence;
            let _e450 = sourceColor_1;
            let _e452 = sourceColor_1;
            let _e455 = sourceColor_1;
            if ((_e447 > 0f) && (((_e450.x + _e452.y) + _e455.z) > 0f)) {
                {
                    let _e461 = intersection;
                    let _e462 = lightDir;
                    let _e466 = lightDir;
                    let _e467 = radius_9;
                    let _e468 = twistCount_6;
                    let _e469 = phase_7;
                    let _e470 = moebiusRayMarch((_e461 + (_e462 * 0.001f)), _e466, _e467, _e468, _e469);
                    if (_e470.x > 0f) {
                        incidence = 0f;
                    }
                }
            }
            let _e475 = col;
            let _e477 = ambientColor_1;
            let _e481 = col;
            let _e484 = sourceColor_1;
            let _e486 = incidence;
            let _e488 = col;
            let _e491 = (((_e477.xyz * 2f) * _e481.xyz) + ((_e484.xyz * _e486) * _e488.xyz));
            col.x = _e491.x;
            col.y = _e491.y;
            col.z = _e491.z;
            let _e498 = col;
            let _e500 = col;
            let _e503 = scaledSpecular;
            let _e506 = specular_1;
            let _e510 = lightDir;
            let _e511 = cameraPos;
            let _e512 = intersection;
            let _e515 = normal;
            let _e520 = sourceColor_1;
            let _e523 = (_e500.xyz + (smoothstep((1f - _e503), (1.01f - (_e506 * 0.0001f)), dot(_e510, -(reflect(normalize((_e511 - _e512)), _e515)))) * _e520.xyz));
            col.x = _e523.x;
            col.y = _e523.y;
            col.z = _e523.z;
            let _e530 = origin_4;
            let _e531 = intersection;
            dist_1 = length((_e530 - _e531));
            let _e535 = dist_1;
            let _e542 = fogColor_1;
            fog = (max(((_e535 - 0.5f) * 4f), 0f) * _e542.w);
            let _e546 = col;
            let _e548 = fogColor_1;
            let _e550 = fog;
            let _e552 = mix(_e546.xyz, _e548.xyz, vec3(_e550));
            let _e553 = col;
            return vec4<f32>(_e552.x, _e552.y, _e552.z, _e553.w);
        }
    } else {
        {
            let _e562 = backgroundStyle_1;
            if (_e562 == 0i) {
                {
                    let _e565 = dir_4;
                    _o_n = normalize(_e565);
                    let _e568 = _o_n;
                    let _e570 = _o_n;
                    _o_alpha = atan2(_e568.z, _e570.x);
                    let _e574 = _o_n;
                    _o_beta = asin(_e574.y);
                    let _e578 = _o_alpha;
                    let _e585 = _o_beta;
                    let _e593 = global.U[0];
                    let _e596 = _o_alpha;
                    let _e603 = _o_beta;
                    let _e616 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e578) / 3.1415927f) * 2f), ((2f * _e585) / 3.1415927f)).x / _e593.x), vec2<f32>(((-(_e596) / 3.1415927f) * 2f), ((2f * _e603) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
                    bkg = _e616;
                }
            } else {
                let _e617 = backgroundStyle_1;
                if (_e617 == 1i) {
                    {
                        let _e620 = dir_4;
                        let _e623 = dir_4;
                        let _e626 = dir_4;
                        let _e629 = dir_4;
                        _o_pos = vec2<f32>((-(_e620.x) / _e623.z), (-(_e626.y) / _e629.z));
                        let _e634 = _o_pos;
                        let _e637 = _o_pos;
                        _o_m = max(abs(_e634.x), abs(_e637.y));
                        let _e644 = _o_m;
                        _o_darken = (4f / max(4f, _e644));
                        let _e648 = _o_pos;
                        let _e652 = global.U[0];
                        let _e655 = _o_pos;
                        let _e664 = textureSample(t_source, samp, ((vec2<f32>((_e648.x / _e652.x), _e655.y) / vec2(2f)) + vec2(0.5f)));
                        let _e665 = _o_darken;
                        let _e666 = _o_darken;
                        let _e667 = _o_darken;
                        bkg = (_e664 * vec4<f32>(_e665, _e666, _e667, 1f));
                    }
                } else {
                    let _e671 = backgroundStyle_1;
                    if (_e671 == 2i) {
                        {
                            let _e674 = sourceDim_1;
                            let _e676 = sourceDim_1;
                            _o_ratio = (_e674.y / _e676.x);
                            let _e684 = dir_4;
                            let _e687 = dir_4;
                            let _e690 = _o_ratio;
                            let _e693 = dir_4;
                            let _e696 = dir_4;
                            let _e699 = _o_ratio;
                            if ((abs(_e684.y) > (abs(_e687.z) * _e690)) && (abs(_e693.y) > (abs(_e696.x) * _e699))) {
                                {
                                    let _e703 = _o_X;
                                    let _e704 = dir_4;
                                    let _e707 = dir_4;
                                    _o_X = (_e703 + ((-(_e704.x) / _e707.y) * 0.5f));
                                    let _e713 = _o_Y;
                                    let _e714 = dir_4;
                                    let _e717 = dir_4;
                                    _o_Y = (_e713 + ((-(_e714.z) / _e717.y) * 0.5f));
                                }
                            } else {
                                let _e723 = dir_4;
                                let _e726 = dir_4;
                                if (abs(_e723.x) < abs(_e726.z)) {
                                    {
                                        let _e730 = _o_X;
                                        let _e731 = dir_4;
                                        let _e733 = dir_4;
                                        let _e737 = _o_ratio;
                                        let _e741 = dir_4;
                                        _o_X = (_e730 + ((((_e731.x / abs(_e733.z)) * _e737) * 0.5f) * -(sign(_e741.z))));
                                        let _e747 = _o_Y;
                                        let _e748 = dir_4;
                                        let _e750 = dir_4;
                                        _o_Y = (_e747 + ((_e748.y / abs(_e750.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e757 = _o_X;
                                        let _e758 = dir_4;
                                        let _e760 = dir_4;
                                        let _e764 = _o_ratio;
                                        let _e768 = dir_4;
                                        _o_X = (_e757 + ((((_e758.z / abs(_e760.x)) * _e764) * 0.5f) * -(sign(_e768.x))));
                                        let _e774 = _o_Y;
                                        let _e775 = dir_4;
                                        let _e777 = dir_4;
                                        _o_Y = (_e774 + ((_e775.y / abs(_e777.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e784 = _o_X;
                            let _e785 = _o_Y;
                            let _e795 = global.U[0];
                            let _e798 = _o_X;
                            let _e799 = _o_Y;
                            let _e814 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e784, _e785) * 2f) - vec2(1f)).x / _e795.x), ((vec2<f32>(_e798, _e799) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            bkg = _e814;
                        }
                    } else {
                        {
                            let _e815 = dir_4;
                            let _e820 = ((_e815 * 0.5f) + vec3(0.5f));
                            bkg = vec4<f32>(_e820.x, _e820.y, _e820.z, 1f);
                        }
                    }
                }
            }
            let _e833 = fogColor_1;
            fog_1 = clamp((6f * _e833.w), 0f, 1f);
            let _e840 = bkg;
            let _e842 = fogColor_1;
            let _e844 = fog_1;
            let _e846 = mix(_e840.xyz, _e842.xyz, vec3(_e844));
            let _e847 = bkg;
            return vec4<f32>(_e846.x, _e846.y, _e846.z, _e847.w);
        }
    }
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
    let _e66 = global.U[6];
    let _e69 = global.U[7];
    let _e72 = global.U[8];
    let _e75 = global.U[9];
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e124 = global.U[4];
    let _e128 = global.U[13];
    let _e132 = global.U[14];
    let _e136 = global.U[15];
    let _e140 = global.U[16];
    let _e145 = global.U[17];
    let _e149 = global.U[18];
    let _e153 = global.U[19];
    let _e157 = global.U[20];
    let _e160 = global.U[21];
    let _e163 = global.U[22];
    let _e166 = global.U[23];
    let _e170 = global.U[24];
    let _e174 = global.U[25];
    let _e178 = global.U[26];
    let _e182 = global.U[27];
    let _e185 = moebiusTorusGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)), _e124.xy, _e128.x, _e132.x, _e136.x, i32(_e140.x), _e145.x, _e149.x, _e153.x, _e157, _e160, _e163, _e166.x, _e170.x, _e174.x, _e178.x, i32(_e182.x));
    fragColor = _e185;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
}

fn _naga_inverse_4x4_f32(m: mat4x4<f32>) -> mat4x4<f32> {
   let sub_factor00: f32 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
   let sub_factor01: f32 = m[2][1] * m[3][3] - m[3][1] * m[2][3];
   let sub_factor02: f32 = m[2][1] * m[3][2] - m[3][1] * m[2][2];
   let sub_factor03: f32 = m[2][0] * m[3][3] - m[3][0] * m[2][3];
   let sub_factor04: f32 = m[2][0] * m[3][2] - m[3][0] * m[2][2];
   let sub_factor05: f32 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
   let sub_factor06: f32 = m[1][2] * m[3][3] - m[3][2] * m[1][3];
   let sub_factor07: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor08: f32 = m[1][1] * m[3][2] - m[3][1] * m[1][2];
   let sub_factor09: f32 = m[1][0] * m[3][3] - m[3][0] * m[1][3];
   let sub_factor10: f32 = m[1][0] * m[3][2] - m[3][0] * m[1][2];
   let sub_factor11: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor12: f32 = m[1][0] * m[3][1] - m[3][0] * m[1][1];
   let sub_factor13: f32 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
   let sub_factor14: f32 = m[1][1] * m[2][3] - m[2][1] * m[1][3];
   let sub_factor15: f32 = m[1][1] * m[2][2] - m[2][1] * m[1][2];
   let sub_factor16: f32 = m[1][0] * m[2][3] - m[2][0] * m[1][3];
   let sub_factor17: f32 = m[1][0] * m[2][2] - m[2][0] * m[1][2];
   let sub_factor18: f32 = m[1][0] * m[2][1] - m[2][0] * m[1][1];

   var adj: mat4x4<f32>;
   adj[0][0] =   (m[1][1] * sub_factor00 - m[1][2] * sub_factor01 + m[1][3] * sub_factor02);
   adj[1][0] = - (m[1][0] * sub_factor00 - m[1][2] * sub_factor03 + m[1][3] * sub_factor04);
   adj[2][0] =   (m[1][0] * sub_factor01 - m[1][1] * sub_factor03 + m[1][3] * sub_factor05);
   adj[3][0] = - (m[1][0] * sub_factor02 - m[1][1] * sub_factor04 + m[1][2] * sub_factor05);
   adj[0][1] = - (m[0][1] * sub_factor00 - m[0][2] * sub_factor01 + m[0][3] * sub_factor02);
   adj[1][1] =   (m[0][0] * sub_factor00 - m[0][2] * sub_factor03 + m[0][3] * sub_factor04);
   adj[2][1] = - (m[0][0] * sub_factor01 - m[0][1] * sub_factor03 + m[0][3] * sub_factor05);
   adj[3][1] =   (m[0][0] * sub_factor02 - m[0][1] * sub_factor04 + m[0][2] * sub_factor05);
   adj[0][2] =   (m[0][1] * sub_factor06 - m[0][2] * sub_factor07 + m[0][3] * sub_factor08);
   adj[1][2] = - (m[0][0] * sub_factor06 - m[0][2] * sub_factor09 + m[0][3] * sub_factor10);
   adj[2][2] =   (m[0][0] * sub_factor11 - m[0][1] * sub_factor09 + m[0][3] * sub_factor12);
   adj[3][2] = - (m[0][0] * sub_factor08 - m[0][1] * sub_factor10 + m[0][2] * sub_factor12);
   adj[0][3] = - (m[0][1] * sub_factor13 - m[0][2] * sub_factor14 + m[0][3] * sub_factor15);
   adj[1][3] =   (m[0][0] * sub_factor13 - m[0][2] * sub_factor16 + m[0][3] * sub_factor17);
   adj[2][3] = - (m[0][0] * sub_factor14 - m[0][1] * sub_factor16 + m[0][3] * sub_factor18);
   adj[3][3] =   (m[0][0] * sub_factor15 - m[0][1] * sub_factor17 + m[0][2] * sub_factor18);

   let det = (m[0][0] * adj[0][0] + m[0][1] * adj[1][0] + m[0][2] * adj[2][0] + m[0][3] * adj[3][0]);

   return adj * (1 / det);
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
