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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

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

fn iridizeGetChannel(select: i32, rgb: vec4<f32>, hsl: vec4<f32>) -> f32 {
    var select_1: i32;
    var rgb_1: vec4<f32>;
    var hsl_1: vec4<f32>;

    select_1 = select;
    rgb_1 = rgb;
    hsl_1 = hsl;
    let _e13 = select_1;
    if (_e13 == 0i) {
        let _e16 = rgb_1;
        return _e16.x;
    } else {
        let _e18 = select_1;
        if (_e18 == 1i) {
            let _e21 = rgb_1;
            return _e21.y;
        } else {
            let _e23 = select_1;
            if (_e23 == 2i) {
                let _e26 = rgb_1;
                return _e26.z;
            } else {
                let _e28 = select_1;
                if (_e28 == 3i) {
                    let _e31 = hsl_1;
                    return _e31.x;
                } else {
                    let _e33 = select_1;
                    if (_e33 == 4i) {
                        let _e36 = hsl_1;
                        return _e36.y;
                    } else {
                        let _e38 = select_1;
                        if (_e38 == 5i) {
                            let _e41 = hsl_1;
                            return _e41.z;
                        } else {
                            let _e43 = select_1;
                            if (_e43 == 6i) {
                                let _e47 = rgb_1;
                                return (1f - _e47.x);
                            } else {
                                let _e50 = select_1;
                                if (_e50 == 7i) {
                                    let _e54 = rgb_1;
                                    return (1f - _e54.y);
                                } else {
                                    let _e57 = select_1;
                                    if (_e57 == 8i) {
                                        let _e61 = rgb_1;
                                        return (1f - _e61.z);
                                    } else {
                                        let _e64 = select_1;
                                        if (_e64 == 9i) {
                                            let _e68 = hsl_1;
                                            return (1f - _e68.x);
                                        } else {
                                            let _e71 = select_1;
                                            if (_e71 == 10i) {
                                                let _e75 = hsl_1;
                                                return (1f - _e75.y);
                                            } else {
                                                let _e79 = hsl_1;
                                                return (1f - _e79.z);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
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

fn iridizeSwap(rgb_2: vec4<f32>, mode: f32) -> vec4<f32> {
    var rgb_3: vec4<f32>;
    var mode_1: f32;
    var coding: f32;
    var toHsl: bool;
    var hsl_2: vec4<f32>;
    var rChannel: i32;
    var gChannel: i32;
    var bChannel: i32;
    var local_2: f32;
    var color: vec4<f32>;
    var local_3: vec4<f32>;

    rgb_3 = rgb_2;
    mode_1 = mode;
    let _e11 = mode_1;
    coding = floor(_e11);
    let _e14 = coding;
    toHsl = (_e14 >= 1728f);
    let _e18 = toHsl;
    if _e18 {
        let _e19 = coding;
        coding = (_e19 - (floor((_e19 / 1728f)) * 1728f));
    }
    let _e25 = rgb_3;
    let _e26 = rgbToHsl(_e25);
    hsl_2 = _e26;
    let _e29 = hsl_2;
    hsl_2.x = (_e29.x / 360f);
    let _e33 = coding;
    rChannel = i32((_e33 - (floor((_e33 / 12f)) * 12f)));
    let _e41 = coding;
    let _e43 = (_e41 / 12f);
    gChannel = i32((_e43 - (floor((_e43 / 12f)) * 12f)));
    let _e51 = coding;
    let _e53 = (_e51 / 144f);
    bChannel = i32((_e53 - (floor((_e53 / 12f)) * 12f)));
    let _e61 = rChannel;
    let _e62 = rgb_3;
    let _e63 = hsl_2;
    let _e64 = iridizeGetChannel(_e61, _e62, _e63);
    let _e65 = toHsl;
    if _e65 {
        local_2 = 360f;
    } else {
        local_2 = 1f;
    }
    let _e69 = local_2;
    let _e71 = gChannel;
    let _e72 = rgb_3;
    let _e73 = hsl_2;
    let _e74 = iridizeGetChannel(_e71, _e72, _e73);
    let _e75 = bChannel;
    let _e76 = rgb_3;
    let _e77 = hsl_2;
    let _e78 = iridizeGetChannel(_e75, _e76, _e77);
    let _e79 = rgb_3;
    color = vec4<f32>((_e64 * _e69), _e74, _e78, _e79.w);
    let _e83 = toHsl;
    if _e83 {
        let _e84 = color;
        let _e85 = hslToRgb(_e84);
        local_3 = _e85;
    } else {
        let _e86 = color;
        local_3 = _e86;
    }
    let _e88 = local_3;
    return _e88;
}

fn iridizeModesGL(pos: vec2<f32>, outPos: vec2<f32>, source2_specified: i32, intensity: f32, balance: f32, mode_2: f32, mode2_: f32, backgroundOnly: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source2_specified_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var mode_3: f32;
    var mode2_1: f32;
    var backgroundOnly_1: f32;
    var rgb_4: vec4<f32>;
    var local_4: vec4<f32>;
    var mapRgb: vec4<f32>;
    var hsl_3: vec4<f32>;
    var mapHsl: vec4<f32>;
    var saturation: f32;
    var satBal: f32;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source2_specified_1 = source2_specified;
    intensity_1 = intensity;
    balance_1 = balance;
    mode_3 = mode_2;
    mode2_1 = mode2_;
    backgroundOnly_1 = backgroundOnly;
    let _e23 = pos_1;
    let _e27 = global.U[0];
    let _e30 = pos_1;
    let _e39 = textureSample(t_source, samp, ((vec2<f32>((_e23.x / _e27.x), _e30.y) / vec2(2f)) + vec2(0.5f)));
    rgb_4 = _e39;
    let _e41 = source2_specified_1;
    if (_e41 == 0i) {
        let _e44 = rgb_4;
        local_4 = _e44;
    } else {
        let _e45 = pos_1;
        let _e49 = global.U[0];
        let _e52 = pos_1;
        let _e61 = textureSample(t_source2_, samp, ((vec2<f32>((_e45.x / _e49.x), _e52.y) / vec2(2f)) + vec2(0.5f)));
        local_4 = _e61;
    }
    let _e63 = local_4;
    mapRgb = _e63;
    let _e65 = mode_3;
    if (_e65 >= 0f) {
        {
            let _e68 = rgb_4;
            let _e69 = mode_3;
            let _e70 = iridizeSwap(_e68, _e69);
            rgb_4 = _e70;
            let _e71 = mapRgb;
            let _e72 = mode_3;
            let _e73 = iridizeSwap(_e71, _e72);
            mapRgb = _e73;
        }
    }
    let _e74 = backgroundOnly_1;
    if (_e74 >= 0.5f) {
        let _e77 = rgb_4;
        return _e77;
    }
    let _e78 = rgb_4;
    let _e79 = rgbToHsl(_e78);
    hsl_3 = _e79;
    let _e81 = mapRgb;
    let _e82 = rgbToHsl(_e81);
    mapHsl = _e82;
    let _e84 = mapHsl;
    saturation = _e84.y;
    let _e88 = balance_1;
    satBal = (0.5f - (_e88 * 0.5f));
    let _e94 = saturation;
    let _e97 = saturation;
    let _e98 = satBal;
    hsl_3.y = (_e94 * smoothstep(0f, 1f, (((_e97 - _e98) * 4f) + 0.5f)));
    let _e107 = mapHsl;
    let _e110 = saturation;
    let _e111 = intensity_1;
    hsl_3.x = (_e107.x * (1f + ((_e110 * _e111) * 40f)));
    let _e117 = hsl_3;
    let _e118 = hslToRgb(_e117);
    outCol = _e118;
    let _e120 = mode2_1;
    if (_e120 >= 0f) {
        {
            let _e123 = outCol;
            let _e124 = mode2_1;
            let _e125 = iridizeSwap(_e123, _e124);
            outCol = _e125;
        }
    }
    let _e126 = outCol;
    return _e126;
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
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e90 = iridizeModesGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, _e84.x, _e88.x);
    fragColor = _e90;
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
