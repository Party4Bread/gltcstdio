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
            let _e123 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e98.x / _e102.x), _e113.y) / vec2(2f)) + vec2(0.5f)), 0f);
            ccol = _e123.xyz;
            var_ = 0f;
            j = 0f;
            loop {
                let _e130 = j;
                let _e131 = n;
                if !((_e130 < _e131)) {
                    break;
                }
                {
                    i = 0f;
                    loop {
                        let _e139 = i;
                        let _e140 = n;
                        if !((_e139 < _e140)) {
                            break;
                        }
                        {
                            let _e146 = s2_;
                            let _e147 = i;
                            let _e148 = st;
                            let _e151 = s2_;
                            let _e152 = j;
                            let _e153 = st;
                            uu = vec2<f32>((_e146 + (_e147 * _e148)), (_e151 + (_e152 * _e153)));
                            let _e158 = modelTransform_1;
                            let _e159 = cid;
                            let _e160 = uu;
                            let _e162 = R;
                            let _e165 = tf(_e158, ((_e159 + _e160) / vec2(_e162)));
                            let _e169 = global.U[0];
                            let _e172 = modelTransform_1;
                            let _e173 = cid;
                            let _e174 = uu;
                            let _e176 = R;
                            let _e179 = tf(_e172, ((_e173 + _e174) / vec2(_e176)));
                            let _e189 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e165.x / _e169.x), _e179.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col = _e189.xyz;
                            let _e192 = var_;
                            let _e193 = ccol;
                            let _e194 = col;
                            let _e196 = ccol;
                            let _e197 = col;
                            var_ = (_e192 + dot((_e193 - _e194), (_e196 - _e197)));
                        }
                        continuing {
                            let _e143 = i;
                            i = (_e143 + 1f);
                        }
                    }
                }
                continuing {
                    let _e134 = j;
                    j = (_e134 + 1f);
                }
            }
            let _e201 = var_;
            let _e202 = n;
            let _e203 = n;
            let _e206 = thr;
            if ((_e201 / (_e202 * _e203)) < _e206) {
                break;
            }
            let _e208 = R;
            R = (_e208 * 2f);
        }
        continuing {
            let _e82 = k;
            k = (_e82 + 1i);
        }
    }
    let _e211 = vg;
    let _e212 = R;
    vv = (_e211 * _e212);
    let _e215 = vv;
    id = floor(_e215);
    {
        let _e218 = maskTransform_1;
        imask = _naga_inverse_3x3_f32(_e218);
        let _e222 = outDim_1;
        let _e224 = outDim_1;
        H = max(1f, (_e222.x / _e224.y));
        let _e229 = H;
        let _e230 = maskAR_1;
        let _e232 = H;
        mh = vec2<f32>((_e229 * _e230), _e232);
        let _e235 = imask;
        let _e236 = modelTransform_1;
        let _e237 = id;
        let _e241 = R;
        let _e244 = tf(_e236, ((_e237 + vec2(0.5f)) / vec2(_e241)));
        let _e245 = tf(_e235, _e244);
        ml = _e245;
        let _e251 = modelTransform_1[0][0];
        let _e256 = modelTransform_1[0][1];
        mScale = length(vec2<f32>(_e251, _e256));
        let _e264 = imask[0][0];
        let _e269 = imask[0][1];
        kScale = length(vec2<f32>(_e264, _e269));
        let _e274 = R;
        let _e276 = mScale;
        let _e278 = kScale;
        hc = (((0.5f / _e274) * _e276) * _e278);
        let _e281 = ml;
        let _e284 = mh;
        let _e286 = hc;
        let _e289 = ml;
        let _e292 = mh;
        let _e294 = hc;
        if ((abs(_e281.x) > (_e284.x + _e286)) || (abs(_e289.y) > (_e292.y + _e294))) {
            let _e298 = uv_1;
            let _e302 = global.U[0];
            let _e305 = uv_1;
            let _e315 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e298.x / _e302.x), _e305.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e315;
        }
    }
    let _e316 = vv;
    let _e317 = id;
    cell = ((_e316 - _e317) - vec2(0.5f));
    let _e324 = cell;
    cell.y = -(_e324.y);
    loop {
        let _e332 = j_1;
        let _e333 = n;
        if !((_e332 < _e333)) {
            break;
        }
        {
            i_1 = 0f;
            loop {
                let _e341 = i_1;
                let _e342 = n;
                if !((_e341 < _e342)) {
                    break;
                }
                {
                    let _e348 = s2_;
                    let _e349 = i_1;
                    let _e350 = st;
                    let _e353 = s2_;
                    let _e354 = j_1;
                    let _e355 = st;
                    uu_1 = vec2<f32>((_e348 + (_e349 * _e350)), (_e353 + (_e354 * _e355)));
                    let _e360 = csum;
                    let _e361 = modelTransform_1;
                    let _e362 = id;
                    let _e363 = uu_1;
                    let _e365 = R;
                    let _e368 = tf(_e361, ((_e362 + _e363) / vec2(_e365)));
                    let _e372 = global.U[0];
                    let _e375 = modelTransform_1;
                    let _e376 = id;
                    let _e377 = uu_1;
                    let _e379 = R;
                    let _e382 = tf(_e375, ((_e376 + _e377) / vec2(_e379)));
                    let _e392 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e368.x / _e372.x), _e382.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    csum = (_e360 + _e392.xyz);
                }
                continuing {
                    let _e345 = i_1;
                    i_1 = (_e345 + 1f);
                }
            }
        }
        continuing {
            let _e336 = j_1;
            j_1 = (_e336 + 1f);
        }
    }
    let _e395 = csum;
    let _e396 = n;
    let _e397 = n;
    c = (_e395 / vec3((_e396 * _e397)));
    let _e405 = c;
    vals[0i] = clamp(_e405.x, 0f, 1f);
    let _e412 = c;
    vals[1i] = clamp(_e412.y, 0f, 1f);
    let _e419 = c;
    vals[2i] = clamp(_e419.z, 0f, 1f);
    let _e427 = colorR_1;
    chan[0i] = _e427;
    let _e430 = colorG_1;
    chan[1i] = _e430;
    let _e433 = colorB_1;
    chan[2i] = _e433;
    let _e435 = outDim_1;
    pixel = (2f / _e435.y);
    let _e439 = im;
    let _e440 = uv_1;
    let _e441 = pixel;
    let _e445 = tf(_e439, (_e440 + vec2<f32>(_e441, 0f)));
    let _e446 = vg;
    let _e449 = R;
    aa_4 = max((length((_e445 - _e446)) * _e449), 0.0001f);
    let _e454 = thickness_1;
    strokeLw = (_e454 * 0.05f);
    let _e458 = border_1;
    frameLw = (_e458 * 0.06f);
    let _e462 = style_1;
    styleCell = clamp(_e462, 0i, 3i);
    let _e467 = id;
    let _e468 = randomSeed_1;
    let _e469 = randomSeed_1;
    let _e476 = hash22_((_e467 + vec2<f32>(_e468, ((_e469 * 1.7f) + 3.1f))));
    hh = _e476;
    let _e478 = hh;
    let _e480 = randomness_1;
    if (_e478.x < _e480) {
        {
            let _e482 = hh;
            styleCell = min(i32(floor((_e482.y * 4f))), 3i);
        }
    }
    let _e490 = uv_1;
    let _e494 = global.U[0];
    let _e497 = uv_1;
    let _e507 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e490.x / _e494.x), _e497.y) / vec2(2f)) + vec2(0.5f)), 0f);
    bkg = _e507;
    let _e509 = bkg;
    let _e511 = colorBkg_1;
    let _e513 = colorBkg_1;
    acc = mix(_e509.xyz, _e511.xyz, vec3(_e513.w));
    let _e521 = cell;
    let _e524 = cell;
    dFrame = abs((0.5f - max(abs(_e521.x), abs(_e524.y))));
    let _e531 = fill_1;
    if (_e531 == 1i) {
        let _e534 = cell;
        let _e535 = aa_4;
        let _e536 = chHatch(_e534, _e535);
        local = _e536;
    } else {
        local = 1f;
    }
    let _e539 = local;
    hatch = _e539;
    let _e541 = styleCell;
    if (_e541 == 0i) {
        {
            let _e546 = cell;
            let _e548 = r;
            dDisc = (length(_e546) - _e548);
            let _e551 = dStroke;
            let _e552 = dDisc;
            dStroke = min(_e551, abs(_e552));
            let _e557 = vals[0];
            let _e560 = vals[1];
            let _e564 = vals[2];
            rawSum = ((_e557 + _e560) + _e564);
            let _e567 = rawSum;
            if (_e567 > 0.0001f) {
                {
                    let _e572 = vals[0];
                    let _e573 = rawSum;
                    f0_ = (_e572 / _e573);
                    let _e576 = f0_;
                    let _e579 = vals[1];
                    let _e580 = rawSum;
                    f1_ = (_e576 + (_e579 / _e580));
                    let _e584 = dDisc;
                    let _e585 = aa_4;
                    if (_e584 < _e585) {
                        {
                            let _e588 = aa_4;
                            let _e590 = aa_4;
                            let _e591 = dDisc;
                            discCov = (1f - smoothstep(-(_e588), _e590, _e591));
                            let _e595 = cell;
                            let _e597 = cell;
                            ang = fract(((atan2(_e595.y, _e597.x) / 6.2831855f) + 1f));
                            let _e608 = ang;
                            let _e609 = f0_;
                            if (_e608 < _e609) {
                                {
                                    let _e613 = chan[0];
                                    wcol = _e613.xyz;
                                    let _e617 = chan[0];
                                    wa = _e617.w;
                                }
                            } else {
                                let _e619 = ang;
                                let _e620 = f1_;
                                if (_e619 < _e620) {
                                    {
                                        let _e624 = chan[1];
                                        wcol = _e624.xyz;
                                        let _e628 = chan[1];
                                        wa = _e628.w;
                                    }
                                } else {
                                    {
                                        let _e632 = chan[2];
                                        wcol = _e632.xyz;
                                        let _e636 = chan[2];
                                        wa = _e636.w;
                                    }
                                }
                            }
                            let _e638 = acc;
                            let _e639 = wcol;
                            let _e640 = discCov;
                            let _e641 = wa;
                            let _e643 = hatch;
                            acc = mix(_e638, _e639, vec3(((_e640 * _e641) * _e643)));
                        }
                    }
                    let _e647 = dStroke;
                    let _e648 = cell;
                    let _e651 = r;
                    let _e656 = sdSegment(_e648, vec2(0f), (_e651 * vec2<f32>(1f, 0f)));
                    dStroke = min(_e647, _e656);
                    let _e658 = dStroke;
                    let _e659 = cell;
                    let _e662 = r;
                    let _e663 = f0_;
                    let _e667 = f0_;
                    let _e673 = sdSegment(_e659, vec2(0f), (_e662 * vec2<f32>(cos((_e663 * 6.2831855f)), sin((_e667 * 6.2831855f)))));
                    dStroke = min(_e658, _e673);
                    let _e675 = dStroke;
                    let _e676 = cell;
                    let _e679 = r;
                    let _e680 = f1_;
                    let _e684 = f1_;
                    let _e690 = sdSegment(_e676, vec2(0f), (_e679 * vec2<f32>(cos((_e680 * 6.2831855f)), sin((_e684 * 6.2831855f)))));
                    dStroke = min(_e675, _e690);
                }
            }
        }
    } else {
        let _e692 = styleCell;
        if (_e692 == 1i) {
            {
                loop {
                    let _e702 = b_2;
                    if !((_e702 < 3i)) {
                        break;
                    }
                    {
                        let _e711 = b_2;
                        bx = (-0.24f + (f32(_e711) * 0.24f));
                        let _e717 = b_2;
                        let _e719 = vals[_e717];
                        let _e720 = maxH;
                        h_1 = (_e719 * _e720);
                        let _e723 = cell;
                        let _e724 = bx;
                        let _e727 = base;
                        let _e729 = bx;
                        let _e732 = base;
                        let _e733 = h_1;
                        let _e738 = chBox(_e723, vec2<f32>((_e724 - 0.085f), _e727), vec2<f32>((_e729 + 0.085f), (_e732 + max(_e733, 0.004f))));
                        d_2 = _e738;
                        let _e740 = acc;
                        let _e741 = b_2;
                        let _e743 = chan[_e741];
                        let _e746 = aa_4;
                        let _e748 = aa_4;
                        let _e749 = d_2;
                        let _e752 = b_2;
                        let _e754 = chan[_e752];
                        let _e757 = hatch;
                        acc = mix(_e740, _e743.xyz, vec3((((1f - smoothstep(-(_e746), _e748, _e749)) * _e754.w) * _e757)));
                        let _e761 = dStroke;
                        let _e762 = d_2;
                        dStroke = min(_e761, abs(_e762));
                    }
                    continuing {
                        let _e706 = b_2;
                        b_2 = (_e706 + 1i);
                    }
                }
                let _e765 = dStroke;
                let _e766 = cell;
                let _e769 = base;
                let _e772 = base;
                let _e774 = sdSegment(_e766, vec2<f32>(-0.4f, _e769), vec2<f32>(0.4f, _e772));
                dStroke = min(_e765, _e774);
            }
        } else {
            let _e776 = styleCell;
            if (_e776 == 2i) {
                {
                    let _e781 = fill_1;
                    if (_e781 == 1i) {
                        let _e784 = cell;
                        let _e785 = aa_4;
                        let _e786 = chHatchRadial(_e784, _e785);
                        local_1 = _e786;
                    } else {
                        local_1 = 1f;
                    }
                    let _e789 = local_1;
                    hatchR = _e789;
                    loop {
                        let _e793 = b_3;
                        if !((_e793 < 3i)) {
                            break;
                        }
                        {
                            let _e801 = b_3;
                            ri = (0.14f + (f32(_e801) * 0.1f));
                            let _e807 = cell;
                            let _e809 = ri;
                            dTrack = abs((length(_e807) - _e809));
                            let _e813 = strokeLw;
                            if (_e813 <= 0f) {
                                local_2 = 0f;
                            } else {
                                let _e818 = strokeLw;
                                let _e819 = aa_4;
                                let _e821 = strokeLw;
                                let _e822 = aa_4;
                                let _e824 = dTrack;
                                local_2 = (1f - smoothstep((_e818 - _e819), (_e821 + _e822), _e824));
                            }
                            let _e828 = local_2;
                            covTrack = _e828;
                            let _e830 = acc;
                            let _e831 = colorOutline_1;
                            let _e833 = covTrack;
                            let _e834 = colorOutline_1;
                            acc = mix(_e830, _e831.xyz, vec3((_e833 * _e834.w)));
                            let _e840 = strokeLw;
                            let _e842 = aa_4;
                            hw = max(0.03f, (_e840 + (2f * _e842)));
                            let _e847 = cell;
                            let _e849 = ri;
                            let _e852 = hw;
                            dRing = (abs((length(_e847) - _e849)) - _e852);
                            let _e855 = startAng;
                            let _e856 = cell;
                            let _e858 = cell;
                            ang_1 = fract((((_e855 - atan2(_e856.y, _e858.x)) / 6.2831855f) + 1f));
                            let _e868 = aa_4;
                            let _e870 = ri;
                            angAA = (_e868 / max((6.2831855f * _e870), 0.001f));
                            let _e877 = b_3;
                            let _e879 = vals[_e877];
                            let _e880 = angAA;
                            let _e882 = b_3;
                            let _e884 = vals[_e882];
                            let _e885 = angAA;
                            let _e887 = ang_1;
                            angMask = (1f - smoothstep((_e879 - _e880), (_e884 + _e885), _e887));
                            let _e891 = acc;
                            let _e892 = b_3;
                            let _e894 = chan[_e892];
                            let _e897 = aa_4;
                            let _e899 = aa_4;
                            let _e900 = dRing;
                            let _e903 = angMask;
                            let _e905 = b_3;
                            let _e907 = chan[_e905];
                            let _e910 = hatchR;
                            acc = mix(_e891, _e894.xyz, vec3(((((1f - smoothstep(-(_e897), _e899, _e900)) * _e903) * _e907.w) * _e910)));
                        }
                        continuing {
                            let _e797 = b_3;
                            b_3 = (_e797 + 1i);
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
                        let _e948 = r_1;
                        if !((_e948 < 3i)) {
                            break;
                        }
                        {
                            let _e955 = r_1;
                            let _e957 = vals[_e955];
                            cnt = clamp(i32(floor(((_e957 * 3f) + 0.5f))), 0i, 3i);
                            cc = 0i;
                            loop {
                                let _e970 = cc;
                                if !((_e970 < 3i)) {
                                    break;
                                }
                                {
                                    let _e977 = cell;
                                    let _e978 = cc;
                                    let _e980 = cx[_e978];
                                    let _e981 = r_1;
                                    let _e983 = cy[_e981];
                                    let _e987 = cc;
                                    let _e989 = rr[_e987];
                                    dCirc = (length((_e977 - vec2<f32>(_e980, _e983))) - _e989);
                                    let _e992 = cc;
                                    let _e993 = cnt;
                                    if (_e992 < _e993) {
                                        {
                                            let _e995 = acc;
                                            let _e996 = r_1;
                                            let _e998 = chan[_e996];
                                            let _e1001 = aa_4;
                                            let _e1003 = aa_4;
                                            let _e1004 = dCirc;
                                            let _e1007 = r_1;
                                            let _e1009 = chan[_e1007];
                                            let _e1012 = hatch;
                                            acc = mix(_e995, _e998.xyz, vec3((((1f - smoothstep(-(_e1001), _e1003, _e1004)) * _e1009.w) * _e1012)));
                                        }
                                    }
                                    let _e1016 = dStroke;
                                    let _e1017 = dCirc;
                                    dStroke = min(_e1016, abs(_e1017));
                                }
                                continuing {
                                    let _e974 = cc;
                                    cc = (_e974 + 1i);
                                }
                            }
                        }
                        continuing {
                            let _e952 = r_1;
                            r_1 = (_e952 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e1020 = strokeLw;
    if (_e1020 <= 0f) {
        local_3 = 0f;
    } else {
        let _e1025 = strokeLw;
        let _e1026 = aa_4;
        let _e1028 = strokeLw;
        let _e1029 = aa_4;
        let _e1031 = dStroke;
        local_3 = (1f - smoothstep((_e1025 - _e1026), (_e1028 + _e1029), _e1031));
    }
    let _e1035 = local_3;
    covStroke = _e1035;
    let _e1037 = acc;
    let _e1038 = colorOutline_1;
    let _e1040 = covStroke;
    let _e1041 = colorOutline_1;
    acc = mix(_e1037, _e1038.xyz, vec3((_e1040 * _e1041.w)));
    let _e1046 = frameLw;
    if (_e1046 <= 0f) {
        local_4 = 0f;
    } else {
        let _e1051 = frameLw;
        let _e1052 = aa_4;
        let _e1054 = frameLw;
        let _e1055 = aa_4;
        let _e1057 = dFrame;
        local_4 = (1f - smoothstep((_e1051 - _e1052), (_e1054 + _e1055), _e1057));
    }
    let _e1061 = local_4;
    covFrame = _e1061;
    let _e1063 = acc;
    let _e1064 = colorOutline_1;
    let _e1066 = covFrame;
    let _e1067 = colorOutline_1;
    acc = mix(_e1063, _e1064.xyz, vec3((_e1066 * _e1067.w)));
    let _e1072 = acc;
    return vec4<f32>(_e1072.x, _e1072.y, _e1072.z, 1f);
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
