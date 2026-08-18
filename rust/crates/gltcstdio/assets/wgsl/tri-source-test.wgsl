struct Params {
    U: array<vec4<f32>, 5>,
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
@group(0) @binding(4) 
var t_source3_: texture_2d<f32>;

fn linearBlend(pos: vec2<f32>, outPos: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var in1_: vec4<f32>;
    var in2_: vec4<f32>;
    var in3_: vec4<f32>;
    var blended: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    let _e12 = pos_1;
    let _e16 = global.U[0];
    let _e19 = pos_1;
    let _e28 = textureSample(t_source1_, samp, ((vec2<f32>((_e12.x / _e16.x), _e19.y) / vec2(2f)) + vec2(0.5f)));
    in1_ = _e28;
    let _e30 = pos_1;
    let _e34 = global.U[0];
    let _e37 = pos_1;
    let _e46 = textureSample(t_source2_, samp, ((vec2<f32>((_e30.x / _e34.x), _e37.y) / vec2(2f)) + vec2(0.5f)));
    in2_ = _e46;
    let _e48 = pos_1;
    let _e52 = global.U[0];
    let _e55 = pos_1;
    let _e64 = textureSample(t_source3_, samp, ((vec2<f32>((_e48.x / _e52.x), _e55.y) / vec2(2f)) + vec2(0.5f)));
    in3_ = _e64;
    let _e66 = in1_;
    let _e67 = in2_;
    let _e69 = in3_;
    blended = (((_e66 + _e67) + _e69) / vec4(3f));
    let _e75 = blended;
    return _e75;
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e66 = linearBlend((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)));
    fragColor = _e66;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e17 = fragColor;
    return FragmentOutput(_e17);
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
