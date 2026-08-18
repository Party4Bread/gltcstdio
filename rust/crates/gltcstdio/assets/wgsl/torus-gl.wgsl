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

fn torusImplicitFn(p: vec3<f32>, radius: f32, perturbation: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var perturbation_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;

    p_1 = p;
    radius_1 = radius;
    perturbation_1 = perturbation;
    let _e14 = R;
    let _e15 = radius_1;
    r = (_e14 * _e15);
    let _e18 = perturbation_1;
    if (_e18 != 0f) {
        {
            let _e21 = p_1;
            let _e22 = perturbation_1;
            let _e25 = p_1;
            let _e34 = p_1;
            let _e42 = p_1;
            let _e51 = p_1;
            let _e59 = p_1;
            let _e68 = p_1;
            p_1 = (_e21 + ((_e22 * 0.001f) * vec3<f32>(((sin(((_e25.x * 10.1f) + 0.4f)) * 0.5f) * sin(((_e34.y * 20.1f) + 1.1f))), ((sin(((_e42.y * 10.21f) + 0.7f)) * 0.5f) * sin(((_e51.z * 20.22f) + 0.1f))), ((sin(((_e59.z * 10.021f) + 0.8f)) * 0.5f) * sin(((_e68.x * 10.9f) + 0.6f))))));
        }
    }
    let _e79 = p_1;
    let _e81 = p_1;
    let _e84 = p_1;
    let _e86 = p_1;
    let _e91 = R;
    a = (sqrt(((_e79.x * _e81.x) + (_e84.y * _e86.y))) - _e91);
    let _e94 = a;
    let _e95 = a;
    let _e97 = p_1;
    let _e99 = p_1;
    let _e104 = r;
    return (sqrt(((_e94 * _e95) + (_e97.z * _e99.z))) - _e104);
}

fn torusNormal(p_2: vec3<f32>, radius_2: f32, perturbation_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var perturbation_3: f32;
    var d: f32 = 0.0001f;
    var d2_: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    perturbation_3 = perturbation_2;
    let _e14 = d;
    d2_ = (_e14 * 2f);
    let _e18 = p_3;
    let _e20 = d;
    let _e22 = p_3;
    let _e24 = p_3;
    let _e27 = radius_3;
    let _e28 = perturbation_3;
    let _e29 = torusImplicitFn(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27, _e28);
    let _e30 = p_3;
    let _e32 = d;
    let _e34 = p_3;
    let _e36 = p_3;
    let _e39 = radius_3;
    let _e40 = perturbation_3;
    let _e41 = torusImplicitFn(vec3<f32>((_e30.x + _e32), _e34.y, _e36.z), _e39, _e40);
    let _e43 = d2_;
    let _e45 = p_3;
    let _e47 = p_3;
    let _e49 = d;
    let _e51 = p_3;
    let _e54 = radius_3;
    let _e55 = perturbation_3;
    let _e56 = torusImplicitFn(vec3<f32>(_e45.x, (_e47.y - _e49), _e51.z), _e54, _e55);
    let _e57 = p_3;
    let _e59 = p_3;
    let _e61 = d;
    let _e63 = p_3;
    let _e66 = radius_3;
    let _e67 = perturbation_3;
    let _e68 = torusImplicitFn(vec3<f32>(_e57.x, (_e59.y + _e61), _e63.z), _e66, _e67);
    let _e70 = d2_;
    let _e72 = p_3;
    let _e74 = p_3;
    let _e76 = p_3;
    let _e78 = d;
    let _e81 = radius_3;
    let _e82 = perturbation_3;
    let _e83 = torusImplicitFn(vec3<f32>(_e72.x, _e74.y, (_e76.z - _e78)), _e81, _e82);
    let _e84 = p_3;
    let _e86 = p_3;
    let _e88 = p_3;
    let _e90 = d;
    let _e93 = radius_3;
    let _e94 = perturbation_3;
    let _e95 = torusImplicitFn(vec3<f32>(_e84.x, _e86.y, (_e88.z + _e90)), _e93, _e94);
    let _e97 = d2_;
    return normalize(vec3<f32>(((_e29 - _e41) / _e43), ((_e56 - _e68) / _e70), ((_e83 - _e95) / _e97)));
}

