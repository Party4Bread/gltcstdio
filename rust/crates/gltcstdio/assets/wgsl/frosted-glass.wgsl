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

fn interpolatedRand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var fractY: f32;

    v_3 = v_2;
    let _e8 = v_3;
    fractY = fract(_e8.y);
    let _e12 = v_3;
    let _e14 = rand2_(floor(_e12));
    let _e15 = v_3;
    let _e18 = v_3;
    let _e22 = rand2_(vec2<f32>(floor(_e15.x), ceil(_e18.y)));
    let _e23 = fractY;
    let _e26 = v_3;
    let _e29 = v_3;
    let _e33 = rand2_(vec2<f32>(ceil(_e26.x), floor(_e29.y)));
    let _e34 = v_3;
    let _e36 = rand2_(ceil(_e34));
    let _e37 = fractY;
    let _e40 = v_3;
    return mix(mix(_e14, _e22, vec2(_e23)), mix(_e33, _e36, vec2(_e37)), vec2(fract(_e40.x)));
}

fn fractalValueNoiseDisplace(u: vec2<f32>, v_4: vec2<f32>, count: i32, intensity: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var v_5: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var s: f32 = 1f;
    var maxDisplacement: f32;
    var totalDisp: vec2<f32> = vec2(0f);
    var i: i32 = 0i;
    var disp: vec2<f32>;

    u_1 = u;
    v_5 = v_4;
    count_1 = count;
    intensity_1 = intensity;
    let _e16 = intensity_1;
    maxDisplacement = _e16;
    loop {
        let _e23 = i;
        let _e24 = count_1;
        if !((_e23 < _e24)) {
            break;
        }
        {
            let _e30 = v_5;
            let _e31 = s;
            let _e33 = interpolatedRand2_((_e30 * _e31));
            disp = _e33;
            let _e35 = totalDisp;
            let _e36 = maxDisplacement;
            let _e37 = disp;
            totalDisp = (_e35 + ((_e36 * (_e37 - vec2<f32>(0.5f, 0.5f))) * 2f));
            let _e46 = maxDisplacement;
            maxDisplacement = (_e46 * 0.5f);
            let _e49 = s;
            s = (_e49 * 2.1055472f);
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    let _e52 = u_1;
    let _e53 = totalDisp;
    return (_e52 + _e53);
}

fn perlinDisplace(u_2: vec2<f32>, count_2: i32, intensity_2: f32) -> vec2<f32> {
    var u_3: vec2<f32>;
    var count_3: i32;
    var intensity_3: f32;
    var s_1: f32 = 1f;
    var maxDisplacement_1: f32;
    var totalDisp_1: vec2<f32>;
    var i_1: i32 = 0i;
    var disp_1: vec2<f32>;

    u_3 = u_2;
    count_3 = count_2;
    intensity_3 = intensity_2;
    let _e14 = intensity_3;
    maxDisplacement_1 = _e14;
    loop {
        let _e19 = i_1;
        let _e20 = count_3;
        if !((_e19 < _e20)) {
            break;
        }
        {
            let _e26 = u_3;
            let _e27 = s_1;
            let _e29 = interpolatedRand2_((_e26 * _e27));
            disp_1 = _e29;
            let _e31 = totalDisp_1;
            let _e32 = maxDisplacement_1;
            let _e33 = disp_1;
            totalDisp_1 = (_e31 + ((_e32 * (_e33 - vec2<f32>(0.5f, 0.5f))) * 2f));
            let _e42 = maxDisplacement_1;
            maxDisplacement_1 = (_e42 * 0.5f);
            let _e45 = s_1;
            s_1 = (_e45 * 2.2f);
        }
        continuing {
            let _e23 = i_1;
            i_1 = (_e23 + 1i);
        }
    }
    let _e48 = u_3;
    let _e49 = totalDisp_1;
    return (_e48 + _e49);
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

fn frostedGlass(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, intensity_4: f32, radiusVariability: f32, variability: f32, randomSeed: f32, perturbation: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensity_5: f32;
    var radiusVariability_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var perturbation_1: f32;
    var t: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var k_4: f32 = 0f;
    var displacement: vec2<f32> = vec2<f32>(0f, 0f);
    var j: i32 = -2i;
    var i_2: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var d: vec2<f32>;
    var threshold: f32;
    var r: f32;
    var dp: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    intensity_5 = intensity_4;
    radiusVariability_1 = radiusVariability;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    perturbation_1 = perturbation;
    let _e22 = modelTransform_1;
    let _e24 = pos_1;
    t = (_naga_inverse_3x3_f32(_e22) * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e32 = perturbation_1;
    if (_e32 > 0f) {
        {
            let _e35 = t;
            let _e37 = perturbation_1;
            let _e40 = perlinDisplace(_e35, 3i, (_e37 * 4f));
            t = _e40;
        }
    }
    let _e41 = t;
    ci = floor(_e41.x);
    let _e45 = t;
    cj = floor(_e45.y);
    loop {
        let _e58 = j;
        if !((_e58 <= 2i)) {
            break;
        }
        {
            i_2 = -2i;
            loop {
                let _e68 = i_2;
                if !((_e68 <= 2i)) {
                    break;
                }
                {
                    let _e75 = i_2;
                    let _e77 = ci;
                    let _e79 = j;
                    let _e81 = cj;
                    center = vec2<f32>((f32(_e75) + _e77), (f32(_e79) + _e81));
                    let _e85 = center;
                    let _e86 = randomSeed_1;
                    let _e87 = rand2relSeeded(_e85, _e86);
                    delta = _e87;
                    let _e91 = delta;
                    let _e93 = radiusVariability_1;
                    radiusModifier = max(0.3f, (1.2f + (_e91.x * _e93)));
                    let _e98 = center;
                    let _e102 = delta;
                    let _e103 = variability_1;
                    center = (_e98 + (vec2<f32>(0.5f, 0.5f) + (_e102 * _e103)));
                    let _e107 = t;
                    let _e108 = center;
                    d = (_e107 - _e108);
                    let _e111 = d;
                    k_4 = length(_e111);
                    let _e113 = radiusModifier;
                    threshold = _e113;
                    let _e115 = k_4;
                    let _e116 = threshold;
                    if (_e115 < _e116) {
                        {
                            let _e118 = k_4;
                            let _e119 = threshold;
                            k_4 = (_e118 / _e119);
                            let _e122 = k_4;
                            let _e125 = k_4;
                            r = (((0.5f - _e122) * (0.5f - _e125)) * 4f);
                            let _e132 = r;
                            let _e135 = r;
                            dp = ((1f - _e132) / (0.5f + _e135));
                            let _e139 = displacement;
                            let _e140 = dp;
                            let _e141 = d;
                            displacement = (_e139 + (_e140 * _e141));
                        }
                    }
                }
                continuing {
                    let _e72 = i_2;
                    i_2 = (_e72 + 1i);
                }
            }
        }
        continuing {
            let _e62 = j;
            j = (_e62 + 1i);
        }
    }
    let _e144 = pos_1;
    let _e145 = displacement;
    let _e146 = intensity_5;
    let _e148 = intensity_5;
    let _e154 = global.U[0];
    let _e157 = pos_1;
    let _e158 = displacement;
    let _e159 = intensity_5;
    let _e161 = intensity_5;
    let _e172 = _mirror_wrap(((vec2<f32>(((_e144 + ((_e145 * _e146) * _e148)).x / _e154.x), (_e157 + ((_e158 * _e159) * _e161)).y) / vec2(2f)) + vec2(0.5f)));
    let _e173 = textureSample(t_source, samp, _e172);
    return _e173;
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e95 = global.U[9];
    let _e99 = global.U[10];
    let _e103 = global.U[11];
    let _e107 = global.U[12];
    let _e109 = frostedGlass((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.x, _e99.x, _e103.x, _e107.x);
    fragColor = _e109;
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
