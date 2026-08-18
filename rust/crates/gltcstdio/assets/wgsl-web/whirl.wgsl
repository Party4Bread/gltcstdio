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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn whirl(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, intensity: f32, unwind: f32, highFreqColor: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var intensity_1: f32;
    var unwind_1: f32;
    var highFreqColor_1: vec4<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var bal: f32;
    var ratio2_: f32;
    var ratio2_1: f32;
    var dangle: f32;
    var ca: f32;
    var sa: f32;
    var rotated: vec2<f32>;
    var darken: f32 = 0f;
    var d_1: f32;
    var sHeight: f32;
    var sSlope: f32;
    var coord: vec2<f32>;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    intensity_1 = intensity;
    unwind_1 = unwind;
    highFreqColor_1 = highFreqColor;
    let _e18 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e18);
    let _e21 = inverseModelTransform;
    let _e22 = pos_1;
    let _e23 = tf(_e21, _e22);
    u_2 = _e23;
    let _e25 = u_2;
    d = length(_e25);
    let _e28 = d;
    if (_e28 >= 1f) {
        {
            let _e31 = pos_1;
            let _e35 = global.U[0];
            let _e38 = pos_1;
            let _e47 = _mirror_wrap(((vec2<f32>((_e31.x / _e35.x), _e38.y) / vec2(2f)) + vec2(0.5f)));
            let _e49 = textureSampleLevel(t_source, samp, _e47, 0f);
            return _e49;
        }
    } else {
        {
            let _e50 = unwind_1;
            bal = _e50;
            let _e52 = bal;
            if (_e52 != 0.5f) {
                {
                    let _e55 = bal;
                    let _e58 = d;
                    let _e59 = bal;
                    if ((_e55 == 1f) || (_e58 < _e59)) {
                        {
                            let _e62 = d;
                            let _e63 = bal;
                            ratio2_ = (_e62 / _e63);
                            let _e67 = ratio2_;
                            d = (0.5f * _e67);
                        }
                    } else {
                        {
                            let _e69 = d;
                            let _e70 = bal;
                            let _e73 = bal;
                            ratio2_1 = ((_e69 - _e70) / (1f - _e73));
                            let _e79 = ratio2_1;
                            d = (0.5f * (1f - _e79));
                        }
                    }
                }
            }
            let _e82 = intensity_1;
            let _e86 = d;
            dangle = ((_e82 * 10f) * (1f - cos(((_e86 * 2f) * 3.1415927f))));
            let _e95 = dangle;
            ca = cos(_e95);
            let _e98 = dangle;
            sa = sin(_e98);
            let _e101 = ca;
            let _e102 = u_2;
            let _e105 = sa;
            let _e106 = u_2;
            let _e110 = ca;
            let _e111 = u_2;
            let _e114 = sa;
            let _e115 = u_2;
            rotated = vec2<f32>(((_e101 * _e102.x) - (_e105 * _e106.y)), ((_e110 * _e111.y) + (_e114 * _e115.x)));
            let _e123 = highFreqColor_1;
            if (_e123.w != 0f) {
                {
                    let _e127 = rotated;
                    let _e130 = intensity_1;
                    d_1 = length((_e127 * vec2<f32>(min(1.5f, (1f + abs((_e130 * 3f)))), 1f)));
                    let _e141 = highFreqColor_1;
                    sHeight = (_e141.w * 4f);
                    let _e147 = highFreqColor_1;
                    sSlope = (1f + (_e147.w * 3f));
                    let _e153 = sHeight;
                    let _e154 = d_1;
                    let _e155 = sSlope;
                    darken = clamp((_e153 - (_e154 * _e155)), 0f, 1f);
                }
            }
            let _e161 = modelTransform_1;
            let _e162 = rotated;
            let _e163 = tf(_e161, _e162);
            coord = _e163;
            let _e165 = coord;
            let _e169 = global.U[0];
            let _e172 = coord;
            let _e181 = _mirror_wrap(((vec2<f32>((_e165.x / _e169.x), _e172.y) / vec2(2f)) + vec2(0.5f)));
            let _e183 = textureSampleLevel(t_source, samp, _e181, 0f);
            col = _e183;
            let _e185 = col;
            let _e186 = highFreqColor_1;
            let _e187 = _e186.xyz;
            let _e188 = col;
            let _e194 = darken;
            return mix(_e185, vec4<f32>(_e187.x, _e187.y, _e187.z, _e188.w), vec4(_e194));
        }
    }
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e95 = global.U[9];
    let _e99 = global.U[10];
    let _e100 = whirl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.x, _e99);
    fragColor = _e100;
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
