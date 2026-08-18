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
            let _e277 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e261.x / _e265.x), _e268.y) / vec2(2f)) + vec2(0.5f)));
            local_7 = _e277;
        } else {
            local_7 = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e284 = local_7;
        return _e284;
    }
    let _e285 = k1_;
    k_2 = _e285;
    let _e287 = cameraPos;
    let _e288 = k_2;
    let _e289 = dir_2;
    p_1 = (_e287 + (_e288 * _e289));
    let _e293 = sourceBkg_specified_1;
    if (_e293 == 1i) {
        let _e296 = outPos_1;
        let _e300 = global.U[0];
        let _e303 = outPos_1;
        let _e312 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e296.x / _e300.x), _e303.y) / vec2(2f)) + vec2(0.5f)));
        local_8 = _e312;
    } else {
        local_8 = vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e319 = local_8;
    color_2 = _e319;
    let _e329 = dir_2;
    let _e332 = ballSize;
    strideX = (sign(_e329.x) * _e332);
    let _e335 = dir_2;
    let _e338 = ballSize;
    strideY = (sign(_e335.y) * _e338);
    let _e345 = color_2;
    outColor = _e345;
    let _e347 = dir_2;
    let _e350 = ballSize;
    nextLines = ((sign(_e347.xy) * _e350) / vec2(2f));
    loop {
        let _e358 = intersected;
        let _e361 = k_2;
        let _e362 = k2_;
        let _e365 = maxIter;
        if !((((_e358 < 1f) && (_e361 <= _e362)) && (_e365 > 0i))) {
            break;
        }
        {
            let _e370 = p_1;
            let _e372 = surfaceWidth;
            let _e376 = ballSize;
            indexX = ((_e370.x + (_e372 / 2f)) / _e376);
            let _e379 = p_1;
            let _e381 = surfaceHeight;
            let _e385 = ballSize;
            indexY = ((_e379.y + (_e381 / 2f)) / _e385);
            let _e388 = indexX;
            fX = fract(_e388);
            let _e391 = indexY;
            fY = fract(_e391);
            let _e395 = fX;
            let _e398 = dir_2;
            if ((_e395 > 0.9999f) && (_e398.x > 0f)) {
                let _e404 = indexX;
                let _e408 = ballSize;
                sphereCenter.x = ((ceil(_e404) + 0.5f) * _e408);
            } else {
                let _e410 = fX;
                let _e413 = dir_2;
                if ((_e410 < 0.0001f) && (_e413.x < 0f)) {
                    let _e419 = indexX;
                    let _e423 = ballSize;
                    sphereCenter.x = ((floor(_e419) - 0.5f) * _e423);
                } else {
                    let _e426 = indexX;
                    let _e430 = ballSize;
                    sphereCenter.x = ((floor(_e426) + 0.5f) * _e430);
                }
            }
            let _e433 = sphereCenter;
            let _e435 = surfaceWidth;
            sphereCenter.x = (_e433.x - (_e435 / 2f));
            let _e439 = fY;
            let _e442 = dir_2;
            if ((_e439 > 0.9999f) && (_e442.y > 0f)) {
                let _e448 = indexY;
                let _e452 = ballSize;
                sphereCenter.y = ((ceil(_e448) + 0.5f) * _e452);
            } else {
                let _e454 = fY;
                let _e457 = dir_2;
                if ((_e454 < 0.0001f) && (_e457.y < 0f)) {
                    let _e463 = indexY;
                    let _e467 = ballSize;
                    sphereCenter.y = ((floor(_e463) - 0.5f) * _e467);
                } else {
                    let _e470 = indexY;
                    let _e474 = ballSize;
                    sphereCenter.y = ((floor(_e470) + 0.5f) * _e474);
                }
            }
            let _e477 = sphereCenter;
            let _e479 = surfaceHeight;
            sphereCenter.y = (_e477.y - (_e479 / 2f));
            let _e483 = heightMap;
            if _e483 {
                let _e484 = sphereCenter;
                let _e489 = global.U[0];
                let _e492 = sphereCenter;
                let _e502 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e484.x / _e489.x), _e492.y) / vec2(2f)) + vec2(0.5f)));
                local_9 = _e502;
            } else {
                let _e503 = sphereCenter;
                let _e508 = global.U[0];
                let _e511 = sphereCenter;
                let _e521 = textureSample(t_source, samp, ((vec2<f32>((_e503.x / _e508.x), _e511.y) / vec2(2f)) + vec2(0.5f)));
                local_9 = _e521;
            }
            let _e523 = local_9;
            hColor = _e523;
            let _e525 = intensity_3;
            let _e526 = hColor;
            let _e527 = getHeight(_e525, _e526);
            height = _e527;
            let _e530 = height;
            sphereCenter.z = _e530;
            let _e531 = sphereCenter;
            let _e534 = surfaceWidth;
            let _e538 = sphereCenter;
            let _e541 = surfaceHeight;
            if ((abs(_e531.x) < (_e534 / 2f)) && (abs(_e538.y) < (_e541 / 2f))) {
                {
                    let _e546 = sphereCenter;
                    let _e547 = ballSize;
                    let _e550 = cameraPos;
                    let _e551 = dir_2;
                    let _e552 = sphereIntersectionWithNormedDir(_e546, (_e547 / 2f), _e550, _e551);
                    intersection = _e552;
                    let _e554 = sphereCenter;
                    let _e555 = cameraPos;
                    sv = (_e554 - _e555);
                    let _e558 = sv;
                    let _e559 = dir_2;
                    let _e560 = sv;
                    let _e561 = dir_2;
                    dist = length((_e558 - (_e559 * dot(_e560, _e561))));
                    let _e567 = shape_3;
                    let _e568 = sphereCenter;
                    let _e570 = ratio_2;
                    let _e571 = getDampening(_e567, _e568.xy, _e570);
                    shapeDampen = _e571;
                    let _e574 = bokeh_1;
                    let _e576 = cameraPos;
                    let _e577 = sphereCenter;
                    sharp = pow((1f - _e574), abs(log((length((_e576 - _e577)) / 0.25f))));
                    let _e586 = outColor;
                    let _e588 = outColor;
                    let _e590 = shapeDampen;
                    let _e591 = brightness_1;
                    let _e593 = ballSize;
                    let _e596 = ballSize;
                    let _e599 = dist;
                    let _e602 = sphereCenter;
                    let _e607 = global.U[0];
                    let _e610 = sphereCenter;
                    let _e620 = textureSample(t_source, samp, ((vec2<f32>((_e602.x / _e607.x), _e610.y) / vec2(2f)) + vec2(0.5f)));
                    let _e625 = fResolution;
                    let _e627 = dist;
                    let _e629 = fResolution;
                    let _e632 = sharp;
                    let _e639 = sharp;
                    let _e642 = (_e588.xyz + ((((_e590 * _e591) * smoothstep((_e593 / 2f), (_e596 / 4f), _e599)) * _e620.xyz) * mix(1f, max(((0.5f / _e625) / max(_e627, ((1f / _e629) * (1f - _e632)))), 1f), _e639)));
                    outColor.x = _e642.x;
                    outColor.y = _e642.y;
                    outColor.z = _e642.z;
                }
            }
            let _e649 = sphereCenter;
            let _e651 = nextLines;
            next = (_e649.xy + _e651);
            let _e654 = next;
            let _e655 = p_1;
            let _e658 = dir_2;
            deltaK = ((_e654 - _e655.xy) / _e658.xy);
            let _e662 = deltaK;
            let _e664 = deltaK;
            minK = min(_e662.x, _e664.y);
            let _e668 = k_2;
            let _e669 = minK;
            k_2 = (_e668 + _e669);
            let _e671 = p_1;
            let _e672 = minK;
            let _e673 = dir_2;
            p_1 = (_e671 + (_e672 * _e673));
            let _e676 = maxIter;
            maxIter = (_e676 - 1i);
        }
    }
    let _e679 = color_2;
    let _e680 = outColor;
    let _e681 = _e680.xyz;
    let _e682 = color_2;
    let _e688 = outColor;
    color_2 = mix(_e679, vec4<f32>(_e681.x, _e681.y, _e681.z, _e682.w), vec4(_e688.w));
    let _e692 = color_2;
    return clamp(_e692, vec4(0f), vec4(1f));
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
