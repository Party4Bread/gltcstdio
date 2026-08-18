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
    let _e41 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e31.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e41;
    let _e45 = count_1;
    N = _e45;
    let _e47 = coverage_1;
    noiseSize = (_e47 * 0.5f);
    let _e51 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e51);
    loop {
        let _e56 = i;
        let _e57 = N;
        if !((_e56 < _e57)) {
            break;
        }
        {
            let _e63 = N;
            if (_e63 <= 1i) {
                local = 1f;
            } else {
                let _e67 = depth_1;
                let _e70 = i;
                let _e73 = N;
                local = pow(_e67, (1f - ((2f * f32(_e70)) / f32((_e73 - 1i)))));
            }
            let _e81 = local;
            s = _e81;
            let _e83 = invModelTransform;
            let _e84 = s;
            let _e88 = s;
            let _e98 = uv_1;
            u = ((_e83 * mat3x3<f32>(vec3<f32>(_e84, 0f, 0f), vec3<f32>(0f, _e88, 0f), vec3<f32>(0f, 0f, 1f))) * vec3<f32>(_e98.x, _e98.y, 1f)).xy;
            let _e106 = u;
            id = round(_e106);
            let _e109 = u;
            let _e110 = id;
            v_2 = (_e109 - _e110);
            let _e113 = id;
            let _e114 = i;
            let _e122 = randomSeed_1;
            let _e123 = rand2relSeeded((_e113 + (f32(_e114) * vec2<f32>(4.43f, -5.434f))), _e122);
            rnd = _e123;
            let _e125 = rnd;
            let _e127 = rnd;
            let _e133 = variability_1;
            if (abs((_e125.x - _e127.y)) > (1f - (0.75f * _e133))) {
                let _e137 = id;
                let _e141 = i;
                let _e149 = randomSeed_1;
                let _e150 = rand2relSeeded((floor((_e137 * 0.25f)) + (f32(_e141) * vec2<f32>(4.43f, -5.434f))), _e149);
                rnd = _e150;
            }
            let _e151 = rnd;
            let _e153 = rnd;
            let _e159 = variability_1;
            if (abs((_e151.x - _e153.y)) > (1f - (0.75f * _e159))) {
                let _e163 = id;
                let _e167 = i;
                let _e175 = randomSeed_1;
                let _e176 = rand2relSeeded((floor((_e163 * 0.0625f)) + (f32(_e167) * vec2<f32>(4.43f, -5.434f))), _e175);
                rnd = _e176;
            }
            let _e177 = rnd;
            let _e184 = variability_1;
            hide = (fract((_e177.x * 10f)) > (1f - (0.5f * _e184)));
            let _e189 = rnd;
            let _e196 = variability_1;
            if (fract((_e189.x * 20f)) > (1f - (0.25f * _e196))) {
                let _e200 = v_2;
                v_2 = abs((_e200 - vec2(0.12f)));
            }
            let _e205 = variability_1;
            if (_e205 < 0.01f) {
                let _e208 = v_2;
                local_1 = _e208;
            } else {
                let _e209 = v_2;
                let _e210 = rnd;
                let _e212 = rnd;
                let _e215 = variability_1;
                let _e218 = rnd;
                let _e221 = variability_1;
                local_1 = (_e209 + (sign(_e210) * vec2<f32>(pow(_e212.x, (1f / _e215)), pow(_e218.y, (1f / _e221)))));
            }
            let _e228 = local_1;
            center = _e228;
            let _e230 = noiseSize;
            let _e232 = variability_1;
            let _e233 = rnd;
            nSize = (_e230 * pow(4f, (_e232 * (fract((_e233.y * 10f)) - 0.5f))));
            let _e244 = hide;
            let _e246 = center;
            let _e249 = nSize;
            let _e252 = center;
            let _e255 = nSize;
            if ((!(_e244) && (abs(_e246.x) < _e249)) && (abs(_e252.y) < _e255)) {
                {
                    let _e258 = colorScheme_1;
                    k_4 = (_e258 * 5f);
                    let _e264 = rnd;
                    rc = fract(((_e264.y * 10f) + 0.33f));
                    let _e272 = colorScheme_1;
                    if (_e272 < 0.2f) {
                        {
                            let _e275 = rc;
                            let _e276 = k_4;
                            if (_e275 >= _e276) {
                                local_2 = vec4<f32>(0f, 0f, 0f, 1f);
                            } else {
                                local_2 = vec4<f32>(1f, 1f, 1f, 1f);
                            }
                            let _e289 = local_2;
                            col = _e289;
                        }
                    } else {
                        let _e290 = colorScheme_1;
                        if (_e290 < 0.4f) {
                            {
                                let _e293 = k_4;
                                k_4 = (_e293 - 1f);
                                let _e296 = rc;
                                let _e297 = k_4;
                                if (_e296 >= _e297) {
                                    local_3 = vec4<f32>(1f, 1f, 1f, 1f);
                                } else {
                                    let _e304 = u;
                                    let _e308 = global.U[0];
                                    let _e311 = u;
                                    let _e321 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e304.x / _e308.x), _e311.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                    local_3 = _e321;
                                }
                                let _e323 = local_3;
                                col = _e323;
                            }
                        } else {
                            let _e324 = colorScheme_1;
                            if (_e324 < 0.6f) {
                                {
                                    let _e327 = k_4;
                                    k_4 = (_e327 - 2f);
                                    let _e330 = rc;
                                    let _e331 = k_4;
                                    if (_e330 >= _e331) {
                                        let _e333 = u;
                                        let _e337 = global.U[0];
                                        let _e340 = u;
                                        let _e350 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e333.x / _e337.x), _e340.y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        local_4 = _e350;
                                    } else {
                                        let _e351 = id;
                                        let _e357 = global.U[0];
                                        let _e360 = id;
                                        let _e372 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e351 * 0.731344f).x / _e357.x), (_e360 * 0.731344f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                        local_4 = _e372;
                                    }
                                    let _e374 = local_4;
                                    col = _e374;
                                }
                            } else {
                                let _e375 = colorScheme_1;
                                if (_e375 < 0.8f) {
                                    {
                                        let _e378 = k_4;
                                        k_4 = (_e378 - 3f);
                                        let _e381 = rc;
                                        let _e382 = k_4;
                                        if (_e381 >= _e382) {
                                            let _e384 = id;
                                            let _e390 = global.U[0];
                                            let _e393 = id;
                                            let _e405 = textureSampleLevel(t_source, samp, ((vec2<f32>(((_e384 * 0.731344f).x / _e390.x), (_e393 * 0.731344f).y) / vec2(2f)) + vec2(0.5f)), 0f);
                                            local_5 = _e405;
                                        } else {
                                            local_5 = vec4<f32>(0f, 0f, 0f, 1f);
                                        }
                                        let _e412 = local_5;
                                        col = _e412;
                                    }
                                } else {
                                    {
                                        let _e413 = k_4;
                                        k_4 = (_e413 - 4f);
                                        let _e416 = rc;
                                        let _e417 = k_4;
                                        if (_e416 >= _e417) {
                                            local_6 = vec4<f32>(0f, 0f, 0f, 1f);
                                        } else {
                                            local_6 = vec4<f32>(1f, 1f, 1f, 1f);
                                        }
                                        let _e430 = local_6;
                                        col = _e430;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        continuing {
            let _e60 = i;
            i = (_e60 + 1i);
        }
    }
    let _e431 = col;
    return _e431;
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
