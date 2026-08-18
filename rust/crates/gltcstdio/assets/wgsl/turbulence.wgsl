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

fn nextRot(i: i32, angle: f32) -> f32 {
    var i_1: i32;
    var angle_1: f32;

    i_1 = i;
    angle_1 = angle;
    let _e11 = angle_1;
    let _e14 = i_1;
    return ((1.507f + sin(_e11)) + sin((f32(_e14) * 0.01f)));
}

fn rotation3_(angle_2: f32) -> mat3x3<f32> {
    var angle_3: f32;
    var ca: f32;
    var sa: f32;

    angle_3 = angle_2;
    let _e8 = angle_3;
    ca = cos(_e8);
    let _e11 = angle_3;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat3x3<f32>(vec3<f32>(_e14, _e15, 0f), vec3<f32>(-(_e17), _e19, 0f), vec3<f32>(0f, 0f, 1f));
}

fn scaling3_(s: f32) -> mat3x3<f32> {
    var s_1: f32;

    s_1 = s;
    let _e8 = s_1;
    let _e12 = s_1;
    return mat3x3<f32>(vec3<f32>(_e8, 0f, 0f), vec3<f32>(0f, _e12, 0f), vec3<f32>(0f, 0f, 1f));
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

fn translation3_(t: vec2<f32>) -> mat3x3<f32> {
    var t_1: vec2<f32>;

    t_1 = t;
    let _e14 = t_1;
    let _e16 = t_1;
    return mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e14.x, _e16.y, 1f));
}

fn wave(u_2: vec2<f32>, k: f32) -> vec2<f32> {
    var u_3: vec2<f32>;
    var k_1: f32;

    u_3 = u_2;
    k_1 = k;
    let _e11 = k_1;
    let _e12 = u_3;
    let _e15 = u_3;
    let _e26 = u_3;
    let _e32 = k_1;
    let _e33 = u_3;
    let _e36 = u_3;
    return (5f * vec2<f32>(((_e11 * sin(((_e12.y * (1.5f + sin((_e15.y * 1.1f)))) + 0.44f))) / (abs(_e26.y) + 1f)), (_e32 * (sin(_e33.x) / (abs(_e36.x) + 1f)))));
}

fn turbulence(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, iterations: i32, modelTransform: mat3x3<f32>, translation: f32, angle_4: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var iterations_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var translation_1: f32;
    var angle_5: f32;
    var t_2: mat3x3<f32>;
    var i_2: i32 = 0i;
    var p: vec2<f32>;
    var tt: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    iterations_1 = iterations;
    modelTransform_1 = modelTransform;
    translation_1 = translation;
    angle_5 = angle_4;
    let _e20 = modelTransform_1;
    t_2 = _naga_inverse_3x3_f32(_e20);
    loop {
        let _e25 = i_2;
        let _e26 = iterations_1;
        if !((_e25 < _e26)) {
            break;
        }
        {
            let _e32 = t_2;
            let _e33 = uv_1;
            let _e34 = tf(_e32, _e33);
            uv_1 = _e34;
            let _e35 = uv_1;
            let _e36 = uv_1;
            let _e37 = intensity_1;
            let _e38 = wave(_e36, _e37);
            uv_1 = (_e35 + _e38);
            let _e40 = t_2;
            let _e42 = uv_1;
            let _e43 = tf(_naga_inverse_3x3_f32(_e40), _e42);
            uv_1 = _e43;
            p = vec2(0f);
            let _e47 = translation_1;
            tt = pow(_e47, 3f);
            let _e51 = t_2;
            let _e52 = tt;
            let _e54 = angle_5;
            let _e58 = tt;
            let _e60 = angle_5;
            let _e65 = translation3_(vec2<f32>((_e52 + (0.01f * cos(_e54))), (_e58 + (0.02f * sin(_e60)))));
            let _e66 = i_2;
            let _e67 = angle_5;
            let _e68 = nextRot(_e66, _e67);
            let _e70 = p;
            let _e74 = rotation3_((_e68 + (0.5f * _e70.y)));
            let _e77 = scaling3_(1f);
            t_2 = (_e51 * ((_e65 * _e74) * _e77));
        }
        continuing {
            let _e29 = i_2;
            i_2 = (_e29 + 1i);
        }
    }
    let _e80 = uv_1;
    let _e84 = global.U[0];
    let _e87 = uv_1;
    let _e96 = _mirror_wrap(((vec2<f32>((_e80.x / _e84.x), _e87.y) / vec2(2f)) + vec2(0.5f)));
    let _e97 = textureSample(t_source, samp, _e96);
    return _e97;
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
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e100 = global.U[10];
    let _e104 = global.U[11];
    let _e106 = turbulence((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)), _e100.x, _e104.x);
    fragColor = _e106;
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
