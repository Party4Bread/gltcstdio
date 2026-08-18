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
            let _e305 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e267) / 3.1415927f) * 2f), ((2f * _e274) / 3.1415927f)).x / _e282.x), vec2<f32>(((-(_e285) / 3.1415927f) * 2f), ((2f * _e292) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
            _bkgMiss = _e305;
        }
    } else {
        let _e306 = backgroundStyle_1;
        if (_e306 == 1i) {
            {
                let _e309 = dir;
                let _e312 = dir;
                let _e315 = sourceDim_1;
                let _e318 = sourceDim_1;
                let _e321 = dir;
                let _e324 = dir;
                _o_pos = vec2<f32>((((-(_e309.x) / _e312.z) * _e315.y) / _e318.x), (-(_e321.y) / _e324.z));
                let _e329 = _o_pos;
                let _e332 = _o_pos;
                _o_m = max(abs(_e329.x), abs(_e332.y));
                let _e339 = _o_m;
                _o_darken = (4f / max(4f, _e339));
                let _e343 = _o_pos;
                let _e347 = global.U[0];
                let _e350 = _o_pos;
                let _e359 = textureSample(t_source, samp, ((vec2<f32>((_e343.x / _e347.x), _e350.y) / vec2(2f)) + vec2(0.5f)));
                let _e360 = _o_darken;
                let _e361 = _o_darken;
                let _e362 = _o_darken;
                _bkgMiss = (_e359 * vec4<f32>(_e360, _e361, _e362, 1f));
            }
        } else {
            let _e366 = backgroundStyle_1;
            if (_e366 == 2i) {
                {
                    let _e369 = sourceDim_1;
                    let _e371 = sourceDim_1;
                    _o_ratio = (_e369.y / _e371.x);
                    let _e379 = dir;
                    let _e382 = dir;
                    let _e385 = _o_ratio;
                    let _e388 = dir;
                    let _e391 = dir;
                    let _e394 = _o_ratio;
                    if ((abs(_e379.y) > (abs(_e382.z) * _e385)) && (abs(_e388.y) > (abs(_e391.x) * _e394))) {
                        {
                            let _e398 = _o_X;
                            let _e399 = dir;
                            let _e402 = dir;
                            _o_X = (_e398 + ((-(_e399.x) / _e402.y) * 0.5f));
                            let _e408 = _o_Y;
                            let _e409 = dir;
                            let _e412 = dir;
                            _o_Y = (_e408 + ((-(_e409.z) / _e412.y) * 0.5f));
                        }
                    } else {
                        let _e418 = dir;
                        let _e421 = dir;
                        if (abs(_e418.x) < abs(_e421.z)) {
                            {
                                let _e425 = _o_X;
                                let _e426 = dir;
                                let _e428 = dir;
                                let _e432 = _o_ratio;
                                let _e436 = dir;
                                _o_X = (_e425 + ((((_e426.x / abs(_e428.z)) * _e432) * 0.5f) * -(sign(_e436.z))));
                                let _e442 = _o_Y;
                                let _e443 = dir;
                                let _e445 = dir;
                                _o_Y = (_e442 + ((_e443.y / abs(_e445.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e452 = _o_X;
                                let _e453 = dir;
                                let _e455 = dir;
                                let _e459 = _o_ratio;
                                let _e463 = dir;
                                _o_X = (_e452 + ((((_e453.z / abs(_e455.x)) * _e459) * 0.5f) * -(sign(_e463.x))));
                                let _e469 = _o_Y;
                                let _e470 = dir;
                                let _e472 = dir;
                                _o_Y = (_e469 + ((_e470.y / abs(_e472.x)) * 0.5f));
                            }
                        }
                    }
                    let _e479 = _o_X;
                    let _e480 = _o_Y;
                    let _e490 = global.U[0];
                    let _e493 = _o_X;
                    let _e494 = _o_Y;
                    let _e509 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e479, _e480) * 2f) - vec2(1f)).x / _e490.x), ((vec2<f32>(_e493, _e494) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _bkgMiss = _e509;
                }
            } else {
                {
                    let _e510 = dir;
                    let _e515 = ((_e510 * 0.5f) + vec3(0.5f));
                    _bkgMiss = vec4<f32>(_e515.x, _e515.y, _e515.z, 1f);
                }
            }
        }
    }
    let _e521 = k1_;
    let _e522 = k2_;
    if (_e521 > _e522) {
        let _e524 = _bkgMiss;
        return _e524;
    }
    let _e525 = k1_;
    k = _e525;
    let _e527 = cameraPos;
    let _e528 = k;
    let _e529 = dir;
    p = (_e527 + (_e528 * _e529));
    let _e539 = color_3;
    prevColor = _e539;
    loop {
        {
            let _e551 = color_3;
            prevColor = _e551;
            let _e552 = dz;
            prevDz = _e552;
            let _e553 = h;
            prevH = _e553;
            let _e554 = p;
            let _e559 = global.U[0];
            let _e562 = p;
            let _e572 = textureSample(t_source, samp, ((vec2<f32>((_e554.x / _e559.x), _e562.y) / vec2(2f)) + vec2(0.5f)));
            color_3 = _e572;
            let _e573 = intensityScaled;
            let _e574 = color_3;
            let _e575 = qsHeight(_e573, _e574);
            h = _e575;
            let _e576 = p;
            let _e578 = h;
            dz = (_e576.z - _e578);
            let _e580 = p;
            let _e581 = step;
            p = (_e580 + _e581);
            let _e583 = k;
            let _e584 = dk;
            k = (_e583 + _e584);
            let _e586 = dz;
            let _e589 = k;
            let _e590 = k1_;
            let _e592 = dz;
            let _e594 = prevDz;
            stop = ((_e586 == 0f) || ((_e589 != _e590) && (sign(_e592) == -(sign(_e594)))));
        }
        let _e600 = k;
        let _e601 = k2_;
        let _e603 = stop;
        if !(((_e600 <= _e601) && !(_e603))) {
            break;
        }
    }
    let _e607 = stop;
    let _e608 = dz;
    let _e610 = dk;
    stop = (_e607 || (abs(_e608) < _e610));
    let _e613 = stop;
    if !(_e613) {
        let _e615 = _bkgMiss;
        return _e615;
    }
    let _e616 = dz;
    let _e619 = k1_;
    let _e620 = dk;
    let _e622 = k2_;
    if ((_e616 == 0f) || ((_e619 + _e620) > _e622)) {
        local = 1f;
    } else {
        let _e626 = prevDz;
        let _e628 = dz;
        let _e630 = prevDz;
        local = (abs(_e626) / (abs(_e628) + abs(_e630)));
    }
    let _e635 = local;
    kk = _e635;
    let _e637 = prevH;
    let _e638 = h;
    let _e639 = kk;
    hh = mix(_e637, _e638, _e639);
    let _e642 = lightPos;
    let _e643 = p;
    lightVec = (_e642 - _e643);
    let _e646 = lightVec;
    lightDir = normalize(_e646);
    let _e649 = sourceColor_3;
    let _e651 = sourceColor_3;
    let _e654 = sourceColor_3;
    shadowing = ((_e649.x + _e651.y) + _e654.z);
    let _e658 = p;
    intersection = _e658;
    let _e661 = normalSmoothing_1;
    N = (1f + ceil((_e661 / 20f)));
    let _e668 = normalSmoothing_1;
    bx = (0.0005f + (_e668 * 0.0001f));
    let _e673 = N;
    if (_e673 >= 2f) {
        let _e676 = bx;
        let _e677 = N;
        local_1 = (_e676 / (_e677 - 1f));
    } else {
        local_1 = 0f;
    }
    let _e683 = local_1;
    sx = _e683;
    loop {
        let _e689 = i;
        let _e690 = N;
        if !((_e689 < i32(_e690))) {
            break;
        }
        {
            let _e697 = bx;
            let _e698 = i;
            let _e700 = sx;
            deltaX = (_e697 + (f32(_e698) * _e700));
            let _e704 = dzdx;
            let _e705 = intensityScaled;
            let _e706 = intersection;
            let _e708 = deltaX;
            let _e710 = intersection;
            let _e716 = global.U[0];
            let _e719 = intersection;
            let _e721 = deltaX;
            let _e723 = intersection;
            let _e734 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e706.x + _e708), _e710.y).x / _e716.x), vec2<f32>((_e719.x + _e721), _e723.y).y) / vec2(2f)) + vec2(0.5f)));
            let _e735 = qsHeight(_e705, _e734);
            let _e736 = intensityScaled;
            let _e737 = intersection;
            let _e739 = deltaX;
            let _e741 = intersection;
            let _e747 = global.U[0];
            let _e750 = intersection;
            let _e752 = deltaX;
            let _e754 = intersection;
            let _e765 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((_e737.x - _e739), _e741.y).x / _e747.x), vec2<f32>((_e750.x - _e752), _e754.y).y) / vec2(2f)) + vec2(0.5f)));
            let _e766 = qsHeight(_e736, _e765);
            dzdx = (_e704 + (_e735 - _e766));
        }
        continuing {
            let _e694 = i;
            i = (_e694 + 1i);
        }
    }
    let _e769 = dzdx;
    let _e770 = N;
    dzdx = (_e769 / _e770);
    let _e772 = bx;
    let _e773 = N;
    let _e778 = sx;
    deltaX_1 = (_e772 + (((_e773 - 1f) / 2f) * _e778));
    let _e783 = normalSmoothing_1;
    by = (0.0005f + (_e783 * 0.0001f));
    let _e788 = N;
    if (_e788 >= 2f) {
        let _e791 = by;
        let _e792 = N;
        local_2 = (_e791 / (_e792 - 1f));
    } else {
        local_2 = 0f;
    }
    let _e798 = local_2;
    sy = _e798;
    loop {
        let _e804 = i_1;
        let _e805 = N;
        if !((_e804 < i32(_e805))) {
            break;
        }
        {
            let _e812 = by;
            let _e813 = i_1;
            let _e815 = sy;
            deltaY = (_e812 + (f32(_e813) * _e815));
            let _e819 = dzdy;
            let _e820 = intensityScaled;
            let _e821 = intersection;
            let _e823 = intersection;
            let _e825 = deltaY;
            let _e831 = global.U[0];
            let _e834 = intersection;
            let _e836 = intersection;
            let _e838 = deltaY;
            let _e849 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e821.x, (_e823.y + _e825)).x / _e831.x), vec2<f32>(_e834.x, (_e836.y + _e838)).y) / vec2(2f)) + vec2(0.5f)));
            let _e850 = qsHeight(_e820, _e849);
            let _e851 = intensityScaled;
            let _e852 = intersection;
            let _e854 = intersection;
            let _e856 = deltaY;
            let _e862 = global.U[0];
            let _e865 = intersection;
            let _e867 = intersection;
            let _e869 = deltaY;
            let _e880 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e852.x, (_e854.y - _e856)).x / _e862.x), vec2<f32>(_e865.x, (_e867.y - _e869)).y) / vec2(2f)) + vec2(0.5f)));
            let _e881 = qsHeight(_e851, _e880);
            dzdy = (_e819 + (_e850 - _e881));
        }
        continuing {
            let _e809 = i_1;
            i_1 = (_e809 + 1i);
        }
    }
    let _e884 = dzdy;
    let _e885 = N;
    dzdy = (_e884 / _e885);
    let _e887 = by;
    let _e888 = N;
    let _e893 = sy;
    deltaY_1 = (_e887 + (((_e888 - 1f) / 2f) * _e893));
    let _e899 = deltaY_1;
    let _e901 = dzdx;
    let _e905 = deltaX_1;
    let _e907 = dzdy;
    let _e909 = deltaX_1;
    let _e910 = deltaY_1;
    unormal = vec3<f32>(((-2f * _e899) * _e901), ((-2f * _e905) * _e907), (_e909 * _e910));
    let _e914 = unormal;
    let _e918 = unormal;
    let _e923 = unormal;
    if (((_e914.x == 0f) && (_e918.y == 0f)) && (_e923.z == 0f)) {
        local_3 = vec3<f32>(0f, 0f, 1f);
    } else {
        let _e932 = unormal;
        local_3 = normalize(_e932);
    }
    let _e935 = local_3;
    normal = _e935;
    let _e937 = lightDir;
    let _e938 = normal;
    lighting = ((dot(_e937, _e938) + 1f) / 2f);
    let _e945 = dir;
    let _e946 = normal;
    reflected = reflect(_e945, _e946);
    let _e949 = prevColor;
    let _e950 = color_3;
    let _e951 = kk;
    surfaceColor = mix(_e949, _e950, vec4(_e951));
    let _e958 = surfaceColor;
    let _e960 = colorScheme_1;
    reflectiveColor = mix(vec4(1f), (1.5f * _e958), vec4((_e960 * 0.01f)));
    let _e969 = backgroundStyle_1;
    if (_e969 == 0i) {
        {
            let _e972 = reflected;
            _o_n_1 = normalize(_e972);
            let _e975 = _o_n_1;
            let _e977 = _o_n_1;
            _o_alpha_1 = atan2(_e975.z, _e977.x);
            let _e981 = _o_n_1;
            _o_beta_1 = asin(_e981.y);
            let _e985 = _o_alpha_1;
            let _e992 = _o_beta_1;
            let _e1000 = global.U[0];
            let _e1003 = _o_alpha_1;
            let _e1010 = _o_beta_1;
            let _e1023 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(((-(_e985) / 3.1415927f) * 2f), ((2f * _e992) / 3.1415927f)).x / _e1000.x), vec2<f32>(((-(_e1003) / 3.1415927f) * 2f), ((2f * _e1010) / 3.1415927f)).y) / vec2(2f)) + vec2(0.5f)));
            _reflBkg = _e1023;
        }
    } else {
        let _e1024 = backgroundStyle_1;
        if (_e1024 == 1i) {
            {
                let _e1027 = reflected;
                let _e1030 = reflected;
                let _e1033 = sourceDim_1;
                let _e1036 = sourceDim_1;
                let _e1039 = reflected;
                let _e1042 = reflected;
                _o_pos_1 = vec2<f32>((((-(_e1027.x) / _e1030.z) * _e1033.y) / _e1036.x), (-(_e1039.y) / _e1042.z));
                let _e1047 = _o_pos_1;
                let _e1050 = _o_pos_1;
                _o_m_1 = max(abs(_e1047.x), abs(_e1050.y));
                let _e1057 = _o_m_1;
                _o_darken_1 = (4f / max(4f, _e1057));
                let _e1061 = _o_pos_1;
                let _e1065 = global.U[0];
                let _e1068 = _o_pos_1;
                let _e1077 = textureSample(t_source, samp, ((vec2<f32>((_e1061.x / _e1065.x), _e1068.y) / vec2(2f)) + vec2(0.5f)));
                let _e1078 = _o_darken_1;
                let _e1079 = _o_darken_1;
                let _e1080 = _o_darken_1;
                _reflBkg = (_e1077 * vec4<f32>(_e1078, _e1079, _e1080, 1f));
            }
        } else {
            let _e1084 = backgroundStyle_1;
            if (_e1084 == 2i) {
                {
                    let _e1087 = sourceDim_1;
                    let _e1089 = sourceDim_1;
                    _o_ratio_1 = (_e1087.y / _e1089.x);
                    let _e1097 = reflected;
                    let _e1100 = reflected;
                    let _e1103 = _o_ratio_1;
                    let _e1106 = reflected;
                    let _e1109 = reflected;
                    let _e1112 = _o_ratio_1;
                    if ((abs(_e1097.y) > (abs(_e1100.z) * _e1103)) && (abs(_e1106.y) > (abs(_e1109.x) * _e1112))) {
                        {
                            let _e1116 = _o_X_1;
                            let _e1117 = reflected;
                            let _e1120 = reflected;
                            _o_X_1 = (_e1116 + ((-(_e1117.x) / _e1120.y) * 0.5f));
                            let _e1126 = _o_Y_1;
                            let _e1127 = reflected;
                            let _e1130 = reflected;
                            _o_Y_1 = (_e1126 + ((-(_e1127.z) / _e1130.y) * 0.5f));
                        }
                    } else {
                        let _e1136 = reflected;
                        let _e1139 = reflected;
                        if (abs(_e1136.x) < abs(_e1139.z)) {
                            {
                                let _e1143 = _o_X_1;
                                let _e1144 = reflected;
                                let _e1146 = reflected;
                                let _e1150 = _o_ratio_1;
                                let _e1154 = reflected;
                                _o_X_1 = (_e1143 + ((((_e1144.x / abs(_e1146.z)) * _e1150) * 0.5f) * -(sign(_e1154.z))));
                                let _e1160 = _o_Y_1;
                                let _e1161 = reflected;
                                let _e1163 = reflected;
                                _o_Y_1 = (_e1160 + ((_e1161.y / abs(_e1163.z)) * 0.5f));
                            }
                        } else {
                            {
                                let _e1170 = _o_X_1;
                                let _e1171 = reflected;
                                let _e1173 = reflected;
                                let _e1177 = _o_ratio_1;
                                let _e1181 = reflected;
                                _o_X_1 = (_e1170 + ((((_e1171.z / abs(_e1173.x)) * _e1177) * 0.5f) * -(sign(_e1181.x))));
                                let _e1187 = _o_Y_1;
                                let _e1188 = reflected;
                                let _e1190 = reflected;
                                _o_Y_1 = (_e1187 + ((_e1188.y / abs(_e1190.x)) * 0.5f));
                            }
                        }
                    }
                    let _e1197 = _o_X_1;
                    let _e1198 = _o_Y_1;
                    let _e1208 = global.U[0];
                    let _e1211 = _o_X_1;
                    let _e1212 = _o_Y_1;
                    let _e1227 = textureSample(t_source, samp, ((vec2<f32>((((vec2<f32>(_e1197, _e1198) * 2f) - vec2(1f)).x / _e1208.x), ((vec2<f32>(_e1211, _e1212) * 2f) - vec2(1f)).y) / vec2(2f)) + vec2(0.5f)));
                    _reflBkg = _e1227;
                }
            } else {
                {
                    let _e1228 = reflected;
                    let _e1233 = ((_e1228 * 0.5f) + vec3(0.5f));
                    _reflBkg = vec4<f32>(_e1233.x, _e1233.y, _e1233.z, 1f);
                }
            }
        }
    }
    let _e1239 = reflectiveColor;
    let _e1240 = _reflBkg;
    reflectColor_2 = (_e1239 * _e1240);
    let _e1243 = surfaceSmoothness_1;
    if (_e1243 < 100f) {
        {
            let _e1246 = lighting;
            if (_e1246 < 0.5f) {
                let _e1249 = lighting;
                let _e1253 = surfaceSmoothness_1;
                lighting = (pow((_e1249 * 2f), (100f / _e1253)) / 2f);
            } else {
                let _e1258 = lighting;
                let _e1264 = surfaceSmoothness_1;
                lighting = ((pow(((_e1258 - 0.5f) * 2f), (0.01f * _e1264)) / 2f) + 0.5f);
            }
        }
    }
    let _e1273 = specular_3;
    if (_e1273 != 0f) {
        {
            let _e1276 = lightDir;
            let _e1277 = normal;
            reflectLightDir = reflect(_e1276, _e1277);
            let _e1280 = dir;
            let _e1281 = reflectLightDir;
            let _e1287 = specular_3;
            spec = pow(clamp(dot(_e1280, _e1281), 0f, 1f), (10f - (_e1287 * 0.1f)));
        }
    }
    let _e1292 = shadows_1;
    shad = (_e1292 * 0.01f);
    let _e1296 = shadowing;
    let _e1299 = shad;
    let _e1303 = intensity_3;
    if (((_e1296 != 0f) && (_e1299 > 0f)) && (_e1303 != 0f)) {
        {
            let _e1307 = p;
            let _e1309 = step;
            p = (_e1307 - (2f * _e1309));
            let _e1312 = lightDir;
            let _e1313 = dk;
            lightStep = (_e1312 * _e1313);
            k1_ = 0f;
            let _e1317 = lightVec;
            k2s = length(_e1317);
            let _e1320 = lightDir;
            if (_e1320.x != 0f) {
                {
                    let _e1324 = lightDir;
                    s_3 = sign(_e1324.x);
                    let _e1328 = s_3;
                    let _e1330 = ratio;
                    let _e1332 = p;
                    let _e1335 = lightDir;
                    k3_3 = (((-(_e1328) * _e1330) - _e1332.x) / _e1335.x);
                    let _e1339 = s_3;
                    let _e1340 = ratio;
                    let _e1342 = p;
                    let _e1345 = lightDir;
                    k4_3 = (((_e1339 * _e1340) - _e1342.x) / _e1345.x);
                    let _e1349 = k4_3;
                    if (_e1349 > 0f) {
                        let _e1352 = k2s;
                        let _e1353 = k4_3;
                        k2s = min(_e1352, _e1353);
                    }
                    let _e1355 = k3_3;
                    if (_e1355 > 0f) {
                        let _e1358 = k2s;
                        let _e1359 = k3_3;
                        k2s = min(_e1358, _e1359);
                    }
                }
            }
            let _e1361 = lightDir;
            if (_e1361.y != 0f) {
                {
                    let _e1365 = lightDir;
                    s_4 = sign(_e1365.y);
                    let _e1369 = s_4;
                    let _e1371 = p;
                    let _e1374 = lightDir;
                    k3_4 = ((-(_e1369) - _e1371.y) / _e1374.y);
                    let _e1378 = s_4;
                    let _e1379 = p;
                    let _e1382 = lightDir;
                    k4_4 = ((_e1378 - _e1379.y) / _e1382.y);
                    let _e1386 = k4_4;
                    if (_e1386 > 0f) {
                        let _e1389 = k2s;
                        let _e1390 = k4_4;
                        k2s = min(_e1389, _e1390);
                    }
                    let _e1392 = k3_4;
                    if (_e1392 > 0f) {
                        let _e1395 = k2s;
                        let _e1396 = k3_4;
                        k2s = min(_e1395, _e1396);
                    }
                }
            }
            let _e1398 = maxZ;
            maxZ2s = (_e1398 + 0.0001f);
            let _e1402 = lightDir;
            if (_e1402.z != 0f) {
                {
                    let _e1406 = lightDir;
                    s_5 = sign(_e1406.z);
                    let _e1410 = s_5;
                    let _e1412 = maxZ2s;
                    let _e1414 = p;
                    let _e1417 = lightDir;
                    k3_5 = (((-(_e1410) * _e1412) - _e1414.z) / _e1417.z);
                    let _e1421 = s_5;
                    let _e1422 = maxZ2s;
                    let _e1424 = p;
                    let _e1427 = lightDir;
                    k4_5 = (((_e1421 * _e1422) - _e1424.z) / _e1427.z);
                    let _e1431 = k4_5;
                    if (_e1431 > 0f) {
                        let _e1434 = k2s;
                        let _e1435 = k4_5;
                        k2s = min(_e1434, _e1435);
                    }
                    let _e1437 = k3_5;
                    if (_e1437 > 0f) {
                        let _e1440 = k2s;
                        let _e1441 = k3_5;
                        k2s = min(_e1440, _e1441);
                    }
                }
            }
            h = 0f;
            prevH = 0f;
            dz = 0f;
            prevDz = 0f;
            loop {
                {
                    let _e1451 = dz;
                    prevDz = _e1451;
                    let _e1452 = h;
                    prevH = _e1452;
                    let _e1453 = intensityScaled;
                    let _e1454 = p;
                    let _e1459 = global.U[0];
                    let _e1462 = p;
                    let _e1472 = textureSample(t_source, samp, ((vec2<f32>((_e1454.x / _e1459.x), _e1462.y) / vec2(2f)) + vec2(0.5f)));
                    let _e1473 = qsHeight(_e1453, _e1472);
                    h = _e1473;
                    let _e1474 = p;
                    let _e1476 = h;
                    dz = (_e1474.z - _e1476);
                    let _e1478 = p;
                    let _e1479 = lightStep;
                    p = (_e1478 + _e1479);
                    let _e1481 = ks;
                    let _e1482 = dk;
                    ks = (_e1481 + _e1482);
                    let _e1484 = dz;
                    let _e1487 = ks;
                    let _e1490 = dz;
                    let _e1492 = prevDz;
                    sstop = ((_e1484 == 0f) || ((_e1487 != 0f) && (sign(_e1490) == -(sign(_e1492)))));
                }
                let _e1498 = ks;
                let _e1499 = k2s;
                let _e1501 = sstop;
                if !(((_e1498 <= _e1499) && !(_e1501))) {
                    break;
                }
            }
            let _e1505 = sstop;
            if _e1505 {
                {
                    let _e1507 = shad;
                    let _e1509 = lighting;
                    lighting = min((1f - _e1507), _e1509);
                    spec = 0f;
                }
            }
        }
    }
    let _e1512 = surfaceColor;
    let _e1513 = reflectColor_2;
    let _e1514 = lighting;
    let _e1515 = spec;
    let _e1516 = ambientColor_3;
    let _e1517 = sourceColor_3;
    let _e1518 = gamma_3;
    let _e1519 = qsApplyLighting(_e1512, _e1513, _e1514, _e1515, _e1516, _e1517, _e1518);
    return _e1519;
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
