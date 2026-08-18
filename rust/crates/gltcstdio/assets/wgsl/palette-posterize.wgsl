struct Params {
    U: array<vec4<f32>, 6>,
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
var t_palette: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn colorDistance(a: vec3<f32>, b: vec3<f32>) -> f32 {
    var a_1: vec3<f32>;
    var b_1: vec3<f32>;

    a_1 = a;
    b_1 = b;
    let _e11 = a_1;
    let _e12 = b_1;
    return length((_e11 - _e12));
}

fn palettePosterizeFromImage(pos: vec2<f32>, outPos: vec2<f32>, paletteDim: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var paletteDim_1: vec2<f32>;
    var color: vec4<f32>;
    var bestIndex: i32 = 0i;
    var bestDistance: f32 = 1000000000f;
    var bestColor: vec4<f32>;
    var n: i32;
    var i: i32 = 0i;
    var pCol: vec4<f32>;
    var distance: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    paletteDim_1 = paletteDim;
    let _e13 = pos_1;
    let _e17 = global.U[0];
    let _e20 = pos_1;
    let _e29 = textureSample(t_source, samp, ((vec2<f32>((_e13.x / _e17.x), _e20.y) / vec2(2f)) + vec2(0.5f)));
    color = _e29;
    let _e35 = color;
    bestColor = _e35;
    let _e37 = paletteDim_1;
    n = i32(_e37.x);
    loop {
        let _e43 = i;
        let _e44 = n;
        if !((_e43 < _e44)) {
            break;
        }
        {
            let _e50 = i;
            let _e54 = textureLoad(t_palette, vec2<i32>(_e50, 0i), 0i);
            pCol = _e54;
            let _e56 = color;
            let _e58 = pCol;
            let _e60 = colorDistance(_e56.xyz, _e58.xyz);
            distance = _e60;
            let _e62 = distance;
            let _e63 = bestDistance;
            if (_e62 < _e63) {
                {
                    let _e65 = distance;
                    bestDistance = _e65;
                    let _e66 = i;
                    bestIndex = _e66;
                    let _e67 = pCol;
                    bestColor = _e67;
                }
            }
        }
        continuing {
            let _e47 = i;
            i = (_e47 + 1i);
        }
    }
    let _e68 = bestColor;
    return _e68;
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[4];
    let _e69 = palettePosterizeFromImage((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.xy);
    fragColor = _e69;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
