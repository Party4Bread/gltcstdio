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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn triangleToSquareWave(x_1: f32, k_4: f32) -> f32 {
    var x_2: f32;
    var k_5: f32;
    var s: f32 = 1f;
    var local: f32;
    var m_2: f32;

    x_2 = x_1;
    k_5 = k_4;
    let _e10 = x_2;
    x_2 = (_e10 - (floor((_e10 / 4f)) * 4f));
    let _e18 = x_2;
    if (_e18 > 2f) {
        {
            let _e21 = x_2;
            x_2 = (_e21 - 2f);
            s = -1f;
        }
    }
    let _e26 = k_5;
    if (_e26 > 0f) {
        local = 1f;
    } else {
        let _e32 = k_5;
        let _e35 = k_5;
        local = pow(mix(5f, 40f, -(_e32)), -(_e35));
    }
    let _e39 = local;
    m_2 = _e39;
    let _e41 = m_2;
    let _e42 = s;
    let _e45 = x_2;
    let _e50 = k_5;
    return ((_e41 * _e42) * (1f - pow(abs((_e45 - 1f)), pow(100f, _e50))));
}

fn flower(uv: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, intensity: f32, dampening: f32, shape: f32, variability: f32, randomSeed: f32, lighting: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var intensity_1: f32;
    var dampening_1: f32;
    var shape_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var lighting_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var N: f32;
    var u_2: vec2<f32>;
    var d: f32;
    var angle: f32;
    var k_6: f32;
    var variab: f32 = 1f;
    var w: f32;
    var index: f32;
    var dw: f32;
    var rnd: f32;
    var limit: f32;
    var threshold: f32;
    var threshold_1: f32;
    var scaling: f32;
    var coord: vec2<f32>;
    var outCol: vec4<f32>;
    var dilation: f32;
    var grad: vec2<f32>;
    var light: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    intensity_1 = intensity;
    dampening_1 = dampening;
    shape_1 = shape;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    lighting_1 = lighting;
    modelTransform_1 = modelTransform;
    let _e26 = spikeCount_1;
    N = f32(_e26);
    let _e29 = modelTransform_1;
    let _e31 = uv_1;
    let _e32 = tf(_naga_inverse_3x3_f32(_e29), _e31);
    u_2 = _e32;
    let _e34 = u_2;
    d = length(_e34);
    let _e37 = d;
    if (_e37 >= 1f) {
        {
            let _e40 = uv_1;
            let _e44 = global.U[0];
            let _e47 = uv_1;
            let _e56 = _mirror_wrap(((vec2<f32>((_e40.x / _e44.x), _e47.y) / vec2(2f)) + vec2(0.5f)));
            let _e57 = textureSample(t_source, samp, _e56);
            return _e57;
        }
    } else {
        {
            let _e58 = u_2;
            let _e60 = u_2;
            angle = atan2(_e58.y, _e60.x);
            let _e64 = intensity_1;
            k_6 = _e64;
            let _e68 = variability_1;
            if (_e68 != 0f) {
                {
                    let _e71 = angle;
                    let _e76 = N;
                    w = (((_e71 + 3.1415927f) / 6.2831855f) * _e76);
                    let _e79 = w;
                    index = ceil(_e79);
                    let _e82 = index;
                    let _e83 = w;
                    dw = (_e82 - _e83);
                    let _e86 = index;
                    let _e87 = index;
                    let _e89 = randomSeed_1;
                    let _e90 = rand2relSeeded(vec2<f32>(_e86, _e87), _e89);
                    rnd = (_e90.x + 0.5f);
                    let _e96 = variability_1;
                    let _e97 = rnd;
                    variab = (1f - (_e96 * _e97));
                }
            }
            let _e100 = d;
            let _e101 = variab;
            if (_e100 >= _e101) {
                {
                    let _e103 = uv_1;
                    let _e107 = global.U[0];
                    let _e110 = uv_1;
                    let _e119 = _mirror_wrap(((vec2<f32>((_e103.x / _e107.x), _e110.y) / vec2(2f)) + vec2(0.5f)));
                    let _e120 = textureSample(t_source, samp, _e119);
                    return _e120;
                }
            }
            let _e122 = variab;
            limit = (0.9f * _e122);
            let _e125 = dampening_1;
            if (_e125 >= 0f) {
                {
                    let _e128 = limit;
                    let _e130 = dampening_1;
                    threshold = (_e128 * (1f - _e130));
                    let _e134 = d;
                    let _e135 = threshold;
                    if (_e134 > _e135) {
                        {
                            let _e137 = k_6;
                            let _e139 = d;
                            let _e140 = threshold;
                            let _e142 = variab;
                            let _e143 = threshold;
                            k_6 = (_e137 * (1f - ((_e139 - _e140) / (_e142 - _e143))));
                        }
                    }
                }
            } else {
                {
                    let _e148 = d;
                    let _e149 = limit;
                    if (_e148 > _e149) {
                        {
                            let _e151 = k_6;
                            let _e153 = d;
                            let _e154 = limit;
                            let _e156 = variab;
                            let _e157 = limit;
                            k_6 = (_e151 * (1f - ((_e153 - _e154) / (_e156 - _e157))));
                        }
                    }
                    let _e162 = limit;
                    let _e163 = dampening_1;
                    threshold_1 = (_e162 * -(_e163));
                    let _e167 = d;
                    let _e168 = threshold_1;
                    if (_e167 < _e168) {
                        {
                            let _e170 = k_6;
                            let _e174 = threshold_1;
                            let _e175 = d;
                            let _e177 = threshold_1;
                            k_6 = (_e170 * max(0f, (1f - (2f * ((_e174 - _e175) / _e177)))));
                        }
                    }
                }
            }
            let _e184 = k_6;
            let _e186 = angle;
            let _e193 = N;
            let _e197 = shape_1;
            let _e198 = triangleToSquareWave((((((_e186 + 3.1415927f) / 6.2831855f) * 4f) * _e193) - 1f), _e197);
            scaling = (1f + (_e184 * (1f + _e198)));
            let _e203 = modelTransform_1;
            let _e204 = scaling;
            let _e205 = u_2;
            let _e207 = tf(_e203, (_e204 * _e205));
            coord = _e207;
            let _e209 = coord;
            let _e213 = global.U[0];
            let _e216 = coord;
            let _e225 = _mirror_wrap(((vec2<f32>((_e209.x / _e213.x), _e216.y) / vec2(2f)) + vec2(0.5f)));
            let _e226 = textureSample(t_source, samp, _e225);
            outCol = _e226;
            let _e228 = coord;
            let _e229 = u_2;
            dilation = length((_e228 - _e229));
            let _e233 = dilation;
            let _e234 = dpdx(_e233);
            let _e235 = u_2;
            let _e237 = dpdx(_e235.x);
            let _e239 = dilation;
            let _e240 = dpdy(_e239);
            let _e241 = u_2;
            let _e243 = dpdy(_e241.y);
            grad = (vec2<f32>((_e234 / _e237), (_e240 / _e243)) * 4f);
            let _e249 = lighting_1;
            if (_e249 > 0f) {
                {
                    let _e253 = lighting_1;
                    let _e254 = grad;
                    light = (1f + (_e253 * dot(_e254, vec2<f32>(0f, -1f))));
                    let _e263 = outCol;
                    let _e265 = outCol;
                    let _e267 = light;
                    let _e268 = (_e265.xyz * _e267);
                    outCol.x = _e268.x;
                    outCol.y = _e268.y;
                    outCol.z = _e268.z;
                }
            }
            let _e275 = outCol;
            return _e275;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e118 = flower((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87.x, _e91.x, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)));
    fragColor = _e118;
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
