struct Params {
    U: array<vec4<f32>, 14>,
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
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn getPos(p: vec2<f32>, ang: f32, bottomLeft: vec2<f32>, topRight: vec2<f32>) -> vec2<f32> {
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

fn lowFreqBanding(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, sourceDim: vec2<f32>, source2Dim: vec2<f32>, source2_specified: i32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var sourceDim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var source2_specified_1: i32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var color: vec4<f32>;
    var bestColor: vec4<f32>;
    var bestDist: f32 = 100f;
    var resolution: f32;
    var scale: f32;
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
    var pp: vec2<f32>;
    var local_5: vec4<f32>;
    var c: vec4<f32>;
    var dist: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    sourceDim_1 = sourceDim;
    source2Dim_1 = source2Dim;
    source2_specified_1 = source2_specified;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e25 = pos_1;
    let _e29 = global.U[0];
    let _e32 = pos_1;
    let _e41 = textureSample(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    color = _e41;
    let _e43 = color;
    bestColor = _e43;
    let _e49 = modelTransform_1[0];
    resolution = length(_e49.xy);
    let _e54 = resolution;
    scale = (1f / _e54);
    let _e57 = pos_1;
    p_2 = _e57;
    let _e59 = source2_specified_1;
    if (_e59 != 0i) {
        let _e62 = source2Dim_1;
        let _e64 = source2Dim_1;
        let _e68 = source2Dim_1;
        let _e74 = source2Dim_1;
        local_4 = vec2<f32>(((_e62.x / _e64.y) - (1f / _e68.y)), (1f - (1f / _e74.y)));
    } else {
        let _e79 = sourceDim_1;
        let _e81 = sourceDim_1;
        let _e85 = sourceDim_1;
        let _e91 = sourceDim_1;
        local_4 = vec2<f32>(((_e79.x / _e81.y) - (1f / _e85.y)), (1f - (1f / _e91.y)));
    }
    let _e97 = local_4;
    dim = _e97;
    let _e99 = modelTransform_1;
    orig = (_e99 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e107 = modelTransform_1;
    let _e116 = dim;
    scaledDim = (mat2x2<f32>(_e107[0].xy, _e107[1].xy) * (2f * _e116));
    let _e120 = scaledDim;
    let _e124 = orig;
    offset = ((_e120 / vec2(2f)) - _e124);
    let _e127 = p_2;
    let _e128 = offset;
    let _e130 = scaledDim;
    let _e133 = scaledDim;
    let _e135 = offset;
    bottomLeft_2 = ((floor(((_e127 + _e128) / _e130)) * _e133) - _e135);
    let _e138 = p_2;
    let _e139 = offset;
    let _e141 = scaledDim;
    let _e144 = scaledDim;
    let _e146 = offset;
    topRight_2 = ((ceil(((_e138 + _e139) / _e141)) * _e144) - _e146);
    loop {
        let _e151 = i;
        let _e152 = count_1;
        if !((_e151 < _e152)) {
            break;
        }
        {
            let _e158 = i;
            let _e160 = count_1;
            let _e165 = angle_1;
            ang_2 = (((f32(_e158) / f32(_e160)) * 3.1415927f) + _e165);
            let _e168 = p_2;
            let _e169 = ang_2;
            let _e170 = bottomLeft_2;
            let _e171 = topRight_2;
            let _e172 = getPos(_e168, _e169, _e170, _e171);
            pp = _e172;
            let _e174 = source2_specified_1;
            if (_e174 != 0i) {
                let _e177 = pp;
                let _e181 = global.U[0];
                let _e184 = pp;
                let _e193 = textureSample(t_source2_, samp, ((vec2<f32>((_e177.x / _e181.x), _e184.y) / vec2(2f)) + vec2(0.5f)));
                local_5 = _e193;
            } else {
                let _e194 = pp;
                let _e198 = global.U[0];
                let _e201 = pp;
                let _e210 = textureSample(t_source, samp, ((vec2<f32>((_e194.x / _e198.x), _e201.y) / vec2(2f)) + vec2(0.5f)));
                local_5 = _e210;
            }
            let _e212 = local_5;
            c = _e212;
            let _e214 = color;
            let _e215 = c;
            dist = length((_e214 - _e215));
            let _e219 = dist;
            let _e220 = bestDist;
            if (_e219 < _e220) {
                {
                    let _e222 = dist;
                    bestDist = _e222;
                    let _e223 = c;
                    bestColor = _e223;
                }
            }
        }
        continuing {
            let _e155 = i;
            i = (_e155 + 1i);
        }
    }
    let _e224 = color;
    let _e225 = bestColor;
    let _e226 = intensity_1;
    return mix(_e224, _e225, vec4(_e226));
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
    let _e67 = global.U[8];
    let _e71 = global.U[9];
    let _e76 = global.U[4];
    let _e80 = global.U[5];
    let _e84 = global.U[6];
    let _e89 = global.U[10];
    let _e93 = global.U[11];
    let _e94 = _e93.xyz;
    let _e97 = global.U[12];
    let _e98 = _e97.xyz;
    let _e101 = global.U[13];
    let _e102 = _e101.xyz;
    let _e116 = lowFreqBanding((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.xy, _e80.xy, i32(_e84.x), _e89.x, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
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
