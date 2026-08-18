struct Params {
    U: array<vec4<f32>, 8>,
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

fn hash32_(u: vec3<f32>) -> vec2<f32> {
    var u_1: vec3<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e17 = u_1;
    let _e26 = u_1;
    let _e30 = u_1;
    let _e35 = u_1;
    return vec2<f32>(fract((sin((((_e8.x * 776.45f) + (_e12.y * 453.24f)) + (_e17.z * 553.25f))) * 45.77f)), fract((sin((((_e26.x * 376.45f) + (_e30.y * 853.24f)) + (_e35.z * 153.84f))) * 88.77f)));
}

fn stochasticSuperSampling(uv: vec2<f32>, outPos: vec2<f32>, radius: f32, count: i32, sourceDim: vec2<f32>, outDim: vec2<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalW: f32 = 0f;
    var pixelSize: f32;
    var d: f32;
    var outPixelCoord: vec2<f32>;
    var i: i32 = 0i;
    var delta: vec2<f32>;
    var col: vec4<f32>;
    var avgColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    radius_1 = radius;
    count_1 = count;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    let _e27 = outDim_1;
    pixelSize = (2f / _e27.y);
    let _e31 = pixelSize;
    let _e32 = radius_1;
    d = (_e31 * _e32);
    let _e35 = uv_1;
    let _e36 = outDim_1;
    let _e38 = outDim_1;
    let _e44 = pixelSize;
    outPixelCoord = ((_e35 + vec2<f32>((_e36.x / _e38.y), 1f)) / vec2(_e44));
    loop {
        let _e50 = i;
        let _e51 = count_1;
        if !((_e50 < _e51)) {
            break;
        }
        {
            let _e57 = uv_1;
            let _e59 = (_e57 * 100f);
            let _e60 = i;
            let _e65 = hash32_(vec3<f32>(_e59.x, _e59.y, f32(_e60)));
            let _e69 = d;
            delta = ((_e65 - vec2(0.5f)) * _e69);
            let _e72 = uv_1;
            let _e73 = delta;
            let _e78 = global.U[0];
            let _e81 = uv_1;
            let _e82 = delta;
            let _e92 = textureSample(t_source, samp, ((vec2<f32>(((_e72 + _e73).x / _e78.x), (_e81 + _e82).y) / vec2(2f)) + vec2(0.5f)));
            col = _e92;
            let _e94 = totalColor;
            let _e95 = col;
            let _e96 = col;
            totalColor = (_e94 + (_e95 * _e96));
            let _e99 = totalW;
            totalW = (_e99 + 1f);
        }
        continuing {
            let _e54 = i;
            i = (_e54 + 1i);
        }
    }
    let _e102 = totalColor;
    let _e103 = totalW;
    avgColor = sqrt((_e102 / vec4(_e103)));
    let _e108 = avgColor;
    return _e108;
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
    let _e66 = global.U[6];
    let _e70 = global.U[7];
    let _e75 = global.U[4];
    let _e79 = global.U[5];
    let _e81 = stochasticSuperSampling((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.xy, _e79.xy);
    fragColor = _e81;
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
