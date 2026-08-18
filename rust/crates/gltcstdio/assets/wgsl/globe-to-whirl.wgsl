struct Params {
    U: array<vec4<f32>, 20>,
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

fn measure(v: vec2<f32>, power: f32) -> f32 {
    var v_1: vec2<f32>;
    var power_1: f32;
    var low: f32;
    var high: f32;
    var local: f32;

    v_1 = v;
    power_1 = power;
    let _e10 = v_1;
    let _e13 = v_1;
    low = min(abs(_e10.x), abs(_e13.y));
    let _e18 = v_1;
    let _e21 = v_1;
    high = max(abs(_e18.x), abs(_e21.y));
    let _e26 = high;
    if (_e26 == 0f) {
        local = 0f;
    } else {
        let _e30 = high;
        let _e32 = low;
        let _e33 = high;
        let _e35 = power_1;
        let _e39 = power_1;
        local = (_e30 * pow((1f + pow((_e32 / _e33), _e35)), (1f / _e39)));
    }
    let _e44 = local;
    return _e44;
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

fn globe_to_whirl(uv: vec2<f32>, outPos: vec2<f32>, time: f32, globeIntensity: f32, sourceDim: vec2<f32>, power_2: f32, shadows: f32, colorShadow: vec4<f32>, whirlIntensity: f32, unwind: f32, highFreqColor: vec4<f32>, modelTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var time_1: f32;
    var globeIntensity_1: f32;
    var sourceDim_1: vec2<f32>;
    var power_3: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var whirlIntensity_1: f32;
    var unwind_1: f32;
    var highFreqColor_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var ratio: f32;
    var local_1: f32;
    var ratioScale: f32;
    var u_2: vec2<f32>;
    var v_2: vec2<f32>;
    var dCircle: f32;
    var dShape: f32;
    var d: f32;
    var kShadow: f32 = 0f;
    var darken: f32 = 0f;
    var hh: f32;
    var globeDilation: f32 = 1f;
    var h: f32;
    var s: f32;
    var globeUV: vec2<f32>;
    var dWhirl: f32;
    var bal: f32;
    var dangle: f32;
    var ca: f32;
    var sa: f32;
    var whirlUV: vec2<f32>;
    var blended: vec2<f32>;
    var vs: vec2<f32>;
    var ds: f32;
    var dRot: f32;
    var sHeight: f32;
    var sSlope: f32;
    var vs_1: vec2<f32>;
    var ds_1: f32;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    time_1 = time;
    globeIntensity_1 = globeIntensity;
    sourceDim_1 = sourceDim;
    power_3 = power_2;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    whirlIntensity_1 = whirlIntensity;
    unwind_1 = unwind;
    highFreqColor_1 = highFreqColor;
    modelTransform_1 = modelTransform;
    shadowTransform_1 = shadowTransform;
    let _e32 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e32);
    let _e35 = sourceDim_1;
    let _e37 = sourceDim_1;
    ratio = (_e35.x / _e37.y);
    let _e41 = ratio;
    if (_e41 < 1f) {
        let _e45 = ratio;
        let _e48 = time_1;
        local_1 = mix((1f / _e45), 1f, _e48);
    } else {
        local_1 = 1f;
    }
    let _e52 = local_1;
    ratioScale = _e52;
    let _e54 = uv_1;
    let _e55 = ratioScale;
    u_2 = (_e54 * _e55);
    let _e58 = t;
    let _e59 = u_2;
    let _e60 = tf(_e58, _e59);
    v_2 = _e60;
    let _e62 = v_2;
    dCircle = length(_e62);
    let _e65 = v_2;
    let _e66 = power_3;
    let _e67 = measure(_e65, _e66);
    dShape = _e67;
    let _e69 = dShape;
    let _e70 = dCircle;
    let _e71 = time_1;
    d = mix(_e69, _e70, _e71);
    let _e78 = d;
    if (_e78 < 1f) {
        {
            let _e82 = d;
            let _e83 = d;
            hh = sqrt((1f - (_e82 * _e83)));
            let _e90 = hh;
            if (_e90 != 0f) {
                {
                    let _e94 = hh;
                    h = (1f + _e94);
                    let _e97 = d;
                    let _e99 = globeIntensity_1;
                    let _e101 = hh;
                    s = ((-(_e97) * _e99) / _e101);
                    let _e105 = h;
                    let _e106 = s;
                    let _e108 = d;
                    globeDilation = (1f + ((_e105 * _e106) / _e108));
                }
            }
            let _e111 = globeDilation;
            let _e112 = v_2;
            globeUV = (_e111 * _e112);
            let _e115 = dCircle;
            dWhirl = _e115;
            let _e117 = unwind_1;
            bal = _e117;
            let _e119 = bal;
            if (_e119 != 0.5f) {
                {
                    let _e122 = bal;
                    let _e125 = dWhirl;
                    let _e126 = bal;
                    if ((_e122 == 1f) || (_e125 < _e126)) {
                        {
                            let _e130 = dWhirl;
                            let _e132 = bal;
                            dWhirl = ((0.5f * _e130) / _e132);
                        }
                    } else {
                        {
                            let _e136 = dWhirl;
                            let _e137 = bal;
                            let _e140 = bal;
                            dWhirl = (0.5f * (1f - ((_e136 - _e137) / (1f - _e140))));
                        }
                    }
                }
            }
            let _e145 = whirlIntensity_1;
            let _e149 = dWhirl;
            dangle = ((_e145 * 10f) * (1f - cos(((_e149 * 2f) * 3.1415927f))));
            let _e158 = dangle;
            ca = cos(_e158);
            let _e161 = dangle;
            sa = sin(_e161);
            let _e164 = ca;
            let _e165 = v_2;
            let _e168 = sa;
            let _e169 = v_2;
            let _e173 = ca;
            let _e174 = v_2;
            let _e177 = sa;
            let _e178 = v_2;
            whirlUV = vec2<f32>(((_e164 * _e165.x) - (_e168 * _e169.y)), ((_e173 * _e174.y) + (_e177 * _e178.x)));
            let _e184 = globeUV;
            let _e185 = whirlUV;
            let _e186 = time_1;
            blended = mix(_e184, _e185, vec2(_e186));
            let _e190 = modelTransform_1;
            let _e191 = blended;
            let _e192 = tf(_e190, _e191);
            u_2 = _e192;
            let _e193 = shadows_1;
            if (_e193 < 0f) {
                {
                    let _e196 = shadowTransform_1;
                    let _e198 = v_2;
                    let _e199 = tf(_naga_inverse_3x3_f32(_e196), _e198);
                    vs = _e199;
                    let _e201 = vs;
                    let _e202 = power_3;
                    let _e203 = measure(_e201, _e202);
                    ds = _e203;
                    let _e206 = time_1;
                    let _e208 = shadows_1;
                    let _e210 = ds;
                    kShadow = ((1f - _e206) * smoothstep(_e208, 0f, (_e210 - 1f)));
                }
            }
            let _e215 = highFreqColor_1;
            if (_e215.w != 0f) {
                {
                    let _e219 = whirlUV;
                    let _e222 = whirlIntensity_1;
                    dRot = length((_e219 * vec2<f32>(min(1.5f, (1f + abs((_e222 * 3f)))), 1f)));
                    let _e233 = highFreqColor_1;
                    sHeight = (_e233.w * 4f);
                    let _e239 = highFreqColor_1;
                    sSlope = (1f + (_e239.w * 3f));
                    let _e245 = sHeight;
                    let _e246 = dRot;
                    let _e247 = sSlope;
                    let _e253 = time_1;
                    darken = (clamp((_e245 - (_e246 * _e247)), 0f, 1f) * _e253);
                }
            }
        }
    } else {
        {
            let _e255 = shadows_1;
            if (_e255 > 0f) {
                {
                    let _e258 = shadowTransform_1;
                    let _e260 = v_2;
                    let _e261 = tf(_naga_inverse_3x3_f32(_e258), _e260);
                    vs_1 = _e261;
                    let _e263 = vs_1;
                    let _e264 = power_3;
                    let _e265 = measure(_e263, _e264);
                    ds_1 = _e265;
                    let _e268 = time_1;
                    let _e270 = shadows_1;
                    let _e272 = ds_1;
                    kShadow = ((1f - _e268) * smoothstep(_e270, 0f, (_e272 - 1f)));
                }
            }
        }
    }
    let _e277 = u_2;
    let _e278 = ratioScale;
    u_2 = (_e277 / vec2(_e278));
    let _e281 = u_2;
    let _e285 = global.U[0];
    let _e288 = u_2;
    let _e297 = _mirror_wrap(((vec2<f32>((_e281.x / _e285.x), _e288.y) / vec2(2f)) + vec2(0.5f)));
    let _e298 = textureSample(t_source, samp, _e297);
    col = _e298;
    let _e300 = col;
    let _e301 = colorShadow_1;
    let _e302 = _e301.xyz;
    let _e303 = col;
    let _e309 = kShadow;
    let _e310 = colorShadow_1;
    col = mix(_e300, vec4<f32>(_e302.x, _e302.y, _e302.z, _e303.w), vec4((_e309 * _e310.w)));
    let _e315 = col;
    let _e316 = highFreqColor_1;
    let _e317 = _e316.xyz;
    let _e318 = col;
    let _e324 = darken;
    col = mix(_e315, vec4<f32>(_e317.x, _e317.y, _e317.z, _e318.w), vec4(_e324));
    let _e327 = col;
    return _e327;
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
    let _e70 = global.U[7];
    let _e74 = global.U[4];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e93 = global.U[12];
    let _e97 = global.U[13];
    let _e100 = global.U[14];
    let _e101 = _e100.xyz;
    let _e104 = global.U[15];
    let _e105 = _e104.xyz;
    let _e108 = global.U[16];
    let _e109 = _e108.xyz;
    let _e125 = global.U[17];
    let _e126 = _e125.xyz;
    let _e129 = global.U[18];
    let _e130 = _e129.xyz;
    let _e133 = global.U[19];
    let _e134 = _e133.xyz;
    let _e148 = globe_to_whirl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.xy, _e78.x, _e82.x, _e86, _e89.x, _e93.x, _e97, mat3x3<f32>(vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z)), mat3x3<f32>(vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z)));
    fragColor = _e148;
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
