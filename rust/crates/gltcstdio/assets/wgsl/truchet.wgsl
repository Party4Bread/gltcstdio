struct Params {
    U: array<vec4<f32>, 12>,
    u_types: array<vec4<i32>, 16>,
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

fn hash(a: i32, b: i32) -> i32 {
    var a_1: i32;
    var b_1: i32;

    a_1 = a;
    b_1 = b;
    let _e12 = a_1;
    let _e13 = b_1;
    let _e15 = a_1;
    let _e16 = b_1;
    let _e23 = a_1;
    return ((((_e12 + _e13) * ((_e15 + _e16) + 1i)) / 2i) + _e23);
}

fn hashmore(i: i32, j: i32, regularity: f32) -> i32 {
    var i_1: i32;
    var j_1: i32;
    var regularity_1: f32;
    var x: f32;
    var y: f32;
    var h: i32;
    var local: i32;

    i_1 = i;
    j_1 = j;
    regularity_1 = regularity;
    let _e14 = i_1;
    x = f32(_e14);
    let _e17 = j_1;
    y = f32(_e17);
    let _e20 = x;
    let _e23 = y;
    let _e28 = x;
    let _e29 = y;
    h = i32((fract((sin(((_e20 * 12.9898f) + (_e23 * 78.233f))) * ((_e28 / ((_e29 - (floor((_e29 / 1000f)) * 1000f)) + 1f)) + 458.5453f))) * 1000f));
    let _e46 = regularity_1;
    if (_e46 == 0f) {
        let _e49 = h;
        return _e49;
    }
    let _e50 = i_1;
    let _e51 = j_1;
    let _e52 = hash(_e50, _e51);
    let _e53 = f32(_e52);
    let _e59 = regularity_1;
    if ((_e53 - (floor((_e53 / 100f)) * 100f)) >= (_e59 * 100f)) {
        let _e63 = h;
        local = _e63;
    } else {
        let _e64 = i_1;
        let _e65 = j_1;
        local = ((_e64 + _e65) * 50i);
    }
    let _e70 = local;
    return _e70;
}

fn getLevel(i_2: i32, j_2: i32, distribution: f32, regularity_2: f32, levels: i32) -> i32 {
    var i_3: i32;
    var j_3: i32;
    var distribution_1: f32;
    var regularity_3: f32;
    var levels_1: i32;
    var d: f32;
    var k: f32;
    var div: f32;
    var local_1: i32;
    var local_2: i32;
    var F: vec2<f32>;
    var I: i32;
    var J: i32;

    i_3 = i_2;
    j_3 = j_2;
    distribution_1 = distribution;
    regularity_3 = regularity_2;
    levels_1 = levels;
    let _e18 = distribution_1;
    d = _e18;
    let _e21 = d;
    let _e24 = levels_1;
    k = pow((100f / _e21), (1f / f32(_e24)));
    let _e30 = levels_1;
    div = pow(2f, f32(_e30));
    loop {
        let _e34 = levels_1;
        if !((_e34 >= 1i)) {
            break;
        }
        {
            let _e38 = i_3;
            let _e39 = i_3;
            if (_e39 < 0i) {
                let _e42 = div;
                local_1 = (i32(_e42) - 1i);
            } else {
                local_1 = 0i;
            }
            let _e48 = local_1;
            let _e51 = j_3;
            let _e52 = j_3;
            if (_e52 < 0i) {
                let _e55 = div;
                local_2 = (i32(_e55) - 1i);
            } else {
                local_2 = 0i;
            }
            let _e61 = local_2;
            let _e65 = div;
            F = (vec2<f32>(f32((_e38 - _e48)), f32((_e51 - _e61))) / vec2(_e65));
            let _e69 = F;
            I = i32(_e69.x);
            let _e73 = F;
            J = i32(_e73.y);
            let _e77 = I;
            let _e80 = J;
            let _e83 = regularity_3;
            let _e84 = hashmore((_e77 + 11i), (_e80 + 14i), _e83);
            let _e85 = f32(_e84);
            let _e91 = d;
            if ((_e85 - (floor((_e85 / 100f)) * 100f)) > _e91) {
                let _e93 = levels_1;
                return _e93;
            }
            let _e94 = d;
            let _e95 = k;
            d = (_e94 / _e95);
            let _e97 = div;
            div = (_e97 / 2f);
            let _e100 = levels_1;
            levels_1 = (_e100 - 1i);
        }
    }
    return 0i;
}

fn getType(i_4: i32, j_4: i32, types_size: i32, regularity_4: f32) -> i32 {
    var i_5: i32;
    var j_5: i32;
    var types_size_1: i32;
    var regularity_5: f32;

    i_5 = i_4;
    j_5 = j_4;
    types_size_1 = types_size;
    regularity_5 = regularity_4;
    let _e16 = i_5;
    let _e17 = j_5;
    let _e18 = regularity_5;
    let _e19 = hashmore(_e16, _e17, _e18);
    let _e20 = f32(_e19);
    let _e21 = types_size_1;
    let _e22 = f32(_e21);
    let _e29 = global.u_types[i32((_e20 - (floor((_e20 / _e22)) * _e22)))];
    return i32(_e29.x);
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e12 = bkg_1;
    let _e14 = front_1;
    let _e16 = front_1;
    let _e19 = bkg_1;
    let _e23 = front_1;
    let _e29 = mix(_e12.xyz, _e14.xyz, vec3((_e16.w + ((1f - _e19.w) * (1f - _e23.w)))));
    let _e30 = bkg_1;
    let _e32 = front_1;
    return vec4<f32>(_e29.x, _e29.y, _e29.z, max(_e30.w, _e32.w));
}

fn inWing(pos: vec2<f32>, center: vec2<f32>, ox: f32, oy: f32, r2_: f32) -> bool {
    var pos_1: vec2<f32>;
    var center_1: vec2<f32>;
    var ox_1: f32;
    var oy_1: f32;
    var r2_1: f32;
    var delta: vec2<f32>;

    pos_1 = pos;
    center_1 = center;
    ox_1 = ox;
    oy_1 = oy;
    r2_1 = r2_;
    let _e18 = pos_1;
    let _e19 = center_1;
    let _e21 = ox_1;
    let _e23 = center_1;
    let _e25 = oy_1;
    delta = (_e18 - vec2<f32>((_e19.x + _e21), (_e23.y + _e25)));
    let _e30 = delta;
    let _e31 = delta;
    let _e33 = r2_1;
    return (dot(_e30, _e31) < _e33);
}

fn minWing(wing: i32, pos_2: vec2<f32>, i_6: i32, j_6: i32, distribution_2: f32, regularity_6: f32, levels_2: i32) -> i32 {
    var wing_1: i32;
    var pos_3: vec2<f32>;
    var i_7: i32;
    var j_7: i32;
    var distribution_3: f32;
    var regularity_7: f32;
    var levels_3: i32;
    var mLevel: i32;
    var W: i32;
    var level: i32;
    var len: f32;
    var halflen: f32;
    var exp: f32;
    var center_2: vec2<f32>;
    var radius: f32;
    var ppos: vec2<f32>;
    var rel: vec2<f32>;
    var wingc: vec2<f32>;
    var delta_1: vec2<f32>;

    wing_1 = wing;
    pos_3 = pos_2;
    i_7 = i_6;
    j_7 = j_6;
    distribution_3 = distribution_2;
    regularity_7 = regularity_6;
    levels_3 = levels_2;
    let _e22 = i_7;
    let _e23 = j_7;
    let _e24 = distribution_3;
    let _e25 = regularity_7;
    let _e26 = levels_3;
    let _e27 = getLevel(_e22, _e23, _e24, _e25, _e26);
    mLevel = _e27;
    let _e29 = wing_1;
    W = _e29;
    let _e31 = mLevel;
    level = _e31;
    loop {
        let _e33 = level;
        let _e34 = W;
        if !((_e33 < _e34)) {
            break;
        }
        {
            len = 1f;
            let _e42 = len;
            halflen = (_e42 / 2f);
            let _e47 = level;
            exp = pow(2f, f32(_e47));
            let _e51 = i_7;
            let _e53 = exp;
            let _e56 = halflen;
            let _e58 = j_7;
            let _e60 = exp;
            let _e63 = halflen;
            center_2 = vec2<f32>((floor((f32(_e51) / _e53)) + _e56), (floor((f32(_e58) / _e60)) + _e63));
            let _e67 = len;
            radius = (_e67 / 3f);
            let _e71 = pos_3;
            let _e72 = exp;
            ppos = (_e71 / vec2(_e72));
            let _e76 = ppos;
            let _e78 = center_2;
            let _e82 = ppos;
            let _e84 = center_2;
            let _e89 = halflen;
            let _e90 = radius;
            if (max(abs((_e76.x - _e78.x)), abs((_e82.y - _e84.y))) <= (_e89 + _e90)) {
                {
                    let _e93 = ppos;
                    let _e94 = center_2;
                    rel = (_e93 - _e94);
                    let _e97 = rel;
                    let _e99 = halflen;
                    wingc = (sign(_e97) * _e99);
                    let _e102 = wingc;
                    let _e106 = wingc;
                    if ((_e102.x != 0f) && (_e106.y != 0f)) {
                        {
                            let _e111 = rel;
                            let _e112 = wingc;
                            delta_1 = (_e111 - _e112);
                            let _e115 = delta_1;
                            let _e117 = radius;
                            if (length(_e115) < _e117) {
                                let _e119 = level;
                                return _e119;
                            }
                        }
                    }
                }
            }
        }
        continuing {
            let _e37 = level;
            level = (_e37 + 1i);
        }
    }
    let _e120 = wing_1;
    return _e120;
}

fn in2ThirdCircle(cx: f32, cy: f32, u: vec2<f32>) -> bool {
    var cx_1: f32;
    var cy_1: f32;
    var u_1: vec2<f32>;

    cx_1 = cx;
    cy_1 = cy;
    u_1 = u;
    let _e14 = cx_1;
    let _e15 = cy_1;
    let _e17 = u_1;
    return (length((vec2<f32>(_e14, _e15) - _e17)) <= 0.33333334f);
}

fn inThirdCircle(cx_2: f32, cy_2: f32, u_2: vec2<f32>) -> bool {
    var cx_3: f32;
    var cy_3: f32;
    var u_3: vec2<f32>;

    cx_3 = cx_2;
    cy_3 = cy_2;
    u_3 = u_2;
    let _e14 = cx_3;
    let _e15 = cy_3;
    let _e17 = u_3;
    return (length((vec2<f32>(_e14, _e15) - _e17)) <= 0.16666666f);
}

fn inThirds(d_1: f32) -> bool {
    var d_2: f32;

    d_2 = d_1;
    let _e10 = d_2;
    let _e13 = d_2;
    return ((_e10 >= 0.33333334f) && (_e13 <= 0.6666667f));
}

fn truchetTile(u_4: vec2<f32>, type_45: i32) -> bool {
    var u_5: vec2<f32>;
    var type_46: i32;

    u_5 = u_4;
    type_46 = type_45;
    let _e12 = type_46;
    if (_e12 == 1i) {
        let _e18 = u_5;
        let _e21 = inThirds(length((vec2<f32>(0f, 1f) - _e18)));
        let _e25 = u_5;
        let _e28 = inThirds(length((vec2<f32>(1f, 0f) - _e25)));
        return (_e21 || _e28);
    } else {
        let _e30 = type_46;
        if (_e30 == 2i) {
            let _e35 = u_5;
            let _e36 = in2ThirdCircle(0f, 0f, _e35);
            let _e40 = u_5;
            let _e41 = in2ThirdCircle(1f, 0f, _e40);
            let _e46 = u_5;
            let _e47 = in2ThirdCircle(0f, 1f, _e46);
            let _e52 = u_5;
            let _e53 = in2ThirdCircle(1f, 1f, _e52);
            return (((!(_e36) && !(_e41)) && !(_e47)) && !(_e53));
        } else {
            let _e56 = type_46;
            if (_e56 == 3i) {
                let _e61 = u_5;
                let _e62 = inThirdCircle(0f, 0.5f, _e61);
                let _e65 = u_5;
                let _e66 = inThirdCircle(1f, 0.5f, _e65);
                let _e70 = u_5;
                let _e71 = inThirdCircle(0.5f, 0f, _e70);
                let _e75 = u_5;
                let _e76 = inThirdCircle(0.5f, 1f, _e75);
                return (((_e62 || _e66) || _e71) || _e76);
            } else {
                let _e78 = u_5;
                let _e80 = inThirds(length(_e78));
                let _e84 = u_5;
                let _e87 = inThirds(length((vec2<f32>(1f, 1f) - _e84)));
                return (_e80 || _e87);
            }
        }
    }
}

fn multiLevelTruchet(pos_4: vec2<f32>, outPos: vec2<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, distribution_4: f32, regularity_8: f32, types_size_2: i32, levels_4: i32) -> vec4<f32> {
    var pos_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var distribution_5: f32;
    var regularity_9: f32;
    var types_size_3: i32;
    var levels_5: i32;
    var ipos: vec2<f32>;
    var i_8: i32;
    var j_8: i32;
    var level_1: i32;
    var exp_1: i32;
    var local_3: i32;
    var I_1: i32;
    var local_4: i32;
    var J_1: i32;
    var type_47: i32;
    var scaling: f32;
    var negative: bool;
    var scPos: vec2<f32>;
    var relPos: vec2<f32>;
    var local_5: f32;
    var k_1: f32;
    var wing_2: i32;
    var N: i32;
    var jj: i32;
    var ii: i32;
    var local_6: f32;
    var outColor: vec4<f32>;

    pos_5 = pos_4;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    distribution_5 = distribution_4;
    regularity_9 = regularity_8;
    types_size_3 = types_size_2;
    levels_5 = levels_4;
    let _e26 = pos_5;
    ipos = floor(_e26);
    let _e29 = ipos;
    i_8 = i32(_e29.x);
    let _e33 = ipos;
    j_8 = i32(_e33.y);
    let _e37 = i_8;
    let _e38 = j_8;
    let _e39 = distribution_5;
    let _e40 = regularity_9;
    let _e41 = levels_5;
    let _e42 = getLevel(_e37, _e38, _e39, _e40, _e41);
    level_1 = _e42;
    let _e45 = level_1;
    exp_1 = i32(pow(2f, f32(_e45)));
    let _e50 = i_8;
    let _e51 = i_8;
    if (_e51 < 0i) {
        let _e54 = exp_1;
        local_3 = (_e54 - 1i);
    } else {
        local_3 = 0i;
    }
    let _e59 = local_3;
    let _e61 = exp_1;
    I_1 = ((_e50 - _e59) / _e61);
    let _e64 = j_8;
    let _e65 = j_8;
    if (_e65 < 0i) {
        let _e68 = exp_1;
        local_4 = (_e68 - 1i);
    } else {
        local_4 = 0i;
    }
    let _e73 = local_4;
    let _e75 = exp_1;
    J_1 = ((_e64 - _e73) / _e75);
    let _e78 = I_1;
    let _e79 = J_1;
    let _e80 = types_size_3;
    let _e81 = regularity_9;
    let _e82 = getType(_e78, _e79, _e80, _e81);
    type_47 = _e82;
    let _e85 = level_1;
    scaling = pow(2f, f32(_e85));
    let _e89 = level_1;
    let _e90 = level_1;
    negative = ((_e89 - ((_e90 / 2i) * 2i)) == 1i);
    let _e99 = pos_5;
    let _e100 = scaling;
    scPos = (_e99 / vec2(_e100));
    let _e104 = scPos;
    relPos = fract(_e104);
    let _e107 = relPos;
    let _e108 = type_47;
    let _e109 = truchetTile(_e107, _e108);
    if _e109 {
        local_5 = 1f;
    } else {
        local_5 = 0f;
    }
    let _e113 = local_5;
    k_1 = _e113;
    let _e115 = negative;
    if _e115 {
        let _e117 = k_1;
        k_1 = (1f - _e117);
    }
    let _e119 = level_1;
    wing_2 = _e119;
    let _e121 = level_1;
    let _e124 = relPos;
    let _e129 = relPos;
    if ((_e121 >= 1i) && (max(abs((_e124.x - 0.5f)), abs((_e129.y - 0.5f))) > 0.333333f)) {
        {
            let _e139 = level_1;
            N = i32(pow(2f, f32((_e139 - 1i))));
            let _e146 = j_8;
            let _e147 = N;
            jj = (_e146 - _e147);
            loop {
                let _e150 = jj;
                let _e151 = j_8;
                let _e152 = N;
                if !((_e150 <= (_e151 + _e152))) {
                    break;
                }
                {
                    let _e159 = i_8;
                    let _e160 = N;
                    ii = (_e159 - _e160);
                    loop {
                        let _e163 = ii;
                        let _e164 = i_8;
                        let _e165 = N;
                        if !((_e163 <= (_e164 + _e165))) {
                            break;
                        }
                        {
                            let _e172 = wing_2;
                            let _e173 = pos_5;
                            let _e174 = ii;
                            let _e175 = jj;
                            let _e176 = distribution_5;
                            let _e177 = regularity_9;
                            let _e178 = levels_5;
                            let _e179 = minWing(_e172, _e173, _e174, _e175, _e176, _e177, _e178);
                            wing_2 = _e179;
                        }
                        continuing {
                            let _e169 = ii;
                            ii = (_e169 + 1i);
                        }
                    }
                }
                continuing {
                    let _e156 = jj;
                    jj = (_e156 + 1i);
                }
            }
            let _e180 = wing_2;
            let _e181 = level_1;
            if (_e180 < _e181) {
                {
                    let _e183 = wing_2;
                    let _e184 = wing_2;
                    if ((_e183 - ((_e184 / 2i) * 2i)) == 0i) {
                        local_6 = 0f;
                    } else {
                        local_6 = 1f;
                    }
                    let _e195 = local_6;
                    k_1 = _e195;
                }
            }
        }
    }
    let _e196 = color1_1;
    let _e197 = color2_1;
    let _e198 = k_1;
    outColor = mix(_e196, _e197, vec4(_e198));
    let _e202 = source_specified_1;
    if (_e202 == 1i) {
        let _e205 = outPos_1;
        let _e209 = global.U[0];
        let _e212 = outPos_1;
        let _e221 = textureSample(t_source, samp, ((vec2<f32>((_e205.x / _e209.x), _e212.y) / vec2(2f)) + vec2(0.5f)));
        let _e222 = outColor;
        let _e223 = mergeColor(_e221, _e222);
        return _e223;
    } else {
        let _e224 = outColor;
        return _e224;
    }
}

fn main_1() {
    let _e10 = global.U[1];
    let _e11 = _e10.xyz;
    let _e14 = global.U[2];
    let _e15 = _e14.xyz;
    let _e18 = global.U[3];
    let _e19 = _e18.xyz;
    let _e34 = v_uv_1;
    let _e42 = global.U[0];
    let _e46 = (((_e34 - vec2(0.5f)) * 2f) * vec2<f32>(_e42.x, 1f));
    let _e53 = v_uv_1;
    let _e61 = global.U[0];
    let _e68 = global.U[4];
    let _e73 = global.U[6];
    let _e76 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e92 = global.U[11];
    let _e95 = multiLevelTruchet((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e11.x, _e11.y, _e11.z), vec3<f32>(_e15.x, _e15.y, _e15.z), vec3<f32>(_e19.x, _e19.y, _e19.z))) * vec3<f32>(_e46.x, _e46.y, 1f)).xy, (((_e53 - vec2(0.5f)) * 2f) * vec2<f32>(_e61.x, 1f)), i32(_e68.x), _e73, _e76, _e79.x, _e83.x, i32(_e87.x), i32(_e92.x));
    fragColor = _e95;
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
