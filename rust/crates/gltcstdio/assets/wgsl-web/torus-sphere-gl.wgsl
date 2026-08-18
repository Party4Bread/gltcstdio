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
@group(0) @binding(2) 
var t_source: texture_2d<f32>;

fn torusSphereSdfSmin(a: f32, b: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k: f32 = 32f;
    var res: f32;

    a_1 = a;
    b_1 = b;
    let _e12 = k;
    let _e14 = a_1;
    let _e17 = k;
    let _e19 = b_1;
    res = (exp((-(_e12) * _e14)) + exp((-(_e17) * _e19)));
    let _e25 = res;
    let _e29 = k;
    return (-(log(max(0.0001f, _e25))) / _e29);
}

fn torusSphereImplicitFn(p: vec3<f32>, radius: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var q1_: vec2<f32>;
    var q2_: vec2<f32>;
    var q3_: vec2<f32>;

    p_1 = p;
    radius_1 = radius;
    let _e12 = R;
    let _e13 = radius_1;
    r = (_e12 * _e13);
    let _e16 = p_1;
    let _e18 = p_1;
    let _e21 = p_1;
    let _e23 = p_1;
    let _e28 = R;
    let _e30 = p_1;
    q1_ = vec2<f32>((sqrt(((_e16.x * _e18.x) + (_e21.y * _e23.y))) - _e28), _e30.z);
    let _e34 = p_1;
    let _e36 = p_1;
    let _e39 = p_1;
    let _e41 = p_1;
    let _e46 = R;
    let _e48 = p_1;
    q2_ = vec2<f32>((sqrt(((_e34.x * _e36.x) + (_e39.z * _e41.z))) - _e46), _e48.y);
    let _e52 = p_1;
    let _e54 = p_1;
    let _e57 = p_1;
    let _e59 = p_1;
    let _e64 = R;
    let _e66 = p_1;
    q3_ = vec2<f32>((sqrt(((_e52.z * _e54.z) + (_e57.y * _e59.y))) - _e64), _e66.x);
    let _e70 = q1_;
    let _e72 = r;
    let _e74 = q2_;
    let _e76 = r;
    let _e78 = q3_;
    let _e80 = r;
    let _e82 = torusSphereSdfSmin((length(_e74) - _e76), (length(_e78) - _e80));
    let _e83 = torusSphereSdfSmin((length(_e70) - _e72), _e82);
    return _e83;
}

fn torusSphereNormal(p_2: vec3<f32>, radius_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var d: f32 = 0.0001f;
    var d2_: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    let _e12 = d;
    d2_ = (_e12 * 2f);
    let _e16 = p_3;
    let _e18 = d;
    let _e20 = p_3;
    let _e22 = p_3;
    let _e25 = radius_3;
    let _e26 = torusSphereImplicitFn(vec3<f32>((_e16.x - _e18), _e20.y, _e22.z), _e25);
    let _e27 = p_3;
    let _e29 = d;
    let _e31 = p_3;
    let _e33 = p_3;
    let _e36 = radius_3;
    let _e37 = torusSphereImplicitFn(vec3<f32>((_e27.x + _e29), _e31.y, _e33.z), _e36);
    let _e39 = d2_;
    let _e41 = p_3;
    let _e43 = p_3;
    let _e45 = d;
    let _e47 = p_3;
    let _e50 = radius_3;
    let _e51 = torusSphereImplicitFn(vec3<f32>(_e41.x, (_e43.y - _e45), _e47.z), _e50);
    let _e52 = p_3;
    let _e54 = p_3;
    let _e56 = d;
    let _e58 = p_3;
    let _e61 = radius_3;
    let _e62 = torusSphereImplicitFn(vec3<f32>(_e52.x, (_e54.y + _e56), _e58.z), _e61);
    let _e64 = d2_;
    let _e66 = p_3;
    let _e68 = p_3;
    let _e70 = p_3;
    let _e72 = d;
    let _e75 = radius_3;
    let _e76 = torusSphereImplicitFn(vec3<f32>(_e66.x, _e68.y, (_e70.z - _e72)), _e75);
    let _e77 = p_3;
    let _e79 = p_3;
    let _e81 = p_3;
    let _e83 = d;
    let _e86 = radius_3;
    let _e87 = torusSphereImplicitFn(vec3<f32>(_e77.x, _e79.y, (_e81.z + _e83)), _e86);
    let _e89 = d2_;
    return normalize(vec3<f32>(((_e26 - _e37) / _e39), ((_e51 - _e62) / _e64), ((_e76 - _e87) / _e89)));
}

