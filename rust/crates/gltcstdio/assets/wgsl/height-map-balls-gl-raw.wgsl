struct Params {
    U: array<vec4<f32>, 18>,
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

fn hmbgl_height(intensity: f32, color: vec4<f32>) -> f32 {
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

fn hmbgl_round(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e10 = x_1;
    return floor((_e10 + 0.5f));
}

fn sphereIntersectionWithNormedDir(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a: f32 = 1f;
    var b: f32;
    var c: f32;
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
    c = (dot(_e28, _e29) - (_e31 * _e32));
    let _e36 = b;
    let _e37 = b;
    let _e40 = a;
    let _e42 = c;
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

fn heightMapBallsGl(pos: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, intensity_2: f32, rezolution: i32, sourceColor: vec4<f32>, ambientColor: vec4<f32>, specular: f32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var intensity_3: f32;
    var rezolution_1: i32;
    var sourceColor_1: vec4<f32>;
    var ambientColor_1: vec4<f32>;
    var specular_1: f32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
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
    var k: f32;
    var p: vec3<f32>;
    var local_5: vec4<f32>;
    var color_2: vec4<f32>;
    var intersected: f32 = 0f;
    var outColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var nextLines: vec2<f32>;
    var maxIter: i32 = 1000i;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var sphereCenter: vec3<f32>;
    var local_6: vec4<f32>;
    var hColor: vec4<f32>;
    var h: f32;
    var intersection: vec3<f32>;
    var col: vec4<f32>;
    var sampled: vec4<f32>;
    var normal: vec3<f32>;
    var alpha: f32;
    var lightDir: vec3<f32>;
    var reflectLightDir: vec3<f32>;
    var local_7: f32;
    var specularColor: vec4<f32>;
    var local_8: vec4<f32>;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;
    var result: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    intensity_3 = intensity_2;
    rezolution_1 = rezolution;
    sourceColor_1 = sourceColor;
    ambientColor_1 = ambientColor;
    specular_1 = specular;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    model3DTransform_1 = model3DTransform;
    let _e45 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e45);
    let _e48 = m;
    let _e49 = cameraPos;
    cameraPos = (_e48 * vec4<f32>(_e49.x, _e49.y, _e49.z, 1f)).xyz;
    let _e57 = pos_1;
    let _e59 = D;
    let _e61 = pos_1;
    let _e63 = D;
    dir_2 = vec3<f32>((_e57.x * _e59), (_e61.y * _e63), -1f);
    let _e69 = m;
    let _e79 = dir_2;
    dir_2 = normalize((mat3x3<f32>(_e69[0].xyz, _e69[1].xyz, _e69[2].xyz) * _e79));
    let _e82 = sourceElevation_specified_1;
    heightMap = (_e82 == 1i);
    let _e86 = intensity_3;
    maxZ = (abs(_e86) * 0.02f);
    let _e91 = heightMap;
    if _e91 {
        let _e92 = sourceElevationDim_1;
        let _e94 = sourceElevationDim_1;
        local_2 = (_e92.x / _e94.y);
    } else {
        let _e97 = sourceDim_1;
        let _e99 = sourceDim_1;
        local_2 = (_e97.x / _e99.y);
    }
    let _e103 = local_2;
    ratio = _e103;
    let _e105 = heightMap;
    if _e105 {
        let _e107 = sourceElevationDim_1;
        local_3 = (2f / _e107.y);
    } else {
        let _e111 = sourceDim_1;
        local_3 = (2f / _e111.y);
    }
    let _e115 = local_3;
    dk = _e115;
    let _e117 = dir_2;
    let _e118 = dk;
    step = (_e117 * _e118);
    let _e121 = rezolution_1;
    fResolution = f32(_e121);
    let _e125 = fResolution;
    ballSize = (2f / _e125);
    let _e128 = maxZ;
    let _e129 = ballSize;
    maxZ = (_e128 + _e129);
    let _e132 = ratio;
    let _e134 = ballSize;
    let _e136 = hmbgl_round(((2f * _e132) / _e134));
    let _e137 = ballSize;
    surfaceWidth = (_e136 * _e137);
    let _e146 = dir_2;
    if (_e146.x != 0f) {
        {
            let _e150 = dir_2;
            s = sign(_e150.x);
            let _e154 = s;
            let _e156 = surfaceWidth;
            let _e160 = cameraPos;
            let _e163 = dir_2;
            k3_ = ((((-(_e154) * _e156) / 2f) - _e160.x) / _e163.x);
            let _e167 = s;
            let _e168 = surfaceWidth;
            let _e172 = cameraPos;
            let _e175 = dir_2;
            k4_ = ((((_e167 * _e168) / 2f) - _e172.x) / _e175.x);
            let _e179 = k1_;
            let _e180 = k3_;
            k1_ = max(_e179, _e180);
            let _e182 = k2_;
            let _e183 = k4_;
            k2_ = min(_e182, _e183);
        }
    }
    let _e185 = dir_2;
    if (_e185.y != 0f) {
        {
            let _e189 = dir_2;
            s_1 = sign(_e189.y);
            let _e193 = s_1;
            let _e195 = cameraPos;
            let _e198 = dir_2;
            k3_1 = ((-(_e193) - _e195.y) / _e198.y);
            let _e202 = s_1;
            let _e203 = cameraPos;
            let _e206 = dir_2;
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
    let _e220 = dir_2;
    if (_e220.z != 0f) {
        {
            let _e224 = dir_2;
            s_2 = sign(_e224.z);
            let _e228 = s_2;
            let _e230 = maxZ2_;
            let _e232 = cameraPos;
            let _e235 = dir_2;
            k3_2 = (((-(_e228) * _e230) - _e232.z) / _e235.z);
            let _e239 = s_2;
            let _e240 = maxZ2_;
            let _e242 = cameraPos;
            let _e245 = dir_2;
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
            let _e261 = outPos_1;
            let _e265 = global.U[0];
            let _e268 = outPos_1;
            let _e277 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e261.x / _e265.x), _e268.y) / vec2(2f)) + vec2(0.5f)));
            local_4 = _e277;
        } else {
            local_4 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e284 = local_4;
        return _e284;
    }
    let _e285 = k1_;
    k = _e285;
    let _e287 = cameraPos;
    let _e288 = k;
    let _e289 = dir_2;
    p = (_e287 + (_e288 * _e289));
    let _e293 = sourceBkg_specified_1;
    if (_e293 == 1i) {
        let _e296 = outPos_1;
        let _e300 = global.U[0];
        let _e303 = outPos_1;
        let _e312 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e296.x / _e300.x), _e303.y) / vec2(2f)) + vec2(0.5f)));
        local_5 = _e312;
    } else {
        local_5 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e319 = local_5;
    color_2 = _e319;
    let _e329 = dir_2;
    let _e332 = ballSize;
    nextLines = ((sign(_e329.xy) * _e332) / vec2(2f));
    loop {
        let _e340 = intersected;
        let _e343 = k;
        let _e344 = k2_;
        let _e347 = maxIter;
        if !((((_e340 < 1f) && (_e343 <= _e344)) && (_e347 > 0i))) {
            break;
        }
        {
            let _e352 = p;
            let _e354 = surfaceWidth;
            let _e358 = ballSize;
            indexX = ((_e352.x + (_e354 / 2f)) / _e358);
            let _e361 = p;
            let _e363 = surfaceHeight;
            let _e367 = ballSize;
            indexY = ((_e361.y + (_e363 / 2f)) / _e367);
            let _e370 = indexX;
            fX = fract(_e370);
            let _e373 = indexY;
            fY = fract(_e373);
            let _e377 = fX;
            let _e380 = dir_2;
            if ((_e377 > 0.9999f) && (_e380.x > 0f)) {
                let _e386 = indexX;
                let _e390 = ballSize;
                sphereCenter.x = ((ceil(_e386) + 0.5f) * _e390);
            } else {
                let _e392 = fX;
                let _e395 = dir_2;
                if ((_e392 < 0.0001f) && (_e395.x < 0f)) {
                    let _e401 = indexX;
                    let _e405 = ballSize;
                    sphereCenter.x = ((floor(_e401) - 0.5f) * _e405);
                } else {
                    let _e408 = indexX;
                    let _e412 = ballSize;
                    sphereCenter.x = ((floor(_e408) + 0.5f) * _e412);
                }
            }
            let _e415 = sphereCenter;
            let _e417 = surfaceWidth;
            sphereCenter.x = (_e415.x - (_e417 / 2f));
            let _e421 = fY;
            let _e424 = dir_2;
            if ((_e421 > 0.9999f) && (_e424.y > 0f)) {
                let _e430 = indexY;
                let _e434 = ballSize;
                sphereCenter.y = ((ceil(_e430) + 0.5f) * _e434);
            } else {
                let _e436 = fY;
                let _e439 = dir_2;
                if ((_e436 < 0.0001f) && (_e439.y < 0f)) {
                    let _e445 = indexY;
                    let _e449 = ballSize;
                    sphereCenter.y = ((floor(_e445) - 0.5f) * _e449);
                } else {
                    let _e452 = indexY;
                    let _e456 = ballSize;
                    sphereCenter.y = ((floor(_e452) + 0.5f) * _e456);
                }
            }
            let _e459 = sphereCenter;
            let _e461 = surfaceHeight;
            sphereCenter.y = (_e459.y - (_e461 / 2f));
            let _e465 = heightMap;
            if _e465 {
                let _e466 = sphereCenter;
                let _e471 = global.U[0];
                let _e474 = sphereCenter;
                let _e484 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e466.x / _e471.x), _e474.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e484;
            } else {
                let _e485 = sphereCenter;
                let _e490 = global.U[0];
                let _e493 = sphereCenter;
                let _e503 = textureSample(t_source, samp, ((vec2<f32>((_e485.x / _e490.x), _e493.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e503;
            }
            let _e505 = local_6;
            hColor = _e505;
            let _e507 = intensity_3;
            let _e508 = hColor;
            let _e509 = hmbgl_height(_e507, _e508);
            h = _e509;
            let _e512 = h;
            sphereCenter.z = _e512;
            let _e513 = sphereCenter;
            let _e516 = surfaceWidth;
            let _e520 = sphereCenter;
            let _e523 = surfaceHeight;
            if ((abs(_e513.x) < (_e516 / 2f)) && (abs(_e520.y) < (_e523 / 2f))) {
                {
                    let _e528 = sphereCenter;
                    let _e529 = ballSize;
                    let _e532 = cameraPos;
                    let _e533 = dir_2;
                    let _e534 = sphereIntersectionWithNormedDir(_e528, (_e529 / 2f), _e532, _e533);
                    intersection = _e534;
                    let _e536 = intersection;
                    if (_e536.x < 10000000000000000000f) {
                        {
                            let _e540 = sphereCenter;
                            let _e545 = global.U[0];
                            let _e548 = sphereCenter;
                            let _e558 = textureSample(t_source, samp, ((vec2<f32>((_e540.x / _e545.x), _e548.y) / vec2(2f)) + vec2(0.5f)));
                            col = _e558;
                            let _e560 = col;
                            let _e561 = ambientColor_1;
                            let _e564 = (_e561.xyz * 2f);
                            let _e565 = ambientColor_1;
                            sampled = (_e560 * vec4<f32>(_e564.x, _e564.y, _e564.z, _e565.w));
                            let _e573 = sourceColor_1;
                            if (length(_e573.xyz) != 0f) {
                                {
                                    let _e578 = intersection;
                                    let _e579 = sphereCenter;
                                    normal = (_e578 - _e579);
                                    let _e582 = normal;
                                    if (length(_e582) > 0f) {
                                        {
                                            let _e586 = sampled;
                                            alpha = _e586.w;
                                            let _e589 = normal;
                                            normal = normalize(_e589);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e597 = sampled;
                                            let _e598 = col;
                                            let _e599 = sourceColor_1;
                                            let _e602 = (_e599.xyz * 2f);
                                            let _e609 = lightDir;
                                            let _e610 = normal;
                                            sampled = (_e597 + ((_e598 * vec4<f32>(_e602.x, _e602.y, _e602.z, 1f)) * clamp(dot(_e609, _e610), 0f, 1f)));
                                            let _e617 = specular_1;
                                            if (_e617 != 0f) {
                                                {
                                                    let _e620 = lightDir;
                                                    let _e621 = normal;
                                                    reflectLightDir = reflect(_e620, _e621);
                                                    let _e624 = sourceColor_1;
                                                    let _e625 = specular_1;
                                                    if (_e625 < 25f) {
                                                        let _e628 = specular_1;
                                                        local_7 = (_e628 * 0.04f);
                                                    } else {
                                                        local_7 = 1f;
                                                    }
                                                    let _e633 = local_7;
                                                    let _e635 = dir_2;
                                                    let _e636 = reflectLightDir;
                                                    let _e642 = specular_1;
                                                    specularColor = ((_e624 * _e633) * pow(clamp(dot(_e635, _e636), 0f, 1f), (10f - (_e642 * 0.1f))));
                                                    let _e649 = sampled;
                                                    let _e650 = specularColor;
                                                    sampled = (_e649 + _e650);
                                                }
                                            }
                                            let _e653 = alpha;
                                            sampled.w = _e653;
                                        }
                                    }
                                }
                            }
                            let _e654 = intersected;
                            if (_e654 == 0f) {
                                let _e657 = sampled;
                                local_8 = _e657;
                            } else {
                                let _e658 = outColor;
                                let _e660 = sampled;
                                let _e662 = intersected;
                                let _e663 = intersected;
                                let _e664 = sampled;
                                let _e669 = mix(_e658.xyz, _e660.xyz, vec3((_e662 / (_e663 + _e664.w))));
                                let _e670 = outColor;
                                let _e673 = outColor;
                                let _e676 = sampled;
                                local_8 = vec4<f32>(_e669.x, _e669.y, _e669.z, (_e670.w + ((1f - _e673.w) * _e676.w)));
                            }
                            let _e685 = local_8;
                            outColor = _e685;
                            let _e686 = intersected;
                            let _e687 = sampled;
                            intersected = (_e686 + _e687.w);
                        }
                    }
                }
            }
            let _e690 = sphereCenter;
            let _e692 = nextLines;
            next = (_e690.xy + _e692);
            let _e695 = next;
            let _e696 = p;
            let _e699 = dir_2;
            deltaK = ((_e695 - _e696.xy) / _e699.xy);
            let _e703 = deltaK;
            let _e705 = deltaK;
            minK = min(_e703.x, _e705.y);
            let _e709 = k;
            let _e710 = minK;
            k = (_e709 + _e710);
            let _e712 = p;
            let _e713 = minK;
            let _e714 = dir_2;
            p = (_e712 + (_e713 * _e714));
            let _e717 = maxIter;
            maxIter = (_e717 - 1i);
        }
    }
    let _e720 = color_2;
    let _e721 = outColor;
    let _e722 = _e721.xyz;
    let _e723 = color_2;
    let _e729 = outColor;
    result = mix(_e720, vec4<f32>(_e722.x, _e722.y, _e722.z, _e723.w), vec4(_e729.w));
    let _e734 = result;
    return clamp(_e734, vec4(0f), vec4(1f));
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
    let _e78 = global.U[9];
    let _e82 = global.U[10];
    let _e87 = global.U[11];
    let _e90 = global.U[12];
    let _e93 = global.U[13];
    let _e97 = global.U[6];
    let _e101 = global.U[7];
    let _e105 = global.U[14];
    let _e108 = global.U[15];
    let _e111 = global.U[16];
    let _e114 = global.U[17];
    let _e136 = heightMapBallsGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.x, i32(_e82.x), _e87, _e90, _e93.x, _e97.xy, _e101.xy, mat4x4<f32>(vec4<f32>(_e105.x, _e105.y, _e105.z, _e105.w), vec4<f32>(_e108.x, _e108.y, _e108.z, _e108.w), vec4<f32>(_e111.x, _e111.y, _e111.z, _e111.w), vec4<f32>(_e114.x, _e114.y, _e114.z, _e114.w)));
    fragColor = _e136;
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
