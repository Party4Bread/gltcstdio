struct Params {
    U: array<vec4<f32>, 16>,
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
var t_source1_: texture_2d<f32>;
@group(0) @binding(4) 
var t_source2_: texture_2d<f32>;
@group(0) @binding(5) 
var t_source3_: texture_2d<f32>;

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e11 = v_1;
    x = fract((sin(dot(_e11.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e22 = x;
    let _e23 = v_1;
    y = fract((sin(dot(vec2<f32>(_e22, _e23.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e35 = x;
    let _e36 = y;
    return vec2<f32>(_e35, _e36);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e14 = noise_1;
    phase = acos(((2f * _e14) - 1f));
    let _e20 = noise_1;
    freq = (fract((_e20 * 16f)) + 0.5f);
    let _e28 = phase;
    let _e29 = freq;
    let _e30 = k_1;
    return ((1f + cos((_e28 + (_e29 * _e30)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e13 = noise_3;
    let _e15 = k_3;
    let _e16 = varyNoiseSmoothly(_e13.x, _e15);
    let _e17 = noise_3;
    let _e19 = k_3;
    let _e20 = varyNoiseSmoothly(_e17.y, _e19);
    return vec2<f32>(_e16, _e20);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e13 = co_1;
    let _e14 = rand2_(_e13);
    let _e15 = seed_1;
    let _e16 = varyVec2NoiseSmoothly(_e14, _e15);
    return (_e16 - vec2(0.5f));
}

fn withBias(x_1: f32, b: f32) -> f32 {
    var x_2: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_2 = x_1;
    b_1 = b;
    let _e13 = b_1;
    s = sign(_e13);
    let _e16 = b_1;
    ab = abs(_e16);
    let _e19 = x_2;
    let _e23 = s;
    let _e25 = ab;
    return (pow((_e19 + 0.5f), pow(2f, (-(_e23) * _e25))) - 0.5f);
}

fn dichotomicTiles(uv: vec2<f32>, outPos: vec2<f32>, source1Dim: vec2<f32>, source2Dim: vec2<f32>, source3Dim: vec2<f32>, variability: f32, randomSeed: f32, colorBkg: vec4<f32>, color: vec4<f32>, thickness: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source1Dim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var source3Dim_1: vec2<f32>;
    var variability_1: f32;
    var randomSeed_1: f32;
    var colorBkg_1: vec4<f32>;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var ratio: f32;
    var pixel: f32;
    var biasBase: vec2<f32>;
    var scale: f32;
    var p: vec2<f32>;
    var regularity: f32;
    var rect: vec4<f32>;
    var splits: vec2<f32> = vec2<f32>(0f, 0f);
    var horSplit: bool = true;
    var bias: vec2<f32>;
    var sPos: f32 = 0f;
    var sscale: f32 = 0.5f;
    var inverter: f32 = 0f;
    var i: f32 = 0f;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var posVar: f32;
    var Y: f32;
    var X: f32;
    var cw: f32;
    var ch: f32;
    var r: f32;
    var k_4: i32;
    var local: vec2<f32>;
    var local_1: vec2<f32>;
    var dimK: vec2<f32>;
    var a: f32;
    var nH: f32;
    var horizontal: bool;
    var local_2: i32;
    var n: i32;
    var u: f32 = 0f;
    var v_2: f32 = 0f;
    var inside: bool;
    var tileW: f32;
    var rowW: f32;
    var startX: f32;
    var lx: f32;
    var idx: f32;
    var tileH: f32;
    var colH: f32;
    var startY: f32;
    var ly: f32;
    var idx_1: f32;
    var border: bool = false;
    var t: f32;
    var X_1: vec2<f32>;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source1Dim_1 = source1Dim;
    source2Dim_1 = source2Dim;
    source3Dim_1 = source3Dim;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    colorBkg_1 = colorBkg;
    color_1 = color;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    let _e31 = source1Dim_1;
    let _e33 = source1Dim_1;
    ratio = (_e31.x / _e33.y);
    let _e38 = source1Dim_1;
    pixel = (2f / _e38.y);
    let _e42 = modelTransform_1;
    biasBase = (_e42 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e55 = modelTransform_1[0][0];
    let _e60 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e55, _e60)));
    let _e65 = uv_1;
    p = _e65;
    let _e68 = variability_1;
    regularity = (1f - _e68);
    let _e71 = ratio;
    let _e75 = ratio;
    rect = vec4<f32>(-(_e71), -1f, _e75, 1f);
    let _e85 = biasBase;
    bias = _e85;
    loop {
        let _e95 = i;
        let _e96 = sPos;
        let _e98 = scale;
        if !(((_e95 + _e96) < _e98)) {
            break;
        }
        {
            let _e104 = splits;
            let _e105 = randomSeed_1;
            let _e108 = rand2relSeeded(_e104, (_e105 + 122.1f));
            rnd = _e108;
            let _e110 = rect;
            let _e112 = rect;
            size = (_e110.zw - _e112.xy);
            let _e116 = size;
            let _e118 = pixel;
            let _e120 = size;
            let _e122 = pixel;
            if ((_e116.x < _e118) || (_e120.y < _e122)) {
                break;
            }
            let _e125 = rnd;
            let _e129 = regularity;
            if ((_e125.x + 0.5f) < (_e129 * 2f)) {
                let _e133 = size;
                let _e135 = size;
                horSplit = (_e133.y > _e135.x);
            }
            let _e140 = regularity;
            posVar = (1f - max(0f, ((_e140 * 2f) - 1f)));
            let _e148 = horSplit;
            if _e148 {
                {
                    let _e149 = rect;
                    let _e151 = rect;
                    let _e153 = posVar;
                    let _e154 = rnd;
                    let _e156 = bias;
                    let _e158 = withBias(_e154.y, _e156.y);
                    Y = mix(_e149.y, _e151.w, ((_e153 * _e158) + 0.5f));
                    let _e164 = p;
                    let _e166 = Y;
                    if (_e164.y < _e166) {
                        {
                            let _e169 = Y;
                            rect.w = _e169;
                            let _e171 = splits;
                            splits.y = (_e171.y + 1f);
                            let _e175 = sPos;
                            let _e176 = inverter;
                            let _e177 = sscale;
                            sPos = (_e175 + (_e176 * _e177));
                        }
                    } else {
                        {
                            let _e181 = Y;
                            rect.y = _e181;
                            let _e183 = splits;
                            splits.y = (_e183.y + 100f);
                            let _e187 = sPos;
                            let _e189 = inverter;
                            let _e191 = sscale;
                            sPos = (_e187 + ((1f - _e189) * _e191));
                        }
                    }
                }
            } else {
                {
                    let _e194 = rect;
                    let _e196 = rect;
                    let _e198 = posVar;
                    let _e199 = rnd;
                    let _e201 = bias;
                    let _e203 = withBias(_e199.x, _e201.x);
                    X = mix(_e194.x, _e196.z, ((_e198 * _e203) + 0.5f));
                    let _e209 = p;
                    let _e211 = X;
                    if (_e209.x < _e211) {
                        {
                            let _e214 = X;
                            rect.z = _e214;
                            let _e216 = splits;
                            splits.x = (_e216.x + 1f);
                            let _e220 = sPos;
                            let _e221 = inverter;
                            let _e222 = sscale;
                            sPos = (_e220 + (_e221 * _e222));
                        }
                    } else {
                        {
                            let _e226 = X;
                            rect.x = _e226;
                            let _e228 = splits;
                            splits.x = (_e228.x + 100f);
                            let _e232 = sPos;
                            let _e234 = inverter;
                            let _e236 = sscale;
                            sPos = (_e232 + ((1f - _e234) * _e236));
                        }
                    }
                }
            }
            let _e239 = horSplit;
            horSplit = !(_e239);
            let _e242 = inverter;
            inverter = (1f - _e242);
            let _e244 = sscale;
            sscale = (_e244 * 0.5f);
            let _e247 = bias;
            bias = (_e247 * 0.5f);
        }
        continuing {
            let _e101 = i;
            i = (_e101 + 1f);
        }
    }
    let _e250 = rect;
    let _e252 = rect;
    cw = (_e250.z - _e252.x);
    let _e256 = rect;
    let _e258 = rect;
    ch = (_e256.w - _e258.y);
    let _e262 = splits;
    let _e263 = randomSeed_1;
    let _e266 = rand2relSeeded(_e262, (_e263 + 55.5f));
    r = (_e266.x + 0.5f);
    let _e272 = r;
    k_4 = i32(min(2f, floor((_e272 * 3f))));
    let _e279 = k_4;
    if (_e279 == 0i) {
        let _e282 = source1Dim_1;
        local_1 = _e282;
    } else {
        let _e283 = k_4;
        if (_e283 == 1i) {
            let _e286 = source2Dim_1;
            local = _e286;
        } else {
            let _e287 = source3Dim_1;
            local = _e287;
        }
        let _e289 = local;
        local_1 = _e289;
    }
    let _e291 = local_1;
    dimK = _e291;
    let _e293 = dimK;
    let _e295 = dimK;
    a = (_e293.x / _e295.y);
    let _e299 = cw;
    let _e300 = ch;
    let _e301 = a;
    nH = (_e299 / (_e300 * _e301));
    let _e305 = nH;
    horizontal = (_e305 >= 1f);
    let _e309 = horizontal;
    if _e309 {
        let _e310 = nH;
        local_2 = i32(floor(_e310));
    } else {
        let _e314 = nH;
        local_2 = i32(floor((1f / _e314)));
    }
    let _e319 = local_2;
    n = _e319;
    let _e321 = n;
    n = max(_e321, 1i);
    let _e329 = horizontal;
    if _e329 {
        {
            let _e330 = ch;
            let _e331 = a;
            tileW = (_e330 * _e331);
            let _e334 = tileW;
            let _e335 = n;
            rowW = (_e334 * f32(_e335));
            let _e339 = rect;
            let _e341 = cw;
            let _e342 = rowW;
            startX = (_e339.x + ((_e341 - _e342) * 0.5f));
            let _e348 = p;
            let _e350 = startX;
            lx = (_e348.x - _e350);
            let _e353 = lx;
            let _e354 = tileW;
            idx = floor((_e353 / _e354));
            let _e358 = lx;
            let _e361 = lx;
            let _e362 = rowW;
            inside = ((_e358 >= 0f) && (_e361 <= _e362));
            let _e365 = lx;
            let _e366 = idx;
            let _e367 = tileW;
            let _e370 = tileW;
            u = ((_e365 - (_e366 * _e367)) / _e370);
            let _e372 = p;
            let _e374 = rect;
            let _e377 = ch;
            v_2 = ((_e372.y - _e374.y) / _e377);
        }
    } else {
        {
            let _e379 = cw;
            let _e380 = a;
            tileH = (_e379 / _e380);
            let _e383 = tileH;
            let _e384 = n;
            colH = (_e383 * f32(_e384));
            let _e388 = rect;
            let _e390 = ch;
            let _e391 = colH;
            startY = (_e388.y + ((_e390 - _e391) * 0.5f));
            let _e397 = p;
            let _e399 = startY;
            ly = (_e397.y - _e399);
            let _e402 = ly;
            let _e403 = tileH;
            idx_1 = floor((_e402 / _e403));
            let _e407 = ly;
            let _e410 = ly;
            let _e411 = colH;
            inside = ((_e407 >= 0f) && (_e410 <= _e411));
            let _e414 = p;
            let _e416 = rect;
            let _e419 = cw;
            u = ((_e414.x - _e416.x) / _e419);
            let _e421 = ly;
            let _e422 = idx_1;
            let _e423 = tileH;
            let _e426 = tileH;
            v_2 = ((_e421 - (_e422 * _e423)) / _e426);
        }
    }
    let _e430 = thickness_1;
    if (_e430 > 0f) {
        {
            let _e433 = thickness_1;
            t = (_e433 * 0.1f);
            let _e437 = p;
            let _e439 = rect;
            let _e442 = t;
            let _e444 = rect;
            let _e446 = p;
            let _e449 = t;
            let _e452 = p;
            let _e454 = rect;
            let _e457 = t;
            let _e460 = rect;
            let _e462 = p;
            let _e465 = t;
            if (((((_e437.x - _e439.x) < _e442) || ((_e444.z - _e446.x) < _e449)) || ((_e452.y - _e454.y) < _e457)) || ((_e460.w - _e462.y) < _e465)) {
                border = true;
            }
        }
    }
    let _e469 = border;
    if _e469 {
        let _e470 = color_1;
        return _e470;
    }
    let _e471 = inside;
    if !(_e471) {
        let _e473 = colorBkg_1;
        return _e473;
    }
    let _e474 = u;
    let _e479 = a;
    let _e481 = v_2;
    X_1 = vec2<f32>((((_e474 - 0.5f) * 2f) * _e479), ((_e481 - 0.5f) * 2f));
    let _e488 = k_4;
    if (_e488 == 0i) {
        let _e491 = X_1;
        let _e495 = global.U[0];
        let _e498 = X_1;
        let _e507 = textureSample(t_source1_, samp, ((vec2<f32>((_e491.x / _e495.x), _e498.y) / vec2(2f)) + vec2(0.5f)));
        local_4 = _e507;
    } else {
        let _e508 = k_4;
        if (_e508 == 1i) {
            let _e511 = X_1;
            let _e515 = global.U[0];
            let _e518 = X_1;
            let _e527 = textureSample(t_source2_, samp, ((vec2<f32>((_e511.x / _e515.x), _e518.y) / vec2(2f)) + vec2(0.5f)));
            local_3 = _e527;
        } else {
            let _e528 = X_1;
            let _e532 = global.U[0];
            let _e535 = X_1;
            let _e544 = textureSample(t_source3_, samp, ((vec2<f32>((_e528.x / _e532.x), _e535.y) / vec2(2f)) + vec2(0.5f)));
            local_3 = _e544;
        }
        let _e546 = local_3;
        local_4 = _e546;
    }
    let _e548 = local_4;
    return _e548;
}

fn main_1() {
    let _e11 = global.U[1];
    let _e12 = _e11.xyz;
    let _e15 = global.U[2];
    let _e16 = _e15.xyz;
    let _e19 = global.U[3];
    let _e20 = _e19.xyz;
    let _e35 = v_uv_1;
    let _e43 = global.U[0];
    let _e47 = (((_e35 - vec2(0.5f)) * 2f) * vec2<f32>(_e43.x, 1f));
    let _e54 = v_uv_1;
    let _e62 = global.U[0];
    let _e69 = global.U[4];
    let _e73 = global.U[5];
    let _e77 = global.U[6];
    let _e81 = global.U[8];
    let _e85 = global.U[9];
    let _e89 = global.U[10];
    let _e92 = global.U[11];
    let _e95 = global.U[12];
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e107 = global.U[15];
    let _e108 = _e107.xyz;
    let _e122 = dichotomicTiles((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z), vec3<f32>(_e20.x, _e20.y, _e20.z))) * vec3<f32>(_e47.x, _e47.y, 1f)).xy, (((_e54 - vec2(0.5f)) * 2f) * vec2<f32>(_e62.x, 1f)), _e69.xy, _e73.xy, _e77.xy, _e81.x, _e85.x, _e89, _e92, _e95.x, mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)));
    fragColor = _e122;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e19 = fragColor;
    return FragmentOutput(_e19);
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
