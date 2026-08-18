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
var t_palette: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn pdg_withBias(x: f32, b: f32) -> f32 {
    var x_1: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_1 = x;
    b_1 = b;
    let _e11 = b_1;
    s = sign(_e11);
    let _e14 = b_1;
    ab = abs(_e14);
    let _e17 = x_1;
    let _e21 = s;
    let _e23 = ab;
    return (pow((_e17 + 0.5f), pow(2f, (-(_e21) * _e23))) - 0.5f);
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_2: f32;
    var y: f32;

    v_1 = v;
    let _e9 = v_1;
    x_2 = fract((sin(dot(_e9.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e20 = x_2;
    let _e21 = v_1;
    y = fract((sin(dot(vec2<f32>(_e20, _e21.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e33 = x_2;
    let _e34 = y;
    return vec2<f32>(_e33, _e34);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e12 = noise_1;
    phase = acos(((2f * _e12) - 1f));
    let _e18 = noise_1;
    freq = (fract((_e18 * 16f)) + 0.5f);
    let _e26 = phase;
    let _e27 = freq;
    let _e28 = k_1;
    return ((1f + cos((_e26 + (_e27 * _e28)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e11 = noise_3;
    let _e13 = k_3;
    let _e14 = varyNoiseSmoothly(_e11.x, _e13);
    let _e15 = noise_3;
    let _e17 = k_3;
    let _e18 = varyNoiseSmoothly(_e15.y, _e17);
    return vec2<f32>(_e14, _e18);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e11 = co_1;
    let _e12 = rand2_(_e11);
    let _e13 = seed_1;
    let _e14 = varyVec2NoiseSmoothly(_e12, _e13);
    return (_e14 - vec2(0.5f));
}

fn pixelateDichotomic(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>, randomSeed: f32, regularity: f32, thickness: f32, color1_: vec4<f32>, paletteDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var randomSeed_1: f32;
    var regularity_1: f32;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var paletteDim_1: vec2<f32>;
    var ratio: f32;
    var pixel: f32;
    var rect: vec4<f32>;
    var horSplit: bool = true;
    var border: bool = false;
    var splits: vec2<f32> = vec2<f32>(0f, 0f);
    var bias: vec2<f32>;
    var maxSplits: f32;
    var regularityScaled: f32;
    var variability: f32;
    var thicknessShader: f32;
    var i: i32 = 0i;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var Y: f32;
    var X: f32;
    var col: vec4<f32>;
    var outCol: vec4<f32>;
    var n: i32;
    var doQuantize: bool;
    var minDist: f32 = 1000000000f;
    var bestColor: vec4<f32>;
    var i_1: i32 = 0i;
    var target_: vec4<f32>;
    var dist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    randomSeed_1 = randomSeed;
    regularity_1 = regularity;
    thickness_1 = thickness;
    color1_1 = color1_;
    paletteDim_1 = paletteDim;
    let _e25 = sourceDim_1;
    let _e27 = sourceDim_1;
    ratio = (floor((((_e25.x / _e27.y) * 100f) + 0.5f)) * 0.01f);
    let _e39 = sourceDim_1;
    pixel = (2f / _e39.y);
    let _e43 = ratio;
    let _e47 = ratio;
    rect = vec4<f32>(-(_e43), -1f, _e47, 1f);
    let _e59 = modelTransform_1;
    bias = (_e59 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e72 = modelTransform_1[0][0];
    let _e77 = modelTransform_1[0][1];
    maxSplits = (1f / length(vec2<f32>(_e72, _e77)));
    let _e82 = regularity_1;
    regularityScaled = (_e82 * 2f);
    let _e88 = regularityScaled;
    variability = (1f - max(0f, (_e88 - 1f)));
    let _e94 = thickness_1;
    let _e95 = thickness_1;
    thicknessShader = ((_e94 * _e95) * 0.1f);
    loop {
        let _e102 = i;
        if !((_e102 < 100i)) {
            break;
        }
        {
            let _e109 = i;
            let _e111 = maxSplits;
            if (f32(_e109) >= _e111) {
                break;
            }
            let _e113 = splits;
            let _e114 = randomSeed_1;
            let _e117 = rand2relSeeded(_e113, (_e114 + 122.1f));
            rnd = _e117;
            let _e119 = rect;
            let _e121 = rect;
            size = (_e119.zw - _e121.xy);
            let _e125 = size;
            let _e127 = pixel;
            let _e129 = size;
            let _e131 = pixel;
            if ((_e125.x < _e127) || (_e129.y < _e131)) {
                break;
            }
            let _e134 = rnd;
            let _e138 = regularityScaled;
            if ((_e134.x + 0.5f) < _e138) {
                let _e140 = size;
                let _e142 = size;
                horSplit = (_e140.y > _e142.x);
            }
            let _e145 = horSplit;
            if _e145 {
                {
                    let _e146 = rect;
                    let _e148 = rect;
                    let _e150 = variability;
                    let _e151 = rnd;
                    let _e153 = bias;
                    let _e155 = pdg_withBias(_e151.y, _e153.y);
                    Y = mix(_e146.y, _e148.w, ((_e150 * _e155) + 0.5f));
                    let _e161 = Y;
                    let _e162 = pos_1;
                    let _e166 = thicknessShader;
                    if (abs((_e161 - _e162.y)) < _e166) {
                        {
                            border = true;
                            break;
                        }
                    }
                    let _e169 = pos_1;
                    let _e171 = Y;
                    if (_e169.y < _e171) {
                        {
                            let _e174 = Y;
                            rect.w = _e174;
                            let _e176 = splits;
                            splits.y = (_e176.y + 1f);
                        }
                    } else {
                        {
                            let _e181 = Y;
                            rect.y = _e181;
                            let _e183 = splits;
                            splits.y = (_e183.y + 100f);
                        }
                    }
                }
            } else {
                {
                    let _e187 = rect;
                    let _e189 = rect;
                    let _e191 = variability;
                    let _e192 = rnd;
                    let _e194 = bias;
                    let _e196 = pdg_withBias(_e192.x, _e194.x);
                    X = mix(_e187.x, _e189.z, ((_e191 * _e196) + 0.5f));
                    let _e202 = X;
                    let _e203 = pos_1;
                    let _e207 = thicknessShader;
                    if (abs((_e202 - _e203.x)) < _e207) {
                        {
                            border = true;
                            break;
                        }
                    }
                    let _e210 = pos_1;
                    let _e212 = X;
                    if (_e210.x < _e212) {
                        {
                            let _e215 = X;
                            rect.z = _e215;
                            let _e217 = splits;
                            splits.x = (_e217.x + 1f);
                        }
                    } else {
                        {
                            let _e222 = X;
                            rect.x = _e222;
                            let _e224 = splits;
                            splits.x = (_e224.x + 100f);
                        }
                    }
                }
            }
            let _e228 = horSplit;
            horSplit = !(_e228);
            let _e230 = bias;
            bias = (_e230 * 0.5f);
        }
        continuing {
            let _e106 = i;
            i = (_e106 + 1i);
        }
    }
    let _e233 = pos_1;
    let _e237 = global.U[0];
    let _e240 = pos_1;
    let _e249 = textureSample(t_source, samp, ((vec2<f32>((_e233.x / _e237.x), _e240.y) / vec2(2f)) + vec2(0.5f)));
    col = _e249;
    let _e252 = border;
    if _e252 {
        {
            let _e253 = col;
            let _e255 = color1_1;
            let _e257 = color1_1;
            let _e260 = mix(_e253.xyz, _e255.xyz, vec3(_e257.w));
            let _e261 = col;
            outCol = vec4<f32>(_e260.x, _e260.y, _e260.z, _e261.w);
        }
    } else {
        {
            let _e267 = rect;
            let _e269 = rect;
            let _e277 = global.U[0];
            let _e280 = rect;
            let _e282 = rect;
            let _e295 = textureSample(t_source, samp, ((vec2<f32>((((_e267.xy + _e269.zw) * 0.5f).x / _e277.x), ((_e280.xy + _e282.zw) * 0.5f).y) / vec2(2f)) + vec2(0.5f)));
            outCol = _e295;
            let _e296 = paletteDim_1;
            n = i32(_e296.x);
            let _e300 = n;
            doQuantize = (_e300 > 1i);
            let _e304 = n;
            if (_e304 == 1i) {
                let _e311 = textureLoad(t_palette, vec2<i32>(0i, 0i), 0i);
                doQuantize = (_e311.w > 0.5f);
            }
            let _e315 = doQuantize;
            if _e315 {
                {
                    let _e318 = outCol;
                    bestColor = _e318;
                    loop {
                        let _e322 = i_1;
                        let _e323 = n;
                        if !((_e322 < _e323)) {
                            break;
                        }
                        {
                            let _e329 = i_1;
                            let _e333 = textureLoad(t_palette, vec2<i32>(_e329, 0i), 0i);
                            target_ = _e333;
                            let _e335 = outCol;
                            let _e336 = target_;
                            dist = length((_e335 - _e336));
                            let _e340 = dist;
                            let _e341 = minDist;
                            if (_e340 < _e341) {
                                {
                                    let _e343 = dist;
                                    minDist = _e343;
                                    let _e344 = target_;
                                    bestColor = _e344;
                                }
                            }
                        }
                        continuing {
                            let _e326 = i_1;
                            i_1 = (_e326 + 1i);
                        }
                    }
                    let _e345 = bestColor;
                    outCol = _e345;
                }
            }
        }
    }
    let _e346 = outCol;
    return _e346;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e71 = global.U[8];
    let _e72 = _e71.xyz;
    let _e75 = global.U[9];
    let _e76 = _e75.xyz;
    let _e79 = global.U[10];
    let _e80 = _e79.xyz;
    let _e96 = global.U[11];
    let _e100 = global.U[12];
    let _e104 = global.U[13];
    let _e108 = global.U[14];
    let _e111 = global.U[5];
    let _e113 = pixelateDichotomic((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x, _e104.x, _e108, _e111.xy);
    fragColor = _e113;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
