struct Params {
    U: array<vec4<f32>, 18>,
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

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn f2_(u: vec2<f32>, split: vec2<f32>, s: vec2<f32>, intensity: f32, coverage: f32, mode: f32, N: i32, seed_2: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var split_1: vec2<f32>;
    var s_1: vec2<f32>;
    var intensity_1: f32;
    var coverage_1: f32;
    var mode_1: f32;
    var N_1: i32;
    var seed_3: f32;
    var mul: f32;
    var rnd: vec2<f32>;
    var type1_: f32 = 0f;
    var type2_: f32 = 1f;
    var type3_: f32 = 2f;
    var type4_: f32 = 3f;
    var i: i32 = 0i;
    var type_43: f32;
    var ox: f32;

    u_1 = u;
    split_1 = split;
    s_1 = s;
    intensity_1 = intensity;
    coverage_1 = coverage;
    mode_1 = mode;
    N_1 = N;
    seed_3 = seed_2;
    let _e22 = mode_1;
    mul = floor((_e22 - (floor((_e22 / 4f)) * 4f)));
    let _e30 = mode_1;
    mode_1 = floor((_e30 / 4f));
    let _e34 = s_1;
    let _e35 = seed_3;
    let _e36 = rand2relSeeded(_e34, _e35);
    rnd = _e36;
    loop {
        let _e48 = i;
        let _e49 = N_1;
        if !((_e48 < _e49)) {
            break;
        }
        {
            let _e56 = u_1;
            let _e58 = split_1;
            let _e61 = u_1;
            let _e63 = split_1;
            if ((_e56.x > _e58.x) && (_e61.y > _e63.y)) {
                {
                    let _e67 = type1_;
                    type_43 = _e67;
                }
            } else {
                let _e68 = u_1;
                let _e70 = split_1;
                let _e73 = u_1;
                let _e75 = split_1;
                if ((_e68.x <= _e70.x) && (_e73.y > _e75.y)) {
                    {
                        let _e79 = type2_;
                        type_43 = _e79;
                    }
                } else {
                    let _e80 = u_1;
                    let _e82 = split_1;
                    if (_e80.x > _e82.x) {
                        {
                            let _e85 = type3_;
                            type_43 = _e85;
                        }
                    } else {
                        {
                            let _e86 = type4_;
                            type_43 = _e86;
                        }
                    }
                }
            }
            let _e87 = type_43;
            if (_e87 == 0f) {
                {
                    let _e90 = u_1;
                    let _e92 = rnd;
                    u_1 = (_e90 * (1f + _e92.x));
                }
            } else {
                let _e96 = type_43;
                if (_e96 == 1f) {
                    {
                        let _e99 = u_1;
                        ox = _e99.x;
                        let _e103 = rnd;
                        let _e106 = u_1;
                        u_1.x = (sign(_e103.x) * _e106.y);
                        let _e110 = rnd;
                        let _e113 = ox;
                        u_1.y = (sign(_e110.y) * _e113);
                    }
                } else {
                    let _e115 = type_43;
                    if (_e115 == 2f) {
                        {
                            let _e119 = u_1;
                            let _e121 = rnd;
                            u_1.x = (_e119.x + (_e121.y * 2f));
                        }
                    } else {
                        let _e126 = type_43;
                        if (_e126 == 3f) {
                            {
                                let _e130 = u_1;
                                let _e133 = u_1;
                                let _e136 = rnd;
                                let _e139 = (sign(_e130.x) * pow(abs(_e133.x), _e136.y));
                                u_1.x = (_e139 - (floor((_e139 / 1f)) * 1f));
                                let _e146 = u_1;
                                let _e149 = u_1;
                                let _e152 = rnd;
                                let _e155 = (sign(_e146.y) * pow(abs(_e149.y), _e152.x));
                                u_1.y = (_e155 - (floor((_e155 / 1f)) * 1f));
                            }
                        }
                    }
                }
            }
            let _e161 = u_1;
            let _e164 = u_1;
            if (max(abs(_e161.x), abs(_e164.y)) > 1.5f) {
                {
                    let _e170 = u_1;
                    let _e172 = intensity_1;
                    u_1 = (_e170 * pow(2f, _e172));
                }
            }
        }
        continuing {
            let _e52 = i;
            i = (_e52 + 1i);
        }
    }
    let _e175 = u_1;
    return _e175;
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
    var s_2: f32;
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
    s_2 = _e19.y;
    let _e22 = inc_1;
    l = _e22.z;
    let _e27 = l;
    if (_e27 < 0.5f) {
        let _e30 = l;
        let _e32 = s_2;
        q_2 = (_e30 * (1f + _e32));
    } else {
        let _e35 = l;
        let _e36 = s_2;
        let _e38 = s_2;
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

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn defect(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode_2: i32, count: i32, intensity_2: f32, coverage_2: f32, randomSeed: f32, power: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_3: i32;
    var count_1: i32;
    var intensity_3: f32;
    var coverage_3: f32;
    var randomSeed_1: f32;
    var power_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var ratio: f32;
    var vRatio: vec2<f32>;
    var u1_: vec2<f32>;
    var split1_: vec2<f32>;
    var col: vec4<f32>;
    var fmode: f32;
    var px: vec2<f32>;
    var py: vec2<f32>;
    var pz: vec2<f32>;
    var outCol: vec4<f32>;
    var fixedBkg: bool;
    var tN: f32 = 16f;
    var type1_1: f32;
    var type2_1: f32;
    var type3_1: f32;
    var type_44: f32 = 0f;
    var local_2: vec2<f32>;
    var local_3: vec2<f32>;
    var a: vec4<f32>;
    var b_1: vec4<f32>;
    var a_1: vec4<f32>;
    var b_2: vec4<f32>;
    var step: vec2<f32>;
    var r_1: f32;
    var g_1: f32;
    var b_3: f32;
    var g_2: f32;
    var s_3: f32;
    var g_3: f32;
    var s_4: f32;
    var local_4: vec2<f32>;
    var vv: vec2<f32>;
    var local_5: vec2<f32>;
    var local_6: vec2<f32>;
    var r_2: f32;
    var g_4: f32;
    var b_4: f32;
    var a_2: vec4<f32>;
    var b_5: vec4<f32>;
    var local_7: f32;
    var l_1: f32;
    var km: f32;
    var hsl: vec4<f32>;
    var a_3: vec4<f32>;
    var b_6: vec4<f32>;
    var local_8: f32;
    var l_2: f32;
    var km_1: f32;
    var hsl_1: vec4<f32>;
    var a_4: vec4<f32>;
    var b_7: vec4<f32>;
    var km_2: f32;
    var hsl_2: vec4<f32>;
    var s_5: f32;
    var g_5: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_3 = mode_2;
    count_1 = count;
    intensity_3 = intensity_2;
    coverage_3 = coverage_2;
    randomSeed_1 = randomSeed;
    power_1 = power;
    modelTransform_1 = modelTransform;
    let _e26 = sourceDim_1;
    let _e28 = sourceDim_1;
    ratio = (_e26.x / _e28.y);
    let _e32 = ratio;
    vRatio = vec2<f32>(_e32, 1f);
    let _e36 = coverage_3;
    coverage_3 = (_e36 * 100f);
    let _e39 = modelTransform_1;
    let _e41 = pos_1;
    let _e42 = tf(_naga_inverse_3x3_f32(_e39), _e41);
    u1_ = _e42;
    let _e44 = u1_;
    split1_ = ((fract(_e44) * 2f) - vec2(1f));
    let _e52 = pos_1;
    let _e56 = global.U[0];
    let _e59 = pos_1;
    let _e69 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e52.x / _e56.x), _e59.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e69;
    let _e71 = mode_3;
    fmode = f32(_e71);
    let _e74 = pos_1;
    let _e75 = vRatio;
    let _e77 = split1_;
    let _e78 = u1_;
    let _e80 = power_1;
    let _e81 = coverage_3;
    let _e82 = fmode;
    let _e83 = count_1;
    let _e84 = randomSeed_1;
    let _e85 = f2_((_e74 / _e75), _e77, floor(_e78), _e80, _e81, _e82, _e83, _e84);
    let _e86 = vRatio;
    px = (_e85 * _e86);
    let _e89 = pos_1;
    let _e90 = vRatio;
    let _e92 = split1_;
    let _e93 = u1_;
    let _e99 = power_1;
    let _e100 = coverage_3;
    let _e101 = fmode;
    let _e102 = count_1;
    let _e103 = randomSeed_1;
    let _e104 = f2_((_e89 / _e90), _e92, (floor(_e93) - vec2<f32>(1f, 1f)), _e99, _e100, _e101, _e102, _e103);
    let _e105 = vRatio;
    py = (_e104 * _e105);
    let _e108 = pos_1;
    let _e109 = vRatio;
    let _e111 = split1_;
    let _e112 = u1_;
    let _e118 = power_1;
    let _e119 = coverage_3;
    let _e120 = fmode;
    let _e121 = count_1;
    let _e122 = randomSeed_1;
    let _e123 = f2_((_e108 / _e109), _e111, (floor(_e112) + vec2<f32>(2f, 0f)), _e118, _e119, _e120, _e121, _e122);
    let _e124 = vRatio;
    pz = (_e123 * _e124);
    let _e128 = fmode;
    fixedBkg = (floor((_e128 - (floor((_e128 / 2f)) * 2f))) == 0f);
    let _e138 = fmode;
    fmode = floor((_e138 / 2f));
    let _e144 = fmode;
    let _e145 = tN;
    type1_1 = floor((_e144 - (floor((_e144 / _e145)) * _e145)));
    let _e152 = fmode;
    let _e153 = tN;
    fmode = floor((_e152 / _e153));
    let _e156 = fmode;
    let _e157 = tN;
    type2_1 = floor((_e156 - (floor((_e156 / _e157)) * _e157)));
    let _e164 = fmode;
    let _e165 = tN;
    fmode = floor((_e164 / _e165));
    let _e168 = fmode;
    let _e169 = tN;
    type3_1 = floor((_e168 - (floor((_e168 / _e169)) * _e169)));
    let _e176 = fmode;
    let _e177 = tN;
    fmode = floor((_e176 / _e177));
    let _e182 = px;
    let _e183 = py;
    let _e186 = py;
    let _e187 = pz;
    let _e190 = coverage_3;
    let _e193 = coverage_3;
    if ((length((_e182 - _e183)) > (length((_e186 - _e187)) * _e190)) && (_e193 < 100f)) {
        {
            type_44 = 0f;
        }
    } else {
        let _e198 = px;
        let _e199 = py;
        let _e202 = px;
        let _e203 = pz;
        if (length((_e198 - _e199)) > length((_e202 - _e203))) {
            {
                let _e207 = type1_1;
                type_44 = _e207;
            }
        } else {
            let _e208 = py;
            let _e209 = pz;
            let _e212 = py;
            let _e213 = px;
            if (length((_e208 - _e209)) > length((_e212 - _e213))) {
                {
                    let _e217 = type2_1;
                    type_44 = _e217;
                }
            } else {
                {
                    let _e218 = type3_1;
                    type_44 = _e218;
                }
            }
        }
    }
    let _e219 = type_44;
    if (_e219 == 0f) {
        {
            let _e222 = fixedBkg;
            if _e222 {
                let _e223 = outPos_1;
                local_2 = _e223;
            } else {
                let _e224 = pos_1;
                local_2 = _e224;
            }
            let _e226 = local_2;
            let _e230 = global.U[0];
            let _e233 = fixedBkg;
            if _e233 {
                let _e234 = outPos_1;
                local_3 = _e234;
            } else {
                let _e235 = pos_1;
                local_3 = _e235;
            }
            let _e237 = local_3;
            let _e247 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e226.x / _e230.x), _e237.y) / vec2(2f)) + vec2(0.5f)), 0f);
            outCol = _e247;
        }
    } else {
        let _e248 = type_44;
        if (_e248 == 1f) {
            {
                let _e253 = ratio;
                let _e255 = px;
                let _e261 = global.U[0];
                let _e266 = ratio;
                let _e268 = px;
                let _e280 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((-0.99f * _e253), _e255.y).x / _e261.x), vec2<f32>((-0.99f * _e266), _e268.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                a = _e280;
                let _e283 = ratio;
                let _e285 = px;
                let _e291 = global.U[0];
                let _e295 = ratio;
                let _e297 = px;
                let _e309 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((0.99f * _e283), _e285.y).x / _e291.x), vec2<f32>((0.99f * _e295), _e297.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                b_1 = _e309;
                let _e311 = a;
                let _e312 = b_1;
                let _e313 = px;
                outCol = mix(_e311, _e312, vec4(fract(((_e313.x + 1f) / 2f))));
            }
        } else {
            let _e322 = type_44;
            if (_e322 == 2f) {
                {
                    let _e325 = px;
                    let _e333 = global.U[0];
                    let _e336 = px;
                    let _e350 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e325.x, -0.99f).x / _e333.x), vec2<f32>(_e336.x, -0.99f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    a_1 = _e350;
                    let _e352 = px;
                    let _e359 = global.U[0];
                    let _e362 = px;
                    let _e375 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e352.x, 0.99f).x / _e359.x), vec2<f32>(_e362.x, 0.99f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    b_2 = _e375;
                    let _e377 = a_1;
                    let _e378 = b_2;
                    let _e379 = px;
                    outCol = mix(_e377, _e378, vec4(fract(((_e379.y + 1f) / 2f))));
                }
            } else {
                let _e388 = type_44;
                if (_e388 == 3f) {
                    {
                        let _e391 = px;
                        let _e392 = py;
                        let _e395 = intensity_3;
                        step = ((normalize((_e391 - _e392)) * _e395) * 0.2f);
                        let _e400 = pos_1;
                        let _e401 = step;
                        let _e406 = global.U[0];
                        let _e409 = pos_1;
                        let _e410 = step;
                        let _e421 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e400 - _e401).x / _e406.x), (_e409 - _e410).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        r_1 = _e421.x;
                        let _e424 = pos_1;
                        let _e428 = global.U[0];
                        let _e431 = pos_1;
                        let _e441 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e424.x / _e428.x), _e431.y) / vec2(2f)) + vec2(0.5f)), 0f);
                        g_1 = _e441.y;
                        let _e444 = pos_1;
                        let _e445 = step;
                        let _e450 = global.U[0];
                        let _e453 = pos_1;
                        let _e454 = step;
                        let _e465 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e444 + _e445).x / _e450.x), (_e453 + _e454).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        b_3 = _e465.z;
                        let _e468 = r_1;
                        let _e469 = g_1;
                        let _e470 = b_3;
                        let _e471 = col;
                        outCol = vec4<f32>(_e468, _e469, _e470, _e471.w);
                    }
                } else {
                    let _e474 = type_44;
                    if (_e474 == 4f) {
                        {
                            let _e477 = pos_1;
                            let _e481 = global.U[0];
                            let _e484 = pos_1;
                            let _e494 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e477.x / _e481.x), _e484.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            outCol = _e494;
                            let _e495 = outCol;
                            let _e497 = outCol;
                            let _e500 = outCol;
                            let _e505 = intensity_3;
                            g_2 = pow((((_e495.x + _e497.y) + _e500.z) / 3f), (_e505 + 1f));
                            let _e510 = g_2;
                            let _e511 = g_2;
                            let _e512 = g_2;
                            let _e513 = col;
                            outCol = vec4<f32>(_e510, _e511, _e512, _e513.w);
                        }
                    } else {
                        let _e516 = type_44;
                        if (_e516 == 5f) {
                            {
                                let _e520 = intensity_3;
                                s_3 = (40f * _e520);
                                let _e523 = px;
                                let _e524 = s_3;
                                let _e527 = s_3;
                                let _e533 = global.U[0];
                                let _e536 = px;
                                let _e537 = s_3;
                                let _e540 = s_3;
                                let _e552 = textureSampleLevel(t_source, samp, ((vec2<f32>(((floor((_e523 * _e524)) / vec2(_e527)).x / _e533.x), (floor((_e536 * _e537)) / vec2(_e540)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                outCol = _e552;
                                let _e553 = outCol;
                                let _e555 = outCol;
                                let _e558 = outCol;
                                g_3 = floor(((((_e553.x + _e555.y) + _e558.z) / 3f) + 0.5f));
                                let _e567 = g_3;
                                let _e568 = g_3;
                                let _e569 = g_3;
                                let _e570 = col;
                                outCol = vec4<f32>(_e567, _e568, _e569, _e570.w);
                            }
                        } else {
                            let _e573 = type_44;
                            if (_e573 == 6f) {
                                {
                                    let _e577 = intensity_3;
                                    s_4 = (40f * _e577);
                                    let _e580 = px;
                                    let _e581 = s_4;
                                    let _e584 = s_4;
                                    let _e590 = global.U[0];
                                    let _e593 = px;
                                    let _e594 = s_4;
                                    let _e597 = s_4;
                                    let _e609 = textureSampleLevel(t_source, samp, ((vec2<f32>(((floor((_e580 * _e581)) / vec2(_e584)).x / _e590.x), (floor((_e593 * _e594)) / vec2(_e597)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    outCol = floor((_e609 + vec4(0.5f)));
                                }
                            } else {
                                let _e614 = type_44;
                                if (_e614 == 7f) {
                                    {
                                        let _e617 = fixedBkg;
                                        if _e617 {
                                            let _e618 = outPos_1;
                                            local_4 = _e618;
                                        } else {
                                            let _e619 = pos_1;
                                            local_4 = _e619;
                                        }
                                        let _e621 = local_4;
                                        let _e623 = px;
                                        let _e635 = pos_1;
                                        let _e638 = intensity_3;
                                        vv = mix(_e621, vec2<f32>(0f, ((fract(((_e623.y + 1f) / 2f)) * 2f) - 1f)), vec2((fract(_e635.x) * _e638)));
                                        let _e643 = vv;
                                        let _e647 = global.U[0];
                                        let _e650 = vv;
                                        let _e660 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e643.x / _e647.x), _e650.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        outCol = _e660;
                                    }
                                } else {
                                    let _e661 = type_44;
                                    if (_e661 == 8f) {
                                        {
                                            let _e664 = fixedBkg;
                                            if _e664 {
                                                let _e665 = outPos_1;
                                                local_5 = _e665;
                                            } else {
                                                let _e666 = pos_1;
                                                local_5 = _e666;
                                            }
                                            let _e668 = local_5;
                                            let _e669 = px;
                                            let _e673 = px;
                                            let _e676 = intensity_3;
                                            let _e683 = global.U[0];
                                            let _e686 = fixedBkg;
                                            if _e686 {
                                                let _e687 = outPos_1;
                                                local_6 = _e687;
                                            } else {
                                                let _e688 = pos_1;
                                                local_6 = _e688;
                                            }
                                            let _e690 = local_6;
                                            let _e691 = px;
                                            let _e695 = px;
                                            let _e698 = intensity_3;
                                            let _e711 = textureSampleLevel(t_source, samp, ((vec2<f32>((mix(_e668, vec2<f32>(_e669.x, 0f), vec2((fract(_e673.y) * _e676))).x / _e683.x), mix(_e690, vec2<f32>(_e691.x, 0f), vec2((fract(_e695.y) * _e698))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            outCol = _e711;
                                        }
                                    } else {
                                        let _e712 = type_44;
                                        if (_e712 == 9f) {
                                            {
                                                let _e715 = pos_1;
                                                let _e716 = px;
                                                let _e717 = intensity_3;
                                                let _e725 = global.U[0];
                                                let _e728 = pos_1;
                                                let _e729 = px;
                                                let _e730 = intensity_3;
                                                let _e744 = textureSampleLevel(t_source, samp, ((vec2<f32>((mix(_e715, _e716, vec2((_e717 - 0.5f))).x / _e725.x), mix(_e728, _e729, vec2((_e730 - 0.5f))).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                r_2 = _e744.x;
                                                let _e747 = py;
                                                let _e751 = global.U[0];
                                                let _e754 = py;
                                                let _e764 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e747.x / _e751.x), _e754.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                g_4 = _e764.y;
                                                let _e767 = pz;
                                                let _e771 = global.U[0];
                                                let _e774 = pz;
                                                let _e784 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e767.x / _e771.x), _e774.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                b_4 = _e784.z;
                                                let _e787 = r_2;
                                                let _e788 = g_4;
                                                let _e789 = b_4;
                                                let _e790 = col;
                                                outCol = vec4<f32>(_e787, _e788, _e789, _e790.w);
                                            }
                                        } else {
                                            let _e793 = type_44;
                                            if (_e793 == 10f) {
                                                {
                                                    let _e798 = ratio;
                                                    let _e800 = px;
                                                    let _e806 = global.U[0];
                                                    let _e811 = ratio;
                                                    let _e813 = px;
                                                    let _e825 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((-0.5f * _e798), _e800.y).x / _e806.x), vec2<f32>((-0.5f * _e811), _e813.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e826 = rgbToHsl(_e825);
                                                    a_2 = _e826;
                                                    let _e829 = ratio;
                                                    let _e831 = px;
                                                    let _e837 = global.U[0];
                                                    let _e841 = ratio;
                                                    let _e843 = px;
                                                    let _e855 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((0.5f * _e829), _e831.y).x / _e837.x), vec2<f32>((0.5f * _e841), _e843.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                    let _e856 = rgbToHsl(_e855);
                                                    b_5 = _e856;
                                                    let _e858 = a_2;
                                                    let _e863 = b_5;
                                                    if (abs((_e858.z - 0.5f)) < abs((_e863.z - 0.5f))) {
                                                        let _e869 = a_2;
                                                        local_7 = _e869.z;
                                                    } else {
                                                        let _e871 = b_5;
                                                        local_7 = _e871.z;
                                                    }
                                                    let _e874 = local_7;
                                                    l_1 = _e874;
                                                    let _e877 = intensity_3;
                                                    km = ((1f + _e877) / 2f);
                                                    let _e883 = a_2;
                                                    let _e885 = km;
                                                    let _e888 = b_5;
                                                    let _e890 = km;
                                                    let _e892 = px;
                                                    let _e901 = l_1;
                                                    let _e902 = a_2;
                                                    let _e904 = b_5;
                                                    hsl = vec4<f32>(mix(mix(0f, _e883.x, _e885), mix(360f, _e888.x, _e890), fract(((_e892.x + 1f) / 2f))), 1f, _e901, max(_e902.w, _e904.w));
                                                    let _e909 = hsl;
                                                    let _e910 = hslToRgb(_e909);
                                                    outCol = _e910;
                                                }
                                            } else {
                                                let _e911 = type_44;
                                                if (_e911 == 11f) {
                                                    {
                                                        let _e914 = px;
                                                        let _e922 = global.U[0];
                                                        let _e925 = px;
                                                        let _e939 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e914.x, -0.5f).x / _e922.x), vec2<f32>(_e925.x, -0.5f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e940 = rgbToHsl(_e939);
                                                        a_3 = _e940;
                                                        let _e942 = px;
                                                        let _e949 = global.U[0];
                                                        let _e952 = px;
                                                        let _e965 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>(_e942.x, 0.5f).x / _e949.x), vec2<f32>(_e952.x, 0.5f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                        let _e966 = rgbToHsl(_e965);
                                                        b_6 = _e966;
                                                        let _e968 = a_3;
                                                        let _e973 = b_6;
                                                        if (abs((_e968.z - 0.5f)) < abs((_e973.z - 0.5f))) {
                                                            let _e979 = a_3;
                                                            local_8 = _e979.z;
                                                        } else {
                                                            let _e981 = b_6;
                                                            local_8 = _e981.z;
                                                        }
                                                        let _e984 = local_8;
                                                        l_2 = _e984;
                                                        let _e987 = intensity_3;
                                                        km_1 = ((1f + _e987) / 2f);
                                                        let _e993 = a_3;
                                                        let _e995 = km_1;
                                                        let _e998 = b_6;
                                                        let _e1000 = km_1;
                                                        let _e1002 = px;
                                                        let _e1011 = l_2;
                                                        let _e1012 = a_3;
                                                        let _e1014 = b_6;
                                                        hsl_1 = vec4<f32>(mix(mix(0f, _e993.x, _e995), mix(360f, _e998.x, _e1000), fract(((_e1002.y + 1f) / 2f))), 1f, _e1011, max(_e1012.w, _e1014.w));
                                                        let _e1019 = hsl_1;
                                                        let _e1020 = hslToRgb(_e1019);
                                                        outCol = _e1020;
                                                    }
                                                } else {
                                                    let _e1021 = type_44;
                                                    if (_e1021 == 12f) {
                                                        {
                                                            let _e1026 = ratio;
                                                            let _e1028 = px;
                                                            let _e1034 = global.U[0];
                                                            let _e1039 = ratio;
                                                            let _e1041 = px;
                                                            let _e1053 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((-0.5f * _e1026), _e1028.y).x / _e1034.x), vec2<f32>((-0.5f * _e1039), _e1041.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e1054 = rgbToHsl(_e1053);
                                                            a_4 = _e1054;
                                                            let _e1057 = ratio;
                                                            let _e1059 = px;
                                                            let _e1065 = global.U[0];
                                                            let _e1069 = ratio;
                                                            let _e1071 = px;
                                                            let _e1083 = textureSampleLevel(t_source, samp, ((vec2<f32>((vec2<f32>((0.5f * _e1057), _e1059.y).x / _e1065.x), vec2<f32>((0.5f * _e1069), _e1071.y).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                            let _e1084 = rgbToHsl(_e1083);
                                                            b_7 = _e1084;
                                                            let _e1087 = intensity_3;
                                                            km_2 = ((1f + _e1087) / 2f);
                                                            let _e1095 = a_4;
                                                            let _e1097 = km_2;
                                                            let _e1100 = b_7;
                                                            let _e1102 = km_2;
                                                            let _e1104 = px;
                                                            let _e1112 = a_4;
                                                            let _e1114 = b_7;
                                                            hsl_2 = vec4<f32>(0f, 0f, mix(mix(0f, _e1095.z, _e1097), mix(1f, _e1100.z, _e1102), fract(((_e1104.x + 1f) / 2f))), max(_e1112.w, _e1114.w));
                                                            let _e1119 = hsl_2;
                                                            let _e1120 = hslToRgb(_e1119);
                                                            outCol = _e1120;
                                                        }
                                                    } else {
                                                        let _e1121 = type_44;
                                                        if (_e1121 == 13f) {
                                                            {
                                                                let _e1125 = intensity_3;
                                                                s_5 = (40f * _e1125);
                                                                let _e1128 = px;
                                                                let _e1132 = global.U[0];
                                                                let _e1135 = px;
                                                                let _e1145 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1128.x / _e1132.x), _e1135.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                outCol = _e1145;
                                                                let _e1146 = outCol;
                                                                let _e1148 = outCol;
                                                                let _e1151 = outCol;
                                                                let _e1156 = px;
                                                                let _e1163 = intensity_3;
                                                                g_5 = floor((((((_e1146.x + _e1148.y) + _e1151.z) / 3f) + ((fract((_e1156.x * 40f)) - 0.5f) * _e1163)) + 0.5f));
                                                                let _e1170 = g_5;
                                                                let _e1171 = g_5;
                                                                let _e1172 = g_5;
                                                                let _e1173 = col;
                                                                outCol = vec4<f32>(_e1170, _e1171, _e1172, _e1173.w);
                                                            }
                                                        } else {
                                                            {
                                                                let _e1176 = pos_1;
                                                                let _e1180 = global.U[0];
                                                                let _e1183 = pos_1;
                                                                let _e1193 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1176.x / _e1180.x), _e1183.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                                                outCol = _e1193;
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
            }
        }
    }
    let _e1194 = outCol;
    return _e1194;
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
    let _e70 = global.U[9];
    let _e75 = global.U[10];
    let _e80 = global.U[11];
    let _e84 = global.U[12];
    let _e88 = global.U[13];
    let _e92 = global.U[14];
    let _e96 = global.U[15];
    let _e97 = _e96.xyz;
    let _e100 = global.U[16];
    let _e101 = _e100.xyz;
    let _e104 = global.U[17];
    let _e105 = _e104.xyz;
    let _e119 = defect((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), _e80.x, _e84.x, _e88.x, _e92.x, mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)));
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
