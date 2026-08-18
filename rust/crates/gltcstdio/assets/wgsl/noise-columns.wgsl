struct Params {
    U: array<vec4<f32>, 15>,
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

fn noiseColumns(uv: vec2<f32>, outPos: vec2<f32>, shapeAspectRatio: f32, count: i32, coverage: f32, variability: f32, randomSeed: f32, color: vec4<f32>, highlightColor: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var shapeAspectRatio_1: f32;
    var count_1: i32;
    var coverage_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var highlightColor_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var bkg_2: vec4<f32>;
    var u: vec2<f32>;
    var ar: f32;
    var n: f32;
    var cw: f32;
    var c: f32;
    var rc: vec2<f32>;
    var chunk: f32;
    var density: f32;
    var rh: f32;
    var r: f32;
    var fy: f32;
    var nx: f32 = 1f;
    var pSub: f32;
    var rs: vec2<f32>;
    var xw: f32;
    var k_4: f32;
    var rd: vec2<f32>;
    var rg: vec2<f32>;
    var h: f32;
    var y0_: f32;
    var local: vec4<f32>;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    shapeAspectRatio_1 = shapeAspectRatio;
    count_1 = count;
    coverage_1 = coverage;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color_1 = color;
    highlightColor_1 = highlightColor;
    modelTransform_1 = modelTransform;
    let _e26 = uv_1;
    let _e30 = global.U[0];
    let _e33 = uv_1;
    let _e42 = textureSample(t_source, samp, ((vec2<f32>((_e26.x / _e30.x), _e33.y) / vec2(2f)) + vec2(0.5f)));
    bkg_2 = _e42;
    let _e44 = modelTransform_1;
    let _e46 = uv_1;
    u = (_naga_inverse_3x3_f32(_e44) * vec3<f32>(_e46.x, _e46.y, 1f)).xy;
    let _e54 = shapeAspectRatio_1;
    ar = max(_e54, 0.01f);
    let _e58 = u;
    let _e61 = ar;
    let _e63 = u;
    if ((abs(_e58.x) > _e61) || (abs(_e63.y) > 1f)) {
        let _e69 = bkg_2;
        return _e69;
    }
    let _e70 = count_1;
    n = f32(max(_e70, 1i));
    let _e76 = ar;
    let _e78 = n;
    cw = ((2f * _e76) / _e78);
    let _e81 = u;
    let _e83 = ar;
    let _e85 = cw;
    let _e88 = n;
    c = min(floor(((_e81.x + _e83) / _e85)), (_e88 - 1f));
    let _e93 = c;
    let _e98 = c;
    let _e104 = randomSeed_1;
    let _e105 = rand2relSeeded(vec2<f32>(((_e93 * 7.13f) + 3.7f), ((_e98 * 1.77f) - 8.1f)), _e104);
    rc = (_e105 + vec2(0.5f));
    let _e111 = rc;
    let _e117 = variability_1;
    chunk = pow(4f, (((_e111.x - 0.5f) * 2f) * _e117));
    let _e121 = coverage_1;
    let _e123 = rc;
    let _e129 = variability_1;
    density = clamp((_e121 * pow(3f, (((_e123.y - 0.5f) * 2f) * _e129))), 0f, 1f);
    let _e137 = chunk;
    rh = ((_e137 * 2f) / 24f);
    let _e143 = u;
    let _e147 = rh;
    r = floor(((_e143.y + 1f) / _e147));
    let _e151 = u;
    let _e155 = rh;
    fy = fract(((_e151.y + 1f) / _e155));
    let _e161 = variability_1;
    pSub = clamp(((_e161 - 0.5f) * 2f), 0f, 1f);
    let _e170 = pSub;
    if (_e170 > 0f) {
        {
            let _e173 = c;
            let _e178 = c;
            let _e184 = randomSeed_1;
            let _e185 = rand2relSeeded(vec2<f32>(((_e173 * 3.31f) + 1.7f), ((_e178 * 9.87f) + 2.3f)), _e184);
            rs = (_e185 + vec2(0.5f));
            let _e190 = rs;
            let _e192 = pSub;
            if (_e190.x < _e192) {
                let _e194 = cw;
                let _e195 = rh;
                nx = clamp(floor((_e194 / (_e195 * 2f))), 1f, 64f);
            }
        }
    }
    let _e203 = cw;
    let _e204 = nx;
    xw = (_e203 / _e204);
    let _e207 = u;
    let _e209 = ar;
    let _e211 = c;
    let _e212 = cw;
    let _e215 = xw;
    let _e218 = nx;
    k_4 = min(floor((((_e207.x + _e209) - (_e211 * _e212)) / _e215)), (_e218 - 1f));
    let _e223 = c;
    let _e226 = k_4;
    let _e230 = r;
    let _e236 = randomSeed_1;
    let _e237 = rand2relSeeded(vec2<f32>(((_e223 * 13.7f) + (_e226 * 5.91f)), ((_e230 * 2.23f) + 4.9f)), _e236);
    rd = (_e237 + vec2(0.5f));
    let _e242 = rd;
    let _e244 = density;
    if (_e242.x > _e244) {
        let _e246 = bkg_2;
        return _e246;
    }
    let _e247 = r;
    let _e250 = k_4;
    let _e254 = c;
    let _e260 = randomSeed_1;
    let _e261 = rand2relSeeded(vec2<f32>(((_e247 * 3.17f) + (_e250 * 9.13f)), ((_e254 * 4.79f) + 8.31f)), _e260);
    rg = (_e261 + vec2(0.5f));
    let _e268 = rg;
    h = mix(0.35f, 0.8f, _e268.y);
    let _e273 = h;
    y0_ = ((1f - _e273) * 0.5f);
    let _e278 = fy;
    let _e279 = y0_;
    let _e281 = fy;
    let _e282 = y0_;
    let _e283 = h;
    if ((_e278 < _e279) || (_e281 > (_e282 + _e283))) {
        let _e287 = bkg_2;
        return _e287;
    }
    let _e288 = rd;
    if (fract((_e288.y * 13f)) < 0.08f) {
        let _e295 = highlightColor_1;
        local = _e295;
    } else {
        let _e296 = color_1;
        local = _e296;
    }
    let _e298 = local;
    col = _e298;
    let _e300 = bkg_2;
    let _e301 = col;
    let _e302 = mergeColor(_e300, _e301);
    return _e302;
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
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e101 = global.U[14];
    let _e102 = _e101.xyz;
    let _e116 = noiseColumns((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, _e83.x, _e87, _e90, mat3x3<f32>(vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z), vec3<f32>(_e102.x, _e102.y, _e102.z)));
    fragColor = _e116;
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
