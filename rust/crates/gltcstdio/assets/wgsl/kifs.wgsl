struct Params {
    U: array<vec4<f32>, 17>,
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

fn getDir(angle: f32) -> vec2<f32> {
    var angle_1: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    let _e10 = angle_1;
    return vec2<f32>(sin(_e8), cos(_e10));
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

fn kifs(pos: vec2<f32>, outPos: vec2<f32>, iterations: i32, modelTransform: mat3x3<f32>, texTransform: mat3x3<f32>, thickness: f32, color: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var ang: f32 = 2.6179938f;
    var n: vec2<f32>;
    var d: f32;
    var ang1_: f32;
    var n1_: vec2<f32>;
    var ang2_: f32;
    var n2_: vec2<f32>;
    var scale: f32 = 1f;
    var i: i32 = 0i;
    var local: f32;
    var k: f32;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    iterations_1 = iterations;
    modelTransform_1 = modelTransform;
    texTransform_1 = texTransform;
    thickness_1 = thickness;
    color_1 = color;
    let _e20 = pos_1;
    pos_1 = (_e20 * 1.25f);
    let _e24 = pos_1;
    pos_1.x = abs(_e24.x);
    let _e34 = pos_1;
    let _e36 = ang;
    pos_1.y = (_e34.y + (tan(_e36) * 0.5f));
    let _e41 = ang;
    let _e42 = getDir(_e41);
    n = _e42;
    let _e44 = pos_1;
    let _e49 = n;
    d = dot((_e44 - vec2<f32>(0.5f, 0f)), _e49);
    let _e52 = pos_1;
    let _e53 = n;
    let _e55 = d;
    pos_1 = (_e52 - ((_e53 * max(0f, _e55)) * 2f));
    let _e70 = modelTransform_1[2][0];
    ang1_ = (2.0943952f + _e70);
    let _e73 = ang1_;
    let _e74 = getDir(_e73);
    n1_ = _e74;
    let _e85 = modelTransform_1[2][1];
    ang2_ = (2.0943952f + _e85);
    let _e88 = ang2_;
    let _e89 = getDir(_e88);
    n2_ = _e89;
    let _e94 = pos_1;
    pos_1.x = (_e94.x + 0.5f);
    loop {
        let _e100 = i;
        let _e101 = iterations_1;
        if !((_e100 < _e101)) {
            break;
        }
        {
            let _e107 = pos_1;
            let _e113 = modelTransform_1[0][0];
            pos_1 = (_e107 * (3f * _e113));
            let _e116 = scale;
            let _e122 = modelTransform_1[0][0];
            scale = (_e116 * (3f * _e122));
            let _e126 = pos_1;
            pos_1.x = (_e126.x - 1.5f);
            let _e131 = pos_1;
            pos_1.x = abs(_e131.x);
            let _e135 = pos_1;
            pos_1.x = (_e135.x - 0.5f);
            let _e139 = i;
            let _e144 = i;
            if (((_e139 / 2i) * 2i) == _e144) {
                let _e146 = pos_1;
                let _e147 = n1_;
                let _e149 = pos_1;
                let _e150 = n1_;
                pos_1 = (_e146 - ((_e147 * min(0f, dot(_e149, _e150))) * 2f));
            } else {
                let _e157 = pos_1;
                let _e158 = n2_;
                let _e160 = pos_1;
                let _e161 = n2_;
                pos_1 = (_e157 - ((_e158 * min(0f, dot(_e160, _e161))) * 2f));
            }
        }
        continuing {
            let _e104 = i;
            i = (_e104 + 1i);
        }
    }
    let _e168 = pos_1;
    let _e169 = pos_1;
    d = length((_e168 - vec2<f32>(clamp(_e169.x, -1f, 1f), 0f)));
    let _e179 = pos_1;
    let _e180 = scale;
    pos_1 = (_e179 / vec2(_e180));
    let _e183 = d;
    let _e184 = scale;
    let _e186 = thickness_1;
    if ((_e183 / _e184) < (_e186 * 0.1f)) {
        local = 1f;
    } else {
        local = 0f;
    }
    let _e193 = local;
    k = _e193;
    let _e195 = texTransform_1;
    let _e197 = pos_1;
    let _e198 = tf(_naga_inverse_3x3_f32(_e195), _e197);
    let _e202 = global.U[0];
    let _e205 = texTransform_1;
    let _e207 = pos_1;
    let _e208 = tf(_naga_inverse_3x3_f32(_e205), _e207);
    let _e217 = _mirror_wrap(((vec2<f32>((_e198.x / _e202.x), _e208.y) / vec2(2f)) + vec2(0.5f)));
    let _e218 = textureSample(t_source, samp, _e217);
    col = _e218;
    let _e220 = k;
    if (_e220 > 0f) {
        {
            let _e223 = col;
            let _e225 = color_1;
            let _e227 = color_1;
            let _e230 = mix(_e223.xyz, _e225.xyz, vec3(_e227.w));
            let _e231 = col;
            return vec4<f32>(_e230.x, _e230.y, _e230.z, _e231.w);
        }
    } else {
        {
            let _e237 = col;
            return _e237;
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
    let _e66 = global.U[8];
    let _e71 = global.U[9];
    let _e72 = _e71.xyz;
    let _e75 = global.U[10];
    let _e76 = _e75.xyz;
    let _e79 = global.U[11];
    let _e80 = _e79.xyz;
    let _e96 = global.U[12];
    let _e97 = _e96.xyz;
    let _e100 = global.U[13];
    let _e101 = _e100.xyz;
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e121 = global.U[15];
    let _e125 = global.U[16];
    let _e126 = kifs((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), _e121.x, _e125);
    fragColor = _e126;
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
