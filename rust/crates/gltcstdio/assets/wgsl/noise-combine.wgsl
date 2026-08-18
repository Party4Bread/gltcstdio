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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn aRatio(a: f32) -> vec2<f32> {
    var a_1: f32;

    a_1 = a;
    let _e9 = a_1;
    let _e13 = a_1;
    return ((vec2<f32>(_e9, 1f) / vec2((1f + _e13))) * 2f);
}

fn getCoverFitTransform(aspectRatio: f32, imageDims: vec2<f32>) -> mat3x3<f32> {
    var aspectRatio_1: f32;
    var imageDims_1: vec2<f32>;
    var srcAr: f32;
    var h: f32;

    aspectRatio_1 = aspectRatio;
    imageDims_1 = imageDims;
    let _e11 = imageDims_1;
    let _e13 = imageDims_1;
    srcAr = (_e11.x / _e13.y);
    let _e18 = srcAr;
    let _e19 = aspectRatio_1;
    h = min(1f, (_e18 / _e19));
    let _e23 = h;
    let _e27 = h;
    return mat3x3<f32>(vec3<f32>(_e23, 0f, 0f), vec3<f32>(0f, _e27, 0f), vec3<f32>(0f, 0f, 1f));
}

fn rndUnit3_(p: vec3<f32>) -> vec3<f32> {
    var p_1: vec3<f32>;
    var u: vec3<f32>;
    var h_1: vec3<f32>;

    p_1 = p;
    let _e9 = p_1;
    u = fract((_e9 * vec3<f32>(0.1031f, 0.103f, 0.0973f)));
    let _e17 = u;
    let _e18 = u;
    let _e19 = u;
    u = (_e17 + vec3(dot(_e18, (_e19.yxz + vec3(33.33f)))));
    let _e27 = u;
    let _e29 = u;
    let _e32 = u;
    h_1 = fract(((_e27.xxy + _e29.yxx) * _e32.zyx));
    let _e37 = h_1;
    return normalize((_e37 - vec3(0.5f)));
}

fn dotGridGradient3_(g: vec3<f32>, u_1: vec3<f32>) -> f32 {
    var g_1: vec3<f32>;
    var u_2: vec3<f32>;

    g_1 = g;
    u_2 = u_1;
    let _e11 = u_2;
    let _e12 = g_1;
    let _e14 = g_1;
    let _e15 = rndUnit3_(_e14);
    return dot((_e11 - _e12), _e15);
}

fn smix(a_2: f32, b: f32, k: f32) -> f32 {
    var a_3: f32;
    var b_1: f32;
    var k_1: f32;

    a_3 = a_2;
    b_1 = b;
    k_1 = k;
    let _e13 = a_3;
    let _e14 = b_1;
    let _e17 = k_1;
    return mix(_e13, _e14, smoothstep(0f, 1f, _e17));
}

fn perlinRelNoise3_(p_2: vec3<f32>) -> f32 {
    var p_3: vec3<f32>;
    var s: vec3<f32> = vec3<f32>(1f, 0f, 0f);
    var f: vec3<f32>;
    var d: vec3<f32>;
    var ix00_: f32;
    var ix10_: f32;
    var ix01_: f32;
    var ix11_: f32;
    var iy0_: f32;
    var iy1_: f32;

    p_3 = p_2;
    let _e14 = p_3;
    f = floor(_e14);
    let _e17 = p_3;
    let _e18 = f;
    d = (_e17 - _e18);
    let _e21 = f;
    let _e22 = p_3;
    let _e23 = dotGridGradient3_(_e21, _e22);
    let _e24 = f;
    let _e25 = s;
    let _e27 = p_3;
    let _e28 = dotGridGradient3_((_e24 + _e25), _e27);
    let _e29 = d;
    let _e31 = smix(_e23, _e28, _e29.x);
    ix00_ = _e31;
    let _e33 = f;
    let _e34 = s;
    let _e37 = p_3;
    let _e38 = dotGridGradient3_((_e33 + _e34.yxz), _e37);
    let _e39 = f;
    let _e40 = s;
    let _e43 = p_3;
    let _e44 = dotGridGradient3_((_e39 + _e40.xxz), _e43);
    let _e45 = d;
    let _e47 = smix(_e38, _e44, _e45.x);
    ix10_ = _e47;
    let _e49 = f;
    let _e50 = s;
    let _e53 = p_3;
    let _e54 = dotGridGradient3_((_e49 + _e50.yyx), _e53);
    let _e55 = f;
    let _e56 = s;
    let _e59 = p_3;
    let _e60 = dotGridGradient3_((_e55 + _e56.xyx), _e59);
    let _e61 = d;
    let _e63 = smix(_e54, _e60, _e61.x);
    ix01_ = _e63;
    let _e65 = f;
    let _e66 = s;
    let _e69 = p_3;
    let _e70 = dotGridGradient3_((_e65 + _e66.yxx), _e69);
    let _e71 = f;
    let _e72 = s;
    let _e75 = p_3;
    let _e76 = dotGridGradient3_((_e71 + _e72.xxx), _e75);
    let _e77 = d;
    let _e79 = smix(_e70, _e76, _e77.x);
    ix11_ = _e79;
    let _e81 = ix00_;
    let _e82 = ix10_;
    let _e83 = d;
    let _e85 = smix(_e81, _e82, _e83.y);
    iy0_ = _e85;
    let _e87 = ix01_;
    let _e88 = ix11_;
    let _e89 = d;
    let _e91 = smix(_e87, _e88, _e89.y);
    iy1_ = _e91;
    let _e93 = iy0_;
    let _e94 = iy1_;
    let _e95 = d;
    let _e97 = smix(_e93, _e94, _e95.z);
    return _e97;
}

