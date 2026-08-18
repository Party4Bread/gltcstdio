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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
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

fn bismuth(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invModelTransform: mat3x3<f32>;
    var orig: vec2<f32>;
    var p: vec2<f32>;
    var N: i32;
    var delta: f32;
    var disp: vec2<f32>;
    var i: i32 = 0i;
    var inc: vec4<f32>;
    var totalDisp: vec2<f32>;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e16 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e16);
    let _e19 = invModelTransform;
    let _e20 = uv_1;
    let _e21 = tf(_e19, _e20);
    orig = _e21;
    let _e23 = orig;
    p = _e23;
    let _e25 = intensity_1;
    N = i32((abs(_e25) * 500f));
    let _e32 = intensity_1;
    delta = (0.001f * sign(_e32));
    let _e36 = invModelTransform;
    let _e44 = delta;
    let _e45 = angle_1;
    let _e47 = angle_1;
    disp = (mat2x2<f32>(_e36[0].xy, _e36[1].xy) * (_e44 * vec2<f32>(cos(_e45), sin(_e47))));
    loop {
        let _e55 = i;
        let _e56 = N;
        if !((_e55 < _e56)) {
            break;
        }
        {
            let _e62 = p;
            let _e66 = global.U[0];
            let _e69 = p;
            let _e78 = _mirror_wrap(((vec2<f32>((_e62.x / _e66.x), _e69.y) / vec2(2f)) + vec2(0.5f)));
            let _e79 = textureSample(t_source, samp, _e78);
            inc = _e79;
            let _e81 = inc;
            let _e83 = inc;
            let _e87 = inc;
            let _e89 = inc;
            if (max(abs((_e81.x - _e83.y)), abs((_e87.x - _e89.z))) < 0.01f) {
                {
                    let _e96 = p;
                    let _e97 = disp;
                    p = (_e96 - _e97);
                }
            }
            let _e99 = inc;
            let _e101 = inc;
            let _e104 = inc;
            let _e106 = inc;
            if ((_e99.x > _e101.y) && (_e104.x > _e106.z)) {
                {
                    let _e110 = p;
                    let _e111 = disp;
                    p = (_e110 + _e111);
                }
            } else {
                let _e113 = inc;
                let _e115 = inc;
                if (_e113.y > _e115.z) {
                    {
                        let _e118 = p;
                        let _e119 = disp;
                        p = (_e118 + _e119.yx);
                    }
                } else {
                    {
                        let _e122 = p;
                        let _e123 = disp;
                        p = (_e122 - _e123.yx);
                    }
                }
            }
        }
        continuing {
            let _e59 = i;
            i = (_e59 + 1i);
        }
    }
    let _e126 = p;
    let _e127 = orig;
    totalDisp = (_e126 - _e127);
    let _e130 = uv_1;
    let _e131 = totalDisp;
    let _e136 = global.U[0];
    let _e139 = uv_1;
    let _e140 = totalDisp;
    let _e150 = _mirror_wrap(((vec2<f32>(((_e130 + _e131).x / _e136.x), (_e139 + _e140).y) / vec2(2f)) + vec2(0.5f)));
    let _e151 = textureSample(t_source, samp, _e150);
    outColor = _e151;
    let _e153 = outColor;
    return _e153;
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
    let _e97 = bismuth((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, mat3x3<f32>(vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z)));
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
