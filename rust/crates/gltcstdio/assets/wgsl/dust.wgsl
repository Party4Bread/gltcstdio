struct Params {
    U: array<vec4<f32>, 10>,
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

fn getDisplacement(pos: vec2<f32>, scale: f32, randomSeed: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var scale_1: f32;
    var randomSeed_1: f32;
    var t: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var k_4: f32 = 0f;
    var displacement: vec2<f32> = vec2<f32>(0f, 0f);
    var radiusVariability: f32 = 1f;
    var variab: f32 = 1f;
    var j: i32 = -2i;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var d: vec2<f32>;
    var threshold: f32;
    var r: f32;
    var dp: f32;
    var intensity: f32 = 20f;

    pos_1 = pos;
    scale_1 = scale;
    randomSeed_1 = randomSeed;
    let _e12 = pos_1;
    t = _e12;
    let _e14 = t;
    ci = floor(_e14.x);
    let _e18 = t;
    cj = floor(_e18.y);
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
                    let _e70 = radiusVariability;
                    radiusModifier = max(0.3f, (1.2f + (_e68.x * _e70)));
                    let _e75 = center;
                    let _e79 = delta;
                    let _e80 = variab;
                    center = (_e75 + (vec2<f32>(0.5f, 0.5f) + (_e79 * _e80)));
                    let _e84 = t;
                    let _e85 = center;
                    d = (_e84 - _e85);
                    let _e88 = d;
                    k_4 = length(_e88);
                    let _e90 = radiusModifier;
                    threshold = _e90;
                    let _e92 = k_4;
                    let _e93 = threshold;
                    if (_e92 < _e93) {
                        {
                            let _e95 = k_4;
                            let _e96 = threshold;
                            k_4 = (_e95 / _e96);
                            let _e99 = k_4;
                            let _e102 = k_4;
                            r = (((0.5f - _e99) * (0.5f - _e102)) * 4f);
                            let _e109 = r;
                            let _e112 = r;
                            dp = ((1f - _e109) / (0.5f + _e112));
                            let _e116 = displacement;
                            let _e117 = dp;
                            let _e118 = d;
                            displacement = (_e116 + (_e117 * _e118));
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
    let _e123 = displacement;
    let _e124 = intensity;
    return (_e123 * _e124);
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

fn threshold_1(value: f32) -> f32 {
    var value_1: f32;

    value_1 = value;
    let _e9 = value_1;
    return min(pow(min(1.1f, (_e9 + 0.3f)), 30f), 4f);
}

fn voronoiOctaveNoise(u_2: vec2<f32>, n: i32) -> f32 {
    var u_3: vec2<f32>;
    var n_1: i32;
    var noise_4: f32 = 0f;
    var amplitude: f32 = 0.6f;
    var k_5: i32 = 0i;
    var v_2: vec2<f32>;
    var closest: f32;
    var j_1: i32;
    var i_1: i32;
    var point: vec2<f32>;
    var displace: vec2<f32>;
    var distance: f32;

    u_3 = u_2;
    n_1 = n;
    loop {
        let _e16 = k_5;
        let _e17 = n_1;
        if !((_e16 < _e17)) {
            break;
        }
        {
            let _e23 = u_3;
            let _e27 = u_3;
            v_2 = floor(vec2<f32>((_e23.x + 0.5f), (_e27.y + 0.5f)));
            closest = 1000000000f;
            j_1 = -2i;
            loop {
                let _e39 = j_1;
                if !((_e39 <= 2i)) {
                    break;
                }
                {
                    i_1 = -2i;
                    loop {
                        let _e49 = i_1;
                        if !((_e49 <= 2i)) {
                            break;
                        }
                        {
                            let _e56 = v_2;
                            let _e58 = i_1;
                            let _e61 = v_2;
                            let _e63 = j_1;
                            point = vec2<f32>((_e56.x + f32(_e58)), (_e61.y + f32(_e63)));
                            let _e68 = point;
                            let _e69 = rand2_(_e68);
                            displace = ((_e69 - vec2<f32>(0.5f, 0.5f)) * 2f);
                            let _e77 = point;
                            let _e78 = displace;
                            let _e80 = u_3;
                            distance = length(((_e77 + _e78) - _e80));
                            let _e84 = distance;
                            let _e85 = closest;
                            if (_e84 < _e85) {
                                {
                                    let _e87 = distance;
                                    closest = _e87;
                                }
                            }
                        }
                        continuing {
                            let _e53 = i_1;
                            i_1 = (_e53 + 1i);
                        }
                    }
                }
                continuing {
                    let _e43 = j_1;
                    j_1 = (_e43 + 1i);
                }
            }
            let _e88 = noise_4;
            let _e89 = amplitude;
            let _e90 = closest;
            noise_4 = (_e88 + (_e89 * _e90));
            let _e93 = amplitude;
            amplitude = (_e93 * 0.5f);
            let _e96 = u_3;
            u_3 = ((_e96 * 2f) + vec2<f32>(1.34f, 2.55f));
        }
        continuing {
            let _e20 = k_5;
            k_5 = (_e20 + 1i);
        }
    }
    let _e103 = noise_4;
    return _e103;
}

fn dust(uv: vec2<f32>, outPos: vec2<f32>, intensity_1: f32, randomSeed_2: f32, outDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_2: f32;
    var randomSeed_3: f32;
    var outDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var t_1: vec2<f32>;
    var scale_2: f32;
    var col: vec4<f32>;
    var lumNoise: f32;
    var g: f32;
    var dustValue: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_2 = intensity_1;
    randomSeed_3 = randomSeed_2;
    outDim_1 = outDim;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e18);
    let _e21 = invModelTransform;
    let _e22 = uv_1;
    let _e23 = tf(_e21, _e22);
    t_1 = _e23;
    let _e27 = invModelTransform[0];
    scale_2 = length(_e27.xy);
    let _e31 = uv_1;
    let _e35 = global.U[0];
    let _e38 = uv_1;
    let _e47 = textureSample(t_source, samp, ((vec2<f32>((_e31.x / _e35.x), _e38.y) / vec2(2f)) + vec2(0.5f)));
    col = _e47;
    let _e49 = intensity_2;
    if (_e49 != 0f) {
        {
            let _e52 = t_1;
            let _e53 = scale_2;
            let _e54 = randomSeed_3;
            let _e55 = getDisplacement(_e52, _e53, _e54);
            let _e57 = voronoiOctaveNoise(_e55, 1i);
            lumNoise = _e57;
            let _e59 = lumNoise;
            let _e60 = threshold_1(_e59);
            g = _e60;
            let _e62 = intensity_2;
            let _e63 = g;
            dustValue = (_e62 * _e63);
            let _e66 = col;
            let _e68 = col;
            let _e70 = intensity_2;
            let _e71 = g;
            let _e74 = (_e68.xyz + vec3((_e70 * _e71)));
            col.x = _e74.x;
            col.y = _e74.y;
            col.z = _e74.z;
        }
    }
    let _e81 = col;
    return _e81;
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
    let _e74 = global.U[4];
    let _e78 = global.U[7];
    let _e79 = _e78.xyz;
    let _e82 = global.U[8];
    let _e83 = _e82.xyz;
    let _e86 = global.U[9];
    let _e87 = _e86.xyz;
    let _e101 = dust((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.xy, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
    fragColor = _e101;
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
