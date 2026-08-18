struct Params {
    U: array<vec4<f32>, 27>,
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

fn getFog(dist: f32, alpha: f32) -> f32 {
    var dist_1: f32;
    var alpha_1: f32;

    dist_1 = dist;
    alpha_1 = alpha;
    let _e10 = dist_1;
    let _e17 = alpha_1;
    return (max(((_e10 - 0.5f) * 4f), 0f) * _e17);
}

fn implicitFn(p: vec3<f32>, radius: f32, count: i32, roundness: f32, angle: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var count_1: i32;
    var roundness_1: f32;
    var angle_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;
    var ang: f32;
    var ca: f32;
    var sa: f32;
    var rot: mat2x2<f32>;
    var q: vec2<f32>;
    var d: vec2<f32>;
    var compensation: f32;

    p_1 = p;
    radius_1 = radius;
    count_1 = count;
    roundness_1 = roundness;
    angle_1 = angle;
    let _e18 = R;
    let _e19 = radius_1;
    r = (_e18 * _e19);
    let _e22 = p_1;
    let _e24 = p_1;
    let _e27 = p_1;
    let _e29 = p_1;
    let _e34 = R;
    a = (sqrt(((_e22.x * _e24.x) + (_e27.z * _e29.z))) - _e34);
    let _e37 = angle_1;
    let _e38 = p_1;
    let _e40 = p_1;
    let _e45 = count_1;
    ang = (_e37 + ((atan2(_e38.z, _e40.x) * 0.25f) * (f32(_e45) - 1f)));
    let _e52 = ang;
    ca = cos(_e52);
    let _e55 = ang;
    sa = sin(_e55);
    let _e58 = ca;
    let _e59 = sa;
    let _e60 = sa;
    let _e61 = ca;
    rot = mat2x2<f32>(vec2<f32>(_e58, _e59), vec2<f32>(_e60, -(_e61)));
    let _e67 = rot;
    let _e68 = a;
    let _e69 = p_1;
    q = (_e67 * vec2<f32>(_e68, _e69.y));
    let _e74 = q;
    let _e76 = r;
    d = (abs(_e74) - vec2(_e76));
    let _e82 = count_1;
    compensation = mix(0.7f, 0.2f, (f32(_e82) * 0.01f));
    let _e88 = compensation;
    let _e89 = d;
    let _e94 = d;
    let _e96 = d;
    let _e103 = roundness_1;
    return ((_e88 * (length(max(_e89, vec2(0f))) + min(max(_e94.x, _e96.y), 0f))) - _e103);
}

fn sphereIntersectionSpec(center: vec3<f32>, radius_2: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_3: f32;
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
    radius_3 = radius_2;
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
    let _e31 = radius_3;
    let _e32 = radius_3;
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
                {
                    let _e89 = l1_;
                    let _e91 = l2_;
                    return vec2<f32>(max(0f, _e89), _e91);
                }
            }
        }
    }
    return vec2<f32>(-1f, -1f);
}

