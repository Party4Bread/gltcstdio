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

fn hash12_(x: f32) -> vec2<f32> {
    var x_1: f32;

    x_1 = x;
    let _e8 = x_1;
    let _e15 = x_1;
    return vec2<f32>(fract((sin((_e8 * 776.4577f)) * 45.77f)), fract((sin(((_e15 * 376.4517f) + 1.2524f)) * 88.77f)));
}

fn getCenter(i: f32, variability: f32, randomSeed: f32) -> vec2<f32> {
    var i_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var x_2: f32;
    var p: vec2<f32>;

    i_1 = i;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    let _e12 = i_1;
    x_2 = (_e12 * 0.2f);
    let _e16 = x_2;
    let _e17 = x_2;
    let _e19 = x_2;
    p = (_e16 * vec2<f32>(cos(_e17), sin(_e19)));
    let _e24 = variability_1;
    if (_e24 != 0f) {
        {
            let _e27 = p;
            let _e28 = x_2;
            let _e29 = variability_1;
            let _e33 = i_1;
            let _e36 = randomSeed_1;
            let _e38 = hash12_(((_e33 * 10f) + _e36));
            p = (_e27 + (((_e28 * _e29) * 2f) * (_e38 - vec2(0.5f))));
        }
    }
    let _e44 = p;
    return _e44;
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_3: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x_3 = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x_3;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x_3;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_1: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_1 = k;
    let _e12 = val1_1;
    let _e14 = k_1;
    let _e22 = val2_1;
    let _e25 = k_1;
    return (((_e12 * (1f + cos((_e14 * 3.1415927f)))) * 0.5f) + ((_e22 * (1f + cos(((1f - _e25) * 3.1415927f)))) * 0.5f));
}

