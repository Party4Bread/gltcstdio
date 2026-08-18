struct Params {
    U: array<vec4<f32>, 10>,
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
var t_source1_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn quicksilver(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, modelTransform: mat3x3<f32>, displacement_specified: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var displacement_specified_1: i32;
    var inverseModelTransform: mat3x3<f32>;
    var local: vec2<f32>;
    var delta: vec2<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    modelTransform_1 = modelTransform;
    displacement_specified_1 = displacement_specified;
    let _e17 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e17);
    let _e20 = displacement_specified_1;
    if (_e20 == 1i) {
        let _e23 = inverseModelTransform;
        let _e24 = pos_1;
        let _e25 = tf(_e23, _e24);
        let _e29 = global.U[0];
        let _e32 = inverseModelTransform;
        let _e33 = pos_1;
        let _e34 = tf(_e32, _e33);
        let _e43 = _mirror_wrap(((vec2<f32>((_e25.x / _e29.x), _e34.y) / vec2(2f)) + vec2(0.5f)));
        let _e44 = textureSample(t_displacement, samp, _e43);
        let _e46 = intensity_1;
        local = (_e44.xy * _e46);
    } else {
        let _e48 = inverseModelTransform;
        let _e49 = pos_1;
        let _e50 = tf(_e48, _e49);
        let _e54 = global.U[0];
        let _e57 = inverseModelTransform;
        let _e58 = pos_1;
        let _e59 = tf(_e57, _e58);
        let _e68 = _mirror_wrap(((vec2<f32>((_e50.x / _e54.x), _e59.y) / vec2(2f)) + vec2(0.5f)));
        let _e69 = textureSample(t_source1_, samp, _e68);
        let _e71 = intensity_1;
        local = (_e69.xy * _e71);
    }
    let _e74 = local;
    delta = _e74;
    let _e76 = pos_1;
    let _e77 = delta;
    let _e82 = global.U[0];
    let _e85 = pos_1;
    let _e86 = delta;
    let _e96 = _mirror_wrap(((vec2<f32>(((_e76 + _e77).x / _e82.x), (_e85 + _e86).y) / vec2(2f)) + vec2(0.5f)));
    let _e97 = textureSample(t_source1_, samp, _e96);
    outCol = _e97;
    let _e99 = outCol;
    return _e99;
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
    let _e67 = global.U[6];
    let _e71 = global.U[7];
    let _e72 = _e71.xyz;
    let _e75 = global.U[8];
    let _e76 = _e75.xyz;
    let _e79 = global.U[9];
    let _e80 = _e79.xyz;
    let _e96 = global.U[4];
    let _e99 = quicksilver((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), i32(_e96.x));
    fragColor = _e99;
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
