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

fn sdf(p_2: vec3<f32>, roundness: f32) -> f32 {
    var p_3: vec3<f32>;
    var roundness_1: f32;
    var d3_: f32 = 0.16666667f;
    var d6_: f32;
    var d: f32;

    p_3 = p_2;
    roundness_1 = roundness;
    let _e15 = d3_;
    d6_ = (_e15 * 0.5f);
    let _e19 = p_3;
    let _e21 = p_3;
    let _e23 = p_3;
    let _e26 = p_3;
    let _e28 = vec3<f32>(_e21.x, -(_e23.z), _e26.y);
    p_3.x = _e28.x;
    p_3.y = _e28.y;
    p_3.z = _e28.z;
    let _e35 = p_3;
    let _e37 = p_3;
    if (_e35.x > _e37.z) {
        {
            let _e40 = p_3;
            let _e42 = p_3;
            let _e43 = _e42.zyx;
            p_3.x = _e43.x;
            p_3.y = _e43.y;
            p_3.z = _e43.z;
        }
    }
    let _e50 = p_3;
    let _e51 = d6_;
    let _e52 = d3_;
    let _e53 = d6_;
    let _e56 = d3_;
    let _e57 = d6_;
    let _e58 = d3_;
    let _e60 = sdBox((_e50 - vec3<f32>(_e51, _e52, _e53)), vec3<f32>(_e56, _e57, _e58));
    d = _e60;
    let _e62 = d;
    let _e63 = p_3;
    let _e64 = d3_;
    let _e66 = d3_;
    let _e69 = d6_;
    let _e71 = d6_;
    let _e73 = sdBox((_e63 - vec3<f32>(_e64, 0f, _e66)), vec3<f32>(_e69, 0.25f, _e71));
    d = min(_e62, _e73);
    let _e75 = d;
    let _e76 = p_3;
    let _e78 = d3_;
    let _e79 = d3_;
    let _e83 = d6_;
    let _e84 = d6_;
    let _e86 = sdBox((_e76 - vec3<f32>(0f, _e78, _e79)), vec3<f32>(0.25f, _e83, _e84));
    d = min(_e75, _e86);
    let _e88 = d;
    let _e89 = p_3;
    let _e92 = d3_;
    let _e95 = d6_;
    let _e96 = d6_;
    let _e97 = d6_;
    let _e99 = sdBox((_e89 - vec3<f32>(0f, 0f, _e92)), vec3<f32>(_e95, _e96, _e97));
    d = min(_e88, _e99);
    let _e101 = d;
    let _e102 = roundness_1;
    return (_e101 - (_e102 * 0.5f));
}

