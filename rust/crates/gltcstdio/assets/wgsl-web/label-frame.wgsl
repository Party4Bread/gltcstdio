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
        let _e116 = textureSampleLevel(t_source, samp, _e114, 0f);
        local_1 = _e116;
    } else {
        let _e117 = v;
        let _e121 = global.U[0];
        let _e124 = v;
        let _e133 = _mirror_wrap(((vec2<f32>((_e117.x / _e121.x), _e124.y) / vec2(2f)) + vec2(0.5f)));
        let _e135 = textureSampleLevel(t_source, samp, _e133, 0f);
        let _e136 = paperColor_1;
        let _e137 = mergeColor(_e135, _e136);
        local_1 = _e137;
    }
    let _e139 = local_1;
    col = _e139;
    let _e141 = gar;
    outer = vec2<f32>(_e141, 1f);
    let _e145 = threshold;
    let _e147 = outer;
    let _e148 = threshold;
    vtx = (_e145 + (0.5f * (_e147 - _e148)));
    let _e153 = mode_1;
    mBorder = ((_e153 >> 3u) & 3i);
    let _e160 = mode_1;
    hasVText = ((_e160 >> 2u) & 1i);
    let _e169 = th;
    bw = _e169;
    let _e171 = mBorder;
    if (_e171 == 0i) {
        {
            loop {
                let _e177 = sx;
                if !((_e177 <= 1i)) {
                    break;
                }
                {
                    sy = -1i;
                    loop {
                        let _e187 = sy;
                        if !((_e187 <= 1i)) {
                            break;
                        }
                        {
                            let _e194 = sx;
                            let _e196 = vtx;
                            let _e199 = sy;
                            let _e201 = vtx;
                            c_2 = vec2<f32>((f32(_e194) * _e196.x), (f32(_e199) * _e201.y));
                            let _e206 = dB;
                            let _e207 = uv_1;
                            let _e208 = c_2;
                            let _e209 = c_2;
                            let _e210 = sx;
                            let _e212 = markLength_1;
                            let _e217 = sdSegment(_e207, _e208, (_e209 - vec2<f32>((f32(_e210) * _e212), 0f)));
                            dB = min(_e206, _e217);
                            let _e219 = dB;
                            let _e220 = uv_1;
                            let _e221 = c_2;
                            let _e222 = c_2;
                            let _e224 = sy;
                            let _e226 = markLength_1;
                            let _e230 = sdSegment(_e220, _e221, (_e222 - vec2<f32>(0f, (f32(_e224) * _e226))));
                            dB = min(_e219, _e230);
                        }
                        continuing {
                            let _e191 = sy;
                            sy = (_e191 + 2i);
                        }
                    }
                }
                continuing {
                    let _e181 = sx;
                    sx = (_e181 + 2i);
                }
            }
        }
    } else {
        {
            let _e232 = mBorder;
            if (_e232 == 2i) {
                let _e235 = th;
                bw = (_e235 * 3f);
            }
            let _e238 = dB;
            let _e239 = uv_1;
            let _e240 = vtx;
            let _e243 = vtx;
            let _e247 = vtx;
            let _e249 = vtx;
            let _e253 = sdSegment(_e239, vec2<f32>(-(_e240.x), -(_e243.y)), vec2<f32>(_e247.x, -(_e249.y)));
            dB = min(_e238, _e253);
            let _e255 = dB;
            let _e256 = uv_1;
            let _e257 = vtx;
            let _e260 = vtx;
            let _e263 = vtx;
            let _e265 = vtx;
            let _e268 = sdSegment(_e256, vec2<f32>(-(_e257.x), _e260.y), vec2<f32>(_e263.x, _e265.y));
            dB = min(_e255, _e268);
            let _e270 = dB;
            let _e271 = uv_1;
            let _e272 = vtx;
            let _e274 = vtx;
            let _e278 = vtx;
            let _e280 = vtx;
            let _e283 = sdSegment(_e271, vec2<f32>(_e272.x, -(_e274.y)), vec2<f32>(_e278.x, _e280.y));
            dB = min(_e270, _e283);
            let _e285 = hasVText;
            if (_e285 == 1i) {
                {
                    let _e288 = dB;
                    let _e289 = uv_1;
                    let _e290 = vtx;
                    let _e293 = vtx;
                    let _e297 = vtx;
                    let _e300 = vtx;
                    let _e306 = sdSegment(_e289, vec2<f32>(-(_e290.x), -(_e293.y)), vec2<f32>(-(_e297.x), (-(_e300.y) + 0.05f)));
                    dB = min(_e288, _e306);
                    let _e308 = dB;
                    let _e309 = uv_1;
                    let _e310 = vtx;
                    let _e313 = vtx;
                    let _e319 = vtx;
                    let _e322 = vtx;
                    let _e325 = sdSegment(_e309, vec2<f32>(-(_e310.x), (-(_e313.y) + 0.45f)), vec2<f32>(-(_e319.x), _e322.y));
                    dB = min(_e308, _e325);
                }
            } else {
                {
                    let _e327 = dB;
                    let _e328 = uv_1;
                    let _e329 = vtx;
                    let _e332 = vtx;
                    let _e336 = vtx;
                    let _e339 = vtx;
                    let _e342 = sdSegment(_e328, vec2<f32>(-(_e329.x), -(_e332.y)), vec2<f32>(-(_e336.x), _e339.y));
                    dB = min(_e327, _e342);
                }
            }
        }
    }
    let _e345 = bw;
    let _e346 = aa;
    let _e348 = bw;
    let _e349 = aa;
    let _e351 = dB;
    bcov = (1f - smoothstep((_e345 - _e346), (_e348 + _e349), _e351));
    let _e355 = mBorder;
    if (_e355 == 3i) {
        {
            let _e358 = bcov;
            let _e360 = th;
            let _e361 = aa;
            let _e363 = th;
            let _e364 = aa;
            let _e366 = uv_1;
            let _e367 = vtx;
            let _e369 = th;
            let _e373 = sdRectangle(_e366, (_e367 - vec2((5f * _e369))));
            bcov = max(_e358, (1f - smoothstep((_e360 - _e361), (_e363 + _e364), abs(_e373))));
        }
    }
    let _e378 = col;
    let _e379 = inkColor_1;
    let _e380 = _e379.xyz;
    let _e381 = inkColor_1;
    let _e383 = bcov;
    let _e389 = mergeColor(_e378, vec4<f32>(_e380.x, _e380.y, _e380.z, (_e381.w * _e383)));
    col = _e389;
    let _e394 = panelTransform_1[2][0];
    let _e399 = panelTransform_1[2][1];
    textC = vec2<f32>(_e394, _e399);
    let _e406 = panelTransform_1[0][0];
    let _e411 = panelTransform_1[0][1];
    s = length(vec2<f32>(_e406, _e411));
    let _e416 = s;
    tHalf = (0.1f * _e416);
    let _e420 = s;
    bcH = (0.16f * _e420);
    let _e424 = s;
    g = (0.03f * _e424);
    let _e428 = s;
    m_2 = (0.07f * _e428);
    let _e431 = s;
    let _e434 = panelAspect_1;
    panelHalfW = ((_e431 * 0.5f) * _e434);
    let _e437 = textC;
    let _e439 = tHalf;
    let _e441 = g;
    let _e443 = bcH;
    bcCenterY = (((_e437.y - _e439) - _e441) - _e443);
    let _e446 = textC;
    let _e448 = tHalf;
    let _e450 = m_2;
    panelBottom = ((_e446.y + _e448) + _e450);
    let _e453 = bcCenterY;
    let _e454 = bcH;
    let _e456 = m_2;
    panelTop = ((_e453 - _e454) - _e456);
    let _e459 = textC;
    let _e462 = panelTop;
    let _e463 = panelBottom;
    panelC = vec2<f32>(_e459.x, (0.5f * (_e462 + _e463)));
    let _e469 = panelBottom;
    let _e470 = panelTop;
    panelHalfH = (0.5f * (_e469 - _e470));
    let _e474 = uv_1;
    let _e475 = panelC;
    let _e477 = panelHalfW;
    let _e478 = panelHalfH;
    let _e480 = sdRectangle((_e474 - _e475), vec2<f32>(_e477, _e478));
    dPanel = _e480;
    let _e482 = col;
    let _e483 = paperColor_1;
    let _e484 = _e483.xyz;
    let _e485 = paperColor_1;
    let _e488 = aa;
    let _e490 = aa;
    let _e491 = dPanel;
    let _e499 = mergeColor(_e482, vec4<f32>(_e484.x, _e484.y, _e484.z, (_e485.w * (1f - smoothstep(-(_e488), _e490, _e491)))));
    col = _e499;
    let _e500 = mode_1;
    panelLvl = (_e500 & 3i);
    let _e504 = panelLvl;
    if (_e504 == 0i) {
        local_4 = 0f;
    } else {
        let _e508 = panelLvl;
        if (_e508 == 1i) {
            local_3 = 0.5f;
        } else {
            let _e512 = panelLvl;
            if (_e512 == 2i) {
                local_2 = 1f;
            } else {
                local_2 = 5f;
            }
            let _e518 = local_2;
            local_3 = _e518;
        }
        let _e520 = local_3;
        local_4 = _e520;
    }
    let _e522 = local_4;
    lvlMult = _e522;
    let _e524 = panelOutline_1;
    let _e527 = lvlMult;
    ol = ((_e524 / 20f) * _e527);
    let _e530 = ol;
    if (_e530 > 0f) {
        let _e533 = col;
        let _e534 = inkColor_1;
        let _e535 = _e534.xyz;
        let _e536 = inkColor_1;
        let _e539 = ol;
        let _e540 = aa;
        let _e542 = ol;
        let _e543 = aa;
        let _e545 = dPanel;
        let _e554 = mergeColor(_e533, vec4<f32>(_e535.x, _e535.y, _e535.z, (_e536.w * (1f - smoothstep((_e539 - _e540), (_e542 + _e543), abs(_e545))))));
        col = _e554;
    }
    let _e555 = textC;
    let _e557 = bcCenterY;
    bcCenter = vec2<f32>(_e555.x, _e557);
    let _e560 = panelHalfW;
    bcHalfW = (_e560 * 0.85f);
    let _e564 = uv_1;
    let _e566 = textC;
    let _e570 = panelHalfW;
    let _e572 = uv_1;
    let _e574 = bcCenterY;
    let _e577 = bcH;
    if ((abs((_e564.x - _e566.x)) < _e570) && (abs((_e572.y - _e574)) < (_e577 * 1.6f))) {
        {
            let _e582 = barcodeCount_1;
            N = f32(_e582);
            loop {
                let _e589 = i;
                if !((_e589 < 40i)) {
                    break;
                }
                {
                    let _e596 = i;
                    let _e597 = barcodeCount_1;
                    if (_e596 >= _e597) {
                        break;
                    }
                    let _e599 = i;
                    let _e601 = barcodeSeed_1;
                    rnd = fract((sin(((f32(_e599) + _e601) * 12.9898f)) * 43758.547f));
                    let _e610 = rnd;
                    if (_e610 < 0.5f) {
                        local_5 = 1f;
                    } else {
                        local_5 = 2f;
                    }
                    let _e616 = local_5;
                    w = _e616;
                    let _e618 = bcHalfW;
                    let _e620 = i;
                    let _e624 = N;
                    let _e628 = bcHalfW;
                    bx = (-(_e618) + ((((f32(_e620) + 0.5f) / _e624) * 2f) * _e628));
                    let _e632 = uv_1;
                    let _e633 = bcCenter;
                    let _e634 = bx;
                    bq = (_e632 - (_e633 + vec2<f32>(_e634, 0f)));
                    let _e640 = dBar;
                    let _e641 = bq;
                    let _e642 = w;
                    let _e643 = th;
                    let _e647 = bcH;
                    let _e649 = sdRectangle(_e641, vec2<f32>(((_e642 * _e643) * 0.9f), _e647));
                    dBar = min(_e640, _e649);
                }
                continuing {
                    let _e593 = i;
                    i = (_e593 + 1i);
                }
            }
            let _e651 = col;
            let _e652 = inkColor_1;
            let _e653 = _e652.xyz;
            let _e654 = inkColor_1;
            let _e657 = aa;
            let _e659 = aa;
            let _e660 = dBar;
            let _e668 = mergeColor(_e651, vec4<f32>(_e653.x, _e653.y, _e653.z, (_e654.w * (1f - smoothstep(-(_e657), _e659, _e660)))));
            col = _e668;
        }
    }
    let _e669 = col;
    return _e669;
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
