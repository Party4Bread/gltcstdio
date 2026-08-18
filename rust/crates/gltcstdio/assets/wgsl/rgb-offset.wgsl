struct Params {
    U: array<vec4<f32>, 16>,
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

fn getOffsetPos(transform: mat3x3<f32>, pos: vec2<f32>, scale: f32, dampening: f32) -> vec2<f32> {
    var transform_1: mat3x3<f32>;
    var pos_1: vec2<f32>;
    var scale_1: f32;
    var dampening_1: f32;
    var tPos: vec2<f32>;
    var dist: f32;

    transform_1 = transform;
    pos_1 = pos;
    scale_1 = scale;
    dampening_1 = dampening;
    let _e14 = transform_1;
    let _e16 = pos_1;
    tPos = (_naga_inverse_3x3_f32(_e14) * vec3<f32>(_e16.x, _e16.y, 1f)).xy;
    let _e24 = pos_1;
    let _e25 = scale_1;
    let _e26 = tPos;
    let _e27 = pos_1;
    tPos = (_e24 + (_e25 * (_e26 - _e27)));
    let _e31 = pos_1;
    dist = length(_e31);
    let _e34 = dist;
    if (_e34 < 1f) {
        {
            let _e37 = pos_1;
            let _e38 = tPos;
            let _e40 = dampening_1;
            let _e42 = dist;
            let _e43 = dist;
            tPos = mix(_e37, _e38, vec2((1f - (_e40 * (1f - (_e42 * _e43))))));
        }
    }
    let _e50 = tPos;
    return _e50;
}

fn rgbOffset(pos_2: vec2<f32>, outPos: vec2<f32>, dampening_2: f32, scale_2: f32, redTransform: mat3x3<f32>, greenTransform: mat3x3<f32>, blueTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var dampening_3: f32;
    var scale_3: f32;
    var redTransform_1: mat3x3<f32>;
    var greenTransform_1: mat3x3<f32>;
    var blueTransform_1: mat3x3<f32>;
    var red: vec4<f32>;
    var green: vec4<f32>;
    var blue: vec4<f32>;
    var outColor: vec4<f32>;

    pos_3 = pos_2;
    outPos_1 = outPos;
    dampening_3 = dampening_2;
    scale_3 = scale_2;
    redTransform_1 = redTransform;
    greenTransform_1 = greenTransform;
    blueTransform_1 = blueTransform;
    let _e20 = redTransform_1;
    let _e21 = pos_3;
    let _e22 = scale_3;
    let _e23 = dampening_3;
    let _e24 = getOffsetPos(_e20, _e21, _e22, _e23);
    let _e28 = global.U[0];
    let _e31 = redTransform_1;
    let _e32 = pos_3;
    let _e33 = scale_3;
    let _e34 = dampening_3;
    let _e35 = getOffsetPos(_e31, _e32, _e33, _e34);
    let _e44 = textureSample(t_source, samp, ((vec2<f32>((_e24.x / _e28.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    red = _e44;
    let _e46 = greenTransform_1;
    let _e47 = pos_3;
    let _e48 = scale_3;
    let _e49 = dampening_3;
    let _e50 = getOffsetPos(_e46, _e47, _e48, _e49);
    let _e54 = global.U[0];
    let _e57 = greenTransform_1;
    let _e58 = pos_3;
    let _e59 = scale_3;
    let _e60 = dampening_3;
    let _e61 = getOffsetPos(_e57, _e58, _e59, _e60);
    let _e70 = textureSample(t_source, samp, ((vec2<f32>((_e50.x / _e54.x), _e61.y) / vec2(2f)) + vec2(0.5f)));
    green = _e70;
    let _e72 = blueTransform_1;
    let _e73 = pos_3;
    let _e74 = scale_3;
    let _e75 = dampening_3;
    let _e76 = getOffsetPos(_e72, _e73, _e74, _e75);
    let _e80 = global.U[0];
    let _e83 = blueTransform_1;
    let _e84 = pos_3;
    let _e85 = scale_3;
    let _e86 = dampening_3;
    let _e87 = getOffsetPos(_e83, _e84, _e85, _e86);
    let _e96 = textureSample(t_source, samp, ((vec2<f32>((_e76.x / _e80.x), _e87.y) / vec2(2f)) + vec2(0.5f)));
    blue = _e96;
    let _e98 = red;
    let _e100 = green;
    let _e102 = blue;
    let _e104 = red;
    let _e106 = green;
    let _e109 = blue;
    outColor = vec4<f32>(_e98.x, _e100.y, _e102.z, (((_e104.w + _e106.w) + _e109.w) / 3f));
    let _e116 = outColor;
    return _e116;
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
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e124 = global.U[13];
    let _e125 = _e124.xyz;
    let _e128 = global.U[14];
    let _e129 = _e128.xyz;
    let _e132 = global.U[15];
    let _e133 = _e132.xyz;
    let _e147 = rgbOffset((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)), mat3x3<f32>(vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z)), mat3x3<f32>(vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z)));
    fragColor = _e147;
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
