struct Params {
    U: array<vec4<f32>, 16>,
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

fn cubeFaceNormal(center: vec3<f32>, intersection: vec3<f32>) -> vec3<f32> {
    var center_1: vec3<f32>;
    var intersection_1: vec3<f32>;
    var delta: vec3<f32>;
    var a: vec3<f32>;

    center_1 = center;
    intersection_1 = intersection;
    let _e10 = intersection_1;
    let _e11 = center_1;
    delta = (_e10 - _e11);
    let _e14 = delta;
    a = abs(_e14);
    let _e17 = a;
    let _e19 = a;
    let _e22 = a;
    let _e24 = a;
    if ((_e17.x > _e19.y) && (_e22.x > _e24.z)) {
        let _e28 = delta;
        return vec3<f32>(sign(_e28.x), 0f, 0f);
    } else {
        let _e34 = a;
        let _e36 = a;
        if (_e34.y > _e36.z) {
            let _e40 = delta;
            return vec3<f32>(0f, sign(_e40.y), 0f);
        } else {
            let _e47 = delta;
            return vec3<f32>(0f, 0f, sign(_e47.z));
        }
    }
}

fn cubeIntersection(center_2: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var center_3: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var kOut: f32 = 100000000000000000000f;
    var kIn: f32 = 0f;
    var k1_: f32;
    var k2_: f32;
    var k1_1: f32;
    var k2_1: f32;
    var k1_2: f32;
    var k2_2: f32;
    var local: f32;
    var k: f32;
    var inters: vec3<f32>;

    center_3 = center_2;
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e14 = origin_1;
    let _e15 = center_3;
    relOrigin = (_e14 - _e15);
    let _e22 = dir_1;
    if (_e22.x != 0f) {
        {
            let _e26 = relOrigin;
            let _e28 = radius_1;
            let _e31 = dir_1;
            k1_ = (-((_e26.x - _e28)) / _e31.x);
            let _e35 = relOrigin;
            let _e37 = radius_1;
            let _e40 = dir_1;
            k2_ = (-((_e35.x + _e37)) / _e40.x);
            let _e44 = kIn;
            let _e45 = k1_;
            let _e46 = k2_;
            kIn = max(_e44, min(_e45, _e46));
            let _e49 = kOut;
            let _e50 = k1_;
            let _e51 = k2_;
            kOut = min(_e49, max(_e50, _e51));
        }
    } else {
        let _e54 = relOrigin;
        let _e57 = radius_1;
        if (abs(_e54.x) > _e57) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e63 = dir_1;
    if (_e63.y != 0f) {
        {
            let _e67 = relOrigin;
            let _e69 = radius_1;
            let _e72 = dir_1;
            k1_1 = (-((_e67.y - _e69)) / _e72.y);
            let _e76 = relOrigin;
            let _e78 = radius_1;
            let _e81 = dir_1;
            k2_1 = (-((_e76.y + _e78)) / _e81.y);
            let _e85 = kIn;
            let _e86 = k1_1;
            let _e87 = k2_1;
            kIn = max(_e85, min(_e86, _e87));
            let _e90 = kOut;
            let _e91 = k1_1;
            let _e92 = k2_1;
            kOut = min(_e90, max(_e91, _e92));
        }
    } else {
        let _e95 = relOrigin;
        let _e98 = radius_1;
        if (abs(_e95.y) > _e98) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e104 = dir_1;
    if (_e104.z != 0f) {
        {
            let _e108 = relOrigin;
            let _e110 = radius_1;
            let _e113 = dir_1;
            k1_2 = (-((_e108.z - _e110)) / _e113.z);
            let _e117 = relOrigin;
            let _e119 = radius_1;
            let _e122 = dir_1;
            k2_2 = (-((_e117.z + _e119)) / _e122.z);
            let _e126 = kIn;
            let _e127 = k1_2;
            let _e128 = k2_2;
            kIn = max(_e126, min(_e127, _e128));
            let _e131 = kOut;
            let _e132 = k1_2;
            let _e133 = k2_2;
            kOut = min(_e131, max(_e132, _e133));
        }
    } else {
        let _e136 = relOrigin;
        let _e139 = radius_1;
        if (abs(_e136.z) > _e139) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e145 = kIn;
    if (_e145 > 0f) {
        let _e148 = kIn;
        local = _e148;
    } else {
        let _e149 = kOut;
        local = _e149;
    }
    let _e151 = local;
    k = _e151;
    let _e153 = k;
    let _e156 = kOut;
    let _e157 = kIn;
    if ((_e153 <= 0f) || (_e156 < _e157)) {
        return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
    }
    let _e164 = origin_1;
    let _e165 = k;
    let _e166 = dir_1;
    inters = (_e164 + (_e165 * _e166));
    let _e170 = inters;
    return _e170;
}

fn cubeGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var reflectivity_1: f32;
    var objectColor_1: vec4<f32>;
    var glowColor_1: vec4<f32>;
    var bkgColor_1: vec4<f32>;
    var backgroundStyle_1: i32;
    var invModelTransform: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_2: vec3<f32>;
    var radius_2: f32 = 0.25f;
    var intersection_2: vec3<f32>;
    var normal: vec3<f32>;
    var eta: f32;
    var incidence: f32;
    var refractedDir: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var reflectedColor: vec4<f32> = vec4(0f);
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_nX: f32 = 2f;
    var _o_nY: f32 = 1f;
    var _o_pos: vec2<f32>;
    var _o_pos_1: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio: f32;
    var _o_X: f32 = 0.5f;
    var _o_Y: f32 = 0.5f;
    var intersection2_: vec3<f32>;
    var refractedColor: vec4<f32> = vec4(0f);
    var _o_n_1: vec3<f32>;
    var _o_alpha_1: f32;
    var _o_beta_1: f32;
    var _o_nX_1: f32 = 2f;
    var _o_nY_1: f32 = 1f;
    var _o_pos_2: vec2<f32>;
    var _o_pos_3: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var balance: f32;
    var mixedCol: vec4<f32>;
    var minDist: f32;
    var bkg: vec4<f32> = vec4(0f);
    var _o_n_2: vec3<f32>;
    var _o_alpha_2: f32;
    var _o_beta_2: f32;
    var _o_nX_2: f32 = 2f;
    var _o_nY_2: f32 = 1f;
    var _o_pos_4: vec2<f32>;
    var _o_pos_5: vec2<f32>;
    var _o_m_2: f32;
    var _o_darken_2: f32;
    var _o_ratio_2: f32;
    var _o_X_2: f32 = 0.5f;
    var _o_Y_2: f32 = 0.5f;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    reflectivity_1 = reflectivity;
    objectColor_1 = objectColor;
    glowColor_1 = glowColor;
    bkgColor_1 = bkgColor;
    backgroundStyle_1 = backgroundStyle;
    let _e26 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e26);
    let _e29 = invModelTransform;
    cameraPos = (_e29 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e40 = pos_1;
    let _e42 = D;
    let _e44 = pos_1;
    let _e46 = D;
    dir_2 = normalize(vec3<f32>((_e40.x * _e42), (_e44.y * _e46), -1f));
    let _e53 = invModelTransform;
    let _e63 = dir_2;
    dir_2 = (mat3x3<f32>(_e53[0].xyz, _e53[1].xyz, _e53[2].xyz) * _e63);
    let _e69 = radius_2;
    let _e70 = cameraPos;
    let _e71 = dir_2;
    let _e72 = cubeIntersection(vec3(0f), _e69, _e70, _e71);
    intersection_2 = _e72;
    let _e74 = intersection_2;
    if (_e74.x < 100000000f) {
        {
            let _e80 = intersection_2;
            let _e81 = cubeFaceNormal(vec3(0f), _e80);
            normal = _e81;
            let _e85 = intensity_1;
            eta = (1f - (2f * _e85));
            let _e89 = normal;
            let _e90 = dir_2;
            incidence = abs(dot(_e89, _e90));
            let _e94 = dir_2;
            let _e95 = normal;
            let _e96 = eta;
            refractedDir = refract(_e94, _e95, _e96);
            let _e99 = dir_2;
            let _e100 = normal;
            reflectedDir = reflect(_e99, _e100);
            let _e106 = backgroundStyle_1;
            if (_e106 == 0i) {
                {
                    let _e109 = reflectedDir;
                    _o_n = normalize(_e109);
                    let _e112 = _o_n;
                    let _e114 = _o_n;
                    _o_alpha = atan2(_e112.z, _e114.x);
                    let _e118 = _o_n;
                    _o_beta = asin(_e118.y);
                    let _e126 = _o_alpha;
                    let _e132 = _o_nX;
                    let _e135 = _o_nY;
                    let _e136 = _o_beta;
                    _o_pos = ((vec2<f32>((((-(_e126) / 3.1415927f) * 0.5f) * _e132), (0.5f + ((_e135 * _e136) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e148 = _o_pos;
                    let _e152 = global.U[0];
                    let _e155 = _o_pos;
                    let _e164 = textureSample(t_source, samp, ((vec2<f32>((_e148.x / _e152.x), _e155.y) / vec2(2f)) + vec2(0.5f)));
                    reflectedColor = _e164;
                }
            } else {
                let _e165 = backgroundStyle_1;
                if (_e165 == 1i) {
                    {
                        let _e168 = reflectedDir;
                        let _e171 = reflectedDir;
                        let _e174 = reflectedDir;
                        let _e177 = reflectedDir;
                        _o_pos_1 = vec2<f32>((-(_e168.x) / _e171.z), (-(_e174.y) / _e177.z));
                        let _e182 = _o_pos_1;
                        let _e185 = _o_pos_1;
                        _o_m = max(abs(_e182.x), abs(_e185.y));
                        let _e192 = _o_m;
                        _o_darken = (4f / max(4f, _e192));
                        let _e196 = _o_pos_1;
                        let _e200 = global.U[0];
                        let _e203 = _o_pos_1;
                        let _e212 = textureSample(t_source, samp, ((vec2<f32>((_e196.x / _e200.x), _e203.y) / vec2(2f)) + vec2(0.5f)));
                        let _e213 = _o_darken;
                        let _e214 = _o_darken;
                        let _e215 = _o_darken;
                        reflectedColor = (_e212 * vec4<f32>(_e213, _e214, _e215, 1f));
                    }
                } else {
                    let _e219 = backgroundStyle_1;
                    if (_e219 == 2i) {
                        {
                            let _e222 = sourceDim_1;
                            let _e224 = sourceDim_1;
                            _o_ratio = (_e222.y / _e224.x);
                            let _e232 = reflectedDir;
                            let _e235 = reflectedDir;
                            let _e238 = _o_ratio;
                            let _e241 = reflectedDir;
                            let _e244 = reflectedDir;
                            let _e247 = _o_ratio;
                            if ((abs(_e232.y) > (abs(_e235.z) * _e238)) && (abs(_e241.y) > (abs(_e244.x) * _e247))) {
                                {
                                    let _e251 = _o_X;
                                    let _e252 = reflectedDir;
                                    let _e255 = reflectedDir;
                                    _o_X = (_e251 + ((-(_e252.x) / _e255.y) * 0.5f));
                                    let _e261 = _o_Y;
                                    let _e262 = reflectedDir;
                                    let _e265 = reflectedDir;
                                    _o_Y = (_e261 + ((-(_e262.z) / _e265.y) * 0.5f));
                                }
                            } else {
                                let _e271 = reflectedDir;
                                let _e274 = reflectedDir;
                                if (abs(_e271.x) < abs(_e274.z)) {
                                    {
                                        let _e278 = _o_X;
                                        let _e279 = reflectedDir;
                                        let _e281 = reflectedDir;
                                        let _e285 = _o_ratio;
                                        let _e289 = reflectedDir;
                                        _o_X = (_e278 + ((((_e279.x / abs(_e281.z)) * _e285) * 0.5f) * -(sign(_e289.z))));
                                        let _e295 = _o_Y;
                                        let _e296 = reflectedDir;
                                        let _e298 = reflectedDir;
                                        _o_Y = (_e295 + ((_e296.y / abs(_e298.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e305 = _o_X;
                                        let _e306 = reflectedDir;
                                        let _e308 = reflectedDir;
                                        let _e312 = _o_ratio;
                                        let _e316 = reflectedDir;
                                        _o_X = (_e305 + ((((_e306.z / abs(_e308.x)) * _e312) * 0.5f) * -(sign(_e316.x))));
                                        let _e322 = _o_Y;
                                        let _e323 = reflectedDir;
                                        let _e325 = reflectedDir;
                                        _o_Y = (_e322 + ((_e323.y / abs(_e325.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e332 = _o_X;
                            let _e333 = _o_Y;
                            let _e343 = global.U[0];
                            let _e346 = _o_X;
                            let _e347 = _o_Y;
                            let _e362 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e332, _e333) * 2f) - vec2(1f)).x / _e343.x), ((vec2<f32>(_e346, _e347) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            reflectedColor = _e362;
                        }
                    } else {
                        {
                            let _e363 = reflectedDir;
                            let _e368 = ((_e363 * 0.5f) + vec3(0.5f));
                            reflectedColor = vec4<f32>(_e368.x, _e368.y, _e368.z, 1f);
                        }
                    }
                }
            }
            let _e376 = radius_2;
            let _e377 = intersection_2;
            let _e378 = refractedDir;
            let _e382 = refractedDir;
            let _e383 = cubeIntersection(vec3(0f), _e376, (_e377 + (_e378 * 0.00001f)), _e382);
            intersection2_ = _e383;
            let _e385 = intersection2_;
            if (_e385.x < 100000000f) {
                {
                    let _e391 = intersection2_;
                    let _e392 = cubeFaceNormal(vec3(0f), _e391);
                    normal = -(_e392);
                    let _e394 = refractedDir;
                    let _e395 = normal;
                    let _e396 = eta;
                    refractedDir = refract(_e394, _e395, _e396);
                }
            }
            let _e401 = backgroundStyle_1;
            if (_e401 == 0i) {
                {
                    let _e404 = refractedDir;
                    _o_n_1 = normalize(_e404);
                    let _e407 = _o_n_1;
                    let _e409 = _o_n_1;
                    _o_alpha_1 = atan2(_e407.z, _e409.x);
                    let _e413 = _o_n_1;
                    _o_beta_1 = asin(_e413.y);
                    let _e421 = _o_alpha_1;
                    let _e427 = _o_nX_1;
                    let _e430 = _o_nY_1;
                    let _e431 = _o_beta_1;
                    _o_pos_2 = ((vec2<f32>((((-(_e421) / 3.1415927f) * 0.5f) * _e427), (0.5f + ((_e430 * _e431) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e443 = _o_pos_2;
                    let _e447 = global.U[0];
                    let _e450 = _o_pos_2;
                    let _e459 = textureSample(t_source, samp, ((vec2<f32>((_e443.x / _e447.x), _e450.y) / vec2(2f)) + vec2(0.5f)));
                    refractedColor = _e459;
                }
            } else {
                let _e460 = backgroundStyle_1;
                if (_e460 == 1i) {
                    {
                        let _e463 = refractedDir;
                        let _e466 = refractedDir;
                        let _e469 = refractedDir;
                        let _e472 = refractedDir;
                        _o_pos_3 = vec2<f32>((-(_e463.x) / _e466.z), (-(_e469.y) / _e472.z));
                        let _e477 = _o_pos_3;
                        let _e480 = _o_pos_3;
                        _o_m_1 = max(abs(_e477.x), abs(_e480.y));
                        let _e487 = _o_m_1;
                        _o_darken_1 = (4f / max(4f, _e487));
                        let _e491 = _o_pos_3;
                        let _e495 = global.U[0];
                        let _e498 = _o_pos_3;
                        let _e507 = textureSample(t_source, samp, ((vec2<f32>((_e491.x / _e495.x), _e498.y) / vec2(2f)) + vec2(0.5f)));
                        let _e508 = _o_darken_1;
                        let _e509 = _o_darken_1;
                        let _e510 = _o_darken_1;
                        refractedColor = (_e507 * vec4<f32>(_e508, _e509, _e510, 1f));
                    }
                } else {
                    let _e514 = backgroundStyle_1;
                    if (_e514 == 2i) {
                        {
                            let _e517 = sourceDim_1;
                            let _e519 = sourceDim_1;
                            _o_ratio_1 = (_e517.y / _e519.x);
                            let _e527 = refractedDir;
                            let _e530 = refractedDir;
                            let _e533 = _o_ratio_1;
                            let _e536 = refractedDir;
                            let _e539 = refractedDir;
                            let _e542 = _o_ratio_1;
                            if ((abs(_e527.y) > (abs(_e530.z) * _e533)) && (abs(_e536.y) > (abs(_e539.x) * _e542))) {
                                {
                                    let _e546 = _o_X_1;
                                    let _e547 = refractedDir;
                                    let _e550 = refractedDir;
                                    _o_X_1 = (_e546 + ((-(_e547.x) / _e550.y) * 0.5f));
                                    let _e556 = _o_Y_1;
                                    let _e557 = refractedDir;
                                    let _e560 = refractedDir;
                                    _o_Y_1 = (_e556 + ((-(_e557.z) / _e560.y) * 0.5f));
                                }
                            } else {
                                let _e566 = refractedDir;
                                let _e569 = refractedDir;
                                if (abs(_e566.x) < abs(_e569.z)) {
                                    {
                                        let _e573 = _o_X_1;
                                        let _e574 = refractedDir;
                                        let _e576 = refractedDir;
                                        let _e580 = _o_ratio_1;
                                        let _e584 = refractedDir;
                                        _o_X_1 = (_e573 + ((((_e574.x / abs(_e576.z)) * _e580) * 0.5f) * -(sign(_e584.z))));
                                        let _e590 = _o_Y_1;
                                        let _e591 = refractedDir;
                                        let _e593 = refractedDir;
                                        _o_Y_1 = (_e590 + ((_e591.y / abs(_e593.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e600 = _o_X_1;
                                        let _e601 = refractedDir;
                                        let _e603 = refractedDir;
                                        let _e607 = _o_ratio_1;
                                        let _e611 = refractedDir;
                                        _o_X_1 = (_e600 + ((((_e601.z / abs(_e603.x)) * _e607) * 0.5f) * -(sign(_e611.x))));
                                        let _e617 = _o_Y_1;
                                        let _e618 = refractedDir;
                                        let _e620 = refractedDir;
                                        _o_Y_1 = (_e617 + ((_e618.y / abs(_e620.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e627 = _o_X_1;
                            let _e628 = _o_Y_1;
                            let _e638 = global.U[0];
                            let _e641 = _o_X_1;
                            let _e642 = _o_Y_1;
                            let _e657 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e627, _e628) * 2f) - vec2(1f)).x / _e638.x), ((vec2<f32>(_e641, _e642) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            refractedColor = _e657;
                        }
                    } else {
                        {
                            let _e658 = refractedDir;
                            let _e663 = ((_e658 * 0.5f) + vec3(0.5f));
                            refractedColor = vec4<f32>(_e663.x, _e663.y, _e663.z, 1f);
                        }
                    }
                }
            }
            let _e671 = reflectivity_1;
            balance = (1f - (2f * _e671));
            let _e675 = reflectedColor;
            let _e676 = refractedColor;
            let _e677 = incidence;
            let _e678 = balance;
            mixedCol = mix(_e675, _e676, vec4(clamp((_e677 + _e678), 0f, 1f)));
            let _e686 = mixedCol;
            let _e687 = mixedCol;
            let _e689 = objectColor_1;
            let _e691 = (2f * _e689.xyz);
            let _e698 = objectColor_1;
            mixedCol = mix(_e686, (_e687 * vec4<f32>(_e691.x, _e691.y, _e691.z, 1f)), vec4(_e698.w));
            let _e702 = mixedCol;
            return _e702;
        }
    } else {
        {
            let _e703 = dir_2;
            let _e704 = cameraPos;
            let _e707 = dir_2;
            let _e710 = radius_2;
            minDist = abs(((length(cross(_e703, _e704)) / length(_e707)) - _e710));
            let _e717 = backgroundStyle_1;
            if (_e717 == 0i) {
                {
                    let _e720 = dir_2;
                    _o_n_2 = normalize(_e720);
                    let _e723 = _o_n_2;
                    let _e725 = _o_n_2;
                    _o_alpha_2 = atan2(_e723.z, _e725.x);
                    let _e729 = _o_n_2;
                    _o_beta_2 = asin(_e729.y);
                    let _e737 = _o_alpha_2;
                    let _e743 = _o_nX_2;
                    let _e746 = _o_nY_2;
                    let _e747 = _o_beta_2;
                    _o_pos_4 = ((vec2<f32>((((-(_e737) / 3.1415927f) * 0.5f) * _e743), (0.5f + ((_e746 * _e747) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e759 = _o_pos_4;
                    let _e763 = global.U[0];
                    let _e766 = _o_pos_4;
                    let _e775 = textureSample(t_source, samp, ((vec2<f32>((_e759.x / _e763.x), _e766.y) / vec2(2f)) + vec2(0.5f)));
                    bkg = _e775;
                }
            } else {
                let _e776 = backgroundStyle_1;
                if (_e776 == 1i) {
                    {
                        let _e779 = dir_2;
                        let _e782 = dir_2;
                        let _e785 = dir_2;
                        let _e788 = dir_2;
                        _o_pos_5 = vec2<f32>((-(_e779.x) / _e782.z), (-(_e785.y) / _e788.z));
                        let _e793 = _o_pos_5;
                        let _e796 = _o_pos_5;
                        _o_m_2 = max(abs(_e793.x), abs(_e796.y));
                        let _e803 = _o_m_2;
                        _o_darken_2 = (4f / max(4f, _e803));
                        let _e807 = _o_pos_5;
                        let _e811 = global.U[0];
                        let _e814 = _o_pos_5;
                        let _e823 = textureSample(t_source, samp, ((vec2<f32>((_e807.x / _e811.x), _e814.y) / vec2(2f)) + vec2(0.5f)));
                        let _e824 = _o_darken_2;
                        let _e825 = _o_darken_2;
                        let _e826 = _o_darken_2;
                        bkg = (_e823 * vec4<f32>(_e824, _e825, _e826, 1f));
                    }
                } else {
                    let _e830 = backgroundStyle_1;
                    if (_e830 == 2i) {
                        {
                            let _e833 = sourceDim_1;
                            let _e835 = sourceDim_1;
                            _o_ratio_2 = (_e833.y / _e835.x);
                            let _e843 = dir_2;
                            let _e846 = dir_2;
                            let _e849 = _o_ratio_2;
                            let _e852 = dir_2;
                            let _e855 = dir_2;
                            let _e858 = _o_ratio_2;
                            if ((abs(_e843.y) > (abs(_e846.z) * _e849)) && (abs(_e852.y) > (abs(_e855.x) * _e858))) {
                                {
                                    let _e862 = _o_X_2;
                                    let _e863 = dir_2;
                                    let _e866 = dir_2;
                                    _o_X_2 = (_e862 + ((-(_e863.x) / _e866.y) * 0.5f));
                                    let _e872 = _o_Y_2;
                                    let _e873 = dir_2;
                                    let _e876 = dir_2;
                                    _o_Y_2 = (_e872 + ((-(_e873.z) / _e876.y) * 0.5f));
                                }
                            } else {
                                let _e882 = dir_2;
                                let _e885 = dir_2;
                                if (abs(_e882.x) < abs(_e885.z)) {
                                    {
                                        let _e889 = _o_X_2;
                                        let _e890 = dir_2;
                                        let _e892 = dir_2;
                                        let _e896 = _o_ratio_2;
                                        let _e900 = dir_2;
                                        _o_X_2 = (_e889 + ((((_e890.x / abs(_e892.z)) * _e896) * 0.5f) * -(sign(_e900.z))));
                                        let _e906 = _o_Y_2;
                                        let _e907 = dir_2;
                                        let _e909 = dir_2;
                                        _o_Y_2 = (_e906 + ((_e907.y / abs(_e909.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e916 = _o_X_2;
                                        let _e917 = dir_2;
                                        let _e919 = dir_2;
                                        let _e923 = _o_ratio_2;
                                        let _e927 = dir_2;
                                        _o_X_2 = (_e916 + ((((_e917.z / abs(_e919.x)) * _e923) * 0.5f) * -(sign(_e927.x))));
                                        let _e933 = _o_Y_2;
                                        let _e934 = dir_2;
                                        let _e936 = dir_2;
                                        _o_Y_2 = (_e933 + ((_e934.y / abs(_e936.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e943 = _o_X_2;
                            let _e944 = _o_Y_2;
                            let _e954 = global.U[0];
                            let _e957 = _o_X_2;
                            let _e958 = _o_Y_2;
                            let _e973 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e943, _e944) * 2f) - vec2(1f)).x / _e954.x), ((vec2<f32>(_e957, _e958) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            bkg = _e973;
                        }
                    } else {
                        {
                            let _e974 = dir_2;
                            let _e979 = ((_e974 * 0.5f) + vec3(0.5f));
                            bkg = vec4<f32>(_e979.x, _e979.y, _e979.z, 1f);
                        }
                    }
                }
            }
            let _e985 = bkg;
            let _e989 = bkgColor_1;
            let _e991 = (2f * _e989.xyz);
            let _e997 = bkgColor_1;
            let _e1002 = glowColor_1;
            let _e1006 = minDist;
            let _e1010 = ((_e1002.xyz * 0.2f) / vec3(pow(_e1006, 1.5f)));
            let _e1016 = glowColor_1;
            return ((_e985 * mix(vec4(1f), vec4<f32>(_e991.x, _e991.y, _e991.z, 1f), vec4(_e997.w))) + (vec4<f32>(_e1010.x, _e1010.y, _e1010.z, 0f) * _e1016.w));
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
    let _e99 = global.U[4];
    let _e103 = global.U[10];
    let _e107 = global.U[11];
    let _e111 = global.U[12];
    let _e114 = global.U[13];
    let _e117 = global.U[14];
    let _e120 = global.U[15];
    let _e123 = cubeGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111, _e114, _e117, i32(_e120.x));
    fragColor = _e123;
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
