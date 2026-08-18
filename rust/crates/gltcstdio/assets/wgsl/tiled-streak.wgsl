struct Params {
    U: array<vec4<f32>, 14>,
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

fn rnd2_(u: vec2<f32>, seed: f32, regularity: f32) -> f32 {
    var u_1: vec2<f32>;
    var seed_1: f32;
    var regularity_1: f32;
    var a: f32;
    var b: f32;
    var r1_: f32;
    var R1_: f32;
    var R2_: f32;
    var R3_: f32;
    var R4_: f32;
    var a2_: f32;
    var b2_: f32;
    var r2_: f32;
    var local: f32;

    u_1 = u;
    seed_1 = seed;
    regularity_1 = regularity;
    let _e13 = u_1;
    let _e14 = u_1;
    let _e21 = seed_1;
    a = (5f * fract((dot(_e13, (_e14.yx + vec2<f32>(10.32777f, 13.1123f))) + (_e21 * 0.977f))));
    let _e29 = a;
    let _e30 = u_1;
    let _e33 = u_1;
    let _e36 = u_1;
    b = (5f * fract(dot(vec2<f32>((_e29 * _e30.y), _e33.x), (-(_e36.xy) + vec2(0.55555f)))));
    let _e47 = a;
    let _e49 = b;
    let _e51 = u_1;
    let _e52 = u_1;
    r1_ = fract((((10.1545f * _e47) * _e49) - dot(_e51, _e52)));
    let _e57 = seed_1;
    R1_ = (floor((fract(((_e57 * 1.1f) + 0.51f)) * 4f)) / 4f);
    let _e69 = seed_1;
    R2_ = (floor((fract((_e69 * 4.3f)) * 4f)) / 4f);
    let _e79 = seed_1;
    R3_ = (floor((fract((_e79 * 23.4f)) * 4f)) / 4f);
    let _e89 = seed_1;
    R4_ = (floor((fract((_e89 * 71.7f)) * 4f)) / 4f);
    let _e100 = R4_;
    let _e102 = u_1;
    let _e103 = u_1;
    let _e106 = R1_;
    let _e109 = R2_;
    a2_ = ((5f + _e100) * fract(dot(_e102, (_e103.yx + vec2<f32>((5f + _e106), (4f + _e109))))));
    let _e118 = a2_;
    let _e119 = u_1;
    let _e122 = u_1;
    let _e125 = u_1;
    let _e131 = R3_;
    b2_ = (5f * fract(dot(vec2<f32>((_e118 * _e119.y), _e122.x), ((-(_e125.xy) + vec2(0.5f)) + vec2((_e131 / 2f))))));
    let _e141 = a2_;
    let _e143 = b2_;
    let _e145 = u_1;
    let _e146 = u_1;
    r2_ = fract((((10.5f * _e141) * _e143) - dot(_e145, _e146)));
    let _e151 = seed_1;
    let _e152 = u_1;
    let _e157 = u_1;
    let _e163 = regularity_1;
    if (fract(((_e151 + (_e152.x * 1.2337f)) + (_e157.y * 3.23323f))) > _e163) {
        let _e165 = r1_;
        local = _e165;
    } else {
        let _e166 = r2_;
        local = _e166;
    }
    let _e168 = local;
    return _e168;
}

fn rnd2dir(u_2: vec2<f32>, dir: vec2<f32>, seed_2: f32, regularity_2: f32) -> f32 {
    var u_3: vec2<f32>;
    var dir_1: vec2<f32>;
    var seed_3: f32;
    var regularity_3: f32;

    u_3 = u_2;
    dir_1 = dir;
    seed_3 = seed_2;
    regularity_3 = regularity_2;
    let _e15 = u_3;
    let _e20 = dir_1;
    let _e22 = seed_3;
    let _e23 = regularity_3;
    let _e24 = rnd2_((((2f * _e15) + vec2(1f)) + _e20), _e22, _e23);
    return _e24;
}

fn getDir(u_4: vec2<f32>, dir_2: vec2<f32>, seed_4: f32, regularity_4: f32) -> bool {
    var u_5: vec2<f32>;
    var dir_3: vec2<f32>;
    var seed_5: f32;
    var regularity_5: f32;

    u_5 = u_4;
    dir_3 = dir_2;
    seed_5 = seed_4;
    regularity_5 = regularity_4;
    let _e14 = u_5;
    let _e15 = dir_3;
    let _e16 = seed_5;
    let _e17 = regularity_5;
    let _e18 = rnd2dir(_e14, _e15, _e16, _e17);
    return (_e18 < 0.5f);
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed_6: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_7: f32;

    co_1 = co;
    seed_7 = seed_6;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_7;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn tiledStreak(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, balance: f32, variability: f32, borderColor: vec4<f32>, thickness: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var balance_1: f32;
    var variability_1: f32;
    var borderColor_1: vec4<f32>;
    var thickness_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var regularity_6: f32;
    var u_8: vec2<f32>;
    var c_2: vec2<f32>;
    var f: vec2<f32>;
    var cell: vec2<f32>;
    var k_4: f32;
    var d: f32;
    var onBorder: bool;
    var dirBottom: bool;
    var dirTop: bool;
    var dirLeft: bool;
    var dirRight: bool;
    var delta: vec2<f32> = vec2<f32>(0.3f, 0f);
    var dir_4: vec2<f32>;
    var v_2: vec2<f32>;
    var col: vec4<f32> = vec4<f32>(0f, 1f, 0f, 1f);
    var X: f32;
    var Y: f32;
    var X_1: f32;
    var Y_1: f32;
    var center: vec2<f32>;
    var rel: vec2<f32>;
    var len: f32;
    var a_1: f32;
    var center_1: vec2<f32>;
    var rel_1: vec2<f32>;
    var len_1: f32;
    var a_2: f32;
    var X_2: f32;
    var Y_2: f32;
    var center_2: vec2<f32>;
    var rel_2: vec2<f32>;
    var len_2: f32;
    var a_3: f32;
    var center_3: vec2<f32>;
    var rel_3: vec2<f32>;
    var len_3: f32;
    var a_4: f32;
    var center_4: vec2<f32>;
    var rel_4: vec2<f32>;
    var len_4: f32;
    var a_5: f32;
    var center_5: vec2<f32>;
    var rel_5: vec2<f32>;
    var len_5: f32;
    var a_6: f32;
    var center_6: vec2<f32>;
    var rel_6: vec2<f32>;
    var len_6: f32;
    var a_7: f32;
    var center_7: vec2<f32>;
    var rel_7: vec2<f32>;
    var len_7: f32;
    var a_8: f32;
    var center_8: vec2<f32>;
    var rel_8: vec2<f32>;
    var len_8: f32;
    var a_9: f32;
    var center_9: vec2<f32>;
    var rel_9: vec2<f32>;
    var len_9: f32;
    var a_10: f32;
    var Y_3: f32;
    var X_3: f32;
    var Y_4: f32;
    var X_4: f32;
    var col1_: vec4<f32>;
    var col2_: vec4<f32>;
    var col3_: vec4<f32>;
    var col4_: vec4<f32>;
    var center_10: vec2<f32>;
    var rel_10: vec2<f32>;
    var len_10: f32;
    var a_11: f32;
    var center_11: vec2<f32>;
    var rel_11: vec2<f32>;
    var len_11: f32;
    var a_12: f32;
    var center_12: vec2<f32>;
    var rel_12: vec2<f32>;
    var len_12: f32;
    var a_13: f32;
    var center_13: vec2<f32>;
    var rel_13: vec2<f32>;
    var len_13: f32;
    var a_14: f32;
    var cols: mat4x4<f32>;
    var r: f32;
    var i: i32 = 0i;
    var i1_: i32;
    var i2_: i32;
    var tmp: vec4<f32>;
    var i_1: i32 = 0i;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    balance_1 = balance;
    variability_1 = variability;
    borderColor_1 = borderColor;
    thickness_1 = thickness;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e25 = variability_1;
    regularity_6 = (1f - _e25);
    let _e28 = modelTransform_1;
    let _e30 = uv_1;
    u_8 = (_naga_inverse_3x3_f32(_e28) * vec3<f32>(_e30.x, _e30.y, 1f)).xy;
    let _e38 = u_8;
    c_2 = floor(_e38);
    let _e41 = u_8;
    let _e42 = c_2;
    f = (_e41 - _e42);
    let _e45 = f;
    cell = abs((_e45 - vec2(0.5f)));
    let _e51 = cell;
    let _e53 = cell;
    k_4 = max(_e51.x, _e53.y);
    let _e57 = cell;
    let _e60 = cell;
    d = max(abs(_e57.x), abs(_e60.y));
    let _e65 = d;
    let _e68 = thickness_1;
    onBorder = (_e65 > (0.5f - (0.5f * _e68)));
    let _e73 = onBorder;
    let _e74 = borderColor_1;
    if (_e73 && (_e74.w == 1f)) {
        let _e79 = borderColor_1;
        return _e79;
    }
    let _e80 = c_2;
    let _e85 = randomSeed_1;
    let _e86 = regularity_6;
    let _e87 = getDir(_e80, vec2<f32>(0f, -1f), _e85, _e86);
    dirBottom = _e87;
    let _e89 = c_2;
    let _e93 = randomSeed_1;
    let _e94 = regularity_6;
    let _e95 = getDir(_e89, vec2<f32>(0f, 1f), _e93, _e94);
    dirTop = _e95;
    let _e97 = c_2;
    let _e102 = randomSeed_1;
    let _e103 = regularity_6;
    let _e104 = getDir(_e97, vec2<f32>(-1f, 0f), _e102, _e103);
    dirLeft = _e104;
    let _e106 = c_2;
    let _e110 = randomSeed_1;
    let _e111 = regularity_6;
    let _e112 = getDir(_e106, vec2<f32>(1f, 0f), _e110, _e111);
    dirRight = _e112;
    let _e115 = randomSeed_1;
    let _e121 = regularity_6;
    if (pow((1f - fract((_e115 * 0.11111f))), (10f - (_e121 * 9f))) > 0.95f) {
        {
            dirTop = false;
            dirBottom = false;
            dirRight = true;
            dirLeft = true;
        }
    }
    let _e130 = c_2;
    let _e131 = randomSeed_1;
    let _e132 = rand2relSeeded(_e130, _e131);
    let _e136 = balance_1;
    if ((_e132.x + 0.5f) < abs(_e136)) {
        {
            dir_4 = vec2<f32>(0f, -1f);
            let _e149 = c_2;
            let _e154 = dir_4;
            v_2 = ((_e149 + vec2(0.5f)) + (0.5f * _e154));
            let _e157 = modelTransform_1;
            let _e158 = v_2;
            let _e159 = delta;
            let _e161 = tf(_e157, (_e158 + _e159));
            let _e165 = global.U[0];
            let _e168 = modelTransform_1;
            let _e169 = v_2;
            let _e170 = delta;
            let _e172 = tf(_e168, (_e169 + _e170));
            let _e181 = textureSample(t_source, samp, ((vec2<f32>((_e161.x / _e165.x), _e172.y) / vec2(2f)) + vec2(0.5f)));
            let _e183 = luma(_e181.xyz);
            let _e184 = modelTransform_1;
            let _e185 = v_2;
            let _e186 = delta;
            let _e188 = tf(_e184, (_e185 - _e186));
            let _e192 = global.U[0];
            let _e195 = modelTransform_1;
            let _e196 = v_2;
            let _e197 = delta;
            let _e199 = tf(_e195, (_e196 - _e197));
            let _e208 = textureSample(t_source, samp, ((vec2<f32>((_e188.x / _e192.x), _e199.y) / vec2(2f)) + vec2(0.5f)));
            let _e210 = luma(_e208.xyz);
            let _e213 = modelTransform_1;
            let _e214 = v_2;
            let _e215 = delta;
            let _e218 = delta;
            let _e220 = tf(_e213, ((_e214 + _e215.yx) + _e218));
            let _e224 = global.U[0];
            let _e227 = modelTransform_1;
            let _e228 = v_2;
            let _e229 = delta;
            let _e232 = delta;
            let _e234 = tf(_e227, ((_e228 + _e229.yx) + _e232));
            let _e243 = textureSample(t_source, samp, ((vec2<f32>((_e220.x / _e224.x), _e234.y) / vec2(2f)) + vec2(0.5f)));
            let _e245 = luma(_e243.xyz);
            let _e246 = modelTransform_1;
            let _e247 = v_2;
            let _e248 = delta;
            let _e251 = delta;
            let _e253 = tf(_e246, ((_e247 + _e248.yx) - _e251));
            let _e257 = global.U[0];
            let _e260 = modelTransform_1;
            let _e261 = v_2;
            let _e262 = delta;
            let _e265 = delta;
            let _e267 = tf(_e260, ((_e261 + _e262.yx) - _e265));
            let _e276 = textureSample(t_source, samp, ((vec2<f32>((_e253.x / _e257.x), _e267.y) / vec2(2f)) + vec2(0.5f)));
            let _e278 = luma(_e276.xyz);
            let _e282 = modelTransform_1;
            let _e283 = v_2;
            let _e284 = delta;
            let _e287 = delta;
            let _e289 = tf(_e282, ((_e283 - _e284.yx) + _e287));
            let _e293 = global.U[0];
            let _e296 = modelTransform_1;
            let _e297 = v_2;
            let _e298 = delta;
            let _e301 = delta;
            let _e303 = tf(_e296, ((_e297 - _e298.yx) + _e301));
            let _e312 = textureSample(t_source, samp, ((vec2<f32>((_e289.x / _e293.x), _e303.y) / vec2(2f)) + vec2(0.5f)));
            let _e314 = luma(_e312.xyz);
            let _e315 = modelTransform_1;
            let _e316 = v_2;
            let _e317 = delta;
            let _e320 = delta;
            let _e322 = tf(_e315, ((_e316 - _e317.yx) - _e320));
            let _e326 = global.U[0];
            let _e329 = modelTransform_1;
            let _e330 = v_2;
            let _e331 = delta;
            let _e334 = delta;
            let _e336 = tf(_e329, ((_e330 - _e331.yx) - _e334));
            let _e345 = textureSample(t_source, samp, ((vec2<f32>((_e322.x / _e326.x), _e336.y) / vec2(2f)) + vec2(0.5f)));
            let _e347 = luma(_e345.xyz);
            let _e351 = modelTransform_1;
            let _e352 = v_2;
            let _e353 = delta;
            let _e356 = tf(_e351, (_e352 + _e353.yx));
            let _e360 = global.U[0];
            let _e363 = modelTransform_1;
            let _e364 = v_2;
            let _e365 = delta;
            let _e368 = tf(_e363, (_e364 + _e365.yx));
            let _e377 = textureSample(t_source, samp, ((vec2<f32>((_e356.x / _e360.x), _e368.y) / vec2(2f)) + vec2(0.5f)));
            let _e379 = luma(_e377.xyz);
            let _e380 = modelTransform_1;
            let _e381 = v_2;
            let _e382 = delta;
            let _e385 = tf(_e380, (_e381 - _e382.yx));
            let _e389 = global.U[0];
            let _e392 = modelTransform_1;
            let _e393 = v_2;
            let _e394 = delta;
            let _e397 = tf(_e392, (_e393 - _e394.yx));
            let _e406 = textureSample(t_source, samp, ((vec2<f32>((_e385.x / _e389.x), _e397.y) / vec2(2f)) + vec2(0.5f)));
            let _e408 = luma(_e406.xyz);
            let _e411 = modelTransform_1;
            let _e412 = v_2;
            let _e413 = delta;
            let _e415 = delta;
            let _e418 = tf(_e411, ((_e412 + _e413) + _e415.yx));
            let _e422 = global.U[0];
            let _e425 = modelTransform_1;
            let _e426 = v_2;
            let _e427 = delta;
            let _e429 = delta;
            let _e432 = tf(_e425, ((_e426 + _e427) + _e429.yx));
            let _e441 = textureSample(t_source, samp, ((vec2<f32>((_e418.x / _e422.x), _e432.y) / vec2(2f)) + vec2(0.5f)));
            let _e443 = luma(_e441.xyz);
            let _e444 = modelTransform_1;
            let _e445 = v_2;
            let _e446 = delta;
            let _e448 = delta;
            let _e451 = tf(_e444, ((_e445 + _e446) - _e448.yx));
            let _e455 = global.U[0];
            let _e458 = modelTransform_1;
            let _e459 = v_2;
            let _e460 = delta;
            let _e462 = delta;
            let _e465 = tf(_e458, ((_e459 + _e460) - _e462.yx));
            let _e474 = textureSample(t_source, samp, ((vec2<f32>((_e451.x / _e455.x), _e465.y) / vec2(2f)) + vec2(0.5f)));
            let _e476 = luma(_e474.xyz);
            let _e480 = modelTransform_1;
            let _e481 = v_2;
            let _e482 = delta;
            let _e484 = delta;
            let _e487 = tf(_e480, ((_e481 - _e482) + _e484.yx));
            let _e491 = global.U[0];
            let _e494 = modelTransform_1;
            let _e495 = v_2;
            let _e496 = delta;
            let _e498 = delta;
            let _e501 = tf(_e494, ((_e495 - _e496) + _e498.yx));
            let _e510 = textureSample(t_source, samp, ((vec2<f32>((_e487.x / _e491.x), _e501.y) / vec2(2f)) + vec2(0.5f)));
            let _e512 = luma(_e510.xyz);
            let _e513 = modelTransform_1;
            let _e514 = v_2;
            let _e515 = delta;
            let _e517 = delta;
            let _e520 = tf(_e513, ((_e514 - _e515) - _e517.yx));
            let _e524 = global.U[0];
            let _e527 = modelTransform_1;
            let _e528 = v_2;
            let _e529 = delta;
            let _e531 = delta;
            let _e534 = tf(_e527, ((_e528 - _e529) - _e531.yx));
            let _e543 = textureSample(t_source, samp, ((vec2<f32>((_e520.x / _e524.x), _e534.y) / vec2(2f)) + vec2(0.5f)));
            let _e545 = luma(_e543.xyz);
            dirBottom = (((abs((_e183 - _e210)) + abs((_e245 - _e278))) + abs((_e314 - _e347))) < ((abs((_e379 - _e408)) + abs((_e443 - _e476))) + abs((_e512 - _e545))));
            dir_4 = vec2<f32>(0f, 1f);
            let _e553 = c_2;
            let _e558 = dir_4;
            v_2 = ((_e553 + vec2(0.5f)) + (0.5f * _e558));
            let _e561 = modelTransform_1;
            let _e562 = v_2;
            let _e563 = delta;
            let _e565 = tf(_e561, (_e562 + _e563));
            let _e569 = global.U[0];
            let _e572 = modelTransform_1;
            let _e573 = v_2;
            let _e574 = delta;
            let _e576 = tf(_e572, (_e573 + _e574));
            let _e585 = textureSample(t_source, samp, ((vec2<f32>((_e565.x / _e569.x), _e576.y) / vec2(2f)) + vec2(0.5f)));
            let _e587 = luma(_e585.xyz);
            let _e588 = modelTransform_1;
            let _e589 = v_2;
            let _e590 = delta;
            let _e592 = tf(_e588, (_e589 - _e590));
            let _e596 = global.U[0];
            let _e599 = modelTransform_1;
            let _e600 = v_2;
            let _e601 = delta;
            let _e603 = tf(_e599, (_e600 - _e601));
            let _e612 = textureSample(t_source, samp, ((vec2<f32>((_e592.x / _e596.x), _e603.y) / vec2(2f)) + vec2(0.5f)));
            let _e614 = luma(_e612.xyz);
            let _e617 = modelTransform_1;
            let _e618 = v_2;
            let _e619 = delta;
            let _e622 = delta;
            let _e624 = tf(_e617, ((_e618 + _e619.yx) + _e622));
            let _e628 = global.U[0];
            let _e631 = modelTransform_1;
            let _e632 = v_2;
            let _e633 = delta;
            let _e636 = delta;
            let _e638 = tf(_e631, ((_e632 + _e633.yx) + _e636));
            let _e647 = textureSample(t_source, samp, ((vec2<f32>((_e624.x / _e628.x), _e638.y) / vec2(2f)) + vec2(0.5f)));
            let _e649 = luma(_e647.xyz);
            let _e650 = modelTransform_1;
            let _e651 = v_2;
            let _e652 = delta;
            let _e655 = delta;
            let _e657 = tf(_e650, ((_e651 + _e652.yx) - _e655));
            let _e661 = global.U[0];
            let _e664 = modelTransform_1;
            let _e665 = v_2;
            let _e666 = delta;
            let _e669 = delta;
            let _e671 = tf(_e664, ((_e665 + _e666.yx) - _e669));
            let _e680 = textureSample(t_source, samp, ((vec2<f32>((_e657.x / _e661.x), _e671.y) / vec2(2f)) + vec2(0.5f)));
            let _e682 = luma(_e680.xyz);
            let _e686 = modelTransform_1;
            let _e687 = v_2;
            let _e688 = delta;
            let _e691 = delta;
            let _e693 = tf(_e686, ((_e687 - _e688.yx) + _e691));
            let _e697 = global.U[0];
            let _e700 = modelTransform_1;
            let _e701 = v_2;
            let _e702 = delta;
            let _e705 = delta;
            let _e707 = tf(_e700, ((_e701 - _e702.yx) + _e705));
            let _e716 = textureSample(t_source, samp, ((vec2<f32>((_e693.x / _e697.x), _e707.y) / vec2(2f)) + vec2(0.5f)));
            let _e718 = luma(_e716.xyz);
            let _e719 = modelTransform_1;
            let _e720 = v_2;
            let _e721 = delta;
            let _e724 = delta;
            let _e726 = tf(_e719, ((_e720 - _e721.yx) - _e724));
            let _e730 = global.U[0];
            let _e733 = modelTransform_1;
            let _e734 = v_2;
            let _e735 = delta;
            let _e738 = delta;
            let _e740 = tf(_e733, ((_e734 - _e735.yx) - _e738));
            let _e749 = textureSample(t_source, samp, ((vec2<f32>((_e726.x / _e730.x), _e740.y) / vec2(2f)) + vec2(0.5f)));
            let _e751 = luma(_e749.xyz);
            let _e755 = modelTransform_1;
            let _e756 = v_2;
            let _e757 = delta;
            let _e760 = tf(_e755, (_e756 + _e757.yx));
            let _e764 = global.U[0];
            let _e767 = modelTransform_1;
            let _e768 = v_2;
            let _e769 = delta;
            let _e772 = tf(_e767, (_e768 + _e769.yx));
            let _e781 = textureSample(t_source, samp, ((vec2<f32>((_e760.x / _e764.x), _e772.y) / vec2(2f)) + vec2(0.5f)));
            let _e783 = luma(_e781.xyz);
            let _e784 = modelTransform_1;
            let _e785 = v_2;
            let _e786 = delta;
            let _e789 = tf(_e784, (_e785 - _e786.yx));
            let _e793 = global.U[0];
            let _e796 = modelTransform_1;
            let _e797 = v_2;
            let _e798 = delta;
            let _e801 = tf(_e796, (_e797 - _e798.yx));
            let _e810 = textureSample(t_source, samp, ((vec2<f32>((_e789.x / _e793.x), _e801.y) / vec2(2f)) + vec2(0.5f)));
            let _e812 = luma(_e810.xyz);
            let _e815 = modelTransform_1;
            let _e816 = v_2;
            let _e817 = delta;
            let _e819 = delta;
            let _e822 = tf(_e815, ((_e816 + _e817) + _e819.yx));
            let _e826 = global.U[0];
            let _e829 = modelTransform_1;
            let _e830 = v_2;
            let _e831 = delta;
            let _e833 = delta;
            let _e836 = tf(_e829, ((_e830 + _e831) + _e833.yx));
            let _e845 = textureSample(t_source, samp, ((vec2<f32>((_e822.x / _e826.x), _e836.y) / vec2(2f)) + vec2(0.5f)));
            let _e847 = luma(_e845.xyz);
            let _e848 = modelTransform_1;
            let _e849 = v_2;
            let _e850 = delta;
            let _e852 = delta;
            let _e855 = tf(_e848, ((_e849 + _e850) - _e852.yx));
            let _e859 = global.U[0];
            let _e862 = modelTransform_1;
            let _e863 = v_2;
            let _e864 = delta;
            let _e866 = delta;
            let _e869 = tf(_e862, ((_e863 + _e864) - _e866.yx));
            let _e878 = textureSample(t_source, samp, ((vec2<f32>((_e855.x / _e859.x), _e869.y) / vec2(2f)) + vec2(0.5f)));
            let _e880 = luma(_e878.xyz);
            let _e884 = modelTransform_1;
            let _e885 = v_2;
            let _e886 = delta;
            let _e888 = delta;
            let _e891 = tf(_e884, ((_e885 - _e886) + _e888.yx));
            let _e895 = global.U[0];
            let _e898 = modelTransform_1;
            let _e899 = v_2;
            let _e900 = delta;
            let _e902 = delta;
            let _e905 = tf(_e898, ((_e899 - _e900) + _e902.yx));
            let _e914 = textureSample(t_source, samp, ((vec2<f32>((_e891.x / _e895.x), _e905.y) / vec2(2f)) + vec2(0.5f)));
            let _e916 = luma(_e914.xyz);
            let _e917 = modelTransform_1;
            let _e918 = v_2;
            let _e919 = delta;
            let _e921 = delta;
            let _e924 = tf(_e917, ((_e918 - _e919) - _e921.yx));
            let _e928 = global.U[0];
            let _e931 = modelTransform_1;
            let _e932 = v_2;
            let _e933 = delta;
            let _e935 = delta;
            let _e938 = tf(_e931, ((_e932 - _e933) - _e935.yx));
            let _e947 = textureSample(t_source, samp, ((vec2<f32>((_e924.x / _e928.x), _e938.y) / vec2(2f)) + vec2(0.5f)));
            let _e949 = luma(_e947.xyz);
            dirTop = (((abs((_e587 - _e614)) + abs((_e649 - _e682))) + abs((_e718 - _e751))) < ((abs((_e783 - _e812)) + abs((_e847 - _e880))) + abs((_e916 - _e949))));
            dir_4 = vec2<f32>(-1f, 0f);
            let _e958 = c_2;
            let _e963 = dir_4;
            v_2 = ((_e958 + vec2(0.5f)) + (0.5f * _e963));
            let _e966 = modelTransform_1;
            let _e967 = v_2;
            let _e968 = delta;
            let _e970 = tf(_e966, (_e967 + _e968));
            let _e974 = global.U[0];
            let _e977 = modelTransform_1;
            let _e978 = v_2;
            let _e979 = delta;
            let _e981 = tf(_e977, (_e978 + _e979));
            let _e990 = textureSample(t_source, samp, ((vec2<f32>((_e970.x / _e974.x), _e981.y) / vec2(2f)) + vec2(0.5f)));
            let _e992 = luma(_e990.xyz);
            let _e993 = modelTransform_1;
            let _e994 = v_2;
            let _e995 = delta;
            let _e997 = tf(_e993, (_e994 - _e995));
            let _e1001 = global.U[0];
            let _e1004 = modelTransform_1;
            let _e1005 = v_2;
            let _e1006 = delta;
            let _e1008 = tf(_e1004, (_e1005 - _e1006));
            let _e1017 = textureSample(t_source, samp, ((vec2<f32>((_e997.x / _e1001.x), _e1008.y) / vec2(2f)) + vec2(0.5f)));
            let _e1019 = luma(_e1017.xyz);
            let _e1022 = modelTransform_1;
            let _e1023 = v_2;
            let _e1024 = delta;
            let _e1027 = delta;
            let _e1029 = tf(_e1022, ((_e1023 + _e1024.yx) + _e1027));
            let _e1033 = global.U[0];
            let _e1036 = modelTransform_1;
            let _e1037 = v_2;
            let _e1038 = delta;
            let _e1041 = delta;
            let _e1043 = tf(_e1036, ((_e1037 + _e1038.yx) + _e1041));
            let _e1052 = textureSample(t_source, samp, ((vec2<f32>((_e1029.x / _e1033.x), _e1043.y) / vec2(2f)) + vec2(0.5f)));
            let _e1054 = luma(_e1052.xyz);
            let _e1055 = modelTransform_1;
            let _e1056 = v_2;
            let _e1057 = delta;
            let _e1060 = delta;
            let _e1062 = tf(_e1055, ((_e1056 + _e1057.yx) - _e1060));
            let _e1066 = global.U[0];
            let _e1069 = modelTransform_1;
            let _e1070 = v_2;
            let _e1071 = delta;
            let _e1074 = delta;
            let _e1076 = tf(_e1069, ((_e1070 + _e1071.yx) - _e1074));
            let _e1085 = textureSample(t_source, samp, ((vec2<f32>((_e1062.x / _e1066.x), _e1076.y) / vec2(2f)) + vec2(0.5f)));
            let _e1087 = luma(_e1085.xyz);
            let _e1091 = modelTransform_1;
            let _e1092 = v_2;
            let _e1093 = delta;
            let _e1096 = delta;
            let _e1098 = tf(_e1091, ((_e1092 - _e1093.yx) + _e1096));
            let _e1102 = global.U[0];
            let _e1105 = modelTransform_1;
            let _e1106 = v_2;
            let _e1107 = delta;
            let _e1110 = delta;
            let _e1112 = tf(_e1105, ((_e1106 - _e1107.yx) + _e1110));
            let _e1121 = textureSample(t_source, samp, ((vec2<f32>((_e1098.x / _e1102.x), _e1112.y) / vec2(2f)) + vec2(0.5f)));
            let _e1123 = luma(_e1121.xyz);
            let _e1124 = modelTransform_1;
            let _e1125 = v_2;
            let _e1126 = delta;
            let _e1129 = delta;
            let _e1131 = tf(_e1124, ((_e1125 - _e1126.yx) - _e1129));
            let _e1135 = global.U[0];
            let _e1138 = modelTransform_1;
            let _e1139 = v_2;
            let _e1140 = delta;
            let _e1143 = delta;
            let _e1145 = tf(_e1138, ((_e1139 - _e1140.yx) - _e1143));
            let _e1154 = textureSample(t_source, samp, ((vec2<f32>((_e1131.x / _e1135.x), _e1145.y) / vec2(2f)) + vec2(0.5f)));
            let _e1156 = luma(_e1154.xyz);
            let _e1160 = modelTransform_1;
            let _e1161 = v_2;
            let _e1162 = delta;
            let _e1165 = tf(_e1160, (_e1161 + _e1162.yx));
            let _e1169 = global.U[0];
            let _e1172 = modelTransform_1;
            let _e1173 = v_2;
            let _e1174 = delta;
            let _e1177 = tf(_e1172, (_e1173 + _e1174.yx));
            let _e1186 = textureSample(t_source, samp, ((vec2<f32>((_e1165.x / _e1169.x), _e1177.y) / vec2(2f)) + vec2(0.5f)));
            let _e1188 = luma(_e1186.xyz);
            let _e1189 = modelTransform_1;
            let _e1190 = v_2;
            let _e1191 = delta;
            let _e1194 = tf(_e1189, (_e1190 - _e1191.yx));
            let _e1198 = global.U[0];
            let _e1201 = modelTransform_1;
            let _e1202 = v_2;
            let _e1203 = delta;
            let _e1206 = tf(_e1201, (_e1202 - _e1203.yx));
            let _e1215 = textureSample(t_source, samp, ((vec2<f32>((_e1194.x / _e1198.x), _e1206.y) / vec2(2f)) + vec2(0.5f)));
            let _e1217 = luma(_e1215.xyz);
            let _e1220 = modelTransform_1;
            let _e1221 = v_2;
            let _e1222 = delta;
            let _e1224 = delta;
            let _e1227 = tf(_e1220, ((_e1221 + _e1222) + _e1224.yx));
            let _e1231 = global.U[0];
            let _e1234 = modelTransform_1;
            let _e1235 = v_2;
            let _e1236 = delta;
            let _e1238 = delta;
            let _e1241 = tf(_e1234, ((_e1235 + _e1236) + _e1238.yx));
            let _e1250 = textureSample(t_source, samp, ((vec2<f32>((_e1227.x / _e1231.x), _e1241.y) / vec2(2f)) + vec2(0.5f)));
            let _e1252 = luma(_e1250.xyz);
            let _e1253 = modelTransform_1;
            let _e1254 = v_2;
            let _e1255 = delta;
            let _e1257 = delta;
            let _e1260 = tf(_e1253, ((_e1254 + _e1255) - _e1257.yx));
            let _e1264 = global.U[0];
            let _e1267 = modelTransform_1;
            let _e1268 = v_2;
            let _e1269 = delta;
            let _e1271 = delta;
            let _e1274 = tf(_e1267, ((_e1268 + _e1269) - _e1271.yx));
            let _e1283 = textureSample(t_source, samp, ((vec2<f32>((_e1260.x / _e1264.x), _e1274.y) / vec2(2f)) + vec2(0.5f)));
            let _e1285 = luma(_e1283.xyz);
            let _e1289 = modelTransform_1;
            let _e1290 = v_2;
            let _e1291 = delta;
            let _e1293 = delta;
            let _e1296 = tf(_e1289, ((_e1290 - _e1291) + _e1293.yx));
            let _e1300 = global.U[0];
            let _e1303 = modelTransform_1;
            let _e1304 = v_2;
            let _e1305 = delta;
            let _e1307 = delta;
            let _e1310 = tf(_e1303, ((_e1304 - _e1305) + _e1307.yx));
            let _e1319 = textureSample(t_source, samp, ((vec2<f32>((_e1296.x / _e1300.x), _e1310.y) / vec2(2f)) + vec2(0.5f)));
            let _e1321 = luma(_e1319.xyz);
            let _e1322 = modelTransform_1;
            let _e1323 = v_2;
            let _e1324 = delta;
            let _e1326 = delta;
            let _e1329 = tf(_e1322, ((_e1323 - _e1324) - _e1326.yx));
            let _e1333 = global.U[0];
            let _e1336 = modelTransform_1;
            let _e1337 = v_2;
            let _e1338 = delta;
            let _e1340 = delta;
            let _e1343 = tf(_e1336, ((_e1337 - _e1338) - _e1340.yx));
            let _e1352 = textureSample(t_source, samp, ((vec2<f32>((_e1329.x / _e1333.x), _e1343.y) / vec2(2f)) + vec2(0.5f)));
            let _e1354 = luma(_e1352.xyz);
            dirLeft = (((abs((_e992 - _e1019)) + abs((_e1054 - _e1087))) + abs((_e1123 - _e1156))) < ((abs((_e1188 - _e1217)) + abs((_e1252 - _e1285))) + abs((_e1321 - _e1354))));
            dir_4 = vec2<f32>(1f, 0f);
            let _e1362 = c_2;
            let _e1367 = dir_4;
            v_2 = ((_e1362 + vec2(0.5f)) + (0.5f * _e1367));
            let _e1370 = modelTransform_1;
            let _e1371 = v_2;
            let _e1372 = delta;
            let _e1374 = tf(_e1370, (_e1371 + _e1372));
            let _e1378 = global.U[0];
            let _e1381 = modelTransform_1;
            let _e1382 = v_2;
            let _e1383 = delta;
            let _e1385 = tf(_e1381, (_e1382 + _e1383));
            let _e1394 = textureSample(t_source, samp, ((vec2<f32>((_e1374.x / _e1378.x), _e1385.y) / vec2(2f)) + vec2(0.5f)));
            let _e1396 = luma(_e1394.xyz);
            let _e1397 = modelTransform_1;
            let _e1398 = v_2;
            let _e1399 = delta;
            let _e1401 = tf(_e1397, (_e1398 - _e1399));
            let _e1405 = global.U[0];
            let _e1408 = modelTransform_1;
            let _e1409 = v_2;
            let _e1410 = delta;
            let _e1412 = tf(_e1408, (_e1409 - _e1410));
            let _e1421 = textureSample(t_source, samp, ((vec2<f32>((_e1401.x / _e1405.x), _e1412.y) / vec2(2f)) + vec2(0.5f)));
            let _e1423 = luma(_e1421.xyz);
            let _e1426 = modelTransform_1;
            let _e1427 = v_2;
            let _e1428 = delta;
            let _e1431 = delta;
            let _e1433 = tf(_e1426, ((_e1427 + _e1428.yx) + _e1431));
            let _e1437 = global.U[0];
            let _e1440 = modelTransform_1;
            let _e1441 = v_2;
            let _e1442 = delta;
            let _e1445 = delta;
            let _e1447 = tf(_e1440, ((_e1441 + _e1442.yx) + _e1445));
            let _e1456 = textureSample(t_source, samp, ((vec2<f32>((_e1433.x / _e1437.x), _e1447.y) / vec2(2f)) + vec2(0.5f)));
            let _e1458 = luma(_e1456.xyz);
            let _e1459 = modelTransform_1;
            let _e1460 = v_2;
            let _e1461 = delta;
            let _e1464 = delta;
            let _e1466 = tf(_e1459, ((_e1460 + _e1461.yx) - _e1464));
            let _e1470 = global.U[0];
            let _e1473 = modelTransform_1;
            let _e1474 = v_2;
            let _e1475 = delta;
            let _e1478 = delta;
            let _e1480 = tf(_e1473, ((_e1474 + _e1475.yx) - _e1478));
            let _e1489 = textureSample(t_source, samp, ((vec2<f32>((_e1466.x / _e1470.x), _e1480.y) / vec2(2f)) + vec2(0.5f)));
            let _e1491 = luma(_e1489.xyz);
            let _e1495 = modelTransform_1;
            let _e1496 = v_2;
            let _e1497 = delta;
            let _e1500 = delta;
            let _e1502 = tf(_e1495, ((_e1496 - _e1497.yx) + _e1500));
            let _e1506 = global.U[0];
            let _e1509 = modelTransform_1;
            let _e1510 = v_2;
            let _e1511 = delta;
            let _e1514 = delta;
            let _e1516 = tf(_e1509, ((_e1510 - _e1511.yx) + _e1514));
            let _e1525 = textureSample(t_source, samp, ((vec2<f32>((_e1502.x / _e1506.x), _e1516.y) / vec2(2f)) + vec2(0.5f)));
            let _e1527 = luma(_e1525.xyz);
            let _e1528 = modelTransform_1;
            let _e1529 = v_2;
            let _e1530 = delta;
            let _e1533 = delta;
            let _e1535 = tf(_e1528, ((_e1529 - _e1530.yx) - _e1533));
            let _e1539 = global.U[0];
            let _e1542 = modelTransform_1;
            let _e1543 = v_2;
            let _e1544 = delta;
            let _e1547 = delta;
            let _e1549 = tf(_e1542, ((_e1543 - _e1544.yx) - _e1547));
            let _e1558 = textureSample(t_source, samp, ((vec2<f32>((_e1535.x / _e1539.x), _e1549.y) / vec2(2f)) + vec2(0.5f)));
            let _e1560 = luma(_e1558.xyz);
            let _e1564 = modelTransform_1;
            let _e1565 = v_2;
            let _e1566 = delta;
            let _e1569 = tf(_e1564, (_e1565 + _e1566.yx));
            let _e1573 = global.U[0];
            let _e1576 = modelTransform_1;
            let _e1577 = v_2;
            let _e1578 = delta;
            let _e1581 = tf(_e1576, (_e1577 + _e1578.yx));
            let _e1590 = textureSample(t_source, samp, ((vec2<f32>((_e1569.x / _e1573.x), _e1581.y) / vec2(2f)) + vec2(0.5f)));
            let _e1592 = luma(_e1590.xyz);
            let _e1593 = modelTransform_1;
            let _e1594 = v_2;
            let _e1595 = delta;
            let _e1598 = tf(_e1593, (_e1594 - _e1595.yx));
            let _e1602 = global.U[0];
            let _e1605 = modelTransform_1;
            let _e1606 = v_2;
            let _e1607 = delta;
            let _e1610 = tf(_e1605, (_e1606 - _e1607.yx));
            let _e1619 = textureSample(t_source, samp, ((vec2<f32>((_e1598.x / _e1602.x), _e1610.y) / vec2(2f)) + vec2(0.5f)));
            let _e1621 = luma(_e1619.xyz);
            let _e1624 = modelTransform_1;
            let _e1625 = v_2;
            let _e1626 = delta;
            let _e1628 = delta;
            let _e1631 = tf(_e1624, ((_e1625 + _e1626) + _e1628.yx));
            let _e1635 = global.U[0];
            let _e1638 = modelTransform_1;
            let _e1639 = v_2;
            let _e1640 = delta;
            let _e1642 = delta;
            let _e1645 = tf(_e1638, ((_e1639 + _e1640) + _e1642.yx));
            let _e1654 = textureSample(t_source, samp, ((vec2<f32>((_e1631.x / _e1635.x), _e1645.y) / vec2(2f)) + vec2(0.5f)));
            let _e1656 = luma(_e1654.xyz);
            let _e1657 = modelTransform_1;
            let _e1658 = v_2;
            let _e1659 = delta;
            let _e1661 = delta;
            let _e1664 = tf(_e1657, ((_e1658 + _e1659) - _e1661.yx));
            let _e1668 = global.U[0];
            let _e1671 = modelTransform_1;
            let _e1672 = v_2;
            let _e1673 = delta;
            let _e1675 = delta;
            let _e1678 = tf(_e1671, ((_e1672 + _e1673) - _e1675.yx));
            let _e1687 = textureSample(t_source, samp, ((vec2<f32>((_e1664.x / _e1668.x), _e1678.y) / vec2(2f)) + vec2(0.5f)));
            let _e1689 = luma(_e1687.xyz);
            let _e1693 = modelTransform_1;
            let _e1694 = v_2;
            let _e1695 = delta;
            let _e1697 = delta;
            let _e1700 = tf(_e1693, ((_e1694 - _e1695) + _e1697.yx));
            let _e1704 = global.U[0];
            let _e1707 = modelTransform_1;
            let _e1708 = v_2;
            let _e1709 = delta;
            let _e1711 = delta;
            let _e1714 = tf(_e1707, ((_e1708 - _e1709) + _e1711.yx));
            let _e1723 = textureSample(t_source, samp, ((vec2<f32>((_e1700.x / _e1704.x), _e1714.y) / vec2(2f)) + vec2(0.5f)));
            let _e1725 = luma(_e1723.xyz);
            let _e1726 = modelTransform_1;
            let _e1727 = v_2;
            let _e1728 = delta;
            let _e1730 = delta;
            let _e1733 = tf(_e1726, ((_e1727 - _e1728) - _e1730.yx));
            let _e1737 = global.U[0];
            let _e1740 = modelTransform_1;
            let _e1741 = v_2;
            let _e1742 = delta;
            let _e1744 = delta;
            let _e1747 = tf(_e1740, ((_e1741 - _e1742) - _e1744.yx));
            let _e1756 = textureSample(t_source, samp, ((vec2<f32>((_e1733.x / _e1737.x), _e1747.y) / vec2(2f)) + vec2(0.5f)));
            let _e1758 = luma(_e1756.xyz);
            dirRight = (((abs((_e1396 - _e1423)) + abs((_e1458 - _e1491))) + abs((_e1527 - _e1560))) < ((abs((_e1592 - _e1621)) + abs((_e1656 - _e1689))) + abs((_e1725 - _e1758))));
            let _e1763 = balance_1;
            if (_e1763 < 0f) {
                {
                    let _e1766 = dirTop;
                    dirTop = !(_e1766);
                    let _e1768 = dirBottom;
                    dirBottom = !(_e1768);
                    let _e1770 = dirLeft;
                    dirLeft = !(_e1770);
                    let _e1772 = dirRight;
                    dirRight = !(_e1772);
                }
            }
        }
    }
    let _e1780 = dirTop;
    let _e1781 = dirBottom;
    let _e1783 = dirTop;
    let _e1784 = dirLeft;
    let _e1787 = dirTop;
    let _e1788 = dirRight;
    if (((_e1780 == _e1781) && (_e1783 == _e1784)) && (_e1787 == _e1788)) {
        {
            let _e1791 = dirTop;
            if _e1791 {
                {
                    let _e1792 = modelTransform_1;
                    let _e1793 = c_2;
                    let _e1795 = u_8;
                    let _e1798 = tf(_e1792, vec2<f32>(_e1793.x, _e1795.y));
                    let _e1802 = global.U[0];
                    let _e1805 = modelTransform_1;
                    let _e1806 = c_2;
                    let _e1808 = u_8;
                    let _e1811 = tf(_e1805, vec2<f32>(_e1806.x, _e1808.y));
                    let _e1820 = textureSample(t_source, samp, ((vec2<f32>((_e1798.x / _e1802.x), _e1811.y) / vec2(2f)) + vec2(0.5f)));
                    let _e1821 = modelTransform_1;
                    let _e1822 = c_2;
                    let _e1826 = u_8;
                    let _e1829 = tf(_e1821, vec2<f32>((_e1822.x + 1f), _e1826.y));
                    let _e1833 = global.U[0];
                    let _e1836 = modelTransform_1;
                    let _e1837 = c_2;
                    let _e1841 = u_8;
                    let _e1844 = tf(_e1836, vec2<f32>((_e1837.x + 1f), _e1841.y));
                    let _e1853 = textureSample(t_source, samp, ((vec2<f32>((_e1829.x / _e1833.x), _e1844.y) / vec2(2f)) + vec2(0.5f)));
                    let _e1854 = u_8;
                    let _e1856 = c_2;
                    col = mix(_e1820, _e1853, vec4((_e1854.x - _e1856.x)));
                }
            } else {
                {
                    let _e1861 = modelTransform_1;
                    let _e1862 = u_8;
                    let _e1864 = c_2;
                    let _e1867 = tf(_e1861, vec2<f32>(_e1862.x, _e1864.y));
                    let _e1871 = global.U[0];
                    let _e1874 = modelTransform_1;
                    let _e1875 = u_8;
                    let _e1877 = c_2;
                    let _e1880 = tf(_e1874, vec2<f32>(_e1875.x, _e1877.y));
                    let _e1889 = textureSample(t_source, samp, ((vec2<f32>((_e1867.x / _e1871.x), _e1880.y) / vec2(2f)) + vec2(0.5f)));
                    let _e1890 = modelTransform_1;
                    let _e1891 = u_8;
                    let _e1893 = c_2;
                    let _e1898 = tf(_e1890, vec2<f32>(_e1891.x, (_e1893.y + 1f)));
                    let _e1902 = global.U[0];
                    let _e1905 = modelTransform_1;
                    let _e1906 = u_8;
                    let _e1908 = c_2;
                    let _e1913 = tf(_e1905, vec2<f32>(_e1906.x, (_e1908.y + 1f)));
                    let _e1922 = textureSample(t_source, samp, ((vec2<f32>((_e1898.x / _e1902.x), _e1913.y) / vec2(2f)) + vec2(0.5f)));
                    let _e1923 = u_8;
                    let _e1925 = c_2;
                    col = mix(_e1889, _e1922, vec4((_e1923.y - _e1925.y)));
                }
            }
        }
    } else {
        let _e1930 = dirTop;
        let _e1931 = dirBottom;
        let _e1933 = dirLeft;
        let _e1935 = dirRight;
        if (((_e1930 && _e1931) && _e1933) && !(_e1935)) {
            {
                if false {
                    {
                        let _e1939 = modelTransform_1;
                        let _e1940 = c_2;
                        let _e1942 = u_8;
                        let _e1945 = tf(_e1939, vec2<f32>(_e1940.x, _e1942.y));
                        let _e1949 = global.U[0];
                        let _e1952 = modelTransform_1;
                        let _e1953 = c_2;
                        let _e1955 = u_8;
                        let _e1958 = tf(_e1952, vec2<f32>(_e1953.x, _e1955.y));
                        let _e1967 = textureSample(t_source, samp, ((vec2<f32>((_e1945.x / _e1949.x), _e1958.y) / vec2(2f)) + vec2(0.5f)));
                        let _e1968 = modelTransform_1;
                        let _e1969 = c_2;
                        let _e1973 = u_8;
                        let _e1976 = tf(_e1968, vec2<f32>((_e1969.x + 1f), _e1973.y));
                        let _e1980 = global.U[0];
                        let _e1983 = modelTransform_1;
                        let _e1984 = c_2;
                        let _e1988 = u_8;
                        let _e1991 = tf(_e1983, vec2<f32>((_e1984.x + 1f), _e1988.y));
                        let _e2000 = textureSample(t_source, samp, ((vec2<f32>((_e1976.x / _e1980.x), _e1991.y) / vec2(2f)) + vec2(0.5f)));
                        let _e2001 = u_8;
                        let _e2003 = c_2;
                        col = mix(_e1967, _e2000, vec4((_e2001.x - _e2003.x)));
                    }
                } else {
                    {
                        col = vec4<f32>(0f, 1f, 0f, 1f);
                        let _e2013 = c_2;
                        let _e2017 = u_8;
                        let _e2019 = c_2;
                        X = ((_e2013.x + 0.5f) + abs(((_e2017.y - _e2019.y) - 0.5f)));
                        let _e2027 = u_8;
                        let _e2029 = X;
                        if (_e2027.x < _e2029) {
                            let _e2031 = modelTransform_1;
                            let _e2032 = c_2;
                            let _e2034 = u_8;
                            let _e2037 = tf(_e2031, vec2<f32>(_e2032.x, _e2034.y));
                            let _e2041 = global.U[0];
                            let _e2044 = modelTransform_1;
                            let _e2045 = c_2;
                            let _e2047 = u_8;
                            let _e2050 = tf(_e2044, vec2<f32>(_e2045.x, _e2047.y));
                            let _e2059 = textureSample(t_source, samp, ((vec2<f32>((_e2037.x / _e2041.x), _e2050.y) / vec2(2f)) + vec2(0.5f)));
                            let _e2060 = modelTransform_1;
                            let _e2061 = X;
                            let _e2062 = u_8;
                            let _e2065 = tf(_e2060, vec2<f32>(_e2061, _e2062.y));
                            let _e2069 = global.U[0];
                            let _e2072 = modelTransform_1;
                            let _e2073 = X;
                            let _e2074 = u_8;
                            let _e2077 = tf(_e2072, vec2<f32>(_e2073, _e2074.y));
                            let _e2086 = textureSample(t_source, samp, ((vec2<f32>((_e2065.x / _e2069.x), _e2077.y) / vec2(2f)) + vec2(0.5f)));
                            let _e2087 = u_8;
                            let _e2089 = c_2;
                            let _e2092 = X;
                            let _e2093 = c_2;
                            col = mix(_e2059, _e2086, vec4(((_e2087.x - _e2089.x) / (_e2092 - _e2093.x))));
                        } else {
                            {
                                let _e2099 = u_8;
                                let _e2101 = c_2;
                                Y = abs(((_e2099.x - _e2101.x) - 0.5f));
                                let _e2108 = modelTransform_1;
                                let _e2109 = u_8;
                                let _e2111 = c_2;
                                let _e2115 = Y;
                                let _e2118 = tf(_e2108, vec2<f32>(_e2109.x, ((_e2111.y + 0.5f) - _e2115)));
                                let _e2122 = global.U[0];
                                let _e2125 = modelTransform_1;
                                let _e2126 = u_8;
                                let _e2128 = c_2;
                                let _e2132 = Y;
                                let _e2135 = tf(_e2125, vec2<f32>(_e2126.x, ((_e2128.y + 0.5f) - _e2132)));
                                let _e2144 = textureSample(t_source, samp, ((vec2<f32>((_e2118.x / _e2122.x), _e2135.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2145 = modelTransform_1;
                                let _e2146 = u_8;
                                let _e2148 = c_2;
                                let _e2152 = Y;
                                let _e2155 = tf(_e2145, vec2<f32>(_e2146.x, ((_e2148.y + 0.5f) + _e2152)));
                                let _e2159 = global.U[0];
                                let _e2162 = modelTransform_1;
                                let _e2163 = u_8;
                                let _e2165 = c_2;
                                let _e2169 = Y;
                                let _e2172 = tf(_e2162, vec2<f32>(_e2163.x, ((_e2165.y + 0.5f) + _e2169)));
                                let _e2181 = textureSample(t_source, samp, ((vec2<f32>((_e2155.x / _e2159.x), _e2172.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2182 = u_8;
                                let _e2184 = c_2;
                                let _e2189 = Y;
                                let _e2192 = Y;
                                col = mix(_e2144, _e2181, vec4(((((_e2182.y - _e2184.y) - 0.5f) + _e2189) / (2f * _e2192))));
                            }
                        }
                    }
                }
            }
        } else {
            let _e2197 = dirTop;
            let _e2198 = dirBottom;
            let _e2200 = dirLeft;
            let _e2203 = dirRight;
            if (((_e2197 && _e2198) && !(_e2200)) && _e2203) {
                {
                    if false {
                        {
                            let _e2206 = modelTransform_1;
                            let _e2207 = c_2;
                            let _e2209 = u_8;
                            let _e2212 = tf(_e2206, vec2<f32>(_e2207.x, _e2209.y));
                            let _e2216 = global.U[0];
                            let _e2219 = modelTransform_1;
                            let _e2220 = c_2;
                            let _e2222 = u_8;
                            let _e2225 = tf(_e2219, vec2<f32>(_e2220.x, _e2222.y));
                            let _e2234 = textureSample(t_source, samp, ((vec2<f32>((_e2212.x / _e2216.x), _e2225.y) / vec2(2f)) + vec2(0.5f)));
                            let _e2235 = modelTransform_1;
                            let _e2236 = c_2;
                            let _e2240 = u_8;
                            let _e2243 = tf(_e2235, vec2<f32>((_e2236.x + 1f), _e2240.y));
                            let _e2247 = global.U[0];
                            let _e2250 = modelTransform_1;
                            let _e2251 = c_2;
                            let _e2255 = u_8;
                            let _e2258 = tf(_e2250, vec2<f32>((_e2251.x + 1f), _e2255.y));
                            let _e2267 = textureSample(t_source, samp, ((vec2<f32>((_e2243.x / _e2247.x), _e2258.y) / vec2(2f)) + vec2(0.5f)));
                            let _e2268 = u_8;
                            let _e2270 = c_2;
                            col = mix(_e2234, _e2267, vec4((_e2268.x - _e2270.x)));
                        }
                    } else {
                        {
                            let _e2275 = c_2;
                            let _e2279 = u_8;
                            let _e2281 = c_2;
                            X_1 = ((_e2275.x + 0.5f) - abs(((_e2279.y - _e2281.y) - 0.5f)));
                            let _e2289 = u_8;
                            let _e2291 = X_1;
                            if (_e2289.x > _e2291) {
                                let _e2293 = modelTransform_1;
                                let _e2294 = X_1;
                                let _e2295 = u_8;
                                let _e2298 = tf(_e2293, vec2<f32>(_e2294, _e2295.y));
                                let _e2302 = global.U[0];
                                let _e2305 = modelTransform_1;
                                let _e2306 = X_1;
                                let _e2307 = u_8;
                                let _e2310 = tf(_e2305, vec2<f32>(_e2306, _e2307.y));
                                let _e2319 = textureSample(t_source, samp, ((vec2<f32>((_e2298.x / _e2302.x), _e2310.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2320 = modelTransform_1;
                                let _e2321 = c_2;
                                let _e2325 = u_8;
                                let _e2328 = tf(_e2320, vec2<f32>((_e2321.x + 1f), _e2325.y));
                                let _e2332 = global.U[0];
                                let _e2335 = modelTransform_1;
                                let _e2336 = c_2;
                                let _e2340 = u_8;
                                let _e2343 = tf(_e2335, vec2<f32>((_e2336.x + 1f), _e2340.y));
                                let _e2352 = textureSample(t_source, samp, ((vec2<f32>((_e2328.x / _e2332.x), _e2343.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2353 = u_8;
                                let _e2355 = X_1;
                                let _e2357 = c_2;
                                let _e2361 = X_1;
                                col = mix(_e2319, _e2352, vec4(((_e2353.x - _e2355) / ((_e2357.x + 1f) - _e2361))));
                            } else {
                                {
                                    let _e2366 = u_8;
                                    let _e2368 = c_2;
                                    Y_1 = abs(((_e2366.x - _e2368.x) - 0.5f));
                                    let _e2375 = modelTransform_1;
                                    let _e2376 = u_8;
                                    let _e2378 = c_2;
                                    let _e2382 = Y_1;
                                    let _e2385 = tf(_e2375, vec2<f32>(_e2376.x, ((_e2378.y + 0.5f) - _e2382)));
                                    let _e2389 = global.U[0];
                                    let _e2392 = modelTransform_1;
                                    let _e2393 = u_8;
                                    let _e2395 = c_2;
                                    let _e2399 = Y_1;
                                    let _e2402 = tf(_e2392, vec2<f32>(_e2393.x, ((_e2395.y + 0.5f) - _e2399)));
                                    let _e2411 = textureSample(t_source, samp, ((vec2<f32>((_e2385.x / _e2389.x), _e2402.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2412 = modelTransform_1;
                                    let _e2413 = u_8;
                                    let _e2415 = c_2;
                                    let _e2419 = Y_1;
                                    let _e2422 = tf(_e2412, vec2<f32>(_e2413.x, ((_e2415.y + 0.5f) + _e2419)));
                                    let _e2426 = global.U[0];
                                    let _e2429 = modelTransform_1;
                                    let _e2430 = u_8;
                                    let _e2432 = c_2;
                                    let _e2436 = Y_1;
                                    let _e2439 = tf(_e2429, vec2<f32>(_e2430.x, ((_e2432.y + 0.5f) + _e2436)));
                                    let _e2448 = textureSample(t_source, samp, ((vec2<f32>((_e2422.x / _e2426.x), _e2439.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2449 = u_8;
                                    let _e2451 = c_2;
                                    let _e2456 = Y_1;
                                    let _e2459 = Y_1;
                                    col = mix(_e2411, _e2448, vec4(((((_e2449.y - _e2451.y) - 0.5f) + _e2456) / (2f * _e2459))));
                                }
                            }
                        }
                    }
                }
            } else {
                let _e2464 = dirTop;
                let _e2465 = dirBottom;
                let _e2468 = dirLeft;
                let _e2470 = dirRight;
                if (((_e2464 && !(_e2465)) && _e2468) && _e2470) {
                    {
                        let _e2472 = c_2;
                        center = ((_e2472 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                        let _e2495 = u_8;
                        let _e2496 = center;
                        rel = (_e2495 - _e2496);
                        let _e2499 = rel;
                        len = length(_e2499);
                        let _e2502 = len;
                        if (_e2502 < 1f) {
                            {
                                let _e2505 = u_8;
                                let _e2506 = center;
                                let _e2513 = u_8;
                                let _e2514 = center;
                                a_1 = atan2(dot((_e2505 - _e2506), vec2<f32>(-1f, 0f)), dot((_e2513 - _e2514), vec2<f32>(0f, 1f)));
                                let _e2522 = modelTransform_1;
                                let _e2523 = center;
                                let _e2524 = len;
                                let _e2530 = tf(_e2522, (_e2523 + (_e2524 * vec2<f32>(0f, 1f))));
                                let _e2534 = global.U[0];
                                let _e2537 = modelTransform_1;
                                let _e2538 = center;
                                let _e2539 = len;
                                let _e2545 = tf(_e2537, (_e2538 + (_e2539 * vec2<f32>(0f, 1f))));
                                let _e2554 = textureSample(t_source, samp, ((vec2<f32>((_e2530.x / _e2534.x), _e2545.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2555 = modelTransform_1;
                                let _e2556 = center;
                                let _e2557 = len;
                                let _e2564 = tf(_e2555, (_e2556 + (_e2557 * vec2<f32>(-1f, 0f))));
                                let _e2568 = global.U[0];
                                let _e2571 = modelTransform_1;
                                let _e2572 = center;
                                let _e2573 = len;
                                let _e2580 = tf(_e2571, (_e2572 + (_e2573 * vec2<f32>(-1f, 0f))));
                                let _e2589 = textureSample(t_source, samp, ((vec2<f32>((_e2564.x / _e2568.x), _e2580.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2590 = a_1;
                                col = mix(_e2554, _e2589, vec4((_e2590 / 1.5707964f)));
                            }
                        } else {
                            {
                                let _e2595 = modelTransform_1;
                                let _e2596 = c_2;
                                let _e2598 = u_8;
                                let _e2601 = tf(_e2595, vec2<f32>(_e2596.x, _e2598.y));
                                let _e2605 = global.U[0];
                                let _e2608 = modelTransform_1;
                                let _e2609 = c_2;
                                let _e2611 = u_8;
                                let _e2614 = tf(_e2608, vec2<f32>(_e2609.x, _e2611.y));
                                let _e2623 = textureSample(t_source, samp, ((vec2<f32>((_e2601.x / _e2605.x), _e2614.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2624 = modelTransform_1;
                                let _e2625 = c_2;
                                let _e2629 = u_8;
                                let _e2632 = tf(_e2624, vec2<f32>((_e2625.x + 1f), _e2629.y));
                                let _e2636 = global.U[0];
                                let _e2639 = modelTransform_1;
                                let _e2640 = c_2;
                                let _e2644 = u_8;
                                let _e2647 = tf(_e2639, vec2<f32>((_e2640.x + 1f), _e2644.y));
                                let _e2656 = textureSample(t_source, samp, ((vec2<f32>((_e2632.x / _e2636.x), _e2647.y) / vec2(2f)) + vec2(0.5f)));
                                let _e2657 = u_8;
                                let _e2659 = c_2;
                                col = mix(_e2623, _e2656, vec4((_e2657.x - _e2659.x)));
                            }
                        }
                    }
                } else {
                    let _e2664 = dirTop;
                    let _e2666 = dirBottom;
                    let _e2668 = dirLeft;
                    let _e2670 = dirRight;
                    if (((!(_e2664) && _e2666) && _e2668) && _e2670) {
                        {
                            let _e2672 = c_2;
                            center_1 = ((_e2672 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                            let _e2696 = u_8;
                            let _e2697 = center_1;
                            rel_1 = (_e2696 - _e2697);
                            let _e2700 = rel_1;
                            len_1 = length(_e2700);
                            let _e2703 = len_1;
                            if (_e2703 < 1f) {
                                {
                                    let _e2706 = u_8;
                                    let _e2707 = center_1;
                                    let _e2714 = u_8;
                                    let _e2715 = center_1;
                                    a_2 = atan2(dot((_e2706 - _e2707), vec2<f32>(0f, -1f)), dot((_e2714 - _e2715), vec2<f32>(-1f, 0f)));
                                    let _e2724 = modelTransform_1;
                                    let _e2725 = center_1;
                                    let _e2726 = len_1;
                                    let _e2733 = tf(_e2724, (_e2725 + (_e2726 * vec2<f32>(-1f, 0f))));
                                    let _e2737 = global.U[0];
                                    let _e2740 = modelTransform_1;
                                    let _e2741 = center_1;
                                    let _e2742 = len_1;
                                    let _e2749 = tf(_e2740, (_e2741 + (_e2742 * vec2<f32>(-1f, 0f))));
                                    let _e2758 = textureSample(t_source, samp, ((vec2<f32>((_e2733.x / _e2737.x), _e2749.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2759 = modelTransform_1;
                                    let _e2760 = center_1;
                                    let _e2761 = len_1;
                                    let _e2768 = tf(_e2759, (_e2760 + (_e2761 * vec2<f32>(0f, -1f))));
                                    let _e2772 = global.U[0];
                                    let _e2775 = modelTransform_1;
                                    let _e2776 = center_1;
                                    let _e2777 = len_1;
                                    let _e2784 = tf(_e2775, (_e2776 + (_e2777 * vec2<f32>(0f, -1f))));
                                    let _e2793 = textureSample(t_source, samp, ((vec2<f32>((_e2768.x / _e2772.x), _e2784.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2794 = a_2;
                                    col = mix(_e2758, _e2793, vec4((_e2794 / 1.5707964f)));
                                }
                            } else {
                                {
                                    let _e2799 = modelTransform_1;
                                    let _e2800 = c_2;
                                    let _e2802 = u_8;
                                    let _e2805 = tf(_e2799, vec2<f32>(_e2800.x, _e2802.y));
                                    let _e2809 = global.U[0];
                                    let _e2812 = modelTransform_1;
                                    let _e2813 = c_2;
                                    let _e2815 = u_8;
                                    let _e2818 = tf(_e2812, vec2<f32>(_e2813.x, _e2815.y));
                                    let _e2827 = textureSample(t_source, samp, ((vec2<f32>((_e2805.x / _e2809.x), _e2818.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2828 = modelTransform_1;
                                    let _e2829 = c_2;
                                    let _e2833 = u_8;
                                    let _e2836 = tf(_e2828, vec2<f32>((_e2829.x + 1f), _e2833.y));
                                    let _e2840 = global.U[0];
                                    let _e2843 = modelTransform_1;
                                    let _e2844 = c_2;
                                    let _e2848 = u_8;
                                    let _e2851 = tf(_e2843, vec2<f32>((_e2844.x + 1f), _e2848.y));
                                    let _e2860 = textureSample(t_source, samp, ((vec2<f32>((_e2836.x / _e2840.x), _e2851.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e2861 = u_8;
                                    let _e2863 = c_2;
                                    col = mix(_e2827, _e2860, vec4((_e2861.x - _e2863.x)));
                                }
                            }
                        }
                    } else {
                        let _e2868 = dirTop;
                        let _e2869 = dirBottom;
                        let _e2871 = dirLeft;
                        let _e2874 = dirRight;
                        if (((_e2868 && _e2869) && !(_e2871)) && !(_e2874)) {
                            {
                                if false {
                                    {
                                        let _e2878 = modelTransform_1;
                                        let _e2879 = c_2;
                                        let _e2881 = u_8;
                                        let _e2884 = tf(_e2878, vec2<f32>(_e2879.x, _e2881.y));
                                        let _e2888 = global.U[0];
                                        let _e2891 = modelTransform_1;
                                        let _e2892 = c_2;
                                        let _e2894 = u_8;
                                        let _e2897 = tf(_e2891, vec2<f32>(_e2892.x, _e2894.y));
                                        let _e2906 = textureSample(t_source, samp, ((vec2<f32>((_e2884.x / _e2888.x), _e2897.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e2907 = modelTransform_1;
                                        let _e2908 = c_2;
                                        let _e2912 = u_8;
                                        let _e2915 = tf(_e2907, vec2<f32>((_e2908.x + 1f), _e2912.y));
                                        let _e2919 = global.U[0];
                                        let _e2922 = modelTransform_1;
                                        let _e2923 = c_2;
                                        let _e2927 = u_8;
                                        let _e2930 = tf(_e2922, vec2<f32>((_e2923.x + 1f), _e2927.y));
                                        let _e2939 = textureSample(t_source, samp, ((vec2<f32>((_e2915.x / _e2919.x), _e2930.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e2940 = u_8;
                                        let _e2942 = c_2;
                                        col = mix(_e2906, _e2939, vec4((_e2940.x - _e2942.x)));
                                    }
                                } else {
                                    {
                                        let _e2947 = u_8;
                                        let _e2949 = c_2;
                                        X_2 = abs(((_e2947.y - _e2949.y) - 0.5f));
                                        let _e2956 = u_8;
                                        let _e2958 = c_2;
                                        Y_2 = abs(((_e2956.x - _e2958.x) - 0.5f));
                                        let _e2965 = X_2;
                                        let _e2966 = Y_2;
                                        if (_e2965 > _e2966) {
                                            let _e2968 = modelTransform_1;
                                            let _e2969 = c_2;
                                            let _e2973 = X_2;
                                            let _e2975 = u_8;
                                            let _e2978 = tf(_e2968, vec2<f32>(((_e2969.x + 0.5f) - _e2973), _e2975.y));
                                            let _e2982 = global.U[0];
                                            let _e2985 = modelTransform_1;
                                            let _e2986 = c_2;
                                            let _e2990 = X_2;
                                            let _e2992 = u_8;
                                            let _e2995 = tf(_e2985, vec2<f32>(((_e2986.x + 0.5f) - _e2990), _e2992.y));
                                            let _e3004 = textureSample(t_source, samp, ((vec2<f32>((_e2978.x / _e2982.x), _e2995.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3005 = modelTransform_1;
                                            let _e3006 = c_2;
                                            let _e3010 = X_2;
                                            let _e3012 = u_8;
                                            let _e3015 = tf(_e3005, vec2<f32>(((_e3006.x + 0.5f) + _e3010), _e3012.y));
                                            let _e3019 = global.U[0];
                                            let _e3022 = modelTransform_1;
                                            let _e3023 = c_2;
                                            let _e3027 = X_2;
                                            let _e3029 = u_8;
                                            let _e3032 = tf(_e3022, vec2<f32>(((_e3023.x + 0.5f) + _e3027), _e3029.y));
                                            let _e3041 = textureSample(t_source, samp, ((vec2<f32>((_e3015.x / _e3019.x), _e3032.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3042 = u_8;
                                            let _e3044 = c_2;
                                            let _e3049 = X_2;
                                            let _e3052 = X_2;
                                            col = mix(_e3004, _e3041, vec4(((((_e3042.x - _e3044.x) - 0.5f) + _e3049) / (2f * _e3052))));
                                        } else {
                                            let _e3057 = modelTransform_1;
                                            let _e3058 = u_8;
                                            let _e3060 = c_2;
                                            let _e3064 = Y_2;
                                            let _e3067 = tf(_e3057, vec2<f32>(_e3058.x, ((_e3060.y + 0.5f) - _e3064)));
                                            let _e3071 = global.U[0];
                                            let _e3074 = modelTransform_1;
                                            let _e3075 = u_8;
                                            let _e3077 = c_2;
                                            let _e3081 = Y_2;
                                            let _e3084 = tf(_e3074, vec2<f32>(_e3075.x, ((_e3077.y + 0.5f) - _e3081)));
                                            let _e3093 = textureSample(t_source, samp, ((vec2<f32>((_e3067.x / _e3071.x), _e3084.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3094 = modelTransform_1;
                                            let _e3095 = u_8;
                                            let _e3097 = c_2;
                                            let _e3101 = Y_2;
                                            let _e3104 = tf(_e3094, vec2<f32>(_e3095.x, ((_e3097.y + 0.5f) + _e3101)));
                                            let _e3108 = global.U[0];
                                            let _e3111 = modelTransform_1;
                                            let _e3112 = u_8;
                                            let _e3114 = c_2;
                                            let _e3118 = Y_2;
                                            let _e3121 = tf(_e3111, vec2<f32>(_e3112.x, ((_e3114.y + 0.5f) + _e3118)));
                                            let _e3130 = textureSample(t_source, samp, ((vec2<f32>((_e3104.x / _e3108.x), _e3121.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3131 = u_8;
                                            let _e3133 = c_2;
                                            let _e3138 = Y_2;
                                            let _e3141 = Y_2;
                                            col = mix(_e3093, _e3130, vec4(((((_e3131.y - _e3133.y) - 0.5f) + _e3138) / (2f * _e3141))));
                                        }
                                    }
                                }
                            }
                        } else {
                            let _e3146 = dirTop;
                            let _e3148 = dirBottom;
                            let _e3150 = dirLeft;
                            let _e3152 = dirRight;
                            if (((!(_e3146) && _e3148) && _e3150) && !(_e3152)) {
                                {
                                    let _e3155 = c_2;
                                    center_2 = ((_e3155 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                    let _e3178 = u_8;
                                    let _e3179 = center_2;
                                    rel_2 = (_e3178 - _e3179);
                                    let _e3182 = rel_2;
                                    len_2 = length(_e3182);
                                    let _e3185 = len_2;
                                    if (_e3185 < 1f) {
                                        {
                                            let _e3188 = u_8;
                                            let _e3189 = center_2;
                                            let _e3195 = u_8;
                                            let _e3196 = center_2;
                                            a_3 = atan2(dot((_e3188 - _e3189), vec2<f32>(1f, 0f)), dot((_e3195 - _e3196), vec2<f32>(0f, -1f)));
                                            let _e3205 = modelTransform_1;
                                            let _e3206 = center_2;
                                            let _e3207 = len_2;
                                            let _e3214 = tf(_e3205, (_e3206 + (_e3207 * vec2<f32>(0f, -1f))));
                                            let _e3218 = global.U[0];
                                            let _e3221 = modelTransform_1;
                                            let _e3222 = center_2;
                                            let _e3223 = len_2;
                                            let _e3230 = tf(_e3221, (_e3222 + (_e3223 * vec2<f32>(0f, -1f))));
                                            let _e3239 = textureSample(t_source, samp, ((vec2<f32>((_e3214.x / _e3218.x), _e3230.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3240 = modelTransform_1;
                                            let _e3241 = center_2;
                                            let _e3242 = len_2;
                                            let _e3248 = tf(_e3240, (_e3241 + (_e3242 * vec2<f32>(1f, 0f))));
                                            let _e3252 = global.U[0];
                                            let _e3255 = modelTransform_1;
                                            let _e3256 = center_2;
                                            let _e3257 = len_2;
                                            let _e3263 = tf(_e3255, (_e3256 + (_e3257 * vec2<f32>(1f, 0f))));
                                            let _e3272 = textureSample(t_source, samp, ((vec2<f32>((_e3248.x / _e3252.x), _e3263.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e3273 = a_3;
                                            col = mix(_e3239, _e3272, vec4((_e3273 / 1.5707964f)));
                                        }
                                    } else {
                                        {
                                            if false {
                                                {
                                                    let _e3279 = modelTransform_1;
                                                    let _e3280 = c_2;
                                                    let _e3282 = u_8;
                                                    let _e3285 = tf(_e3279, vec2<f32>(_e3280.x, _e3282.y));
                                                    let _e3289 = global.U[0];
                                                    let _e3292 = modelTransform_1;
                                                    let _e3293 = c_2;
                                                    let _e3295 = u_8;
                                                    let _e3298 = tf(_e3292, vec2<f32>(_e3293.x, _e3295.y));
                                                    let _e3307 = textureSample(t_source, samp, ((vec2<f32>((_e3285.x / _e3289.x), _e3298.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3308 = modelTransform_1;
                                                    let _e3309 = c_2;
                                                    let _e3313 = u_8;
                                                    let _e3316 = tf(_e3308, vec2<f32>((_e3309.x + 1f), _e3313.y));
                                                    let _e3320 = global.U[0];
                                                    let _e3323 = modelTransform_1;
                                                    let _e3324 = c_2;
                                                    let _e3328 = u_8;
                                                    let _e3331 = tf(_e3323, vec2<f32>((_e3324.x + 1f), _e3328.y));
                                                    let _e3340 = textureSample(t_source, samp, ((vec2<f32>((_e3316.x / _e3320.x), _e3331.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3341 = u_8;
                                                    let _e3343 = c_2;
                                                    col = mix(_e3307, _e3340, vec4((_e3341.x - _e3343.x)));
                                                }
                                            } else {
                                                {
                                                    let _e3348 = modelTransform_1;
                                                    let _e3349 = c_2;
                                                    let _e3351 = u_8;
                                                    let _e3354 = tf(_e3348, vec2<f32>(_e3349.x, _e3351.y));
                                                    let _e3358 = global.U[0];
                                                    let _e3361 = modelTransform_1;
                                                    let _e3362 = c_2;
                                                    let _e3364 = u_8;
                                                    let _e3367 = tf(_e3361, vec2<f32>(_e3362.x, _e3364.y));
                                                    let _e3376 = textureSample(t_source, samp, ((vec2<f32>((_e3354.x / _e3358.x), _e3367.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3377 = modelTransform_1;
                                                    let _e3378 = c_2;
                                                    let _e3382 = u_8;
                                                    let _e3385 = tf(_e3377, vec2<f32>((_e3378.x + 1f), _e3382.y));
                                                    let _e3389 = global.U[0];
                                                    let _e3392 = modelTransform_1;
                                                    let _e3393 = c_2;
                                                    let _e3397 = u_8;
                                                    let _e3400 = tf(_e3392, vec2<f32>((_e3393.x + 1f), _e3397.y));
                                                    let _e3409 = textureSample(t_source, samp, ((vec2<f32>((_e3385.x / _e3389.x), _e3400.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3410 = u_8;
                                                    let _e3412 = c_2;
                                                    col = mix(_e3376, _e3409, vec4((_e3410.x - _e3412.x)));
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                let _e3417 = dirTop;
                                let _e3418 = dirBottom;
                                let _e3421 = dirLeft;
                                let _e3423 = dirRight;
                                if (((_e3417 && !(_e3418)) && _e3421) && !(_e3423)) {
                                    {
                                        let _e3426 = c_2;
                                        center_3 = ((_e3426 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                        let _e3448 = u_8;
                                        let _e3449 = center_3;
                                        rel_3 = (_e3448 - _e3449);
                                        let _e3452 = rel_3;
                                        len_3 = length(_e3452);
                                        let _e3455 = len_3;
                                        if (_e3455 < 1f) {
                                            {
                                                let _e3458 = u_8;
                                                let _e3459 = center_3;
                                                let _e3465 = u_8;
                                                let _e3466 = center_3;
                                                a_4 = atan2(dot((_e3458 - _e3459), vec2<f32>(0f, 1f)), dot((_e3465 - _e3466), vec2<f32>(1f, 0f)));
                                                let _e3474 = modelTransform_1;
                                                let _e3475 = center_3;
                                                let _e3476 = len_3;
                                                let _e3482 = tf(_e3474, (_e3475 + (_e3476 * vec2<f32>(1f, 0f))));
                                                let _e3486 = global.U[0];
                                                let _e3489 = modelTransform_1;
                                                let _e3490 = center_3;
                                                let _e3491 = len_3;
                                                let _e3497 = tf(_e3489, (_e3490 + (_e3491 * vec2<f32>(1f, 0f))));
                                                let _e3506 = textureSample(t_source, samp, ((vec2<f32>((_e3482.x / _e3486.x), _e3497.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e3507 = modelTransform_1;
                                                let _e3508 = center_3;
                                                let _e3509 = len_3;
                                                let _e3515 = tf(_e3507, (_e3508 + (_e3509 * vec2<f32>(0f, 1f))));
                                                let _e3519 = global.U[0];
                                                let _e3522 = modelTransform_1;
                                                let _e3523 = center_3;
                                                let _e3524 = len_3;
                                                let _e3530 = tf(_e3522, (_e3523 + (_e3524 * vec2<f32>(0f, 1f))));
                                                let _e3539 = textureSample(t_source, samp, ((vec2<f32>((_e3515.x / _e3519.x), _e3530.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e3540 = a_4;
                                                col = mix(_e3506, _e3539, vec4((_e3540 / 1.5707964f)));
                                            }
                                        } else {
                                            {
                                                if false {
                                                    {
                                                        let _e3546 = modelTransform_1;
                                                        let _e3547 = c_2;
                                                        let _e3549 = u_8;
                                                        let _e3552 = tf(_e3546, vec2<f32>(_e3547.x, _e3549.y));
                                                        let _e3556 = global.U[0];
                                                        let _e3559 = modelTransform_1;
                                                        let _e3560 = c_2;
                                                        let _e3562 = u_8;
                                                        let _e3565 = tf(_e3559, vec2<f32>(_e3560.x, _e3562.y));
                                                        let _e3574 = textureSample(t_source, samp, ((vec2<f32>((_e3552.x / _e3556.x), _e3565.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e3575 = modelTransform_1;
                                                        let _e3576 = c_2;
                                                        let _e3580 = u_8;
                                                        let _e3583 = tf(_e3575, vec2<f32>((_e3576.x + 1f), _e3580.y));
                                                        let _e3587 = global.U[0];
                                                        let _e3590 = modelTransform_1;
                                                        let _e3591 = c_2;
                                                        let _e3595 = u_8;
                                                        let _e3598 = tf(_e3590, vec2<f32>((_e3591.x + 1f), _e3595.y));
                                                        let _e3607 = textureSample(t_source, samp, ((vec2<f32>((_e3583.x / _e3587.x), _e3598.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e3608 = u_8;
                                                        let _e3610 = c_2;
                                                        col = mix(_e3574, _e3607, vec4((_e3608.x - _e3610.x)));
                                                    }
                                                } else {
                                                    {
                                                        let _e3615 = modelTransform_1;
                                                        let _e3616 = c_2;
                                                        let _e3618 = u_8;
                                                        let _e3621 = tf(_e3615, vec2<f32>(_e3616.x, _e3618.y));
                                                        let _e3625 = global.U[0];
                                                        let _e3628 = modelTransform_1;
                                                        let _e3629 = c_2;
                                                        let _e3631 = u_8;
                                                        let _e3634 = tf(_e3628, vec2<f32>(_e3629.x, _e3631.y));
                                                        let _e3643 = textureSample(t_source, samp, ((vec2<f32>((_e3621.x / _e3625.x), _e3634.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e3644 = modelTransform_1;
                                                        let _e3645 = c_2;
                                                        let _e3649 = u_8;
                                                        let _e3652 = tf(_e3644, vec2<f32>((_e3645.x + 1f), _e3649.y));
                                                        let _e3656 = global.U[0];
                                                        let _e3659 = modelTransform_1;
                                                        let _e3660 = c_2;
                                                        let _e3664 = u_8;
                                                        let _e3667 = tf(_e3659, vec2<f32>((_e3660.x + 1f), _e3664.y));
                                                        let _e3676 = textureSample(t_source, samp, ((vec2<f32>((_e3652.x / _e3656.x), _e3667.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e3677 = u_8;
                                                        let _e3679 = c_2;
                                                        col = mix(_e3643, _e3676, vec4((_e3677.x - _e3679.x)));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    let _e3684 = dirTop;
                                    let _e3686 = dirBottom;
                                    let _e3688 = dirLeft;
                                    let _e3691 = dirRight;
                                    if (((!(_e3684) && _e3686) && !(_e3688)) && _e3691) {
                                        {
                                            let _e3693 = c_2;
                                            center_4 = ((_e3693 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                            let _e3717 = u_8;
                                            let _e3718 = center_4;
                                            rel_4 = (_e3717 - _e3718);
                                            let _e3721 = rel_4;
                                            len_4 = length(_e3721);
                                            let _e3724 = len_4;
                                            if (_e3724 < 1f) {
                                                {
                                                    let _e3727 = u_8;
                                                    let _e3728 = center_4;
                                                    let _e3735 = u_8;
                                                    let _e3736 = center_4;
                                                    a_5 = atan2(dot((_e3727 - _e3728), vec2<f32>(0f, -1f)), dot((_e3735 - _e3736), vec2<f32>(-1f, 0f)));
                                                    let _e3745 = modelTransform_1;
                                                    let _e3746 = center_4;
                                                    let _e3747 = len_4;
                                                    let _e3754 = tf(_e3745, (_e3746 + (_e3747 * vec2<f32>(-1f, 0f))));
                                                    let _e3758 = global.U[0];
                                                    let _e3761 = modelTransform_1;
                                                    let _e3762 = center_4;
                                                    let _e3763 = len_4;
                                                    let _e3770 = tf(_e3761, (_e3762 + (_e3763 * vec2<f32>(-1f, 0f))));
                                                    let _e3779 = textureSample(t_source, samp, ((vec2<f32>((_e3754.x / _e3758.x), _e3770.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3780 = modelTransform_1;
                                                    let _e3781 = center_4;
                                                    let _e3782 = len_4;
                                                    let _e3789 = tf(_e3780, (_e3781 + (_e3782 * vec2<f32>(0f, -1f))));
                                                    let _e3793 = global.U[0];
                                                    let _e3796 = modelTransform_1;
                                                    let _e3797 = center_4;
                                                    let _e3798 = len_4;
                                                    let _e3805 = tf(_e3796, (_e3797 + (_e3798 * vec2<f32>(0f, -1f))));
                                                    let _e3814 = textureSample(t_source, samp, ((vec2<f32>((_e3789.x / _e3793.x), _e3805.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e3815 = a_5;
                                                    col = mix(_e3779, _e3814, vec4((_e3815 / 1.5707964f)));
                                                }
                                            } else {
                                                {
                                                    if false {
                                                        {
                                                            let _e3821 = modelTransform_1;
                                                            let _e3822 = c_2;
                                                            let _e3824 = u_8;
                                                            let _e3827 = tf(_e3821, vec2<f32>(_e3822.x, _e3824.y));
                                                            let _e3831 = global.U[0];
                                                            let _e3834 = modelTransform_1;
                                                            let _e3835 = c_2;
                                                            let _e3837 = u_8;
                                                            let _e3840 = tf(_e3834, vec2<f32>(_e3835.x, _e3837.y));
                                                            let _e3849 = textureSample(t_source, samp, ((vec2<f32>((_e3827.x / _e3831.x), _e3840.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e3850 = modelTransform_1;
                                                            let _e3851 = c_2;
                                                            let _e3855 = u_8;
                                                            let _e3858 = tf(_e3850, vec2<f32>((_e3851.x + 1f), _e3855.y));
                                                            let _e3862 = global.U[0];
                                                            let _e3865 = modelTransform_1;
                                                            let _e3866 = c_2;
                                                            let _e3870 = u_8;
                                                            let _e3873 = tf(_e3865, vec2<f32>((_e3866.x + 1f), _e3870.y));
                                                            let _e3882 = textureSample(t_source, samp, ((vec2<f32>((_e3858.x / _e3862.x), _e3873.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e3883 = u_8;
                                                            let _e3885 = c_2;
                                                            col = mix(_e3849, _e3882, vec4((_e3883.x - _e3885.x)));
                                                        }
                                                    } else {
                                                        {
                                                            let _e3890 = modelTransform_1;
                                                            let _e3891 = c_2;
                                                            let _e3893 = u_8;
                                                            let _e3896 = tf(_e3890, vec2<f32>(_e3891.x, _e3893.y));
                                                            let _e3900 = global.U[0];
                                                            let _e3903 = modelTransform_1;
                                                            let _e3904 = c_2;
                                                            let _e3906 = u_8;
                                                            let _e3909 = tf(_e3903, vec2<f32>(_e3904.x, _e3906.y));
                                                            let _e3918 = textureSample(t_source, samp, ((vec2<f32>((_e3896.x / _e3900.x), _e3909.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e3919 = modelTransform_1;
                                                            let _e3920 = c_2;
                                                            let _e3924 = u_8;
                                                            let _e3927 = tf(_e3919, vec2<f32>((_e3920.x + 1f), _e3924.y));
                                                            let _e3931 = global.U[0];
                                                            let _e3934 = modelTransform_1;
                                                            let _e3935 = c_2;
                                                            let _e3939 = u_8;
                                                            let _e3942 = tf(_e3934, vec2<f32>((_e3935.x + 1f), _e3939.y));
                                                            let _e3951 = textureSample(t_source, samp, ((vec2<f32>((_e3927.x / _e3931.x), _e3942.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e3952 = u_8;
                                                            let _e3954 = c_2;
                                                            col = mix(_e3918, _e3951, vec4((_e3952.x - _e3954.x)));
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        let _e3959 = dirTop;
                                        let _e3960 = dirBottom;
                                        let _e3963 = dirLeft;
                                        let _e3966 = dirRight;
                                        if (((_e3959 && !(_e3960)) && !(_e3963)) && _e3966) {
                                            {
                                                let _e3968 = c_2;
                                                center_5 = ((_e3968 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                let _e3991 = u_8;
                                                let _e3992 = center_5;
                                                rel_5 = (_e3991 - _e3992);
                                                let _e3995 = rel_5;
                                                len_5 = length(_e3995);
                                                let _e3998 = len_5;
                                                if (_e3998 < 1f) {
                                                    {
                                                        let _e4001 = u_8;
                                                        let _e4002 = center_5;
                                                        let _e4009 = u_8;
                                                        let _e4010 = center_5;
                                                        a_6 = atan2(dot((_e4001 - _e4002), vec2<f32>(-1f, 0f)), dot((_e4009 - _e4010), vec2<f32>(0f, 1f)));
                                                        let _e4018 = modelTransform_1;
                                                        let _e4019 = center_5;
                                                        let _e4020 = len_5;
                                                        let _e4026 = tf(_e4018, (_e4019 + (_e4020 * vec2<f32>(0f, 1f))));
                                                        let _e4030 = global.U[0];
                                                        let _e4033 = modelTransform_1;
                                                        let _e4034 = center_5;
                                                        let _e4035 = len_5;
                                                        let _e4041 = tf(_e4033, (_e4034 + (_e4035 * vec2<f32>(0f, 1f))));
                                                        let _e4050 = textureSample(t_source, samp, ((vec2<f32>((_e4026.x / _e4030.x), _e4041.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4051 = modelTransform_1;
                                                        let _e4052 = center_5;
                                                        let _e4053 = len_5;
                                                        let _e4060 = tf(_e4051, (_e4052 + (_e4053 * vec2<f32>(-1f, 0f))));
                                                        let _e4064 = global.U[0];
                                                        let _e4067 = modelTransform_1;
                                                        let _e4068 = center_5;
                                                        let _e4069 = len_5;
                                                        let _e4076 = tf(_e4067, (_e4068 + (_e4069 * vec2<f32>(-1f, 0f))));
                                                        let _e4085 = textureSample(t_source, samp, ((vec2<f32>((_e4060.x / _e4064.x), _e4076.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4086 = a_6;
                                                        col = mix(_e4050, _e4085, vec4((_e4086 / 1.5707964f)));
                                                    }
                                                } else {
                                                    {
                                                        if false {
                                                            {
                                                                let _e4092 = modelTransform_1;
                                                                let _e4093 = c_2;
                                                                let _e4095 = u_8;
                                                                let _e4098 = tf(_e4092, vec2<f32>(_e4093.x, _e4095.y));
                                                                let _e4102 = global.U[0];
                                                                let _e4105 = modelTransform_1;
                                                                let _e4106 = c_2;
                                                                let _e4108 = u_8;
                                                                let _e4111 = tf(_e4105, vec2<f32>(_e4106.x, _e4108.y));
                                                                let _e4120 = textureSample(t_source, samp, ((vec2<f32>((_e4098.x / _e4102.x), _e4111.y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e4121 = modelTransform_1;
                                                                let _e4122 = c_2;
                                                                let _e4126 = u_8;
                                                                let _e4129 = tf(_e4121, vec2<f32>((_e4122.x + 1f), _e4126.y));
                                                                let _e4133 = global.U[0];
                                                                let _e4136 = modelTransform_1;
                                                                let _e4137 = c_2;
                                                                let _e4141 = u_8;
                                                                let _e4144 = tf(_e4136, vec2<f32>((_e4137.x + 1f), _e4141.y));
                                                                let _e4153 = textureSample(t_source, samp, ((vec2<f32>((_e4129.x / _e4133.x), _e4144.y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e4154 = u_8;
                                                                let _e4156 = c_2;
                                                                col = mix(_e4120, _e4153, vec4((_e4154.x - _e4156.x)));
                                                            }
                                                        } else {
                                                            {
                                                                let _e4161 = modelTransform_1;
                                                                let _e4162 = c_2;
                                                                let _e4164 = u_8;
                                                                let _e4167 = tf(_e4161, vec2<f32>(_e4162.x, _e4164.y));
                                                                let _e4171 = global.U[0];
                                                                let _e4174 = modelTransform_1;
                                                                let _e4175 = c_2;
                                                                let _e4177 = u_8;
                                                                let _e4180 = tf(_e4174, vec2<f32>(_e4175.x, _e4177.y));
                                                                let _e4189 = textureSample(t_source, samp, ((vec2<f32>((_e4167.x / _e4171.x), _e4180.y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e4190 = modelTransform_1;
                                                                let _e4191 = c_2;
                                                                let _e4195 = u_8;
                                                                let _e4198 = tf(_e4190, vec2<f32>((_e4191.x + 1f), _e4195.y));
                                                                let _e4202 = global.U[0];
                                                                let _e4205 = modelTransform_1;
                                                                let _e4206 = c_2;
                                                                let _e4210 = u_8;
                                                                let _e4213 = tf(_e4205, vec2<f32>((_e4206.x + 1f), _e4210.y));
                                                                let _e4222 = textureSample(t_source, samp, ((vec2<f32>((_e4198.x / _e4202.x), _e4213.y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e4223 = u_8;
                                                                let _e4225 = c_2;
                                                                col = mix(_e4189, _e4222, vec4((_e4223.x - _e4225.x)));
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            let _e4230 = dirTop;
                                            let _e4232 = dirBottom;
                                            let _e4235 = dirLeft;
                                            let _e4237 = dirRight;
                                            if (((!(_e4230) && !(_e4232)) && _e4235) && !(_e4237)) {
                                                {
                                                    let _e4240 = c_2;
                                                    let _e4241 = randomSeed_1;
                                                    let _e4242 = regularity_6;
                                                    let _e4243 = rnd2_(_e4240, _e4241, _e4242);
                                                    if (_e4243 < 0.5f) {
                                                        {
                                                            let _e4246 = c_2;
                                                            center_6 = ((_e4246 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                                            let _e4269 = u_8;
                                                            let _e4270 = center_6;
                                                            rel_6 = (_e4269 - _e4270);
                                                            let _e4273 = rel_6;
                                                            len_6 = length(_e4273);
                                                            let _e4276 = len_6;
                                                            if (_e4276 < 1f) {
                                                                {
                                                                    let _e4279 = u_8;
                                                                    let _e4280 = center_6;
                                                                    let _e4286 = u_8;
                                                                    let _e4287 = center_6;
                                                                    a_7 = atan2(dot((_e4279 - _e4280), vec2<f32>(1f, 0f)), dot((_e4286 - _e4287), vec2<f32>(0f, -1f)));
                                                                    let _e4296 = modelTransform_1;
                                                                    let _e4297 = center_6;
                                                                    let _e4298 = len_6;
                                                                    let _e4305 = tf(_e4296, (_e4297 + (_e4298 * vec2<f32>(0f, -1f))));
                                                                    let _e4309 = global.U[0];
                                                                    let _e4312 = modelTransform_1;
                                                                    let _e4313 = center_6;
                                                                    let _e4314 = len_6;
                                                                    let _e4321 = tf(_e4312, (_e4313 + (_e4314 * vec2<f32>(0f, -1f))));
                                                                    let _e4330 = textureSample(t_source, samp, ((vec2<f32>((_e4305.x / _e4309.x), _e4321.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4331 = modelTransform_1;
                                                                    let _e4332 = center_6;
                                                                    let _e4333 = len_6;
                                                                    let _e4339 = tf(_e4331, (_e4332 + (_e4333 * vec2<f32>(1f, 0f))));
                                                                    let _e4343 = global.U[0];
                                                                    let _e4346 = modelTransform_1;
                                                                    let _e4347 = center_6;
                                                                    let _e4348 = len_6;
                                                                    let _e4354 = tf(_e4346, (_e4347 + (_e4348 * vec2<f32>(1f, 0f))));
                                                                    let _e4363 = textureSample(t_source, samp, ((vec2<f32>((_e4339.x / _e4343.x), _e4354.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4364 = a_7;
                                                                    col = mix(_e4330, _e4363, vec4((_e4364 / 1.5707964f)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e4369 = modelTransform_1;
                                                                    let _e4370 = u_8;
                                                                    let _e4372 = c_2;
                                                                    let _e4375 = tf(_e4369, vec2<f32>(_e4370.x, _e4372.y));
                                                                    let _e4379 = global.U[0];
                                                                    let _e4382 = modelTransform_1;
                                                                    let _e4383 = u_8;
                                                                    let _e4385 = c_2;
                                                                    let _e4388 = tf(_e4382, vec2<f32>(_e4383.x, _e4385.y));
                                                                    let _e4397 = textureSample(t_source, samp, ((vec2<f32>((_e4375.x / _e4379.x), _e4388.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4398 = modelTransform_1;
                                                                    let _e4399 = u_8;
                                                                    let _e4401 = c_2;
                                                                    let _e4406 = tf(_e4398, vec2<f32>(_e4399.x, (_e4401.y + 1f)));
                                                                    let _e4410 = global.U[0];
                                                                    let _e4413 = modelTransform_1;
                                                                    let _e4414 = u_8;
                                                                    let _e4416 = c_2;
                                                                    let _e4421 = tf(_e4413, vec2<f32>(_e4414.x, (_e4416.y + 1f)));
                                                                    let _e4430 = textureSample(t_source, samp, ((vec2<f32>((_e4406.x / _e4410.x), _e4421.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4431 = u_8;
                                                                    let _e4433 = c_2;
                                                                    col = mix(_e4397, _e4430, vec4((_e4431.y - _e4433.y)));
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        {
                                                            let _e4438 = c_2;
                                                            center_7 = ((_e4438 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                                            let _e4460 = u_8;
                                                            let _e4461 = center_7;
                                                            rel_7 = (_e4460 - _e4461);
                                                            let _e4464 = rel_7;
                                                            len_7 = length(_e4464);
                                                            let _e4467 = len_7;
                                                            if (_e4467 < 1f) {
                                                                {
                                                                    let _e4470 = u_8;
                                                                    let _e4471 = center_7;
                                                                    let _e4477 = u_8;
                                                                    let _e4478 = center_7;
                                                                    a_8 = atan2(dot((_e4470 - _e4471), vec2<f32>(0f, 1f)), dot((_e4477 - _e4478), vec2<f32>(1f, 0f)));
                                                                    let _e4486 = modelTransform_1;
                                                                    let _e4487 = center_7;
                                                                    let _e4488 = len_7;
                                                                    let _e4494 = tf(_e4486, (_e4487 + (_e4488 * vec2<f32>(1f, 0f))));
                                                                    let _e4498 = global.U[0];
                                                                    let _e4501 = modelTransform_1;
                                                                    let _e4502 = center_7;
                                                                    let _e4503 = len_7;
                                                                    let _e4509 = tf(_e4501, (_e4502 + (_e4503 * vec2<f32>(1f, 0f))));
                                                                    let _e4518 = textureSample(t_source, samp, ((vec2<f32>((_e4494.x / _e4498.x), _e4509.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4519 = modelTransform_1;
                                                                    let _e4520 = center_7;
                                                                    let _e4521 = len_7;
                                                                    let _e4527 = tf(_e4519, (_e4520 + (_e4521 * vec2<f32>(0f, 1f))));
                                                                    let _e4531 = global.U[0];
                                                                    let _e4534 = modelTransform_1;
                                                                    let _e4535 = center_7;
                                                                    let _e4536 = len_7;
                                                                    let _e4542 = tf(_e4534, (_e4535 + (_e4536 * vec2<f32>(0f, 1f))));
                                                                    let _e4551 = textureSample(t_source, samp, ((vec2<f32>((_e4527.x / _e4531.x), _e4542.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4552 = a_8;
                                                                    col = mix(_e4518, _e4551, vec4((_e4552 / 1.5707964f)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e4557 = modelTransform_1;
                                                                    let _e4558 = u_8;
                                                                    let _e4560 = c_2;
                                                                    let _e4563 = tf(_e4557, vec2<f32>(_e4558.x, _e4560.y));
                                                                    let _e4567 = global.U[0];
                                                                    let _e4570 = modelTransform_1;
                                                                    let _e4571 = u_8;
                                                                    let _e4573 = c_2;
                                                                    let _e4576 = tf(_e4570, vec2<f32>(_e4571.x, _e4573.y));
                                                                    let _e4585 = textureSample(t_source, samp, ((vec2<f32>((_e4563.x / _e4567.x), _e4576.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4586 = modelTransform_1;
                                                                    let _e4587 = u_8;
                                                                    let _e4589 = c_2;
                                                                    let _e4594 = tf(_e4586, vec2<f32>(_e4587.x, (_e4589.y + 1f)));
                                                                    let _e4598 = global.U[0];
                                                                    let _e4601 = modelTransform_1;
                                                                    let _e4602 = u_8;
                                                                    let _e4604 = c_2;
                                                                    let _e4609 = tf(_e4601, vec2<f32>(_e4602.x, (_e4604.y + 1f)));
                                                                    let _e4618 = textureSample(t_source, samp, ((vec2<f32>((_e4594.x / _e4598.x), _e4609.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4619 = u_8;
                                                                    let _e4621 = c_2;
                                                                    col = mix(_e4585, _e4618, vec4((_e4619.y - _e4621.y)));
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e4626 = dirTop;
                                                let _e4628 = dirBottom;
                                                let _e4631 = dirLeft;
                                                let _e4634 = dirRight;
                                                if (((!(_e4626) && !(_e4628)) && !(_e4631)) && _e4634) {
                                                    {
                                                        let _e4636 = c_2;
                                                        let _e4637 = randomSeed_1;
                                                        let _e4638 = regularity_6;
                                                        let _e4639 = rnd2_(_e4636, _e4637, _e4638);
                                                        if (_e4639 < 0.5f) {
                                                            {
                                                                let _e4642 = c_2;
                                                                center_8 = ((_e4642 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                                let _e4665 = u_8;
                                                                let _e4666 = center_8;
                                                                rel_8 = (_e4665 - _e4666);
                                                                let _e4669 = rel_8;
                                                                len_8 = length(_e4669);
                                                                let _e4672 = len_8;
                                                                if (_e4672 < 1f) {
                                                                    {
                                                                        let _e4675 = u_8;
                                                                        let _e4676 = center_8;
                                                                        let _e4683 = u_8;
                                                                        let _e4684 = center_8;
                                                                        a_9 = atan2(dot((_e4675 - _e4676), vec2<f32>(-1f, 0f)), dot((_e4683 - _e4684), vec2<f32>(0f, 1f)));
                                                                        let _e4692 = modelTransform_1;
                                                                        let _e4693 = center_8;
                                                                        let _e4694 = len_8;
                                                                        let _e4700 = tf(_e4692, (_e4693 + (_e4694 * vec2<f32>(0f, 1f))));
                                                                        let _e4704 = global.U[0];
                                                                        let _e4707 = modelTransform_1;
                                                                        let _e4708 = center_8;
                                                                        let _e4709 = len_8;
                                                                        let _e4715 = tf(_e4707, (_e4708 + (_e4709 * vec2<f32>(0f, 1f))));
                                                                        let _e4724 = textureSample(t_source, samp, ((vec2<f32>((_e4700.x / _e4704.x), _e4715.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4725 = modelTransform_1;
                                                                        let _e4726 = center_8;
                                                                        let _e4727 = len_8;
                                                                        let _e4734 = tf(_e4725, (_e4726 + (_e4727 * vec2<f32>(-1f, 0f))));
                                                                        let _e4738 = global.U[0];
                                                                        let _e4741 = modelTransform_1;
                                                                        let _e4742 = center_8;
                                                                        let _e4743 = len_8;
                                                                        let _e4750 = tf(_e4741, (_e4742 + (_e4743 * vec2<f32>(-1f, 0f))));
                                                                        let _e4759 = textureSample(t_source, samp, ((vec2<f32>((_e4734.x / _e4738.x), _e4750.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4760 = a_9;
                                                                        col = mix(_e4724, _e4759, vec4((_e4760 / 1.5707964f)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e4765 = modelTransform_1;
                                                                        let _e4766 = u_8;
                                                                        let _e4768 = c_2;
                                                                        let _e4771 = tf(_e4765, vec2<f32>(_e4766.x, _e4768.y));
                                                                        let _e4775 = global.U[0];
                                                                        let _e4778 = modelTransform_1;
                                                                        let _e4779 = u_8;
                                                                        let _e4781 = c_2;
                                                                        let _e4784 = tf(_e4778, vec2<f32>(_e4779.x, _e4781.y));
                                                                        let _e4793 = textureSample(t_source, samp, ((vec2<f32>((_e4771.x / _e4775.x), _e4784.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4794 = modelTransform_1;
                                                                        let _e4795 = u_8;
                                                                        let _e4797 = c_2;
                                                                        let _e4802 = tf(_e4794, vec2<f32>(_e4795.x, (_e4797.y + 1f)));
                                                                        let _e4806 = global.U[0];
                                                                        let _e4809 = modelTransform_1;
                                                                        let _e4810 = u_8;
                                                                        let _e4812 = c_2;
                                                                        let _e4817 = tf(_e4809, vec2<f32>(_e4810.x, (_e4812.y + 1f)));
                                                                        let _e4826 = textureSample(t_source, samp, ((vec2<f32>((_e4802.x / _e4806.x), _e4817.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4827 = u_8;
                                                                        let _e4829 = c_2;
                                                                        col = mix(_e4793, _e4826, vec4((_e4827.y - _e4829.y)));
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            {
                                                                let _e4834 = c_2;
                                                                center_9 = ((_e4834 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                                                let _e4858 = u_8;
                                                                let _e4859 = center_9;
                                                                rel_9 = (_e4858 - _e4859);
                                                                let _e4862 = rel_9;
                                                                len_9 = length(_e4862);
                                                                let _e4865 = len_9;
                                                                if (_e4865 < 1f) {
                                                                    {
                                                                        let _e4868 = u_8;
                                                                        let _e4869 = center_9;
                                                                        let _e4876 = u_8;
                                                                        let _e4877 = center_9;
                                                                        a_10 = atan2(dot((_e4868 - _e4869), vec2<f32>(0f, -1f)), dot((_e4876 - _e4877), vec2<f32>(-1f, 0f)));
                                                                        let _e4886 = modelTransform_1;
                                                                        let _e4887 = center_9;
                                                                        let _e4888 = len_9;
                                                                        let _e4895 = tf(_e4886, (_e4887 + (_e4888 * vec2<f32>(-1f, 0f))));
                                                                        let _e4899 = global.U[0];
                                                                        let _e4902 = modelTransform_1;
                                                                        let _e4903 = center_9;
                                                                        let _e4904 = len_9;
                                                                        let _e4911 = tf(_e4902, (_e4903 + (_e4904 * vec2<f32>(-1f, 0f))));
                                                                        let _e4920 = textureSample(t_source, samp, ((vec2<f32>((_e4895.x / _e4899.x), _e4911.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4921 = modelTransform_1;
                                                                        let _e4922 = center_9;
                                                                        let _e4923 = len_9;
                                                                        let _e4930 = tf(_e4921, (_e4922 + (_e4923 * vec2<f32>(0f, -1f))));
                                                                        let _e4934 = global.U[0];
                                                                        let _e4937 = modelTransform_1;
                                                                        let _e4938 = center_9;
                                                                        let _e4939 = len_9;
                                                                        let _e4946 = tf(_e4937, (_e4938 + (_e4939 * vec2<f32>(0f, -1f))));
                                                                        let _e4955 = textureSample(t_source, samp, ((vec2<f32>((_e4930.x / _e4934.x), _e4946.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4956 = a_10;
                                                                        col = mix(_e4920, _e4955, vec4((_e4956 / 1.5707964f)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e4961 = modelTransform_1;
                                                                        let _e4962 = u_8;
                                                                        let _e4964 = c_2;
                                                                        let _e4967 = tf(_e4961, vec2<f32>(_e4962.x, _e4964.y));
                                                                        let _e4971 = global.U[0];
                                                                        let _e4974 = modelTransform_1;
                                                                        let _e4975 = u_8;
                                                                        let _e4977 = c_2;
                                                                        let _e4980 = tf(_e4974, vec2<f32>(_e4975.x, _e4977.y));
                                                                        let _e4989 = textureSample(t_source, samp, ((vec2<f32>((_e4967.x / _e4971.x), _e4980.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4990 = modelTransform_1;
                                                                        let _e4991 = u_8;
                                                                        let _e4993 = c_2;
                                                                        let _e4998 = tf(_e4990, vec2<f32>(_e4991.x, (_e4993.y + 1f)));
                                                                        let _e5002 = global.U[0];
                                                                        let _e5005 = modelTransform_1;
                                                                        let _e5006 = u_8;
                                                                        let _e5008 = c_2;
                                                                        let _e5013 = tf(_e5005, vec2<f32>(_e5006.x, (_e5008.y + 1f)));
                                                                        let _e5022 = textureSample(t_source, samp, ((vec2<f32>((_e4998.x / _e5002.x), _e5013.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e5023 = u_8;
                                                                        let _e5025 = c_2;
                                                                        col = mix(_e4989, _e5022, vec4((_e5023.y - _e5025.y)));
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e5030 = dirTop;
                                                    let _e5031 = dirBottom;
                                                    let _e5034 = dirLeft;
                                                    let _e5037 = dirRight;
                                                    if (((_e5030 && !(_e5031)) && !(_e5034)) && !(_e5037)) {
                                                        {
                                                            if false {
                                                                {
                                                                    let _e5041 = modelTransform_1;
                                                                    let _e5042 = u_8;
                                                                    let _e5044 = c_2;
                                                                    let _e5047 = tf(_e5041, vec2<f32>(_e5042.x, _e5044.y));
                                                                    let _e5051 = global.U[0];
                                                                    let _e5054 = modelTransform_1;
                                                                    let _e5055 = u_8;
                                                                    let _e5057 = c_2;
                                                                    let _e5060 = tf(_e5054, vec2<f32>(_e5055.x, _e5057.y));
                                                                    let _e5069 = textureSample(t_source, samp, ((vec2<f32>((_e5047.x / _e5051.x), _e5060.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e5070 = modelTransform_1;
                                                                    let _e5071 = u_8;
                                                                    let _e5073 = c_2;
                                                                    let _e5078 = tf(_e5070, vec2<f32>(_e5071.x, (_e5073.y + 1f)));
                                                                    let _e5082 = global.U[0];
                                                                    let _e5085 = modelTransform_1;
                                                                    let _e5086 = u_8;
                                                                    let _e5088 = c_2;
                                                                    let _e5093 = tf(_e5085, vec2<f32>(_e5086.x, (_e5088.y + 1f)));
                                                                    let _e5102 = textureSample(t_source, samp, ((vec2<f32>((_e5078.x / _e5082.x), _e5093.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e5103 = u_8;
                                                                    let _e5105 = c_2;
                                                                    col = mix(_e5069, _e5102, vec4((_e5103.y - _e5105.y)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e5110 = c_2;
                                                                    let _e5114 = u_8;
                                                                    let _e5116 = c_2;
                                                                    Y_3 = ((_e5110.y + 0.5f) + abs(((_e5114.x - _e5116.x) - 0.5f)));
                                                                    let _e5124 = u_8;
                                                                    let _e5126 = Y_3;
                                                                    if (_e5124.y < _e5126) {
                                                                        let _e5128 = modelTransform_1;
                                                                        let _e5129 = u_8;
                                                                        let _e5131 = c_2;
                                                                        let _e5134 = tf(_e5128, vec2<f32>(_e5129.x, _e5131.y));
                                                                        let _e5138 = global.U[0];
                                                                        let _e5141 = modelTransform_1;
                                                                        let _e5142 = u_8;
                                                                        let _e5144 = c_2;
                                                                        let _e5147 = tf(_e5141, vec2<f32>(_e5142.x, _e5144.y));
                                                                        let _e5156 = textureSample(t_source, samp, ((vec2<f32>((_e5134.x / _e5138.x), _e5147.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e5157 = modelTransform_1;
                                                                        let _e5158 = u_8;
                                                                        let _e5160 = Y_3;
                                                                        let _e5162 = tf(_e5157, vec2<f32>(_e5158.x, _e5160));
                                                                        let _e5166 = global.U[0];
                                                                        let _e5169 = modelTransform_1;
                                                                        let _e5170 = u_8;
                                                                        let _e5172 = Y_3;
                                                                        let _e5174 = tf(_e5169, vec2<f32>(_e5170.x, _e5172));
                                                                        let _e5183 = textureSample(t_source, samp, ((vec2<f32>((_e5162.x / _e5166.x), _e5174.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e5184 = u_8;
                                                                        let _e5186 = c_2;
                                                                        let _e5189 = Y_3;
                                                                        let _e5190 = c_2;
                                                                        col = mix(_e5156, _e5183, vec4(((_e5184.y - _e5186.y) / (_e5189 - _e5190.y))));
                                                                    } else {
                                                                        {
                                                                            let _e5196 = u_8;
                                                                            let _e5198 = c_2;
                                                                            X_3 = abs(((_e5196.y - _e5198.y) - 0.5f));
                                                                            let _e5205 = modelTransform_1;
                                                                            let _e5206 = c_2;
                                                                            let _e5210 = X_3;
                                                                            let _e5212 = u_8;
                                                                            let _e5215 = tf(_e5205, vec2<f32>(((_e5206.x + 0.5f) - _e5210), _e5212.y));
                                                                            let _e5219 = global.U[0];
                                                                            let _e5222 = modelTransform_1;
                                                                            let _e5223 = c_2;
                                                                            let _e5227 = X_3;
                                                                            let _e5229 = u_8;
                                                                            let _e5232 = tf(_e5222, vec2<f32>(((_e5223.x + 0.5f) - _e5227), _e5229.y));
                                                                            let _e5241 = textureSample(t_source, samp, ((vec2<f32>((_e5215.x / _e5219.x), _e5232.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e5242 = modelTransform_1;
                                                                            let _e5243 = c_2;
                                                                            let _e5247 = X_3;
                                                                            let _e5249 = u_8;
                                                                            let _e5252 = tf(_e5242, vec2<f32>(((_e5243.x + 0.5f) + _e5247), _e5249.y));
                                                                            let _e5256 = global.U[0];
                                                                            let _e5259 = modelTransform_1;
                                                                            let _e5260 = c_2;
                                                                            let _e5264 = X_3;
                                                                            let _e5266 = u_8;
                                                                            let _e5269 = tf(_e5259, vec2<f32>(((_e5260.x + 0.5f) + _e5264), _e5266.y));
                                                                            let _e5278 = textureSample(t_source, samp, ((vec2<f32>((_e5252.x / _e5256.x), _e5269.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e5279 = u_8;
                                                                            let _e5281 = c_2;
                                                                            let _e5286 = X_3;
                                                                            let _e5289 = X_3;
                                                                            col = mix(_e5241, _e5278, vec4(((((_e5279.x - _e5281.x) - 0.5f) + _e5286) / (2f * _e5289))));
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e5294 = dirTop;
                                                        let _e5296 = dirBottom;
                                                        let _e5298 = dirLeft;
                                                        let _e5301 = dirRight;
                                                        if (((!(_e5294) && _e5296) && !(_e5298)) && !(_e5301)) {
                                                            {
                                                                if false {
                                                                    {
                                                                        let _e5305 = modelTransform_1;
                                                                        let _e5306 = u_8;
                                                                        let _e5308 = c_2;
                                                                        let _e5311 = tf(_e5305, vec2<f32>(_e5306.x, _e5308.y));
                                                                        let _e5315 = global.U[0];
                                                                        let _e5318 = modelTransform_1;
                                                                        let _e5319 = u_8;
                                                                        let _e5321 = c_2;
                                                                        let _e5324 = tf(_e5318, vec2<f32>(_e5319.x, _e5321.y));
                                                                        let _e5333 = textureSample(t_source, samp, ((vec2<f32>((_e5311.x / _e5315.x), _e5324.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e5334 = modelTransform_1;
                                                                        let _e5335 = u_8;
                                                                        let _e5337 = c_2;
                                                                        let _e5342 = tf(_e5334, vec2<f32>(_e5335.x, (_e5337.y + 1f)));
                                                                        let _e5346 = global.U[0];
                                                                        let _e5349 = modelTransform_1;
                                                                        let _e5350 = u_8;
                                                                        let _e5352 = c_2;
                                                                        let _e5357 = tf(_e5349, vec2<f32>(_e5350.x, (_e5352.y + 1f)));
                                                                        let _e5366 = textureSample(t_source, samp, ((vec2<f32>((_e5342.x / _e5346.x), _e5357.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e5367 = u_8;
                                                                        let _e5369 = c_2;
                                                                        col = mix(_e5333, _e5366, vec4((_e5367.y - _e5369.y)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e5374 = c_2;
                                                                        let _e5378 = u_8;
                                                                        let _e5380 = c_2;
                                                                        Y_4 = ((_e5374.y + 0.5f) - abs(((_e5378.x - _e5380.x) - 0.5f)));
                                                                        let _e5388 = u_8;
                                                                        let _e5390 = Y_4;
                                                                        if (_e5388.y > _e5390) {
                                                                            let _e5392 = modelTransform_1;
                                                                            let _e5393 = u_8;
                                                                            let _e5395 = Y_4;
                                                                            let _e5397 = tf(_e5392, vec2<f32>(_e5393.x, _e5395));
                                                                            let _e5401 = global.U[0];
                                                                            let _e5404 = modelTransform_1;
                                                                            let _e5405 = u_8;
                                                                            let _e5407 = Y_4;
                                                                            let _e5409 = tf(_e5404, vec2<f32>(_e5405.x, _e5407));
                                                                            let _e5418 = textureSample(t_source, samp, ((vec2<f32>((_e5397.x / _e5401.x), _e5409.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e5419 = modelTransform_1;
                                                                            let _e5420 = u_8;
                                                                            let _e5422 = c_2;
                                                                            let _e5427 = tf(_e5419, vec2<f32>(_e5420.x, (_e5422.y + 1f)));
                                                                            let _e5431 = global.U[0];
                                                                            let _e5434 = modelTransform_1;
                                                                            let _e5435 = u_8;
                                                                            let _e5437 = c_2;
                                                                            let _e5442 = tf(_e5434, vec2<f32>(_e5435.x, (_e5437.y + 1f)));
                                                                            let _e5451 = textureSample(t_source, samp, ((vec2<f32>((_e5427.x / _e5431.x), _e5442.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e5452 = u_8;
                                                                            let _e5454 = Y_4;
                                                                            let _e5456 = c_2;
                                                                            let _e5460 = Y_4;
                                                                            col = mix(_e5418, _e5451, vec4(((_e5452.y - _e5454) / ((_e5456.y + 1f) - _e5460))));
                                                                        } else {
                                                                            {
                                                                                let _e5465 = u_8;
                                                                                let _e5467 = c_2;
                                                                                X_4 = abs(((_e5465.y - _e5467.y) - 0.5f));
                                                                                let _e5474 = modelTransform_1;
                                                                                let _e5475 = c_2;
                                                                                let _e5479 = X_4;
                                                                                let _e5481 = u_8;
                                                                                let _e5484 = tf(_e5474, vec2<f32>(((_e5475.x + 0.5f) - _e5479), _e5481.y));
                                                                                let _e5488 = global.U[0];
                                                                                let _e5491 = modelTransform_1;
                                                                                let _e5492 = c_2;
                                                                                let _e5496 = X_4;
                                                                                let _e5498 = u_8;
                                                                                let _e5501 = tf(_e5491, vec2<f32>(((_e5492.x + 0.5f) - _e5496), _e5498.y));
                                                                                let _e5510 = textureSample(t_source, samp, ((vec2<f32>((_e5484.x / _e5488.x), _e5501.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5511 = modelTransform_1;
                                                                                let _e5512 = c_2;
                                                                                let _e5516 = X_4;
                                                                                let _e5518 = u_8;
                                                                                let _e5521 = tf(_e5511, vec2<f32>(((_e5512.x + 0.5f) + _e5516), _e5518.y));
                                                                                let _e5525 = global.U[0];
                                                                                let _e5528 = modelTransform_1;
                                                                                let _e5529 = c_2;
                                                                                let _e5533 = X_4;
                                                                                let _e5535 = u_8;
                                                                                let _e5538 = tf(_e5528, vec2<f32>(((_e5529.x + 0.5f) + _e5533), _e5535.y));
                                                                                let _e5547 = textureSample(t_source, samp, ((vec2<f32>((_e5521.x / _e5525.x), _e5538.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5548 = u_8;
                                                                                let _e5550 = c_2;
                                                                                let _e5555 = X_4;
                                                                                let _e5558 = X_4;
                                                                                col = mix(_e5510, _e5547, vec4(((((_e5548.x - _e5550.x) - 0.5f) + _e5555) / (2f * _e5558))));
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e5563 = dirTop;
                                                            let _e5565 = dirBottom;
                                                            let _e5568 = dirLeft;
                                                            let _e5570 = dirRight;
                                                            if (((!(_e5563) && !(_e5565)) && _e5568) && _e5570) {
                                                                {
                                                                    {
                                                                        let _e5576 = c_2;
                                                                        center_10 = ((_e5576 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                                                        let _e5598 = u_8;
                                                                        let _e5599 = center_10;
                                                                        rel_10 = (_e5598 - _e5599);
                                                                        let _e5602 = rel_10;
                                                                        len_10 = length(_e5602);
                                                                        let _e5605 = len_10;
                                                                        if (_e5605 < 1f) {
                                                                            {
                                                                                let _e5608 = u_8;
                                                                                let _e5609 = center_10;
                                                                                let _e5615 = u_8;
                                                                                let _e5616 = center_10;
                                                                                a_11 = atan2(dot((_e5608 - _e5609), vec2<f32>(0f, 1f)), dot((_e5615 - _e5616), vec2<f32>(1f, 0f)));
                                                                                let _e5624 = modelTransform_1;
                                                                                let _e5625 = center_10;
                                                                                let _e5626 = len_10;
                                                                                let _e5632 = tf(_e5624, (_e5625 + (_e5626 * vec2<f32>(1f, 0f))));
                                                                                let _e5636 = global.U[0];
                                                                                let _e5639 = modelTransform_1;
                                                                                let _e5640 = center_10;
                                                                                let _e5641 = len_10;
                                                                                let _e5647 = tf(_e5639, (_e5640 + (_e5641 * vec2<f32>(1f, 0f))));
                                                                                let _e5656 = textureSample(t_source, samp, ((vec2<f32>((_e5632.x / _e5636.x), _e5647.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5657 = modelTransform_1;
                                                                                let _e5658 = center_10;
                                                                                let _e5659 = len_10;
                                                                                let _e5665 = tf(_e5657, (_e5658 + (_e5659 * vec2<f32>(0f, 1f))));
                                                                                let _e5669 = global.U[0];
                                                                                let _e5672 = modelTransform_1;
                                                                                let _e5673 = center_10;
                                                                                let _e5674 = len_10;
                                                                                let _e5680 = tf(_e5672, (_e5673 + (_e5674 * vec2<f32>(0f, 1f))));
                                                                                let _e5689 = textureSample(t_source, samp, ((vec2<f32>((_e5665.x / _e5669.x), _e5680.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5690 = a_11;
                                                                                col1_ = mix(_e5656, _e5689, vec4((_e5690 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col1_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e5697 = c_2;
                                                                        center_11 = ((_e5697 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                                                        let _e5720 = u_8;
                                                                        let _e5721 = center_11;
                                                                        rel_11 = (_e5720 - _e5721);
                                                                        let _e5724 = rel_11;
                                                                        len_11 = length(_e5724);
                                                                        let _e5727 = len_11;
                                                                        if (_e5727 < 1f) {
                                                                            {
                                                                                let _e5730 = u_8;
                                                                                let _e5731 = center_11;
                                                                                let _e5737 = u_8;
                                                                                let _e5738 = center_11;
                                                                                a_12 = atan2(dot((_e5730 - _e5731), vec2<f32>(1f, 0f)), dot((_e5737 - _e5738), vec2<f32>(0f, -1f)));
                                                                                let _e5747 = modelTransform_1;
                                                                                let _e5748 = center_11;
                                                                                let _e5749 = len_11;
                                                                                let _e5756 = tf(_e5747, (_e5748 + (_e5749 * vec2<f32>(0f, -1f))));
                                                                                let _e5760 = global.U[0];
                                                                                let _e5763 = modelTransform_1;
                                                                                let _e5764 = center_11;
                                                                                let _e5765 = len_11;
                                                                                let _e5772 = tf(_e5763, (_e5764 + (_e5765 * vec2<f32>(0f, -1f))));
                                                                                let _e5781 = textureSample(t_source, samp, ((vec2<f32>((_e5756.x / _e5760.x), _e5772.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5782 = modelTransform_1;
                                                                                let _e5783 = center_11;
                                                                                let _e5784 = len_11;
                                                                                let _e5790 = tf(_e5782, (_e5783 + (_e5784 * vec2<f32>(1f, 0f))));
                                                                                let _e5794 = global.U[0];
                                                                                let _e5797 = modelTransform_1;
                                                                                let _e5798 = center_11;
                                                                                let _e5799 = len_11;
                                                                                let _e5805 = tf(_e5797, (_e5798 + (_e5799 * vec2<f32>(1f, 0f))));
                                                                                let _e5814 = textureSample(t_source, samp, ((vec2<f32>((_e5790.x / _e5794.x), _e5805.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5815 = a_12;
                                                                                col2_ = mix(_e5781, _e5814, vec4((_e5815 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col2_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e5822 = c_2;
                                                                        center_12 = ((_e5822 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                                                        let _e5846 = u_8;
                                                                        let _e5847 = center_12;
                                                                        rel_12 = (_e5846 - _e5847);
                                                                        let _e5850 = rel_12;
                                                                        len_12 = length(_e5850);
                                                                        let _e5853 = len_12;
                                                                        if (_e5853 < 1f) {
                                                                            {
                                                                                let _e5856 = u_8;
                                                                                let _e5857 = center_12;
                                                                                let _e5864 = u_8;
                                                                                let _e5865 = center_12;
                                                                                a_13 = atan2(dot((_e5856 - _e5857), vec2<f32>(0f, -1f)), dot((_e5864 - _e5865), vec2<f32>(-1f, 0f)));
                                                                                let _e5874 = modelTransform_1;
                                                                                let _e5875 = center_12;
                                                                                let _e5876 = len_12;
                                                                                let _e5883 = tf(_e5874, (_e5875 + (_e5876 * vec2<f32>(-1f, 0f))));
                                                                                let _e5887 = global.U[0];
                                                                                let _e5890 = modelTransform_1;
                                                                                let _e5891 = center_12;
                                                                                let _e5892 = len_12;
                                                                                let _e5899 = tf(_e5890, (_e5891 + (_e5892 * vec2<f32>(-1f, 0f))));
                                                                                let _e5908 = textureSample(t_source, samp, ((vec2<f32>((_e5883.x / _e5887.x), _e5899.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5909 = modelTransform_1;
                                                                                let _e5910 = center_12;
                                                                                let _e5911 = len_12;
                                                                                let _e5918 = tf(_e5909, (_e5910 + (_e5911 * vec2<f32>(0f, -1f))));
                                                                                let _e5922 = global.U[0];
                                                                                let _e5925 = modelTransform_1;
                                                                                let _e5926 = center_12;
                                                                                let _e5927 = len_12;
                                                                                let _e5934 = tf(_e5925, (_e5926 + (_e5927 * vec2<f32>(0f, -1f))));
                                                                                let _e5943 = textureSample(t_source, samp, ((vec2<f32>((_e5918.x / _e5922.x), _e5934.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5944 = a_13;
                                                                                col3_ = mix(_e5908, _e5943, vec4((_e5944 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col3_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e5951 = c_2;
                                                                        center_13 = ((_e5951 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                                        let _e5974 = u_8;
                                                                        let _e5975 = center_13;
                                                                        rel_13 = (_e5974 - _e5975);
                                                                        let _e5978 = rel_13;
                                                                        len_13 = length(_e5978);
                                                                        let _e5981 = len_13;
                                                                        if (_e5981 < 1f) {
                                                                            {
                                                                                let _e5984 = u_8;
                                                                                let _e5985 = center_13;
                                                                                let _e5992 = u_8;
                                                                                let _e5993 = center_13;
                                                                                a_14 = atan2(dot((_e5984 - _e5985), vec2<f32>(-1f, 0f)), dot((_e5992 - _e5993), vec2<f32>(0f, 1f)));
                                                                                let _e6001 = modelTransform_1;
                                                                                let _e6002 = center_13;
                                                                                let _e6003 = len_13;
                                                                                let _e6009 = tf(_e6001, (_e6002 + (_e6003 * vec2<f32>(0f, 1f))));
                                                                                let _e6013 = global.U[0];
                                                                                let _e6016 = modelTransform_1;
                                                                                let _e6017 = center_13;
                                                                                let _e6018 = len_13;
                                                                                let _e6024 = tf(_e6016, (_e6017 + (_e6018 * vec2<f32>(0f, 1f))));
                                                                                let _e6033 = textureSample(t_source, samp, ((vec2<f32>((_e6009.x / _e6013.x), _e6024.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e6034 = modelTransform_1;
                                                                                let _e6035 = center_13;
                                                                                let _e6036 = len_13;
                                                                                let _e6043 = tf(_e6034, (_e6035 + (_e6036 * vec2<f32>(-1f, 0f))));
                                                                                let _e6047 = global.U[0];
                                                                                let _e6050 = modelTransform_1;
                                                                                let _e6051 = center_13;
                                                                                let _e6052 = len_13;
                                                                                let _e6059 = tf(_e6050, (_e6051 + (_e6052 * vec2<f32>(-1f, 0f))));
                                                                                let _e6068 = textureSample(t_source, samp, ((vec2<f32>((_e6043.x / _e6047.x), _e6059.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e6069 = a_14;
                                                                                col4_ = mix(_e6033, _e6068, vec4((_e6069 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col4_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    let _e6076 = col1_;
                                                                    let _e6077 = col2_;
                                                                    let _e6078 = col3_;
                                                                    let _e6079 = col4_;
                                                                    cols = mat4x4<f32>(vec4<f32>(_e6076.x, _e6076.y, _e6076.z, _e6076.w), vec4<f32>(_e6077.x, _e6077.y, _e6077.z, _e6077.w), vec4<f32>(_e6078.x, _e6078.y, _e6078.z, _e6078.w), vec4<f32>(_e6079.x, _e6079.y, _e6079.z, _e6079.w));
                                                                    let _e6102 = c_2;
                                                                    let _e6103 = randomSeed_1;
                                                                    let _e6104 = regularity_6;
                                                                    let _e6105 = rnd2_(_e6102, _e6103, _e6104);
                                                                    r = _e6105;
                                                                    loop {
                                                                        let _e6109 = i;
                                                                        if !((_e6109 < 5i)) {
                                                                            break;
                                                                        }
                                                                        {
                                                                            let _e6116 = r;
                                                                            i1_ = i32(floor((_e6116 * 4f)));
                                                                            let _e6122 = i1_;
                                                                            i2_ = (_e6122 + 1i);
                                                                            let _e6126 = i2_;
                                                                            if (_e6126 >= 4i) {
                                                                                i2_ = 0i;
                                                                            }
                                                                            let _e6130 = i1_;
                                                                            let _e6132 = cols[_e6130];
                                                                            tmp = _e6132;
                                                                            let _e6134 = i1_;
                                                                            let _e6136 = i2_;
                                                                            let _e6138 = cols[_e6136];
                                                                            cols[_e6134] = _e6138;
                                                                            let _e6139 = i2_;
                                                                            let _e6141 = tmp;
                                                                            cols[_e6139] = _e6141;
                                                                            let _e6142 = r;
                                                                            r = (_e6142 * 0.25f);
                                                                        }
                                                                        continuing {
                                                                            let _e6113 = i;
                                                                            i = (_e6113 + 1i);
                                                                        }
                                                                    }
                                                                    loop {
                                                                        let _e6147 = i_1;
                                                                        if !((_e6147 < 4i)) {
                                                                            break;
                                                                        }
                                                                        {
                                                                            let _e6154 = i_1;
                                                                            let _e6156 = cols[_e6154];
                                                                            col = _e6156;
                                                                            let _e6157 = col;
                                                                            if (_e6157.w == 1f) {
                                                                                break;
                                                                            }
                                                                        }
                                                                        continuing {
                                                                            let _e6151 = i_1;
                                                                            i_1 = (_e6151 + 1i);
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e6161 = onBorder;
    if _e6161 {
        let _e6162 = col;
        let _e6163 = borderColor_1;
        let _e6164 = mergeColor(_e6162, _e6163);
        return _e6164;
    } else {
        let _e6165 = col;
        return _e6165;
    }
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e85 = global.U[10];
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e112 = tiledStreak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78, _e81.x, _e85.x, mat3x3<f32>(vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z)));
    fragColor = _e112;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e13 = fragColor;
    return FragmentOutput(_e13);
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
