struct Params {
    U: array<vec4<f32>, 34>,
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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;
@group(0) @binding(4) 
var t_source3_: texture_2d<f32>;

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e10 = v_1;
    x = fract((sin(dot(_e10.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e21 = x;
    let _e22 = v_1;
    y = fract((sin(dot(vec2<f32>(_e21, _e22.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e34 = x;
    let _e35 = y;
    return vec2<f32>(_e34, _e35);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e13 = noise_1;
    phase = acos(((2f * _e13) - 1f));
    let _e19 = noise_1;
    freq = (fract((_e19 * 16f)) + 0.5f);
    let _e27 = phase;
    let _e28 = freq;
    let _e29 = k_1;
    return ((1f + cos((_e27 + (_e28 * _e29)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e12 = noise_3;
    let _e14 = k_3;
    let _e15 = varyNoiseSmoothly(_e12.x, _e14);
    let _e16 = noise_3;
    let _e18 = k_3;
    let _e19 = varyNoiseSmoothly(_e16.y, _e18);
    return vec2<f32>(_e15, _e19);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e12 = co_1;
    let _e13 = rand2_(_e12);
    let _e14 = seed_1;
    let _e15 = varyVec2NoiseSmoothly(_e13, _e14);
    return (_e15 - vec2(0.5f));
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
    let _e18 = splits_1;
    let _e19 = seed_3;
    let _e22 = rand2relSeeded(_e18, (_e19 + 122.1f));
    rnd = _e22;
    let _e24 = rect_1;
    let _e26 = rect_1;
    dx = (_e24.z - _e26.x);
    let _e30 = rect_1;
    let _e32 = rect_1;
    dy = (_e30.w - _e32.y);
    let _e36 = dx;
    let _e37 = dy;
    if (_e36 > _e37) {
        let _e39 = pos_1;
        let _e40 = rnd;
        let _e43 = dx;
        let _e45 = dy;
        let _e47 = intensity_1;
        return (_e39 + vec2<f32>(((((sign(_e40.x) * _e43) / _e45) * _e47) * 0.0005f), 0f));
    } else {
        let _e54 = pos_1;
        let _e56 = rnd;
        let _e59 = dy;
        let _e61 = dx;
        let _e63 = intensity_1;
        return (_e54 + vec2<f32>(0f, ((((sign(_e56.y) * _e59) / _e61) * _e63) * 0.0005f)));
    }
}

fn fitCoord(uv: vec2<f32>, rect_2: vec4<f32>, srcRatio: f32, pix: f32) -> vec2<f32> {
    var uv_1: vec2<f32>;
    var rect_3: vec4<f32>;
    var srcRatio_1: f32;
    var pix_1: f32;
    var ap: f32;
    var a: f32;
    var cw: f32;
    var ch: f32;
    var nH: f32;
    var horizontal: bool;
    var local: f32;
    var maxfit: f32;
    var local_1: f32;
    var cap: f32;
    var n: f32;
    var copyW: f32;
    var blockW: f32;
    var startX: f32;
    var lx: f32;
    var local_2: f32;
    var local_3: f32;
    var u: f32;
    var v_2: f32;
    var copyH: f32;
    var blockH: f32;
    var startY: f32;
    var ly: f32;
    var u_1: f32;
    var local_4: f32;
    var local_5: f32;
    var v_3: f32;

    uv_1 = uv;
    rect_3 = rect_2;
    srcRatio_1 = srcRatio;
    pix_1 = pix;
    let _e16 = pix_1;
    ap = -(_e16);
    let _e19 = srcRatio_1;
    a = _e19;
    let _e21 = rect_3;
    let _e23 = rect_3;
    cw = (_e21.z - _e23.x);
    let _e27 = rect_3;
    let _e29 = rect_3;
    ch = (_e27.w - _e29.y);
    let _e33 = cw;
    let _e34 = ch;
    let _e35 = a;
    nH = (_e33 / (_e34 * _e35));
    let _e39 = nH;
    horizontal = (_e39 >= 1f);
    let _e43 = horizontal;
    if _e43 {
        let _e44 = nH;
        local = floor(_e44);
    } else {
        let _e47 = nH;
        local = floor((1f / _e47));
    }
    let _e51 = local;
    maxfit = max(_e51, 1f);
    let _e55 = ap;
    if (_e55 >= 0.99f) {
        local_1 = 1000000f;
    } else {
        let _e61 = ap;
        local_1 = floor(pow(2f, ((10f * _e61) - 1f)));
    }
    let _e68 = local_1;
    cap = _e68;
    let _e70 = maxfit;
    let _e71 = cap;
    n = min(_e70, _e71);
    let _e74 = horizontal;
    if _e74 {
        {
            let _e75 = ch;
            let _e76 = a;
            copyW = (_e75 * _e76);
            let _e79 = n;
            let _e80 = copyW;
            blockW = (_e79 * _e80);
            let _e83 = rect_3;
            let _e85 = cw;
            let _e86 = blockW;
            startX = (_e83.x + ((_e85 - _e86) * 0.5f));
            let _e92 = uv_1;
            let _e94 = startX;
            lx = (_e92.x - _e94);
            let _e97 = n;
            if (_e97 <= 0f) {
                let _e100 = lx;
                if (_e100 < 0f) {
                    local_2 = 0f;
                } else {
                    local_2 = 1f;
                }
                let _e106 = local_2;
                local_3 = _e106;
            } else {
                let _e107 = lx;
                let _e109 = blockW;
                let _e113 = copyW;
                local_3 = fract((clamp(_e107, 0f, (_e109 - 0.00001f)) / _e113));
            }
            let _e117 = local_3;
            u = _e117;
            let _e119 = uv_1;
            let _e121 = rect_3;
            let _e124 = ch;
            v_2 = ((_e119.y - _e121.y) / _e124);
            let _e127 = u;
            let _e132 = a;
            let _e134 = v_2;
            return vec2<f32>((((_e127 - 0.5f) * 2f) * _e132), ((_e134 - 0.5f) * 2f));
        }
    } else {
        {
            let _e140 = cw;
            let _e141 = a;
            copyH = (_e140 / _e141);
            let _e144 = n;
            let _e145 = copyH;
            blockH = (_e144 * _e145);
            let _e148 = rect_3;
            let _e150 = ch;
            let _e151 = blockH;
            startY = (_e148.y + ((_e150 - _e151) * 0.5f));
            let _e157 = uv_1;
            let _e159 = startY;
            ly = (_e157.y - _e159);
            let _e162 = uv_1;
            let _e164 = rect_3;
            let _e167 = cw;
            u_1 = ((_e162.x - _e164.x) / _e167);
            let _e170 = n;
            if (_e170 <= 0f) {
                let _e173 = ly;
                if (_e173 < 0f) {
                    local_4 = 0f;
                } else {
                    local_4 = 1f;
                }
                let _e179 = local_4;
                local_5 = _e179;
            } else {
                let _e180 = ly;
                let _e182 = blockH;
                let _e186 = copyH;
                local_5 = fract((clamp(_e180, 0f, (_e182 - 0.00001f)) / _e186));
            }
            let _e190 = local_5;
            v_3 = _e190;
            let _e192 = u_1;
            let _e197 = a;
            let _e199 = v_3;
            return vec2<f32>((((_e192 - 0.5f) * 2f) * _e197), ((_e199 - 0.5f) * 2f));
        }
    }
}

fn inscribedRect(wt: mat3x3<f32>, srcRatio_2: f32) -> vec4<f32> {
    var wt_1: mat3x3<f32>;
    var srcRatio_3: f32;
    var ws: f32;
    var winA: f32;
    var winB: f32;
    var wax: vec2<f32>;
    var c1_: f32;
    var s1_: f32;
    var sin2_: f32;
    var W: f32;
    var H: f32;
    var det: f32;
    var wc: vec2<f32>;

    wt_1 = wt;
    srcRatio_3 = srcRatio_2;
    let _e14 = wt_1[1];
    ws = length(_e14.xy);
    let _e18 = srcRatio_3;
    let _e21 = wt_1[0];
    winA = (_e18 * length(_e21.xy));
    let _e26 = ws;
    winB = _e26;
    let _e30 = wt_1[0];
    wax = normalize(_e30.xy);
    let _e34 = wax;
    c1_ = abs(_e34.x);
    let _e38 = wax;
    s1_ = abs(_e38.y);
    let _e43 = c1_;
    let _e45 = s1_;
    sin2_ = ((2f * _e43) * _e45);
    let _e50 = winA;
    let _e51 = winB;
    let _e52 = sin2_;
    if (_e50 <= (_e51 * _e52)) {
        {
            let _e55 = winA;
            let _e57 = c1_;
            W = (_e55 / (2f * _e57));
            let _e60 = winA;
            let _e62 = s1_;
            H = (_e60 / (2f * _e62));
        }
    } else {
        let _e65 = winB;
        let _e66 = winA;
        let _e67 = sin2_;
        if (_e65 <= (_e66 * _e67)) {
            {
                let _e70 = winB;
                let _e72 = s1_;
                W = (_e70 / (2f * _e72));
                let _e75 = winB;
                let _e77 = c1_;
                H = (_e75 / (2f * _e77));
            }
        } else {
            {
                let _e80 = c1_;
                let _e81 = c1_;
                let _e83 = s1_;
                let _e84 = s1_;
                det = ((_e80 * _e81) - (_e83 * _e84));
                let _e88 = winA;
                let _e89 = c1_;
                let _e91 = winB;
                let _e92 = s1_;
                let _e95 = det;
                W = (((_e88 * _e89) - (_e91 * _e92)) / _e95);
                let _e97 = winB;
                let _e98 = c1_;
                let _e100 = winA;
                let _e101 = s1_;
                let _e104 = det;
                H = (((_e97 * _e98) - (_e100 * _e101)) / _e104);
            }
        }
    }
    let _e106 = W;
    W = max(_e106, 0f);
    let _e109 = H;
    H = max(_e109, 0f);
    let _e114 = wt_1[2];
    wc = _e114.xy;
    let _e117 = wc;
    let _e119 = W;
    let _e121 = wc;
    let _e123 = H;
    let _e125 = wc;
    let _e127 = W;
    let _e129 = wc;
    let _e131 = H;
    return vec4<f32>((_e117.x - _e119), (_e121.y - _e123), (_e125.x + _e127), (_e129.y + _e131));
}

fn rounded(x_1: f32, prec: f32) -> f32 {
    var x_2: f32;
    var prec_1: f32;

    x_2 = x_1;
    prec_1 = prec;
    let _e12 = x_2;
    let _e13 = prec_1;
    let _e18 = prec_1;
    return (floor(((_e12 / _e13) + 0.5f)) * _e18);
}

fn withBias(x_3: f32, b: f32) -> f32 {
    var x_4: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_4 = x_3;
    b_1 = b;
    let _e12 = b_1;
    s = sign(_e12);
    let _e15 = b_1;
    ab = abs(_e15);
    let _e18 = x_4;
    let _e22 = s;
    let _e24 = ab;
    return (pow((_e18 + 0.5f), pow(2f, (-(_e22) * _e24))) - 0.5f);
}

fn dichotomicSampling(uv_2: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, source2Dim: vec2<f32>, source3Dim: vec2<f32>, outDim: vec2<f32>, source2_specified: i32, source3_specified: i32, pixelation1_: f32, pixelation2_: f32, pixelation3_: f32, iterations: i32, intensity_2: f32, balance: f32, proximity: f32, variability: f32, randomSeed: f32, color: vec4<f32>, thickness: f32, aspectRatio: f32, modelTransform: mat3x3<f32>, windowTransform: mat3x3<f32>, windowTransform2_: mat3x3<f32>, windowTransform3_: mat3x3<f32>) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var source3Dim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var source2_specified_1: i32;
    var source3_specified_1: i32;
    var pixelation1_1: f32;
    var pixelation2_1: f32;
    var pixelation3_1: f32;
    var iterations_1: i32;
    var intensity_3: f32;
    var balance_1: f32;
    var proximity_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var aspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var windowTransform_1: mat3x3<f32>;
    var windowTransform2_1: mat3x3<f32>;
    var windowTransform3_1: mat3x3<f32>;
    var srcRatio_4: f32;
    var outAR: f32;
    var pixel: f32;
    var has2_: bool;
    var has3_: bool;
    var local_6: f32;
    var src2Ratio: f32;
    var local_7: f32;
    var src3Ratio: f32;
    var bias: vec2<f32>;
    var scale: f32;
    var th: f32;
    var regularity: f32;
    var var2_: f32;
    var ws1_: f32;
    var wl1_: vec2<f32>;
    var sxg1_: f32;
    var syg1_: f32;
    var frame: bool;
    var ws2_: f32;
    var wl2_: vec2<f32>;
    var sxg2_: f32;
    var syg2_: f32;
    var ws3_: f32;
    var wl3_: vec2<f32>;
    var sxg3_: f32;
    var syg3_: f32;
    var col: vec4<f32>;
    var E1_: vec4<f32>;
    var local_8: vec4<f32>;
    var E2_: vec4<f32>;
    var local_9: vec4<f32>;
    var E3_: vec4<f32>;
    var p: vec2<f32>;
    var shatterBorder: bool = false;
    var rect_4: vec4<f32>;
    var cellId: vec2<f32> = vec2(0f);
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var b_2: vec2<f32>;
    var i: f32;
    var rnd_1: vec2<f32>;
    var size: vec2<f32>;
    var Y: f32;
    var local_10: f32;
    var local_11: f32;
    var local_12: f32;
    var X: f32;
    var local_13: f32;
    var local_14: f32;
    var local_15: f32;
    var cc: vec2<f32>;
    var d1_: f32;
    var d2_: f32;
    var d3_: f32;
    var w1_: f32;
    var local_16: f32;
    var w2_: f32;
    var local_17: f32;
    var w3_: f32;
    var proxPos: f32;
    var rnd2_: f32;
    var s_1: f32;
    var local_18: i32;
    var local_19: i32;
    var src: i32;
    var local_20: f32;
    var local_21: f32;
    var pixSel: f32;
    var local_22: f32;
    var local_23: f32;
    var srcSelRatio: f32;
    var crect: vec4<f32>;
    var cborder: bool = false;
    var horSplit_1: bool = true;
    var splits_3: vec2<f32> = vec2(0f);
    var sPos_1: f32 = 0f;
    var sscale_1: f32 = 0.5f;
    var inverter_1: f32 = 0f;
    var b_3: vec2<f32>;
    var i_1: f32 = 0f;
    var rnd_2: vec2<f32>;
    var size_1: vec2<f32>;
    var Y_1: f32;
    var local_24: f32;
    var local_25: f32;
    var local_26: f32;
    var X_1: f32;
    var local_27: f32;
    var local_28: f32;
    var local_29: f32;
    var col_1: vec4<f32>;
    var fc: vec2<f32>;
    var col_2: vec4<f32>;
    var sp: vec2<f32>;

    uv_3 = uv_2;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    source2Dim_1 = source2Dim;
    source3Dim_1 = source3Dim;
    outDim_1 = outDim;
    source2_specified_1 = source2_specified;
    source3_specified_1 = source3_specified;
    pixelation1_1 = pixelation1_;
    pixelation2_1 = pixelation2_;
    pixelation3_1 = pixelation3_;
    iterations_1 = iterations;
    intensity_3 = intensity_2;
    balance_1 = balance;
    proximity_1 = proximity;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    thickness_1 = thickness;
    aspectRatio_1 = aspectRatio;
    modelTransform_1 = modelTransform;
    windowTransform_1 = windowTransform;
    windowTransform2_1 = windowTransform2_;
    windowTransform3_1 = windowTransform3_;
    let _e56 = sourceDim_1;
    let _e58 = sourceDim_1;
    let _e62 = rounded((_e56.x / _e58.y), 0.01f);
    srcRatio_4 = _e62;
    let _e64 = outDim_1;
    let _e66 = outDim_1;
    let _e70 = rounded((_e64.x / _e66.y), 0.01f);
    outAR = _e70;
    let _e73 = outDim_1;
    pixel = (2f / _e73.y);
    let _e77 = source2_specified_1;
    has2_ = (_e77 != 0i);
    let _e81 = source3_specified_1;
    has3_ = (_e81 != 0i);
    let _e85 = has2_;
    if _e85 {
        let _e86 = source2Dim_1;
        let _e88 = source2Dim_1;
        let _e92 = rounded((_e86.x / _e88.y), 0.01f);
        local_6 = _e92;
    } else {
        let _e93 = srcRatio_4;
        local_6 = _e93;
    }
    let _e95 = local_6;
    src2Ratio = _e95;
    let _e97 = has3_;
    if _e97 {
        let _e98 = source3Dim_1;
        let _e100 = source3Dim_1;
        let _e104 = rounded((_e98.x / _e100.y), 0.01f);
        local_7 = _e104;
    } else {
        let _e105 = srcRatio_4;
        local_7 = _e105;
    }
    let _e107 = local_7;
    src3Ratio = _e107;
    let _e109 = modelTransform_1;
    bias = (_e109 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e122 = modelTransform_1[0][0];
    let _e127 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e122, _e127)));
    let _e132 = thickness_1;
    th = (_e132 * 0.1f);
    let _e137 = variability_1;
    regularity = (1f - _e137);
    let _e142 = regularity;
    var2_ = (1f - max(0f, ((_e142 * 2f) - 1f)));
    let _e152 = windowTransform_1[1];
    ws1_ = length(_e152.xy);
    let _e156 = windowTransform_1;
    let _e158 = uv_3;
    wl1_ = (_naga_inverse_3x3_f32(_e156) * vec3<f32>(_e158.x, _e158.y, 1f)).xy;
    let _e166 = srcRatio_4;
    let _e167 = wl1_;
    let _e171 = ws1_;
    sxg1_ = ((_e166 - abs(_e167.x)) * _e171);
    let _e175 = wl1_;
    let _e179 = ws1_;
    syg1_ = ((1f - abs(_e175.y)) * _e179);
    let _e182 = sxg1_;
    let _e185 = syg1_;
    if ((_e182 > 0f) && (_e185 > 0f)) {
        let _e189 = wl1_;
        let _e193 = global.U[0];
        let _e196 = wl1_;
        let _e205 = textureSample(t_source, samp, ((vec2<f32>((_e189.x / _e193.x), _e196.y) / vec2(2f)) + vec2(0.5f)));
        return _e205;
    }
    let _e206 = sxg1_;
    let _e208 = th;
    let _e210 = syg1_;
    let _e211 = th;
    let _e215 = syg1_;
    let _e217 = th;
    let _e219 = sxg1_;
    let _e220 = th;
    frame = (((abs(_e206) < _e208) && (_e210 > -(_e211))) || ((abs(_e215) < _e217) && (_e219 > -(_e220))));
    let _e226 = has2_;
    if _e226 {
        {
            let _e229 = windowTransform2_1[1];
            ws2_ = length(_e229.xy);
            let _e233 = windowTransform2_1;
            let _e235 = uv_3;
            wl2_ = (_naga_inverse_3x3_f32(_e233) * vec3<f32>(_e235.x, _e235.y, 1f)).xy;
            let _e243 = src2Ratio;
            let _e244 = wl2_;
            let _e248 = ws2_;
            sxg2_ = ((_e243 - abs(_e244.x)) * _e248);
            let _e252 = wl2_;
            let _e256 = ws2_;
            syg2_ = ((1f - abs(_e252.y)) * _e256);
            let _e259 = sxg2_;
            let _e262 = syg2_;
            if ((_e259 > 0f) && (_e262 > 0f)) {
                let _e266 = wl2_;
                let _e270 = global.U[0];
                let _e273 = wl2_;
                let _e282 = textureSample(t_source2_, samp, ((vec2<f32>((_e266.x / _e270.x), _e273.y) / vec2(2f)) + vec2(0.5f)));
                return _e282;
            }
            let _e283 = frame;
            let _e284 = sxg2_;
            let _e286 = th;
            let _e288 = syg2_;
            let _e289 = th;
            let _e294 = syg2_;
            let _e296 = th;
            let _e298 = sxg2_;
            let _e299 = th;
            frame = ((_e283 || ((abs(_e284) < _e286) && (_e288 > -(_e289)))) || ((abs(_e294) < _e296) && (_e298 > -(_e299))));
        }
    }
    let _e304 = has3_;
    if _e304 {
        {
            let _e307 = windowTransform3_1[1];
            ws3_ = length(_e307.xy);
            let _e311 = windowTransform3_1;
            let _e313 = uv_3;
            wl3_ = (_naga_inverse_3x3_f32(_e311) * vec3<f32>(_e313.x, _e313.y, 1f)).xy;
            let _e321 = src3Ratio;
            let _e322 = wl3_;
            let _e326 = ws3_;
            sxg3_ = ((_e321 - abs(_e322.x)) * _e326);
            let _e330 = wl3_;
            let _e334 = ws3_;
            syg3_ = ((1f - abs(_e330.y)) * _e334);
            let _e337 = sxg3_;
            let _e340 = syg3_;
            if ((_e337 > 0f) && (_e340 > 0f)) {
                let _e344 = wl3_;
                let _e348 = global.U[0];
                let _e351 = wl3_;
                let _e360 = textureSample(t_source3_, samp, ((vec2<f32>((_e344.x / _e348.x), _e351.y) / vec2(2f)) + vec2(0.5f)));
                return _e360;
            }
            let _e361 = frame;
            let _e362 = sxg3_;
            let _e364 = th;
            let _e366 = syg3_;
            let _e367 = th;
            let _e372 = syg3_;
            let _e374 = th;
            let _e376 = sxg3_;
            let _e377 = th;
            frame = ((_e361 || ((abs(_e362) < _e364) && (_e366 > -(_e367)))) || ((abs(_e372) < _e374) && (_e376 > -(_e377))));
        }
    }
    let _e382 = frame;
    if _e382 {
        {
            let _e383 = uv_3;
            let _e387 = global.U[0];
            let _e390 = uv_3;
            let _e399 = textureSample(t_source, samp, ((vec2<f32>((_e383.x / _e387.x), _e390.y) / vec2(2f)) + vec2(0.5f)));
            col = _e399;
            let _e401 = col;
            let _e403 = color_1;
            let _e405 = color_1;
            let _e408 = mix(_e401.xyz, _e403.xyz, vec3(_e405.w));
            let _e409 = col;
            return vec4<f32>(_e408.x, _e408.y, _e408.z, _e409.w);
        }
    }
    let _e415 = windowTransform_1;
    let _e416 = srcRatio_4;
    let _e417 = inscribedRect(_e415, _e416);
    E1_ = _e417;
    let _e419 = has2_;
    if _e419 {
        let _e420 = windowTransform2_1;
        let _e421 = src2Ratio;
        let _e422 = inscribedRect(_e420, _e421);
        local_8 = _e422;
    } else {
        local_8 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e431 = local_8;
    E2_ = _e431;
    let _e433 = has3_;
    if _e433 {
        let _e434 = windowTransform3_1;
        let _e435 = src3Ratio;
        let _e436 = inscribedRect(_e434, _e435);
        local_9 = _e436;
    } else {
        local_9 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e445 = local_9;
    E3_ = _e445;
    let _e447 = uv_3;
    p = _e447;
    let _e451 = outAR;
    let _e455 = outAR;
    rect_4 = vec4<f32>(-(_e451), -1f, _e455, 1f);
    loop {
        let _e464 = j;
        let _e465 = iterations_1;
        if !((_e464 < _e465)) {
            break;
        }
        {
            let _e471 = outAR;
            let _e475 = outAR;
            rect_4 = vec4<f32>(-(_e471), -1f, _e475, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e490 = bias;
            b_2 = _e490;
            i = 0f;
            loop {
                let _e494 = i;
                let _e495 = sPos;
                let _e497 = scale;
                if !(((_e494 + _e495) < _e497)) {
                    break;
                }
                {
                    let _e503 = splits_2;
                    let _e504 = randomSeed_1;
                    let _e507 = rand2relSeeded(_e503, (_e504 + 122.1f));
                    rnd_1 = _e507;
                    let _e509 = rect_4;
                    let _e511 = rect_4;
                    size = (_e509.zw - _e511.xy);
                    let _e515 = size;
                    let _e517 = pixel;
                    let _e519 = size;
                    let _e521 = pixel;
                    if ((_e515.x < _e517) || (_e519.y < _e521)) {
                        break;
                    }
                    let _e524 = rnd_1;
                    let _e528 = regularity;
                    if ((_e524.x + 0.5f) < (_e528 * 2f)) {
                        let _e532 = size;
                        let _e534 = size;
                        horSplit = (_e532.y > _e534.x);
                    }
                    let _e537 = horSplit;
                    if _e537 {
                        {
                            let _e538 = rect_4;
                            let _e540 = rect_4;
                            let _e542 = var2_;
                            let _e543 = rnd_1;
                            let _e545 = b_2;
                            let _e547 = withBias(_e543.y, _e545.y);
                            Y = mix(_e538.y, _e540.w, ((_e542 * _e547) + 0.5f));
                            let _e553 = rect_4;
                            let _e555 = E1_;
                            let _e558 = rect_4;
                            let _e560 = E1_;
                            let _e564 = Y;
                            let _e565 = E1_;
                            let _e569 = Y;
                            let _e570 = E1_;
                            if ((((_e553.x < _e555.z) && (_e558.z > _e560.x)) && (_e564 > _e565.y)) && (_e569 < _e570.w)) {
                                let _e574 = Y;
                                let _e575 = E1_;
                                let _e578 = E1_;
                                let _e580 = Y;
                                if ((_e574 - _e575.y) < (_e578.w - _e580)) {
                                    let _e583 = E1_;
                                    local_10 = _e583.y;
                                } else {
                                    let _e585 = E1_;
                                    local_10 = _e585.w;
                                }
                                let _e588 = local_10;
                                Y = _e588;
                            }
                            let _e589 = rect_4;
                            let _e591 = E2_;
                            let _e594 = rect_4;
                            let _e596 = E2_;
                            let _e600 = Y;
                            let _e601 = E2_;
                            let _e605 = Y;
                            let _e606 = E2_;
                            if ((((_e589.x < _e591.z) && (_e594.z > _e596.x)) && (_e600 > _e601.y)) && (_e605 < _e606.w)) {
                                let _e610 = Y;
                                let _e611 = E2_;
                                let _e614 = E2_;
                                let _e616 = Y;
                                if ((_e610 - _e611.y) < (_e614.w - _e616)) {
                                    let _e619 = E2_;
                                    local_11 = _e619.y;
                                } else {
                                    let _e621 = E2_;
                                    local_11 = _e621.w;
                                }
                                let _e624 = local_11;
                                Y = _e624;
                            }
                            let _e625 = rect_4;
                            let _e627 = E3_;
                            let _e630 = rect_4;
                            let _e632 = E3_;
                            let _e636 = Y;
                            let _e637 = E3_;
                            let _e641 = Y;
                            let _e642 = E3_;
                            if ((((_e625.x < _e627.z) && (_e630.z > _e632.x)) && (_e636 > _e637.y)) && (_e641 < _e642.w)) {
                                let _e646 = Y;
                                let _e647 = E3_;
                                let _e650 = E3_;
                                let _e652 = Y;
                                if ((_e646 - _e647.y) < (_e650.w - _e652)) {
                                    let _e655 = E3_;
                                    local_12 = _e655.y;
                                } else {
                                    let _e657 = E3_;
                                    local_12 = _e657.w;
                                }
                                let _e660 = local_12;
                                Y = _e660;
                            }
                            let _e661 = Y;
                            let _e662 = p;
                            let _e666 = th;
                            if (abs((_e661 - _e662.y)) < _e666) {
                                {
                                    shatterBorder = true;
                                    break;
                                }
                            }
                            let _e669 = p;
                            let _e671 = Y;
                            if (_e669.y < _e671) {
                                {
                                    let _e674 = Y;
                                    rect_4.w = _e674;
                                    let _e676 = splits_2.y;
                                    splits_2.y = (_e676 + 1f);
                                    let _e679 = sPos;
                                    let _e680 = inverter;
                                    let _e681 = sscale;
                                    sPos = (_e679 + (_e680 * _e681));
                                }
                            } else {
                                {
                                    let _e685 = Y;
                                    rect_4.y = _e685;
                                    let _e687 = splits_2;
                                    splits_2.y = (_e687.y + 100f);
                                    let _e691 = sPos;
                                    let _e693 = inverter;
                                    let _e695 = sscale;
                                    sPos = (_e691 + ((1f - _e693) * _e695));
                                }
                            }
                        }
                    } else {
                        {
                            let _e698 = rect_4;
                            let _e700 = rect_4;
                            let _e702 = var2_;
                            let _e703 = rnd_1;
                            let _e705 = b_2;
                            let _e707 = withBias(_e703.x, _e705.x);
                            X = mix(_e698.x, _e700.z, ((_e702 * _e707) + 0.5f));
                            let _e713 = rect_4;
                            let _e715 = E1_;
                            let _e718 = rect_4;
                            let _e720 = E1_;
                            let _e724 = X;
                            let _e725 = E1_;
                            let _e729 = X;
                            let _e730 = E1_;
                            if ((((_e713.y < _e715.w) && (_e718.w > _e720.y)) && (_e724 > _e725.x)) && (_e729 < _e730.z)) {
                                let _e734 = X;
                                let _e735 = E1_;
                                let _e738 = E1_;
                                let _e740 = X;
                                if ((_e734 - _e735.x) < (_e738.z - _e740)) {
                                    let _e743 = E1_;
                                    local_13 = _e743.x;
                                } else {
                                    let _e745 = E1_;
                                    local_13 = _e745.z;
                                }
                                let _e748 = local_13;
                                X = _e748;
                            }
                            let _e749 = rect_4;
                            let _e751 = E2_;
                            let _e754 = rect_4;
                            let _e756 = E2_;
                            let _e760 = X;
                            let _e761 = E2_;
                            let _e765 = X;
                            let _e766 = E2_;
                            if ((((_e749.y < _e751.w) && (_e754.w > _e756.y)) && (_e760 > _e761.x)) && (_e765 < _e766.z)) {
                                let _e770 = X;
                                let _e771 = E2_;
                                let _e774 = E2_;
                                let _e776 = X;
                                if ((_e770 - _e771.x) < (_e774.z - _e776)) {
                                    let _e779 = E2_;
                                    local_14 = _e779.x;
                                } else {
                                    let _e781 = E2_;
                                    local_14 = _e781.z;
                                }
                                let _e784 = local_14;
                                X = _e784;
                            }
                            let _e785 = rect_4;
                            let _e787 = E3_;
                            let _e790 = rect_4;
                            let _e792 = E3_;
                            let _e796 = X;
                            let _e797 = E3_;
                            let _e801 = X;
                            let _e802 = E3_;
                            if ((((_e785.y < _e787.w) && (_e790.w > _e792.y)) && (_e796 > _e797.x)) && (_e801 < _e802.z)) {
                                let _e806 = X;
                                let _e807 = E3_;
                                let _e810 = E3_;
                                let _e812 = X;
                                if ((_e806 - _e807.x) < (_e810.z - _e812)) {
                                    let _e815 = E3_;
                                    local_15 = _e815.x;
                                } else {
                                    let _e817 = E3_;
                                    local_15 = _e817.z;
                                }
                                let _e820 = local_15;
                                X = _e820;
                            }
                            let _e821 = X;
                            let _e822 = p;
                            let _e826 = th;
                            if (abs((_e821 - _e822.x)) < _e826) {
                                {
                                    shatterBorder = true;
                                    break;
                                }
                            }
                            let _e829 = p;
                            let _e831 = X;
                            if (_e829.x < _e831) {
                                {
                                    let _e834 = X;
                                    rect_4.z = _e834;
                                    let _e836 = splits_2.x;
                                    splits_2.x = (_e836 + 1f);
                                    let _e839 = sPos;
                                    let _e840 = inverter;
                                    let _e841 = sscale;
                                    sPos = (_e839 + (_e840 * _e841));
                                }
                            } else {
                                {
                                    let _e845 = X;
                                    rect_4.x = _e845;
                                    let _e847 = splits_2;
                                    splits_2.x = (_e847.x + 100f);
                                    let _e851 = sPos;
                                    let _e853 = inverter;
                                    let _e855 = sscale;
                                    sPos = (_e851 + ((1f - _e853) * _e855));
                                }
                            }
                        }
                    }
                    let _e858 = horSplit;
                    horSplit = !(_e858);
                    let _e861 = inverter;
                    inverter = (1f - _e861);
                    let _e863 = sscale;
                    sscale = (_e863 * 0.5f);
                    let _e866 = b_2;
                    b_2 = (_e866 * 0.5f);
                }
                continuing {
                    let _e500 = i;
                    i = (_e500 + 1f);
                }
            }
            let _e869 = shatterBorder;
            if _e869 {
                break;
            }
            let _e870 = splits_2;
            cellId = _e870;
            let _e871 = p;
            let _e872 = rect_4;
            let _e873 = splits_2;
            let _e874 = intensity_3;
            let _e875 = randomSeed_1;
            let _e876 = distort9_(_e871, _e872, _e873, _e874, _e875);
            p = _e876;
        }
        continuing {
            let _e468 = j;
            j = (_e468 + 1i);
        }
    }
    let _e878 = rect_4;
    let _e880 = rect_4;
    cc = (0.5f * (_e878.xy + _e880.zw));
    let _e885 = cc;
    let _e888 = windowTransform_1[2];
    d1_ = length((_e885 - _e888.xy));
    let _e893 = cc;
    let _e896 = windowTransform2_1[2];
    d2_ = length((_e893 - _e896.xy));
    let _e901 = cc;
    let _e904 = windowTransform3_1[2];
    d3_ = length((_e901 - _e904.xy));
    let _e910 = d1_;
    w1_ = (1f / (_e910 + 0.001f));
    let _e915 = has2_;
    if _e915 {
        let _e917 = d2_;
        local_16 = (1f / (_e917 + 0.001f));
    } else {
        local_16 = 0f;
    }
    let _e923 = local_16;
    w2_ = _e923;
    let _e925 = has3_;
    if _e925 {
        let _e927 = d3_;
        local_17 = (1f / (_e927 + 0.001f));
    } else {
        local_17 = 0f;
    }
    let _e933 = local_17;
    w3_ = _e933;
    let _e935 = w1_;
    let _e939 = w2_;
    let _e943 = w3_;
    let _e947 = w1_;
    let _e948 = w2_;
    let _e950 = w3_;
    proxPos = ((((_e935 * -1f) + (_e939 * 0f)) + (_e943 * 1f)) / ((_e947 + _e948) + _e950));
    let _e954 = cellId;
    let _e955 = randomSeed_1;
    let _e958 = rand2relSeeded(_e954, (_e955 + 77.7f));
    rnd2_ = (_e958.x * 2f);
    let _e963 = balance_1;
    let _e965 = balance_1;
    let _e969 = rnd2_;
    let _e970 = proxPos;
    let _e971 = proximity_1;
    s_1 = (_e963 + (abs(sin((3.1415927f * _e965))) * mix(_e969, _e970, _e971)));
    let _e976 = s_1;
    if (_e976 < -0.33333f) {
        local_19 = 1i;
    } else {
        let _e981 = s_1;
        if (_e981 > 0.33333f) {
            local_18 = 3i;
        } else {
            local_18 = 2i;
        }
        let _e987 = local_18;
        local_19 = _e987;
    }
    let _e989 = local_19;
    src = _e989;
    let _e991 = src;
    let _e994 = has2_;
    if ((_e991 == 2i) && !(_e994)) {
        src = 1i;
    }
    let _e998 = src;
    let _e1001 = has3_;
    if ((_e998 == 3i) && !(_e1001)) {
        src = 1i;
    }
    let _e1005 = src;
    if (_e1005 == 3i) {
        let _e1008 = pixelation3_1;
        local_21 = _e1008;
    } else {
        let _e1009 = src;
        if (_e1009 == 2i) {
            let _e1012 = pixelation2_1;
            local_20 = _e1012;
        } else {
            let _e1013 = pixelation1_1;
            local_20 = _e1013;
        }
        let _e1015 = local_20;
        local_21 = _e1015;
    }
    let _e1017 = local_21;
    pixSel = _e1017;
    let _e1019 = src;
    if (_e1019 == 3i) {
        let _e1022 = src3Ratio;
        local_23 = _e1022;
    } else {
        let _e1023 = src;
        if (_e1023 == 2i) {
            let _e1026 = src2Ratio;
            local_22 = _e1026;
        } else {
            let _e1027 = srcRatio_4;
            local_22 = _e1027;
        }
        let _e1029 = local_22;
        local_23 = _e1029;
    }
    let _e1031 = local_23;
    srcSelRatio = _e1031;
    let _e1033 = pixSel;
    if (_e1033 < 0f) {
        {
            let _e1036 = outAR;
            let _e1040 = outAR;
            crect = vec4<f32>(-(_e1036), -1f, _e1040, 1f);
            {
                let _e1057 = bias;
                b_3 = _e1057;
                loop {
                    let _e1061 = i_1;
                    let _e1062 = sPos_1;
                    let _e1064 = scale;
                    if !(((_e1061 + _e1062) < _e1064)) {
                        break;
                    }
                    {
                        let _e1070 = splits_3;
                        let _e1071 = randomSeed_1;
                        let _e1074 = rand2relSeeded(_e1070, (_e1071 + 122.1f));
                        rnd_2 = _e1074;
                        let _e1076 = crect;
                        let _e1078 = crect;
                        size_1 = (_e1076.zw - _e1078.xy);
                        let _e1082 = size_1;
                        let _e1084 = pixel;
                        let _e1086 = size_1;
                        let _e1088 = pixel;
                        if ((_e1082.x < _e1084) || (_e1086.y < _e1088)) {
                            break;
                        }
                        let _e1091 = rnd_2;
                        let _e1095 = regularity;
                        if ((_e1091.x + 0.5f) < (_e1095 * 2f)) {
                            let _e1099 = size_1;
                            let _e1101 = size_1;
                            horSplit_1 = (_e1099.y > _e1101.x);
                        }
                        let _e1104 = horSplit_1;
                        if _e1104 {
                            {
                                let _e1105 = crect;
                                let _e1107 = crect;
                                let _e1109 = var2_;
                                let _e1110 = rnd_2;
                                let _e1112 = b_3;
                                let _e1114 = withBias(_e1110.y, _e1112.y);
                                Y_1 = mix(_e1105.y, _e1107.w, ((_e1109 * _e1114) + 0.5f));
                                let _e1120 = crect;
                                let _e1122 = E1_;
                                let _e1125 = crect;
                                let _e1127 = E1_;
                                let _e1131 = Y_1;
                                let _e1132 = E1_;
                                let _e1136 = Y_1;
                                let _e1137 = E1_;
                                if ((((_e1120.x < _e1122.z) && (_e1125.z > _e1127.x)) && (_e1131 > _e1132.y)) && (_e1136 < _e1137.w)) {
                                    let _e1141 = Y_1;
                                    let _e1142 = E1_;
                                    let _e1145 = E1_;
                                    let _e1147 = Y_1;
                                    if ((_e1141 - _e1142.y) < (_e1145.w - _e1147)) {
                                        let _e1150 = E1_;
                                        local_24 = _e1150.y;
                                    } else {
                                        let _e1152 = E1_;
                                        local_24 = _e1152.w;
                                    }
                                    let _e1155 = local_24;
                                    Y_1 = _e1155;
                                }
                                let _e1156 = crect;
                                let _e1158 = E2_;
                                let _e1161 = crect;
                                let _e1163 = E2_;
                                let _e1167 = Y_1;
                                let _e1168 = E2_;
                                let _e1172 = Y_1;
                                let _e1173 = E2_;
                                if ((((_e1156.x < _e1158.z) && (_e1161.z > _e1163.x)) && (_e1167 > _e1168.y)) && (_e1172 < _e1173.w)) {
                                    let _e1177 = Y_1;
                                    let _e1178 = E2_;
                                    let _e1181 = E2_;
                                    let _e1183 = Y_1;
                                    if ((_e1177 - _e1178.y) < (_e1181.w - _e1183)) {
                                        let _e1186 = E2_;
                                        local_25 = _e1186.y;
                                    } else {
                                        let _e1188 = E2_;
                                        local_25 = _e1188.w;
                                    }
                                    let _e1191 = local_25;
                                    Y_1 = _e1191;
                                }
                                let _e1192 = crect;
                                let _e1194 = E3_;
                                let _e1197 = crect;
                                let _e1199 = E3_;
                                let _e1203 = Y_1;
                                let _e1204 = E3_;
                                let _e1208 = Y_1;
                                let _e1209 = E3_;
                                if ((((_e1192.x < _e1194.z) && (_e1197.z > _e1199.x)) && (_e1203 > _e1204.y)) && (_e1208 < _e1209.w)) {
                                    let _e1213 = Y_1;
                                    let _e1214 = E3_;
                                    let _e1217 = E3_;
                                    let _e1219 = Y_1;
                                    if ((_e1213 - _e1214.y) < (_e1217.w - _e1219)) {
                                        let _e1222 = E3_;
                                        local_26 = _e1222.y;
                                    } else {
                                        let _e1224 = E3_;
                                        local_26 = _e1224.w;
                                    }
                                    let _e1227 = local_26;
                                    Y_1 = _e1227;
                                }
                                let _e1228 = Y_1;
                                let _e1229 = uv_3;
                                let _e1233 = th;
                                if (abs((_e1228 - _e1229.y)) < _e1233) {
                                    {
                                        cborder = true;
                                        break;
                                    }
                                }
                                let _e1236 = uv_3;
                                let _e1238 = Y_1;
                                if (_e1236.y < _e1238) {
                                    {
                                        let _e1241 = Y_1;
                                        crect.w = _e1241;
                                        let _e1243 = splits_3.y;
                                        splits_3.y = (_e1243 + 1f);
                                        let _e1246 = sPos_1;
                                        let _e1247 = inverter_1;
                                        let _e1248 = sscale_1;
                                        sPos_1 = (_e1246 + (_e1247 * _e1248));
                                    }
                                } else {
                                    {
                                        let _e1252 = Y_1;
                                        crect.y = _e1252;
                                        let _e1254 = splits_3;
                                        splits_3.y = (_e1254.y + 100f);
                                        let _e1258 = sPos_1;
                                        let _e1260 = inverter_1;
                                        let _e1262 = sscale_1;
                                        sPos_1 = (_e1258 + ((1f - _e1260) * _e1262));
                                    }
                                }
                            }
                        } else {
                            {
                                let _e1265 = crect;
                                let _e1267 = crect;
                                let _e1269 = var2_;
                                let _e1270 = rnd_2;
                                let _e1272 = b_3;
                                let _e1274 = withBias(_e1270.x, _e1272.x);
                                X_1 = mix(_e1265.x, _e1267.z, ((_e1269 * _e1274) + 0.5f));
                                let _e1280 = crect;
                                let _e1282 = E1_;
                                let _e1285 = crect;
                                let _e1287 = E1_;
                                let _e1291 = X_1;
                                let _e1292 = E1_;
                                let _e1296 = X_1;
                                let _e1297 = E1_;
                                if ((((_e1280.y < _e1282.w) && (_e1285.w > _e1287.y)) && (_e1291 > _e1292.x)) && (_e1296 < _e1297.z)) {
                                    let _e1301 = X_1;
                                    let _e1302 = E1_;
                                    let _e1305 = E1_;
                                    let _e1307 = X_1;
                                    if ((_e1301 - _e1302.x) < (_e1305.z - _e1307)) {
                                        let _e1310 = E1_;
                                        local_27 = _e1310.x;
                                    } else {
                                        let _e1312 = E1_;
                                        local_27 = _e1312.z;
                                    }
                                    let _e1315 = local_27;
                                    X_1 = _e1315;
                                }
                                let _e1316 = crect;
                                let _e1318 = E2_;
                                let _e1321 = crect;
                                let _e1323 = E2_;
                                let _e1327 = X_1;
                                let _e1328 = E2_;
                                let _e1332 = X_1;
                                let _e1333 = E2_;
                                if ((((_e1316.y < _e1318.w) && (_e1321.w > _e1323.y)) && (_e1327 > _e1328.x)) && (_e1332 < _e1333.z)) {
                                    let _e1337 = X_1;
                                    let _e1338 = E2_;
                                    let _e1341 = E2_;
                                    let _e1343 = X_1;
                                    if ((_e1337 - _e1338.x) < (_e1341.z - _e1343)) {
                                        let _e1346 = E2_;
                                        local_28 = _e1346.x;
                                    } else {
                                        let _e1348 = E2_;
                                        local_28 = _e1348.z;
                                    }
                                    let _e1351 = local_28;
                                    X_1 = _e1351;
                                }
                                let _e1352 = crect;
                                let _e1354 = E3_;
                                let _e1357 = crect;
                                let _e1359 = E3_;
                                let _e1363 = X_1;
                                let _e1364 = E3_;
                                let _e1368 = X_1;
                                let _e1369 = E3_;
                                if ((((_e1352.y < _e1354.w) && (_e1357.w > _e1359.y)) && (_e1363 > _e1364.x)) && (_e1368 < _e1369.z)) {
                                    let _e1373 = X_1;
                                    let _e1374 = E3_;
                                    let _e1377 = E3_;
                                    let _e1379 = X_1;
                                    if ((_e1373 - _e1374.x) < (_e1377.z - _e1379)) {
                                        let _e1382 = E3_;
                                        local_29 = _e1382.x;
                                    } else {
                                        let _e1384 = E3_;
                                        local_29 = _e1384.z;
                                    }
                                    let _e1387 = local_29;
                                    X_1 = _e1387;
                                }
                                let _e1388 = X_1;
                                let _e1389 = uv_3;
                                let _e1393 = th;
                                if (abs((_e1388 - _e1389.x)) < _e1393) {
                                    {
                                        cborder = true;
                                        break;
                                    }
                                }
                                let _e1396 = uv_3;
                                let _e1398 = X_1;
                                if (_e1396.x < _e1398) {
                                    {
                                        let _e1401 = X_1;
                                        crect.z = _e1401;
                                        let _e1403 = splits_3.x;
                                        splits_3.x = (_e1403 + 1f);
                                        let _e1406 = sPos_1;
                                        let _e1407 = inverter_1;
                                        let _e1408 = sscale_1;
                                        sPos_1 = (_e1406 + (_e1407 * _e1408));
                                    }
                                } else {
                                    {
                                        let _e1412 = X_1;
                                        crect.x = _e1412;
                                        let _e1414 = splits_3;
                                        splits_3.x = (_e1414.x + 100f);
                                        let _e1418 = sPos_1;
                                        let _e1420 = inverter_1;
                                        let _e1422 = sscale_1;
                                        sPos_1 = (_e1418 + ((1f - _e1420) * _e1422));
                                    }
                                }
                            }
                        }
                        let _e1425 = horSplit_1;
                        horSplit_1 = !(_e1425);
                        let _e1428 = inverter_1;
                        inverter_1 = (1f - _e1428);
                        let _e1430 = sscale_1;
                        sscale_1 = (_e1430 * 0.5f);
                        let _e1433 = b_3;
                        b_3 = (_e1433 * 0.5f);
                    }
                    continuing {
                        let _e1067 = i_1;
                        i_1 = (_e1067 + 1f);
                    }
                }
            }
            let _e1436 = cborder;
            if _e1436 {
                {
                    let _e1437 = uv_3;
                    let _e1441 = global.U[0];
                    let _e1444 = uv_3;
                    let _e1453 = textureSample(t_source, samp, ((vec2<f32>((_e1437.x / _e1441.x), _e1444.y) / vec2(2f)) + vec2(0.5f)));
                    col_1 = _e1453;
                    let _e1455 = col_1;
                    let _e1457 = color_1;
                    let _e1459 = color_1;
                    let _e1462 = mix(_e1455.xyz, _e1457.xyz, vec3(_e1459.w));
                    let _e1463 = col_1;
                    return vec4<f32>(_e1462.x, _e1462.y, _e1462.z, _e1463.w);
                }
            }
            let _e1469 = uv_3;
            let _e1470 = crect;
            let _e1471 = srcSelRatio;
            let _e1472 = pixSel;
            let _e1473 = fitCoord(_e1469, _e1470, _e1471, _e1472);
            fc = _e1473;
            let _e1475 = src;
            if (_e1475 == 3i) {
                let _e1478 = fc;
                let _e1482 = global.U[0];
                let _e1485 = fc;
                let _e1494 = textureSample(t_source3_, samp, ((vec2<f32>((_e1478.x / _e1482.x), _e1485.y) / vec2(2f)) + vec2(0.5f)));
                return _e1494;
            }
            let _e1495 = src;
            if (_e1495 == 2i) {
                let _e1498 = fc;
                let _e1502 = global.U[0];
                let _e1505 = fc;
                let _e1514 = textureSample(t_source2_, samp, ((vec2<f32>((_e1498.x / _e1502.x), _e1505.y) / vec2(2f)) + vec2(0.5f)));
                return _e1514;
            }
            let _e1515 = fc;
            let _e1519 = global.U[0];
            let _e1522 = fc;
            let _e1531 = textureSample(t_source, samp, ((vec2<f32>((_e1515.x / _e1519.x), _e1522.y) / vec2(2f)) + vec2(0.5f)));
            return _e1531;
        }
    }
    let _e1532 = shatterBorder;
    if _e1532 {
        {
            let _e1533 = uv_3;
            let _e1537 = global.U[0];
            let _e1540 = uv_3;
            let _e1549 = textureSample(t_source, samp, ((vec2<f32>((_e1533.x / _e1537.x), _e1540.y) / vec2(2f)) + vec2(0.5f)));
            col_2 = _e1549;
            let _e1551 = col_2;
            let _e1553 = color_1;
            let _e1555 = color_1;
            let _e1558 = mix(_e1551.xyz, _e1553.xyz, vec3(_e1555.w));
            let _e1559 = col_2;
            return vec4<f32>(_e1558.x, _e1558.y, _e1558.z, _e1559.w);
        }
    }
    let _e1565 = p;
    sp = _e1565;
    let _e1567 = pixSel;
    if (_e1567 > 0.0001f) {
        let _e1570 = p;
        let _e1571 = pixSel;
        let _e1578 = pixSel;
        sp = (floor(((_e1570 / vec2(_e1571)) + vec2(0.5f))) * _e1578);
    }
    let _e1580 = src;
    if (_e1580 == 3i) {
        let _e1583 = sp;
        let _e1587 = global.U[0];
        let _e1590 = sp;
        let _e1599 = textureSample(t_source3_, samp, ((vec2<f32>((_e1583.x / _e1587.x), _e1590.y) / vec2(2f)) + vec2(0.5f)));
        return _e1599;
    }
    let _e1600 = src;
    if (_e1600 == 2i) {
        let _e1603 = sp;
        let _e1607 = global.U[0];
        let _e1610 = sp;
        let _e1619 = textureSample(t_source2_, samp, ((vec2<f32>((_e1603.x / _e1607.x), _e1610.y) / vec2(2f)) + vec2(0.5f)));
        return _e1619;
    }
    let _e1620 = sp;
    let _e1624 = global.U[0];
    let _e1627 = sp;
    let _e1636 = textureSample(t_source, samp, ((vec2<f32>((_e1620.x / _e1624.x), _e1627.y) / vec2(2f)) + vec2(0.5f)));
    return _e1636;
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[4];
    let _e72 = global.U[5];
    let _e76 = global.U[6];
    let _e80 = global.U[7];
    let _e84 = global.U[8];
    let _e89 = global.U[9];
    let _e94 = global.U[11];
    let _e98 = global.U[12];
    let _e102 = global.U[13];
    let _e106 = global.U[14];
    let _e111 = global.U[15];
    let _e115 = global.U[16];
    let _e119 = global.U[17];
    let _e123 = global.U[18];
    let _e127 = global.U[19];
    let _e131 = global.U[20];
    let _e134 = global.U[21];
    let _e138 = global.U[10];
    let _e142 = global.U[22];
    let _e143 = _e142.xyz;
    let _e146 = global.U[23];
    let _e147 = _e146.xyz;
    let _e150 = global.U[24];
    let _e151 = _e150.xyz;
    let _e167 = global.U[25];
    let _e168 = _e167.xyz;
    let _e171 = global.U[26];
    let _e172 = _e171.xyz;
    let _e175 = global.U[27];
    let _e176 = _e175.xyz;
    let _e192 = global.U[28];
    let _e193 = _e192.xyz;
    let _e196 = global.U[29];
    let _e197 = _e196.xyz;
    let _e200 = global.U[30];
    let _e201 = _e200.xyz;
    let _e217 = global.U[31];
    let _e218 = _e217.xyz;
    let _e221 = global.U[32];
    let _e222 = _e221.xyz;
    let _e225 = global.U[33];
    let _e226 = _e225.xyz;
    let _e240 = dichotomicSampling((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), _e68.xy, _e72.xy, _e76.xy, _e80.xy, i32(_e84.x), i32(_e89.x), _e94.x, _e98.x, _e102.x, i32(_e106.x), _e111.x, _e115.x, _e119.x, _e123.x, _e127.x, _e131, _e134.x, _e138.x, mat3x3<f32>(vec3<f32>(_e143.x, _e143.y, _e143.z), vec3<f32>(_e147.x, _e147.y, _e147.z), vec3<f32>(_e151.x, _e151.y, _e151.z)), mat3x3<f32>(vec3<f32>(_e168.x, _e168.y, _e168.z), vec3<f32>(_e172.x, _e172.y, _e172.z), vec3<f32>(_e176.x, _e176.y, _e176.z)), mat3x3<f32>(vec3<f32>(_e193.x, _e193.y, _e193.z), vec3<f32>(_e197.x, _e197.y, _e197.z), vec3<f32>(_e201.x, _e201.y, _e201.z)), mat3x3<f32>(vec3<f32>(_e218.x, _e218.y, _e218.z), vec3<f32>(_e222.x, _e222.y, _e222.z), vec3<f32>(_e226.x, _e226.y, _e226.z)));
    fragColor = _e240;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
