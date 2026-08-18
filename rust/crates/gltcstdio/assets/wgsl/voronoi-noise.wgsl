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

fn voronoiNoise(pos: vec2<f32>, outPos: vec2<f32>, source_specified: i32, viewTransform: mat3x3<f32>, octaves: i32, variability: f32, randomSeed: f32, color1_: vec4<f32>, color2_: vec4<f32>, threshold: f32, thresholdColor: vec4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var viewTransform_1: mat3x3<f32>;
    var octaves_1: i32;
    var variability_1: f32;
    var randomSeed_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var threshold_1: f32;
    var thresholdColor_1: vec4<f32>;
    var u: vec2<f32>;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var total: f32 = 0f;
    var noise_4: f32 = 0f;
    var amplitude: f32 = 1f;
    var k_4: i32 = 0i;
    var v_2: vec2<f32>;
    var closest: f32;
    var j: i32;
    var i: i32;
    var point: vec2<f32>;
    var displace: vec2<f32>;
    var distance: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    viewTransform_1 = viewTransform;
    octaves_1 = octaves;
    variability_1 = variability;
    randomSeed_1 = randomSeed;
    color1_1 = color1_;
    color2_1 = color2_;
    threshold_1 = threshold;
    thresholdColor_1 = thresholdColor;
    let _e28 = pos_1;
    u = _e28;
    loop {
        let _e64 = k_4;
        let _e65 = octaves_1;
        if !((_e64 < _e65)) {
            break;
        }
        {
            let _e71 = u;
            let _e75 = u;
            v_2 = floor(vec2<f32>((_e71.x + 0.5f), (_e75.y + 0.5f)));
            closest = 1000000000f;
            j = -2i;
            loop {
                let _e87 = j;
                if !((_e87 <= 2i)) {
                    break;
                }
                {
                    i = -2i;
                    loop {
                        let _e97 = i;
                        if !((_e97 <= 2i)) {
                            break;
                        }
                        {
                            let _e104 = v_2;
                            let _e106 = i;
                            let _e109 = v_2;
                            let _e111 = j;
                            point = vec2<f32>((_e104.x + f32(_e106)), (_e109.y + f32(_e111)));
                            let _e116 = point;
                            let _e117 = randomSeed_1;
                            let _e118 = rand2relSeeded(_e116, _e117);
                            let _e119 = variability_1;
                            displace = ((_e118 * _e119) * 2f);
                            let _e124 = point;
                            let _e125 = displace;
                            let _e127 = u;
                            distance = length(((_e124 + _e125) - _e127));
                            let _e131 = distance;
                            let _e132 = closest;
                            if (_e131 < _e132) {
                                {
                                    let _e134 = distance;
                                    closest = _e134;
                                }
                            }
                        }
                        continuing {
                            let _e101 = i;
                            i = (_e101 + 1i);
                        }
                    }
                }
                continuing {
                    let _e91 = j;
                    j = (_e91 + 1i);
                }
            }
            let _e135 = total;
            let _e136 = amplitude;
            total = (_e135 + _e136);
            let _e138 = noise_4;
            let _e139 = amplitude;
            let _e140 = closest;
            noise_4 = (_e138 + (_e139 * _e140));
            let _e143 = amplitude;
            amplitude = (_e143 * 0.5f);
            let _e146 = u;
            u = ((_e146 * 2f) + vec2<f32>(1.34f, 2.55f));
        }
        continuing {
            let _e68 = k_4;
            k_4 = (_e68 + 1i);
        }
    }
    let _e153 = noise_4;
    let _e154 = total;
    noise_4 = (_e153 / _e154);
    let _e157 = threshold_1;
    if (_e157 == 0f) {
        let _e160 = color1_1;
        let _e161 = color2_1;
        let _e162 = noise_4;
        outColor = mix(_e160, _e161, vec4(_e162));
    } else {
        let _e165 = threshold_1;
        if (_e165 < 0f) {
            {
                let _e168 = noise_4;
                let _e170 = threshold_1;
                if (_e168 >= (1f + _e170)) {
                    {
                        let _e173 = thresholdColor_1;
                        outColor = _e173;
                    }
                } else {
                    {
                        let _e174 = color1_1;
                        let _e175 = color2_1;
                        let _e176 = noise_4;
                        let _e178 = threshold_1;
                        outColor = mix(_e174, _e175, vec4((_e176 / (1f + _e178))));
                    }
                }
            }
        } else {
            {
                let _e183 = noise_4;
                let _e184 = threshold_1;
                if (_e183 <= _e184) {
                    {
                        let _e186 = thresholdColor_1;
                        outColor = _e186;
                    }
                } else {
                    {
                        let _e187 = color1_1;
                        let _e188 = color2_1;
                        let _e189 = noise_4;
                        let _e190 = threshold_1;
                        let _e193 = threshold_1;
                        outColor = mix(_e187, _e188, vec4(((_e189 - _e190) / (1f - _e193))));
                    }
                }
            }
        }
    }
    let _e198 = source_specified_1;
    if (_e198 == 1i) {
        let _e201 = outPos_1;
        let _e205 = global.U[0];
        let _e208 = outPos_1;
        let _e217 = textureSample(t_source, samp, ((vec2<f32>((_e201.x / _e205.x), _e208.y) / vec2(2f)) + vec2(0.5f)));
        let _e218 = outColor;
        let _e219 = mergeColor(_e217, _e218);
        return _e219;
    } else {
        let _e220 = outColor;
        return _e220;
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
    let _e66 = global.U[4];
    let _e71 = global.U[1];
    let _e72 = _e71.xyz;
    let _e75 = global.U[2];
    let _e76 = _e75.xyz;
    let _e79 = global.U[3];
    let _e80 = _e79.xyz;
    let _e96 = global.U[6];
    let _e101 = global.U[7];
    let _e105 = global.U[8];
    let _e109 = global.U[9];
    let _e112 = global.U[10];
    let _e115 = global.U[11];
    let _e119 = global.U[12];
    let _e120 = voronoiNoise((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)), i32(_e96.x), _e101.x, _e105.x, _e109, _e112, _e115.x, _e119);
    fragColor = _e120;
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
