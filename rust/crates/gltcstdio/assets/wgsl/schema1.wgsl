struct Params {
    U: array<vec4<f32>, 17>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e11 = noise_1;
    phase = acos(((2f * _e11) - 1f));
    let _e17 = noise_1;
    freq = (fract((_e17 * 16f)) + 0.5f);
    let _e25 = phase;
    let _e26 = freq;
    let _e27 = k_1;
    return ((1f + cos((_e25 + (_e26 * _e27)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e10 = noise_3;
    let _e12 = k_3;
    let _e13 = varyNoiseSmoothly(_e10.x, _e12);
    let _e14 = noise_3;
    let _e16 = k_3;
    let _e17 = varyNoiseSmoothly(_e14.y, _e16);
    return vec2<f32>(_e13, _e17);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e10 = co_1;
    let _e11 = rand2_(_e10);
    let _e12 = seed_1;
    let _e13 = varyVec2NoiseSmoothly(_e11, _e12);
    return (_e13 - vec2(0.5f));
}

fn distort(pos: vec2<f32>, a: vec2<f32>, b: vec2<f32>, splits: vec2<f32>, rect: vec4<f32>, intensity: f32, seed_2: f32, mode: i32) -> vec2<f32> {
    var pos_1: vec2<f32>;
    var a_1: vec2<f32>;
    var b_1: vec2<f32>;
    var splits_1: vec2<f32>;
    var rect_1: vec4<f32>;
    var intensity_1: f32;
    var seed_3: f32;
    var mode_1: i32;
    var rnd: vec2<f32>;
    var dx: f32;
    var dy: f32;

    pos_1 = pos;
    a_1 = a;
    b_1 = b;
    splits_1 = splits;
    rect_1 = rect;
    intensity_1 = intensity;
    seed_3 = seed_2;
    mode_1 = mode;
    let _e22 = splits_1;
    let _e23 = seed_3;
    let _e26 = rand2relSeeded(_e22, (_e23 + 122.1f));
    rnd = _e26;
    let _e28 = rect_1;
    let _e30 = rect_1;
    dx = (_e28.z - _e30.x);
    let _e34 = rect_1;
    let _e36 = rect_1;
    dy = (_e34.w - _e36.y);
    let _e40 = dx;
    let _e41 = dy;
    if (_e40 > _e41) {
        {
            let _e43 = pos_1;
            let _e44 = rnd;
            let _e47 = dx;
            let _e49 = dy;
            let _e51 = intensity_1;
            return (_e43 + vec2<f32>(((((sign(_e44.x) * _e47) / _e49) * _e51) * 0.0005f), 0f));
        }
    } else {
        {
            let _e58 = pos_1;
            let _e60 = rnd;
            let _e63 = dy;
            let _e65 = dx;
            let _e67 = intensity_1;
            return (_e58 + vec2<f32>(0f, ((((sign(_e60.y) * _e63) / _e65) * _e67) * 0.0005f)));
        }
    }
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

fn sdRectangle(u: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_1: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local: f32;

    u_1 = u;
    halfSize_1 = halfSize;
    let _e10 = u_1;
    let _e12 = halfSize_1;
    u_1 = (abs(_e10) - _e12);
    let _e14 = u_1;
    let _e18 = u_1;
    if ((_e14.x >= 0f) && (_e18.y >= 0f)) {
        let _e23 = u_1;
        local = length(_e23);
    } else {
        let _e25 = u_1;
        let _e27 = u_1;
        local = max(_e25.x, _e27.y);
    }
    let _e31 = local;
    return _e31;
}

fn roundedRectField(uv: vec2<f32>, shapeAspectRatio: f32) -> f32 {
    var uv_1: vec2<f32>;
    var shapeAspectRatio_1: f32;
    var rectSize: vec2<f32>;
    var d: f32;

    uv_1 = uv;
    shapeAspectRatio_1 = shapeAspectRatio;
    let _e10 = uv_1;
    uv_1 = (_e10 / vec2(1.1036f));
    let _e15 = shapeAspectRatio_1;
    rectSize = vec2<f32>(1f, _e15);
    let _e18 = rectSize;
    let _e19 = rectSize;
    rectSize = (_e18 / vec2(length(_e19)));
    let _e23 = uv_1;
    let _e26 = rectSize;
    let _e27 = sdRectangle((_e23 * 2f), _e26);
    d = _e27;
    let _e29 = d;
    return step((_e29 * 0.25f), 0f);
}

fn withBias(x_1: f32, b_2: f32) -> f32 {
    var x_2: f32;
    var b_3: f32;
    var s: f32;
    var ab: f32;

    x_2 = x_1;
    b_3 = b_2;
    let _e10 = b_3;
    s = sign(_e10);
    let _e13 = b_3;
    ab = abs(_e13);
    let _e16 = x_2;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn schema1_(uv_2: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, shapeAspectRatio_2: f32, iterations: i32, intensity_2: f32, variability: f32, randomSeed: f32, color1_: vec4<f32>, color2_: vec4<f32>, thickness: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var shapeAspectRatio_3: f32;
    var iterations_1: i32;
    var intensity_3: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var bg: vec4<f32>;
    var p: vec2<f32>;
    var scale: f32 = 17.459476f;
    var bias: vec2<f32> = vec2<f32>(0f, 0f);
    var mode_2: i32 = 9i;
    var ratio: f32 = 1f;
    var pixel: f32;
    var border: bool = false;
    var rect_2: vec4<f32>;
    var rndStep: f32 = 0f;
    var regularity: f32;
    var j: i32 = 0i;
    var horSplit: bool;
    var splits_2: vec2<f32>;
    var sPos: f32;
    var sscale: f32;
    var inverter: f32;
    var i: f32;
    var rnd_1: vec2<f32>;
    var size: vec2<f32>;
    var variability_2: f32;
    var Y: f32;
    var X: f32;
    var k_4: f32;
    var local_1: vec4<f32>;
    var fg: vec4<f32>;

    uv_3 = uv_2;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    shapeAspectRatio_3 = shapeAspectRatio_2;
    iterations_1 = iterations;
    intensity_3 = intensity_2;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color1_1 = color1_;
    color2_1 = color2_;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    let _e30 = uv_3;
    let _e34 = global.U[0];
    let _e37 = uv_3;
    let _e46 = textureSample(t_source, samp, ((vec2<f32>((_e30.x / _e34.x), _e37.y) / vec2(2f)) + vec2(0.5f)));
    bg = _e46;
    let _e48 = modelTransform_1;
    let _e50 = uv_3;
    p = (_naga_inverse_3x3_f32(_e48) * vec3<f32>(_e50.x, _e50.y, 1f)).xy;
    let _e71 = sourceDim_1;
    pixel = (2f / _e71.y);
    let _e81 = variability_1;
    regularity = (1f - _e81);
    loop {
        let _e86 = j;
        let _e87 = iterations_1;
        if !((_e86 < _e87)) {
            break;
        }
        {
            let _e93 = ratio;
            let _e97 = ratio;
            rect_2 = vec4<f32>(-(_e93), -1f, _e97, 1f);
            horSplit = true;
            splits_2 = vec2<f32>(0f, 0f);
            sPos = 0f;
            sscale = 0.5f;
            inverter = 0f;
            i = 0f;
            loop {
                let _e114 = i;
                let _e115 = sPos;
                let _e117 = scale;
                if !(((_e114 + _e115) < _e117)) {
                    break;
                }
                {
                    let _e123 = splits_2;
                    let _e124 = randomSeed_1;
                    let _e127 = rndStep;
                    let _e128 = j;
                    let _e132 = rand2relSeeded(_e123, ((_e124 + 122.1f) + (_e127 * f32(_e128))));
                    rnd_1 = _e132;
                    let _e134 = rect_2;
                    let _e136 = rect_2;
                    size = (_e134.zw - _e136.xy);
                    let _e140 = size;
                    let _e142 = pixel;
                    let _e144 = size;
                    let _e146 = pixel;
                    if ((_e140.x < _e142) || (_e144.y < _e146)) {
                        break;
                    }
                    let _e149 = rnd_1;
                    let _e153 = regularity;
                    if ((_e149.x + 0.5f) < (_e153 * 2f)) {
                        let _e157 = size;
                        let _e159 = size;
                        horSplit = (_e157.y > _e159.x);
                    }
                    let _e164 = regularity;
                    variability_2 = (1f - max(0f, ((_e164 * 2f) - 1f)));
                    let _e172 = horSplit;
                    if _e172 {
                        {
                            let _e173 = rect_2;
                            let _e175 = rect_2;
                            let _e177 = variability_2;
                            let _e178 = rnd_1;
                            let _e180 = bias;
                            let _e182 = withBias(_e178.y, _e180.y);
                            Y = mix(_e173.y, _e175.w, ((_e177 * _e182) + 0.5f));
                            let _e188 = Y;
                            let _e189 = p;
                            let _e193 = thickness_1;
                            if (abs((_e188 - _e189.y)) < (_e193 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e198 = p;
                            let _e200 = Y;
                            if (_e198.y < _e200) {
                                {
                                    let _e203 = Y;
                                    rect_2.w = _e203;
                                    let _e205 = splits_2.y;
                                    splits_2.y = (_e205 + 1f);
                                    let _e208 = sPos;
                                    let _e209 = inverter;
                                    let _e210 = sscale;
                                    sPos = (_e208 + (_e209 * _e210));
                                }
                            } else {
                                {
                                    let _e214 = Y;
                                    rect_2.y = _e214;
                                    let _e216 = splits_2;
                                    splits_2.y = (_e216.y + 100f);
                                    let _e220 = sPos;
                                    let _e222 = inverter;
                                    let _e224 = sscale;
                                    sPos = (_e220 + ((1f - _e222) * _e224));
                                }
                            }
                        }
                    } else {
                        {
                            let _e227 = rect_2;
                            let _e229 = rect_2;
                            let _e231 = variability_2;
                            let _e232 = rnd_1;
                            let _e234 = bias;
                            let _e236 = withBias(_e232.x, _e234.x);
                            X = mix(_e227.x, _e229.z, ((_e231 * _e236) + 0.5f));
                            let _e242 = X;
                            let _e243 = p;
                            let _e247 = thickness_1;
                            if (abs((_e242 - _e243.x)) < (_e247 * 0.1f)) {
                                {
                                    border = true;
                                    break;
                                }
                            }
                            let _e252 = p;
                            let _e254 = X;
                            if (_e252.x < _e254) {
                                {
                                    let _e257 = X;
                                    rect_2.z = _e257;
                                    let _e259 = splits_2.x;
                                    splits_2.x = (_e259 + 1f);
                                    let _e262 = sPos;
                                    let _e263 = inverter;
                                    let _e264 = sscale;
                                    sPos = (_e262 + (_e263 * _e264));
                                }
                            } else {
                                {
                                    let _e268 = X;
                                    rect_2.x = _e268;
                                    let _e270 = splits_2;
                                    splits_2.x = (_e270.x + 100f);
                                    let _e274 = sPos;
                                    let _e276 = inverter;
                                    let _e278 = sscale;
                                    sPos = (_e274 + ((1f - _e276) * _e278));
                                }
                            }
                        }
                    }
                    let _e281 = horSplit;
                    horSplit = !(_e281);
                    let _e284 = inverter;
                    inverter = (1f - _e284);
                    let _e286 = sscale;
                    sscale = (_e286 * 0.5f);
                    let _e289 = bias;
                    bias = (_e289 * 0.5f);
                }
                continuing {
                    let _e120 = i;
                    i = (_e120 + 1f);
                }
            }
            let _e292 = border;
            if _e292 {
                break;
            }
            let _e293 = p;
            let _e294 = rect_2;
            let _e296 = rect_2;
            let _e298 = splits_2;
            let _e299 = rect_2;
            let _e300 = intensity_3;
            let _e301 = randomSeed_1;
            let _e302 = mode_2;
            let _e303 = distort(_e293, _e294.xy, _e296.zw, _e298, _e299, _e300, _e301, _e302);
            p = _e303;
        }
        continuing {
            let _e90 = j;
            j = (_e90 + 1i);
        }
    }
    let _e304 = p;
    let _e305 = shapeAspectRatio_3;
    let _e306 = roundedRectField(_e304, _e305);
    k_4 = _e306;
    let _e308 = border;
    if _e308 {
        let _e309 = color2_1;
        local_1 = _e309;
    } else {
        let _e310 = color2_1;
        let _e311 = color1_1;
        let _e312 = k_4;
        local_1 = mix(_e310, _e311, vec4(_e312));
    }
    let _e316 = local_1;
    fg = _e316;
    let _e318 = bg;
    let _e319 = fg;
    let _e320 = mergeColor(_e318, _e319);
    return _e320;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e94 = global.U[12];
    let _e97 = global.U[13];
    let _e101 = global.U[14];
    let _e102 = _e101.xyz;
    let _e105 = global.U[15];
    let _e106 = _e105.xyz;
    let _e109 = global.U[16];
    let _e110 = _e109.xyz;
    let _e124 = schema1_((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, i32(_e74.x), _e79.x, _e83.x, _e87.x, _e91, _e94, _e97.x, mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)));
    fragColor = _e124;
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
