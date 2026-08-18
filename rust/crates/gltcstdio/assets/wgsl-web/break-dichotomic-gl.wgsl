struct Params {
    U: array<vec4<f32>, 19>,
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

fn bdDistort(pos: vec2<f32>, a: vec2<f32>, b: vec2<f32>, splits: vec2<f32>, rect: vec4<f32>, intensity: f32, mode: i32, seed_2: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var splits_1: vec2<f32>;
    var rect_1: vec4<f32>;
    var intensity_1: f32;
    var mode_1: i32;
    var seed_3: f32;
    var c: vec2<f32>;
    var rnd: vec2<f32>;
    var rnd_1: vec2<f32>;
    var rnd_2: vec2<f32>;
    var rnd_3: vec2<f32>;
    var delta: vec2<f32>;
    var rnd_4: vec2<f32>;
    var dx: f32;
    var dy: f32;
    var rnd_5: vec2<f32>;
    var dx_1: f32;
    var dy_1: f32;
    var ca: f32;
    var sa: f32;

    pos_1 = pos;
    a_1 = a;
    b_1 = b;
    splits_1 = splits;
    rect_1 = rect;
    intensity_1 = intensity;
    mode_1 = mode;
    seed_3 = seed_2;
    let _e22 = a_1;
    let _e23 = b_1;
    c = ((_e22 + _e23) / vec2(2f));
    let _e29 = mode_1;
    if (_e29 <= 1i) {
        {
            let _e32 = c;
            let _e33 = pos_1;
            let _e34 = c;
            let _e37 = intensity_1;
            return (_e32 + ((_e33 - _e34) * pow(1.05f, _e37)));
        }
    } else {
        let _e41 = mode_1;
        if (_e41 == 2i) {
            {
                let _e44 = splits_1;
                let _e45 = seed_3;
                let _e48 = rand2relSeeded(_e44, (_e45 + 122.1f));
                rnd = _e48;
                let _e50 = pos_1;
                let _e51 = rnd;
                let _e53 = intensity_1;
                return (_e50 + vec2<f32>(((_e51.x * _e53) * 0.02f), 0f));
            }
        } else {
            let _e60 = mode_1;
            if (_e60 == 3i) {
                {
                    let _e63 = splits_1;
                    let _e64 = seed_3;
                    let _e67 = rand2relSeeded(_e63, (_e64 + 122.1f));
                    rnd_1 = _e67;
                    let _e69 = pos_1;
                    let _e71 = rnd_1;
                    let _e73 = intensity_1;
                    return (_e69 + vec2<f32>(0f, ((_e71.y * _e73) * 0.02f)));
                }
            } else {
                let _e79 = mode_1;
                if (_e79 == 4i) {
                    {
                        let _e82 = splits_1;
                        let _e83 = seed_3;
                        let _e86 = rand2relSeeded(_e82, (_e83 + 122.1f));
                        rnd_2 = _e86;
                        let _e88 = rnd_2;
                        let _e91 = rnd_2;
                        if (abs(_e88.x) > abs(_e91.y)) {
                            {
                                let _e95 = pos_1;
                                let _e96 = rnd_2;
                                let _e98 = intensity_1;
                                return (_e95 + vec2<f32>(((_e96.x * _e98) * 0.02f), 0f));
                            }
                        } else {
                            {
                                let _e105 = pos_1;
                                let _e107 = rnd_2;
                                let _e109 = intensity_1;
                                return (_e105 + vec2<f32>(0f, ((_e107.y * _e109) * 0.02f)));
                            }
                        }
                    }
                } else {
                    let _e115 = mode_1;
                    if (_e115 == 5i) {
                        {
                            let _e118 = splits_1;
                            let _e119 = seed_3;
                            let _e122 = rand2relSeeded(_e118, (_e119 + 122.1f));
                            rnd_3 = _e122;
                            let _e124 = rect_1;
                            let _e126 = rect_1;
                            let _e129 = rect_1;
                            let _e131 = rect_1;
                            if ((_e124.z - _e126.x) > (_e129.w - _e131.y)) {
                                {
                                    let _e135 = pos_1;
                                    let _e136 = rnd_3;
                                    let _e138 = intensity_1;
                                    return (_e135 + vec2<f32>(((_e136.x * _e138) * 0.02f), 0f));
                                }
                            } else {
                                {
                                    let _e145 = pos_1;
                                    let _e147 = rnd_3;
                                    let _e149 = intensity_1;
                                    return (_e145 + vec2<f32>(0f, ((_e147.y * _e149) * 0.02f)));
                                }
                            }
                        }
                    } else {
                        let _e155 = mode_1;
                        if (_e155 == 6i) {
                            {
                                let _e158 = pos_1;
                                let _e159 = c;
                                delta = (_e158 - _e159);
                                let _e162 = c;
                                let _e163 = delta;
                                let _e165 = intensity_1;
                                return (_e162 - (_e163 * pow(1.05f, _e165)));
                            }
                        } else {
                            let _e169 = mode_1;
                            if (_e169 <= 8i) {
                                {
                                    let _e172 = splits_1;
                                    let _e173 = seed_3;
                                    let _e176 = rand2relSeeded(_e172, (_e173 + 122.1f));
                                    rnd_4 = _e176;
                                    let _e178 = rect_1;
                                    let _e180 = rect_1;
                                    dx = (_e178.z - _e180.x);
                                    let _e184 = rect_1;
                                    let _e186 = rect_1;
                                    dy = (_e184.w - _e186.y);
                                    let _e190 = dx;
                                    let _e191 = dy;
                                    if (_e190 > _e191) {
                                        {
                                            let _e193 = pos_1;
                                            let _e194 = rnd_4;
                                            let _e197 = dx;
                                            let _e199 = intensity_1;
                                            return (_e193 + vec2<f32>((((sign(_e194.x) * _e197) * _e199) * 0.02f), 0f));
                                        }
                                    } else {
                                        {
                                            let _e206 = pos_1;
                                            let _e208 = rnd_4;
                                            let _e211 = dy;
                                            let _e213 = intensity_1;
                                            return (_e206 + vec2<f32>(0f, (((sign(_e208.y) * _e211) * _e213) * 0.02f)));
                                        }
                                    }
                                }
                            } else {
                                let _e219 = mode_1;
                                if (_e219 == 9i) {
                                    {
                                        let _e222 = splits_1;
                                        let _e223 = seed_3;
                                        let _e226 = rand2relSeeded(_e222, (_e223 + 122.1f));
                                        rnd_5 = _e226;
                                        let _e228 = rect_1;
                                        let _e230 = rect_1;
                                        dx_1 = (_e228.z - _e230.x);
                                        let _e234 = rect_1;
                                        let _e236 = rect_1;
                                        dy_1 = (_e234.w - _e236.y);
                                        let _e240 = dx_1;
                                        let _e241 = dy_1;
                                        if (_e240 > _e241) {
                                            {
                                                let _e243 = pos_1;
                                                let _e244 = rnd_5;
                                                let _e247 = dx_1;
                                                let _e249 = dy_1;
                                                let _e251 = intensity_1;
                                                return (_e243 + vec2<f32>(((((sign(_e244.x) * _e247) / _e249) * _e251) * 0.0005f), 0f));
                                            }
                                        } else {
                                            {
                                                let _e258 = pos_1;
                                                let _e260 = rnd_5;
                                                let _e263 = dy_1;
                                                let _e265 = dx_1;
                                                let _e267 = intensity_1;
                                                return (_e258 + vec2<f32>(0f, ((((sign(_e260.y) * _e263) / _e265) * _e267) * 0.0005f)));
                                            }
                                        }
                                    }
                                } else {
                                    {
                                        let _e273 = intensity_1;
                                        ca = cos((_e273 * 0.1f));
                                        let _e278 = intensity_1;
                                        sa = sin((_e278 * 0.1f));
                                        let _e283 = c;
                                        let _e284 = ca;
                                        let _e285 = sa;
                                        let _e286 = sa;
                                        let _e288 = ca;
                                        let _e292 = pos_1;
                                        let _e293 = c;
                                        return (_e283 + (mat2x2<f32>(vec2<f32>(_e284, _e285), vec2<f32>(-(_e286), _e288)) * (_e292 - _e293)));
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

fn bdRound(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e10 = x_2;
    let _e11 = prec_1;
    let _e16 = prec_1;
    return (floor(((_e10 / _e11) + 0.5f)) * _e16);
}

fn bdWithBias(x_3: f32, b_2: f32) -> f32 {
    var x_4: f32;
    var b_3: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_3 = b_2;
    let _e10 = b_3;
    s = sign(_e10);
    let _e13 = b_3;
    ab = abs(_e13);
    let _e16 = x_4;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn breakDichotomic(pos_2: vec2<f32>, outPos: vec2<f32>, mode_2: i32, count: i32, intensity_2: f32, randomSeed: f32, regularity: f32, thickness: f32, color: vec4<f32>, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_3: i32;
    var count_1: i32;
    var intensity_3: f32;
    var randomSeed_1: f32;
    var regularity_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensityFolded: f32;
    var thicknessThreshold: f32;
    var regularityScaled: f32;
    var bias: vec2<f32>;
    var scaleInv: f32;
    var ratio: f32;
    var pixel: f32;
    var p: vec2<f32>;
    var border: bool = false;
    var rect_2: vec4<f32>;
    var rndStep: f32 = 1f;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var i: f32;
    var rnd_6: vec2<f32>;
    var size: vec2<f32>;
    var variability: f32;
    var Y: f32;
    var X: f32;
    var col: vec4<f32>;
    var outCol: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    mode_3 = mode_2;
    count_1 = count;
    intensity_3 = intensity_2;
    randomSeed_1 = randomSeed;
    regularity_1 = regularity;
    thickness_1 = thickness;
    color_1 = color;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e28 = intensity_3;
    let _e30 = intensity_3;
    let _e32 = intensity_3;
    intensityFolded = (((sign(_e28) * _e30) * _e32) * 100f);
    let _e37 = thickness_1;
    let _e38 = thickness_1;
    thicknessThreshold = ((_e37 * _e38) * 0.1f);
    let _e43 = regularity_1;
    regularityScaled = (_e43 * 2f);
    let _e49 = modelTransform_1[2];
    bias = _e49.xy;
    let _e57 = modelTransform_1[0][0];
    let _e62 = modelTransform_1[0][1];
    scaleInv = (1f / length(vec2<f32>(_e57, _e62)));
    let _e67 = sourceDim_1;
    let _e69 = sourceDim_1;
    let _e73 = bdRound((_e67.x / _e69.y), 0.01f);
    ratio = _e73;
    let _e76 = sourceDim_1;
    pixel = (2f / _e76.y);
    let _e80 = pos_3;
    p = _e80;
    let _e87 = mode_3;
    let _e90 = mode_3;
    let _e94 = mode_3;
    if (((_e87 == 1i) || (_e90 == 8i)) || (_e94 == 9i)) {
        rndStep = 0f;
    }
    loop {
        let _e101 = j;
        let _e102 = count_1;
        if !((_e101 < _e102)) {
            break;
        }
        {
            let _e108 = ratio;
            let _e112 = ratio;
            rect_2 = vec4<f32>(-(_e108), -1f, _e112, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            i = 0f;
            loop {
                let _e129 = i;
                let _e130 = sPos;
                let _e132 = scaleInv;
                if !(((_e129 + _e130) < _e132)) {
                    break;
                }
                {
                    let _e138 = splits_2;
                    let _e139 = randomSeed_1;
                    let _e142 = rndStep;
                    let _e143 = j;
                    let _e147 = rand2relSeeded(_e138, ((_e139 + 122.1f) + (_e142 * f32(_e143))));
                    rnd_6 = _e147;
                    let _e149 = rect_2;
                    let _e151 = rect_2;
                    size = (_e149.zw - _e151.xy);
                    let _e155 = size;
                    let _e157 = pixel;
                    let _e159 = size;
                    let _e161 = pixel;
                    if ((_e155.x < _e157) || (_e159.y < _e161)) {
                        break;
                    }
                    let _e164 = rnd_6;
                    let _e168 = regularityScaled;
                    if ((_e164.x + 0.5f) < _e168) {
                        let _e170 = size;
                        let _e172 = size;
                        horSplit = (_e170.y > _e172.x);
                    }
                    let _e177 = regularityScaled;
                    variability = (1f - max(0f, (_e177 - 1f)));
                    let _e183 = horSplit;
                    if _e183 {
                        {
                            let _e184 = rect_2;
                            let _e186 = rect_2;
                            let _e188 = variability;
                            let _e189 = rnd_6;
                            let _e191 = bias;
                            let _e193 = bdWithBias(_e189.y, _e191.y);
                            Y = mix(_e184.y, _e186.w, ((_e188 * _e193) + 0.5f));
                            let _e199 = Y;
                            let _e200 = p;
                            let _e204 = thicknessThreshold;
                            if (abs((_e199 - _e200.y)) < _e204) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e207 = p;
                            let _e209 = Y;
                            if (_e207.y < _e209) {
                                {
                                    let _e212 = Y;
                                    rect_2.w = _e212;
                                    let _e214 = splits_2;
                                    splits_2.y = (_e214.y + 1f);
                                    let _e218 = sPos;
                                    let _e219 = inverter;
                                    let _e220 = sscale;
                                    sPos = (_e218 + (_e219 * _e220));
                                }
                            } else {
                                {
                                    let _e224 = Y;
                                    rect_2.y = _e224;
                                    let _e226 = splits_2;
                                    splits_2.y = (_e226.y + 100f);
                                    let _e230 = sPos;
                                    let _e232 = inverter;
                                    let _e234 = sscale;
                                    sPos = (_e230 + ((1f - _e232) * _e234));
                                }
                            }
                        }
                    } else {
                        {
                            let _e237 = rect_2;
                            let _e239 = rect_2;
                            let _e241 = variability;
                            let _e242 = rnd_6;
                            let _e244 = bias;
                            let _e246 = bdWithBias(_e242.x, _e244.x);
                            X = mix(_e237.x, _e239.z, ((_e241 * _e246) + 0.5f));
                            let _e252 = X;
                            let _e253 = p;
                            let _e257 = thicknessThreshold;
                            if (abs((_e252 - _e253.x)) < _e257) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e260 = p;
                            let _e262 = X;
                            if (_e260.x < _e262) {
                                {
                                    let _e265 = X;
                                    rect_2.z = _e265;
                                    let _e267 = splits_2;
                                    splits_2.x = (_e267.x + 1f);
                                    let _e271 = sPos;
                                    let _e272 = inverter;
                                    let _e273 = sscale;
                                    sPos = (_e271 + (_e272 * _e273));
                                }
                            } else {
                                {
                                    let _e277 = X;
                                    rect_2.x = _e277;
                                    let _e279 = splits_2;
                                    splits_2.x = (_e279.x + 100f);
                                    let _e283 = sPos;
                                    let _e285 = inverter;
                                    let _e287 = sscale;
                                    sPos = (_e283 + ((1f - _e285) * _e287));
                                }
                            }
                        }
                    }
                    let _e290 = horSplit;
                    horSplit = !(_e290);
                    let _e293 = inverter;
                    inverter = (1f - _e293);
                    let _e295 = sscale;
                    sscale = (_e295 * 0.5f);
                    let _e298 = bias;
                    bias = (_e298 * 0.5f);
                }
                continuing {
                    let _e135 = i;
                    i = (_e135 + 1f);
                }
            }
            let _e301 = border;
            if _e301 {
                break;
            }
            let _e302 = p;
            let _e303 = rect_2;
            let _e305 = rect_2;
            let _e307 = splits_2;
            let _e308 = rect_2;
            let _e309 = intensityFolded;
            let _e310 = mode_3;
            let _e311 = randomSeed_1;
            let _e312 = bdDistort(_e302, _e303.xy, _e305.zw, _e307, _e308, _e309, _e310, _e311);
            p = _e312;
        }
        continuing {
            let _e105 = j;
            j = (_e105 + 1i);
        }
    }
    let _e313 = pos_3;
    let _e317 = global.U[0];
    let _e320 = pos_3;
    let _e330 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e313.x / _e317.x), _e320.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e330;
    let _e333 = border;
    if _e333 {
        {
            let _e334 = col;
            let _e336 = color_1;
            let _e338 = color_1;
            let _e341 = mix(_e334.xyz, _e336.xyz, vec3(_e338.w));
            let _e342 = col;
            outCol = vec4<f32>(_e341.x, _e341.y, _e341.z, _e342.w);
        }
    } else {
        {
            let _e348 = p;
            let _e352 = global.U[0];
            let _e355 = p;
            let _e365 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e348.x / _e352.x), _e355.y) / vec2(2f)) + vec2(0.5f)), 0f);
            outCol = _e365;
        }
    }
    let _e366 = outCol;
    return _e366;
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
    let _e66 = global.U[9];
    let _e71 = global.U[10];
    let _e76 = global.U[11];
    let _e80 = global.U[12];
    let _e84 = global.U[13];
    let _e88 = global.U[14];
    let _e92 = global.U[15];
    let _e95 = global.U[4];
    let _e99 = global.U[16];
    let _e100 = _e99.xyz;
    let _e103 = global.U[17];
    let _e104 = _e103.xyz;
    let _e107 = global.U[18];
    let _e108 = _e107.xyz;
    let _e122 = breakDichotomic((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84.x, _e88.x, _e92, _e95.xy, mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
    fragColor = _e122;
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
