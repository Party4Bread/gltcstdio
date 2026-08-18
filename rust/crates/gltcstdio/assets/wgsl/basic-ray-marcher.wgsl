struct Params {
    U: array<vec4<f32>, 23>,
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
@group(0) @binding(3) 
var t_legacy_1_: texture_2d<f32>;

fn getRay(uv: vec2<f32>, camera: vec3<f32>, target_: vec3<f32>, focalDist: f32) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var camera_1: vec3<f32>;
    var target_1: vec3<f32>;
    var focalDist_1: f32;
    var camZ: vec3<f32>;
    var camX: vec3<f32>;
    var camY: vec3<f32>;

    uv_1 = uv;
    camera_1 = camera;
    target_1 = target_;
    focalDist_1 = focalDist;
    let _e15 = target_1;
    let _e16 = camera_1;
    camZ = normalize((_e15 - _e16));
    let _e24 = camZ;
    camX = normalize(cross(vec3<f32>(0f, 1f, 0f), _e24));
    let _e28 = camZ;
    let _e29 = camX;
    camY = cross(_e28, _e29);
    let _e32 = camZ;
    let _e33 = focalDist_1;
    let _e35 = uv_1;
    let _e37 = camX;
    let _e40 = uv_1;
    let _e42 = camY;
    return normalize((((_e32 * _e33) + (_e35.x * _e37)) + (_e40.y * _e42)));
}

fn sdf(p: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;
    var ang: f32;
    var ca: f32;
    var sa: f32;
    var rot: mat2x2<f32>;
    var q: vec2<f32>;
    var c1_: vec2<f32> = vec2<f32>(0.15f, 0f);
    var d: vec2<f32>;

    p_1 = p;
    let _e11 = R;
    r = (_e11 * 0.2f);
    let _e15 = p_1;
    let _e17 = p_1;
    let _e20 = p_1;
    let _e22 = p_1;
    let _e27 = R;
    a = (sqrt(((_e15.x * _e17.x) + (_e20.y * _e22.y))) - _e27);
    let _e30 = p_1;
    let _e32 = p_1;
    ang = ((atan2(_e30.y, _e32.x) * 0.5f) * 5f);
    let _e42 = ang;
    ca = cos(_e42);
    let _e45 = ang;
    sa = sin(_e45);
    let _e48 = ca;
    let _e49 = sa;
    let _e50 = sa;
    let _e51 = ca;
    rot = mat2x2<f32>(vec2<f32>(_e48, _e49), vec2<f32>(_e50, -(_e51)));
    let _e57 = rot;
    let _e58 = a;
    let _e59 = p_1;
    q = (_e57 * vec2<f32>(_e58, _e59.z));
    let _e64 = q;
    if (_e64.x < 0f) {
        let _e68 = q;
        q = -(_e68);
    }
    let _e74 = q;
    let _e75 = c1_;
    let _e78 = r;
    d = (abs((_e74 - _e75)) - vec2(_e78));
    let _e83 = d;
    let _e88 = d;
    let _e90 = d;
    return (0.4f * (length(max(_e83, vec2(0f))) + min(max(_e88.x, _e90.y), 0f)));
}

