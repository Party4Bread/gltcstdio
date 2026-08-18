struct Params {
    U: array<vec4<f32>, 17>,
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

fn compression1dGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, angle: f32, displacement_specified: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var angle_1: f32;
    var displacement_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var dir: vec2<f32>;
    var pp: vec2<f32>;
    var p: vec2<f32>;
    var local: vec4<f32>;
    var fieldSample: vec4<f32>;
    var d: f32;
    var scaledIntensity: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    angle_1 = angle;
    displacement_specified_1 = displacement_specified;
    modelTransform_1 = modelTransform;
    let _e19 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e19);
    let _e22 = angle_1;
    let _e24 = angle_1;
    dir = vec2<f32>(sin(_e22), cos(_e24));
    let _e28 = dir;
    let _e29 = pos_1;
    let _e31 = dir;
    pp = (dot(_e28, _e29) * _e31);
    let _e34 = invM;
    let _e35 = pp;
    p = (_e34 * vec3<f32>(_e35.x, _e35.y, 1f)).xy;
    let _e43 = displacement_specified_1;
    if (_e43 != 0i) {
        let _e46 = p;
        let _e50 = global.U[0];
        let _e53 = p;
        let _e62 = _mirror_wrap(((vec2<f32>((_e46.x / _e50.x), _e53.y) / vec2(2f)) + vec2(0.5f)));
        let _e63 = textureSample(t_displacement, samp, _e62);
        local = _e63;
    } else {
        let _e64 = p;
        let _e68 = global.U[0];
        let _e71 = p;
        let _e80 = textureSample(t_source, samp, ((vec2<f32>((_e64.x / _e68.x), _e71.y) / vec2(2f)) + vec2(0.5f)));
        local = _e80;
    }
    let _e82 = local;
    fieldSample = _e82;
    let _e84 = fieldSample;
    d = (((length(_e84.xyz) / 1.73205f) - 0.5f) * 2f);
    let _e94 = intensity_1;
    scaledIntensity = (_e94 * 4f);
    let _e98 = pp;
    let _e99 = pos_1;
    let _e100 = pp;
    let _e103 = d;
    let _e104 = scaledIntensity;
    let _e112 = global.U[0];
    let _e115 = pp;
    let _e116 = pos_1;
    let _e117 = pp;
    let _e120 = d;
    let _e121 = scaledIntensity;
    let _e134 = textureSample(t_source, samp, ((vec2<f32>(((_e98 + ((_e99 - _e100) * (1f + (_e103 * _e104)))).x / _e112.x), (_e115 + ((_e116 - _e117) * (1f + (_e120 * _e121)))).y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e134;
    let _e136 = outColor;
    return _e136;
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
    let _e75 = global.U[4];
    let _e80 = global.U[14];
    let _e81 = _e80.xyz;
    let _e84 = global.U[15];
    let _e85 = _e84.xyz;
    let _e88 = global.U[16];
    let _e89 = _e88.xyz;
    let _e103 = compression1dGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, i32(_e75.x), mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)));
    fragColor = _e103;
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
