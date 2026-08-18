struct Params {
    U: array<vec4<f32>, 9>,
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

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e16 = sa;
    let _e18 = ca;
    return mat2x2<f32>(vec2<f32>(_e14, _e15), vec2<f32>(-(_e16), _e18));
}

fn emboss(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, balance: f32, delta: f32, angle_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var delta_1: f32;
    var angle_3: f32;
    var step: vec2<f32>;
    var uv: vec2<f32>;
    var grad: vec2<f32>;
    var diff: f32;
    var absDiff: f32;
    var k: f32;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    balance_1 = balance;
    delta_1 = delta;
    angle_3 = angle_2;
    let _e18 = delta_1;
    step = vec2<f32>((_e18 / 2f), 0f);
    let _e24 = pos_1;
    uv = _e24;
    let _e26 = uv;
    let _e27 = step;
    let _e32 = global.U[0];
    let _e35 = uv;
    let _e36 = step;
    let _e46 = textureSample(t_source, samp, ((vec2<f32>(((_e26 + _e27).x / _e32.x), (_e35 + _e36).y) / vec2(2f)) + vec2(0.5f)));
    let _e48 = luma(_e46.xyz);
    let _e49 = uv;
    let _e50 = step;
    let _e55 = global.U[0];
    let _e58 = uv;
    let _e59 = step;
    let _e69 = textureSample(t_source, samp, ((vec2<f32>(((_e49 - _e50).x / _e55.x), (_e58 - _e59).y) / vec2(2f)) + vec2(0.5f)));
    let _e71 = luma(_e69.xyz);
    let _e73 = uv;
    let _e74 = step;
    let _e80 = global.U[0];
    let _e83 = uv;
    let _e84 = step;
    let _e95 = textureSample(t_source, samp, ((vec2<f32>(((_e73 + _e74.yx).x / _e80.x), (_e83 + _e84.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e97 = luma(_e95.xyz);
    let _e98 = uv;
    let _e99 = step;
    let _e105 = global.U[0];
    let _e108 = uv;
    let _e109 = step;
    let _e120 = textureSample(t_source, samp, ((vec2<f32>(((_e98 - _e99.yx).x / _e105.x), (_e108 - _e109.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e122 = luma(_e120.xyz);
    let _e125 = delta_1;
    grad = (vec2<f32>((_e48 - _e71), (_e97 - _e122)) / vec2(_e125));
    let _e129 = grad;
    let _e130 = angle_3;
    let _e131 = rotation2_(_e130);
    diff = dot(_e129, (_e131 * vec2<f32>(0f, 1f)));
    let _e138 = diff;
    absDiff = abs(_e138);
    let _e142 = diff;
    let _e143 = absDiff;
    let _e144 = balance_1;
    let _e146 = intensity_1;
    k = (1f + ((mix(_e142, _e143, _e144) * _e146) * 0.2f));
    let _e152 = pos_1;
    let _e156 = global.U[0];
    let _e159 = pos_1;
    let _e168 = textureSample(t_source, samp, ((vec2<f32>((_e152.x / _e156.x), _e159.y) / vec2(2f)) + vec2(0.5f)));
    col = _e168;
    let _e170 = col;
    let _e172 = k;
    let _e173 = (_e170.xyz * _e172);
    let _e174 = col;
    return vec4<f32>(_e173.x, _e173.y, _e173.z, _e174.w);
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
    let _e80 = emboss((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x);
    fragColor = _e80;
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
