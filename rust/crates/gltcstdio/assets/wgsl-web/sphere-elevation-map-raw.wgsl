struct Params {
    U: array<vec4<f32>, 19>,
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

fn height(intensity: f32, color: vec4<f32>) -> f32 {
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

fn sphereIntersectionWithNormedDir(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a: f32 = 1f;
    var b: f32;
    var c_2: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local: f32;
    var local_1: f32;
    var l: f32;

    center_1 = center;
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e16 = origin_1;
    let _e17 = center_1;
    relOrigin = (_e16 - _e17);
    let _e23 = dir_1;
    let _e24 = relOrigin;
    b = (2f * dot(_e23, _e24));
    let _e28 = relOrigin;
    let _e29 = relOrigin;
    let _e31 = radius_1;
    let _e32 = radius_1;
    c_2 = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a;
    let _e42 = c_2;
    delta = ((_e36 * _e37) - ((4f * _e40) * _e42));
    let _e46 = delta;
    if (_e46 >= 0f) {
        {
            let _e49 = delta;
            sqrtDelta = sqrt(_e49);
            let _e52 = b;
            let _e54 = sqrtDelta;
            let _e57 = a;
            l1_ = ((-(_e52) - _e54) / (2f * _e57));
            let _e61 = b;
            let _e63 = sqrtDelta;
            let _e66 = a;
            l2_ = ((-(_e61) + _e63) / (2f * _e66));
            let _e70 = l1_;
            if (_e70 > 0f) {
                let _e73 = l1_;
                local_1 = _e73;
            } else {
                let _e74 = l2_;
                if (_e74 > 0f) {
                    let _e77 = l2_;
                    local = _e77;
                } else {
                    local = -1f;
                }
                let _e81 = local;
                local_1 = _e81;
            }
            let _e83 = local_1;
            l = _e83;
            let _e85 = l;
            if (_e85 > 0f) {
                {
                    let _e88 = origin_1;
                    let _e89 = l;
                    let _e90 = dir_1;
                    return (_e88 + (_e89 * _e90));
                }
            }
        }
    }
    return vec3(100000000000000000000f);
}

fn sphereElevationMap(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, rezolution: i32, intensity_2: f32, specular: f32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, colorFog: vec4<f32>, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var rezolution_1: i32;
    var intensity_3: f32;
    var specular_1: f32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var colorFog_1: vec4<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var maxZ: f32;
    var heightMap: bool;
    var local_2: f32;
    var ratio: f32;
    var local_3: f32;
    var dk: f32;
    var step: vec3<f32>;
    var fResolution: f32;
    var ballSize: f32;
    var surfaceWidth: f32;
    var surfaceHeight: f32 = 2f;
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
    var local_4: vec4<f32>;
    var local_5: vec4<f32>;
    var k: f32;
    var p: vec3<f32>;
    var local_6: vec4<f32>;
    var local_7: vec4<f32>;
    var color_2: vec4<f32>;
    var h: f32 = 0f;
    var dz: f32 = 0f;
    var prevDz: f32;
    var prevColor: vec4<f32>;
    var prevH: f32;
    var stop: bool;
    var strideX: f32;
    var strideY: f32;
    var intersected: f32 = 0f;
    var kFog: f32 = 1000000000f;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var nextLines: vec2<f32>;
    var maxIter: i32 = 1000i;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var sphereCenter: vec3<f32>;
    var local_8: vec4<f32>;
    var hColor: vec4<f32>;
    var intersection: vec3<f32>;
    var col: vec4<f32>;
    var sampled: vec4<f32>;
    var normal: vec3<f32>;
    var alpha: f32;
    var lightDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var spec: f32;
    var local_9: f32;
    var specularColor: vec4<f32>;
    var local_10: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    rezolution_1 = rezolution;
    intensity_3 = intensity_2;
    specular_1 = specular;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    colorFog_1 = colorFog;
    model3DTransform_1 = model3DTransform;
    let _e47 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e47);
    let _e50 = m;
    let _e51 = cameraPos;
    cameraPos = (_e50 * vec4<f32>(_e51.x, _e51.y, _e51.z, 1f)).xyz;
    let _e59 = pos_1;
    let _e61 = D;
    let _e63 = pos_1;
    let _e65 = D;
    dir_2 = vec3<f32>((_e59.x * _e61), (_e63.y * _e65), -1f);
    let _e71 = m;
    let _e81 = dir_2;
    dir_2 = normalize((mat3x3<f32>(_e71[0].xyz, _e71[1].xyz, _e71[2].xyz) * _e81));
    let _e84 = intensity_3;
    maxZ = (abs(_e84) * 0.02f);
    let _e89 = sourceElevation_specified_1;
    heightMap = (_e89 == 1i);
    let _e93 = heightMap;
    if _e93 {
        let _e94 = sourceElevationDim_1;
        let _e96 = sourceElevationDim_1;
        local_2 = (_e94.x / _e96.y);
    } else {
        let _e99 = sourceDim_1;
        let _e101 = sourceDim_1;
        local_2 = (_e99.x / _e101.y);
    }
    let _e105 = local_2;
    ratio = _e105;
    let _e107 = heightMap;
    if _e107 {
        let _e109 = sourceElevationDim_1;
        local_3 = (2f / _e109.y);
    } else {
        let _e113 = sourceDim_1;
        local_3 = (2f / _e113.y);
    }
    let _e117 = local_3;
    dk = _e117;
    let _e119 = dir_2;
    let _e120 = dk;
    step = (_e119 * _e120);
    let _e123 = rezolution_1;
    fResolution = f32(_e123);
    let _e127 = fResolution;
    ballSize = (2f / _e127);
    let _e130 = maxZ;
    let _e131 = ballSize;
    maxZ = (_e130 + _e131);
    let _e134 = ratio;
    let _e136 = ballSize;
    let _e139 = ballSize;
    surfaceWidth = (round(((2f * _e134) / _e136)) * _e139);
    let _e148 = dir_2;
    if (_e148.x != 0f) {
        {
            let _e152 = dir_2;
            s = sign(_e152.x);
            let _e156 = s;
            let _e158 = surfaceWidth;
            let _e162 = cameraPos;
            let _e165 = dir_2;
            k3_ = ((((-(_e156) * _e158) / 2f) - _e162.x) / _e165.x);
            let _e169 = s;
            let _e170 = surfaceWidth;
            let _e174 = cameraPos;
            let _e177 = dir_2;
            k4_ = ((((_e169 * _e170) / 2f) - _e174.x) / _e177.x);
            let _e181 = k1_;
            let _e182 = k3_;
            k1_ = max(_e181, _e182);
            let _e184 = k2_;
            let _e185 = k4_;
            k2_ = min(_e184, _e185);
        }
    }
    let _e187 = dir_2;
    if (_e187.y != 0f) {
        {
            let _e191 = dir_2;
            s_1 = sign(_e191.y);
            let _e195 = s_1;
            let _e197 = cameraPos;
            let _e200 = dir_2;
            k3_1 = ((-(_e195) - _e197.y) / _e200.y);
            let _e204 = s_1;
            let _e205 = cameraPos;
            let _e208 = dir_2;
            k4_1 = ((_e204 - _e205.y) / _e208.y);
            let _e212 = k1_;
            let _e213 = k3_1;
            k1_ = max(_e212, _e213);
            let _e215 = k2_;
            let _e216 = k4_1;
            k2_ = min(_e215, _e216);
        }
    }
    let _e218 = maxZ;
    maxZ2_ = (_e218 + 0.0001f);
    let _e222 = dir_2;
    if (_e222.z != 0f) {
        {
            let _e226 = dir_2;
            s_2 = sign(_e226.z);
            let _e230 = s_2;
            let _e232 = maxZ2_;
            let _e234 = cameraPos;
            let _e237 = dir_2;
            k3_2 = (((-(_e230) * _e232) - _e234.z) / _e237.z);
            let _e241 = s_2;
            let _e242 = maxZ2_;
            let _e244 = cameraPos;
            let _e247 = dir_2;
            k4_2 = (((_e241 * _e242) - _e244.z) / _e247.z);
            let _e251 = k1_;
            let _e252 = k3_2;
            k1_ = max(_e251, _e252);
            let _e254 = k2_;
            let _e255 = k4_2;
            k2_ = min(_e254, _e255);
        }
    }
    let _e257 = k1_;
    let _e258 = k2_;
    if (_e257 > _e258) {
        let _e260 = colorFog_1;
        if (_e260.w != 0f) {
            let _e264 = colorFog_1;
            let _e265 = _e264.xyz;
            local_5 = vec4<f32>(_e265.x, _e265.y, _e265.z, 1f);
        } else {
            let _e271 = sourceBkg_specified_1;
            if (_e271 == 1i) {
                let _e274 = outPos_1;
                let _e278 = global.U[0];
                let _e281 = outPos_1;
                let _e290 = _mirror_wrap(((vec2<f32>((_e274.x / _e278.x), _e281.y) / vec2(2f)) + vec2(0.5f)));
                let _e292 = textureSampleLevel(t_sourceBkg, samp, _e290, 0f);
                local_4 = _e292;
            } else {
                local_4 = vec4<f32>(0f, 0f, 0f, 1f);
            }
            let _e299 = local_4;
            local_5 = _e299;
        }
        let _e301 = local_5;
        return _e301;
    }
    let _e302 = k1_;
    k = _e302;
    let _e304 = cameraPos;
    let _e305 = k;
    let _e306 = dir_2;
    p = (_e304 + (_e305 * _e306));
    let _e310 = colorFog_1;
    if (_e310.w != 0f) {
        let _e314 = colorFog_1;
        let _e315 = _e314.xyz;
        local_7 = vec4<f32>(_e315.x, _e315.y, _e315.z, 1f);
    } else {
        let _e321 = sourceBkg_specified_1;
        if (_e321 == 1i) {
            let _e324 = outPos_1;
            let _e328 = global.U[0];
            let _e331 = outPos_1;
            let _e340 = _mirror_wrap(((vec2<f32>((_e324.x / _e328.x), _e331.y) / vec2(2f)) + vec2(0.5f)));
            let _e342 = textureSampleLevel(t_sourceBkg, samp, _e340, 0f);
            local_6 = _e342;
        } else {
            local_6 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e349 = local_6;
        local_7 = _e349;
    }
    let _e351 = local_7;
    color_2 = _e351;
    let _e361 = dir_2;
    let _e364 = ballSize;
    strideX = (sign(_e361.x) * _e364);
    let _e367 = dir_2;
    let _e370 = ballSize;
    strideY = (sign(_e367.y) * _e370);
    let _e383 = dir_2;
    let _e386 = ballSize;
    nextLines = ((sign(_e383.xy) * _e386) / vec2(2f));
    loop {
        let _e394 = intersected;
        let _e397 = k;
        let _e398 = k2_;
        let _e401 = maxIter;
        if !((((_e394 < 1f) && (_e397 <= _e398)) && (_e401 > 0i))) {
            break;
        }
        {
            let _e406 = p;
            let _e408 = surfaceWidth;
            let _e412 = ballSize;
            indexX = ((_e406.x + (_e408 / 2f)) / _e412);
            let _e415 = p;
            let _e417 = surfaceHeight;
            let _e421 = ballSize;
            indexY = ((_e415.y + (_e417 / 2f)) / _e421);
            let _e424 = indexX;
            fX = fract(_e424);
            let _e427 = indexY;
            fY = fract(_e427);
            let _e431 = fX;
            let _e434 = dir_2;
            if ((_e431 > 0.9999f) && (_e434.x > 0f)) {
                let _e440 = indexX;
                let _e444 = ballSize;
                sphereCenter.x = ((ceil(_e440) + 0.5f) * _e444);
            } else {
                let _e446 = fX;
                let _e449 = dir_2;
                if ((_e446 < 0.0001f) && (_e449.x < 0f)) {
                    let _e455 = indexX;
                    let _e459 = ballSize;
                    sphereCenter.x = ((floor(_e455) - 0.5f) * _e459);
                } else {
                    let _e462 = indexX;
                    let _e466 = ballSize;
                    sphereCenter.x = ((floor(_e462) + 0.5f) * _e466);
                }
            }
            let _e469 = sphereCenter;
            let _e471 = surfaceWidth;
            sphereCenter.x = (_e469.x - (_e471 / 2f));
            let _e475 = fY;
            let _e478 = dir_2;
            if ((_e475 > 0.9999f) && (_e478.y > 0f)) {
                let _e484 = indexY;
                let _e488 = ballSize;
                sphereCenter.y = ((ceil(_e484) + 0.5f) * _e488);
            } else {
                let _e490 = fY;
                let _e493 = dir_2;
                if ((_e490 < 0.0001f) && (_e493.y < 0f)) {
                    let _e499 = indexY;
                    let _e503 = ballSize;
                    sphereCenter.y = ((floor(_e499) - 0.5f) * _e503);
                } else {
                    let _e506 = indexY;
                    let _e510 = ballSize;
                    sphereCenter.y = ((floor(_e506) + 0.5f) * _e510);
                }
            }
            let _e513 = sphereCenter;
            let _e515 = surfaceHeight;
            sphereCenter.y = (_e513.y - (_e515 / 2f));
            let _e519 = heightMap;
            if _e519 {
                let _e520 = sphereCenter;
                let _e525 = global.U[0];
                let _e528 = sphereCenter;
                let _e538 = _mirror_wrap(((vec2<f32>((_e520.x / _e525.x), _e528.y) / vec2(2f)) + vec2(0.5f)));
                let _e540 = textureSampleLevel(t_sourceElevation, samp, _e538, 0f);
                local_8 = _e540;
            } else {
                let _e541 = sphereCenter;
                let _e546 = global.U[0];
                let _e549 = sphereCenter;
                let _e559 = _mirror_wrap(((vec2<f32>((_e541.x / _e546.x), _e549.y) / vec2(2f)) + vec2(0.5f)));
                let _e561 = textureSampleLevel(t_source, samp, _e559, 0f);
                local_8 = _e561;
            }
            let _e563 = local_8;
            hColor = _e563;
            let _e566 = intensity_3;
            let _e567 = hColor;
            let _e568 = height(_e566, _e567);
            sphereCenter.z = _e568;
            let _e569 = sphereCenter;
            let _e572 = surfaceWidth;
            let _e576 = sphereCenter;
            let _e579 = surfaceHeight;
            if ((abs(_e569.x) < (_e572 / 2f)) && (abs(_e576.y) < (_e579 / 2f))) {
                {
                    let _e584 = sphereCenter;
                    let _e585 = ballSize;
                    let _e588 = cameraPos;
                    let _e589 = dir_2;
                    let _e590 = sphereIntersectionWithNormedDir(_e584, (_e585 / 2f), _e588, _e589);
                    intersection = _e590;
                    let _e592 = intersection;
                    if (_e592.x != 100000000000000000000f) {
                        {
                            let _e596 = cameraPos;
                            let _e597 = intersection;
                            kFog = length((_e596 - _e597.xyz));
                            let _e601 = sphereCenter;
                            let _e606 = global.U[0];
                            let _e609 = sphereCenter;
                            let _e619 = _mirror_wrap(((vec2<f32>((_e601.x / _e606.x), _e609.y) / vec2(2f)) + vec2(0.5f)));
                            let _e621 = textureSampleLevel(t_source, samp, _e619, 0f);
                            col = _e621;
                            let _e623 = col;
                            let _e624 = ambientColor_1;
                            let _e627 = (_e624.xyz * 2f);
                            let _e628 = ambientColor_1;
                            sampled = (_e623 * vec4<f32>(_e627.x, _e627.y, _e627.z, _e628.w));
                            let _e636 = sourceColor_1;
                            if (length(_e636.xyz) != 0f) {
                                {
                                    let _e641 = intersection;
                                    let _e642 = sphereCenter;
                                    normal = (_e641 - _e642);
                                    let _e645 = normal;
                                    if (length(_e645) > 0f) {
                                        {
                                            let _e649 = sampled;
                                            alpha = _e649.w;
                                            let _e652 = normal;
                                            normal = normalize(_e652);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e660 = sampled;
                                            let _e661 = col;
                                            let _e662 = sourceColor_1;
                                            let _e665 = (_e662.xyz * 2f);
                                            let _e672 = lightDir;
                                            let _e673 = normal;
                                            sampled = (_e660 + ((_e661 * vec4<f32>(_e665.x, _e665.y, _e665.z, 1f)) * clamp(dot(_e672, _e673), 0f, 1f)));
                                            let _e680 = specular_1;
                                            if (_e680 != 0f) {
                                                {
                                                    let _e683 = lightDir;
                                                    let _e684 = normal;
                                                    reflectLightDir = reflect(_e683, _e684);
                                                    let _e687 = specular_1;
                                                    spec = _e687;
                                                    let _e689 = sourceColor_1;
                                                    let _e690 = specular_1;
                                                    if (_e690 < 0.25f) {
                                                        let _e693 = specular_1;
                                                        local_9 = (_e693 * 4f);
                                                    } else {
                                                        local_9 = 1f;
                                                    }
                                                    let _e698 = local_9;
                                                    let _e700 = dir_2;
                                                    let _e701 = reflectLightDir;
                                                    let _e707 = specular_1;
                                                    specularColor = ((_e689 * _e698) * pow(clamp(dot(_e700, _e701), 0f, 1f), (10f - (_e707 * 10f))));
                                                    let _e714 = sampled;
                                                    let _e715 = specularColor;
                                                    sampled = (_e714 + _e715);
                                                }
                                            }
                                            let _e718 = alpha;
                                            sampled.w = _e718;
                                        }
                                    }
                                }
                            }
                            let _e719 = intersected;
                            if (_e719 == 0f) {
                                let _e722 = sampled;
                                local_10 = _e722;
                            } else {
                                let _e723 = outColor;
                                let _e725 = sampled;
                                let _e727 = intersected;
                                let _e728 = intersected;
                                let _e729 = sampled;
                                let _e734 = mix(_e723.xyz, _e725.xyz, vec3((_e727 / (_e728 + _e729.w))));
                                let _e735 = outColor;
                                let _e738 = outColor;
                                let _e741 = sampled;
                                local_10 = vec4<f32>(_e734.x, _e734.y, _e734.z, (_e735.w + ((1f - _e738.w) * _e741.w)));
                            }
                            let _e750 = local_10;
                            outColor = _e750;
                            let _e751 = intersected;
                            let _e752 = sampled;
                            intersected = (_e751 + _e752.w);
                        }
                    }
                }
            }
            let _e755 = sphereCenter;
            let _e757 = nextLines;
            next = (_e755.xy + _e757);
            let _e760 = next;
            let _e761 = p;
            let _e764 = dir_2;
            deltaK = ((_e760 - _e761.xy) / _e764.xy);
            let _e768 = deltaK;
            let _e770 = deltaK;
            minK = min(_e768.x, _e770.y);
            let _e774 = k;
            let _e775 = minK;
            k = (_e774 + _e775);
            let _e777 = p;
            let _e778 = minK;
            let _e779 = dir_2;
            p = (_e777 + (_e778 * _e779));
            let _e782 = maxIter;
            maxIter = (_e782 - 1i);
        }
    }
    let _e785 = color_2;
    let _e786 = outColor;
    let _e787 = _e786.xyz;
    let _e788 = color_2;
    let _e794 = outColor;
    color_2 = mix(_e785, vec4<f32>(_e787.x, _e787.y, _e787.z, _e788.w), vec4(_e794.w));
    let _e798 = colorFog_1;
    if (_e798.w != 0f) {
        {
            let _e804 = colorFog_1;
            nearDist = (2f * (1f - _e804.w));
            let _e810 = nearDist;
            farDist = (2f * _e810);
            let _e813 = nearDist;
            let _e814 = farDist;
            let _e815 = kFog;
            kFog = smoothstep(_e813, _e814, _e815);
            let _e817 = color_2;
            let _e819 = color_2;
            let _e821 = colorFog_1;
            let _e823 = kFog;
            let _e825 = mix(_e819.xyz, _e821.xyz, vec3(_e823));
            color_2.x = _e825.x;
            color_2.y = _e825.y;
            color_2.z = _e825.z;
        }
    }
    let _e832 = color_2;
    return clamp(_e832, vec4(0f), vec4(1f));
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
    let _e78 = global.U[6];
    let _e82 = global.U[7];
    let _e86 = global.U[9];
    let _e91 = global.U[10];
    let _e95 = global.U[11];
    let _e99 = global.U[12];
    let _e102 = global.U[13];
    let _e105 = global.U[14];
    let _e108 = global.U[15];
    let _e111 = global.U[16];
    let _e114 = global.U[17];
    let _e117 = global.U[18];
    let _e139 = sphereElevationMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.xy, _e82.xy, i32(_e86.x), _e91.x, _e95.x, _e99, _e102, _e105, mat4x4<f32>(vec4<f32>(_e108.x, _e108.y, _e108.z, _e108.w), vec4<f32>(_e111.x, _e111.y, _e111.z, _e111.w), vec4<f32>(_e114.x, _e114.y, _e114.z, _e114.w), vec4<f32>(_e117.x, _e117.y, _e117.z, _e117.w)));
    fragColor = _e139;
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
