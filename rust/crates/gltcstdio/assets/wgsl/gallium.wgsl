struct Params {
    U: array<vec4<f32>, 11>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn gallium(pos: vec2<f32>, outPos: vec2<f32>, iterations: i32, intensity: f32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_1: i32;
    var intensity_1: f32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var nIntens: f32;
    var i: i32 = 0i;
    var col: vec4<f32>;
    var len: f32;
    var ang1_: f32;
    var ang2_: f32;
    var delta: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    iterations_1 = iterations;
    intensity_1 = intensity;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e18);
    let _e21 = intensity_1;
    let _e22 = iterations_1;
    nIntens = (_e21 / f32(_e22));
    loop {
        let _e28 = i;
        let _e29 = iterations_1;
        if !((_e28 < _e29)) {
            break;
        }
        {
            let _e35 = inverseModelTransform;
            let _e36 = pos_1;
            let _e37 = tf(_e35, _e36);
            let _e41 = global.U[0];
            let _e44 = inverseModelTransform;
            let _e45 = pos_1;
            let _e46 = tf(_e44, _e45);
            let _e55 = _mirror_wrap(((vec2<f32>((_e37.x / _e41.x), _e46.y) / vec2(2f)) + vec2(0.5f)));
            let _e56 = textureSample(t_source, samp, _e55);
            col = _e56;
            let _e58 = col;
            let _e60 = col;
            let _e62 = col;
            len = mix(_e58.x, _e60.y, _e62.z);
            let _e66 = col;
            let _e68 = col;
            let _e70 = col;
            let _e75 = angle_1;
            ang1_ = ((mix(_e66.y, _e68.z, _e70.x) * 6.2831855f) + _e75);
            let _e78 = col;
            let _e80 = col;
            let _e82 = col;
            let _e87 = angle_1;
            ang2_ = ((mix(_e78.z, _e80.x, _e82.y) * 6.2831855f) + _e87);
            let _e90 = nIntens;
            let _e91 = len;
            let _e93 = ang1_;
            let _e95 = ang2_;
            delta = ((_e90 * _e91) * (vec2<f32>(cos(_e93), sin(_e95)) - vec2(0.5f)));
            let _e103 = pos_1;
            let _e104 = delta;
            pos_1 = (_e103 + _e104);
        }
        continuing {
            let _e32 = i;
            i = (_e32 + 1i);
        }
    }
    let _e106 = pos_1;
    let _e110 = global.U[0];
    let _e113 = pos_1;
    let _e122 = _mirror_wrap(((vec2<f32>((_e106.x / _e110.x), _e113.y) / vec2(2f)) + vec2(0.5f)));
    let _e123 = textureSample(t_source, samp, _e122);
    return _e123;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = gallium((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
