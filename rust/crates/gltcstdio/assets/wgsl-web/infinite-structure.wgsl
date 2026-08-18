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

fn sdf(p: vec3<f32>) -> f32 {
    var p_1: vec3<f32>;
    var q: vec3<f32>;
    var qq: vec3<f32>;

    p_1 = p;
    let _e9 = p_1;
    let _e11 = vec3(5f);
    q = ((_e9 - (floor((_e9 / _e11)) * _e11)) - vec3(2.5f));
    let _e20 = q;
    qq = (min(abs(_e20), vec3(1f)) - vec3(0.5f));
    let _e29 = qq;
    return (length(_e29) - 0.6f);
}

fn normal(p_2: vec3<f32>) -> vec3<f32> {
    var p_3: vec3<f32>;
    var d: f32 = 0.0001f;
    var s: f32;

    p_3 = p_2;
    let _e11 = p_3;
    let _e12 = sdf(_e11);
    s = _e12;
    let _e14 = s;
    let _e15 = p_3;
    let _e17 = d;
    let _e19 = p_3;
    let _e21 = p_3;
    let _e24 = sdf(vec3<f32>((_e15.x - _e17), _e19.y, _e21.z));
    let _e26 = d;
    let _e28 = s;
    let _e29 = p_3;
    let _e31 = p_3;
    let _e33 = d;
    let _e35 = p_3;
    let _e38 = sdf(vec3<f32>(_e29.x, (_e31.y - _e33), _e35.z));
    let _e40 = d;
    let _e42 = s;
    let _e43 = p_3;
    let _e45 = p_3;
    let _e47 = p_3;
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
    var p_4: vec3<f32>;

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
            p_4 = (_e36 + (_e37 * _e38));
            let _e42 = p_4;
            let _e43 = sdf(_e42);
            d_1 = _e43;
            let _e44 = d_1;
            if (abs(_e44) < 0.0001f) {
                let _e48 = p_4;
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
                            let _e415 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e368) / 3.1415927f) * 0.5f) * _e374), (0.5f + ((_e377 * _e378) / 3.1415927f))).x / _e387.x), vec2<f32>((((-(_e390) / 3.1415927f) * 0.5f) * _e396), (0.5f + ((_e399 * _e400) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colR = _e415;
                        }
                    } else {
                        let _e416 = backgroundStyle_1;
                        if (_e416 == 1i) {
                            {
                                let _e419 = refractDirR;
                                let _e422 = refractDirR;
                                let _e425 = refractDirR;
                                let _e428 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e419.x) / _e422.z), (-(_e425.y) / _e428.z)) * 1f);
                                let _e435 = _o_pos;
                                let _e438 = _o_pos;
                                _o_m = max(abs(_e435.x), abs(_e438.y));
                                let _e445 = _o_m;
                                _o_darken = (4f / max(4f, _e445));
                                let _e449 = _o_pos;
                                let _e453 = global.U[0];
                                let _e456 = _o_pos;
                                let _e466 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e449.x / _e453.x), _e456.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e467 = _o_darken;
                                let _e468 = _o_darken;
                                let _e469 = _o_darken;
                                colR = (_e466 * vec4<f32>(_e467, _e468, _e469, 1f));
                            }
                        } else {
                            let _e473 = backgroundStyle_1;
                            if (_e473 == 2i) {
                                {
                                    let _e476 = sourceDim_1;
                                    let _e478 = sourceDim_1;
                                    _o_ratio_1 = (_e476.y / _e478.x);
                                    let _e486 = refractDirR;
                                    let _e489 = refractDirR;
                                    let _e492 = _o_ratio_1;
                                    let _e495 = refractDirR;
                                    let _e498 = refractDirR;
                                    let _e501 = _o_ratio_1;
                                    if ((abs(_e486.y) > (abs(_e489.z) * _e492)) && (abs(_e495.y) > (abs(_e498.x) * _e501))) {
                                        {
                                            let _e505 = _o_X;
                                            let _e506 = refractDirR;
                                            let _e509 = refractDirR;
                                            _o_X = (_e505 + ((-(_e506.x) / _e509.y) * 0.5f));
                                            let _e515 = _o_Y;
                                            let _e516 = refractDirR;
                                            let _e519 = refractDirR;
                                            _o_Y = (_e515 + ((-(_e516.z) / _e519.y) * 0.5f));
                                        }
                                    } else {
                                        let _e525 = refractDirR;
                                        let _e528 = refractDirR;
                                        if (abs(_e525.x) < abs(_e528.z)) {
                                            {
                                                let _e532 = _o_X;
                                                let _e533 = refractDirR;
                                                let _e535 = refractDirR;
                                                let _e539 = _o_ratio_1;
                                                let _e543 = refractDirR;
                                                _o_X = (_e532 + ((((_e533.x / abs(_e535.z)) * _e539) * 0.5f) * -(sign(_e543.z))));
                                                let _e549 = _o_Y;
                                                let _e550 = refractDirR;
                                                let _e552 = refractDirR;
                                                _o_Y = (_e549 + ((_e550.y / abs(_e552.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e559 = _o_X;
                                                let _e560 = refractDirR;
                                                let _e562 = refractDirR;
                                                let _e566 = _o_ratio_1;
                                                let _e570 = refractDirR;
                                                _o_X = (_e559 + ((((_e560.z / abs(_e562.x)) * _e566) * 0.5f) * -(sign(_e570.x))));
                                                let _e576 = _o_Y;
                                                let _e577 = refractDirR;
                                                let _e579 = refractDirR;
                                                _o_Y = (_e576 + ((_e577.y / abs(_e579.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e586 = _o_X;
                                    let _e587 = _o_Y;
                                    let _e592 = global.U[0];
                                    let _e595 = _o_X;
                                    let _e596 = _o_Y;
                                    let _e607 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e586, _e587).x / _e592.x), vec2<f32>(_e595, _e596).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colR = _e607;
                                }
                            } else {
                                {
                                    let _e608 = refractDirR;
                                    let _e613 = ((_e608 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e613.x, _e613.y, _e613.z, 1f);
                                }
                            }
                        }
                    }
                    let _e619 = backgroundStyle_1;
                    if (_e619 == 0i) {
                        {
                            let _e622 = refractDirG;
                            _o_n_1 = normalize(_e622);
                            let _e625 = _o_n_1;
                            let _e627 = _o_n_1;
                            _o_alpha_1 = atan2(_e625.z, _e627.x);
                            let _e631 = _o_n_1;
                            _o_beta_1 = asin(_e631.y);
                            let _e635 = sourceDim_1;
                            let _e637 = sourceDim_1;
                            _o_ratio_2 = (_e635.x / _e637.y);
                            let _e645 = _o_alpha_1;
                            let _e651 = _o_nX_1;
                            let _e654 = _o_nY_1;
                            let _e655 = _o_beta_1;
                            let _e664 = global.U[0];
                            let _e667 = _o_alpha_1;
                            let _e673 = _o_nX_1;
                            let _e676 = _o_nY_1;
                            let _e677 = _o_beta_1;
                            let _e692 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e645) / 3.1415927f) * 0.5f) * _e651), (0.5f + ((_e654 * _e655) / 3.1415927f))).x / _e664.x), vec2<f32>((((-(_e667) / 3.1415927f) * 0.5f) * _e673), (0.5f + ((_e676 * _e677) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colG = _e692;
                        }
                    } else {
                        let _e693 = backgroundStyle_1;
                        if (_e693 == 1i) {
                            {
                                let _e696 = refractDirG;
                                let _e699 = refractDirG;
                                let _e702 = refractDirG;
                                let _e705 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e696.x) / _e699.z), (-(_e702.y) / _e705.z)) * 1f);
                                let _e712 = _o_pos_1;
                                let _e715 = _o_pos_1;
                                _o_m_1 = max(abs(_e712.x), abs(_e715.y));
                                let _e722 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e722));
                                let _e726 = _o_pos_1;
                                let _e730 = global.U[0];
                                let _e733 = _o_pos_1;
                                let _e743 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e726.x / _e730.x), _e733.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e744 = _o_darken_1;
                                let _e745 = _o_darken_1;
                                let _e746 = _o_darken_1;
                                colG = (_e743 * vec4<f32>(_e744, _e745, _e746, 1f));
                            }
                        } else {
                            let _e750 = backgroundStyle_1;
                            if (_e750 == 2i) {
                                {
                                    let _e753 = sourceDim_1;
                                    let _e755 = sourceDim_1;
                                    _o_ratio_3 = (_e753.y / _e755.x);
                                    let _e763 = refractDirG;
                                    let _e766 = refractDirG;
                                    let _e769 = _o_ratio_3;
                                    let _e772 = refractDirG;
                                    let _e775 = refractDirG;
                                    let _e778 = _o_ratio_3;
                                    if ((abs(_e763.y) > (abs(_e766.z) * _e769)) && (abs(_e772.y) > (abs(_e775.x) * _e778))) {
                                        {
                                            let _e782 = _o_X_1;
                                            let _e783 = refractDirG;
                                            let _e786 = refractDirG;
                                            _o_X_1 = (_e782 + ((-(_e783.x) / _e786.y) * 0.5f));
                                            let _e792 = _o_Y_1;
                                            let _e793 = refractDirG;
                                            let _e796 = refractDirG;
                                            _o_Y_1 = (_e792 + ((-(_e793.z) / _e796.y) * 0.5f));
                                        }
                                    } else {
                                        let _e802 = refractDirG;
                                        let _e805 = refractDirG;
                                        if (abs(_e802.x) < abs(_e805.z)) {
                                            {
                                                let _e809 = _o_X_1;
                                                let _e810 = refractDirG;
                                                let _e812 = refractDirG;
                                                let _e816 = _o_ratio_3;
                                                let _e820 = refractDirG;
                                                _o_X_1 = (_e809 + ((((_e810.x / abs(_e812.z)) * _e816) * 0.5f) * -(sign(_e820.z))));
                                                let _e826 = _o_Y_1;
                                                let _e827 = refractDirG;
                                                let _e829 = refractDirG;
                                                _o_Y_1 = (_e826 + ((_e827.y / abs(_e829.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e836 = _o_X_1;
                                                let _e837 = refractDirG;
                                                let _e839 = refractDirG;
                                                let _e843 = _o_ratio_3;
                                                let _e847 = refractDirG;
                                                _o_X_1 = (_e836 + ((((_e837.z / abs(_e839.x)) * _e843) * 0.5f) * -(sign(_e847.x))));
                                                let _e853 = _o_Y_1;
                                                let _e854 = refractDirG;
                                                let _e856 = refractDirG;
                                                _o_Y_1 = (_e853 + ((_e854.y / abs(_e856.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e863 = _o_X_1;
                                    let _e864 = _o_Y_1;
                                    let _e869 = global.U[0];
                                    let _e872 = _o_X_1;
                                    let _e873 = _o_Y_1;
                                    let _e884 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e863, _e864).x / _e869.x), vec2<f32>(_e872, _e873).y) / vec2(2f)) + vec2(0.5f)), 0f);
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
                            let _e969 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e922) / 3.1415927f) * 0.5f) * _e928), (0.5f + ((_e931 * _e932) / 3.1415927f))).x / _e941.x), vec2<f32>((((-(_e944) / 3.1415927f) * 0.5f) * _e950), (0.5f + ((_e953 * _e954) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colB = _e969;
                        }
                    } else {
                        let _e970 = backgroundStyle_1;
                        if (_e970 == 1i) {
                            {
                                let _e973 = refractDirB;
                                let _e976 = refractDirB;
                                let _e979 = refractDirB;
                                let _e982 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e973.x) / _e976.z), (-(_e979.y) / _e982.z)) * 1f);
                                let _e989 = _o_pos_2;
                                let _e992 = _o_pos_2;
                                _o_m_2 = max(abs(_e989.x), abs(_e992.y));
                                let _e999 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e999));
                                let _e1003 = _o_pos_2;
                                let _e1007 = global.U[0];
                                let _e1010 = _o_pos_2;
                                let _e1020 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1003.x / _e1007.x), _e1010.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1021 = _o_darken_2;
                                let _e1022 = _o_darken_2;
                                let _e1023 = _o_darken_2;
                                colB = (_e1020 * vec4<f32>(_e1021, _e1022, _e1023, 1f));
                            }
                        } else {
                            let _e1027 = backgroundStyle_1;
                            if (_e1027 == 2i) {
                                {
                                    let _e1030 = sourceDim_1;
                                    let _e1032 = sourceDim_1;
                                    _o_ratio_5 = (_e1030.y / _e1032.x);
                                    let _e1040 = refractDirB;
                                    let _e1043 = refractDirB;
                                    let _e1046 = _o_ratio_5;
                                    let _e1049 = refractDirB;
                                    let _e1052 = refractDirB;
                                    let _e1055 = _o_ratio_5;
                                    if ((abs(_e1040.y) > (abs(_e1043.z) * _e1046)) && (abs(_e1049.y) > (abs(_e1052.x) * _e1055))) {
                                        {
                                            let _e1059 = _o_X_2;
                                            let _e1060 = refractDirB;
                                            let _e1063 = refractDirB;
                                            _o_X_2 = (_e1059 + ((-(_e1060.x) / _e1063.y) * 0.5f));
                                            let _e1069 = _o_Y_2;
                                            let _e1070 = refractDirB;
                                            let _e1073 = refractDirB;
                                            _o_Y_2 = (_e1069 + ((-(_e1070.z) / _e1073.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1079 = refractDirB;
                                        let _e1082 = refractDirB;
                                        if (abs(_e1079.x) < abs(_e1082.z)) {
                                            {
                                                let _e1086 = _o_X_2;
                                                let _e1087 = refractDirB;
                                                let _e1089 = refractDirB;
                                                let _e1093 = _o_ratio_5;
                                                let _e1097 = refractDirB;
                                                _o_X_2 = (_e1086 + ((((_e1087.x / abs(_e1089.z)) * _e1093) * 0.5f) * -(sign(_e1097.z))));
                                                let _e1103 = _o_Y_2;
                                                let _e1104 = refractDirB;
                                                let _e1106 = refractDirB;
                                                _o_Y_2 = (_e1103 + ((_e1104.y / abs(_e1106.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1113 = _o_X_2;
                                                let _e1114 = refractDirB;
                                                let _e1116 = refractDirB;
                                                let _e1120 = _o_ratio_5;
                                                let _e1124 = refractDirB;
                                                _o_X_2 = (_e1113 + ((((_e1114.z / abs(_e1116.x)) * _e1120) * 0.5f) * -(sign(_e1124.x))));
                                                let _e1130 = _o_Y_2;
                                                let _e1131 = refractDirB;
                                                let _e1133 = refractDirB;
                                                _o_Y_2 = (_e1130 + ((_e1131.y / abs(_e1133.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1140 = _o_X_2;
                                    let _e1141 = _o_Y_2;
                                    let _e1146 = global.U[0];
                                    let _e1149 = _o_X_2;
                                    let _e1150 = _o_Y_2;
                                    let _e1161 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1140, _e1141).x / _e1146.x), vec2<f32>(_e1149, _e1150).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colB = _e1161;
                                }
                            } else {
                                {
                                    let _e1162 = refractDirB;
                                    let _e1167 = ((_e1162 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1167.x, _e1167.y, _e1167.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1173 = colR;
                    let _e1175 = colG;
                    let _e1177 = colB;
                    col = vec4<f32>(_e1173.x, _e1175.y, _e1177.z, 1f);
                    let _e1183 = absorption;
                    let _e1184 = qIn;
                    let _e1185 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1183 * length((_e1184 - _e1185)))));
                    let _e1193 = absorbed;
                    let _e1196 = colorMaterial_1;
                    absorbed = mix(0f, _e1193, smoothstep(0f, 0.1f, _e1196.w));
                    let _e1200 = color;
                    let _e1202 = color;
                    let _e1204 = colorMaterial_1;
                    let _e1207 = fresnel;
                    let _e1211 = absorbed;
                    let _e1214 = col;
                    let _e1217 = (_e1202.xyz + (((_e1204.xyz * (1f - _e1207)) * (1f - _e1211)) * _e1214.xyz));
                    color.x = _e1217.x;
                    color.y = _e1217.y;
                    color.z = _e1217.z;
                    let _e1224 = color;
                    let _e1226 = color;
                    let _e1228 = absorbed;
                    let _e1229 = colorMaterial_1;
                    let _e1232 = ambientColor_1;
                    let _e1235 = nIn;
                    let _e1236 = lightDir;
                    let _e1239 = sourceColor_1;
                    let _e1244 = (_e1226.xyz + ((_e1228 * _e1229.xyz) * (_e1232.xyz + (max(0f, dot(_e1235, _e1236)) * _e1239.xyz))));
                    color.x = _e1244.x;
                    color.y = _e1244.y;
                    color.z = _e1244.z;
                }
            }
            let _e1251 = fresnel;
            let _e1254 = specular_1;
            if ((_e1251 != 0f) || (_e1254 != 0f)) {
                {
                    let _e1258 = reflectDir;
                    origReflectDir = _e1258;
                    let _e1260 = qIn;
                    let _e1261 = nIn;
                    let _e1265 = reflectDir;
                    let _e1267 = rayMarch((_e1260 + (_e1261 * 0.001f)), _e1265, 1f);
                    qR = _e1267;
                    let _e1269 = qR;
                    if (_e1269.x != 100000000000000000000f) {
                        {
                            let _e1273 = qR;
                            let _e1274 = normal(_e1273);
                            n_1 = _e1274;
                            let _e1276 = reflectDir;
                            let _e1277 = n_1;
                            reflectDir = reflect(_e1276, _e1277);
                        }
                    }
                    let _e1279 = model3DTransform3_;
                    let _e1280 = reflectDir;
                    reflectDir = (_e1279 * _e1280);
                    let _e1282 = backgroundStyle_1;
                    if (_e1282 == 0i) {
                        {
                            let _e1285 = reflectDir;
                            _o_n_3 = normalize(_e1285);
                            let _e1288 = _o_n_3;
                            let _e1290 = _o_n_3;
                            _o_alpha_3 = atan2(_e1288.z, _e1290.x);
                            let _e1294 = _o_n_3;
                            _o_beta_3 = asin(_e1294.y);
                            let _e1298 = sourceDim_1;
                            let _e1300 = sourceDim_1;
                            _o_ratio_6 = (_e1298.x / _e1300.y);
                            let _e1308 = _o_alpha_3;
                            let _e1314 = _o_nX_3;
                            let _e1317 = _o_nY_3;
                            let _e1318 = _o_beta_3;
                            let _e1327 = global.U[0];
                            let _e1330 = _o_alpha_3;
                            let _e1336 = _o_nX_3;
                            let _e1339 = _o_nY_3;
                            let _e1340 = _o_beta_3;
                            let _e1355 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1308) / 3.1415927f) * 0.5f) * _e1314), (0.5f + ((_e1317 * _e1318) / 3.1415927f))).x / _e1327.x), vec2<f32>((((-(_e1330) / 3.1415927f) * 0.5f) * _e1336), (0.5f + ((_e1339 * _e1340) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1355;
                        }
                    } else {
                        let _e1356 = backgroundStyle_1;
                        if (_e1356 == 1i) {
                            {
                                let _e1359 = reflectDir;
                                let _e1362 = reflectDir;
                                let _e1365 = reflectDir;
                                let _e1368 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1359.x) / _e1362.z), (-(_e1365.y) / _e1368.z)) * 1f);
                                let _e1375 = _o_pos_3;
                                let _e1378 = _o_pos_3;
                                _o_m_3 = max(abs(_e1375.x), abs(_e1378.y));
                                let _e1385 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1385));
                                let _e1389 = _o_pos_3;
                                let _e1393 = global.U[0];
                                let _e1396 = _o_pos_3;
                                let _e1406 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1389.x / _e1393.x), _e1396.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1407 = _o_darken_3;
                                let _e1408 = _o_darken_3;
                                let _e1409 = _o_darken_3;
                                col = (_e1406 * vec4<f32>(_e1407, _e1408, _e1409, 1f));
                            }
                        } else {
                            let _e1413 = backgroundStyle_1;
                            if (_e1413 == 2i) {
                                {
                                    let _e1416 = sourceDim_1;
                                    let _e1418 = sourceDim_1;
                                    _o_ratio_7 = (_e1416.y / _e1418.x);
                                    let _e1426 = reflectDir;
                                    let _e1429 = reflectDir;
                                    let _e1432 = _o_ratio_7;
                                    let _e1435 = reflectDir;
                                    let _e1438 = reflectDir;
                                    let _e1441 = _o_ratio_7;
                                    if ((abs(_e1426.y) > (abs(_e1429.z) * _e1432)) && (abs(_e1435.y) > (abs(_e1438.x) * _e1441))) {
                                        {
                                            let _e1445 = _o_X_3;
                                            let _e1446 = reflectDir;
                                            let _e1449 = reflectDir;
                                            _o_X_3 = (_e1445 + ((-(_e1446.x) / _e1449.y) * 0.5f));
                                            let _e1455 = _o_Y_3;
                                            let _e1456 = reflectDir;
                                            let _e1459 = reflectDir;
                                            _o_Y_3 = (_e1455 + ((-(_e1456.z) / _e1459.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1465 = reflectDir;
                                        let _e1468 = reflectDir;
                                        if (abs(_e1465.x) < abs(_e1468.z)) {
                                            {
                                                let _e1472 = _o_X_3;
                                                let _e1473 = reflectDir;
                                                let _e1475 = reflectDir;
                                                let _e1479 = _o_ratio_7;
                                                let _e1483 = reflectDir;
                                                _o_X_3 = (_e1472 + ((((_e1473.x / abs(_e1475.z)) * _e1479) * 0.5f) * -(sign(_e1483.z))));
                                                let _e1489 = _o_Y_3;
                                                let _e1490 = reflectDir;
                                                let _e1492 = reflectDir;
                                                _o_Y_3 = (_e1489 + ((_e1490.y / abs(_e1492.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1499 = _o_X_3;
                                                let _e1500 = reflectDir;
                                                let _e1502 = reflectDir;
                                                let _e1506 = _o_ratio_7;
                                                let _e1510 = reflectDir;
                                                _o_X_3 = (_e1499 + ((((_e1500.z / abs(_e1502.x)) * _e1506) * 0.5f) * -(sign(_e1510.x))));
                                                let _e1516 = _o_Y_3;
                                                let _e1517 = reflectDir;
                                                let _e1519 = reflectDir;
                                                _o_Y_3 = (_e1516 + ((_e1517.y / abs(_e1519.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1526 = _o_X_3;
                                    let _e1527 = _o_Y_3;
                                    let _e1532 = global.U[0];
                                    let _e1535 = _o_X_3;
                                    let _e1536 = _o_Y_3;
                                    let _e1547 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1526, _e1527).x / _e1532.x), vec2<f32>(_e1535, _e1536).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e1547;
                                }
                            } else {
                                {
                                    let _e1548 = reflectDir;
                                    let _e1553 = ((_e1548 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1553.x, _e1553.y, _e1553.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1559 = color;
                    let _e1561 = color;
                    let _e1563 = fresnel;
                    let _e1564 = col;
                    let _e1567 = (_e1561.xyz + (_e1563 * _e1564.xyz));
                    color.x = _e1567.x;
                    color.y = _e1567.y;
                    color.z = _e1567.z;
                    let _e1575 = specular_1;
                    let _e1578 = lightDir;
                    let _e1579 = origReflectDir;
                    kSpec = ((10f * _e1575) * pow(max(0f, dot(_e1578, _e1579)), 9f));
                    let _e1586 = color;
                    let _e1588 = color;
                    let _e1590 = sourceColor_1;
                    let _e1592 = kSpec;
                    let _e1594 = (_e1588.xyz + (_e1590.xyz * _e1592));
                    color.x = _e1594.x;
                    color.y = _e1594.y;
                    color.z = _e1594.z;
                }
            }
            let _e1601 = colorFog_1;
            if (_e1601.w != 0f) {
                {
                    let _e1605 = camera_2;
                    let _e1606 = qIn;
                    dist = length((_e1605 - _e1606));
                    let _e1612 = colorFog_1;
                    let _e1615 = dist;
                    kFog = (1f - pow(0.4f, (_e1612.w * max(0f, (_e1615 - 0.1f)))));
                    let _e1623 = color;
                    let _e1625 = color;
                    let _e1627 = colorFog_1;
                    let _e1629 = kFog;
                    let _e1631 = mix(_e1625.xyz, _e1627.xyz, vec3(_e1629));
                    color.x = _e1631.x;
                    color.y = _e1631.y;
                    color.z = _e1631.z;
                }
            }
        }
    } else {
        {
            let _e1638 = bkgTransform_1;
            let _e1648 = model3DTransform3_;
            let _e1650 = camDir;
            camDir = ((mat3x3<f32>(_e1638[0].xyz, _e1638[1].xyz, _e1638[2].xyz) * _e1648) * _e1650);
            let _e1652 = backgroundStyle_1;
            if (_e1652 == 0i) {
                {
                    let _e1655 = camDir;
                    _o_n_4 = normalize(_e1655);
                    let _e1658 = _o_n_4;
                    let _e1660 = _o_n_4;
                    _o_alpha_4 = atan2(_e1658.z, _e1660.x);
                    let _e1664 = _o_n_4;
                    _o_beta_4 = asin(_e1664.y);
                    let _e1668 = sourceDim_1;
                    let _e1670 = sourceDim_1;
                    _o_ratio_8 = (_e1668.x / _e1670.y);
                    let _e1678 = _o_alpha_4;
                    let _e1684 = _o_nX_4;
                    let _e1687 = _o_nY_4;
                    let _e1688 = _o_beta_4;
                    let _e1697 = global.U[0];
                    let _e1700 = _o_alpha_4;
                    let _e1706 = _o_nX_4;
                    let _e1709 = _o_nY_4;
                    let _e1710 = _o_beta_4;
                    let _e1725 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1678) / 3.1415927f) * 0.5f) * _e1684), (0.5f + ((_e1687 * _e1688) / 3.1415927f))).x / _e1697.x), vec2<f32>((((-(_e1700) / 3.1415927f) * 0.5f) * _e1706), (0.5f + ((_e1709 * _e1710) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col = _e1725;
                }
            } else {
                let _e1726 = backgroundStyle_1;
                if (_e1726 == 1i) {
                    {
                        let _e1729 = camDir;
                        let _e1732 = camDir;
                        let _e1735 = camDir;
                        let _e1738 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1729.x) / _e1732.z), (-(_e1735.y) / _e1738.z)) * 1f);
                        let _e1745 = _o_pos_4;
                        let _e1748 = _o_pos_4;
                        _o_m_4 = max(abs(_e1745.x), abs(_e1748.y));
                        let _e1755 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1755));
                        let _e1759 = _o_pos_4;
                        let _e1763 = global.U[0];
                        let _e1766 = _o_pos_4;
                        let _e1776 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1759.x / _e1763.x), _e1766.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1777 = _o_darken_4;
                        let _e1778 = _o_darken_4;
                        let _e1779 = _o_darken_4;
                        col = (_e1776 * vec4<f32>(_e1777, _e1778, _e1779, 1f));
                    }
                } else {
                    let _e1783 = backgroundStyle_1;
                    if (_e1783 == 2i) {
                        {
                            let _e1786 = sourceDim_1;
                            let _e1788 = sourceDim_1;
                            _o_ratio_9 = (_e1786.y / _e1788.x);
                            let _e1796 = camDir;
                            let _e1799 = camDir;
                            let _e1802 = _o_ratio_9;
                            let _e1805 = camDir;
                            let _e1808 = camDir;
                            let _e1811 = _o_ratio_9;
                            if ((abs(_e1796.y) > (abs(_e1799.z) * _e1802)) && (abs(_e1805.y) > (abs(_e1808.x) * _e1811))) {
                                {
                                    let _e1815 = _o_X_4;
                                    let _e1816 = camDir;
                                    let _e1819 = camDir;
                                    _o_X_4 = (_e1815 + ((-(_e1816.x) / _e1819.y) * 0.5f));
                                    let _e1825 = _o_Y_4;
                                    let _e1826 = camDir;
                                    let _e1829 = camDir;
                                    _o_Y_4 = (_e1825 + ((-(_e1826.z) / _e1829.y) * 0.5f));
                                }
                            } else {
                                let _e1835 = camDir;
                                let _e1838 = camDir;
                                if (abs(_e1835.x) < abs(_e1838.z)) {
                                    {
                                        let _e1842 = _o_X_4;
                                        let _e1843 = camDir;
                                        let _e1845 = camDir;
                                        let _e1849 = _o_ratio_9;
                                        let _e1853 = camDir;
                                        _o_X_4 = (_e1842 + ((((_e1843.x / abs(_e1845.z)) * _e1849) * 0.5f) * -(sign(_e1853.z))));
                                        let _e1859 = _o_Y_4;
                                        let _e1860 = camDir;
                                        let _e1862 = camDir;
                                        _o_Y_4 = (_e1859 + ((_e1860.y / abs(_e1862.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1869 = _o_X_4;
                                        let _e1870 = camDir;
                                        let _e1872 = camDir;
                                        let _e1876 = _o_ratio_9;
                                        let _e1880 = camDir;
                                        _o_X_4 = (_e1869 + ((((_e1870.z / abs(_e1872.x)) * _e1876) * 0.5f) * -(sign(_e1880.x))));
                                        let _e1886 = _o_Y_4;
                                        let _e1887 = camDir;
                                        let _e1889 = camDir;
                                        _o_Y_4 = (_e1886 + ((_e1887.y / abs(_e1889.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1896 = _o_X_4;
                            let _e1897 = _o_Y_4;
                            let _e1902 = global.U[0];
                            let _e1905 = _o_X_4;
                            let _e1906 = _o_Y_4;
                            let _e1917 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1896, _e1897).x / _e1902.x), vec2<f32>(_e1905, _e1906).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1917;
                        }
                    } else {
                        {
                            let _e1918 = camDir;
                            let _e1923 = ((_e1918 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1923.x, _e1923.y, _e1923.z, 1f);
                        }
                    }
                }
            }
            let _e1929 = colorFog_1;
            if (_e1929.w != 0f) {
                let _e1933 = color;
                let _e1935 = colorFog_1;
                let _e1936 = _e1935.xyz;
                color.x = _e1936.x;
                color.y = _e1936.y;
                color.z = _e1936.z;
            } else {
                let _e1943 = col;
                color = _e1943;
            }
        }
    }
    let _e1944 = color;
    return clamp(_e1944, vec4(0f), vec4(1f));
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
