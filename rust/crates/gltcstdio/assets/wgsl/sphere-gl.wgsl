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
                    let _e162 = textureSample(t_source, samp, ((vec2<f32>((_e146.x / _e150.x), _e153.y) / vec2(2f)) + vec2(0.5f)));
                    reflectedColor = _e162;
                }
            } else {
                let _e163 = backgroundStyle_1;
                if (_e163 == 1i) {
                    {
                        let _e166 = reflectedDir;
                        let _e169 = reflectedDir;
                        let _e172 = reflectedDir;
                        let _e175 = reflectedDir;
                        _o_pos_1 = vec2<f32>((-(_e166.x) / _e169.z), (-(_e172.y) / _e175.z));
                        let _e180 = _o_pos_1;
                        let _e183 = _o_pos_1;
                        _o_m = max(abs(_e180.x), abs(_e183.y));
                        let _e190 = _o_m;
                        _o_darken = (4f / max(4f, _e190));
                        let _e194 = _o_pos_1;
                        let _e198 = global.U[0];
                        let _e201 = _o_pos_1;
                        let _e210 = textureSample(t_source, samp, ((vec2<f32>((_e194.x / _e198.x), _e201.y) / vec2(2f)) + vec2(0.5f)));
                        let _e211 = _o_darken;
                        let _e212 = _o_darken;
                        let _e213 = _o_darken;
                        reflectedColor = (_e210 * vec4<f32>(_e211, _e212, _e213, 1f));
                    }
                } else {
                    let _e217 = backgroundStyle_1;
                    if (_e217 == 2i) {
                        {
                            let _e220 = sourceDim_1;
                            let _e222 = sourceDim_1;
                            _o_ratio = (_e220.y / _e222.x);
                            let _e230 = reflectedDir;
                            let _e233 = reflectedDir;
                            let _e236 = _o_ratio;
                            let _e239 = reflectedDir;
                            let _e242 = reflectedDir;
                            let _e245 = _o_ratio;
                            if ((abs(_e230.y) > (abs(_e233.z) * _e236)) && (abs(_e239.y) > (abs(_e242.x) * _e245))) {
                                {
                                    let _e249 = _o_X;
                                    let _e250 = reflectedDir;
                                    let _e253 = reflectedDir;
                                    _o_X = (_e249 + ((-(_e250.x) / _e253.y) * 0.5f));
                                    let _e259 = _o_Y;
                                    let _e260 = reflectedDir;
                                    let _e263 = reflectedDir;
                                    _o_Y = (_e259 + ((-(_e260.z) / _e263.y) * 0.5f));
                                }
                            } else {
                                let _e269 = reflectedDir;
                                let _e272 = reflectedDir;
                                if (abs(_e269.x) < abs(_e272.z)) {
                                    {
                                        let _e276 = _o_X;
                                        let _e277 = reflectedDir;
                                        let _e279 = reflectedDir;
                                        let _e283 = _o_ratio;
                                        let _e287 = reflectedDir;
                                        _o_X = (_e276 + ((((_e277.x / abs(_e279.z)) * _e283) * 0.5f) * -(sign(_e287.z))));
                                        let _e293 = _o_Y;
                                        let _e294 = reflectedDir;
                                        let _e296 = reflectedDir;
                                        _o_Y = (_e293 + ((_e294.y / abs(_e296.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e303 = _o_X;
                                        let _e304 = reflectedDir;
                                        let _e306 = reflectedDir;
                                        let _e310 = _o_ratio;
                                        let _e314 = reflectedDir;
                                        _o_X = (_e303 + ((((_e304.z / abs(_e306.x)) * _e310) * 0.5f) * -(sign(_e314.x))));
                                        let _e320 = _o_Y;
                                        let _e321 = reflectedDir;
                                        let _e323 = reflectedDir;
                                        _o_Y = (_e320 + ((_e321.y / abs(_e323.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e330 = _o_X;
                            let _e331 = _o_Y;
                            let _e341 = global.U[0];
                            let _e344 = _o_X;
                            let _e345 = _o_Y;
                            let _e360 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e330, _e331) * 2f) - vec2(1f)).x / _e341.x), ((vec2<f32>(_e344, _e345) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            reflectedColor = _e360;
                        }
                    } else {
                        {
                            let _e361 = reflectedDir;
                            let _e366 = ((_e361 * 0.5f) + vec3(0.5f));
                            reflectedColor = vec4<f32>(_e366.x, _e366.y, _e366.z, 1f);
                        }
                    }
                }
            }
            let _e374 = radius_2;
            let _e375 = intersection;
            let _e376 = refractedDir;
            let _e380 = refractedDir;
            let _e381 = sphereIntersection(vec3(0f), _e374, (_e375 + (_e376 * 0.00001f)), _e380);
            intersection2_ = _e381;
            let _e383 = intersection2_;
            if (_e383.x < 100000000f) {
                {
                    let _e387 = intersection2_;
                    normal = -(normalize(_e387));
                    let _e390 = refractedDir;
                    let _e391 = normal;
                    let _e392 = eta;
                    refractedDir = refract(_e390, _e391, _e392);
                }
            }
            let _e397 = backgroundStyle_1;
            if (_e397 == 0i) {
                {
                    let _e400 = refractedDir;
                    _o_n_1 = normalize(_e400);
                    let _e403 = _o_n_1;
                    let _e405 = _o_n_1;
                    _o_alpha_1 = atan2(_e403.z, _e405.x);
                    let _e409 = _o_n_1;
                    _o_beta_1 = asin(_e409.y);
                    let _e417 = _o_alpha_1;
                    let _e423 = _o_nX_1;
                    let _e426 = _o_nY_1;
                    let _e427 = _o_beta_1;
                    _o_pos_2 = ((vec2<f32>((((-(_e417) / 3.1415927f) * 0.5f) * _e423), (0.5f + ((_e426 * _e427) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e439 = _o_pos_2;
                    let _e443 = global.U[0];
                    let _e446 = _o_pos_2;
                    let _e455 = textureSample(t_source, samp, ((vec2<f32>((_e439.x / _e443.x), _e446.y) / vec2(2f)) + vec2(0.5f)));
                    refractedColor = _e455;
                }
            } else {
                let _e456 = backgroundStyle_1;
                if (_e456 == 1i) {
                    {
                        let _e459 = refractedDir;
                        let _e462 = refractedDir;
                        let _e465 = refractedDir;
                        let _e468 = refractedDir;
                        _o_pos_3 = vec2<f32>((-(_e459.x) / _e462.z), (-(_e465.y) / _e468.z));
                        let _e473 = _o_pos_3;
                        let _e476 = _o_pos_3;
                        _o_m_1 = max(abs(_e473.x), abs(_e476.y));
                        let _e483 = _o_m_1;
                        _o_darken_1 = (4f / max(4f, _e483));
                        let _e487 = _o_pos_3;
                        let _e491 = global.U[0];
                        let _e494 = _o_pos_3;
                        let _e503 = textureSample(t_source, samp, ((vec2<f32>((_e487.x / _e491.x), _e494.y) / vec2(2f)) + vec2(0.5f)));
                        let _e504 = _o_darken_1;
                        let _e505 = _o_darken_1;
                        let _e506 = _o_darken_1;
                        refractedColor = (_e503 * vec4<f32>(_e504, _e505, _e506, 1f));
                    }
                } else {
                    let _e510 = backgroundStyle_1;
                    if (_e510 == 2i) {
                        {
                            let _e513 = sourceDim_1;
                            let _e515 = sourceDim_1;
                            _o_ratio_1 = (_e513.y / _e515.x);
                            let _e523 = refractedDir;
                            let _e526 = refractedDir;
                            let _e529 = _o_ratio_1;
                            let _e532 = refractedDir;
                            let _e535 = refractedDir;
                            let _e538 = _o_ratio_1;
                            if ((abs(_e523.y) > (abs(_e526.z) * _e529)) && (abs(_e532.y) > (abs(_e535.x) * _e538))) {
                                {
                                    let _e542 = _o_X_1;
                                    let _e543 = refractedDir;
                                    let _e546 = refractedDir;
                                    _o_X_1 = (_e542 + ((-(_e543.x) / _e546.y) * 0.5f));
                                    let _e552 = _o_Y_1;
                                    let _e553 = refractedDir;
                                    let _e556 = refractedDir;
                                    _o_Y_1 = (_e552 + ((-(_e553.z) / _e556.y) * 0.5f));
                                }
                            } else {
                                let _e562 = refractedDir;
                                let _e565 = refractedDir;
                                if (abs(_e562.x) < abs(_e565.z)) {
                                    {
                                        let _e569 = _o_X_1;
                                        let _e570 = refractedDir;
                                        let _e572 = refractedDir;
                                        let _e576 = _o_ratio_1;
                                        let _e580 = refractedDir;
                                        _o_X_1 = (_e569 + ((((_e570.x / abs(_e572.z)) * _e576) * 0.5f) * -(sign(_e580.z))));
                                        let _e586 = _o_Y_1;
                                        let _e587 = refractedDir;
                                        let _e589 = refractedDir;
                                        _o_Y_1 = (_e586 + ((_e587.y / abs(_e589.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e596 = _o_X_1;
                                        let _e597 = refractedDir;
                                        let _e599 = refractedDir;
                                        let _e603 = _o_ratio_1;
                                        let _e607 = refractedDir;
                                        _o_X_1 = (_e596 + ((((_e597.z / abs(_e599.x)) * _e603) * 0.5f) * -(sign(_e607.x))));
                                        let _e613 = _o_Y_1;
                                        let _e614 = refractedDir;
                                        let _e616 = refractedDir;
                                        _o_Y_1 = (_e613 + ((_e614.y / abs(_e616.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e623 = _o_X_1;
                            let _e624 = _o_Y_1;
                            let _e634 = global.U[0];
                            let _e637 = _o_X_1;
                            let _e638 = _o_Y_1;
                            let _e653 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e623, _e624) * 2f) - vec2(1f)).x / _e634.x), ((vec2<f32>(_e637, _e638) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            refractedColor = _e653;
                        }
                    } else {
                        {
                            let _e654 = refractedDir;
                            let _e659 = ((_e654 * 0.5f) + vec3(0.5f));
                            refractedColor = vec4<f32>(_e659.x, _e659.y, _e659.z, 1f);
                        }
                    }
                }
            }
            let _e667 = reflectivity_1;
            balance = (1f - (2f * _e667));
            let _e671 = reflectedColor;
            let _e672 = refractedColor;
            let _e673 = incidence;
            let _e674 = balance;
            mixedCol = mix(_e671, _e672, vec4(clamp((_e673 + _e674), 0f, 1f)));
            let _e682 = mixedCol;
            let _e683 = mixedCol;
            let _e685 = objectColor_1;
            let _e687 = (2f * _e685.xyz);
            let _e694 = objectColor_1;
            mixedCol = mix(_e682, (_e683 * vec4<f32>(_e687.x, _e687.y, _e687.z, 1f)), vec4(_e694.w));
            let _e698 = mixedCol;
            return _e698;
        }
    } else {
        {
            let _e699 = dir_2;
            let _e700 = cameraPos;
            let _e703 = dir_2;
            let _e706 = radius_2;
            minDist = abs(((length(cross(_e699, _e700)) / length(_e703)) - _e706));
            let _e713 = backgroundStyle_1;
            if (_e713 == 0i) {
                {
                    let _e716 = dir_2;
                    _o_n_2 = normalize(_e716);
                    let _e719 = _o_n_2;
                    let _e721 = _o_n_2;
                    _o_alpha_2 = atan2(_e719.z, _e721.x);
                    let _e725 = _o_n_2;
                    _o_beta_2 = asin(_e725.y);
                    let _e733 = _o_alpha_2;
                    let _e739 = _o_nX_2;
                    let _e742 = _o_nY_2;
                    let _e743 = _o_beta_2;
                    _o_pos_4 = ((vec2<f32>((((-(_e733) / 3.1415927f) * 0.5f) * _e739), (0.5f + ((_e742 * _e743) / 3.1415927f))) * 2f) - vec2(1f));
                    let _e755 = _o_pos_4;
                    let _e759 = global.U[0];
                    let _e762 = _o_pos_4;
                    let _e771 = textureSample(t_source, samp, ((vec2<f32>((_e755.x / _e759.x), _e762.y) / vec2(2f)) + vec2(0.5f)));
                    bkg = _e771;
                }
            } else {
                let _e772 = backgroundStyle_1;
                if (_e772 == 1i) {
                    {
                        let _e775 = dir_2;
                        let _e778 = dir_2;
                        let _e781 = dir_2;
                        let _e784 = dir_2;
                        _o_pos_5 = vec2<f32>((-(_e775.x) / _e778.z), (-(_e781.y) / _e784.z));
                        let _e789 = _o_pos_5;
                        let _e792 = _o_pos_5;
                        _o_m_2 = max(abs(_e789.x), abs(_e792.y));
                        let _e799 = _o_m_2;
                        _o_darken_2 = (4f / max(4f, _e799));
                        let _e803 = _o_pos_5;
                        let _e807 = global.U[0];
                        let _e810 = _o_pos_5;
                        let _e819 = textureSample(t_source, samp, ((vec2<f32>((_e803.x / _e807.x), _e810.y) / vec2(2f)) + vec2(0.5f)));
                        let _e820 = _o_darken_2;
                        let _e821 = _o_darken_2;
                        let _e822 = _o_darken_2;
                        bkg = (_e819 * vec4<f32>(_e820, _e821, _e822, 1f));
                    }
                } else {
                    let _e826 = backgroundStyle_1;
                    if (_e826 == 2i) {
                        {
                            let _e829 = sourceDim_1;
                            let _e831 = sourceDim_1;
                            _o_ratio_2 = (_e829.y / _e831.x);
                            let _e839 = dir_2;
                            let _e842 = dir_2;
                            let _e845 = _o_ratio_2;
                            let _e848 = dir_2;
                            let _e851 = dir_2;
                            let _e854 = _o_ratio_2;
                            if ((abs(_e839.y) > (abs(_e842.z) * _e845)) && (abs(_e848.y) > (abs(_e851.x) * _e854))) {
                                {
                                    let _e858 = _o_X_2;
                                    let _e859 = dir_2;
                                    let _e862 = dir_2;
                                    _o_X_2 = (_e858 + ((-(_e859.x) / _e862.y) * 0.5f));
                                    let _e868 = _o_Y_2;
                                    let _e869 = dir_2;
                                    let _e872 = dir_2;
                                    _o_Y_2 = (_e868 + ((-(_e869.z) / _e872.y) * 0.5f));
                                }
                            } else {
                                let _e878 = dir_2;
                                let _e881 = dir_2;
                                if (abs(_e878.x) < abs(_e881.z)) {
                                    {
                                        let _e885 = _o_X_2;
                                        let _e886 = dir_2;
                                        let _e888 = dir_2;
                                        let _e892 = _o_ratio_2;
                                        let _e896 = dir_2;
                                        _o_X_2 = (_e885 + ((((_e886.x / abs(_e888.z)) * _e892) * 0.5f) * -(sign(_e896.z))));
                                        let _e902 = _o_Y_2;
                                        let _e903 = dir_2;
                                        let _e905 = dir_2;
                                        _o_Y_2 = (_e902 + ((_e903.y / abs(_e905.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e912 = _o_X_2;
                                        let _e913 = dir_2;
                                        let _e915 = dir_2;
                                        let _e919 = _o_ratio_2;
                                        let _e923 = dir_2;
                                        _o_X_2 = (_e912 + ((((_e913.z / abs(_e915.x)) * _e919) * 0.5f) * -(sign(_e923.x))));
                                        let _e929 = _o_Y_2;
                                        let _e930 = dir_2;
                                        let _e932 = dir_2;
                                        _o_Y_2 = (_e929 + ((_e930.y / abs(_e932.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e939 = _o_X_2;
                            let _e940 = _o_Y_2;
                            let _e950 = global.U[0];
                            let _e953 = _o_X_2;
                            let _e954 = _o_Y_2;
                            let _e969 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e939, _e940) * 2f) - vec2(1f)).x / _e950.x), ((vec2<f32>(_e953, _e954) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                            bkg = _e969;
                        }
                    } else {
                        {
                            let _e970 = dir_2;
                            let _e975 = ((_e970 * 0.5f) + vec3(0.5f));
                            bkg = vec4<f32>(_e975.x, _e975.y, _e975.z, 1f);
                        }
                    }
                }
            }
            let _e981 = bkg;
            let _e985 = bkgColor_1;
            let _e987 = (2f * _e985.xyz);
            let _e993 = bkgColor_1;
            let _e998 = glowColor_1;
            let _e1002 = minDist;
            let _e1003 = minDist;
            let _e1009 = ((_e998.xyz * 0.2f) / vec3(pow(_e1002, clamp(_e1003, 1f, 3f))));
            let _e1015 = glowColor_1;
            return ((_e981 * mix(vec4(1f), vec4<f32>(_e987.x, _e987.y, _e987.z, 1f), vec4(_e993.w))) + (vec4<f32>(_e1009.x, _e1009.y, _e1009.z, 0f) * _e1015.w));
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