fn torusBoundingSphereK(center: vec3<f32>, radius_4: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
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

fn torusRayMarch(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_6: f32, perturbation_4: f32, glowColor: vec4<f32>) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_7: f32;
    var perturbation_5: f32;
    var glowColor_1: vec4<f32>;
    var minDist: f32 = 1000000000f;
    var k: f32 = 0f;
    var kBounds: vec2<f32>;
    var kk: f32;
    var de: f32 = 0.0001f;
    var maxIter: i32 = 1256i;
    var iter: i32 = 0i;
    var p_4: vec3<f32>;
    var dist: f32;
    var kStep: f32;
    var local_2: vec3<f32>;

    origin_3 = origin_2;
    dir_3 = dir_2;
    radius_7 = radius_6;
    perturbation_5 = perturbation_4;
    glowColor_1 = glowColor;
    let _e20 = glowColor_1;
    let _e24 = glowColor_1;
    let _e29 = glowColor_1;
    let _e34 = perturbation_5;
    if ((((_e20.x == 0f) && (_e24.y == 0f)) && (_e29.z == 0f)) && (_e34 == 0f)) {
        {
            let _e42 = radius_7;
            let _e45 = origin_3;
            let _e46 = dir_3;
            let _e47 = torusBoundingSphereK(vec3(0f), (0.5f * (1f + _e42)), _e45, _e46);
            kBounds = _e47;
            let _e49 = kBounds;
            kk = _e49.x;
            let _e52 = kk;
            if (_e52 < 0f) {
                let _e55 = kk;
                let _e57 = minDist;
                return vec3<f32>(_e55, 0f, _e57);
            }
        }
    }
    let _e65 = origin_3;
    p_4 = _e65;
    let _e67 = p_4;
    let _e68 = radius_7;
    let _e69 = perturbation_5;
    let _e70 = torusImplicitFn(_e67, _e68, _e69);
    dist = _e70;
    let _e73 = perturbation_5;
    kStep = (1f - (_e73 * 0.005f));
    loop {
        let _e78 = dist;
        let _e80 = de;
        let _e82 = iter;
        let _e83 = maxIter;
        if !(((abs(_e78) > _e80) && (_e82 < _e83))) {
            break;
        }
        {
            let _e87 = k;
            let _e88 = dist;
            let _e90 = kStep;
            k = (_e87 + (abs(_e88) * _e90));
            let _e93 = origin_3;
            let _e94 = k;
            let _e95 = dir_3;
            p_4 = (_e93 + (_e94 * _e95));
            let _e98 = p_4;
            let _e99 = radius_7;
            let _e100 = perturbation_5;
            let _e101 = torusImplicitFn(_e98, _e99, _e100);
            dist = _e101;
            let _e102 = minDist;
            let _e103 = dist;
            minDist = min(_e102, abs(_e103));
            let _e106 = iter;
            iter = (_e106 + 1i);
        }
    }
    let _e109 = dist;
    let _e110 = de;
    if (_e109 < _e110) {
        let _e112 = k;
        let _e113 = iter;
        let _e115 = minDist;
        local_2 = vec3<f32>(_e112, f32(_e113), _e115);
    } else {
        let _e119 = iter;
        let _e121 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e119), _e121);
    }
    let _e124 = local_2;
    return _e124;
}

