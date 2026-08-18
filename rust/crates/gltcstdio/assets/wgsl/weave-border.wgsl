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

fn borderDistanceRounded(coord: vec2<f32>, ratio: f32, radius: f32, thickness: f32) -> f32 {
    var coord_1: vec2<f32>;
    var ratio_1: f32;
    var radius_1: f32;
    var thickness_1: f32;
    var D: f32;
    var x1_: f32;
    var x2_: f32;
    var y1_: f32;
    var y2_: f32;
    var X: f32;
    var Y: f32;

    coord_1 = coord;
    ratio_1 = ratio;
    radius_1 = radius;
    thickness_1 = thickness;
    let _e14 = radius_1;
    let _e15 = thickness_1;
    D = (_e14 + _e15);
    let _e18 = ratio_1;
    let _e20 = D;
    let _e22 = coord_1;
    let _e25 = D;
    x1_ = (((-(_e18) + _e20) - _e22.x) / _e25);
    let _e28 = coord_1;
    let _e30 = ratio_1;
    let _e31 = D;
    let _e34 = D;
    x2_ = ((_e28.x - (_e30 - _e31)) / _e34);
    let _e39 = D;
    let _e41 = coord_1;
    let _e44 = D;
    y1_ = (((-1f + _e39) - _e41.y) / _e44);
    let _e47 = coord_1;
    let _e50 = D;
    let _e53 = D;
    y2_ = ((_e47.y - (1f - _e50)) / _e53);
    let _e56 = x1_;
    let _e57 = x2_;
    X = max(_e56, _e57);
    let _e60 = y1_;
    let _e61 = y2_;
    Y = max(_e60, _e61);
    let _e64 = X;
    let _e67 = Y;
    if ((_e64 > 0f) && (_e67 > 0f)) {
        {
            let _e71 = X;
            let _e72 = Y;
            let _e75 = radius_1;
            let _e76 = radius_1;
            let _e77 = thickness_1;
            return (length(vec2<f32>(_e71, _e72)) - (_e75 / (_e76 + _e77)));
        }
    } else {
        {
            let _e81 = X;
            let _e82 = Y;
            let _e84 = radius_1;
            let _e85 = radius_1;
            let _e86 = thickness_1;
            return (max(_e81, _e82) - (_e84 / (_e85 + _e86)));
        }
    }
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

fn interpolatedRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var sfractY: f32;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e12 = v_3;
    sfractY = smoothstep(0f, 1f, fract(_e12.y));
    let _e17 = v_3;
    let _e19 = seed_3;
    let _e20 = rand2relSeeded(floor(_e17), _e19);
    let _e21 = v_3;
    let _e24 = v_3;
    let _e28 = seed_3;
    let _e29 = rand2relSeeded(vec2<f32>(floor(_e21.x), ceil(_e24.y)), _e28);
    let _e30 = sfractY;
    let _e33 = v_3;
    let _e36 = v_3;
    let _e40 = seed_3;
    let _e41 = rand2relSeeded(vec2<f32>(ceil(_e33.x), floor(_e36.y)), _e40);
    let _e42 = v_3;
    let _e44 = seed_3;
    let _e45 = rand2relSeeded(ceil(_e42), _e44);
    let _e46 = sfractY;
    let _e51 = v_3;
    return mix(mix(_e20, _e29, vec2(_e30)), mix(_e41, _e45, vec2(_e46)), vec2(smoothstep(0f, 1f, fract(_e51.x))));
}

