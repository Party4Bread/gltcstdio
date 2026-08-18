struct Params {
    U: array<vec4<f32>, 28>,
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

fn applyLighting(baseColor: vec4<f32>, reflectColor: vec4<f32>, fromSource: f32, specular: f32, ambientColor: vec4<f32>, sourceColor: vec4<f32>, gamma: f32) -> vec4<f32> {
    var baseColor_1: vec4<f32>;
    var reflectColor_1: vec4<f32>;
    var fromSource_1: f32;
    var specular_1: f32;
    var ambientColor_1: vec4<f32>;
    var sourceColor_1: vec4<f32>;
    var gamma_1: f32;
    var sumRGB: vec3<f32>;
    var maxLum: f32;
    var color: vec3<f32>;
    var lum: f32;
    var gammaCorrectedLum: f32;

    baseColor_1 = baseColor;
    reflectColor_1 = reflectColor;
    fromSource_1 = fromSource;
    specular_1 = specular;
    ambientColor_1 = ambientColor;
    sourceColor_1 = sourceColor;
    gamma_1 = gamma;
    let _e22 = ambientColor_1;
    let _e24 = sourceColor_1;
    sumRGB = ((_e22.xyz + _e24.xyz) + vec3(1f));
    let _e31 = sumRGB;
    let _e33 = sumRGB;
    let _e36 = sumRGB;
    maxLum = max(max(_e31.x, _e33.y), _e36.z);
    let _e40 = maxLum;
    if (_e40 == 0f) {
        return vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e48 = reflectColor_1;
    let _e50 = baseColor_1;
    let _e52 = ambientColor_1;
    let _e56 = baseColor_1;
    let _e58 = sourceColor_1;
    let _e61 = fromSource_1;
    let _e64 = sourceColor_1;
    let _e66 = specular_1;
    let _e69 = maxLum;
    color = ((((_e48.xyz + (_e50.xyz * _e52.xyz)) + ((_e56.xyz * _e58.xyz) * _e61)) + (_e64.xyz * _e66)) / vec3(_e69));
    let _e73 = color;
    let _e75 = color;
    let _e78 = color;
    lum = (((_e73.x + _e75.y) + _e78.z) / 3f);
    let _e84 = lum;
    let _e87 = gamma_1;
    if ((_e84 > 0f) && (_e87 != 0f)) {
        {
            let _e91 = lum;
            let _e93 = gamma_1;
            gammaCorrectedLum = pow(_e91, pow(1.02f, (-(_e93) * 100f)));
            let _e100 = color;
            let _e101 = gammaCorrectedLum;
            let _e103 = lum;
            color = ((_e100 * _e101) / vec3(_e103));
        }
    }
    let _e106 = color;
    let _e107 = baseColor_1;
    return clamp(vec4<f32>(_e106.x, _e106.y, _e106.z, _e107.w), vec4(0f), vec4(1f));
}

fn boxMap(dir: vec3<f32>, sourceBkgDim: vec2<f32>) -> vec3<f32> {
    var dir_1: vec3<f32>;
    var sourceBkgDim_1: vec2<f32>;
    var ratio: f32;
    var X: f32 = 0.5f;
    var Y: f32 = 0.5f;

    dir_1 = dir;
    sourceBkgDim_1 = sourceBkgDim;
    let _e12 = sourceBkgDim_1;
    let _e14 = sourceBkgDim_1;
    ratio = (_e12.y / _e14.x);
    let _e22 = dir_1;
    let _e25 = dir_1;
    let _e28 = ratio;
    let _e31 = dir_1;
    let _e34 = dir_1;
    let _e37 = ratio;
    if ((abs(_e22.y) > (abs(_e25.z) * _e28)) && (abs(_e31.y) > (abs(_e34.x) * _e37))) {
        {
            let _e41 = X;
            let _e42 = dir_1;
            let _e45 = dir_1;
            X = (_e41 + ((-(_e42.x) / _e45.y) * 0.5f));
            let _e51 = Y;
            let _e52 = dir_1;
            let _e55 = dir_1;
            Y = (_e51 + ((-(_e52.z) / _e55.y) * 0.5f));
        }
    } else {
        let _e61 = dir_1;
        let _e64 = dir_1;
        if (abs(_e61.x) < abs(_e64.z)) {
            {
                let _e68 = X;
                let _e69 = dir_1;
                let _e71 = dir_1;
                let _e75 = ratio;
                let _e79 = dir_1;
                X = (_e68 + ((((_e69.x / abs(_e71.z)) * _e75) * 0.5f) * -(sign(_e79.z))));
                let _e85 = Y;
                let _e86 = dir_1;
                let _e88 = dir_1;
                Y = (_e85 + ((_e86.y / abs(_e88.z)) * 0.5f));
            }
        } else {
            {
                let _e95 = X;
                let _e96 = dir_1;
                let _e98 = dir_1;
                let _e102 = ratio;
                let _e106 = dir_1;
                X = (_e95 + ((((_e96.z / abs(_e98.x)) * _e102) * 0.5f) * -(sign(_e106.x))));
                let _e112 = Y;
                let _e113 = dir_1;
                let _e115 = dir_1;
                Y = (_e112 + ((_e113.y / abs(_e115.x)) * 0.5f));
            }
        }
    }
    let _e122 = X;
    let _e123 = Y;
    return vec3<f32>(_e122, _e123, 1f);
}

fn planeMap(dir_2: vec3<f32>, sourceBkgDim_2: vec2<f32>) -> vec3<f32> {
    var dir_3: vec3<f32>;
    var sourceBkgDim_3: vec2<f32>;
    var ratio_1: f32;
    var planePos: vec2<f32>;
    var m: f32;
    var darken: f32;

    dir_3 = dir_2;
    sourceBkgDim_3 = sourceBkgDim_2;
    let _e12 = sourceBkgDim_3;
    let _e14 = sourceBkgDim_3;
    ratio_1 = (_e12.x / _e14.y);
    let _e18 = dir_3;
    let _e21 = dir_3;
    let _e24 = ratio_1;
    let _e26 = dir_3;
    let _e29 = dir_3;
    planePos = ((vec2<f32>(((-(_e18.x) / _e21.z) * _e24), (-(_e26.y) / _e29.z)) * 0.5f) + vec2<f32>(0.5f, 0.5f));
    let _e40 = planePos;
    let _e45 = planePos;
    m = (max(abs((_e40.x - 0.5f)), abs((_e45.y - 0.5f))) * 2f);
    let _e56 = m;
    darken = (1f / max(1f, _e56));
    let _e60 = planePos;
    let _e61 = darken;
    return vec3<f32>(_e60.x, _e60.y, _e61);
}

fn sphereMap(dir_4: vec3<f32>, sourceBkgDim_4: vec2<f32>) -> vec3<f32> {
    var dir_5: vec3<f32>;
    var sourceBkgDim_5: vec2<f32>;
    var n: vec3<f32>;
    var alpha: f32;
    var beta: f32;
    var nX: f32 = 1f;
    var nY: f32 = 1f;

    dir_5 = dir_4;
    sourceBkgDim_5 = sourceBkgDim_4;
    let _e12 = dir_5;
    n = normalize(_e12);
    let _e15 = n;
    let _e17 = n;
    alpha = atan2(_e15.x, _e17.z);
    let _e21 = n;
    beta = asin(_e21.y);
    let _e29 = alpha;
    let _e33 = nX;
    let _e36 = nY;
    let _e37 = beta;
    return vec3<f32>(((-(_e29) / 3.1415927f) * _e33), (0.5f + ((_e36 * _e37) / 3.1415927f)), 1f);
}

fn backgroundDirect(dir_6: vec3<f32>, outPos: vec2<f32>, sourceBkgDim_6: vec2<f32>, backgroundMode: i32) -> vec3<f32> {
    var dir_7: vec3<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkgDim_7: vec2<f32>;
    var backgroundMode_1: i32;

    dir_7 = dir_6;
    outPos_1 = outPos;
    sourceBkgDim_7 = sourceBkgDim_6;
    backgroundMode_1 = backgroundMode;
    let _e16 = backgroundMode_1;
    if (_e16 == 1i) {
        let _e19 = dir_7;
        let _e20 = sourceBkgDim_7;
        let _e21 = planeMap(_e19, _e20);
        return _e21;
    } else {
        let _e22 = backgroundMode_1;
        if (_e22 == 2i) {
            let _e25 = dir_7;
            let _e26 = sourceBkgDim_7;
            let _e27 = boxMap(_e25, _e26);
            return _e27;
        } else {
            let _e28 = backgroundMode_1;
            if (_e28 == 3i) {
                let _e31 = outPos_1;
                return vec3<f32>(_e31.x, _e31.y, 1f);
            } else {
                let _e36 = dir_7;
                let _e37 = sourceBkgDim_7;
                let _e38 = sphereMap(_e36, _e37);
                return _e38;
            }
        }
    }
}

fn backgroundForReflection(dir_8: vec3<f32>, sourceBkgDim_8: vec2<f32>, backgroundMode_2: i32) -> vec3<f32> {
    var dir_9: vec3<f32>;
    var sourceBkgDim_9: vec2<f32>;
    var backgroundMode_3: i32;

    dir_9 = dir_8;
    sourceBkgDim_9 = sourceBkgDim_8;
    backgroundMode_3 = backgroundMode_2;
    let _e14 = backgroundMode_3;
    if (_e14 == 1i) {
        let _e17 = dir_9;
        let _e18 = sourceBkgDim_9;
        let _e19 = planeMap(_e17, _e18);
        return _e19;
    } else {
        let _e20 = backgroundMode_3;
        if (_e20 == 2i) {
            let _e23 = dir_9;
            let _e24 = sourceBkgDim_9;
            let _e25 = boxMap(_e23, _e24);
            return _e25;
        } else {
            let _e26 = dir_9;
            let _e27 = sourceBkgDim_9;
            let _e28 = sphereMap(_e26, _e27);
            return _e28;
        }
    }
}

fn height(intensity: f32, color_1: vec4<f32>) -> f32 {
    var intensity_1: f32;
    var color_2: vec4<f32>;

    intensity_1 = intensity;
    color_2 = color_1;
    let _e12 = intensity_1;
    let _e15 = color_2;
    let _e17 = color_2;
    let _e20 = color_2;
    return ((_e12 * 0.04f) * ((((_e15.x + _e17.y) + _e20.z) / 3f) - 0.5f));
}

fn quicksilver3D(pos: vec2<f32>, outPos_2: vec2<f32>, intensity_2: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceBkgDim_10: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, lightSourceTransform: mat4x4<f32>, colorScheme: f32, backgroundMode_4: i32, sourceColor_2: vec4<f32>, ambientColor_2: vec4<f32>, colorFog: vec4<f32>, normalSmoothing: f32, surfaceSmoothness: f32, specular_2: f32, shadows: f32, gamma_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_3: vec2<f32>;
    var intensity_3: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceBkgDim_11: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var lightSourceTransform_1: mat4x4<f32>;
    var colorScheme_1: f32;
    var backgroundMode_5: i32;
    var sourceColor_3: vec4<f32>;
    var ambientColor_3: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var normalSmoothing_1: f32;
    var surfaceSmoothness_1: f32;
    var specular_3: f32;
    var shadows_1: f32;
    var gamma_3: f32;
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m_1: mat4x4<f32>;
    var dir_10: vec3<f32>;
    var maxZ: f32;
    var ratio_2: f32;
    var dk: f32;
    var step: vec3<f32>;
    var heightMap: bool;
    var lightPos: vec3<f32>;
    var k1_: f32 = 0f;
    var k2_: f32 = 100000000f;
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
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var bkgDir: vec3<f32>;
    var k: f32;
    var p: vec3<f32>;
    var color_3: vec4<f32>;
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var prevH: f32;
    var stop: bool;
    var pp: vec2<f32>;
    var local: f32;
    var kk: f32;
    var hh: f32;
    var lightVec: vec3<f32>;
    var lightDir: vec3<f32>;
    var lighting: f32 = 1f;
    var spec: f32 = 0f;
    var shadowing: f32;
    var intersection: vec3<f32>;
    var N: f32;
    var bx: f32;
    var local_1: f32;
    var sx: f32;
    var dzdx: f32 = 0f;
    var i: i32 = 0i;
    var deltaX: f32;
    var i_1: i32 = 0i;
    var deltaX_1: f32;
    var deltaX_2: f32;
    var by: f32;
    var local_2: f32;
    var sy: f32;
    var dzdy: f32 = 0f;
    var i_2: i32 = 0i;
    var deltaY: f32;
    var i_3: i32 = 0i;
    var deltaY_1: f32;
    var deltaY_2: f32;
    var unormal: vec3<f32>;
    var local_3: vec3<f32>;
    var normal: vec3<f32>;
    var reflected: vec3<f32>;
    var surfaceColor: vec4<f32>;
    var reflectiveColor: vec4<f32>;
    var reflectColor_2: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var refDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var shad: f32;
    var lightStep: vec3<f32>;
    var k2_1: f32;
    var s_3: f32;
    var k3_3: f32;
    var k4_3: f32;
    var s_4: f32;
    var k3_4: f32;
    var k4_4: f32;
    var maxZ2_1: f32;
    var s_5: f32;
    var k3_5: f32;
    var k4_5: f32;
    var kFog: f32;
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_3 = outPos_2;
    intensity_3 = intensity_2;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceBkgDim_11 = sourceBkgDim_10;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    lightSourceTransform_1 = lightSourceTransform;
    colorScheme_1 = colorScheme;
    backgroundMode_5 = backgroundMode_4;
    sourceColor_3 = sourceColor_2;
    ambientColor_3 = ambientColor_2;
    colorFog_1 = colorFog;
    normalSmoothing_1 = normalSmoothing;
    surfaceSmoothness_1 = surfaceSmoothness;
    specular_3 = specular_2;
    shadows_1 = shadows;
    gamma_3 = gamma_2;
    let _e53 = model3DTransform_1;
    m_1 = _naga_inverse_4x4_f32(_e53);
    let _e56 = m_1;
    let _e57 = cameraPos;
    cameraPos = (_e56 * vec4<f32>(_e57.x, _e57.y, _e57.z, 1f)).xyz;
    let _e65 = pos_1;
    let _e67 = D;
    let _e69 = pos_1;
    let _e71 = D;
    dir_10 = vec3<f32>((_e65.x * _e67), (_e69.y * _e71), -1f);
    let _e77 = m_1;
    let _e87 = dir_10;
    dir_10 = normalize((mat3x3<f32>(_e77[0].xyz, _e77[1].xyz, _e77[2].xyz) * _e87));
    let _e90 = intensity_3;
    maxZ = (abs(_e90) * 0.02f);
    let _e95 = sourceDim_1;
    let _e97 = sourceDim_1;
    ratio_2 = (_e95.x / _e97.y);
    let _e102 = sourceDim_1;
    dk = (2f / _e102.y);
    let _e106 = dir_10;
    let _e107 = dk;
    step = (_e106 * _e107);
    let _e110 = sourceElevation_specified_1;
    heightMap = (_e110 == 1i);
    let _e114 = lightSourceTransform_1;
    lightPos = (_e114 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e127 = dir_10;
    if (_e127.x != 0f) {
        {
            let _e131 = dir_10;
            s = sign(_e131.x);
            let _e135 = s;
            let _e137 = ratio_2;
            let _e139 = cameraPos;
            let _e142 = dir_10;
            k3_ = (((-(_e135) * _e137) - _e139.x) / _e142.x);
            let _e146 = s;
            let _e147 = ratio_2;
            let _e149 = cameraPos;
            let _e152 = dir_10;
            k4_ = (((_e146 * _e147) - _e149.x) / _e152.x);
            let _e156 = k1_;
            let _e157 = k3_;
            k1_ = max(_e156, _e157);
            let _e159 = k2_;
            let _e160 = k4_;
            k2_ = min(_e159, _e160);
        }
    }
    let _e162 = dir_10;
    if (_e162.y != 0f) {
        {
            let _e166 = dir_10;
            s_1 = sign(_e166.y);
            let _e170 = s_1;
            let _e172 = cameraPos;
            let _e175 = dir_10;
            k3_1 = ((-(_e170) - _e172.y) / _e175.y);
            let _e179 = s_1;
            let _e180 = cameraPos;
            let _e183 = dir_10;
            k4_1 = ((_e179 - _e180.y) / _e183.y);
            let _e187 = k1_;
            let _e188 = k3_1;
            k1_ = max(_e187, _e188);
            let _e190 = k2_;
            let _e191 = k4_1;
            k2_ = min(_e190, _e191);
        }
    }
    let _e193 = maxZ;
    maxZ2_ = (_e193 + 0.0001f);
    let _e197 = dir_10;
    if (_e197.z != 0f) {
        {
            let _e201 = dir_10;
            s_2 = sign(_e201.z);
            let _e205 = s_2;
            let _e207 = maxZ2_;
            let _e209 = cameraPos;
            let _e212 = dir_10;
            k3_2 = (((-(_e205) * _e207) - _e209.z) / _e212.z);
            let _e216 = s_2;
            let _e217 = maxZ2_;
            let _e219 = cameraPos;
            let _e222 = dir_10;
            k4_2 = (((_e216 * _e217) - _e219.z) / _e222.z);
            let _e226 = k1_;
            let _e227 = k3_2;
            k1_ = max(_e226, _e227);
            let _e229 = k2_;
            let _e230 = k4_2;
            k2_ = min(_e229, _e230);
        }
    }
    let _e238 = sourceBkg_specified_1;
    if (_e238 == 1i) {
        {
            let _e241 = dir_10;
            let _e242 = outPos_3;
            let _e243 = sourceBkgDim_11;
            let _e244 = backgroundMode_5;
            let _e245 = backgroundDirect(_e241, _e242, _e243, _e244);
            bkgDir = _e245;
            let _e247 = bkgDir;
            let _e252 = global.U[0];
            let _e255 = bkgDir;
            let _e266 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e247.x / _e252.x), _e255.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e267 = bkgDir;
            let _e269 = vec3(_e267.z);
            backgroundColor = (_e266 * vec4<f32>(_e269.x, _e269.y, _e269.z, 1f));
        }
    }
    let _e276 = k1_;
    let _e277 = k2_;
    if (_e276 > _e277) {
        let _e279 = backgroundColor;
        return _e279;
    }
    let _e280 = k1_;
    k = _e280;
    let _e282 = cameraPos;
    let _e283 = k;
    let _e284 = dir_10;
    p = (_e282 + (_e283 * _e284));
    let _e288 = backgroundColor;
    color_3 = _e288;
    let _e303 = heightMap;
    if _e303 {
        {
            loop {
                {
                    let _e304 = dz;
                    prevDz = _e304;
                    let _e305 = h;
                    prevH = _e305;
                    let _e306 = intensity_3;
                    let _e307 = p;
                    let _e312 = global.U[0];
                    let _e315 = p;
                    let _e326 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e307.x / _e312.x), _e315.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e327 = height(_e306, _e326);
                    h = _e327;
                    let _e328 = p;
                    let _e330 = h;
                    dz = (_e328.z - _e330);
                    let _e332 = p;
                    let _e333 = step;
                    p = (_e332 + _e333);
                    let _e335 = k;
                    let _e336 = dk;
                    k = (_e335 + _e336);
                    let _e338 = dz;
                    let _e341 = k;
                    let _e342 = k1_;
                    let _e344 = dz;
                    let _e346 = prevDz;
                    stop = ((_e338 == 0f) || ((_e341 != _e342) && (sign(_e344) == -(sign(_e346)))));
                }
                let _e352 = k;
                let _e353 = k2_;
                let _e355 = stop;
                if !(((_e352 <= _e353) && !(_e355))) {
                    break;
                }
            }
            let _e359 = p;
            let _e360 = step;
            pp = (_e359 - _e360).xy;
            let _e364 = pp;
            let _e368 = global.U[0];
            let _e371 = pp;
            let _e381 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e364.x / _e368.x), _e371.y) / vec2(2f)) + vec2(0.5f)), 0f);
            color_3 = _e381;
            let _e382 = pp;
            let _e383 = step;
            let _e389 = global.U[0];
            let _e392 = pp;
            let _e393 = step;
            let _e405 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e382 - _e383.xy).x / _e389.x), (_e392 - _e393.xy).y) / vec2(2f)) + vec2(0.5f)), 0f);
            prevColor = _e405;
        }
    } else {
        {
            loop {
                {
                    let _e406 = color_3;
                    prevColor = _e406;
                    let _e407 = dz;
                    prevDz = _e407;
                    let _e408 = h;
                    prevH = _e408;
                    let _e409 = p;
                    let _e414 = global.U[0];
                    let _e417 = p;
                    let _e428 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e409.x / _e414.x), _e417.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    color_3 = _e428;
                    let _e429 = intensity_3;
                    let _e430 = color_3;
                    let _e431 = height(_e429, _e430);
                    h = _e431;
                    let _e432 = p;
                    let _e434 = h;
                    dz = (_e432.z - _e434);
                    let _e436 = p;
                    let _e437 = step;
                    p = (_e436 + _e437);
                    let _e439 = k;
                    let _e440 = dk;
                    k = (_e439 + _e440);
                    let _e442 = dz;
                    let _e445 = k;
                    let _e446 = k1_;
                    let _e448 = dz;
                    let _e450 = prevDz;
                    stop = ((_e442 == 0f) || ((_e445 != _e446) && (sign(_e448) == -(sign(_e450)))));
                }
                let _e456 = k;
                let _e457 = k2_;
                let _e459 = stop;
                if !(((_e456 <= _e457) && !(_e459))) {
                    break;
                }
            }
        }
    }
    let _e463 = stop;
    let _e464 = dz;
    let _e466 = dk;
    stop = (_e463 || (abs(_e464) < _e466));
    let _e469 = stop;
    if !(_e469) {
        let _e471 = backgroundColor;
        return _e471;
    }
    let _e472 = dz;
    let _e475 = k1_;
    let _e476 = dk;
    let _e478 = k2_;
    if ((_e472 == 0f) || ((_e475 + _e476) > _e478)) {
        local = 1f;
    } else {
        let _e482 = prevDz;
        let _e484 = dz;
        let _e486 = prevDz;
        local = (abs(_e482) / (abs(_e484) + abs(_e486)));
    }
    let _e491 = local;
    kk = _e491;
    let _e493 = prevH;
    let _e494 = h;
    let _e495 = kk;
    hh = mix(_e493, _e494, _e495);
    let _e498 = lightPos;
    let _e499 = p;
    lightVec = (_e498 - _e499);
    let _e502 = lightVec;
    lightDir = normalize(_e502);
    let _e509 = sourceColor_3;
    let _e511 = sourceColor_3;
    let _e514 = sourceColor_3;
    shadowing = ((_e509.x + _e511.y) + _e514.z);
    let _e518 = p;
    intersection = _e518;
    let _e521 = normalSmoothing_1;
    N = (1f + ceil((_e521 / 20f)));
    let _e528 = normalSmoothing_1;
    bx = (0.0005f + (_e528 * 0.0001f));
    let _e533 = N;
    if (_e533 >= 2f) {
        let _e536 = bx;
        let _e537 = N;
        local_1 = (_e536 / (_e537 - 1f));
    } else {
        local_1 = 0f;
    }
    let _e543 = local_1;
    sx = _e543;
    let _e547 = heightMap;
    if !(_e547) {
        {
            loop {
                let _e551 = i;
                let _e552 = N;
                if !((_e551 < i32(_e552))) {
                    break;
                }
                {
                    let _e559 = bx;
                    let _e560 = i;
                    let _e562 = sx;
                    deltaX = (_e559 + (f32(_e560) * _e562));
                    let _e566 = dzdx;
                    let _e567 = intensity_3;
                    let _e568 = intersection;
                    let _e570 = deltaX;
                    let _e572 = intersection;
                    let _e578 = global.U[0];
                    let _e581 = intersection;
                    let _e583 = deltaX;
                    let _e585 = intersection;
                    let _e597 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e568.x + _e570), _e572.y).x / _e578.x), vec2<f32>((_e581.x + _e583), _e585.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e598 = height(_e567, _e597);
                    let _e599 = intensity_3;
                    let _e600 = intersection;
                    let _e602 = deltaX;
                    let _e604 = intersection;
                    let _e610 = global.U[0];
                    let _e613 = intersection;
                    let _e615 = deltaX;
                    let _e617 = intersection;
                    let _e629 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e600.x - _e602), _e604.y).x / _e610.x), vec2<f32>((_e613.x - _e615), _e617.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e630 = height(_e599, _e629);
                    dzdx = (_e566 + (_e598 - _e630));
                }
                continuing {
                    let _e556 = i;
                    i = (_e556 + 1i);
                }
            }
        }
    } else {
        {
            loop {
                let _e635 = i_1;
                let _e636 = N;
                if !((_e635 < i32(_e636))) {
                    break;
                }
                {
                    let _e643 = bx;
                    let _e644 = i_1;
                    let _e646 = sx;
                    deltaX_1 = (_e643 + (f32(_e644) * _e646));
                    let _e650 = dzdx;
                    let _e651 = intensity_3;
                    let _e652 = intersection;
                    let _e654 = deltaX_1;
                    let _e656 = intersection;
                    let _e662 = global.U[0];
                    let _e665 = intersection;
                    let _e667 = deltaX_1;
                    let _e669 = intersection;
                    let _e681 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e652.x + _e654), _e656.y).x / _e662.x), vec2<f32>((_e665.x + _e667), _e669.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e682 = height(_e651, _e681);
                    let _e683 = intensity_3;
                    let _e684 = intersection;
                    let _e686 = deltaX_1;
                    let _e688 = intersection;
                    let _e694 = global.U[0];
                    let _e697 = intersection;
                    let _e699 = deltaX_1;
                    let _e701 = intersection;
                    let _e713 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e684.x - _e686), _e688.y).x / _e694.x), vec2<f32>((_e697.x - _e699), _e701.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e714 = height(_e683, _e713);
                    dzdx = (_e650 + (_e682 - _e714));
                }
                continuing {
                    let _e640 = i_1;
                    i_1 = (_e640 + 1i);
                }
            }
        }
    }
    let _e717 = dzdx;
    let _e718 = N;
    dzdx = (_e717 / _e718);
    let _e720 = bx;
    let _e721 = N;
    let _e726 = sx;
    deltaX_2 = (_e720 + (((_e721 - 1f) / 2f) * _e726));
    let _e731 = normalSmoothing_1;
    by = (0.0005f + (_e731 * 0.0001f));
    let _e736 = N;
    if (_e736 >= 2f) {
        let _e739 = by;
        let _e740 = N;
        local_2 = (_e739 / (_e740 - 1f));
    } else {
        local_2 = 0f;
    }
    let _e746 = local_2;
    sy = _e746;
    let _e750 = heightMap;
    if !(_e750) {
        {
            loop {
                let _e754 = i_2;
                let _e755 = N;
                if !((_e754 < i32(_e755))) {
                    break;
                }
                {
                    let _e762 = by;
                    let _e763 = i_2;
                    let _e765 = sy;
                    deltaY = (_e762 + (f32(_e763) * _e765));
                    let _e769 = dzdy;
                    let _e770 = intensity_3;
                    let _e771 = intersection;
                    let _e773 = intersection;
                    let _e775 = deltaY;
                    let _e781 = global.U[0];
                    let _e784 = intersection;
                    let _e786 = intersection;
                    let _e788 = deltaY;
                    let _e800 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e771.x, (_e773.y + _e775)).x / _e781.x), vec2<f32>(_e784.x, (_e786.y + _e788)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e801 = height(_e770, _e800);
                    let _e802 = intensity_3;
                    let _e803 = intersection;
                    let _e805 = intersection;
                    let _e807 = deltaY;
                    let _e813 = global.U[0];
                    let _e816 = intersection;
                    let _e818 = intersection;
                    let _e820 = deltaY;
                    let _e832 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e803.x, (_e805.y - _e807)).x / _e813.x), vec2<f32>(_e816.x, (_e818.y - _e820)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e833 = height(_e802, _e832);
                    dzdy = (_e769 + (_e801 - _e833));
                }
                continuing {
                    let _e759 = i_2;
                    i_2 = (_e759 + 1i);
                }
            }
        }
    } else {
        {
            loop {
                let _e838 = i_3;
                let _e839 = N;
                if !((_e838 < i32(_e839))) {
                    break;
                }
                {
                    let _e846 = by;
                    let _e847 = i_3;
                    let _e849 = sy;
                    deltaY_1 = (_e846 + (f32(_e847) * _e849));
                    let _e853 = dzdy;
                    let _e854 = intensity_3;
                    let _e855 = intersection;
                    let _e857 = intersection;
                    let _e859 = deltaY_1;
                    let _e865 = global.U[0];
                    let _e868 = intersection;
                    let _e870 = intersection;
                    let _e872 = deltaY_1;
                    let _e884 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e855.x, (_e857.y + _e859)).x / _e865.x), vec2<f32>(_e868.x, (_e870.y + _e872)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e885 = height(_e854, _e884);
                    let _e886 = intensity_3;
                    let _e887 = intersection;
                    let _e889 = intersection;
                    let _e891 = deltaY_1;
                    let _e897 = global.U[0];
                    let _e900 = intersection;
                    let _e902 = intersection;
                    let _e904 = deltaY_1;
                    let _e916 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e887.x, (_e889.y - _e891)).x / _e897.x), vec2<f32>(_e900.x, (_e902.y - _e904)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e917 = height(_e886, _e916);
                    dzdy = (_e853 + (_e885 - _e917));
                }
                continuing {
                    let _e843 = i_3;
                    i_3 = (_e843 + 1i);
                }
            }
        }
    }
    let _e920 = dzdy;
    let _e921 = N;
    dzdy = (_e920 / _e921);
    let _e923 = by;
    let _e924 = N;
    let _e929 = sy;
    deltaY_2 = (_e923 + (((_e924 - 1f) / 2f) * _e929));
    let _e935 = deltaY_2;
    let _e937 = dzdx;
    let _e941 = deltaX_2;
    let _e943 = dzdy;
    let _e945 = deltaX_2;
    let _e946 = deltaY_2;
    unormal = vec3<f32>(((-2f * _e935) * _e937), ((-2f * _e941) * _e943), (_e945 * _e946));
    let _e950 = unormal;
    let _e954 = unormal;
    let _e959 = unormal;
    if (((_e950.x == 0f) && (_e954.y == 0f)) && (_e959.z == 0f)) {
        local_3 = vec3<f32>(0f, 0f, 1f);
    } else {
        let _e968 = unormal;
        local_3 = normalize(_e968);
    }
    let _e971 = local_3;
    normal = _e971;
    let _e973 = lightDir;
    let _e974 = normal;
    lighting = ((dot(_e973, _e974) + 1f) / 2f);
    let _e980 = dir_10;
    let _e981 = normal;
    reflected = reflect(_e980, _e981);
    let _e984 = prevColor;
    let _e985 = color_3;
    let _e986 = kk;
    surfaceColor = mix(_e984, _e985, vec4(_e986));
    let _e996 = surfaceColor;
    let _e998 = colorScheme_1;
    reflectiveColor = mix(vec4<f32>(1f, 1f, 1f, 1f), (1.5f * _e996), vec4((_e998 * 0.01f)));
    let _e1010 = sourceBkg_specified_1;
    if (_e1010 == 1i) {
        {
            let _e1013 = reflected;
            let _e1014 = sourceBkgDim_11;
            let _e1015 = backgroundMode_5;
            let _e1016 = backgroundForReflection(_e1013, _e1014, _e1015);
            refDir = _e1016;
            let _e1018 = reflectiveColor;
            let _e1019 = refDir;
            let _e1024 = global.U[0];
            let _e1027 = refDir;
            let _e1038 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e1019.x / _e1024.x), _e1027.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1040 = refDir;
            let _e1042 = vec3(_e1040.z);
            reflectColor_2 = ((_e1018 * _e1038) * vec4<f32>(_e1042.x, _e1042.y, _e1042.z, 1f));
        }
    }
    let _e1049 = surfaceSmoothness_1;
    if (_e1049 < 100f) {
        {
            let _e1052 = lighting;
            if (_e1052 < 0.5f) {
                {
                    let _e1055 = lighting;
                    let _e1059 = surfaceSmoothness_1;
                    lighting = (pow((_e1055 * 2f), (100f / _e1059)) / 2f);
                }
            } else {
                {
                    let _e1064 = lighting;
                    let _e1070 = surfaceSmoothness_1;
                    lighting = ((pow(((_e1064 - 0.5f) * 2f), (0.01f * _e1070)) / 2f) + 0.5f);
                }
            }
        }
    }
    let _e1077 = specular_3;
    if (_e1077 != 0f) {
        {
            let _e1080 = lightDir;
            let _e1081 = normal;
            reflectLightDir = reflect(_e1080, _e1081);
            let _e1084 = dir_10;
            let _e1085 = reflectLightDir;
            let _e1091 = specular_3;
            spec = pow(clamp(dot(_e1084, _e1085), 0f, 1f), (10f - (_e1091 * 0.1f)));
        }
    }
    let _e1096 = shadows_1;
    shad = _e1096;
    let _e1098 = shadowing;
    let _e1101 = shad;
    let _e1105 = intensity_3;
    if (((_e1098 != 0f) && (_e1101 > 0f)) && (_e1105 != 0f)) {
        {
            let _e1109 = p;
            let _e1111 = step;
            p = (_e1109 - (2f * _e1111));
            let _e1114 = lightDir;
            let _e1115 = dk;
            lightStep = (_e1114 * _e1115);
            k1_ = 0f;
            let _e1119 = lightVec;
            k2_1 = length(_e1119);
            let _e1122 = lightDir;
            if (_e1122.x != 0f) {
                {
                    let _e1126 = lightDir;
                    s_3 = sign(_e1126.x);
                    let _e1130 = s_3;
                    let _e1132 = ratio_2;
                    let _e1134 = p;
                    let _e1137 = lightDir;
                    k3_3 = (((-(_e1130) * _e1132) - _e1134.x) / _e1137.x);
                    let _e1141 = s_3;
                    let _e1142 = ratio_2;
                    let _e1144 = p;
                    let _e1147 = lightDir;
                    k4_3 = (((_e1141 * _e1142) - _e1144.x) / _e1147.x);
                    let _e1151 = k4_3;
                    if (_e1151 > 0f) {
                        let _e1154 = k2_1;
                        let _e1155 = k4_3;
                        k2_1 = min(_e1154, _e1155);
                    }
                    let _e1157 = k3_3;
                    if (_e1157 > 0f) {
                        let _e1160 = k2_1;
                        let _e1161 = k3_3;
                        k2_1 = min(_e1160, _e1161);
                    }
                }
            }
            let _e1163 = lightDir;
            if (_e1163.y != 0f) {
                {
                    let _e1167 = lightDir;
                    s_4 = sign(_e1167.y);
                    let _e1171 = s_4;
                    let _e1173 = p;
                    let _e1176 = lightDir;
                    k3_4 = ((-(_e1171) - _e1173.y) / _e1176.y);
                    let _e1180 = s_4;
                    let _e1181 = p;
                    let _e1184 = lightDir;
                    k4_4 = ((_e1180 - _e1181.y) / _e1184.y);
                    let _e1188 = k4_4;
                    if (_e1188 > 0f) {
                        let _e1191 = k2_1;
                        let _e1192 = k4_4;
                        k2_1 = min(_e1191, _e1192);
                    }
                    let _e1194 = k3_4;
                    if (_e1194 > 0f) {
                        let _e1197 = k2_1;
                        let _e1198 = k3_4;
                        k2_1 = min(_e1197, _e1198);
                    }
                }
            }
            let _e1200 = maxZ;
            maxZ2_1 = (_e1200 + 0.0001f);
            let _e1204 = lightDir;
            if (_e1204.z != 0f) {
                {
                    let _e1208 = lightDir;
                    s_5 = sign(_e1208.z);
                    let _e1212 = s_5;
                    let _e1214 = maxZ2_1;
                    let _e1216 = p;
                    let _e1219 = lightDir;
                    k3_5 = (((-(_e1212) * _e1214) - _e1216.z) / _e1219.z);
                    let _e1223 = s_5;
                    let _e1224 = maxZ2_1;
                    let _e1226 = p;
                    let _e1229 = lightDir;
                    k4_5 = (((_e1223 * _e1224) - _e1226.z) / _e1229.z);
                    let _e1233 = k4_5;
                    if (_e1233 > 0f) {
                        let _e1236 = k2_1;
                        let _e1237 = k4_5;
                        k2_1 = min(_e1236, _e1237);
                    }
                    let _e1239 = k3_5;
                    if (_e1239 > 0f) {
                        let _e1242 = k2_1;
                        let _e1243 = k3_5;
                        k2_1 = min(_e1242, _e1243);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1249 = heightMap;
            if _e1249 {
                {
                    loop {
                        {
                            let _e1250 = dz;
                            prevDz = _e1250;
                            let _e1251 = h;
                            prevH = _e1251;
                            let _e1252 = intensity_3;
                            let _e1253 = p;
                            let _e1258 = global.U[0];
                            let _e1261 = p;
                            let _e1272 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e1253.x / _e1258.x), _e1261.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e1273 = height(_e1252, _e1272);
                            h = _e1273;
                            let _e1274 = p;
                            let _e1276 = h;
                            dz = (_e1274.z - _e1276);
                            let _e1278 = p;
                            let _e1279 = lightStep;
                            p = (_e1278 + _e1279);
                            let _e1281 = k;
                            let _e1282 = dk;
                            k = (_e1281 + _e1282);
                            let _e1284 = dz;
                            let _e1287 = k;
                            let _e1288 = k1_;
                            let _e1290 = dz;
                            let _e1292 = prevDz;
                            stop = ((_e1284 == 0f) || ((_e1287 != _e1288) && (sign(_e1290) == -(sign(_e1292)))));
                        }
                        let _e1298 = k;
                        let _e1299 = k2_1;
                        let _e1301 = stop;
                        if !(((_e1298 <= _e1299) && !(_e1301))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1305 = dz;
                            prevDz = _e1305;
                            let _e1306 = h;
                            prevH = _e1306;
                            let _e1307 = intensity_3;
                            let _e1308 = p;
                            let _e1313 = global.U[0];
                            let _e1316 = p;
                            let _e1327 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1308.x / _e1313.x), _e1316.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e1328 = height(_e1307, _e1327);
                            h = _e1328;
                            let _e1329 = p;
                            let _e1331 = h;
                            dz = (_e1329.z - _e1331);
                            let _e1333 = p;
                            let _e1334 = lightStep;
                            p = (_e1333 + _e1334);
                            let _e1336 = k;
                            let _e1337 = dk;
                            k = (_e1336 + _e1337);
                            let _e1339 = dz;
                            let _e1342 = k;
                            let _e1343 = k1_;
                            let _e1345 = dz;
                            let _e1347 = prevDz;
                            stop = ((_e1339 == 0f) || ((_e1342 != _e1343) && (sign(_e1345) == -(sign(_e1347)))));
                        }
                        let _e1353 = k;
                        let _e1354 = k2_1;
                        let _e1356 = stop;
                        if !(((_e1353 <= _e1354) && !(_e1356))) {
                            break;
                        }
                    }
                }
            }
            let _e1360 = stop;
            if _e1360 {
                {
                    let _e1362 = shadows_1;
                    let _e1364 = lighting;
                    lighting = min((1f - _e1362), _e1364);
                    spec = 0f;
                }
            }
        }
    }
    let _e1367 = surfaceColor;
    let _e1368 = reflectColor_2;
    let _e1369 = lighting;
    let _e1370 = spec;
    let _e1371 = ambientColor_3;
    let _e1372 = sourceColor_3;
    let _e1373 = gamma_3;
    let _e1374 = applyLighting(_e1367, _e1368, _e1369, _e1370, _e1371, _e1372, _e1373);
    color_3 = _e1374;
    let _e1375 = colorFog_1;
    if (_e1375.w != 0f) {
        {
            let _e1379 = cameraPos;
            let _e1380 = p;
            kFog = length((_e1379 - _e1380));
            let _e1386 = colorFog_1;
            nearDist = (2f * (1f - _e1386.w));
            let _e1392 = nearDist;
            farDist = (2f * _e1392);
            let _e1395 = nearDist;
            let _e1396 = farDist;
            let _e1397 = kFog;
            kFog = smoothstep(_e1395, _e1396, _e1397);
            let _e1399 = color_3;
            let _e1401 = color_3;
            let _e1403 = colorFog_1;
            let _e1405 = kFog;
            let _e1407 = mix(_e1401.xyz, _e1403.xyz, vec3(_e1405));
            color_3.x = _e1407.x;
            color_3.y = _e1407.y;
            color_3.z = _e1407.z;
        }
    }
    let _e1414 = color_3;
    return clamp(_e1414, vec4(0f), vec4(1f));
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
    let _e68 = global.U[9];
    let _e72 = global.U[10];
    let _e75 = global.U[11];
    let _e78 = global.U[12];
    let _e81 = global.U[13];
    let _e105 = global.U[4];
    let _e109 = global.U[5];
    let _e113 = global.U[6];
    let _e118 = global.U[7];
    let _e123 = global.U[14];
    let _e126 = global.U[15];
    let _e129 = global.U[16];
    let _e132 = global.U[17];
    let _e156 = global.U[18];
    let _e160 = global.U[19];
    let _e165 = global.U[20];
    let _e168 = global.U[21];
    let _e171 = global.U[22];
    let _e174 = global.U[23];
    let _e178 = global.U[24];
    let _e182 = global.U[25];
    let _e186 = global.U[26];
    let _e190 = global.U[27];
    let _e192 = quicksilver3D((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, mat4x4<f32>(vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w), vec4<f32>(_e78.x, _e78.y, _e78.z, _e78.w), vec4<f32>(_e81.x, _e81.y, _e81.z, _e81.w)), _e105.xy, _e109.xy, i32(_e113.x), i32(_e118.x), mat4x4<f32>(vec4<f32>(_e123.x, _e123.y, _e123.z, _e123.w), vec4<f32>(_e126.x, _e126.y, _e126.z, _e126.w), vec4<f32>(_e129.x, _e129.y, _e129.z, _e129.w), vec4<f32>(_e132.x, _e132.y, _e132.z, _e132.w)), _e156.x, i32(_e160.x), _e165, _e168, _e171, _e174.x, _e178.x, _e182.x, _e186.x, _e190.x);
    fragColor = _e192;
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
