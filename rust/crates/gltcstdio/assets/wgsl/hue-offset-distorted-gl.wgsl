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

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e12 = h_1;
    if (_e12 < 0f) {
        let _e15 = h_1;
        h_1 = (_e15 + 1f);
    }
    let _e18 = h_1;
    if (_e18 > 1f) {
        let _e21 = h_1;
        h_1 = (_e21 - 1f);
    }
    let _e25 = h_1;
    if ((6f * _e25) < 1f) {
        {
            let _e29 = p_1;
            let _e30 = q_1;
            let _e31 = p_1;
            let _e35 = h_1;
            return (_e29 + (((_e30 - _e31) * 6f) * _e35));
        }
    }
    let _e39 = h_1;
    if ((2f * _e39) < 1f) {
        {
            let _e43 = q_1;
            return _e43;
        }
    }
    let _e45 = h_1;
    if ((3f * _e45) < 2f) {
        {
            let _e49 = p_1;
            let _e50 = q_1;
            let _e51 = p_1;
            let _e58 = h_1;
            return (_e49 + (((_e50 - _e51) * 6f) * (0.6666667f - _e58)));
        }
    }
    let _e62 = p_1;
    return _e62;
}

fn hslToRgb(inc: vec4<f32>) -> vec4<f32> {
    var inc_1: vec4<f32>;
    var h_2: f32;
    var s: f32;
    var l: f32;
    var q_2: f32 = 0f;
    var p_2: f32;
    var r: f32;
    var g: f32;
    var b: f32;
    var outc: vec4<f32>;

    inc_1 = inc;
    let _e8 = inc_1;
    h_2 = (_e8.x - (floor((_e8.x / 360f)) * 360f));
    let _e16 = h_2;
    h_2 = (_e16 / 360f);
    let _e19 = inc_1;
    s = _e19.y;
    let _e22 = inc_1;
    l = _e22.z;
    let _e27 = l;
    if (_e27 < 0.5f) {
        let _e30 = l;
        let _e32 = s;
        q_2 = (_e30 * (1f + _e32));
    } else {
        let _e35 = l;
        let _e36 = s;
        let _e38 = s;
        let _e39 = l;
        q_2 = ((_e35 + _e36) - (_e38 * _e39));
    }
    let _e43 = l;
    let _e45 = q_2;
    p_2 = ((2f * _e43) - _e45);
    let _e49 = p_2;
    let _e50 = q_2;
    let _e51 = h_2;
    let _e56 = hueToRgb(_e49, _e50, (_e51 + 0.33333334f));
    r = max(0f, _e56);
    let _e60 = p_2;
    let _e61 = q_2;
    let _e62 = h_2;
    let _e63 = hueToRgb(_e60, _e61, _e62);
    g = max(0f, _e63);
    let _e67 = p_2;
    let _e68 = q_2;
    let _e69 = h_2;
    let _e74 = hueToRgb(_e67, _e68, (_e69 - 0.33333334f));
    b = max(0f, _e74);
    let _e79 = r;
    outc.x = min(_e79, 1f);
    let _e83 = g;
    outc.y = min(_e83, 1f);
    let _e87 = b;
    outc.z = min(_e87, 1f);
    let _e91 = inc_1;
    outc.w = _e91.w;
    let _e93 = outc;
    return _e93;
}

