struct Params {
    U: array<vec4<f32>, 13>,
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

fn radialShimmer(uv: vec2<f32>, outPos: vec2<f32>, spacing: f32, intensity: f32, count: i32, dampening: f32, shape: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spacing_1: f32;
    var intensity_1: f32;
    var count_1: i32;
    var dampening_1: f32;
    var shape_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v: vec2<f32>;
    var d: f32;
    var local_1: f32;
    var dampen: f32;
    var angle: f32;
    var local_2: f32;
    var dd: f32;
    var z: f32;
    var dAngle: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    spacing_1 = spacing;
    intensity_1 = intensity;
    count_1 = count;
    dampening_1 = dampening;
    shape_1 = shape;
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e22);
    let _e25 = uv_1;
    u_2 = _e25;
    let _e27 = t;
    let _e28 = uv_1;
    let _e29 = tf(_e27, _e28);
    v = _e29;
    let _e31 = v;
    d = length(_e31);
    let _e34 = d;
    if (_e34 < 1f) {
        {
            let _e37 = dampening_1;
            if (_e37 >= 0f) {
                let _e41 = d;
                let _e43 = dampening_1;
                local_1 = pow((1f - _e41), (_e43 * 2f));
            } else {
                let _e47 = d;
                let _e48 = dampening_1;
                local_1 = pow(_e47, (-(_e48) * 5f));
            }
            let _e54 = local_1;
            dampen = _e54;
            let _e56 = v;
            let _e58 = v;
            angle = atan2(_e56.y, _e58.x);
            let _e62 = spacing_1;
            if (_e62 <= 0f) {
                let _e65 = d;
                local_2 = (_e65 - 1f);
            } else {
                let _e68 = d;
                let _e71 = spacing_1;
                let _e76 = spacing_1;
                local_2 = (log((((_e68 - 1f) * _e71) + 1f)) / _e76);
            }
            let _e79 = local_2;
            dd = _e79;
            let _e81 = dd;
            let _e82 = count_1;
            let _e85 = shape_1;
            let _e86 = triangleToSquareWave((_e81 * f32(_e82)), _e85);
            z = _e86;
            let _e88 = intensity_1;
            let _e89 = z;
            let _e91 = dampen;
            dAngle = ((_e88 * _e89) * _e91);
            let _e94 = angle;
            let _e95 = dAngle;
            angle = (_e94 + _e95);
            let _e97 = modelTransform_1;
            let _e98 = d;
            let _e99 = angle;
            let _e101 = angle;
            let _e105 = tf(_e97, (_e98 * vec2<f32>(cos(_e99), sin(_e101))));
            u_2 = _e105;
        }
    }
    let _e106 = u_2;
    let _e110 = global.U[0];
    let _e113 = u_2;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = radialShimmer((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, i32(_e74.x), _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