fn varyNoiseSmoothly(noise: f32, k_2: f32) -> f32 {
    var noise_1: f32;
    var k_3: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_3 = k_2;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_3;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_4: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_5: f32;

    noise_3 = noise_2;
    k_5 = k_4;
    let _e10 = noise_3;
    let _e12 = k_5;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_5;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_1: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_1 = seed;
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
    let _e34 = seed_1;
    let _e35 = varyVec2NoiseSmoothly(_e33, _e34);
    r00_ = (_e35 - vec2<f32>(0.5f, 0.5f));
    let _e41 = u01_;
    let _e42 = rand2_(_e41);
    let _e43 = seed_1;
    let _e44 = varyVec2NoiseSmoothly(_e42, _e43);
    r01_ = (_e44 - vec2<f32>(0.5f, 0.5f));
    let _e50 = u10_;
    let _e51 = rand2_(_e50);
    let _e52 = seed_1;
    let _e53 = varyVec2NoiseSmoothly(_e51, _e52);
    r10_ = (_e53 - vec2<f32>(0.5f, 0.5f));
    let _e59 = u11_;
    let _e60 = rand2_(_e59);
    let _e61 = seed_1;
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

fn spiralBreaks(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, perturbation: f32, distortion: f32, variability_2: f32, randomSeed_2: f32, pixelation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var perturbation_1: f32;
    var distortion_1: f32;
    var variability_3: f32;
    var randomSeed_3: f32;
    var pixelation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var t: vec2<f32>;
    var d2min: f32 = 100000000000000000000f;
    var d2min2_: f32 = 100000000000000000000f;
    var minCenter: vec2<f32>;
    var minIndex: f32 = 0f;
    var N: f32 = 100f;
    var i_2: f32 = 0f;
    var angle: f32;
    var center: vec2<f32>;
    var d: vec2<f32>;
    var d2_: f32;
    var delta: vec2<f32>;
    var newPos: vec2<f32>;
    var distorted: bool = false;
    var dd: vec2<f32>;
    var k_6: f32;
    var r: f32;
    var dp: f32;
    var outColor: vec4<f32>;
    var pixelPos: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    perturbation_1 = perturbation;
    distortion_1 = distortion;
    variability_3 = variability_2;
    randomSeed_3 = randomSeed_2;
    pixelation_1 = pixelation;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e24);
    let _e27 = uv_1;
    u_2 = _e27;
    let _e29 = inverseModelTransform;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    t = _e31;
    let _e33 = perturbation_1;
    if (_e33 > 0f) {
        {
            let _e36 = t;
            let _e37 = t;
            let _e39 = perturbation_1;
            let _e44 = randomSeed_3;
            let _e45 = sineSurfaceRand2Seeded((_e37 * (1f + (_e39 * 0f))), _e44);
            let _e48 = perturbation_1;
            t = (_e36 + ((_e45 * 2.5f) * _e48));
        }
    }
    loop {
        let _e62 = i_2;
        let _e63 = N;
        if !((_e62 < _e63)) {
            break;
        }
        {
            let _e69 = i_2;
            let _e74 = N;
            angle = (((_e69 * 6f) * 6.2831855f) / _e74);
            let _e77 = i_2;
            let _e78 = variability_3;
            let _e79 = randomSeed_3;
            let _e80 = getCenter(_e77, _e78, _e79);
            center = _e80;
            let _e82 = t;
            let _e83 = center;
            d = (_e82 - _e83);
            let _e86 = d;
            let _e87 = d;
            d2_ = dot(_e86, _e87);
            let _e90 = d2_;
            let _e91 = d2min;
            if (_e90 < _e91) {
                {
                    let _e93 = d2min;
                    d2min2_ = _e93;
                    let _e94 = d2_;
                    d2min = _e94;
                    let _e95 = i_2;
                    minIndex = _e95;
                    let _e96 = center;
                    minCenter = _e96;
                }
            } else {
                let _e97 = d2_;
                let _e98 = d2min2_;
                if (_e97 < _e98) {
                    {
                        let _e100 = d2_;
                        d2min2_ = _e100;
                    }
                }
            }
        }
        continuing {
            let _e66 = i_2;
            i_2 = (_e66 + 1f);
        }
    }
    let _e101 = minIndex;
    let _e104 = minIndex;
    let _e106 = rand2_(vec2<f32>((_e101 + 1f), _e104));
    let _e111 = intensity_1;
    delta = (((_e106 - vec2<f32>(0.5f, 0.5f)) * _e111) * 2f);
    let _e116 = uv_1;
    let _e117 = delta;
    newPos = (_e116 + _e117);
    let _e122 = d2min;
    let _e125 = distortion_1;
    let _e129 = pixelation_1;
    if (((_e122 > 0f) && (_e125 > 0f)) && (_e129 != 1f)) {
        {
            let _e133 = t;
            let _e134 = minCenter;
            dd = (_e133 - _e134);
            distorted = true;
            let _e138 = d2min;
            let _e143 = d2min2_;
            k_6 = (clamp(sqrt(_e138), 0f, 1f) / sqrt(_e143));
            let _e148 = k_6;
            r = (1f - _e148);
            let _e151 = distortion_1;
            let _e155 = r;
            let _e159 = r;
            dp = (((_e151 * 2f) * (1f - _e155)) / (0.5f + _e159));
            let _e163 = newPos;
            let _e164 = dd;
            let _e165 = dp;
            newPos = (_e163 + (_e164 * _e165));
        }
    }
    let _e168 = newPos;
    let _e172 = global.U[0];
    let _e175 = newPos;
    let _e184 = textureSample(t_source, samp, ((vec2<f32>((_e168.x / _e172.x), _e175.y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e184;
    let _e186 = pixelation_1;
    if (_e186 != 0f) {
        {
            let _e189 = modelTransform_1;
            let _e190 = minCenter;
            let _e191 = tf(_e189, _e190);
            let _e192 = delta;
            pixelPos = (_e191 + _e192);
            let _e195 = outColor;
            let _e196 = pixelPos;
            let _e200 = global.U[0];
            let _e203 = pixelPos;
            let _e212 = textureSample(t_source, samp, ((vec2<f32>((_e196.x / _e200.x), _e203.y) / vec2(2f)) + vec2(0.5f)));
            let _e213 = pixelation_1;
            outColor = mix(_e195, _e212, vec4(_e213));
        }
    }
    let _e216 = outColor;
    return _e216;
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
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e113 = spiralBreaks((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)));
    fragColor = _e113;
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
