struct Params {
    U: array<vec4<f32>, 17>,
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

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e8 = co_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = co_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return (vec2<f32>(_e32, _e33) - vec2<f32>(0.5f, 0.5f));
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

fn bokehLights(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count: i32, intensity: f32, vignetting: f32, radius: f32, radiusVariability: f32, color: vec4<f32>, variability: f32, colorVariability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var vignetting_1: f32;
    var radius_1: f32;
    var radiusVariability_1: f32;
    var color_1: vec4<f32>;
    var variability_1: f32;
    var colorVariability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inc_2: vec4<f32>;
    var u_2: vec2<f32>;
    var inLight: bool = false;
    var col: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var baseColor: vec4<f32>;
    var v: vec2<f32>;
    var closest: f32 = 1000000000f;
    var vig: f32;
    var j: i32 = -2i;
    var i: i32;
    var point: vec2<f32>;
    var randomness: vec2<f32>;
    var displace: vec2<f32>;
    var delta: vec2<f32>;
    var distance: f32;
    var local_2: f32;
    var radiusModifier: f32;
    var local_3: f32;
    var blur: f32;
    var ang: f32;
    var alpha2_: f32;
    var alpha: f32;
    var da: f32;
    var rounding: f32;
    var rad: f32;
    var rad2_: f32;
    var d2_: f32;
    var kk: f32;
    var xxx: f32;
    var kkk: f32;
    var newColor: vec4<f32>;
    var hsl: vec4<f32>;
    var outc_2: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_1 = count;
    intensity_1 = intensity;
    vignetting_1 = vignetting;
    radius_1 = radius;
    radiusVariability_1 = radiusVariability;
    color_1 = color;
    variability_1 = variability;
    colorVariability_1 = colorVariability;
    modelTransform_1 = modelTransform;
    let _e30 = uv_1;
    let _e34 = global.U[0];
    let _e37 = uv_1;
    let _e46 = textureSample(t_source, samp, ((vec2<f32>((_e30.x / _e34.x), _e37.y) / vec2(2f)) + vec2(0.5f)));
    inc_2 = _e46;
    let _e48 = modelTransform_1;
    let _e50 = uv_1;
    let _e51 = tf(_naga_inverse_3x3_f32(_e48), _e50);
    u_2 = _e51;
    let _e61 = color_1;
    baseColor = _e61;
    let _e63 = u_2;
    let _e67 = u_2;
    v = floor(vec2<f32>((_e63.x + 0.5f), (_e67.y + 0.5f)));
    let _e78 = vignetting_1;
    let _e82 = vignetting_1;
    let _e84 = uv_1;
    vig = smoothstep(mix(0.2f, 0.6f, _e78), mix(0.4f, 1.6f, _e82), length(_e84));
    let _e88 = intensity_1;
    let _e90 = vig;
    let _e92 = vignetting_1;
    intensity_1 = (_e88 * mix(1f, _e90, min(1f, (_e92 * 3f))));
    loop {
        let _e101 = j;
        if !((_e101 <= 2i)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e111 = i;
                if !((_e111 <= 2i)) {
                    break;
                }
                {
                    let _e118 = v;
                    let _e120 = i;
                    let _e123 = v;
                    let _e125 = j;
                    point = vec2<f32>((_e118.x + f32(_e120)), (_e123.y + f32(_e125)));
                    let _e130 = point;
                    let _e131 = rand2rel(_e130);
                    randomness = (_e131 * 2f);
                    let _e135 = randomness;
                    let _e136 = variability_1;
                    displace = (_e135 * _e136);
                    let _e139 = point;
                    let _e140 = displace;
                    let _e142 = u_2;
                    delta = ((_e139 + _e140) - _e142);
                    let _e145 = delta;
                    distance = length(_e145);
                    let _e148 = randomness;
                    if (_e148.x < 0f) {
                        let _e153 = randomness;
                        let _e155 = radiusVariability_1;
                        local_2 = (1f + ((_e153.x * _e155) * 0.4f));
                    } else {
                        let _e161 = randomness;
                        let _e163 = radiusVariability_1;
                        local_2 = (1f + ((_e161.x * _e163) * 2f));
                    }
                    let _e169 = local_2;
                    radiusModifier = _e169;
                    let _e171 = radiusModifier;
                    if (_e171 < 1f) {
                        let _e175 = radiusModifier;
                        local_3 = (1f / _e175);
                    } else {
                        let _e177 = radiusModifier;
                        local_3 = _e177;
                    }
                    let _e179 = local_3;
                    blur = (_e179 - 1f);
                    let _e183 = count_1;
                    let _e186 = distance;
                    if ((_e183 < 15i) && (_e186 > 0f)) {
                        {
                            let _e190 = delta;
                            let _e192 = distance;
                            ang = acos((_e190.x / _e192));
                            let _e196 = delta;
                            if (_e196.y < 0f) {
                                let _e201 = ang;
                                ang = (6.2831855f - _e201);
                            }
                            let _e204 = count_1;
                            alpha2_ = (6.2831855f / f32(_e204));
                            let _e208 = alpha2_;
                            alpha = (_e208 / 2f);
                            let _e212 = ang;
                            let _e213 = alpha2_;
                            da = (_e212 - (floor((_e212 / _e213)) * _e213));
                            let _e219 = da;
                            let _e220 = alpha;
                            if (_e219 > _e220) {
                                let _e222 = alpha2_;
                                let _e223 = da;
                                da = (_e222 - _e223);
                            }
                            let _e227 = alpha;
                            let _e228 = alpha;
                            let _e230 = alpha;
                            let _e231 = da;
                            let _e233 = alpha;
                            let _e234 = da;
                            rounding = (1f + (0.25f * ((_e227 * _e228) - ((_e230 - _e231) * (_e233 - _e234)))));
                            let _e241 = radiusModifier;
                            let _e242 = blur;
                            let _e244 = blur;
                            let _e246 = alpha;
                            let _e249 = alpha;
                            let _e250 = da;
                            let _e254 = rounding;
                            radiusModifier = (_e241 * (_e242 + ((((1f - _e244) * cos(_e246)) / cos((_e249 - _e250))) * _e254)));
                        }
                    }
                    let _e258 = radius_1;
                    let _e259 = radiusModifier;
                    rad = (_e258 * _e259);
                    let _e262 = rad;
                    let _e263 = rad;
                    rad2_ = (_e262 * _e263);
                    let _e266 = distance;
                    let _e267 = distance;
                    d2_ = (_e266 * _e267);
                    kk = 0f;
                    let _e272 = d2_;
                    let _e273 = rad2_;
                    if (_e272 < _e273) {
                        {
                            let _e275 = d2_;
                            let _e276 = rad2_;
                            kk = (_e275 / (_e276 * 0.97f));
                            let _e281 = kk;
                            let _e282 = kk;
                            kk = ((min(1f, (_e281 * _e282)) * 0.35f) + 0.65f);
                        }
                    } else {
                        let _e289 = d2_;
                        let _e291 = rad2_;
                        if (_e289 < (2f * _e291)) {
                            {
                                let _e295 = d2_;
                                let _e296 = rad2_;
                                let _e298 = rad2_;
                                kk = (1f - ((_e295 - _e296) / _e298));
                                let _e301 = kk;
                                kk = (pow(_e301, 2f) * 0.5f);
                            }
                        }
                    }
                    let _e306 = blur;
                    let _e309 = d2_;
                    let _e311 = rad2_;
                    if ((_e306 > 0f) && (_e309 < (2f * _e311))) {
                        {
                            let _e315 = blur;
                            blur = min(_e315, 1f);
                            let _e318 = d2_;
                            let _e320 = rad2_;
                            xxx = (_e318 / (2f * _e320));
                            let _e325 = xxx;
                            kkk = ((1f + cos((_e325 * 3.1415927f))) * 0.5f);
                            let _e333 = blur;
                            let _e334 = kkk;
                            let _e337 = blur;
                            let _e339 = kk;
                            kk = ((_e333 * _e334) + ((1f - _e337) * _e339));
                        }
                    }
                    let _e342 = kk;
                    if (_e342 > 0f) {
                        {
                            inLight = true;
                            let _e346 = baseColor;
                            newColor = _e346;
                            let _e348 = colorVariability_1;
                            if (_e348 > 0f) {
                                {
                                    let _e351 = color_1;
                                    let _e352 = rgbToHsl(_e351);
                                    hsl = _e352;
                                    let _e355 = hsl;
                                    let _e357 = randomness;
                                    let _e359 = colorVariability_1;
                                    hsl.x = (_e355.x + ((_e357.y * _e359) * 100f));
                                    let _e364 = hsl;
                                    let _e365 = hslToRgb(_e364);
                                    newColor = _e365;
                                }
                            }
                            let _e367 = intensity_1;
                            let _e368 = kk;
                            newColor.w = (_e367 * _e368);
                            let _e370 = col;
                            let _e371 = newColor;
                            let _e372 = alphaBlend(_e370, _e371);
                            col = _e372;
                        }
                    }
                }
                continuing {
                    let _e115 = i;
                    i = (_e115 + 1i);
                }
            }
        }
        continuing {
            let _e105 = j;
            j = (_e105 + 1i);
        }
    }
    let _e373 = inLight;
    if _e373 {
        {
            let _e374 = inc_2;
            let _e375 = col;
            let _e376 = col;
            outc_2 = (_e374 + (_e375 * _e376.w));
            outc_2.w = 1f;
            let _e383 = outc_2;
            return _e383;
        }
    } else {
        {
            let _e384 = inc_2;
            return _e384;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e94 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e110 = global.U[16];
    let _e111 = _e110.xyz;
    let _e125 = bokehLights((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, _e79.x, _e83.x, _e87.x, _e91, _e94.x, _e98.x, mat3x3<f32>(vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z)));
    fragColor = _e125;
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
