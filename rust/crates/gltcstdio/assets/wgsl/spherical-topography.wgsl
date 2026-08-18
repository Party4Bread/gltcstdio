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

fn getRay(uv: vec2<f32>, camera: vec3<f32>, target_: vec3<f32>, focalDist: f32) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var camera_1: vec3<f32>;
    var target_1: vec3<f32>;
    var focalDist_1: f32;
    var camZ: vec3<f32>;
    var camX: vec3<f32>;
    var camY: vec3<f32>;

    uv_1 = uv;
    camera_1 = camera;
    target_1 = target_;
    focalDist_1 = focalDist;
    let _e15 = target_1;
    let _e16 = camera_1;
    camZ = normalize((_e15 - _e16));
    let _e24 = camZ;
    camX = normalize(cross(vec3<f32>(0f, 1f, 0f), _e24));
    let _e28 = camZ;
    let _e29 = camX;
    camY = cross(_e28, _e29);
    let _e32 = camZ;
    let _e33 = focalDist_1;
    let _e35 = uv_1;
    let _e37 = camX;
    let _e40 = uv_1;
    let _e42 = camY;
    return normalize((((_e32 * _e33) + (_e35.x * _e37)) + (_e40.y * _e42)));
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e14 = c_1;
    let _e19 = c_1;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn sphereFirstIntersection(center: vec3<f32>, radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var center_1: vec3<f32>;
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var relOrigin: vec3<f32>;
    var a: f32;
    var b: f32;
    var c_2: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;

    center_1 = center;
    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e15 = origin_1;
    let _e16 = center_1;
    relOrigin = (_e15 - _e16);
    let _e19 = dir_1;
    let _e20 = dir_1;
    a = dot(_e19, _e20);
    let _e24 = dir_1;
    let _e25 = relOrigin;
    b = (2f * dot(_e24, _e25));
    let _e29 = relOrigin;
    let _e30 = relOrigin;
    let _e32 = radius_1;
    let _e33 = radius_1;
    c_2 = (dot(_e29, _e30) - (_e32 * _e33));
    let _e37 = b;
    let _e38 = b;
    let _e41 = a;
    let _e43 = c_2;
    delta = ((_e37 * _e38) - ((4f * _e41) * _e43));
    let _e47 = delta;
    if (_e47 >= 0f) {
        {
            let _e50 = delta;
            sqrtDelta = sqrt(_e50);
            let _e53 = b;
            let _e55 = sqrtDelta;
            let _e58 = a;
            l1_ = ((-(_e53) - _e55) / (2f * _e58));
            let _e62 = l1_;
            if (_e62 > 0f) {
                {
                    let _e65 = origin_1;
                    let _e66 = l1_;
                    let _e67 = dir_1;
                    return (_e65 + (_e66 * _e67));
                }
            }
        }
    }
    return vec3(100000000000000000000f);
}

fn sphereLastIntersection(center_2: vec3<f32>, radius_2: f32, origin_2: vec3<f32>, dir_2: vec3<f32>) -> vec3<f32> {
    var center_3: vec3<f32>;
    var radius_3: f32;
    var origin_3: vec3<f32>;
    var dir_3: vec3<f32>;
    var relOrigin_1: vec3<f32>;
    var a_1: f32;
    var b_1: f32;
    var c_3: f32;
    var delta_1: f32;
    var sqrtDelta_1: f32;
    var l2_: f32;

    center_3 = center_2;
    radius_3 = radius_2;
    origin_3 = origin_2;
    dir_3 = dir_2;
    let _e15 = origin_3;
    let _e16 = center_3;
    relOrigin_1 = (_e15 - _e16);
    let _e19 = dir_3;
    let _e20 = dir_3;
    a_1 = dot(_e19, _e20);
    let _e24 = dir_3;
    let _e25 = relOrigin_1;
    b_1 = (2f * dot(_e24, _e25));
    let _e29 = relOrigin_1;
    let _e30 = relOrigin_1;
    let _e32 = radius_3;
    let _e33 = radius_3;
    c_3 = (dot(_e29, _e30) - (_e32 * _e33));
    let _e37 = b_1;
    let _e38 = b_1;
    let _e41 = a_1;
    let _e43 = c_3;
    delta_1 = ((_e37 * _e38) - ((4f * _e41) * _e43));
    let _e47 = delta_1;
    if (_e47 >= 0f) {
        {
            let _e50 = delta_1;
            sqrtDelta_1 = sqrt(_e50);
            let _e53 = b_1;
            let _e55 = sqrtDelta_1;
            let _e58 = a_1;
            l2_ = ((-(_e53) + _e55) / (2f * _e58));
            let _e62 = l2_;
            if (_e62 > 0f) {
                {
                    let _e65 = origin_3;
                    let _e66 = l2_;
                    let _e67 = dir_3;
                    return (_e65 + (_e66 * _e67));
                }
            }
        }
    }
    return vec3(100000000000000000000f);
}

