struct Params {
    U: array<vec4<f32>, 15>,
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

fn colorWeight(color: vec4<f32>, refColor: vec4<f32>, tolerance: f32) -> f32 {
    var color_1: vec4<f32>;
    var refColor_1: vec4<f32>;
    var tolerance_1: f32;
    var d: f32;
    var maxDistance: f32;

    color_1 = color;
    refColor_1 = refColor;
    tolerance_1 = tolerance;
    let _e12 = color_1;
    let _e14 = refColor_1;
    d = length((_e12.xyz - _e14.xyz));
    let _e19 = tolerance_1;
    maxDistance = (_e19 * 1.7320508f);
    let _e23 = maxDistance;
    let _e24 = maxDistance;
    let _e27 = d;
    return smoothstep(_e23, (_e24 * 0.5f), _e27);
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

fn ghosting(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, iterations: i32, tolerance_2: f32, vignetting: f32, dampening: f32, color_2: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var iterations_1: i32;
    var tolerance_3: f32;
    var vignetting_1: f32;
    var dampening_1: f32;
    var color_3: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalWeight: f32 = 0f;
    var delta: vec2<f32>;
    var radius: f32;
    var outColor: vec4<f32>;
    var p: vec2<f32>;
    var i: i32 = 0i;
    var color_4: vec4<f32>;
    var local: f32;
    var centrality: f32;
    var local_1: f32;
    var weight: f32;
    var i_1: i32 = 0i;
    var color_5: vec4<f32>;
    var local_2: f32;
    var centrality_1: f32;
    var local_3: vec4<f32>;
    var i_2: i32 = 0i;
    var color_6: vec4<f32>;
    var local_4: f32;
    var centrality_2: f32;
    var local_5: vec4<f32>;
    var i_3: i32 = 0i;
    var col: vec4<f32>;
    var local_6: f32;
    var centrality_3: f32;
    var local_7: f32;
    var weight_1: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    iterations_1 = iterations;
    tolerance_3 = tolerance_2;
    vignetting_1 = vignetting;
    dampening_1 = dampening;
    color_3 = color_2;
    modelTransform_1 = modelTransform;
    let _e26 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e26);
    let _e29 = inverseModelTransform;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    u_2 = _e31;
    let _e41 = u_2;
    let _e42 = uv_1;
    let _e44 = iterations_1;
    delta = ((_e41 - _e42) / vec2(f32(_e44)));
    let _e50 = sourceDim_1;
    let _e52 = sourceDim_1;
    radius = (min(1f, (_e50.x / _e52.y)) * 1.1f);
    let _e60 = uv_1;
    p = _e60;
    let _e62 = mode_1;
    if (_e62 == 0i) {
        {
            loop {
                let _e67 = i;
                let _e68 = iterations_1;
                if !((_e67 < _e68)) {
                    break;
                }
                {
                    let _e74 = p;
                    let _e78 = global.U[0];
                    let _e81 = p;
                    let _e90 = _mirror_wrap(((vec2<f32>((_e74.x / _e78.x), _e81.y) / vec2(2f)) + vec2(0.5f)));
                    let _e91 = textureSample(t_source, samp, _e90);
                    color_4 = _e91;
                    let _e93 = vignetting_1;
                    if (_e93 == 0f) {
                        local = 1f;
                    } else {
                        let _e97 = radius;
                        let _e98 = vignetting_1;
                        let _e100 = radius;
                        let _e103 = p;
                        local = smoothstep((_e97 / _e98), (_e100 * 0.6f), length(_e103));
                    }
                    let _e107 = local;
                    centrality = _e107;
                    let _e109 = i;
                    if (_e109 == 0i) {
                        local_1 = 1f;
                    } else {
                        let _e114 = dampening_1;
                        let _e116 = i;
                        let _e118 = iterations_1;
                        let _e124 = centrality;
                        local_1 = (pow((1f - _e114), (f32(_e116) / f32((_e118 - 1i)))) * _e124);
                    }
                    let _e127 = local_1;
                    weight = _e127;
                    let _e129 = totalColor;
                    let _e130 = weight;
                    let _e131 = color_4;
                    totalColor = (_e129 + (_e130 * _e131));
                    let _e134 = totalWeight;
                    let _e135 = weight;
                    totalWeight = (_e134 + _e135);
                    let _e137 = p;
                    let _e138 = delta;
                    p = (_e137 + _e138);
                }
                continuing {
                    let _e71 = i;
                    i = (_e71 + 1i);
                }
            }
            let _e140 = totalColor;
            let _e141 = totalWeight;
            outColor = (_e140 / vec4(_e141));
        }
    } else {
        let _e144 = mode_1;
        if (_e144 == 1i) {
            {
                loop {
                    let _e149 = i_1;
                    let _e150 = iterations_1;
                    if !((_e149 < _e150)) {
                        break;
                    }
                    {
                        let _e156 = p;
                        let _e160 = global.U[0];
                        let _e163 = p;
                        let _e172 = _mirror_wrap(((vec2<f32>((_e156.x / _e160.x), _e163.y) / vec2(2f)) + vec2(0.5f)));
                        let _e173 = textureSample(t_source, samp, _e172);
                        color_5 = _e173;
                        let _e175 = i_1;
                        if (_e175 == 0i) {
                            let _e178 = color_5;
                            totalColor = _e178;
                        } else {
                            {
                                let _e179 = color_5;
                                let _e181 = color_5;
                                let _e184 = color_5;
                                let _e188 = dampening_1;
                                let _e190 = i_1;
                                let _e192 = iterations_1;
                                let _e198 = totalColor;
                                let _e200 = totalColor;
                                let _e203 = totalColor;
                                if (((_e179.x + _e181.y) + _e184.z) >= (pow((1f - _e188), (f32(_e190) / f32((_e192 - 1i)))) * ((_e198.x + _e200.y) + _e203.z))) {
                                    let _e208 = color_5;
                                    totalColor = _e208;
                                }
                            }
                        }
                        let _e209 = vignetting_1;
                        if (_e209 == 0f) {
                            local_2 = 1f;
                        } else {
                            let _e213 = radius;
                            let _e214 = vignetting_1;
                            let _e216 = radius;
                            let _e219 = p;
                            local_2 = smoothstep((_e213 / _e214), (_e216 * 0.6f), length(_e219));
                        }
                        let _e223 = local_2;
                        centrality_1 = _e223;
                        let _e225 = i_1;
                        if (_e225 == 0i) {
                            let _e228 = totalColor;
                            local_3 = _e228;
                        } else {
                            let _e229 = outColor;
                            let _e230 = totalColor;
                            let _e231 = centrality_1;
                            local_3 = mix(_e229, _e230, vec4(_e231));
                        }
                        let _e235 = local_3;
                        outColor = _e235;
                        let _e236 = p;
                        let _e237 = delta;
                        p = (_e236 + _e237);
                    }
                    continuing {
                        let _e153 = i_1;
                        i_1 = (_e153 + 1i);
                    }
                }
            }
        } else {
            let _e239 = mode_1;
            if (_e239 == 2i) {
                {
                    loop {
                        let _e244 = i_2;
                        let _e245 = iterations_1;
                        if !((_e244 < _e245)) {
                            break;
                        }
                        {
                            let _e251 = p;
                            let _e255 = global.U[0];
                            let _e258 = p;
                            let _e267 = _mirror_wrap(((vec2<f32>((_e251.x / _e255.x), _e258.y) / vec2(2f)) + vec2(0.5f)));
                            let _e268 = textureSample(t_source, samp, _e267);
                            color_6 = _e268;
                            let _e270 = i_2;
                            if (_e270 == 0i) {
                                let _e273 = color_6;
                                totalColor = _e273;
                            } else {
                                {
                                    let _e274 = color_6;
                                    let _e276 = color_6;
                                    let _e279 = color_6;
                                    let _e283 = dampening_1;
                                    let _e285 = i_2;
                                    let _e287 = iterations_1;
                                    let _e293 = totalColor;
                                    let _e295 = totalColor;
                                    let _e298 = totalColor;
                                    if (((_e274.x + _e276.y) + _e279.z) <= (pow((1f - _e283), (f32(_e285) / f32((_e287 - 1i)))) * ((_e293.x + _e295.y) + _e298.z))) {
                                        let _e303 = color_6;
                                        totalColor = _e303;
                                    }
                                }
                            }
                            let _e304 = vignetting_1;
                            if (_e304 == 0f) {
                                local_4 = 1f;
                            } else {
                                let _e308 = radius;
                                let _e309 = vignetting_1;
                                let _e311 = radius;
                                let _e314 = p;
                                local_4 = smoothstep((_e308 / _e309), (_e311 * 0.6f), length(_e314));
                            }
                            let _e318 = local_4;
                            centrality_2 = _e318;
                            let _e320 = i_2;
                            if (_e320 == 0i) {
                                let _e323 = totalColor;
                                local_5 = _e323;
                            } else {
                                let _e324 = outColor;
                                let _e325 = totalColor;
                                let _e326 = centrality_2;
                                local_5 = mix(_e324, _e325, vec4(_e326));
                            }
                            let _e330 = local_5;
                            outColor = _e330;
                            let _e331 = p;
                            let _e332 = delta;
                            p = (_e331 + _e332);
                        }
                        continuing {
                            let _e248 = i_2;
                            i_2 = (_e248 + 1i);
                        }
                    }
                }
            } else {
                {
                    loop {
                        let _e336 = i_3;
                        let _e337 = iterations_1;
                        if !((_e336 < _e337)) {
                            break;
                        }
                        {
                            let _e343 = p;
                            let _e347 = global.U[0];
                            let _e350 = p;
                            let _e359 = _mirror_wrap(((vec2<f32>((_e343.x / _e347.x), _e350.y) / vec2(2f)) + vec2(0.5f)));
                            let _e360 = textureSample(t_source, samp, _e359);
                            col = _e360;
                            let _e362 = vignetting_1;
                            if (_e362 == 0f) {
                                local_6 = 1f;
                            } else {
                                let _e366 = radius;
                                let _e367 = vignetting_1;
                                let _e369 = radius;
                                let _e372 = p;
                                local_6 = smoothstep((_e366 / _e367), (_e369 * 0.6f), length(_e372));
                            }
                            let _e376 = local_6;
                            centrality_3 = _e376;
                            let _e378 = i_3;
                            if (_e378 == 0i) {
                                local_7 = 1f;
                            } else {
                                let _e383 = dampening_1;
                                let _e385 = i_3;
                                let _e387 = iterations_1;
                                let _e393 = centrality_3;
                                let _e395 = col;
                                let _e396 = color_3;
                                let _e397 = tolerance_3;
                                let _e398 = colorWeight(_e395, _e396, _e397);
                                local_7 = ((pow((1f - _e383), (f32(_e385) / f32((_e387 - 1i)))) * _e393) * _e398);
                            }
                            let _e401 = local_7;
                            weight_1 = _e401;
                            let _e403 = totalColor;
                            let _e404 = weight_1;
                            let _e405 = col;
                            totalColor = (_e403 + (_e404 * _e405));
                            let _e408 = totalWeight;
                            let _e409 = weight_1;
                            totalWeight = (_e408 + _e409);
                            let _e411 = p;
                            let _e412 = delta;
                            p = (_e411 + _e412);
                        }
                        continuing {
                            let _e340 = i_3;
                            i_3 = (_e340 + 1i);
                        }
                    }
                    let _e414 = totalColor;
                    let _e415 = totalWeight;
                    outColor = (_e414 / vec4(_e415));
                }
            }
        }
    }
    let _e418 = outColor;
    return _e418;
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
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e99 = global.U[13];
    let _e100 = _e99.xyz;
    let _e103 = global.U[14];
    let _e104 = _e103.xyz;
    let _e118 = ghosting((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), i32(_e75.x), _e80.x, _e84.x, _e88.x, _e92, mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)));
    fragColor = _e118;
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
