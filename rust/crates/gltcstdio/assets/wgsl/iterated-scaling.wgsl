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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn iteratedScaling(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, iterations: i32, offset: f32, texTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var iterations_1: i32;
    var offset_1: f32;
    var texTransform_1: mat3x3<f32>;
    var ratio: f32;
    var u_2: vec2<f32>;
    var len: f32;
    var indexes: vec2<f32>;
    var index: f32;
    var s: vec2<f32>;
    var shift: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    iterations_1 = iterations;
    offset_1 = offset;
    texTransform_1 = texTransform;
    let _e18 = sourceDim_1;
    let _e20 = sourceDim_1;
    ratio = (_e18.x / _e20.y);
    let _e24 = pos_1;
    let _e25 = ratio;
    u_2 = (_e24 / vec2<f32>(_e25, 1f));
    let _e30 = u_2;
    let _e33 = (_e30.x + 1f);
    let _e39 = u_2;
    let _e42 = (_e39.y + 1f);
    u_2 = (vec2<f32>((_e33 - (floor((_e33 / 2f)) * 2f)), (_e42 - (floor((_e42 / 2f)) * 2f))) - vec2<f32>(1f, 1f));
    let _e55 = iterations_1;
    len = (3f - (pow(0.5f, (f32(_e55) - 1f)) * 2f));
    let _e64 = u_2;
    let _e65 = len;
    u_2 = (_e64 * _e65);
    let _e68 = u_2;
    indexes = floor((-(log((vec2(3f) - abs(_e68)))) / vec2(0.6931472f)));
    let _e80 = indexes;
    let _e82 = indexes;
    index = max(_e80.x, _e82.y);
    let _e86 = u_2;
    s = sign(_e86);
    let _e89 = u_2;
    u_2 = abs(_e89);
    let _e92 = index;
    shift = pow(0.5f, _e92);
    let _e98 = shift;
    let _e101 = u_2;
    u_2 = ((vec2<f32>(2f, 2f) - vec2(_e98)) - _e101);
    let _e106 = u_2;
    u_2 = (vec2<f32>(1f, 1f) - _e106);
    let _e108 = u_2;
    let _e115 = u_2;
    u_2 = vec2<f32>((_e108.x - (floor((_e108.x / 1f)) * 1f)), (_e115.y - (floor((_e115.y / 1f)) * 1f)));
    let _e123 = index;
    if (_e123 == -2f) {
        let _e127 = u_2;
        let _e128 = s;
        u_2 = (_e127 * _e128);
    } else {
        let _e130 = u_2;
        let _e132 = index;
        let _e137 = s;
        u_2 = (((_e130 * pow(2f, (_e132 + 2f))) * _e137) - vec2(1f));
    }
    let _e142 = u_2;
    let _e143 = ratio;
    u_2 = (_e142 * vec2<f32>(_e143, 1f));
    let _e147 = texTransform_1;
    let _e149 = u_2;
    let _e150 = tf(_naga_inverse_3x3_f32(_e147), _e149);
    let _e151 = offset_1;
    let _e152 = pos_1;
    let _e158 = global.U[0];
    let _e161 = texTransform_1;
    let _e163 = u_2;
    let _e164 = tf(_naga_inverse_3x3_f32(_e161), _e163);
    let _e165 = offset_1;
    let _e166 = pos_1;
    let _e177 = textureSample(t_source, samp, ((vec2<f32>(((_e150 + (_e151 * _e152)).x / _e158.x), (_e164 + (_e165 * _e166)).y) / vec2(2f)) + vec2(0.5f)));
    return _e177;
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e102 = iteratedScaling((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
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
