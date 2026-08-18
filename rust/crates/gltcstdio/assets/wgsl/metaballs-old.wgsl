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
                            let _e438 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e392) / 3.1415927f) * 0.5f) * _e398), (0.5f + ((_e401 * _e402) / 3.1415927f))).x / _e411.x), vec2<f32>((((-(_e414) / 3.1415927f) * 0.5f) * _e420), (0.5f + ((_e423 * _e424) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colR = _e438;
                        }
                    } else {
                        let _e439 = backgroundStyle_1;
                        if (_e439 == 1i) {
                            {
                                let _e442 = refractDirR;
                                let _e445 = refractDirR;
                                let _e448 = refractDirR;
                                let _e451 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e442.x) / _e445.z), (-(_e448.y) / _e451.z)) * 1f);
                                let _e458 = _o_pos;
                                let _e461 = _o_pos;
                                _o_m = max(abs(_e458.x), abs(_e461.y));
                                let _e468 = _o_m;
                                _o_darken = (4f / max(4f, _e468));
                                let _e472 = _o_pos;
                                let _e476 = global.U[0];
                                let _e479 = _o_pos;
                                let _e488 = textureSample(t_source, samp, ((vec2<f32>((_e472.x / _e476.x), _e479.y) / vec2(2f)) + vec2(0.5f)));
                                let _e489 = _o_darken;
                                let _e490 = _o_darken;
                                let _e491 = _o_darken;
                                colR = (_e488 * vec4<f32>(_e489, _e490, _e491, 1f));
                            }
                        } else {
                            let _e495 = backgroundStyle_1;
                            if (_e495 == 2i) {
                                {
                                    let _e498 = sourceDim_1;
                                    let _e500 = sourceDim_1;
                                    _o_ratio_1 = (_e498.y / _e500.x);
                                    let _e508 = refractDirR;
                                    let _e511 = refractDirR;
                                    let _e514 = _o_ratio_1;
                                    let _e517 = refractDirR;
                                    let _e520 = refractDirR;
                                    let _e523 = _o_ratio_1;
                                    if ((abs(_e508.y) > (abs(_e511.z) * _e514)) && (abs(_e517.y) > (abs(_e520.x) * _e523))) {
                                        {
                                            let _e527 = _o_X;
                                            let _e528 = refractDirR;
                                            let _e531 = refractDirR;
                                            _o_X = (_e527 + ((-(_e528.x) / _e531.y) * 0.5f));
                                            let _e537 = _o_Y;
                                            let _e538 = refractDirR;
                                            let _e541 = refractDirR;
                                            _o_Y = (_e537 + ((-(_e538.z) / _e541.y) * 0.5f));
                                        }
                                    } else {
                                        let _e547 = refractDirR;
                                        let _e550 = refractDirR;
                                        if (abs(_e547.x) < abs(_e550.z)) {
                                            {
                                                let _e554 = _o_X;
                                                let _e555 = refractDirR;
                                                let _e557 = refractDirR;
                                                let _e561 = _o_ratio_1;
                                                let _e565 = refractDirR;
                                                _o_X = (_e554 + ((((_e555.x / abs(_e557.z)) * _e561) * 0.5f) * -(sign(_e565.z))));
                                                let _e571 = _o_Y;
                                                let _e572 = refractDirR;
                                                let _e574 = refractDirR;
                                                _o_Y = (_e571 + ((_e572.y / abs(_e574.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e581 = _o_X;
                                                let _e582 = refractDirR;
                                                let _e584 = refractDirR;
                                                let _e588 = _o_ratio_1;
                                                let _e592 = refractDirR;
                                                _o_X = (_e581 + ((((_e582.z / abs(_e584.x)) * _e588) * 0.5f) * -(sign(_e592.x))));
                                                let _e598 = _o_Y;
                                                let _e599 = refractDirR;
                                                let _e601 = refractDirR;
                                                _o_Y = (_e598 + ((_e599.y / abs(_e601.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e608 = _o_X;
                                    let _e609 = _o_Y;
                                    let _e614 = global.U[0];
                                    let _e617 = _o_X;
                                    let _e618 = _o_Y;
                                    let _e628 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e608, _e609).x / _e614.x), vec2<f32>(_e617, _e618).y) / vec2(2f)) + vec2(0.5f)));
                                    colR = _e628;
                                }
                            } else {
                                {
                                    let _e629 = refractDirR;
                                    let _e634 = ((_e629 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e634.x, _e634.y, _e634.z, 1f);
                                }
                            }
                        }
                    }
                    let _e640 = backgroundStyle_1;
                    if (_e640 == 0i) {
                        {
                            let _e643 = refractDirG;
                            _o_n_1 = normalize(_e643);
                            let _e646 = _o_n_1;
                            let _e648 = _o_n_1;
                            _o_alpha_1 = atan2(_e646.z, _e648.x);
                            let _e652 = _o_n_1;
                            _o_beta_1 = asin(_e652.y);
                            let _e656 = sourceDim_1;
                            let _e658 = sourceDim_1;
                            _o_ratio_2 = (_e656.x / _e658.y);
                            let _e666 = _o_alpha_1;
                            let _e672 = _o_nX_1;
                            let _e675 = _o_nY_1;
                            let _e676 = _o_beta_1;
                            let _e685 = global.U[0];
                            let _e688 = _o_alpha_1;
                            let _e694 = _o_nX_1;
                            let _e697 = _o_nY_1;
                            let _e698 = _o_beta_1;
                            let _e712 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e666) / 3.1415927f) * 0.5f) * _e672), (0.5f + ((_e675 * _e676) / 3.1415927f))).x / _e685.x), vec2<f32>((((-(_e688) / 3.1415927f) * 0.5f) * _e694), (0.5f + ((_e697 * _e698) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colG = _e712;
                        }
                    } else {
                        let _e713 = backgroundStyle_1;
                        if (_e713 == 1i) {
                            {
                                let _e716 = refractDirG;
                                let _e719 = refractDirG;
                                let _e722 = refractDirG;
                                let _e725 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e716.x) / _e719.z), (-(_e722.y) / _e725.z)) * 1f);
                                let _e732 = _o_pos_1;
                                let _e735 = _o_pos_1;
                                _o_m_1 = max(abs(_e732.x), abs(_e735.y));
                                let _e742 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e742));
                                let _e746 = _o_pos_1;
                                let _e750 = global.U[0];
                                let _e753 = _o_pos_1;
                                let _e762 = textureSample(t_source, samp, ((vec2<f32>((_e746.x / _e750.x), _e753.y) / vec2(2f)) + vec2(0.5f)));
                                let _e763 = _o_darken_1;
                                let _e764 = _o_darken_1;
                                let _e765 = _o_darken_1;
                                colG = (_e762 * vec4<f32>(_e763, _e764, _e765, 1f));
                            }
                        } else {
                            let _e769 = backgroundStyle_1;
                            if (_e769 == 2i) {
                                {
                                    let _e772 = sourceDim_1;
                                    let _e774 = sourceDim_1;
                                    _o_ratio_3 = (_e772.y / _e774.x);
                                    let _e782 = refractDirG;
                                    let _e785 = refractDirG;
                                    let _e788 = _o_ratio_3;
                                    let _e791 = refractDirG;
                                    let _e794 = refractDirG;
                                    let _e797 = _o_ratio_3;
                                    if ((abs(_e782.y) > (abs(_e785.z) * _e788)) && (abs(_e791.y) > (abs(_e794.x) * _e797))) {
                                        {
                                            let _e801 = _o_X_1;
                                            let _e802 = refractDirG;
                                            let _e805 = refractDirG;
                                            _o_X_1 = (_e801 + ((-(_e802.x) / _e805.y) * 0.5f));
                                            let _e811 = _o_Y_1;
                                            let _e812 = refractDirG;
                                            let _e815 = refractDirG;
                                            _o_Y_1 = (_e811 + ((-(_e812.z) / _e815.y) * 0.5f));
                                        }
                                    } else {
                                        let _e821 = refractDirG;
                                        let _e824 = refractDirG;
                                        if (abs(_e821.x) < abs(_e824.z)) {
                                            {
                                                let _e828 = _o_X_1;
                                                let _e829 = refractDirG;
                                                let _e831 = refractDirG;
                                                let _e835 = _o_ratio_3;
                                                let _e839 = refractDirG;
                                                _o_X_1 = (_e828 + ((((_e829.x / abs(_e831.z)) * _e835) * 0.5f) * -(sign(_e839.z))));
                                                let _e845 = _o_Y_1;
                                                let _e846 = refractDirG;
                                                let _e848 = refractDirG;
                                                _o_Y_1 = (_e845 + ((_e846.y / abs(_e848.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e855 = _o_X_1;
                                                let _e856 = refractDirG;
                                                let _e858 = refractDirG;
                                                let _e862 = _o_ratio_3;
                                                let _e866 = refractDirG;
                                                _o_X_1 = (_e855 + ((((_e856.z / abs(_e858.x)) * _e862) * 0.5f) * -(sign(_e866.x))));
                                                let _e872 = _o_Y_1;
                                                let _e873 = refractDirG;
                                                let _e875 = refractDirG;
                                                _o_Y_1 = (_e872 + ((_e873.y / abs(_e875.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e882 = _o_X_1;
                                    let _e883 = _o_Y_1;
                                    let _e888 = global.U[0];
                                    let _e891 = _o_X_1;
                                    let _e892 = _o_Y_1;
                                    let _e902 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e882, _e883).x / _e888.x), vec2<f32>(_e891, _e892).y) / vec2(2f)) + vec2(0.5f)));
                                    colG = _e902;
                                }
                            } else {
                                {
                                    let _e903 = refractDirG;
                                    let _e908 = ((_e903 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e908.x, _e908.y, _e908.z, 1f);
                                }
                            }
                        }
                    }
                    let _e914 = backgroundStyle_1;
                    if (_e914 == 0i) {
                        {
                            let _e917 = refractDirB;
                            _o_n_2 = normalize(_e917);
                            let _e920 = _o_n_2;
                            let _e922 = _o_n_2;
                            _o_alpha_2 = atan2(_e920.z, _e922.x);
                            let _e926 = _o_n_2;
                            _o_beta_2 = asin(_e926.y);
                            let _e930 = sourceDim_1;
                            let _e932 = sourceDim_1;
                            _o_ratio_4 = (_e930.x / _e932.y);
                            let _e940 = _o_alpha_2;
                            let _e946 = _o_nX_2;
                            let _e949 = _o_nY_2;
                            let _e950 = _o_beta_2;
                            let _e959 = global.U[0];
                            let _e962 = _o_alpha_2;
                            let _e968 = _o_nX_2;
                            let _e971 = _o_nY_2;
                            let _e972 = _o_beta_2;
                            let _e986 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e940) / 3.1415927f) * 0.5f) * _e946), (0.5f + ((_e949 * _e950) / 3.1415927f))).x / _e959.x), vec2<f32>((((-(_e962) / 3.1415927f) * 0.5f) * _e968), (0.5f + ((_e971 * _e972) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colB = _e986;
                        }
                    } else {
                        let _e987 = backgroundStyle_1;
                        if (_e987 == 1i) {
                            {
                                let _e990 = refractDirB;
                                let _e993 = refractDirB;
                                let _e996 = refractDirB;
                                let _e999 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e990.x) / _e993.z), (-(_e996.y) / _e999.z)) * 1f);
                                let _e1006 = _o_pos_2;
                                let _e1009 = _o_pos_2;
                                _o_m_2 = max(abs(_e1006.x), abs(_e1009.y));
                                let _e1016 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1016));
                                let _e1020 = _o_pos_2;
                                let _e1024 = global.U[0];
                                let _e1027 = _o_pos_2;
                                let _e1036 = textureSample(t_source, samp, ((vec2<f32>((_e1020.x / _e1024.x), _e1027.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1037 = _o_darken_2;
                                let _e1038 = _o_darken_2;
                                let _e1039 = _o_darken_2;
                                colB = (_e1036 * vec4<f32>(_e1037, _e1038, _e1039, 1f));
                            }
                        } else {
                            let _e1043 = backgroundStyle_1;
                            if (_e1043 == 2i) {
                                {
                                    let _e1046 = sourceDim_1;
                                    let _e1048 = sourceDim_1;
                                    _o_ratio_5 = (_e1046.y / _e1048.x);
                                    let _e1056 = refractDirB;
                                    let _e1059 = refractDirB;
                                    let _e1062 = _o_ratio_5;
                                    let _e1065 = refractDirB;
                                    let _e1068 = refractDirB;
                                    let _e1071 = _o_ratio_5;
                                    if ((abs(_e1056.y) > (abs(_e1059.z) * _e1062)) && (abs(_e1065.y) > (abs(_e1068.x) * _e1071))) {
                                        {
                                            let _e1075 = _o_X_2;
                                            let _e1076 = refractDirB;
                                            let _e1079 = refractDirB;
                                            _o_X_2 = (_e1075 + ((-(_e1076.x) / _e1079.y) * 0.5f));
                                            let _e1085 = _o_Y_2;
                                            let _e1086 = refractDirB;
                                            let _e1089 = refractDirB;
                                            _o_Y_2 = (_e1085 + ((-(_e1086.z) / _e1089.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1095 = refractDirB;
                                        let _e1098 = refractDirB;
                                        if (abs(_e1095.x) < abs(_e1098.z)) {
                                            {
                                                let _e1102 = _o_X_2;
                                                let _e1103 = refractDirB;
                                                let _e1105 = refractDirB;
                                                let _e1109 = _o_ratio_5;
                                                let _e1113 = refractDirB;
                                                _o_X_2 = (_e1102 + ((((_e1103.x / abs(_e1105.z)) * _e1109) * 0.5f) * -(sign(_e1113.z))));
                                                let _e1119 = _o_Y_2;
                                                let _e1120 = refractDirB;
                                                let _e1122 = refractDirB;
                                                _o_Y_2 = (_e1119 + ((_e1120.y / abs(_e1122.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1129 = _o_X_2;
                                                let _e1130 = refractDirB;
                                                let _e1132 = refractDirB;
                                                let _e1136 = _o_ratio_5;
                                                let _e1140 = refractDirB;
                                                _o_X_2 = (_e1129 + ((((_e1130.z / abs(_e1132.x)) * _e1136) * 0.5f) * -(sign(_e1140.x))));
                                                let _e1146 = _o_Y_2;
                                                let _e1147 = refractDirB;
                                                let _e1149 = refractDirB;
                                                _o_Y_2 = (_e1146 + ((_e1147.y / abs(_e1149.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1156 = _o_X_2;
                                    let _e1157 = _o_Y_2;
                                    let _e1162 = global.U[0];
                                    let _e1165 = _o_X_2;
                                    let _e1166 = _o_Y_2;
                                    let _e1176 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1156, _e1157).x / _e1162.x), vec2<f32>(_e1165, _e1166).y) / vec2(2f)) + vec2(0.5f)));
                                    colB = _e1176;
                                }
                            } else {
                                {
                                    let _e1177 = refractDirB;
                                    let _e1182 = ((_e1177 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1182.x, _e1182.y, _e1182.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1188 = colR;
                    let _e1190 = colG;
                    let _e1192 = colB;
                    col = vec4<f32>(_e1188.x, _e1190.y, _e1192.z, 1f);
                    let _e1198 = absorption;
                    let _e1199 = qIn;
                    let _e1200 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1198 * length((_e1199 - _e1200)))));
                    let _e1208 = absorbed;
                    let _e1211 = colorMaterial_1;
                    absorbed = mix(0f, _e1208, smoothstep(0f, 0.1f, _e1211.w));
                    let _e1215 = color;
                    let _e1217 = color;
                    let _e1219 = colorMaterial_1;
                    let _e1222 = fresnel;
                    let _e1226 = absorbed;
                    let _e1229 = col;
                    let _e1232 = (_e1217.xyz + (((_e1219.xyz * (1f - _e1222)) * (1f - _e1226)) * _e1229.xyz));
                    color.x = _e1232.x;
                    color.y = _e1232.y;
                    color.z = _e1232.z;
                    let _e1239 = color;
                    let _e1241 = color;
                    let _e1243 = absorbed;
                    let _e1244 = colorMaterial_1;
                    let _e1247 = ambientColor_1;
                    let _e1250 = nIn;
                    let _e1251 = lightDir;
                    let _e1254 = sourceColor_1;
                    let _e1259 = (_e1241.xyz + ((_e1243 * _e1244.xyz) * (_e1247.xyz + (max(0f, dot(_e1250, _e1251)) * _e1254.xyz))));
                    color.x = _e1259.x;
                    color.y = _e1259.y;
                    color.z = _e1259.z;
                }
            }
            let _e1266 = fresnel;
            let _e1269 = specular_1;
            if ((_e1266 != 0f) || (_e1269 != 0f)) {
                {
                    let _e1273 = reflectDir;
                    origReflectDir = _e1273;
                    let _e1275 = qIn;
                    let _e1276 = nIn;
                    let _e1280 = reflectDir;
                    let _e1282 = count_7;
                    let _e1283 = radius_7;
                    let _e1284 = randomSeed_7;
                    let _e1285 = separation_7;
                    let _e1286 = rayMarch((_e1275 + (_e1276 * 0.001f)), _e1280, 1f, _e1282, _e1283, _e1284, _e1285);
                    qR = _e1286;
                    let _e1288 = qR;
                    if (_e1288.x != 100000000000000000000f) {
                        {
                            let _e1292 = qR;
                            let _e1293 = count_7;
                            let _e1294 = radius_7;
                            let _e1295 = randomSeed_7;
                            let _e1296 = separation_7;
                            let _e1297 = normal(_e1292, _e1293, _e1294, _e1295, _e1296);
                            n_1 = _e1297;
                            let _e1299 = reflectDir;
                            let _e1300 = n_1;
                            reflectDir = reflect(_e1299, _e1300);
                        }
                    }
                    let _e1302 = model3DTransform3_;
                    let _e1303 = reflectDir;
                    reflectDir = (_e1302 * _e1303);
                    let _e1305 = backgroundStyle_1;
                    if (_e1305 == 0i) {
                        {
                            let _e1308 = reflectDir;
                            _o_n_3 = normalize(_e1308);
                            let _e1311 = _o_n_3;
                            let _e1313 = _o_n_3;
                            _o_alpha_3 = atan2(_e1311.z, _e1313.x);
                            let _e1317 = _o_n_3;
                            _o_beta_3 = asin(_e1317.y);
                            let _e1321 = sourceDim_1;
                            let _e1323 = sourceDim_1;
                            _o_ratio_6 = (_e1321.x / _e1323.y);
                            let _e1331 = _o_alpha_3;
                            let _e1337 = _o_nX_3;
                            let _e1340 = _o_nY_3;
                            let _e1341 = _o_beta_3;
                            let _e1350 = global.U[0];
                            let _e1353 = _o_alpha_3;
                            let _e1359 = _o_nX_3;
                            let _e1362 = _o_nY_3;
                            let _e1363 = _o_beta_3;
                            let _e1377 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1331) / 3.1415927f) * 0.5f) * _e1337), (0.5f + ((_e1340 * _e1341) / 3.1415927f))).x / _e1350.x), vec2<f32>((((-(_e1353) / 3.1415927f) * 0.5f) * _e1359), (0.5f + ((_e1362 * _e1363) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1377;
                        }
                    } else {
                        let _e1378 = backgroundStyle_1;
                        if (_e1378 == 1i) {
                            {
                                let _e1381 = reflectDir;
                                let _e1384 = reflectDir;
                                let _e1387 = reflectDir;
                                let _e1390 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1381.x) / _e1384.z), (-(_e1387.y) / _e1390.z)) * 1f);
                                let _e1397 = _o_pos_3;
                                let _e1400 = _o_pos_3;
                                _o_m_3 = max(abs(_e1397.x), abs(_e1400.y));
                                let _e1407 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1407));
                                let _e1411 = _o_pos_3;
                                let _e1415 = global.U[0];
                                let _e1418 = _o_pos_3;
                                let _e1427 = textureSample(t_source, samp, ((vec2<f32>((_e1411.x / _e1415.x), _e1418.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1428 = _o_darken_3;
                                let _e1429 = _o_darken_3;
                                let _e1430 = _o_darken_3;
                                col = (_e1427 * vec4<f32>(_e1428, _e1429, _e1430, 1f));
                            }
                        } else {
                            let _e1434 = backgroundStyle_1;
                            if (_e1434 == 2i) {
                                {
                                    let _e1437 = sourceDim_1;
                                    let _e1439 = sourceDim_1;
                                    _o_ratio_7 = (_e1437.y / _e1439.x);
                                    let _e1447 = reflectDir;
                                    let _e1450 = reflectDir;
                                    let _e1453 = _o_ratio_7;
                                    let _e1456 = reflectDir;
                                    let _e1459 = reflectDir;
                                    let _e1462 = _o_ratio_7;
                                    if ((abs(_e1447.y) > (abs(_e1450.z) * _e1453)) && (abs(_e1456.y) > (abs(_e1459.x) * _e1462))) {
                                        {
                                            let _e1466 = _o_X_3;
                                            let _e1467 = reflectDir;
                                            let _e1470 = reflectDir;
                                            _o_X_3 = (_e1466 + ((-(_e1467.x) / _e1470.y) * 0.5f));
                                            let _e1476 = _o_Y_3;
                                            let _e1477 = reflectDir;
                                            let _e1480 = reflectDir;
                                            _o_Y_3 = (_e1476 + ((-(_e1477.z) / _e1480.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1486 = reflectDir;
                                        let _e1489 = reflectDir;
                                        if (abs(_e1486.x) < abs(_e1489.z)) {
                                            {
                                                let _e1493 = _o_X_3;
                                                let _e1494 = reflectDir;
                                                let _e1496 = reflectDir;
                                                let _e1500 = _o_ratio_7;
                                                let _e1504 = reflectDir;
                                                _o_X_3 = (_e1493 + ((((_e1494.x / abs(_e1496.z)) * _e1500) * 0.5f) * -(sign(_e1504.z))));
                                                let _e1510 = _o_Y_3;
                                                let _e1511 = reflectDir;
                                                let _e1513 = reflectDir;
                                                _o_Y_3 = (_e1510 + ((_e1511.y / abs(_e1513.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1520 = _o_X_3;
                                                let _e1521 = reflectDir;
                                                let _e1523 = reflectDir;
                                                let _e1527 = _o_ratio_7;
                                                let _e1531 = reflectDir;
                                                _o_X_3 = (_e1520 + ((((_e1521.z / abs(_e1523.x)) * _e1527) * 0.5f) * -(sign(_e1531.x))));
                                                let _e1537 = _o_Y_3;
                                                let _e1538 = reflectDir;
                                                let _e1540 = reflectDir;
                                                _o_Y_3 = (_e1537 + ((_e1538.y / abs(_e1540.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1547 = _o_X_3;
                                    let _e1548 = _o_Y_3;
                                    let _e1553 = global.U[0];
                                    let _e1556 = _o_X_3;
                                    let _e1557 = _o_Y_3;
                                    let _e1567 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1547, _e1548).x / _e1553.x), vec2<f32>(_e1556, _e1557).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e1567;
                                }
                            } else {
                                {
                                    let _e1568 = reflectDir;
                                    let _e1573 = ((_e1568 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1573.x, _e1573.y, _e1573.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1579 = color;
                    let _e1581 = color;
                    let _e1583 = fresnel;
                    let _e1584 = col;
                    let _e1587 = (_e1581.xyz + (_e1583 * _e1584.xyz));
                    color.x = _e1587.x;
                    color.y = _e1587.y;
                    color.z = _e1587.z;
                    let _e1595 = specular_1;
                    let _e1598 = lightDir;
                    let _e1599 = origReflectDir;
                    kSpec = ((10f * _e1595) * pow(max(0f, dot(_e1598, _e1599)), 9f));
                    let _e1606 = color;
                    let _e1608 = color;
                    let _e1610 = sourceColor_1;
                    let _e1612 = kSpec;
                    let _e1614 = (_e1608.xyz + (_e1610.xyz * _e1612));
                    color.x = _e1614.x;
                    color.y = _e1614.y;
                    color.z = _e1614.z;
                }
            }
            let _e1621 = colorFog_1;
            if (_e1621.w != 0f) {
                {
                    let _e1625 = camera_2;
                    let _e1626 = qIn;
                    dist = length((_e1625 - _e1626));
                    let _e1632 = colorFog_1;
                    let _e1635 = dist;
                    kFog = (1f - pow(0.4f, (_e1632.w * max(0f, (_e1635 - 0.1f)))));
                    let _e1643 = color;
                    let _e1645 = color;
                    let _e1647 = colorFog_1;
                    let _e1649 = kFog;
                    let _e1651 = mix(_e1645.xyz, _e1647.xyz, vec3(_e1649));
                    color.x = _e1651.x;
                    color.y = _e1651.y;
                    color.z = _e1651.z;
                }
            }
        }
    } else {
        {
            let _e1658 = bkgTransform_1;
            let _e1668 = model3DTransform3_;
            let _e1670 = camDir;
            camDir = ((mat3x3<f32>(_e1658[0].xyz, _e1658[1].xyz, _e1658[2].xyz) * _e1668) * _e1670);
            let _e1672 = backgroundStyle_1;
            if (_e1672 == 0i) {
                {
                    let _e1675 = camDir;
                    _o_n_4 = normalize(_e1675);
                    let _e1678 = _o_n_4;
                    let _e1680 = _o_n_4;
                    _o_alpha_4 = atan2(_e1678.z, _e1680.x);
                    let _e1684 = _o_n_4;
                    _o_beta_4 = asin(_e1684.y);
                    let _e1688 = sourceDim_1;
                    let _e1690 = sourceDim_1;
                    _o_ratio_8 = (_e1688.x / _e1690.y);
                    let _e1698 = _o_alpha_4;
                    let _e1704 = _o_nX_4;
                    let _e1707 = _o_nY_4;
                    let _e1708 = _o_beta_4;
                    let _e1717 = global.U[0];
                    let _e1720 = _o_alpha_4;
                    let _e1726 = _o_nX_4;
                    let _e1729 = _o_nY_4;
                    let _e1730 = _o_beta_4;
                    let _e1744 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1698) / 3.1415927f) * 0.5f) * _e1704), (0.5f + ((_e1707 * _e1708) / 3.1415927f))).x / _e1717.x), vec2<f32>((((-(_e1720) / 3.1415927f) * 0.5f) * _e1726), (0.5f + ((_e1729 * _e1730) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e1744;
                }
            } else {
                let _e1745 = backgroundStyle_1;
                if (_e1745 == 1i) {
                    {
                        let _e1748 = camDir;
                        let _e1751 = camDir;
                        let _e1754 = camDir;
                        let _e1757 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1748.x) / _e1751.z), (-(_e1754.y) / _e1757.z)) * 1f);
                        let _e1764 = _o_pos_4;
                        let _e1767 = _o_pos_4;
                        _o_m_4 = max(abs(_e1764.x), abs(_e1767.y));
                        let _e1774 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1774));
                        let _e1778 = _o_pos_4;
                        let _e1782 = global.U[0];
                        let _e1785 = _o_pos_4;
                        let _e1794 = textureSample(t_source, samp, ((vec2<f32>((_e1778.x / _e1782.x), _e1785.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1795 = _o_darken_4;
                        let _e1796 = _o_darken_4;
                        let _e1797 = _o_darken_4;
                        col = (_e1794 * vec4<f32>(_e1795, _e1796, _e1797, 1f));
                    }
                } else {
                    let _e1801 = backgroundStyle_1;
                    if (_e1801 == 2i) {
                        {
                            let _e1804 = sourceDim_1;
                            let _e1806 = sourceDim_1;
                            _o_ratio_9 = (_e1804.y / _e1806.x);
                            let _e1814 = camDir;
                            let _e1817 = camDir;
                            let _e1820 = _o_ratio_9;
                            let _e1823 = camDir;
                            let _e1826 = camDir;
                            let _e1829 = _o_ratio_9;
                            if ((abs(_e1814.y) > (abs(_e1817.z) * _e1820)) && (abs(_e1823.y) > (abs(_e1826.x) * _e1829))) {
                                {
                                    let _e1833 = _o_X_4;
                                    let _e1834 = camDir;
                                    let _e1837 = camDir;
                                    _o_X_4 = (_e1833 + ((-(_e1834.x) / _e1837.y) * 0.5f));
                                    let _e1843 = _o_Y_4;
                                    let _e1844 = camDir;
                                    let _e1847 = camDir;
                                    _o_Y_4 = (_e1843 + ((-(_e1844.z) / _e1847.y) * 0.5f));
                                }
                            } else {
                                let _e1853 = camDir;
                                let _e1856 = camDir;
                                if (abs(_e1853.x) < abs(_e1856.z)) {
                                    {
                                        let _e1860 = _o_X_4;
                                        let _e1861 = camDir;
                                        let _e1863 = camDir;
                                        let _e1867 = _o_ratio_9;
                                        let _e1871 = camDir;
                                        _o_X_4 = (_e1860 + ((((_e1861.x / abs(_e1863.z)) * _e1867) * 0.5f) * -(sign(_e1871.z))));
                                        let _e1877 = _o_Y_4;
                                        let _e1878 = camDir;
                                        let _e1880 = camDir;
                                        _o_Y_4 = (_e1877 + ((_e1878.y / abs(_e1880.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1887 = _o_X_4;
                                        let _e1888 = camDir;
                                        let _e1890 = camDir;
                                        let _e1894 = _o_ratio_9;
                                        let _e1898 = camDir;
                                        _o_X_4 = (_e1887 + ((((_e1888.z / abs(_e1890.x)) * _e1894) * 0.5f) * -(sign(_e1898.x))));
                                        let _e1904 = _o_Y_4;
                                        let _e1905 = camDir;
                                        let _e1907 = camDir;
                                        _o_Y_4 = (_e1904 + ((_e1905.y / abs(_e1907.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1914 = _o_X_4;
                            let _e1915 = _o_Y_4;
                            let _e1920 = global.U[0];
                            let _e1923 = _o_X_4;
                            let _e1924 = _o_Y_4;
                            let _e1934 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1914, _e1915).x / _e1920.x), vec2<f32>(_e1923, _e1924).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1934;
                        }
                    } else {
                        {
                            let _e1935 = camDir;
                            let _e1940 = ((_e1935 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1940.x, _e1940.y, _e1940.z, 1f);
                        }
                    }
                }
            }
            let _e1946 = colorFog_1;
            if (_e1946.w != 0f) {
                let _e1950 = color;
                let _e1952 = colorFog_1;
                let _e1953 = _e1952.xyz;
                color.x = _e1953.x;
                color.y = _e1953.y;
                color.z = _e1953.z;
            } else {
                let _e1960 = col;
                color = _e1960;
            }
        }
    }
    let _e1961 = color;
    return clamp(_e1961, vec4(0f), vec4(1f));
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
