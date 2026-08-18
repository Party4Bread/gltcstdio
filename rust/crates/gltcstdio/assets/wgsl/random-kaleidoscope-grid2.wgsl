struct Params {
    U: array<vec4<f32>, 13>,
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

fn hexDist(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;

    p_1 = p;
    let _e8 = p_1;
    p_1 = abs(_e8);
    let _e10 = p_1;
    let _e12 = p_1;
    return max(_e10.x, dot(_e12, normalize(vec2<f32>(1f, 1.7320508f))));
}

fn hexTile(v: vec2<f32>) -> HexTile {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
    var angle: f32;
    var dist: f32;
    var borderDist: f32;
    var center: vec2<f32>;

    v_1 = v;
    let _e12 = r;
    h = (_e12 / vec2(2f));
    let _e17 = v_1;
    let _e19 = r;
    let _e25 = v_1;
    let _e27 = r;
    let _e34 = h;
    a = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_1;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r;
    let _e48 = v_1;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r;
    let _e60 = h;
    b = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a;
    let _e65 = b;
    if (length(_e63) < length(_e65)) {
        let _e68 = a;
        local = _e68;
    } else {
        let _e69 = b;
        local = _e69;
    }
    let _e71 = local;
    hv = _e71;
    let _e73 = hv;
    let _e75 = hv;
    angle = atan2(_e73.y, _e75.x);
    let _e79 = hv;
    dist = length(_e79);
    let _e83 = hv;
    let _e84 = hexDist(_e83);
    borderDist = (0.5f - _e84);
    let _e87 = v_1;
    let _e88 = hv;
    center = (_e87 - _e88);
    let _e91 = center;
    let _e92 = hv;
    let _e93 = angle;
    let _e94 = dist;
    let _e95 = borderDist;
    return HexTile(_e91, _e92, _e93, _e94, _e95);
}

fn rand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var x: f32;
    var y: f32;

    v_3 = v_2;
    let _e8 = v_3;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_3;
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

fn reflct(d: f32, sourceAngle: f32, alpha: f32, halfAlpha: f32) -> vec2<f32> {
    var d_1: f32;
    var sourceAngle_1: f32;
    var alpha_1: f32;
    var halfAlpha_1: f32;

    d_1 = d;
    sourceAngle_1 = sourceAngle;
    alpha_1 = alpha;
    halfAlpha_1 = halfAlpha;
    let _e14 = sourceAngle_1;
    let _e15 = halfAlpha_1;
    if (_e14 > _e15) {
        let _e17 = alpha_1;
        let _e18 = sourceAngle_1;
        sourceAngle_1 = (_e17 - _e18);
    }
    let _e20 = d_1;
    let _e21 = sourceAngle_1;
    let _e23 = sourceAngle_1;
    return (_e20 * vec2<f32>(cos(_e21), sin(_e23)));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn kaleidoscope(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, spikeCount: i32, texTransform: mat3x3<f32>, blend: f32, randomSeed: f32, variability: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var spikeCount_1: i32;
    var texTransform_1: mat3x3<f32>;
    var blend_1: f32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var totalWeight: f32 = 0f;
    var totalCol: vec4<f32> = vec4(0f);
    var totalCoord: vec2<f32> = vec2(0f);
    var lightestCol: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var lightestVal: f32 = 0f;
    var lighting: f32 = 1f;
    var N: f32 = 1f;
    var j: f32;
    var i: f32;
    var u_2: vec2<f32>;
    var id: vec2<f32>;
    var center_1: vec2<f32>;
    var d_2: f32;
    var weight: f32;
    var local_1: f32;
    var borderDist_1: vec2<f32>;
    var lightFactor: vec2<f32>;
    var lightStrength: f32;
    var squareWeight: f32;
    var circleWeight: f32;
    var b_1: f32;
    var sourceAngle_2: f32;
    var halfAlpha_2: f32;
    var alpha_2: f32;
    var ang: f32;
    var coord: vec2<f32>;
    var angle_1: f32;
    var scale: f32;
    var t: vec2<f32>;
    var rnd: vec2<f32>;
    var tc: vec2<f32>;
    var tcc: vec2<f32>;
    var col: vec4<f32>;
    var u_3: vec2<f32>;
    var id_1: vec2<f32>;
    var center_2: vec2<f32>;
    var tile: HexTile;
    var borderDist_2: vec2<f32>;
    var lightFactor_1: vec2<f32>;
    var lightStrength_1: f32;
    var i_1: i32 = 0i;
    var weight_1: f32;
    var angle_2: f32;
    var local_2: f32;
    var d_3: f32;
    var sourceAngle_3: f32;
    var halfAlpha_3: f32;
    var alpha_3: f32;
    var ang_1: f32;
    var coord_1: vec2<f32>;
    var angle_3: f32;
    var scale_1: f32;
    var t_1: vec2<f32>;
    var rnd_1: vec2<f32>;
    var tc_1: vec2<f32>;
    var tcc_1: vec2<f32>;
    var col_1: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    spikeCount_1 = spikeCount;
    texTransform_1 = texTransform;
    blend_1 = blend;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    let _e40 = mode_1;
    if (_e40 == 0i) {
        {
            let _e45 = N;
            j = -(_e45);
            loop {
                let _e48 = j;
                let _e49 = N;
                if !((_e48 <= _e49)) {
                    break;
                }
                {
                    let _e55 = N;
                    i = -(_e55);
                    loop {
                        let _e58 = i;
                        let _e59 = N;
                        if !((_e58 <= _e59)) {
                            break;
                        }
                        {
                            let _e68 = pos_1;
                            u_2 = _e68;
                            let _e69 = u_2;
                            let _e77 = i;
                            let _e78 = j;
                            id = (floor(((_e69 + vec2(1f)) / vec2(2f))) + vec2<f32>(_e77, _e78));
                            let _e81 = id;
                            center_1 = (_e81 * 2f);
                            let _e84 = u_2;
                            let _e85 = center_1;
                            u_2 = (_e84 - _e85);
                            let _e87 = u_2;
                            d_2 = length(_e87);
                            let _e91 = blend_1;
                            if (_e91 <= 0f) {
                                {
                                    let _e94 = i;
                                    let _e97 = j;
                                    if ((_e94 == 0f) && (_e97 == 0f)) {
                                        local_1 = 1f;
                                    } else {
                                        local_1 = 0f;
                                    }
                                    let _e104 = local_1;
                                    weight = _e104;
                                    let _e105 = u_2;
                                    borderDist_1 = (_e105 - vec2(-1f));
                                    let _e113 = borderDist_1;
                                    lightFactor = smoothstep(vec2(0f), vec2(1.4f), _e113);
                                    let _e118 = lightFactor;
                                    let _e120 = lightFactor;
                                    lightStrength = (_e118.x * _e120.y);
                                    let _e124 = i;
                                    let _e127 = j;
                                    if ((_e124 == 0f) && (_e127 == 0f)) {
                                        let _e132 = lightStrength;
                                        let _e133 = blend_1;
                                        lighting = mix(1f, _e132, -(_e133));
                                    }
                                }
                            } else {
                                let _e136 = blend_1;
                                if (_e136 < 0.15f) {
                                    {
                                        let _e140 = blend_1;
                                        let _e143 = blend_1;
                                        let _e145 = u_2;
                                        let _e148 = u_2;
                                        weight = smoothstep((1f + _e140), (1f - _e143), max(abs(_e145.x), abs(_e148.y)));
                                    }
                                } else {
                                    let _e153 = blend_1;
                                    if (_e153 < 0.3f) {
                                        {
                                            let _e162 = u_2;
                                            let _e165 = u_2;
                                            squareWeight = smoothstep(1.15f, 0.85f, max(abs(_e162.x), abs(_e165.y)));
                                            let _e177 = d_2;
                                            circleWeight = smoothstep(1.55f, 1.25f, _e177);
                                            let _e180 = squareWeight;
                                            let _e181 = circleWeight;
                                            let _e182 = blend_1;
                                            weight = mix(_e180, _e181, ((_e182 - 0.15f) / 0.15f));
                                        }
                                    } else {
                                        {
                                            let _e190 = blend_1;
                                            b_1 = mix(0.15f, 1f, ((_e190 - 0.3f) / 0.7f));
                                            let _e198 = b_1;
                                            let _e201 = b_1;
                                            let _e203 = d_2;
                                            weight = smoothstep((1.4f + _e198), (1.4f - _e201), _e203);
                                        }
                                    }
                                }
                            }
                            let _e205 = weight;
                            if (_e205 > 0f) {
                                {
                                    sourceAngle_2 = 0f;
                                    halfAlpha_2 = 0f;
                                    alpha_2 = 0f;
                                    let _e214 = d_2;
                                    if (_e214 > 0f) {
                                        {
                                            let _e217 = u_2;
                                            let _e219 = u_2;
                                            ang = atan2(_e217.y, _e219.x);
                                            let _e223 = ang;
                                            if (_e223 < 0f) {
                                                let _e226 = ang;
                                                ang = (_e226 + 6.2831855f);
                                            }
                                            let _e230 = spikeCount_1;
                                            halfAlpha_2 = (3.1415927f / f32(_e230));
                                            let _e233 = halfAlpha_2;
                                            alpha_2 = (_e233 * 2f);
                                            let _e236 = ang;
                                            let _e237 = alpha_2;
                                            sourceAngle_2 = (_e236 - (floor((_e236 / _e237)) * _e237));
                                        }
                                    }
                                    let _e242 = d_2;
                                    let _e243 = sourceAngle_2;
                                    let _e244 = alpha_2;
                                    let _e245 = halfAlpha_2;
                                    let _e246 = reflct(_e242, _e243, _e244, _e245);
                                    coord = _e246;
                                    angle_1 = 0f;
                                    scale = 1f;
                                    t = vec2<f32>(0f, 0f);
                                    let _e256 = id;
                                    let _e260 = id;
                                    if ((_e256.x != 0f) || (_e260.y != 0f)) {
                                        {
                                            let _e265 = id;
                                            let _e266 = randomSeed_1;
                                            let _e267 = rand2relSeeded(_e265, _e266);
                                            rnd = _e267;
                                            let _e269 = variability_1;
                                            let _e270 = rnd;
                                            angle_1 = (((_e269 * _e270.x) * 3.1415927f) * 2f);
                                            let _e277 = variability_1;
                                            let _e278 = rnd;
                                            scale = (((_e277 * _e278.y) * 0.2f) + 1f);
                                            let _e285 = variability_1;
                                            let _e286 = rnd;
                                            t = ((_e285 * _e286) * 2f);
                                        }
                                    }
                                    let _e290 = texTransform_1;
                                    let _e292 = coord;
                                    let _e293 = tf(_naga_inverse_3x3_f32(_e290), _e292);
                                    tc = _e293;
                                    let _e295 = scale;
                                    let _e296 = angle_1;
                                    let _e298 = tc;
                                    let _e301 = angle_1;
                                    let _e303 = tc;
                                    let _e308 = t;
                                    let _e311 = scale;
                                    let _e312 = angle_1;
                                    let _e315 = tc;
                                    let _e318 = angle_1;
                                    let _e320 = tc;
                                    let _e325 = t;
                                    tcc = vec2<f32>(((_e295 * ((cos(_e296) * _e298.x) + (sin(_e301) * _e303.y))) + _e308.x), ((_e311 * ((-(sin(_e312)) * _e315.x) + (cos(_e318) * _e320.y))) + _e325.y));
                                    let _e330 = tcc;
                                    let _e334 = global.U[0];
                                    let _e337 = tcc;
                                    let _e346 = _mirror_wrap(((vec2<f32>((_e330.x / _e334.x), _e337.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e347 = textureSample(t_source, samp, _e346);
                                    col = _e347;
                                    let _e349 = totalCol;
                                    let _e350 = weight;
                                    let _e351 = col;
                                    totalCol = (_e349 + (_e350 * _e351));
                                    let _e354 = totalWeight;
                                    let _e355 = weight;
                                    totalWeight = (_e354 + _e355);
                                }
                            }
                        }
                        continuing {
                            let _e62 = i;
                            i = (_e62 + 1f);
                        }
                    }
                }
                continuing {
                    let _e52 = j;
                    j = (_e52 + 1f);
                }
            }
        }
    } else {
        {
            let _e360 = pos_1;
            u_3 = _e360;
            let _e361 = u_3;
            let _e364 = hexTile((_e361 * 0.5f));
            tile = _e364;
            let _e366 = tile;
            id_1 = round((_e366.center * 10f));
            let _e371 = tile;
            center_2 = _e371.center;
            let _e373 = pos_1;
            let _e376 = center_2;
            u_3 = (((_e373 * 0.5f) - _e376) * 2f);
            let _e380 = blend_1;
            if (_e380 <= 0f) {
                {
                    let _e383 = u_3;
                    borderDist_2 = (_e383 - vec2(-1f));
                    let _e391 = borderDist_2;
                    lightFactor_1 = smoothstep(vec2(0f), vec2(1.4f), _e391);
                    let _e396 = lightFactor_1;
                    let _e398 = lightFactor_1;
                    lightStrength_1 = (_e396.x * _e398.y);
                    let _e403 = lightStrength_1;
                    let _e404 = blend_1;
                    lighting = mix(1f, _e403, -(_e404));
                }
            }
            loop {
                let _e409 = i_1;
                if !((_e409 < 7i)) {
                    break;
                }
                {
                    weight_1 = 1f;
                    let _e418 = blend_1;
                    if (_e418 > 0f) {
                        {
                            let _e421 = i_1;
                            if (_e421 == 0i) {
                                {
                                }
                            } else {
                                {
                                    let _e424 = i_1;
                                    angle_2 = (f32((_e424 - 1i)) * 1.0471976f);
                                    let _e431 = tile;
                                    let _e433 = angle_2;
                                    let _e435 = angle_2;
                                    center_2 = (_e431.center + vec2<f32>(cos(_e433), sin(_e435)));
                                    let _e439 = center_2;
                                    id_1 = round((_e439 * 10f));
                                    let _e443 = pos_1;
                                    let _e446 = center_2;
                                    u_3 = (((_e443 * 0.5f) - _e446) * 2f);
                                }
                            }
                            let _e450 = blend_1;
                            if (_e450 < 0.5f) {
                                {
                                    let _e460 = blend_1;
                                    let _e465 = u_3;
                                    weight_1 = smoothstep(1.1547005f, (1.1547005f * (1f - (_e460 * 2f))), length(_e465));
                                }
                            } else {
                                {
                                    let _e472 = blend_1;
                                    let _e479 = u_3;
                                    weight_1 = smoothstep(mix(1.1547005f, 2f, ((_e472 - 0.5f) * 2f)), 0f, length(_e479));
                                }
                            }
                            let _e482 = blend_1;
                            let _e485 = i_1;
                            if ((_e482 < 0.2f) && (_e485 == 0i)) {
                                let _e489 = weight_1;
                                let _e491 = blend_1;
                                weight_1 = (_e489 + (pow((1f - (_e491 * 5f)), 15f) * 250f));
                            }
                        }
                    } else {
                        {
                            let _e500 = i_1;
                            if (_e500 == 0i) {
                                local_2 = 1f;
                            } else {
                                local_2 = 0f;
                            }
                            let _e506 = local_2;
                            weight_1 = _e506;
                        }
                    }
                    let _e507 = u_3;
                    d_3 = length(_e507);
                    let _e510 = weight_1;
                    if (_e510 > 0f) {
                        {
                            sourceAngle_3 = 0f;
                            halfAlpha_3 = 0f;
                            alpha_3 = 0f;
                            let _e519 = d_3;
                            if (_e519 > 0f) {
                                {
                                    let _e522 = u_3;
                                    let _e524 = u_3;
                                    ang_1 = atan2(_e522.y, _e524.x);
                                    let _e528 = ang_1;
                                    if (_e528 < 0f) {
                                        let _e531 = ang_1;
                                        ang_1 = (_e531 + 6.2831855f);
                                    }
                                    let _e535 = spikeCount_1;
                                    halfAlpha_3 = (3.1415927f / f32(_e535));
                                    let _e538 = halfAlpha_3;
                                    alpha_3 = (_e538 * 2f);
                                    let _e541 = ang_1;
                                    let _e542 = alpha_3;
                                    sourceAngle_3 = (_e541 - (floor((_e541 / _e542)) * _e542));
                                }
                            }
                            let _e547 = d_3;
                            let _e548 = sourceAngle_3;
                            let _e549 = alpha_3;
                            let _e550 = halfAlpha_3;
                            let _e551 = reflct(_e547, _e548, _e549, _e550);
                            coord_1 = _e551;
                            angle_3 = 0f;
                            scale_1 = 1f;
                            t_1 = vec2<f32>(0f, 0f);
                            let _e561 = id_1;
                            let _e565 = id_1;
                            if ((_e561.x != 0f) || (_e565.y != 0f)) {
                                {
                                    let _e570 = id_1;
                                    let _e571 = randomSeed_1;
                                    let _e572 = rand2relSeeded(_e570, _e571);
                                    rnd_1 = _e572;
                                    let _e574 = variability_1;
                                    let _e575 = rnd_1;
                                    angle_3 = (((_e574 * _e575.x) * 3.1415927f) * 2f);
                                    let _e582 = variability_1;
                                    let _e583 = rnd_1;
                                    scale_1 = (((_e582 * _e583.y) * 0.2f) + 1f);
                                    let _e590 = variability_1;
                                    let _e591 = rnd_1;
                                    t_1 = ((_e590 * _e591) * 2f);
                                }
                            }
                            let _e595 = texTransform_1;
                            let _e597 = coord_1;
                            let _e598 = tf(_naga_inverse_3x3_f32(_e595), _e597);
                            tc_1 = _e598;
                            let _e600 = scale_1;
                            let _e601 = angle_3;
                            let _e603 = tc_1;
                            let _e606 = angle_3;
                            let _e608 = tc_1;
                            let _e613 = t_1;
                            let _e616 = scale_1;
                            let _e617 = angle_3;
                            let _e620 = tc_1;
                            let _e623 = angle_3;
                            let _e625 = tc_1;
                            let _e630 = t_1;
                            tcc_1 = vec2<f32>(((_e600 * ((cos(_e601) * _e603.x) + (sin(_e606) * _e608.y))) + _e613.x), ((_e616 * ((-(sin(_e617)) * _e620.x) + (cos(_e623) * _e625.y))) + _e630.y));
                            let _e635 = tcc_1;
                            let _e639 = global.U[0];
                            let _e642 = tcc_1;
                            let _e651 = _mirror_wrap(((vec2<f32>((_e635.x / _e639.x), _e642.y) / vec2(2f)) + vec2(0.5f)));
                            let _e652 = textureSample(t_source, samp, _e651);
                            col_1 = _e652;
                            let _e654 = totalCol;
                            let _e655 = weight_1;
                            let _e656 = col_1;
                            totalCol = (_e654 + (_e655 * _e656));
                            let _e659 = totalWeight;
                            let _e660 = weight_1;
                            totalWeight = (_e659 + _e660);
                        }
                    }
                }
                continuing {
                    let _e413 = i_1;
                    i_1 = (_e413 + 1i);
                }
            }
        }
    }
    let _e662 = totalCol;
    let _e663 = totalWeight;
    let _e666 = lighting;
    let _e667 = vec3(_e666);
    return ((_e662 / vec4(_e663)) * vec4<f32>(_e667.x, _e667.y, _e667.z, 1f));
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
    let _e66 = global.U[5];
    let _e71 = global.U[6];
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e101 = global.U[10];
    let _e105 = global.U[11];
    let _e109 = global.U[12];
    let _e111 = kaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), _e101.x, _e105.x, _e109.x);
    fragColor = _e111;
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
