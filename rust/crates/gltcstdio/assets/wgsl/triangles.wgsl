struct Params {
    U: array<vec4<f32>, 8>,
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

fn inTriangle(p: vec2<f32>, a: vec2<f32>, b: vec2<f32>, c: vec2<f32>) -> bool {
    var p_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var c_1: vec2<f32>;
    var e0_: vec2<f32>;
    var e1_: vec2<f32>;
    var e2_: vec2<f32>;
    var v0_: vec2<f32>;
    var v1_: vec2<f32>;
    var v2_: vec2<f32>;
    var s: f32;

    p_1 = p;
    a_1 = a;
    b_1 = b;
    c_1 = c;
    let _e13 = b_1;
    let _e14 = a_1;
    e0_ = (_e13 - _e14);
    let _e17 = c_1;
    let _e18 = b_1;
    e1_ = (_e17 - _e18);
    let _e21 = a_1;
    let _e22 = c_1;
    e2_ = (_e21 - _e22);
    let _e25 = p_1;
    let _e26 = a_1;
    v0_ = (_e25 - _e26);
    let _e29 = p_1;
    let _e30 = b_1;
    v1_ = (_e29 - _e30);
    let _e33 = p_1;
    let _e34 = c_1;
    v2_ = (_e33 - _e34);
    let _e37 = e0_;
    let _e39 = e2_;
    let _e42 = e0_;
    let _e44 = e2_;
    s = sign(((_e37.x * _e39.y) - (_e42.y * _e44.x)));
    let _e50 = s;
    let _e51 = v0_;
    let _e53 = e0_;
    let _e56 = v0_;
    let _e58 = e0_;
    let _e65 = s;
    let _e66 = v1_;
    let _e68 = e1_;
    let _e71 = v1_;
    let _e73 = e1_;
    let _e81 = s;
    let _e82 = v2_;
    let _e84 = e2_;
    let _e87 = v2_;
    let _e89 = e2_;
    return ((((_e50 * ((_e51.x * _e53.y) - (_e56.y * _e58.x))) > 0f) && ((_e65 * ((_e66.x * _e68.y) - (_e71.y * _e73.x))) > 0f)) && ((_e81 * ((_e82.x * _e84.y) - (_e87.y * _e89.x))) > 0f));
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

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_1;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e9 = noise_3;
    let _e11 = k_3;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_3;
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

fn triangles(uv: vec2<f32>, outPos: vec2<f32>, color: vec4<f32>, count: i32, randomSeed: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color_1: vec4<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var col: vec3<f32>;
    var size: f32 = 1f;
    var N: f32;
    var i: f32 = 0f;
    var offset: vec2<f32>;
    var u: vec2<f32>;
    var id: vec2<f32>;
    var center: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var c_2: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    color_1 = color;
    count_1 = count;
    randomSeed_1 = randomSeed;
    let _e15 = color_1;
    col = _e15.xyz;
    let _e20 = count_1;
    N = f32(_e20);
    loop {
        let _e25 = i;
        let _e26 = N;
        if !((_e25 < _e26)) {
            break;
        }
        {
            let _e32 = i;
            let _e35 = i;
            let _e39 = randomSeed_1;
            let _e40 = rand2relSeeded(vec2<f32>((_e32 * 10f), (_e35 + 2.221f)), _e39);
            offset = (_e40 - vec2(0.5f));
            let _e45 = uv_1;
            let _e47 = offset;
            u = ((_e45 + (200f * _e47)) * 0.5f);
            let _e53 = u;
            id = floor(_e53);
            let _e56 = id;
            center = (_e56 + vec2(0.5f));
            let _e61 = id;
            let _e62 = randomSeed_1;
            let _e63 = rand2relSeeded(_e61, _e62);
            rnd = _e63;
            let _e65 = id;
            let _e69 = id;
            let _e74 = randomSeed_1;
            let _e75 = rand2relSeeded(vec2<f32>((_e65.x * 1.15f), (_e69.y * 2.55f)), _e74);
            rnd2_ = _e75;
            let _e77 = center;
            let _e78 = size;
            let _e79 = rnd;
            a_2 = (_e77 + (_e78 * _e79));
            let _e83 = center;
            let _e84 = size;
            let _e85 = rnd;
            b_2 = (_e83 + (_e84 * (fract((_e85 * 10f)) - vec2(0.5f))));
            let _e95 = center;
            let _e96 = size;
            let _e97 = rnd2_;
            c_2 = (_e95 + (_e96 * _e97));
            let _e101 = u;
            let _e102 = a_2;
            let _e103 = b_2;
            let _e104 = c_2;
            let _e105 = inTriangle(_e101, _e102, _e103, _e104);
            if _e105 {
                {
                    let _e107 = rnd;
                    let _e108 = rnd2_;
                    col = (vec3(0.5f) + vec3<f32>(_e107.x, _e107.y, _e108.x));
                }
            }
        }
        continuing {
            let _e29 = i;
            i = (_e29 + 1f);
        }
    }
    let _e115 = col;
    return vec4<f32>(_e115.x, _e115.y, _e115.z, 1f);
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
    let _e65 = global.U[5];
    let _e68 = global.U[6];
    let _e73 = global.U[7];
    let _e75 = triangles((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, i32(_e68.x), _e73.x);
    fragColor = _e75;
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
