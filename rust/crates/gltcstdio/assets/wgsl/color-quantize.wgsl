struct Params {
    U: array<vec4<f32>, 15>,
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
var t_ditheringPattern: texture_2d<f32>;
@group(0) @binding(3) 
var t_palette: texture_2d<f32>;
@group(0) @binding(4) 
var t_source: texture_2d<f32>;

fn applyColorTransforms(color: vec4<f32>, gamma: f32, contrast: f32, saturation: f32) -> vec4<f32> {
    var color_1: vec4<f32>;
    var gamma_1: f32;
    var contrast_1: f32;
    var saturation_1: f32;
    var rgb: vec3<f32>;
    var local: f32;
    var local_1: f32;
    var local_2: f32;
    var grey: f32;

    color_1 = color;
    gamma_1 = gamma;
    contrast_1 = contrast;
    saturation_1 = saturation;
    let _e16 = color_1;
    rgb = _e16.xyz;
    let _e19 = gamma_1;
    if (_e19 != 1f) {
        {
            let _e22 = rgb;
            let _e23 = gamma_1;
            rgb = pow(_e22, vec3(_e23));
        }
    }
    let _e26 = contrast_1;
    if (_e26 != 1f) {
        {
            let _e30 = rgb;
            if (_e30.x < 0.5f) {
                let _e34 = rgb;
                let _e38 = contrast_1;
                local = (pow((_e34.x * 2f), _e38) / 2f);
            } else {
                let _e43 = rgb;
                let _e50 = contrast_1;
                local = (0.5f + (pow(((_e43.x - 0.5f) * 2f), (1f / _e50)) / 2f));
            }
            let _e57 = local;
            rgb.x = _e57;
            let _e59 = rgb;
            if (_e59.y < 0.5f) {
                let _e63 = rgb;
                let _e67 = contrast_1;
                local_1 = (pow((_e63.y * 2f), _e67) / 2f);
            } else {
                let _e72 = rgb;
                let _e79 = contrast_1;
                local_1 = (0.5f + (pow(((_e72.y - 0.5f) * 2f), (1f / _e79)) / 2f));
            }
            let _e86 = local_1;
            rgb.y = _e86;
            let _e88 = rgb;
            if (_e88.z < 0.5f) {
                let _e92 = rgb;
                let _e96 = contrast_1;
                local_2 = (pow((_e92.z * 2f), _e96) / 2f);
            } else {
                let _e101 = rgb;
                let _e108 = contrast_1;
                local_2 = (0.5f + (pow(((_e101.z - 0.5f) * 2f), (1f / _e108)) / 2f));
            }
            let _e115 = local_2;
            rgb.z = _e115;
        }
    }
    let _e116 = saturation_1;
    if (_e116 != 1f) {
        {
            let _e120 = rgb;
            let _e124 = rgb;
            let _e129 = rgb;
            grey = (((0.2126f * _e120.x) + (0.7152f * _e124.y)) + (0.0722f * _e129.z));
            let _e134 = grey;
            let _e136 = rgb;
            let _e137 = grey;
            let _e140 = saturation_1;
            rgb = (vec3(_e134) + ((_e136 - vec3(_e137)) * _e140));
        }
    }
    let _e143 = rgb;
    let _e148 = clamp(_e143, vec3(0f), vec3(1f));
    let _e149 = color_1;
    return vec4<f32>(_e148.x, _e148.y, _e148.z, _e149.w);
}

fn imod(x: i32, y: i32) -> i32 {
    var x_1: i32;
    var y_1: i32;

    x_1 = x;
    y_1 = y;
    let _e12 = x_1;
    let _e13 = y_1;
    let _e14 = x_1;
    let _e15 = y_1;
    return (_e12 - (_e13 * (_e14 / _e15)));
}

fn rand(x_2: f32) -> f32 {
    var x_3: f32;

    x_3 = x_2;
    let _e10 = x_3;
    return fract(sin((_e10 * 43758.547f)));
}

fn rand_1(co: vec2<f32>) -> f32 {
    var co_1: vec2<f32>;

    co_1 = co;
    let _e10 = co_1;
    return fract((sin(dot(_e10.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn colorQuantize(pos: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, paletteDim: vec2<f32>, quantizeMode: i32, ditheringPatternDim: vec2<f32>, dithering: f32, gamma_2: f32, contrast_2: f32, saturation_2: f32, noiseValue: f32, closenessFactor: f32, paletteStep: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var paletteDim_1: vec2<f32>;
    var quantizeMode_1: i32;
    var ditheringPatternDim_1: vec2<f32>;
    var dithering_1: f32;
    var gamma_3: f32;
    var contrast_3: f32;
    var saturation_3: f32;
    var noiseValue_1: f32;
    var closenessFactor_1: f32;
    var paletteStep_1: i32;
    var color_2: vec4<f32>;
    var transformed: vec4<f32>;
    var pixelPos: vec2<f32>;
    var ar: f32;
    var x_4: i32;
    var y_2: i32;
    var processedColor: vec4<f32>;
    var result: vec4<f32>;
    var minDistance: f32 = 1000000f;
    var best: vec4<f32>;
    var n: i32;
    var i: i32 = 0i;
    var paletteColor: vec4<f32>;
    var delta: vec3<f32>;
    var distance: f32;
    var MODE_BASIC: i32 = 0i;
    var MODE_EXTENDED: i32 = 1i;
    var MODE_EXTENDED_FAVORING_CLOSENESS: i32 = 2i;
    var MODE_NOISY: i32 = 3i;
    var MODE_PATTERN3_: i32 = 4i;
    var MODE_PATTERN4_: i32 = 5i;
    var MODE_PATTERN4_OFFSET: i32 = 6i;
    var MODE_PATTERN8_: i32 = 7i;
    var MODE_INTERLACED_H: i32 = 8i;
    var MODE_INTERLACED_V: i32 = 9i;
    var MODE_PATTERN5_: i32 = 10i;
    var MODE_PATTERN2_: i32 = 11i;
    var MODE_PATTERN3x6_: i32 = 12i;
    var MODE_PATTERN4x8_: i32 = 13i;
    var noise: f32;
    var minDistance_1: f32 = 1000000f;
    var best_1: vec4<f32>;
    var n_1: i32;
    var i_1: i32 = 0i;
    var paletteColor_1: vec4<f32>;
    var delta_1: vec3<f32>;
    var distance_1: f32;
    var patternW: i32;
    var patternH: i32;
    var dPos: vec2<i32>;
    var patternCol: vec4<f32>;
    var patternNoise: f32;
    var minDistance_2: f32 = 1000000f;
    var best_2: vec4<f32>;
    var n_2: i32;
    var i_2: i32 = 0i;
    var paletteColor_2: vec4<f32>;
    var delta_2: vec3<f32>;
    var distance_2: f32;
    var patternW_1: i32;
    var patternH_1: i32;
    var dPosR: vec2<i32>;
    var dPosG: vec2<i32>;
    var dPosB: vec2<i32>;
    var noiseR: f32;
    var noiseG: f32;
    var noiseB: f32;
    var minDistance_3: f32 = 1000000f;
    var best_3: vec4<f32>;
    var n_3: i32;
    var i_3: i32 = 0i;
    var paletteColor_3: vec4<f32>;
    var delta_3: vec3<f32>;
    var distance_3: f32;
    var minDistance_4: f32 = 1000000f;
    var best_4: vec4<f32>;
    var n_4: i32;
    var i_4: i32 = 0i;
    var j: i32;
    var color1_: vec4<f32>;
    var color2_: vec4<f32>;
    var avgColor: vec3<f32>;
    var delta_4: vec3<f32>;
    var distance_4: f32;
    var lum1_: f32;
    var lum2_: f32;
    var checker: bool;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;
    var minDistance_5: f32 = 1000000f;
    var best_5: vec4<f32>;
    var n_5: i32;
    var i_5: i32 = 0i;
    var j_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var avgColor_1: vec3<f32>;
    var delta_5: vec3<f32>;
    var penalty: vec3<f32>;
    var distance_5: f32;
    var lum1_1: f32;
    var lum2_1: f32;
    var checker_1: bool;
    var local_5: vec4<f32>;
    var local_6: vec4<f32>;
    var minDistance_6: f32 = 1000000f;
    var best_6: vec4<f32>;
    var n_6: i32;
    var i_6: i32 = 0i;
    var j_2: i32;
    var color1_2: vec4<f32>;
    var color2_2: vec4<f32>;
    var avgColor_2: vec3<f32>;
    var delta_6: vec3<f32>;
    var penalty_1: vec3<f32>;
    var distance_6: f32;
    var lum1_2: f32;
    var lum2_2: f32;
    var evenRow: bool;
    var local_7: vec4<f32>;
    var local_8: vec4<f32>;
    var minDistance_7: f32 = 1000000f;
    var best_7: vec4<f32>;
    var n_7: i32;
    var i_7: i32 = 0i;
    var j_3: i32;
    var color1_3: vec4<f32>;
    var color2_3: vec4<f32>;
    var avgColor_3: vec3<f32>;
    var delta_7: vec3<f32>;
    var penalty_2: vec3<f32>;
    var distance_7: f32;
    var lum1_3: f32;
    var lum2_3: f32;
    var evenCol: bool;
    var local_9: vec4<f32>;
    var local_10: vec4<f32>;
    var minDistance_8: f32 = 1000000f;
    var best_8: vec4<f32>;
    var n_8: i32;
    var i_8: i32 = 0i;
    var paletteColor_4: vec4<f32>;
    var delta_8: vec3<f32>;
    var distance_8: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    outDim_1 = outDim;
    paletteDim_1 = paletteDim;
    quantizeMode_1 = quantizeMode;
    ditheringPatternDim_1 = ditheringPatternDim;
    dithering_1 = dithering;
    gamma_3 = gamma_2;
    contrast_3 = contrast_2;
    saturation_3 = saturation_2;
    noiseValue_1 = noiseValue;
    closenessFactor_1 = closenessFactor;
    paletteStep_1 = paletteStep;
    let _e34 = pos_1;
    let _e38 = global.U[0];
    let _e41 = pos_1;
    let _e50 = textureSample(t_source, samp, ((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
    color_2 = _e50;
    let _e52 = color_2;
    let _e53 = gamma_3;
    let _e54 = contrast_3;
    let _e55 = saturation_3;
    let _e56 = applyColorTransforms(_e52, _e53, _e54, _e55);
    transformed = _e56;
    let _e58 = outPos_1;
    pixelPos = _e58;
    let _e60 = outDim_1;
    let _e62 = outDim_1;
    ar = (_e60.x / _e62.y);
    let _e66 = outPos_1;
    let _e68 = ar;
    let _e72 = outDim_1;
    x_4 = i32((((_e66.x + _e68) * 0.5f) * _e72.y));
    let _e77 = outPos_1;
    let _e83 = outDim_1;
    y_2 = i32((((_e77.y + 1f) * 0.5f) * _e83.y));
    let _e88 = transformed;
    processedColor = _e88;
    {
        let _e93 = processedColor;
        best = _e93;
        let _e95 = paletteDim_1;
        n = i32(_e95.x);
        loop {
            let _e101 = i;
            if !((_e101 < 4096i)) {
                break;
            }
            {
                let _e108 = i;
                let _e109 = n;
                if (_e108 >= _e109) {
                    break;
                }
                let _e111 = i;
                let _e115 = textureLoad(t_palette, vec2<i32>(_e111, 0i), 0i);
                paletteColor = _e115;
                let _e117 = paletteColor;
                let _e119 = processedColor;
                delta = (_e117.xyz - _e119.xyz);
                let _e123 = delta;
                let _e124 = delta;
                distance = dot(_e123, _e124);
                let _e127 = distance;
                let _e128 = minDistance;
                if (_e127 < _e128) {
                    {
                        let _e130 = distance;
                        minDistance = _e130;
                        let _e131 = paletteColor;
                        best = _e131;
                    }
                }
            }
            continuing {
                let _e105 = i;
                i = (_e105 + 1i);
            }
        }
        let _e132 = best;
        result = _e132;
    }
    let _e161 = quantizeMode_1;
    let _e162 = MODE_NOISY;
    if (_e161 == _e162) {
        {
            let _e164 = pixelPos;
            let _e165 = rand_1(_e164);
            let _e170 = noiseValue_1;
            noise = ((((_e165 * 2f) - 1f) * _e170) / 255f);
            let _e175 = processedColor;
            let _e177 = transformed;
            let _e179 = noise;
            let _e186 = clamp((_e177.xyz + vec3(_e179)), vec3(0f), vec3(1f));
            processedColor.x = _e186.x;
            processedColor.y = _e186.y;
            processedColor.z = _e186.z;
            {
                let _e195 = processedColor;
                best_1 = _e195;
                let _e197 = paletteDim_1;
                n_1 = i32(_e197.x);
                loop {
                    let _e203 = i_1;
                    if !((_e203 < 4096i)) {
                        break;
                    }
                    {
                        let _e210 = i_1;
                        let _e211 = n_1;
                        if (_e210 >= _e211) {
                            break;
                        }
                        let _e213 = i_1;
                        let _e217 = textureLoad(t_palette, vec2<i32>(_e213, 0i), 0i);
                        paletteColor_1 = _e217;
                        let _e219 = paletteColor_1;
                        let _e221 = processedColor;
                        delta_1 = (_e219.xyz - _e221.xyz);
                        let _e225 = delta_1;
                        let _e226 = delta_1;
                        distance_1 = dot(_e225, _e226);
                        let _e229 = distance_1;
                        let _e230 = minDistance_1;
                        if (_e229 < _e230) {
                            {
                                let _e232 = distance_1;
                                minDistance_1 = _e232;
                                let _e233 = paletteColor_1;
                                best_1 = _e233;
                            }
                        }
                    }
                    continuing {
                        let _e207 = i_1;
                        i_1 = (_e207 + 1i);
                    }
                }
                let _e234 = best_1;
                result = _e234;
            }
            let _e235 = result;
            return _e235;
        }
    } else {
        let _e236 = quantizeMode_1;
        let _e237 = MODE_PATTERN2_;
        let _e239 = quantizeMode_1;
        let _e240 = MODE_PATTERN3_;
        let _e243 = quantizeMode_1;
        let _e244 = MODE_PATTERN4_;
        let _e247 = quantizeMode_1;
        let _e248 = MODE_PATTERN5_;
        let _e251 = quantizeMode_1;
        let _e252 = MODE_PATTERN8_;
        let _e255 = quantizeMode_1;
        let _e256 = MODE_PATTERN3x6_;
        let _e259 = quantizeMode_1;
        let _e260 = MODE_PATTERN4x8_;
        if (((((((_e236 == _e237) || (_e239 == _e240)) || (_e243 == _e244)) || (_e247 == _e248)) || (_e251 == _e252)) || (_e255 == _e256)) || (_e259 == _e260)) {
            {
                let _e263 = ditheringPatternDim_1;
                patternW = i32(_e263.x);
                let _e267 = ditheringPatternDim_1;
                patternH = i32(_e267.y);
                let _e271 = x_4;
                let _e272 = patternW;
                let _e273 = imod(_e271, _e272);
                let _e274 = y_2;
                let _e275 = patternH;
                let _e276 = imod(_e274, _e275);
                dPos = vec2<i32>(_e273, _e276);
                let _e279 = dPos;
                let _e281 = textureLoad(t_ditheringPattern, _e279, 0i);
                patternCol = _e281;
                let _e283 = patternCol;
                patternNoise = (_e283.x - 0.5019608f);
                let _e290 = processedColor;
                let _e292 = transformed;
                let _e294 = patternNoise;
                let _e301 = clamp((_e292.xyz + vec3(_e294)), vec3(0f), vec3(1f));
                processedColor.x = _e301.x;
                processedColor.y = _e301.y;
                processedColor.z = _e301.z;
                {
                    let _e310 = processedColor;
                    best_2 = _e310;
                    let _e312 = paletteDim_1;
                    n_2 = i32(_e312.x);
                    loop {
                        let _e318 = i_2;
                        if !((_e318 < 4096i)) {
                            break;
                        }
                        {
                            let _e325 = i_2;
                            let _e326 = n_2;
                            if (_e325 >= _e326) {
                                break;
                            }
                            let _e328 = i_2;
                            let _e332 = textureLoad(t_palette, vec2<i32>(_e328, 0i), 0i);
                            paletteColor_2 = _e332;
                            let _e334 = paletteColor_2;
                            let _e336 = processedColor;
                            delta_2 = (_e334.xyz - _e336.xyz);
                            let _e340 = delta_2;
                            let _e341 = delta_2;
                            distance_2 = dot(_e340, _e341);
                            let _e344 = distance_2;
                            let _e345 = minDistance_2;
                            if (_e344 < _e345) {
                                {
                                    let _e347 = distance_2;
                                    minDistance_2 = _e347;
                                    let _e348 = paletteColor_2;
                                    best_2 = _e348;
                                }
                            }
                        }
                        continuing {
                            let _e322 = i_2;
                            i_2 = (_e322 + 1i);
                        }
                    }
                    let _e349 = best_2;
                    result = _e349;
                }
                let _e350 = result;
                return _e350;
            }
        } else {
            let _e351 = quantizeMode_1;
            let _e352 = MODE_PATTERN4_OFFSET;
            if (_e351 == _e352) {
                {
                    let _e354 = ditheringPatternDim_1;
                    patternW_1 = i32(_e354.x);
                    let _e358 = ditheringPatternDim_1;
                    patternH_1 = i32(_e358.y);
                    let _e362 = x_4;
                    let _e363 = patternW_1;
                    let _e364 = imod(_e362, _e363);
                    let _e365 = y_2;
                    let _e366 = patternH_1;
                    let _e367 = imod(_e365, _e366);
                    dPosR = vec2<i32>(_e364, _e367);
                    let _e370 = x_4;
                    let _e373 = patternW_1;
                    let _e374 = imod((_e370 + 1i), _e373);
                    let _e375 = y_2;
                    let _e378 = patternH_1;
                    let _e379 = imod((_e375 + 2i), _e378);
                    dPosG = vec2<i32>(_e374, _e379);
                    let _e382 = x_4;
                    let _e385 = patternW_1;
                    let _e386 = imod((_e382 + 3i), _e385);
                    let _e387 = y_2;
                    let _e390 = patternH_1;
                    let _e391 = imod((_e387 + 1i), _e390);
                    dPosB = vec2<i32>(_e386, _e391);
                    let _e394 = dPosR;
                    let _e396 = textureLoad(t_ditheringPattern, _e394, 0i);
                    noiseR = (_e396.x - 0.5019608f);
                    let _e403 = dPosG;
                    let _e405 = textureLoad(t_ditheringPattern, _e403, 0i);
                    noiseG = (_e405.x - 0.5019608f);
                    let _e412 = dPosB;
                    let _e414 = textureLoad(t_ditheringPattern, _e412, 0i);
                    noiseB = (_e414.x - 0.5019608f);
                    let _e422 = transformed;
                    let _e424 = noiseR;
                    processedColor.x = clamp((_e422.x + _e424), 0f, 1f);
                    let _e430 = transformed;
                    let _e432 = noiseG;
                    processedColor.y = clamp((_e430.y + _e432), 0f, 1f);
                    let _e438 = transformed;
                    let _e440 = noiseB;
                    processedColor.z = clamp((_e438.z + _e440), 0f, 1f);
                    {
                        let _e447 = processedColor;
                        best_3 = _e447;
                        let _e449 = paletteDim_1;
                        n_3 = i32(_e449.x);
                        loop {
                            let _e455 = i_3;
                            if !((_e455 < 4096i)) {
                                break;
                            }
                            {
                                let _e462 = i_3;
                                let _e463 = n_3;
                                if (_e462 >= _e463) {
                                    break;
                                }
                                let _e465 = i_3;
                                let _e469 = textureLoad(t_palette, vec2<i32>(_e465, 0i), 0i);
                                paletteColor_3 = _e469;
                                let _e471 = paletteColor_3;
                                let _e473 = processedColor;
                                delta_3 = (_e471.xyz - _e473.xyz);
                                let _e477 = delta_3;
                                let _e478 = delta_3;
                                distance_3 = dot(_e477, _e478);
                                let _e481 = distance_3;
                                let _e482 = minDistance_3;
                                if (_e481 < _e482) {
                                    {
                                        let _e484 = distance_3;
                                        minDistance_3 = _e484;
                                        let _e485 = paletteColor_3;
                                        best_3 = _e485;
                                    }
                                }
                            }
                            continuing {
                                let _e459 = i_3;
                                i_3 = (_e459 + 1i);
                            }
                        }
                        let _e486 = best_3;
                        result = _e486;
                    }
                    let _e487 = result;
                    return _e487;
                }
            } else {
                let _e488 = quantizeMode_1;
                let _e489 = MODE_EXTENDED;
                if (_e488 == _e489) {
                    {
                        {
                            let _e493 = transformed;
                            best_4 = _e493;
                            let _e495 = paletteDim_1;
                            n_4 = i32(_e495.x);
                            loop {
                                let _e501 = i_4;
                                if !((_e501 < 4096i)) {
                                    break;
                                }
                                {
                                    let _e508 = i_4;
                                    let _e509 = n_4;
                                    if (_e508 >= _e509) {
                                        break;
                                    }
                                    let _e511 = i_4;
                                    j = _e511;
                                    loop {
                                        let _e513 = j;
                                        if !((_e513 >= 0i)) {
                                            break;
                                        }
                                        {
                                            let _e520 = i_4;
                                            let _e524 = textureLoad(t_palette, vec2<i32>(_e520, 0i), 0i);
                                            color1_ = _e524;
                                            let _e526 = j;
                                            let _e530 = textureLoad(t_palette, vec2<i32>(_e526, 0i), 0i);
                                            color2_ = _e530;
                                            let _e532 = color1_;
                                            let _e534 = color2_;
                                            avgColor = ((_e532.xyz + _e534.xyz) / vec3(2f));
                                            let _e541 = avgColor;
                                            let _e542 = transformed;
                                            delta_4 = (_e541 - _e542.xyz);
                                            let _e546 = delta_4;
                                            let _e547 = delta_4;
                                            distance_4 = dot(_e546, _e547);
                                            let _e550 = distance_4;
                                            let _e551 = minDistance_4;
                                            if (_e550 < _e551) {
                                                {
                                                    let _e553 = distance_4;
                                                    minDistance_4 = _e553;
                                                    let _e555 = color1_;
                                                    let _e559 = color1_;
                                                    let _e564 = color1_;
                                                    lum1_ = (((0.2126f * _e555.x) + (0.7152f * _e559.y)) + (0.0722f * _e564.z));
                                                    let _e570 = color2_;
                                                    let _e574 = color2_;
                                                    let _e579 = color2_;
                                                    lum2_ = (((0.2126f * _e570.x) + (0.7152f * _e574.y)) + (0.0722f * _e579.z));
                                                    let _e584 = x_4;
                                                    let _e585 = y_2;
                                                    let _e588 = imod((_e584 + _e585), 2i);
                                                    checker = (_e588 == 0i);
                                                    let _e592 = lum1_;
                                                    let _e593 = lum2_;
                                                    if (_e592 > _e593) {
                                                        {
                                                            let _e595 = checker;
                                                            if _e595 {
                                                                let _e596 = color1_;
                                                                local_3 = _e596;
                                                            } else {
                                                                let _e597 = color2_;
                                                                local_3 = _e597;
                                                            }
                                                            let _e599 = local_3;
                                                            best_4 = _e599;
                                                        }
                                                    } else {
                                                        {
                                                            let _e600 = checker;
                                                            if _e600 {
                                                                let _e601 = color2_;
                                                                local_4 = _e601;
                                                            } else {
                                                                let _e602 = color1_;
                                                                local_4 = _e602;
                                                            }
                                                            let _e604 = local_4;
                                                            best_4 = _e604;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        continuing {
                                            let _e517 = j;
                                            let _e518 = paletteStep_1;
                                            j = (_e517 - _e518);
                                        }
                                    }
                                }
                                continuing {
                                    let _e505 = i_4;
                                    i_4 = (_e505 + 1i);
                                }
                            }
                            let _e605 = best_4;
                            result = _e605;
                        }
                        let _e606 = result;
                        return _e606;
                    }
                } else {
                    let _e607 = quantizeMode_1;
                    let _e608 = MODE_EXTENDED_FAVORING_CLOSENESS;
                    if (_e607 == _e608) {
                        {
                            {
                                let _e612 = transformed;
                                best_5 = _e612;
                                let _e614 = paletteDim_1;
                                n_5 = i32(_e614.x);
                                loop {
                                    let _e620 = i_5;
                                    if !((_e620 < 4096i)) {
                                        break;
                                    }
                                    {
                                        let _e627 = i_5;
                                        let _e628 = n_5;
                                        if (_e627 >= _e628) {
                                            break;
                                        }
                                        let _e630 = i_5;
                                        j_1 = _e630;
                                        loop {
                                            let _e632 = j_1;
                                            if !((_e632 >= 0i)) {
                                                break;
                                            }
                                            {
                                                let _e639 = i_5;
                                                let _e643 = textureLoad(t_palette, vec2<i32>(_e639, 0i), 0i);
                                                color1_1 = _e643;
                                                let _e645 = j_1;
                                                let _e649 = textureLoad(t_palette, vec2<i32>(_e645, 0i), 0i);
                                                color2_1 = _e649;
                                                let _e651 = color1_1;
                                                let _e653 = color2_1;
                                                avgColor_1 = ((_e651.xyz + _e653.xyz) / vec3(2f));
                                                let _e660 = avgColor_1;
                                                let _e661 = transformed;
                                                delta_5 = (_e660 - _e661.xyz);
                                                let _e665 = color1_1;
                                                let _e667 = color2_1;
                                                penalty = (_e665.xyz - _e667.xyz);
                                                let _e671 = delta_5;
                                                let _e672 = delta_5;
                                                let _e674 = penalty;
                                                let _e675 = penalty;
                                                let _e677 = closenessFactor_1;
                                                distance_5 = (dot(_e671, _e672) + (dot(_e674, _e675) * _e677));
                                                let _e681 = distance_5;
                                                let _e682 = minDistance_5;
                                                if (_e681 < _e682) {
                                                    {
                                                        let _e684 = distance_5;
                                                        minDistance_5 = _e684;
                                                        let _e686 = color1_1;
                                                        let _e690 = color1_1;
                                                        let _e695 = color1_1;
                                                        lum1_1 = (((0.2126f * _e686.x) + (0.7152f * _e690.y)) + (0.0722f * _e695.z));
                                                        let _e701 = color2_1;
                                                        let _e705 = color2_1;
                                                        let _e710 = color2_1;
                                                        lum2_1 = (((0.2126f * _e701.x) + (0.7152f * _e705.y)) + (0.0722f * _e710.z));
                                                        let _e715 = x_4;
                                                        let _e716 = y_2;
                                                        let _e719 = imod((_e715 + _e716), 2i);
                                                        checker_1 = (_e719 == 0i);
                                                        let _e723 = lum1_1;
                                                        let _e724 = lum2_1;
                                                        if (_e723 > _e724) {
                                                            {
                                                                let _e726 = checker_1;
                                                                if _e726 {
                                                                    let _e727 = color1_1;
                                                                    local_5 = _e727;
                                                                } else {
                                                                    let _e728 = color2_1;
                                                                    local_5 = _e728;
                                                                }
                                                                let _e730 = local_5;
                                                                best_5 = _e730;
                                                            }
                                                        } else {
                                                            {
                                                                let _e731 = checker_1;
                                                                if _e731 {
                                                                    let _e732 = color2_1;
                                                                    local_6 = _e732;
                                                                } else {
                                                                    let _e733 = color1_1;
                                                                    local_6 = _e733;
                                                                }
                                                                let _e735 = local_6;
                                                                best_5 = _e735;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            continuing {
                                                let _e636 = j_1;
                                                let _e637 = paletteStep_1;
                                                j_1 = (_e636 - _e637);
                                            }
                                        }
                                    }
                                    continuing {
                                        let _e624 = i_5;
                                        i_5 = (_e624 + 1i);
                                    }
                                }
                                let _e736 = best_5;
                                result = _e736;
                            }
                            let _e737 = result;
                            return _e737;
                        }
                    } else {
                        let _e738 = quantizeMode_1;
                        let _e739 = MODE_INTERLACED_H;
                        if (_e738 == _e739) {
                            {
                                {
                                    let _e743 = transformed;
                                    best_6 = _e743;
                                    let _e745 = paletteDim_1;
                                    n_6 = i32(_e745.x);
                                    loop {
                                        let _e751 = i_6;
                                        if !((_e751 < 4096i)) {
                                            break;
                                        }
                                        {
                                            let _e758 = i_6;
                                            let _e759 = n_6;
                                            if (_e758 >= _e759) {
                                                break;
                                            }
                                            let _e761 = i_6;
                                            j_2 = _e761;
                                            loop {
                                                let _e763 = j_2;
                                                if !((_e763 >= 0i)) {
                                                    break;
                                                }
                                                {
                                                    let _e770 = i_6;
                                                    let _e774 = textureLoad(t_palette, vec2<i32>(_e770, 0i), 0i);
                                                    color1_2 = _e774;
                                                    let _e776 = j_2;
                                                    let _e780 = textureLoad(t_palette, vec2<i32>(_e776, 0i), 0i);
                                                    color2_2 = _e780;
                                                    let _e782 = color1_2;
                                                    let _e784 = color2_2;
                                                    avgColor_2 = ((_e782.xyz + _e784.xyz) / vec3(2f));
                                                    let _e791 = avgColor_2;
                                                    let _e792 = transformed;
                                                    delta_6 = (_e791 - _e792.xyz);
                                                    let _e796 = color1_2;
                                                    let _e798 = color2_2;
                                                    penalty_1 = (_e796.xyz - _e798.xyz);
                                                    let _e802 = delta_6;
                                                    let _e803 = delta_6;
                                                    let _e805 = penalty_1;
                                                    let _e806 = penalty_1;
                                                    let _e808 = closenessFactor_1;
                                                    distance_6 = (dot(_e802, _e803) + (dot(_e805, _e806) * _e808));
                                                    let _e812 = distance_6;
                                                    let _e813 = minDistance_6;
                                                    if (_e812 < _e813) {
                                                        {
                                                            let _e815 = distance_6;
                                                            minDistance_6 = _e815;
                                                            let _e817 = color1_2;
                                                            let _e821 = color1_2;
                                                            let _e826 = color1_2;
                                                            lum1_2 = (((0.2126f * _e817.x) + (0.7152f * _e821.y)) + (0.0722f * _e826.z));
                                                            let _e832 = color2_2;
                                                            let _e836 = color2_2;
                                                            let _e841 = color2_2;
                                                            lum2_2 = (((0.2126f * _e832.x) + (0.7152f * _e836.y)) + (0.0722f * _e841.z));
                                                            let _e846 = y_2;
                                                            let _e848 = imod(_e846, 2i);
                                                            evenRow = (_e848 == 0i);
                                                            let _e852 = lum1_2;
                                                            let _e853 = lum2_2;
                                                            if (_e852 > _e853) {
                                                                {
                                                                    let _e855 = evenRow;
                                                                    if _e855 {
                                                                        let _e856 = color1_2;
                                                                        local_7 = _e856;
                                                                    } else {
                                                                        let _e857 = color2_2;
                                                                        local_7 = _e857;
                                                                    }
                                                                    let _e859 = local_7;
                                                                    best_6 = _e859;
                                                                }
                                                            } else {
                                                                {
                                                                    let _e860 = evenRow;
                                                                    if _e860 {
                                                                        let _e861 = color2_2;
                                                                        local_8 = _e861;
                                                                    } else {
                                                                        let _e862 = color1_2;
                                                                        local_8 = _e862;
                                                                    }
                                                                    let _e864 = local_8;
                                                                    best_6 = _e864;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                continuing {
                                                    let _e767 = j_2;
                                                    let _e768 = paletteStep_1;
                                                    j_2 = (_e767 - _e768);
                                                }
                                            }
                                        }
                                        continuing {
                                            let _e755 = i_6;
                                            i_6 = (_e755 + 1i);
                                        }
                                    }
                                    let _e865 = best_6;
                                    result = _e865;
                                }
                                let _e866 = result;
                                return _e866;
                            }
                        } else {
                            let _e867 = quantizeMode_1;
                            let _e868 = MODE_INTERLACED_V;
                            if (_e867 == _e868) {
                                {
                                    {
                                        let _e872 = transformed;
                                        best_7 = _e872;
                                        let _e874 = paletteDim_1;
                                        n_7 = i32(_e874.x);
                                        loop {
                                            let _e880 = i_7;
                                            if !((_e880 < 4096i)) {
                                                break;
                                            }
                                            {
                                                let _e887 = i_7;
                                                let _e888 = n_7;
                                                if (_e887 >= _e888) {
                                                    break;
                                                }
                                                let _e890 = i_7;
                                                j_3 = _e890;
                                                loop {
                                                    let _e892 = j_3;
                                                    if !((_e892 >= 0i)) {
                                                        break;
                                                    }
                                                    {
                                                        let _e899 = i_7;
                                                        let _e903 = textureLoad(t_palette, vec2<i32>(_e899, 0i), 0i);
                                                        color1_3 = _e903;
                                                        let _e905 = j_3;
                                                        let _e909 = textureLoad(t_palette, vec2<i32>(_e905, 0i), 0i);
                                                        color2_3 = _e909;
                                                        let _e911 = color1_3;
                                                        let _e913 = color2_3;
                                                        avgColor_3 = ((_e911.xyz + _e913.xyz) / vec3(2f));
                                                        let _e920 = avgColor_3;
                                                        let _e921 = transformed;
                                                        delta_7 = (_e920 - _e921.xyz);
                                                        let _e925 = color1_3;
                                                        let _e927 = color2_3;
                                                        penalty_2 = (_e925.xyz - _e927.xyz);
                                                        let _e931 = delta_7;
                                                        let _e932 = delta_7;
                                                        let _e934 = penalty_2;
                                                        let _e935 = penalty_2;
                                                        let _e937 = closenessFactor_1;
                                                        distance_7 = (dot(_e931, _e932) + (dot(_e934, _e935) * _e937));
                                                        let _e941 = distance_7;
                                                        let _e942 = minDistance_7;
                                                        if (_e941 < _e942) {
                                                            {
                                                                let _e944 = distance_7;
                                                                minDistance_7 = _e944;
                                                                let _e946 = color1_3;
                                                                let _e950 = color1_3;
                                                                let _e955 = color1_3;
                                                                lum1_3 = (((0.2126f * _e946.x) + (0.7152f * _e950.y)) + (0.0722f * _e955.z));
                                                                let _e961 = color2_3;
                                                                let _e965 = color2_3;
                                                                let _e970 = color2_3;
                                                                lum2_3 = (((0.2126f * _e961.x) + (0.7152f * _e965.y)) + (0.0722f * _e970.z));
                                                                let _e975 = x_4;
                                                                let _e977 = imod(_e975, 2i);
                                                                evenCol = (_e977 == 0i);
                                                                let _e981 = lum1_3;
                                                                let _e982 = lum2_3;
                                                                if (_e981 > _e982) {
                                                                    {
                                                                        let _e984 = evenCol;
                                                                        if _e984 {
                                                                            let _e985 = color1_3;
                                                                            local_9 = _e985;
                                                                        } else {
                                                                            let _e986 = color2_3;
                                                                            local_9 = _e986;
                                                                        }
                                                                        let _e988 = local_9;
                                                                        best_7 = _e988;
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e989 = evenCol;
                                                                        if _e989 {
                                                                            let _e990 = color2_3;
                                                                            local_10 = _e990;
                                                                        } else {
                                                                            let _e991 = color1_3;
                                                                            local_10 = _e991;
                                                                        }
                                                                        let _e993 = local_10;
                                                                        best_7 = _e993;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    continuing {
                                                        let _e896 = j_3;
                                                        let _e897 = paletteStep_1;
                                                        j_3 = (_e896 - _e897);
                                                    }
                                                }
                                            }
                                            continuing {
                                                let _e884 = i_7;
                                                i_7 = (_e884 + 1i);
                                            }
                                        }
                                        let _e994 = best_7;
                                        result = _e994;
                                    }
                                    let _e995 = result;
                                    return _e995;
                                }
                            } else {
                                {
                                    {
                                        let _e998 = transformed;
                                        best_8 = _e998;
                                        let _e1000 = paletteDim_1;
                                        n_8 = i32(_e1000.x);
                                        loop {
                                            let _e1006 = i_8;
                                            if !((_e1006 < 4096i)) {
                                                break;
                                            }
                                            {
                                                let _e1013 = i_8;
                                                let _e1014 = n_8;
                                                if (_e1013 >= _e1014) {
                                                    break;
                                                }
                                                let _e1016 = i_8;
                                                let _e1020 = textureLoad(t_palette, vec2<i32>(_e1016, 0i), 0i);
                                                paletteColor_4 = _e1020;
                                                let _e1022 = paletteColor_4;
                                                let _e1024 = transformed;
                                                delta_8 = (_e1022.xyz - _e1024.xyz);
                                                let _e1028 = delta_8;
                                                let _e1029 = delta_8;
                                                distance_8 = dot(_e1028, _e1029);
                                                let _e1032 = distance_8;
                                                let _e1033 = minDistance_8;
                                                if (_e1032 < _e1033) {
                                                    {
                                                        let _e1035 = distance_8;
                                                        minDistance_8 = _e1035;
                                                        let _e1036 = paletteColor_4;
                                                        best_8 = _e1036;
                                                    }
                                                }
                                            }
                                            continuing {
                                                let _e1010 = i_8;
                                                i_8 = (_e1010 + 1i);
                                            }
                                        }
                                        let _e1037 = best_8;
                                        result = _e1037;
                                    }
                                    let _e1038 = result;
                                    return _e1038;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
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
    let _e72 = global.U[5];
    let _e76 = global.U[7];
    let _e81 = global.U[6];
    let _e85 = global.U[8];
    let _e89 = global.U[9];
    let _e93 = global.U[10];
    let _e97 = global.U[11];
    let _e101 = global.U[12];
    let _e105 = global.U[13];
    let _e109 = global.U[14];
    let _e112 = colorQuantize((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.xy, _e72.xy, i32(_e76.x), _e81.xy, _e85.x, _e89.x, _e93.x, _e97.x, _e101.x, _e105.x, i32(_e109.x));
    fragColor = _e112;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
