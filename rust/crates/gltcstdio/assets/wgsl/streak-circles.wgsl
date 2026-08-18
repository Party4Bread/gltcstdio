struct Params {
    U: array<vec4<f32>, 20>,
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

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn streakCircles(uv: vec2<f32>, outPos: vec2<f32>, pixelation: f32, count: i32, layerCount: i32, variability: f32, shadows: f32, randomSeed: f32, size: f32, sizing: i32, thickness: f32, borderColor: vec4<f32>, colorShadow: vec4<f32>, modelTransform: mat3x3<f32>, backgroundMode: i32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var pixelation_1: f32;
    var count_1: i32;
    var layerCount_1: i32;
    var variability_1: f32;
    var shadows_1: f32;
    var randomSeed_1: f32;
    var size_1: f32;
    var sizing_1: i32;
    var thickness_1: f32;
    var borderColor_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var backgroundMode_1: i32;
    var ang: f32;
    var angInv: f32;
    var u_2: vec2<f32>;
    var local: f32;
    var N: f32;
    var height: f32 = -1f;
    var color: vec4<f32>;
    var lc: f32;
    var scaleFactor: f32 = 1f;
    var scale: f32 = 1f;
    var a: f32;
    var ap: f32;
    var a1_: f32;
    var a2_: f32;
    var k_4: f32;
    var dd: f32;
    var p1_: vec2<f32>;
    var p2_: vec2<f32>;
    var shadow: f32 = 0f;
    var l: f32 = 0f;
    var v_2: vec2<f32>;
    var c: vec2<f32>;
    var j: f32;
    var i: f32;
    var id: vec2<f32>;
    var heightAndSize: vec2<f32>;
    var h: f32;
    var radius: f32;
    var delta: vec2<f32>;
    var center: vec2<f32>;
    var vRel: vec2<f32>;
    var d: f32;
    var a_1: f32;
    var ap_1: f32;
    var a1_1: f32;
    var a2_1: f32;
    var k_5: f32;
    var dd_1: f32;
    var p1_1: vec2<f32>;
    var p2_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    pixelation_1 = pixelation;
    count_1 = count;
    layerCount_1 = layerCount;
    variability_1 = variability;
    shadows_1 = shadows;
    randomSeed_1 = randomSeed;
    size_1 = size;
    sizing_1 = sizing;
    thickness_1 = thickness;
    borderColor_1 = borderColor;
    colorShadow_1 = colorShadow;
    modelTransform_1 = modelTransform;
    backgroundMode_1 = backgroundMode;
    let _e37 = count_1;
    ang = (6.2831855f / f32(_e37));
    let _e41 = count_1;
    angInv = (f32(_e41) / 6.2831855f);
    let _e46 = modelTransform_1;
    let _e48 = uv_1;
    u_2 = (_naga_inverse_3x3_f32(_e46) * vec3<f32>(_e48.x, _e48.y, 1f)).xy;
    let _e56 = shadows_1;
    if (_e56 == 0f) {
        local = 1f;
    } else {
        local = 2f;
    }
    let _e62 = local;
    N = _e62;
    let _e68 = layerCount_1;
    lc = f32(_e68);
    let _e75 = sizing_1;
    if (_e75 == 0i) {
        scaleFactor = 1.4f;
    } else {
        let _e79 = sizing_1;
        if (_e79 == 1i) {
            scaleFactor = 1.25f;
        } else {
            let _e83 = sizing_1;
            if (_e83 == 2i) {
                {
                    scaleFactor = 0.8f;
                    let _e87 = scaleFactor;
                    let _e88 = lc;
                    scale = pow(_e87, -(_e88));
                }
            } else {
                let _e91 = sizing_1;
                if (_e91 == 3i) {
                    {
                        scaleFactor = 0.714f;
                        let _e95 = scaleFactor;
                        let _e96 = lc;
                        scale = pow(_e95, -(_e96));
                    }
                }
            }
        }
    }
    let _e99 = backgroundMode_1;
    let _e102 = backgroundMode_1;
    if ((_e99 >= 1i) && (_e102 <= 2i)) {
        {
            let _e106 = uv_1;
            let _e108 = uv_1;
            a = atan2(_e106.y, _e108.x);
            let _e112 = a;
            let _e113 = angInv;
            ap = (_e112 * _e113);
            let _e116 = ap;
            let _e118 = ang;
            a1_ = (floor(_e116) * _e118);
            let _e121 = a1_;
            let _e122 = ang;
            a2_ = (_e121 + _e122);
            let _e125 = ap;
            k_4 = fract(_e125);
            let _e128 = uv_1;
            let _e133 = pixelation_1;
            dd = ((length(_e128) * 2f) * (1f - _e133));
            let _e137 = a1_;
            let _e139 = a1_;
            let _e142 = dd;
            p1_ = (vec2<f32>(cos(_e137), sin(_e139)) * _e142);
            let _e145 = a2_;
            let _e147 = a2_;
            let _e150 = dd;
            p2_ = (vec2<f32>(cos(_e145), sin(_e147)) * _e150);
            let _e153 = backgroundMode_1;
            if (_e153 == 2i) {
                {
                    let _e156 = modelTransform_1;
                    let _e157 = p1_;
                    let _e158 = tf(_e156, _e157);
                    p1_ = _e158;
                    let _e159 = modelTransform_1;
                    let _e160 = p2_;
                    let _e161 = tf(_e159, _e160);
                    p2_ = _e161;
                }
            }
            let _e162 = p1_;
            let _e166 = global.U[0];
            let _e169 = p1_;
            let _e178 = textureSample(t_source, samp, ((vec2<f32>((_e162.x / _e166.x), _e169.y) / vec2(2f)) + vec2(0.5f)));
            let _e179 = p2_;
            let _e183 = global.U[0];
            let _e186 = p2_;
            let _e195 = textureSample(t_source, samp, ((vec2<f32>((_e179.x / _e183.x), _e186.y) / vec2(2f)) + vec2(0.5f)));
            let _e196 = k_4;
            color = mix(_e178, _e195, vec4(_e196));
        }
    } else {
        let _e199 = backgroundMode_1;
        if (_e199 == 3i) {
            {
                let _e202 = borderColor_1;
                color = _e202;
            }
        } else {
            let _e203 = backgroundMode_1;
            if (_e203 == 4i) {
                {
                    let _e206 = colorShadow_1;
                    color = _e206;
                }
            } else {
                {
                    let _e207 = uv_1;
                    let _e211 = global.U[0];
                    let _e214 = uv_1;
                    let _e223 = textureSample(t_source, samp, ((vec2<f32>((_e207.x / _e211.x), _e214.y) / vec2(2f)) + vec2(0.5f)));
                    color = _e223;
                }
            }
        }
    }
    loop {
        let _e228 = l;
        let _e229 = lc;
        if !((_e228 < _e229)) {
            break;
        }
        {
            let _e235 = sizing_1;
            if (_e235 <= 3i) {
                {
                    let _e238 = scale;
                    let _e239 = scaleFactor;
                    scale = (_e238 * _e239);
                }
            } else {
                {
                    let _e241 = scale;
                    let _e243 = l;
                    let _e245 = randomSeed_1;
                    let _e246 = rand2relSeeded(vec2(_e243), _e245);
                    scale = (_e241 * pow(2f, _e246.y));
                }
            }
            let _e250 = u_2;
            let _e251 = scale;
            v_2 = (_e250 * _e251);
            let _e254 = v_2;
            c = floor(_e254);
            let _e257 = N;
            j = -(_e257);
            loop {
                let _e260 = j;
                let _e261 = N;
                if !((_e260 <= _e261)) {
                    break;
                }
                {
                    let _e267 = N;
                    i = -(_e267);
                    loop {
                        let _e270 = i;
                        let _e271 = N;
                        if !((_e270 <= _e271)) {
                            break;
                        }
                        {
                            let _e277 = c;
                            let _e278 = i;
                            let _e279 = j;
                            id = (_e277 + vec2<f32>(_e278, _e279));
                            let _e283 = id;
                            let _e287 = randomSeed_1;
                            let _e288 = l;
                            let _e290 = rand2relSeeded((_e283 + vec2(1.52f)), (_e287 + _e288));
                            heightAndSize = _e290;
                            let _e292 = heightAndSize;
                            let _e294 = l;
                            h = (_e292.x + (_e294 * 0.5f));
                            let _e299 = h;
                            let _e300 = height;
                            if (_e299 > _e300) {
                                {
                                    let _e303 = variability_1;
                                    let _e304 = heightAndSize;
                                    let _e310 = size_1;
                                    radius = ((1f - (_e303 * (_e304.y + 0.5f))) * _e310);
                                    let _e313 = id;
                                    let _e314 = randomSeed_1;
                                    let _e315 = l;
                                    let _e317 = rand2relSeeded(_e313, (_e314 + _e315));
                                    let _e318 = variability_1;
                                    delta = (_e317 * _e318);
                                    let _e321 = id;
                                    let _e325 = delta;
                                    center = ((_e321 + vec2(0.5f)) + _e325);
                                    let _e328 = v_2;
                                    let _e329 = center;
                                    vRel = (_e328 - _e329);
                                    let _e332 = vRel;
                                    d = length(_e332);
                                    let _e335 = d;
                                    let _e336 = radius;
                                    if (_e335 < _e336) {
                                        {
                                            let _e338 = h;
                                            height = _e338;
                                            shadow = 0f;
                                            let _e340 = vRel;
                                            let _e342 = vRel;
                                            a_1 = atan2(_e340.y, _e342.x);
                                            let _e346 = a_1;
                                            let _e347 = angInv;
                                            ap_1 = (_e346 * _e347);
                                            let _e350 = ap_1;
                                            let _e352 = ang;
                                            a1_1 = (floor(_e350) * _e352);
                                            let _e355 = a1_1;
                                            let _e356 = ang;
                                            a2_1 = (_e355 + _e356);
                                            let _e359 = ap_1;
                                            k_5 = fract(_e359);
                                            let _e362 = d;
                                            let _e366 = pixelation_1;
                                            dd_1 = ((_e362 * 2f) * (1f - _e366));
                                            let _e370 = center;
                                            let _e371 = a1_1;
                                            let _e373 = a1_1;
                                            let _e376 = dd_1;
                                            let _e379 = scale;
                                            p1_1 = ((_e370 + (vec2<f32>(cos(_e371), sin(_e373)) * _e376)) / vec2(_e379));
                                            let _e383 = center;
                                            let _e384 = a2_1;
                                            let _e386 = a2_1;
                                            let _e389 = dd_1;
                                            let _e392 = scale;
                                            p2_1 = ((_e383 + (vec2<f32>(cos(_e384), sin(_e386)) * _e389)) / vec2(_e392));
                                            let _e396 = modelTransform_1;
                                            let _e397 = p1_1;
                                            let _e398 = tf(_e396, _e397);
                                            let _e402 = global.U[0];
                                            let _e405 = modelTransform_1;
                                            let _e406 = p1_1;
                                            let _e407 = tf(_e405, _e406);
                                            let _e416 = textureSample(t_source, samp, ((vec2<f32>((_e398.x / _e402.x), _e407.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e417 = modelTransform_1;
                                            let _e418 = p2_1;
                                            let _e419 = tf(_e417, _e418);
                                            let _e423 = global.U[0];
                                            let _e426 = modelTransform_1;
                                            let _e427 = p2_1;
                                            let _e428 = tf(_e426, _e427);
                                            let _e437 = textureSample(t_source, samp, ((vec2<f32>((_e419.x / _e423.x), _e428.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e438 = k_5;
                                            color = mix(_e416, _e437, vec4(_e438));
                                            let _e441 = d;
                                            let _e442 = radius;
                                            let _e443 = thickness_1;
                                            let _e444 = radius;
                                            if (_e441 > (_e442 - (_e443 * _e444))) {
                                                {
                                                    let _e448 = color;
                                                    let _e449 = borderColor_1;
                                                    let _e450 = mergeColor(_e448, _e449);
                                                    color = _e450;
                                                }
                                            }
                                        }
                                    } else {
                                        let _e451 = shadows_1;
                                        if (_e451 > 0f) {
                                            {
                                                let _e454 = shadow;
                                                let _e455 = radius;
                                                let _e456 = shadows_1;
                                                let _e459 = h;
                                                let _e460 = height;
                                                let _e466 = radius;
                                                let _e467 = d;
                                                shadow = max(_e454, smoothstep((_e455 + (((_e456 * 0.5f) * (_e459 - _e460)) * 3.5f)), _e466, _e467));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e274 = i;
                            i = (_e274 + 1f);
                        }
                    }
                }
                continuing {
                    let _e264 = j;
                    j = (_e264 + 1f);
                }
            }
        }
        continuing {
            let _e232 = l;
            l = (_e232 + 1f);
        }
    }
    let _e470 = color;
    let _e471 = color;
    let _e472 = colorShadow_1;
    let _e473 = shadow;
    let _e476 = mergeColor(_e470, mix(_e471, _e472, vec4(_e473)));
    return _e476;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e101 = global.U[13];
    let _e105 = global.U[14];
    let _e108 = global.U[15];
    let _e111 = global.U[16];
    let _e112 = _e111.xyz;
    let _e115 = global.U[17];
    let _e116 = _e115.xyz;
    let _e119 = global.U[18];
    let _e120 = _e119.xyz;
    let _e136 = global.U[19];
    let _e139 = streakCircles((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), i32(_e75.x), _e80.x, _e84.x, _e88.x, _e92.x, i32(_e96.x), _e101.x, _e105, _e108, mat3x3<f32>(vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e116.x, _e116.y, _e116.z), vec3<f32>(_e120.x, _e120.y, _e120.z)), i32(_e136.x));
    fragColor = _e139;
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
