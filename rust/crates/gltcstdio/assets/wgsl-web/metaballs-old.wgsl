struct Params {
    U: array<vec4<f32>, 36>,
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

fn hash13_(x: f32) -> vec3<f32> {
    var x_1: f32;

    x_1 = x;
    let _e9 = x_1;
    let _e15 = x_1;
    let _e21 = x_1;
    return fract(vec3<f32>((sin((_e9 * 776.4577f)) * 45.771f), (cos((_e15 * 442.8831f)) * 65.111f), (sin(((_e21 * 376.4517f) + 1.2524f)) * 88.771f)));
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e12 = noise_1;
    phase = acos(((2f * _e12) - 1f));
    let _e18 = noise_1;
    freq = (fract((_e18 * 16f)) + 0.5f);
    let _e26 = phase;
    let _e27 = freq;
    let _e28 = k_1;
    return ((1f + cos((_e26 + (_e27 * _e28)))) * 0.5f);
}

fn varyVec3NoiseSmoothly(noise_2: vec3<f32>, k_2: f32) -> vec3<f32> {
    var noise_3: vec3<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e11 = noise_3;
    let _e13 = k_3;
    let _e14 = varyNoiseSmoothly(_e11.x, _e13);
    let _e15 = noise_3;
    let _e17 = k_3;
    let _e18 = varyNoiseSmoothly(_e15.y, _e17);
    let _e19 = noise_3;
    let _e21 = k_3;
    let _e22 = varyNoiseSmoothly(_e19.z, _e21);
    return vec3<f32>(_e14, _e18, _e22);
}

fn rand13relSeeded(co: f32, seed: f32) -> vec3<f32> {
    var co_1: f32;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e11 = co_1;
    let _e12 = hash13_(_e11);
    let _e13 = seed_1;
    let _e14 = varyVec3NoiseSmoothly(_e12, _e13);
    return (_e14 - vec3(0.5f));
}

fn sdf(p: vec3<f32>, count: i32, radius: f32, randomSeed: f32, separation: f32) -> f32 {
    var p_1: vec3<f32>;
    var count_1: i32;
    var radius_1: f32;
    var randomSeed_1: f32;
    var separation_1: f32;
    var r: f32;
    var d: f32;
    var i: i32 = 1i;
    var center: vec3<f32>;

    p_1 = p;
    count_1 = count;
    radius_1 = radius;
    randomSeed_1 = randomSeed;
    separation_1 = separation;
    let _e17 = radius_1;
    r = _e17;
    let _e20 = p_1;
    let _e24 = r;
    d = ((1f / length(_e20)) - (1f / _e24));
    loop {
        let _e30 = i;
        let _e31 = count_1;
        if !((_e30 < _e31)) {
            break;
        }
        {
            let _e37 = separation_1;
            let _e38 = i;
            let _e40 = randomSeed_1;
            let _e41 = rand13relSeeded(f32(_e38), _e40);
            center = (_e37 * _e41);
            let _e44 = d;
            let _e46 = center;
            let _e47 = p_1;
            let _e52 = r;
            d = (_e44 + ((1f / length((_e46 - _e47))) - (1f / _e52)));
        }
        continuing {
            let _e34 = i;
            i = (_e34 + 1i);
        }
    }
    let _e56 = d;
    return _e56;
}

fn normal(p_2: vec3<f32>, count_2: i32, radius_2: f32, randomSeed_2: f32, separation_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var count_3: i32;
    var radius_3: f32;
    var randomSeed_3: f32;
    var separation_3: f32;
    var d_1: f32 = 0.0001f;
    var s: f32;

    p_3 = p_2;
    count_3 = count_2;
    radius_3 = radius_2;
    randomSeed_3 = randomSeed_2;
    separation_3 = separation_2;
    let _e19 = p_3;
    let _e20 = count_3;
    let _e21 = radius_3;
    let _e22 = randomSeed_3;
    let _e23 = separation_3;
    let _e24 = sdf(_e19, _e20, _e21, _e22, _e23);
    s = _e24;
    let _e26 = s;
    let _e27 = p_3;
    let _e29 = d_1;
    let _e31 = p_3;
    let _e33 = p_3;
    let _e36 = count_3;
    let _e37 = radius_3;
    let _e38 = randomSeed_3;
    let _e39 = separation_3;
    let _e40 = sdf(vec3<f32>((_e27.x - _e29), _e31.y, _e33.z), _e36, _e37, _e38, _e39);
    let _e42 = d_1;
    let _e44 = s;
    let _e45 = p_3;
    let _e47 = p_3;
    let _e49 = d_1;
    let _e51 = p_3;
    let _e54 = count_3;
    let _e55 = radius_3;
    let _e56 = randomSeed_3;
    let _e57 = separation_3;
    let _e58 = sdf(vec3<f32>(_e45.x, (_e47.y - _e49), _e51.z), _e54, _e55, _e56, _e57);
    let _e60 = d_1;
    let _e62 = s;
    let _e63 = p_3;
    let _e65 = p_3;
    let _e67 = p_3;
    let _e69 = d_1;
    let _e72 = count_3;
    let _e73 = radius_3;
    let _e74 = randomSeed_3;
    let _e75 = separation_3;
    let _e76 = sdf(vec3<f32>(_e63.x, _e65.y, (_e67.z - _e69)), _e72, _e73, _e74, _e75);
    let _e78 = d_1;
    return normalize(vec3<f32>(((_e26 - _e40) / _e42), ((_e44 - _e58) / _e60), ((_e62 - _e76) / _e78)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32, count_4: i32, radius_4: f32, randomSeed_4: f32, separation_4: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var count_5: i32;
    var radius_5: f32;
    var randomSeed_5: f32;
    var separation_5: f32;
    var d_2: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_4: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    count_5 = count_4;
    radius_5 = radius_4;
    randomSeed_5 = randomSeed_4;
    separation_5 = separation_4;
    let _e21 = p0_1;
    let _e22 = count_5;
    let _e23 = radius_5;
    let _e24 = randomSeed_5;
    let _e25 = separation_5;
    let _e26 = sdf(_e21, _e22, _e23, _e24, _e25);
    d_2 = _e26;
    let _e28 = d_2;
    s_1 = sign(_e28);
    loop {
        let _e35 = step;
        let _e38 = d_2;
        if !(((_e35 < 1000i) && (_e38 < 100f))) {
            break;
        }
        {
            let _e43 = totalD;
            let _e44 = d_2;
            let _e45 = side_1;
            totalD = (_e43 + (_e44 * _e45));
            let _e48 = p0_1;
            let _e49 = totalD;
            let _e50 = dir_1;
            p_4 = (_e48 + (_e49 * _e50));
            let _e54 = p_4;
            let _e55 = count_5;
            let _e56 = radius_5;
            let _e57 = randomSeed_5;
            let _e58 = separation_5;
            let _e59 = sdf(_e54, _e55, _e56, _e57, _e58);
            d_2 = _e59;
            let _e60 = d_2;
            if (abs(_e60) < 0.0001f) {
                let _e64 = p_4;
                return _e64;
            }
            let _e65 = step;
            step = (_e65 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32, count_6: i32, radius_6: f32, randomSeed_6: f32, separation_6: f32) -> vec4<f32> {
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
    var count_7: i32;
    var radius_7: f32;
    var randomSeed_7: f32;
    var separation_7: f32;
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
    var k_4: f32;
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
    count_7 = count_6;
    radius_7 = radius_6;
    randomSeed_7 = randomSeed_6;
    separation_7 = separation_6;
    let _e54 = camera3DTransform_1;
    let _e55 = camera_2;
    camera_2 = (_e54 * vec4<f32>(_e55.x, _e55.y, _e55.z, 1f)).xyz;
    let _e66 = uv_3;
    let _e67 = camera_2;
    let _e68 = target_2;
    let _e70 = getRay(_e66, _e67, _e68, 1f);
    camDir = _e70;
    let _e72 = lightSourceTransform_1;
    lightPos = (_e72 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e81 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e81);
    let _e84 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e84[0].xyz, _e84[1].xyz, _e84[2].xyz);
    let _e95 = invModelTransform;
    let _e96 = camera_2;
    camera_2 = (_e95 * vec4<f32>(_e96.x, _e96.y, _e96.z, 1f)).xyz;
    let _e104 = uv_3;
    let _e106 = D;
    let _e108 = uv_3;
    let _e110 = D;
    dir_2 = normalize(vec3<f32>((_e104.x * _e106), (_e108.y * _e110), -1f));
    let _e117 = camera3DTransform_1;
    let _e127 = dir_2;
    dir_2 = (mat3x3<f32>(_e117[0].xyz, _e117[1].xyz, _e117[2].xyz) * _e127);
    let _e129 = invModelTransform;
    let _e139 = dir_2;
    camDir = normalize((mat3x3<f32>(_e129[0].xyz, _e129[1].xyz, _e129[2].xyz) * _e139));
    let _e154 = camera_2;
    let _e155 = camDir;
    let _e157 = count_7;
    let _e158 = radius_7;
    let _e159 = randomSeed_7;
    let _e160 = separation_7;
    let _e161 = rayMarch(_e154, _e155, 1f, _e157, _e158, _e159, _e160);
    qIn = _e161;
    let _e163 = camDir;
    reflectDir = _e163;
    let _e168 = refractionIndex_1;
    ref_ = _e168;
    let _e170 = chromaticAberration_1;
    chromaticAbb = _e170;
    let _e176 = colorMaterial_1;
    let _e180 = colorMaterial_1;
    absorption = pow(mix(30f, 1000f, smoothstep(0.95f, 1f, _e176.w)), _e180.w);
    let _e184 = qIn;
    if (_e184.x != 100000000000000000000f) {
        {
            let _e188 = qIn;
            let _e189 = count_7;
            let _e190 = radius_7;
            let _e191 = randomSeed_7;
            let _e192 = separation_7;
            let _e193 = normal(_e188, _e189, _e190, _e191, _e192);
            nIn = _e193;
            let _e195 = nIn;
            let _e196 = camDir;
            incidence = abs(dot(_e195, _e196));
            let _e201 = incidence;
            let _e204 = fresnelStrength_1;
            let _e211 = fresnelStrength_1;
            let _e216 = fresnelStrength_1;
            fresnel = ((pow((1f - _e201), (6f - (_e204 * 6f))) * smoothstep(0f, 0.025f, _e211)) * smoothstep(0f, 0.025f, _e216));
            let _e220 = camDir;
            let _e221 = nIn;
            reflectDir = reflect(_e220, _e221);
            let _e225 = colorMaterial_1;
            reflectivity = (vec3(1f) - _e225.xyz);
            let _e229 = reflectivity;
            reflectK = _e229;
            let _e230 = qIn;
            let _e231 = lightPos;
            lightDir = normalize((_e230 - _e231));
            let _e235 = fresnel;
            if (_e235 != 1f) {
                {
                    let _e240 = ref_;
                    let _e241 = ref_;
                    let _e244 = nIn;
                    let _e245 = camDir;
                    let _e247 = nIn;
                    let _e248 = camDir;
                    k_4 = (1f - ((_e240 * _e241) * (1f - (dot(_e244, _e245) * dot(_e247, _e248)))));
                    let _e255 = k_4;
                    if (_e255 < 0f) {
                        refractDir = vec3(0f);
                    } else {
                        let _e260 = ref_;
                        let _e261 = camDir;
                        let _e263 = ref_;
                        let _e264 = nIn;
                        let _e265 = camDir;
                        let _e268 = k_4;
                        let _e271 = nIn;
                        refractDir = ((_e260 * _e261) - (((_e263 * dot(_e264, _e265)) + sqrt(_e268)) * _e271));
                    }
                    let _e274 = qIn;
                    let _e275 = nIn;
                    let _e279 = refractDir;
                    let _e282 = count_7;
                    let _e283 = radius_7;
                    let _e284 = randomSeed_7;
                    let _e285 = separation_7;
                    let _e286 = rayMarch((_e274 - (_e275 * 0.001f)), _e279, -1f, _e282, _e283, _e284, _e285);
                    qOut = _e286;
                    let _e288 = qOut;
                    let _e289 = count_7;
                    let _e290 = radius_7;
                    let _e291 = randomSeed_7;
                    let _e292 = separation_7;
                    let _e293 = normal(_e288, _e289, _e290, _e291, _e292);
                    n = -(_e293);
                    let _e296 = refractDir;
                    let _e297 = n;
                    let _e299 = ref_;
                    let _e301 = chromaticAbb;
                    rDir = refract(_e296, _e297, ((1f / _e299) - _e301));
                    let _e305 = rDir;
                    if (length(_e305) == 0f) {
                        let _e309 = refractDir;
                        let _e310 = n;
                        local = reflect(_e309, _e310);
                    } else {
                        let _e312 = rDir;
                        local = _e312;
                    }
                    let _e314 = local;
                    refractDirR = _e314;
                    let _e316 = refractDir;
                    let _e317 = n;
                    let _e319 = ref_;
                    gDir = refract(_e316, _e317, (1f / _e319));
                    let _e323 = gDir;
                    if (length(_e323) == 0f) {
                        let _e327 = refractDir;
                        let _e328 = n;
                        local_1 = reflect(_e327, _e328);
                    } else {
                        let _e330 = gDir;
                        local_1 = _e330;
                    }
                    let _e332 = local_1;
                    refractDirG = _e332;
                    let _e334 = refractDir;
                    let _e335 = n;
                    let _e337 = ref_;
                    let _e339 = chromaticAbb;
                    bDir = refract(_e334, _e335, ((1f / _e337) + _e339));
                    let _e343 = bDir;
                    if (length(_e343) == 0f) {
                        let _e347 = refractDir;
                        let _e348 = n;
                        local_2 = reflect(_e347, _e348);
                    } else {
                        let _e350 = bDir;
                        local_2 = _e350;
                    }
                    let _e352 = local_2;
                    refractDirB = _e352;
                    let _e357 = model3DTransform3_;
                    let _e358 = refractDirR;
                    refractDirR = (_e357 * _e358);
                    let _e360 = model3DTransform3_;
                    let _e361 = refractDirG;
                    refractDirG = (_e360 * _e361);
                    let _e363 = model3DTransform3_;
                    let _e364 = refractDirB;
                    refractDirB = (_e363 * _e364);
                    let _e366 = backgroundStyle_1;
                    if (_e366 == 0i) {
                        {
                            let _e369 = refractDirR;
                            _o_n = normalize(_e369);
                            let _e372 = _o_n;
                            let _e374 = _o_n;
                            _o_alpha = atan2(_e372.z, _e374.x);
                            let _e378 = _o_n;
                            _o_beta = asin(_e378.y);
                            let _e382 = sourceDim_1;
                            let _e384 = sourceDim_1;
                            _o_ratio = (_e382.x / _e384.y);
                            let _e392 = _o_alpha;
                            let _e398 = _o_nX;
                            let _e401 = _o_nY;
                            let _e402 = _o_beta;
                            let _e411 = global.U[0];
                            let _e414 = _o_alpha;
                            let _e420 = _o_nX;
                            let _e423 = _o_nY;
                            let _e424 = _o_beta;
                            let _e439 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e392) / 3.1415927f) * 0.5f) * _e398), (0.5f + ((_e401 * _e402) / 3.1415927f))).x / _e411.x), vec2<f32>((((-(_e414) / 3.1415927f) * 0.5f) * _e420), (0.5f + ((_e423 * _e424) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colR = _e439;
                        }
                    } else {
                        let _e440 = backgroundStyle_1;
                        if (_e440 == 1i) {
                            {
                                let _e443 = refractDirR;
                                let _e446 = refractDirR;
                                let _e449 = refractDirR;
                                let _e452 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e443.x) / _e446.z), (-(_e449.y) / _e452.z)) * 1f);
                                let _e459 = _o_pos;
                                let _e462 = _o_pos;
                                _o_m = max(abs(_e459.x), abs(_e462.y));
                                let _e469 = _o_m;
                                _o_darken = (4f / max(4f, _e469));
                                let _e473 = _o_pos;
                                let _e477 = global.U[0];
                                let _e480 = _o_pos;
                                let _e490 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e473.x / _e477.x), _e480.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e491 = _o_darken;
                                let _e492 = _o_darken;
                                let _e493 = _o_darken;
                                colR = (_e490 * vec4<f32>(_e491, _e492, _e493, 1f));
                            }
                        } else {
                            let _e497 = backgroundStyle_1;
                            if (_e497 == 2i) {
                                {
                                    let _e500 = sourceDim_1;
                                    let _e502 = sourceDim_1;
                                    _o_ratio_1 = (_e500.y / _e502.x);
                                    let _e510 = refractDirR;
                                    let _e513 = refractDirR;
                                    let _e516 = _o_ratio_1;
                                    let _e519 = refractDirR;
                                    let _e522 = refractDirR;
                                    let _e525 = _o_ratio_1;
                                    if ((abs(_e510.y) > (abs(_e513.z) * _e516)) && (abs(_e519.y) > (abs(_e522.x) * _e525))) {
                                        {
                                            let _e529 = _o_X;
                                            let _e530 = refractDirR;
                                            let _e533 = refractDirR;
                                            _o_X = (_e529 + ((-(_e530.x) / _e533.y) * 0.5f));
                                            let _e539 = _o_Y;
                                            let _e540 = refractDirR;
                                            let _e543 = refractDirR;
                                            _o_Y = (_e539 + ((-(_e540.z) / _e543.y) * 0.5f));
                                        }
                                    } else {
                                        let _e549 = refractDirR;
                                        let _e552 = refractDirR;
                                        if (abs(_e549.x) < abs(_e552.z)) {
                                            {
                                                let _e556 = _o_X;
                                                let _e557 = refractDirR;
                                                let _e559 = refractDirR;
                                                let _e563 = _o_ratio_1;
                                                let _e567 = refractDirR;
                                                _o_X = (_e556 + ((((_e557.x / abs(_e559.z)) * _e563) * 0.5f) * -(sign(_e567.z))));
                                                let _e573 = _o_Y;
                                                let _e574 = refractDirR;
                                                let _e576 = refractDirR;
                                                _o_Y = (_e573 + ((_e574.y / abs(_e576.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e583 = _o_X;
                                                let _e584 = refractDirR;
                                                let _e586 = refractDirR;
                                                let _e590 = _o_ratio_1;
                                                let _e594 = refractDirR;
                                                _o_X = (_e583 + ((((_e584.z / abs(_e586.x)) * _e590) * 0.5f) * -(sign(_e594.x))));
                                                let _e600 = _o_Y;
                                                let _e601 = refractDirR;
                                                let _e603 = refractDirR;
                                                _o_Y = (_e600 + ((_e601.y / abs(_e603.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e610 = _o_X;
                                    let _e611 = _o_Y;
                                    let _e616 = global.U[0];
                                    let _e619 = _o_X;
                                    let _e620 = _o_Y;
                                    let _e631 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e610, _e611).x / _e616.x), vec2<f32>(_e619, _e620).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colR = _e631;
                                }
                            } else {
                                {
                                    let _e632 = refractDirR;
                                    let _e637 = ((_e632 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e637.x, _e637.y, _e637.z, 1f);
                                }
                            }
                        }
                    }
                    let _e643 = backgroundStyle_1;
                    if (_e643 == 0i) {
                        {
                            let _e646 = refractDirG;
                            _o_n_1 = normalize(_e646);
                            let _e649 = _o_n_1;
                            let _e651 = _o_n_1;
                            _o_alpha_1 = atan2(_e649.z, _e651.x);
                            let _e655 = _o_n_1;
                            _o_beta_1 = asin(_e655.y);
                            let _e659 = sourceDim_1;
                            let _e661 = sourceDim_1;
                            _o_ratio_2 = (_e659.x / _e661.y);
                            let _e669 = _o_alpha_1;
                            let _e675 = _o_nX_1;
                            let _e678 = _o_nY_1;
                            let _e679 = _o_beta_1;
                            let _e688 = global.U[0];
                            let _e691 = _o_alpha_1;
                            let _e697 = _o_nX_1;
                            let _e700 = _o_nY_1;
                            let _e701 = _o_beta_1;
                            let _e716 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e669) / 3.1415927f) * 0.5f) * _e675), (0.5f + ((_e678 * _e679) / 3.1415927f))).x / _e688.x), vec2<f32>((((-(_e691) / 3.1415927f) * 0.5f) * _e697), (0.5f + ((_e700 * _e701) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colG = _e716;
                        }
                    } else {
                        let _e717 = backgroundStyle_1;
                        if (_e717 == 1i) {
                            {
                                let _e720 = refractDirG;
                                let _e723 = refractDirG;
                                let _e726 = refractDirG;
                                let _e729 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e720.x) / _e723.z), (-(_e726.y) / _e729.z)) * 1f);
                                let _e736 = _o_pos_1;
                                let _e739 = _o_pos_1;
                                _o_m_1 = max(abs(_e736.x), abs(_e739.y));
                                let _e746 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e746));
                                let _e750 = _o_pos_1;
                                let _e754 = global.U[0];
                                let _e757 = _o_pos_1;
                                let _e767 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e750.x / _e754.x), _e757.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e768 = _o_darken_1;
                                let _e769 = _o_darken_1;
                                let _e770 = _o_darken_1;
                                colG = (_e767 * vec4<f32>(_e768, _e769, _e770, 1f));
                            }
                        } else {
                            let _e774 = backgroundStyle_1;
                            if (_e774 == 2i) {
                                {
                                    let _e777 = sourceDim_1;
                                    let _e779 = sourceDim_1;
                                    _o_ratio_3 = (_e777.y / _e779.x);
                                    let _e787 = refractDirG;
                                    let _e790 = refractDirG;
                                    let _e793 = _o_ratio_3;
                                    let _e796 = refractDirG;
                                    let _e799 = refractDirG;
                                    let _e802 = _o_ratio_3;
                                    if ((abs(_e787.y) > (abs(_e790.z) * _e793)) && (abs(_e796.y) > (abs(_e799.x) * _e802))) {
                                        {
                                            let _e806 = _o_X_1;
                                            let _e807 = refractDirG;
                                            let _e810 = refractDirG;
                                            _o_X_1 = (_e806 + ((-(_e807.x) / _e810.y) * 0.5f));
                                            let _e816 = _o_Y_1;
                                            let _e817 = refractDirG;
                                            let _e820 = refractDirG;
                                            _o_Y_1 = (_e816 + ((-(_e817.z) / _e820.y) * 0.5f));
                                        }
                                    } else {
                                        let _e826 = refractDirG;
                                        let _e829 = refractDirG;
                                        if (abs(_e826.x) < abs(_e829.z)) {
                                            {
                                                let _e833 = _o_X_1;
                                                let _e834 = refractDirG;
                                                let _e836 = refractDirG;
                                                let _e840 = _o_ratio_3;
                                                let _e844 = refractDirG;
                                                _o_X_1 = (_e833 + ((((_e834.x / abs(_e836.z)) * _e840) * 0.5f) * -(sign(_e844.z))));
                                                let _e850 = _o_Y_1;
                                                let _e851 = refractDirG;
                                                let _e853 = refractDirG;
                                                _o_Y_1 = (_e850 + ((_e851.y / abs(_e853.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e860 = _o_X_1;
                                                let _e861 = refractDirG;
                                                let _e863 = refractDirG;
                                                let _e867 = _o_ratio_3;
                                                let _e871 = refractDirG;
                                                _o_X_1 = (_e860 + ((((_e861.z / abs(_e863.x)) * _e867) * 0.5f) * -(sign(_e871.x))));
                                                let _e877 = _o_Y_1;
                                                let _e878 = refractDirG;
                                                let _e880 = refractDirG;
                                                _o_Y_1 = (_e877 + ((_e878.y / abs(_e880.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e887 = _o_X_1;
                                    let _e888 = _o_Y_1;
                                    let _e893 = global.U[0];
                                    let _e896 = _o_X_1;
                                    let _e897 = _o_Y_1;
                                    let _e908 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e887, _e888).x / _e893.x), vec2<f32>(_e896, _e897).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colG = _e908;
                                }
                            } else {
                                {
                                    let _e909 = refractDirG;
                                    let _e914 = ((_e909 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e914.x, _e914.y, _e914.z, 1f);
                                }
                            }
                        }
                    }
                    let _e920 = backgroundStyle_1;
                    if (_e920 == 0i) {
                        {
                            let _e923 = refractDirB;
                            _o_n_2 = normalize(_e923);
                            let _e926 = _o_n_2;
                            let _e928 = _o_n_2;
                            _o_alpha_2 = atan2(_e926.z, _e928.x);
                            let _e932 = _o_n_2;
                            _o_beta_2 = asin(_e932.y);
                            let _e936 = sourceDim_1;
                            let _e938 = sourceDim_1;
                            _o_ratio_4 = (_e936.x / _e938.y);
                            let _e946 = _o_alpha_2;
                            let _e952 = _o_nX_2;
                            let _e955 = _o_nY_2;
                            let _e956 = _o_beta_2;
                            let _e965 = global.U[0];
                            let _e968 = _o_alpha_2;
                            let _e974 = _o_nX_2;
                            let _e977 = _o_nY_2;
                            let _e978 = _o_beta_2;
                            let _e993 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e946) / 3.1415927f) * 0.5f) * _e952), (0.5f + ((_e955 * _e956) / 3.1415927f))).x / _e965.x), vec2<f32>((((-(_e968) / 3.1415927f) * 0.5f) * _e974), (0.5f + ((_e977 * _e978) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colB = _e993;
                        }
                    } else {
                        let _e994 = backgroundStyle_1;
                        if (_e994 == 1i) {
                            {
                                let _e997 = refractDirB;
                                let _e1000 = refractDirB;
                                let _e1003 = refractDirB;
                                let _e1006 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e997.x) / _e1000.z), (-(_e1003.y) / _e1006.z)) * 1f);
                                let _e1013 = _o_pos_2;
                                let _e1016 = _o_pos_2;
                                _o_m_2 = max(abs(_e1013.x), abs(_e1016.y));
                                let _e1023 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1023));
                                let _e1027 = _o_pos_2;
                                let _e1031 = global.U[0];
                                let _e1034 = _o_pos_2;
                                let _e1044 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1027.x / _e1031.x), _e1034.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1045 = _o_darken_2;
                                let _e1046 = _o_darken_2;
                                let _e1047 = _o_darken_2;
                                colB = (_e1044 * vec4<f32>(_e1045, _e1046, _e1047, 1f));
                            }
                        } else {
                            let _e1051 = backgroundStyle_1;
                            if (_e1051 == 2i) {
                                {
                                    let _e1054 = sourceDim_1;
                                    let _e1056 = sourceDim_1;
                                    _o_ratio_5 = (_e1054.y / _e1056.x);
                                    let _e1064 = refractDirB;
                                    let _e1067 = refractDirB;
                                    let _e1070 = _o_ratio_5;
                                    let _e1073 = refractDirB;
                                    let _e1076 = refractDirB;
                                    let _e1079 = _o_ratio_5;
                                    if ((abs(_e1064.y) > (abs(_e1067.z) * _e1070)) && (abs(_e1073.y) > (abs(_e1076.x) * _e1079))) {
                                        {
                                            let _e1083 = _o_X_2;
                                            let _e1084 = refractDirB;
                                            let _e1087 = refractDirB;
                                            _o_X_2 = (_e1083 + ((-(_e1084.x) / _e1087.y) * 0.5f));
                                            let _e1093 = _o_Y_2;
                                            let _e1094 = refractDirB;
                                            let _e1097 = refractDirB;
                                            _o_Y_2 = (_e1093 + ((-(_e1094.z) / _e1097.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1103 = refractDirB;
                                        let _e1106 = refractDirB;
                                        if (abs(_e1103.x) < abs(_e1106.z)) {
                                            {
                                                let _e1110 = _o_X_2;
                                                let _e1111 = refractDirB;
                                                let _e1113 = refractDirB;
                                                let _e1117 = _o_ratio_5;
                                                let _e1121 = refractDirB;
                                                _o_X_2 = (_e1110 + ((((_e1111.x / abs(_e1113.z)) * _e1117) * 0.5f) * -(sign(_e1121.z))));
                                                let _e1127 = _o_Y_2;
                                                let _e1128 = refractDirB;
                                                let _e1130 = refractDirB;
                                                _o_Y_2 = (_e1127 + ((_e1128.y / abs(_e1130.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1137 = _o_X_2;
                                                let _e1138 = refractDirB;
                                                let _e1140 = refractDirB;
                                                let _e1144 = _o_ratio_5;
                                                let _e1148 = refractDirB;
                                                _o_X_2 = (_e1137 + ((((_e1138.z / abs(_e1140.x)) * _e1144) * 0.5f) * -(sign(_e1148.x))));
                                                let _e1154 = _o_Y_2;
                                                let _e1155 = refractDirB;
                                                let _e1157 = refractDirB;
                                                _o_Y_2 = (_e1154 + ((_e1155.y / abs(_e1157.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1164 = _o_X_2;
                                    let _e1165 = _o_Y_2;
                                    let _e1170 = global.U[0];
                                    let _e1173 = _o_X_2;
                                    let _e1174 = _o_Y_2;
                                    let _e1185 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1164, _e1165).x / _e1170.x), vec2<f32>(_e1173, _e1174).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colB = _e1185;
                                }
                            } else {
                                {
                                    let _e1186 = refractDirB;
                                    let _e1191 = ((_e1186 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1191.x, _e1191.y, _e1191.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1197 = colR;
                    let _e1199 = colG;
                    let _e1201 = colB;
                    col = vec4<f32>(_e1197.x, _e1199.y, _e1201.z, 1f);
                    let _e1207 = absorption;
                    let _e1208 = qIn;
                    let _e1209 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1207 * length((_e1208 - _e1209)))));
                    let _e1217 = absorbed;
                    let _e1220 = colorMaterial_1;
                    absorbed = mix(0f, _e1217, smoothstep(0f, 0.1f, _e1220.w));
                    let _e1224 = color;
                    let _e1226 = color;
                    let _e1228 = colorMaterial_1;
                    let _e1231 = fresnel;
                    let _e1235 = absorbed;
                    let _e1238 = col;
                    let _e1241 = (_e1226.xyz + (((_e1228.xyz * (1f - _e1231)) * (1f - _e1235)) * _e1238.xyz));
                    color.x = _e1241.x;
                    color.y = _e1241.y;
                    color.z = _e1241.z;
                    let _e1248 = color;
                    let _e1250 = color;
                    let _e1252 = absorbed;
                    let _e1253 = colorMaterial_1;
                    let _e1256 = ambientColor_1;
                    let _e1259 = nIn;
                    let _e1260 = lightDir;
                    let _e1263 = sourceColor_1;
                    let _e1268 = (_e1250.xyz + ((_e1252 * _e1253.xyz) * (_e1256.xyz + (max(0f, dot(_e1259, _e1260)) * _e1263.xyz))));
                    color.x = _e1268.x;
                    color.y = _e1268.y;
                    color.z = _e1268.z;
                }
            }
            let _e1275 = fresnel;
            let _e1278 = specular_1;
            if ((_e1275 != 0f) || (_e1278 != 0f)) {
                {
                    let _e1282 = reflectDir;
                    origReflectDir = _e1282;
                    let _e1284 = qIn;
                    let _e1285 = nIn;
                    let _e1289 = reflectDir;
                    let _e1291 = count_7;
                    let _e1292 = radius_7;
                    let _e1293 = randomSeed_7;
                    let _e1294 = separation_7;
                    let _e1295 = rayMarch((_e1284 + (_e1285 * 0.001f)), _e1289, 1f, _e1291, _e1292, _e1293, _e1294);
                    qR = _e1295;
                    let _e1297 = qR;
                    if (_e1297.x != 100000000000000000000f) {
                        {
                            let _e1301 = qR;
                            let _e1302 = count_7;
                            let _e1303 = radius_7;
                            let _e1304 = randomSeed_7;
                            let _e1305 = separation_7;
                            let _e1306 = normal(_e1301, _e1302, _e1303, _e1304, _e1305);
                            n_1 = _e1306;
                            let _e1308 = reflectDir;
                            let _e1309 = n_1;
                            reflectDir = reflect(_e1308, _e1309);
                        }
                    }
                    let _e1311 = model3DTransform3_;
                    let _e1312 = reflectDir;
                    reflectDir = (_e1311 * _e1312);
                    let _e1314 = backgroundStyle_1;
                    if (_e1314 == 0i) {
                        {
                            let _e1317 = reflectDir;
                            _o_n_3 = normalize(_e1317);
                            let _e1320 = _o_n_3;
                            let _e1322 = _o_n_3;
                            _o_alpha_3 = atan2(_e1320.z, _e1322.x);
                            let _e1326 = _o_n_3;
                            _o_beta_3 = asin(_e1326.y);
                            let _e1330 = sourceDim_1;
                            let _e1332 = sourceDim_1;
                            _o_ratio_6 = (_e1330.x / _e1332.y);
                            let _e1340 = _o_alpha_3;
                            let _e1346 = _o_nX_3;
                            let _e1349 = _o_nY_3;
                            let _e1350 = _o_beta_3;
                            let _e1359 = global.U[0];
                            let _e1362 = _o_alpha_3;
                            let _e1368 = _o_nX_3;
                            let _e1371 = _o_nY_3;
                            let _e1372 = _o_beta_3;
                            let _e1387 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1340) / 3.1415927f) * 0.5f) * _e1346), (0.5f + ((_e1349 * _e1350) / 3.1415927f))).x / _e1359.x), vec2<f32>((((-(_e1362) / 3.1415927f) * 0.5f) * _e1368), (0.5f + ((_e1371 * _e1372) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1387;
                        }
                    } else {
                        let _e1388 = backgroundStyle_1;
                        if (_e1388 == 1i) {
                            {
                                let _e1391 = reflectDir;
                                let _e1394 = reflectDir;
                                let _e1397 = reflectDir;
                                let _e1400 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1391.x) / _e1394.z), (-(_e1397.y) / _e1400.z)) * 1f);
                                let _e1407 = _o_pos_3;
                                let _e1410 = _o_pos_3;
                                _o_m_3 = max(abs(_e1407.x), abs(_e1410.y));
                                let _e1417 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1417));
                                let _e1421 = _o_pos_3;
                                let _e1425 = global.U[0];
                                let _e1428 = _o_pos_3;
                                let _e1438 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1421.x / _e1425.x), _e1428.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1439 = _o_darken_3;
                                let _e1440 = _o_darken_3;
                                let _e1441 = _o_darken_3;
                                col = (_e1438 * vec4<f32>(_e1439, _e1440, _e1441, 1f));
                            }
                        } else {
                            let _e1445 = backgroundStyle_1;
                            if (_e1445 == 2i) {
                                {
                                    let _e1448 = sourceDim_1;
                                    let _e1450 = sourceDim_1;
                                    _o_ratio_7 = (_e1448.y / _e1450.x);
                                    let _e1458 = reflectDir;
                                    let _e1461 = reflectDir;
                                    let _e1464 = _o_ratio_7;
                                    let _e1467 = reflectDir;
                                    let _e1470 = reflectDir;
                                    let _e1473 = _o_ratio_7;
                                    if ((abs(_e1458.y) > (abs(_e1461.z) * _e1464)) && (abs(_e1467.y) > (abs(_e1470.x) * _e1473))) {
                                        {
                                            let _e1477 = _o_X_3;
                                            let _e1478 = reflectDir;
                                            let _e1481 = reflectDir;
                                            _o_X_3 = (_e1477 + ((-(_e1478.x) / _e1481.y) * 0.5f));
                                            let _e1487 = _o_Y_3;
                                            let _e1488 = reflectDir;
                                            let _e1491 = reflectDir;
                                            _o_Y_3 = (_e1487 + ((-(_e1488.z) / _e1491.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1497 = reflectDir;
                                        let _e1500 = reflectDir;
                                        if (abs(_e1497.x) < abs(_e1500.z)) {
                                            {
                                                let _e1504 = _o_X_3;
                                                let _e1505 = reflectDir;
                                                let _e1507 = reflectDir;
                                                let _e1511 = _o_ratio_7;
                                                let _e1515 = reflectDir;
                                                _o_X_3 = (_e1504 + ((((_e1505.x / abs(_e1507.z)) * _e1511) * 0.5f) * -(sign(_e1515.z))));
                                                let _e1521 = _o_Y_3;
                                                let _e1522 = reflectDir;
                                                let _e1524 = reflectDir;
                                                _o_Y_3 = (_e1521 + ((_e1522.y / abs(_e1524.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1531 = _o_X_3;
                                                let _e1532 = reflectDir;
                                                let _e1534 = reflectDir;
                                                let _e1538 = _o_ratio_7;
                                                let _e1542 = reflectDir;
                                                _o_X_3 = (_e1531 + ((((_e1532.z / abs(_e1534.x)) * _e1538) * 0.5f) * -(sign(_e1542.x))));
                                                let _e1548 = _o_Y_3;
                                                let _e1549 = reflectDir;
                                                let _e1551 = reflectDir;
                                                _o_Y_3 = (_e1548 + ((_e1549.y / abs(_e1551.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1558 = _o_X_3;
                                    let _e1559 = _o_Y_3;
                                    let _e1564 = global.U[0];
                                    let _e1567 = _o_X_3;
                                    let _e1568 = _o_Y_3;
                                    let _e1579 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1558, _e1559).x / _e1564.x), vec2<f32>(_e1567, _e1568).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e1579;
                                }
                            } else {
                                {
                                    let _e1580 = reflectDir;
                                    let _e1585 = ((_e1580 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1585.x, _e1585.y, _e1585.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1591 = color;
                    let _e1593 = color;
                    let _e1595 = fresnel;
                    let _e1596 = col;
                    let _e1599 = (_e1593.xyz + (_e1595 * _e1596.xyz));
                    color.x = _e1599.x;
                    color.y = _e1599.y;
                    color.z = _e1599.z;
                    let _e1607 = specular_1;
                    let _e1610 = lightDir;
                    let _e1611 = origReflectDir;
                    kSpec = ((10f * _e1607) * pow(max(0f, dot(_e1610, _e1611)), 9f));
                    let _e1618 = color;
                    let _e1620 = color;
                    let _e1622 = sourceColor_1;
                    let _e1624 = kSpec;
                    let _e1626 = (_e1620.xyz + (_e1622.xyz * _e1624));
                    color.x = _e1626.x;
                    color.y = _e1626.y;
                    color.z = _e1626.z;
                }
            }
            let _e1633 = colorFog_1;
            if (_e1633.w != 0f) {
                {
                    let _e1637 = camera_2;
                    let _e1638 = qIn;
                    dist = length((_e1637 - _e1638));
                    let _e1644 = colorFog_1;
                    let _e1647 = dist;
                    kFog = (1f - pow(0.4f, (_e1644.w * max(0f, (_e1647 - 0.1f)))));
                    let _e1655 = color;
                    let _e1657 = color;
                    let _e1659 = colorFog_1;
                    let _e1661 = kFog;
                    let _e1663 = mix(_e1657.xyz, _e1659.xyz, vec3(_e1661));
                    color.x = _e1663.x;
                    color.y = _e1663.y;
                    color.z = _e1663.z;
                }
            }
        }
    } else {
        {
            let _e1670 = bkgTransform_1;
            let _e1680 = model3DTransform3_;
            let _e1682 = camDir;
            camDir = ((mat3x3<f32>(_e1670[0].xyz, _e1670[1].xyz, _e1670[2].xyz) * _e1680) * _e1682);
            let _e1684 = backgroundStyle_1;
            if (_e1684 == 0i) {
                {
                    let _e1687 = camDir;
                    _o_n_4 = normalize(_e1687);
                    let _e1690 = _o_n_4;
                    let _e1692 = _o_n_4;
                    _o_alpha_4 = atan2(_e1690.z, _e1692.x);
                    let _e1696 = _o_n_4;
                    _o_beta_4 = asin(_e1696.y);
                    let _e1700 = sourceDim_1;
                    let _e1702 = sourceDim_1;
                    _o_ratio_8 = (_e1700.x / _e1702.y);
                    let _e1710 = _o_alpha_4;
                    let _e1716 = _o_nX_4;
                    let _e1719 = _o_nY_4;
                    let _e1720 = _o_beta_4;
                    let _e1729 = global.U[0];
                    let _e1732 = _o_alpha_4;
                    let _e1738 = _o_nX_4;
                    let _e1741 = _o_nY_4;
                    let _e1742 = _o_beta_4;
                    let _e1757 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1710) / 3.1415927f) * 0.5f) * _e1716), (0.5f + ((_e1719 * _e1720) / 3.1415927f))).x / _e1729.x), vec2<f32>((((-(_e1732) / 3.1415927f) * 0.5f) * _e1738), (0.5f + ((_e1741 * _e1742) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col = _e1757;
                }
            } else {
                let _e1758 = backgroundStyle_1;
                if (_e1758 == 1i) {
                    {
                        let _e1761 = camDir;
                        let _e1764 = camDir;
                        let _e1767 = camDir;
                        let _e1770 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1761.x) / _e1764.z), (-(_e1767.y) / _e1770.z)) * 1f);
                        let _e1777 = _o_pos_4;
                        let _e1780 = _o_pos_4;
                        _o_m_4 = max(abs(_e1777.x), abs(_e1780.y));
                        let _e1787 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1787));
                        let _e1791 = _o_pos_4;
                        let _e1795 = global.U[0];
                        let _e1798 = _o_pos_4;
                        let _e1808 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1791.x / _e1795.x), _e1798.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1809 = _o_darken_4;
                        let _e1810 = _o_darken_4;
                        let _e1811 = _o_darken_4;
                        col = (_e1808 * vec4<f32>(_e1809, _e1810, _e1811, 1f));
                    }
                } else {
                    let _e1815 = backgroundStyle_1;
                    if (_e1815 == 2i) {
                        {
                            let _e1818 = sourceDim_1;
                            let _e1820 = sourceDim_1;
                            _o_ratio_9 = (_e1818.y / _e1820.x);
                            let _e1828 = camDir;
                            let _e1831 = camDir;
                            let _e1834 = _o_ratio_9;
                            let _e1837 = camDir;
                            let _e1840 = camDir;
                            let _e1843 = _o_ratio_9;
                            if ((abs(_e1828.y) > (abs(_e1831.z) * _e1834)) && (abs(_e1837.y) > (abs(_e1840.x) * _e1843))) {
                                {
                                    let _e1847 = _o_X_4;
                                    let _e1848 = camDir;
                                    let _e1851 = camDir;
                                    _o_X_4 = (_e1847 + ((-(_e1848.x) / _e1851.y) * 0.5f));
                                    let _e1857 = _o_Y_4;
                                    let _e1858 = camDir;
                                    let _e1861 = camDir;
                                    _o_Y_4 = (_e1857 + ((-(_e1858.z) / _e1861.y) * 0.5f));
                                }
                            } else {
                                let _e1867 = camDir;
                                let _e1870 = camDir;
                                if (abs(_e1867.x) < abs(_e1870.z)) {
                                    {
                                        let _e1874 = _o_X_4;
                                        let _e1875 = camDir;
                                        let _e1877 = camDir;
                                        let _e1881 = _o_ratio_9;
                                        let _e1885 = camDir;
                                        _o_X_4 = (_e1874 + ((((_e1875.x / abs(_e1877.z)) * _e1881) * 0.5f) * -(sign(_e1885.z))));
                                        let _e1891 = _o_Y_4;
                                        let _e1892 = camDir;
                                        let _e1894 = camDir;
                                        _o_Y_4 = (_e1891 + ((_e1892.y / abs(_e1894.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1901 = _o_X_4;
                                        let _e1902 = camDir;
                                        let _e1904 = camDir;
                                        let _e1908 = _o_ratio_9;
                                        let _e1912 = camDir;
                                        _o_X_4 = (_e1901 + ((((_e1902.z / abs(_e1904.x)) * _e1908) * 0.5f) * -(sign(_e1912.x))));
                                        let _e1918 = _o_Y_4;
                                        let _e1919 = camDir;
                                        let _e1921 = camDir;
                                        _o_Y_4 = (_e1918 + ((_e1919.y / abs(_e1921.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1928 = _o_X_4;
                            let _e1929 = _o_Y_4;
                            let _e1934 = global.U[0];
                            let _e1937 = _o_X_4;
                            let _e1938 = _o_Y_4;
                            let _e1949 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1928, _e1929).x / _e1934.x), vec2<f32>(_e1937, _e1938).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1949;
                        }
                    } else {
                        {
                            let _e1950 = camDir;
                            let _e1955 = ((_e1950 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1955.x, _e1955.y, _e1955.z, 1f);
                        }
                    }
                }
            }
            let _e1961 = colorFog_1;
            if (_e1961.w != 0f) {
                let _e1965 = color;
                let _e1967 = colorFog_1;
                let _e1968 = _e1967.xyz;
                color.x = _e1968.x;
                color.y = _e1968.y;
                color.z = _e1968.z;
            } else {
                let _e1975 = col;
                color = _e1975;
            }
        }
    }
    let _e1976 = color;
    return clamp(_e1976, vec4(0f), vec4(1f));
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
    let _e241 = global.U[33];
    let _e245 = global.U[34];
    let _e249 = global.U[35];
    let _e251 = rayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)), mat4x4<f32>(vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w)), _e203, _e206.x, _e210.x, _e214.x, _e218, _e221, _e224, _e227.x, i32(_e231.x), i32(_e236.x), _e241.x, _e245.x, _e249.x);
    fragColor = _e251;
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
