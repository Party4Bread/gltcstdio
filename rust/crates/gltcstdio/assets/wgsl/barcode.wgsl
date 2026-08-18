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

fn response(d: f32, glow: f32) -> f32 {
    var d_1: f32;
    var glow_1: f32;
    var local: f32;
    var base: f32;
    var local_1: f32;

    d_1 = d;
    glow_1 = glow;
    let _e10 = glow_1;
    if (_e10 < 0.2f) {
        local = 1f;
    } else {
        let _e15 = glow_1;
        local = (1f + ((_e15 - 0.2f) * 4f));
    }
    let _e22 = local;
    base = _e22;
    let _e24 = base;
    let _e25 = d_1;
    if (_e25 <= 0f) {
        local_1 = 1f;
    } else {
        let _e30 = glow_1;
        let _e33 = d_1;
        local_1 = min(1f, ((_e30 * 0.01f) / _e33));
    }
    let _e37 = local_1;
    let _e41 = d_1;
    return ((_e24 * _e37) * smoothstep(2f, 1.2f, _e41));
}

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local_2: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local_2 = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local_2 = max(_e25.x, _e27.y);
    }
    let _e31 = local_2;
    return _e31;
}

fn spilloverChannels(c: vec4<f32>) -> vec4<f32> {
    var c_1: vec4<f32>;
    var overflow: f32;

    c_1 = c;
    let _e8 = c_1;
    let _e14 = c_1;
    let _e21 = c_1;
    overflow = (((max((_e8.x - 1f), 0f) + max((_e14.y - 1f), 0f)) + max((_e21.z - 1f), 0f)) / 3f);
    let _e32 = c_1;
    let _e34 = overflow;
    c_1.x = (_e32.x + _e34);
    let _e37 = c_1;
    let _e39 = overflow;
    c_1.y = (_e37.y + _e39);
    let _e42 = c_1;
    let _e44 = overflow;
    c_1.z = (_e42.z + _e44);
    let _e46 = c_1;
    return _e46;
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn barcode(uv: vec2<f32>, outPos: vec2<f32>, count: i32, randomSeed: f32, len: f32, thickness: f32, color: vec4<f32>, glow_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var len_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var glow_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var code1_: f32;
    var code2_: f32;
    var k_4: f32 = 0f;
    var N: f32;
    var unit: f32;
    var code: f32;
    var i: f32 = 0f;
    var width: f32;
    var d_2: f32;
    var bkgCol: vec4<f32>;
    var glowCol: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_1 = count;
    randomSeed_1 = randomSeed;
    len_1 = len;
    thickness_1 = thickness;
    color_1 = color;
    glow_3 = glow_2;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    let _e26 = uv_1;
    let _e27 = tf(_naga_inverse_3x3_f32(_e24), _e26);
    u_4 = _e27;
    let _e32 = randomSeed_1;
    let _e33 = rand2relSeeded(vec2<f32>(10f, 10f), _e32);
    rnd = _e33;
    let _e39 = randomSeed_1;
    let _e40 = rand2relSeeded(vec2<f32>(11f, -5.5f), _e39);
    rnd2_ = _e40;
    let _e42 = rnd2_;
    let _e48 = rnd;
    code1_ = floor((((_e42.x + 0.5f) * 256f) + ((_e48.x + 0.5f) * 65536f)));
    let _e57 = rnd2_;
    let _e63 = rnd;
    code2_ = floor((((_e57.y + 0.5f) * 256f) + ((_e63.y + 0.5f) * 65536f)));
    let _e74 = count_1;
    N = f32(_e74);
    let _e77 = thickness_1;
    let _e79 = N;
    unit = (_e77 / (3f * _e79));
    let _e83 = code1_;
    code = _e83;
    loop {
        let _e87 = i;
        let _e88 = N;
        if !((_e87 < _e88)) {
            break;
        }
        {
            let _e94 = code;
            width = ((_e94 - (floor((_e94 / 2f)) * 2f)) + 1f);
            let _e103 = code;
            code = floor((_e103 / 2f));
            let _e107 = code;
            if (_e107 == 0f) {
                let _e110 = code2_;
                code = _e110;
            }
            let _e111 = u_4;
            let _e112 = i;
            let _e113 = N;
            let _e119 = len_1;
            let _e124 = width;
            let _e125 = unit;
            let _e131 = sdRectangle((_e111 - vec2<f32>((((_e112 / (_e113 - 1f)) - 0.5f) * _e119), 0f)), vec2<f32>(((_e124 * _e125) * 0.5f), 0.5f));
            d_2 = _e131;
            let _e133 = k_4;
            let _e134 = d_2;
            let _e135 = glow_3;
            let _e136 = response(_e134, _e135);
            k_4 = (_e133 + _e136);
        }
        continuing {
            let _e91 = i;
            i = (_e91 + 1f);
        }
    }
    let _e138 = uv_1;
    let _e142 = global.U[0];
    let _e145 = uv_1;
    let _e154 = textureSample(t_source, samp, ((vec2<f32>((_e138.x / _e142.x), _e145.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e154;
    let _e156 = color_1;
    let _e159 = k_4;
    let _e161 = (_e156.xyz * max(1f, _e159));
    let _e162 = color_1;
    let _e168 = spilloverChannels(vec4<f32>(_e161.x, _e161.y, _e161.z, _e162.w));
    glowCol = _e168;
    let _e170 = bkgCol;
    let _e171 = glowCol;
    let _e172 = _e171.xyz;
    let _e173 = glowCol;
    let _e176 = k_4;
    let _e183 = mergeColor(_e170, vec4<f32>(_e172.x, _e172.y, _e172.z, (_e173.w * min(1f, _e176))));
    outCol = _e183;
    let _e185 = outCol;
    return _e185;
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
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e113 = barcode((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83, _e86.x, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)));
    fragColor = _e113;
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