fn getIntersectionD(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_4: f32, count_2: i32, roundness_2: f32, angle_2: f32) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_5: f32;
    var count_3: i32;
    var roundness_3: f32;
    var angle_3: f32;
    var minDist: f32 = 1000000000f;
    var k: f32 = 0f;
    var de: f32 = 0.0001f;
    var maxIter: i32 = 1256i;
    var iter: i32 = 0i;
    var p_2: vec3<f32>;
    var dist_2: f32;
    var local_2: vec3<f32>;

    origin_3 = origin_2;
    dir_3 = dir_2;
    radius_5 = radius_4;
    count_3 = count_2;
    roundness_3 = roundness_2;
    angle_3 = angle_2;
    let _e28 = origin_3;
    p_2 = _e28;
    let _e30 = p_2;
    let _e31 = radius_5;
    let _e32 = count_3;
    let _e33 = roundness_3;
    let _e34 = angle_3;
    let _e35 = implicitFn(_e30, _e31, _e32, _e33, _e34);
    dist_2 = _e35;
    loop {
        let _e37 = dist_2;
        let _e39 = de;
        let _e41 = iter;
        let _e42 = maxIter;
        if !(((abs(_e37) > _e39) && (_e41 < _e42))) {
            break;
        }
        {
            let _e46 = k;
            let _e47 = dist_2;
            k = (_e46 + abs(_e47));
            let _e50 = origin_3;
            let _e51 = k;
            let _e52 = dir_3;
            p_2 = (_e50 + (_e51 * _e52));
            let _e55 = p_2;
            let _e56 = radius_5;
            let _e57 = count_3;
            let _e58 = roundness_3;
            let _e59 = angle_3;
            let _e60 = implicitFn(_e55, _e56, _e57, _e58, _e59);
            dist_2 = _e60;
            let _e61 = minDist;
            let _e62 = dist_2;
            minDist = min(_e61, abs(_e62));
            let _e65 = iter;
            iter = (_e65 + 1i);
        }
    }
    let _e68 = dist_2;
    let _e69 = de;
    if (_e68 < _e69) {
        let _e71 = k;
        let _e72 = iter;
        let _e73 = minDist;
        local_2 = vec3<f32>(_e71, f32(_e72), _e73);
    } else {
        let _e78 = iter;
        let _e79 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e78), _e79);
    }
    let _e83 = local_2;
    return _e83;
}

fn getNormal(p_3: vec3<f32>, radius_6: f32, count_4: i32, roundness_4: f32, angle_4: f32) -> vec3<f32> {
    var p_4: vec3<f32>;
    var radius_7: f32;
    var count_5: i32;
    var roundness_5: f32;
    var angle_5: f32;
    var d_1: f32 = 0.0001f;
    var d2_: f32;

    p_4 = p_3;
    radius_7 = radius_6;
    count_5 = count_4;
    roundness_5 = roundness_4;
    angle_5 = angle_4;
    let _e18 = d_1;
    d2_ = (_e18 * 2f);
    let _e22 = p_4;
    let _e24 = d_1;
    let _e26 = p_4;
    let _e28 = p_4;
    let _e31 = radius_7;
    let _e32 = count_5;
    let _e33 = roundness_5;
    let _e34 = angle_5;
    let _e35 = implicitFn(vec3<f32>((_e22.x - _e24), _e26.y, _e28.z), _e31, _e32, _e33, _e34);
    let _e36 = p_4;
    let _e38 = d_1;
    let _e40 = p_4;
    let _e42 = p_4;
    let _e45 = radius_7;
    let _e46 = count_5;
    let _e47 = roundness_5;
    let _e48 = angle_5;
    let _e49 = implicitFn(vec3<f32>((_e36.x + _e38), _e40.y, _e42.z), _e45, _e46, _e47, _e48);
    let _e51 = d2_;
    let _e53 = p_4;
    let _e55 = p_4;
    let _e57 = d_1;
    let _e59 = p_4;
    let _e62 = radius_7;
    let _e63 = count_5;
    let _e64 = roundness_5;
    let _e65 = angle_5;
    let _e66 = implicitFn(vec3<f32>(_e53.x, (_e55.y - _e57), _e59.z), _e62, _e63, _e64, _e65);
    let _e67 = p_4;
    let _e69 = p_4;
    let _e71 = d_1;
    let _e73 = p_4;
    let _e76 = radius_7;
    let _e77 = count_5;
    let _e78 = roundness_5;
    let _e79 = angle_5;
    let _e80 = implicitFn(vec3<f32>(_e67.x, (_e69.y + _e71), _e73.z), _e76, _e77, _e78, _e79);
    let _e82 = d2_;
    let _e84 = p_4;
    let _e86 = p_4;
    let _e88 = p_4;
    let _e90 = d_1;
    let _e93 = radius_7;
    let _e94 = count_5;
    let _e95 = roundness_5;
    let _e96 = angle_5;
    let _e97 = implicitFn(vec3<f32>(_e84.x, _e86.y, (_e88.z - _e90)), _e93, _e94, _e95, _e96);
    let _e98 = p_4;
    let _e100 = p_4;
    let _e102 = p_4;
    let _e104 = d_1;
    let _e107 = radius_7;
    let _e108 = count_5;
    let _e109 = roundness_5;
    let _e110 = angle_5;
    let _e111 = implicitFn(vec3<f32>(_e98.x, _e100.y, (_e102.z + _e104)), _e107, _e108, _e109, _e110);
    let _e113 = d2_;
    return normalize(vec3<f32>(((_e35 - _e49) / _e51), ((_e66 - _e80) / _e82), ((_e97 - _e111) / _e113)));
}

