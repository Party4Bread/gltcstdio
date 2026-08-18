struct Params {
    U: array<vec4<f32>, 26>,
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

fn applyLighting(baseColor: vec4<f32>, fromSource: f32, specular: f32, ambientColor: vec4<f32>, sourceColor: vec4<f32>, gamma: f32) -> vec4<f32> {
    var baseColor_1: vec4<f32>;
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
    fromSource_1 = fromSource;
    specular_1 = specular;
    ambientColor_1 = ambientColor;
    sourceColor_1 = sourceColor;
    gamma_1 = gamma;
    let _e20 = ambientColor_1;
    let _e22 = sourceColor_1;
    sumRGB = (_e20.xyz + _e22.xyz);
    let _e26 = sumRGB;
    let _e28 = sumRGB;
    let _e31 = sumRGB;
    maxLum = max(max(_e26.x, _e28.y), _e31.z);
    let _e35 = maxLum;
    if (_e35 == 0f) {
        return vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e43 = baseColor_1;
    let _e45 = ambientColor_1;
    let _e48 = baseColor_1;
    let _e50 = sourceColor_1;
    let _e53 = fromSource_1;
    let _e56 = sourceColor_1;
    let _e58 = specular_1;
    let _e61 = maxLum;
    color = ((((_e43.xyz * _e45.xyz) + ((_e48.xyz * _e50.xyz) * _e53)) + (_e56.xyz * _e58)) / vec3(_e61));
    let _e65 = color;
    let _e67 = color;
    let _e70 = color;
    lum = (((_e65.x + _e67.y) + _e70.z) / 3f);
    let _e76 = lum;
    let _e79 = gamma_1;
    if ((_e76 > 0f) && (_e79 != 0f)) {
        {
            let _e83 = lum;
            let _e85 = gamma_1;
            gammaCorrectedLum = pow(_e83, pow(1.02f, (-(_e85) * 100f)));
            let _e92 = color;
            let _e93 = gammaCorrectedLum;
            let _e95 = lum;
            color = ((_e92 * _e93) / vec3(_e95));
        }
    }
    let _e98 = color;
    let _e99 = baseColor_1;
    return clamp(vec4<f32>(_e98.x, _e98.y, _e98.z, _e99.w), vec4(0f), vec4(1f));
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

fn heightMap(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, lightSourceTransform: mat4x4<f32>, colorScheme: f32, sourceColor_2: vec4<f32>, ambientColor_2: vec4<f32>, colorFog: vec4<f32>, normalSmoothing: f32, surfaceSmoothness: f32, specular_2: f32, shadows: f32, gamma_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var lightSourceTransform_1: mat4x4<f32>;
    var colorScheme_1: f32;
    var sourceColor_3: vec4<f32>;
    var ambientColor_3: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var normalSmoothing_1: f32;
    var surfaceSmoothness_1: f32;
    var specular_3: f32;
    var shadows_1: f32;
    var gamma_3: f32;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir: vec3<f32>;
    var maxZ: f32;
    var ratio: f32;
    var dk: f32;
    var step: vec3<f32>;
    var heightMap_1: bool;
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
    var local: vec4<f32>;
    var local_1: vec4<f32>;
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
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var local_4: f32;
    var kk: f32;
    var hh: f32;
    var local_5: f32;
    var hRatio: f32;
    var darken: f32;
    var darken_1: f32;
    var kkk: f32;
    var col: vec4<f32>;
    var lightVec: vec3<f32>;
    var lightDir: vec3<f32>;
    var lighting: f32 = 1f;
    var spec: f32 = 0f;
    var shadowing: f32;
    var intersection: vec3<f32>;
    var deltaX: f32 = 0.002f;
    var deltaY: f32 = 0.002f;
    var dzdx: f32 = 0f;
    var dzdy: f32 = 0f;
    var maxNormalIter: i32 = 6i;
    var N: f32;
    var bx: f32;
    var local_6: f32;
    var sx: f32;
    var i: i32 = 0i;
    var deltaX_1: f32;
    var i_1: i32 = 0i;
    var deltaX_2: f32;
    var by: f32;
    var local_7: f32;
    var sy: f32;
    var i_2: i32 = 0i;
    var deltaY_1: f32;
    var i_3: i32 = 0i;
    var deltaY_2: f32;
    var unormal: vec3<f32>;
    var local_8: vec3<f32>;
    var normal: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var local_9: f32;
    var kFog: f32;
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
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    lightSourceTransform_1 = lightSourceTransform;
    colorScheme_1 = colorScheme;
    sourceColor_3 = sourceColor_2;
    ambientColor_3 = ambientColor_2;
    colorFog_1 = colorFog;
    normalSmoothing_1 = normalSmoothing;
    surfaceSmoothness_1 = surfaceSmoothness;
    specular_3 = specular_2;
    shadows_1 = shadows;
    gamma_3 = gamma_2;
    let _e55 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e55);
    let _e58 = m;
    let _e59 = cameraPos;
    cameraPos = (_e58 * vec4<f32>(_e59.x, _e59.y, _e59.z, 1f)).xyz;
    let _e67 = pos_1;
    let _e69 = D;
    let _e71 = pos_1;
    let _e73 = D;
    dir = vec3<f32>((_e67.x * _e69), (_e71.y * _e73), -1f);
    let _e79 = m;
    let _e89 = dir;
    dir = normalize((mat3x3<f32>(_e79[0].xyz, _e79[1].xyz, _e79[2].xyz) * _e89));
    let _e92 = intensity_3;
    maxZ = (abs(_e92) * 0.02f);
    let _e97 = sourceDim_1;
    let _e99 = sourceDim_1;
    ratio = (_e97.x / _e99.y);
    let _e104 = sourceDim_1;
    dk = (2f / _e104.y);
    let _e108 = dir;
    let _e109 = dk;
    step = (_e108 * _e109);
    let _e112 = sourceElevation_specified_1;
    heightMap_1 = (_e112 == 1i);
    let _e116 = lightSourceTransform_1;
    lightPos = (_e116 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e129 = dir;
    if (_e129.x != 0f) {
        {
            let _e133 = dir;
            s = sign(_e133.x);
            let _e137 = s;
            let _e139 = ratio;
            let _e141 = cameraPos;
            let _e144 = dir;
            k3_ = (((-(_e137) * _e139) - _e141.x) / _e144.x);
            let _e148 = s;
            let _e149 = ratio;
            let _e151 = cameraPos;
            let _e154 = dir;
            k4_ = (((_e148 * _e149) - _e151.x) / _e154.x);
            let _e158 = k1_;
            let _e159 = k3_;
            k1_ = max(_e158, _e159);
            let _e161 = k2_;
            let _e162 = k4_;
            k2_ = min(_e161, _e162);
        }
    }
    let _e164 = dir;
    if (_e164.y != 0f) {
        {
            let _e168 = dir;
            s_1 = sign(_e168.y);
            let _e172 = s_1;
            let _e174 = cameraPos;
            let _e177 = dir;
            k3_1 = ((-(_e172) - _e174.y) / _e177.y);
            let _e181 = s_1;
            let _e182 = cameraPos;
            let _e185 = dir;
            k4_1 = ((_e181 - _e182.y) / _e185.y);
            let _e189 = k1_;
            let _e190 = k3_1;
            k1_ = max(_e189, _e190);
            let _e192 = k2_;
            let _e193 = k4_1;
            k2_ = min(_e192, _e193);
        }
    }
    let _e195 = maxZ;
    maxZ2_ = (_e195 + 0.0001f);
    let _e199 = dir;
    if (_e199.z != 0f) {
        {
            let _e203 = dir;
            s_2 = sign(_e203.z);
            let _e207 = s_2;
            let _e209 = maxZ2_;
            let _e211 = cameraPos;
            let _e214 = dir;
            k3_2 = (((-(_e207) * _e209) - _e211.z) / _e214.z);
            let _e218 = s_2;
            let _e219 = maxZ2_;
            let _e221 = cameraPos;
            let _e224 = dir;
            k4_2 = (((_e218 * _e219) - _e221.z) / _e224.z);
            let _e228 = k1_;
            let _e229 = k3_2;
            k1_ = max(_e228, _e229);
            let _e231 = k2_;
            let _e232 = k4_2;
            k2_ = min(_e231, _e232);
        }
    }
    let _e234 = k1_;
    let _e235 = k2_;
    if (_e234 > _e235) {
        let _e237 = colorFog_1;
        if (_e237.w != 0f) {
            let _e241 = colorFog_1;
            let _e242 = _e241.xyz;
            local_1 = vec4<f32>(_e242.x, _e242.y, _e242.z, 1f);
        } else {
            let _e248 = sourceBkg_specified_1;
            if (_e248 == 1i) {
                let _e251 = pos_1;
                let _e255 = global.U[0];
                let _e258 = pos_1;
                let _e267 = _mirror_wrap(((vec2<f32>((_e251.x / _e255.x), _e258.y) / vec2(2f)) + vec2(0.5f)));
                let _e269 = textureSampleLevel(t_sourceBkg, samp, _e267, 0f);
                local = _e269;
            } else {
                local = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e276 = local;
            local_1 = _e276;
        }
        let _e278 = local_1;
        return _e278;
    }
    let _e279 = k1_;
    k = _e279;
    let _e281 = cameraPos;
    let _e282 = k;
    let _e283 = dir;
    p = (_e281 + (_e282 * _e283));
    let _e287 = backgroundColor;
    color_3 = _e287;
    let _e302 = k2_;
    let _e303 = dk;
    k2_ = (_e302 + _e303);
    let _e305 = heightMap_1;
    if _e305 {
        {
            loop {
                {
                    let _e306 = dz;
                    prevDz = _e306;
                    let _e307 = h;
                    prevH = _e307;
                    let _e308 = intensity_3;
                    let _e309 = p;
                    let _e314 = global.U[0];
                    let _e317 = p;
                    let _e327 = _mirror_wrap(((vec2<f32>((_e309.x / _e314.x), _e317.y) / vec2(2f)) + vec2(0.5f)));
                    let _e329 = textureSampleLevel(t_sourceElevation, samp, _e327, 0f);
                    let _e330 = height(_e308, _e329);
                    h = _e330;
                    let _e331 = p;
                    let _e333 = h;
                    dz = (_e331.z - _e333);
                    let _e335 = p;
                    let _e336 = step;
                    p = (_e335 + _e336);
                    let _e338 = k;
                    let _e339 = dk;
                    k = (_e338 + _e339);
                    let _e341 = dz;
                    let _e344 = k;
                    let _e345 = k1_;
                    let _e347 = dz;
                    let _e349 = prevDz;
                    stop = ((_e341 == 0f) || ((_e344 != _e345) && (sign(_e347) == -(sign(_e349)))));
                }
                let _e355 = k;
                let _e356 = k2_;
                let _e358 = stop;
                if !(((_e355 <= _e356) && !(_e358))) {
                    break;
                }
            }
            let _e362 = p;
            let _e363 = step;
            pp = (_e362 - _e363).xy;
            let _e367 = pp;
            let _e371 = global.U[0];
            let _e374 = pp;
            let _e383 = _mirror_wrap(((vec2<f32>((_e367.x / _e371.x), _e374.y) / vec2(2f)) + vec2(0.5f)));
            let _e385 = textureSampleLevel(t_source, samp, _e383, 0f);
            color_3 = _e385;
            let _e386 = pp;
            let _e387 = step;
            let _e393 = global.U[0];
            let _e396 = pp;
            let _e397 = step;
            let _e408 = _mirror_wrap(((vec2<f32>(((_e386 - _e387.xy).x / _e393.x), (_e396 - _e397.xy).y) / vec2(2f)) + vec2(0.5f)));
            let _e410 = textureSampleLevel(t_source, samp, _e408, 0f);
            prevColor = _e410;
        }
    } else {
        {
            loop {
                {
                    let _e411 = color_3;
                    prevColor = _e411;
                    let _e412 = dz;
                    prevDz = _e412;
                    let _e413 = h;
                    prevH = _e413;
                    let _e414 = p;
                    let _e419 = global.U[0];
                    let _e422 = p;
                    let _e432 = _mirror_wrap(((vec2<f32>((_e414.x / _e419.x), _e422.y) / vec2(2f)) + vec2(0.5f)));
                    let _e434 = textureSampleLevel(t_source, samp, _e432, 0f);
                    color_3 = _e434;
                    let _e435 = intensity_3;
                    let _e436 = color_3;
                    let _e437 = height(_e435, _e436);
                    h = _e437;
                    let _e438 = p;
                    let _e440 = h;
                    dz = (_e438.z - _e440);
                    let _e442 = p;
                    let _e443 = step;
                    p = (_e442 + _e443);
                    let _e445 = k;
                    let _e446 = dk;
                    k = (_e445 + _e446);
                    let _e448 = dz;
                    let _e451 = k;
                    let _e452 = k1_;
                    let _e454 = dz;
                    let _e456 = prevDz;
                    stop = ((_e448 == 0f) || ((_e451 != _e452) && (sign(_e454) == -(sign(_e456)))));
                }
                let _e462 = k;
                let _e463 = k2_;
                let _e465 = stop;
                if !(((_e462 <= _e463) && !(_e465))) {
                    break;
                }
            }
        }
    }
    let _e469 = stop;
    if !(_e469) {
        let _e471 = colorFog_1;
        if (_e471.w != 0f) {
            let _e475 = colorFog_1;
            let _e476 = _e475.xyz;
            local_3 = vec4<f32>(_e476.x, _e476.y, _e476.z, 1f);
        } else {
            let _e482 = sourceBkg_specified_1;
            if (_e482 == 1i) {
                let _e485 = pos_1;
                let _e489 = global.U[0];
                let _e492 = pos_1;
                let _e501 = _mirror_wrap(((vec2<f32>((_e485.x / _e489.x), _e492.y) / vec2(2f)) + vec2(0.5f)));
                let _e503 = textureSampleLevel(t_sourceBkg, samp, _e501, 0f);
                local_2 = _e503;
            } else {
                local_2 = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e510 = local_2;
            local_3 = _e510;
        }
        let _e512 = local_3;
        return _e512;
    }
    let _e513 = dz;
    let _e516 = k1_;
    let _e517 = dk;
    let _e519 = k2_;
    if ((_e513 == 0f) || ((_e516 + _e517) > _e519)) {
        local_4 = 1f;
    } else {
        let _e523 = prevDz;
        let _e525 = dz;
        let _e527 = prevDz;
        local_4 = (abs(_e523) / (abs(_e525) + abs(_e527)));
    }
    let _e532 = local_4;
    kk = _e532;
    let _e534 = prevH;
    let _e535 = h;
    let _e536 = kk;
    hh = mix(_e534, _e535, _e536);
    let _e539 = maxZ;
    if (_e539 == 0f) {
        local_5 = 1f;
    } else {
        let _e543 = hh;
        let _e544 = maxZ;
        local_5 = (_e543 / _e544);
    }
    let _e547 = local_5;
    hRatio = _e547;
    let _e549 = colorScheme_1;
    if (_e549 <= 50f) {
        {
            let _e553 = colorScheme_1;
            let _e556 = hRatio;
            darken = (1f + ((_e553 * 0.02f) * _e556));
            let _e560 = prevColor;
            let _e561 = color_3;
            let _e562 = kk;
            let _e565 = darken;
            let _e566 = darken;
            let _e567 = darken;
            color_3 = (mix(_e560, _e561, vec4(_e562)) * vec4<f32>(_e565, _e566, _e567, 1f));
        }
    } else {
        {
            let _e572 = hRatio;
            darken_1 = (1f + _e572);
            let _e575 = colorScheme_1;
            kkk = ((_e575 - 50f) * 0.02f);
            let _e581 = prevColor;
            let _e582 = color_3;
            let _e583 = kk;
            let _e586 = darken_1;
            let _e587 = darken_1;
            let _e588 = darken_1;
            col = (mix(_e581, _e582, vec4(_e583)) * vec4<f32>(_e586, _e587, _e588, 1f));
            let _e593 = col;
            let _e594 = darken_1;
            let _e597 = darken_1;
            let _e600 = darken_1;
            let _e605 = kkk;
            color_3 = mix(_e593, vec4<f32>((_e594 * 0.5f), (_e597 * 0.5f), (_e600 * 0.5f), 1f), vec4(_e605));
        }
    }
    let _e608 = lightPos;
    let _e609 = p;
    lightVec = (_e608 - _e609);
    let _e612 = lightVec;
    lightDir = normalize(_e612);
    let _e619 = sourceColor_3;
    let _e621 = sourceColor_3;
    let _e624 = sourceColor_3;
    shadowing = ((_e619.x + _e621.y) + _e624.z);
    let _e628 = shadowing;
    if (_e628 != 0f) {
        {
            let _e631 = p;
            intersection = _e631;
            let _e644 = normalSmoothing_1;
            N = (1f + ceil((_e644 / 20f)));
            let _e651 = normalSmoothing_1;
            bx = (0.0005f + (_e651 * 0.0001f));
            let _e656 = N;
            if (_e656 >= 2f) {
                let _e659 = bx;
                let _e660 = N;
                local_6 = (_e659 / (_e660 - 1f));
            } else {
                local_6 = 0f;
            }
            let _e666 = local_6;
            sx = _e666;
            let _e668 = heightMap_1;
            if !(_e668) {
                loop {
                    let _e672 = i;
                    let _e673 = N;
                    if !((_e672 < i32(_e673))) {
                        break;
                    }
                    {
                        let _e680 = bx;
                        let _e681 = i;
                        let _e683 = sx;
                        deltaX_1 = (_e680 + (f32(_e681) * _e683));
                        let _e687 = dzdx;
                        let _e688 = intensity_3;
                        let _e689 = intersection;
                        let _e691 = deltaX_1;
                        let _e693 = intersection;
                        let _e699 = global.U[0];
                        let _e702 = intersection;
                        let _e704 = deltaX_1;
                        let _e706 = intersection;
                        let _e717 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e689.x + _e691), _e693.y).x / _e699.x), vec2<f32>((_e702.x + _e704), _e706.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e719 = textureSampleLevel(t_source, samp, _e717, 0f);
                        let _e720 = height(_e688, _e719);
                        let _e721 = intensity_3;
                        let _e722 = intersection;
                        let _e724 = deltaX_1;
                        let _e726 = intersection;
                        let _e732 = global.U[0];
                        let _e735 = intersection;
                        let _e737 = deltaX_1;
                        let _e739 = intersection;
                        let _e750 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e722.x - _e724), _e726.y).x / _e732.x), vec2<f32>((_e735.x - _e737), _e739.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e752 = textureSampleLevel(t_source, samp, _e750, 0f);
                        let _e753 = height(_e721, _e752);
                        dzdx = (_e687 + (_e720 - _e753));
                    }
                    continuing {
                        let _e677 = i;
                        i = (_e677 + 1i);
                    }
                }
            } else {
                loop {
                    let _e758 = i_1;
                    let _e759 = N;
                    if !((_e758 < i32(_e759))) {
                        break;
                    }
                    {
                        let _e766 = bx;
                        let _e767 = i_1;
                        let _e769 = sx;
                        deltaX_2 = (_e766 + (f32(_e767) * _e769));
                        let _e773 = dzdx;
                        let _e774 = intensity_3;
                        let _e775 = intersection;
                        let _e777 = deltaX_2;
                        let _e779 = intersection;
                        let _e785 = global.U[0];
                        let _e788 = intersection;
                        let _e790 = deltaX_2;
                        let _e792 = intersection;
                        let _e803 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e775.x + _e777), _e779.y).x / _e785.x), vec2<f32>((_e788.x + _e790), _e792.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e805 = textureSampleLevel(t_sourceElevation, samp, _e803, 0f);
                        let _e806 = height(_e774, _e805);
                        let _e807 = intensity_3;
                        let _e808 = intersection;
                        let _e810 = deltaX_2;
                        let _e812 = intersection;
                        let _e818 = global.U[0];
                        let _e821 = intersection;
                        let _e823 = deltaX_2;
                        let _e825 = intersection;
                        let _e836 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e808.x - _e810), _e812.y).x / _e818.x), vec2<f32>((_e821.x - _e823), _e825.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e838 = textureSampleLevel(t_sourceElevation, samp, _e836, 0f);
                        let _e839 = height(_e807, _e838);
                        dzdx = (_e773 + (_e806 - _e839));
                    }
                    continuing {
                        let _e763 = i_1;
                        i_1 = (_e763 + 1i);
                    }
                }
            }
            let _e842 = dzdx;
            let _e843 = N;
            dzdx = (_e842 / _e843);
            let _e845 = bx;
            let _e846 = N;
            let _e851 = sx;
            deltaX = (_e845 + (((_e846 - 1f) / 2f) * _e851));
            let _e855 = normalSmoothing_1;
            by = (0.0005f + (_e855 * 0.0001f));
            let _e860 = N;
            if (_e860 >= 2f) {
                let _e863 = by;
                let _e864 = N;
                local_7 = (_e863 / (_e864 - 1f));
            } else {
                local_7 = 0f;
            }
            let _e870 = local_7;
            sy = _e870;
            let _e872 = heightMap_1;
            if !(_e872) {
                loop {
                    let _e876 = i_2;
                    let _e877 = N;
                    if !((_e876 < i32(_e877))) {
                        break;
                    }
                    {
                        let _e884 = by;
                        let _e885 = i_2;
                        let _e887 = sy;
                        deltaY_1 = (_e884 + (f32(_e885) * _e887));
                        let _e891 = intensity_3;
                        let _e892 = intersection;
                        let _e894 = intersection;
                        let _e896 = deltaY_1;
                        let _e902 = global.U[0];
                        let _e905 = intersection;
                        let _e907 = intersection;
                        let _e909 = deltaY_1;
                        let _e920 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e892.x, (_e894.y + _e896)).x / _e902.x), vec2<f32>(_e905.x, (_e907.y + _e909)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e922 = textureSampleLevel(t_source, samp, _e920, 0f);
                        let _e923 = height(_e891, _e922);
                        let _e924 = intensity_3;
                        let _e925 = intersection;
                        let _e927 = intersection;
                        let _e929 = deltaY_1;
                        let _e935 = global.U[0];
                        let _e938 = intersection;
                        let _e940 = intersection;
                        let _e942 = deltaY_1;
                        let _e953 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e925.x, (_e927.y - _e929)).x / _e935.x), vec2<f32>(_e938.x, (_e940.y - _e942)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e955 = textureSampleLevel(t_source, samp, _e953, 0f);
                        let _e956 = height(_e924, _e955);
                        dzdy = (_e923 - _e956);
                    }
                    continuing {
                        let _e881 = i_2;
                        i_2 = (_e881 + 1i);
                    }
                }
            } else {
                loop {
                    let _e960 = i_3;
                    let _e961 = N;
                    if !((_e960 < i32(_e961))) {
                        break;
                    }
                    {
                        let _e968 = by;
                        let _e969 = i_3;
                        let _e971 = sy;
                        deltaY_2 = (_e968 + (f32(_e969) * _e971));
                        let _e975 = intensity_3;
                        let _e976 = intersection;
                        let _e978 = intersection;
                        let _e980 = deltaY_2;
                        let _e986 = global.U[0];
                        let _e989 = intersection;
                        let _e991 = intersection;
                        let _e993 = deltaY_2;
                        let _e1004 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e976.x, (_e978.y + _e980)).x / _e986.x), vec2<f32>(_e989.x, (_e991.y + _e993)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e1006 = textureSampleLevel(t_sourceElevation, samp, _e1004, 0f);
                        let _e1007 = height(_e975, _e1006);
                        let _e1008 = intensity_3;
                        let _e1009 = intersection;
                        let _e1011 = intersection;
                        let _e1013 = deltaY_2;
                        let _e1019 = global.U[0];
                        let _e1022 = intersection;
                        let _e1024 = intersection;
                        let _e1026 = deltaY_2;
                        let _e1037 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e1009.x, (_e1011.y - _e1013)).x / _e1019.x), vec2<f32>(_e1022.x, (_e1024.y - _e1026)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e1039 = textureSampleLevel(t_sourceElevation, samp, _e1037, 0f);
                        let _e1040 = height(_e1008, _e1039);
                        dzdy = (_e1007 - _e1040);
                    }
                    continuing {
                        let _e965 = i_3;
                        i_3 = (_e965 + 1i);
                    }
                }
            }
            let _e1042 = dzdy;
            let _e1043 = N;
            dzdy = (_e1042 / _e1043);
            let _e1045 = by;
            let _e1046 = N;
            let _e1051 = sy;
            deltaY = (_e1045 + (((_e1046 - 1f) / 2f) * _e1051));
            let _e1056 = deltaY;
            let _e1058 = dzdx;
            let _e1062 = deltaX;
            let _e1064 = dzdy;
            let _e1066 = deltaX;
            let _e1067 = deltaY;
            unormal = vec3<f32>(((-2f * _e1056) * _e1058), ((-2f * _e1062) * _e1064), (_e1066 * _e1067));
            let _e1071 = unormal;
            let _e1075 = unormal;
            let _e1080 = unormal;
            if (((_e1071.x == 0f) && (_e1075.y == 0f)) && (_e1080.z == 0f)) {
                local_8 = vec3<f32>(0f, 0f, 1f);
            } else {
                let _e1089 = unormal;
                local_8 = normalize(_e1089);
            }
            let _e1092 = local_8;
            normal = _e1092;
            let _e1094 = lightDir;
            let _e1095 = normal;
            lighting = ((dot(_e1094, _e1095) + 1f) / 2f);
            let _e1101 = surfaceSmoothness_1;
            if (_e1101 < 100f) {
                {
                    let _e1104 = lighting;
                    if (_e1104 < 0.5f) {
                        let _e1107 = lighting;
                        let _e1111 = surfaceSmoothness_1;
                        lighting = (pow((_e1107 * 2f), (100f / _e1111)) / 2f);
                    } else {
                        let _e1116 = lighting;
                        let _e1122 = surfaceSmoothness_1;
                        lighting = ((pow(((_e1116 - 0.5f) * 2f), (0.01f * _e1122)) / 2f) + 0.5f);
                    }
                }
            }
            let _e1129 = specular_3;
            if (_e1129 != 0f) {
                {
                    let _e1132 = lightDir;
                    let _e1133 = normal;
                    reflectLightDir = reflect(_e1132, _e1133);
                    let _e1136 = specular_3;
                    if (_e1136 < 25f) {
                        let _e1139 = specular_3;
                        local_9 = (_e1139 * 0.04f);
                    } else {
                        local_9 = 1f;
                    }
                    let _e1144 = local_9;
                    let _e1145 = dir;
                    let _e1146 = reflectLightDir;
                    let _e1152 = specular_3;
                    spec = (_e1144 * pow(clamp(dot(_e1145, _e1146), 0f, 1f), (10f - (_e1152 * 0.1f))));
                }
            }
        }
    }
    let _e1158 = cameraPos;
    let _e1159 = p;
    kFog = length((_e1158 - _e1159));
    let _e1163 = shadows_1;
    shad = _e1163;
    let _e1165 = shadowing;
    let _e1168 = shad;
    let _e1172 = intensity_3;
    if (((_e1165 != 0f) && (_e1168 > 0f)) && (_e1172 != 0f)) {
        {
            let _e1176 = p;
            let _e1178 = step;
            p = (_e1176 - (2f * _e1178));
            let _e1181 = lightDir;
            let _e1182 = dk;
            lightStep = (_e1181 * _e1182);
            k1_ = 0f;
            let _e1186 = lightVec;
            k2_1 = length(_e1186);
            let _e1189 = lightDir;
            if (_e1189.x != 0f) {
                {
                    let _e1193 = lightDir;
                    s_3 = sign(_e1193.x);
                    let _e1197 = s_3;
                    let _e1199 = ratio;
                    let _e1201 = p;
                    let _e1204 = lightDir;
                    k3_3 = (((-(_e1197) * _e1199) - _e1201.x) / _e1204.x);
                    let _e1208 = s_3;
                    let _e1209 = ratio;
                    let _e1211 = p;
                    let _e1214 = lightDir;
                    k4_3 = (((_e1208 * _e1209) - _e1211.x) / _e1214.x);
                    let _e1218 = k4_3;
                    if (_e1218 > 0f) {
                        let _e1221 = k2_1;
                        let _e1222 = k4_3;
                        k2_1 = min(_e1221, _e1222);
                    }
                    let _e1224 = k3_3;
                    if (_e1224 > 0f) {
                        let _e1227 = k2_1;
                        let _e1228 = k3_3;
                        k2_1 = min(_e1227, _e1228);
                    }
                }
            }
            let _e1230 = lightDir;
            if (_e1230.y != 0f) {
                {
                    let _e1234 = lightDir;
                    s_4 = sign(_e1234.y);
                    let _e1238 = s_4;
                    let _e1240 = p;
                    let _e1243 = lightDir;
                    k3_4 = ((-(_e1238) - _e1240.y) / _e1243.y);
                    let _e1247 = s_4;
                    let _e1248 = p;
                    let _e1251 = lightDir;
                    k4_4 = ((_e1247 - _e1248.y) / _e1251.y);
                    let _e1255 = k4_4;
                    if (_e1255 > 0f) {
                        let _e1258 = k2_1;
                        let _e1259 = k4_4;
                        k2_1 = min(_e1258, _e1259);
                    }
                    let _e1261 = k3_4;
                    if (_e1261 > 0f) {
                        let _e1264 = k2_1;
                        let _e1265 = k3_4;
                        k2_1 = min(_e1264, _e1265);
                    }
                }
            }
            let _e1267 = maxZ;
            maxZ2_1 = (_e1267 + 0.0001f);
            let _e1271 = lightDir;
            if (_e1271.z != 0f) {
                {
                    let _e1275 = lightDir;
                    s_5 = sign(_e1275.z);
                    let _e1279 = s_5;
                    let _e1281 = maxZ2_1;
                    let _e1283 = p;
                    let _e1286 = lightDir;
                    k3_5 = (((-(_e1279) * _e1281) - _e1283.z) / _e1286.z);
                    let _e1290 = s_5;
                    let _e1291 = maxZ2_1;
                    let _e1293 = p;
                    let _e1296 = lightDir;
                    k4_5 = (((_e1290 * _e1291) - _e1293.z) / _e1296.z);
                    let _e1300 = k4_5;
                    if (_e1300 > 0f) {
                        let _e1303 = k2_1;
                        let _e1304 = k4_5;
                        k2_1 = min(_e1303, _e1304);
                    }
                    let _e1306 = k3_5;
                    if (_e1306 > 0f) {
                        let _e1309 = k2_1;
                        let _e1310 = k3_5;
                        k2_1 = min(_e1309, _e1310);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1316 = heightMap_1;
            if _e1316 {
                {
                    loop {
                        {
                            let _e1317 = dz;
                            prevDz = _e1317;
                            let _e1318 = h;
                            prevH = _e1318;
                            let _e1319 = intensity_3;
                            let _e1320 = p;
                            let _e1325 = global.U[0];
                            let _e1328 = p;
                            let _e1338 = _mirror_wrap(((vec2<f32>((_e1320.x / _e1325.x), _e1328.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1340 = textureSampleLevel(t_sourceElevation, samp, _e1338, 0f);
                            let _e1341 = height(_e1319, _e1340);
                            h = _e1341;
                            let _e1342 = p;
                            let _e1344 = h;
                            dz = (_e1342.z - _e1344);
                            let _e1346 = p;
                            let _e1347 = lightStep;
                            p = (_e1346 + _e1347);
                            let _e1349 = k;
                            let _e1350 = dk;
                            k = (_e1349 + _e1350);
                            let _e1352 = dz;
                            let _e1355 = k;
                            let _e1356 = k1_;
                            let _e1358 = dz;
                            let _e1360 = prevDz;
                            stop = ((_e1352 == 0f) || ((_e1355 != _e1356) && (sign(_e1358) == -(sign(_e1360)))));
                        }
                        let _e1366 = k;
                        let _e1367 = k2_1;
                        let _e1369 = stop;
                        if !(((_e1366 <= _e1367) && !(_e1369))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1373 = dz;
                            prevDz = _e1373;
                            let _e1374 = h;
                            prevH = _e1374;
                            let _e1375 = intensity_3;
                            let _e1376 = p;
                            let _e1381 = global.U[0];
                            let _e1384 = p;
                            let _e1394 = _mirror_wrap(((vec2<f32>((_e1376.x / _e1381.x), _e1384.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1396 = textureSampleLevel(t_source, samp, _e1394, 0f);
                            let _e1397 = height(_e1375, _e1396);
                            h = _e1397;
                            let _e1398 = p;
                            let _e1400 = h;
                            dz = (_e1398.z - _e1400);
                            let _e1402 = p;
                            let _e1403 = lightStep;
                            p = (_e1402 + _e1403);
                            let _e1405 = k;
                            let _e1406 = dk;
                            k = (_e1405 + _e1406);
                            let _e1408 = dz;
                            let _e1411 = k;
                            let _e1412 = k1_;
                            let _e1414 = dz;
                            let _e1416 = prevDz;
                            stop = ((_e1408 == 0f) || ((_e1411 != _e1412) && (sign(_e1414) == -(sign(_e1416)))));
                        }
                        let _e1422 = k;
                        let _e1423 = k2_1;
                        let _e1425 = stop;
                        if !(((_e1422 <= _e1423) && !(_e1425))) {
                            break;
                        }
                    }
                }
            }
            let _e1429 = stop;
            if _e1429 {
                {
                    let _e1431 = shadows_1;
                    let _e1433 = lighting;
                    lighting = min((1f - _e1431), _e1433);
                    spec = 0f;
                }
            }
        }
    }
    let _e1436 = color_3;
    let _e1437 = lighting;
    let _e1438 = spec;
    let _e1439 = ambientColor_3;
    let _e1440 = sourceColor_3;
    let _e1441 = gamma_3;
    let _e1442 = applyLighting(_e1436, _e1437, _e1438, _e1439, _e1440, _e1441);
    color_3 = _e1442;
    let _e1443 = colorFog_1;
    if (_e1443.w != 0f) {
        {
            let _e1449 = colorFog_1;
            nearDist = (2f * (1f - _e1449.w));
            let _e1455 = nearDist;
            farDist = (2f * _e1455);
            let _e1458 = nearDist;
            let _e1459 = farDist;
            let _e1460 = kFog;
            kFog = smoothstep(_e1458, _e1459, _e1460);
            let _e1462 = color_3;
            let _e1464 = color_3;
            let _e1466 = colorFog_1;
            let _e1468 = kFog;
            let _e1470 = mix(_e1464.xyz, _e1466.xyz, vec3(_e1468));
            color_3.x = _e1470.x;
            color_3.y = _e1470.y;
            color_3.z = _e1470.z;
        }
    }
    let _e1477 = color_3;
    return clamp(_e1477, vec4(0f), vec4(1f));
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
    let _e68 = global.U[8];
    let _e72 = global.U[9];
    let _e75 = global.U[10];
    let _e78 = global.U[11];
    let _e81 = global.U[12];
    let _e105 = global.U[4];
    let _e109 = global.U[5];
    let _e114 = global.U[6];
    let _e119 = global.U[13];
    let _e122 = global.U[14];
    let _e125 = global.U[15];
    let _e128 = global.U[16];
    let _e152 = global.U[17];
    let _e156 = global.U[18];
    let _e159 = global.U[19];
    let _e162 = global.U[20];
    let _e165 = global.U[21];
    let _e169 = global.U[22];
    let _e173 = global.U[23];
    let _e177 = global.U[24];
    let _e181 = global.U[25];
    let _e183 = heightMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, mat4x4<f32>(vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w), vec4<f32>(_e78.x, _e78.y, _e78.z, _e78.w), vec4<f32>(_e81.x, _e81.y, _e81.z, _e81.w)), _e105.xy, i32(_e109.x), i32(_e114.x), mat4x4<f32>(vec4<f32>(_e119.x, _e119.y, _e119.z, _e119.w), vec4<f32>(_e122.x, _e122.y, _e122.z, _e122.w), vec4<f32>(_e125.x, _e125.y, _e125.z, _e125.w), vec4<f32>(_e128.x, _e128.y, _e128.z, _e128.w)), _e152.x, _e156, _e159, _e162, _e165.x, _e169.x, _e173.x, _e177.x, _e181.x);
    fragColor = _e183;
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
