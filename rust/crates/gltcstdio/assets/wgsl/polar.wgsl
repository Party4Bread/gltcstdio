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

fn polar(r: f32, angle: f32) -> vec2<f32> {
    var r_1: f32;
    var angle_1: f32;

    r_1 = r;
    angle_1 = angle;
    let _e10 = r_1;
    let _e11 = angle_1;
    let _e13 = angle_1;
    return (_e10 * vec2<f32>(cos(_e11), sin(_e13)));
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

fn polar_1(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, dampening: f32, blend: f32, mirrorMode: i32, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var blend_1: f32;
    var mirrorMode_1: i32;
    var texTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var inverseTexTransform: mat3x3<f32>;
    var d: f32;
    var local: f32;
    var p: f32;
    var angle_2: f32;
    var phase: f32 = 0f;
    var blendedWidth: f32;
    var fullRatio: f32;
    var blendedRatio: f32;
    var xp: f32;
    var sx: f32;
    var sy: f32;
    var xpp: f32;
    var blendStart: f32;
    var pos: vec2<f32>;
    var k: f32;
    var pos1_: vec2<f32>;
    var local_1: f32;
    var sx2_: f32;
    var pos2_: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    dampening_1 = dampening;
    blend_1 = blend;
    mirrorMode_1 = mirrorMode;
    texTransform_1 = texTransform;
    let _e22 = uv_1;
    u_2 = _e22;
    let _e24 = texTransform_1;
    inverseTexTransform = _naga_inverse_3x3_f32(_e24);
    let _e27 = u_2;
    d = length(_e27);
    let _e31 = intensity_1;
    if (_e31 > 0f) {
        let _e34 = intensity_1;
        local = (_e34 * 3f);
    } else {
        let _e37 = intensity_1;
        local = (_e37 * 0.99f);
    }
    let _e41 = local;
    p = (1f + _e41);
    let _e44 = u_2;
    let _e46 = u_2;
    angle_2 = atan2(_e44.y, _e46.x);
    let _e52 = mirrorMode_1;
    if (_e52 == 1i) {
        {
            let _e56 = angle_2;
            let _e57 = phase;
            angle_2 = (2f * (_e56 + _e57));
            let _e60 = angle_2;
            angle_2 = (_e60 - (floor((_e60 / 12.566371f)) * 12.566371f));
            let _e66 = angle_2;
            if (_e66 > 6.2831855f) {
                {
                    let _e70 = angle_2;
                    angle_2 = (12.566371f - _e70);
                }
            }
        }
    } else {
        {
            let _e72 = angle_2;
            let _e73 = phase;
            angle_2 = (_e72 + _e73);
            let _e75 = angle_2;
            angle_2 = (_e75 - (floor((_e75 / 6.2831855f)) * 6.2831855f));
        }
    }
    let _e81 = sourceDim_1;
    let _e84 = blend_1;
    blendedWidth = (_e81.x * (1f - (_e84 * 0.5f)));
    let _e90 = sourceDim_1;
    let _e92 = sourceDim_1;
    fullRatio = (_e90.x / _e92.y);
    let _e96 = blendedWidth;
    let _e97 = sourceDim_1;
    blendedRatio = (_e96 / _e97.y);
    let _e101 = angle_2;
    xp = ((_e101 / 3.1415927f) - 1f);
    let _e107 = blendedRatio;
    let _e108 = xp;
    sx = (_e107 * _e108);
    let _e112 = d;
    let _e115 = p;
    sy = (1f - (pow((_e112 / 2f), _e115) * 2f));
    let _e121 = xp;
    let _e122 = fullRatio;
    let _e124 = blendedRatio;
    xpp = ((_e121 / _e122) * _e124);
    let _e128 = blend_1;
    blendStart = (1f - _e128);
    let _e131 = xpp;
    let _e133 = blendStart;
    if (abs(_e131) <= _e133) {
        {
            let _e135 = sx;
            let _e136 = sy;
            pos = vec2<f32>(_e135, _e136);
            let _e139 = inverseTexTransform;
            let _e140 = pos;
            let _e141 = tf(_e139, _e140);
            let _e145 = global.U[0];
            let _e148 = inverseTexTransform;
            let _e149 = pos;
            let _e150 = tf(_e148, _e149);
            let _e159 = textureSample(t_source, samp, ((vec2<f32>((_e141.x / _e145.x), _e150.y) / vec2(2f)) + vec2(0.5f)));
            return _e159;
        }
    } else {
        {
            let _e160 = xpp;
            let _e162 = blendStart;
            let _e164 = blend_1;
            k = ((abs(_e160) - _e162) / _e164);
            let _e167 = sx;
            let _e168 = sy;
            pos1_ = vec2<f32>(_e167, _e168);
            let _e171 = xp;
            if (_e171 >= 0f) {
                let _e174 = sx;
                let _e175 = blendedRatio;
                local_1 = (_e174 - (_e175 * 2f));
            } else {
                let _e179 = sx;
                let _e180 = blendedRatio;
                local_1 = (_e179 + (_e180 * 2f));
            }
            let _e185 = local_1;
            sx2_ = _e185;
            let _e187 = sx2_;
            let _e188 = sy;
            pos2_ = vec2<f32>(_e187, _e188);
            let _e191 = inverseTexTransform;
            let _e192 = pos1_;
            let _e193 = tf(_e191, _e192);
            let _e197 = global.U[0];
            let _e200 = inverseTexTransform;
            let _e201 = pos1_;
            let _e202 = tf(_e200, _e201);
            let _e211 = textureSample(t_source, samp, ((vec2<f32>((_e193.x / _e197.x), _e202.y) / vec2(2f)) + vec2(0.5f)));
            let _e212 = inverseTexTransform;
            let _e213 = pos2_;
            let _e214 = tf(_e212, _e213);
            let _e218 = global.U[0];
            let _e221 = inverseTexTransform;
            let _e222 = pos2_;
            let _e223 = tf(_e221, _e222);
            let _e232 = textureSample(t_source, samp, ((vec2<f32>((_e214.x / _e218.x), _e223.y) / vec2(2f)) + vec2(0.5f)));
            let _e233 = k;
            return mix(_e211, _e232, vec4(_e233));
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = polar_1((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, i32(_e82.x), mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
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
