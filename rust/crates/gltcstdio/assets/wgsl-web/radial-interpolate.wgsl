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
                                            let _e187 = textureSampleLevel(t_source, samp, _e185, 0f);
                                            col1_ = _e187;
                                            let _e189 = modelTransform_1;
                                            let _e190 = center;
                                            let _e192 = d;
                                            let _e193 = ang2_;
                                            let _e197 = center;
                                            let _e199 = d;
                                            let _e200 = ang2_;
                                            let _e205 = tf(_e189, vec2<f32>((_e190.x - (_e192 * sin(_e193))), (_e197.y - (_e199 * cos(_e200)))));
                                            pos2_ = _e205;
                                            let _e207 = pos2_;
                                            let _e211 = global.U[0];
                                            let _e214 = pos2_;
                                            let _e223 = _mirror_wrap(((vec2<f32>((_e207.x / _e211.x), _e214.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e225 = textureSampleLevel(t_source, samp, _e223, 0f);
                                            col2_ = _e225;
                                            let _e227 = ang;
                                            let _e228 = angleRange;
                                            let _e229 = index;
                                            let _e232 = angleRange;
                                            ka = ((_e227 - (_e228 * _e229)) / _e232);
                                            let _e235 = col1_;
                                            let _e236 = col2_;
                                            let _e238 = ka;
                                            let _e240 = ka;
                                            let _e243 = balance_1;
                                            return mix(_e235, _e236, vec4(mix((1f - _e238), _e240, (0.5f + (0.5f * _e243)))));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    let _e249 = phase;
                    let _e250 = ha;
                    let _e252 = i;
                    let _e253 = f32(_e252);
                    if ((_e253 - (floor((_e253 / 2f)) * 2f)) == 0f) {
                        let _e261 = angle_1;
                        local = _e261;
                    } else {
                        local = 0f;
                    }
                    let _e264 = local;
                    endAng = ((_e249 - _e250) + _e264);
                    let _e267 = center;
                    let _e269 = halfThickPos;
                    let _e270 = endAng;
                    let _e274 = center;
                    let _e276 = halfThickPos;
                    let _e277 = endAng;
                    posH = vec2<f32>((_e267.x - (_e269 * sin(_e270))), (_e274.y - (_e276 * cos(_e277))));
                    let _e284 = posH;
                    let _e286 = center;
                    center = ((2f * _e284) - _e286);
                    let _e288 = phase;
                    phase = (_e288 + 3.1415927f);
                }
                continuing {
                    let _e61 = i;
                    i = (_e61 + 1i);
                }
            }
            let _e291 = ha;
            endAng_1 = -(_e291);
            let _e294 = halfThickPos;
            let _e296 = endAng_1;
            let _e299 = halfThickPos;
            let _e301 = endAng_1;
            posH_1 = vec2<f32>((-(_e294) * sin(_e296)), (-(_e299) * cos(_e301)));
            let _e307 = posH_1;
            center = (2f * _e307);
            phase = 3.1415927f;
            loop {
                let _e312 = i_1;
                let _e313 = len_1;
                if !((_e312 < i32(ceil(_e313)))) {
                    break;
                }
                {
                    let _e321 = u_2;
                    let _e322 = center;
                    d_1 = length((_e321 - _e322));
                    let _e326 = d_1;
                    let _e328 = thickn;
                    let _e331 = d_1;
                    if ((_e326 >= (1f - _e328)) && (_e331 <= 1f)) {
                        {
                            da_1 = 0f;
                            let _e337 = d_1;
                            if (_e337 > 0f) {
                                {
                                    let _e340 = u_2;
                                    let _e342 = center;
                                    let _e345 = d_1;
                                    ang_1 = acos(((_e340.x - _e342.x) / _e345));
                                    let _e349 = u_2;
                                    let _e351 = center;
                                    if ((_e349.y - _e351.y) < 0f) {
                                        let _e357 = ang_1;
                                        ang_1 = (6.2831855f - _e357);
                                    }
                                    let _e359 = ang_1;
                                    let _e360 = phase;
                                    let _e365 = ha;
                                    ang_1 = (_e359 + ((_e360 + 1.5707964f) + _e365));
                                    let _e368 = ang_1;
                                    let _e370 = (_e368 + 6.2831855f);
                                    ang_1 = (_e370 - (floor((_e370 / 6.2831855f)) * 6.2831855f));
                                    let _e376 = ang_1;
                                    let _e377 = angle_1;
                                    if (_e376 <= _e377) {
                                        {
                                            let _e379 = angle_1;
                                            let _e380 = ang_1;
                                            ang_1 = (_e379 - _e380);
                                            let _e382 = ang_1;
                                            let _e383 = angle_1;
                                            let _e385 = count_1;
                                            index_1 = floor(((_e382 / _e383) * f32(_e385)));
                                            let _e390 = phase;
                                            let _e391 = ha;
                                            let _e393 = angleRange;
                                            let _e394 = index_1;
                                            ang1_1 = ((_e390 - _e391) + (_e393 * _e394));
                                            let _e398 = phase;
                                            let _e399 = ha;
                                            let _e401 = angleRange;
                                            let _e402 = index_1;
                                            ang2_1 = ((_e398 - _e399) + (_e401 * (_e402 + 1f)));
                                            let _e408 = modelTransform_1;
                                            let _e409 = center;
                                            let _e411 = d_1;
                                            let _e412 = ang1_1;
                                            let _e416 = center;
                                            let _e418 = d_1;
                                            let _e419 = ang1_1;
                                            let _e424 = tf(_e408, vec2<f32>((_e409.x - (_e411 * sin(_e412))), (_e416.y - (_e418 * cos(_e419)))));
                                            pos1_1 = _e424;
                                            let _e426 = pos1_1;
                                            let _e430 = global.U[0];
                                            let _e433 = pos1_1;
                                            let _e442 = _mirror_wrap(((vec2<f32>((_e426.x / _e430.x), _e433.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e444 = textureSampleLevel(t_source, samp, _e442, 0f);
                                            col1_1 = _e444;
                                            let _e446 = modelTransform_1;
                                            let _e447 = center;
                                            let _e449 = d_1;
                                            let _e450 = ang2_1;
                                            let _e454 = center;
                                            let _e456 = d_1;
                                            let _e457 = ang2_1;
                                            let _e462 = tf(_e446, vec2<f32>((_e447.x - (_e449 * sin(_e450))), (_e454.y - (_e456 * cos(_e457)))));
                                            pos2_1 = _e462;
                                            let _e464 = pos2_1;
                                            let _e468 = global.U[0];
                                            let _e471 = pos2_1;
                                            let _e480 = _mirror_wrap(((vec2<f32>((_e464.x / _e468.x), _e471.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e482 = textureSampleLevel(t_source, samp, _e480, 0f);
                                            col2_1 = _e482;
                                            let _e484 = ang_1;
                                            let _e485 = angleRange;
                                            let _e486 = index_1;
                                            let _e489 = angleRange;
                                            ka_1 = ((_e484 - (_e485 * _e486)) / _e489);
                                            let _e492 = col1_1;
                                            let _e493 = col2_1;
                                            let _e495 = ka_1;
                                            let _e497 = ka_1;
                                            let _e500 = balance_1;
                                            return mix(_e492, _e493, vec4(mix((1f - _e495), _e497, (0.5f + (0.5f * _e500)))));
                                        }
                                    }
                                }
                            }
                        }
                    }
                    let _e506 = phase;
                    let _e507 = ha;
                    let _e509 = i_1;
                    let _e510 = f32(_e509);
                    if ((_e510 - (floor((_e510 / 2f)) * 2f)) == 1f) {
                        let _e518 = angle_1;
                        local_1 = _e518;
                    } else {
                        local_1 = 0f;
                    }
                    let _e521 = local_1;
                    endAng_2 = ((_e506 - _e507) + _e521);
                    let _e524 = center;
                    let _e526 = halfThickPos;
                    let _e527 = endAng_2;
                    let _e531 = center;
                    let _e533 = halfThickPos;
                    let _e534 = endAng_2;
                    posH_2 = vec2<f32>((_e524.x - (_e526 * sin(_e527))), (_e531.y - (_e533 * cos(_e534))));
                    let _e541 = posH_2;
                    let _e543 = center;
                    center = ((2f * _e541) - _e543);
                    let _e545 = phase;
                    phase = (_e545 + 3.1415927f);
                }
                continuing {
                    let _e318 = i_1;
                    i_1 = (_e318 + 1i);
                }
            }
        }
    }
    let _e548 = pos_1;
    let _e552 = global.U[0];
    let _e555 = pos_1;
    let _e564 = _mirror_wrap(((vec2<f32>((_e548.x / _e552.x), _e555.y) / vec2(2f)) + vec2(0.5f)));
    let _e566 = textureSampleLevel(t_source, samp, _e564, 0f);
    return _e566;
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