fn rayMarch(p0_: vec3<f32>, dir_4: vec3<f32>, side: f32, radius_8: f32, count_6: i32, roundness_6: f32, angle_6: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_5: vec3<f32>;
    var side_1: f32;
    var radius_9: f32;
    var count_7: i32;
    var roundness_7: f32;
    var angle_7: f32;
    var d_2: f32;
    var s: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_5: vec3<f32>;

    p0_1 = p0_;
    dir_5 = dir_4;
    side_1 = side;
    radius_9 = radius_8;
    count_7 = count_6;
    roundness_7 = roundness_6;
    angle_7 = angle_6;
    let _e20 = p0_1;
    let _e21 = radius_9;
    let _e22 = count_7;
    let _e23 = roundness_7;
    let _e24 = angle_7;
    let _e25 = implicitFn(_e20, _e21, _e22, _e23, _e24);
    d_2 = _e25;
    let _e27 = d_2;
    s = sign(_e27);
    loop {
        let _e34 = step;
        let _e37 = d_2;
        if !(((_e34 < 1000i) && (_e37 < 100f))) {
            break;
        }
        {
            let _e42 = totalD;
            let _e43 = d_2;
            let _e44 = side_1;
            totalD = (_e42 + (_e43 * _e44));
            let _e47 = p0_1;
            let _e48 = totalD;
            let _e49 = dir_5;
            p_5 = (_e47 + (_e48 * _e49));
            let _e53 = p_5;
            let _e54 = radius_9;
            let _e55 = count_7;
            let _e56 = roundness_7;
            let _e57 = angle_7;
            let _e58 = implicitFn(_e53, _e54, _e55, _e56, _e57);
            d_2 = _e58;
            let _e59 = d_2;
            if (abs(_e59) < 0.0001f) {
                let _e63 = p_5;
                return _e63;
            }
            let _e64 = step;
            step = (_e64 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn torusMap(pos: vec2<f32>, outPos: vec2<f32>, radius_10: f32, angle_8: f32, count_8: i32, roundness_8: f32, blend: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, sourceDim: vec2<f32>, backgroundStyle: i32, specular: f32, model3DTransform: mat4x4<f32>, texTransform: mat3x3<f32>, lightSourceTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_11: f32;
    var angle_9: f32;
    var count_9: i32;
    var roundness_9: f32;
    var blend_1: f32;
    var colorFog_1: vec4<f32>;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundStyle_1: i32;
    var specular_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var texTransform_1: mat3x3<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var invTt: mat3x3<f32>;
    var lightPos: vec3<f32>;
    var D: f32 = 1.6666666f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m_2: mat4x4<f32>;
    var dir_6: vec3<f32>;
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
    var r_1: f32;
    var x: f32;
    var a_2: f32;
    var y: f32;
    var col: vec4<f32>;
    var u00_: vec2<f32>;
    var u10_: vec2<f32>;
    var u01_: vec2<f32>;
    var u11_: vec2<f32>;
    var dist_3: f32;
    var fog: f32;
    var normal: vec3<f32>;
    var lightDir: vec3<f32>;
    var colorWithLight: vec3<f32>;
    var reflectDir: vec3<f32>;
    var kSpec: f32;
    var col_1: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_ratio: f32;
    var _o_nX: f32 = 2f;
    var _o_nY: f32 = 1f;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio_1: f32;
    var _o_X: f32 = 0.5f;
    var _o_Y: f32 = 0.5f;
    var dist_4: f32 = 2f;
    var fog_1: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    radius_11 = radius_10;
    angle_9 = angle_8;
    count_9 = count_8;
    roundness_9 = roundness_8;
    blend_1 = blend;
    colorFog_1 = colorFog;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    sourceDim_1 = sourceDim;
    backgroundStyle_1 = backgroundStyle;
    specular_1 = specular;
    model3DTransform_1 = model3DTransform;
    texTransform_1 = texTransform;
    lightSourceTransform_1 = lightSourceTransform;
    let _e44 = texTransform_1;
    invTt = _naga_inverse_3x3_f32(_e44);
    let _e47 = lightSourceTransform_1;
    lightPos = (_e47 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e63 = model3DTransform_1;
    m_2 = _naga_inverse_4x4_f32(_e63);
    let _e66 = m_2;
    let _e67 = cameraPos;
    cameraPos = (_e66 * vec4<f32>(_e67.x, _e67.y, _e67.z, 1f)).xyz;
    let _e75 = pos_1;
    let _e77 = D;
    let _e79 = pos_1;
    let _e81 = D;
    dir_6 = normalize(vec3<f32>((_e75.x * _e77), (_e79.y * _e81), -1f));
    let _e88 = m_2;
    let _e98 = dir_6;
    dir_6 = normalize((mat3x3<f32>(_e88[0].xyz, _e88[1].xyz, _e88[2].xyz) * _e98));
    let _e101 = cameraPos;
    origin_4 = _e101;
    let _e103 = origin_4;
    let _e104 = dir_6;
    let _e105 = radius_11;
    let _e106 = count_9;
    let _e107 = roundness_9;
    let _e108 = angle_9;
    let _e109 = getIntersectionD(_e103, _e104, _e105, _e106, _e107, _e108);
    inters = _e109;
    let _e111 = inters;
    k_1 = _e111.x;
    let _e114 = sourceDim_1;
    let _e116 = sourceDim_1;
    ratio = (_e114.x / _e116.y);
    let _e120 = blend_1;
    blend_1 = (_e120 * 0.5f);
    let _e123 = ratio;
    let _e125 = blend_1;
    width = (_e123 * (1f - _e125));
    let _e130 = blend_1;
    height = (1f - _e130);
    let _e133 = width;
    let _e134 = ratio;
    let _e135 = blend_1;
    bWidth = (_e133 - (_e134 * _e135));
    let _e139 = height;
    let _e140 = blend_1;
    bHeight = (_e139 - _e140);
    let _e143 = k_1;
    if (_e143 > 0f) {
        {
            let _e146 = origin_4;
            let _e147 = k_1;
            let _e148 = dir_6;
            intersection = (_e146 + (_e147 * _e148));
            let _e154 = R_1;
            let _e155 = radius_11;
            r_1 = ((_e154 * _e155) * 2f);
            let _e160 = intersection;
            let _e162 = intersection;
            let _e167 = width;
            x = ((atan2(_e160.x, _e162.z) / 3.1415927f) * _e167);
            let _e170 = intersection;
            let _e172 = intersection;
            let _e175 = intersection;
            let _e177 = intersection;
            let _e182 = R_1;
            a_2 = (sqrt(((_e170.x * _e172.x) + (_e175.z * _e177.z))) - _e182);
            let _e185 = a_2;
            let _e186 = intersection;
            let _e192 = height;
            y = ((atan2(_e185, -(_e186.y)) / 3.1415927f) * _e192);
            let _e196 = blend_1;
            if (_e196 == 0f) {
                let _e199 = invTt;
                let _e200 = x;
                let _e201 = y;
                let _e203 = tf(_e199, vec2<f32>(_e200, _e201));
                let _e207 = global.U[0];
                let _e210 = invTt;
                let _e211 = x;
                let _e212 = y;
                let _e214 = tf(_e210, vec2<f32>(_e211, _e212));
                let _e224 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e203.x / _e207.x), _e214.y) / vec2(2f)) + vec2(0.5f)), 0f);
                col = _e224;
            } else {
                {
                    let _e225 = invTt;
                    let _e226 = x;
                    let _e227 = y;
                    let _e229 = tf(_e225, vec2<f32>(_e226, _e227));
                    u00_ = _e229;
                    let _e231 = invTt;
                    let _e232 = x;
                    let _e233 = x;
                    let _e235 = ratio;
                    let _e236 = bWidth;
                    let _e240 = y;
                    let _e242 = tf(_e231, vec2<f32>((_e232 - (sign(_e233) * (_e235 + _e236))), _e240));
                    u10_ = _e242;
                    let _e244 = invTt;
                    let _e245 = x;
                    let _e246 = y;
                    let _e247 = y;
                    let _e250 = bHeight;
                    let _e255 = tf(_e244, vec2<f32>(_e245, (_e246 - (sign(_e247) * (1f + _e250)))));
                    u01_ = _e255;
                    let _e257 = invTt;
                    let _e258 = x;
                    let _e259 = x;
                    let _e261 = ratio;
                    let _e262 = bWidth;
                    let _e266 = y;
                    let _e267 = y;
                    let _e270 = bHeight;
                    let _e275 = tf(_e257, vec2<f32>((_e258 - (sign(_e259) * (_e261 + _e262))), (_e266 - (sign(_e267) * (1f + _e270)))));
                    u11_ = _e275;
                    let _e277 = u00_;
                    let _e281 = global.U[0];
                    let _e284 = u00_;
                    let _e294 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e277.x / _e281.x), _e284.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e295 = u10_;
                    let _e299 = global.U[0];
                    let _e302 = u10_;
                    let _e312 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e295.x / _e299.x), _e302.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e315 = blend_1;
                    let _e317 = ratio;
                    let _e319 = x;
                    let _e321 = bWidth;
                    let _e326 = u01_;
                    let _e330 = global.U[0];
                    let _e333 = u01_;
                    let _e343 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e326.x / _e330.x), _e333.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e344 = u11_;
                    let _e348 = global.U[0];
                    let _e351 = u11_;
                    let _e361 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e344.x / _e348.x), _e351.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e364 = blend_1;
                    let _e366 = ratio;
                    let _e368 = x;
                    let _e370 = bWidth;
                    let _e377 = blend_1;
                    let _e379 = y;
                    let _e381 = bHeight;
                    col = mix(mix(_e294, _e312, vec4(smoothstep(0f, ((2f * _e315) * _e317), (abs(_e319) - _e321)))), mix(_e343, _e361, vec4(smoothstep(0f, ((2f * _e364) * _e366), (abs(_e368) - _e370)))), vec4(smoothstep(0f, (2f * _e377), (abs(_e379) - _e381))));
                }
            }
            let _e386 = origin_4;
            let _e387 = intersection;
            dist_3 = length((_e386 - _e387));
            let _e391 = dist_3;
            let _e392 = colorFog_1;
            let _e394 = getFog(_e391, _e392.w);
            fog = _e394;
            let _e396 = intersection;
            let _e397 = radius_11;
            let _e398 = count_9;
            let _e399 = roundness_9;
            let _e400 = angle_9;
            let _e401 = getNormal(_e396, _e397, _e398, _e399, _e400);
            normal = _e401;
            let _e403 = intersection;
            let _e404 = lightPos;
            lightDir = normalize((_e403 - _e404));
            let _e408 = col;
            let _e410 = ambientColor_1;
            let _e413 = normal;
            let _e414 = lightDir;
            let _e417 = sourceColor_1;
            colorWithLight = (_e408.xyz * (_e410.xyz + (max(0f, dot(_e413, _e414)) * _e417.xyz)));
            let _e423 = specular_1;
            if (_e423 > 0f) {
                {
                    let _e426 = dir_6;
                    let _e427 = normal;
                    reflectDir = reflect(_e426, _e427);
                    let _e431 = specular_1;
                    let _e434 = lightDir;
                    let _e436 = reflectDir;
                    kSpec = ((10f * _e431) * pow(max(0f, dot(-(_e434), _e436)), 9f));
                    let _e443 = colorWithLight;
                    let _e445 = colorWithLight;
                    let _e447 = sourceColor_1;
                    let _e449 = kSpec;
                    let _e451 = (_e445.xyz + (_e447.xyz * _e449));
                    colorWithLight.x = _e451.x;
                    colorWithLight.y = _e451.y;
                    colorWithLight.z = _e451.z;
                }
            }
            let _e458 = colorWithLight;
            let _e460 = colorFog_1;
            let _e462 = fog;
            let _e464 = mix(_e458.xyz, _e460.xyz, vec3(_e462));
            let _e465 = col;
            return vec4<f32>(_e464.x, _e464.y, _e464.z, _e465.w);
        }
    } else {
        {
            let _e477 = backgroundStyle_1;
            if (_e477 == 0i) {
                {
                    let _e480 = dir_6;
                    _o_n = normalize(_e480);
                    let _e483 = _o_n;
                    let _e485 = _o_n;
                    _o_alpha = atan2(_e483.z, _e485.x);
                    let _e489 = _o_n;
                    _o_beta = asin(_e489.y);
                    let _e493 = sourceDim_1;
                    let _e495 = sourceDim_1;
                    _o_ratio = (_e493.x / _e495.y);
                    let _e503 = _o_alpha;
                    let _e509 = _o_nX;
                    let _e512 = _o_nY;
                    let _e513 = _o_beta;
                    let _e522 = global.U[0];
                    let _e525 = _o_alpha;
                    let _e531 = _o_nX;
                    let _e534 = _o_nY;
                    let _e535 = _o_beta;
                    let _e550 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e503) / 3.1415927f) * 0.5f) * _e509), (0.5f + ((_e512 * _e513) / 3.1415927f))).x / _e522.x), vec2<f32>((((-(_e525) / 3.1415927f) * 0.5f) * _e531), (0.5f + ((_e534 * _e535) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col_1 = _e550;
                }
            } else {
                let _e551 = backgroundStyle_1;
                if (_e551 == 1i) {
                    {
                        let _e554 = dir_6;
                        let _e557 = dir_6;
                        let _e560 = dir_6;
                        let _e563 = dir_6;
                        _o_pos = (vec2<f32>((-(_e554.x) / _e557.z), (-(_e560.y) / _e563.z)) * 1f);
                        let _e570 = _o_pos;
                        let _e573 = _o_pos;
                        _o_m = max(abs(_e570.x), abs(_e573.y));
                        let _e580 = _o_m;
                        _o_darken = (4f / max(4f, _e580));
                        let _e584 = _o_pos;
                        let _e588 = global.U[0];
                        let _e591 = _o_pos;
                        let _e601 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e584.x / _e588.x), _e591.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e602 = _o_darken;
                        let _e603 = _o_darken;
                        let _e604 = _o_darken;
                        col_1 = (_e601 * vec4<f32>(_e602, _e603, _e604, 1f));
                    }
                } else {
                    let _e608 = backgroundStyle_1;
                    if (_e608 == 2i) {
                        {
                            let _e611 = sourceDim_1;
                            let _e613 = sourceDim_1;
                            _o_ratio_1 = (_e611.y / _e613.x);
                            let _e621 = dir_6;
                            let _e624 = dir_6;
                            let _e627 = _o_ratio_1;
                            let _e630 = dir_6;
                            let _e633 = dir_6;
                            let _e636 = _o_ratio_1;
                            if ((abs(_e621.y) > (abs(_e624.z) * _e627)) && (abs(_e630.y) > (abs(_e633.x) * _e636))) {
                                {
                                    let _e640 = _o_X;
                                    let _e641 = dir_6;
                                    let _e644 = dir_6;
                                    _o_X = (_e640 + ((-(_e641.x) / _e644.y) * 0.5f));
                                    let _e650 = _o_Y;
                                    let _e651 = dir_6;
                                    let _e654 = dir_6;
                                    _o_Y = (_e650 + ((-(_e651.z) / _e654.y) * 0.5f));
                                }
                            } else {
                                let _e660 = dir_6;
                                let _e663 = dir_6;
                                if (abs(_e660.x) < abs(_e663.z)) {
                                    {
                                        let _e667 = _o_X;
                                        let _e668 = dir_6;
                                        let _e670 = dir_6;
                                        let _e674 = _o_ratio_1;
                                        let _e678 = dir_6;
                                        _o_X = (_e667 + ((((_e668.x / abs(_e670.z)) * _e674) * 0.5f) * -(sign(_e678.z))));
                                        let _e684 = _o_Y;
                                        let _e685 = dir_6;
                                        let _e687 = dir_6;
                                        _o_Y = (_e684 + ((_e685.y / abs(_e687.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e694 = _o_X;
                                        let _e695 = dir_6;
                                        let _e697 = dir_6;
                                        let _e701 = _o_ratio_1;
                                        let _e705 = dir_6;
                                        _o_X = (_e694 + ((((_e695.z / abs(_e697.x)) * _e701) * 0.5f) * -(sign(_e705.x))));
                                        let _e711 = _o_Y;
                                        let _e712 = dir_6;
                                        let _e714 = dir_6;
                                        _o_Y = (_e711 + ((_e712.y / abs(_e714.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e721 = _o_X;
                            let _e722 = _o_Y;
                            let _e727 = global.U[0];
                            let _e730 = _o_X;
                            let _e731 = _o_Y;
                            let _e742 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e721, _e722).x / _e727.x), vec2<f32>(_e730, _e731).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col_1 = _e742;
                        }
                    } else {
                        let _e743 = backgroundStyle_1;
                        if (_e743 == 3i) {
                            {
                                let _e746 = dir_6;
                                let _e751 = ((_e746 * 0.5f) + vec3(0.5f));
                                col_1 = vec4<f32>(_e751.x, _e751.y, _e751.z, 1f);
                            }
                        } else {
                            let _e757 = backgroundStyle_1;
                            if (_e757 == 4i) {
                                {
                                    col_1 = vec4<f32>(0f, 0f, 0f, 1f);
                                }
                            } else {
                                {
                                    col_1 = vec4(0f);
                                }
                            }
                        }
                    }
                }
            }
            let _e769 = dist_4;
            let _e770 = colorFog_1;
            let _e772 = getFog(_e769, _e770.w);
            fog_1 = clamp(_e772, 0f, 1f);
            let _e777 = col_1;
            let _e779 = colorFog_1;
            let _e781 = fog_1;
            let _e783 = mix(_e777.xyz, _e779.xyz, vec3(_e781));
            let _e784 = col_1;
            return vec4<f32>(_e783.x, _e783.y, _e783.z, _e784.w);
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
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e79 = global.U[9];
    let _e83 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e93 = global.U[13];
    let _e96 = global.U[4];
    let _e100 = global.U[14];
    let _e105 = global.U[15];
    let _e109 = global.U[16];
    let _e112 = global.U[17];
    let _e115 = global.U[18];
    let _e118 = global.U[19];
    let _e142 = global.U[20];
    let _e143 = _e142.xyz;
    let _e146 = global.U[21];
    let _e147 = _e146.xyz;
    let _e150 = global.U[22];
    let _e151 = _e150.xyz;
    let _e167 = global.U[23];
    let _e170 = global.U[24];
    let _e173 = global.U[25];
    let _e176 = global.U[26];
    let _e198 = torusMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, i32(_e74.x), _e79.x, _e83.x, _e87, _e90, _e93, _e96.xy, i32(_e100.x), _e105.x, mat4x4<f32>(vec4<f32>(_e109.x, _e109.y, _e109.z, _e109.w), vec4<f32>(_e112.x, _e112.y, _e112.z, _e112.w), vec4<f32>(_e115.x, _e115.y, _e115.z, _e115.w), vec4<f32>(_e118.x, _e118.y, _e118.z, _e118.w)), mat3x3<f32>(vec3<f32>(_e143.x, _e143.y, _e143.z), vec3<f32>(_e147.x, _e147.y, _e147.z), vec3<f32>(_e151.x, _e151.y, _e151.z)), mat4x4<f32>(vec4<f32>(_e167.x, _e167.y, _e167.z, _e167.w), vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w)));
    fragColor = _e198;
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
