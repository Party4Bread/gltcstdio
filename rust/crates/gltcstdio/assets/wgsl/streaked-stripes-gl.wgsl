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

fn streakedStripesGL(uv: vec2<f32>, outPos: vec2<f32>, color: vec4<f32>, thickness: f32, balance: f32, variability: f32, shadows: f32, randomSeed: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var balance_1: f32;
    var variability_1: f32;
    var shadows_1: f32;
    var randomSeed_1: f32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u: vec2<f32>;
    var pixel: f32;
    var scale: f32;
    var t: f32;
    var varAmt: f32;
    var index: f32;
    var border: bool = false;
    var light: f32 = 1f;
    var x1_: f32 = 0f;
    var x2_: f32 = 0f;
    var i2_: f32 = 0f;
    var i: f32;
    var rnd2_: vec2<f32>;
    var shadowSize: f32;
    var rnd: vec2<f32>;
    var maxIter: i32 = 30i;
    var st: f32;
    var Y: f32;
    var dy: f32;
    var k_4: f32;
    var x12_: f32;
    var Y_1: f32;
    var dy_1: f32;
    var k_5: f32;
    var x12_1: f32;
    var v_2: vec2<f32>;
    var col: vec4<f32>;
    var local: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    color_1 = color;
    thickness_1 = thickness;
    balance_1 = balance;
    variability_1 = variability;
    shadows_1 = shadows;
    randomSeed_1 = randomSeed;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e26 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e26);
    let _e29 = invM;
    let _e30 = uv_1;
    u = (_e29 * vec3<f32>(_e30.x, _e30.y, 1f)).xy;
    let _e39 = sourceDim_1;
    pixel = (2f / _e39.y);
    let _e45 = invM[0];
    scale = length(_e45.xy);
    let _e49 = thickness_1;
    let _e52 = scale;
    t = ((_e49 * 0.02f) * _e52);
    let _e55 = variability_1;
    varAmt = (_e55 * 8f);
    let _e59 = u;
    index = floor((_e59.x + 0.5f));
    let _e75 = index;
    i = (_e75 - 6f);
    loop {
        let _e79 = i;
        let _e80 = index;
        if !((_e79 <= (_e80 + 6f))) {
            break;
        }
        {
            let _e88 = i;
            let _e89 = i;
            let _e91 = randomSeed_1;
            let _e92 = rand2relSeeded(vec2<f32>(_e88, _e89), _e91);
            rnd2_ = _e92;
            let _e94 = i;
            let _e95 = varAmt;
            let _e96 = rnd2_;
            x1_ = (_e94 + (_e95 * _e96.x));
            let _e100 = shadows_1;
            let _e104 = variability_1;
            let _e105 = rnd2_;
            shadowSize = ((_e100 * 4f) * (1f + (_e104 * _e105.y)));
            let _e111 = i;
            i2_ = (_e111 + 1f);
            let _e114 = i2_;
            let _e115 = varAmt;
            let _e116 = i2_;
            let _e117 = i2_;
            let _e119 = randomSeed_1;
            let _e120 = rand2relSeeded(vec2<f32>(_e116, _e117), _e119);
            x2_ = (_e114 + (_e115 * _e120.x));
            let _e124 = u;
            let _e126 = x1_;
            let _e129 = t;
            let _e131 = x2_;
            let _e132 = u;
            let _e136 = t;
            if ((abs((_e124.x - _e126)) < _e129) || (abs((_e131 - _e132.x)) < _e136)) {
                {
                    border = true;
                    break;
                }
            } else {
                let _e140 = x1_;
                let _e141 = u;
                let _e144 = u;
                let _e146 = x2_;
                if ((_e140 <= _e141.x) && (_e144.x <= _e146)) {
                    {
                        let _e149 = shadowSize;
                        let _e152 = shadows_1;
                        let _e154 = shadowSize;
                        let _e155 = x2_;
                        let _e156 = u;
                        light = smoothstep(mix(-(_e149), 0f, _e152), _e154, (_e155 - _e156.x));
                        break;
                    }
                }
            }
        }
        continuing {
            let _e85 = i;
            i = (_e85 + 1f);
        }
    }
    let _e160 = u;
    let _e163 = i2_;
    let _e165 = randomSeed_1;
    let _e166 = rand2relSeeded(vec2<f32>(sign(_e160.y), _e163), _e165);
    rnd = _e166;
    let _e170 = t;
    st = _e170;
    let _e172 = balance_1;
    if (_e172 < 0f) {
        {
            let _e176 = balance_1;
            let _e177 = balance_1;
            let _e187 = varAmt;
            let _e189 = rnd;
            Y = (((50f / abs(((_e176 * _e177) * 10000f))) * 20f) * (1f + ((0.5f * _e187) * _e189.x)));
            let _e196 = balance_1;
            let _e197 = balance_1;
            let _e207 = varAmt;
            let _e209 = rnd;
            dy = (((50f / abs(((_e196 * _e197) * 10000f))) * 20f) * (1f + ((0.5f * _e207) * _e209.y)));
            loop {
                let _e215 = u;
                let _e218 = Y;
                let _e220 = x2_;
                let _e221 = x1_;
                let _e224 = pixel;
                let _e227 = maxIter;
                if !((((abs(_e215.y) > _e218) && (abs((_e220 - _e221)) > _e224)) && (_e227 > 0i))) {
                    break;
                }
                {
                    let _e232 = rnd;
                    k_4 = (_e232.x + 0.5f);
                    let _e237 = x1_;
                    let _e238 = x2_;
                    let _e239 = k_4;
                    x12_ = mix(_e237, _e238, _e239);
                    let _e242 = x2_;
                    let _e243 = x1_;
                    let _e246 = st;
                    let _e248 = u;
                    let _e250 = x12_;
                    let _e253 = st;
                    if ((abs((_e242 - _e243)) < _e246) || (abs((_e248.x - _e250)) < _e253)) {
                        {
                            border = true;
                            let _e257 = x12_;
                            x2_ = _e257;
                            x1_ = _e257;
                            break;
                        }
                    } else {
                        let _e258 = u;
                        let _e260 = x12_;
                        if (_e258.x < _e260) {
                            {
                                let _e262 = x12_;
                                x2_ = _e262;
                            }
                        } else {
                            {
                                let _e263 = x12_;
                                x1_ = _e263;
                            }
                        }
                    }
                    let _e264 = Y;
                    let _e265 = dy;
                    Y = (_e264 + _e265);
                    let _e267 = dy;
                    dy = (_e267 * 0.5f);
                    let _e270 = rnd;
                    let _e271 = randomSeed_1;
                    let _e272 = rand2relSeeded(_e270, _e271);
                    rnd = _e272;
                    let _e273 = maxIter;
                    maxIter = (_e273 - 1i);
                }
            }
        }
    } else {
        let _e276 = balance_1;
        if (_e276 > 0f) {
            {
                border = false;
                let _e280 = balance_1;
                let _e292 = varAmt;
                let _e294 = rnd;
                Y_1 = (((pow(abs((_e280 * 100f)), 1.5f) * 0.01f) * 20f) * (1f + ((0.01f * _e292) * _e294.x)));
                let _e301 = balance_1;
                let _e302 = balance_1;
                let _e312 = varAmt;
                let _e314 = rnd;
                dy_1 = (((50f / abs(((_e301 * _e302) * 10000f))) * 20f) * (1f + ((0.5f * _e312) * _e314.y)));
                loop {
                    let _e320 = u;
                    let _e323 = Y_1;
                    let _e325 = x2_;
                    let _e326 = x1_;
                    let _e329 = pixel;
                    let _e332 = maxIter;
                    if !((((abs(_e320.y) < _e323) && (abs((_e325 - _e326)) > _e329)) && (_e332 > 0i))) {
                        break;
                    }
                    {
                        let _e337 = rnd;
                        k_5 = (_e337.x + 0.5f);
                        let _e342 = x1_;
                        let _e343 = x2_;
                        let _e344 = k_5;
                        x12_1 = mix(_e342, _e343, _e344);
                        let _e347 = u;
                        let _e349 = x12_1;
                        if (_e347.x < _e349) {
                            {
                                let _e351 = x12_1;
                                x2_ = _e351;
                            }
                        } else {
                            {
                                let _e352 = x12_1;
                                x1_ = _e352;
                            }
                        }
                        let _e353 = Y_1;
                        let _e354 = dy_1;
                        Y_1 = (_e353 - _e354);
                        let _e356 = dy_1;
                        dy_1 = (_e356 * 0.5f);
                        let _e359 = rnd;
                        let _e360 = randomSeed_1;
                        let _e361 = rand2relSeeded(_e359, _e360);
                        rnd = _e361;
                        let _e362 = maxIter;
                        maxIter = (_e362 - 1i);
                    }
                }
                let _e365 = st;
                let _e366 = x2_;
                let _e367 = x1_;
                let _e373 = u;
                let _e375 = x1_;
                let _e378 = t;
                let _e380 = x2_;
                let _e381 = u;
                let _e385 = t;
                if ((_e365 < (abs((_e366 - _e367)) / 2f)) && ((abs((_e373.x - _e375)) < _e378) || (abs((_e380 - _e381.x)) < _e385))) {
                    {
                        border = true;
                    }
                }
            }
        }
    }
    let _e391 = x1_;
    let _e392 = x2_;
    u.x = ((_e391 + _e392) / 2f);
    let _e396 = modelTransform_1;
    let _e397 = u;
    v_2 = (_e396 * vec3<f32>(_e397.x, _e397.y, 1f)).xy;
    let _e405 = v_2;
    let _e409 = global.U[0];
    let _e412 = v_2;
    let _e421 = textureSample(t_source, samp, ((vec2<f32>((_e405.x / _e409.x), _e412.y) / vec2(2f)) + vec2(0.5f)));
    col = _e421;
    let _e423 = border;
    if _e423 {
        let _e424 = col;
        let _e426 = color_1;
        let _e428 = color_1;
        let _e431 = mix(_e424.xyz, _e426.xyz, vec3(_e428.w));
        let _e432 = col;
        local = vec4<f32>(_e431.x, _e431.y, _e431.z, _e432.w);
    } else {
        let _e438 = col;
        local = _e438;
    }
    let _e440 = local;
    outCol = _e440;
    let _e447 = outCol;
    let _e448 = light;
    outCol = mix(vec4<f32>(0f, 0f, 0f, 1f), _e447, vec4(_e448));
    let _e451 = outCol;
    return _e451;
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
    let _e66 = global.U[12];
    let _e69 = global.U[13];
    let _e73 = global.U[14];
    let _e77 = global.U[15];
    let _e81 = global.U[16];
    let _e85 = global.U[17];
    let _e89 = global.U[4];
    let _e93 = global.U[18];
    let _e94 = _e93.xyz;
    let _e97 = global.U[19];
    let _e98 = _e97.xyz;
    let _e101 = global.U[20];
    let _e102 = _e101.xyz;
    let _e116 = streakedStripesGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66, _e69.x, _e73.x, _e77.x, _e81.x, _e85.x, _e89.xy, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
