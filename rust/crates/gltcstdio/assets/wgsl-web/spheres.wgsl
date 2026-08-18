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
                {
                    let _e90 = l;
                    return _e90;
                }
            }
        }
    }
    return -1f;
}

fn spheres(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32, spheres_size: i32) -> vec4<f32> {
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
    var _o_nX: f32;
    var _o_nY: f32;
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
    var _o_nX_1: f32 = 2f;
    var _o_nY_1: f32 = 1f;
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
                                    _o_nX = 2f;
                                    _o_nY = 1f;
                                    let _e218 = _o_alpha;
                                    let _e224 = _o_nX;
                                    let _e227 = _o_nY;
                                    let _e228 = _o_beta;
                                    _o_pos = ((vec2<f32>((((-(_e218) / 3.1415927f) * 0.5f) * _e224), (0.5f + ((_e227 * _e228) / 3.1415927f))) * 2f) - vec2(1f));
                                    let _e240 = _o_pos;
                                    let _e244 = global.U[0];
                                    let _e247 = _o_pos;
                                    let _e257 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e240.x / _e244.x), _e247.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e257;
                                }
                            } else {
                                let _e258 = backgroundStyle_1;
                                if (_e258 == 1i) {
                                    {
                                        let _e261 = reflectedDir;
                                        let _e264 = reflectedDir;
                                        let _e267 = reflectedDir;
                                        let _e270 = reflectedDir;
                                        _o_pos_1 = vec2<f32>((-(_e261.x) / _e264.z), (-(_e267.y) / _e270.z));
                                        let _e275 = _o_pos_1;
                                        let _e278 = _o_pos_1;
                                        _o_m = max(abs(_e275.x), abs(_e278.y));
                                        let _e285 = _o_m;
                                        _o_darken = (4f / max(4f, _e285));
                                        let _e289 = _o_pos_1;
                                        let _e293 = global.U[0];
                                        let _e296 = _o_pos_1;
                                        let _e306 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e289.x / _e293.x), _e296.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e307 = _o_darken;
                                        let _e308 = _o_darken;
                                        let _e309 = _o_darken;
                                        _reflBkg = (_e306 * vec4<f32>(_e307, _e308, _e309, 1f));
                                    }
                                } else {
                                    let _e313 = backgroundStyle_1;
                                    if (_e313 == 2i) {
                                        {
                                            let _e316 = sourceDim_1;
                                            let _e318 = sourceDim_1;
                                            _o_ratio = (_e316.y / _e318.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e326 = reflectedDir;
                                            let _e329 = reflectedDir;
                                            let _e332 = _o_ratio;
                                            let _e335 = reflectedDir;
                                            let _e338 = reflectedDir;
                                            let _e341 = _o_ratio;
                                            if ((abs(_e326.y) > (abs(_e329.z) * _e332)) && (abs(_e335.y) > (abs(_e338.x) * _e341))) {
                                                {
                                                    let _e345 = _o_X;
                                                    let _e346 = reflectedDir;
                                                    let _e349 = reflectedDir;
                                                    _o_X = (_e345 + ((-(_e346.x) / _e349.y) * 0.5f));
                                                    let _e355 = _o_Y;
                                                    let _e356 = reflectedDir;
                                                    let _e359 = reflectedDir;
                                                    _o_Y = (_e355 + ((-(_e356.z) / _e359.y) * 0.5f));
                                                }
                                            } else {
                                                let _e365 = reflectedDir;
                                                let _e368 = reflectedDir;
                                                if (abs(_e365.x) < abs(_e368.z)) {
                                                    {
                                                        let _e372 = _o_X;
                                                        let _e373 = reflectedDir;
                                                        let _e375 = reflectedDir;
                                                        let _e379 = _o_ratio;
                                                        let _e383 = reflectedDir;
                                                        _o_X = (_e372 + ((((_e373.x / abs(_e375.z)) * _e379) * 0.5f) * -(sign(_e383.z))));
                                                        let _e389 = _o_Y;
                                                        let _e390 = reflectedDir;
                                                        let _e392 = reflectedDir;
                                                        _o_Y = (_e389 + ((_e390.y / abs(_e392.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e399 = _o_X;
                                                        let _e400 = reflectedDir;
                                                        let _e402 = reflectedDir;
                                                        let _e406 = _o_ratio;
                                                        let _e410 = reflectedDir;
                                                        _o_X = (_e399 + ((((_e400.z / abs(_e402.x)) * _e406) * 0.5f) * -(sign(_e410.x))));
                                                        let _e416 = _o_Y;
                                                        let _e417 = reflectedDir;
                                                        let _e419 = reflectedDir;
                                                        _o_Y = (_e416 + ((_e417.y / abs(_e419.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e426 = _o_X;
                                            let _e427 = _o_Y;
                                            let _e437 = global.U[0];
                                            let _e440 = _o_X;
                                            let _e441 = _o_Y;
                                            let _e457 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e426, _e427) * 2f) - vec2(1f)).x / _e437.x), ((vec2<f32>(_e440, _e441) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e457;
                                        }
                                    } else {
                                        {
                                            let _e458 = reflectedDir;
                                            let _e463 = ((_e458 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e463.x, _e463.y, _e463.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e469 = _reflBkg;
                            let _e476 = objectColor_1;
                            let _e478 = (2f * _e476.xyz);
                            let _e484 = objectColor_1;
                            reflectedColor = (_e469 * mix(vec4<f32>(1f, 1f, 1f, 1f), vec4<f32>(_e478.x, _e478.y, _e478.z, 1f), vec4(_e484.w)));
                        }
                    }
                    let _e489 = dir_2;
                    let _e490 = normal;
                    let _e491 = eta;
                    dir_2 = refract(_e489, _e490, _e491);
                    let _e493 = intersection;
                    let _e494 = dir_2;
                    origin_2 = (_e493 + (_e494 * 0.001f));
                }
            }
            let _e498 = iter;
            iter = (_e498 - 1i);
        }
        let _e501 = minI;
        let _e504 = iter;
        if !(((_e501 >= 0i) && (_e504 > 0i))) {
            break;
        }
    }
    let _e511 = reflectivity_1;
    balance = (1f - (2f * _e511));
    let _e518 = backgroundStyle_1;
    if (_e518 == 0i) {
        {
            let _e521 = dir_2;
            _o_n_1 = normalize(_e521);
            let _e524 = _o_n_1;
            let _e526 = _o_n_1;
            _o_alpha_1 = atan2(_e524.z, _e526.x);
            let _e530 = _o_n_1;
            _o_beta_1 = asin(_e530.y);
            let _e538 = _o_alpha_1;
            let _e544 = _o_nX_1;
            let _e547 = _o_nY_1;
            let _e548 = _o_beta_1;
            _o_pos_2 = ((vec2<f32>((((-(_e538) / 3.1415927f) * 0.5f) * _e544), (0.5f + ((_e547 * _e548) / 3.1415927f))) * 2f) - vec2(1f));
            let _e560 = _o_pos_2;
            let _e564 = global.U[0];
            let _e567 = _o_pos_2;
            let _e577 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e560.x / _e564.x), _e567.y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e577;
        }
    } else {
        let _e578 = backgroundStyle_1;
        if (_e578 == 1i) {
            {
                let _e581 = dir_2;
                let _e584 = dir_2;
                let _e587 = dir_2;
                let _e590 = dir_2;
                _o_pos_3 = vec2<f32>((-(_e581.x) / _e584.z), (-(_e587.y) / _e590.z));
                let _e595 = _o_pos_3;
                let _e598 = _o_pos_3;
                _o_m_1 = max(abs(_e595.x), abs(_e598.y));
                let _e605 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e605));
                let _e609 = _o_pos_3;
                let _e613 = global.U[0];
                let _e616 = _o_pos_3;
                let _e626 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e609.x / _e613.x), _e616.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e627 = _o_darken_1;
                let _e628 = _o_darken_1;
                let _e629 = _o_darken_1;
                _bkg = (_e626 * vec4<f32>(_e627, _e628, _e629, 1f));
            }
        } else {
            let _e633 = backgroundStyle_1;
            if (_e633 == 2i) {
                {
                    let _e636 = sourceDim_1;
                    let _e638 = sourceDim_1;
                    _o_ratio_1 = (_e636.y / _e638.x);
                    let _e646 = dir_2;
                    let _e649 = dir_2;
                    let _e652 = _o_ratio_1;
                    let _e655 = dir_2;
                    let _e658 = dir_2;
                    let _e661 = _o_ratio_1;
                    if ((abs(_e646.y) > (abs(_e649.z) * _e652)) && (abs(_e655.y) > (abs(_e658.x) * _e661))) {
                        {
                            let _e665 = _o_X_1;
                            let _e666 = dir_2;
                            let _e669 = dir_2;
                            _o_X_1 = (_e665 + ((-(_e666.x) / _e669.y) * 0.5f));
                            let _e675 = _o_Y_1;
                            let _e676 = dir_2;
                            let _e679 = dir_2;
                            _o_Y_1 = (_e675 + ((-(_e676.z) / _e679.y) * 0.5f));
                        }
                    } else {
                        let _e685 = dir_2;
                        let _e688 = dir_2;
                        if (abs(_e685.x) < abs(_e688.z)) {
                            {
                                let _e692 = _o_X_1;
                                let _e693 = dir_2;
                                let _e695 = dir_2;
                                let _e699 = _o_ratio_1;
                                let _e703 = dir_2;
                                _o_X_1 = (_e692 + ((((_e693.x / abs(_e695.z)) * _e699) * 0.5f) * -(sign(_e703.z))));
                                let _e709 = _o_Y_1;
                                let _e710 = dir_2;
                                let _e712 = dir_2;
                                _o_Y_1 = (_e709 + ((_e710.y / abs(_e712.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e719 = _o_X_1;
                                let _e720 = dir_2;
                                let _e722 = dir_2;
                                let _e726 = _o_ratio_1;
                                let _e730 = dir_2;
                                _o_X_1 = (_e719 + ((((_e720.z / abs(_e722.x)) * _e726) * 0.5f) * -(sign(_e730.x))));
                                let _e736 = _o_Y_1;
                                let _e737 = dir_2;
                                let _e739 = dir_2;
                                _o_Y_1 = (_e736 + ((_e737.y / abs(_e739.x)) * 0.5f));
                            }
                        }
                    }
                    let _e746 = _o_X_1;
                    let _e747 = _o_Y_1;
                    let _e757 = global.U[0];
                    let _e760 = _o_X_1;
                    let _e761 = _o_Y_1;
                    let _e777 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e746, _e747) * 2f) - vec2(1f)).x / _e757.x), ((vec2<f32>(_e760, _e761) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e777;
                }
            } else {
                {
                    let _e778 = dir_2;
                    let _e783 = ((_e778 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e783.x, _e783.y, _e783.z, 1f);
                }
            }
        }
    }
    let _e789 = _bkg;
    let _e796 = bkgColor_1;
    let _e798 = (2f * _e796.xyz);
    let _e804 = bkgColor_1;
    let _e809 = glowColor_1;
    let _e813 = minDist;
    let _e817 = ((_e809.xyz * 0.2f) / vec3(pow(_e813, 1.5f)));
    let _e823 = glowColor_1;
    col = ((_e789 * mix(vec4<f32>(1f, 1f, 1f, 1f), vec4<f32>(_e798.x, _e798.y, _e798.z, 1f), vec4(_e804.w))) + (vec4<f32>(_e817.x, _e817.y, _e817.z, 0f) * _e823.w));
    let _e828 = reflectedColor;
    let _e829 = col;
    let _e830 = incidence;
    let _e831 = balance;
    return mix(_e828, _e829, vec4(clamp((_e830 + _e831), 0f, 1f)));
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
    let _e130 = spheres((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), mat4x4<f32>(vec4<f32>(_e68.x, _e68.y, _e68.z, _e68.w), vec4<f32>(_e71.x, _e71.y, _e71.z, _e71.w), vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w)), _e101.xy, _e105.x, _e109.x, _e113, _e116, _e119, i32(_e122.x), i32(_e127.x));
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
