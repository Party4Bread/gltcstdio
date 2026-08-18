struct Params {
    U: array<vec4<f32>, 18>,
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
var t_legacy_1_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn rand(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e9 = x_1;
    return fract(sin((_e9 * 43758.547f)));
}

fn gkglDisplaceAngle(angle: f32, maxDisplacement: f32) -> f32 {
    var angle_1: f32;
    var maxDisplacement_1: f32;

    angle_1 = angle;
    maxDisplacement_1 = maxDisplacement;
    let _e11 = angle_1;
    let _e12 = maxDisplacement_1;
    let _e13 = angle_1;
    let _e14 = rand(_e13);
    return (_e11 + (_e12 * (_e14 - 0.5f)));
}

fn gkglPerspective(u: vec2<f32>, perspective: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var perspective_1: f32;
    var invP: f32;
    var Z: f32 = 4f;
    var z: f32;

    u_1 = u;
    perspective_1 = perspective;
    let _e11 = perspective_1;
    if (_e11 == 0f) {
        let _e14 = u_1;
        return _e14;
    }
    let _e18 = perspective_1;
    invP = tan((1.5707964f - _e18));
    let _e22 = invP;
    if (_e22 >= 10000f) {
        let _e25 = u_1;
        return _e25;
    }
    let _e28 = Z;
    let _e29 = u_1;
    let _e32 = Z;
    let _e34 = invP;
    let _e36 = u_1;
    z = ((_e28 * _e29.y) / ((-(_e32) * _e34) - _e36.y));
    let _e41 = u_1;
    let _e43 = z;
    let _e44 = Z;
    let _e47 = Z;
    let _e49 = z;
    let _e50 = invP;
    return vec2<f32>(((_e41.x * (_e43 + _e44)) / _e47), (_e49 * -(_e50)));
}

fn gkglReflect(d: f32, sourceAngle: f32, alpha: f32, halfAlpha: f32, halfRoundedAngle: f32) -> vec2<f32> {
    var d_1: f32;
    var sourceAngle_1: f32;
    var alpha_1: f32;
    var halfAlpha_1: f32;
    var halfRoundedAngle_1: f32;
    var cornerAngle: f32;
    var x_2: f32;
    var y: f32;
    var cha: f32;
    var sha: f32;
    var cca: f32;
    var sca: f32;
    var A: f32;
    var B: f32;
    var C: f32;
    var delta2_: f32;
    var l: f32;
    var cx: f32;
    var cy: f32;
    var k: f32;
    var Xp: f32;
    var Yp: f32;
    var R: f32;

    d_1 = d;
    sourceAngle_1 = sourceAngle;
    alpha_1 = alpha;
    halfAlpha_1 = halfAlpha;
    halfRoundedAngle_1 = halfRoundedAngle;
    let _e17 = sourceAngle_1;
    let _e18 = halfAlpha_1;
    if (_e17 > _e18) {
        let _e20 = alpha_1;
        let _e21 = sourceAngle_1;
        sourceAngle_1 = (_e20 - _e21);
    }
    let _e23 = halfAlpha_1;
    let _e24 = halfRoundedAngle_1;
    cornerAngle = (_e23 - _e24);
    let _e27 = halfRoundedAngle_1;
    let _e30 = sourceAngle_1;
    let _e31 = cornerAngle;
    if ((_e27 == 0f) || (_e30 <= _e31)) {
        {
            let _e34 = d_1;
            let _e35 = sourceAngle_1;
            let _e37 = sourceAngle_1;
            return (_e34 * vec2<f32>(cos(_e35), sin(_e37)));
        }
    } else {
        {
            let _e41 = cornerAngle;
            if (_e41 == 0f) {
                cornerAngle = 0.001f;
            }
            let _e45 = d_1;
            let _e46 = sourceAngle_1;
            x_2 = (_e45 * cos(_e46));
            let _e50 = d_1;
            let _e51 = sourceAngle_1;
            y = (_e50 * sin(_e51));
            let _e55 = halfAlpha_1;
            cha = cos(_e55);
            let _e58 = halfAlpha_1;
            sha = sin(_e58);
            let _e61 = cornerAngle;
            cca = cos(_e61);
            let _e64 = cornerAngle;
            sca = sin(_e64);
            let _e67 = sha;
            let _e68 = sca;
            let _e70 = cca;
            let _e72 = cha;
            let _e74 = sha;
            let _e75 = sca;
            let _e77 = cca;
            let _e79 = cha;
            A = (((((_e67 / _e68) * _e70) - _e72) * (((_e74 / _e75) * _e77) - _e79)) - 1f);
            let _e86 = cha;
            let _e87 = x_2;
            let _e89 = sha;
            let _e90 = y;
            B = (2f * ((_e86 * _e87) + (_e89 * _e90)));
            let _e95 = x_2;
            let _e96 = x_2;
            let _e98 = y;
            let _e99 = y;
            C = -(((_e95 * _e96) + (_e98 * _e99)));
            let _e104 = B;
            let _e105 = B;
            let _e108 = A;
            let _e110 = C;
            delta2_ = ((_e104 * _e105) - ((4f * _e108) * _e110));
            let _e114 = delta2_;
            if (_e114 < 0f) {
                {
                    let _e117 = x_2;
                    let _e118 = y;
                    return vec2<f32>(_e117, _e118);
                }
            }
            let _e120 = B;
            let _e122 = delta2_;
            let _e126 = A;
            l = ((-(_e120) + sqrt(_e122)) / (2f * _e126));
            let _e130 = l;
            let _e131 = cha;
            cx = (_e130 * _e131);
            let _e134 = l;
            let _e135 = sha;
            cy = (_e134 * _e135);
            let _e138 = l;
            let _e139 = sha;
            let _e141 = sca;
            k = ((_e138 * _e139) / _e141);
            let _e144 = k;
            let _e145 = cca;
            Xp = (_e144 * _e145);
            let _e148 = k;
            let _e149 = sca;
            Yp = (_e148 * _e149);
            let _e152 = Xp;
            let _e153 = cx;
            R = (_e152 - _e153);
            let _e156 = Xp;
            let _e157 = Yp;
            let _e158 = R;
            let _e159 = sourceAngle_1;
            let _e160 = cornerAngle;
            return vec2<f32>(_e156, (_e157 + (_e158 * (_e159 - _e160))));
        }
    }
}

fn glitchKaleidoscope(uv: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, regularity: f32, roundedness: f32, perspective_2: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var regularity_1: f32;
    var roundedness_1: f32;
    var perspective_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var d_2: f32;
    var sourceAngle_2: f32 = 0f;
    var variability: f32;
    var halfAlpha_2: f32 = 0f;
    var alpha_2: f32 = 0f;
    var sCount: f32;
    var ang: f32;
    var maxDisplacement_2: f32;
    var spikeAngle1_: f32 = 0f;
    var spikeAngle2_: f32;
    var i: i32 = 0i;
    var halfRoundedAngle_2: f32;
    var coord: vec2<f32>;
    var kCoord: vec2<f32>;
    var kCol: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    regularity_1 = regularity;
    roundedness_1 = roundedness;
    perspective_3 = perspective_2;
    modelTransform_1 = modelTransform;
    let _e21 = uv_1;
    let _e22 = perspective_3;
    let _e23 = gkglPerspective(_e21, _e22);
    u_2 = _e23;
    let _e25 = u_2;
    d_2 = length(_e25);
    let _e31 = regularity_1;
    variability = (1f - _e31);
    let _e38 = spikeCount_1;
    sCount = f32(_e38);
    let _e41 = d_2;
    if (_e41 > 0f) {
        {
            let _e44 = u_2;
            let _e46 = u_2;
            ang = atan2(_e44.y, _e46.x);
            let _e50 = ang;
            if (_e50 < 0f) {
                let _e53 = ang;
                ang = (_e53 + 6.2831855f);
            }
            let _e56 = variability;
            if (_e56 == 0f) {
                {
                    let _e60 = sCount;
                    halfAlpha_2 = (3.1415927f / _e60);
                    let _e62 = halfAlpha_2;
                    alpha_2 = (_e62 * 2f);
                    let _e65 = ang;
                    let _e66 = alpha_2;
                    sourceAngle_2 = (_e65 - (floor((_e65 / _e66)) * _e66));
                }
            } else {
                {
                    let _e74 = sCount;
                    maxDisplacement_2 = (12.566371f / _e74);
                    let _e80 = sCount;
                    let _e82 = variability;
                    let _e83 = maxDisplacement_2;
                    let _e85 = gkglDisplaceAngle((6.2831855f / _e80), (_e82 * _e83));
                    spikeAngle2_ = _e85;
                    loop {
                        let _e89 = i;
                        let _e90 = spikeCount_1;
                        if !((_e89 < _e90)) {
                            break;
                        }
                        {
                            let _e96 = i;
                            let _e97 = spikeCount_1;
                            let _e101 = ang;
                            let _e102 = spikeAngle2_;
                            if ((_e96 == (_e97 - 1i)) || (_e101 <= _e102)) {
                                {
                                    let _e105 = spikeAngle2_;
                                    let _e106 = spikeAngle1_;
                                    alpha_2 = (_e105 - _e106);
                                    let _e108 = alpha_2;
                                    halfAlpha_2 = (_e108 / 2f);
                                    let _e111 = ang;
                                    let _e112 = spikeAngle1_;
                                    sourceAngle_2 = (_e111 - _e112);
                                    break;
                                }
                            } else {
                                {
                                    let _e114 = spikeAngle2_;
                                    spikeAngle1_ = _e114;
                                    let _e115 = i;
                                    let _e121 = sCount;
                                    spikeAngle2_ = ((f32((_e115 + 2i)) * 6.2831855f) / _e121);
                                    let _e123 = i;
                                    let _e124 = spikeCount_1;
                                    if (_e123 != (_e124 - 2i)) {
                                        let _e128 = spikeAngle2_;
                                        let _e129 = variability;
                                        let _e130 = maxDisplacement_2;
                                        let _e132 = gkglDisplaceAngle(_e128, (_e129 * _e130));
                                        spikeAngle2_ = _e132;
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e93 = i;
                            i = (_e93 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e133 = halfAlpha_2;
    let _e134 = roundedness_1;
    halfRoundedAngle_2 = (_e133 * _e134);
    let _e137 = d_2;
    let _e138 = sourceAngle_2;
    let _e139 = alpha_2;
    let _e140 = halfAlpha_2;
    let _e141 = halfRoundedAngle_2;
    let _e142 = gkglReflect(_e137, _e138, _e139, _e140, _e141);
    coord = _e142;
    let _e144 = modelTransform_1;
    let _e146 = coord;
    kCoord = (_naga_inverse_3x3_f32(_e144) * vec3<f32>(_e146.x, _e146.y, 1f)).xy;
    let _e154 = kCoord;
    let _e158 = global.U[0];
    let _e161 = kCoord;
    let _e170 = _mirror_wrap(((vec2<f32>((_e154.x / _e158.x), _e161.y) / vec2(2f)) + vec2(0.5f)));
    let _e171 = textureSample(t_source, samp, _e170);
    kCol = _e171;
    let _e173 = kCol;
    return _e173;
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
    let _e72 = global.U[12];
    let _e76 = global.U[13];
    let _e80 = global.U[14];
    let _e84 = global.U[15];
    let _e85 = _e84.xyz;
    let _e88 = global.U[16];
    let _e89 = _e88.xyz;
    let _e92 = global.U[17];
    let _e93 = _e92.xyz;
    let _e107 = glitchKaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, mat3x3<f32>(vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z)));
    fragColor = _e107;
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
