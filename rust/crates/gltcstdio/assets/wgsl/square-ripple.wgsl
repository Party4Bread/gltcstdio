struct Params {
    U: array<vec4<f32>, 12>,
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

fn squareRippleIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, count: i32, thickness: f32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var count_1: i32;
    var thickness_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var u: vec2<f32>;
    var id: vec2<f32>;
    var uv2_: vec2<f32>;
    var id2_: vec2<f32>;
    var crossLen: f32;
    var k: i32;
    var invert: bool;
    var k_1: i32;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    count_1 = count;
    thickness_1 = thickness;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    let _e23 = uv_1;
    u = abs((fract((_e23 - vec2(0.5f))) - vec2(0.5f)));
    let _e33 = uv_1;
    id = floor((_e33 - vec2(0.5f)));
    let _e39 = uv_1;
    uv2_ = _e39;
    let _e41 = uv2_;
    id2_ = floor(_e41);
    let _e46 = thickness_1;
    crossLen = mix(0.15f, 0.5f, _e46);
    let _e49 = thickness_1;
    thickness_1 = (_e49 * 0.2f);
    let _e52 = u;
    let _e54 = crossLen;
    let _e56 = u;
    let _e58 = thickness_1;
    let _e61 = u;
    let _e63 = crossLen;
    let _e65 = u;
    let _e67 = thickness_1;
    if (((_e52.x < _e54) && (_e56.y < _e58)) || ((_e61.y < _e63) && (_e65.x < _e67))) {
        {
            let _e71 = id;
            let _e73 = id;
            k = i32((_e71.x + _e73.y));
            let _e78 = k;
            let _e79 = count_1;
            invert = (((_e78 / _e79) % 2i) == 0i);
            let _e86 = k;
            let _e91 = invert;
            if (((_e86 % 3i) == 0i) != _e91) {
                let _e93 = color3_1;
                return _e93;
            } else {
                let _e94 = color4_1;
                return _e94;
            }
        }
    } else {
        {
            let _e95 = id2_;
            let _e97 = id2_;
            k_1 = i32((_e95.x + _e97.y));
            let _e102 = k_1;
            if ((_e102 % 2i) == 0i) {
                let _e107 = color1_1;
                return _e107;
            } else {
                let _e108 = color2_1;
                return _e108;
            }
        }
    }
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[4];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e88 = global.U[11];
    let _e89 = squareRippleIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), i32(_e70.x), _e75.x, _e79, _e82, _e85, _e88);
    fragColor = _e89;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
