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

fn changeIn01_(x: f32, range: f32, k: f32) -> f32 {
    var x_1: f32;
    var range_1: f32;
    var k_1: f32;
    var r2_: f32;
    var a: f32;
    var b: f32;

    x_1 = x;
    range_1 = range;
    k_1 = k;
    let _e11 = range_1;
    r2_ = (_e11 * 0.5f);
    let _e15 = x_1;
    let _e16 = r2_;
    a = (_e15 - _e16);
    let _e19 = x_1;
    let _e20 = r2_;
    b = (_e19 + _e20);
    let _e23 = a;
    if (_e23 < 0f) {
        {
            let _e26 = b;
            let _e27 = a;
            b = (_e26 - _e27);
            a = 0f;
        }
    }
    let _e30 = b;
    if (_e30 > 1f) {
        {
            let _e33 = a;
            let _e35 = b;
            a = (_e33 + (1f - _e35));
            b = 1f;
        }
    }
    let _e39 = a;
    let _e40 = b;
    let _e41 = a;
    let _e43 = k_1;
    return (_e39 + ((_e40 - _e41) * _e43));
}

fn hash23_(u: vec2<f32>) -> vec3<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e7 = u_1;
    let _e11 = u_1;
    let _e20 = u_1;
    let _e24 = u_1;
    let _e33 = u_1;
    let _e37 = u_1;
    return vec3<f32>(fract((sin(((_e7.x * 776.45f) + (_e11.y * 453.24f))) * 45.77f)), fract((sin(((_e20.x * 376.45f) + (_e24.y * 853.24f))) * 88.77f)), fract((sin(((_e33.x * 457.77f) + (_e37.y * 667.17f))) * 65.57f)));
}

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x_2: f32;
    var y: f32;

    v_1 = v;
    let _e7 = v_1;
    x_2 = fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e18 = x_2;
    let _e19 = v_1;
    y = fract((sin(dot(vec2<f32>(_e18, _e19.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e31 = x_2;
    let _e32 = y;
    return vec2<f32>(_e31, _e32);
}

fn varyNoiseSmoothly(noise: f32, k_2: f32) -> f32 {
    var noise_1: f32;
    var k_3: f32;
    var phase: f32;
    var freq: f32;

    noise_1 = noise;
    k_3 = k_2;
    let _e10 = noise_1;
    phase = acos(((2f * _e10) - 1f));
    let _e16 = noise_1;
    freq = (fract((_e16 * 16f)) + 0.5f);
    let _e24 = phase;
    let _e25 = freq;
    let _e26 = k_3;
    return ((1f + cos((_e24 + (_e25 * _e26)))) * 0.5f);
}

fn varyVec2NoiseSmoothly(noise_2: vec2<f32>, k_4: f32) -> vec2<f32> {
    var noise_3: vec2<f32>;
    var k_5: f32;

    noise_3 = noise_2;
    k_5 = k_4;
    let _e9 = noise_3;
    let _e11 = k_5;
    let _e12 = varyNoiseSmoothly(_e9.x, _e11);
    let _e13 = noise_3;
    let _e15 = k_5;
    let _e16 = varyNoiseSmoothly(_e13.y, _e15);
    return vec2<f32>(_e12, _e16);
}

fn rand2relSeeded(co: vec2<f32>, seed: f32) -> vec2<f32> {
    var co_1: vec2<f32>;
    var seed_1: f32;

    co_1 = co;
    seed_1 = seed;
    let _e9 = co_1;
    let _e10 = rand2_(_e9);
    let _e11 = seed_1;
    let _e12 = varyVec2NoiseSmoothly(_e10, _e11);
    return (_e12 - vec2(0.5f));
}

fn randomConeGradients(u_2: vec2<f32>, outPos: vec2<f32>, color1_: vec4<f32>, color2_: vec4<f32>, color3_: vec4<f32>, color4_: vec4<f32>, colorBkg: vec4<f32>, hardness: f32, variability: f32, colorVariability: f32, randomSeed: f32, acuteness: f32, radiality: f32) -> vec4<f32> {
    var u_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var color3_1: vec4<f32>;
    var color4_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var hardness_1: f32;
    var variability_1: f32;
    var colorVariability_1: f32;
    var randomSeed_1: f32;
    var acuteness_1: f32;
    var radiality_1: f32;
    var intensity: f32;
    var b_1: vec2<f32>;
    var N: f32;
    var totalW: f32;
    var col: vec3<f32>;
    var j: f32;
    var i: f32;
    var id: vec2<f32>;
    var rnd1_: vec2<f32>;
    var rnd2_: vec2<f32>;
    var c: vec2<f32>;
    var dir: vec2<f32>;
    var d: f32;
    var local: f32;
    var w: f32;
    var selector: f32;
    var rndR: f32;
    var rndB: f32;
    var rndG: f32;
    var local_1: vec4<f32>;
    var local_2: vec4<f32>;
    var local_3: vec4<f32>;
    var baseCol: vec4<f32>;

    u_3 = u_2;
    outPos_1 = outPos;
    color1_1 = color1_;
    color2_1 = color2_;
    color3_1 = color3_;
    color4_1 = color4_;
    colorBkg_1 = colorBkg;
    hardness_1 = hardness;
    variability_1 = variability;
    colorVariability_1 = colorVariability;
    randomSeed_1 = randomSeed;
    acuteness_1 = acuteness;
    radiality_1 = radiality;
    let _e31 = variability_1;
    intensity = (_e31 * 4f);
    let _e35 = u_3;
    b_1 = floor((_e35 + vec2(0.5f)));
    let _e43 = intensity;
    N = floor((2f + (0.5f * abs(_e43))));
    let _e49 = colorBkg_1;
    let _e51 = colorBkg_1;
    totalW = ((_e49.w * _e51.w) * 2f);
    let _e57 = totalW;
    let _e58 = colorBkg_1;
    col = (_e57 * _e58.xyz);
    let _e62 = b_1;
    let _e64 = N;
    j = (_e62.y - _e64);
    loop {
        let _e67 = j;
        let _e68 = b_1;
        let _e70 = N;
        if !((_e67 <= (_e68.y + _e70))) {
            break;
        }
        {
            let _e77 = b_1;
            let _e79 = N;
            i = (_e77.x - _e79);
            loop {
                let _e82 = i;
                let _e83 = b_1;
                let _e85 = N;
                if !((_e82 <= (_e83.x + _e85))) {
                    break;
                }
                {
                    let _e92 = i;
                    let _e93 = j;
                    id = vec2<f32>(_e92, _e93);
                    let _e96 = id;
                    let _e97 = randomSeed_1;
                    let _e98 = rand2relSeeded(_e96, _e97);
                    rnd1_ = _e98;
                    let _e100 = id;
                    let _e104 = randomSeed_1;
                    let _e105 = rand2relSeeded((_e100 + vec2(1f)), _e104);
                    rnd2_ = _e105;
                    let _e107 = id;
                    let _e108 = intensity;
                    let _e109 = rnd1_;
                    c = (_e107 + (_e108 * _e109));
                    let _e113 = rnd2_;
                    let _e114 = c;
                    let _e116 = radiality_1;
                    dir = normalize(mix(_e113, normalize(_e114), vec2(_e116)));
                    let _e121 = u_3;
                    let _e122 = c;
                    d = length((_e121 - _e122));
                    let _e130 = d;
                    let _e136 = hardness_1;
                    let _e140 = acuteness_1;
                    if (_e140 == 1f) {
                        local = 1f;
                    } else {
                        let _e147 = u_3;
                        let _e148 = c;
                        let _e151 = dir;
                        let _e155 = acuteness_1;
                        local = pow(smoothstep(-1f, 1f, dot(normalize((_e147 - _e148)), _e151)), (2f - (_e155 * 2f)));
                    }
                    let _e161 = local;
                    w = (pow((0.001f + (0.999f * smoothstep(1.64f, 0f, _e130))), (2.2f + (1.6f * _e136))) * _e161);
                    let _e164 = rnd1_;
                    let _e167 = (_e164.x * 40f);
                    selector = (_e167 - (floor((_e167 / 4f)) * 4f));
                    let _e174 = rnd1_;
                    rndR = fract((_e174.y * 10f));
                    let _e180 = rnd2_;
                    rndB = fract((_e180.x * 10f));
                    let _e186 = rnd2_;
                    rndG = fract((_e186.y * 10f));
                    let _e192 = selector;
                    if (_e192 < 1f) {
                        let _e195 = color1_1;
                        local_3 = _e195;
                    } else {
                        let _e196 = selector;
                        if (_e196 < 2f) {
                            let _e199 = color2_1;
                            local_2 = _e199;
                        } else {
                            let _e200 = selector;
                            if (_e200 < 3f) {
                                let _e203 = color3_1;
                                local_1 = _e203;
                            } else {
                                let _e204 = color4_1;
                                local_1 = _e204;
                            }
                            let _e206 = local_1;
                            local_2 = _e206;
                        }
                        let _e208 = local_2;
                        local_3 = _e208;
                    }
                    let _e210 = local_3;
                    baseCol = _e210;
                    let _e213 = baseCol;
                    let _e215 = colorVariability_1;
                    let _e216 = rndR;
                    let _e217 = changeIn01_(_e213.x, _e215, _e216);
                    baseCol.x = _e217;
                    let _e219 = baseCol;
                    let _e221 = colorVariability_1;
                    let _e222 = rndG;
                    let _e223 = changeIn01_(_e219.y, _e221, _e222);
                    baseCol.y = _e223;
                    let _e225 = baseCol;
                    let _e227 = colorVariability_1;
                    let _e228 = rndB;
                    let _e229 = changeIn01_(_e225.z, _e227, _e228);
                    baseCol.z = _e229;
                    let _e230 = col;
                    let _e231 = w;
                    let _e232 = baseCol;
                    col = (_e230 + (_e231 * _e232.xyz));
                    let _e236 = totalW;
                    let _e237 = w;
                    totalW = (_e236 + _e237);
                }
                continuing {
                    let _e89 = i;
                    i = (_e89 + 1f);
                }
            }
        }
        continuing {
            let _e74 = j;
            j = (_e74 + 1f);
        }
    }
    let _e239 = col;
    let _e240 = totalW;
    let _e242 = (_e239 / vec3(_e240));
    return vec4<f32>(_e242.x, _e242.y, _e242.z, 1f);
}

fn main_1() {
    let _e7 = global.U[1];
    let _e8 = _e7.xyz;
    let _e11 = global.U[2];
    let _e12 = _e11.xyz;
    let _e15 = global.U[3];
    let _e16 = _e15.xyz;
    let _e31 = v_uv_1;
    let _e39 = global.U[0];
    let _e43 = (((_e31 - vec2(0.5f)) * 2f) * vec2<f32>(_e39.x, 1f));
    let _e50 = v_uv_1;
    let _e58 = global.U[0];
    let _e65 = global.U[5];
    let _e68 = global.U[6];
    let _e71 = global.U[7];
    let _e74 = global.U[8];
    let _e77 = global.U[9];
    let _e80 = global.U[10];
    let _e84 = global.U[11];
    let _e88 = global.U[12];
    let _e92 = global.U[13];
    let _e96 = global.U[14];
    let _e100 = global.U[15];
    let _e102 = randomConeGradients((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68, _e71, _e74, _e77, _e80.x, _e84.x, _e88.x, _e92.x, _e96.x, _e100.x);
    fragColor = _e102;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e11 = fragColor;
    return FragmentOutput(_e11);
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
