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

fn streak(uv: vec2<f32>, outPos: vec2<f32>, color: vec4<f32>, sourceDim: vec2<f32>, thickness: f32, variability: f32, shadows: f32, randomSeed: f32, subdividing: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var thickness_1: f32;
    var variability_1: f32;
    var shadows_1: f32;
    var randomSeed_1: f32;
    var subdividing_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var pixel: f32;
    var scale: f32;
    var t: f32;
    var var_: f32;
    var index: f32;
    var border: bool = false;
    var light: f32 = 1f;
    var x1_: f32;
    var x2_: f32;
    var i2_: f32;
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
    sourceDim_1 = sourceDim;
    thickness_1 = thickness;
    variability_1 = variability;
    shadows_1 = shadows;
    randomSeed_1 = randomSeed;
    subdividing_1 = subdividing;
    modelTransform_1 = modelTransform;
    let _e26 = modelTransform_1;
    let _e28 = uv_1;
    u = (_naga_inverse_3x3_f32(_e26) * vec3<f32>(_e28.x, _e28.y, 1f)).xy;
    let _e37 = sourceDim_1;
    pixel = (2f / _e37.y);
    let _e43 = modelTransform_1[0];
    scale = length(_e43.xy);
    let _e47 = thickness_1;
    let _e50 = scale;
    t = ((_e47 * 0.02f) * _e50);
    let _e53 = variability_1;
    var_ = (_e53 * 8f);
    let _e57 = u;
    index = floor((_e57.x + 0.5f));
    let _e70 = index;
    i = (_e70 - 6f);
    loop {
        let _e74 = i;
        let _e75 = index;
        if !((_e74 <= (_e75 + 6f))) {
            break;
        }
        {
            let _e83 = i;
            let _e84 = i;
            let _e86 = randomSeed_1;
            let _e87 = rand2relSeeded(vec2<f32>(_e83, _e84), _e86);
            rnd2_ = _e87;
            let _e89 = i;
            let _e90 = var_;
            let _e91 = rnd2_;
            x1_ = (_e89 + (_e90 * _e91.x));
            let _e95 = shadows_1;
            let _e99 = variability_1;
            let _e100 = rnd2_;
            shadowSize = ((_e95 * 4f) * (1f + (_e99 * _e100.y)));
            let _e106 = i;
            i2_ = (_e106 + 1f);
            let _e109 = i2_;
            let _e110 = var_;
            let _e111 = i2_;
            let _e112 = i2_;
            let _e114 = randomSeed_1;
            let _e115 = rand2relSeeded(vec2<f32>(_e111, _e112), _e114);
            x2_ = (_e109 + (_e110 * _e115.x));
            let _e119 = u;
            let _e121 = x1_;
            let _e124 = t;
            let _e126 = x2_;
            let _e127 = u;
            let _e131 = t;
            if ((abs((_e119.x - _e121)) < _e124) || (abs((_e126 - _e127.x)) < _e131)) {
                {
                    border = true;
                    break;
                }
            } else {
                let _e135 = x1_;
                let _e136 = u;
                let _e139 = u;
                let _e141 = x2_;
                if ((_e135 <= _e136.x) && (_e139.x <= _e141)) {
                    {
                        let _e144 = shadowSize;
                        let _e147 = shadows_1;
                        let _e149 = shadowSize;
                        let _e150 = x2_;
                        let _e151 = u;
                        light = smoothstep(mix(-(_e144), 0f, _e147), _e149, (_e150 - _e151.x));
                        break;
                    }
                }
            }
        }
        continuing {
            let _e80 = i;
            i = (_e80 + 1f);
        }
    }
    let _e155 = u;
    let _e158 = i2_;
    let _e160 = randomSeed_1;
    let _e161 = rand2relSeeded(vec2<f32>(sign(_e155.y), _e158), _e160);
    rnd = _e161;
    let _e165 = t;
    st = _e165;
    let _e167 = subdividing_1;
    if (_e167 < 0f) {
        {
            let _e171 = subdividing_1;
            let _e172 = subdividing_1;
            let _e182 = var_;
            let _e184 = rnd;
            Y = (((50f / abs(((_e171 * _e172) * 10000f))) * 20f) * (1f + ((0.5f * _e182) * _e184.x)));
            let _e191 = subdividing_1;
            let _e192 = subdividing_1;
            let _e202 = var_;
            let _e204 = rnd;
            dy = (((50f / abs(((_e191 * _e192) * 10000f))) * 20f) * (1f + ((0.5f * _e202) * _e204.y)));
            loop {
                let _e210 = u;
                let _e213 = Y;
                let _e215 = x2_;
                let _e216 = x1_;
                let _e219 = pixel;
                let _e222 = maxIter;
                if !((((abs(_e210.y) > _e213) && (abs((_e215 - _e216)) > _e219)) && (_e222 > 0i))) {
                    break;
                }
                {
                    let _e227 = rnd;
                    k_4 = (_e227.x + 0.5f);
                    let _e232 = x1_;
                    let _e233 = x2_;
                    let _e234 = k_4;
                    x12_ = mix(_e232, _e233, _e234);
                    let _e237 = x2_;
                    let _e238 = x1_;
                    let _e241 = st;
                    let _e243 = u;
                    let _e245 = x12_;
                    let _e248 = st;
                    if ((abs((_e237 - _e238)) < _e241) || (abs((_e243.x - _e245)) < _e248)) {
                        {
                            border = true;
                            let _e252 = x12_;
                            x2_ = _e252;
                            x1_ = _e252;
                            break;
                        }
                    } else {
                        let _e253 = u;
                        let _e255 = x12_;
                        if (_e253.x < _e255) {
                            {
                                let _e257 = x12_;
                                x2_ = _e257;
                            }
                        } else {
                            {
                                let _e258 = x12_;
                                x1_ = _e258;
                            }
                        }
                    }
                    let _e259 = Y;
                    let _e260 = dy;
                    Y = (_e259 + _e260);
                    let _e262 = dy;
                    dy = (_e262 * 0.5f);
                    let _e265 = rnd;
                    let _e266 = randomSeed_1;
                    let _e267 = rand2relSeeded(_e265, _e266);
                    rnd = _e267;
                    let _e268 = maxIter;
                    maxIter = (_e268 - 1i);
                }
            }
        }
    } else {
        let _e271 = subdividing_1;
        if (_e271 > 0f) {
            {
                border = false;
                let _e275 = subdividing_1;
                let _e287 = var_;
                let _e289 = rnd;
                Y_1 = (((pow(abs((_e275 * 100f)), 1.5f) * 0.01f) * 20f) * (1f + ((0.01f * _e287) * _e289.x)));
                let _e296 = subdividing_1;
                let _e297 = subdividing_1;
                let _e307 = var_;
                let _e309 = rnd;
                dy_1 = (((50f / abs(((_e296 * _e297) * 10000f))) * 20f) * (1f + ((0.5f * _e307) * _e309.y)));
                loop {
                    let _e315 = u;
                    let _e318 = Y_1;
                    let _e320 = x2_;
                    let _e321 = x1_;
                    let _e324 = pixel;
                    let _e327 = maxIter;
                    if !((((abs(_e315.y) < _e318) && (abs((_e320 - _e321)) > _e324)) && (_e327 > 0i))) {
                        break;
                    }
                    {
                        let _e332 = rnd;
                        k_5 = (_e332.x + 0.5f);
                        let _e337 = x1_;
                        let _e338 = x2_;
                        let _e339 = k_5;
                        x12_1 = mix(_e337, _e338, _e339);
                        let _e342 = u;
                        let _e344 = x12_1;
                        if (_e342.x < _e344) {
                            {
                                let _e346 = x12_1;
                                x2_ = _e346;
                            }
                        } else {
                            {
                                let _e347 = x12_1;
                                x1_ = _e347;
                            }
                        }
                        let _e348 = Y_1;
                        let _e349 = dy_1;
                        Y_1 = (_e348 - _e349);
                        let _e351 = dy_1;
                        dy_1 = (_e351 * 0.5f);
                        let _e354 = rnd;
                        let _e355 = randomSeed_1;
                        let _e356 = rand2relSeeded(_e354, _e355);
                        rnd = _e356;
                        let _e357 = maxIter;
                        maxIter = (_e357 - 1i);
                    }
                }
                let _e360 = st;
                let _e361 = x2_;
                let _e362 = x1_;
                let _e368 = u;
                let _e370 = x1_;
                let _e373 = t;
                let _e375 = x2_;
                let _e376 = u;
                let _e380 = t;
                if ((_e360 < (abs((_e361 - _e362)) / 2f)) && ((abs((_e368.x - _e370)) < _e373) || (abs((_e375 - _e376.x)) < _e380))) {
                    {
                        border = true;
                    }
                }
            }
        }
    }
    let _e386 = x1_;
    let _e387 = x2_;
    u.x = ((_e386 + _e387) / 2f);
    let _e391 = modelTransform_1;
    let _e392 = u;
    v_2 = (_e391 * vec3<f32>(_e392.x, _e392.y, 1f)).xy;
    let _e400 = v_2;
    let _e404 = global.U[0];
    let _e407 = v_2;
    let _e416 = textureSample(t_source, samp, ((vec2<f32>((_e400.x / _e404.x), _e407.y) / vec2(2f)) + vec2(0.5f)));
    col = _e416;
    let _e418 = border;
    if _e418 {
        let _e419 = col;
        let _e421 = color_1;
        let _e423 = color_1;
        let _e426 = mix(_e419.xyz, _e421.xyz, vec3(_e423.w));
        let _e427 = col;
        local = vec4<f32>(_e426.x, _e426.y, _e426.z, _e427.w);
    } else {
        let _e433 = col;
        local = _e433;
    }
    let _e435 = local;
    outCol = _e435;
    let _e442 = outCol;
    let _e443 = light;
    outCol = mix(vec4<f32>(0f, 0f, 0f, 1f), _e442, vec4(_e443));
    let _e446 = outCol;
    return _e446;
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
    let _e66 = global.U[6];
    let _e69 = global.U[4];
    let _e73 = global.U[7];
    let _e77 = global.U[8];
    let _e81 = global.U[9];
    let _e85 = global.U[10];
    let _e89 = global.U[11];
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e101 = global.U[14];
    let _e102 = _e101.xyz;
    let _e116 = streak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66, _e69.xy, _e73.x, _e77.x, _e81.x, _e85.x, _e89.x, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
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
