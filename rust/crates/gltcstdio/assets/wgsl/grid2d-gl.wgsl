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

fn grid2dDistance1d(x: f32, count: f32) -> f32 {
    var x_1: f32;
    var count_1: f32;
    var normalized: f32;

    x_1 = x;
    count_1 = count;
    let _e10 = x_1;
    if (abs(_e10) > 0.5f) {
        let _e14 = x_1;
        return (abs(_e14) - 0.5f);
    }
    let _e18 = x_1;
    let _e21 = count_1;
    normalized = (((_e18 + 0.5f) * _e21) + 0.5f);
    let _e26 = normalized;
    let _e31 = count_1;
    return (abs((fract(_e26) - 0.5f)) / _e31);
}

fn grid2dResponse(d: f32, thickness: f32, blur: f32) -> f32 {
    var d_1: f32;
    var thickness_1: f32;
    var blur_1: f32;

    d_1 = d;
    thickness_1 = thickness;
    blur_1 = blur;
    let _e12 = thickness_1;
    let _e13 = thickness_1;
    let _e14 = blur_1;
    let _e16 = d_1;
    return pow(smoothstep(_e12, (_e13 + _e14), _e16), 0.3f);
}

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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn grid2dGl(pos: vec2<f32>, outPos: vec2<f32>, count_2: i32, thickness_2: f32, glow: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_3: i32;
    var thickness_3: f32;
    var glow_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var th: f32;
    var blur_2: f32;
    var fCount: f32;
    var d_2: f32;
    var k: f32;
    var bkgCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    count_3 = count_2;
    thickness_3 = thickness_2;
    glow_1 = glow;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = pos_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    u_2 = _e23;
    let _e25 = thickness_3;
    let _e26 = thickness_3;
    th = ((_e25 * _e26) * 0.25f);
    let _e31 = glow_1;
    blur_2 = (_e31 * 0.2f);
    let _e35 = count_3;
    fCount = f32(_e35);
    let _e39 = u_2;
    let _e44 = u_2;
    if ((abs(_e39.x) > 0.5f) || (abs(_e44.y) > 0.5f)) {
        {
            let _e50 = u_2;
            let _e55 = u_2;
            d_2 = max((abs(_e50.x) - 0.5f), (abs(_e55.y) - 0.5f));
        }
    } else {
        {
            let _e61 = u_2;
            let _e63 = fCount;
            let _e64 = grid2dDistance1d(_e61.x, _e63);
            let _e65 = u_2;
            let _e67 = fCount;
            let _e68 = grid2dDistance1d(_e65.y, _e67);
            d_2 = min(_e64, _e68);
        }
    }
    let _e70 = d_2;
    let _e71 = th;
    let _e72 = blur_2;
    let _e73 = grid2dResponse(_e70, _e71, _e72);
    k = _e73;
    let _e75 = pos_1;
    let _e79 = global.U[0];
    let _e82 = pos_1;
    let _e91 = textureSample(t_source, samp, ((vec2<f32>((_e75.x / _e79.x), _e82.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e91;
    let _e93 = bkgCol;
    let _e94 = color_1;
    let _e95 = _e94.xyz;
    let _e96 = color_1;
    let _e99 = k;
    let _e106 = mergeColor(_e93, vec4<f32>(_e95.x, _e95.y, _e95.z, (_e96.w * (1f - _e99))));
    return _e106;
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
    let _e66 = global.U[8];
    let _e71 = global.U[9];
    let _e75 = global.U[10];
    let _e79 = global.U[11];
    let _e82 = global.U[12];
    let _e83 = _e82.xyz;
    let _e86 = global.U[13];
    let _e87 = _e86.xyz;
    let _e90 = global.U[14];
    let _e91 = _e90.xyz;
    let _e105 = grid2dGl((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
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
