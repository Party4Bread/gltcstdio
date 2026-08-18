struct Params {
    U: array<vec4<f32>, 15>,
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

fn moire(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, intensity1_: f32, intensity2_: f32, intensity3_: f32, intensity4_: f32, intensity5_: f32, color1_: vec4<f32>, color2_: vec4<f32>, thickness: f32, viewTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var intensity1_1: f32;
    var intensity2_1: f32;
    var intensity3_1: f32;
    var intensity4_1: f32;
    var intensity5_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var thickness_1: f32;
    var viewTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var scale: f32;
    var t: f32;
    var k1_: f32;
    var k2_: f32;
    var k3_: f32;
    var k4_: f32;
    var k5_: f32;
    var d: f32;
    var f: f32;
    var local: vec4<f32>;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    intensity1_1 = intensity1_;
    intensity2_1 = intensity2_;
    intensity3_1 = intensity3_;
    intensity4_1 = intensity4_;
    intensity5_1 = intensity5_;
    color1_1 = color1_;
    color2_1 = color2_;
    thickness_1 = thickness;
    viewTransform_1 = viewTransform;
    let _e30 = uv_1;
    u = _e30;
    let _e37 = viewTransform_1[0][0];
    let _e42 = viewTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e37, _e42)));
    let _e48 = thickness_1;
    let _e52 = scale;
    t = (((1f - _e48) * 5000f) / _e52);
    let _e55 = u;
    let _e56 = t;
    let _e62 = t;
    u = (floor(((_e55 * _e56) + vec2(0.5f))) / vec2(_e62));
    let _e65 = intensity1_1;
    let _e66 = intensity1_1;
    k1_ = (_e65 * _e66);
    let _e69 = intensity2_1;
    let _e70 = intensity2_1;
    k2_ = (_e69 * _e70);
    let _e73 = intensity3_1;
    let _e74 = intensity3_1;
    k3_ = (_e73 * _e74);
    let _e77 = intensity4_1;
    let _e78 = intensity4_1;
    k4_ = (_e77 * _e78);
    let _e81 = intensity5_1;
    let _e82 = intensity5_1;
    k5_ = (_e81 * _e82);
    let _e85 = u;
    let _e87 = u;
    let _e90 = k1_;
    let _e92 = u;
    let _e94 = k2_;
    let _e97 = u;
    let _e99 = u;
    let _e102 = k3_;
    let _e105 = u;
    let _e107 = u;
    let _e110 = k4_;
    let _e113 = u;
    let _e115 = k5_;
    d = ((((((_e85.y * _e87.x) * _e90) + (length(_e92) * _e94)) + ((_e97.y * _e99.y) * _e102)) + ((_e105.x * _e107.x) * _e110)) + (_e113.y * _e115));
    let _e119 = d;
    f = (fract(_e119) * 2f);
    let _e124 = f;
    if (_e124 <= 1f) {
        let _e127 = color1_1;
        local = _e127;
    } else {
        let _e128 = color2_1;
        local = _e128;
    }
    let _e130 = local;
    outColor = _e130;
    let _e132 = source_specified_1;
    if (_e132 == 1i) {
        let _e135 = outPos_1;
        let _e139 = global.U[0];
        let _e142 = outPos_1;
        let _e151 = textureSample(t_source, samp, ((vec2<f32>((_e135.x / _e139.x), _e142.y) / vec2(2f)) + vec2(0.5f)));
        let _e152 = outColor;
        let _e153 = mergeColor(_e151, _e152);
        return _e153;
    } else {
        let _e154 = outColor;
        return _e154;
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
    let _e71 = global.U[7];
    let _e75 = global.U[8];
    let _e79 = global.U[9];
    let _e83 = global.U[10];
    let _e87 = global.U[11];
    let _e91 = global.U[12];
    let _e94 = global.U[13];
    let _e97 = global.U[14];
    let _e101 = global.U[1];
    let _e102 = _e101.xyz;
    let _e105 = global.U[2];
    let _e106 = _e105.xyz;
    let _e109 = global.U[3];
    let _e110 = _e109.xyz;
    let _e124 = moire((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87.x, _e91, _e94, _e97.x, mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)));
    fragColor = _e124;
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
