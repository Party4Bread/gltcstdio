struct Params {
    U: array<vec4<f32>, 21>,
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

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e16 = sa;
    let _e18 = ca;
    return mat2x2<f32>(vec2<f32>(_e14, _e15), vec2<f32>(-(_e16), _e18));
}

fn f2_(u: vec2<f32>, split: vec2<f32>, N: i32, intensity: f32, balance: f32, variability: f32, randomSeed: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var split_1: vec2<f32>;
    var N_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var r: f32 = 0f;
    var origU: vec2<f32>;
    var i: i32 = 0i;
    var scale: vec2<f32>;
    var center: vec2<f32>;
    var rnd: vec2<f32>;
    var rndx: f32;

    u_1 = u;
    split_1 = split;
    N_1 = N;
    intensity_1 = intensity;
    balance_1 = balance;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    let _e22 = u_1;
    origU = _e22;
    loop {
        let _e26 = i;
        let _e27 = N_1;
        if !((_e26 < _e27)) {
            break;
        }
        {
            let _e35 = u_1;
            let _e37 = split_1;
            let _e40 = u_1;
            let _e42 = split_1;
            if ((_e35.x > _e37.x) && (_e40.y > _e42.y)) {
                {
                    let _e48 = split_1;
                    let _e52 = split_1;
                    scale = (vec2(2f) / vec2<f32>((1f - _e48.x), (1f - _e52.y)));
                    let _e59 = split_1;
                    let _e63 = split_1;
                    center = (vec2<f32>((1f + _e59.x), (1f + _e63.y)) / vec2(2f));
                    let _e70 = r;
                    let _e73 = i;
                    r = (_e70 + (0.25f * pow(0.5f, f32(_e73))));
                }
            } else {
                let _e78 = u_1;
                let _e80 = split_1;
                let _e83 = u_1;
                let _e85 = split_1;
                if ((_e78.x <= _e80.x) && (_e83.y > _e85.y)) {
                    {
                        let _e91 = split_1;
                        let _e95 = split_1;
                        scale = (vec2(2f) / vec2<f32>((1f + _e91.x), (1f - _e95.y)));
                        let _e103 = split_1;
                        let _e107 = split_1;
                        center = (vec2<f32>((-1f + _e103.x), (1f + _e107.y)) / vec2(2f));
                        let _e114 = r;
                        let _e117 = i;
                        r = (_e114 + (0.5f * pow(0.5f, f32(_e117))));
                    }
                } else {
                    let _e122 = u_1;
                    let _e124 = split_1;
                    if (_e122.x > _e124.x) {
                        {
                            let _e129 = split_1;
                            let _e133 = split_1;
                            scale = (vec2(2f) / vec2<f32>((1f - _e129.x), (1f + _e133.y)));
                            let _e140 = split_1;
                            let _e145 = split_1;
                            center = (vec2<f32>((1f + _e140.x), (-1f + _e145.y)) / vec2(2f));
                            let _e152 = r;
                            let _e155 = i;
                            r = (_e152 + (0.75f * pow(0.5f, f32(_e155))));
                        }
                    } else {
                        {
                            let _e162 = split_1;
                            let _e166 = split_1;
                            scale = (vec2(2f) / vec2<f32>((1f + _e162.x), (1f + _e166.y)));
                            let _e174 = split_1;
                            let _e179 = split_1;
                            center = (vec2<f32>((-1f + _e174.x), (-1f + _e179.y)) / vec2(2f));
                            let _e186 = r;
                            let _e189 = i;
                            r = (_e186 + (1f * pow(0.5f, f32(_e189))));
                        }
                    }
                }
            }
            let _e194 = r;
            let _e195 = r;
            let _e197 = randomSeed_1;
            let _e198 = rand2relSeeded(vec2<f32>(_e194, _e195), _e197);
            rnd = _e198;
            let _e200 = rnd;
            let _e204 = variability_1;
            rndx = ((_e200.x + 0.5f) * _e204);
            let _e207 = rndx;
            if (_e207 < 0.1f) {
                let _e212 = center;
                let _e213 = intensity_1;
                let _e216 = u_1;
                let _e217 = center;
                let _e219 = scale;
                u_1 = (mix(vec2(0f), _e212, vec2(_e213)) + ((_e216 - _e217) * _e219));
            } else {
                let _e222 = rndx;
                if (_e222 < 0.2f) {
                    {
                        center = vec2(0f);
                        let _e229 = center;
                        let _e230 = intensity_1;
                        let _e233 = u_1;
                        let _e234 = center;
                        let _e236 = scale;
                        u_1 = (mix(vec2(0f), _e229, vec2(_e230)) + ((_e233 - _e234) * _e236));
                    }
                } else {
                    let _e239 = rndx;
                    if (_e239 < 0.3f) {
                        let _e244 = center;
                        let _e245 = intensity_1;
                        let _e248 = u_1;
                        let _e249 = center;
                        let _e251 = scale;
                        u_1 = -((mix(vec2(0f), _e244, vec2(_e245)) + ((_e248 - _e249) * _e251)));
                    } else {
                        let _e255 = rndx;
                        if (_e255 < 0.4f) {
                            {
                                let _e260 = center;
                                let _e261 = intensity_1;
                                let _e264 = u_1;
                                let _e265 = center;
                                let _e267 = scale;
                                u_1 = (mix(vec2(0f), _e260, vec2(_e261)) + ((_e264 - _e265) * _e267));
                                let _e271 = rotation2_(0.3f);
                                let _e272 = u_1;
                                u_1 = (_e271 * _e272);
                            }
                        } else {
                            let _e274 = rndx;
                            if (_e274 < 0.5f) {
                                let _e277 = origU;
                                u_1 = _e277;
                            } else {
                                let _e278 = rndx;
                                if (_e278 < 0.6f) {
                                    {
                                        let _e281 = u_1;
                                        let _e282 = -(_e281);
                                        u_1 = _e282;
                                        u_1 = _e282;
                                    }
                                } else {
                                    let _e283 = rndx;
                                    if (_e283 < 0.7f) {
                                        {
                                            let _e286 = scale;
                                            scale = (_e286 * 0.5f);
                                            let _e291 = center;
                                            let _e292 = intensity_1;
                                            let _e295 = u_1;
                                            let _e296 = center;
                                            let _e298 = scale;
                                            u_1 = (mix(vec2(0f), _e291, vec2(_e292)) + ((_e295 - _e296) * _e298));
                                        }
                                    } else {
                                        let _e301 = rndx;
                                        if (_e301 < 0.8f) {
                                            {
                                                u_1.x = 0f;
                                            }
                                        } else {
                                            let _e306 = rndx;
                                            if (_e306 < 0.9f) {
                                                {
                                                    u_1.y = 0f;
                                                }
                                            } else {
                                                {
                                                    let _e311 = i;
                                                    if (_e311 < 2i) {
                                                        let _e316 = center;
                                                        let _e317 = intensity_1;
                                                        let _e320 = u_1;
                                                        let _e321 = center;
                                                        let _e323 = scale;
                                                        u_1 = (mix(vec2(0f), _e316, vec2(_e317)) + ((_e320 - _e321) * _e323));
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
            let _e326 = split_1;
            let _e327 = center;
            let _e328 = balance_1;
            split_1 = mix(_e326, _e327, vec2(_e328));
        }
        continuing {
            let _e30 = i;
            i = (_e30 + 1i);
        }
    }
    let _e331 = u_1;
    return _e331;
}

fn getPlacement(u_2: vec2<f32>, style: f32, randomSeed_2: f32) -> f32 {
    var u_3: vec2<f32>;
    var style_1: f32;
    var randomSeed_3: f32;
    var s: f32;
    var d: f32;
    var p: f32;
    var k_4: f32;

    u_3 = u_2;
    style_1 = style;
    randomSeed_3 = randomSeed_2;
    let _e12 = style_1;
    if (_e12 == 0f) {
        return 1f;
    }
    let _e16 = style_1;
    s = abs(_e16);
    let _e20 = s;
    if (_e20 < 0.1f) {
        {
            let _e23 = u_3;
            let _e25 = s;
            d = ((length(_e23) * _e25) / 0.1f);
        }
    } else {
        let _e29 = s;
        if (_e29 < 0.5f) {
            {
                let _e34 = s;
                p = mix(2f, 50f, ((_e34 - 0.1f) / 0.4f));
                let _e41 = u_3;
                let _e44 = p;
                let _e46 = u_3;
                let _e49 = p;
                let _e53 = p;
                d = pow((pow(abs(_e41.x), _e44) + pow(abs(_e46.y), _e49)), (1f / _e53));
            }
        } else {
            {
                let _e56 = s;
                k_4 = ((_e56 - 0.5f) * 2f);
                let _e62 = u_3;
                let _e63 = k_4;
                let _e64 = u_3;
                let _e68 = randomSeed_3;
                let _e69 = rand2relSeeded(floor((_e64 * 2f)), _e68);
                u_3 = (_e62 + (_e63 * _e69));
                let _e72 = k_4;
                if (_e72 > 0.33f) {
                    let _e75 = u_3;
                    let _e76 = k_4;
                    let _e79 = u_3;
                    let _e83 = randomSeed_3;
                    let _e84 = rand2relSeeded(floor((_e79 * 4f)), _e83);
                    u_3 = (_e75 + ((_e76 * 0.5f) * _e84));
                }
                let _e87 = k_4;
                if (_e87 > 0.66f) {
                    let _e90 = u_3;
                    let _e91 = k_4;
                    let _e94 = u_3;
                    let _e98 = randomSeed_3;
                    let _e99 = rand2relSeeded(floor((_e94 * 8f)), _e98);
                    u_3 = (_e90 + ((_e91 * 0.25f) * _e99));
                }
                let _e102 = u_3;
                let _e105 = u_3;
                d = max(abs(_e102.x), abs(_e105.y));
            }
        }
    }
    let _e110 = d;
    let _e112 = style_1;
    return ((1f - _e110) * sign(_e112));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn tf(m: mat3x3<f32>, u_4: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_5: vec2<f32>;

    m_1 = m;
    u_5 = u_4;
    let _e10 = m_1;
    let _e11 = u_5;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn division(pos: vec2<f32>, outPos: vec2<f32>, count: i32, intensity_2: f32, balance_2: f32, border: f32, borderColor: vec4<f32>, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>, variability_2: f32, randomSeed_4: f32, placementTransform: mat3x3<f32>, placementStyle: f32, placementFeather: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var intensity_3: f32;
    var balance_3: f32;
    var border_1: f32;
    var borderColor_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var variability_3: f32;
    var randomSeed_5: f32;
    var placementTransform_1: mat3x3<f32>;
    var placementStyle_1: f32;
    var placementFeather_1: f32;
    var u_6: vec2<f32>;
    var split_2: vec2<f32>;
    var ratio: f32;
    var vRatio: vec2<f32>;
    var v_2: vec2<f32>;
    var p_1: f32;
    var outColor: vec4<f32>;
    var edgeDist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    count_1 = count;
    intensity_3 = intensity_2;
    balance_3 = balance_2;
    border_1 = border;
    borderColor_1 = borderColor;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    variability_3 = variability_2;
    randomSeed_5 = randomSeed_4;
    placementTransform_1 = placementTransform;
    placementStyle_1 = placementStyle;
    placementFeather_1 = placementFeather;
    let _e34 = modelTransform_1;
    let _e36 = pos_1;
    u_6 = (_naga_inverse_3x3_f32(_e34) * vec3<f32>(_e36.x, _e36.y, 1f)).xy;
    let _e44 = u_6;
    split_2 = ((fract(_e44) * 2f) - vec2(1f));
    let _e52 = sourceDim_1;
    let _e54 = sourceDim_1;
    ratio = (_e52.x / _e54.y);
    let _e58 = ratio;
    vRatio = vec2<f32>(_e58, 1f);
    let _e62 = pos_1;
    let _e63 = vRatio;
    let _e65 = split_2;
    let _e66 = count_1;
    let _e67 = intensity_3;
    let _e68 = balance_3;
    let _e69 = variability_3;
    let _e70 = randomSeed_5;
    let _e71 = f2_((_e62 / _e63), _e65, _e66, _e67, _e68, _e69, _e70);
    let _e72 = vRatio;
    v_2 = (_e71 * _e72);
    let _e75 = placementTransform_1;
    let _e77 = pos_1;
    let _e78 = tf(_naga_inverse_3x3_f32(_e75), _e77);
    let _e79 = placementStyle_1;
    let _e80 = randomSeed_5;
    let _e81 = getPlacement(_e78, _e79, _e80);
    p_1 = _e81;
    let _e83 = pos_1;
    let _e84 = v_2;
    let _e87 = placementFeather_1;
    let _e88 = p_1;
    v_2 = mix(_e83, _e84, vec2(smoothstep(-0.001f, _e87, _e88)));
    let _e92 = v_2;
    let _e96 = global.U[0];
    let _e99 = v_2;
    let _e108 = _mirror_wrap(((vec2<f32>((_e92.x / _e96.x), _e99.y) / vec2(2f)) + vec2(0.5f)));
    let _e109 = textureSample(t_source, samp, _e108);
    outColor = _e109;
    let _e112 = v_2;
    let _e116 = ratio;
    let _e117 = v_2;
    edgeDist = abs(min((1f - abs(_e112.y)), (_e116 - abs(_e117.x))));
    let _e124 = edgeDist;
    let _e125 = border_1;
    if (_e124 < _e125) {
        let _e127 = outColor;
        let _e128 = borderColor_1;
        let _e129 = mergeColor(_e127, _e128);
        outColor = _e129;
    }
    let _e130 = outColor;
    return _e130;
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
    let _e71 = global.U[7];
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e83 = global.U[10];
    let _e86 = global.U[4];
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e94 = global.U[12];
    let _e95 = _e94.xyz;
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e115 = global.U[14];
    let _e119 = global.U[15];
    let _e123 = global.U[16];
    let _e124 = _e123.xyz;
    let _e127 = global.U[17];
    let _e128 = _e127.xyz;
    let _e131 = global.U[18];
    let _e132 = _e131.xyz;
    let _e148 = global.U[19];
    let _e152 = global.U[20];
    let _e154 = division((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83, _e86.xy, mat3x3<f32>(vec3<f32>(_e91.x, _e91.y, _e91.z), vec3<f32>(_e95.x, _e95.y, _e95.z), vec3<f32>(_e99.x, _e99.y, _e99.z)), _e115.x, _e119.x, mat3x3<f32>(vec3<f32>(_e124.x, _e124.y, _e124.z), vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z)), _e148.x, _e152.x);
    fragColor = _e154;
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