fn perlinNoise3_(p_4: vec3<f32>) -> f32 {
    var p_5: vec3<f32>;

    p_5 = p_4;
    let _e10 = p_5;
    let _e11 = perlinRelNoise3_(_e10);
    return (0.5f + (_e11 * 0.5f));
}

fn tf(m: mat3x3<f32>, u_3: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_4: vec2<f32>;

    m_1 = m;
    u_4 = u_3;
    let _e11 = m_1;
    let _e12 = u_4;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn noiseCombine(pos: vec2<f32>, outPos: vec2<f32>, coverage: f32, aspectRatio_2: f32, octaves: i32, randomSeed: f32, shapeAspectRatio: f32, modelTransform: mat3x3<f32>, source1Dim: vec2<f32>, source2Dim: vec2<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var coverage_1: f32;
    var aspectRatio_3: f32;
    var octaves_1: i32;
    var randomSeed_1: f32;
    var shapeAspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var source1Dim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var u_5: vec2<f32>;
    var uv: vec2<f32>;
    var octaveTransform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_2: f32 = 1f;
    var xacc: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;
    var x: f32;
    var octaveStd: f32;
    var sigma: f32;
    var p_6: f32;
    var threshold: f32;
    var local: f32;
    var outAr: f32;
    var fit1_: mat3x3<f32>;
    var fit2_: mat3x3<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    coverage_1 = coverage;
    aspectRatio_3 = aspectRatio_2;
    octaves_1 = octaves;
    randomSeed_1 = randomSeed;
    shapeAspectRatio_1 = shapeAspectRatio;
    modelTransform_1 = modelTransform;
    source1Dim_1 = source1Dim;
    source2Dim_1 = source2Dim;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e31 = modelTransform_1;
    let _e33 = pos_1;
    let _e34 = tf(_naga_inverse_3x3_f32(_e31), _e33);
    u_5 = _e34;
    let _e36 = u_5;
    let _e37 = shapeAspectRatio_1;
    let _e38 = aRatio(_e37);
    uv = (_e36 / _e38);
    loop {
        let _e75 = i;
        let _e76 = octaves_1;
        if !((_e75 < _e76)) {
            break;
        }
        {
            let _e82 = xacc;
            let _e83 = k_2;
            let _e84 = uv;
            let _e85 = randomSeed_1;
            let _e89 = perlinNoise3_(vec3<f32>(_e84.x, _e84.y, _e85));
            xacc = (_e82 + (_e83 * _e89));
            let _e92 = total;
            let _e93 = k_2;
            total = (_e92 + _e93);
            let _e95 = k_2;
            k_2 = (_e95 * 0.5f);
            let _e98 = octaveTransform;
            let _e99 = uv;
            uv = (_e98 * _e99);
        }
        continuing {
            let _e79 = i;
            i = (_e79 + 1i);
        }
    }
    let _e101 = xacc;
    let _e102 = total;
    x = (_e101 / _e102);
    let _e107 = octaves_1;
    let _e114 = octaves_1;
    octaveStd = sqrt(((1f - pow(0.25f, f32(_e107))) / (3f * pow((1f - pow(0.5f, f32(_e114))), 2f))));
    let _e125 = octaveStd;
    sigma = (0.16f * _e125);
    let _e128 = coverage_1;
    p_6 = clamp(_e128, 0.00001f, 0.99999f);
    let _e136 = sigma;
    let _e137 = p_6;
    let _e139 = p_6;
    threshold = (0.5f - ((_e136 * log((_e137 / (1f - _e139)))) / 1.702f));
    let _e148 = aspectRatio_3;
    if (_e148 > 0f) {
        let _e151 = aspectRatio_3;
        local = _e151;
    } else {
        let _e152 = source1Dim_1;
        let _e154 = source1Dim_1;
        local = (_e152.x / _e154.y);
    }
    let _e158 = local;
    outAr = _e158;
    let _e160 = outAr;
    let _e161 = source1Dim_1;
    let _e162 = getCoverFitTransform(_e160, _e161);
    fit1_ = _e162;
    let _e164 = outAr;
    let _e165 = source2Dim_1;
    let _e166 = getCoverFitTransform(_e164, _e165);
    fit2_ = _e166;
    let _e168 = x;
    let _e169 = threshold;
    if (_e168 < _e169) {
        let _e171 = fit1_;
        let _e172 = viewTransform1_1;
        let _e175 = pos_1;
        let _e176 = tf((_e171 * _naga_inverse_3x3_f32(_e172)), _e175);
        let _e180 = global.U[0];
        let _e183 = fit1_;
        let _e184 = viewTransform1_1;
        let _e187 = pos_1;
        let _e188 = tf((_e183 * _naga_inverse_3x3_f32(_e184)), _e187);
        let _e197 = textureSample(t_source1_, samp, ((vec2<f32>((_e176.x / _e180.x), _e188.y) / vec2(2f)) + vec2(0.5f)));
        return _e197;
    } else {
        let _e198 = fit2_;
        let _e199 = viewTransform2_1;
        let _e202 = pos_1;
        let _e203 = tf((_e198 * _naga_inverse_3x3_f32(_e199)), _e202);
        let _e207 = global.U[0];
        let _e210 = fit2_;
        let _e211 = viewTransform2_1;
        let _e214 = pos_1;
        let _e215 = tf((_e210 * _naga_inverse_3x3_f32(_e211)), _e214);
        let _e224 = textureSample(t_source2_, samp, ((vec2<f32>((_e203.x / _e207.x), _e215.y) / vec2(2f)) + vec2(0.5f)));
        return _e224;
    }
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[8];
    let _e71 = global.U[4];
    let _e75 = global.U[9];
    let _e80 = global.U[10];
    let _e84 = global.U[11];
    let _e88 = global.U[12];
    let _e89 = _e88.xyz;
    let _e92 = global.U[13];
    let _e93 = _e92.xyz;
    let _e96 = global.U[14];
    let _e97 = _e96.xyz;
    let _e113 = global.U[5];
    let _e117 = global.U[6];
    let _e121 = global.U[15];
    let _e122 = _e121.xyz;
    let _e125 = global.U[16];
    let _e126 = _e125.xyz;
    let _e129 = global.U[17];
    let _e130 = _e129.xyz;
    let _e146 = global.U[18];
    let _e147 = _e146.xyz;
    let _e150 = global.U[19];
    let _e151 = _e150.xyz;
    let _e154 = global.U[20];
    let _e155 = _e154.xyz;
    let _e169 = noiseCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, _e71.x, i32(_e75.x), _e80.x, _e84.x, mat3x3<f32>(vec3<f32>(_e89.x, _e89.y, _e89.z), vec3<f32>(_e93.x, _e93.y, _e93.z), vec3<f32>(_e97.x, _e97.y, _e97.z)), _e113.xy, _e117.xy, mat3x3<f32>(vec3<f32>(_e122.x, _e122.y, _e122.z), vec3<f32>(_e126.x, _e126.y, _e126.z), vec3<f32>(_e130.x, _e130.y, _e130.z)), mat3x3<f32>(vec3<f32>(_e147.x, _e147.y, _e147.z), vec3<f32>(_e151.x, _e151.y, _e151.z), vec3<f32>(_e155.x, _e155.y, _e155.z)));
    fragColor = _e169;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
