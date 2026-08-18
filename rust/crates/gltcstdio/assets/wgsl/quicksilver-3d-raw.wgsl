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
            let _e265 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e247.x / _e252.x), _e255.y) / vec2(2f)) + vec2(0.5f)));
            let _e266 = bkgDir;
            let _e268 = vec3(_e266.z);
            backgroundColor = (_e265 * vec4<f32>(_e268.x, _e268.y, _e268.z, 1f));
        }
    }
    let _e275 = k1_;
    let _e276 = k2_;
    if (_e275 > _e276) {
        let _e278 = backgroundColor;
        return _e278;
    }
    let _e279 = k1_;
    k = _e279;
    let _e281 = cameraPos;
    let _e282 = k;
    let _e283 = dir_10;
    p = (_e281 + (_e282 * _e283));
    let _e287 = backgroundColor;
    color_3 = _e287;
    let _e302 = heightMap;
    if _e302 {
        {
            loop {
                {
                    let _e303 = dz;
                    prevDz = _e303;
                    let _e304 = h;
                    prevH = _e304;
                    let _e305 = intensity_3;
                    let _e306 = p;
                    let _e311 = global.U[0];
                    let _e314 = p;
                    let _e324 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e306.x / _e311.x), _e314.y) / vec2(2f)) + vec2(0.5f)));
                    let _e325 = height(_e305, _e324);
                    h = _e325;
                    let _e326 = p;
                    let _e328 = h;
                    dz = (_e326.z - _e328);
                    let _e330 = p;
                    let _e331 = step;
                    p = (_e330 + _e331);
                    let _e333 = k;
                    let _e334 = dk;
                    k = (_e333 + _e334);
                    let _e336 = dz;
                    let _e339 = k;
                    let _e340 = k1_;
                    let _e342 = dz;
                    let _e344 = prevDz;
                    stop = ((_e336 == 0f) || ((_e339 != _e340) && (sign(_e342) == -(sign(_e344)))));
                }
                let _e350 = k;
                let _e351 = k2_;
                let _e353 = stop;
                if !(((_e350 <= _e351) && !(_e353))) {
                    break;
                }
            }
            let _e357 = p;
            let _e358 = step;
            pp = (_e357 - _e358).xy;
            let _e362 = pp;
            let _e366 = global.U[0];
            let _e369 = pp;
            let _e378 = textureSample(t_source, samp, ((vec2<f32>((_e362.x / _e366.x), _e369.y) / vec2(2f)) + vec2(0.5f)));
            color_3 = _e378;
            let _e379 = pp;
            let _e380 = step;
            let _e386 = global.U[0];
            let _e389 = pp;
            let _e390 = step;
            let _e401 = textureSample(t_source, samp, ((vec2<f32>(((_e379 - _e380.xy).x / _e386.x), (_e389 - _e390.xy).y) / vec2(2f)) + vec2(0.5f)));
            prevColor = _e401;
        }
    } else {
        {
            loop {
                {
                    let _e402 = color_3;
                    prevColor = _e402;
                    let _e403 = dz;
                    prevDz = _e403;
                    let _e404 = h;
                    prevH = _e404;
                    let _e405 = p;
                    let _e410 = global.U[0];
                    let _e413 = p;
                    let _e423 = textureSample(t_source, samp, ((vec2<f32>((_e405.x / _e410.x), _e413.y) / vec2(2f)) + vec2(0.5f)));
                    color_3 = _e423;
                    let _e424 = intensity_3;
                    let _e425 = color_3;
                    let _e426 = height(_e424, _e425);
                    h = _e426;
                    let _e427 = p;
                    let _e429 = h;
                    dz = (_e427.z - _e429);
                    let _e431 = p;
                    let _e432 = step;
                    p = (_e431 + _e432);
                    let _e434 = k;
                    let _e435 = dk;
                    k = (_e434 + _e435);
                    let _e437 = dz;
                    let _e440 = k;
                    let _e441 = k1_;
                    let _e443 = dz;
                    let _e445 = prevDz;
                    stop = ((_e437 == 0f) || ((_e440 != _e441) && (sign(_e443) == -(sign(_e445)))));
                }
                let _e451 = k;
                let _e452 = k2_;
                let _e454 = stop;
                if !(((_e451 <= _e452) && !(_e454))) {
                    break;
                }
            }
        }
    }
    let _e458 = stop;
    let _e459 = dz;
    let _e461 = dk;
    stop = (_e458 || (abs(_e459) < _e461));
    let _e464 = stop;
    if !(_e464) {
        let _e466 = backgroundColor;
        return _e466;
    }
    let _e467 = dz;
    let _e470 = k1_;
    let _e471 = dk;
    let _e473 = k2_;
    if ((_e467 == 0f) || ((_e470 + _e471) > _e473)) {
        local = 1f;
    } else {
        let _e477 = prevDz;
        let _e479 = dz;
        let _e481 = prevDz;
        local = (abs(_e477) / (abs(_e479) + abs(_e481)));
    }
    let _e486 = local;
    kk = _e486;
    let _e488 = prevH;
    let _e489 = h;
    let _e490 = kk;
    hh = mix(_e488, _e489, _e490);
    let _e493 = lightPos;
    let _e494 = p;
    lightVec = (_e493 - _e494);
    let _e497 = lightVec;
    lightDir = normalize(_e497);
    let _e504 = sourceColor_3;
    let _e506 = sourceColor_3;
    let _e509 = sourceColor_3;
    shadowing = ((_e504.x + _e506.y) + _e509.z);
    let _e513 = p;
    intersection = _e513;
    let _e516 = normalSmoothing_1;
    N = (1f + ceil((_e516 / 20f)));
    let _e523 = normalSmoothing_1;
    bx = (0.0005f + (_e523 * 0.0001f));
    let _e528 = N;
    if (_e528 >= 2f) {
        let _e531 = bx;
        let _e532 = N;
        local_1 = (_e531 / (_e532 - 1f));
    } else {
        local_1 = 0f;
    }
    let _e538 = local_1;
    sx = _e538;
    let _e542 = heightMap;
    if !(_e542) {
        {
            loop {
                let _e546 = i;
                let _e547 = N;
                if !((_e546 < i32(_e547))) {
                    break;
                }
                {
                    let _e554 = bx;
                    let _e555 = i;
                    let _e557 = sx;
                    deltaX = (_e554 + (f32(_e555) * _e557));
                    let _e561 = dzdx;
                    let _e562 = intensity_3;
                    let _e563 = intersection;
                    let _e565 = deltaX;
                    let _e567 = intersection;
                    let _e573 = global.U[0];
                    let _e576 = intersection;
                    let _e578 = deltaX;
                    let _e580 = intersection;
                    let _e591 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e563.x + _e565), _e567.y).x / _e573.x), vec2<f32>((_e576.x + _e578), _e580.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e592 = height(_e562, _e591);
                    let _e593 = intensity_3;
                    let _e594 = intersection;
                    let _e596 = deltaX;
                    let _e598 = intersection;
                    let _e604 = global.U[0];
                    let _e607 = intersection;
                    let _e609 = deltaX;
                    let _e611 = intersection;
                    let _e622 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e594.x - _e596), _e598.y).x / _e604.x), vec2<f32>((_e607.x - _e609), _e611.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e623 = height(_e593, _e622);
                    dzdx = (_e561 + (_e592 - _e623));
                }
                continuing {
                    let _e551 = i;
                    i = (_e551 + 1i);
                }
            }
        }
    } else {
        {
            loop {
                let _e628 = i_1;
                let _e629 = N;
                if !((_e628 < i32(_e629))) {
                    break;
                }
                {
                    let _e636 = bx;
                    let _e637 = i_1;
                    let _e639 = sx;
                    deltaX_1 = (_e636 + (f32(_e637) * _e639));
                    let _e643 = dzdx;
                    let _e644 = intensity_3;
                    let _e645 = intersection;
                    let _e647 = deltaX_1;
                    let _e649 = intersection;
                    let _e655 = global.U[0];
                    let _e658 = intersection;
                    let _e660 = deltaX_1;
                    let _e662 = intersection;
                    let _e673 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e645.x + _e647), _e649.y).x / _e655.x), vec2<f32>((_e658.x + _e660), _e662.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e674 = height(_e644, _e673);
                    let _e675 = intensity_3;
                    let _e676 = intersection;
                    let _e678 = deltaX_1;
                    let _e680 = intersection;
                    let _e686 = global.U[0];
                    let _e689 = intersection;
                    let _e691 = deltaX_1;
                    let _e693 = intersection;
                    let _e704 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e676.x - _e678), _e680.y).x / _e686.x), vec2<f32>((_e689.x - _e691), _e693.y).y) / vec2(2f)) + vec2(0.5f)));
                    let _e705 = height(_e675, _e704);
                    dzdx = (_e643 + (_e674 - _e705));
                }
                continuing {
                    let _e633 = i_1;
                    i_1 = (_e633 + 1i);
                }
            }
        }
    }
    let _e708 = dzdx;
    let _e709 = N;
    dzdx = (_e708 / _e709);
    let _e711 = bx;
    let _e712 = N;
    let _e717 = sx;
    deltaX_2 = (_e711 + (((_e712 - 1f) / 2f) * _e717));
    let _e722 = normalSmoothing_1;
    by = (0.0005f + (_e722 * 0.0001f));
    let _e727 = N;
    if (_e727 >= 2f) {
        let _e730 = by;
        let _e731 = N;
        local_2 = (_e730 / (_e731 - 1f));
    } else {
        local_2 = 0f;
    }
    let _e737 = local_2;
    sy = _e737;
    let _e741 = heightMap;
    if !(_e741) {
        {
            loop {
                let _e745 = i_2;
                let _e746 = N;
                if !((_e745 < i32(_e746))) {
                    break;
                }
                {
                    let _e753 = by;
                    let _e754 = i_2;
                    let _e756 = sy;
                    deltaY = (_e753 + (f32(_e754) * _e756));
                    let _e760 = dzdy;
                    let _e761 = intensity_3;
                    let _e762 = intersection;
                    let _e764 = intersection;
                    let _e766 = deltaY;
                    let _e772 = global.U[0];
                    let _e775 = intersection;
                    let _e777 = intersection;
                    let _e779 = deltaY;
                    let _e790 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e762.x, (_e764.y + _e766)).x / _e772.x), vec2<f32>(_e775.x, (_e777.y + _e779)).y) / vec2(2f)) + vec2(0.5f)));
                    let _e791 = height(_e761, _e790);
                    let _e792 = intensity_3;
                    let _e793 = intersection;
                    let _e795 = intersection;
                    let _e797 = deltaY;
                    let _e803 = global.U[0];
                    let _e806 = intersection;
                    let _e808 = intersection;
                    let _e810 = deltaY;
                    let _e821 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e793.x, (_e795.y - _e797)).x / _e803.x), vec2<f32>(_e806.x, (_e808.y - _e810)).y) / vec2(2f)) + vec2(0.5f)));
                    let _e822 = height(_e792, _e821);
                    dzdy = (_e760 + (_e791 - _e822));
                }
                continuing {
                    let _e750 = i_2;
                    i_2 = (_e750 + 1i);
                }
            }
        }
    } else {
        {
            loop {
                let _e827 = i_3;
                let _e828 = N;
                if !((_e827 < i32(_e828))) {
                    break;
                }
                {
                    let _e835 = by;
                    let _e836 = i_3;
                    let _e838 = sy;
                    deltaY_1 = (_e835 + (f32(_e836) * _e838));
                    let _e842 = dzdy;
                    let _e843 = intensity_3;
                    let _e844 = intersection;
                    let _e846 = intersection;
                    let _e848 = deltaY_1;
                    let _e854 = global.U[0];
                    let _e857 = intersection;
                    let _e859 = intersection;
                    let _e861 = deltaY_1;
                    let _e872 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e844.x, (_e846.y + _e848)).x / _e854.x), vec2<f32>(_e857.x, (_e859.y + _e861)).y) / vec2(2f)) + vec2(0.5f)));
                    let _e873 = height(_e843, _e872);
                    let _e874 = intensity_3;
                    let _e875 = intersection;
                    let _e877 = intersection;
                    let _e879 = deltaY_1;
                    let _e885 = global.U[0];
                    let _e888 = intersection;
                    let _e890 = intersection;
                    let _e892 = deltaY_1;
                    let _e903 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e875.x, (_e877.y - _e879)).x / _e885.x), vec2<f32>(_e888.x, (_e890.y - _e892)).y) / vec2(2f)) + vec2(0.5f)));
                    let _e904 = height(_e874, _e903);
                    dzdy = (_e842 + (_e873 - _e904));
                }
                continuing {
                    let _e832 = i_3;
                    i_3 = (_e832 + 1i);
                }
            }
        }
    }
    let _e907 = dzdy;
    let _e908 = N;
    dzdy = (_e907 / _e908);
    let _e910 = by;
    let _e911 = N;
    let _e916 = sy;
    deltaY_2 = (_e910 + (((_e911 - 1f) / 2f) * _e916));
    let _e922 = deltaY_2;
    let _e924 = dzdx;
    let _e928 = deltaX_2;
    let _e930 = dzdy;
    let _e932 = deltaX_2;
    let _e933 = deltaY_2;
    unormal = vec3<f32>(((-2f * _e922) * _e924), ((-2f * _e928) * _e930), (_e932 * _e933));
    let _e937 = unormal;
    let _e941 = unormal;
    let _e946 = unormal;
    if (((_e937.x == 0f) && (_e941.y == 0f)) && (_e946.z == 0f)) {
        local_3 = vec3<f32>(0f, 0f, 1f);
    } else {
        let _e955 = unormal;
        local_3 = normalize(_e955);
    }
    let _e958 = local_3;
    normal = _e958;
    let _e960 = lightDir;
    let _e961 = normal;
    lighting = ((dot(_e960, _e961) + 1f) / 2f);
    let _e967 = dir_10;
    let _e968 = normal;
    reflected = reflect(_e967, _e968);
    let _e971 = prevColor;
    let _e972 = color_3;
    let _e973 = kk;
    surfaceColor = mix(_e971, _e972, vec4(_e973));
    let _e983 = surfaceColor;
    let _e985 = colorScheme_1;
    reflectiveColor = mix(vec4<f32>(1f, 1f, 1f, 1f), (1.5f * _e983), vec4((_e985 * 0.01f)));
    let _e997 = sourceBkg_specified_1;
    if (_e997 == 1i) {
        {
            let _e1000 = reflected;
            let _e1001 = sourceBkgDim_11;
            let _e1002 = backgroundMode_5;
            let _e1003 = backgroundForReflection(_e1000, _e1001, _e1002);
            refDir = _e1003;
            let _e1005 = reflectiveColor;
            let _e1006 = refDir;
            let _e1011 = global.U[0];
            let _e1014 = refDir;
            let _e1024 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e1006.x / _e1011.x), _e1014.y) / vec2(2f)) + vec2(0.5f)));
            let _e1026 = refDir;
            let _e1028 = vec3(_e1026.z);
            reflectColor_2 = ((_e1005 * _e1024) * vec4<f32>(_e1028.x, _e1028.y, _e1028.z, 1f));
        }
    }
    let _e1035 = surfaceSmoothness_1;
    if (_e1035 < 100f) {
        {
            let _e1038 = lighting;
            if (_e1038 < 0.5f) {
                {
                    let _e1041 = lighting;
                    let _e1045 = surfaceSmoothness_1;
                    lighting = (pow((_e1041 * 2f), (100f / _e1045)) / 2f);
                }
            } else {
                {
                    let _e1050 = lighting;
                    let _e1056 = surfaceSmoothness_1;
                    lighting = ((pow(((_e1050 - 0.5f) * 2f), (0.01f * _e1056)) / 2f) + 0.5f);
                }
            }
        }
    }
    let _e1063 = specular_3;
    if (_e1063 != 0f) {
        {
            let _e1066 = lightDir;
            let _e1067 = normal;
            reflectLightDir = reflect(_e1066, _e1067);
            let _e1070 = dir_10;
            let _e1071 = reflectLightDir;
            let _e1077 = specular_3;
            spec = pow(clamp(dot(_e1070, _e1071), 0f, 1f), (10f - (_e1077 * 0.1f)));
        }
    }
    let _e1082 = shadows_1;
    shad = _e1082;
    let _e1084 = shadowing;
    let _e1087 = shad;
    let _e1091 = intensity_3;
    if (((_e1084 != 0f) && (_e1087 > 0f)) && (_e1091 != 0f)) {
        {
            let _e1095 = p;
            let _e1097 = step;
            p = (_e1095 - (2f * _e1097));
            let _e1100 = lightDir;
            let _e1101 = dk;
            lightStep = (_e1100 * _e1101);
            k1_ = 0f;
            let _e1105 = lightVec;
            k2_1 = length(_e1105);
            let _e1108 = lightDir;
            if (_e1108.x != 0f) {
                {
                    let _e1112 = lightDir;
                    s_3 = sign(_e1112.x);
                    let _e1116 = s_3;
                    let _e1118 = ratio_2;
                    let _e1120 = p;
                    let _e1123 = lightDir;
                    k3_3 = (((-(_e1116) * _e1118) - _e1120.x) / _e1123.x);
                    let _e1127 = s_3;
                    let _e1128 = ratio_2;
                    let _e1130 = p;
                    let _e1133 = lightDir;
                    k4_3 = (((_e1127 * _e1128) - _e1130.x) / _e1133.x);
                    let _e1137 = k4_3;
                    if (_e1137 > 0f) {
                        let _e1140 = k2_1;
                        let _e1141 = k4_3;
                        k2_1 = min(_e1140, _e1141);
                    }
                    let _e1143 = k3_3;
                    if (_e1143 > 0f) {
                        let _e1146 = k2_1;
                        let _e1147 = k3_3;
                        k2_1 = min(_e1146, _e1147);
                    }
                }
            }
            let _e1149 = lightDir;
            if (_e1149.y != 0f) {
                {
                    let _e1153 = lightDir;
                    s_4 = sign(_e1153.y);
                    let _e1157 = s_4;
                    let _e1159 = p;
                    let _e1162 = lightDir;
                    k3_4 = ((-(_e1157) - _e1159.y) / _e1162.y);
                    let _e1166 = s_4;
                    let _e1167 = p;
                    let _e1170 = lightDir;
                    k4_4 = ((_e1166 - _e1167.y) / _e1170.y);
                    let _e1174 = k4_4;
                    if (_e1174 > 0f) {
                        let _e1177 = k2_1;
                        let _e1178 = k4_4;
                        k2_1 = min(_e1177, _e1178);
                    }
                    let _e1180 = k3_4;
                    if (_e1180 > 0f) {
                        let _e1183 = k2_1;
                        let _e1184 = k3_4;
                        k2_1 = min(_e1183, _e1184);
                    }
                }
            }
            let _e1186 = maxZ;
            maxZ2_1 = (_e1186 + 0.0001f);
            let _e1190 = lightDir;
            if (_e1190.z != 0f) {
                {
                    let _e1194 = lightDir;
                    s_5 = sign(_e1194.z);
                    let _e1198 = s_5;
                    let _e1200 = maxZ2_1;
                    let _e1202 = p;
                    let _e1205 = lightDir;
                    k3_5 = (((-(_e1198) * _e1200) - _e1202.z) / _e1205.z);
                    let _e1209 = s_5;
                    let _e1210 = maxZ2_1;
                    let _e1212 = p;
                    let _e1215 = lightDir;
                    k4_5 = (((_e1209 * _e1210) - _e1212.z) / _e1215.z);
                    let _e1219 = k4_5;
                    if (_e1219 > 0f) {
                        let _e1222 = k2_1;
                        let _e1223 = k4_5;
                        k2_1 = min(_e1222, _e1223);
                    }
                    let _e1225 = k3_5;
                    if (_e1225 > 0f) {
                        let _e1228 = k2_1;
                        let _e1229 = k3_5;
                        k2_1 = min(_e1228, _e1229);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1235 = heightMap;
            if _e1235 {
                {
                    loop {
                        {
                            let _e1236 = dz;
                            prevDz = _e1236;
                            let _e1237 = h;
                            prevH = _e1237;
                            let _e1238 = intensity_3;
                            let _e1239 = p;
                            let _e1244 = global.U[0];
                            let _e1247 = p;
                            let _e1257 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e1239.x / _e1244.x), _e1247.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1258 = height(_e1238, _e1257);
                            h = _e1258;
                            let _e1259 = p;
                            let _e1261 = h;
                            dz = (_e1259.z - _e1261);
                            let _e1263 = p;
                            let _e1264 = lightStep;
                            p = (_e1263 + _e1264);
                            let _e1266 = k;
                            let _e1267 = dk;
                            k = (_e1266 + _e1267);
                            let _e1269 = dz;
                            let _e1272 = k;
                            let _e1273 = k1_;
                            let _e1275 = dz;
                            let _e1277 = prevDz;
                            stop = ((_e1269 == 0f) || ((_e1272 != _e1273) && (sign(_e1275) == -(sign(_e1277)))));
                        }
                        let _e1283 = k;
                        let _e1284 = k2_1;
                        let _e1286 = stop;
                        if !(((_e1283 <= _e1284) && !(_e1286))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1290 = dz;
                            prevDz = _e1290;
                            let _e1291 = h;
                            prevH = _e1291;
                            let _e1292 = intensity_3;
                            let _e1293 = p;
                            let _e1298 = global.U[0];
                            let _e1301 = p;
                            let _e1311 = textureSample(t_source, samp, ((vec2<f32>((_e1293.x / _e1298.x), _e1301.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1312 = height(_e1292, _e1311);
                            h = _e1312;
                            let _e1313 = p;
                            let _e1315 = h;
                            dz = (_e1313.z - _e1315);
                            let _e1317 = p;
                            let _e1318 = lightStep;
                            p = (_e1317 + _e1318);
                            let _e1320 = k;
                            let _e1321 = dk;
                            k = (_e1320 + _e1321);
                            let _e1323 = dz;
                            let _e1326 = k;
                            let _e1327 = k1_;
                            let _e1329 = dz;
                            let _e1331 = prevDz;
                            stop = ((_e1323 == 0f) || ((_e1326 != _e1327) && (sign(_e1329) == -(sign(_e1331)))));
                        }
                        let _e1337 = k;
                        let _e1338 = k2_1;
                        let _e1340 = stop;
                        if !(((_e1337 <= _e1338) && !(_e1340))) {
                            break;
                        }
                    }
                }
            }
            let _e1344 = stop;
            if _e1344 {
                {
                    let _e1346 = shadows_1;
                    let _e1348 = lighting;
                    lighting = min((1f - _e1346), _e1348);
                    spec = 0f;
                }
            }
        }
    }
    let _e1351 = surfaceColor;
    let _e1352 = reflectColor_2;
    let _e1353 = lighting;
    let _e1354 = spec;
    let _e1355 = ambientColor_3;
    let _e1356 = sourceColor_3;
    let _e1357 = gamma_3;
    let _e1358 = applyLighting(_e1351, _e1352, _e1353, _e1354, _e1355, _e1356, _e1357);
    color_3 = _e1358;
    let _e1359 = colorFog_1;
    if (_e1359.w != 0f) {
        {
            let _e1363 = cameraPos;
            let _e1364 = p;
            kFog = length((_e1363 - _e1364));
            let _e1370 = colorFog_1;
            nearDist = (2f * (1f - _e1370.w));
            let _e1376 = nearDist;
            farDist = (2f * _e1376);
            let _e1379 = nearDist;
            let _e1380 = farDist;
            let _e1381 = kFog;
            kFog = smoothstep(_e1379, _e1380, _e1381);
            let _e1383 = color_3;
            let _e1385 = color_3;
            let _e1387 = colorFog_1;
            let _e1389 = kFog;
            let _e1391 = mix(_e1385.xyz, _e1387.xyz, vec3(_e1389));
            color_3.x = _e1391.x;
            color_3.y = _e1391.y;
            color_3.z = _e1391.z;
        }
    }
    let _e1398 = color_3;
    return clamp(_e1398, vec4(0f), vec4(1f));
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
