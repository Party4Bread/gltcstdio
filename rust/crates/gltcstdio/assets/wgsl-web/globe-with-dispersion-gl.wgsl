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

fn gwdGetRGBWeights(w: f32) -> vec4<f32> {
    var w_1: f32;

    w_1 = w;
    let _e9 = w_1;
    let _e14 = w_1;
    let _e19 = w_1;
    return vec4<f32>(max(0f, -(_e9)), max(0f, (1f - abs(_e14))), max(0f, _e19), 1f);
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

fn globeWithDispersionGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, dispersion: f32, perturbation: f32, randomSeed: f32, power: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dispersion_1: f32;
    var perturbation_1: f32;
    var randomSeed_1: f32;
    var power_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u: vec2<f32>;
    var p: f32;
    var d: f32;
    var hh: f32;
    var h: f32;
    var s: f32;
    var dilation: f32;
    var coord: vec2<f32>;
    var wStep: f32 = 0.05f;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var w_2: f32 = -1f;
    var s_1: f32;
    var dilation_1: f32;
    var coord_1: vec2<f32>;
    var weight: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dispersion_1 = dispersion;
    perturbation_1 = perturbation;
    randomSeed_1 = randomSeed;
    power_1 = power;
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e22);
    let _e25 = invM;
    let _e26 = pos_1;
    u = (_e25 * vec3<f32>(_e26.x, _e26.y, 1f)).xy;
    let _e34 = perturbation_1;
    if (_e34 > 0f) {
        {
            let _e37 = u;
            let _e38 = u;
            let _e40 = perturbation_1;
            let _e43 = randomSeed_1;
            let _e44 = sineSurfaceRand2Seeded((_e38 * (1f + _e40)), _e43);
            let _e45 = perturbation_1;
            u = (_e37 + (_e44 * _e45));
        }
    }
    let _e48 = power_1;
    p = _e48;
    let _e50 = u;
    let _e53 = p;
    let _e55 = u;
    let _e58 = p;
    let _e62 = p;
    d = pow((pow(abs(_e50.x), _e53) + pow(abs(_e55.y), _e58)), (1f / _e62));
    let _e66 = d;
    let _e69 = d;
    if ((_e66 == 0f) || (_e69 >= 1f)) {
        {
            let _e73 = pos_1;
            let _e77 = global.U[0];
            let _e80 = pos_1;
            let _e89 = _mirror_wrap(((vec2<f32>((_e73.x / _e77.x), _e80.y) / vec2(2f)) + vec2(0.5f)));
            let _e91 = textureSampleLevel(t_source, samp, _e89, 0f);
            return _e91;
        }
    } else {
        {
            let _e93 = d;
            let _e94 = d;
            hh = sqrt((1f - (_e93 * _e94)));
            let _e99 = hh;
            if (_e99 == 0f) {
                {
                    let _e102 = pos_1;
                    let _e106 = global.U[0];
                    let _e109 = pos_1;
                    let _e118 = _mirror_wrap(((vec2<f32>((_e102.x / _e106.x), _e109.y) / vec2(2f)) + vec2(0.5f)));
                    let _e120 = textureSampleLevel(t_source, samp, _e118, 0f);
                    return _e120;
                }
            }
            let _e122 = hh;
            h = (1f + _e122);
            let _e125 = dispersion_1;
            if (_e125 == 0f) {
                {
                    let _e128 = d;
                    let _e130 = intensity_1;
                    let _e132 = hh;
                    s = ((-(_e128) * _e130) / _e132);
                    let _e136 = h;
                    let _e137 = s;
                    let _e139 = d;
                    dilation = (1f + ((_e136 * _e137) / _e139));
                    let _e143 = modelTransform_1;
                    let _e144 = dilation;
                    let _e145 = u;
                    let _e146 = (_e144 * _e145);
                    coord = (_e143 * vec3<f32>(_e146.x, _e146.y, 1f)).xy;
                    let _e154 = coord;
                    let _e158 = global.U[0];
                    let _e161 = coord;
                    let _e170 = _mirror_wrap(((vec2<f32>((_e154.x / _e158.x), _e161.y) / vec2(2f)) + vec2(0.5f)));
                    let _e172 = textureSampleLevel(t_source, samp, _e170, 0f);
                    return _e172;
                }
            } else {
                {
                    loop {
                        let _e190 = w_2;
                        if !((_e190 <= 1f)) {
                            break;
                        }
                        {
                            let _e197 = d;
                            let _e199 = intensity_1;
                            let _e201 = w_2;
                            let _e202 = dispersion_1;
                            let _e207 = hh;
                            s_1 = ((-(_e197) * (_e199 * (1f + (_e201 * _e202)))) / _e207);
                            let _e211 = h;
                            let _e212 = s_1;
                            let _e214 = d;
                            dilation_1 = (1f + ((_e211 * _e212) / _e214));
                            let _e218 = modelTransform_1;
                            let _e219 = dilation_1;
                            let _e220 = u;
                            let _e221 = (_e219 * _e220);
                            coord_1 = (_e218 * vec3<f32>(_e221.x, _e221.y, 1f)).xy;
                            let _e229 = w_2;
                            let _e230 = gwdGetRGBWeights(_e229);
                            weight = _e230;
                            let _e232 = totalColor;
                            let _e233 = weight;
                            let _e234 = coord_1;
                            let _e238 = global.U[0];
                            let _e241 = coord_1;
                            let _e250 = _mirror_wrap(((vec2<f32>((_e234.x / _e238.x), _e241.y) / vec2(2f)) + vec2(0.5f)));
                            let _e252 = textureSampleLevel(t_source, samp, _e250, 0f);
                            totalColor = (_e232 + (_e233 * _e252));
                            let _e255 = totalWeight;
                            let _e256 = weight;
                            totalWeight = (_e255 + _e256);
                        }
                        continuing {
                            let _e194 = w_2;
                            let _e195 = wStep;
                            w_2 = (_e194 + _e195);
                        }
                    }
                    let _e258 = totalColor;
                    let _e259 = totalWeight;
                    return (_e258 / _e259);
                }
            }
        }
    }
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
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e109 = globeWithDispersionGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, mat3x3<f32>(vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z)));
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
