struct Params {
    U: array<vec4<f32>, 16>,
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

fn borderDistance(coord: vec2<f32>, ratio: f32, M: f32, border: f32) -> f32 {
    var coord_1: vec2<f32>;
    var ratio_1: f32;
    var M_1: f32;
    var border_1: f32;

    coord_1 = coord;
    ratio_1 = ratio;
    M_1 = M;
    border_1 = border;
    let _e14 = border_1;
    if (_e14 == 0f) {
        return 0f;
    }
    let _e18 = ratio_1;
    let _e20 = border_1;
    let _e22 = coord_1;
    let _e25 = border_1;
    let _e27 = coord_1;
    let _e29 = ratio_1;
    let _e30 = border_1;
    let _e33 = border_1;
    let _e38 = border_1;
    let _e40 = coord_1;
    let _e43 = border_1;
    let _e45 = coord_1;
    let _e48 = border_1;
    let _e51 = border_1;
    return max(max((((-(_e18) + _e20) - _e22.x) / _e25), ((_e27.x - (_e29 - _e30)) / _e33)), max((((-1f + _e38) - _e40.y) / _e43), ((_e45.y - (1f - _e48)) / _e51)));
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

fn lenP(u: vec2<f32>, k_4: f32) -> f32 {
    var u_1: vec2<f32>;
    var k_5: f32;
    var v_4: vec2<f32>;

    u_1 = u;
    k_5 = k_4;
    let _e10 = u_1;
    v_4 = abs(_e10);
    let _e13 = v_4;
    let _e15 = k_5;
    let _e17 = v_4;
    let _e19 = k_5;
    let _e23 = k_5;
    return pow((pow(_e13.x, _e15) + pow(_e17.y, _e19)), (1f / _e23));
}

fn circles(coord_2: vec2<f32>, k_6: f32, baseRadius: f32, varRadius: f32, angleVariability: f32, variability: f32, seed_4: f32) -> f32 {
    var coord_3: vec2<f32>;
    var k_7: f32;
    var baseRadius_1: f32;
    var varRadius_1: f32;
    var angleVariability_1: f32;
    var variability_1: f32;
    var seed_5: f32;
    var base: vec2<f32>;
    var minD: f32 = 10000f;
    var N: i32;
    var j: i32;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radius: f32;
    var v_5: vec2<f32>;
    var angle: f32;
    var d: f32;

    coord_3 = coord_2;
    k_7 = k_6;
    baseRadius_1 = baseRadius;
    varRadius_1 = varRadius;
    angleVariability_1 = angleVariability;
    variability_1 = variability;
    seed_5 = seed_4;
    let _e20 = coord_3;
    base = floor(_e20);
    let _e25 = k_7;
    let _e28 = baseRadius_1;
    let _e29 = varRadius_1;
    N = i32(ceil(((_e25 * 0.01f) + (_e28 * _e29))));
    let _e35 = N;
    j = -(_e35);
    loop {
        let _e38 = j;
        let _e39 = N;
        if !((_e38 <= _e39)) {
            break;
        }
        {
            let _e45 = N;
            i = -(_e45);
            loop {
                let _e48 = i;
                let _e49 = N;
                if !((_e48 <= _e49)) {
                    break;
                }
                {
                    let _e55 = i;
                    let _e57 = j;
                    let _e60 = base;
                    center = (vec2<f32>(f32(_e55), f32(_e57)) + _e60);
                    let _e63 = center;
                    let _e64 = seed_5;
                    let _e65 = rand2relSeeded(_e63, _e64);
                    delta = _e65;
                    let _e67 = varRadius_1;
                    let _e68 = delta;
                    let _e73 = baseRadius_1;
                    radius = (((_e67 * _e68.x) + 1f) * _e73);
                    let _e76 = center;
                    let _e80 = variability_1;
                    let _e83 = delta;
                    let _e85 = k_7;
                    center = (_e76 + (vec2<f32>(0.5f, 0.5f) + ((((_e80 * 0.5f) * _e83) * _e85) * 0.02f)));
                    let _e91 = coord_3;
                    let _e92 = center;
                    v_5 = (_e91 - _e92);
                    let _e95 = angleVariability_1;
                    if (_e95 != 0f) {
                        {
                            let _e98 = angleVariability_1;
                            let _e99 = variability_1;
                            let _e103 = center;
                            let _e106 = seed_5;
                            let _e107 = interpolatedRand2Seeded((_e103 * 5f), _e106);
                            angle = (((_e98 * _e99) * 3.1415927f) * _e107.y);
                            let _e111 = v_5;
                            let _e113 = angle;
                            let _e116 = v_5;
                            let _e118 = angle;
                            let _e122 = v_5;
                            let _e124 = angle;
                            let _e127 = v_5;
                            let _e129 = angle;
                            v_5 = vec2<f32>(((_e111.x * cos(_e113)) - (_e116.y * sin(_e118))), ((_e122.y * cos(_e124)) + (_e127.x * sin(_e129))));
                        }
                    }
                    let _e134 = v_5;
                    let _e136 = lenP(_e134, 4f);
                    d = _e136;
                    let _e138 = d;
                    let _e139 = radius;
                    if (_e138 < _e139) {
                        {
                            return 1f;
                        }
                    }
                }
                continuing {
                    let _e52 = i;
                    i = (_e52 + 1i);
                }
            }
        }
        continuing {
            let _e42 = j;
            j = (_e42 + 1i);
        }
    }
    return 0f;
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

fn markerBorder(pos: vec2<f32>, outPos: vec2<f32>, border_2: f32, sourceDim: vec2<f32>, outDim: vec2<f32>, borderColor: vec4<f32>, variability_2: f32, randomSeed: f32, modelTransform: mat3x3<f32>, borderTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var border_3: f32;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var borderColor_1: vec4<f32>;
    var variability_3: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var borderTransform_1: mat3x3<f32>;
    var angleVariability_2: f32 = 0.2f;
    var ratio_2: f32;
    var v_6: vec2<f32>;
    var bRel: f32;
    var B: f32;
    var u_4: vec2<f32>;
    var angle_1: f32;
    var k_8: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    border_3 = border_2;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    borderColor_1 = borderColor;
    variability_3 = variability_2;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    borderTransform_1 = borderTransform;
    let _e28 = outDim_1;
    let _e30 = outDim_1;
    ratio_2 = (_e28.x / _e30.y);
    let _e34 = modelTransform_1;
    let _e36 = pos_1;
    let _e37 = tf(_naga_inverse_3x3_f32(_e34), _e36);
    v_6 = _e37;
    let _e39 = border_3;
    bRel = (_e39 * 2f);
    let _e43 = outPos_1;
    let _e44 = ratio_2;
    let _e46 = border_3;
    let _e47 = borderDistance(_e43, _e44, 0.1f, _e46);
    let _e48 = variability_3;
    let _e51 = pos_1;
    let _e54 = randomSeed_1;
    let _e55 = interpolatedRand2Seeded((_e51 * 10f), _e54);
    B = (_e47 + ((_e48 * 0.08f) * _e55.x));
    let _e60 = B;
    if (_e60 <= 0f) {
        let _e63 = v_6;
        let _e67 = global.U[0];
        let _e70 = v_6;
        let _e79 = _mirror_wrap(((vec2<f32>((_e63.x / _e67.x), _e70.y) / vec2(2f)) + vec2(0.5f)));
        let _e81 = textureSampleLevel(t_source, samp, _e79, 0f);
        return _e81;
    }
    let _e82 = borderTransform_1;
    let _e84 = pos_1;
    u_4 = (_naga_inverse_3x3_f32(_e82) * vec3<f32>(_e84.x, _e84.y, 1f)).xy;
    let _e92 = angleVariability_2;
    if (_e92 != 0f) {
        {
            let _e95 = angleVariability_2;
            let _e96 = variability_3;
            let _e100 = u_4;
            let _e103 = randomSeed_1;
            let _e104 = interpolatedRand2Seeded((_e100 * 0.01f), _e103);
            angle_1 = (((_e95 * _e96) * 3.1415927f) * (_e104.y - 0.5f));
            let _e110 = u_4;
            let _e112 = angle_1;
            let _e115 = u_4;
            let _e117 = angle_1;
            let _e121 = u_4;
            let _e123 = angle_1;
            let _e126 = u_4;
            let _e128 = angle_1;
            u_4 = vec2<f32>(((_e110.x * cos(_e112)) - (_e115.y * sin(_e117))), ((_e121.y * cos(_e123)) + (_e126.x * sin(_e128))));
        }
    }
    let _e133 = u_4;
    u_4 = (_e133 * vec2<f32>(1f, 0.01f));
    let _e139 = u_4;
    let _e141 = B;
    let _e144 = variability_3;
    let _e147 = angleVariability_2;
    let _e148 = variability_3;
    let _e149 = randomSeed_1;
    let _e150 = circles(_e139, 100f, pow(_e141, 0.9f), (_e144 * 0.5f), _e147, _e148, _e149);
    k_8 = (1f - _e150);
    let _e153 = k_8;
    if (_e153 == 0f) {
        let _e156 = borderColor_1;
        return _e156;
    }
    let _e157 = borderColor_1;
    let _e158 = v_6;
    let _e162 = global.U[0];
    let _e165 = v_6;
    let _e174 = _mirror_wrap(((vec2<f32>((_e158.x / _e162.x), _e165.y) / vec2(2f)) + vec2(0.5f)));
    let _e176 = textureSampleLevel(t_source, samp, _e174, 0f);
    let _e177 = k_8;
    return mix(_e157, _e176, vec4(_e177));
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
    let _e114 = global.U[13];
    let _e115 = _e114.xyz;
    let _e118 = global.U[14];
    let _e119 = _e118.xyz;
    let _e122 = global.U[15];
    let _e123 = _e122.xyz;
    let _e137 = markerBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.xy, _e74.xy, _e78, _e81.x, _e85.x, mat3x3<f32>(vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z)), mat3x3<f32>(vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z), vec3<f32>(_e123.x, _e123.y, _e123.z)));
    fragColor = _e137;
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
