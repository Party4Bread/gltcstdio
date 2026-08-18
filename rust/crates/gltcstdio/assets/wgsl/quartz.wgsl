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

fn quartz(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, randomSeed: f32, variability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var origPos: vec2<f32>;
    var ii: i32 = 0i;
    var t: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var k_4: f32;
    var minDelta: vec2<f32>;
    var d2min: f32;
    var minI: i32;
    var minJ: i32;
    var minCenter: vec2<f32>;
    var minRadiusModifier: f32;
    var j: i32;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var d: vec2<f32>;
    var d2_: f32;
    var delta_1: vec2<f32>;
    var newPos: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    let _e20 = pos_1;
    origPos = _e20;
    loop {
        let _e24 = ii;
        let _e25 = count_1;
        if !((_e24 < _e25)) {
            break;
        }
        {
            let _e31 = modelTransform_1;
            let _e33 = pos_1;
            let _e34 = tf(_naga_inverse_3x3_f32(_e31), _e33);
            t = _e34;
            let _e36 = t;
            ci = floor(_e36.x);
            let _e40 = t;
            cj = floor(_e40.y);
            k_4 = 0f;
            d2min = 1000000000f;
            minI = 0i;
            minJ = 0i;
            j = -2i;
            loop {
                let _e58 = j;
                if !((_e58 <= 2i)) {
                    break;
                }
                {
                    i = -2i;
                    loop {
                        let _e68 = i;
                        if !((_e68 <= 2i)) {
                            break;
                        }
                        {
                            let _e75 = i;
                            let _e77 = ci;
                            let _e79 = j;
                            let _e81 = cj;
                            center = vec2<f32>((f32(_e75) + _e77), (f32(_e79) + _e81));
                            let _e85 = center;
                            let _e86 = randomSeed_1;
                            let _e87 = rand2relSeeded(_e85, _e86);
                            delta = _e87;
                            let _e91 = delta;
                            radiusModifier = max(0.01f, (1f + (_e91.x * 1f)));
                            let _e98 = center;
                            let _e102 = delta;
                            let _e103 = variability_1;
                            center = (_e98 + (vec2<f32>(0.5f, 0.5f) + ((_e102 * _e103) * 2f)));
                            let _e109 = t;
                            let _e110 = center;
                            d = (_e109 - _e110);
                            let _e113 = d;
                            let _e116 = d;
                            d2_ = (abs(_e113.x) + abs(_e116.y));
                            let _e121 = d2_;
                            let _e122 = radiusModifier;
                            let _e124 = d2min;
                            if ((_e121 / _e122) < _e124) {
                                {
                                    let _e126 = d2_;
                                    d2min = _e126;
                                    let _e127 = i;
                                    minI = _e127;
                                    let _e128 = j;
                                    minJ = _e128;
                                    let _e129 = center;
                                    minCenter = _e129;
                                    let _e130 = delta;
                                    minDelta = _e130;
                                    let _e131 = radiusModifier;
                                    minRadiusModifier = _e131;
                                }
                            }
                        }
                        continuing {
                            let _e72 = i;
                            i = (_e72 + 1i);
                        }
                    }
                }
                continuing {
                    let _e62 = j;
                    j = (_e62 + 1i);
                }
            }
            let _e132 = d2min;
            k_4 = sqrt(_e132);
            let _e134 = k_4;
            k_4 = clamp(_e134, 0f, 1f);
            let _e138 = minDelta;
            let _e139 = intensity_1;
            delta_1 = ((_e138 * _e139) * 2f);
            let _e144 = pos_1;
            let _e145 = delta_1;
            newPos = (_e144 + _e145);
            let _e148 = newPos;
            pos_1 = _e148;
        }
        continuing {
            let _e28 = ii;
            ii = (_e28 + 1i);
        }
    }
    let _e149 = pos_1;
    let _e153 = global.U[0];
    let _e156 = pos_1;
    let _e165 = textureSample(t_source, samp, ((vec2<f32>((_e149.x / _e153.x), _e156.y) / vec2(2f)) + vec2(0.5f)));
    return _e165;
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = quartz((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
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
