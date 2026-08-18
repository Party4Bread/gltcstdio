struct Params {
    U: array<vec4<f32>, 15>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn inversion(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, intensity: f32, dampening: f32, iterations: i32, modelTransform: mat3x3<f32>, modelTransform2_: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var intensity_1: f32;
    var dampening_1: f32;
    var iterations_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var modelTransform2_1: mat3x3<f32>;
    var center: vec2<f32>;
    var unit: vec2<f32>;
    var radius: f32;
    var t2_: mat3x3<f32>;
    var u_2: vec2<f32>;
    var i: i32 = 0i;
    var len: f32;
    var dir: vec2<f32>;
    var inversedLen: f32;
    var local: f32;
    var k: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    intensity_1 = intensity;
    dampening_1 = dampening;
    iterations_1 = iterations;
    modelTransform_1 = modelTransform;
    modelTransform2_1 = modelTransform2_;
    let _e22 = modelTransform_1;
    let _e25 = tf(_e22, vec2(0f));
    center = _e25;
    let _e27 = modelTransform_1;
    let _e31 = tf(_e27, vec2<f32>(1f, 0f));
    unit = _e31;
    let _e33 = unit;
    radius = length(_e33);
    let _e36 = modelTransform2_1;
    t2_ = _naga_inverse_3x3_f32(_e36);
    let _e39 = uv_1;
    u_2 = _e39;
    loop {
        let _e43 = i;
        let _e44 = iterations_1;
        if !((_e43 < _e44)) {
            break;
        }
        {
            let _e50 = u_2;
            let _e51 = center;
            len = length((_e50 - _e51));
            let _e55 = u_2;
            let _e56 = center;
            let _e58 = len;
            dir = ((_e55 - _e56) / vec2(_e58));
            let _e62 = radius;
            let _e63 = len;
            inversedLen = (_e62 / _e63);
            let _e66 = center;
            let _e67 = intensity_1;
            let _e68 = inversedLen;
            let _e70 = dir;
            u_2 = (_e66 + ((_e67 * _e68) * _e70));
            let _e73 = mode_1;
            if (_e73 != 1i) {
                let _e76 = t2_;
                let _e77 = u_2;
                let _e78 = tf(_e76, _e77);
                u_2 = abs(_e78);
            } else {
                let _e80 = t2_;
                let _e81 = u_2;
                let _e82 = tf(_e80, _e81);
                u_2 = _e82;
            }
            let _e83 = dampening_1;
            if (_e83 != -100f) {
                {
                    let _e87 = len;
                    let _e88 = radius;
                    if (_e87 < _e88) {
                        let _e90 = len;
                        let _e91 = radius;
                        let _e95 = dampening_1;
                        local = pow((_e90 / _e91), (2f * pow(1.04f, _e95)));
                    } else {
                        local = 1f;
                    }
                    let _e101 = local;
                    k = _e101;
                    let _e103 = dampening_1;
                    if (_e103 < 0f) {
                        let _e106 = k;
                        let _e108 = dampening_1;
                        k = mix(_e106, 1f, (-(_e108) / 100f));
                    }
                    let _e113 = uv_1;
                    let _e114 = u_2;
                    let _e115 = k;
                    u_2 = mix(_e113, _e114, vec2(_e115));
                }
            }
        }
        continuing {
            let _e47 = i;
            i = (_e47 + 1i);
        }
    }
    let _e118 = u_2;
    let _e122 = global.U[0];
    let _e125 = u_2;
    let _e134 = textureSample(t_source, samp, ((vec2<f32>((_e118.x / _e122.x), _e125.y) / vec2(2f)) + vec2(0.5f)));
    return _e134;
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
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e92 = global.U[11];
    let _e93 = _e92.xyz;
    let _e109 = global.U[12];
    let _e110 = _e109.xyz;
    let _e113 = global.U[13];
    let _e114 = _e113.xyz;
    let _e117 = global.U[14];
    let _e118 = _e117.xyz;
    let _e132 = inversion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, i32(_e79.x), mat3x3<f32>(vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z)), mat3x3<f32>(vec3<f32>(_e110.x, _e110.y, _e110.z), vec3<f32>(_e114.x, _e114.y, _e114.z), vec3<f32>(_e118.x, _e118.y, _e118.z)));
    fragColor = _e132;
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
