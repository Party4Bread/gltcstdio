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

fn mandelbrotFeather(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, iterations: i32, balance: f32, julianess: f32, power: f32, colorIn: vec4<f32>, colorOut: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var iterations_1: i32;
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

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    iterations_1 = iterations;
    balance_1 = balance;
    julianess_1 = julianess;
    power_1 = power;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    let _e28 = julianess_1;
    cj = cos(((_e28 * 3.1415927f) * 0.5f));
    let _e35 = julianess_1;
    sj = sin(((_e35 * 3.1415927f) * 0.5f));
    let _e42 = modelTransform_1;
    invModelTransform = _naga_inverse_3x3_f32(_e42);
    let _e45 = invModelTransform;
    let _e46 = pos_1;
    let _e47 = tf(_e45, _e46);
    uv = _e47;
    let _e49 = cj;
    let _e50 = uv;
    let _e52 = sj;
    let _e55 = offsetTransform_1[2];
    t = ((_e49 * _e50) + (_e52 * _e55.xy));
    let _e60 = sj;
    let _e61 = uv;
    let _e63 = cj;
    let _e66 = offsetTransform_1[2];
    z0_ = ((_e60 * _e61) + (_e63 * _e66.xy));
    let _e71 = z0_;
    z = _e71;
    let _e74 = t;
    prev = _e74;
    let _e80 = power_1;
    if (_e80 == 2f) {
        {
            loop {
                let _e83 = iter;
                let _e84 = iterations_1;
                if !((_e83 < _e84)) {
                    break;
                }
                {
                    let _e87 = iter;
                    iter = (_e87 + 1i);
                    let _e90 = z;
                    prev = _e90;
                    let _e92 = prev;
                    let _e94 = prev;
                    let _e97 = prev;
                    let _e99 = prev;
                    let _e103 = t;
                    z.x = (((_e92.x * _e94.x) - (_e97.y * _e99.y)) + _e103.x);
                    let _e108 = prev;
                    let _e111 = prev;
                    let _e115 = t;
                    z.y = (abs(((2f * _e108.x) * _e111.y)) + _e115.y);
                    let _e118 = z;
                    let _e119 = z;
                    d2_ = dot(_e118, _e119);
                    let _e121 = iter;
                    let _e123 = balance_1;
                    let _e127 = rotation2_(((f32(_e121) * _e123) * 6.2831855f));
                    let _e128 = z;
                    w = (_e127 * _e128);
                    let _e130 = w;
                    if (_e130.y > 5f) {
                        {
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e134 = power_1;
        if (_e134 == 3f) {
            {
                loop {
                    let _e137 = iter;
                    let _e138 = iterations_1;
                    if !((_e137 < _e138)) {
                        break;
                    }
                    {
                        let _e141 = iter;
                        iter = (_e141 + 1i);
                        let _e144 = z;
                        prev = abs(_e144);
                        let _e147 = prev;
                        let _e149 = prev;
                        let _e152 = prev;
                        let _e156 = prev;
                        let _e159 = prev;
                        let _e162 = prev;
                        let _e166 = t;
                        z.x = ((((_e147.x * _e149.x) * _e152.x) - (((3f * _e156.y) * _e159.y) * _e162.x)) + _e166.x);
                        let _e170 = prev;
                        let _e173 = prev;
                        let _e176 = prev;
                        let _e180 = prev;
                        let _e183 = prev;
                        let _e186 = prev;
                        let _e190 = t;
                        z.y = ((((-(_e170.y) * _e173.y) * _e176.y) + (((3f * _e180.x) * _e183.x) * _e186.y)) + _e190.y);
                        let _e193 = z;
                        let _e194 = z;
                        d2_ = dot(_e193, _e194);
                        let _e196 = iter;
                        let _e198 = balance_1;
                        let _e202 = rotation2_(((f32(_e196) * _e198) * 6.2831855f));
                        let _e203 = z;
                        w = (_e202 * _e203);
                        let _e205 = w;
                        if (_e205.y > 5f) {
                            {
                                break;
                            }
                        }
                    }
                }
                let _e209 = z;
                w = _e209;
            }
        } else {
            {
                let _e210 = z;
                d = length(_e210);
                loop {
                    let _e213 = iter;
                    let _e214 = iterations_1;
                    if !((_e213 < _e214)) {
                        break;
                    }
                    {
                        let _e217 = iter;
                        iter = (_e217 + 1i);
                        let _e220 = z;
                        prev = abs(_e220);
                        let _e222 = prev;
                        let _e224 = prev;
                        angle_2 = atan2(_e222.y, _e224.x);
                        let _e228 = d;
                        let _e229 = power_1;
                        dp = pow(_e228, _e229);
                        let _e233 = dp;
                        let _e234 = power_1;
                        let _e235 = angle_2;
                        let _e239 = t;
                        z.x = ((_e233 * cos((_e234 * _e235))) + _e239.x);
                        let _e243 = dp;
                        let _e244 = power_1;
                        let _e245 = angle_2;
                        let _e249 = t;
                        z.y = ((_e243 * sin((_e244 * _e245))) + _e249.y);
                        let _e252 = z;
                        d = length(_e252);
                        let _e254 = iter;
                        let _e256 = balance_1;
                        let _e260 = rotation2_(((f32(_e254) * _e256) * 6.2831855f));
                        let _e261 = z;
                        w = (_e260 * _e261);
                        let _e263 = w;
                        if (_e263.y > 5f) {
                            {
                                break;
                            }
                        }
                    }
                }
                let _e267 = z;
                w = _e267;
                let _e268 = d;
                let _e269 = d;
                d2_ = (_e268 * _e269);
            }
        }
    }
    let _e273 = d2_;
    d_1 = sqrt(_e273);
    let _e277 = iter;
    let _e280 = d_1;
    let _e283 = power_1;
    ty = ((1f + f32(_e277)) - (log(log(_e280)) / log(_e283)));
    let _e289 = ty;
    grey = (1f / _e289);
    let _e293 = iter;
    let _e294 = iterations_1;
    if (_e293 == _e294) {
        {
            let _e296 = w;
            grey = abs(_e296.y);
            let _e299 = colorIn_1;
            color = _e299;
        }
    } else {
        {
            let _e301 = w;
            let _e309 = iter;
            grey = ((1f / pow(_e301.y, 0.25f)) + (0.5f * (1f - pow(0.9f, f32(_e309)))));
            let _e315 = colorOut_1;
            color = _e315;
        }
    }
    let _e316 = source_specified_1;
    if (_e316 == 0i) {
        let _e319 = grey;
        let _e320 = color;
        let _e324 = ((_e319 * _e320.xyz) * 2f);
        let _e325 = color;
        return vec4<f32>(_e324.x, _e324.y, _e324.z, _e325.w);
    } else {
        let _e332 = grey;
        let _e341 = global.U[0];
        let _e345 = grey;
        let _e359 = textureSample(t_source, samp, ((vec2<f32>((vec2<f32>(0f, ((_e332 * 2f) - 1f)).x / _e341.x), vec2<f32>(0f, ((_e345 * 2f) - 1f)).y) / vec2(2f)) + vec2(0.5f)));
        return _e359;
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
    let _e141 = global.U[17];
    let _e142 = mandelbrotFeather((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), i32(_e121.x), _e126.x, _e130.x, _e134.x, _e138, _e141);
    fragColor = _e142;
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
