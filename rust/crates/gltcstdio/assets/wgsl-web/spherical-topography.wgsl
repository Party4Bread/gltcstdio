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
            let _e136 = textureSampleLevel(t_sourceBkg, samp, ((vec2<f32>((_e119.x / _e123.x), _e126.y) / vec2(2f)) + vec2(0.5f)), 0f);
            local = _e136;
        } else {
            local = vec4<f32>(0f, 0f, 0f, 1f);
        }
        let _e143 = local;
        local_1 = _e143;
    }
    let _e145 = local_1;
    col = _e145;
    let _e147 = dir_4;
    if (_e147.z == 0f) {
        let _e151 = col;
        return _e151;
    }
    let _e152 = count_1;
    N = f32(_e152);
    let _e156 = overlap_1;
    let _e157 = N;
    let _e162 = N;
    layerSize = ((1f + (_e156 * (_e157 - 1f))) / _e162);
    let _e166 = layerSize;
    let _e169 = N;
    layerOffset = ((1f - _e166) / max(1f, (_e169 - 1f)));
    let _e175 = N;
    mid = ((_e175 - 1f) * 0.5f);
    let _e181 = mode_1;
    if (_e181 == 2i) {
        let _e184 = intensity_1;
        intensity_1 = -(_e184);
    }
    let _e186 = cameraPos;
    let _e187 = dir_4;
    let _e188 = cameraPos;
    let _e191 = dir_4;
    normalPoint = (_e186 + (dot(_e187, -(_e188)) * _e191));
    let _e195 = normalPoint;
    let _e196 = cameraPos;
    let _e198 = dir_4;
    kNormal = dot((_e195 - _e196), _e198);
    let _e201 = cameraPos;
    let _e205 = N;
    let _e207 = intensity_1;
    let _e209 = mid;
    startLayer = ((((length(_e201) - 1f) * _e205) / _e207) + _e209);
    let _e212 = normalPoint;
    let _e216 = N;
    let _e218 = intensity_1;
    let _e220 = mid;
    normalLayer = ((((length(_e212) - 1f) * _e216) / _e218) + _e220);
    let _e223 = mode_1;
    if (_e223 == 2i) {
        local_2 = -1f;
    } else {
        local_2 = 1f;
    }
    let _e230 = local_2;
    let _e231 = intensity_1;
    if (_e231 >= 0f) {
        local_3 = 1f;
    } else {
        local_3 = -1f;
    }
    let _e238 = local_3;
    iterDir = (_e230 * _e238);
    let _e241 = startLayer;
    let _e244 = N;
    N0_ = clamp(ceil(_e241), 0f, (_e244 - 1f));
    let _e249 = normalLayer;
    let _e252 = N;
    N1_ = clamp(floor(_e249), 0f, (_e252 - 1f));
    let _e257 = iterDir;
    if (_e257 >= 0f) {
        let _e260 = N;
        local_4 = (_e260 - 1f);
    } else {
        local_4 = 0f;
    }
    let _e265 = local_4;
    N2_ = _e265;
    let _e270 = N0_;
    let _e271 = iterDir;
    let _e273 = N1_;
    let _e274 = iterDir;
    if ((_e270 * _e271) >= (_e273 * _e274)) {
        {
            let _e277 = N0_;
            i = _e277;
            loop {
                let _e279 = i;
                let _e280 = iterDir;
                let _e282 = N1_;
                let _e283 = iterDir;
                if !(((_e279 * _e280) >= (_e282 * _e283))) {
                    break;
                }
                {
                    let _e291 = i;
                    let _e292 = mid;
                    let _e294 = N;
                    let _e296 = intensity_1;
                    radius_4 = (1f + (((_e291 - _e292) / _e294) * _e296));
                    let _e302 = radius_4;
                    let _e303 = cameraPos;
                    let _e304 = dir_4;
                    let _e305 = sphereFirstIntersection(vec3(0f), _e302, _e303, _e304);
                    intersection = _e305;
                    let _e306 = intersection;
                    if (_e306.x < 100000000000000000000f) {
                        {
                            let _e310 = intersection;
                            let _e312 = intersection;
                            angle = atan2(_e310.x, _e312.z);
                            let _e317 = angle;
                            x = (_e317 / 3.1415927f);
                            let _e321 = x;
                            let _e323 = blend_1;
                            X = (_e321 * (1f + _e323));
                            let _e327 = x;
                            let _e330 = blend_1;
                            if (abs(_e327) <= (1f - _e330)) {
                                {
                                    let _e333 = x;
                                    let _e335 = blend_1;
                                    let _e338 = ratio;
                                    let _e340 = intersection;
                                    let _e342 = radius_4;
                                    q = vec2<f32>(((_e333 / (1f + _e335)) * _e338), (_e340.y / _e342));
                                    let _e346 = q;
                                    let _e350 = global.U[0];
                                    let _e353 = q;
                                    let _e363 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e346.x / _e350.x), _e353.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    sampleCol = _e363;
                                }
                            } else {
                                {
                                    let _e364 = x;
                                    let _e366 = blend_1;
                                    x1_ = (_e364 / (1f + _e366));
                                    let _e370 = x;
                                    let _e374 = x;
                                    let _e377 = blend_1;
                                    let _e381 = blend_1;
                                    x2_ = (sign(_e370) * (-1f + ((abs(_e374) - (1f - _e377)) / (1f + _e381))));
                                    let _e387 = x1_;
                                    let _e388 = ratio;
                                    let _e390 = intersection;
                                    let _e392 = radius_4;
                                    q1_ = vec2<f32>((_e387 * _e388), (_e390.y / _e392));
                                    let _e396 = x2_;
                                    let _e397 = ratio;
                                    let _e399 = intersection;
                                    let _e401 = radius_4;
                                    q2_ = vec2<f32>((_e396 * _e397), (_e399.y / _e401));
                                    let _e406 = x;
                                    let _e409 = blend_1;
                                    let _e413 = blend_1;
                                    k = ((0.5f * (abs(_e406) - (1f - _e409))) / _e413);
                                    let _e416 = q1_;
                                    let _e420 = global.U[0];
                                    let _e423 = q1_;
                                    let _e433 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e416.x / _e420.x), _e423.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e434 = q2_;
                                    let _e438 = global.U[0];
                                    let _e441 = q2_;
                                    let _e451 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e434.x / _e438.x), _e441.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e452 = k;
                                    sampleCol = mix(_e433, _e451, vec4(_e452));
                                }
                            }
                            let _e455 = radius_4;
                            let _e456 = kernelRadius_1;
                            if (_e455 <= _e456) {
                                {
                                    let _e458 = cameraPos;
                                    let _e459 = intersection;
                                    kFog = length((_e458 - _e459));
                                    let _e462 = sampleCol;
                                    let _e463 = colorKernel_1;
                                    let _e464 = mergeColor(_e462, _e463);
                                    col = _e464;
                                    opacity = 1f;
                                    break;
                                }
                            }
                            let _e466 = sampleCol;
                            let _e468 = luma(_e466.xyz);
                            lum = _e468;
                            let _e470 = layerOffset;
                            let _e471 = i;
                            layerStart = (_e470 * f32(_e471));
                            let _e475 = layerStart;
                            let _e476 = layerSize;
                            layerEnd = (_e475 + _e476);
                            let _e479 = lum;
                            let _e480 = layerStart;
                            let _e482 = lum;
                            let _e483 = layerEnd;
                            if ((_e479 >= _e480) && (_e482 <= _e483)) {
                                {
                                    let _e486 = cameraPos;
                                    let _e487 = intersection;
                                    kFog = length((_e486 - _e487));
                                    let _e490 = sampleCol;
                                    col = _e490;
                                    opacity = 1f;
                                    break;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e287 = i;
                    let _e288 = iterDir;
                    i = (_e287 - _e288);
                }
            }
        }
    }
    let _e492 = opacity;
    let _e495 = N1_;
    let _e496 = iterDir;
    let _e498 = N2_;
    let _e499 = iterDir;
    if ((_e492 != 1f) && ((_e495 * _e496) <= (_e498 * _e499))) {
        {
            let _e503 = N1_;
            i_1 = _e503;
            loop {
                let _e505 = i_1;
                let _e506 = iterDir;
                let _e508 = N2_;
                let _e509 = iterDir;
                if !(((_e505 * _e506) <= (_e508 * _e509))) {
                    break;
                }
                {
                    let _e517 = i_1;
                    let _e518 = mid;
                    let _e520 = N;
                    let _e522 = intensity_1;
                    radius_5 = (1f + (((_e517 - _e518) / _e520) * _e522));
                    let _e528 = radius_5;
                    let _e529 = cameraPos;
                    let _e530 = dir_4;
                    let _e531 = sphereLastIntersection(vec3(0f), _e528, _e529, _e530);
                    intersection = _e531;
                    let _e532 = intersection;
                    if (_e532.x < 100000000000000000000f) {
                        {
                            let _e536 = intersection;
                            let _e538 = intersection;
                            angle_1 = atan2(_e536.x, _e538.z);
                            let _e543 = angle_1;
                            x_1 = (_e543 / 3.1415927f);
                            let _e547 = x_1;
                            let _e549 = blend_1;
                            X_1 = (_e547 * (1f + _e549));
                            let _e553 = x_1;
                            let _e556 = blend_1;
                            if (abs(_e553) <= (1f - _e556)) {
                                {
                                    let _e559 = x_1;
                                    let _e561 = blend_1;
                                    let _e564 = ratio;
                                    let _e566 = intersection;
                                    let _e568 = radius_5;
                                    q_1 = vec2<f32>(((_e559 / (1f + _e561)) * _e564), (_e566.y / _e568));
                                    let _e572 = q_1;
                                    let _e576 = global.U[0];
                                    let _e579 = q_1;
                                    let _e589 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e572.x / _e576.x), _e579.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    sampleCol_1 = _e589;
                                }
                            } else {
                                {
                                    let _e590 = x_1;
                                    let _e592 = blend_1;
                                    x1_1 = (_e590 / (1f + _e592));
                                    let _e596 = x_1;
                                    let _e600 = x_1;
                                    let _e603 = blend_1;
                                    let _e607 = blend_1;
                                    x2_1 = (sign(_e596) * (-1f + ((abs(_e600) - (1f - _e603)) / (1f + _e607))));
                                    let _e613 = x1_1;
                                    let _e614 = ratio;
                                    let _e616 = intersection;
                                    let _e618 = radius_5;
                                    q1_1 = vec2<f32>((_e613 * _e614), (_e616.y / _e618));
                                    let _e622 = x2_1;
                                    let _e623 = ratio;
                                    let _e625 = intersection;
                                    let _e627 = radius_5;
                                    q2_1 = vec2<f32>((_e622 * _e623), (_e625.y / _e627));
                                    let _e632 = x_1;
                                    let _e635 = blend_1;
                                    let _e639 = blend_1;
                                    k_1 = ((0.5f * (abs(_e632) - (1f - _e635))) / _e639);
                                    let _e642 = q1_1;
                                    let _e646 = global.U[0];
                                    let _e649 = q1_1;
                                    let _e659 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e642.x / _e646.x), _e649.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e660 = q2_1;
                                    let _e664 = global.U[0];
                                    let _e667 = q2_1;
                                    let _e677 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e660.x / _e664.x), _e667.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e678 = k_1;
                                    sampleCol_1 = mix(_e659, _e677, vec4(_e678));
                                }
                            }
                            let _e681 = radius_5;
                            let _e682 = kernelRadius_1;
                            if (_e681 <= _e682) {
                                {
                                    let _e684 = cameraPos;
                                    let _e685 = intersection;
                                    kFog = length((_e684 - _e685));
                                    let _e688 = sampleCol_1;
                                    let _e689 = colorKernel_1;
                                    let _e690 = mergeColor(_e688, _e689);
                                    col = _e690;
                                    opacity = 1f;
                                    break;
                                }
                            }
                            let _e692 = sampleCol_1;
                            let _e694 = luma(_e692.xyz);
                            lum_1 = _e694;
                            let _e696 = layerOffset;
                            let _e697 = i_1;
                            layerStart_1 = (_e696 * f32(_e697));
                            let _e701 = layerStart_1;
                            let _e702 = layerSize;
                            layerEnd_1 = (_e701 + _e702);
                            let _e705 = lum_1;
                            let _e706 = layerStart_1;
                            let _e708 = lum_1;
                            let _e709 = layerEnd_1;
                            if ((_e705 >= _e706) && (_e708 <= _e709)) {
                                {
                                    let _e712 = cameraPos;
                                    let _e713 = intersection;
                                    kFog = length((_e712 - _e713));
                                    let _e716 = sampleCol_1;
                                    col = _e716;
                                    opacity = 1f;
                                    break;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e513 = i_1;
                    let _e514 = iterDir;
                    i_1 = (_e513 + _e514);
                }
            }
        }
    }
    let _e718 = colorFog_1;
    if (_e718.w != 0f) {
        {
            let _e724 = colorFog_1;
            nearDist = (2f * (1f - _e724.w));
            let _e730 = nearDist;
            farDist = (2f * _e730);
            let _e733 = nearDist;
            let _e734 = farDist;
            let _e735 = kFog;
            kFog = smoothstep(_e733, _e734, _e735);
            let _e737 = col;
            let _e739 = col;
            let _e741 = colorFog_1;
            let _e743 = kFog;
            let _e745 = mix(_e739.xyz, _e741.xyz, vec3(_e743));
            col.x = _e745.x;
            col.y = _e745.y;
            col.z = _e745.z;
        }
    }
    let _e752 = col;
    return _e752;
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
