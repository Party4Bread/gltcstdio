struct Params {
    U: array<vec4<f32>, 12>,
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

fn mlRand(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e8 = x_1;
    return fract(sin((_e8 * 43758.547f)));
}

fn mlDisplaceAngle(angle: f32, maxDisplacement: f32) -> f32 {
    var angle_1: f32;
    var maxDisplacement_1: f32;

    angle_1 = angle;
    maxDisplacement_1 = maxDisplacement;
    let _e10 = angle_1;
    let _e11 = maxDisplacement_1;
    let _e12 = angle_1;
    let _e13 = mlRand(_e12);
    return (_e10 + (_e11 * (_e13 - 0.5f)));
}

fn mlGetVecAngle2_(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;
    var len: f32;
    var angle_2: f32;
    var local: f32;

    u_1 = u;
    let _e8 = u_1;
    len = length(_e8);
    let _e11 = len;
    if (_e11 == 0f) {
        let _e15 = len;
        return vec2<f32>(0f, _e15);
    }
    let _e18 = u_1;
    let _e21 = u_1;
    if (abs(_e18.x) < abs(_e21.y)) {
        {
            let _e25 = u_1;
            let _e27 = len;
            angle_2 = acos((_e25.x / _e27));
            let _e30 = u_1;
            if (_e30.y < 0f) {
                let _e34 = angle_2;
                angle_2 = -(_e34);
            }
        }
    } else {
        {
            let _e36 = u_1;
            let _e38 = len;
            angle_2 = asin((_e36.y / _e38));
            let _e41 = u_1;
            if (_e41.x < 0f) {
                let _e45 = angle_2;
                let _e47 = u_1;
                if (_e47.y > 0f) {
                    local = 3.1415927f;
                } else {
                    local = -3.1415927f;
                }
                let _e55 = local;
                angle_2 = (-(_e45) + _e55);
            }
        }
    }
    let _e57 = angle_2;
    let _e58 = len;
    return vec2<f32>(_e57, _e58);
}

fn mlPerspective(u_2: vec2<f32>, angle_3: f32) -> vec2<f32> {
    var u_3: vec2<f32>;
    var angle_4: f32;
    var persp: f32;
    var Z: f32 = 4f;
    var z: f32;

    u_3 = u_2;
    angle_4 = angle_3;
    let _e10 = angle_4;
    if (_e10 != 0f) {
        {
            let _e16 = angle_4;
            persp = tan((1.5707964f - _e16));
            let _e22 = Z;
            let _e23 = u_3;
            let _e26 = Z;
            let _e28 = persp;
            let _e30 = u_3;
            z = ((_e22 * _e23.y) / ((-(_e26) * _e28) - _e30.y));
            let _e35 = u_3;
            let _e37 = z;
            let _e38 = Z;
            let _e41 = Z;
            let _e43 = z;
            let _e44 = persp;
            return vec2<f32>(((_e35.x * (_e37 + _e38)) / _e41), (_e43 * -(_e44)));
        }
    }
    let _e48 = u_3;
    return _e48;
}

fn mlReflect(d: f32, sourceAngle: f32, alpha: f32, halfAlpha: f32, halfRoundedAngle: f32) -> vec2<f32> {
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
    let _e16 = sourceAngle_1;
    let _e17 = halfAlpha_1;
    if (_e16 > _e17) {
        let _e19 = alpha_1;
        let _e20 = sourceAngle_1;
        sourceAngle_1 = (_e19 - _e20);
    }
    let _e22 = halfAlpha_1;
    let _e23 = halfRoundedAngle_1;
    cornerAngle = (_e22 - _e23);
    let _e26 = halfRoundedAngle_1;
    let _e29 = sourceAngle_1;
    let _e30 = cornerAngle;
    if ((_e26 == 0f) || (_e29 <= _e30)) {
        {
            let _e33 = d_1;
            let _e34 = sourceAngle_1;
            let _e36 = sourceAngle_1;
            return (_e33 * vec2<f32>(cos(_e34), sin(_e36)));
        }
    } else {
        {
            let _e40 = cornerAngle;
            if (_e40 == 0f) {
                cornerAngle = 0.001f;
            }
            let _e44 = d_1;
            let _e45 = sourceAngle_1;
            x_2 = (_e44 * cos(_e45));
            let _e49 = d_1;
            let _e50 = sourceAngle_1;
            y = (_e49 * sin(_e50));
            let _e54 = halfAlpha_1;
            cha = cos(_e54);
            let _e57 = halfAlpha_1;
            sha = sin(_e57);
            let _e60 = cornerAngle;
            cca = cos(_e60);
            let _e63 = cornerAngle;
            sca = sin(_e63);
            let _e66 = sha;
            let _e67 = sca;
            let _e69 = cca;
            let _e71 = cha;
            let _e73 = sha;
            let _e74 = sca;
            let _e76 = cca;
            let _e78 = cha;
            A = (((((_e66 / _e67) * _e69) - _e71) * (((_e73 / _e74) * _e76) - _e78)) - 1f);
            let _e85 = cha;
            let _e86 = x_2;
            let _e88 = sha;
            let _e89 = y;
            B = (2f * ((_e85 * _e86) + (_e88 * _e89)));
            let _e94 = x_2;
            let _e95 = x_2;
            let _e97 = y;
            let _e98 = y;
            C = -(((_e94 * _e95) + (_e97 * _e98)));
            let _e103 = B;
            let _e104 = B;
            let _e107 = A;
            let _e109 = C;
            delta2_ = ((_e103 * _e104) - ((4f * _e107) * _e109));
            let _e113 = delta2_;
            if (_e113 < 0f) {
                {
                    let _e116 = x_2;
                    let _e117 = y;
                    return vec2<f32>(_e116, _e117);
                }
            }
            let _e119 = B;
            let _e121 = delta2_;
            let _e125 = A;
            l = ((-(_e119) + sqrt(_e121)) / (2f * _e125));
            let _e129 = l;
            let _e130 = cha;
            cx = (_e129 * _e130);
            let _e133 = l;
            let _e134 = sha;
            cy = (_e133 * _e134);
            let _e137 = l;
            let _e138 = sha;
            let _e140 = sca;
            k = ((_e137 * _e138) / _e140);
            let _e143 = k;
            let _e144 = cca;
            Xp = (_e143 * _e144);
            let _e147 = k;
            let _e148 = sca;
            Yp = (_e147 * _e148);
            let _e151 = Xp;
            let _e152 = cx;
            R = (_e151 - _e152);
            let _e155 = Xp;
            let _e156 = Yp;
            let _e157 = R;
            let _e158 = sourceAngle_1;
            let _e159 = cornerAngle;
            return vec2<f32>(_e155, (_e156 + (_e157 * (_e158 - _e159))));
        }
    }
}

fn kaleidoscopeML(uv: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, regularity: f32, roundness: f32, perspective: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var regularity_1: f32;
    var roundness_1: f32;
    var perspective_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;
    var d_2: f32;
    var sourceAngle_2: f32 = 0f;
    var variability: f32;
    var halfAlpha_2: f32;
    var alpha_2: f32;
    var angLen: vec2<f32>;
    var ang: f32;
    var maxDisplacement_2: f32;
    var spikeAngle1_: f32 = 0f;
    var spikeAngle2_: f32;
    var i: i32 = 0i;
    var halfRoundedAngle_2: f32;
    var coord: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    regularity_1 = regularity;
    roundness_1 = roundness;
    perspective_1 = perspective;
    modelTransform_1 = modelTransform;
    let _e20 = uv_1;
    let _e21 = perspective_1;
    let _e22 = mlPerspective(_e20, _e21);
    u_4 = _e22;
    let _e24 = u_4;
    d_2 = length(_e24);
    let _e30 = regularity_1;
    variability = (1f - _e30);
    let _e35 = d_2;
    if (_e35 > 0f) {
        {
            let _e38 = u_4;
            let _e39 = mlGetVecAngle2_(_e38);
            angLen = _e39;
            let _e41 = angLen;
            ang = _e41.x;
            let _e44 = ang;
            if (_e44 < 0f) {
                let _e47 = ang;
                ang = (_e47 + 6.2831855f);
            }
            let _e50 = variability;
            if (_e50 == 0f) {
                {
                    let _e54 = spikeCount_1;
                    halfAlpha_2 = (3.1415927f / f32(_e54));
                    let _e57 = halfAlpha_2;
                    alpha_2 = (_e57 * 2f);
                    let _e60 = ang;
                    let _e61 = alpha_2;
                    sourceAngle_2 = (_e60 - (floor((_e60 / _e61)) * _e61));
                }
            } else {
                {
                    let _e69 = spikeCount_1;
                    maxDisplacement_2 = (12.566371f / f32(_e69));
                    let _e76 = spikeCount_1;
                    let _e79 = variability;
                    let _e80 = maxDisplacement_2;
                    let _e82 = mlDisplaceAngle((6.2831855f / f32(_e76)), (_e79 * _e80));
                    spikeAngle2_ = _e82;
                    loop {
                        let _e86 = i;
                        let _e87 = spikeCount_1;
                        if !((_e86 < _e87)) {
                            break;
                        }
                        {
                            let _e93 = i;
                            let _e94 = spikeCount_1;
                            let _e98 = ang;
                            let _e99 = spikeAngle2_;
                            if ((_e93 == (_e94 - 1i)) || (_e98 <= _e99)) {
                                {
                                    let _e102 = spikeAngle2_;
                                    let _e103 = spikeAngle1_;
                                    alpha_2 = (_e102 - _e103);
                                    let _e105 = alpha_2;
                                    halfAlpha_2 = (_e105 / 2f);
                                    let _e108 = ang;
                                    let _e109 = spikeAngle1_;
                                    sourceAngle_2 = (_e108 - _e109);
                                    break;
                                }
                            } else {
                                {
                                    let _e111 = spikeAngle2_;
                                    spikeAngle1_ = _e111;
                                    let _e112 = i;
                                    let _e118 = spikeCount_1;
                                    spikeAngle2_ = ((f32((_e112 + 2i)) * 6.2831855f) / f32(_e118));
                                    let _e121 = i;
                                    let _e122 = spikeCount_1;
                                    if (_e121 != (_e122 - 2i)) {
                                        let _e126 = spikeAngle2_;
                                        let _e127 = variability;
                                        let _e128 = maxDisplacement_2;
                                        let _e130 = mlDisplaceAngle(_e126, (_e127 * _e128));
                                        spikeAngle2_ = _e130;
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e90 = i;
                            i = (_e90 + 1i);
                        }
                    }
                }
            }
        }
    }
    let _e131 = halfAlpha_2;
    let _e132 = roundness_1;
    halfRoundedAngle_2 = (_e131 * _e132);
    let _e135 = d_2;
    let _e136 = sourceAngle_2;
    let _e137 = alpha_2;
    let _e138 = halfAlpha_2;
    let _e139 = halfRoundedAngle_2;
    let _e140 = mlReflect(_e135, _e136, _e137, _e138, _e139);
    coord = _e140;
    let _e142 = modelTransform_1;
    let _e144 = coord;
    coord = (_naga_inverse_3x3_f32(_e142) * vec3<f32>(_e144.x, _e144.y, 1f)).xy;
    let _e151 = coord;
    let _e155 = global.U[0];
    let _e158 = coord;
    let _e167 = _mirror_wrap(((vec2<f32>((_e151.x / _e155.x), _e158.y) / vec2(2f)) + vec2(0.5f)));
    let _e168 = textureSample(t_source, samp, _e167);
    return _e168;
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
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = kaleidoscopeML((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
    fragColor = _e106;
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
