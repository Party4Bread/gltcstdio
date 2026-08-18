struct Params {
    U: array<vec4<f32>, 25>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e9 = m_1;
    let _e10 = u_1;
    return (_e9 * vec3<f32>(_e10.x, _e10.y, 1f)).xy;
}

fn orbit(z: vec2<f32>, orbitSize: f32, t: mat3x3<f32>, type_18: i32) -> f32 {
    var z_1: vec2<f32>;
    var orbitSize_1: f32;
    var t_1: mat3x3<f32>;
    var type_19: i32;
    var tz: vec2<f32>;

    z_1 = z;
    orbitSize_1 = orbitSize;
    t_1 = t;
    type_19 = type_18;
    let _e13 = t_1;
    let _e14 = z_1;
    let _e15 = tf(_e13, _e14);
    tz = _e15;
    let _e17 = type_19;
    if (_e17 == 0i) {
        let _e20 = tz;
        return length(_e20);
    } else {
        let _e22 = type_19;
        if (_e22 == 1i) {
            let _e25 = tz;
            let _e27 = orbitSize_1;
            return abs((length(_e25) - _e27));
        } else {
            let _e30 = type_19;
            if (_e30 == 2i) {
                let _e33 = tz;
                return abs(_e33.y);
            } else {
                let _e36 = tz;
                let _e39 = tz;
                let _e43 = orbitSize_1;
                return abs((max(abs(_e36.x), abs(_e39.y)) - _e43));
            }
        }
    }
}

fn pointOrbit(z_2: vec2<f32>, a: vec2<f32>) -> f32 {
    var z_3: vec2<f32>;
    var a_1: vec2<f32>;

    z_3 = z_2;
    a_1 = a;
    let _e9 = z_3;
    let _e10 = a_1;
    return length((_e9 - _e10));
}

