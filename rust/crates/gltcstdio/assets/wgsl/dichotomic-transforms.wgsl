struct Params {
    U: array<vec4<f32>, 26>,
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

fn withBias(x_1: f32, b: f32) -> f32 {
    var x_2: f32;
    var b_1: f32;
    var s: f32;
    var ab: f32;

    x_2 = x_1;
    b_1 = b;
    let _e10 = b_1;
    s = sign(_e10);
    let _e13 = b_1;
    ab = abs(_e13);
    let _e16 = x_2;
    let _e20 = s;
    let _e22 = ab;
    return (pow((_e16 + 0.5f), pow(2f, (-(_e20) * _e22))) - 0.5f);
}

fn dichotomicTransforms(uv: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, variability: f32, randomSeed: f32, colorBkg: vec4<f32>, color: vec4<f32>, thickness: f32, modelTransform: mat3x3<f32>, transform1_: mat3x3<f32>, transform2_: mat3x3<f32>, transform3_: mat3x3<f32>, transform4_: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var variability_1: f32;
    var randomSeed_1: f32;
    var colorBkg_1: vec4<f32>;
    var color_1: vec4<f32>;
    var thickness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var transform1_1: mat3x3<f32>;
    var transform2_1: mat3x3<f32>;
    var transform3_1: mat3x3<f32>;
    var transform4_1: mat3x3<f32>;
    var ratio: f32;
    var pixel: f32;
    var biasBase: vec2<f32>;
    var scale: f32;
    var p: vec2<f32>;
    var regularity: f32;
    var rect: vec4<f32>;
    var splits: vec2<f32> = vec2<f32>(0f, 0f);
    var horSplit: bool = true;
    var bias: vec2<f32>;
    var sPos: f32 = 0f;
    var sscale: f32 = 0.5f;
    var inverter: f32 = 0f;
    var i: f32 = 0f;
    var rnd: vec2<f32>;
    var size: vec2<f32>;
    var posVar: f32;
    var Y: f32;
    var X: f32;
    var cw: f32;
    var ch: f32;
    var r: f32;
    var k_4: i32;
    var local: mat3x3<f32>;
    var local_1: mat3x3<f32>;
    var local_2: mat3x3<f32>;
    var tf: mat3x3<f32>;
    var a: f32 = 1f;
    var nH: f32;
    var horizontal: bool;
    var local_3: i32;
    var n: i32;
    var u: f32 = 0f;
    var v_2: f32 = 0f;
    var tileW: f32;
    var rowW: f32;
    var startX: f32;
    var lx: f32;
    var idx: f32;
    var tileH: f32;
    var colH: f32;
    var startY: f32;
    var ly: f32;
    var idx_1: f32;
    var border: bool = false;
    var t: f32;
    var c: vec2<f32>;
    var ct: vec2<f32>;
    var X_1: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    colorBkg_1 = colorBkg;
    color_1 = color;
    thickness_1 = thickness;
    modelTransform_1 = modelTransform;
    transform1_1 = transform1_;
    transform2_1 = transform2_;
    transform3_1 = transform3_;
    transform4_1 = transform4_;
    let _e32 = sourceDim_1;
    let _e34 = sourceDim_1;
    ratio = (_e32.x / _e34.y);
    let _e39 = sourceDim_1;
    pixel = (2f / _e39.y);
    let _e43 = modelTransform_1;
    biasBase = (_e43 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e56 = modelTransform_1[0][0];
    let _e61 = modelTransform_1[0][1];
    scale = (1f / length(vec2<f32>(_e56, _e61)));
    let _e66 = uv_1;
    p = _e66;
    let _e69 = variability_1;
    regularity = (1f - _e69);
    let _e72 = ratio;
    let _e76 = ratio;
    rect = vec4<f32>(-(_e72), -1f, _e76, 1f);
    let _e86 = biasBase;
    bias = _e86;
    loop {
        let _e96 = i;
        let _e97 = sPos;
        let _e99 = scale;
        if !(((_e96 + _e97) < _e99)) {
            break;
        }
        {
            let _e105 = splits;
            let _e106 = randomSeed_1;
            let _e109 = rand2relSeeded(_e105, (_e106 + 122.1f));
            rnd = _e109;
            let _e111 = rect;
            let _e113 = rect;
            size = (_e111.zw - _e113.xy);
            let _e117 = size;
            let _e119 = pixel;
            let _e121 = size;
            let _e123 = pixel;
            if ((_e117.x < _e119) || (_e121.y < _e123)) {
                break;
            }
            let _e126 = rnd;
            let _e130 = regularity;
            if ((_e126.x + 0.5f) < (_e130 * 2f)) {
                let _e134 = size;
                let _e136 = size;
                horSplit = (_e134.y > _e136.x);
            }
            let _e141 = regularity;
            posVar = (1f - max(0f, ((_e141 * 2f) - 1f)));
            let _e149 = horSplit;
            if _e149 {
                {
                    let _e150 = rect;
                    let _e152 = rect;
                    let _e154 = posVar;
                    let _e155 = rnd;
                    let _e157 = bias;
                    let _e159 = withBias(_e155.y, _e157.y);
                    Y = mix(_e150.y, _e152.w, ((_e154 * _e159) + 0.5f));
                    let _e165 = p;
                    let _e167 = Y;
                    if (_e165.y < _e167) {
                        {
                            let _e170 = Y;
                            rect.w = _e170;
                            let _e172 = splits;
                            splits.y = (_e172.y + 1f);
                            let _e176 = sPos;
                            let _e177 = inverter;
                            let _e178 = sscale;
                            sPos = (_e176 + (_e177 * _e178));
                        }
                    } else {
                        {
                            let _e182 = Y;
                            rect.y = _e182;
                            let _e184 = splits;
                            splits.y = (_e184.y + 100f);
                            let _e188 = sPos;
                            let _e190 = inverter;
                            let _e192 = sscale;
                            sPos = (_e188 + ((1f - _e190) * _e192));
                        }
                    }
                }
            } else {
                {
                    let _e195 = rect;
                    let _e197 = rect;
                    let _e199 = posVar;
                    let _e200 = rnd;
                    let _e202 = bias;
                    let _e204 = withBias(_e200.x, _e202.x);
                    X = mix(_e195.x, _e197.z, ((_e199 * _e204) + 0.5f));
                    let _e210 = p;
                    let _e212 = X;
                    if (_e210.x < _e212) {
                        {
                            let _e215 = X;
                            rect.z = _e215;
                            let _e217 = splits;
                            splits.x = (_e217.x + 1f);
                            let _e221 = sPos;
                            let _e222 = inverter;
                            let _e223 = sscale;
                            sPos = (_e221 + (_e222 * _e223));
                        }
                    } else {
                        {
                            let _e227 = X;
                            rect.x = _e227;
                            let _e229 = splits;
                            splits.x = (_e229.x + 100f);
                            let _e233 = sPos;
                            let _e235 = inverter;
                            let _e237 = sscale;
                            sPos = (_e233 + ((1f - _e235) * _e237));
                        }
                    }
                }
            }
            let _e240 = horSplit;
            horSplit = !(_e240);
            let _e243 = inverter;
            inverter = (1f - _e243);
            let _e245 = sscale;
            sscale = (_e245 * 0.5f);
            let _e248 = bias;
            bias = (_e248 * 0.5f);
        }
        continuing {
            let _e102 = i;
            i = (_e102 + 1f);
        }
    }
    let _e251 = rect;
    let _e253 = rect;
    cw = (_e251.z - _e253.x);
    let _e257 = rect;
    let _e259 = rect;
    ch = (_e257.w - _e259.y);
    let _e263 = splits;
    let _e264 = randomSeed_1;
    let _e267 = rand2relSeeded(_e263, (_e264 + 55.5f));
    r = (_e267.x + 0.5f);
    let _e273 = r;
    k_4 = i32(min(3f, floor((_e273 * 4f))));
    let _e280 = k_4;
    if (_e280 == 0i) {
        let _e283 = transform1_1;
        local_2 = _e283;
    } else {
        let _e284 = k_4;
        if (_e284 == 1i) {
            let _e287 = transform2_1;
            local_1 = _e287;
        } else {
            let _e288 = k_4;
            if (_e288 == 2i) {
                let _e291 = transform3_1;
                local = _e291;
            } else {
                let _e292 = transform4_1;
                local = _e292;
            }
            let _e294 = local;
            local_1 = _e294;
        }
        let _e296 = local_1;
        local_2 = _e296;
    }
    let _e298 = local_2;
    tf = _e298;
    let _e302 = cw;
    let _e303 = ch;
    let _e304 = a;
    nH = (_e302 / (_e303 * _e304));
    let _e308 = nH;
    horizontal = (_e308 >= 1f);
    let _e312 = horizontal;
    if _e312 {
        let _e313 = nH;
        local_3 = i32(floor(_e313));
    } else {
        let _e317 = nH;
        local_3 = i32(floor((1f / _e317)));
    }
    let _e322 = local_3;
    n = _e322;
    let _e324 = n;
    n = max(_e324, 1i);
    let _e331 = horizontal;
    if _e331 {
        {
            let _e332 = ch;
            let _e333 = a;
            tileW = (_e332 * _e333);
            let _e336 = tileW;
            let _e337 = n;
            rowW = (_e336 * f32(_e337));
            let _e341 = rect;
            let _e343 = cw;
            let _e344 = rowW;
            startX = (_e341.x + ((_e343 - _e344) * 0.5f));
            let _e350 = p;
            let _e352 = startX;
            let _e355 = rowW;
            lx = clamp((_e350.x - _e352), 0f, _e355);
            let _e358 = lx;
            let _e359 = tileW;
            let _e362 = n;
            idx = min(floor((_e358 / _e359)), (f32(_e362) - 1f));
            let _e368 = lx;
            let _e369 = idx;
            let _e370 = tileW;
            let _e373 = tileW;
            u = ((_e368 - (_e369 * _e370)) / _e373);
            let _e375 = p;
            let _e377 = rect;
            let _e380 = ch;
            v_2 = ((_e375.y - _e377.y) / _e380);
        }
    } else {
        {
            let _e382 = cw;
            let _e383 = a;
            tileH = (_e382 / _e383);
            let _e386 = tileH;
            let _e387 = n;
            colH = (_e386 * f32(_e387));
            let _e391 = rect;
            let _e393 = ch;
            let _e394 = colH;
            startY = (_e391.y + ((_e393 - _e394) * 0.5f));
            let _e400 = p;
            let _e402 = startY;
            let _e405 = colH;
            ly = clamp((_e400.y - _e402), 0f, _e405);
            let _e408 = ly;
            let _e409 = tileH;
            let _e412 = n;
            idx_1 = min(floor((_e408 / _e409)), (f32(_e412) - 1f));
            let _e418 = p;
            let _e420 = rect;
            let _e423 = cw;
            u = ((_e418.x - _e420.x) / _e423);
            let _e425 = ly;
            let _e426 = idx_1;
            let _e427 = tileH;
            let _e430 = tileH;
            v_2 = ((_e425 - (_e426 * _e427)) / _e430);
        }
    }
    let _e434 = thickness_1;
    if (_e434 > 0f) {
        {
            let _e437 = thickness_1;
            t = (_e437 * 0.1f);
            let _e441 = p;
            let _e443 = rect;
            let _e446 = t;
            let _e448 = rect;
            let _e450 = p;
            let _e453 = t;
            let _e456 = p;
            let _e458 = rect;
            let _e461 = t;
            let _e464 = rect;
            let _e466 = p;
            let _e469 = t;
            if (((((_e441.x - _e443.x) < _e446) || ((_e448.z - _e450.x) < _e453)) || ((_e456.y - _e458.y) < _e461)) || ((_e464.w - _e466.y) < _e469)) {
                border = true;
            }
        }
    }
    let _e473 = border;
    if _e473 {
        let _e474 = color_1;
        return _e474;
    }
    let _e475 = u;
    let _e480 = v_2;
    c = vec2<f32>(((_e475 - 0.5f) * 2f), ((_e480 - 0.5f) * 2f));
    let _e487 = tf;
    let _e489 = c;
    ct = (_naga_inverse_3x3_f32(_e487) * vec3<f32>(_e489.x, _e489.y, 1f)).xy;
    let _e497 = ct;
    let _e499 = ratio;
    let _e501 = ct;
    X_1 = vec2<f32>((_e497.x * _e499), _e501.y);
    let _e505 = X_1;
    let _e509 = global.U[0];
    let _e512 = X_1;
    let _e521 = textureSample(t_source, samp, ((vec2<f32>((_e505.x / _e509.x), _e512.y) / vec2(2f)) + vec2(0.5f)));
    return _e521;
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
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e84 = global.U[10];
    let _e88 = global.U[11];
    let _e89 = _e88.xyz;
    let _e92 = global.U[12];
    let _e93 = _e92.xyz;
    let _e96 = global.U[13];
    let _e97 = _e96.xyz;
    let _e113 = global.U[14];
    let _e114 = _e113.xyz;
    let _e117 = global.U[15];
    let _e118 = _e117.xyz;
    let _e121 = global.U[16];
    let _e122 = _e121.xyz;
    let _e138 = global.U[17];
    let _e139 = _e138.xyz;
    let _e142 = global.U[18];
    let _e143 = _e142.xyz;
    let _e146 = global.U[19];
    let _e147 = _e146.xyz;
    let _e163 = global.U[20];
    let _e164 = _e163.xyz;
    let _e167 = global.U[21];
    let _e168 = _e167.xyz;
    let _e171 = global.U[22];
    let _e172 = _e171.xyz;
    let _e188 = global.U[23];
    let _e189 = _e188.xyz;
    let _e192 = global.U[24];
    let _e193 = _e192.xyz;
    let _e196 = global.U[25];
    let _e197 = _e196.xyz;
    let _e211 = dichotomicTransforms((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78, _e81, _e84.x, mat3x3<f32>(vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z), vec3<f32>(_e97.x, _e97.y, _e97.z)), mat3x3<f32>(vec3<f32>(_e114.x, _e114.y, _e114.z), vec3<f32>(_e118.x, _e118.y, _e118.z), vec3<f32>(_e122.x, _e122.y, _e122.z)), mat3x3<f32>(vec3<f32>(_e139.x, _e139.y, _e139.z), vec3<f32>(_e143.x, _e143.y, _e143.z), vec3<f32>(_e147.x, _e147.y, _e147.z)), mat3x3<f32>(vec3<f32>(_e164.x, _e164.y, _e164.z), vec3<f32>(_e168.x, _e168.y, _e168.z), vec3<f32>(_e172.x, _e172.y, _e172.z)), mat3x3<f32>(vec3<f32>(_e189.x, _e189.y, _e189.z), vec3<f32>(_e193.x, _e193.y, _e193.z), vec3<f32>(_e197.x, _e197.y, _e197.z)));
    fragColor = _e211;
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
