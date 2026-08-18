struct Params {
    U: array<vec4<f32>, 22>,
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

fn getColor(d: f32, offset: f32, channel: f32) -> vec3<f32> {
    var d_1: f32;
    var offset_1: f32;
    var channel_1: f32;
    var x: f32;

    d_1 = d;
    offset_1 = offset;
    channel_1 = channel;
    let _e12 = d_1;
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn sdSegment(u_2: vec2<f32>, a: vec2<f32>, b: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_1 = a;
    b_1 = b;
    let _e12 = u_3;
    let _e13 = a_1;
    ua = (_e12 - _e13);
    let _e16 = b_1;
    let _e17 = a_1;
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

fn mandelbrotOrbits(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, mode_2: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, transformOrbit: mat3x3<f32>, color_2: vec4<f32>, offset_4: f32, colorPower_2: f32, iterations: i32, julianess: f32, power: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var mode_3: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var transformOrbit_1: mat3x3<f32>;
    var color_3: vec4<f32>;
    var offset_5: f32;
    var colorPower_3: f32;
    var iterations_1: i32;
    var julianess_1: f32;
    var power_1: f32;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var orbDist_2: vec3<f32> = vec3(100000000000000000000f);
    var tR: mat3x3<f32>;
    var tG: mat3x3<f32>;
    var tB: mat3x3<f32>;
    var modes_3: vec3<f32>;
    var uv: vec2<f32>;
    var t_4: vec2<f32>;
    var z0_: vec2<f32>;
    var z_4: vec2<f32>;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var outside: bool = true;
    var d_2: f32;
    var angle_2: f32;
    var dp: f32;
    var angle_3: f32 = 0f;
    var d_3: f32;
    var ty: f32;
    var outCol: vec4<f32>;
    var local_3: f32;
    var local_4: f32;
    var local_5: f32;
    var dd_2: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    mode_3 = mode_2;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    transformOrbit_1 = transformOrbit;
    color_3 = color_2;
    offset_5 = offset_4;
    colorPower_3 = colorPower_2;
    iterations_1 = iterations;
    julianess_1 = julianess;
    power_1 = power;
    let _e32 = julianess_1;
    cj = cos(((_e32 * 3.1415927f) * 0.5f));
    let _e39 = julianess_1;
    sj = sin(((_e39 * 3.1415927f) * 0.5f));
    let _e46 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e46);
    let _e52 = transformOrbit_1;
    tR = _naga_inverse_3x3_f32(_e52);
    let _e57 = mode_3;
    let _e58 = transformOrbit_1;
    let _e65 = getOrbitModes(_e57, _e58, (&tR), (&tG), (&tB));
    modes_3 = _e65;
    let _e67 = invModelTransform;
    let _e68 = pos_1;
    let _e69 = tf(_e67, _e68);
    uv = _e69;
    let _e71 = cj;
    let _e72 = uv;
    let _e74 = sj;
    let _e77 = offsetTransform_1[2];
    t_4 = ((_e71 * _e72) + (_e74 * _e77.xy));
    let _e82 = sj;
    let _e83 = uv;
    let _e85 = cj;
    let _e88 = offsetTransform_1[2];
    z0_ = ((_e82 * _e83) + (_e85 * _e88.xy));
    let _e93 = z0_;
    z_4 = _e93;
    let _e95 = t_4;
    prev = _e95;
    let _e103 = power_1;
    if (_e103 == 2f) {
        {
            loop {
                let _e106 = iter;
                let _e107 = iterations_1;
                if !((_e106 < _e107)) {
                    break;
                }
                {
                    let _e110 = iter;
                    iter = (_e110 + 1i);
                    let _e113 = z_4;
                    prev = _e113;
                    let _e115 = prev;
                    let _e117 = prev;
                    let _e120 = prev;
                    let _e122 = prev;
                    let _e126 = t_4;
                    z_4.x = (((_e115.x * _e117.x) - (_e120.y * _e122.y)) + _e126.x);
                    let _e131 = prev;
                    let _e134 = prev;
                    let _e137 = t_4;
                    z_4.y = (((2f * _e131.x) * _e134.y) + _e137.y);
                    let _e140 = z_4;
                    let _e141 = z_4;
                    d2_ = dot(_e140, _e141);
                    let _e144 = z_4;
                    let _e145 = tR;
                    let _e146 = tG;
                    let _e147 = tB;
                    let _e148 = modes_3;
                    threeOrbits((&orbDist_2), _e144, _e145, _e146, _e147, _e148);
                    let _e150 = d2_;
                    if (_e150 > 400000000f) {
                        {
                            outside = false;
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e154 = power_1;
        if (_e154 == 3f) {
            {
                loop {
                    let _e157 = iter;
                    let _e158 = iterations_1;
                    if !((_e157 < _e158)) {
                        break;
                    }
                    {
                        let _e161 = iter;
                        iter = (_e161 + 1i);
                        let _e164 = z_4;
                        prev = _e164;
                        let _e166 = prev;
                        let _e168 = prev;
                        let _e171 = prev;
                        let _e175 = prev;
                        let _e178 = prev;
                        let _e181 = prev;
                        let _e185 = t_4;
                        z_4.x = ((((_e166.x * _e168.x) * _e171.x) - (((3f * _e175.y) * _e178.y) * _e181.x)) + _e185.x);
                        let _e189 = prev;
                        let _e192 = prev;
                        let _e195 = prev;
                        let _e199 = prev;
                        let _e202 = prev;
                        let _e205 = prev;
                        let _e209 = t_4;
                        z_4.y = ((((-(_e189.y) * _e192.y) * _e195.y) + (((3f * _e199.x) * _e202.x) * _e205.y)) + _e209.y);
                        let _e212 = z_4;
                        let _e213 = z_4;
                        d2_ = dot(_e212, _e213);
                        let _e216 = z_4;
                        let _e217 = tR;
                        let _e218 = tG;
                        let _e219 = tB;
                        let _e220 = modes_3;
                        threeOrbits((&orbDist_2), _e216, _e217, _e218, _e219, _e220);
                        let _e222 = d2_;
                        if (_e222 > 400000000f) {
                            {
                                outside = false;
                                break;
                            }
                        }
                    }
                }
            }
        } else {
            {
                let _e226 = z_4;
                d_2 = length(_e226);
                loop {
                    let _e229 = iter;
                    let _e230 = iterations_1;
                    if !((_e229 < _e230)) {
                        break;
                    }
                    {
                        let _e233 = iter;
                        iter = (_e233 + 1i);
                        let _e236 = z_4;
                        prev = _e236;
                        let _e237 = prev;
                        let _e239 = prev;
                        angle_2 = atan2(_e237.y, _e239.x);
                        let _e243 = d_2;
                        let _e244 = power_1;
                        dp = pow(_e243, _e244);
                        let _e248 = dp;
                        let _e249 = power_1;
                        let _e250 = angle_2;
                        let _e254 = t_4;
                        z_4.x = ((_e248 * cos((_e249 * _e250))) + _e254.x);
                        let _e258 = dp;
                        let _e259 = power_1;
                        let _e260 = angle_2;
                        let _e264 = t_4;
                        z_4.y = ((_e258 * sin((_e259 * _e260))) + _e264.y);
                        let _e268 = z_4;
                        let _e269 = tR;
                        let _e270 = tG;
                        let _e271 = tB;
                        let _e272 = modes_3;
                        threeOrbits((&orbDist_2), _e268, _e269, _e270, _e271, _e272);
                        let _e274 = z_4;
                        d_2 = length(_e274);
                        let _e276 = d_2;
                        if (_e276 > 20000f) {
                            {
                                outside = false;
                                break;
                            }
                        }
                    }
                }
                let _e280 = d_2;
                let _e281 = d_2;
                d2_ = (_e280 * _e281);
            }
        }
    }
    let _e285 = d2_;
    d_3 = sqrt(_e285);
    let _e289 = iter;
    let _e292 = d_3;
    let _e295 = power_1;
    ty = ((1f + f32(_e289)) - (log(log(_e292)) / log(_e295)));
    let _e301 = source_specified_1;
    if (_e301 == 1i) {
        {
            let _e304 = offset_5;
            let _e305 = orbDist_2;
            if (_e305.x >= 0f) {
                let _e309 = orbDist_2;
                let _e311 = colorPower_3;
                local_3 = pow(_e309.x, _e311);
            } else {
                local_3 = 100000000000000000000f;
            }
            let _e315 = local_3;
            let _e316 = orbDist_2;
            if (_e316.y >= 0f) {
                let _e320 = orbDist_2;
                let _e322 = colorPower_3;
                local_4 = pow(_e320.y, _e322);
            } else {
                local_4 = 100000000000000000000f;
            }
            let _e326 = local_4;
            let _e328 = orbDist_2;
            let _e330 = colorPower_3;
            if (pow(_e328.z, _e330) >= 0f) {
                let _e334 = orbDist_2;
                local_5 = _e334.z;
            } else {
                local_5 = 100000000000000000000f;
            }
            let _e338 = local_5;
            dd_2 = (_e304 + min(min(_e315, _e326), _e338));
            let _e342 = dd_2;
            let _e346 = dd_2;
            let _e354 = global.U[0];
            let _e357 = dd_2;
            let _e361 = dd_2;
            let _e374 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(sin((_e342 * 3.333f)), cos((_e346 * 4.3434f))).x / _e354.x), vec2<f32>(sin((_e357 * 3.333f)), cos((_e361 * 4.3434f))).y) / vec2(2f)) + vec2(0.5f)));
            outCol = _e374;
        }
    } else {
        {
            let _e375 = orbDist_2;
            let _e376 = colorPower_3;
            let _e377 = offset_5;
            let _e378 = color_3;
            let _e379 = getCombinedColor(_e375, _e376, _e377, _e378);
            outCol = _e379;
        }
    }
    let _e380 = outCol;
    return _e380;
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
    let _e102 = _e101.xyz;
    let _e105 = global.U[11];
    let _e106 = _e105.xyz;
    let _e109 = global.U[12];
    let _e110 = _e109.xyz;
    let _e126 = global.U[13];
    let _e127 = _e126.xyz;
    let _e130 = global.U[14];
    let _e131 = _e130.xyz;
    let _e134 = global.U[15];
    let _e135 = _e134.xyz;
    let _e151 = global.U[16];
    let _e154 = global.U[17];
    let _e158 = global.U[18];
    let _e162 = global.U[19];
    let _e167 = global.U[20];
    let _e171 = global.U[21];
    let _e173 = mandelbrotOrbits((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), mat3x3<f32>(vec3<f32>(_e77.x, _e77.y, _e77.z), vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z)), mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)), mat3x3<f32>(vec3<f32>(_e127.x, _e127.y, _e127.z), vec3<f32>(_e131.x, _e131.y, _e131.z), vec3<f32>(_e135.x, _e135.y, _e135.z)), _e151, _e154.x, _e158.x, i32(_e162.x), _e167.x, _e171.x);
    fragColor = _e173;
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
