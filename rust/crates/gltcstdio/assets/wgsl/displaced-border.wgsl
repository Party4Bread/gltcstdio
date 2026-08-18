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
var t_displacement: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

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

fn displacedBorder(uv: vec2<f32>, outPos: vec2<f32>, border: f32, displacement_specified: i32, sourceDim: vec2<f32>, outDim: vec2<f32>, intensity: f32, balance: f32, colorOut: vec4<f32>, viewTransform: mat3x3<f32>, modelTransform: mat3x3<f32>, borderTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var border_1: f32;
    var displacement_specified_1: i32;
    var sourceDim_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var intensity_1: f32;
    var balance_1: f32;
    var colorOut_1: vec4<f32>;
    var viewTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var borderTransform_1: mat3x3<f32>;
    var ratio: f32;
    var borderSize: f32;
    var newBounds: vec2<f32>;
    var threshold: vec2<f32>;
    var u_2: vec2<f32>;
    var local: vec4<f32>;
    var inside: bool;
    var v: vec2<f32>;
    var local_1: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    border_1 = border;
    displacement_specified_1 = displacement_specified;
    sourceDim_1 = sourceDim;
    outDim_1 = outDim;
    intensity_1 = intensity;
    balance_1 = balance;
    colorOut_1 = colorOut;
    viewTransform_1 = viewTransform;
    modelTransform_1 = modelTransform;
    borderTransform_1 = borderTransform;
    let _e31 = sourceDim_1;
    let _e33 = sourceDim_1;
    ratio = (_e31.x / _e33.y);
    let _e37 = border_1;
    let _e41 = ratio;
    borderSize = ((_e37 * 2f) * min(1f, _e41));
    let _e45 = ratio;
    let _e48 = borderSize;
    newBounds = (vec2<f32>(_e45, 1f) + vec2(_e48));
    let _e52 = outDim_1;
    let _e54 = outDim_1;
    let _e57 = ratio;
    let _e59 = newBounds;
    let _e63 = newBounds;
    threshold = vec2<f32>((((_e52.x / _e54.y) * _e57) / _e59.x), (1f / _e63.y));
    let _e68 = uv_1;
    u_2 = _e68;
    let _e70 = u_2;
    let _e71 = intensity_1;
    let _e72 = displacement_specified_1;
    if (_e72 == 1i) {
        let _e75 = borderTransform_1;
        let _e77 = uv_1;
        let _e78 = tf(_naga_inverse_3x3_f32(_e75), _e77);
        let _e82 = global.U[0];
        let _e85 = borderTransform_1;
        let _e87 = uv_1;
        let _e88 = tf(_naga_inverse_3x3_f32(_e85), _e87);
        let _e97 = _mirror_wrap(((vec2<f32>((_e78.x / _e82.x), _e88.y) / vec2(2f)) + vec2(0.5f)));
        let _e98 = textureSample(t_displacement, samp, _e97);
        local = _e98;
    } else {
        let _e99 = borderTransform_1;
        let _e101 = uv_1;
        let _e102 = tf(_naga_inverse_3x3_f32(_e99), _e101);
        let _e106 = global.U[0];
        let _e109 = borderTransform_1;
        let _e111 = uv_1;
        let _e112 = tf(_naga_inverse_3x3_f32(_e109), _e111);
        let _e121 = _mirror_wrap(((vec2<f32>((_e102.x / _e106.x), _e112.y) / vec2(2f)) + vec2(0.5f)));
        let _e122 = textureSample(t_source, samp, _e121);
        local = _e122;
    }
    let _e124 = local;
    let _e129 = balance_1;
    u_2 = (_e70 + (_e71 * ((_e124.xy - vec2(0.5f)) + vec2(_e129))));
    let _e134 = u_2;
    let _e137 = threshold;
    let _e140 = u_2;
    let _e143 = threshold;
    inside = ((abs(_e134.x) <= _e137.x) && (abs(_e140.y) <= _e143.y));
    let _e148 = modelTransform_1;
    let _e150 = uv_1;
    let _e151 = tf(_naga_inverse_3x3_f32(_e148), _e150);
    v = _e151;
    let _e153 = inside;
    if _e153 {
        let _e154 = v;
        let _e158 = global.U[0];
        let _e161 = v;
        let _e170 = _mirror_wrap(((vec2<f32>((_e154.x / _e158.x), _e161.y) / vec2(2f)) + vec2(0.5f)));
        let _e171 = textureSample(t_source, samp, _e170);
        local_1 = _e171;
    } else {
        let _e172 = v;
        let _e176 = global.U[0];
        let _e179 = v;
        let _e188 = _mirror_wrap(((vec2<f32>((_e172.x / _e176.x), _e179.y) / vec2(2f)) + vec2(0.5f)));
        let _e189 = textureSample(t_source, samp, _e188);
        let _e190 = colorOut_1;
        let _e191 = mergeColor(_e189, _e190);
        local_1 = _e191;
    }
    let _e193 = local_1;
    return _e193;
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
    let _e71 = global.U[4];
    let _e76 = global.U[5];
    let _e80 = global.U[6];
    let _e84 = global.U[8];
    let _e88 = global.U[9];
    let _e92 = global.U[10];
    let _e95 = global.U[1];
    let _e96 = _e95.xyz;
    let _e99 = global.U[2];
    let _e100 = _e99.xyz;
    let _e103 = global.U[3];
    let _e104 = _e103.xyz;
    let _e120 = global.U[11];
    let _e121 = _e120.xyz;
    let _e124 = global.U[12];
    let _e125 = _e124.xyz;
    let _e128 = global.U[13];
    let _e129 = _e128.xyz;
    let _e145 = global.U[14];
    let _e146 = _e145.xyz;
    let _e149 = global.U[15];
    let _e150 = _e149.xyz;
    let _e153 = global.U[16];
    let _e154 = _e153.xyz;
    let _e168 = displacedBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.xy, _e80.xy, _e84.x, _e88.x, _e92, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)), mat3x3<f32>(vec3<f32>(_e146.x, _e146.y, _e146.z), vec3<f32>(_e150.x, _e150.y, _e150.z), vec3<f32>(_e154.x, _e154.y, _e154.z)));
    fragColor = _e168;
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
