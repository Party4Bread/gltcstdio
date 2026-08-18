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

fn hmpgl_cubeIntersection(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
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
            return vec3(100000000000000000000f);
        }
    }
    let _e63 = dir_1;
    if (_e63.y != 0f) {
        {
            let _e67 = relOrigin;
            let _e69 = radius_1;
            let _e72 = dir_1;
            k1_1 = (-((_e67.y - _e69)) / _e72.y);
            let _e76 = relOrigin;
            let _e78 = radius_1;
            let _e81 = dir_1;
            k2_1 = (-((_e76.y + _e78)) / _e81.y);
            let _e85 = kIn;
            let _e86 = k1_1;
            let _e87 = k2_1;
            kIn = max(_e85, min(_e86, _e87));
            let _e90 = kOut;
            let _e91 = k1_1;
            let _e92 = k2_1;
            kOut = min(_e90, max(_e91, _e92));
        }
    } else {
        let _e95 = relOrigin;
        let _e98 = radius_1;
        if (abs(_e95.y) > _e98) {
            return vec3(100000000000000000000f);
        }
    }
    let _e102 = dir_1;
    if (_e102.z != 0f) {
        {
            let _e106 = relOrigin;
            let _e108 = radius_1;
            let _e111 = dir_1;
            k1_2 = (-((_e106.z - _e108)) / _e111.z);
            let _e115 = relOrigin;
            let _e117 = radius_1;
            let _e120 = dir_1;
            k2_2 = (-((_e115.z + _e117)) / _e120.z);
            let _e124 = kIn;
            let _e125 = k1_2;
            let _e126 = k2_2;
            kIn = max(_e124, min(_e125, _e126));
            let _e129 = kOut;
            let _e130 = k1_2;
            let _e131 = k2_2;
            kOut = min(_e129, max(_e130, _e131));
        }
    } else {
        let _e134 = relOrigin;
        let _e137 = radius_1;
        if (abs(_e134.z) > _e137) {
            return vec3(100000000000000000000f);
        }
    }
    let _e141 = kIn;
    if (_e141 > 0f) {
        let _e144 = kIn;
        local = _e144;
    } else {
        let _e145 = kOut;
        local = _e145;
    }
    let _e147 = local;
    k = _e147;
    let _e149 = k;
    let _e152 = kOut;
    let _e153 = kIn;
    if ((_e149 <= 0f) || (_e152 < _e153)) {
        return vec3(100000000000000000000f);
    }
    let _e158 = origin_1;
    let _e159 = k;
    let _e160 = dir_1;
    return (_e158 + (_e159 * _e160));
}

