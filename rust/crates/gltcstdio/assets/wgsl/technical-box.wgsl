struct Params {
    U: array<vec4<f32>, 15>,
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

fn dRect(p: vec2<f32>, c: vec2<f32>, E: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var c_1: vec2<f32>;
    var E_1: vec2<f32>;

    p_1 = p;
    c_1 = c;
    E_1 = E;
    let _e12 = p_1;
    let _e14 = c_1;
    let _e18 = E_1;
    let _e21 = p_1;
    let _e23 = c_1;
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

fn technicalBox(uv: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, shapeAspectRatio: f32, mode_2: i32, cornerStyle: i32, thickness: f32, size: f32, count: i32, color1_: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var shapeAspectRatio_1: f32;
    var mode_3: i32;
    var cornerStyle_1: i32;
    var thickness_1: f32;
    var size_1: f32;
    var count_1: i32;
    var color1_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var bkg_2: vec4<f32>;
    var u: vec2<f32>;
    var modelScale: f32;
    var pixel: f32;
    var aa: f32;
    var th: f32;
    var ar: f32;
    var E_2: vec2<f32>;
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
    var local: f32;
    var sx: f32;
    var local_1: f32;
    var sy: f32;
    var c_2: vec2<f32>;
    var local_2: f32;
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
    var cov: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    outDim_1 = outDim;
    shapeAspectRatio_1 = shapeAspectRatio;
    mode_3 = mode_2;
    cornerStyle_1 = cornerStyle;
    thickness_1 = thickness;
    size_1 = size;
    count_1 = count;
    color1_1 = color1_;
    modelTransform_1 = modelTransform;
    let _e28 = uv_1;
    let _e32 = global.U[0];
    let _e35 = uv_1;
    let _e44 = textureSample(t_source, samp, ((vec2<f32>((_e28.x / _e32.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e44;
    let _e46 = modelTransform_1;
    let _e48 = uv_1;
    u = (_naga_inverse_3x3_f32(_e46) * vec3<f32>(_e48.x, _e48.y, 1f)).xy;
    let _e60 = modelTransform_1[0][0];
    let _e65 = modelTransform_1[0][1];
    modelScale = max(length(vec2<f32>(_e60, _e65)), 0.000001f);
    let _e72 = outDim_1;
    pixel = (2f / _e72.y);
    let _e76 = pixel;
    aa = (_e76 * 0.75f);
    let _e80 = thickness_1;
    let _e83 = pixel;
    th = max((_e80 * 0.01f), (_e83 * 0.5f));
    let _e88 = shapeAspectRatio_1;
    ar = max(_e88, 0.01f);
    let _e92 = ar;
    E_2 = vec2<f32>(_e92, 1f);
    let _e96 = E_2;
    let _e97 = size_1;
    iF = (_e96 - vec2((_e97 * 0.12f)));
    let _e105 = mode_3;
    let _e107 = tbBit(_e105, 0f);
    if (_e107 > 0.5f) {
        let _e110 = d_1;
        let _e111 = u;
        let _e114 = E_2;
        let _e115 = dRect(_e111, vec2(0f), _e114);
        d_1 = min(_e110, abs(_e115));
    }
    let _e118 = mode_3;
    let _e120 = tbBit(_e118, 1f);
    if (_e120 > 0.5f) {
        let _e123 = d_1;
        let _e124 = u;
        let _e127 = iF;
        let _e128 = dRect(_e124, vec2(0f), _e127);
        d_1 = min(_e123, abs(_e128));
    }
    let _e131 = mode_3;
    let _e133 = tbBit(_e131, 3f);
    let _e136 = count_1;
    if ((_e133 > 0.5f) && (_e136 > 0i)) {
        {
            let _e140 = size_1;
            tickLen = (_e140 * 0.06f);
            let _e145 = E_2;
            let _e148 = count_1;
            spx = ((2f * _e145.x) / f32(_e148));
            let _e153 = E_2;
            let _e156 = count_1;
            spy = ((2f * _e153.y) / f32(_e156));
            let _e160 = u;
            let _e162 = E_2;
            let _e165 = spx;
            let _e170 = spx;
            let _e172 = E_2;
            let _e175 = E_2;
            let _e178 = E_2;
            txn = clamp(((floor((((_e160.x + _e162.x) / _e165) + 0.5f)) * _e170) - _e172.x), -(_e175.x), _e178.x);
            let _e182 = u;
            let _e184 = E_2;
            let _e187 = spy;
            let _e192 = spy;
            let _e194 = E_2;
            let _e197 = E_2;
            let _e200 = E_2;
            tyn = clamp(((floor((((_e182.y + _e184.y) / _e187) + 0.5f)) * _e192) - _e194.y), -(_e197.y), _e200.y);
            let _e204 = d_1;
            let _e205 = u;
            let _e206 = txn;
            let _e207 = E_2;
            let _e210 = txn;
            let _e211 = E_2;
            let _e213 = tickLen;
            let _e216 = dSeg(_e205, vec2<f32>(_e206, _e207.y), vec2<f32>(_e210, (_e211.y - _e213)));
            d_1 = min(_e204, _e216);
            let _e218 = d_1;
            let _e219 = u;
            let _e220 = txn;
            let _e221 = E_2;
            let _e225 = txn;
            let _e226 = E_2;
            let _e229 = tickLen;
            let _e232 = dSeg(_e219, vec2<f32>(_e220, -(_e221.y)), vec2<f32>(_e225, (-(_e226.y) + _e229)));
            d_1 = min(_e218, _e232);
            let _e234 = d_1;
            let _e235 = u;
            let _e236 = E_2;
            let _e238 = tyn;
            let _e240 = E_2;
            let _e242 = tickLen;
            let _e244 = tyn;
            let _e246 = dSeg(_e235, vec2<f32>(_e236.x, _e238), vec2<f32>((_e240.x - _e242), _e244));
            d_1 = min(_e234, _e246);
            let _e248 = d_1;
            let _e249 = u;
            let _e250 = E_2;
            let _e253 = tyn;
            let _e255 = E_2;
            let _e258 = tickLen;
            let _e260 = tyn;
            let _e262 = dSeg(_e249, vec2<f32>(-(_e250.x), _e253), vec2<f32>((-(_e255.x) + _e258), _e260));
            d_1 = min(_e248, _e262);
        }
    }
    let _e264 = mode_3;
    let _e266 = tbBit(_e264, 2f);
    let _e269 = cornerStyle_1;
    if ((_e266 > 0.5f) && (_e269 != 0i)) {
        {
            let _e273 = size_1;
            Lc = (_e273 * 0.14f);
            let _e277 = size_1;
            gap = (_e277 * 0.05f);
            loop {
                let _e283 = sxi;
                if !((_e283 < 2i)) {
                    break;
                }
                {
                    syi = 0i;
                    loop {
                        let _e292 = syi;
                        if !((_e292 < 2i)) {
                            break;
                        }
                        {
                            let _e299 = sxi;
                            if (_e299 == 0i) {
                                local = -1f;
                            } else {
                                local = 1f;
                            }
                            let _e306 = local;
                            sx = _e306;
                            let _e308 = syi;
                            if (_e308 == 0i) {
                                local_1 = -1f;
                            } else {
                                local_1 = 1f;
                            }
                            let _e315 = local_1;
                            sy = _e315;
                            let _e317 = cornerStyle_1;
                            if (_e317 == 4i) {
                                {
                                    let _e320 = d_1;
                                    let _e321 = u;
                                    let _e322 = sx;
                                    let _e323 = E_2;
                                    let _e325 = gap;
                                    let _e328 = sy;
                                    let _e329 = E_2;
                                    let _e333 = sx;
                                    let _e334 = E_2;
                                    let _e336 = gap;
                                    let _e338 = Lc;
                                    let _e341 = sy;
                                    let _e342 = E_2;
                                    let _e346 = dSeg(_e321, vec2<f32>((_e322 * (_e323.x + _e325)), (_e328 * _e329.y)), vec2<f32>((_e333 * ((_e334.x + _e336) + _e338)), (_e341 * _e342.y)));
                                    d_1 = min(_e320, _e346);
                                    let _e348 = d_1;
                                    let _e349 = u;
                                    let _e350 = sx;
                                    let _e351 = E_2;
                                    let _e354 = sy;
                                    let _e355 = E_2;
                                    let _e357 = gap;
                                    let _e361 = sx;
                                    let _e362 = E_2;
                                    let _e365 = sy;
                                    let _e366 = E_2;
                                    let _e368 = gap;
                                    let _e370 = Lc;
                                    let _e374 = dSeg(_e349, vec2<f32>((_e350 * _e351.x), (_e354 * (_e355.y + _e357))), vec2<f32>((_e361 * _e362.x), (_e365 * ((_e366.y + _e368) + _e370))));
                                    d_1 = min(_e348, _e374);
                                }
                            } else {
                                {
                                    let _e376 = sx;
                                    let _e377 = iF;
                                    let _e380 = sy;
                                    let _e381 = iF;
                                    c_2 = vec2<f32>((_e376 * _e377.x), (_e380 * _e381.y));
                                    let _e386 = cornerStyle_1;
                                    if (_e386 == 3i) {
                                        {
                                            let _e389 = d_1;
                                            let _e390 = u;
                                            let _e391 = c_2;
                                            let _e392 = Lc;
                                            let _e396 = c_2;
                                            let _e397 = Lc;
                                            let _e401 = dSeg(_e390, (_e391 - vec2<f32>(_e392, 0f)), (_e396 + vec2<f32>(_e397, 0f)));
                                            d_1 = min(_e389, _e401);
                                            let _e403 = d_1;
                                            let _e404 = u;
                                            let _e405 = c_2;
                                            let _e407 = Lc;
                                            let _e410 = c_2;
                                            let _e412 = Lc;
                                            let _e415 = dSeg(_e404, (_e405 - vec2<f32>(0f, _e407)), (_e410 + vec2<f32>(0f, _e412)));
                                            d_1 = min(_e403, _e415);
                                        }
                                    } else {
                                        {
                                            let _e417 = cornerStyle_1;
                                            if (_e417 == 1i) {
                                                local_2 = -1f;
                                            } else {
                                                local_2 = 1f;
                                            }
                                            let _e424 = local_2;
                                            dir = _e424;
                                            let _e426 = d_1;
                                            let _e427 = u;
                                            let _e428 = c_2;
                                            let _e429 = c_2;
                                            let _e430 = sx;
                                            let _e431 = dir;
                                            let _e433 = Lc;
                                            let _e438 = dSeg(_e427, _e428, (_e429 + vec2<f32>(((_e430 * _e431) * _e433), 0f)));
                                            d_1 = min(_e426, _e438);
                                            let _e440 = d_1;
                                            let _e441 = u;
                                            let _e442 = c_2;
                                            let _e443 = c_2;
                                            let _e445 = sy;
                                            let _e446 = dir;
                                            let _e448 = Lc;
                                            let _e452 = dSeg(_e441, _e442, (_e443 + vec2<f32>(0f, ((_e445 * _e446) * _e448))));
                                            d_1 = min(_e440, _e452);
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e296 = syi;
                            syi = (_e296 + 1i);
                        }
                    }
                }
                continuing {
                    let _e287 = sxi;
                    sxi = (_e287 + 1i);
                }
            }
        }
    }
    let _e454 = mode_3;
    let _e456 = tbBit(_e454, 4f);
    if (_e456 > 0.5f) {
        {
            let _e459 = size_1;
            r_2 = (_e459 * 0.05f);
            let _e464 = E_2;
            let _e467 = r_2;
            tC = vec2<f32>(0f, (_e464.y - (1.3f * _e467)));
            let _e472 = d_1;
            let _e473 = u;
            let _e474 = tC;
            let _e477 = r_2;
            let _e478 = sdTri(-((_e473 - _e474)), _e477);
            d_1 = min(_e472, _e478);
            let _e481 = E_2;
            let _e485 = r_2;
            bC = vec2<f32>(0f, (-(_e481.y) + (1.3f * _e485)));
            let _e490 = d_1;
            let _e491 = u;
            let _e492 = bC;
            let _e494 = r_2;
            let _e495 = sdTri((_e491 - _e492), _e494);
            d_1 = min(_e490, _e495);
            let _e497 = E_2;
            let _e500 = r_2;
            rC = vec2<f32>((_e497.x - (1.3f * _e500)), 0f);
            let _e506 = u;
            let _e507 = rC;
            rq = (_e506 - _e507);
            let _e510 = d_1;
            let _e511 = rq;
            let _e513 = rq;
            let _e517 = r_2;
            let _e518 = sdTri(vec2<f32>(_e511.y, -(_e513.x)), _e517);
            d_1 = min(_e510, _e518);
            let _e520 = E_2;
            let _e524 = r_2;
            lC = vec2<f32>((-(_e520.x) + (1.3f * _e524)), 0f);
            let _e530 = u;
            let _e531 = lC;
            lq = (_e530 - _e531);
            let _e534 = d_1;
            let _e535 = lq;
            let _e538 = lq;
            let _e541 = r_2;
            let _e542 = sdTri(vec2<f32>(-(_e535.y), _e538.x), _e541);
            d_1 = min(_e534, _e542);
        }
    }
    let _e544 = mode_3;
    let _e546 = tbBit(_e544, 5f);
    if (_e546 > 0.5f) {
        {
            let _e549 = size_1;
            pw = (_e549 * 0.6f);
            let _e553 = size_1;
            ph = (_e553 * 0.26f);
            let _e557 = iF;
            pmax = _e557;
            let _e559 = pmax;
            let _e560 = pw;
            let _e561 = ph;
            pmin = (_e559 - vec2<f32>(_e560, _e561));
            let _e565 = pmin;
            let _e566 = pmax;
            pc = ((_e565 + _e566) * 0.5f);
            let _e571 = pmax;
            let _e572 = pmin;
            phf = ((_e571 - _e572) * 0.5f);
            let _e577 = d_1;
            let _e578 = u;
            let _e579 = pc;
            let _e580 = phf;
            let _e581 = dRect(_e578, _e579, _e580);
            d_1 = min(_e577, abs(_e581));
            let _e584 = d_1;
            let _e585 = u;
            let _e586 = pc;
            let _e588 = pmin;
            let _e591 = pc;
            let _e593 = pmax;
            let _e596 = dSeg(_e585, vec2<f32>(_e586.x, _e588.y), vec2<f32>(_e591.x, _e593.y));
            d_1 = min(_e584, _e596);
            let _e598 = d_1;
            let _e599 = u;
            let _e600 = pmin;
            let _e602 = pc;
            let _e605 = pmax;
            let _e607 = pc;
            let _e610 = dSeg(_e599, vec2<f32>(_e600.x, _e602.y), vec2<f32>(_e605.x, _e607.y));
            d_1 = min(_e598, _e610);
        }
    }
    let _e613 = th;
    let _e614 = aa;
    let _e616 = th;
    let _e617 = aa;
    let _e619 = d_1;
    let _e620 = modelScale;
    cov = (1f - smoothstep((_e613 - _e614), (_e616 + _e617), (_e619 * _e620)));
    let _e625 = cov;
    if (_e625 <= 0f) {
        let _e628 = bkg_2;
        return _e628;
    }
    let _e629 = bkg_2;
    let _e630 = color1_1;
    let _e631 = _e630.xyz;
    let _e632 = color1_1;
    let _e634 = cov;
    let _e640 = mergeColor(_e629, vec4<f32>(_e631.x, _e631.y, _e631.z, (_e632.w * _e634)));
    return _e640;
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
    let _e97 = global.U[11];
    let _e100 = global.U[12];
    let _e101 = _e100.xyz;
    let _e104 = global.U[13];
    let _e105 = _e104.xyz;
    let _e108 = global.U[14];
    let _e109 = _e108.xyz;
    let _e123 = technicalBox((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, i32(_e74.x), i32(_e79.x), _e84.x, _e88.x, i32(_e92.x), _e97, mat3x3<f32>(vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z)));
    fragColor = _e123;
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
