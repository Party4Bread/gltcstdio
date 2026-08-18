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
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn getFlipTransform(mode: i32) -> mat3x3<f32> {
    var mode_1: i32;
    var local: f32;
    var sx: f32;
    var local_1: f32;
    var sy: f32;

    mode_1 = mode;
    let _e8 = mode_1;
    if ((_e8 % 2i) == 1i) {
        local = -2f;
    } else {
        local = 2f;
    }
    let _e17 = local;
    sx = _e17;
    let _e19 = mode_1;
    if (_e19 > 1i) {
        local_1 = -2f;
    } else {
        local_1 = 2f;
    }
    let _e26 = local_1;
    sy = _e26;
    let _e28 = sx;
    let _e32 = sy;
    return mat3x3<f32>(vec3<f32>(_e28, 0f, 0f), vec3<f32>(0f, _e32, 0f), vec3<f32>(0f, 0f, 1f));
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

fn quadMirror(uv: vec2<f32>, outPos: vec2<f32>, mode_2: i32, sourceDim: vec2<f32>, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_3: i32;
    var sourceDim_1: vec2<f32>;
    var texTransform_1: mat3x3<f32>;
    var translation: vec2<f32>;
    var u_2: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_3 = mode_2;
    sourceDim_1 = sourceDim;
    texTransform_1 = texTransform;
    let _e18 = sourceDim_1;
    let _e21 = sourceDim_1;
    translation = vec2<f32>(((-0.5f * _e18.x) / _e21.y), -0.5f);
    let _e28 = uv_1;
    if (_e28.y < 0f) {
        {
            let _e32 = mode_3;
            mode_3 = (_e32 / 16i);
            let _e36 = translation;
            translation.y = -(_e36.y);
        }
    }
    let _e39 = uv_1;
    if (_e39.x < 0f) {
        {
            let _e43 = mode_3;
            mode_3 = (_e43 / 4i);
            let _e47 = translation;
            translation.x = -(_e47.x);
        }
    }
    let _e50 = mode_3;
    mode_3 = (_e50 % 4i);
    let _e53 = texTransform_1;
    let _e55 = mode_3;
    let _e56 = getFlipTransform(_e55);
    let _e58 = uv_1;
    let _e59 = translation;
    let _e61 = tf((_naga_inverse_3x3_f32(_e53) * _e56), (_e58 + _e59));
    u_2 = _e61;
    let _e63 = u_2;
    let _e67 = global.U[0];
    let _e70 = u_2;
    let _e79 = _mirror_wrap(((vec2<f32>((_e63.x / _e67.x), _e70.y) / vec2(2f)) + vec2(0.5f)));
    let _e80 = textureSample(t_source, samp, _e79);
    return _e80;
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
    let _e66 = global.U[6];
    let _e71 = global.U[4];
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e98 = quadMirror((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.xy, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)));
    fragColor = _e98;
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
