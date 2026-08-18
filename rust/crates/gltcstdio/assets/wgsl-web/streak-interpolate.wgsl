struct Params {
    U: array<vec4<f32>, 12>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn streakInterpolate(uv: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, sourceDim: vec2<f32>, count: i32, size: f32, textureSensitivity: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var sourceDim_1: vec2<f32>;
    var count_1: i32;
    var size_1: f32;
    var textureSensitivity_1: f32;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var ratio: f32;
    var scale: f32;
    var l: f32;
    var b: f32;
    var pixel: f32;
    var ya: f32 = -1f;
    var yb: f32 = 1f;
    var p: vec2<f32>;
    var ip: vec2<f32>;
    var c: vec4<f32>;
    var value: f32;
    var threshold: f32 = 1.5f;
    var dt: f32;
    var dir: f32;
    var newdir: f32;
    var newdir_1: f32;
    var stride: f32;
    var y: f32;
    var y1_: f32;
    var y2_: f32;
    var p1_: vec2<f32>;
    var p2_: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    sourceDim_1 = sourceDim;
    count_1 = count;
    size_1 = size;
    textureSensitivity_1 = textureSensitivity;
    let _e20 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e20);
    let _e23 = inverseModelTransform;
    let _e24 = uv_1;
    let _e25 = tf(_e23, _e24);
    u_2 = _e25;
    let _e27 = sourceDim_1;
    let _e29 = sourceDim_1;
    ratio = (_e27.x / _e29.y);
    let _e35 = inverseModelTransform[0];
    scale = length(_e35.xy);
    let _e39 = size_1;
    let _e43 = ratio;
    let _e46 = scale;
    l = (((_e39 * 1.5f) * max(1f, _e43)) * _e46);
    let _e50 = textureSensitivity_1;
    let _e52 = scale;
    b = ((0.2f * _e50) * _e52);
    let _e56 = sourceDim_1;
    let _e59 = scale;
    pixel = ((2f / _e56.y) * _e59);
    let _e62 = u_2;
    let _e65 = l;
    let _e67 = u_2;
    let _e71 = b;
    if ((abs(_e62.x) < _e65) && (abs(_e67.y) < (1f + abs(_e71)))) {
        {
            let _e81 = b;
            if (_e81 != 0f) {
                {
                    let _e84 = u_2;
                    let _e86 = ya;
                    p = vec2<f32>(_e84.x, _e86);
                    let _e89 = modelTransform_1;
                    let _e90 = p;
                    ip = (_e89 * vec3<f32>(_e90.x, _e90.y, 1f)).xy;
                    let _e98 = ip;
                    let _e102 = global.U[0];
                    let _e105 = ip;
                    let _e115 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e98.x / _e102.x), _e105.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    c = _e115;
                    let _e117 = c;
                    let _e119 = c;
                    let _e122 = c;
                    value = ((_e117.x + _e119.y) + _e122.z);
                    let _e128 = threshold;
                    let _e129 = pixel;
                    let _e131 = b;
                    dt = ((_e128 * _e129) / _e131);
                    let _e134 = b;
                    let _e135 = value;
                    let _e136 = threshold;
                    dir = -(sign((_e134 * (_e135 - _e136))));
                    loop {
                        let _e142 = dir;
                        let _e145 = p;
                        let _e147 = ya;
                        let _e150 = b;
                        if !(((_e142 != 0f) && (abs((_e145.y - _e147)) < abs(_e150)))) {
                            break;
                        }
                        {
                            let _e156 = p;
                            let _e158 = dir;
                            let _e159 = pixel;
                            p.y = (_e156.y + (_e158 * _e159));
                            let _e162 = modelTransform_1;
                            let _e163 = p;
                            ip = (_e162 * vec3<f32>(_e163.x, _e163.y, 1f)).xy;
                            let _e170 = ip;
                            let _e174 = global.U[0];
                            let _e177 = ip;
                            let _e187 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e170.x / _e174.x), _e177.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            c = _e187;
                            let _e188 = c;
                            let _e190 = c;
                            let _e193 = c;
                            value = ((_e188.x + _e190.y) + _e193.z);
                            let _e196 = b;
                            let _e197 = value;
                            let _e198 = threshold;
                            newdir = -(sign((_e196 * (_e197 - _e198))));
                            let _e204 = dir;
                            let _e205 = newdir;
                            if (_e204 != _e205) {
                                dir = 0f;
                            }
                            let _e208 = threshold;
                            let _e209 = dir;
                            let _e210 = dt;
                            threshold = (_e208 - (_e209 * _e210));
                        }
                    }
                    let _e213 = p;
                    ya = _e213.y;
                    let _e215 = u_2;
                    let _e217 = yb;
                    p = vec2<f32>(_e215.x, _e217);
                    let _e219 = modelTransform_1;
                    let _e220 = p;
                    ip = (_e219 * vec3<f32>(_e220.x, _e220.y, 1f)).xy;
                    let _e227 = ip;
                    let _e231 = global.U[0];
                    let _e234 = ip;
                    let _e244 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e227.x / _e231.x), _e234.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    c = _e244;
                    let _e245 = c;
                    let _e247 = c;
                    let _e250 = c;
                    value = ((_e245.x + _e247.y) + _e250.z);
                    threshold = 1.5f;
                    let _e254 = threshold;
                    let _e255 = pixel;
                    let _e257 = b;
                    dt = ((_e254 * _e255) / _e257);
                    let _e259 = b;
                    let _e260 = value;
                    let _e261 = threshold;
                    dir = sign((_e259 * (_e260 - _e261)));
                    loop {
                        let _e265 = dir;
                        let _e268 = p;
                        let _e270 = yb;
                        let _e273 = b;
                        if !(((_e265 != 0f) && (abs((_e268.y - _e270)) < abs(_e273)))) {
                            break;
                        }
                        {
                            let _e279 = p;
                            let _e281 = dir;
                            let _e282 = pixel;
                            p.y = (_e279.y + (_e281 * _e282));
                            let _e285 = modelTransform_1;
                            let _e286 = p;
                            ip = (_e285 * vec3<f32>(_e286.x, _e286.y, 1f)).xy;
                            let _e293 = ip;
                            let _e297 = global.U[0];
                            let _e300 = ip;
                            let _e310 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e293.x / _e297.x), _e300.y) / vec2(2f)) + vec2(0.5f)), 0f);
                            c = _e310;
                            let _e311 = c;
                            let _e313 = c;
                            let _e316 = c;
                            value = ((_e311.x + _e313.y) + _e316.z);
                            let _e319 = b;
                            let _e320 = value;
                            let _e321 = threshold;
                            newdir_1 = sign((_e319 * (_e320 - _e321)));
                            let _e326 = dir;
                            let _e327 = newdir_1;
                            if (_e326 != _e327) {
                                dir = 0f;
                            }
                            let _e330 = threshold;
                            let _e331 = dir;
                            let _e332 = dt;
                            threshold = (_e330 + (_e331 * _e332));
                        }
                    }
                    let _e335 = p;
                    yb = _e335.y;
                }
            }
            let _e337 = u_2;
            let _e339 = ya;
            let _e341 = u_2;
            let _e343 = yb;
            if ((_e337.y >= _e339) && (_e341.y <= _e343)) {
                {
                    let _e346 = yb;
                    let _e347 = ya;
                    let _e349 = count_1;
                    stride = ((_e346 - _e347) / f32(_e349));
                    let _e353 = u_2;
                    let _e355 = ya;
                    y = (_e353.y - _e355);
                    let _e358 = y;
                    let _e359 = stride;
                    let _e362 = stride;
                    let _e364 = ya;
                    y1_ = ((floor((_e358 / _e359)) * _e362) + _e364);
                    let _e367 = y1_;
                    let _e368 = stride;
                    y2_ = (_e367 + _e368);
                    let _e371 = modelTransform_1;
                    let _e372 = u_2;
                    let _e374 = y1_;
                    p1_ = (_e371 * vec3<f32>(_e372.x, _e374, 1f)).xy;
                    let _e380 = modelTransform_1;
                    let _e381 = u_2;
                    let _e383 = y2_;
                    p2_ = (_e380 * vec3<f32>(_e381.x, _e383, 1f)).xy;
                    let _e389 = p1_;
                    let _e393 = global.U[0];
                    let _e396 = p1_;
                    let _e406 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e389.x / _e393.x), _e396.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e407 = p2_;
                    let _e411 = global.U[0];
                    let _e414 = p2_;
                    let _e424 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e407.x / _e411.x), _e414.y) / vec2(2f)) + vec2(0.5f)), 0f);
                    let _e425 = u_2;
                    let _e427 = y1_;
                    let _e429 = stride;
                    return mix(_e406, _e424, vec4(((_e425.y - _e427) / _e429)));
                }
            }
        }
    }
    let _e433 = uv_1;
    let _e437 = global.U[0];
    let _e440 = uv_1;
    let _e450 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e433.x / _e437.x), _e440.y) / vec2(2f)) + vec2(0.5f)), 0f);
    return _e450;
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
    let _e66 = global.U[6];
    let _e67 = _e66.xyz;
    let _e70 = global.U[7];
    let _e71 = _e70.xyz;
    let _e74 = global.U[8];
    let _e75 = _e74.xyz;
    let _e91 = global.U[4];
    let _e95 = global.U[9];
    let _e100 = global.U[10];
    let _e104 = global.U[11];
    let _e106 = streakInterpolate((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.xy, i32(_e95.x), _e100.x, _e104.x);
    fragColor = _e106;
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
