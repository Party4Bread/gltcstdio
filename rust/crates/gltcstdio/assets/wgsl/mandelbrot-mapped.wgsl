struct Params {
    U: array<vec4<f32>, 21>,
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

fn complexLog(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e11 = u_1;
    let _e13 = u_1;
    return vec2<f32>(log(length(_e8)), atan2(_e11.y, _e13.x));
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

fn tf(m: mat3x3<f32>, u_2: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_3: vec2<f32>;

    m_1 = m;
    u_3 = u_2;
    let _e10 = m_1;
    let _e11 = u_3;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn mandelbrotMapped(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, mode: i32, shadows: f32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, texTransform: mat3x3<f32>, colorIn: vec4<f32>, iterations: i32, julianess: f32, power: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var mode_1: i32;
    var shadows_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var colorIn_1: vec4<f32>;
    var iterations_1: i32;
    var julianess_1: f32;
    var power_1: f32;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var uv: vec2<f32>;
    var t: vec2<f32>;
    var z0_: vec2<f32>;
    var z: vec2<f32>;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var inside: bool = true;
    var limitMode: i32;
    var baseMode: i32;
    var dLimit: f32 = 2f;
    var d2Limit: f32;
    var d: f32;
    var angle: f32;
    var dp: f32;
    var d_1: f32;
    var angle_1: f32;
    var dp_1: f32;
    var d_2: f32;
    var x: f32;
    var l: vec2<f32>;
    var y: f32;
    var w: vec2<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    mode_1 = mode;
    shadows_1 = shadows;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    texTransform_1 = texTransform;
    colorIn_1 = colorIn;
    iterations_1 = iterations;
    julianess_1 = julianess;
    power_1 = power;
    let _e30 = julianess_1;
    cj = cos(((_e30 * 3.1415927f) * 0.5f));
    let _e37 = julianess_1;
    sj = sin(((_e37 * 3.1415927f) * 0.5f));
    let _e44 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e44);
    let _e47 = invModelTransform;
    let _e48 = pos_1;
    let _e49 = tf(_e47, _e48);
    uv = _e49;
    let _e51 = cj;
    let _e52 = uv;
    let _e54 = sj;
    let _e57 = offsetTransform_1[2];
    t = ((_e51 * _e52) + (_e54 * _e57.xy));
    let _e62 = sj;
    let _e63 = uv;
    let _e65 = cj;
    let _e68 = offsetTransform_1[2];
    z0_ = ((_e62 * _e63) + (_e65 * _e68.xy));
    let _e73 = z0_;
    z = _e73;
    let _e75 = t;
    prev = _e75;
    let _e83 = mode_1;
    limitMode = (_e83 % 4i);
    let _e87 = mode_1;
    baseMode = (_e87 / 4i);
    let _e93 = limitMode;
    if (_e93 == 1i) {
        {
            dLimit = 4f;
        }
    } else {
        let _e97 = limitMode;
        if (_e97 == 2i) {
            {
                dLimit = 100f;
            }
        } else {
            let _e101 = limitMode;
            if (_e101 == 3i) {
                {
                    dLimit = 100000f;
                }
            }
        }
    }
    let _e105 = dLimit;
    let _e106 = dLimit;
    d2Limit = (_e105 * _e106);
    let _e109 = mode_1;
    if (_e109 == 20i) {
        {
            let _e112 = power_1;
            if (_e112 == 2f) {
                {
                    loop {
                        let _e115 = iter;
                        let _e116 = iterations_1;
                        if !((_e115 < _e116)) {
                            break;
                        }
                        {
                            let _e119 = iter;
                            iter = (_e119 + 1i);
                            let _e122 = z;
                            prev = _e122;
                            let _e124 = prev;
                            let _e126 = prev;
                            let _e129 = prev;
                            let _e131 = prev;
                            let _e135 = t;
                            z.x = (((_e124.x * _e126.x) - (_e129.y * _e131.y)) + _e135.x);
                            let _e140 = prev;
                            let _e143 = prev;
                            let _e146 = t;
                            z.y = (((2f * _e140.x) * _e143.y) + _e146.y);
                            let _e149 = z;
                            let _e150 = z;
                            d2_ = dot(_e149, _e150);
                        }
                    }
                }
            } else {
                let _e152 = power_1;
                if (_e152 == 3f) {
                    {
                        loop {
                            let _e155 = iter;
                            let _e156 = iterations_1;
                            if !((_e155 < _e156)) {
                                break;
                            }
                            {
                                let _e159 = iter;
                                iter = (_e159 + 1i);
                                let _e162 = z;
                                prev = _e162;
                                let _e164 = prev;
                                let _e166 = prev;
                                let _e169 = prev;
                                let _e173 = prev;
                                let _e176 = prev;
                                let _e179 = prev;
                                let _e183 = t;
                                z.x = ((((_e164.x * _e166.x) * _e169.x) - (((3f * _e173.y) * _e176.y) * _e179.x)) + _e183.x);
                                let _e187 = prev;
                                let _e190 = prev;
                                let _e193 = prev;
                                let _e197 = prev;
                                let _e200 = prev;
                                let _e203 = prev;
                                let _e207 = t;
                                z.y = ((((-(_e187.y) * _e190.y) * _e193.y) + (((3f * _e197.x) * _e200.x) * _e203.y)) + _e207.y);
                                let _e210 = z;
                                let _e211 = z;
                                d2_ = dot(_e210, _e211);
                            }
                        }
                    }
                } else {
                    {
                        let _e213 = z;
                        d = length(_e213);
                        loop {
                            let _e216 = iter;
                            let _e217 = iterations_1;
                            if !((_e216 < _e217)) {
                                break;
                            }
                            {
                                let _e220 = iter;
                                iter = (_e220 + 1i);
                                let _e223 = z;
                                prev = _e223;
                                let _e224 = prev;
                                let _e226 = prev;
                                angle = atan2(_e224.y, _e226.x);
                                let _e230 = d;
                                let _e231 = power_1;
                                dp = pow(_e230, _e231);
                                let _e235 = dp;
                                let _e236 = power_1;
                                let _e237 = angle;
                                let _e241 = t;
                                z.x = ((_e235 * cos((_e236 * _e237))) + _e241.x);
                                let _e245 = dp;
                                let _e246 = power_1;
                                let _e247 = angle;
                                let _e251 = t;
                                z.y = ((_e245 * sin((_e246 * _e247))) + _e251.y);
                            }
                        }
                    }
                }
            }
            let _e254 = texTransform_1;
            let _e256 = z;
            let _e257 = tf(_naga_inverse_3x3_f32(_e254), _e256);
            let _e261 = global.U[0];
            let _e264 = texTransform_1;
            let _e266 = z;
            let _e267 = tf(_naga_inverse_3x3_f32(_e264), _e266);
            let _e276 = textureSample(t_source, samp, ((vec2<f32>((_e257.x / _e261.x), _e267.y) / vec2(2f)) + vec2(0.5f)));
            return _e276;
        }
    }
    let _e277 = power_1;
    if (_e277 == 2f) {
        {
            loop {
                let _e280 = iter;
                let _e281 = iterations_1;
                if !((_e280 < _e281)) {
                    break;
                }
                {
                    let _e284 = iter;
                    iter = (_e284 + 1i);
                    let _e287 = z;
                    prev = _e287;
                    let _e289 = prev;
                    let _e291 = prev;
                    let _e294 = prev;
                    let _e296 = prev;
                    let _e300 = t;
                    z.x = (((_e289.x * _e291.x) - (_e294.y * _e296.y)) + _e300.x);
                    let _e305 = prev;
                    let _e308 = prev;
                    let _e311 = t;
                    z.y = (((2f * _e305.x) * _e308.y) + _e311.y);
                    let _e314 = z;
                    let _e315 = z;
                    d2_ = dot(_e314, _e315);
                    let _e317 = d2_;
                    let _e318 = d2Limit;
                    if (_e317 > _e318) {
                        {
                            inside = false;
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e321 = power_1;
        if (_e321 == 3f) {
            {
                loop {
                    let _e324 = iter;
                    let _e325 = iterations_1;
                    if !((_e324 < _e325)) {
                        break;
                    }
                    {
                        let _e328 = iter;
                        iter = (_e328 + 1i);
                        let _e331 = z;
                        prev = _e331;
                        let _e333 = prev;
                        let _e335 = prev;
                        let _e338 = prev;
                        let _e342 = prev;
                        let _e345 = prev;
                        let _e348 = prev;
                        let _e352 = t;
                        z.x = ((((_e333.x * _e335.x) * _e338.x) - (((3f * _e342.y) * _e345.y) * _e348.x)) + _e352.x);
                        let _e356 = prev;
                        let _e359 = prev;
                        let _e362 = prev;
                        let _e366 = prev;
                        let _e369 = prev;
                        let _e372 = prev;
                        let _e376 = t;
                        z.y = ((((-(_e356.y) * _e359.y) * _e362.y) + (((3f * _e366.x) * _e369.x) * _e372.y)) + _e376.y);
                        let _e379 = z;
                        let _e380 = z;
                        d2_ = dot(_e379, _e380);
                        let _e382 = d2_;
                        let _e383 = d2Limit;
                        if (_e382 > _e383) {
                            {
                                inside = false;
                                break;
                            }
                        }
                    }
                }
            }
        } else {
            {
                let _e386 = z;
                d_1 = length(_e386);
                loop {
                    let _e389 = iter;
                    let _e390 = iterations_1;
                    if !((_e389 < _e390)) {
                        break;
                    }
                    {
                        let _e393 = iter;
                        iter = (_e393 + 1i);
                        let _e396 = z;
                        prev = _e396;
                        let _e397 = prev;
                        let _e399 = prev;
                        angle_1 = atan2(_e397.y, _e399.x);
                        let _e403 = d_1;
                        let _e404 = power_1;
                        dp_1 = pow(_e403, _e404);
                        let _e408 = dp_1;
                        let _e409 = power_1;
                        let _e410 = angle_1;
                        let _e414 = t;
                        z.x = ((_e408 * cos((_e409 * _e410))) + _e414.x);
                        let _e418 = dp_1;
                        let _e419 = power_1;
                        let _e420 = angle_1;
                        let _e424 = t;
                        z.y = ((_e418 * sin((_e419 * _e420))) + _e424.y);
                        let _e427 = z;
                        d_1 = length(_e427);
                        let _e429 = d_1;
                        let _e430 = dLimit;
                        if (_e429 > _e430) {
                            {
                                inside = false;
                                break;
                            }
                        }
                    }
                }
                let _e433 = d_1;
                let _e434 = d_1;
                d2_ = (_e433 * _e434);
            }
        }
    }
    let _e436 = d2_;
    d_2 = sqrt(_e436);
    let _e440 = iter;
    let _e443 = d_2;
    x = ((1f + f32(_e440)) - (log(log(_e443)) / 0.6931472f));
    let _e451 = z;
    let _e452 = complexLog(_e451);
    l = _e452;
    let _e455 = l;
    y = (2f * _e455.y);
    let _e459 = z;
    w = _e459;
    let _e461 = baseMode;
    if (_e461 == 0i) {
        let _e464 = y;
        let _e467 = x;
        w = vec2<f32>((_e464 * 0.125f), _e467);
    } else {
        let _e469 = baseMode;
        if (_e469 == 1i) {
            let _e472 = y;
            let _e473 = l;
            let _e474 = complexLog(_e473);
            w = vec2<f32>(_e472, _e474.x);
        } else {
            let _e477 = baseMode;
            if (_e477 == 2i) {
                let _e480 = y;
                let _e481 = l;
                w = vec2<f32>(_e480, _e481.x);
            } else {
                let _e484 = baseMode;
                if (_e484 == 3i) {
                    let _e488 = t;
                    let _e489 = complexLog(_e488);
                    let _e492 = l;
                    let _e493 = complexLog(_e492);
                    w = vec2<f32>((2f * _e489.y), _e493.x);
                }
            }
        }
    }
    let _e497 = source_specified_1;
    if (_e497 == 1i) {
        let _e500 = texTransform_1;
        let _e502 = w;
        let _e503 = tf(_naga_inverse_3x3_f32(_e500), _e502);
        let _e507 = global.U[0];
        let _e510 = texTransform_1;
        let _e512 = w;
        let _e513 = tf(_naga_inverse_3x3_f32(_e510), _e512);
        let _e522 = textureSample(t_source, samp, ((vec2<f32>((_e503.x / _e507.x), _e513.y) / vec2(2f)) + vec2(0.5f)));
        outCol = _e522;
    } else {
        let _e523 = texTransform_1;
        let _e525 = w;
        let _e527 = tf(_naga_inverse_3x3_f32(_e523), fract(_e525));
        outCol = vec4<f32>(_e527.x, _e527.y, 0.5f, 1f);
    }
    let _e533 = shadows_1;
    if (_e533 > 0f) {
        {
            let _e536 = outCol;
            let _e537 = colorIn_1;
            let _e538 = x;
            let _e539 = iter;
            let _e542 = d2Limit;
            let _e544 = shadows_1;
            outCol = mix(_e536, _e537, vec4((((_e538 - f32(_e539)) * _e542) * _e544)));
        }
    }
    let _e548 = inside;
    if _e548 {
        let _e549 = outCol;
        let _e550 = colorIn_1;
        let _e551 = mergeColor(_e549, _e550);
        return _e551;
    } else {
        let _e552 = outCol;
        return _e552;
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
    let _e71 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e81 = _e80.xyz;
    let _e84 = global.U[9];
    let _e85 = _e84.xyz;
    let _e88 = global.U[10];
    let _e89 = _e88.xyz;
    let _e105 = global.U[11];
    let _e106 = _e105.xyz;
    let _e109 = global.U[12];
    let _e110 = _e109.xyz;
    let _e113 = global.U[13];
    let _e114 = _e113.xyz;
    let _e130 = global.U[14];
    let _e131 = _e130.xyz;
    let _e134 = global.U[15];
    let _e135 = _e134.xyz;
    let _e138 = global.U[16];
    let _e139 = _e138.xyz;
    let _e155 = global.U[17];
    let _e158 = global.U[18];
    let _e163 = global.U[19];
    let _e167 = global.U[20];
    let _e169 = mandelbrotMapped((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)), mat3x3<f32>(vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z), vec3<f32>(_e114.x, _e114.y, _e114.z)), mat3x3<f32>(vec3<f32>(_e131.x, _e131.y, _e131.z), vec3<f32>(_e135.x, _e135.y, _e135.z), vec3<f32>(_e139.x, _e139.y, _e139.z)), _e155, i32(_e158.x), _e163.x, _e167.x);
    fragColor = _e169;
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
