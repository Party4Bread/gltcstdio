struct Params {
    U: array<vec4<f32>, 15>,
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

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k_4: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_5: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_5 = k_4;
    let _e12 = val1_1;
    let _e14 = k_5;
    let _e22 = val2_1;
    let _e25 = k_5;
    return (((_e12 * (1f + cos((_e14 * 3.1415927f)))) * 0.5f) + ((_e22 * (1f + cos(((1f - _e25) * 3.1415927f)))) * 0.5f));
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e10 = v_3;
    u00_ = floor(_e10);
    let _e13 = v_3;
    let _e16 = v_3;
    u01_ = vec2<f32>(floor(_e13.x), ceil(_e16.y));
    let _e21 = v_3;
    let _e24 = v_3;
    u10_ = vec2<f32>(ceil(_e21.x), floor(_e24.y));
    let _e29 = v_3;
    u11_ = ceil(_e29);
    let _e32 = u00_;
    let _e33 = rand2_(_e32);
    let _e34 = seed_3;
    let _e35 = varyVec2NoiseSmoothly(_e33, _e34);
    r00_ = (_e35 - vec2<f32>(0.5f, 0.5f));
    let _e41 = u01_;
    let _e42 = rand2_(_e41);
    let _e43 = seed_3;
    let _e44 = varyVec2NoiseSmoothly(_e42, _e43);
    r01_ = (_e44 - vec2<f32>(0.5f, 0.5f));
    let _e50 = u10_;
    let _e51 = rand2_(_e50);
    let _e52 = seed_3;
    let _e53 = varyVec2NoiseSmoothly(_e51, _e52);
    r10_ = (_e53 - vec2<f32>(0.5f, 0.5f));
    let _e59 = u11_;
    let _e60 = rand2_(_e59);
    let _e61 = seed_3;
    let _e62 = varyVec2NoiseSmoothly(_e60, _e61);
    r11_ = (_e62 - vec2<f32>(0.5f, 0.5f));
    let _e68 = r00_;
    let _e69 = r01_;
    let _e70 = v_3;
    let _e73 = sineMix(_e68, _e69, fract(_e70.y));
    let _e74 = r10_;
    let _e75 = r11_;
    let _e76 = v_3;
    let _e79 = sineMix(_e74, _e75, fract(_e76.y));
    let _e80 = v_3;
    let _e83 = sineMix(_e73, _e79, fract(_e80.x));
    return _e83;
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

fn cells(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, randomSeed: f32, variability: f32, radiusVariability: f32, perturbation: f32, pixelation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var radiusVariability_1: f32;
    var perturbation_1: f32;
    var pixelation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var k_6: f32 = 0f;
    var minDelta: vec2<f32>;
    var d2min: f32 = 1000000000f;
    var minI: i32 = 0i;
    var minJ: i32 = 0i;
    var minCenter: vec2<f32>;
    var minRadiusModifier: f32;
    var j: i32 = -2i;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var d: vec2<f32>;
    var d2_: f32;
    var delta_1: vec2<f32>;
    var newPos: vec2<f32>;
    var distorted: bool = false;
    var dd: vec2<f32>;
    var radius: f32 = 100f;
    var threshold: f32;
    var r: f32;
    var dp: f32;
    var outColor: vec4<f32>;
    var pixelPos: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    distortion_1 = distortion;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    radiusVariability_1 = radiusVariability;
    perturbation_1 = perturbation;
    pixelation_1 = pixelation;
    modelTransform_1 = modelTransform;
    let _e26 = modelTransform_1;
    let _e28 = pos_1;
    let _e29 = tf(_naga_inverse_3x3_f32(_e26), _e28);
    t = _e29;
    let _e31 = perturbation_1;
    if (_e31 > 0f) {
        {
            let _e34 = t;
            let _e35 = t;
            let _e37 = perturbation_1;
            let _e42 = randomSeed_1;
            let _e43 = sineSurfaceRand2Seeded((_e35 * (1f + (_e37 * 0f))), _e42);
            let _e46 = perturbation_1;
            t = (_e34 + ((_e43 * 2.5f) * _e46));
        }
    }
    let _e49 = t;
    ci = floor(_e49.x);
    let _e53 = t;
    cj = floor(_e53.y);
    loop {
        let _e71 = j;
        if !((_e71 <= 2i)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e81 = i;
                if !((_e81 <= 2i)) {
                    break;
                }
                {
                    let _e88 = i;
                    let _e90 = ci;
                    let _e92 = j;
                    let _e94 = cj;
                    center = vec2<f32>((f32(_e88) + _e90), (f32(_e92) + _e94));
                    let _e98 = center;
                    let _e99 = randomSeed_1;
                    let _e100 = rand2relSeeded(_e98, _e99);
                    delta = _e100;
                    let _e104 = delta;
                    let _e106 = radiusVariability_1;
                    radiusModifier = max(0.01f, (1f + (_e104.x * _e106)));
                    let _e111 = center;
                    let _e115 = delta;
                    let _e116 = variability_1;
                    center = (_e111 + (vec2<f32>(0.5f, 0.5f) + ((_e115 * _e116) * 2f)));
                    let _e122 = t;
                    let _e123 = center;
                    d = (_e122 - _e123);
                    let _e126 = d;
                    let _e127 = d;
                    d2_ = dot(_e126, _e127);
                    let _e130 = d2_;
                    let _e131 = radiusModifier;
                    let _e133 = d2min;
                    if ((_e130 / _e131) < _e133) {
                        {
                            let _e135 = d2_;
                            d2min = _e135;
                            let _e136 = i;
                            minI = _e136;
                            let _e137 = j;
                            minJ = _e137;
                            let _e138 = center;
                            minCenter = _e138;
                            let _e139 = delta;
                            minDelta = _e139;
                            let _e140 = radiusModifier;
                            minRadiusModifier = _e140;
                        }
                    }
                }
                continuing {
                    let _e85 = i;
                    i = (_e85 + 1i);
                }
            }
        }
        continuing {
            let _e75 = j;
            j = (_e75 + 1i);
        }
    }
    let _e141 = d2min;
    k_6 = sqrt(_e141);
    let _e143 = k_6;
    k_6 = clamp(_e143, 0f, 1f);
    let _e147 = minDelta;
    let _e148 = intensity_1;
    delta_1 = ((_e147 * _e148) * 2f);
    let _e153 = pos_1;
    let _e154 = delta_1;
    newPos = (_e153 + _e154);
    let _e159 = d2min;
    let _e162 = distortion_1;
    let _e166 = pixelation_1;
    if (((_e159 > 0f) && (_e162 > 0f)) && (_e166 != 100f)) {
        {
            let _e170 = t;
            let _e171 = minCenter;
            dd = (_e170 - _e171);
            let _e176 = radius;
            let _e179 = minRadiusModifier;
            threshold = ((_e176 * 0.01f) * _e179);
            let _e182 = k_6;
            let _e183 = threshold;
            if (_e182 < _e183) {
                {
                    distorted = true;
                    let _e186 = k_6;
                    let _e187 = threshold;
                    k_6 = (_e186 / _e187);
                    let _e190 = k_6;
                    r = (1f - _e190);
                    let _e193 = distortion_1;
                    let _e197 = r;
                    let _e201 = r;
                    dp = (((_e193 * 2f) * (1f - _e197)) / (0.5f + _e201));
                    let _e205 = newPos;
                    let _e206 = dd;
                    let _e207 = dp;
                    newPos = (_e205 + (_e206 * _e207));
                }
            }
        }
    }
    let _e210 = newPos;
    let _e214 = global.U[0];
    let _e217 = newPos;
    let _e226 = _mirror_wrap(((vec2<f32>((_e210.x / _e214.x), _e217.y) / vec2(2f)) + vec2(0.5f)));
    let _e227 = textureSample(t_source, samp, _e226);
    outColor = _e227;
    let _e229 = pixelation_1;
    if (_e229 != 0f) {
        {
            let _e232 = modelTransform_1;
            let _e233 = minCenter;
            let _e240 = delta_1;
            pixelPos = ((_e232 * vec3<f32>(_e233.x, _e233.y, 1f)).xy + _e240);
            let _e243 = outColor;
            let _e244 = pixelPos;
            let _e248 = global.U[0];
            let _e251 = pixelPos;
            let _e260 = _mirror_wrap(((vec2<f32>((_e244.x / _e248.x), _e251.y) / vec2(2f)) + vec2(0.5f)));
            let _e261 = textureSample(t_source, samp, _e260);
            let _e262 = pixelation_1;
            outColor = mix(_e243, _e261, vec4(_e262));
        }
    }
    let _e265 = outColor;
    return _e265;
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
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e117 = cells((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, _e90.x, mat3x3<f32>(vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z), vec3<f32>(_e103.x, _e103.y, _e103.z)));
    fragColor = _e117;
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
