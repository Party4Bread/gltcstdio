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
    var type_44: f32;
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
                    type_44 = _e67;
                }
            } else {
                let _e68 = u_1;
                let _e70 = split_1;
                let _e73 = u_1;
                let _e75 = split_1;
                if ((_e68.x <= _e70.x) && (_e73.y > _e75.y)) {
                    {
                        let _e79 = type2_;
                        type_44 = _e79;
                    }
                } else {
                    let _e80 = u_1;
                    let _e82 = split_1;
                    if (_e80.x > _e82.x) {
                        {
                            let _e85 = type3_;
                            type_44 = _e85;
                        }
                    } else {
                        {
                            let _e86 = type4_;
                            type_44 = _e86;
                        }
                    }
                }
            }
            let _e87 = type_44;
            if (_e87 == 0f) {
                {
                    let _e90 = u_1;
                    let _e92 = rnd;
                    u_1 = (_e90 * (1f + _e92.x));
                }
            } else {
                let _e96 = type_44;
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
                    let _e115 = type_44;
                    if (_e115 == 2f) {
                        {
                            let _e119 = u_1;
                            let _e121 = rnd;
                            u_1.x = (_e119.x + (_e121.y * 2f));
                        }
                    } else {
                        let _e126 = type_44;
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
    var type_45: f32 = 0f;
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
    let _e68 = textureSample(t_source, samp, ((vec2<f32>((_e52.x / _e56.x), _e59.y) / vec2(2f)) + vec2(0.5f)));
    col = _e68;
    let _e70 = mode_3;
    fmode = f32(_e70);
    let _e73 = pos_1;
    let _e74 = vRatio;
    let _e76 = split1_;
    let _e77 = u1_;
    let _e79 = power_1;
    let _e80 = coverage_3;
    let _e81 = fmode;
    let _e82 = count_1;
    let _e83 = randomSeed_1;
    let _e84 = f2_((_e73 / _e74), _e76, floor(_e77), _e79, _e80, _e81, _e82, _e83);
    let _e85 = vRatio;
    px = (_e84 * _e85);
    let _e88 = pos_1;
    let _e89 = vRatio;
    let _e91 = split1_;
    let _e92 = u1_;
    let _e98 = power_1;
    let _e99 = coverage_3;
    let _e100 = fmode;
    let _e101 = count_1;
    let _e102 = randomSeed_1;
    let _e103 = f2_((_e88 / _e89), _e91, (floor(_e92) - vec2<f32>(1f, 1f)), _e98, _e99, _e100, _e101, _e102);
    let _e104 = vRatio;
    py = (_e103 * _e104);
    let _e107 = pos_1;
    let _e108 = vRatio;
    let _e110 = split1_;
    let _e111 = u1_;
    let _e117 = power_1;
    let _e118 = coverage_3;
    let _e119 = fmode;
    let _e120 = count_1;
    let _e121 = randomSeed_1;
    let _e122 = f2_((_e107 / _e108), _e110, (floor(_e111) + vec2<f32>(2f, 0f)), _e117, _e118, _e119, _e120, _e121);
    let _e123 = vRatio;
    pz = (_e122 * _e123);
    let _e127 = fmode;
    fixedBkg = (floor((_e127 - (floor((_e127 / 2f)) * 2f))) == 0f);
    let _e137 = fmode;
    fmode = floor((_e137 / 2f));
    let _e143 = fmode;
    let _e144 = tN;
    type1_1 = floor((_e143 - (floor((_e143 / _e144)) * _e144)));
    let _e151 = fmode;
    let _e152 = tN;
    fmode = floor((_e151 / _e152));
    let _e155 = fmode;
    let _e156 = tN;
    type2_1 = floor((_e155 - (floor((_e155 / _e156)) * _e156)));
    let _e163 = fmode;
    let _e164 = tN;
    fmode = floor((_e163 / _e164));
    let _e167 = fmode;
    let _e168 = tN;
    type3_1 = floor((_e167 - (floor((_e167 / _e168)) * _e168)));
    let _e175 = fmode;
    let _e176 = tN;
    fmode = floor((_e175 / _e176));
    let _e181 = px;
    let _e182 = py;
    let _e185 = py;
    let _e186 = pz;
    let _e189 = coverage_3;
    let _e192 = coverage_3;
    if ((length((_e181 - _e182)) > (length((_e185 - _e186)) * _e189)) && (_e192 < 100f)) {
        {
            type_45 = 0f;
        }
    } else {
        let _e197 = px;
        let _e198 = py;
        let _e201 = px;
        let _e202 = pz;
        if (length((_e197 - _e198)) > length((_e201 - _e202))) {
            {
                let _e206 = type1_1;
                type_45 = _e206;
            }
        } else {
            let _e207 = py;
            let _e208 = pz;
            let _e211 = py;
            let _e212 = px;
            if (length((_e207 - _e208)) > length((_e211 - _e212))) {
                {
                    let _e216 = type2_1;
                    type_45 = _e216;
                }
            } else {
                {
                    let _e217 = type3_1;
                    type_45 = _e217;
                }
            }
        }
    }
    let _e218 = type_45;
    if (_e218 == 0f) {
        {
            let _e221 = fixedBkg;
            if _e221 {
                let _e222 = outPos_1;
                local_2 = _e222;
            } else {
                let _e223 = pos_1;
                local_2 = _e223;
            }
            let _e225 = local_2;
            let _e229 = global.U[0];
            let _e232 = fixedBkg;
            if _e232 {
                let _e233 = outPos_1;
                local_3 = _e233;
            } else {
                let _e234 = pos_1;
                local_3 = _e234;
            }
            let _e236 = local_3;
            let _e245 = textureSample(t_source, samp, ((vec2<f32>((_e225.x / _e229.x), _e236.y) / vec2(2f)) + vec2(0.5f)));
            outCol = _e245;
        }
    } else {
        let _e246 = type_45;
        if (_e246 == 1f) {
            {
                let _e251 = ratio;
                let _e253 = px;
                let _e259 = global.U[0];
                let _e264 = ratio;
                let _e266 = px;
                let _e277 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((-0.99f * _e251), _e253.y).x / _e259.x), vec2<f32>((-0.99f * _e264), _e266.y).y) / vec2(2f)) + vec2(0.5f)));
                a = _e277;
                let _e280 = ratio;
                let _e282 = px;
                let _e288 = global.U[0];
                let _e292 = ratio;
                let _e294 = px;
                let _e305 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((0.99f * _e280), _e282.y).x / _e288.x), vec2<f32>((0.99f * _e292), _e294.y).y) / vec2(2f)) + vec2(0.5f)));
                b_1 = _e305;
                let _e307 = a;
                let _e308 = b_1;
                let _e309 = px;
                outCol = mix(_e307, _e308, vec4(fract(((_e309.x + 1f) / 2f))));
            }
        } else {
            let _e318 = type_45;
            if (_e318 == 2f) {
                {
                    let _e321 = px;
                    let _e329 = global.U[0];
                    let _e332 = px;
                    let _e345 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e321.x, -0.99f).x / _e329.x), vec2<f32>(_e332.x, -0.99f).y) / vec2(2f)) + vec2(0.5f)));
                    a_1 = _e345;
                    let _e347 = px;
                    let _e354 = global.U[0];
                    let _e357 = px;
                    let _e369 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e347.x, 0.99f).x / _e354.x), vec2<f32>(_e357.x, 0.99f).y) / vec2(2f)) + vec2(0.5f)));
                    b_2 = _e369;
                    let _e371 = a_1;
                    let _e372 = b_2;
                    let _e373 = px;
                    outCol = mix(_e371, _e372, vec4(fract(((_e373.y + 1f) / 2f))));
                }
            } else {
                let _e382 = type_45;
                if (_e382 == 3f) {
                    {
                        let _e385 = px;
                        let _e386 = py;
                        let _e389 = intensity_3;
                        step = ((normalize((_e385 - _e386)) * _e389) * 0.2f);
                        let _e394 = pos_1;
                        let _e395 = step;
                        let _e400 = global.U[0];
                        let _e403 = pos_1;
                        let _e404 = step;
                        let _e414 = textureSample(t_source, samp, ((vec2<f32>(((_e394 - _e395).x / _e400.x), (_e403 - _e404).y) / vec2(2f)) + vec2(0.5f)));
                        r_1 = _e414.x;
                        let _e417 = pos_1;
                        let _e421 = global.U[0];
                        let _e424 = pos_1;
                        let _e433 = textureSample(t_source, samp, ((vec2<f32>((_e417.x / _e421.x), _e424.y) / vec2(2f)) + vec2(0.5f)));
                        g_1 = _e433.y;
                        let _e436 = pos_1;
                        let _e437 = step;
                        let _e442 = global.U[0];
                        let _e445 = pos_1;
                        let _e446 = step;
                        let _e456 = textureSample(t_source, samp, ((vec2<f32>(((_e436 + _e437).x / _e442.x), (_e445 + _e446).y) / vec2(2f)) + vec2(0.5f)));
                        b_3 = _e456.z;
                        let _e459 = r_1;
                        let _e460 = g_1;
                        let _e461 = b_3;
                        let _e462 = col;
                        outCol = vec4<f32>(_e459, _e460, _e461, _e462.w);
                    }
                } else {
                    let _e465 = type_45;
                    if (_e465 == 4f) {
                        {
                            let _e468 = pos_1;
                            let _e472 = global.U[0];
                            let _e475 = pos_1;
                            let _e484 = textureSample(t_source, samp, ((vec2<f32>((_e468.x / _e472.x), _e475.y) / vec2(2f)) + vec2(0.5f)));
                            outCol = _e484;
                            let _e485 = outCol;
                            let _e487 = outCol;
                            let _e490 = outCol;
                            let _e495 = intensity_3;
                            g_2 = pow((((_e485.x + _e487.y) + _e490.z) / 3f), (_e495 + 1f));
                            let _e500 = g_2;
                            let _e501 = g_2;
                            let _e502 = g_2;
                            let _e503 = col;
                            outCol = vec4<f32>(_e500, _e501, _e502, _e503.w);
                        }
                    } else {
                        let _e506 = type_45;
                        if (_e506 == 5f) {
                            {
                                let _e510 = intensity_3;
                                s_3 = (40f * _e510);
                                let _e513 = px;
                                let _e514 = s_3;
                                let _e517 = s_3;
                                let _e523 = global.U[0];
                                let _e526 = px;
                                let _e527 = s_3;
                                let _e530 = s_3;
                                let _e541 = textureSample(t_source, samp, ((vec2<f32>(((floor((_e513 * _e514)) / vec2(_e517)).x / _e523.x), (floor((_e526 * _e527)) / vec2(_e530)).y) / vec2(2f)) + vec2(0.5f)));
                                outCol = _e541;
                                let _e542 = outCol;
                                let _e544 = outCol;
                                let _e547 = outCol;
                                g_3 = floor(((((_e542.x + _e544.y) + _e547.z) / 3f) + 0.5f));
                                let _e556 = g_3;
                                let _e557 = g_3;
                                let _e558 = g_3;
                                let _e559 = col;
                                outCol = vec4<f32>(_e556, _e557, _e558, _e559.w);
                            }
                        } else {
                            let _e562 = type_45;
                            if (_e562 == 6f) {
                                {
                                    let _e566 = intensity_3;
                                    s_4 = (40f * _e566);
                                    let _e569 = px;
                                    let _e570 = s_4;
                                    let _e573 = s_4;
                                    let _e579 = global.U[0];
                                    let _e582 = px;
                                    let _e583 = s_4;
                                    let _e586 = s_4;
                                    let _e597 = textureSample(t_source, samp, ((vec2<f32>(((floor((_e569 * _e570)) / vec2(_e573)).x / _e579.x), (floor((_e582 * _e583)) / vec2(_e586)).y) / vec2(2f)) + vec2(0.5f)));
                                    outCol = floor((_e597 + vec4(0.5f)));
                                }
                            } else {
                                let _e602 = type_45;
                                if (_e602 == 7f) {
                                    {
                                        let _e605 = fixedBkg;
                                        if _e605 {
                                            let _e606 = outPos_1;
                                            local_4 = _e606;
                                        } else {
                                            let _e607 = pos_1;
                                            local_4 = _e607;
                                        }
                                        let _e609 = local_4;
                                        let _e611 = px;
                                        let _e623 = pos_1;
                                        let _e626 = intensity_3;
                                        vv = mix(_e609, vec2<f32>(0f, ((fract(((_e611.y + 1f) / 2f)) * 2f) - 1f)), vec2((fract(_e623.x) * _e626)));
                                        let _e631 = vv;
                                        let _e635 = global.U[0];
                                        let _e638 = vv;
                                        let _e647 = textureSample(t_source, samp, ((vec2<f32>((_e631.x / _e635.x), _e638.y) / vec2(2f)) + vec2(0.5f)));
                                        outCol = _e647;
                                    }
                                } else {
                                    let _e648 = type_45;
                                    if (_e648 == 8f) {
                                        {
                                            let _e651 = fixedBkg;
                                            if _e651 {
                                                let _e652 = outPos_1;
                                                local_5 = _e652;
                                            } else {
                                                let _e653 = pos_1;
                                                local_5 = _e653;
                                            }
                                            let _e655 = local_5;
                                            let _e656 = px;
                                            let _e660 = px;
                                            let _e663 = intensity_3;
                                            let _e670 = global.U[0];
                                            let _e673 = fixedBkg;
                                            if _e673 {
                                                let _e674 = outPos_1;
                                                local_6 = _e674;
                                            } else {
                                                let _e675 = pos_1;
                                                local_6 = _e675;
                                            }
                                            let _e677 = local_6;
                                            let _e678 = px;
                                            let _e682 = px;
                                            let _e685 = intensity_3;
                                            let _e697 = textureSample(t_source, samp, ((vec2<f32>((mix(_e655, vec2<f32>(_e656.x, 0f), vec2((fract(_e660.y) * _e663))).x / _e670.x), mix(_e677, vec2<f32>(_e678.x, 0f), vec2((fract(_e682.y) * _e685))).y) / vec2(2f)) + vec2(0.5f)));
                                            outCol = _e697;
                                        }
                                    } else {
                                        let _e698 = type_45;
                                        if (_e698 == 9f) {
                                            {
                                                let _e701 = pos_1;
                                                let _e702 = px;
                                                let _e703 = intensity_3;
                                                let _e711 = global.U[0];
                                                let _e714 = pos_1;
                                                let _e715 = px;
                                                let _e716 = intensity_3;
                                                let _e729 = textureSample(t_source, samp, ((vec2<f32>((mix(_e701, _e702, vec2((_e703 - 0.5f))).x / _e711.x), mix(_e714, _e715, vec2((_e716 - 0.5f))).y) / vec2(2f)) + vec2(0.5f)));
                                                r_2 = _e729.x;
                                                let _e732 = py;
                                                let _e736 = global.U[0];
                                                let _e739 = py;
                                                let _e748 = textureSample(t_source, samp, ((vec2<f32>((_e732.x / _e736.x), _e739.y) / vec2(2f)) + vec2(0.5f)));
                                                g_4 = _e748.y;
                                                let _e751 = pz;
                                                let _e755 = global.U[0];
                                                let _e758 = pz;
                                                let _e767 = textureSample(t_source, samp, ((vec2<f32>((_e751.x / _e755.x), _e758.y) / vec2(2f)) + vec2(0.5f)));
                                                b_4 = _e767.z;
                                                let _e770 = r_2;
                                                let _e771 = g_4;
                                                let _e772 = b_4;
                                                let _e773 = col;
                                                outCol = vec4<f32>(_e770, _e771, _e772, _e773.w);
                                            }
                                        } else {
                                            let _e776 = type_45;
                                            if (_e776 == 10f) {
                                                {
                                                    let _e781 = ratio;
                                                    let _e783 = px;
                                                    let _e789 = global.U[0];
                                                    let _e794 = ratio;
                                                    let _e796 = px;
                                                    let _e807 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((-0.5f * _e781), _e783.y).x / _e789.x), vec2<f32>((-0.5f * _e794), _e796.y).y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e808 = rgbToHsl(_e807);
                                                    a_2 = _e808;
                                                    let _e811 = ratio;
                                                    let _e813 = px;
                                                    let _e819 = global.U[0];
                                                    let _e823 = ratio;
                                                    let _e825 = px;
                                                    let _e836 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((0.5f * _e811), _e813.y).x / _e819.x), vec2<f32>((0.5f * _e823), _e825.y).y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e837 = rgbToHsl(_e836);
                                                    b_5 = _e837;
                                                    let _e839 = a_2;
                                                    let _e844 = b_5;
                                                    if (abs((_e839.z - 0.5f)) < abs((_e844.z - 0.5f))) {
                                                        let _e850 = a_2;
                                                        local_7 = _e850.z;
                                                    } else {
                                                        let _e852 = b_5;
                                                        local_7 = _e852.z;
                                                    }
                                                    let _e855 = local_7;
                                                    l_1 = _e855;
                                                    let _e858 = intensity_3;
                                                    km = ((1f + _e858) / 2f);
                                                    let _e864 = a_2;
                                                    let _e866 = km;
                                                    let _e869 = b_5;
                                                    let _e871 = km;
                                                    let _e873 = px;
                                                    let _e882 = l_1;
                                                    let _e883 = a_2;
                                                    let _e885 = b_5;
                                                    hsl = vec4<f32>(mix(mix(0f, _e864.x, _e866), mix(360f, _e869.x, _e871), fract(((_e873.x + 1f) / 2f))), 1f, _e882, max(_e883.w, _e885.w));
                                                    let _e890 = hsl;
                                                    let _e891 = hslToRgb(_e890);
                                                    outCol = _e891;
                                                }
                                            } else {
                                                let _e892 = type_45;
                                                if (_e892 == 11f) {
                                                    {
                                                        let _e895 = px;
                                                        let _e903 = global.U[0];
                                                        let _e906 = px;
                                                        let _e919 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e895.x, -0.5f).x / _e903.x), vec2<f32>(_e906.x, -0.5f).y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e920 = rgbToHsl(_e919);
                                                        a_3 = _e920;
                                                        let _e922 = px;
                                                        let _e929 = global.U[0];
                                                        let _e932 = px;
                                                        let _e944 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(_e922.x, 0.5f).x / _e929.x), vec2<f32>(_e932.x, 0.5f).y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e945 = rgbToHsl(_e944);
                                                        b_6 = _e945;
                                                        let _e947 = a_3;
                                                        let _e952 = b_6;
                                                        if (abs((_e947.z - 0.5f)) < abs((_e952.z - 0.5f))) {
                                                            let _e958 = a_3;
                                                            local_8 = _e958.z;
                                                        } else {
                                                            let _e960 = b_6;
                                                            local_8 = _e960.z;
                                                        }
                                                        let _e963 = local_8;
                                                        l_2 = _e963;
                                                        let _e966 = intensity_3;
                                                        km_1 = ((1f + _e966) / 2f);
                                                        let _e972 = a_3;
                                                        let _e974 = km_1;
                                                        let _e977 = b_6;
                                                        let _e979 = km_1;
                                                        let _e981 = px;
                                                        let _e990 = l_2;
                                                        let _e991 = a_3;
                                                        let _e993 = b_6;
                                                        hsl_1 = vec4<f32>(mix(mix(0f, _e972.x, _e974), mix(360f, _e977.x, _e979), fract(((_e981.y + 1f) / 2f))), 1f, _e990, max(_e991.w, _e993.w));
                                                        let _e998 = hsl_1;
                                                        let _e999 = hslToRgb(_e998);
                                                        outCol = _e999;
                                                    }
                                                } else {
                                                    let _e1000 = type_45;
                                                    if (_e1000 == 12f) {
                                                        {
                                                            let _e1005 = ratio;
                                                            let _e1007 = px;
                                                            let _e1013 = global.U[0];
                                                            let _e1018 = ratio;
                                                            let _e1020 = px;
                                                            let _e1031 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((-0.5f * _e1005), _e1007.y).x / _e1013.x), vec2<f32>((-0.5f * _e1018), _e1020.y).y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e1032 = rgbToHsl(_e1031);
                                                            a_4 = _e1032;
                                                            let _e1035 = ratio;
                                                            let _e1037 = px;
                                                            let _e1043 = global.U[0];
                                                            let _e1047 = ratio;
                                                            let _e1049 = px;
                                                            let _e1060 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>((0.5f * _e1035), _e1037.y).x / _e1043.x), vec2<f32>((0.5f * _e1047), _e1049.y).y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e1061 = rgbToHsl(_e1060);
                                                            b_7 = _e1061;
                                                            let _e1064 = intensity_3;
                                                            km_2 = ((1f + _e1064) / 2f);
                                                            let _e1072 = a_4;
                                                            let _e1074 = km_2;
                                                            let _e1077 = b_7;
                                                            let _e1079 = km_2;
                                                            let _e1081 = px;
                                                            let _e1089 = a_4;
                                                            let _e1091 = b_7;
                                                            hsl_2 = vec4<f32>(0f, 0f, mix(mix(0f, _e1072.z, _e1074), mix(1f, _e1077.z, _e1079), fract(((_e1081.x + 1f) / 2f))), max(_e1089.w, _e1091.w));
                                                            let _e1096 = hsl_2;
                                                            let _e1097 = hslToRgb(_e1096);
                                                            outCol = _e1097;
                                                        }
                                                    } else {
                                                        let _e1098 = type_45;
                                                        if (_e1098 == 13f) {
                                                            {
                                                                let _e1102 = intensity_3;
                                                                s_5 = (40f * _e1102);
                                                                let _e1105 = px;
                                                                let _e1109 = global.U[0];
                                                                let _e1112 = px;
                                                                let _e1121 = textureSample(t_source, samp, ((vec2<f32>((_e1105.x / _e1109.x), _e1112.y) / vec2(2f)) + vec2(0.5f)));
                                                                outCol = _e1121;
                                                                let _e1122 = outCol;
                                                                let _e1124 = outCol;
                                                                let _e1127 = outCol;
                                                                let _e1132 = px;
                                                                let _e1139 = intensity_3;
                                                                g_5 = floor((((((_e1122.x + _e1124.y) + _e1127.z) / 3f) + ((fract((_e1132.x * 40f)) - 0.5f) * _e1139)) + 0.5f));
                                                                let _e1146 = g_5;
                                                                let _e1147 = g_5;
                                                                let _e1148 = g_5;
                                                                let _e1149 = col;
                                                                outCol = vec4<f32>(_e1146, _e1147, _e1148, _e1149.w);
                                                            }
                                                        } else {
                                                            {
                                                                let _e1152 = pos_1;
                                                                let _e1156 = global.U[0];
                                                                let _e1159 = pos_1;
                                                                let _e1168 = textureSample(t_source, samp, ((vec2<f32>((_e1152.x / _e1156.x), _e1159.y) / vec2(2f)) + vec2(0.5f)));
                                                                outCol = _e1168;
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
    let _e1169 = outCol;
    return _e1169;
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
