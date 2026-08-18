struct Params {
    U: array<vec4<f32>, 24>,
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

fn heightMapLightingGl(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, lightSourceDistance: f32, lightSourceAngleX: f32, lightSourceAngleY: f32, colorScheme: f32, sourceColor_2: vec4<f32>, ambientColor_2: vec4<f32>, normalSmoothing: f32, surfaceSmoothness: f32, specular_2: f32, shadows: f32, gamma_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var lightSourceDistance_1: f32;
    var lightSourceAngleX_1: f32;
    var lightSourceAngleY_1: f32;
    var colorScheme_1: f32;
    var sourceColor_3: vec4<f32>;
    var ambientColor_3: vec4<f32>;
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
    var heightMap: bool;
    var _caX: f32;
    var _saX: f32;
    var _caY: f32;
    var _saY: f32;
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
    var local_1: vec4<f32>;
    var local_2: f32;
    var kk: f32;
    var hh: f32;
    var local_3: f32;
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
    var N: f32;
    var bx: f32;
    var local_4: f32;
    var sx: f32;
    var i: i32 = 0i;
    var deltaX_1: f32;
    var i_1: i32 = 0i;
    var deltaX_2: f32;
    var by: f32;
    var local_5: f32;
    var sy: f32;
    var i_2: i32 = 0i;
    var deltaY_1: f32;
    var i_3: i32 = 0i;
    var deltaY_2: f32;
    var unormal: vec3<f32>;
    var local_6: vec3<f32>;
    var normal: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var local_7: f32;
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

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    lightSourceDistance_1 = lightSourceDistance;
    lightSourceAngleX_1 = lightSourceAngleX;
    lightSourceAngleY_1 = lightSourceAngleY;
    colorScheme_1 = colorScheme;
    sourceColor_3 = sourceColor_2;
    ambientColor_3 = ambientColor_2;
    normalSmoothing_1 = normalSmoothing;
    surfaceSmoothness_1 = surfaceSmoothness;
    specular_3 = specular_2;
    shadows_1 = shadows;
    gamma_3 = gamma_2;
    let _e57 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e57);
    let _e60 = m;
    let _e61 = cameraPos;
    cameraPos = (_e60 * vec4<f32>(_e61.x, _e61.y, _e61.z, 1f)).xyz;
    let _e69 = pos_1;
    let _e71 = D;
    let _e73 = pos_1;
    let _e75 = D;
    dir = vec3<f32>((_e69.x * _e71), (_e73.y * _e75), -1f);
    let _e81 = m;
    let _e91 = dir;
    dir = normalize((mat3x3<f32>(_e81[0].xyz, _e81[1].xyz, _e81[2].xyz) * _e91));
    let _e94 = intensity_3;
    maxZ = (abs(_e94) * 0.02f);
    let _e99 = sourceDim_1;
    let _e101 = sourceDim_1;
    ratio = (_e99.x / _e101.y);
    let _e106 = sourceDim_1;
    dk = (2f / _e106.y);
    let _e110 = dir;
    let _e111 = dk;
    step = (_e110 * _e111);
    let _e114 = sourceElevation_specified_1;
    heightMap = (_e114 == 1i);
    let _e118 = lightSourceAngleX_1;
    _caX = cos(_e118);
    let _e121 = lightSourceAngleX_1;
    _saX = sin(_e121);
    let _e124 = lightSourceAngleY_1;
    _caY = cos(_e124);
    let _e127 = lightSourceAngleY_1;
    _saY = sin(_e127);
    let _e130 = lightSourceDistance_1;
    let _e131 = _caX;
    let _e133 = _saY;
    let _e135 = lightSourceDistance_1;
    let _e137 = _saX;
    let _e139 = lightSourceDistance_1;
    let _e140 = _caX;
    let _e142 = _caY;
    lightPos = vec3<f32>(((_e130 * _e131) * _e133), (-(_e135) * _e137), ((_e139 * _e140) * _e142));
    let _e150 = dir;
    if (_e150.x != 0f) {
        {
            let _e154 = dir;
            s = sign(_e154.x);
            let _e158 = s;
            let _e160 = ratio;
            let _e162 = cameraPos;
            let _e165 = dir;
            k3_ = (((-(_e158) * _e160) - _e162.x) / _e165.x);
            let _e169 = s;
            let _e170 = ratio;
            let _e172 = cameraPos;
            let _e175 = dir;
            k4_ = (((_e169 * _e170) - _e172.x) / _e175.x);
            let _e179 = k1_;
            let _e180 = k3_;
            k1_ = max(_e179, _e180);
            let _e182 = k2_;
            let _e183 = k4_;
            k2_ = min(_e182, _e183);
        }
    }
    let _e185 = dir;
    if (_e185.y != 0f) {
        {
            let _e189 = dir;
            s_1 = sign(_e189.y);
            let _e193 = s_1;
            let _e195 = cameraPos;
            let _e198 = dir;
            k3_1 = ((-(_e193) - _e195.y) / _e198.y);
            let _e202 = s_1;
            let _e203 = cameraPos;
            let _e206 = dir;
            k4_1 = ((_e202 - _e203.y) / _e206.y);
            let _e210 = k1_;
            let _e211 = k3_1;
            k1_ = max(_e210, _e211);
            let _e213 = k2_;
            let _e214 = k4_1;
            k2_ = min(_e213, _e214);
        }
    }
    let _e216 = maxZ;
    maxZ2_ = (_e216 + 0.0001f);
    let _e220 = dir;
    if (_e220.z != 0f) {
        {
            let _e224 = dir;
            s_2 = sign(_e224.z);
            let _e228 = s_2;
            let _e230 = maxZ2_;
            let _e232 = cameraPos;
            let _e235 = dir;
            k3_2 = (((-(_e228) * _e230) - _e232.z) / _e235.z);
            let _e239 = s_2;
            let _e240 = maxZ2_;
            let _e242 = cameraPos;
            let _e245 = dir;
            k4_2 = (((_e239 * _e240) - _e242.z) / _e245.z);
            let _e249 = k1_;
            let _e250 = k3_2;
            k1_ = max(_e249, _e250);
            let _e252 = k2_;
            let _e253 = k4_2;
            k2_ = min(_e252, _e253);
        }
    }
    let _e255 = k1_;
    let _e256 = k2_;
    if (_e255 > _e256) {
        let _e258 = sourceBkg_specified_1;
        if (_e258 == 1i) {
            let _e261 = pos_1;
            let _e265 = global.U[0];
            let _e268 = pos_1;
            let _e278 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e261.x / _e265.x), _e268.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local = _e278;
        } else {
            local = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e285 = local;
        return _e285;
    }
    let _e286 = k1_;
    k = _e286;
    let _e288 = cameraPos;
    let _e289 = k;
    let _e290 = dir;
    p = (_e288 + (_e289 * _e290));
    let _e294 = backgroundColor;
    color_3 = _e294;
    let _e309 = k2_;
    let _e310 = dk;
    k2_ = (_e309 + _e310);
    let _e312 = heightMap;
    if _e312 {
        {
            loop {
                {
                    let _e313 = dz;
                    prevDz = _e313;
                    let _e314 = h;
                    prevH = _e314;
                    let _e315 = intensity_3;
                    let _e316 = p;
                    let _e321 = global.U[0];
                    let _e324 = p;
                    let _e335 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e316.x / _e321.x), _e324.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e336 = height(_e315, _e335);
                    h = _e336;
                    let _e337 = p;
                    let _e339 = h;
                    dz = (_e337.z - _e339);
                    let _e341 = p;
                    let _e342 = step;
                    p = (_e341 + _e342);
                    let _e344 = k;
                    let _e345 = dk;
                    k = (_e344 + _e345);
                    let _e347 = dz;
                    let _e350 = k;
                    let _e351 = k1_;
                    let _e353 = dz;
                    let _e355 = prevDz;
                    stop = ((_e347 == 0f) || ((_e350 != _e351) && (sign(_e353) == -(sign(_e355)))));
                }
                let _e361 = k;
                let _e362 = k2_;
                let _e364 = stop;
                if !(((_e361 <= _e362) && !(_e364))) {
                    break;
                }
            }
            let _e368 = p;
            let _e369 = step;
            pp = (_e368 - _e369).xy;
            let _e373 = pp;
            let _e377 = global.U[0];
            let _e380 = pp;
            let _e390 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e373.x / _e377.x), _e380.y) / vec2(2f)) + vec2(0.5f)), 0f);
            color_3 = _e390;
            let _e391 = pp;
            let _e392 = step;
            let _e398 = global.U[0];
            let _e401 = pp;
            let _e402 = step;
            let _e414 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e391 - _e392.xy).x / _e398.x), (_e401 - _e402.xy).y) / vec2(2f)) + vec2(0.5f)), 0f);
            prevColor = _e414;
        }
    } else {
        {
            loop {
                {
                    let _e415 = color_3;
                    prevColor = _e415;
                    let _e416 = dz;
                    prevDz = _e416;
                    let _e417 = h;
                    prevH = _e417;
                    let _e418 = p;
                    let _e423 = global.U[0];
                    let _e426 = p;
                    let _e437 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e418.x / _e423.x), _e426.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    color_3 = _e437;
                    let _e438 = intensity_3;
                    let _e439 = color_3;
                    let _e440 = height(_e438, _e439);
                    h = _e440;
                    let _e441 = p;
                    let _e443 = h;
                    dz = (_e441.z - _e443);
                    let _e445 = p;
                    let _e446 = step;
                    p = (_e445 + _e446);
                    let _e448 = k;
                    let _e449 = dk;
                    k = (_e448 + _e449);
                    let _e451 = dz;
                    let _e454 = k;
                    let _e455 = k1_;
                    let _e457 = dz;
                    let _e459 = prevDz;
                    stop = ((_e451 == 0f) || ((_e454 != _e455) && (sign(_e457) == -(sign(_e459)))));
                }
                let _e465 = k;
                let _e466 = k2_;
                let _e468 = stop;
                if !(((_e465 <= _e466) && !(_e468))) {
                    break;
                }
            }
        }
    }
    let _e472 = stop;
    if !(_e472) {
        let _e474 = sourceBkg_specified_1;
        if (_e474 == 1i) {
            let _e477 = pos_1;
            let _e481 = global.U[0];
            let _e484 = pos_1;
            let _e494 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e477.x / _e481.x), _e484.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local_1 = _e494;
        } else {
            local_1 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e501 = local_1;
        return _e501;
    }
    let _e502 = dz;
    let _e505 = k1_;
    let _e506 = dk;
    let _e508 = k2_;
    if ((_e502 == 0f) || ((_e505 + _e506) > _e508)) {
        local_2 = 1f;
    } else {
        let _e512 = prevDz;
        let _e514 = dz;
        let _e516 = prevDz;
        local_2 = (abs(_e512) / (abs(_e514) + abs(_e516)));
    }
    let _e521 = local_2;
    kk = _e521;
    let _e523 = prevH;
    let _e524 = h;
    let _e525 = kk;
    hh = mix(_e523, _e524, _e525);
    let _e528 = maxZ;
    if (_e528 == 0f) {
        local_3 = 1f;
    } else {
        let _e532 = hh;
        let _e533 = maxZ;
        local_3 = (_e532 / _e533);
    }
    let _e536 = local_3;
    hRatio = _e536;
    let _e538 = colorScheme_1;
    if (_e538 <= 50f) {
        {
            let _e542 = colorScheme_1;
            let _e545 = hRatio;
            darken = (1f + ((_e542 * 0.02f) * _e545));
            let _e549 = prevColor;
            let _e550 = color_3;
            let _e551 = kk;
            let _e554 = darken;
            let _e555 = darken;
            let _e556 = darken;
            color_3 = (mix(_e549, _e550, vec4(_e551)) * vec4<f32>(_e554, _e555, _e556, 1f));
        }
    } else {
        {
            let _e561 = hRatio;
            darken_1 = (1f + _e561);
            let _e564 = colorScheme_1;
            kkk = ((_e564 - 50f) * 0.02f);
            let _e570 = prevColor;
            let _e571 = color_3;
            let _e572 = kk;
            let _e575 = darken_1;
            let _e576 = darken_1;
            let _e577 = darken_1;
            col = (mix(_e570, _e571, vec4(_e572)) * vec4<f32>(_e575, _e576, _e577, 1f));
            let _e582 = col;
            let _e583 = darken_1;
            let _e586 = darken_1;
            let _e589 = darken_1;
            let _e594 = kkk;
            color_3 = mix(_e582, vec4<f32>((_e583 * 0.5f), (_e586 * 0.5f), (_e589 * 0.5f), 1f), vec4(_e594));
        }
    }
    let _e597 = lightPos;
    let _e598 = p;
    lightVec = (_e597 - _e598);
    let _e601 = lightVec;
    lightDir = normalize(_e601);
    let _e608 = sourceColor_3;
    let _e610 = sourceColor_3;
    let _e613 = sourceColor_3;
    shadowing = ((_e608.x + _e610.y) + _e613.z);
    let _e617 = shadowing;
    if (_e617 != 0f) {
        {
            let _e620 = p;
            intersection = _e620;
            let _e631 = normalSmoothing_1;
            N = (1f + ceil((_e631 / 20f)));
            let _e638 = normalSmoothing_1;
            bx = (0.0005f + (_e638 * 0.0001f));
            let _e643 = N;
            if (_e643 >= 2f) {
                let _e646 = bx;
                let _e647 = N;
                local_4 = (_e646 / (_e647 - 1f));
            } else {
                local_4 = 0f;
            }
            let _e653 = local_4;
            sx = _e653;
            let _e655 = heightMap;
            if !(_e655) {
                loop {
                    let _e659 = i;
                    let _e660 = N;
                    if !((_e659 < i32(_e660))) {
                        break;
                    }
                    {
                        let _e667 = bx;
                        let _e668 = i;
                        let _e670 = sx;
                        deltaX_1 = (_e667 + (f32(_e668) * _e670));
                        let _e674 = dzdx;
                        let _e675 = intensity_3;
                        let _e676 = intersection;
                        let _e678 = deltaX_1;
                        let _e680 = intersection;
                        let _e686 = global.U[0];
                        let _e689 = intersection;
                        let _e691 = deltaX_1;
                        let _e693 = intersection;
                        let _e705 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e676.x + _e678), _e680.y).x / _e686.x), vec2<f32>((_e689.x + _e691), _e693.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e706 = height(_e675, _e705);
                        let _e707 = intensity_3;
                        let _e708 = intersection;
                        let _e710 = deltaX_1;
                        let _e712 = intersection;
                        let _e718 = global.U[0];
                        let _e721 = intersection;
                        let _e723 = deltaX_1;
                        let _e725 = intersection;
                        let _e737 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e708.x - _e710), _e712.y).x / _e718.x), vec2<f32>((_e721.x - _e723), _e725.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e738 = height(_e707, _e737);
                        dzdx = (_e674 + (_e706 - _e738));
                    }
                    continuing {
                        let _e664 = i;
                        i = (_e664 + 1i);
                    }
                }
            } else {
                loop {
                    let _e743 = i_1;
                    let _e744 = N;
                    if !((_e743 < i32(_e744))) {
                        break;
                    }
                    {
                        let _e751 = bx;
                        let _e752 = i_1;
                        let _e754 = sx;
                        deltaX_2 = (_e751 + (f32(_e752) * _e754));
                        let _e758 = dzdx;
                        let _e759 = intensity_3;
                        let _e760 = intersection;
                        let _e762 = deltaX_2;
                        let _e764 = intersection;
                        let _e770 = global.U[0];
                        let _e773 = intersection;
                        let _e775 = deltaX_2;
                        let _e777 = intersection;
                        let _e789 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e760.x + _e762), _e764.y).x / _e770.x), vec2<f32>((_e773.x + _e775), _e777.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e790 = height(_e759, _e789);
                        let _e791 = intensity_3;
                        let _e792 = intersection;
                        let _e794 = deltaX_2;
                        let _e796 = intersection;
                        let _e802 = global.U[0];
                        let _e805 = intersection;
                        let _e807 = deltaX_2;
                        let _e809 = intersection;
                        let _e821 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e792.x - _e794), _e796.y).x / _e802.x), vec2<f32>((_e805.x - _e807), _e809.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e822 = height(_e791, _e821);
                        dzdx = (_e758 + (_e790 - _e822));
                    }
                    continuing {
                        let _e748 = i_1;
                        i_1 = (_e748 + 1i);
                    }
                }
            }
            let _e825 = dzdx;
            let _e826 = N;
            dzdx = (_e825 / _e826);
            let _e828 = bx;
            let _e829 = N;
            let _e834 = sx;
            deltaX = (_e828 + (((_e829 - 1f) / 2f) * _e834));
            let _e838 = normalSmoothing_1;
            by = (0.0005f + (_e838 * 0.0001f));
            let _e843 = N;
            if (_e843 >= 2f) {
                let _e846 = by;
                let _e847 = N;
                local_5 = (_e846 / (_e847 - 1f));
            } else {
                local_5 = 0f;
            }
            let _e853 = local_5;
            sy = _e853;
            let _e855 = heightMap;
            if !(_e855) {
                loop {
                    let _e859 = i_2;
                    let _e860 = N;
                    if !((_e859 < i32(_e860))) {
                        break;
                    }
                    {
                        let _e867 = by;
                        let _e868 = i_2;
                        let _e870 = sy;
                        deltaY_1 = (_e867 + (f32(_e868) * _e870));
                        let _e874 = intensity_3;
                        let _e875 = intersection;
                        let _e877 = intersection;
                        let _e879 = deltaY_1;
                        let _e885 = global.U[0];
                        let _e888 = intersection;
                        let _e890 = intersection;
                        let _e892 = deltaY_1;
                        let _e904 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e875.x, (_e877.y + _e879)).x / _e885.x), vec2<f32>(_e888.x, (_e890.y + _e892)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e905 = height(_e874, _e904);
                        let _e906 = intensity_3;
                        let _e907 = intersection;
                        let _e909 = intersection;
                        let _e911 = deltaY_1;
                        let _e917 = global.U[0];
                        let _e920 = intersection;
                        let _e922 = intersection;
                        let _e924 = deltaY_1;
                        let _e936 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e907.x, (_e909.y - _e911)).x / _e917.x), vec2<f32>(_e920.x, (_e922.y - _e924)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e937 = height(_e906, _e936);
                        dzdy = (_e905 - _e937);
                    }
                    continuing {
                        let _e864 = i_2;
                        i_2 = (_e864 + 1i);
                    }
                }
            } else {
                loop {
                    let _e941 = i_3;
                    let _e942 = N;
                    if !((_e941 < i32(_e942))) {
                        break;
                    }
                    {
                        let _e949 = by;
                        let _e950 = i_3;
                        let _e952 = sy;
                        deltaY_2 = (_e949 + (f32(_e950) * _e952));
                        let _e956 = intensity_3;
                        let _e957 = intersection;
                        let _e959 = intersection;
                        let _e961 = deltaY_2;
                        let _e967 = global.U[0];
                        let _e970 = intersection;
                        let _e972 = intersection;
                        let _e974 = deltaY_2;
                        let _e986 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e957.x, (_e959.y + _e961)).x / _e967.x), vec2<f32>(_e970.x, (_e972.y + _e974)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e987 = height(_e956, _e986);
                        let _e988 = intensity_3;
                        let _e989 = intersection;
                        let _e991 = intersection;
                        let _e993 = deltaY_2;
                        let _e999 = global.U[0];
                        let _e1002 = intersection;
                        let _e1004 = intersection;
                        let _e1006 = deltaY_2;
                        let _e1018 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e989.x, (_e991.y - _e993)).x / _e999.x), vec2<f32>(_e1002.x, (_e1004.y - _e1006)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e1019 = height(_e988, _e1018);
                        dzdy = (_e987 - _e1019);
                    }
                    continuing {
                        let _e946 = i_3;
                        i_3 = (_e946 + 1i);
                    }
                }
            }
            let _e1021 = dzdy;
            let _e1022 = N;
            dzdy = (_e1021 / _e1022);
            let _e1024 = by;
            let _e1025 = N;
            let _e1030 = sy;
            deltaY = (_e1024 + (((_e1025 - 1f) / 2f) * _e1030));
            let _e1035 = deltaY;
            let _e1037 = dzdx;
            let _e1041 = deltaX;
            let _e1043 = dzdy;
            let _e1045 = deltaX;
            let _e1046 = deltaY;
            unormal = vec3<f32>(((-2f * _e1035) * _e1037), ((-2f * _e1041) * _e1043), (_e1045 * _e1046));
            let _e1050 = unormal;
            let _e1054 = unormal;
            let _e1059 = unormal;
            if (((_e1050.x == 0f) && (_e1054.y == 0f)) && (_e1059.z == 0f)) {
                local_6 = vec3<f32>(0f, 0f, 1f);
            } else {
                let _e1068 = unormal;
                local_6 = normalize(_e1068);
            }
            let _e1071 = local_6;
            normal = _e1071;
            let _e1073 = lightDir;
            let _e1074 = normal;
            lighting = ((dot(_e1073, _e1074) + 1f) / 2f);
            let _e1080 = surfaceSmoothness_1;
            if (_e1080 < 100f) {
                {
                    let _e1083 = lighting;
                    if (_e1083 < 0.5f) {
                        let _e1086 = lighting;
                        let _e1090 = surfaceSmoothness_1;
                        lighting = (pow((_e1086 * 2f), (100f / _e1090)) / 2f);
                    } else {
                        let _e1095 = lighting;
                        let _e1101 = surfaceSmoothness_1;
                        lighting = ((pow(((_e1095 - 0.5f) * 2f), (0.01f * _e1101)) / 2f) + 0.5f);
                    }
                }
            }
            let _e1108 = specular_3;
            if (_e1108 != 0f) {
                {
                    let _e1111 = lightDir;
                    let _e1112 = normal;
                    reflectLightDir = reflect(_e1111, _e1112);
                    let _e1115 = specular_3;
                    if (_e1115 < 25f) {
                        let _e1118 = specular_3;
                        local_7 = (_e1118 * 0.04f);
                    } else {
                        local_7 = 1f;
                    }
                    let _e1123 = local_7;
                    let _e1124 = dir;
                    let _e1125 = reflectLightDir;
                    let _e1131 = specular_3;
                    spec = (_e1123 * pow(clamp(dot(_e1124, _e1125), 0f, 1f), (10f - (_e1131 * 0.1f))));
                }
            }
        }
    }
    let _e1137 = shadows_1;
    shad = _e1137;
    let _e1139 = shadowing;
    let _e1142 = shad;
    let _e1146 = intensity_3;
    if (((_e1139 != 0f) && (_e1142 > 0f)) && (_e1146 != 0f)) {
        {
            let _e1150 = p;
            let _e1152 = step;
            p = (_e1150 - (2f * _e1152));
            let _e1155 = lightDir;
            let _e1156 = dk;
            lightStep = (_e1155 * _e1156);
            k1_ = 0f;
            let _e1160 = lightVec;
            k2_1 = length(_e1160);
            let _e1163 = lightDir;
            if (_e1163.x != 0f) {
                {
                    let _e1167 = lightDir;
                    s_3 = sign(_e1167.x);
                    let _e1171 = s_3;
                    let _e1173 = ratio;
                    let _e1175 = p;
                    let _e1178 = lightDir;
                    k3_3 = (((-(_e1171) * _e1173) - _e1175.x) / _e1178.x);
                    let _e1182 = s_3;
                    let _e1183 = ratio;
                    let _e1185 = p;
                    let _e1188 = lightDir;
                    k4_3 = (((_e1182 * _e1183) - _e1185.x) / _e1188.x);
                    let _e1192 = k4_3;
                    if (_e1192 > 0f) {
                        let _e1195 = k2_1;
                        let _e1196 = k4_3;
                        k2_1 = min(_e1195, _e1196);
                    }
                    let _e1198 = k3_3;
                    if (_e1198 > 0f) {
                        let _e1201 = k2_1;
                        let _e1202 = k3_3;
                        k2_1 = min(_e1201, _e1202);
                    }
                }
            }
            let _e1204 = lightDir;
            if (_e1204.y != 0f) {
                {
                    let _e1208 = lightDir;
                    s_4 = sign(_e1208.y);
                    let _e1212 = s_4;
                    let _e1214 = p;
                    let _e1217 = lightDir;
                    k3_4 = ((-(_e1212) - _e1214.y) / _e1217.y);
                    let _e1221 = s_4;
                    let _e1222 = p;
                    let _e1225 = lightDir;
                    k4_4 = ((_e1221 - _e1222.y) / _e1225.y);
                    let _e1229 = k4_4;
                    if (_e1229 > 0f) {
                        let _e1232 = k2_1;
                        let _e1233 = k4_4;
                        k2_1 = min(_e1232, _e1233);
                    }
                    let _e1235 = k3_4;
                    if (_e1235 > 0f) {
                        let _e1238 = k2_1;
                        let _e1239 = k3_4;
                        k2_1 = min(_e1238, _e1239);
                    }
                }
            }
            let _e1241 = maxZ;
            maxZ2_1 = (_e1241 + 0.0001f);
            let _e1245 = lightDir;
            if (_e1245.z != 0f) {
                {
                    let _e1249 = lightDir;
                    s_5 = sign(_e1249.z);
                    let _e1253 = s_5;
                    let _e1255 = maxZ2_1;
                    let _e1257 = p;
                    let _e1260 = lightDir;
                    k3_5 = (((-(_e1253) * _e1255) - _e1257.z) / _e1260.z);
                    let _e1264 = s_5;
                    let _e1265 = maxZ2_1;
                    let _e1267 = p;
                    let _e1270 = lightDir;
                    k4_5 = (((_e1264 * _e1265) - _e1267.z) / _e1270.z);
                    let _e1274 = k4_5;
                    if (_e1274 > 0f) {
                        let _e1277 = k2_1;
                        let _e1278 = k4_5;
                        k2_1 = min(_e1277, _e1278);
                    }
                    let _e1280 = k3_5;
                    if (_e1280 > 0f) {
                        let _e1283 = k2_1;
                        let _e1284 = k3_5;
                        k2_1 = min(_e1283, _e1284);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1290 = heightMap;
            if _e1290 {
                {
                    loop {
                        {
                            let _e1291 = dz;
                            prevDz = _e1291;
                            let _e1292 = h;
                            prevH = _e1292;
                            let _e1293 = intensity_3;
                            let _e1294 = p;
                            let _e1299 = global.U[0];
                            let _e1302 = p;
                            let _e1313 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e1294.x / _e1299.x), _e1302.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e1314 = height(_e1293, _e1313);
                            h = _e1314;
                            let _e1315 = p;
                            let _e1317 = h;
                            dz = (_e1315.z - _e1317);
                            let _e1319 = p;
                            let _e1320 = lightStep;
                            p = (_e1319 + _e1320);
                            let _e1322 = k;
                            let _e1323 = dk;
                            k = (_e1322 + _e1323);
                            let _e1325 = dz;
                            let _e1328 = k;
                            let _e1329 = k1_;
                            let _e1331 = dz;
                            let _e1333 = prevDz;
                            stop = ((_e1325 == 0f) || ((_e1328 != _e1329) && (sign(_e1331) == -(sign(_e1333)))));
                        }
                        let _e1339 = k;
                        let _e1340 = k2_1;
                        let _e1342 = stop;
                        if !(((_e1339 <= _e1340) && !(_e1342))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1346 = dz;
                            prevDz = _e1346;
                            let _e1347 = h;
                            prevH = _e1347;
                            let _e1348 = intensity_3;
                            let _e1349 = p;
                            let _e1354 = global.U[0];
                            let _e1357 = p;
                            let _e1368 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1349.x / _e1354.x), _e1357.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e1369 = height(_e1348, _e1368);
                            h = _e1369;
                            let _e1370 = p;
                            let _e1372 = h;
                            dz = (_e1370.z - _e1372);
                            let _e1374 = p;
                            let _e1375 = lightStep;
                            p = (_e1374 + _e1375);
                            let _e1377 = k;
                            let _e1378 = dk;
                            k = (_e1377 + _e1378);
                            let _e1380 = dz;
                            let _e1383 = k;
                            let _e1384 = k1_;
                            let _e1386 = dz;
                            let _e1388 = prevDz;
                            stop = ((_e1380 == 0f) || ((_e1383 != _e1384) && (sign(_e1386) == -(sign(_e1388)))));
                        }
                        let _e1394 = k;
                        let _e1395 = k2_1;
                        let _e1397 = stop;
                        if !(((_e1394 <= _e1395) && !(_e1397))) {
                            break;
                        }
                    }
                }
            }
            let _e1401 = stop;
            if _e1401 {
                {
                    let _e1403 = shadows_1;
                    let _e1405 = lighting;
                    lighting = min((1f - _e1403), _e1405);
                    spec = 0f;
                }
            }
        }
    }
    let _e1408 = color_3;
    let _e1409 = lighting;
    let _e1410 = spec;
    let _e1411 = ambientColor_3;
    let _e1412 = sourceColor_3;
    let _e1413 = gamma_3;
    let _e1414 = applyLighting(_e1408, _e1409, _e1410, _e1411, _e1412, _e1413);
    color_3 = _e1414;
    let _e1415 = color_3;
    return clamp(_e1415, vec4(0f), vec4(1f));
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
    let _e123 = global.U[14];
    let _e127 = global.U[15];
    let _e131 = global.U[16];
    let _e135 = global.U[17];
    let _e138 = global.U[18];
    let _e141 = global.U[19];
    let _e145 = global.U[20];
    let _e149 = global.U[21];
    let _e153 = global.U[22];
    let _e157 = global.U[23];
    let _e159 = heightMapLightingGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, mat4x4<f32>(vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w), vec4<f32>(_e78.x, _e78.y, _e78.z, _e78.w), vec4<f32>(_e81.x, _e81.y, _e81.z, _e81.w)), _e105.xy, i32(_e109.x), i32(_e114.x), _e119.x, _e123.x, _e127.x, _e131.x, _e135, _e138, _e141.x, _e145.x, _e149.x, _e153.x, _e157.x);
    fragColor = _e159;
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
