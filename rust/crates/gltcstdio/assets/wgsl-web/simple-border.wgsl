struct Params {
    U: array<vec4<f32>, 16>,
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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
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

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn simpleBorder(uv: vec2<f32>, outPos: vec2<f32>, border: f32, sourceDim: vec2<f32>, shadows: f32, outDim: vec2<f32>, colorOut: vec4<f32>, colorShadow: vec4<f32>, viewTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var border_1: f32;
    var sourceDim_1: vec2<f32>;
    var shadows_1: f32;
    var outDim_1: vec2<f32>;
    var colorOut_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var viewTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var ratio: f32;
    var borderSize: f32;
    var newBounds: vec2<f32>;
    var threshold: vec2<f32>;
    var u_4: vec2<f32>;
    var d: f32;
    var inside: bool;
    var shadow: f32 = 0f;
    var v: vec2<f32>;
    var v_1: vec2<f32>;
    var v_2: vec2<f32>;
    var local_1: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    border_1 = border;
    sourceDim_1 = sourceDim;
    shadows_1 = shadows;
    outDim_1 = outDim;
    colorOut_1 = colorOut;
    colorShadow_1 = colorShadow;
    viewTransform_1 = viewTransform;
    shadowTransform_1 = shadowTransform;
    modelTransform_1 = modelTransform;
    let _e28 = sourceDim_1;
    let _e30 = sourceDim_1;
    ratio = (_e28.x / _e30.y);
    let _e34 = border_1;
    let _e38 = ratio;
    borderSize = ((_e34 * 2f) * min(1f, _e38));
    let _e42 = ratio;
    let _e45 = borderSize;
    newBounds = (vec2<f32>(_e42, 1f) + vec2(_e45));
    let _e49 = outDim_1;
    let _e51 = outDim_1;
    let _e54 = ratio;
    let _e56 = newBounds;
    let _e60 = newBounds;
    threshold = vec2<f32>((((_e49.x / _e51.y) * _e54) / _e56.x), (1f / _e60.y));
    let _e65 = uv_1;
    u_4 = _e65;
    let _e67 = u_4;
    let _e68 = threshold;
    let _e69 = sdRectangle(_e67, _e68);
    d = _e69;
    let _e71 = d;
    inside = (_e71 < 0f);
    let _e77 = modelTransform_1;
    let _e79 = uv_1;
    let _e80 = tf(_naga_inverse_3x3_f32(_e77), _e79);
    v = _e80;
    let _e82 = inside;
    if _e82 {
        {
            let _e83 = shadows_1;
            if (_e83 < 0f) {
                {
                    let _e86 = shadowTransform_1;
                    let _e88 = u_4;
                    let _e89 = tf(_naga_inverse_3x3_f32(_e86), _e88);
                    v_1 = _e89;
                    let _e91 = v_1;
                    let _e92 = threshold;
                    let _e93 = sdRectangle(_e91, _e92);
                    d = _e93;
                    let _e94 = shadows_1;
                    let _e96 = d;
                    shadow = smoothstep(_e94, 0f, _e96);
                }
            }
        }
    } else {
        {
            let _e98 = shadows_1;
            if (_e98 > 0f) {
                {
                    let _e101 = shadowTransform_1;
                    let _e103 = u_4;
                    let _e104 = tf(_naga_inverse_3x3_f32(_e101), _e103);
                    v_2 = _e104;
                    let _e106 = v_2;
                    let _e107 = threshold;
                    let _e108 = sdRectangle(_e106, _e107);
                    d = _e108;
                    let _e109 = shadows_1;
                    let _e111 = d;
                    shadow = smoothstep(_e109, 0f, _e111);
                }
            }
        }
    }
    let _e113 = inside;
    if _e113 {
        let _e114 = v;
        let _e118 = global.U[0];
        let _e121 = v;
        let _e130 = _mirror_wrap(((vec2<f32>((_e114.x / _e118.x), _e121.y) / vec2(2f)) + vec2(0.5f)));
        let _e132 = textureSampleLevel(t_source, samp, _e130, 0f);
        local_1 = _e132;
    } else {
        let _e133 = v;
        let _e137 = global.U[0];
        let _e140 = v;
        let _e149 = _mirror_wrap(((vec2<f32>((_e133.x / _e137.x), _e140.y) / vec2(2f)) + vec2(0.5f)));
        let _e151 = textureSampleLevel(t_source, samp, _e149, 0f);
        let _e152 = colorOut_1;
        let _e153 = mergeColor(_e151, _e152);
        local_1 = _e153;
    }
    let _e155 = local_1;
    outCol = _e155;
    let _e157 = outCol;
    let _e158 = outCol;
    let _e159 = colorShadow_1;
    let _e160 = mergeColor(_e158, _e159);
    let _e161 = shadow;
    return mix(_e157, _e160, vec4(_e161));
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
    let _e70 = global.U[4];
    let _e74 = global.U[7];
    let _e78 = global.U[5];
    let _e82 = global.U[8];
    let _e85 = global.U[9];
    let _e88 = global.U[1];
    let _e89 = _e88.xyz;
    let _e92 = global.U[2];
    let _e93 = _e92.xyz;
    let _e96 = global.U[3];
    let _e97 = _e96.xyz;
    let _e113 = global.U[10];
    let _e114 = _e113.xyz;
    let _e117 = global.U[11];
    let _e118 = _e117.xyz;
    let _e121 = global.U[12];
    let _e122 = _e121.xyz;
    let _e138 = global.U[13];
    let _e139 = _e138.xyz;
    let _e142 = global.U[14];
    let _e143 = _e142.xyz;
    let _e146 = global.U[15];
    let _e147 = _e146.xyz;
    let _e161 = simpleBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.xy, _e74.x, _e78.xy, _e82, _e85, mat3x3<f32>(vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z), vec3<f32>(_e97.x, _e97.y, _e97.z)), mat3x3<f32>(vec3<f32>(_e114.x, _e114.y, _e114.z), vec3<f32>(_e118.x, _e118.y, _e118.z), vec3<f32>(_e122.x, _e122.y, _e122.z)), mat3x3<f32>(vec3<f32>(_e139.x, _e139.y, _e139.z), vec3<f32>(_e143.x, _e143.y, _e143.z), vec3<f32>(_e147.x, _e147.y, _e147.z)));
    fragColor = _e161;
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
