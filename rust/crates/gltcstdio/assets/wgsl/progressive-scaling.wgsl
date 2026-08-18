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

fn getUnitColor(u: vec2<f32>) -> vec4<f32> {
    var u_1: vec2<f32>;
    var k: f32 = 0f;
    var v: vec2<f32>;
    var col: vec4<f32>;

    u_1 = u;
    let _e10 = u_1;
    let _e13 = u_1;
    v = ((_e10 * 10f) - round((_e13 * 10f)));
    let _e19 = u_1;
    let _e23 = u_1;
    let _e28 = u_1;
    let _e33 = u_1;
    if ((((_e19.x >= 0f) && (_e23.x < 0.1f)) && (_e28.y >= 0f)) && (_e33.y < 0.1f)) {
        k = 0.75f;
    }
    let _e39 = u_1;
    let _e43 = u_1;
    let _e48 = u_1;
    let _e53 = u_1;
    if ((((_e39.x >= 0f) && (_e43.x < 0.1f)) && (_e48.y >= 0.9f)) && (_e53.y < 1f)) {
        k = 0.75f;
    }
    let _e59 = u_1;
    let _e63 = u_1;
    let _e68 = u_1;
    let _e73 = u_1;
    if ((((_e59.x >= 0.9f) && (_e63.x < 1f)) && (_e68.y >= 0f)) && (_e73.y < 0.1f)) {
        k = 0.75f;
    }
    let _e79 = u_1;
    let _e83 = u_1;
    let _e88 = u_1;
    let _e93 = u_1;
    if ((((_e79.x >= 0.9f) && (_e83.x < 1f)) && (_e88.y >= 0.9f)) && (_e93.y < 1f)) {
        k = 0.75f;
    }
    let _e99 = k;
    let _e102 = v;
    let _e108 = v;
    k = max(_e99, max(smoothstep(0.03f, 0.02f, abs(_e102.x)), smoothstep(0.03f, 0.02f, abs(_e108.y))));
    let _e114 = u_1;
    let _e116 = u_1;
    col = vec4<f32>(_e114.x, _e116.y, 0.5f, 1f);
    let _e122 = u_1;
    let _e129 = u_1;
    if ((abs((_e122.x - 0.5f)) > 0.5f) || (abs((_e129.y - 0.5f)) > 0.5f)) {
        let _e137 = col;
        let _e139 = col;
        let _e142 = (_e139.xyz * 0.25f);
        col.x = _e142.x;
        col.y = _e142.y;
        col.z = _e142.z;
    }
    let _e149 = col;
    let _e152 = k;
    return mix(_e149, vec4(1f), vec4(_e152));
}

