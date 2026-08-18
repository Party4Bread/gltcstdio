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
                let _e268 = textureSample(t_sourceBkg, samp, _e267);
                local = _e268;
            } else {
                local = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e275 = local;
            local_1 = _e275;
        }
        let _e277 = local_1;
        return _e277;
    }
    let _e278 = k1_;
    k = _e278;
    let _e280 = cameraPos;
    let _e281 = k;
    let _e282 = dir;
    p = (_e280 + (_e281 * _e282));
    let _e286 = backgroundColor;
    color_3 = _e286;
    let _e301 = k2_;
    let _e302 = dk;
    k2_ = (_e301 + _e302);
    let _e304 = heightMap_1;
    if _e304 {
        {
            loop {
                {
                    let _e305 = dz;
                    prevDz = _e305;
                    let _e306 = h;
                    prevH = _e306;
                    let _e307 = intensity_3;
                    let _e308 = p;
                    let _e313 = global.U[0];
                    let _e316 = p;
                    let _e326 = _mirror_wrap(((vec2<f32>((_e308.x / _e313.x), _e316.y) / vec2(2f)) + vec2(0.5f)));
                    let _e327 = textureSample(t_sourceElevation, samp, _e326);
                    let _e328 = height(_e307, _e327);
                    h = _e328;
                    let _e329 = p;
                    let _e331 = h;
                    dz = (_e329.z - _e331);
                    let _e333 = p;
                    let _e334 = step;
                    p = (_e333 + _e334);
                    let _e336 = k;
                    let _e337 = dk;
                    k = (_e336 + _e337);
                    let _e339 = dz;
                    let _e342 = k;
                    let _e343 = k1_;
                    let _e345 = dz;
                    let _e347 = prevDz;
                    stop = ((_e339 == 0f) || ((_e342 != _e343) && (sign(_e345) == -(sign(_e347)))));
                }
                let _e353 = k;
                let _e354 = k2_;
                let _e356 = stop;
                if !(((_e353 <= _e354) && !(_e356))) {
                    break;
                }
            }
            let _e360 = p;
            let _e361 = step;
            pp = (_e360 - _e361).xy;
            let _e365 = pp;
            let _e369 = global.U[0];
            let _e372 = pp;
            let _e381 = _mirror_wrap(((vec2<f32>((_e365.x / _e369.x), _e372.y) / vec2(2f)) + vec2(0.5f)));
            let _e382 = textureSample(t_source, samp, _e381);
            color_3 = _e382;
            let _e383 = pp;
            let _e384 = step;
            let _e390 = global.U[0];
            let _e393 = pp;
            let _e394 = step;
            let _e405 = _mirror_wrap(((vec2<f32>(((_e383 - _e384.xy).x / _e390.x), (_e393 - _e394.xy).y) / vec2(2f)) + vec2(0.5f)));
            let _e406 = textureSample(t_source, samp, _e405);
            prevColor = _e406;
        }
    } else {
        {
            loop {
                {
                    let _e407 = color_3;
                    prevColor = _e407;
                    let _e408 = dz;
                    prevDz = _e408;
                    let _e409 = h;
                    prevH = _e409;
                    let _e410 = p;
                    let _e415 = global.U[0];
                    let _e418 = p;
                    let _e428 = _mirror_wrap(((vec2<f32>((_e410.x / _e415.x), _e418.y) / vec2(2f)) + vec2(0.5f)));
                    let _e429 = textureSample(t_source, samp, _e428);
                    color_3 = _e429;
                    let _e430 = intensity_3;
                    let _e431 = color_3;
                    let _e432 = height(_e430, _e431);
                    h = _e432;
                    let _e433 = p;
                    let _e435 = h;
                    dz = (_e433.z - _e435);
                    let _e437 = p;
                    let _e438 = step;
                    p = (_e437 + _e438);
                    let _e440 = k;
                    let _e441 = dk;
                    k = (_e440 + _e441);
                    let _e443 = dz;
                    let _e446 = k;
                    let _e447 = k1_;
                    let _e449 = dz;
                    let _e451 = prevDz;
                    stop = ((_e443 == 0f) || ((_e446 != _e447) && (sign(_e449) == -(sign(_e451)))));
                }
                let _e457 = k;
                let _e458 = k2_;
                let _e460 = stop;
                if !(((_e457 <= _e458) && !(_e460))) {
                    break;
                }
            }
        }
    }
    let _e464 = stop;
    if !(_e464) {
        let _e466 = colorFog_1;
        if (_e466.w != 0f) {
            let _e470 = colorFog_1;
            let _e471 = _e470.xyz;
            local_3 = vec4<f32>(_e471.x, _e471.y, _e471.z, 1f);
        } else {
            let _e477 = sourceBkg_specified_1;
            if (_e477 == 1i) {
                let _e480 = pos_1;
                let _e484 = global.U[0];
                let _e487 = pos_1;
                let _e496 = _mirror_wrap(((vec2<f32>((_e480.x / _e484.x), _e487.y) / vec2(2f)) + vec2(0.5f)));
                let _e497 = textureSample(t_sourceBkg, samp, _e496);
                local_2 = _e497;
            } else {
                local_2 = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e504 = local_2;
            local_3 = _e504;
        }
        let _e506 = local_3;
        return _e506;
    }
    let _e507 = dz;
    let _e510 = k1_;
    let _e511 = dk;
    let _e513 = k2_;
    if ((_e507 == 0f) || ((_e510 + _e511) > _e513)) {
        local_4 = 1f;
    } else {
        let _e517 = prevDz;
        let _e519 = dz;
        let _e521 = prevDz;
        local_4 = (abs(_e517) / (abs(_e519) + abs(_e521)));
    }
    let _e526 = local_4;
    kk = _e526;
    let _e528 = prevH;
    let _e529 = h;
    let _e530 = kk;
    hh = mix(_e528, _e529, _e530);
    let _e533 = maxZ;
    if (_e533 == 0f) {
        local_5 = 1f;
    } else {
        let _e537 = hh;
        let _e538 = maxZ;
        local_5 = (_e537 / _e538);
    }
    let _e541 = local_5;
    hRatio = _e541;
    let _e543 = colorScheme_1;
    if (_e543 <= 50f) {
        {
            let _e547 = colorScheme_1;
            let _e550 = hRatio;
            darken = (1f + ((_e547 * 0.02f) * _e550));
            let _e554 = prevColor;
            let _e555 = color_3;
            let _e556 = kk;
            let _e559 = darken;
            let _e560 = darken;
            let _e561 = darken;
            color_3 = (mix(_e554, _e555, vec4(_e556)) * vec4<f32>(_e559, _e560, _e561, 1f));
        }
    } else {
        {
            let _e566 = hRatio;
            darken_1 = (1f + _e566);
            let _e569 = colorScheme_1;
            kkk = ((_e569 - 50f) * 0.02f);
            let _e575 = prevColor;
            let _e576 = color_3;
            let _e577 = kk;
            let _e580 = darken_1;
            let _e581 = darken_1;
            let _e582 = darken_1;
            col = (mix(_e575, _e576, vec4(_e577)) * vec4<f32>(_e580, _e581, _e582, 1f));
            let _e587 = col;
            let _e588 = darken_1;
            let _e591 = darken_1;
            let _e594 = darken_1;
            let _e599 = kkk;
            color_3 = mix(_e587, vec4<f32>((_e588 * 0.5f), (_e591 * 0.5f), (_e594 * 0.5f), 1f), vec4(_e599));
        }
    }
    let _e602 = lightPos;
    let _e603 = p;
    lightVec = (_e602 - _e603);
    let _e606 = lightVec;
    lightDir = normalize(_e606);
    let _e613 = sourceColor_3;
    let _e615 = sourceColor_3;
    let _e618 = sourceColor_3;
    shadowing = ((_e613.x + _e615.y) + _e618.z);
    let _e622 = shadowing;
    if (_e622 != 0f) {
        {
            let _e625 = p;
            intersection = _e625;
            let _e638 = normalSmoothing_1;
            N = (1f + ceil((_e638 / 20f)));
            let _e645 = normalSmoothing_1;
            bx = (0.0005f + (_e645 * 0.0001f));
            let _e650 = N;
            if (_e650 >= 2f) {
                let _e653 = bx;
                let _e654 = N;
                local_6 = (_e653 / (_e654 - 1f));
            } else {
                local_6 = 0f;
            }
            let _e660 = local_6;
            sx = _e660;
            let _e662 = heightMap_1;
            if !(_e662) {
                loop {
                    let _e666 = i;
                    let _e667 = N;
                    if !((_e666 < i32(_e667))) {
                        break;
                    }
                    {
                        let _e674 = bx;
                        let _e675 = i;
                        let _e677 = sx;
                        deltaX_1 = (_e674 + (f32(_e675) * _e677));
                        let _e681 = dzdx;
                        let _e682 = intensity_3;
                        let _e683 = intersection;
                        let _e685 = deltaX_1;
                        let _e687 = intersection;
                        let _e693 = global.U[0];
                        let _e696 = intersection;
                        let _e698 = deltaX_1;
                        let _e700 = intersection;
                        let _e711 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e683.x + _e685), _e687.y).x / _e693.x), vec2<f32>((_e696.x + _e698), _e700.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e712 = textureSample(t_source, samp, _e711);
                        let _e713 = height(_e682, _e712);
                        let _e714 = intensity_3;
                        let _e715 = intersection;
                        let _e717 = deltaX_1;
                        let _e719 = intersection;
                        let _e725 = global.U[0];
                        let _e728 = intersection;
                        let _e730 = deltaX_1;
                        let _e732 = intersection;
                        let _e743 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e715.x - _e717), _e719.y).x / _e725.x), vec2<f32>((_e728.x - _e730), _e732.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e744 = textureSample(t_source, samp, _e743);
                        let _e745 = height(_e714, _e744);
                        dzdx = (_e681 + (_e713 - _e745));
                    }
                    continuing {
                        let _e671 = i;
                        i = (_e671 + 1i);
                    }
                }
            } else {
                loop {
                    let _e750 = i_1;
                    let _e751 = N;
                    if !((_e750 < i32(_e751))) {
                        break;
                    }
                    {
                        let _e758 = bx;
                        let _e759 = i_1;
                        let _e761 = sx;
                        deltaX_2 = (_e758 + (f32(_e759) * _e761));
                        let _e765 = dzdx;
                        let _e766 = intensity_3;
                        let _e767 = intersection;
                        let _e769 = deltaX_2;
                        let _e771 = intersection;
                        let _e777 = global.U[0];
                        let _e780 = intersection;
                        let _e782 = deltaX_2;
                        let _e784 = intersection;
                        let _e795 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e767.x + _e769), _e771.y).x / _e777.x), vec2<f32>((_e780.x + _e782), _e784.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e796 = textureSample(t_sourceElevation, samp, _e795);
                        let _e797 = height(_e766, _e796);
                        let _e798 = intensity_3;
                        let _e799 = intersection;
                        let _e801 = deltaX_2;
                        let _e803 = intersection;
                        let _e809 = global.U[0];
                        let _e812 = intersection;
                        let _e814 = deltaX_2;
                        let _e816 = intersection;
                        let _e827 = _mirror_wrap(((vec2<f32>((vec2<f32>((_e799.x - _e801), _e803.y).x / _e809.x), vec2<f32>((_e812.x - _e814), _e816.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e828 = textureSample(t_sourceElevation, samp, _e827);
                        let _e829 = height(_e798, _e828);
                        dzdx = (_e765 + (_e797 - _e829));
                    }
                    continuing {
                        let _e755 = i_1;
                        i_1 = (_e755 + 1i);
                    }
                }
            }
            let _e832 = dzdx;
            let _e833 = N;
            dzdx = (_e832 / _e833);
            let _e835 = bx;
            let _e836 = N;
            let _e841 = sx;
            deltaX = (_e835 + (((_e836 - 1f) / 2f) * _e841));
            let _e845 = normalSmoothing_1;
            by = (0.0005f + (_e845 * 0.0001f));
            let _e850 = N;
            if (_e850 >= 2f) {
                let _e853 = by;
                let _e854 = N;
                local_7 = (_e853 / (_e854 - 1f));
            } else {
                local_7 = 0f;
            }
            let _e860 = local_7;
            sy = _e860;
            let _e862 = heightMap_1;
            if !(_e862) {
                loop {
                    let _e866 = i_2;
                    let _e867 = N;
                    if !((_e866 < i32(_e867))) {
                        break;
                    }
                    {
                        let _e874 = by;
                        let _e875 = i_2;
                        let _e877 = sy;
                        deltaY_1 = (_e874 + (f32(_e875) * _e877));
                        let _e881 = intensity_3;
                        let _e882 = intersection;
                        let _e884 = intersection;
                        let _e886 = deltaY_1;
                        let _e892 = global.U[0];
                        let _e895 = intersection;
                        let _e897 = intersection;
                        let _e899 = deltaY_1;
                        let _e910 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e882.x, (_e884.y + _e886)).x / _e892.x), vec2<f32>(_e895.x, (_e897.y + _e899)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e911 = textureSample(t_source, samp, _e910);
                        let _e912 = height(_e881, _e911);
                        let _e913 = intensity_3;
                        let _e914 = intersection;
                        let _e916 = intersection;
                        let _e918 = deltaY_1;
                        let _e924 = global.U[0];
                        let _e927 = intersection;
                        let _e929 = intersection;
                        let _e931 = deltaY_1;
                        let _e942 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e914.x, (_e916.y - _e918)).x / _e924.x), vec2<f32>(_e927.x, (_e929.y - _e931)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e943 = textureSample(t_source, samp, _e942);
                        let _e944 = height(_e913, _e943);
                        dzdy = (_e912 - _e944);
                    }
                    continuing {
                        let _e871 = i_2;
                        i_2 = (_e871 + 1i);
                    }
                }
            } else {
                loop {
                    let _e948 = i_3;
                    let _e949 = N;
                    if !((_e948 < i32(_e949))) {
                        break;
                    }
                    {
                        let _e956 = by;
                        let _e957 = i_3;
                        let _e959 = sy;
                        deltaY_2 = (_e956 + (f32(_e957) * _e959));
                        let _e963 = intensity_3;
                        let _e964 = intersection;
                        let _e966 = intersection;
                        let _e968 = deltaY_2;
                        let _e974 = global.U[0];
                        let _e977 = intersection;
                        let _e979 = intersection;
                        let _e981 = deltaY_2;
                        let _e992 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e964.x, (_e966.y + _e968)).x / _e974.x), vec2<f32>(_e977.x, (_e979.y + _e981)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e993 = textureSample(t_sourceElevation, samp, _e992);
                        let _e994 = height(_e963, _e993);
                        let _e995 = intensity_3;
                        let _e996 = intersection;
                        let _e998 = intersection;
                        let _e1000 = deltaY_2;
                        let _e1006 = global.U[0];
                        let _e1009 = intersection;
                        let _e1011 = intersection;
                        let _e1013 = deltaY_2;
                        let _e1024 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e996.x, (_e998.y - _e1000)).x / _e1006.x), vec2<f32>(_e1009.x, (_e1011.y - _e1013)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e1025 = textureSample(t_sourceElevation, samp, _e1024);
                        let _e1026 = height(_e995, _e1025);
                        dzdy = (_e994 - _e1026);
                    }
                    continuing {
                        let _e953 = i_3;
                        i_3 = (_e953 + 1i);
                    }
                }
            }
            let _e1028 = dzdy;
            let _e1029 = N;
            dzdy = (_e1028 / _e1029);
            let _e1031 = by;
            let _e1032 = N;
            let _e1037 = sy;
            deltaY = (_e1031 + (((_e1032 - 1f) / 2f) * _e1037));
            let _e1042 = deltaY;
            let _e1044 = dzdx;
            let _e1048 = deltaX;
            let _e1050 = dzdy;
            let _e1052 = deltaX;
            let _e1053 = deltaY;
            unormal = vec3<f32>(((-2f * _e1042) * _e1044), ((-2f * _e1048) * _e1050), (_e1052 * _e1053));
            let _e1057 = unormal;
            let _e1061 = unormal;
            let _e1066 = unormal;
            if (((_e1057.x == 0f) && (_e1061.y == 0f)) && (_e1066.z == 0f)) {
                local_8 = vec3<f32>(0f, 0f, 1f);
            } else {
                let _e1075 = unormal;
                local_8 = normalize(_e1075);
            }
            let _e1078 = local_8;
            normal = _e1078;
            let _e1080 = lightDir;
            let _e1081 = normal;
            lighting = ((dot(_e1080, _e1081) + 1f) / 2f);
            let _e1087 = surfaceSmoothness_1;
            if (_e1087 < 100f) {
                {
                    let _e1090 = lighting;
                    if (_e1090 < 0.5f) {
                        let _e1093 = lighting;
                        let _e1097 = surfaceSmoothness_1;
                        lighting = (pow((_e1093 * 2f), (100f / _e1097)) / 2f);
                    } else {
                        let _e1102 = lighting;
                        let _e1108 = surfaceSmoothness_1;
                        lighting = ((pow(((_e1102 - 0.5f) * 2f), (0.01f * _e1108)) / 2f) + 0.5f);
                    }
                }
            }
            let _e1115 = specular_3;
            if (_e1115 != 0f) {
                {
                    let _e1118 = lightDir;
                    let _e1119 = normal;
                    reflectLightDir = reflect(_e1118, _e1119);
                    let _e1122 = specular_3;
                    if (_e1122 < 25f) {
                        let _e1125 = specular_3;
                        local_9 = (_e1125 * 0.04f);
                    } else {
                        local_9 = 1f;
                    }
                    let _e1130 = local_9;
                    let _e1131 = dir;
                    let _e1132 = reflectLightDir;
                    let _e1138 = specular_3;
                    spec = (_e1130 * pow(clamp(dot(_e1131, _e1132), 0f, 1f), (10f - (_e1138 * 0.1f))));
                }
            }
        }
    }
    let _e1144 = cameraPos;
    let _e1145 = p;
    kFog = length((_e1144 - _e1145));
    let _e1149 = shadows_1;
    shad = _e1149;
    let _e1151 = shadowing;
    let _e1154 = shad;
    let _e1158 = intensity_3;
    if (((_e1151 != 0f) && (_e1154 > 0f)) && (_e1158 != 0f)) {
        {
            let _e1162 = p;
            let _e1164 = step;
            p = (_e1162 - (2f * _e1164));
            let _e1167 = lightDir;
            let _e1168 = dk;
            lightStep = (_e1167 * _e1168);
            k1_ = 0f;
            let _e1172 = lightVec;
            k2_1 = length(_e1172);
            let _e1175 = lightDir;
            if (_e1175.x != 0f) {
                {
                    let _e1179 = lightDir;
                    s_3 = sign(_e1179.x);
                    let _e1183 = s_3;
                    let _e1185 = ratio;
                    let _e1187 = p;
                    let _e1190 = lightDir;
                    k3_3 = (((-(_e1183) * _e1185) - _e1187.x) / _e1190.x);
                    let _e1194 = s_3;
                    let _e1195 = ratio;
                    let _e1197 = p;
                    let _e1200 = lightDir;
                    k4_3 = (((_e1194 * _e1195) - _e1197.x) / _e1200.x);
                    let _e1204 = k4_3;
                    if (_e1204 > 0f) {
                        let _e1207 = k2_1;
                        let _e1208 = k4_3;
                        k2_1 = min(_e1207, _e1208);
                    }
                    let _e1210 = k3_3;
                    if (_e1210 > 0f) {
                        let _e1213 = k2_1;
                        let _e1214 = k3_3;
                        k2_1 = min(_e1213, _e1214);
                    }
                }
            }
            let _e1216 = lightDir;
            if (_e1216.y != 0f) {
                {
                    let _e1220 = lightDir;
                    s_4 = sign(_e1220.y);
                    let _e1224 = s_4;
                    let _e1226 = p;
                    let _e1229 = lightDir;
                    k3_4 = ((-(_e1224) - _e1226.y) / _e1229.y);
                    let _e1233 = s_4;
                    let _e1234 = p;
                    let _e1237 = lightDir;
                    k4_4 = ((_e1233 - _e1234.y) / _e1237.y);
                    let _e1241 = k4_4;
                    if (_e1241 > 0f) {
                        let _e1244 = k2_1;
                        let _e1245 = k4_4;
                        k2_1 = min(_e1244, _e1245);
                    }
                    let _e1247 = k3_4;
                    if (_e1247 > 0f) {
                        let _e1250 = k2_1;
                        let _e1251 = k3_4;
                        k2_1 = min(_e1250, _e1251);
                    }
                }
            }
            let _e1253 = maxZ;
            maxZ2_1 = (_e1253 + 0.0001f);
            let _e1257 = lightDir;
            if (_e1257.z != 0f) {
                {
                    let _e1261 = lightDir;
                    s_5 = sign(_e1261.z);
                    let _e1265 = s_5;
                    let _e1267 = maxZ2_1;
                    let _e1269 = p;
                    let _e1272 = lightDir;
                    k3_5 = (((-(_e1265) * _e1267) - _e1269.z) / _e1272.z);
                    let _e1276 = s_5;
                    let _e1277 = maxZ2_1;
                    let _e1279 = p;
                    let _e1282 = lightDir;
                    k4_5 = (((_e1276 * _e1277) - _e1279.z) / _e1282.z);
                    let _e1286 = k4_5;
                    if (_e1286 > 0f) {
                        let _e1289 = k2_1;
                        let _e1290 = k4_5;
                        k2_1 = min(_e1289, _e1290);
                    }
                    let _e1292 = k3_5;
                    if (_e1292 > 0f) {
                        let _e1295 = k2_1;
                        let _e1296 = k3_5;
                        k2_1 = min(_e1295, _e1296);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1302 = heightMap_1;
            if _e1302 {
                {
                    loop {
                        {
                            let _e1303 = dz;
                            prevDz = _e1303;
                            let _e1304 = h;
                            prevH = _e1304;
                            let _e1305 = intensity_3;
                            let _e1306 = p;
                            let _e1311 = global.U[0];
                            let _e1314 = p;
                            let _e1324 = _mirror_wrap(((vec2<f32>((_e1306.x / _e1311.x), _e1314.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1325 = textureSample(t_sourceElevation, samp, _e1324);
                            let _e1326 = height(_e1305, _e1325);
                            h = _e1326;
                            let _e1327 = p;
                            let _e1329 = h;
                            dz = (_e1327.z - _e1329);
                            let _e1331 = p;
                            let _e1332 = lightStep;
                            p = (_e1331 + _e1332);
                            let _e1334 = k;
                            let _e1335 = dk;
                            k = (_e1334 + _e1335);
                            let _e1337 = dz;
                            let _e1340 = k;
                            let _e1341 = k1_;
                            let _e1343 = dz;
                            let _e1345 = prevDz;
                            stop = ((_e1337 == 0f) || ((_e1340 != _e1341) && (sign(_e1343) == -(sign(_e1345)))));
                        }
                        let _e1351 = k;
                        let _e1352 = k2_1;
                        let _e1354 = stop;
                        if !(((_e1351 <= _e1352) && !(_e1354))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1358 = dz;
                            prevDz = _e1358;
                            let _e1359 = h;
                            prevH = _e1359;
                            let _e1360 = intensity_3;
                            let _e1361 = p;
                            let _e1366 = global.U[0];
                            let _e1369 = p;
                            let _e1379 = _mirror_wrap(((vec2<f32>((_e1361.x / _e1366.x), _e1369.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1380 = textureSample(t_source, samp, _e1379);
                            let _e1381 = height(_e1360, _e1380);
                            h = _e1381;
                            let _e1382 = p;
                            let _e1384 = h;
                            dz = (_e1382.z - _e1384);
                            let _e1386 = p;
                            let _e1387 = lightStep;
                            p = (_e1386 + _e1387);
                            let _e1389 = k;
                            let _e1390 = dk;
                            k = (_e1389 + _e1390);
                            let _e1392 = dz;
                            let _e1395 = k;
                            let _e1396 = k1_;
                            let _e1398 = dz;
                            let _e1400 = prevDz;
                            stop = ((_e1392 == 0f) || ((_e1395 != _e1396) && (sign(_e1398) == -(sign(_e1400)))));
                        }
                        let _e1406 = k;
                        let _e1407 = k2_1;
                        let _e1409 = stop;
                        if !(((_e1406 <= _e1407) && !(_e1409))) {
                            break;
                        }
                    }
                }
            }
            let _e1413 = stop;
            if _e1413 {
                {
                    let _e1415 = shadows_1;
                    let _e1417 = lighting;
                    lighting = min((1f - _e1415), _e1417);
                    spec = 0f;
                }
            }
        }
    }
    let _e1420 = color_3;
    let _e1421 = lighting;
    let _e1422 = spec;
    let _e1423 = ambientColor_3;
    let _e1424 = sourceColor_3;
    let _e1425 = gamma_3;
    let _e1426 = applyLighting(_e1420, _e1421, _e1422, _e1423, _e1424, _e1425);
    color_3 = _e1426;
    let _e1427 = colorFog_1;
    if (_e1427.w != 0f) {
        {
            let _e1433 = colorFog_1;
            nearDist = (2f * (1f - _e1433.w));
            let _e1439 = nearDist;
            farDist = (2f * _e1439);
            let _e1442 = nearDist;
            let _e1443 = farDist;
            let _e1444 = kFog;
            kFog = smoothstep(_e1442, _e1443, _e1444);
            let _e1446 = color_3;
            let _e1448 = color_3;
            let _e1450 = colorFog_1;
            let _e1452 = kFog;
            let _e1454 = mix(_e1448.xyz, _e1450.xyz, vec3(_e1452));
            color_3.x = _e1454.x;
            color_3.y = _e1454.y;
            color_3.z = _e1454.z;
        }
    }
    let _e1461 = color_3;
    return clamp(_e1461, vec4(0f), vec4(1f));
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
