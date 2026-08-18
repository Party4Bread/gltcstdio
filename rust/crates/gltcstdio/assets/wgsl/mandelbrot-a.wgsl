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

fn mandelbrotA(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, texTransform: mat3x3<f32>, iterations: i32, count: i32, julianess: f32, power: f32, offset: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var iterations_1: i32;
    var count_1: i32;
    var julianess_1: f32;
    var power_1: f32;
    var offset_1: f32;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var uv: vec2<f32>;
    var t: vec2<f32>;
    var z: vec2<f32>;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var d: f32;
    var angle: f32;
    var dp: f32;
    var d_1: f32;
    var angle_1: f32;
    var tx: f32;
    var step: f32;
    var local: f32;
    var s: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    texTransform_1 = texTransform;
    iterations_1 = iterations;
    count_1 = count;
    julianess_1 = julianess;
    power_1 = power;
    offset_1 = offset;
    let _e28 = julianess_1;
    cj = cos(((_e28 * 3.1415927f) * 0.5f));
    let _e35 = julianess_1;
    sj = sin(((_e35 * 3.1415927f) * 0.5f));
    let _e42 = modelTransform_1;
    let _e45 = offsetTransform_1[0];
    let _e46 = _e45.xy;
    let _e50 = vec3<f32>(_e46.x, _e46.y, 0f);
    let _e53 = offsetTransform_1[1];
    let _e54 = _e53.xy;
    let _e58 = vec3<f32>(_e54.x, _e54.y, 0f);
    invModelTransform = _naga_inverse_3x3_f32((_e42 * mat3x3<f32>(vec3<f32>(_e50.x, _e50.y, _e50.z), vec3<f32>(_e58.x, _e58.y, _e58.z), vec3<f32>(0f, 0f, 1f))));
    let _e76 = invModelTransform;
    let _e77 = pos_1;
    let _e78 = tf(_e76, _e77);
    uv = _e78;
    let _e80 = cj;
    let _e81 = uv;
    let _e83 = sj;
    let _e86 = offsetTransform_1[2];
    t = ((_e80 * _e81) + (_e83 * _e86.xy));
    let _e91 = sj;
    let _e92 = uv;
    let _e94 = cj;
    let _e97 = offsetTransform_1[2];
    z = ((_e91 * _e92) + (_e94 * _e97.xy));
    let _e102 = t;
    prev = _e102;
    let _e108 = power_1;
    if (_e108 == 2f) {
        {
            loop {
                let _e111 = iter;
                let _e112 = iterations_1;
                if !((_e111 < _e112)) {
                    break;
                }
                {
                    let _e115 = iter;
                    iter = (_e115 + 1i);
                    let _e118 = z;
                    prev = _e118;
                    let _e120 = prev;
                    let _e122 = prev;
                    let _e125 = prev;
                    let _e127 = prev;
                    let _e131 = t;
                    z.x = (((_e120.x * _e122.x) - (_e125.y * _e127.y)) + _e131.x);
                    let _e136 = prev;
                    let _e139 = prev;
                    let _e142 = t;
                    z.y = (((2f * _e136.x) * _e139.y) + _e142.y);
                    let _e145 = z;
                    let _e146 = z;
                    d2_ = dot(_e145, _e146);
                    let _e148 = d2_;
                    if (_e148 > 4f) {
                        break;
                    }
                }
            }
        }
    } else {
        let _e151 = power_1;
        if (_e151 == 3f) {
            {
                loop {
                    let _e154 = iter;
                    let _e155 = iterations_1;
                    if !((_e154 < _e155)) {
                        break;
                    }
                    {
                        let _e158 = iter;
                        iter = (_e158 + 1i);
                        let _e161 = z;
                        prev = _e161;
                        let _e163 = prev;
                        let _e165 = prev;
                        let _e168 = prev;
                        let _e172 = prev;
                        let _e175 = prev;
                        let _e178 = prev;
                        let _e182 = t;
                        z.x = ((((_e163.x * _e165.x) * _e168.x) - (((3f * _e172.y) * _e175.y) * _e178.x)) + _e182.x);
                        let _e186 = prev;
                        let _e189 = prev;
                        let _e192 = prev;
                        let _e196 = prev;
                        let _e199 = prev;
                        let _e202 = prev;
                        let _e206 = t;
                        z.y = ((((-(_e186.y) * _e189.y) * _e192.y) + (((3f * _e196.x) * _e199.x) * _e202.y)) + _e206.y);
                        let _e209 = z;
                        let _e210 = z;
                        d2_ = dot(_e209, _e210);
                        let _e212 = d2_;
                        if (_e212 > 4f) {
                            break;
                        }
                    }
                }
            }
        } else {
            {
                let _e215 = z;
                d = length(_e215);
                loop {
                    let _e218 = iter;
                    let _e219 = iterations_1;
                    if !((_e218 < _e219)) {
                        break;
                    }
                    {
                        let _e222 = iter;
                        iter = (_e222 + 1i);
                        let _e225 = z;
                        prev = _e225;
                        let _e226 = prev;
                        let _e228 = prev;
                        angle = atan2(_e226.y, _e228.x);
                        let _e232 = d;
                        let _e233 = power_1;
                        dp = pow(_e232, _e233);
                        let _e237 = dp;
                        let _e238 = power_1;
                        let _e239 = angle;
                        let _e243 = t;
                        z.x = ((_e237 * cos((_e238 * _e239))) + _e243.x);
                        let _e247 = dp;
                        let _e248 = power_1;
                        let _e249 = angle;
                        let _e253 = t;
                        z.y = ((_e247 * sin((_e248 * _e249))) + _e253.y);
                        let _e256 = z;
                        d = length(_e256);
                        let _e258 = d;
                        if (_e258 > 2f) {
                            break;
                        }
                    }
                }
                let _e261 = d;
                let _e262 = d;
                d2_ = (_e261 * _e262);
            }
        }
    }
    let _e264 = d2_;
    d_1 = sqrt(_e264);
    let _e267 = z;
    let _e269 = z;
    angle_1 = atan2(_e267.y, _e269.x);
    let _e274 = angle_1;
    let _e280 = count_1;
    tx = ((((2f * _e274) / 3.1415927f) - 1f) * f32(_e280));
    let _e284 = offset_1;
    let _e287 = iter;
    let _e290 = iterations_1;
    step = (((_e284 * 4f) * f32(_e287)) / f32(_e290));
    let _e294 = tx;
    let _e295 = d_1;
    if (_e295 < 2f) {
        let _e299 = d_1;
        local = (2f - _e299);
    } else {
        let _e301 = d_1;
        local = (_e301 - 2f);
    }
    let _e305 = local;
    let _e310 = step;
    s = vec2<f32>(_e294, ((pow(_e305, 0.5f) - 1f) + _e310));
    let _e314 = texTransform_1;
    let _e316 = s;
    let _e317 = tf(_naga_inverse_3x3_f32(_e314), _e316);
    let _e321 = global.U[0];
    let _e324 = texTransform_1;
    let _e326 = s;
    let _e327 = tf(_naga_inverse_3x3_f32(_e324), _e326);
    let _e336 = _mirror_wrap(((vec2<f32>((_e317.x / _e321.x), _e327.y) / vec2(2f)) + vec2(0.5f)));
    let _e337 = textureSample(t_source, samp, _e336);
    return _e337;
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
    let _e122 = _e121.xyz;
    let _e125 = global.U[13];
    let _e126 = _e125.xyz;
    let _e129 = global.U[14];
    let _e130 = _e129.xyz;
    let _e146 = global.U[15];
    let _e151 = global.U[16];
    let _e156 = global.U[17];
    let _e160 = global.U[18];
    let _e164 = global.U[19];
    let _e166 = mandelbrotA((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z)), i32(_e146.x), i32(_e151.x), _e156.x, _e160.x, _e164.x);
    fragColor = _e166;
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
