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

fn hash22_(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e21 = u_1;
    let _e25 = u_1;
    return vec2<f32>(fract((sin(((_e8.x * 776.45f) + (_e12.y * 453.24f))) * 45.77f)), fract((sin(((_e21.x * 376.45f) + (_e25.y * 853.24f))) * 88.77f)));
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
    var id: vec2<f32>;
    var c: vec2<f32>;
    var d: f32;
    var j_1: f32;
    var i_1: f32;
    var id_1: vec2<f32>;
    var c_1: vec2<f32>;
    var v: vec2<f32>;
    var borderDist: f32;

    u_3 = u_2;
    intensity_1 = intensity;
    let _e10 = u_3;
    b = floor((_e10 + vec2(0.5f)));
    let _e18 = intensity_1;
    N = floor((2f + (0.5f * abs(_e18))));
    let _e37 = N;
    j = -(_e37);
    loop {
        let _e40 = j;
        let _e41 = N;
        if !((_e40 <= _e41)) {
            break;
        }
        {
            let _e47 = N;
            i = -(_e47);
            loop {
                let _e50 = i;
                let _e51 = N;
                if !((_e50 <= _e51)) {
                    break;
                }
                {
                    let _e57 = b;
                    let _e58 = i;
                    let _e59 = j;
                    id = (_e57 + vec2<f32>(_e58, _e59));
                    let _e63 = id;
                    let _e64 = intensity_1;
                    let _e65 = id;
                    let _e66 = hash22_(_e65);
                    c = (_e63 + (_e64 * (_e66 - vec2(0.5f))));
                    let _e73 = u_3;
                    let _e74 = c;
                    d = length((_e73 - _e74));
                    let _e78 = minD;
                    let _e79 = d;
                    if (_e78 >= _e79) {
                        {
                            let _e81 = minId;
                            secId = _e81;
                            let _e82 = secD;
                            thirdD = _e82;
                            let _e83 = minD;
                            secD = _e83;
                            let _e84 = id;
                            minId = _e84;
                            let _e85 = d;
                            minD = _e85;
                            let _e86 = c;
                            minC = _e86;
                        }
                    } else {
                        let _e87 = secD;
                        let _e88 = d;
                        if (_e87 >= _e88) {
                            {
                                let _e90 = id;
                                secId = _e90;
                                let _e91 = secD;
                                thirdD = _e91;
                                let _e92 = d;
                                secD = _e92;
                            }
                        } else {
                            let _e93 = thirdD;
                            let _e94 = d;
                            if (_e93 >= _e94) {
                                {
                                    let _e96 = d;
                                    thirdD = _e96;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e54 = i;
                    i = (_e54 + 1f);
                }
            }
        }
        continuing {
            let _e44 = j;
            j = (_e44 + 1f);
        }
    }
    let _e97 = N;
    j_1 = -(_e97);
    loop {
        let _e100 = j_1;
        let _e101 = N;
        if !((_e100 <= _e101)) {
            break;
        }
        {
            let _e107 = N;
            i_1 = -(_e107);
            loop {
                let _e110 = i_1;
                let _e111 = N;
                if !((_e110 <= _e111)) {
                    break;
                }
                {
                    let _e117 = b;
                    let _e118 = i_1;
                    let _e119 = j_1;
                    id_1 = (_e117 + vec2<f32>(_e118, _e119));
                    let _e123 = id_1;
                    let _e124 = minId;
                    if any((_e123 != _e124)) {
                        {
                            let _e127 = id_1;
                            let _e128 = intensity_1;
                            let _e129 = id_1;
                            let _e130 = hash22_(_e129);
                            c_1 = (_e127 + (_e128 * (_e130 - vec2(0.5f))));
                            let _e137 = c_1;
                            let _e138 = minC;
                            v = normalize((_e137 - _e138));
                            let _e142 = minC;
                            let _e143 = c_1;
                            let _e148 = u_3;
                            let _e149 = minC;
                            let _e151 = v;
                            borderDist = ((length((_e142 - _e143)) / 2f) - dot((_e148 - _e149), _e151));
                            let _e155 = borderDist;
                            let _e156 = minB;
                            minB = min(_e155, _e156);
                            let _e158 = minB;
                            let _e159 = borderDist;
                            if (_e158 == _e159) {
                                let _e161 = v;
                                let _e164 = v;
                                normal = vec2<f32>(-(_e161.x), _e164.y);
                            }
                        }
                    }
                }
                continuing {
                    let _e114 = i_1;
                    i_1 = (_e114 + 1f);
                }
            }
        }
        continuing {
            let _e104 = j_1;
            j_1 = (_e104 + 1f);
        }
    }
    let _e167 = minD;
    let _e168 = minId;
    let _e169 = minB;
    let _e170 = minC;
    let _e171 = normal;
    let _e172 = secD;
    let _e173 = secId;
    let _e174 = thirdD;
    return Tile(_e167, _e168, _e169, _e170, _e171, _e172, _e173, _e174);
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn voronoiHatch(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, viewTransform: mat3x3<f32>, variability: f32, shadows: f32, color1_: vec4<f32>, color2_: vec4<f32>, offset: f32, banding: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var viewTransform_1: mat3x3<f32>;
    var variability_1: f32;
    var shadows_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var offset_1: f32;
    var banding_1: f32;
    var u_4: vec2<f32>;
    var cell: Tile;
    var d_1: f32;
    var d2_: f32;
    var d3_: f32;
    var rounded: f32;
    var lightness: f32;
    var id_2: vec2<f32>;
    var even: f32;
    var dir: vec2<f32>;
    var k: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    viewTransform_1 = viewTransform;
    variability_1 = variability;
    shadows_1 = shadows;
    color1_1 = color1_;
    color2_1 = color2_;
    offset_1 = offset;
    banding_1 = banding;
    let _e26 = pos_1;
    u_4 = _e26;
    let _e28 = u_4;
    let _e29 = variability_1;
    let _e30 = getVoronoiTile(_e28, _e29);
    cell = _e30;
    let _e32 = cell;
    d_1 = _e32.centerDist;
    let _e35 = cell;
    d2_ = _e35.secondCenterDist;
    let _e38 = cell;
    d3_ = _e38.thirdCenterDist;
    let _e43 = d2_;
    let _e44 = d_1;
    let _e50 = d3_;
    let _e51 = d_1;
    rounded = min((2f / ((1f / max((_e43 - _e44), 0.001f)) + (1f / max((_e50 - _e51), 0.001f)))), 1f);
    let _e63 = shadows_1;
    let _e64 = rounded;
    lightness = smoothstep(-0.001f, _e63, abs(_e64));
    let _e68 = cell;
    id_2 = _e68.tileId;
    let _e71 = id_2;
    let _e73 = id_2;
    let _e75 = (_e71.x + _e73.y);
    even = (_e75 - (floor((_e75 / 2f)) * 2f));
    let _e82 = even;
    let _e84 = even;
    let _e87 = id_2;
    let _e88 = hash22_(_e87);
    let _e92 = variability_1;
    dir = normalize(mix(vec2<f32>(_e82, (1f - _e84)), (_e88 - vec2(0.5f)), vec2(_e92)));
    let _e97 = lightness;
    let _e98 = u_4;
    let _e99 = cell;
    let _e102 = dir;
    let _e104 = banding_1;
    let _e106 = offset_1;
    k = (_e97 * ((cos(((dot((_e98 - _e99.center), _e102) * _e104) + (_e106 * 3.1415927f))) * 0.5f) + 0.5f));
    let _e117 = color2_1;
    let _e118 = color1_1;
    let _e119 = k;
    outColor = mix(_e117, _e118, vec4(_e119));
    let _e123 = source_specified_1;
    if (_e123 == 1i) {
        let _e126 = outPos_1;
        let _e130 = global.U[0];
        let _e133 = outPos_1;
        let _e142 = textureSample(t_source, samp, ((vec2<f32>((_e126.x / _e130.x), _e133.y) / vec2(2f)) + vec2(0.5f)));
        let _e143 = outColor;
        let _e144 = mergeColor(_e142, _e143);
        return _e144;
    } else {
        let _e145 = outColor;
        return _e145;
    }
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
    let _e71 = global.U[1];
    let _e72 = _e71.xyz;
    let _e75 = global.U[2];
    let _e76 = _e75.xyz;
    let _e79 = global.U[3];
    let _e80 = _e79.xyz;
    let _e96 = global.U[6];
    let _e100 = global.U[7];
    let _e104 = global.U[8];
    let _e107 = global.U[9];
    let _e110 = global.U[10];
    let _e114 = global.U[11];
    let _e116 = voronoiHatch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x, _e104, _e107, _e110.x, _e114.x);
    fragColor = _e116;
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
