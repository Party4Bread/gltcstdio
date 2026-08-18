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
                            let _e444 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e398) / 3.1415927f) * 0.5f) * _e404), (0.5f + ((_e407 * _e408) / 3.1415927f))).x / _e417.x), vec2<f32>((((-(_e420) / 3.1415927f) * 0.5f) * _e426), (0.5f + ((_e429 * _e430) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colR = _e444;
                        }
                    } else {
                        let _e445 = backgroundStyle_1;
                        if (_e445 == 1i) {
                            {
                                let _e448 = refractDirR;
                                let _e451 = refractDirR;
                                let _e454 = refractDirR;
                                let _e457 = refractDirR;
                                _o_pos = (vec2<f32>((-(_e448.x) / _e451.z), (-(_e454.y) / _e457.z)) * 1f);
                                let _e464 = _o_pos;
                                let _e467 = _o_pos;
                                _o_m = max(abs(_e464.x), abs(_e467.y));
                                let _e474 = _o_m;
                                _o_darken = (4f / max(4f, _e474));
                                let _e478 = _o_pos;
                                let _e482 = global.U[0];
                                let _e485 = _o_pos;
                                let _e494 = textureSample(t_source, samp, ((vec2<f32>((_e478.x / _e482.x), _e485.y) / vec2(2f)) + vec2(0.5f)));
                                let _e495 = _o_darken;
                                let _e496 = _o_darken;
                                let _e497 = _o_darken;
                                colR = (_e494 * vec4<f32>(_e495, _e496, _e497, 1f));
                            }
                        } else {
                            let _e501 = backgroundStyle_1;
                            if (_e501 == 2i) {
                                {
                                    let _e504 = sourceDim_1;
                                    let _e506 = sourceDim_1;
                                    _o_ratio_1 = (_e504.y / _e506.x);
                                    let _e514 = refractDirR;
                                    let _e517 = refractDirR;
                                    let _e520 = _o_ratio_1;
                                    let _e523 = refractDirR;
                                    let _e526 = refractDirR;
                                    let _e529 = _o_ratio_1;
                                    if ((abs(_e514.y) > (abs(_e517.z) * _e520)) && (abs(_e523.y) > (abs(_e526.x) * _e529))) {
                                        {
                                            let _e533 = _o_X;
                                            let _e534 = refractDirR;
                                            let _e537 = refractDirR;
                                            _o_X = (_e533 + ((-(_e534.x) / _e537.y) * 0.5f));
                                            let _e543 = _o_Y;
                                            let _e544 = refractDirR;
                                            let _e547 = refractDirR;
                                            _o_Y = (_e543 + ((-(_e544.z) / _e547.y) * 0.5f));
                                        }
                                    } else {
                                        let _e553 = refractDirR;
                                        let _e556 = refractDirR;
                                        if (abs(_e553.x) < abs(_e556.z)) {
                                            {
                                                let _e560 = _o_X;
                                                let _e561 = refractDirR;
                                                let _e563 = refractDirR;
                                                let _e567 = _o_ratio_1;
                                                let _e571 = refractDirR;
                                                _o_X = (_e560 + ((((_e561.x / abs(_e563.z)) * _e567) * 0.5f) * -(sign(_e571.z))));
                                                let _e577 = _o_Y;
                                                let _e578 = refractDirR;
                                                let _e580 = refractDirR;
                                                _o_Y = (_e577 + ((_e578.y / abs(_e580.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e587 = _o_X;
                                                let _e588 = refractDirR;
                                                let _e590 = refractDirR;
                                                let _e594 = _o_ratio_1;
                                                let _e598 = refractDirR;
                                                _o_X = (_e587 + ((((_e588.z / abs(_e590.x)) * _e594) * 0.5f) * -(sign(_e598.x))));
                                                let _e604 = _o_Y;
                                                let _e605 = refractDirR;
                                                let _e607 = refractDirR;
                                                _o_Y = (_e604 + ((_e605.y / abs(_e607.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e614 = _o_X;
                                    let _e615 = _o_Y;
                                    let _e620 = global.U[0];
                                    let _e623 = _o_X;
                                    let _e624 = _o_Y;
                                    let _e634 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e614, _e615).x / _e620.x), vec2<f32>(_e623, _e624).y) / vec2(2f)) + vec2(0.5f)));
                                    colR = _e634;
                                }
                            } else {
                                {
                                    let _e635 = refractDirR;
                                    let _e640 = ((_e635 * 0.5f) + vec3(0.5f));
                                    colR = vec4<f32>(_e640.x, _e640.y, _e640.z, 1f);
                                }
                            }
                        }
                    }
                    let _e646 = backgroundStyle_1;
                    if (_e646 == 0i) {
                        {
                            let _e649 = refractDirG;
                            _o_n_1 = normalize(_e649);
                            let _e652 = _o_n_1;
                            let _e654 = _o_n_1;
                            _o_alpha_1 = atan2(_e652.z, _e654.x);
                            let _e658 = _o_n_1;
                            _o_beta_1 = asin(_e658.y);
                            let _e662 = sourceDim_1;
                            let _e664 = sourceDim_1;
                            _o_ratio_2 = (_e662.x / _e664.y);
                            let _e672 = _o_alpha_1;
                            let _e678 = _o_nX_1;
                            let _e681 = _o_nY_1;
                            let _e682 = _o_beta_1;
                            let _e691 = global.U[0];
                            let _e694 = _o_alpha_1;
                            let _e700 = _o_nX_1;
                            let _e703 = _o_nY_1;
                            let _e704 = _o_beta_1;
                            let _e718 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e672) / 3.1415927f) * 0.5f) * _e678), (0.5f + ((_e681 * _e682) / 3.1415927f))).x / _e691.x), vec2<f32>((((-(_e694) / 3.1415927f) * 0.5f) * _e700), (0.5f + ((_e703 * _e704) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colG = _e718;
                        }
                    } else {
                        let _e719 = backgroundStyle_1;
                        if (_e719 == 1i) {
                            {
                                let _e722 = refractDirG;
                                let _e725 = refractDirG;
                                let _e728 = refractDirG;
                                let _e731 = refractDirG;
                                _o_pos_1 = (vec2<f32>((-(_e722.x) / _e725.z), (-(_e728.y) / _e731.z)) * 1f);
                                let _e738 = _o_pos_1;
                                let _e741 = _o_pos_1;
                                _o_m_1 = max(abs(_e738.x), abs(_e741.y));
                                let _e748 = _o_m_1;
                                _o_darken_1 = (4f / max(4f, _e748));
                                let _e752 = _o_pos_1;
                                let _e756 = global.U[0];
                                let _e759 = _o_pos_1;
                                let _e768 = textureSample(t_source, samp, ((vec2<f32>((_e752.x / _e756.x), _e759.y) / vec2(2f)) + vec2(0.5f)));
                                let _e769 = _o_darken_1;
                                let _e770 = _o_darken_1;
                                let _e771 = _o_darken_1;
                                colG = (_e768 * vec4<f32>(_e769, _e770, _e771, 1f));
                            }
                        } else {
                            let _e775 = backgroundStyle_1;
                            if (_e775 == 2i) {
                                {
                                    let _e778 = sourceDim_1;
                                    let _e780 = sourceDim_1;
                                    _o_ratio_3 = (_e778.y / _e780.x);
                                    let _e788 = refractDirG;
                                    let _e791 = refractDirG;
                                    let _e794 = _o_ratio_3;
                                    let _e797 = refractDirG;
                                    let _e800 = refractDirG;
                                    let _e803 = _o_ratio_3;
                                    if ((abs(_e788.y) > (abs(_e791.z) * _e794)) && (abs(_e797.y) > (abs(_e800.x) * _e803))) {
                                        {
                                            let _e807 = _o_X_1;
                                            let _e808 = refractDirG;
                                            let _e811 = refractDirG;
                                            _o_X_1 = (_e807 + ((-(_e808.x) / _e811.y) * 0.5f));
                                            let _e817 = _o_Y_1;
                                            let _e818 = refractDirG;
                                            let _e821 = refractDirG;
                                            _o_Y_1 = (_e817 + ((-(_e818.z) / _e821.y) * 0.5f));
                                        }
                                    } else {
                                        let _e827 = refractDirG;
                                        let _e830 = refractDirG;
                                        if (abs(_e827.x) < abs(_e830.z)) {
                                            {
                                                let _e834 = _o_X_1;
                                                let _e835 = refractDirG;
                                                let _e837 = refractDirG;
                                                let _e841 = _o_ratio_3;
                                                let _e845 = refractDirG;
                                                _o_X_1 = (_e834 + ((((_e835.x / abs(_e837.z)) * _e841) * 0.5f) * -(sign(_e845.z))));
                                                let _e851 = _o_Y_1;
                                                let _e852 = refractDirG;
                                                let _e854 = refractDirG;
                                                _o_Y_1 = (_e851 + ((_e852.y / abs(_e854.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e861 = _o_X_1;
                                                let _e862 = refractDirG;
                                                let _e864 = refractDirG;
                                                let _e868 = _o_ratio_3;
                                                let _e872 = refractDirG;
                                                _o_X_1 = (_e861 + ((((_e862.z / abs(_e864.x)) * _e868) * 0.5f) * -(sign(_e872.x))));
                                                let _e878 = _o_Y_1;
                                                let _e879 = refractDirG;
                                                let _e881 = refractDirG;
                                                _o_Y_1 = (_e878 + ((_e879.y / abs(_e881.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e888 = _o_X_1;
                                    let _e889 = _o_Y_1;
                                    let _e894 = global.U[0];
                                    let _e897 = _o_X_1;
                                    let _e898 = _o_Y_1;
                                    let _e908 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e888, _e889).x / _e894.x), vec2<f32>(_e897, _e898).y) / vec2(2f)) + vec2(0.5f)));
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
                            let _e992 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e946) / 3.1415927f) * 0.5f) * _e952), (0.5f + ((_e955 * _e956) / 3.1415927f))).x / _e965.x), vec2<f32>((((-(_e968) / 3.1415927f) * 0.5f) * _e974), (0.5f + ((_e977 * _e978) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            colB = _e992;
                        }
                    } else {
                        let _e993 = backgroundStyle_1;
                        if (_e993 == 1i) {
                            {
                                let _e996 = refractDirB;
                                let _e999 = refractDirB;
                                let _e1002 = refractDirB;
                                let _e1005 = refractDirB;
                                _o_pos_2 = (vec2<f32>((-(_e996.x) / _e999.z), (-(_e1002.y) / _e1005.z)) * 1f);
                                let _e1012 = _o_pos_2;
                                let _e1015 = _o_pos_2;
                                _o_m_2 = max(abs(_e1012.x), abs(_e1015.y));
                                let _e1022 = _o_m_2;
                                _o_darken_2 = (4f / max(4f, _e1022));
                                let _e1026 = _o_pos_2;
                                let _e1030 = global.U[0];
                                let _e1033 = _o_pos_2;
                                let _e1042 = textureSample(t_source, samp, ((vec2<f32>((_e1026.x / _e1030.x), _e1033.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1043 = _o_darken_2;
                                let _e1044 = _o_darken_2;
                                let _e1045 = _o_darken_2;
                                colB = (_e1042 * vec4<f32>(_e1043, _e1044, _e1045, 1f));
                            }
                        } else {
                            let _e1049 = backgroundStyle_1;
                            if (_e1049 == 2i) {
                                {
                                    let _e1052 = sourceDim_1;
                                    let _e1054 = sourceDim_1;
                                    _o_ratio_5 = (_e1052.y / _e1054.x);
                                    let _e1062 = refractDirB;
                                    let _e1065 = refractDirB;
                                    let _e1068 = _o_ratio_5;
                                    let _e1071 = refractDirB;
                                    let _e1074 = refractDirB;
                                    let _e1077 = _o_ratio_5;
                                    if ((abs(_e1062.y) > (abs(_e1065.z) * _e1068)) && (abs(_e1071.y) > (abs(_e1074.x) * _e1077))) {
                                        {
                                            let _e1081 = _o_X_2;
                                            let _e1082 = refractDirB;
                                            let _e1085 = refractDirB;
                                            _o_X_2 = (_e1081 + ((-(_e1082.x) / _e1085.y) * 0.5f));
                                            let _e1091 = _o_Y_2;
                                            let _e1092 = refractDirB;
                                            let _e1095 = refractDirB;
                                            _o_Y_2 = (_e1091 + ((-(_e1092.z) / _e1095.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1101 = refractDirB;
                                        let _e1104 = refractDirB;
                                        if (abs(_e1101.x) < abs(_e1104.z)) {
                                            {
                                                let _e1108 = _o_X_2;
                                                let _e1109 = refractDirB;
                                                let _e1111 = refractDirB;
                                                let _e1115 = _o_ratio_5;
                                                let _e1119 = refractDirB;
                                                _o_X_2 = (_e1108 + ((((_e1109.x / abs(_e1111.z)) * _e1115) * 0.5f) * -(sign(_e1119.z))));
                                                let _e1125 = _o_Y_2;
                                                let _e1126 = refractDirB;
                                                let _e1128 = refractDirB;
                                                _o_Y_2 = (_e1125 + ((_e1126.y / abs(_e1128.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1135 = _o_X_2;
                                                let _e1136 = refractDirB;
                                                let _e1138 = refractDirB;
                                                let _e1142 = _o_ratio_5;
                                                let _e1146 = refractDirB;
                                                _o_X_2 = (_e1135 + ((((_e1136.z / abs(_e1138.x)) * _e1142) * 0.5f) * -(sign(_e1146.x))));
                                                let _e1152 = _o_Y_2;
                                                let _e1153 = refractDirB;
                                                let _e1155 = refractDirB;
                                                _o_Y_2 = (_e1152 + ((_e1153.y / abs(_e1155.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1162 = _o_X_2;
                                    let _e1163 = _o_Y_2;
                                    let _e1168 = global.U[0];
                                    let _e1171 = _o_X_2;
                                    let _e1172 = _o_Y_2;
                                    let _e1182 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1162, _e1163).x / _e1168.x), vec2<f32>(_e1171, _e1172).y) / vec2(2f)) + vec2(0.5f)));
                                    colB = _e1182;
                                }
                            } else {
                                {
                                    let _e1183 = refractDirB;
                                    let _e1188 = ((_e1183 * 0.5f) + vec3(0.5f));
                                    colB = vec4<f32>(_e1188.x, _e1188.y, _e1188.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1194 = colR;
                    let _e1196 = colG;
                    let _e1198 = colB;
                    col = vec4<f32>(_e1194.x, _e1196.y, _e1198.z, 1f);
                    let _e1204 = absorption;
                    let _e1205 = qIn;
                    let _e1206 = qOut;
                    absorbed = (1f - pow(0.5f, (_e1204 * length((_e1205 - _e1206)))));
                    let _e1214 = absorbed;
                    let _e1217 = colorMaterial_1;
                    absorbed = mix(0f, _e1214, smoothstep(0f, 0.1f, _e1217.w));
                    let _e1221 = color;
                    let _e1223 = color;
                    let _e1225 = colorMaterial_1;
                    let _e1228 = fresnel;
                    let _e1232 = absorbed;
                    let _e1235 = col;
                    let _e1238 = (_e1223.xyz + (((_e1225.xyz * (1f - _e1228)) * (1f - _e1232)) * _e1235.xyz));
                    color.x = _e1238.x;
                    color.y = _e1238.y;
                    color.z = _e1238.z;
                    let _e1245 = color;
                    let _e1247 = color;
                    let _e1249 = absorbed;
                    let _e1250 = colorMaterial_1;
                    let _e1253 = ambientColor_1;
                    let _e1256 = nIn;
                    let _e1257 = lightDir;
                    let _e1260 = sourceColor_1;
                    let _e1265 = (_e1247.xyz + ((_e1249 * _e1250.xyz) * (_e1253.xyz + (max(0f, dot(_e1256, _e1257)) * _e1260.xyz))));
                    color.x = _e1265.x;
                    color.y = _e1265.y;
                    color.z = _e1265.z;
                }
            }
            let _e1272 = fresnel;
            let _e1275 = specular_1;
            if ((_e1272 != 0f) || (_e1275 != 0f)) {
                {
                    let _e1279 = reflectDir;
                    origReflectDir = _e1279;
                    let _e1281 = qIn;
                    let _e1282 = nIn;
                    let _e1286 = reflectDir;
                    let _e1288 = radius_7;
                    let _e1289 = count_7;
                    let _e1290 = roundness_7;
                    let _e1291 = angle_7;
                    let _e1292 = separation_7;
                    let _e1293 = rayMarch((_e1281 + (_e1282 * 0.001f)), _e1286, 1f, _e1288, _e1289, _e1290, _e1291, _e1292);
                    qR = _e1293;
                    let _e1295 = qR;
                    if (_e1295.x != 100000000000000000000f) {
                        {
                            let _e1299 = qR;
                            let _e1300 = radius_7;
                            let _e1301 = count_7;
                            let _e1302 = roundness_7;
                            let _e1303 = angle_7;
                            let _e1304 = separation_7;
                            let _e1305 = normal(_e1299, _e1300, _e1301, _e1302, _e1303, _e1304);
                            n_1 = _e1305;
                            let _e1307 = reflectDir;
                            let _e1308 = n_1;
                            reflectDir = reflect(_e1307, _e1308);
                        }
                    }
                    let _e1310 = model3DTransform3_;
                    let _e1311 = reflectDir;
                    reflectDir = (_e1310 * _e1311);
                    let _e1313 = backgroundStyle_1;
                    if (_e1313 == 0i) {
                        {
                            let _e1316 = reflectDir;
                            _o_n_3 = normalize(_e1316);
                            let _e1319 = _o_n_3;
                            let _e1321 = _o_n_3;
                            _o_alpha_3 = atan2(_e1319.z, _e1321.x);
                            let _e1325 = _o_n_3;
                            _o_beta_3 = asin(_e1325.y);
                            let _e1329 = sourceDim_1;
                            let _e1331 = sourceDim_1;
                            _o_ratio_6 = (_e1329.x / _e1331.y);
                            let _e1339 = _o_alpha_3;
                            let _e1345 = _o_nX_3;
                            let _e1348 = _o_nY_3;
                            let _e1349 = _o_beta_3;
                            let _e1358 = global.U[0];
                            let _e1361 = _o_alpha_3;
                            let _e1367 = _o_nX_3;
                            let _e1370 = _o_nY_3;
                            let _e1371 = _o_beta_3;
                            let _e1385 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1339) / 3.1415927f) * 0.5f) * _e1345), (0.5f + ((_e1348 * _e1349) / 3.1415927f))).x / _e1358.x), vec2<f32>((((-(_e1361) / 3.1415927f) * 0.5f) * _e1367), (0.5f + ((_e1370 * _e1371) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1385;
                        }
                    } else {
                        let _e1386 = backgroundStyle_1;
                        if (_e1386 == 1i) {
                            {
                                let _e1389 = reflectDir;
                                let _e1392 = reflectDir;
                                let _e1395 = reflectDir;
                                let _e1398 = reflectDir;
                                _o_pos_3 = (vec2<f32>((-(_e1389.x) / _e1392.z), (-(_e1395.y) / _e1398.z)) * 1f);
                                let _e1405 = _o_pos_3;
                                let _e1408 = _o_pos_3;
                                _o_m_3 = max(abs(_e1405.x), abs(_e1408.y));
                                let _e1415 = _o_m_3;
                                _o_darken_3 = (4f / max(4f, _e1415));
                                let _e1419 = _o_pos_3;
                                let _e1423 = global.U[0];
                                let _e1426 = _o_pos_3;
                                let _e1435 = textureSample(t_source, samp, ((vec2<f32>((_e1419.x / _e1423.x), _e1426.y) / vec2(2f)) + vec2(0.5f)));
                                let _e1436 = _o_darken_3;
                                let _e1437 = _o_darken_3;
                                let _e1438 = _o_darken_3;
                                col = (_e1435 * vec4<f32>(_e1436, _e1437, _e1438, 1f));
                            }
                        } else {
                            let _e1442 = backgroundStyle_1;
                            if (_e1442 == 2i) {
                                {
                                    let _e1445 = sourceDim_1;
                                    let _e1447 = sourceDim_1;
                                    _o_ratio_7 = (_e1445.y / _e1447.x);
                                    let _e1455 = reflectDir;
                                    let _e1458 = reflectDir;
                                    let _e1461 = _o_ratio_7;
                                    let _e1464 = reflectDir;
                                    let _e1467 = reflectDir;
                                    let _e1470 = _o_ratio_7;
                                    if ((abs(_e1455.y) > (abs(_e1458.z) * _e1461)) && (abs(_e1464.y) > (abs(_e1467.x) * _e1470))) {
                                        {
                                            let _e1474 = _o_X_3;
                                            let _e1475 = reflectDir;
                                            let _e1478 = reflectDir;
                                            _o_X_3 = (_e1474 + ((-(_e1475.x) / _e1478.y) * 0.5f));
                                            let _e1484 = _o_Y_3;
                                            let _e1485 = reflectDir;
                                            let _e1488 = reflectDir;
                                            _o_Y_3 = (_e1484 + ((-(_e1485.z) / _e1488.y) * 0.5f));
                                        }
                                    } else {
                                        let _e1494 = reflectDir;
                                        let _e1497 = reflectDir;
                                        if (abs(_e1494.x) < abs(_e1497.z)) {
                                            {
                                                let _e1501 = _o_X_3;
                                                let _e1502 = reflectDir;
                                                let _e1504 = reflectDir;
                                                let _e1508 = _o_ratio_7;
                                                let _e1512 = reflectDir;
                                                _o_X_3 = (_e1501 + ((((_e1502.x / abs(_e1504.z)) * _e1508) * 0.5f) * -(sign(_e1512.z))));
                                                let _e1518 = _o_Y_3;
                                                let _e1519 = reflectDir;
                                                let _e1521 = reflectDir;
                                                _o_Y_3 = (_e1518 + ((_e1519.y / abs(_e1521.z)) * 0.5f));
                                            }
                                        } else {
                                            {
                                                let _e1528 = _o_X_3;
                                                let _e1529 = reflectDir;
                                                let _e1531 = reflectDir;
                                                let _e1535 = _o_ratio_7;
                                                let _e1539 = reflectDir;
                                                _o_X_3 = (_e1528 + ((((_e1529.z / abs(_e1531.x)) * _e1535) * 0.5f) * -(sign(_e1539.x))));
                                                let _e1545 = _o_Y_3;
                                                let _e1546 = reflectDir;
                                                let _e1548 = reflectDir;
                                                _o_Y_3 = (_e1545 + ((_e1546.y / abs(_e1548.x)) * 0.5f));
                                            }
                                        }
                                    }
                                    let _e1555 = _o_X_3;
                                    let _e1556 = _o_Y_3;
                                    let _e1561 = global.U[0];
                                    let _e1564 = _o_X_3;
                                    let _e1565 = _o_Y_3;
                                    let _e1575 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1555, _e1556).x / _e1561.x), vec2<f32>(_e1564, _e1565).y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e1575;
                                }
                            } else {
                                {
                                    let _e1576 = reflectDir;
                                    let _e1581 = ((_e1576 * 0.5f) + vec3(0.5f));
                                    col = vec4<f32>(_e1581.x, _e1581.y, _e1581.z, 1f);
                                }
                            }
                        }
                    }
                    let _e1587 = color;
                    let _e1589 = color;
                    let _e1591 = fresnel;
                    let _e1592 = col;
                    let _e1595 = (_e1589.xyz + (_e1591 * _e1592.xyz));
                    color.x = _e1595.x;
                    color.y = _e1595.y;
                    color.z = _e1595.z;
                    let _e1603 = specular_1;
                    let _e1606 = lightDir;
                    let _e1607 = origReflectDir;
                    kSpec = ((10f * _e1603) * pow(max(0f, dot(_e1606, _e1607)), 9f));
                    let _e1614 = color;
                    let _e1616 = color;
                    let _e1618 = sourceColor_1;
                    let _e1620 = kSpec;
                    let _e1622 = (_e1616.xyz + (_e1618.xyz * _e1620));
                    color.x = _e1622.x;
                    color.y = _e1622.y;
                    color.z = _e1622.z;
                }
            }
            let _e1629 = colorFog_1;
            if (_e1629.w != 0f) {
                {
                    let _e1633 = camera_2;
                    let _e1634 = qIn;
                    dist = length((_e1633 - _e1634));
                    let _e1640 = colorFog_1;
                    let _e1643 = dist;
                    kFog = (1f - pow(0.4f, (_e1640.w * max(0f, (_e1643 - 0.1f)))));
                    let _e1651 = color;
                    let _e1653 = color;
                    let _e1655 = colorFog_1;
                    let _e1657 = kFog;
                    let _e1659 = mix(_e1653.xyz, _e1655.xyz, vec3(_e1657));
                    color.x = _e1659.x;
                    color.y = _e1659.y;
                    color.z = _e1659.z;
                }
            }
        }
    } else {
        {
            let _e1666 = bkgTransform_1;
            let _e1676 = model3DTransform3_;
            let _e1678 = camDir;
            camDir = ((mat3x3<f32>(_e1666[0].xyz, _e1666[1].xyz, _e1666[2].xyz) * _e1676) * _e1678);
            let _e1680 = backgroundStyle_1;
            if (_e1680 == 0i) {
                {
                    let _e1683 = camDir;
                    _o_n_4 = normalize(_e1683);
                    let _e1686 = _o_n_4;
                    let _e1688 = _o_n_4;
                    _o_alpha_4 = atan2(_e1686.z, _e1688.x);
                    let _e1692 = _o_n_4;
                    _o_beta_4 = asin(_e1692.y);
                    let _e1696 = sourceDim_1;
                    let _e1698 = sourceDim_1;
                    _o_ratio_8 = (_e1696.x / _e1698.y);
                    let _e1706 = _o_alpha_4;
                    let _e1712 = _o_nX_4;
                    let _e1715 = _o_nY_4;
                    let _e1716 = _o_beta_4;
                    let _e1725 = global.U[0];
                    let _e1728 = _o_alpha_4;
                    let _e1734 = _o_nX_4;
                    let _e1737 = _o_nY_4;
                    let _e1738 = _o_beta_4;
                    let _e1752 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((((-(_e1706) / 3.1415927f) * 0.5f) * _e1712), (0.5f + ((_e1715 * _e1716) / 3.1415927f))).x / _e1725.x), vec2<f32>((((-(_e1728) / 3.1415927f) * 0.5f) * _e1734), (0.5f + ((_e1737 * _e1738) / 3.1415927f))).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e1752;
                }
            } else {
                let _e1753 = backgroundStyle_1;
                if (_e1753 == 1i) {
                    {
                        let _e1756 = camDir;
                        let _e1759 = camDir;
                        let _e1762 = camDir;
                        let _e1765 = camDir;
                        _o_pos_4 = (vec2<f32>((-(_e1756.x) / _e1759.z), (-(_e1762.y) / _e1765.z)) * 1f);
                        let _e1772 = _o_pos_4;
                        let _e1775 = _o_pos_4;
                        _o_m_4 = max(abs(_e1772.x), abs(_e1775.y));
                        let _e1782 = _o_m_4;
                        _o_darken_4 = (4f / max(4f, _e1782));
                        let _e1786 = _o_pos_4;
                        let _e1790 = global.U[0];
                        let _e1793 = _o_pos_4;
                        let _e1802 = textureSample(t_source, samp, ((vec2<f32>((_e1786.x / _e1790.x), _e1793.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1803 = _o_darken_4;
                        let _e1804 = _o_darken_4;
                        let _e1805 = _o_darken_4;
                        col = (_e1802 * vec4<f32>(_e1803, _e1804, _e1805, 1f));
                    }
                } else {
                    let _e1809 = backgroundStyle_1;
                    if (_e1809 == 2i) {
                        {
                            let _e1812 = sourceDim_1;
                            let _e1814 = sourceDim_1;
                            _o_ratio_9 = (_e1812.y / _e1814.x);
                            let _e1822 = camDir;
                            let _e1825 = camDir;
                            let _e1828 = _o_ratio_9;
                            let _e1831 = camDir;
                            let _e1834 = camDir;
                            let _e1837 = _o_ratio_9;
                            if ((abs(_e1822.y) > (abs(_e1825.z) * _e1828)) && (abs(_e1831.y) > (abs(_e1834.x) * _e1837))) {
                                {
                                    let _e1841 = _o_X_4;
                                    let _e1842 = camDir;
                                    let _e1845 = camDir;
                                    _o_X_4 = (_e1841 + ((-(_e1842.x) / _e1845.y) * 0.5f));
                                    let _e1851 = _o_Y_4;
                                    let _e1852 = camDir;
                                    let _e1855 = camDir;
                                    _o_Y_4 = (_e1851 + ((-(_e1852.z) / _e1855.y) * 0.5f));
                                }
                            } else {
                                let _e1861 = camDir;
                                let _e1864 = camDir;
                                if (abs(_e1861.x) < abs(_e1864.z)) {
                                    {
                                        let _e1868 = _o_X_4;
                                        let _e1869 = camDir;
                                        let _e1871 = camDir;
                                        let _e1875 = _o_ratio_9;
                                        let _e1879 = camDir;
                                        _o_X_4 = (_e1868 + ((((_e1869.x / abs(_e1871.z)) * _e1875) * 0.5f) * -(sign(_e1879.z))));
                                        let _e1885 = _o_Y_4;
                                        let _e1886 = camDir;
                                        let _e1888 = camDir;
                                        _o_Y_4 = (_e1885 + ((_e1886.y / abs(_e1888.z)) * 0.5f));
                                    }
                                } else {
                                    {
                                        let _e1895 = _o_X_4;
                                        let _e1896 = camDir;
                                        let _e1898 = camDir;
                                        let _e1902 = _o_ratio_9;
                                        let _e1906 = camDir;
                                        _o_X_4 = (_e1895 + ((((_e1896.z / abs(_e1898.x)) * _e1902) * 0.5f) * -(sign(_e1906.x))));
                                        let _e1912 = _o_Y_4;
                                        let _e1913 = camDir;
                                        let _e1915 = camDir;
                                        _o_Y_4 = (_e1912 + ((_e1913.y / abs(_e1915.x)) * 0.5f));
                                    }
                                }
                            }
                            let _e1922 = _o_X_4;
                            let _e1923 = _o_Y_4;
                            let _e1928 = global.U[0];
                            let _e1931 = _o_X_4;
                            let _e1932 = _o_Y_4;
                            let _e1942 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e1922, _e1923).x / _e1928.x), vec2<f32>(_e1931, _e1932).y) / vec2(2f)) + vec2(0.5f)));
                            col = _e1942;
                        }
                    } else {
                        {
                            let _e1943 = camDir;
                            let _e1948 = ((_e1943 * 0.5f) + vec3(0.5f));
                            col = vec4<f32>(_e1948.x, _e1948.y, _e1948.z, 1f);
                        }
                    }
                }
            }
            let _e1954 = colorFog_1;
            if (_e1954.w != 0f) {
                let _e1958 = color;
                let _e1960 = colorFog_1;
                let _e1961 = _e1960.xyz;
                color.x = _e1961.x;
                color.y = _e1961.y;
                color.z = _e1961.z;
            } else {
                let _e1968 = col;
                color = _e1968;
            }
        }
    }
    let _e1969 = color;
    return clamp(_e1969, vec4(0f), vec4(1f));
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
