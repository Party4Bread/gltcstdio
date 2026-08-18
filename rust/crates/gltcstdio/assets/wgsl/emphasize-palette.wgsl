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

fn colorize(sourceColor: vec4<f32>, targetColor: vec4<f32>, saturation: f32) -> vec4<f32> {
    var sourceColor_1: vec4<f32>;
    var targetColor_1: vec4<f32>;
    var saturation_1: f32;
    var hslTarget: vec4<f32>;
    var hslSource: vec4<f32>;
    var local_2: f32;
    var gamma: f32;

    sourceColor_1 = sourceColor;
    targetColor_1 = targetColor;
    saturation_1 = saturation;
    let _e13 = targetColor_1;
    let _e14 = rgbToHsl(_e13);
    hslTarget = _e14;
    let _e16 = sourceColor_1;
    let _e17 = rgbToHsl(_e16);
    hslSource = _e17;
    let _e20 = hslTarget;
    hslSource.x = _e20.x;
    let _e23 = hslTarget;
    if (_e23.y == 0f) {
        local_2 = 0f;
    } else {
        let _e28 = hslTarget;
        let _e30 = saturation_1;
        let _e32 = hslSource;
        let _e35 = saturation_1;
        local_2 = ((_e28.y * _e30) + (_e32.y * (1f - _e35)));
    }
    let _e40 = local_2;
    hslSource.y = _e40;
    let _e43 = hslTarget;
    gamma = pow(2f, ((0.5f - _e43.z) * 2f));
    let _e51 = hslSource;
    let _e53 = gamma;
    hslSource.z = pow(_e51.z, _e53);
    let _e55 = hslSource;
    let _e56 = hslToRgb(_e55);
    return _e56;
}

fn emphasizePalette(pos: vec2<f32>, outPos: vec2<f32>, paletteDim: vec2<f32>, intensity: f32, saturation_2: f32, tolerance: f32, hardness: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var paletteDim_1: vec2<f32>;
    var intensity_1: f32;
    var saturation_3: f32;
    var tolerance_1: f32;
    var hardness_1: f32;
    var inc_2: vec4<f32>;
    var total: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var totalWeight: f32 = 0f;
    var separation: f32;
    var k0_: f32 = 1f;
    var n: i32;
    var tol: f32;
    var i: i32 = 0i;
    var target_: vec4<f32>;
    var contribColor: vec4<f32>;
    var k: f32;
    var dist: f32;
    var local_3: vec4<f32>;
    var rgb: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    paletteDim_1 = paletteDim;
    intensity_1 = intensity;
    saturation_3 = saturation_2;
    tolerance_1 = tolerance;
    hardness_1 = hardness;
    let _e21 = pos_1;
    let _e25 = global.U[0];
    let _e28 = pos_1;
    let _e37 = textureSample(t_source, samp, ((vec2<f32>((_e21.x / _e25.x), _e28.y) / vec2(2f)) + vec2(0.5f)));
    inc_2 = _e37;
    let _e48 = hardness_1;
    separation = (0f + (_e48 * 10f));
    let _e55 = paletteDim_1;
    n = i32(_e55.x);
    let _e59 = tolerance_1;
    tol = (_e59 * 2.5f);
    loop {
        let _e65 = i;
        let _e66 = n;
        if !((_e65 < _e66)) {
            break;
        }
        {
            let _e72 = i;
            let _e76 = textureLoad(t_palette, vec2<i32>(_e72, 0i), 0i);
            target_ = _e76;
            contribColor = vec4<f32>(0f, 0f, 0f, 1f);
            k = 0f;
            let _e86 = inc_2;
            let _e87 = target_;
            dist = length((_e86 - _e87).xyz);
            let _e92 = dist;
            let _e93 = tol;
            if (_e92 < _e93) {
                {
                    let _e95 = inc_2;
                    let _e96 = target_;
                    let _e97 = saturation_3;
                    let _e98 = colorize(_e95, _e96, _e97);
                    let _e99 = _e98.xyz;
                    let _e100 = inc_2;
                    contribColor = vec4<f32>(_e99.x, _e99.y, _e99.z, _e100.w);
                    let _e107 = dist;
                    let _e108 = tol;
                    k = (1f - (_e107 / _e108));
                }
            }
            let _e112 = k0_;
            let _e113 = k;
            k0_ = max(0f, (_e112 - _e113));
            let _e116 = k;
            let _e117 = separation;
            k = pow(_e116, (_e117 + 0.5f));
            let _e121 = total;
            let _e122 = k;
            let _e123 = contribColor;
            total = (_e121 + (_e122 * _e123));
            let _e126 = totalWeight;
            let _e127 = k;
            totalWeight = (_e126 + _e127);
        }
        continuing {
            let _e69 = i;
            i = (_e69 + 1i);
        }
    }
    let _e129 = k0_;
    if (_e129 == 1f) {
        let _e132 = inc_2;
        local_3 = _e132;
    } else {
        let _e133 = total;
        let _e134 = totalWeight;
        let _e137 = inc_2;
        let _e138 = k0_;
        local_3 = mix((_e133 / vec4(_e134)), _e137, vec4(_e138));
    }
    let _e142 = local_3;
    rgb = _e142;
    let _e144 = inc_2;
    let _e146 = rgb;
    let _e148 = intensity_1;
    let _e150 = mix(_e144.xyz, _e146.xyz, vec3(_e148));
    let _e151 = inc_2;
    return vec4<f32>(_e150.x, _e150.y, _e150.z, _e151.w);
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
    let _e85 = emphasizePalette((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.x, _e75.x, _e79.x, _e83.x);
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
