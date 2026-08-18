struct Params {
    U: array<vec4<f32>, 14>,
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

fn dRect(p: vec2<f32>, c_2: vec2<f32>, E: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var c_3: vec2<f32>;
    var E_1: vec2<f32>;

    p_1 = p;
    c_3 = c_2;
    E_1 = E;
    let _e12 = p_1;
    let _e14 = c_3;
    let _e18 = E_1;
    let _e21 = p_1;
    let _e23 = c_3;
    let _e27 = E_1;
    return max((abs((_e12.x - _e14.x)) - _e18.x), (abs((_e21.y - _e23.y)) - _e27.y));
}

fn dSeg(p_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var lo: vec2<f32>;
    var hi: vec2<f32>;
    var d: vec2<f32>;

    p_3 = p_2;
    a_1 = a;
    b_1 = b;
    let _e12 = a_1;
    let _e13 = b_1;
    lo = min(_e12, _e13);
    let _e16 = a_1;
    let _e17 = b_1;
    hi = max(_e16, _e17);
    let _e20 = lo;
    let _e21 = p_3;
    let _e23 = p_3;
    let _e24 = hi;
    d = max((_e20 - _e21), (_e23 - _e24));
    let _e28 = d;
    let _e30 = d;
    return max(_e28.x, _e30.y);
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

fn sdTri(p_4: vec2<f32>, r: f32) -> f32 {
    var p_5: vec2<f32>;
    var r_1: f32;
    var k: f32 = 1.7320508f;

    p_5 = p_4;
    r_1 = r;
    let _e13 = p_5;
    let _e16 = r_1;
    p_5.x = (abs(_e13.x) - _e16);
    let _e19 = p_5;
    let _e21 = r_1;
    let _e22 = k;
    p_5.y = (_e19.y + (_e21 / _e22));
    let _e25 = p_5;
    let _e27 = k;
    let _e28 = p_5;
    if ((_e25.x + (_e27 * _e28.y)) > 0f) {
        let _e34 = p_5;
        let _e36 = k;
        let _e37 = p_5;
        let _e41 = k;
        let _e43 = p_5;
        let _e46 = p_5;
        p_5 = (vec2<f32>((_e34.x - (_e36 * _e37.y)), ((-(_e41) * _e43.x) - _e46.y)) / vec2(2f));
    }
    let _e54 = p_5;
    let _e56 = p_5;
    let _e60 = r_1;
    p_5.x = (_e54.x - clamp(_e56.x, (-2f * _e60), 0f));
    let _e65 = p_5;
    let _e68 = p_5;
    return (-(length(_e65)) * sign(_e68.y));
}

fn tbBit(mode: i32, i: f32) -> f32 {
    var mode_1: i32;
    var i_1: f32;

    mode_1 = mode;
    i_1 = i;
    let _e10 = mode_1;
    let _e13 = i_1;
    let _e16 = floor((f32(_e10) / pow(2f, _e13)));
    return (_e16 - (floor((_e16 / 2f)) * 2f));
}

fn technicalBorder(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>, mode_2: i32, cornerStyle: i32, thickness: f32, border: f32, size: f32, count: i32, color1_: vec4<f32>, borderColor: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var mode_3: i32;
    var cornerStyle_1: i32;
    var thickness_1: f32;
    var border_1: f32;
    var size_1: f32;
    var count_1: i32;
    var color1_1: vec4<f32>;
    var borderColor_1: vec4<f32>;
    var ratio: f32;
    var borderSize: f32;
    var newBounds: vec2<f32>;
    var img: vec2<f32>;
    var H: vec2<f32>;
    var pixel: f32;
    var aa: f32;
    var th: f32;
    var dImg: f32;
    var local: vec4<f32>;
    var base: vec4<f32>;
    var m: vec2<f32>;
    var oF: vec2<f32>;
    var iF: vec2<f32>;
    var d_1: f32 = 1000000000f;
    var tickLen: f32;
    var spx: f32;
    var spy: f32;
    var txn: f32;
    var tyn: f32;
    var Lc: f32;
    var gap: f32;
    var sxi: i32 = 0i;
    var syi: i32;
    var local_1: f32;
    var sx: f32;
    var local_2: f32;
    var sy: f32;
    var c_4: vec2<f32>;
    var local_3: f32;
    var dir: f32;
    var r_2: f32;
    var tC: vec2<f32>;
    var bC: vec2<f32>;
    var rC: vec2<f32>;
    var rq: vec2<f32>;
    var lC: vec2<f32>;
    var lq: vec2<f32>;
    var pw: f32;
    var ph: f32;
    var pmax: vec2<f32>;
    var pmin: vec2<f32>;
    var pc: vec2<f32>;
    var phf: vec2<f32>;
    var panelIn: f32;
    var cov: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    mode_3 = mode_2;
    cornerStyle_1 = cornerStyle;
    thickness_1 = thickness;
    border_1 = border;
    size_1 = size;
    count_1 = count;
    color1_1 = color1_;
    borderColor_1 = borderColor;
    let _e30 = sourceDim_1;
    let _e32 = sourceDim_1;
    ratio = (_e30.x / _e32.y);
    let _e36 = border_1;
    let _e40 = ratio;
    borderSize = ((_e36 * 2f) * min(1f, _e40));
    let _e44 = ratio;
    let _e47 = borderSize;
    newBounds = (vec2<f32>(_e44, 1f) + vec2(_e47));
    let _e51 = outDim_1;
    let _e53 = outDim_1;
    let _e56 = ratio;
    let _e58 = newBounds;
    let _e62 = newBounds;
    img = vec2<f32>((((_e51.x / _e53.y) * _e56) / _e58.x), (1f / _e62.y));
    let _e67 = outDim_1;
    let _e69 = outDim_1;
    H = vec2<f32>((_e67.x / _e69.y), 1f);
    let _e76 = outDim_1;
    pixel = (2f / _e76.y);
    let _e80 = pixel;
    aa = (_e80 * 0.75f);
    let _e84 = thickness_1;
    let _e87 = pixel;
    th = max((_e84 * 0.01f), (_e87 * 0.5f));
    let _e92 = uv_1;
    let _e95 = img;
    let _e96 = dRect(_e92, vec2(0f), _e95);
    dImg = _e96;
    let _e98 = dImg;
    if (_e98 < 0f) {
        let _e101 = uv_1;
        let _e105 = global.U[0];
        let _e108 = uv_1;
        let _e117 = _mirror_wrap(((vec2<f32>((_e101.x / _e105.x), _e108.y) / vec2(2f)) + vec2(0.5f)));
        let _e119 = textureSampleLevel(t_source, samp, _e117, 0f);
        local = _e119;
    } else {
        let _e120 = uv_1;
        let _e124 = global.U[0];
        let _e127 = uv_1;
        let _e136 = _mirror_wrap(((vec2<f32>((_e120.x / _e124.x), _e127.y) / vec2(2f)) + vec2(0.5f)));
        let _e138 = textureSampleLevel(t_source, samp, _e136, 0f);
        let _e139 = borderColor_1;
        let _e140 = mergeColor(_e138, _e139);
        local = _e140;
    }
    let _e142 = local;
    base = _e142;
    let _e144 = H;
    let _e145 = img;
    m = max((_e144 - _e145), vec2(0f));
    let _e151 = H;
    let _e153 = m;
    oF = (_e151 - (0.3f * _e153));
    let _e157 = img;
    let _e159 = m;
    iF = (_e157 + (0.15f * _e159));
    let _e165 = mode_3;
    let _e167 = tbBit(_e165, 0f);
    if (_e167 > 0.5f) {
        let _e170 = d_1;
        let _e171 = uv_1;
        let _e174 = oF;
        let _e175 = dRect(_e171, vec2(0f), _e174);
        d_1 = min(_e170, abs(_e175));
    }
    let _e178 = mode_3;
    let _e180 = tbBit(_e178, 1f);
    if (_e180 > 0.5f) {
        let _e183 = d_1;
        let _e184 = uv_1;
        let _e187 = iF;
        let _e188 = dRect(_e184, vec2(0f), _e187);
        d_1 = min(_e183, abs(_e188));
    }
    let _e191 = mode_3;
    let _e193 = tbBit(_e191, 3f);
    let _e196 = count_1;
    if ((_e193 > 0.5f) && (_e196 > 0i)) {
        {
            let _e200 = size_1;
            tickLen = (_e200 * 0.06f);
            let _e205 = oF;
            let _e208 = count_1;
            spx = ((2f * _e205.x) / f32(_e208));
            let _e213 = oF;
            let _e216 = count_1;
            spy = ((2f * _e213.y) / f32(_e216));
            let _e220 = uv_1;
            let _e222 = oF;
            let _e225 = spx;
            let _e230 = spx;
            let _e232 = oF;
            let _e235 = oF;
            let _e238 = oF;
            txn = clamp(((floor((((_e220.x + _e222.x) / _e225) + 0.5f)) * _e230) - _e232.x), -(_e235.x), _e238.x);
            let _e242 = uv_1;
            let _e244 = oF;
            let _e247 = spy;
            let _e252 = spy;
            let _e254 = oF;
            let _e257 = oF;
            let _e260 = oF;
            tyn = clamp(((floor((((_e242.y + _e244.y) / _e247) + 0.5f)) * _e252) - _e254.y), -(_e257.y), _e260.y);
            let _e264 = d_1;
            let _e265 = uv_1;
            let _e266 = txn;
            let _e267 = oF;
            let _e270 = txn;
            let _e271 = oF;
            let _e273 = tickLen;
            let _e276 = dSeg(_e265, vec2<f32>(_e266, _e267.y), vec2<f32>(_e270, (_e271.y - _e273)));
            d_1 = min(_e264, _e276);
            let _e278 = d_1;
            let _e279 = uv_1;
            let _e280 = txn;
            let _e281 = oF;
            let _e285 = txn;
            let _e286 = oF;
            let _e289 = tickLen;
            let _e292 = dSeg(_e279, vec2<f32>(_e280, -(_e281.y)), vec2<f32>(_e285, (-(_e286.y) + _e289)));
            d_1 = min(_e278, _e292);
            let _e294 = d_1;
            let _e295 = uv_1;
            let _e296 = oF;
            let _e298 = tyn;
            let _e300 = oF;
            let _e302 = tickLen;
            let _e304 = tyn;
            let _e306 = dSeg(_e295, vec2<f32>(_e296.x, _e298), vec2<f32>((_e300.x - _e302), _e304));
            d_1 = min(_e294, _e306);
            let _e308 = d_1;
            let _e309 = uv_1;
            let _e310 = oF;
            let _e313 = tyn;
            let _e315 = oF;
            let _e318 = tickLen;
            let _e320 = tyn;
            let _e322 = dSeg(_e309, vec2<f32>(-(_e310.x), _e313), vec2<f32>((-(_e315.x) + _e318), _e320));
            d_1 = min(_e308, _e322);
        }
    }
    let _e324 = mode_3;
    let _e326 = tbBit(_e324, 2f);
    let _e329 = cornerStyle_1;
    if ((_e326 > 0.5f) && (_e329 != 0i)) {
        {
            let _e333 = size_1;
            Lc = (_e333 * 0.14f);
            let _e337 = size_1;
            gap = (_e337 * 0.05f);
            loop {
                let _e343 = sxi;
                if !((_e343 < 2i)) {
                    break;
                }
                {
                    syi = 0i;
                    loop {
                        let _e352 = syi;
                        if !((_e352 < 2i)) {
                            break;
                        }
                        {
                            let _e359 = sxi;
                            if (_e359 == 0i) {
                                local_1 = -1f;
                            } else {
                                local_1 = 1f;
                            }
                            let _e366 = local_1;
                            sx = _e366;
                            let _e368 = syi;
                            if (_e368 == 0i) {
                                local_2 = -1f;
                            } else {
                                local_2 = 1f;
                            }
                            let _e375 = local_2;
                            sy = _e375;
                            let _e377 = cornerStyle_1;
                            if (_e377 == 4i) {
                                {
                                    let _e380 = d_1;
                                    let _e381 = uv_1;
                                    let _e382 = sx;
                                    let _e383 = img;
                                    let _e385 = gap;
                                    let _e388 = sy;
                                    let _e389 = img;
                                    let _e393 = sx;
                                    let _e394 = img;
                                    let _e396 = gap;
                                    let _e398 = Lc;
                                    let _e401 = sy;
                                    let _e402 = img;
                                    let _e406 = dSeg(_e381, vec2<f32>((_e382 * (_e383.x + _e385)), (_e388 * _e389.y)), vec2<f32>((_e393 * ((_e394.x + _e396) + _e398)), (_e401 * _e402.y)));
                                    d_1 = min(_e380, _e406);
                                    let _e408 = d_1;
                                    let _e409 = uv_1;
                                    let _e410 = sx;
                                    let _e411 = img;
                                    let _e414 = sy;
                                    let _e415 = img;
                                    let _e417 = gap;
                                    let _e421 = sx;
                                    let _e422 = img;
                                    let _e425 = sy;
                                    let _e426 = img;
                                    let _e428 = gap;
                                    let _e430 = Lc;
                                    let _e434 = dSeg(_e409, vec2<f32>((_e410 * _e411.x), (_e414 * (_e415.y + _e417))), vec2<f32>((_e421 * _e422.x), (_e425 * ((_e426.y + _e428) + _e430))));
                                    d_1 = min(_e408, _e434);
                                }
                            } else {
                                {
                                    let _e436 = sx;
                                    let _e437 = iF;
                                    let _e440 = sy;
                                    let _e441 = iF;
                                    c_4 = vec2<f32>((_e436 * _e437.x), (_e440 * _e441.y));
                                    let _e446 = cornerStyle_1;
                                    if (_e446 == 3i) {
                                        {
                                            let _e449 = d_1;
                                            let _e450 = uv_1;
                                            let _e451 = c_4;
                                            let _e452 = Lc;
                                            let _e456 = c_4;
                                            let _e457 = Lc;
                                            let _e461 = dSeg(_e450, (_e451 - vec2<f32>(_e452, 0f)), (_e456 + vec2<f32>(_e457, 0f)));
                                            d_1 = min(_e449, _e461);
                                            let _e463 = d_1;
                                            let _e464 = uv_1;
                                            let _e465 = c_4;
                                            let _e467 = Lc;
                                            let _e470 = c_4;
                                            let _e472 = Lc;
                                            let _e475 = dSeg(_e464, (_e465 - vec2<f32>(0f, _e467)), (_e470 + vec2<f32>(0f, _e472)));
                                            d_1 = min(_e463, _e475);
                                        }
                                    } else {
                                        {
                                            let _e477 = cornerStyle_1;
                                            if (_e477 == 1i) {
                                                local_3 = -1f;
                                            } else {
                                                local_3 = 1f;
                                            }
                                            let _e484 = local_3;
                                            dir = _e484;
                                            let _e486 = d_1;
                                            let _e487 = uv_1;
                                            let _e488 = c_4;
                                            let _e489 = c_4;
                                            let _e490 = sx;
                                            let _e491 = dir;
                                            let _e493 = Lc;
                                            let _e498 = dSeg(_e487, _e488, (_e489 + vec2<f32>(((_e490 * _e491) * _e493), 0f)));
                                            d_1 = min(_e486, _e498);
                                            let _e500 = d_1;
                                            let _e501 = uv_1;
                                            let _e502 = c_4;
                                            let _e503 = c_4;
                                            let _e505 = sy;
                                            let _e506 = dir;
                                            let _e508 = Lc;
                                            let _e512 = dSeg(_e501, _e502, (_e503 + vec2<f32>(0f, ((_e505 * _e506) * _e508))));
                                            d_1 = min(_e500, _e512);
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e356 = syi;
                            syi = (_e356 + 1i);
                        }
                    }
                }
                continuing {
                    let _e347 = sxi;
                    sxi = (_e347 + 1i);
                }
            }
        }
    }
    let _e514 = mode_3;
    let _e516 = tbBit(_e514, 4f);
    if (_e516 > 0.5f) {
        {
            let _e519 = size_1;
            r_2 = (_e519 * 0.05f);
            let _e524 = oF;
            let _e527 = r_2;
            tC = vec2<f32>(0f, (_e524.y - (1.3f * _e527)));
            let _e532 = d_1;
            let _e533 = uv_1;
            let _e534 = tC;
            let _e537 = r_2;
            let _e538 = sdTri(-((_e533 - _e534)), _e537);
            d_1 = min(_e532, _e538);
            let _e541 = oF;
            let _e545 = r_2;
            bC = vec2<f32>(0f, (-(_e541.y) + (1.3f * _e545)));
            let _e550 = d_1;
            let _e551 = uv_1;
            let _e552 = bC;
            let _e554 = r_2;
            let _e555 = sdTri((_e551 - _e552), _e554);
            d_1 = min(_e550, _e555);
            let _e557 = oF;
            let _e560 = r_2;
            rC = vec2<f32>((_e557.x - (1.3f * _e560)), 0f);
            let _e566 = uv_1;
            let _e567 = rC;
            rq = (_e566 - _e567);
            let _e570 = d_1;
            let _e571 = rq;
            let _e573 = rq;
            let _e577 = r_2;
            let _e578 = sdTri(vec2<f32>(_e571.y, -(_e573.x)), _e577);
            d_1 = min(_e570, _e578);
            let _e580 = oF;
            let _e584 = r_2;
            lC = vec2<f32>((-(_e580.x) + (1.3f * _e584)), 0f);
            let _e590 = uv_1;
            let _e591 = lC;
            lq = (_e590 - _e591);
            let _e594 = d_1;
            let _e595 = lq;
            let _e598 = lq;
            let _e601 = r_2;
            let _e602 = sdTri(vec2<f32>(-(_e595.y), _e598.x), _e601);
            d_1 = min(_e594, _e602);
        }
    }
    let _e604 = mode_3;
    let _e606 = tbBit(_e604, 5f);
    if (_e606 > 0.5f) {
        {
            let _e609 = size_1;
            pw = (_e609 * 0.6f);
            let _e613 = size_1;
            ph = (_e613 * 0.26f);
            let _e617 = img;
            pmax = _e617;
            let _e619 = pmax;
            let _e620 = pw;
            let _e621 = ph;
            pmin = (_e619 - vec2<f32>(_e620, _e621));
            let _e625 = pmin;
            let _e626 = pmax;
            pc = ((_e625 + _e626) * 0.5f);
            let _e631 = pmax;
            let _e632 = pmin;
            phf = ((_e631 - _e632) * 0.5f);
            let _e638 = aa;
            let _e640 = aa;
            let _e641 = uv_1;
            let _e642 = pc;
            let _e643 = phf;
            let _e644 = dRect(_e641, _e642, _e643);
            panelIn = (1f - smoothstep(-(_e638), _e640, _e644));
            let _e648 = base;
            let _e649 = base;
            let _e650 = borderColor_1;
            let _e651 = mergeColor(_e649, _e650);
            let _e652 = panelIn;
            base = mix(_e648, _e651, vec4(_e652));
            let _e655 = d_1;
            let _e656 = uv_1;
            let _e657 = pc;
            let _e658 = phf;
            let _e659 = dRect(_e656, _e657, _e658);
            d_1 = min(_e655, abs(_e659));
            let _e662 = d_1;
            let _e663 = uv_1;
            let _e664 = pc;
            let _e666 = pmin;
            let _e669 = pc;
            let _e671 = pmax;
            let _e674 = dSeg(_e663, vec2<f32>(_e664.x, _e666.y), vec2<f32>(_e669.x, _e671.y));
            d_1 = min(_e662, _e674);
            let _e676 = d_1;
            let _e677 = uv_1;
            let _e678 = pmin;
            let _e680 = pc;
            let _e683 = pmax;
            let _e685 = pc;
            let _e688 = dSeg(_e677, vec2<f32>(_e678.x, _e680.y), vec2<f32>(_e683.x, _e685.y));
            d_1 = min(_e676, _e688);
        }
    }
    let _e691 = th;
    let _e692 = aa;
    let _e694 = th;
    let _e695 = aa;
    let _e697 = d_1;
    cov = (1f - smoothstep((_e691 - _e692), (_e694 + _e695), _e697));
    let _e701 = base;
    let _e702 = color1_1;
    let _e703 = _e702.xyz;
    let _e704 = color1_1;
    let _e706 = cov;
    let _e712 = mergeColor(_e701, vec4<f32>(_e703.x, _e703.y, _e703.z, (_e704.w * _e706)));
    return _e712;
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
    let _e74 = global.U[6];
    let _e79 = global.U[7];
    let _e84 = global.U[8];
    let _e88 = global.U[9];
    let _e92 = global.U[10];
    let _e96 = global.U[11];
    let _e101 = global.U[12];
    let _e104 = global.U[13];
    let _e105 = technicalBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.xy, i32(_e74.x), i32(_e79.x), _e84.x, _e88.x, _e92.x, i32(_e96.x), _e101, _e104);
    fragColor = _e105;
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
