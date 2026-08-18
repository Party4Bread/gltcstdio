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
            let _e278 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e261.x / _e265.x), _e268.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local_4 = _e278;
        } else {
            local_4 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e285 = local_4;
        return _e285;
    }
    let _e286 = k1_;
    k = _e286;
    let _e288 = cameraPos;
    let _e289 = k;
    let _e290 = dir_2;
    p = (_e288 + (_e289 * _e290));
    let _e294 = sourceBkg_specified_1;
    if (_e294 == 1i) {
        let _e297 = outPos_1;
        let _e301 = global.U[0];
        let _e304 = outPos_1;
        let _e314 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e297.x / _e301.x), _e304.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_5 = _e314;
    } else {
        local_5 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e321 = local_5;
    color_2 = _e321;
    let _e331 = dir_2;
    let _e334 = ballSize;
    nextLines = ((sign(_e331.xy) * _e334) / vec2(2f));
    loop {
        let _e342 = intersected;
        let _e345 = k;
        let _e346 = k2_;
        let _e349 = maxIter;
        if !((((_e342 < 1f) && (_e345 <= _e346)) && (_e349 > 0i))) {
            break;
        }
        {
            let _e354 = p;
            let _e356 = surfaceWidth;
            let _e360 = ballSize;
            indexX = ((_e354.x + (_e356 / 2f)) / _e360);
            let _e363 = p;
            let _e365 = surfaceHeight;
            let _e369 = ballSize;
            indexY = ((_e363.y + (_e365 / 2f)) / _e369);
            let _e372 = indexX;
            fX = fract(_e372);
            let _e375 = indexY;
            fY = fract(_e375);
            let _e379 = fX;
            let _e382 = dir_2;
            if ((_e379 > 0.9999f) && (_e382.x > 0f)) {
                let _e388 = indexX;
                let _e392 = ballSize;
                sphereCenter.x = ((ceil(_e388) + 0.5f) * _e392);
            } else {
                let _e394 = fX;
                let _e397 = dir_2;
                if ((_e394 < 0.0001f) && (_e397.x < 0f)) {
                    let _e403 = indexX;
                    let _e407 = ballSize;
                    sphereCenter.x = ((floor(_e403) - 0.5f) * _e407);
                } else {
                    let _e410 = indexX;
                    let _e414 = ballSize;
                    sphereCenter.x = ((floor(_e410) + 0.5f) * _e414);
                }
            }
            let _e417 = sphereCenter;
            let _e419 = surfaceWidth;
            sphereCenter.x = (_e417.x - (_e419 / 2f));
            let _e423 = fY;
            let _e426 = dir_2;
            if ((_e423 > 0.9999f) && (_e426.y > 0f)) {
                let _e432 = indexY;
                let _e436 = ballSize;
                sphereCenter.y = ((ceil(_e432) + 0.5f) * _e436);
            } else {
                let _e438 = fY;
                let _e441 = dir_2;
                if ((_e438 < 0.0001f) && (_e441.y < 0f)) {
                    let _e447 = indexY;
                    let _e451 = ballSize;
                    sphereCenter.y = ((floor(_e447) - 0.5f) * _e451);
                } else {
                    let _e454 = indexY;
                    let _e458 = ballSize;
                    sphereCenter.y = ((floor(_e454) + 0.5f) * _e458);
                }
            }
            let _e461 = sphereCenter;
            let _e463 = surfaceHeight;
            sphereCenter.y = (_e461.y - (_e463 / 2f));
            let _e467 = heightMap;
            if _e467 {
                let _e468 = sphereCenter;
                let _e473 = global.U[0];
                let _e476 = sphereCenter;
                let _e487 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e468.x / _e473.x), _e476.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_6 = _e487;
            } else {
                let _e488 = sphereCenter;
                let _e493 = global.U[0];
                let _e496 = sphereCenter;
                let _e507 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e488.x / _e493.x), _e496.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_6 = _e507;
            }
            let _e509 = local_6;
            hColor = _e509;
            let _e511 = intensity_3;
            let _e512 = hColor;
            let _e513 = hmbgl_height(_e511, _e512);
            h = _e513;
            let _e516 = h;
            sphereCenter.z = _e516;
            let _e517 = sphereCenter;
            let _e520 = surfaceWidth;
            let _e524 = sphereCenter;
            let _e527 = surfaceHeight;
            if ((abs(_e517.x) < (_e520 / 2f)) && (abs(_e524.y) < (_e527 / 2f))) {
                {
                    let _e532 = sphereCenter;
                    let _e533 = ballSize;
                    let _e536 = cameraPos;
                    let _e537 = dir_2;
                    let _e538 = sphereIntersectionWithNormedDir(_e532, (_e533 / 2f), _e536, _e537);
                    intersection = _e538;
                    let _e540 = intersection;
                    if (_e540.x < 10000000000000000000f) {
                        {
                            let _e544 = sphereCenter;
                            let _e549 = global.U[0];
                            let _e552 = sphereCenter;
                            let _e563 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e544.x / _e549.x), _e552.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e563;
                            let _e565 = col;
                            let _e566 = ambientColor_1;
                            let _e569 = (_e566.xyz * 2f);
                            let _e570 = ambientColor_1;
                            sampled = (_e565 * vec4<f32>(_e569.x, _e569.y, _e569.z, _e570.w));
                            let _e578 = sourceColor_1;
                            if (length(_e578.xyz) != 0f) {
                                {
                                    let _e583 = intersection;
                                    let _e584 = sphereCenter;
                                    normal = (_e583 - _e584);
                                    let _e587 = normal;
                                    if (length(_e587) > 0f) {
                                        {
                                            let _e591 = sampled;
                                            alpha = _e591.w;
                                            let _e594 = normal;
                                            normal = normalize(_e594);
                                            lightDir = normalize(vec3<f32>(1f, 1f, 1f));
                                            let _e602 = sampled;
                                            let _e603 = col;
                                            let _e604 = sourceColor_1;
                                            let _e607 = (_e604.xyz * 2f);
                                            let _e614 = lightDir;
                                            let _e615 = normal;
                                            sampled = (_e602 + ((_e603 * vec4<f32>(_e607.x, _e607.y, _e607.z, 1f)) * clamp(dot(_e614, _e615), 0f, 1f)));
                                            let _e622 = specular_1;
                                            if (_e622 != 0f) {
                                                {
                                                    let _e625 = lightDir;
                                                    let _e626 = normal;
                                                    reflectLightDir = reflect(_e625, _e626);
                                                    let _e629 = sourceColor_1;
                                                    let _e630 = specular_1;
                                                    if (_e630 < 25f) {
                                                        let _e633 = specular_1;
                                                        local_7 = (_e633 * 0.04f);
                                                    } else {
                                                        local_7 = 1f;
                                                    }
                                                    let _e638 = local_7;
                                                    let _e640 = dir_2;
                                                    let _e641 = reflectLightDir;
                                                    let _e647 = specular_1;
                                                    specularColor = ((_e629 * _e638) * pow(clamp(dot(_e640, _e641), 0f, 1f), (10f - (_e647 * 0.1f))));
                                                    let _e654 = sampled;
                                                    let _e655 = specularColor;
                                                    sampled = (_e654 + _e655);
                                                }
                                            }
                                            let _e658 = alpha;
                                            sampled.w = _e658;
                                        }
                                    }
                                }
                            }
                            let _e659 = intersected;
                            if (_e659 == 0f) {
                                let _e662 = sampled;
                                local_8 = _e662;
                            } else {
                                let _e663 = outColor;
                                let _e665 = sampled;
                                let _e667 = intersected;
                                let _e668 = intersected;
                                let _e669 = sampled;
                                let _e674 = mix(_e663.xyz, _e665.xyz, vec3((_e667 / (_e668 + _e669.w))));
                                let _e675 = outColor;
                                let _e678 = outColor;
                                let _e681 = sampled;
                                local_8 = vec4<f32>(_e674.x, _e674.y, _e674.z, (_e675.w + ((1f - _e678.w) * _e681.w)));
                            }
                            let _e690 = local_8;
                            outColor = _e690;
                            let _e691 = intersected;
                            let _e692 = sampled;
                            intersected = (_e691 + _e692.w);
                        }
                    }
                }
            }
            let _e695 = sphereCenter;
            let _e697 = nextLines;
            next = (_e695.xy + _e697);
            let _e700 = next;
            let _e701 = p;
            let _e704 = dir_2;
            deltaK = ((_e700 - _e701.xy) / _e704.xy);
            let _e708 = deltaK;
            let _e710 = deltaK;
            minK = min(_e708.x, _e710.y);
            let _e714 = k;
            let _e715 = minK;
            k = (_e714 + _e715);
            let _e717 = p;
            let _e718 = minK;
            let _e719 = dir_2;
            p = (_e717 + (_e718 * _e719));
            let _e722 = maxIter;
            maxIter = (_e722 - 1i);
        }
    }
    let _e725 = color_2;
    let _e726 = outColor;
    let _e727 = _e726.xyz;
    let _e728 = color_2;
    let _e734 = outColor;
    result = mix(_e725, vec4<f32>(_e727.x, _e727.y, _e727.z, _e728.w), vec4(_e734.w));
    let _e739 = result;
    return clamp(_e739, vec4(0f), vec4(1f));
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
