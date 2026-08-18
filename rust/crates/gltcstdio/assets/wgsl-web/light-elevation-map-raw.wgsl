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

fn getDampening(shape: f32, pos: vec2<f32>, ratio: f32) -> f32 {
    var shape_1: f32;
    var pos_1: vec2<f32>;
    var ratio_1: f32;
    var p: f32;
    var local: f32;
    var k: f32;
    var local_1: vec2<f32>;
    var rr: vec2<f32>;
    var local_2: f32;
    var k_1: f32;
    var minR: f32;

    shape_1 = shape;
    pos_1 = pos;
    ratio_1 = ratio;
    let _e14 = shape_1;
    if (_e14 == 0f) {
        return 1f;
    } else {
        let _e18 = shape_1;
        if (_e18 < 0.25f) {
            {
                let _e23 = shape_1;
                p = pow(2f, (0.25f / _e23));
                let _e27 = pos_1;
                let _e30 = ratio_1;
                let _e32 = p;
                let _e34 = pos_1;
                let _e37 = p;
                let _e41 = p;
                if (pow((pow((abs(_e27.x) / _e30), _e32) + pow(abs(_e34.y), _e37)), (1f / _e41)) < 1f) {
                    local = 1f;
                } else {
                    local = 0f;
                }
                let _e49 = local;
                return _e49;
            }
        } else {
            let _e50 = shape_1;
            if (_e50 < 0.5f) {
                {
                    let _e53 = shape_1;
                    k = ((_e53 - 0.25f) * 4f);
                    let _e59 = ratio_1;
                    if (_e59 < 1f) {
                        let _e63 = ratio_1;
                        let _e66 = ratio_1;
                        local_1 = vec2<f32>((1f / _e63), (1f / _e66));
                    } else {
                        local_1 = vec2<f32>(1f, 1f);
                    }
                    let _e73 = local_1;
                    rr = _e73;
                    let _e75 = pos_1;
                    let _e77 = ratio_1;
                    let _e81 = rr;
                    let _e82 = k;
                    if (length((_e75 * mix(vec2<f32>((1f / _e77), 1f), _e81, vec2(_e82)))) < 1f) {
                        local_2 = 1f;
                    } else {
                        local_2 = 0f;
                    }
                    let _e92 = local_2;
                    return _e92;
                }
            } else {
                {
                    let _e93 = shape_1;
                    k_1 = ((_e93 - 0.5f) * 2f);
                    let _e99 = ratio_1;
                    minR = min(_e99, 1f);
                    let _e103 = minR;
                    let _e104 = minR;
                    let _e106 = k_1;
                    let _e109 = pos_1;
                    return smoothstep(_e103, (_e104 * (1f - _e106)), length(_e109));
                }
            }
        }
    }
}

fn getHeight(intensity: f32, color: vec4<f32>) -> f32 {
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
    var c: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;
    var local_3: f32;
    var local_4: f32;
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
                local_4 = _e73;
            } else {
                let _e74 = l2_;
                if (_e74 > 0f) {
                    let _e77 = l2_;
                    local_3 = _e77;
                } else {
                    local_3 = -1f;
                }
                let _e81 = local_3;
                local_4 = _e81;
            }
            let _e83 = local_4;
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

