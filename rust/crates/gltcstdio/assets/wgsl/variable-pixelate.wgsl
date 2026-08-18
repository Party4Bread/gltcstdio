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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn pixelateVariable(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, regularity: f32, balance: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var regularity_1: f32;
    var balance_1: f32;
    var invModelTransform: mat3x3<f32>;
    var sampledColor: vec4<f32>;
    var uu: vec2<f32>;
    var scale: f32 = 1f;
    var i: i32 = 0i;
    var sM: mat3x3<f32>;
    var isM: mat3x3<f32>;
    var v: vec2<f32>;
    var pix: vec2<f32>;
    var u_2: vec2<f32>;
    var local: f32;
    var scale2_: f32;
    var sM2_: mat3x3<f32>;
    var isM2_: mat3x3<f32>;
    var total: f32;
    var j: i32;
    var i_1: i32;
    var other: vec4<f32>;
    var dist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    regularity_1 = regularity;
    balance_1 = balance;
    let _e16 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e16);
    loop {
        let _e25 = i;
        if !((_e25 < 5i)) {
            break;
        }
        {
            let _e32 = scale;
            let _e36 = scale;
            sM = mat3x3<f32>(vec3<f32>(_e32, 0f, 0f), vec3<f32>(0f, _e36, 0f), vec3<f32>(0f, 0f, 1f));
            let _e47 = scale;
            let _e53 = scale;
            isM = mat3x3<f32>(vec3<f32>((1f / _e47), 0f, 0f), vec3<f32>(0f, (1f / _e53), 0f), vec3<f32>(0f, 0f, 1f));
            let _e64 = isM;
            let _e65 = invModelTransform;
            let _e67 = pos_1;
            let _e68 = tf((_e64 * _e65), _e67);
            v = _e68;
            let _e70 = v;
            pix = round(_e70);
            let _e73 = modelTransform_1;
            let _e74 = sM;
            let _e76 = pix;
            let _e77 = tf((_e73 * _e74), _e76);
            u_2 = _e77;
            let _e79 = u_2;
            let _e83 = global.U[0];
            let _e86 = u_2;
            let _e95 = _mirror_wrap(((vec2<f32>((_e79.x / _e83.x), _e86.y) / vec2(2f)) + vec2(0.5f)));
            let _e96 = textureSample(t_source, samp, _e95);
            sampledColor = _e96;
            let _e97 = regularity_1;
            if (_e97 == 0f) {
                local = 0.0000001f;
            } else {
                let _e101 = regularity_1;
                let _e104 = scale;
                local = ((_e101 * 2f) * _e104);
            }
            let _e107 = local;
            scale2_ = _e107;
            let _e109 = scale2_;
            let _e113 = scale2_;
            sM2_ = mat3x3<f32>(vec3<f32>(_e109, 0f, 0f), vec3<f32>(0f, _e113, 0f), vec3<f32>(0f, 0f, 1f));
            let _e124 = scale2_;
            let _e130 = scale2_;
            isM2_ = mat3x3<f32>(vec3<f32>((1f / _e124), 0f, 0f), vec3<f32>(0f, (1f / _e130), 0f), vec3<f32>(0f, 0f, 1f));
            let _e141 = isM2_;
            let _e142 = invModelTransform;
            let _e144 = pos_1;
            let _e145 = tf((_e141 * _e142), _e144);
            v = _e145;
            let _e146 = v;
            pix = round(_e146);
            let _e148 = modelTransform_1;
            let _e149 = sM2_;
            let _e151 = pix;
            let _e152 = tf((_e148 * _e149), _e151);
            u_2 = _e152;
            total = 0f;
            j = -1i;
            loop {
                let _e158 = j;
                if !((_e158 <= 1i)) {
                    break;
                }
                {
                    i_1 = -1i;
                    loop {
                        let _e168 = i_1;
                        if !((_e168 <= 1i)) {
                            break;
                        }
                        {
                            let _e175 = u_2;
                            let _e176 = scale;
                            let _e179 = i_1;
                            let _e181 = j;
                            let _e189 = global.U[0];
                            let _e192 = u_2;
                            let _e193 = scale;
                            let _e196 = i_1;
                            let _e198 = j;
                            let _e211 = _mirror_wrap(((vec2<f32>(((_e175 + ((_e176 * 0.5f) * vec2<f32>(f32(_e179), f32(_e181)))).x / _e189.x), (_e192 + ((_e193 * 0.5f) * vec2<f32>(f32(_e196), f32(_e198)))).y) / vec2(2f)) + vec2(0.5f)));
                            let _e212 = textureSample(t_source, samp, _e211);
                            other = _e212;
                            let _e214 = total;
                            let _e215 = sampledColor;
                            let _e217 = other;
                            total = (_e214 + length((_e215.xyz - _e217.xyz)));
                        }
                        continuing {
                            let _e172 = i_1;
                            i_1 = (_e172 + 1i);
                        }
                    }
                }
                continuing {
                    let _e162 = j;
                    j = (_e162 + 1i);
                }
            }
            let _e222 = total;
            dist = (_e222 / 8f);
            let _e226 = dist;
            let _e228 = balance_1;
            if (_e226 >= ((0.5f + (_e228 * 0.5f)) * 1.717f)) {
                break;
            }
            let _e235 = scale;
            scale = (_e235 * 2f);
        }
        continuing {
            let _e29 = i;
            i = (_e29 + 1i);
        }
    }
    let _e238 = sampledColor;
    return _e238;
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
    let _e97 = pixelateVariable((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x, _e95.x);
    fragColor = _e97;
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
