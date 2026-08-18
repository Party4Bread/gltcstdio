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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn polarPlanet(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, dampening: f32, blend: f32, mirrorMode: i32, texTransform: mat3x3<f32>) -> vec4<f32> {
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
    var angle: f32;
    var phase: f32 = 0f;
    var blendedWidth: f32;
    var fullRatio: f32;
    var blendedRatio: f32;
    var xp: f32;
    var sx: f32;
    var I: f32;
    var local: f32;
    var local_1: f32;
    var sy: f32;
    var xpp: f32;
    var blendStart: f32;
    var pos: vec2<f32>;
    var k: f32;
    var pos1_: vec2<f32>;
    var local_2: f32;
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
    let _e30 = u_2;
    let _e32 = u_2;
    angle = atan2(_e30.y, _e32.x);
    let _e38 = mirrorMode_1;
    if (_e38 == 1i) {
        {
            let _e42 = angle;
            let _e43 = phase;
            angle = (2f * (_e42 + _e43));
            let _e46 = angle;
            angle = (_e46 - (floor((_e46 / 12.566371f)) * 12.566371f));
            let _e52 = angle;
            if (_e52 > 6.2831855f) {
                {
                    let _e56 = angle;
                    angle = (12.566371f - _e56);
                }
            }
        }
    } else {
        {
            let _e58 = angle;
            let _e59 = phase;
            angle = (_e58 + _e59);
            let _e61 = angle;
            angle = (_e61 - (floor((_e61 / 6.2831855f)) * 6.2831855f));
        }
    }
    let _e67 = sourceDim_1;
    let _e70 = blend_1;
    blendedWidth = (_e67.x * (1f - (_e70 * 0.5f)));
    let _e76 = sourceDim_1;
    let _e78 = sourceDim_1;
    fullRatio = (_e76.x / _e78.y);
    let _e82 = blendedWidth;
    let _e83 = sourceDim_1;
    blendedRatio = (_e82 / _e83.y);
    let _e87 = angle;
    xp = ((_e87 / 3.1415927f) - 1f);
    let _e93 = blendedRatio;
    let _e94 = xp;
    sx = (_e93 * _e94);
    let _e97 = intensity_1;
    I = _e97;
    let _e99 = d;
    let _e100 = I;
    if (_e99 <= _e100) {
        let _e103 = d;
        local_1 = (1f - (_e103 * 2f));
    } else {
        let _e107 = I;
        if (_e107 < 1f) {
            let _e112 = I;
            let _e116 = I;
            let _e120 = I;
            let _e125 = d;
            let _e127 = I;
            local = (1f - ((2f * _e112) + (((2f - (2f * _e116)) / log((2f - _e120))) * log(((1f + _e125) - _e127)))));
        } else {
            let _e136 = d;
            local = (1f - (2f + (2f * log(_e136))));
        }
        let _e142 = local;
        local_1 = _e142;
    }
    let _e144 = local_1;
    sy = _e144;
    let _e146 = xp;
    let _e147 = fullRatio;
    let _e149 = blendedRatio;
    xpp = ((_e146 / _e147) * _e149);
    let _e153 = blend_1;
    blendStart = (1f - _e153);
    let _e156 = xpp;
    let _e158 = blendStart;
    if (abs(_e156) <= _e158) {
        {
            let _e160 = sx;
            let _e161 = sy;
            pos = vec2<f32>(_e160, _e161);
            let _e164 = inverseTexTransform;
            let _e165 = pos;
            let _e166 = tf(_e164, _e165);
            let _e170 = global.U[0];
            let _e173 = inverseTexTransform;
            let _e174 = pos;
            let _e175 = tf(_e173, _e174);
            let _e185 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e166.x / _e170.x), _e175.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e185;
        }
    } else {
        {
            let _e186 = xpp;
            let _e188 = blendStart;
            let _e190 = blend_1;
            k = ((abs(_e186) - _e188) / _e190);
            let _e193 = sx;
            let _e194 = sy;
            pos1_ = vec2<f32>(_e193, _e194);
            let _e197 = xp;
            if (_e197 >= 0f) {
                let _e200 = sx;
                let _e201 = blendedRatio;
                local_2 = (_e200 - (_e201 * 2f));
            } else {
                let _e205 = sx;
                let _e206 = blendedRatio;
                local_2 = (_e205 + (_e206 * 2f));
            }
            let _e211 = local_2;
            sx2_ = _e211;
            let _e213 = sx2_;
            let _e214 = sy;
            pos2_ = vec2<f32>(_e213, _e214);
            let _e217 = inverseTexTransform;
            let _e218 = pos1_;
            let _e219 = tf(_e217, _e218);
            let _e223 = global.U[0];
            let _e226 = inverseTexTransform;
            let _e227 = pos1_;
            let _e228 = tf(_e226, _e227);
            let _e238 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e219.x / _e223.x), _e228.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e239 = inverseTexTransform;
            let _e240 = pos2_;
            let _e241 = tf(_e239, _e240);
            let _e245 = global.U[0];
            let _e248 = inverseTexTransform;
            let _e249 = pos2_;
            let _e250 = tf(_e248, _e249);
            let _e260 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e241.x / _e245.x), _e250.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e261 = k;
            return mix(_e238, _e260, vec4(_e261));
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
    let _e110 = polarPlanet((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, i32(_e82.x), mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
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
