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
                                    let _e224 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e185) / 3.1415927f) * 2f), ((2f * _e192) / 3.1415927f)).x / _e200.x), vec2<f32>(((-(_e203) / 3.1415927f) * 2f), ((2f * _e210) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e224;
                                }
                            } else {
                                let _e225 = backgroundStyle_1;
                                if (_e225 == 1i) {
                                    {
                                        let _e228 = reflectedDir;
                                        let _e231 = reflectedDir;
                                        let _e234 = reflectedDir;
                                        let _e237 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e228.x) / _e231.z), (-(_e234.y) / _e237.z));
                                        let _e242 = _o_pos;
                                        let _e245 = _o_pos;
                                        _o_m = max(abs(_e242.x), abs(_e245.y));
                                        let _e252 = _o_m;
                                        _o_darken = (4f / max(4f, _e252));
                                        let _e256 = _o_pos;
                                        let _e260 = global.U[0];
                                        let _e263 = _o_pos;
                                        let _e273 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e256.x / _e260.x), _e263.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e274 = _o_darken;
                                        let _e275 = _o_darken;
                                        let _e276 = _o_darken;
                                        _reflBkg = (_e273 * vec4<f32>(_e274, _e275, _e276, 1f));
                                    }
                                } else {
                                    let _e280 = backgroundStyle_1;
                                    if (_e280 == 2i) {
                                        {
                                            let _e283 = sourceDim_1;
                                            let _e285 = sourceDim_1;
                                            _o_ratio = (_e283.y / _e285.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e293 = reflectedDir;
                                            let _e296 = reflectedDir;
                                            let _e299 = _o_ratio;
                                            let _e302 = reflectedDir;
                                            let _e305 = reflectedDir;
                                            let _e308 = _o_ratio;
                                            if ((abs(_e293.y) > (abs(_e296.z) * _e299)) && (abs(_e302.y) > (abs(_e305.x) * _e308))) {
                                                {
                                                    let _e312 = _o_X;
                                                    let _e313 = reflectedDir;
                                                    let _e316 = reflectedDir;
                                                    _o_X = (_e312 + ((-(_e313.x) / _e316.y) * 0.5f));
                                                    let _e322 = _o_Y;
                                                    let _e323 = reflectedDir;
                                                    let _e326 = reflectedDir;
                                                    _o_Y = (_e322 + ((-(_e323.z) / _e326.y) * 0.5f));
                                                }
                                            } else {
                                                let _e332 = reflectedDir;
                                                let _e335 = reflectedDir;
                                                if (abs(_e332.x) < abs(_e335.z)) {
                                                    {
                                                        let _e339 = _o_X;
                                                        let _e340 = reflectedDir;
                                                        let _e342 = reflectedDir;
                                                        let _e346 = _o_ratio;
                                                        let _e350 = reflectedDir;
                                                        _o_X = (_e339 + ((((_e340.x / abs(_e342.z)) * _e346) * 0.5f) * -(sign(_e350.z))));
                                                        let _e356 = _o_Y;
                                                        let _e357 = reflectedDir;
                                                        let _e359 = reflectedDir;
                                                        _o_Y = (_e356 + ((_e357.y / abs(_e359.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e366 = _o_X;
                                                        let _e367 = reflectedDir;
                                                        let _e369 = reflectedDir;
                                                        let _e373 = _o_ratio;
                                                        let _e377 = reflectedDir;
                                                        _o_X = (_e366 + ((((_e367.z / abs(_e369.x)) * _e373) * 0.5f) * -(sign(_e377.x))));
                                                        let _e383 = _o_Y;
                                                        let _e384 = reflectedDir;
                                                        let _e386 = reflectedDir;
                                                        _o_Y = (_e383 + ((_e384.y / abs(_e386.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e393 = _o_X;
                                            let _e394 = _o_Y;
                                            let _e404 = global.U[0];
                                            let _e407 = _o_X;
                                            let _e408 = _o_Y;
                                            let _e424 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e393, _e394) * 2f) - vec2(1f)).x / _e404.x), ((vec2<f32>(_e407, _e408) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e424;
                                        }
                                    } else {
                                        {
                                            let _e425 = reflectedDir;
                                            let _e430 = ((_e425 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e430.x, _e430.y, _e430.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e436 = _reflBkg;
                            reflectedColor = _e436;
                        }
                    }
                    let _e437 = dir_4;
                    let _e438 = normal;
                    let _e439 = eta;
                    dir_4 = refract(_e437, _e438, _e439);
                    let _e441 = intersection;
                    let _e442 = dir_4;
                    origin_4 = (_e441 + (_e442 * 0.001f));
                }
            }
            let _e446 = iter_1;
            iter_1 = (_e446 - 1i);
        }
        let _e449 = minI;
        let _e452 = iter_1;
        if !(((_e449 >= 0i) && (_e452 > 0i))) {
            break;
        }
    }
    let _e459 = reflectivity_1;
    balance = (1f - (2f * _e459));
    let _e466 = backgroundStyle_1;
    if (_e466 == 0i) {
        {
            let _e469 = dir_4;
            _o_n_1 = normalize(_e469);
            let _e472 = _o_n_1;
            let _e474 = _o_n_1;
            _o_alpha_1 = atan2(_e472.z, _e474.x);
            let _e478 = _o_n_1;
            _o_beta_1 = asin(_e478.y);
            let _e482 = _o_alpha_1;
            let _e489 = _o_beta_1;
            let _e497 = global.U[0];
            let _e500 = _o_alpha_1;
            let _e507 = _o_beta_1;
            let _e521 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e482) / 3.1415927f) * 2f), ((2f * _e489) / 3.1415927f)).x / _e497.x), vec2<f32>(((-(_e500) / 3.1415927f) * 2f), ((2f * _e507) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e521;
        }
    } else {
        let _e522 = backgroundStyle_1;
        if (_e522 == 1i) {
            {
                let _e525 = dir_4;
                let _e528 = dir_4;
                let _e531 = dir_4;
                let _e534 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e525.x) / _e528.z), (-(_e531.y) / _e534.z));
                let _e539 = _o_pos_1;
                let _e542 = _o_pos_1;
                _o_m_1 = max(abs(_e539.x), abs(_e542.y));
                let _e549 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e549));
                let _e553 = _o_pos_1;
                let _e557 = global.U[0];
                let _e560 = _o_pos_1;
                let _e570 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e553.x / _e557.x), _e560.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e571 = _o_darken_1;
                let _e572 = _o_darken_1;
                let _e573 = _o_darken_1;
                _bkg = (_e570 * vec4<f32>(_e571, _e572, _e573, 1f));
            }
        } else {
            let _e577 = backgroundStyle_1;
            if (_e577 == 2i) {
                {
                    let _e580 = sourceDim_1;
                    let _e582 = sourceDim_1;
                    _o_ratio_1 = (_e580.y / _e582.x);
                    let _e590 = dir_4;
                    let _e593 = dir_4;
                    let _e596 = _o_ratio_1;
                    let _e599 = dir_4;
                    let _e602 = dir_4;
                    let _e605 = _o_ratio_1;
                    if ((abs(_e590.y) > (abs(_e593.z) * _e596)) && (abs(_e599.y) > (abs(_e602.x) * _e605))) {
                        {
                            let _e609 = _o_X_1;
                            let _e610 = dir_4;
                            let _e613 = dir_4;
                            _o_X_1 = (_e609 + ((-(_e610.x) / _e613.y) * 0.5f));
                            let _e619 = _o_Y_1;
                            let _e620 = dir_4;
                            let _e623 = dir_4;
                            _o_Y_1 = (_e619 + ((-(_e620.z) / _e623.y) * 0.5f));
                        }
                    } else {
                        let _e629 = dir_4;
                        let _e632 = dir_4;
                        if (abs(_e629.x) < abs(_e632.z)) {
                            {
                                let _e636 = _o_X_1;
                                let _e637 = dir_4;
                                let _e639 = dir_4;
                                let _e643 = _o_ratio_1;
                                let _e647 = dir_4;
                                _o_X_1 = (_e636 + ((((_e637.x / abs(_e639.z)) * _e643) * 0.5f) * -(sign(_e647.z))));
                                let _e653 = _o_Y_1;
                                let _e654 = dir_4;
                                let _e656 = dir_4;
                                _o_Y_1 = (_e653 + ((_e654.y / abs(_e656.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e663 = _o_X_1;
                                let _e664 = dir_4;
                                let _e666 = dir_4;
                                let _e670 = _o_ratio_1;
                                let _e674 = dir_4;
                                _o_X_1 = (_e663 + ((((_e664.z / abs(_e666.x)) * _e670) * 0.5f) * -(sign(_e674.x))));
                                let _e680 = _o_Y_1;
                                let _e681 = dir_4;
                                let _e683 = dir_4;
                                _o_Y_1 = (_e680 + ((_e681.y / abs(_e683.x)) * 0.5f));
                            }
                        }
                    }
                    let _e690 = _o_X_1;
                    let _e691 = _o_Y_1;
                    let _e701 = global.U[0];
                    let _e704 = _o_X_1;
                    let _e705 = _o_Y_1;
                    let _e721 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e690, _e691) * 2f) - vec2(1f)).x / _e701.x), ((vec2<f32>(_e704, _e705) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e721;
                }
            } else {
                {
                    let _e722 = dir_4;
                    let _e727 = ((_e722 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e727.x, _e727.y, _e727.z, 1f);
                }
            }
        }
    }
    let _e733 = reflectedColor;
    let _e734 = _bkg;
    let _e735 = incidence;
    let _e736 = balance;
    mixedCol = mix(_e733, _e734, vec4(clamp((_e735 + _e736), 0f, 1f)));
    let _e744 = objectIntersected;
    if _e744 {
        let _e745 = mixedCol;
        let _e746 = mixedCol;
        let _e748 = objectColor_1;
        let _e750 = (2f * _e748.xyz);
        let _e757 = objectColor_1;
        mixedCol = mix(_e745, (_e746 * vec4<f32>(_e750.x, _e750.y, _e750.z, 1f)), vec4(_e757.w));
    } else {
        let _e761 = mixedCol;
        let _e762 = mixedCol;
        let _e764 = bkgColor_1;
        let _e766 = (2f * _e764.xyz);
        let _e773 = bkgColor_1;
        mixedCol = mix(_e761, (_e762 * vec4<f32>(_e766.x, _e766.y, _e766.z, 1f)), vec4(_e773.w));
    }
    let _e777 = mixedCol;
    let _e778 = glowColor_3;
    let _e782 = minDist_1;
    let _e786 = ((_e778.xyz * 0.1f) / vec3(pow(_e782, 1f)));
    let _e792 = glowColor_3;
    return (_e777 + (vec4<f32>(_e786.x, _e786.y, _e786.z, 0f) * _e792.w));
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
