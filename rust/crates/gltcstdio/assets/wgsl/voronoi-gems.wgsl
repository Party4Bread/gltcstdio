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

fn hash22_(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e7 = u_1;
    let _e11 = u_1;
    let _e20 = u_1;
    let _e24 = u_1;
    return vec2<f32>(fract((sin(((_e7.x * 776.45f) + (_e11.y * 453.24f))) * 45.77f)), fract((sin(((_e20.x * 376.45f) + (_e24.y * 853.24f))) * 88.77f)));
}

fn color(id: vec2<f32>) -> vec3<f32> {
    var id_1: vec2<f32>;

    id_1 = id;
    let _e9 = id_1;
    let _e10 = hash22_(_e9);
    let _e13 = (vec2(0.25f) + (0.75f * _e10));
    let _e16 = id_1;
    let _e20 = hash22_((_e16 + vec2(123f)));
    return vec3<f32>(_e13.x, _e13.y, (0.5f + (0.05f * _e20.x)));
}

fn getVoronoiTile(u_2: vec2<f32>, intensity: f32) -> Tile {
    var u_3: vec2<f32>;
    var intensity_1: f32;
    var b: vec2<f32>;
    var N: f32;
    var minD: f32 = 10000000000f;
    var minB: f32 = 10000000000f;
    var minId: vec2<f32>;
    var minC: vec2<f32>;
    var normal: vec2<f32> = vec2<f32>(0f, 1f);
    var secId: vec2<f32>;
    var secD: f32;
    var thirdD: f32;
    var j: f32;
    var i: f32;
    var id_2: vec2<f32>;
    var c: vec2<f32>;
    var d: f32;
    var j_1: f32;
    var i_1: f32;
    var id_3: vec2<f32>;
    var c_1: vec2<f32>;
    var v: vec2<f32>;
    var borderDist: f32;

    u_3 = u_2;
    intensity_1 = intensity;
    let _e9 = u_3;
    b = floor((_e9 + vec2(0.5f)));
    let _e17 = intensity_1;
    N = floor((2f + (0.5f * abs(_e17))));
    let _e36 = N;
    j = -(_e36);
    loop {
        let _e39 = j;
        let _e40 = N;
        if !((_e39 <= _e40)) {
            break;
        }
        {
            let _e46 = N;
            i = -(_e46);
            loop {
                let _e49 = i;
                let _e50 = N;
                if !((_e49 <= _e50)) {
                    break;
                }
                {
                    let _e56 = b;
                    let _e57 = i;
                    let _e58 = j;
                    id_2 = (_e56 + vec2<f32>(_e57, _e58));
                    let _e62 = id_2;
                    let _e63 = intensity_1;
                    let _e64 = id_2;
                    let _e65 = hash22_(_e64);
                    c = (_e62 + (_e63 * (_e65 - vec2(0.5f))));
                    let _e72 = u_3;
                    let _e73 = c;
                    d = length((_e72 - _e73));
                    let _e77 = minD;
                    let _e78 = d;
                    if (_e77 >= _e78) {
                        {
                            let _e80 = minId;
                            secId = _e80;
                            let _e81 = secD;
                            thirdD = _e81;
                            let _e82 = minD;
                            secD = _e82;
                            let _e83 = id_2;
                            minId = _e83;
                            let _e84 = d;
                            minD = _e84;
                            let _e85 = c;
                            minC = _e85;
                        }
                    } else {
                        let _e86 = secD;
                        let _e87 = d;
                        if (_e86 >= _e87) {
                            {
                                let _e89 = id_2;
                                secId = _e89;
                                let _e90 = secD;
                                thirdD = _e90;
                                let _e91 = d;
                                secD = _e91;
                            }
                        } else {
                            let _e92 = thirdD;
                            let _e93 = d;
                            if (_e92 >= _e93) {
                                {
                                    let _e95 = d;
                                    thirdD = _e95;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e53 = i;
                    i = (_e53 + 1f);
                }
            }
        }
        continuing {
            let _e43 = j;
            j = (_e43 + 1f);
        }
    }
    let _e96 = N;
    j_1 = -(_e96);
    loop {
        let _e99 = j_1;
        let _e100 = N;
        if !((_e99 <= _e100)) {
            break;
        }
        {
            let _e106 = N;
            i_1 = -(_e106);
            loop {
                let _e109 = i_1;
                let _e110 = N;
                if !((_e109 <= _e110)) {
                    break;
                }
                {
                    let _e116 = b;
                    let _e117 = i_1;
                    let _e118 = j_1;
                    id_3 = (_e116 + vec2<f32>(_e117, _e118));
                    let _e122 = id_3;
                    let _e123 = minId;
                    if any((_e122 != _e123)) {
                        {
                            let _e126 = id_3;
                            let _e127 = intensity_1;
                            let _e128 = id_3;
                            let _e129 = hash22_(_e128);
                            c_1 = (_e126 + (_e127 * (_e129 - vec2(0.5f))));
                            let _e136 = c_1;
                            let _e137 = minC;
                            v = normalize((_e136 - _e137));
                            let _e141 = minC;
                            let _e142 = c_1;
                            let _e147 = u_3;
                            let _e148 = minC;
                            let _e150 = v;
                            borderDist = ((length((_e141 - _e142)) / 2f) - dot((_e147 - _e148), _e150));
                            let _e154 = borderDist;
                            let _e155 = minB;
                            minB = min(_e154, _e155);
                            let _e157 = minB;
                            let _e158 = borderDist;
                            if (_e157 == _e158) {
                                let _e160 = v;
                                let _e163 = v;
                                normal = vec2<f32>(-(_e160.x), _e163.y);
                            }
                        }
                    }
                }
                continuing {
                    let _e113 = i_1;
                    i_1 = (_e113 + 1f);
                }
            }
        }
        continuing {
            let _e103 = j_1;
            j_1 = (_e103 + 1f);
        }
    }
    let _e166 = minD;
    let _e167 = minId;
    let _e168 = minB;
    let _e169 = minC;
    let _e170 = normal;
    let _e171 = secD;
    let _e172 = secId;
    let _e173 = thirdD;
    return Tile(_e166, _e167, _e168, _e169, _e170, _e171, _e172, _e173);
}

fn voronoiGems(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, colorBleed: f32, variability: f32, shadows: f32, specular: f32, color1_: vec4<f32>, colorVariability: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var colorBleed_1: f32;
    var variability_1: f32;
    var shadows_1: f32;
    var specular_1: f32;
    var color1_1: vec4<f32>;
    var colorVariability_1: f32;
    var uv: vec2<f32>;
    var cell: Tile;
    var d_1: f32;
    var d2_: f32;
    var id_4: vec2<f32>;
    var secId_1: vec2<f32>;
    var b_1: f32;
    var normal_1: vec2<f32>;
    var s: f32;
    var light: f32;
    var plight: f32;
    var nlight: f32;
    var cb: f32;
    var local: vec3<f32>;
    var faceColor: vec3<f32>;
    var rgb: vec3<f32>;
    var col: vec3<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    colorBleed_1 = colorBleed;
    variability_1 = variability;
    shadows_1 = shadows;
    specular_1 = specular;
    color1_1 = color1_;
    colorVariability_1 = colorVariability;
    let _e23 = pos_1;
    uv = _e23;
    let _e25 = uv;
    let _e26 = variability_1;
    let _e29 = getVoronoiTile(_e25, (_e26 * 3f));
    cell = _e29;
    let _e31 = cell;
    d_1 = _e31.centerDist;
    let _e34 = cell;
    d2_ = _e34.secondCenterDist;
    let _e37 = cell;
    id_4 = _e37.tileId;
    let _e40 = cell;
    secId_1 = _e40.secondTileId;
    let _e43 = cell;
    b_1 = _e43.borderDist;
    let _e46 = mode_1;
    if (_e46 == 3i) {
        let _e49 = b_1;
        let _e52 = vec3((_e49 * 1.5f));
        return vec4<f32>(_e52.x, _e52.y, _e52.z, 1f);
    }
    let _e58 = cell;
    normal_1 = _e58.borderNormal;
    let _e61 = normal_1;
    s = dot(_e61, vec2<f32>(0f, 1f));
    let _e67 = b_1;
    let _e70 = shadows_1;
    light = pow(_e67, (0.35f * pow(1.06f, ((_e70 * 50f) - 50f))));
    let _e83 = s;
    plight = (1f + (1.5f * smoothstep(0.6f, 1f, _e83)));
    let _e89 = light;
    let _e94 = s;
    nlight = ((1f - _e89) * (1.5f + smoothstep(0.25f, 1f, -(_e94))));
    let _e100 = light;
    let _e102 = nlight;
    let _e103 = plight;
    let _e107 = s;
    let _e110 = specular_1;
    light = (_e100 * mix(1f, mix(_e102, _e103, smoothstep(-0.2f, 0.2f, _e107)), _e110));
    let _e116 = d_1;
    let _e122 = d2_;
    let _e123 = d_1;
    cb = ((0.05f * smoothstep(0f, 0.9f, _e116)) + (0.25f * smoothstep(2f, 1f, (_e122 / _e123))));
    let _e129 = mode_1;
    if (_e129 == 1i) {
        let _e132 = id_4;
        let _e133 = color(_e132);
        local = _e133;
    } else {
        let _e134 = normal_1;
        let _e140 = normal_1;
        local = vec3<f32>(((_e134.x * 0.5f) + 0.5f), ((_e140.y * 0.5f) + 0.5f), 0.5f);
    }
    let _e149 = local;
    faceColor = _e149;
    let _e151 = color1_1;
    let _e153 = faceColor;
    let _e154 = colorVariability_1;
    rgb = mix(_e151.xyz, _e153, vec3(_e154));
    let _e158 = rgb;
    let _e159 = secId_1;
    let _e160 = color(_e159);
    let _e161 = colorBleed_1;
    let _e162 = cb;
    let _e166 = light;
    col = (mix(_e158, _e160, vec3((_e161 * _e162))) * _e166);
    let _e169 = col;
    return vec4<f32>(_e169.x, _e169.y, _e169.z, 1f);
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e91 = voronoiGems((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), _e70.x, _e74.x, _e78.x, _e82.x, _e86, _e89.x);
    fragColor = _e91;
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
