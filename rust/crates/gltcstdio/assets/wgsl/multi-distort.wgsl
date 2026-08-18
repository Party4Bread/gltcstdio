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

fn interpolatedRand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var fractY: f32;

    v_3 = v_2;
    let _e8 = v_3;
    fractY = fract(_e8.y);
    let _e12 = v_3;
    let _e14 = rand2_(floor(_e12));
    let _e15 = v_3;
    let _e18 = v_3;
    let _e22 = rand2_(vec2<f32>(floor(_e15.x), ceil(_e18.y)));
    let _e23 = fractY;
    let _e26 = v_3;
    let _e29 = v_3;
    let _e33 = rand2_(vec2<f32>(ceil(_e26.x), floor(_e29.y)));
    let _e34 = v_3;
    let _e36 = rand2_(ceil(_e34));
    let _e37 = fractY;
    let _e40 = v_3;
    return mix(mix(_e14, _e22, vec2(_e23)), mix(_e33, _e36, vec2(_e37)), vec2(fract(_e40.x)));
}

fn fractalValueNoiseDisplace(u: vec2<f32>, v_4: vec2<f32>, count: i32, intensity: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var v_5: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var s: f32 = 1f;
    var maxDisplacement: f32;
    var totalDisp: vec2<f32> = vec2(0f);
    var i: i32 = 0i;
    var disp: vec2<f32>;

    u_1 = u;
    v_5 = v_4;
    count_1 = count;
    intensity_1 = intensity;
    let _e16 = intensity_1;
    maxDisplacement = _e16;
    loop {
        let _e23 = i;
        let _e24 = count_1;
        if !((_e23 < _e24)) {
            break;
        }
        {
            let _e30 = v_5;
            let _e31 = s;
            let _e33 = interpolatedRand2_((_e30 * _e31));
            disp = _e33;
            let _e35 = totalDisp;
            let _e36 = maxDisplacement;
            let _e37 = disp;
            totalDisp = (_e35 + ((_e36 * (_e37 - vec2<f32>(0.5f, 0.5f))) * 2f));
            let _e46 = maxDisplacement;
            maxDisplacement = (_e46 * 0.5f);
            let _e49 = s;
            s = (_e49 * 2.1055472f);
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    let _e52 = u_1;
    let _e53 = totalDisp;
    return (_e52 + _e53);
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

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn multiDistort(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, intensity_2: f32, variability: f32, randomSeed: f32, lighting: f32, layerCount: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensity_3: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var lighting_1: f32;
    var layerCount_1: i32;
    var inverseModelTransform: mat3x3<f32>;
    var u_4: vec2<f32>;
    var seed_2: f32;
    var layerTransform: mat3x3<f32> = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 0f, 1f));
    var displaced: vec2<f32>;
    var l: i32 = 0i;
    var local: f32;
    var N: f32;
    var j: f32;
    var i_1: f32;
    var id: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var rnd3_: vec2<f32>;
    var center: vec2<f32>;
    var w: vec2<f32>;
    var radius: f32;
    var local_1: f32;
    var count_2: f32;
    var ripplesIntensity: f32;
    var swirlIntensity: f32;
    var flowerlIntensity: f32;
    var marbleIntensity: f32;
    var d: f32;
    var k_4: f32;
    var angle: f32;
    var kk: f32;
    var scaling: f32;
    var dilation: f32;
    var dampening: f32;
    var power: f32;
    var dangle: f32;
    var ca: f32;
    var sa: f32;
    var v_6: vec2<f32>;
    var outCol: vec4<f32>;
    var dilation_1: f32;
    var grad: vec2<f32>;
    var light: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    intensity_3 = intensity_2;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    lighting_1 = lighting;
    layerCount_1 = layerCount;
    let _e22 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e22);
    let _e25 = inverseModelTransform;
    let _e26 = pos_1;
    let _e27 = tf(_e25, _e26);
    u_4 = _e27;
    let _e29 = randomSeed_1;
    seed_2 = _e29;
    let _e45 = u_4;
    displaced = _e45;
    loop {
        let _e49 = l;
        let _e50 = layerCount_1;
        if !((_e49 < _e50)) {
            break;
        }
        {
            let _e56 = layerTransform;
            let _e57 = displaced;
            let _e58 = tf(_e56, _e57);
            displaced = _e58;
            let _e59 = variability_1;
            if (_e59 == 0f) {
                local = 0f;
            } else {
                local = 2f;
            }
            let _e65 = local;
            N = _e65;
            let _e67 = N;
            j = -(_e67);
            loop {
                let _e70 = j;
                let _e71 = N;
                if !((_e70 <= _e71)) {
                    break;
                }
                {
                    let _e77 = N;
                    i_1 = -(_e77);
                    loop {
                        let _e80 = i_1;
                        let _e81 = N;
                        if !((_e80 <= _e81)) {
                            break;
                        }
                        {
                            let _e87 = u_4;
                            let _e95 = i_1;
                            let _e96 = j;
                            id = (floor(((_e87 + vec2(1f)) / vec2(2f))) + vec2<f32>(_e95, _e96));
                            let _e100 = id;
                            let _e101 = seed_2;
                            let _e102 = rand2relSeeded(_e100, _e101);
                            rnd = _e102;
                            let _e104 = id;
                            let _e109 = seed_2;
                            let _e110 = rand2relSeeded((_e104 + vec2<f32>(3.4f, 23.3f)), _e109);
                            rnd2_ = _e110;
                            let _e112 = id;
                            let _e117 = seed_2;
                            let _e118 = rand2relSeeded((_e112 - vec2<f32>(13.3f, 7.2f)), _e117);
                            rnd3_ = _e118;
                            let _e120 = id;
                            let _e123 = variability_1;
                            let _e124 = rnd3_;
                            let _e126 = rnd2_;
                            center = ((_e120 * 2f) + ((_e123 * vec2<f32>(_e124.y, _e126.y)) * 5.5f));
                            let _e134 = displaced;
                            let _e135 = center;
                            w = (_e134 - _e135);
                            let _e139 = rnd;
                            let _e145 = variability_1;
                            radius = abs((0.6f + ((_e139.x * 0.8f) * (1f + (2.5f * abs(_e145))))));
                            let _e153 = id;
                            let _e157 = id;
                            let _e162 = radius;
                            if (((_e153.x == 0f) && (_e157.y == 0f)) && (_e162 < 1f)) {
                                radius = 1f;
                            }
                            let _e167 = rnd3_;
                            if (_e167.x < 0f) {
                                let _e171 = rnd;
                                local_1 = floor((((_e171.y + 0.5f) * 100f) + 1f));
                            } else {
                                let _e181 = rnd;
                                local_1 = floor(pow(10f, (_e181.y * 2f)));
                            }
                            let _e188 = local_1;
                            count_2 = _e188;
                            let _e191 = rnd2_;
                            ripplesIntensity = max(0f, (_e191.x * 4f));
                            let _e197 = rnd2_;
                            let _e201 = rnd2_;
                            swirlIntensity = (sign(_e197.y) * max(0f, ((abs(_e201.y) - 0.25f) * 8f)));
                            let _e211 = rnd3_;
                            let _e215 = rnd3_;
                            flowerlIntensity = (sign(_e211.x) * max(0f, ((abs(_e215.x) - 0.25f) * 8f)));
                            let _e226 = rnd3_;
                            marbleIntensity = max(0f, (_e226.y * 2f));
                            let _e232 = w;
                            d = length(_e232);
                            let _e235 = d;
                            let _e236 = radius;
                            if (_e235 < _e236) {
                                {
                                    let _e238 = d;
                                    let _e239 = radius;
                                    k_4 = (_e238 / _e239);
                                    let _e242 = marbleIntensity;
                                    if (_e242 != 0f) {
                                        {
                                            let _e245 = w;
                                            let _e246 = w;
                                            let _e249 = rnd2_;
                                            let _e254 = marbleIntensity;
                                            let _e255 = intensity_3;
                                            let _e259 = k_4;
                                            let _e262 = fractalValueNoiseDisplace(_e245, ((_e246 * 5f) + (_e249 * 3f)), 6i, ((_e254 * _e255) * smoothstep(1f, 0.5f, _e259)));
                                            w = _e262;
                                        }
                                    }
                                    let _e263 = flowerlIntensity;
                                    if (_e263 != 0f) {
                                        {
                                            let _e266 = w;
                                            let _e268 = w;
                                            angle = atan2(_e266.x, _e268.y);
                                            let _e272 = flowerlIntensity;
                                            let _e274 = k_4;
                                            kk = (_e272 * (1f - _e274));
                                            let _e279 = kk;
                                            let _e280 = intensity_3;
                                            let _e283 = angle;
                                            let _e286 = count_2;
                                            scaling = (1f + ((_e279 * _e280) * (1f + sin((((_e283 + 3.1415927f) * _e286) - 1.5707964f)))));
                                            let _e297 = w;
                                            let _e298 = scaling;
                                            w = (_e297 * _e298);
                                        }
                                    }
                                    let _e300 = ripplesIntensity;
                                    if (_e300 != 0f) {
                                        {
                                            let _e304 = ripplesIntensity;
                                            let _e305 = intensity_3;
                                            let _e307 = k_4;
                                            let _e308 = count_2;
                                            let _e316 = k_4;
                                            dilation = (1f + (((_e304 * _e305) * sin(((_e307 * _e308) * 3.1415927f))) * smoothstep(1f, 0.5f, _e316)));
                                            let _e321 = dilation;
                                            let _e322 = w;
                                            w = (_e321 * _e322);
                                        }
                                    }
                                    let _e324 = swirlIntensity;
                                    if (_e324 != 0f) {
                                        {
                                            dampening = 0.3f;
                                            let _e329 = rnd;
                                            power = ((_e329.x + 0.6f) * 50f);
                                            let _e340 = dampening;
                                            let _e342 = k_4;
                                            let _e344 = swirlIntensity;
                                            let _e346 = intensity_3;
                                            let _e350 = k_4;
                                            let _e353 = power;
                                            dangle = ((((smoothstep(1f, mix(0.9f, -4f, _e340), _e342) * _e344) * _e346) * 5f) / pow(_e350, mix(0.01f, 1.6f, (_e353 * 0.01f))));
                                            let _e360 = dangle;
                                            ca = cos(_e360);
                                            let _e363 = dangle;
                                            sa = sin(_e363);
                                            let _e366 = ca;
                                            let _e367 = w;
                                            let _e370 = sa;
                                            let _e371 = w;
                                            let _e375 = ca;
                                            let _e376 = w;
                                            let _e379 = sa;
                                            let _e380 = w;
                                            w = vec2<f32>(((_e366 * _e367.x) - (_e370 * _e371.y)), ((_e375 * _e376.y) + (_e379 * _e380.x)));
                                        }
                                    }
                                    let _e385 = w;
                                    let _e386 = center;
                                    displaced = (_e385 + _e386);
                                }
                            }
                        }
                        continuing {
                            let _e84 = i_1;
                            i_1 = (_e84 + 1f);
                        }
                    }
                }
                continuing {
                    let _e74 = j;
                    j = (_e74 + 1f);
                }
            }
            let _e388 = layerTransform;
            let _e390 = displaced;
            let _e391 = tf(_naga_inverse_3x3_f32(_e388), _e390);
            displaced = _e391;
            let _e392 = l;
            if (_e392 == 0i) {
                let _e395 = layerTransform;
                layerTransform = (_e395 * mat3x3<f32>(vec3<f32>(0.65f, 0.75f, 0f), vec3<f32>(0.75f, -0.65f, 0f), vec3<f32>(0.1f, 0.2f, 1f)));
            } else {
                let _e411 = layerTransform;
                layerTransform = (_e411 * mat3x3<f32>(vec3<f32>(0.7f, 0.9f, 0f), vec3<f32>(0.9f, -0.7f, 0f), vec3<f32>(0.1f, 0.2f, 1f)));
            }
            let _e427 = seed_2;
            seed_2 = (_e427 + 0.8f);
        }
        continuing {
            let _e53 = l;
            l = (_e53 + 1i);
        }
    }
    let _e430 = modelTransform_1;
    let _e431 = displaced;
    let _e432 = tf(_e430, _e431);
    v_6 = _e432;
    let _e434 = v_6;
    let _e438 = global.U[0];
    let _e441 = v_6;
    let _e450 = _mirror_wrap(((vec2<f32>((_e434.x / _e438.x), _e441.y) / vec2(2f)) + vec2(0.5f)));
    let _e451 = textureSample(t_source, samp, _e450);
    outCol = _e451;
    let _e453 = lighting_1;
    if (_e453 > 0f) {
        {
            let _e456 = displaced;
            let _e457 = u_4;
            dilation_1 = length((_e456 - _e457));
            let _e461 = dilation_1;
            let _e462 = dpdx(_e461);
            let _e463 = u_4;
            let _e465 = dpdx(_e463.x);
            let _e467 = dilation_1;
            let _e468 = dpdy(_e467);
            let _e469 = u_4;
            let _e471 = dpdy(_e469.y);
            grad = (vec2<f32>((_e462 / _e465), (_e468 / _e471)) * 4f);
            let _e478 = lighting_1;
            let _e479 = grad;
            light = (1f + (_e478 * dot(_e479, vec2<f32>(0f, -1f))));
            let _e488 = outCol;
            let _e490 = outCol;
            let _e492 = light;
            let _e493 = (_e490.xyz * _e492);
            outCol.x = _e493.x;
            outCol.y = _e493.y;
            outCol.z = _e493.z;
        }
    }
    let _e500 = outCol;
    return _e500;
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e95 = global.U[9];
    let _e99 = global.U[10];
    let _e103 = global.U[11];
    let _e107 = global.U[12];
    let _e110 = multiDistort((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.x, _e99.x, _e103.x, i32(_e107.x));
    fragColor = _e110;
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
