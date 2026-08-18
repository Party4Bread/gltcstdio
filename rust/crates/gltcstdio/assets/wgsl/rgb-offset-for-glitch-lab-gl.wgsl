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

fn rgbOffsetGlitchLabGetOffsetPos(transform: mat3x3<f32>, pos: vec2<f32>, vignetting: f32) -> vec2<f32> {
    var transform_1: mat3x3<f32>;
    var pos_1: vec2<f32>;
    var vignetting_1: f32;
    var tPos: vec2<f32>;
    var dist: f32;

    transform_1 = transform;
    pos_1 = pos;
    vignetting_1 = vignetting;
    let _e12 = transform_1;
    let _e14 = pos_1;
    tPos = (_naga_inverse_3x3_f32(_e12) * vec3<f32>(_e14.x, _e14.y, 1f)).xy;
    let _e22 = pos_1;
    dist = length(_e22);
    let _e25 = dist;
    if (_e25 < 1f) {
        {
            let _e28 = pos_1;
            let _e29 = tPos;
            let _e31 = vignetting_1;
            let _e33 = dist;
            let _e34 = dist;
            tPos = mix(_e28, _e29, vec2((1f - (_e31 * (1f - (_e33 * _e34))))));
        }
    }
    let _e41 = tPos;
    return _e41;
}

fn rgbOffsetForGlitchLabGl(pos_2: vec2<f32>, outPos: vec2<f32>, vignetting_2: f32, redTransform: mat3x3<f32>, greenTransform: mat3x3<f32>, blueTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var vignetting_3: f32;
    var redTransform_1: mat3x3<f32>;
    var greenTransform_1: mat3x3<f32>;
    var blueTransform_1: mat3x3<f32>;
    var red: vec4<f32>;
    var green: vec4<f32>;
    var blue: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    vignetting_3 = vignetting_2;
    redTransform_1 = redTransform;
    greenTransform_1 = greenTransform;
    blueTransform_1 = blueTransform;
    let _e18 = redTransform_1;
    let _e19 = pos_3;
    let _e20 = vignetting_3;
    let _e21 = rgbOffsetGlitchLabGetOffsetPos(_e18, _e19, _e20);
    let _e25 = global.U[0];
    let _e28 = redTransform_1;
    let _e29 = pos_3;
    let _e30 = vignetting_3;
    let _e31 = rgbOffsetGlitchLabGetOffsetPos(_e28, _e29, _e30);
    let _e40 = textureSample(t_source, samp, ((vec2<f32>((_e21.x / _e25.x), _e31.y) / vec2(2f)) + vec2(0.5f)));
    red = _e40;
    let _e42 = greenTransform_1;
    let _e43 = pos_3;
    let _e44 = vignetting_3;
    let _e45 = rgbOffsetGlitchLabGetOffsetPos(_e42, _e43, _e44);
    let _e49 = global.U[0];
    let _e52 = greenTransform_1;
    let _e53 = pos_3;
    let _e54 = vignetting_3;
    let _e55 = rgbOffsetGlitchLabGetOffsetPos(_e52, _e53, _e54);
    let _e64 = textureSample(t_source, samp, ((vec2<f32>((_e45.x / _e49.x), _e55.y) / vec2(2f)) + vec2(0.5f)));
    green = _e64;
    let _e66 = blueTransform_1;
    let _e67 = pos_3;
    let _e68 = vignetting_3;
    let _e69 = rgbOffsetGlitchLabGetOffsetPos(_e66, _e67, _e68);
    let _e73 = global.U[0];
    let _e76 = blueTransform_1;
    let _e77 = pos_3;
    let _e78 = vignetting_3;
    let _e79 = rgbOffsetGlitchLabGetOffsetPos(_e76, _e77, _e78);
    let _e88 = textureSample(t_source, samp, ((vec2<f32>((_e69.x / _e73.x), _e79.y) / vec2(2f)) + vec2(0.5f)));
    blue = _e88;
    let _e90 = red;
    let _e92 = green;
    let _e94 = blue;
    let _e96 = red;
    let _e98 = green;
    let _e101 = blue;
    return vec4<f32>(_e90.x, _e92.y, _e94.z, (((_e96.w + _e98.w) + _e101.w) / 3f));
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
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e95 = global.U[9];
    let _e96 = _e95.xyz;
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e120 = global.U[12];
    let _e121 = _e120.xyz;
    let _e124 = global.U[13];
    let _e125 = _e124.xyz;
    let _e128 = global.U[14];
    let _e129 = _e128.xyz;
    let _e143 = rgbOffsetForGlitchLabGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)), mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)));
    fragColor = _e143;
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
