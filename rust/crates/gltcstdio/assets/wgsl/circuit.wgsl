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

fn hash21_(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_1 = p;
    let _e10 = p_1;
    a = fract((-45.3277f * _e10.xy));
    let _e15 = a;
    let _e16 = a;
    let _e17 = a;
    b = (_e15 + vec2(dot(_e16, (_e17 + vec2(123.3371f)))));
    let _e25 = b;
    let _e27 = b;
    return fract((_e25.x * _e27.y));
}

fn hash4_(id: vec2<f32>, id2_: vec2<f32>, regularity: f32, vecSeed: vec4<f32>) -> f32 {
    var id_1: vec2<f32>;
    var id2_1: vec2<f32>;
    var regularity_1: f32;
    var vecSeed_1: vec4<f32>;
    var ida: vec2<f32>;
    var idb: vec2<f32>;
    var local: f32;
    var a_1: f32;
    var b_1: f32;
    var irreg: f32;
    var reg: f32;

    id_1 = id;
    id2_1 = id2_;
    regularity_1 = regularity;
    vecSeed_1 = vecSeed;
    let _e14 = id_1;
    let _e15 = id2_1;
    ida = min(_e14, _e15);
    let _e18 = id_1;
    let _e19 = id2_1;
    idb = max(_e18, _e19);
    let _e22 = ida;
    let _e26 = idb;
    let _e31 = ida;
    let _e33 = id_1;
    let _e36 = ida;
    let _e38 = id_1;
    let _e42 = ida;
    let _e44 = id2_1;
    let _e47 = ida;
    let _e49 = id2_1;
    if (((_e31.x == _e33.x) && (_e36.y == _e38.y)) || ((_e42.x == _e44.x) && (_e47.y == _e49.y))) {
        local = 123.32f;
    } else {
        local = -123.55f;
    }
    let _e58 = local;
    a_1 = fract((dot((_e22 + vec2(23.23f)), (_e26.yx * 10.2232f)) + _e58));
    let _e62 = a_1;
    let _e63 = ida;
    let _e68 = idb;
    b_1 = fract(((_e62 + (_e63.x * 232.23f)) - (_e68.y * 777.77f)));
    let _e75 = a_1;
    let _e78 = b_1;
    let _e80 = a_1;
    let _e81 = b_1;
    irreg = fract(((((_e75 * 5.22f) + _e78) + ((_e80 * _e81) * 23.77f)) + 99.9f));
    let _e90 = ida;
    let _e91 = idb;
    let _e97 = vecSeed_1;
    reg = fract(dot(vec4<f32>(_e90.x, _e90.y, _e91.x, _e91.y), _e97));
    let _e101 = irreg;
    let _e102 = reg;
    let _e103 = regularity_1;
    return mix(_e101, _e102, _e103);
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

fn sdDisk(u: vec2<f32>, r: f32) -> f32 {
    var u_1: vec2<f32>;
    var r_1: f32;

    u_1 = u;
    r_1 = r;
    let _e10 = u_1;
    let _e12 = r_1;
    return (length(_e10) - _e12);
}

fn sdSegment(u_2: vec2<f32>, a_2: vec2<f32>, b_2: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var ua: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    u_3 = u_2;
    a_3 = a_2;
    b_3 = b_2;
    let _e12 = u_3;
    let _e13 = a_3;
    ua = (_e12 - _e13);
    let _e16 = b_3;
    let _e17 = a_3;
    ba = (_e16 - _e17);
    let _e20 = ua;
    let _e21 = ba;
    let _e23 = ba;
    let _e24 = ba;
    h = clamp((dot(_e20, _e21) / dot(_e23, _e24)), 0f, 1f);
    let _e31 = ua;
    let _e32 = ba;
    let _e33 = h;
    return length((_e31 - (_e32 * _e33)));
}

fn circuit(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, randomSeed: f32, regularity_2: f32, thickness: f32, roundness: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var randomSeed_1: f32;
    var regularity_3: f32;
    var thickness_1: f32;
    var roundness_1: f32;
    var uv: vec2<f32>;
    var vecSeed_2: vec4<f32>;
    var rnd: vec2<f32>;
    var density: f32;
    var diagonals: f32;
    var D: f32 = 1000000000f;
    var Y: f32 = -1f;
    var X: f32;
    var id_2: vec2<f32>;
    var u_4: vec2<f32>;
    var d: f32;
    var count: i32;
    var first: vec2<f32>;
    var second: vec2<f32>;
    var y_1: f32;
    var x_1: f32;
    var on: bool;
    var l: f32;
    var local_1: f32;
    var cr: f32;
    var cr_1: f32;
    var c: vec2<f32>;
    var radius: f32;
    var thick: f32;
    var k_4: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    randomSeed_1 = randomSeed;
    regularity_3 = regularity_2;
    thickness_1 = thickness;
    roundness_1 = roundness;
    let _e26 = pos_1;
    uv = _e26;
    let _e31 = randomSeed_1;
    let _e34 = rand2relSeeded(vec2<f32>(0f, 0f), (_e31 - 8f));
    let _e38 = randomSeed_1;
    let _e41 = rand2relSeeded(vec2<f32>(0.5212f, 10f), (_e38 - 8f));
    vecSeed_2 = vec4<f32>(_e34.x, _e34.y, _e41.x, _e41.y);
    let _e51 = randomSeed_1;
    let _e56 = rand2relSeeded(vec2<f32>(1f, 2f), ((_e51 - 8f) * 0.3f));
    rnd = _e56;
    let _e59 = rnd;
    density = (0.55f + (_e59.x * 0.6f));
    let _e66 = rnd;
    diagonals = ((1f - pow((_e66.y + 0.5f), 10f)) * 0.5f);
    loop {
        let _e81 = Y;
        if !((_e81 <= 1f)) {
            break;
        }
        {
            X = -1f;
            loop {
                let _e91 = X;
                if !((_e91 <= 1f)) {
                    break;
                }
                {
                    let _e98 = uv;
                    let _e100 = X;
                    let _e101 = Y;
                    id_2 = (floor(_e98) + vec2<f32>(_e100, _e101));
                    let _e105 = uv;
                    let _e106 = id_2;
                    u_4 = ((_e105 - _e106) - vec2(0.5f));
                    d = 1000000000f;
                    count = 0i;
                    y_1 = -1f;
                    loop {
                        let _e121 = y_1;
                        if !((_e121 <= 1f)) {
                            break;
                        }
                        {
                            x_1 = -1f;
                            loop {
                                let _e131 = x_1;
                                if !((_e131 <= 1f)) {
                                    break;
                                }
                                {
                                    let _e138 = x_1;
                                    let _e141 = y_1;
                                    if ((_e138 != 0f) || (_e141 != 0f)) {
                                        {
                                            let _e145 = id_2;
                                            let _e146 = id_2;
                                            let _e147 = x_1;
                                            let _e148 = y_1;
                                            let _e151 = regularity_3;
                                            let _e152 = vecSeed_2;
                                            let _e153 = hash4_(_e145, (_e146 + vec2<f32>(_e147, _e148)), _e151, _e152);
                                            let _e154 = density;
                                            let _e156 = diagonals;
                                            let _e157 = x_1;
                                            let _e159 = y_1;
                                            on = (_e153 < (_e154 * (1f - (_e156 * (abs(_e157) + abs(_e159))))));
                                            let _e167 = count;
                                            if (_e167 == 0i) {
                                                let _e170 = x_1;
                                                let _e171 = y_1;
                                                first = vec2<f32>(_e170, _e171);
                                            } else {
                                                let _e173 = count;
                                                if (_e173 == 1i) {
                                                    let _e176 = x_1;
                                                    let _e177 = y_1;
                                                    second = vec2<f32>(_e176, _e177);
                                                }
                                            }
                                            let _e179 = on;
                                            if _e179 {
                                                {
                                                    let _e180 = count;
                                                    count = (_e180 + 1i);
                                                    let _e183 = d;
                                                    let _e184 = u_4;
                                                    let _e188 = x_1;
                                                    let _e189 = y_1;
                                                    let _e192 = sdSegment(_e184, vec2(0f), (0.5f * vec2<f32>(_e188, _e189)));
                                                    d = min(_e183, _e192);
                                                }
                                            }
                                        }
                                    }
                                }
                                continuing {
                                    let _e135 = x_1;
                                    x_1 = (_e135 + 1f);
                                }
                            }
                        }
                        continuing {
                            let _e125 = y_1;
                            y_1 = (_e125 + 1f);
                        }
                    }
                    let _e194 = count;
                    if (_e194 == 1i) {
                        {
                            let _e197 = u_4;
                            l = length(_e197);
                            let _e200 = rnd;
                            let _e204 = regularity_3;
                            if ((_e200.x + 0.25f) > _e204) {
                                let _e207 = roundness_1;
                                let _e209 = id_2;
                                let _e210 = hash21_(_e209);
                                local_1 = (((0.25f * _e207) * ceil((_e210 * 2f))) / 2f);
                            } else {
                                let _e218 = roundness_1;
                                local_1 = (0.25f * _e218);
                            }
                            let _e221 = local_1;
                            cr = _e221;
                            let _e223 = l;
                            let _e224 = cr;
                            if (_e223 < _e224) {
                                let _e226 = u_4;
                                let _e227 = cr;
                                let _e228 = sdDisk(_e226, _e227);
                                d = abs(_e228);
                            } else {
                                let _e230 = d;
                                let _e231 = u_4;
                                let _e232 = cr;
                                let _e233 = sdDisk(_e231, _e232);
                                d = min(_e230, abs(_e233));
                            }
                        }
                    } else {
                        let _e236 = count;
                        let _e239 = first;
                        let _e240 = second;
                        if ((_e236 == 2i) && (dot(_e239, _e240) == 0f)) {
                            {
                                let _e246 = roundness_1;
                                cr_1 = (0.5f * _e246);
                                let _e249 = cr_1;
                                let _e250 = first;
                                let _e251 = second;
                                c = (_e249 * (_e250 + _e251));
                                let _e255 = u_4;
                                let _e256 = c;
                                let _e258 = first;
                                let _e263 = u_4;
                                let _e264 = c;
                                let _e266 = second;
                                if ((dot((_e255 - _e256), -(_e258)) >= 0f) && (dot((_e263 - _e264), -(_e266)) >= 0f)) {
                                    {
                                        let _e272 = c;
                                        let _e276 = first;
                                        let _e277 = sdSegment(_e272, vec2<f32>(0f, 0f), _e276);
                                        radius = _e277;
                                        let _e279 = u_4;
                                        let _e280 = c;
                                        let _e282 = radius;
                                        let _e283 = sdDisk((_e279 - _e280), _e282);
                                        d = abs(_e283);
                                    }
                                }
                            }
                        }
                    }
                    let _e285 = D;
                    let _e286 = d;
                    D = min(_e285, _e286);
                }
                continuing {
                    let _e95 = X;
                    X = (_e95 + 1f);
                }
            }
        }
        continuing {
            let _e85 = Y;
            Y = (_e85 + 1f);
        }
    }
    let _e289 = thickness_1;
    thick = (0.15f * _e289);
    let _e292 = thick;
    let _e293 = thick;
    let _e296 = D;
    k_4 = smoothstep(_e292, (_e293 - 0.005f), _e296);
    let _e299 = color1_1;
    let _e300 = color2_1;
    let _e301 = k_4;
    outColor = mix(_e299, _e300, vec4(_e301));
    let _e305 = source_specified_1;
    if (_e305 == 1i) {
        let _e308 = outPos_1;
        let _e312 = global.U[0];
        let _e315 = outPos_1;
        let _e324 = textureSample(t_source, samp, ((vec2<f32>((_e308.x / _e312.x), _e315.y) / vec2(2f)) + vec2(0.5f)));
        let _e325 = outColor;
        let _e326 = mergeColor(_e324, _e325);
        return _e326;
    } else {
        let _e327 = outColor;
        return _e327;
    }
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
    let _e96 = global.U[9];
    let _e99 = global.U[10];
    let _e102 = global.U[11];
    let _e106 = global.U[12];
    let _e110 = global.U[13];
    let _e114 = global.U[14];
    let _e116 = circuit((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), i32(_e91.x), _e96, _e99, _e102.x, _e106.x, _e110.x, _e114.x);
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
