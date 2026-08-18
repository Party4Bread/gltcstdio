struct Params {
    U: array<vec4<f32>, 10>,
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
var t_palette: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e13 = h_1;
    if (_e13 < 0f) {
        let _e16 = h_1;
        h_1 = (_e16 + 1f);
    }
    let _e19 = h_1;
    if (_e19 > 1f) {
        let _e22 = h_1;
        h_1 = (_e22 - 1f);
    }
    let _e26 = h_1;
    if ((6f * _e26) < 1f) {
        {
            let _e30 = p_1;
            let _e31 = q_1;
            let _e32 = p_1;
            let _e36 = h_1;
            return (_e30 + (((_e31 - _e32) * 6f) * _e36));
        }
    }
    let _e40 = h_1;
    if ((2f * _e40) < 1f) {
        {
            let _e44 = q_1;
            return _e44;
        }
    }
    let _e46 = h_1;
    if ((3f * _e46) < 2f) {
        {
            let _e50 = p_1;
            let _e51 = q_1;
            let _e52 = p_1;
            let _e59 = h_1;
            return (_e50 + (((_e51 - _e52) * 6f) * (0.6666667f - _e59)));
        }
    }
    let _e63 = p_1;
    return _e63;
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
    let _e9 = inc_1;
    h_2 = (_e9.x - (floor((_e9.x / 360f)) * 360f));
    let _e17 = h_2;
    h_2 = (_e17 / 360f);
    let _e20 = inc_1;
    s = _e20.y;
    let _e23 = inc_1;
    l = _e23.z;
    let _e28 = l;
    if (_e28 < 0.5f) {
        let _e31 = l;
        let _e33 = s;
        q_2 = (_e31 * (1f + _e33));
    } else {
        let _e36 = l;
        let _e37 = s;
        let _e39 = s;
        let _e40 = l;
        q_2 = ((_e36 + _e37) - (_e39 * _e40));
    }
    let _e44 = l;
    let _e46 = q_2;
    p_2 = ((2f * _e44) - _e46);
    let _e50 = p_2;
    let _e51 = q_2;
    let _e52 = h_2;
    let _e57 = hueToRgb(_e50, _e51, (_e52 + 0.33333334f));
    r = max(0f, _e57);
    let _e61 = p_2;
    let _e62 = q_2;
    let _e63 = h_2;
    let _e64 = hueToRgb(_e61, _e62, _e63);
    g = max(0f, _e64);
    let _e68 = p_2;
    let _e69 = q_2;
    let _e70 = h_2;
    let _e75 = hueToRgb(_e68, _e69, (_e70 - 0.33333334f));
    b = max(0f, _e75);
    let _e80 = r;
    outc.x = min(_e80, 1f);
    let _e84 = g;
    outc.y = min(_e84, 1f);
    let _e88 = b;
    outc.z = min(_e88, 1f);
    let _e92 = inc_1;
    outc.w = _e92.w;
    let _e94 = outc;
    return _e94;
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
    let _e9 = RGB_1;
    let _e11 = RGB_1;
    if (_e9.y < _e11.z) {
        let _e14 = RGB_1;
        let _e15 = _e14.zy;
        local = vec4<f32>(_e15.x, _e15.y, -1f, 0.6666667f);
    } else {
        let _e24 = RGB_1;
        let _e25 = _e24.yz;
        local = vec4<f32>(_e25.x, _e25.y, 0f, -0.33333334f);
    }
    let _e35 = local;
    P = _e35;
    let _e37 = RGB_1;
    let _e39 = P;
    if (_e37.x < _e39.x) {
        let _e42 = P;
        let _e43 = _e42.xyw;
        let _e44 = RGB_1;
        local_1 = vec4<f32>(_e43.x, _e43.y, _e43.z, _e44.x);
    } else {
        let _e50 = RGB_1;
        let _e52 = P;
        let _e53 = _e52.yzx;
        local_1 = vec4<f32>(_e50.x, _e53.x, _e53.y, _e53.z);
    }
    let _e59 = local_1;
    Q = _e59;
    let _e61 = Q;
    let _e63 = Q;
    let _e65 = Q;
    C = (_e61.x - min(_e63.w, _e65.y));
    let _e70 = Q;
    let _e72 = Q;
    let _e76 = C;
    let _e81 = Q;
    H = abs((((_e70.w - _e72.y) / ((6f * _e76) + 0.0000000001f)) + _e81.z));
    let _e86 = H;
    let _e87 = C;
    let _e88 = Q;
    let _e90 = RGB_1;
    return vec4<f32>(_e86, _e87, _e88.x, _e90.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e9 = RGB_3;
    let _e10 = rgbToHcv(_e9);
    HCV = _e10;
    let _e12 = HCV;
    let _e14 = HCV;
    L = (_e12.z - (_e14.y * 0.5f));
    let _e20 = HCV;
    let _e23 = L;
    S = (_e20.y / ((1f - abs(((_e23 * 2f) - 1f))) + 0.000001f));
    let _e34 = HCV;
    let _e38 = S;
    let _e39 = L;
    let _e40 = RGB_3;
    return vec4<f32>((_e34.x * 360f), _e38, _e39, _e40.w);
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
    let _e11 = col_1;
    let _e12 = rgbToHsl(_e11);
    colHsl = _e12.xyz;
    let _e15 = tint_1;
    let _e16 = rgbToHsl(_e15);
    tintHsl = _e16.xyz;
    let _e21 = tintHsl;
    gamma = pow(5f, (0.5f - _e21.z));
    let _e26 = tintHsl;
    let _e27 = _e26.xy;
    let _e28 = colHsl;
    let _e30 = gamma;
    let _e32 = col_1;
    let _e37 = hslToRgb(vec4<f32>(_e27.x, _e27.y, pow(_e28.z, _e30), _e32.w));
    target_ = _e37;
    let _e39 = col_1;
    let _e40 = target_;
    let _e41 = tint_1;
    return mix(_e39, _e40, vec4(_e41.w));
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
    let _e23 = luminosity_1;
    if (_e23 != 0f) {
        {
            let _e26 = col_3;
            let _e28 = col_3;
            let _e30 = luminosity_1;
            let _e32 = (_e28.xyz + vec3(_e30));
            col_3.x = _e32.x;
            col_3.y = _e32.y;
            col_3.z = _e32.z;
        }
    }
    let _e39 = brightness_1;
    if (_e39 != 0f) {
        {
            let _e42 = col_3;
            let _e44 = col_3;
            let _e47 = brightness_1;
            let _e49 = (_e44.xyz * (1f + _e47));
            col_3.x = _e49.x;
            col_3.y = _e49.y;
            col_3.z = _e49.z;
        }
    }
    let _e56 = gamma_2;
    if (_e56 != 0f) {
        {
            let _e60 = gamma_2;
            p_3 = pow(2f, -(_e60));
            let _e65 = col_3;
            let _e67 = p_3;
            col_3.x = pow(_e65.x, _e67);
            let _e70 = col_3;
            let _e72 = p_3;
            col_3.y = pow(_e70.y, _e72);
            let _e75 = col_3;
            let _e77 = p_3;
            col_3.z = pow(_e75.z, _e77);
        }
    }
    let _e79 = contrast_1;
    if (_e79 != 0f) {
        {
            let _e82 = contrast_1;
            if (abs(_e82) > 1f) {
                let _e86 = contrast_1;
                let _e88 = contrast_1;
                local_2 = (sign(_e86) * pow(abs(_e88), 2f));
            } else {
                let _e93 = contrast_1;
                local_2 = _e93;
            }
            let _e95 = local_2;
            c = _e95;
            let _e97 = col_3;
            let _e99 = col_3;
            let _e104 = c;
            let _e108 = (((_e99.xyz - vec3(0.5f)) * _e104) + vec3(0.5f));
            col_3.x = _e108.x;
            col_3.y = _e108.y;
            col_3.z = _e108.z;
        }
    }
    let _e115 = saturation_1;
    let _e118 = hue_1;
    requireHsl = ((_e115 != 0f) || (_e118 != 0f));
    let _e123 = requireHsl;
    if _e123 {
        {
            let _e124 = col_3;
            let _e125 = rgbToHsl(_e124);
            hsl = _e125;
            let _e131 = hsl.y;
            let _e133 = saturation_1;
            hsl[1i] = clamp((_e131 * (1f + _e133)), 0f, 1f);
            let _e143 = hsl.x;
            let _e144 = hue_1;
            hsl[0i] = (_e143 + _e144);
            let _e146 = hsl;
            let _e147 = hslToRgb(_e146);
            col_3 = _e147;
        }
    }
    let _e148 = tint_3;
    if (_e148.w != 0f) {
        {
            let _e152 = col_3;
            let _e153 = tint_3;
            let _e154 = tintColor(_e152, _e153);
            col_3 = _e154;
        }
    }
    let _e155 = col_3;
    return _e155;
}

fn posterizePalette(pos: vec2<f32>, outPos: vec2<f32>, paletteDim: vec2<f32>, intensity: f32, saturation_2: f32, brightness_2: f32, hue_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var paletteDim_1: vec2<f32>;
    var intensity_1: f32;
    var saturation_3: f32;
    var brightness_3: f32;
    var hue_3: f32;
    var col_4: vec4<f32>;
    var n: i32;
    var minDist: f32 = 1000000000f;
    var bestColor: vec4<f32>;
    var i: i32 = 0i;
    var target_1: vec4<f32>;
    var dist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    paletteDim_1 = paletteDim;
    intensity_1 = intensity;
    saturation_3 = saturation_2;
    brightness_3 = brightness_2;
    hue_3 = hue_2;
    let _e21 = pos_1;
    let _e25 = global.U[0];
    let _e28 = pos_1;
    let _e37 = textureSample(t_source, samp, ((vec2<f32>((_e21.x / _e25.x), _e28.y) / vec2(2f)) + vec2(0.5f)));
    let _e38 = brightness_3;
    let _e42 = saturation_3;
    let _e43 = hue_3;
    let _e46 = adjustColor(_e37, _e38, 1f, 0f, 0f, _e42, _e43, vec4(0f));
    col_4 = _e46;
    let _e48 = paletteDim_1;
    n = i32(_e48.x);
    let _e54 = col_4;
    bestColor = _e54;
    loop {
        let _e58 = i;
        let _e59 = n;
        if !((_e58 < _e59)) {
            break;
        }
        {
            let _e65 = i;
            let _e69 = textureLoad(t_palette, vec2<i32>(_e65, 0i), 0i);
            target_1 = _e69;
            let _e71 = col_4;
            let _e72 = target_1;
            dist = length((_e71 - _e72).xyz);
            let _e77 = dist;
            let _e78 = minDist;
            if (_e77 < _e78) {
                {
                    let _e80 = dist;
                    minDist = _e80;
                    let _e81 = target_1;
                    bestColor = _e81;
                }
            }
        }
        continuing {
            let _e62 = i;
            i = (_e62 + 1i);
        }
    }
    let _e82 = col_4;
    let _e83 = bestColor;
    let _e84 = intensity_1;
    return mix(_e82, _e83, vec4(_e84));
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e85 = posterizePalette((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.x, _e75.x, _e79.x, _e83.x);
    fragColor = _e85;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
