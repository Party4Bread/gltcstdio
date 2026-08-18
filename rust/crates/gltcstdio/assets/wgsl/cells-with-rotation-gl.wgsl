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

fn cellsWithRotationGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, variability: f32, randomSeed: f32, perturbation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var perturbation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var minDelta: vec2<f32> = vec2(0f);
    var d2min: f32 = 1000000000f;
    var minCenter: vec2<f32> = vec2(0f);
    var j: i32 = -2i;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var d: vec2<f32>;
    var d2_: f32;
    var angle: f32;
    var cosa: f32;
    var sina: f32;
    var absCenter: vec2<f32>;
    var rel: vec2<f32>;
    var rotated: vec2<f32>;
    var newPos: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    perturbation_1 = perturbation;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = pos_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    t = _e23;
    let _e25 = perturbation_1;
    if (_e25 > 0f) {
        {
            let _e28 = t;
            let _e29 = t;
            let _e31 = perturbation_1;
            let _e36 = randomSeed_1;
            let _e37 = sineSurfaceRand2Seeded((_e29 * (1f + (_e31 * 0f))), _e36);
            let _e40 = perturbation_1;
            t = (_e28 + ((_e37 * 2.5f) * _e40));
        }
    }
    let _e43 = t;
    ci = floor(_e43.x);
    let _e47 = t;
    cj = floor(_e47.y);
    loop {
        let _e62 = j;
        if !((_e62 <= 2i)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e72 = i;
                if !((_e72 <= 2i)) {
                    break;
                }
                {
                    let _e79 = i;
                    let _e81 = ci;
                    let _e83 = j;
                    let _e85 = cj;
                    center = vec2<f32>((f32(_e79) + _e81), (f32(_e83) + _e85));
                    let _e89 = center;
                    let _e90 = randomSeed_1;
                    let _e91 = rand2relSeeded(_e89, _e90);
                    delta = _e91;
                    let _e93 = center;
                    let _e97 = delta;
                    let _e98 = variability_1;
                    center = (_e93 + (vec2<f32>(0.5f, 0.5f) + ((_e97 * _e98) * 2f)));
                    let _e104 = t;
                    let _e105 = center;
                    d = (_e104 - _e105);
                    let _e108 = d;
                    let _e109 = d;
                    d2_ = dot(_e108, _e109);
                    let _e112 = d2_;
                    let _e113 = d2min;
                    if (_e112 < _e113) {
                        {
                            let _e115 = d2_;
                            d2min = _e115;
                            let _e116 = center;
                            minCenter = _e116;
                            let _e117 = delta;
                            minDelta = _e117;
                        }
                    }
                }
                continuing {
                    let _e76 = i;
                    i = (_e76 + 1i);
                }
            }
        }
        continuing {
            let _e66 = j;
            j = (_e66 + 1i);
        }
    }
    let _e118 = minDelta;
    let _e120 = intensity_1;
    angle = ((_e118.x * _e120) * 20f);
    let _e125 = angle;
    cosa = cos(_e125);
    let _e128 = angle;
    sina = sin(_e128);
    let _e131 = modelTransform_1;
    let _e132 = minCenter;
    absCenter = (_e131 * vec3<f32>(_e132.x, _e132.y, 1f)).xy;
    let _e140 = pos_1;
    let _e141 = absCenter;
    rel = (_e140 - _e141);
    let _e144 = cosa;
    let _e145 = rel;
    let _e148 = sina;
    let _e149 = rel;
    let _e153 = sina;
    let _e154 = rel;
    let _e157 = cosa;
    let _e158 = rel;
    rotated = vec2<f32>(((_e144 * _e145.x) - (_e148 * _e149.y)), ((_e153 * _e154.x) + (_e157 * _e158.y)));
    let _e164 = absCenter;
    let _e165 = rotated;
    newPos = (_e164 + _e165);
    let _e168 = newPos;
    let _e172 = global.U[0];
    let _e175 = newPos;
    let _e184 = _mirror_wrap(((vec2<f32>((_e168.x / _e172.x), _e175.y) / vec2(2f)) + vec2(0.5f)));
    let _e185 = textureSample(t_source, samp, _e184);
    return _e185;
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
    let _e66 = global.U[8];
    let _e70 = global.U[9];
    let _e74 = global.U[10];
    let _e78 = global.U[11];
    let _e82 = global.U[12];
    let _e83 = _e82.xyz;
    let _e86 = global.U[13];
    let _e87 = _e86.xyz;
    let _e90 = global.U[14];
    let _e91 = _e90.xyz;
    let _e105 = cellsWithRotationGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
