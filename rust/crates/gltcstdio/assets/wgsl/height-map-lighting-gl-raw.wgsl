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
            let _e277 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e261.x / _e265.x), _e268.y) / vec2(2f)) + vec2(0.5f)));
            local = _e277;
        } else {
            local = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e284 = local;
        return _e284;
    }
    let _e285 = k1_;
    k = _e285;
    let _e287 = cameraPos;
    let _e288 = k;
    let _e289 = dir;
    p = (_e287 + (_e288 * _e289));
    let _e293 = backgroundColor;
    color_3 = _e293;
    let _e308 = k2_;
    let _e309 = dk;
    k2_ = (_e308 + _e309);
    let _e311 = heightMap;
    if _e311 {
        {
            loop {
                {
                    let _e312 = dz;
                    prevDz = _e312;
                    let _e313 = h;
                    prevH = _e313;
                    let _e314 = intensity_3;
                    let _e315 = p;
                    let _e320 = global.U[0];
                    let _e323 = p;
                    let _e333 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e315.x / _e320.x), _e323.y) / vec2(2f)) + vec2(0.5f)));
                    let _e334 = height(_e314, _e333);
                    h = _e334;
                    let _e335 = p;
                    let _e337 = h;
                    dz = (_e335.z - _e337);
                    let _e339 = p;
                    let _e340 = step;
                    p = (_e339 + _e340);
                    let _e342 = k;
                    let _e343 = dk;
                    k = (_e342 + _e343);
                    let _e345 = dz;
                    let _e348 = k;
                    let _e349 = k1_;
                    let _e351 = dz;
                    let _e353 = prevDz;
                    stop = ((_e345 == 0f) || ((_e348 != _e349) && (sign(_e351) == -(sign(_e353)))));
                }
                let _e359 = k;
                let _e360 = k2_;
                let _e362 = stop;
                if !(((_e359 <= _e360) && !(_e362))) {
                    break;
                }
            }
            let _e366 = p;
            let _e367 = step;
            pp = (_e366 - _e367).xy;
            let _e371 = pp;
            let _e375 = global.U[0];
            let _e378 = pp;
            let _e387 = textureSample(t_source, samp, ((vec2<f32>((_e371.x / _e375.x), _e378.y) / vec2(2f)) + vec2(0.5f)));
            color_3 = _e387;
            let _e388 = pp;
            let _e389 = step;
            let _e395 = global.U[0];
            let _e398 = pp;
            let _e399 = step;
            let _e410 = textureSample(t_source, samp, ((vec2<f32>(((_e388 - _e389.xy).x / _e395.x), (_e398 - _e399.xy).y) / vec2(2f)) + vec2(0.5f)));
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
                    let _e432 = textureSample(t_source, samp, ((vec2<f32>((_e414.x / _e419.x), _e422.y) / vec2(2f)) + vec2(0.5f)));
                    color_3 = _e432;
                    let _e433 = intensity_3;
                    let _e434 = color_3;
                    let _e435 = height(_e433, _e434);
                    h = _e435;
                    let _e436 = p;
                    let _e438 = h;
                    dz = (_e436.z - _e438);
                    let _e440 = p;
                    let _e441 = step;
                    p = (_e440 + _e441);
                    let _e443 = k;
                    let _e444 = dk;
                    k = (_e443 + _e444);
                    let _e446 = dz;
                    let _e449 = k;
                    let _e450 = k1_;
                    let _e452 = dz;
                    let _e454 = prevDz;
                    stop = ((_e446 == 0f) || ((_e449 != _e450) && (sign(_e452) == -(sign(_e454)))));
                }
                let _e460 = k;
                let _e461 = k2_;
                let _e463 = stop;
                if !(((_e460 <= _e461) && !(_e463))) {
                    break;
                }
            }
        }
    }
    let _e467 = stop;
    if !(_e467) {
        let _e469 = sourceBkg_specified_1;
        if (_e469 == 1i) {
            let _e472 = pos_1;
            let _e476 = global.U[0];
            let _e479 = pos_1;
            let _e488 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e472.x / _e476.x), _e479.y) / vec2(2f)) + vec2(0.5f)));
            local_1 = _e488;
        } else {
            local_1 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e495 = local_1;
        return _e495;
    }
    let _e496 = dz;
    let _e499 = k1_;
    let _e500 = dk;
    let _e502 = k2_;
    if ((_e496 == 0f) || ((_e499 + _e500) > _e502)) {
        local_2 = 1f;
    } else {
        let _e506 = prevDz;
        let _e508 = dz;
        let _e510 = prevDz;
        local_2 = (abs(_e506) / (abs(_e508) + abs(_e510)));
    }
    let _e515 = local_2;
    kk = _e515;
    let _e517 = prevH;
    let _e518 = h;
    let _e519 = kk;
    hh = mix(_e517, _e518, _e519);
    let _e522 = maxZ;
    if (_e522 == 0f) {
        local_3 = 1f;
    } else {
        let _e526 = hh;
        let _e527 = maxZ;
        local_3 = (_e526 / _e527);
    }
    let _e530 = local_3;
    hRatio = _e530;
    let _e532 = colorScheme_1;
    if (_e532 <= 50f) {
        {
            let _e536 = colorScheme_1;
            let _e539 = hRatio;
            darken = (1f + ((_e536 * 0.02f) * _e539));
            let _e543 = prevColor;
            let _e544 = color_3;
            let _e545 = kk;
            let _e548 = darken;
            let _e549 = darken;
            let _e550 = darken;
            color_3 = (mix(_e543, _e544, vec4(_e545)) * vec4<f32>(_e548, _e549, _e550, 1f));
        }
    } else {
        {
            let _e555 = hRatio;
            darken_1 = (1f + _e555);
            let _e558 = colorScheme_1;
            kkk = ((_e558 - 50f) * 0.02f);
            let _e564 = prevColor;
            let _e565 = color_3;
            let _e566 = kk;
            let _e569 = darken_1;
            let _e570 = darken_1;
            let _e571 = darken_1;
            col = (mix(_e564, _e565, vec4(_e566)) * vec4<f32>(_e569, _e570, _e571, 1f));
            let _e576 = col;
            let _e577 = darken_1;
            let _e580 = darken_1;
            let _e583 = darken_1;
            let _e588 = kkk;
            color_3 = mix(_e576, vec4<f32>((_e577 * 0.5f), (_e580 * 0.5f), (_e583 * 0.5f), 1f), vec4(_e588));
        }
    }
    let _e591 = lightPos;
    let _e592 = p;
    lightVec = (_e591 - _e592);
    let _e595 = lightVec;
    lightDir = normalize(_e595);
    let _e602 = sourceColor_3;
    let _e604 = sourceColor_3;
    let _e607 = sourceColor_3;
    shadowing = ((_e602.x + _e604.y) + _e607.z);
    let _e611 = shadowing;
    if (_e611 != 0f) {
        {
            let _e614 = p;
            intersection = _e614;
            let _e625 = normalSmoothing_1;
            N = (1f + ceil((_e625 / 20f)));
            let _e632 = normalSmoothing_1;
            bx = (0.0005f + (_e632 * 0.0001f));
            let _e637 = N;
            if (_e637 >= 2f) {
                let _e640 = bx;
                let _e641 = N;
                local_4 = (_e640 / (_e641 - 1f));
            } else {
                local_4 = 0f;
            }
            let _e647 = local_4;
            sx = _e647;
            let _e649 = heightMap;
            if !(_e649) {
                loop {
                    let _e653 = i;
                    let _e654 = N;
                    if !((_e653 < i32(_e654))) {
                        break;
                    }
                    {
                        let _e661 = bx;
                        let _e662 = i;
                        let _e664 = sx;
                        deltaX_1 = (_e661 + (f32(_e662) * _e664));
                        let _e668 = dzdx;
                        let _e669 = intensity_3;
                        let _e670 = intersection;
                        let _e672 = deltaX_1;
                        let _e674 = intersection;
                        let _e680 = global.U[0];
                        let _e683 = intersection;
                        let _e685 = deltaX_1;
                        let _e687 = intersection;
                        let _e698 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e670.x + _e672), _e674.y).x / _e680.x), vec2<f32>((_e683.x + _e685), _e687.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e699 = height(_e669, _e698);
                        let _e700 = intensity_3;
                        let _e701 = intersection;
                        let _e703 = deltaX_1;
                        let _e705 = intersection;
                        let _e711 = global.U[0];
                        let _e714 = intersection;
                        let _e716 = deltaX_1;
                        let _e718 = intersection;
                        let _e729 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e701.x - _e703), _e705.y).x / _e711.x), vec2<f32>((_e714.x - _e716), _e718.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e730 = height(_e700, _e729);
                        dzdx = (_e668 + (_e699 - _e730));
                    }
                    continuing {
                        let _e658 = i;
                        i = (_e658 + 1i);
                    }
                }
            } else {
                loop {
                    let _e735 = i_1;
                    let _e736 = N;
                    if !((_e735 < i32(_e736))) {
                        break;
                    }
                    {
                        let _e743 = bx;
                        let _e744 = i_1;
                        let _e746 = sx;
                        deltaX_2 = (_e743 + (f32(_e744) * _e746));
                        let _e750 = dzdx;
                        let _e751 = intensity_3;
                        let _e752 = intersection;
                        let _e754 = deltaX_2;
                        let _e756 = intersection;
                        let _e762 = global.U[0];
                        let _e765 = intersection;
                        let _e767 = deltaX_2;
                        let _e769 = intersection;
                        let _e780 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e752.x + _e754), _e756.y).x / _e762.x), vec2<f32>((_e765.x + _e767), _e769.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e781 = height(_e751, _e780);
                        let _e782 = intensity_3;
                        let _e783 = intersection;
                        let _e785 = deltaX_2;
                        let _e787 = intersection;
                        let _e793 = global.U[0];
                        let _e796 = intersection;
                        let _e798 = deltaX_2;
                        let _e800 = intersection;
                        let _e811 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>((_e783.x - _e785), _e787.y).x / _e793.x), vec2<f32>((_e796.x - _e798), _e800.y).y) / vec2(2f)) + vec2(0.5f)));
                        let _e812 = height(_e782, _e811);
                        dzdx = (_e750 + (_e781 - _e812));
                    }
                    continuing {
                        let _e740 = i_1;
                        i_1 = (_e740 + 1i);
                    }
                }
            }
            let _e815 = dzdx;
            let _e816 = N;
            dzdx = (_e815 / _e816);
            let _e818 = bx;
            let _e819 = N;
            let _e824 = sx;
            deltaX = (_e818 + (((_e819 - 1f) / 2f) * _e824));
            let _e828 = normalSmoothing_1;
            by = (0.0005f + (_e828 * 0.0001f));
            let _e833 = N;
            if (_e833 >= 2f) {
                let _e836 = by;
                let _e837 = N;
                local_5 = (_e836 / (_e837 - 1f));
            } else {
                local_5 = 0f;
            }
            let _e843 = local_5;
            sy = _e843;
            let _e845 = heightMap;
            if !(_e845) {
                loop {
                    let _e849 = i_2;
                    let _e850 = N;
                    if !((_e849 < i32(_e850))) {
                        break;
                    }
                    {
                        let _e857 = by;
                        let _e858 = i_2;
                        let _e860 = sy;
                        deltaY_1 = (_e857 + (f32(_e858) * _e860));
                        let _e864 = intensity_3;
                        let _e865 = intersection;
                        let _e867 = intersection;
                        let _e869 = deltaY_1;
                        let _e875 = global.U[0];
                        let _e878 = intersection;
                        let _e880 = intersection;
                        let _e882 = deltaY_1;
                        let _e893 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e865.x, (_e867.y + _e869)).x / _e875.x), vec2<f32>(_e878.x, (_e880.y + _e882)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e894 = height(_e864, _e893);
                        let _e895 = intensity_3;
                        let _e896 = intersection;
                        let _e898 = intersection;
                        let _e900 = deltaY_1;
                        let _e906 = global.U[0];
                        let _e909 = intersection;
                        let _e911 = intersection;
                        let _e913 = deltaY_1;
                        let _e924 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e896.x, (_e898.y - _e900)).x / _e906.x), vec2<f32>(_e909.x, (_e911.y - _e913)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e925 = height(_e895, _e924);
                        dzdy = (_e894 - _e925);
                    }
                    continuing {
                        let _e854 = i_2;
                        i_2 = (_e854 + 1i);
                    }
                }
            } else {
                loop {
                    let _e929 = i_3;
                    let _e930 = N;
                    if !((_e929 < i32(_e930))) {
                        break;
                    }
                    {
                        let _e937 = by;
                        let _e938 = i_3;
                        let _e940 = sy;
                        deltaY_2 = (_e937 + (f32(_e938) * _e940));
                        let _e944 = intensity_3;
                        let _e945 = intersection;
                        let _e947 = intersection;
                        let _e949 = deltaY_2;
                        let _e955 = global.U[0];
                        let _e958 = intersection;
                        let _e960 = intersection;
                        let _e962 = deltaY_2;
                        let _e973 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e945.x, (_e947.y + _e949)).x / _e955.x), vec2<f32>(_e958.x, (_e960.y + _e962)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e974 = height(_e944, _e973);
                        let _e975 = intensity_3;
                        let _e976 = intersection;
                        let _e978 = intersection;
                        let _e980 = deltaY_2;
                        let _e986 = global.U[0];
                        let _e989 = intersection;
                        let _e991 = intersection;
                        let _e993 = deltaY_2;
                        let _e1004 = textureSample(t_sourceElevation, samp, ((vec2<f32>((vec2<f32>(_e976.x, (_e978.y - _e980)).x / _e986.x), vec2<f32>(_e989.x, (_e991.y - _e993)).y) / vec2(2f)) + vec2(0.5f)));
                        let _e1005 = height(_e975, _e1004);
                        dzdy = (_e974 - _e1005);
                    }
                    continuing {
                        let _e934 = i_3;
                        i_3 = (_e934 + 1i);
                    }
                }
            }
            let _e1007 = dzdy;
            let _e1008 = N;
            dzdy = (_e1007 / _e1008);
            let _e1010 = by;
            let _e1011 = N;
            let _e1016 = sy;
            deltaY = (_e1010 + (((_e1011 - 1f) / 2f) * _e1016));
            let _e1021 = deltaY;
            let _e1023 = dzdx;
            let _e1027 = deltaX;
            let _e1029 = dzdy;
            let _e1031 = deltaX;
            let _e1032 = deltaY;
            unormal = vec3<f32>(((-2f * _e1021) * _e1023), ((-2f * _e1027) * _e1029), (_e1031 * _e1032));
            let _e1036 = unormal;
            let _e1040 = unormal;
            let _e1045 = unormal;
            if (((_e1036.x == 0f) && (_e1040.y == 0f)) && (_e1045.z == 0f)) {
                local_6 = vec3<f32>(0f, 0f, 1f);
            } else {
                let _e1054 = unormal;
                local_6 = normalize(_e1054);
            }
            let _e1057 = local_6;
            normal = _e1057;
            let _e1059 = lightDir;
            let _e1060 = normal;
            lighting = ((dot(_e1059, _e1060) + 1f) / 2f);
            let _e1066 = surfaceSmoothness_1;
            if (_e1066 < 100f) {
                {
                    let _e1069 = lighting;
                    if (_e1069 < 0.5f) {
                        let _e1072 = lighting;
                        let _e1076 = surfaceSmoothness_1;
                        lighting = (pow((_e1072 * 2f), (100f / _e1076)) / 2f);
                    } else {
                        let _e1081 = lighting;
                        let _e1087 = surfaceSmoothness_1;
                        lighting = ((pow(((_e1081 - 0.5f) * 2f), (0.01f * _e1087)) / 2f) + 0.5f);
                    }
                }
            }
            let _e1094 = specular_3;
            if (_e1094 != 0f) {
                {
                    let _e1097 = lightDir;
                    let _e1098 = normal;
                    reflectLightDir = reflect(_e1097, _e1098);
                    let _e1101 = specular_3;
                    if (_e1101 < 25f) {
                        let _e1104 = specular_3;
                        local_7 = (_e1104 * 0.04f);
                    } else {
                        local_7 = 1f;
                    }
                    let _e1109 = local_7;
                    let _e1110 = dir;
                    let _e1111 = reflectLightDir;
                    let _e1117 = specular_3;
                    spec = (_e1109 * pow(clamp(dot(_e1110, _e1111), 0f, 1f), (10f - (_e1117 * 0.1f))));
                }
            }
        }
    }
    let _e1123 = shadows_1;
    shad = _e1123;
    let _e1125 = shadowing;
    let _e1128 = shad;
    let _e1132 = intensity_3;
    if (((_e1125 != 0f) && (_e1128 > 0f)) && (_e1132 != 0f)) {
        {
            let _e1136 = p;
            let _e1138 = step;
            p = (_e1136 - (2f * _e1138));
            let _e1141 = lightDir;
            let _e1142 = dk;
            lightStep = (_e1141 * _e1142);
            k1_ = 0f;
            let _e1146 = lightVec;
            k2_1 = length(_e1146);
            let _e1149 = lightDir;
            if (_e1149.x != 0f) {
                {
                    let _e1153 = lightDir;
                    s_3 = sign(_e1153.x);
                    let _e1157 = s_3;
                    let _e1159 = ratio;
                    let _e1161 = p;
                    let _e1164 = lightDir;
                    k3_3 = (((-(_e1157) * _e1159) - _e1161.x) / _e1164.x);
                    let _e1168 = s_3;
                    let _e1169 = ratio;
                    let _e1171 = p;
                    let _e1174 = lightDir;
                    k4_3 = (((_e1168 * _e1169) - _e1171.x) / _e1174.x);
                    let _e1178 = k4_3;
                    if (_e1178 > 0f) {
                        let _e1181 = k2_1;
                        let _e1182 = k4_3;
                        k2_1 = min(_e1181, _e1182);
                    }
                    let _e1184 = k3_3;
                    if (_e1184 > 0f) {
                        let _e1187 = k2_1;
                        let _e1188 = k3_3;
                        k2_1 = min(_e1187, _e1188);
                    }
                }
            }
            let _e1190 = lightDir;
            if (_e1190.y != 0f) {
                {
                    let _e1194 = lightDir;
                    s_4 = sign(_e1194.y);
                    let _e1198 = s_4;
                    let _e1200 = p;
                    let _e1203 = lightDir;
                    k3_4 = ((-(_e1198) - _e1200.y) / _e1203.y);
                    let _e1207 = s_4;
                    let _e1208 = p;
                    let _e1211 = lightDir;
                    k4_4 = ((_e1207 - _e1208.y) / _e1211.y);
                    let _e1215 = k4_4;
                    if (_e1215 > 0f) {
                        let _e1218 = k2_1;
                        let _e1219 = k4_4;
                        k2_1 = min(_e1218, _e1219);
                    }
                    let _e1221 = k3_4;
                    if (_e1221 > 0f) {
                        let _e1224 = k2_1;
                        let _e1225 = k3_4;
                        k2_1 = min(_e1224, _e1225);
                    }
                }
            }
            let _e1227 = maxZ;
            maxZ2_1 = (_e1227 + 0.0001f);
            let _e1231 = lightDir;
            if (_e1231.z != 0f) {
                {
                    let _e1235 = lightDir;
                    s_5 = sign(_e1235.z);
                    let _e1239 = s_5;
                    let _e1241 = maxZ2_1;
                    let _e1243 = p;
                    let _e1246 = lightDir;
                    k3_5 = (((-(_e1239) * _e1241) - _e1243.z) / _e1246.z);
                    let _e1250 = s_5;
                    let _e1251 = maxZ2_1;
                    let _e1253 = p;
                    let _e1256 = lightDir;
                    k4_5 = (((_e1250 * _e1251) - _e1253.z) / _e1256.z);
                    let _e1260 = k4_5;
                    if (_e1260 > 0f) {
                        let _e1263 = k2_1;
                        let _e1264 = k4_5;
                        k2_1 = min(_e1263, _e1264);
                    }
                    let _e1266 = k3_5;
                    if (_e1266 > 0f) {
                        let _e1269 = k2_1;
                        let _e1270 = k3_5;
                        k2_1 = min(_e1269, _e1270);
                    }
                }
            }
            k = 0f;
            h = 0f;
            dz = 0f;
            stop = false;
            let _e1276 = heightMap;
            if _e1276 {
                {
                    loop {
                        {
                            let _e1277 = dz;
                            prevDz = _e1277;
                            let _e1278 = h;
                            prevH = _e1278;
                            let _e1279 = intensity_3;
                            let _e1280 = p;
                            let _e1285 = global.U[0];
                            let _e1288 = p;
                            let _e1298 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e1280.x / _e1285.x), _e1288.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1299 = height(_e1279, _e1298);
                            h = _e1299;
                            let _e1300 = p;
                            let _e1302 = h;
                            dz = (_e1300.z - _e1302);
                            let _e1304 = p;
                            let _e1305 = lightStep;
                            p = (_e1304 + _e1305);
                            let _e1307 = k;
                            let _e1308 = dk;
                            k = (_e1307 + _e1308);
                            let _e1310 = dz;
                            let _e1313 = k;
                            let _e1314 = k1_;
                            let _e1316 = dz;
                            let _e1318 = prevDz;
                            stop = ((_e1310 == 0f) || ((_e1313 != _e1314) && (sign(_e1316) == -(sign(_e1318)))));
                        }
                        let _e1324 = k;
                        let _e1325 = k2_1;
                        let _e1327 = stop;
                        if !(((_e1324 <= _e1325) && !(_e1327))) {
                            break;
                        }
                    }
                }
            } else {
                {
                    loop {
                        {
                            let _e1331 = dz;
                            prevDz = _e1331;
                            let _e1332 = h;
                            prevH = _e1332;
                            let _e1333 = intensity_3;
                            let _e1334 = p;
                            let _e1339 = global.U[0];
                            let _e1342 = p;
                            let _e1352 = textureSample(t_source, samp, ((vec2<f32>((_e1334.x / _e1339.x), _e1342.y) / vec2(2f)) + vec2(0.5f)));
                            let _e1353 = height(_e1333, _e1352);
                            h = _e1353;
                            let _e1354 = p;
                            let _e1356 = h;
                            dz = (_e1354.z - _e1356);
                            let _e1358 = p;
                            let _e1359 = lightStep;
                            p = (_e1358 + _e1359);
                            let _e1361 = k;
                            let _e1362 = dk;
                            k = (_e1361 + _e1362);
                            let _e1364 = dz;
                            let _e1367 = k;
                            let _e1368 = k1_;
                            let _e1370 = dz;
                            let _e1372 = prevDz;
                            stop = ((_e1364 == 0f) || ((_e1367 != _e1368) && (sign(_e1370) == -(sign(_e1372)))));
                        }
                        let _e1378 = k;
                        let _e1379 = k2_1;
                        let _e1381 = stop;
                        if !(((_e1378 <= _e1379) && !(_e1381))) {
                            break;
                        }
                    }
                }
            }
            let _e1385 = stop;
            if _e1385 {
                {
                    let _e1387 = shadows_1;
                    let _e1389 = lighting;
                    lighting = min((1f - _e1387), _e1389);
                    spec = 0f;
                }
            }
        }
    }
    let _e1392 = color_3;
    let _e1393 = lighting;
    let _e1394 = spec;
    let _e1395 = ambientColor_3;
    let _e1396 = sourceColor_3;
    let _e1397 = gamma_3;
    let _e1398 = applyLighting(_e1392, _e1393, _e1394, _e1395, _e1396, _e1397);
    color_3 = _e1398;
    let _e1399 = color_3;
    return clamp(_e1399, vec4(0f), vec4(1f));
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
