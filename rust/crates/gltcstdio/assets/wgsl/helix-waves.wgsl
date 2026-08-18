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

fn helixWaves(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, intensity: f32, frequency: f32, lighting: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var intensity_1: f32;
    var frequency_1: f32;
    var lighting_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v: vec2<f32>;
    var ratio: f32;
    var X: f32;
    var local: f32;
    var mirror: f32;
    var d: f32;
    var xx: f32;
    var delta1_: f32;
    var delta2_: f32;
    var local_1: f32;
    var k: f32;
    var delta: f32;
    var light: f32 = 1f;
    var pixel: f32;
    var grad: vec2<f32>;
    var lightDir: vec2<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    intensity_1 = intensity;
    frequency_1 = frequency;
    lighting_1 = lighting;
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e22);
    let _e25 = uv_1;
    u_2 = _e25;
    let _e27 = t;
    let _e28 = uv_1;
    let _e29 = tf(_e27, _e28);
    v = _e29;
    let _e31 = sourceDim_1;
    let _e33 = sourceDim_1;
    ratio = (_e31.x / _e33.y);
    let _e37 = v;
    let _e39 = ratio;
    X = ((_e37.x / _e39) + 1f);
    let _e44 = mode_1;
    if (_e44 == 0i) {
        local = 1f;
    } else {
        let _e48 = X;
        local = sign(((_e48 - (floor((_e48 / 4f)) * 4f)) - 2f));
    }
    let _e58 = local;
    mirror = _e58;
    let _e60 = mirror;
    let _e61 = intensity_1;
    intensity_1 = (_e60 * _e61);
    let _e63 = X;
    d = ((_e63 - (floor((_e63 / 2f)) * 2f)) - 1f);
    let _e72 = v;
    let _e76 = frequency_1;
    let _e79 = intensity_1;
    xx = (sin(((_e72.y * 2f) * _e76)) * _e79);
    let _e85 = d;
    let _e88 = xx;
    let _e93 = d;
    delta1_ = (mix(-1f, 0f, ((_e85 + 1f) / (_e88 + 1f))) - _e93);
    let _e96 = d;
    let _e97 = xx;
    let _e100 = xx;
    let _e103 = d;
    delta2_ = (((_e96 - _e97) / (1f - _e100)) - _e103);
    let _e106 = d;
    let _e107 = xx;
    if (_e106 < _e107) {
        local_1 = 0f;
    } else {
        local_1 = 1f;
    }
    let _e112 = local_1;
    k = _e112;
    let _e114 = delta1_;
    let _e115 = delta2_;
    let _e116 = k;
    delta = mix(_e114, _e115, _e116);
    let _e120 = v;
    let _e122 = delta;
    let _e123 = ratio;
    v.x = (_e120.x + (_e122 * _e123));
    let _e126 = modelTransform_1;
    let _e127 = v;
    let _e128 = tf(_e126, _e127);
    u_2 = _e128;
    let _e131 = lighting_1;
    if (_e131 > 0f) {
        {
            let _e135 = sourceDim_1;
            pixel = (2f / _e135.y);
            let _e139 = delta;
            let _e140 = dpdx(_e139);
            let _e141 = u_2;
            let _e143 = dpdx(_e141.x);
            let _e145 = delta;
            let _e146 = dpdy(_e145);
            let _e147 = u_2;
            let _e149 = dpdy(_e147.y);
            grad = (vec2<f32>((_e140 / _e143), (_e146 / _e149)) * 4f);
            let _e155 = modelTransform_1;
            lightDir = (mat2x2<f32>(_e155[0].xy, _e155[1].xy) * vec2<f32>(0f, -1f));
            let _e170 = lighting_1;
            let _e173 = grad;
            let _e174 = lightDir;
            light = (1f + ((_e170 * 0.2f) * dot(_e173, _e174)));
        }
    }
    let _e178 = u_2;
    let _e182 = global.U[0];
    let _e185 = u_2;
    let _e194 = _mirror_wrap(((vec2<f32>((_e178.x / _e182.x), _e185.y) / vec2(2f)) + vec2(0.5f)));
    let _e195 = textureSample(t_source, samp, _e194);
    outCol = _e195;
    let _e197 = outCol;
    let _e199 = outCol;
    let _e201 = light;
    let _e202 = (_e199.xyz * _e201);
    outCol.x = _e202.x;
    outCol.y = _e202.y;
    outCol.z = _e202.z;
    let _e209 = outCol;
    return _e209;
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
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = helixWaves((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
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
