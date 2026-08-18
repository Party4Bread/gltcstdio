struct Params {
    U: array<vec4<f32>, 18>,
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

fn complexExp(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e11 = u_1;
    let _e14 = u_1;
    return (exp(_e8.x) * vec2<f32>(cos(_e11.y), sin(_e14.y)));
}

fn complexMul(u_2: vec2<f32>, v: vec2<f32>) -> vec2<f32> {
    var u_3: vec2<f32>;
    var v_1: vec2<f32>;

    u_3 = u_2;
    v_1 = v;
    let _e10 = u_3;
    let _e12 = v_1;
    let _e15 = u_3;
    let _e17 = v_1;
    let _e21 = u_3;
    let _e22 = v_1;
    return vec2<f32>(((_e10.x * _e12.x) - (_e15.y * _e17.y)), dot(_e21, _e22.yx));
}

fn collatz(u_4: vec2<f32>, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32, g: f32) -> vec2<f32> {
    var u_5: vec2<f32>;
    var a_1: f32;
    var b_1: f32;
    var c_1: f32;
    var d_1: f32;
    var e_1: f32;
    var f_1: f32;
    var g_1: f32;

    u_5 = u_4;
    a_1 = a;
    b_1 = b;
    c_1 = c;
    d_1 = d;
    e_1 = e;
    f_1 = f;
    g_1 = g;
    let _e22 = a_1;
    let _e23 = u_5;
    let _e25 = b_1;
    let _e28 = c_1;
    let _e29 = u_5;
    let _e31 = d_1;
    let _e34 = e_1;
    let _e35 = u_5;
    let _e38 = f_1;
    let _e39 = u_5;
    let _e43 = complexExp(vec2<f32>((_e34 * _e35.y), (_e38 * _e39.x)));
    let _e44 = complexMul(((_e28 * _e29) + vec2(_e31)), _e43);
    let _e46 = g_1;
    return ((((_e22 * _e23) + vec2(_e25)) - _e44) * _e46);
}

fn getColor(d_2: f32, offset: f32, channel: f32) -> vec3<f32> {
    var d_3: f32;
    var offset_1: f32;
    var channel_1: f32;
    var x: f32;

    d_3 = d_2;
    offset_1 = offset;
    channel_1 = channel;
    let _e12 = d_3;
    let _e13 = offset_1;
    let _e15 = channel_1;
    let _e20 = (((_e12 + _e13) + (_e15 * 6.2831855f)) + 3.1415927f);
    x = (_e20 - (floor((_e20 / 18.849556f)) * 18.849556f));
    let _e29 = x;
    if (_e29 < 6.2831855f) {
        let _e34 = x;
        return vec3<f32>(((-0.5f * cos(_e34)) + 0.5f), 0f, 0f);
    } else {
        let _e42 = x;
        if (_e42 < 12.566371f) {
            let _e48 = x;
            return vec3<f32>(0f, ((-0.5f * cos((_e48 - 6.2831855f))) + 0.5f), 0f);
        } else {
            let _e61 = x;
            return vec3<f32>(0f, 0f, ((-0.5f * cos((_e61 - 12.566371f))) + 0.5f));
        }
    }
}

fn getCombinedColor(orbDist: vec3<f32>, colorPower: f32, offset_2: f32, color: vec4<f32>) -> vec4<f32> {
    var orbDist_1: vec3<f32>;
    var colorPower_1: f32;
    var offset_3: f32;
    var color_1: vec4<f32>;
    var dd: f32;
    var k: f32;
    var rndCol: vec3<f32>;
    var baseCol: vec3<f32>;
    var dd_1: f32;
    var dd2_: f32;
    var k_1: f32;
    var col1_: vec3<f32>;
    var col2_: vec3<f32>;
    var local: vec3<f32>;
    var col1_1: vec3<f32>;
    var local_1: vec3<f32>;
    var col2_1: vec3<f32>;
    var local_2: vec3<f32>;
    var col3_: vec3<f32>;
    var similarity: f32;
    var rgb: vec3<f32>;

    orbDist_1 = orbDist;
    colorPower_1 = colorPower;
    offset_3 = offset_2;
    color_1 = color;
    let _e14 = orbDist_1;
    let _e18 = orbDist_1;
    if ((_e14.y < 0f) && (_e18.z < 0f)) {
        {
            let _e23 = orbDist_1;
            let _e25 = colorPower_1;
            let _e27 = offset_3;
            dd = (pow(_e23.x, _e25) + _e27);
            let _e32 = dd;
            k = (0.5f + (0.5f * cos(_e32)));
            let _e37 = dd;
            let _e41 = dd;
            let _e45 = dd;
            rndCol = vec3<f32>(sin((_e37 * 3.333f)), sin((_e41 * 4.3434f)), sin((_e45 * 3.88434f)));
            let _e51 = color_1;
            baseCol = _e51.xyz;
            let _e54 = rndCol;
            let _e55 = baseCol;
            let _e56 = k;
            let _e58 = mix(_e54, _e55, vec3(_e56));
            let _e59 = color_1;
            return vec4<f32>(_e58.x, _e58.y, _e58.z, _e59.w);
        }
    } else {
        let _e65 = orbDist_1;
        if (_e65.z < 0f) {
            {
                let _e69 = orbDist_1;
                let _e71 = colorPower_1;
                let _e73 = offset_3;
                dd_1 = (pow(_e69.x, _e71) + _e73);
                let _e76 = orbDist_1;
                let _e78 = colorPower_1;
                let _e80 = offset_3;
                dd2_ = (pow(_e76.y, _e78) + _e80);
                let _e85 = dd2_;
                k_1 = (0.5f + (0.5f * cos(_e85)));
                let _e90 = color_1;
                col1_ = _e90.xyz;
                let _e93 = dd_1;
                let _e97 = dd_1;
                let _e101 = dd_1;
                col2_ = vec3<f32>(sin((_e93 * 3.333f)), sin((_e97 * 4.3434f)), sin((_e101 * 3.88434f)));
                let _e107 = col2_;
                let _e108 = col1_;
                let _e109 = k_1;
                let _e111 = mix(_e107, _e108, vec3(_e109));
                let _e112 = color_1;
                return vec4<f32>(_e111.x, _e111.y, _e111.z, _e112.w);
            }
        } else {
            {
                let _e118 = orbDist_1;
                if (_e118.x >= 0f) {
                    let _e122 = orbDist_1;
                    let _e124 = colorPower_1;
                    let _e126 = offset_3;
                    let _e128 = getColor(pow(_e122.x, _e124), _e126, 0f);
                    local = _e128;
                } else {
                    local = vec3(0f);
                }
                let _e132 = local;
                col1_1 = _e132;
                let _e134 = orbDist_1;
                if (_e134.y >= 0f) {
                    let _e138 = orbDist_1;
                    let _e140 = colorPower_1;
                    let _e142 = offset_3;
                    let _e144 = getColor(pow(_e138.y, _e140), _e142, 1f);
                    local_1 = _e144;
                } else {
                    local_1 = vec3(0f);
                }
                let _e148 = local_1;
                col2_1 = _e148;
                let _e150 = orbDist_1;
                if (_e150.z >= 0f) {
                    let _e154 = orbDist_1;
                    let _e156 = colorPower_1;
                    let _e158 = offset_3;
                    let _e160 = getColor(pow(_e154.z, _e156), _e158, 2f);
                    local_2 = _e160;
                } else {
                    local_2 = vec3(0f);
                }
                let _e164 = local_2;
                col3_ = _e164;
                let _e166 = col1_1;
                let _e167 = col2_1;
                let _e169 = col2_1;
                let _e170 = col3_;
                let _e173 = col3_;
                let _e174 = col1_1;
                similarity = (((dot(_e166, _e167) + dot(_e169, _e170)) + dot(_e173, _e174)) / 3f);
                let _e180 = col1_1;
                let _e181 = col2_1;
                let _e183 = col3_;
                let _e185 = color_1;
                let _e190 = col1_1;
                let _e191 = col2_1;
                let _e193 = col3_;
                let _e195 = similarity;
                rgb = mix(((((_e180 + _e181) + _e183) * _e185.xyz) * 2f), ((_e190 + _e191) + _e193), vec3(_e195));
                let _e199 = rgb;
                let _e200 = color_1;
                return vec4<f32>(_e199.x, _e199.y, _e199.z, _e200.w);
            }
        }
    }
}

fn rotation3_(angle: f32) -> mat3x3<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e17 = sa;
    let _e19 = ca;
    return mat3x3<f32>(vec3<f32>(_e14, _e15, 0f), vec3<f32>(-(_e17), _e19, 0f), vec3<f32>(0f, 0f, 1f));
}

