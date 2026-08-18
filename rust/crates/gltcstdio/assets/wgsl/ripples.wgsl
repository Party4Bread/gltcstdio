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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn ripples(uv: vec2<f32>, outPos: vec2<f32>, spacing: f32, intensity: f32, count: i32, dampening: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spacing_1: f32;
    var intensity_1: f32;
    var count_1: i32;
    var dampening_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v: vec2<f32>;
    var d: f32;
    var local: f32;
    var dampen: f32;
    var local_1: f32;
    var dd: f32;
    var dilation: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    spacing_1 = spacing;
    intensity_1 = intensity;
    count_1 = count;
    dampening_1 = dampening;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e20);
    let _e23 = uv_1;
    u_2 = _e23;
    let _e25 = t;
    let _e26 = uv_1;
    let _e27 = tf(_e25, _e26);
    v = _e27;
    let _e29 = v;
    d = length(_e29);
    let _e32 = d;
    if (_e32 < 1f) {
        {
            let _e35 = dampening_1;
            if (_e35 >= 0f) {
                let _e39 = d;
                let _e41 = dampening_1;
                local = pow((1f - _e39), (_e41 * 2f));
            } else {
                let _e45 = d;
                let _e46 = dampening_1;
                local = pow(_e45, (-(_e46) * 5f));
            }
            let _e52 = local;
            dampen = _e52;
            let _e54 = spacing_1;
            if (_e54 <= 0f) {
                let _e57 = d;
                local_1 = (_e57 - 1f);
            } else {
                let _e60 = d;
                let _e63 = spacing_1;
                let _e68 = spacing_1;
                local_1 = (log((((_e60 - 1f) * _e63) + 1f)) / _e68);
            }
            let _e71 = local_1;
            dd = _e71;
            let _e74 = intensity_1;
            let _e75 = dd;
            let _e76 = count_1;
            let _e83 = dampen;
            dilation = (1f + ((_e74 * sin(((_e75 * f32(_e76)) * 3.1415927f))) * _e83));
            let _e87 = modelTransform_1;
            let _e88 = dilation;
            let _e89 = v;
            let _e91 = tf(_e87, (_e88 * _e89));
            u_2 = _e91;
        }
    }
    let _e92 = u_2;
    let _e96 = global.U[0];
    let _e99 = u_2;
    let _e108 = _mirror_wrap(((vec2<f32>((_e92.x / _e96.x), _e99.y) / vec2(2f)) + vec2(0.5f)));
    let _e109 = textureSample(t_source, samp, _e108);
    return _e109;
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = ripples((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, i32(_e74.x), _e79.x, mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
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
