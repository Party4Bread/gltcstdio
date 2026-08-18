struct Params {
    U: array<vec4<f32>, 20>,
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

fn triColorBorder(uv: vec2<f32>, outPos: vec2<f32>, border: f32, thickness: f32, offset: f32, sourceDim: vec2<f32>, shadows: f32, outDim: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, colorShadow: vec4<f32>, viewTransform: mat3x3<f32>, shadowTransform: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var border_1: f32;
    var thickness_1: f32;
    var offset_1: f32;
    var sourceDim_1: vec2<f32>;
    var shadows_1: f32;
    var outDim_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var colorShadow_1: vec4<f32>;
    var viewTransform_1: mat3x3<f32>;
    var shadowTransform_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var ratio: f32;
    var borderSize: f32;
    var newBounds: vec2<f32>;
    var threshold: vec2<f32>;
    var u_4: vec2<f32>;
    var ur: vec2<f32>;
    var d: f32;
    var inside: bool;
    var shadow: f32 = 0f;
    var v: vec2<f32>;
    var v_1: vec2<f32>;
    var v_2: vec2<f32>;
    var borderColor: vec4<f32> = vec4(0f);
    var b: f32;
    var dRel: f32;
    var o: f32;
    var local_1: vec4<f32>;
    var outCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    border_1 = border;
    thickness_1 = thickness;
    offset_1 = offset;
    sourceDim_1 = sourceDim;
    shadows_1 = shadows;
    outDim_1 = outDim;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    colorShadow_1 = colorShadow;
    viewTransform_1 = viewTransform;
    shadowTransform_1 = shadowTransform;
    modelTransform_1 = modelTransform;
    let _e36 = sourceDim_1;
    let _e38 = sourceDim_1;
    ratio = (_e36.x / _e38.y);
    let _e42 = border_1;
    let _e46 = ratio;
    borderSize = ((_e42 * 2f) * min(1f, _e46));
    let _e50 = ratio;
    let _e53 = borderSize;
    newBounds = (vec2<f32>(_e50, 1f) + vec2(_e53));
    let _e57 = outDim_1;
    let _e59 = outDim_1;
    let _e62 = ratio;
    let _e64 = newBounds;
    let _e68 = newBounds;
    threshold = vec2<f32>((((_e57.x / _e59.y) * _e62) / _e64.x), (1f / _e68.y));
    let _e73 = uv_1;
    u_4 = _e73;
    let _e75 = u_4;
    let _e77 = threshold;
    ur = (abs(_e75) - _e77);
    let _e80 = ur;
    let _e82 = ur;
    d = max(_e80.x, _e82.y);
    let _e86 = d;
    inside = (_e86 < 0f);
    let _e92 = modelTransform_1;
    let _e94 = uv_1;
    let _e95 = tf(_naga_inverse_3x3_f32(_e92), _e94);
    v = _e95;
    let _e97 = inside;
    if _e97 {
        {
            let _e98 = shadows_1;
            if (_e98 < 0f) {
                {
                    let _e101 = shadowTransform_1;
                    let _e103 = u_4;
                    let _e104 = tf(_naga_inverse_3x3_f32(_e101), _e103);
                    v_1 = _e104;
                    let _e106 = v_1;
                    let _e107 = threshold;
                    let _e108 = sdRectangle(_e106, _e107);
                    d = _e108;
                    let _e109 = shadows_1;
                    let _e111 = d;
                    shadow = smoothstep(_e109, 0f, _e111);
                }
            }
        }
    } else {
        {
            let _e113 = shadows_1;
            if (_e113 > 0f) {
                {
                    let _e116 = shadowTransform_1;
                    let _e118 = u_4;
                    let _e119 = tf(_naga_inverse_3x3_f32(_e116), _e118);
                    v_2 = _e119;
                    let _e121 = v_2;
                    let _e122 = threshold;
                    let _e123 = sdRectangle(_e121, _e122);
                    d = _e123;
                    let _e124 = shadows_1;
                    let _e126 = d;
                    shadow = smoothstep(_e124, 0f, _e126);
                }
            }
        }
    }
    let _e131 = inside;
    if !(_e131) {
        {
            let _e134 = threshold;
            b = (1f - _e134.y);
            let _e138 = d;
            let _e139 = b;
            dRel = (_e138 / _e139);
            let _e142 = offset_1;
            o = ((_e142 * 0.5f) + 0.5f);
            let _e148 = dRel;
            let _e149 = o;
            let _e152 = thickness_1;
            if (abs((_e148 - _e149)) < (_e152 * 0.5f)) {
                let _e156 = color2_1;
                borderColor = _e156;
            } else {
                let _e157 = dRel;
                let _e158 = o;
                if (_e157 > _e158) {
                    let _e160 = color3_1;
                    borderColor = _e160;
                } else {
                    let _e161 = color1_1;
                    borderColor = _e161;
                }
            }
        }
    }
    let _e162 = inside;
    if _e162 {
        let _e163 = v;
        let _e167 = global.U[0];
        let _e170 = v;
        let _e179 = _mirror_wrap(((vec2<f32>((_e163.x / _e167.x), _e170.y) / vec2(2f)) + vec2(0.5f)));
        let _e180 = textureSample(t_source, samp, _e179);
        local_1 = _e180;
    } else {
        let _e181 = v;
        let _e185 = global.U[0];
        let _e188 = v;
        let _e197 = _mirror_wrap(((vec2<f32>((_e181.x / _e185.x), _e188.y) / vec2(2f)) + vec2(0.5f)));
        let _e198 = textureSample(t_source, samp, _e197);
        let _e199 = borderColor;
        let _e200 = mergeColor(_e198, _e199);
        local_1 = _e200;
    }
    let _e202 = local_1;
    outCol = _e202;
    let _e204 = outCol;
    let _e205 = outCol;
    let _e206 = colorShadow_1;
    let _e207 = mergeColor(_e205, _e206);
    let _e208 = shadow;
    return mix(_e204, _e207, vec4(_e208));
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
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[4];
    let _e82 = global.U[9];
    let _e86 = global.U[5];
    let _e90 = global.U[10];
    let _e93 = global.U[11];
    let _e96 = global.U[12];
    let _e99 = global.U[13];
    let _e102 = global.U[1];
    let _e103 = _e102.xyz;
    let _e106 = global.U[2];
    let _e107 = _e106.xyz;
    let _e110 = global.U[3];
    let _e111 = _e110.xyz;
    let _e127 = global.U[14];
    let _e128 = _e127.xyz;
    let _e131 = global.U[15];
    let _e132 = _e131.xyz;
    let _e135 = global.U[16];
    let _e136 = _e135.xyz;
    let _e152 = global.U[17];
    let _e153 = _e152.xyz;
    let _e156 = global.U[18];
    let _e157 = _e156.xyz;
    let _e160 = global.U[19];
    let _e161 = _e160.xyz;
    let _e175 = triColorBorder((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.xy, _e82.x, _e86.xy, _e90, _e93, _e96, _e99, mat3x3<f32>(vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z)), mat3x3<f32>(vec3<f32>(_e128.x, _e128.y, _e128.z), vec3<f32>(_e132.x, _e132.y, _e132.z), vec3<f32>(_e136.x, _e136.y, _e136.z)), mat3x3<f32>(vec3<f32>(_e153.x, _e153.y, _e153.z), vec3<f32>(_e157.x, _e157.y, _e157.z), vec3<f32>(_e161.x, _e161.y, _e161.z)));
    fragColor = _e175;
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
