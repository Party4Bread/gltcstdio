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

fn distort9_(pos: vec2<f32>, rect: vec4<f32>, splits: vec2<f32>, intensity: f32, seed_2: f32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var rect_1: vec4<f32>;
    var splits_1: vec2<f32>;
    var intensity_1: f32;
    var seed_3: f32;
    var rnd: vec2<f32>;
    var dx: f32;
    var dy: f32;

    pos_1 = pos;
    rect_1 = rect;
    splits_1 = splits;
    intensity_1 = intensity;
    seed_3 = seed_2;
    let _e16 = splits_1;
    let _e17 = seed_3;
    let _e20 = rand2relSeeded(_e16, (_e17 + 122.1f));
    rnd = _e20;
    let _e22 = rect_1;
    let _e24 = rect_1;
    dx = (_e22.z - _e24.x);
    let _e28 = rect_1;
    let _e30 = rect_1;
    dy = (_e28.w - _e30.y);
    let _e34 = dx;
    let _e35 = dy;
    if (_e34 > _e35) {
        let _e37 = pos_1;
        let _e38 = rnd;
        let _e41 = dx;
        let _e43 = dy;
        let _e45 = intensity_1;
        return (_e37 + vec2<f32>(((((sign(_e38.x) * _e41) / _e43) * _e45) * 0.0005f), 0f));
    } else {
        let _e52 = pos_1;
        let _e54 = rnd;
        let _e57 = dy;
        let _e59 = dx;
        let _e61 = intensity_1;
        return (_e52 + vec2<f32>(0f, ((((sign(_e54.y) * _e57) / _e59) * _e61) * 0.0005f)));
    }
}