fn sinewaves(coord_2: vec2<f32>, angle: f32, r: f32, baseAmp: f32, varAmp: f32, baseThickness: f32, varThickness: f32, size: f32, variability: f32, randomSeed: f32) -> f32 {
    var coord_3: vec2<f32>;
    var angle_1: f32;
    var r_1: f32;
    var baseAmp_1: f32;
    var varAmp_1: f32;
    var baseThickness_1: f32;
    var varThickness_1: f32;
    var size_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var scale: f32;
    var base: vec2<f32>;
    var seed_4: f32;
    var value: f32 = 0f;
    var j: i32 = -2i;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var amp: f32;
    var thickness_2: f32;
    var rr: f32;
    var d: f32;
    var k_4: f32;

    coord_3 = coord_2;
    angle_1 = angle;
    r_1 = r;
    baseAmp_1 = baseAmp;
    varAmp_1 = varAmp;
    baseThickness_1 = baseThickness;
    varThickness_1 = varThickness;
    size_1 = size;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    let _e26 = size_1;
    scale = (_e26 + 15f);
    let _e30 = r_1;
    let _e31 = scale;
    let _e33 = r_1;
    let _e34 = scale;
    base = floor(vec2<f32>((_e30 * _e31), (_e33 * _e34)));
    let _e39 = randomSeed_1;
    seed_4 = _e39;
    loop {
        let _e46 = j;
        let _e47 = scale;
        if !((_e46 <= (i32(_e47) + 2i))) {
            break;
        }
        {
            let _e57 = j;
            center = vec2<f32>(0f, f32(_e57));
            let _e61 = center;
            let _e62 = seed_4;
            let _e63 = rand2relSeeded(_e61, _e62);
            delta = _e63;
            let _e65 = center;
            let _e66 = variability_1;
            let _e73 = scale;
            let _e76 = delta;
            center = (_e65 + ((((_e66 * 100f) * vec2<f32>(6f, 2f)) / vec2(_e73)) * _e76));
            let _e79 = varAmp_1;
            let _e80 = delta;
            let _e85 = baseAmp_1;
            amp = (((_e79 * _e80.x) + 1f) * _e85);
            let _e88 = varThickness_1;
            let _e89 = delta;
            let _e94 = baseThickness_1;
            thickness_2 = (((_e88 * _e89.y) + 1f) * _e94);
            let _e97 = center;
            let _e99 = amp;
            let _e100 = center;
            let _e102 = angle_1;
            rr = (_e97.y + (_e99 * sin((_e100.x + (_e102 * 10f)))));
            let _e110 = r_1;
            let _e111 = scale;
            let _e113 = rr;
            let _e117 = thickness_2;
            d = (abs(((_e110 * _e111) - _e113)) / (30f * _e117));
            let _e121 = d;
            if (_e121 < 1f) {
                {
                    k_4 = 0.8f;
                    let _e126 = d;
                    let _e127 = k_4;
                    if (_e126 < _e127) {
                        {
                            return 1f;
                        }
                    } else {
                        {
                            let _e130 = value;
                            let _e132 = d;
                            let _e135 = k_4;
                            value = max(_e130, ((1f - _e132) / (1f - _e135)));
                        }
                    }
                }
            }
        }
        continuing {
            let _e53 = j;
            j = (_e53 + 1i);
        }
    }
    let _e139 = value;
    return _e139;
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

fn weaveBorder(pos: vec2<f32>, outPos: vec2<f32>, border: f32, sourceDim: vec2<f32>, outDim: vec2<f32>, borderColor: vec4<f32>, variability_2: f32, randomSeed_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var border_1: f32;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var borderColor_1: vec4<f32>;
    var variability_3: f32;
    var randomSeed_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var ratio_2: f32;
    var v_4: vec2<f32>;
    var bRel: f32;
    var B: f32;
    var angle_2: f32;
    var local: f32;
    var k_5: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    border_1 = border;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    borderColor_1 = borderColor;
    variability_3 = variability_2;
    randomSeed_3 = randomSeed_2;
    modelTransform_1 = modelTransform;
    let _e24 = outDim_1;
    let _e26 = outDim_1;
    ratio_2 = (_e24.x / _e26.y);
    let _e30 = modelTransform_1;
    let _e32 = pos_1;
    let _e33 = tf(_naga_inverse_3x3_f32(_e30), _e32);
    v_4 = _e33;
    let _e35 = border_1;
    bRel = (_e35 * 2f);
    let _e39 = outPos_1;
    let _e40 = ratio_2;
    let _e41 = bRel;
    let _e42 = bRel;
    let _e43 = borderDistanceRounded(_e39, _e40, _e41, _e42);
    let _e44 = variability_3;
    let _e47 = pos_1;
    let _e50 = randomSeed_3;
    let _e51 = interpolatedRand2Seeded((_e47 * 10f), _e50);
    B = (_e43 + ((_e44 * 0.08f) * _e51.x));
    let _e56 = B;
    if (_e56 <= 0f) {
        let _e59 = v_4;
        let _e63 = global.U[0];
        let _e66 = v_4;
        let _e75 = _mirror_wrap(((vec2<f32>((_e59.x / _e63.x), _e66.y) / vec2(2f)) + vec2(0.5f)));
        let _e76 = textureSample(t_source, samp, _e75);
        return _e76;
    }
    let _e77 = outPos_1;
    let _e79 = outPos_1;
    angle_2 = atan2(_e77.y, _e79.x);
    let _e84 = pos_1;
    let _e85 = angle_2;
    let _e86 = B;
    let _e90 = B;
    if (_e90 < 0f) {
        local = 0f;
    } else {
        let _e94 = B;
        local = pow(_e94, 0.7f);
    }
    let _e98 = local;
    let _e102 = variability_3;
    let _e103 = randomSeed_3;
    let _e104 = sinewaves(_e84, _e85, _e86, 2f, 1f, (0.1f * _e98), 0.5f, 20f, _e102, _e103);
    k_5 = (1f - _e104);
    let _e107 = k_5;
    if (_e107 == 0f) {
        let _e110 = borderColor_1;
        return _e110;
    }
    let _e111 = borderColor_1;
    let _e112 = v_4;
    let _e116 = global.U[0];
    let _e119 = v_4;
    let _e128 = _mirror_wrap(((vec2<f32>((_e112.x / _e116.x), _e119.y) / vec2(2f)) + vec2(0.5f)));
    let _e129 = textureSample(t_source, samp, _e128);
    let _e130 = k_5;
    return mix(_e111, _e129, vec4(_e130));
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
    let _e66 = global.U[6];
    let _e70 = global.U[4];
    let _e74 = global.U[5];
    let _e78 = global.U[7];
    let _e81 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e90 = _e89.xyz;
    let _e93 = global.U[11];
    let _e94 = _e93.xyz;
    let _e97 = global.U[12];
    let _e98 = _e97.xyz;
    let _e112 = weaveBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.xy, _e74.xy, _e78, _e81.x, _e85.x, mat3x3<f32>(vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z)));
    fragColor = _e112;
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