fn torusSphereBoundingSphereK(center: vec3<f32>, radius_4: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var center_1: vec3<f32>;
    var radius_5: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a_2: f32;
    var b_2: f32;
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
    a_2 = dot(_e18, _e19);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b_2 = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_5;
    let _e32 = radius_5;
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b_2;
    let _e37 = b_2;
    let _e40 = a_2;
    let _e42 = c;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b_2;
            let _e54 = sqrtDelta;
            let _e57 = a_2;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b_2;
            let _e63 = sqrtDelta;
            let _e66 = a_2;
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

fn torusSphereRayMarch(origin_2: vec3<f32>, dir_2: vec3<f32>, radius_6: f32, glowColor: vec4<f32>) -> vec3<f32> {
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var radius_7: f32;
    var glowColor_1: vec4<f32>;
    var minDist: f32 = 1000000000f;
    var k_1: f32 = 0f;
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
    glowColor_1 = glowColor;
    let _e18 = glowColor_1;
    let _e22 = glowColor_1;
    let _e27 = glowColor_1;
    if (((_e18.x == 0f) && (_e22.y == 0f)) && (_e27.z == 0f)) {
        {
            let _e36 = radius_7;
            let _e39 = origin_3;
            let _e40 = dir_3;
            let _e41 = torusSphereBoundingSphereK(vec3(0f), (0.5f * (2.25f + _e36)), _e39, _e40);
            kBounds = _e41;
            let _e43 = kBounds;
            kk = _e43.x;
            let _e46 = kk;
            if (_e46 < 0f) {
                let _e49 = kk;
                let _e51 = minDist;
                return vec3<f32>(_e49, 0f, _e51);
            }
        }
    }
    let _e59 = origin_3;
    p_4 = _e59;
    let _e61 = p_4;
    let _e62 = radius_7;
    let _e63 = torusSphereImplicitFn(_e61, _e62);
    dist = _e63;
    loop {
        let _e65 = dist;
        let _e67 = de;
        let _e69 = iter;
        let _e70 = maxIter;
        if !(((abs(_e65) > _e67) && (_e69 < _e70))) {
            break;
        }
        {
            let _e74 = k_1;
            let _e75 = dist;
            k_1 = (_e74 + abs(_e75));
            let _e78 = origin_3;
            let _e79 = k_1;
            let _e80 = dir_3;
            p_4 = (_e78 + (_e79 * _e80));
            let _e83 = p_4;
            let _e84 = radius_7;
            let _e85 = torusSphereImplicitFn(_e83, _e84);
            dist = _e85;
            let _e86 = minDist;
            let _e87 = dist;
            minDist = min(_e86, abs(_e87));
            let _e90 = iter;
            iter = (_e90 + 1i);
        }
    }
    let _e93 = dist;
    let _e94 = de;
    if (_e93 < _e94) {
        let _e96 = k_1;
        let _e97 = iter;
        let _e99 = minDist;
        local_2 = vec3<f32>(_e96, f32(_e97), _e99);
    } else {
        let _e103 = iter;
        let _e105 = minDist;
        local_2 = vec3<f32>(-1f, f32(_e103), _e105);
    }
    let _e108 = local_2;
    return _e108;
}

fn torusSphereGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, radius_8: f32, objectColor: vec4<f32>, glowColor_2: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var radius_9: f32;
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
    var k_2: f32;
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
    objectColor_1 = objectColor;
    glowColor_3 = glowColor_2;
    bkgColor_1 = bkgColor;
    backgroundStyle_1 = backgroundStyle;
    let _e28 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e28);
    let _e31 = invModelTransform;
    cameraPos = (_e31 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e42 = pos_1;
    let _e44 = D;
    let _e46 = pos_1;
    let _e48 = D;
    dir_4 = normalize(vec3<f32>((_e42.x * _e44), (_e46.y * _e48), -1f));
    let _e55 = invModelTransform;
    let _e65 = dir_4;
    dir_4 = (mat3x3<f32>(_e55[0].xyz, _e55[1].xyz, _e55[2].xyz) * _e65);
    let _e69 = intensity_1;
    eta = (1f - (2f * _e69));
    let _e73 = cameraPos;
    origin_4 = _e73;
    let _e77 = maxIter_1;
    iter_1 = _e77;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            let _e99 = origin_4;
            let _e100 = dir_4;
            let _e101 = radius_9;
            let _e102 = glowColor_3;
            let _e103 = torusSphereRayMarch(_e99, _e100, _e101, _e102);
            inters = _e103;
            let _e105 = inters;
            k_2 = _e105.x;
            let _e108 = k_2;
            let _e111 = k_2;
            let _e112 = minK;
            if ((_e108 > 0f) && (_e111 < _e112)) {
                {
                    let _e115 = k_2;
                    minK = _e115;
                    minI = 0i;
                    objectIntersected = true;
                }
            } else {
                let _e118 = iter_1;
                let _e119 = maxIter_1;
                if (_e118 == _e119) {
                    {
                        let _e121 = minDist_1;
                        let _e122 = inters;
                        minDist_1 = min(_e121, _e122.z);
                    }
                }
            }
            let _e125 = minI;
            if (_e125 >= 0i) {
                {
                    let _e128 = origin_4;
                    let _e129 = minK;
                    let _e130 = dir_4;
                    intersection = (_e128 + (_e129 * _e130));
                    let _e134 = origin_4;
                    let _e135 = radius_9;
                    let _e136 = torusSphereImplicitFn(_e134, _e135);
                    if (_e136 <= 0f) {
                        let _e139 = intersection;
                        let _e140 = radius_9;
                        let _e141 = torusSphereNormal(_e139, _e140);
                        local_3 = _e141;
                    } else {
                        let _e142 = intersection;
                        let _e143 = radius_9;
                        let _e144 = torusSphereNormal(_e142, _e143);
                        local_3 = -(_e144);
                    }
                    let _e147 = local_3;
                    normal = _e147;
                    let _e149 = iter_1;
                    let _e150 = maxIter_1;
                    if (_e149 == _e150) {
                        {
                            let _e152 = normal;
                            let _e153 = dir_4;
                            incidence = abs(dot(_e152, _e153));
                            let _e156 = dir_4;
                            let _e157 = normal;
                            reflectedDir = reflect(_e156, _e157);
                            _reflBkg = vec4(0f);
                            let _e163 = backgroundStyle_1;
                            if (_e163 == 0i) {
                                {
                                    let _e166 = reflectedDir;
                                    _o_n = normalize(_e166);
                                    let _e169 = _o_n;
                                    let _e171 = _o_n;
                                    _o_alpha = atan2(_e169.z, _e171.x);
                                    let _e175 = _o_n;
                                    _o_beta = asin(_e175.y);
                                    let _e179 = _o_alpha;
                                    let _e186 = _o_beta;
                                    let _e194 = global.U[0];
                                    let _e197 = _o_alpha;
                                    let _e204 = _o_beta;
                                    let _e218 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e179) / 3.1415927f) * 2f), ((2f * _e186) / 3.1415927f)).x / _e194.x), vec2<f32>(((-(_e197) / 3.1415927f) * 2f), ((2f * _e204) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e218;
                                }
                            } else {
                                let _e219 = backgroundStyle_1;
                                if (_e219 == 1i) {
                                    {
                                        let _e222 = reflectedDir;
                                        let _e225 = reflectedDir;
                                        let _e228 = reflectedDir;
                                        let _e231 = reflectedDir;
                                        _o_pos = vec2<f32>((-(_e222.x) / _e225.z), (-(_e228.y) / _e231.z));
                                        let _e236 = _o_pos;
                                        let _e239 = _o_pos;
                                        _o_m = max(abs(_e236.x), abs(_e239.y));
                                        let _e246 = _o_m;
                                        _o_darken = (4f / max(4f, _e246));
                                        let _e250 = _o_pos;
                                        let _e254 = global.U[0];
                                        let _e257 = _o_pos;
                                        let _e267 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e250.x / _e254.x), _e257.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e268 = _o_darken;
                                        let _e269 = _o_darken;
                                        let _e270 = _o_darken;
                                        _reflBkg = (_e267 * vec4<f32>(_e268, _e269, _e270, 1f));
                                    }
                                } else {
                                    let _e274 = backgroundStyle_1;
                                    if (_e274 == 2i) {
                                        {
                                            let _e277 = sourceDim_1;
                                            let _e279 = sourceDim_1;
                                            _o_ratio = (_e277.y / _e279.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e287 = reflectedDir;
                                            let _e290 = reflectedDir;
                                            let _e293 = _o_ratio;
                                            let _e296 = reflectedDir;
                                            let _e299 = reflectedDir;
                                            let _e302 = _o_ratio;
                                            if ((abs(_e287.y) > (abs(_e290.z) * _e293)) && (abs(_e296.y) > (abs(_e299.x) * _e302))) {
                                                {
                                                    let _e306 = _o_X;
                                                    let _e307 = reflectedDir;
                                                    let _e310 = reflectedDir;
                                                    _o_X = (_e306 + ((-(_e307.x) / _e310.y) * 0.5f));
                                                    let _e316 = _o_Y;
                                                    let _e317 = reflectedDir;
                                                    let _e320 = reflectedDir;
                                                    _o_Y = (_e316 + ((-(_e317.z) / _e320.y) * 0.5f));
                                                }
                                            } else {
                                                let _e326 = reflectedDir;
                                                let _e329 = reflectedDir;
                                                if (abs(_e326.x) < abs(_e329.z)) {
                                                    {
                                                        let _e333 = _o_X;
                                                        let _e334 = reflectedDir;
                                                        let _e336 = reflectedDir;
                                                        let _e340 = _o_ratio;
                                                        let _e344 = reflectedDir;
                                                        _o_X = (_e333 + ((((_e334.x / abs(_e336.z)) * _e340) * 0.5f) * -(sign(_e344.z))));
                                                        let _e350 = _o_Y;
                                                        let _e351 = reflectedDir;
                                                        let _e353 = reflectedDir;
                                                        _o_Y = (_e350 + ((_e351.y / abs(_e353.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e360 = _o_X;
                                                        let _e361 = reflectedDir;
                                                        let _e363 = reflectedDir;
                                                        let _e367 = _o_ratio;
                                                        let _e371 = reflectedDir;
                                                        _o_X = (_e360 + ((((_e361.z / abs(_e363.x)) * _e367) * 0.5f) * -(sign(_e371.x))));
                                                        let _e377 = _o_Y;
                                                        let _e378 = reflectedDir;
                                                        let _e380 = reflectedDir;
                                                        _o_Y = (_e377 + ((_e378.y / abs(_e380.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e387 = _o_X;
                                            let _e388 = _o_Y;
                                            let _e398 = global.U[0];
                                            let _e401 = _o_X;
                                            let _e402 = _o_Y;
                                            let _e418 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e387, _e388) * 2f) - vec2(1f)).x / _e398.x), ((vec2<f32>(_e401, _e402) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e418;
                                        }
                                    } else {
                                        {
                                            let _e419 = reflectedDir;
                                            let _e424 = ((_e419 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e424.x, _e424.y, _e424.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e430 = _reflBkg;
                            reflectedColor = _e430;
                        }
                    }
                    let _e431 = dir_4;
                    let _e432 = normal;
                    let _e433 = eta;
                    dir_4 = refract(_e431, _e432, _e433);
                    let _e435 = intersection;
                    let _e436 = dir_4;
                    origin_4 = (_e435 + (_e436 * 0.001f));
                }
            }
            let _e440 = iter_1;
            iter_1 = (_e440 - 1i);
        }
        let _e443 = minI;
        let _e446 = iter_1;
        if !(((_e443 >= 0i) && (_e446 > 0i))) {
            break;
        }
    }
    let _e453 = reflectivity_1;
    balance = (1f - (2f * _e453));
    let _e460 = backgroundStyle_1;
    if (_e460 == 0i) {
        {
            let _e463 = dir_4;
            _o_n_1 = normalize(_e463);
            let _e466 = _o_n_1;
            let _e468 = _o_n_1;
            _o_alpha_1 = atan2(_e466.z, _e468.x);
            let _e472 = _o_n_1;
            _o_beta_1 = asin(_e472.y);
            let _e476 = _o_alpha_1;
            let _e483 = _o_beta_1;
            let _e491 = global.U[0];
            let _e494 = _o_alpha_1;
            let _e501 = _o_beta_1;
            let _e515 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e476) / 3.1415927f) * 2f), ((2f * _e483) / 3.1415927f)).x / _e491.x), vec2<f32>(((-(_e494) / 3.1415927f) * 2f), ((2f * _e501) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e515;
        }
    } else {
        let _e516 = backgroundStyle_1;
        if (_e516 == 1i) {
            {
                let _e519 = dir_4;
                let _e522 = dir_4;
                let _e525 = dir_4;
                let _e528 = dir_4;
                _o_pos_1 = vec2<f32>((-(_e519.x) / _e522.z), (-(_e525.y) / _e528.z));
                let _e533 = _o_pos_1;
                let _e536 = _o_pos_1;
                _o_m_1 = max(abs(_e533.x), abs(_e536.y));
                let _e543 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e543));
                let _e547 = _o_pos_1;
                let _e551 = global.U[0];
                let _e554 = _o_pos_1;
                let _e564 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e547.x / _e551.x), _e554.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e565 = _o_darken_1;
                let _e566 = _o_darken_1;
                let _e567 = _o_darken_1;
                _bkg = (_e564 * vec4<f32>(_e565, _e566, _e567, 1f));
            }
        } else {
            let _e571 = backgroundStyle_1;
            if (_e571 == 2i) {
                {
                    let _e574 = sourceDim_1;
                    let _e576 = sourceDim_1;
                    _o_ratio_1 = (_e574.y / _e576.x);
                    let _e584 = dir_4;
                    let _e587 = dir_4;
                    let _e590 = _o_ratio_1;
                    let _e593 = dir_4;
                    let _e596 = dir_4;
                    let _e599 = _o_ratio_1;
                    if ((abs(_e584.y) > (abs(_e587.z) * _e590)) && (abs(_e593.y) > (abs(_e596.x) * _e599))) {
                        {
                            let _e603 = _o_X_1;
                            let _e604 = dir_4;
                            let _e607 = dir_4;
                            _o_X_1 = (_e603 + ((-(_e604.x) / _e607.y) * 0.5f));
                            let _e613 = _o_Y_1;
                            let _e614 = dir_4;
                            let _e617 = dir_4;
                            _o_Y_1 = (_e613 + ((-(_e614.z) / _e617.y) * 0.5f));
                        }
                    } else {
                        let _e623 = dir_4;
                        let _e626 = dir_4;
                        if (abs(_e623.x) < abs(_e626.z)) {
                            {
                                let _e630 = _o_X_1;
                                let _e631 = dir_4;
                                let _e633 = dir_4;
                                let _e637 = _o_ratio_1;
                                let _e641 = dir_4;
                                _o_X_1 = (_e630 + ((((_e631.x / abs(_e633.z)) * _e637) * 0.5f) * -(sign(_e641.z))));
                                let _e647 = _o_Y_1;
                                let _e648 = dir_4;
                                let _e650 = dir_4;
                                _o_Y_1 = (_e647 + ((_e648.y / abs(_e650.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e657 = _o_X_1;
                                let _e658 = dir_4;
                                let _e660 = dir_4;
                                let _e664 = _o_ratio_1;
                                let _e668 = dir_4;
                                _o_X_1 = (_e657 + ((((_e658.z / abs(_e660.x)) * _e664) * 0.5f) * -(sign(_e668.x))));
                                let _e674 = _o_Y_1;
                                let _e675 = dir_4;
                                let _e677 = dir_4;
                                _o_Y_1 = (_e674 + ((_e675.y / abs(_e677.x)) * 0.5f));
                            }
                        }
                    }
                    let _e684 = _o_X_1;
                    let _e685 = _o_Y_1;
                    let _e695 = global.U[0];
                    let _e698 = _o_X_1;
                    let _e699 = _o_Y_1;
                    let _e715 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e684, _e685) * 2f) - vec2(1f)).x / _e695.x), ((vec2<f32>(_e698, _e699) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
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
    let _e118 = global.U[14];
    let _e121 = global.U[15];
    let _e124 = global.U[16];
    let _e127 = torusSphereGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111.x, _e115, _e118, _e121, i32(_e124.x));
    fragColor = _e127;
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
