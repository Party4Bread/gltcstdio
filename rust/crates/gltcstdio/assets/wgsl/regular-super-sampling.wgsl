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
    var N: f32;
    var cellSize: f32;
    var start: vec2<f32>;
    var j: i32 = 0i;
    var i: i32;
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
    let _e31 = count_1;
    N = f32(_e31);
    let _e34 = pixelSize;
    let _e35 = N;
    let _e37 = radius_1;
    cellSize = ((_e34 / _e35) * _e37);
    let _e40 = cellSize;
    let _e41 = N;
    start = vec2((-((_e40 * (_e41 - 1f))) * 0.5f));
    loop {
        let _e52 = j;
        let _e53 = count_1;
        if !((_e52 < _e53)) {
            break;
        }
        {
            i = 0i;
            loop {
                let _e61 = i;
                let _e62 = count_1;
                if !((_e61 < _e62)) {
                    break;
                }
                {
                    let _e68 = start;
                    let _e69 = cellSize;
                    let _e70 = i;
                    let _e72 = j;
                    delta = (_e68 + (_e69 * vec2<f32>(f32(_e70), f32(_e72))));
                    let _e78 = uv_1;
                    let _e79 = delta;
                    let _e84 = global.U[0];
                    let _e87 = uv_1;
                    let _e88 = delta;
                    let _e98 = textureSample(t_source, samp, ((vec2<f32>(((_e78 + _e79).x / _e84.x), (_e87 + _e88).y) / vec2(2f)) + vec2(0.5f)));
                    col = _e98;
                    let _e100 = totalColor;
                    let _e101 = col;
                    let _e102 = col;
                    totalColor = (_e100 + (_e101 * _e102));
                    let _e105 = totalW;
                    totalW = (_e105 + 1f);
                }
                continuing {
                    let _e65 = i;
                    i = (_e65 + 1i);
                }
            }
        }
        continuing {
            let _e56 = j;
            j = (_e56 + 1i);
        }
    }
    let _e108 = totalColor;
    let _e109 = totalW;
    avgColor = sqrt((_e108 / vec4(_e109)));
    let _e114 = avgColor;
    return _e114;
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
