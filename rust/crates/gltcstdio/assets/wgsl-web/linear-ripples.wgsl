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

fn linearRipples(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, perspective: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var perspective_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var u: vec2<f32>;
    var d: f32;
    var radius: f32 = 0.5f;
    var p: f32;
    var local: f32;
    var local_1: f32;
    var pd: f32;
    var dilation: f32;
    var coord: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    perspective_1 = perspective;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = invModelTransform;
    let _e20 = pos_1;
    u = (_e19 * vec3<f32>(_e20.x, _e20.y, 1f)).xy;
    let _e28 = u;
    d = _e28.y;
    let _e31 = d;
    if (_e31 < 0f) {
        {
            let _e34 = pos_1;
            let _e38 = global.U[0];
            let _e41 = pos_1;
            let _e50 = _mirror_wrap(((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
            let _e52 = textureSampleLevel(t_source, samp, _e50, 0f);
            return _e52;
        }
    }
    let _e55 = perspective_1;
    let _e56 = radius;
    p = (_e55 * _e56);
    let _e59 = perspective_1;
    if (_e59 == 0f) {
        local_1 = 0f;
    } else {
        let _e63 = perspective_1;
        if (_e63 >= 10000f) {
            let _e66 = d;
            local = _e66;
        } else {
            let _e67 = p;
            let _e68 = d;
            let _e70 = p;
            let _e71 = d;
            local = ((_e67 * _e68) / (_e70 + _e71));
        }
        let _e75 = local;
        local_1 = _e75;
    }
    let _e77 = local_1;
    pd = _e77;
    let _e79 = intensity_1;
    let _e80 = radius;
    let _e84 = pd;
    let _e89 = radius;
    dilation = (((_e79 * _e80) * 0.5f) * sin((((_e84 * 3.1415927f) * 100f) / _e89)));
    let _e94 = modelTransform_1;
    let _e95 = u;
    let _e97 = u;
    let _e99 = dilation;
    coord = (_e94 * vec3<f32>(_e95.x, (_e97.y + _e99), 1f)).xy;
    let _e106 = coord;
    let _e110 = global.U[0];
    let _e113 = coord;
    let _e122 = _mirror_wrap(((vec2<f32>((_e106.x / _e110.x), _e113.y) / vec2(2f)) + vec2(0.5f)));
    let _e124 = textureSampleLevel(t_source, samp, _e122, 0f);
    return _e124;
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
    let _e97 = linearRipples((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)));
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
