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
    let _e14 = b_1;
    let _e15 = a_1;
    e0_ = (_e14 - _e15);
    let _e18 = c_1;
    let _e19 = b_1;
    e1_ = (_e18 - _e19);
    let _e22 = a_1;
    let _e23 = c_1;
    e2_ = (_e22 - _e23);
    let _e26 = p_1;
    let _e27 = a_1;
    v0_ = (_e26 - _e27);
    let _e30 = p_1;
    let _e31 = b_1;
    v1_ = (_e30 - _e31);
    let _e34 = p_1;
    let _e35 = c_1;
    v2_ = (_e34 - _e35);
    let _e38 = e0_;
    let _e40 = e2_;
    let _e43 = e0_;
    let _e45 = e2_;
    s = sign(((_e38.x * _e40.y) - (_e43.y * _e45.x)));
    let _e51 = s;
    let _e52 = v0_;
    let _e54 = e0_;
    let _e57 = v0_;
    let _e59 = e0_;
    let _e66 = s;
    let _e67 = v1_;
    let _e69 = e1_;
    let _e72 = v1_;
    let _e74 = e1_;
    let _e82 = s;
    let _e83 = v2_;
    let _e85 = e2_;
    let _e88 = v2_;
    let _e90 = e2_;
    return ((((_e51 * ((_e52.x * _e54.y) - (_e57.y * _e59.x))) > 0f) && ((_e66 * ((_e67.x * _e69.y) - (_e72.y * _e74.x))) > 0f)) && ((_e82 * ((_e83.x * _e85.y) - (_e88.y * _e90.x))) > 0f));
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

fn triangleFrosting(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var col: vec4<f32>;
    var size: f32 = 1f;
    var N: f32;
    var v_2: vec2<f32>;
    var i: f32 = 0f;
    var offset: vec2<f32>;
    var u_2: vec2<f32>;
    var id: vec2<f32>;
    var center: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var c_2: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e18 = uv_1;
    let _e22 = global.U[0];
    let _e25 = uv_1;
    let _e34 = textureSample(t_source, samp, ((vec2<f32>((_e18.x / _e22.x), _e25.y) / vec2(2f)) + vec2(0.5f)));
    col = _e34;
    let _e38 = count_1;
    N = f32(_e38);
    let _e41 = modelTransform_1;
    let _e43 = uv_1;
    let _e44 = tf(_naga_inverse_3x3_f32(_e41), _e43);
    v_2 = _e44;
    loop {
        let _e48 = i;
        let _e49 = N;
        if !((_e48 < _e49)) {
            break;
        }
        {
            let _e55 = i;
            let _e58 = i;
            let _e62 = randomSeed_1;
            let _e63 = rand2relSeeded(vec2<f32>((_e55 * 10f), (_e58 + 2.221f)), _e62);
            offset = (_e63 - vec2(0.5f));
            let _e68 = v_2;
            let _e70 = offset;
            u_2 = ((_e68 + (200f * _e70)) * 0.5f);
            let _e76 = u_2;
            id = floor(_e76);
            let _e79 = id;
            center = (_e79 + vec2(0.5f));
            let _e84 = id;
            let _e85 = randomSeed_1;
            let _e86 = rand2relSeeded(_e84, _e85);
            rnd = _e86;
            let _e88 = id;
            let _e92 = id;
            let _e97 = randomSeed_1;
            let _e98 = rand2relSeeded(vec2<f32>((_e88.x * 1.15f), (_e92.y * 2.55f)), _e97);
            rnd2_ = _e98;
            let _e100 = center;
            let _e101 = size;
            let _e102 = rnd;
            a_2 = (_e100 + (_e101 * _e102));
            let _e106 = center;
            let _e107 = size;
            let _e108 = rnd;
            b_2 = (_e106 + (_e107 * (fract((_e108 * 10f)) - vec2(0.5f))));
            let _e118 = center;
            let _e119 = size;
            let _e120 = rnd2_;
            c_2 = (_e118 + (_e119 * _e120));
            let _e124 = u_2;
            let _e125 = a_2;
            let _e126 = b_2;
            let _e127 = c_2;
            let _e128 = inTriangle(_e124, _e125, _e126, _e127);
            if _e128 {
                {
                    let _e129 = col;
                    let _e130 = modelTransform_1;
                    let _e132 = a_2;
                    let _e133 = b_2;
                    let _e135 = c_2;
                    let _e142 = offset;
                    let _e145 = tf(_e130, (((2f * ((_e132 + _e133) + _e135)) / vec2(3f)) - (200f * _e142)));
                    let _e149 = global.U[0];
                    let _e152 = modelTransform_1;
                    let _e154 = a_2;
                    let _e155 = b_2;
                    let _e157 = c_2;
                    let _e164 = offset;
                    let _e167 = tf(_e152, (((2f * ((_e154 + _e155) + _e157)) / vec2(3f)) - (200f * _e164)));
                    let _e176 = textureSample(t_source, samp, ((vec2<f32>((_e145.x / _e149.x), _e167.y) / vec2(2f)) + vec2(0.5f)));
                    let _e177 = intensity_1;
                    col = mix(_e129, _e176, vec4(_e177));
                }
            }
        }
        continuing {
            let _e52 = i;
            i = (_e52 + 1f);
        }
    }
    let _e180 = col;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = triangleFrosting((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
