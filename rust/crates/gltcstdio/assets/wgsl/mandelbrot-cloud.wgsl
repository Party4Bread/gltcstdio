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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e9 = m_1;
    let _e10 = u_1;
    return (_e9 * vec3<f32>(_e10.x, _e10.y, 1f)).xy;
}

fn mandelbrotCloud(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, iterations: i32, julianess: f32, power: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
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
    var outside: bool = true;
    var N: i32 = 30i;
    var totalSqrDist: f32 = 0f;
    var aN: f32;
    var bN: f32 = -1.75f;
    var i: i32 = 0i;
    var j: i32;
    var z_1: vec2<f32>;
    var delta: vec2<f32>;
    var d: f32;
    var angle: f32;
    var dp: f32;
    var kDiv: f32;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    iterations_1 = iterations;
    julianess_1 = julianess;
    power_1 = power;
    let _e21 = julianess_1;
    cj = cos(((_e21 * 3.1415927f) * 0.5f));
    let _e28 = julianess_1;
    sj = sin(((_e28 * 3.1415927f) * 0.5f));
    let _e35 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e35);
    let _e38 = invModelTransform;
    let _e39 = pos_1;
    let _e40 = tf(_e38, _e39);
    uv = _e40;
    let _e42 = cj;
    let _e43 = uv;
    let _e45 = sj;
    let _e48 = offsetTransform_1[2];
    t = ((_e42 * _e43) + (_e45 * _e48.xy));
    let _e53 = sj;
    let _e54 = uv;
    let _e56 = cj;
    let _e59 = offsetTransform_1[2];
    z0_ = ((_e53 * _e54) + (_e56 * _e59.xy));
    let _e64 = z0_;
    z = _e64;
    let _e66 = t;
    prev = _e66;
    let _e79 = N;
    aN = (3.5f / f32((_e79 - 1i)));
    let _e88 = power_1;
    if (_e88 == 2f) {
        {
            loop {
                let _e93 = i;
                let _e94 = N;
                if !((_e93 < _e94)) {
                    break;
                }
                {
                    j = 0i;
                    loop {
                        let _e102 = j;
                        let _e103 = N;
                        if !((_e102 < _e103)) {
                            break;
                        }
                        {
                            let _e109 = i;
                            let _e111 = j;
                            let _e114 = aN;
                            let _e116 = bN;
                            z_1 = ((vec2<f32>(f32(_e109), f32(_e111)) * _e114) + vec2(_e116));
                            loop {
                                let _e120 = iter;
                                let _e121 = iterations_1;
                                if !((_e120 < _e121)) {
                                    break;
                                }
                                {
                                    let _e124 = iter;
                                    iter = (_e124 + 1i);
                                    let _e127 = z_1;
                                    prev = _e127;
                                    let _e129 = prev;
                                    let _e131 = prev;
                                    let _e134 = prev;
                                    let _e136 = prev;
                                    let _e140 = t;
                                    z_1.x = (((_e129.x * _e131.x) - (_e134.y * _e136.y)) + _e140.x);
                                    let _e145 = prev;
                                    let _e148 = prev;
                                    let _e151 = t;
                                    z_1.y = (((2f * _e145.x) * _e148.y) + _e151.y);
                                    let _e154 = z_1;
                                    let _e155 = z_1;
                                    d2_ = dot(_e154, _e155);
                                    let _e157 = z_1;
                                    let _e158 = uv;
                                    delta = (_e157 - _e158);
                                    let _e161 = totalSqrDist;
                                    let _e164 = delta;
                                    let _e165 = delta;
                                    totalSqrDist = (_e161 + (0.0001f / max(0.0001f, dot(_e164, _e165))));
                                    let _e170 = d2_;
                                    if (_e170 > 2f) {
                                        {
                                            outside = false;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        continuing {
                            let _e106 = j;
                            j = (_e106 + 1i);
                        }
                    }
                }
                continuing {
                    let _e97 = i;
                    i = (_e97 + 1i);
                }
            }
        }
    } else {
        let _e174 = power_1;
        if (_e174 == 3f) {
            {
                loop {
                    let _e177 = iter;
                    let _e178 = iterations_1;
                    if !((_e177 < _e178)) {
                        break;
                    }
                    {
                        let _e181 = iter;
                        iter = (_e181 + 1i);
                        let _e184 = z;
                        prev = _e184;
                        let _e186 = prev;
                        let _e188 = prev;
                        let _e191 = prev;
                        let _e195 = prev;
                        let _e198 = prev;
                        let _e201 = prev;
                        let _e205 = t;
                        z.x = ((((_e186.x * _e188.x) * _e191.x) - (((3f * _e195.y) * _e198.y) * _e201.x)) + _e205.x);
                        let _e209 = prev;
                        let _e212 = prev;
                        let _e215 = prev;
                        let _e219 = prev;
                        let _e222 = prev;
                        let _e225 = prev;
                        let _e229 = t;
                        z.y = ((((-(_e209.y) * _e212.y) * _e215.y) + (((3f * _e219.x) * _e222.x) * _e225.y)) + _e229.y);
                        let _e232 = z;
                        let _e233 = z;
                        d2_ = dot(_e232, _e233);
                        let _e235 = d2_;
                        if (_e235 > 400000000f) {
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
                let _e239 = z;
                d = length(_e239);
                loop {
                    let _e242 = iter;
                    let _e243 = iterations_1;
                    if !((_e242 < _e243)) {
                        break;
                    }
                    {
                        let _e246 = iter;
                        iter = (_e246 + 1i);
                        let _e249 = z;
                        prev = _e249;
                        let _e250 = prev;
                        let _e252 = prev;
                        angle = atan2(_e250.y, _e252.x);
                        let _e256 = d;
                        let _e257 = power_1;
                        dp = pow(_e256, _e257);
                        let _e261 = dp;
                        let _e262 = power_1;
                        let _e263 = angle;
                        let _e267 = t;
                        z.x = ((_e261 * cos((_e262 * _e263))) + _e267.x);
                        let _e271 = dp;
                        let _e272 = power_1;
                        let _e273 = angle;
                        let _e277 = t;
                        z.y = ((_e271 * sin((_e272 * _e273))) + _e277.y);
                        let _e280 = z;
                        d = length(_e280);
                        let _e282 = d;
                        if (_e282 > 20000f) {
                            {
                                outside = false;
                                break;
                            }
                        }
                    }
                }
                let _e286 = d;
                let _e287 = d;
                d2_ = (_e286 * _e287);
            }
        }
    }
    let _e290 = N;
    let _e291 = N;
    let _e293 = iterations_1;
    kDiv = (1f / f32(((_e290 * _e291) * _e293)));
    let _e298 = totalSqrDist;
    let _e299 = kDiv;
    let _e303 = totalSqrDist;
    let _e304 = kDiv;
    let _e308 = totalSqrDist;
    let _e309 = kDiv;
    outCol = vec4<f32>(((_e298 * _e299) * 1000f), ((_e303 * _e304) * 20000f), ((_e308 * _e309) * 10000f), 1f);
    let _e316 = outCol;
    return _e316;
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
    let _e65 = global.U[4];
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
    let _e125 = global.U[13];
    let _e129 = global.U[14];
    let _e131 = mandelbrotCloud((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), i32(_e65.x), mat3x3<f32>(vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z), vec3<f32>(_e79.x, _e79.y, _e79.z)), mat3x3<f32>(vec3<f32>(_e96.x, _e96.y, _e96.z), vec3<f32>(_e100.x, _e100.y, _e100.z), vec3<f32>(_e104.x, _e104.y, _e104.z)), i32(_e120.x), _e125.x, _e129.x);
    fragColor = _e131;
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
