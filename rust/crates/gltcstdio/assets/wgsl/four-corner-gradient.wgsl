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

fn fourCornerGradient(u: vec2<f32>, outPos: vec2<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>) -> vec4<f32> {
    var u_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var k1_: f32;
    var k2_: f32;
    var k3_: f32;
    var k4_: f32;
    var inv1_: f32;
    var inv2_: f32;
    var inv3_: f32;
    var inv4_: f32;
    var tot: f32;
    var outColor: vec4<f32>;

    u_1 = u;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    let _e20 = u_1;
    k1_ = length((_e20 - vec2<f32>(-1f, -1f)));
    let _e29 = k1_;
    if (_e29 == 0f) {
        let _e32 = color1_1;
        return _e32;
    }
    let _e33 = u_1;
    k2_ = length((_e33 - vec2<f32>(-1f, 1f)));
    let _e41 = k2_;
    if (_e41 == 0f) {
        let _e44 = color2_1;
        return _e44;
    }
    let _e45 = u_1;
    k3_ = length((_e45 - vec2<f32>(1f, -1f)));
    let _e53 = k3_;
    if (_e53 == 0f) {
        let _e56 = color3_1;
        return _e56;
    }
    let _e57 = u_1;
    k4_ = length((_e57 - vec2<f32>(1f, 1f)));
    let _e64 = k4_;
    if (_e64 == 0f) {
        let _e67 = color4_1;
        return _e67;
    }
    let _e69 = k1_;
    inv1_ = (1f / _e69);
    let _e73 = k2_;
    inv2_ = (1f / _e73);
    let _e77 = k3_;
    inv3_ = (1f / _e77);
    let _e81 = k4_;
    inv4_ = (1f / _e81);
    let _e84 = inv1_;
    let _e85 = inv2_;
    let _e87 = inv3_;
    let _e89 = inv4_;
    tot = (((_e84 + _e85) + _e87) + _e89);
    let _e92 = inv1_;
    let _e93 = tot;
    inv1_ = (_e92 / _e93);
    let _e95 = inv2_;
    let _e96 = tot;
    inv2_ = (_e95 / _e96);
    let _e98 = inv3_;
    let _e99 = tot;
    inv3_ = (_e98 / _e99);
    let _e101 = inv4_;
    let _e102 = tot;
    inv4_ = (_e101 / _e102);
    let _e104 = color1_1;
    let _e105 = inv1_;
    let _e107 = color2_1;
    let _e108 = inv2_;
    let _e111 = color3_1;
    let _e112 = inv3_;
    let _e115 = color4_1;
    let _e116 = inv4_;
    outColor = ((((_e104 * _e105) + (_e107 * _e108)) + (_e111 * _e112)) + (_e115 * _e116));
    let _e120 = source_specified_1;
    if (_e120 == 1i) {
        let _e123 = outPos_1;
        let _e127 = global.U[0];
        let _e130 = outPos_1;
        let _e139 = textureSample(t_source, samp, ((vec2<f32>((_e123.x / _e127.x), _e130.y) / vec2(2f)) + vec2(0.5f)));
        let _e140 = outColor;
        let _e141 = mergeColor(_e139, _e140);
        return _e141;
    } else {
        let _e142 = outColor;
        return _e142;
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
    let _e80 = global.U[9];
    let _e81 = fourCornerGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77, _e80);
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
