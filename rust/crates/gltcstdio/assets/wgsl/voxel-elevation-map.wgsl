struct Params {
    U: array<vec4<f32>, 20>,
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
var t_sourceBkg: texture_2d<f32>;
@group(0) @binding(4) 
var t_sourceElevation: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e11 = c_1;
    let _e13 = vec2(2f);
    return (vec2(1f) - abs(((_e11 - (floor((_e11 / _e13)) * _e13)) - vec2(1f))));
}

fn cubeIntersection(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var kOut: f32 = 100000000000000000000f;
    var kIn: f32 = 0f;
    var k1_: f32;
    var k2_: f32;
    var k1_1: f32;
    var k2_1: f32;
    var k1_2: f32;
    var k2_2: f32;
    var local: f32;
    var k: f32;
    var inters: vec3<f32>;

    center_1 = center;
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e16 = origin_1;
    let _e17 = center_1;
    relOrigin = (_e16 - _e17);
    let _e24 = dir_1;
    if (_e24.x != 0f) {
        {
            let _e28 = relOrigin;
            let _e30 = radius_1;
            let _e33 = dir_1;
            k1_ = (-((_e28.x - _e30)) / _e33.x);
            let _e37 = relOrigin;
            let _e39 = radius_1;
            let _e42 = dir_1;
            k2_ = (-((_e37.x + _e39)) / _e42.x);
            let _e46 = kIn;
            let _e47 = k1_;
            let _e48 = k2_;
            kIn = max(_e46, min(_e47, _e48));
            let _e51 = kOut;
            let _e52 = k1_;
            let _e53 = k2_;
            kOut = min(_e51, max(_e52, _e53));
        }
    } else {
        let _e56 = relOrigin;
        let _e59 = radius_1;
        if (abs(_e56.x) > _e59) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e65 = dir_1;
    if (_e65.y != 0f) {
        {
            let _e69 = relOrigin;
            let _e71 = radius_1;
            let _e74 = dir_1;
            k1_1 = (-((_e69.y - _e71)) / _e74.y);
            let _e78 = relOrigin;
            let _e80 = radius_1;
            let _e83 = dir_1;
            k2_1 = (-((_e78.y + _e80)) / _e83.y);
            let _e87 = kIn;
            let _e88 = k1_1;
            let _e89 = k2_1;
            kIn = max(_e87, min(_e88, _e89));
            let _e92 = kOut;
            let _e93 = k1_1;
            let _e94 = k2_1;
            kOut = min(_e92, max(_e93, _e94));
        }
    } else {
        let _e97 = relOrigin;
        let _e100 = radius_1;
        if (abs(_e97.y) > _e100) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e106 = dir_1;
    if (_e106.z != 0f) {
        {
            let _e110 = relOrigin;
            let _e112 = radius_1;
            let _e115 = dir_1;
            k1_2 = (-((_e110.z - _e112)) / _e115.z);
            let _e119 = relOrigin;
            let _e121 = radius_1;
            let _e124 = dir_1;
            k2_2 = (-((_e119.z + _e121)) / _e124.z);
            let _e128 = kIn;
            let _e129 = k1_2;
            let _e130 = k2_2;
            kIn = max(_e128, min(_e129, _e130));
            let _e133 = kOut;
            let _e134 = k1_2;
            let _e135 = k2_2;
            kOut = min(_e133, max(_e134, _e135));
        }
    } else {
        let _e138 = relOrigin;
        let _e141 = radius_1;
        if (abs(_e138.z) > _e141) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e147 = kIn;
    if (_e147 > 0f) {
        let _e150 = kIn;
        local = _e150;
    } else {
        let _e151 = kOut;
        local = _e151;
    }
    let _e153 = local;
    k = _e153;
    let _e155 = k;
    let _e158 = kOut;
    let _e159 = kIn;
    if ((_e155 <= 0f) || (_e158 < _e159)) {
        return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
    }
    let _e166 = origin_1;
    let _e167 = k;
    let _e168 = dir_1;
    inters = (_e166 + (_e167 * _e168));
    let _e172 = inters;
    return _e172;
}

fn getCubeNormal(center_2: vec3<f32>, intersection: vec3<f32>) -> vec3<f32> {
    var center_3: vec3<f32>;
    var intersection_1: vec3<f32>;
    var d: vec3<f32>;

    center_3 = center_2;
    intersection_1 = intersection;
    let _e12 = intersection_1;
    let _e13 = center_3;
    d = (_e12 - _e13);
    let _e16 = d;
    let _e19 = d;
    let _e23 = d;
    let _e26 = d;
    if ((abs(_e16.x) > abs(_e19.y)) && (abs(_e23.x) > abs(_e26.z))) {
        {
            let _e31 = d;
            return vec3<f32>(sign(_e31.x), 0f, 0f);
        }
    } else {
        let _e37 = d;
        let _e40 = d;
        if (abs(_e37.y) > abs(_e40.z)) {
            {
                let _e44 = d;
                return vec3(sign(_e44.y));
            }
        } else {
            {
                let _e48 = d;
                return vec3(sign(_e48.z));
            }
        }
    }
}

fn height(intensity: f32, color: vec4<f32>) -> f32 {
    var intensity_1: f32;
    var color_1: vec4<f32>;

    intensity_1 = intensity;
    color_1 = color;
    let _e12 = intensity_1;
    let _e15 = color_1;
    let _e17 = color_1;
    let _e20 = color_1;
    return ((_e12 * 0.04f) * ((((_e15.x + _e17.y) + _e20.z) / 3f) - 0.5f));
}

fn trailIntersection(center_4: vec3<f32>, radius_2: f32, extraTrail: f32, origin_2: vec3<f32>, dir_2: vec3<f32>) -> vec3<f32> {
    var center_5: vec3<f32>;
    var radius_3: f32;
    var extraTrail_1: f32;
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var relOrigin_1: vec3<f32>;
    var kOut_1: f32 = 100000000000000000000f;
    var kIn_1: f32 = 0f;
    var k1_3: f32;
    var k2_3: f32;
    var k1_4: f32;
    var k2_4: f32;
    var k1_5: f32;
    var k2_5: f32;
    var local_1: f32;
    var k_1: f32;
    var inters_1: vec3<f32>;

    center_5 = center_4;
    radius_3 = radius_2;
    extraTrail_1 = extraTrail;
    origin_3 = origin_2;
    dir_3 = dir_2;
    let _e18 = origin_3;
    let _e19 = center_5;
    relOrigin_1 = (_e18 - _e19);
    let _e26 = dir_3;
    if (_e26.x != 0f) {
        {
            let _e30 = relOrigin_1;
            let _e32 = radius_3;
            let _e35 = dir_3;
            k1_3 = (-((_e30.x - _e32)) / _e35.x);
            let _e39 = relOrigin_1;
            let _e41 = radius_3;
            let _e44 = dir_3;
            k2_3 = (-((_e39.x + _e41)) / _e44.x);
            let _e48 = kIn_1;
            let _e49 = k1_3;
            let _e50 = k2_3;
            kIn_1 = max(_e48, min(_e49, _e50));
            let _e53 = kOut_1;
            let _e54 = k1_3;
            let _e55 = k2_3;
            kOut_1 = min(_e53, max(_e54, _e55));
        }
    } else {
        let _e58 = relOrigin_1;
        let _e61 = radius_3;
        if (abs(_e58.x) > _e61) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e67 = dir_3;
    if (_e67.y != 0f) {
        {
            let _e71 = relOrigin_1;
            let _e73 = radius_3;
            let _e76 = dir_3;
            k1_4 = (-((_e71.y - _e73)) / _e76.y);
            let _e80 = relOrigin_1;
            let _e82 = radius_3;
            let _e85 = dir_3;
            k2_4 = (-((_e80.y + _e82)) / _e85.y);
            let _e89 = kIn_1;
            let _e90 = k1_4;
            let _e91 = k2_4;
            kIn_1 = max(_e89, min(_e90, _e91));
            let _e94 = kOut_1;
            let _e95 = k1_4;
            let _e96 = k2_4;
            kOut_1 = min(_e94, max(_e95, _e96));
        }
    } else {
        let _e99 = relOrigin_1;
        let _e102 = radius_3;
        if (abs(_e99.y) > _e102) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e108 = dir_3;
    if (_e108.z != 0f) {
        {
            let _e112 = relOrigin_1;
            let _e114 = radius_3;
            let _e117 = dir_3;
            k1_5 = (-((_e112.z + _e114)) / _e117.z);
            let _e121 = relOrigin_1;
            let _e123 = radius_3;
            let _e124 = extraTrail_1;
            let _e128 = dir_3;
            k2_5 = (-((_e121.z + (_e123 + _e124))) / _e128.z);
            let _e132 = kIn_1;
            let _e133 = k1_5;
            let _e134 = k2_5;
            kIn_1 = max(_e132, min(_e133, _e134));
            let _e137 = kOut_1;
            let _e138 = k1_5;
            let _e139 = k2_5;
            kOut_1 = min(_e137, max(_e138, _e139));
        }
    } else {
        let _e142 = relOrigin_1;
        let _e145 = radius_3;
        if (abs(_e142.z) > _e145) {
            return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
        }
    }
    let _e151 = kIn_1;
    if (_e151 > 0f) {
        let _e154 = kIn_1;
        local_1 = _e154;
    } else {
        let _e155 = kOut_1;
        local_1 = _e155;
    }
    let _e157 = local_1;
    k_1 = _e157;
    let _e159 = k_1;
    let _e162 = kOut_1;
    let _e163 = kIn_1;
    if ((_e159 <= 0f) || (_e162 < _e163)) {
        return vec3<f32>(100000000000000000000f, 100000000000000000000f, 100000000000000000000f);
    }
    let _e170 = origin_3;
    let _e171 = k_1;
    let _e172 = dir_3;
    inters_1 = (_e170 + (_e171 * _e172));
    let _e176 = inters_1;
    return _e176;
}

fn voxelElevationMap(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, rezolution: i32, intensity_2: f32, specular: f32, size: f32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, colorFog: vec4<f32>, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var rezolution_1: i32;
    var intensity_3: f32;
    var specular_1: f32;
    var size_1: f32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_4: vec3<f32>;
    var maxZ: f32;
    var heightMap: bool;
    var local_2: f32;
    var ratio: f32;
    var local_3: f32;
    var dk: f32;
    var step: vec3<f32>;
    var fResolution: f32;
    var ballSize: f32;
    var surfaceWidth: f32;
    var surfaceHeight: f32 = 2f;
    var k1_6: f32 = 0f;
    var k2_6: f32 = 100000000f;
    var s: f32;
    var k3_: f32;
    var k4_: f32;
    var s_1: f32;
    var k3_1: f32;
    var k4_1: f32;
    var maxZ2_: f32;
    var s_2: f32;
    var k3_2: f32;
    var k4_2: f32;
    var local_4: vec4<f32>;
    var local_5: vec4<f32>;
    var k_2: f32;
    var p: vec3<f32>;
    var local_6: vec4<f32>;
    var local_7: vec4<f32>;
    var color_2: vec4<f32>;
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32>;
    var prevH: f32;
    var stop: bool;
    var strideX: f32;
    var strideY: f32;
    var intersected: f32 = 0f;
    var kFog: f32 = 1000000000f;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var nextLines: vec2<f32>;
    var trailSize: f32;
    var maxIter: i32 = 1000i;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var sphereCenter: vec3<f32>;
    var local_8: vec4<f32>;
    var hColor: vec4<f32>;
    var voxelHeight: f32;
    var intersection_2: vec3<f32>;
    var trailAlpha: f32;
    var col: vec4<f32>;
    var sampled: vec4<f32>;
    var normal: vec3<f32>;
    var alpha: f32;
    var lightDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var spec: f32;
    var local_9: f32;
    var specularColor: vec4<f32>;
    var local_10: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    rezolution_1 = rezolution;
    intensity_3 = intensity_2;
    specular_1 = specular;
    size_1 = size;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    colorFog_1 = colorFog;
    model3DTransform_1 = model3DTransform;
    let _e49 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e49);
    let _e52 = m;
    let _e53 = cameraPos;
    cameraPos = (_e52 * vec4<f32>(_e53.x, _e53.y, _e53.z, 1f)).xyz;
    let _e61 = pos_1;
    let _e63 = D;
    let _e65 = pos_1;
    let _e67 = D;
    dir_4 = vec3<f32>((_e61.x * _e63), (_e65.y * _e67), -1f);
    let _e73 = m;
    let _e83 = dir_4;
    dir_4 = normalize((mat3x3<f32>(_e73[0].xyz, _e73[1].xyz, _e73[2].xyz) * _e83));
    let _e86 = intensity_3;
    maxZ = (abs(_e86) * 0.02f);
    let _e91 = sourceElevation_specified_1;
    heightMap = (_e91 == 1i);
    let _e95 = heightMap;
    if _e95 {
        let _e96 = sourceElevationDim_1;
        let _e98 = sourceElevationDim_1;
        local_2 = (_e96.x / _e98.y);
    } else {
        let _e101 = sourceDim_1;
        let _e103 = sourceDim_1;
        local_2 = (_e101.x / _e103.y);
    }
    let _e107 = local_2;
    ratio = _e107;
    let _e109 = heightMap;
    if _e109 {
        let _e111 = sourceElevationDim_1;
        local_3 = (2f / _e111.y);
    } else {
        let _e115 = sourceDim_1;
        local_3 = (2f / _e115.y);
    }
    let _e119 = local_3;
    dk = _e119;
    let _e121 = dir_4;
    let _e122 = dk;
    step = (_e121 * _e122);
    let _e125 = rezolution_1;
    fResolution = f32(_e125);
    let _e129 = fResolution;
    ballSize = (2f / _e129);
    let _e132 = maxZ;
    let _e133 = ballSize;
    maxZ = (_e132 + _e133);
    let _e136 = ratio;
    let _e138 = ballSize;
    let _e141 = ballSize;
    surfaceWidth = (round(((2f * _e136) / _e138)) * _e141);
    let _e150 = dir_4;
    if (_e150.x != 0f) {
        {
            let _e154 = dir_4;
            s = sign(_e154.x);
            let _e158 = s;
            let _e160 = surfaceWidth;
            let _e164 = cameraPos;
            let _e167 = dir_4;
            k3_ = ((((-(_e158) * _e160) / 2f) - _e164.x) / _e167.x);
            let _e171 = s;
            let _e172 = surfaceWidth;
            let _e176 = cameraPos;
            let _e179 = dir_4;
            k4_ = ((((_e171 * _e172) / 2f) - _e176.x) / _e179.x);
            let _e183 = k1_6;
            let _e184 = k3_;
            k1_6 = max(_e183, _e184);
            let _e186 = k2_6;
            let _e187 = k4_;
            k2_6 = min(_e186, _e187);
        }
    }
    let _e189 = dir_4;
    if (_e189.y != 0f) {
        {
            let _e193 = dir_4;
            s_1 = sign(_e193.y);
            let _e197 = s_1;
            let _e199 = cameraPos;
            let _e202 = dir_4;
            k3_1 = ((-(_e197) - _e199.y) / _e202.y);
            let _e206 = s_1;
            let _e207 = cameraPos;
            let _e210 = dir_4;
            k4_1 = ((_e206 - _e207.y) / _e210.y);
            let _e214 = k1_6;
            let _e215 = k3_1;
            k1_6 = max(_e214, _e215);
            let _e217 = k2_6;
            let _e218 = k4_1;
            k2_6 = min(_e217, _e218);
        }
    }
    let _e220 = maxZ;
    maxZ2_ = (_e220 + 0.0001f);
    let _e224 = dir_4;
    if (_e224.z != 0f) {
        {
            let _e228 = dir_4;
            s_2 = sign(_e228.z);
            let _e232 = s_2;
            let _e234 = maxZ2_;
            let _e236 = cameraPos;
            let _e239 = dir_4;
            k3_2 = (((-(_e232) * _e234) - _e236.z) / _e239.z);
            let _e243 = s_2;
            let _e244 = maxZ2_;
            let _e246 = cameraPos;
            let _e249 = dir_4;
            k4_2 = (((_e243 * _e244) - _e246.z) / _e249.z);
            let _e253 = k1_6;
            let _e254 = k3_2;
            k1_6 = max(_e253, _e254);
            let _e256 = k2_6;
            let _e257 = k4_2;
            k2_6 = min(_e256, _e257);
        }
    }
    let _e259 = k1_6;
    let _e260 = k2_6;
    if (_e259 > _e260) {
        let _e262 = colorFog_1;
        if (_e262.w != 0f) {
            let _e266 = colorFog_1;
            let _e267 = _e266.xyz;
            local_5 = vec4<f32>(_e267.x, _e267.y, _e267.z, 1f);
        } else {
            let _e273 = sourceBkg_specified_1;
            if (_e273 == 1i) {
                let _e276 = outPos_1;
                let _e280 = global.U[0];
                let _e283 = outPos_1;
                let _e292 = _mirror_wrap(((vec2<f32>((_e276.x / _e280.x), _e283.y) / vec2(2f)) + vec2(0.5f)));
                let _e293 = textureSample(t_sourceBkg, samp, _e292);
                local_4 = _e293;
            } else {
                local_4 = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e300 = local_4;
            local_5 = _e300;
        }
        let _e302 = local_5;
        return _e302;
    }
    let _e303 = k1_6;
    k_2 = _e303;
    let _e305 = cameraPos;
    let _e306 = k_2;
    let _e307 = dir_4;
    p = (_e305 + (_e306 * _e307));
    let _e311 = colorFog_1;
    if (_e311.w != 0f) {
        let _e315 = colorFog_1;
        let _e316 = _e315.xyz;
        local_7 = vec4<f32>(_e316.x, _e316.y, _e316.z, 1f);
    } else {
        let _e322 = sourceBkg_specified_1;
        if (_e322 == 1i) {
            let _e325 = outPos_1;
            let _e329 = global.U[0];
            let _e332 = outPos_1;
            let _e341 = _mirror_wrap(((vec2<f32>((_e325.x / _e329.x), _e332.y) / vec2(2f)) + vec2(0.5f)));
            let _e342 = textureSample(t_sourceBkg, samp, _e341);
            local_6 = _e342;
        } else {
            local_6 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e349 = local_6;
        local_7 = _e349;
    }
    let _e351 = local_7;
    color_2 = _e351;
    let _e361 = dir_4;
    let _e364 = ballSize;
    strideX = (sign(_e361.x) * _e364);
    let _e367 = dir_4;
    let _e370 = ballSize;
    strideY = (sign(_e367.y) * _e370);
    let _e383 = dir_4;
    let _e386 = ballSize;
    nextLines = ((sign(_e383.xy) * _e386) / vec2(2f));
    let _e392 = size_1;
    trailSize = _e392;
    loop {
        let _e396 = intersected;
        let _e399 = k_2;
        let _e400 = k2_6;
        let _e403 = maxIter;
        if !((((_e396 < 1f) && (_e399 <= _e400)) && (_e403 > 0i))) {
            break;
        }
        {
            let _e408 = p;
            let _e410 = surfaceWidth;
            let _e414 = ballSize;
            indexX = ((_e408.x + (_e410 / 2f)) / _e414);
            let _e417 = p;
            let _e419 = surfaceHeight;
            let _e423 = ballSize;
            indexY = ((_e417.y + (_e419 / 2f)) / _e423);
            let _e426 = indexX;
            fX = fract(_e426);
            let _e429 = indexY;
            fY = fract(_e429);
            let _e433 = fX;
            let _e436 = dir_4;
            if ((_e433 > 0.9999f) && (_e436.x > 0f)) {
                let _e442 = indexX;
                let _e446 = ballSize;
                sphereCenter.x = ((ceil(_e442) + 0.5f) * _e446);
            } else {
                let _e448 = fX;
                let _e451 = dir_4;
                if ((_e448 < 0.0001f) && (_e451.x < 0f)) {
                    let _e457 = indexX;
                    let _e461 = ballSize;
                    sphereCenter.x = ((floor(_e457) - 0.5f) * _e461);
                } else {
                    let _e464 = indexX;
                    let _e468 = ballSize;
                    sphereCenter.x = ((floor(_e464) + 0.5f) * _e468);
                }
            }
            let _e471 = sphereCenter;
            let _e473 = surfaceWidth;
            sphereCenter.x = (_e471.x - (_e473 / 2f));
            let _e477 = fY;
            let _e480 = dir_4;
            if ((_e477 > 0.9999f) && (_e480.y > 0f)) {
                let _e486 = indexY;
                let _e490 = ballSize;
                sphereCenter.y = ((ceil(_e486) + 0.5f) * _e490);
            } else {
                let _e492 = fY;
                let _e495 = dir_4;
                if ((_e492 < 0.0001f) && (_e495.y < 0f)) {
                    let _e501 = indexY;
                    let _e505 = ballSize;
                    sphereCenter.y = ((floor(_e501) - 0.5f) * _e505);
                } else {
                    let _e508 = indexY;
                    let _e512 = ballSize;
                    sphereCenter.y = ((floor(_e508) + 0.5f) * _e512);
                }
            }
            let _e515 = sphereCenter;
            let _e517 = surfaceHeight;
            sphereCenter.y = (_e515.y - (_e517 / 2f));
            let _e521 = heightMap;
            if _e521 {
                let _e522 = sphereCenter;
                let _e527 = global.U[0];
                let _e530 = sphereCenter;
                let _e540 = _mirror_wrap(((vec2<f32>((_e522.x / _e527.x), _e530.y) / vec2(2f)) + vec2(0.5f)));
                let _e541 = textureSample(t_sourceElevation, samp, _e540);
                local_8 = _e541;
            } else {
                let _e542 = sphereCenter;
                let _e547 = global.U[0];
                let _e550 = sphereCenter;
                let _e560 = _mirror_wrap(((vec2<f32>((_e542.x / _e547.x), _e550.y) / vec2(2f)) + vec2(0.5f)));
                let _e561 = textureSample(t_source, samp, _e560);
                local_8 = _e561;
            }
            let _e563 = local_8;
            hColor = _e563;
            let _e565 = intensity_3;
            let _e566 = hColor;
            let _e567 = height(_e565, _e566);
            voxelHeight = _e567;
            let _e570 = voxelHeight;
            sphereCenter.z = _e570;
            let _e571 = sphereCenter;
            let _e574 = surfaceWidth;
            let _e578 = sphereCenter;
            let _e581 = surfaceHeight;
            if ((abs(_e571.x) < (_e574 / 2f)) && (abs(_e578.y) < (_e581 / 2f))) {
                {
                    let _e586 = sphereCenter;
                    let _e587 = ballSize;
                    let _e590 = cameraPos;
                    let _e591 = dir_4;
                    let _e592 = cubeIntersection(_e586, (_e587 / 2f), _e590, _e591);
                    intersection_2 = _e592;
                    trailAlpha = 1f;
                    let _e596 = intersection_2;
                    if (_e596.x == 100000000000000000000f) {
                        {
                            let _e600 = sphereCenter;
                            let _e601 = ballSize;
                            let _e604 = trailSize;
                            let _e605 = cameraPos;
                            let _e606 = dir_4;
                            let _e607 = trailIntersection(_e600, (_e601 / 2f), _e604, _e605, _e606);
                            intersection_2 = _e607;
                            let _e608 = intersection_2;
                            if (_e608.x != 100000000000000000000f) {
                                {
                                    let _e615 = voxelHeight;
                                    let _e616 = ballSize;
                                    let _e620 = intersection_2;
                                    let _e624 = trailSize;
                                    trailAlpha = (1f / (1f + ((1f * ((_e615 - (_e616 / 2f)) - _e620.z)) / _e624)));
                                }
                            }
                        }
                    }
                    let _e628 = intersection_2;
                    if (_e628.x != 100000000000000000000f) {
                        {
                            let _e632 = cameraPos;
                            let _e633 = intersection_2;
                            kFog = length((_e632 - _e633.xyz));
                            let _e637 = sphereCenter;
                            let _e642 = global.U[0];
                            let _e645 = sphereCenter;
                            let _e655 = _mirror_wrap(((vec2<f32>((_e637.x / _e642.x), _e645.y) / vec2(2f)) + vec2(0.5f)));
                            let _e656 = textureSample(t_source, samp, _e655);
                            col = _e656;
                            let _e659 = col;
                            let _e661 = trailAlpha;
                            col.w = (_e659.w * _e661);
                            let _e663 = col;
                            let _e664 = ambientColor_1;
                            let _e667 = (_e664.xyz * 2f);
                            let _e668 = ambientColor_1;
                            sampled = (_e663 * vec4<f32>(_e667.x, _e667.y, _e667.z, _e668.w));
                            let _e676 = sourceColor_1;
                            if (length(_e676.xyz) != 0f) {
                                {
                                    let _e681 = sphereCenter;
                                    let _e682 = intersection_2;
                                    let _e683 = getCubeNormal(_e681, _e682);
                                    normal = _e683;
                                    let _e685 = normal;
                                    if (length(_e685) > 0f) {
                                        {
                                            let _e689 = sampled;
                                            alpha = _e689.w;
                                            let _e692 = normal;
                                            normal = normalize(_e692);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e700 = sampled;
                                            let _e701 = col;
                                            let _e702 = sourceColor_1;
                                            let _e705 = (_e702.xyz * 2f);
                                            let _e712 = lightDir;
                                            let _e713 = normal;
                                            sampled = (_e700 + ((_e701 * vec4<f32>(_e705.x, _e705.y, _e705.z, 1f)) * clamp(dot(_e712, _e713), 0f, 1f)));
                                            let _e720 = specular_1;
                                            if (_e720 != 0f) {
                                                {
                                                    let _e723 = lightDir;
                                                    let _e724 = normal;
                                                    reflectLightDir = reflect(_e723, _e724);
                                                    let _e727 = specular_1;
                                                    spec = _e727;
                                                    let _e729 = sourceColor_1;
                                                    let _e730 = specular_1;
                                                    if (_e730 < 0.25f) {
                                                        let _e733 = specular_1;
                                                        local_9 = (_e733 * 4f);
                                                    } else {
                                                        local_9 = 1f;
                                                    }
                                                    let _e738 = local_9;
                                                    let _e740 = dir_4;
                                                    let _e741 = reflectLightDir;
                                                    let _e747 = specular_1;
                                                    specularColor = ((_e729 * _e738) * pow(clamp(dot(_e740, _e741), 0f, 1f), (10f - (_e747 * 10f))));
                                                    let _e754 = sampled;
                                                    let _e755 = specularColor;
                                                    sampled = (_e754 + _e755);
                                                }
                                            }
                                            let _e758 = alpha;
                                            sampled.w = _e758;
                                        }
                                    }
                                }
                            }
                            let _e759 = intersected;
                            if (_e759 == 0f) {
                                let _e762 = sampled;
                                local_10 = _e762;
                            } else {
                                let _e763 = outColor;
                                let _e765 = sampled;
                                let _e767 = intersected;
                                let _e768 = intersected;
                                let _e769 = sampled;
                                let _e774 = mix(_e763.xyz, _e765.xyz, vec3((_e767 / (_e768 + _e769.w))));
                                let _e775 = outColor;
                                let _e778 = outColor;
                                let _e781 = sampled;
                                local_10 = vec4<f32>(_e774.x, _e774.y, _e774.z, (_e775.w + ((1f - _e778.w) * _e781.w)));
                            }
                            let _e790 = local_10;
                            outColor = _e790;
                            let _e791 = intersected;
                            let _e792 = sampled;
                            intersected = (_e791 + _e792.w);
                        }
                    }
                }
            }
            let _e795 = sphereCenter;
            let _e797 = nextLines;
            next = (_e795.xy + _e797);
            let _e800 = next;
            let _e801 = p;
            let _e804 = dir_4;
            deltaK = ((_e800 - _e801.xy) / _e804.xy);
            let _e808 = deltaK;
            let _e810 = deltaK;
            minK = min(_e808.x, _e810.y);
            let _e814 = k_2;
            let _e815 = minK;
            k_2 = (_e814 + _e815);
            let _e817 = p;
            let _e818 = minK;
            let _e819 = dir_4;
            p = (_e817 + (_e818 * _e819));
            let _e822 = maxIter;
            maxIter = (_e822 - 1i);
        }
    }
    let _e825 = color_2;
    let _e826 = outColor;
    let _e827 = _e826.xyz;
    let _e828 = color_2;
    let _e834 = outColor;
    color_2 = mix(_e825, vec4<f32>(_e827.x, _e827.y, _e827.z, _e828.w), vec4(_e834.w));
    let _e838 = colorFog_1;
    if (_e838.w != 0f) {
        {
            let _e844 = colorFog_1;
            nearDist = (2f * (1f - _e844.w));
            let _e850 = nearDist;
            farDist = (2f * _e850);
            let _e853 = nearDist;
            let _e854 = farDist;
            let _e855 = kFog;
            kFog = smoothstep(_e853, _e854, _e855);
            let _e857 = color_2;
            let _e859 = color_2;
            let _e861 = colorFog_1;
            let _e863 = kFog;
            let _e865 = mix(_e859.xyz, _e861.xyz, vec3(_e863));
            color_2.x = _e865.x;
            color_2.y = _e865.y;
            color_2.z = _e865.z;
        }
    }
    let _e872 = color_2;
    return clamp(_e872, vec4(0f), vec4(1f));
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[4];
    let _e73 = global.U[5];
    let _e78 = global.U[6];
    let _e82 = global.U[7];
    let _e86 = global.U[9];
    let _e91 = global.U[10];
    let _e95 = global.U[11];
    let _e99 = global.U[12];
    let _e103 = global.U[13];
    let _e106 = global.U[14];
    let _e109 = global.U[15];
    let _e112 = global.U[16];
    let _e115 = global.U[17];
    let _e118 = global.U[18];
    let _e121 = global.U[19];
    let _e143 = voxelElevationMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.xy, _e82.xy, i32(_e86.x), _e91.x, _e95.x, _e99.x, _e103, _e106, _e109, mat4x4<f32>(vec4<f32>(_e112.x, _e112.y, _e112.z, _e112.w), vec4<f32>(_e115.x, _e115.y, _e115.z, _e115.w), vec4<f32>(_e118.x, _e118.y, _e118.z, _e118.w), vec4<f32>(_e121.x, _e121.y, _e121.z, _e121.w)));
    fragColor = _e143;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
