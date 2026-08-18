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

fn getSpiralIndex(uv: vec2<f32>) -> f32 {
    var uv_1: vec2<f32>;
    var v: vec2<f32>;
    var u: vec2<f32>;
    var m: vec2<f32>;
    var level: f32;

    uv_1 = uv;
    let _e8 = uv_1;
    v = fract(_e8);
    let _e11 = uv_1;
    u = floor(_e11);
    let _e14 = u;
    m = abs((_e14 + vec2(0.5f)));
    let _e20 = m;
    let _e22 = m;
    level = (max(_e20.x, _e22.y) + 0.5f);
    let _e28 = u;
    let _e30 = level;
    if (_e28.y == -(_e30)) {
        {
            let _e34 = level;
            let _e36 = level;
            let _e40 = level;
            let _e43 = u;
            return ((((4f * _e34) * _e36) - 1f) - ((_e40 - 1f) - _e43.x));
        }
    } else {
        let _e47 = u;
        let _e49 = level;
        if (_e47.x == -(_e49)) {
            {
                let _e53 = level;
                let _e55 = level;
                let _e60 = level;
                let _e65 = level;
                let _e67 = u;
                return (((((4f * _e53) * _e55) - 1f) - ((2f * _e60) - 1f)) + (-(_e65) - _e67.y));
            }
        } else {
            let _e71 = u;
            let _e73 = level;
            if (_e71.y == (_e73 - 1f)) {
                {
                    let _e78 = level;
                    let _e82 = level;
                    let _e89 = level;
                    let _e94 = level;
                    let _e97 = u;
                    return (((((4f * (_e78 - 1f)) * (_e82 - 1f)) - 1f) + ((2f * _e89) - 1f)) + ((_e94 - 1f) - _e97.x));
                }
            } else {
                {
                    let _e102 = level;
                    let _e106 = level;
                    let _e112 = u;
                    let _e114 = level;
                    return ((((4f * (_e102 - 1f)) * (_e106 - 1f)) - 1f) + (_e112.y + _e114));
                }
            }
        }
    }
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

fn mir(x: f32, a: f32) -> f32 {
    var x_1: f32;
    var a_1: f32;

    x_1 = x;
    a_1 = a;
    let _e10 = a_1;
    let _e12 = x_1;
    let _e14 = a_1;
    let _e15 = (2f * _e14);
    let _e20 = a_1;
    return (_e10 * (1f - abs((((_e12 - (floor((_e12 / _e15)) * _e15)) / _e20) - 1f))));
}

fn remap(uv_2: vec2<f32>, scale: i32) -> vec2<f32> {
    var uv_3: vec2<f32>;
    var scale_1: i32;
    var s: f32;

    uv_3 = uv_2;
    scale_1 = scale;
    let _e10 = scale_1;
    s = f32(_e10);
    let _e13 = uv_3;
    let _e14 = s;
    let _e16 = scale_1;
    return ((_e13 * _e14) - vec2(f32((_e16 / 2i))));
}

fn squareSpiral(uv_4: vec2<f32>, outPos: vec2<f32>, outDim: vec2<f32>, source_specified: i32, scale_2: i32, innerScale: i32, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>, borderColor: vec4<f32>, mode: i32, thickness: f32, border: f32, balance: f32, offset: f32) -> vec4<f32> {
    var uv_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var outDim_1: vec2<f32>;
    var source_specified_1: i32;
    var scale_3: i32;
    var innerScale_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var borderColor_1: vec4<f32>;
    var mode_1: i32;
    var thickness_1: f32;
    var border_1: f32;
    var balance_1: f32;
    var offset_1: f32;
    var orig2Uv: vec2<f32>;
    var origUv: vec2<f32>;
    var index: f32;
    var intensity: f32;
    var k: f32;
    var outColor: vec4<f32>;
    var uv2_: vec2<f32>;
    var t: f32;
    var index_1: f32;
    var intensity_1: f32;
    var k_1: f32;
    var innerColor: vec4<f32>;
    var fuv: vec2<f32>;

    uv_5 = uv_4;
    outPos_1 = outPos;
    outDim_1 = outDim;
    source_specified_1 = source_specified;
    scale_3 = scale_2;
    innerScale_1 = innerScale;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    borderColor_1 = borderColor;
    mode_1 = mode;
    thickness_1 = thickness;
    border_1 = border;
    balance_1 = balance;
    offset_1 = offset;
    let _e38 = uv_5;
    orig2Uv = _e38;
    let _e40 = mode_1;
    if (_e40 >= 1i) {
        let _e43 = uv_5;
        let _e47 = (_e43 + vec2<f32>(1f, 1f));
        let _e49 = vec2(2f);
        uv_5 = ((_e47 - (floor((_e47 / _e49)) * _e49)) - vec2<f32>(1f, 1f));
    }
    let _e58 = uv_5;
    origUv = _e58;
    let _e60 = uv_5;
    let _e67 = scale_3;
    let _e68 = remap(((_e60 + vec2<f32>(1f, 1f)) * 0.5f), _e67);
    uv_5 = _e68;
    let _e69 = uv_5;
    let _e70 = getSpiralIndex(_e69);
    index = _e70;
    let _e73 = scale_3;
    let _e74 = scale_3;
    intensity = (1f / f32((_e73 * _e74)));
    let _e79 = intensity;
    let _e80 = index;
    k = (_e79 * _e80);
    let _e83 = balance_1;
    if (_e83 != 0f) {
        let _e86 = k;
        let _e88 = balance_1;
        k = (_e86 * pow(1000f, _e88));
    }
    let _e91 = offset_1;
    if (_e91 != 0f) {
        let _e94 = k;
        let _e95 = offset_1;
        k = (_e94 + _e95);
    }
    let _e97 = mode_1;
    if (_e97 != 0i) {
        {
            let _e100 = k;
            let _e102 = mir(_e100, 1f);
            k = _e102;
        }
    }
    let _e103 = color1_1;
    let _e104 = color2_1;
    let _e105 = k;
    outColor = mix(_e103, _e104, vec4(_e105));
    let _e109 = uv_5;
    uv2_ = fract(_e109);
    let _e112 = thickness_1;
    t = (_e112 * 0.5f);
    let _e116 = uv2_;
    let _e118 = t;
    let _e120 = uv2_;
    let _e123 = t;
    let _e127 = uv2_;
    let _e129 = t;
    let _e132 = uv2_;
    let _e135 = t;
    if ((((_e116.x > _e118) && (_e120.x < (1f - _e123))) && (_e127.y > _e129)) && (_e132.y < (1f - _e135))) {
        {
            let _e139 = uv2_;
            let _e140 = t;
            let _e144 = thickness_1;
            let _e148 = innerScale_1;
            let _e149 = remap(((_e139 - vec2(_e140)) / vec2((1f - _e144))), _e148);
            uv2_ = _e149;
            let _e150 = uv2_;
            let _e151 = getSpiralIndex(_e150);
            index_1 = _e151;
            let _e154 = innerScale_1;
            let _e155 = innerScale_1;
            intensity_1 = (1f / f32((_e154 * _e155)));
            let _e160 = intensity_1;
            let _e161 = index_1;
            k_1 = (_e160 * _e161);
            let _e164 = color3_1;
            let _e165 = color4_1;
            let _e166 = k_1;
            innerColor = mix(_e164, _e165, vec4(_e166));
            let _e170 = outColor;
            let _e171 = innerColor;
            let _e172 = mergeColor(_e170, _e171);
            outColor = _e172;
        }
    }
    let _e173 = border_1;
    if (_e173 > 0f) {
        {
            let _e176 = uv_5;
            fuv = fract(_e176);
            let _e179 = fuv;
            let _e181 = border_1;
            let _e183 = index;
            let _e184 = uv_5;
            let _e189 = getSpiralIndex((_e184 - vec2<f32>(1f, 0f)));
            if ((_e179.x < _e181) && (abs((_e183 - _e189)) > 1f)) {
                {
                    let _e195 = outColor;
                    let _e196 = borderColor_1;
                    let _e197 = mergeColor(_e195, _e196);
                    outColor = _e197;
                }
            } else {
                let _e198 = fuv;
                let _e200 = border_1;
                let _e202 = index;
                let _e203 = uv_5;
                let _e208 = getSpiralIndex((_e203 - vec2<f32>(0f, 1f)));
                if ((_e198.y < _e200) && (abs((_e202 - _e208)) > 1f)) {
                    {
                        let _e214 = outColor;
                        let _e215 = borderColor_1;
                        let _e216 = mergeColor(_e214, _e215);
                        outColor = _e216;
                    }
                } else {
                    let _e217 = fuv;
                    let _e220 = border_1;
                    let _e223 = index;
                    let _e224 = uv_5;
                    let _e229 = getSpiralIndex((_e224 + vec2<f32>(1f, 0f)));
                    if ((_e217.x > (1f - _e220)) && (abs((_e223 - _e229)) > 1f)) {
                        {
                            let _e235 = outColor;
                            let _e236 = borderColor_1;
                            let _e237 = mergeColor(_e235, _e236);
                            outColor = _e237;
                        }
                    } else {
                        let _e238 = fuv;
                        let _e241 = border_1;
                        let _e244 = index;
                        let _e245 = uv_5;
                        let _e250 = getSpiralIndex((_e245 + vec2<f32>(0f, 1f)));
                        if ((_e238.y > (1f - _e241)) && (abs((_e244 - _e250)) > 1f)) {
                            {
                                let _e256 = outColor;
                                let _e257 = borderColor_1;
                                let _e258 = mergeColor(_e256, _e257);
                                outColor = _e258;
                            }
                        } else {
                            let _e259 = fuv;
                            let _e261 = border_1;
                            let _e263 = fuv;
                            let _e265 = border_1;
                            let _e268 = index;
                            let _e269 = uv_5;
                            let _e274 = getSpiralIndex((_e269 - vec2<f32>(1f, 1f)));
                            if (((_e259.x < _e261) && (_e263.y < _e265)) && (abs((_e268 - _e274)) > 1f)) {
                                {
                                    let _e280 = outColor;
                                    let _e281 = borderColor_1;
                                    let _e282 = mergeColor(_e280, _e281);
                                    outColor = _e282;
                                }
                            } else {
                                let _e283 = fuv;
                                let _e286 = border_1;
                                let _e289 = fuv;
                                let _e291 = border_1;
                                let _e294 = index;
                                let _e295 = uv_5;
                                let _e301 = getSpiralIndex((_e295 + vec2<f32>(1f, -1f)));
                                if (((_e283.x > (1f - _e286)) && (_e289.y < _e291)) && (abs((_e294 - _e301)) > 1f)) {
                                    {
                                        let _e307 = outColor;
                                        let _e308 = borderColor_1;
                                        let _e309 = mergeColor(_e307, _e308);
                                        outColor = _e309;
                                    }
                                } else {
                                    let _e310 = fuv;
                                    let _e312 = border_1;
                                    let _e314 = fuv;
                                    let _e317 = border_1;
                                    let _e321 = index;
                                    let _e322 = uv_5;
                                    let _e328 = getSpiralIndex((_e322 + vec2<f32>(-1f, 1f)));
                                    if (((_e310.x < _e312) && (_e314.y > (1f - _e317))) && (abs((_e321 - _e328)) > 1f)) {
                                        {
                                            let _e334 = outColor;
                                            let _e335 = borderColor_1;
                                            let _e336 = mergeColor(_e334, _e335);
                                            outColor = _e336;
                                        }
                                    } else {
                                        let _e337 = fuv;
                                        let _e340 = border_1;
                                        let _e343 = fuv;
                                        let _e346 = border_1;
                                        let _e350 = index;
                                        let _e351 = uv_5;
                                        let _e356 = getSpiralIndex((_e351 + vec2<f32>(1f, 1f)));
                                        if (((_e337.x > (1f - _e340)) && (_e343.y > (1f - _e346))) && (abs((_e350 - _e356)) > 1f)) {
                                            {
                                                let _e362 = outColor;
                                                let _e363 = borderColor_1;
                                                let _e364 = mergeColor(_e362, _e363);
                                                outColor = _e364;
                                            }
                                        } else {
                                            let _e365 = mode_1;
                                            if (_e365 == 1i) {
                                                {
                                                    let _e368 = origUv;
                                                    let _e373 = border_1;
                                                    let _e375 = scale_3;
                                                    let _e380 = origUv;
                                                    let _e384 = border_1;
                                                    let _e386 = scale_3;
                                                    if ((_e368.x < (-1f + ((2f * _e373) / f32(_e375)))) || (_e380.x > (1f - ((2f * _e384) / f32(_e386))))) {
                                                        {
                                                            let _e392 = outColor;
                                                            let _e393 = borderColor_1;
                                                            let _e394 = mergeColor(_e392, _e393);
                                                            outColor = _e394;
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
    let _e395 = mode_1;
    if (_e395 == 2i) {
        {
            let _e398 = origUv;
            let _e403 = border_1;
            let _e405 = scale_3;
            let _e410 = origUv;
            let _e414 = border_1;
            let _e416 = scale_3;
            if ((_e398.x < (-1f + ((2f * _e403) / f32(_e405)))) || (_e410.x > (1f - ((2f * _e414) / f32(_e416))))) {
                {
                    let _e422 = outColor;
                    let _e423 = borderColor_1;
                    let _e424 = mergeColor(_e422, _e423);
                    outColor = _e424;
                }
            } else {
                let _e425 = orig2Uv;
                let _e430 = border_1;
                let _e432 = scale_3;
                let _e437 = orig2Uv;
                let _e441 = border_1;
                let _e443 = scale_3;
                if ((_e425.y < (-1f + ((2f * _e430) / f32(_e432)))) || (_e437.y > (1f - ((2f * _e441) / f32(_e443))))) {
                    {
                        let _e449 = outColor;
                        let _e450 = borderColor_1;
                        let _e451 = mergeColor(_e449, _e450);
                        outColor = _e451;
                    }
                }
            }
        }
    }
    let _e452 = source_specified_1;
    if (_e452 == 1i) {
        let _e455 = outPos_1;
        let _e459 = global.U[0];
        let _e462 = outPos_1;
        let _e471 = textureSample(t_source, samp, ((vec2<f32>((_e455.x / _e459.x), _e462.y) / vec2(2f)) + vec2(0.5f)));
        let _e472 = outColor;
        let _e473 = mergeColor(_e471, _e472);
        return _e473;
    } else {
        let _e474 = outColor;
        return _e474;
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
    let _e70 = global.U[5];
    let _e75 = global.U[6];
    let _e80 = global.U[7];
    let _e85 = global.U[8];
    let _e88 = global.U[9];
    let _e91 = global.U[10];
    let _e94 = global.U[11];
    let _e97 = global.U[12];
    let _e100 = global.U[13];
    let _e105 = global.U[14];
    let _e109 = global.U[15];
    let _e113 = global.U[16];
    let _e117 = global.U[17];
    let _e119 = squareSpiral((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), i32(_e80.x), _e85, _e88, _e91, _e94, _e97, i32(_e100.x), _e105.x, _e109.x, _e113.x, _e117.x);
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
