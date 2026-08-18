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
                    let _e165 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e148.x / _e152.x), _e155.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    reflectedColor = _e165;
                }
            } else {
                let _e166 = backgroundStyle_1;
                if (_e166 == 1i) {
                    {
                        let _e169 = reflectedDir;
                        let _e172 = reflectedDir;
                        let _e175 = reflectedDir;
                        let _e178 = reflectedDir;
                        _o_pos_1 = vec2<f32>((-(_e169.x) / _e172.z), (-(_e175.y) / _e178.z));
                        let _e183 = _o_pos_1;
                        let _e186 = _o_pos_1;
                        _o_m = max(abs(_e183.x), abs(_e186.y));
                        let _e193 = _o_m;
                        _o_darken = (4f / max(4f, _e193));
                        let _e197 = _o_pos_1;
                        let _e201 = global.U[0];
                        let _e204 = _o_pos_1;
                        let _e214 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e197.x / _e201.x), _e204.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e215 = _o_darken;
                        let _e216 = _o_darken;
                        let _e217 = _o_darken;
                        reflectedColor = (_e214 * vec4<f32>(_e215, _e216, _e217, 1f));
                    }
                } else {
                    let _e221 = backgroundStyle_1;
                    if (_e221 == 2i) {
                        {
                            let _e224 = sourceDim_1;
                            let _e226 = sourceDim_1;
                            _o_ratio = (_e224.y / _e226.x);
                            let _e234 = reflectedDir;
                            let _e237 = reflectedDir;
                            let _e240 = _o_ratio;
                            let _e243 = reflectedDir;
                            let _e246 = reflectedDir;
                            let _e249 = _o_ratio;
                            if ((abs(_e234.y) > (abs(_e237.z) * _e240)) && (abs(_e243.y) > (abs(_e246.x) * _e249))) {
                                {
                                    let _e253 = _o_X;
                                    let _e254 = reflectedDir;
                                    let _e257 = reflectedDir;
                                    _o_X = (_e253 + ((-(_e254.x) / _e257.y) * 0.5f));
                                    let _e263 = _o_Y;
                                    let _e264 = reflectedDir;
                                    let _e267 = reflectedDir;
                                    _o_Y = (_e263 + ((-(_e264.z) / _e267.y) * 0.5f));
                                }
                            } else {
                                let _e273 = reflectedDir;
                                let _e276 = reflectedDir;
                                if (abs(_e273.x) < abs(_e276.z)) {
                                    {
                                        let _e280 = _o_X;
                                        let _e281 = reflectedDir;
                                        let _e283 = reflectedDir;
                                        let _e287 = _o_ratio;
                                        let _e291 = reflectedDir;
                                        _o_X = (_e280 + ((((_e281.x / abs(_e283.z)) * _e287) * 0.5f) * -(sign(_e291.z))));
                                        let _e297 = _o_Y;
                                        let _e298 = reflectedDir;
                                        let _e300 = reflectedDir;
                                        _o_Y = (_e297 + ((_e298.y / abs(_e300.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e307 = _o_X;
                                        let _e308 = reflectedDir;
                                        let _e310 = reflectedDir;
                                        let _e314 = _o_ratio;
                                        let _e318 = reflectedDir;
                                        _o_X = (_e307 + ((((_e308.z / abs(_e310.x)) * _e314) * 0.5f) * -(sign(_e318.x))));
                                        let _e324 = _o_Y;
                                        let _e325 = reflectedDir;
                                        let _e327 = reflectedDir;
                                        _o_Y = (_e324 + ((_e325.y / abs(_e327.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e334 = _o_X;
                            let _e335 = _o_Y;
                            let _e345 = global.U[0];
                            let _e348 = _o_X;
                            let _e349 = _o_Y;
                            let _e365 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e334, _e335) * 2f) - vec2(1f)).x / _e345.x), ((vec2<f32>(_e348, _e349) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            reflectedColor = _e365;
                        }
                    } else {
                        {
                            let _e366 = reflectedDir;
                            let _e371 = ((_e366 * 0.5f) + vec3(0.5f));
                            reflectedColor = vec4<f32>(_e371.x, _e371.y, _e371.z, 1f);
                        }
                    }
                }
            }
            let _e379 = radius_2;
            let _e380 = intersection_2;
            let _e381 = refractedDir;
            let _e385 = refractedDir;
            let _e386 = cubeIntersection(vec3(0f), _e379, (_e380 + (_e381 * 0.00001f)), _e385);
            intersection2_ = _e386;
            let _e388 = intersection2_;
            if (_e388.x < 100000000f) {
                {
                    let _e394 = intersection2_;
                    let _e395 = cubeFaceNormal(vec3(0f), _e394);
                    normal = -(_e395);
                    let _e397 = refractedDir;
                    let _e398 = normal;
                    let _e399 = eta;
                    refractedDir = refract(_e397, _e398, _e399);
                }
            }
            let _e404 = backgroundStyle_1;
            if (_e404 == 0i) {
                {
                    let _e407 = refractedDir;
                    _o_n_1 = normalize(_e407);
                    let _e410 = _o_n_1;
                    let _e412 = _o_n_1;
                    _o_alpha_1 = atan2(_e410.z, _e412.x);
                    let _e416 = _o_n_1;
                    _o_beta_1 = asin(_e416.y);
                    let _e424 = _o_alpha_1;
                    let _e430 = _o_nX_1;
                    let _e433 = _o_nY_1;
                    let _e434 = _o_beta_1;
                    _o_pos_2 = ((vec2<f32>((((-(_e424) / 3.1415927f) * 0.5f) * _e430), (0.5f + ((_e433 * _e434) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e446 = _o_pos_2;
                    let _e450 = global.U[0];
                    let _e453 = _o_pos_2;
                    let _e463 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e446.x / _e450.x), _e453.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    refractedColor = _e463;
                }
            } else {
                let _e464 = backgroundStyle_1;
                if (_e464 == 1i) {
                    {
                        let _e467 = refractedDir;
                        let _e470 = refractedDir;
                        let _e473 = refractedDir;
                        let _e476 = refractedDir;
                        _o_pos_3 = vec2<f32>((-(_e467.x) / _e470.z), (-(_e473.y) / _e476.z));
                        let _e481 = _o_pos_3;
                        let _e484 = _o_pos_3;
                        _o_m_1 = max(abs(_e481.x), abs(_e484.y));
                        let _e491 = _o_m_1;
                        _o_darken_1 = (4f / max(4f, _e491));
                        let _e495 = _o_pos_3;
                        let _e499 = global.U[0];
                        let _e502 = _o_pos_3;
                        let _e512 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e495.x / _e499.x), _e502.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e513 = _o_darken_1;
                        let _e514 = _o_darken_1;
                        let _e515 = _o_darken_1;
                        refractedColor = (_e512 * vec4<f32>(_e513, _e514, _e515, 1f));
                    }
                } else {
                    let _e519 = backgroundStyle_1;
                    if (_e519 == 2i) {
                        {
                            let _e522 = sourceDim_1;
                            let _e524 = sourceDim_1;
                            _o_ratio_1 = (_e522.y / _e524.x);
                            let _e532 = refractedDir;
                            let _e535 = refractedDir;
                            let _e538 = _o_ratio_1;
                            let _e541 = refractedDir;
                            let _e544 = refractedDir;
                            let _e547 = _o_ratio_1;
                            if ((abs(_e532.y) > (abs(_e535.z) * _e538)) && (abs(_e541.y) > (abs(_e544.x) * _e547))) {
                                {
                                    let _e551 = _o_X_1;
                                    let _e552 = refractedDir;
                                    let _e555 = refractedDir;
                                    _o_X_1 = (_e551 + ((-(_e552.x) / _e555.y) * 0.5f));
                                    let _e561 = _o_Y_1;
                                    let _e562 = refractedDir;
                                    let _e565 = refractedDir;
                                    _o_Y_1 = (_e561 + ((-(_e562.z) / _e565.y) * 0.5f));
                                }
                            } else {
                                let _e571 = refractedDir;
                                let _e574 = refractedDir;
                                if (abs(_e571.x) < abs(_e574.z)) {
                                    {
                                        let _e578 = _o_X_1;
                                        let _e579 = refractedDir;
                                        let _e581 = refractedDir;
                                        let _e585 = _o_ratio_1;
                                        let _e589 = refractedDir;
                                        _o_X_1 = (_e578 + ((((_e579.x / abs(_e581.z)) * _e585) * 0.5f) * -(sign(_e589.z))));
                                        let _e595 = _o_Y_1;
                                        let _e596 = refractedDir;
                                        let _e598 = refractedDir;
                                        _o_Y_1 = (_e595 + ((_e596.y / abs(_e598.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e605 = _o_X_1;
                                        let _e606 = refractedDir;
                                        let _e608 = refractedDir;
                                        let _e612 = _o_ratio_1;
                                        let _e616 = refractedDir;
                                        _o_X_1 = (_e605 + ((((_e606.z / abs(_e608.x)) * _e612) * 0.5f) * -(sign(_e616.x))));
                                        let _e622 = _o_Y_1;
                                        let _e623 = refractedDir;
                                        let _e625 = refractedDir;
                                        _o_Y_1 = (_e622 + ((_e623.y / abs(_e625.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e632 = _o_X_1;
                            let _e633 = _o_Y_1;
                            let _e643 = global.U[0];
                            let _e646 = _o_X_1;
                            let _e647 = _o_Y_1;
                            let _e663 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e632, _e633) * 2f) - vec2(1f)).x / _e643.x), ((vec2<f32>(_e646, _e647) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            refractedColor = _e663;
                        }
                    } else {
                        {
                            let _e664 = refractedDir;
                            let _e669 = ((_e664 * 0.5f) + vec3(0.5f));
                            refractedColor = vec4<f32>(_e669.x, _e669.y, _e669.z, 1f);
                        }
                    }
                }
            }
            let _e677 = reflectivity_1;
            balance = (1f - (2f * _e677));
            let _e681 = reflectedColor;
            let _e682 = refractedColor;
            let _e683 = incidence;
            let _e684 = balance;
            mixedCol = mix(_e681, _e682, vec4(clamp((_e683 + _e684), 0f, 1f)));
            let _e692 = mixedCol;
            let _e693 = mixedCol;
            let _e695 = objectColor_1;
            let _e697 = (2f * _e695.xyz);
            let _e704 = objectColor_1;
            mixedCol = mix(_e692, (_e693 * vec4<f32>(_e697.x, _e697.y, _e697.z, 1f)), vec4(_e704.w));
            let _e708 = mixedCol;
            return _e708;
        }
    } else {
        {
            let _e709 = dir_2;
            let _e710 = cameraPos;
            let _e713 = dir_2;
            let _e716 = radius_2;
            minDist = abs(((length(cross(_e709, _e710)) / length(_e713)) - _e716));
            let _e723 = backgroundStyle_1;
            if (_e723 == 0i) {
                {
                    let _e726 = dir_2;
                    _o_n_2 = normalize(_e726);
                    let _e729 = _o_n_2;
                    let _e731 = _o_n_2;
                    _o_alpha_2 = atan2(_e729.z, _e731.x);
                    let _e735 = _o_n_2;
                    _o_beta_2 = asin(_e735.y);
                    let _e743 = _o_alpha_2;
                    let _e749 = _o_nX_2;
                    let _e752 = _o_nY_2;
                    let _e753 = _o_beta_2;
                    _o_pos_4 = ((vec2<f32>((((-(_e743) / 3.1415927f) * 0.5f) * _e749), (0.5f + ((_e752 * _e753) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e765 = _o_pos_4;
                    let _e769 = global.U[0];
                    let _e772 = _o_pos_4;
                    let _e782 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e765.x / _e769.x), _e772.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    bkg = _e782;
                }
            } else {
                let _e783 = backgroundStyle_1;
                if (_e783 == 1i) {
                    {
                        let _e786 = dir_2;
                        let _e789 = dir_2;
                        let _e792 = dir_2;
                        let _e795 = dir_2;
                        _o_pos_5 = vec2<f32>((-(_e786.x) / _e789.z), (-(_e792.y) / _e795.z));
                        let _e800 = _o_pos_5;
                        let _e803 = _o_pos_5;
                        _o_m_2 = max(abs(_e800.x), abs(_e803.y));
                        let _e810 = _o_m_2;
                        _o_darken_2 = (4f / max(4f, _e810));
                        let _e814 = _o_pos_5;
                        let _e818 = global.U[0];
                        let _e821 = _o_pos_5;
                        let _e831 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e814.x / _e818.x), _e821.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e832 = _o_darken_2;
                        let _e833 = _o_darken_2;
                        let _e834 = _o_darken_2;
                        bkg = (_e831 * vec4<f32>(_e832, _e833, _e834, 1f));
                    }
                } else {
                    let _e838 = backgroundStyle_1;
                    if (_e838 == 2i) {
                        {
                            let _e841 = sourceDim_1;
                            let _e843 = sourceDim_1;
                            _o_ratio_2 = (_e841.y / _e843.x);
                            let _e851 = dir_2;
                            let _e854 = dir_2;
                            let _e857 = _o_ratio_2;
                            let _e860 = dir_2;
                            let _e863 = dir_2;
                            let _e866 = _o_ratio_2;
                            if ((abs(_e851.y) > (abs(_e854.z) * _e857)) && (abs(_e860.y) > (abs(_e863.x) * _e866))) {
                                {
                                    let _e870 = _o_X_2;
                                    let _e871 = dir_2;
                                    let _e874 = dir_2;
                                    _o_X_2 = (_e870 + ((-(_e871.x) / _e874.y) * 0.5f));
                                    let _e880 = _o_Y_2;
                                    let _e881 = dir_2;
                                    let _e884 = dir_2;
                                    _o_Y_2 = (_e880 + ((-(_e881.z) / _e884.y) * 0.5f));
                                }
                            } else {
                                let _e890 = dir_2;
                                let _e893 = dir_2;
                                if (abs(_e890.x) < abs(_e893.z)) {
                                    {
                                        let _e897 = _o_X_2;
                                        let _e898 = dir_2;
                                        let _e900 = dir_2;
                                        let _e904 = _o_ratio_2;
                                        let _e908 = dir_2;
                                        _o_X_2 = (_e897 + ((((_e898.x / abs(_e900.z)) * _e904) * 0.5f) * -(sign(_e908.z))));
                                        let _e914 = _o_Y_2;
                                        let _e915 = dir_2;
                                        let _e917 = dir_2;
                                        _o_Y_2 = (_e914 + ((_e915.y / abs(_e917.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e924 = _o_X_2;
                                        let _e925 = dir_2;
                                        let _e927 = dir_2;
                                        let _e931 = _o_ratio_2;
                                        let _e935 = dir_2;
                                        _o_X_2 = (_e924 + ((((_e925.z / abs(_e927.x)) * _e931) * 0.5f) * -(sign(_e935.x))));
                                        let _e941 = _o_Y_2;
                                        let _e942 = dir_2;
                                        let _e944 = dir_2;
                                        _o_Y_2 = (_e941 + ((_e942.y / abs(_e944.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e951 = _o_X_2;
                            let _e952 = _o_Y_2;
                            let _e962 = global.U[0];
                            let _e965 = _o_X_2;
                            let _e966 = _o_Y_2;
                            let _e982 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e951, _e952) * 2f) - vec2(1f)).x / _e962.x), ((vec2<f32>(_e965, _e966) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            bkg = _e982;
                        }
                    } else {
                        {
                            let _e983 = dir_2;
                            let _e988 = ((_e983 * 0.5f) + vec3(0.5f));
                            bkg = vec4<f32>(_e988.x, _e988.y, _e988.z, 1f);
                        }
                    }
                }
            }
            let _e994 = bkg;
            let _e998 = bkgColor_1;
            let _e1000 = (2f * _e998.xyz);
            let _e1006 = bkgColor_1;
            let _e1011 = glowColor_1;
            let _e1015 = minDist;
            let _e1019 = ((_e1011.xyz * 0.2f) / vec3(pow(_e1015, 1.5f)));
            let _e1025 = glowColor_1;
            return ((_e994 * mix(vec4(1f), vec4<f32>(_e1000.x, _e1000.y, _e1000.z, 1f), vec4(_e1006.w))) + (vec4<f32>(_e1019.x, _e1019.y, _e1019.z, 0f) * _e1025.w));
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
