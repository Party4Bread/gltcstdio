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
            let _e61 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e44.x / _e48.x), _e51.y) / vec2(2f)) + vec2(0.5f)), 0f);
            return _e61;
        }
    }
    let _e62 = angle_1;
    ha = (_e62 / 2f);
    let _e66 = angle_1;
    if (_e66 <= 6.2831855f) {
        {
            let _e69 = d;
            if (_e69 > 0f) {
                {
                    let _e72 = u;
                    let _e74 = d;
                    ang = acos((_e72.x / _e74));
                    let _e78 = u;
                    if (_e78.y < 0f) {
                        let _e83 = ang;
                        ang = (6.2831855f - _e83);
                    }
                    let _e85 = ang;
                    let _e89 = ha;
                    ang = (_e85 + (1.5707964f + _e89));
                    let _e92 = ang;
                    let _e94 = (_e92 + 6.2831855f);
                    ang = (_e94 - (floor((_e94 / 6.2831855f)) * 6.2831855f));
                    let _e100 = ang;
                    let _e101 = angle_1;
                    if (_e100 <= _e101) {
                        {
                            let _e103 = angle_1;
                            let _e104 = ang;
                            ang = (_e103 - _e104);
                            let _e106 = angle_1;
                            let _e107 = count_1;
                            angleRange = (_e106 / f32(_e107));
                            let _e111 = ang;
                            let _e112 = angle_1;
                            let _e114 = count_1;
                            index = floor(((_e111 / _e112) * f32(_e114)));
                            let _e119 = ha;
                            let _e121 = angleRange;
                            let _e122 = index;
                            ang1_ = (-(_e119) + (_e121 * _e122));
                            let _e126 = ha;
                            let _e128 = angleRange;
                            let _e129 = index;
                            ang2_ = (-(_e126) + (_e128 * (_e129 + 1f)));
                            let _e135 = modelTransform_1;
                            let _e136 = d;
                            let _e138 = ang1_;
                            let _e141 = d;
                            let _e143 = ang1_;
                            pos1_ = (_e135 * vec3<f32>((-(_e136) * sin(_e138)), (-(_e141) * cos(_e143)), 1f)).xy;
                            let _e151 = pos1_;
                            let _e155 = global.U[0];
                            let _e158 = pos1_;
                            let _e168 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e151.x / _e155.x), _e158.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col1_ = _e168;
                            let _e170 = modelTransform_1;
                            let _e171 = d;
                            let _e173 = ang2_;
                            let _e176 = d;
                            let _e178 = ang2_;
                            pos2_ = (_e170 * vec3<f32>((-(_e171) * sin(_e173)), (-(_e176) * cos(_e178)), 1f)).xy;
                            let _e186 = pos2_;
                            let _e190 = global.U[0];
                            let _e193 = pos2_;
                            let _e203 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e186.x / _e190.x), _e193.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            col2_ = _e203;
                            let _e205 = col1_;
                            let _e206 = col2_;
                            let _e208 = ang;
                            let _e209 = angleRange;
                            let _e210 = index;
                            let _e213 = angleRange;
                            return mix(_e205, _e206, vec4((1f - ((_e208 - (_e209 * _e210)) / _e213))));
                        }
                    }
                }
            }
        }
    }
    let _e218 = pos_1;
    let _e222 = global.U[0];
    let _e225 = pos_1;
    let _e235 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e218.x / _e222.x), _e225.y) / vec2(2f)) + vec2(0.5f)), 0f);
    return _e235;
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
