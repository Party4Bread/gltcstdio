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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn highFreqBanding(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, sourceDim: vec2<f32>, source2Dim: vec2<f32>, source2_specified: i32, scaleX: f32, scaleY: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var source2_specified_1: i32;
    var scaleX_1: f32;
    var scaleY_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var color: vec4<f32>;
    var bestColor: vec4<f32>;
    var bestDist: f32 = 1000000000f;
    var resolution: f32;
    var scale: f32;
    var p: vec2<f32>;
    var local: vec2<f32>;
    var dim: vec2<f32>;
    var orig: vec2<f32>;
    var scaledDim: vec2<f32>;
    var offset: vec2<f32>;
    var bottomLeft: vec2<f32>;
    var topRight: vec2<f32>;
    var dist: f32;
    var pp: vec2<f32>;
    var c: vec4<f32>;
    var N: f32;
    var i: f32 = 0f;
    var d: f32;
    var local_1: vec4<f32>;
    var local_2: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    sourceDim_1 = sourceDim;
    source2Dim_1 = source2Dim;
    source2_specified_1 = source2_specified;
    scaleX_1 = scaleX;
    scaleY_1 = scaleY;
    modelTransform_1 = modelTransform;
    let _e27 = pos_1;
    let _e31 = global.U[0];
    let _e34 = pos_1;
    let _e43 = textureSample(t_source, samp, ((vec2<f32>((_e27.x / _e31.x), _e34.y) / vec2(2f)) + vec2(0.5f)));
    color = _e43;
    let _e45 = color;
    bestColor = _e45;
    let _e51 = modelTransform_1[0];
    resolution = length(_e51.xy);
    let _e56 = resolution;
    scale = (1f / _e56);
    let _e59 = pos_1;
    p = _e59;
    let _e61 = source2_specified_1;
    if (_e61 != 0i) {
        let _e64 = source2Dim_1;
        let _e66 = source2Dim_1;
        let _e70 = source2Dim_1;
        let _e76 = source2Dim_1;
        local = vec2<f32>(((_e64.x / _e66.y) - (1f / _e70.y)), (1f - (1f / _e76.y)));
    } else {
        let _e81 = sourceDim_1;
        let _e83 = sourceDim_1;
        let _e87 = sourceDim_1;
        let _e93 = sourceDim_1;
        local = vec2<f32>(((_e81.x / _e83.y) - (1f / _e87.y)), (1f - (1f / _e93.y)));
    }
    let _e99 = local;
    dim = _e99;
    let _e101 = modelTransform_1;
    orig = (_e101 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e109 = modelTransform_1;
    let _e118 = dim;
    scaledDim = (mat2x2<f32>(_e109[0].xy, _e109[1].xy) * (2f * _e118));
    let _e122 = scaledDim;
    let _e126 = orig;
    offset = ((_e122 / vec2(2f)) - _e126);
    let _e129 = p;
    let _e130 = offset;
    let _e132 = scaledDim;
    let _e135 = scaledDim;
    let _e137 = offset;
    bottomLeft = ((floor(((_e129 + _e130) / _e132)) * _e135) - _e137);
    let _e140 = p;
    let _e141 = offset;
    let _e143 = scaledDim;
    let _e146 = scaledDim;
    let _e148 = offset;
    topRight = ((ceil(((_e140 + _e141) / _e143)) * _e146) - _e148);
    let _e155 = count_1;
    N = max(1f, (floor((f32(_e155) / 2f)) - 1f));
    loop {
        let _e166 = i;
        let _e167 = count_1;
        if !((_e166 < f32(_e167))) {
            break;
        }
        {
            let _e174 = i;
            let _e178 = N;
            d = (floor((_e174 / 2f)) / _e178);
            let _e181 = i;
            if ((_e181 - (floor((_e181 / 2f)) * 2f)) == 0f) {
                {
                    let _e189 = bottomLeft;
                    let _e191 = d;
                    let _e192 = topRight;
                    let _e194 = bottomLeft;
                    let _e199 = bottomLeft;
                    let _e201 = p;
                    let _e203 = scaleY_1;
                    let _e204 = (_e201.y * _e203);
                    let _e205 = topRight;
                    let _e207 = bottomLeft;
                    let _e209 = (_e205.y - _e207.y);
                    pp = vec2<f32>((_e189.x + (_e191 * (_e192.x - _e194.x))), (_e199.y + (_e204 - (floor((_e204 / _e209)) * _e209))));
                    let _e216 = source2_specified_1;
                    if (_e216 != 0i) {
                        let _e219 = pp;
                        let _e223 = global.U[0];
                        let _e226 = pp;
                        let _e235 = textureSample(t_source2_, samp, ((vec2<f32>((_e219.x / _e223.x), _e226.y) / vec2(2f)) + vec2(0.5f)));
                        local_1 = _e235;
                    } else {
                        let _e236 = pp;
                        let _e240 = global.U[0];
                        let _e243 = pp;
                        let _e252 = textureSample(t_source, samp, ((vec2<f32>((_e236.x / _e240.x), _e243.y) / vec2(2f)) + vec2(0.5f)));
                        local_1 = _e252;
                    }
                    let _e254 = local_1;
                    c = _e254;
                    let _e255 = color;
                    let _e256 = c;
                    dist = length((_e255 - _e256));
                    let _e259 = dist;
                    let _e260 = bestDist;
                    if (_e259 < _e260) {
                        {
                            let _e262 = dist;
                            bestDist = _e262;
                            let _e263 = c;
                            bestColor = _e263;
                        }
                    }
                }
            } else {
                {
                    let _e264 = bottomLeft;
                    let _e266 = p;
                    let _e268 = scaleX_1;
                    let _e269 = (_e266.x * _e268);
                    let _e270 = topRight;
                    let _e272 = bottomLeft;
                    let _e274 = (_e270.x - _e272.x);
                    let _e280 = bottomLeft;
                    let _e282 = d;
                    let _e283 = topRight;
                    let _e285 = bottomLeft;
                    pp = vec2<f32>((_e264.x + (_e269 - (floor((_e269 / _e274)) * _e274))), (_e280.y + (_e282 * (_e283.y - _e285.y))));
                    let _e291 = source2_specified_1;
                    if (_e291 != 0i) {
                        let _e294 = pp;
                        let _e298 = global.U[0];
                        let _e301 = pp;
                        let _e310 = textureSample(t_source2_, samp, ((vec2<f32>((_e294.x / _e298.x), _e301.y) / vec2(2f)) + vec2(0.5f)));
                        local_2 = _e310;
                    } else {
                        let _e311 = pp;
                        let _e315 = global.U[0];
                        let _e318 = pp;
                        let _e327 = textureSample(t_source, samp, ((vec2<f32>((_e311.x / _e315.x), _e318.y) / vec2(2f)) + vec2(0.5f)));
                        local_2 = _e327;
                    }
                    let _e329 = local_2;
                    c = _e329;
                    let _e330 = color;
                    let _e331 = c;
                    dist = length((_e330 - _e331));
                    let _e334 = dist;
                    let _e335 = bestDist;
                    if (_e334 < _e335) {
                        {
                            let _e337 = dist;
                            bestDist = _e337;
                            let _e338 = c;
                            bestColor = _e338;
                        }
                    }
                }
            }
        }
        continuing {
            let _e171 = i;
            i = (_e171 + 1f);
        }
    }
    let _e339 = color;
    let _e340 = bestColor;
    let _e341 = intensity_1;
    return mix(_e339, _e340, vec4(_e341));
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
    let _e67 = global.U[8];
    let _e71 = global.U[9];
    let _e76 = global.U[4];
    let _e80 = global.U[5];
    let _e84 = global.U[6];
    let _e89 = global.U[10];
    let _e93 = global.U[11];
    let _e97 = global.U[12];
    let _e98 = _e97.xyz;
    let _e101 = global.U[13];
    let _e102 = _e101.xyz;
    let _e105 = global.U[14];
    let _e106 = _e105.xyz;
    let _e120 = highFreqBanding((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.xy, _e80.xy, i32(_e84.x), _e89.x, _e93.x, mat3x3<f32>(vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z)));
    fragColor = _e120;
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
