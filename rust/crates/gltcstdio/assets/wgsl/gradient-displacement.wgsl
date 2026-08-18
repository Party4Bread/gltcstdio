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

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e10 = c_3;
    let _e14 = c_3;
    let _e19 = c_3;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e9 = angle_1;
    ca = cos(_e9);
    let _e12 = angle_1;
    sa = sin(_e12);
    let _e15 = ca;
    let _e16 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat2x2<f32>(vec2<f32>(_e15, _e16), vec2<f32>(-(_e17), _e19));
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

fn gradientDisplacement(pos: vec2<f32>, outPos: vec2<f32>, displacement_specified: i32, intensity: f32, delta: f32, angle_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var displacement_specified_1: i32;
    var intensity_1: f32;
    var delta_1: f32;
    var angle_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var step: vec2<f32>;
    var uv: vec2<f32>;
    var local: vec2<f32>;
    var grad: vec2<f32>;
    var rot: mat2x2<f32>;
    var disp: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    displacement_specified_1 = displacement_specified;
    intensity_1 = intensity;
    delta_1 = delta;
    angle_3 = angle_2;
    modelTransform_1 = modelTransform;
    let _e21 = delta_1;
    step = vec2<f32>((_e21 / 2f), 0f);
    let _e27 = modelTransform_1;
    let _e29 = pos_1;
    let _e30 = tf(_naga_inverse_3x3_f32(_e27), _e29);
    uv = _e30;
    let _e32 = displacement_specified_1;
    if (_e32 == 1i) {
        let _e35 = uv;
        let _e36 = step;
        let _e41 = global.U[0];
        let _e44 = uv;
        let _e45 = step;
        let _e55 = _mirror_wrap(((vec2<f32>(((_e35 + _e36).x / _e41.x), (_e44 + _e45).y) / vec2(2f)) + vec2(0.5f)));
        let _e56 = textureSample(t_displacement, samp, _e55);
        let _e58 = luma(_e56.xyz);
        let _e59 = uv;
        let _e60 = step;
        let _e65 = global.U[0];
        let _e68 = uv;
        let _e69 = step;
        let _e79 = _mirror_wrap(((vec2<f32>(((_e59 - _e60).x / _e65.x), (_e68 - _e69).y) / vec2(2f)) + vec2(0.5f)));
        let _e80 = textureSample(t_displacement, samp, _e79);
        let _e82 = luma(_e80.xyz);
        let _e84 = uv;
        let _e85 = step;
        let _e91 = global.U[0];
        let _e94 = uv;
        let _e95 = step;
        let _e106 = _mirror_wrap(((vec2<f32>(((_e84 + _e85.yx).x / _e91.x), (_e94 + _e95.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e107 = textureSample(t_displacement, samp, _e106);
        let _e109 = luma(_e107.xyz);
        let _e110 = uv;
        let _e111 = step;
        let _e117 = global.U[0];
        let _e120 = uv;
        let _e121 = step;
        let _e132 = _mirror_wrap(((vec2<f32>(((_e110 - _e111.yx).x / _e117.x), (_e120 - _e121.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e133 = textureSample(t_displacement, samp, _e132);
        let _e135 = luma(_e133.xyz);
        let _e138 = delta_1;
        local = (vec2<f32>((_e58 - _e82), (_e109 - _e135)) / vec2(_e138));
    } else {
        let _e141 = uv;
        let _e142 = step;
        let _e147 = global.U[0];
        let _e150 = uv;
        let _e151 = step;
        let _e161 = _mirror_wrap(((vec2<f32>(((_e141 + _e142).x / _e147.x), (_e150 + _e151).y) / vec2(2f)) + vec2(0.5f)));
        let _e162 = textureSample(t_source1_, samp, _e161);
        let _e164 = luma(_e162.xyz);
        let _e165 = uv;
        let _e166 = step;
        let _e171 = global.U[0];
        let _e174 = uv;
        let _e175 = step;
        let _e185 = _mirror_wrap(((vec2<f32>(((_e165 - _e166).x / _e171.x), (_e174 - _e175).y) / vec2(2f)) + vec2(0.5f)));
        let _e186 = textureSample(t_source1_, samp, _e185);
        let _e188 = luma(_e186.xyz);
        let _e190 = uv;
        let _e191 = step;
        let _e197 = global.U[0];
        let _e200 = uv;
        let _e201 = step;
        let _e212 = _mirror_wrap(((vec2<f32>(((_e190 + _e191.yx).x / _e197.x), (_e200 + _e201.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e213 = textureSample(t_source1_, samp, _e212);
        let _e215 = luma(_e213.xyz);
        let _e216 = uv;
        let _e217 = step;
        let _e223 = global.U[0];
        let _e226 = uv;
        let _e227 = step;
        let _e238 = _mirror_wrap(((vec2<f32>(((_e216 - _e217.yx).x / _e223.x), (_e226 - _e227.yx).y) / vec2(2f)) + vec2(0.5f)));
        let _e239 = textureSample(t_source1_, samp, _e238);
        let _e241 = luma(_e239.xyz);
        let _e244 = delta_1;
        local = (vec2<f32>((_e164 - _e188), (_e215 - _e241)) / vec2(_e244));
    }
    let _e248 = local;
    grad = _e248;
    let _e250 = angle_3;
    let _e251 = rotation2_(_e250);
    rot = _e251;
    let _e253 = rot;
    let _e254 = grad;
    let _e256 = intensity_1;
    disp = (((_e253 * _e254) * _e256) * 0.01f);
    let _e261 = pos_1;
    let _e262 = disp;
    let _e267 = global.U[0];
    let _e270 = pos_1;
    let _e271 = disp;
    let _e281 = _mirror_wrap(((vec2<f32>(((_e261 + _e262).x / _e267.x), (_e270 + _e271).y) / vec2(2f)) + vec2(0.5f)));
    let _e282 = textureSample(t_source1_, samp, _e281);
    return _e282;
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
    let _e67 = global.U[4];
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e92 = global.U[11];
    let _e93 = _e92.xyz;
    let _e107 = gradientDisplacement((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, mat3x3<f32>(vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z)));
    fragColor = _e107;
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
