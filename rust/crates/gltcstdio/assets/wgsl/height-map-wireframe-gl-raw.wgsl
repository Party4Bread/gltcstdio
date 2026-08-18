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

fn close(a: f32, b: f32) -> bool {
    var a_1: f32;
    var b_1: f32;

    a_1 = a;
    b_1 = b;
    let _e12 = a_1;
    let _e13 = b_1;
    return (abs((_e12 - _e13)) < 0.00001f);
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

fn intersectX_hmwgl(_p: vec3<f32>, cameraPos: vec3<f32>, cameraDir: vec3<f32>, h: f32, thickness: f32, glow: f32) -> f32 {
    var _p_1: vec3<f32>;
    var cameraPos_1: vec3<f32>;
    var cameraDir_1: vec3<f32>;
    var h_1: f32;
    var thickness_1: f32;
    var glow_1: f32;
    var dist: f32;
    var t: f32;
    var b_2: f32;
    var maxDist: f32;
    var proxim: f32;

    _p_1 = _p;
    cameraPos_1 = cameraPos;
    cameraDir_1 = cameraDir;
    h_1 = h;
    thickness_1 = thickness;
    glow_1 = glow;
    let _e20 = cameraDir_1;
    let _e21 = _p_1;
    let _e22 = cameraPos_1;
    dist = dot(_e20, (_e21 - _e22));
    let _e26 = thickness_1;
    t = (_e26 * 0.01f);
    let _e30 = glow_1;
    b_2 = (_e30 * 0.1f);
    let _e34 = t;
    let _e35 = b_2;
    let _e37 = dist;
    maxDist = ((_e34 + _e35) * _e37);
    let _e40 = maxDist;
    let _e41 = cameraPos_1;
    let _e43 = _p_1;
    let _e45 = h_1;
    maxDist = (_e40 / abs(normalize((_e41.xz - vec2<f32>(_e43.x, _e45))).x));
    let _e52 = _p_1;
    let _e54 = h_1;
    let _e57 = maxDist;
    proxim = (abs((_e52.z - _e54)) / _e57);
    let _e60 = proxim;
    if (_e60 > 1f) {
        return 0f;
    }
    let _e65 = t;
    let _e66 = t;
    let _e67 = b_2;
    let _e71 = proxim;
    return (1f - pow(smoothstep((_e65 / (_e66 + _e67)), 1f, _e71), 0.5f));
}

fn intersectY_hmwgl(_p_2: vec3<f32>, cameraPos_2: vec3<f32>, cameraDir_2: vec3<f32>, h_2: f32, thickness_2: f32, glow_2: f32) -> f32 {
    var _p_3: vec3<f32>;
    var cameraPos_3: vec3<f32>;
    var cameraDir_3: vec3<f32>;
    var h_3: f32;
    var thickness_3: f32;
    var glow_3: f32;
    var dist_1: f32;
    var t_1: f32;
    var b_3: f32;
    var maxDist_1: f32;
    var proxim_1: f32;

    _p_3 = _p_2;
    cameraPos_3 = cameraPos_2;
    cameraDir_3 = cameraDir_2;
    h_3 = h_2;
    thickness_3 = thickness_2;
    glow_3 = glow_2;
    let _e20 = cameraDir_3;
    let _e21 = _p_3;
    let _e22 = cameraPos_3;
    dist_1 = dot(_e20, (_e21 - _e22));
    let _e26 = thickness_3;
    t_1 = (_e26 * 0.01f);
    let _e30 = glow_3;
    b_3 = (_e30 * 0.1f);
    let _e34 = t_1;
    let _e35 = b_3;
    let _e37 = dist_1;
    maxDist_1 = ((_e34 + _e35) * _e37);
    let _e40 = maxDist_1;
    let _e41 = cameraPos_3;
    let _e43 = _p_3;
    let _e45 = h_3;
    maxDist_1 = (_e40 / abs(normalize((_e41.yz - vec2<f32>(_e43.y, _e45))).x));
    let _e52 = _p_3;
    let _e54 = h_3;
    let _e57 = maxDist_1;
    proxim_1 = (abs((_e52.z - _e54)) / _e57);
    let _e60 = proxim_1;
    if (_e60 > 1f) {
        return 0f;
    }
    let _e65 = t_1;
    let _e66 = t_1;
    let _e67 = b_3;
    let _e71 = proxim_1;
    return (1f - pow(smoothstep((_e65 / (_e66 + _e67)), 1f, _e71), 0.5f));
}

fn heightMapWireframeGl(pos: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, rezolution: i32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>, sourceElevationDim: vec2<f32>, sourceBkg_specified: i32, sourceElevation_specified: i32, thickness_4: f32, glow_4: f32, colorLines: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var rezolution_1: i32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var sourceElevationDim_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var sourceElevation_specified_1: i32;
    var thickness_5: f32;
    var glow_5: f32;
    var colorLines_1: vec4<f32>;
    var D: f32 = 1f;
    var cameraPos_4: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir: vec3<f32>;
    var cameraDir_4: vec3<f32>;
    var heightMap: bool;
    var maxZ: f32;
    var local: f32;
    var ratio: f32;
    var local_1: f32;
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
    var local_2: vec4<f32>;
    var k: f32;
    var p: vec3<f32>;
    var strideX: f32;
    var countY: f32;
    var strideY: f32;
    var intersected: f32 = 0f;
    var _h: f32;
    var yPos: f32;
    var yIndex: f32;
    var local_3: vec4<f32>;
    var local_4: f32;
    var advanceY: f32;
    var deltaK: f32;
    var deltaY: f32;
    var maxIter: i32 = 1500i;
    var local_5: vec4<f32>;
    var xPos: f32;
    var xIndex: f32;
    var local_6: vec4<f32>;
    var local_7: f32;
    var advanceX: f32;
    var deltaK_1: f32;
    var deltaX: f32;
    var maxIter_1: i32 = 1500i;
    var local_8: vec4<f32>;
    var wireColor: vec4<f32>;
    var local_9: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    rezolution_1 = rezolution;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    sourceElevationDim_1 = sourceElevationDim;
    sourceBkg_specified_1 = sourceBkg_specified;
    sourceElevation_specified_1 = sourceElevation_specified;
    thickness_5 = thickness_4;
    glow_5 = glow_4;
    colorLines_1 = colorLines;
    let _e39 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e39);
    let _e42 = m;
    let _e43 = cameraPos_4;
    cameraPos_4 = (_e42 * vec4<f32>(_e43.x, _e43.y, _e43.z, 1f)).xyz;
    let _e51 = pos_1;
    let _e53 = D;
    let _e55 = pos_1;
    let _e57 = D;
    dir = normalize(vec3<f32>((_e51.x * _e53), (_e55.y * _e57), -1f));
    let _e64 = m;
    let _e74 = dir;
    dir = (mat3x3<f32>(_e64[0].xyz, _e64[1].xyz, _e64[2].xyz) * _e74);
    cameraDir_4 = normalize(vec3<f32>(0f, 0f, -1f));
    let _e83 = m;
    let _e93 = cameraDir_4;
    cameraDir_4 = (mat3x3<f32>(_e83[0].xyz, _e83[1].xyz, _e83[2].xyz) * _e93);
    let _e95 = sourceElevation_specified_1;
    heightMap = (_e95 == 1i);
    let _e99 = intensity_3;
    maxZ = (abs(_e99) * 0.02f);
    let _e104 = heightMap;
    if _e104 {
        let _e105 = sourceElevationDim_1;
        let _e107 = sourceElevationDim_1;
        local = (_e105.x / _e107.y);
    } else {
        let _e110 = sourceDim_1;
        let _e112 = sourceDim_1;
        local = (_e110.x / _e112.y);
    }
    let _e116 = local;
    ratio = _e116;
    let _e118 = heightMap;
    if _e118 {
        let _e120 = sourceElevationDim_1;
        local_1 = (2f / _e120.y);
    } else {
        let _e124 = sourceDim_1;
        local_1 = (2f / _e124.y);
    }
    let _e128 = local_1;
    dk = _e128;
    let _e130 = dir;
    let _e131 = dk;
    step = (_e130 * _e131);
    let _e138 = dir;
    if (_e138.x != 0f) {
        {
            let _e142 = dir;
            s = sign(_e142.x);
            let _e146 = s;
            let _e148 = ratio;
            let _e150 = cameraPos_4;
            let _e153 = dir;
            k3_ = (((-(_e146) * _e148) - _e150.x) / _e153.x);
            let _e157 = s;
            let _e158 = ratio;
            let _e160 = cameraPos_4;
            let _e163 = dir;
            k4_ = (((_e157 * _e158) - _e160.x) / _e163.x);
            let _e167 = k1_;
            let _e168 = k3_;
            k1_ = max(_e167, _e168);
            let _e170 = k2_;
            let _e171 = k4_;
            k2_ = min(_e170, _e171);
        }
    }
    let _e173 = dir;
    if (_e173.y != 0f) {
        {
            let _e177 = dir;
            s_1 = sign(_e177.y);
            let _e181 = s_1;
            let _e183 = cameraPos_4;
            let _e186 = dir;
            k3_1 = ((-(_e181) - _e183.y) / _e186.y);
            let _e190 = s_1;
            let _e191 = cameraPos_4;
            let _e194 = dir;
            k4_1 = ((_e190 - _e191.y) / _e194.y);
            let _e198 = k1_;
            let _e199 = k3_1;
            k1_ = max(_e198, _e199);
            let _e201 = k2_;
            let _e202 = k4_1;
            k2_ = min(_e201, _e202);
        }
    }
    let _e204 = maxZ;
    maxZ2_ = (_e204 + 0.0001f);
    let _e208 = dir;
    if (_e208.z != 0f) {
        {
            let _e212 = dir;
            s_2 = sign(_e212.z);
            let _e216 = s_2;
            let _e218 = maxZ2_;
            let _e220 = cameraPos_4;
            let _e223 = dir;
            k3_2 = (((-(_e216) * _e218) - _e220.z) / _e223.z);
            let _e227 = s_2;
            let _e228 = maxZ2_;
            let _e230 = cameraPos_4;
            let _e233 = dir;
            k4_2 = (((_e227 * _e228) - _e230.z) / _e233.z);
            let _e237 = k1_;
            let _e238 = k3_2;
            k1_ = max(_e237, _e238);
            let _e240 = k2_;
            let _e241 = k4_2;
            k2_ = min(_e240, _e241);
        }
    }
    let _e243 = k1_;
    let _e244 = k2_;
    if (_e243 > _e244) {
        let _e246 = sourceBkg_specified_1;
        if (_e246 == 1i) {
            let _e249 = outPos_1;
            let _e253 = global.U[0];
            let _e256 = outPos_1;
            let _e265 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e249.x / _e253.x), _e256.y) / vec2(2f)) + vec2(0.5f)));
            local_2 = _e265;
        } else {
            let _e266 = outPos_1;
            let _e270 = global.U[0];
            let _e273 = outPos_1;
            let _e282 = textureSample(t_source, samp, ((vec2<f32>((_e266.x / _e270.x), _e273.y) / vec2(2f)) + vec2(0.5f)));
            local_2 = _e282;
        }
        let _e284 = local_2;
        return _e284;
    }
    let _e285 = k1_;
    k = _e285;
    let _e287 = cameraPos_4;
    let _e288 = k;
    let _e289 = dir;
    p = (_e287 + (_e288 * _e289));
    let _e293 = ratio;
    let _e296 = rezolution_1;
    strideX = ((_e293 * 2f) / f32(_e296));
    let _e301 = strideX;
    countY = floor(((2f / _e301) + 0.5f));
    let _e308 = countY;
    strideY = (2f / _e308);
    let _e314 = p;
    let _e318 = strideY;
    yPos = ((_e314.y + 1f) / _e318);
    let _e321 = yPos;
    yIndex = floor((_e321 + 0.5f));
    let _e326 = yPos;
    let _e327 = yIndex;
    let _e328 = close(_e326, _e327);
    if _e328 {
        {
            let _e329 = intensity_3;
            let _e330 = heightMap;
            if _e330 {
                let _e331 = p;
                let _e336 = global.U[0];
                let _e339 = p;
                let _e349 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e331.x / _e336.x), _e339.y) / vec2(2f)) + vec2(0.5f)));
                local_3 = _e349;
            } else {
                let _e350 = p;
                let _e355 = global.U[0];
                let _e358 = p;
                let _e368 = textureSample(t_source, samp, ((vec2<f32>((_e350.x / _e355.x), _e358.y) / vec2(2f)) + vec2(0.5f)));
                local_3 = _e368;
            }
            let _e370 = local_3;
            let _e371 = height(_e329, _e370);
            _h = _e371;
            let _e372 = intersected;
            let _e373 = p;
            let _e374 = cameraPos_4;
            let _e375 = cameraDir_4;
            let _e376 = _h;
            let _e377 = thickness_5;
            let _e378 = glow_5;
            let _e379 = intersectY_hmwgl(_e373, _e374, _e375, _e376, _e377, _e378);
            intersected = (_e372 + _e379);
        }
    }
    let _e381 = dir;
    if (_e381.y != 0f) {
        {
            let _e385 = dir;
            if (sign(_e385.y) > 0f) {
                let _e390 = yPos;
                let _e392 = yPos;
                local_4 = (ceil(_e390) - _e392);
            } else {
                let _e394 = yPos;
                let _e396 = yPos;
                local_4 = (floor(_e394) - _e396);
            }
            let _e399 = local_4;
            let _e400 = strideY;
            advanceY = (_e399 * _e400);
            let _e403 = advanceY;
            let _e404 = dir;
            deltaK = (_e403 / _e404.y);
            let _e408 = k;
            let _e409 = deltaK;
            k = (_e408 + _e409);
            let _e411 = p;
            let _e412 = deltaK;
            let _e413 = dir;
            p = (_e411 + (_e412 * _e413));
            let _e416 = dir;
            let _e419 = strideY;
            deltaY = (sign(_e416.y) * _e419);
            let _e422 = deltaY;
            let _e423 = dir;
            deltaK = (_e422 / _e423.y);
            loop {
                let _e428 = p;
                let _e433 = k;
                let _e434 = k2_;
                let _e437 = maxIter;
                if !((((abs(_e428.y) <= 1f) && (_e433 <= _e434)) && (_e437 > 0i))) {
                    break;
                }
                {
                    let _e442 = intensity_3;
                    let _e443 = heightMap;
                    if _e443 {
                        let _e444 = p;
                        let _e449 = global.U[0];
                        let _e452 = p;
                        let _e462 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e444.x / _e449.x), _e452.y) / vec2(2f)) + vec2(0.5f)));
                        local_5 = _e462;
                    } else {
                        let _e463 = p;
                        let _e468 = global.U[0];
                        let _e471 = p;
                        let _e481 = textureSample(t_source, samp, ((vec2<f32>((_e463.x / _e468.x), _e471.y) / vec2(2f)) + vec2(0.5f)));
                        local_5 = _e481;
                    }
                    let _e483 = local_5;
                    let _e484 = height(_e442, _e483);
                    _h = _e484;
                    let _e485 = intersected;
                    let _e486 = p;
                    let _e487 = cameraPos_4;
                    let _e488 = cameraDir_4;
                    let _e489 = _h;
                    let _e490 = thickness_5;
                    let _e491 = glow_5;
                    let _e492 = intersectY_hmwgl(_e486, _e487, _e488, _e489, _e490, _e491);
                    intersected = (_e485 + _e492);
                    let _e494 = intersected;
                    if (_e494 >= 1f) {
                        break;
                    }
                    let _e497 = k;
                    let _e498 = deltaK;
                    k = (_e497 + _e498);
                    let _e500 = p;
                    let _e501 = deltaK;
                    let _e502 = dir;
                    p = (_e500 + (_e501 * _e502));
                    let _e505 = maxIter;
                    maxIter = (_e505 - 1i);
                }
            }
        }
    }
    let _e508 = k1_;
    k = _e508;
    let _e509 = cameraPos_4;
    let _e510 = k;
    let _e511 = dir;
    p = (_e509 + (_e510 * _e511));
    let _e514 = p;
    let _e518 = strideX;
    xPos = ((_e514.x + 1f) / _e518);
    let _e521 = xPos;
    xIndex = floor((_e521 + 0.5f));
    let _e526 = xPos;
    let _e527 = xIndex;
    let _e528 = close(_e526, _e527);
    if _e528 {
        {
            let _e529 = intensity_3;
            let _e530 = heightMap;
            if _e530 {
                let _e531 = p;
                let _e536 = global.U[0];
                let _e539 = p;
                let _e549 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e531.x / _e536.x), _e539.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e549;
            } else {
                let _e550 = p;
                let _e555 = global.U[0];
                let _e558 = p;
                let _e568 = textureSample(t_source, samp, ((vec2<f32>((_e550.x / _e555.x), _e558.y) / vec2(2f)) + vec2(0.5f)));
                local_6 = _e568;
            }
            let _e570 = local_6;
            let _e571 = height(_e529, _e570);
            _h = _e571;
            let _e572 = intersected;
            let _e573 = p;
            let _e574 = cameraPos_4;
            let _e575 = cameraDir_4;
            let _e576 = _h;
            let _e577 = thickness_5;
            let _e578 = glow_5;
            let _e579 = intersectX_hmwgl(_e573, _e574, _e575, _e576, _e577, _e578);
            intersected = (_e572 + _e579);
        }
    }
    let _e581 = dir;
    if (_e581.x != 0f) {
        {
            let _e585 = dir;
            if (sign(_e585.x) > 0f) {
                let _e590 = xPos;
                let _e592 = xPos;
                local_7 = (ceil(_e590) - _e592);
            } else {
                let _e594 = xPos;
                let _e596 = xPos;
                local_7 = (floor(_e594) - _e596);
            }
            let _e599 = local_7;
            let _e600 = strideX;
            advanceX = (_e599 * _e600);
            let _e603 = advanceX;
            let _e604 = dir;
            deltaK_1 = (_e603 / _e604.x);
            let _e608 = k;
            let _e609 = deltaK_1;
            k = (_e608 + _e609);
            let _e611 = p;
            let _e612 = deltaK_1;
            let _e613 = dir;
            p = (_e611 + (_e612 * _e613));
            let _e616 = dir;
            let _e619 = strideX;
            deltaX = (sign(_e616.x) * _e619);
            let _e622 = deltaX;
            let _e623 = dir;
            deltaK_1 = (_e622 / _e623.x);
            loop {
                let _e628 = p;
                let _e631 = ratio;
                let _e633 = k;
                let _e634 = k2_;
                let _e637 = maxIter_1;
                if !((((abs(_e628.x) <= _e631) && (_e633 <= _e634)) && (_e637 > 0i))) {
                    break;
                }
                {
                    let _e642 = intensity_3;
                    let _e643 = heightMap;
                    if _e643 {
                        let _e644 = p;
                        let _e649 = global.U[0];
                        let _e652 = p;
                        let _e662 = textureSample(t_sourceElevation, samp, ((vec2<f32>((_e644.x / _e649.x), _e652.y) / vec2(2f)) + vec2(0.5f)));
                        local_8 = _e662;
                    } else {
                        let _e663 = p;
                        let _e668 = global.U[0];
                        let _e671 = p;
                        let _e681 = textureSample(t_source, samp, ((vec2<f32>((_e663.x / _e668.x), _e671.y) / vec2(2f)) + vec2(0.5f)));
                        local_8 = _e681;
                    }
                    let _e683 = local_8;
                    let _e684 = height(_e642, _e683);
                    _h = _e684;
                    let _e685 = intersected;
                    let _e686 = p;
                    let _e687 = cameraPos_4;
                    let _e688 = cameraDir_4;
                    let _e689 = _h;
                    let _e690 = thickness_5;
                    let _e691 = glow_5;
                    let _e692 = intersectX_hmwgl(_e686, _e687, _e688, _e689, _e690, _e691);
                    intersected = (_e685 + _e692);
                    let _e694 = intersected;
                    if (_e694 >= 1f) {
                        break;
                    }
                    let _e697 = k;
                    let _e698 = deltaK_1;
                    k = (_e697 + _e698);
                    let _e700 = p;
                    let _e701 = deltaK_1;
                    let _e702 = dir;
                    p = (_e700 + (_e701 * _e702));
                    let _e705 = maxIter_1;
                    maxIter_1 = (_e705 - 1i);
                }
            }
        }
    }
    let _e708 = colorLines_1;
    wireColor = _e708;
    let _e710 = sourceBkg_specified_1;
    if (_e710 == 1i) {
        let _e713 = outPos_1;
        let _e717 = global.U[0];
        let _e720 = outPos_1;
        let _e729 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e713.x / _e717.x), _e720.y) / vec2(2f)) + vec2(0.5f)));
        local_9 = _e729;
    } else {
        let _e730 = outPos_1;
        let _e734 = global.U[0];
        let _e737 = outPos_1;
        let _e746 = textureSample(t_source, samp, ((vec2<f32>((_e730.x / _e734.x), _e737.y) / vec2(2f)) + vec2(0.5f)));
        local_9 = _e746;
    }
    let _e748 = local_9;
    let _e749 = wireColor;
    let _e750 = intersected;
    return mix(_e748, _e749, vec4(clamp(_e750, 0f, 1f)));
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
    let _e68 = global.U[9];
    let _e72 = global.U[10];
    let _e77 = global.U[11];
    let _e80 = global.U[12];
    let _e83 = global.U[13];
    let _e86 = global.U[14];
    let _e110 = global.U[4];
    let _e114 = global.U[5];
    let _e118 = global.U[6];
    let _e123 = global.U[7];
    let _e128 = global.U[15];
    let _e132 = global.U[16];
    let _e136 = global.U[17];
    let _e137 = heightMapWireframeGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.x, i32(_e72.x), mat4x4<f32>(vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w), vec4<f32>(_e80.x, _e80.y, _e80.z, _e80.w), vec4<f32>(_e83.x, _e83.y, _e83.z, _e83.w), vec4<f32>(_e86.x, _e86.y, _e86.z, _e86.w)), _e110.xy, _e114.xy, i32(_e118.x), i32(_e123.x), _e128.x, _e132.x, _e136);
    fragColor = _e137;
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
