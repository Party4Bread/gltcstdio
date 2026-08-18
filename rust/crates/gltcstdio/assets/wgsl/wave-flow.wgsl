struct Params {
    U: array<vec4<f32>, 16>,
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

fn waveFlow(uv: vec2<f32>, outPos: vec2<f32>, iterations: i32, intensity: f32, balance: f32, variability: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var iterations_1: i32;
    var intensity_1: f32;
    var balance_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var mtScale: f32;
    var mt2k: f32;
    var modelTransform2_: mat3x3<f32>;
    var u: vec2<f32>;
    var inverseTransform: mat3x3<f32>;
    var inverseTransform2_: mat3x3<f32>;
    var invTransf: mat3x3<f32>;
    var transf: mat3x3<f32>;
    var local: f32;
    var bTranslate: vec2<f32>;
    var j: i32 = 0i;
    var translate: vec2<f32>;
    var local_1: f32;
    var scale: f32;
    var ts: mat3x3<f32>;
    var invts: mat3x3<f32>;
    var tt: mat3x3<f32>;
    var invtt: mat3x3<f32>;
    var t1_: mat3x3<f32>;
    var invt1_: mat3x3<f32>;
    var t2_: mat3x3<f32>;
    var invt2_: mat3x3<f32>;
    var local_2: mat3x3<f32>;
    var invTransf_1: mat3x3<f32>;
    var d: f32;
    var N: f32;
    var xx: f32;
    var i: f32;
    var di: f32;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var var_: f32;
    var magnitude: f32;
    var dy: f32;
    var local_3: mat3x3<f32>;
    var transf_1: mat3x3<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    iterations_1 = iterations;
    intensity_1 = intensity;
    balance_1 = balance;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1[0];
    mtScale = length(_e24.xy);
    let _e28 = mtScale;
    mt2k = (_e28 * 0.70710677f);
    let _e32 = mt2k;
    let _e33 = mt2k;
    let _e35 = vec3<f32>(_e32, _e33, 0f);
    let _e36 = mt2k;
    let _e38 = mt2k;
    let _e40 = vec3<f32>(-(_e36), _e38, 0f);
    let _e43 = modelTransform_1[2];
    modelTransform2_ = mat3x3<f32>(vec3<f32>(_e35.x, _e35.y, _e35.z), vec3<f32>(_e40.x, _e40.y, _e40.z), vec3<f32>(_e43.x, _e43.y, _e43.z));
    let _e58 = uv_1;
    u = _e58;
    let _e60 = modelTransform_1;
    inverseTransform = _naga_inverse_3x3_f32(_e60);
    let _e63 = modelTransform2_;
    inverseTransform2_ = _naga_inverse_3x3_f32(_e63);
    let _e66 = inverseTransform;
    invTransf = _e66;
    let _e68 = modelTransform_1;
    transf = _e68;
    let _e70 = balance_1;
    if (_e70 > 0f) {
        let _e73 = balance_1;
        local = _e73;
    } else {
        local = 0f;
    }
    let _e76 = local;
    let _e77 = balance_1;
    let _e81 = balance_1;
    bTranslate = (_e76 * vec2<f32>(cos((_e77 * 10f)), sin((-(_e81) * 10f))));
    loop {
        let _e91 = j;
        let _e92 = iterations_1;
        if !((_e91 < _e92)) {
            break;
        }
        {
            let _e98 = bTranslate;
            let _e99 = j;
            translate = (_e98 * f32(_e99));
            let _e103 = balance_1;
            if (_e103 < 0f) {
                let _e107 = balance_1;
                let _e111 = j;
                local_1 = pow(0.999f, ((abs(_e107) * 100f) * f32(_e111)));
            } else {
                local_1 = 1f;
            }
            let _e117 = local_1;
            scale = _e117;
            let _e119 = scale;
            let _e123 = scale;
            ts = mat3x3<f32>(vec3<f32>(_e119, 0f, 0f), vec3<f32>(0f, _e123, 0f), vec3<f32>(0f, 0f, 1f));
            let _e134 = scale;
            let _e140 = scale;
            invts = mat3x3<f32>(vec3<f32>((1f / _e134), 0f, 0f), vec3<f32>(0f, (1f / _e140), 0f), vec3<f32>(0f, 0f, 1f));
            let _e157 = translate;
            let _e159 = translate;
            tt = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e157.x, _e159.y, 1f));
            let _e173 = translate;
            let _e176 = translate;
            invtt = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(-(_e173.x), -(_e176.y), 1f));
            let _e185 = ts;
            let _e186 = modelTransform_1;
            let _e188 = tt;
            t1_ = ((_e185 * _e186) * _e188);
            let _e191 = invtt;
            let _e192 = inverseTransform;
            let _e194 = invts;
            invt1_ = ((_e191 * _e192) * _e194);
            let _e197 = ts;
            let _e198 = modelTransform2_;
            let _e200 = tt;
            t2_ = ((_e197 * _e198) * _e200);
            let _e203 = invtt;
            let _e204 = inverseTransform2_;
            let _e206 = invts;
            invt2_ = ((_e203 * _e204) * _e206);
            let _e209 = j;
            let _e210 = j;
            if (_e209 == ((_e210 / 2i) * 2i)) {
                let _e216 = invt1_;
                local_2 = _e216;
            } else {
                let _e217 = invt2_;
                local_2 = _e217;
            }
            let _e219 = local_2;
            invTransf_1 = _e219;
            let _e221 = invTransf_1;
            let _e222 = u;
            u = (_e221 * vec3<f32>(_e222.x, _e222.y, 1f)).xy;
            let _e229 = u;
            d = _e229.x;
            N = 4f;
            let _e234 = u;
            let _e236 = N;
            xx = (_e234.x / _e236);
            let _e239 = xx;
            i = floor(_e239);
            let _e242 = xx;
            let _e243 = i;
            di = (_e242 - _e243);
            let _e246 = i;
            let _e247 = i;
            let _e249 = randomSeed_1;
            let _e250 = rand2relSeeded(vec2<f32>(_e246, _e247), _e249);
            rnd = _e250;
            let _e253 = rnd;
            var_ = _e253.x;
            let _e256 = di;
            if (_e256 < 0.5f) {
                {
                    let _e259 = i;
                    let _e262 = i;
                    let _e266 = randomSeed_1;
                    let _e267 = rand2relSeeded(vec2<f32>((_e259 - 1f), (_e262 - 1f)), _e266);
                    rnd2_ = _e267;
                    let _e269 = di;
                    di = (0.5f - _e269);
                }
            } else {
                {
                    let _e271 = i;
                    let _e274 = i;
                    let _e278 = randomSeed_1;
                    let _e279 = rand2relSeeded(vec2<f32>((_e271 + 1f), (_e274 + 1f)), _e278);
                    rnd2_ = _e279;
                    let _e280 = di;
                    di = (_e280 - 0.5f);
                }
            }
            let _e283 = var_;
            let _e284 = rnd2_;
            let _e286 = di;
            let _e287 = di;
            var_ = mix(_e283, _e284.x, ((_e286 * _e287) * 2f));
            let _e292 = intensity_1;
            let _e294 = variability_1;
            let _e297 = var_;
            magnitude = (_e292 * (1f + (((_e294 * 10f) * _e297) * 2f)));
            let _e304 = xx;
            let _e308 = magnitude;
            dy = (sin((_e304 * 3.1415927f)) * _e308);
            let _e311 = j;
            let _e312 = j;
            if (_e311 == ((_e312 / 2i) * 2i)) {
                let _e318 = t1_;
                local_3 = _e318;
            } else {
                let _e319 = t2_;
                local_3 = _e319;
            }
            let _e321 = local_3;
            transf_1 = _e321;
            let _e323 = transf_1;
            let _e324 = u;
            let _e326 = u;
            let _e328 = dy;
            u = (_e323 * vec3<f32>(_e324.x, (_e326.y + _e328), 1f)).xy;
        }
        continuing {
            let _e95 = j;
            j = (_e95 + 1i);
        }
    }
    let _e334 = u;
    let _e338 = global.U[0];
    let _e341 = u;
    let _e350 = _mirror_wrap(((vec2<f32>((_e334.x / _e338.x), _e341.y) / vec2(2f)) + vec2(0.5f)));
    let _e351 = textureSample(t_source, samp, _e350);
    return _e351;
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
    let _e66 = global.U[8];
    let _e71 = global.U[9];
    let _e75 = global.U[10];
    let _e79 = global.U[11];
    let _e83 = global.U[12];
    let _e87 = global.U[13];
    let _e88 = _e87.xyz;
    let _e91 = global.U[14];
    let _e92 = _e91.xyz;
    let _e95 = global.U[15];
    let _e96 = _e95.xyz;
    let _e110 = waveFlow((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
    fragColor = _e110;
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
