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
                    let _e126 = textureSample(t_source1_, samp, ((vec2<f32>(((vec2<f32>(_e100, _e101) / vec2(_e103)).x / _e109.x), (vec2<f32>(_e112, _e113) / vec2(_e115)).y) / vec2(2f)) + vec2(0.5f)));
                    return _e126;
                }
            } else {
                {
                    let _e127 = source2Dim_1;
                    let _e129 = source2Dim_1;
                    ratio1_1 = (_e127.x / _e129.y);
                    let _e133 = ratio1_1;
                    let _e134 = thickness_1;
                    let _e137 = thickness_1;
                    ratio_1 = ((_e133 + _e134) / (1f + _e137));
                    let _e141 = uv_1;
                    let _e143 = ratio_1;
                    let _e144 = (_e141.x + _e143);
                    let _e146 = ratio_1;
                    let _e147 = (2f * _e146);
                    let _e152 = ratio_1;
                    x_1 = ((_e144 - (floor((_e144 / _e147)) * _e147)) - _e152);
                    let _e157 = thickness_1;
                    b_1 = (1f / (1f + _e157));
                    let _e161 = x_1;
                    let _e163 = ratio_1;
                    let _e166 = b_1;
                    let _e169 = y;
                    let _e171 = b_1;
                    if ((abs(_e161) > ((_e163 - 1f) + _e166)) || (abs(_e169) > _e171)) {
                        let _e174 = colorBorder_1;
                        return _e174;
                    }
                    let _e175 = x_1;
                    let _e176 = y;
                    let _e178 = b_1;
                    let _e184 = global.U[0];
                    let _e187 = x_1;
                    let _e188 = y;
                    let _e190 = b_1;
                    let _e201 = textureSample(t_source2_, samp, ((vec2<f32>(((vec2<f32>(_e175, _e176) / vec2(_e178)).x / _e184.x), (vec2<f32>(_e187, _e188) / vec2(_e190)).y) / vec2(2f)) + vec2(0.5f)));
                    return _e201;
                }
            }
        }
    } else {
        let _e202 = mode_1;
        if (_e202 == 1i) {
            {
                let _e205 = uv_1;
                id_1 = round((_e205.x * 0.5f));
                let _e211 = uv_1;
                let _e214 = (_e211.x + 1f);
                x_2 = ((_e214 - (floor((_e214 / 2f)) * 2f)) - 1f);
                let _e223 = id_1;
                if ((_e223 - (floor((_e223 / 2f)) * 2f)) == 0f) {
                    let _e231 = x_2;
                    let _e232 = uv_1;
                    let _e235 = source1Dim_1;
                    let _e238 = source1Dim_1;
                    let _e245 = global.U[0];
                    let _e248 = x_2;
                    let _e249 = uv_1;
                    let _e252 = source1Dim_1;
                    let _e255 = source1Dim_1;
                    let _e267 = textureSample(t_source1_, samp, ((vec2<f32>((((vec2<f32>(_e231, _e232.y) * _e235.x) / vec2(_e238.y)).x / _e245.x), ((vec2<f32>(_e248, _e249.y) * _e252.x) / vec2(_e255.y)).y) / vec2(2f)) + vec2(0.5f)));
                    return _e267;
                } else {
                    let _e268 = x_2;
                    let _e269 = uv_1;
                    let _e272 = source2Dim_1;
                    let _e275 = source2Dim_1;
                    let _e282 = global.U[0];
                    let _e285 = x_2;
                    let _e286 = uv_1;
                    let _e289 = source2Dim_1;
                    let _e292 = source2Dim_1;
                    let _e304 = textureSample(t_source2_, samp, ((vec2<f32>((((vec2<f32>(_e268, _e269.y) * _e272.x) / vec2(_e275.y)).x / _e282.x), ((vec2<f32>(_e285, _e286.y) * _e289.x) / vec2(_e292.y)).y) / vec2(2f)) + vec2(0.5f)));
                    return _e304;
                }
            }
        } else {
            {
                let _e305 = uv_1;
                id_2 = round((_e305 * 0.5f));
                let _e310 = uv_1;
                let _e313 = (_e310 + vec2(1f));
                let _e315 = vec2(2f);
                u = ((_e313 - (floor((_e313 / _e315)) * _e315)) - vec2(1f));
                let _e325 = thickness_1;
                b_2 = (1f - _e325);
                let _e328 = u;
                let _e331 = b_2;
                let _e333 = u;
                let _e336 = b_2;
                if ((abs(_e328.x) > _e331) || (abs(_e333.y) > _e336)) {
                    let _e339 = colorBorder_1;
                    return _e339;
                }
                let _e340 = u;
                let _e341 = b_2;
                u = (_e340 / vec2(_e341));
                let _e344 = id_2;
                let _e346 = id_2;
                let _e348 = (_e344.x + _e346.y);
                if ((_e348 - (floor((_e348 / 2f)) * 2f)) == 0f) {
                    let _e356 = u;
                    let _e360 = global.U[0];
                    let _e363 = u;
                    let _e372 = textureSample(t_source1_, samp, ((vec2<f32>((_e356.x / _e360.x), _e363.y) / vec2(2f)) + vec2(0.5f)));
                    return _e372;
                } else {
                    let _e373 = u;
                    let _e377 = global.U[0];
                    let _e380 = u;
                    let _e389 = textureSample(t_source2_, samp, ((vec2<f32>((_e373.x / _e377.x), _e380.y) / vec2(2f)) + vec2(0.5f)));
                    return _e389;
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
