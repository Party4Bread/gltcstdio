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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn pinch(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, dampening: f32, threshold: f32, highFreqColor: vec4<f32>, sourceDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var dampening_1: f32;
    var threshold_1: f32;
    var highFreqColor_1: vec4<f32>;
    var sourceDim_1: vec2<f32>;
    var u_2: vec2<f32>;
    var y: f32;
    var dTreshold: f32;
    var div: f32 = 1f;
    var kCol: f32;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    dampening_1 = dampening;
    threshold_1 = threshold;
    highFreqColor_1 = highFreqColor;
    sourceDim_1 = sourceDim;
    let _e20 = modelTransform_1;
    let _e22 = pos_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    u_2 = _e23;
    let _e25 = u_2;
    y = abs(_e25.y);
    let _e29 = threshold_1;
    let _e31 = dampening_1;
    dTreshold = (_e29 * (1f + _e31));
    let _e37 = y;
    let _e38 = threshold_1;
    if (_e37 > _e38) {
        {
            let _e40 = y;
            let _e41 = dTreshold;
            if (_e40 > _e41) {
                {
                    let _e43 = y;
                    let _e44 = dampening_1;
                    let _e45 = threshold_1;
                    div = (_e43 - ((_e44 * _e45) * 0.5f));
                }
            } else {
                {
                    let _e50 = threshold_1;
                    let _e51 = dTreshold;
                    let _e52 = dampening_1;
                    let _e53 = threshold_1;
                    let _e58 = y;
                    let _e59 = threshold_1;
                    let _e61 = dTreshold;
                    let _e62 = threshold_1;
                    div = mix(_e50, (_e51 - ((_e52 * _e53) * 0.5f)), pow(((_e58 - _e59) / (_e61 - _e62)), 2f));
                }
            }
        }
    } else {
        {
            let _e68 = threshold_1;
            div = _e68;
        }
    }
    let _e70 = u_2;
    let _e72 = div;
    u_2.x = (_e70.x / _e72);
    let _e77 = div;
    let _e80 = highFreqColor_1;
    kCol = smoothstep(0f, 3f, (log((1f / _e77)) * _e80.w));
    let _e85 = modelTransform_1;
    let _e86 = u_2;
    let _e87 = tf(_e85, _e86);
    u_2 = _e87;
    let _e88 = u_2;
    let _e92 = global.U[0];
    let _e95 = u_2;
    let _e104 = _mirror_wrap(((vec2<f32>((_e88.x / _e92.x), _e95.y) / vec2(2f)) + vec2(0.5f)));
    let _e105 = textureSample(t_source, samp, _e104);
    outCol = _e105;
    let _e107 = outCol;
    let _e108 = highFreqColor_1;
    let _e109 = _e108.xyz;
    let _e115 = kCol;
    return mix(_e107, vec4<f32>(_e109.x, _e109.y, _e109.z, 1f), vec4(_e115));
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[7];
    let _e71 = _e70.xyz;
    let _e74 = global.U[8];
    let _e75 = _e74.xyz;
    let _e91 = global.U[9];
    let _e95 = global.U[10];
    let _e99 = global.U[11];
    let _e102 = global.U[4];
    let _e104 = pinch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.x, _e99, _e102.xy);
    fragColor = _e104;
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
