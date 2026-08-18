struct Params {
    U: array<vec4<f32>, 13>,
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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn solve2ndDegreePolynomial(a: f32, b: f32, c_2: f32) -> vec2<f32> {
    var a_1: f32;
    var b_1: f32;
    var c_3: f32;
    var delta: f32;
    var sqrtDelta: f32;
    var l1_: f32;
    var l2_: f32;

    a_1 = a;
    b_1 = b;
    c_3 = c_2;
    let _e12 = b_1;
    let _e13 = b_1;
    let _e16 = a_1;
    let _e18 = c_3;
    delta = ((_e12 * _e13) - ((4f * _e16) * _e18));
    let _e22 = delta;
    if (_e22 >= 0f) {
        {
            let _e25 = delta;
            sqrtDelta = sqrt(_e25);
            let _e28 = b_1;
            let _e30 = sqrtDelta;
            let _e33 = a_1;
            l1_ = ((-(_e28) - _e30) / (2f * _e33));
            let _e37 = b_1;
            let _e39 = sqrtDelta;
            let _e42 = a_1;
            l2_ = ((-(_e37) + _e39) / (2f * _e42));
            let _e46 = l1_;
            let _e47 = l2_;
            let _e49 = l1_;
            let _e50 = l2_;
            return vec2<f32>(min(_e46, _e47), max(_e49, _e50));
        }
    }
    return vec2<f32>(100000000000000000000f, 100000000000000000000f);
}

fn cylinderIntersectionK(radius: f32, origin: vec3<f32>, dir: vec3<f32>) -> vec2<f32> {
    var radius_1: f32;
    var origin_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var a_2: f32;
    var b_2: f32;
    var c_4: f32;
    var k: vec2<f32>;
    var local: f32;
    var local_1: f32;

    radius_1 = radius;
    origin_1 = origin;
    dir_1 = dir;
    let _e12 = dir_1;
    let _e14 = dir_1;
    a_2 = dot(_e12.xy, _e14.xy);
    let _e19 = dir_1;
    let _e21 = origin_1;
    b_2 = (2f * dot(_e19.xy, _e21.xy));
    let _e26 = origin_1;
    let _e28 = origin_1;
    let _e31 = radius_1;
    let _e32 = radius_1;
    c_4 = (dot(_e26.xy, _e28.xy) - (_e31 * _e32));
    let _e36 = a_2;
    let _e37 = b_2;
    let _e38 = c_4;
    let _e39 = solve2ndDegreePolynomial(_e36, _e37, _e38);
    k = _e39;
    let _e41 = k;
    if (_e41.x < 0f) {
        local = 100000000000000000000f;
    } else {
        let _e46 = k;
        local = _e46.x;
    }
    let _e49 = local;
    let _e50 = k;
    if (_e50.y < 0f) {
        local_1 = 100000000000000000000f;
    } else {
        let _e55 = k;
        local_1 = _e55.y;
    }
    let _e58 = local_1;
    return vec2<f32>(_e49, _e58);
}

fn getBackground(dir_2: vec3<f32>) -> vec4<f32> {
    var dir_3: vec3<f32>;

    dir_3 = dir_2;
    return vec4<f32>(0f, 0f, 0f, 1f);
}

fn planeIntersection(planePoint: vec3<f32>, normal: vec3<f32>, origin_2: vec3<f32>, dir_4: vec3<f32>) -> vec3<f32> {
    var planePoint_1: vec3<f32>;
    var normal_1: vec3<f32>;
    var origin_3: vec3<f32>;
    var dir_5: vec3<f32>;
    var relPlane: vec3<f32>;
    var div: f32;
    var k_1: f32;
    var local_2: vec3<f32>;

    planePoint_1 = planePoint;
    normal_1 = normal;
    origin_3 = origin_2;
    dir_5 = dir_4;
    let _e14 = planePoint_1;
    let _e15 = origin_3;
    relPlane = (_e14 - _e15);
    let _e18 = dir_5;
    let _e19 = normal_1;
    div = dot(_e18, _e19);
    let _e22 = div;
    if (_e22 == 0f) {
        return vec3(100000000000000000000f);
    }
    let _e27 = relPlane;
    let _e28 = normal_1;
    let _e30 = div;
    k_1 = (dot(_e27, _e28) / _e30);
    let _e33 = k_1;
    if (_e33 > 0f) {
        let _e36 = origin_3;
        let _e37 = dir_5;
        let _e38 = k_1;
        local_2 = (_e36 + (_e37 * _e38));
    } else {
        local_2 = vec3(100000000000000000000f);
    }
    let _e44 = local_2;
    return _e44;
}

fn planeIntersectionK(planePoint_2: vec3<f32>, normal_2: vec3<f32>, origin_4: vec3<f32>, dir_6: vec3<f32>) -> f32 {
    var planePoint_3: vec3<f32>;
    var normal_3: vec3<f32>;
    var origin_5: vec3<f32>;
    var dir_7: vec3<f32>;
    var relPlane_1: vec3<f32>;
    var div_1: f32;
    var k_2: f32;
    var local_3: f32;

    planePoint_3 = planePoint_2;
    normal_3 = normal_2;
    origin_5 = origin_4;
    dir_7 = dir_6;
    let _e14 = planePoint_3;
    let _e15 = origin_5;
    relPlane_1 = (_e14 - _e15);
    let _e18 = dir_7;
    let _e19 = normal_3;
    div_1 = dot(_e18, _e19);
    let _e22 = div_1;
    if (_e22 == 0f) {
        return 100000000000000000000f;
    }
    let _e26 = relPlane_1;
    let _e27 = normal_3;
    let _e29 = div_1;
    k_2 = (dot(_e26, _e27) / _e29);
    let _e32 = k_2;
    if (_e32 > 0f) {
        let _e35 = k_2;
        local_3 = _e35;
    } else {
        local_3 = 100000000000000000000f;
    }
    let _e38 = local_3;
    return _e38;
}

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local_4: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local_4 = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local_4 = max(_e25.x, _e27.y);
    }
    let _e31 = local_4;
    return _e31;
}

