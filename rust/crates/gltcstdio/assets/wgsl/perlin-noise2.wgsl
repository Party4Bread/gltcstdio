struct Params {
    U: array<vec4<f32>, 14>,
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

fn aRatio(a: f32) -> vec2<f32> {
    var a_1: f32;

    a_1 = a;
    let _e7 = a_1;
    let _e11 = a_1;
    return ((vec2<f32>(_e7, 1f) / vec2((1f + _e11))) * 2f);
}

fn rndUnit3_(p: vec3<f32>) -> vec3<f32> {
    var p_1: vec3<f32>;
    var u: vec3<f32>;
    var h: vec3<f32>;

    p_1 = p;
    let _e7 = p_1;
    u = fract((_e7 * vec3<f32>(0.1031f, 0.103f, 0.0973f)));
    let _e15 = u;
    let _e16 = u;
    let _e17 = u;
    u = (_e15 + vec3(dot(_e16, (_e17.yxz + vec3(33.33f)))));
    let _e25 = u;
    let _e27 = u;
    let _e30 = u;
    h = fract(((_e25.xxy + _e27.yxx) * _e30.zyx));
    let _e35 = h;
    return normalize((_e35 - vec3(0.5f)));
}

fn dotGridGradient3_(g: vec3<f32>, u_1: vec3<f32>) -> f32 {
    var g_1: vec3<f32>;
    var u_2: vec3<f32>;

    g_1 = g;
    u_2 = u_1;
    let _e9 = u_2;
    let _e10 = g_1;
    let _e12 = g_1;
    let _e13 = rndUnit3_(_e12);
    return dot((_e9 - _e10), _e13);
}

fn smix(a_2: f32, b: f32, k: f32) -> f32 {
    var a_3: f32;
    var b_1: f32;
    var k_1: f32;

    a_3 = a_2;
    b_1 = b;
    k_1 = k;
    let _e11 = a_3;
    let _e12 = b_1;
    let _e15 = k_1;
    return mix(_e11, _e12, smoothstep(0f, 1f, _e15));
}

fn perlinRelNoise3_(p_2: vec3<f32>) -> f32 {
    var p_3: vec3<f32>;
    var s: vec3<f32> = vec3<f32>(1f, 0f, 0f);
    var f: vec3<f32>;
    var d: vec3<f32>;
    var ix00_: f32;
    var ix10_: f32;
    var ix01_: f32;
    var ix11_: f32;
    var iy0_: f32;
    var iy1_: f32;

    p_3 = p_2;
    let _e12 = p_3;
    f = floor(_e12);
    let _e15 = p_3;
    let _e16 = f;
    d = (_e15 - _e16);
    let _e19 = f;
    let _e20 = p_3;
    let _e21 = dotGridGradient3_(_e19, _e20);
    let _e22 = f;
    let _e23 = s;
    let _e25 = p_3;
    let _e26 = dotGridGradient3_((_e22 + _e23), _e25);
    let _e27 = d;
    let _e29 = smix(_e21, _e26, _e27.x);
    ix00_ = _e29;
    let _e31 = f;
    let _e32 = s;
    let _e35 = p_3;
    let _e36 = dotGridGradient3_((_e31 + _e32.yxz), _e35);
    let _e37 = f;
    let _e38 = s;
    let _e41 = p_3;
    let _e42 = dotGridGradient3_((_e37 + _e38.xxz), _e41);
    let _e43 = d;
    let _e45 = smix(_e36, _e42, _e43.x);
    ix10_ = _e45;
    let _e47 = f;
    let _e48 = s;
    let _e51 = p_3;
    let _e52 = dotGridGradient3_((_e47 + _e48.yyx), _e51);
    let _e53 = f;
    let _e54 = s;
    let _e57 = p_3;
    let _e58 = dotGridGradient3_((_e53 + _e54.xyx), _e57);
    let _e59 = d;
    let _e61 = smix(_e52, _e58, _e59.x);
    ix01_ = _e61;
    let _e63 = f;
    let _e64 = s;
    let _e67 = p_3;
    let _e68 = dotGridGradient3_((_e63 + _e64.yxx), _e67);
    let _e69 = f;
    let _e70 = s;
    let _e73 = p_3;
    let _e74 = dotGridGradient3_((_e69 + _e70.xxx), _e73);
    let _e75 = d;
    let _e77 = smix(_e68, _e74, _e75.x);
    ix11_ = _e77;
    let _e79 = ix00_;
    let _e80 = ix10_;
    let _e81 = d;
    let _e83 = smix(_e79, _e80, _e81.y);
    iy0_ = _e83;
    let _e85 = ix01_;
    let _e86 = ix11_;
    let _e87 = d;
    let _e89 = smix(_e85, _e86, _e87.y);
    iy1_ = _e89;
    let _e91 = iy0_;
    let _e92 = iy1_;
    let _e93 = d;
    let _e95 = smix(_e91, _e92, _e93.z);
    return _e95;
}

fn perlinNoise3_(p_4: vec3<f32>) -> f32 {
    var p_5: vec3<f32>;

    p_5 = p_4;
    let _e8 = p_5;
    let _e9 = perlinRelNoise3_(_e8);
    return (0.5f + (_e9 * 0.5f));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x;
    let _e32 = y;
    return vec2<f32>(_e31, _e32);
}

fn varyNoiseSmoothly(noise: f32, k_2: f32) -> f32 {
    var noise_1: f32;
    var k_3: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_3 = k_2;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_3;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_4: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_5: f32;

    noise_3 = noise_2;
    k_5 = k_4;
    let _e9 = noise_3;
    let _e11 = k_5;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_5;
    let _e16 = varyNoiseSmoothly(_e13.y, _e15);
    return vec2<f32>(_e12, _e16);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rand2_(_e9);
    let _e11 = seed_1;
    let _e12 = varyVec2NoiseSmoothly(_e10, _e11);
    return (_e12 - vec2(0.5f));
}

fn perlinNoise2_(pos: vec2<f32>, outPos: vec2<f32>, viewTransform: mat3x3<f32>, octaves: i32, color1_: vec4<f32>, color2_: vec4<f32>, hardness: f32, balance: f32, shapeAspectRatio: f32, variability: f32, randomSeed: f32, styleSeed: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var viewTransform_1: mat3x3<f32>;
    var octaves_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var hardness_1: f32;
    var balance_1: f32;
    var shapeAspectRatio_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var styleSeed_1: f32;
    var uv: vec2<f32>;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_6: f32 = 1f;
    var x_1: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;
    var r: vec2<f32>;
    var angle: f32;
    var ar: f32;
    var rot: mat2x2<f32>;
    var stretch: mat2x2<f32>;
    var suv: vec2<f32>;
    var scaleVar: f32;
    var local: f32;
    var w: f32;
    var e: f32;
    var local_1: f32;
    var a_4: f32;
    var local_2: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    viewTransform_1 = viewTransform;
    octaves_1 = octaves;
    color1_1 = color1_;
    color2_1 = color2_;
    hardness_1 = hardness;
    balance_1 = balance;
    shapeAspectRatio_1 = shapeAspectRatio;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    styleSeed_1 = styleSeed;
    let _e29 = pos_1;
    let _e30 = shapeAspectRatio_1;
    let _e31 = aRatio(_e30);
    uv = (_e29 / _e31);
    loop {
        let _e68 = i;
        let _e69 = octaves_1;
        if !((_e68 < _e69)) {
            break;
        }
        {
            let _e75 = i;
            let _e80 = styleSeed_1;
            let _e83 = rand2relSeeded(vec2((f32(_e75) + 17.3f)), (_e80 * 0.1f));
            r = _e83;
            let _e85 = r;
            let _e89 = variability_1;
            angle = ((_e85.x * 6.2831855f) * _e89);
            let _e93 = r;
            let _e97 = variability_1;
            ar = pow(20f, ((_e93.y * 2f) * _e97));
            let _e101 = angle;
            let _e103 = angle;
            let _e105 = angle;
            let _e108 = angle;
            rot = mat2x2<f32>(vec2<f32>(cos(_e101), sin(_e103)), vec2<f32>(-(sin(_e105)), cos(_e108)));
            let _e114 = ar;
            let _e118 = ar;
            stretch = mat2x2<f32>(vec2<f32>(_e114, 0f), vec2<f32>(0f, (1f / _e118)));
            let _e124 = stretch;
            let _e125 = rot;
            let _e127 = uv;
            suv = ((_e124 * _e125) * _e127);
            let _e130 = x_1;
            let _e131 = k_6;
            let _e132 = suv;
            let _e133 = randomSeed_1;
            let _e137 = perlinNoise3_(vec3<f32>(_e132.x, _e132.y, _e133));
            x_1 = (_e130 + (_e131 * _e137));
            let _e140 = total;
            let _e141 = k_6;
            total = (_e140 + _e141);
            let _e143 = variability_1;
            let _e144 = r;
            scaleVar = ((_e143 * (fract((_e144.x * 3.4f)) - 0.5f)) * 2f);
            let _e155 = k_6;
            let _e158 = scaleVar;
            k_6 = (_e155 * (0.5f * pow(2f, _e158)));
            let _e162 = transform;
            let _e163 = uv;
            uv = (_e162 * _e163);
        }
        continuing {
            let _e72 = i;
            i = (_e72 + 1i);
        }
    }
    let _e165 = x_1;
    let _e166 = total;
    x_1 = (_e165 / _e166);
    let _e168 = balance_1;
    if (_e168 >= 0f) {
        let _e171 = x_1;
        let _e173 = balance_1;
        local = mix(_e171, 1f, _e173);
    } else {
        let _e175 = x_1;
        let _e177 = balance_1;
        local = mix(_e175, 0f, -(_e177));
    }
    let _e181 = local;
    x_1 = _e181;
    let _e183 = hardness_1;
    w = (1f - _e183);
    let _e186 = w;
    if (_e186 <= 0f) {
        {
            let _e190 = x_1;
            x_1 = step(0.5f, _e190);
        }
    } else {
        {
            let _e193 = w;
            e = (1f / _e193);
            let _e198 = x_1;
            if (_e198 < 0.5f) {
                let _e201 = x_1;
                local_1 = _e201;
            } else {
                let _e203 = x_1;
                local_1 = (1f - _e203);
            }
            let _e206 = local_1;
            let _e208 = e;
            a_4 = (0.5f * pow((2f * _e206), _e208));
            let _e212 = x_1;
            if (_e212 < 0.5f) {
                let _e215 = a_4;
                local_2 = _e215;
            } else {
                let _e217 = a_4;
                local_2 = (1f - _e217);
            }
            let _e220 = local_2;
            x_1 = _e220;
        }
    }
    let _e221 = color1_1;
    let _e222 = color2_1;
    let _e223 = x_1;
    return mix(_e221, _e222, vec4(_e223));
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[1];
    let _e66 = _e65.xyz;
    let _e69 = global.U[2];
    let _e70 = _e69.xyz;
    let _e73 = global.U[3];
    let _e74 = _e73.xyz;
    let _e90 = global.U[5];
    let _e95 = global.U[6];
    let _e98 = global.U[7];
    let _e101 = global.U[8];
    let _e105 = global.U[9];
    let _e109 = global.U[10];
    let _e113 = global.U[11];
    let _e117 = global.U[12];
    let _e121 = global.U[13];
    let _e123 = perlinNoise2_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), mat3x3<f32>(vec3<f32>(_e66.x, _e66.y, _e66.z), vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z)), i32(_e90.x), _e95, _e98, _e101.x, _e105.x, _e109.x, _e113.x, _e117.x, _e121.x);
    fragColor = _e123;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
