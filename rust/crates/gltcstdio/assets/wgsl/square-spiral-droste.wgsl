struct Params {
    U: array<vec4<f32>, 16>,
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

fn ssdSquareAngle(u: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var ax: f32;
    var ay: f32;
    var d: f32;
    var n: vec2<f32>;
    var p: f32;

    u_1 = u;
    let _e8 = u_1;
    ax = abs(_e8.x);
    let _e12 = u_1;
    ay = abs(_e12.y);
    let _e16 = ax;
    let _e17 = ay;
    d = max(_e16, _e17);
    let _e20 = d;
    if (_e20 < 0.0001f) {
        return 0f;
    }
    let _e24 = u_1;
    let _e25 = d;
    n = (_e24 / vec2(_e25));
    let _e30 = n;
    let _e32 = n;
    if (_e30.x >= abs(_e32.y)) {
        {
            let _e36 = n;
            p = (_e36.y + 1f);
        }
    } else {
        let _e40 = n;
        let _e42 = n;
        if (_e40.y > abs(_e42.x)) {
            {
                let _e48 = n;
                p = (2f + (1f - _e48.x));
            }
        } else {
            let _e52 = n;
            let _e54 = n;
            if (_e52.x <= -(abs(_e54.y))) {
                {
                    let _e61 = n;
                    p = (4f + (1f - _e61.y));
                }
            } else {
                {
                    let _e66 = n;
                    p = (6f + (_e66.x + 1f));
                }
            }
        }
    }
    let _e71 = p;
    return ((_e71 / 8f) * 6.2831855f);
}

fn ssdSquareToCart(d_1: f32, angle: f32) -> vec2<f32> {
    var d_2: f32;
    var angle_1: f32;
    var p_1: f32;
    var n_1: vec2<f32>;

    d_2 = d_1;
    angle_1 = angle;
    let _e10 = angle_1;
    let _e14 = ((_e10 / 6.2831855f) * 8f);
    p_1 = (_e14 - (floor((_e14 / 8f)) * 8f));
    let _e22 = p_1;
    if (_e22 < 2f) {
        {
            let _e26 = p_1;
            n_1 = vec2<f32>(1f, (_e26 - 1f));
        }
    } else {
        let _e30 = p_1;
        if (_e30 < 4f) {
            {
                let _e34 = p_1;
                n_1 = vec2<f32>((1f - (_e34 - 2f)), 1f);
            }
        } else {
            let _e40 = p_1;
            if (_e40 < 6f) {
                {
                    let _e46 = p_1;
                    n_1 = vec2<f32>(-1f, (1f - (_e46 - 4f)));
                }
            } else {
                {
                    let _e53 = p_1;
                    n_1 = vec2<f32>((-1f + (_e53 - 6f)), -1f);
                }
            }
        }
    }
    let _e60 = n_1;
    let _e61 = d_2;
    return (_e60 * _e61);
}

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn squareSpiralDroste(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, distortion: f32, shapeAspectRatio: f32, thickness: f32, shadows: f32, colorShadow: vec4<f32>, colorBorder: vec4<f32>, texTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var shapeAspectRatio_1: f32;
    var thickness_1: f32;
    var shadows_1: f32;
    var colorShadow_1: vec4<f32>;
    var colorBorder_1: vec4<f32>;
    var texTransform_1: mat3x3<f32>;
    var u_4: vec2<f32>;
    var d_3: f32;
    var local: f32;
    var p_2: f32;
    var angle_2: f32;
    var widthAngle: f32 = 0.7853982f;
    var scale360_: f32;
    var a: f32;
    var s: f32;
    var dd: f32;
    var ddd: f32;
    var coord_d: f32;
    var coord: vec2<f32>;
    var winding: f32;
    var scoord: vec2<f32>;
    var ds: f32;
    var local_1: f32;
    var shadowing: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    distortion_1 = distortion;
    shapeAspectRatio_1 = shapeAspectRatio;
    thickness_1 = thickness;
    shadows_1 = shadows;
    colorShadow_1 = colorShadow;
    colorBorder_1 = colorBorder;
    texTransform_1 = texTransform;
    let _e28 = uv_1;
    let _e30 = shapeAspectRatio_1;
    u_4 = (_e28 * vec2<f32>((1f / _e30), 1f));
    let _e36 = u_4;
    let _e39 = u_4;
    d_3 = max(abs(_e36.x), abs(_e39.y));
    let _e44 = intensity_1;
    if (_e44 > 0f) {
        let _e49 = intensity_1;
        local = (1f / (1f + (_e49 * 10f)));
    } else {
        let _e55 = intensity_1;
        local = (1f + pow((-(_e55) * 100f), 0.75f));
    }
    let _e63 = local;
    p_2 = _e63;
    let _e65 = u_4;
    let _e66 = ssdSquareAngle(_e65);
    angle_2 = _e66;
    let _e72 = angle_2;
    angle_2 = (_e72 - (floor((_e72 / 6.2831855f)) * 6.2831855f));
    let _e78 = intensity_1;
    let _e79 = intensity_1;
    scale360_ = ((_e78 * _e79) * 0.1f);
    let _e84 = angle_2;
    a = (_e84 / 6.2831855f);
    let _e88 = scale360_;
    let _e89 = a;
    s = pow(_e88, _e89);
    let _e92 = d_3;
    let _e93 = s;
    let _e96 = scale360_;
    dd = (log((_e92 * _e93)) / log(_e96));
    let _e100 = dd;
    ddd = (_e100 - (floor((_e100 / 1f)) * 1f));
    let _e107 = ddd;
    let _e108 = thickness_1;
    if (_e107 < _e108) {
        let _e110 = colorBorder_1;
        return _e110;
    }
    let _e111 = ddd;
    let _e112 = ddd;
    let _e118 = distortion_1;
    coord_d = mix(_e111, (exp(_e112) / 2.7182817f), (1f - _e118));
    let _e122 = coord_d;
    let _e123 = angle_2;
    let _e124 = ssdSquareToCart(_e122, _e123);
    let _e125 = shapeAspectRatio_1;
    coord = (_e124 * vec2<f32>(_e125, 1f));
    let _e130 = dd;
    let _e131 = ddd;
    let _e133 = a;
    winding = ((_e130 - _e131) - _e133);
    let _e136 = coord;
    let _e138 = shapeAspectRatio_1;
    let _e143 = shadows_1;
    let _e149 = scale360_;
    let _e150 = winding;
    let _e153 = shadows_1;
    scoord = ((_e136 * vec2<f32>((1f / _e138), 1f)) - ((_e143 * vec2<f32>(1f, 1f)) * mix(1f, pow(_e149, -(_e150)), (_e153 * 0.1f))));
    let _e160 = scoord;
    let _e163 = scoord;
    ds = max(abs(_e160.x), abs(_e163.y));
    let _e169 = ds;
    if (_e169 > 1f) {
        let _e176 = ds;
        let _e181 = shadows_1;
        local_1 = mix(1f, max(0f, (6f - (5f * _e176))), (0.5f + (_e181 * 0.5f)));
    } else {
        local_1 = 1f;
    }
    let _e188 = local_1;
    shadowing = (1f - _e188);
    let _e191 = texTransform_1;
    let _e193 = coord;
    let _e194 = tf(_naga_inverse_3x3_f32(_e191), _e193);
    let _e198 = global.U[0];
    let _e201 = texTransform_1;
    let _e203 = coord;
    let _e204 = tf(_naga_inverse_3x3_f32(_e201), _e203);
    let _e213 = textureSample(t_source, samp, ((vec2<f32>((_e194.x / _e198.x), _e204.y) / vec2(2f)) + vec2(0.5f)));
    let _e214 = colorShadow_1;
    let _e215 = shadowing;
    return mix(_e213, _e214, vec4(_e215));
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e96 = global.U[13];
    let _e97 = _e96.xyz;
    let _e100 = global.U[14];
    let _e101 = _e100.xyz;
    let _e104 = global.U[15];
    let _e105 = _e104.xyz;
    let _e119 = squareSpiralDroste((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, _e90, _e93, mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)));
    fragColor = _e119;
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
