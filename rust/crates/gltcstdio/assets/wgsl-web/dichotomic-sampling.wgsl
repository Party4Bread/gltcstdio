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
        let _e206 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e189.x / _e193.x), _e196.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e206;
    }
    let _e207 = sxg1_;
    let _e209 = th;
    let _e211 = syg1_;
    let _e212 = th;
    let _e216 = syg1_;
    let _e218 = th;
    let _e220 = sxg1_;
    let _e221 = th;
    frame = (((abs(_e207) < _e209) && (_e211 > -(_e212))) || ((abs(_e216) < _e218) && (_e220 > -(_e221))));
    let _e227 = has2_;
    if _e227 {
        {
            let _e230 = windowTransform2_1[1];
            ws2_ = length(_e230.xy);
            let _e234 = windowTransform2_1;
            let _e236 = uv_3;
            wl2_ = (_naga_inverse_3x3_f32(_e234) * vec3<f32>(_e236.x, _e236.y, 1f)).xy;
            let _e244 = src2Ratio;
            let _e245 = wl2_;
            let _e249 = ws2_;
            sxg2_ = ((_e244 - abs(_e245.x)) * _e249);
            let _e253 = wl2_;
            let _e257 = ws2_;
            syg2_ = ((1f - abs(_e253.y)) * _e257);
            let _e260 = sxg2_;
            let _e263 = syg2_;
            if ((_e260 > 0f) && (_e263 > 0f)) {
                let _e267 = wl2_;
                let _e271 = global.U[0];
                let _e274 = wl2_;
                let _e284 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e267.x / _e271.x), _e274.y) / vec2(2f)) + vec2(0.5f)), 0f);
                return _e284;
            }
            let _e285 = frame;
            let _e286 = sxg2_;
            let _e288 = th;
            let _e290 = syg2_;
            let _e291 = th;
            let _e296 = syg2_;
            let _e298 = th;
            let _e300 = sxg2_;
            let _e301 = th;
            frame = ((_e285 || ((abs(_e286) < _e288) && (_e290 > -(_e291)))) || ((abs(_e296) < _e298) && (_e300 > -(_e301))));
        }
    }
    let _e306 = has3_;
    if _e306 {
        {
            let _e309 = windowTransform3_1[1];
            ws3_ = length(_e309.xy);
            let _e313 = windowTransform3_1;
            let _e315 = uv_3;
            wl3_ = (_naga_inverse_3x3_f32(_e313) * vec3<f32>(_e315.x, _e315.y, 1f)).xy;
            let _e323 = src3Ratio;
            let _e324 = wl3_;
            let _e328 = ws3_;
            sxg3_ = ((_e323 - abs(_e324.x)) * _e328);
            let _e332 = wl3_;
            let _e336 = ws3_;
            syg3_ = ((1f - abs(_e332.y)) * _e336);
            let _e339 = sxg3_;
            let _e342 = syg3_;
            if ((_e339 > 0f) && (_e342 > 0f)) {
                let _e346 = wl3_;
                let _e350 = global.U[0];
                let _e353 = wl3_;
                let _e363 = textureSampleLevel(t_source3_, samp, ((vec2<f32>((_e346.x / _e350.x), _e353.y) / vec2(2f)) + vec2(0.5f)), 0f);
                return _e363;
            }
            let _e364 = frame;
            let _e365 = sxg3_;
            let _e367 = th;
            let _e369 = syg3_;
            let _e370 = th;
            let _e375 = syg3_;
            let _e377 = th;
            let _e379 = sxg3_;
            let _e380 = th;
            frame = ((_e364 || ((abs(_e365) < _e367) && (_e369 > -(_e370)))) || ((abs(_e375) < _e377) && (_e379 > -(_e380))));
        }
    }
    let _e385 = frame;
    if _e385 {
        {
            let _e386 = uv_3;
            let _e390 = global.U[0];
            let _e393 = uv_3;
            let _e403 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e386.x / _e390.x), _e393.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col = _e403;
            let _e405 = col;
            let _e407 = color_1;
            let _e409 = color_1;
            let _e412 = mix(_e405.xyz, _e407.xyz, vec3(_e409.w));
            let _e413 = col;
            return vec4<f32>(_e412.x, _e412.y, _e412.z, _e413.w);
        }
    }
    let _e419 = windowTransform_1;
    let _e420 = srcRatio_4;
    let _e421 = inscribedRect(_e419, _e420);
    E1_ = _e421;
    let _e423 = has2_;
    if _e423 {
        let _e424 = windowTransform2_1;
        let _e425 = src2Ratio;
        let _e426 = inscribedRect(_e424, _e425);
        local_8 = _e426;
    } else {
        local_8 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e435 = local_8;
    E2_ = _e435;
    let _e437 = has3_;
    if _e437 {
        let _e438 = windowTransform3_1;
        let _e439 = src3Ratio;
        let _e440 = inscribedRect(_e438, _e439);
        local_9 = _e440;
    } else {
        local_9 = vec4<f32>(1000000000000000000000000000000f, 1000000000000000000000000000000f, -1000000000000000000000000000000f, -1000000000000000000000000000000f);
    }
    let _e449 = local_9;
    E3_ = _e449;
    let _e451 = uv_3;
    p = _e451;
    let _e455 = outAR;
    let _e459 = outAR;
    rect_4 = vec4<f32>(-(_e455), -1f, _e459, 1f);
    loop {
        let _e468 = j;
        let _e469 = iterations_1;
        if !((_e468 < _e469)) {
            break;
        }
        {
            let _e475 = outAR;
            let _e479 = outAR;
            rect_4 = vec4<f32>(-(_e475), -1f, _e479, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            let _e494 = bias;
            b_2 = _e494;
            i = 0f;
            loop {
                let _e498 = i;
                let _e499 = sPos;
                let _e501 = scale;
                if !(((_e498 + _e499) < _e501)) {
                    break;
                }
                {
                    let _e507 = splits_2;
                    let _e508 = randomSeed_1;
                    let _e511 = rand2relSeeded(_e507, (_e508 + 122.1f));
                    rnd_1 = _e511;
                    let _e513 = rect_4;
                    let _e515 = rect_4;
                    size = (_e513.zw - _e515.xy);
                    let _e519 = size;
                    let _e521 = pixel;
                    let _e523 = size;
                    let _e525 = pixel;
                    if ((_e519.x < _e521) || (_e523.y < _e525)) {
                        break;
                    }
                    let _e528 = rnd_1;
                    let _e532 = regularity;
                    if ((_e528.x + 0.5f) < (_e532 * 2f)) {
                        let _e536 = size;
                        let _e538 = size;
                        horSplit = (_e536.y > _e538.x);
                    }
                    let _e541 = horSplit;
                    if _e541 {
                        {
                            let _e542 = rect_4;
                            let _e544 = rect_4;
                            let _e546 = var2_;
                            let _e547 = rnd_1;
                            let _e549 = b_2;
                            let _e551 = withBias(_e547.y, _e549.y);
                            Y = mix(_e542.y, _e544.w, ((_e546 * _e551) + 0.5f));
                            let _e557 = rect_4;
                            let _e559 = E1_;
                            let _e562 = rect_4;
                            let _e564 = E1_;
                            let _e568 = Y;
                            let _e569 = E1_;
                            let _e573 = Y;
                            let _e574 = E1_;
                            if ((((_e557.x < _e559.z) && (_e562.z > _e564.x)) && (_e568 > _e569.y)) && (_e573 < _e574.w)) {
                                let _e578 = Y;
                                let _e579 = E1_;
                                let _e582 = E1_;
                                let _e584 = Y;
                                if ((_e578 - _e579.y) < (_e582.w - _e584)) {
                                    let _e587 = E1_;
                                    local_10 = _e587.y;
                                } else {
                                    let _e589 = E1_;
                                    local_10 = _e589.w;
                                }
                                let _e592 = local_10;
                                Y = _e592;
                            }
                            let _e593 = rect_4;
                            let _e595 = E2_;
                            let _e598 = rect_4;
                            let _e600 = E2_;
                            let _e604 = Y;
                            let _e605 = E2_;
                            let _e609 = Y;
                            let _e610 = E2_;
                            if ((((_e593.x < _e595.z) && (_e598.z > _e600.x)) && (_e604 > _e605.y)) && (_e609 < _e610.w)) {
                                let _e614 = Y;
                                let _e615 = E2_;
                                let _e618 = E2_;
                                let _e620 = Y;
                                if ((_e614 - _e615.y) < (_e618.w - _e620)) {
                                    let _e623 = E2_;
                                    local_11 = _e623.y;
                                } else {
                                    let _e625 = E2_;
                                    local_11 = _e625.w;
                                }
                                let _e628 = local_11;
                                Y = _e628;
                            }
                            let _e629 = rect_4;
                            let _e631 = E3_;
                            let _e634 = rect_4;
                            let _e636 = E3_;
                            let _e640 = Y;
                            let _e641 = E3_;
                            let _e645 = Y;
                            let _e646 = E3_;
                            if ((((_e629.x < _e631.z) && (_e634.z > _e636.x)) && (_e640 > _e641.y)) && (_e645 < _e646.w)) {
                                let _e650 = Y;
                                let _e651 = E3_;
                                let _e654 = E3_;
                                let _e656 = Y;
                                if ((_e650 - _e651.y) < (_e654.w - _e656)) {
                                    let _e659 = E3_;
                                    local_12 = _e659.y;
                                } else {
                                    let _e661 = E3_;
                                    local_12 = _e661.w;
                                }
                                let _e664 = local_12;
                                Y = _e664;
                            }
                            let _e665 = Y;
                            let _e666 = p;
                            let _e670 = th;
                            if (abs((_e665 - _e666.y)) < _e670) {
                                {
                                    shatterBorder = true;
                                    break;
                                }
                            }
                            let _e673 = p;
                            let _e675 = Y;
                            if (_e673.y < _e675) {
                                {
                                    let _e678 = Y;
                                    rect_4.w = _e678;
                                    let _e680 = splits_2.y;
                                    splits_2.y = (_e680 + 1f);
                                    let _e683 = sPos;
                                    let _e684 = inverter;
                                    let _e685 = sscale;
                                    sPos = (_e683 + (_e684 * _e685));
                                }
                            } else {
                                {
                                    let _e689 = Y;
                                    rect_4.y = _e689;
                                    let _e691 = splits_2;
                                    splits_2.y = (_e691.y + 100f);
                                    let _e695 = sPos;
                                    let _e697 = inverter;
                                    let _e699 = sscale;
                                    sPos = (_e695 + ((1f - _e697) * _e699));
                                }
                            }
                        }
                    } else {
                        {
                            let _e702 = rect_4;
                            let _e704 = rect_4;
                            let _e706 = var2_;
                            let _e707 = rnd_1;
                            let _e709 = b_2;
                            let _e711 = withBias(_e707.x, _e709.x);
                            X = mix(_e702.x, _e704.z, ((_e706 * _e711) + 0.5f));
                            let _e717 = rect_4;
                            let _e719 = E1_;
                            let _e722 = rect_4;
                            let _e724 = E1_;
                            let _e728 = X;
                            let _e729 = E1_;
                            let _e733 = X;
                            let _e734 = E1_;
                            if ((((_e717.y < _e719.w) && (_e722.w > _e724.y)) && (_e728 > _e729.x)) && (_e733 < _e734.z)) {
                                let _e738 = X;
                                let _e739 = E1_;
                                let _e742 = E1_;
                                let _e744 = X;
                                if ((_e738 - _e739.x) < (_e742.z - _e744)) {
                                    let _e747 = E1_;
                                    local_13 = _e747.x;
                                } else {
                                    let _e749 = E1_;
                                    local_13 = _e749.z;
                                }
                                let _e752 = local_13;
                                X = _e752;
                            }
                            let _e753 = rect_4;
                            let _e755 = E2_;
                            let _e758 = rect_4;
                            let _e760 = E2_;
                            let _e764 = X;
                            let _e765 = E2_;
                            let _e769 = X;
                            let _e770 = E2_;
                            if ((((_e753.y < _e755.w) && (_e758.w > _e760.y)) && (_e764 > _e765.x)) && (_e769 < _e770.z)) {
                                let _e774 = X;
                                let _e775 = E2_;
                                let _e778 = E2_;
                                let _e780 = X;
                                if ((_e774 - _e775.x) < (_e778.z - _e780)) {
                                    let _e783 = E2_;
                                    local_14 = _e783.x;
                                } else {
                                    let _e785 = E2_;
                                    local_14 = _e785.z;
                                }
                                let _e788 = local_14;
                                X = _e788;
                            }
                            let _e789 = rect_4;
                            let _e791 = E3_;
                            let _e794 = rect_4;
                            let _e796 = E3_;
                            let _e800 = X;
                            let _e801 = E3_;
                            let _e805 = X;
                            let _e806 = E3_;
                            if ((((_e789.y < _e791.w) && (_e794.w > _e796.y)) && (_e800 > _e801.x)) && (_e805 < _e806.z)) {
                                let _e810 = X;
                                let _e811 = E3_;
                                let _e814 = E3_;
                                let _e816 = X;
                                if ((_e810 - _e811.x) < (_e814.z - _e816)) {
                                    let _e819 = E3_;
                                    local_15 = _e819.x;
                                } else {
                                    let _e821 = E3_;
                                    local_15 = _e821.z;
                                }
                                let _e824 = local_15;
                                X = _e824;
                            }
                            let _e825 = X;
                            let _e826 = p;
                            let _e830 = th;
                            if (abs((_e825 - _e826.x)) < _e830) {
                                {
                                    shatterBorder = true;
                                    break;
                                }
                            }
                            let _e833 = p;
                            let _e835 = X;
                            if (_e833.x < _e835) {
                                {
                                    let _e838 = X;
                                    rect_4.z = _e838;
                                    let _e840 = splits_2.x;
                                    splits_2.x = (_e840 + 1f);
                                    let _e843 = sPos;
                                    let _e844 = inverter;
                                    let _e845 = sscale;
                                    sPos = (_e843 + (_e844 * _e845));
                                }
                            } else {
                                {
                                    let _e849 = X;
                                    rect_4.x = _e849;
                                    let _e851 = splits_2;
                                    splits_2.x = (_e851.x + 100f);
                                    let _e855 = sPos;
                                    let _e857 = inverter;
                                    let _e859 = sscale;
                                    sPos = (_e855 + ((1f - _e857) * _e859));
                                }
                            }
                        }
                    }
                    let _e862 = horSplit;
                    horSplit = !(_e862);
                    let _e865 = inverter;
                    inverter = (1f - _e865);
                    let _e867 = sscale;
                    sscale = (_e867 * 0.5f);
                    let _e870 = b_2;
                    b_2 = (_e870 * 0.5f);
                }
                continuing {
                    let _e504 = i;
                    i = (_e504 + 1f);
                }
            }
            let _e873 = shatterBorder;
            if _e873 {
                break;
            }
            let _e874 = splits_2;
            cellId = _e874;
            let _e875 = p;
            let _e876 = rect_4;
            let _e877 = splits_2;
            let _e878 = intensity_3;
            let _e879 = randomSeed_1;
            let _e880 = distort9_(_e875, _e876, _e877, _e878, _e879);
            p = _e880;
        }
        continuing {
            let _e472 = j;
            j = (_e472 + 1i);
        }
    }
    let _e882 = rect_4;
    let _e884 = rect_4;
    cc = (0.5f * (_e882.xy + _e884.zw));
    let _e889 = cc;
    let _e892 = windowTransform_1[2];
    d1_ = length((_e889 - _e892.xy));
    let _e897 = cc;
    let _e900 = windowTransform2_1[2];
    d2_ = length((_e897 - _e900.xy));
    let _e905 = cc;
    let _e908 = windowTransform3_1[2];
    d3_ = length((_e905 - _e908.xy));
    let _e914 = d1_;
    w1_ = (1f / (_e914 + 0.001f));
    let _e919 = has2_;
    if _e919 {
        let _e921 = d2_;
        local_16 = (1f / (_e921 + 0.001f));
    } else {
        local_16 = 0f;
    }
    let _e927 = local_16;
    w2_ = _e927;
    let _e929 = has3_;
    if _e929 {
        let _e931 = d3_;
        local_17 = (1f / (_e931 + 0.001f));
    } else {
        local_17 = 0f;
    }
    let _e937 = local_17;
    w3_ = _e937;
    let _e939 = w1_;
    let _e943 = w2_;
    let _e947 = w3_;
    let _e951 = w1_;
    let _e952 = w2_;
    let _e954 = w3_;
    proxPos = ((((_e939 * -1f) + (_e943 * 0f)) + (_e947 * 1f)) / ((_e951 + _e952) + _e954));
    let _e958 = cellId;
    let _e959 = randomSeed_1;
    let _e962 = rand2relSeeded(_e958, (_e959 + 77.7f));
    rnd2_ = (_e962.x * 2f);
    let _e967 = balance_1;
    let _e969 = balance_1;
    let _e973 = rnd2_;
    let _e974 = proxPos;
    let _e975 = proximity_1;
    s_1 = (_e967 + (abs(sin((3.1415927f * _e969))) * mix(_e973, _e974, _e975)));
    let _e980 = s_1;
    if (_e980 < -0.33333f) {
        local_19 = 1i;
    } else {
        let _e985 = s_1;
        if (_e985 > 0.33333f) {
            local_18 = 3i;
        } else {
            local_18 = 2i;
        }
        let _e991 = local_18;
        local_19 = _e991;
    }
    let _e993 = local_19;
    src = _e993;
    let _e995 = src;
    let _e998 = has2_;
    if ((_e995 == 2i) && !(_e998)) {
        src = 1i;
    }
    let _e1002 = src;
    let _e1005 = has3_;
    if ((_e1002 == 3i) && !(_e1005)) {
        src = 1i;
    }
    let _e1009 = src;
    if (_e1009 == 3i) {
        let _e1012 = pixelation3_1;
        local_21 = _e1012;
    } else {
        let _e1013 = src;
        if (_e1013 == 2i) {
            let _e1016 = pixelation2_1;
            local_20 = _e1016;
        } else {
            let _e1017 = pixelation1_1;
            local_20 = _e1017;
        }
        let _e1019 = local_20;
        local_21 = _e1019;
    }
    let _e1021 = local_21;
    pixSel = _e1021;
    let _e1023 = src;
    if (_e1023 == 3i) {
        let _e1026 = src3Ratio;
        local_23 = _e1026;
    } else {
        let _e1027 = src;
        if (_e1027 == 2i) {
            let _e1030 = src2Ratio;
            local_22 = _e1030;
        } else {
            let _e1031 = srcRatio_4;
            local_22 = _e1031;
        }
        let _e1033 = local_22;
        local_23 = _e1033;
    }
    let _e1035 = local_23;
    srcSelRatio = _e1035;
    let _e1037 = pixSel;
    if (_e1037 < 0f) {
        {
            let _e1040 = outAR;
            let _e1044 = outAR;
            crect = vec4<f32>(-(_e1040), -1f, _e1044, 1f);
            {
                let _e1061 = bias;
                b_3 = _e1061;
                loop {
                    let _e1065 = i_1;
                    let _e1066 = sPos_1;
                    let _e1068 = scale;
                    if !(((_e1065 + _e1066) < _e1068)) {
                        break;
                    }
                    {
                        let _e1074 = splits_3;
                        let _e1075 = randomSeed_1;
                        let _e1078 = rand2relSeeded(_e1074, (_e1075 + 122.1f));
                        rnd_2 = _e1078;
                        let _e1080 = crect;
                        let _e1082 = crect;
                        size_1 = (_e1080.zw - _e1082.xy);
                        let _e1086 = size_1;
                        let _e1088 = pixel;
                        let _e1090 = size_1;
                        let _e1092 = pixel;
                        if ((_e1086.x < _e1088) || (_e1090.y < _e1092)) {
                            break;
                        }
                        let _e1095 = rnd_2;
                        let _e1099 = regularity;
                        if ((_e1095.x + 0.5f) < (_e1099 * 2f)) {
                            let _e1103 = size_1;
                            let _e1105 = size_1;
                            horSplit_1 = (_e1103.y > _e1105.x);
                        }
                        let _e1108 = horSplit_1;
                        if _e1108 {
                            {
                                let _e1109 = crect;
                                let _e1111 = crect;
                                let _e1113 = var2_;
                                let _e1114 = rnd_2;
                                let _e1116 = b_3;
                                let _e1118 = withBias(_e1114.y, _e1116.y);
                                Y_1 = mix(_e1109.y, _e1111.w, ((_e1113 * _e1118) + 0.5f));
                                let _e1124 = crect;
                                let _e1126 = E1_;
                                let _e1129 = crect;
                                let _e1131 = E1_;
                                let _e1135 = Y_1;
                                let _e1136 = E1_;
                                let _e1140 = Y_1;
                                let _e1141 = E1_;
                                if ((((_e1124.x < _e1126.z) && (_e1129.z > _e1131.x)) && (_e1135 > _e1136.y)) && (_e1140 < _e1141.w)) {
                                    let _e1145 = Y_1;
                                    let _e1146 = E1_;
                                    let _e1149 = E1_;
                                    let _e1151 = Y_1;
                                    if ((_e1145 - _e1146.y) < (_e1149.w - _e1151)) {
                                        let _e1154 = E1_;
                                        local_24 = _e1154.y;
                                    } else {
                                        let _e1156 = E1_;
                                        local_24 = _e1156.w;
                                    }
                                    let _e1159 = local_24;
                                    Y_1 = _e1159;
                                }
                                let _e1160 = crect;
                                let _e1162 = E2_;
                                let _e1165 = crect;
                                let _e1167 = E2_;
                                let _e1171 = Y_1;
                                let _e1172 = E2_;
                                let _e1176 = Y_1;
                                let _e1177 = E2_;
                                if ((((_e1160.x < _e1162.z) && (_e1165.z > _e1167.x)) && (_e1171 > _e1172.y)) && (_e1176 < _e1177.w)) {
                                    let _e1181 = Y_1;
                                    let _e1182 = E2_;
                                    let _e1185 = E2_;
                                    let _e1187 = Y_1;
                                    if ((_e1181 - _e1182.y) < (_e1185.w - _e1187)) {
                                        let _e1190 = E2_;
                                        local_25 = _e1190.y;
                                    } else {
                                        let _e1192 = E2_;
                                        local_25 = _e1192.w;
                                    }
                                    let _e1195 = local_25;
                                    Y_1 = _e1195;
                                }
                                let _e1196 = crect;
                                let _e1198 = E3_;
                                let _e1201 = crect;
                                let _e1203 = E3_;
                                let _e1207 = Y_1;
                                let _e1208 = E3_;
                                let _e1212 = Y_1;
                                let _e1213 = E3_;
                                if ((((_e1196.x < _e1198.z) && (_e1201.z > _e1203.x)) && (_e1207 > _e1208.y)) && (_e1212 < _e1213.w)) {
                                    let _e1217 = Y_1;
                                    let _e1218 = E3_;
                                    let _e1221 = E3_;
                                    let _e1223 = Y_1;
                                    if ((_e1217 - _e1218.y) < (_e1221.w - _e1223)) {
                                        let _e1226 = E3_;
                                        local_26 = _e1226.y;
                                    } else {
                                        let _e1228 = E3_;
                                        local_26 = _e1228.w;
                                    }
                                    let _e1231 = local_26;
                                    Y_1 = _e1231;
                                }
                                let _e1232 = Y_1;
                                let _e1233 = uv_3;
                                let _e1237 = th;
                                if (abs((_e1232 - _e1233.y)) < _e1237) {
                                    {
                                        cborder = true;
                                        break;
                                    }
                                }
                                let _e1240 = uv_3;
                                let _e1242 = Y_1;
                                if (_e1240.y < _e1242) {
                                    {
                                        let _e1245 = Y_1;
                                        crect.w = _e1245;
                                        let _e1247 = splits_3.y;
                                        splits_3.y = (_e1247 + 1f);
                                        let _e1250 = sPos_1;
                                        let _e1251 = inverter_1;
                                        let _e1252 = sscale_1;
                                        sPos_1 = (_e1250 + (_e1251 * _e1252));
                                    }
                                } else {
                                    {
                                        let _e1256 = Y_1;
                                        crect.y = _e1256;
                                        let _e1258 = splits_3;
                                        splits_3.y = (_e1258.y + 100f);
                                        let _e1262 = sPos_1;
                                        let _e1264 = inverter_1;
                                        let _e1266 = sscale_1;
                                        sPos_1 = (_e1262 + ((1f - _e1264) * _e1266));
                                    }
                                }
                            }
                        } else {
                            {
                                let _e1269 = crect;
                                let _e1271 = crect;
                                let _e1273 = var2_;
                                let _e1274 = rnd_2;
                                let _e1276 = b_3;
                                let _e1278 = withBias(_e1274.x, _e1276.x);
                                X_1 = mix(_e1269.x, _e1271.z, ((_e1273 * _e1278) + 0.5f));
                                let _e1284 = crect;
                                let _e1286 = E1_;
                                let _e1289 = crect;
                                let _e1291 = E1_;
                                let _e1295 = X_1;
                                let _e1296 = E1_;
                                let _e1300 = X_1;
                                let _e1301 = E1_;
                                if ((((_e1284.y < _e1286.w) && (_e1289.w > _e1291.y)) && (_e1295 > _e1296.x)) && (_e1300 < _e1301.z)) {
                                    let _e1305 = X_1;
                                    let _e1306 = E1_;
                                    let _e1309 = E1_;
                                    let _e1311 = X_1;
                                    if ((_e1305 - _e1306.x) < (_e1309.z - _e1311)) {
                                        let _e1314 = E1_;
                                        local_27 = _e1314.x;
                                    } else {
                                        let _e1316 = E1_;
                                        local_27 = _e1316.z;
                                    }
                                    let _e1319 = local_27;
                                    X_1 = _e1319;
                                }
                                let _e1320 = crect;
                                let _e1322 = E2_;
                                let _e1325 = crect;
                                let _e1327 = E2_;
                                let _e1331 = X_1;
                                let _e1332 = E2_;
                                let _e1336 = X_1;
                                let _e1337 = E2_;
                                if ((((_e1320.y < _e1322.w) && (_e1325.w > _e1327.y)) && (_e1331 > _e1332.x)) && (_e1336 < _e1337.z)) {
                                    let _e1341 = X_1;
                                    let _e1342 = E2_;
                                    let _e1345 = E2_;
                                    let _e1347 = X_1;
                                    if ((_e1341 - _e1342.x) < (_e1345.z - _e1347)) {
                                        let _e1350 = E2_;
                                        local_28 = _e1350.x;
                                    } else {
                                        let _e1352 = E2_;
                                        local_28 = _e1352.z;
                                    }
                                    let _e1355 = local_28;
                                    X_1 = _e1355;
                                }
                                let _e1356 = crect;
                                let _e1358 = E3_;
                                let _e1361 = crect;
                                let _e1363 = E3_;
                                let _e1367 = X_1;
                                let _e1368 = E3_;
                                let _e1372 = X_1;
                                let _e1373 = E3_;
                                if ((((_e1356.y < _e1358.w) && (_e1361.w > _e1363.y)) && (_e1367 > _e1368.x)) && (_e1372 < _e1373.z)) {
                                    let _e1377 = X_1;
                                    let _e1378 = E3_;
                                    let _e1381 = E3_;
                                    let _e1383 = X_1;
                                    if ((_e1377 - _e1378.x) < (_e1381.z - _e1383)) {
                                        let _e1386 = E3_;
                                        local_29 = _e1386.x;
                                    } else {
                                        let _e1388 = E3_;
                                        local_29 = _e1388.z;
                                    }
                                    let _e1391 = local_29;
                                    X_1 = _e1391;
                                }
                                let _e1392 = X_1;
                                let _e1393 = uv_3;
                                let _e1397 = th;
                                if (abs((_e1392 - _e1393.x)) < _e1397) {
                                    {
                                        cborder = true;
                                        break;
                                    }
                                }
                                let _e1400 = uv_3;
                                let _e1402 = X_1;
                                if (_e1400.x < _e1402) {
                                    {
                                        let _e1405 = X_1;
                                        crect.z = _e1405;
                                        let _e1407 = splits_3.x;
                                        splits_3.x = (_e1407 + 1f);
                                        let _e1410 = sPos_1;
                                        let _e1411 = inverter_1;
                                        let _e1412 = sscale_1;
                                        sPos_1 = (_e1410 + (_e1411 * _e1412));
                                    }
                                } else {
                                    {
                                        let _e1416 = X_1;
                                        crect.x = _e1416;
                                        let _e1418 = splits_3;
                                        splits_3.x = (_e1418.x + 100f);
                                        let _e1422 = sPos_1;
                                        let _e1424 = inverter_1;
                                        let _e1426 = sscale_1;
                                        sPos_1 = (_e1422 + ((1f - _e1424) * _e1426));
                                    }
                                }
                            }
                        }
                        let _e1429 = horSplit_1;
                        horSplit_1 = !(_e1429);
                        let _e1432 = inverter_1;
                        inverter_1 = (1f - _e1432);
                        let _e1434 = sscale_1;
                        sscale_1 = (_e1434 * 0.5f);
                        let _e1437 = b_3;
                        b_3 = (_e1437 * 0.5f);
                    }
                    continuing {
                        let _e1071 = i_1;
                        i_1 = (_e1071 + 1f);
                    }
                }
            }
            let _e1440 = cborder;
            if _e1440 {
                {
                    let _e1441 = uv_3;
                    let _e1445 = global.U[0];
                    let _e1448 = uv_3;
                    let _e1458 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1441.x / _e1445.x), _e1448.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    col_1 = _e1458;
                    let _e1460 = col_1;
                    let _e1462 = color_1;
                    let _e1464 = color_1;
                    let _e1467 = mix(_e1460.xyz, _e1462.xyz, vec3(_e1464.w));
                    let _e1468 = col_1;
                    return vec4<f32>(_e1467.x, _e1467.y, _e1467.z, _e1468.w);
                }
            }
            let _e1474 = uv_3;
            let _e1475 = crect;
            let _e1476 = srcSelRatio;
            let _e1477 = pixSel;
            let _e1478 = fitCoord(_e1474, _e1475, _e1476, _e1477);
            fc = _e1478;
            let _e1480 = src;
            if (_e1480 == 3i) {
                let _e1483 = fc;
                let _e1487 = global.U[0];
                let _e1490 = fc;
                let _e1500 = textureSampleLevel(t_source3_, samp, ((vec2<f32>((_e1483.x / _e1487.x), _e1490.y) / vec2(2f)) + vec2(0.5f)), 0f);
                return _e1500;
            }
            let _e1501 = src;
            if (_e1501 == 2i) {
                let _e1504 = fc;
                let _e1508 = global.U[0];
                let _e1511 = fc;
                let _e1521 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e1504.x / _e1508.x), _e1511.y) / vec2(2f)) + vec2(0.5f)), 0f);
                return _e1521;
            }
            let _e1522 = fc;
            let _e1526 = global.U[0];
            let _e1529 = fc;
            let _e1539 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1522.x / _e1526.x), _e1529.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e1539;
        }
    }
    let _e1540 = shatterBorder;
    if _e1540 {
        {
            let _e1541 = uv_3;
            let _e1545 = global.U[0];
            let _e1548 = uv_3;
            let _e1558 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1541.x / _e1545.x), _e1548.y) / vec2(2f)) + vec2(0.5f)), 0f);
            col_2 = _e1558;
            let _e1560 = col_2;
            let _e1562 = color_1;
            let _e1564 = color_1;
            let _e1567 = mix(_e1560.xyz, _e1562.xyz, vec3(_e1564.w));
            let _e1568 = col_2;
            return vec4<f32>(_e1567.x, _e1567.y, _e1567.z, _e1568.w);
        }
    }
    let _e1574 = p;
    sp = _e1574;
    let _e1576 = pixSel;
    if (_e1576 > 0.0001f) {
        let _e1579 = p;
        let _e1580 = pixSel;
        let _e1587 = pixSel;
        sp = (floor(((_e1579 / vec2(_e1580)) + vec2(0.5f))) * _e1587);
    }
    let _e1589 = src;
    if (_e1589 == 3i) {
        let _e1592 = sp;
        let _e1596 = global.U[0];
        let _e1599 = sp;
        let _e1609 = textureSampleLevel(t_source3_, samp, ((vec2<f32>((_e1592.x / _e1596.x), _e1599.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e1609;
    }
    let _e1610 = src;
    if (_e1610 == 2i) {
        let _e1613 = sp;
        let _e1617 = global.U[0];
        let _e1620 = sp;
        let _e1630 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e1613.x / _e1617.x), _e1620.y) / vec2(2f)) + vec2(0.5f)), 0f);
        return _e1630;
    }
    let _e1631 = sp;
    let _e1635 = global.U[0];
    let _e1638 = sp;
    let _e1648 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e1631.x / _e1635.x), _e1638.y) / vec2(2f)) + vec2(0.5f)), 0f);
    return _e1648;
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