fn normal(p_2: vec3<f32>) -> vec3<f32> {
    var p_3: vec3<f32>;
    var d_1: f32 = 0.0001f;
    var d2_: f32;

    p_3 = p_2;
    let _e11 = d_1;
    d2_ = (_e11 * 2f);
    let _e15 = p_3;
    let _e17 = d_1;
    let _e19 = p_3;
    let _e21 = p_3;
    let _e24 = sdf(vec3<f32>((_e15.x + _e17), _e19.y, _e21.z));
    let _e25 = p_3;
    let _e27 = d_1;
    let _e29 = p_3;
    let _e31 = p_3;
    let _e34 = sdf(vec3<f32>((_e25.x - _e27), _e29.y, _e31.z));
    let _e36 = d2_;
    let _e38 = p_3;
    let _e40 = p_3;
    let _e42 = d_1;
    let _e44 = p_3;
    let _e47 = sdf(vec3<f32>(_e38.x, (_e40.y + _e42), _e44.z));
    let _e48 = p_3;
    let _e50 = p_3;
    let _e52 = d_1;
    let _e54 = p_3;
    let _e57 = sdf(vec3<f32>(_e48.x, (_e50.y - _e52), _e54.z));
    let _e59 = d2_;
    let _e61 = p_3;
    let _e63 = p_3;
    let _e65 = p_3;
    let _e67 = d_1;
    let _e70 = sdf(vec3<f32>(_e61.x, _e63.y, (_e65.z + _e67)));
    let _e71 = p_3;
    let _e73 = p_3;
    let _e75 = p_3;
    let _e77 = d_1;
    let _e80 = sdf(vec3<f32>(_e71.x, _e73.y, (_e75.z - _e77)));
    let _e82 = d2_;
    return normalize(vec3<f32>(((_e24 - _e34) / _e36), ((_e47 - _e57) / _e59), ((_e70 - _e80) / _e82)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var d_2: f32;
    var s: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_4: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    let _e11 = p0_1;
    let _e12 = sdf(_e11);
    d_2 = _e12;
    let _e14 = d_2;
    s = sign(_e14);
    loop {
        let _e21 = step;
        let _e24 = d_2;
        if !(((_e21 < 1000i) && (_e24 < 100f))) {
            break;
        }
        {
            let _e29 = totalD;
            let _e30 = d_2;
            totalD = (_e29 + (abs(_e30) * 1f));
            let _e35 = p0_1;
            let _e36 = totalD;
            let _e37 = dir_1;
            p_4 = (_e35 + (_e36 * _e37));
            let _e41 = p_4;
            let _e42 = sdf(_e41);
            d_2 = _e42;
            let _e43 = d_2;
            if (abs(_e43) < 0.0001f) {
                let _e47 = p_4;
                return _e47;
            }
            let _e48 = step;
            step = (_e48 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn basicRayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, colorScheme: f32, colorTransmission: vec4<f32>, refractionIndex: f32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, shadows: f32, backgroundStyle: i32) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var colorScheme_1: f32;
    var colorTransmission_1: vec4<f32>;
    var refractionIndex_1: f32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var specular_1: f32;
    var shadows_1: f32;
    var backgroundStyle_1: i32;
    var D: f32 = 2f;
    var camera_2: vec3<f32>;
    var target_2: vec3<f32> = vec3(0f);
    var camDir: vec3<f32>;
    var col: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var color: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var q_1: vec3<f32>;
    var reflectDir: vec3<f32>;
    var reflectK: vec3<f32> = vec3(1f);
    var n: vec3<f32>;
    var incidence: f32;
    var refractDir: vec3<f32>;
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_ratio: f32;
    var _o_nX: f32 = 2f;
    var _o_nY: f32 = 1f;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio_1: f32;
    var _o_X: f32 = 0.5f;
    var _o_Y: f32 = 0.5f;
    var _o_n_1: vec3<f32>;
    var _o_alpha_1: f32;
    var _o_beta_1: f32;
    var _o_ratio_2: f32;
    var _o_nX_1: f32 = 2f;
    var _o_nY_1: f32 = 1f;
    var _o_pos_1: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_3: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;

    uv_3 = uv_2;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    lightSourceTransform_1 = lightSourceTransform;
    colorScheme_1 = colorScheme;
    colorTransmission_1 = colorTransmission;
    refractionIndex_1 = refractionIndex;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    specular_1 = specular;
    shadows_1 = shadows;
    backgroundStyle_1 = backgroundStyle;
    let _e37 = D;
    camera_2 = vec3<f32>(0f, 0f, _e37);
    let _e40 = model3DTransform_1;
    let _e41 = camera_2;
    camera_2 = (_e40 * vec4<f32>(_e41.x, _e41.y, _e41.z, 1f)).xyz;
    let _e52 = uv_3;
    let _e53 = camera_2;
    let _e54 = target_2;
    let _e56 = getRay(_e52, _e53, _e54, 1f);
    camDir = _e56;
    let _e70 = camera_2;
    let _e71 = camDir;
    let _e72 = rayMarch(_e70, _e71);
    q_1 = _e72;
    let _e74 = camDir;
    reflectDir = _e74;
    let _e79 = q_1;
    if (_e79.x != 100000000000000000000f) {
        {
            let _e83 = q_1;
            let _e84 = normal(_e83);
            n = _e84;
            let _e86 = n;
            let _e87 = camDir;
            incidence = abs(dot(_e86, _e87));
            let _e91 = camDir;
            let _e92 = n;
            reflectDir = reflect(_e91, _e92);
            let _e96 = colorTransmission_1;
            reflectK = (vec3(1f) - _e96.xyz);
            let _e99 = colorTransmission_1;
            if (length(_e99.xyz) != 0f) {
                {
                    let _e104 = camDir;
                    let _e105 = n;
                    let _e106 = refractionIndex_1;
                    refractDir = refract(_e104, _e105, _e106);
                    let _e109 = q_1;
                    let _e110 = n;
                    let _e114 = refractDir;
                    let _e115 = rayMarch((_e109 - (_e110 * 0.001f)), _e114);
                    q_1 = _e115;
                    let _e116 = q_1;
                    if (_e116.x != 100000000000000000000f) {
                        {
                            let _e120 = q_1;
                            let _e121 = normal(_e120);
                            n = _e121;
                            let _e122 = refractDir;
                            let _e123 = n;
                            let _e126 = refractionIndex_1;
                            refractDir = refract(_e122, -(_e123), (1f / _e126));
                            let _e129 = backgroundStyle_1;
                            if (_e129 == 0i) {
                                {
                                    let _e132 = refractDir;
                                    _o_n = normalize(_e132);
                                    let _e135 = _o_n;
                                    let _e137 = _o_n;
                                    _o_alpha = atan2(_e135.z, _e137.x);
                                    let _e141 = _o_n;
                                    _o_beta = asin(_e141.y);
                                    let _e145 = sourceDim_1;
                                    let _e147 = sourceDim_1;
                                    _o_ratio = (_e145.x / _e147.y);
                                    let _e155 = _o_alpha;
                                    let _e161 = _o_nX;
                                    let _e164 = _o_nY;
                                    let _e165 = _o_beta;
                                    let _e174 = global.U[0];
                                    let _e177 = _o_alpha;
                                    let _e183 = _o_nX;
                                    let _e186 = _o_nY;
                                    let _e187 = _o_beta;
                                    let _e201 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e155) / 3.1415927f) * 0.5f) * _e161), (0.5f + ((_e164 * _e165) / 3.1415927f))).x / _e174.x), vec2<f32>((((-(_e177) / 3.1415927f) * 0.5f) * _e183), (0.5f + ((_e186 * _e187) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e201;
                                }
                            } else {
                                let _e202 = backgroundStyle_1;
                                if (_e202 == 1i) {
                                    {
                                        let _e205 = refractDir;
                                        let _e208 = refractDir;
                                        let _e211 = sourceDim_1;
                                        let _e214 = sourceDim_1;
                                        let _e217 = refractDir;
                                        let _e220 = refractDir;
                                        _o_pos = (vec2<f32>((((-(_e205.x) / _e208.z) * _e211.y) / _e214.x), (-(_e217.y) / _e220.z)) * 0.5f);
                                        let _e227 = _o_pos;
                                        let _e230 = _o_pos;
                                        _o_m = max(abs(_e227.x), abs(_e230.y));
                                        let _e237 = _o_m;
                                        _o_darken = (4f / max(4f, _e237));
                                        let _e241 = _o_pos;
                                        let _e245 = global.U[0];
                                        let _e248 = _o_pos;
                                        let _e257 = textureSample(t_source, samp, ((vec2<f32>((_e241.x / _e245.x), _e248.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e258 = _o_darken;
                                        let _e259 = _o_darken;
                                        let _e260 = _o_darken;
                                        col = (_e257 * vec4<f32>(_e258, _e259, _e260, 1f));
                                    }
                                } else {
                                    let _e264 = backgroundStyle_1;
                                    if (_e264 == 2i) {
                                        {
                                            let _e267 = sourceDim_1;
                                            let _e269 = sourceDim_1;
                                            _o_ratio_1 = (_e267.y / _e269.x);
                                            let _e277 = refractDir;
                                            let _e280 = refractDir;
                                            let _e283 = _o_ratio_1;
                                            let _e286 = refractDir;
                                            let _e289 = refractDir;
                                            let _e292 = _o_ratio_1;
                                            if ((abs(_e277.y) > (abs(_e280.z) * _e283)) && (abs(_e286.y) > (abs(_e289.x) * _e292))) {
                                                {
                                                    let _e296 = _o_X;
                                                    let _e297 = refractDir;
                                                    let _e300 = refractDir;
                                                    _o_X = (_e296 + ((-(_e297.x) / _e300.y) * 0.5f));
                                                    let _e306 = _o_Y;
                                                    let _e307 = refractDir;
                                                    let _e310 = refractDir;
                                                    _o_Y = (_e306 + ((-(_e307.z) / _e310.y) * 0.5f));
                                                }
                                            } else {
                                                let _e316 = refractDir;
                                                let _e319 = refractDir;
                                                if (abs(_e316.x) < abs(_e319.z)) {
                                                    {
                                                        let _e323 = _o_X;
                                                        let _e324 = refractDir;
                                                        let _e326 = refractDir;
                                                        let _e330 = _o_ratio_1;
                                                        let _e334 = refractDir;
                                                        _o_X = (_e323 + ((((_e324.x / abs(_e326.z)) * _e330) * 0.5f) * -(sign(_e334.z))));
                                                        let _e340 = _o_Y;
                                                        let _e341 = refractDir;
                                                        let _e343 = refractDir;
                                                        _o_Y = (_e340 + ((_e341.y / abs(_e343.z)) * 0.5f));
                                                    }
                                                } else {
                                                    {
                                                        let _e350 = _o_X;
                                                        let _e351 = refractDir;
                                                        let _e353 = refractDir;
                                                        let _e357 = _o_ratio_1;
                                                        let _e361 = refractDir;
                                                        _o_X = (_e350 + ((((_e351.z / abs(_e353.x)) * _e357) * 0.5f) * -(sign(_e361.x))));
                                                        let _e367 = _o_Y;
                                                        let _e368 = refractDir;
                                                        let _e370 = refractDir;
                                                        _o_Y = (_e367 + ((_e368.y / abs(_e370.x)) * 0.5f));
                                                    }
                                                }
                                            }
                                            let _e377 = _o_X;
                                            let _e378 = _o_Y;
                                            let _e383 = global.U[0];
                                            let _e386 = _o_X;
                                            let _e387 = _o_Y;
                                            let _e397 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e377, _e378).x / _e383.x), vec2<f32>(_e386, _e387).y) / vec2(2f)) + vec2(0.5f)));
                                            col = _e397;
                                        }
                                    } else {
                                        {
                                            let _e398 = refractDir;
                                            let _e403 = ((_e398 * 0.5f) + vec3(0.5f));
                                            col = vec4<f32>(_e403.x, _e403.y, _e403.z, 1f);
                                        }
                                    }
                                }
                            }
                            let _e409 = color;
                            let _e411 = color;
                            let _e413 = colorTransmission_1;
                            let _e415 = col;
                            let _e418 = (_e411.xyz + (_e413.xyz * _e415.xyz));
                            color.x = _e418.x;
                            color.y = _e418.y;
                            color.z = _e418.z;
                        }
                    } else {
                        {
                            let _e425 = color;
                            color.x = 1f;
                            color.y = 0f;
                            color.z = 0f;
                        }
                    }
                }
            }
        }
    }
    let _e434 = backgroundStyle_1;
    if (_e434 == 0i) {
        {
            let _e437 = reflectDir;
            _o_n_1 = normalize(_e437);
            let _e440 = _o_n_1;
            let _e442 = _o_n_1;
            _o_alpha_1 = atan2(_e440.z, _e442.x);
            let _e446 = _o_n_1;
            _o_beta_1 = asin(_e446.y);
            let _e450 = sourceDim_1;
            let _e452 = sourceDim_1;
            _o_ratio_2 = (_e450.x / _e452.y);
            let _e460 = _o_alpha_1;
            let _e466 = _o_nX_1;
            let _e469 = _o_nY_1;
            let _e470 = _o_beta_1;
            let _e479 = global.U[0];
            let _e482 = _o_alpha_1;
            let _e488 = _o_nX_1;
            let _e491 = _o_nY_1;
            let _e492 = _o_beta_1;
            let _e506 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e460) / 3.1415927f) * 0.5f) * _e466), (0.5f + ((_e469 * _e470) / 3.1415927f))).x / _e479.x), vec2<f32>((((-(_e482) / 3.1415927f) * 0.5f) * _e488), (0.5f + ((_e491 * _e492) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
            col = _e506;
        }
    } else {
        let _e507 = backgroundStyle_1;
        if (_e507 == 1i) {
            {
                let _e510 = reflectDir;
                let _e513 = reflectDir;
                let _e516 = sourceDim_1;
                let _e519 = sourceDim_1;
                let _e522 = reflectDir;
                let _e525 = reflectDir;
                _o_pos_1 = (vec2<f32>((((-(_e510.x) / _e513.z) * _e516.y) / _e519.x), (-(_e522.y) / _e525.z)) * 0.5f);
                let _e532 = _o_pos_1;
                let _e535 = _o_pos_1;
                _o_m_1 = max(abs(_e532.x), abs(_e535.y));
                let _e542 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e542));
                let _e546 = _o_pos_1;
                let _e550 = global.U[0];
                let _e553 = _o_pos_1;
                let _e562 = textureSample(t_source, samp, ((vec2<f32>((_e546.x / _e550.x), _e553.y) / vec2(2f)) + vec2(0.5f)));
                let _e563 = _o_darken_1;
                let _e564 = _o_darken_1;
                let _e565 = _o_darken_1;
                col = (_e562 * vec4<f32>(_e563, _e564, _e565, 1f));
            }
        } else {
            let _e569 = backgroundStyle_1;
            if (_e569 == 2i) {
                {
                    let _e572 = sourceDim_1;
                    let _e574 = sourceDim_1;
                    _o_ratio_3 = (_e572.y / _e574.x);
                    let _e582 = reflectDir;
                    let _e585 = reflectDir;
                    let _e588 = _o_ratio_3;
                    let _e591 = reflectDir;
                    let _e594 = reflectDir;
                    let _e597 = _o_ratio_3;
                    if ((abs(_e582.y) > (abs(_e585.z) * _e588)) && (abs(_e591.y) > (abs(_e594.x) * _e597))) {
                        {
                            let _e601 = _o_X_1;
                            let _e602 = reflectDir;
                            let _e605 = reflectDir;
                            _o_X_1 = (_e601 + ((-(_e602.x) / _e605.y) * 0.5f));
                            let _e611 = _o_Y_1;
                            let _e612 = reflectDir;
                            let _e615 = reflectDir;
                            _o_Y_1 = (_e611 + ((-(_e612.z) / _e615.y) * 0.5f));
                        }
                    } else {
                        let _e621 = reflectDir;
                        let _e624 = reflectDir;
                        if (abs(_e621.x) < abs(_e624.z)) {
                            {
                                let _e628 = _o_X_1;
                                let _e629 = reflectDir;
                                let _e631 = reflectDir;
                                let _e635 = _o_ratio_3;
                                let _e639 = reflectDir;
                                _o_X_1 = (_e628 + ((((_e629.x / abs(_e631.z)) * _e635) * 0.5f) * -(sign(_e639.z))));
                                let _e645 = _o_Y_1;
                                let _e646 = reflectDir;
                                let _e648 = reflectDir;
                                _o_Y_1 = (_e645 + ((_e646.y / abs(_e648.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e655 = _o_X_1;
                                let _e656 = reflectDir;
                                let _e658 = reflectDir;
                                let _e662 = _o_ratio_3;
                                let _e666 = reflectDir;
                                _o_X_1 = (_e655 + ((((_e656.z / abs(_e658.x)) * _e662) * 0.5f) * -(sign(_e666.x))));
                                let _e672 = _o_Y_1;
                                let _e673 = reflectDir;
                                let _e675 = reflectDir;
                                _o_Y_1 = (_e672 + ((_e673.y / abs(_e675.x)) * 0.5f));
                            }
                        }
                    }
                    let _e682 = _o_X_1;
                    let _e683 = _o_Y_1;
                    let _e688 = global.U[0];
                    let _e691 = _o_X_1;
                    let _e692 = _o_Y_1;
                    let _e702 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e682, _e683).x / _e688.x), vec2<f32>(_e691, _e692).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e702;
                }
            } else {
                {
                    let _e703 = reflectDir;
                    let _e708 = ((_e703 * 0.5f) + vec3(0.5f));
                    col = vec4<f32>(_e708.x, _e708.y, _e708.z, 1f);
                }
            }
        }
    }
    let _e714 = color;
    let _e716 = color;
    let _e718 = reflectK;
    let _e719 = col;
    let _e722 = (_e716.xyz + (_e718 * _e719.xyz));
    color.x = _e722.x;
    color.y = _e722.y;
    color.z = _e722.z;
    let _e729 = color;
    return clamp(_e729, vec4(0f), vec4(1f));
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[7];
    let _e70 = global.U[8];
    let _e73 = global.U[9];
    let _e76 = global.U[10];
    let _e100 = global.U[4];
    let _e104 = global.U[11];
    let _e107 = global.U[12];
    let _e110 = global.U[13];
    let _e113 = global.U[14];
    let _e137 = global.U[15];
    let _e141 = global.U[16];
    let _e144 = global.U[17];
    let _e148 = global.U[18];
    let _e151 = global.U[19];
    let _e154 = global.U[20];
    let _e158 = global.U[21];
    let _e162 = global.U[22];
    let _e165 = basicRayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), _e137.x, _e141, _e144.x, _e148, _e151, _e154.x, _e158.x, i32(_e162.x));
    fragColor = _e165;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
