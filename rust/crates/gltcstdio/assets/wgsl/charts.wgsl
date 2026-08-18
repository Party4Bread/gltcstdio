struct Params {
    U: array<vec4<f32>, 27>,
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

fn chBox(p: vec2<f32>, lo: vec2<f32>, hi: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var lo_1: vec2<f32>;
    var hi_1: vec2<f32>;
    var ctr: vec2<f32>;
    var hlf: vec2<f32>;
    var q: vec2<f32>;

    p_1 = p;
    lo_1 = lo;
    hi_1 = hi;
    let _e12 = lo_1;
    let _e13 = hi_1;
    ctr = ((_e12 + _e13) * 0.5f);
    let _e18 = hi_1;
    let _e19 = lo_1;
    hlf = ((_e18 - _e19) * 0.5f);
    let _e24 = p_1;
    let _e25 = ctr;
    let _e28 = hlf;
    q = (abs((_e24 - _e25)) - _e28);
    let _e31 = q;
    let _e36 = q;
    let _e38 = q;
    return (length(max(_e31, vec2(0f))) + min(max(_e36.x, _e38.y), 0f));
}

fn chHatch(p_2: vec2<f32>, aa: f32) -> f32 {
    var p_3: vec2<f32>;
    var aa_1: f32;
    var period: f32 = 0.07f;
    var t: f32;
    var d: f32;
    var w: f32;

    p_3 = p_2;
    aa_1 = aa;
    let _e12 = p_3;
    let _e14 = p_3;
    let _e17 = period;
    t = fract(((_e12.x + _e14.y) / _e17));
    let _e22 = t;
    d = (0.25f - abs((_e22 - 0.5f)));
    let _e28 = aa_1;
    let _e29 = period;
    w = (_e28 / _e29);
    let _e32 = w;
    let _e34 = w;
    let _e35 = d;
    return smoothstep(-(_e32), _e34, _e35);
}

fn chHatchRadial(p_4: vec2<f32>, aa_2: f32) -> f32 {
    var p_5: vec2<f32>;
    var aa_3: f32;
    var spokes: f32 = 22f;
    var rho: f32;
    var t_1: f32;
    var d_1: f32;
    var w_1: f32;

    p_5 = p_4;
    aa_3 = aa_2;
    let _e12 = p_5;
    rho = max(length(_e12), 0.001f);
    let _e17 = p_5;
    let _e19 = p_5;
    let _e24 = spokes;
    t_1 = fract(((atan2(_e17.y, _e19.x) / 6.2831855f) * _e24));
    let _e29 = t_1;
    d_1 = (0.25f - abs((_e29 - 0.5f)));
    let _e35 = aa_3;
    let _e36 = spokes;
    let _e39 = rho;
    w_1 = ((_e35 * _e36) / (6.2831855f * _e39));
    let _e43 = w_1;
    let _e45 = w_1;
    let _e46 = d_1;
    return smoothstep(-(_e43), _e45, _e46);
}

fn hash22_(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e21 = u_1;
    let _e25 = u_1;
    return vec2<f32>(fract((sin(((_e8.x * 776.45f) + (_e12.y * 453.24f))) * 45.77f)), fract((sin(((_e21.x * 376.45f) + (_e25.y * 853.24f))) * 88.77f)));
}

fn sdSegment(u_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_1 = a;
    b_1 = b;
    let _e12 = u_3;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
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

fn charts(uv: vec2<f32>, outPos: vec2<f32>, style: i32, fill: i32, randomness: f32, randomSeed: f32, levels: i32, threshold: f32, precizion: i32, thickness: f32, border: f32, maskAR: f32, colorOutline: vec4<f32>, colorBkg: vec4<f32>, colorR: vec4<f32>, colorG: vec4<f32>, colorB: vec4<f32>, modelTransform: mat3x3<f32>, maskTransform: mat3x3<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var style_1: i32;
    var fill_1: i32;
    var randomness_1: f32;
    var randomSeed_1: f32;
    var levels_1: i32;
    var threshold_1: f32;
    var precizion_1: i32;
    var thickness_1: f32;
    var border_1: f32;
    var maskAR_1: f32;
    var colorOutline_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var colorR_1: vec4<f32>;
    var colorG_1: vec4<f32>;
    var colorB_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var maskTransform_1: mat3x3<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var im: mat3x3<f32>;
    var vg: vec2<f32>;
    var N: i32;
    var n: f32;
    var st: f32;
    var s2_: f32;
    var thr: f32;
    var R: f32 = 1f;
    var k: i32 = 0i;
    var cid: vec2<f32>;
    var ccol: vec3<f32>;
    var var_: f32;
    var j: f32;
    var i: f32;
    var uu: vec2<f32>;
    var col: vec3<f32>;
    var vv: vec2<f32>;
    var id: vec2<f32>;
    var imask: mat3x3<f32>;
    var H: f32;
    var mh: vec2<f32>;
    var ml: vec2<f32>;
    var mScale: f32;
    var kScale: f32;
    var hc: f32;
    var cell: vec2<f32>;
    var csum: vec3<f32> = vec3(0f);
    var j_1: f32 = 0f;
    var i_1: f32;
    var uu_1: vec2<f32>;
    var c: vec3<f32>;
    var vals: array<f32, 3>;
    var chan: array<vec4<f32>, 3>;
    var pixel: f32;
    var aa_4: f32;
    var strokeLw: f32;
    var frameLw: f32;
    var styleCell: i32;
    var hh: vec2<f32>;
    var bkg: vec4<f32>;
    var acc: vec3<f32>;
    var dStroke: f32 = 1000000000f;
    var dFrame: f32;
    var local: f32;
    var hatch: f32;
    var r: f32 = 0.34f;
    var dDisc: f32;
    var rawSum: f32;
    var f0_: f32;
    var f1_: f32;
    var discCov: f32;
    var ang: f32;
    var wcol: vec3<f32>;
    var wa: f32;
    var base: f32 = -0.36f;
    var maxH: f32 = 0.72f;
    var b_2: i32 = 0i;
    var bx: f32;
    var h_1: f32;
    var d_2: f32;
    var startAng: f32 = 1.5707963f;
    var local_1: f32;
    var hatchR: f32;
    var b_3: i32 = 0i;
    var ri: f32;
    var dTrack: f32;
    var local_2: f32;
    var covTrack: f32;
    var hw: f32;
    var dRing: f32;
    var ang_1: f32;
    var angAA: f32;
    var angMask: f32;
    var cy: array<f32, 3>;
    var cx: array<f32, 3>;
    var rr: array<f32, 3>;
    var r_1: i32 = 0i;
    var cnt: i32;
    var cc: i32;
    var dCirc: f32;
    var local_3: f32;
    var covStroke: f32;
    var local_4: f32;
    var covFrame: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    style_1 = style;
    fill_1 = fill;
    randomness_1 = randomness;
    randomSeed_1 = randomSeed;
    levels_1 = levels;
    threshold_1 = threshold;
    precizion_1 = precizion;
    thickness_1 = thickness;
    border_1 = border;
    maskAR_1 = maskAR;
    colorOutline_1 = colorOutline;
    colorBkg_1 = colorBkg;
    colorR_1 = colorR;
    colorG_1 = colorG;
    colorB_1 = colorB;
    modelTransform_1 = modelTransform;
    maskTransform_1 = maskTransform;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    let _e48 = modelTransform_1;
    im = _naga_inverse_3x3_f32(_e48);
    let _e51 = im;
    let _e52 = uv_1;
    let _e53 = tf(_e51, _e52);
    vg = _e53;
    let _e55 = precizion_1;
    N = _e55;
    let _e57 = N;
    n = f32(_e57);
    let _e61 = n;
    st = (1f / _e61);
    let _e64 = st;
    s2_ = (_e64 * 0.5f);
    let _e68 = threshold_1;
    let _e69 = threshold_1;
    thr = (_e68 * _e69);
    loop {
        let _e76 = k;
        let _e77 = levels_1;
        if !((_e76 < (_e77 - 1i))) {
            break;
        }
        {
            let _e85 = vg;
            let _e86 = R;
            cid = floor((_e85 * _e86));
            let _e90 = modelTransform_1;
            let _e91 = cid;
            let _e95 = R;
            let _e98 = tf(_e90, ((_e91 + vec2(0.5f)) / vec2(_e95)));
            let _e102 = global.U[0];
            let _e105 = modelTransform_1;
            let _e106 = cid;
            let _e110 = R;
            let _e113 = tf(_e105, ((_e106 + vec2(0.5f)) / vec2(_e110)));
            let _e122 = textureSample(t_source, samp, ((vec2<f32>((_e98.x / _e102.x), _e113.y) / vec2(2f)) + vec2(0.5f)));
            ccol = _e122.xyz;
            var_ = 0f;
            j = 0f;
            loop {
                let _e129 = j;
                let _e130 = n;
                if !((_e129 < _e130)) {
                    break;
                }
                {
                    i = 0f;
                    loop {
                        let _e138 = i;
                        let _e139 = n;
                        if !((_e138 < _e139)) {
                            break;
                        }
                        {
                            let _e145 = s2_;
                            let _e146 = i;
                            let _e147 = st;
                            let _e150 = s2_;
                            let _e151 = j;
                            let _e152 = st;
                            uu = vec2<f32>((_e145 + (_e146 * _e147)), (_e150 + (_e151 * _e152)));
                            let _e157 = modelTransform_1;
                            let _e158 = cid;
                            let _e159 = uu;
                            let _e161 = R;
                            let _e164 = tf(_e157, ((_e158 + _e159) / vec2(_e161)));
                            let _e168 = global.U[0];
                            let _e171 = modelTransform_1;
                            let _e172 = cid;
                            let _e173 = uu;
                            let _e175 = R;
                            let _e178 = tf(_e171, ((_e172 + _e173) / vec2(_e175)));
                            let _e187 = textureSample(t_source, samp, ((vec2<f32>((_e164.x / _e168.x), _e178.y) / vec2(2f)) + vec2(0.5f)));
                            col = _e187.xyz;
                            let _e190 = var_;
                            let _e191 = ccol;
                            let _e192 = col;
                            let _e194 = ccol;
                            let _e195 = col;
                            var_ = (_e190 + dot((_e191 - _e192), (_e194 - _e195)));
                        }
                        continuing {
                            let _e142 = i;
                            i = (_e142 + 1f);
                        }
                    }
                }
                continuing {
                    let _e133 = j;
                    j = (_e133 + 1f);
                }
            }
            let _e199 = var_;
            let _e200 = n;
            let _e201 = n;
            let _e204 = thr;
            if ((_e199 / (_e200 * _e201)) < _e204) {
                break;
            }
            let _e206 = R;
            R = (_e206 * 2f);
        }
        continuing {
            let _e82 = k;
            k = (_e82 + 1i);
        }
    }
    let _e209 = vg;
    let _e210 = R;
    vv = (_e209 * _e210);
    let _e213 = vv;
    id = floor(_e213);
    {
        let _e216 = maskTransform_1;
        imask = _naga_inverse_3x3_f32(_e216);
        let _e220 = outDim_1;
        let _e222 = outDim_1;
        H = max(1f, (_e220.x / _e222.y));
        let _e227 = H;
        let _e228 = maskAR_1;
        let _e230 = H;
        mh = vec2<f32>((_e227 * _e228), _e230);
        let _e233 = imask;
        let _e234 = modelTransform_1;
        let _e235 = id;
        let _e239 = R;
        let _e242 = tf(_e234, ((_e235 + vec2(0.5f)) / vec2(_e239)));
        let _e243 = tf(_e233, _e242);
        ml = _e243;
        let _e249 = modelTransform_1[0][0];
        let _e254 = modelTransform_1[0][1];
        mScale = length(vec2<f32>(_e249, _e254));
        let _e262 = imask[0][0];
        let _e267 = imask[0][1];
        kScale = length(vec2<f32>(_e262, _e267));
        let _e272 = R;
        let _e274 = mScale;
        let _e276 = kScale;
        hc = (((0.5f / _e272) * _e274) * _e276);
        let _e279 = ml;
        let _e282 = mh;
        let _e284 = hc;
        let _e287 = ml;
        let _e290 = mh;
        let _e292 = hc;
        if ((abs(_e279.x) > (_e282.x + _e284)) || (abs(_e287.y) > (_e290.y + _e292))) {
            let _e296 = uv_1;
            let _e300 = global.U[0];
            let _e303 = uv_1;
            let _e312 = textureSample(t_source, samp, ((vec2<f32>((_e296.x / _e300.x), _e303.y) / vec2(2f)) + vec2(0.5f)));
            return _e312;
        }
    }
    let _e313 = vv;
    let _e314 = id;
    cell = ((_e313 - _e314) - vec2(0.5f));
    let _e321 = cell;
    cell.y = -(_e321.y);
    loop {
        let _e329 = j_1;
        let _e330 = n;
        if !((_e329 < _e330)) {
            break;
        }
        {
            i_1 = 0f;
            loop {
                let _e338 = i_1;
                let _e339 = n;
                if !((_e338 < _e339)) {
                    break;
                }
                {
                    let _e345 = s2_;
                    let _e346 = i_1;
                    let _e347 = st;
                    let _e350 = s2_;
                    let _e351 = j_1;
                    let _e352 = st;
                    uu_1 = vec2<f32>((_e345 + (_e346 * _e347)), (_e350 + (_e351 * _e352)));
                    let _e357 = csum;
                    let _e358 = modelTransform_1;
                    let _e359 = id;
                    let _e360 = uu_1;
                    let _e362 = R;
                    let _e365 = tf(_e358, ((_e359 + _e360) / vec2(_e362)));
                    let _e369 = global.U[0];
                    let _e372 = modelTransform_1;
                    let _e373 = id;
                    let _e374 = uu_1;
                    let _e376 = R;
                    let _e379 = tf(_e372, ((_e373 + _e374) / vec2(_e376)));
                    let _e388 = textureSample(t_source, samp, ((vec2<f32>((_e365.x / _e369.x), _e379.y) / vec2(2f)) + vec2(0.5f)));
                    csum = (_e357 + _e388.xyz);
                }
                continuing {
                    let _e342 = i_1;
                    i_1 = (_e342 + 1f);
                }
            }
        }
        continuing {
            let _e333 = j_1;
            j_1 = (_e333 + 1f);
        }
    }
    let _e391 = csum;
    let _e392 = n;
    let _e393 = n;
    c = (_e391 / vec3((_e392 * _e393)));
    let _e401 = c;
    vals[0i] = clamp(_e401.x, 0f, 1f);
    let _e408 = c;
    vals[1i] = clamp(_e408.y, 0f, 1f);
    let _e415 = c;
    vals[2i] = clamp(_e415.z, 0f, 1f);
    let _e423 = colorR_1;
    chan[0i] = _e423;
    let _e426 = colorG_1;
    chan[1i] = _e426;
    let _e429 = colorB_1;
    chan[2i] = _e429;
    let _e431 = outDim_1;
    pixel = (2f / _e431.y);
    let _e435 = im;
    let _e436 = uv_1;
    let _e437 = pixel;
    let _e441 = tf(_e435, (_e436 + vec2<f32>(_e437, 0f)));
    let _e442 = vg;
    let _e445 = R;
    aa_4 = max((length((_e441 - _e442)) * _e445), 0.0001f);
    let _e450 = thickness_1;
    strokeLw = (_e450 * 0.05f);
    let _e454 = border_1;
    frameLw = (_e454 * 0.06f);
    let _e458 = style_1;
    styleCell = clamp(_e458, 0i, 3i);
    let _e463 = id;
    let _e464 = randomSeed_1;
    let _e465 = randomSeed_1;
    let _e472 = hash22_((_e463 + vec2<f32>(_e464, ((_e465 * 1.7f) + 3.1f))));
    hh = _e472;
    let _e474 = hh;
    let _e476 = randomness_1;
    if (_e474.x < _e476) {
        {
            let _e478 = hh;
            styleCell = min(i32(floor((_e478.y * 4f))), 3i);
        }
    }
    let _e486 = uv_1;
    let _e490 = global.U[0];
    let _e493 = uv_1;
    let _e502 = textureSample(t_source, samp, ((vec2<f32>((_e486.x / _e490.x), _e493.y) / vec2(2f)) + vec2(0.5f)));
    bkg = _e502;
    let _e504 = bkg;
    let _e506 = colorBkg_1;
    let _e508 = colorBkg_1;
    acc = mix(_e504.xyz, _e506.xyz, vec3(_e508.w));
    let _e516 = cell;
    let _e519 = cell;
    dFrame = abs((0.5f - max(abs(_e516.x), abs(_e519.y))));
    let _e526 = fill_1;
    if (_e526 == 1i) {
        let _e529 = cell;
        let _e530 = aa_4;
        let _e531 = chHatch(_e529, _e530);
        local = _e531;
    } else {
        local = 1f;
    }
    let _e534 = local;
    hatch = _e534;
    let _e536 = styleCell;
    if (_e536 == 0i) {
        {
            let _e541 = cell;
            let _e543 = r;
            dDisc = (length(_e541) - _e543);
            let _e546 = dStroke;
            let _e547 = dDisc;
            dStroke = min(_e546, abs(_e547));
            let _e552 = vals[0];
            let _e555 = vals[1];
            let _e559 = vals[2];
            rawSum = ((_e552 + _e555) + _e559);
            let _e562 = rawSum;
            if (_e562 > 0.0001f) {
                {
                    let _e567 = vals[0];
                    let _e568 = rawSum;
                    f0_ = (_e567 / _e568);
                    let _e571 = f0_;
                    let _e574 = vals[1];
                    let _e575 = rawSum;
                    f1_ = (_e571 + (_e574 / _e575));
                    let _e579 = dDisc;
                    let _e580 = aa_4;
                    if (_e579 < _e580) {
                        {
                            let _e583 = aa_4;
                            let _e585 = aa_4;
                            let _e586 = dDisc;
                            discCov = (1f - smoothstep(-(_e583), _e585, _e586));
                            let _e590 = cell;
                            let _e592 = cell;
                            ang = fract(((atan2(_e590.y, _e592.x) / 6.2831855f) + 1f));
                            let _e603 = ang;
                            let _e604 = f0_;
                            if (_e603 < _e604) {
                                {
                                    let _e608 = chan[0];
                                    wcol = _e608.xyz;
                                    let _e612 = chan[0];
                                    wa = _e612.w;
                                }
                            } else {
                                let _e614 = ang;
                                let _e615 = f1_;
                                if (_e614 < _e615) {
                                    {
                                        let _e619 = chan[1];
                                        wcol = _e619.xyz;
                                        let _e623 = chan[1];
                                        wa = _e623.w;
                                    }
                                } else {
                                    {
                                        let _e627 = chan[2];
                                        wcol = _e627.xyz;
                                        let _e631 = chan[2];
                                        wa = _e631.w;
                                    }
                                }
                            }
                            let _e633 = acc;
                            let _e634 = wcol;
                            let _e635 = discCov;
                            let _e636 = wa;
                            let _e638 = hatch;
                            acc = mix(_e633, _e634, vec3(((_e635 * _e636) * _e638)));
                        }
                    }
                    let _e642 = dStroke;
                    let _e643 = cell;
                    let _e646 = r;
                    let _e651 = sdSegment(_e643, vec2(0f), (_e646 * vec2<f32>(1f, 0f)));
                    dStroke = min(_e642, _e651);
                    let _e653 = dStroke;
                    let _e654 = cell;
                    let _e657 = r;
                    let _e658 = f0_;
                    let _e662 = f0_;
                    let _e668 = sdSegment(_e654, vec2(0f), (_e657 * vec2<f32>(cos((_e658 * 6.2831855f)), sin((_e662 * 6.2831855f)))));
                    dStroke = min(_e653, _e668);
                    let _e670 = dStroke;
                    let _e671 = cell;
                    let _e674 = r;
                    let _e675 = f1_;
                    let _e679 = f1_;
                    let _e685 = sdSegment(_e671, vec2(0f), (_e674 * vec2<f32>(cos((_e675 * 6.2831855f)), sin((_e679 * 6.2831855f)))));
                    dStroke = min(_e670, _e685);
                }
            }
        }
    } else {
        let _e687 = styleCell;
        if (_e687 == 1i) {
            {
                loop {
                    let _e697 = b_2;
                    if !((_e697 < 3i)) {
                        break;
                    }
                    {
                        let _e706 = b_2;
                        bx = (-0.24f + (f32(_e706) * 0.24f));
                        let _e712 = b_2;
                        let _e714 = vals[_e712];
                        let _e715 = maxH;
                        h_1 = (_e714 * _e715);
                        let _e718 = cell;
                        let _e719 = bx;
                        let _e722 = base;
                        let _e724 = bx;
                        let _e727 = base;
                        let _e728 = h_1;
                        let _e733 = chBox(_e718, vec2<f32>((_e719 - 0.085f), _e722), vec2<f32>((_e724 + 0.085f), (_e727 + max(_e728, 0.004f))));
                        d_2 = _e733;
                        let _e735 = acc;
                        let _e736 = b_2;
                        let _e738 = chan[_e736];
                        let _e741 = aa_4;
                        let _e743 = aa_4;
                        let _e744 = d_2;
                        let _e747 = b_2;
                        let _e749 = chan[_e747];
                        let _e752 = hatch;
                        acc = mix(_e735, _e738.xyz, vec3((((1f - smoothstep(-(_e741), _e743, _e744)) * _e749.w) * _e752)));
                        let _e756 = dStroke;
                        let _e757 = d_2;
                        dStroke = min(_e756, abs(_e757));
                    }
                    continuing {
                        let _e701 = b_2;
                        b_2 = (_e701 + 1i);
                    }
                }
                let _e760 = dStroke;
                let _e761 = cell;
                let _e764 = base;
                let _e767 = base;
                let _e769 = sdSegment(_e761, vec2<f32>(-0.4f, _e764), vec2<f32>(0.4f, _e767));
                dStroke = min(_e760, _e769);
            }
        } else {
            let _e771 = styleCell;
            if (_e771 == 2i) {
                {
                    let _e776 = fill_1;
                    if (_e776 == 1i) {
                        let _e779 = cell;
                        let _e780 = aa_4;
                        let _e781 = chHatchRadial(_e779, _e780);
                        local_1 = _e781;
                    } else {
                        local_1 = 1f;
                    }
                    let _e784 = local_1;
                    hatchR = _e784;
                    loop {
                        let _e788 = b_3;
                        if !((_e788 < 3i)) {
                            break;
                        }
                        {
                            let _e796 = b_3;
                            ri = (0.14f + (f32(_e796) * 0.1f));
                            let _e802 = cell;
                            let _e804 = ri;
                            dTrack = abs((length(_e802) - _e804));
                            let _e808 = strokeLw;
                            if (_e808 <= 0f) {
                                local_2 = 0f;
                            } else {
                                let _e813 = strokeLw;
                                let _e814 = aa_4;
                                let _e816 = strokeLw;
                                let _e817 = aa_4;
                                let _e819 = dTrack;
                                local_2 = (1f - smoothstep((_e813 - _e814), (_e816 + _e817), _e819));
                            }
                            let _e823 = local_2;
                            covTrack = _e823;
                            let _e825 = acc;
                            let _e826 = colorOutline_1;
                            let _e828 = covTrack;
                            let _e829 = colorOutline_1;
                            acc = mix(_e825, _e826.xyz, vec3((_e828 * _e829.w)));
                            let _e835 = strokeLw;
                            let _e837 = aa_4;
                            hw = max(0.03f, (_e835 + (2f * _e837)));
                            let _e842 = cell;
                            let _e844 = ri;
                            let _e847 = hw;
                            dRing = (abs((length(_e842) - _e844)) - _e847);
                            let _e850 = startAng;
                            let _e851 = cell;
                            let _e853 = cell;
                            ang_1 = fract((((_e850 - atan2(_e851.y, _e853.x)) / 6.2831855f) + 1f));
                            let _e863 = aa_4;
                            let _e865 = ri;
                            angAA = (_e863 / max((6.2831855f * _e865), 0.001f));
                            let _e872 = b_3;
                            let _e874 = vals[_e872];
                            let _e875 = angAA;
                            let _e877 = b_3;
                            let _e879 = vals[_e877];
                            let _e880 = angAA;
                            let _e882 = ang_1;
                            angMask = (1f - smoothstep((_e874 - _e875), (_e879 + _e880), _e882));
                            let _e886 = acc;
                            let _e887 = b_3;
                            let _e889 = chan[_e887];
                            let _e892 = aa_4;
                            let _e894 = aa_4;
                            let _e895 = dRing;
                            let _e898 = angMask;
                            let _e900 = b_3;
                            let _e902 = chan[_e900];
                            let _e905 = hatchR;
                            acc = mix(_e886, _e889.xyz, vec3(((((1f - smoothstep(-(_e892), _e894, _e895)) * _e898) * _e902.w) * _e905)));
                        }
                        continuing {
                            let _e792 = b_3;
                            b_3 = (_e792 + 1i);
                        }
                    }
                }
            } else {
                {
                    cy[0i] = 0.3f;
                    cy[1i] = 0f;
                    cy[2i] = -0.3f;
                    cx[0i] = -0.3f;
                    cx[1i] = 0f;
                    cx[2i] = 0.3f;
                    rr[0i] = 0.05f;
                    rr[1i] = 0.085f;
                    rr[2i] = 0.12f;
                    loop {
                        let _e943 = r_1;
                        if !((_e943 < 3i)) {
                            break;
                        }
                        {
                            let _e950 = r_1;
                            let _e952 = vals[_e950];
                            cnt = clamp(i32(floor(((_e952 * 3f) + 0.5f))), 0i, 3i);
                            cc = 0i;
                            loop {
                                let _e965 = cc;
                                if !((_e965 < 3i)) {
                                    break;
                                }
                                {
                                    let _e972 = cell;
                                    let _e973 = cc;
                                    let _e975 = cx[_e973];
                                    let _e976 = r_1;
                                    let _e978 = cy[_e976];
                                    let _e982 = cc;
                                    let _e984 = rr[_e982];
                                    dCirc = (length((_e972 - vec2<f32>(_e975, _e978))) - _e984);
                                    let _e987 = cc;
                                    let _e988 = cnt;
                                    if (_e987 < _e988) {
                                        {
                                            let _e990 = acc;
                                            let _e991 = r_1;
                                            let _e993 = chan[_e991];
                                            let _e996 = aa_4;
                                            let _e998 = aa_4;
                                            let _e999 = dCirc;
                                            let _e1002 = r_1;
                                            let _e1004 = chan[_e1002];
                                            let _e1007 = hatch;
                                            acc = mix(_e990, _e993.xyz, vec3((((1f - smoothstep(-(_e996), _e998, _e999)) * _e1004.w) * _e1007)));
                                        }
                                    }
                                    let _e1011 = dStroke;
                                    let _e1012 = dCirc;
                                    dStroke = min(_e1011, abs(_e1012));
                                }
                                continuing {
                                    let _e969 = cc;
                                    cc = (_e969 + 1i);
                                }
                            }
                        }
                        continuing {
                            let _e947 = r_1;
                            r_1 = (_e947 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e1015 = strokeLw;
    if (_e1015 <= 0f) {
        local_3 = 0f;
    } else {
        let _e1020 = strokeLw;
        let _e1021 = aa_4;
        let _e1023 = strokeLw;
        let _e1024 = aa_4;
        let _e1026 = dStroke;
        local_3 = (1f - smoothstep((_e1020 - _e1021), (_e1023 + _e1024), _e1026));
    }
    let _e1030 = local_3;
    covStroke = _e1030;
    let _e1032 = acc;
    let _e1033 = colorOutline_1;
    let _e1035 = covStroke;
    let _e1036 = colorOutline_1;
    acc = mix(_e1032, _e1033.xyz, vec3((_e1035 * _e1036.w)));
    let _e1041 = frameLw;
    if (_e1041 <= 0f) {
        local_4 = 0f;
    } else {
        let _e1046 = frameLw;
        let _e1047 = aa_4;
        let _e1049 = frameLw;
        let _e1050 = aa_4;
        let _e1052 = dFrame;
        local_4 = (1f - smoothstep((_e1046 - _e1047), (_e1049 + _e1050), _e1052));
    }
    let _e1056 = local_4;
    covFrame = _e1056;
    let _e1058 = acc;
    let _e1059 = colorOutline_1;
    let _e1061 = covFrame;
    let _e1062 = colorOutline_1;
    acc = mix(_e1058, _e1059.xyz, vec3((_e1061 * _e1062.w)));
    let _e1067 = acc;
    return vec4<f32>(_e1067.x, _e1067.y, _e1067.z, 1f);
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
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e84 = global.U[10];
    let _e89 = global.U[11];
    let _e93 = global.U[12];
    let _e98 = global.U[13];
    let _e102 = global.U[14];
    let _e106 = global.U[15];
    let _e110 = global.U[16];
    let _e113 = global.U[17];
    let _e116 = global.U[18];
    let _e119 = global.U[19];
    let _e122 = global.U[20];
    let _e125 = global.U[21];
    let _e126 = _e125.xyz;
    let _e129 = global.U[22];
    let _e130 = _e129.xyz;
    let _e133 = global.U[23];
    let _e134 = _e133.xyz;
    let _e150 = global.U[24];
    let _e151 = _e150.xyz;
    let _e154 = global.U[25];
    let _e155 = _e154.xyz;
    let _e158 = global.U[26];
    let _e159 = _e158.xyz;
    let _e175 = global.U[4];
    let _e179 = global.U[5];
    let _e181 = charts((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, i32(_e84.x), _e89.x, i32(_e93.x), _e98.x, _e102.x, _e106.x, _e110, _e113, _e116, _e119, _e122, mat3x3<f32>(vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z)), mat3x3<f32>(vec3<f32>(_e151.x, _e151.y, _e151.z), vec3<f32>(_e155.x, _e155.y, _e155.z), vec3<f32>(_e159.x, _e159.y, _e159.z)), _e175.xy, _e179.xy);
    fragColor = _e181;
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
