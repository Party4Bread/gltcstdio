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
                                    let _e348 = textureSampleLevel(t_source, samp, _e346, 0f);
                                    col = _e348;
                                    let _e350 = totalCol;
                                    let _e351 = weight;
                                    let _e352 = col;
                                    totalCol = (_e350 + (_e351 * _e352));
                                    let _e355 = totalWeight;
                                    let _e356 = weight;
                                    totalWeight = (_e355 + _e356);
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
            let _e361 = pos_1;
            u_3 = _e361;
            let _e362 = u_3;
            let _e365 = hexTile((_e362 * 0.5f));
            tile = _e365;
            let _e367 = tile;
            id_1 = round((_e367.center * 10f));
            let _e372 = tile;
            center_2 = _e372.center;
            let _e374 = pos_1;
            let _e377 = center_2;
            u_3 = (((_e374 * 0.5f) - _e377) * 2f);
            let _e381 = blend_1;
            if (_e381 <= 0f) {
                {
                    let _e384 = u_3;
                    borderDist_2 = (_e384 - vec2(-1f));
                    let _e392 = borderDist_2;
                    lightFactor_1 = smoothstep(vec2(0f), vec2(1.4f), _e392);
                    let _e397 = lightFactor_1;
                    let _e399 = lightFactor_1;
                    lightStrength_1 = (_e397.x * _e399.y);
                    let _e404 = lightStrength_1;
                    let _e405 = blend_1;
                    lighting = mix(1f, _e404, -(_e405));
                }
            }
            loop {
                let _e410 = i_1;
                if !((_e410 < 7i)) {
                    break;
                }
                {
                    weight_1 = 1f;
                    let _e419 = blend_1;
                    if (_e419 > 0f) {
                        {
                            let _e422 = i_1;
                            if (_e422 == 0i) {
                                {
                                }
                            } else {
                                {
                                    let _e425 = i_1;
                                    angle_2 = (f32((_e425 - 1i)) * 1.0471976f);
                                    let _e432 = tile;
                                    let _e434 = angle_2;
                                    let _e436 = angle_2;
                                    center_2 = (_e432.center + vec2<f32>(cos(_e434), sin(_e436)));
                                    let _e440 = center_2;
                                    id_1 = round((_e440 * 10f));
                                    let _e444 = pos_1;
                                    let _e447 = center_2;
                                    u_3 = (((_e444 * 0.5f) - _e447) * 2f);
                                }
                            }
                            let _e451 = blend_1;
                            if (_e451 < 0.5f) {
                                {
                                    let _e461 = blend_1;
                                    let _e466 = u_3;
                                    weight_1 = smoothstep(1.1547005f, (1.1547005f * (1f - (_e461 * 2f))), length(_e466));
                                }
                            } else {
                                {
                                    let _e473 = blend_1;
                                    let _e480 = u_3;
                                    weight_1 = smoothstep(mix(1.1547005f, 2f, ((_e473 - 0.5f) * 2f)), 0f, length(_e480));
                                }
                            }
                            let _e483 = blend_1;
                            let _e486 = i_1;
                            if ((_e483 < 0.2f) && (_e486 == 0i)) {
                                let _e490 = weight_1;
                                let _e492 = blend_1;
                                weight_1 = (_e490 + (pow((1f - (_e492 * 5f)), 15f) * 250f));
                            }
                        }
                    } else {
                        {
                            let _e501 = i_1;
                            if (_e501 == 0i) {
                                local_2 = 1f;
                            } else {
                                local_2 = 0f;
                            }
                            let _e507 = local_2;
                            weight_1 = _e507;
                        }
                    }
                    let _e508 = u_3;
                    d_3 = length(_e508);
                    let _e511 = weight_1;
                    if (_e511 > 0f) {
                        {
                            sourceAngle_3 = 0f;
                            halfAlpha_3 = 0f;
                            alpha_3 = 0f;
                            let _e520 = d_3;
                            if (_e520 > 0f) {
                                {
                                    let _e523 = u_3;
                                    let _e525 = u_3;
                                    ang_1 = atan2(_e523.y, _e525.x);
                                    let _e529 = ang_1;
                                    if (_e529 < 0f) {
                                        let _e532 = ang_1;
                                        ang_1 = (_e532 + 6.2831855f);
                                    }
                                    let _e536 = spikeCount_1;
                                    halfAlpha_3 = (3.1415927f / f32(_e536));
                                    let _e539 = halfAlpha_3;
                                    alpha_3 = (_e539 * 2f);
                                    let _e542 = ang_1;
                                    let _e543 = alpha_3;
                                    sourceAngle_3 = (_e542 - (floor((_e542 / _e543)) * _e543));
                                }
                            }
                            let _e548 = d_3;
                            let _e549 = sourceAngle_3;
                            let _e550 = alpha_3;
                            let _e551 = halfAlpha_3;
                            let _e552 = reflct(_e548, _e549, _e550, _e551);
                            coord_1 = _e552;
                            angle_3 = 0f;
                            scale_1 = 1f;
                            t_1 = vec2<f32>(0f, 0f);
                            let _e562 = id_1;
                            let _e566 = id_1;
                            if ((_e562.x != 0f) || (_e566.y != 0f)) {
                                {
                                    let _e571 = id_1;
                                    let _e572 = randomSeed_1;
                                    let _e573 = rand2relSeeded(_e571, _e572);
                                    rnd_1 = _e573;
                                    let _e575 = variability_1;
                                    let _e576 = rnd_1;
                                    angle_3 = (((_e575 * _e576.x) * 3.1415927f) * 2f);
                                    let _e583 = variability_1;
                                    let _e584 = rnd_1;
                                    scale_1 = (((_e583 * _e584.y) * 0.2f) + 1f);
                                    let _e591 = variability_1;
                                    let _e592 = rnd_1;
                                    t_1 = ((_e591 * _e592) * 2f);
                                }
                            }
                            let _e596 = texTransform_1;
                            let _e598 = coord_1;
                            let _e599 = tf(_naga_inverse_3x3_f32(_e596), _e598);
                            tc_1 = _e599;
                            let _e601 = scale_1;
                            let _e602 = angle_3;
                            let _e604 = tc_1;
                            let _e607 = angle_3;
                            let _e609 = tc_1;
                            let _e614 = t_1;
                            let _e617 = scale_1;
                            let _e618 = angle_3;
                            let _e621 = tc_1;
                            let _e624 = angle_3;
                            let _e626 = tc_1;
                            let _e631 = t_1;
                            tcc_1 = vec2<f32>(((_e601 * ((cos(_e602) * _e604.x) + (sin(_e607) * _e609.y))) + _e614.x), ((_e617 * ((-(sin(_e618)) * _e621.x) + (cos(_e624) * _e626.y))) + _e631.y));
                            let _e636 = tcc_1;
                            let _e640 = global.U[0];
                            let _e643 = tcc_1;
                            let _e652 = _mirror_wrap(((vec2<f32>((_e636.x / _e640.x), _e643.y) / vec2(2f)) + vec2(0.5f)));
                            let _e654 = textureSampleLevel(t_source, samp, _e652, 0f);
                            col_1 = _e654;
                            let _e656 = totalCol;
                            let _e657 = weight_1;
                            let _e658 = col_1;
                            totalCol = (_e656 + (_e657 * _e658));
                            let _e661 = totalWeight;
                            let _e662 = weight_1;
                            totalWeight = (_e661 + _e662);
                        }
                    }
                }
                continuing {
                    let _e414 = i_1;
                    i_1 = (_e414 + 1i);
                }
            }
        }
    }
    let _e664 = totalCol;
    let _e665 = totalWeight;
    let _e668 = lighting;
    let _e669 = vec3(_e668);
    return ((_e664 / vec4(_e665)) * vec4<f32>(_e669.x, _e669.y, _e669.z, 1f));
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
