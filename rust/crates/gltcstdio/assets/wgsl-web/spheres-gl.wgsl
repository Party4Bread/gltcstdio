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
                                    let _e270 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e231) / 3.1415927f) * 2f), ((2f * _e238) / 3.1415927f)).x / _e246.x), vec2<f32>(((-(_e249) / 3.1415927f) * 2f), ((2f * _e256) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    _reflBkg = _e270;
                                }
                            } else {
                                let _e271 = backgroundStyle_1;
                                if (_e271 == 1i) {
                                    {
                                        let _e274 = reflectedDir;
                                        let _e277 = reflectedDir;
                                        let _e280 = reflectedDir;
                                        let _e283 = reflectedDir;
                                        _o_pos_1 = vec2<f32>((-(_e274.x) / _e277.z), (-(_e280.y) / _e283.z));
                                        let _e288 = _o_pos_1;
                                        let _e291 = _o_pos_1;
                                        _o_m = max(abs(_e288.x), abs(_e291.y));
                                        let _e298 = _o_m;
                                        _o_darken = (4f / max(4f, _e298));
                                        let _e302 = _o_pos_1;
                                        let _e306 = global.U[0];
                                        let _e309 = _o_pos_1;
                                        let _e319 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e302.x / _e306.x), _e309.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e320 = _o_darken;
                                        let _e321 = _o_darken;
                                        let _e322 = _o_darken;
                                        _reflBkg = (_e319 * vec4<f32>(_e320, _e321, _e322, 1f));
                                    }
                                } else {
                                    let _e326 = backgroundStyle_1;
                                    if (_e326 == 2i) {
                                        {
                                            let _e329 = sourceDim_1;
                                            let _e331 = sourceDim_1;
                                            _o_ratio = (_e329.y / _e331.x);
                                            _o_X = 0.5f;
                                            _o_Y = 0.5f;
                                            let _e339 = reflectedDir;
                                            let _e342 = reflectedDir;
                                            let _e345 = _o_ratio;
                                            let _e348 = reflectedDir;
                                            let _e351 = reflectedDir;
                                            let _e354 = _o_ratio;
                                            if ((abs(_e339.y) > (abs(_e342.z) * _e345)) && (abs(_e348.y) > (abs(_e351.x) * _e354))) {
                                                {
                                                    let _e358 = _o_X;
                                                    let _e359 = reflectedDir;
                                                    let _e362 = reflectedDir;
                                                    _o_X = (_e358 + ((-(_e359.x) / _e362.y) * 0.5f));
                                                    let _e368 = _o_Y;
                                                    let _e369 = reflectedDir;
                                                    let _e372 = reflectedDir;
                                                    _o_Y = (_e368 + ((-(_e369.z) / _e372.y) * 0.5f));
                                                }
                                            } else {
                                                let _e378 = reflectedDir;
                                                let _e381 = reflectedDir;
                                                if (abs(_e378.x) < abs(_e381.z)) {
                                                    {
                                                        let _e385 = _o_X;
                                                        let _e386 = reflectedDir;
                                                        let _e388 = reflectedDir;
                                                        let _e392 = _o_ratio;
                                                        let _e396 = reflectedDir;
                                                        _o_X = (_e385 + ((((_e386.x / abs(_e388.z)) * _e392) * 0.5f) * -(sign(_e396.z))));
                                                        let _e402 = _o_Y;
                                                        let _e403 = reflectedDir;
                                                        let _e405 = reflectedDir;
                                                        _o_Y = (_e402 + ((_e403.y / abs(_e405.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e412 = _o_X;
                                                        let _e413 = reflectedDir;
                                                        let _e415 = reflectedDir;
                                                        let _e419 = _o_ratio;
                                                        let _e423 = reflectedDir;
                                                        _o_X = (_e412 + ((((_e413.z / abs(_e415.x)) * _e419) * 0.5f) * -(sign(_e423.x))));
                                                        let _e429 = _o_Y;
                                                        let _e430 = reflectedDir;
                                                        let _e432 = reflectedDir;
                                                        _o_Y = (_e429 + ((_e430.y / abs(_e432.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e439 = _o_X;
                                            let _e440 = _o_Y;
                                            let _e450 = global.U[0];
                                            let _e453 = _o_X;
                                            let _e454 = _o_Y;
                                            let _e470 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e439, _e440) * 2f) - vec2(1f)).x / _e450.x), ((vec2<f32>(_e453, _e454) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            _reflBkg = _e470;
                                        }
                                    } else {
                                        {
                                            let _e471 = reflectedDir;
                                            let _e476 = ((_e471 * 0.5f) + vec3(0.5f));
                                            _reflBkg = vec4<f32>(_e476.x, _e476.y, _e476.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e482 = _reflBkg;
                            let _e486 = objectColor_1;
                            let _e488 = (2f * _e486.xyz);
                            let _e494 = objectColor_1;
                            reflectedColor = (_e482 * mix(vec4(1f), vec4<f32>(_e488.x, _e488.y, _e488.z, 1f), vec4(_e494.w)));
                        }
                    }
                    let _e499 = dir_2;
                    let _e500 = normal;
                    let _e501 = eta;
                    dir_2 = refract(_e499, _e500, _e501);
                    let _e503 = intersection;
                    let _e504 = dir_2;
                    origin_2 = (_e503 + (_e504 * 0.001f));
                }
            }
            let _e508 = iter;
            iter = (_e508 - 1i);
        }
        let _e511 = minI;
        let _e514 = iter;
        if !(((_e511 >= 0i) && (_e514 > 0i))) {
            break;
        }
    }
    let _e521 = reflectivity_1;
    balance = (1f - (2f * _e521));
    let _e528 = backgroundStyle_1;
    if (_e528 == 0i) {
        {
            let _e531 = dir_2;
            _o_n_1 = normalize(_e531);
            let _e534 = _o_n_1;
            let _e536 = _o_n_1;
            _o_alpha_1 = atan2(_e534.z, _e536.x);
            let _e540 = _o_n_1;
            _o_beta_1 = asin(_e540.y);
            let _e544 = _o_alpha_1;
            let _e549 = _o_beta_1;
            _o_pos_2 = ((vec2<f32>((-(_e544) / 3.1415927f), ((2f * _e549) / 3.1415927f)) * 2f) - vec2<f32>(0f, 0f));
            let _e561 = _o_alpha_1;
            let _e568 = _o_beta_1;
            let _e576 = global.U[0];
            let _e579 = _o_alpha_1;
            let _e586 = _o_beta_1;
            let _e600 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e561) / 3.1415927f) * 2f), ((2f * _e568) / 3.1415927f)).x / _e576.x), vec2<f32>(((-(_e579) / 3.1415927f) * 2f), ((2f * _e586) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkg = _e600;
        }
    } else {
        let _e601 = backgroundStyle_1;
        if (_e601 == 1i) {
            {
                let _e604 = dir_2;
                let _e607 = dir_2;
                let _e610 = dir_2;
                let _e613 = dir_2;
                _o_pos_3 = vec2<f32>((-(_e604.x) / _e607.z), (-(_e610.y) / _e613.z));
                let _e618 = _o_pos_3;
                let _e621 = _o_pos_3;
                _o_m_1 = max(abs(_e618.x), abs(_e621.y));
                let _e628 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e628));
                let _e632 = _o_pos_3;
                let _e636 = global.U[0];
                let _e639 = _o_pos_3;
                let _e649 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e632.x / _e636.x), _e639.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e650 = _o_darken_1;
                let _e651 = _o_darken_1;
                let _e652 = _o_darken_1;
                _bkg = (_e649 * vec4<f32>(_e650, _e651, _e652, 1f));
            }
        } else {
            let _e656 = backgroundStyle_1;
            if (_e656 == 2i) {
                {
                    let _e659 = sourceDim_1;
                    let _e661 = sourceDim_1;
                    _o_ratio_1 = (_e659.y / _e661.x);
                    let _e669 = dir_2;
                    let _e672 = dir_2;
                    let _e675 = _o_ratio_1;
                    let _e678 = dir_2;
                    let _e681 = dir_2;
                    let _e684 = _o_ratio_1;
                    if ((abs(_e669.y) > (abs(_e672.z) * _e675)) && (abs(_e678.y) > (abs(_e681.x) * _e684))) {
                        {
                            let _e688 = _o_X_1;
                            let _e689 = dir_2;
                            let _e692 = dir_2;
                            _o_X_1 = (_e688 + ((-(_e689.x) / _e692.y) * 0.5f));
                            let _e698 = _o_Y_1;
                            let _e699 = dir_2;
                            let _e702 = dir_2;
                            _o_Y_1 = (_e698 + ((-(_e699.z) / _e702.y) * 0.5f));
                        }
                    } else {
                        let _e708 = dir_2;
                        let _e711 = dir_2;
                        if (abs(_e708.x) < abs(_e711.z)) {
                            {
                                let _e715 = _o_X_1;
                                let _e716 = dir_2;
                                let _e718 = dir_2;
                                let _e722 = _o_ratio_1;
                                let _e726 = dir_2;
                                _o_X_1 = (_e715 + ((((_e716.x / abs(_e718.z)) * _e722) * 0.5f) * -(sign(_e726.z))));
                                let _e732 = _o_Y_1;
                                let _e733 = dir_2;
                                let _e735 = dir_2;
                                _o_Y_1 = (_e732 + ((_e733.y / abs(_e735.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e742 = _o_X_1;
                                let _e743 = dir_2;
                                let _e745 = dir_2;
                                let _e749 = _o_ratio_1;
                                let _e753 = dir_2;
                                _o_X_1 = (_e742 + ((((_e743.z / abs(_e745.x)) * _e749) * 0.5f) * -(sign(_e753.x))));
                                let _e759 = _o_Y_1;
                                let _e760 = dir_2;
                                let _e762 = dir_2;
                                _o_Y_1 = (_e759 + ((_e760.y / abs(_e762.x)) * 0.5f));
                            }
                        }
                    }
                    let _e769 = _o_X_1;
                    let _e770 = _o_Y_1;
                    let _e780 = global.U[0];
                    let _e783 = _o_X_1;
                    let _e784 = _o_Y_1;
                    let _e800 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e769, _e770) * 2f) - vec2(1f)).x / _e780.x), ((vec2<f32>(_e783, _e784) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkg = _e800;
                }
            } else {
                {
                    let _e801 = dir_2;
                    let _e806 = ((_e801 * 0.5f) + vec3(0.5f));
                    _bkg = vec4<f32>(_e806.x, _e806.y, _e806.z, 1f);
                }
            }
        }
    }
    let _e812 = _bkg;
    let _e816 = bkgColor_1;
    let _e818 = (2f * _e816.xyz);
    let _e824 = bkgColor_1;
    let _e829 = glowColor_1;
    let _e833 = minDist;
    let _e837 = ((_e829.xyz * 0.2f) / vec3(pow(_e833, 1.5f)));
    let _e843 = glowColor_1;
    col = ((_e812 * mix(vec4(1f), vec4<f32>(_e818.x, _e818.y, _e818.z, 1f), vec4(_e824.w))) + (vec4<f32>(_e837.x, _e837.y, _e837.z, 0f) * _e843.w));
    let _e848 = reflectedColor;
    let _e849 = col;
    let _e850 = incidence;
    let _e851 = balance;
    return mix(_e848, _e849, vec4(clamp((_e850 + _e851), 0f, 1f)));
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
