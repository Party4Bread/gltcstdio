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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn splitCombine(pos: vec2<f32>, outPos: vec2<f32>, dithering: f32, waviness: f32, axisTransform: mat3x3<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var dithering_1: f32;
    var waviness_1: f32;
    var axisTransform_1: mat3x3<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var inverseAxisTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var scale: f32;
    var d: f32;
    var local: vec4<f32>;
    var color: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    dithering_1 = dithering;
    waviness_1 = waviness;
    axisTransform_1 = axisTransform;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e21 = axisTransform_1;
    inverseAxisTransform = _naga_inverse_3x3_f32(_e21);
    let _e24 = inverseAxisTransform;
    let _e25 = pos_1;
    let _e26 = tf(_e24, _e25);
    u_2 = _e26;
    let _e30 = axisTransform_1[0];
    scale = length(_e30.xy);
    let _e35 = u_2;
    let _e37 = waviness_1;
    let _e38 = u_2;
    u_2.x = (_e35.x + (_e37 * sin((_e38.y * 5f))));
    let _e46 = u_2;
    let _e48 = dithering_1;
    let _e49 = u_2;
    u_2.x = (_e46.x + (_e48 * sin((_e49.x * 50f))));
    let _e56 = u_2;
    let _e58 = scale;
    d = (_e56.x * _e58);
    let _e61 = d;
    if (_e61 < 0f) {
        let _e64 = viewTransform1_1;
        let _e66 = pos_1;
        let _e67 = tf(_naga_inverse_3x3_f32(_e64), _e66);
        let _e71 = global.U[0];
        let _e74 = viewTransform1_1;
        let _e76 = pos_1;
        let _e77 = tf(_naga_inverse_3x3_f32(_e74), _e76);
        let _e87 = textureSampleLevel(t_source1_, samp, ((vec2<f32>((_e67.x / _e71.x), _e77.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local = _e87;
    } else {
        let _e88 = viewTransform2_1;
        let _e90 = pos_1;
        let _e91 = tf(_naga_inverse_3x3_f32(_e88), _e90);
        let _e95 = global.U[0];
        let _e98 = viewTransform2_1;
        let _e100 = pos_1;
        let _e101 = tf(_naga_inverse_3x3_f32(_e98), _e100);
        let _e111 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e91.x / _e95.x), _e101.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local = _e111;
    }
    let _e113 = local;
    color = _e113;
    let _e115 = color;
    return _e115;
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
    let _e67 = global.U[5];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e100 = global.U[10];
    let _e101 = _e100.xyz;
    let _e104 = global.U[11];
    let _e105 = _e104.xyz;
    let _e108 = global.U[12];
    let _e109 = _e108.xyz;
    let _e125 = global.U[13];
    let _e126 = _e125.xyz;
    let _e129 = global.U[14];
    let _e130 = _e129.xyz;
    let _e133 = global.U[15];
    let _e134 = _e133.xyz;
    let _e148 = splitCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)), mat3x3<f32>(vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z), vec3<f32>(_e109.x, _e109.y, _e109.z)), mat3x3<f32>(vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z), vec3<f32>(_e134.x, _e134.y, _e134.z)));
    fragColor = _e148;
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