fn hueOffsetDistortedDistort(p_3: vec2<f32>, k: f32, randomSeed: f32) -> vec2<f32> {
    var p_4: vec2<f32>;
    var k_1: f32;
    var randomSeed_1: f32;
    var pp: vec3<f32>;
    var m: vec3<f32>;

    p_4 = p_3;
    k_1 = k;
    randomSeed_1 = randomSeed;
    let _e12 = p_4;
    let _e13 = randomSeed_1;
    pp = vec3<f32>(_e12.x, _e12.y, _e13);
    let _e18 = randomSeed_1;
    let _e20 = randomSeed_1;
    let _e24 = randomSeed_1;
    m = vec3<f32>(sin(_e18), sin((_e20 + 10f)), sin((-(_e24) + 20f)));
    let _e31 = pp;
    let _e33 = pp;
    let _e35 = k_1;
    let _e39 = m;
    let _e42 = pp;
    let _e47 = (_e33.xyz + ((_e35 * 1f) * sin(((2f + _e39.x) * _e42.yzx))));
    pp.x = _e47.x;
    pp.y = _e47.y;
    pp.z = _e47.z;
    let _e54 = pp;
    let _e56 = pp;
    let _e58 = k_1;
    let _e62 = m;
    let _e65 = pp;
    let _e70 = (_e56.xyz + ((_e58 * 0.75f) * sin(((2f + _e62.y) * _e65.yzx))));
    pp.x = _e70.x;
    pp.y = _e70.y;
    pp.z = _e70.z;
    let _e77 = pp;
    let _e79 = pp;
    let _e81 = k_1;
    let _e85 = m;
    let _e88 = pp;
    let _e93 = (_e79.xyz + ((_e81 * 0.5f) * sin(((2f + _e85.z) * _e88.yzx))));
    pp.x = _e93.x;
    pp.y = _e93.y;
    pp.z = _e93.z;
    let _e100 = pp;
    return _e100.xy;
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local: vec4<f32>;
    var P: vec4<f32>;
    var local_1: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e8 = RGB_1;
    let _e10 = RGB_1;
    if (_e8.y < _e10.z) {
        let _e13 = RGB_1;
        let _e14 = _e13.zy;
        local = vec4<f32>(_e14.x, _e14.y, -1f, 0.6666667f);
    } else {
        let _e23 = RGB_1;
        let _e24 = _e23.yz;
        local = vec4<f32>(_e24.x, _e24.y, 0f, -0.33333334f);
    }
    let _e34 = local;
    P = _e34;
    let _e36 = RGB_1;
    let _e38 = P;
    if (_e36.x < _e38.x) {
        let _e41 = P;
        let _e42 = _e41.xyw;
        let _e43 = RGB_1;
        local_1 = vec4<f32>(_e42.x, _e42.y, _e42.z, _e43.x);
    } else {
        let _e49 = RGB_1;
        let _e51 = P;
        let _e52 = _e51.yzx;
        local_1 = vec4<f32>(_e49.x, _e52.x, _e52.y, _e52.z);
    }
    let _e58 = local_1;
    Q = _e58;
    let _e60 = Q;
    let _e62 = Q;
    let _e64 = Q;
    C = (_e60.x - min(_e62.w, _e64.y));
    let _e69 = Q;
    let _e71 = Q;
    let _e75 = C;
    let _e80 = Q;
    H = abs((((_e69.w - _e71.y) / ((6f * _e75) + 0.0000000001f)) + _e80.z));
    let _e85 = H;
    let _e86 = C;
    let _e87 = Q;
    let _e89 = RGB_1;
    return vec4<f32>(_e85, _e86, _e87.x, _e89.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e8 = RGB_3;
    let _e9 = rgbToHcv(_e8);
    HCV = _e9;
    let _e11 = HCV;
    let _e13 = HCV;
    L = (_e11.z - (_e13.y * 0.5f));
    let _e19 = HCV;
    let _e22 = L;
    S = (_e19.y / ((1f - abs(((_e22 * 2f) - 1f))) + 0.000001f));
    let _e33 = HCV;
    let _e37 = S;
    let _e38 = L;
    let _e39 = RGB_3;
    return vec4<f32>((_e33.x * 360f), _e37, _e38, _e39.w);
}

fn tf(m_1: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_2: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_2 = m_1;
    u_1 = u;
    let _e10 = m_2;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn hueOffsetDistortedGl(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, balance: f32, randomSeed_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var randomSeed_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var col: vec4<f32>;
    var hsl: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    balance_1 = balance;
    randomSeed_3 = randomSeed_2;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = pos_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    u_2 = _e21;
    let _e23 = pos_1;
    let _e27 = global.U[0];
    let _e30 = pos_1;
    let _e39 = textureSample(t_source, samp, ((vec2<f32>((_e23.x / _e27.x), _e30.y) / vec2(2f)) + vec2(0.5f)));
    col = _e39;
    let _e41 = col;
    let _e42 = rgbToHsl(_e41);
    hsl = _e42;
    let _e48 = hsl.x;
    let _e49 = u_2;
    let _e51 = randomSeed_3;
    let _e52 = hueOffsetDistortedDistort(_e49, 1.1f, _e51);
    let _e58 = hsl.y;
    hsl[0i] = (_e48 + ((_e52.x * 2000f) * _e58));
    let _e65 = hsl.y;
    let _e69 = hsl.y;
    let _e71 = balance_1;
    hsl[1i] = mix(_e65, (1f - _e69), ((_e71 * 0.5f) + 0.5f));
    let _e77 = hsl;
    let _e78 = hslToRgb(_e77);
    outCol = _e78;
    let _e80 = col;
    let _e81 = outCol;
    let _e82 = intensity_1;
    return clamp(mix(_e80, _e81, vec4((_e82 * 2f))), vec4(0f), vec4(1f));
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
    let _e66 = global.U[8];
    let _e70 = global.U[9];
    let _e74 = global.U[10];
    let _e78 = global.U[11];
    let _e79 = _e78.xyz;
    let _e82 = global.U[12];
    let _e83 = _e82.xyz;
    let _e86 = global.U[13];
    let _e87 = _e86.xyz;
    let _e101 = hueOffsetDistortedGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
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
