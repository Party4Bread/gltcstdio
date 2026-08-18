struct Params {
    U: array<vec4<f32>, 18>,
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
var t_colorField: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn colorPickAliased(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, sourceDim: vec2<f32>, colorFieldDim: vec2<f32>, colorField_specified: i32, scaleX: f32, scaleY: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var colorFieldDim_1: vec2<f32>;
    var colorField_specified_1: i32;
    var scaleX_1: f32;
    var scaleY_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var p: vec2<f32>;
    var color: vec4<f32>;
    var bestColor: vec4<f32>;
    var bestDist: f32 = 100f;
    var scaleXEff: f32;
    var scaleYEff: f32;
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
    colorFieldDim_1 = colorFieldDim;
    colorField_specified_1 = colorField_specified;
    scaleX_1 = scaleX;
    scaleY_1 = scaleY;
    modelTransform_1 = modelTransform;
    let _e27 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e27);
    let _e30 = pos_1;
    p = _e30;
    let _e32 = pos_1;
    let _e36 = global.U[0];
    let _e39 = pos_1;
    let _e48 = textureSample(t_source, samp, ((vec2<f32>((_e32.x / _e36.x), _e39.y) / vec2(2f)) + vec2(0.5f)));
    color = _e48;
    let _e50 = color;
    bestColor = _e50;
    let _e55 = scaleX_1;
    scaleXEff = pow(1.1f, _e55);
    let _e59 = scaleY_1;
    scaleYEff = pow(1.1f, _e59);
    let _e62 = colorField_specified_1;
    if (_e62 != 0i) {
        let _e65 = colorFieldDim_1;
        let _e67 = colorFieldDim_1;
        let _e71 = colorFieldDim_1;
        let _e77 = colorFieldDim_1;
        local = vec2<f32>(((_e65.x / _e67.y) - (1f / _e71.y)), (1f - (1f / _e77.y)));
    } else {
        let _e82 = sourceDim_1;
        let _e84 = sourceDim_1;
        let _e88 = sourceDim_1;
        let _e94 = sourceDim_1;
        local = vec2<f32>(((_e82.x / _e84.y) - (1f / _e88.y)), (1f - (1f / _e94.y)));
    }
    let _e100 = local;
    dim = _e100;
    let _e102 = invM;
    orig = (_e102 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e110 = invM;
    let _e119 = dim;
    scaledDim = (mat2x2<f32>(_e110[0].xy, _e110[1].xy) * (2f * _e119));
    let _e123 = scaledDim;
    let _e127 = orig;
    offset = ((_e123 / vec2(2f)) - _e127);
    let _e130 = p;
    let _e131 = offset;
    let _e133 = scaledDim;
    let _e136 = scaledDim;
    let _e138 = offset;
    bottomLeft = ((floor(((_e130 + _e131) / _e133)) * _e136) - _e138);
    let _e141 = p;
    let _e142 = offset;
    let _e144 = scaledDim;
    let _e147 = scaledDim;
    let _e149 = offset;
    topRight = ((ceil(((_e141 + _e142) / _e144)) * _e147) - _e149);
    let _e156 = count_1;
    N = max(1f, (floor((f32(_e156) / 2f)) - 1f));
    loop {
        let _e167 = i;
        let _e168 = count_1;
        if !((_e167 < f32(_e168))) {
            break;
        }
        {
            let _e175 = i;
            let _e179 = N;
            d = (floor((_e175 / 2f)) / _e179);
            let _e182 = i;
            if ((_e182 - (floor((_e182 / 2f)) * 2f)) == 0f) {
                {
                    let _e190 = bottomLeft;
                    let _e192 = d;
                    let _e193 = topRight;
                    let _e195 = bottomLeft;
                    let _e200 = bottomLeft;
                    let _e202 = p;
                    let _e204 = scaleYEff;
                    let _e205 = (_e202.y * _e204);
                    let _e206 = topRight;
                    let _e208 = bottomLeft;
                    let _e210 = (_e206.y - _e208.y);
                    pp = vec2<f32>((_e190.x + (_e192 * (_e193.x - _e195.x))), (_e200.y + (_e205 - (floor((_e205 / _e210)) * _e210))));
                    let _e217 = colorField_specified_1;
                    if (_e217 != 0i) {
                        let _e220 = pp;
                        let _e224 = global.U[0];
                        let _e227 = pp;
                        let _e236 = textureSample(t_colorField, samp, ((vec2<f32>((_e220.x / _e224.x), _e227.y) / vec2(2f)) + vec2(0.5f)));
                        local_1 = _e236;
                    } else {
                        let _e237 = pp;
                        let _e241 = global.U[0];
                        let _e244 = pp;
                        let _e253 = textureSample(t_source, samp, ((vec2<f32>((_e237.x / _e241.x), _e244.y) / vec2(2f)) + vec2(0.5f)));
                        local_1 = _e253;
                    }
                    let _e255 = local_1;
                    c = _e255;
                    let _e256 = color;
                    let _e257 = c;
                    dist = length((_e256 - _e257));
                    let _e260 = dist;
                    let _e261 = bestDist;
                    if (_e260 < _e261) {
                        {
                            let _e263 = dist;
                            bestDist = _e263;
                            let _e264 = c;
                            bestColor = _e264;
                        }
                    }
                }
            } else {
                {
                    let _e265 = bottomLeft;
                    let _e267 = p;
                    let _e269 = scaleXEff;
                    let _e270 = (_e267.x * _e269);
                    let _e271 = topRight;
                    let _e273 = bottomLeft;
                    let _e275 = (_e271.x - _e273.x);
                    let _e281 = bottomLeft;
                    let _e283 = d;
                    let _e284 = topRight;
                    let _e286 = bottomLeft;
                    pp = vec2<f32>((_e265.x + (_e270 - (floor((_e270 / _e275)) * _e275))), (_e281.y + (_e283 * (_e284.y - _e286.y))));
                    let _e292 = colorField_specified_1;
                    if (_e292 != 0i) {
                        let _e295 = pp;
                        let _e299 = global.U[0];
                        let _e302 = pp;
                        let _e311 = textureSample(t_colorField, samp, ((vec2<f32>((_e295.x / _e299.x), _e302.y) / vec2(2f)) + vec2(0.5f)));
                        local_2 = _e311;
                    } else {
                        let _e312 = pp;
                        let _e316 = global.U[0];
                        let _e319 = pp;
                        let _e328 = textureSample(t_source, samp, ((vec2<f32>((_e312.x / _e316.x), _e319.y) / vec2(2f)) + vec2(0.5f)));
                        local_2 = _e328;
                    }
                    let _e330 = local_2;
                    c = _e330;
                    let _e331 = color;
                    let _e332 = c;
                    dist = length((_e331 - _e332));
                    let _e335 = dist;
                    let _e336 = bestDist;
                    if (_e335 < _e336) {
                        {
                            let _e338 = dist;
                            bestDist = _e338;
                            let _e339 = c;
                            bestColor = _e339;
                        }
                    }
                }
            }
        }
        continuing {
            let _e172 = i;
            i = (_e172 + 1f);
        }
    }
    let _e340 = color;
    let _e341 = bestColor;
    let _e342 = intensity_1;
    return mix(_e340, _e341, vec4(_e342));
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
    let _e67 = global.U[11];
    let _e71 = global.U[12];
    let _e76 = global.U[4];
    let _e80 = global.U[5];
    let _e84 = global.U[6];
    let _e89 = global.U[13];
    let _e93 = global.U[14];
    let _e97 = global.U[15];
    let _e98 = _e97.xyz;
    let _e101 = global.U[16];
    let _e102 = _e101.xyz;
    let _e105 = global.U[17];
    let _e106 = _e105.xyz;
    let _e120 = colorPickAliased((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.xy, _e80.xy, i32(_e84.x), _e89.x, _e93.x, mat3x3<f32>(vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z)));
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
