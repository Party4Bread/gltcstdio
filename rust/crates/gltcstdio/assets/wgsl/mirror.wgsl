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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn mirror(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, border: f32, borderColor: vec4<f32>, borderType: i32, modelTransform: mat3x3<f32>, axisTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var border_1: f32;
    var borderColor_1: vec4<f32>;
    var borderType_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var axisTransform_1: mat3x3<f32>;
    var inRatio: f32;
    var axisNormal: vec2<f32>;
    var axisPoint: vec2<f32>;
    var translate: mat3x3<f32>;
    var d: f32;
    var pos2_: vec2<f32>;
    var center: vec2<f32>;
    var t1_: vec2<f32>;
    var t2_: vec2<f32>;
    var local: f32;
    var k: f32;
    var mirColor: vec4<f32>;
    var bordColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    border_1 = border;
    borderColor_1 = borderColor;
    borderType_1 = borderType;
    modelTransform_1 = modelTransform;
    axisTransform_1 = axisTransform;
    let _e24 = sourceDim_1;
    let _e26 = sourceDim_1;
    inRatio = (_e24.x / _e26.y);
    let _e30 = axisTransform_1;
    axisNormal = normalize((mat2x2<f32>(_e30[0].xy, _e30[1].xy) * vec2<f32>(1f, 0f)));
    let _e44 = axisTransform_1;
    axisPoint = (_e44 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e53 = mode_1;
    if (_e53 == 1i) {
        let _e62 = inRatio;
        translate = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e62, 0f, 1f));
    } else {
        let _e69 = mode_1;
        if (_e69 == 2i) {
            translate = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 1f, 1f));
        } else {
            translate = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(0f, 0f, 1f));
        }
    }
    let _e100 = mode_1;
    if (_e100 == 3i) {
        {
            let _e103 = axisPoint;
            center = _e103;
            let _e106 = center;
            let _e108 = pos_1;
            pos2_ = ((2f * _e106) - _e108);
            let _e110 = pos_1;
            let _e111 = center;
            let _e113 = axisNormal;
            d = dot((_e110 - _e111), _e113);
        }
    } else {
        {
            let _e115 = pos_1;
            let _e116 = axisPoint;
            let _e118 = axisNormal;
            d = dot((_e115 - _e116), _e118);
            let _e120 = pos_1;
            let _e122 = d;
            let _e124 = axisNormal;
            pos2_ = (_e120 - ((2f * _e122) * _e124));
        }
    }
    let _e127 = modelTransform_1;
    let _e128 = translate;
    let _e131 = pos_1;
    let _e132 = tf(_naga_inverse_3x3_f32((_e127 * _e128)), _e131);
    t1_ = _e132;
    let _e134 = modelTransform_1;
    let _e135 = translate;
    let _e138 = pos2_;
    let _e139 = tf(_naga_inverse_3x3_f32((_e134 * _e135)), _e138);
    t2_ = _e139;
    let _e141 = d;
    if (_e141 <= 0f) {
        local = 0f;
    } else {
        local = 1f;
    }
    let _e147 = local;
    k = _e147;
    let _e149 = borderType_1;
    if (_e149 == 1i) {
        {
            let _e152 = d;
            let _e154 = border_1;
            if (abs(_e152) < (_e154 * 0.1f)) {
                {
                    let _e158 = d;
                    let _e159 = border_1;
                    let _e163 = border_1;
                    k = ((_e158 + (_e159 * 0.1f)) / (_e163 * 0.2f));
                }
            }
        }
    }
    let _e167 = t1_;
    let _e171 = global.U[0];
    let _e174 = t1_;
    let _e183 = _mirror_wrap(((vec2<f32>((_e167.x / _e171.x), _e174.y) / vec2(2f)) + vec2(0.5f)));
    let _e184 = textureSample(t_source, samp, _e183);
    let _e185 = t2_;
    let _e189 = global.U[0];
    let _e192 = t2_;
    let _e201 = _mirror_wrap(((vec2<f32>((_e185.x / _e189.x), _e192.y) / vec2(2f)) + vec2(0.5f)));
    let _e202 = textureSample(t_source, samp, _e201);
    let _e203 = k;
    mirColor = mix(_e184, _e202, vec4(_e203));
    let _e213 = borderType_1;
    if (_e213 == 100i) {
        {
            let _e216 = d;
            let _e218 = border_1;
            if (abs(_e216) < (_e218 * 0.1f)) {
                let _e222 = borderColor_1;
                bordColor = _e222;
            }
        }
    } else {
        let _e223 = borderType_1;
        if (_e223 == 101i) {
            {
                let _e226 = d;
                let _e228 = border_1;
                if (abs(_e226) < (_e228 * 0.1f)) {
                    {
                        let _e233 = d;
                        let _e235 = border_1;
                        k = (1f - (abs(_e233) / (_e235 * 0.1f)));
                        let _e240 = borderColor_1;
                        let _e241 = _e240.xyz;
                        let _e242 = borderColor_1;
                        let _e244 = k;
                        bordColor = vec4<f32>(_e241.x, _e241.y, _e241.z, (_e242.w * _e244));
                    }
                }
            }
        }
    }
    let _e250 = mirColor;
    let _e251 = bordColor;
    let _e252 = mergeColor(_e250, _e251);
    return _e252;
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
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e82 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e112 = global.U[13];
    let _e113 = _e112.xyz;
    let _e116 = global.U[14];
    let _e117 = _e116.xyz;
    let _e120 = global.U[15];
    let _e121 = _e120.xyz;
    let _e135 = mirror((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, _e79, i32(_e82.x), mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)), mat3x3<f32>(vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e121.x, _e121.y, _e121.z)));
    fragColor = _e135;
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
