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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
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

fn turb3Layer(u_2: vec2<f32>, intensity: f32, radiusVariability: f32, variability: f32, randomSeed: f32, balance: f32) -> vec2<f32> {
    var u_3: vec2<f32>;
    var intensity_1: f32;
    var radiusVariability_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var balance_1: f32;
    var ci: f32;
    var cj: f32;
    var k_4: f32 = 0f;
    var displacement: vec2<f32> = vec2<f32>(0f, 0f);
    var j: i32 = -2i;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var d: vec2<f32>;
    var threshold: f32;
    var bal: f32;
    var ratio2_: f32;
    var ratio2_1: f32;
    var dangle: f32;
    var ca: f32;
    var sa: f32;
    var rotated: vec2<f32>;

    u_3 = u_2;
    intensity_1 = intensity;
    radiusVariability_1 = radiusVariability;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    balance_1 = balance;
    let _e18 = u_3;
    ci = floor(_e18.x);
    let _e22 = u_3;
    cj = floor(_e22.y);
    loop {
        let _e35 = j;
        if !((_e35 <= 2i)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e45 = i;
                if !((_e45 <= 2i)) {
                    break;
                }
                {
                    let _e52 = i;
                    let _e54 = ci;
                    let _e56 = j;
                    let _e58 = cj;
                    center = vec2<f32>((f32(_e52) + _e54), (f32(_e56) + _e58));
                    let _e62 = center;
                    let _e63 = randomSeed_1;
                    let _e64 = rand2relSeeded(_e62, _e63);
                    delta = _e64;
                    let _e68 = delta;
                    let _e70 = radiusVariability_1;
                    radiusModifier = max(0.01f, (1f + (_e68.x * _e70)));
                    let _e75 = center;
                    let _e79 = delta;
                    let _e80 = variability_1;
                    center = (_e75 + (vec2<f32>(0.5f, 0.5f) + (_e79 * _e80)));
                    let _e84 = u_3;
                    let _e85 = center;
                    d = (_e84 - _e85);
                    let _e88 = d;
                    k_4 = length(_e88);
                    let _e90 = radiusModifier;
                    threshold = (_e90 * 0.75f);
                    let _e94 = k_4;
                    let _e95 = threshold;
                    if (_e94 < _e95) {
                        {
                            let _e97 = k_4;
                            let _e98 = threshold;
                            k_4 = (_e97 / _e98);
                            let _e100 = balance_1;
                            bal = ((-(_e100) + 1f) * 0.5f);
                            let _e107 = bal;
                            if (_e107 != 0.5f) {
                                {
                                    let _e110 = bal;
                                    let _e113 = k_4;
                                    let _e114 = bal;
                                    if ((_e110 == 1f) || (_e113 < _e114)) {
                                        {
                                            let _e117 = k_4;
                                            let _e118 = bal;
                                            ratio2_ = (_e117 / _e118);
                                            let _e122 = ratio2_;
                                            k_4 = (0.5f * _e122);
                                        }
                                    } else {
                                        {
                                            let _e124 = k_4;
                                            let _e125 = bal;
                                            let _e128 = bal;
                                            ratio2_1 = ((_e124 - _e125) / (1f - _e128));
                                            let _e134 = ratio2_1;
                                            k_4 = (0.5f * (1f - _e134));
                                        }
                                    }
                                }
                            }
                            let _e137 = intensity_1;
                            let _e138 = delta;
                            let _e144 = k_4;
                            dangle = (((_e137 * _e138.x) * 10f) * (1f - cos(((_e144 * 2f) * 3.1415927f))));
                            let _e153 = dangle;
                            ca = cos(_e153);
                            let _e156 = dangle;
                            sa = sin(_e156);
                            let _e159 = ca;
                            let _e160 = d;
                            let _e163 = sa;
                            let _e164 = d;
                            let _e168 = ca;
                            let _e169 = d;
                            let _e172 = sa;
                            let _e173 = d;
                            rotated = vec2<f32>(((_e159 * _e160.x) - (_e163 * _e164.y)), ((_e168 * _e169.y) + (_e172 * _e173.x)));
                            let _e179 = displacement;
                            let _e180 = rotated;
                            let _e181 = d;
                            displacement = (_e179 + (_e180 - _e181));
                        }
                    }
                }
                continuing {
                    let _e49 = i;
                    i = (_e49 + 1i);
                }
            }
        }
        continuing {
            let _e39 = j;
            j = (_e39 + 1i);
        }
    }
    let _e184 = displacement;
    return _e184;
}

