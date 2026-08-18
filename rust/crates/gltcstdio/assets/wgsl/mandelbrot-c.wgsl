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

fn mandelbrotC(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, texTransform: mat3x3<f32>, iterations: i32, julianess: f32, power: f32, offset: f32, colorIn: vec4<f32>, colorOut: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var iterations_1: i32;
    var julianess_1: f32;
    var power_1: f32;
    var offset_1: f32;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
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
    var d: f32;
    var angle: f32;
    var dp: f32;
    var d_1: f32;
    var angleT: f32;
    var angleZ0_: f32;
    var angle_1: f32;
    var tx: f32;
    var ty: f32;
    var s: vec2<f32>;
    var texCol: vec4<f32>;
    var local: vec4<f32>;
    var inoutCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    texTransform_1 = texTransform;
    iterations_1 = iterations;
    julianess_1 = julianess;
    power_1 = power;
    offset_1 = offset;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    let _e30 = julianess_1;
    cj = cos(((_e30 * 3.1415927f) * 0.5f));
    let _e37 = julianess_1;
    sj = sin(((_e37 * 3.1415927f) * 0.5f));
    let _e44 = modelTransform_1;
    let _e47 = offsetTransform_1[0];
    let _e48 = _e47.xy;
    let _e52 = vec3<f32>(_e48.x, _e48.y, 0f);
    let _e55 = offsetTransform_1[1];
    let _e56 = _e55.xy;
    let _e60 = vec3<f32>(_e56.x, _e56.y, 0f);
    invModelTransform = _naga_inverse_3x3_f32((_e44 * mat3x3<f32>(vec3<f32>(_e52.x, _e52.y, _e52.z), vec3<f32>(_e60.x, _e60.y, _e60.z), vec3<f32>(0f, 0f, 1f))));
    let _e78 = invModelTransform;
    let _e79 = pos_1;
    let _e80 = tf(_e78, _e79);
    uv = _e80;
    let _e82 = cj;
    let _e83 = uv;
    let _e85 = sj;
    let _e88 = offsetTransform_1[2];
    t = ((_e82 * _e83) + (_e85 * _e88.xy));
    let _e93 = sj;
    let _e94 = uv;
    let _e96 = cj;
    let _e99 = offsetTransform_1[2];
    z0_ = ((_e93 * _e94) + (_e96 * _e99.xy));
    let _e104 = z0_;
    z = _e104;
    let _e106 = t;
    prev = _e106;
    let _e114 = power_1;
    if (_e114 == 2f) {
        {
            loop {
                let _e117 = iter;
                let _e118 = iterations_1;
                if !((_e117 < _e118)) {
                    break;
                }
                {
                    let _e121 = iter;
                    iter = (_e121 + 1i);
                    let _e124 = z;
                    prev = _e124;
                    let _e126 = prev;
                    let _e128 = prev;
                    let _e131 = prev;
                    let _e133 = prev;
                    let _e137 = t;
                    z.x = (((_e126.x * _e128.x) - (_e131.y * _e133.y)) + _e137.x);
                    let _e142 = prev;
                    let _e145 = prev;
                    let _e148 = t;
                    z.y = (((2f * _e142.x) * _e145.y) + _e148.y);
                    let _e151 = z;
                    let _e152 = z;
                    d2_ = dot(_e151, _e152);
                    let _e154 = d2_;
                    if (_e154 > 400000000f) {
                        {
                            outside = false;
                            break;
                        }
                    }
                }
            }
        }
    } else {
        let _e158 = power_1;
        if (_e158 == 3f) {
            {
                loop {
                    let _e161 = iter;
                    let _e162 = iterations_1;
                    if !((_e161 < _e162)) {
                        break;
                    }
                    {
                        let _e165 = iter;
                        iter = (_e165 + 1i);
                        let _e168 = z;
                        prev = _e168;
                        let _e170 = prev;
                        let _e172 = prev;
                        let _e175 = prev;
                        let _e179 = prev;
                        let _e182 = prev;
                        let _e185 = prev;
                        let _e189 = t;
                        z.x = ((((_e170.x * _e172.x) * _e175.x) - (((3f * _e179.y) * _e182.y) * _e185.x)) + _e189.x);
                        let _e193 = prev;
                        let _e196 = prev;
                        let _e199 = prev;
                        let _e203 = prev;
                        let _e206 = prev;
                        let _e209 = prev;
                        let _e213 = t;
                        z.y = ((((-(_e193.y) * _e196.y) * _e199.y) + (((3f * _e203.x) * _e206.x) * _e209.y)) + _e213.y);
                        let _e216 = z;
                        let _e217 = z;
                        d2_ = dot(_e216, _e217);
                        let _e219 = d2_;
                        if (_e219 > 400000000f) {
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
                let _e223 = z;
                d = length(_e223);
                loop {
                    let _e226 = iter;
                    let _e227 = iterations_1;
                    if !((_e226 < _e227)) {
                        break;
                    }
                    {
                        let _e230 = iter;
                        iter = (_e230 + 1i);
                        let _e233 = z;
                        prev = _e233;
                        let _e234 = prev;
                        let _e236 = prev;
                        angle = atan2(_e234.y, _e236.x);
                        let _e240 = d;
                        let _e241 = power_1;
                        dp = pow(_e240, _e241);
                        let _e245 = dp;
                        let _e246 = power_1;
                        let _e247 = angle;
                        let _e251 = t;
                        z.x = ((_e245 * cos((_e246 * _e247))) + _e251.x);
                        let _e255 = dp;
                        let _e256 = power_1;
                        let _e257 = angle;
                        let _e261 = t;
                        z.y = ((_e255 * sin((_e256 * _e257))) + _e261.y);
                        let _e264 = z;
                        d = length(_e264);
                        let _e266 = d;
                        if (_e266 > 20000f) {
                            {
                                outside = false;
                                break;
                            }
                        }
                    }
                }
                let _e270 = d;
                let _e271 = d;
                d2_ = (_e270 * _e271);
            }
        }
    }
    let _e273 = d2_;
    d_1 = sqrt(_e273);
    let _e276 = t;
    let _e278 = t;
    angleT = acos((_e276.x / max(length(_e278), 0.000001f)));
    let _e285 = z0_;
    let _e287 = z0_;
    angleZ0_ = acos((_e285.x / max(length(_e287), 0.000001f)));
    let _e294 = cj;
    let _e295 = angleT;
    let _e297 = sj;
    let _e298 = angleZ0_;
    angle_1 = ((_e294 * _e295) + (_e297 * _e298));
    let _e302 = angle_1;
    tx = (((_e302 / 3.1415927f) * 2f) - 1f);
    let _e311 = iter;
    let _e314 = d_1;
    let _e319 = power_1;
    ty = ((1f + f32(_e311)) - (log(log(max(_e314, 2.7182817f))) / log(max(_e319, 1.0001f))));
    let _e326 = offset_1;
    if (_e326 != 0f) {
        let _e329 = ty;
        let _e333 = offset_1;
        ty = pow(max(_e329, 0.0001f), pow(1.05f, -(_e333)));
    }
    let _e337 = tx;
    let _e338 = ty;
    s = vec2<f32>(_e337, _e338);
    let _e341 = texTransform_1;
    let _e343 = s;
    let _e344 = tf(_naga_inverse_3x3_f32(_e341), _e343);
    let _e348 = global.U[0];
    let _e351 = texTransform_1;
    let _e353 = s;
    let _e354 = tf(_naga_inverse_3x3_f32(_e351), _e353);
    let _e363 = _mirror_wrap(((vec2<f32>((_e344.x / _e348.x), _e354.y) / vec2(2f)) + vec2(0.5f)));
    let _e364 = textureSample(t_source, samp, _e363);
    texCol = _e364;
    let _e366 = outside;
    if _e366 {
        let _e367 = colorIn_1;
        local = _e367;
    } else {
        let _e368 = colorOut_1;
        local = _e368;
    }
    let _e370 = local;
    inoutCol = _e370;
    let _e372 = texCol;
    let _e374 = inoutCol;
    let _e376 = inoutCol;
    let _e379 = mix(_e372.xyz, _e374.xyz, vec3(_e376.w));
    let _e380 = texCol;
    return vec4<f32>(_e379.x, _e379.y, _e379.z, _e380.w);
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
    let _e155 = global.U[17];
    let _e159 = global.U[18];
    let _e163 = global.U[19];
    let _e166 = global.U[20];
    let _e167 = mandelbrotC((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z)), i32(_e146.x), _e151.x, _e155.x, _e159.x, _e163, _e166);
    fragColor = _e167;
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
