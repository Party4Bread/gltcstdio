struct Params {
    U: array<vec4<f32>, 19>,
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

fn rotation2_(angle: f32) -> mat2x2<f32> {
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
    let _e16 = sa;
    let _e18 = ca;
    return mat2x2<f32>(vec2<f32>(_e14, _e15), vec2<f32>(-(_e16), _e18));
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

fn mandelbrotFeather(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, iterations: i32, dampening: f32, balance: f32, julianess: f32, power: f32, colorIn: vec4<f32>, colorOut: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var iterations_1: i32;
    var dampening_1: f32;
    var balance_1: f32;
    var julianess_1: f32;
    var power_1: f32;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var uv: vec2<f32>;
    var t: vec2<f32>;
    var z0_: vec2<f32>;
    var z: vec2<f32>;
    var w: vec2<f32>;
    var escape: f32 = 0f;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var d: f32;
    var angle_2: f32;
    var dp: f32;
    var angle_3: f32 = 0f;
    var d_1: f32;
    var ty: f32;
    var grey: f32;
    var color: vec4<f32>;
    var kIter: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    iterations_1 = iterations;
    dampening_1 = dampening;
    balance_1 = balance;
    julianess_1 = julianess;
    power_1 = power;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
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
    let _e78 = t;
    prev = _e78;
    let _e84 = power_1;
    if (_e84 == 2f) {
        {
            loop {
                let _e87 = iter;
                let _e88 = iterations_1;
                if !((_e87 < _e88)) {
                    break;
                }
                {
                    let _e91 = iter;
                    iter = (_e91 + 1i);
                    let _e94 = z;
                    prev = _e94;
                    let _e96 = prev;
                    let _e98 = prev;
                    let _e101 = prev;
                    let _e103 = prev;
                    let _e107 = t;
                    z.x = (((_e96.x * _e98.x) - (_e101.y * _e103.y)) + _e107.x);
                    let _e112 = prev;
                    let _e115 = prev;
                    let _e118 = t;
                    z.y = (((2f * _e112.x) * _e115.y) + _e118.y);
                    let _e121 = z;
                    let _e122 = z;
                    d2_ = dot(_e121, _e122);
                    let _e124 = iter;
                    let _e126 = balance_1;
                    let _e130 = rotation2_(((f32(_e124) * _e126) * 6.2831855f));
                    let _e131 = z;
                    w = (_e130 * _e131);
                    let _e133 = w;
                    if (_e133.y > 5f) {
                        {
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e137 = power_1;
        if (_e137 == 3f) {
            {
                loop {
                    let _e140 = iter;
                    let _e141 = iterations_1;
                    if !((_e140 < _e141)) {
                        break;
                    }
                    {
                        let _e144 = iter;
                        iter = (_e144 + 1i);
                        let _e147 = z;
                        prev = _e147;
                        let _e149 = prev;
                        let _e151 = prev;
                        let _e154 = prev;
                        let _e158 = prev;
                        let _e161 = prev;
                        let _e164 = prev;
                        let _e168 = t;
                        z.x = ((((_e149.x * _e151.x) * _e154.x) - (((3f * _e158.y) * _e161.y) * _e164.x)) + _e168.x);
                        let _e172 = prev;
                        let _e175 = prev;
                        let _e178 = prev;
                        let _e182 = prev;
                        let _e185 = prev;
                        let _e188 = prev;
                        let _e192 = t;
                        z.y = ((((-(_e172.y) * _e175.y) * _e178.y) + (((3f * _e182.x) * _e185.x) * _e188.y)) + _e192.y);
                        let _e195 = z;
                        let _e196 = z;
                        d2_ = dot(_e195, _e196);
                        let _e198 = iter;
                        let _e200 = balance_1;
                        let _e204 = rotation2_(((f32(_e198) * _e200) * 6.2831855f));
                        let _e205 = z;
                        w = (_e204 * _e205);
                        let _e207 = w;
                        if (_e207.y > 5f) {
                            {
                                break;
                            }
                        }
                    }
                }
                let _e211 = z;
                w = _e211;
            }
        } else {
            {
                let _e212 = z;
                d = length(_e212);
                loop {
                    let _e215 = iter;
                    let _e216 = iterations_1;
                    if !((_e215 < _e216)) {
                        break;
                    }
                    {
                        let _e219 = iter;
                        iter = (_e219 + 1i);
                        let _e222 = z;
                        prev = _e222;
                        let _e223 = prev;
                        let _e225 = prev;
                        angle_2 = atan2(_e223.y, _e225.x);
                        let _e229 = d;
                        let _e230 = power_1;
                        dp = pow(_e229, _e230);
                        let _e234 = dp;
                        let _e235 = power_1;
                        let _e236 = angle_2;
                        let _e240 = t;
                        z.x = ((_e234 * cos((_e235 * _e236))) + _e240.x);
                        let _e244 = dp;
                        let _e245 = power_1;
                        let _e246 = angle_2;
                        let _e250 = t;
                        z.y = ((_e244 * sin((_e245 * _e246))) + _e250.y);
                        let _e253 = z;
                        d = length(_e253);
                        let _e255 = iter;
                        let _e257 = balance_1;
                        let _e261 = rotation2_(((f32(_e255) * _e257) * 6.2831855f));
                        let _e262 = z;
                        w = (_e261 * _e262);
                        let _e264 = w;
                        if (_e264.y > 5f) {
                            {
                                break;
                            }
                        }
                    }
                }
                let _e268 = z;
                w = _e268;
                let _e269 = d;
                let _e270 = d;
                d2_ = (_e269 * _e270);
            }
        }
    }
    let _e274 = d2_;
    d_1 = sqrt(_e274);
    let _e278 = iter;
    let _e281 = d_1;
    let _e284 = power_1;
    ty = ((1f + f32(_e278)) - (log(log(_e281)) / log(_e284)));
    let _e290 = ty;
    grey = (1f / _e290);
    let _e294 = iter;
    let _e295 = iterations_1;
    if (_e294 == _e295) {
        {
            let _e297 = w;
            grey = abs(_e297.y);
            let _e300 = colorIn_1;
            color = _e300;
        }
    } else {
        {
            let _e302 = w;
            let _e310 = iter;
            grey = ((1f / pow(_e302.y, 0.25f)) + (0.75f * (1f - pow(0.9f, f32(_e310)))));
            let _e316 = dampening_1;
            if (_e316 > 0f) {
                {
                    let _e319 = iterations_1;
                    let _e322 = iter;
                    let _e325 = iterations_1;
                    kIter = (f32(((_e319 - 1i) - _e322)) / f32(_e325));
                    let _e329 = kIter;
                    let _e330 = dampening_1;
                    if (_e329 < _e330) {
                        let _e332 = grey;
                        let _e333 = kIter;
                        let _e334 = dampening_1;
                        grey = (_e332 * (_e333 / _e334));
                    }
                }
            }
            let _e337 = colorOut_1;
            color = _e337;
        }
    }
    let _e338 = source_specified_1;
    if (_e338 == 0i) {
        let _e341 = grey;
        let _e342 = color;
        let _e346 = ((_e341 * _e342.xyz) * 2f);
        let _e347 = color;
        return vec4<f32>(_e346.x, _e346.y, _e346.z, _e347.w);
    } else {
        let _e354 = grey;
        let _e363 = global.U[0];
        let _e367 = grey;
        let _e381 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(0f, ((_e354 * 2f) - 1f)).x / _e363.x), vec2<f32>(0f, ((_e367 * 2f) - 1f)).y) / vec2(2f)) + vec2(0.5f)));
        return _e381;
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
    let _e72 = _e71.xyz;
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e96 = global.U[9];
    let _e97 = _e96.xyz;
    let _e100 = global.U[10];
    let _e101 = _e100.xyz;
    let _e104 = global.U[11];
    let _e105 = _e104.xyz;
    let _e121 = global.U[12];
    let _e126 = global.U[13];
    let _e130 = global.U[14];
    let _e134 = global.U[15];
    let _e138 = global.U[16];
    let _e142 = global.U[17];
    let _e145 = global.U[18];
    let _e146 = mandelbrotFeather((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), i32(_e121.x), _e126.x, _e130.x, _e134.x, _e138.x, _e142, _e145);
    fragColor = _e146;
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
