struct Params {
    U: array<vec4<f32>, 11>,
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

fn bc5GetIndex(pos: vec2<f32>, blockSize: vec2<f32>, dim: vec2<f32>) -> f32 {
    var pos_1: vec2<f32>;
    var blockSize_1: vec2<f32>;
    var dim_1: vec2<f32>;
    var columns: f32;
    var lines: f32;
    var f: vec2<f32>;

    pos_1 = pos;
    blockSize_1 = blockSize;
    dim_1 = dim;
    let _e12 = dim_1;
    let _e14 = blockSize_1;
    columns = (_e12.x / _e14.x);
    let _e18 = dim_1;
    let _e20 = blockSize_1;
    lines = (_e18.y / _e20.y);
    let _e24 = pos_1;
    let _e25 = blockSize_1;
    f = floor((_e24 / _e25));
    let _e29 = f;
    let _e32 = columns;
    let _e35 = f;
    let _e38 = lines;
    let _e41 = columns;
    return ((_e29.x + (0.5f * _e32)) + ((_e35.y + (0.5f * _e38)) * _e41));
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

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k_4: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_5: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_5 = k_4;
    let _e12 = val1_1;
    let _e14 = k_5;
    let _e22 = val2_1;
    let _e25 = k_5;
    return (((_e12 * (1f + cos((_e14 * 3.1415927f)))) * 0.5f) + ((_e22 * (1f + cos(((1f - _e25) * 3.1415927f)))) * 0.5f));
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e10 = v_3;
    u00_ = floor(_e10);
    let _e13 = v_3;
    let _e16 = v_3;
    u01_ = vec2<f32>(floor(_e13.x), ceil(_e16.y));
    let _e21 = v_3;
    let _e24 = v_3;
    u10_ = vec2<f32>(ceil(_e21.x), floor(_e24.y));
    let _e29 = v_3;
    u11_ = ceil(_e29);
    let _e32 = u00_;
    let _e33 = rand2_(_e32);
    let _e34 = seed_3;
    let _e35 = varyVec2NoiseSmoothly(_e33, _e34);
    r00_ = (_e35 - vec2<f32>(0.5f, 0.5f));
    let _e41 = u01_;
    let _e42 = rand2_(_e41);
    let _e43 = seed_3;
    let _e44 = varyVec2NoiseSmoothly(_e42, _e43);
    r01_ = (_e44 - vec2<f32>(0.5f, 0.5f));
    let _e50 = u10_;
    let _e51 = rand2_(_e50);
    let _e52 = seed_3;
    let _e53 = varyVec2NoiseSmoothly(_e51, _e52);
    r10_ = (_e53 - vec2<f32>(0.5f, 0.5f));
    let _e59 = u11_;
    let _e60 = rand2_(_e59);
    let _e61 = seed_3;
    let _e62 = varyVec2NoiseSmoothly(_e60, _e61);
    r11_ = (_e62 - vec2<f32>(0.5f, 0.5f));
    let _e68 = r00_;
    let _e69 = r01_;
    let _e70 = v_3;
    let _e73 = sineMix(_e68, _e69, fract(_e70.y));
    let _e74 = r10_;
    let _e75 = r11_;
    let _e76 = v_3;
    let _e79 = sineMix(_e74, _e75, fract(_e76.y));
    let _e80 = v_3;
    let _e83 = sineMix(_e73, _e79, fract(_e80.x));
    return _e83;
}

fn blockCorrupt5_(pos_2: vec2<f32>, outPos: vec2<f32>, count: i32, randomSeed: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var randomSeed_1: f32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var inCol: vec4<f32>;
    var outCol: vec4<f32>;
    var ratio: f32;
    var dim_2: vec2<f32>;
    var blockSize_2: vec2<f32>;
    var columns_1: f32;
    var lines_1: f32;
    var blocks: f32;
    var index: f32;
    var offset: f32;
    var scale: f32;
    var i: i32 = 0i;
    var rnd: vec2<f32>;
    var center: f32;
    var local: f32;
    var bSize: f32;
    var ind1_: f32;
    var ind2_: f32;
    var inside: bool;
    var subMode: f32;
    var g: f32;
    var local_1: f32;
    var local_2: f32;
    var local_3: f32;
    var local_4: f32;
    var local_5: f32;
    var local_6: f32;
    var local_7: f32;
    var local_8: f32;
    var local_9: f32;
    var local_10: f32;
    var local_11: f32;

    pos_3 = pos_2;
    outPos_1 = outPos;
    count_1 = count;
    randomSeed_1 = randomSeed;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e18 = pos_3;
    let _e22 = global.U[0];
    let _e25 = pos_3;
    let _e34 = textureSample(t_source, samp, ((vec2<f32>((_e18.x / _e22.x), _e25.y) / vec2(2f)) + vec2(0.5f)));
    inCol = _e34;
    let _e36 = inCol;
    outCol = _e36;
    let _e38 = sourceDim_1;
    let _e40 = sourceDim_1;
    ratio = (_e38.x / _e40.y);
    let _e45 = ratio;
    dim_2 = vec2<f32>((2f * _e45), 2f);
    let _e50 = dim_2;
    blockSize_2 = (_e50 / vec2<f32>(160f, 80f));
    let _e56 = dim_2;
    let _e58 = blockSize_2;
    columns_1 = (_e56.x / _e58.x);
    let _e62 = dim_2;
    let _e64 = blockSize_2;
    lines_1 = (_e62.y / _e64.y);
    let _e68 = columns_1;
    let _e69 = lines_1;
    blocks = (_e68 * _e69);
    let _e72 = pos_3;
    let _e73 = blockSize_2;
    let _e74 = dim_2;
    let _e75 = bc5GetIndex(_e72, _e73, _e74);
    index = _e75;
    let _e81 = modelTransform_1[2][0];
    let _e84 = columns_1;
    let _e90 = modelTransform_1[2][1];
    let _e93 = lines_1;
    let _e95 = columns_1;
    let _e99 = blocks;
    offset = ((((_e81 * 0.5f) * _e84) + (((_e90 * 0.5f) * _e93) * _e95)) + (0.5f * _e99));
    let _e107 = modelTransform_1[0][0];
    let _e112 = modelTransform_1[0][1];
    scale = length(vec2<f32>(_e107, _e112));
    loop {
        let _e118 = i;
        let _e119 = count_1;
        if !((_e118 < _e119)) {
            break;
        }
        {
            let _e126 = i;
            let _e131 = i;
            let _e136 = randomSeed_1;
            let _e139 = sineSurfaceRand2Seeded(vec2<f32>((10f - f32(_e126)), (15f + (5f * f32(_e131)))), (_e136 + 4.46f));
            rnd = _e139;
            let _e141 = offset;
            let _e142 = rnd;
            let _e144 = blocks;
            center = (_e141 + (_e142.x * _e144));
            let _e148 = rnd;
            let _e152 = i;
            if (_e148.x < (-0.5f + (f32(_e152) * 0.1f))) {
                local = 0.5f;
            } else {
                let _e159 = rnd;
                let _e162 = blocks;
                let _e164 = scale;
                local = ((abs(_e159.y) * _e162) * _e164);
            }
            let _e167 = local;
            bSize = _e167;
            let _e169 = center;
            let _e170 = bSize;
            ind1_ = (_e169 - _e170);
            let _e173 = center;
            let _e174 = bSize;
            ind2_ = (_e173 + _e174);
            let _e177 = index;
            let _e178 = ind1_;
            let _e180 = index;
            let _e181 = ind2_;
            inside = ((_e177 >= _e178) && (_e180 <= _e181));
            let _e185 = inside;
            if _e185 {
                {
                    let _e186 = rnd;
                    let _e189 = (_e186.x * 15f);
                    subMode = floor((_e189 - (floor((_e189 / 9f)) * 9f)));
                    g = 0f;
                    let _e199 = subMode;
                    if (_e199 == 0f) {
                        {
                            let _e202 = pos_3;
                            let _e206 = randomSeed_1;
                            let _e207 = rand2relSeeded(floor((_e202 * 320f)), _e206);
                            if (fract(_e207.x) > 0.5f) {
                                local_1 = 1f;
                            } else {
                                local_1 = 0f;
                            }
                            let _e215 = local_1;
                            g = _e215;
                        }
                    } else {
                        let _e216 = subMode;
                        if (_e216 == 1f) {
                            {
                                let _e219 = pos_3;
                                let _e223 = randomSeed_1;
                                let _e224 = rand2relSeeded(floor((_e219 * 160f)), _e223);
                                if (fract(_e224.x) > 0.5f) {
                                    local_2 = 1f;
                                } else {
                                    local_2 = 0f;
                                }
                                let _e232 = local_2;
                                g = _e232;
                            }
                        } else {
                            let _e233 = subMode;
                            if (_e233 == 2f) {
                                {
                                    let _e236 = pos_3;
                                    if (fract((_e236.x * 40f)) > 0.5f) {
                                        local_3 = 1f;
                                    } else {
                                        local_3 = 0f;
                                    }
                                    let _e246 = local_3;
                                    g = _e246;
                                }
                            } else {
                                let _e247 = subMode;
                                if (_e247 == 3f) {
                                    {
                                        let _e250 = pos_3;
                                        if (fract((_e250.x * 80f)) > 0.5f) {
                                            local_4 = 1f;
                                        } else {
                                            local_4 = 0f;
                                        }
                                        let _e260 = local_4;
                                        g = _e260;
                                    }
                                } else {
                                    let _e261 = subMode;
                                    if (_e261 == 6f) {
                                        {
                                            let _e264 = pos_3;
                                            let _e269 = inCol;
                                            if (fract((_e264.x * 80f)) > (length(_e269.xyz) / 1.7f)) {
                                                local_5 = 1f;
                                            } else {
                                                local_5 = 0f;
                                            }
                                            let _e278 = local_5;
                                            g = _e278;
                                        }
                                    } else {
                                        let _e279 = subMode;
                                        if (_e279 == 7f) {
                                            {
                                                let _e282 = pos_3;
                                                let _e287 = inCol;
                                                if (fract((_e282.x * 10f)) < (length(_e287.xyz) / 1.7f)) {
                                                    local_6 = 1f;
                                                } else {
                                                    local_6 = 0f;
                                                }
                                                let _e296 = local_6;
                                                g = _e296;
                                            }
                                        } else {
                                            let _e297 = subMode;
                                            if (_e297 == 4f) {
                                                {
                                                    let _e300 = pos_3;
                                                    if (fract((_e300.x * 80f)) > 0.5f) {
                                                        local_7 = 1f;
                                                    } else {
                                                        local_7 = 0f;
                                                    }
                                                    let _e310 = local_7;
                                                    let _e311 = pos_3;
                                                    if (fract((_e311.y * 40f)) > 0.5f) {
                                                        local_8 = 1f;
                                                    } else {
                                                        local_8 = 0f;
                                                    }
                                                    let _e321 = local_8;
                                                    let _e322 = (_e310 + _e321);
                                                    g = (_e322 - (floor((_e322 / 2f)) * 2f));
                                                }
                                            } else {
                                                let _e328 = subMode;
                                                if (_e328 == 5f) {
                                                    {
                                                        let _e331 = pos_3;
                                                        let _e335 = randomSeed_1;
                                                        let _e336 = rand2relSeeded(floor((_e331 * 160f)), _e335);
                                                        let _e339 = inCol;
                                                        if (fract(_e336.x) < (length(_e339.xyz) / 1.7f)) {
                                                            local_9 = 1f;
                                                        } else {
                                                            local_9 = 0f;
                                                        }
                                                        let _e348 = local_9;
                                                        g = _e348;
                                                    }
                                                } else {
                                                    {
                                                        let _e349 = pos_3;
                                                        if (fract((_e349.x * 40f)) > 0.5f) {
                                                            local_10 = 1f;
                                                        } else {
                                                            local_10 = 0f;
                                                        }
                                                        let _e359 = local_10;
                                                        let _e360 = pos_3;
                                                        if (fract((_e360.y * 20f)) > 0.5f) {
                                                            local_11 = 1f;
                                                        } else {
                                                            local_11 = 0f;
                                                        }
                                                        let _e370 = local_11;
                                                        let _e371 = (_e359 + _e370);
                                                        g = (_e371 - (floor((_e371 / 2f)) * 2f));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    let _e377 = g;
                    let _e378 = g;
                    let _e379 = g;
                    outCol = vec4<f32>(_e377, _e378, _e379, 1f);
                    let _e382 = outCol;
                    return _e382;
                }
            }
        }
        continuing {
            let _e122 = i;
            i = (_e122 + 1i);
        }
    }
    let _e383 = inCol;
    return _e383;
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
    let _e71 = global.U[7];
    let _e75 = global.U[4];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = blockCorrupt5_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.xy, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