fn sphericalTopography(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, count: i32, overlap: f32, sourceBkg_specified: i32, colorFog: vec4<f32>, mode: i32, kernelRadius: f32, colorKernel: vec4<f32>, blend: f32, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var overlap_1: f32;
    var sourceBkg_specified_1: i32;
    var colorFog_1: vec4<f32>;
    var mode_1: i32;
    var kernelRadius_1: f32;
    var colorKernel_1: vec4<f32>;
    var blend_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var ratio: f32;
    var blendedWidth: f32;
    var blendedRatio: f32;
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_4: vec3<f32>;
    var kFog: f32 = 1000000000f;
    var local: vec4<f32>;
    var local_1: vec4<f32>;
    var col: vec4<f32>;
    var N: f32;
    var layerSize: f32;
    var layerOffset: f32;
    var mid: f32;
    var normalPoint: vec3<f32>;
    var kNormal: f32;
    var startLayer: f32;
    var normalLayer: f32;
    var local_2: f32;
    var local_3: f32;
    var iterDir: f32;
    var N0_: f32;
    var N1_: f32;
    var local_4: f32;
    var N2_: f32;
    var opacity: f32 = 0f;
    var intersection: vec3<f32>;
    var i: f32;
    var radius_4: f32;
    var angle: f32;
    var sampleCol: vec4<f32>;
    var x: f32;
    var X: f32;
    var q: vec2<f32>;
    var x1_: f32;
    var x2_: f32;
    var q1_: vec2<f32>;
    var q2_: vec2<f32>;
    var k: f32;
    var lum: f32;
    var layerStart: f32;
    var layerEnd: f32;
    var i_1: f32;
    var radius_5: f32;
    var angle_1: f32;
    var sampleCol_1: vec4<f32>;
    var x_1: f32;
    var X_1: f32;
    var q_1: vec2<f32>;
    var x1_1: f32;
    var x2_1: f32;
    var q1_1: vec2<f32>;
    var q2_1: vec2<f32>;
    var k_1: f32;
    var lum_1: f32;
    var layerStart_1: f32;
    var layerEnd_1: f32;
    var nearDist: f32;
    var farDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    count_1 = count;
    overlap_1 = overlap;
    sourceBkg_specified_1 = sourceBkg_specified;
    colorFog_1 = colorFog;
    mode_1 = mode;
    kernelRadius_1 = kernelRadius;
    colorKernel_1 = colorKernel;
    blend_1 = blend;
    model3DTransform_1 = model3DTransform;
    let _e39 = sourceDim_1;
    let _e41 = sourceDim_1;
    ratio = (_e39.x / _e41.y);
    let _e45 = sourceDim_1;
    let _e48 = blend_1;
    blendedWidth = (_e45.x * (1f - (_e48 * 0.5f)));
    let _e54 = blendedWidth;
    let _e55 = sourceDim_1;
    blendedRatio = (_e54 / _e55.y);
    let _e66 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e66);
    let _e69 = m;
    let _e70 = cameraPos;
    cameraPos = (_e69 * vec4<f32>(_e70.x, _e70.y, _e70.z, 1f)).xyz;
    let _e78 = pos_1;
    let _e80 = D;
    let _e82 = pos_1;
    let _e84 = D;
    dir_4 = vec3<f32>((_e78.x * _e80), (_e82.y * _e84), -1f);
    let _e90 = m;
    let _e100 = dir_4;
    dir_4 = normalize((mat3x3<f32>(_e90[0].xyz, _e90[1].xyz, _e90[2].xyz) * _e100));
    let _e105 = colorFog_1;
    if (_e105.w != 0f) {
        let _e109 = colorFog_1;
        let _e110 = _e109.xyz;
        local_1 = vec4<f32>(_e110.x, _e110.y, _e110.z, 1f);
    } else {
        let _e116 = sourceBkg_specified_1;
        if (_e116 == 1i) {
            let _e119 = outPos_1;
            let _e123 = global.U[0];
            let _e126 = outPos_1;
            let _e135 = textureSample(t_sourceBkg, samp, ((vec2<f32>((_e119.x / _e123.x), _e126.y) / vec2(2f)) + vec2(0.5f)));
            local = _e135;
        } else {
            local = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e142 = local;
        local_1 = _e142;
    }
    let _e144 = local_1;
    col = _e144;
    let _e146 = dir_4;
    if (_e146.z == 0f) {
        let _e150 = col;
        return _e150;
    }
    let _e151 = count_1;
    N = f32(_e151);
    let _e155 = overlap_1;
    let _e156 = N;
    let _e161 = N;
    layerSize = ((1f + (_e155 * (_e156 - 1f))) / _e161);
    let _e165 = layerSize;
    let _e168 = N;
    layerOffset = ((1f - _e165) / max(1f, (_e168 - 1f)));
    let _e174 = N;
    mid = ((_e174 - 1f) * 0.5f);
    let _e180 = mode_1;
    if (_e180 == 2i) {
        let _e183 = intensity_1;
        intensity_1 = -(_e183);
    }
    let _e185 = cameraPos;
    let _e186 = dir_4;
    let _e187 = cameraPos;
    let _e190 = dir_4;
    normalPoint = (_e185 + (dot(_e186, -(_e187)) * _e190));
    let _e194 = normalPoint;
    let _e195 = cameraPos;
    let _e197 = dir_4;
    kNormal = dot((_e194 - _e195), _e197);
    let _e200 = cameraPos;
    let _e204 = N;
    let _e206 = intensity_1;
    let _e208 = mid;
    startLayer = ((((length(_e200) - 1f) * _e204) / _e206) + _e208);
    let _e211 = normalPoint;
    let _e215 = N;
    let _e217 = intensity_1;
    let _e219 = mid;
    normalLayer = ((((length(_e211) - 1f) * _e215) / _e217) + _e219);
    let _e222 = mode_1;
    if (_e222 == 2i) {
        local_2 = -1f;
    } else {
        local_2 = 1f;
    }
    let _e229 = local_2;
    let _e230 = intensity_1;
    if (_e230 >= 0f) {
        local_3 = 1f;
    } else {
        local_3 = -1f;
    }
    let _e237 = local_3;
    iterDir = (_e229 * _e237);
    let _e240 = startLayer;
    let _e243 = N;
    N0_ = clamp(ceil(_e240), 0f, (_e243 - 1f));
    let _e248 = normalLayer;
    let _e251 = N;
    N1_ = clamp(floor(_e248), 0f, (_e251 - 1f));
    let _e256 = iterDir;
    if (_e256 >= 0f) {
        let _e259 = N;
        local_4 = (_e259 - 1f);
    } else {
        local_4 = 0f;
    }
    let _e264 = local_4;
    N2_ = _e264;
    let _e269 = N0_;
    let _e270 = iterDir;
    let _e272 = N1_;
    let _e273 = iterDir;
    if ((_e269 * _e270) >= (_e272 * _e273)) {
        {
            let _e276 = N0_;
            i = _e276;
            loop {
                let _e278 = i;
                let _e279 = iterDir;
                let _e281 = N1_;
                let _e282 = iterDir;
                if !(((_e278 * _e279) >= (_e281 * _e282))) {
                    break;
                }
                {
                    let _e290 = i;
                    let _e291 = mid;
                    let _e293 = N;
                    let _e295 = intensity_1;
                    radius_4 = (1f + (((_e290 - _e291) / _e293) * _e295));
                    let _e301 = radius_4;
                    let _e302 = cameraPos;
                    let _e303 = dir_4;
                    let _e304 = sphereFirstIntersection(vec3(0f), _e301, _e302, _e303);
                    intersection = _e304;
                    let _e305 = intersection;
                    if (_e305.x < 100000000000000000000f) {
                        {
                            let _e309 = intersection;
                            let _e311 = intersection;
                            angle = atan2(_e309.x, _e311.z);
                            let _e316 = angle;
                            x = (_e316 / 3.1415927f);
                            let _e320 = x;
                            let _e322 = blend_1;
                            X = (_e320 * (1f + _e322));
                            let _e326 = x;
                            let _e329 = blend_1;
                            if (abs(_e326) <= (1f - _e329)) {
                                {
                                    let _e332 = x;
                                    let _e334 = blend_1;
                                    let _e337 = ratio;
                                    let _e339 = intersection;
                                    let _e341 = radius_4;
                                    q = vec2<f32>(((_e332 / (1f + _e334)) * _e337), (_e339.y / _e341));
                                    let _e345 = q;
                                    let _e349 = global.U[0];
                                    let _e352 = q;
                                    let _e361 = textureSample(t_source, samp, ((vec2<f32>((_e345.x / _e349.x), _e352.y) / vec2(2f)) + vec2(0.5f)));
                                    sampleCol = _e361;
                                }
                            } else {
                                {
                                    let _e362 = x;
                                    let _e364 = blend_1;
                                    x1_ = (_e362 / (1f + _e364));
                                    let _e368 = x;
                                    let _e372 = x;
                                    let _e375 = blend_1;
                                    let _e379 = blend_1;
                                    x2_ = (sign(_e368) * (-1f + ((abs(_e372) - (1f - _e375)) / (1f + _e379))));
                                    let _e385 = x1_;
                                    let _e386 = ratio;
                                    let _e388 = intersection;
                                    let _e390 = radius_4;
                                    q1_ = vec2<f32>((_e385 * _e386), (_e388.y / _e390));
                                    let _e394 = x2_;
                                    let _e395 = ratio;
                                    let _e397 = intersection;
                                    let _e399 = radius_4;
                                    q2_ = vec2<f32>((_e394 * _e395), (_e397.y / _e399));
                                    let _e404 = x;
                                    let _e407 = blend_1;
                                    let _e411 = blend_1;
                                    k = ((0.5f * (abs(_e404) - (1f - _e407))) / _e411);
                                    let _e414 = q1_;
                                    let _e418 = global.U[0];
                                    let _e421 = q1_;
                                    let _e430 = textureSample(t_source, samp, ((vec2<f32>((_e414.x / _e418.x), _e421.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e431 = q2_;
                                    let _e435 = global.U[0];
                                    let _e438 = q2_;
                                    let _e447 = textureSample(t_source, samp, ((vec2<f32>((_e431.x / _e435.x), _e438.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e448 = k;
                                    sampleCol = mix(_e430, _e447, vec4(_e448));
                                }
                            }
                            let _e451 = radius_4;
                            let _e452 = kernelRadius_1;
                            if (_e451 <= _e452) {
                                {
                                    let _e454 = cameraPos;
                                    let _e455 = intersection;
                                    kFog = length((_e454 - _e455));
                                    let _e458 = sampleCol;
                                    let _e459 = colorKernel_1;
                                    let _e460 = mergeColor(_e458, _e459);
                                    col = _e460;
                                    opacity = 1f;
                                    break;
                                }
                            }
                            let _e462 = sampleCol;
                            let _e464 = luma(_e462.xyz);
                            lum = _e464;
                            let _e466 = layerOffset;
                            let _e467 = i;
                            layerStart = (_e466 * f32(_e467));
                            let _e471 = layerStart;
                            let _e472 = layerSize;
                            layerEnd = (_e471 + _e472);
                            let _e475 = lum;
                            let _e476 = layerStart;
                            let _e478 = lum;
                            let _e479 = layerEnd;
                            if ((_e475 >= _e476) && (_e478 <= _e479)) {
                                {
                                    let _e482 = cameraPos;
                                    let _e483 = intersection;
                                    kFog = length((_e482 - _e483));
                                    let _e486 = sampleCol;
                                    col = _e486;
                                    opacity = 1f;
                                    break;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e286 = i;
                    let _e287 = iterDir;
                    i = (_e286 - _e287);
                }
            }
        }
    }
    let _e488 = opacity;
    let _e491 = N1_;
    let _e492 = iterDir;
    let _e494 = N2_;
    let _e495 = iterDir;
    if ((_e488 != 1f) && ((_e491 * _e492) <= (_e494 * _e495))) {
        {
            let _e499 = N1_;
            i_1 = _e499;
            loop {
                let _e501 = i_1;
                let _e502 = iterDir;
                let _e504 = N2_;
                let _e505 = iterDir;
                if !(((_e501 * _e502) <= (_e504 * _e505))) {
                    break;
                }
                {
                    let _e513 = i_1;
                    let _e514 = mid;
                    let _e516 = N;
                    let _e518 = intensity_1;
                    radius_5 = (1f + (((_e513 - _e514) / _e516) * _e518));
                    let _e524 = radius_5;
                    let _e525 = cameraPos;
                    let _e526 = dir_4;
                    let _e527 = sphereLastIntersection(vec3(0f), _e524, _e525, _e526);
                    intersection = _e527;
                    let _e528 = intersection;
                    if (_e528.x < 100000000000000000000f) {
                        {
                            let _e532 = intersection;
                            let _e534 = intersection;
                            angle_1 = atan2(_e532.x, _e534.z);
                            let _e539 = angle_1;
                            x_1 = (_e539 / 3.1415927f);
                            let _e543 = x_1;
                            let _e545 = blend_1;
                            X_1 = (_e543 * (1f + _e545));
                            let _e549 = x_1;
                            let _e552 = blend_1;
                            if (abs(_e549) <= (1f - _e552)) {
                                {
                                    let _e555 = x_1;
                                    let _e557 = blend_1;
                                    let _e560 = ratio;
                                    let _e562 = intersection;
                                    let _e564 = radius_5;
                                    q_1 = vec2<f32>(((_e555 / (1f + _e557)) * _e560), (_e562.y / _e564));
                                    let _e568 = q_1;
                                    let _e572 = global.U[0];
                                    let _e575 = q_1;
                                    let _e584 = textureSample(t_source, samp, ((vec2<f32>((_e568.x / _e572.x), _e575.y) / vec2(2f)) + vec2(0.5f)));
                                    sampleCol_1 = _e584;
                                }
                            } else {
                                {
                                    let _e585 = x_1;
                                    let _e587 = blend_1;
                                    x1_1 = (_e585 / (1f + _e587));
                                    let _e591 = x_1;
                                    let _e595 = x_1;
                                    let _e598 = blend_1;
                                    let _e602 = blend_1;
                                    x2_1 = (sign(_e591) * (-1f + ((abs(_e595) - (1f - _e598)) / (1f + _e602))));
                                    let _e608 = x1_1;
                                    let _e609 = ratio;
                                    let _e611 = intersection;
                                    let _e613 = radius_5;
                                    q1_1 = vec2<f32>((_e608 * _e609), (_e611.y / _e613));
                                    let _e617 = x2_1;
                                    let _e618 = ratio;
                                    let _e620 = intersection;
                                    let _e622 = radius_5;
                                    q2_1 = vec2<f32>((_e617 * _e618), (_e620.y / _e622));
                                    let _e627 = x_1;
                                    let _e630 = blend_1;
                                    let _e634 = blend_1;
                                    k_1 = ((0.5f * (abs(_e627) - (1f - _e630))) / _e634);
                                    let _e637 = q1_1;
                                    let _e641 = global.U[0];
                                    let _e644 = q1_1;
                                    let _e653 = textureSample(t_source, samp, ((vec2<f32>((_e637.x / _e641.x), _e644.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e654 = q2_1;
                                    let _e658 = global.U[0];
                                    let _e661 = q2_1;
                                    let _e670 = textureSample(t_source, samp, ((vec2<f32>((_e654.x / _e658.x), _e661.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e671 = k_1;
                                    sampleCol_1 = mix(_e653, _e670, vec4(_e671));
                                }
                            }
                            let _e674 = radius_5;
                            let _e675 = kernelRadius_1;
                            if (_e674 <= _e675) {
                                {
                                    let _e677 = cameraPos;
                                    let _e678 = intersection;
                                    kFog = length((_e677 - _e678));
                                    let _e681 = sampleCol_1;
                                    let _e682 = colorKernel_1;
                                    let _e683 = mergeColor(_e681, _e682);
                                    col = _e683;
                                    opacity = 1f;
                                    break;
                                }
                            }
                            let _e685 = sampleCol_1;
                            let _e687 = luma(_e685.xyz);
                            lum_1 = _e687;
                            let _e689 = layerOffset;
                            let _e690 = i_1;
                            layerStart_1 = (_e689 * f32(_e690));
                            let _e694 = layerStart_1;
                            let _e695 = layerSize;
                            layerEnd_1 = (_e694 + _e695);
                            let _e698 = lum_1;
                            let _e699 = layerStart_1;
                            let _e701 = lum_1;
                            let _e702 = layerEnd_1;
                            if ((_e698 >= _e699) && (_e701 <= _e702)) {
                                {
                                    let _e705 = cameraPos;
                                    let _e706 = intersection;
                                    kFog = length((_e705 - _e706));
                                    let _e709 = sampleCol_1;
                                    col = _e709;
                                    opacity = 1f;
                                    break;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e509 = i_1;
                    let _e510 = iterDir;
                    i_1 = (_e509 + _e510);
                }
            }
        }
    }
    let _e711 = colorFog_1;
    if (_e711.w != 0f) {
        {
            let _e717 = colorFog_1;
            nearDist = (2f * (1f - _e717.w));
            let _e723 = nearDist;
            farDist = (2f * _e723);
            let _e726 = nearDist;
            let _e727 = farDist;
            let _e728 = kFog;
            kFog = smoothstep(_e726, _e727, _e728);
            let _e730 = col;
            let _e732 = col;
            let _e734 = colorFog_1;
            let _e736 = kFog;
            let _e738 = mix(_e732.xyz, _e734.xyz, vec3(_e736));
            col.x = _e738.x;
            col.y = _e738.y;
            col.z = _e738.z;
        }
    }
    let _e745 = col;
    return _e745;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e71 = global.U[7];
    let _e75 = global.U[8];
    let _e80 = global.U[9];
    let _e84 = global.U[5];
    let _e89 = global.U[10];
    let _e92 = global.U[11];
    let _e97 = global.U[12];
    let _e101 = global.U[13];
    let _e104 = global.U[14];
    let _e108 = global.U[15];
    let _e111 = global.U[16];
    let _e114 = global.U[17];
    let _e117 = global.U[18];
    let _e139 = sphericalTopography((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.x, i32(_e75.x), _e80.x, i32(_e84.x), _e89, i32(_e92.x), _e97.x, _e101, _e104.x, mat4x4<f32>(vec4<f32>(_e108.x, _e108.y, _e108.z, _e108.w), vec4<f32>(_e111.x, _e111.y, _e111.z, _e111.w), vec4<f32>(_e114.x, _e114.y, _e114.z, _e114.w), vec4<f32>(_e117.x, _e117.y, _e117.z, _e117.w)));
    fragColor = _e139;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
