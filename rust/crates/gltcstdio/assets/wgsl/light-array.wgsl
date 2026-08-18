struct Params {
    U: array<vec4<f32>, 20>,
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

fn hash33_(u: vec3<f32>) -> vec3<f32> {
    var u_1: vec3<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e17 = u_1;
    let _e26 = u_1;
    let _e30 = u_1;
    let _e35 = u_1;
    let _e44 = u_1;
    let _e48 = u_1;
    let _e53 = u_1;
    return vec3<f32>(fract((sin((((_e8.x * 776.45f) + (_e12.y * 453.24f)) + (_e17.z * 553.25f))) * 45.77f)), fract((sin((((_e26.x * 376.45f) + (_e30.y * 853.24f)) + (_e35.z * 153.84f))) * 88.77f)), fract((sin((((_e44.x * 457.77f) + (_e48.y * 667.17f)) + (_e53.z * 355.94f))) * 65.57f)));
}

fn getColor1_(pos: vec3<f32>) -> vec4<f32> {
    var pos_1: vec3<f32>;
    var v: vec3<f32>;
    var w: vec3<f32>;

    pos_1 = pos;
    let _e9 = pos_1;
    pos_1.y = -(_e9.y);
    let _e12 = pos_1;
    let _e16 = pos_1;
    if ((_e12.y < 0f) || (_e16.y > 9f)) {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
    let _e25 = pos_1;
    let _e27 = vec3(10f);
    v = (_e25 - (floor((_e25 / _e27)) * _e27));
    let _e33 = v;
    let _e35 = v;
    let _e38 = v;
    if (((_e33.x * _e35.y) + _e38.z) == 0f) {
        return vec4<f32>(7f, 7f, 7f, 0f);
    }
    let _e53 = v;
    let _e55 = v;
    let _e57 = v;
    if ((_e53.x + (_e55.y * _e57.z)) == 12f) {
        let _e63 = pos_1;
        let _e64 = hash33_(_e63);
        let _e66 = (_e64 * 15f);
        return vec4<f32>(_e66.x, _e66.y, _e66.z, 0f);
    }
    let _e72 = v;
    let _e74 = v;
    let _e77 = v;
    if (((_e72.x * _e74.y) + _e77.z) == 5f) {
        return vec4<f32>(7f, 7f, 7f, 0f);
    }
    let _e92 = pos_1;
    let _e94 = (_e92 * 4.1f);
    let _e96 = vec3(10f);
    w = (_e94 - (floor((_e94 / _e96)) * _e96));
    let _e102 = w;
    let _e106 = w;
    let _e111 = w;
    if (((_e102.x < 1f) && (_e106.y < 1f)) && (_e111.z < 1f)) {
        let _e116 = pos_1;
        let _e117 = hash33_(_e116);
        let _e119 = (_e117 * 15f);
        return vec4<f32>(_e119.x, _e119.y, _e119.z, 0f);
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColor2_(pos_2: vec3<f32>) -> vec4<f32> {
    var pos_3: vec3<f32>;

    pos_3 = pos_2;
    let _e8 = pos_3;
    let _e9 = hash33_(_e8);
    let _e11 = (_e9 * 2f);
    return vec4<f32>(_e11.x, _e11.y, _e11.z, 0f);
}

fn getColor2b(pos_4: vec3<f32>) -> vec4<f32> {
    var pos_5: vec3<f32>;
    var rnd: vec3<f32>;

    pos_5 = pos_4;
    let _e8 = pos_5;
    let _e9 = hash33_(_e8);
    rnd = _e9;
    let _e11 = rnd;
    if (fract((_e11.x * 12.55f)) > 0.2f) {
        return vec4(0f);
    }
    let _e20 = rnd;
    let _e22 = (_e20 * 5f);
    return vec4<f32>(_e22.x, _e22.y, _e22.z, 0f);
}

fn getColor3b(pos_6: vec3<f32>, N: f32) -> vec4<f32> {
    var pos_7: vec3<f32>;
    var N_1: f32;
    var rgb: vec3<f32>;

    pos_7 = pos_6;
    N_1 = N;
    let _e10 = pos_7;
    rgb = _e10.xyz;
    let _e13 = rgb;
    let _e14 = N_1;
    let _e15 = vec3(_e14);
    let _e22 = N_1;
    let _e24 = (((_e13 - (floor((_e13 / _e15)) * _e15)) * 2.5f) / vec3(_e22));
    return vec4<f32>(_e24.x, _e24.y, _e24.z, 0f);
}

fn hash21_(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_1 = p;
    let _e10 = p_1;
    a = fract((-45.3277f * _e10.xy));
    let _e15 = a;
    let _e16 = a;
    let _e17 = a;
    b = (_e15 + vec2(dot(_e16, (_e17 + vec2(123.3371f)))));
    let _e25 = b;
    let _e27 = b;
    return fract((_e25.x * _e27.y));
}

fn hash31_(u_2: vec3<f32>) -> f32 {
    var u_3: vec3<f32>;

    u_3 = u_2;
    let _e8 = u_3;
    let _e12 = u_3;
    let _e17 = u_3;
    return fract((sin((((_e8.x * 776.45f) + (_e12.y * 453.24f)) + (_e17.z * 553.25f))) * 45.77f));
}

fn getColor6_(pos_8: vec3<f32>) -> vec4<f32> {
    var pos_9: vec3<f32>;
    var xRoad: f32;
    var roadLightH: f32 = 1f;
    var rnd_1: f32;
    var xz: vec2<f32>;
    var rnd_2: f32;
    var h: f32;
    var rnd2_: vec3<f32>;
    var k: f32;
    var local: vec3<f32>;
    var local_1: vec3<f32>;
    var local_2: vec3<f32>;
    var baseWindowColor: vec3<f32>;
    var rnd_3: f32;
    var rnd_4: vec3<f32>;

    pos_9 = pos_8;
    let _e9 = pos_9;
    pos_9.y = -(_e9.y);
    let _e12 = pos_9;
    xRoad = (_e12.x - (floor((_e12.x / 15f)) * 15f));
    let _e22 = pos_9;
    if (_e22.z == 1f) {
        {
            let _e26 = pos_9;
            let _e30 = pos_9;
            if ((_e26.y == 1f) && ((_e30.x - (floor((_e30.x / 4f)) * 4f)) == 2f)) {
                return vec4<f32>(2f, 2f, 2f, 0f);
            }
        }
    }
    let _e52 = pos_9;
    if (_e52.z == 2f) {
        {
            let _e56 = pos_9;
            let _e60 = pos_9;
            let _e65 = pos_9;
            if (((_e56.y >= 0f) && (_e60.y <= 3f)) && ((_e65.x - (floor((_e65.x / 7f)) * 7f)) == 3f)) {
                return vec4<f32>(1.84f, 2.07f, 2.3f, 0f);
            }
        }
    }
    let _e87 = xRoad;
    let _e90 = pos_9;
    let _e92 = roadLightH;
    if ((_e87 < 4f) && (_e90.y <= _e92)) {
        {
            let _e95 = pos_9;
            if (_e95.y == 0f) {
                {
                    let _e99 = pos_9;
                    let _e100 = hash31_(_e99);
                    rnd_1 = _e100;
                    let _e102 = rnd_1;
                    if (_e102 < 0.75f) {
                        {
                            let _e105 = xRoad;
                            if (_e105 == 1f) {
                                let _e118 = rnd_1;
                                let _e121 = (vec3<f32>(2f, 0.2f, 0.2f) * (_e118 + 0.75f));
                                return vec4<f32>(_e121.x, _e121.y, _e121.z, 0f);
                            } else {
                                let _e127 = xRoad;
                                if (_e127 == 2f) {
                                    let _e140 = rnd_1;
                                    let _e143 = (vec3<f32>(2f, 2f, 1f) * (_e140 + 0.75f));
                                    return vec4<f32>(_e143.x, _e143.y, _e143.z, 0f);
                                }
                            }
                        }
                    }
                }
            }
            let _e149 = pos_9;
            let _e151 = roadLightH;
            let _e153 = xRoad;
            let _e156 = xRoad;
            if ((_e149.y == _e151) && ((_e153 == 0f) || (_e156 == 3f))) {
                {
                    return vec4<f32>(2f, 2f, 2f, 0f);
                }
            }
            return vec4<f32>(0f, 0f, 0f, 0f);
        }
    }
    let _e177 = pos_9;
    let _e181 = pos_9;
    let _e186 = pos_9;
    if (((_e177.y >= 0f) && (_e181.y <= 12f)) && (_e186.z >= 4f)) {
        {
            let _e191 = pos_9;
            let _e193 = pos_9;
            xz = (vec2<f32>(_e191.x, _e193.z) * 0.2f);
            let _e199 = xz;
            let _e200 = pos_9;
            xz = (_e199 + sin(_e200.xz));
            let _e204 = xz;
            xz = floor(_e204);
            let _e206 = xz;
            let _e207 = hash21_(_e206);
            rnd_2 = _e207;
            let _e209 = rnd_2;
            h = ((_e209 * 40f) - 28f);
            let _e215 = h;
            let _e216 = h;
            let _e218 = h;
            h = (((_e215 * _e216) * _e218) / 50f);
            let _e222 = pos_9;
            let _e224 = h;
            let _e226 = pos_9;
            let _e227 = hash31_(_e226);
            if ((_e222.y <= _e224) && (_e227 < 0.6f)) {
                {
                    let _e231 = pos_9;
                    let _e232 = hash33_(_e231);
                    rnd2_ = _e232;
                    let _e234 = rnd2_;
                    k = _e234.z;
                    let _e237 = k;
                    if (_e237 < 0.2f) {
                        return vec4(0f);
                    }
                    let _e242 = k;
                    if (_e242 < 0.3f) {
                        local_2 = vec3<f32>(0.9f, 0.6f, 0.3f);
                    } else {
                        let _e249 = k;
                        if (_e249 < 0.75f) {
                            local_1 = vec3<f32>(1f, 1f, 0.5f);
                        } else {
                            let _e256 = k;
                            if (_e256 < 0.95f) {
                                local = vec3(1f);
                            } else {
                                local = vec3<f32>(0.9f, 1f, 1.2f);
                            }
                            let _e266 = local;
                            local_1 = _e266;
                        }
                        let _e268 = local_1;
                        local_2 = _e268;
                    }
                    let _e270 = local_2;
                    baseWindowColor = _e270;
                    let _e272 = baseWindowColor;
                    let _e275 = rnd2_;
                    let _e278 = ((_e272 * 8f) + (_e275 * 1.5f));
                    return vec4<f32>(_e278.x, _e278.y, _e278.z, 0f);
                }
            }
        }
    }
    let _e284 = pos_9;
    let _e288 = pos_9;
    if ((_e284.y >= 4f) && (_e288.y <= 30f)) {
        {
            let _e293 = pos_9;
            let _e295 = pos_9;
            let _e297 = (_e293.xyz * _e295.yzx);
            let _e299 = vec3(5.1f);
            let _e304 = hash31_((_e297 - (floor((_e297 / _e299)) * _e299)));
            rnd_3 = _e304;
            let _e306 = rnd_3;
            let _e307 = pos_9;
            if ((_e306 * _e307.y) < 0.04f) {
                {
                    let _e312 = pos_9;
                    let _e313 = hash33_(_e312);
                    rnd_4 = _e313;
                    let _e325 = rnd_4;
                    let _e326 = (vec3<f32>(5f, 0.5f, 0.5f) + _e325);
                    return vec4<f32>(_e326.x, _e326.y, _e326.z, 0f);
                }
            }
        }
    }
    return vec4<f32>(0f, 0f, 0f, 0f);
}

fn getColor7_(pos_10: vec3<f32>, N_2: f32) -> vec4<f32> {
    var pos_11: vec3<f32>;
    var N_3: f32;
    var id: vec3<f32>;
    var color: vec3<f32>;
    var d: f32;

    pos_11 = pos_10;
    N_3 = N_2;
    let _e10 = N_3;
    N_3 = (_e10 * 2f);
    let _e13 = pos_11;
    let _e14 = N_3;
    let _e17 = N_3;
    id = floor(((_e13 + vec3(_e14)) / vec3((_e17 * 2f))));
    let _e24 = id;
    if (_e24.z < 1f) {
        return vec4(0f);
    }
    let _e30 = id;
    let _e31 = hash33_(_e30);
    color = _e31;
    let _e33 = pos_11;
    let _e34 = N_3;
    let _e36 = (_e33 + vec3(_e34));
    let _e37 = N_3;
    let _e40 = vec3((_e37 * 2f));
    let _e45 = N_3;
    pos_11 = ((_e36 - (floor((_e36 / _e40)) * _e40)) - vec3(_e45));
    let _e48 = pos_11;
    d = length((_e48 - vec3<f32>(0f, 0f, 0f)));
    let _e56 = color;
    let _e59 = d;
    let _e63 = d;
    let _e70 = (_e56 * vec3(((smoothstep(10f, 0f, _e59) * 150f) / pow(max(_e63, 1f), 1f))));
    return vec4<f32>(_e70.x, _e70.y, _e70.z, 0f);
}

fn hash11_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e8 = x_1;
    return fract((sin(((_e8 * 45.34f) + 123.131f)) * 94.434f));
}

fn getColorBoxes(pos_12: vec3<f32>, N_4: f32) -> vec4<f32> {
    var pos_13: vec3<f32>;
    var N_5: f32;
    var k_1: f32;

    pos_13 = pos_12;
    N_5 = N_4;
    let _e10 = N_5;
    k_1 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_13;
    let _e19 = hash11_(_e17.x);
    let _e20 = k_1;
    let _e22 = pos_13;
    let _e24 = hash11_(_e22.y);
    let _e25 = k_1;
    if ((_e19 < _e20) || (_e24 < _e25)) {
        let _e28 = pos_13;
        let _e31 = hash33_(vec3<f32>(_e28.xyz));
        let _e33 = (_e31 * 8f);
        return vec4<f32>(_e33.x, _e33.y, _e33.z, 0f);
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn hash23_(u_4: vec2<f32>) -> vec3<f32> {
    var u_5: vec2<f32>;

    u_5 = u_4;
    let _e8 = u_5;
    let _e12 = u_5;
    let _e21 = u_5;
    let _e25 = u_5;
    let _e34 = u_5;
    let _e38 = u_5;
    return vec3<f32>(fract((sin(((_e8.x * 776.45f) + (_e12.y * 453.24f))) * 45.77f)), fract((sin(((_e21.x * 376.45f) + (_e25.y * 853.24f))) * 88.77f)), fract((sin(((_e34.x * 457.77f) + (_e38.y * 667.17f))) * 65.57f)));
}

fn getColorBoxesGradient(pos_14: vec3<f32>, N_6: f32) -> vec4<f32> {
    var pos_15: vec3<f32>;
    var N_7: f32;
    var k_2: f32;
    var col: vec3<f32>;
    var offset: f32;

    pos_15 = pos_14;
    N_7 = N_6;
    let _e10 = N_7;
    k_2 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_15;
    let _e19 = hash11_(_e17.x);
    let _e20 = k_2;
    let _e22 = pos_15;
    let _e24 = hash11_(_e22.y);
    let _e25 = k_2;
    if ((_e19 < _e20) || (_e24 < _e25)) {
        {
            let _e28 = pos_15;
            let _e30 = hash23_(_e28.xy);
            col = _e30;
            let _e32 = col;
            offset = (fract((_e32.y * 55.2f)) * 10f);
            let _e40 = col;
            let _e43 = pos_15;
            let _e47 = offset;
            let _e50 = ((_e40 * 8f) * fract(((_e43.z * 0.02f) + _e47)));
            return vec4<f32>(_e50.x, _e50.y, _e50.z, 0f);
        }
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColorCorridor(pos_16: vec3<f32>, N_8: f32) -> vec4<f32> {
    var pos_17: vec3<f32>;
    var N_9: f32;
    var k_3: f32;

    pos_17 = pos_16;
    N_9 = N_8;
    let _e10 = N_9;
    k_3 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_17;
    let _e19 = hash21_(_e17.xy);
    let _e20 = k_3;
    if (_e19 < _e20) {
        let _e22 = pos_17;
        let _e25 = hash33_(vec3<f32>(_e22.xyz));
        let _e27 = (_e25 * 8f);
        return vec4<f32>(_e27.x, _e27.y, _e27.z, 0f);
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColorCorridorGradient(pos_18: vec3<f32>, N_10: f32) -> vec4<f32> {
    var pos_19: vec3<f32>;
    var N_11: f32;
    var k_4: f32;
    var col_1: vec3<f32>;
    var offset_1: f32;

    pos_19 = pos_18;
    N_11 = N_10;
    let _e10 = N_11;
    k_4 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_19;
    let _e19 = hash21_(_e17.xy);
    let _e20 = k_4;
    if (_e19 < _e20) {
        {
            let _e22 = pos_19;
            let _e24 = hash23_(_e22.xy);
            col_1 = _e24;
            let _e26 = col_1;
            offset_1 = (fract((_e26.y * 55.2f)) * 10f);
            let _e34 = col_1;
            let _e37 = pos_19;
            let _e41 = offset_1;
            let _e44 = ((_e34 * 8f) * fract(((_e37.z * 0.02f) + _e41)));
            return vec4<f32>(_e44.x, _e44.y, _e44.z, 0f);
        }
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColorPillars(pos_20: vec3<f32>, N_12: f32) -> vec4<f32> {
    var pos_21: vec3<f32>;
    var N_13: f32;
    var k_5: f32;

    pos_21 = pos_20;
    N_13 = N_12;
    let _e10 = N_13;
    k_5 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_21;
    let _e19 = hash21_(_e17.zx);
    let _e20 = k_5;
    if (_e19 < _e20) {
        let _e22 = pos_21;
        let _e25 = hash33_(vec3<f32>(_e22.xyz));
        let _e27 = (_e25 * 8f);
        return vec4<f32>(_e27.x, _e27.y, _e27.z, 0f);
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColorPlanes(pos_22: vec3<f32>, N_14: f32) -> vec4<f32> {
    var pos_23: vec3<f32>;
    var N_15: f32;
    var k_6: f32;

    pos_23 = pos_22;
    N_15 = N_14;
    let _e10 = N_15;
    k_6 = pow((abs(_e10) * 0.01f), 0.5f);
    let _e17 = pos_23;
    let _e19 = hash11_(_e17.y);
    let _e20 = k_6;
    if (_e19 < _e20) {
        let _e22 = pos_23;
        let _e25 = hash33_(vec3<f32>(_e22.xyz));
        let _e27 = (_e25 * 8f);
        return vec4<f32>(_e27.x, _e27.y, _e27.z, 0f);
    } else {
        return vec4<f32>(0f, 0f, 0f, 0f);
    }
}

fn getColorSuperStructure(pos_24: vec3<f32>, N_16: f32) -> vec4<f32> {
    var pos_25: vec3<f32>;
    var N_17: f32;
    var k_7: f32;

    pos_25 = pos_24;
    N_17 = N_16;
    let _e10 = N_17;
    k_7 = (abs(_e10) * 0.01f);
    let _e15 = pos_25;
    let _e17 = hash21_(_e15.xy);
    let _e18 = k_7;
    let _e20 = pos_25;
    let _e22 = hash21_(_e20.yz);
    let _e23 = k_7;
    let _e26 = pos_25;
    let _e28 = hash21_(_e26.zx);
    let _e29 = k_7;
    if (((_e17 < _e18) || (_e22 < _e23)) || (_e28 < _e29)) {
        let _e32 = pos_25;
        let _e35 = hash33_(vec3<f32>(_e32.xyz));
        let _e37 = (_e35 * 8f);
        return vec4<f32>(_e37.x, _e37.y, _e37.z, 0f);
    }
    return vec4<f32>(0f, 0f, 0f, 0f);
}

fn hash12_(x_2: f32) -> vec2<f32> {
    var x_3: f32;

    x_3 = x_2;
    let _e8 = x_3;
    let _e15 = x_3;
    return vec2<f32>(fract((sin((_e8 * 776.4577f)) * 45.77f)), fract((sin(((_e15 * 376.4517f) + 1.2524f)) * 88.77f)));
}

fn hash32_(u_6: vec3<f32>) -> vec2<f32> {
    var u_7: vec3<f32>;

    u_7 = u_6;
    let _e8 = u_7;
    let _e12 = u_7;
    let _e17 = u_7;
    let _e26 = u_7;
    let _e30 = u_7;
    let _e35 = u_7;
    return vec2<f32>(fract((sin((((_e8.x * 776.45f) + (_e12.y * 453.24f)) + (_e17.z * 553.25f))) * 45.77f)), fract((sin((((_e26.x * 376.45f) + (_e30.y * 853.24f)) + (_e35.z * 153.84f))) * 88.77f)));
}

fn getLayer(id_1: f32, camera: vec2<f32>, cameraZ: f32, uv: vec2<f32>, mode: i32, dampening: f32, lastX: ptr<function, f32>, offset_2: f32, distortion: f32, distortionPower: f32, distortionScale: f32, distortionIntensity: f32, colorPeriod: f32) -> vec4<f32> {
    var id_2: f32;
    var camera_1: vec2<f32>;
    var cameraZ_1: f32;
    var uv_1: vec2<f32>;
    var mode_1: i32;
    var dampening_1: f32;
    var offset_3: f32;
    var distortion_1: f32;
    var distortionPower_1: f32;
    var distortionScale_1: f32;
    var distortionIntensity_1: f32;
    var colorPeriod_1: f32;
    var z: f32;
    var local_3: vec2<f32>;
    var displace: vec2<f32>;
    var scale: f32;
    var k_8: f32;
    var scale_1: f32;
    var k_9: f32;
    var scale_2: f32;
    var k_10: f32;
    var scale_3: f32;
    var k_11: f32;
    var scale_4: f32;
    var d_1: f32;
    var a_1: f32;
    var da: f32;
    var intersection: vec2<f32>;
    var cell: vec2<f32>;
    var color_1: vec4<f32>;
    var pos_26: vec3<f32>;
    var u_8: vec2<f32>;
    var r: f32;
    var g: f32;
    var depthDampening: f32;

    id_2 = id_1;
    camera_1 = camera;
    cameraZ_1 = cameraZ;
    uv_1 = uv;
    mode_1 = mode;
    dampening_1 = dampening;
    offset_3 = offset_2;
    distortion_1 = distortion;
    distortionPower_1 = distortionPower;
    distortionScale_1 = distortionScale;
    distortionIntensity_1 = distortionIntensity;
    colorPeriod_1 = colorPeriod;
    let _e31 = id_2;
    z = (_e31 + 1f);
    let _e35 = z;
    let _e36 = cameraZ_1;
    if ((_e35 + _e36) <= 0f) {
        return vec4(0f);
    }
    let _e42 = offset_3;
    if (_e42 == 0f) {
        local_3 = vec2(0f);
    } else {
        let _e47 = offset_3;
        let _e50 = z;
        let _e51 = hash12_(_e50);
        local_3 = ((_e47 * 2f) * _e51);
    }
    let _e54 = local_3;
    displace = _e54;
    let _e56 = distortion_1;
    if (_e56 == 0f) {
        {
        }
    } else {
        let _e59 = distortion_1;
        if (_e59 <= 1f) {
            {
                let _e62 = distortionScale_1;
                let _e63 = z;
                let _e64 = distortionPower_1;
                scale = (_e62 * pow(_e63, _e64));
                let _e68 = displace;
                let _e69 = distortion_1;
                let _e70 = distortionIntensity_1;
                let _e72 = uv_1;
                let _e73 = scale;
                displace = (_e68 + ((_e69 * _e70) * sin((_e72 * _e73))));
            }
        } else {
            let _e78 = distortion_1;
            if (_e78 <= 2f) {
                {
                    let _e81 = distortion_1;
                    k_8 = (_e81 - 1f);
                    let _e85 = distortionScale_1;
                    let _e86 = z;
                    let _e87 = distortionPower_1;
                    scale_1 = (_e85 * pow(_e86, _e87));
                    let _e91 = displace;
                    let _e92 = distortionIntensity_1;
                    let _e93 = uv_1;
                    let _e94 = scale_1;
                    let _e97 = uv_1;
                    let _e99 = uv_1;
                    let _e101 = scale_1;
                    let _e105 = uv_1;
                    let _e107 = scale_1;
                    let _e111 = k_8;
                    displace = (_e91 + (_e92 * mix(sin((_e93 * _e94)), ((normalize(_e97) * cos((_e99.x * _e101))) * cos((_e105.y * _e107))), vec2(_e111))));
                }
            } else {
                let _e116 = distortion_1;
                if (_e116 <= 3f) {
                    {
                        let _e119 = distortion_1;
                        k_9 = (_e119 - 2f);
                        let _e123 = distortionScale_1;
                        let _e124 = z;
                        let _e125 = distortionPower_1;
                        scale_2 = (_e123 * pow(_e124, _e125));
                        let _e129 = displace;
                        let _e130 = distortionIntensity_1;
                        let _e131 = uv_1;
                        let _e133 = uv_1;
                        let _e135 = scale_2;
                        let _e139 = uv_1;
                        let _e141 = scale_2;
                        let _e145 = uv_1;
                        let _e147 = uv_1;
                        let _e148 = scale_2;
                        let _e153 = k_9;
                        displace = (_e129 + (_e130 * mix(((normalize(_e131) * cos((_e133.x * _e135))) * cos((_e139.y * _e141))), (normalize(_e145) * sin(length((_e147 * _e148)))), vec2(_e153))));
                    }
                } else {
                    let _e158 = distortion_1;
                    if (_e158 <= 4f) {
                        {
                            let _e161 = distortion_1;
                            k_10 = (_e161 - 3f);
                            let _e165 = distortionScale_1;
                            let _e166 = z;
                            let _e167 = distortionPower_1;
                            scale_3 = (_e165 * pow(_e166, _e167));
                            let _e171 = displace;
                            let _e172 = distortionIntensity_1;
                            let _e173 = uv_1;
                            let _e175 = uv_1;
                            let _e176 = scale_3;
                            let _e181 = uv_1;
                            let _e183 = uv_1;
                            let _e184 = scale_3;
                            let _e189 = k_10;
                            displace = (_e171 + (_e172 * mix((normalize(_e173) * sin(length((_e175 * _e176)))), (normalize(_e181) * cos(length((_e183 * _e184)))), vec2(_e189))));
                        }
                    } else {
                        let _e194 = distortion_1;
                        if (_e194 <= 5f) {
                            {
                                let _e197 = distortion_1;
                                k_11 = (_e197 - 4f);
                                let _e201 = distortionScale_1;
                                let _e202 = z;
                                let _e203 = distortionPower_1;
                                scale_4 = (_e201 * pow(_e202, _e203));
                                let _e207 = uv_1;
                                d_1 = length(_e207);
                                let _e210 = uv_1;
                                let _e212 = uv_1;
                                a_1 = atan2(_e210.y, _e212.x);
                                let _e216 = d_1;
                                let _e217 = scale_4;
                                let _e220 = a_1;
                                da = (cos((_e216 * _e217)) + _e220);
                                let _e223 = displace;
                                let _e224 = distortionIntensity_1;
                                let _e225 = uv_1;
                                let _e227 = uv_1;
                                let _e228 = scale_4;
                                let _e233 = d_1;
                                let _e234 = da;
                                let _e236 = da;
                                let _e240 = uv_1;
                                let _e242 = k_11;
                                displace = (_e223 + (_e224 * mix((normalize(_e225) * cos(length((_e227 * _e228)))), ((_e233 * vec2<f32>(cos(_e234), sin(_e236))) - _e240), vec2(_e242))));
                            }
                        }
                    }
                }
            }
        }
    }
    let _e247 = uv_1;
    let _e248 = displace;
    let _e250 = z;
    let _e251 = cameraZ_1;
    let _e254 = camera_1;
    intersection = (((_e247 + _e248) * (_e250 + _e251)) + _e254);
    let _e257 = intersection;
    cell = round(_e257);
    let _e260 = (*lastX);
    if (_e260 != -1000000000f) {
        {
            let _e264 = cell;
            let _e266 = (*lastX);
            if (_e264.x != _e266) {
                return vec4(0f);
            }
        }
    }
    let _e271 = cell;
    let _e272 = z;
    pos_26 = vec3<f32>(_e271.x, _e271.y, _e272);
    let _e277 = mode_1;
    if (_e277 == 0i) {
        let _e280 = pos_26;
        let _e281 = getColor2_(_e280);
        color_1 = _e281;
    } else {
        let _e282 = mode_1;
        if (_e282 == 1i) {
            let _e285 = pos_26;
            let _e286 = getColor2b(_e285);
            color_1 = _e286;
        } else {
            let _e287 = mode_1;
            if (_e287 == 2i) {
                let _e290 = pos_26;
                let _e291 = colorPeriod_1;
                let _e292 = getColor3b(_e290, _e291);
                color_1 = _e292;
            } else {
                let _e293 = mode_1;
                if (_e293 == 3i) {
                    let _e296 = pos_26;
                    let _e298 = colorPeriod_1;
                    let _e299 = getColor3b(_e296.yzx, _e298);
                    color_1 = _e299;
                } else {
                    let _e300 = mode_1;
                    if (_e300 == 4i) {
                        let _e303 = pos_26;
                        let _e305 = colorPeriod_1;
                        let _e306 = getColor3b(_e303.zxy, _e305);
                        color_1 = _e306;
                    } else {
                        let _e307 = mode_1;
                        if (_e307 == 5i) {
                            let _e310 = pos_26;
                            let _e311 = colorPeriod_1;
                            let _e312 = getColor7_(_e310, _e311);
                            color_1 = _e312;
                        } else {
                            let _e313 = mode_1;
                            if (_e313 == 10i) {
                                let _e316 = pos_26;
                                let _e317 = getColor1_(_e316);
                                color_1 = _e317;
                            } else {
                                let _e318 = mode_1;
                                if (_e318 == 20i) {
                                    let _e321 = pos_26;
                                    let _e322 = getColor6_(_e321);
                                    color_1 = _e322;
                                } else {
                                    let _e323 = mode_1;
                                    if (_e323 == 100i) {
                                        let _e326 = pos_26;
                                        let _e327 = colorPeriod_1;
                                        let _e328 = getColorSuperStructure(_e326, _e327);
                                        color_1 = _e328;
                                    } else {
                                        let _e329 = mode_1;
                                        if (_e329 == 101i) {
                                            let _e332 = pos_26;
                                            let _e333 = colorPeriod_1;
                                            let _e334 = getColorPillars(_e332, _e333);
                                            color_1 = _e334;
                                        } else {
                                            let _e335 = mode_1;
                                            if (_e335 == 102i) {
                                                let _e338 = pos_26;
                                                let _e339 = colorPeriod_1;
                                                let _e340 = getColorCorridor(_e338, _e339);
                                                color_1 = _e340;
                                            } else {
                                                let _e341 = mode_1;
                                                if (_e341 == 103i) {
                                                    let _e344 = pos_26;
                                                    let _e345 = colorPeriod_1;
                                                    let _e346 = getColorCorridorGradient(_e344, _e345);
                                                    color_1 = _e346;
                                                } else {
                                                    let _e347 = mode_1;
                                                    if (_e347 == 110i) {
                                                        let _e350 = pos_26;
                                                        let _e351 = colorPeriod_1;
                                                        let _e352 = getColorPlanes(_e350, _e351);
                                                        color_1 = _e352;
                                                    } else {
                                                        let _e353 = mode_1;
                                                        if (_e353 == 111i) {
                                                            let _e356 = pos_26;
                                                            let _e357 = colorPeriod_1;
                                                            let _e358 = getColorBoxes(_e356, _e357);
                                                            color_1 = _e358;
                                                        } else {
                                                            let _e359 = mode_1;
                                                            if (_e359 == 112i) {
                                                                let _e362 = pos_26;
                                                                let _e363 = colorPeriod_1;
                                                                let _e364 = getColorBoxesGradient(_e362, _e363);
                                                                color_1 = _e364;
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
            }
        }
    }
    let _e365 = color_1;
    let _e369 = color_1;
    let _e374 = color_1;
    if (((_e365.x == 0f) && (_e369.y == 0f)) && (_e374.z == 0f)) {
        let _e379 = color_1;
        return _e379;
    }
    let _e380 = intersection;
    let _e381 = cell;
    u_8 = (_e380 - _e381);
    let _e384 = u_8;
    r = length(_e384);
    let _e389 = r;
    let _e393 = r;
    g = ((smoothstep(0.5f, 0.3f, _e389) * 0.05f) / _e393);
    let _e396 = z;
    let _e397 = dampening_1;
    depthDampening = pow(_e396, -(_e397));
    let _e401 = color_1;
    if (_e401.w > 0f) {
        let _e405 = cell;
        (*lastX) = _e405.x;
    }
    let _e407 = g;
    let _e408 = color_1;
    let _e411 = depthDampening;
    let _e412 = ((_e407 * _e408.xyz) * _e411);
    let _e413 = color_1;
    return vec4<f32>(_e412.x, _e412.y, _e412.z, _e413.w);
}

fn lightArray(uv_2: vec2<f32>, outPos: vec2<f32>, layerCount: i32, modelTransform: mat3x3<f32>, color_2: vec4<f32>, mode_2: i32, dampening_2: f32, offset_4: f32, intensity: f32, distortion_2: f32, distortionPower_2: f32, distortionScale_2: f32, distortionIntensity_2: f32, colorPeriod_2: f32, source_specified: i32) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var layerCount_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var color_3: vec4<f32>;
    var mode_3: i32;
    var dampening_3: f32;
    var offset_5: f32;
    var intensity_1: f32;
    var distortion_3: f32;
    var distortionPower_3: f32;
    var distortionScale_3: f32;
    var distortionIntensity_3: f32;
    var colorPeriod_3: f32;
    var source_specified_1: i32;
    var inverseModelTransform: mat3x3<f32>;
    var lastX_1: f32 = -1000000000f;
    var col_2: vec3<f32> = vec3(0f);
    var N_18: f32;
    var camScale: f32;
    var cameraZ_2: f32;
    var i: f32 = 0f;
    var layColor: vec4<f32>;
    var outCol: vec4<f32>;
    var lum: f32;
    var blend: f32;

    uv_3 = uv_2;
    outPos_1 = outPos;
    layerCount_1 = layerCount;
    modelTransform_1 = modelTransform;
    color_3 = color_2;
    mode_3 = mode_2;
    dampening_3 = dampening_2;
    offset_5 = offset_4;
    intensity_1 = intensity;
    distortion_3 = distortion_2;
    distortionPower_3 = distortionPower_2;
    distortionScale_3 = distortionScale_2;
    distortionIntensity_3 = distortionIntensity_2;
    colorPeriod_3 = colorPeriod_2;
    source_specified_1 = source_specified;
    let _e36 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e36);
    let _e39 = uv_3;
    uv_3 = (_e39 * 1f);
    let _e48 = layerCount_1;
    N_18 = f32(_e48);
    let _e53 = inverseModelTransform[0];
    camScale = length(_e53.xy);
    let _e57 = camScale;
    cameraZ_2 = log(_e57);
    loop {
        let _e62 = i;
        let _e63 = N_18;
        if !((_e62 < _e63)) {
            break;
        }
        {
            let _e69 = i;
            let _e72 = inverseModelTransform[2];
            let _e76 = cameraZ_2;
            let _e77 = uv_3;
            let _e78 = mode_3;
            let _e79 = dampening_3;
            let _e81 = offset_5;
            let _e82 = distortion_3;
            let _e83 = distortionPower_3;
            let _e84 = distortionScale_3;
            let _e85 = distortionIntensity_3;
            let _e86 = colorPeriod_3;
            let _e88 = getLayer(_e69, (_e72.xy * 2f), _e76, _e77, _e78, _e79, (&lastX_1), _e81, _e82, _e83, _e84, _e85, _e86);
            layColor = _e88;
            let _e90 = col_2;
            let _e91 = layColor;
            col_2 = (_e90 + _e91.xyz);
        }
        continuing {
            let _e66 = i;
            i = (_e66 + 1f);
        }
    }
    let _e94 = intensity_1;
    let _e95 = col_2;
    let _e96 = (_e94 * _e95);
    outCol = vec4<f32>(_e96.x, _e96.y, _e96.z, 1f);
    let _e103 = outCol;
    let _e105 = outCol;
    let _e108 = outCol;
    lum = ((_e103.x + _e105.y) + _e108.z);
    let _e112 = lum;
    if (_e112 > 0f) {
        {
            let _e115 = color_3;
            let _e117 = color_3;
            let _e119 = lum;
            let _e120 = color_3;
            let _e122 = color_3;
            let _e125 = color_3;
            let _e129 = (_e117.xyz * (_e119 / ((_e120.x + _e122.y) + _e125.z)));
            color_3.x = _e129.x;
            color_3.y = _e129.y;
            color_3.z = _e129.z;
            let _e136 = outCol;
            let _e138 = outCol;
            let _e140 = color_3;
            let _e142 = color_3;
            let _e145 = mix(_e138.xyz, _e140.xyz, vec3(_e142.w));
            outCol.x = _e145.x;
            outCol.y = _e145.y;
            outCol.z = _e145.z;
        }
    }
    let _e152 = source_specified_1;
    if (_e152 == 1i) {
        {
            let _e155 = lum;
            blend = clamp(_e155, 0f, 1f);
            let _e160 = uv_3;
            let _e164 = global.U[0];
            let _e167 = uv_3;
            let _e176 = textureSample(t_source, samp, ((vec2<f32>((_e160.x / _e164.x), _e167.y) / vec2(2f)) + vec2(0.5f)));
            let _e177 = outCol;
            outCol = (_e176 + _e177);
        }
    }
    let _e179 = outCol;
    return _e179;
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
    let _e66 = global.U[6];
    let _e71 = global.U[7];
    let _e72 = _e71.xyz;
    let _e75 = global.U[8];
    let _e76 = _e75.xyz;
    let _e79 = global.U[9];
    let _e80 = _e79.xyz;
    let _e96 = global.U[10];
    let _e99 = global.U[11];
    let _e104 = global.U[12];
    let _e108 = global.U[13];
    let _e112 = global.U[14];
    let _e116 = global.U[15];
    let _e120 = global.U[16];
    let _e124 = global.U[17];
    let _e128 = global.U[18];
    let _e132 = global.U[19];
    let _e136 = global.U[4];
    let _e139 = lightArray((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96, i32(_e99.x), _e104.x, _e108.x, _e112.x, _e116.x, _e120.x, _e124.x, _e128.x, _e132.x, i32(_e136.x));
    fragColor = _e139;
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
