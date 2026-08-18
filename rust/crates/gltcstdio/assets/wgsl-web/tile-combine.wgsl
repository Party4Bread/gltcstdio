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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn tileCombine(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, thickness: f32, colorBorder: vec4<f32>, source1Dim: vec2<f32>, source2Dim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var thickness_1: f32;
    var colorBorder_1: vec4<f32>;
    var source1Dim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var id: f32;
    var y: f32;
    var ratio1_: f32;
    var ratio: f32;
    var x: f32;
    var b: f32;
    var ratio1_1: f32;
    var ratio_1: f32;
    var x_1: f32;
    var b_1: f32;
    var id_1: f32;
    var x_2: f32;
    var id_2: vec2<f32>;
    var u: vec2<f32>;
    var b_2: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    thickness_1 = thickness;
    colorBorder_1 = colorBorder;
    source1Dim_1 = source1Dim;
    source2Dim_1 = source2Dim;
    modelTransform_1 = modelTransform;
    let _e23 = mode_1;
    if (_e23 == 0i) {
        {
            let _e26 = uv_1;
            id = round((_e26.y * 0.5f));
            let _e32 = uv_1;
            let _e35 = (_e32.y + 1f);
            y = ((_e35 - (floor((_e35 / 2f)) * 2f)) - 1f);
            let _e44 = id;
            if ((_e44 - (floor((_e44 / 2f)) * 2f)) == 0f) {
                {
                    let _e52 = source1Dim_1;
                    let _e54 = source1Dim_1;
                    ratio1_ = (_e52.x / _e54.y);
                    let _e58 = ratio1_;
                    let _e59 = thickness_1;
                    let _e62 = thickness_1;
                    ratio = ((_e58 + _e59) / (1f + _e62));
                    let _e66 = uv_1;
                    let _e68 = ratio;
                    let _e69 = (_e66.x + _e68);
                    let _e71 = ratio;
                    let _e72 = (2f * _e71);
                    let _e77 = ratio;
                    x = ((_e69 - (floor((_e69 / _e72)) * _e72)) - _e77);
                    let _e82 = thickness_1;
                    b = (1f / (1f + _e82));
                    let _e86 = x;
                    let _e88 = ratio;
                    let _e91 = b;
                    let _e94 = y;
                    let _e96 = b;
                    if ((abs(_e86) > ((_e88 - 1f) + _e91)) || (abs(_e94) > _e96)) {
                        let _e99 = colorBorder_1;
                        return _e99;
                    }
                    let _e100 = x;
                    let _e101 = y;
                    let _e103 = b;
                    let _e109 = global.U[0];
                    let _e112 = x;
                    let _e113 = y;
                    let _e115 = b;
                    let _e127 = textureSampleLevel(t_source1_, samp, ((vec2<f32>(((vec2<f32>(_e100, _e101) / vec2(_e103)).x / _e109.x), (vec2<f32>(_e112, _e113) / vec2(_e115)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e127;
                }
            } else {
                {
                    let _e128 = source2Dim_1;
                    let _e130 = source2Dim_1;
                    ratio1_1 = (_e128.x / _e130.y);
                    let _e134 = ratio1_1;
                    let _e135 = thickness_1;
                    let _e138 = thickness_1;
                    ratio_1 = ((_e134 + _e135) / (1f + _e138));
                    let _e142 = uv_1;
                    let _e144 = ratio_1;
                    let _e145 = (_e142.x + _e144);
                    let _e147 = ratio_1;
                    let _e148 = (2f * _e147);
                    let _e153 = ratio_1;
                    x_1 = ((_e145 - (floor((_e145 / _e148)) * _e148)) - _e153);
                    let _e158 = thickness_1;
                    b_1 = (1f / (1f + _e158));
                    let _e162 = x_1;
                    let _e164 = ratio_1;
                    let _e167 = b_1;
                    let _e170 = y;
                    let _e172 = b_1;
                    if ((abs(_e162) > ((_e164 - 1f) + _e167)) || (abs(_e170) > _e172)) {
                        let _e175 = colorBorder_1;
                        return _e175;
                    }
                    let _e176 = x_1;
                    let _e177 = y;
                    let _e179 = b_1;
                    let _e185 = global.U[0];
                    let _e188 = x_1;
                    let _e189 = y;
                    let _e191 = b_1;
                    let _e203 = textureSampleLevel(t_source2_, samp, ((vec2<f32>(((vec2<f32>(_e176, _e177) / vec2(_e179)).x / _e185.x), (vec2<f32>(_e188, _e189) / vec2(_e191)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e203;
                }
            }
        }
    } else {
        let _e204 = mode_1;
        if (_e204 == 1i) {
            {
                let _e207 = uv_1;
                id_1 = round((_e207.x * 0.5f));
                let _e213 = uv_1;
                let _e216 = (_e213.x + 1f);
                x_2 = ((_e216 - (floor((_e216 / 2f)) * 2f)) - 1f);
                let _e225 = id_1;
                if ((_e225 - (floor((_e225 / 2f)) * 2f)) == 0f) {
                    let _e233 = x_2;
                    let _e234 = uv_1;
                    let _e237 = source1Dim_1;
                    let _e240 = source1Dim_1;
                    let _e247 = global.U[0];
                    let _e250 = x_2;
                    let _e251 = uv_1;
                    let _e254 = source1Dim_1;
                    let _e257 = source1Dim_1;
                    let _e270 = textureSampleLevel(t_source1_, samp, ((vec2<f32>((((vec2<f32>(_e233, _e234.y) * _e237.x) / vec2(_e240.y)).x / _e247.x), ((vec2<f32>(_e250, _e251.y) * _e254.x) / vec2(_e257.y)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e270;
                } else {
                    let _e271 = x_2;
                    let _e272 = uv_1;
                    let _e275 = source2Dim_1;
                    let _e278 = source2Dim_1;
                    let _e285 = global.U[0];
                    let _e288 = x_2;
                    let _e289 = uv_1;
                    let _e292 = source2Dim_1;
                    let _e295 = source2Dim_1;
                    let _e308 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((((vec2<f32>(_e271, _e272.y) * _e275.x) / vec2(_e278.y)).x / _e285.x), ((vec2<f32>(_e288, _e289.y) * _e292.x) / vec2(_e295.y)).y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e308;
                }
            }
        } else {
            {
                let _e309 = uv_1;
                id_2 = round((_e309 * 0.5f));
                let _e314 = uv_1;
                let _e317 = (_e314 + vec2(1f));
                let _e319 = vec2(2f);
                u = ((_e317 - (floor((_e317 / _e319)) * _e319)) - vec2(1f));
                let _e329 = thickness_1;
                b_2 = (1f - _e329);
                let _e332 = u;
                let _e335 = b_2;
                let _e337 = u;
                let _e340 = b_2;
                if ((abs(_e332.x) > _e335) || (abs(_e337.y) > _e340)) {
                    let _e343 = colorBorder_1;
                    return _e343;
                }
                let _e344 = u;
                let _e345 = b_2;
                u = (_e344 / vec2(_e345));
                let _e348 = id_2;
                let _e350 = id_2;
                let _e352 = (_e348.x + _e350.y);
                if ((_e352 - (floor((_e352 / 2f)) * 2f)) == 0f) {
                    let _e360 = u;
                    let _e364 = global.U[0];
                    let _e367 = u;
                    let _e377 = textureSampleLevel(t_source1_, samp, ((vec2<f32>((_e360.x / _e364.x), _e367.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e377;
                } else {
                    let _e378 = u;
                    let _e382 = global.U[0];
                    let _e385 = u;
                    let _e395 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e378.x / _e382.x), _e385.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    return _e395;
                }
            }
        }
    }
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
    let _e67 = global.U[7];
    let _e72 = global.U[8];
    let _e76 = global.U[9];
    let _e79 = global.U[4];
    let _e83 = global.U[5];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = tileCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76, _e79.xy, _e83.xy, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
