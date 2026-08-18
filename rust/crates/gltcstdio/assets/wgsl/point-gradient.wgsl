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

fn pointGradient(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, mode: i32, modelTransform: mat3x3<f32>, colorIn: vec4<f32>, colorOut: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var mode_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var u: vec2<f32>;
    var k: f32 = 0f;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    mode_1 = mode;
    modelTransform_1 = modelTransform;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    let _e20 = pos_1;
    u = _e20;
    let _e24 = mode_1;
    let _e27 = mode_1;
    if ((_e24 == 0i) || (_e27 >= 3i)) {
        let _e31 = u;
        k = min(length(_e31), 1f);
    }
    let _e35 = mode_1;
    let _e38 = mode_1;
    if ((_e35 == 1i) || (_e38 == 3i)) {
        let _e43 = k;
        let _e45 = u;
        let _e47 = u;
        k = (((1f - _e43) * (atan2(_e45.x, _e47.y) + 3.1415927f)) / 6.2831855f);
    }
    let _e55 = mode_1;
    let _e58 = mode_1;
    if ((_e55 == 2i) || (_e58 == 4i)) {
        let _e63 = k;
        let _e65 = u;
        let _e68 = u;
        k = (((1f - _e63) * atan2(abs(_e65.x), _e68.y)) / 3.1415927f);
    }
    let _e74 = colorIn_1;
    let _e75 = colorOut_1;
    let _e76 = k;
    outColor = mix(_e74, _e75, vec4(_e76));
    let _e80 = source_specified_1;
    if (_e80 == 1i) {
        let _e83 = outPos_1;
        let _e87 = global.U[0];
        let _e90 = outPos_1;
        let _e99 = textureSample(t_source, samp, ((vec2<f32>((_e83.x / _e87.x), _e90.y) / vec2(2f)) + vec2(0.5f)));
        let _e100 = outColor;
        let _e101 = mergeColor(_e99, _e100);
        return _e101;
    } else {
        let _e102 = outColor;
        return _e102;
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
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e101 = global.U[10];
    let _e104 = global.U[11];
    let _e105 = pointGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), _e101, _e104);
    fragColor = _e105;
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
