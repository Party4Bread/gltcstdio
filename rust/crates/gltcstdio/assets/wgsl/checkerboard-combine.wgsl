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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn getCoverFitTransform(aspectRatio: f32, imageDims: vec2<f32>) -> mat3x3<f32> {
    var aspectRatio_1: f32;
    var imageDims_1: vec2<f32>;
    var srcAr: f32;
    var h: f32;

    aspectRatio_1 = aspectRatio;
    imageDims_1 = imageDims;
    let _e11 = imageDims_1;
    let _e13 = imageDims_1;
    srcAr = (_e11.x / _e13.y);
    let _e18 = srcAr;
    let _e19 = aspectRatio_1;
    h = min(1f, (_e18 / _e19));
    let _e23 = h;
    let _e27 = h;
    return mat3x3<f32>(vec3<f32>(_e23, 0f, 0f), vec3<f32>(0f, _e27, 0f), vec3<f32>(0f, 0f, 1f));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn checkerboardCombine(pos: vec2<f32>, outPos: vec2<f32>, thickness: f32, borderColor: vec4<f32>, source1Dim: vec2<f32>, source2Dim: vec2<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var thickness_1: f32;
    var borderColor_1: vec4<f32>;
    var source1Dim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var choice: f32;
    var v: vec2<f32>;
    var d: f32;
    var fit1_: mat3x3<f32>;
    var fit2_: mat3x3<f32>;
    var local: vec4<f32>;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    thickness_1 = thickness;
    borderColor_1 = borderColor;
    source1Dim_1 = source1Dim;
    source2Dim_1 = source2Dim;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e23 = pos_1;
    u_2 = _e23;
    let _e25 = u_2;
    let _e28 = u_2;
    let _e31 = (floor(_e25.x) + floor(_e28.y));
    choice = (_e31 - (floor((_e31 / 2f)) * 2f));
    let _e38 = u_2;
    v = ((fract(_e38) - vec2(0.5f)) * 2f);
    let _e46 = v;
    let _e52 = v;
    d = min(abs((abs(_e46.x) - 1f)), abs((abs(_e52.y) - 1f)));
    let _e60 = d;
    let _e61 = thickness_1;
    if (_e60 < (_e61 * 0.1f)) {
        let _e65 = borderColor_1;
        let _e66 = _e65.xyz;
        return vec4<f32>(_e66.x, _e66.y, _e66.z, 1f);
    }
    let _e72 = v;
    let _e74 = thickness_1;
    v = (_e72 / vec2((1f - (_e74 * 0.1f))));
    let _e81 = source1Dim_1;
    let _e82 = getCoverFitTransform(1f, _e81);
    fit1_ = _e82;
    let _e85 = source2Dim_1;
    let _e86 = getCoverFitTransform(1f, _e85);
    fit2_ = _e86;
    let _e88 = choice;
    if (_e88 > 0f) {
        let _e91 = fit1_;
        let _e92 = viewTransform1_1;
        let _e95 = v;
        let _e96 = tf((_e91 * _naga_inverse_3x3_f32(_e92)), _e95);
        let _e100 = global.U[0];
        let _e103 = fit1_;
        let _e104 = viewTransform1_1;
        let _e107 = v;
        let _e108 = tf((_e103 * _naga_inverse_3x3_f32(_e104)), _e107);
        let _e117 = textureSample(t_source1_, samp, ((vec2<f32>((_e96.x / _e100.x), _e108.y) / vec2(2f)) + vec2(0.5f)));
        local = _e117;
    } else {
        let _e118 = fit2_;
        let _e119 = viewTransform2_1;
        let _e122 = v;
        let _e123 = tf((_e118 * _naga_inverse_3x3_f32(_e119)), _e122);
        let _e127 = global.U[0];
        let _e130 = fit2_;
        let _e131 = viewTransform2_1;
        let _e134 = v;
        let _e135 = tf((_e130 * _naga_inverse_3x3_f32(_e131)), _e134);
        let _e144 = textureSample(t_source2_, samp, ((vec2<f32>((_e123.x / _e127.x), _e135.y) / vec2(2f)) + vec2(0.5f)));
        local = _e144;
    }
    let _e146 = local;
    col = _e146;
    let _e148 = col;
    return _e148;
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
    let _e67 = global.U[7];
    let _e71 = global.U[8];
    let _e74 = global.U[4];
    let _e78 = global.U[5];
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e111 = global.U[13];
    let _e112 = _e111.xyz;
    let _e115 = global.U[14];
    let _e116 = _e115.xyz;
    let _e130 = checkerboardCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71, _e74.xy, _e78.xy, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)), mat3x3<f32>(vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z), vec3<f32>(_e116.x, _e116.y, _e116.z)));
    fragColor = _e130;
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
