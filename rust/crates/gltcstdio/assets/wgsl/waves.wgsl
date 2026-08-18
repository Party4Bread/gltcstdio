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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
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

fn waves(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, lighting: f32, variability: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var lighting_1: f32;
    var variability_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var v_2: vec2<f32>;
    var local: f32;
    var d: f32;
    var xx: f32;
    var i: f32;
    var di: f32;
    var r0_: f32;
    var rNeighbor: f32;
    var vary: f32;
    var magnitude: f32;
    var w: vec2<f32>;
    var u_2: vec2<f32>;
    var outCol: vec4<f32>;
    var offset: f32;
    var grad: vec2<f32>;
    var light: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    lighting_1 = lighting;
    variability_1 = variability;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = uv_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    v_2 = _e23;
    let _e25 = dampening_1;
    if (_e25 == 0f) {
        local = 1f;
    } else {
        let _e30 = dampening_1;
        let _e33 = dampening_1;
        let _e35 = v_2;
        local = smoothstep((5f / _e30), (0.5f / _e33), abs(_e35.x));
    }
    let _e40 = local;
    d = _e40;
    let _e42 = v_2;
    xx = ((_e42.x - 1.5707963f) / 3.1415927f);
    let _e49 = xx;
    i = floor(_e49);
    let _e52 = xx;
    let _e53 = i;
    di = (_e52 - _e53);
    let _e56 = i;
    let _e57 = i;
    let _e59 = rand2_(vec2<f32>(_e56, _e57));
    r0_ = _e59.x;
    let _e63 = di;
    if (_e63 < 0.5f) {
        {
            let _e66 = i;
            let _e69 = i;
            let _e73 = rand2_(vec2<f32>((_e66 - 1f), (_e69 - 1f)));
            rNeighbor = _e73.x;
            let _e76 = di;
            di = (0.5f - _e76);
        }
    } else {
        {
            let _e78 = i;
            let _e81 = i;
            let _e85 = rand2_(vec2<f32>((_e78 + 1f), (_e81 + 1f)));
            rNeighbor = _e85.x;
            let _e87 = di;
            di = (_e87 - 0.5f);
        }
    }
    let _e90 = r0_;
    let _e91 = rNeighbor;
    let _e92 = di;
    let _e93 = di;
    vary = mix(_e90, _e91, ((_e92 * _e93) * 2f));
    let _e99 = intensity_1;
    let _e101 = variability_1;
    let _e102 = vary;
    magnitude = (_e99 * (1f + ((_e101 * (_e102 - 0.5f)) * 2f)));
    let _e111 = v_2;
    let _e113 = v_2;
    let _e115 = magnitude;
    let _e116 = v_2;
    let _e120 = d;
    w = vec2<f32>(_e111.x, (_e113.y + ((_e115 * cos(_e116.x)) * _e120)));
    let _e125 = modelTransform_1;
    let _e126 = w;
    let _e127 = tf(_e125, _e126);
    u_2 = _e127;
    let _e129 = u_2;
    let _e133 = global.U[0];
    let _e136 = u_2;
    let _e145 = _mirror_wrap(((vec2<f32>((_e129.x / _e133.x), _e136.y) / vec2(2f)) + vec2(0.5f)));
    let _e146 = textureSample(t_source, samp, _e145);
    outCol = _e146;
    let _e148 = lighting_1;
    if (_e148 > 0f) {
        {
            let _e151 = magnitude;
            let _e152 = v_2;
            let _e156 = d;
            offset = ((_e151 * cos(_e152.x)) * _e156);
            let _e159 = offset;
            let _e160 = dpdx(_e159);
            let _e161 = uv_1;
            let _e163 = dpdx(_e161.x);
            let _e165 = offset;
            let _e166 = dpdy(_e165);
            let _e167 = uv_1;
            let _e169 = dpdy(_e167.y);
            grad = vec2<f32>((_e160 / _e163), (_e166 / _e169));
            let _e174 = lighting_1;
            let _e175 = grad;
            let _e176 = modelTransform_1;
            light = (1f + (_e174 * dot(_e175, (mat2x2<f32>(_e176[0].xy, _e176[1].xy) * vec2<f32>(1f, 0f)))));
            let _e192 = outCol;
            let _e194 = outCol;
            let _e196 = light;
            let _e197 = (_e194.xyz * _e196);
            outCol.x = _e197.x;
            outCol.y = _e197.y;
            outCol.z = _e197.z;
        }
    }
    let _e204 = outCol;
    return _e204;
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
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = waves((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
