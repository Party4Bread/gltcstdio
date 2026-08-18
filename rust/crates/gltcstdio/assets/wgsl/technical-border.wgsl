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
        let _e118 = textureSample(t_source, samp, _e117);
        local = _e118;
    } else {
        let _e119 = uv_1;
        let _e123 = global.U[0];
        let _e126 = uv_1;
        let _e135 = _mirror_wrap(((vec2<f32>((_e119.x / _e123.x), _e126.y) / vec2(2f)) + vec2(0.5f)));
        let _e136 = textureSample(t_source, samp, _e135);
        let _e137 = borderColor_1;
        let _e138 = mergeColor(_e136, _e137);
        local = _e138;
    }
    let _e140 = local;
    base = _e140;
    let _e142 = H;
    let _e143 = img;
    m = max((_e142 - _e143), vec2(0f));
    let _e149 = H;
    let _e151 = m;
    oF = (_e149 - (0.3f * _e151));
    let _e155 = img;
    let _e157 = m;
    iF = (_e155 + (0.15f * _e157));
    let _e163 = mode_3;
    let _e165 = tbBit(_e163, 0f);
    if (_e165 > 0.5f) {
        let _e168 = d_1;
        let _e169 = uv_1;
        let _e172 = oF;
        let _e173 = dRect(_e169, vec2(0f), _e172);
        d_1 = min(_e168, abs(_e173));
    }
    let _e176 = mode_3;
    let _e178 = tbBit(_e176, 1f);
    if (_e178 > 0.5f) {
        let _e181 = d_1;
        let _e182 = uv_1;
        let _e185 = iF;
        let _e186 = dRect(_e182, vec2(0f), _e185);
        d_1 = min(_e181, abs(_e186));
    }
    let _e189 = mode_3;
    let _e191 = tbBit(_e189, 3f);
    let _e194 = count_1;
    if ((_e191 > 0.5f) && (_e194 > 0i)) {
        {
            let _e198 = size_1;
            tickLen = (_e198 * 0.06f);
            let _e203 = oF;
            let _e206 = count_1;
            spx = ((2f * _e203.x) / f32(_e206));
            let _e211 = oF;
            let _e214 = count_1;
            spy = ((2f * _e211.y) / f32(_e214));
            let _e218 = uv_1;
            let _e220 = oF;
            let _e223 = spx;
            let _e228 = spx;
            let _e230 = oF;
            let _e233 = oF;
            let _e236 = oF;
            txn = clamp(((floor((((_e218.x + _e220.x) / _e223) + 0.5f)) * _e228) - _e230.x), -(_e233.x), _e236.x);
            let _e240 = uv_1;
            let _e242 = oF;
            let _e245 = spy;
            let _e250 = spy;
            let _e252 = oF;
            let _e255 = oF;
            let _e258 = oF;
            tyn = clamp(((floor((((_e240.y + _e242.y) / _e245) + 0.5f)) * _e250) - _e252.y), -(_e255.y), _e258.y);
            let _e262 = d_1;
            let _e263 = uv_1;
            let _e264 = txn;
            let _e265 = oF;
            let _e268 = txn;
            let _e269 = oF;
            let _e271 = tickLen;
            let _e274 = dSeg(_e263, vec2<f32>(_e264, _e265.y), vec2<f32>(_e268, (_e269.y - _e271)));
            d_1 = min(_e262, _e274);
            let _e276 = d_1;
            let _e277 = uv_1;
            let _e278 = txn;
            let _e279 = oF;
            let _e283 = txn;
            let _e284 = oF;
            let _e287 = tickLen;
            let _e290 = dSeg(_e277, vec2<f32>(_e278, -(_e279.y)), vec2<f32>(_e283, (-(_e284.y) + _e287)));
            d_1 = min(_e276, _e290);
            let _e292 = d_1;
            let _e293 = uv_1;
            let _e294 = oF;
            let _e296 = tyn;
            let _e298 = oF;
            let _e300 = tickLen;
            let _e302 = tyn;
            let _e304 = dSeg(_e293, vec2<f32>(_e294.x, _e296), vec2<f32>((_e298.x - _e300), _e302));
            d_1 = min(_e292, _e304);
            let _e306 = d_1;
            let _e307 = uv_1;
            let _e308 = oF;
            let _e311 = tyn;
            let _e313 = oF;
            let _e316 = tickLen;
            let _e318 = tyn;
            let _e320 = dSeg(_e307, vec2<f32>(-(_e308.x), _e311), vec2<f32>((-(_e313.x) + _e316), _e318));
            d_1 = min(_e306, _e320);
        }
    }
    let _e322 = mode_3;
    let _e324 = tbBit(_e322, 2f);
    let _e327 = cornerStyle_1;
    if ((_e324 > 0.5f) && (_e327 != 0i)) {
        {
            let _e331 = size_1;
            Lc = (_e331 * 0.14f);
            let _e335 = size_1;
            gap = (_e335 * 0.05f);
            loop {
                let _e341 = sxi;
                if !((_e341 < 2i)) {
                    break;
                }
                {
                    syi = 0i;
                    loop {
                        let _e350 = syi;
                        if !((_e350 < 2i)) {
                            break;
                        }
                        {
                            let _e357 = sxi;
                            if (_e357 == 0i) {
                                local_1 = -1f;
                            } else {
                                local_1 = 1f;
                            }
                            let _e364 = local_1;
                            sx = _e364;
                            let _e366 = syi;
                            if (_e366 == 0i) {
                                local_2 = -1f;
                            } else {
                                local_2 = 1f;
                            }
                            let _e373 = local_2;
                            sy = _e373;
                            let _e375 = cornerStyle_1;
                            if (_e375 == 4i) {
                                {
                                    let _e378 = d_1;
                                    let _e379 = uv_1;
                                    let _e380 = sx;
                                    let _e381 = img;
                                    let _e383 = gap;
                                    let _e386 = sy;
                                    let _e387 = img;
                                    let _e391 = sx;
                                    let _e392 = img;
                                    let _e394 = gap;
                                    let _e396 = Lc;
                                    let _e399 = sy;
                                    let _e400 = img;
                                    let _e404 = dSeg(_e379, vec2<f32>((_e380 * (_e381.x + _e383)), (_e386 * _e387.y)), vec2<f32>((_e391 * ((_e392.x + _e394) + _e396)), (_e399 * _e400.y)));
                                    d_1 = min(_e378, _e404);
                                    let _e406 = d_1;
                                    let _e407 = uv_1;
                                    let _e408 = sx;
                                    let _e409 = img;
                                    let _e412 = sy;
                                    let _e413 = img;
                                    let _e415 = gap;
                                    let _e419 = sx;
                                    let _e420 = img;
                                    let _e423 = sy;
                                    let _e424 = img;
                                    let _e426 = gap;
                                    let _e428 = Lc;
                                    let _e432 = dSeg(_e407, vec2<f32>((_e408 * _e409.x), (_e412 * (_e413.y + _e415))), vec2<f32>((_e419 * _e420.x), (_e423 * ((_e424.y + _e426) + _e428))));
                                    d_1 = min(_e406, _e432);
                                }
                            } else {
                                {
                                    let _e434 = sx;
                                    let _e435 = iF;
                                    let _e438 = sy;
                                    let _e439 = iF;
                                    c_4 = vec2<f32>((_e434 * _e435.x), (_e438 * _e439.y));
                                    let _e444 = cornerStyle_1;
                                    if (_e444 == 3i) {
                                        {
                                            let _e447 = d_1;
                                            let _e448 = uv_1;
                                            let _e449 = c_4;
                                            let _e450 = Lc;
                                            let _e454 = c_4;
                                            let _e455 = Lc;
                                            let _e459 = dSeg(_e448, (_e449 - vec2<f32>(_e450, 0f)), (_e454 + vec2<f32>(_e455, 0f)));
                                            d_1 = min(_e447, _e459);
                                            let _e461 = d_1;
                                            let _e462 = uv_1;
                                            let _e463 = c_4;
                                            let _e465 = Lc;
                                            let _e468 = c_4;
                                            let _e470 = Lc;
                                            let _e473 = dSeg(_e462, (_e463 - vec2<f32>(0f, _e465)), (_e468 + vec2<f32>(0f, _e470)));
                                            d_1 = min(_e461, _e473);
                                        }
                                    } else {
                                        {
                                            let _e475 = cornerStyle_1;
                                            if (_e475 == 1i) {
                                                local_3 = -1f;
                                            } else {
                                                local_3 = 1f;
                                            }
                                            let _e482 = local_3;
                                            dir = _e482;
                                            let _e484 = d_1;
                                            let _e485 = uv_1;
                                            let _e486 = c_4;
                                            let _e487 = c_4;
                                            let _e488 = sx;
                                            let _e489 = dir;
                                            let _e491 = Lc;
                                            let _e496 = dSeg(_e485, _e486, (_e487 + vec2<f32>(((_e488 * _e489) * _e491), 0f)));
                                            d_1 = min(_e484, _e496);
                                            let _e498 = d_1;
                                            let _e499 = uv_1;
                                            let _e500 = c_4;
                                            let _e501 = c_4;
                                            let _e503 = sy;
                                            let _e504 = dir;
                                            let _e506 = Lc;
                                            let _e510 = dSeg(_e499, _e500, (_e501 + vec2<f32>(0f, ((_e503 * _e504) * _e506))));
                                            d_1 = min(_e498, _e510);
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e354 = syi;
                            syi = (_e354 + 1i);
                        }
                    }
                }
                continuing {
                    let _e345 = sxi;
                    sxi = (_e345 + 1i);
                }
            }
        }
    }
    let _e512 = mode_3;
    let _e514 = tbBit(_e512, 4f);
    if (_e514 > 0.5f) {
        {
            let _e517 = size_1;
            r_2 = (_e517 * 0.05f);
            let _e522 = oF;
            let _e525 = r_2;
            tC = vec2<f32>(0f, (_e522.y - (1.3f * _e525)));
            let _e530 = d_1;
            let _e531 = uv_1;
            let _e532 = tC;
            let _e535 = r_2;
            let _e536 = sdTri(-((_e531 - _e532)), _e535);
            d_1 = min(_e530, _e536);
            let _e539 = oF;
            let _e543 = r_2;
            bC = vec2<f32>(0f, (-(_e539.y) + (1.3f * _e543)));
            let _e548 = d_1;
            let _e549 = uv_1;
            let _e550 = bC;
            let _e552 = r_2;
            let _e553 = sdTri((_e549 - _e550), _e552);
            d_1 = min(_e548, _e553);
            let _e555 = oF;
            let _e558 = r_2;
            rC = vec2<f32>((_e555.x - (1.3f * _e558)), 0f);
            let _e564 = uv_1;
            let _e565 = rC;
            rq = (_e564 - _e565);
            let _e568 = d_1;
            let _e569 = rq;
            let _e571 = rq;
            let _e575 = r_2;
            let _e576 = sdTri(vec2<f32>(_e569.y, -(_e571.x)), _e575);
            d_1 = min(_e568, _e576);
            let _e578 = oF;
            let _e582 = r_2;
            lC = vec2<f32>((-(_e578.x) + (1.3f * _e582)), 0f);
            let _e588 = uv_1;
            let _e589 = lC;
            lq = (_e588 - _e589);
            let _e592 = d_1;
            let _e593 = lq;
            let _e596 = lq;
            let _e599 = r_2;
            let _e600 = sdTri(vec2<f32>(-(_e593.y), _e596.x), _e599);
            d_1 = min(_e592, _e600);
        }
    }
    let _e602 = mode_3;
    let _e604 = tbBit(_e602, 5f);
    if (_e604 > 0.5f) {
        {
            let _e607 = size_1;
            pw = (_e607 * 0.6f);
            let _e611 = size_1;
            ph = (_e611 * 0.26f);
            let _e615 = img;
            pmax = _e615;
            let _e617 = pmax;
            let _e618 = pw;
            let _e619 = ph;
            pmin = (_e617 - vec2<f32>(_e618, _e619));
            let _e623 = pmin;
            let _e624 = pmax;
            pc = ((_e623 + _e624) * 0.5f);
            let _e629 = pmax;
            let _e630 = pmin;
            phf = ((_e629 - _e630) * 0.5f);
            let _e636 = aa;
            let _e638 = aa;
            let _e639 = uv_1;
            let _e640 = pc;
            let _e641 = phf;
            let _e642 = dRect(_e639, _e640, _e641);
            panelIn = (1f - smoothstep(-(_e636), _e638, _e642));
            let _e646 = base;
            let _e647 = base;
            let _e648 = borderColor_1;
            let _e649 = mergeColor(_e647, _e648);
            let _e650 = panelIn;
            base = mix(_e646, _e649, vec4(_e650));
            let _e653 = d_1;
            let _e654 = uv_1;
            let _e655 = pc;
            let _e656 = phf;
            let _e657 = dRect(_e654, _e655, _e656);
            d_1 = min(_e653, abs(_e657));
            let _e660 = d_1;
            let _e661 = uv_1;
            let _e662 = pc;
            let _e664 = pmin;
            let _e667 = pc;
            let _e669 = pmax;
            let _e672 = dSeg(_e661, vec2<f32>(_e662.x, _e664.y), vec2<f32>(_e667.x, _e669.y));
            d_1 = min(_e660, _e672);
            let _e674 = d_1;
            let _e675 = uv_1;
            let _e676 = pmin;
            let _e678 = pc;
            let _e681 = pmax;
            let _e683 = pc;
            let _e686 = dSeg(_e675, vec2<f32>(_e676.x, _e678.y), vec2<f32>(_e681.x, _e683.y));
            d_1 = min(_e674, _e686);
        }
    }
    let _e689 = th;
    let _e690 = aa;
    let _e692 = th;
    let _e693 = aa;
    let _e695 = d_1;
    cov = (1f - smoothstep((_e689 - _e690), (_e692 + _e693), _e695));
    let _e699 = base;
    let _e700 = color1_1;
    let _e701 = _e700.xyz;
    let _e702 = color1_1;
    let _e704 = cov;
    let _e710 = mergeColor(_e699, vec4<f32>(_e701.x, _e701.y, _e701.z, (_e702.w * _e704)));
    return _e710;
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
