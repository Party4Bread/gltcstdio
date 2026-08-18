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

fn hsl2rgb(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;
    var local: f32;
    var t: f32;
    var K: vec4<f32> = vec4<f32>(1f, 0.6666667f, 0.33333334f, 3f);
    var p: vec3<f32>;

    c_3 = c_2;
    let _e8 = c_3;
    let _e10 = c_3;
    if (_e10.z < 0.5f) {
        let _e14 = c_3;
        local = _e14.z;
    } else {
        let _e17 = c_3;
        local = (1f - _e17.z);
    }
    let _e21 = local;
    t = (_e8.y * _e21);
    let _e34 = c_3;
    let _e36 = K;
    let _e42 = K;
    p = abs(((fract((_e34.xxx + _e36.xyz)) * 6f) - _e42.www));
    let _e47 = c_3;
    let _e49 = t;
    let _e51 = K;
    let _e53 = p;
    let _e54 = K;
    let _e63 = t;
    let _e65 = c_3;
    return ((_e47.z + _e49) * mix(_e51.xxx, clamp((_e53 - _e54.xxx), vec3(0f), vec3(1f)), vec3(((2f * _e63) / _e65.z))));
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

fn coral(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var orig: vec2<f32>;
    var p_1: vec2<f32>;
    var delta: f32 = 0.001f;
    var d: vec2<f32>;
    var N: i32;
    var i: i32 = 0i;
    var hsl: vec3<f32>;
    var k: f32;
    var a: f32;
    var totalDisp: vec2<f32>;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = invModelTransform;
    let _e20 = uv_1;
    let _e21 = tf(_e19, _e20);
    orig = _e21;
    let _e23 = orig;
    p_1 = _e23;
    let _e27 = invModelTransform;
    let _e35 = delta;
    d = (mat2x2<f32>(_e27[0].xy, _e27[1].xy) * vec2<f32>(_e35, 0f));
    let _e40 = intensity_1;
    N = i32((abs(_e40) * 500f));
    loop {
        let _e48 = i;
        let _e49 = N;
        if !((_e48 < _e49)) {
            break;
        }
        {
            let _e55 = p_1;
            let _e59 = global.U[0];
            let _e62 = p_1;
            let _e71 = _mirror_wrap(((vec2<f32>((_e55.x / _e59.x), _e62.y) / vec2(2f)) + vec2(0.5f)));
            let _e72 = textureSample(t_source, samp, _e71);
            let _e74 = hsl2rgb(_e72.xyz);
            hsl = _e74;
            let _e79 = hsl;
            k = (1f - (2f * abs((0.5f - _e79.z))));
            let _e86 = angle_1;
            let _e87 = hsl;
            let _e91 = k;
            let _e92 = hsl;
            a = (_e86 + (((_e87.z * 2f) + ((_e91 * _e92.x) / 180f)) * 3.1415927f));
            let _e102 = p_1;
            let _e103 = intensity_1;
            let _e105 = delta;
            let _e107 = a;
            let _e109 = a;
            p_1 = (_e102 + ((sign(_e103) * _e105) * vec2<f32>(cos(_e107), sin(_e109))));
        }
        continuing {
            let _e52 = i;
            i = (_e52 + 1i);
        }
    }
    let _e114 = p_1;
    let _e115 = orig;
    totalDisp = (_e114 - _e115);
    let _e118 = uv_1;
    let _e119 = totalDisp;
    let _e124 = global.U[0];
    let _e127 = uv_1;
    let _e128 = totalDisp;
    let _e138 = _mirror_wrap(((vec2<f32>(((_e118 + _e119).x / _e124.x), (_e127 + _e128).y) / vec2(2f)) + vec2(0.5f)));
    let _e139 = textureSample(t_source, samp, _e138);
    outColor = _e139;
    let _e141 = outColor;
    return _e141;
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
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e97 = coral((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)));
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
