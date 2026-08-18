struct Params {
    U: array<vec4<f32>, 18>,
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

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
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

fn plasma(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, intensity: f32, balance: f32, hardness: f32, dampening: f32, color1_: vec4<f32>, color2_: vec4<f32>, colorVariability: f32, randomSeed: f32, variability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var hardness_1: f32;
    var dampening_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var colorVariability_1: f32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var u2_: vec2<f32>;
    var p: vec2<f32>;
    var p2_: vec2<f32>;
    var N: f32 = 4f;
    var t: f32 = 0f;
    var tk2_: f32 = 0f;
    var tc: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var j: f32;
    var i: f32;
    var q: vec2<f32>;
    var q2_: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var col: vec3<f32>;
    var c: vec2<f32>;
    var c2_: vec2<f32>;
    var d: vec2<f32>;
    var d2_: vec2<f32>;
    var k2_: f32;
    var k_4: f32;
    var a: f32;
    var b: f32;
    var k_5: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    intensity_1 = intensity;
    balance_1 = balance;
    hardness_1 = hardness;
    dampening_1 = dampening;
    color1_1 = color1_;
    color2_1 = color2_;
    colorVariability_1 = colorVariability;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    let _e32 = uv_1;
    u = _e32;
    let _e34 = u;
    u2_ = (_e34 * 0.3f);
    let _e38 = u;
    p = floor((_e38 + vec2(0.5f)));
    let _e44 = u2_;
    p2_ = floor((_e44 + vec2(0.5f)));
    let _e61 = N;
    j = -(_e61);
    loop {
        let _e64 = j;
        let _e65 = N;
        if !((_e64 <= _e65)) {
            break;
        }
        {
            let _e71 = N;
            i = -(_e71);
            loop {
                let _e74 = i;
                let _e75 = N;
                if !((_e74 <= _e75)) {
                    break;
                }
                {
                    let _e81 = p;
                    let _e82 = i;
                    let _e83 = j;
                    q = (_e81 + vec2<f32>(_e82, _e83));
                    let _e87 = p2_;
                    let _e88 = i;
                    let _e89 = j;
                    q2_ = (_e87 + vec2<f32>(_e88, _e89));
                    let _e93 = q;
                    let _e94 = randomSeed_1;
                    let _e95 = rand2relSeeded(_e93, _e94);
                    rnd = _e95;
                    let _e97 = q2_;
                    let _e98 = randomSeed_1;
                    let _e99 = rand2relSeeded(_e97, _e98);
                    rnd2_ = _e99;
                    let _e101 = color2_1;
                    let _e103 = rnd2_;
                    let _e105 = rnd2_;
                    let _e107 = rnd2_;
                    let _e109 = rnd2_;
                    let _e118 = colorVariability_1;
                    col = (_e101.xyz + ((vec3<f32>(_e103.x, _e105.y, (fract(((_e107.x + _e109.y) * 50f)) - 0.5f)) * _e118) * 2f));
                    let _e124 = q;
                    let _e125 = rnd;
                    let _e126 = variability_1;
                    c = (_e124 + ((_e125 * _e126) * 2f));
                    let _e132 = q2_;
                    let _e133 = rnd2_;
                    c2_ = (_e132 + (_e133 * 2f));
                    let _e138 = u;
                    let _e139 = c;
                    d = (_e138 - _e139);
                    let _e142 = u2_;
                    let _e143 = c2_;
                    d2_ = (_e142 - _e143);
                    let _e148 = d2_;
                    let _e149 = d2_;
                    k2_ = (1f / (0.001f + dot(_e148, _e149)));
                    let _e155 = dampening_1;
                    let _e158 = d;
                    k_4 = (1f / (_e155 + smoothstep(0f, 3f, length(_e158))));
                    let _e164 = t;
                    let _e165 = k_4;
                    t = (_e164 + _e165);
                    let _e167 = tk2_;
                    let _e168 = k2_;
                    tk2_ = (_e167 + _e168);
                    let _e170 = tc;
                    let _e171 = col;
                    let _e172 = k2_;
                    tc = (_e170 + (_e171 * _e172));
                }
                continuing {
                    let _e78 = i;
                    i = (_e78 + 1f);
                }
            }
        }
        continuing {
            let _e68 = j;
            j = (_e68 + 1f);
        }
    }
    let _e177 = balance_1;
    let _e178 = hardness_1;
    a = mix(-2f, _e177, _e178);
    let _e182 = balance_1;
    let _e183 = hardness_1;
    b = mix(2f, _e182, _e183);
    let _e186 = a;
    let _e187 = b;
    let _e188 = t;
    let _e189 = intensity_1;
    k_5 = smoothstep(_e186, _e187, sin(((_e188 * _e189) * 2f)));
    let _e196 = tc;
    let _e197 = tk2_;
    tc = (_e196 / vec3(_e197));
    let _e200 = color1_1;
    let _e201 = tc;
    let _e202 = color2_1;
    let _e208 = k_5;
    outColor = mix(_e200, vec4<f32>(_e201.x, _e201.y, _e201.z, _e202.w), vec4(_e208));
    let _e212 = source_specified_1;
    if (_e212 == 1i) {
        let _e215 = outPos_1;
        let _e219 = global.U[0];
        let _e222 = outPos_1;
        let _e231 = textureSample(t_source, samp, ((vec2<f32>((_e215.x / _e219.x), _e222.y) / vec2(2f)) + vec2(0.5f)));
        let _e232 = outColor;
        let _e233 = mergeColor(_e231, _e232);
        return _e233;
    } else {
        let _e234 = outColor;
        return _e234;
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
    let _e66 = global.U[4];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e97 = global.U[13];
    let _e101 = global.U[14];
    let _e105 = global.U[15];
    let _e106 = _e105.xyz;
    let _e109 = global.U[16];
    let _e110 = _e109.xyz;
    let _e113 = global.U[17];
    let _e114 = _e113.xyz;
    let _e128 = plasma((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87, _e90, _e93.x, _e97.x, _e101.x, mat3x3<f32>(vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z), vec3<f32>(_e114.x, _e114.y, _e114.z)));
    fragColor = _e128;
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
