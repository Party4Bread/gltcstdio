struct Params {
    U: array<vec4<f32>, 21>,
    u_spheres: array<vec4<f32>, 32>,
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

fn sphereHitDist(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> f32 {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a: f32;
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
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e16 = origin_1;
    let _e17 = center_1;
    relOrigin = (_e16 - _e17);
    let _e20 = dir_1;
    let _e21 = dir_1;
    a = dot(_e20, _e21);
    let _e25 = dir_1;
    let _e26 = relOrigin;
    b = (2f * dot(_e25, _e26));
    let _e30 = relOrigin;
    let _e31 = relOrigin;
    let _e33 = radius_1;
    let _e34 = radius_1;
    c = (dot(_e30, _e31) - (_e33 * _e34));
    let _e38 = b;
    let _e39 = b;
    let _e42 = a;
    let _e44 = c;
    delta = ((_e38 * _e39) - ((4f * _e42) * _e44));
    let _e48 = delta;
    if (_e48 >= 0f) {
        {
            let _e51 = delta;
            sqrtDelta = sqrt(_e51);
            let _e54 = b;
            let _e56 = sqrtDelta;
            let _e59 = a;
            l1_ = ((-(_e54) - _e56) / (2f * _e59));
            let _e63 = b;
            let _e65 = sqrtDelta;
            let _e68 = a;
            l2_ = ((-(_e63) + _e65) / (2f * _e68));
            let _e72 = l1_;
            if (_e72 > 0f) {
                let _e75 = l1_;
                local_1 = _e75;
            } else {
                let _e76 = l2_;
                if (_e76 > 0f) {
                    let _e79 = l2_;
                    local = _e79;
                } else {
                    local = -1f;
                }
                let _e83 = local;
                local_1 = _e83;
            }
            let _e85 = local_1;
            l = _e85;
            let _e87 = l;
            if (_e87 > 0f) {
                let _e90 = l;
                return _e90;
            }
        }
    }
    return -1f;
}

fn spheresGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32, spheres_size: i32) -> vec4<f32> {
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
    var spheres_size_1: i32;
    var invModelTransform: mat4x4<f32>;
    var cameraPos: vec3<f32>;
    var D: f32 = 1f;
    var dir_2: vec3<f32>;
    var eta: f32;
    var origin_2: vec3<f32>;
    var maxIter: i32 = 12i;
    var iter: i32;
    var minI: i32 = -1i;
    var minK: f32 = 1000000f;
    var incidence: f32 = 2f;
    var reflectedColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var minDist: f32 = 1000000000f;
    var i: i32;
    var k: f32;
    var center_2: vec3<f32>;
    var intersection: vec3<f32>;
    var relInt: vec3<f32>;
    var local_2: vec3<f32>;
    var normal: vec3<f32>;
    var reflectedDir: vec3<f32>;
    var _reflBkg: vec4<f32>;
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_pos: vec2<f32>;
    var _o_pos_1: vec2<f32>;
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
    var _o_pos_2: vec2<f32>;
    var _o_pos_3: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var col: vec4<f32>;

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
    spheres_size_1 = spheres_size;
    let _e30 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e30);
    let _e33 = invModelTransform;
    cameraPos = (_e33 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e44 = pos_1;
    let _e46 = D;
    let _e48 = pos_1;
    let _e50 = D;
    dir_2 = normalize(vec3<f32>((_e44.x * _e46), (_e48.y * _e50), -1f));
    let _e57 = invModelTransform;
    let _e67 = dir_2;
    dir_2 = (mat3x3<f32>(_e57[0].xyz, _e57[1].xyz, _e57[2].xyz) * _e67);
    let _e71 = intensity_1;
    eta = (1f - (2f * _e71));
    let _e75 = cameraPos;
    origin_2 = _e75;
    let _e79 = maxIter;
    iter = _e79;
    loop {
        {
            minK = 1000000f;
            minI = -1i;
            i = 0i;
            loop {
                let _e101 = i;
                let _e102 = spheres_size_1;
                if !((_e101 < _e102)) {
                    break;
                }
                {
                    let _e108 = i;
                    let _e110 = global.u_spheres[_e108];
                    let _e112 = i;
                    let _e114 = global.u_spheres[_e112];
                    let _e116 = origin_2;
                    let _e117 = dir_2;
                    let _e118 = sphereHitDist(_e110.xyz, _e114.w, _e116, _e117);
                    k = _e118;
                    let _e120 = k;
                    let _e123 = k;
                    let _e124 = minK;
                    if ((_e120 > 0f) && (_e123 < _e124)) {
                        {
                            let _e127 = k;
                            minK = _e127;
                            let _e128 = i;
                            minI = _e128;
                        }
                    } else {
                        {
                            let _e129 = minDist;
                            let _e130 = dir_2;
                            let _e131 = cameraPos;
                            let _e132 = i;
                            let _e134 = global.u_spheres[_e132];
                            let _e139 = dir_2;
                            let _e142 = i;
                            let _e144 = global.u_spheres[_e142];
                            minDist = min(_e129, abs(((length(cross(_e130, (_e131 - _e134.xyz))) / length(_e139)) - _e144.w)));
                        }
                    }
                }
                continuing {
                    let _e105 = i;
                    i = (_e105 + 1i);
                }
            }
            let _e149 = minI;
            if (_e149 >= 0i) {
                {
                    let _e152 = minI;
                    let _e154 = global.u_spheres[_e152];
                    center_2 = _e154.xyz;
                    let _e157 = origin_2;
                    let _e158 = minK;
                    let _e159 = dir_2;
                    intersection = (_e157 + (_e158 * _e159));
                    let _e163 = intersection;
                    let _e164 = center_2;
                    relInt = (_e163 - _e164);
                    let _e167 = origin_2;
                    let _e168 = center_2;
                    let _e171 = minI;
                    let _e173 = global.u_spheres[_e171];
                    if (length((_e167 - _e168)) <= _e173.w) {
                        let _e176 = relInt;
                        local_2 = -(normalize(_e176));
                    } else {
                        let _e179 = relInt;
                        local_2 = normalize(_e179);
                    }
                    let _e182 = local_2;
                    normal = _e182;
                    let _e184 = iter;
                    let _e185 = maxIter;
                    if (_e184 == _e185) {
                        {
                            let _e187 = normal;
                            let _e188 = dir_2;
                            incidence = abs(dot(_e187, _e188));
                            let _e191 = dir_2;
                            let _e192 = normal;
                            reflectedDir = reflect(_e191, _e192);
                            _reflBkg = vec4(0f);
                            let _e198 = backgroundStyle_1;
                            if (_e198 == 0i) {
                                {
                                    let _e201 = reflectedDir;
                                    _o_n = normalize(_e201);
                                    let _e204 = _o_n;
                                    let _e206 = _o_n;
                                    _o_alpha = atan2(_e204.z, _e206.x);
                                    let _e210 = _o_n;
                                    _o_beta = asin(_e210.y);
                                    let _e214 = _o_alpha;
                                    let _e219 = _o_beta;
                                    _o_pos = ((vec2<f32>((-(_e214) / 3.1415927f), ((2f * _e219) / 3.1415927f)) * 2f) - vec2<f32>(0f, 0f));
                                    let _e231 = _o_alpha;
                                    let _e238 = _o_beta;
                                    let _e246 = global.U[0];
                                    let _e249 = _o_alpha;
                                    let _e256 = _o_beta;
                                    let _e269 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e231) / 3.1415927f) * 2f), ((2f * _e238) / 3.1415927f)).x / _e246.x), vec2<f32>(((-(_e249) / 3.1415927f) * 2f), ((2f * _e256) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
                                    _reflBkg = _e269;
                                }
                            } else {
                                let _e270 = backgroundStyle_1;
                                if (_e270 == 1i) {
                                    {
                                        let _e273 = reflectedDir;
                                        let _e276 = reflectedDir;
                                        let _e279 = reflectedDir;
                                        let _e282 = reflectedDir;
                                        _o_pos_1 = vec2<f32>((-(_e273.x) / _e276.z), (-(_e279.y) / _e282.z));
                                        let _e287 = _o_pos_1;
                                        let _e290 = _o_pos_1;
                                        _o_m = max(abs(_e287.x), abs(_e290.y));
                                        let _e297 = _o_m;
                                        _o_darken = (4f / max(4f, _e297));
                                        let _e301 = _o_pos_1;
                                        let _e305 = global.U[0];
                                        let _e308 = _o_pos_1;
                                        let _e317 = textureSample(t_source, samp, ((vec2<f32>((_e301.x / _e305.x), _e308.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e318 = _o_darken;
                                        let _e319 = _o_darken;
                                        let _e320 = _o_darken;
                                        _reflBkg = (_e317 * vec4<f32>(_e318, _e319, _e320, 1f));
                                    }
                                } else {
                                    let _e324 = backgroundStyle_1;
                                    if (_e324 == 2i) {
                                        {
                                            let _e327 = sourceDim_1;
                                            let _e329 = sourceDim_1;
                                            _o_ratio = (_e327.y / _e329.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e337 = reflectedDir;
                                            let _e340 = reflectedDir;
                                            let _e343 = _o_ratio;
                                            let _e346 = reflectedDir;
                                            let _e349 = reflectedDir;
                                            let _e352 = _o_ratio;
                                            if ((abs(_e337.y) > (abs(_e340.z) * _e343)) && (abs(_e346.y) > (abs(_e349.x) * _e352))) {
                                                {
                                                    let _e356 = _o_X;
                                                    let _e357 = reflectedDir;
                                                    let _e360 = reflectedDir;
                                                    _o_X = (_e356 + ((-(_e357.x) / _e360.y) * 0.5f));
                                                    let _e366 = _o_Y;
                                                    let _e367 = reflectedDir;
                                                    let _e370 = reflectedDir;
                                                    _o_Y = (_e366 + ((-(_e367.z) / _e370.y) * 0.5f));
                                                }
                                            } else {
                                                let _e376 = reflectedDir;
                                                let _e379 = reflectedDir;
                                                if (abs(_e376.x) < abs(_e379.z)) {
                                                    {
                                                        let _e383 = _o_X;
                                                        let _e384 = reflectedDir;
                                                        let _e386 = reflectedDir;
                                                        let _e390 = _o_ratio;
                                                        let _e394 = reflectedDir;
                                                        _o_X = (_e383 + ((((_e384.x / abs(_e386.z)) * _e390) * 0.5f) * -(sign(_e394.z))));
                                                        let _e400 = _o_Y;
                                                        let _e401 = reflectedDir;
                                                        let _e403 = reflectedDir;
                                                        _o_Y = (_e400 + ((_e401.y / abs(_e403.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e410 = _o_X;
                                                        let _e411 = reflectedDir;
                                                        let _e413 = reflectedDir;
                                                        let _e417 = _o_ratio;
                                                        let _e421 = reflectedDir;
                                                        _o_X = (_e410 + ((((_e411.z / abs(_e413.x)) * _e417) * 0.5f) * -(sign(_e421.x))));
                                                        let _e427 = _o_Y;
                                                        let _e428 = reflectedDir;
                                                        let _e430 = reflectedDir;
                                                        _o_Y = (_e427 + ((_e428.y / abs(_e430.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e437 = _o_X;
                                            let _e438 = _o_Y;
                                            let _e448 = global.U[0];
                                            let _e451 = _o_X;
                                            let _e452 = _o_Y;
                                            let _e467 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e437, _e438) * 2f) - vec2(1f)).x / _e448.x), ((vec2<f32>(_e451, _e452) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                                            _reflBkg = _e467;
                                        }
                                    } else {
                                        {
                                            let _e468 = reflectedDir;
                                            let _e473 = ((_e468 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e473.x, _e473.y, _e473.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e479 = _reflBkg;
                            let _e483 = objectColor_1;
                            let _e485 = (2f * _e483.xyz);
                            let _e491 = objectColor_1;
                            reflectedColor = (_e479 * mix(vec4(1f), vec4<f32>(_e485.x, _e485.y, _e485.z, 1f), vec4(_e491.w)));
                        }
                    }
                    let _e496 = dir_2;
                    let _e497 = normal;
                    let _e498 = eta;
                    dir_2 = refract(_e496, _e497, _e498);
                    let _e500 = intersection;
                    let _e501 = dir_2;
                    origin_2 = (_e500 + (_e501 * 0.001f));
                }
            }
            let _e505 = iter;
            iter = (_e505 - 1i);
        }
        let _e508 = minI;
        let _e511 = iter;
        if !(((_e508 >= 0i) && (_e511 > 0i))) {
            break;
        }
    }
    let _e518 = reflectivity_1;
    balance = (1f - (2f * _e518));
    let _e525 = backgroundStyle_1;
    if (_e525 == 0i) {
        {
            let _e528 = dir_2;
            _o_n_1 = normalize(_e528);
            let _e531 = _o_n_1;
            let _e533 = _o_n_1;
            _o_alpha_1 = atan2(_e531.z, _e533.x);
            let _e537 = _o_n_1;
            _o_beta_1 = asin(_e537.y);
            let _e541 = _o_alpha_1;
            let _e546 = _o_beta_1;
            _o_pos_2 = ((vec2<f32>((-(_e541) / 3.1415927f), ((2f * _e546) / 3.1415927f)) * 2f) - vec2<f32>(0f, 0f));
            let _e558 = _o_alpha_1;
            let _e565 = _o_beta_1;
            let _e573 = global.U[0];
            let _e576 = _o_alpha_1;
            let _e583 = _o_beta_1;
            let _e596 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e558) / 3.1415927f) * 2f), ((2f * _e565) / 3.1415927f)).x / _e573.x), vec2<f32>(((-(_e576) / 3.1415927f) * 2f), ((2f * _e583) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
            _bkg = _e596;
        }
    } else {
        let _e597 = backgroundStyle_1;
        if (_e597 == 1i) {
            {
                let _e600 = dir_2;
                let _e603 = dir_2;
                let _e606 = dir_2;
                let _e609 = dir_2;
                _o_pos_3 = vec2<f32>((-(_e600.x) / _e603.z), (-(_e606.y) / _e609.z));
                let _e614 = _o_pos_3;
                let _e617 = _o_pos_3;
                _o_m_1 = max(abs(_e614.x), abs(_e617.y));
                let _e624 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e624));
                let _e628 = _o_pos_3;
                let _e632 = global.U[0];
                let _e635 = _o_pos_3;
                let _e644 = textureSample(t_source, samp, ((vec2<f32>((_e628.x / _e632.x), _e635.y) / vec2(2f)) + vec2(0.5f)));
                let _e645 = _o_darken_1;
                let _e646 = _o_darken_1;
                let _e647 = _o_darken_1;
                _bkg = (_e644 * vec4<f32>(_e645, _e646, _e647, 1f));
            }
        } else {
            let _e651 = backgroundStyle_1;
            if (_e651 == 2i) {
                {
                    let _e654 = sourceDim_1;
                    let _e656 = sourceDim_1;
                    _o_ratio_1 = (_e654.y / _e656.x);
                    let _e664 = dir_2;
                    let _e667 = dir_2;
                    let _e670 = _o_ratio_1;
                    let _e673 = dir_2;
                    let _e676 = dir_2;
                    let _e679 = _o_ratio_1;
                    if ((abs(_e664.y) > (abs(_e667.z) * _e670)) && (abs(_e673.y) > (abs(_e676.x) * _e679))) {
                        {
                            let _e683 = _o_X_1;
                            let _e684 = dir_2;
                            let _e687 = dir_2;
                            _o_X_1 = (_e683 + ((-(_e684.x) / _e687.y) * 0.5f));
                            let _e693 = _o_Y_1;
                            let _e694 = dir_2;
                            let _e697 = dir_2;
                            _o_Y_1 = (_e693 + ((-(_e694.z) / _e697.y) * 0.5f));
                        }
                    } else {
                        let _e703 = dir_2;
                        let _e706 = dir_2;
                        if (abs(_e703.x) < abs(_e706.z)) {
                            {
                                let _e710 = _o_X_1;
                                let _e711 = dir_2;
                                let _e713 = dir_2;
                                let _e717 = _o_ratio_1;
                                let _e721 = dir_2;
                                _o_X_1 = (_e710 + ((((_e711.x / abs(_e713.z)) * _e717) * 0.5f) * -(sign(_e721.z))));
                                let _e727 = _o_Y_1;
                                let _e728 = dir_2;
                                let _e730 = dir_2;
                                _o_Y_1 = (_e727 + ((_e728.y / abs(_e730.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e737 = _o_X_1;
                                let _e738 = dir_2;
                                let _e740 = dir_2;
                                let _e744 = _o_ratio_1;
                                let _e748 = dir_2;
                                _o_X_1 = (_e737 + ((((_e738.z / abs(_e740.x)) * _e744) * 0.5f) * -(sign(_e748.x))));
                                let _e754 = _o_Y_1;
                                let _e755 = dir_2;
                                let _e757 = dir_2;
                                _o_Y_1 = (_e754 + ((_e755.y / abs(_e757.x)) * 0.5f));
                            }
                        }
                    }
                    let _e764 = _o_X_1;
                    let _e765 = _o_Y_1;
                    let _e775 = global.U[0];
                    let _e778 = _o_X_1;
                    let _e779 = _o_Y_1;
                    let _e794 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e764, _e765) * 2f) - vec2(1f)).x / _e775.x), ((vec2<f32>(_e778, _e779) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _bkg = _e794;
                }
            } else {
                {
                    let _e795 = dir_2;
                    let _e800 = ((_e795 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e800.x, _e800.y, _e800.z, 1f);
                }
            }
        }
    }
    let _e806 = _bkg;
    let _e810 = bkgColor_1;
    let _e812 = (2f * _e810.xyz);
    let _e818 = bkgColor_1;
    let _e823 = glowColor_1;
    let _e827 = minDist;
    let _e831 = ((_e823.xyz * 0.2f) / vec3(pow(_e827, 1.5f)));
    let _e837 = glowColor_1;
    col = ((_e806 * mix(vec4(1f), vec4<f32>(_e812.x, _e812.y, _e812.z, 1f), vec4(_e818.w))) + (vec4<f32>(_e831.x, _e831.y, _e831.z, 0f) * _e837.w));
    let _e842 = reflectedColor;
    let _e843 = col;
    let _e844 = incidence;
    let _e845 = balance;
    return mix(_e842, _e843, vec4(clamp((_e844 + _e845), 0f, 1f)));
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[6];
    let _e71 = global.U[7];
    let _e74 = global.U[8];
    let _e77 = global.U[9];
    let _e101 = global.U[4];
    let _e105 = global.U[10];
    let _e109 = global.U[11];
    let _e113 = global.U[12];
    let _e116 = global.U[13];
    let _e119 = global.U[14];
    let _e122 = global.U[15];
    let _e127 = global.U[16];
    let _e130 = spheresGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat4x4<f32>(vec4<f32>(_e68.x, _e68.y, _e68.z, _e68.w), vec4<f32>(_e71.x, _e71.y, _e71.z, _e71.w), vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w)), _e101.xy, _e105.x, _e109.x, _e113, _e116, _e119, i32(_e122.x), i32(_e127.x));
    fragColor = _e130;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
