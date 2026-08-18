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
var t_displacement: texture_2d<f32>;
@group(0) @binding(3) 
var t_source1_: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn iteratedQuickSilverGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, iterations: i32, phase: f32, modelTransform: mat3x3<f32>, displacement_specified: i32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var iterations_1: i32;
    var phase_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var displacement_specified_1: i32;
    var invM: mat3x3<f32>;
    var origPos: vec2<f32>;
    var originalPos: vec2<f32>;
    var intEff: f32;
    var i: i32 = 0i;
    var t: vec2<f32>;
    var local: vec4<f32>;
    var val: vec4<f32>;
    var local_1: vec2<f32>;
    var tt: vec2<f32>;
    var displacement: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    iterations_1 = iterations;
    phase_1 = phase;
    modelTransform_1 = modelTransform;
    displacement_specified_1 = displacement_specified;
    let _e21 = modelTransform_1;
    invM = _naga_inverse_3x3_f32(_e21);
    let _e24 = pos_1;
    origPos = _e24;
    let _e26 = pos_1;
    originalPos = _e26;
    let _e28 = intensity_1;
    let _e29 = intensity_1;
    intEff = ((_e28 * _e29) * 100f);
    let _e34 = intEff;
    if (_e34 != 0f) {
        {
            loop {
                let _e39 = i;
                let _e40 = iterations_1;
                if !((_e39 < _e40)) {
                    break;
                }
                {
                    let _e46 = invM;
                    let _e47 = pos_1;
                    t = (_e46 * vec3<f32>(_e47.x, _e47.y, 1f)).xy;
                    let _e55 = displacement_specified_1;
                    if (_e55 == 1i) {
                        let _e58 = t;
                        let _e62 = global.U[0];
                        let _e65 = t;
                        let _e74 = _mirror_wrap(((vec2<f32>((_e58.x / _e62.x), _e65.y) / vec2(2f)) + vec2(0.5f)));
                        let _e75 = textureSample(t_displacement, samp, _e74);
                        local = _e75;
                    } else {
                        let _e76 = t;
                        let _e80 = global.U[0];
                        let _e83 = t;
                        let _e92 = _mirror_wrap(((vec2<f32>((_e76.x / _e80.x), _e83.y) / vec2(2f)) + vec2(0.5f)));
                        let _e93 = textureSample(t_source1_, samp, _e92);
                        local = _e93;
                    }
                    let _e95 = local;
                    val = _e95;
                    let _e97 = val;
                    let _e99 = val;
                    let _e104 = (_e99.xy - vec2<f32>(0.5f, 0.5f));
                    val.x = _e104.x;
                    val.y = _e104.y;
                    let _e109 = phase_1;
                    if (_e109 == 0f) {
                        let _e112 = val;
                        local_1 = _e112.xy;
                    } else {
                        let _e114 = phase_1;
                        let _e116 = val;
                        let _e119 = phase_1;
                        let _e121 = val;
                        let _e125 = phase_1;
                        let _e127 = val;
                        let _e130 = phase_1;
                        let _e132 = val;
                        local_1 = vec2<f32>(((cos(_e114) * _e116.x) - (sin(_e119) * _e121.y)), ((cos(_e125) * _e127.y) + (sin(_e130) * _e132.x)));
                    }
                    let _e138 = local_1;
                    tt = _e138;
                    let _e140 = intEff;
                    let _e143 = tt;
                    displacement = ((_e140 * 0.004f) * _e143);
                    let _e146 = pos_1;
                    let _e147 = displacement;
                    pos_1 = (_e146 + _e147);
                }
                continuing {
                    let _e43 = i;
                    i = (_e43 + 1i);
                }
            }
        }
    }
    let _e149 = pos_1;
    let _e153 = global.U[0];
    let _e156 = pos_1;
    let _e165 = _mirror_wrap(((vec2<f32>((_e149.x / _e153.x), _e156.y) / vec2(2f)) + vec2(0.5f)));
    let _e166 = textureSample(t_source1_, samp, _e165);
    return _e166;
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
    let _e67 = global.U[6];
    let _e71 = global.U[7];
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e88 = global.U[11];
    let _e89 = _e88.xyz;
    let _e105 = global.U[4];
    let _e108 = iteratedQuickSilverGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), _e76.x, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)), i32(_e105.x));
    fragColor = _e108;
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
