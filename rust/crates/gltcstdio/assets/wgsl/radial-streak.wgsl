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

fn radialStreak(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u: vec2<f32>;
    var d: f32;
    var ang: f32;
    var sector: f32;
    var streakAngle: f32;
    var mang: f32;
    var n: f32;
    var sang: f32;
    var local: f32;
    var angleCompression: f32;
    var uv2_: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = inverseModelTransform;
    let _e20 = uv_1;
    u = (_e19 * vec3<f32>(_e20.x, _e20.y, 1f)).xy;
    let _e28 = u;
    d = length(_e28);
    let _e31 = d;
    if (_e31 == 0f) {
        let _e34 = uv_1;
        let _e38 = global.U[0];
        let _e41 = uv_1;
        let _e50 = textureSample(t_source, samp, ((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
        return _e50;
    }
    let _e51 = u;
    let _e53 = d;
    ang = acos((_e51.x / _e53));
    let _e57 = u;
    if (_e57.y < 0f) {
        let _e62 = ang;
        ang = (6.2831855f - _e62);
    }
    let _e64 = ang;
    ang = (_e64 - 1.5707964f);
    let _e70 = count_1;
    sector = (6.2831855f / f32(_e70));
    let _e74 = intensity_1;
    let _e75 = sector;
    streakAngle = (_e74 * _e75);
    let _e78 = ang;
    let _e79 = sector;
    mang = (_e78 - (floor((_e78 / _e79)) * _e79));
    let _e85 = ang;
    let _e86 = sector;
    n = floor((_e85 / _e86));
    let _e91 = mang;
    let _e92 = sector;
    let _e97 = sector;
    let _e98 = streakAngle;
    if (abs((_e91 - (_e92 / 2f))) > ((_e97 - _e98) / 2f)) {
        {
            let _e104 = mang;
            let _e105 = sector;
            if (_e104 <= (_e105 / 2f)) {
                let _e109 = n;
                local = _e109;
            } else {
                let _e110 = n;
                local = (_e110 + 1f);
            }
            let _e114 = local;
            let _e115 = sector;
            sang = (1.5707964f + (_e114 * _e115));
        }
    } else {
        {
            let _e119 = intensity_1;
            angleCompression = (1f - _e119);
            let _e123 = n;
            let _e124 = sector;
            let _e127 = sector;
            let _e131 = mang;
            let _e132 = sector;
            let _e136 = angleCompression;
            sang = (((1.5707964f + (_e123 * _e124)) + (_e127 / 2f)) + ((_e131 - (_e132 / 2f)) / _e136));
        }
    }
    let _e139 = modelTransform_1;
    let _e140 = d;
    let _e141 = sang;
    let _e144 = d;
    let _e145 = sang;
    uv2_ = (_e139 * vec3<f32>((_e140 * cos(_e141)), (_e144 * sin(_e145)), 1f)).xy;
    let _e153 = uv2_;
    let _e157 = global.U[0];
    let _e160 = uv2_;
    let _e169 = textureSample(t_source, samp, ((vec2<f32>((_e153.x / _e157.x), _e160.y) / vec2(2f)) + vec2(0.5f)));
    return _e169;
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
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e98 = radialStreak((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)));
    fragColor = _e98;
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