fn sphereElevationMap(pos_2: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, rezolution: i32, intensity_2: f32, shape_2: f32, brightness: f32, bokeh: f32, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var rezolution_1: i32;
    var intensity_3: f32;
    var shape_3: f32;
    var brightness_1: f32;
    var bokeh_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var maxZ: f32;
    var heightMap: bool;
    var local_5: f32;
    var ratio_2: f32;
    var local_6: f32;
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
    var local_7: vec4<f32>;
    var k_2: f32;
    var p_1: vec3<f32>;
    var local_8: vec4<f32>;
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
    var outColor: vec4<f32>;
    var nextLines: vec2<f32>;
    var maxIter: i32 = 1000i;
    var indexX: f32;
    var indexY: f32;
    var fX: f32;
    var fY: f32;
    var sphereCenter: vec3<f32>;
    var local_9: vec4<f32>;
    var hColor: vec4<f32>;
    var height: f32;
    var intersection: vec3<f32>;
    var sv: vec3<f32>;
    var dist: f32;
    var shapeDampen: f32;
    var sharp: f32;
    var next: vec2<f32>;
    var deltaK: vec2<f32>;
    var minK: f32;

    pos_3 = pos_2;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    rezolution_1 = rezolution;
    intensity_3 = intensity_2;
    shape_3 = shape_2;
    brightness_1 = brightness;
    bokeh_1 = bokeh;
    model3DTransform_1 = model3DTransform;
    let _e45 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e45);
    let _e48 = m;
    let _e49 = cameraPos;
    cameraPos = (_e48 * vec4<f32>(_e49.x, _e49.y, _e49.z, 1f)).xyz;
    let _e57 = pos_3;
    let _e59 = D;
    let _e61 = pos_3;
    let _e63 = D;
    dir_2 = vec3<f32>((_e57.x * _e59), (_e61.y * _e63), -1f);
    let _e69 = m;
    let _e79 = dir_2;
    dir_2 = normalize((mat3x3<f32>(_e69[0].xyz, _e69[1].xyz, _e69[2].xyz) * _e79));
    let _e82 = intensity_3;
    maxZ = (abs(_e82) * 0.02f);
    let _e87 = sourceElevation_specified_1;
    heightMap = (_e87 == 1i);
    let _e91 = heightMap;
    if _e91 {
        let _e92 = sourceElevationDim_1;
        let _e94 = sourceElevationDim_1;
        local_5 = (_e92.x / _e94.y);
    } else {
        let _e97 = sourceDim_1;
        let _e99 = sourceDim_1;
        local_5 = (_e97.x / _e99.y);
    }
    let _e103 = local_5;
    ratio_2 = _e103;
    let _e105 = heightMap;
    if _e105 {
        let _e107 = sourceElevationDim_1;
        local_6 = (2f / _e107.y);
    } else {
        let _e111 = sourceDim_1;
        local_6 = (2f / _e111.y);
    }
    let _e115 = local_6;
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
    let _e132 = ratio_2;
    let _e134 = ballSize;
    let _e137 = ballSize;
    surfaceWidth = (round(((2f * _e132) / _e134)) * _e137);
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
            local_7 = _e278;
        } else {
            local_7 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e285 = local_7;
        return _e285;
    }
    let _e286 = k1_;
    k_2 = _e286;
    let _e288 = cameraPos;
    let _e289 = k_2;
    let _e290 = dir_2;
    p_1 = (_e288 + (_e289 * _e290));
    let _e294 = sourceBkg_specified_1;
    if (_e294 == 1i) {
        let _e297 = outPos_1;
        let _e301 = global.U[0];
        let _e304 = outPos_1;
        let _e314 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e297.x / _e301.x), _e304.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local_8 = _e314;
    } else {
        local_8 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e321 = local_8;
    color_2 = _e321;
    let _e331 = dir_2;
    let _e334 = ballSize;
    strideX = (sign(_e331.x) * _e334);
    let _e337 = dir_2;
    let _e340 = ballSize;
    strideY = (sign(_e337.y) * _e340);
    let _e347 = color_2;
    outColor = _e347;
    let _e349 = dir_2;
    let _e352 = ballSize;
    nextLines = ((sign(_e349.xy) * _e352) / vec2(2f));
    loop {
        let _e360 = intersected;
        let _e363 = k_2;
        let _e364 = k2_;
        let _e367 = maxIter;
        if !((((_e360 < 1f) && (_e363 <= _e364)) && (_e367 > 0i))) {
            break;
        }
        {
            let _e372 = p_1;
            let _e374 = surfaceWidth;
            let _e378 = ballSize;
            indexX = ((_e372.x + (_e374 / 2f)) / _e378);
            let _e381 = p_1;
            let _e383 = surfaceHeight;
            let _e387 = ballSize;
            indexY = ((_e381.y + (_e383 / 2f)) / _e387);
            let _e390 = indexX;
            fX = fract(_e390);
            let _e393 = indexY;
            fY = fract(_e393);
            let _e397 = fX;
            let _e400 = dir_2;
            if ((_e397 > 0.9999f) && (_e400.x > 0f)) {
                let _e406 = indexX;
                let _e410 = ballSize;
                sphereCenter.x = ((ceil(_e406) + 0.5f) * _e410);
            } else {
                let _e412 = fX;
                let _e415 = dir_2;
                if ((_e412 < 0.0001f) && (_e415.x < 0f)) {
                    let _e421 = indexX;
                    let _e425 = ballSize;
                    sphereCenter.x = ((floor(_e421) - 0.5f) * _e425);
                } else {
                    let _e428 = indexX;
                    let _e432 = ballSize;
                    sphereCenter.x = ((floor(_e428) + 0.5f) * _e432);
                }
            }
            let _e435 = sphereCenter;
            let _e437 = surfaceWidth;
            sphereCenter.x = (_e435.x - (_e437 / 2f));
            let _e441 = fY;
            let _e444 = dir_2;
            if ((_e441 > 0.9999f) && (_e444.y > 0f)) {
                let _e450 = indexY;
                let _e454 = ballSize;
                sphereCenter.y = ((ceil(_e450) + 0.5f) * _e454);
            } else {
                let _e456 = fY;
                let _e459 = dir_2;
                if ((_e456 < 0.0001f) && (_e459.y < 0f)) {
                    let _e465 = indexY;
                    let _e469 = ballSize;
                    sphereCenter.y = ((floor(_e465) - 0.5f) * _e469);
                } else {
                    let _e472 = indexY;
                    let _e476 = ballSize;
                    sphereCenter.y = ((floor(_e472) + 0.5f) * _e476);
                }
            }
            let _e479 = sphereCenter;
            let _e481 = surfaceHeight;
            sphereCenter.y = (_e479.y - (_e481 / 2f));
            let _e485 = heightMap;
            if _e485 {
                let _e486 = sphereCenter;
                let _e491 = global.U[0];
                let _e494 = sphereCenter;
                let _e505 = textureSampleLevel(t_sourceElevation, samp, ((vec2<f32>((_e486.x / _e491.x), _e494.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_9 = _e505;
            } else {
                let _e506 = sphereCenter;
                let _e511 = global.U[0];
                let _e514 = sphereCenter;
                let _e525 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e506.x / _e511.x), _e514.y) / vec2(2f)) + vec2(0.5f)), 0f);
                local_9 = _e525;
            }
            let _e527 = local_9;
            hColor = _e527;
            let _e529 = intensity_3;
            let _e530 = hColor;
            let _e531 = getHeight(_e529, _e530);
            height = _e531;
            let _e534 = height;
            sphereCenter.z = _e534;
            let _e535 = sphereCenter;
            let _e538 = surfaceWidth;
            let _e542 = sphereCenter;
            let _e545 = surfaceHeight;
            if ((abs(_e535.x) < (_e538 / 2f)) && (abs(_e542.y) < (_e545 / 2f))) {
                {
                    let _e550 = sphereCenter;
                    let _e551 = ballSize;
                    let _e554 = cameraPos;
                    let _e555 = dir_2;
                    let _e556 = sphereIntersectionWithNormedDir(_e550, (_e551 / 2f), _e554, _e555);
                    intersection = _e556;
                    let _e558 = sphereCenter;
                    let _e559 = cameraPos;
                    sv = (_e558 - _e559);
                    let _e562 = sv;
                    let _e563 = dir_2;
                    let _e564 = sv;
                    let _e565 = dir_2;
                    dist = length((_e562 - (_e563 * dot(_e564, _e565))));
                    let _e571 = shape_3;
                    let _e572 = sphereCenter;
                    let _e574 = ratio_2;
                    let _e575 = getDampening(_e571, _e572.xy, _e574);
                    shapeDampen = _e575;
                    let _e578 = bokeh_1;
                    let _e580 = cameraPos;
                    let _e581 = sphereCenter;
                    sharp = pow((1f - _e578), abs(log((length((_e580 - _e581)) / 0.25f))));
                    let _e590 = outColor;
                    let _e592 = outColor;
                    let _e594 = shapeDampen;
                    let _e595 = brightness_1;
                    let _e597 = ballSize;
                    let _e600 = ballSize;
                    let _e603 = dist;
                    let _e606 = sphereCenter;
                    let _e611 = global.U[0];
                    let _e614 = sphereCenter;
                    let _e625 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e606.x / _e611.x), _e614.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e630 = fResolution;
                    let _e632 = dist;
                    let _e634 = fResolution;
                    let _e637 = sharp;
                    let _e644 = sharp;
                    let _e647 = (_e592.xyz + ((((_e594 * _e595) * smoothstep((_e597 / 2f), (_e600 / 4f), _e603)) * _e625.xyz) * mix(1f, max(((0.5f / _e630) / max(_e632, ((1f / _e634) * (1f - _e637)))), 1f), _e644)));
                    outColor.x = _e647.x;
                    outColor.y = _e647.y;
                    outColor.z = _e647.z;
                }
            }
            let _e654 = sphereCenter;
            let _e656 = nextLines;
            next = (_e654.xy + _e656);
            let _e659 = next;
            let _e660 = p_1;
            let _e663 = dir_2;
            deltaK = ((_e659 - _e660.xy) / _e663.xy);
            let _e667 = deltaK;
            let _e669 = deltaK;
            minK = min(_e667.x, _e669.y);
            let _e673 = k_2;
            let _e674 = minK;
            k_2 = (_e673 + _e674);
            let _e676 = p_1;
            let _e677 = minK;
            let _e678 = dir_2;
            p_1 = (_e676 + (_e677 * _e678));
            let _e681 = maxIter;
            maxIter = (_e681 - 1i);
        }
    }
    let _e684 = color_2;
    let _e685 = outColor;
    let _e686 = _e685.xyz;
    let _e687 = color_2;
    let _e693 = outColor;
    color_2 = mix(_e684, vec4<f32>(_e686.x, _e686.y, _e686.z, _e687.w), vec4(_e693.w));
    let _e697 = color_2;
    return clamp(_e697, vec4(0f), vec4(1f));
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
    let _e103 = global.U[13];
    let _e107 = global.U[14];
    let _e110 = global.U[15];
    let _e113 = global.U[16];
    let _e116 = global.U[17];
    let _e138 = sphereElevationMap((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), i32(_e73.x), _e78.xy, _e82.xy, i32(_e86.x), _e91.x, _e95.x, _e99.x, _e103.x, mat4x4<f32>(vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w), vec4<f32>(_e116.x, _e116.y, _e116.z, _e116.w)));
    fragColor = _e138;
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
