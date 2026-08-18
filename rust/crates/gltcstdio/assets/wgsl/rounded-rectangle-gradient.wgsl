struct Params {
    U: array<vec4<f32>, 11>,
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

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local = max(_e25.x, _e27.y);
    }
    let _e31 = local;
    return _e31;
}

fn circleGradient(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, shapeAspectRatio: f32, hardness: f32, roundness: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var shapeAspectRatio_1: f32;
    var hardness_1: f32;
    var roundness_1: f32;
    var rectSize: vec2<f32>;
    var radius: f32;
    var d: f32;
    var local_1: f32;
    var k: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    shapeAspectRatio_1 = shapeAspectRatio;
    hardness_1 = hardness;
    roundness_1 = roundness;
    let _e23 = shapeAspectRatio_1;
    rectSize = vec2<f32>(1f, _e23);
    let _e26 = rectSize;
    let _e27 = rectSize;
    rectSize = (_e26 / vec2(length(_e27)));
    let _e31 = rectSize;
    let _e33 = rectSize;
    let _e36 = roundness_1;
    radius = (min(_e31.x, _e33.y) * _e36);
    let _e39 = rectSize;
    let _e40 = radius;
    rectSize = (_e39 - vec2(_e40));
    let _e43 = uv_1;
    let _e46 = rectSize;
    let _e47 = sdRectangle((_e43 * 2f), _e46);
    let _e48 = radius;
    d = (_e47 - _e48);
    let _e51 = hardness_1;
    if (_e51 == 1f) {
        let _e54 = d;
        local_1 = step((_e54 * 0.25f), 0f);
    } else {
        let _e60 = hardness_1;
        let _e63 = d;
        local_1 = smoothstep((1f - _e60), 0f, (_e63 * 0.25f));
    }
    let _e68 = local_1;
    k = _e68;
    let _e70 = color1_1;
    let _e71 = color2_1;
    let _e72 = k;
    outColor = mix(_e70, _e71, vec4(_e72));
    let _e76 = source_specified_1;
    if (_e76 == 1i) {
        let _e79 = outPos_1;
        let _e83 = global.U[0];
        let _e86 = outPos_1;
        let _e95 = textureSample(t_source, samp, ((vec2<f32>((_e79.x / _e83.x), _e86.y) / vec2(2f)) + vec2(0.5f)));
        let _e96 = outColor;
        let _e97 = mergeColor(_e95, _e96);
        return _e97;
    } else {
        let _e98 = outColor;
        return _e98;
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
    let _e66 = global.U[4];
    let _e71 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e81 = global.U[9];
    let _e85 = global.U[10];
    let _e87 = circleGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77.x, _e81.x, _e85.x);
    fragColor = _e87;
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
