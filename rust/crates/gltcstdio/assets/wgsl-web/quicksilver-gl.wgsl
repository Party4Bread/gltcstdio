struct Params {
    U: array<vec4<f32>, 23>,
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

fn qsApplyLighting(baseColor: vec4<f32>, reflectColor: vec4<f32>, fromSource: f32, specular: f32, ambientColor: vec4<f32>, sourceColor: vec4<f32>, gamma: f32) -> vec4<f32> {
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
    let _e20 = ambientColor_1;
    let _e22 = sourceColor_1;
    sumRGB = ((_e20.xyz + _e22.xyz) + vec3(1f));
    let _e29 = sumRGB;
    let _e31 = sumRGB;
    let _e34 = sumRGB;
    maxLum = max(max(_e29.x, _e31.y), _e34.z);
    let _e38 = maxLum;
    if (_e38 == 0f) {
        return vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e46 = reflectColor_1;
    let _e48 = baseColor_1;
    let _e50 = ambientColor_1;
    let _e54 = baseColor_1;
    let _e56 = sourceColor_1;
    let _e59 = fromSource_1;
    let _e62 = sourceColor_1;
    let _e64 = specular_1;
    let _e67 = maxLum;
    color = ((((_e46.xyz + (_e48.xyz * _e50.xyz)) + ((_e54.xyz * _e56.xyz) * _e59)) + (_e62.xyz * _e64)) / vec3(_e67));
    let _e71 = color;
    let _e73 = color;
    let _e76 = color;
    lum = (((_e71.x + _e73.y) + _e76.z) / 3f);
    let _e82 = lum;
    let _e85 = gamma_1;
    if ((_e82 > 0f) && (_e85 != 0f)) {
        {
            let _e89 = lum;
            let _e91 = gamma_1;
            gammaCorrectedLum = pow(_e89, pow(1.02f, -(_e91)));
            let _e96 = color;
            let _e97 = gammaCorrectedLum;
            let _e99 = lum;
            color = ((_e96 * _e97) / vec3(_e99));
        }
    }
    let _e102 = color;
    let _e103 = baseColor_1;
    return clamp(vec4<f32>(_e102.x, _e102.y, _e102.z, _e103.w), vec4(0f), vec4(1f));
}

fn qsHeight(intensity: f32, color_1: vec4<f32>) -> f32 {
    var intensity_1: f32;
    var color_2: vec4<f32>;

    intensity_1 = intensity;
    color_2 = color_1;
    let _e10 = intensity_1;
    let _e13 = color_2;
    let _e15 = color_2;
    let _e18 = color_2;
    return ((_e10 * 0.04f) * ((((_e13.x + _e15.y) + _e18.z) / 3f) - 0.5f));
}

fn quicksilverGl(pos: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, intensity_2: f32, colorScheme: f32, gamma_2: f32, specular_2: f32, surfaceSmoothness: f32, normalSmoothing: f32, shadows: f32, lightDistance: f32, lightAngleX: f32, lightAngleY: f32, sourceColor_2: vec4<f32>, ambientColor_2: vec4<f32>, backgroundStyle: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_3: f32;
    var colorScheme_1: f32;
    var gamma_3: f32;
    var specular_3: f32;
    var surfaceSmoothness_1: f32;
    var normalSmoothing_1: f32;
    var shadows_1: f32;
    var lightDistance_1: f32;
    var lightAngleX_1: f32;
    var lightAngleY_1: f32;
    var sourceColor_3: vec4<f32>;
    var ambientColor_3: vec4<f32>;
    var backgroundStyle_1: i32;
    var invModelTransform: mat4x4<f32>;
    var _caX: f32;
    var _saX: f32;
    var _caY: f32;
    var _saY: f32;
    var lightPos: vec3<f32>;
    var intensityScaled: f32;
    var intensityAbs: f32;
    var D: f32 = 1f;
    var cameraPos: vec3<f32>;
    var dir: vec3<f32>;
    var maxZ: f32;
    var ratio: f32;
    var dk: f32;
    var step: vec3<f32>;
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
    var _bkgMiss: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var _o_n: vec3<f32>;
    var _o_alpha: f32;
    var _o_beta: f32;
    var _o_pos: vec2<f32>;
    var _o_m: f32;
    var _o_darken: f32;
    var _o_ratio: f32;
    var _o_X: f32 = 0.5f;
    var _o_Y: f32 = 0.5f;
    var k: f32;
    var p: vec3<f32>;
    var color_3: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var prevColor: vec4<f32>;
    var h: f32 = 0f;
    var prevH: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32 = 0f;
    var stop: bool = false;
    var local: f32;
    var kk: f32;
    var hh: f32;
    var lightVec: vec3<f32>;
    var lightDir: vec3<f32>;
    var shadowing: f32;
    var intersection: vec3<f32>;
    var N: f32;
    var bx: f32;
    var local_1: f32;
    var sx: f32;
    var dzdx: f32 = 0f;
    var i: i32 = 0i;
    var deltaX: f32;
    var deltaX_1: f32;
    var by: f32;
    var local_2: f32;
    var sy: f32;
    var dzdy: f32 = 0f;
    var i_1: i32 = 0i;
    var deltaY: f32;
    var deltaY_1: f32;
    var unormal: vec3<f32>;
    var local_3: vec3<f32>;
    var normal: vec3<f32>;
    var lighting: f32;
    var reflected: vec3<f32>;
    var surfaceColor: vec4<f32>;
    var reflectiveColor: vec4<f32>;
    var _reflBkg: vec4<f32> = vec4(0f);
    var _o_n_1: vec3<f32>;
    var _o_alpha_1: f32;
    var _o_beta_1: f32;
    var _o_pos_1: vec2<f32>;
    var _o_m_1: f32;
    var _o_darken_1: f32;
    var _o_ratio_1: f32;
    var _o_X_1: f32 = 0.5f;
    var _o_Y_1: f32 = 0.5f;
    var reflectColor_2: vec4<f32>;
    var spec: f32 = 0f;
    var reflectLightDir: vec3<f32>;
    var shad: f32;
    var lightStep: vec3<f32>;
    var k2s: f32;
    var s_3: f32;
    var k3_3: f32;
    var k4_3: f32;
    var s_4: f32;
    var k3_4: f32;
    var k4_4: f32;
    var maxZ2s: f32;
    var s_5: f32;
    var k3_5: f32;
    var k4_5: f32;
    var ks: f32 = 0f;
    var sstop: bool = false;

    pos_1 = pos;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    intensity_3 = intensity_2;
    colorScheme_1 = colorScheme;
    gamma_3 = gamma_2;
    specular_3 = specular_2;
    surfaceSmoothness_1 = surfaceSmoothness;
    normalSmoothing_1 = normalSmoothing;
    shadows_1 = shadows;
    lightDistance_1 = lightDistance;
    lightAngleX_1 = lightAngleX;
    lightAngleY_1 = lightAngleY;
    sourceColor_3 = sourceColor_2;
    ambientColor_3 = ambientColor_2;
    backgroundStyle_1 = backgroundStyle;
    let _e40 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e40);
    let _e43 = lightAngleX_1;
    _caX = cos(_e43);
    let _e46 = lightAngleX_1;
    _saX = sin(_e46);
    let _e49 = lightAngleY_1;
    _caY = cos(_e49);
    let _e52 = lightAngleY_1;
    _saY = sin(_e52);
    let _e55 = lightDistance_1;
    let _e56 = _caX;
    let _e58 = _saY;
    let _e60 = lightDistance_1;
    let _e62 = _saX;
    let _e64 = lightDistance_1;
    let _e65 = _caX;
    let _e67 = _caY;
    lightPos = vec3<f32>(((_e55 * _e56) * _e58), (-(_e60) * _e62), ((_e64 * _e65) * _e67));
    let _e71 = intensity_3;
    intensityScaled = (pow((_e71 * 0.01f), 4f) * 100f);
    let _e79 = intensity_3;
    intensityAbs = abs(_e79);
    let _e84 = invModelTransform;
    cameraPos = (_e84 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e93 = invModelTransform;
    let _e103 = pos_1;
    let _e105 = D;
    let _e107 = pos_1;
    let _e109 = D;
    dir = normalize((mat3x3<f32>(_e93[0].xyz, _e93[1].xyz, _e93[2].xyz) * vec3<f32>((_e103.x * _e105), (_e107.y * _e109), -1f)));
    let _e117 = intensityAbs;
    maxZ = (_e117 * 0.02f);
    let _e121 = sourceDim_1;
    let _e123 = sourceDim_1;
    ratio = (_e121.x / _e123.y);
    let _e128 = sourceDim_1;
    dk = (2f / _e128.y);
    let _e132 = dir;
    let _e133 = dk;
    step = (_e132 * _e133);
    let _e140 = dir;
    if (_e140.x != 0f) {
        {
            let _e144 = dir;
            s = sign(_e144.x);
            let _e148 = s;
            let _e150 = ratio;
            let _e152 = cameraPos;
            let _e155 = dir;
            k3_ = (((-(_e148) * _e150) - _e152.x) / _e155.x);
            let _e159 = s;
            let _e160 = ratio;
            let _e162 = cameraPos;
            let _e165 = dir;
            k4_ = (((_e159 * _e160) - _e162.x) / _e165.x);
            let _e169 = k1_;
            let _e170 = k3_;
            k1_ = max(_e169, _e170);
            let _e172 = k2_;
            let _e173 = k4_;
            k2_ = min(_e172, _e173);
        }
    }
    let _e175 = dir;
    if (_e175.y != 0f) {
        {
            let _e179 = dir;
            s_1 = sign(_e179.y);
            let _e183 = s_1;
            let _e185 = cameraPos;
            let _e188 = dir;
            k3_1 = ((-(_e183) - _e185.y) / _e188.y);
            let _e192 = s_1;
            let _e193 = cameraPos;
            let _e196 = dir;
            k4_1 = ((_e192 - _e193.y) / _e196.y);
            let _e200 = k1_;
            let _e201 = k3_1;
            k1_ = max(_e200, _e201);
            let _e203 = k2_;
            let _e204 = k4_1;
            k2_ = min(_e203, _e204);
        }
    }
    let _e206 = maxZ;
    maxZ2_ = (_e206 + 0.0001f);
    let _e210 = dir;
    if (_e210.z != 0f) {
        {
            let _e214 = dir;
            s_2 = sign(_e214.z);
            let _e218 = s_2;
            let _e220 = maxZ2_;
            let _e222 = cameraPos;
            let _e225 = dir;
            k3_2 = (((-(_e218) * _e220) - _e222.z) / _e225.z);
            let _e229 = s_2;
            let _e230 = maxZ2_;
            let _e232 = cameraPos;
            let _e235 = dir;
            k4_2 = (((_e229 * _e230) - _e232.z) / _e235.z);
            let _e239 = k1_;
            let _e240 = k3_2;
            k1_ = max(_e239, _e240);
            let _e242 = k2_;
            let _e243 = k4_2;
            k2_ = min(_e242, _e243);
        }
    }
    let _e251 = backgroundStyle_1;
    if (_e251 == 0i) {
        {
            let _e254 = dir;
            _o_n = normalize(_e254);
            let _e257 = _o_n;
            let _e259 = _o_n;
            _o_alpha = atan2(_e257.z, _e259.x);
            let _e263 = _o_n;
            _o_beta = asin(_e263.y);
            let _e267 = _o_alpha;
            let _e274 = _o_beta;
            let _e282 = global.U[0];
            let _e285 = _o_alpha;
            let _e292 = _o_beta;
            let _e306 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e267) / 3.1415927f) * 2f), ((2f * _e274) / 3.1415927f)).x / _e282.x), vec2<f32>(((-(_e285) / 3.1415927f) * 2f), ((2f * _e292) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _bkgMiss = _e306;
        }
    } else {
        let _e307 = backgroundStyle_1;
        if (_e307 == 1i) {
            {
                let _e310 = dir;
                let _e313 = dir;
                let _e316 = sourceDim_1;
                let _e319 = sourceDim_1;
                let _e322 = dir;
                let _e325 = dir;
                _o_pos = vec2<f32>((((-(_e310.x) / _e313.z) * _e316.y) / _e319.x), (-(_e322.y) / _e325.z));
                let _e330 = _o_pos;
                let _e333 = _o_pos;
                _o_m = max(abs(_e330.x), abs(_e333.y));
                let _e340 = _o_m;
                _o_darken = (4f / max(4f, _e340));
                let _e344 = _o_pos;
                let _e348 = global.U[0];
                let _e351 = _o_pos;
                let _e361 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e344.x / _e348.x), _e351.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e362 = _o_darken;
                let _e363 = _o_darken;
                let _e364 = _o_darken;
                _bkgMiss = (_e361 * vec4<f32>(_e362, _e363, _e364, 1f));
            }
        } else {
            let _e368 = backgroundStyle_1;
            if (_e368 == 2i) {
                {
                    let _e371 = sourceDim_1;
                    let _e373 = sourceDim_1;
                    _o_ratio = (_e371.y / _e373.x);
                    let _e381 = dir;
                    let _e384 = dir;
                    let _e387 = _o_ratio;
                    let _e390 = dir;
                    let _e393 = dir;
                    let _e396 = _o_ratio;
                    if ((abs(_e381.y) > (abs(_e384.z) * _e387)) && (abs(_e390.y) > (abs(_e393.x) * _e396))) {
                        {
                            let _e400 = _o_X;
                            let _e401 = dir;
                            let _e404 = dir;
                            _o_X = (_e400 + ((-(_e401.x) / _e404.y) * 0.5f));
                            let _e410 = _o_Y;
                            let _e411 = dir;
                            let _e414 = dir;
                            _o_Y = (_e410 + ((-(_e411.z) / _e414.y) * 0.5f));
                        }
                    } else {
                        let _e420 = dir;
                        let _e423 = dir;
                        if (abs(_e420.x) < abs(_e423.z)) {
                            {
                                let _e427 = _o_X;
                                let _e428 = dir;
                                let _e430 = dir;
                                let _e434 = _o_ratio;
                                let _e438 = dir;
                                _o_X = (_e427 + ((((_e428.x / abs(_e430.z)) * _e434) * 0.5f) * -(sign(_e438.z))));
                                let _e444 = _o_Y;
                                let _e445 = dir;
                                let _e447 = dir;
                                _o_Y = (_e444 + ((_e445.y / abs(_e447.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e454 = _o_X;
                                let _e455 = dir;
                                let _e457 = dir;
                                let _e461 = _o_ratio;
                                let _e465 = dir;
                                _o_X = (_e454 + ((((_e455.z / abs(_e457.x)) * _e461) * 0.5f) * -(sign(_e465.x))));
                                let _e471 = _o_Y;
                                let _e472 = dir;
                                let _e474 = dir;
                                _o_Y = (_e471 + ((_e472.y / abs(_e474.x)) * 0.5f));
                            }
                        }
                    }
                    let _e481 = _o_X;
                    let _e482 = _o_Y;
                    let _e492 = global.U[0];
                    let _e495 = _o_X;
                    let _e496 = _o_Y;
                    let _e512 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e481, _e482) * 2f) - vec2(1f)).x / _e492.x), ((vec2<f32>(_e495, _e496) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _bkgMiss = _e512;
                }
            } else {
                {
                    let _e513 = dir;
                    let _e518 = ((_e513 * 0.5f) + vec3(0.5f));
                    _bkgMiss = vec4<f32>(_e518.x, _e518.y, _e518.z, 1f);
                }
            }
        }
    }
    let _e524 = k1_;
    let _e525 = k2_;
    if (_e524 > _e525) {
        let _e527 = _bkgMiss;
        return _e527;
    }
    let _e528 = k1_;
    k = _e528;
    let _e530 = cameraPos;
    let _e531 = k;
    let _e532 = dir;
    p = (_e530 + (_e531 * _e532));
    let _e542 = color_3;
    prevColor = _e542;
    loop {
        {
            let _e554 = color_3;
            prevColor = _e554;
            let _e555 = dz;
            prevDz = _e555;
            let _e556 = h;
            prevH = _e556;
            let _e557 = p;
            let _e562 = global.U[0];
            let _e565 = p;
            let _e576 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e557.x / _e562.x), _e565.y) / vec2(2f)) + vec2(0.5f)), 0f);
            color_3 = _e576;
            let _e577 = intensityScaled;
            let _e578 = color_3;
            let _e579 = qsHeight(_e577, _e578);
            h = _e579;
            let _e580 = p;
            let _e582 = h;
            dz = (_e580.z - _e582);
            let _e584 = p;
            let _e585 = step;
            p = (_e584 + _e585);
            let _e587 = k;
            let _e588 = dk;
            k = (_e587 + _e588);
            let _e590 = dz;
            let _e593 = k;
            let _e594 = k1_;
            let _e596 = dz;
            let _e598 = prevDz;
            stop = ((_e590 == 0f) || ((_e593 != _e594) && (sign(_e596) == -(sign(_e598)))));
        }
        let _e604 = k;
        let _e605 = k2_;
        let _e607 = stop;
        if !(((_e604 <= _e605) && !(_e607))) {
            break;
        }
    }
    let _e611 = stop;
    let _e612 = dz;
    let _e614 = dk;
    stop = (_e611 || (abs(_e612) < _e614));
    let _e617 = stop;
    if !(_e617) {
        let _e619 = _bkgMiss;
        return _e619;
    }
    let _e620 = dz;
    let _e623 = k1_;
    let _e624 = dk;
    let _e626 = k2_;
    if ((_e620 == 0f) || ((_e623 + _e624) > _e626)) {
        local = 1f;
    } else {
        let _e630 = prevDz;
        let _e632 = dz;
        let _e634 = prevDz;
        local = (abs(_e630) / (abs(_e632) + abs(_e634)));
    }
    let _e639 = local;
    kk = _e639;
    let _e641 = prevH;
    let _e642 = h;
    let _e643 = kk;
    hh = mix(_e641, _e642, _e643);
    let _e646 = lightPos;
    let _e647 = p;
    lightVec = (_e646 - _e647);
    let _e650 = lightVec;
    lightDir = normalize(_e650);
    let _e653 = sourceColor_3;
    let _e655 = sourceColor_3;
    let _e658 = sourceColor_3;
    shadowing = ((_e653.x + _e655.y) + _e658.z);
    let _e662 = p;
    intersection = _e662;
    let _e665 = normalSmoothing_1;
    N = (1f + ceil((_e665 / 20f)));
    let _e672 = normalSmoothing_1;
    bx = (0.0005f + (_e672 * 0.0001f));
    let _e677 = N;
    if (_e677 >= 2f) {
        let _e680 = bx;
        let _e681 = N;
        local_1 = (_e680 / (_e681 - 1f));
    } else {
        local_1 = 0f;
    }
    let _e687 = local_1;
    sx = _e687;
    loop {
        let _e693 = i;
        let _e694 = N;
        if !((_e693 < i32(_e694))) {
            break;
        }
        {
            let _e701 = bx;
            let _e702 = i;
            let _e704 = sx;
            deltaX = (_e701 + (f32(_e702) * _e704));
            let _e708 = dzdx;
            let _e709 = intensityScaled;
            let _e710 = intersection;
            let _e712 = deltaX;
            let _e714 = intersection;
            let _e720 = global.U[0];
            let _e723 = intersection;
            let _e725 = deltaX;
            let _e727 = intersection;
            let _e739 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e710.x + _e712), _e714.y).x / _e720.x), vec2<f32>((_e723.x + _e725), _e727.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e740 = qsHeight(_e709, _e739);
            let _e741 = intensityScaled;
            let _e742 = intersection;
            let _e744 = deltaX;
            let _e746 = intersection;
            let _e752 = global.U[0];
            let _e755 = intersection;
            let _e757 = deltaX;
            let _e759 = intersection;
            let _e771 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((_e742.x - _e744), _e746.y).x / _e752.x), vec2<f32>((_e755.x - _e757), _e759.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e772 = qsHeight(_e741, _e771);
            dzdx = (_e708 + (_e740 - _e772));
        }
        continuing {
            let _e698 = i;
            i = (_e698 + 1i);
        }
    }
    let _e775 = dzdx;
    let _e776 = N;
    dzdx = (_e775 / _e776);
    let _e778 = bx;
    let _e779 = N;
    let _e784 = sx;
    deltaX_1 = (_e778 + (((_e779 - 1f) / 2f) * _e784));
    let _e789 = normalSmoothing_1;
    by = (0.0005f + (_e789 * 0.0001f));
    let _e794 = N;
    if (_e794 >= 2f) {
        let _e797 = by;
        let _e798 = N;
        local_2 = (_e797 / (_e798 - 1f));
    } else {
        local_2 = 0f;
    }
    let _e804 = local_2;
    sy = _e804;
    loop {
        let _e810 = i_1;
        let _e811 = N;
        if !((_e810 < i32(_e811))) {
            break;
        }
        {
            let _e818 = by;
            let _e819 = i_1;
            let _e821 = sy;
            deltaY = (_e818 + (f32(_e819) * _e821));
            let _e825 = dzdy;
            let _e826 = intensityScaled;
            let _e827 = intersection;
            let _e829 = intersection;
            let _e831 = deltaY;
            let _e837 = global.U[0];
            let _e840 = intersection;
            let _e842 = intersection;
            let _e844 = deltaY;
            let _e856 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e827.x, (_e829.y + _e831)).x / _e837.x), vec2<f32>(_e840.x, (_e842.y + _e844)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e857 = qsHeight(_e826, _e856);
            let _e858 = intensityScaled;
            let _e859 = intersection;
            let _e861 = intersection;
            let _e863 = deltaY;
            let _e869 = global.U[0];
            let _e872 = intersection;
            let _e874 = intersection;
            let _e876 = deltaY;
            let _e888 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e859.x, (_e861.y - _e863)).x / _e869.x), vec2<f32>(_e872.x, (_e874.y - _e876)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e889 = qsHeight(_e858, _e888);
            dzdy = (_e825 + (_e857 - _e889));
        }
        continuing {
            let _e815 = i_1;
            i_1 = (_e815 + 1i);
        }
    }
    let _e892 = dzdy;
    let _e893 = N;
    dzdy = (_e892 / _e893);
    let _e895 = by;
    let _e896 = N;
    let _e901 = sy;
    deltaY_1 = (_e895 + (((_e896 - 1f) / 2f) * _e901));
    let _e907 = deltaY_1;
    let _e909 = dzdx;
    let _e913 = deltaX_1;
    let _e915 = dzdy;
    let _e917 = deltaX_1;
    let _e918 = deltaY_1;
    unormal = vec3<f32>(((-2f * _e907) * _e909), ((-2f * _e913) * _e915), (_e917 * _e918));
    let _e922 = unormal;
    let _e926 = unormal;
    let _e931 = unormal;
    if (((_e922.x == 0f) && (_e926.y == 0f)) && (_e931.z == 0f)) {
        local_3 = vec3<f32>(0f, 0f, 1f);
    } else {
        let _e940 = unormal;
        local_3 = normalize(_e940);
    }
    let _e943 = local_3;
    normal = _e943;
    let _e945 = lightDir;
    let _e946 = normal;
    lighting = ((dot(_e945, _e946) + 1f) / 2f);
    let _e953 = dir;
    let _e954 = normal;
    reflected = reflect(_e953, _e954);
    let _e957 = prevColor;
    let _e958 = color_3;
    let _e959 = kk;
    surfaceColor = mix(_e957, _e958, vec4(_e959));
    let _e966 = surfaceColor;
    let _e968 = colorScheme_1;
    reflectiveColor = mix(vec4(1f), (1.5f * _e966), vec4((_e968 * 0.01f)));
    let _e977 = backgroundStyle_1;
    if (_e977 == 0i) {
        {
            let _e980 = reflected;
            _o_n_1 = normalize(_e980);
            let _e983 = _o_n_1;
            let _e985 = _o_n_1;
            _o_alpha_1 = atan2(_e983.z, _e985.x);
            let _e989 = _o_n_1;
            _o_beta_1 = asin(_e989.y);
            let _e993 = _o_alpha_1;
            let _e1000 = _o_beta_1;
            let _e1008 = global.U[0];
            let _e1011 = _o_alpha_1;
            let _e1018 = _o_beta_1;
            let _e1032 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e993) / 3.1415927f) * 2f), ((2f * _e1000) / 3.1415927f)).x / _e1008.x), vec2<f32>(((-(_e1011) / 3.1415927f) * 2f), ((2f * _e1018) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
            _reflBkg = _e1032;
        }
    } else {
        let _e1033 = backgroundStyle_1;
        if (_e1033 == 1i) {
            {
                let _e1036 = reflected;
                let _e1039 = reflected;
                let _e1042 = sourceDim_1;
                let _e1045 = sourceDim_1;
                let _e1048 = reflected;
                let _e1051 = reflected;
                _o_pos_1 = vec2<f32>((((-(_e1036.x) / _e1039.z) * _e1042.y) / _e1045.x), (-(_e1048.y) / _e1051.z));
                let _e1056 = _o_pos_1;
                let _e1059 = _o_pos_1;
                _o_m_1 = max(abs(_e1056.x), abs(_e1059.y));
                let _e1066 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e1066));
                let _e1070 = _o_pos_1;
                let _e1074 = global.U[0];
                let _e1077 = _o_pos_1;
                let _e1087 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1070.x / _e1074.x), _e1077.y) / vec2(2f)) + vec2(0.5f)), 0f);
                let _e1088 = _o_darken_1;
                let _e1089 = _o_darken_1;
                let _e1090 = _o_darken_1;
                _reflBkg = (_e1087 * vec4<f32>(_e1088, _e1089, _e1090, 1f));
            }
        } else {
            let _e1094 = backgroundStyle_1;
            if (_e1094 == 2i) {
                {
                    let _e1097 = sourceDim_1;
                    let _e1099 = sourceDim_1;
                    _o_ratio_1 = (_e1097.y / _e1099.x);
                    let _e1107 = reflected;
                    let _e1110 = reflected;
                    let _e1113 = _o_ratio_1;
                    let _e1116 = reflected;
                    let _e1119 = reflected;
                    let _e1122 = _o_ratio_1;
                    if ((abs(_e1107.y) > (abs(_e1110.z) * _e1113)) && (abs(_e1116.y) > (abs(_e1119.x) * _e1122))) {
                        {
                            let _e1126 = _o_X_1;
                            let _e1127 = reflected;
                            let _e1130 = reflected;
                            _o_X_1 = (_e1126 + ((-(_e1127.x) / _e1130.y) * 0.5f));
                            let _e1136 = _o_Y_1;
                            let _e1137 = reflected;
                            let _e1140 = reflected;
                            _o_Y_1 = (_e1136 + ((-(_e1137.z) / _e1140.y) * 0.5f));
                        }
                    } else {
                        let _e1146 = reflected;
                        let _e1149 = reflected;
                        if (abs(_e1146.x) < abs(_e1149.z)) {
                            {
                                let _e1153 = _o_X_1;
                                let _e1154 = reflected;
                                let _e1156 = reflected;
                                let _e1160 = _o_ratio_1;
                                let _e1164 = reflected;
                                _o_X_1 = (_e1153 + ((((_e1154.x / abs(_e1156.z)) * _e1160) * 0.5f) * -(sign(_e1164.z))));
                                let _e1170 = _o_Y_1;
                                let _e1171 = reflected;
                                let _e1173 = reflected;
                                _o_Y_1 = (_e1170 + ((_e1171.y / abs(_e1173.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e1180 = _o_X_1;
                                let _e1181 = reflected;
                                let _e1183 = reflected;
                                let _e1187 = _o_ratio_1;
                                let _e1191 = reflected;
                                _o_X_1 = (_e1180 + ((((_e1181.z / abs(_e1183.x)) * _e1187) * 0.5f) * -(sign(_e1191.x))));
                                let _e1197 = _o_Y_1;
                                let _e1198 = reflected;
                                let _e1200 = reflected;
                                _o_Y_1 = (_e1197 + ((_e1198.y / abs(_e1200.x)) * 0.5f));
                            }
                        }
                    }
                    let _e1207 = _o_X_1;
                    let _e1208 = _o_Y_1;
                    let _e1218 = global.U[0];
                    let _e1221 = _o_X_1;
                    let _e1222 = _o_Y_1;
                    let _e1238 = textureSampleLevel(t_source, samp, ((vec2<f32>((((vec2<f32>(_e1207, _e1208) * 2f) - vec2(1f)).x / _e1218.x), ((vec2<f32>(_e1221, _e1222) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    _reflBkg = _e1238;
                }
            } else {
                {
                    let _e1239 = reflected;
                    let _e1244 = ((_e1239 * 0.5f) + vec3(0.5f));
                    _reflBkg = vec4<f32>(_e1244.x, _e1244.y, _e1244.z, 1f);
                }
            }
        }
    }
    let _e1250 = reflectiveColor;
    let _e1251 = _reflBkg;
    reflectColor_2 = (_e1250 * _e1251);
    let _e1254 = surfaceSmoothness_1;
    if (_e1254 < 100f) {
        {
            let _e1257 = lighting;
            if (_e1257 < 0.5f) {
                let _e1260 = lighting;
                let _e1264 = surfaceSmoothness_1;
                lighting = (pow((_e1260 * 2f), (100f / _e1264)) / 2f);
            } else {
                let _e1269 = lighting;
                let _e1275 = surfaceSmoothness_1;
                lighting = ((pow(((_e1269 - 0.5f) * 2f), (0.01f * _e1275)) / 2f) + 0.5f);
            }
        }
    }
    let _e1284 = specular_3;
    if (_e1284 != 0f) {
        {
            let _e1287 = lightDir;
            let _e1288 = normal;
            reflectLightDir = reflect(_e1287, _e1288);
            let _e1291 = dir;
            let _e1292 = reflectLightDir;
            let _e1298 = specular_3;
            spec = pow(clamp(dot(_e1291, _e1292), 0f, 1f), (10f - (_e1298 * 0.1f)));
        }
    }
    let _e1303 = shadows_1;
    shad = (_e1303 * 0.01f);
    let _e1307 = shadowing;
    let _e1310 = shad;
    let _e1314 = intensity_3;
    if (((_e1307 != 0f) && (_e1310 > 0f)) && (_e1314 != 0f)) {
        {
            let _e1318 = p;
            let _e1320 = step;
            p = (_e1318 - (2f * _e1320));
            let _e1323 = lightDir;
            let _e1324 = dk;
            lightStep = (_e1323 * _e1324);
            k1_ = 0f;
            let _e1328 = lightVec;
            k2s = length(_e1328);
            let _e1331 = lightDir;
            if (_e1331.x != 0f) {
                {
                    let _e1335 = lightDir;
                    s_3 = sign(_e1335.x);
                    let _e1339 = s_3;
                    let _e1341 = ratio;
                    let _e1343 = p;
                    let _e1346 = lightDir;
                    k3_3 = (((-(_e1339) * _e1341) - _e1343.x) / _e1346.x);
                    let _e1350 = s_3;
                    let _e1351 = ratio;
                    let _e1353 = p;
                    let _e1356 = lightDir;
                    k4_3 = (((_e1350 * _e1351) - _e1353.x) / _e1356.x);
                    let _e1360 = k4_3;
                    if (_e1360 > 0f) {
                        let _e1363 = k2s;
                        let _e1364 = k4_3;
                        k2s = min(_e1363, _e1364);
                    }
                    let _e1366 = k3_3;
                    if (_e1366 > 0f) {
                        let _e1369 = k2s;
                        let _e1370 = k3_3;
                        k2s = min(_e1369, _e1370);
                    }
                }
            }
            let _e1372 = lightDir;
            if (_e1372.y != 0f) {
                {
                    let _e1376 = lightDir;
                    s_4 = sign(_e1376.y);
                    let _e1380 = s_4;
                    let _e1382 = p;
                    let _e1385 = lightDir;
                    k3_4 = ((-(_e1380) - _e1382.y) / _e1385.y);
                    let _e1389 = s_4;
                    let _e1390 = p;
                    let _e1393 = lightDir;
                    k4_4 = ((_e1389 - _e1390.y) / _e1393.y);
                    let _e1397 = k4_4;
                    if (_e1397 > 0f) {
                        let _e1400 = k2s;
                        let _e1401 = k4_4;
                        k2s = min(_e1400, _e1401);
                    }
                    let _e1403 = k3_4;
                    if (_e1403 > 0f) {
                        let _e1406 = k2s;
                        let _e1407 = k3_4;
                        k2s = min(_e1406, _e1407);
                    }
                }
            }
            let _e1409 = maxZ;
            maxZ2s = (_e1409 + 0.0001f);
            let _e1413 = lightDir;
            if (_e1413.z != 0f) {
                {
                    let _e1417 = lightDir;
                    s_5 = sign(_e1417.z);
                    let _e1421 = s_5;
                    let _e1423 = maxZ2s;
                    let _e1425 = p;
                    let _e1428 = lightDir;
                    k3_5 = (((-(_e1421) * _e1423) - _e1425.z) / _e1428.z);
                    let _e1432 = s_5;
                    let _e1433 = maxZ2s;
                    let _e1435 = p;
                    let _e1438 = lightDir;
                    k4_5 = (((_e1432 * _e1433) - _e1435.z) / _e1438.z);
                    let _e1442 = k4_5;
                    if (_e1442 > 0f) {
                        let _e1445 = k2s;
                        let _e1446 = k4_5;
                        k2s = min(_e1445, _e1446);
                    }
                    let _e1448 = k3_5;
                    if (_e1448 > 0f) {
                        let _e1451 = k2s;
                        let _e1452 = k3_5;
                        k2s = min(_e1451, _e1452);
                    }
                }
            }
            h = 0f;
            prevH = 0f;
            dz = 0f;
            prevDz = 0f;
            loop {
                {
                    let _e1462 = dz;
                    prevDz = _e1462;
                    let _e1463 = h;
                    prevH = _e1463;
                    let _e1464 = intensityScaled;
                    let _e1465 = p;
                    let _e1470 = global.U[0];
                    let _e1473 = p;
                    let _e1484 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1465.x / _e1470.x), _e1473.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e1485 = qsHeight(_e1464, _e1484);
                    h = _e1485;
                    let _e1486 = p;
                    let _e1488 = h;
                    dz = (_e1486.z - _e1488);
                    let _e1490 = p;
                    let _e1491 = lightStep;
                    p = (_e1490 + _e1491);
                    let _e1493 = ks;
                    let _e1494 = dk;
                    ks = (_e1493 + _e1494);
                    let _e1496 = dz;
                    let _e1499 = ks;
                    let _e1502 = dz;
                    let _e1504 = prevDz;
                    sstop = ((_e1496 == 0f) || ((_e1499 != 0f) && (sign(_e1502) == -(sign(_e1504)))));
                }
                let _e1510 = ks;
                let _e1511 = k2s;
                let _e1513 = sstop;
                if !(((_e1510 <= _e1511) && !(_e1513))) {
                    break;
                }
            }
            let _e1517 = sstop;
            if _e1517 {
                {
                    let _e1519 = shad;
                    let _e1521 = lighting;
                    lighting = min((1f - _e1519), _e1521);
                    spec = 0f;
                }
            }
        }
    }
    let _e1524 = surfaceColor;
    let _e1525 = reflectColor_2;
    let _e1526 = lighting;
    let _e1527 = spec;
    let _e1528 = ambientColor_3;
    let _e1529 = sourceColor_3;
    let _e1530 = gamma_3;
    let _e1531 = qsApplyLighting(_e1524, _e1525, _e1526, _e1527, _e1528, _e1529, _e1530);
    return _e1531;
}

fn main_1() {
    let _e8 = global.U[1];
    let _e9 = _e8.xyz;
    let _e12 = global.U[2];
    let _e13 = _e12.xyz;
    let _e16 = global.U[3];
    let _e17 = _e16.xyz;
    let _e32 = v_uv_1;
    let _e40 = global.U[0];
    let _e44 = (((_e32 - vec2(0.5f)) * 2f) * vec2<f32>(_e40.x, 1f));
    let _e51 = v_uv_1;
    let _e59 = global.U[0];
    let _e66 = global.U[6];
    let _e69 = global.U[7];
    let _e72 = global.U[8];
    let _e75 = global.U[9];
    let _e99 = global.U[4];
    let _e103 = global.U[10];
    let _e107 = global.U[11];
    let _e111 = global.U[12];
    let _e115 = global.U[13];
    let _e119 = global.U[14];
    let _e123 = global.U[15];
    let _e127 = global.U[16];
    let _e131 = global.U[17];
    let _e135 = global.U[18];
    let _e139 = global.U[19];
    let _e143 = global.U[20];
    let _e146 = global.U[21];
    let _e149 = global.U[22];
    let _e152 = quicksilverGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat4x4<f32>(vec4<f32>(_e66.x, _e66.y, _e66.z, _e66.w), vec4<f32>(_e69.x, _e69.y, _e69.z, _e69.w), vec4<f32>(_e72.x, _e72.y, _e72.z, _e72.w), vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w)), _e99.xy, _e103.x, _e107.x, _e111.x, _e115.x, _e119.x, _e123.x, _e127.x, _e131.x, _e135.x, _e139.x, _e143, _e146, i32(_e149.x));
    fragColor = _e152;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
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
