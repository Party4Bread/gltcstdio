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
                            let _e427 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e380) / 3.1415927f) * 0.5f) * _e386), (0.5f + ((_e389 * _e390) / 3.1415927f))).x / _e399.x), vec2<f32>((((-(_e402) / 3.1415927f) * 0.5f) * _e408), (0.5f + ((_e411 * _e412) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colR = _e427;
                        }
                    } else {
                        let _e428 = backgroundStyle_1;
                        if (_e428 == 1i) {
                            {
                                let _e431 = refractDirR;
                                let _e434 = refractDirR;
                                let _e437 = refractDirR;
                                let _e440 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e431.x) / _e434.z), (-(_e437.y) / _e440.z)) * 1f);
                                let _e447 = _o_pos;
                                let _e450 = _o_pos;
                                _o_m = max(abs(_e447.x), abs(_e450.y));
                                let _e457 = _o_m;
                                _o_darken = (4f / max(4f, _e457));
                                let _e461 = _o_pos;
                                let _e465 = global.U[0];
                                let _e468 = _o_pos;
                                let _e478 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e461.x / _e465.x), _e468.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e479 = _o_darken;
                                let _e480 = _o_darken;
                                let _e481 = _o_darken;
                                colR = (_e478 * vec4<f32>(_e479, _e480, _e481, 1f));
                            }
                        } else {
                            let _e485 = backgroundStyle_1;
                            if (_e485 == 2i) {
                                {
                                    let _e488 = sourceDim_1;
                                    let _e490 = sourceDim_1;
                                    _o_ratio_1 = (_e488.y / _e490.x);
                                    let _e498 = refractDirR;
                                    let _e501 = refractDirR;
                                    let _e504 = _o_ratio_1;
                                    let _e507 = refractDirR;
                                    let _e510 = refractDirR;
                                    let _e513 = _o_ratio_1;
                                    if ((abs(_e498.y) > (abs(_e501.z) * _e504)) && (abs(_e507.y) > (abs(_e510.x) * _e513))) {
                                        {
                                            let _e517 = _o_X;
                                            let _e518 = refractDirR;
                                            let _e521 = refractDirR;
                                            _o_X = (_e517 + ((-(_e518.x) / _e521.y) * 0.5f));
                                            let _e527 = _o_Y;
                                            let _e528 = refractDirR;
                                            let _e531 = refractDirR;
                                            _o_Y = (_e527 + ((-(_e528.z) / _e531.y) * 0.5f));
                                        }
                                    } else {
                                        let _e537 = refractDirR;
                                        let _e540 = refractDirR;
                                        if (abs(_e537.x) < abs(_e540.z)) {
                                            {
                                                let _e544 = _o_X;
                                                let _e545 = refractDirR;
                                                let _e547 = refractDirR;
                                                let _e551 = _o_ratio_1;
                                                let _e555 = refractDirR;
                                                _o_X = (_e544 + ((((_e545.x / abs(_e547.z)) * _e551) * 0.5f) * -(sign(_e555.z))));
                                                let _e561 = _o_Y;
                                                let _e562 = refractDirR;
                                                let _e564 = refractDirR;
                                                _o_Y = (_e561 + ((_e562.y / abs(_e564.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e571 = _o_X;
                                                let _e572 = refractDirR;
                                                let _e574 = refractDirR;
                                                let _e578 = _o_ratio_1;
                                                let _e582 = refractDirR;
                                                _o_X = (_e571 + ((((_e572.z / abs(_e574.x)) * _e578) * 0.5f) * -(sign(_e582.x))));
                                                let _e588 = _o_Y;
                                                let _e589 = refractDirR;
                                                let _e591 = refractDirR;
                                                _o_Y = (_e588 + ((_e589.y / abs(_e591.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e598 = _o_X;
                                    let _e599 = _o_Y;
                                    let _e604 = global.U[0];
                                    let _e607 = _o_X;
                                    let _e608 = _o_Y;
                                    let _e619 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e598, _e599).x / _e604.x), vec2<f32>(_e607, _e608).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colR = _e619;
                                }
                            } else {
                                {
                                    let _e620 = refractDirR;
                                    let _e625 = ((_e620 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e625.x, _e625.y, _e625.z, 1f);
                                }
                            }
                        }
                    }
                    let _e631 = backgroundStyle_1;
                    if (_e631 == 0i) {
                        {
                            let _e634 = refractDirG;
                            _o_n_1 = normalize(_e634);
                            let _e637 = _o_n_1;
                            let _e639 = _o_n_1;
                            _o_alpha_1 = atan2(_e637.z, _e639.x);
                            let _e643 = _o_n_1;
                            _o_beta_1 = asin(_e643.y);
                            let _e647 = sourceDim_1;
                            let _e649 = sourceDim_1;
                            _o_ratio_2 = (_e647.x / _e649.y);
                            let _e657 = _o_alpha_1;
                            let _e663 = _o_nX_1;
                            let _e666 = _o_nY_1;
                            let _e667 = _o_beta_1;
                            let _e676 = global.U[0];
                            let _e679 = _o_alpha_1;
                            let _e685 = _o_nX_1;
                            let _e688 = _o_nY_1;
                            let _e689 = _o_beta_1;
                            let _e704 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e657) / 3.1415927f) * 0.5f) * _e663), (0.5f + ((_e666 * _e667) / 3.1415927f))).x / _e676.x), vec2<f32>((((-(_e679) / 3.1415927f) * 0.5f) * _e685), (0.5f + ((_e688 * _e689) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colG = _e704;
                        }
                    } else {
                        let _e705 = backgroundStyle_1;
                        if (_e705 == 1i) {
                            {
                                let _e708 = refractDirG;
                                let _e711 = refractDirG;
                                let _e714 = refractDirG;
                                let _e717 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e708.x) / _e711.z), (-(_e714.y) / _e717.z)) * 1f);
                                let _e724 = _o_pos_1;
                                let _e727 = _o_pos_1;
                                _o_m_1 = max(abs(_e724.x), abs(_e727.y));
                                let _e734 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e734));
                                let _e738 = _o_pos_1;
                                let _e742 = global.U[0];
                                let _e745 = _o_pos_1;
                                let _e755 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e738.x / _e742.x), _e745.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e756 = _o_darken_1;
                                let _e757 = _o_darken_1;
                                let _e758 = _o_darken_1;
                                colG = (_e755 * vec4<f32>(_e756, _e757, _e758, 1f));
                            }
                        } else {
                            let _e762 = backgroundStyle_1;
                            if (_e762 == 2i) {
                                {
                                    let _e765 = sourceDim_1;
                                    let _e767 = sourceDim_1;
                                    _o_ratio_3 = (_e765.y / _e767.x);
                                    let _e775 = refractDirG;
                                    let _e778 = refractDirG;
                                    let _e781 = _o_ratio_3;
                                    let _e784 = refractDirG;
                                    let _e787 = refractDirG;
                                    let _e790 = _o_ratio_3;
                                    if ((abs(_e775.y) > (abs(_e778.z) * _e781)) && (abs(_e784.y) > (abs(_e787.x) * _e790))) {
                                        {
                                            let _e794 = _o_X_1;
                                            let _e795 = refractDirG;
                                            let _e798 = refractDirG;
                                            _o_X_1 = (_e794 + ((-(_e795.x) / _e798.y) * 0.5f));
                                            let _e804 = _o_Y_1;
                                            let _e805 = refractDirG;
                                            let _e808 = refractDirG;
                                            _o_Y_1 = (_e804 + ((-(_e805.z) / _e808.y) * 0.5f));
                                        }
                                    } else {
                                        let _e814 = refractDirG;
                                        let _e817 = refractDirG;
                                        if (abs(_e814.x) < abs(_e817.z)) {
                                            {
                                                let _e821 = _o_X_1;
                                                let _e822 = refractDirG;
                                                let _e824 = refractDirG;
                                                let _e828 = _o_ratio_3;
                                                let _e832 = refractDirG;
                                                _o_X_1 = (_e821 + ((((_e822.x / abs(_e824.z)) * _e828) * 0.5f) * -(sign(_e832.z))));
                                                let _e838 = _o_Y_1;
                                                let _e839 = refractDirG;
                                                let _e841 = refractDirG;
                                                _o_Y_1 = (_e838 + ((_e839.y / abs(_e841.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e848 = _o_X_1;
                                                let _e849 = refractDirG;
                                                let _e851 = refractDirG;
                                                let _e855 = _o_ratio_3;
                                                let _e859 = refractDirG;
                                                _o_X_1 = (_e848 + ((((_e849.z / abs(_e851.x)) * _e855) * 0.5f) * -(sign(_e859.x))));
                                                let _e865 = _o_Y_1;
                                                let _e866 = refractDirG;
                                                let _e868 = refractDirG;
                                                _o_Y_1 = (_e865 + ((_e866.y / abs(_e868.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e875 = _o_X_1;
                                    let _e876 = _o_Y_1;
                                    let _e881 = global.U[0];
                                    let _e884 = _o_X_1;
                                    let _e885 = _o_Y_1;
                                    let _e896 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e875, _e876).x / _e881.x), vec2<f32>(_e884, _e885).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colG = _e896;
                                }
                            } else {
                                {
                                    let _e897 = refractDirG;
                                    let _e902 = ((_e897 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e902.x, _e902.y, _e902.z, 1f);
                                }
                            }
                        }
                    }
                    let _e908 = backgroundStyle_1;
                    if (_e908 == 0i) {
                        {
                            let _e911 = refractDirB;
                            _o_n_2 = normalize(_e911);
                            let _e914 = _o_n_2;
                            let _e916 = _o_n_2;
                            _o_alpha_2 = atan2(_e914.z, _e916.x);
                            let _e920 = _o_n_2;
                            _o_beta_2 = asin(_e920.y);
                            let _e924 = sourceDim_1;
                            let _e926 = sourceDim_1;
                            _o_ratio_4 = (_e924.x / _e926.y);
                            let _e934 = _o_alpha_2;
                            let _e940 = _o_nX_2;
                            let _e943 = _o_nY_2;
                            let _e944 = _o_beta_2;
                            let _e953 = global.U[0];
                            let _e956 = _o_alpha_2;
                            let _e962 = _o_nX_2;
                            let _e965 = _o_nY_2;
                            let _e966 = _o_beta_2;
                            let _e981 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e934) / 3.1415927f) * 0.5f) * _e940), (0.5f + ((_e943 * _e944) / 3.1415927f))).x / _e953.x), vec2<f32>((((-(_e956) / 3.1415927f) * 0.5f) * _e962), (0.5f + ((_e965 * _e966) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colB = _e981;
                        }
                    } else {
                        let _e982 = backgroundStyle_1;
                        if (_e982 == 1i) {
                            {
                                let _e985 = refractDirB;
                                let _e988 = refractDirB;
                                let _e991 = refractDirB;
                                let _e994 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e985.x) / _e988.z), (-(_e991.y) / _e994.z)) * 1f);
                                let _e1001 = _o_pos_2;
                                let _e1004 = _o_pos_2;
                                _o_m_2 = max(abs(_e1001.x), abs(_e1004.y));
                                let _e1011 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1011));
                                let _e1015 = _o_pos_2;
                                let _e1019 = global.U[0];
                                let _e1022 = _o_pos_2;
                                let _e1032 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1015.x / _e1019.x), _e1022.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1033 = _o_darken_2;
                                let _e1034 = _o_darken_2;
                                let _e1035 = _o_darken_2;
                                colB = (_e1032 * vec4<f32>(_e1033, _e1034, _e1035, 1f));
                            }
                        } else {
                            let _e1039 = backgroundStyle_1;
                            if (_e1039 == 2i) {
                                {
                                    let _e1042 = sourceDim_1;
                                    let _e1044 = sourceDim_1;
                                    _o_ratio_5 = (_e1042.y / _e1044.x);
                                    let _e1052 = refractDirB;
                                    let _e1055 = refractDirB;
                                    let _e1058 = _o_ratio_5;
                                    let _e1061 = refractDirB;
                                    let _e1064 = refractDirB;
                                    let _e1067 = _o_ratio_5;
                                    if ((abs(_e1052.y) > (abs(_e1055.z) * _e1058)) && (abs(_e1061.y) > (abs(_e1064.x) * _e1067))) {
                                        {
                                            let _e1071 = _o_X_2;
                                            let _e1072 = refractDirB;
                                            let _e1075 = refractDirB;
                                            _o_X_2 = (_e1071 + ((-(_e1072.x) / _e1075.y) * 0.5f));
                                            let _e1081 = _o_Y_2;
                                            let _e1082 = refractDirB;
                                            let _e1085 = refractDirB;
                                            _o_Y_2 = (_e1081 + ((-(_e1082.z) / _e1085.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1091 = refractDirB;
                                        let _e1094 = refractDirB;
                                        if (abs(_e1091.x) < abs(_e1094.z)) {
                                            {
                                                let _e1098 = _o_X_2;
                                                let _e1099 = refractDirB;
                                                let _e1101 = refractDirB;
                                                let _e1105 = _o_ratio_5;
                                                let _e1109 = refractDirB;
                                                _o_X_2 = (_e1098 + ((((_e1099.x / abs(_e1101.z)) * _e1105) * 0.5f) * -(sign(_e1109.z))));
                                                let _e1115 = _o_Y_2;
                                                let _e1116 = refractDirB;
                                                let _e1118 = refractDirB;
                                                _o_Y_2 = (_e1115 + ((_e1116.y / abs(_e1118.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1125 = _o_X_2;
                                                let _e1126 = refractDirB;
                                                let _e1128 = refractDirB;
                                                let _e1132 = _o_ratio_5;
                                                let _e1136 = refractDirB;
                                                _o_X_2 = (_e1125 + ((((_e1126.z / abs(_e1128.x)) * _e1132) * 0.5f) * -(sign(_e1136.x))));
                                                let _e1142 = _o_Y_2;
                                                let _e1143 = refractDirB;
                                                let _e1145 = refractDirB;
                                                _o_Y_2 = (_e1142 + ((_e1143.y / abs(_e1145.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1152 = _o_X_2;
                                    let _e1153 = _o_Y_2;
                                    let _e1158 = global.U[0];
                                    let _e1161 = _o_X_2;
                                    let _e1162 = _o_Y_2;
                                    let _e1173 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1152, _e1153).x / _e1158.x), vec2<f32>(_e1161, _e1162).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colB = _e1173;
                                }
                            } else {
                                {
                                    let _e1174 = refractDirB;
                                    let _e1179 = ((_e1174 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1179.x, _e1179.y, _e1179.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1185 = colR;
                    let _e1187 = colG;
                    let _e1189 = colB;
                    col = vec4<f32>(_e1185.x, _e1187.y, _e1189.z, 1f);
                    let _e1195 = absorption;
                    let _e1196 = qIn;
                    let _e1197 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1195 * length((_e1196 - _e1197)))));
                    let _e1205 = absorbed;
                    let _e1208 = colorMaterial_1;
                    absorbed = mix(0f, _e1205, smoothstep(0f, 0.1f, _e1208.w));
                    let _e1212 = color;
                    let _e1214 = color;
                    let _e1216 = colorMaterial_1;
                    let _e1219 = fresnel;
                    let _e1223 = absorbed;
                    let _e1226 = col;
                    let _e1229 = (_e1214.xyz + (((_e1216.xyz * (1f - _e1219)) * (1f - _e1223)) * _e1226.xyz));
                    color.x = _e1229.x;
                    color.y = _e1229.y;
                    color.z = _e1229.z;
                    let _e1236 = color;
                    let _e1238 = color;
                    let _e1240 = absorbed;
                    let _e1241 = colorMaterial_1;
                    let _e1244 = ambientColor_1;
                    let _e1247 = nIn;
                    let _e1248 = lightDir;
                    let _e1251 = sourceColor_1;
                    let _e1256 = (_e1238.xyz + ((_e1240 * _e1241.xyz) * (_e1244.xyz + (max(0f, dot(_e1247, _e1248)) * _e1251.xyz))));
                    color.x = _e1256.x;
                    color.y = _e1256.y;
                    color.z = _e1256.z;
                }
            }
            let _e1263 = fresnel;
            let _e1266 = specular_1;
            if ((_e1263 != 0f) || (_e1266 != 0f)) {
                {
                    let _e1270 = reflectDir;
                    origReflectDir = _e1270;
                    let _e1272 = qIn;
                    let _e1273 = nIn;
                    let _e1277 = reflectDir;
                    let _e1279 = radius_7;
                    let _e1280 = roundness_7;
                    let _e1281 = rayMarch((_e1272 + (_e1273 * 0.001f)), _e1277, 1f, _e1279, _e1280);
                    qR = _e1281;
                    let _e1283 = qR;
                    if (_e1283.x != 100000000000000000000f) {
                        {
                            let _e1287 = qR;
                            let _e1288 = radius_7;
                            let _e1289 = roundness_7;
                            let _e1290 = normal(_e1287, _e1288, _e1289);
                            n_1 = _e1290;
                            let _e1292 = reflectDir;
                            let _e1293 = n_1;
                            reflectDir = reflect(_e1292, _e1293);
                        }
                    }
                    let _e1295 = model3DTransform3_;
                    let _e1296 = reflectDir;
                    reflectDir = (_e1295 * _e1296);
                    let _e1298 = backgroundStyle_1;
                    if (_e1298 == 0i) {
                        {
                            let _e1301 = reflectDir;
                            _o_n_3 = normalize(_e1301);
                            let _e1304 = _o_n_3;
                            let _e1306 = _o_n_3;
                            _o_alpha_3 = atan2(_e1304.z, _e1306.x);
                            let _e1310 = _o_n_3;
                            _o_beta_3 = asin(_e1310.y);
                            let _e1314 = sourceDim_1;
                            let _e1316 = sourceDim_1;
                            _o_ratio_6 = (_e1314.x / _e1316.y);
                            let _e1324 = _o_alpha_3;
                            let _e1330 = _o_nX_3;
                            let _e1333 = _o_nY_3;
                            let _e1334 = _o_beta_3;
                            let _e1343 = global.U[0];
                            let _e1346 = _o_alpha_3;
                            let _e1352 = _o_nX_3;
                            let _e1355 = _o_nY_3;
                            let _e1356 = _o_beta_3;
                            let _e1371 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1324) / 3.1415927f) * 0.5f) * _e1330), (0.5f + ((_e1333 * _e1334) / 3.1415927f))).x / _e1343.x), vec2<f32>((((-(_e1346) / 3.1415927f) * 0.5f) * _e1352), (0.5f + ((_e1355 * _e1356) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1371;
                        }
                    } else {
                        let _e1372 = backgroundStyle_1;
                        if (_e1372 == 1i) {
                            {
                                let _e1375 = reflectDir;
                                let _e1378 = reflectDir;
                                let _e1381 = reflectDir;
                                let _e1384 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1375.x) / _e1378.z), (-(_e1381.y) / _e1384.z)) * 1f);
                                let _e1391 = _o_pos_3;
                                let _e1394 = _o_pos_3;
                                _o_m_3 = max(abs(_e1391.x), abs(_e1394.y));
                                let _e1401 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1401));
                                let _e1405 = _o_pos_3;
                                let _e1409 = global.U[0];
                                let _e1412 = _o_pos_3;
                                let _e1422 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1405.x / _e1409.x), _e1412.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1423 = _o_darken_3;
                                let _e1424 = _o_darken_3;
                                let _e1425 = _o_darken_3;
                                col = (_e1422 * vec4<f32>(_e1423, _e1424, _e1425, 1f));
                            }
                        } else {
                            let _e1429 = backgroundStyle_1;
                            if (_e1429 == 2i) {
                                {
                                    let _e1432 = sourceDim_1;
                                    let _e1434 = sourceDim_1;
                                    _o_ratio_7 = (_e1432.y / _e1434.x);
                                    let _e1442 = reflectDir;
                                    let _e1445 = reflectDir;
                                    let _e1448 = _o_ratio_7;
                                    let _e1451 = reflectDir;
                                    let _e1454 = reflectDir;
                                    let _e1457 = _o_ratio_7;
                                    if ((abs(_e1442.y) > (abs(_e1445.z) * _e1448)) && (abs(_e1451.y) > (abs(_e1454.x) * _e1457))) {
                                        {
                                            let _e1461 = _o_X_3;
                                            let _e1462 = reflectDir;
                                            let _e1465 = reflectDir;
                                            _o_X_3 = (_e1461 + ((-(_e1462.x) / _e1465.y) * 0.5f));
                                            let _e1471 = _o_Y_3;
                                            let _e1472 = reflectDir;
                                            let _e1475 = reflectDir;
                                            _o_Y_3 = (_e1471 + ((-(_e1472.z) / _e1475.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1481 = reflectDir;
                                        let _e1484 = reflectDir;
                                        if (abs(_e1481.x) < abs(_e1484.z)) {
                                            {
                                                let _e1488 = _o_X_3;
                                                let _e1489 = reflectDir;
                                                let _e1491 = reflectDir;
                                                let _e1495 = _o_ratio_7;
                                                let _e1499 = reflectDir;
                                                _o_X_3 = (_e1488 + ((((_e1489.x / abs(_e1491.z)) * _e1495) * 0.5f) * -(sign(_e1499.z))));
                                                let _e1505 = _o_Y_3;
                                                let _e1506 = reflectDir;
                                                let _e1508 = reflectDir;
                                                _o_Y_3 = (_e1505 + ((_e1506.y / abs(_e1508.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1515 = _o_X_3;
                                                let _e1516 = reflectDir;
                                                let _e1518 = reflectDir;
                                                let _e1522 = _o_ratio_7;
                                                let _e1526 = reflectDir;
                                                _o_X_3 = (_e1515 + ((((_e1516.z / abs(_e1518.x)) * _e1522) * 0.5f) * -(sign(_e1526.x))));
                                                let _e1532 = _o_Y_3;
                                                let _e1533 = reflectDir;
                                                let _e1535 = reflectDir;
                                                _o_Y_3 = (_e1532 + ((_e1533.y / abs(_e1535.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1542 = _o_X_3;
                                    let _e1543 = _o_Y_3;
                                    let _e1548 = global.U[0];
                                    let _e1551 = _o_X_3;
                                    let _e1552 = _o_Y_3;
                                    let _e1563 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1542, _e1543).x / _e1548.x), vec2<f32>(_e1551, _e1552).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e1563;
                                }
                            } else {
                                {
                                    let _e1564 = reflectDir;
                                    let _e1569 = ((_e1564 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1569.x, _e1569.y, _e1569.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1575 = color;
                    let _e1577 = color;
                    let _e1579 = fresnel;
                    let _e1580 = col;
                    let _e1583 = (_e1577.xyz + (_e1579 * _e1580.xyz));
                    color.x = _e1583.x;
                    color.y = _e1583.y;
                    color.z = _e1583.z;
                    let _e1591 = specular_1;
                    let _e1594 = lightDir;
                    let _e1595 = origReflectDir;
                    kSpec = ((10f * _e1591) * pow(max(0f, dot(_e1594, _e1595)), 9f));
                    let _e1602 = color;
                    let _e1604 = color;
                    let _e1606 = sourceColor_1;
                    let _e1608 = kSpec;
                    let _e1610 = (_e1604.xyz + (_e1606.xyz * _e1608));
                    color.x = _e1610.x;
                    color.y = _e1610.y;
                    color.z = _e1610.z;
                }
            }
            let _e1617 = colorFog_1;
            if (_e1617.w != 0f) {
                {
                    let _e1621 = camera_2;
                    let _e1622 = qIn;
                    dist = length((_e1621 - _e1622));
                    let _e1628 = colorFog_1;
                    let _e1631 = dist;
                    kFog = (1f - pow(0.4f, (_e1628.w * max(0f, (_e1631 - 0.1f)))));
                    let _e1639 = color;
                    let _e1641 = color;
                    let _e1643 = colorFog_1;
                    let _e1645 = kFog;
                    let _e1647 = mix(_e1641.xyz, _e1643.xyz, vec3(_e1645));
                    color.x = _e1647.x;
                    color.y = _e1647.y;
                    color.z = _e1647.z;
                }
            }
        }
    } else {
        {
            let _e1654 = bkgTransform_1;
            let _e1664 = model3DTransform3_;
            let _e1666 = camDir;
            camDir = ((mat3x3<f32>(_e1654[0].xyz, _e1654[1].xyz, _e1654[2].xyz) * _e1664) * _e1666);
            let _e1668 = backgroundStyle_1;
            if (_e1668 == 0i) {
                {
                    let _e1671 = camDir;
                    _o_n_4 = normalize(_e1671);
                    let _e1674 = _o_n_4;
                    let _e1676 = _o_n_4;
                    _o_alpha_4 = atan2(_e1674.z, _e1676.x);
                    let _e1680 = _o_n_4;
                    _o_beta_4 = asin(_e1680.y);
                    let _e1684 = sourceDim_1;
                    let _e1686 = sourceDim_1;
                    _o_ratio_8 = (_e1684.x / _e1686.y);
                    let _e1694 = _o_alpha_4;
                    let _e1700 = _o_nX_4;
                    let _e1703 = _o_nY_4;
                    let _e1704 = _o_beta_4;
                    let _e1713 = global.U[0];
                    let _e1716 = _o_alpha_4;
                    let _e1722 = _o_nX_4;
                    let _e1725 = _o_nY_4;
                    let _e1726 = _o_beta_4;
                    let _e1741 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1694) / 3.1415927f) * 0.5f) * _e1700), (0.5f + ((_e1703 * _e1704) / 3.1415927f))).x / _e1713.x), vec2<f32>((((-(_e1716) / 3.1415927f) * 0.5f) * _e1722), (0.5f + ((_e1725 * _e1726) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col = _e1741;
                }
            } else {
                let _e1742 = backgroundStyle_1;
                if (_e1742 == 1i) {
                    {
                        let _e1745 = camDir;
                        let _e1748 = camDir;
                        let _e1751 = camDir;
                        let _e1754 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1745.x) / _e1748.z), (-(_e1751.y) / _e1754.z)) * 1f);
                        let _e1761 = _o_pos_4;
                        let _e1764 = _o_pos_4;
                        _o_m_4 = max(abs(_e1761.x), abs(_e1764.y));
                        let _e1771 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1771));
                        let _e1775 = _o_pos_4;
                        let _e1779 = global.U[0];
                        let _e1782 = _o_pos_4;
                        let _e1792 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1775.x / _e1779.x), _e1782.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1793 = _o_darken_4;
                        let _e1794 = _o_darken_4;
                        let _e1795 = _o_darken_4;
                        col = (_e1792 * vec4<f32>(_e1793, _e1794, _e1795, 1f));
                    }
                } else {
                    let _e1799 = backgroundStyle_1;
                    if (_e1799 == 2i) {
                        {
                            let _e1802 = sourceDim_1;
                            let _e1804 = sourceDim_1;
                            _o_ratio_9 = (_e1802.y / _e1804.x);
                            let _e1812 = camDir;
                            let _e1815 = camDir;
                            let _e1818 = _o_ratio_9;
                            let _e1821 = camDir;
                            let _e1824 = camDir;
                            let _e1827 = _o_ratio_9;
                            if ((abs(_e1812.y) > (abs(_e1815.z) * _e1818)) && (abs(_e1821.y) > (abs(_e1824.x) * _e1827))) {
                                {
                                    let _e1831 = _o_X_4;
                                    let _e1832 = camDir;
                                    let _e1835 = camDir;
                                    _o_X_4 = (_e1831 + ((-(_e1832.x) / _e1835.y) * 0.5f));
                                    let _e1841 = _o_Y_4;
                                    let _e1842 = camDir;
                                    let _e1845 = camDir;
                                    _o_Y_4 = (_e1841 + ((-(_e1842.z) / _e1845.y) * 0.5f));
                                }
                            } else {
                                let _e1851 = camDir;
                                let _e1854 = camDir;
                                if (abs(_e1851.x) < abs(_e1854.z)) {
                                    {
                                        let _e1858 = _o_X_4;
                                        let _e1859 = camDir;
                                        let _e1861 = camDir;
                                        let _e1865 = _o_ratio_9;
                                        let _e1869 = camDir;
                                        _o_X_4 = (_e1858 + ((((_e1859.x / abs(_e1861.z)) * _e1865) * 0.5f) * -(sign(_e1869.z))));
                                        let _e1875 = _o_Y_4;
                                        let _e1876 = camDir;
                                        let _e1878 = camDir;
                                        _o_Y_4 = (_e1875 + ((_e1876.y / abs(_e1878.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1885 = _o_X_4;
                                        let _e1886 = camDir;
                                        let _e1888 = camDir;
                                        let _e1892 = _o_ratio_9;
                                        let _e1896 = camDir;
                                        _o_X_4 = (_e1885 + ((((_e1886.z / abs(_e1888.x)) * _e1892) * 0.5f) * -(sign(_e1896.x))));
                                        let _e1902 = _o_Y_4;
                                        let _e1903 = camDir;
                                        let _e1905 = camDir;
                                        _o_Y_4 = (_e1902 + ((_e1903.y / abs(_e1905.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1912 = _o_X_4;
                            let _e1913 = _o_Y_4;
                            let _e1918 = global.U[0];
                            let _e1921 = _o_X_4;
                            let _e1922 = _o_Y_4;
                            let _e1933 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1912, _e1913).x / _e1918.x), vec2<f32>(_e1921, _e1922).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1933;
                        }
                    } else {
                        {
                            let _e1934 = camDir;
                            let _e1939 = ((_e1934 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1939.x, _e1939.y, _e1939.z, 1f);
                        }
                    }
                }
            }
            let _e1945 = colorFog_1;
            if (_e1945.w != 0f) {
                let _e1949 = color;
                let _e1951 = colorFog_1;
                let _e1952 = _e1951.xyz;
                color.x = _e1952.x;
                color.y = _e1952.y;
                color.z = _e1952.z;
            } else {
                let _e1959 = col;
                color = _e1959;
            }
        }
    }
    let _e1960 = color;
    return clamp(_e1960, vec4(0f), vec4(1f));
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
