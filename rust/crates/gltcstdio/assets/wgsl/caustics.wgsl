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

fn getDisplacement(pos: vec2<f32>, variability: f32, randomSeed: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var variability_1: f32;
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
    var scale: f32 = 10f;
    var intensity: f32;

    pos_1 = pos;
    variability_1 = variability;
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
    let _e123 = scale;
    let _e126 = variability_1;
    intensity = ((_e123 * 0.3f) * _e126);
    let _e129 = displacement;
    let _e130 = intensity;
    return (_e129 * _e130);
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
    return min(pow(min(1.2f, (_e9 + 0.35f)), 10f), 4f);
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

fn caustics(uv: vec2<f32>, outPos: vec2<f32>, count: i32, intensity_1: f32, dispersion: f32, variability_2: f32, randomSeed_2: f32, vignetting: f32, color: vec4<f32>, outDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var intensity_2: f32;
    var dispersion_1: f32;
    var variability_3: f32;
    var randomSeed_3: f32;
    var vignetting_1: f32;
    var color_1: vec4<f32>;
    var outDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var t_1: vec2<f32>;
    var col: vec4<f32>;
    var falloff: f32 = 1f;
    var diag: f32;
    var len: f32;
    var radius: f32;
    var light: vec3<f32>;
    var n_2: i32;
    var displacement_1: vec2<f32>;
    var g: f32;
    var ab: f32;
    var n_3: i32;
    var displacement_2: vec2<f32>;
    var r_1: f32;
    var y_1: f32;
    var g_1: f32;
    var c: f32;
    var b: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    count_1 = count;
    intensity_2 = intensity_1;
    dispersion_1 = dispersion;
    variability_3 = variability_2;
    randomSeed_3 = randomSeed_2;
    vignetting_1 = vignetting;
    color_1 = color;
    outDim_1 = outDim;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    let _e30 = uv_1;
    let _e31 = tf(_naga_inverse_3x3_f32(_e28), _e30);
    t_1 = _e31;
    let _e33 = uv_1;
    let _e37 = global.U[0];
    let _e40 = uv_1;
    let _e49 = textureSample(t_source, samp, ((vec2<f32>((_e33.x / _e37.x), _e40.y) / vec2(2f)) + vec2(0.5f)));
    col = _e49;
    let _e53 = vignetting_1;
    if (_e53 != 0f) {
        {
            let _e57 = outDim_1;
            let _e59 = outDim_1;
            diag = max(1f, (_e57.x / _e59.y));
            let _e64 = uv_1;
            len = length(_e64);
            let _e68 = vignetting_1;
            let _e70 = diag;
            radius = ((1.5f - _e68) * _e70);
            let _e75 = vignetting_1;
            let _e79 = radius;
            let _e80 = len;
            falloff = max(0f, (1f - ((_e75 * 2f) * smoothstep(0f, _e79, _e80))));
        }
    }
    let _e85 = intensity_2;
    if (_e85 != 0f) {
        {
            let _e89 = dispersion_1;
            if (_e89 == 0f) {
                {
                    let _e92 = count_1;
                    n_2 = _e92;
                    let _e94 = t_1;
                    let _e95 = variability_3;
                    let _e96 = randomSeed_3;
                    let _e97 = getDisplacement(_e94, _e95, _e96);
                    displacement_1 = _e97;
                    let _e99 = t_1;
                    let _e100 = displacement_1;
                    let _e102 = n_2;
                    let _e103 = voronoiOctaveNoise((_e99 + _e100), _e102);
                    let _e104 = threshold_1(_e103);
                    g = _e104;
                    let _e106 = color_1;
                    let _e108 = g;
                    let _e109 = g;
                    let _e110 = g;
                    light = (_e106.xyz * vec3<f32>(_e108, _e109, _e110));
                }
            } else {
                {
                    let _e113 = dispersion_1;
                    let _e117 = variability_3;
                    ab = ((_e113 * 0.1f) / (0.01f + _e117));
                    let _e121 = count_1;
                    n_3 = _e121;
                    let _e123 = t_1;
                    let _e124 = variability_3;
                    let _e125 = randomSeed_3;
                    let _e126 = getDisplacement(_e123, _e124, _e125);
                    displacement_2 = _e126;
                    let _e128 = t_1;
                    let _e129 = displacement_2;
                    let _e131 = ab;
                    let _e135 = n_3;
                    let _e136 = voronoiOctaveNoise((_e128 + (_e129 * (1f - _e131))), _e135);
                    let _e137 = threshold_1(_e136);
                    r_1 = _e137;
                    let _e139 = t_1;
                    let _e140 = displacement_2;
                    let _e143 = ab;
                    let _e148 = n_3;
                    let _e149 = voronoiOctaveNoise((_e139 + (_e140 * (1f - (0.5f * _e143)))), _e148);
                    let _e150 = threshold_1(_e149);
                    y_1 = _e150;
                    let _e152 = t_1;
                    let _e153 = displacement_2;
                    let _e155 = n_3;
                    let _e156 = voronoiOctaveNoise((_e152 + _e153), _e155);
                    let _e157 = threshold_1(_e156);
                    g_1 = _e157;
                    let _e159 = t_1;
                    let _e160 = displacement_2;
                    let _e163 = ab;
                    let _e168 = n_3;
                    let _e169 = voronoiOctaveNoise((_e159 + (_e160 * (1f + (0.5f * _e163)))), _e168);
                    let _e170 = threshold_1(_e169);
                    c = _e170;
                    let _e172 = t_1;
                    let _e173 = displacement_2;
                    let _e176 = ab;
                    let _e181 = n_3;
                    let _e182 = voronoiOctaveNoise((_e172 + (_e173 * (1f + (1.5f * _e176)))), _e181);
                    let _e183 = threshold_1(_e182);
                    b = _e183;
                    let _e185 = color_1;
                    let _e187 = r_1;
                    let _e191 = y_1;
                    let _e195 = y_1;
                    let _e198 = g_1;
                    let _e202 = c;
                    let _e206 = c;
                    let _e209 = b;
                    light = (_e185.xyz * vec3<f32>(((_e187 * 0.66f) + (0.33f * _e191)), (((0.4f * _e195) + (0.2f * _e198)) + (0.4f * _e202)), ((0.15f * _e206) + (0.85f * _e209))));
                }
            }
            let _e214 = col;
            let _e216 = col;
            let _e218 = intensity_2;
            let _e221 = light;
            let _e223 = falloff;
            let _e225 = (_e216.xyz + (((_e218 * 5f) * _e221) * _e223));
            col.x = _e225.x;
            col.y = _e225.y;
            col.z = _e225.z;
        }
    }
    let _e232 = col;
    return _e232;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e94 = global.U[4];
    let _e98 = global.U[12];
    let _e99 = _e98.xyz;
    let _e102 = global.U[13];
    let _e103 = _e102.xyz;
    let _e106 = global.U[14];
    let _e107 = _e106.xyz;
    let _e121 = caustics((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87.x, _e91, _e94.xy, mat3x3<f32>(vec3<f32>(_e99.x, _e99.y, _e99.z), vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z)));
    fragColor = _e121;
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
