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
var t_displacement: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn displacement1dGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, angle: f32, phase2_: f32, displacement_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var angle_1: f32;
    var phase2_1: f32;
    var displacement_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var dir: vec2<f32>;
    var dispDir: vec2<f32>;
    var pp: vec2<f32>;
    var p: vec2<f32>;
    var local: vec4<f32>;
    var fieldSample: vec4<f32>;
    var d: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    angle_1 = angle;
    phase2_1 = phase2_;
    displacement_specified_1 = displacement_specified;
    modelTransform_1 = modelTransform;
    let _e21 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e21);
    let _e24 = angle_1;
    let _e26 = angle_1;
    dir = vec2<f32>(sin(_e24), cos(_e26));
    let _e30 = phase2_1;
    let _e32 = phase2_1;
    let _e35 = phase2_1;
    let _e37 = phase2_1;
    let _e42 = dir;
    dispDir = (mat2x2<f32>(vec2<f32>(cos(_e30), -(sin(_e32))), vec2<f32>(sin(_e35), cos(_e37))) * _e42);
    let _e45 = dir;
    let _e46 = pos_1;
    let _e48 = dir;
    pp = (dot(_e45, _e46) * _e48);
    let _e51 = invM;
    let _e52 = pp;
    p = (_e51 * vec3<f32>(_e52.x, _e52.y, 1f)).xy;
    let _e60 = displacement_specified_1;
    if (_e60 != 0i) {
        let _e63 = p;
        let _e67 = global.U[0];
        let _e70 = p;
        let _e79 = _mirror_wrap(((vec2<f32>((_e63.x / _e67.x), _e70.y) / vec2(2f)) + vec2(0.5f)));
        let _e80 = textureSample(t_displacement, samp, _e79);
        local = _e80;
    } else {
        let _e81 = p;
        let _e85 = global.U[0];
        let _e88 = p;
        let _e97 = textureSample(t_source, samp, ((vec2<f32>((_e81.x / _e85.x), _e88.y) / vec2(2f)) + vec2(0.5f)));
        local = _e97;
    }
    let _e99 = local;
    fieldSample = _e99;
    let _e101 = fieldSample;
    d = (((length(_e101.xyz) / 1.73205f) - 0.5f) * 2f);
    let _e111 = pos_1;
    let _e112 = intensity_1;
    let _e113 = d;
    let _e115 = dispDir;
    let _e121 = global.U[0];
    let _e124 = pos_1;
    let _e125 = intensity_1;
    let _e126 = d;
    let _e128 = dispDir;
    let _e139 = textureSample(t_source, samp, ((vec2<f32>(((_e111 + ((_e112 * _e113) * _e115)).x / _e121.x), (_e124 + ((_e125 * _e126) * _e128)).y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e139;
    let _e141 = outColor;
    return _e141;
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
    let _e67 = global.U[12];
    let _e71 = global.U[13];
    let _e75 = global.U[14];
    let _e79 = global.U[4];
    let _e84 = global.U[15];
    let _e85 = _e84.xyz;
    let _e88 = global.U[16];
    let _e89 = _e88.xyz;
    let _e92 = global.U[17];
    let _e93 = _e92.xyz;
    let _e107 = displacement1dGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, _e75.x, i32(_e79.x), mat3x3<f32>(vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z)));
    fragColor = _e107;
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
