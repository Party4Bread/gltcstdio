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

fn tintColor(col: vec4<f32>, tint: vec4<f32>) -> vec4<f32> {
    var col_1: vec4<f32>;
    var tint_1: vec4<f32>;
    var colHsl: vec3<f32>;
    var tintHsl: vec3<f32>;
    var gamma: f32;
    var target_: vec4<f32>;

    col_1 = col;
    tint_1 = tint;
    let _e10 = col_1;
    let _e11 = rgbToHsl(_e10);
    colHsl = _e11.xyz;
    let _e14 = tint_1;
    let _e15 = rgbToHsl(_e14);
    tintHsl = _e15.xyz;
    let _e20 = tintHsl;
    gamma = pow(5f, (0.5f - _e20.z));
    let _e25 = tintHsl;
    let _e26 = _e25.xy;
    let _e27 = colHsl;
    let _e29 = gamma;
    let _e31 = col_1;
    let _e36 = hslToRgb(vec4<f32>(_e26.x, _e26.y, pow(_e27.z, _e29), _e31.w));
    target_ = _e36;
    let _e38 = col_1;
    let _e39 = target_;
    let _e40 = tint_1;
    return mix(_e38, _e39, vec4(_e40.w));
}

fn adjustColor(col_2: vec4<f32>, brightness: f32, contrast: f32, luminosity: f32, gamma_1: f32, saturation: f32, hue: f32, tint_2: vec4<f32>) -> vec4<f32> {
    var col_3: vec4<f32>;
    var brightness_1: f32;
    var contrast_1: f32;
    var luminosity_1: f32;
    var gamma_2: f32;
    var saturation_1: f32;
    var hue_1: f32;
    var tint_3: vec4<f32>;
    var p_3: f32;
    var local_2: f32;
    var c: f32;
    var requireHsl: bool;
    var hsl: vec4<f32>;

    col_3 = col_2;
    brightness_1 = brightness;
    contrast_1 = contrast;
    luminosity_1 = luminosity;
    gamma_2 = gamma_1;
    saturation_1 = saturation;
    hue_1 = hue;
    tint_3 = tint_2;
    let _e22 = luminosity_1;
    if (_e22 != 0f) {
        {
            let _e25 = col_3;
            let _e27 = col_3;
            let _e29 = luminosity_1;
            let _e31 = (_e27.xyz + vec3(_e29));
            col_3.x = _e31.x;
            col_3.y = _e31.y;
            col_3.z = _e31.z;
        }
    }
    let _e38 = brightness_1;
    if (_e38 != 0f) {
        {
            let _e41 = col_3;
            let _e43 = col_3;
            let _e46 = brightness_1;
            let _e48 = (_e43.xyz * (1f + _e46));
            col_3.x = _e48.x;
            col_3.y = _e48.y;
            col_3.z = _e48.z;
        }
    }
    let _e55 = gamma_2;
    if (_e55 != 0f) {
        {
            let _e59 = gamma_2;
            p_3 = pow(2f, -(_e59));
            let _e64 = col_3;
            let _e66 = p_3;
            col_3.x = pow(_e64.x, _e66);
            let _e69 = col_3;
            let _e71 = p_3;
            col_3.y = pow(_e69.y, _e71);
            let _e74 = col_3;
            let _e76 = p_3;
            col_3.z = pow(_e74.z, _e76);
        }
    }
    let _e78 = contrast_1;
    if (_e78 != 0f) {
        {
            let _e81 = contrast_1;
            if (abs(_e81) > 1f) {
                let _e85 = contrast_1;
                let _e87 = contrast_1;
                local_2 = (sign(_e85) * pow(abs(_e87), 2f));
            } else {
                let _e92 = contrast_1;
                local_2 = _e92;
            }
            let _e94 = local_2;
            c = _e94;
            let _e96 = col_3;
            let _e98 = col_3;
            let _e103 = c;
            let _e107 = (((_e98.xyz - vec3(0.5f)) * _e103) + vec3(0.5f));
            col_3.x = _e107.x;
            col_3.y = _e107.y;
            col_3.z = _e107.z;
        }
    }
    let _e114 = saturation_1;
    let _e117 = hue_1;
    requireHsl = ((_e114 != 0f) || (_e117 != 0f));
    let _e122 = requireHsl;
    if _e122 {
        {
            let _e123 = col_3;
            let _e124 = rgbToHsl(_e123);
            hsl = _e124;
            let _e130 = hsl.y;
            let _e132 = saturation_1;
            hsl[1i] = clamp((_e130 * (1f + _e132)), 0f, 1f);
            let _e142 = hsl.x;
            let _e143 = hue_1;
            hsl[0i] = (_e142 + _e143);
            let _e145 = hsl;
            let _e146 = hslToRgb(_e145);
            col_3 = _e146;
        }
    }
    let _e147 = tint_3;
    if (_e147.w != 0f) {
        {
            let _e151 = col_3;
            let _e152 = tint_3;
            let _e153 = tintColor(_e151, _e152);
            col_3 = _e153;
        }
    }
    let _e154 = col_3;
    return _e154;
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

fn adjustHSLuv(pos: vec2<f32>, outPos: vec2<f32>, brightness_2: f32, contrast_2: f32, luminosity_2: f32, gamma_3: f32, saturation_2: f32, hue_2: f32, tint_4: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var brightness_3: f32;
    var contrast_3: f32;
    var luminosity_3: f32;
    var gamma_4: f32;
    var saturation_3: f32;
    var hue_3: f32;
    var tint_5: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var col_4: vec4<f32>;
    var d: f32;
    var outCol: vec4<f32>;
    var k: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    brightness_3 = brightness_2;
    contrast_3 = contrast_2;
    luminosity_3 = luminosity_2;
    gamma_4 = gamma_3;
    saturation_3 = saturation_2;
    hue_3 = hue_2;
    tint_5 = tint_4;
    modelTransform_1 = modelTransform;
    let _e26 = pos_1;
    let _e30 = global.U[0];
    let _e33 = pos_1;
    let _e42 = textureSample(t_source, samp, ((vec2<f32>((_e26.x / _e30.x), _e33.y) / vec2(2f)) + vec2(0.5f)));
    col_4 = _e42;
    let _e44 = modelTransform_1;
    let _e46 = pos_1;
    let _e47 = tf(_naga_inverse_3x3_f32(_e44), _e46);
    d = length(_e47);
    let _e50 = d;
    if (_e50 >= 1f) {
        let _e53 = col_4;
        return _e53;
    }
    let _e54 = col_4;
    let _e55 = brightness_3;
    let _e56 = contrast_3;
    let _e57 = luminosity_3;
    let _e58 = gamma_4;
    let _e59 = saturation_3;
    let _e60 = hue_3;
    let _e61 = tint_5;
    let _e62 = adjustColor(_e54, _e55, _e56, _e57, _e58, _e59, _e60, _e61);
    outCol = _e62;
    let _e66 = d;
    k = smoothstep(1f, 0.5f, _e66);
    let _e69 = col_4;
    let _e70 = outCol;
    let _e71 = k;
    return mix(_e69, _e70, vec4(_e71));
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
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e101 = global.U[14];
    let _e102 = _e101.xyz;
    let _e116 = adjustHSLuv((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, _e90, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
