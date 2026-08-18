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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn ghostingMerge(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, mode: f32, iterations: i32, angle: f32, source2_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var mode_1: f32;
    var iterations_1: i32;
    var angle_1: f32;
    var source2_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var color: vec4<f32>;
    var bestColor: vec4<f32>;
    var bestDist: f32 = 100f;
    var resolution: f32;
    var scale: f32;
    var dim: vec2<f32>;
    var orig: vec2<f32>;
    var scaledDim: vec2<f32>;
    var offset: vec2<f32>;
    var N: f32;
    var local: vec2<f32>;
    var step: vec2<f32>;
    var start: vec2<f32>;
    var zeroDists: i32 = 0i;
    var i: f32 = 0f;
    var pos1_: vec2<f32>;
    var ang: f32;
    var pos2_: vec2<f32>;
    var p: vec2<f32>;
    var local_1: vec4<f32>;
    var c: vec4<f32>;
    var dist: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    mode_1 = mode;
    iterations_1 = iterations;
    angle_1 = angle;
    source2_specified_1 = source2_specified;
    modelTransform_1 = modelTransform;
    let _e25 = uv_1;
    let _e29 = global.U[0];
    let _e32 = uv_1;
    let _e41 = textureSample(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    color = _e41;
    let _e43 = color;
    bestColor = _e43;
    let _e51 = modelTransform_1[0][0];
    let _e56 = modelTransform_1[0][1];
    resolution = length(vec2<f32>(_e51, _e56));
    let _e61 = resolution;
    scale = (1f / _e61);
    let _e64 = sourceDim_1;
    let _e66 = sourceDim_1;
    let _e70 = sourceDim_1;
    let _e76 = sourceDim_1;
    dim = vec2<f32>(((_e64.x / _e66.y) - (1f / _e70.y)), (1f - (1f / _e76.y)));
    let _e82 = modelTransform_1;
    orig = (_e82 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e90 = modelTransform_1;
    let _e99 = dim;
    scaledDim = (mat2x2<f32>(_e90[0].xy, _e90[1].xy) * (1f * _e99));
    let _e107 = modelTransform_1[2][0];
    let _e112 = modelTransform_1[2][1];
    let _e115 = scaledDim;
    offset = (-(vec2<f32>(_e107, _e112)) / _e115);
    let _e118 = iterations_1;
    N = f32(_e118);
    let _e121 = N;
    if (_e121 <= 1f) {
        local = vec2<f32>(0f, 0f);
    } else {
        let _e127 = angle_1;
        let _e129 = angle_1;
        let _e132 = scaledDim;
        let _e136 = N;
        local = (((vec2<f32>(cos(_e127), sin(_e129)) * _e132) * 2f) / vec2((_e136 - 1f)));
    }
    let _e142 = local;
    step = _e142;
    let _e144 = step;
    let _e146 = scaledDim;
    start = (-(_e144) * _e146);
    loop {
        let _e153 = i;
        let _e154 = N;
        if !((_e153 < _e154)) {
            break;
        }
        {
            let _e160 = uv_1;
            let _e161 = offset;
            let _e163 = start;
            let _e165 = i;
            let _e166 = step;
            pos1_ = (((_e160 + _e161) + _e163) + (_e165 * _e166));
            let _e170 = i;
            let _e171 = iterations_1;
            let _e176 = angle_1;
            ang = (((_e170 / f32(_e171)) * 6.2831855f) + _e176);
            let _e179 = uv_1;
            let _e180 = offset;
            let _e182 = ang;
            let _e184 = ang;
            let _e187 = scaledDim;
            pos2_ = ((_e179 + _e180) + (vec2<f32>(cos(_e182), sin(_e184)) * _e187));
            let _e191 = pos1_;
            let _e192 = pos2_;
            let _e193 = mode_1;
            p = mix(_e191, _e192, vec2(_e193));
            let _e197 = source2_specified_1;
            if (_e197 == 1i) {
                let _e200 = p;
                let _e204 = global.U[0];
                let _e207 = p;
                let _e216 = textureSample(t_source2_, samp, ((vec2<f32>((_e200.x / _e204.x), _e207.y) / vec2(2f)) + vec2(0.5f)));
                local_1 = _e216;
            } else {
                let _e217 = p;
                let _e221 = global.U[0];
                let _e224 = p;
                let _e233 = textureSample(t_source, samp, ((vec2<f32>((_e217.x / _e221.x), _e224.y) / vec2(2f)) + vec2(0.5f)));
                local_1 = _e233;
            }
            let _e235 = local_1;
            c = _e235;
            let _e237 = color;
            let _e238 = c;
            dist = length((_e237 - _e238));
            let _e242 = dist;
            let _e243 = bestDist;
            if (_e242 < _e243) {
                {
                    let _e245 = i;
                    let _e248 = dist;
                    let _e252 = zeroDists;
                    if (((_e245 == 0f) || (_e248 != 0f)) || (_e252 != 0i)) {
                        {
                            let _e256 = dist;
                            bestDist = _e256;
                            let _e257 = c;
                            bestColor = _e257;
                        }
                    } else {
                        let _e258 = dist;
                        if (_e258 == 0f) {
                            {
                                let _e261 = zeroDists;
                                zeroDists = (_e261 + 1i);
                            }
                        }
                    }
                }
            }
        }
        continuing {
            let _e157 = i;
            i = (_e157 + 1f);
        }
    }
    let _e264 = bestColor;
    return _e264;
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
    let _e71 = global.U[7];
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e84 = global.U[10];
    let _e88 = global.U[5];
    let _e93 = global.U[11];
    let _e94 = _e93.xyz;
    let _e97 = global.U[12];
    let _e98 = _e97.xyz;
    let _e101 = global.U[13];
    let _e102 = _e101.xyz;
    let _e116 = ghostingMerge((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy, _e71.x, _e75.x, i32(_e79.x), _e84.x, i32(_e88.x), mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