fn inWindow(p: vec2<f32>, wc: vec2<f32>, wax: vec2<f32>, wpp: vec2<f32>, winA: f32, winB: f32) -> bool {
    var p_1: vec2<f32>;
    var wc_1: vec2<f32>;
    var wax_1: vec2<f32>;
    var wpp_1: vec2<f32>;
    var winA_1: f32;
    var winB_1: f32;

    p_1 = p;
    wc_1 = wc;
    wax_1 = wax;
    wpp_1 = wpp;
    winA_1 = winA;
    winB_1 = winB;
    let _e18 = p_1;
    let _e19 = wc_1;
    let _e21 = wax_1;
    let _e24 = winA_1;
    let _e26 = p_1;
    let _e27 = wc_1;
    let _e29 = wpp_1;
    let _e32 = winB_1;
    return ((abs(dot((_e18 - _e19), _e21)) <= _e24) && (abs(dot((_e26 - _e27), _e29)) <= _e32));
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

fn windowSliceX(Y: f32, wc_2: vec2<f32>, wax_2: vec2<f32>, winA_2: f32, winB_2: f32) -> vec2<f32> {
    var Y_1: f32;
    var wc_3: vec2<f32>;
    var wax_3: vec2<f32>;
    var winA_3: f32;
    var winB_3: f32;
    var ax: f32;
    var ay: f32;
    var dy_1: f32;
    var lo: f32 = -1000000000000000000000000000000f;
    var hi: f32 = 1000000000000000000000000000000f;
    var a: f32;
    var b: f32;
    var a_1: f32;
    var b_1: f32;

    Y_1 = Y;
    wc_3 = wc_2;
    wax_3 = wax_2;
    winA_3 = winA_2;
    winB_3 = winB_2;
    let _e16 = wax_3;
    ax = _e16.x;
    let _e19 = wax_3;
    ay = _e19.y;
    let _e22 = Y_1;
    let _e23 = wc_3;
    dy_1 = (_e22 - _e23.y);
    let _e32 = ax;
    if (abs(_e32) > 0.000001f) {
        {
            let _e36 = wc_3;
            let _e38 = winA_3;
            let _e40 = ay;
            let _e41 = dy_1;
            let _e44 = ax;
            a = (_e36.x + ((-(_e38) - (_e40 * _e41)) / _e44));
            let _e48 = wc_3;
            let _e50 = winA_3;
            let _e51 = ay;
            let _e52 = dy_1;
            let _e55 = ax;
            b = (_e48.x + ((_e50 - (_e51 * _e52)) / _e55));
            let _e59 = lo;
            let _e60 = a;
            let _e61 = b;
            lo = max(_e59, min(_e60, _e61));
            let _e64 = hi;
            let _e65 = a;
            let _e66 = b;
            hi = min(_e64, max(_e65, _e66));
        }
    } else {
        let _e69 = ay;
        let _e70 = dy_1;
        let _e73 = winA_3;
        if (abs((_e69 * _e70)) > _e73) {
            return vec2<f32>(1000000000000000000000000000000f, -1000000000000000000000000000000f);
        }
    }
    let _e79 = ay;
    if (abs(_e79) > 0.000001f) {
        {
            let _e83 = wc_3;
            let _e85 = ax;
            let _e86 = dy_1;
            let _e88 = winB_3;
            let _e90 = ay;
            a_1 = (_e83.x + (((_e85 * _e86) - _e88) / _e90));
            let _e94 = wc_3;
            let _e96 = ax;
            let _e97 = dy_1;
            let _e99 = winB_3;
            let _e101 = ay;
            b_1 = (_e94.x + (((_e96 * _e97) + _e99) / _e101));
            let _e105 = lo;
            let _e106 = a_1;
            let _e107 = b_1;
            lo = max(_e105, min(_e106, _e107));
            let _e110 = hi;
            let _e111 = a_1;
            let _e112 = b_1;
            hi = min(_e110, max(_e111, _e112));
        }
    } else {
        let _e115 = ax;
        let _e116 = dy_1;
        let _e119 = winB_3;
        if (abs((_e115 * _e116)) > _e119) {
            return vec2<f32>(1000000000000000000000000000000f, -1000000000000000000000000000000f);
        }
    }
    let _e125 = lo;
    let _e126 = hi;
    return vec2<f32>(_e125, _e126);
}

fn windowSliceY(X: f32, wc_4: vec2<f32>, wax_4: vec2<f32>, winA_4: f32, winB_4: f32) -> vec2<f32> {
    var X_1: f32;
    var wc_5: vec2<f32>;
    var wax_5: vec2<f32>;
    var winA_5: f32;
    var winB_5: f32;
    var ax_1: f32;
    var ay_1: f32;
    var dx_1: f32;
    var lo_1: f32 = -1000000000000000000000000000000f;
    var hi_1: f32 = 1000000000000000000000000000000f;
    var a_2: f32;
    var b_2: f32;
    var a_3: f32;
    var b_3: f32;

    X_1 = X;
    wc_5 = wc_4;
    wax_5 = wax_4;
    winA_5 = winA_4;
    winB_5 = winB_4;
    let _e16 = wax_5;
    ax_1 = _e16.x;
    let _e19 = wax_5;
    ay_1 = _e19.y;
    let _e22 = X_1;
    let _e23 = wc_5;
    dx_1 = (_e22 - _e23.x);
    let _e32 = ay_1;
    if (abs(_e32) > 0.000001f) {
        {
            let _e36 = wc_5;
            let _e38 = winA_5;
            let _e40 = ax_1;
            let _e41 = dx_1;
            let _e44 = ay_1;
            a_2 = (_e36.y + ((-(_e38) - (_e40 * _e41)) / _e44));
            let _e48 = wc_5;
            let _e50 = winA_5;
            let _e51 = ax_1;
            let _e52 = dx_1;
            let _e55 = ay_1;
            b_2 = (_e48.y + ((_e50 - (_e51 * _e52)) / _e55));
            let _e59 = lo_1;
            let _e60 = a_2;
            let _e61 = b_2;
            lo_1 = max(_e59, min(_e60, _e61));
            let _e64 = hi_1;
            let _e65 = a_2;
            let _e66 = b_2;
            hi_1 = min(_e64, max(_e65, _e66));
        }
    } else {
        let _e69 = ax_1;
        let _e70 = dx_1;
        let _e73 = winA_5;
        if (abs((_e69 * _e70)) > _e73) {
            return vec2<f32>(1000000000000000000000000000000f, -1000000000000000000000000000000f);
        }
    }
    let _e79 = ax_1;
    if (abs(_e79) > 0.000001f) {
        {
            let _e83 = wc_5;
            let _e85 = ay_1;
            let _e86 = dx_1;
            let _e88 = winB_5;
            let _e90 = ax_1;
            a_3 = (_e83.y + (((_e85 * _e86) - _e88) / _e90));
            let _e94 = wc_5;
            let _e96 = ay_1;
            let _e97 = dx_1;
            let _e99 = winB_5;
            let _e101 = ax_1;
            b_3 = (_e94.y + (((_e96 * _e97) + _e99) / _e101));
            let _e105 = lo_1;
            let _e106 = a_3;
            let _e107 = b_3;
            lo_1 = max(_e105, min(_e106, _e107));
            let _e110 = hi_1;
            let _e111 = a_3;
            let _e112 = b_3;
            hi_1 = min(_e110, max(_e111, _e112));
        }
    } else {
        let _e115 = ay_1;
        let _e116 = dx_1;
        let _e119 = winB_5;
        if (abs((_e115 * _e116)) > _e119) {
            return vec2<f32>(1000000000000000000000000000000f, -1000000000000000000000000000000f);
        }
    }
    let _e125 = lo_1;
    let _e126 = hi_1;
    return vec2<f32>(_e125, _e126);
}

fn withBias(x_3: f32, b_4: f32) -> f32 {
    var x_4: f32;
    var b_5: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_5 = b_4;
    let _e10 = b_5;
    s = sign(_e10);
    let _e13 = b_5;
    ab = abs(_e13);
    let _e16 = x_4;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn schema3b(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>, intensity_2: f32, iterations: i32, pixelation: f32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, aspectRatio: f32, modelTransform: mat3x3<f32>, windowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var intensity_3: f32;
    var iterations_1: i32;
    var pixelation_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var aspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var windowTransform_1: mat3x3<f32>;
    var srcRatio: f32;
    var outAR: f32;
    var pixel: f32;
    var bias: vec2<f32>;
    var scale: f32;
    var th: f32;
    var bm: f32 = 0.001f;
    var wc_6: vec2<f32>;
    var wax_6: vec2<f32>;
    var winA_6: f32;
    var winB_6: f32;
    var wpp_2: vec2<f32>;
    var wl: vec2<f32>;
    var p_2: vec2<f32>;
    var border: bool = false;
    var rect_2: vec4<f32>;
    var regularity: f32;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var b_6: vec2<f32>;
    var i: f32;
    var rnd_1: vec2<f32>;
    var size: vec2<f32>;
    var rc: vec2<f32>;
    var rh: vec2<f32>;
    var ax_2: f32;
    var ay_2: f32;
    var uc: f32;
    var vc: f32;
    var var2_: f32;
    var Y_2: f32;
    var sx: vec2<f32>;
    var c0_: f32;
    var c1_: f32;
    var sy: vec2<f32>;
    var loNear: bool;
    var local: f32;
    var Yn: f32;
    var local_1: f32;
    var X_2: f32;
    var sy_1: vec2<f32>;
    var c0_1: f32;
    var c1_1: f32;
    var sx_1: vec2<f32>;
    var loNear_1: bool;
    var local_2: f32;
    var Xn: f32;
    var local_3: f32;
    var cc: vec2<f32>;
    var ps: vec2<f32>;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    intensity_3 = intensity_2;
    iterations_1 = iterations;
    pixelation_1 = pixelation;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    aspectRatio_1 = aspectRatio;
    modelTransform_1 = modelTransform;
    windowTransform_1 = windowTransform;
    let _e34 = sourceDim_1;
    let _e36 = sourceDim_1;
    let _e40 = rounded((_e34.x / _e36.y), 0.01f);
    srcRatio = _e40;
    let _e42 = outDim_1;
    let _e44 = outDim_1;
    let _e48 = rounded((_e42.x / _e44.y), 0.01f);
    outAR = _e48;
    let _e51 = outDim_1;
    pixel = (2f / _e51.y);
    let _e55 = modelTransform_1;
    bias = (_e55 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e68 = modelTransform_1[0][0];
    let _e73 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e68, _e73)));
    let _e78 = thickness_1;
    th = (_e78 * 0.1f);
    let _e86 = windowTransform_1[2];
    wc_6 = _e86.xy;
    let _e91 = windowTransform_1[0];
    wax_6 = normalize(_e91.xy);
    let _e95 = srcRatio;
    let _e98 = windowTransform_1[0];
    winA_6 = (_e95 * length(_e98.xy));
    let _e105 = windowTransform_1[1];
    winB_6 = length(_e105.xy);
    let _e109 = wax_6;
    let _e112 = wax_6;
    wpp_2 = vec2<f32>(-(_e109.y), _e112.x);
    let _e116 = windowTransform_1;
    let _e118 = uv_1;
    wl = (_naga_inverse_3x3_f32(_e116) * vec3<f32>(_e118.x, _e118.y, 1f)).xy;
    let _e126 = uv_1;
    p_2 = _e126;
    let _e132 = variability_1;
    regularity = (1f - _e132);
    loop {
        let _e137 = j;
        let _e138 = iterations_1;
        if !((_e137 < _e138)) {
            break;
        }
        {
            let _e144 = outAR;
            let _e148 = outAR;
            rect_2 = vec4<f32>(-(_e144), -1f, _e148, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e163 = bias;
            b_6 = _e163;
            i = 0f;
            loop {
                let _e167 = i;
                let _e168 = sPos;
                let _e170 = scale;
                if !(((_e167 + _e168) < _e170)) {
                    break;
                }
                {
                    let _e176 = splits_2;
                    let _e177 = randomSeed_1;
                    let _e180 = rand2relSeeded(_e176, (_e177 + 122.1f));
                    rnd_1 = _e180;
                    let _e182 = rect_2;
                    let _e184 = rect_2;
                    size = (_e182.zw - _e184.xy);
                    let _e188 = size;
                    let _e190 = pixel;
                    let _e192 = size;
                    let _e194 = pixel;
                    if ((_e188.x < _e190) || (_e192.y < _e194)) {
                        break;
                    }
                    let _e197 = j;
                    if (_e197 == 0i) {
                        {
                            let _e201 = rect_2;
                            let _e203 = rect_2;
                            rc = (0.5f * (_e201.xy + _e203.zw));
                            let _e209 = size;
                            rh = (0.5f * _e209);
                            let _e212 = wax_6;
                            ax_2 = abs(_e212.x);
                            let _e216 = wax_6;
                            ay_2 = abs(_e216.y);
                            let _e220 = rc;
                            let _e221 = wc_6;
                            let _e223 = wax_6;
                            uc = dot((_e220 - _e221), _e223);
                            let _e226 = rc;
                            let _e227 = wc_6;
                            let _e229 = wpp_2;
                            vc = dot((_e226 - _e227), _e229);
                            let _e232 = uc;
                            let _e234 = rh;
                            let _e236 = ax_2;
                            let _e239 = rh;
                            let _e241 = ay_2;
                            let _e244 = winA_6;
                            let _e248 = vc;
                            let _e250 = rh;
                            let _e252 = ay_2;
                            let _e255 = rh;
                            let _e257 = ax_2;
                            let _e260 = winB_6;
                            if ((((abs(_e232) + (_e234.x * _e236)) + (_e239.y * _e241)) <= (_e244 + 0.001f)) && (((abs(_e248) + (_e250.x * _e252)) + (_e255.y * _e257)) <= (_e260 + 0.001f))) {
                                break;
                            }
                        }
                    }
                    let _e265 = rnd_1;
                    let _e269 = regularity;
                    if ((_e265.x + 0.5f) < (_e269 * 2f)) {
                        let _e273 = size;
                        let _e275 = size;
                        horSplit = (_e273.y > _e275.x);
                    }
                    let _e280 = regularity;
                    var2_ = (1f - max(0f, ((_e280 * 2f) - 1f)));
                    let _e288 = horSplit;
                    if _e288 {
                        {
                            let _e289 = rect_2;
                            let _e291 = rect_2;
                            let _e293 = var2_;
                            let _e294 = rnd_1;
                            let _e296 = b_6;
                            let _e298 = withBias(_e294.y, _e296.y);
                            Y_2 = mix(_e289.y, _e291.w, ((_e293 * _e298) + 0.5f));
                            let _e304 = j;
                            if (_e304 == 0i) {
                                {
                                    let _e307 = Y_2;
                                    let _e308 = wc_6;
                                    let _e309 = wax_6;
                                    let _e310 = winA_6;
                                    let _e311 = winB_6;
                                    let _e312 = windowSliceX(_e307, _e308, _e309, _e310, _e311);
                                    sx = _e312;
                                    let _e314 = sx;
                                    let _e316 = rect_2;
                                    c0_ = max(_e314.x, _e316.x);
                                    let _e320 = sx;
                                    let _e322 = rect_2;
                                    c1_ = min(_e320.y, _e322.z);
                                    let _e326 = c0_;
                                    let _e327 = c1_;
                                    if (_e326 < _e327) {
                                        {
                                            let _e330 = c0_;
                                            let _e331 = c1_;
                                            let _e334 = wc_6;
                                            let _e335 = wax_6;
                                            let _e336 = winA_6;
                                            let _e337 = winB_6;
                                            let _e338 = windowSliceY((0.5f * (_e330 + _e331)), _e334, _e335, _e336, _e337);
                                            sy = _e338;
                                            let _e340 = Y_2;
                                            let _e341 = sy;
                                            let _e345 = sy;
                                            let _e347 = Y_2;
                                            loNear = (abs((_e340 - _e341.x)) < abs((_e345.y - _e347)));
                                            let _e352 = loNear;
                                            if _e352 {
                                                let _e353 = sy;
                                                local = _e353.x;
                                            } else {
                                                let _e355 = sy;
                                                local = _e355.y;
                                            }
                                            let _e358 = local;
                                            Yn = _e358;
                                            let _e360 = Yn;
                                            let _e361 = rect_2;
                                            let _e364 = Yn;
                                            let _e365 = rect_2;
                                            if !(((_e360 > _e361.y) && (_e364 < _e365.w))) {
                                                let _e370 = loNear;
                                                if _e370 {
                                                    let _e371 = sy;
                                                    local_1 = _e371.y;
                                                } else {
                                                    let _e373 = sy;
                                                    local_1 = _e373.x;
                                                }
                                                let _e376 = local_1;
                                                Yn = _e376;
                                            }
                                            let _e377 = Yn;
                                            let _e378 = rect_2;
                                            let _e381 = Yn;
                                            let _e382 = rect_2;
                                            if ((_e377 > _e378.y) && (_e381 < _e382.w)) {
                                                let _e386 = Yn;
                                                Y_2 = _e386;
                                            }
                                        }
                                    }
                                }
                            }
                            let _e387 = Y_2;
                            let _e388 = p_2;
                            let _e392 = th;
                            let _e394 = j;
                            let _e397 = p_2;
                            let _e399 = Y_2;
                            let _e401 = wc_6;
                            let _e402 = wax_6;
                            let _e403 = wpp_2;
                            let _e404 = winA_6;
                            let _e405 = bm;
                            let _e407 = winB_6;
                            let _e408 = bm;
                            let _e410 = inWindow(vec2<f32>(_e397.x, _e399), _e401, _e402, _e403, (_e404 + _e405), (_e407 + _e408));
                            if ((abs((_e387 - _e388.y)) < _e392) && !(((_e394 == 0i) && _e410))) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e415 = p_2;
                            let _e417 = Y_2;
                            if (_e415.y < _e417) {
                                {
                                    let _e420 = Y_2;
                                    rect_2.w = _e420;
                                    let _e422 = splits_2.y;
                                    splits_2.y = (_e422 + 1f);
                                    let _e425 = sPos;
                                    let _e426 = inverter;
                                    let _e427 = sscale;
                                    sPos = (_e425 + (_e426 * _e427));
                                }
                            } else {
                                {
                                    let _e431 = Y_2;
                                    rect_2.y = _e431;
                                    let _e433 = splits_2;
                                    splits_2.y = (_e433.y + 100f);
                                    let _e437 = sPos;
                                    let _e439 = inverter;
                                    let _e441 = sscale;
                                    sPos = (_e437 + ((1f - _e439) * _e441));
                                }
                            }
                        }
                    } else {
                        {
                            let _e444 = rect_2;
                            let _e446 = rect_2;
                            let _e448 = var2_;
                            let _e449 = rnd_1;
                            let _e451 = b_6;
                            let _e453 = withBias(_e449.x, _e451.x);
                            X_2 = mix(_e444.x, _e446.z, ((_e448 * _e453) + 0.5f));
                            let _e459 = j;
                            if (_e459 == 0i) {
                                {
                                    let _e462 = X_2;
                                    let _e463 = wc_6;
                                    let _e464 = wax_6;
                                    let _e465 = winA_6;
                                    let _e466 = winB_6;
                                    let _e467 = windowSliceY(_e462, _e463, _e464, _e465, _e466);
                                    sy_1 = _e467;
                                    let _e469 = sy_1;
                                    let _e471 = rect_2;
                                    c0_1 = max(_e469.x, _e471.y);
                                    let _e475 = sy_1;
                                    let _e477 = rect_2;
                                    c1_1 = min(_e475.y, _e477.w);
                                    let _e481 = c0_1;
                                    let _e482 = c1_1;
                                    if (_e481 < _e482) {
                                        {
                                            let _e485 = c0_1;
                                            let _e486 = c1_1;
                                            let _e489 = wc_6;
                                            let _e490 = wax_6;
                                            let _e491 = winA_6;
                                            let _e492 = winB_6;
                                            let _e493 = windowSliceX((0.5f * (_e485 + _e486)), _e489, _e490, _e491, _e492);
                                            sx_1 = _e493;
                                            let _e495 = X_2;
                                            let _e496 = sx_1;
                                            let _e500 = sx_1;
                                            let _e502 = X_2;
                                            loNear_1 = (abs((_e495 - _e496.x)) < abs((_e500.y - _e502)));
                                            let _e507 = loNear_1;
                                            if _e507 {
                                                let _e508 = sx_1;
                                                local_2 = _e508.x;
                                            } else {
                                                let _e510 = sx_1;
                                                local_2 = _e510.y;
                                            }
                                            let _e513 = local_2;
                                            Xn = _e513;
                                            let _e515 = Xn;
                                            let _e516 = rect_2;
                                            let _e519 = Xn;
                                            let _e520 = rect_2;
                                            if !(((_e515 > _e516.x) && (_e519 < _e520.z))) {
                                                let _e525 = loNear_1;
                                                if _e525 {
                                                    let _e526 = sx_1;
                                                    local_3 = _e526.y;
                                                } else {
                                                    let _e528 = sx_1;
                                                    local_3 = _e528.x;
                                                }
                                                let _e531 = local_3;
                                                Xn = _e531;
                                            }
                                            let _e532 = Xn;
                                            let _e533 = rect_2;
                                            let _e536 = Xn;
                                            let _e537 = rect_2;
                                            if ((_e532 > _e533.x) && (_e536 < _e537.z)) {
                                                let _e541 = Xn;
                                                X_2 = _e541;
                                            }
                                        }
                                    }
                                }
                            }
                            let _e542 = X_2;
                            let _e543 = p_2;
                            let _e547 = th;
                            let _e549 = j;
                            let _e552 = X_2;
                            let _e553 = p_2;
                            let _e556 = wc_6;
                            let _e557 = wax_6;
                            let _e558 = wpp_2;
                            let _e559 = winA_6;
                            let _e560 = bm;
                            let _e562 = winB_6;
                            let _e563 = bm;
                            let _e565 = inWindow(vec2<f32>(_e552, _e553.y), _e556, _e557, _e558, (_e559 + _e560), (_e562 + _e563));
                            if ((abs((_e542 - _e543.x)) < _e547) && !(((_e549 == 0i) && _e565))) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e570 = p_2;
                            let _e572 = X_2;
                            if (_e570.x < _e572) {
                                {
                                    let _e575 = X_2;
                                    rect_2.z = _e575;
                                    let _e577 = splits_2.x;
                                    splits_2.x = (_e577 + 1f);
                                    let _e580 = sPos;
                                    let _e581 = inverter;
                                    let _e582 = sscale;
                                    sPos = (_e580 + (_e581 * _e582));
                                }
                            } else {
                                {
                                    let _e586 = X_2;
                                    rect_2.x = _e586;
                                    let _e588 = splits_2;
                                    splits_2.x = (_e588.x + 100f);
                                    let _e592 = sPos;
                                    let _e594 = inverter;
                                    let _e596 = sscale;
                                    sPos = (_e592 + ((1f - _e594) * _e596));
                                }
                            }
                        }
                    }
                    let _e599 = horSplit;
                    horSplit = !(_e599);
                    let _e602 = inverter;
                    inverter = (1f - _e602);
                    let _e604 = sscale;
                    sscale = (_e604 * 0.5f);
                    let _e607 = b_6;
                    b_6 = (_e607 * 0.5f);
                }
                continuing {
                    let _e173 = i;
                    i = (_e173 + 1f);
                }
            }
            let _e610 = border;
            if _e610 {
                break;
            }
            let _e611 = j;
            if (_e611 == 0i) {
                {
                    let _e615 = rect_2;
                    let _e617 = rect_2;
                    cc = (0.5f * (_e615.xy + _e617.zw));
                    let _e622 = cc;
                    let _e623 = wc_6;
                    let _e625 = wax_6;
                    let _e628 = winA_6;
                    let _e630 = cc;
                    let _e631 = wc_6;
                    let _e633 = wpp_2;
                    let _e636 = winB_6;
                    if ((abs(dot((_e622 - _e623), _e625)) <= _e628) && (abs(dot((_e630 - _e631), _e633)) <= _e636)) {
                        let _e639 = wl;
                        let _e640 = srcRatio;
                        let _e645 = srcRatio;
                        let _e652 = global.U[0];
                        let _e655 = wl;
                        let _e656 = srcRatio;
                        let _e661 = srcRatio;
                        let _e674 = textureSampleLevel(t_source, samp, ((vec2<f32>((clamp(_e639, vec2<f32>(-(_e640), -1f), vec2<f32>(_e645, 1f)).x / _e652.x), clamp(_e655, vec2<f32>(-(_e656), -1f), vec2<f32>(_e661, 1f)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                        return _e674;
                    }
                }
            }
            let _e675 = p_2;
            let _e676 = rect_2;
            let _e677 = splits_2;
            let _e678 = intensity_3;
            let _e679 = randomSeed_1;
            let _e680 = distort9_(_e675, _e676, _e677, _e678, _e679);
            p_2 = _e680;
        }
        continuing {
            let _e141 = j;
            j = (_e141 + 1i);
        }
    }
    let _e681 = p_2;
    ps = _e681;
    let _e683 = pixelation_1;
    if (_e683 > 0.0001f) {
        let _e686 = p_2;
        let _e687 = pixelation_1;
        let _e694 = pixelation_1;
        ps = (floor(((_e686 / vec2(_e687)) + vec2(0.5f))) * _e694);
    }
    let _e696 = border;
    if _e696 {
        {
            let _e697 = uv_1;
            let _e701 = global.U[0];
            let _e704 = uv_1;
            let _e714 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e697.x / _e701.x), _e704.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e714;
            let _e716 = col;
            let _e718 = color_1;
            let _e720 = color_1;
            let _e723 = mix(_e716.xyz, _e718.xyz, vec3(_e720.w));
            let _e724 = col;
            return vec4<f32>(_e723.x, _e723.y, _e723.z, _e724.w);
        }
    }
    let _e730 = ps;
    let _e734 = global.U[0];
    let _e737 = ps;
    let _e747 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e730.x / _e734.x), _e737.y) / vec2(2f)) + vec2(0.5f)), 0f);
    return _e747;
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
    let _e70 = global.U[5];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[6];
    let _e106 = global.U[14];
    let _e107 = _e106.xyz;
    let _e110 = global.U[15];
    let _e111 = _e110.xyz;
    let _e114 = global.U[16];
    let _e115 = _e114.xyz;
    let _e131 = global.U[17];
    let _e132 = _e131.xyz;
    let _e135 = global.U[18];
    let _e136 = _e135.xyz;
    let _e139 = global.U[19];
    let _e140 = _e139.xyz;
    let _e154 = schema3b((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.xy, _e74.x, i32(_e78.x), _e83.x, _e87.x, _e91.x, _e95, _e98.x, _e102.x, mat3x3<f32>(vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z)), mat3x3<f32>(vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z), vec3<f32>(_e140.x, _e140.y, _e140.z)));
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
