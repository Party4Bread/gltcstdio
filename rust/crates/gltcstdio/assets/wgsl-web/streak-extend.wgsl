struct Params {
    U: array<vec4<f32>, 10>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn streakExpand(uv: vec2<f32>, outPos: vec2<f32>, len: f32, shadows: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var len_1: f32;
    var shadows_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var lightness: f32 = 1f;
    var col: vec4<f32>;
    var outColor: vec4<f32>;
    var scale: f32;
    var step: f32;
    var local: f32;
    var p: vec2<f32>;
    var dx: f32;
    var dy: f32;
    var maxDx: f32 = 0.25f;
    var maxDy: f32 = 1f;

    uv_1 = uv;
    outPos_1 = outPos;
    len_1 = len;
    shadows_1 = shadows;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = inverseModelTransform;
    let _e20 = uv_1;
    let _e21 = tf(_e19, _e20);
    u_2 = _e21;
    let _e25 = uv_1;
    let _e29 = global.U[0];
    let _e32 = uv_1;
    let _e42 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)), 0f);
    col = _e42;
    let _e44 = col;
    outColor = _e44;
    let _e46 = u_2;
    if (_e46.y > 0f) {
        {
            let _e52 = inverseModelTransform[0];
            scale = length(_e52.xy);
            let _e56 = u_2;
            if (abs(_e56.x) < 1f) {
                {
                    let _e61 = scale;
                    let _e62 = len_1;
                    step = (_e61 * _e62);
                    let _e66 = len_1;
                    if (_e66 == 0f) {
                        local = 0f;
                    } else {
                        let _e70 = u_2;
                        let _e72 = step;
                        local = (_e70.y - (floor((_e70.y / _e72)) * _e72));
                    }
                    let _e78 = local;
                    u_2.y = _e78;
                    let _e79 = modelTransform_1;
                    let _e80 = u_2;
                    let _e81 = tf(_e79, _e80);
                    p = _e81;
                    let _e83 = p;
                    let _e87 = global.U[0];
                    let _e90 = p;
                    let _e100 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e83.x / _e87.x), _e90.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    outColor = _e100;
                }
            } else {
                let _e101 = shadows_1;
                if (_e101 > 0f) {
                    {
                        let _e104 = u_2;
                        let _e109 = scale;
                        dx = ((abs(_e104.x) - 1f) / _e109);
                        let _e112 = u_2;
                        let _e115 = scale;
                        dy = (abs(_e112.y) / _e115);
                        let _e122 = dy;
                        let _e123 = maxDy;
                        if (_e122 < _e123) {
                            let _e125 = dx;
                            let _e126 = maxDy;
                            let _e127 = dy;
                            let _e129 = maxDy;
                            let _e131 = shadows_1;
                            let _e133 = maxDx;
                            dx = (_e125 + ((((_e126 - _e127) / _e129) * _e131) * _e133));
                        }
                        let _e137 = shadows_1;
                        let _e138 = maxDx;
                        let _e140 = dx;
                        let _e145 = maxDx;
                        lightness = (1f - (clamp(((_e137 * _e138) - _e140), 0f, 1f) / _e145));
                        let _e148 = lightness;
                        if (_e148 > 1f) {
                            lightness = 1f;
                        }
                        let _e152 = col;
                        let _e153 = lightness;
                        let _e154 = lightness;
                        let _e155 = lightness;
                        outColor = (_e152 * vec4<f32>(_e153, _e154, _e155, 1f));
                    }
                }
            }
        }
    }
    let _e159 = outColor;
    return _e159;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e97 = streakExpand((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)));
    fragColor = _e97;
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