fn scaling3_(s: f32) -> mat3x3<f32> {
    var s_1: f32;

    s_1 = s;
    let _e8 = s_1;
    let _e12 = s_1;
    return mat3x3<f32>(vec3<f32>(_e8, 0f, 0f), vec3<f32>(0f, _e12, 0f), vec3<f32>(0f, 0f, 1f));
}

fn translation3_(t: vec2<f32>) -> mat3x3<f32> {
    var t_1: vec2<f32>;

    t_1 = t;
    let _e14 = t_1;
    let _e16 = t_1;
    return mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e14.x, _e16.y, 1f));
}

fn getOrbitModes(mode: i32, t0_: mat3x3<f32>, t1_: ptr<function, mat3x3<f32>>, t2_: ptr<function, mat3x3<f32>>, t3_: ptr<function, mat3x3<f32>>) -> vec3<f32> {
    var mode_1: i32;
    var t0_1: mat3x3<f32>;
    var modes: vec3<f32> = vec3<f32>(0f, -1f, -1f);
    var baseMode: f32;
    var subMode: i32;

    mode_1 = mode;
    t0_1 = t0_;
    let _e20 = t0_1;
    (*t1_) = _naga_inverse_3x3_f32(_e20);
    let _e22 = mode_1;
    baseMode = f32((_e22 / 10i));
    let _e27 = mode_1;
    subMode = (_e27 % 10i);
    let _e31 = baseMode;
    if (_e31 <= 5f) {
        {
            let _e35 = baseMode;
            modes.x = _e35;
            let _e36 = subMode;
            if (_e36 == 1i) {
                {
                    let _e40 = baseMode;
                    modes.y = _e40;
                    let _e42 = rotation3_(3.1415927f);
                    let _e43 = t0_1;
                    (*t2_) = _naga_inverse_3x3_f32((_e42 * _e43));
                }
            } else {
                let _e46 = subMode;
                if (_e46 == 2i) {
                    {
                        let _e50 = baseMode;
                        modes.y = _e50;
                        let _e54 = translation3_(vec2<f32>(0.5f, 0f));
                        let _e55 = t0_1;
                        (*t2_) = _naga_inverse_3x3_f32((_e54 * _e55));
                    }
                } else {
                    let _e58 = subMode;
                    if (_e58 == 3i) {
                        {
                            let _e62 = baseMode;
                            modes.y = _e62;
                            let _e66 = translation3_(vec2<f32>(1f, 0f));
                            let _e67 = t0_1;
                            (*t2_) = _naga_inverse_3x3_f32((_e66 * _e67));
                        }
                    } else {
                        {
                            let _e71 = baseMode;
                            modes.y = _e71;
                            let _e73 = baseMode;
                            modes.z = _e73;
                            let _e74 = subMode;
                            if (_e74 == 4i) {
                                {
                                    let _e80 = rotation3_(1.0471976f);
                                    let _e81 = t0_1;
                                    (*t2_) = _naga_inverse_3x3_f32((_e80 * _e81));
                                    let _e87 = rotation3_(2.0943952f);
                                    let _e88 = t0_1;
                                    (*t3_) = _naga_inverse_3x3_f32((_e87 * _e88));
                                }
                            } else {
                                let _e91 = subMode;
                                if (_e91 == 5i) {
                                    {
                                        let _e95 = scaling3_(1.5f);
                                        let _e96 = t0_1;
                                        (*t2_) = _naga_inverse_3x3_f32((_e95 * _e96));
                                        let _e100 = scaling3_(2.25f);
                                        let _e101 = t0_1;
                                        (*t3_) = _naga_inverse_3x3_f32((_e100 * _e101));
                                    }
                                } else {
                                    let _e104 = subMode;
                                    if (_e104 == 6i) {
                                        {
                                            let _e110 = translation3_(vec2<f32>(0f, 2f));
                                            let _e111 = t0_1;
                                            (*t2_) = _naga_inverse_3x3_f32((_e110 * _e111));
                                            let _e118 = translation3_(vec2<f32>(0f, -2f));
                                            let _e119 = t0_1;
                                            (*t3_) = _naga_inverse_3x3_f32((_e118 * _e119));
                                        }
                                    } else {
                                        let _e122 = subMode;
                                        if (_e122 == 7i) {
                                            {
                                                let _e135 = translation3_(vec2<f32>(-0.21650635f, -0.25f));
                                                let _e136 = t0_1;
                                                (*t2_) = _naga_inverse_3x3_f32((_e135 * _e136));
                                                let _e148 = translation3_(vec2<f32>(-0.21650635f, 0.25f));
                                                let _e149 = t0_1;
                                                (*t3_) = _naga_inverse_3x3_f32((_e148 * _e149));
                                            }
                                        } else {
                                            let _e152 = subMode;
                                            if (_e152 == 8i) {
                                                {
                                                    let _e165 = translation3_(vec2<f32>(-0.4330127f, -0.5f));
                                                    let _e166 = t0_1;
                                                    (*t2_) = _naga_inverse_3x3_f32((_e165 * _e166));
                                                    let _e178 = translation3_(vec2<f32>(-0.4330127f, 0.5f));
                                                    let _e179 = t0_1;
                                                    (*t3_) = _naga_inverse_3x3_f32((_e178 * _e179));
                                                }
                                            } else {
                                                let _e182 = subMode;
                                                if (_e182 == 9i) {
                                                    {
                                                        let _e186 = scaling3_(1.5f);
                                                        let _e197 = translation3_(vec2<f32>(-0.8660254f, -1f));
                                                        let _e199 = t0_1;
                                                        (*t2_) = _naga_inverse_3x3_f32(((_e186 * _e197) * _e199));
                                                        let _e203 = scaling3_(2.25f);
                                                        let _e213 = translation3_(vec2<f32>(-0.4330127f, 0.5f));
                                                        let _e215 = t0_1;
                                                        (*t3_) = _naga_inverse_3x3_f32(((_e203 * _e213) * _e215));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } else {
        let _e218 = mode_1;
        if (_e218 == 60i) {
            {
                modes.x = 0f;
                modes.y = 2f;
                let _e226 = rotation3_(3.1415927f);
                let _e227 = t0_1;
                (*t2_) = _naga_inverse_3x3_f32((_e226 * _e227));
            }
        } else {
            let _e230 = mode_1;
            if (_e230 == 61i) {
                {
                    modes.x = 0f;
                    modes.y = 1f;
                    let _e238 = rotation3_(3.1415927f);
                    let _e239 = t0_1;
                    (*t2_) = _naga_inverse_3x3_f32((_e238 * _e239));
                }
            } else {
                let _e242 = mode_1;
                if (_e242 == 62i) {
                    {
                        modes.x = 0f;
                        modes.y = 5f;
                        let _e252 = translation3_(vec2<f32>(2f, 0f));
                        let _e253 = t0_1;
                        (*t2_) = _naga_inverse_3x3_f32((_e252 * _e253));
                    }
                } else {
                    let _e256 = mode_1;
                    if (_e256 == 63i) {
                        {
                            modes.x = 0f;
                            modes.y = 1f;
                            let _e266 = translation3_(vec2<f32>(2f, 0f));
                            let _e267 = t0_1;
                            (*t2_) = _naga_inverse_3x3_f32((_e266 * _e267));
                        }
                    }
                }
            }
        }
    }
    let _e270 = modes;
    return _e270;
}

fn tf(m: mat3x3<f32>, u_6: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_7: vec2<f32>;

    m_1 = m;
    u_7 = u_6;
    let _e10 = m_1;
    let _e11 = u_7;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn sdSegment(u_8: vec2<f32>, a_2: vec2<f32>, b_2: vec2<f32>) -> f32 {
    var u_9: vec2<f32>;
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_9 = u_8;
    a_3 = a_2;
    b_3 = b_2;
    let _e12 = u_9;
    let _e13 = a_3;
    ua = (_e12 - _e13);
    let _e16 = b_3;
    let _e17 = a_3;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn orbit(z: vec2<f32>, t_2: mat3x3<f32>, type_46: i32) -> f32 {
    var z_1: vec2<f32>;
    var t_3: mat3x3<f32>;
    var type_47: i32;
    var tz: vec2<f32>;

    z_1 = z;
    t_3 = t_2;
    type_47 = type_46;
    let _e12 = t_3;
    let _e13 = z_1;
    let _e14 = tf(_e12, _e13);
    tz = _e14;
    let _e16 = type_47;
    if (_e16 == 0i) {
        let _e19 = tz;
        return length(_e19);
    } else {
        let _e21 = type_47;
        if (_e21 == 1i) {
            let _e24 = tz;
            return abs((length(_e24) - 5f));
        } else {
            let _e29 = type_47;
            if (_e29 == 2i) {
                let _e32 = tz;
                return abs(_e32.y);
            } else {
                let _e35 = type_47;
                if (_e35 == 3i) {
                    let _e38 = tz;
                    let _e41 = tz;
                    return abs((max(abs(_e38.x), abs(_e41.y)) - 5f));
                } else {
                    let _e48 = type_47;
                    if (_e48 == 4i) {
                        let _e51 = tz;
                        let _e59 = sdSegment(_e51, vec2<f32>(-8f, 0f), vec2<f32>(8f, 0f));
                        return _e59;
                    } else {
                        let _e60 = type_47;
                        if (_e60 == 5i) {
                            let _e63 = tz;
                            return (length((fract(_e63) - vec2(0.5f))) * 5f);
                        } else {
                            return -1f;
                        }
                    }
                }
            }
        }
    }
}

fn threeOrbits(dist: ptr<function, vec3<f32>>, z_2: vec2<f32>, t1_1: mat3x3<f32>, t2_1: mat3x3<f32>, t3_1: mat3x3<f32>, modes_1: vec3<f32>) {
    var z_3: vec2<f32>;
    var t1_2: mat3x3<f32>;
    var t2_2: mat3x3<f32>;
    var t3_2: mat3x3<f32>;
    var modes_2: vec3<f32>;

    z_3 = z_2;
    t1_2 = t1_1;
    t2_2 = t2_1;
    t3_2 = t3_1;
    modes_2 = modes_1;
    let _e18 = (*dist);
    let _e20 = z_3;
    let _e21 = t1_2;
    let _e22 = modes_2;
    let _e25 = orbit(_e20, _e21, i32(_e22.x));
    (*dist).x = min(_e18.x, _e25);
    let _e28 = (*dist);
    let _e30 = z_3;
    let _e31 = t2_2;
    let _e32 = modes_2;
    let _e35 = orbit(_e30, _e31, i32(_e32.y));
    (*dist).y = min(_e28.y, _e35);
    let _e38 = (*dist);
    let _e40 = z_3;
    let _e41 = t3_2;
    let _e42 = modes_2;
    let _e45 = orbit(_e40, _e41, i32(_e42.z));
    (*dist).z = min(_e38.z, _e45);
    return;
}

fn collatzOrbits(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, mode_2: i32, transformOrbit: mat3x3<f32>, color_2: vec4<f32>, offset_4: f32, colorPower_2: f32, modelTransform: mat3x3<f32>, iterations: i32, seed: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var mode_3: i32;
    var transformOrbit_1: mat3x3<f32>;
    var color_3: vec4<f32>;
    var offset_5: f32;
    var colorPower_3: f32;
    var modelTransform_1: mat3x3<f32>;
    var iterations_1: i32;
    var seed_1: f32;
    var invModelTransform: mat3x3<f32>;
    var uv: vec2<f32>;
    var orbDist_2: vec3<f32> = vec3(100000000000000000000f);
    var tR: mat3x3<f32>;
    var tG: mat3x3<f32>;
    var tB: mat3x3<f32>;
    var modes_3: vec3<f32>;
    var dist_1: f32 = 100000000000000000000f;
    var pa: f32;
    var pb: f32;
    var pc: f32;
    var pd: f32;
    var pe: f32;
    var pf: f32;
    var pg: f32;
    var s1_: vec2<f32>;
    var c1_: vec2<f32> = vec2<f32>(20f, 0f);
    var g_2: f32 = 0.36787945f;
    var i: i32 = 0i;
    var outCol: vec4<f32>;
    var local_3: f32;
    var local_4: f32;
    var local_5: f32;
    var dd_2: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    mode_3 = mode_2;
    transformOrbit_1 = transformOrbit;
    color_3 = color_2;
    offset_5 = offset_4;
    colorPower_3 = colorPower_2;
    modelTransform_1 = modelTransform;
    iterations_1 = iterations;
    seed_1 = seed;
    let _e28 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e28);
    let _e31 = invModelTransform;
    let _e32 = pos_1;
    let _e33 = tf(_e31, _e32);
    uv = _e33;
    let _e38 = transformOrbit_1;
    tR = _naga_inverse_3x3_f32(_e38);
    let _e43 = mode_3;
    let _e44 = transformOrbit_1;
    let _e51 = getOrbitModes(_e43, _e44, (&tR), (&tG), (&tB));
    modes_3 = _e51;
    let _e57 = seed_1;
    pa = (1f + (6f * sin((_e57 * 3f))));
    let _e66 = seed_1;
    pb = (2f + (1.5f * sin((_e66 * 5.343f))));
    let _e75 = seed_1;
    pc = (1f + (4f * sin((_e75 * 7.431f))));
    let _e84 = seed_1;
    pd = (2f + (1.5f * sin((_e84 * 9.111f))));
    let _e94 = seed_1;
    pe = (-3.1415927f + (0.5f * sin((_e94 * 11.003f))));
    let _e103 = seed_1;
    pf = (3.1415927f + (0.5f * sin((_e103 * 13.884f))));
    let _e112 = seed_1;
    pg = (0.25f + (0.15f * sin((_e112 * 15.343f))));
    let _e119 = seed_1;
    let _e121 = seed_1;
    s1_ = vec2<f32>(cos(_e119), sin(_e121));
    loop {
        let _e135 = i;
        let _e136 = iterations_1;
        if !((_e135 < _e136)) {
            break;
        }
        {
            let _e142 = uv;
            let _e143 = pa;
            let _e144 = pb;
            let _e145 = pc;
            let _e146 = pd;
            let _e147 = pe;
            let _e148 = pf;
            let _e149 = pg;
            let _e150 = collatz(_e142, _e143, _e144, _e145, _e146, _e147, _e148, _e149);
            uv = _e150;
            let _e152 = uv;
            let _e153 = tR;
            let _e154 = tG;
            let _e155 = tB;
            let _e156 = modes_3;
            threeOrbits((&orbDist_2), _e152, _e153, _e154, _e155, _e156);
            let _e158 = dist_1;
            let _e160 = uv;
            let _e161 = s1_;
            dist_1 = min(_e158, (5f * abs(dot(_e160, _e161))));
            let _e166 = dist_1;
            let _e167 = uv;
            let _e168 = c1_;
            dist_1 = min(_e166, length((_e167 - _e168)));
        }
        continuing {
            let _e139 = i;
            i = (_e139 + 1i);
        }
    }
    let _e173 = dist_1;
    g_2 = ((1f - (_e173 * 0.05f)) * 1f);
    let _e180 = source_specified_1;
    if (_e180 == 1i) {
        {
            let _e183 = offset_5;
            let _e184 = orbDist_2;
            if (_e184.x >= 0f) {
                let _e188 = orbDist_2;
                let _e190 = colorPower_3;
                local_3 = pow(_e188.x, _e190);
            } else {
                local_3 = 100000000000000000000f;
            }
            let _e194 = local_3;
            let _e195 = orbDist_2;
            if (_e195.y >= 0f) {
                let _e199 = orbDist_2;
                let _e201 = colorPower_3;
                local_4 = pow(_e199.y, _e201);
            } else {
                local_4 = 100000000000000000000f;
            }
            let _e205 = local_4;
            let _e207 = orbDist_2;
            let _e209 = colorPower_3;
            if (pow(_e207.z, _e209) >= 0f) {
                let _e213 = orbDist_2;
                local_5 = _e213.z;
            } else {
                local_5 = 100000000000000000000f;
            }
            let _e217 = local_5;
            dd_2 = (_e183 + min(min(_e194, _e205), _e217));
            let _e221 = dd_2;
            let _e225 = dd_2;
            let _e233 = global.U[0];
            let _e236 = dd_2;
            let _e240 = dd_2;
            let _e253 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(sin((_e221 * 3.333f)), cos((_e225 * 4.3434f))).x / _e233.x), vec2<f32>(sin((_e236 * 3.333f)), cos((_e240 * 4.3434f))).y) / vec2(2f)) + vec2(0.5f)));
            outCol = _e253;
        }
    } else {
        {
            let _e254 = orbDist_2;
            let _e255 = colorPower_3;
            let _e256 = offset_5;
            let _e257 = color_3;
            let _e258 = getCombinedColor(_e254, _e255, _e256, _e257);
            outCol = _e258;
        }
    }
    let _e259 = g_2;
    let _e260 = g_2;
    let _e261 = g_2;
    let _e264 = outCol;
    return (vec4<f32>(_e259, _e260, _e261, 1f) * _e264);
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
    let _e71 = global.U[6];
    let _e76 = global.U[7];
    let _e77 = _e76.xyz;
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e101 = global.U[10];
    let _e104 = global.U[11];
    let _e108 = global.U[12];
    let _e112 = global.U[13];
    let _e113 = _e112.xyz;
    let _e116 = global.U[14];
    let _e117 = _e116.xyz;
    let _e120 = global.U[15];
    let _e121 = _e120.xyz;
    let _e137 = global.U[16];
    let _e142 = global.U[17];
    let _e144 = collatzOrbits((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), _e101, _e104.x, _e108.x, mat3x3<f32>(vec3<f32>(_e113.x, _e113.y, _e113.z), vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e121.x, _e121.y, _e121.z)), i32(_e137.x), _e142.x);
    fragColor = _e144;
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
