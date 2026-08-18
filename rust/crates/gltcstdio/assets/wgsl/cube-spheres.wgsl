struct Params {
    U: array<vec4<f32>, 34>,
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

fn sdf(p_2: vec3<f32>, radius: f32, roundness: f32) -> f32 {
    var p_3: vec3<f32>;
    var radius_1: f32;
    var roundness_1: f32;

    p_3 = p_2;
    radius_1 = radius;
    roundness_1 = roundness;
    let _e13 = p_3;
    let _e16 = sdBox(_e13, vec3(0.25f));
    let _e17 = p_3;
    let _e23 = radius_1;
    let _e28 = roundness_1;
    return (min(_e16, (length((abs(_e17) - vec3(0.25f))) - (_e23 * 0.5f))) - _e28);
}

fn normal(p_4: vec3<f32>, radius_2: f32, roundness_2: f32) -> vec3<f32> {
    var p_5: vec3<f32>;
    var radius_3: f32;
    var roundness_3: f32;
    var d: f32 = 0.0001f;
    var s: f32;

    p_5 = p_4;
    radius_3 = radius_2;
    roundness_3 = roundness_2;
    let _e15 = p_5;
    let _e16 = radius_3;
    let _e17 = roundness_3;
    let _e18 = sdf(_e15, _e16, _e17);
    s = _e18;
    let _e20 = s;
    let _e21 = p_5;
    let _e23 = d;
    let _e25 = p_5;
    let _e27 = p_5;
    let _e30 = radius_3;
    let _e31 = roundness_3;
    let _e32 = sdf(vec3<f32>((_e21.x - _e23), _e25.y, _e27.z), _e30, _e31);
    let _e34 = d;
    let _e36 = s;
    let _e37 = p_5;
    let _e39 = p_5;
    let _e41 = d;
    let _e43 = p_5;
    let _e46 = radius_3;
    let _e47 = roundness_3;
    let _e48 = sdf(vec3<f32>(_e37.x, (_e39.y - _e41), _e43.z), _e46, _e47);
    let _e50 = d;
    let _e52 = s;
    let _e53 = p_5;
    let _e55 = p_5;
    let _e57 = p_5;
    let _e59 = d;
    let _e62 = radius_3;
    let _e63 = roundness_3;
    let _e64 = sdf(vec3<f32>(_e53.x, _e55.y, (_e57.z - _e59)), _e62, _e63);
    let _e66 = d;
    return normalize(vec3<f32>(((_e20 - _e32) / _e34), ((_e36 - _e48) / _e50), ((_e52 - _e64) / _e66)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32, radius_4: f32, roundness_4: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var radius_5: f32;
    var roundness_5: f32;
    var d_1: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_6: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    radius_5 = radius_4;
    roundness_5 = roundness_4;
    let _e17 = p0_1;
    let _e18 = radius_5;
    let _e19 = roundness_5;
    let _e20 = sdf(_e17, _e18, _e19);
    d_1 = _e20;
    let _e22 = d_1;
    s_1 = sign(_e22);
    loop {
        let _e29 = step;
        let _e32 = d_1;
        if !(((_e29 < 1000i) && (_e32 < 100f))) {
            break;
        }
        {
            let _e37 = totalD;
            let _e38 = d_1;
            let _e39 = side_1;
            totalD = (_e37 + (_e38 * _e39));
            let _e42 = p0_1;
            let _e43 = totalD;
            let _e44 = dir_1;
            p_6 = (_e42 + (_e43 * _e44));
            let _e48 = p_6;
            let _e49 = radius_5;
            let _e50 = roundness_5;
            let _e51 = sdf(_e48, _e49, _e50);
            d_1 = _e51;
            let _e52 = d_1;
            if (abs(_e52) < 0.0001f) {
                let _e56 = p_6;
                return _e56;
            }
            let _e57 = step;
            step = (_e57 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32, radius_6: f32, roundness_6: f32) -> vec4<f32> {
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
    radius_7 = radius_6;
    roundness_7 = roundness_6;
    let _e50 = camera3DTransform_1;
    let _e51 = camera_2;
    camera_2 = (_e50 * vec4<f32>(_e51.x, _e51.y, _e51.z, 1f)).xyz;
    let _e62 = uv_3;
    let _e63 = camera_2;
    let _e64 = target_2;
    let _e66 = getRay(_e62, _e63, _e64, 1f);
    camDir = _e66;
    let _e68 = lightSourceTransform_1;
    lightPos = (_e68 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e77 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e77);
    let _e80 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e80[0].xyz, _e80[1].xyz, _e80[2].xyz);
    let _e91 = invModelTransform;
    let _e92 = camera_2;
    camera_2 = (_e91 * vec4<f32>(_e92.x, _e92.y, _e92.z, 1f)).xyz;
    let _e100 = uv_3;
    let _e102 = D;
    let _e104 = uv_3;
    let _e106 = D;
    dir_2 = normalize(vec3<f32>((_e100.x * _e102), (_e104.y * _e106), -1f));
    let _e113 = camera3DTransform_1;
    let _e123 = dir_2;
    dir_2 = (mat3x3<f32>(_e113[0].xyz, _e113[1].xyz, _e113[2].xyz) * _e123);
    let _e125 = invModelTransform;
    let _e135 = dir_2;
    camDir = normalize((mat3x3<f32>(_e125[0].xyz, _e125[1].xyz, _e125[2].xyz) * _e135));
    let _e150 = camera_2;
    let _e151 = camDir;
    let _e153 = radius_7;
    let _e154 = roundness_7;
    let _e155 = rayMarch(_e150, _e151, 1f, _e153, _e154);
    qIn = _e155;
    let _e157 = camDir;
    reflectDir = _e157;
    let _e162 = refractionIndex_1;
    ref_ = _e162;
    let _e164 = chromaticAberration_1;
    chromaticAbb = _e164;
    let _e170 = colorMaterial_1;
    let _e174 = colorMaterial_1;
    absorption = pow(mix(30f, 1000f, smoothstep(0.95f, 1f, _e170.w)), _e174.w);
    let _e178 = qIn;
    if (_e178.x != 100000000000000000000f) {
        {
            let _e182 = qIn;
            let _e183 = radius_7;
            let _e184 = roundness_7;
            let _e185 = normal(_e182, _e183, _e184);
            nIn = _e185;
            let _e187 = nIn;
            let _e188 = camDir;
            incidence = abs(dot(_e187, _e188));
            let _e193 = incidence;
            let _e196 = fresnelStrength_1;
            let _e203 = fresnelStrength_1;
            let _e208 = fresnelStrength_1;
            fresnel = ((pow((1f - _e193), (6f - (_e196 * 6f))) * smoothstep(0f, 0.025f, _e203)) * smoothstep(0f, 0.025f, _e208));
            let _e212 = camDir;
            let _e213 = nIn;
            reflectDir = reflect(_e212, _e213);
            let _e217 = colorMaterial_1;
            reflectivity = (vec3(1f) - _e217.xyz);
            let _e221 = reflectivity;
            reflectK = _e221;
            let _e222 = qIn;
            let _e223 = lightPos;
            lightDir = normalize((_e222 - _e223));
            let _e227 = fresnel;
            if (_e227 != 1f) {
                {
                    let _e232 = ref_;
                    let _e233 = ref_;
                    let _e236 = nIn;
                    let _e237 = camDir;
                    let _e239 = nIn;
                    let _e240 = camDir;
                    k = (1f - ((_e232 * _e233) * (1f - (dot(_e236, _e237) * dot(_e239, _e240)))));
                    let _e247 = k;
                    if (_e247 < 0f) {
                        refractDir = vec3(0f);
                    } else {
                        let _e252 = ref_;
                        let _e253 = camDir;
                        let _e255 = ref_;
                        let _e256 = nIn;
                        let _e257 = camDir;
                        let _e260 = k;
                        let _e263 = nIn;
                        refractDir = ((_e252 * _e253) - (((_e255 * dot(_e256, _e257)) + sqrt(_e260)) * _e263));
                    }
                    let _e266 = qIn;
                    let _e267 = nIn;
                    let _e271 = refractDir;
                    let _e274 = radius_7;
                    let _e275 = roundness_7;
                    let _e276 = rayMarch((_e266 - (_e267 * 0.001f)), _e271, -1f, _e274, _e275);
                    qOut = _e276;
                    let _e278 = qOut;
                    let _e279 = radius_7;
                    let _e280 = roundness_7;
                    let _e281 = normal(_e278, _e279, _e280);
                    n = -(_e281);
                    let _e284 = refractDir;
                    let _e285 = n;
                    let _e287 = ref_;
                    let _e289 = chromaticAbb;
                    rDir = refract(_e284, _e285, ((1f / _e287) - _e289));
                    let _e293 = rDir;
                    if (length(_e293) == 0f) {
                        let _e297 = refractDir;
                        let _e298 = n;
                        local = reflect(_e297, _e298);
                    } else {
                        let _e300 = rDir;
                        local = _e300;
                    }
                    let _e302 = local;
                    refractDirR = _e302;
                    let _e304 = refractDir;
                    let _e305 = n;
                    let _e307 = ref_;
                    gDir = refract(_e304, _e305, (1f / _e307));
                    let _e311 = gDir;
                    if (length(_e311) == 0f) {
                        let _e315 = refractDir;
                        let _e316 = n;
                        local_1 = reflect(_e315, _e316);
                    } else {
                        let _e318 = gDir;
                        local_1 = _e318;
                    }
                    let _e320 = local_1;
                    refractDirG = _e320;
                    let _e322 = refractDir;
                    let _e323 = n;
                    let _e325 = ref_;
                    let _e327 = chromaticAbb;
                    bDir = refract(_e322, _e323, ((1f / _e325) + _e327));
                    let _e331 = bDir;
                    if (length(_e331) == 0f) {
                        let _e335 = refractDir;
                        let _e336 = n;
                        local_2 = reflect(_e335, _e336);
                    } else {
                        let _e338 = bDir;
                        local_2 = _e338;
                    }
                    let _e340 = local_2;
                    refractDirB = _e340;
                    let _e345 = model3DTransform3_;
                    let _e346 = refractDirR;
                    refractDirR = (_e345 * _e346);
                    let _e348 = model3DTransform3_;
                    let _e349 = refractDirG;
                    refractDirG = (_e348 * _e349);
                    let _e351 = model3DTransform3_;
                    let _e352 = refractDirB;
                    refractDirB = (_e351 * _e352);
                    let _e354 = backgroundStyle_1;
                    if (_e354 == 0i) {
                        {
                            let _e357 = refractDirR;
                            _o_n = normalize(_e357);
                            let _e360 = _o_n;
                            let _e362 = _o_n;
                            _o_alpha = atan2(_e360.z, _e362.x);
                            let _e366 = _o_n;
                            _o_beta = asin(_e366.y);
                            let _e370 = sourceDim_1;
                            let _e372 = sourceDim_1;
                            _o_ratio = (_e370.x / _e372.y);
                            let _e380 = _o_alpha;
                            let _e386 = _o_nX;
                            let _e389 = _o_nY;
                            let _e390 = _o_beta;
                            let _e399 = global.U[0];
                            let _e402 = _o_alpha;
                            let _e408 = _o_nX;
                            let _e411 = _o_nY;
                            let _e412 = _o_beta;
                            let _e426 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e380) / 3.1415927f) * 0.5f) * _e386), (0.5f + ((_e389 * _e390) / 3.1415927f))).x / _e399.x), vec2<f32>((((-(_e402) / 3.1415927f) * 0.5f) * _e408), (0.5f + ((_e411 * _e412) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colR = _e426;
                        }
                    } else {
                        let _e427 = backgroundStyle_1;
                        if (_e427 == 1i) {
                            {
                                let _e430 = refractDirR;
                                let _e433 = refractDirR;
                                let _e436 = refractDirR;
                                let _e439 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e430.x) / _e433.z), (-(_e436.y) / _e439.z)) * 1f);
                                let _e446 = _o_pos;
                                let _e449 = _o_pos;
                                _o_m = max(abs(_e446.x), abs(_e449.y));
                                let _e456 = _o_m;
                                _o_darken = (4f / max(4f, _e456));
                                let _e460 = _o_pos;
                                let _e464 = global.U[0];
                                let _e467 = _o_pos;
                                let _e476 = textureSample(t_source, samp, ((vec2<f32>((_e460.x / _e464.x), _e467.y) / vec2(2f)) + vec2(0.5f)));
                                let _e477 = _o_darken;
                                let _e478 = _o_darken;
                                let _e479 = _o_darken;
                                colR = (_e476 * vec4<f32>(_e477, _e478, _e479, 1f));
                            }
                        } else {
                            let _e483 = backgroundStyle_1;
                            if (_e483 == 2i) {
                                {
                                    let _e486 = sourceDim_1;
                                    let _e488 = sourceDim_1;
                                    _o_ratio_1 = (_e486.y / _e488.x);
                                    let _e496 = refractDirR;
                                    let _e499 = refractDirR;
                                    let _e502 = _o_ratio_1;
                                    let _e505 = refractDirR;
                                    let _e508 = refractDirR;
                                    let _e511 = _o_ratio_1;
                                    if ((abs(_e496.y) > (abs(_e499.z) * _e502)) && (abs(_e505.y) > (abs(_e508.x) * _e511))) {
                                        {
                                            let _e515 = _o_X;
                                            let _e516 = refractDirR;
                                            let _e519 = refractDirR;
                                            _o_X = (_e515 + ((-(_e516.x) / _e519.y) * 0.5f));
                                            let _e525 = _o_Y;
                                            let _e526 = refractDirR;
                                            let _e529 = refractDirR;
                                            _o_Y = (_e525 + ((-(_e526.z) / _e529.y) * 0.5f));
                                        }
                                    } else {
                                        let _e535 = refractDirR;
                                        let _e538 = refractDirR;
                                        if (abs(_e535.x) < abs(_e538.z)) {
                                            {
                                                let _e542 = _o_X;
                                                let _e543 = refractDirR;
                                                let _e545 = refractDirR;
                                                let _e549 = _o_ratio_1;
                                                let _e553 = refractDirR;
                                                _o_X = (_e542 + ((((_e543.x / abs(_e545.z)) * _e549) * 0.5f) * -(sign(_e553.z))));
                                                let _e559 = _o_Y;
                                                let _e560 = refractDirR;
                                                let _e562 = refractDirR;
                                                _o_Y = (_e559 + ((_e560.y / abs(_e562.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e569 = _o_X;
                                                let _e570 = refractDirR;
                                                let _e572 = refractDirR;
                                                let _e576 = _o_ratio_1;
                                                let _e580 = refractDirR;
                                                _o_X = (_e569 + ((((_e570.z / abs(_e572.x)) * _e576) * 0.5f) * -(sign(_e580.x))));
                                                let _e586 = _o_Y;
                                                let _e587 = refractDirR;
                                                let _e589 = refractDirR;
                                                _o_Y = (_e586 + ((_e587.y / abs(_e589.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e596 = _o_X;
                                    let _e597 = _o_Y;
                                    let _e602 = global.U[0];
                                    let _e605 = _o_X;
                                    let _e606 = _o_Y;
                                    let _e616 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e596, _e597).x / _e602.x), vec2<f32>(_e605, _e606).y) / vec2(2f)) + vec2(0.5f)));
                                    colR = _e616;
                                }
                            } else {
                                {
                                    let _e617 = refractDirR;
                                    let _e622 = ((_e617 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e622.x, _e622.y, _e622.z, 1f);
                                }
                            }
                        }
                    }
                    let _e628 = backgroundStyle_1;
                    if (_e628 == 0i) {
                        {
                            let _e631 = refractDirG;
                            _o_n_1 = normalize(_e631);
                            let _e634 = _o_n_1;
                            let _e636 = _o_n_1;
                            _o_alpha_1 = atan2(_e634.z, _e636.x);
                            let _e640 = _o_n_1;
                            _o_beta_1 = asin(_e640.y);
                            let _e644 = sourceDim_1;
                            let _e646 = sourceDim_1;
                            _o_ratio_2 = (_e644.x / _e646.y);
                            let _e654 = _o_alpha_1;
                            let _e660 = _o_nX_1;
                            let _e663 = _o_nY_1;
                            let _e664 = _o_beta_1;
                            let _e673 = global.U[0];
                            let _e676 = _o_alpha_1;
                            let _e682 = _o_nX_1;
                            let _e685 = _o_nY_1;
                            let _e686 = _o_beta_1;
                            let _e700 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e654) / 3.1415927f) * 0.5f) * _e660), (0.5f + ((_e663 * _e664) / 3.1415927f))).x / _e673.x), vec2<f32>((((-(_e676) / 3.1415927f) * 0.5f) * _e682), (0.5f + ((_e685 * _e686) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colG = _e700;
                        }
                    } else {
                        let _e701 = backgroundStyle_1;
                        if (_e701 == 1i) {
                            {
                                let _e704 = refractDirG;
                                let _e707 = refractDirG;
                                let _e710 = refractDirG;
                                let _e713 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e704.x) / _e707.z), (-(_e710.y) / _e713.z)) * 1f);
                                let _e720 = _o_pos_1;
                                let _e723 = _o_pos_1;
                                _o_m_1 = max(abs(_e720.x), abs(_e723.y));
                                let _e730 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e730));
                                let _e734 = _o_pos_1;
                                let _e738 = global.U[0];
                                let _e741 = _o_pos_1;
                                let _e750 = textureSample(t_source, samp, ((vec2<f32>((_e734.x / _e738.x), _e741.y) / vec2(2f)) + vec2(0.5f)));
                                let _e751 = _o_darken_1;
                                let _e752 = _o_darken_1;
                                let _e753 = _o_darken_1;
                                colG = (_e750 * vec4<f32>(_e751, _e752, _e753, 1f));
                            }
                        } else {
                            let _e757 = backgroundStyle_1;
                            if (_e757 == 2i) {
                                {
                                    let _e760 = sourceDim_1;
                                    let _e762 = sourceDim_1;
                                    _o_ratio_3 = (_e760.y / _e762.x);
                                    let _e770 = refractDirG;
                                    let _e773 = refractDirG;
                                    let _e776 = _o_ratio_3;
                                    let _e779 = refractDirG;
                                    let _e782 = refractDirG;
                                    let _e785 = _o_ratio_3;
                                    if ((abs(_e770.y) > (abs(_e773.z) * _e776)) && (abs(_e779.y) > (abs(_e782.x) * _e785))) {
                                        {
                                            let _e789 = _o_X_1;
                                            let _e790 = refractDirG;
                                            let _e793 = refractDirG;
                                            _o_X_1 = (_e789 + ((-(_e790.x) / _e793.y) * 0.5f));
                                            let _e799 = _o_Y_1;
                                            let _e800 = refractDirG;
                                            let _e803 = refractDirG;
                                            _o_Y_1 = (_e799 + ((-(_e800.z) / _e803.y) * 0.5f));
                                        }
                                    } else {
                                        let _e809 = refractDirG;
                                        let _e812 = refractDirG;
                                        if (abs(_e809.x) < abs(_e812.z)) {
                                            {
                                                let _e816 = _o_X_1;
                                                let _e817 = refractDirG;
                                                let _e819 = refractDirG;
                                                let _e823 = _o_ratio_3;
                                                let _e827 = refractDirG;
                                                _o_X_1 = (_e816 + ((((_e817.x / abs(_e819.z)) * _e823) * 0.5f) * -(sign(_e827.z))));
                                                let _e833 = _o_Y_1;
                                                let _e834 = refractDirG;
                                                let _e836 = refractDirG;
                                                _o_Y_1 = (_e833 + ((_e834.y / abs(_e836.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e843 = _o_X_1;
                                                let _e844 = refractDirG;
                                                let _e846 = refractDirG;
                                                let _e850 = _o_ratio_3;
                                                let _e854 = refractDirG;
                                                _o_X_1 = (_e843 + ((((_e844.z / abs(_e846.x)) * _e850) * 0.5f) * -(sign(_e854.x))));
                                                let _e860 = _o_Y_1;
                                                let _e861 = refractDirG;
                                                let _e863 = refractDirG;
                                                _o_Y_1 = (_e860 + ((_e861.y / abs(_e863.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e870 = _o_X_1;
                                    let _e871 = _o_Y_1;
                                    let _e876 = global.U[0];
                                    let _e879 = _o_X_1;
                                    let _e880 = _o_Y_1;
                                    let _e890 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e870, _e871).x / _e876.x), vec2<f32>(_e879, _e880).y) / vec2(2f)) + vec2(0.5f)));
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
                            let _e974 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e928) / 3.1415927f) * 0.5f) * _e934), (0.5f + ((_e937 * _e938) / 3.1415927f))).x / _e947.x), vec2<f32>((((-(_e950) / 3.1415927f) * 0.5f) * _e956), (0.5f + ((_e959 * _e960) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colB = _e974;
                        }
                    } else {
                        let _e975 = backgroundStyle_1;
                        if (_e975 == 1i) {
                            {
                                let _e978 = refractDirB;
                                let _e981 = refractDirB;
                                let _e984 = refractDirB;
                                let _e987 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e978.x) / _e981.z), (-(_e984.y) / _e987.z)) * 1f);
                                let _e994 = _o_pos_2;
                                let _e997 = _o_pos_2;
                                _o_m_2 = max(abs(_e994.x), abs(_e997.y));
                                let _e1004 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1004));
                                let _e1008 = _o_pos_2;
                                let _e1012 = global.U[0];
                                let _e1015 = _o_pos_2;
                                let _e1024 = textureSample(t_source, samp, ((vec2<f32>((_e1008.x / _e1012.x), _e1015.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1025 = _o_darken_2;
                                let _e1026 = _o_darken_2;
                                let _e1027 = _o_darken_2;
                                colB = (_e1024 * vec4<f32>(_e1025, _e1026, _e1027, 1f));
                            }
                        } else {
                            let _e1031 = backgroundStyle_1;
                            if (_e1031 == 2i) {
                                {
                                    let _e1034 = sourceDim_1;
                                    let _e1036 = sourceDim_1;
                                    _o_ratio_5 = (_e1034.y / _e1036.x);
                                    let _e1044 = refractDirB;
                                    let _e1047 = refractDirB;
                                    let _e1050 = _o_ratio_5;
                                    let _e1053 = refractDirB;
                                    let _e1056 = refractDirB;
                                    let _e1059 = _o_ratio_5;
                                    if ((abs(_e1044.y) > (abs(_e1047.z) * _e1050)) && (abs(_e1053.y) > (abs(_e1056.x) * _e1059))) {
                                        {
                                            let _e1063 = _o_X_2;
                                            let _e1064 = refractDirB;
                                            let _e1067 = refractDirB;
                                            _o_X_2 = (_e1063 + ((-(_e1064.x) / _e1067.y) * 0.5f));
                                            let _e1073 = _o_Y_2;
                                            let _e1074 = refractDirB;
                                            let _e1077 = refractDirB;
                                            _o_Y_2 = (_e1073 + ((-(_e1074.z) / _e1077.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1083 = refractDirB;
                                        let _e1086 = refractDirB;
                                        if (abs(_e1083.x) < abs(_e1086.z)) {
                                            {
                                                let _e1090 = _o_X_2;
                                                let _e1091 = refractDirB;
                                                let _e1093 = refractDirB;
                                                let _e1097 = _o_ratio_5;
                                                let _e1101 = refractDirB;
                                                _o_X_2 = (_e1090 + ((((_e1091.x / abs(_e1093.z)) * _e1097) * 0.5f) * -(sign(_e1101.z))));
                                                let _e1107 = _o_Y_2;
                                                let _e1108 = refractDirB;
                                                let _e1110 = refractDirB;
                                                _o_Y_2 = (_e1107 + ((_e1108.y / abs(_e1110.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1117 = _o_X_2;
                                                let _e1118 = refractDirB;
                                                let _e1120 = refractDirB;
                                                let _e1124 = _o_ratio_5;
                                                let _e1128 = refractDirB;
                                                _o_X_2 = (_e1117 + ((((_e1118.z / abs(_e1120.x)) * _e1124) * 0.5f) * -(sign(_e1128.x))));
                                                let _e1134 = _o_Y_2;
                                                let _e1135 = refractDirB;
                                                let _e1137 = refractDirB;
                                                _o_Y_2 = (_e1134 + ((_e1135.y / abs(_e1137.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1144 = _o_X_2;
                                    let _e1145 = _o_Y_2;
                                    let _e1150 = global.U[0];
                                    let _e1153 = _o_X_2;
                                    let _e1154 = _o_Y_2;
                                    let _e1164 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1144, _e1145).x / _e1150.x), vec2<f32>(_e1153, _e1154).y) / vec2(2f)) + vec2(0.5f)));
                                    colB = _e1164;
                                }
                            } else {
                                {
                                    let _e1165 = refractDirB;
                                    let _e1170 = ((_e1165 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1170.x, _e1170.y, _e1170.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1176 = colR;
                    let _e1178 = colG;
                    let _e1180 = colB;
                    col = vec4<f32>(_e1176.x, _e1178.y, _e1180.z, 1f);
                    let _e1186 = absorption;
                    let _e1187 = qIn;
                    let _e1188 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1186 * length((_e1187 - _e1188)))));
                    let _e1196 = absorbed;
                    let _e1199 = colorMaterial_1;
                    absorbed = mix(0f, _e1196, smoothstep(0f, 0.1f, _e1199.w));
                    let _e1203 = color;
                    let _e1205 = color;
                    let _e1207 = colorMaterial_1;
                    let _e1210 = fresnel;
                    let _e1214 = absorbed;
                    let _e1217 = col;
                    let _e1220 = (_e1205.xyz + (((_e1207.xyz * (1f - _e1210)) * (1f - _e1214)) * _e1217.xyz));
                    color.x = _e1220.x;
                    color.y = _e1220.y;
                    color.z = _e1220.z;
                    let _e1227 = color;
                    let _e1229 = color;
                    let _e1231 = absorbed;
                    let _e1232 = colorMaterial_1;
                    let _e1235 = ambientColor_1;
                    let _e1238 = nIn;
                    let _e1239 = lightDir;
                    let _e1242 = sourceColor_1;
                    let _e1247 = (_e1229.xyz + ((_e1231 * _e1232.xyz) * (_e1235.xyz + (max(0f, dot(_e1238, _e1239)) * _e1242.xyz))));
                    color.x = _e1247.x;
                    color.y = _e1247.y;
                    color.z = _e1247.z;
                }
            }
            let _e1254 = fresnel;
            let _e1257 = specular_1;
            if ((_e1254 != 0f) || (_e1257 != 0f)) {
                {
                    let _e1261 = reflectDir;
                    origReflectDir = _e1261;
                    let _e1263 = qIn;
                    let _e1264 = nIn;
                    let _e1268 = reflectDir;
                    let _e1270 = radius_7;
                    let _e1271 = roundness_7;
                    let _e1272 = rayMarch((_e1263 + (_e1264 * 0.001f)), _e1268, 1f, _e1270, _e1271);
                    qR = _e1272;
                    let _e1274 = qR;
                    if (_e1274.x != 100000000000000000000f) {
                        {
                            let _e1278 = qR;
                            let _e1279 = radius_7;
                            let _e1280 = roundness_7;
                            let _e1281 = normal(_e1278, _e1279, _e1280);
                            n_1 = _e1281;
                            let _e1283 = reflectDir;
                            let _e1284 = n_1;
                            reflectDir = reflect(_e1283, _e1284);
                        }
                    }
                    let _e1286 = model3DTransform3_;
                    let _e1287 = reflectDir;
                    reflectDir = (_e1286 * _e1287);
                    let _e1289 = backgroundStyle_1;
                    if (_e1289 == 0i) {
                        {
                            let _e1292 = reflectDir;
                            _o_n_3 = normalize(_e1292);
                            let _e1295 = _o_n_3;
                            let _e1297 = _o_n_3;
                            _o_alpha_3 = atan2(_e1295.z, _e1297.x);
                            let _e1301 = _o_n_3;
                            _o_beta_3 = asin(_e1301.y);
                            let _e1305 = sourceDim_1;
                            let _e1307 = sourceDim_1;
                            _o_ratio_6 = (_e1305.x / _e1307.y);
                            let _e1315 = _o_alpha_3;
                            let _e1321 = _o_nX_3;
                            let _e1324 = _o_nY_3;
                            let _e1325 = _o_beta_3;
                            let _e1334 = global.U[0];
                            let _e1337 = _o_alpha_3;
                            let _e1343 = _o_nX_3;
                            let _e1346 = _o_nY_3;
                            let _e1347 = _o_beta_3;
                            let _e1361 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1315) / 3.1415927f) * 0.5f) * _e1321), (0.5f + ((_e1324 * _e1325) / 3.1415927f))).x / _e1334.x), vec2<f32>((((-(_e1337) / 3.1415927f) * 0.5f) * _e1343), (0.5f + ((_e1346 * _e1347) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1361;
                        }
                    } else {
                        let _e1362 = backgroundStyle_1;
                        if (_e1362 == 1i) {
                            {
                                let _e1365 = reflectDir;
                                let _e1368 = reflectDir;
                                let _e1371 = reflectDir;
                                let _e1374 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1365.x) / _e1368.z), (-(_e1371.y) / _e1374.z)) * 1f);
                                let _e1381 = _o_pos_3;
                                let _e1384 = _o_pos_3;
                                _o_m_3 = max(abs(_e1381.x), abs(_e1384.y));
                                let _e1391 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1391));
                                let _e1395 = _o_pos_3;
                                let _e1399 = global.U[0];
                                let _e1402 = _o_pos_3;
                                let _e1411 = textureSample(t_source, samp, ((vec2<f32>((_e1395.x / _e1399.x), _e1402.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1412 = _o_darken_3;
                                let _e1413 = _o_darken_3;
                                let _e1414 = _o_darken_3;
                                col = (_e1411 * vec4<f32>(_e1412, _e1413, _e1414, 1f));
                            }
                        } else {
                            let _e1418 = backgroundStyle_1;
                            if (_e1418 == 2i) {
                                {
                                    let _e1421 = sourceDim_1;
                                    let _e1423 = sourceDim_1;
                                    _o_ratio_7 = (_e1421.y / _e1423.x);
                                    let _e1431 = reflectDir;
                                    let _e1434 = reflectDir;
                                    let _e1437 = _o_ratio_7;
                                    let _e1440 = reflectDir;
                                    let _e1443 = reflectDir;
                                    let _e1446 = _o_ratio_7;
                                    if ((abs(_e1431.y) > (abs(_e1434.z) * _e1437)) && (abs(_e1440.y) > (abs(_e1443.x) * _e1446))) {
                                        {
                                            let _e1450 = _o_X_3;
                                            let _e1451 = reflectDir;
                                            let _e1454 = reflectDir;
                                            _o_X_3 = (_e1450 + ((-(_e1451.x) / _e1454.y) * 0.5f));
                                            let _e1460 = _o_Y_3;
                                            let _e1461 = reflectDir;
                                            let _e1464 = reflectDir;
                                            _o_Y_3 = (_e1460 + ((-(_e1461.z) / _e1464.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1470 = reflectDir;
                                        let _e1473 = reflectDir;
                                        if (abs(_e1470.x) < abs(_e1473.z)) {
                                            {
                                                let _e1477 = _o_X_3;
                                                let _e1478 = reflectDir;
                                                let _e1480 = reflectDir;
                                                let _e1484 = _o_ratio_7;
                                                let _e1488 = reflectDir;
                                                _o_X_3 = (_e1477 + ((((_e1478.x / abs(_e1480.z)) * _e1484) * 0.5f) * -(sign(_e1488.z))));
                                                let _e1494 = _o_Y_3;
                                                let _e1495 = reflectDir;
                                                let _e1497 = reflectDir;
                                                _o_Y_3 = (_e1494 + ((_e1495.y / abs(_e1497.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1504 = _o_X_3;
                                                let _e1505 = reflectDir;
                                                let _e1507 = reflectDir;
                                                let _e1511 = _o_ratio_7;
                                                let _e1515 = reflectDir;
                                                _o_X_3 = (_e1504 + ((((_e1505.z / abs(_e1507.x)) * _e1511) * 0.5f) * -(sign(_e1515.x))));
                                                let _e1521 = _o_Y_3;
                                                let _e1522 = reflectDir;
                                                let _e1524 = reflectDir;
                                                _o_Y_3 = (_e1521 + ((_e1522.y / abs(_e1524.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1531 = _o_X_3;
                                    let _e1532 = _o_Y_3;
                                    let _e1537 = global.U[0];
                                    let _e1540 = _o_X_3;
                                    let _e1541 = _o_Y_3;
                                    let _e1551 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1531, _e1532).x / _e1537.x), vec2<f32>(_e1540, _e1541).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e1551;
                                }
                            } else {
                                {
                                    let _e1552 = reflectDir;
                                    let _e1557 = ((_e1552 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1557.x, _e1557.y, _e1557.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1563 = color;
                    let _e1565 = color;
                    let _e1567 = fresnel;
                    let _e1568 = col;
                    let _e1571 = (_e1565.xyz + (_e1567 * _e1568.xyz));
                    color.x = _e1571.x;
                    color.y = _e1571.y;
                    color.z = _e1571.z;
                    let _e1579 = specular_1;
                    let _e1582 = lightDir;
                    let _e1583 = origReflectDir;
                    kSpec = ((10f * _e1579) * pow(max(0f, dot(_e1582, _e1583)), 9f));
                    let _e1590 = color;
                    let _e1592 = color;
                    let _e1594 = sourceColor_1;
                    let _e1596 = kSpec;
                    let _e1598 = (_e1592.xyz + (_e1594.xyz * _e1596));
                    color.x = _e1598.x;
                    color.y = _e1598.y;
                    color.z = _e1598.z;
                }
            }
            let _e1605 = colorFog_1;
            if (_e1605.w != 0f) {
                {
                    let _e1609 = camera_2;
                    let _e1610 = qIn;
                    dist = length((_e1609 - _e1610));
                    let _e1616 = colorFog_1;
                    let _e1619 = dist;
                    kFog = (1f - pow(0.4f, (_e1616.w * max(0f, (_e1619 - 0.1f)))));
                    let _e1627 = color;
                    let _e1629 = color;
                    let _e1631 = colorFog_1;
                    let _e1633 = kFog;
                    let _e1635 = mix(_e1629.xyz, _e1631.xyz, vec3(_e1633));
                    color.x = _e1635.x;
                    color.y = _e1635.y;
                    color.z = _e1635.z;
                }
            }
        }
    } else {
        {
            let _e1642 = bkgTransform_1;
            let _e1652 = model3DTransform3_;
            let _e1654 = camDir;
            camDir = ((mat3x3<f32>(_e1642[0].xyz, _e1642[1].xyz, _e1642[2].xyz) * _e1652) * _e1654);
            let _e1656 = backgroundStyle_1;
            if (_e1656 == 0i) {
                {
                    let _e1659 = camDir;
                    _o_n_4 = normalize(_e1659);
                    let _e1662 = _o_n_4;
                    let _e1664 = _o_n_4;
                    _o_alpha_4 = atan2(_e1662.z, _e1664.x);
                    let _e1668 = _o_n_4;
                    _o_beta_4 = asin(_e1668.y);
                    let _e1672 = sourceDim_1;
                    let _e1674 = sourceDim_1;
                    _o_ratio_8 = (_e1672.x / _e1674.y);
                    let _e1682 = _o_alpha_4;
                    let _e1688 = _o_nX_4;
                    let _e1691 = _o_nY_4;
                    let _e1692 = _o_beta_4;
                    let _e1701 = global.U[0];
                    let _e1704 = _o_alpha_4;
                    let _e1710 = _o_nX_4;
                    let _e1713 = _o_nY_4;
                    let _e1714 = _o_beta_4;
                    let _e1728 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1682) / 3.1415927f) * 0.5f) * _e1688), (0.5f + ((_e1691 * _e1692) / 3.1415927f))).x / _e1701.x), vec2<f32>((((-(_e1704) / 3.1415927f) * 0.5f) * _e1710), (0.5f + ((_e1713 * _e1714) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e1728;
                }
            } else {
                let _e1729 = backgroundStyle_1;
                if (_e1729 == 1i) {
                    {
                        let _e1732 = camDir;
                        let _e1735 = camDir;
                        let _e1738 = camDir;
                        let _e1741 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1732.x) / _e1735.z), (-(_e1738.y) / _e1741.z)) * 1f);
                        let _e1748 = _o_pos_4;
                        let _e1751 = _o_pos_4;
                        _o_m_4 = max(abs(_e1748.x), abs(_e1751.y));
                        let _e1758 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1758));
                        let _e1762 = _o_pos_4;
                        let _e1766 = global.U[0];
                        let _e1769 = _o_pos_4;
                        let _e1778 = textureSample(t_source, samp, ((vec2<f32>((_e1762.x / _e1766.x), _e1769.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1779 = _o_darken_4;
                        let _e1780 = _o_darken_4;
                        let _e1781 = _o_darken_4;
                        col = (_e1778 * vec4<f32>(_e1779, _e1780, _e1781, 1f));
                    }
                } else {
                    let _e1785 = backgroundStyle_1;
                    if (_e1785 == 2i) {
                        {
                            let _e1788 = sourceDim_1;
                            let _e1790 = sourceDim_1;
                            _o_ratio_9 = (_e1788.y / _e1790.x);
                            let _e1798 = camDir;
                            let _e1801 = camDir;
                            let _e1804 = _o_ratio_9;
                            let _e1807 = camDir;
                            let _e1810 = camDir;
                            let _e1813 = _o_ratio_9;
                            if ((abs(_e1798.y) > (abs(_e1801.z) * _e1804)) && (abs(_e1807.y) > (abs(_e1810.x) * _e1813))) {
                                {
                                    let _e1817 = _o_X_4;
                                    let _e1818 = camDir;
                                    let _e1821 = camDir;
                                    _o_X_4 = (_e1817 + ((-(_e1818.x) / _e1821.y) * 0.5f));
                                    let _e1827 = _o_Y_4;
                                    let _e1828 = camDir;
                                    let _e1831 = camDir;
                                    _o_Y_4 = (_e1827 + ((-(_e1828.z) / _e1831.y) * 0.5f));
                                }
                            } else {
                                let _e1837 = camDir;
                                let _e1840 = camDir;
                                if (abs(_e1837.x) < abs(_e1840.z)) {
                                    {
                                        let _e1844 = _o_X_4;
                                        let _e1845 = camDir;
                                        let _e1847 = camDir;
                                        let _e1851 = _o_ratio_9;
                                        let _e1855 = camDir;
                                        _o_X_4 = (_e1844 + ((((_e1845.x / abs(_e1847.z)) * _e1851) * 0.5f) * -(sign(_e1855.z))));
                                        let _e1861 = _o_Y_4;
                                        let _e1862 = camDir;
                                        let _e1864 = camDir;
                                        _o_Y_4 = (_e1861 + ((_e1862.y / abs(_e1864.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1871 = _o_X_4;
                                        let _e1872 = camDir;
                                        let _e1874 = camDir;
                                        let _e1878 = _o_ratio_9;
                                        let _e1882 = camDir;
                                        _o_X_4 = (_e1871 + ((((_e1872.z / abs(_e1874.x)) * _e1878) * 0.5f) * -(sign(_e1882.x))));
                                        let _e1888 = _o_Y_4;
                                        let _e1889 = camDir;
                                        let _e1891 = camDir;
                                        _o_Y_4 = (_e1888 + ((_e1889.y / abs(_e1891.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1898 = _o_X_4;
                            let _e1899 = _o_Y_4;
                            let _e1904 = global.U[0];
                            let _e1907 = _o_X_4;
                            let _e1908 = _o_Y_4;
                            let _e1918 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1898, _e1899).x / _e1904.x), vec2<f32>(_e1907, _e1908).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1918;
                        }
                    } else {
                        {
                            let _e1919 = camDir;
                            let _e1924 = ((_e1919 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1924.x, _e1924.y, _e1924.z, 1f);
                        }
                    }
                }
            }
            let _e1930 = colorFog_1;
            if (_e1930.w != 0f) {
                let _e1934 = color;
                let _e1936 = colorFog_1;
                let _e1937 = _e1936.xyz;
                color.x = _e1937.x;
                color.y = _e1937.y;
                color.z = _e1937.z;
            } else {
                let _e1944 = col;
                color = _e1944;
            }
        }
    }
    let _e1945 = color;
    return clamp(_e1945, vec4(0f), vec4(1f));
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
    let _e240 = global.U[33];
    let _e242 = rayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)), mat4x4<f32>(vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w)), _e203, _e206.x, _e210.x, _e214.x, _e218, _e221, _e224, _e227.x, i32(_e231.x), _e236.x, _e240.x);
    fragColor = _e242;
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
