struct Params {
    U: array<vec4<f32>, 12>,
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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn mirrorPoint(p: vec2<f32>, axisPoint: vec2<f32>, axisNormal: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var axisPoint_1: vec2<f32>;
    var axisNormal_1: vec2<f32>;
    var d: f32;
    var local: vec2<f32>;

    p_1 = p;
    axisPoint_1 = axisPoint;
    axisNormal_1 = axisNormal;
    let _e12 = p_1;
    let _e13 = axisPoint_1;
    let _e15 = axisNormal_1;
    d = dot((_e12 - _e13), _e15);
    let _e18 = d;
    if (_e18 <= 0f) {
        let _e21 = p_1;
        local = _e21;
    } else {
        let _e22 = p_1;
        let _e24 = d;
        let _e26 = axisNormal_1;
        local = (_e22 - ((2f * _e24) * _e26));
    }
    let _e30 = local;
    return _e30;
}

fn mirrorOpt(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>, axisTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var axisTransform_1: mat3x3<f32>;
    var inRatio: f32;
    var axisNormal_2: vec2<f32>;
    var axisPoint_2: vec2<f32>;
    var translate: mat3x3<f32>;
    var t: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    axisTransform_1 = axisTransform;
    let _e16 = sourceDim_1;
    let _e18 = sourceDim_1;
    inRatio = (_e16.x / _e18.y);
    let _e22 = axisTransform_1;
    axisNormal_2 = normalize((mat2x2<f32>(_e22[0].xy, _e22[1].xy) * vec2<f32>(1f, 0f)));
    let _e36 = axisTransform_1;
    axisPoint_2 = (_e36 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e50 = inRatio;
    translate = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e50, 0f, 1f));
    let _e58 = modelTransform_1;
    let _e59 = translate;
    let _e62 = pos_1;
    let _e63 = axisPoint_2;
    let _e64 = axisNormal_2;
    let _e65 = mirrorPoint(_e62, _e63, _e64);
    t = (_naga_inverse_3x3_f32((_e58 * _e59)) * vec3<f32>(_e65.x, _e65.y, 1f)).xy;
    let _e73 = t;
    let _e77 = global.U[0];
    let _e80 = t;
    let _e89 = _mirror_wrap(((vec2<f32>((_e73.x / _e77.x), _e80.y) / vec2(2f)) + vec2(0.5f)));
    let _e90 = textureSample(t_source, samp, _e89);
    return _e90;
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
    let _e66 = global.U[4];
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
    let _e118 = mirrorOpt((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)), mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)));
    fragColor = _e118;
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
