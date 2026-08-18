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

fn squareNoise(uv: vec2<f32>, outPos: vec2<f32>, depth: f32, count: i32, coverage: f32, variability: f32, randomSeed: f32, colorScheme: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var depth_1: f32;
    var count_1: i32;
    var coverage_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var colorScheme_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var col: vec4<f32>;
    var baseScale: f32 = 10f;
    var N: i32;
    var noiseSize: f32;
    var invModelTransform: mat3x3<f32>;
    var i: i32 = 0i;
    var local: f32;
    var s: f32;
    var u: vec2<f32>;
    var id: vec2<f32>;
    var v_2: vec2<f32>;
    var rnd: vec2<f32>;
    var hide: bool;
    var local_1: vec2<f32>;
    var center: vec2<f32>;
    var nSize: f32;
    var k_4: f32;
    var col1_: vec4<f32>;
    var col2_: vec4<f32>;
    var rc: f32;
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var local_4: vec4<f32>;
    var local_5: vec4<f32>;
    var local_6: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    depth_1 = depth;
    count_1 = count;
    coverage_1 = coverage;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    colorScheme_1 = colorScheme;
    modelTransform_1 = modelTransform;
    let _e24 = uv_1;
    let _e28 = global.U[0];
    let _e31 = uv_1;
    let _e40 = textureSample(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e31.y) / vec2(2f)) + vec2(0.5f)));
    col = _e40;
    let _e44 = count_1;
    N = _e44;
    let _e46 = coverage_1;
    noiseSize = (_e46 * 0.5f);
    let _e50 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e50);
    loop {
        let _e55 = i;
        let _e56 = N;
        if !((_e55 < _e56)) {
            break;
        }
        {
            let _e62 = N;
            if (_e62 <= 1i) {
                local = 1f;
            } else {
                let _e66 = depth_1;
                let _e69 = i;
                let _e72 = N;
                local = pow(_e66, (1f - ((2f * f32(_e69)) / f32((_e72 - 1i)))));
            }
            let _e80 = local;
            s = _e80;
            let _e82 = invModelTransform;
            let _e83 = s;
            let _e87 = s;
            let _e97 = uv_1;
            u = ((_e82 * mat3x3<f32>(vec3<f32>(_e83, 0f, 0f), vec3<f32>(0f, _e87, 0f), vec3<f32>(0f, 0f, 1f))) * vec3<f32>(_e97.x, _e97.y, 1f)).xy;
            let _e105 = u;
            id = round(_e105);
            let _e108 = u;
            let _e109 = id;
            v_2 = (_e108 - _e109);
            let _e112 = id;
            let _e113 = i;
            let _e121 = randomSeed_1;
            let _e122 = rand2relSeeded((_e112 + (f32(_e113) * vec2<f32>(4.43f, -5.434f))), _e121);
            rnd = _e122;
            let _e124 = rnd;
            let _e126 = rnd;
            let _e132 = variability_1;
            if (abs((_e124.x - _e126.y)) > (1f - (0.75f * _e132))) {
                let _e136 = id;
                let _e140 = i;
                let _e148 = randomSeed_1;
                let _e149 = rand2relSeeded((floor((_e136 * 0.25f)) + (f32(_e140) * vec2<f32>(4.43f, -5.434f))), _e148);
                rnd = _e149;
            }
            let _e150 = rnd;
            let _e152 = rnd;
            let _e158 = variability_1;
            if (abs((_e150.x - _e152.y)) > (1f - (0.75f * _e158))) {
                let _e162 = id;
                let _e166 = i;
                let _e174 = randomSeed_1;
                let _e175 = rand2relSeeded((floor((_e162 * 0.0625f)) + (f32(_e166) * vec2<f32>(4.43f, -5.434f))), _e174);
                rnd = _e175;
            }
            let _e176 = rnd;
            let _e183 = variability_1;
            hide = (fract((_e176.x * 10f)) > (1f - (0.5f * _e183)));
            let _e188 = rnd;
            let _e195 = variability_1;
            if (fract((_e188.x * 20f)) > (1f - (0.25f * _e195))) {
                let _e199 = v_2;
                v_2 = abs((_e199 - vec2(0.12f)));
            }
            let _e204 = variability_1;
            if (_e204 < 0.01f) {
                let _e207 = v_2;
                local_1 = _e207;
            } else {
                let _e208 = v_2;
                let _e209 = rnd;
                let _e211 = rnd;
                let _e214 = variability_1;
                let _e217 = rnd;
                let _e220 = variability_1;
                local_1 = (_e208 + (sign(_e209) * vec2<f32>(pow(_e211.x, (1f / _e214)), pow(_e217.y, (1f / _e220)))));
            }
            let _e227 = local_1;
            center = _e227;
            let _e229 = noiseSize;
            let _e231 = variability_1;
            let _e232 = rnd;
            nSize = (_e229 * pow(4f, (_e231 * (fract((_e232.y * 10f)) - 0.5f))));
            let _e243 = hide;
            let _e245 = center;
            let _e248 = nSize;
            let _e251 = center;
            let _e254 = nSize;
            if ((!(_e243) && (abs(_e245.x) < _e248)) && (abs(_e251.y) < _e254)) {
                {
                    let _e257 = colorScheme_1;
                    k_4 = (_e257 * 5f);
                    let _e263 = rnd;
                    rc = fract(((_e263.y * 10f) + 0.33f));
                    let _e271 = colorScheme_1;
                    if (_e271 < 0.2f) {
                        {
                            let _e274 = rc;
                            let _e275 = k_4;
                            if (_e274 >= _e275) {
                                local_2 = vec4<f32>(0f, 0f, 0f, 1f);
                            } else {
                                local_2 = vec4<f32>(1f, 1f, 1f, 1f);
                            }
                            let _e288 = local_2;
                            col = _e288;
                        }
                    } else {
                        let _e289 = colorScheme_1;
                        if (_e289 < 0.4f) {
                            {
                                let _e292 = k_4;
                                k_4 = (_e292 - 1f);
                                let _e295 = rc;
                                let _e296 = k_4;
                                if (_e295 >= _e296) {
                                    local_3 = vec4<f32>(1f, 1f, 1f, 1f);
                                } else {
                                    let _e303 = u;
                                    let _e307 = global.U[0];
                                    let _e310 = u;
                                    let _e319 = textureSample(t_source, samp, ((vec2<f32>((_e303.x / _e307.x), _e310.y) / vec2(2f)) + vec2(0.5f)));
                                    local_3 = _e319;
                                }
                                let _e321 = local_3;
                                col = _e321;
                            }
                        } else {
                            let _e322 = colorScheme_1;
                            if (_e322 < 0.6f) {
                                {
                                    let _e325 = k_4;
                                    k_4 = (_e325 - 2f);
                                    let _e328 = rc;
                                    let _e329 = k_4;
                                    if (_e328 >= _e329) {
                                        let _e331 = u;
                                        let _e335 = global.U[0];
                                        let _e338 = u;
                                        let _e347 = textureSample(t_source, samp, ((vec2<f32>((_e331.x / _e335.x), _e338.y) / vec2(2f)) + vec2(0.5f)));
                                        local_4 = _e347;
                                    } else {
                                        let _e348 = id;
                                        let _e354 = global.U[0];
                                        let _e357 = id;
                                        let _e368 = textureSample(t_source, samp, ((vec2<f32>(((_e348 * 0.731344f).x / _e354.x), (_e357 * 0.731344f).y) / vec2(2f)) + vec2(0.5f)));
                                        local_4 = _e368;
                                    }
                                    let _e370 = local_4;
                                    col = _e370;
                                }
                            } else {
                                let _e371 = colorScheme_1;
                                if (_e371 < 0.8f) {
                                    {
                                        let _e374 = k_4;
                                        k_4 = (_e374 - 3f);
                                        let _e377 = rc;
                                        let _e378 = k_4;
                                        if (_e377 >= _e378) {
                                            let _e380 = id;
                                            let _e386 = global.U[0];
                                            let _e389 = id;
                                            let _e400 = textureSample(t_source, samp, ((vec2<f32>(((_e380 * 0.731344f).x / _e386.x), (_e389 * 0.731344f).y) / vec2(2f)) + vec2(0.5f)));
                                            local_5 = _e400;
                                        } else {
                                            local_5 = vec4<f32>(0f, 0f, 0f, 1f);
                                        }
                                        let _e407 = local_5;
                                        col = _e407;
                                    }
                                } else {
                                    {
                                        let _e408 = k_4;
                                        k_4 = (_e408 - 4f);
                                        let _e411 = rc;
                                        let _e412 = k_4;
                                        if (_e411 >= _e412) {
                                            local_6 = vec4<f32>(0f, 0f, 0f, 1f);
                                        } else {
                                            local_6 = vec4<f32>(1f, 1f, 1f, 1f);
                                        }
                                        let _e425 = local_6;
                                        col = _e425;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        continuing {
            let _e59 = i;
            i = (_e59 + 1i);
        }
    }
    let _e426 = col;
    return _e426;
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
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e114 = squareNoise((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, _e83.x, _e87.x, mat3x3<f32>(vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z)));
    fragColor = _e114;
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
