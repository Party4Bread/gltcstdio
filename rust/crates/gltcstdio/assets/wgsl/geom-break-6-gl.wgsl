struct Params {
    U: array<vec4<f32>, 14>,
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

fn geomBreak6GL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var gridStep: mat3x3<f32>;
    var ratio: f32;
    var i: i32 = 0i;
    var m: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e18 = pos_1;
    u = _e18;
    let _e20 = modelTransform_1;
    gridStep = _naga_inverse_3x3_f32(_e20);
    let _e23 = sourceDim_1;
    let _e25 = sourceDim_1;
    ratio = (_e23.x / _e25.y);
    loop {
        let _e31 = i;
        let _e32 = count_1;
        if !((_e31 < _e32)) {
            break;
        }
        {
            let _e38 = u;
            let _e40 = ratio;
            let _e43 = ((_e38.x / _e40) + 1f);
            let _e49 = u;
            let _e52 = (_e49.y + 1f);
            m = (vec2<f32>((_e43 - (floor((_e43 / 2f)) * 2f)), (_e52 - (floor((_e52 / 2f)) * 2f))) - vec2<f32>(1f, 1f));
            let _e64 = m;
            let _e67 = m;
            let _e71 = intensity_1;
            if (max(abs(_e64.x), abs(_e67.y)) > _e71) {
                break;
            }
            let _e73 = gridStep;
            let _e74 = u;
            u = (_e73 * vec3<f32>(_e74.x, _e74.y, 1f)).xy;
        }
        continuing {
            let _e35 = i;
            i = (_e35 + 1i);
        }
    }
    let _e81 = u;
    let _e85 = global.U[0];
    let _e88 = u;
    let _e97 = textureSample(t_source, samp, ((vec2<f32>((_e81.x / _e85.x), _e88.y) / vec2(2f)) + vec2(0.5f)));
    return _e97;
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
    let _e66 = global.U[9];
    let _e70 = global.U[10];
    let _e75 = global.U[4];
    let _e79 = global.U[11];
    let _e80 = _e79.xyz;
    let _e83 = global.U[12];
    let _e84 = _e83.xyz;
    let _e87 = global.U[13];
    let _e88 = _e87.xyz;
    let _e102 = geomBreak6GL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.xy, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
