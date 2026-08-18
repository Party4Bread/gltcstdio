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
            let _e182 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e161.x / _e165.x), _e172.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e184 = luma(_e182.xyz);
            let _e185 = modelTransform_1;
            let _e186 = v_2;
            let _e187 = delta;
            let _e189 = tf(_e185, (_e186 - _e187));
            let _e193 = global.U[0];
            let _e196 = modelTransform_1;
            let _e197 = v_2;
            let _e198 = delta;
            let _e200 = tf(_e196, (_e197 - _e198));
            let _e210 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e189.x / _e193.x), _e200.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e212 = luma(_e210.xyz);
            let _e215 = modelTransform_1;
            let _e216 = v_2;
            let _e217 = delta;
            let _e220 = delta;
            let _e222 = tf(_e215, ((_e216 + _e217.yx) + _e220));
            let _e226 = global.U[0];
            let _e229 = modelTransform_1;
            let _e230 = v_2;
            let _e231 = delta;
            let _e234 = delta;
            let _e236 = tf(_e229, ((_e230 + _e231.yx) + _e234));
            let _e246 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e222.x / _e226.x), _e236.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e248 = luma(_e246.xyz);
            let _e249 = modelTransform_1;
            let _e250 = v_2;
            let _e251 = delta;
            let _e254 = delta;
            let _e256 = tf(_e249, ((_e250 + _e251.yx) - _e254));
            let _e260 = global.U[0];
            let _e263 = modelTransform_1;
            let _e264 = v_2;
            let _e265 = delta;
            let _e268 = delta;
            let _e270 = tf(_e263, ((_e264 + _e265.yx) - _e268));
            let _e280 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e256.x / _e260.x), _e270.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e282 = luma(_e280.xyz);
            let _e286 = modelTransform_1;
            let _e287 = v_2;
            let _e288 = delta;
            let _e291 = delta;
            let _e293 = tf(_e286, ((_e287 - _e288.yx) + _e291));
            let _e297 = global.U[0];
            let _e300 = modelTransform_1;
            let _e301 = v_2;
            let _e302 = delta;
            let _e305 = delta;
            let _e307 = tf(_e300, ((_e301 - _e302.yx) + _e305));
            let _e317 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e293.x / _e297.x), _e307.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e319 = luma(_e317.xyz);
            let _e320 = modelTransform_1;
            let _e321 = v_2;
            let _e322 = delta;
            let _e325 = delta;
            let _e327 = tf(_e320, ((_e321 - _e322.yx) - _e325));
            let _e331 = global.U[0];
            let _e334 = modelTransform_1;
            let _e335 = v_2;
            let _e336 = delta;
            let _e339 = delta;
            let _e341 = tf(_e334, ((_e335 - _e336.yx) - _e339));
            let _e351 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e327.x / _e331.x), _e341.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e353 = luma(_e351.xyz);
            let _e357 = modelTransform_1;
            let _e358 = v_2;
            let _e359 = delta;
            let _e362 = tf(_e357, (_e358 + _e359.yx));
            let _e366 = global.U[0];
            let _e369 = modelTransform_1;
            let _e370 = v_2;
            let _e371 = delta;
            let _e374 = tf(_e369, (_e370 + _e371.yx));
            let _e384 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e362.x / _e366.x), _e374.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e386 = luma(_e384.xyz);
            let _e387 = modelTransform_1;
            let _e388 = v_2;
            let _e389 = delta;
            let _e392 = tf(_e387, (_e388 - _e389.yx));
            let _e396 = global.U[0];
            let _e399 = modelTransform_1;
            let _e400 = v_2;
            let _e401 = delta;
            let _e404 = tf(_e399, (_e400 - _e401.yx));
            let _e414 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e392.x / _e396.x), _e404.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e416 = luma(_e414.xyz);
            let _e419 = modelTransform_1;
            let _e420 = v_2;
            let _e421 = delta;
            let _e423 = delta;
            let _e426 = tf(_e419, ((_e420 + _e421) + _e423.yx));
            let _e430 = global.U[0];
            let _e433 = modelTransform_1;
            let _e434 = v_2;
            let _e435 = delta;
            let _e437 = delta;
            let _e440 = tf(_e433, ((_e434 + _e435) + _e437.yx));
            let _e450 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e426.x / _e430.x), _e440.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e452 = luma(_e450.xyz);
            let _e453 = modelTransform_1;
            let _e454 = v_2;
            let _e455 = delta;
            let _e457 = delta;
            let _e460 = tf(_e453, ((_e454 + _e455) - _e457.yx));
            let _e464 = global.U[0];
            let _e467 = modelTransform_1;
            let _e468 = v_2;
            let _e469 = delta;
            let _e471 = delta;
            let _e474 = tf(_e467, ((_e468 + _e469) - _e471.yx));
            let _e484 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e460.x / _e464.x), _e474.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e486 = luma(_e484.xyz);
            let _e490 = modelTransform_1;
            let _e491 = v_2;
            let _e492 = delta;
            let _e494 = delta;
            let _e497 = tf(_e490, ((_e491 - _e492) + _e494.yx));
            let _e501 = global.U[0];
            let _e504 = modelTransform_1;
            let _e505 = v_2;
            let _e506 = delta;
            let _e508 = delta;
            let _e511 = tf(_e504, ((_e505 - _e506) + _e508.yx));
            let _e521 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e497.x / _e501.x), _e511.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e523 = luma(_e521.xyz);
            let _e524 = modelTransform_1;
            let _e525 = v_2;
            let _e526 = delta;
            let _e528 = delta;
            let _e531 = tf(_e524, ((_e525 - _e526) - _e528.yx));
            let _e535 = global.U[0];
            let _e538 = modelTransform_1;
            let _e539 = v_2;
            let _e540 = delta;
            let _e542 = delta;
            let _e545 = tf(_e538, ((_e539 - _e540) - _e542.yx));
            let _e555 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e531.x / _e535.x), _e545.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e557 = luma(_e555.xyz);
            dirBottom = (((abs((_e184 - _e212)) + abs((_e248 - _e282))) + abs((_e319 - _e353))) < ((abs((_e386 - _e416)) + abs((_e452 - _e486))) + abs((_e523 - _e557))));
            dir_4 = vec2<f32>(0f, 1f);
            let _e565 = c_2;
            let _e570 = dir_4;
            v_2 = ((_e565 + vec2(0.5f)) + (0.5f * _e570));
            let _e573 = modelTransform_1;
            let _e574 = v_2;
            let _e575 = delta;
            let _e577 = tf(_e573, (_e574 + _e575));
            let _e581 = global.U[0];
            let _e584 = modelTransform_1;
            let _e585 = v_2;
            let _e586 = delta;
            let _e588 = tf(_e584, (_e585 + _e586));
            let _e598 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e577.x / _e581.x), _e588.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e600 = luma(_e598.xyz);
            let _e601 = modelTransform_1;
            let _e602 = v_2;
            let _e603 = delta;
            let _e605 = tf(_e601, (_e602 - _e603));
            let _e609 = global.U[0];
            let _e612 = modelTransform_1;
            let _e613 = v_2;
            let _e614 = delta;
            let _e616 = tf(_e612, (_e613 - _e614));
            let _e626 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e605.x / _e609.x), _e616.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e628 = luma(_e626.xyz);
            let _e631 = modelTransform_1;
            let _e632 = v_2;
            let _e633 = delta;
            let _e636 = delta;
            let _e638 = tf(_e631, ((_e632 + _e633.yx) + _e636));
            let _e642 = global.U[0];
            let _e645 = modelTransform_1;
            let _e646 = v_2;
            let _e647 = delta;
            let _e650 = delta;
            let _e652 = tf(_e645, ((_e646 + _e647.yx) + _e650));
            let _e662 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e638.x / _e642.x), _e652.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e664 = luma(_e662.xyz);
            let _e665 = modelTransform_1;
            let _e666 = v_2;
            let _e667 = delta;
            let _e670 = delta;
            let _e672 = tf(_e665, ((_e666 + _e667.yx) - _e670));
            let _e676 = global.U[0];
            let _e679 = modelTransform_1;
            let _e680 = v_2;
            let _e681 = delta;
            let _e684 = delta;
            let _e686 = tf(_e679, ((_e680 + _e681.yx) - _e684));
            let _e696 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e672.x / _e676.x), _e686.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e698 = luma(_e696.xyz);
            let _e702 = modelTransform_1;
            let _e703 = v_2;
            let _e704 = delta;
            let _e707 = delta;
            let _e709 = tf(_e702, ((_e703 - _e704.yx) + _e707));
            let _e713 = global.U[0];
            let _e716 = modelTransform_1;
            let _e717 = v_2;
            let _e718 = delta;
            let _e721 = delta;
            let _e723 = tf(_e716, ((_e717 - _e718.yx) + _e721));
            let _e733 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e709.x / _e713.x), _e723.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e735 = luma(_e733.xyz);
            let _e736 = modelTransform_1;
            let _e737 = v_2;
            let _e738 = delta;
            let _e741 = delta;
            let _e743 = tf(_e736, ((_e737 - _e738.yx) - _e741));
            let _e747 = global.U[0];
            let _e750 = modelTransform_1;
            let _e751 = v_2;
            let _e752 = delta;
            let _e755 = delta;
            let _e757 = tf(_e750, ((_e751 - _e752.yx) - _e755));
            let _e767 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e743.x / _e747.x), _e757.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e769 = luma(_e767.xyz);
            let _e773 = modelTransform_1;
            let _e774 = v_2;
            let _e775 = delta;
            let _e778 = tf(_e773, (_e774 + _e775.yx));
            let _e782 = global.U[0];
            let _e785 = modelTransform_1;
            let _e786 = v_2;
            let _e787 = delta;
            let _e790 = tf(_e785, (_e786 + _e787.yx));
            let _e800 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e778.x / _e782.x), _e790.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e802 = luma(_e800.xyz);
            let _e803 = modelTransform_1;
            let _e804 = v_2;
            let _e805 = delta;
            let _e808 = tf(_e803, (_e804 - _e805.yx));
            let _e812 = global.U[0];
            let _e815 = modelTransform_1;
            let _e816 = v_2;
            let _e817 = delta;
            let _e820 = tf(_e815, (_e816 - _e817.yx));
            let _e830 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e808.x / _e812.x), _e820.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e832 = luma(_e830.xyz);
            let _e835 = modelTransform_1;
            let _e836 = v_2;
            let _e837 = delta;
            let _e839 = delta;
            let _e842 = tf(_e835, ((_e836 + _e837) + _e839.yx));
            let _e846 = global.U[0];
            let _e849 = modelTransform_1;
            let _e850 = v_2;
            let _e851 = delta;
            let _e853 = delta;
            let _e856 = tf(_e849, ((_e850 + _e851) + _e853.yx));
            let _e866 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e842.x / _e846.x), _e856.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e868 = luma(_e866.xyz);
            let _e869 = modelTransform_1;
            let _e870 = v_2;
            let _e871 = delta;
            let _e873 = delta;
            let _e876 = tf(_e869, ((_e870 + _e871) - _e873.yx));
            let _e880 = global.U[0];
            let _e883 = modelTransform_1;
            let _e884 = v_2;
            let _e885 = delta;
            let _e887 = delta;
            let _e890 = tf(_e883, ((_e884 + _e885) - _e887.yx));
            let _e900 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e876.x / _e880.x), _e890.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e902 = luma(_e900.xyz);
            let _e906 = modelTransform_1;
            let _e907 = v_2;
            let _e908 = delta;
            let _e910 = delta;
            let _e913 = tf(_e906, ((_e907 - _e908) + _e910.yx));
            let _e917 = global.U[0];
            let _e920 = modelTransform_1;
            let _e921 = v_2;
            let _e922 = delta;
            let _e924 = delta;
            let _e927 = tf(_e920, ((_e921 - _e922) + _e924.yx));
            let _e937 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e913.x / _e917.x), _e927.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e939 = luma(_e937.xyz);
            let _e940 = modelTransform_1;
            let _e941 = v_2;
            let _e942 = delta;
            let _e944 = delta;
            let _e947 = tf(_e940, ((_e941 - _e942) - _e944.yx));
            let _e951 = global.U[0];
            let _e954 = modelTransform_1;
            let _e955 = v_2;
            let _e956 = delta;
            let _e958 = delta;
            let _e961 = tf(_e954, ((_e955 - _e956) - _e958.yx));
            let _e971 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e947.x / _e951.x), _e961.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e973 = luma(_e971.xyz);
            dirTop = (((abs((_e600 - _e628)) + abs((_e664 - _e698))) + abs((_e735 - _e769))) < ((abs((_e802 - _e832)) + abs((_e868 - _e902))) + abs((_e939 - _e973))));
            dir_4 = vec2<f32>(-1f, 0f);
            let _e982 = c_2;
            let _e987 = dir_4;
            v_2 = ((_e982 + vec2(0.5f)) + (0.5f * _e987));
            let _e990 = modelTransform_1;
            let _e991 = v_2;
            let _e992 = delta;
            let _e994 = tf(_e990, (_e991 + _e992));
            let _e998 = global.U[0];
            let _e1001 = modelTransform_1;
            let _e1002 = v_2;
            let _e1003 = delta;
            let _e1005 = tf(_e1001, (_e1002 + _e1003));
            let _e1015 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e994.x / _e998.x), _e1005.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1017 = luma(_e1015.xyz);
            let _e1018 = modelTransform_1;
            let _e1019 = v_2;
            let _e1020 = delta;
            let _e1022 = tf(_e1018, (_e1019 - _e1020));
            let _e1026 = global.U[0];
            let _e1029 = modelTransform_1;
            let _e1030 = v_2;
            let _e1031 = delta;
            let _e1033 = tf(_e1029, (_e1030 - _e1031));
            let _e1043 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1022.x / _e1026.x), _e1033.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1045 = luma(_e1043.xyz);
            let _e1048 = modelTransform_1;
            let _e1049 = v_2;
            let _e1050 = delta;
            let _e1053 = delta;
            let _e1055 = tf(_e1048, ((_e1049 + _e1050.yx) + _e1053));
            let _e1059 = global.U[0];
            let _e1062 = modelTransform_1;
            let _e1063 = v_2;
            let _e1064 = delta;
            let _e1067 = delta;
            let _e1069 = tf(_e1062, ((_e1063 + _e1064.yx) + _e1067));
            let _e1079 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1055.x / _e1059.x), _e1069.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1081 = luma(_e1079.xyz);
            let _e1082 = modelTransform_1;
            let _e1083 = v_2;
            let _e1084 = delta;
            let _e1087 = delta;
            let _e1089 = tf(_e1082, ((_e1083 + _e1084.yx) - _e1087));
            let _e1093 = global.U[0];
            let _e1096 = modelTransform_1;
            let _e1097 = v_2;
            let _e1098 = delta;
            let _e1101 = delta;
            let _e1103 = tf(_e1096, ((_e1097 + _e1098.yx) - _e1101));
            let _e1113 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1089.x / _e1093.x), _e1103.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1115 = luma(_e1113.xyz);
            let _e1119 = modelTransform_1;
            let _e1120 = v_2;
            let _e1121 = delta;
            let _e1124 = delta;
            let _e1126 = tf(_e1119, ((_e1120 - _e1121.yx) + _e1124));
            let _e1130 = global.U[0];
            let _e1133 = modelTransform_1;
            let _e1134 = v_2;
            let _e1135 = delta;
            let _e1138 = delta;
            let _e1140 = tf(_e1133, ((_e1134 - _e1135.yx) + _e1138));
            let _e1150 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1126.x / _e1130.x), _e1140.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1152 = luma(_e1150.xyz);
            let _e1153 = modelTransform_1;
            let _e1154 = v_2;
            let _e1155 = delta;
            let _e1158 = delta;
            let _e1160 = tf(_e1153, ((_e1154 - _e1155.yx) - _e1158));
            let _e1164 = global.U[0];
            let _e1167 = modelTransform_1;
            let _e1168 = v_2;
            let _e1169 = delta;
            let _e1172 = delta;
            let _e1174 = tf(_e1167, ((_e1168 - _e1169.yx) - _e1172));
            let _e1184 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1160.x / _e1164.x), _e1174.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1186 = luma(_e1184.xyz);
            let _e1190 = modelTransform_1;
            let _e1191 = v_2;
            let _e1192 = delta;
            let _e1195 = tf(_e1190, (_e1191 + _e1192.yx));
            let _e1199 = global.U[0];
            let _e1202 = modelTransform_1;
            let _e1203 = v_2;
            let _e1204 = delta;
            let _e1207 = tf(_e1202, (_e1203 + _e1204.yx));
            let _e1217 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1195.x / _e1199.x), _e1207.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1219 = luma(_e1217.xyz);
            let _e1220 = modelTransform_1;
            let _e1221 = v_2;
            let _e1222 = delta;
            let _e1225 = tf(_e1220, (_e1221 - _e1222.yx));
            let _e1229 = global.U[0];
            let _e1232 = modelTransform_1;
            let _e1233 = v_2;
            let _e1234 = delta;
            let _e1237 = tf(_e1232, (_e1233 - _e1234.yx));
            let _e1247 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1225.x / _e1229.x), _e1237.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1249 = luma(_e1247.xyz);
            let _e1252 = modelTransform_1;
            let _e1253 = v_2;
            let _e1254 = delta;
            let _e1256 = delta;
            let _e1259 = tf(_e1252, ((_e1253 + _e1254) + _e1256.yx));
            let _e1263 = global.U[0];
            let _e1266 = modelTransform_1;
            let _e1267 = v_2;
            let _e1268 = delta;
            let _e1270 = delta;
            let _e1273 = tf(_e1266, ((_e1267 + _e1268) + _e1270.yx));
            let _e1283 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1259.x / _e1263.x), _e1273.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1285 = luma(_e1283.xyz);
            let _e1286 = modelTransform_1;
            let _e1287 = v_2;
            let _e1288 = delta;
            let _e1290 = delta;
            let _e1293 = tf(_e1286, ((_e1287 + _e1288) - _e1290.yx));
            let _e1297 = global.U[0];
            let _e1300 = modelTransform_1;
            let _e1301 = v_2;
            let _e1302 = delta;
            let _e1304 = delta;
            let _e1307 = tf(_e1300, ((_e1301 + _e1302) - _e1304.yx));
            let _e1317 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1293.x / _e1297.x), _e1307.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1319 = luma(_e1317.xyz);
            let _e1323 = modelTransform_1;
            let _e1324 = v_2;
            let _e1325 = delta;
            let _e1327 = delta;
            let _e1330 = tf(_e1323, ((_e1324 - _e1325) + _e1327.yx));
            let _e1334 = global.U[0];
            let _e1337 = modelTransform_1;
            let _e1338 = v_2;
            let _e1339 = delta;
            let _e1341 = delta;
            let _e1344 = tf(_e1337, ((_e1338 - _e1339) + _e1341.yx));
            let _e1354 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1330.x / _e1334.x), _e1344.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1356 = luma(_e1354.xyz);
            let _e1357 = modelTransform_1;
            let _e1358 = v_2;
            let _e1359 = delta;
            let _e1361 = delta;
            let _e1364 = tf(_e1357, ((_e1358 - _e1359) - _e1361.yx));
            let _e1368 = global.U[0];
            let _e1371 = modelTransform_1;
            let _e1372 = v_2;
            let _e1373 = delta;
            let _e1375 = delta;
            let _e1378 = tf(_e1371, ((_e1372 - _e1373) - _e1375.yx));
            let _e1388 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1364.x / _e1368.x), _e1378.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1390 = luma(_e1388.xyz);
            dirLeft = (((abs((_e1017 - _e1045)) + abs((_e1081 - _e1115))) + abs((_e1152 - _e1186))) < ((abs((_e1219 - _e1249)) + abs((_e1285 - _e1319))) + abs((_e1356 - _e1390))));
            dir_4 = vec2<f32>(1f, 0f);
            let _e1398 = c_2;
            let _e1403 = dir_4;
            v_2 = ((_e1398 + vec2(0.5f)) + (0.5f * _e1403));
            let _e1406 = modelTransform_1;
            let _e1407 = v_2;
            let _e1408 = delta;
            let _e1410 = tf(_e1406, (_e1407 + _e1408));
            let _e1414 = global.U[0];
            let _e1417 = modelTransform_1;
            let _e1418 = v_2;
            let _e1419 = delta;
            let _e1421 = tf(_e1417, (_e1418 + _e1419));
            let _e1431 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1410.x / _e1414.x), _e1421.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1433 = luma(_e1431.xyz);
            let _e1434 = modelTransform_1;
            let _e1435 = v_2;
            let _e1436 = delta;
            let _e1438 = tf(_e1434, (_e1435 - _e1436));
            let _e1442 = global.U[0];
            let _e1445 = modelTransform_1;
            let _e1446 = v_2;
            let _e1447 = delta;
            let _e1449 = tf(_e1445, (_e1446 - _e1447));
            let _e1459 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1438.x / _e1442.x), _e1449.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1461 = luma(_e1459.xyz);
            let _e1464 = modelTransform_1;
            let _e1465 = v_2;
            let _e1466 = delta;
            let _e1469 = delta;
            let _e1471 = tf(_e1464, ((_e1465 + _e1466.yx) + _e1469));
            let _e1475 = global.U[0];
            let _e1478 = modelTransform_1;
            let _e1479 = v_2;
            let _e1480 = delta;
            let _e1483 = delta;
            let _e1485 = tf(_e1478, ((_e1479 + _e1480.yx) + _e1483));
            let _e1495 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1471.x / _e1475.x), _e1485.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1497 = luma(_e1495.xyz);
            let _e1498 = modelTransform_1;
            let _e1499 = v_2;
            let _e1500 = delta;
            let _e1503 = delta;
            let _e1505 = tf(_e1498, ((_e1499 + _e1500.yx) - _e1503));
            let _e1509 = global.U[0];
            let _e1512 = modelTransform_1;
            let _e1513 = v_2;
            let _e1514 = delta;
            let _e1517 = delta;
            let _e1519 = tf(_e1512, ((_e1513 + _e1514.yx) - _e1517));
            let _e1529 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1505.x / _e1509.x), _e1519.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1531 = luma(_e1529.xyz);
            let _e1535 = modelTransform_1;
            let _e1536 = v_2;
            let _e1537 = delta;
            let _e1540 = delta;
            let _e1542 = tf(_e1535, ((_e1536 - _e1537.yx) + _e1540));
            let _e1546 = global.U[0];
            let _e1549 = modelTransform_1;
            let _e1550 = v_2;
            let _e1551 = delta;
            let _e1554 = delta;
            let _e1556 = tf(_e1549, ((_e1550 - _e1551.yx) + _e1554));
            let _e1566 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1542.x / _e1546.x), _e1556.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1568 = luma(_e1566.xyz);
            let _e1569 = modelTransform_1;
            let _e1570 = v_2;
            let _e1571 = delta;
            let _e1574 = delta;
            let _e1576 = tf(_e1569, ((_e1570 - _e1571.yx) - _e1574));
            let _e1580 = global.U[0];
            let _e1583 = modelTransform_1;
            let _e1584 = v_2;
            let _e1585 = delta;
            let _e1588 = delta;
            let _e1590 = tf(_e1583, ((_e1584 - _e1585.yx) - _e1588));
            let _e1600 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1576.x / _e1580.x), _e1590.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1602 = luma(_e1600.xyz);
            let _e1606 = modelTransform_1;
            let _e1607 = v_2;
            let _e1608 = delta;
            let _e1611 = tf(_e1606, (_e1607 + _e1608.yx));
            let _e1615 = global.U[0];
            let _e1618 = modelTransform_1;
            let _e1619 = v_2;
            let _e1620 = delta;
            let _e1623 = tf(_e1618, (_e1619 + _e1620.yx));
            let _e1633 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1611.x / _e1615.x), _e1623.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1635 = luma(_e1633.xyz);
            let _e1636 = modelTransform_1;
            let _e1637 = v_2;
            let _e1638 = delta;
            let _e1641 = tf(_e1636, (_e1637 - _e1638.yx));
            let _e1645 = global.U[0];
            let _e1648 = modelTransform_1;
            let _e1649 = v_2;
            let _e1650 = delta;
            let _e1653 = tf(_e1648, (_e1649 - _e1650.yx));
            let _e1663 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1641.x / _e1645.x), _e1653.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1665 = luma(_e1663.xyz);
            let _e1668 = modelTransform_1;
            let _e1669 = v_2;
            let _e1670 = delta;
            let _e1672 = delta;
            let _e1675 = tf(_e1668, ((_e1669 + _e1670) + _e1672.yx));
            let _e1679 = global.U[0];
            let _e1682 = modelTransform_1;
            let _e1683 = v_2;
            let _e1684 = delta;
            let _e1686 = delta;
            let _e1689 = tf(_e1682, ((_e1683 + _e1684) + _e1686.yx));
            let _e1699 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1675.x / _e1679.x), _e1689.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1701 = luma(_e1699.xyz);
            let _e1702 = modelTransform_1;
            let _e1703 = v_2;
            let _e1704 = delta;
            let _e1706 = delta;
            let _e1709 = tf(_e1702, ((_e1703 + _e1704) - _e1706.yx));
            let _e1713 = global.U[0];
            let _e1716 = modelTransform_1;
            let _e1717 = v_2;
            let _e1718 = delta;
            let _e1720 = delta;
            let _e1723 = tf(_e1716, ((_e1717 + _e1718) - _e1720.yx));
            let _e1733 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1709.x / _e1713.x), _e1723.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1735 = luma(_e1733.xyz);
            let _e1739 = modelTransform_1;
            let _e1740 = v_2;
            let _e1741 = delta;
            let _e1743 = delta;
            let _e1746 = tf(_e1739, ((_e1740 - _e1741) + _e1743.yx));
            let _e1750 = global.U[0];
            let _e1753 = modelTransform_1;
            let _e1754 = v_2;
            let _e1755 = delta;
            let _e1757 = delta;
            let _e1760 = tf(_e1753, ((_e1754 - _e1755) + _e1757.yx));
            let _e1770 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1746.x / _e1750.x), _e1760.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1772 = luma(_e1770.xyz);
            let _e1773 = modelTransform_1;
            let _e1774 = v_2;
            let _e1775 = delta;
            let _e1777 = delta;
            let _e1780 = tf(_e1773, ((_e1774 - _e1775) - _e1777.yx));
            let _e1784 = global.U[0];
            let _e1787 = modelTransform_1;
            let _e1788 = v_2;
            let _e1789 = delta;
            let _e1791 = delta;
            let _e1794 = tf(_e1787, ((_e1788 - _e1789) - _e1791.yx));
            let _e1804 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1780.x / _e1784.x), _e1794.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e1806 = luma(_e1804.xyz);
            dirRight = (((abs((_e1433 - _e1461)) + abs((_e1497 - _e1531))) + abs((_e1568 - _e1602))) < ((abs((_e1635 - _e1665)) + abs((_e1701 - _e1735))) + abs((_e1772 - _e1806))));
            let _e1811 = balance_1;
            if (_e1811 < 0f) {
                {
                    let _e1814 = dirTop;
                    dirTop = !(_e1814);
                    let _e1816 = dirBottom;
                    dirBottom = !(_e1816);
                    let _e1818 = dirLeft;
                    dirLeft = !(_e1818);
                    let _e1820 = dirRight;
                    dirRight = !(_e1820);
                }
            }
        }
    }
    let _e1828 = dirTop;
    let _e1829 = dirBottom;
    let _e1831 = dirTop;
    let _e1832 = dirLeft;
    let _e1835 = dirTop;
    let _e1836 = dirRight;
    if (((_e1828 == _e1829) && (_e1831 == _e1832)) && (_e1835 == _e1836)) {
        {
            let _e1839 = dirTop;
            if _e1839 {
                {
                    let _e1840 = modelTransform_1;
                    let _e1841 = c_2;
                    let _e1843 = u_8;
                    let _e1846 = tf(_e1840, vec2<f32>(_e1841.x, _e1843.y));
                    let _e1850 = global.U[0];
                    let _e1853 = modelTransform_1;
                    let _e1854 = c_2;
                    let _e1856 = u_8;
                    let _e1859 = tf(_e1853, vec2<f32>(_e1854.x, _e1856.y));
                    let _e1869 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1846.x / _e1850.x), _e1859.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e1870 = modelTransform_1;
                    let _e1871 = c_2;
                    let _e1875 = u_8;
                    let _e1878 = tf(_e1870, vec2<f32>((_e1871.x + 1f), _e1875.y));
                    let _e1882 = global.U[0];
                    let _e1885 = modelTransform_1;
                    let _e1886 = c_2;
                    let _e1890 = u_8;
                    let _e1893 = tf(_e1885, vec2<f32>((_e1886.x + 1f), _e1890.y));
                    let _e1903 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1878.x / _e1882.x), _e1893.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e1904 = u_8;
                    let _e1906 = c_2;
                    col = mix(_e1869, _e1903, vec4((_e1904.x - _e1906.x)));
                }
            } else {
                {
                    let _e1911 = modelTransform_1;
                    let _e1912 = u_8;
                    let _e1914 = c_2;
                    let _e1917 = tf(_e1911, vec2<f32>(_e1912.x, _e1914.y));
                    let _e1921 = global.U[0];
                    let _e1924 = modelTransform_1;
                    let _e1925 = u_8;
                    let _e1927 = c_2;
                    let _e1930 = tf(_e1924, vec2<f32>(_e1925.x, _e1927.y));
                    let _e1940 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1917.x / _e1921.x), _e1930.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e1941 = modelTransform_1;
                    let _e1942 = u_8;
                    let _e1944 = c_2;
                    let _e1949 = tf(_e1941, vec2<f32>(_e1942.x, (_e1944.y + 1f)));
                    let _e1953 = global.U[0];
                    let _e1956 = modelTransform_1;
                    let _e1957 = u_8;
                    let _e1959 = c_2;
                    let _e1964 = tf(_e1956, vec2<f32>(_e1957.x, (_e1959.y + 1f)));
                    let _e1974 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1949.x / _e1953.x), _e1964.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e1975 = u_8;
                    let _e1977 = c_2;
                    col = mix(_e1940, _e1974, vec4((_e1975.y - _e1977.y)));
                }
            }
        }
    } else {
        let _e1982 = dirTop;
        let _e1983 = dirBottom;
        let _e1985 = dirLeft;
        let _e1987 = dirRight;
        if (((_e1982 && _e1983) && _e1985) && !(_e1987)) {
            {
                if false {
                    {
                        let _e1991 = modelTransform_1;
                        let _e1992 = c_2;
                        let _e1994 = u_8;
                        let _e1997 = tf(_e1991, vec2<f32>(_e1992.x, _e1994.y));
                        let _e2001 = global.U[0];
                        let _e2004 = modelTransform_1;
                        let _e2005 = c_2;
                        let _e2007 = u_8;
                        let _e2010 = tf(_e2004, vec2<f32>(_e2005.x, _e2007.y));
                        let _e2020 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1997.x / _e2001.x), _e2010.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e2021 = modelTransform_1;
                        let _e2022 = c_2;
                        let _e2026 = u_8;
                        let _e2029 = tf(_e2021, vec2<f32>((_e2022.x + 1f), _e2026.y));
                        let _e2033 = global.U[0];
                        let _e2036 = modelTransform_1;
                        let _e2037 = c_2;
                        let _e2041 = u_8;
                        let _e2044 = tf(_e2036, vec2<f32>((_e2037.x + 1f), _e2041.y));
                        let _e2054 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2029.x / _e2033.x), _e2044.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        let _e2055 = u_8;
                        let _e2057 = c_2;
                        col = mix(_e2020, _e2054, vec4((_e2055.x - _e2057.x)));
                    }
                } else {
                    {
                        col = vec4<f32>(0f, 1f, 0f, 1f);
                        let _e2067 = c_2;
                        let _e2071 = u_8;
                        let _e2073 = c_2;
                        X = ((_e2067.x + 0.5f) + abs(((_e2071.y - _e2073.y) - 0.5f)));
                        let _e2081 = u_8;
                        let _e2083 = X;
                        if (_e2081.x < _e2083) {
                            let _e2085 = modelTransform_1;
                            let _e2086 = c_2;
                            let _e2088 = u_8;
                            let _e2091 = tf(_e2085, vec2<f32>(_e2086.x, _e2088.y));
                            let _e2095 = global.U[0];
                            let _e2098 = modelTransform_1;
                            let _e2099 = c_2;
                            let _e2101 = u_8;
                            let _e2104 = tf(_e2098, vec2<f32>(_e2099.x, _e2101.y));
                            let _e2114 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2091.x / _e2095.x), _e2104.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e2115 = modelTransform_1;
                            let _e2116 = X;
                            let _e2117 = u_8;
                            let _e2120 = tf(_e2115, vec2<f32>(_e2116, _e2117.y));
                            let _e2124 = global.U[0];
                            let _e2127 = modelTransform_1;
                            let _e2128 = X;
                            let _e2129 = u_8;
                            let _e2132 = tf(_e2127, vec2<f32>(_e2128, _e2129.y));
                            let _e2142 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2120.x / _e2124.x), _e2132.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e2143 = u_8;
                            let _e2145 = c_2;
                            let _e2148 = X;
                            let _e2149 = c_2;
                            col = mix(_e2114, _e2142, vec4(((_e2143.x - _e2145.x) / (_e2148 - _e2149.x))));
                        } else {
                            {
                                let _e2155 = u_8;
                                let _e2157 = c_2;
                                Y = abs(((_e2155.x - _e2157.x) - 0.5f));
                                let _e2164 = modelTransform_1;
                                let _e2165 = u_8;
                                let _e2167 = c_2;
                                let _e2171 = Y;
                                let _e2174 = tf(_e2164, vec2<f32>(_e2165.x, ((_e2167.y + 0.5f) - _e2171)));
                                let _e2178 = global.U[0];
                                let _e2181 = modelTransform_1;
                                let _e2182 = u_8;
                                let _e2184 = c_2;
                                let _e2188 = Y;
                                let _e2191 = tf(_e2181, vec2<f32>(_e2182.x, ((_e2184.y + 0.5f) - _e2188)));
                                let _e2201 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2174.x / _e2178.x), _e2191.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2202 = modelTransform_1;
                                let _e2203 = u_8;
                                let _e2205 = c_2;
                                let _e2209 = Y;
                                let _e2212 = tf(_e2202, vec2<f32>(_e2203.x, ((_e2205.y + 0.5f) + _e2209)));
                                let _e2216 = global.U[0];
                                let _e2219 = modelTransform_1;
                                let _e2220 = u_8;
                                let _e2222 = c_2;
                                let _e2226 = Y;
                                let _e2229 = tf(_e2219, vec2<f32>(_e2220.x, ((_e2222.y + 0.5f) + _e2226)));
                                let _e2239 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2212.x / _e2216.x), _e2229.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2240 = u_8;
                                let _e2242 = c_2;
                                let _e2247 = Y;
                                let _e2250 = Y;
                                col = mix(_e2201, _e2239, vec4(((((_e2240.y - _e2242.y) - 0.5f) + _e2247) / (2f * _e2250))));
                            }
                        }
                    }
                }
            }
        } else {
            let _e2255 = dirTop;
            let _e2256 = dirBottom;
            let _e2258 = dirLeft;
            let _e2261 = dirRight;
            if (((_e2255 && _e2256) && !(_e2258)) && _e2261) {
                {
                    if false {
                        {
                            let _e2264 = modelTransform_1;
                            let _e2265 = c_2;
                            let _e2267 = u_8;
                            let _e2270 = tf(_e2264, vec2<f32>(_e2265.x, _e2267.y));
                            let _e2274 = global.U[0];
                            let _e2277 = modelTransform_1;
                            let _e2278 = c_2;
                            let _e2280 = u_8;
                            let _e2283 = tf(_e2277, vec2<f32>(_e2278.x, _e2280.y));
                            let _e2293 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2270.x / _e2274.x), _e2283.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e2294 = modelTransform_1;
                            let _e2295 = c_2;
                            let _e2299 = u_8;
                            let _e2302 = tf(_e2294, vec2<f32>((_e2295.x + 1f), _e2299.y));
                            let _e2306 = global.U[0];
                            let _e2309 = modelTransform_1;
                            let _e2310 = c_2;
                            let _e2314 = u_8;
                            let _e2317 = tf(_e2309, vec2<f32>((_e2310.x + 1f), _e2314.y));
                            let _e2327 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2302.x / _e2306.x), _e2317.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            let _e2328 = u_8;
                            let _e2330 = c_2;
                            col = mix(_e2293, _e2327, vec4((_e2328.x - _e2330.x)));
                        }
                    } else {
                        {
                            let _e2335 = c_2;
                            let _e2339 = u_8;
                            let _e2341 = c_2;
                            X_1 = ((_e2335.x + 0.5f) - abs(((_e2339.y - _e2341.y) - 0.5f)));
                            let _e2349 = u_8;
                            let _e2351 = X_1;
                            if (_e2349.x > _e2351) {
                                let _e2353 = modelTransform_1;
                                let _e2354 = X_1;
                                let _e2355 = u_8;
                                let _e2358 = tf(_e2353, vec2<f32>(_e2354, _e2355.y));
                                let _e2362 = global.U[0];
                                let _e2365 = modelTransform_1;
                                let _e2366 = X_1;
                                let _e2367 = u_8;
                                let _e2370 = tf(_e2365, vec2<f32>(_e2366, _e2367.y));
                                let _e2380 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2358.x / _e2362.x), _e2370.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2381 = modelTransform_1;
                                let _e2382 = c_2;
                                let _e2386 = u_8;
                                let _e2389 = tf(_e2381, vec2<f32>((_e2382.x + 1f), _e2386.y));
                                let _e2393 = global.U[0];
                                let _e2396 = modelTransform_1;
                                let _e2397 = c_2;
                                let _e2401 = u_8;
                                let _e2404 = tf(_e2396, vec2<f32>((_e2397.x + 1f), _e2401.y));
                                let _e2414 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2389.x / _e2393.x), _e2404.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2415 = u_8;
                                let _e2417 = X_1;
                                let _e2419 = c_2;
                                let _e2423 = X_1;
                                col = mix(_e2380, _e2414, vec4(((_e2415.x - _e2417) / ((_e2419.x + 1f) - _e2423))));
                            } else {
                                {
                                    let _e2428 = u_8;
                                    let _e2430 = c_2;
                                    Y_1 = abs(((_e2428.x - _e2430.x) - 0.5f));
                                    let _e2437 = modelTransform_1;
                                    let _e2438 = u_8;
                                    let _e2440 = c_2;
                                    let _e2444 = Y_1;
                                    let _e2447 = tf(_e2437, vec2<f32>(_e2438.x, ((_e2440.y + 0.5f) - _e2444)));
                                    let _e2451 = global.U[0];
                                    let _e2454 = modelTransform_1;
                                    let _e2455 = u_8;
                                    let _e2457 = c_2;
                                    let _e2461 = Y_1;
                                    let _e2464 = tf(_e2454, vec2<f32>(_e2455.x, ((_e2457.y + 0.5f) - _e2461)));
                                    let _e2474 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2447.x / _e2451.x), _e2464.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2475 = modelTransform_1;
                                    let _e2476 = u_8;
                                    let _e2478 = c_2;
                                    let _e2482 = Y_1;
                                    let _e2485 = tf(_e2475, vec2<f32>(_e2476.x, ((_e2478.y + 0.5f) + _e2482)));
                                    let _e2489 = global.U[0];
                                    let _e2492 = modelTransform_1;
                                    let _e2493 = u_8;
                                    let _e2495 = c_2;
                                    let _e2499 = Y_1;
                                    let _e2502 = tf(_e2492, vec2<f32>(_e2493.x, ((_e2495.y + 0.5f) + _e2499)));
                                    let _e2512 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2485.x / _e2489.x), _e2502.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2513 = u_8;
                                    let _e2515 = c_2;
                                    let _e2520 = Y_1;
                                    let _e2523 = Y_1;
                                    col = mix(_e2474, _e2512, vec4(((((_e2513.y - _e2515.y) - 0.5f) + _e2520) / (2f * _e2523))));
                                }
                            }
                        }
                    }
                }
            } else {
                let _e2528 = dirTop;
                let _e2529 = dirBottom;
                let _e2532 = dirLeft;
                let _e2534 = dirRight;
                if (((_e2528 && !(_e2529)) && _e2532) && _e2534) {
                    {
                        let _e2536 = c_2;
                        center = ((_e2536 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                        let _e2559 = u_8;
                        let _e2560 = center;
                        rel = (_e2559 - _e2560);
                        let _e2563 = rel;
                        len = length(_e2563);
                        let _e2566 = len;
                        if (_e2566 < 1f) {
                            {
                                let _e2569 = u_8;
                                let _e2570 = center;
                                let _e2577 = u_8;
                                let _e2578 = center;
                                a_1 = atan2(dot((_e2569 - _e2570), vec2<f32>(-1f, 0f)), dot((_e2577 - _e2578), vec2<f32>(0f, 1f)));
                                let _e2586 = modelTransform_1;
                                let _e2587 = center;
                                let _e2588 = len;
                                let _e2594 = tf(_e2586, (_e2587 + (_e2588 * vec2<f32>(0f, 1f))));
                                let _e2598 = global.U[0];
                                let _e2601 = modelTransform_1;
                                let _e2602 = center;
                                let _e2603 = len;
                                let _e2609 = tf(_e2601, (_e2602 + (_e2603 * vec2<f32>(0f, 1f))));
                                let _e2619 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2594.x / _e2598.x), _e2609.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2620 = modelTransform_1;
                                let _e2621 = center;
                                let _e2622 = len;
                                let _e2629 = tf(_e2620, (_e2621 + (_e2622 * vec2<f32>(-1f, 0f))));
                                let _e2633 = global.U[0];
                                let _e2636 = modelTransform_1;
                                let _e2637 = center;
                                let _e2638 = len;
                                let _e2645 = tf(_e2636, (_e2637 + (_e2638 * vec2<f32>(-1f, 0f))));
                                let _e2655 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2629.x / _e2633.x), _e2645.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2656 = a_1;
                                col = mix(_e2619, _e2655, vec4((_e2656 / 1.5707964f)));
                            }
                        } else {
                            {
                                let _e2661 = modelTransform_1;
                                let _e2662 = c_2;
                                let _e2664 = u_8;
                                let _e2667 = tf(_e2661, vec2<f32>(_e2662.x, _e2664.y));
                                let _e2671 = global.U[0];
                                let _e2674 = modelTransform_1;
                                let _e2675 = c_2;
                                let _e2677 = u_8;
                                let _e2680 = tf(_e2674, vec2<f32>(_e2675.x, _e2677.y));
                                let _e2690 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2667.x / _e2671.x), _e2680.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2691 = modelTransform_1;
                                let _e2692 = c_2;
                                let _e2696 = u_8;
                                let _e2699 = tf(_e2691, vec2<f32>((_e2692.x + 1f), _e2696.y));
                                let _e2703 = global.U[0];
                                let _e2706 = modelTransform_1;
                                let _e2707 = c_2;
                                let _e2711 = u_8;
                                let _e2714 = tf(_e2706, vec2<f32>((_e2707.x + 1f), _e2711.y));
                                let _e2724 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2699.x / _e2703.x), _e2714.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                let _e2725 = u_8;
                                let _e2727 = c_2;
                                col = mix(_e2690, _e2724, vec4((_e2725.x - _e2727.x)));
                            }
                        }
                    }
                } else {
                    let _e2732 = dirTop;
                    let _e2734 = dirBottom;
                    let _e2736 = dirLeft;
                    let _e2738 = dirRight;
                    if (((!(_e2732) && _e2734) && _e2736) && _e2738) {
                        {
                            let _e2740 = c_2;
                            center_1 = ((_e2740 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                            let _e2764 = u_8;
                            let _e2765 = center_1;
                            rel_1 = (_e2764 - _e2765);
                            let _e2768 = rel_1;
                            len_1 = length(_e2768);
                            let _e2771 = len_1;
                            if (_e2771 < 1f) {
                                {
                                    let _e2774 = u_8;
                                    let _e2775 = center_1;
                                    let _e2782 = u_8;
                                    let _e2783 = center_1;
                                    a_2 = atan2(dot((_e2774 - _e2775), vec2<f32>(0f, -1f)), dot((_e2782 - _e2783), vec2<f32>(-1f, 0f)));
                                    let _e2792 = modelTransform_1;
                                    let _e2793 = center_1;
                                    let _e2794 = len_1;
                                    let _e2801 = tf(_e2792, (_e2793 + (_e2794 * vec2<f32>(-1f, 0f))));
                                    let _e2805 = global.U[0];
                                    let _e2808 = modelTransform_1;
                                    let _e2809 = center_1;
                                    let _e2810 = len_1;
                                    let _e2817 = tf(_e2808, (_e2809 + (_e2810 * vec2<f32>(-1f, 0f))));
                                    let _e2827 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2801.x / _e2805.x), _e2817.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2828 = modelTransform_1;
                                    let _e2829 = center_1;
                                    let _e2830 = len_1;
                                    let _e2837 = tf(_e2828, (_e2829 + (_e2830 * vec2<f32>(0f, -1f))));
                                    let _e2841 = global.U[0];
                                    let _e2844 = modelTransform_1;
                                    let _e2845 = center_1;
                                    let _e2846 = len_1;
                                    let _e2853 = tf(_e2844, (_e2845 + (_e2846 * vec2<f32>(0f, -1f))));
                                    let _e2863 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2837.x / _e2841.x), _e2853.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2864 = a_2;
                                    col = mix(_e2827, _e2863, vec4((_e2864 / 1.5707964f)));
                                }
                            } else {
                                {
                                    let _e2869 = modelTransform_1;
                                    let _e2870 = c_2;
                                    let _e2872 = u_8;
                                    let _e2875 = tf(_e2869, vec2<f32>(_e2870.x, _e2872.y));
                                    let _e2879 = global.U[0];
                                    let _e2882 = modelTransform_1;
                                    let _e2883 = c_2;
                                    let _e2885 = u_8;
                                    let _e2888 = tf(_e2882, vec2<f32>(_e2883.x, _e2885.y));
                                    let _e2898 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2875.x / _e2879.x), _e2888.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2899 = modelTransform_1;
                                    let _e2900 = c_2;
                                    let _e2904 = u_8;
                                    let _e2907 = tf(_e2899, vec2<f32>((_e2900.x + 1f), _e2904.y));
                                    let _e2911 = global.U[0];
                                    let _e2914 = modelTransform_1;
                                    let _e2915 = c_2;
                                    let _e2919 = u_8;
                                    let _e2922 = tf(_e2914, vec2<f32>((_e2915.x + 1f), _e2919.y));
                                    let _e2932 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2907.x / _e2911.x), _e2922.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    let _e2933 = u_8;
                                    let _e2935 = c_2;
                                    col = mix(_e2898, _e2932, vec4((_e2933.x - _e2935.x)));
                                }
                            }
                        }
                    } else {
                        let _e2940 = dirTop;
                        let _e2941 = dirBottom;
                        let _e2943 = dirLeft;
                        let _e2946 = dirRight;
                        if (((_e2940 && _e2941) && !(_e2943)) && !(_e2946)) {
                            {
                                if false {
                                    {
                                        let _e2950 = modelTransform_1;
                                        let _e2951 = c_2;
                                        let _e2953 = u_8;
                                        let _e2956 = tf(_e2950, vec2<f32>(_e2951.x, _e2953.y));
                                        let _e2960 = global.U[0];
                                        let _e2963 = modelTransform_1;
                                        let _e2964 = c_2;
                                        let _e2966 = u_8;
                                        let _e2969 = tf(_e2963, vec2<f32>(_e2964.x, _e2966.y));
                                        let _e2979 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2956.x / _e2960.x), _e2969.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e2980 = modelTransform_1;
                                        let _e2981 = c_2;
                                        let _e2985 = u_8;
                                        let _e2988 = tf(_e2980, vec2<f32>((_e2981.x + 1f), _e2985.y));
                                        let _e2992 = global.U[0];
                                        let _e2995 = modelTransform_1;
                                        let _e2996 = c_2;
                                        let _e3000 = u_8;
                                        let _e3003 = tf(_e2995, vec2<f32>((_e2996.x + 1f), _e3000.y));
                                        let _e3013 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e2988.x / _e2992.x), _e3003.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        let _e3014 = u_8;
                                        let _e3016 = c_2;
                                        col = mix(_e2979, _e3013, vec4((_e3014.x - _e3016.x)));
                                    }
                                } else {
                                    {
                                        let _e3021 = u_8;
                                        let _e3023 = c_2;
                                        X_2 = abs(((_e3021.y - _e3023.y) - 0.5f));
                                        let _e3030 = u_8;
                                        let _e3032 = c_2;
                                        Y_2 = abs(((_e3030.x - _e3032.x) - 0.5f));
                                        let _e3039 = X_2;
                                        let _e3040 = Y_2;
                                        if (_e3039 > _e3040) {
                                            let _e3042 = modelTransform_1;
                                            let _e3043 = c_2;
                                            let _e3047 = X_2;
                                            let _e3049 = u_8;
                                            let _e3052 = tf(_e3042, vec2<f32>(((_e3043.x + 0.5f) - _e3047), _e3049.y));
                                            let _e3056 = global.U[0];
                                            let _e3059 = modelTransform_1;
                                            let _e3060 = c_2;
                                            let _e3064 = X_2;
                                            let _e3066 = u_8;
                                            let _e3069 = tf(_e3059, vec2<f32>(((_e3060.x + 0.5f) - _e3064), _e3066.y));
                                            let _e3079 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3052.x / _e3056.x), _e3069.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3080 = modelTransform_1;
                                            let _e3081 = c_2;
                                            let _e3085 = X_2;
                                            let _e3087 = u_8;
                                            let _e3090 = tf(_e3080, vec2<f32>(((_e3081.x + 0.5f) + _e3085), _e3087.y));
                                            let _e3094 = global.U[0];
                                            let _e3097 = modelTransform_1;
                                            let _e3098 = c_2;
                                            let _e3102 = X_2;
                                            let _e3104 = u_8;
                                            let _e3107 = tf(_e3097, vec2<f32>(((_e3098.x + 0.5f) + _e3102), _e3104.y));
                                            let _e3117 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3090.x / _e3094.x), _e3107.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3118 = u_8;
                                            let _e3120 = c_2;
                                            let _e3125 = X_2;
                                            let _e3128 = X_2;
                                            col = mix(_e3079, _e3117, vec4(((((_e3118.x - _e3120.x) - 0.5f) + _e3125) / (2f * _e3128))));
                                        } else {
                                            let _e3133 = modelTransform_1;
                                            let _e3134 = u_8;
                                            let _e3136 = c_2;
                                            let _e3140 = Y_2;
                                            let _e3143 = tf(_e3133, vec2<f32>(_e3134.x, ((_e3136.y + 0.5f) - _e3140)));
                                            let _e3147 = global.U[0];
                                            let _e3150 = modelTransform_1;
                                            let _e3151 = u_8;
                                            let _e3153 = c_2;
                                            let _e3157 = Y_2;
                                            let _e3160 = tf(_e3150, vec2<f32>(_e3151.x, ((_e3153.y + 0.5f) - _e3157)));
                                            let _e3170 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3143.x / _e3147.x), _e3160.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3171 = modelTransform_1;
                                            let _e3172 = u_8;
                                            let _e3174 = c_2;
                                            let _e3178 = Y_2;
                                            let _e3181 = tf(_e3171, vec2<f32>(_e3172.x, ((_e3174.y + 0.5f) + _e3178)));
                                            let _e3185 = global.U[0];
                                            let _e3188 = modelTransform_1;
                                            let _e3189 = u_8;
                                            let _e3191 = c_2;
                                            let _e3195 = Y_2;
                                            let _e3198 = tf(_e3188, vec2<f32>(_e3189.x, ((_e3191.y + 0.5f) + _e3195)));
                                            let _e3208 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3181.x / _e3185.x), _e3198.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3209 = u_8;
                                            let _e3211 = c_2;
                                            let _e3216 = Y_2;
                                            let _e3219 = Y_2;
                                            col = mix(_e3170, _e3208, vec4(((((_e3209.y - _e3211.y) - 0.5f) + _e3216) / (2f * _e3219))));
                                        }
                                    }
                                }
                            }
                        } else {
                            let _e3224 = dirTop;
                            let _e3226 = dirBottom;
                            let _e3228 = dirLeft;
                            let _e3230 = dirRight;
                            if (((!(_e3224) && _e3226) && _e3228) && !(_e3230)) {
                                {
                                    let _e3233 = c_2;
                                    center_2 = ((_e3233 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                    let _e3256 = u_8;
                                    let _e3257 = center_2;
                                    rel_2 = (_e3256 - _e3257);
                                    let _e3260 = rel_2;
                                    len_2 = length(_e3260);
                                    let _e3263 = len_2;
                                    if (_e3263 < 1f) {
                                        {
                                            let _e3266 = u_8;
                                            let _e3267 = center_2;
                                            let _e3273 = u_8;
                                            let _e3274 = center_2;
                                            a_3 = atan2(dot((_e3266 - _e3267), vec2<f32>(1f, 0f)), dot((_e3273 - _e3274), vec2<f32>(0f, -1f)));
                                            let _e3283 = modelTransform_1;
                                            let _e3284 = center_2;
                                            let _e3285 = len_2;
                                            let _e3292 = tf(_e3283, (_e3284 + (_e3285 * vec2<f32>(0f, -1f))));
                                            let _e3296 = global.U[0];
                                            let _e3299 = modelTransform_1;
                                            let _e3300 = center_2;
                                            let _e3301 = len_2;
                                            let _e3308 = tf(_e3299, (_e3300 + (_e3301 * vec2<f32>(0f, -1f))));
                                            let _e3318 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3292.x / _e3296.x), _e3308.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3319 = modelTransform_1;
                                            let _e3320 = center_2;
                                            let _e3321 = len_2;
                                            let _e3327 = tf(_e3319, (_e3320 + (_e3321 * vec2<f32>(1f, 0f))));
                                            let _e3331 = global.U[0];
                                            let _e3334 = modelTransform_1;
                                            let _e3335 = center_2;
                                            let _e3336 = len_2;
                                            let _e3342 = tf(_e3334, (_e3335 + (_e3336 * vec2<f32>(1f, 0f))));
                                            let _e3352 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3327.x / _e3331.x), _e3342.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e3353 = a_3;
                                            col = mix(_e3318, _e3352, vec4((_e3353 / 1.5707964f)));
                                        }
                                    } else {
                                        {
                                            if false {
                                                {
                                                    let _e3359 = modelTransform_1;
                                                    let _e3360 = c_2;
                                                    let _e3362 = u_8;
                                                    let _e3365 = tf(_e3359, vec2<f32>(_e3360.x, _e3362.y));
                                                    let _e3369 = global.U[0];
                                                    let _e3372 = modelTransform_1;
                                                    let _e3373 = c_2;
                                                    let _e3375 = u_8;
                                                    let _e3378 = tf(_e3372, vec2<f32>(_e3373.x, _e3375.y));
                                                    let _e3388 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3365.x / _e3369.x), _e3378.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3389 = modelTransform_1;
                                                    let _e3390 = c_2;
                                                    let _e3394 = u_8;
                                                    let _e3397 = tf(_e3389, vec2<f32>((_e3390.x + 1f), _e3394.y));
                                                    let _e3401 = global.U[0];
                                                    let _e3404 = modelTransform_1;
                                                    let _e3405 = c_2;
                                                    let _e3409 = u_8;
                                                    let _e3412 = tf(_e3404, vec2<f32>((_e3405.x + 1f), _e3409.y));
                                                    let _e3422 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3397.x / _e3401.x), _e3412.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3423 = u_8;
                                                    let _e3425 = c_2;
                                                    col = mix(_e3388, _e3422, vec4((_e3423.x - _e3425.x)));
                                                }
                                            } else {
                                                {
                                                    let _e3430 = modelTransform_1;
                                                    let _e3431 = c_2;
                                                    let _e3433 = u_8;
                                                    let _e3436 = tf(_e3430, vec2<f32>(_e3431.x, _e3433.y));
                                                    let _e3440 = global.U[0];
                                                    let _e3443 = modelTransform_1;
                                                    let _e3444 = c_2;
                                                    let _e3446 = u_8;
                                                    let _e3449 = tf(_e3443, vec2<f32>(_e3444.x, _e3446.y));
                                                    let _e3459 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3436.x / _e3440.x), _e3449.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3460 = modelTransform_1;
                                                    let _e3461 = c_2;
                                                    let _e3465 = u_8;
                                                    let _e3468 = tf(_e3460, vec2<f32>((_e3461.x + 1f), _e3465.y));
                                                    let _e3472 = global.U[0];
                                                    let _e3475 = modelTransform_1;
                                                    let _e3476 = c_2;
                                                    let _e3480 = u_8;
                                                    let _e3483 = tf(_e3475, vec2<f32>((_e3476.x + 1f), _e3480.y));
                                                    let _e3493 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3468.x / _e3472.x), _e3483.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3494 = u_8;
                                                    let _e3496 = c_2;
                                                    col = mix(_e3459, _e3493, vec4((_e3494.x - _e3496.x)));
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                let _e3501 = dirTop;
                                let _e3502 = dirBottom;
                                let _e3505 = dirLeft;
                                let _e3507 = dirRight;
                                if (((_e3501 && !(_e3502)) && _e3505) && !(_e3507)) {
                                    {
                                        let _e3510 = c_2;
                                        center_3 = ((_e3510 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                        let _e3532 = u_8;
                                        let _e3533 = center_3;
                                        rel_3 = (_e3532 - _e3533);
                                        let _e3536 = rel_3;
                                        len_3 = length(_e3536);
                                        let _e3539 = len_3;
                                        if (_e3539 < 1f) {
                                            {
                                                let _e3542 = u_8;
                                                let _e3543 = center_3;
                                                let _e3549 = u_8;
                                                let _e3550 = center_3;
                                                a_4 = atan2(dot((_e3542 - _e3543), vec2<f32>(0f, 1f)), dot((_e3549 - _e3550), vec2<f32>(1f, 0f)));
                                                let _e3558 = modelTransform_1;
                                                let _e3559 = center_3;
                                                let _e3560 = len_3;
                                                let _e3566 = tf(_e3558, (_e3559 + (_e3560 * vec2<f32>(1f, 0f))));
                                                let _e3570 = global.U[0];
                                                let _e3573 = modelTransform_1;
                                                let _e3574 = center_3;
                                                let _e3575 = len_3;
                                                let _e3581 = tf(_e3573, (_e3574 + (_e3575 * vec2<f32>(1f, 0f))));
                                                let _e3591 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3566.x / _e3570.x), _e3581.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e3592 = modelTransform_1;
                                                let _e3593 = center_3;
                                                let _e3594 = len_3;
                                                let _e3600 = tf(_e3592, (_e3593 + (_e3594 * vec2<f32>(0f, 1f))));
                                                let _e3604 = global.U[0];
                                                let _e3607 = modelTransform_1;
                                                let _e3608 = center_3;
                                                let _e3609 = len_3;
                                                let _e3615 = tf(_e3607, (_e3608 + (_e3609 * vec2<f32>(0f, 1f))));
                                                let _e3625 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3600.x / _e3604.x), _e3615.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                let _e3626 = a_4;
                                                col = mix(_e3591, _e3625, vec4((_e3626 / 1.5707964f)));
                                            }
                                        } else {
                                            {
                                                if false {
                                                    {
                                                        let _e3632 = modelTransform_1;
                                                        let _e3633 = c_2;
                                                        let _e3635 = u_8;
                                                        let _e3638 = tf(_e3632, vec2<f32>(_e3633.x, _e3635.y));
                                                        let _e3642 = global.U[0];
                                                        let _e3645 = modelTransform_1;
                                                        let _e3646 = c_2;
                                                        let _e3648 = u_8;
                                                        let _e3651 = tf(_e3645, vec2<f32>(_e3646.x, _e3648.y));
                                                        let _e3661 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3638.x / _e3642.x), _e3651.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e3662 = modelTransform_1;
                                                        let _e3663 = c_2;
                                                        let _e3667 = u_8;
                                                        let _e3670 = tf(_e3662, vec2<f32>((_e3663.x + 1f), _e3667.y));
                                                        let _e3674 = global.U[0];
                                                        let _e3677 = modelTransform_1;
                                                        let _e3678 = c_2;
                                                        let _e3682 = u_8;
                                                        let _e3685 = tf(_e3677, vec2<f32>((_e3678.x + 1f), _e3682.y));
                                                        let _e3695 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3670.x / _e3674.x), _e3685.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e3696 = u_8;
                                                        let _e3698 = c_2;
                                                        col = mix(_e3661, _e3695, vec4((_e3696.x - _e3698.x)));
                                                    }
                                                } else {
                                                    {
                                                        let _e3703 = modelTransform_1;
                                                        let _e3704 = c_2;
                                                        let _e3706 = u_8;
                                                        let _e3709 = tf(_e3703, vec2<f32>(_e3704.x, _e3706.y));
                                                        let _e3713 = global.U[0];
                                                        let _e3716 = modelTransform_1;
                                                        let _e3717 = c_2;
                                                        let _e3719 = u_8;
                                                        let _e3722 = tf(_e3716, vec2<f32>(_e3717.x, _e3719.y));
                                                        let _e3732 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3709.x / _e3713.x), _e3722.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e3733 = modelTransform_1;
                                                        let _e3734 = c_2;
                                                        let _e3738 = u_8;
                                                        let _e3741 = tf(_e3733, vec2<f32>((_e3734.x + 1f), _e3738.y));
                                                        let _e3745 = global.U[0];
                                                        let _e3748 = modelTransform_1;
                                                        let _e3749 = c_2;
                                                        let _e3753 = u_8;
                                                        let _e3756 = tf(_e3748, vec2<f32>((_e3749.x + 1f), _e3753.y));
                                                        let _e3766 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3741.x / _e3745.x), _e3756.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e3767 = u_8;
                                                        let _e3769 = c_2;
                                                        col = mix(_e3732, _e3766, vec4((_e3767.x - _e3769.x)));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    let _e3774 = dirTop;
                                    let _e3776 = dirBottom;
                                    let _e3778 = dirLeft;
                                    let _e3781 = dirRight;
                                    if (((!(_e3774) && _e3776) && !(_e3778)) && _e3781) {
                                        {
                                            let _e3783 = c_2;
                                            center_4 = ((_e3783 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                            let _e3807 = u_8;
                                            let _e3808 = center_4;
                                            rel_4 = (_e3807 - _e3808);
                                            let _e3811 = rel_4;
                                            len_4 = length(_e3811);
                                            let _e3814 = len_4;
                                            if (_e3814 < 1f) {
                                                {
                                                    let _e3817 = u_8;
                                                    let _e3818 = center_4;
                                                    let _e3825 = u_8;
                                                    let _e3826 = center_4;
                                                    a_5 = atan2(dot((_e3817 - _e3818), vec2<f32>(0f, -1f)), dot((_e3825 - _e3826), vec2<f32>(-1f, 0f)));
                                                    let _e3835 = modelTransform_1;
                                                    let _e3836 = center_4;
                                                    let _e3837 = len_4;
                                                    let _e3844 = tf(_e3835, (_e3836 + (_e3837 * vec2<f32>(-1f, 0f))));
                                                    let _e3848 = global.U[0];
                                                    let _e3851 = modelTransform_1;
                                                    let _e3852 = center_4;
                                                    let _e3853 = len_4;
                                                    let _e3860 = tf(_e3851, (_e3852 + (_e3853 * vec2<f32>(-1f, 0f))));
                                                    let _e3870 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3844.x / _e3848.x), _e3860.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3871 = modelTransform_1;
                                                    let _e3872 = center_4;
                                                    let _e3873 = len_4;
                                                    let _e3880 = tf(_e3871, (_e3872 + (_e3873 * vec2<f32>(0f, -1f))));
                                                    let _e3884 = global.U[0];
                                                    let _e3887 = modelTransform_1;
                                                    let _e3888 = center_4;
                                                    let _e3889 = len_4;
                                                    let _e3896 = tf(_e3887, (_e3888 + (_e3889 * vec2<f32>(0f, -1f))));
                                                    let _e3906 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3880.x / _e3884.x), _e3896.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e3907 = a_5;
                                                    col = mix(_e3870, _e3906, vec4((_e3907 / 1.5707964f)));
                                                }
                                            } else {
                                                {
                                                    if false {
                                                        {
                                                            let _e3913 = modelTransform_1;
                                                            let _e3914 = c_2;
                                                            let _e3916 = u_8;
                                                            let _e3919 = tf(_e3913, vec2<f32>(_e3914.x, _e3916.y));
                                                            let _e3923 = global.U[0];
                                                            let _e3926 = modelTransform_1;
                                                            let _e3927 = c_2;
                                                            let _e3929 = u_8;
                                                            let _e3932 = tf(_e3926, vec2<f32>(_e3927.x, _e3929.y));
                                                            let _e3942 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3919.x / _e3923.x), _e3932.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e3943 = modelTransform_1;
                                                            let _e3944 = c_2;
                                                            let _e3948 = u_8;
                                                            let _e3951 = tf(_e3943, vec2<f32>((_e3944.x + 1f), _e3948.y));
                                                            let _e3955 = global.U[0];
                                                            let _e3958 = modelTransform_1;
                                                            let _e3959 = c_2;
                                                            let _e3963 = u_8;
                                                            let _e3966 = tf(_e3958, vec2<f32>((_e3959.x + 1f), _e3963.y));
                                                            let _e3976 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3951.x / _e3955.x), _e3966.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e3977 = u_8;
                                                            let _e3979 = c_2;
                                                            col = mix(_e3942, _e3976, vec4((_e3977.x - _e3979.x)));
                                                        }
                                                    } else {
                                                        {
                                                            let _e3984 = modelTransform_1;
                                                            let _e3985 = c_2;
                                                            let _e3987 = u_8;
                                                            let _e3990 = tf(_e3984, vec2<f32>(_e3985.x, _e3987.y));
                                                            let _e3994 = global.U[0];
                                                            let _e3997 = modelTransform_1;
                                                            let _e3998 = c_2;
                                                            let _e4000 = u_8;
                                                            let _e4003 = tf(_e3997, vec2<f32>(_e3998.x, _e4000.y));
                                                            let _e4013 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e3990.x / _e3994.x), _e4003.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e4014 = modelTransform_1;
                                                            let _e4015 = c_2;
                                                            let _e4019 = u_8;
                                                            let _e4022 = tf(_e4014, vec2<f32>((_e4015.x + 1f), _e4019.y));
                                                            let _e4026 = global.U[0];
                                                            let _e4029 = modelTransform_1;
                                                            let _e4030 = c_2;
                                                            let _e4034 = u_8;
                                                            let _e4037 = tf(_e4029, vec2<f32>((_e4030.x + 1f), _e4034.y));
                                                            let _e4047 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4022.x / _e4026.x), _e4037.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e4048 = u_8;
                                                            let _e4050 = c_2;
                                                            col = mix(_e4013, _e4047, vec4((_e4048.x - _e4050.x)));
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        let _e4055 = dirTop;
                                        let _e4056 = dirBottom;
                                        let _e4059 = dirLeft;
                                        let _e4062 = dirRight;
                                        if (((_e4055 && !(_e4056)) && !(_e4059)) && _e4062) {
                                            {
                                                let _e4064 = c_2;
                                                center_5 = ((_e4064 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                let _e4087 = u_8;
                                                let _e4088 = center_5;
                                                rel_5 = (_e4087 - _e4088);
                                                let _e4091 = rel_5;
                                                len_5 = length(_e4091);
                                                let _e4094 = len_5;
                                                if (_e4094 < 1f) {
                                                    {
                                                        let _e4097 = u_8;
                                                        let _e4098 = center_5;
                                                        let _e4105 = u_8;
                                                        let _e4106 = center_5;
                                                        a_6 = atan2(dot((_e4097 - _e4098), vec2<f32>(-1f, 0f)), dot((_e4105 - _e4106), vec2<f32>(0f, 1f)));
                                                        let _e4114 = modelTransform_1;
                                                        let _e4115 = center_5;
                                                        let _e4116 = len_5;
                                                        let _e4122 = tf(_e4114, (_e4115 + (_e4116 * vec2<f32>(0f, 1f))));
                                                        let _e4126 = global.U[0];
                                                        let _e4129 = modelTransform_1;
                                                        let _e4130 = center_5;
                                                        let _e4131 = len_5;
                                                        let _e4137 = tf(_e4129, (_e4130 + (_e4131 * vec2<f32>(0f, 1f))));
                                                        let _e4147 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4122.x / _e4126.x), _e4137.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e4148 = modelTransform_1;
                                                        let _e4149 = center_5;
                                                        let _e4150 = len_5;
                                                        let _e4157 = tf(_e4148, (_e4149 + (_e4150 * vec2<f32>(-1f, 0f))));
                                                        let _e4161 = global.U[0];
                                                        let _e4164 = modelTransform_1;
                                                        let _e4165 = center_5;
                                                        let _e4166 = len_5;
                                                        let _e4173 = tf(_e4164, (_e4165 + (_e4166 * vec2<f32>(-1f, 0f))));
                                                        let _e4183 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4157.x / _e4161.x), _e4173.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e4184 = a_6;
                                                        col = mix(_e4147, _e4183, vec4((_e4184 / 1.5707964f)));
                                                    }
                                                } else {
                                                    {
                                                        if false {
                                                            {
                                                                let _e4190 = modelTransform_1;
                                                                let _e4191 = c_2;
                                                                let _e4193 = u_8;
                                                                let _e4196 = tf(_e4190, vec2<f32>(_e4191.x, _e4193.y));
                                                                let _e4200 = global.U[0];
                                                                let _e4203 = modelTransform_1;
                                                                let _e4204 = c_2;
                                                                let _e4206 = u_8;
                                                                let _e4209 = tf(_e4203, vec2<f32>(_e4204.x, _e4206.y));
                                                                let _e4219 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4196.x / _e4200.x), _e4209.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                let _e4220 = modelTransform_1;
                                                                let _e4221 = c_2;
                                                                let _e4225 = u_8;
                                                                let _e4228 = tf(_e4220, vec2<f32>((_e4221.x + 1f), _e4225.y));
                                                                let _e4232 = global.U[0];
                                                                let _e4235 = modelTransform_1;
                                                                let _e4236 = c_2;
                                                                let _e4240 = u_8;
                                                                let _e4243 = tf(_e4235, vec2<f32>((_e4236.x + 1f), _e4240.y));
                                                                let _e4253 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4228.x / _e4232.x), _e4243.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                let _e4254 = u_8;
                                                                let _e4256 = c_2;
                                                                col = mix(_e4219, _e4253, vec4((_e4254.x - _e4256.x)));
                                                            }
                                                        } else {
                                                            {
                                                                let _e4261 = modelTransform_1;
                                                                let _e4262 = c_2;
                                                                let _e4264 = u_8;
                                                                let _e4267 = tf(_e4261, vec2<f32>(_e4262.x, _e4264.y));
                                                                let _e4271 = global.U[0];
                                                                let _e4274 = modelTransform_1;
                                                                let _e4275 = c_2;
                                                                let _e4277 = u_8;
                                                                let _e4280 = tf(_e4274, vec2<f32>(_e4275.x, _e4277.y));
                                                                let _e4290 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4267.x / _e4271.x), _e4280.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                let _e4291 = modelTransform_1;
                                                                let _e4292 = c_2;
                                                                let _e4296 = u_8;
                                                                let _e4299 = tf(_e4291, vec2<f32>((_e4292.x + 1f), _e4296.y));
                                                                let _e4303 = global.U[0];
                                                                let _e4306 = modelTransform_1;
                                                                let _e4307 = c_2;
                                                                let _e4311 = u_8;
                                                                let _e4314 = tf(_e4306, vec2<f32>((_e4307.x + 1f), _e4311.y));
                                                                let _e4324 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4299.x / _e4303.x), _e4314.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                let _e4325 = u_8;
                                                                let _e4327 = c_2;
                                                                col = mix(_e4290, _e4324, vec4((_e4325.x - _e4327.x)));
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            let _e4332 = dirTop;
                                            let _e4334 = dirBottom;
                                            let _e4337 = dirLeft;
                                            let _e4339 = dirRight;
                                            if (((!(_e4332) && !(_e4334)) && _e4337) && !(_e4339)) {
                                                {
                                                    let _e4342 = c_2;
                                                    let _e4343 = randomSeed_1;
                                                    let _e4344 = regularity_6;
                                                    let _e4345 = rnd2_(_e4342, _e4343, _e4344);
                                                    if (_e4345 < 0.5f) {
                                                        {
                                                            let _e4348 = c_2;
                                                            center_6 = ((_e4348 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                                            let _e4371 = u_8;
                                                            let _e4372 = center_6;
                                                            rel_6 = (_e4371 - _e4372);
                                                            let _e4375 = rel_6;
                                                            len_6 = length(_e4375);
                                                            let _e4378 = len_6;
                                                            if (_e4378 < 1f) {
                                                                {
                                                                    let _e4381 = u_8;
                                                                    let _e4382 = center_6;
                                                                    let _e4388 = u_8;
                                                                    let _e4389 = center_6;
                                                                    a_7 = atan2(dot((_e4381 - _e4382), vec2<f32>(1f, 0f)), dot((_e4388 - _e4389), vec2<f32>(0f, -1f)));
                                                                    let _e4398 = modelTransform_1;
                                                                    let _e4399 = center_6;
                                                                    let _e4400 = len_6;
                                                                    let _e4407 = tf(_e4398, (_e4399 + (_e4400 * vec2<f32>(0f, -1f))));
                                                                    let _e4411 = global.U[0];
                                                                    let _e4414 = modelTransform_1;
                                                                    let _e4415 = center_6;
                                                                    let _e4416 = len_6;
                                                                    let _e4423 = tf(_e4414, (_e4415 + (_e4416 * vec2<f32>(0f, -1f))));
                                                                    let _e4433 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4407.x / _e4411.x), _e4423.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4434 = modelTransform_1;
                                                                    let _e4435 = center_6;
                                                                    let _e4436 = len_6;
                                                                    let _e4442 = tf(_e4434, (_e4435 + (_e4436 * vec2<f32>(1f, 0f))));
                                                                    let _e4446 = global.U[0];
                                                                    let _e4449 = modelTransform_1;
                                                                    let _e4450 = center_6;
                                                                    let _e4451 = len_6;
                                                                    let _e4457 = tf(_e4449, (_e4450 + (_e4451 * vec2<f32>(1f, 0f))));
                                                                    let _e4467 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4442.x / _e4446.x), _e4457.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4468 = a_7;
                                                                    col = mix(_e4433, _e4467, vec4((_e4468 / 1.5707964f)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e4473 = modelTransform_1;
                                                                    let _e4474 = u_8;
                                                                    let _e4476 = c_2;
                                                                    let _e4479 = tf(_e4473, vec2<f32>(_e4474.x, _e4476.y));
                                                                    let _e4483 = global.U[0];
                                                                    let _e4486 = modelTransform_1;
                                                                    let _e4487 = u_8;
                                                                    let _e4489 = c_2;
                                                                    let _e4492 = tf(_e4486, vec2<f32>(_e4487.x, _e4489.y));
                                                                    let _e4502 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4479.x / _e4483.x), _e4492.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4503 = modelTransform_1;
                                                                    let _e4504 = u_8;
                                                                    let _e4506 = c_2;
                                                                    let _e4511 = tf(_e4503, vec2<f32>(_e4504.x, (_e4506.y + 1f)));
                                                                    let _e4515 = global.U[0];
                                                                    let _e4518 = modelTransform_1;
                                                                    let _e4519 = u_8;
                                                                    let _e4521 = c_2;
                                                                    let _e4526 = tf(_e4518, vec2<f32>(_e4519.x, (_e4521.y + 1f)));
                                                                    let _e4536 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4511.x / _e4515.x), _e4526.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4537 = u_8;
                                                                    let _e4539 = c_2;
                                                                    col = mix(_e4502, _e4536, vec4((_e4537.y - _e4539.y)));
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        {
                                                            let _e4544 = c_2;
                                                            center_7 = ((_e4544 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                                            let _e4566 = u_8;
                                                            let _e4567 = center_7;
                                                            rel_7 = (_e4566 - _e4567);
                                                            let _e4570 = rel_7;
                                                            len_7 = length(_e4570);
                                                            let _e4573 = len_7;
                                                            if (_e4573 < 1f) {
                                                                {
                                                                    let _e4576 = u_8;
                                                                    let _e4577 = center_7;
                                                                    let _e4583 = u_8;
                                                                    let _e4584 = center_7;
                                                                    a_8 = atan2(dot((_e4576 - _e4577), vec2<f32>(0f, 1f)), dot((_e4583 - _e4584), vec2<f32>(1f, 0f)));
                                                                    let _e4592 = modelTransform_1;
                                                                    let _e4593 = center_7;
                                                                    let _e4594 = len_7;
                                                                    let _e4600 = tf(_e4592, (_e4593 + (_e4594 * vec2<f32>(1f, 0f))));
                                                                    let _e4604 = global.U[0];
                                                                    let _e4607 = modelTransform_1;
                                                                    let _e4608 = center_7;
                                                                    let _e4609 = len_7;
                                                                    let _e4615 = tf(_e4607, (_e4608 + (_e4609 * vec2<f32>(1f, 0f))));
                                                                    let _e4625 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4600.x / _e4604.x), _e4615.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4626 = modelTransform_1;
                                                                    let _e4627 = center_7;
                                                                    let _e4628 = len_7;
                                                                    let _e4634 = tf(_e4626, (_e4627 + (_e4628 * vec2<f32>(0f, 1f))));
                                                                    let _e4638 = global.U[0];
                                                                    let _e4641 = modelTransform_1;
                                                                    let _e4642 = center_7;
                                                                    let _e4643 = len_7;
                                                                    let _e4649 = tf(_e4641, (_e4642 + (_e4643 * vec2<f32>(0f, 1f))));
                                                                    let _e4659 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4634.x / _e4638.x), _e4649.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4660 = a_8;
                                                                    col = mix(_e4625, _e4659, vec4((_e4660 / 1.5707964f)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e4665 = modelTransform_1;
                                                                    let _e4666 = u_8;
                                                                    let _e4668 = c_2;
                                                                    let _e4671 = tf(_e4665, vec2<f32>(_e4666.x, _e4668.y));
                                                                    let _e4675 = global.U[0];
                                                                    let _e4678 = modelTransform_1;
                                                                    let _e4679 = u_8;
                                                                    let _e4681 = c_2;
                                                                    let _e4684 = tf(_e4678, vec2<f32>(_e4679.x, _e4681.y));
                                                                    let _e4694 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4671.x / _e4675.x), _e4684.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4695 = modelTransform_1;
                                                                    let _e4696 = u_8;
                                                                    let _e4698 = c_2;
                                                                    let _e4703 = tf(_e4695, vec2<f32>(_e4696.x, (_e4698.y + 1f)));
                                                                    let _e4707 = global.U[0];
                                                                    let _e4710 = modelTransform_1;
                                                                    let _e4711 = u_8;
                                                                    let _e4713 = c_2;
                                                                    let _e4718 = tf(_e4710, vec2<f32>(_e4711.x, (_e4713.y + 1f)));
                                                                    let _e4728 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4703.x / _e4707.x), _e4718.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e4729 = u_8;
                                                                    let _e4731 = c_2;
                                                                    col = mix(_e4694, _e4728, vec4((_e4729.y - _e4731.y)));
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e4736 = dirTop;
                                                let _e4738 = dirBottom;
                                                let _e4741 = dirLeft;
                                                let _e4744 = dirRight;
                                                if (((!(_e4736) && !(_e4738)) && !(_e4741)) && _e4744) {
                                                    {
                                                        let _e4746 = c_2;
                                                        let _e4747 = randomSeed_1;
                                                        let _e4748 = regularity_6;
                                                        let _e4749 = rnd2_(_e4746, _e4747, _e4748);
                                                        if (_e4749 < 0.5f) {
                                                            {
                                                                let _e4752 = c_2;
                                                                center_8 = ((_e4752 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                                let _e4775 = u_8;
                                                                let _e4776 = center_8;
                                                                rel_8 = (_e4775 - _e4776);
                                                                let _e4779 = rel_8;
                                                                len_8 = length(_e4779);
                                                                let _e4782 = len_8;
                                                                if (_e4782 < 1f) {
                                                                    {
                                                                        let _e4785 = u_8;
                                                                        let _e4786 = center_8;
                                                                        let _e4793 = u_8;
                                                                        let _e4794 = center_8;
                                                                        a_9 = atan2(dot((_e4785 - _e4786), vec2<f32>(-1f, 0f)), dot((_e4793 - _e4794), vec2<f32>(0f, 1f)));
                                                                        let _e4802 = modelTransform_1;
                                                                        let _e4803 = center_8;
                                                                        let _e4804 = len_8;
                                                                        let _e4810 = tf(_e4802, (_e4803 + (_e4804 * vec2<f32>(0f, 1f))));
                                                                        let _e4814 = global.U[0];
                                                                        let _e4817 = modelTransform_1;
                                                                        let _e4818 = center_8;
                                                                        let _e4819 = len_8;
                                                                        let _e4825 = tf(_e4817, (_e4818 + (_e4819 * vec2<f32>(0f, 1f))));
                                                                        let _e4835 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4810.x / _e4814.x), _e4825.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e4836 = modelTransform_1;
                                                                        let _e4837 = center_8;
                                                                        let _e4838 = len_8;
                                                                        let _e4845 = tf(_e4836, (_e4837 + (_e4838 * vec2<f32>(-1f, 0f))));
                                                                        let _e4849 = global.U[0];
                                                                        let _e4852 = modelTransform_1;
                                                                        let _e4853 = center_8;
                                                                        let _e4854 = len_8;
                                                                        let _e4861 = tf(_e4852, (_e4853 + (_e4854 * vec2<f32>(-1f, 0f))));
                                                                        let _e4871 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4845.x / _e4849.x), _e4861.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e4872 = a_9;
                                                                        col = mix(_e4835, _e4871, vec4((_e4872 / 1.5707964f)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e4877 = modelTransform_1;
                                                                        let _e4878 = u_8;
                                                                        let _e4880 = c_2;
                                                                        let _e4883 = tf(_e4877, vec2<f32>(_e4878.x, _e4880.y));
                                                                        let _e4887 = global.U[0];
                                                                        let _e4890 = modelTransform_1;
                                                                        let _e4891 = u_8;
                                                                        let _e4893 = c_2;
                                                                        let _e4896 = tf(_e4890, vec2<f32>(_e4891.x, _e4893.y));
                                                                        let _e4906 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4883.x / _e4887.x), _e4896.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e4907 = modelTransform_1;
                                                                        let _e4908 = u_8;
                                                                        let _e4910 = c_2;
                                                                        let _e4915 = tf(_e4907, vec2<f32>(_e4908.x, (_e4910.y + 1f)));
                                                                        let _e4919 = global.U[0];
                                                                        let _e4922 = modelTransform_1;
                                                                        let _e4923 = u_8;
                                                                        let _e4925 = c_2;
                                                                        let _e4930 = tf(_e4922, vec2<f32>(_e4923.x, (_e4925.y + 1f)));
                                                                        let _e4940 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e4915.x / _e4919.x), _e4930.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e4941 = u_8;
                                                                        let _e4943 = c_2;
                                                                        col = mix(_e4906, _e4940, vec4((_e4941.y - _e4943.y)));
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            {
                                                                let _e4948 = c_2;
                                                                center_9 = ((_e4948 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                                                let _e4972 = u_8;
                                                                let _e4973 = center_9;
                                                                rel_9 = (_e4972 - _e4973);
                                                                let _e4976 = rel_9;
                                                                len_9 = length(_e4976);
                                                                let _e4979 = len_9;
                                                                if (_e4979 < 1f) {
                                                                    {
                                                                        let _e4982 = u_8;
                                                                        let _e4983 = center_9;
                                                                        let _e4990 = u_8;
                                                                        let _e4991 = center_9;
                                                                        a_10 = atan2(dot((_e4982 - _e4983), vec2<f32>(0f, -1f)), dot((_e4990 - _e4991), vec2<f32>(-1f, 0f)));
                                                                        let _e5000 = modelTransform_1;
                                                                        let _e5001 = center_9;
                                                                        let _e5002 = len_9;
                                                                        let _e5009 = tf(_e5000, (_e5001 + (_e5002 * vec2<f32>(-1f, 0f))));
                                                                        let _e5013 = global.U[0];
                                                                        let _e5016 = modelTransform_1;
                                                                        let _e5017 = center_9;
                                                                        let _e5018 = len_9;
                                                                        let _e5025 = tf(_e5016, (_e5017 + (_e5018 * vec2<f32>(-1f, 0f))));
                                                                        let _e5035 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5009.x / _e5013.x), _e5025.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5036 = modelTransform_1;
                                                                        let _e5037 = center_9;
                                                                        let _e5038 = len_9;
                                                                        let _e5045 = tf(_e5036, (_e5037 + (_e5038 * vec2<f32>(0f, -1f))));
                                                                        let _e5049 = global.U[0];
                                                                        let _e5052 = modelTransform_1;
                                                                        let _e5053 = center_9;
                                                                        let _e5054 = len_9;
                                                                        let _e5061 = tf(_e5052, (_e5053 + (_e5054 * vec2<f32>(0f, -1f))));
                                                                        let _e5071 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5045.x / _e5049.x), _e5061.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5072 = a_10;
                                                                        col = mix(_e5035, _e5071, vec4((_e5072 / 1.5707964f)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e5077 = modelTransform_1;
                                                                        let _e5078 = u_8;
                                                                        let _e5080 = c_2;
                                                                        let _e5083 = tf(_e5077, vec2<f32>(_e5078.x, _e5080.y));
                                                                        let _e5087 = global.U[0];
                                                                        let _e5090 = modelTransform_1;
                                                                        let _e5091 = u_8;
                                                                        let _e5093 = c_2;
                                                                        let _e5096 = tf(_e5090, vec2<f32>(_e5091.x, _e5093.y));
                                                                        let _e5106 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5083.x / _e5087.x), _e5096.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5107 = modelTransform_1;
                                                                        let _e5108 = u_8;
                                                                        let _e5110 = c_2;
                                                                        let _e5115 = tf(_e5107, vec2<f32>(_e5108.x, (_e5110.y + 1f)));
                                                                        let _e5119 = global.U[0];
                                                                        let _e5122 = modelTransform_1;
                                                                        let _e5123 = u_8;
                                                                        let _e5125 = c_2;
                                                                        let _e5130 = tf(_e5122, vec2<f32>(_e5123.x, (_e5125.y + 1f)));
                                                                        let _e5140 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5115.x / _e5119.x), _e5130.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5141 = u_8;
                                                                        let _e5143 = c_2;
                                                                        col = mix(_e5106, _e5140, vec4((_e5141.y - _e5143.y)));
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e5148 = dirTop;
                                                    let _e5149 = dirBottom;
                                                    let _e5152 = dirLeft;
                                                    let _e5155 = dirRight;
                                                    if (((_e5148 && !(_e5149)) && !(_e5152)) && !(_e5155)) {
                                                        {
                                                            if false {
                                                                {
                                                                    let _e5159 = modelTransform_1;
                                                                    let _e5160 = u_8;
                                                                    let _e5162 = c_2;
                                                                    let _e5165 = tf(_e5159, vec2<f32>(_e5160.x, _e5162.y));
                                                                    let _e5169 = global.U[0];
                                                                    let _e5172 = modelTransform_1;
                                                                    let _e5173 = u_8;
                                                                    let _e5175 = c_2;
                                                                    let _e5178 = tf(_e5172, vec2<f32>(_e5173.x, _e5175.y));
                                                                    let _e5188 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5165.x / _e5169.x), _e5178.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e5189 = modelTransform_1;
                                                                    let _e5190 = u_8;
                                                                    let _e5192 = c_2;
                                                                    let _e5197 = tf(_e5189, vec2<f32>(_e5190.x, (_e5192.y + 1f)));
                                                                    let _e5201 = global.U[0];
                                                                    let _e5204 = modelTransform_1;
                                                                    let _e5205 = u_8;
                                                                    let _e5207 = c_2;
                                                                    let _e5212 = tf(_e5204, vec2<f32>(_e5205.x, (_e5207.y + 1f)));
                                                                    let _e5222 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5197.x / _e5201.x), _e5212.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                    let _e5223 = u_8;
                                                                    let _e5225 = c_2;
                                                                    col = mix(_e5188, _e5222, vec4((_e5223.y - _e5225.y)));
                                                                }
                                                            } else {
                                                                {
                                                                    let _e5230 = c_2;
                                                                    let _e5234 = u_8;
                                                                    let _e5236 = c_2;
                                                                    Y_3 = ((_e5230.y + 0.5f) + abs(((_e5234.x - _e5236.x) - 0.5f)));
                                                                    let _e5244 = u_8;
                                                                    let _e5246 = Y_3;
                                                                    if (_e5244.y < _e5246) {
                                                                        let _e5248 = modelTransform_1;
                                                                        let _e5249 = u_8;
                                                                        let _e5251 = c_2;
                                                                        let _e5254 = tf(_e5248, vec2<f32>(_e5249.x, _e5251.y));
                                                                        let _e5258 = global.U[0];
                                                                        let _e5261 = modelTransform_1;
                                                                        let _e5262 = u_8;
                                                                        let _e5264 = c_2;
                                                                        let _e5267 = tf(_e5261, vec2<f32>(_e5262.x, _e5264.y));
                                                                        let _e5277 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5254.x / _e5258.x), _e5267.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5278 = modelTransform_1;
                                                                        let _e5279 = u_8;
                                                                        let _e5281 = Y_3;
                                                                        let _e5283 = tf(_e5278, vec2<f32>(_e5279.x, _e5281));
                                                                        let _e5287 = global.U[0];
                                                                        let _e5290 = modelTransform_1;
                                                                        let _e5291 = u_8;
                                                                        let _e5293 = Y_3;
                                                                        let _e5295 = tf(_e5290, vec2<f32>(_e5291.x, _e5293));
                                                                        let _e5305 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5283.x / _e5287.x), _e5295.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5306 = u_8;
                                                                        let _e5308 = c_2;
                                                                        let _e5311 = Y_3;
                                                                        let _e5312 = c_2;
                                                                        col = mix(_e5277, _e5305, vec4(((_e5306.y - _e5308.y) / (_e5311 - _e5312.y))));
                                                                    } else {
                                                                        {
                                                                            let _e5318 = u_8;
                                                                            let _e5320 = c_2;
                                                                            X_3 = abs(((_e5318.y - _e5320.y) - 0.5f));
                                                                            let _e5327 = modelTransform_1;
                                                                            let _e5328 = c_2;
                                                                            let _e5332 = X_3;
                                                                            let _e5334 = u_8;
                                                                            let _e5337 = tf(_e5327, vec2<f32>(((_e5328.x + 0.5f) - _e5332), _e5334.y));
                                                                            let _e5341 = global.U[0];
                                                                            let _e5344 = modelTransform_1;
                                                                            let _e5345 = c_2;
                                                                            let _e5349 = X_3;
                                                                            let _e5351 = u_8;
                                                                            let _e5354 = tf(_e5344, vec2<f32>(((_e5345.x + 0.5f) - _e5349), _e5351.y));
                                                                            let _e5364 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5337.x / _e5341.x), _e5354.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                            let _e5365 = modelTransform_1;
                                                                            let _e5366 = c_2;
                                                                            let _e5370 = X_3;
                                                                            let _e5372 = u_8;
                                                                            let _e5375 = tf(_e5365, vec2<f32>(((_e5366.x + 0.5f) + _e5370), _e5372.y));
                                                                            let _e5379 = global.U[0];
                                                                            let _e5382 = modelTransform_1;
                                                                            let _e5383 = c_2;
                                                                            let _e5387 = X_3;
                                                                            let _e5389 = u_8;
                                                                            let _e5392 = tf(_e5382, vec2<f32>(((_e5383.x + 0.5f) + _e5387), _e5389.y));
                                                                            let _e5402 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5375.x / _e5379.x), _e5392.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                            let _e5403 = u_8;
                                                                            let _e5405 = c_2;
                                                                            let _e5410 = X_3;
                                                                            let _e5413 = X_3;
                                                                            col = mix(_e5364, _e5402, vec4(((((_e5403.x - _e5405.x) - 0.5f) + _e5410) / (2f * _e5413))));
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e5418 = dirTop;
                                                        let _e5420 = dirBottom;
                                                        let _e5422 = dirLeft;
                                                        let _e5425 = dirRight;
                                                        if (((!(_e5418) && _e5420) && !(_e5422)) && !(_e5425)) {
                                                            {
                                                                if false {
                                                                    {
                                                                        let _e5429 = modelTransform_1;
                                                                        let _e5430 = u_8;
                                                                        let _e5432 = c_2;
                                                                        let _e5435 = tf(_e5429, vec2<f32>(_e5430.x, _e5432.y));
                                                                        let _e5439 = global.U[0];
                                                                        let _e5442 = modelTransform_1;
                                                                        let _e5443 = u_8;
                                                                        let _e5445 = c_2;
                                                                        let _e5448 = tf(_e5442, vec2<f32>(_e5443.x, _e5445.y));
                                                                        let _e5458 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5435.x / _e5439.x), _e5448.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5459 = modelTransform_1;
                                                                        let _e5460 = u_8;
                                                                        let _e5462 = c_2;
                                                                        let _e5467 = tf(_e5459, vec2<f32>(_e5460.x, (_e5462.y + 1f)));
                                                                        let _e5471 = global.U[0];
                                                                        let _e5474 = modelTransform_1;
                                                                        let _e5475 = u_8;
                                                                        let _e5477 = c_2;
                                                                        let _e5482 = tf(_e5474, vec2<f32>(_e5475.x, (_e5477.y + 1f)));
                                                                        let _e5492 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5467.x / _e5471.x), _e5482.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                        let _e5493 = u_8;
                                                                        let _e5495 = c_2;
                                                                        col = mix(_e5458, _e5492, vec4((_e5493.y - _e5495.y)));
                                                                    }
                                                                } else {
                                                                    {
                                                                        let _e5500 = c_2;
                                                                        let _e5504 = u_8;
                                                                        let _e5506 = c_2;
                                                                        Y_4 = ((_e5500.y + 0.5f) - abs(((_e5504.x - _e5506.x) - 0.5f)));
                                                                        let _e5514 = u_8;
                                                                        let _e5516 = Y_4;
                                                                        if (_e5514.y > _e5516) {
                                                                            let _e5518 = modelTransform_1;
                                                                            let _e5519 = u_8;
                                                                            let _e5521 = Y_4;
                                                                            let _e5523 = tf(_e5518, vec2<f32>(_e5519.x, _e5521));
                                                                            let _e5527 = global.U[0];
                                                                            let _e5530 = modelTransform_1;
                                                                            let _e5531 = u_8;
                                                                            let _e5533 = Y_4;
                                                                            let _e5535 = tf(_e5530, vec2<f32>(_e5531.x, _e5533));
                                                                            let _e5545 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5523.x / _e5527.x), _e5535.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                            let _e5546 = modelTransform_1;
                                                                            let _e5547 = u_8;
                                                                            let _e5549 = c_2;
                                                                            let _e5554 = tf(_e5546, vec2<f32>(_e5547.x, (_e5549.y + 1f)));
                                                                            let _e5558 = global.U[0];
                                                                            let _e5561 = modelTransform_1;
                                                                            let _e5562 = u_8;
                                                                            let _e5564 = c_2;
                                                                            let _e5569 = tf(_e5561, vec2<f32>(_e5562.x, (_e5564.y + 1f)));
                                                                            let _e5579 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5554.x / _e5558.x), _e5569.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                            let _e5580 = u_8;
                                                                            let _e5582 = Y_4;
                                                                            let _e5584 = c_2;
                                                                            let _e5588 = Y_4;
                                                                            col = mix(_e5545, _e5579, vec4(((_e5580.y - _e5582) / ((_e5584.y + 1f) - _e5588))));
                                                                        } else {
                                                                            {
                                                                                let _e5593 = u_8;
                                                                                let _e5595 = c_2;
                                                                                X_4 = abs(((_e5593.y - _e5595.y) - 0.5f));
                                                                                let _e5602 = modelTransform_1;
                                                                                let _e5603 = c_2;
                                                                                let _e5607 = X_4;
                                                                                let _e5609 = u_8;
                                                                                let _e5612 = tf(_e5602, vec2<f32>(((_e5603.x + 0.5f) - _e5607), _e5609.y));
                                                                                let _e5616 = global.U[0];
                                                                                let _e5619 = modelTransform_1;
                                                                                let _e5620 = c_2;
                                                                                let _e5624 = X_4;
                                                                                let _e5626 = u_8;
                                                                                let _e5629 = tf(_e5619, vec2<f32>(((_e5620.x + 0.5f) - _e5624), _e5626.y));
                                                                                let _e5639 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5612.x / _e5616.x), _e5629.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5640 = modelTransform_1;
                                                                                let _e5641 = c_2;
                                                                                let _e5645 = X_4;
                                                                                let _e5647 = u_8;
                                                                                let _e5650 = tf(_e5640, vec2<f32>(((_e5641.x + 0.5f) + _e5645), _e5647.y));
                                                                                let _e5654 = global.U[0];
                                                                                let _e5657 = modelTransform_1;
                                                                                let _e5658 = c_2;
                                                                                let _e5662 = X_4;
                                                                                let _e5664 = u_8;
                                                                                let _e5667 = tf(_e5657, vec2<f32>(((_e5658.x + 0.5f) + _e5662), _e5664.y));
                                                                                let _e5677 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5650.x / _e5654.x), _e5667.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5678 = u_8;
                                                                                let _e5680 = c_2;
                                                                                let _e5685 = X_4;
                                                                                let _e5688 = X_4;
                                                                                col = mix(_e5639, _e5677, vec4(((((_e5678.x - _e5680.x) - 0.5f) + _e5685) / (2f * _e5688))));
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e5693 = dirTop;
                                                            let _e5695 = dirBottom;
                                                            let _e5698 = dirLeft;
                                                            let _e5700 = dirRight;
                                                            if (((!(_e5693) && !(_e5695)) && _e5698) && _e5700) {
                                                                {
                                                                    {
                                                                        let _e5706 = c_2;
                                                                        center_10 = ((_e5706 + vec2(0.5f)) - vec2<f32>(0.5f, 0.5f));
                                                                        let _e5728 = u_8;
                                                                        let _e5729 = center_10;
                                                                        rel_10 = (_e5728 - _e5729);
                                                                        let _e5732 = rel_10;
                                                                        len_10 = length(_e5732);
                                                                        let _e5735 = len_10;
                                                                        if (_e5735 < 1f) {
                                                                            {
                                                                                let _e5738 = u_8;
                                                                                let _e5739 = center_10;
                                                                                let _e5745 = u_8;
                                                                                let _e5746 = center_10;
                                                                                a_11 = atan2(dot((_e5738 - _e5739), vec2<f32>(0f, 1f)), dot((_e5745 - _e5746), vec2<f32>(1f, 0f)));
                                                                                let _e5754 = modelTransform_1;
                                                                                let _e5755 = center_10;
                                                                                let _e5756 = len_10;
                                                                                let _e5762 = tf(_e5754, (_e5755 + (_e5756 * vec2<f32>(1f, 0f))));
                                                                                let _e5766 = global.U[0];
                                                                                let _e5769 = modelTransform_1;
                                                                                let _e5770 = center_10;
                                                                                let _e5771 = len_10;
                                                                                let _e5777 = tf(_e5769, (_e5770 + (_e5771 * vec2<f32>(1f, 0f))));
                                                                                let _e5787 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5762.x / _e5766.x), _e5777.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5788 = modelTransform_1;
                                                                                let _e5789 = center_10;
                                                                                let _e5790 = len_10;
                                                                                let _e5796 = tf(_e5788, (_e5789 + (_e5790 * vec2<f32>(0f, 1f))));
                                                                                let _e5800 = global.U[0];
                                                                                let _e5803 = modelTransform_1;
                                                                                let _e5804 = center_10;
                                                                                let _e5805 = len_10;
                                                                                let _e5811 = tf(_e5803, (_e5804 + (_e5805 * vec2<f32>(0f, 1f))));
                                                                                let _e5821 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5796.x / _e5800.x), _e5811.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5822 = a_11;
                                                                                col1_ = mix(_e5787, _e5821, vec4((_e5822 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col1_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e5829 = c_2;
                                                                        center_11 = ((_e5829 + vec2(0.5f)) - vec2<f32>(0.5f, -0.5f));
                                                                        let _e5852 = u_8;
                                                                        let _e5853 = center_11;
                                                                        rel_11 = (_e5852 - _e5853);
                                                                        let _e5856 = rel_11;
                                                                        len_11 = length(_e5856);
                                                                        let _e5859 = len_11;
                                                                        if (_e5859 < 1f) {
                                                                            {
                                                                                let _e5862 = u_8;
                                                                                let _e5863 = center_11;
                                                                                let _e5869 = u_8;
                                                                                let _e5870 = center_11;
                                                                                a_12 = atan2(dot((_e5862 - _e5863), vec2<f32>(1f, 0f)), dot((_e5869 - _e5870), vec2<f32>(0f, -1f)));
                                                                                let _e5879 = modelTransform_1;
                                                                                let _e5880 = center_11;
                                                                                let _e5881 = len_11;
                                                                                let _e5888 = tf(_e5879, (_e5880 + (_e5881 * vec2<f32>(0f, -1f))));
                                                                                let _e5892 = global.U[0];
                                                                                let _e5895 = modelTransform_1;
                                                                                let _e5896 = center_11;
                                                                                let _e5897 = len_11;
                                                                                let _e5904 = tf(_e5895, (_e5896 + (_e5897 * vec2<f32>(0f, -1f))));
                                                                                let _e5914 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5888.x / _e5892.x), _e5904.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5915 = modelTransform_1;
                                                                                let _e5916 = center_11;
                                                                                let _e5917 = len_11;
                                                                                let _e5923 = tf(_e5915, (_e5916 + (_e5917 * vec2<f32>(1f, 0f))));
                                                                                let _e5927 = global.U[0];
                                                                                let _e5930 = modelTransform_1;
                                                                                let _e5931 = center_11;
                                                                                let _e5932 = len_11;
                                                                                let _e5938 = tf(_e5930, (_e5931 + (_e5932 * vec2<f32>(1f, 0f))));
                                                                                let _e5948 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e5923.x / _e5927.x), _e5938.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e5949 = a_12;
                                                                                col2_ = mix(_e5914, _e5948, vec4((_e5949 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col2_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e5956 = c_2;
                                                                        center_12 = ((_e5956 + vec2(0.5f)) - vec2<f32>(-0.5f, -0.5f));
                                                                        let _e5980 = u_8;
                                                                        let _e5981 = center_12;
                                                                        rel_12 = (_e5980 - _e5981);
                                                                        let _e5984 = rel_12;
                                                                        len_12 = length(_e5984);
                                                                        let _e5987 = len_12;
                                                                        if (_e5987 < 1f) {
                                                                            {
                                                                                let _e5990 = u_8;
                                                                                let _e5991 = center_12;
                                                                                let _e5998 = u_8;
                                                                                let _e5999 = center_12;
                                                                                a_13 = atan2(dot((_e5990 - _e5991), vec2<f32>(0f, -1f)), dot((_e5998 - _e5999), vec2<f32>(-1f, 0f)));
                                                                                let _e6008 = modelTransform_1;
                                                                                let _e6009 = center_12;
                                                                                let _e6010 = len_12;
                                                                                let _e6017 = tf(_e6008, (_e6009 + (_e6010 * vec2<f32>(-1f, 0f))));
                                                                                let _e6021 = global.U[0];
                                                                                let _e6024 = modelTransform_1;
                                                                                let _e6025 = center_12;
                                                                                let _e6026 = len_12;
                                                                                let _e6033 = tf(_e6024, (_e6025 + (_e6026 * vec2<f32>(-1f, 0f))));
                                                                                let _e6043 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e6017.x / _e6021.x), _e6033.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e6044 = modelTransform_1;
                                                                                let _e6045 = center_12;
                                                                                let _e6046 = len_12;
                                                                                let _e6053 = tf(_e6044, (_e6045 + (_e6046 * vec2<f32>(0f, -1f))));
                                                                                let _e6057 = global.U[0];
                                                                                let _e6060 = modelTransform_1;
                                                                                let _e6061 = center_12;
                                                                                let _e6062 = len_12;
                                                                                let _e6069 = tf(_e6060, (_e6061 + (_e6062 * vec2<f32>(0f, -1f))));
                                                                                let _e6079 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e6053.x / _e6057.x), _e6069.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e6080 = a_13;
                                                                                col3_ = mix(_e6043, _e6079, vec4((_e6080 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col3_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    {
                                                                        let _e6087 = c_2;
                                                                        center_13 = ((_e6087 + vec2(0.5f)) - vec2<f32>(-0.5f, 0.5f));
                                                                        let _e6110 = u_8;
                                                                        let _e6111 = center_13;
                                                                        rel_13 = (_e6110 - _e6111);
                                                                        let _e6114 = rel_13;
                                                                        len_13 = length(_e6114);
                                                                        let _e6117 = len_13;
                                                                        if (_e6117 < 1f) {
                                                                            {
                                                                                let _e6120 = u_8;
                                                                                let _e6121 = center_13;
                                                                                let _e6128 = u_8;
                                                                                let _e6129 = center_13;
                                                                                a_14 = atan2(dot((_e6120 - _e6121), vec2<f32>(-1f, 0f)), dot((_e6128 - _e6129), vec2<f32>(0f, 1f)));
                                                                                let _e6137 = modelTransform_1;
                                                                                let _e6138 = center_13;
                                                                                let _e6139 = len_13;
                                                                                let _e6145 = tf(_e6137, (_e6138 + (_e6139 * vec2<f32>(0f, 1f))));
                                                                                let _e6149 = global.U[0];
                                                                                let _e6152 = modelTransform_1;
                                                                                let _e6153 = center_13;
                                                                                let _e6154 = len_13;
                                                                                let _e6160 = tf(_e6152, (_e6153 + (_e6154 * vec2<f32>(0f, 1f))));
                                                                                let _e6170 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e6145.x / _e6149.x), _e6160.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e6171 = modelTransform_1;
                                                                                let _e6172 = center_13;
                                                                                let _e6173 = len_13;
                                                                                let _e6180 = tf(_e6171, (_e6172 + (_e6173 * vec2<f32>(-1f, 0f))));
                                                                                let _e6184 = global.U[0];
                                                                                let _e6187 = modelTransform_1;
                                                                                let _e6188 = center_13;
                                                                                let _e6189 = len_13;
                                                                                let _e6196 = tf(_e6187, (_e6188 + (_e6189 * vec2<f32>(-1f, 0f))));
                                                                                let _e6206 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e6180.x / _e6184.x), _e6196.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                                let _e6207 = a_14;
                                                                                col4_ = mix(_e6170, _e6206, vec4((_e6207 / 1.5707964f)));
                                                                            }
                                                                        } else {
                                                                            {
                                                                                col4_ = vec4(0f);
                                                                            }
                                                                        }
                                                                    }
                                                                    let _e6214 = col1_;
                                                                    let _e6215 = col2_;
                                                                    let _e6216 = col3_;
                                                                    let _e6217 = col4_;
                                                                    cols = mat4x4<f32>(vec4<f32>(_e6214.x, _e6214.y, _e6214.z, _e6214.w), vec4<f32>(_e6215.x, _e6215.y, _e6215.z, _e6215.w), vec4<f32>(_e6216.x, _e6216.y, _e6216.z, _e6216.w), vec4<f32>(_e6217.x, _e6217.y, _e6217.z, _e6217.w));
                                                                    let _e6240 = c_2;
                                                                    let _e6241 = randomSeed_1;
                                                                    let _e6242 = regularity_6;
                                                                    let _e6243 = rnd2_(_e6240, _e6241, _e6242);
                                                                    r = _e6243;
                                                                    loop {
                                                                        let _e6247 = i;
                                                                        if !((_e6247 < 5i)) {
                                                                            break;
                                                                        }
                                                                        {
                                                                            let _e6254 = r;
                                                                            i1_ = i32(floor((_e6254 * 4f)));
                                                                            let _e6260 = i1_;
                                                                            i2_ = (_e6260 + 1i);
                                                                            let _e6264 = i2_;
                                                                            if (_e6264 >= 4i) {
                                                                                i2_ = 0i;
                                                                            }
                                                                            let _e6268 = i1_;
                                                                            let _e6270 = cols[_e6268];
                                                                            tmp = _e6270;
                                                                            let _e6272 = i1_;
                                                                            let _e6274 = i2_;
                                                                            let _e6276 = cols[_e6274];
                                                                            cols[_e6272] = _e6276;
                                                                            let _e6277 = i2_;
                                                                            let _e6279 = tmp;
                                                                            cols[_e6277] = _e6279;
                                                                            let _e6280 = r;
                                                                            r = (_e6280 * 0.25f);
                                                                        }
                                                                        continuing {
                                                                            let _e6251 = i;
                                                                            i = (_e6251 + 1i);
                                                                        }
                                                                    }
                                                                    loop {
                                                                        let _e6285 = i_1;
                                                                        if !((_e6285 < 4i)) {
                                                                            break;
                                                                        }
                                                                        {
                                                                            let _e6292 = i_1;
                                                                            let _e6294 = cols[_e6292];
                                                                            col = _e6294;
                                                                            let _e6295 = col;
                                                                            if (_e6295.w == 1f) {
                                                                                break;
                                                                            }
                                                                        }
                                                                        continuing {
                                                                            let _e6289 = i_1;
                                                                            i_1 = (_e6289 + 1i);
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
    let _e6299 = onBorder;
    if _e6299 {
        let _e6300 = col;
        let _e6301 = borderColor_1;
        let _e6302 = mergeColor(_e6300, _e6301);
        return _e6302;
    } else {
        let _e6303 = col;
        return _e6303;
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
