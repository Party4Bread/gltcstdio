struct Params {
    U: array<vec4<f32>, 11>,
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

fn getRGBWeights(w: f32) -> vec4<f32> {
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

fn smoothmix2_(a: vec2<f32>, b: vec2<f32>, k_4: f32) -> vec2<f32> {
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var k_5: f32;

    a_1 = a;
    b_1 = b;
    k_5 = k_4;
    let _e12 = a_1;
    let _e14 = b_1;
    let _e18 = k_5;
    let _e21 = a_1;
    let _e23 = b_1;
    let _e27 = k_5;
    return vec2<f32>(mix(_e12.x, _e14.x, smoothstep(0f, 1f, _e18)), mix(_e21.y, _e23.y, smoothstep(0f, 1f, _e27)));
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

fn randomColorDispersion(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: vec2<f32>;
    var f: vec2<f32>;
    var r: vec2<f32>;
    var v_2: f32 = 2f;
    var delta00_: vec2<f32>;
    var delta10_: vec2<f32>;
    var delta01_: vec2<f32>;
    var delta11_: vec2<f32>;
    var stepLen: f32;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var dispersion: f32;
    var delta: vec2<f32>;
    var range: vec2<f32>;
    var N: f32;
    var wStep: f32;
    var col: vec4<f32>;
    var i: f32;
    var w_2: f32;
    var scol: vec4<f32>;
    var outColor: vec4<f32>;
    var weight: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = pos_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    t = _e21;
    let _e23 = t;
    f = floor(_e23);
    let _e26 = t;
    r = fract(_e26);
    let _e31 = f;
    let _e32 = randomSeed_1;
    let _e33 = rand2relSeeded(_e31, _e32);
    let _e34 = v_2;
    delta00_ = (_e33 * _e34);
    let _e37 = f;
    let _e42 = randomSeed_1;
    let _e43 = rand2relSeeded((_e37 + vec2<f32>(1f, 0f)), _e42);
    let _e44 = v_2;
    delta10_ = (_e43 * _e44);
    let _e47 = f;
    let _e52 = randomSeed_1;
    let _e53 = rand2relSeeded((_e47 + vec2<f32>(0f, 1f)), _e52);
    let _e54 = v_2;
    delta01_ = (_e53 * _e54);
    let _e57 = f;
    let _e62 = randomSeed_1;
    let _e63 = rand2relSeeded((_e57 + vec2<f32>(1f, 1f)), _e62);
    let _e64 = v_2;
    delta11_ = (_e63 * _e64);
    let _e68 = sourceDim_1;
    stepLen = (2f / _e68.y);
    let _e84 = intensity_1;
    dispersion = _e84;
    let _e86 = delta00_;
    let _e87 = delta10_;
    let _e88 = r;
    let _e90 = smoothmix2_(_e86, _e87, _e88.x);
    let _e91 = delta01_;
    let _e92 = delta11_;
    let _e93 = r;
    let _e95 = smoothmix2_(_e91, _e92, _e93.x);
    let _e96 = r;
    let _e98 = smoothmix2_(_e90, _e95, _e96.y);
    delta = _e98;
    let _e100 = dispersion;
    let _e101 = delta;
    range = (_e100 * _e101);
    let _e105 = range;
    let _e107 = stepLen;
    N = ceil((0.1f + (length(_e105) / _e107)));
    let _e113 = N;
    wStep = (1f / _e113);
    let _e117 = N;
    i = -(_e117);
    loop {
        let _e120 = i;
        let _e121 = N;
        if !((_e120 <= _e121)) {
            break;
        }
        {
            let _e127 = i;
            let _e128 = wStep;
            w_2 = (_e127 * _e128);
            let _e131 = pos_1;
            let _e132 = w_2;
            let _e133 = range;
            let _e139 = global.U[0];
            let _e142 = pos_1;
            let _e143 = w_2;
            let _e144 = range;
            let _e155 = _mirror_wrap(((vec2<f32>(((_e131 + (_e132 * _e133)).x / _e139.x), (_e142 + (_e143 * _e144)).y) / vec2(2f)) + vec2(0.5f)));
            let _e157 = textureSampleLevel(t_source, samp, _e155, 0f);
            scol = _e157;
            let _e159 = i;
            if (_e159 == 0f) {
                let _e162 = scol;
                col = _e162;
            }
            let _e163 = scol;
            outColor = _e163;
            let _e165 = w_2;
            let _e166 = getRGBWeights(_e165);
            weight = _e166;
            let _e168 = totalColor;
            let _e169 = weight;
            let _e170 = outColor;
            totalColor = (_e168 + (_e169 * _e170));
            let _e173 = totalWeight;
            let _e174 = weight;
            totalWeight = (_e173 + _e174);
        }
        continuing {
            let _e124 = i;
            i = (_e124 + 1f);
        }
    }
    let _e176 = totalColor;
    let _e177 = totalWeight;
    outCol = (_e176 / _e177);
    let _e180 = outCol;
    return _e180;
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = randomColorDispersion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
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
