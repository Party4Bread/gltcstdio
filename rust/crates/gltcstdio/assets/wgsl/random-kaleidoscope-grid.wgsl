struct Params {
    U: array<vec4<f32>, 12>,
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

fn reflct(d: f32, sourceAngle: f32, alpha: f32, halfAlpha: f32) -> vec2<f32> {
    var d_1: f32;
    var sourceAngle_1: f32;
    var alpha_1: f32;
    var halfAlpha_1: f32;

    d_1 = d;
    sourceAngle_1 = sourceAngle;
    alpha_1 = alpha;
    halfAlpha_1 = halfAlpha;
    let _e14 = sourceAngle_1;
    let _e15 = halfAlpha_1;
    if (_e14 > _e15) {
        let _e17 = alpha_1;
        let _e18 = sourceAngle_1;
        sourceAngle_1 = (_e17 - _e18);
    }
    let _e20 = d_1;
    let _e21 = sourceAngle_1;
    let _e23 = sourceAngle_1;
    return (_e20 * vec2<f32>(cos(_e21), sin(_e23)));
}

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn kaleidoscope(pos: vec2<f32>, outPos: vec2<f32>, spikeCount: i32, texTransform: mat3x3<f32>, blend: f32, randomSeed: f32, variability: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var spikeCount_1: i32;
    var texTransform_1: mat3x3<f32>;
    var blend_1: f32;
    var randomSeed_1: f32;
    var variability_1: f32;
    var totalWeight: f32 = 0f;
    var totalCol: vec4<f32> = vec4(0f);
    var totalCoord: vec2<f32> = vec2(0f);
    var lightestCol: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var lightestVal: f32 = 0f;
    var lighting: f32 = 1f;
    var N: f32 = 1f;
    var j: f32;
    var i: f32;
    var u_2: vec2<f32>;
    var id: vec2<f32>;
    var center: vec2<f32>;
    var d_2: f32;
    var weight: f32;
    var local: f32;
    var borderDist: vec2<f32>;
    var lightFactor: vec2<f32>;
    var lightStrength: f32;
    var squareWeight: f32;
    var circleWeight: f32;
    var b: f32;
    var sourceAngle_2: f32;
    var halfAlpha_2: f32;
    var alpha_2: f32;
    var ang: f32;
    var coord: vec2<f32>;
    var angle: f32;
    var scale: f32;
    var t: vec2<f32>;
    var rnd: vec2<f32>;
    var tc: vec2<f32>;
    var tcc: vec2<f32>;
    var col: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    spikeCount_1 = spikeCount;
    texTransform_1 = texTransform;
    blend_1 = blend;
    randomSeed_1 = randomSeed;
    variability_1 = variability;
    let _e40 = N;
    j = -(_e40);
    loop {
        let _e43 = j;
        let _e44 = N;
        if !((_e43 <= _e44)) {
            break;
        }
        {
            let _e50 = N;
            i = -(_e50);
            loop {
                let _e53 = i;
                let _e54 = N;
                if !((_e53 <= _e54)) {
                    break;
                }
                {
                    let _e60 = pos_1;
                    u_2 = _e60;
                    let _e62 = u_2;
                    let _e70 = i;
                    let _e71 = j;
                    id = (floor(((_e62 + vec2(1f)) / vec2(2f))) + vec2<f32>(_e70, _e71));
                    let _e75 = id;
                    center = (_e75 * 2f);
                    let _e79 = u_2;
                    let _e80 = center;
                    u_2 = (_e79 - _e80);
                    let _e82 = u_2;
                    d_2 = length(_e82);
                    let _e86 = blend_1;
                    if (_e86 <= 0f) {
                        {
                            let _e89 = u_2;
                            let _e92 = u_2;
                            if (max(abs(_e89.x), abs(_e92.y)) <= 1f) {
                                local = 1f;
                            } else {
                                local = 0f;
                            }
                            let _e101 = local;
                            weight = _e101;
                            let _e102 = u_2;
                            borderDist = (_e102 - vec2(-1f));
                            let _e110 = borderDist;
                            lightFactor = smoothstep(vec2(0f), vec2(1.4f), _e110);
                            let _e115 = lightFactor;
                            let _e117 = lightFactor;
                            lightStrength = (_e115.x * _e117.y);
                            let _e121 = i;
                            let _e124 = j;
                            if ((_e121 == 0f) && (_e124 == 0f)) {
                                let _e129 = lightStrength;
                                let _e130 = blend_1;
                                lighting = mix(1f, _e129, -(_e130));
                            }
                        }
                    } else {
                        let _e133 = blend_1;
                        if (_e133 < 0.15f) {
                            {
                                let _e137 = blend_1;
                                let _e140 = blend_1;
                                let _e142 = u_2;
                                let _e145 = u_2;
                                weight = smoothstep((1f + _e137), (1f - _e140), max(abs(_e142.x), abs(_e145.y)));
                            }
                        } else {
                            let _e150 = blend_1;
                            if (_e150 < 0.3f) {
                                {
                                    let _e159 = u_2;
                                    let _e162 = u_2;
                                    squareWeight = smoothstep(1.15f, 0.85f, max(abs(_e159.x), abs(_e162.y)));
                                    let _e174 = d_2;
                                    circleWeight = smoothstep(1.55f, 1.25f, _e174);
                                    let _e177 = squareWeight;
                                    let _e178 = circleWeight;
                                    let _e179 = blend_1;
                                    weight = mix(_e177, _e178, ((_e179 - 0.15f) / 0.15f));
                                }
                            } else {
                                {
                                    let _e187 = blend_1;
                                    b = mix(0.15f, 1f, ((_e187 - 0.3f) / 0.7f));
                                    let _e195 = b;
                                    let _e198 = b;
                                    let _e200 = d_2;
                                    weight = smoothstep((1.4f + _e195), (1.4f - _e198), _e200);
                                }
                            }
                        }
                    }
                    let _e202 = weight;
                    if (_e202 > 0f) {
                        {
                            sourceAngle_2 = 0f;
                            halfAlpha_2 = 0f;
                            alpha_2 = 0f;
                            let _e211 = d_2;
                            if (_e211 > 0f) {
                                {
                                    let _e214 = u_2;
                                    let _e216 = u_2;
                                    ang = atan2(_e214.y, _e216.x);
                                    let _e220 = ang;
                                    if (_e220 < 0f) {
                                        let _e223 = ang;
                                        ang = (_e223 + 6.2831855f);
                                    }
                                    let _e227 = spikeCount_1;
                                    halfAlpha_2 = (3.1415927f / f32(_e227));
                                    let _e230 = halfAlpha_2;
                                    alpha_2 = (_e230 * 2f);
                                    let _e233 = ang;
                                    let _e234 = alpha_2;
                                    sourceAngle_2 = (_e233 - (floor((_e233 / _e234)) * _e234));
                                }
                            }
                            let _e239 = d_2;
                            let _e240 = sourceAngle_2;
                            let _e241 = alpha_2;
                            let _e242 = halfAlpha_2;
                            let _e243 = reflct(_e239, _e240, _e241, _e242);
                            coord = _e243;
                            angle = 0f;
                            scale = 1f;
                            t = vec2<f32>(0f, 0f);
                            let _e253 = id;
                            let _e257 = id;
                            if ((_e253.x != 0f) || (_e257.y != 0f)) {
                                {
                                    let _e262 = id;
                                    let _e263 = randomSeed_1;
                                    let _e264 = rand2relSeeded(_e262, _e263);
                                    rnd = _e264;
                                    let _e266 = variability_1;
                                    let _e267 = rnd;
                                    angle = (((_e266 * _e267.x) * 3.1415927f) * 2f);
                                    let _e274 = variability_1;
                                    let _e275 = rnd;
                                    scale = (((_e274 * _e275.y) * 0.2f) + 1f);
                                    let _e282 = variability_1;
                                    let _e283 = rnd;
                                    t = ((_e282 * _e283) * 2f);
                                }
                            }
                            let _e287 = texTransform_1;
                            let _e289 = coord;
                            let _e290 = tf(_naga_inverse_3x3_f32(_e287), _e289);
                            tc = _e290;
                            let _e292 = scale;
                            let _e293 = angle;
                            let _e295 = tc;
                            let _e298 = angle;
                            let _e300 = tc;
                            let _e305 = t;
                            let _e308 = scale;
                            let _e309 = angle;
                            let _e312 = tc;
                            let _e315 = angle;
                            let _e317 = tc;
                            let _e322 = t;
                            tcc = vec2<f32>(((_e292 * ((cos(_e293) * _e295.x) + (sin(_e298) * _e300.y))) + _e305.x), ((_e308 * ((-(sin(_e309)) * _e312.x) + (cos(_e315) * _e317.y))) + _e322.y));
                            let _e327 = tcc;
                            let _e331 = global.U[0];
                            let _e334 = tcc;
                            let _e343 = _mirror_wrap(((vec2<f32>((_e327.x / _e331.x), _e334.y) / vec2(2f)) + vec2(0.5f)));
                            let _e344 = textureSample(t_source, samp, _e343);
                            col = _e344;
                            let _e346 = totalCol;
                            let _e347 = weight;
                            let _e348 = col;
                            totalCol = (_e346 + (_e347 * _e348));
                            let _e351 = totalWeight;
                            let _e352 = weight;
                            totalWeight = (_e351 + _e352);
                        }
                    }
                }
                continuing {
                    let _e57 = i;
                    i = (_e57 + 1f);
                }
            }
        }
        continuing {
            let _e47 = j;
            j = (_e47 + 1f);
        }
    }
    let _e354 = totalCol;
    let _e355 = totalWeight;
    let _e358 = lighting;
    let _e359 = vec3(_e358);
    return ((_e354 / vec4(_e355)) * vec4<f32>(_e359.x, _e359.y, _e359.z, 1f));
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
    let _e71 = global.U[6];
    let _e72 = _e71.xyz;
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e96 = global.U[9];
    let _e100 = global.U[10];
    let _e104 = global.U[11];
    let _e106 = kaleidoscope((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), _e96.x, _e100.x, _e104.x);
    fragColor = _e106;
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
