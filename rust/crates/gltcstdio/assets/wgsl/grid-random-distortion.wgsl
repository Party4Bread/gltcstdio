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

fn sstep(a: vec2<f32>, b: vec2<f32>, k_4: f32) -> vec2<f32> {
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

fn gridRandomDistortion(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, randomSeed: f32, dispersion: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var randomSeed_1: f32;
    var dispersion_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: vec2<f32>;
    var f: vec2<f32>;
    var r: vec2<f32>;
    var v_2: f32;
    var delta00_: vec2<f32>;
    var delta10_: vec2<f32>;
    var delta01_: vec2<f32>;
    var delta11_: vec2<f32>;
    var delta: vec2<f32>;
    var dcol: vec4<f32>;
    var outColor: vec4<f32>;
    var wStep: f32 = 0.05f;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var delta_1: vec2<f32>;
    var w_2: f32 = -1f;
    var dcol_1: vec4<f32>;
    var outColor_1: vec4<f32>;
    var weight: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    randomSeed_1 = randomSeed;
    dispersion_1 = dispersion;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = uv_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    t = _e21;
    let _e23 = t;
    f = floor(_e23);
    let _e26 = t;
    r = fract(_e26);
    let _e29 = intensity_1;
    v_2 = (_e29 * 4f);
    let _e33 = f;
    let _e34 = randomSeed_1;
    let _e35 = rand2relSeeded(_e33, _e34);
    let _e36 = v_2;
    delta00_ = (_e35 * _e36);
    let _e39 = f;
    let _e44 = randomSeed_1;
    let _e45 = rand2relSeeded((_e39 + vec2<f32>(1f, 0f)), _e44);
    let _e46 = v_2;
    delta10_ = (_e45 * _e46);
    let _e49 = f;
    let _e54 = randomSeed_1;
    let _e55 = rand2relSeeded((_e49 + vec2<f32>(0f, 1f)), _e54);
    let _e56 = v_2;
    delta01_ = (_e55 * _e56);
    let _e59 = f;
    let _e64 = randomSeed_1;
    let _e65 = rand2relSeeded((_e59 + vec2<f32>(1f, 1f)), _e64);
    let _e66 = v_2;
    delta11_ = (_e65 * _e66);
    let _e69 = dispersion_1;
    if (_e69 == 0f) {
        {
            let _e72 = delta00_;
            let _e73 = delta10_;
            let _e74 = r;
            let _e76 = sstep(_e72, _e73, _e74.x);
            let _e77 = delta01_;
            let _e78 = delta11_;
            let _e79 = r;
            let _e81 = sstep(_e77, _e78, _e79.x);
            let _e82 = r;
            let _e84 = sstep(_e76, _e81, _e82.y);
            delta = _e84;
            let _e86 = delta;
            let _e88 = delta;
            dcol = vec4<f32>(_e86.x, _e88.y, 0.5f, 1f);
            let _e94 = uv_1;
            let _e95 = delta;
            let _e100 = global.U[0];
            let _e103 = uv_1;
            let _e104 = delta;
            let _e114 = _mirror_wrap(((vec2<f32>(((_e94 + _e95).x / _e100.x), (_e103 + _e104).y) / vec2(2f)) + vec2(0.5f)));
            let _e115 = textureSample(t_source, samp, _e114);
            let _e116 = dcol;
            outColor = mix(_e115, _e116, vec4(0f));
            let _e121 = outColor;
            return _e121;
        }
    } else {
        {
            let _e136 = delta00_;
            let _e137 = delta10_;
            let _e138 = r;
            let _e140 = sstep(_e136, _e137, _e138.x);
            let _e141 = delta01_;
            let _e142 = delta11_;
            let _e143 = r;
            let _e145 = sstep(_e141, _e142, _e143.x);
            let _e146 = r;
            let _e148 = sstep(_e140, _e145, _e146.y);
            delta_1 = _e148;
            loop {
                let _e153 = w_2;
                if !((_e153 <= 1f)) {
                    break;
                }
                {
                    let _e160 = delta_1;
                    let _e162 = delta_1;
                    dcol_1 = vec4<f32>(_e160.x, _e162.y, 0.5f, 1f);
                    let _e168 = uv_1;
                    let _e170 = w_2;
                    let _e171 = dispersion_1;
                    let _e174 = delta_1;
                    let _e180 = global.U[0];
                    let _e183 = uv_1;
                    let _e185 = w_2;
                    let _e186 = dispersion_1;
                    let _e189 = delta_1;
                    let _e200 = _mirror_wrap(((vec2<f32>(((_e168 + ((1f + (_e170 * _e171)) * _e174)).x / _e180.x), (_e183 + ((1f + (_e185 * _e186)) * _e189)).y) / vec2(2f)) + vec2(0.5f)));
                    let _e201 = textureSample(t_source, samp, _e200);
                    let _e202 = dcol_1;
                    outColor_1 = mix(_e201, _e202, vec4(0f));
                    let _e207 = w_2;
                    let _e208 = getRGBWeights(_e207);
                    weight = _e208;
                    let _e210 = totalColor;
                    let _e211 = weight;
                    let _e212 = outColor_1;
                    totalColor = (_e210 + (_e211 * _e212));
                    let _e215 = totalWeight;
                    let _e216 = weight;
                    totalWeight = (_e215 + _e216);
                }
                continuing {
                    let _e157 = w_2;
                    let _e158 = wStep;
                    w_2 = (_e157 + _e158);
                }
            }
            let _e218 = totalColor;
            let _e219 = totalWeight;
            return (_e218 / _e219);
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
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = gridRandomDistortion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
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