fn mir(x: f32, a: f32) -> f32 {
    var x_1: f32;
    var a_1: f32;

    x_1 = x;
    a_1 = a;
    let _e10 = a_1;
    let _e12 = x_1;
    let _e14 = a_1;
    let _e15 = (2f * _e14);
    let _e20 = a_1;
    return (_e10 * (1f - abs((((_e12 - (floor((_e12 / _e15)) * _e15)) / _e20) - 1f))));
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn progressiveScaling(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, backgroundMode: i32, balance: f32, power: f32, offset: f32, colorScheme: f32, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var backgroundMode_1: i32;
    var balance_1: f32;
    var power_1: f32;
    var offset_1: f32;
    var colorScheme_1: f32;
    var texTransform_1: mat3x3<f32>;
    var ar: vec2<f32>;
    var inside: bool = true;
    var N: f32 = 200f;
    var S: f32 = 1f;
    var y: f32;
    var E: f32;
    var Y: f32 = 0f;
    var i: f32 = 0f;
    var j: f32;
    var sy: f32;
    var E_1: f32;
    var S_1: f32;
    var local: f32;
    var y_1: f32;
    var Y_1: f32;
    var ly: f32;
    var y1_: f32;
    var circum: f32;
    var N_1: f32;
    var E_2: f32;
    var S_2: f32;
    var local_1: f32;
    var y_2: f32;
    var Y_2: f32;
    var ly_1: f32;
    var y1_1: f32;
    var N_2: f32;
    var local_2: f32;
    var kCol: f32;
    var col1_: vec4<f32>;
    var uv2_: vec2<f32>;
    var col3_: vec4<f32>;
    var local_3: f32;
    var g: f32;
    var r: f32;
    var col2_: vec4<f32>;
    var local_4: f32;
    var col4_: vec4<f32>;
    var local_5: f32;
    var local_6: f32;
    var colSlopedThenGrad: vec4<f32>;
    var local_7: vec4<f32>;
    var colBorder: vec4<f32>;
    var resCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    backgroundMode_1 = backgroundMode;
    balance_1 = balance;
    power_1 = power;
    offset_1 = offset;
    colorScheme_1 = colorScheme;
    texTransform_1 = texTransform;
    let _e26 = mode_1;
    if (_e26 >= 100i) {
        {
            let _e29 = uv_1;
            let _e31 = uv_1;
            let _e36 = uv_1;
            uv_1 = vec2<f32>((atan2(_e29.x, _e31.y) / 3.1415927f), length(_e36));
            let _e39 = mode_1;
            mode_1 = (_e39 - 100i);
        }
    }
    let _e42 = sourceDim_1;
    let _e44 = sourceDim_1;
    ar = vec2<f32>((_e42.x / _e44.y), 1f);
    let _e52 = mode_1;
    if (_e52 == 0i) {
        {
            let _e59 = backgroundMode_1;
            if (_e59 == 1i) {
                let _e63 = uv_1;
                uv_1.y = abs(_e63.y);
            }
            let _e66 = uv_1;
            y = -(_e66.y);
            let _e70 = power_1;
            E = _e70;
            inside = false;
            let _e73 = y;
            if (_e73 > 0f) {
                {
                    let _e76 = outPos_1;
                    uv_1 = ((_e76 + vec2(1f)) * 0.5f);
                }
            } else {
                {
                    loop {
                        let _e86 = i;
                        let _e87 = N;
                        if !((_e86 < _e87)) {
                            break;
                        }
                        {
                            let _e93 = i;
                            j = (_e93 + 3f);
                            let _e97 = Y;
                            let _e98 = S;
                            let _e99 = j;
                            let _e100 = E;
                            Y = (_e97 + (_e98 / pow(_e99, _e100)));
                            let _e104 = j;
                            let _e105 = E;
                            let _e107 = S;
                            let _e109 = Y;
                            let _e112 = balance_1;
                            sy = mix((pow(_e104, _e105) / _e107), (_e109 * 0.5f), _e112);
                            let _e115 = y;
                            let _e116 = Y;
                            if (_e115 > -(_e116)) {
                                {
                                    let _e119 = ar;
                                    let _e120 = uv_1;
                                    let _e121 = Y;
                                    let _e125 = j;
                                    let _e127 = j;
                                    let _e128 = E;
                                    let _e130 = S;
                                    uv_1 = (_e119 + ((_e120 - vec2(_e121)) * vec2<f32>((0.5f * _e125), (pow(_e127, _e128) / _e130))));
                                    inside = true;
                                    break;
                                }
                            }
                        }
                        continuing {
                            let _e90 = i;
                            i = (_e90 + 1f);
                        }
                    }
                }
            }
            let _e137 = uv_1;
            let _e139 = offset_1;
            uv_1.x = (_e137.x + _e139);
            let _e141 = uv_1;
            uv_1 = fract(_e141);
        }
    } else {
        let _e143 = mode_1;
        if (_e143 == 1i) {
            {
                let _e147 = power_1;
                E_1 = (max(0.001f, abs(_e147)) + 1f);
                let _e156 = E_1;
                S_1 = (1f / (1f - (1f / _e156)));
                let _e161 = backgroundMode_1;
                if (_e161 == 1i) {
                    let _e164 = uv_1;
                    let _e166 = S_1;
                    let _e167 = mir(_e164.y, _e166);
                    local = _e167;
                } else {
                    let _e168 = uv_1;
                    local = _e168.y;
                }
                let _e171 = local;
                y_1 = _e171;
                let _e173 = y_1;
                let _e176 = y_1;
                let _e177 = S_1;
                if ((_e173 >= 0f) && (_e176 <= _e177)) {
                    {
                        let _e180 = S_1;
                        let _e181 = y_1;
                        let _e183 = S_1;
                        let _e187 = E_1;
                        Y_1 = floor((log(((_e180 - _e181) / _e183)) / log((1f / _e187))));
                        let _e193 = E_1;
                        let _e194 = Y_1;
                        let _e197 = Y_1;
                        let _e200 = balance_1;
                        ly = mix(pow(_e193, -(_e194)), (_e197 * 0.5f), _e200);
                        let _e203 = S_1;
                        let _e204 = S_1;
                        let _e205 = ly;
                        y1_ = (_e203 - (_e204 * _e205));
                        let _e209 = Y_1;
                        circum = (((_e209 + 0.5f) * 2f) * 3.1415927f);
                        let _e217 = circum;
                        N_1 = round((_e217 / 5f));
                        let _e222 = uv_1;
                        let _e224 = N_1;
                        let _e226 = y_1;
                        let _e227 = y1_;
                        let _e229 = ly;
                        uv_1 = vec2<f32>((_e222.x * _e224), ((_e226 - _e227) / _e229));
                        let _e233 = uv_1;
                        let _e235 = offset_1;
                        uv_1.x = (_e233.x + _e235);
                        let _e237 = uv_1;
                        uv_1 = fract(_e237);
                    }
                } else {
                    {
                        inside = false;
                        let _e240 = outPos_1;
                        uv_1 = ((_e240 + vec2(1f)) * 0.5f);
                    }
                }
            }
        } else {
            let _e246 = mode_1;
            if (_e246 == 2i) {
                {
                    let _e250 = power_1;
                    E_2 = (max(0.001f, abs(_e250)) + 1f);
                    let _e259 = E_2;
                    S_2 = (1f / (1f - (1f / _e259)));
                    let _e264 = backgroundMode_1;
                    if (_e264 == 1i) {
                        let _e267 = uv_1;
                        let _e269 = S_2;
                        let _e270 = mir(_e267.y, _e269);
                        local_1 = _e270;
                    } else {
                        let _e271 = uv_1;
                        local_1 = _e271.y;
                    }
                    let _e274 = local_1;
                    y_2 = _e274;
                    let _e276 = y_2;
                    let _e279 = y_2;
                    let _e280 = S_2;
                    if ((_e276 >= 0f) && (_e279 <= _e280)) {
                        {
                            let _e283 = S_2;
                            let _e284 = y_2;
                            let _e286 = S_2;
                            let _e290 = E_2;
                            Y_2 = floor((log(((_e283 - _e284) / _e286)) / log((1f / _e290))));
                            let _e296 = E_2;
                            let _e297 = Y_2;
                            let _e300 = Y_2;
                            let _e303 = balance_1;
                            ly_1 = mix(pow(_e296, -(_e297)), (_e300 * 0.5f), _e303);
                            let _e306 = S_2;
                            let _e307 = S_2;
                            let _e308 = ly_1;
                            y1_1 = (_e306 - (_e307 * _e308));
                            let _e313 = Y_2;
                            N_2 = pow(2f, _e313);
                            let _e316 = uv_1;
                            let _e318 = N_2;
                            let _e320 = y_2;
                            let _e321 = y1_1;
                            let _e323 = ly_1;
                            uv_1 = vec2<f32>((_e316.x * _e318), ((_e320 - _e321) / _e323));
                            let _e327 = uv_1;
                            let _e329 = offset_1;
                            uv_1.x = (_e327.x + _e329);
                            let _e331 = uv_1;
                            uv_1 = fract(_e331);
                        }
                    } else {
                        {
                            inside = false;
                            let _e334 = outPos_1;
                            uv_1 = ((_e334 + vec2(1f)) * 0.5f);
                        }
                    }
                }
            }
        }
    }
    let _e340 = colorScheme_1;
    if (_e340 == 1f) {
        local_2 = 1f;
    } else {
        let _e344 = colorScheme_1;
        local_2 = fract((_e344 * 5f));
    }
    let _e349 = local_2;
    kCol = _e349;
    let _e351 = uv_1;
    let _e352 = getUnitColor(_e351);
    col1_ = _e352;
    let _e354 = uv_1;
    let _e360 = ar;
    uv2_ = (((_e354 * 2f) - vec2(1f)) * _e360);
    let _e363 = texTransform_1;
    let _e365 = uv2_;
    let _e366 = tf(_naga_inverse_3x3_f32(_e363), _e365);
    uv2_ = _e366;
    let _e367 = uv2_;
    let _e371 = global.U[0];
    let _e374 = uv2_;
    let _e383 = _mirror_wrap(((vec2<f32>((_e367.x / _e371.x), _e374.y) / vec2(2f)) + vec2(0.5f)));
    let _e384 = textureSample(t_source, samp, _e383);
    col3_ = _e384;
    let _e386 = texTransform_1;
    let _e388 = uv_1;
    let _e389 = tf(_naga_inverse_3x3_f32(_e386), _e388);
    uv_1 = _e389;
    let _e390 = uv_1;
    if (fract(_e390.x) < 0.5f) {
        local_3 = 1f;
    } else {
        local_3 = 0f;
    }
    let _e398 = local_3;
    g = _e398;
    let _e400 = uv_1;
    r = fract(_e400.y);
    let _e404 = r;
    let _e405 = g;
    let _e407 = vec3<f32>(_e404, _e405, 0.5f);
    col2_ = vec4<f32>(_e407.x, _e407.y, _e407.z, 1f);
    let _e414 = g;
    if (_e414 > 0.5f) {
        local_4 = 1f;
    } else {
        local_4 = 0f;
    }
    let _e420 = local_4;
    let _e421 = vec3(_e420);
    col4_ = vec4<f32>(_e421.x, _e421.y, _e421.z, 1f);
    let _e428 = kCol;
    if (_e428 <= 0.5f) {
        let _e431 = uv_1;
        let _e435 = kCol;
        let _e438 = uv_1;
        if ((_e431.x - 0.5f) > ((_e435 * 2f) * (_e438.y - 0.5f))) {
            local_5 = 0f;
        } else {
            local_5 = 1f;
        }
        let _e447 = local_5;
        local_6 = _e447;
    } else {
        let _e448 = kCol;
        let _e452 = uv_1;
        let _e454 = kCol;
        let _e458 = uv_1;
        let _e460 = kCol;
        local_6 = ((_e448 - 0.5f) + (0.25f * ((_e452.y / (_e454 - 0.5f)) - (_e458.x / (_e460 - 0.5f)))));
    }
    let _e468 = local_6;
    let _e469 = vec3(_e468);
    colSlopedThenGrad = vec4<f32>(_e469.x, _e469.y, _e469.z, 1f);
    let _e476 = uv_1;
    let _e483 = uv_1;
    if ((abs((_e476.x - 0.5f)) > 0.4f) || (abs((_e483.y - 0.5f)) > 0.4f)) {
        local_7 = vec4<f32>(0f, 0f, 0f, 1f);
    } else {
        let _e496 = col3_;
        local_7 = _e496;
    }
    let _e498 = local_7;
    colBorder = _e498;
    let _e501 = colorScheme_1;
    if (_e501 < 0.2f) {
        let _e504 = col3_;
        let _e505 = colBorder;
        let _e506 = kCol;
        resCol = mix(_e504, _e505, vec4(_e506));
    } else {
        let _e509 = colorScheme_1;
        if (_e509 < 0.4f) {
            let _e512 = colBorder;
            let _e513 = col1_;
            let _e514 = kCol;
            resCol = mix(_e512, _e513, vec4(_e514));
        } else {
            let _e517 = colorScheme_1;
            if (_e517 < 0.6f) {
                let _e520 = col1_;
                let _e521 = col2_;
                let _e522 = kCol;
                resCol = mix(_e520, _e521, vec4(_e522));
            } else {
                let _e525 = colorScheme_1;
                if (_e525 < 0.8f) {
                    let _e528 = col2_;
                    let _e529 = col4_;
                    let _e530 = kCol;
                    resCol = mix(_e528, _e529, vec4(_e530));
                } else {
                    let _e533 = colSlopedThenGrad;
                    resCol = _e533;
                }
            }
        }
    }
    let _e534 = inside;
    let _e535 = backgroundMode_1;
    if (_e534 || (_e535 <= 1i)) {
        let _e539 = resCol;
        return _e539;
    } else {
        let _e540 = backgroundMode_1;
        if (_e540 == 2i) {
            return vec4<f32>(0f, 0f, 0f, 1f);
        } else {
            let _e548 = backgroundMode_1;
            if (_e548 == 3i) {
                return vec4(1f);
            } else {
                let _e553 = outPos_1;
                let _e557 = global.U[0];
                let _e560 = outPos_1;
                let _e569 = _mirror_wrap(((vec2<f32>((_e553.x / _e557.x), _e560.y) / vec2(2f)) + vec2(0.5f)));
                let _e570 = textureSample(t_source, samp, _e569);
                return _e570;
            }
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
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e97 = _e96.xyz;
    let _e100 = global.U[13];
    let _e101 = _e100.xyz;
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e119 = progressiveScaling((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), _e80.x, _e84.x, _e88.x, _e92.x, mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)));
    fragColor = _e119;
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