fn mandelbrotOrbits(pos: vec2<f32>, outPos: vec2<f32>, mode: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, transformRed: mat3x3<f32>, transformGreen: mat3x3<f32>, transformBlue: mat3x3<f32>, iterations: i32, orbitSize_2: f32, julianess: f32, power: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var mode_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var transformRed_1: mat3x3<f32>;
    var transformGreen_1: mat3x3<f32>;
    var transformBlue_1: mat3x3<f32>;
    var iterations_1: i32;
    var orbitSize_3: f32;
    var julianess_1: f32;
    var power_1: f32;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var tR: mat3x3<f32>;
    var tG: mat3x3<f32>;
    var tB: mat3x3<f32>;
    var modeR: i32;
    var modeG: i32;
    var modeB: i32;
    var uv: vec2<f32>;
    var t_2: vec2<f32>;
    var z0_: vec2<f32>;
    var z_4: vec2<f32>;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var outside: bool = true;
    var distR: f32 = 100000000000000000000f;
    var distG: f32 = 100000000000000000000f;
    var distB: f32 = 100000000000000000000f;
    var d: f32;
    var angle: f32;
    var dp: f32;
    var angle_1: f32 = 0f;
    var d_1: f32;
    var ty: f32;
    var grey: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    mode_1 = mode;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    transformRed_1 = transformRed;
    transformGreen_1 = transformGreen;
    transformBlue_1 = transformBlue;
    iterations_1 = iterations;
    orbitSize_3 = orbitSize_2;
    julianess_1 = julianess;
    power_1 = power;
    let _e29 = julianess_1;
    cj = cos(((_e29 * 3.1415927f) * 0.5f));
    let _e36 = julianess_1;
    sj = sin(((_e36 * 3.1415927f) * 0.5f));
    let _e43 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e43);
    let _e46 = transformRed_1;
    tR = _naga_inverse_3x3_f32(_e46);
    let _e49 = transformGreen_1;
    tG = _naga_inverse_3x3_f32(_e49);
    let _e52 = transformBlue_1;
    tB = _naga_inverse_3x3_f32(_e52);
    let _e55 = mode_1;
    modeR = (_e55 & 3i);
    let _e59 = mode_1;
    modeG = ((_e59 / 4i) & 3i);
    let _e65 = mode_1;
    modeB = ((_e65 / 16i) & 3i);
    let _e71 = invModelTransform;
    let _e72 = pos_1;
    let _e73 = tf(_e71, _e72);
    uv = _e73;
    let _e75 = cj;
    let _e76 = uv;
    let _e78 = sj;
    let _e81 = offsetTransform_1[2];
    t_2 = ((_e75 * _e76) + (_e78 * _e81.xy));
    let _e86 = sj;
    let _e87 = uv;
    let _e89 = cj;
    let _e92 = offsetTransform_1[2];
    z0_ = ((_e86 * _e87) + (_e89 * _e92.xy));
    let _e97 = z0_;
    z_4 = _e97;
    let _e99 = t_2;
    prev = _e99;
    let _e113 = power_1;
    if (_e113 == 2f) {
        {
            loop {
                let _e116 = iter;
                let _e117 = iterations_1;
                if !((_e116 < _e117)) {
                    break;
                }
                {
                    let _e120 = iter;
                    iter = (_e120 + 1i);
                    let _e123 = z_4;
                    prev = _e123;
                    let _e125 = prev;
                    let _e127 = prev;
                    let _e130 = prev;
                    let _e132 = prev;
                    let _e136 = t_2;
                    z_4.x = (((_e125.x * _e127.x) - (_e130.y * _e132.y)) + _e136.x);
                    let _e141 = prev;
                    let _e144 = prev;
                    let _e147 = t_2;
                    z_4.y = (((2f * _e141.x) * _e144.y) + _e147.y);
                    let _e150 = z_4;
                    let _e151 = z_4;
                    d2_ = dot(_e150, _e151);
                    let _e153 = distR;
                    let _e154 = z_4;
                    let _e155 = orbitSize_3;
                    let _e156 = tR;
                    let _e157 = modeR;
                    let _e158 = orbit(_e154, _e155, _e156, _e157);
                    distR = min(_e153, _e158);
                    let _e160 = distG;
                    let _e161 = z_4;
                    let _e162 = orbitSize_3;
                    let _e163 = tG;
                    let _e164 = modeG;
                    let _e165 = orbit(_e161, _e162, _e163, _e164);
                    distG = min(_e160, _e165);
                    let _e167 = distB;
                    let _e168 = z_4;
                    let _e169 = orbitSize_3;
                    let _e170 = tB;
                    let _e171 = modeB;
                    let _e172 = orbit(_e168, _e169, _e170, _e171);
                    distB = min(_e167, _e172);
                    let _e174 = d2_;
                    if (_e174 > 400000000f) {
                        {
                            outside = false;
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e178 = power_1;
        if (_e178 == 3f) {
            {
                loop {
                    let _e181 = iter;
                    let _e182 = iterations_1;
                    if !((_e181 < _e182)) {
                        break;
                    }
                    {
                        let _e185 = iter;
                        iter = (_e185 + 1i);
                        let _e188 = z_4;
                        prev = _e188;
                        let _e190 = prev;
                        let _e192 = prev;
                        let _e195 = prev;
                        let _e199 = prev;
                        let _e202 = prev;
                        let _e205 = prev;
                        let _e209 = t_2;
                        z_4.x = ((((_e190.x * _e192.x) * _e195.x) - (((3f * _e199.y) * _e202.y) * _e205.x)) + _e209.x);
                        let _e213 = prev;
                        let _e216 = prev;
                        let _e219 = prev;
                        let _e223 = prev;
                        let _e226 = prev;
                        let _e229 = prev;
                        let _e233 = t_2;
                        z_4.y = ((((-(_e213.y) * _e216.y) * _e219.y) + (((3f * _e223.x) * _e226.x) * _e229.y)) + _e233.y);
                        let _e236 = z_4;
                        let _e237 = z_4;
                        d2_ = dot(_e236, _e237);
                        let _e239 = distR;
                        let _e240 = z_4;
                        let _e243 = transformRed_1[2];
                        let _e246 = pointOrbit(_e240, -(_e243.xy));
                        let _e249 = transformRed_1[0];
                        distR = min(_e239, (_e246 * length(_e249)));
                        let _e253 = distG;
                        let _e254 = z_4;
                        let _e257 = transformGreen_1[2];
                        let _e260 = pointOrbit(_e254, -(_e257.xy));
                        let _e263 = transformGreen_1[0];
                        distG = min(_e253, (_e260 * length(_e263)));
                        let _e267 = distB;
                        let _e268 = z_4;
                        let _e271 = transformBlue_1[2];
                        let _e274 = pointOrbit(_e268, -(_e271.xy));
                        let _e277 = transformBlue_1[0];
                        distB = min(_e267, (_e274 * length(_e277)));
                        let _e281 = d2_;
                        if (_e281 > 400000000f) {
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
                let _e285 = z_4;
                d = length(_e285);
                loop {
                    let _e288 = iter;
                    let _e289 = iterations_1;
                    if !((_e288 < _e289)) {
                        break;
                    }
                    {
                        let _e292 = iter;
                        iter = (_e292 + 1i);
                        let _e295 = z_4;
                        prev = _e295;
                        let _e296 = prev;
                        let _e298 = prev;
                        angle = atan2(_e296.y, _e298.x);
                        let _e302 = d;
                        let _e303 = power_1;
                        dp = pow(_e302, _e303);
                        let _e307 = dp;
                        let _e308 = power_1;
                        let _e309 = angle;
                        let _e313 = t_2;
                        z_4.x = ((_e307 * cos((_e308 * _e309))) + _e313.x);
                        let _e317 = dp;
                        let _e318 = power_1;
                        let _e319 = angle;
                        let _e323 = t_2;
                        z_4.y = ((_e317 * sin((_e318 * _e319))) + _e323.y);
                        let _e326 = distR;
                        let _e327 = z_4;
                        let _e330 = transformRed_1[2];
                        let _e333 = pointOrbit(_e327, -(_e330.xy));
                        let _e336 = transformRed_1[0];
                        distR = min(_e326, (_e333 * length(_e336)));
                        let _e340 = distG;
                        let _e341 = z_4;
                        let _e344 = transformGreen_1[2];
                        let _e347 = pointOrbit(_e341, -(_e344.xy));
                        let _e350 = transformGreen_1[0];
                        distG = min(_e340, (_e347 * length(_e350)));
                        let _e354 = distB;
                        let _e355 = z_4;
                        let _e358 = transformBlue_1[2];
                        let _e361 = pointOrbit(_e355, -(_e358.xy));
                        let _e364 = transformBlue_1[0];
                        distB = min(_e354, (_e361 * length(_e364)));
                        let _e368 = z_4;
                        d = length(_e368);
                        let _e370 = d;
                        if (_e370 > 20000f) {
                            {
                                outside = false;
                                break;
                            }
                        }
                    }
                }
                let _e374 = d;
                let _e375 = d;
                d2_ = (_e374 * _e375);
            }
        }
    }
    let _e379 = d2_;
    d_1 = sqrt(_e379);
    let _e383 = iter;
    let _e386 = d_1;
    let _e389 = power_1;
    ty = ((1f + f32(_e383)) - (log(log(_e386)) / log(_e389)));
    let _e395 = ty;
    grey = (1f / _e395);
    let _e398 = distR;
    let _e399 = distG;
    let _e400 = distB;
    return vec4<f32>(_e398, _e399, _e400, 1f);
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e95 = global.U[9];
    let _e96 = _e95.xyz;
    let _e99 = global.U[10];
    let _e100 = _e99.xyz;
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e120 = global.U[12];
    let _e121 = _e120.xyz;
    let _e124 = global.U[13];
    let _e125 = _e124.xyz;
    let _e128 = global.U[14];
    let _e129 = _e128.xyz;
    let _e145 = global.U[15];
    let _e146 = _e145.xyz;
    let _e149 = global.U[16];
    let _e150 = _e149.xyz;
    let _e153 = global.U[17];
    let _e154 = _e153.xyz;
    let _e170 = global.U[18];
    let _e171 = _e170.xyz;
    let _e174 = global.U[19];
    let _e175 = _e174.xyz;
    let _e178 = global.U[20];
    let _e179 = _e178.xyz;
    let _e195 = global.U[21];
    let _e200 = global.U[22];
    let _e204 = global.U[23];
    let _e208 = global.U[24];
    let _e210 = mandelbrotOrbits((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)), mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), mat3x3<f32>(vec3<f32>(_e121.x, _e121.y, _e121.z), vec3<f32>(_e125.x, _e125.y, _e125.z), vec3<f32>(_e129.x, _e129.y, _e129.z)), mat3x3<f32>(vec3<f32>(_e146.x, _e146.y, _e146.z), vec3<f32>(_e150.x, _e150.y, _e150.z), vec3<f32>(_e154.x, _e154.y, _e154.z)), mat3x3<f32>(vec3<f32>(_e171.x, _e171.y, _e171.z), vec3<f32>(_e175.x, _e175.y, _e175.z), vec3<f32>(_e179.x, _e179.y, _e179.z)), i32(_e195.x), _e200.x, _e204.x, _e208.x);
    fragColor = _e210;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
