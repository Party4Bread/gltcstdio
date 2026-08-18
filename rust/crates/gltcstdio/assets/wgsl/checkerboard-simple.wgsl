struct Params {
    U: array<vec4<f32>, 8>,
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

fn cherckerboard(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, color1_: vec4<f32>, color2_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var k: f32;
    var id: vec2<f32>;
    var index: f32;
    var bit: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    color1_1 = color1_;
    color2_1 = color2_;
    let _e15 = uv_1;
    let _e18 = uv_1;
    let _e21 = (floor(_e15.x) + floor(_e18.y));
    k = (_e21 - (floor((_e21 / 2f)) * 2f));
    let _e28 = uv_1;
    let _e29 = floor(_e28);
    let _e31 = vec2(4f);
    id = (_e29 - (floor((_e29 / _e31)) * _e31));
    let _e37 = id;
    let _e39 = id;
    index = (_e37.x + (_e39.y * 4f));
    let _e45 = mode_1;
    let _e48 = index;
    let _e51 = floor((f32(_e45) / pow(2f, _e48)));
    bit = (_e51 - (floor((_e51 / 2f)) * 2f));
    let _e58 = color1_1;
    let _e59 = color2_1;
    let _e60 = bit;
    outColor = mix(_e58, _e59, vec4(_e60));
    let _e64 = outColor;
    return _e64;
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e70 = global.U[6];
    let _e73 = global.U[7];
    let _e74 = cherckerboard((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), _e70, _e73);
    fragColor = _e74;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