fn torusGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, radius_8: f32, perturbation_6: f32, objectColor: vec4<f32>, glowColor_2: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var radius_9: f32;
    var perturbation_7: f32;
    var objectColor_1: vec4<f32>;
    var glowColor_3: vec4<f32>;
    var bkgColor_1: vec4<f32>;
    var backgroundStyle_1: i32;
    var invModelTransform: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_4: vec3<f32>;
    var eta: f32;
    var origin_4: vec3<f32>;
    var maxIter_1: i32 = 12i;
    var iter_1: i32;
    var minI: i32 = -1i;
    var minK: f32 = 1000000f;
    var incidence: f32 = 2f;
    var reflectedColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var minDist_1: f32 = 1000000000f;
    var objectIntersected: bool = false;
    var inters: vec3<f32>;
    var k_1: f32;
    var intersection: vec3<f32>;
    var local_3: vec3<f32>;
    var normal: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var _reflBkg: vec4<f32>;
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio: f32;
    var _o_X: f32;
    var _o_Y: f32;
    var balance: f32;
    var _bkg: vec4<f32> = vec4(0f);
    var _o_n_1: vec3<f32>;
    var _o_alpha_1: f32;
    var _o_beta_1: f32;
    var _o_pos_1: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var mixedCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    reflectivity_1 = reflectivity;
    radius_9 = radius_8;
    perturbation_7 = perturbation_6;
    objectColor_1 = objectColor;
    glowColor_3 = glowColor_2;
    bkgColor_1 = bkgColor;
    backgroundStyle_1 = backgroundStyle;
    let _e30 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e30);
    let _e33 = invModelTransform;
    cameraPos = (_e33 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e44 = pos_1;
    let _e46 = D;
    let _e48 = pos_1;
    let _e50 = D;
    dir_4 = normalize(vec3<f32>((_e44.x * _e46), (_e48.y * _e50), -1f));
    let _e57 = invModelTransform;
    let _e67 = dir_4;
    dir_4 = (mat3x3<f32>(_e57[0].xyz, _e57[1].xyz, _e57[2].xyz) * _e67);
    let _e71 = intensity_1;
    eta = (1f - (2f * _e71));
    let _e75 = cameraPos;
    origin_4 = _e75;
    let _e79 = maxIter_1;
    iter_1 = _e79;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            let _e101 = origin_4;
            let _e102 = dir_4;
            let _e103 = radius_9;
            let _e104 = perturbation_7;
            let _e105 = glowColor_3;
            let _e106 = torusRayMarch(_e101, _e102, _e103, _e104, _e105);
            inters = _e106;
            let _e108 = inters;
            k_1 = _e108.x;
            let _e111 = k_1;
            let _e114 = k_1;
            let _e115 = minK;
            if ((_e111 > 0f) && (_e114 < _e115)) {
                {
                    let _e118 = k_1;
                    minK = _e118;
                    minI = 0i;
                    objectIntersected = true;
                }
            } else {
                let _e121 = iter_1;
                let _e122 = maxIter_1;
                if (_e121 == _e122) {
                    {
                        let _e124 = minDist_1;
                        let _e125 = inters;
                        minDist_1 = min(_e124, _e125.z);
                    }
                }
            }
            let _e128 = minI;
            if (_e128 >= 0i) {
                {
                    let _e131 = origin_4;
                    let _e132 = minK;
                    let _e133 = dir_4;
                    intersection = (_e131 + (_e132 * _e133));
                    let _e137 = origin_4;
                    let _e138 = radius_9;
                    let _e139 = perturbation_7;
                    let _e140 = torusImplicitFn(_e137, _e138, _e139);
                    if (_e140 <= 0f) {
                        let _e143 = intersection;
                        let _e144 = radius_9;
                        let _e145 = perturbation_7;
                        let _e146 = torusNormal(_e143, _e144, _e145);
                        local_3 = _e146;
                    } else {
                        let _e147 = intersection;
                        let _e148 = radius_9;
                        let _e149 = perturbation_7;
                        let _e150 = torusNormal(_e147, _e148, _e149);
                        local_3 = -(_e150);
                    }
                    let _e153 = local_3;
                    normal = _e153;
                    let _e155 = iter_1;
                    let _e156 = maxIter_1;
                    if (_e155 == _e156) {
                        {
                            let _e158 = normal;
                            let _e159 = dir_4;
                            incidence = abs(dot(_e158, _e159));
                            let _e162 = dir_4;
                            let _e163 = normal;
                            reflectedDir = reflect(_e162, _e163);
                            _reflBkg = vec4(0f);
                            let _e169 = backgroundStyle_1;
                            if (_e169 == 0i) {
                                {
                                    let _e172 = reflectedDir;
                                    _o_n = normalize(_e172);
                                    let _e175 = _o_n;
                                    let _e177 = _o_n;
                                    _o_alpha = atan2(_e175.z, _e177.x);
                                    let _e181 = _o_n;
                                    _o_beta = asin(_e181.y);
                                    let _e185 = _o_alpha;
                                    let _e192 = _o_beta;
                                    let _e200 = global.U[0];
                                    let _e203 = _o_alpha;
                                    let _e210 = _o_beta;
                                    let _e223 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e185) / 3.1415927f) * 2f), ((2f * _e192) / 3.1415927f)).x / _e200.x), vec2<f32>(((-(_e203) / 3.1415927f) * 2f), ((2f * _e210) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
                                    _reflBkg = _e223;
                                }
                            } else {
                                let _e224 = backgroundStyle_1;
                                if (_e224 == 1i) {
                                    {
                                        let _e227 = reflectedDir;
                                        let _e230 = reflectedDir;
                                        let _e233 = reflectedDir;
                                        let _e236 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e227.x) / _e230.z), (-(_e233.y) / _e236.z));
                                        let _e241 = _o_pos;
                                        let _e244 = _o_pos;
                                        _o_m = max(abs(_e241.x), abs(_e244.y));
                                        let _e251 = _o_m;
                                        _o_darken = (4f / max(4f, _e251));
                                        let _e255 = _o_pos;
                                        let _e259 = global.U[0];
                                        let _e262 = _o_pos;
                                        let _e271 = textureSample(t_source, samp, ((vec2<f32>((_e255.x / _e259.x), _e262.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e272 = _o_darken;
                                        let _e273 = _o_darken;
                                        let _e274 = _o_darken;
                                        _reflBkg = (_e271 * vec4<f32>(_e272, _e273, _e274, 1f));
                                    }
                                } else {
                                    let _e278 = backgroundStyle_1;
                                    if (_e278 == 2i) {
                                        {
                                            let _e281 = sourceDim_1;
                                            let _e283 = sourceDim_1;
                                            _o_ratio = (_e281.y / _e283.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e291 = reflectedDir;
                                            let _e294 = reflectedDir;
                                            let _e297 = _o_ratio;
                                            let _e300 = reflectedDir;
                                            let _e303 = reflectedDir;
                                            let _e306 = _o_ratio;
                                            if ((abs(_e291.y) > (abs(_e294.z) * _e297)) && (abs(_e300.y) > (abs(_e303.x) * _e306))) {
                                                {
                                                    let _e310 = _o_X;
                                                    let _e311 = reflectedDir;
                                                    let _e314 = reflectedDir;
                                                    _o_X = (_e310 + ((-(_e311.x) / _e314.y) * 0.5f));
                                                    let _e320 = _o_Y;
                                                    let _e321 = reflectedDir;
                                                    let _e324 = reflectedDir;
                                                    _o_Y = (_e320 + ((-(_e321.z) / _e324.y) * 0.5f));
                                                }
                                            } else {
                                                let _e330 = reflectedDir;
                                                let _e333 = reflectedDir;
                                                if (abs(_e330.x) < abs(_e333.z)) {
                                                    {
                                                        let _e337 = _o_X;
                                                        let _e338 = reflectedDir;
                                                        let _e340 = reflectedDir;
                                                        let _e344 = _o_ratio;
                                                        let _e348 = reflectedDir;
                                                        _o_X = (_e337 + ((((_e338.x / abs(_e340.z)) * _e344) * 0.5f) * -(sign(_e348.z))));
                                                        let _e354 = _o_Y;
                                                        let _e355 = reflectedDir;
                                                        let _e357 = reflectedDir;
                                                        _o_Y = (_e354 + ((_e355.y / abs(_e357.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e364 = _o_X;
                                                        let _e365 = reflectedDir;
                                                        let _e367 = reflectedDir;
                                                        let _e371 = _o_ratio;
                                                        let _e375 = reflectedDir;
                                                        _o_X = (_e364 + ((((_e365.z / abs(_e367.x)) * _e371) * 0.5f) * -(sign(_e375.x))));
                                                        let _e381 = _o_Y;
                                                        let _e382 = reflectedDir;
                                                        let _e384 = reflectedDir;
                                                        _o_Y = (_e381 + ((_e382.y / abs(_e384.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e391 = _o_X;
                                            let _e392 = _o_Y;
                                            let _e402 = global.U[0];
                                            let _e405 = _o_X;
                                            let _e406 = _o_Y;
                                            let _e421 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e391, _e392) * 2f) - vec2(1f)).x / _e402.x), ((vec2<f32>(_e405, _e406) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                                            _reflBkg = _e421;
                                        }
                                    } else {
                                        {
                                            let _e422 = reflectedDir;
                                            let _e427 = ((_e422 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e427.x, _e427.y, _e427.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e433 = _reflBkg;
                            reflectedColor = _e433;
                        }
                    }
                    let _e434 = dir_4;
                    let _e435 = normal;
                    let _e436 = eta;
                    dir_4 = refract(_e434, _e435, _e436);
                    let _e438 = intersection;
                    let _e439 = dir_4;
                    origin_4 = (_e438 + (_e439 * 0.001f));
                }
            }
            let _e443 = iter_1;
            iter_1 = (_e443 - 1i);
        }
        let _e446 = minI;
        let _e449 = iter_1;
        if !(((_e446 >= 0i) && (_e449 > 0i))) {
            break;
        }
    }
    let _e456 = reflectivity_1;
    balance = (1f - (2f * _e456));
    let _e463 = backgroundStyle_1;
    if (_e463 == 0i) {
        {
            let _e466 = dir_4;
            _o_n_1 = normalize(_e466);
            let _e469 = _o_n_1;
            let _e471 = _o_n_1;
            _o_alpha_1 = atan2(_e469.z, _e471.x);
            let _e475 = _o_n_1;
            _o_beta_1 = asin(_e475.y);
            let _e479 = _o_alpha_1;
            let _e486 = _o_beta_1;
            let _e494 = global.U[0];
            let _e497 = _o_alpha_1;
            let _e504 = _o_beta_1;
            let _e517 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e479) / 3.1415927f) * 2f), ((2f * _e486) / 3.1415927f)).x / _e494.x), vec2<f32>(((-(_e497) / 3.1415927f) * 2f), ((2f * _e504) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
            _bkg = _e517;
        }
    } else {
        let _e518 = backgroundStyle_1;
        if (_e518 == 1i) {
            {
                let _e521 = dir_4;
                let _e524 = dir_4;
                let _e527 = dir_4;
                let _e530 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e521.x) / _e524.z), (-(_e527.y) / _e530.z));
                let _e535 = _o_pos_1;
                let _e538 = _o_pos_1;
                _o_m_1 = max(abs(_e535.x), abs(_e538.y));
                let _e545 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e545));
                let _e549 = _o_pos_1;
                let _e553 = global.U[0];
                let _e556 = _o_pos_1;
                let _e565 = textureSample(t_source, samp, ((vec2<f32>((_e549.x / _e553.x), _e556.y) / vec2(2f)) + vec2(0.5f)));
                let _e566 = _o_darken_1;
                let _e567 = _o_darken_1;
                let _e568 = _o_darken_1;
                _bkg = (_e565 * vec4<f32>(_e566, _e567, _e568, 1f));
            }
        } else {
            let _e572 = backgroundStyle_1;
            if (_e572 == 2i) {
                {
                    let _e575 = sourceDim_1;
                    let _e577 = sourceDim_1;
                    _o_ratio_1 = (_e575.y / _e577.x);
                    let _e585 = dir_4;
                    let _e588 = dir_4;
                    let _e591 = _o_ratio_1;
                    let _e594 = dir_4;
                    let _e597 = dir_4;
                    let _e600 = _o_ratio_1;
                    if ((abs(_e585.y) > (abs(_e588.z) * _e591)) && (abs(_e594.y) > (abs(_e597.x) * _e600))) {
                        {
                            let _e604 = _o_X_1;
                            let _e605 = dir_4;
                            let _e608 = dir_4;
                            _o_X_1 = (_e604 + ((-(_e605.x) / _e608.y) * 0.5f));
                            let _e614 = _o_Y_1;
                            let _e615 = dir_4;
                            let _e618 = dir_4;
                            _o_Y_1 = (_e614 + ((-(_e615.z) / _e618.y) * 0.5f));
                        }
                    } else {
                        let _e624 = dir_4;
                        let _e627 = dir_4;
                        if (abs(_e624.x) < abs(_e627.z)) {
                            {
                                let _e631 = _o_X_1;
                                let _e632 = dir_4;
                                let _e634 = dir_4;
                                let _e638 = _o_ratio_1;
                                let _e642 = dir_4;
                                _o_X_1 = (_e631 + ((((_e632.x / abs(_e634.z)) * _e638) * 0.5f) * -(sign(_e642.z))));
                                let _e648 = _o_Y_1;
                                let _e649 = dir_4;
                                let _e651 = dir_4;
                                _o_Y_1 = (_e648 + ((_e649.y / abs(_e651.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e658 = _o_X_1;
                                let _e659 = dir_4;
                                let _e661 = dir_4;
                                let _e665 = _o_ratio_1;
                                let _e669 = dir_4;
                                _o_X_1 = (_e658 + ((((_e659.z / abs(_e661.x)) * _e665) * 0.5f) * -(sign(_e669.x))));
                                let _e675 = _o_Y_1;
                                let _e676 = dir_4;
                                let _e678 = dir_4;
                                _o_Y_1 = (_e675 + ((_e676.y / abs(_e678.x)) * 0.5f));
                            }
                        }
                    }
                    let _e685 = _o_X_1;
                    let _e686 = _o_Y_1;
                    let _e696 = global.U[0];
                    let _e699 = _o_X_1;
                    let _e700 = _o_Y_1;
                    let _e715 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e685, _e686) * 2f) - vec2(1f)).x / _e696.x), ((vec2<f32>(_e699, _e700) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _bkg = _e715;
                }
            } else {
                {
                    let _e716 = dir_4;
                    let _e721 = ((_e716 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e721.x, _e721.y, _e721.z, 1f);
                }
            }
        }
    }
    let _e727 = reflectedColor;
    let _e728 = _bkg;
    let _e729 = incidence;
    let _e730 = balance;
    mixedCol = mix(_e727, _e728, vec4(clamp((_e729 + _e730), 0f, 1f)));
    let _e738 = objectIntersected;
    if _e738 {
        let _e739 = mixedCol;
        let _e740 = mixedCol;
        let _e742 = objectColor_1;
        let _e744 = (2f * _e742.xyz);
        let _e751 = objectColor_1;
        mixedCol = mix(_e739, (_e740 * vec4<f32>(_e744.x, _e744.y, _e744.z, 1f)), vec4(_e751.w));
    } else {
        let _e755 = mixedCol;
        let _e756 = mixedCol;
        let _e758 = bkgColor_1;
        let _e760 = (2f * _e758.xyz);
        let _e767 = bkgColor_1;
        mixedCol = mix(_e755, (_e756 * vec4<f32>(_e760.x, _e760.y, _e760.z, 1f)), vec4(_e767.w));
    }
    let _e771 = mixedCol;
    let _e772 = glowColor_3;
    let _e776 = minDist_1;
    let _e780 = ((_e772.xyz * 0.1f) / vec3(pow(_e776, 1f)));
    let _e786 = glowColor_3;
    return (_e771 + (vec4<f32>(_e780.x, _e780.y, _e780.z, 0f) * _e786.w));
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
    let _e99 = global.U[4];
    let _e103 = global.U[10];
    let _e107 = global.U[11];
    let _e111 = global.U[12];
    let _e115 = global.U[13];
    let _e119 = global.U[14];
    let _e122 = global.U[15];
    let _e125 = global.U[16];
    let _e128 = global.U[17];
    let _e131 = torusGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111.x, _e115.x, _e119, _e122, _e125, i32(_e128.x));
    fragColor = _e131;
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
