struct Params {
    U: array<vec4<f32>, 22>,
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

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local = max(_e25.x, _e27.y);
    }
    let _e31 = local;
    return _e31;
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

fn labelFrame(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>, margin: f32, paperColor: vec4<f32>, inkColor: vec4<f32>, markLength: f32, thickness: f32, panelAspect: f32, panelOutline: f32, mode: i32, barcodeCount: i32, barcodeSeed: f32, panelTransform: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var margin_1: f32;
    var paperColor_1: vec4<f32>;
    var inkColor_1: vec4<f32>;
    var markLength_1: f32;
    var thickness_1: f32;
    var panelAspect_1: f32;
    var panelOutline_1: f32;
    var mode_1: i32;
    var barcodeCount_1: i32;
    var barcodeSeed_1: f32;
    var panelTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var gar: f32;
    var ratio: f32;
    var borderSize: f32;
    var newBounds: vec2<f32>;
    var threshold: vec2<f32>;
    var aa: f32;
    var th: f32;
    var v: vec2<f32>;
    var inside: bool;
    var local_1: vec4<f32>;
    var col: vec4<f32>;
    var outer: vec2<f32>;
    var vtx: vec2<f32>;
    var mBorder: i32;
    var hasVText: i32;
    var dB: f32 = 1000000000f;
    var bw: f32;
    var sx: i32 = -1i;
    var sy: i32;
    var c_2: vec2<f32>;
    var bcov: f32;
    var textC: vec2<f32>;
    var s: f32;
    var tHalf: f32;
    var bcH: f32;
    var g: f32;
    var m_2: f32;
    var panelHalfW: f32;
    var bcCenterY: f32;
    var panelBottom: f32;
    var panelTop: f32;
    var panelC: vec2<f32>;
    var panelHalfH: f32;
    var dPanel: f32;
    var panelLvl: i32;
    var local_2: f32;
    var local_3: f32;
    var local_4: f32;
    var lvlMult: f32;
    var ol: f32;
    var bcCenter: vec2<f32>;
    var bcHalfW: f32;
    var N: f32;
    var dBar: f32 = 1000000000f;
    var i: i32 = 0i;
    var rnd: f32;
    var local_5: f32;
    var w: f32;
    var bx: f32;
    var bq: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    margin_1 = margin;
    paperColor_1 = paperColor;
    inkColor_1 = inkColor;
    markLength_1 = markLength;
    thickness_1 = thickness;
    panelAspect_1 = panelAspect;
    panelOutline_1 = panelOutline;
    mode_1 = mode;
    barcodeCount_1 = barcodeCount;
    barcodeSeed_1 = barcodeSeed;
    panelTransform_1 = panelTransform;
    modelTransform_1 = modelTransform;
    let _e38 = outDim_1;
    let _e40 = outDim_1;
    gar = (_e38.x / _e40.y);
    let _e44 = sourceDim_1;
    let _e46 = sourceDim_1;
    ratio = (_e44.x / _e46.y);
    let _e50 = margin_1;
    let _e54 = ratio;
    borderSize = ((_e50 * 2f) * min(1f, _e54));
    let _e58 = ratio;
    let _e61 = borderSize;
    newBounds = (vec2<f32>(_e58, 1f) + vec2(_e61));
    let _e65 = gar;
    let _e66 = ratio;
    let _e68 = newBounds;
    let _e72 = newBounds;
    threshold = vec2<f32>(((_e65 * _e66) / _e68.x), (1f / _e72.y));
    let _e78 = outDim_1;
    aa = (1.5f / _e78.y);
    let _e82 = thickness_1;
    th = (_e82 / 20f);
    let _e86 = modelTransform_1;
    let _e88 = uv_1;
    let _e89 = tf(_naga_inverse_3x3_f32(_e86), _e88);
    v = _e89;
    let _e91 = uv_1;
    let _e92 = threshold;
    let _e93 = sdRectangle(_e91, _e92);
    inside = (_e93 < 0f);
    let _e97 = inside;
    if _e97 {
        let _e98 = v;
        let _e102 = global.U[0];
        let _e105 = v;
        let _e114 = _mirror_wrap(((vec2<f32>((_e98.x / _e102.x), _e105.y) / vec2(2f)) + vec2(0.5f)));
        let _e115 = textureSample(t_source, samp, _e114);
        local_1 = _e115;
    } else {
        let _e116 = v;
        let _e120 = global.U[0];
        let _e123 = v;
        let _e132 = _mirror_wrap(((vec2<f32>((_e116.x / _e120.x), _e123.y) / vec2(2f)) + vec2(0.5f)));
        let _e133 = textureSample(t_source, samp, _e132);
        let _e134 = paperColor_1;
        let _e135 = mergeColor(_e133, _e134);
        local_1 = _e135;
    }
    let _e137 = local_1;
    col = _e137;
    let _e139 = gar;
    outer = vec2<f32>(_e139, 1f);
    let _e143 = threshold;
    let _e145 = outer;
    let _e146 = threshold;
    vtx = (_e143 + (0.5f * (_e145 - _e146)));
    let _e151 = mode_1;
    mBorder = ((_e151 >> 3u) & 3i);
    let _e158 = mode_1;
    hasVText = ((_e158 >> 2u) & 1i);
    let _e167 = th;
    bw = _e167;
    let _e169 = mBorder;
    if (_e169 == 0i) {
        {
            loop {
                let _e175 = sx;
                if !((_e175 <= 1i)) {
                    break;
                }
                {
                    sy = -1i;
                    loop {
                        let _e185 = sy;
                        if !((_e185 <= 1i)) {
                            break;
                        }
                        {
                            let _e192 = sx;
                            let _e194 = vtx;
                            let _e197 = sy;
                            let _e199 = vtx;
                            c_2 = vec2<f32>((f32(_e192) * _e194.x), (f32(_e197) * _e199.y));
                            let _e204 = dB;
                            let _e205 = uv_1;
                            let _e206 = c_2;
                            let _e207 = c_2;
                            let _e208 = sx;
                            let _e210 = markLength_1;
                            let _e215 = sdSegment(_e205, _e206, (_e207 - vec2<f32>((f32(_e208) * _e210), 0f)));
                            dB = min(_e204, _e215);
                            let _e217 = dB;
                            let _e218 = uv_1;
                            let _e219 = c_2;
                            let _e220 = c_2;
                            let _e222 = sy;
                            let _e224 = markLength_1;
                            let _e228 = sdSegment(_e218, _e219, (_e220 - vec2<f32>(0f, (f32(_e222) * _e224))));
                            dB = min(_e217, _e228);
                        }
                        continuing {
                            let _e189 = sy;
                            sy = (_e189 + 2i);
                        }
                    }
                }
                continuing {
                    let _e179 = sx;
                    sx = (_e179 + 2i);
                }
            }
        }
    } else {
        {
            let _e230 = mBorder;
            if (_e230 == 2i) {
                let _e233 = th;
                bw = (_e233 * 3f);
            }
            let _e236 = dB;
            let _e237 = uv_1;
            let _e238 = vtx;
            let _e241 = vtx;
            let _e245 = vtx;
            let _e247 = vtx;
            let _e251 = sdSegment(_e237, vec2<f32>(-(_e238.x), -(_e241.y)), vec2<f32>(_e245.x, -(_e247.y)));
            dB = min(_e236, _e251);
            let _e253 = dB;
            let _e254 = uv_1;
            let _e255 = vtx;
            let _e258 = vtx;
            let _e261 = vtx;
            let _e263 = vtx;
            let _e266 = sdSegment(_e254, vec2<f32>(-(_e255.x), _e258.y), vec2<f32>(_e261.x, _e263.y));
            dB = min(_e253, _e266);
            let _e268 = dB;
            let _e269 = uv_1;
            let _e270 = vtx;
            let _e272 = vtx;
            let _e276 = vtx;
            let _e278 = vtx;
            let _e281 = sdSegment(_e269, vec2<f32>(_e270.x, -(_e272.y)), vec2<f32>(_e276.x, _e278.y));
            dB = min(_e268, _e281);
            let _e283 = hasVText;
            if (_e283 == 1i) {
                {
                    let _e286 = dB;
                    let _e287 = uv_1;
                    let _e288 = vtx;
                    let _e291 = vtx;
                    let _e295 = vtx;
                    let _e298 = vtx;
                    let _e304 = sdSegment(_e287, vec2<f32>(-(_e288.x), -(_e291.y)), vec2<f32>(-(_e295.x), (-(_e298.y) + 0.05f)));
                    dB = min(_e286, _e304);
                    let _e306 = dB;
                    let _e307 = uv_1;
                    let _e308 = vtx;
                    let _e311 = vtx;
                    let _e317 = vtx;
                    let _e320 = vtx;
                    let _e323 = sdSegment(_e307, vec2<f32>(-(_e308.x), (-(_e311.y) + 0.45f)), vec2<f32>(-(_e317.x), _e320.y));
                    dB = min(_e306, _e323);
                }
            } else {
                {
                    let _e325 = dB;
                    let _e326 = uv_1;
                    let _e327 = vtx;
                    let _e330 = vtx;
                    let _e334 = vtx;
                    let _e337 = vtx;
                    let _e340 = sdSegment(_e326, vec2<f32>(-(_e327.x), -(_e330.y)), vec2<f32>(-(_e334.x), _e337.y));
                    dB = min(_e325, _e340);
                }
            }
        }
    }
    let _e343 = bw;
    let _e344 = aa;
    let _e346 = bw;
    let _e347 = aa;
    let _e349 = dB;
    bcov = (1f - smoothstep((_e343 - _e344), (_e346 + _e347), _e349));
    let _e353 = mBorder;
    if (_e353 == 3i) {
        {
            let _e356 = bcov;
            let _e358 = th;
            let _e359 = aa;
            let _e361 = th;
            let _e362 = aa;
            let _e364 = uv_1;
            let _e365 = vtx;
            let _e367 = th;
            let _e371 = sdRectangle(_e364, (_e365 - vec2((5f * _e367))));
            bcov = max(_e356, (1f - smoothstep((_e358 - _e359), (_e361 + _e362), abs(_e371))));
        }
    }
    let _e376 = col;
    let _e377 = inkColor_1;
    let _e378 = _e377.xyz;
    let _e379 = inkColor_1;
    let _e381 = bcov;
    let _e387 = mergeColor(_e376, vec4<f32>(_e378.x, _e378.y, _e378.z, (_e379.w * _e381)));
    col = _e387;
    let _e392 = panelTransform_1[2][0];
    let _e397 = panelTransform_1[2][1];
    textC = vec2<f32>(_e392, _e397);
    let _e404 = panelTransform_1[0][0];
    let _e409 = panelTransform_1[0][1];
    s = length(vec2<f32>(_e404, _e409));
    let _e414 = s;
    tHalf = (0.1f * _e414);
    let _e418 = s;
    bcH = (0.16f * _e418);
    let _e422 = s;
    g = (0.03f * _e422);
    let _e426 = s;
    m_2 = (0.07f * _e426);
    let _e429 = s;
    let _e432 = panelAspect_1;
    panelHalfW = ((_e429 * 0.5f) * _e432);
    let _e435 = textC;
    let _e437 = tHalf;
    let _e439 = g;
    let _e441 = bcH;
    bcCenterY = (((_e435.y - _e437) - _e439) - _e441);
    let _e444 = textC;
    let _e446 = tHalf;
    let _e448 = m_2;
    panelBottom = ((_e444.y + _e446) + _e448);
    let _e451 = bcCenterY;
    let _e452 = bcH;
    let _e454 = m_2;
    panelTop = ((_e451 - _e452) - _e454);
    let _e457 = textC;
    let _e460 = panelTop;
    let _e461 = panelBottom;
    panelC = vec2<f32>(_e457.x, (0.5f * (_e460 + _e461)));
    let _e467 = panelBottom;
    let _e468 = panelTop;
    panelHalfH = (0.5f * (_e467 - _e468));
    let _e472 = uv_1;
    let _e473 = panelC;
    let _e475 = panelHalfW;
    let _e476 = panelHalfH;
    let _e478 = sdRectangle((_e472 - _e473), vec2<f32>(_e475, _e476));
    dPanel = _e478;
    let _e480 = col;
    let _e481 = paperColor_1;
    let _e482 = _e481.xyz;
    let _e483 = paperColor_1;
    let _e486 = aa;
    let _e488 = aa;
    let _e489 = dPanel;
    let _e497 = mergeColor(_e480, vec4<f32>(_e482.x, _e482.y, _e482.z, (_e483.w * (1f - smoothstep(-(_e486), _e488, _e489)))));
    col = _e497;
    let _e498 = mode_1;
    panelLvl = (_e498 & 3i);
    let _e502 = panelLvl;
    if (_e502 == 0i) {
        local_4 = 0f;
    } else {
        let _e506 = panelLvl;
        if (_e506 == 1i) {
            local_3 = 0.5f;
        } else {
            let _e510 = panelLvl;
            if (_e510 == 2i) {
                local_2 = 1f;
            } else {
                local_2 = 5f;
            }
            let _e516 = local_2;
            local_3 = _e516;
        }
        let _e518 = local_3;
        local_4 = _e518;
    }
    let _e520 = local_4;
    lvlMult = _e520;
    let _e522 = panelOutline_1;
    let _e525 = lvlMult;
    ol = ((_e522 / 20f) * _e525);
    let _e528 = ol;
    if (_e528 > 0f) {
        let _e531 = col;
        let _e532 = inkColor_1;
        let _e533 = _e532.xyz;
        let _e534 = inkColor_1;
        let _e537 = ol;
        let _e538 = aa;
        let _e540 = ol;
        let _e541 = aa;
        let _e543 = dPanel;
        let _e552 = mergeColor(_e531, vec4<f32>(_e533.x, _e533.y, _e533.z, (_e534.w * (1f - smoothstep((_e537 - _e538), (_e540 + _e541), abs(_e543))))));
        col = _e552;
    }
    let _e553 = textC;
    let _e555 = bcCenterY;
    bcCenter = vec2<f32>(_e553.x, _e555);
    let _e558 = panelHalfW;
    bcHalfW = (_e558 * 0.85f);
    let _e562 = uv_1;
    let _e564 = textC;
    let _e568 = panelHalfW;
    let _e570 = uv_1;
    let _e572 = bcCenterY;
    let _e575 = bcH;
    if ((abs((_e562.x - _e564.x)) < _e568) && (abs((_e570.y - _e572)) < (_e575 * 1.6f))) {
        {
            let _e580 = barcodeCount_1;
            N = f32(_e580);
            loop {
                let _e587 = i;
                if !((_e587 < 40i)) {
                    break;
                }
                {
                    let _e594 = i;
                    let _e595 = barcodeCount_1;
                    if (_e594 >= _e595) {
                        break;
                    }
                    let _e597 = i;
                    let _e599 = barcodeSeed_1;
                    rnd = fract((sin(((f32(_e597) + _e599) * 12.9898f)) * 43758.547f));
                    let _e608 = rnd;
                    if (_e608 < 0.5f) {
                        local_5 = 1f;
                    } else {
                        local_5 = 2f;
                    }
                    let _e614 = local_5;
                    w = _e614;
                    let _e616 = bcHalfW;
                    let _e618 = i;
                    let _e622 = N;
                    let _e626 = bcHalfW;
                    bx = (-(_e616) + ((((f32(_e618) + 0.5f) / _e622) * 2f) * _e626));
                    let _e630 = uv_1;
                    let _e631 = bcCenter;
                    let _e632 = bx;
                    bq = (_e630 - (_e631 + vec2<f32>(_e632, 0f)));
                    let _e638 = dBar;
                    let _e639 = bq;
                    let _e640 = w;
                    let _e641 = th;
                    let _e645 = bcH;
                    let _e647 = sdRectangle(_e639, vec2<f32>(((_e640 * _e641) * 0.9f), _e645));
                    dBar = min(_e638, _e647);
                }
                continuing {
                    let _e591 = i;
                    i = (_e591 + 1i);
                }
            }
            let _e649 = col;
            let _e650 = inkColor_1;
            let _e651 = _e650.xyz;
            let _e652 = inkColor_1;
            let _e655 = aa;
            let _e657 = aa;
            let _e658 = dBar;
            let _e666 = mergeColor(_e649, vec4<f32>(_e651.x, _e651.y, _e651.z, (_e652.w * (1f - smoothstep(-(_e655), _e657, _e658)))));
            col = _e666;
        }
    }
    let _e667 = col;
    return _e667;
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
    let _e78 = global.U[7];
    let _e81 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e100 = global.U[13];
    let _e105 = global.U[14];
    let _e110 = global.U[15];
    let _e114 = global.U[16];
    let _e115 = _e114.xyz;
    let _e118 = global.U[17];
    let _e119 = _e118.xyz;
    let _e122 = global.U[18];
    let _e123 = _e122.xyz;
    let _e139 = global.U[19];
    let _e140 = _e139.xyz;
    let _e143 = global.U[20];
    let _e144 = _e143.xyz;
    let _e147 = global.U[21];
    let _e148 = _e147.xyz;
    let _e162 = labelFrame((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.xy, _e74.x, _e78, _e81, _e84.x, _e88.x, _e92.x, _e96.x, i32(_e100.x), i32(_e105.x), _e110.x, mat3x3<f32>(vec3<f32>(_e115.x, _e115.y, _e115.z), vec3<f32>(_e119.x, _e119.y, _e119.z), vec3<f32>(_e123.x, _e123.y, _e123.z)), mat3x3<f32>(vec3<f32>(_e140.x, _e140.y, _e140.z), vec3<f32>(_e144.x, _e144.y, _e144.z), vec3<f32>(_e148.x, _e148.y, _e148.z)));
    fragColor = _e162;
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
