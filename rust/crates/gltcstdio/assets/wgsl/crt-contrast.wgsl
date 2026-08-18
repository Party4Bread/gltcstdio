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

fn crtContrast(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, radius: f32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var radius_1: f32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var color: vec4<f32>;
    var pixel: f32;
    var pos2_: vec2<f32>;
    var n: i32;
    var total: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var p: vec2<f32>;
    var delta: vec2<f32>;
    var div: f32 = 0f;
    var i: i32 = 0i;
    var d: f32;
    var k: f32;
    var blur: vec4<f32>;
    var kIntensity: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    radius_1 = radius;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e20 = radius_1;
    radius_1 = (_e20 * 0.1f);
    let _e23 = pos_1;
    let _e27 = global.U[0];
    let _e30 = pos_1;
    let _e39 = _mirror_wrap(((vec2<f32>((_e23.x / _e27.x), _e30.y) / vec2(2f)) + vec2(0.5f)));
    let _e40 = textureSample(t_source, samp, _e39);
    color = _e40;
    let _e43 = sourceDim_1;
    pixel = (2f / _e43.y);
    let _e47 = modelTransform_1;
    let _e48 = pos_1;
    let _e49 = radius_1;
    let _e50 = angle_1;
    let _e52 = angle_1;
    let _e57 = tf(_e47, (_e48 + (_e49 * vec2<f32>(cos(_e50), sin(_e52)))));
    pos2_ = _e57;
    let _e60 = pos2_;
    let _e61 = pos_1;
    let _e64 = pixel;
    n = i32(min(50f, (length((_e60 - _e61)) / _e64)));
    let _e69 = n;
    if (_e69 <= 0i) {
        let _e72 = color;
        return _e72;
    }
    let _e79 = pos_1;
    p = _e79;
    let _e81 = pos2_;
    let _e82 = pos_1;
    let _e84 = n;
    delta = ((_e81 - _e82) / vec2(f32(_e84)));
    loop {
        let _e93 = i;
        let _e94 = n;
        if !((_e93 <= _e94)) {
            break;
        }
        {
            let _e100 = i;
            let _e102 = n;
            d = (f32(_e100) / f32(_e102));
            let _e106 = d;
            if (_e106 <= 1f) {
                {
                    k = 1f;
                    let _e111 = total;
                    let _e112 = k;
                    let _e113 = p;
                    let _e117 = global.U[0];
                    let _e120 = p;
                    let _e129 = _mirror_wrap(((vec2<f32>((_e113.x / _e117.x), _e120.y) / vec2(2f)) + vec2(0.5f)));
                    let _e130 = textureSample(t_source, samp, _e129);
                    total = (_e111 + (_e112 * _e130));
                    let _e133 = div;
                    let _e134 = k;
                    div = (_e133 + _e134);
                    let _e136 = p;
                    let _e137 = delta;
                    p = (_e136 + _e137);
                }
            }
        }
        continuing {
            let _e97 = i;
            i = (_e97 + 1i);
        }
    }
    let _e139 = total;
    let _e140 = div;
    blur = (_e139 / vec4(_e140));
    let _e144 = intensity_1;
    kIntensity = (_e144 * 2f);
    let _e149 = kIntensity;
    let _e151 = color;
    let _e153 = kIntensity;
    let _e154 = blur;
    return (((1f + _e149) * _e151) - (_e153 * _e154));
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
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = crtContrast((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
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
