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

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn withShapeAspectRatio(u: vec2<f32>, ar: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var ar_1: f32;

    u_1 = u;
    ar_1 = ar;
    let _e10 = u_1;
    let _e12 = ar_1;
    let _e14 = u_1;
    let _e20 = ar_1;
    return ((vec2<f32>((_e10.x * _e12), _e14.y) * 2f) / vec2((1f + _e20)));
}

fn circleGradient(uv: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, source_specified: i32, hardness: f32, shapeAspectRatio: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var source_specified_1: i32;
    var hardness_1: f32;
    var shapeAspectRatio_1: f32;
    var dist: f32;
    var local: f32;
    var k: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    color1_1 = color1_;
    color2_1 = color2_;
    source_specified_1 = source_specified;
    hardness_1 = hardness;
    shapeAspectRatio_1 = shapeAspectRatio;
    let _e20 = uv_1;
    let _e21 = shapeAspectRatio_1;
    let _e22 = withShapeAspectRatio(_e20, _e21);
    dist = length(_e22);
    let _e25 = hardness_1;
    if (_e25 == 1f) {
        let _e28 = dist;
        local = step(_e28, 1f);
    } else {
        let _e32 = hardness_1;
        let _e33 = dist;
        local = smoothstep(1f, _e32, _e33);
    }
    let _e36 = local;
    k = _e36;
    let _e38 = color1_1;
    let _e39 = color2_1;
    let _e40 = k;
    outColor = mix(_e38, _e39, vec4(_e40));
    let _e44 = source_specified_1;
    if (_e44 == 1i) {
        let _e47 = outPos_1;
        let _e51 = global.U[0];
        let _e54 = outPos_1;
        let _e63 = textureSample(t_source, samp, ((vec2<f32>((_e47.x / _e51.x), _e54.y) / vec2(2f)) + vec2(0.5f)));
        let _e64 = outColor;
        let _e65 = mergeColor(_e63, _e64);
        return _e65;
    } else {
        let _e66 = outColor;
        return _e66;
    }
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
    let _e69 = global.U[7];
    let _e72 = global.U[4];
    let _e77 = global.U[8];
    let _e81 = global.U[9];
    let _e83 = circleGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66, _e69, i32(_e72.x), _e77.x, _e81.x);
    fragColor = _e83;
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
