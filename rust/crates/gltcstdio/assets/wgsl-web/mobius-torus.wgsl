struct Params {
    U: array<vec4<f32>, 37>,
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

fn sdf(p: vec3<f32>, radius: f32, count: i32, roundness: f32, angle: f32, separation: f32) -> f32 {
    var p_1: vec3<f32>;
    var radius_1: f32;
    var count_1: i32;
    var roundness_1: f32;
    var angle_1: f32;
    var separation_1: f32;
    var R: f32 = 0.5f;
    var r: f32;
    var a: f32;
    var ang: f32;
    var ca: f32;
    var sa: f32;
    var rot: mat2x2<f32>;
    var q: vec2<f32>;
    var c1_: vec2<f32>;
    var d: vec2<f32>;

    p_1 = p;
    radius_1 = radius;
    count_1 = count;
    roundness_1 = roundness;
    angle_1 = angle;
    separation_1 = separation;
    let _e21 = R;
    let _e22 = radius_1;
    r = (_e21 * _e22);
    let _e25 = p_1;
    let _e27 = p_1;
    let _e30 = p_1;
    let _e32 = p_1;
    let _e37 = R;
    a = (sqrt(((_e25.x * _e27.x) + (_e30.y * _e32.y))) - _e37);
    let _e40 = angle_1;
    let _e41 = p_1;
    let _e43 = p_1;
    let _e48 = count_1;
    ang = (_e40 + ((atan2(_e41.y, _e43.x) * 0.5f) * (f32(_e48) - 1f)));
    let _e55 = ang;
    ca = cos(_e55);
    let _e58 = ang;
    sa = sin(_e58);
    let _e61 = ca;
    let _e62 = sa;
    let _e63 = sa;
    let _e64 = ca;
    rot = mat2x2<f32>(vec2<f32>(_e61, _e62), vec2<f32>(_e63, -(_e64)));
    let _e70 = rot;
    let _e71 = a;
    let _e72 = p_1;
    q = (_e70 * vec2<f32>(_e71, _e72.z));
    let _e77 = q;
    if (_e77.x < 0f) {
        let _e81 = q;
        q = -(_e81);
    }
    let _e83 = separation_1;
    c1_ = vec2<f32>(_e83, 0f);
    let _e87 = q;
    let _e88 = c1_;
    let _e91 = r;
    d = (abs((_e87 - _e88)) - vec2(_e91));
    let _e96 = d;
    let _e101 = d;
    let _e103 = d;
    let _e110 = roundness_1;
    return ((0.4f * (length(max(_e96, vec2(0f))) + min(max(_e101.x, _e103.y), 0f))) - _e110);
}

fn normal(p_2: vec3<f32>, radius_2: f32, count_2: i32, roundness_2: f32, angle_2: f32, separation_2: f32) -> vec3<f32> {
    var p_3: vec3<f32>;
    var radius_3: f32;
    var count_3: i32;
    var roundness_3: f32;
    var angle_3: f32;
    var separation_3: f32;
    var d_1: f32 = 0.0001f;
    var s: f32;

    p_3 = p_2;
    radius_3 = radius_2;
    count_3 = count_2;
    roundness_3 = roundness_2;
    angle_3 = angle_2;
    separation_3 = separation_2;
    let _e21 = p_3;
    let _e22 = radius_3;
    let _e23 = count_3;
    let _e24 = roundness_3;
    let _e25 = angle_3;
    let _e26 = separation_3;
    let _e27 = sdf(_e21, _e22, _e23, _e24, _e25, _e26);
    s = _e27;
    let _e29 = s;
    let _e30 = p_3;
    let _e32 = d_1;
    let _e34 = p_3;
    let _e36 = p_3;
    let _e39 = radius_3;
    let _e40 = count_3;
    let _e41 = roundness_3;
    let _e42 = angle_3;
    let _e43 = separation_3;
    let _e44 = sdf(vec3<f32>((_e30.x - _e32), _e34.y, _e36.z), _e39, _e40, _e41, _e42, _e43);
    let _e46 = d_1;
    let _e48 = s;
    let _e49 = p_3;
    let _e51 = p_3;
    let _e53 = d_1;
    let _e55 = p_3;
    let _e58 = radius_3;
    let _e59 = count_3;
    let _e60 = roundness_3;
    let _e61 = angle_3;
    let _e62 = separation_3;
    let _e63 = sdf(vec3<f32>(_e49.x, (_e51.y - _e53), _e55.z), _e58, _e59, _e60, _e61, _e62);
    let _e65 = d_1;
    let _e67 = s;
    let _e68 = p_3;
    let _e70 = p_3;
    let _e72 = p_3;
    let _e74 = d_1;
    let _e77 = radius_3;
    let _e78 = count_3;
    let _e79 = roundness_3;
    let _e80 = angle_3;
    let _e81 = separation_3;
    let _e82 = sdf(vec3<f32>(_e68.x, _e70.y, (_e72.z - _e74)), _e77, _e78, _e79, _e80, _e81);
    let _e84 = d_1;
    return normalize(vec3<f32>(((_e29 - _e44) / _e46), ((_e48 - _e63) / _e65), ((_e67 - _e82) / _e84)));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, side: f32, radius_4: f32, count_4: i32, roundness_4: f32, angle_4: f32, separation_4: f32) -> vec3<f32> {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var side_1: f32;
    var radius_5: f32;
    var count_5: i32;
    var roundness_5: f32;
    var angle_5: f32;
    var separation_5: f32;
    var d_2: f32;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var p_4: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    side_1 = side;
    radius_5 = radius_4;
    count_5 = count_4;
    roundness_5 = roundness_4;
    angle_5 = angle_4;
    separation_5 = separation_4;
    let _e23 = p0_1;
    let _e24 = radius_5;
    let _e25 = count_5;
    let _e26 = roundness_5;
    let _e27 = angle_5;
    let _e28 = separation_5;
    let _e29 = sdf(_e23, _e24, _e25, _e26, _e27, _e28);
    d_2 = _e29;
    let _e31 = d_2;
    s_1 = sign(_e31);
    loop {
        let _e38 = step;
        let _e41 = d_2;
        if !(((_e38 < 1000i) && (_e41 < 100f))) {
            break;
        }
        {
            let _e46 = totalD;
            let _e47 = d_2;
            let _e48 = side_1;
            totalD = (_e46 + (_e47 * _e48));
            let _e51 = p0_1;
            let _e52 = totalD;
            let _e53 = dir_1;
            p_4 = (_e51 + (_e52 * _e53));
            let _e57 = p_4;
            let _e58 = radius_5;
            let _e59 = count_5;
            let _e60 = roundness_5;
            let _e61 = angle_5;
            let _e62 = separation_5;
            let _e63 = sdf(_e57, _e58, _e59, _e60, _e61, _e62);
            d_2 = _e63;
            let _e64 = d_2;
            if (abs(_e64) < 0.0001f) {
                let _e68 = p_4;
                return _e68;
            }
            let _e69 = step;
            step = (_e69 + 1i);
        }
    }
    return vec3(100000000000000000000f);
}

fn rayMarcher(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, lightSourceTransform: mat4x4<f32>, bkgTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>, colorMaterial: vec4<f32>, refractionIndex: f32, fresnelStrength: f32, chromaticAberration: f32, colorFog: vec4<f32>, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, backgroundStyle: i32, radius_6: f32, count_6: i32, roundness_6: f32, angle_6: f32, separation_6: f32) -> vec4<f32> {
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
    var count_7: i32;
    var roundness_7: f32;
    var angle_7: f32;
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
    count_7 = count_6;
    roundness_7 = roundness_6;
    angle_7 = angle_6;
    separation_7 = separation_6;
    let _e56 = camera3DTransform_1;
    let _e57 = camera_2;
    camera_2 = (_e56 * vec4<f32>(_e57.x, _e57.y, _e57.z, 1f)).xyz;
    let _e68 = uv_3;
    let _e69 = camera_2;
    let _e70 = target_2;
    let _e72 = getRay(_e68, _e69, _e70, 1f);
    camDir = _e72;
    let _e74 = lightSourceTransform_1;
    lightPos = (_e74 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e83 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e83);
    let _e86 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e86[0].xyz, _e86[1].xyz, _e86[2].xyz);
    let _e97 = invModelTransform;
    let _e98 = camera_2;
    camera_2 = (_e97 * vec4<f32>(_e98.x, _e98.y, _e98.z, 1f)).xyz;
    let _e106 = uv_3;
    let _e108 = D;
    let _e110 = uv_3;
    let _e112 = D;
    dir_2 = normalize(vec3<f32>((_e106.x * _e108), (_e110.y * _e112), -1f));
    let _e119 = camera3DTransform_1;
    let _e129 = dir_2;
    dir_2 = (mat3x3<f32>(_e119[0].xyz, _e119[1].xyz, _e119[2].xyz) * _e129);
    let _e131 = invModelTransform;
    let _e141 = dir_2;
    camDir = normalize((mat3x3<f32>(_e131[0].xyz, _e131[1].xyz, _e131[2].xyz) * _e141));
    let _e156 = camera_2;
    let _e157 = camDir;
    let _e159 = radius_7;
    let _e160 = count_7;
    let _e161 = roundness_7;
    let _e162 = angle_7;
    let _e163 = separation_7;
    let _e164 = rayMarch(_e156, _e157, 1f, _e159, _e160, _e161, _e162, _e163);
    qIn = _e164;
    let _e166 = camDir;
    reflectDir = _e166;
    let _e171 = refractionIndex_1;
    ref_ = _e171;
    let _e173 = chromaticAberration_1;
    chromaticAbb = _e173;
    let _e179 = colorMaterial_1;
    let _e183 = colorMaterial_1;
    absorption = pow(mix(30f, 1000f, smoothstep(0.95f, 1f, _e179.w)), _e183.w);
    let _e187 = qIn;
    if (_e187.x != 100000000000000000000f) {
        {
            let _e191 = qIn;
            let _e192 = radius_7;
            let _e193 = count_7;
            let _e194 = roundness_7;
            let _e195 = angle_7;
            let _e196 = separation_7;
            let _e197 = normal(_e191, _e192, _e193, _e194, _e195, _e196);
            nIn = _e197;
            let _e199 = nIn;
            let _e200 = camDir;
            incidence = abs(dot(_e199, _e200));
            let _e205 = incidence;
            let _e208 = fresnelStrength_1;
            let _e215 = fresnelStrength_1;
            let _e220 = fresnelStrength_1;
            fresnel = ((pow((1f - _e205), (6f - (_e208 * 6f))) * smoothstep(0f, 0.025f, _e215)) * smoothstep(0f, 0.025f, _e220));
            let _e224 = camDir;
            let _e225 = nIn;
            reflectDir = reflect(_e224, _e225);
            let _e229 = colorMaterial_1;
            reflectivity = (vec3(1f) - _e229.xyz);
            let _e233 = reflectivity;
            reflectK = _e233;
            let _e234 = qIn;
            let _e235 = lightPos;
            lightDir = normalize((_e234 - _e235));
            let _e239 = fresnel;
            if (_e239 != 1f) {
                {
                    let _e244 = ref_;
                    let _e245 = ref_;
                    let _e248 = nIn;
                    let _e249 = camDir;
                    let _e251 = nIn;
                    let _e252 = camDir;
                    k = (1f - ((_e244 * _e245) * (1f - (dot(_e248, _e249) * dot(_e251, _e252)))));
                    let _e259 = k;
                    if (_e259 < 0f) {
                        refractDir = vec3(0f);
                    } else {
                        let _e264 = ref_;
                        let _e265 = camDir;
                        let _e267 = ref_;
                        let _e268 = nIn;
                        let _e269 = camDir;
                        let _e272 = k;
                        let _e275 = nIn;
                        refractDir = ((_e264 * _e265) - (((_e267 * dot(_e268, _e269)) + sqrt(_e272)) * _e275));
                    }
                    let _e278 = qIn;
                    let _e279 = nIn;
                    let _e283 = refractDir;
                    let _e286 = radius_7;
                    let _e287 = count_7;
                    let _e288 = roundness_7;
                    let _e289 = angle_7;
                    let _e290 = separation_7;
                    let _e291 = rayMarch((_e278 - (_e279 * 0.001f)), _e283, -1f, _e286, _e287, _e288, _e289, _e290);
                    qOut = _e291;
                    let _e293 = qOut;
                    let _e294 = radius_7;
                    let _e295 = count_7;
                    let _e296 = roundness_7;
                    let _e297 = angle_7;
                    let _e298 = separation_7;
                    let _e299 = normal(_e293, _e294, _e295, _e296, _e297, _e298);
                    n = -(_e299);
                    let _e302 = refractDir;
                    let _e303 = n;
                    let _e305 = ref_;
                    let _e307 = chromaticAbb;
                    rDir = refract(_e302, _e303, ((1f / _e305) - _e307));
                    let _e311 = rDir;
                    if (length(_e311) == 0f) {
                        let _e315 = refractDir;
                        let _e316 = n;
                        local = reflect(_e315, _e316);
                    } else {
                        let _e318 = rDir;
                        local = _e318;
                    }
                    let _e320 = local;
                    refractDirR = _e320;
                    let _e322 = refractDir;
                    let _e323 = n;
                    let _e325 = ref_;
                    gDir = refract(_e322, _e323, (1f / _e325));
                    let _e329 = gDir;
                    if (length(_e329) == 0f) {
                        let _e333 = refractDir;
                        let _e334 = n;
                        local_1 = reflect(_e333, _e334);
                    } else {
                        let _e336 = gDir;
                        local_1 = _e336;
                    }
                    let _e338 = local_1;
                    refractDirG = _e338;
                    let _e340 = refractDir;
                    let _e341 = n;
                    let _e343 = ref_;
                    let _e345 = chromaticAbb;
                    bDir = refract(_e340, _e341, ((1f / _e343) + _e345));
                    let _e349 = bDir;
                    if (length(_e349) == 0f) {
                        let _e353 = refractDir;
                        let _e354 = n;
                        local_2 = reflect(_e353, _e354);
                    } else {
                        let _e356 = bDir;
                        local_2 = _e356;
                    }
                    let _e358 = local_2;
                    refractDirB = _e358;
                    let _e363 = model3DTransform3_;
                    let _e364 = refractDirR;
                    refractDirR = (_e363 * _e364);
                    let _e366 = model3DTransform3_;
                    let _e367 = refractDirG;
                    refractDirG = (_e366 * _e367);
                    let _e369 = model3DTransform3_;
                    let _e370 = refractDirB;
                    refractDirB = (_e369 * _e370);
                    let _e372 = backgroundStyle_1;
                    if (_e372 == 0i) {
                        {
                            let _e375 = refractDirR;
                            _o_n = normalize(_e375);
                            let _e378 = _o_n;
                            let _e380 = _o_n;
                            _o_alpha = atan2(_e378.z, _e380.x);
                            let _e384 = _o_n;
                            _o_beta = asin(_e384.y);
                            let _e388 = sourceDim_1;
                            let _e390 = sourceDim_1;
                            _o_ratio = (_e388.x / _e390.y);
                            let _e398 = _o_alpha;
                            let _e404 = _o_nX;
                            let _e407 = _o_nY;
                            let _e408 = _o_beta;
                            let _e417 = global.U[0];
                            let _e420 = _o_alpha;
                            let _e426 = _o_nX;
                            let _e429 = _o_nY;
                            let _e430 = _o_beta;
                            let _e445 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e398) / 3.1415927f) * 0.5f) * _e404), (0.5f + ((_e407 * _e408) / 3.1415927f))).x / _e417.x), vec2<f32>((((-(_e420) / 3.1415927f) * 0.5f) * _e426), (0.5f + ((_e429 * _e430) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colR = _e445;
                        }
                    } else {
                        let _e446 = backgroundStyle_1;
                        if (_e446 == 1i) {
                            {
                                let _e449 = refractDirR;
                                let _e452 = refractDirR;
                                let _e455 = refractDirR;
                                let _e458 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e449.x) / _e452.z), (-(_e455.y) / _e458.z)) * 1f);
                                let _e465 = _o_pos;
                                let _e468 = _o_pos;
                                _o_m = max(abs(_e465.x), abs(_e468.y));
                                let _e475 = _o_m;
                                _o_darken = (4f / max(4f, _e475));
                                let _e479 = _o_pos;
                                let _e483 = global.U[0];
                                let _e486 = _o_pos;
                                let _e496 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e479.x / _e483.x), _e486.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e497 = _o_darken;
                                let _e498 = _o_darken;
                                let _e499 = _o_darken;
                                colR = (_e496 * vec4<f32>(_e497, _e498, _e499, 1f));
                            }
                        } else {
                            let _e503 = backgroundStyle_1;
                            if (_e503 == 2i) {
                                {
                                    let _e506 = sourceDim_1;
                                    let _e508 = sourceDim_1;
                                    _o_ratio_1 = (_e506.y / _e508.x);
                                    let _e516 = refractDirR;
                                    let _e519 = refractDirR;
                                    let _e522 = _o_ratio_1;
                                    let _e525 = refractDirR;
                                    let _e528 = refractDirR;
                                    let _e531 = _o_ratio_1;
                                    if ((abs(_e516.y) > (abs(_e519.z) * _e522)) && (abs(_e525.y) > (abs(_e528.x) * _e531))) {
                                        {
                                            let _e535 = _o_X;
                                            let _e536 = refractDirR;
                                            let _e539 = refractDirR;
                                            _o_X = (_e535 + ((-(_e536.x) / _e539.y) * 0.5f));
                                            let _e545 = _o_Y;
                                            let _e546 = refractDirR;
                                            let _e549 = refractDirR;
                                            _o_Y = (_e545 + ((-(_e546.z) / _e549.y) * 0.5f));
                                        }
                                    } else {
                                        let _e555 = refractDirR;
                                        let _e558 = refractDirR;
                                        if (abs(_e555.x) < abs(_e558.z)) {
                                            {
                                                let _e562 = _o_X;
                                                let _e563 = refractDirR;
                                                let _e565 = refractDirR;
                                                let _e569 = _o_ratio_1;
                                                let _e573 = refractDirR;
                                                _o_X = (_e562 + ((((_e563.x / abs(_e565.z)) * _e569) * 0.5f) * -(sign(_e573.z))));
                                                let _e579 = _o_Y;
                                                let _e580 = refractDirR;
                                                let _e582 = refractDirR;
                                                _o_Y = (_e579 + ((_e580.y / abs(_e582.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e589 = _o_X;
                                                let _e590 = refractDirR;
                                                let _e592 = refractDirR;
                                                let _e596 = _o_ratio_1;
                                                let _e600 = refractDirR;
                                                _o_X = (_e589 + ((((_e590.z / abs(_e592.x)) * _e596) * 0.5f) * -(sign(_e600.x))));
                                                let _e606 = _o_Y;
                                                let _e607 = refractDirR;
                                                let _e609 = refractDirR;
                                                _o_Y = (_e606 + ((_e607.y / abs(_e609.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e616 = _o_X;
                                    let _e617 = _o_Y;
                                    let _e622 = global.U[0];
                                    let _e625 = _o_X;
                                    let _e626 = _o_Y;
                                    let _e637 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e616, _e617).x / _e622.x), vec2<f32>(_e625, _e626).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colR = _e637;
                                }
                            } else {
                                {
                                    let _e638 = refractDirR;
                                    let _e643 = ((_e638 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e643.x, _e643.y, _e643.z, 1f);
                                }
                            }
                        }
                    }
                    let _e649 = backgroundStyle_1;
                    if (_e649 == 0i) {
                        {
                            let _e652 = refractDirG;
                            _o_n_1 = normalize(_e652);
                            let _e655 = _o_n_1;
                            let _e657 = _o_n_1;
                            _o_alpha_1 = atan2(_e655.z, _e657.x);
                            let _e661 = _o_n_1;
                            _o_beta_1 = asin(_e661.y);
                            let _e665 = sourceDim_1;
                            let _e667 = sourceDim_1;
                            _o_ratio_2 = (_e665.x / _e667.y);
                            let _e675 = _o_alpha_1;
                            let _e681 = _o_nX_1;
                            let _e684 = _o_nY_1;
                            let _e685 = _o_beta_1;
                            let _e694 = global.U[0];
                            let _e697 = _o_alpha_1;
                            let _e703 = _o_nX_1;
                            let _e706 = _o_nY_1;
                            let _e707 = _o_beta_1;
                            let _e722 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e675) / 3.1415927f) * 0.5f) * _e681), (0.5f + ((_e684 * _e685) / 3.1415927f))).x / _e694.x), vec2<f32>((((-(_e697) / 3.1415927f) * 0.5f) * _e703), (0.5f + ((_e706 * _e707) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colG = _e722;
                        }
                    } else {
                        let _e723 = backgroundStyle_1;
                        if (_e723 == 1i) {
                            {
                                let _e726 = refractDirG;
                                let _e729 = refractDirG;
                                let _e732 = refractDirG;
                                let _e735 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e726.x) / _e729.z), (-(_e732.y) / _e735.z)) * 1f);
                                let _e742 = _o_pos_1;
                                let _e745 = _o_pos_1;
                                _o_m_1 = max(abs(_e742.x), abs(_e745.y));
                                let _e752 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e752));
                                let _e756 = _o_pos_1;
                                let _e760 = global.U[0];
                                let _e763 = _o_pos_1;
                                let _e773 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e756.x / _e760.x), _e763.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e774 = _o_darken_1;
                                let _e775 = _o_darken_1;
                                let _e776 = _o_darken_1;
                                colG = (_e773 * vec4<f32>(_e774, _e775, _e776, 1f));
                            }
                        } else {
                            let _e780 = backgroundStyle_1;
                            if (_e780 == 2i) {
                                {
                                    let _e783 = sourceDim_1;
                                    let _e785 = sourceDim_1;
                                    _o_ratio_3 = (_e783.y / _e785.x);
                                    let _e793 = refractDirG;
                                    let _e796 = refractDirG;
                                    let _e799 = _o_ratio_3;
                                    let _e802 = refractDirG;
                                    let _e805 = refractDirG;
                                    let _e808 = _o_ratio_3;
                                    if ((abs(_e793.y) > (abs(_e796.z) * _e799)) && (abs(_e802.y) > (abs(_e805.x) * _e808))) {
                                        {
                                            let _e812 = _o_X_1;
                                            let _e813 = refractDirG;
                                            let _e816 = refractDirG;
                                            _o_X_1 = (_e812 + ((-(_e813.x) / _e816.y) * 0.5f));
                                            let _e822 = _o_Y_1;
                                            let _e823 = refractDirG;
                                            let _e826 = refractDirG;
                                            _o_Y_1 = (_e822 + ((-(_e823.z) / _e826.y) * 0.5f));
                                        }
                                    } else {
                                        let _e832 = refractDirG;
                                        let _e835 = refractDirG;
                                        if (abs(_e832.x) < abs(_e835.z)) {
                                            {
                                                let _e839 = _o_X_1;
                                                let _e840 = refractDirG;
                                                let _e842 = refractDirG;
                                                let _e846 = _o_ratio_3;
                                                let _e850 = refractDirG;
                                                _o_X_1 = (_e839 + ((((_e840.x / abs(_e842.z)) * _e846) * 0.5f) * -(sign(_e850.z))));
                                                let _e856 = _o_Y_1;
                                                let _e857 = refractDirG;
                                                let _e859 = refractDirG;
                                                _o_Y_1 = (_e856 + ((_e857.y / abs(_e859.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e866 = _o_X_1;
                                                let _e867 = refractDirG;
                                                let _e869 = refractDirG;
                                                let _e873 = _o_ratio_3;
                                                let _e877 = refractDirG;
                                                _o_X_1 = (_e866 + ((((_e867.z / abs(_e869.x)) * _e873) * 0.5f) * -(sign(_e877.x))));
                                                let _e883 = _o_Y_1;
                                                let _e884 = refractDirG;
                                                let _e886 = refractDirG;
                                                _o_Y_1 = (_e883 + ((_e884.y / abs(_e886.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e893 = _o_X_1;
                                    let _e894 = _o_Y_1;
                                    let _e899 = global.U[0];
                                    let _e902 = _o_X_1;
                                    let _e903 = _o_Y_1;
                                    let _e914 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e893, _e894).x / _e899.x), vec2<f32>(_e902, _e903).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colG = _e914;
                                }
                            } else {
                                {
                                    let _e915 = refractDirG;
                                    let _e920 = ((_e915 * 0.5f) + vec3(0.5f));
                                    colG = vec4<f32>(_e920.x, _e920.y, _e920.z, 1f);
                                }
                            }
                        }
                    }
                    let _e926 = backgroundStyle_1;
                    if (_e926 == 0i) {
                        {
                            let _e929 = refractDirB;
                            _o_n_2 = normalize(_e929);
                            let _e932 = _o_n_2;
                            let _e934 = _o_n_2;
                            _o_alpha_2 = atan2(_e932.z, _e934.x);
                            let _e938 = _o_n_2;
                            _o_beta_2 = asin(_e938.y);
                            let _e942 = sourceDim_1;
                            let _e944 = sourceDim_1;
                            _o_ratio_4 = (_e942.x / _e944.y);
                            let _e952 = _o_alpha_2;
                            let _e958 = _o_nX_2;
                            let _e961 = _o_nY_2;
                            let _e962 = _o_beta_2;
                            let _e971 = global.U[0];
                            let _e974 = _o_alpha_2;
                            let _e980 = _o_nX_2;
                            let _e983 = _o_nY_2;
                            let _e984 = _o_beta_2;
                            let _e999 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e952) / 3.1415927f) * 0.5f) * _e958), (0.5f + ((_e961 * _e962) / 3.1415927f))).x / _e971.x), vec2<f32>((((-(_e974) / 3.1415927f) * 0.5f) * _e980), (0.5f + ((_e983 * _e984) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            colB = _e999;
                        }
                    } else {
                        let _e1000 = backgroundStyle_1;
                        if (_e1000 == 1i) {
                            {
                                let _e1003 = refractDirB;
                                let _e1006 = refractDirB;
                                let _e1009 = refractDirB;
                                let _e1012 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e1003.x) / _e1006.z), (-(_e1009.y) / _e1012.z)) * 1f);
                                let _e1019 = _o_pos_2;
                                let _e1022 = _o_pos_2;
                                _o_m_2 = max(abs(_e1019.x), abs(_e1022.y));
                                let _e1029 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1029));
                                let _e1033 = _o_pos_2;
                                let _e1037 = global.U[0];
                                let _e1040 = _o_pos_2;
                                let _e1050 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1033.x / _e1037.x), _e1040.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1051 = _o_darken_2;
                                let _e1052 = _o_darken_2;
                                let _e1053 = _o_darken_2;
                                colB = (_e1050 * vec4<f32>(_e1051, _e1052, _e1053, 1f));
                            }
                        } else {
                            let _e1057 = backgroundStyle_1;
                            if (_e1057 == 2i) {
                                {
                                    let _e1060 = sourceDim_1;
                                    let _e1062 = sourceDim_1;
                                    _o_ratio_5 = (_e1060.y / _e1062.x);
                                    let _e1070 = refractDirB;
                                    let _e1073 = refractDirB;
                                    let _e1076 = _o_ratio_5;
                                    let _e1079 = refractDirB;
                                    let _e1082 = refractDirB;
                                    let _e1085 = _o_ratio_5;
                                    if ((abs(_e1070.y) > (abs(_e1073.z) * _e1076)) && (abs(_e1079.y) > (abs(_e1082.x) * _e1085))) {
                                        {
                                            let _e1089 = _o_X_2;
                                            let _e1090 = refractDirB;
                                            let _e1093 = refractDirB;
                                            _o_X_2 = (_e1089 + ((-(_e1090.x) / _e1093.y) * 0.5f));
                                            let _e1099 = _o_Y_2;
                                            let _e1100 = refractDirB;
                                            let _e1103 = refractDirB;
                                            _o_Y_2 = (_e1099 + ((-(_e1100.z) / _e1103.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1109 = refractDirB;
                                        let _e1112 = refractDirB;
                                        if (abs(_e1109.x) < abs(_e1112.z)) {
                                            {
                                                let _e1116 = _o_X_2;
                                                let _e1117 = refractDirB;
                                                let _e1119 = refractDirB;
                                                let _e1123 = _o_ratio_5;
                                                let _e1127 = refractDirB;
                                                _o_X_2 = (_e1116 + ((((_e1117.x / abs(_e1119.z)) * _e1123) * 0.5f) * -(sign(_e1127.z))));
                                                let _e1133 = _o_Y_2;
                                                let _e1134 = refractDirB;
                                                let _e1136 = refractDirB;
                                                _o_Y_2 = (_e1133 + ((_e1134.y / abs(_e1136.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1143 = _o_X_2;
                                                let _e1144 = refractDirB;
                                                let _e1146 = refractDirB;
                                                let _e1150 = _o_ratio_5;
                                                let _e1154 = refractDirB;
                                                _o_X_2 = (_e1143 + ((((_e1144.z / abs(_e1146.x)) * _e1150) * 0.5f) * -(sign(_e1154.x))));
                                                let _e1160 = _o_Y_2;
                                                let _e1161 = refractDirB;
                                                let _e1163 = refractDirB;
                                                _o_Y_2 = (_e1160 + ((_e1161.y / abs(_e1163.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1170 = _o_X_2;
                                    let _e1171 = _o_Y_2;
                                    let _e1176 = global.U[0];
                                    let _e1179 = _o_X_2;
                                    let _e1180 = _o_Y_2;
                                    let _e1191 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1170, _e1171).x / _e1176.x), vec2<f32>(_e1179, _e1180).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    colB = _e1191;
                                }
                            } else {
                                {
                                    let _e1192 = refractDirB;
                                    let _e1197 = ((_e1192 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1197.x, _e1197.y, _e1197.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1203 = colR;
                    let _e1205 = colG;
                    let _e1207 = colB;
                    col = vec4<f32>(_e1203.x, _e1205.y, _e1207.z, 1f);
                    let _e1213 = absorption;
                    let _e1214 = qIn;
                    let _e1215 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1213 * length((_e1214 - _e1215)))));
                    let _e1223 = absorbed;
                    let _e1226 = colorMaterial_1;
                    absorbed = mix(0f, _e1223, smoothstep(0f, 0.1f, _e1226.w));
                    let _e1230 = color;
                    let _e1232 = color;
                    let _e1234 = colorMaterial_1;
                    let _e1237 = fresnel;
                    let _e1241 = absorbed;
                    let _e1244 = col;
                    let _e1247 = (_e1232.xyz + (((_e1234.xyz * (1f - _e1237)) * (1f - _e1241)) * _e1244.xyz));
                    color.x = _e1247.x;
                    color.y = _e1247.y;
                    color.z = _e1247.z;
                    let _e1254 = color;
                    let _e1256 = color;
                    let _e1258 = absorbed;
                    let _e1259 = colorMaterial_1;
                    let _e1262 = ambientColor_1;
                    let _e1265 = nIn;
                    let _e1266 = lightDir;
                    let _e1269 = sourceColor_1;
                    let _e1274 = (_e1256.xyz + ((_e1258 * _e1259.xyz) * (_e1262.xyz + (max(0f, dot(_e1265, _e1266)) * _e1269.xyz))));
                    color.x = _e1274.x;
                    color.y = _e1274.y;
                    color.z = _e1274.z;
                }
            }
            let _e1281 = fresnel;
            let _e1284 = specular_1;
            if ((_e1281 != 0f) || (_e1284 != 0f)) {
                {
                    let _e1288 = reflectDir;
                    origReflectDir = _e1288;
                    let _e1290 = qIn;
                    let _e1291 = nIn;
                    let _e1295 = reflectDir;
                    let _e1297 = radius_7;
                    let _e1298 = count_7;
                    let _e1299 = roundness_7;
                    let _e1300 = angle_7;
                    let _e1301 = separation_7;
                    let _e1302 = rayMarch((_e1290 + (_e1291 * 0.001f)), _e1295, 1f, _e1297, _e1298, _e1299, _e1300, _e1301);
                    qR = _e1302;
                    let _e1304 = qR;
                    if (_e1304.x != 100000000000000000000f) {
                        {
                            let _e1308 = qR;
                            let _e1309 = radius_7;
                            let _e1310 = count_7;
                            let _e1311 = roundness_7;
                            let _e1312 = angle_7;
                            let _e1313 = separation_7;
                            let _e1314 = normal(_e1308, _e1309, _e1310, _e1311, _e1312, _e1313);
                            n_1 = _e1314;
                            let _e1316 = reflectDir;
                            let _e1317 = n_1;
                            reflectDir = reflect(_e1316, _e1317);
                        }
                    }
                    let _e1319 = model3DTransform3_;
                    let _e1320 = reflectDir;
                    reflectDir = (_e1319 * _e1320);
                    let _e1322 = backgroundStyle_1;
                    if (_e1322 == 0i) {
                        {
                            let _e1325 = reflectDir;
                            _o_n_3 = normalize(_e1325);
                            let _e1328 = _o_n_3;
                            let _e1330 = _o_n_3;
                            _o_alpha_3 = atan2(_e1328.z, _e1330.x);
                            let _e1334 = _o_n_3;
                            _o_beta_3 = asin(_e1334.y);
                            let _e1338 = sourceDim_1;
                            let _e1340 = sourceDim_1;
                            _o_ratio_6 = (_e1338.x / _e1340.y);
                            let _e1348 = _o_alpha_3;
                            let _e1354 = _o_nX_3;
                            let _e1357 = _o_nY_3;
                            let _e1358 = _o_beta_3;
                            let _e1367 = global.U[0];
                            let _e1370 = _o_alpha_3;
                            let _e1376 = _o_nX_3;
                            let _e1379 = _o_nY_3;
                            let _e1380 = _o_beta_3;
                            let _e1395 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1348) / 3.1415927f) * 0.5f) * _e1354), (0.5f + ((_e1357 * _e1358) / 3.1415927f))).x / _e1367.x), vec2<f32>((((-(_e1370) / 3.1415927f) * 0.5f) * _e1376), (0.5f + ((_e1379 * _e1380) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1395;
                        }
                    } else {
                        let _e1396 = backgroundStyle_1;
                        if (_e1396 == 1i) {
                            {
                                let _e1399 = reflectDir;
                                let _e1402 = reflectDir;
                                let _e1405 = reflectDir;
                                let _e1408 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1399.x) / _e1402.z), (-(_e1405.y) / _e1408.z)) * 1f);
                                let _e1415 = _o_pos_3;
                                let _e1418 = _o_pos_3;
                                _o_m_3 = max(abs(_e1415.x), abs(_e1418.y));
                                let _e1425 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1425));
                                let _e1429 = _o_pos_3;
                                let _e1433 = global.U[0];
                                let _e1436 = _o_pos_3;
                                let _e1446 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1429.x / _e1433.x), _e1436.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e1447 = _o_darken_3;
                                let _e1448 = _o_darken_3;
                                let _e1449 = _o_darken_3;
                                col = (_e1446 * vec4<f32>(_e1447, _e1448, _e1449, 1f));
                            }
                        } else {
                            let _e1453 = backgroundStyle_1;
                            if (_e1453 == 2i) {
                                {
                                    let _e1456 = sourceDim_1;
                                    let _e1458 = sourceDim_1;
                                    _o_ratio_7 = (_e1456.y / _e1458.x);
                                    let _e1466 = reflectDir;
                                    let _e1469 = reflectDir;
                                    let _e1472 = _o_ratio_7;
                                    let _e1475 = reflectDir;
                                    let _e1478 = reflectDir;
                                    let _e1481 = _o_ratio_7;
                                    if ((abs(_e1466.y) > (abs(_e1469.z) * _e1472)) && (abs(_e1475.y) > (abs(_e1478.x) * _e1481))) {
                                        {
                                            let _e1485 = _o_X_3;
                                            let _e1486 = reflectDir;
                                            let _e1489 = reflectDir;
                                            _o_X_3 = (_e1485 + ((-(_e1486.x) / _e1489.y) * 0.5f));
                                            let _e1495 = _o_Y_3;
                                            let _e1496 = reflectDir;
                                            let _e1499 = reflectDir;
                                            _o_Y_3 = (_e1495 + ((-(_e1496.z) / _e1499.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1505 = reflectDir;
                                        let _e1508 = reflectDir;
                                        if (abs(_e1505.x) < abs(_e1508.z)) {
                                            {
                                                let _e1512 = _o_X_3;
                                                let _e1513 = reflectDir;
                                                let _e1515 = reflectDir;
                                                let _e1519 = _o_ratio_7;
                                                let _e1523 = reflectDir;
                                                _o_X_3 = (_e1512 + ((((_e1513.x / abs(_e1515.z)) * _e1519) * 0.5f) * -(sign(_e1523.z))));
                                                let _e1529 = _o_Y_3;
                                                let _e1530 = reflectDir;
                                                let _e1532 = reflectDir;
                                                _o_Y_3 = (_e1529 + ((_e1530.y / abs(_e1532.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1539 = _o_X_3;
                                                let _e1540 = reflectDir;
                                                let _e1542 = reflectDir;
                                                let _e1546 = _o_ratio_7;
                                                let _e1550 = reflectDir;
                                                _o_X_3 = (_e1539 + ((((_e1540.z / abs(_e1542.x)) * _e1546) * 0.5f) * -(sign(_e1550.x))));
                                                let _e1556 = _o_Y_3;
                                                let _e1557 = reflectDir;
                                                let _e1559 = reflectDir;
                                                _o_Y_3 = (_e1556 + ((_e1557.y / abs(_e1559.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1566 = _o_X_3;
                                    let _e1567 = _o_Y_3;
                                    let _e1572 = global.U[0];
                                    let _e1575 = _o_X_3;
                                    let _e1576 = _o_Y_3;
                                    let _e1587 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1566, _e1567).x / _e1572.x), vec2<f32>(_e1575, _e1576).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e1587;
                                }
                            } else {
                                {
                                    let _e1588 = reflectDir;
                                    let _e1593 = ((_e1588 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1593.x, _e1593.y, _e1593.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1599 = color;
                    let _e1601 = color;
                    let _e1603 = fresnel;
                    let _e1604 = col;
                    let _e1607 = (_e1601.xyz + (_e1603 * _e1604.xyz));
                    color.x = _e1607.x;
                    color.y = _e1607.y;
                    color.z = _e1607.z;
                    let _e1615 = specular_1;
                    let _e1618 = lightDir;
                    let _e1619 = origReflectDir;
                    kSpec = ((10f * _e1615) * pow(max(0f, dot(_e1618, _e1619)), 9f));
                    let _e1626 = color;
                    let _e1628 = color;
                    let _e1630 = sourceColor_1;
                    let _e1632 = kSpec;
                    let _e1634 = (_e1628.xyz + (_e1630.xyz * _e1632));
                    color.x = _e1634.x;
                    color.y = _e1634.y;
                    color.z = _e1634.z;
                }
            }
            let _e1641 = colorFog_1;
            if (_e1641.w != 0f) {
                {
                    let _e1645 = camera_2;
                    let _e1646 = qIn;
                    dist = length((_e1645 - _e1646));
                    let _e1652 = colorFog_1;
                    let _e1655 = dist;
                    kFog = (1f - pow(0.4f, (_e1652.w * max(0f, (_e1655 - 0.1f)))));
                    let _e1663 = color;
                    let _e1665 = color;
                    let _e1667 = colorFog_1;
                    let _e1669 = kFog;
                    let _e1671 = mix(_e1665.xyz, _e1667.xyz, vec3(_e1669));
                    color.x = _e1671.x;
                    color.y = _e1671.y;
                    color.z = _e1671.z;
                }
            }
        }
    } else {
        {
            let _e1678 = bkgTransform_1;
            let _e1688 = model3DTransform3_;
            let _e1690 = camDir;
            camDir = ((mat3x3<f32>(_e1678[0].xyz, _e1678[1].xyz, _e1678[2].xyz) * _e1688) * _e1690);
            let _e1692 = backgroundStyle_1;
            if (_e1692 == 0i) {
                {
                    let _e1695 = camDir;
                    _o_n_4 = normalize(_e1695);
                    let _e1698 = _o_n_4;
                    let _e1700 = _o_n_4;
                    _o_alpha_4 = atan2(_e1698.z, _e1700.x);
                    let _e1704 = _o_n_4;
                    _o_beta_4 = asin(_e1704.y);
                    let _e1708 = sourceDim_1;
                    let _e1710 = sourceDim_1;
                    _o_ratio_8 = (_e1708.x / _e1710.y);
                    let _e1718 = _o_alpha_4;
                    let _e1724 = _o_nX_4;
                    let _e1727 = _o_nY_4;
                    let _e1728 = _o_beta_4;
                    let _e1737 = global.U[0];
                    let _e1740 = _o_alpha_4;
                    let _e1746 = _o_nX_4;
                    let _e1749 = _o_nY_4;
                    let _e1750 = _o_beta_4;
                    let _e1765 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1718) / 3.1415927f) * 0.5f) * _e1724), (0.5f + ((_e1727 * _e1728) / 3.1415927f))).x / _e1737.x), vec2<f32>((((-(_e1740) / 3.1415927f) * 0.5f) * _e1746), (0.5f + ((_e1749 * _e1750) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col = _e1765;
                }
            } else {
                let _e1766 = backgroundStyle_1;
                if (_e1766 == 1i) {
                    {
                        let _e1769 = camDir;
                        let _e1772 = camDir;
                        let _e1775 = camDir;
                        let _e1778 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1769.x) / _e1772.z), (-(_e1775.y) / _e1778.z)) * 1f);
                        let _e1785 = _o_pos_4;
                        let _e1788 = _o_pos_4;
                        _o_m_4 = max(abs(_e1785.x), abs(_e1788.y));
                        let _e1795 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1795));
                        let _e1799 = _o_pos_4;
                        let _e1803 = global.U[0];
                        let _e1806 = _o_pos_4;
                        let _e1816 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1799.x / _e1803.x), _e1806.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1817 = _o_darken_4;
                        let _e1818 = _o_darken_4;
                        let _e1819 = _o_darken_4;
                        col = (_e1816 * vec4<f32>(_e1817, _e1818, _e1819, 1f));
                    }
                } else {
                    let _e1823 = backgroundStyle_1;
                    if (_e1823 == 2i) {
                        {
                            let _e1826 = sourceDim_1;
                            let _e1828 = sourceDim_1;
                            _o_ratio_9 = (_e1826.y / _e1828.x);
                            let _e1836 = camDir;
                            let _e1839 = camDir;
                            let _e1842 = _o_ratio_9;
                            let _e1845 = camDir;
                            let _e1848 = camDir;
                            let _e1851 = _o_ratio_9;
                            if ((abs(_e1836.y) > (abs(_e1839.z) * _e1842)) && (abs(_e1845.y) > (abs(_e1848.x) * _e1851))) {
                                {
                                    let _e1855 = _o_X_4;
                                    let _e1856 = camDir;
                                    let _e1859 = camDir;
                                    _o_X_4 = (_e1855 + ((-(_e1856.x) / _e1859.y) * 0.5f));
                                    let _e1865 = _o_Y_4;
                                    let _e1866 = camDir;
                                    let _e1869 = camDir;
                                    _o_Y_4 = (_e1865 + ((-(_e1866.z) / _e1869.y) * 0.5f));
                                }
                            } else {
                                let _e1875 = camDir;
                                let _e1878 = camDir;
                                if (abs(_e1875.x) < abs(_e1878.z)) {
                                    {
                                        let _e1882 = _o_X_4;
                                        let _e1883 = camDir;
                                        let _e1885 = camDir;
                                        let _e1889 = _o_ratio_9;
                                        let _e1893 = camDir;
                                        _o_X_4 = (_e1882 + ((((_e1883.x / abs(_e1885.z)) * _e1889) * 0.5f) * -(sign(_e1893.z))));
                                        let _e1899 = _o_Y_4;
                                        let _e1900 = camDir;
                                        let _e1902 = camDir;
                                        _o_Y_4 = (_e1899 + ((_e1900.y / abs(_e1902.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1909 = _o_X_4;
                                        let _e1910 = camDir;
                                        let _e1912 = camDir;
                                        let _e1916 = _o_ratio_9;
                                        let _e1920 = camDir;
                                        _o_X_4 = (_e1909 + ((((_e1910.z / abs(_e1912.x)) * _e1916) * 0.5f) * -(sign(_e1920.x))));
                                        let _e1926 = _o_Y_4;
                                        let _e1927 = camDir;
                                        let _e1929 = camDir;
                                        _o_Y_4 = (_e1926 + ((_e1927.y / abs(_e1929.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1936 = _o_X_4;
                            let _e1937 = _o_Y_4;
                            let _e1942 = global.U[0];
                            let _e1945 = _o_X_4;
                            let _e1946 = _o_Y_4;
                            let _e1957 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e1936, _e1937).x / _e1942.x), vec2<f32>(_e1945, _e1946).y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e1957;
                        }
                    } else {
                        {
                            let _e1958 = camDir;
                            let _e1963 = ((_e1958 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1963.x, _e1963.y, _e1963.z, 1f);
                        }
                    }
                }
            }
            let _e1969 = colorFog_1;
            if (_e1969.w != 0f) {
                let _e1973 = color;
                let _e1975 = colorFog_1;
                let _e1976 = _e1975.xyz;
                color.x = _e1976.x;
                color.y = _e1976.y;
                color.z = _e1976.z;
            } else {
                let _e1983 = col;
                color = _e1983;
            }
        }
    }
    let _e1984 = color;
    return clamp(_e1984, vec4(0f), vec4(1f));
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
    let _e245 = global.U[34];
    let _e249 = global.U[35];
    let _e253 = global.U[36];
    let _e255 = rayMarcher((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), mat4x4<f32>(vec4<f32>(_e67.x, _e67.y, _e67.z, _e67.w), vec4<f32>(_e70.x, _e70.y, _e70.z, _e70.w), vec4<f32>(_e73.x, _e73.y, _e73.z, _e73.w), vec4<f32>(_e76.x, _e76.y, _e76.z, _e76.w)), _e100.xy, mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)), mat4x4<f32>(vec4<f32>(_e170.x, _e170.y, _e170.z, _e170.w), vec4<f32>(_e173.x, _e173.y, _e173.z, _e173.w), vec4<f32>(_e176.x, _e176.y, _e176.z, _e176.w), vec4<f32>(_e179.x, _e179.y, _e179.z, _e179.w)), _e203, _e206.x, _e210.x, _e214.x, _e218, _e221, _e224, _e227.x, i32(_e231.x), _e236.x, i32(_e240.x), _e245.x, _e249.x, _e253.x);
    fragColor = _e255;
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
