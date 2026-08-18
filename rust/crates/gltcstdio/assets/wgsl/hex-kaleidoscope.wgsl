struct Params {
    U: array<vec4<f32>, 16>,
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

fn hexPolarCoords(v: vec2<f32>) -> vec4<f32> {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 1.7320508f);
    var h: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;
    var local: vec2<f32>;
    var hv: vec2<f32>;
    var x: f32;
    var y: f32;
    var id: vec2<f32>;

    v_1 = v;
    let _e12 = r;
    h = (_e12 / vec2(2f));
    let _e17 = v_1;
    let _e19 = r;
    let _e25 = v_1;
    let _e27 = r;
    let _e34 = h;
    a = (vec2<f32>((_e17.x - (floor((_e17.x / _e19.x)) * _e19.x)), (_e25.y - (floor((_e25.y / _e27.y)) * _e27.y))) - _e34);
    let _e37 = v_1;
    let _e39 = h;
    let _e41 = (_e37.x - _e39.x);
    let _e42 = r;
    let _e48 = v_1;
    let _e50 = h;
    let _e52 = (_e48.y - _e50.y);
    let _e53 = r;
    let _e60 = h;
    b = (vec2<f32>((_e41 - (floor((_e41 / _e42.x)) * _e42.x)), (_e52 - (floor((_e52 / _e53.y)) * _e53.y))) - _e60);
    let _e63 = a;
    let _e65 = b;
    if (length(_e63) < length(_e65)) {
        let _e68 = a;
        local = _e68;
    } else {
        let _e69 = b;
        local = _e69;
    }
    let _e71 = local;
    hv = _e71;
    let _e73 = hv;
    let _e75 = hv;
    x = atan2(_e73.y, _e75.x);
    let _e79 = hv;
    y = length(_e79);
    let _e82 = v_1;
    let _e83 = hv;
    id = (_e82 - _e83);
    let _e86 = x;
    let _e87 = y;
    let _e88 = id;
    return vec4<f32>(_e86, _e87, _e88.x, _e88.y);
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

fn hexKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, mode: i32, spikeCount: i32, offset: f32, shadows: f32, colorShadow: vec4<f32>, modelTransform: mat3x3<f32>, viewTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var spikeCount_1: i32;
    var offset_1: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var viewTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var hex: vec4<f32>;
    var a_1: f32;
    var anglePeriod: f32;
    var local_1: f32;
    var dv: vec2<f32>;
    var w: vec2<f32>;
    var v_2: vec2<f32>;
    var col: vec4<f32>;
    var hex2_: vec2<f32>;
    var kShadow: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    mode_1 = mode;
    spikeCount_1 = spikeCount;
    offset_1 = offset;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    modelTransform_1 = modelTransform;
    viewTransform_1 = viewTransform;
    shadowTransform_1 = shadowTransform;
    let _e26 = uv_1;
    u_2 = _e26;
    let _e28 = u_2;
    let _e29 = hexPolarCoords(_e28);
    hex = _e29;
    let _e31 = hex;
    a_1 = _e31.x;
    let _e35 = spikeCount_1;
    anglePeriod = (6.2831855f / f32(_e35));
    let _e39 = a_1;
    let _e40 = anglePeriod;
    a_1 = (_e39 - (floor((_e39 / _e40)) * _e40));
    let _e45 = mode_1;
    if (_e45 == 0i) {
        let _e48 = a_1;
        let _e49 = anglePeriod;
        if (_e48 > (_e49 / 2f)) {
            let _e53 = anglePeriod;
            let _e54 = a_1;
            local_1 = (_e53 - _e54);
        } else {
            let _e56 = a_1;
            local_1 = _e56;
        }
        let _e58 = local_1;
        a_1 = _e58;
    }
    let _e59 = offset_1;
    let _e60 = u_2;
    dv = (_e59 * _e60);
    let _e63 = hex;
    let _e65 = a_1;
    let _e67 = a_1;
    w = (_e63.y * vec2<f32>(cos(_e65), sin(_e67)));
    let _e72 = modelTransform_1;
    let _e74 = w;
    let _e75 = dv;
    let _e76 = (_e74 + _e75);
    v_2 = (_naga_inverse_3x3_f32(_e72) * vec3<f32>(_e76.x, _e76.y, 1f)).xy;
    let _e84 = v_2;
    let _e88 = global.U[0];
    let _e91 = v_2;
    let _e100 = _mirror_wrap(((vec2<f32>((_e84.x / _e88.x), _e91.y) / vec2(2f)) + vec2(0.5f)));
    let _e101 = textureSample(t_source, samp, _e100);
    col = _e101;
    let _e103 = shadows_1;
    if (_e103 > 0f) {
        {
            let _e106 = shadowTransform_1;
            let _e108 = hex;
            let _e110 = hex;
            let _e113 = hex;
            let _e118 = tf(_naga_inverse_3x3_f32(_e106), (_e108.y * vec2<f32>(cos(_e110.x), sin(_e113.x))));
            hex2_ = _e118;
            let _e122 = shadows_1;
            let _e127 = hex2_;
            let _e133 = colorShadow_1;
            kShadow = (smoothstep((-0.15f + _e122), -0.15f, ((0.5f - length(_e127)) * 2f)) * _e133.w);
            let _e137 = col;
            let _e139 = col;
            let _e141 = colorShadow_1;
            let _e143 = kShadow;
            let _e145 = mix(_e139.xyz, _e141.xyz, vec3(_e143));
            col.x = _e145.x;
            col.y = _e145.y;
            col.z = _e145.z;
        }
    }
    let _e152 = col;
    return _e152;
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e112 = global.U[1];
    let _e113 = _e112.xyz;
    let _e116 = global.U[2];
    let _e117 = _e116.xyz;
    let _e120 = global.U[3];
    let _e121 = _e120.xyz;
    let _e137 = global.U[13];
    let _e138 = _e137.xyz;
    let _e141 = global.U[14];
    let _e142 = _e141.xyz;
    let _e145 = global.U[15];
    let _e146 = _e145.xyz;
    let _e160 = hexKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80.x, _e84, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)), mat3x3<f32>(vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e121.x, _e121.y, _e121.z)), mat3x3<f32>(vec3<f32>(_e138.x, _e138.y, _e138.z), vec3<f32>(_e142.x, _e142.y, _e142.z), vec3<f32>(_e146.x, _e146.y, _e146.z)));
    fragColor = _e160;
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
