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
var t_colorField: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn cpa_getSamplePos(p: vec2<f32>, ang: f32, bottomLeft: vec2<f32>, topRight: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var ang_1: f32;
    var bottomLeft_1: vec2<f32>;
    var topRight_1: vec2<f32>;
    var dir: vec2<f32>;
    var local: f32;
    var kx1_: f32;
    var local_1: f32;
    var kx2_: f32;
    var local_2: f32;
    var ky1_: f32;
    var local_3: f32;
    var ky2_: f32;
    var k: f32;

    p_1 = p;
    ang_1 = ang;
    bottomLeft_1 = bottomLeft;
    topRight_1 = topRight;
    let _e15 = ang_1;
    let _e17 = ang_1;
    dir = vec2<f32>(cos(_e15), sin(_e17));
    let _e21 = dir;
    if (_e21.x == 0f) {
        local = -1f;
    } else {
        let _e27 = bottomLeft_1;
        let _e29 = p_1;
        let _e32 = dir;
        local = ((_e27.x - _e29.x) / _e32.x);
    }
    let _e36 = local;
    kx1_ = _e36;
    let _e38 = dir;
    if (_e38.x == 0f) {
        local_1 = -1f;
    } else {
        let _e44 = topRight_1;
        let _e46 = p_1;
        let _e49 = dir;
        local_1 = ((_e44.x - _e46.x) / _e49.x);
    }
    let _e53 = local_1;
    kx2_ = _e53;
    let _e55 = dir;
    if (_e55.y == 0f) {
        local_2 = -1f;
    } else {
        let _e61 = bottomLeft_1;
        let _e63 = p_1;
        let _e66 = dir;
        local_2 = ((_e61.y - _e63.y) / _e66.y);
    }
    let _e70 = local_2;
    ky1_ = _e70;
    let _e72 = dir;
    if (_e72.y == 0f) {
        local_3 = -1f;
    } else {
        let _e78 = topRight_1;
        let _e80 = p_1;
        let _e83 = dir;
        local_3 = ((_e78.y - _e80.y) / _e83.y);
    }
    let _e87 = local_3;
    ky2_ = _e87;
    let _e89 = kx1_;
    k = _e89;
    let _e91 = k;
    let _e94 = kx2_;
    let _e97 = kx2_;
    let _e98 = k;
    if ((_e91 < 0f) || ((_e94 >= 0f) && (_e97 < _e98))) {
        let _e102 = kx2_;
        k = _e102;
    }
    let _e103 = k;
    let _e106 = ky2_;
    let _e109 = ky2_;
    let _e110 = k;
    if ((_e103 < 0f) || ((_e106 >= 0f) && (_e109 < _e110))) {
        let _e114 = ky2_;
        k = _e114;
    }
    let _e115 = k;
    let _e118 = ky1_;
    let _e121 = ky1_;
    let _e122 = k;
    if ((_e115 < 0f) || ((_e118 >= 0f) && (_e121 < _e122))) {
        let _e126 = ky1_;
        k = _e126;
    }
    let _e127 = p_1;
    let _e128 = k;
    let _e129 = dir;
    return (_e127 + (_e128 * _e129));
}