fn wallpaper(pos: vec2<f32>, outPos: vec2<f32>, radius_2: f32, mode: i32, lighting: f32, model3DTransform: mat4x4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_3: f32;
    var mode_1: i32;
    var lighting_1: f32;
    var model3DTransform_1: mat4x4<f32>;
    var sourceDim_1: vec2<f32>;
    var backgroundColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var D: f32 = 1f;
    var cameraPos: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var m: mat4x4<f32>;
    var dir_8: vec3<f32>;
    var col: vec4<f32>;
    var clip: bool;
    var ratio: f32;
    var z: f32 = 0f;
    var Y: f32 = 0.5f;
    var kz: f32;
    var ky: f32;
    var cylCenter: vec2<f32>;
    var kc: vec2<f32>;
    var bestK: f32 = 100000000000000000000f;
    var uv: vec3<f32>;
    var angle: f32;
    var y: f32;
    var uv_1: vec3<f32>;
    var angle_1: f32;
    var y_1: f32;
    var uv_2: vec3<f32>;
    var uv_3: vec3<f32>;
    var intersection: vec3<f32>;
    var normal_4: vec3<f32> = vec3<f32>(0f, 0f, 1f);
    var lightPos: vec3<f32> = vec3<f32>(-10000f, 20000f, 40000f);
    var lightToIntersection: vec3<f32>;
    var illum: f32;
    var k_3: f32;
    var specular: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    radius_3 = radius_2;
    mode_1 = mode;
    lighting_1 = lighting;
    model3DTransform_1 = model3DTransform;
    sourceDim_1 = sourceDim;
    let _e33 = model3DTransform_1;
    m = _naga_inverse_4x4_f32(_e33);
    let _e36 = m;
    let _e37 = cameraPos;
    cameraPos = (_e36 * vec4<f32>(_e37.x, _e37.y, _e37.z, 1f)).xyz;
    let _e45 = pos_1;
    let _e47 = D;
    let _e49 = pos_1;
    let _e51 = D;
    dir_8 = normalize(vec3<f32>((_e45.x * _e47), (_e49.y * _e51), -1f));
    let _e58 = m;
    let _e68 = dir_8;
    dir_8 = (mat3x3<f32>(_e58[0].xyz, _e58[1].xyz, _e58[2].xyz) * _e68);
    let _e70 = dir_8;
    let _e71 = getBackground(_e70);
    col = _e71;
    let _e73 = dir_8;
    if (_e73.z == 0f) {
        let _e77 = col;
        return _e77;
    }
    let _e78 = mode_1;
    clip = (_e78 == 0i);
    let _e82 = sourceDim_1;
    let _e84 = sourceDim_1;
    ratio = (_e82.x / _e84.y);
    let _e98 = cameraPos;
    let _e99 = dir_8;
    let _e100 = planeIntersectionK(vec3(0f), vec3<f32>(0f, 0f, 1f), _e98, _e99);
    kz = _e100;
    let _e103 = Y;
    let _e110 = cameraPos;
    let _e111 = dir_8;
    let _e112 = planeIntersectionK(vec3<f32>(0f, _e103, 0f), vec3<f32>(0f, 1f, 0f), _e110, _e111);
    ky = _e112;
    let _e114 = radius_3;
    let _e115 = Y;
    let _e116 = radius_3;
    cylCenter = vec2<f32>(_e114, (_e115 - _e116));
    let _e120 = radius_3;
    let _e121 = cameraPos;
    let _e123 = cylCenter;
    let _e129 = dir_8;
    let _e131 = cylinderIntersectionK(_e120, (_e121.zyx - vec3<f32>(_e123.x, _e123.y, 0f)), _e129.zyx);
    kc = _e131;
    let _e135 = kc;
    let _e137 = bestK;
    if (_e135.x < _e137) {
        {
            let _e139 = cameraPos;
            let _e140 = kc;
            let _e142 = dir_8;
            uv = (_e139 + (_e140.x * _e142));
            let _e146 = uv;
            let _e148 = radius_3;
            let _e150 = uv;
            let _e152 = Y;
            let _e153 = radius_3;
            if ((_e146.z < _e148) && (_e150.y > (_e152 - _e153))) {
                {
                    let _e157 = uv;
                    let _e159 = Y;
                    let _e161 = radius_3;
                    let _e163 = radius_3;
                    let _e164 = uv;
                    angle = atan2(((_e157.y - _e159) + _e161), (_e163 - _e164.z));
                    let _e169 = Y;
                    let _e170 = radius_3;
                    let _e171 = angle;
                    y = (_e169 + (_e170 * (_e171 - 1f)));
                    let _e177 = uv;
                    let _e179 = y;
                    let _e184 = global.U[0];
                    let _e187 = uv;
                    let _e189 = y;
                    let _e199 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e177.x, _e179).x / _e184.x), vec2<f32>(_e187.x, _e189).y) / vec2(2f)) + vec2(0.5f)));
                    let _e201 = textureSampleLevel(t_source, samp, _e199, 0f);
                    col = _e201;
                    let _e202 = kc;
                    bestK = _e202.x;
                }
            }
        }
    }
    let _e204 = kc;
    let _e206 = bestK;
    if (_e204.y < _e206) {
        {
            let _e208 = cameraPos;
            let _e209 = kc;
            let _e211 = dir_8;
            uv_1 = (_e208 + (_e209.y * _e211));
            let _e215 = uv_1;
            let _e217 = radius_3;
            let _e219 = uv_1;
            let _e221 = Y;
            let _e222 = radius_3;
            if ((_e215.z < _e217) && (_e219.y > (_e221 - _e222))) {
                {
                    let _e226 = uv_1;
                    let _e228 = Y;
                    let _e230 = radius_3;
                    let _e232 = radius_3;
                    let _e233 = uv_1;
                    angle_1 = atan2(((_e226.y - _e228) + _e230), (_e232 - _e233.z));
                    let _e238 = Y;
                    let _e239 = radius_3;
                    let _e240 = angle_1;
                    y_1 = (_e238 + (_e239 * (_e240 - 1f)));
                    let _e246 = uv_1;
                    let _e248 = y_1;
                    let _e253 = global.U[0];
                    let _e256 = uv_1;
                    let _e258 = y_1;
                    let _e268 = _mirror_wrap(((vec2<f32>((vec2<f32>(_e246.x, _e248).x / _e253.x), vec2<f32>(_e256.x, _e258).y) / vec2(2f)) + vec2(0.5f)));
                    let _e270 = textureSampleLevel(t_source, samp, _e268, 0f);
                    col = _e270;
                    let _e271 = kc;
                    bestK = _e271.y;
                }
            }
        }
    }
    let _e273 = ky;
    let _e274 = bestK;
    if (_e273 < _e274) {
        {
            let _e276 = cameraPos;
            let _e277 = ky;
            let _e278 = dir_8;
            uv_2 = (_e276 + (_e277 * _e278));
            let _e282 = uv_2;
            let _e284 = radius_3;
            if (_e282.z >= _e284) {
                {
                    let _e286 = uv_2;
                    let _e289 = Y;
                    let _e290 = radius_3;
                    let _e301 = global.U[0];
                    let _e304 = uv_2;
                    let _e307 = Y;
                    let _e308 = radius_3;
                    let _e324 = _mirror_wrap(((vec2<f32>(((_e286.xz + vec2<f32>(0f, (_e289 + (_e290 * -0.42920363f)))).x / _e301.x), (_e304.xz + vec2<f32>(0f, (_e307 + (_e308 * -0.42920363f)))).y) / vec2(2f)) + vec2(0.5f)));
                    let _e326 = textureSampleLevel(t_source, samp, _e324, 0f);
                    col = _e326;
                    let _e327 = ky;
                    bestK = _e327;
                }
            }
        }
    }
    let _e328 = kz;
    let _e329 = bestK;
    if (_e328 < _e329) {
        {
            let _e331 = cameraPos;
            let _e332 = kz;
            let _e333 = dir_8;
            uv_3 = (_e331 + (_e332 * _e333));
            let _e337 = uv_3;
            let _e339 = Y;
            let _e340 = radius_3;
            if (_e337.y <= (_e339 - _e340)) {
                {
                    let _e343 = uv_3;
                    let _e348 = global.U[0];
                    let _e351 = uv_3;
                    let _e361 = _mirror_wrap(((vec2<f32>((_e343.x / _e348.x), _e351.y) / vec2(2f)) + vec2(0.5f)));
                    let _e363 = textureSampleLevel(t_source, samp, _e361, 0f);
                    col = _e363;
                    let _e364 = kz;
                    bestK = _e364;
                }
            }
        }
    }
    let _e365 = lighting_1;
    if (_e365 > 0f) {
        {
            let _e368 = cameraPos;
            let _e369 = bestK;
            let _e370 = dir_8;
            intersection = (_e368 + (_e369 * _e370));
            let _e379 = intersection;
            let _e381 = radius_3;
            if (_e379.z >= _e381) {
                normal_4 = vec3<f32>(0f, -1f, 0f);
            } else {
                let _e388 = intersection;
                if (abs(_e388.z) > 0.0001f) {
                    let _e394 = cylCenter;
                    let _e396 = intersection;
                    let _e399 = cylCenter;
                    let _e401 = intersection;
                    normal_4 = normalize(vec3<f32>(0f, (_e394.y - _e396.y), (_e399.x - _e401.z)));
                }
            }
            let _e412 = intersection;
            let _e413 = lightPos;
            lightToIntersection = normalize((_e412 - _e413));
            let _e417 = lightToIntersection;
            let _e419 = normal_4;
            illum = dot(-(_e417), _e419);
            let _e426 = illum;
            let _e431 = lighting_1;
            k_3 = mix(1f, (0.7f + (0.3f * max(0f, _e426))), min(1f, (_e431 * 2f)));
            let _e437 = col;
            let _e439 = col;
            let _e441 = k_3;
            let _e442 = (_e439.xyz * _e441);
            col.x = _e442.x;
            col.y = _e442.y;
            col.z = _e442.z;
            let _e450 = lightToIntersection;
            let _e452 = normal_4;
            let _e454 = cameraPos;
            let _e455 = intersection;
            specular = pow(max(0f, dot(reflect(-(_e450), _e452), normalize((_e454 - _e455)))), 5f);
            let _e463 = col;
            let _e465 = col;
            let _e468 = specular;
            let _e470 = lighting_1;
            let _e478 = (_e465.xyz + vec3(mix(0f, _e468, max(0f, ((_e470 * 2f) - 1f)))));
            col.x = _e478.x;
            col.y = _e478.y;
            col.z = _e478.z;
        }
    }
    let _e485 = col;
    return _e485;
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
    let _e70 = global.U[7];
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e82 = global.U[10];
    let _e85 = global.U[11];
    let _e88 = global.U[12];
    let _e112 = global.U[4];
    let _e114 = wallpaper((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, mat4x4<f32>(vec4<f32>(_e79.x, _e79.y, _e79.z, _e79.w), vec4<f32>(_e82.x, _e82.y, _e82.z, _e82.w), vec4<f32>(_e85.x, _e85.y, _e85.z, _e85.w), vec4<f32>(_e88.x, _e88.y, _e88.z, _e88.w)), _e112.xy);
    fragColor = _e114;
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
