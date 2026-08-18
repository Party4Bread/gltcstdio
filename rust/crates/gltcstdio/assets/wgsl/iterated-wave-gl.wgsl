struct Params {
    U: array<vec4<f32>, 13>,
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

fn rotation3_(angle: f32) -> mat3x3<f32> {
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
    let _e17 = sa;
    let _e19 = ca;
    return mat3x3<f32>(vec3<f32>(_e14, _e15, 0f), vec3<f32>(-(_e17), _e19, 0f), vec3<f32>(0f, 0f, 1f));
}

fn iteratedWaveGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, count: i32, regularity: f32, balance: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var count_1: i32;
    var regularity_1: f32;
    var balance_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var u: vec2<f32>;
    var variability: f32;
    var mtScale: f32;
    var mt2k: f32;
    var modelTransform2_: mat3x3<f32>;
    var invM1_: mat3x3<f32>;
    var invM2_: mat3x3<f32>;
    var local: f32;
    var bTranslate: vec2<f32>;
    var j: i32 = 0i;
    var jf: f32;
    var translate: vec2<f32>;
    var local_1: f32;
    var scl: f32;
    var ts: mat3x3<f32>;
    var invts: mat3x3<f32>;
    var tt: mat3x3<f32>;
    var invtt: mat3x3<f32>;
    var even: bool;
    var local_2: mat3x3<f32>;
    var t1_: mat3x3<f32>;
    var local_3: mat3x3<f32>;
    var invt1_: mat3x3<f32>;
    var N: f32;
    var xx: f32;
    var i: f32;
    var di: f32;
    var rnd: vec2<f32>;
    var rnd2_: vec2<f32>;
    var vary: f32;
    var magnitude: f32;
    var dy: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    count_1 = count;
    regularity_1 = regularity;
    balance_1 = balance;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e22 = pos_1;
    u = _e22;
    let _e25 = regularity_1;
    variability = (1f - _e25);
    let _e30 = modelTransform_1[0];
    mtScale = length(_e30.xy);
    let _e34 = mtScale;
    mt2k = (_e34 * 0.70710677f);
    let _e38 = mt2k;
    let _e39 = mt2k;
    let _e41 = vec3<f32>(_e38, _e39, 0f);
    let _e42 = mt2k;
    let _e44 = mt2k;
    let _e46 = vec3<f32>(-(_e42), _e44, 0f);
    let _e49 = modelTransform_1[2];
    modelTransform2_ = mat3x3<f32>(vec3<f32>(_e41.x, _e41.y, _e41.z), vec3<f32>(_e46.x, _e46.y, _e46.z), vec3<f32>(_e49.x, _e49.y, _e49.z));
    let _e64 = modelTransform_1;
    invM1_ = _naga_inverse_3x3_f32(_e64);
    let _e67 = modelTransform2_;
    invM2_ = _naga_inverse_3x3_f32(_e67);
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
        if !((_e91 < 1000i)) {
            break;
        }
        {
            let _e98 = j;
            let _e99 = count_1;
            if (_e98 >= _e99) {
                break;
            }
            let _e101 = j;
            jf = f32(_e101);
            let _e104 = bTranslate;
            let _e105 = jf;
            translate = (_e104 * _e105);
            let _e108 = balance_1;
            if (_e108 < 0f) {
                let _e112 = balance_1;
                let _e116 = jf;
                local_1 = pow(0.999f, ((abs(_e112) * 100f) * _e116));
            } else {
                local_1 = 1f;
            }
            let _e121 = local_1;
            scl = _e121;
            let _e123 = scl;
            let _e127 = scl;
            ts = mat3x3<f32>(vec3<f32>(_e123, 0f, 0f), vec3<f32>(0f, _e127, 0f), vec3<f32>(0f, 0f, 1f));
            let _e138 = scl;
            let _e144 = scl;
            invts = mat3x3<f32>(vec3<f32>((1f / _e138), 0f, 0f), vec3<f32>(0f, (1f / _e144), 0f), vec3<f32>(0f, 0f, 1f));
            let _e161 = translate;
            let _e163 = translate;
            tt = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(_e161.x, _e163.y, 1f));
            let _e177 = translate;
            let _e180 = translate;
            invtt = mat3x3<f32>(vec3<f32>(1f, 0f, 0f), vec3<f32>(0f, 1f, 0f), vec3<f32>(-(_e177.x), -(_e180.y), 1f));
            let _e189 = jf;
            even = ((_e189 - (floor((_e189 / 2f)) * 2f)) == 0f);
            let _e198 = ts;
            let _e199 = even;
            if _e199 {
                let _e200 = modelTransform_1;
                local_2 = _e200;
            } else {
                let _e201 = modelTransform2_;
                local_2 = _e201;
            }
            let _e203 = local_2;
            let _e205 = tt;
            t1_ = ((_e198 * _e203) * _e205);
            let _e208 = invtt;
            let _e209 = even;
            if _e209 {
                let _e210 = invM1_;
                local_3 = _e210;
            } else {
                let _e211 = invM2_;
                local_3 = _e211;
            }
            let _e213 = local_3;
            let _e215 = invts;
            invt1_ = ((_e208 * _e213) * _e215);
            let _e218 = invt1_;
            let _e219 = u;
            u = (_e218 * vec3<f32>(_e219.x, _e219.y, 1f)).xy;
            N = 4f;
            let _e228 = u;
            let _e230 = N;
            xx = (_e228.x / _e230);
            let _e233 = xx;
            i = floor(_e233);
            let _e236 = xx;
            let _e237 = i;
            di = (_e236 - _e237);
            let _e240 = i;
            let _e241 = i;
            let _e243 = randomSeed_1;
            let _e244 = rand2relSeeded(vec2<f32>(_e240, _e241), _e243);
            rnd = _e244;
            let _e247 = rnd;
            vary = _e247.x;
            let _e250 = di;
            if (_e250 < 0.5f) {
                {
                    let _e253 = i;
                    let _e256 = i;
                    let _e260 = randomSeed_1;
                    let _e261 = rand2relSeeded(vec2<f32>((_e253 - 1f), (_e256 - 1f)), _e260);
                    rnd2_ = _e261;
                    let _e263 = di;
                    di = (0.5f - _e263);
                }
            } else {
                {
                    let _e265 = i;
                    let _e268 = i;
                    let _e272 = randomSeed_1;
                    let _e273 = rand2relSeeded(vec2<f32>((_e265 + 1f), (_e268 + 1f)), _e272);
                    rnd2_ = _e273;
                    let _e274 = di;
                    di = (_e274 - 0.5f);
                }
            }
            let _e277 = vary;
            let _e278 = rnd2_;
            let _e280 = di;
            let _e281 = di;
            vary = mix(_e277, _e278.x, ((_e280 * _e281) * 2f));
            let _e286 = intensity_1;
            let _e288 = variability;
            let _e291 = vary;
            magnitude = (_e286 * (1f + (((_e288 * 10f) * _e291) * 2f)));
            let _e298 = xx;
            let _e302 = magnitude;
            dy = (sin((_e298 * 3.1415927f)) * _e302);
            let _e305 = t1_;
            let _e306 = u;
            let _e308 = u;
            let _e310 = dy;
            u = (_e305 * vec3<f32>(_e306.x, (_e308.y + _e310), 1f)).xy;
        }
        continuing {
            let _e95 = j;
            j = (_e95 + 1i);
        }
    }
    let _e316 = u;
    let _e320 = global.U[0];
    let _e323 = u;
    let _e332 = _mirror_wrap(((vec2<f32>((_e316.x / _e320.x), _e323.y) / vec2(2f)) + vec2(0.5f)));
    let _e333 = textureSample(t_source, samp, _e332);
    return _e333;
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e95 = global.U[12];
    let _e96 = _e95.xyz;
    let _e110 = iteratedWaveGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, _e83.x, mat3x3<f32>(vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z), vec3<f32>(_e96.x, _e96.y, _e96.z)));
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
