struct Params {
    U: array<vec4<f32>, 33>,
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

fn sdf(p: vec3<f32>, radius: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var q: vec3<f32>;

    p_1 = p;
    radius_1 = radius;
    let _e11 = p_1;
    let _e13 = vec3(1f);
    q = ((_e11 - (floor((_e11 / _e13)) * _e13)) - vec3(0.5f));
    let _e22 = q;
    let _e23 = q;
    let _e27 = radius_1;
    return (length((_e22 - round(_e23))) - (_e27 * 0.5f));
}

fn normal(p_2: vec3<f32>, radius_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var d: f32 = 0.0001f;
    var s: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    let _e13 = p_3;
    let _e14 = radius_3;
    let _e15 = sdf(_e13, _e14);
    s = _e15;
    let _e17 = s;
    let _e18 = p_3;
    let _e20 = d;
    let _e22 = p_3;
    let _e24 = p_3;
    let _e27 = radius_3;
    let _e28 = sdf(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27);
    let _e30 = d;
    let _e32 = s;
    let _e33 = p_3;
    let _e35 = p_3;
    let _e37 = d;
    let _e39 = p_3;
    let _e42 = radius_3;
    let _e43 = sdf(vec3<f32>(_e33.x, (_e35.y - _e37), _e39.z), _e42);
    let _e45 = d;
    let _e47 = s;
    let _e48 = p_3;
    let _e50 = p_3;
    let _e52 = p_3;
    let _e54 = d;
    let _e57 = radius_3;
    let _e58 = sdf(vec3<f32>(_e48.x, _e50.y, (_e52.z - _e54)), _e57);
    let _e60 = d;
    return normalize(vec3<f32>(((_e17 - _e28) / _e30), ((_e32 - _e43) / _e45), ((_e47 - _e58) / _e60)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32, radius_4: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var radius_5: f32;
    var d_1: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_4: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    radius_5 = radius_4;
    let _e15 = p0_1;
    let _e16 = radius_5;
    let _e17 = sdf(_e15, _e16);
    d_1 = _e17;
    let _e19 = d_1;
    s_1 = sign(_e19);
    loop {
        let _e26 = step;
        let _e29 = d_1;
        if !(((_e26 < 1000i) && (_e29 < 100f))) {
            break;
        }
        {
            let _e34 = totalD;
            let _e35 = d_1;
            let _e36 = side_1;
            totalD = (_e34 + (_e35 * _e36));
            let _e39 = p0_1;
            let _e40 = totalD;
            let _e41 = dir_1;
            p_4 = (_e39 + (_e40 * _e41));
            let _e45 = p_4;
            let _e46 = radius_5;
            let _e47 = sdf(_e45, _e46);
            d_1 = _e47;
            let _e48 = d_1;
            if (abs(_e48) < 0.0001f) {
                let _e52 = p_4;
                return _e52;
            }
            let _e53 = step;
            step = (_e53 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32, radius_6: f32) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var bkgTransform_1: mat4x4<f32>;
    var camera3DTransform_1: mat4x4<f32>;
    var colorMaterial_1: vec4<f32>;
    var refractionIndex_1: f32;
    var fresnelStrength_1: f32;
    var chromaticAberration_1: f32;
    var colorFog_1: vec4<f32>;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var specular_1: f32;
    var backgroundStyle_1: i32;
    var radius_7: f32;
    var D: f32 = 1f;
    var camera_2: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var target_2: vec3<f32> = vec3(0f);
    var camDir: vec3<f32>;
    var lightPos: vec3<f32>;
    var invModelTransform: mat4x4<f32>;
    var model3DTransform3_: mat3x3<f32>;
    var dir_2: vec3<f32>;
    var col: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var color: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var qIn: vec3<f32>;
    var reflectDir: vec3<f32>;
    var reflectK: vec3<f32> = vec3(1f);
    var ref_: f32;
    var chromaticAbb: f32;
    var absorption: f32;
    var nIn: vec3<f32>;
    var incidence: f32;
    var fresnel: f32;
    var reflectivity: vec3<f32>;
    var lightDir: vec3<f32>;
    var refractDir: vec3<f32>;
    var k: f32;
    var qOut: vec3<f32>;
    var n: vec3<f32>;
    var rDir: vec3<f32>;
    var local: vec3<f32>;
    var refractDirR: vec3<f32>;
    var gDir: vec3<f32>;
    var local_1: vec3<f32>;
    var refractDirG: vec3<f32>;
    var bDir: vec3<f32>;
    var local_2: vec3<f32>;
    var refractDirB: vec3<f32>;
    var colR: vec4<f32>;
    var colG: vec4<f32>;
    var colB: vec4<f32>;
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
    var _o_n_2: vec3<f32>;
    var _o_alpha_2: f32;
    var _o_beta_2: f32;
    var _o_ratio_4: f32;
    var _o_nX_2: f32 = 2f;
    var _o_nY_2: f32 = 1f;
    var _o_pos_2: vec2<f32>;
    var _o_m_2: f32;
    var _o_darken_2: f32;
    var _o_ratio_5: f32;
    var _o_X_2: f32 = 0.5f;
    var _o_Y_2: f32 = 0.5f;
    var absorbed: f32;
    var origReflectDir: vec3<f32>;
    var qR: vec3<f32>;
    var n_1: vec3<f32>;
    var _o_n_3: vec3<f32>;
    var _o_alpha_3: f32;
    var _o_beta_3: f32;
    var _o_ratio_6: f32;
    var _o_nX_3: f32 = 2f;
    var _o_nY_3: f32 = 1f;
    var _o_pos_3: vec2<f32>;
    var _o_m_3: f32;
    var _o_darken_3: f32;
    var _o_ratio_7: f32;
    var _o_X_3: f32 = 0.5f;
    var _o_Y_3: f32 = 0.5f;
    var kSpec: f32;
    var dist: f32;
    var kFog: f32;
    var _o_n_4: vec3<f32>;
    var _o_alpha_4: f32;
    var _o_beta_4: f32;
    var _o_ratio_8: f32;
    var _o_nX_4: f32 = 2f;
    var _o_nY_4: f32 = 1f;
    var _o_pos_4: vec2<f32>;
    var _o_m_4: f32;
    var _o_darken_4: f32;
    var _o_ratio_9: f32;
    var _o_X_4: f32 = 0.5f;
    var _o_Y_4: f32 = 0.5f;

    uv_3 = uv_2;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    lightSourceTransform_1 = lightSourceTransform;
    bkgTransform_1 = bkgTransform;
    camera3DTransform_1 = camera3DTransform;
    colorMaterial_1 = colorMaterial;
    refractionIndex_1 = refractionIndex;
    fresnelStrength_1 = fresnelStrength;
    chromaticAberration_1 = chromaticAberration;
    colorFog_1 = colorFog;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    specular_1 = specular;
    backgroundStyle_1 = backgroundStyle;
    radius_7 = radius_6;
    let _e48 = camera3DTransform_1;
    let _e49 = camera_2;
    camera_2 = (_e48 * vec4<f32>(_e49.x, _e49.y, _e49.z, 1f)).xyz;
    let _e60 = uv_3;
    let _e61 = camera_2;
    let _e62 = target_2;
    let _e64 = getRay(_e60, _e61, _e62, 1f);
    camDir = _e64;
    let _e66 = lightSourceTransform_1;
    lightPos = (_e66 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e75 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e75);
    let _e78 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e78[0].xyz, _e78[1].xyz, _e78[2].xyz);
    let _e89 = invModelTransform;
    let _e90 = camera_2;
    camera_2 = (_e89 * vec4<f32>(_e90.x, _e90.y, _e90.z, 1f)).xyz;
    let _e98 = uv_3;
    let _e100 = D;
    let _e102 = uv_3;
    let _e104 = D;
    dir_2 = normalize(vec3<f32>((_e98.x * _e100), (_e102.y * _e104), -1f));
    let _e111 = camera3DTransform_1;
    let _e121 = dir_2;
    dir_2 = (mat3x3<f32>(_e111[0].xyz, _e111[1].xyz, _e111[2].xyz) * _e121);
    let _e123 = invModelTransform;
    let _e133 = dir_2;
    camDir = normalize((mat3x3<f32>(_e123[0].xyz, _e123[1].xyz, _e123[2].xyz) * _e133));
    let _e148 = camera_2;
    let _e149 = camDir;
    let _e151 = radius_7;
    let _e152 = rayMarch(_e148, _e149, 1f, _e151);
    qIn = _e152;
    let _e154 = camDir;
    reflectDir = _e154;
    let _e159 = refractionIndex_1;
    ref_ = _e159;
    let _e161 = chromaticAberration_1;
    chromaticAbb = _e161;
    let _e167 = colorMaterial_1;
    let _e171 = colorMaterial_1;
    absorption = pow(mix(30f, 1000f, smoothstep(0.95f, 1f, _e167.w)), _e171.w);
    let _e175 = qIn;
    if (_e175.x != 100000000000000000000f) {
        {
            let _e179 = qIn;
            let _e180 = radius_7;
            let _e181 = normal(_e179, _e180);
            nIn = _e181;
            let _e183 = nIn;
            let _e184 = camDir;
            incidence = abs(dot(_e183, _e184));
            let _e189 = incidence;
            let _e192 = fresnelStrength_1;
            let _e199 = fresnelStrength_1;
            let _e204 = fresnelStrength_1;
            fresnel = ((pow((1f - _e189), (6f - (_e192 * 6f))) * smoothstep(0f, 0.025f, _e199)) * smoothstep(0f, 0.025f, _e204));
            let _e208 = camDir;
            let _e209 = nIn;
            reflectDir = reflect(_e208, _e209);
            let _e213 = colorMaterial_1;
            reflectivity = (vec3(1f) - _e213.xyz);
            let _e217 = reflectivity;
            reflectK = _e217;
            let _e218 = qIn;
            let _e219 = lightPos;
            lightDir = normalize((_e218 - _e219));
            let _e223 = fresnel;
            if (_e223 != 1f) {
                {
                    let _e228 = ref_;
                    let _e229 = ref_;
                    let _e232 = nIn;
                    let _e233 = camDir;
                    let _e235 = nIn;
                    let _e236 = camDir;
                    k = (1f - ((_e228 * _e229) * (1f - (dot(_e232, _e233) * dot(_e235, _e236)))));
                    let _e243 = k;
                    if (_e243 < 0f) {
                        refractDir = vec3(0f);
                    } else {
                        let _e248 = ref_;
                        let _e249 = camDir;
                        let _e251 = ref_;
                        let _e252 = nIn;
                        let _e253 = camDir;
                        let _e256 = k;
                        let _e259 = nIn;
                        refractDir = ((_e248 * _e249) - (((_e251 * dot(_e252, _e253)) + sqrt(_e256)) * _e259));
                    }
                    let _e262 = qIn;
                    let _e263 = nIn;
                    let _e267 = refractDir;
                    let _e270 = radius_7;
                    let _e271 = rayMarch((_e262 - (_e263 * 0.001f)), _e267, -1f, _e270);
                    qOut = _e271;
                    let _e273 = qOut;
                    let _e274 = radius_7;
                    let _e275 = normal(_e273, _e274);
                    n = -(_e275);
                    let _e278 = refractDir;
                    let _e279 = n;
                    let _e281 = ref_;
                    let _e283 = chromaticAbb;
                    rDir = refract(_e278, _e279, ((1f / _e281) - _e283));
                    let _e287 = rDir;
                    if (length(_e287) == 0f) {
                        let _e291 = refractDir;
                        let _e292 = n;
                        local = reflect(_e291, _e292);
                    } else {
                        let _e294 = rDir;
                        local = _e294;
                    }
                    let _e296 = local;
                    refractDirR = _e296;
                    let _e298 = refractDir;
                    let _e299 = n;
                    let _e301 = ref_;
                    gDir = refract(_e298, _e299, (1f / _e301));
                    let _e305 = gDir;
                    if (length(_e305) == 0f) {
                        let _e309 = refractDir;
                        let _e310 = n;
                        local_1 = reflect(_e309, _e310);
                    } else {
                        let _e312 = gDir;
                        local_1 = _e312;
                    }
                    let _e314 = local_1;
                    refractDirG = _e314;
                    let _e316 = refractDir;
                    let _e317 = n;
                    let _e319 = ref_;
                    let _e321 = chromaticAbb;
                    bDir = refract(_e316, _e317, ((1f / _e319) + _e321));
                    let _e325 = bDir;
                    if (length(_e325) == 0f) {
                        let _e329 = refractDir;
                        let _e330 = n;
                        local_2 = reflect(_e329, _e330);
                    } else {
                        let _e332 = bDir;
                        local_2 = _e332;
                    }
                    let _e334 = local_2;
                    refractDirB = _e334;
                    let _e339 = model3DTransform3_;
                    let _e340 = refractDirR;
                    refractDirR = (_e339 * _e340);
                    let _e342 = model3DTransform3_;
                    let _e343 = refractDirG;
                    refractDirG = (_e342 * _e343);
                    let _e345 = model3DTransform3_;
                    let _e346 = refractDirB;
                    refractDirB = (_e345 * _e346);
                    let _e348 = backgroundStyle_1;
                    if (_e348 == 0i) {
                        {
                            let _e351 = refractDirR;
                            _o_n = normalize(_e351);
                            let _e354 = _o_n;
                            let _e356 = _o_n;
                            _o_alpha = atan2(_e354.z, _e356.x);
                            let _e360 = _o_n;
                            _o_beta = asin(_e360.y);
                            let _e364 = sourceDim_1;
                            let _e366 = sourceDim_1;
                            _o_ratio = (_e364.x / _e366.y);
                            let _e374 = _o_alpha;
                            let _e380 = _o_nX;
                            let _e383 = _o_nY;
                            let _e384 = _o_beta;
                            let _e393 = global.U[0];
                            let _e396 = _o_alpha;
                            let _e402 = _o_nX;
                            let _e405 = _o_nY;
                            let _e406 = _o_beta;
                            let _e420 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e374) / 3.1415927f) * 0.5f) * _e380), (0.5f + ((_e383 * _e384) / 3.1415927f))).x / _e393.x), vec2<f32>((((-(_e396) / 3.1415927f) * 0.5f) * _e402), (0.5f + ((_e405 * _e406) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colR = _e420;
                        }
                    } else {
                        let _e421 = backgroundStyle_1;
                        if (_e421 == 1i) {
                            {
                                let _e424 = refractDirR;
                                let _e427 = refractDirR;
                                let _e430 = refractDirR;
                                let _e433 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e424.x) / _e427.z), (-(_e430.y) / _e433.z)) * 1f);
                                let _e440 = _o_pos;
                                let _e443 = _o_pos;
                                _o_m = max(abs(_e440.x), abs(_e443.y));
                                let _e450 = _o_m;
                                _o_darken = (4f / max(4f, _e450));
                                let _e454 = _o_pos;
                                let _e458 = global.U[0];
                                let _e461 = _o_pos;
                                let _e470 = textureSample(t_source, samp, ((vec2<f32>((_e454.x / _e458.x), _e461.y) / vec2(2f)) + vec2(0.5f)));
                                let _e471 = _o_darken;
                                let _e472 = _o_darken;
                                let _e473 = _o_darken;
                                colR = (_e470 * vec4<f32>(_e471, _e472, _e473, 1f));
                            }
                        } else {
                            let _e477 = backgroundStyle_1;
                            if (_e477 == 2i) {
                                {
                                    let _e480 = sourceDim_1;
                                    let _e482 = sourceDim_1;
                                    _o_ratio_1 = (_e480.y / _e482.x);
                                    let _e490 = refractDirR;
                                    let _e493 = refractDirR;
                                    let _e496 = _o_ratio_1;
                                    let _e499 = refractDirR;
                                    let _e502 = refractDirR;
                                    let _e505 = _o_ratio_1;
                                    if ((abs(_e490.y) > (abs(_e493.z) * _e496)) && (abs(_e499.y) > (abs(_e502.x) * _e505))) {
                                        {
                                            let _e509 = _o_X;
                                            let _e510 = refractDirR;
                                            let _e513 = refractDirR;
                                            _o_X = (_e509 + ((-(_e510.x) / _e513.y) * 0.5f));
                                            let _e519 = _o_Y;
                                            let _e520 = refractDirR;
                                            let _e523 = refractDirR;
                                            _o_Y = (_e519 + ((-(_e520.z) / _e523.y) * 0.5f));
                                        }
                                    } else {
                                        let _e529 = refractDirR;
                                        let _e532 = refractDirR;
                                        if (abs(_e529.x) < abs(_e532.z)) {
                                            {
                                                let _e536 = _o_X;
                                                let _e537 = refractDirR;
                                                let _e539 = refractDirR;
                                                let _e543 = _o_ratio_1;
                                                let _e547 = refractDirR;
                                                _o_X = (_e536 + ((((_e537.x / abs(_e539.z)) * _e543) * 0.5f) * -(sign(_e547.z))));
                                                let _e553 = _o_Y;
                                                let _e554 = refractDirR;
                                                let _e556 = refractDirR;
                                                _o_Y = (_e553 + ((_e554.y / abs(_e556.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e563 = _o_X;
                                                let _e564 = refractDirR;
                                                let _e566 = refractDirR;
                                                let _e570 = _o_ratio_1;
                                                let _e574 = refractDirR;
                                                _o_X = (_e563 + ((((_e564.z / abs(_e566.x)) * _e570) * 0.5f) * -(sign(_e574.x))));
                                                let _e580 = _o_Y;
                                                let _e581 = refractDirR;
                                                let _e583 = refractDirR;
                                                _o_Y = (_e580 + ((_e581.y / abs(_e583.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e590 = _o_X;
                                    let _e591 = _o_Y;
                                    let _e596 = global.U[0];
                                    let _e599 = _o_X;
                                    let _e600 = _o_Y;
                                    let _e610 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e590, _e591).x / _e596.x), vec2<f32>(_e599, _e600).y) / vec2(2f)) + vec2(0.5f)));
                                    colR = _e610;
                                }
                            } else {
                                {
                                    let _e611 = refractDirR;
                                    let _e616 = ((_e611 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e616.x, _e616.y, _e616.z, 1f);
                                }
                            }
                        }
                    }
                    let _e622 = backgroundStyle_1;
                    if (_e622 == 0i) {
                        {
                            let _e625 = refractDirG;
                            _o_n_1 = normalize(_e625);
                            let _e628 = _o_n_1;
                            let _e630 = _o_n_1;
                            _o_alpha_1 = atan2(_e628.z, _e630.x);
                            let _e634 = _o_n_1;
                            _o_beta_1 = asin(_e634.y);
                            let _e638 = sourceDim_1;
                            let _e640 = sourceDim_1;
                            _o_ratio_2 = (_e638.x / _e640.y);
                            let _e648 = _o_alpha_1;
                            let _e654 = _o_nX_1;
                            let _e657 = _o_nY_1;
                            let _e658 = _o_beta_1;
                            let _e667 = global.U[0];
                            let _e670 = _o_alpha_1;
                            let _e676 = _o_nX_1;
                            let _e679 = _o_nY_1;
                            let _e680 = _o_beta_1;
                            let _e694 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e648) / 3.1415927f) * 0.5f) * _e654), (0.5f + ((_e657 * _e658) / 3.1415927f))).x / _e667.x), vec2<f32>((((-(_e670) / 3.1415927f) * 0.5f) * _e676), (0.5f + ((_e679 * _e680) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colG = _e694;
                        }
                    } else {
                        let _e695 = backgroundStyle_1;
                        if (_e695 == 1i) {
                            {
                                let _e698 = refractDirG;
                                let _e701 = refractDirG;
                                let _e704 = refractDirG;
                                let _e707 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e698.x) / _e701.z), (-(_e704.y) / _e707.z)) * 1f);
                                let _e714 = _o_pos_1;
                                let _e717 = _o_pos_1;
                                _o_m_1 = max(abs(_e714.x), abs(_e717.y));
                                let _e724 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e724));
                                let _e728 = _o_pos_1;
                                let _e732 = global.U[0];
                                let _e735 = _o_pos_1;
                                let _e744 = textureSample(t_source, samp, ((vec2<f32>((_e728.x / _e732.x), _e735.y) / vec2(2f)) + vec2(0.5f)));
                                let _e745 = _o_darken_1;
                                let _e746 = _o_darken_1;
                                let _e747 = _o_darken_1;
                                colG = (_e744 * vec4<f32>(_e745, _e746, _e747, 1f));
                            }
                        } else {
                            let _e751 = backgroundStyle_1;
                            if (_e751 == 2i) {
                                {
                                    let _e754 = sourceDim_1;
                                    let _e756 = sourceDim_1;
                                    _o_ratio_3 = (_e754.y / _e756.x);
                                    let _e764 = refractDirG;
                                    let _e767 = refractDirG;
                                    let _e770 = _o_ratio_3;
                                    let _e773 = refractDirG;
                                    let _e776 = refractDirG;
                                    let _e779 = _o_ratio_3;
                                    if ((abs(_e764.y) > (abs(_e767.z) * _e770)) && (abs(_e773.y) > (abs(_e776.x) * _e779))) {
                                        {
                                            let _e783 = _o_X_1;
                                            let _e784 = refractDirG;
                                            let _e787 = refractDirG;
                                            _o_X_1 = (_e783 + ((-(_e784.x) / _e787.y) * 0.5f));
                                            let _e793 = _o_Y_1;
                                            let _e794 = refractDirG;
                                            let _e797 = refractDirG;
                                            _o_Y_1 = (_e793 + ((-(_e794.z) / _e797.y) * 0.5f));
                                        }
                                    } else {
                                        let _e803 = refractDirG;
                                        let _e806 = refractDirG;
                                        if (abs(_e803.x) < abs(_e806.z)) {
                                            {
                                                let _e810 = _o_X_1;
                                                let _e811 = refractDirG;
                                                let _e813 = refractDirG;
                                                let _e817 = _o_ratio_3;
                                                let _e821 = refractDirG;
                                                _o_X_1 = (_e810 + ((((_e811.x / abs(_e813.z)) * _e817) * 0.5f) * -(sign(_e821.z))));
                                                let _e827 = _o_Y_1;
                                                let _e828 = refractDirG;
                                                let _e830 = refractDirG;
                                                _o_Y_1 = (_e827 + ((_e828.y / abs(_e830.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e837 = _o_X_1;
                                                let _e838 = refractDirG;
                                                let _e840 = refractDirG;
                                                let _e844 = _o_ratio_3;
                                                let _e848 = refractDirG;
                                                _o_X_1 = (_e837 + ((((_e838.z / abs(_e840.x)) * _e844) * 0.5f) * -(sign(_e848.x))));
                                                let _e854 = _o_Y_1;
                                                let _e855 = refractDirG;
                                                let _e857 = refractDirG;
                                                _o_Y_1 = (_e854 + ((_e855.y / abs(_e857.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e864 = _o_X_1;
                                    let _e865 = _o_Y_1;
                                    let _e870 = global.U[0];
                                    let _e873 = _o_X_1;
                                    let _e874 = _o_Y_1;
                                    let _e884 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e864, _e865).x / _e870.x), vec2<f32>(_e873, _e874).y) / vec2(2f)) + vec2(0.5f)));
                                    colG = _e884;
                                }
                            } else {
                                {
                                    let _e885 = refractDirG;
                                    let _e890 = ((_e885 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e890.x, _e890.y, _e890.z, 1f);
                                }
                            }
                        }
                    }
                    let _e896 = backgroundStyle_1;
                    if (_e896 == 0i) {
                        {
                            let _e899 = refractDirB;
                            _o_n_2 = normalize(_e899);
                            let _e902 = _o_n_2;
                            let _e904 = _o_n_2;
                            _o_alpha_2 = atan2(_e902.z, _e904.x);
                            let _e908 = _o_n_2;
                            _o_beta_2 = asin(_e908.y);
                            let _e912 = sourceDim_1;
                            let _e914 = sourceDim_1;
                            _o_ratio_4 = (_e912.x / _e914.y);
                            let _e922 = _o_alpha_2;
                            let _e928 = _o_nX_2;
                            let _e931 = _o_nY_2;
                            let _e932 = _o_beta_2;
                            let _e941 = global.U[0];
                            let _e944 = _o_alpha_2;
                            let _e950 = _o_nX_2;
                            let _e953 = _o_nY_2;
                            let _e954 = _o_beta_2;
                            let _e968 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e922) / 3.1415927f) * 0.5f) * _e928), (0.5f + ((_e931 * _e932) / 3.1415927f))).x / _e941.x), vec2<f32>((((-(_e944) / 3.1415927f) * 0.5f) * _e950), (0.5f + ((_e953 * _e954) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colB = _e968;
                        }
                    } else {
                        let _e969 = backgroundStyle_1;
                        if (_e969 == 1i) {
                            {
                                let _e972 = refractDirB;
                                let _e975 = refractDirB;
                                let _e978 = refractDirB;
                                let _e981 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e972.x) / _e975.z), (-(_e978.y) / _e981.z)) * 1f);
                                let _e988 = _o_pos_2;
                                let _e991 = _o_pos_2;
                                _o_m_2 = max(abs(_e988.x), abs(_e991.y));
                                let _e998 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e998));
                                let _e1002 = _o_pos_2;
                                let _e1006 = global.U[0];
                                let _e1009 = _o_pos_2;
                                let _e1018 = textureSample(t_source, samp, ((vec2<f32>((_e1002.x / _e1006.x), _e1009.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1019 = _o_darken_2;
                                let _e1020 = _o_darken_2;
                                let _e1021 = _o_darken_2;
                                colB = (_e1018 * vec4<f32>(_e1019, _e1020, _e1021, 1f));
                            }
                        } else {
                            let _e1025 = backgroundStyle_1;
                            if (_e1025 == 2i) {
                                {
                                    let _e1028 = sourceDim_1;
                                    let _e1030 = sourceDim_1;
                                    _o_ratio_5 = (_e1028.y / _e1030.x);
                                    let _e1038 = refractDirB;
                                    let _e1041 = refractDirB;
                                    let _e1044 = _o_ratio_5;
                                    let _e1047 = refractDirB;
                                    let _e1050 = refractDirB;
                                    let _e1053 = _o_ratio_5;
                                    if ((abs(_e1038.y) > (abs(_e1041.z) * _e1044)) && (abs(_e1047.y) > (abs(_e1050.x) * _e1053))) {
                                        {
                                            let _e1057 = _o_X_2;
                                            let _e1058 = refractDirB;
                                            let _e1061 = refractDirB;
                                            _o_X_2 = (_e1057 + ((-(_e1058.x) / _e1061.y) * 0.5f));
                                            let _e1067 = _o_Y_2;
                                            let _e1068 = refractDirB;
                                            let _e1071 = refractDirB;
                                            _o_Y_2 = (_e1067 + ((-(_e1068.z) / _e1071.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1077 = refractDirB;
                                        let _e1080 = refractDirB;
                                        if (abs(_e1077.x) < abs(_e1080.z)) {
                                            {
                                                let _e1084 = _o_X_2;
                                                let _e1085 = refractDirB;
                                                let _e1087 = refractDirB;
                                                let _e1091 = _o_ratio_5;
                                                let _e1095 = refractDirB;
                                                _o_X_2 = (_e1084 + ((((_e1085.x / abs(_e1087.z)) * _e1091) * 0.5f) * -(sign(_e1095.z))));
                                                let _e1101 = _o_Y_2;
                                                let _e1102 = refractDirB;
                                                let _e1104 = refractDirB;
                                                _o_Y_2 = (_e1101 + ((_e1102.y / abs(_e1104.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1111 = _o_X_2;
                                                let _e1112 = refractDirB;
                                                let _e1114 = refractDirB;
                                                let _e1118 = _o_ratio_5;
                                                let _e1122 = refractDirB;
                                                _o_X_2 = (_e1111 + ((((_e1112.z / abs(_e1114.x)) * _e1118) * 0.5f) * -(sign(_e1122.x))));
                                                let _e1128 = _o_Y_2;
                                                let _e1129 = refractDirB;
                                                let _e1131 = refractDirB;
                                                _o_Y_2 = (_e1128 + ((_e1129.y / abs(_e1131.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1138 = _o_X_2;
                                    let _e1139 = _o_Y_2;
                                    let _e1144 = global.U[0];
                                    let _e1147 = _o_X_2;
                                    let _e1148 = _o_Y_2;
                                    let _e1158 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1138, _e1139).x / _e1144.x), vec2<f32>(_e1147, _e1148).y) / vec2(2f)) + vec2(0.5f)));
                                    colB = _e1158;
                                }
                            } else {
                                {
                                    let _e1159 = refractDirB;
                                    let _e1164 = ((_e1159 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1164.x, _e1164.y, _e1164.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1170 = colR;
                    let _e1172 = colG;
                    let _e1174 = colB;
                    col = vec4<f32>(_e1170.x, _e1172.y, _e1174.z, 1f);
                    let _e1180 = absorption;
                    let _e1181 = qIn;
                    let _e1182 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1180 * length((_e1181 - _e1182)))));
                    let _e1190 = absorbed;
                    let _e1193 = colorMaterial_1;
                    absorbed = mix(0f, _e1190, smoothstep(0f, 0.1f, _e1193.w));
                    let _e1197 = color;
                    let _e1199 = color;
                    let _e1201 = colorMaterial_1;
                    let _e1204 = fresnel;
                    let _e1208 = absorbed;
                    let _e1211 = col;
                    let _e1214 = (_e1199.xyz + (((_e1201.xyz * (1f - _e1204)) * (1f - _e1208)) * _e1211.xyz));
                    color.x = _e1214.x;
                    color.y = _e1214.y;
                    color.z = _e1214.z;
                    let _e1221 = color;
                    let _e1223 = color;
                    let _e1225 = absorbed;
                    let _e1226 = colorMaterial_1;
                    let _e1229 = ambientColor_1;
                    let _e1232 = nIn;
                    let _e1233 = lightDir;
                    let _e1236 = sourceColor_1;
                    let _e1241 = (_e1223.xyz + ((_e1225 * _e1226.xyz) * (_e1229.xyz + (max(0f, dot(_e1232, _e1233)) * _e1236.xyz))));
                    color.x = _e1241.x;
                    color.y = _e1241.y;
                    color.z = _e1241.z;
                }
            }
            let _e1248 = fresnel;
            let _e1251 = specular_1;
            if ((_e1248 != 0f) || (_e1251 != 0f)) {
                {
                    let _e1255 = reflectDir;
                    origReflectDir = _e1255;
                    let _e1257 = qIn;
                    let _e1258 = nIn;
                    let _e1262 = reflectDir;
                    let _e1264 = radius_7;
                    let _e1265 = rayMarch((_e1257 + (_e1258 * 0.001f)), _e1262, 1f, _e1264);
                    qR = _e1265;
                    let _e1267 = qR;
                    if (_e1267.x != 100000000000000000000f) {
                        {
                            let _e1271 = qR;
                            let _e1272 = radius_7;
                            let _e1273 = normal(_e1271, _e1272);
                            n_1 = _e1273;
                            let _e1275 = reflectDir;
                            let _e1276 = n_1;
                            reflectDir = reflect(_e1275, _e1276);
                        }
                    }
                    let _e1278 = model3DTransform3_;
                    let _e1279 = reflectDir;
                    reflectDir = (_e1278 * _e1279);
                    let _e1281 = backgroundStyle_1;
                    if (_e1281 == 0i) {
                        {
                            let _e1284 = reflectDir;
                            _o_n_3 = normalize(_e1284);
                            let _e1287 = _o_n_3;
                            let _e1289 = _o_n_3;
                            _o_alpha_3 = atan2(_e1287.z, _e1289.x);
                            let _e1293 = _o_n_3;
                            _o_beta_3 = asin(_e1293.y);
                            let _e1297 = sourceDim_1;
                            let _e1299 = sourceDim_1;
                            _o_ratio_6 = (_e1297.x / _e1299.y);
                            let _e1307 = _o_alpha_3;
                            let _e1313 = _o_nX_3;
                            let _e1316 = _o_nY_3;
                            let _e1317 = _o_beta_3;
                            let _e1326 = global.U[0];
                            let _e1329 = _o_alpha_3;
                            let _e1335 = _o_nX_3;
                            let _e1338 = _o_nY_3;
                            let _e1339 = _o_beta_3;
                            let _e1353 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1307) / 3.1415927f) * 0.5f) * _e1313), (0.5f + ((_e1316 * _e1317) / 3.1415927f))).x / _e1326.x), vec2<f32>((((-(_e1329) / 3.1415927f) * 0.5f) * _e1335), (0.5f + ((_e1338 * _e1339) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1353;
                        }
                    } else {
                        let _e1354 = backgroundStyle_1;
                        if (_e1354 == 1i) {
                            {
                                let _e1357 = reflectDir;
                                let _e1360 = reflectDir;
                                let _e1363 = reflectDir;
                                let _e1366 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1357.x) / _e1360.z), (-(_e1363.y) / _e1366.z)) * 1f);
                                let _e1373 = _o_pos_3;
                                let _e1376 = _o_pos_3;
                                _o_m_3 = max(abs(_e1373.x), abs(_e1376.y));
                                let _e1383 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1383));
                                let _e1387 = _o_pos_3;
                                let _e1391 = global.U[0];
                                let _e1394 = _o_pos_3;
                                let _e1403 = textureSample(t_source, samp, ((vec2<f32>((_e1387.x / _e1391.x), _e1394.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1404 = _o_darken_3;
                                let _e1405 = _o_darken_3;
                                let _e1406 = _o_darken_3;
                                col = (_e1403 * vec4<f32>(_e1404, _e1405, _e1406, 1f));
                            }
                        } else {
                            let _e1410 = backgroundStyle_1;
                            if (_e1410 == 2i) {
                                {
                                    let _e1413 = sourceDim_1;
                                    let _e1415 = sourceDim_1;
                                    _o_ratio_7 = (_e1413.y / _e1415.x);
                                    let _e1423 = reflectDir;
                                    let _e1426 = reflectDir;
                                    let _e1429 = _o_ratio_7;
                                    let _e1432 = reflectDir;
                                    let _e1435 = reflectDir;
                                    let _e1438 = _o_ratio_7;
                                    if ((abs(_e1423.y) > (abs(_e1426.z) * _e1429)) && (abs(_e1432.y) > (abs(_e1435.x) * _e1438))) {
                                        {
                                            let _e1442 = _o_X_3;
                                            let _e1443 = reflectDir;
                                            let _e1446 = reflectDir;
                                            _o_X_3 = (_e1442 + ((-(_e1443.x) / _e1446.y) * 0.5f));
                                            let _e1452 = _o_Y_3;
                                            let _e1453 = reflectDir;
                                            let _e1456 = reflectDir;
                                            _o_Y_3 = (_e1452 + ((-(_e1453.z) / _e1456.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1462 = reflectDir;
                                        let _e1465 = reflectDir;
                                        if (abs(_e1462.x) < abs(_e1465.z)) {
                                            {
                                                let _e1469 = _o_X_3;
                                                let _e1470 = reflectDir;
                                                let _e1472 = reflectDir;
                                                let _e1476 = _o_ratio_7;
                                                let _e1480 = reflectDir;
                                                _o_X_3 = (_e1469 + ((((_e1470.x / abs(_e1472.z)) * _e1476) * 0.5f) * -(sign(_e1480.z))));
                                                let _e1486 = _o_Y_3;
                                                let _e1487 = reflectDir;
                                                let _e1489 = reflectDir;
                                                _o_Y_3 = (_e1486 + ((_e1487.y / abs(_e1489.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1496 = _o_X_3;
                                                let _e1497 = reflectDir;
                                                let _e1499 = reflectDir;
                                                let _e1503 = _o_ratio_7;
                                                let _e1507 = reflectDir;
                                                _o_X_3 = (_e1496 + ((((_e1497.z / abs(_e1499.x)) * _e1503) * 0.5f) * -(sign(_e1507.x))));
                                                let _e1513 = _o_Y_3;
                                                let _e1514 = reflectDir;
                                                let _e1516 = reflectDir;
                                                _o_Y_3 = (_e1513 + ((_e1514.y / abs(_e1516.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1523 = _o_X_3;
                                    let _e1524 = _o_Y_3;
                                    let _e1529 = global.U[0];
                                    let _e1532 = _o_X_3;
                                    let _e1533 = _o_Y_3;
                                    let _e1543 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1523, _e1524).x / _e1529.x), vec2<f32>(_e1532, _e1533).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e1543;
                                }
                            } else {
                                {
                                    let _e1544 = reflectDir;
                                    let _e1549 = ((_e1544 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1549.x, _e1549.y, _e1549.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1555 = color;
                    let _e1557 = color;
                    let _e1559 = fresnel;
                    let _e1560 = col;
                    let _e1563 = (_e1557.xyz + (_e1559 * _e1560.xyz));
                    color.x = _e1563.x;
                    color.y = _e1563.y;
                    color.z = _e1563.z;
                    let _e1571 = specular_1;
                    let _e1574 = lightDir;
                    let _e1575 = origReflectDir;
                    kSpec = ((10f * _e1571) * pow(max(0f, dot(_e1574, _e1575)), 9f));
                    let _e1582 = color;
                    let _e1584 = color;
                    let _e1586 = sourceColor_1;
                    let _e1588 = kSpec;
                    let _e1590 = (_e1584.xyz + (_e1586.xyz * _e1588));
                    color.x = _e1590.x;
                    color.y = _e1590.y;
                    color.z = _e1590.z;
                }
            }
            let _e1597 = colorFog_1;
            if (_e1597.w != 0f) {
                {
                    let _e1601 = camera_2;
                    let _e1602 = qIn;
                    dist = length((_e1601 - _e1602));
                    let _e1608 = colorFog_1;
                    let _e1611 = dist;
                    kFog = (1f - pow(0.4f, (_e1608.w * max(0f, (_e1611 - 0.1f)))));
                    let _e1619 = color;
                    let _e1621 = color;
                    let _e1623 = colorFog_1;
                    let _e1625 = kFog;
                    let _e1627 = mix(_e1621.xyz, _e1623.xyz, vec3(_e1625));
                    color.x = _e1627.x;
                    color.y = _e1627.y;
                    color.z = _e1627.z;
                }
            }
        }
    } else {
        {
            let _e1634 = bkgTransform_1;
            let _e1644 = model3DTransform3_;
            let _e1646 = camDir;
            camDir = ((mat3x3<f32>(_e1634[0].xyz, _e1634[1].xyz, _e1634[2].xyz) * _e1644) * _e1646);
            let _e1648 = backgroundStyle_1;
            if (_e1648 == 0i) {
                {
                    let _e1651 = camDir;
                    _o_n_4 = normalize(_e1651);
                    let _e1654 = _o_n_4;
                    let _e1656 = _o_n_4;
                    _o_alpha_4 = atan2(_e1654.z, _e1656.x);
                    let _e1660 = _o_n_4;
                    _o_beta_4 = asin(_e1660.y);
                    let _e1664 = sourceDim_1;
                    let _e1666 = sourceDim_1;
                    _o_ratio_8 = (_e1664.x / _e1666.y);
                    let _e1674 = _o_alpha_4;
                    let _e1680 = _o_nX_4;
                    let _e1683 = _o_nY_4;
                    let _e1684 = _o_beta_4;
                    let _e1693 = global.U[0];
                    let _e1696 = _o_alpha_4;
                    let _e1702 = _o_nX_4;
                    let _e1705 = _o_nY_4;
                    let _e1706 = _o_beta_4;
                    let _e1720 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1674) / 3.1415927f) * 0.5f) * _e1680), (0.5f + ((_e1683 * _e1684) / 3.1415927f))).x / _e1693.x), vec2<f32>((((-(_e1696) / 3.1415927f) * 0.5f) * _e1702), (0.5f + ((_e1705 * _e1706) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e1720;
                }
            } else {
                let _e1721 = backgroundStyle_1;
                if (_e1721 == 1i) {
                    {
                        let _e1724 = camDir;
                        let _e1727 = camDir;
                        let _e1730 = camDir;
                        let _e1733 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1724.x) / _e1727.z), (-(_e1730.y) / _e1733.z)) * 1f);
                        let _e1740 = _o_pos_4;
                        let _e1743 = _o_pos_4;
                        _o_m_4 = max(abs(_e1740.x), abs(_e1743.y));
                        let _e1750 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1750));
                        let _e1754 = _o_pos_4;
                        let _e1758 = global.U[0];
                        let _e1761 = _o_pos_4;
                        let _e1770 = textureSample(t_source, samp, ((vec2<f32>((_e1754.x / _e1758.x), _e1761.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1771 = _o_darken_4;
                        let _e1772 = _o_darken_4;
                        let _e1773 = _o_darken_4;
                        col = (_e1770 * vec4<f32>(_e1771, _e1772, _e1773, 1f));
                    }
                } else {
                    let _e1777 = backgroundStyle_1;
                    if (_e1777 == 2i) {
                        {
                            let _e1780 = sourceDim_1;
                            let _e1782 = sourceDim_1;
                            _o_ratio_9 = (_e1780.y / _e1782.x);
                            let _e1790 = camDir;
                            let _e1793 = camDir;
                            let _e1796 = _o_ratio_9;
                            let _e1799 = camDir;
                            let _e1802 = camDir;
                            let _e1805 = _o_ratio_9;
                            if ((abs(_e1790.y) > (abs(_e1793.z) * _e1796)) && (abs(_e1799.y) > (abs(_e1802.x) * _e1805))) {
                                {
                                    let _e1809 = _o_X_4;
                                    let _e1810 = camDir;
                                    let _e1813 = camDir;
                                    _o_X_4 = (_e1809 + ((-(_e1810.x) / _e1813.y) * 0.5f));
                                    let _e1819 = _o_Y_4;
                                    let _e1820 = camDir;
                                    let _e1823 = camDir;
                                    _o_Y_4 = (_e1819 + ((-(_e1820.z) / _e1823.y) * 0.5f));
                                }
                            } else {
                                let _e1829 = camDir;
                                let _e1832 = camDir;
                                if (abs(_e1829.x) < abs(_e1832.z)) {
                                    {
                                        let _e1836 = _o_X_4;
                                        let _e1837 = camDir;
                                        let _e1839 = camDir;
                                        let _e1843 = _o_ratio_9;
                                        let _e1847 = camDir;
                                        _o_X_4 = (_e1836 + ((((_e1837.x / abs(_e1839.z)) * _e1843) * 0.5f) * -(sign(_e1847.z))));
                                        let _e1853 = _o_Y_4;
                                        let _e1854 = camDir;
                                        let _e1856 = camDir;
                                        _o_Y_4 = (_e1853 + ((_e1854.y / abs(_e1856.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1863 = _o_X_4;
                                        let _e1864 = camDir;
                                        let _e1866 = camDir;
                                        let _e1870 = _o_ratio_9;
                                        let _e1874 = camDir;
                                        _o_X_4 = (_e1863 + ((((_e1864.z / abs(_e1866.x)) * _e1870) * 0.5f) * -(sign(_e1874.x))));
                                        let _e1880 = _o_Y_4;
                                        let _e1881 = camDir;
                                        let _e1883 = camDir;
                                        _o_Y_4 = (_e1880 + ((_e1881.y / abs(_e1883.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1890 = _o_X_4;
                            let _e1891 = _o_Y_4;
                            let _e1896 = global.U[0];
                            let _e1899 = _o_X_4;
                            let _e1900 = _o_Y_4;
                            let _e1910 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1890, _e1891).x / _e1896.x), vec2<f32>(_e1899, _e1900).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1910;
                        }
                    } else {
                        {
                            let _e1911 = camDir;
                            let _e1916 = ((_e1911 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1916.x, _e1916.y, _e1916.z, 1f);
                        }
                    }
                }
            }
            let _e1922 = colorFog_1;
            if (_e1922.w != 0f) {
                let _e1926 = color;
                let _e1928 = colorFog_1;
                let _e1929 = _e1928.xyz;
                color.x = _e1929.x;
                color.y = _e1929.y;
                color.z = _e1929.z;
            } else {
                let _e1936 = col;
                color = _e1936;
            }
        }
    }
    let _e1937 = color;
    return clamp(_e1937, vec4(0f), vec4(1f));
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
    let _e140 = global.U[16];
    let _e143 = global.U[17];
    let _e146 = global.U[18];
    let _e170 = global.U[19];
    let _e173 = global.U[20];
    let _e176 = global.U[21];
    let _e179 = global.U[22];
    let _e203 = global.U[23];
    let _e206 = global.U[24];
    let _e210 = global.U[25];
    let _e214 = global.U[26];
    let _e218 = global.U[27];
    let _e221 = global.U[28];
    let _e224 = global.U[29];
    let _e227 = global.U[30];
    let _e231 = global.U[31];
    let _e236 = global.U[32];
    let _e238 = rayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)), mat4x4<f32>(vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w)), _e203, _e206.x, _e210.x, _e214.x, _e218, _e221, _e224, _e227.x, i32(_e231.x), _e236.x);
    fragColor = _e238;
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
