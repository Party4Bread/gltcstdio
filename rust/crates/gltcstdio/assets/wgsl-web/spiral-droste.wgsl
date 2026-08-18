struct Params {
    U: array<vec4<f32>, 15>,
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

fn spiralDroste(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, distortion: f32, thickness: f32, shadows: f32, colorShadow: vec4<f32>, colorBorder: vec4<f32>, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var thickness_1: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var colorBorder_1: vec4<f32>;
    var texTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var local: f32;
    var p: f32;
    var angle: f32;
    var widthAngle: f32 = 0.7853982f;
    var scale360_: f32;
    var a: f32;
    var s: f32;
    var dd: f32;
    var ddd: f32;
    var coord: vec2<f32>;
    var winding: f32;
    var scoord: vec2<f32>;
    var ds: f32;
    var local_1: f32;
    var shadowing: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    distortion_1 = distortion;
    thickness_1 = thickness;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    colorBorder_1 = colorBorder;
    texTransform_1 = texTransform;
    let _e26 = uv_1;
    u_2 = _e26;
    let _e28 = u_2;
    d = length(_e28);
    let _e31 = intensity_1;
    if (_e31 > 0f) {
        let _e36 = intensity_1;
        local = (1f / (1f + (_e36 * 10f)));
    } else {
        let _e42 = intensity_1;
        local = (1f + pow((-(_e42) * 100f), 0.75f));
    }
    let _e50 = local;
    p = _e50;
    let _e52 = u_2;
    let _e54 = u_2;
    angle = atan2(_e52.y, _e54.x);
    let _e62 = angle;
    angle = (_e62 - (floor((_e62 / 6.2831855f)) * 6.2831855f));
    let _e68 = intensity_1;
    let _e69 = intensity_1;
    scale360_ = ((_e68 * _e69) * 0.1f);
    let _e74 = angle;
    a = (_e74 / 6.2831855f);
    let _e78 = scale360_;
    let _e79 = a;
    s = pow(_e78, _e79);
    let _e82 = d;
    let _e83 = s;
    let _e86 = scale360_;
    dd = (log((_e82 * _e83)) / log(_e86));
    let _e90 = dd;
    ddd = (_e90 - (floor((_e90 / 1f)) * 1f));
    let _e97 = ddd;
    let _e98 = thickness_1;
    if (_e97 < _e98) {
        let _e100 = colorBorder_1;
        return _e100;
    }
    let _e101 = ddd;
    let _e102 = ddd;
    let _e108 = distortion_1;
    let _e111 = angle;
    let _e113 = angle;
    coord = (mix(_e101, (exp(_e102) / 2.7182817f), (1f - _e108)) * vec2<f32>(cos(_e111), sin(_e113)));
    let _e118 = dd;
    let _e119 = ddd;
    let _e121 = a;
    winding = ((_e118 - _e119) - _e121);
    let _e124 = coord;
    let _e125 = shadows_1;
    let _e131 = scale360_;
    let _e132 = winding;
    let _e135 = shadows_1;
    scoord = (_e124 - ((_e125 * vec2<f32>(1f, 1f)) * mix(1f, pow(_e131, -(_e132)), (_e135 * 0.1f))));
    let _e142 = scoord;
    ds = length(_e142);
    let _e146 = ds;
    if (_e146 > 1f) {
        let _e153 = ds;
        let _e158 = shadows_1;
        local_1 = mix(1f, max(0f, (6f - (5f * _e153))), (0.5f + (_e158 * 0.5f)));
    } else {
        local_1 = 1f;
    }
    let _e165 = local_1;
    shadowing = (1f - _e165);
    let _e168 = texTransform_1;
    let _e170 = coord;
    let _e171 = tf(_naga_inverse_3x3_f32(_e168), _e170);
    let _e175 = global.U[0];
    let _e178 = texTransform_1;
    let _e180 = coord;
    let _e181 = tf(_naga_inverse_3x3_f32(_e178), _e180);
    let _e191 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e171.x / _e175.x), _e181.y) / vec2(2f)) + vec2(0.5f)), 0f);
    let _e192 = colorShadow_1;
    let _e193 = shadowing;
    return mix(_e191, _e192, vec4(_e193));
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
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e92 = global.U[12];
    let _e93 = _e92.xyz;
    let _e96 = global.U[13];
    let _e97 = _e96.xyz;
    let _e100 = global.U[14];
    let _e101 = _e100.xyz;
    let _e115 = spiralDroste((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, _e82.x, _e86, _e89, mat3x3<f32>(vec3<f32>(_e93.x, _e93.y, _e93.z), vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z)));
    fragColor = _e115;
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