fn hmpgl_getCubeNormal(center_2: vec3<f32>, intersection: vec3<f32>) -> vec3<f32> {
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

fn hmpgl_height(intensity: f32, color: vec4<f32>) -> f32 {
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

fn hmpgl_round(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e10 = x_1;
    return floor((_e10 + 0.5f));
}

fn hmpgl_trailIntersection(center_4: vec3<f32>, radius_2: f32, extraTrail: f32, origin_2: vec3<f32>, dir_2: vec3<f32>) -> vec3<f32> {
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
            return vec3(100000000000000000000f);
        }
    }
    let _e65 = dir_3;
    if (_e65.y != 0f) {
        {
            let _e69 = relOrigin_1;
            let _e71 = radius_3;
            let _e74 = dir_3;
            k1_4 = (-((_e69.y - _e71)) / _e74.y);
            let _e78 = relOrigin_1;
            let _e80 = radius_3;
            let _e83 = dir_3;
            k2_4 = (-((_e78.y + _e80)) / _e83.y);
            let _e87 = kIn_1;
            let _e88 = k1_4;
            let _e89 = k2_4;
            kIn_1 = max(_e87, min(_e88, _e89));
            let _e92 = kOut_1;
            let _e93 = k1_4;
            let _e94 = k2_4;
            kOut_1 = min(_e92, max(_e93, _e94));
        }
    } else {
        let _e97 = relOrigin_1;
        let _e100 = radius_3;
        if (abs(_e97.y) > _e100) {
            return vec3(100000000000000000000f);
        }
    }
    let _e104 = dir_3;
    if (_e104.z != 0f) {
        {
            let _e108 = relOrigin_1;
            let _e110 = radius_3;
            let _e113 = dir_3;
            k1_5 = (-((_e108.z + _e110)) / _e113.z);
            let _e117 = relOrigin_1;
            let _e119 = radius_3;
            let _e120 = extraTrail_1;
            let _e124 = dir_3;
            k2_5 = (-((_e117.z + (_e119 + _e120))) / _e124.z);
            let _e128 = kIn_1;
            let _e129 = k1_5;
            let _e130 = k2_5;
            kIn_1 = max(_e128, min(_e129, _e130));
            let _e133 = kOut_1;
            let _e134 = k1_5;
            let _e135 = k2_5;
            kOut_1 = min(_e133, max(_e134, _e135));
        }
    } else {
        let _e138 = relOrigin_1;
        let _e141 = radius_3;
        if (abs(_e138.z) > _e141) {
            return vec3(100000000000000000000f);
        }
    }
    let _e145 = kIn_1;
    if (_e145 > 0f) {
        let _e148 = kIn_1;
        local_1 = _e148;
    } else {
        let _e149 = kOut_1;
        local_1 = _e149;
    }
    let _e151 = local_1;
    k_1 = _e151;
    let _e153 = k_1;
    let _e156 = kOut_1;
    let _e157 = kIn_1;
    if ((_e153 <= 0f) || (_e156 < _e157)) {
        return vec3(100000000000000000000f);
    }
    let _e162 = origin_3;
    let _e163 = k_1;
    let _e164 = dir_3;
    return (_e162 + (_e163 * _e164));
}

