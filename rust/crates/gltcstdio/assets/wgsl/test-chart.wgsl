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

fn hueToRgb(p: f32, q: f32, h: f32) -> f32 {
    var p_1: f32;
    var q_1: f32;
    var h_1: f32;

    p_1 = p;
    q_1 = q;
    h_1 = h;
    let _e11 = h_1;
    if (_e11 < 0f) {
        let _e14 = h_1;
        h_1 = (_e14 + 1f);
    }
    let _e17 = h_1;
    if (_e17 > 1f) {
        let _e20 = h_1;
        h_1 = (_e20 - 1f);
    }
    let _e24 = h_1;
    if ((6f * _e24) < 1f) {
        {
            let _e28 = p_1;
            let _e29 = q_1;
            let _e30 = p_1;
            let _e34 = h_1;
            return (_e28 + (((_e29 - _e30) * 6f) * _e34));
        }
    }
    let _e38 = h_1;
    if ((2f * _e38) < 1f) {
        {
            let _e42 = q_1;
            return _e42;
        }
    }
    let _e44 = h_1;
    if ((3f * _e44) < 2f) {
        {
            let _e48 = p_1;
            let _e49 = q_1;
            let _e50 = p_1;
            let _e57 = h_1;
            return (_e48 + (((_e49 - _e50) * 6f) * (0.6666667f - _e57)));
        }
    }
    let _e61 = p_1;
    return _e61;
}

fn hslToRgb(inc: vec4<f32>) -> vec4<f32> {
    var inc_1: vec4<f32>;
    var h_2: f32;
    var s: f32;
    var l: f32;
    var q_2: f32 = 0f;
    var p_2: f32;
    var r: f32;
    var g: f32;
    var b: f32;
    var outc: vec4<f32>;

    inc_1 = inc;
    let _e7 = inc_1;
    h_2 = (_e7.x - (floor((_e7.x / 360f)) * 360f));
    let _e15 = h_2;
    h_2 = (_e15 / 360f);
    let _e18 = inc_1;
    s = _e18.y;
    let _e21 = inc_1;
    l = _e21.z;
    let _e26 = l;
    if (_e26 < 0.5f) {
        let _e29 = l;
        let _e31 = s;
        q_2 = (_e29 * (1f + _e31));
    } else {
        let _e34 = l;
        let _e35 = s;
        let _e37 = s;
        let _e38 = l;
        q_2 = ((_e34 + _e35) - (_e37 * _e38));
    }
    let _e42 = l;
    let _e44 = q_2;
    p_2 = ((2f * _e42) - _e44);
    let _e48 = p_2;
    let _e49 = q_2;
    let _e50 = h_2;
    let _e55 = hueToRgb(_e48, _e49, (_e50 + 0.33333334f));
    r = max(0f, _e55);
    let _e59 = p_2;
    let _e60 = q_2;
    let _e61 = h_2;
    let _e62 = hueToRgb(_e59, _e60, _e61);
    g = max(0f, _e62);
    let _e66 = p_2;
    let _e67 = q_2;
    let _e68 = h_2;
    let _e73 = hueToRgb(_e66, _e67, (_e68 - 0.33333334f));
    b = max(0f, _e73);
    let _e78 = r;
    outc.x = min(_e78, 1f);
    let _e82 = g;
    outc.y = min(_e82, 1f);
    let _e86 = b;
    outc.z = min(_e86, 1f);
    let _e90 = inc_1;
    outc.w = _e90.w;
    let _e92 = outc;
    return _e92;
}

fn testChart(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, color1_: vec4<f32>, color2_: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var u: vec2<f32>;
    var uv: vec2<f32>;
    var d: f32;
    var local: vec4<f32>;
    var uv_1: vec2<f32>;
    var uv_2: vec2<f32>;
    var d_1: f32;
    var g_1: f32;
    var uv_3: vec2<f32>;
    var local_1: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    color1_1 = color1_;
    color2_1 = color2_;
    let _e15 = modelTransform_1;
    let _e17 = pos_1;
    u = (_naga_inverse_3x3_f32(_e15) * vec3<f32>(_e17.x, _e17.y, 1f)).xy;
    let _e25 = u;
    if (_e25.x < 0f) {
        {
            let _e29 = u;
            if (_e29.y < 0f) {
                {
                    let _e33 = u;
                    uv = ((_e33 + vec2(0.5f)) * 2f);
                    let _e40 = uv;
                    d = length(_e40);
                    let _e43 = d;
                    if (_e43 > 1f) {
                        let _e46 = color1_1;
                        return _e46;
                    } else {
                        let _e47 = d;
                        let _e50 = floor((_e47 * 6f));
                        if ((_e50 - (floor((_e50 / 2f)) * 2f)) == 0f) {
                            let _e58 = color1_1;
                            local = _e58;
                        } else {
                            let _e59 = color2_1;
                            local = _e59;
                        }
                        let _e61 = local;
                        return _e61;
                    }
                }
            } else {
                {
                    let _e62 = u;
                    uv_1 = _e62;
                    let _e64 = uv_1;
                    let _e69 = uv_1;
                    let _e73 = hslToRgb(vec4<f32>((_e64.x * 360f), 1f, _e69.y, 1f));
                    return _e73;
                }
            }
        }
    } else {
        {
            let _e74 = u;
            if (_e74.y < 0f) {
                {
                    let _e78 = u;
                    uv_2 = abs(_e78);
                    let _e81 = uv_2;
                    let _e83 = uv_2;
                    d_1 = (_e81.x + _e83.y);
                    let _e87 = d_1;
                    let _e88 = d_1;
                    g_1 = ((sin(((_e87 * _e88) * 25f)) + 1f) * 0.5f);
                    let _e98 = g_1;
                    let _e99 = g_1;
                    let _e100 = g_1;
                    return vec4<f32>(_e98, _e99, _e100, 1f);
                }
            } else {
                {
                    let _e103 = u;
                    uv_3 = _e103;
                    let _e105 = uv_3;
                    let _e110 = uv_3;
                    let _e115 = (floor((_e105.x * 6f)) + floor((_e110.y * 6f)));
                    if ((_e115 - (floor((_e115 / 2f)) * 2f)) == 0f) {
                        let _e123 = color1_1;
                        local_1 = _e123;
                    } else {
                        let _e124 = color2_1;
                        local_1 = _e124;
                    }
                    let _e126 = local_1;
                    return _e126;
                }
            }
        }
    }
    let _e127 = color1_1;
    let _e128 = color2_1;
    let _e129 = u;
    let _e131 = floor(_e129.x);
    return mix(_e127, _e128, vec4((_e131 - (floor((_e131 / 2f)) * 2f))));
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e66 = _e65.xyz;
    let _e69 = global.U[6];
    let _e70 = _e69.xyz;
    let _e73 = global.U[7];
    let _e74 = _e73.xyz;
    let _e90 = global.U[8];
    let _e93 = global.U[9];
    let _e94 = testChart((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), mat3x3<f32>(vec3<f32>(_e66.x, _e66.y, _e66.z), vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z)), _e90, _e93);
    fragColor = _e94;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
