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
                let _e294 = textureSampleLevel(t_sourceBkg, samp, _e292, 0f);
                local_4 = _e294;
            } else {
                local_4 = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e301 = local_4;
            local_5 = _e301;
        }
        let _e303 = local_5;
        return _e303;
    }
    let _e304 = k1_6;
    k_2 = _e304;
    let _e306 = cameraPos;
    let _e307 = k_2;
    let _e308 = dir_4;
    p = (_e306 + (_e307 * _e308));
    let _e312 = colorFog_1;
    if (_e312.w != 0f) {
        let _e316 = colorFog_1;
        let _e317 = _e316.xyz;
        local_7 = vec4<f32>(_e317.x, _e317.y, _e317.z, 1f);
    } else {
        let _e323 = sourceBkg_specified_1;
        if (_e323 == 1i) {
            let _e326 = outPos_1;
            let _e330 = global.U[0];
            let _e333 = outPos_1;
            let _e342 = _mirror_wrap(((vec2<f32>((_e326.x / _e330.x), _e333.y) / vec2(2f)) + vec2(0.5f)));
            let _e344 = textureSampleLevel(t_sourceBkg, samp, _e342, 0f);
            local_6 = _e344;
        } else {
            local_6 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e351 = local_6;
        local_7 = _e351;
    }
    let _e353 = local_7;
    color_2 = _e353;
    let _e363 = dir_4;
    let _e366 = ballSize;
    strideX = (sign(_e363.x) * _e366);
    let _e369 = dir_4;
    let _e372 = ballSize;
    strideY = (sign(_e369.y) * _e372);
    let _e385 = dir_4;
    let _e388 = ballSize;
    nextLines = ((sign(_e385.xy) * _e388) / vec2(2f));
    let _e394 = size_1;
    trailSize = _e394;
    loop {
        let _e398 = intersected;
        let _e401 = k_2;
        let _e402 = k2_6;
        let _e405 = maxIter;
        if !((((_e398 < 1f) && (_e401 <= _e402)) && (_e405 > 0i))) {
            break;
        }
        {
            let _e410 = p;
            let _e412 = surfaceWidth;
            let _e416 = ballSize;
            indexX = ((_e410.x + (_e412 / 2f)) / _e416);
            let _e419 = p;
            let _e421 = surfaceHeight;
            let _e425 = ballSize;
            indexY = ((_e419.y + (_e421 / 2f)) / _e425);
            let _e428 = indexX;
            fX = fract(_e428);
            let _e431 = indexY;
            fY = fract(_e431);
            let _e435 = fX;
            let _e438 = dir_4;
            if ((_e435 > 0.9999f) && (_e438.x > 0f)) {
                let _e444 = indexX;
                let _e448 = ballSize;
                sphereCenter.x = ((ceil(_e444) + 0.5f) * _e448);
            } else {
                let _e450 = fX;
                let _e453 = dir_4;
                if ((_e450 < 0.0001f) && (_e453.x < 0f)) {
                    let _e459 = indexX;
                    let _e463 = ballSize;
                    sphereCenter.x = ((floor(_e459) - 0.5f) * _e463);
                } else {
                    let _e466 = indexX;
                    let _e470 = ballSize;
                    sphereCenter.x = ((floor(_e466) + 0.5f) * _e470);
                }
            }
            let _e473 = sphereCenter;
            let _e475 = surfaceWidth;
            sphereCenter.x = (_e473.x - (_e475 / 2f));
            let _e479 = fY;
            let _e482 = dir_4;
            if ((_e479 > 0.9999f) && (_e482.y > 0f)) {
                let _e488 = indexY;
                let _e492 = ballSize;
                sphereCenter.y = ((ceil(_e488) + 0.5f) * _e492);
            } else {
                let _e494 = fY;
                let _e497 = dir_4;
                if ((_e494 < 0.0001f) && (_e497.y < 0f)) {
                    let _e503 = indexY;
                    let _e507 = ballSize;
                    sphereCenter.y = ((floor(_e503) - 0.5f) * _e507);
                } else {
                    let _e510 = indexY;
                    let _e514 = ballSize;
                    sphereCenter.y = ((floor(_e510) + 0.5f) * _e514);
                }
            }
            let _e517 = sphereCenter;
            let _e519 = surfaceHeight;
            sphereCenter.y = (_e517.y - (_e519 / 2f));
            let _e523 = heightMap;
            if _e523 {
                let _e524 = sphereCenter;
                let _e529 = global.U[0];
                let _e532 = sphereCenter;
                let _e542 = _mirror_wrap(((vec2<f32>((_e524.x / _e529.x), _e532.y) / vec2(2f)) + vec2(0.5f)));
                let _e544 = textureSampleLevel(t_sourceElevation, samp, _e542, 0f);
                local_8 = _e544;
            } else {
                let _e545 = sphereCenter;
                let _e550 = global.U[0];
                let _e553 = sphereCenter;
                let _e563 = _mirror_wrap(((vec2<f32>((_e545.x / _e550.x), _e553.y) / vec2(2f)) + vec2(0.5f)));
                let _e565 = textureSampleLevel(t_source, samp, _e563, 0f);
                local_8 = _e565;
            }
            let _e567 = local_8;
            hColor = _e567;
            let _e569 = intensity_3;
            let _e570 = hColor;
            let _e571 = height(_e569, _e570);
            voxelHeight = _e571;
            let _e574 = voxelHeight;
            sphereCenter.z = _e574;
            let _e575 = sphereCenter;
            let _e578 = surfaceWidth;
            let _e582 = sphereCenter;
            let _e585 = surfaceHeight;
            if ((abs(_e575.x) < (_e578 / 2f)) && (abs(_e582.y) < (_e585 / 2f))) {
                {
                    let _e590 = sphereCenter;
                    let _e591 = ballSize;
                    let _e594 = cameraPos;
                    let _e595 = dir_4;
                    let _e596 = cubeIntersection(_e590, (_e591 / 2f), _e594, _e595);
                    intersection_2 = _e596;
                    trailAlpha = 1f;
                    let _e600 = intersection_2;
                    if (_e600.x == 100000000000000000000f) {
                        {
                            let _e604 = sphereCenter;
                            let _e605 = ballSize;
                            let _e608 = trailSize;
                            let _e609 = cameraPos;
                            let _e610 = dir_4;
                            let _e611 = trailIntersection(_e604, (_e605 / 2f), _e608, _e609, _e610);
                            intersection_2 = _e611;
                            let _e612 = intersection_2;
                            if (_e612.x != 100000000000000000000f) {
                                {
                                    let _e619 = voxelHeight;
                                    let _e620 = ballSize;
                                    let _e624 = intersection_2;
                                    let _e628 = trailSize;
                                    trailAlpha = (1f / (1f + ((1f * ((_e619 - (_e620 / 2f)) - _e624.z)) / _e628)));
                                }
                            }
                        }
                    }
                    let _e632 = intersection_2;
                    if (_e632.x != 100000000000000000000f) {
                        {
                            let _e636 = cameraPos;
                            let _e637 = intersection_2;
                            kFog = length((_e636 - _e637.xyz));
                            let _e641 = sphereCenter;
                            let _e646 = global.U[0];
                            let _e649 = sphereCenter;
                            let _e659 = _mirror_wrap(((vec2<f32>((_e641.x / _e646.x), _e649.y) / vec2(2f)) + vec2(0.5f)));
                            let _e661 = textureSampleLevel(t_source, samp, _e659, 0f);
                            col = _e661;
                            let _e664 = col;
                            let _e666 = trailAlpha;
                            col.w = (_e664.w * _e666);
                            let _e668 = col;
                            let _e669 = ambientColor_1;
                            let _e672 = (_e669.xyz * 2f);
                            let _e673 = ambientColor_1;
                            sampled = (_e668 * vec4<f32>(_e672.x, _e672.y, _e672.z, _e673.w));
                            let _e681 = sourceColor_1;
                            if (length(_e681.xyz) != 0f) {
                                {
                                    let _e686 = sphereCenter;
                                    let _e687 = intersection_2;
                                    let _e688 = getCubeNormal(_e686, _e687);
                                    normal = _e688;
                                    let _e690 = normal;
                                    if (length(_e690) > 0f) {
                                        {
                                            let _e694 = sampled;
                                            alpha = _e694.w;
                                            let _e697 = normal;
                                            normal = normalize(_e697);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e705 = sampled;
                                            let _e706 = col;
                                            let _e707 = sourceColor_1;
                                            let _e710 = (_e707.xyz * 2f);
                                            let _e717 = lightDir;
                                            let _e718 = normal;
                                            sampled = (_e705 + ((_e706 * vec4<f32>(_e710.x, _e710.y, _e710.z, 1f)) * clamp(dot(_e717, _e718), 0f, 1f)));
                                            let _e725 = specular_1;
                                            if (_e725 != 0f) {
                                                {
                                                    let _e728 = lightDir;
                                                    let _e729 = normal;
                                                    reflectLightDir = reflect(_e728, _e729);
                                                    let _e732 = specular_1;
                                                    spec = _e732;
                                                    let _e734 = sourceColor_1;
                                                    let _e735 = specular_1;
                                                    if (_e735 < 0.25f) {
                                                        let _e738 = specular_1;
                                                        local_9 = (_e738 * 4f);
                                                    } else {
                                                        local_9 = 1f;
                                                    }
                                                    let _e743 = local_9;
                                                    let _e745 = dir_4;
                                                    let _e746 = reflectLightDir;
                                                    let _e752 = specular_1;
                                                    specularColor = ((_e734 * _e743) * pow(clamp(dot(_e745, _e746), 0f, 1f), (10f - (_e752 * 10f))));
                                                    let _e759 = sampled;
                                                    let _e760 = specularColor;
                                                    sampled = (_e759 + _e760);
                                                }
                                            }
                                            let _e763 = alpha;
                                            sampled.w = _e763;
                                        }
                                    }
                                }
                            }
                            let _e764 = intersected;
                            if (_e764 == 0f) {
                                let _e767 = sampled;
                                local_10 = _e767;
                            } else {
                                let _e768 = outColor;
                                let _e770 = sampled;
                                let _e772 = intersected;
                                let _e773 = intersected;
                                let _e774 = sampled;
                                let _e779 = mix(_e768.xyz, _e770.xyz, vec3((_e772 / (_e773 + _e774.w))));
                                let _e780 = outColor;
                                let _e783 = outColor;
                                let _e786 = sampled;
                                local_10 = vec4<f32>(_e779.x, _e779.y, _e779.z, (_e780.w + ((1f - _e783.w) * _e786.w)));
                            }
                            let _e795 = local_10;
                            outColor = _e795;
                            let _e796 = intersected;
                            let _e797 = sampled;
                            intersected = (_e796 + _e797.w);
                        }
                    }
                }
            }
            let _e800 = sphereCenter;
            let _e802 = nextLines;
            next = (_e800.xy + _e802);
            let _e805 = next;
            let _e806 = p;
            let _e809 = dir_4;
            deltaK = ((_e805 - _e806.xy) / _e809.xy);
            let _e813 = deltaK;
            let _e815 = deltaK;
            minK = min(_e813.x, _e815.y);
            let _e819 = k_2;
            let _e820 = minK;
            k_2 = (_e819 + _e820);
            let _e822 = p;
            let _e823 = minK;
            let _e824 = dir_4;
            p = (_e822 + (_e823 * _e824));
            let _e827 = maxIter;
            maxIter = (_e827 - 1i);
        }
    }
    let _e830 = color_2;
    let _e831 = outColor;
    let _e832 = _e831.xyz;
    let _e833 = color_2;
    let _e839 = outColor;
    color_2 = mix(_e830, vec4<f32>(_e832.x, _e832.y, _e832.z, _e833.w), vec4(_e839.w));
    let _e843 = colorFog_1;
    if (_e843.w != 0f) {
        {
            let _e849 = colorFog_1;
            nearDist = (2f * (1f - _e849.w));
            let _e855 = nearDist;
            farDist = (2f * _e855);
            let _e858 = nearDist;
            let _e859 = farDist;
            let _e860 = kFog;
            kFog = smoothstep(_e858, _e859, _e860);
            let _e862 = color_2;
            let _e864 = color_2;
            let _e866 = colorFog_1;
            let _e868 = kFog;
            let _e870 = mix(_e864.xyz, _e866.xyz, vec3(_e868));
            color_2.x = _e870.x;
            color_2.y = _e870.y;
            color_2.z = _e870.z;
        }
    }
    let _e877 = color_2;
    return clamp(_e877, vec4(0f), vec4(1f));
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