fn heightMapPixelsGl(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, intensity_2: f32, rezolution: i32, thickness: f32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, colorScheme: f32, specular: f32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var intensity_3: f32;
    var rezolution_1: i32;
    var thickness_1: f32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var colorScheme_1: f32;
    var specular_1: f32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_4: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
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
    var k_2: f32;
    var p: vec3<f32>;
    var local_5: vec4<f32>;
    var color_2: vec4<f32>;
    var intersected: f32 = 0f;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var nextLines: vec2<f32>;
    var trailSize: f32;
    var maxIter: i32 = 1000i;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var sphereCenter: vec3<f32>;
    var local_6: vec4<f32>;
    var hColor: vec4<f32>;
    var h: f32;
    var intersection_2: vec3<f32>;
    var trailAlpha: f32;
    var col: vec4<f32>;
    var sampled: vec4<f32>;
    var normal: vec3<f32>;
    var alpha: f32;
    var lightDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var local_7: f32;
    var specularColor: vec4<f32>;
    var local_8: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var result: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    intensity_3 = intensity_2;
    rezolution_1 = rezolution;
    thickness_1 = thickness;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    colorScheme_1 = colorScheme;
    specular_1 = specular;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
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
    let _e86 = sourceElevation_specified_1;
    heightMap = (_e86 == 1i);
    let _e90 = intensity_3;
    maxZ = (abs(_e90) * 0.02f);
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
    let _e140 = hmpgl_round(((2f * _e136) / _e138));
    let _e141 = ballSize;
    surfaceWidth = (_e140 * _e141);
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
        let _e262 = sourceBkg_specified_1;
        if (_e262 == 1i) {
            let _e265 = outPos_1;
            let _e269 = global.U[0];
            let _e272 = outPos_1;
            let _e282 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e265.x / _e269.x), _e272.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local_4 = _e282;
        } else {
            local_4 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e289 = local_4;
        return _e289;
    }
    let _e290 = k1_6;
    k_2 = _e290;
    let _e292 = cameraPos;
    let _e293 = k_2;
    let _e294 = dir_4;
    p = (_e292 + (_e293 * _e294));
    let _e298 = sourceBkg_specified_1;
    if (_e298 == 1i) {
        let _e301 = outPos_1;
        let _e305 = global.U[0];
        let _e308 = outPos_1;
        let _e318 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e301.x / _e305.x), _e308.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_5 = _e318;
    } else {
        local_5 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e325 = local_5;
    color_2 = _e325;
    let _e335 = dir_4;
    let _e338 = ballSize;
    nextLines = ((sign(_e335.xy) * _e338) / vec2(2f));
    let _e344 = thickness_1;
    trailSize = (_e344 * 0.04f);
    loop {
        let _e350 = intersected;
        let _e353 = k_2;
        let _e354 = k2_6;
        let _e357 = maxIter;
        if !((((_e350 < 1f) && (_e353 <= _e354)) && (_e357 > 0i))) {
            break;
        }
        {
            let _e362 = p;
            let _e364 = surfaceWidth;
            let _e368 = ballSize;
            indexX = ((_e362.x + (_e364 / 2f)) / _e368);
            let _e371 = p;
            let _e373 = surfaceHeight;
            let _e377 = ballSize;
            indexY = ((_e371.y + (_e373 / 2f)) / _e377);
            let _e380 = indexX;
            fX = fract(_e380);
            let _e383 = indexY;
            fY = fract(_e383);
            let _e387 = fX;
            let _e390 = dir_4;
            if ((_e387 > 0.9999f) && (_e390.x > 0f)) {
                let _e396 = indexX;
                let _e400 = ballSize;
                sphereCenter.x = ((ceil(_e396) + 0.5f) * _e400);
            } else {
                let _e402 = fX;
                let _e405 = dir_4;
                if ((_e402 < 0.0001f) && (_e405.x < 0f)) {
                    let _e411 = indexX;
                    let _e415 = ballSize;
                    sphereCenter.x = ((floor(_e411) - 0.5f) * _e415);
                } else {
                    let _e418 = indexX;
                    let _e422 = ballSize;
                    sphereCenter.x = ((floor(_e418) + 0.5f) * _e422);
                }
            }
            let _e425 = sphereCenter;
            let _e427 = surfaceWidth;
            sphereCenter.x = (_e425.x - (_e427 / 2f));
            let _e431 = fY;
            let _e434 = dir_4;
            if ((_e431 > 0.9999f) && (_e434.y > 0f)) {
                let _e440 = indexY;
                let _e444 = ballSize;
                sphereCenter.y = ((ceil(_e440) + 0.5f) * _e444);
            } else {
                let _e446 = fY;
                let _e449 = dir_4;
                if ((_e446 < 0.0001f) && (_e449.y < 0f)) {
                    let _e455 = indexY;
                    let _e459 = ballSize;
                    sphereCenter.y = ((floor(_e455) - 0.5f) * _e459);
                } else {
                    let _e462 = indexY;
                    let _e466 = ballSize;
                    sphereCenter.y = ((floor(_e462) + 0.5f) * _e466);
                }
            }
            let _e469 = sphereCenter;
            let _e471 = surfaceHeight;
            sphereCenter.y = (_e469.y - (_e471 / 2f));
            let _e475 = heightMap;
            if _e475 {
                let _e476 = sphereCenter;
                let _e481 = global.U[0];
                let _e484 = sphereCenter;
                let _e495 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e476.x / _e481.x), _e484.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_6 = _e495;
            } else {
                let _e496 = sphereCenter;
                let _e501 = global.U[0];
                let _e504 = sphereCenter;
                let _e515 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e496.x / _e501.x), _e504.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_6 = _e515;
            }
            let _e517 = local_6;
            hColor = _e517;
            let _e519 = intensity_3;
            let _e520 = hColor;
            let _e521 = hmpgl_height(_e519, _e520);
            h = _e521;
            let _e524 = h;
            sphereCenter.z = _e524;
            let _e525 = sphereCenter;
            let _e528 = surfaceWidth;
            let _e532 = sphereCenter;
            let _e535 = surfaceHeight;
            if ((abs(_e525.x) < (_e528 / 2f)) && (abs(_e532.y) < (_e535 / 2f))) {
                {
                    let _e540 = sphereCenter;
                    let _e541 = ballSize;
                    let _e544 = cameraPos;
                    let _e545 = dir_4;
                    let _e546 = hmpgl_cubeIntersection(_e540, (_e541 / 2f), _e544, _e545);
                    intersection_2 = _e546;
                    trailAlpha = 1f;
                    let _e550 = intersection_2;
                    if (_e550.x >= 10000000000000000000f) {
                        {
                            let _e554 = sphereCenter;
                            let _e555 = ballSize;
                            let _e558 = trailSize;
                            let _e559 = cameraPos;
                            let _e560 = dir_4;
                            let _e561 = hmpgl_trailIntersection(_e554, (_e555 / 2f), _e558, _e559, _e560);
                            intersection_2 = _e561;
                            let _e562 = intersection_2;
                            if (_e562.x < 10000000000000000000f) {
                                {
                                    let _e569 = h;
                                    let _e570 = ballSize;
                                    let _e574 = intersection_2;
                                    let _e578 = trailSize;
                                    trailAlpha = (1f / (1f + ((1f * ((_e569 - (_e570 / 2f)) - _e574.z)) / _e578)));
                                }
                            }
                        }
                    }
                    let _e582 = intersection_2;
                    if (_e582.x < 10000000000000000000f) {
                        {
                            let _e587 = colorScheme_1;
                            if (_e587 == 0f) {
                                let _e590 = sphereCenter;
                                let _e595 = global.U[0];
                                let _e598 = sphereCenter;
                                let _e609 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e590.x / _e595.x), _e598.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                col = _e609;
                            } else {
                                let _e610 = colorScheme_1;
                                if (_e610 == 100f) {
                                    let _e613 = intersection_2;
                                    let _e618 = global.U[0];
                                    let _e621 = intersection_2;
                                    let _e632 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e613.x / _e618.x), _e621.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    col = _e632;
                                } else {
                                    let _e633 = sphereCenter;
                                    let _e638 = global.U[0];
                                    let _e641 = sphereCenter;
                                    let _e652 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e633.x / _e638.x), _e641.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e653 = intersection_2;
                                    let _e658 = global.U[0];
                                    let _e661 = intersection_2;
                                    let _e672 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e653.x / _e658.x), _e661.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e673 = colorScheme_1;
                                    col = mix(_e652, _e672, vec4((_e673 * 0.01f)));
                                }
                            }
                            let _e679 = col;
                            let _e681 = trailAlpha;
                            col.w = (_e679.w * _e681);
                            let _e683 = col;
                            let _e684 = ambientColor_1;
                            let _e687 = (_e684.xyz * 2f);
                            let _e688 = ambientColor_1;
                            sampled = (_e683 * vec4<f32>(_e687.x, _e687.y, _e687.z, _e688.w));
                            let _e696 = sourceColor_1;
                            if (length(_e696.xyz) != 0f) {
                                {
                                    let _e701 = sphereCenter;
                                    let _e702 = intersection_2;
                                    let _e703 = hmpgl_getCubeNormal(_e701, _e702);
                                    normal = _e703;
                                    let _e705 = normal;
                                    if (length(_e705) > 0f) {
                                        {
                                            let _e709 = sampled;
                                            alpha = _e709.w;
                                            let _e712 = normal;
                                            normal = normalize(_e712);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e720 = sampled;
                                            let _e721 = col;
                                            let _e722 = sourceColor_1;
                                            let _e725 = (_e722.xyz * 2f);
                                            let _e732 = lightDir;
                                            let _e733 = normal;
                                            sampled = (_e720 + ((_e721 * vec4<f32>(_e725.x, _e725.y, _e725.z, 1f)) * clamp(dot(_e732, _e733), 0f, 1f)));
                                            let _e740 = specular_1;
                                            if (_e740 != 0f) {
                                                {
                                                    let _e743 = lightDir;
                                                    let _e744 = normal;
                                                    reflectLightDir = reflect(_e743, _e744);
                                                    let _e747 = sourceColor_1;
                                                    let _e748 = specular_1;
                                                    if (_e748 < 25f) {
                                                        let _e751 = specular_1;
                                                        local_7 = (_e751 * 0.04f);
                                                    } else {
                                                        local_7 = 1f;
                                                    }
                                                    let _e756 = local_7;
                                                    let _e758 = dir_4;
                                                    let _e759 = reflectLightDir;
                                                    let _e765 = specular_1;
                                                    specularColor = ((_e747 * _e756) * pow(clamp(dot(_e758, _e759), 0f, 1f), (10f - (_e765 * 0.1f))));
                                                    let _e772 = sampled;
                                                    let _e773 = specularColor;
                                                    sampled = (_e772 + _e773);
                                                }
                                            }
                                            let _e776 = alpha;
                                            sampled.w = _e776;
                                        }
                                    }
                                }
                            }
                            let _e777 = intersected;
                            if (_e777 == 0f) {
                                let _e780 = sampled;
                                local_8 = _e780;
                            } else {
                                let _e781 = outColor;
                                let _e783 = sampled;
                                let _e785 = intersected;
                                let _e786 = intersected;
                                let _e787 = sampled;
                                let _e792 = mix(_e781.xyz, _e783.xyz, vec3((_e785 / (_e786 + _e787.w))));
                                let _e793 = outColor;
                                let _e796 = outColor;
                                let _e799 = sampled;
                                local_8 = vec4<f32>(_e792.x, _e792.y, _e792.z, (_e793.w + ((1f - _e796.w) * _e799.w)));
                            }
                            let _e808 = local_8;
                            outColor = _e808;
                            let _e809 = intersected;
                            let _e810 = sampled;
                            intersected = (_e809 + _e810.w);
                        }
                    }
                }
            }
            let _e813 = sphereCenter;
            let _e815 = nextLines;
            next = (_e813.xy + _e815);
            let _e818 = next;
            let _e819 = p;
            let _e822 = dir_4;
            deltaK = ((_e818 - _e819.xy) / _e822.xy);
            let _e826 = deltaK;
            let _e828 = deltaK;
            minK = min(_e826.x, _e828.y);
            let _e832 = k_2;
            let _e833 = minK;
            k_2 = (_e832 + _e833);
            let _e835 = p;
            let _e836 = minK;
            let _e837 = dir_4;
            p = (_e835 + (_e836 * _e837));
            let _e840 = maxIter;
            maxIter = (_e840 - 1i);
        }
    }
    let _e843 = color_2;
    let _e844 = outColor;
    let _e845 = _e844.xyz;
    let _e846 = color_2;
    let _e852 = outColor;
    result = mix(_e843, vec4<f32>(_e845.x, _e845.y, _e845.z, _e846.w), vec4(_e852.w));
    let _e857 = result;
    return clamp(_e857, vec4(0f), vec4(1f));
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
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e87 = global.U[11];
    let _e91 = global.U[12];
    let _e94 = global.U[13];
    let _e97 = global.U[14];
    let _e101 = global.U[15];
    let _e105 = global.U[6];
    let _e109 = global.U[7];
    let _e113 = global.U[16];
    let _e116 = global.U[17];
    let _e119 = global.U[18];
    let _e122 = global.U[19];
    let _e144 = heightMapPixelsGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.x, i32(_e82.x), _e87.x, _e91, _e94, _e97.x, _e101.x, _e105.xy, _e109.xy, mat4x4<f32>(vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w), vec4<f32>(_e116.x, _e116.y, _e116.z, _e116.w), vec4<f32>(_e119.x, _e119.y, _e119.z, _e119.w), vec4<f32>(_e122.x, _e122.y, _e122.z, _e122.w)));
    fragColor = _e144;
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
