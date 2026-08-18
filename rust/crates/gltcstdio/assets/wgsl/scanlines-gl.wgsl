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
@group(0) @binding(2) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

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

fn pincushion(p_3: vec2<f32>, k: f32) -> vec2<f32> {
    var p_4: vec2<f32>;
    var k_1: f32;

    p_4 = p_3;
    k_1 = k;
    let _e10 = p_4;
    let _e12 = k_1;
    let _e13 = p_4;
    let _e14 = p_4;
    let _e17 = p_4;
    let _e18 = p_4;
    return (_e10 * (1f + ((_e12 * dot(_e13, _e14)) * dot(_e17, _e18))));
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn scanlines(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, hueShift: f32, brightness: f32, modelTransform: mat3x3<f32>, hueTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var hueShift_1: f32;
    var brightness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var hueTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var invHueTransform: mat3x3<f32>;
    var col: vec4<f32>;
    var hsl: vec4<f32>;
    var origHsl: vec4<f32>;
    var scale: f32;
    var rot: mat2x2<f32>;
    var pinc: vec2<f32>;
    var pin: vec2<f32>;
    var v: vec2<f32>;
    var huePin: vec2<f32>;
    var b_1: f32;
    var hslD: vec4<f32>;
    var rgbD: vec4<f32>;
    var rgb: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    distortion_1 = distortion;
    hueShift_1 = hueShift;
    brightness_1 = brightness;
    modelTransform_1 = modelTransform;
    hueTransform_1 = hueTransform;
    let _e22 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e22);
    let _e25 = hueTransform_1;
    invHueTransform = _naga_inverse_3x3_f32(_e25);
    let _e28 = uv_1;
    let _e32 = global.U[0];
    let _e35 = uv_1;
    let _e44 = _mirror_wrap(((vec2<f32>((_e28.x / _e32.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    let _e45 = textureSample(t_source, samp, _e44);
    col = _e45;
    let _e47 = col;
    let _e48 = rgbToHsl(_e47);
    hsl = _e48;
    let _e50 = hsl;
    origHsl = _e50;
    let _e56 = invModelTransform[0][0];
    let _e61 = invModelTransform[0][1];
    scale = length(vec2<f32>(_e56, _e61));
    let _e65 = invModelTransform;
    let _e72 = mat2x2<f32>(_e65[0].xy, _e65[1].xy);
    let _e73 = scale;
    let _e74 = vec2(_e73);
    rot = mat2x2<f32>((_e72[0] / _e74), (_e72[1] / _e74));
    let _e81 = uv_1;
    let _e82 = distortion_1;
    let _e85 = pincushion(_e81, (_e82 * 0.15f));
    pinc = _e85;
    let _e87 = invModelTransform;
    let _e88 = pinc;
    pin = (_e87 * vec3<f32>(_e88.x, _e88.y, 1f)).xy;
    let _e96 = invModelTransform;
    let _e97 = pinc;
    let _e98 = tf(_e96, _e97);
    v = _e98;
    let _e100 = invHueTransform;
    let _e101 = v;
    let _e102 = tf(_e100, _e101);
    huePin = _e102;
    let _e108 = hsl.x;
    let _e109 = huePin;
    hsl[0i] = (_e108 + (_e109.y * 2000f));
    let _e115 = brightness_1;
    b_1 = pow(1.04f, (-(_e115) * 100f));
    let _e125 = hsl.z;
    let _e127 = v;
    let _e133 = brightness_1;
    let _e139 = b_1;
    hsl[2i] = (_e125 * pow(((1f + sin((_e127.y * 300f))) * ((_e133 * 0.1f) + 0.5f)), _e139));
    let _e142 = hueShift_1;
    if (_e142 < 0f) {
        {
            let _e149 = hsl.y;
            let _e150 = hueShift_1;
            hsl[1i] = max(_e149, -(_e150));
        }
    }
    let _e153 = origHsl;
    hslD = _e153;
    let _e159 = hsl.z;
    hslD[2i] = _e159;
    let _e160 = hslD;
    let _e161 = hslToRgb(_e160);
    rgbD = _e161;
    let _e163 = hsl;
    let _e164 = hslToRgb(_e163);
    rgb = _e164;
    let _e166 = rgbD;
    let _e167 = rgb;
    let _e168 = hueShift_1;
    rgb = mix(_e166, _e167, vec4(abs(_e168)));
    let _e172 = col;
    let _e173 = rgb;
    let _e174 = intensity_1;
    return mix(_e172, _e173, vec4(_e174));
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
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e111 = global.U[13];
    let _e112 = _e111.xyz;
    let _e115 = global.U[14];
    let _e116 = _e115.xyz;
    let _e130 = scanlines((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)), mat3x3<f32>(vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e116.x, _e116.y, _e116.z)));
    fragColor = _e130;
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
