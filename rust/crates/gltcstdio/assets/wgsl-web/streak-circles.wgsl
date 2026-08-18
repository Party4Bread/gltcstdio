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
            let _e179 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e162.x / _e166.x), _e169.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e180 = p2_;
            let _e184 = global.U[0];
            let _e187 = p2_;
            let _e197 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e180.x / _e184.x), _e187.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e198 = k_4;
            color = mix(_e179, _e197, vec4(_e198));
        }
    } else {
        let _e201 = backgroundMode_1;
        if (_e201 == 3i) {
            {
                let _e204 = borderColor_1;
                color = _e204;
            }
        } else {
            let _e205 = backgroundMode_1;
            if (_e205 == 4i) {
                {
                    let _e208 = colorShadow_1;
                    color = _e208;
                }
            } else {
                {
                    let _e209 = uv_1;
                    let _e213 = global.U[0];
                    let _e216 = uv_1;
                    let _e226 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e209.x / _e213.x), _e216.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    color = _e226;
                }
            }
        }
    }
    loop {
        let _e231 = l;
        let _e232 = lc;
        if !((_e231 < _e232)) {
            break;
        }
        {
            let _e238 = sizing_1;
            if (_e238 <= 3i) {
                {
                    let _e241 = scale;
                    let _e242 = scaleFactor;
                    scale = (_e241 * _e242);
                }
            } else {
                {
                    let _e244 = scale;
                    let _e246 = l;
                    let _e248 = randomSeed_1;
                    let _e249 = rand2relSeeded(vec2(_e246), _e248);
                    scale = (_e244 * pow(2f, _e249.y));
                }
            }
            let _e253 = u_2;
            let _e254 = scale;
            v_2 = (_e253 * _e254);
            let _e257 = v_2;
            c = floor(_e257);
            let _e260 = N;
            j = -(_e260);
            loop {
                let _e263 = j;
                let _e264 = N;
                if !((_e263 <= _e264)) {
                    break;
                }
                {
                    let _e270 = N;
                    i = -(_e270);
                    loop {
                        let _e273 = i;
                        let _e274 = N;
                        if !((_e273 <= _e274)) {
                            break;
                        }
                        {
                            let _e280 = c;
                            let _e281 = i;
                            let _e282 = j;
                            id = (_e280 + vec2<f32>(_e281, _e282));
                            let _e286 = id;
                            let _e290 = randomSeed_1;
                            let _e291 = l;
                            let _e293 = rand2relSeeded((_e286 + vec2(1.52f)), (_e290 + _e291));
                            heightAndSize = _e293;
                            let _e295 = heightAndSize;
                            let _e297 = l;
                            h = (_e295.x + (_e297 * 0.5f));
                            let _e302 = h;
                            let _e303 = height;
                            if (_e302 > _e303) {
                                {
                                    let _e306 = variability_1;
                                    let _e307 = heightAndSize;
                                    let _e313 = size_1;
                                    radius = ((1f - (_e306 * (_e307.y + 0.5f))) * _e313);
                                    let _e316 = id;
                                    let _e317 = randomSeed_1;
                                    let _e318 = l;
                                    let _e320 = rand2relSeeded(_e316, (_e317 + _e318));
                                    let _e321 = variability_1;
                                    delta = (_e320 * _e321);
                                    let _e324 = id;
                                    let _e328 = delta;
                                    center = ((_e324 + vec2(0.5f)) + _e328);
                                    let _e331 = v_2;
                                    let _e332 = center;
                                    vRel = (_e331 - _e332);
                                    let _e335 = vRel;
                                    d = length(_e335);
                                    let _e338 = d;
                                    let _e339 = radius;
                                    if (_e338 < _e339) {
                                        {
                                            let _e341 = h;
                                            height = _e341;
                                            shadow = 0f;
                                            let _e343 = vRel;
                                            let _e345 = vRel;
                                            a_1 = atan2(_e343.y, _e345.x);
                                            let _e349 = a_1;
                                            let _e350 = angInv;
                                            ap_1 = (_e349 * _e350);
                                            let _e353 = ap_1;
                                            let _e355 = ang;
                                            a1_1 = (floor(_e353) * _e355);
                                            let _e358 = a1_1;
                                            let _e359 = ang;
                                            a2_1 = (_e358 + _e359);
                                            let _e362 = ap_1;
                                            k_5 = fract(_e362);
                                            let _e365 = d;
                                            let _e369 = pixelation_1;
                                            dd_1 = ((_e365 * 2f) * (1f - _e369));
                                            let _e373 = center;
                                            let _e374 = a1_1;
                                            let _e376 = a1_1;
                                            let _e379 = dd_1;
                                            let _e382 = scale;
                                            p1_1 = ((_e373 + (vec2<f32>(cos(_e374), sin(_e376)) * _e379)) / vec2(_e382));
                                            let _e386 = center;
                                            let _e387 = a2_1;
                                            let _e389 = a2_1;
                                            let _e392 = dd_1;
                                            let _e395 = scale;
                                            p2_1 = ((_e386 + (vec2<f32>(cos(_e387), sin(_e389)) * _e392)) / vec2(_e395));
                                            let _e399 = modelTransform_1;
                                            let _e400 = p1_1;
                                            let _e401 = tf(_e399, _e400);
                                            let _e405 = global.U[0];
                                            let _e408 = modelTransform_1;
                                            let _e409 = p1_1;
                                            let _e410 = tf(_e408, _e409);
                                            let _e420 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e401.x / _e405.x), _e410.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e421 = modelTransform_1;
                                            let _e422 = p2_1;
                                            let _e423 = tf(_e421, _e422);
                                            let _e427 = global.U[0];
                                            let _e430 = modelTransform_1;
                                            let _e431 = p2_1;
                                            let _e432 = tf(_e430, _e431);
                                            let _e442 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e423.x / _e427.x), _e432.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            let _e443 = k_5;
                                            color = mix(_e420, _e442, vec4(_e443));
                                            let _e446 = d;
                                            let _e447 = radius;
                                            let _e448 = thickness_1;
                                            let _e449 = radius;
                                            if (_e446 > (_e447 - (_e448 * _e449))) {
                                                {
                                                    let _e453 = color;
                                                    let _e454 = borderColor_1;
                                                    let _e455 = mergeColor(_e453, _e454);
                                                    color = _e455;
                                                }
                                            }
                                        }
                                    } else {
                                        let _e456 = shadows_1;
                                        if (_e456 > 0f) {
                                            {
                                                let _e459 = shadow;
                                                let _e460 = radius;
                                                let _e461 = shadows_1;
                                                let _e464 = h;
                                                let _e465 = height;
                                                let _e471 = radius;
                                                let _e472 = d;
                                                shadow = max(_e459, smoothstep((_e460 + (((_e461 * 0.5f) * (_e464 - _e465)) * 3.5f)), _e471, _e472));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e277 = i;
                            i = (_e277 + 1f);
                        }
                    }
                }
                continuing {
                    let _e267 = j;
                    j = (_e267 + 1f);
                }
            }
        }
        continuing {
            let _e235 = l;
            l = (_e235 + 1f);
        }
    }
    let _e475 = color;
    let _e476 = color;
    let _e477 = colorShadow_1;
    let _e478 = shadow;
    let _e481 = mergeColor(_e475, mix(_e476, _e477, vec4(_e478)));
    return _e481;
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
