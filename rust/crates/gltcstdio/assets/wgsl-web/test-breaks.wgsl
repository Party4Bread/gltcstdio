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

fn testBreaks(uv: vec2<f32>, outPos: vec2<f32>, dampening: f32, perturbation: f32, distortion: f32, variability: f32, randomSeed: f32, modelTransform: mat3x3<f32>, displaceTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var dampening_1: f32;
    var perturbation_1: f32;
    var distortion_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var displaceTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var t: vec2<f32>;
    var dist: f32;
    var maxDist: f32;
    var len: f32;
    var index: f32;
    var var_: f32;
    var dd: f32;
    var dx: f32;
    var local: f32;
    var inside: f32;
    var local_1: f32;
    var local_2: f32;
    var local_3: vec2<f32>;
    var delta: vec2<f32>;
    var newPos: vec2<f32>;
    var grad: vec2<f32>;
    var r: f32;
    var dp: f32;
    var r_1: f32;
    var dp_1: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    dampening_1 = dampening;
    perturbation_1 = perturbation;
    distortion_1 = distortion;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    displaceTransform_1 = displaceTransform;
    let _e24 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e24);
    let _e27 = uv_1;
    u_2 = _e27;
    let _e29 = inverseModelTransform;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    t = _e31;
    let _e33 = perturbation_1;
    if (_e33 > 0f) {
        {
            let _e36 = t;
            let _e37 = t;
            let _e39 = perturbation_1;
            let _e44 = randomSeed_1;
            let _e45 = sineSurfaceRand2Seeded((_e37 * (1f + (_e39 * 1f))), _e44);
            let _e48 = perturbation_1;
            t = (_e36 + ((_e45 * 2.5f) * _e48));
        }
    }
    {
        let _e53 = t;
        len = length(_e53);
        let _e56 = len;
        index = floor((_e56 / 2f));
        let _e61 = variability_1;
        let _e62 = index;
        let _e63 = index;
        let _e65 = randomSeed_1;
        let _e66 = rand2relSeeded(vec2<f32>(_e62, _e63), _e65);
        var_ = ((_e61 * _e66.x) * 2f);
        let _e73 = var_;
        dd = (1f + _e73);
        let _e76 = len;
        dx = (_e76 - (floor((_e76 / 2f)) * 2f));
        let _e83 = len;
        let _e90 = var_;
        if ((_e83 - (floor((_e83 / 2f)) * 2f)) < (1f + _e90)) {
            local = 1f;
        } else {
            local = 0f;
        }
        let _e96 = local;
        inside = _e96;
        let _e98 = dx;
        let _e99 = dd;
        if (_e98 <= _e99) {
            let _e101 = dx;
            let _e102 = dd;
            let _e104 = dx;
            local_1 = max((_e101 - _e102), -(_e104));
        } else {
            let _e107 = dx;
            let _e108 = dd;
            let _e111 = dx;
            local_1 = min((_e107 - _e108), (2f - _e111));
        }
        let _e115 = local_1;
        dist = _e115;
        let _e116 = dx;
        let _e117 = dd;
        if (_e116 <= _e117) {
            let _e119 = dd;
            local_2 = (_e119 * 0.5f);
        } else {
            let _e123 = dd;
            local_2 = (1f - (_e123 * 0.5f));
        }
        let _e128 = local_2;
        maxDist = _e128;
    }
    let _e129 = dist;
    if (_e129 < 0f) {
        let _e132 = displaceTransform_1;
        let _e134 = uv_1;
        let _e135 = tf(_naga_inverse_3x3_f32(_e132), _e134);
        let _e136 = uv_1;
        local_3 = (_e135 - _e136);
    } else {
        local_3 = vec2(0f);
    }
    let _e141 = local_3;
    delta = _e141;
    let _e143 = uv_1;
    let _e144 = delta;
    let _e146 = dampening_1;
    newPos = (_e143 + (_e144 * (1f - _e146)));
    let _e151 = dist;
    let _e152 = dpdx(_e151);
    let _e153 = uv_1;
    let _e155 = dpdx(_e153.x);
    let _e157 = dist;
    let _e158 = dpdy(_e157);
    let _e159 = uv_1;
    let _e161 = dpdy(_e159.y);
    grad = normalize(vec2<f32>((_e152 / _e155), (_e158 / _e161)));
    let _e166 = distortion_1;
    let _e169 = dist;
    if ((_e166 > 0f) && (_e169 < 0f)) {
        {
            let _e173 = dist;
            let _e175 = maxDist;
            r = (-(_e173) / _e175);
            let _e178 = distortion_1;
            let _e182 = r;
            let _e186 = r;
            dp = (((_e178 * 2f) * (1f - _e182)) / (0.5f + _e186));
            let _e190 = newPos;
            let _e191 = dp;
            let _e192 = grad;
            newPos = (_e190 + (_e191 * _e192));
        }
    } else {
        let _e195 = distortion_1;
        let _e198 = dist;
        if ((_e195 < 0f) && (_e198 > 0f)) {
            {
                let _e202 = dist;
                let _e203 = maxDist;
                r_1 = (_e202 / _e203);
                let _e206 = distortion_1;
                let _e211 = r_1;
                let _e215 = r_1;
                dp_1 = (((-(_e206) * 2f) * (1f - _e211)) / (0.5f + _e215));
                let _e219 = newPos;
                let _e220 = dp_1;
                let _e221 = grad;
                newPos = (_e219 + (_e220 * _e221));
            }
        }
    }
    let _e224 = newPos;
    let _e228 = global.U[0];
    let _e231 = newPos;
    let _e240 = _mirror_wrap(((vec2<f32>((_e224.x / _e228.x), _e231.y) / vec2(2f)) + vec2(0.5f)));
    let _e241 = textureSample(t_source, samp, _e240);
    outColor = _e241;
    let _e243 = outColor;
    return _e243;
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
    let _e111 = global.U[13];
    let _e112 = _e111.xyz;
    let _e115 = global.U[14];
    let _e116 = _e115.xyz;
    let _e119 = global.U[15];
    let _e120 = _e119.xyz;
    let _e134 = testBreaks((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, mat3x3<f32>(vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z)), mat3x3<f32>(vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e116.x, _e116.y, _e116.z), vec3<f32>(_e120.x, _e120.y, _e120.z)));
    fragColor = _e134;
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
