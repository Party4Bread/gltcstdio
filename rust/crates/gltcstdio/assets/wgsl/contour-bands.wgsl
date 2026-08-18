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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn sampleCol(color: vec4<f32>, count: f32) -> f32 {
    var color_1: vec4<f32>;
    var count_1: f32;

    color_1 = color;
    count_1 = count;
    let _e11 = color_1;
    let _e13 = color_1;
    let _e16 = color_1;
    let _e19 = count_1;
    return floor((((((_e11.x + _e13.y) + _e16.z) * (_e19 - 1f)) / 3f) + 0.5f));
}

fn contour(uv: vec2<f32>, outPos: vec2<f32>, count_2: i32, color1_: vec4<f32>, color2_: vec4<f32>, source2_specified: i32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_3: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var source2_specified_1: i32;
    var local: vec4<f32>;
    var s: f32;
    var k: f32;
    var color_2: vec4<f32>;
    var bkgColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    count_3 = count_2;
    color1_1 = color1_;
    color2_1 = color2_;
    source2_specified_1 = source2_specified;
    let _e19 = source2_specified_1;
    if (_e19 == 1i) {
        let _e22 = uv_1;
        let _e26 = global.U[0];
        let _e29 = uv_1;
        let _e38 = textureSample(t_source2_, samp, ((vec2<f32>((_e22.x / _e26.x), _e29.y) / vec2(2f)) + vec2(0.5f)));
        local = _e38;
    } else {
        let _e39 = uv_1;
        let _e43 = global.U[0];
        let _e46 = uv_1;
        let _e55 = textureSample(t_source, samp, ((vec2<f32>((_e39.x / _e43.x), _e46.y) / vec2(2f)) + vec2(0.5f)));
        local = _e55;
    }
    let _e57 = local;
    let _e58 = count_3;
    let _e60 = sampleCol(_e57, f32(_e58));
    s = _e60;
    let _e62 = s;
    k = (_e62 - (floor((_e62 / 2f)) * 2f));
    let _e70 = color1_1;
    let _e71 = color2_1;
    let _e72 = k;
    color_2 = mix(_e70, _e71, vec4(_e72));
    let _e75 = uv_1;
    let _e79 = global.U[0];
    let _e82 = uv_1;
    let _e91 = textureSample(t_source, samp, ((vec2<f32>((_e75.x / _e79.x), _e82.y) / vec2(2f)) + vec2(0.5f)));
    bkgColor = _e91;
    let _e93 = bkgColor;
    let _e94 = color_2;
    let _e95 = mergeColor(_e93, _e94);
    return _e95;
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
    let _e67 = global.U[6];
    let _e72 = global.U[7];
    let _e75 = global.U[8];
    let _e78 = global.U[4];
    let _e81 = contour((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72, _e75, i32(_e78.x));
    fragColor = _e81;
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
