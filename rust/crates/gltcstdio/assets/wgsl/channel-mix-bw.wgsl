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

fn channelMixBW(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, red: f32, green: f32, blue: f32, normalize: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var red_1: f32;
    var green_1: f32;
    var blue_1: f32;
    var normalize_1: i32;
    var col: vec4<f32>;
    var grey: f32;
    var sum: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    red_1 = red;
    green_1 = green;
    blue_1 = blue;
    normalize_1 = normalize;
    let _e20 = pos_1;
    let _e24 = global.U[0];
    let _e27 = pos_1;
    let _e36 = textureSample(t_source, samp, ((vec2<f32>((_e20.x / _e24.x), _e27.y) / vec2(2f)) + vec2(0.5f)));
    col = _e36;
    let _e38 = red_1;
    let _e39 = col;
    let _e42 = green_1;
    let _e43 = col;
    let _e47 = blue_1;
    let _e48 = col;
    grey = (((_e38 * _e39.x) + (_e42 * _e43.y)) + (_e47 * _e48.z));
    let _e53 = normalize_1;
    if (_e53 == 0i) {
        {
            let _e56 = red_1;
            let _e57 = green_1;
            let _e59 = blue_1;
            sum = ((_e56 + _e57) + _e59);
            let _e62 = sum;
            if (_e62 == 0f) {
                grey = 0f;
            } else {
                let _e66 = grey;
                let _e67 = sum;
                grey = (_e66 / _e67);
            }
        }
    } else {
        let _e69 = normalize_1;
        if (_e69 == 2i) {
            {
                let _e72 = grey;
                grey = (_e72 / 3f);
            }
        }
    }
    let _e75 = col;
    let _e76 = grey;
    let _e77 = grey;
    let _e78 = grey;
    let _e79 = col;
    let _e82 = intensity_1;
    return mix(_e75, vec4<f32>(_e76, _e77, _e78, _e79.w), vec4(_e82));
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
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = channelMixBW((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, i32(_e82.x));
    fragColor = _e85;
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
