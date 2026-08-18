struct Params {
    U: array<vec4<f32>, 9>,
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

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn ringThreshold(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, scale: f32, ringRatio: f32, threshold: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var scale_1: f32;
    var ringRatio_1: f32;
    var threshold_1: f32;
    var ratio: f32;
    var sp: vec2<f32>;
    var col: vec4<f32>;
    var q: f32;
    var ring: f32;
    var t: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    scale_1 = scale;
    ringRatio_1 = ringRatio;
    threshold_1 = threshold;
    let _e18 = sourceDim_1;
    let _e20 = sourceDim_1;
    ratio = (_e18.x / _e20.y);
    let _e24 = uv_1;
    let _e25 = scale_1;
    sp = (_e24 / vec2(_e25));
    let _e29 = sp;
    let _e32 = ratio;
    let _e34 = sp;
    if ((abs(_e29.x) > _e32) || (abs(_e34.y) > 1f)) {
        return vec4<f32>(0f, 0f, 0f, 1f);
    }
    let _e45 = sp;
    let _e49 = global.U[0];
    let _e52 = sp;
    let _e62 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e45.x / _e49.x), _e52.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e62;
    let _e64 = sp;
    let _e67 = ratio;
    let _e69 = sp;
    q = max((abs(_e64.x) / _e67), abs(_e69.y));
    let _e74 = q;
    if (_e74 > 0f) {
        {
            let _e77 = q;
            let _e79 = ringRatio_1;
            ring = max(ceil((log(_e77) / log(_e79))), 1f);
            let _e86 = threshold_1;
            let _e88 = ring;
            t = (_e86 * pow(0.5f, (_e88 - 1f)));
            let _e94 = col;
            let _e96 = luma(_e94.xyz);
            let _e97 = t;
            if (_e96 < _e97) {
                let _e102 = col;
                return vec4<f32>(0f, 0f, 0f, _e102.w);
            }
        }
    }
    let _e105 = col;
    return _e105;
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
    let _e80 = ringThreshold((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x);
    fragColor = _e80;
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
