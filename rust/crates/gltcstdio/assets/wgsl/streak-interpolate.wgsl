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
                    let _e114 = textureSample(t_source, samp, ((vec2<f32>((_e98.x / _e102.x), _e105.y) / vec2(2f)) + vec2(0.5f)));
                    c = _e114;
                    let _e116 = c;
                    let _e118 = c;
                    let _e121 = c;
                    value = ((_e116.x + _e118.y) + _e121.z);
                    let _e127 = threshold;
                    let _e128 = pixel;
                    let _e130 = b;
                    dt = ((_e127 * _e128) / _e130);
                    let _e133 = b;
                    let _e134 = value;
                    let _e135 = threshold;
                    dir = -(sign((_e133 * (_e134 - _e135))));
                    loop {
                        let _e141 = dir;
                        let _e144 = p;
                        let _e146 = ya;
                        let _e149 = b;
                        if !(((_e141 != 0f) && (abs((_e144.y - _e146)) < abs(_e149)))) {
                            break;
                        }
                        {
                            let _e155 = p;
                            let _e157 = dir;
                            let _e158 = pixel;
                            p.y = (_e155.y + (_e157 * _e158));
                            let _e161 = modelTransform_1;
                            let _e162 = p;
                            ip = (_e161 * vec3<f32>(_e162.x, _e162.y, 1f)).xy;
                            let _e169 = ip;
                            let _e173 = global.U[0];
                            let _e176 = ip;
                            let _e185 = textureSample(t_source, samp, ((vec2<f32>((_e169.x / _e173.x), _e176.y) / vec2(2f)) + vec2(0.5f)));
                            c = _e185;
                            let _e186 = c;
                            let _e188 = c;
                            let _e191 = c;
                            value = ((_e186.x + _e188.y) + _e191.z);
                            let _e194 = b;
                            let _e195 = value;
                            let _e196 = threshold;
                            newdir = -(sign((_e194 * (_e195 - _e196))));
                            let _e202 = dir;
                            let _e203 = newdir;
                            if (_e202 != _e203) {
                                dir = 0f;
                            }
                            let _e206 = threshold;
                            let _e207 = dir;
                            let _e208 = dt;
                            threshold = (_e206 - (_e207 * _e208));
                        }
                    }
                    let _e211 = p;
                    ya = _e211.y;
                    let _e213 = u_2;
                    let _e215 = yb;
                    p = vec2<f32>(_e213.x, _e215);
                    let _e217 = modelTransform_1;
                    let _e218 = p;
                    ip = (_e217 * vec3<f32>(_e218.x, _e218.y, 1f)).xy;
                    let _e225 = ip;
                    let _e229 = global.U[0];
                    let _e232 = ip;
                    let _e241 = textureSample(t_source, samp, ((vec2<f32>((_e225.x / _e229.x), _e232.y) / vec2(2f)) + vec2(0.5f)));
                    c = _e241;
                    let _e242 = c;
                    let _e244 = c;
                    let _e247 = c;
                    value = ((_e242.x + _e244.y) + _e247.z);
                    threshold = 1.5f;
                    let _e251 = threshold;
                    let _e252 = pixel;
                    let _e254 = b;
                    dt = ((_e251 * _e252) / _e254);
                    let _e256 = b;
                    let _e257 = value;
                    let _e258 = threshold;
                    dir = sign((_e256 * (_e257 - _e258)));
                    loop {
                        let _e262 = dir;
                        let _e265 = p;
                        let _e267 = yb;
                        let _e270 = b;
                        if !(((_e262 != 0f) && (abs((_e265.y - _e267)) < abs(_e270)))) {
                            break;
                        }
                        {
                            let _e276 = p;
                            let _e278 = dir;
                            let _e279 = pixel;
                            p.y = (_e276.y + (_e278 * _e279));
                            let _e282 = modelTransform_1;
                            let _e283 = p;
                            ip = (_e282 * vec3<f32>(_e283.x, _e283.y, 1f)).xy;
                            let _e290 = ip;
                            let _e294 = global.U[0];
                            let _e297 = ip;
                            let _e306 = textureSample(t_source, samp, ((vec2<f32>((_e290.x / _e294.x), _e297.y) / vec2(2f)) + vec2(0.5f)));
                            c = _e306;
                            let _e307 = c;
                            let _e309 = c;
                            let _e312 = c;
                            value = ((_e307.x + _e309.y) + _e312.z);
                            let _e315 = b;
                            let _e316 = value;
                            let _e317 = threshold;
                            newdir_1 = sign((_e315 * (_e316 - _e317)));
                            let _e322 = dir;
                            let _e323 = newdir_1;
                            if (_e322 != _e323) {
                                dir = 0f;
                            }
                            let _e326 = threshold;
                            let _e327 = dir;
                            let _e328 = dt;
                            threshold = (_e326 + (_e327 * _e328));
                        }
                    }
                    let _e331 = p;
                    yb = _e331.y;
                }
            }
            let _e333 = u_2;
            let _e335 = ya;
            let _e337 = u_2;
            let _e339 = yb;
            if ((_e333.y >= _e335) && (_e337.y <= _e339)) {
                {
                    let _e342 = yb;
                    let _e343 = ya;
                    let _e345 = count_1;
                    stride = ((_e342 - _e343) / f32(_e345));
                    let _e349 = u_2;
                    let _e351 = ya;
                    y = (_e349.y - _e351);
                    let _e354 = y;
                    let _e355 = stride;
                    let _e358 = stride;
                    let _e360 = ya;
                    y1_ = ((floor((_e354 / _e355)) * _e358) + _e360);
                    let _e363 = y1_;
                    let _e364 = stride;
                    y2_ = (_e363 + _e364);
                    let _e367 = modelTransform_1;
                    let _e368 = u_2;
                    let _e370 = y1_;
                    p1_ = (_e367 * vec3<f32>(_e368.x, _e370, 1f)).xy;
                    let _e376 = modelTransform_1;
                    let _e377 = u_2;
                    let _e379 = y2_;
                    p2_ = (_e376 * vec3<f32>(_e377.x, _e379, 1f)).xy;
                    let _e385 = p1_;
                    let _e389 = global.U[0];
                    let _e392 = p1_;
                    let _e401 = textureSample(t_source, samp, ((vec2<f32>((_e385.x / _e389.x), _e392.y) / vec2(2f)) + vec2(0.5f)));
                    let _e402 = p2_;
                    let _e406 = global.U[0];
                    let _e409 = p2_;
                    let _e418 = textureSample(t_source, samp, ((vec2<f32>((_e402.x / _e406.x), _e409.y) / vec2(2f)) + vec2(0.5f)));
                    let _e419 = u_2;
                    let _e421 = y1_;
                    let _e423 = stride;
                    return mix(_e401, _e418, vec4(((_e419.y - _e421) / _e423)));
                }
            }
        }
    }
    let _e427 = uv_1;
    let _e431 = global.U[0];
    let _e434 = uv_1;
    let _e443 = textureSample(t_source, samp, ((vec2<f32>((_e427.x / _e431.x), _e434.y) / vec2(2f)) + vec2(0.5f)));
    return _e443;
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
