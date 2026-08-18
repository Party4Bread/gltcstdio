struct Params {
    U: array<vec4<f32>, 16>,
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

fn distort(pos: vec2<f32>, a: vec2<f32>, b: vec2<f32>, splits: vec2<f32>, rect: vec4<f32>, intensity: f32, seed_2: f32, mode: i32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var splits_1: vec2<f32>;
    var rect_1: vec4<f32>;
    var intensity_1: f32;
    var seed_3: f32;
    var mode_1: i32;
    var c: vec2<f32>;
    var p: vec2<f32>;
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
    var p_1: vec2<f32>;

    pos_1 = pos;
    a_1 = a;
    b_1 = b;
    splits_1 = splits;
    rect_1 = rect;
    intensity_1 = intensity;
    seed_3 = seed_2;
    mode_1 = mode;
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
            p = (_e32 + ((_e33 - _e34) * pow(1.05f, _e37)));
            let _e42 = p;
            return _e42;
        }
    } else {
        let _e43 = mode_1;
        if (_e43 == 2i) {
            {
                let _e46 = splits_1;
                let _e47 = seed_3;
                let _e50 = rand2relSeeded(_e46, (_e47 + 122.1f));
                rnd = _e50;
                let _e52 = pos_1;
                let _e53 = rnd;
                let _e55 = intensity_1;
                return (_e52 + vec2<f32>(((_e53.x * _e55) * 0.02f), 0f));
            }
        } else {
            let _e62 = mode_1;
            if (_e62 == 3i) {
                {
                    let _e65 = splits_1;
                    let _e66 = seed_3;
                    let _e69 = rand2relSeeded(_e65, (_e66 + 122.1f));
                    rnd_1 = _e69;
                    let _e71 = pos_1;
                    let _e73 = rnd_1;
                    let _e75 = intensity_1;
                    return (_e71 + vec2<f32>(0f, ((_e73.y * _e75) * 0.02f)));
                }
            } else {
                let _e81 = mode_1;
                if (_e81 == 4i) {
                    {
                        let _e84 = splits_1;
                        let _e85 = seed_3;
                        let _e88 = rand2relSeeded(_e84, (_e85 + 122.1f));
                        rnd_2 = _e88;
                        let _e90 = rnd_2;
                        let _e93 = rnd_2;
                        if (abs(_e90.x) > abs(_e93.y)) {
                            {
                                let _e97 = pos_1;
                                let _e98 = rnd_2;
                                let _e100 = intensity_1;
                                return (_e97 + vec2<f32>(((_e98.x * _e100) * 0.02f), 0f));
                            }
                        } else {
                            {
                                let _e107 = pos_1;
                                let _e109 = rnd_2;
                                let _e111 = intensity_1;
                                return (_e107 + vec2<f32>(0f, ((_e109.y * _e111) * 0.02f)));
                            }
                        }
                    }
                } else {
                    let _e117 = mode_1;
                    if (_e117 == 5i) {
                        {
                            let _e120 = splits_1;
                            let _e121 = seed_3;
                            let _e124 = rand2relSeeded(_e120, (_e121 + 122.1f));
                            rnd_3 = _e124;
                            let _e126 = rect_1;
                            let _e128 = rect_1;
                            let _e131 = rect_1;
                            let _e133 = rect_1;
                            if ((_e126.z - _e128.x) > (_e131.w - _e133.y)) {
                                {
                                    let _e137 = pos_1;
                                    let _e138 = rnd_3;
                                    let _e140 = intensity_1;
                                    return (_e137 + vec2<f32>(((_e138.x * _e140) * 0.02f), 0f));
                                }
                            } else {
                                {
                                    let _e147 = pos_1;
                                    let _e149 = rnd_3;
                                    let _e151 = intensity_1;
                                    return (_e147 + vec2<f32>(0f, ((_e149.y * _e151) * 0.02f)));
                                }
                            }
                        }
                    } else {
                        let _e157 = mode_1;
                        if (_e157 == 6i) {
                            {
                                let _e160 = pos_1;
                                let _e161 = c;
                                delta = (_e160 - _e161);
                                let _e164 = c;
                                let _e165 = delta;
                                let _e167 = intensity_1;
                                return (_e164 - (_e165 * pow(1.05f, _e167)));
                            }
                        } else {
                            let _e171 = mode_1;
                            if (_e171 <= 8i) {
                                {
                                    let _e174 = splits_1;
                                    let _e175 = seed_3;
                                    let _e178 = rand2relSeeded(_e174, (_e175 + 122.1f));
                                    rnd_4 = _e178;
                                    let _e180 = rect_1;
                                    let _e182 = rect_1;
                                    dx = (_e180.z - _e182.x);
                                    let _e186 = rect_1;
                                    let _e188 = rect_1;
                                    dy = (_e186.w - _e188.y);
                                    let _e192 = dx;
                                    let _e193 = dy;
                                    if (_e192 > _e193) {
                                        {
                                            let _e195 = pos_1;
                                            let _e196 = rnd_4;
                                            let _e199 = dx;
                                            let _e201 = intensity_1;
                                            return (_e195 + vec2<f32>((((sign(_e196.x) * _e199) * _e201) * 0.02f), 0f));
                                        }
                                    } else {
                                        {
                                            let _e208 = pos_1;
                                            let _e210 = rnd_4;
                                            let _e213 = dy;
                                            let _e215 = intensity_1;
                                            return (_e208 + vec2<f32>(0f, (((sign(_e210.y) * _e213) * _e215) * 0.02f)));
                                        }
                                    }
                                }
                            } else {
                                let _e221 = mode_1;
                                if (_e221 == 9i) {
                                    {
                                        let _e224 = splits_1;
                                        let _e225 = seed_3;
                                        let _e228 = rand2relSeeded(_e224, (_e225 + 122.1f));
                                        rnd_5 = _e228;
                                        let _e230 = rect_1;
                                        let _e232 = rect_1;
                                        dx_1 = (_e230.z - _e232.x);
                                        let _e236 = rect_1;
                                        let _e238 = rect_1;
                                        dy_1 = (_e236.w - _e238.y);
                                        let _e242 = dx_1;
                                        let _e243 = dy_1;
                                        if (_e242 > _e243) {
                                            {
                                                let _e245 = pos_1;
                                                let _e246 = rnd_5;
                                                let _e249 = dx_1;
                                                let _e251 = dy_1;
                                                let _e253 = intensity_1;
                                                return (_e245 + vec2<f32>(((((sign(_e246.x) * _e249) / _e251) * _e253) * 0.0005f), 0f));
                                            }
                                        } else {
                                            {
                                                let _e260 = pos_1;
                                                let _e262 = rnd_5;
                                                let _e265 = dy_1;
                                                let _e267 = dx_1;
                                                let _e269 = intensity_1;
                                                return (_e260 + vec2<f32>(0f, ((((sign(_e262.y) * _e265) / _e267) * _e269) * 0.0005f)));
                                            }
                                        }
                                    }
                                } else {
                                    {
                                        let _e275 = c;
                                        let _e276 = intensity_1;
                                        let _e280 = intensity_1;
                                        let _e284 = intensity_1;
                                        let _e289 = intensity_1;
                                        let _e296 = pos_1;
                                        let _e297 = c;
                                        p_1 = (_e275 + (mat2x2<f32>(vec2<f32>(cos((_e276 * 0.1f)), sin((_e280 * 0.1f))), vec2<f32>(-(sin((_e284 * 0.1f))), cos((_e289 * 0.1f)))) * (_e296 - _e297)));
                                        let _e302 = p_1;
                                        return _e302;
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

fn rounded(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e10 = x_2;
    let _e11 = prec_1;
    let _e16 = prec_1;
    return (floor(((_e10 / _e11) + 0.5f)) * _e16);
}

fn withBias(x_3: f32, b_2: f32) -> f32 {
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

fn dichotomicBreak(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity_2: f32, iterations: i32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, mode_2: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_3: f32;
    var iterations_1: i32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var mode_3: i32;
    var modelTransform_1: mat3x3<f32>;
    var bias: vec2<f32>;
    var scale: f32;
    var ratio: f32;
    var pixel: f32;
    var p_2: vec2<f32>;
    var border: bool = false;
    var rect_2: vec4<f32>;
    var rndStep: f32 = 1f;
    var regularity: f32;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var i: f32;
    var rnd_6: vec2<f32>;
    var size: vec2<f32>;
    var variability_2: f32;
    var Y: f32;
    var X: f32;
    var col: vec4<f32>;
    var local: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_3 = intensity_2;
    iterations_1 = iterations;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    mode_3 = mode_2;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    bias = (_e28 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e41 = modelTransform_1[0][0];
    let _e46 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e41, _e46)));
    let _e51 = sourceDim_1;
    let _e53 = sourceDim_1;
    let _e57 = rounded((_e51.x / _e53.y), 0.01f);
    ratio = _e57;
    let _e60 = sourceDim_1;
    pixel = (2f / _e60.y);
    let _e64 = uv_1;
    p_2 = _e64;
    let _e71 = mode_3;
    let _e74 = mode_3;
    let _e78 = mode_3;
    if (((_e71 == 1i) || (_e74 == 8i)) || (_e78 == 9i)) {
        rndStep = 0f;
    }
    let _e84 = variability_1;
    regularity = (1f - _e84);
    loop {
        let _e89 = j;
        let _e90 = iterations_1;
        if !((_e89 < _e90)) {
            break;
        }
        {
            let _e96 = ratio;
            let _e100 = ratio;
            rect_2 = vec4<f32>(-(_e96), -1f, _e100, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            i = 0f;
            loop {
                let _e117 = i;
                let _e118 = sPos;
                let _e120 = scale;
                if !(((_e117 + _e118) < _e120)) {
                    break;
                }
                {
                    let _e126 = splits_2;
                    let _e127 = randomSeed_1;
                    let _e130 = rndStep;
                    let _e131 = j;
                    let _e135 = rand2relSeeded(_e126, ((_e127 + 122.1f) + (_e130 * f32(_e131))));
                    rnd_6 = _e135;
                    let _e137 = rect_2;
                    let _e139 = rect_2;
                    size = (_e137.zw - _e139.xy);
                    let _e143 = size;
                    let _e145 = pixel;
                    let _e147 = size;
                    let _e149 = pixel;
                    if ((_e143.x < _e145) || (_e147.y < _e149)) {
                        break;
                    }
                    let _e152 = rnd_6;
                    let _e156 = regularity;
                    if ((_e152.x + 0.5f) < (_e156 * 2f)) {
                        let _e160 = size;
                        let _e162 = size;
                        horSplit = (_e160.y > _e162.x);
                    }
                    let _e167 = regularity;
                    variability_2 = (1f - max(0f, ((_e167 * 2f) - 1f)));
                    let _e175 = horSplit;
                    if _e175 {
                        {
                            let _e176 = rect_2;
                            let _e178 = rect_2;
                            let _e180 = variability_2;
                            let _e181 = rnd_6;
                            let _e183 = bias;
                            let _e185 = withBias(_e181.y, _e183.y);
                            Y = mix(_e176.y, _e178.w, ((_e180 * _e185) + 0.5f));
                            let _e191 = Y;
                            let _e192 = p_2;
                            let _e196 = thickness_1;
                            if (abs((_e191 - _e192.y)) < (_e196 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e201 = p_2;
                            let _e203 = Y;
                            if (_e201.y < _e203) {
                                {
                                    let _e206 = Y;
                                    rect_2.w = _e206;
                                    let _e208 = splits_2.y;
                                    splits_2.y = (_e208 + 1f);
                                    let _e211 = sPos;
                                    let _e212 = inverter;
                                    let _e213 = sscale;
                                    sPos = (_e211 + (_e212 * _e213));
                                }
                            } else {
                                {
                                    let _e217 = Y;
                                    rect_2.y = _e217;
                                    let _e219 = splits_2;
                                    splits_2.y = (_e219.y + 100f);
                                    let _e223 = sPos;
                                    let _e225 = inverter;
                                    let _e227 = sscale;
                                    sPos = (_e223 + ((1f - _e225) * _e227));
                                }
                            }
                        }
                    } else {
                        {
                            let _e230 = rect_2;
                            let _e232 = rect_2;
                            let _e234 = variability_2;
                            let _e235 = rnd_6;
                            let _e237 = bias;
                            let _e239 = withBias(_e235.x, _e237.x);
                            X = mix(_e230.x, _e232.z, ((_e234 * _e239) + 0.5f));
                            let _e245 = X;
                            let _e246 = p_2;
                            let _e250 = thickness_1;
                            if (abs((_e245 - _e246.x)) < (_e250 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e255 = p_2;
                            let _e257 = X;
                            if (_e255.x < _e257) {
                                {
                                    let _e260 = X;
                                    rect_2.z = _e260;
                                    let _e262 = splits_2.x;
                                    splits_2.x = (_e262 + 1f);
                                    let _e265 = sPos;
                                    let _e266 = inverter;
                                    let _e267 = sscale;
                                    sPos = (_e265 + (_e266 * _e267));
                                }
                            } else {
                                {
                                    let _e271 = X;
                                    rect_2.x = _e271;
                                    let _e273 = splits_2;
                                    splits_2.x = (_e273.x + 100f);
                                    let _e277 = sPos;
                                    let _e279 = inverter;
                                    let _e281 = sscale;
                                    sPos = (_e277 + ((1f - _e279) * _e281));
                                }
                            }
                        }
                    }
                    let _e284 = horSplit;
                    horSplit = !(_e284);
                    let _e287 = inverter;
                    inverter = (1f - _e287);
                    let _e289 = sscale;
                    sscale = (_e289 * 0.5f);
                    let _e292 = bias;
                    bias = (_e292 * 0.5f);
                }
                continuing {
                    let _e123 = i;
                    i = (_e123 + 1f);
                }
            }
            let _e295 = border;
            if _e295 {
                break;
            }
            let _e296 = p_2;
            let _e297 = rect_2;
            let _e299 = rect_2;
            let _e301 = splits_2;
            let _e302 = rect_2;
            let _e303 = intensity_3;
            let _e304 = randomSeed_1;
            let _e305 = mode_3;
            let _e306 = distort(_e296, _e297.xy, _e299.zw, _e301, _e302, _e303, _e304, _e305);
            p_2 = _e306;
        }
        continuing {
            let _e93 = j;
            j = (_e93 + 1i);
        }
    }
    let _e307 = uv_1;
    let _e311 = global.U[0];
    let _e314 = uv_1;
    let _e323 = textureSample(t_source, samp, ((vec2<f32>((_e307.x / _e311.x), _e314.y) / vec2(2f)) + vec2(0.5f)));
    col = _e323;
    let _e325 = border;
    if _e325 {
        let _e326 = col;
        let _e328 = color_1;
        let _e330 = color_1;
        let _e333 = mix(_e326.xyz, _e328.xyz, vec3(_e330.w));
        let _e334 = col;
        local = vec4<f32>(_e333.x, _e333.y, _e333.z, _e334.w);
    } else {
        let _e340 = p_2;
        let _e344 = global.U[0];
        let _e347 = p_2;
        let _e356 = textureSample(t_source, samp, ((vec2<f32>((_e340.x / _e344.x), _e347.y) / vec2(2f)) + vec2(0.5f)));
        local = _e356;
    }
    let _e358 = local;
    outCol = _e358;
    let _e360 = outCol;
    return _e360;
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e90 = global.U[11];
    let _e94 = global.U[12];
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e122 = dichotomicBreak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, i32(_e74.x), _e79.x, _e83.x, _e87, _e90.x, i32(_e94.x), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
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
