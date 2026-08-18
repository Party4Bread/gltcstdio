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

fn triangleToSquareWave(x: f32, k: f32) -> f32 {
    var x_1: f32;
    var k_1: f32;
    var s: f32 = 1f;
    var local: f32;
    var m_2: f32;

    x_1 = x;
    k_1 = k;
    let _e10 = x_1;
    x_1 = (_e10 - (floor((_e10 / 4f)) * 4f));
    let _e18 = x_1;
    if (_e18 > 2f) {
        {
            let _e21 = x_1;
            x_1 = (_e21 - 2f);
            s = -1f;
        }
    }
    let _e26 = k_1;
    if (_e26 > 0f) {
        local = 1f;
    } else {
        let _e32 = k_1;
        let _e35 = k_1;
        local = pow(mix(5f, 40f, -(_e32)), -(_e35));
    }
    let _e39 = local;
    m_2 = _e39;
    let _e41 = m_2;
    let _e42 = s;
    let _e45 = x_1;
    let _e50 = k_1;
    return ((_e41 * _e42) * (1f - pow(abs((_e45 - 1f)), pow(100f, _e50))));
}

fn shimmer(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, shape: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var shape_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var v: vec2<f32>;
    var local_1: f32;
    var d: f32;
    var u_2: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    shape_1 = shape;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = uv_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    v = _e21;
    let _e23 = dampening_1;
    if (_e23 == 0f) {
        local_1 = 1f;
    } else {
        let _e28 = dampening_1;
        let _e31 = dampening_1;
        let _e33 = v;
        local_1 = smoothstep((5f / _e28), (0.5f / _e31), abs(_e33.x));
    }
    let _e38 = local_1;
    d = _e38;
    let _e41 = v;
    let _e43 = intensity_1;
    let _e44 = v;
    let _e50 = shape_1;
    let _e51 = triangleToSquareWave(((_e44.x * 20f) + 1f), _e50);
    let _e53 = d;
    v.y = (_e41.y + (((_e43 * _e51) * _e53) * 0.05f));
    let _e58 = modelTransform_1;
    let _e59 = v;
    let _e60 = tf(_e58, _e59);
    u_2 = _e60;
    let _e62 = u_2;
    let _e66 = global.U[0];
    let _e69 = u_2;
    let _e78 = _mirror_wrap(((vec2<f32>((_e62.x / _e66.x), _e69.y) / vec2(2f)) + vec2(0.5f)));
    let _e79 = textureSample(t_source, samp, _e78);
    return _e79;
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
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = shimmer((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
    fragColor = _e101;
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
