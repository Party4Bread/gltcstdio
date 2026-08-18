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
var t_source: texture_2d<f32>;

fn radialInterpolateBrokenGL(pos: vec2<f32>, outPos: vec2<f32>, count: i32, angle: f32, thickness: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var angle_1: f32;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var u: vec2<f32>;
    var d: f32;
    var thickn: f32;
    var ha: f32;
    var ang: f32;
    var angleRange: f32;
    var index: f32;
    var ang1_: f32;
    var ang2_: f32;
    var pos1_: vec2<f32>;
    var col1_: vec4<f32>;
    var pos2_: vec2<f32>;
    var col2_: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    count_1 = count;
    angle_1 = angle;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e18);
    let _e21 = invM;
    let _e22 = pos_1;
    u = (_e21 * vec3<f32>(_e22.x, _e22.y, 1f)).xy;
    let _e30 = u;
    d = length(_e30);
    let _e33 = thickness_1;
    thickn = _e33;
    let _e35 = d;
    let _e37 = thickn;
    let _e40 = d;
    if ((_e35 < (1f - _e37)) || (_e40 > 1f)) {
        {
            let _e44 = pos_1;
            let _e48 = global.U[0];
            let _e51 = pos_1;
            let _e60 = textureSample(t_source, samp, ((vec2<f32>((_e44.x / _e48.x), _e51.y) / vec2(2f)) + vec2(0.5f)));
            return _e60;
        }
    }
    let _e61 = angle_1;
    ha = (_e61 / 2f);
    let _e65 = angle_1;
    if (_e65 <= 6.2831855f) {
        {
            let _e68 = d;
            if (_e68 > 0f) {
                {
                    let _e71 = u;
                    let _e73 = d;
                    ang = acos((_e71.x / _e73));
                    let _e77 = u;
                    if (_e77.y < 0f) {
                        let _e82 = ang;
                        ang = (6.2831855f - _e82);
                    }
                    let _e84 = ang;
                    let _e88 = ha;
                    ang = (_e84 + (1.5707964f + _e88));
                    let _e91 = ang;
                    let _e93 = (_e91 + 6.2831855f);
                    ang = (_e93 - (floor((_e93 / 6.2831855f)) * 6.2831855f));
                    let _e99 = ang;
                    let _e100 = angle_1;
                    if (_e99 <= _e100) {
                        {
                            let _e102 = angle_1;
                            let _e103 = ang;
                            ang = (_e102 - _e103);
                            let _e105 = angle_1;
                            let _e106 = count_1;
                            angleRange = (_e105 / f32(_e106));
                            let _e110 = ang;
                            let _e111 = angle_1;
                            let _e113 = count_1;
                            index = floor(((_e110 / _e111) * f32(_e113)));
                            let _e118 = ha;
                            let _e120 = angleRange;
                            let _e121 = index;
                            ang1_ = (-(_e118) + (_e120 * _e121));
                            let _e125 = ha;
                            let _e127 = angleRange;
                            let _e128 = index;
                            ang2_ = (-(_e125) + (_e127 * (_e128 + 1f)));
                            let _e134 = modelTransform_1;
                            let _e135 = d;
                            let _e137 = ang1_;
                            let _e140 = d;
                            let _e142 = ang1_;
                            pos1_ = (_e134 * vec3<f32>((-(_e135) * sin(_e137)), (-(_e140) * cos(_e142)), 1f)).xy;
                            let _e150 = pos1_;
                            let _e154 = global.U[0];
                            let _e157 = pos1_;
                            let _e166 = textureSample(t_source, samp, ((vec2<f32>((_e150.x / _e154.x), _e157.y) / vec2(2f)) + vec2(0.5f)));
                            col1_ = _e166;
                            let _e168 = modelTransform_1;
                            let _e169 = d;
                            let _e171 = ang2_;
                            let _e174 = d;
                            let _e176 = ang2_;
                            pos2_ = (_e168 * vec3<f32>((-(_e169) * sin(_e171)), (-(_e174) * cos(_e176)), 1f)).xy;
                            let _e184 = pos2_;
                            let _e188 = global.U[0];
                            let _e191 = pos2_;
                            let _e200 = textureSample(t_source, samp, ((vec2<f32>((_e184.x / _e188.x), _e191.y) / vec2(2f)) + vec2(0.5f)));
                            col2_ = _e200;
                            let _e202 = col1_;
                            let _e203 = col2_;
                            let _e205 = ang;
                            let _e206 = angleRange;
                            let _e207 = index;
                            let _e210 = angleRange;
                            return mix(_e202, _e203, vec4((1f - ((_e205 - (_e206 * _e207)) / _e210))));
                        }
                    }
                }
            }
        }
    }
    let _e215 = pos_1;
    let _e219 = global.U[0];
    let _e222 = pos_1;
    let _e231 = textureSample(t_source, samp, ((vec2<f32>((_e215.x / _e219.x), _e222.y) / vec2(2f)) + vec2(0.5f)));
    return _e231;
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
    let _e66 = global.U[11];
    let _e71 = global.U[12];
    let _e75 = global.U[13];
    let _e79 = global.U[14];
    let _e80 = _e79.xyz;
    let _e83 = global.U[15];
    let _e84 = _e83.xyz;
    let _e87 = global.U[16];
    let _e88 = _e87.xyz;
    let _e102 = radialInterpolateBrokenGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, mat3x3<f32>(vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z)));
    fragColor = _e102;
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
