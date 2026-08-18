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

fn kaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, modelTransform: mat3x3<f32>, offset: f32, stretch: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offset_1: f32;
    var stretch_1: f32;
    var u: vec2<f32>;
    var a: f32;
    var period: f32;
    var halfPeriod: f32;
    var index: f32;
    var d: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    modelTransform_1 = modelTransform;
    offset_1 = offset;
    stretch_1 = stretch;
    let _e18 = uv_1;
    u = _e18;
    let _e20 = u;
    let _e22 = u;
    a = abs(atan2(_e20.x, _e22.y));
    let _e28 = spikeCount_1;
    period = (6.2831855f / f32(_e28));
    let _e32 = period;
    halfPeriod = (_e32 * 0.5f);
    let _e36 = a;
    let _e37 = period;
    index = floor((_e36 / _e37));
    let _e41 = a;
    let _e42 = period;
    a = (_e41 - (floor((_e41 / _e42)) * _e42));
    let _e47 = a;
    let _e48 = halfPeriod;
    if (_e47 > _e48) {
        {
            let _e50 = period;
            let _e51 = a;
            a = (_e50 - _e51);
            let _e53 = offset_1;
            let _e54 = index;
            let _e58 = halfPeriod;
            let _e59 = offset_1;
            let _e60 = index;
            let _e65 = a;
            let _e66 = halfPeriod;
            a = mix((_e53 * (_e54 + 1f)), (_e58 + (_e59 * (_e60 + 1f))), (_e65 / _e66));
        }
    } else {
        {
            let _e69 = offset_1;
            let _e70 = index;
            let _e72 = halfPeriod;
            let _e73 = offset_1;
            let _e74 = index;
            let _e79 = a;
            let _e80 = halfPeriod;
            a = mix((_e69 * _e70), (_e72 + (_e73 * (_e74 + 1f))), (_e79 / _e80));
        }
    }
    let _e83 = u;
    d = length(_e83);
    let _e86 = d;
    let _e87 = a;
    let _e89 = a;
    u = (_e86 * vec2<f32>(cos(_e87), sin(_e89)));
    let _e93 = modelTransform_1;
    let _e95 = u;
    let _e103 = stretch_1;
    let _e106 = d;
    u = ((_naga_inverse_3x3_f32(_e93) * vec3<f32>(_e95.x, _e95.y, 1f)).xy * pow(2f, (-(_e103) * max(0f, _e106))));
    let _e111 = u;
    let _e115 = global.U[0];
    let _e118 = u;
    let _e127 = _mirror_wrap(((vec2<f32>((_e111.x / _e115.x), _e118.y) / vec2(2f)) + vec2(0.5f)));
    let _e128 = textureSample(t_source, samp, _e127);
    return _e128;
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
    let _e72 = _e71.xyz;
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e96 = global.U[9];
    let _e100 = global.U[10];
    let _e102 = kaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x);
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
