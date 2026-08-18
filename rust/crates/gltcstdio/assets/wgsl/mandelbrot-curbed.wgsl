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

fn mandelbrotCurbed(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, modelTransform: mat3x3<f32>, offsetTransform: mat3x3<f32>, texTransform: mat3x3<f32>, intensity: f32, iterations: i32, julianess: f32, power: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var offsetTransform_1: mat3x3<f32>;
    var texTransform_1: mat3x3<f32>;
    var intensity_1: f32;
    var iterations_1: i32;
    var julianess_1: f32;
    var power_1: f32;
    var cj: f32;
    var sj: f32;
    var invModelTransform: mat3x3<f32>;
    var uv: vec2<f32>;
    var t: vec2<f32>;
    var z0_: vec2<f32>;
    var p: f32;
    var z: vec2<f32>;
    var prev: vec2<f32>;
    var iter: i32 = 0i;
    var d2_: f32 = 0f;
    var inside: bool = true;
    var len: f32;
    var k: f32;
    var len_1: f32;
    var k_1: f32;
    var d: f32;
    var angle: f32;
    var dp: f32;
    var len_2: f32;
    var k_2: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    modelTransform_1 = modelTransform;
    offsetTransform_1 = offsetTransform;
    texTransform_1 = texTransform;
    intensity_1 = intensity;
    iterations_1 = iterations;
    julianess_1 = julianess;
    power_1 = power;
    let _e26 = julianess_1;
    cj = cos(((_e26 * 3.1415927f) * 0.5f));
    let _e33 = julianess_1;
    sj = sin(((_e33 * 3.1415927f) * 0.5f));
    let _e40 = modelTransform_1;
    let _e43 = offsetTransform_1[0];
    let _e44 = _e43.xy;
    let _e48 = vec3<f32>(_e44.x, _e44.y, 0f);
    let _e51 = offsetTransform_1[1];
    let _e52 = _e51.xy;
    let _e56 = vec3<f32>(_e52.x, _e52.y, 0f);
    invModelTransform = _naga_inverse_3x3_f32((_e40 * mat3x3<f32>(vec3<f32>(_e48.x, _e48.y, _e48.z), vec3<f32>(_e56.x, _e56.y, _e56.z), vec3<f32>(0f, 0f, 1f))));
    let _e74 = invModelTransform;
    let _e75 = pos_1;
    let _e76 = tf(_e74, _e75);
    uv = _e76;
    let _e78 = cj;
    let _e79 = uv;
    let _e81 = sj;
    let _e84 = offsetTransform_1[2];
    t = ((_e78 * _e79) + (_e81 * _e84.xy));
    let _e89 = sj;
    let _e90 = uv;
    let _e92 = cj;
    let _e95 = offsetTransform_1[2];
    z0_ = ((_e89 * _e90) + (_e92 * _e95.xy));
    let _e100 = intensity_1;
    let _e101 = intensity_1;
    let _e103 = intensity_1;
    let _e105 = intensity_1;
    let _e107 = intensity_1;
    p = (((((_e100 * _e101) * _e103) * _e105) * _e107) * 0.0000000128f);
    let _e116 = z0_;
    z = _e116;
    let _e118 = t;
    prev = _e118;
    let _e126 = power_1;
    if (_e126 == 2f) {
        {
            loop {
                let _e129 = iter;
                let _e130 = iterations_1;
                if !((_e129 < _e130)) {
                    break;
                }
                {
                    let _e133 = iter;
                    iter = (_e133 + 1i);
                    let _e136 = z;
                    prev = _e136;
                    let _e138 = prev;
                    let _e140 = prev;
                    let _e143 = prev;
                    let _e145 = prev;
                    let _e149 = t;
                    z.x = (((_e138.x * _e140.x) - (_e143.y * _e145.y)) + _e149.x);
                    let _e154 = prev;
                    let _e157 = prev;
                    let _e160 = t;
                    z.y = (((2f * _e154.x) * _e157.y) + _e160.y);
                    let _e163 = z;
                    len = length(_e163);
                    let _e166 = len;
                    let _e167 = len;
                    let _e169 = p;
                    k = ((_e166 * _e167) * _e169);
                    let _e172 = z;
                    let _e173 = k;
                    let _e174 = t;
                    let _e177 = k;
                    z = ((_e172 + (_e173 * _e174)) / vec2((_e177 + 1f)));
                }
            }
        }
    } else {
        let _e182 = power_1;
        if (_e182 == 3f) {
            {
                loop {
                    let _e185 = iter;
                    let _e186 = iterations_1;
                    if !((_e185 < _e186)) {
                        break;
                    }
                    {
                        let _e189 = iter;
                        iter = (_e189 + 1i);
                        let _e192 = z;
                        prev = _e192;
                        let _e194 = prev;
                        let _e196 = prev;
                        let _e199 = prev;
                        let _e203 = prev;
                        let _e206 = prev;
                        let _e209 = prev;
                        let _e213 = t;
                        z.x = ((((_e194.x * _e196.x) * _e199.x) - (((3f * _e203.y) * _e206.y) * _e209.x)) + _e213.x);
                        let _e217 = prev;
                        let _e220 = prev;
                        let _e223 = prev;
                        let _e227 = prev;
                        let _e230 = prev;
                        let _e233 = prev;
                        let _e237 = t;
                        z.y = ((((-(_e217.y) * _e220.y) * _e223.y) + (((3f * _e227.x) * _e230.x) * _e233.y)) + _e237.y);
                        let _e240 = z;
                        len_1 = length(_e240);
                        let _e243 = len_1;
                        let _e244 = len_1;
                        let _e246 = p;
                        k_1 = ((_e243 * _e244) * _e246);
                        let _e249 = z;
                        let _e250 = k_1;
                        let _e251 = t;
                        let _e254 = k_1;
                        z = ((_e249 + (_e250 * _e251)) / vec2((_e254 + 1f)));
                    }
                }
            }
        } else {
            {
                let _e259 = z;
                d = length(_e259);
                loop {
                    let _e262 = iter;
                    let _e263 = iterations_1;
                    if !((_e262 < _e263)) {
                        break;
                    }
                    {
                        let _e266 = iter;
                        iter = (_e266 + 1i);
                        let _e269 = z;
                        prev = _e269;
                        let _e270 = prev;
                        let _e272 = prev;
                        angle = atan2(_e270.y, _e272.x);
                        let _e276 = d;
                        let _e277 = power_1;
                        dp = pow(_e276, _e277);
                        let _e281 = dp;
                        let _e282 = power_1;
                        let _e283 = angle;
                        let _e287 = t;
                        z.x = ((_e281 * cos((_e282 * _e283))) + _e287.x);
                        let _e291 = dp;
                        let _e292 = power_1;
                        let _e293 = angle;
                        let _e297 = t;
                        z.y = ((_e291 * sin((_e292 * _e293))) + _e297.y);
                        let _e300 = z;
                        len_2 = length(_e300);
                        let _e303 = len_2;
                        let _e304 = len_2;
                        let _e306 = p;
                        k_2 = ((_e303 * _e304) * _e306);
                        let _e309 = z;
                        let _e310 = k_2;
                        let _e311 = t;
                        let _e314 = k_2;
                        z = ((_e309 + (_e310 * _e311)) / vec2((_e314 + 1f)));
                        let _e319 = len_2;
                        d = _e319;
                    }
                }
            }
        }
    }
    let _e320 = texTransform_1;
    let _e322 = z;
    let _e323 = tf(_naga_inverse_3x3_f32(_e320), _e322);
    let _e327 = global.U[0];
    let _e330 = texTransform_1;
    let _e332 = z;
    let _e333 = tf(_naga_inverse_3x3_f32(_e330), _e332);
    let _e342 = _mirror_wrap(((vec2<f32>((_e323.x / _e327.x), _e333.y) / vec2(2f)) + vec2(0.5f)));
    let _e343 = textureSample(t_source, samp, _e342);
    return _e343;
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
    let _e150 = global.U[16];
    let _e155 = global.U[17];
    let _e159 = global.U[18];
    let _e161 = mandelbrotCurbed((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)), mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z)), _e146.x, i32(_e150.x), _e155.x, _e159.x);
    fragColor = _e161;
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
