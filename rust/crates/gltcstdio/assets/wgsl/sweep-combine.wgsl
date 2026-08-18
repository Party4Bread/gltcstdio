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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

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

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e13 = a_1;
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

fn sweepCombine(pos: vec2<f32>, outPos: vec2<f32>, coverage: f32, mode: i32, style: i32, thickness: f32, patternDensity: f32, aspectRatio_2: f32, source1Dim: vec2<f32>, source2Dim: vec2<f32>, viewTransform1_: mat3x3<f32>, viewTransform2_: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var coverage_1: f32;
    var mode_1: i32;
    var style_1: i32;
    var thickness_1: f32;
    var patternDensity_1: f32;
    var aspectRatio_3: f32;
    var source1Dim_1: vec2<f32>;
    var source2Dim_1: vec2<f32>;
    var viewTransform1_1: mat3x3<f32>;
    var viewTransform2_1: mat3x3<f32>;
    var local: f32;
    var outAr: f32;
    var y: f32;
    var s_1: f32;
    var pAlong: f32;
    var a_2: f32;
    var d_1: vec2<f32>;
    var a_3: f32;
    var r: f32;
    var r_1: f32;
    var r_2: f32;
    var lo: f32;
    var local_1: f32;
    var blend: f32;
    var freq: f32;
    var pat: f32;
    var freq_1: f32;
    var pat_1: f32;
    var freq_2: f32;
    var uv: vec2<f32>;
    var seed: f32;
    var oct: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_2: f32 = 1f;
    var acc: f32 = 0f;
    var tot: f32 = 0f;
    var i: i32 = 0i;
    var n: f32;
    var sigma: f32 = 0.098f;
    var pat_2: f32;
    var c1_: vec4<f32>;
    var c2_: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    coverage_1 = coverage;
    mode_1 = mode;
    style_1 = style;
    thickness_1 = thickness;
    patternDensity_1 = patternDensity;
    aspectRatio_3 = aspectRatio_2;
    source1Dim_1 = source1Dim;
    source2Dim_1 = source2Dim;
    viewTransform1_1 = viewTransform1_;
    viewTransform2_1 = viewTransform2_;
    let _e31 = aspectRatio_3;
    if (_e31 > 0f) {
        let _e34 = aspectRatio_3;
        local = _e34;
    } else {
        let _e35 = source1Dim_1;
        let _e37 = source1Dim_1;
        local = (_e35.x / _e37.y);
    }
    let _e41 = local;
    outAr = _e41;
    let _e43 = pos_1;
    y = -(_e43.y);
    let _e49 = mode_1;
    if (_e49 == 0i) {
        {
            let _e52 = y;
            s_1 = ((_e52 * 0.5f) + 0.5f);
            let _e57 = y;
            pAlong = _e57;
        }
    } else {
        let _e58 = mode_1;
        if (_e58 == 1i) {
            {
                let _e62 = y;
                s_1 = (0.5f - (_e62 * 0.5f));
                let _e66 = y;
                pAlong = _e66;
            }
        } else {
            let _e67 = mode_1;
            if (_e67 == 2i) {
                {
                    let _e71 = pos_1;
                    let _e73 = outAr;
                    s_1 = (0.5f - ((_e71.x / _e73) * 0.5f));
                    let _e78 = pos_1;
                    pAlong = _e78.x;
                }
            } else {
                let _e80 = mode_1;
                if (_e80 == 3i) {
                    {
                        let _e83 = pos_1;
                        let _e85 = outAr;
                        s_1 = (((_e83.x / _e85) * 0.5f) + 0.5f);
                        let _e91 = pos_1;
                        pAlong = _e91.x;
                    }
                } else {
                    let _e93 = mode_1;
                    if (_e93 == 4i) {
                        {
                            let _e96 = pos_1;
                            let _e98 = outAr;
                            let _e100 = y;
                            s_1 = ((((_e96.x / _e98) + _e100) * 0.25f) + 0.5f);
                            let _e106 = pos_1;
                            let _e108 = y;
                            pAlong = ((_e106.x + _e108) * 0.70710677f);
                        }
                    } else {
                        let _e112 = mode_1;
                        if (_e112 == 5i) {
                            {
                                let _e115 = pos_1;
                                let _e117 = y;
                                a_2 = atan2(_e115.x, _e117);
                                let _e120 = a_2;
                                if (_e120 < 0f) {
                                    let _e123 = a_2;
                                    a_2 = (_e123 + 6.2831855f);
                                }
                                let _e127 = a_2;
                                s_1 = (1f - (_e127 / 6.2831855f));
                                let _e131 = a_2;
                                pAlong = _e131;
                            }
                        } else {
                            let _e132 = mode_1;
                            if (_e132 == 6i) {
                                {
                                    let _e135 = pos_1;
                                    let _e137 = y;
                                    d_1 = vec2<f32>(_e135.x, (_e137 + 1f));
                                    let _e142 = d_1;
                                    let _e144 = d_1;
                                    a_3 = atan2(_e142.y, _e144.x);
                                    let _e149 = a_3;
                                    s_1 = (1f - (_e149 / 3.1415927f));
                                    let _e153 = a_3;
                                    pAlong = _e153;
                                }
                            } else {
                                let _e154 = mode_1;
                                if (_e154 == 7i) {
                                    {
                                        let _e157 = pos_1;
                                        let _e159 = outAr;
                                        let _e161 = y;
                                        s_1 = ((((_e157.x / _e159) - _e161) * 0.25f) + 0.5f);
                                        let _e167 = pos_1;
                                        let _e169 = y;
                                        pAlong = ((_e167.x - _e169) * 0.70710677f);
                                    }
                                } else {
                                    let _e173 = mode_1;
                                    if (_e173 == 8i) {
                                        {
                                            let _e176 = pos_1;
                                            let _e178 = y;
                                            r = length(vec2<f32>(_e176.x, _e178));
                                            let _e183 = r;
                                            let _e184 = outAr;
                                            s_1 = (1f - (_e183 / length(vec2<f32>(_e184, 1f))));
                                            let _e190 = r;
                                            pAlong = _e190;
                                        }
                                    } else {
                                        let _e191 = mode_1;
                                        if (_e191 == 9i) {
                                            {
                                                let _e194 = pos_1;
                                                let _e197 = y;
                                                r_1 = (abs(_e194.x) + abs(_e197));
                                                let _e202 = r_1;
                                                let _e203 = outAr;
                                                s_1 = (1f - (_e202 / (_e203 + 1f)));
                                                let _e208 = r_1;
                                                pAlong = _e208;
                                            }
                                        } else {
                                            {
                                                let _e209 = pos_1;
                                                let _e212 = outAr;
                                                let _e214 = y;
                                                r_2 = max((abs(_e209.x) / _e212), abs(_e214));
                                                let _e219 = r_2;
                                                s_1 = (1f - _e219);
                                                let _e221 = r_2;
                                                pAlong = _e221;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e223 = coverage_1;
    let _e225 = thickness_1;
    lo = (1f - (_e223 * (1f + _e225)));
    let _e230 = s_1;
    let _e231 = lo;
    let _e233 = thickness_1;
    local_1 = clamp(((_e230 - _e231) / max(_e233, 0.0001f)), 0f, 1f);
    let _e242 = style_1;
    if (_e242 == 1i) {
        {
            let _e246 = patternDensity_1;
            freq = (1f + (_e246 * 20f));
            let _e253 = pAlong;
            let _e254 = freq;
            pat = (0.5f + (0.5f * cos((_e253 * _e254))));
            let _e260 = pat;
            let _e261 = local_1;
            blend = step(_e260, _e261);
        }
    } else {
        let _e263 = style_1;
        if (_e263 == 2i) {
            {
                let _e267 = patternDensity_1;
                freq_1 = (1f + (_e267 * 20f));
                let _e274 = pos_1;
                let _e276 = freq_1;
                let _e280 = pos_1;
                let _e282 = freq_1;
                pat_1 = (0.5f + ((0.5f * cos((_e274.x * _e276))) * cos((_e280.y * _e282))));
                let _e288 = pat_1;
                let _e289 = local_1;
                blend = step(_e288, _e289);
            }
        } else {
            let _e291 = style_1;
            if (_e291 == 3i) {
                {
                    let _e295 = patternDensity_1;
                    freq_2 = (1f + (_e295 * 20f));
                    let _e300 = pos_1;
                    let _e301 = freq_2;
                    uv = (_e300 * _e301);
                    let _e304 = coverage_1;
                    seed = (_e304 * 4f);
                    loop {
                        let _e342 = i;
                        if !((_e342 < 4i)) {
                            break;
                        }
                        {
                            let _e349 = acc;
                            let _e350 = k_2;
                            let _e351 = uv;
                            let _e352 = seed;
                            let _e356 = perlinNoise3_(vec3<f32>(_e351.x, _e351.y, _e352));
                            acc = (_e349 + (_e350 * _e356));
                            let _e359 = tot;
                            let _e360 = k_2;
                            tot = (_e359 + _e360);
                            let _e362 = k_2;
                            k_2 = (_e362 * 0.5f);
                            let _e365 = oct;
                            let _e366 = uv;
                            uv = (_e365 * _e366);
                        }
                        continuing {
                            let _e346 = i;
                            i = (_e346 + 1i);
                        }
                    }
                    let _e368 = acc;
                    let _e369 = tot;
                    n = (_e368 / _e369);
                    let _e378 = n;
                    let _e382 = sigma;
                    pat_2 = (1f / (1f + exp(((-1.702f * (_e378 - 0.5f)) / _e382))));
                    let _e388 = pat_2;
                    let _e389 = local_1;
                    blend = step(_e388, _e389);
                }
            } else {
                {
                    let _e391 = local_1;
                    blend = _e391;
                }
            }
        }
    }
    let _e392 = outAr;
    let _e393 = source1Dim_1;
    let _e394 = getCoverFitTransform(_e392, _e393);
    let _e395 = viewTransform1_1;
    let _e398 = pos_1;
    let _e399 = tf((_e394 * _naga_inverse_3x3_f32(_e395)), _e398);
    let _e403 = global.U[0];
    let _e406 = outAr;
    let _e407 = source1Dim_1;
    let _e408 = getCoverFitTransform(_e406, _e407);
    let _e409 = viewTransform1_1;
    let _e412 = pos_1;
    let _e413 = tf((_e408 * _naga_inverse_3x3_f32(_e409)), _e412);
    let _e422 = textureSample(t_source1_, samp, ((vec2<f32>((_e399.x / _e403.x), _e413.y) / vec2(2f)) + vec2(0.5f)));
    c1_ = _e422;
    let _e424 = outAr;
    let _e425 = source2Dim_1;
    let _e426 = getCoverFitTransform(_e424, _e425);
    let _e427 = viewTransform2_1;
    let _e430 = pos_1;
    let _e431 = tf((_e426 * _naga_inverse_3x3_f32(_e427)), _e430);
    let _e435 = global.U[0];
    let _e438 = outAr;
    let _e439 = source2Dim_1;
    let _e440 = getCoverFitTransform(_e438, _e439);
    let _e441 = viewTransform2_1;
    let _e444 = pos_1;
    let _e445 = tf((_e440 * _naga_inverse_3x3_f32(_e441)), _e444);
    let _e454 = textureSample(t_source2_, samp, ((vec2<f32>((_e431.x / _e435.x), _e445.y) / vec2(2f)) + vec2(0.5f)));
    c2_ = _e454;
    let _e456 = c1_;
    let _e457 = c2_;
    let _e458 = blend;
    return mix(_e456, _e457, vec4(_e458));
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
    let _e71 = global.U[9];
    let _e76 = global.U[10];
    let _e81 = global.U[11];
    let _e85 = global.U[12];
    let _e89 = global.U[4];
    let _e93 = global.U[5];
    let _e97 = global.U[6];
    let _e101 = global.U[13];
    let _e102 = _e101.xyz;
    let _e105 = global.U[14];
    let _e106 = _e105.xyz;
    let _e109 = global.U[15];
    let _e110 = _e109.xyz;
    let _e126 = global.U[16];
    let _e127 = _e126.xyz;
    let _e130 = global.U[17];
    let _e131 = _e130.xyz;
    let _e134 = global.U[18];
    let _e135 = _e134.xyz;
    let _e149 = sweepCombine((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67.x, i32(_e71.x), i32(_e76.x), _e81.x, _e85.x, _e89.x, _e93.xy, _e97.xy, mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)), mat3x3<f32>(vec3<f32>(_e127.x, _e127.y, _e127.z), vec3<f32>(_e131.x, _e131.y, _e131.z), vec3<f32>(_e135.x, _e135.y, _e135.z)));
    fragColor = _e149;
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
