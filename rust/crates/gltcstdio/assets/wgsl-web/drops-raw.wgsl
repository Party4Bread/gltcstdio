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
@group(0) @binding(3) 
var t_sourceBkg: texture_2d<f32>;

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e10 = c_1;
    let _e12 = vec2(2f);
    return (vec2(1f) - abs(((_e10 - (floor((_e10 / _e12)) * _e12)) - vec2(1f))));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e9 = v_1;
    x = fract((sin(dot(_e9.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e20 = x;
    let _e21 = v_1;
    y = fract((sin(dot(vec2<f32>(_e20, _e21.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e33 = x;
    let _e34 = y;
    return vec2<f32>(_e33, _e34);
}

fn varyNoiseSmoothly(noise: f32, k: f32) -> f32 {
    var noise_1: f32;
    var k_1: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_1 = k;
    let _e12 = noise_1;
    phase = acos(((2f * _e12) - 1f));
    let _e18 = noise_1;
    freq = (fract((_e18 * 16f)) + 0.5f);
    let _e26 = phase;
    let _e27 = freq;
    let _e28 = k_1;
    return ((1f + cos((_e26 + (_e27 * _e28)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_2: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_3: f32;

    noise_3 = noise_2;
    k_3 = k_2;
    let _e11 = noise_3;
    let _e13 = k_3;
    let _e14 = varyNoiseSmoothly(_e11.x, _e13);
    let _e15 = noise_3;
    let _e17 = k_3;
    let _e18 = varyNoiseSmoothly(_e15.y, _e17);
    return vec2<f32>(_e14, _e18);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e11 = co_1;
    let _e12 = rand2_(_e11);
    let _e13 = seed_1;
    let _e14 = varyVec2NoiseSmoothly(_e12, _e13);
    return (_e14 - vec2(0.5f));
}

fn sineMix(val1_: vec2<f32>, val2_: vec2<f32>, k_4: f32) -> vec2<f32> {
    var val1_1: vec2<f32>;
    var val2_1: vec2<f32>;
    var k_5: f32;

    val1_1 = val1_;
    val2_1 = val2_;
    k_5 = k_4;
    let _e13 = val1_1;
    let _e15 = k_5;
    let _e23 = val2_1;
    let _e26 = k_5;
    return (((_e13 * (1f + cos((_e15 * 3.1415927f)))) * 0.5f) + ((_e23 * (1f + cos(((1f - _e26) * 3.1415927f)))) * 0.5f));
}

fn sineSurfaceRand2Seeded(v_2: vec2<f32>, seed_2: f32) -> vec2<f32> {
    var v_3: vec2<f32>;
    var seed_3: f32;
    var u00_: vec2<f32>;
    var u01_: vec2<f32>;
    var u10_: vec2<f32>;
    var u11_: vec2<f32>;
    var r00_: vec2<f32>;
    var r01_: vec2<f32>;
    var r10_: vec2<f32>;
    var r11_: vec2<f32>;

    v_3 = v_2;
    seed_3 = seed_2;
    let _e11 = v_3;
    u00_ = floor(_e11);
    let _e14 = v_3;
    let _e17 = v_3;
    u01_ = vec2<f32>(floor(_e14.x), ceil(_e17.y));
    let _e22 = v_3;
    let _e25 = v_3;
    u10_ = vec2<f32>(ceil(_e22.x), floor(_e25.y));
    let _e30 = v_3;
    u11_ = ceil(_e30);
    let _e33 = u00_;
    let _e34 = rand2_(_e33);
    let _e35 = seed_3;
    let _e36 = varyVec2NoiseSmoothly(_e34, _e35);
    r00_ = (_e36 - vec2<f32>(0.5f, 0.5f));
    let _e42 = u01_;
    let _e43 = rand2_(_e42);
    let _e44 = seed_3;
    let _e45 = varyVec2NoiseSmoothly(_e43, _e44);
    r01_ = (_e45 - vec2<f32>(0.5f, 0.5f));
    let _e51 = u10_;
    let _e52 = rand2_(_e51);
    let _e53 = seed_3;
    let _e54 = varyVec2NoiseSmoothly(_e52, _e53);
    r10_ = (_e54 - vec2<f32>(0.5f, 0.5f));
    let _e60 = u11_;
    let _e61 = rand2_(_e60);
    let _e62 = seed_3;
    let _e63 = varyVec2NoiseSmoothly(_e61, _e62);
    r11_ = (_e63 - vec2<f32>(0.5f, 0.5f));
    let _e69 = r00_;
    let _e70 = r01_;
    let _e71 = v_3;
    let _e74 = sineMix(_e69, _e70, fract(_e71.y));
    let _e75 = r10_;
    let _e76 = r11_;
    let _e77 = v_3;
    let _e80 = sineMix(_e75, _e76, fract(_e77.y));
    let _e81 = v_3;
    let _e84 = sineMix(_e74, _e80, fract(_e81.x));
    return _e84;
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e11 = m_1;
    let _e12 = u_1;
    return (_e11 * vec3<f32>(_e12.x, _e12.y, 1f)).xy;
}

fn drops(uv: vec2<f32>, outPos: vec2<f32>, sourceBkg_specified: i32, intensity: f32, radius: f32, radiusVariability: f32, perturbation: f32, variability: f32, randomSeed: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceBkg_specified_1: i32;
    var intensity_1: f32;
    var radius_1: f32;
    var radiusVariability_1: f32;
    var perturbation_1: f32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v_4: vec2<f32>;
    var ci: f32;
    var cj: f32;
    var k_6: f32 = 0f;
    var minDelta: vec2<f32>;
    var d2min: f32 = 100000000000000000000f;
    var minI: i32 = 0i;
    var minJ: i32 = 0i;
    var minCenter: vec2<f32>;
    var minRadiusModifier: f32;
    var inBubble: bool = false;
    var minRad: f32 = 0f;
    var j: i32 = -2i;
    var i: i32;
    var center: vec2<f32>;
    var delta: vec2<f32>;
    var radiusModifier: f32;
    var rad: f32;
    var rad2_: f32;
    var d: vec2<f32>;
    var d2_: f32;
    var better: bool;
    var dd: vec2<f32>;
    var cd2_: f32;
    var cd: f32;
    var minRad2_: f32;
    var inProj: f32;
    var proj: f32;
    var newPos: vec2<f32>;
    var dd_1: vec2<f32>;
    var rad_1: f32;
    var d_1: f32;
    var hh: f32;
    var h: f32;
    var s: f32;
    var dilation: f32;
    var local: vec4<f32>;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    sourceBkg_specified_1 = sourceBkg_specified;
    intensity_1 = intensity;
    radius_1 = radius;
    radiusVariability_1 = radiusVariability;
    perturbation_1 = perturbation;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    modelTransform_1 = modelTransform;
    let _e27 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e27);
    let _e30 = uv_1;
    u_2 = _e30;
    let _e32 = t;
    let _e33 = uv_1;
    let _e34 = tf(_e32, _e33);
    v_4 = _e34;
    let _e36 = perturbation_1;
    if (_e36 > 0f) {
        {
            let _e39 = v_4;
            let _e40 = v_4;
            let _e42 = perturbation_1;
            let _e47 = randomSeed_1;
            let _e48 = sineSurfaceRand2Seeded((_e40 * (1f + (_e42 * 0f))), _e47);
            let _e51 = perturbation_1;
            v_4 = (_e39 + ((_e48 * 2.5f) * _e51));
        }
    }
    let _e54 = v_4;
    ci = floor(_e54.x);
    let _e58 = v_4;
    cj = floor(_e58.y);
    loop {
        let _e80 = j;
        if !((_e80 <= 2i)) {
            break;
        }
        {
            i = -2i;
            loop {
                let _e90 = i;
                if !((_e90 <= 2i)) {
                    break;
                }
                {
                    let _e97 = i;
                    let _e99 = ci;
                    let _e101 = j;
                    let _e103 = cj;
                    center = vec2<f32>((f32(_e97) + _e99), (f32(_e101) + _e103));
                    let _e107 = center;
                    let _e108 = randomSeed_1;
                    let _e109 = rand2relSeeded(_e107, _e108);
                    delta = _e109;
                    let _e113 = delta;
                    let _e115 = radiusVariability_1;
                    radiusModifier = max(0.01f, (1f + (_e113.x * _e115)));
                    let _e120 = radius_1;
                    let _e121 = radiusModifier;
                    rad = (_e120 * _e121);
                    let _e124 = rad;
                    let _e125 = rad;
                    rad2_ = (_e124 * _e125);
                    let _e128 = center;
                    let _e132 = delta;
                    let _e133 = variability_1;
                    center = (_e128 + (vec2<f32>(0.5f, 0.5f) + ((_e132 * _e133) * 2f)));
                    let _e139 = v_4;
                    let _e140 = center;
                    d = (_e139 - _e140);
                    let _e143 = d;
                    let _e144 = d;
                    d2_ = dot(_e143, _e144);
                    let _e147 = d2_;
                    let _e148 = rad2_;
                    if (_e147 < _e148) {
                        {
                            better = true;
                            let _e152 = inBubble;
                            if _e152 {
                                {
                                    let _e153 = minCenter;
                                    let _e154 = center;
                                    dd = (_e153 - _e154);
                                    let _e157 = dd;
                                    let _e158 = dd;
                                    cd2_ = dot(_e157, _e158);
                                    let _e161 = cd2_;
                                    cd = sqrt(_e161);
                                    let _e164 = minRad;
                                    let _e165 = minRad;
                                    minRad2_ = (_e164 * _e165);
                                    let _e168 = rad2_;
                                    let _e169 = cd2_;
                                    let _e171 = minRad2_;
                                    let _e174 = cd;
                                    inProj = (((_e168 + _e169) - _e171) / (2f * _e174));
                                    let _e178 = v_4;
                                    let _e179 = center;
                                    let _e181 = dd;
                                    let _e183 = cd;
                                    proj = (dot((_e178 - _e179), _e181) / _e183);
                                    let _e186 = proj;
                                    let _e187 = inProj;
                                    better = (_e186 <= _e187);
                                }
                            }
                            let _e189 = better;
                            if _e189 {
                                {
                                    inBubble = true;
                                    let _e191 = d2_;
                                    d2min = _e191;
                                    let _e192 = i;
                                    minI = _e192;
                                    let _e193 = j;
                                    minJ = _e193;
                                    let _e194 = center;
                                    minCenter = _e194;
                                    let _e195 = delta;
                                    minDelta = _e195;
                                    let _e196 = radiusModifier;
                                    minRadiusModifier = _e196;
                                    let _e197 = rad;
                                    minRad = _e197;
                                }
                            }
                        }
                    }
                }
                continuing {
                    let _e94 = i;
                    i = (_e94 + 1i);
                }
            }
        }
        continuing {
            let _e84 = j;
            j = (_e84 + 1i);
        }
    }
    let _e198 = d2min;
    k_6 = sqrt(_e198);
    let _e200 = uv_1;
    newPos = _e200;
    let _e202 = inBubble;
    let _e203 = intensity_1;
    if (_e202 && (_e203 != 0f)) {
        {
            let _e207 = v_4;
            let _e208 = minCenter;
            dd_1 = (_e207 - _e208);
            let _e211 = radius_1;
            let _e212 = minRadiusModifier;
            rad_1 = (_e211 * _e212);
            let _e215 = d2min;
            let _e217 = rad_1;
            d_1 = (sqrt(_e215) / _e217);
            let _e221 = d_1;
            let _e222 = d_1;
            hh = sqrt((1f - (_e221 * _e222)));
            let _e227 = hh;
            if (_e227 != 0f) {
                {
                    let _e231 = hh;
                    h = (1f + _e231);
                    let _e234 = d_1;
                    let _e236 = intensity_1;
                    let _e238 = hh;
                    s = ((-(_e234) * _e236) / _e238);
                    let _e242 = h;
                    let _e243 = s;
                    let _e245 = d_1;
                    dilation = (1f + ((_e242 * _e243) / _e245));
                    let _e249 = modelTransform_1;
                    let _e250 = minCenter;
                    let _e251 = dilation;
                    let _e252 = dd_1;
                    let _e255 = tf(_e249, (_e250 + (_e251 * _e252)));
                    newPos = _e255.xy;
                }
            }
        }
    }
    let _e257 = inBubble;
    let _e258 = sourceBkg_specified_1;
    if (_e257 || (_e258 == 0i)) {
        let _e262 = newPos;
        let _e266 = global.U[0];
        let _e269 = newPos;
        let _e278 = _mirror_wrap(((vec2<f32>((_e262.x / _e266.x), _e269.y) / vec2(2f)) + vec2(0.5f)));
        let _e280 = textureSampleLevel(t_source, samp, _e278, 0f);
        local = _e280;
    } else {
        let _e281 = uv_1;
        let _e285 = global.U[0];
        let _e288 = uv_1;
        let _e297 = _mirror_wrap(((vec2<f32>((_e281.x / _e285.x), _e288.y) / vec2(2f)) + vec2(0.5f)));
        let _e299 = textureSampleLevel(t_sourceBkg, samp, _e297, 0f);
        local = _e299;
    }
    let _e301 = local;
    outColor = _e301;
    let _e303 = outColor;
    return _e303;
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
    let _e67 = global.U[4];
    let _e72 = global.U[6];
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e84 = global.U[9];
    let _e88 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e97 = _e96.xyz;
    let _e100 = global.U[13];
    let _e101 = _e100.xyz;
    let _e104 = global.U[14];
    let _e105 = _e104.xyz;
    let _e119 = drops((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), i32(_e67.x), _e72.x, _e76.x, _e80.x, _e84.x, _e88.x, _e92.x, mat3x3<f32>(vec3<f32>(_e97.x, _e97.y, _e97.z), vec3<f32>(_e101.x, _e101.y, _e101.z), vec3<f32>(_e105.x, _e105.y, _e105.z)));
    fragColor = _e119;
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
