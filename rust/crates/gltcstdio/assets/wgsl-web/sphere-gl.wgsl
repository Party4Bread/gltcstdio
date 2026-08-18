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

fn sphereIntersection(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
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
    let _e14 = origin_1;
    let _e15 = center_1;
    relOrigin = (_e14 - _e15);
    let _e18 = dir_1;
    let _e19 = dir_1;
    a = dot(_e18, _e19);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_1;
    let _e32 = radius_1;
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a;
    let _e42 = c;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b;
            let _e54 = sqrtDelta;
            let _e57 = a;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b;
            let _e63 = sqrtDelta;
            let _e66 = a;
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
                    let _e88 = origin_1;
                    let _e89 = l;
                    let _e90 = dir_1;
                    return (_e88 + (_e89 * _e90));
                }
            }
        }
    }
    return vec3(100000000000000000000f);
}

fn sphereGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity: f32, reflectivity: f32, objectColor: vec4<f32>, glowColor: vec4<f32>, bkgColor: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
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
    var radius_2: f32 = 0.5f;
    var intersection: vec3<f32>;
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
    let _e72 = sphereIntersection(vec3(0f), _e69, _e70, _e71);
    intersection = _e72;
    let _e74 = intersection;
    if (_e74.x < 100000000f) {
        {
            let _e78 = intersection;
            normal = normalize(_e78);
            let _e83 = intensity_1;
            eta = (1f - (2f * _e83));
            let _e87 = normal;
            let _e88 = dir_2;
            incidence = abs(dot(_e87, _e88));
            let _e92 = dir_2;
            let _e93 = normal;
            let _e94 = eta;
            refractedDir = refract(_e92, _e93, _e94);
            let _e97 = dir_2;
            let _e98 = normal;
            reflectedDir = reflect(_e97, _e98);
            let _e104 = backgroundStyle_1;
            if (_e104 == 0i) {
                {
                    let _e107 = reflectedDir;
                    _o_n = normalize(_e107);
                    let _e110 = _o_n;
                    let _e112 = _o_n;
                    _o_alpha = atan2(_e110.z, _e112.x);
                    let _e116 = _o_n;
                    _o_beta = asin(_e116.y);
                    let _e124 = _o_alpha;
                    let _e130 = _o_nX;
                    let _e133 = _o_nY;
                    let _e134 = _o_beta;
                    _o_pos = ((vec2<f32>((((-(_e124) / 3.1415927f) * 0.5f) * _e130), (0.5f + ((_e133 * _e134) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e146 = _o_pos;
                    let _e150 = global.U[0];
                    let _e153 = _o_pos;
                    let _e163 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e146.x / _e150.x), _e153.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    reflectedColor = _e163;
                }
            } else {
                let _e164 = backgroundStyle_1;
                if (_e164 == 1i) {
                    {
                        let _e167 = reflectedDir;
                        let _e170 = reflectedDir;
                        let _e173 = reflectedDir;
                        let _e176 = reflectedDir;
                        _o_pos_1 = vec2<f32>((-(_e167.x) / _e170.z), (-(_e173.y) / _e176.z));
                        let _e181 = _o_pos_1;
                        let _e184 = _o_pos_1;
                        _o_m = max(abs(_e181.x), abs(_e184.y));
                        let _e191 = _o_m;
                        _o_darken = (4f / max(4f, _e191));
                        let _e195 = _o_pos_1;
                        let _e199 = global.U[0];
                        let _e202 = _o_pos_1;
                        let _e212 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e195.x / _e199.x), _e202.y) / vec2(2f)) + vec2(0.5f)), 0f);
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
                            let _e363 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e332, _e333) * 2f) - vec2(1f)).x / _e343.x), ((vec2<f32>(_e346, _e347) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            reflectedColor = _e363;
                        }
                    } else {
                        {
                            let _e364 = reflectedDir;
                            let _e369 = ((_e364 * 0.5f) + vec3(0.5f));
                            reflectedColor = vec4<f32>(_e369.x, _e369.y, _e369.z, 1f);
                        }
                    }
                }
            }
            let _e377 = radius_2;
            let _e378 = intersection;
            let _e379 = refractedDir;
            let _e383 = refractedDir;
            let _e384 = sphereIntersection(vec3(0f), _e377, (_e378 + (_e379 * 0.00001f)), _e383);
            intersection2_ = _e384;
            let _e386 = intersection2_;
            if (_e386.x < 100000000f) {
                {
                    let _e390 = intersection2_;
                    normal = -(normalize(_e390));
                    let _e393 = refractedDir;
                    let _e394 = normal;
                    let _e395 = eta;
                    refractedDir = refract(_e393, _e394, _e395);
                }
            }
            let _e400 = backgroundStyle_1;
            if (_e400 == 0i) {
                {
                    let _e403 = refractedDir;
                    _o_n_1 = normalize(_e403);
                    let _e406 = _o_n_1;
                    let _e408 = _o_n_1;
                    _o_alpha_1 = atan2(_e406.z, _e408.x);
                    let _e412 = _o_n_1;
                    _o_beta_1 = asin(_e412.y);
                    let _e420 = _o_alpha_1;
                    let _e426 = _o_nX_1;
                    let _e429 = _o_nY_1;
                    let _e430 = _o_beta_1;
                    _o_pos_2 = ((vec2<f32>((((-(_e420) / 3.1415927f) * 0.5f) * _e426), (0.5f + ((_e429 * _e430) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e442 = _o_pos_2;
                    let _e446 = global.U[0];
                    let _e449 = _o_pos_2;
                    let _e459 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e442.x / _e446.x), _e449.y) / vec2(2f)) + vec2(0.5f)), 0f);
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
                        let _e508 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e491.x / _e495.x), _e498.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e509 = _o_darken_1;
                        let _e510 = _o_darken_1;
                        let _e511 = _o_darken_1;
                        refractedColor = (_e508 * vec4<f32>(_e509, _e510, _e511, 1f));
                    }
                } else {
                    let _e515 = backgroundStyle_1;
                    if (_e515 == 2i) {
                        {
                            let _e518 = sourceDim_1;
                            let _e520 = sourceDim_1;
                            _o_ratio_1 = (_e518.y / _e520.x);
                            let _e528 = refractedDir;
                            let _e531 = refractedDir;
                            let _e534 = _o_ratio_1;
                            let _e537 = refractedDir;
                            let _e540 = refractedDir;
                            let _e543 = _o_ratio_1;
                            if ((abs(_e528.y) > (abs(_e531.z) * _e534)) && (abs(_e537.y) > (abs(_e540.x) * _e543))) {
                                {
                                    let _e547 = _o_X_1;
                                    let _e548 = refractedDir;
                                    let _e551 = refractedDir;
                                    _o_X_1 = (_e547 + ((-(_e548.x) / _e551.y) * 0.5f));
                                    let _e557 = _o_Y_1;
                                    let _e558 = refractedDir;
                                    let _e561 = refractedDir;
                                    _o_Y_1 = (_e557 + ((-(_e558.z) / _e561.y) * 0.5f));
                                }
                            } else {
                                let _e567 = refractedDir;
                                let _e570 = refractedDir;
                                if (abs(_e567.x) < abs(_e570.z)) {
                                    {
                                        let _e574 = _o_X_1;
                                        let _e575 = refractedDir;
                                        let _e577 = refractedDir;
                                        let _e581 = _o_ratio_1;
                                        let _e585 = refractedDir;
                                        _o_X_1 = (_e574 + ((((_e575.x / abs(_e577.z)) * _e581) * 0.5f) * -(sign(_e585.z))));
                                        let _e591 = _o_Y_1;
                                        let _e592 = refractedDir;
                                        let _e594 = refractedDir;
                                        _o_Y_1 = (_e591 + ((_e592.y / abs(_e594.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e601 = _o_X_1;
                                        let _e602 = refractedDir;
                                        let _e604 = refractedDir;
                                        let _e608 = _o_ratio_1;
                                        let _e612 = refractedDir;
                                        _o_X_1 = (_e601 + ((((_e602.z / abs(_e604.x)) * _e608) * 0.5f) * -(sign(_e612.x))));
                                        let _e618 = _o_Y_1;
                                        let _e619 = refractedDir;
                                        let _e621 = refractedDir;
                                        _o_Y_1 = (_e618 + ((_e619.y / abs(_e621.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e628 = _o_X_1;
                            let _e629 = _o_Y_1;
                            let _e639 = global.U[0];
                            let _e642 = _o_X_1;
                            let _e643 = _o_Y_1;
                            let _e659 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e628, _e629) * 2f) - vec2(1f)).x / _e639.x), ((vec2<f32>(_e642, _e643) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            refractedColor = _e659;
                        }
                    } else {
                        {
                            let _e660 = refractedDir;
                            let _e665 = ((_e660 * 0.5f) + vec3(0.5f));
                            refractedColor = vec4<f32>(_e665.x, _e665.y, _e665.z, 1f);
                        }
                    }
                }
            }
            let _e673 = reflectivity_1;
            balance = (1f - (2f * _e673));
            let _e677 = reflectedColor;
            let _e678 = refractedColor;
            let _e679 = incidence;
            let _e680 = balance;
            mixedCol = mix(_e677, _e678, vec4(clamp((_e679 + _e680), 0f, 1f)));
            let _e688 = mixedCol;
            let _e689 = mixedCol;
            let _e691 = objectColor_1;
            let _e693 = (2f * _e691.xyz);
            let _e700 = objectColor_1;
            mixedCol = mix(_e688, (_e689 * vec4<f32>(_e693.x, _e693.y, _e693.z, 1f)), vec4(_e700.w));
            let _e704 = mixedCol;
            return _e704;
        }
    } else {
        {
            let _e705 = dir_2;
            let _e706 = cameraPos;
            let _e709 = dir_2;
            let _e712 = radius_2;
            minDist = abs(((length(cross(_e705, _e706)) / length(_e709)) - _e712));
            let _e719 = backgroundStyle_1;
            if (_e719 == 0i) {
                {
                    let _e722 = dir_2;
                    _o_n_2 = normalize(_e722);
                    let _e725 = _o_n_2;
                    let _e727 = _o_n_2;
                    _o_alpha_2 = atan2(_e725.z, _e727.x);
                    let _e731 = _o_n_2;
                    _o_beta_2 = asin(_e731.y);
                    let _e739 = _o_alpha_2;
                    let _e745 = _o_nX_2;
                    let _e748 = _o_nY_2;
                    let _e749 = _o_beta_2;
                    _o_pos_4 = ((vec2<f32>((((-(_e739) / 3.1415927f) * 0.5f) * _e745), (0.5f + ((_e748 * _e749) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e761 = _o_pos_4;
                    let _e765 = global.U[0];
                    let _e768 = _o_pos_4;
                    let _e778 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e761.x / _e765.x), _e768.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    bkg = _e778;
                }
            } else {
                let _e779 = backgroundStyle_1;
                if (_e779 == 1i) {
                    {
                        let _e782 = dir_2;
                        let _e785 = dir_2;
                        let _e788 = dir_2;
                        let _e791 = dir_2;
                        _o_pos_5 = vec2<f32>((-(_e782.x) / _e785.z), (-(_e788.y) / _e791.z));
                        let _e796 = _o_pos_5;
                        let _e799 = _o_pos_5;
                        _o_m_2 = max(abs(_e796.x), abs(_e799.y));
                        let _e806 = _o_m_2;
                        _o_darken_2 = (4f / max(4f, _e806));
                        let _e810 = _o_pos_5;
                        let _e814 = global.U[0];
                        let _e817 = _o_pos_5;
                        let _e827 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e810.x / _e814.x), _e817.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e828 = _o_darken_2;
                        let _e829 = _o_darken_2;
                        let _e830 = _o_darken_2;
                        bkg = (_e827 * vec4<f32>(_e828, _e829, _e830, 1f));
                    }
                } else {
                    let _e834 = backgroundStyle_1;
                    if (_e834 == 2i) {
                        {
                            let _e837 = sourceDim_1;
                            let _e839 = sourceDim_1;
                            _o_ratio_2 = (_e837.y / _e839.x);
                            let _e847 = dir_2;
                            let _e850 = dir_2;
                            let _e853 = _o_ratio_2;
                            let _e856 = dir_2;
                            let _e859 = dir_2;
                            let _e862 = _o_ratio_2;
                            if ((abs(_e847.y) > (abs(_e850.z) * _e853)) && (abs(_e856.y) > (abs(_e859.x) * _e862))) {
                                {
                                    let _e866 = _o_X_2;
                                    let _e867 = dir_2;
                                    let _e870 = dir_2;
                                    _o_X_2 = (_e866 + ((-(_e867.x) / _e870.y) * 0.5f));
                                    let _e876 = _o_Y_2;
                                    let _e877 = dir_2;
                                    let _e880 = dir_2;
                                    _o_Y_2 = (_e876 + ((-(_e877.z) / _e880.y) * 0.5f));
                                }
                            } else {
                                let _e886 = dir_2;
                                let _e889 = dir_2;
                                if (abs(_e886.x) < abs(_e889.z)) {
                                    {
                                        let _e893 = _o_X_2;
                                        let _e894 = dir_2;
                                        let _e896 = dir_2;
                                        let _e900 = _o_ratio_2;
                                        let _e904 = dir_2;
                                        _o_X_2 = (_e893 + ((((_e894.x / abs(_e896.z)) * _e900) * 0.5f) * -(sign(_e904.z))));
                                        let _e910 = _o_Y_2;
                                        let _e911 = dir_2;
                                        let _e913 = dir_2;
                                        _o_Y_2 = (_e910 + ((_e911.y / abs(_e913.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e920 = _o_X_2;
                                        let _e921 = dir_2;
                                        let _e923 = dir_2;
                                        let _e927 = _o_ratio_2;
                                        let _e931 = dir_2;
                                        _o_X_2 = (_e920 + ((((_e921.z / abs(_e923.x)) * _e927) * 0.5f) * -(sign(_e931.x))));
                                        let _e937 = _o_Y_2;
                                        let _e938 = dir_2;
                                        let _e940 = dir_2;
                                        _o_Y_2 = (_e937 + ((_e938.y / abs(_e940.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e947 = _o_X_2;
                            let _e948 = _o_Y_2;
                            let _e958 = global.U[0];
                            let _e961 = _o_X_2;
                            let _e962 = _o_Y_2;
                            let _e978 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e947, _e948) * 2f) - vec2(1f)).x / _e958.x), ((vec2<f32>(_e961, _e962) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            bkg = _e978;
                        }
                    } else {
                        {
                            let _e979 = dir_2;
                            let _e984 = ((_e979 * 0.5f) + vec3(0.5f));
                            bkg = vec4<f32>(_e984.x, _e984.y, _e984.z, 1f);
                        }
                    }
                }
            }
            let _e990 = bkg;
            let _e994 = bkgColor_1;
            let _e996 = (2f * _e994.xyz);
            let _e1002 = bkgColor_1;
            let _e1007 = glowColor_1;
            let _e1011 = minDist;
            let _e1012 = minDist;
            let _e1018 = ((_e1007.xyz * 0.2f) / vec3(pow(_e1011, clamp(_e1012, 1f, 3f))));
            let _e1024 = glowColor_1;
            return ((_e990 * mix(vec4(1f), vec4<f32>(_e996.x, _e996.y, _e996.z, 1f), vec4(_e1002.w))) + (vec4<f32>(_e1018.x, _e1018.y, _e1018.z, 0f) * _e1024.w));
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
    let _e123 = sphereGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111, _e114, _e117, i32(_e120.x));
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
