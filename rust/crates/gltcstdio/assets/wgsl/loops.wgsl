struct Params {
    U: array<vec4<f32>, 19>,
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

fn hexCoords(v: vec2<f32>) -> vec4<f32> {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
    var id: vec2<f32>;

    v_1 = v;
    let _e12 = r;
    h = (_e12 / vec2(2f));
    let _e17 = v_1;
    let _e19 = r;
    let _e25 = v_1;
    let _e27 = r;
    let _e34 = h;
    a = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_1;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r;
    let _e48 = v_1;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r;
    let _e60 = h;
    b = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a;
    let _e65 = b;
    if (length(_e63) < length(_e65)) {
        let _e68 = a;
        local = _e68;
    } else {
        let _e69 = b;
        local = _e69;
    }
    let _e71 = local;
    hv = _e71;
    let _e73 = v_1;
    let _e74 = hv;
    id = (_e73 - _e74);
    let _e77 = hv;
    let _e78 = id;
    return vec4<f32>(_e77.x, _e77.y, _e78.x, _e78.y);
}

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

fn rand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var x: f32;
    var y: f32;

    v_3 = v_2;
    let _e8 = v_3;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_3;
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

fn layer(uv: vec2<f32>, col: vec4<f32>, count: i32, offset: f32, thickness: f32, glow: f32, neon: f32, randomSeed: f32, variability: f32, colorVariability: f32, color: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var col_1: vec4<f32>;
    var count_1: i32;
    var offset_1: f32;
    var thickness_1: f32;
    var glow_1: f32;
    var neon_1: f32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var colorVariability_1: f32;
    var color_1: vec4<f32>;
    var D: f32;
    var T: f32;
    var MAXR: f32 = 1.5f;
    var hex: vec4<f32>;
    var id_1: vec2<f32>;
    var relCenter: vec2<f32>;
    var radius: f32;
    var i: i32 = 0i;
    var k_4: f32;
    var rnd: vec2<f32>;
    var c: vec2<f32>;
    var d: f32;
    var alpha: f32;
    var colLoop: vec3<f32>;

    uv_1 = uv;
    col_1 = col;
    count_1 = count;
    offset_1 = offset;
    thickness_1 = thickness;
    glow_1 = glow;
    neon_1 = neon;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    colorVariability_1 = colorVariability;
    color_1 = color;
    let _e28 = offset_1;
    D = _e28;
    let _e30 = thickness_1;
    T = (_e30 * 0.1f);
    let _e36 = uv_1;
    let _e37 = hexCoords(_e36);
    hex = _e37;
    let _e39 = hex;
    id_1 = floor(((_e39.zw * 100f) + vec2(0.5f)));
    let _e48 = hex;
    uv_1 = (_e48.xy * 15f);
    let _e52 = id_1;
    let _e53 = randomSeed_1;
    let _e54 = rand2relSeeded(_e52, _e53);
    relCenter = (_e54 * 6f);
    let _e58 = MAXR;
    let _e59 = D;
    let _e62 = relCenter;
    let _e64 = relCenter;
    radius = ((_e58 - _e59) - (0.5f * fract(((_e62.x + _e64.y) * 11f))));
    loop {
        let _e75 = i;
        let _e76 = count_1;
        if !((_e75 < _e76)) {
            break;
        }
        {
            let _e82 = i;
            k_4 = f32(_e82);
            let _e85 = id_1;
            let _e86 = k_4;
            let _e89 = randomSeed_1;
            let _e90 = rand2relSeeded((_e85 + vec2(_e86)), _e89);
            rnd = _e90;
            let _e92 = relCenter;
            let _e93 = D;
            let _e94 = rnd;
            c = (_e92 + (_e93 * _e94));
            let _e98 = uv_1;
            let _e99 = c;
            let _e102 = radius;
            d = abs((length((_e98 - _e99)) - _e102));
            alpha = 0f;
            let _e108 = d;
            let _e109 = T;
            if (_e108 < _e109) {
                alpha = 1f;
            } else {
                let _e112 = glow_1;
                if (_e112 > 0f) {
                    let _e115 = T;
                    let _e117 = glow_1;
                    let _e120 = T;
                    let _e122 = glow_1;
                    let _e125 = d;
                    let _e127 = T;
                    let _e129 = d;
                    alpha = (((smoothstep((_e115 * (10f * _e117)), (_e120 * (5f * _e122)), _e125) * _e127) / _e129) * 0.75f);
                }
            }
            let _e133 = color_1;
            let _e135 = rnd;
            let _e136 = rnd;
            let _e140 = rnd;
            let _e151 = colorVariability_1;
            colLoop = (_e133.xyz + (vec3<f32>(_e135.x, _e135.y, (fract(((_e136.x * 4.434f) + (_e140.y * 7.565f))) - 0.5f)) * _e151));
            let _e155 = alpha;
            if (_e155 > 0f) {
                let _e158 = col_1;
                let _e159 = colLoop;
                let _e160 = neon_1;
                let _e162 = (_e159 + vec3(_e160));
                let _e163 = alpha;
                let _e168 = mergeColor(_e158, vec4<f32>(_e162.x, _e162.y, _e162.z, _e163));
                col_1 = _e168;
            }
        }
        continuing {
            let _e79 = i;
            i = (_e79 + 1i);
        }
    }
    let _e169 = col_1;
    return _e169;
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

fn loops(uv_2: vec2<f32>, outPos: vec2<f32>, count_2: i32, layerCount: i32, modelTransform: mat3x3<f32>, color_2: vec4<f32>, colorVariability_2: f32, glow_2: f32, neon_2: f32, thickness_2: f32, offset_2: f32, randomSeed_2: f32, variability_2: f32, source_specified: i32) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_3: i32;
    var layerCount_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var color_3: vec4<f32>;
    var colorVariability_3: f32;
    var glow_3: f32;
    var neon_3: f32;
    var thickness_3: f32;
    var offset_3: f32;
    var randomSeed_3: f32;
    var variability_3: f32;
    var source_specified_1: i32;
    var inverseModelTransform: mat3x3<f32>;
    var bkg_2: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var col_2: vec4<f32>;
    var i_1: i32 = 0i;

    uv_3 = uv_2;
    outPos_1 = outPos;
    count_3 = count_2;
    layerCount_1 = layerCount;
    modelTransform_1 = modelTransform;
    color_3 = color_2;
    colorVariability_3 = colorVariability_2;
    glow_3 = glow_2;
    neon_3 = neon_2;
    thickness_3 = thickness_2;
    offset_3 = offset_2;
    randomSeed_3 = randomSeed_2;
    variability_3 = variability_2;
    source_specified_1 = source_specified;
    let _e34 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e34);
    let _e43 = source_specified_1;
    if (_e43 == 1i) {
        {
            let _e46 = outPos_1;
            let _e50 = global.U[0];
            let _e53 = outPos_1;
            let _e62 = textureSample(t_source, samp, ((vec2<f32>((_e46.x / _e50.x), _e53.y) / vec2(2f)) + vec2(0.5f)));
            bkg_2 = _e62;
        }
    }
    let _e63 = bkg_2;
    col_2 = _e63;
    loop {
        let _e67 = i_1;
        let _e68 = layerCount_1;
        if !((_e67 < _e68)) {
            break;
        }
        {
            let _e74 = uv_3;
            let _e75 = col_2;
            let _e76 = count_3;
            let _e77 = offset_3;
            let _e78 = thickness_3;
            let _e79 = glow_3;
            let _e80 = neon_3;
            let _e81 = randomSeed_3;
            let _e82 = variability_3;
            let _e83 = colorVariability_3;
            let _e84 = color_3;
            let _e85 = layer(_e74, _e75, _e76, _e77, _e78, _e79, _e80, _e81, _e82, _e83, _e84);
            col_2 = _e85;
            let _e86 = inverseModelTransform;
            let _e87 = uv_3;
            let _e88 = tf(_e86, _e87);
            uv_3 = _e88;
        }
        continuing {
            let _e71 = i_1;
            i_1 = (_e71 + 1i);
        }
    }
    let _e89 = col_2;
    return _e89;
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
    let _e66 = global.U[6];
    let _e71 = global.U[7];
    let _e76 = global.U[8];
    let _e77 = _e76.xyz;
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e101 = global.U[11];
    let _e104 = global.U[12];
    let _e108 = global.U[13];
    let _e112 = global.U[14];
    let _e116 = global.U[15];
    let _e120 = global.U[16];
    let _e124 = global.U[17];
    let _e128 = global.U[18];
    let _e132 = global.U[4];
    let _e135 = loops((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), _e101, _e104.x, _e108.x, _e112.x, _e116.x, _e120.x, _e124.x, _e128.x, i32(_e132.x));
    fragColor = _e135;
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
