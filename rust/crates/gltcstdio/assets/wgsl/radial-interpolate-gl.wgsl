struct Params {
    U: array<vec4<f32>, 13>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn radialInterpolate(pos: vec2<f32>, outPos: vec2<f32>, thickness: f32, count: i32, balance: f32, len: f32, angle: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var thickness_1: f32;
    var count_1: i32;
    var balance_1: f32;
    var len_1: f32;
    var angle_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var thickn: f32;
    var ha: f32;
    var angleRange: f32;
    var u_2: vec2<f32>;
    var halfThickPos: f32;
    var phase: f32 = 0f;
    var center: vec2<f32> = vec2<f32>(0f, 0f);
    var i: i32 = 0i;
    var d: f32;
    var da: f32;
    var ang: f32;
    var index: f32;
    var ang1_: f32;
    var ang2_: f32;
    var pos1_: vec2<f32>;
    var col1_: vec4<f32>;
    var pos2_: vec2<f32>;
    var col2_: vec4<f32>;
    var ka: f32;
    var local: f32;
    var endAng: f32;
    var posH: vec2<f32>;
    var endAng_1: f32;
    var posH_1: vec2<f32>;
    var i_1: i32 = 1i;
    var d_1: f32;
    var da_1: f32;
    var ang_1: f32;
    var index_1: f32;
    var ang1_1: f32;
    var ang2_1: f32;
    var pos1_1: vec2<f32>;
    var col1_1: vec4<f32>;
    var pos2_1: vec2<f32>;
    var col2_1: vec4<f32>;
    var ka_1: f32;
    var local_1: f32;
    var endAng_2: f32;
    var posH_2: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    thickness_1 = thickness;
    count_1 = count;
    balance_1 = balance;
    len_1 = len;
    angle_1 = angle;
    modelTransform_1 = modelTransform;
    let _e22 = thickness_1;
    thickn = _e22;
    let _e24 = angle_1;
    ha = (_e24 / 2f);
    let _e28 = angle_1;
    let _e29 = count_1;
    angleRange = (_e28 / f32(_e29));
    let _e33 = modelTransform_1;
    let _e35 = pos_1;
    let _e36 = tf(_naga_inverse_3x3_f32(_e33), _e35);
    u_2 = _e36;
    let _e38 = angle_1;
    if (_e38 <= 6.2831855f) {
        {
            let _e42 = thickn;
            halfThickPos = (1f - (_e42 / 2f));
            loop {
                let _e55 = i;
                let _e56 = len_1;
                if !((_e55 < i32(ceil(_e56)))) {
                    break;
                }
                {
                    let _e64 = u_2;
                    let _e65 = center;
                    d = length((_e64 - _e65));
                    let _e69 = d;
                    let _e71 = thickn;
                    let _e74 = d;
                    if ((_e69 >= (1f - _e71)) && (_e74 <= 1f)) {
                        {
                            da = 0f;
                            let _e80 = d;
                            if (_e80 > 0f) {
                                {
                                    let _e83 = u_2;
                                    let _e85 = center;
                                    let _e88 = d;
                                    ang = acos(((_e83.x - _e85.x) / _e88));
                                    let _e92 = u_2;
                                    let _e94 = center;
                                    if ((_e92.y - _e94.y) < 0f) {
                                        let _e100 = ang;
                                        ang = (6.2831855f - _e100);
                                    }
                                    let _e102 = ang;
                                    let _e103 = phase;
                                    let _e108 = ha;
                                    ang = (_e102 + ((_e103 + 1.5707964f) + _e108));
                                    let _e111 = ang;
                                    let _e113 = (_e111 + 6.2831855f);
                                    ang = (_e113 - (floor((_e113 / 6.2831855f)) * 6.2831855f));
                                    let _e119 = ang;
                                    let _e120 = angle_1;
                                    if (_e119 <= _e120) {
                                        {
                                            let _e122 = angle_1;
                                            let _e123 = ang;
                                            ang = (_e122 - _e123);
                                            let _e125 = ang;
                                            let _e126 = angle_1;
                                            let _e128 = count_1;
                                            index = floor(((_e125 / _e126) * f32(_e128)));
                                            let _e133 = phase;
                                            let _e134 = ha;
                                            let _e136 = angleRange;
                                            let _e137 = index;
                                            ang1_ = ((_e133 - _e134) + (_e136 * _e137));
                                            let _e141 = phase;
                                            let _e142 = ha;
                                            let _e144 = angleRange;
                                            let _e145 = index;
                                            ang2_ = ((_e141 - _e142) + (_e144 * (_e145 + 1f)));
                                            let _e151 = modelTransform_1;
                                            let _e152 = center;
                                            let _e154 = d;
                                            let _e155 = ang1_;
                                            let _e159 = center;
                                            let _e161 = d;
                                            let _e162 = ang1_;
                                            let _e167 = tf(_e151, vec2<f32>((_e152.x - (_e154 * sin(_e155))), (_e159.y - (_e161 * cos(_e162)))));
                                            pos1_ = _e167;
                                            let _e169 = pos1_;
                                            let _e173 = global.U[0];
                                            let _e176 = pos1_;
                                            let _e185 = _mirror_wrap(((vec2<f32>((_e169.x / _e173.x), _e176.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e186 = textureSample(t_source, samp, _e185);
                                            col1_ = _e186;
                                            let _e188 = modelTransform_1;
                                            let _e189 = center;
                                            let _e191 = d;
                                            let _e192 = ang2_;
                                            let _e196 = center;
                                            let _e198 = d;
                                            let _e199 = ang2_;
                                            let _e204 = tf(_e188, vec2<f32>((_e189.x - (_e191 * sin(_e192))), (_e196.y - (_e198 * cos(_e199)))));
                                            pos2_ = _e204;
                                            let _e206 = pos2_;
                                            let _e210 = global.U[0];
                                            let _e213 = pos2_;
                                            let _e222 = _mirror_wrap(((vec2<f32>((_e206.x / _e210.x), _e213.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e223 = textureSample(t_source, samp, _e222);
                                            col2_ = _e223;
                                            let _e225 = ang;
                                            let _e226 = angleRange;
                                            let _e227 = index;
                                            let _e230 = angleRange;
                                            ka = ((_e225 - (_e226 * _e227)) / _e230);
                                            let _e233 = col1_;
                                            let _e234 = col2_;
                                            let _e236 = ka;
                                            let _e238 = ka;
                                            let _e241 = balance_1;
                                            return mix(_e233, _e234, vec4(mix((1f - _e236), _e238, (0.5f + (0.5f * _e241)))));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    let _e247 = phase;
                    let _e248 = ha;
                    let _e250 = i;
                    let _e251 = f32(_e250);
                    if ((_e251 - (floor((_e251 / 2f)) * 2f)) == 0f) {
                        let _e259 = angle_1;
                        local = _e259;
                    } else {
                        local = 0f;
                    }
                    let _e262 = local;
                    endAng = ((_e247 - _e248) + _e262);
                    let _e265 = center;
                    let _e267 = halfThickPos;
                    let _e268 = endAng;
                    let _e272 = center;
                    let _e274 = halfThickPos;
                    let _e275 = endAng;
                    posH = vec2<f32>((_e265.x - (_e267 * sin(_e268))), (_e272.y - (_e274 * cos(_e275))));
                    let _e282 = posH;
                    let _e284 = center;
                    center = ((2f * _e282) - _e284);
                    let _e286 = phase;
                    phase = (_e286 + 3.1415927f);
                }
                continuing {
                    let _e61 = i;
                    i = (_e61 + 1i);
                }
            }
            let _e289 = ha;
            endAng_1 = -(_e289);
            let _e292 = halfThickPos;
            let _e294 = endAng_1;
            let _e297 = halfThickPos;
            let _e299 = endAng_1;
            posH_1 = vec2<f32>((-(_e292) * sin(_e294)), (-(_e297) * cos(_e299)));
            let _e305 = posH_1;
            center = (2f * _e305);
            phase = 3.1415927f;
            loop {
                let _e310 = i_1;
                let _e311 = len_1;
                if !((_e310 < i32(ceil(_e311)))) {
                    break;
                }
                {
                    let _e319 = u_2;
                    let _e320 = center;
                    d_1 = length((_e319 - _e320));
                    let _e324 = d_1;
                    let _e326 = thickn;
                    let _e329 = d_1;
                    if ((_e324 >= (1f - _e326)) && (_e329 <= 1f)) {
                        {
                            da_1 = 0f;
                            let _e335 = d_1;
                            if (_e335 > 0f) {
                                {
                                    let _e338 = u_2;
                                    let _e340 = center;
                                    let _e343 = d_1;
                                    ang_1 = acos(((_e338.x - _e340.x) / _e343));
                                    let _e347 = u_2;
                                    let _e349 = center;
                                    if ((_e347.y - _e349.y) < 0f) {
                                        let _e355 = ang_1;
                                        ang_1 = (6.2831855f - _e355);
                                    }
                                    let _e357 = ang_1;
                                    let _e358 = phase;
                                    let _e363 = ha;
                                    ang_1 = (_e357 + ((_e358 + 1.5707964f) + _e363));
                                    let _e366 = ang_1;
                                    let _e368 = (_e366 + 6.2831855f);
                                    ang_1 = (_e368 - (floor((_e368 / 6.2831855f)) * 6.2831855f));
                                    let _e374 = ang_1;
                                    let _e375 = angle_1;
                                    if (_e374 <= _e375) {
                                        {
                                            let _e377 = angle_1;
                                            let _e378 = ang_1;
                                            ang_1 = (_e377 - _e378);
                                            let _e380 = ang_1;
                                            let _e381 = angle_1;
                                            let _e383 = count_1;
                                            index_1 = floor(((_e380 / _e381) * f32(_e383)));
                                            let _e388 = phase;
                                            let _e389 = ha;
                                            let _e391 = angleRange;
                                            let _e392 = index_1;
                                            ang1_1 = ((_e388 - _e389) + (_e391 * _e392));
                                            let _e396 = phase;
                                            let _e397 = ha;
                                            let _e399 = angleRange;
                                            let _e400 = index_1;
                                            ang2_1 = ((_e396 - _e397) + (_e399 * (_e400 + 1f)));
                                            let _e406 = modelTransform_1;
                                            let _e407 = center;
                                            let _e409 = d_1;
                                            let _e410 = ang1_1;
                                            let _e414 = center;
                                            let _e416 = d_1;
                                            let _e417 = ang1_1;
                                            let _e422 = tf(_e406, vec2<f32>((_e407.x - (_e409 * sin(_e410))), (_e414.y - (_e416 * cos(_e417)))));
                                            pos1_1 = _e422;
                                            let _e424 = pos1_1;
                                            let _e428 = global.U[0];
                                            let _e431 = pos1_1;
                                            let _e440 = _mirror_wrap(((vec2<f32>((_e424.x / _e428.x), _e431.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e441 = textureSample(t_source, samp, _e440);
                                            col1_1 = _e441;
                                            let _e443 = modelTransform_1;
                                            let _e444 = center;
                                            let _e446 = d_1;
                                            let _e447 = ang2_1;
                                            let _e451 = center;
                                            let _e453 = d_1;
                                            let _e454 = ang2_1;
                                            let _e459 = tf(_e443, vec2<f32>((_e444.x - (_e446 * sin(_e447))), (_e451.y - (_e453 * cos(_e454)))));
                                            pos2_1 = _e459;
                                            let _e461 = pos2_1;
                                            let _e465 = global.U[0];
                                            let _e468 = pos2_1;
                                            let _e477 = _mirror_wrap(((vec2<f32>((_e461.x / _e465.x), _e468.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e478 = textureSample(t_source, samp, _e477);
                                            col2_1 = _e478;
                                            let _e480 = ang_1;
                                            let _e481 = angleRange;
                                            let _e482 = index_1;
                                            let _e485 = angleRange;
                                            ka_1 = ((_e480 - (_e481 * _e482)) / _e485);
                                            let _e488 = col1_1;
                                            let _e489 = col2_1;
                                            let _e491 = ka_1;
                                            let _e493 = ka_1;
                                            let _e496 = balance_1;
                                            return mix(_e488, _e489, vec4(mix((1f - _e491), _e493, (0.5f + (0.5f * _e496)))));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    let _e502 = phase;
                    let _e503 = ha;
                    let _e505 = i_1;
                    let _e506 = f32(_e505);
                    if ((_e506 - (floor((_e506 / 2f)) * 2f)) == 1f) {
                        let _e514 = angle_1;
                        local_1 = _e514;
                    } else {
                        local_1 = 0f;
                    }
                    let _e517 = local_1;
                    endAng_2 = ((_e502 - _e503) + _e517);
                    let _e520 = center;
                    let _e522 = halfThickPos;
                    let _e523 = endAng_2;
                    let _e527 = center;
                    let _e529 = halfThickPos;
                    let _e530 = endAng_2;
                    posH_2 = vec2<f32>((_e520.x - (_e522 * sin(_e523))), (_e527.y - (_e529 * cos(_e530))));
                    let _e537 = posH_2;
                    let _e539 = center;
                    center = ((2f * _e537) - _e539);
                    let _e541 = phase;
                    phase = (_e541 + 3.1415927f);
                }
                continuing {
                    let _e316 = i_1;
                    i_1 = (_e316 + 1i);
                }
            }
        }
    }
    let _e544 = pos_1;
    let _e548 = global.U[0];
    let _e551 = pos_1;
    let _e560 = _mirror_wrap(((vec2<f32>((_e544.x / _e548.x), _e551.y) / vec2(2f)) + vec2(0.5f)));
    let _e561 = textureSample(t_source, samp, _e560);
    return _e561;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = radialInterpolate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