fn normal(p_4: vec3<f32>, roundness_2: f32) -> vec3<f32> {
    var p_5: vec3<f32>;
    var roundness_3: f32;
    var d_1: f32 = 0.0001f;
    var s: f32;

    p_5 = p_4;
    roundness_3 = roundness_2;
    let _e13 = p_5;
    let _e14 = roundness_3;
    let _e15 = sdf(_e13, _e14);
    s = _e15;
    let _e17 = s;
    let _e18 = p_5;
    let _e20 = d_1;
    let _e22 = p_5;
    let _e24 = p_5;
    let _e27 = roundness_3;
    let _e28 = sdf(vec3<f32>((_e18.x - _e20), _e22.y, _e24.z), _e27);
    let _e30 = d_1;
    let _e32 = s;
    let _e33 = p_5;
    let _e35 = p_5;
    let _e37 = d_1;
    let _e39 = p_5;
    let _e42 = roundness_3;
    let _e43 = sdf(vec3<f32>(_e33.x, (_e35.y - _e37), _e39.z), _e42);
    let _e45 = d_1;
    let _e47 = s;
    let _e48 = p_5;
    let _e50 = p_5;
    let _e52 = p_5;
    let _e54 = d_1;
    let _e57 = roundness_3;
    let _e58 = sdf(vec3<f32>(_e48.x, _e50.y, (_e52.z - _e54)), _e57);
    let _e60 = d_1;
    return normalize(vec3<f32>(((_e17 - _e28) / _e30), ((_e32 - _e43) / _e45), ((_e47 - _e58) / _e60)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32, roundness_4: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var roundness_5: f32;
    var d_2: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_6: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    roundness_5 = roundness_4;
    let _e15 = p0_1;
    let _e16 = roundness_5;
    let _e17 = sdf(_e15, _e16);
    d_2 = _e17;
    let _e19 = d_2;
    s_1 = sign(_e19);
    loop {
        let _e26 = step;
        let _e29 = d_2;
        if !(((_e26 < 1000i) && (_e29 < 100f))) {
            break;
        }
        {
            let _e34 = totalD;
            let _e35 = d_2;
            let _e36 = side_1;
            totalD = (_e34 + (_e35 * _e36));
            let _e39 = p0_1;
            let _e40 = totalD;
            let _e41 = dir_1;
            p_6 = (_e39 + (_e40 * _e41));
            let _e45 = p_6;
            let _e46 = roundness_5;
            let _e47 = sdf(_e45, _e46);
            d_2 = _e47;
            let _e48 = d_2;
            if (abs(_e48) < 0.0001f) {
                let _e52 = p_6;
                return _e52;
            }
            let _e53 = step;
            step = (_e53 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32, roundness_6: f32) -> vec4<f32> {
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
    var roundness_7: f32;
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
    roundness_7 = roundness_6;
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
    let _e151 = roundness_7;
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
            let _e180 = roundness_7;
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
                    let _e270 = roundness_7;
                    let _e271 = rayMarch((_e262 - (_e263 * 0.001f)), _e267, -1f, _e270);
                    qOut = _e271;
                    let _e273 = qOut;
                    let _e274 = roundness_7;
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
                            let _e421 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e374) / 3.1415927f) * 0.5f) * _e380), (0.5f + ((_e383 * _e384) / 3.1415927f))).x / _e393.x), vec2<f32>((((-(_e396) / 3.1415927f) * 0.5f) * _e402), (0.5f + ((_e405 * _e406) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colR = _e421;
                        }
                    } else {
                        let _e422 = backgroundStyle_1;
                        if (_e422 == 1i) {
                            {
                                let _e425 = refractDirR;
                                let _e428 = refractDirR;
                                let _e431 = refractDirR;
                                let _e434 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e425.x) / _e428.z), (-(_e431.y) / _e434.z)) * 1f);
                                let _e441 = _o_pos;
                                let _e444 = _o_pos;
                                _o_m = max(abs(_e441.x), abs(_e444.y));
                                let _e451 = _o_m;
                                _o_darken = (4f / max(4f, _e451));
                                let _e455 = _o_pos;
                                let _e459 = global.U[0];
                                let _e462 = _o_pos;
                                let _e472 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e455.x / _e459.x), _e462.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e473 = _o_darken;
                                let _e474 = _o_darken;
                                let _e475 = _o_darken;
                                colR = (_e472 * vec4<f32>(_e473, _e474, _e475, 1f));
                            }
                        } else {
                            let _e479 = backgroundStyle_1;
                            if (_e479 == 2i) {
                                {
                                    let _e482 = sourceDim_1;
                                    let _e484 = sourceDim_1;
                                    _o_ratio_1 = (_e482.y / _e484.x);
                                    let _e492 = refractDirR;
                                    let _e495 = refractDirR;
                                    let _e498 = _o_ratio_1;
                                    let _e501 = refractDirR;
                                    let _e504 = refractDirR;
                                    let _e507 = _o_ratio_1;
                                    if ((abs(_e492.y) > (abs(_e495.z) * _e498)) && (abs(_e501.y) > (abs(_e504.x) * _e507))) {
                                        {
                                            let _e511 = _o_X;
                                            let _e512 = refractDirR;
                                            let _e515 = refractDirR;
                                            _o_X = (_e511 + ((-(_e512.x) / _e515.y) * 0.5f));
                                            let _e521 = _o_Y;
                                            let _e522 = refractDirR;
                                            let _e525 = refractDirR;
                                            _o_Y = (_e521 + ((-(_e522.z) / _e525.y) * 0.5f));
                                        }
                                    } else {
                                        let _e531 = refractDirR;
                                        let _e534 = refractDirR;
                                        if (abs(_e531.x) < abs(_e534.z)) {
                                            {
                                                let _e538 = _o_X;
                                                let _e539 = refractDirR;
                                                let _e541 = refractDirR;
                                                let _e545 = _o_ratio_1;
                                                let _e549 = refractDirR;
                                                _o_X = (_e538 + ((((_e539.x / abs(_e541.z)) * _e545) * 0.5f) * -(sign(_e549.z))));
                                                let _e555 = _o_Y;
                                                let _e556 = refractDirR;
                                                let _e558 = refractDirR;
                                                _o_Y = (_e555 + ((_e556.y / abs(_e558.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e565 = _o_X;
                                                let _e566 = refractDirR;
                                                let _e568 = refractDirR;
                                                let _e572 = _o_ratio_1;
                                                let _e576 = refractDirR;
                                                _o_X = (_e565 + ((((_e566.z / abs(_e568.x)) * _e572) * 0.5f) * -(sign(_e576.x))));
                                                let _e582 = _o_Y;
                                                let _e583 = refractDirR;
                                                let _e585 = refractDirR;
                                                _o_Y = (_e582 + ((_e583.y / abs(_e585.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e592 = _o_X;
                                    let _e593 = _o_Y;
                                    let _e598 = global.U[0];
                                    let _e601 = _o_X;
                                    let _e602 = _o_Y;
                                    let _e613 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e592, _e593).x / _e598.x), vec2<f32>(_e601, _e602).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colR = _e613;
                                }
                            } else {
                                {
                                    let _e614 = refractDirR;
                                    let _e619 = ((_e614 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e619.x, _e619.y, _e619.z, 1f);
                                }
                            }
                        }
                    }
                    let _e625 = backgroundStyle_1;
                    if (_e625 == 0i) {
                        {
                            let _e628 = refractDirG;
                            _o_n_1 = normalize(_e628);
                            let _e631 = _o_n_1;
                            let _e633 = _o_n_1;
                            _o_alpha_1 = atan2(_e631.z, _e633.x);
                            let _e637 = _o_n_1;
                            _o_beta_1 = asin(_e637.y);
                            let _e641 = sourceDim_1;
                            let _e643 = sourceDim_1;
                            _o_ratio_2 = (_e641.x / _e643.y);
                            let _e651 = _o_alpha_1;
                            let _e657 = _o_nX_1;
                            let _e660 = _o_nY_1;
                            let _e661 = _o_beta_1;
                            let _e670 = global.U[0];
                            let _e673 = _o_alpha_1;
                            let _e679 = _o_nX_1;
                            let _e682 = _o_nY_1;
                            let _e683 = _o_beta_1;
                            let _e698 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e651) / 3.1415927f) * 0.5f) * _e657), (0.5f + ((_e660 * _e661) / 3.1415927f))).x / _e670.x), vec2<f32>((((-(_e673) / 3.1415927f) * 0.5f) * _e679), (0.5f + ((_e682 * _e683) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colG = _e698;
                        }
                    } else {
                        let _e699 = backgroundStyle_1;
                        if (_e699 == 1i) {
                            {
                                let _e702 = refractDirG;
                                let _e705 = refractDirG;
                                let _e708 = refractDirG;
                                let _e711 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e702.x) / _e705.z), (-(_e708.y) / _e711.z)) * 1f);
                                let _e718 = _o_pos_1;
                                let _e721 = _o_pos_1;
                                _o_m_1 = max(abs(_e718.x), abs(_e721.y));
                                let _e728 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e728));
                                let _e732 = _o_pos_1;
                                let _e736 = global.U[0];
                                let _e739 = _o_pos_1;
                                let _e749 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e732.x / _e736.x), _e739.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e750 = _o_darken_1;
                                let _e751 = _o_darken_1;
                                let _e752 = _o_darken_1;
                                colG = (_e749 * vec4<f32>(_e750, _e751, _e752, 1f));
                            }
                        } else {
                            let _e756 = backgroundStyle_1;
                            if (_e756 == 2i) {
                                {
                                    let _e759 = sourceDim_1;
                                    let _e761 = sourceDim_1;
                                    _o_ratio_3 = (_e759.y / _e761.x);
                                    let _e769 = refractDirG;
                                    let _e772 = refractDirG;
                                    let _e775 = _o_ratio_3;
                                    let _e778 = refractDirG;
                                    let _e781 = refractDirG;
                                    let _e784 = _o_ratio_3;
                                    if ((abs(_e769.y) > (abs(_e772.z) * _e775)) && (abs(_e778.y) > (abs(_e781.x) * _e784))) {
                                        {
                                            let _e788 = _o_X_1;
                                            let _e789 = refractDirG;
                                            let _e792 = refractDirG;
                                            _o_X_1 = (_e788 + ((-(_e789.x) / _e792.y) * 0.5f));
                                            let _e798 = _o_Y_1;
                                            let _e799 = refractDirG;
                                            let _e802 = refractDirG;
                                            _o_Y_1 = (_e798 + ((-(_e799.z) / _e802.y) * 0.5f));
                                        }
                                    } else {
                                        let _e808 = refractDirG;
                                        let _e811 = refractDirG;
                                        if (abs(_e808.x) < abs(_e811.z)) {
                                            {
                                                let _e815 = _o_X_1;
                                                let _e816 = refractDirG;
                                                let _e818 = refractDirG;
                                                let _e822 = _o_ratio_3;
                                                let _e826 = refractDirG;
                                                _o_X_1 = (_e815 + ((((_e816.x / abs(_e818.z)) * _e822) * 0.5f) * -(sign(_e826.z))));
                                                let _e832 = _o_Y_1;
                                                let _e833 = refractDirG;
                                                let _e835 = refractDirG;
                                                _o_Y_1 = (_e832 + ((_e833.y / abs(_e835.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e842 = _o_X_1;
                                                let _e843 = refractDirG;
                                                let _e845 = refractDirG;
                                                let _e849 = _o_ratio_3;
                                                let _e853 = refractDirG;
                                                _o_X_1 = (_e842 + ((((_e843.z / abs(_e845.x)) * _e849) * 0.5f) * -(sign(_e853.x))));
                                                let _e859 = _o_Y_1;
                                                let _e860 = refractDirG;
                                                let _e862 = refractDirG;
                                                _o_Y_1 = (_e859 + ((_e860.y / abs(_e862.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e869 = _o_X_1;
                                    let _e870 = _o_Y_1;
                                    let _e875 = global.U[0];
                                    let _e878 = _o_X_1;
                                    let _e879 = _o_Y_1;
                                    let _e890 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e869, _e870).x / _e875.x), vec2<f32>(_e878, _e879).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colG = _e890;
                                }
                            } else {
                                {
                                    let _e891 = refractDirG;
                                    let _e896 = ((_e891 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e896.x, _e896.y, _e896.z, 1f);
                                }
                            }
                        }
                    }
                    let _e902 = backgroundStyle_1;
                    if (_e902 == 0i) {
                        {
                            let _e905 = refractDirB;
                            _o_n_2 = normalize(_e905);
                            let _e908 = _o_n_2;
                            let _e910 = _o_n_2;
                            _o_alpha_2 = atan2(_e908.z, _e910.x);
                            let _e914 = _o_n_2;
                            _o_beta_2 = asin(_e914.y);
                            let _e918 = sourceDim_1;
                            let _e920 = sourceDim_1;
                            _o_ratio_4 = (_e918.x / _e920.y);
                            let _e928 = _o_alpha_2;
                            let _e934 = _o_nX_2;
                            let _e937 = _o_nY_2;
                            let _e938 = _o_beta_2;
                            let _e947 = global.U[0];
                            let _e950 = _o_alpha_2;
                            let _e956 = _o_nX_2;
                            let _e959 = _o_nY_2;
                            let _e960 = _o_beta_2;
                            let _e975 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e928) / 3.1415927f) * 0.5f) * _e934), (0.5f + ((_e937 * _e938) / 3.1415927f))).x / _e947.x), vec2<f32>((((-(_e950) / 3.1415927f) * 0.5f) * _e956), (0.5f + ((_e959 * _e960) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colB = _e975;
                        }
                    } else {
                        let _e976 = backgroundStyle_1;
                        if (_e976 == 1i) {
                            {
                                let _e979 = refractDirB;
                                let _e982 = refractDirB;
                                let _e985 = refractDirB;
                                let _e988 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e979.x) / _e982.z), (-(_e985.y) / _e988.z)) * 1f);
                                let _e995 = _o_pos_2;
                                let _e998 = _o_pos_2;
                                _o_m_2 = max(abs(_e995.x), abs(_e998.y));
                                let _e1005 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1005));
                                let _e1009 = _o_pos_2;
                                let _e1013 = global.U[0];
                                let _e1016 = _o_pos_2;
                                let _e1026 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1009.x / _e1013.x), _e1016.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1027 = _o_darken_2;
                                let _e1028 = _o_darken_2;
                                let _e1029 = _o_darken_2;
                                colB = (_e1026 * vec4<f32>(_e1027, _e1028, _e1029, 1f));
                            }
                        } else {
                            let _e1033 = backgroundStyle_1;
                            if (_e1033 == 2i) {
                                {
                                    let _e1036 = sourceDim_1;
                                    let _e1038 = sourceDim_1;
                                    _o_ratio_5 = (_e1036.y / _e1038.x);
                                    let _e1046 = refractDirB;
                                    let _e1049 = refractDirB;
                                    let _e1052 = _o_ratio_5;
                                    let _e1055 = refractDirB;
                                    let _e1058 = refractDirB;
                                    let _e1061 = _o_ratio_5;
                                    if ((abs(_e1046.y) > (abs(_e1049.z) * _e1052)) && (abs(_e1055.y) > (abs(_e1058.x) * _e1061))) {
                                        {
                                            let _e1065 = _o_X_2;
                                            let _e1066 = refractDirB;
                                            let _e1069 = refractDirB;
                                            _o_X_2 = (_e1065 + ((-(_e1066.x) / _e1069.y) * 0.5f));
                                            let _e1075 = _o_Y_2;
                                            let _e1076 = refractDirB;
                                            let _e1079 = refractDirB;
                                            _o_Y_2 = (_e1075 + ((-(_e1076.z) / _e1079.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1085 = refractDirB;
                                        let _e1088 = refractDirB;
                                        if (abs(_e1085.x) < abs(_e1088.z)) {
                                            {
                                                let _e1092 = _o_X_2;
                                                let _e1093 = refractDirB;
                                                let _e1095 = refractDirB;
                                                let _e1099 = _o_ratio_5;
                                                let _e1103 = refractDirB;
                                                _o_X_2 = (_e1092 + ((((_e1093.x / abs(_e1095.z)) * _e1099) * 0.5f) * -(sign(_e1103.z))));
                                                let _e1109 = _o_Y_2;
                                                let _e1110 = refractDirB;
                                                let _e1112 = refractDirB;
                                                _o_Y_2 = (_e1109 + ((_e1110.y / abs(_e1112.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1119 = _o_X_2;
                                                let _e1120 = refractDirB;
                                                let _e1122 = refractDirB;
                                                let _e1126 = _o_ratio_5;
                                                let _e1130 = refractDirB;
                                                _o_X_2 = (_e1119 + ((((_e1120.z / abs(_e1122.x)) * _e1126) * 0.5f) * -(sign(_e1130.x))));
                                                let _e1136 = _o_Y_2;
                                                let _e1137 = refractDirB;
                                                let _e1139 = refractDirB;
                                                _o_Y_2 = (_e1136 + ((_e1137.y / abs(_e1139.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1146 = _o_X_2;
                                    let _e1147 = _o_Y_2;
                                    let _e1152 = global.U[0];
                                    let _e1155 = _o_X_2;
                                    let _e1156 = _o_Y_2;
                                    let _e1167 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1146, _e1147).x / _e1152.x), vec2<f32>(_e1155, _e1156).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colB = _e1167;
                                }
                            } else {
                                {
                                    let _e1168 = refractDirB;
                                    let _e1173 = ((_e1168 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1173.x, _e1173.y, _e1173.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1179 = colR;
                    let _e1181 = colG;
                    let _e1183 = colB;
                    col = vec4<f32>(_e1179.x, _e1181.y, _e1183.z, 1f);
                    let _e1189 = absorption;
                    let _e1190 = qIn;
                    let _e1191 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1189 * length((_e1190 - _e1191)))));
                    let _e1199 = absorbed;
                    let _e1202 = colorMaterial_1;
                    absorbed = mix(0f, _e1199, smoothstep(0f, 0.1f, _e1202.w));
                    let _e1206 = color;
                    let _e1208 = color;
                    let _e1210 = colorMaterial_1;
                    let _e1213 = fresnel;
                    let _e1217 = absorbed;
                    let _e1220 = col;
                    let _e1223 = (_e1208.xyz + (((_e1210.xyz * (1f - _e1213)) * (1f - _e1217)) * _e1220.xyz));
                    color.x = _e1223.x;
                    color.y = _e1223.y;
                    color.z = _e1223.z;
                    let _e1230 = color;
                    let _e1232 = color;
                    let _e1234 = absorbed;
                    let _e1235 = colorMaterial_1;
                    let _e1238 = ambientColor_1;
                    let _e1241 = nIn;
                    let _e1242 = lightDir;
                    let _e1245 = sourceColor_1;
                    let _e1250 = (_e1232.xyz + ((_e1234 * _e1235.xyz) * (_e1238.xyz + (max(0f, dot(_e1241, _e1242)) * _e1245.xyz))));
                    color.x = _e1250.x;
                    color.y = _e1250.y;
                    color.z = _e1250.z;
                }
            }
            let _e1257 = fresnel;
            let _e1260 = specular_1;
            if ((_e1257 != 0f) || (_e1260 != 0f)) {
                {
                    let _e1264 = reflectDir;
                    origReflectDir = _e1264;
                    let _e1266 = qIn;
                    let _e1267 = nIn;
                    let _e1271 = reflectDir;
                    let _e1273 = roundness_7;
                    let _e1274 = rayMarch((_e1266 + (_e1267 * 0.001f)), _e1271, 1f, _e1273);
                    qR = _e1274;
                    let _e1276 = qR;
                    if (_e1276.x != 100000000000000000000f) {
                        {
                            let _e1280 = qR;
                            let _e1281 = roundness_7;
                            let _e1282 = normal(_e1280, _e1281);
                            n_1 = _e1282;
                            let _e1284 = reflectDir;
                            let _e1285 = n_1;
                            reflectDir = reflect(_e1284, _e1285);
                        }
                    }
                    let _e1287 = model3DTransform3_;
                    let _e1288 = reflectDir;
                    reflectDir = (_e1287 * _e1288);
                    let _e1290 = backgroundStyle_1;
                    if (_e1290 == 0i) {
                        {
                            let _e1293 = reflectDir;
                            _o_n_3 = normalize(_e1293);
                            let _e1296 = _o_n_3;
                            let _e1298 = _o_n_3;
                            _o_alpha_3 = atan2(_e1296.z, _e1298.x);
                            let _e1302 = _o_n_3;
                            _o_beta_3 = asin(_e1302.y);
                            let _e1306 = sourceDim_1;
                            let _e1308 = sourceDim_1;
                            _o_ratio_6 = (_e1306.x / _e1308.y);
                            let _e1316 = _o_alpha_3;
                            let _e1322 = _o_nX_3;
                            let _e1325 = _o_nY_3;
                            let _e1326 = _o_beta_3;
                            let _e1335 = global.U[0];
                            let _e1338 = _o_alpha_3;
                            let _e1344 = _o_nX_3;
                            let _e1347 = _o_nY_3;
                            let _e1348 = _o_beta_3;
                            let _e1363 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1316) / 3.1415927f) * 0.5f) * _e1322), (0.5f + ((_e1325 * _e1326) / 3.1415927f))).x / _e1335.x), vec2<f32>((((-(_e1338) / 3.1415927f) * 0.5f) * _e1344), (0.5f + ((_e1347 * _e1348) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1363;
                        }
                    } else {
                        let _e1364 = backgroundStyle_1;
                        if (_e1364 == 1i) {
                            {
                                let _e1367 = reflectDir;
                                let _e1370 = reflectDir;
                                let _e1373 = reflectDir;
                                let _e1376 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1367.x) / _e1370.z), (-(_e1373.y) / _e1376.z)) * 1f);
                                let _e1383 = _o_pos_3;
                                let _e1386 = _o_pos_3;
                                _o_m_3 = max(abs(_e1383.x), abs(_e1386.y));
                                let _e1393 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1393));
                                let _e1397 = _o_pos_3;
                                let _e1401 = global.U[0];
                                let _e1404 = _o_pos_3;
                                let _e1414 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1397.x / _e1401.x), _e1404.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1415 = _o_darken_3;
                                let _e1416 = _o_darken_3;
                                let _e1417 = _o_darken_3;
                                col = (_e1414 * vec4<f32>(_e1415, _e1416, _e1417, 1f));
                            }
                        } else {
                            let _e1421 = backgroundStyle_1;
                            if (_e1421 == 2i) {
                                {
                                    let _e1424 = sourceDim_1;
                                    let _e1426 = sourceDim_1;
                                    _o_ratio_7 = (_e1424.y / _e1426.x);
                                    let _e1434 = reflectDir;
                                    let _e1437 = reflectDir;
                                    let _e1440 = _o_ratio_7;
                                    let _e1443 = reflectDir;
                                    let _e1446 = reflectDir;
                                    let _e1449 = _o_ratio_7;
                                    if ((abs(_e1434.y) > (abs(_e1437.z) * _e1440)) && (abs(_e1443.y) > (abs(_e1446.x) * _e1449))) {
                                        {
                                            let _e1453 = _o_X_3;
                                            let _e1454 = reflectDir;
                                            let _e1457 = reflectDir;
                                            _o_X_3 = (_e1453 + ((-(_e1454.x) / _e1457.y) * 0.5f));
                                            let _e1463 = _o_Y_3;
                                            let _e1464 = reflectDir;
                                            let _e1467 = reflectDir;
                                            _o_Y_3 = (_e1463 + ((-(_e1464.z) / _e1467.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1473 = reflectDir;
                                        let _e1476 = reflectDir;
                                        if (abs(_e1473.x) < abs(_e1476.z)) {
                                            {
                                                let _e1480 = _o_X_3;
                                                let _e1481 = reflectDir;
                                                let _e1483 = reflectDir;
                                                let _e1487 = _o_ratio_7;
                                                let _e1491 = reflectDir;
                                                _o_X_3 = (_e1480 + ((((_e1481.x / abs(_e1483.z)) * _e1487) * 0.5f) * -(sign(_e1491.z))));
                                                let _e1497 = _o_Y_3;
                                                let _e1498 = reflectDir;
                                                let _e1500 = reflectDir;
                                                _o_Y_3 = (_e1497 + ((_e1498.y / abs(_e1500.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1507 = _o_X_3;
                                                let _e1508 = reflectDir;
                                                let _e1510 = reflectDir;
                                                let _e1514 = _o_ratio_7;
                                                let _e1518 = reflectDir;
                                                _o_X_3 = (_e1507 + ((((_e1508.z / abs(_e1510.x)) * _e1514) * 0.5f) * -(sign(_e1518.x))));
                                                let _e1524 = _o_Y_3;
                                                let _e1525 = reflectDir;
                                                let _e1527 = reflectDir;
                                                _o_Y_3 = (_e1524 + ((_e1525.y / abs(_e1527.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1534 = _o_X_3;
                                    let _e1535 = _o_Y_3;
                                    let _e1540 = global.U[0];
                                    let _e1543 = _o_X_3;
                                    let _e1544 = _o_Y_3;
                                    let _e1555 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1534, _e1535).x / _e1540.x), vec2<f32>(_e1543, _e1544).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e1555;
                                }
                            } else {
                                {
                                    let _e1556 = reflectDir;
                                    let _e1561 = ((_e1556 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1561.x, _e1561.y, _e1561.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1567 = color;
                    let _e1569 = color;
                    let _e1571 = fresnel;
                    let _e1572 = col;
                    let _e1575 = (_e1569.xyz + (_e1571 * _e1572.xyz));
                    color.x = _e1575.x;
                    color.y = _e1575.y;
                    color.z = _e1575.z;
                    let _e1583 = specular_1;
                    let _e1586 = lightDir;
                    let _e1587 = origReflectDir;
                    kSpec = ((10f * _e1583) * pow(max(0f, dot(_e1586, _e1587)), 9f));
                    let _e1594 = color;
                    let _e1596 = color;
                    let _e1598 = sourceColor_1;
                    let _e1600 = kSpec;
                    let _e1602 = (_e1596.xyz + (_e1598.xyz * _e1600));
                    color.x = _e1602.x;
                    color.y = _e1602.y;
                    color.z = _e1602.z;
                }
            }
            let _e1609 = colorFog_1;
            if (_e1609.w != 0f) {
                {
                    let _e1613 = camera_2;
                    let _e1614 = qIn;
                    dist = length((_e1613 - _e1614));
                    let _e1620 = colorFog_1;
                    let _e1623 = dist;
                    kFog = (1f - pow(0.4f, (_e1620.w * max(0f, (_e1623 - 0.1f)))));
                    let _e1631 = color;
                    let _e1633 = color;
                    let _e1635 = colorFog_1;
                    let _e1637 = kFog;
                    let _e1639 = mix(_e1633.xyz, _e1635.xyz, vec3(_e1637));
                    color.x = _e1639.x;
                    color.y = _e1639.y;
                    color.z = _e1639.z;
                }
            }
        }
    } else {
        {
            let _e1646 = bkgTransform_1;
            let _e1656 = model3DTransform3_;
            let _e1658 = camDir;
            camDir = ((mat3x3<f32>(_e1646[0].xyz, _e1646[1].xyz, _e1646[2].xyz) * _e1656) * _e1658);
            let _e1660 = backgroundStyle_1;
            if (_e1660 == 0i) {
                {
                    let _e1663 = camDir;
                    _o_n_4 = normalize(_e1663);
                    let _e1666 = _o_n_4;
                    let _e1668 = _o_n_4;
                    _o_alpha_4 = atan2(_e1666.z, _e1668.x);
                    let _e1672 = _o_n_4;
                    _o_beta_4 = asin(_e1672.y);
                    let _e1676 = sourceDim_1;
                    let _e1678 = sourceDim_1;
                    _o_ratio_8 = (_e1676.x / _e1678.y);
                    let _e1686 = _o_alpha_4;
                    let _e1692 = _o_nX_4;
                    let _e1695 = _o_nY_4;
                    let _e1696 = _o_beta_4;
                    let _e1705 = global.U[0];
                    let _e1708 = _o_alpha_4;
                    let _e1714 = _o_nX_4;
                    let _e1717 = _o_nY_4;
                    let _e1718 = _o_beta_4;
                    let _e1733 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1686) / 3.1415927f) * 0.5f) * _e1692), (0.5f + ((_e1695 * _e1696) / 3.1415927f))).x / _e1705.x), vec2<f32>((((-(_e1708) / 3.1415927f) * 0.5f) * _e1714), (0.5f + ((_e1717 * _e1718) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col = _e1733;
                }
            } else {
                let _e1734 = backgroundStyle_1;
                if (_e1734 == 1i) {
                    {
                        let _e1737 = camDir;
                        let _e1740 = camDir;
                        let _e1743 = camDir;
                        let _e1746 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1737.x) / _e1740.z), (-(_e1743.y) / _e1746.z)) * 1f);
                        let _e1753 = _o_pos_4;
                        let _e1756 = _o_pos_4;
                        _o_m_4 = max(abs(_e1753.x), abs(_e1756.y));
                        let _e1763 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1763));
                        let _e1767 = _o_pos_4;
                        let _e1771 = global.U[0];
                        let _e1774 = _o_pos_4;
                        let _e1784 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1767.x / _e1771.x), _e1774.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1785 = _o_darken_4;
                        let _e1786 = _o_darken_4;
                        let _e1787 = _o_darken_4;
                        col = (_e1784 * vec4<f32>(_e1785, _e1786, _e1787, 1f));
                    }
                } else {
                    let _e1791 = backgroundStyle_1;
                    if (_e1791 == 2i) {
                        {
                            let _e1794 = sourceDim_1;
                            let _e1796 = sourceDim_1;
                            _o_ratio_9 = (_e1794.y / _e1796.x);
                            let _e1804 = camDir;
                            let _e1807 = camDir;
                            let _e1810 = _o_ratio_9;
                            let _e1813 = camDir;
                            let _e1816 = camDir;
                            let _e1819 = _o_ratio_9;
                            if ((abs(_e1804.y) > (abs(_e1807.z) * _e1810)) && (abs(_e1813.y) > (abs(_e1816.x) * _e1819))) {
                                {
                                    let _e1823 = _o_X_4;
                                    let _e1824 = camDir;
                                    let _e1827 = camDir;
                                    _o_X_4 = (_e1823 + ((-(_e1824.x) / _e1827.y) * 0.5f));
                                    let _e1833 = _o_Y_4;
                                    let _e1834 = camDir;
                                    let _e1837 = camDir;
                                    _o_Y_4 = (_e1833 + ((-(_e1834.z) / _e1837.y) * 0.5f));
                                }
                            } else {
                                let _e1843 = camDir;
                                let _e1846 = camDir;
                                if (abs(_e1843.x) < abs(_e1846.z)) {
                                    {
                                        let _e1850 = _o_X_4;
                                        let _e1851 = camDir;
                                        let _e1853 = camDir;
                                        let _e1857 = _o_ratio_9;
                                        let _e1861 = camDir;
                                        _o_X_4 = (_e1850 + ((((_e1851.x / abs(_e1853.z)) * _e1857) * 0.5f) * -(sign(_e1861.z))));
                                        let _e1867 = _o_Y_4;
                                        let _e1868 = camDir;
                                        let _e1870 = camDir;
                                        _o_Y_4 = (_e1867 + ((_e1868.y / abs(_e1870.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1877 = _o_X_4;
                                        let _e1878 = camDir;
                                        let _e1880 = camDir;
                                        let _e1884 = _o_ratio_9;
                                        let _e1888 = camDir;
                                        _o_X_4 = (_e1877 + ((((_e1878.z / abs(_e1880.x)) * _e1884) * 0.5f) * -(sign(_e1888.x))));
                                        let _e1894 = _o_Y_4;
                                        let _e1895 = camDir;
                                        let _e1897 = camDir;
                                        _o_Y_4 = (_e1894 + ((_e1895.y / abs(_e1897.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1904 = _o_X_4;
                            let _e1905 = _o_Y_4;
                            let _e1910 = global.U[0];
                            let _e1913 = _o_X_4;
                            let _e1914 = _o_Y_4;
                            let _e1925 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1904, _e1905).x / _e1910.x), vec2<f32>(_e1913, _e1914).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1925;
                        }
                    } else {
                        {
                            let _e1926 = camDir;
                            let _e1931 = ((_e1926 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1931.x, _e1931.y, _e1931.z, 1f);
                        }
                    }
                }
            }
            let _e1937 = colorFog_1;
            if (_e1937.w != 0f) {
                let _e1941 = color;
                let _e1943 = colorFog_1;
                let _e1944 = _e1943.xyz;
                color.x = _e1944.x;
                color.y = _e1944.y;
                color.z = _e1944.z;
            } else {
                let _e1951 = col;
                color = _e1951;
            }
        }
    }
    let _e1952 = color;
    return clamp(_e1952, vec4(0f), vec4(1f));
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
