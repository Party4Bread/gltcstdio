struct Params {
    U: array<vec4<f32>, 12>,
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

fn kaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, modelTransform: mat3x3<f32>, stretch: f32, variability: f32, randomSeed: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var stretch_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var u: vec2<f32>;
    var a: f32;
    var period: f32;
    var halfPeriod: f32;
    var index: f32;
    var maxDisplacement: f32;
    var spikeAngle1_: f32 = -3.1415927f;
    var spikeAngle2_: f32;
    var i: i32 = 0i;
    var deltaAng: f32;
    var d: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    modelTransform_1 = modelTransform;
    stretch_1 = stretch;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    let _e20 = uv_1;
    u = _e20;
    let _e22 = u;
    let _e24 = u;
    a = atan2(_e22.x, _e24.y);
    let _e29 = spikeCount_1;
    period = (6.2831855f / f32(_e29));
    let _e33 = period;
    halfPeriod = (_e33 * 0.5f);
    let _e37 = a;
    let _e38 = period;
    index = floor((_e37 / _e38));
    let _e42 = spikeCount_1;
    let _e45 = variability_1;
    let _e48 = spikeCount_1;
    if ((_e42 != 1i) && ((_e45 == 0f) || (_e48 > 100i))) {
        {
            let _e53 = a;
            let _e54 = period;
            a = (_e53 - (floor((_e53 / _e54)) * _e54));
            let _e59 = a;
            let _e60 = halfPeriod;
            if (_e59 > _e60) {
                {
                    let _e62 = period;
                    let _e63 = a;
                    a = (_e62 - _e63);
                }
            } else {
                {
                }
            }
        }
    } else {
        {
            let _e65 = halfPeriod;
            maxDisplacement = _e65;
            let _e70 = spikeAngle1_;
            let _e71 = period;
            let _e73 = variability_1;
            let _e74 = maxDisplacement;
            let _e81 = randomSeed_1;
            let _e82 = rand2relSeeded(vec2<f32>(0f, 0f), _e81);
            spikeAngle2_ = ((_e70 + _e71) + (((_e73 * _e74) * 2f) * _e82.x));
            loop {
                let _e89 = i;
                let _e90 = spikeCount_1;
                if !((_e89 < _e90)) {
                    break;
                }
                {
                    let _e96 = i;
                    let _e97 = spikeCount_1;
                    let _e101 = a;
                    let _e102 = spikeAngle2_;
                    if ((_e96 == (_e97 - 1i)) || (_e101 <= _e102)) {
                        {
                            let _e105 = spikeAngle2_;
                            let _e106 = spikeAngle1_;
                            deltaAng = (_e105 - _e106);
                            let _e109 = a;
                            let _e110 = spikeAngle1_;
                            a = (_e109 - _e110);
                            let _e112 = a;
                            let _e113 = deltaAng;
                            if (_e112 > (_e113 * 0.5f)) {
                                {
                                    let _e117 = deltaAng;
                                    let _e118 = a;
                                    a = (_e117 - _e118);
                                }
                            }
                            break;
                        }
                    } else {
                        {
                            let _e120 = spikeAngle2_;
                            spikeAngle1_ = _e120;
                            let _e123 = i;
                            let _e127 = period;
                            spikeAngle2_ = (-3.1415927f + (f32((_e123 + 2i)) * _e127));
                            let _e130 = i;
                            let _e131 = spikeCount_1;
                            if (_e130 != (_e131 - 2i)) {
                                let _e135 = spikeAngle2_;
                                let _e136 = variability_1;
                                let _e137 = maxDisplacement;
                                let _e141 = i;
                                let _e145 = randomSeed_1;
                                let _e146 = rand2relSeeded(vec2<f32>(f32(_e141), 0f), _e145);
                                spikeAngle2_ = (_e135 + (((_e136 * _e137) * 2f) * _e146.x));
                            }
                        }
                    }
                }
                continuing {
                    let _e93 = i;
                    i = (_e93 + 1i);
                }
            }
        }
    }
    let _e150 = u;
    d = length(_e150);
    let _e153 = d;
    let _e154 = a;
    let _e156 = a;
    u = (_e153 * vec2<f32>(cos(_e154), sin(_e156)));
    let _e160 = modelTransform_1;
    let _e162 = u;
    let _e170 = stretch_1;
    let _e173 = d;
    u = ((_naga_inverse_3x3_f32(_e160) * vec3<f32>(_e162.x, _e162.y, 1f)).xy * pow(2f, (-(_e170) * max(0f, _e173))));
    let _e178 = u;
    let _e182 = global.U[0];
    let _e185 = u;
    let _e194 = _mirror_wrap(((vec2<f32>((_e178.x / _e182.x), _e185.y) / vec2(2f)) + vec2(0.5f)));
    let _e195 = textureSample(t_source, samp, _e194);
    return _e195;
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
    let _e71 = global.U[6];
    let _e72 = _e71.xyz;
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e96 = global.U[9];
    let _e100 = global.U[10];
    let _e104 = global.U[11];
    let _e106 = kaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x, _e104.x);
    fragColor = _e106;
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
