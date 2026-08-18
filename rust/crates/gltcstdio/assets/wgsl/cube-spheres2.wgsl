struct Params {
    U: array<vec4<f32>, 32>,
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

fn sdBox(p: vec3<f32>, b: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var b_1: vec3<f32>;
    var q: vec3<f32>;

    p_1 = p;
    b_1 = b;
    let _e11 = p_1;
    let _e13 = b_1;
    q = (abs(_e11) - _e13);
    let _e16 = q;
    let _e21 = q;
    let _e23 = q;
    let _e25 = q;
    return (length(max(_e16, vec3(0f))) + min(max(_e21.x, max(_e23.y, _e25.z)), 0f));
}

fn sdf(p_2: vec3<f32>) -> f32 {
    var p_3: vec3<f32>;

    p_3 = p_2;
    let _e9 = p_3;
    let _e12 = sdBox(_e9, vec3(0.5f));
    let _e13 = p_3;
    let _e25 = p_3;
    let _e32 = sdBox((abs(_e25) - vec3(0.5f)), vec3(0.2f));
    return min(_e12, min((length((abs((abs(_e13) - vec3(0.5f))) - vec3(0.2f))) - 0.1f), _e32));
}

fn normal(p_4: vec3<f32>) -> vec3<f32> {
    var p_5: vec3<f32>;
    var d: f32 = 0.0001f;
    var s: f32;

    p_5 = p_4;
    let _e11 = p_5;
    let _e12 = sdf(_e11);
    s = _e12;
    let _e14 = s;
    let _e15 = p_5;
    let _e17 = d;
    let _e19 = p_5;
    let _e21 = p_5;
    let _e24 = sdf(vec3<f32>((_e15.x - _e17), _e19.y, _e21.z));
    let _e26 = d;
    let _e28 = s;
    let _e29 = p_5;
    let _e31 = p_5;
    let _e33 = d;
    let _e35 = p_5;
    let _e38 = sdf(vec3<f32>(_e29.x, (_e31.y - _e33), _e35.z));
    let _e40 = d;
    let _e42 = s;
    let _e43 = p_5;
    let _e45 = p_5;
    let _e47 = p_5;
    let _e49 = d;
    let _e52 = sdf(vec3<f32>(_e43.x, _e45.y, (_e47.z - _e49)));
    let _e54 = d;
    return normalize(vec3<f32>(((_e14 - _e24) / _e26), ((_e28 - _e38) / _e40), ((_e42 - _e52) / _e54)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var d_1: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_6: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    let _e13 = p0_1;
    let _e14 = sdf(_e13);
    d_1 = _e14;
    let _e16 = d_1;
    s_1 = sign(_e16);
    loop {
        let _e23 = step;
        let _e26 = d_1;
        if !(((_e23 < 1000i) && (_e26 < 100f))) {
            break;
        }
        {
            let _e31 = totalD;
            let _e32 = d_1;
            let _e33 = side_1;
            totalD = (_e31 + (_e32 * _e33));
            let _e36 = p0_1;
            let _e37 = totalD;
            let _e38 = dir_1;
            p_6 = (_e36 + (_e37 * _e38));
            let _e42 = p_6;
            let _e43 = sdf(_e42);
            d_1 = _e43;
            let _e44 = d_1;
            if (abs(_e44) < 0.0001f) {
                let _e48 = p_6;
                return _e48;
            }
            let _e49 = step;
            step = (_e49 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32) -> vec4<f32> {
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
    let _e46 = camera3DTransform_1;
    let _e47 = camera_2;
    camera_2 = (_e46 * vec4<f32>(_e47.x, _e47.y, _e47.z, 1f)).xyz;
    let _e58 = uv_3;
    let _e59 = camera_2;
    let _e60 = target_2;
    let _e62 = getRay(_e58, _e59, _e60, 1f);
    camDir = _e62;
    let _e64 = lightSourceTransform_1;
    lightPos = (_e64 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e73 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e73);
    let _e76 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e76[0].xyz, _e76[1].xyz, _e76[2].xyz);
    let _e87 = invModelTransform;
    let _e88 = camera_2;
    camera_2 = (_e87 * vec4<f32>(_e88.x, _e88.y, _e88.z, 1f)).xyz;
    let _e96 = uv_3;
    let _e98 = D;
    let _e100 = uv_3;
    let _e102 = D;
    dir_2 = normalize(vec3<f32>((_e96.x * _e98), (_e100.y * _e102), -1f));
    let _e109 = camera3DTransform_1;
    let _e119 = dir_2;
    dir_2 = (mat3x3<f32>(_e109[0].xyz, _e109[1].xyz, _e109[2].xyz) * _e119);
    let _e121 = invModelTransform;
    let _e131 = dir_2;
    camDir = normalize((mat3x3<f32>(_e121[0].xyz, _e121[1].xyz, _e121[2].xyz) * _e131));
    let _e146 = camera_2;
    let _e147 = camDir;
    let _e149 = rayMarch(_e146, _e147, 1f);
    qIn = _e149;
    let _e151 = camDir;
    reflectDir = _e151;
    let _e156 = refractionIndex_1;
    ref_ = _e156;
    let _e158 = chromaticAberration_1;
    chromaticAbb = _e158;
    let _e164 = colorMaterial_1;
    let _e168 = colorMaterial_1;
    absorption = pow(mix(30f, 1000f, smoothstep(0.95f, 1f, _e164.w)), _e168.w);
    let _e172 = qIn;
    if (_e172.x != 100000000000000000000f) {
        {
            let _e176 = qIn;
            let _e177 = normal(_e176);
            nIn = _e177;
            let _e179 = nIn;
            let _e180 = camDir;
            incidence = abs(dot(_e179, _e180));
            let _e185 = incidence;
            let _e188 = fresnelStrength_1;
            let _e195 = fresnelStrength_1;
            let _e200 = fresnelStrength_1;
            fresnel = ((pow((1f - _e185), (6f - (_e188 * 6f))) * smoothstep(0f, 0.025f, _e195)) * smoothstep(0f, 0.025f, _e200));
            let _e204 = camDir;
            let _e205 = nIn;
            reflectDir = reflect(_e204, _e205);
            let _e209 = colorMaterial_1;
            reflectivity = (vec3(1f) - _e209.xyz);
            let _e213 = reflectivity;
            reflectK = _e213;
            let _e214 = qIn;
            let _e215 = lightPos;
            lightDir = normalize((_e214 - _e215));
            let _e219 = fresnel;
            if (_e219 != 1f) {
                {
                    let _e224 = ref_;
                    let _e225 = ref_;
                    let _e228 = nIn;
                    let _e229 = camDir;
                    let _e231 = nIn;
                    let _e232 = camDir;
                    k = (1f - ((_e224 * _e225) * (1f - (dot(_e228, _e229) * dot(_e231, _e232)))));
                    let _e239 = k;
                    if (_e239 < 0f) {
                        refractDir = vec3(0f);
                    } else {
                        let _e244 = ref_;
                        let _e245 = camDir;
                        let _e247 = ref_;
                        let _e248 = nIn;
                        let _e249 = camDir;
                        let _e252 = k;
                        let _e255 = nIn;
                        refractDir = ((_e244 * _e245) - (((_e247 * dot(_e248, _e249)) + sqrt(_e252)) * _e255));
                    }
                    let _e258 = qIn;
                    let _e259 = nIn;
                    let _e263 = refractDir;
                    let _e266 = rayMarch((_e258 - (_e259 * 0.001f)), _e263, -1f);
                    qOut = _e266;
                    let _e268 = qOut;
                    let _e269 = normal(_e268);
                    n = -(_e269);
                    let _e272 = refractDir;
                    let _e273 = n;
                    let _e275 = ref_;
                    let _e277 = chromaticAbb;
                    rDir = refract(_e272, _e273, ((1f / _e275) - _e277));
                    let _e281 = rDir;
                    if (length(_e281) == 0f) {
                        let _e285 = refractDir;
                        let _e286 = n;
                        local = reflect(_e285, _e286);
                    } else {
                        let _e288 = rDir;
                        local = _e288;
                    }
                    let _e290 = local;
                    refractDirR = _e290;
                    let _e292 = refractDir;
                    let _e293 = n;
                    let _e295 = ref_;
                    gDir = refract(_e292, _e293, (1f / _e295));
                    let _e299 = gDir;
                    if (length(_e299) == 0f) {
                        let _e303 = refractDir;
                        let _e304 = n;
                        local_1 = reflect(_e303, _e304);
                    } else {
                        let _e306 = gDir;
                        local_1 = _e306;
                    }
                    let _e308 = local_1;
                    refractDirG = _e308;
                    let _e310 = refractDir;
                    let _e311 = n;
                    let _e313 = ref_;
                    let _e315 = chromaticAbb;
                    bDir = refract(_e310, _e311, ((1f / _e313) + _e315));
                    let _e319 = bDir;
                    if (length(_e319) == 0f) {
                        let _e323 = refractDir;
                        let _e324 = n;
                        local_2 = reflect(_e323, _e324);
                    } else {
                        let _e326 = bDir;
                        local_2 = _e326;
                    }
                    let _e328 = local_2;
                    refractDirB = _e328;
                    let _e333 = model3DTransform3_;
                    let _e334 = refractDirR;
                    refractDirR = (_e333 * _e334);
                    let _e336 = model3DTransform3_;
                    let _e337 = refractDirG;
                    refractDirG = (_e336 * _e337);
                    let _e339 = model3DTransform3_;
                    let _e340 = refractDirB;
                    refractDirB = (_e339 * _e340);
                    let _e342 = backgroundStyle_1;
                    if (_e342 == 0i) {
                        {
                            let _e345 = refractDirR;
                            _o_n = normalize(_e345);
                            let _e348 = _o_n;
                            let _e350 = _o_n;
                            _o_alpha = atan2(_e348.z, _e350.x);
                            let _e354 = _o_n;
                            _o_beta = asin(_e354.y);
                            let _e358 = sourceDim_1;
                            let _e360 = sourceDim_1;
                            _o_ratio = (_e358.x / _e360.y);
                            let _e368 = _o_alpha;
                            let _e374 = _o_nX;
                            let _e377 = _o_nY;
                            let _e378 = _o_beta;
                            let _e387 = global.U[0];
                            let _e390 = _o_alpha;
                            let _e396 = _o_nX;
                            let _e399 = _o_nY;
                            let _e400 = _o_beta;
                            let _e414 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e368) / 3.1415927f) * 0.5f) * _e374), (0.5f + ((_e377 * _e378) / 3.1415927f))).x / _e387.x), vec2<f32>((((-(_e390) / 3.1415927f) * 0.5f) * _e396), (0.5f + ((_e399 * _e400) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colR = _e414;
                        }
                    } else {
                        let _e415 = backgroundStyle_1;
                        if (_e415 == 1i) {
                            {
                                let _e418 = refractDirR;
                                let _e421 = refractDirR;
                                let _e424 = refractDirR;
                                let _e427 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e418.x) / _e421.z), (-(_e424.y) / _e427.z)) * 1f);
                                let _e434 = _o_pos;
                                let _e437 = _o_pos;
                                _o_m = max(abs(_e434.x), abs(_e437.y));
                                let _e444 = _o_m;
                                _o_darken = (4f / max(4f, _e444));
                                let _e448 = _o_pos;
                                let _e452 = global.U[0];
                                let _e455 = _o_pos;
                                let _e464 = textureSample(t_source, samp, ((vec2<f32>((_e448.x / _e452.x), _e455.y) / vec2(2f)) + vec2(0.5f)));
                                let _e465 = _o_darken;
                                let _e466 = _o_darken;
                                let _e467 = _o_darken;
                                colR = (_e464 * vec4<f32>(_e465, _e466, _e467, 1f));
                            }
                        } else {
                            let _e471 = backgroundStyle_1;
                            if (_e471 == 2i) {
                                {
                                    let _e474 = sourceDim_1;
                                    let _e476 = sourceDim_1;
                                    _o_ratio_1 = (_e474.y / _e476.x);
                                    let _e484 = refractDirR;
                                    let _e487 = refractDirR;
                                    let _e490 = _o_ratio_1;
                                    let _e493 = refractDirR;
                                    let _e496 = refractDirR;
                                    let _e499 = _o_ratio_1;
                                    if ((abs(_e484.y) > (abs(_e487.z) * _e490)) && (abs(_e493.y) > (abs(_e496.x) * _e499))) {
                                        {
                                            let _e503 = _o_X;
                                            let _e504 = refractDirR;
                                            let _e507 = refractDirR;
                                            _o_X = (_e503 + ((-(_e504.x) / _e507.y) * 0.5f));
                                            let _e513 = _o_Y;
                                            let _e514 = refractDirR;
                                            let _e517 = refractDirR;
                                            _o_Y = (_e513 + ((-(_e514.z) / _e517.y) * 0.5f));
                                        }
                                    } else {
                                        let _e523 = refractDirR;
                                        let _e526 = refractDirR;
                                        if (abs(_e523.x) < abs(_e526.z)) {
                                            {
                                                let _e530 = _o_X;
                                                let _e531 = refractDirR;
                                                let _e533 = refractDirR;
                                                let _e537 = _o_ratio_1;
                                                let _e541 = refractDirR;
                                                _o_X = (_e530 + ((((_e531.x / abs(_e533.z)) * _e537) * 0.5f) * -(sign(_e541.z))));
                                                let _e547 = _o_Y;
                                                let _e548 = refractDirR;
                                                let _e550 = refractDirR;
                                                _o_Y = (_e547 + ((_e548.y / abs(_e550.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e557 = _o_X;
                                                let _e558 = refractDirR;
                                                let _e560 = refractDirR;
                                                let _e564 = _o_ratio_1;
                                                let _e568 = refractDirR;
                                                _o_X = (_e557 + ((((_e558.z / abs(_e560.x)) * _e564) * 0.5f) * -(sign(_e568.x))));
                                                let _e574 = _o_Y;
                                                let _e575 = refractDirR;
                                                let _e577 = refractDirR;
                                                _o_Y = (_e574 + ((_e575.y / abs(_e577.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e584 = _o_X;
                                    let _e585 = _o_Y;
                                    let _e590 = global.U[0];
                                    let _e593 = _o_X;
                                    let _e594 = _o_Y;
                                    let _e604 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e584, _e585).x / _e590.x), vec2<f32>(_e593, _e594).y) / vec2(2f)) + vec2(0.5f)));
                                    colR = _e604;
                                }
                            } else {
                                {
                                    let _e605 = refractDirR;
                                    let _e610 = ((_e605 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e610.x, _e610.y, _e610.z, 1f);
                                }
                            }
                        }
                    }
                    let _e616 = backgroundStyle_1;
                    if (_e616 == 0i) {
                        {
                            let _e619 = refractDirG;
                            _o_n_1 = normalize(_e619);
                            let _e622 = _o_n_1;
                            let _e624 = _o_n_1;
                            _o_alpha_1 = atan2(_e622.z, _e624.x);
                            let _e628 = _o_n_1;
                            _o_beta_1 = asin(_e628.y);
                            let _e632 = sourceDim_1;
                            let _e634 = sourceDim_1;
                            _o_ratio_2 = (_e632.x / _e634.y);
                            let _e642 = _o_alpha_1;
                            let _e648 = _o_nX_1;
                            let _e651 = _o_nY_1;
                            let _e652 = _o_beta_1;
                            let _e661 = global.U[0];
                            let _e664 = _o_alpha_1;
                            let _e670 = _o_nX_1;
                            let _e673 = _o_nY_1;
                            let _e674 = _o_beta_1;
                            let _e688 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e642) / 3.1415927f) * 0.5f) * _e648), (0.5f + ((_e651 * _e652) / 3.1415927f))).x / _e661.x), vec2<f32>((((-(_e664) / 3.1415927f) * 0.5f) * _e670), (0.5f + ((_e673 * _e674) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colG = _e688;
                        }
                    } else {
                        let _e689 = backgroundStyle_1;
                        if (_e689 == 1i) {
                            {
                                let _e692 = refractDirG;
                                let _e695 = refractDirG;
                                let _e698 = refractDirG;
                                let _e701 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e692.x) / _e695.z), (-(_e698.y) / _e701.z)) * 1f);
                                let _e708 = _o_pos_1;
                                let _e711 = _o_pos_1;
                                _o_m_1 = max(abs(_e708.x), abs(_e711.y));
                                let _e718 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e718));
                                let _e722 = _o_pos_1;
                                let _e726 = global.U[0];
                                let _e729 = _o_pos_1;
                                let _e738 = textureSample(t_source, samp, ((vec2<f32>((_e722.x / _e726.x), _e729.y) / vec2(2f)) + vec2(0.5f)));
                                let _e739 = _o_darken_1;
                                let _e740 = _o_darken_1;
                                let _e741 = _o_darken_1;
                                colG = (_e738 * vec4<f32>(_e739, _e740, _e741, 1f));
                            }
                        } else {
                            let _e745 = backgroundStyle_1;
                            if (_e745 == 2i) {
                                {
                                    let _e748 = sourceDim_1;
                                    let _e750 = sourceDim_1;
                                    _o_ratio_3 = (_e748.y / _e750.x);
                                    let _e758 = refractDirG;
                                    let _e761 = refractDirG;
                                    let _e764 = _o_ratio_3;
                                    let _e767 = refractDirG;
                                    let _e770 = refractDirG;
                                    let _e773 = _o_ratio_3;
                                    if ((abs(_e758.y) > (abs(_e761.z) * _e764)) && (abs(_e767.y) > (abs(_e770.x) * _e773))) {
                                        {
                                            let _e777 = _o_X_1;
                                            let _e778 = refractDirG;
                                            let _e781 = refractDirG;
                                            _o_X_1 = (_e777 + ((-(_e778.x) / _e781.y) * 0.5f));
                                            let _e787 = _o_Y_1;
                                            let _e788 = refractDirG;
                                            let _e791 = refractDirG;
                                            _o_Y_1 = (_e787 + ((-(_e788.z) / _e791.y) * 0.5f));
                                        }
                                    } else {
                                        let _e797 = refractDirG;
                                        let _e800 = refractDirG;
                                        if (abs(_e797.x) < abs(_e800.z)) {
                                            {
                                                let _e804 = _o_X_1;
                                                let _e805 = refractDirG;
                                                let _e807 = refractDirG;
                                                let _e811 = _o_ratio_3;
                                                let _e815 = refractDirG;
                                                _o_X_1 = (_e804 + ((((_e805.x / abs(_e807.z)) * _e811) * 0.5f) * -(sign(_e815.z))));
                                                let _e821 = _o_Y_1;
                                                let _e822 = refractDirG;
                                                let _e824 = refractDirG;
                                                _o_Y_1 = (_e821 + ((_e822.y / abs(_e824.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e831 = _o_X_1;
                                                let _e832 = refractDirG;
                                                let _e834 = refractDirG;
                                                let _e838 = _o_ratio_3;
                                                let _e842 = refractDirG;
                                                _o_X_1 = (_e831 + ((((_e832.z / abs(_e834.x)) * _e838) * 0.5f) * -(sign(_e842.x))));
                                                let _e848 = _o_Y_1;
                                                let _e849 = refractDirG;
                                                let _e851 = refractDirG;
                                                _o_Y_1 = (_e848 + ((_e849.y / abs(_e851.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e858 = _o_X_1;
                                    let _e859 = _o_Y_1;
                                    let _e864 = global.U[0];
                                    let _e867 = _o_X_1;
                                    let _e868 = _o_Y_1;
                                    let _e878 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e858, _e859).x / _e864.x), vec2<f32>(_e867, _e868).y) / vec2(2f)) + vec2(0.5f)));
                                    colG = _e878;
                                }
                            } else {
                                {
                                    let _e879 = refractDirG;
                                    let _e884 = ((_e879 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e884.x, _e884.y, _e884.z, 1f);
                                }
                            }
                        }
                    }
                    let _e890 = backgroundStyle_1;
                    if (_e890 == 0i) {
                        {
                            let _e893 = refractDirB;
                            _o_n_2 = normalize(_e893);
                            let _e896 = _o_n_2;
                            let _e898 = _o_n_2;
                            _o_alpha_2 = atan2(_e896.z, _e898.x);
                            let _e902 = _o_n_2;
                            _o_beta_2 = asin(_e902.y);
                            let _e906 = sourceDim_1;
                            let _e908 = sourceDim_1;
                            _o_ratio_4 = (_e906.x / _e908.y);
                            let _e916 = _o_alpha_2;
                            let _e922 = _o_nX_2;
                            let _e925 = _o_nY_2;
                            let _e926 = _o_beta_2;
                            let _e935 = global.U[0];
                            let _e938 = _o_alpha_2;
                            let _e944 = _o_nX_2;
                            let _e947 = _o_nY_2;
                            let _e948 = _o_beta_2;
                            let _e962 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e916) / 3.1415927f) * 0.5f) * _e922), (0.5f + ((_e925 * _e926) / 3.1415927f))).x / _e935.x), vec2<f32>((((-(_e938) / 3.1415927f) * 0.5f) * _e944), (0.5f + ((_e947 * _e948) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colB = _e962;
                        }
                    } else {
                        let _e963 = backgroundStyle_1;
                        if (_e963 == 1i) {
                            {
                                let _e966 = refractDirB;
                                let _e969 = refractDirB;
                                let _e972 = refractDirB;
                                let _e975 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e966.x) / _e969.z), (-(_e972.y) / _e975.z)) * 1f);
                                let _e982 = _o_pos_2;
                                let _e985 = _o_pos_2;
                                _o_m_2 = max(abs(_e982.x), abs(_e985.y));
                                let _e992 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e992));
                                let _e996 = _o_pos_2;
                                let _e1000 = global.U[0];
                                let _e1003 = _o_pos_2;
                                let _e1012 = textureSample(t_source, samp, ((vec2<f32>((_e996.x / _e1000.x), _e1003.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1013 = _o_darken_2;
                                let _e1014 = _o_darken_2;
                                let _e1015 = _o_darken_2;
                                colB = (_e1012 * vec4<f32>(_e1013, _e1014, _e1015, 1f));
                            }
                        } else {
                            let _e1019 = backgroundStyle_1;
                            if (_e1019 == 2i) {
                                {
                                    let _e1022 = sourceDim_1;
                                    let _e1024 = sourceDim_1;
                                    _o_ratio_5 = (_e1022.y / _e1024.x);
                                    let _e1032 = refractDirB;
                                    let _e1035 = refractDirB;
                                    let _e1038 = _o_ratio_5;
                                    let _e1041 = refractDirB;
                                    let _e1044 = refractDirB;
                                    let _e1047 = _o_ratio_5;
                                    if ((abs(_e1032.y) > (abs(_e1035.z) * _e1038)) && (abs(_e1041.y) > (abs(_e1044.x) * _e1047))) {
                                        {
                                            let _e1051 = _o_X_2;
                                            let _e1052 = refractDirB;
                                            let _e1055 = refractDirB;
                                            _o_X_2 = (_e1051 + ((-(_e1052.x) / _e1055.y) * 0.5f));
                                            let _e1061 = _o_Y_2;
                                            let _e1062 = refractDirB;
                                            let _e1065 = refractDirB;
                                            _o_Y_2 = (_e1061 + ((-(_e1062.z) / _e1065.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1071 = refractDirB;
                                        let _e1074 = refractDirB;
                                        if (abs(_e1071.x) < abs(_e1074.z)) {
                                            {
                                                let _e1078 = _o_X_2;
                                                let _e1079 = refractDirB;
                                                let _e1081 = refractDirB;
                                                let _e1085 = _o_ratio_5;
                                                let _e1089 = refractDirB;
                                                _o_X_2 = (_e1078 + ((((_e1079.x / abs(_e1081.z)) * _e1085) * 0.5f) * -(sign(_e1089.z))));
                                                let _e1095 = _o_Y_2;
                                                let _e1096 = refractDirB;
                                                let _e1098 = refractDirB;
                                                _o_Y_2 = (_e1095 + ((_e1096.y / abs(_e1098.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1105 = _o_X_2;
                                                let _e1106 = refractDirB;
                                                let _e1108 = refractDirB;
                                                let _e1112 = _o_ratio_5;
                                                let _e1116 = refractDirB;
                                                _o_X_2 = (_e1105 + ((((_e1106.z / abs(_e1108.x)) * _e1112) * 0.5f) * -(sign(_e1116.x))));
                                                let _e1122 = _o_Y_2;
                                                let _e1123 = refractDirB;
                                                let _e1125 = refractDirB;
                                                _o_Y_2 = (_e1122 + ((_e1123.y / abs(_e1125.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1132 = _o_X_2;
                                    let _e1133 = _o_Y_2;
                                    let _e1138 = global.U[0];
                                    let _e1141 = _o_X_2;
                                    let _e1142 = _o_Y_2;
                                    let _e1152 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1132, _e1133).x / _e1138.x), vec2<f32>(_e1141, _e1142).y) / vec2(2f)) + vec2(0.5f)));
                                    colB = _e1152;
                                }
                            } else {
                                {
                                    let _e1153 = refractDirB;
                                    let _e1158 = ((_e1153 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1158.x, _e1158.y, _e1158.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1164 = colR;
                    let _e1166 = colG;
                    let _e1168 = colB;
                    col = vec4<f32>(_e1164.x, _e1166.y, _e1168.z, 1f);
                    let _e1174 = absorption;
                    let _e1175 = qIn;
                    let _e1176 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1174 * length((_e1175 - _e1176)))));
                    let _e1184 = absorbed;
                    let _e1187 = colorMaterial_1;
                    absorbed = mix(0f, _e1184, smoothstep(0f, 0.1f, _e1187.w));
                    let _e1191 = color;
                    let _e1193 = color;
                    let _e1195 = colorMaterial_1;
                    let _e1198 = fresnel;
                    let _e1202 = absorbed;
                    let _e1205 = col;
                    let _e1208 = (_e1193.xyz + (((_e1195.xyz * (1f - _e1198)) * (1f - _e1202)) * _e1205.xyz));
                    color.x = _e1208.x;
                    color.y = _e1208.y;
                    color.z = _e1208.z;
                    let _e1215 = color;
                    let _e1217 = color;
                    let _e1219 = absorbed;
                    let _e1220 = colorMaterial_1;
                    let _e1223 = ambientColor_1;
                    let _e1226 = nIn;
                    let _e1227 = lightDir;
                    let _e1230 = sourceColor_1;
                    let _e1235 = (_e1217.xyz + ((_e1219 * _e1220.xyz) * (_e1223.xyz + (max(0f, dot(_e1226, _e1227)) * _e1230.xyz))));
                    color.x = _e1235.x;
                    color.y = _e1235.y;
                    color.z = _e1235.z;
                }
            }
            let _e1242 = fresnel;
            let _e1245 = specular_1;
            if ((_e1242 != 0f) || (_e1245 != 0f)) {
                {
                    let _e1249 = reflectDir;
                    origReflectDir = _e1249;
                    let _e1251 = qIn;
                    let _e1252 = nIn;
                    let _e1256 = reflectDir;
                    let _e1258 = rayMarch((_e1251 + (_e1252 * 0.001f)), _e1256, 1f);
                    qR = _e1258;
                    let _e1260 = qR;
                    if (_e1260.x != 100000000000000000000f) {
                        {
                            let _e1264 = qR;
                            let _e1265 = normal(_e1264);
                            n_1 = _e1265;
                            let _e1267 = reflectDir;
                            let _e1268 = n_1;
                            reflectDir = reflect(_e1267, _e1268);
                        }
                    }
                    let _e1270 = model3DTransform3_;
                    let _e1271 = reflectDir;
                    reflectDir = (_e1270 * _e1271);
                    let _e1273 = backgroundStyle_1;
                    if (_e1273 == 0i) {
                        {
                            let _e1276 = reflectDir;
                            _o_n_3 = normalize(_e1276);
                            let _e1279 = _o_n_3;
                            let _e1281 = _o_n_3;
                            _o_alpha_3 = atan2(_e1279.z, _e1281.x);
                            let _e1285 = _o_n_3;
                            _o_beta_3 = asin(_e1285.y);
                            let _e1289 = sourceDim_1;
                            let _e1291 = sourceDim_1;
                            _o_ratio_6 = (_e1289.x / _e1291.y);
                            let _e1299 = _o_alpha_3;
                            let _e1305 = _o_nX_3;
                            let _e1308 = _o_nY_3;
                            let _e1309 = _o_beta_3;
                            let _e1318 = global.U[0];
                            let _e1321 = _o_alpha_3;
                            let _e1327 = _o_nX_3;
                            let _e1330 = _o_nY_3;
                            let _e1331 = _o_beta_3;
                            let _e1345 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1299) / 3.1415927f) * 0.5f) * _e1305), (0.5f + ((_e1308 * _e1309) / 3.1415927f))).x / _e1318.x), vec2<f32>((((-(_e1321) / 3.1415927f) * 0.5f) * _e1327), (0.5f + ((_e1330 * _e1331) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1345;
                        }
                    } else {
                        let _e1346 = backgroundStyle_1;
                        if (_e1346 == 1i) {
                            {
                                let _e1349 = reflectDir;
                                let _e1352 = reflectDir;
                                let _e1355 = reflectDir;
                                let _e1358 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1349.x) / _e1352.z), (-(_e1355.y) / _e1358.z)) * 1f);
                                let _e1365 = _o_pos_3;
                                let _e1368 = _o_pos_3;
                                _o_m_3 = max(abs(_e1365.x), abs(_e1368.y));
                                let _e1375 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1375));
                                let _e1379 = _o_pos_3;
                                let _e1383 = global.U[0];
                                let _e1386 = _o_pos_3;
                                let _e1395 = textureSample(t_source, samp, ((vec2<f32>((_e1379.x / _e1383.x), _e1386.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1396 = _o_darken_3;
                                let _e1397 = _o_darken_3;
                                let _e1398 = _o_darken_3;
                                col = (_e1395 * vec4<f32>(_e1396, _e1397, _e1398, 1f));
                            }
                        } else {
                            let _e1402 = backgroundStyle_1;
                            if (_e1402 == 2i) {
                                {
                                    let _e1405 = sourceDim_1;
                                    let _e1407 = sourceDim_1;
                                    _o_ratio_7 = (_e1405.y / _e1407.x);
                                    let _e1415 = reflectDir;
                                    let _e1418 = reflectDir;
                                    let _e1421 = _o_ratio_7;
                                    let _e1424 = reflectDir;
                                    let _e1427 = reflectDir;
                                    let _e1430 = _o_ratio_7;
                                    if ((abs(_e1415.y) > (abs(_e1418.z) * _e1421)) && (abs(_e1424.y) > (abs(_e1427.x) * _e1430))) {
                                        {
                                            let _e1434 = _o_X_3;
                                            let _e1435 = reflectDir;
                                            let _e1438 = reflectDir;
                                            _o_X_3 = (_e1434 + ((-(_e1435.x) / _e1438.y) * 0.5f));
                                            let _e1444 = _o_Y_3;
                                            let _e1445 = reflectDir;
                                            let _e1448 = reflectDir;
                                            _o_Y_3 = (_e1444 + ((-(_e1445.z) / _e1448.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1454 = reflectDir;
                                        let _e1457 = reflectDir;
                                        if (abs(_e1454.x) < abs(_e1457.z)) {
                                            {
                                                let _e1461 = _o_X_3;
                                                let _e1462 = reflectDir;
                                                let _e1464 = reflectDir;
                                                let _e1468 = _o_ratio_7;
                                                let _e1472 = reflectDir;
                                                _o_X_3 = (_e1461 + ((((_e1462.x / abs(_e1464.z)) * _e1468) * 0.5f) * -(sign(_e1472.z))));
                                                let _e1478 = _o_Y_3;
                                                let _e1479 = reflectDir;
                                                let _e1481 = reflectDir;
                                                _o_Y_3 = (_e1478 + ((_e1479.y / abs(_e1481.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1488 = _o_X_3;
                                                let _e1489 = reflectDir;
                                                let _e1491 = reflectDir;
                                                let _e1495 = _o_ratio_7;
                                                let _e1499 = reflectDir;
                                                _o_X_3 = (_e1488 + ((((_e1489.z / abs(_e1491.x)) * _e1495) * 0.5f) * -(sign(_e1499.x))));
                                                let _e1505 = _o_Y_3;
                                                let _e1506 = reflectDir;
                                                let _e1508 = reflectDir;
                                                _o_Y_3 = (_e1505 + ((_e1506.y / abs(_e1508.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1515 = _o_X_3;
                                    let _e1516 = _o_Y_3;
                                    let _e1521 = global.U[0];
                                    let _e1524 = _o_X_3;
                                    let _e1525 = _o_Y_3;
                                    let _e1535 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1515, _e1516).x / _e1521.x), vec2<f32>(_e1524, _e1525).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e1535;
                                }
                            } else {
                                {
                                    let _e1536 = reflectDir;
                                    let _e1541 = ((_e1536 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1541.x, _e1541.y, _e1541.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1547 = color;
                    let _e1549 = color;
                    let _e1551 = fresnel;
                    let _e1552 = col;
                    let _e1555 = (_e1549.xyz + (_e1551 * _e1552.xyz));
                    color.x = _e1555.x;
                    color.y = _e1555.y;
                    color.z = _e1555.z;
                    let _e1563 = specular_1;
                    let _e1566 = lightDir;
                    let _e1567 = origReflectDir;
                    kSpec = ((10f * _e1563) * pow(max(0f, dot(_e1566, _e1567)), 9f));
                    let _e1574 = color;
                    let _e1576 = color;
                    let _e1578 = sourceColor_1;
                    let _e1580 = kSpec;
                    let _e1582 = (_e1576.xyz + (_e1578.xyz * _e1580));
                    color.x = _e1582.x;
                    color.y = _e1582.y;
                    color.z = _e1582.z;
                }
            }
            let _e1589 = colorFog_1;
            if (_e1589.w != 0f) {
                {
                    let _e1593 = camera_2;
                    let _e1594 = qIn;
                    dist = length((_e1593 - _e1594));
                    let _e1600 = colorFog_1;
                    let _e1603 = dist;
                    kFog = (1f - pow(0.4f, (_e1600.w * max(0f, (_e1603 - 0.1f)))));
                    let _e1611 = color;
                    let _e1613 = color;
                    let _e1615 = colorFog_1;
                    let _e1617 = kFog;
                    let _e1619 = mix(_e1613.xyz, _e1615.xyz, vec3(_e1617));
                    color.x = _e1619.x;
                    color.y = _e1619.y;
                    color.z = _e1619.z;
                }
            }
        }
    } else {
        {
            let _e1626 = bkgTransform_1;
            let _e1636 = model3DTransform3_;
            let _e1638 = camDir;
            camDir = ((mat3x3<f32>(_e1626[0].xyz, _e1626[1].xyz, _e1626[2].xyz) * _e1636) * _e1638);
            let _e1640 = backgroundStyle_1;
            if (_e1640 == 0i) {
                {
                    let _e1643 = camDir;
                    _o_n_4 = normalize(_e1643);
                    let _e1646 = _o_n_4;
                    let _e1648 = _o_n_4;
                    _o_alpha_4 = atan2(_e1646.z, _e1648.x);
                    let _e1652 = _o_n_4;
                    _o_beta_4 = asin(_e1652.y);
                    let _e1656 = sourceDim_1;
                    let _e1658 = sourceDim_1;
                    _o_ratio_8 = (_e1656.x / _e1658.y);
                    let _e1666 = _o_alpha_4;
                    let _e1672 = _o_nX_4;
                    let _e1675 = _o_nY_4;
                    let _e1676 = _o_beta_4;
                    let _e1685 = global.U[0];
                    let _e1688 = _o_alpha_4;
                    let _e1694 = _o_nX_4;
                    let _e1697 = _o_nY_4;
                    let _e1698 = _o_beta_4;
                    let _e1712 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1666) / 3.1415927f) * 0.5f) * _e1672), (0.5f + ((_e1675 * _e1676) / 3.1415927f))).x / _e1685.x), vec2<f32>((((-(_e1688) / 3.1415927f) * 0.5f) * _e1694), (0.5f + ((_e1697 * _e1698) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e1712;
                }
            } else {
                let _e1713 = backgroundStyle_1;
                if (_e1713 == 1i) {
                    {
                        let _e1716 = camDir;
                        let _e1719 = camDir;
                        let _e1722 = camDir;
                        let _e1725 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1716.x) / _e1719.z), (-(_e1722.y) / _e1725.z)) * 1f);
                        let _e1732 = _o_pos_4;
                        let _e1735 = _o_pos_4;
                        _o_m_4 = max(abs(_e1732.x), abs(_e1735.y));
                        let _e1742 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1742));
                        let _e1746 = _o_pos_4;
                        let _e1750 = global.U[0];
                        let _e1753 = _o_pos_4;
                        let _e1762 = textureSample(t_source, samp, ((vec2<f32>((_e1746.x / _e1750.x), _e1753.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1763 = _o_darken_4;
                        let _e1764 = _o_darken_4;
                        let _e1765 = _o_darken_4;
                        col = (_e1762 * vec4<f32>(_e1763, _e1764, _e1765, 1f));
                    }
                } else {
                    let _e1769 = backgroundStyle_1;
                    if (_e1769 == 2i) {
                        {
                            let _e1772 = sourceDim_1;
                            let _e1774 = sourceDim_1;
                            _o_ratio_9 = (_e1772.y / _e1774.x);
                            let _e1782 = camDir;
                            let _e1785 = camDir;
                            let _e1788 = _o_ratio_9;
                            let _e1791 = camDir;
                            let _e1794 = camDir;
                            let _e1797 = _o_ratio_9;
                            if ((abs(_e1782.y) > (abs(_e1785.z) * _e1788)) && (abs(_e1791.y) > (abs(_e1794.x) * _e1797))) {
                                {
                                    let _e1801 = _o_X_4;
                                    let _e1802 = camDir;
                                    let _e1805 = camDir;
                                    _o_X_4 = (_e1801 + ((-(_e1802.x) / _e1805.y) * 0.5f));
                                    let _e1811 = _o_Y_4;
                                    let _e1812 = camDir;
                                    let _e1815 = camDir;
                                    _o_Y_4 = (_e1811 + ((-(_e1812.z) / _e1815.y) * 0.5f));
                                }
                            } else {
                                let _e1821 = camDir;
                                let _e1824 = camDir;
                                if (abs(_e1821.x) < abs(_e1824.z)) {
                                    {
                                        let _e1828 = _o_X_4;
                                        let _e1829 = camDir;
                                        let _e1831 = camDir;
                                        let _e1835 = _o_ratio_9;
                                        let _e1839 = camDir;
                                        _o_X_4 = (_e1828 + ((((_e1829.x / abs(_e1831.z)) * _e1835) * 0.5f) * -(sign(_e1839.z))));
                                        let _e1845 = _o_Y_4;
                                        let _e1846 = camDir;
                                        let _e1848 = camDir;
                                        _o_Y_4 = (_e1845 + ((_e1846.y / abs(_e1848.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1855 = _o_X_4;
                                        let _e1856 = camDir;
                                        let _e1858 = camDir;
                                        let _e1862 = _o_ratio_9;
                                        let _e1866 = camDir;
                                        _o_X_4 = (_e1855 + ((((_e1856.z / abs(_e1858.x)) * _e1862) * 0.5f) * -(sign(_e1866.x))));
                                        let _e1872 = _o_Y_4;
                                        let _e1873 = camDir;
                                        let _e1875 = camDir;
                                        _o_Y_4 = (_e1872 + ((_e1873.y / abs(_e1875.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1882 = _o_X_4;
                            let _e1883 = _o_Y_4;
                            let _e1888 = global.U[0];
                            let _e1891 = _o_X_4;
                            let _e1892 = _o_Y_4;
                            let _e1902 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1882, _e1883).x / _e1888.x), vec2<f32>(_e1891, _e1892).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1902;
                        }
                    } else {
                        {
                            let _e1903 = camDir;
                            let _e1908 = ((_e1903 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1908.x, _e1908.y, _e1908.z, 1f);
                        }
                    }
                }
            }
            let _e1914 = colorFog_1;
            if (_e1914.w != 0f) {
                let _e1918 = color;
                let _e1920 = colorFog_1;
                let _e1921 = _e1920.xyz;
                color.x = _e1921.x;
                color.y = _e1921.y;
                color.z = _e1921.z;
            } else {
                let _e1928 = col;
                color = _e1928;
            }
        }
    }
    let _e1929 = color;
    return clamp(_e1929, vec4(0f), vec4(1f));
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
    let _e234 = rayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)), mat4x4<f32>(vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w)), _e203, _e206.x, _e210.x, _e214.x, _e218, _e221, _e224, _e227.x, i32(_e231.x));
    fragColor = _e234;
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
