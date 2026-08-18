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

fn hash11_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e7 = x_1;
    return fract((sin(((_e7 * 45.34f) + 123.131f)) * 94.434f));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_2: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x_2 = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x_2;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x_2;
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e9 = m_1;
    let _e10 = u_1;
    return (_e9 * vec3<f32>(_e10.x, _e10.y, 1f)).xy;
}

fn scratches(uv: vec2<f32>, outPos: vec2<f32>, color: vec4<f32>, colorBkg: vec4<f32>, modelTransform: mat3x3<f32>, coverage: f32, len: f32, variability: f32, randomSeed: f32, sourceDim: vec2<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var coverage_1: f32;
    var len_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var sourceDim_1: vec2<f32>;
    var t: vec2<f32>;
    var p: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var d2min: f32 = 1000000000f;
    var minId: vec2<f32> = vec2(0f);
    var j: i32 = -1i;
    var i: i32;
    var id: vec2<f32>;
    var center: vec2<f32>;
    var d: vec2<f32>;
    var dd: f32;
    var scratchRow: bool;
    var PERIOD: f32 = 8f;
    var phase_1: f32;
    var seg: f32;
    var inLen: bool;
    var local: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    color_1 = color;
    colorBkg_1 = colorBkg;
    modelTransform_1 = modelTransform;
    coverage_1 = coverage;
    len_1 = len;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    sourceDim_1 = sourceDim;
    let _e25 = modelTransform_1;
    let _e27 = uv_1;
    let _e28 = tf(_naga_inverse_3x3_f32(_e25), _e27);
    t = _e28;
    let _e30 = t;
    p = ((_e30 * 20f) * vec2<f32>(0.1f, 1f));
    let _e38 = p;
    ci = floor(_e38.x);
    let _e42 = p;
    cj = floor(_e42.y);
    loop {
        let _e54 = j;
        if !((_e54 <= 1i)) {
            break;
        }
        {
            i = -1i;
            loop {
                let _e64 = i;
                if !((_e64 <= 1i)) {
                    break;
                }
                {
                    let _e71 = ci;
                    let _e72 = i;
                    let _e75 = cj;
                    let _e76 = j;
                    id = vec2<f32>((_e71 + f32(_e72)), (_e75 + f32(_e76)));
                    let _e81 = id;
                    let _e85 = id;
                    let _e86 = randomSeed_1;
                    let _e87 = rand2relSeeded(_e85, _e86);
                    let _e88 = variability_1;
                    center = ((_e81 + vec2(0.5f)) + (_e87 * _e88));
                    let _e92 = p;
                    let _e93 = center;
                    d = (_e92 - _e93);
                    let _e96 = d;
                    let _e97 = d;
                    dd = dot(_e96, _e97);
                    let _e100 = dd;
                    let _e101 = d2min;
                    if (_e100 < _e101) {
                        {
                            let _e103 = dd;
                            d2min = _e103;
                            let _e104 = id;
                            minId = _e104;
                        }
                    }
                }
                continuing {
                    let _e68 = i;
                    i = (_e68 + 1i);
                }
            }
        }
        continuing {
            let _e58 = j;
            j = (_e58 + 1i);
        }
    }
    let _e105 = minId;
    let _e109 = randomSeed_1;
    let _e111 = hash11_(((_e105.y * 1.7f) + _e109));
    let _e112 = coverage_1;
    scratchRow = (_e111 < _e112);
    let _e117 = minId;
    let _e121 = randomSeed_1;
    let _e125 = hash11_((((_e117.y * 2.3f) + _e121) + 5f));
    let _e126 = PERIOD;
    phase_1 = floor((_e125 * _e126));
    let _e130 = minId;
    let _e132 = phase_1;
    let _e133 = (_e130.x + _e132);
    let _e134 = PERIOD;
    seg = (_e133 - (floor((_e133 / _e134)) * _e134));
    let _e140 = seg;
    let _e141 = len_1;
    let _e142 = PERIOD;
    inLen = (_e140 < (_e141 * _e142));
    let _e146 = scratchRow;
    let _e147 = inLen;
    if (_e146 && _e147) {
        let _e149 = color_1;
        local = _e149;
    } else {
        let _e150 = colorBkg_1;
        local = _e150;
    }
    let _e152 = local;
    return _e152;
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
    let _e65 = global.U[6];
    let _e68 = global.U[7];
    let _e71 = global.U[8];
    let _e72 = _e71.xyz;
    let _e75 = global.U[9];
    let _e76 = _e75.xyz;
    let _e79 = global.U[10];
    let _e80 = _e79.xyz;
    let _e96 = global.U[11];
    let _e100 = global.U[12];
    let _e104 = global.U[13];
    let _e108 = global.U[14];
    let _e112 = global.U[4];
    let _e114 = scratches((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68, mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x, _e104.x, _e108.x, _e112.xy);
    fragColor = _e114;
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
