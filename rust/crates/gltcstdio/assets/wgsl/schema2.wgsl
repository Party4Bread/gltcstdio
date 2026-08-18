struct Params {
    U: array<vec4<f32>, 21>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn schema2_(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, outDim: vec2<f32>, intensity: f32, insideColor: vec4<f32>, borderColor: vec4<f32>, highlightColor: vec4<f32>, thickness: f32, thicknessVar: f32, detail: i32, variability: f32, randomSeed: f32, coverage: f32, edgeJitter: f32, colorVariability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var intensity_1: f32;
    var insideColor_1: vec4<f32>;
    var borderColor_1: vec4<f32>;
    var highlightColor_1: vec4<f32>;
    var thickness_1: f32;
    var thicknessVar_1: f32;
    var detail_1: i32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var coverage_1: f32;
    var edgeJitter_1: f32;
    var colorVariability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var bg: vec4<f32>;
    var u: vec2<f32>;
    var d: f32;
    var local: f32;
    var pw: f32;
    var angle: f32;
    var xp: f32;
    var sx: f32;
    var sy: f32;
    var pos: vec2<f32>;
    var ratio: f32 = 1f;
    var pixel: f32;
    var scale: f32;
    var p: vec2<f32>;
    var rect: vec4<f32>;
    var horSplit: bool = true;
    var splits: vec2<f32> = vec2<f32>(0f, 0f);
    var sPos: f32 = 0f;
    var sscale: f32 = 0.5f;
    var inverter: f32 = 0f;
    var regularity: f32;
    var i: f32 = 0f;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var var2_: f32;
    var Y: f32;
    var X: f32;
    var cellRnd: vec2<f32>;
    var colorRnd: vec2<f32>;
    var acov: f32;
    var cellY: f32;
    var j: f32;
    var frontCoverage: f32;
    var frontJitter: f32;
    var front_2: f32;
    var evictFront: bool;
    var evictRnd: vec2<f32>;
    var squaredStrength: f32;
    var t: f32;
    var topFactor: f32;
    var evictSquared: bool;
    var frontJitter_1: f32;
    var front_3: f32;
    var cv: f32;
    var q1_: f32;
    var q2_: f32;
    var local_1: f32;
    var local_2: f32;
    var highlightFrac: f32;
    var interStrength: f32;
    var cellColor: vec4<f32>;
    var r: f32;
    var jitter: f32;
    var th: f32;
    var distX: f32;
    var distY: f32;
    var du: f32;
    var dd: f32;
    var Jr: f32;
    var Ja: f32;
    var aaX: f32;
    var aaY: f32;
    var covX: f32;
    var covY: f32;
    var borderMix: f32;
    var fg: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    intensity_1 = intensity;
    insideColor_1 = insideColor;
    borderColor_1 = borderColor;
    highlightColor_1 = highlightColor;
    thickness_1 = thickness;
    thicknessVar_1 = thicknessVar;
    detail_1 = detail;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    coverage_1 = coverage;
    edgeJitter_1 = edgeJitter;
    colorVariability_1 = colorVariability;
    modelTransform_1 = modelTransform;
    let _e40 = uv_1;
    let _e44 = global.U[0];
    let _e47 = uv_1;
    let _e56 = textureSample(t_source, samp, ((vec2<f32>((_e40.x / _e44.x), _e47.y) / vec2(2f)) + vec2(0.5f)));
    bg = _e56;
    let _e58 = modelTransform_1;
    let _e60 = uv_1;
    u = (_naga_inverse_3x3_f32(_e58) * vec3<f32>(_e60.x, _e60.y, 1f)).xy;
    let _e68 = u;
    d = length(_e68);
    let _e72 = intensity_1;
    if (_e72 > 0f) {
        let _e75 = intensity_1;
        local = (_e75 * 3f);
    } else {
        let _e78 = intensity_1;
        local = (_e78 * 0.99f);
    }
    let _e82 = local;
    pw = (1f + _e82);
    let _e85 = u;
    let _e87 = u;
    let _e89 = atan2(_e85.y, _e87.x);
    angle = (_e89 - (floor((_e89 / 6.2831855f)) * 6.2831855f));
    let _e96 = angle;
    xp = ((_e96 / 3.1415927f) - 1f);
    let _e102 = xp;
    sx = _e102;
    let _e105 = d;
    let _e108 = pw;
    sy = (1f - (pow((_e105 * 0.5f), _e108) * 2f));
    let _e114 = sx;
    let _e115 = sy;
    pos = vec2<f32>(_e114, _e115);
    let _e118 = pos;
    if (_e118.y < -1f) {
        let _e123 = bg;
        return _e123;
    }
    let _e127 = sourceDim_1;
    pixel = (2f / _e127.y);
    let _e131 = detail_1;
    scale = f32(_e131);
    let _e134 = pos;
    p = _e134;
    let _e136 = ratio;
    let _e140 = ratio;
    rect = vec4<f32>(-(_e136), -1f, _e140, 1f);
    let _e157 = variability_1;
    regularity = (1f - _e157);
    loop {
        let _e162 = i;
        let _e163 = sPos;
        let _e165 = scale;
        if !(((_e162 + _e163) < _e165)) {
            break;
        }
        {
            let _e171 = splits;
            let _e172 = randomSeed_1;
            let _e175 = rand2relSeeded(_e171, (_e172 + 122.1f));
            rnd = _e175;
            let _e177 = rect;
            let _e179 = rect;
            size = (_e177.zw - _e179.xy);
            let _e183 = size;
            let _e185 = pixel;
            let _e187 = size;
            let _e189 = pixel;
            if ((_e183.x < _e185) || (_e187.y < _e189)) {
                break;
            }
            let _e192 = rnd;
            let _e196 = regularity;
            if ((_e192.x + 0.5f) < (_e196 * 2f)) {
                let _e200 = size;
                let _e202 = size;
                horSplit = (_e200.y > _e202.x);
            }
            let _e207 = regularity;
            var2_ = (1f - max(0f, ((_e207 * 2f) - 1f)));
            let _e215 = horSplit;
            if _e215 {
                {
                    let _e216 = rect;
                    let _e218 = rect;
                    let _e220 = var2_;
                    let _e221 = rnd;
                    Y = mix(_e216.y, _e218.w, ((_e220 * _e221.y) + 0.5f));
                    let _e228 = p;
                    let _e230 = Y;
                    if (_e228.y < _e230) {
                        {
                            let _e233 = Y;
                            rect.w = _e233;
                            let _e235 = splits.y;
                            splits.y = (_e235 + 1f);
                            let _e238 = sPos;
                            let _e239 = inverter;
                            let _e240 = sscale;
                            sPos = (_e238 + (_e239 * _e240));
                        }
                    } else {
                        {
                            let _e244 = Y;
                            rect.y = _e244;
                            let _e246 = splits;
                            splits.y = (_e246.y + 100f);
                            let _e250 = sPos;
                            let _e252 = inverter;
                            let _e254 = sscale;
                            sPos = (_e250 + ((1f - _e252) * _e254));
                        }
                    }
                }
            } else {
                {
                    let _e257 = rect;
                    let _e259 = rect;
                    let _e261 = var2_;
                    let _e262 = rnd;
                    X = mix(_e257.x, _e259.z, ((_e261 * _e262.x) + 0.5f));
                    let _e269 = p;
                    let _e271 = X;
                    if (_e269.x < _e271) {
                        {
                            let _e274 = X;
                            rect.z = _e274;
                            let _e276 = splits.x;
                            splits.x = (_e276 + 1f);
                            let _e279 = sPos;
                            let _e280 = inverter;
                            let _e281 = sscale;
                            sPos = (_e279 + (_e280 * _e281));
                        }
                    } else {
                        {
                            let _e285 = X;
                            rect.x = _e285;
                            let _e287 = splits;
                            splits.x = (_e287.x + 100f);
                            let _e291 = sPos;
                            let _e293 = inverter;
                            let _e295 = sscale;
                            sPos = (_e291 + ((1f - _e293) * _e295));
                        }
                    }
                }
            }
            let _e298 = horSplit;
            horSplit = !(_e298);
            let _e301 = inverter;
            inverter = (1f - _e301);
            let _e303 = sscale;
            sscale = (_e303 * 0.5f);
        }
        continuing {
            let _e168 = i;
            i = (_e168 + 1f);
        }
    }
    let _e306 = splits;
    let _e307 = randomSeed_1;
    let _e310 = rand2relSeeded(_e306, (_e307 + 55.5f));
    cellRnd = _e310;
    let _e312 = splits;
    let _e313 = randomSeed_1;
    let _e316 = rand2relSeeded(_e312, (_e313 + 77.7f));
    colorRnd = _e316;
    let _e318 = coverage_1;
    acov = abs(_e318);
    let _e321 = rect;
    let _e323 = rect;
    cellY = ((_e321.y + _e323.w) * 0.5f);
    let _e329 = cellRnd;
    j = (_e329.x + 0.5f);
    let _e334 = coverage_1;
    if (_e334 >= 0f) {
        {
            let _e337 = coverage_1;
            frontCoverage = min((_e337 * 0.5f), 0.1f);
            let _e343 = j;
            let _e344 = j;
            let _e346 = j;
            let _e352 = edgeJitter_1;
            frontJitter = (((((_e343 * _e344) * _e346) - 0.5f) * 2f) * _e352);
            let _e357 = edgeJitter_1;
            let _e360 = edgeJitter_1;
            let _e362 = frontCoverage;
            front_2 = mix((-1f - _e357), (1f + _e360), _e362);
            let _e365 = cellY;
            let _e366 = front_2;
            let _e367 = frontJitter;
            evictFront = (_e365 < (_e366 + _e367));
            let _e371 = splits;
            let _e372 = randomSeed_1;
            let _e375 = rand2relSeeded(_e371, (_e372 + 33.3f));
            evictRnd = _e375;
            let _e377 = coverage_1;
            squaredStrength = clamp(((_e377 - 0.2f) / 0.8f), 0f, 1f);
            let _e387 = cellY;
            t = ((1f - _e387) * 0.5f);
            let _e392 = t;
            topFactor = pow(_e392, 1.5f);
            let _e396 = evictRnd;
            let _e400 = squaredStrength;
            let _e401 = topFactor;
            evictSquared = ((_e396.x + 0.5f) < (_e400 * _e401));
            let _e405 = evictFront;
            let _e406 = evictSquared;
            if (_e405 || _e406) {
                let _e408 = bg;
                return _e408;
            }
        }
    } else {
        {
            let _e409 = j;
            let _e414 = edgeJitter_1;
            frontJitter_1 = (((_e409 - 0.5f) * 2f) * _e414);
            let _e419 = edgeJitter_1;
            let _e422 = edgeJitter_1;
            let _e424 = acov;
            front_3 = mix((-1f - _e419), (1f + _e422), _e424);
            let _e427 = cellY;
            let _e428 = front_3;
            let _e429 = frontJitter_1;
            if (_e427 < (_e428 + _e429)) {
                let _e432 = bg;
                return _e432;
            }
        }
    }
    let _e433 = colorVariability_1;
    cv = _e433;
    let _e435 = colorRnd;
    q1_ = (_e435.x + 0.5f);
    let _e440 = colorRnd;
    q2_ = (_e440.y + 0.5f);
    let _e445 = cv;
    if (_e445 < 0.3f) {
        let _e448 = cv;
        local_2 = ((_e448 / 0.3f) * 0.25f);
    } else {
        let _e453 = cv;
        if (_e453 < 0.7f) {
            local_1 = 0.25f;
        } else {
            let _e459 = cv;
            local_1 = mix(0.25f, 1f, ((_e459 - 0.7f) / 0.3f));
        }
        let _e466 = local_1;
        local_2 = _e466;
    }
    let _e468 = local_2;
    highlightFrac = _e468;
    let _e470 = cv;
    interStrength = clamp(((_e470 - 0.3f) / 0.4f), 0f, 1f);
    let _e479 = insideColor_1;
    cellColor = _e479;
    let _e481 = q1_;
    let _e482 = highlightFrac;
    if (_e481 < _e482) {
        let _e484 = highlightColor_1;
        cellColor = _e484;
    } else {
        let _e485 = cellColor;
        let _e486 = highlightColor_1;
        let _e487 = q2_;
        let _e488 = interStrength;
        cellColor = mix(_e485, _e486, vec4((_e487 * _e488)));
    }
    let _e492 = cellRnd;
    r = (_e492.y + 0.5f);
    let _e498 = r;
    let _e499 = r;
    let _e501 = thicknessVar_1;
    jitter = mix(1f, (_e498 * _e499), _e501);
    let _e504 = thickness_1;
    let _e505 = jitter;
    th = ((_e504 * _e505) * 0.1f);
    let _e510 = p;
    let _e512 = rect;
    let _e515 = rect;
    let _e517 = p;
    distX = min((_e510.x - _e512.x), (_e515.z - _e517.x));
    let _e522 = p;
    let _e524 = rect;
    let _e527 = rect;
    let _e529 = p;
    distY = min((_e522.y - _e524.y), (_e527.w - _e529.y));
    let _e535 = outDim_1;
    let _e540 = modelTransform_1[0];
    du = ((2f / _e535.y) / length(_e540.xy));
    let _e545 = d;
    dd = max(_e545, 0.0001f);
    let _e549 = pw;
    let _e550 = dd;
    let _e553 = pw;
    Jr = (_e549 * pow((_e550 * 0.5f), (_e553 - 1f)));
    let _e561 = dd;
    Ja = (1f / (3.1415927f * _e561));
    let _e565 = Ja;
    let _e566 = du;
    aaX = max((_e565 * _e566), 0.000001f);
    let _e571 = Jr;
    let _e572 = du;
    aaY = max((_e571 * _e572), 0.000001f);
    let _e578 = distX;
    let _e580 = aaX;
    let _e583 = th;
    let _e585 = distX;
    let _e587 = aaX;
    let _e590 = th;
    let _e595 = aaX;
    covX = (max(0f, (min((_e578 + (0.5f * _e580)), _e583) - max((_e585 - (0.5f * _e587)), -(_e590)))) / _e595);
    let _e599 = distY;
    let _e601 = aaY;
    let _e604 = th;
    let _e606 = distY;
    let _e608 = aaY;
    let _e611 = th;
    let _e616 = aaY;
    covY = (max(0f, (min((_e599 + (0.5f * _e601)), _e604) - max((_e606 - (0.5f * _e608)), -(_e611)))) / _e616);
    let _e619 = covX;
    let _e620 = covY;
    borderMix = max(_e619, _e620);
    let _e623 = cellColor;
    let _e624 = borderColor_1;
    let _e625 = borderMix;
    fg = mix(_e623, _e624, vec4(_e625));
    let _e629 = bg;
    let _e630 = fg;
    let _e631 = mergeColor(_e629, _e630);
    return _e631;
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
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e100 = global.U[13];
    let _e104 = global.U[14];
    let _e108 = global.U[15];
    let _e112 = global.U[16];
    let _e116 = global.U[17];
    let _e120 = global.U[18];
    let _e121 = _e120.xyz;
    let _e124 = global.U[19];
    let _e125 = _e124.xyz;
    let _e128 = global.U[20];
    let _e129 = _e128.xyz;
    let _e143 = schema2_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.xy, _e74.x, _e78, _e81, _e84, _e87.x, _e91.x, i32(_e95.x), _e100.x, _e104.x, _e108.x, _e112.x, _e116.x, mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)));
    fragColor = _e143;
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