fn turbulence3_(uv: vec2<f32>, outPos: vec2<f32>, intensity_2: f32, layers: f32, radiusVariability_2: f32, variability_2: f32, randomSeed_2: f32, balance_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_3: f32;
    var layers_1: f32;
    var radiusVariability_3: f32;
    var variability_3: f32;
    var randomSeed_3: f32;
    var balance_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_3 = intensity_2;
    layers_1 = layers;
    radiusVariability_3 = radiusVariability_2;
    variability_3 = variability_2;
    randomSeed_3 = randomSeed_2;
    balance_3 = balance_2;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    let _e26 = uv_1;
    let _e27 = tf(_naga_inverse_3x3_f32(_e24), _e26);
    u_4 = _e27;
    let _e29 = u_4;
    let _e30 = u_4;
    let _e31 = intensity_3;
    let _e32 = radiusVariability_3;
    let _e33 = variability_3;
    let _e34 = randomSeed_3;
    let _e35 = balance_3;
    let _e36 = turb3Layer(_e30, _e31, _e32, _e33, _e34, _e35);
    u_4 = (_e29 + _e36);
    let _e38 = layers_1;
    if (_e38 > 0f) {
        {
            let _e41 = u_4;
            let _e43 = layers_1;
            let _e49 = u_4;
            let _e52 = intensity_3;
            let _e53 = radiusVariability_3;
            let _e54 = variability_3;
            let _e55 = randomSeed_3;
            let _e58 = balance_3;
            let _e59 = turb3Layer((_e49 * 0.5f), _e52, _e53, _e54, (_e55 + 1.1f), _e58);
            u_4 = (_e41 + ((min(1f, (_e43 * 4f)) * 2f) * _e59));
        }
    }
    let _e62 = layers_1;
    if (_e62 > 0.25f) {
        {
            let _e65 = u_4;
            let _e67 = layers_1;
            let _e75 = u_4;
            let _e78 = intensity_3;
            let _e79 = radiusVariability_3;
            let _e80 = variability_3;
            let _e81 = randomSeed_3;
            let _e84 = balance_3;
            let _e85 = turb3Layer((_e75 * 0.25f), _e78, _e79, _e80, (_e81 - 1.2f), _e84);
            u_4 = (_e65 + ((min(1f, ((_e67 * 4f) - 1f)) * 4f) * _e85));
        }
    }
    let _e88 = layers_1;
    if (_e88 > 0.5f) {
        {
            let _e91 = u_4;
            let _e93 = layers_1;
            let _e101 = u_4;
            let _e104 = intensity_3;
            let _e105 = radiusVariability_3;
            let _e106 = variability_3;
            let _e107 = randomSeed_3;
            let _e110 = balance_3;
            let _e111 = turb3Layer((_e101 * 0.125f), _e104, _e105, _e106, (_e107 - 2.22f), _e110);
            u_4 = (_e91 + ((min(1f, ((_e93 * 4f) - 2f)) * 8f) * _e111));
        }
    }
    let _e114 = layers_1;
    if (_e114 > 0.75f) {
        {
            let _e117 = u_4;
            let _e119 = layers_1;
            let _e127 = u_4;
            let _e130 = intensity_3;
            let _e131 = radiusVariability_3;
            let _e132 = variability_3;
            let _e133 = randomSeed_3;
            let _e136 = balance_3;
            let _e137 = turb3Layer((_e127 * 0.0625f), _e130, _e131, _e132, (_e133 + 2.72f), _e136);
            u_4 = (_e117 + ((min(1f, ((_e119 * 4f) - 3f)) * 16f) * _e137));
        }
    }
    let _e140 = modelTransform_1;
    let _e141 = u_4;
    let _e142 = tf(_e140, _e141);
    u_4 = _e142;
    let _e143 = u_4;
    let _e147 = global.U[0];
    let _e150 = u_4;
    let _e159 = _mirror_wrap(((vec2<f32>((_e143.x / _e147.x), _e150.y) / vec2(2f)) + vec2(0.5f)));
    let _e160 = textureSample(t_source, samp, _e159);
    return _e160;
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
    let _e113 = turbulence3_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)));
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
