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

fn alphaBlend(a: vec4<f32>, b: vec4<f32>) -> vec4<f32> {
    var a_1: vec4<f32>;
    var b_1: vec4<f32>;
    var sumA: f32;
    var k1_: f32;
    var k2_: f32;
    var outc: vec4<f32>;

    a_1 = a;
    b_1 = b;
    let _e10 = a_1;
    let _e12 = b_1;
    sumA = (_e10.w + _e12.w);
    let _e16 = sumA;
    if (_e16 == 0f) {
        let _e19 = a_1;
        return _e19;
    }
    let _e20 = a_1;
    let _e22 = sumA;
    k1_ = (_e20.w / _e22);
    let _e25 = b_1;
    let _e27 = sumA;
    k2_ = (_e25.w / _e27);
    let _e30 = k1_;
    let _e31 = a_1;
    let _e33 = k2_;
    let _e34 = b_1;
    outc = ((_e30 * _e31) + (_e33 * _e34));
    let _e41 = a_1;
    let _e45 = b_1;
    outc.w = (1f - ((1f - _e41.w) * (1f - _e45.w)));
    let _e50 = outc;
    return _e50;
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
    var b_2: f32;
    var outc_1: vec4<f32>;

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
    b_2 = max(0f, _e74);
    let _e79 = r;
    outc_1.x = min(_e79, 1f);
    let _e83 = g;
    outc_1.y = min(_e83, 1f);
    let _e87 = b_2;
    outc_1.z = min(_e87, 1f);
    let _e91 = inc_1;
    outc_1.w = _e91.w;
    let _e93 = outc_1;
    return _e93;
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

fn directionalLight(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, lightAngle: f32, blur: f32, color: vec4<f32>, variability: f32, colorVariability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var lightAngle_1: f32;
    var blur_1: f32;
    var color_1: vec4<f32>;
    var variability_1: f32;
    var colorVariability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inc_2: vec4<f32>;
    var t: vec2<f32>;
    var lightDistance: f32;
    var angleSize: f32;
    var baseColor: vec4<f32>;
    var lightX: f32;
    var lightY: f32 = 0f;
    var light: vec2<f32>;
    var d: f32;
    var dx: f32;
    var dy: f32;
    var delta: vec2<f32>;
    var col: vec4<f32> = vec4(0f);
    var inLight: bool = false;
    var angle: f32;
    var N: i32;
    var i: i32 = 0i;
    var subAngleSize: f32;
    var subPhase: f32;
    var var_: vec2<f32>;
    var local_2: f32;
    var sizeVar: f32;
    var subIntensity: f32;
    var deltaAngle: f32;
    var newColor: vec4<f32>;
    var kk: f32;
    var distFromBorder: f32;
    var blurDist: f32;
    var hsl: vec4<f32>;
    var outc_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    lightAngle_1 = lightAngle;
    blur_1 = blur;
    color_1 = color;
    variability_1 = variability;
    colorVariability_1 = colorVariability;
    modelTransform_1 = modelTransform;
    let _e26 = uv_1;
    let _e30 = global.U[0];
    let _e33 = uv_1;
    let _e42 = textureSample(t_source, samp, ((vec2<f32>((_e26.x / _e30.x), _e33.y) / vec2(2f)) + vec2(0.5f)));
    inc_2 = _e42;
    let _e44 = modelTransform_1;
    let _e46 = uv_1;
    let _e47 = tf(_naga_inverse_3x3_f32(_e44), _e46);
    t = _e47;
    let _e50 = sourceDim_1;
    let _e52 = sourceDim_1;
    lightDistance = (1f + (_e50.x / _e52.y));
    let _e57 = lightAngle_1;
    angleSize = _e57;
    let _e59 = color_1;
    baseColor = _e59;
    let _e61 = lightDistance;
    lightX = -(_e61);
    let _e66 = lightX;
    let _e67 = lightY;
    light = vec2<f32>(_e66, _e67);
    let _e70 = light;
    d = length(_e70);
    let _e73 = t;
    let _e75 = lightX;
    dx = (_e73.x - _e75);
    let _e78 = t;
    let _e80 = lightY;
    dy = (_e78.y - _e80);
    let _e83 = dx;
    let _e84 = dy;
    delta = vec2<f32>(_e83, _e84);
    let _e92 = delta;
    let _e94 = delta;
    angle = atan2(_e92.y, _e94.x);
    let _e99 = variability_1;
    N = (1i + i32(ceil((_e99 * 5f))));
    loop {
        let _e108 = i;
        let _e109 = N;
        if !((_e108 < _e109)) {
            break;
        }
        {
            let _e115 = angleSize;
            let _e116 = N;
            subAngleSize = (_e115 / f32(_e116));
            let _e120 = angleSize;
            let _e124 = subAngleSize;
            let _e128 = subAngleSize;
            let _e129 = i;
            subPhase = (((-(_e120) / 2f) + (_e124 / 2f)) + (_e128 * f32(_e129)));
            let _e134 = N;
            let _e136 = i;
            let _e139 = rand2_(vec2<f32>(f32(_e134), f32(_e136)));
            var_ = _e139;
            let _e141 = subPhase;
            let _e142 = subAngleSize;
            let _e143 = var_;
            let _e146 = variability_1;
            subPhase = (_e141 + ((_e142 * _e143.y) * _e146));
            let _e149 = var_;
            if (_e149.x < 0f) {
                let _e154 = var_;
                let _e156 = variability_1;
                local_2 = (1f + ((_e154.x * _e156) * 0.5f));
            } else {
                let _e162 = var_;
                let _e164 = variability_1;
                local_2 = (1f + (_e162.x * _e164));
            }
            let _e168 = local_2;
            sizeVar = _e168;
            let _e170 = subAngleSize;
            let _e171 = sizeVar;
            subAngleSize = (_e170 * _e171);
            let _e173 = intensity_1;
            subIntensity = (_e173 * 100f);
            let _e177 = angle;
            let _e178 = subPhase;
            deltaAngle = (_e177 - _e178);
            let _e181 = deltaAngle;
            if (_e181 < -3.1415927f) {
                let _e185 = deltaAngle;
                deltaAngle = (_e185 + 6.2831855f);
            } else {
                let _e190 = deltaAngle;
                if (_e190 > 3.1415927f) {
                    let _e193 = deltaAngle;
                    deltaAngle = (_e193 - 6.2831855f);
                }
            }
            let _e198 = deltaAngle;
            let _e199 = subAngleSize;
            let _e204 = deltaAngle;
            let _e205 = subAngleSize;
            if ((_e198 > (-(_e199) / 2f)) && (_e204 <= (_e205 / 2f))) {
                {
                    inLight = true;
                    let _e211 = baseColor;
                    newColor = _e211;
                    kk = 1f;
                    let _e215 = blur_1;
                    if (_e215 > 0f) {
                        {
                            let _e218 = subAngleSize;
                            let _e221 = deltaAngle;
                            let _e224 = subAngleSize;
                            distFromBorder = ((((_e218 / 2f) - abs(_e221)) / _e224) * 2f);
                            let _e229 = blur_1;
                            blurDist = _e229;
                            let _e231 = distFromBorder;
                            let _e232 = blurDist;
                            if (_e231 < _e232) {
                                {
                                    let _e234 = distFromBorder;
                                    let _e235 = blurDist;
                                    kk = (_e234 / _e235);
                                }
                            }
                        }
                    }
                    let _e237 = colorVariability_1;
                    if (_e237 > 0f) {
                        {
                            let _e240 = color_1;
                            let _e241 = rgbToHsl(_e240);
                            hsl = _e241;
                            let _e247 = hsl.x;
                            let _e248 = var_;
                            let _e250 = colorVariability_1;
                            hsl[0i] = (_e247 + (_e248.y * _e250));
                            let _e253 = hsl;
                            let _e254 = hslToRgb(_e253);
                            newColor = _e254;
                        }
                    }
                    let _e256 = subIntensity;
                    let _e259 = kk;
                    newColor.w = ((_e256 * 0.01f) * _e259);
                    let _e261 = col;
                    let _e262 = newColor;
                    let _e263 = alphaBlend(_e261, _e262);
                    color_1 = _e263;
                }
            }
        }
        continuing {
            let _e112 = i;
            i = (_e112 + 1i);
        }
    }
    let _e264 = inLight;
    if _e264 {
        {
            let _e265 = inc_2;
            let _e266 = color_1;
            let _e267 = color_1;
            outc_2 = (_e265 + (_e266 * _e267.w));
            outc_2.w = 1f;
            let _e274 = outc_2;
            return _e274;
        }
    } else {
        {
            let _e275 = inc_2;
            return _e275;
        }
    }
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e89 = global.U[11];
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e101 = global.U[14];
    let _e102 = _e101.xyz;
    let _e116 = directionalLight((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, _e82, _e85.x, _e89.x, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
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
