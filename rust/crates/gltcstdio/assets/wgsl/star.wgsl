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

fn starFlare(uv: vec2<f32>, pixel: f32) -> f32 {
    var uv_1: vec2<f32>;
    var pixel_1: f32;
    var local: f32;
    var spike: f32;

    uv_1 = uv;
    pixel_1 = pixel;
    let _e10 = uv_1;
    uv_1 = abs(_e10);
    let _e12 = uv_1;
    let _e14 = uv_1;
    if (_e12.y > _e14.x) {
        let _e17 = uv_1;
        let _e19 = pixel_1;
        let _e24 = uv_1;
        let _e26 = pixel_1;
        let _e32 = uv_1;
        local = ((log(max((_e17.x + _e19), 0.001f)) - log(max((_e24.x - _e26), 0.001f))) / _e32.y);
    } else {
        let _e35 = uv_1;
        let _e37 = pixel_1;
        let _e42 = uv_1;
        let _e44 = pixel_1;
        let _e50 = uv_1;
        local = ((log(max((_e35.y + _e37), 0.001f)) - log(max((_e42.y - _e44), 0.001f))) / _e50.x);
    }
    let _e54 = local;
    spike = _e54;
    let _e56 = spike;
    return _e56;
}

fn star(uv_2: vec2<f32>, pixel_2: f32, center: f32, flare1_: f32, flare2_: f32) -> f32 {
    var uv_3: vec2<f32>;
    var pixel_3: f32;
    var center_1: f32;
    var flare1_1: f32;
    var flare2_1: f32;
    var rot45_: mat2x2<f32> = mat2x2<f32>(vec2<f32>(0.70710677f, 0.70710677f), vec2<f32>(-0.70710677f, 0.70710677f));

    uv_3 = uv_2;
    pixel_3 = pixel_2;
    center_1 = center;
    flare1_1 = flare1_;
    flare2_1 = flare2_;
    let _e25 = center_1;
    let _e26 = uv_3;
    let _e31 = flare1_1;
    let _e32 = uv_3;
    let _e33 = pixel_3;
    let _e34 = starFlare(_e32, _e33);
    let _e37 = flare2_1;
    let _e38 = rot45_;
    let _e39 = uv_3;
    let _e41 = pixel_3;
    let _e42 = starFlare((_e38 * _e39), _e41);
    return (((_e25 / pow(length(_e26), 2f)) + (_e31 * _e34)) + (_e37 * _e42));
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn star_1(uv_4: vec2<f32>, outPos: vec2<f32>, count: i32, intensity: f32, blend: f32, center_2: f32, secondary: f32, thickness: f32, randomSeed: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_5: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var blend_1: f32;
    var center_3: f32;
    var secondary_1: f32;
    var thickness_1: f32;
    var randomSeed_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var u_2: vec2<f32>;
    var lum: f32;
    var i: i32 = 1i;
    var delta: vec2<f32>;
    var col: vec4<f32>;
    var bkgCol: vec4<f32>;
    var k1_: f32;
    var k2_: f32;
    var outCol: vec4<f32>;

    uv_5 = uv_4;
    outPos_1 = outPos;
    count_1 = count;
    intensity_1 = intensity;
    blend_1 = blend;
    center_3 = center_2;
    secondary_1 = secondary;
    thickness_1 = thickness;
    randomSeed_1 = randomSeed;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e28 = modelTransform_1;
    let _e30 = uv_5;
    let _e31 = tf(_naga_inverse_3x3_f32(_e28), _e30);
    u_2 = _e31;
    let _e33 = intensity_1;
    let _e34 = u_2;
    let _e35 = thickness_1;
    let _e38 = center_3;
    let _e40 = secondary_1;
    let _e41 = star(_e34, (_e35 * 0.2f), _e38, 1f, _e40);
    lum = (_e33 * _e41);
    loop {
        let _e46 = i;
        let _e47 = count_1;
        if !((_e46 < _e47)) {
            break;
        }
        {
            let _e53 = i;
            let _e56 = randomSeed_1;
            let _e57 = rand2relSeeded(vec2(f32(_e53)), _e56);
            let _e59 = i;
            delta = (_e57 * (30f + (f32(_e59) * 2f)));
            let _e66 = lum;
            let _e67 = intensity_1;
            let _e68 = delta;
            let _e72 = delta;
            let _e79 = u_2;
            let _e80 = delta;
            let _e82 = thickness_1;
            let _e85 = center_3;
            let _e87 = secondary_1;
            let _e88 = star((_e79 + _e80), (_e82 * 0.2f), _e85, 1f, _e87);
            lum = (_e66 + ((_e67 * fract(((_e68.x * 4f) + (_e72.y * 3f)))) * _e88));
        }
        continuing {
            let _e50 = i;
            i = (_e50 + 1i);
        }
    }
    let _e91 = lum;
    let _e92 = color_1;
    let _e95 = (_e91 * vec3<f32>(_e92.xyz));
    let _e96 = color_1;
    col = vec4<f32>(_e95.x, _e95.y, _e95.z, _e96.w);
    let _e103 = uv_5;
    let _e107 = global.U[0];
    let _e110 = uv_5;
    let _e119 = textureSample(t_source, samp, ((vec2<f32>((_e103.x / _e107.x), _e110.y) / vec2(2f)) + vec2(0.5f)));
    bkgCol = _e119;
    let _e121 = blend_1;
    k1_ = _e121;
    let _e124 = blend_1;
    k2_ = (1f - _e124);
    let _e127 = bkgCol;
    let _e128 = bkgCol;
    let _e129 = col;
    let _e131 = k2_;
    let _e132 = k1_;
    let _e133 = lum;
    let _e134 = k2_;
    outCol = mix(_e127, (_e128 + _e129), vec4((_e131 + (_e132 * min(((_e133 * _e134) * 10f), 1f)))));
    let _e145 = outCol;
    return _e145;
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
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e91 = global.U[11];
    let _e95 = global.U[12];
    let _e98 = global.U[13];
    let _e99 = _e98.xyz;
    let _e102 = global.U[14];
    let _e103 = _e102.xyz;
    let _e106 = global.U[15];
    let _e107 = _e106.xyz;
    let _e121 = star_1((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83.x, _e87.x, _e91.x, _e95, mat3x3<f32>(vec3<f32>(_e99.x, _e99.y, _e99.z), vec3<f32>(_e103.x, _e103.y, _e103.z), vec3<f32>(_e107.x, _e107.y, _e107.z)));
    fragColor = _e121;
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
