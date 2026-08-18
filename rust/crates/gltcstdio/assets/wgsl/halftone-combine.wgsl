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
var t_pattern: texture_2d<f32>;
@group(0) @binding(3) 
var t_source: texture_2d<f32>;

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e14 = c_1;
    let _e19 = c_1;
    return (((0.2989f * _e10.x) + (0.587f * _e14.y)) + (0.114f * _e19.z));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn halftoneCombine(uv: vec2<f32>, outPos: vec2<f32>, smoothen: f32, intensity: f32, modelTransform: mat3x3<f32>, color1_: vec4<f32>, color2_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var smoothen_1: f32;
    var intensity_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var threshold: f32;
    var samplePos: vec2<f32>;
    var color: vec4<f32> = vec4(0f);
    var N: i32 = 5i;
    var r: f32;
    var step: f32;
    var j: i32;
    var i: i32;
    var local: f32;
    var k: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    smoothen_1 = smoothen;
    intensity_1 = intensity;
    modelTransform_1 = modelTransform;
    color1_1 = color1_;
    color2_1 = color2_;
    let _e21 = modelTransform_1;
    let _e23 = uv_1;
    let _e24 = tf(_naga_inverse_3x3_f32(_e21), _e23);
    let _e28 = global.U[0];
    let _e31 = modelTransform_1;
    let _e33 = uv_1;
    let _e34 = tf(_naga_inverse_3x3_f32(_e31), _e33);
    let _e43 = textureSample(t_pattern, samp, ((vec2<f32>((_e24.x / _e28.x), _e34.y) / vec2(2f)) + vec2(0.5f)));
    let _e45 = luma(_e43.xyz);
    threshold = _e45;
    let _e47 = uv_1;
    samplePos = _e47;
    let _e52 = smoothen_1;
    if (_e52 > 0f) {
        {
            let _e59 = modelTransform_1[0];
            let _e62 = smoothen_1;
            r = ((length(_e59.xy) * _e62) * 3f);
            let _e67 = r;
            let _e68 = N;
            step = (_e67 / f32(_e68));
            let _e72 = N;
            j = -(_e72);
            loop {
                let _e75 = j;
                let _e76 = N;
                if !((_e75 <= _e76)) {
                    break;
                }
                {
                    let _e82 = N;
                    i = -(_e82);
                    loop {
                        let _e85 = i;
                        let _e86 = N;
                        if !((_e85 <= _e86)) {
                            break;
                        }
                        {
                            let _e92 = color;
                            let _e93 = samplePos;
                            let _e94 = i;
                            let _e96 = j;
                            let _e99 = step;
                            let _e105 = global.U[0];
                            let _e108 = samplePos;
                            let _e109 = i;
                            let _e111 = j;
                            let _e114 = step;
                            let _e125 = textureSample(t_source, samp, ((vec2<f32>(((_e93 + (vec2<f32>(f32(_e94), f32(_e96)) * _e99)).x / _e105.x), (_e108 + (vec2<f32>(f32(_e109), f32(_e111)) * _e114)).y) / vec2(2f)) + vec2(0.5f)));
                            color = (_e92 + _e125);
                        }
                        continuing {
                            let _e89 = i;
                            i = (_e89 + 1i);
                        }
                    }
                }
                continuing {
                    let _e79 = j;
                    j = (_e79 + 1i);
                }
            }
            let _e127 = color;
            let _e129 = N;
            let _e134 = N;
            color = (_e127 / vec4(f32((((2i * _e129) + 1i) * ((2i * _e134) + 1i)))));
        }
    } else {
        {
            let _e142 = samplePos;
            let _e146 = global.U[0];
            let _e149 = samplePos;
            let _e158 = textureSample(t_source, samp, ((vec2<f32>((_e142.x / _e146.x), _e149.y) / vec2(2f)) + vec2(0.5f)));
            color = _e158;
        }
    }
    let _e159 = color;
    let _e161 = luma(_e159.xyz);
    let _e162 = threshold;
    if (_e161 > _e162) {
        local = 1f;
    } else {
        local = 0f;
    }
    let _e167 = local;
    k = _e167;
    let _e169 = color2_1;
    let _e170 = color1_1;
    let _e171 = k;
    return mix(_e169, _e170, vec4(_e171));
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
    let _e67 = global.U[5];
    let _e71 = global.U[6];
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e100 = global.U[10];
    let _e103 = global.U[11];
    let _e104 = halftoneCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, mat3x3<f32>(vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z), vec3<f32>(_e84.x, _e84.y, _e84.z)), _e100, _e103);
    fragColor = _e104;
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