fn colorPickAngular(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, sourceDim: vec2<f32>, colorFieldDim: vec2<f32>, colorField_specified: i32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var colorFieldDim_1: vec2<f32>;
    var colorField_specified_1: i32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invM: mat3x3<f32>;
    var color: vec4<f32>;
    var bestColor: vec4<f32>;
    var bestDist: f32 = 100f;
    var p_2: vec2<f32>;
    var local_4: vec2<f32>;
    var dim: vec2<f32>;
    var orig: vec2<f32>;
    var scaledDim: vec2<f32>;
    var offset: vec2<f32>;
    var bottomLeft_2: vec2<f32>;
    var topRight_2: vec2<f32>;
    var i: i32 = 0i;
    var ang_2: f32;
    var sp: vec2<f32>;
    var local_5: vec4<f32>;
    var c: vec4<f32>;
    var dist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    sourceDim_1 = sourceDim;
    colorFieldDim_1 = colorFieldDim;
    colorField_specified_1 = colorField_specified;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e25 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e25);
    let _e28 = pos_1;
    let _e32 = global.U[0];
    let _e35 = pos_1;
    let _e44 = textureSample(t_source, samp, ((vec2<f32>((_e28.x / _e32.x), _e35.y) / vec2(2f)) + vec2(0.5f)));
    color = _e44;
    let _e46 = color;
    bestColor = _e46;
    let _e50 = pos_1;
    p_2 = _e50;
    let _e52 = colorField_specified_1;
    if (_e52 != 0i) {
        let _e55 = colorFieldDim_1;
        let _e57 = colorFieldDim_1;
        let _e61 = colorFieldDim_1;
        let _e67 = colorFieldDim_1;
        local_4 = vec2<f32>(((_e55.x / _e57.y) - (1f / _e61.y)), (1f - (1f / _e67.y)));
    } else {
        let _e72 = sourceDim_1;
        let _e74 = sourceDim_1;
        let _e78 = sourceDim_1;
        let _e84 = sourceDim_1;
        local_4 = vec2<f32>(((_e72.x / _e74.y) - (1f / _e78.y)), (1f - (1f / _e84.y)));
    }
    let _e90 = local_4;
    dim = _e90;
    let _e92 = invM;
    orig = (_e92 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e100 = invM;
    let _e109 = dim;
    scaledDim = (mat2x2<f32>(_e100[0].xy, _e100[1].xy) * (2f * _e109));
    let _e113 = scaledDim;
    let _e117 = orig;
    offset = ((_e113 / vec2(2f)) - _e117);
    let _e120 = p_2;
    let _e121 = offset;
    let _e123 = scaledDim;
    let _e126 = scaledDim;
    let _e128 = offset;
    bottomLeft_2 = ((floor(((_e120 + _e121) / _e123)) * _e126) - _e128);
    let _e131 = p_2;
    let _e132 = offset;
    let _e134 = scaledDim;
    let _e137 = scaledDim;
    let _e139 = offset;
    topRight_2 = ((ceil(((_e131 + _e132) / _e134)) * _e137) - _e139);
    loop {
        let _e144 = i;
        let _e145 = count_1;
        if !((_e144 < _e145)) {
            break;
        }
        {
            let _e151 = i;
            let _e153 = count_1;
            let _e158 = angle_1;
            ang_2 = (((f32(_e151) / f32(_e153)) * 6.2831855f) + _e158);
            let _e161 = p_2;
            let _e162 = ang_2;
            let _e163 = bottomLeft_2;
            let _e164 = topRight_2;
            let _e165 = cpa_getSamplePos(_e161, _e162, _e163, _e164);
            sp = _e165;
            let _e167 = colorField_specified_1;
            if (_e167 != 0i) {
                let _e170 = sp;
                let _e174 = global.U[0];
                let _e177 = sp;
                let _e186 = textureSample(t_colorField, samp, ((vec2<f32>((_e170.x / _e174.x), _e177.y) / vec2(2f)) + vec2(0.5f)));
                local_5 = _e186;
            } else {
                let _e187 = sp;
                let _e191 = global.U[0];
                let _e194 = sp;
                let _e203 = textureSample(t_source, samp, ((vec2<f32>((_e187.x / _e191.x), _e194.y) / vec2(2f)) + vec2(0.5f)));
                local_5 = _e203;
            }
            let _e205 = local_5;
            c = _e205;
            let _e207 = color;
            let _e208 = c;
            dist = length((_e207 - _e208));
            let _e212 = dist;
            let _e213 = bestDist;
            if (_e212 < _e213) {
                {
                    let _e215 = dist;
                    bestDist = _e215;
                    let _e216 = c;
                    bestColor = _e216;
                }
            }
        }
        continuing {
            let _e148 = i;
            i = (_e148 + 1i);
        }
    }
    let _e217 = color;
    let _e218 = bestColor;
    let _e219 = intensity_1;
    return mix(_e217, _e218, vec4(_e219));
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
    let _e67 = global.U[11];
    let _e71 = global.U[12];
    let _e76 = global.U[4];
    let _e80 = global.U[5];
    let _e84 = global.U[6];
    let _e89 = global.U[13];
    let _e93 = global.U[14];
    let _e94 = _e93.xyz;
    let _e97 = global.U[15];
    let _e98 = _e97.xyz;
    let _e101 = global.U[16];
    let _e102 = _e101.xyz;
    let _e116 = colorPickAngular((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.xy, _e80.xy, i32(_e84.x), _e89.x, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
