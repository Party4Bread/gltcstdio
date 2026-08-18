struct Params {
    U: array<vec4<f32>, 17>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn columnCombine(pos: vec2<f32>, outPos: vec2<f32>, shadows: f32, thickness: f32, color: vec4<f32>, modelTransform: mat3x3<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var shadows_1: f32;
    var thickness_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d: f32;
    var local: vec4<f32>;
    var col: vec4<f32>;
    var dd: f32;
    var sh: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    shadows_1 = shadows;
    thickness_1 = thickness;
    color_1 = color;
    modelTransform_1 = modelTransform;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e23 = modelTransform_1;
    let _e25 = pos_1;
    let _e26 = tf(_naga_inverse_3x3_f32(_e23), _e25);
    u_2 = _e26;
    let _e28 = u_2;
    d = (abs(_e28.x) - 0.3f);
    let _e34 = d;
    if (_e34 > 0f) {
        let _e37 = viewTransform1_1;
        let _e39 = pos_1;
        let _e40 = tf(_naga_inverse_3x3_f32(_e37), _e39);
        let _e44 = global.U[0];
        let _e47 = viewTransform1_1;
        let _e49 = pos_1;
        let _e50 = tf(_naga_inverse_3x3_f32(_e47), _e49);
        let _e60 = textureSampleLevel(t_source1_, samp, ((vec2<f32>((_e40.x / _e44.x), _e50.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local = _e60;
    } else {
        let _e61 = viewTransform2_1;
        let _e63 = pos_1;
        let _e64 = tf(_naga_inverse_3x3_f32(_e61), _e63);
        let _e68 = global.U[0];
        let _e71 = viewTransform2_1;
        let _e73 = pos_1;
        let _e74 = tf(_naga_inverse_3x3_f32(_e71), _e73);
        let _e84 = textureSampleLevel(t_source2_, samp, ((vec2<f32>((_e64.x / _e68.x), _e74.y) / vec2(2f)) + vec2(0.5f)), 0f);
        local = _e84;
    }
    let _e86 = local;
    col = _e86;
    let _e88 = d;
    let _e91 = modelTransform_1[0];
    dd = (_e88 * length(_e91.xy));
    let _e96 = dd;
    let _e98 = thickness_1;
    if (abs(_e96) < (_e98 * 0.1f)) {
        let _e102 = color_1;
        let _e103 = _e102.xyz;
        return vec4<f32>(_e103.x, _e103.y, _e103.z, 1f);
    }
    let _e109 = shadows_1;
    let _e111 = d;
    let _e114 = shadows_1;
    if ((sign(_e109) == sign(_e111)) && (_e114 != 0f)) {
        {
            let _e118 = shadows_1;
            let _e120 = dd;
            sh = smoothstep(_e118, 0f, _e120);
            let _e123 = col;
            let _e124 = color_1;
            let _e125 = _e124.xyz;
            let _e126 = color_1;
            let _e128 = sh;
            let _e134 = mergeColor(_e123, vec4<f32>(_e125.x, _e125.y, _e125.z, (_e126.w * _e128)));
            col = _e134;
        }
    }
    let _e135 = col;
    return _e135;
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
    let _e67 = global.U[5];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e111 = global.U[13];
    let _e112 = _e111.xyz;
    let _e128 = global.U[14];
    let _e129 = _e128.xyz;
    let _e132 = global.U[15];
    let _e133 = _e132.xyz;
    let _e136 = global.U[16];
    let _e137 = _e136.xyz;
    let _e151 = columnCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, _e75, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)), mat3x3<f32>(vec3<f32>(_e129.x, _e129.y, _e129.z), vec3<f32>(_e133.x, _e133.y, _e133.z), vec3<f32>(_e137.x, _e137.y, _e137.z)));
    fragColor = _e151;
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
