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

fn rt_response(d: f32, glow: f32) -> f32 {
    var d_1: f32;
    var glow_1: f32;
    var dn: f32;
    var local: f32;
    var base: f32;
    var local_1: f32;

    d_1 = d;
    glow_1 = glow;
    let _e10 = d_1;
    dn = (_e10 * 100f);
    let _e14 = glow_1;
    if (_e14 < 0.2f) {
        local = 1f;
    } else {
        let _e19 = glow_1;
        local = (1f + ((_e19 - 0.2f) * 4f));
    }
    let _e26 = local;
    base = _e26;
    let _e28 = base;
    let _e29 = dn;
    if (_e29 <= 0f) {
        local_1 = 1f;
    } else {
        let _e34 = glow_1;
        let _e37 = dn;
        local_1 = min(1f, ((_e34 * 0.01f) / _e37));
    }
    let _e41 = local_1;
    let _e45 = dn;
    return ((_e28 * _e41) * smoothstep(2f, 1.2f, _e45));
}

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local_2: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local_2 = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local_2 = max(_e25.x, _e27.y);
    }
    let _e31 = local_2;
    return _e31;
}

fn spilloverChannels(c: vec4<f32>) -> vec4<f32> {
    var c_1: vec4<f32>;
    var overflow: f32;

    c_1 = c;
    let _e8 = c_1;
    let _e14 = c_1;
    let _e21 = c_1;
    overflow = (((max((_e8.x - 1f), 0f) + max((_e14.y - 1f), 0f)) + max((_e21.z - 1f), 0f)) / 3f);
    let _e32 = c_1;
    let _e34 = overflow;
    c_1.x = (_e32.x + _e34);
    let _e37 = c_1;
    let _e39 = overflow;
    c_1.y = (_e37.y + _e39);
    let _e42 = c_1;
    let _e44 = overflow;
    c_1.z = (_e42.z + _e44);
    let _e46 = c_1;
    return _e46;
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn rulerTicksGL(pos: vec2<f32>, outPos: vec2<f32>, glow_2: f32, color1_: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var glow_3: f32;
    var color1_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var p: vec2<f32>;
    var step: f32 = 0.02f;
    var n: f32;
    var local_3: f32;
    var bigTick: f32;
    var hTick: f32;
    var strokeHalf: f32;
    var q: vec2<f32>;
    var d_2: f32;
    var k: f32;
    var bkgCol: vec4<f32>;
    var glowCol: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    glow_3 = glow_2;
    color1_1 = color1_;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    let _e18 = pos_1;
    p = (_naga_inverse_3x3_f32(_e16) * vec3<f32>(_e18.x, _e18.y, 1f)).xy;
    let _e28 = p;
    let _e30 = step;
    n = floor(((_e28.y / _e30) + 0.5f));
    let _e36 = n;
    if (abs(_e36) > 50f) {
        let _e40 = pos_1;
        let _e44 = global.U[0];
        let _e47 = pos_1;
        let _e56 = textureSample(t_source, samp, ((vec2<f32>((_e40.x / _e44.x), _e47.y) / vec2(2f)) + vec2(0.5f)));
        return _e56;
    }
    let _e57 = n;
    let _e60 = (abs(_e57) + 0.5f);
    if ((_e60 - (floor((_e60 / 5f)) * 5f)) < 1f) {
        local_3 = 1.5f;
    } else {
        local_3 = 1f;
    }
    let _e71 = local_3;
    bigTick = _e71;
    let _e74 = bigTick;
    hTick = (0.05f * _e74);
    let _e78 = bigTick;
    strokeHalf = (0.0015f * _e78);
    let _e81 = p;
    let _e83 = p;
    let _e85 = n;
    let _e86 = step;
    q = vec2<f32>(_e81.x, (_e83.y - (_e85 * _e86)));
    let _e91 = q;
    let _e92 = hTick;
    let _e93 = strokeHalf;
    let _e95 = sdRectangle(_e91, vec2<f32>(_e92, _e93));
    d_2 = _e95;
    let _e97 = d_2;
    let _e98 = glow_3;
    let _e99 = rt_response(_e97, _e98);
    k = _e99;
    let _e101 = pos_1;
    let _e105 = global.U[0];
    let _e108 = pos_1;
    let _e117 = textureSample(t_source, samp, ((vec2<f32>((_e101.x / _e105.x), _e108.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e117;
    let _e119 = color1_1;
    let _e122 = k;
    let _e124 = (_e119.xyz * max(1f, _e122));
    let _e125 = color1_1;
    let _e131 = spilloverChannels(vec4<f32>(_e124.x, _e124.y, _e124.z, _e125.w));
    glowCol = _e131;
    let _e133 = bkgCol;
    let _e134 = glowCol;
    let _e135 = _e134.xyz;
    let _e136 = glowCol;
    let _e139 = k;
    let _e146 = mergeColor(_e133, vec4<f32>(_e135.x, _e135.y, _e135.z, (_e136.w * min(1f, _e139))));
    outCol = _e146;
    let _e148 = outCol;
    return _e148;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e73 = global.U[7];
    let _e74 = _e73.xyz;
    let _e77 = global.U[8];
    let _e78 = _e77.xyz;
    let _e81 = global.U[9];
    let _e82 = _e81.xyz;
    let _e96 = rulerTicksGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70, mat3x3<f32>(vec3<f32>(_e74.x, _e74.y, _e74.z), vec3<f32>(_e78.x, _e78.y, _e78.z), vec3<f32>(_e82.x, _e82.y, _e82.z)));
    fragColor = _e96;
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
