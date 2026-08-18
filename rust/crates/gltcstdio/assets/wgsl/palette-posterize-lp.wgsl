struct Params {
    U: array<vec4<f32>, 5>,
    u_palette: array<vec4<f32>, 64>,
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

fn colorDistance(a: vec3<f32>, b: vec3<f32>) -> f32 {
    var a_1: vec3<f32>;
    var b_1: vec3<f32>;

    a_1 = a;
    b_1 = b;
    let _e12 = a_1;
    let _e13 = b_1;
    return length((_e12 - _e13));
}

fn palettePosterize(pos: vec2<f32>, outPos: vec2<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color: vec4<f32>;
    var bestIndex: i32 = 0i;
    var bestDistance: f32 = 1000000000f;
    var i: i32 = 0i;
    var distance: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    let _e12 = pos_1;
    let _e16 = global.U[0];
    let _e19 = pos_1;
    let _e28 = textureSample(t_source, samp, ((vec2<f32>((_e12.x / _e16.x), _e19.y) / vec2(2f)) + vec2(0.5f)));
    color = _e28;
    loop {
        let _e36 = i;
        if !((_e36 < 64i)) {
            break;
        }
        {
            let _e43 = color;
            let _e45 = i;
            let _e47 = global.u_palette[_e45];
            let _e49 = colorDistance(_e43.xyz, _e47.xyz);
            distance = _e49;
            let _e51 = distance;
            let _e52 = bestDistance;
            if (_e51 < _e52) {
                {
                    let _e54 = distance;
                    bestDistance = _e54;
                    let _e55 = i;
                    bestIndex = _e55;
                }
            }
        }
        continuing {
            let _e40 = i;
            i = (_e40 + 1i);
        }
    }
    let _e56 = bestIndex;
    let _e58 = global.u_palette[_e56];
    return _e58;
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e66 = palettePosterize((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)));
    fragColor = _e66;
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
