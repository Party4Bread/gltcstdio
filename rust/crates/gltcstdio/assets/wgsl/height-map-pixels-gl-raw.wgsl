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
            let _e281 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e265.x / _e269.x), _e272.y) / vec2(2f)) + vec2(0.5f)));
            local_4 = _e281;
        } else {
            local_4 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e288 = local_4;
        return _e288;
    }
    let _e289 = k1_6;
    k_2 = _e289;
    let _e291 = cameraPos;
    let _e292 = k_2;
    let _e293 = dir_4;
    p = (_e291 + (_e292 * _e293));
    let _e297 = sourceBkg_specified_1;
    if (_e297 == 1i) {
        let _e300 = outPos_1;
        let _e304 = global.U[0];
        let _e307 = outPos_1;
        let _e316 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e300.x / _e304.x), _e307.y) / vec2(2f)) + vec2(0.5f)));
        local_5 = _e316;
    } else {
        local_5 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e323 = local_5;
    color_2 = _e323;
    let _e333 = dir_4;
    let _e336 = ballSize;
    nextLines = ((sign(_e333.xy) * _e336) / vec2(2f));
    let _e342 = thickness_1;
    trailSize = (_e342 * 0.04f);
    loop {
        let _e348 = intersected;
        let _e351 = k_2;
        let _e352 = k2_6;
        let _e355 = maxIter;
        if !((((_e348 < 1f) && (_e351 <= _e352)) && (_e355 > 0i))) {
            break;
        }
        {
            let _e360 = p;
            let _e362 = surfaceWidth;
            let _e366 = ballSize;
            indexX = ((_e360.x + (_e362 / 2f)) / _e366);
            let _e369 = p;
            let _e371 = surfaceHeight;
            let _e375 = ballSize;
            indexY = ((_e369.y + (_e371 / 2f)) / _e375);
            let _e378 = indexX;
            fX = fract(_e378);
            let _e381 = indexY;
            fY = fract(_e381);
            let _e385 = fX;
            let _e388 = dir_4;
            if ((_e385 > 0.9999f) && (_e388.x > 0f)) {
                let _e394 = indexX;
                let _e398 = ballSize;
                sphereCenter.x = ((ceil(_e394) + 0.5f) * _e398);
            } else {
                let _e400 = fX;
                let _e403 = dir_4;
                if ((_e400 < 0.0001f) && (_e403.x < 0f)) {
                    let _e409 = indexX;
                    let _e413 = ballSize;
                    sphereCenter.x = ((floor(_e409) - 0.5f) * _e413);
                } else {
                    let _e416 = indexX;
                    let _e420 = ballSize;
                    sphereCenter.x = ((floor(_e416) + 0.5f) * _e420);
                }
            }
            let _e423 = sphereCenter;
            let _e425 = surfaceWidth;
            sphereCenter.x = (_e423.x - (_e425 / 2f));
            let _e429 = fY;
            let _e432 = dir_4;
            if ((_e429 > 0.9999f) && (_e432.y > 0f)) {
                let _e438 = indexY;
                let _e442 = ballSize;
                sphereCenter.y = ((ceil(_e438) + 0.5f) * _e442);
            } else {
                let _e444 = fY;
                let _e447 = dir_4;
                if ((_e444 < 0.0001f) && (_e447.y < 0f)) {
                    let _e453 = indexY;
                    let _e457 = ballSize;
                    sphereCenter.y = ((floor(_e453) - 0.5f) * _e457);
                } else {
                    let _e460 = indexY;
                    let _e464 = ballSize;
                    sphereCenter.y = ((floor(_e460) + 0.5f) * _e464);
                }
            }
            let _e467 = sphereCenter;
            let _e469 = surfaceHeight;
            sphereCenter.y = (_e467.y - (_e469 / 2f));
            let _e473 = heightMap;
            if _e473 {
                let _e474 = sphereCenter;
                let _e479 = global.U[0];
                let _e482 = sphereCenter;
                let _e492 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e474.x / _e479.x), _e482.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e492;
            } else {
                let _e493 = sphereCenter;
                let _e498 = global.U[0];
                let _e501 = sphereCenter;
                let _e511 = textureSample(t_source, samp, ((vec2<f32>((_e493.x / _e498.x), _e501.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e511;
            }
            let _e513 = local_6;
            hColor = _e513;
            let _e515 = intensity_3;
            let _e516 = hColor;
            let _e517 = hmpgl_height(_e515, _e516);
            h = _e517;
            let _e520 = h;
            sphereCenter.z = _e520;
            let _e521 = sphereCenter;
            let _e524 = surfaceWidth;
            let _e528 = sphereCenter;
            let _e531 = surfaceHeight;
            if ((abs(_e521.x) < (_e524 / 2f)) && (abs(_e528.y) < (_e531 / 2f))) {
                {
                    let _e536 = sphereCenter;
                    let _e537 = ballSize;
                    let _e540 = cameraPos;
                    let _e541 = dir_4;
                    let _e542 = hmpgl_cubeIntersection(_e536, (_e537 / 2f), _e540, _e541);
                    intersection_2 = _e542;
                    trailAlpha = 1f;
                    let _e546 = intersection_2;
                    if (_e546.x >= 10000000000000000000f) {
                        {
                            let _e550 = sphereCenter;
                            let _e551 = ballSize;
                            let _e554 = trailSize;
                            let _e555 = cameraPos;
                            let _e556 = dir_4;
                            let _e557 = hmpgl_trailIntersection(_e550, (_e551 / 2f), _e554, _e555, _e556);
                            intersection_2 = _e557;
                            let _e558 = intersection_2;
                            if (_e558.x < 10000000000000000000f) {
                                {
                                    let _e565 = h;
                                    let _e566 = ballSize;
                                    let _e570 = intersection_2;
                                    let _e574 = trailSize;
                                    trailAlpha = (1f / (1f + ((1f * ((_e565 - (_e566 / 2f)) - _e570.z)) / _e574)));
                                }
                            }
                        }
                    }
                    let _e578 = intersection_2;
                    if (_e578.x < 10000000000000000000f) {
                        {
                            let _e583 = colorScheme_1;
                            if (_e583 == 0f) {
                                let _e586 = sphereCenter;
                                let _e591 = global.U[0];
                                let _e594 = sphereCenter;
                                let _e604 = textureSample(t_source, samp, ((vec2<f32>((_e586.x / _e591.x), _e594.y) / vec2(2f)) + vec2(0.5f)));
                                col = _e604;
                            } else {
                                let _e605 = colorScheme_1;
                                if (_e605 == 100f) {
                                    let _e608 = intersection_2;
                                    let _e613 = global.U[0];
                                    let _e616 = intersection_2;
                                    let _e626 = textureSample(t_source, samp, ((vec2<f32>((_e608.x / _e613.x), _e616.y) / vec2(2f)) + vec2(0.5f)));
                                    col = _e626;
                                } else {
                                    let _e627 = sphereCenter;
                                    let _e632 = global.U[0];
                                    let _e635 = sphereCenter;
                                    let _e645 = textureSample(t_source, samp, ((vec2<f32>((_e627.x / _e632.x), _e635.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e646 = intersection_2;
                                    let _e651 = global.U[0];
                                    let _e654 = intersection_2;
                                    let _e664 = textureSample(t_source, samp, ((vec2<f32>((_e646.x / _e651.x), _e654.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e665 = colorScheme_1;
                                    col = mix(_e645, _e664, vec4((_e665 * 0.01f)));
                                }
                            }
                            let _e671 = col;
                            let _e673 = trailAlpha;
                            col.w = (_e671.w * _e673);
                            let _e675 = col;
                            let _e676 = ambientColor_1;
                            let _e679 = (_e676.xyz * 2f);
                            let _e680 = ambientColor_1;
                            sampled = (_e675 * vec4<f32>(_e679.x, _e679.y, _e679.z, _e680.w));
                            let _e688 = sourceColor_1;
                            if (length(_e688.xyz) != 0f) {
                                {
                                    let _e693 = sphereCenter;
                                    let _e694 = intersection_2;
                                    let _e695 = hmpgl_getCubeNormal(_e693, _e694);
                                    normal = _e695;
                                    let _e697 = normal;
                                    if (length(_e697) > 0f) {
                                        {
                                            let _e701 = sampled;
                                            alpha = _e701.w;
                                            let _e704 = normal;
                                            normal = normalize(_e704);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e712 = sampled;
                                            let _e713 = col;
                                            let _e714 = sourceColor_1;
                                            let _e717 = (_e714.xyz * 2f);
                                            let _e724 = lightDir;
                                            let _e725 = normal;
                                            sampled = (_e712 + ((_e713 * vec4<f32>(_e717.x, _e717.y, _e717.z, 1f)) * clamp(dot(_e724, _e725), 0f, 1f)));
                                            let _e732 = specular_1;
                                            if (_e732 != 0f) {
                                                {
                                                    let _e735 = lightDir;
                                                    let _e736 = normal;
                                                    reflectLightDir = reflect(_e735, _e736);
                                                    let _e739 = sourceColor_1;
                                                    let _e740 = specular_1;
                                                    if (_e740 < 25f) {
                                                        let _e743 = specular_1;
                                                        local_7 = (_e743 * 0.04f);
                                                    } else {
                                                        local_7 = 1f;
                                                    }
                                                    let _e748 = local_7;
                                                    let _e750 = dir_4;
                                                    let _e751 = reflectLightDir;
                                                    let _e757 = specular_1;
                                                    specularColor = ((_e739 * _e748) * pow(clamp(dot(_e750, _e751), 0f, 1f), (10f - (_e757 * 0.1f))));
                                                    let _e764 = sampled;
                                                    let _e765 = specularColor;
                                                    sampled = (_e764 + _e765);
                                                }
                                            }
                                            let _e768 = alpha;
                                            sampled.w = _e768;
                                        }
                                    }
                                }
                            }
                            let _e769 = intersected;
                            if (_e769 == 0f) {
                                let _e772 = sampled;
                                local_8 = _e772;
                            } else {
                                let _e773 = outColor;
                                let _e775 = sampled;
                                let _e777 = intersected;
                                let _e778 = intersected;
                                let _e779 = sampled;
                                let _e784 = mix(_e773.xyz, _e775.xyz, vec3((_e777 / (_e778 + _e779.w))));
                                let _e785 = outColor;
                                let _e788 = outColor;
                                let _e791 = sampled;
                                local_8 = vec4<f32>(_e784.x, _e784.y, _e784.z, (_e785.w + ((1f - _e788.w) * _e791.w)));
                            }
                            let _e800 = local_8;
                            outColor = _e800;
                            let _e801 = intersected;
                            let _e802 = sampled;
                            intersected = (_e801 + _e802.w);
                        }
                    }
                }
            }
            let _e805 = sphereCenter;
            let _e807 = nextLines;
            next = (_e805.xy + _e807);
            let _e810 = next;
            let _e811 = p;
            let _e814 = dir_4;
            deltaK = ((_e810 - _e811.xy) / _e814.xy);
            let _e818 = deltaK;
            let _e820 = deltaK;
            minK = min(_e818.x, _e820.y);
            let _e824 = k_2;
            let _e825 = minK;
            k_2 = (_e824 + _e825);
            let _e827 = p;
            let _e828 = minK;
            let _e829 = dir_4;
            p = (_e827 + (_e828 * _e829));
            let _e832 = maxIter;
            maxIter = (_e832 - 1i);
        }
    }
    let _e835 = color_2;
    let _e836 = outColor;
    let _e837 = _e836.xyz;
    let _e838 = color_2;
    let _e844 = outColor;
    result = mix(_e835, vec4<f32>(_e837.x, _e837.y, _e837.z, _e838.w), vec4(_e844.w));
    let _e849 = result;
    return clamp(_e849, vec4(0f), vec4(1f));
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
