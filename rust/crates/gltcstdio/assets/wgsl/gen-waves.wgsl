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

fn getColor(k: f32, base: vec3<f32>, variability: f32) -> vec3<f32> {
    var k_1: f32;
    var base_1: vec3<f32>;
    var variability_1: f32;

    k_1 = k;
    base_1 = base;
    variability_1 = variability;
    let _e11 = base_1;
    let _e12 = variability_1;
    let _e13 = k_1;
    let _e17 = k_1;
    let _e21 = k_1;
    return (_e11 + (_e12 * vec3<f32>(cos((_e13 * 10f)), sin((_e17 * 7.4f)), sin(((_e21 * 14f) + 1f)))));
}

fn getIndexRange(y: f32, scale: f32, height: f32, variability_2: f32) -> vec2<f32> {
    var y_1: f32;
    var scale_1: f32;
    var height_1: f32;
    var variability_3: f32;
    var z: f32;
    var regularity: f32;
    var amp: f32;
    var k_2: f32;
    var y1_: f32;
    var y2_: f32;

    y_1 = y;
    scale_1 = scale;
    height_1 = height;
    variability_3 = variability_2;
    let _e13 = scale_1;
    z = _e13;
    let _e16 = variability_3;
    regularity = (0.25f / (_e16 + 0.000001f));
    let _e23 = regularity;
    let _e26 = z;
    amp = ((0.1f + (0.1f / _e23)) / _e26);
    let _e30 = height_1;
    k_2 = (0.1f + _e30);
    let _e33 = y_1;
    let _e36 = amp;
    y1_ = ((_e33 + 1f) - _e36);
    let _e39 = y_1;
    let _e42 = amp;
    y2_ = ((_e39 + 1f) + _e42);
    let _e45 = y1_;
    let _e46 = k_2;
    let _e49 = y2_;
    let _e50 = k_2;
    return vec2<f32>(floor((_e45 / _e46)), ceil((_e49 / _e50)));
}

fn wave(i: f32, x: f32, scale_2: f32, phase: f32, height_2: f32, variability_4: f32) -> f32 {
    var i_1: f32;
    var x_1: f32;
    var scale_3: f32;
    var phase_1: f32;
    var height_3: f32;
    var variability_5: f32;
    var z_1: f32;
    var regularity_1: f32;
    var p: f32;
    var freq: f32;
    var amp_1: f32;
    var k_3: f32;

    i_1 = i;
    x_1 = x;
    scale_3 = scale_2;
    phase_1 = phase;
    height_3 = height_2;
    variability_5 = variability_4;
    let _e17 = scale_3;
    z_1 = _e17;
    let _e20 = variability_5;
    regularity_1 = (0.25f / (_e20 + 0.000001f));
    let _e25 = phase_1;
    let _e26 = i_1;
    let _e28 = i_1;
    let _e34 = regularity_1;
    p = ((_e25 * _e26) + ((sin((_e28 * 1.5f)) * 10f) / _e34));
    let _e40 = i_1;
    let _e45 = regularity_1;
    let _e48 = z_1;
    freq = ((6f + ((0.0009f * sin((_e40 * 4f))) / _e45)) * _e48);
    let _e53 = i_1;
    let _e58 = regularity_1;
    let _e61 = z_1;
    amp_1 = ((0.1f + ((0.1f * sin((_e53 * 10.15f))) / _e58)) / _e61);
    let _e65 = height_3;
    k_3 = (0.1f + _e65);
    let _e68 = i_1;
    let _e69 = k_3;
    let _e73 = amp_1;
    let _e74 = freq;
    let _e75 = x_1;
    let _e77 = p;
    return (((_e68 * _e69) - 1f) + (_e73 * sin(((_e74 * _e75) + _e77))));
}

fn genWaves(uv: vec2<f32>, outPos: vec2<f32>, color: vec4<f32>, colorVariability: f32, randomSeed: f32, variability_6: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var color_1: vec4<f32>;
    var colorVariability_1: f32;
    var randomSeed_1: f32;
    var variability_7: f32;
    var modelTransform_1: mat3x3<f32>;
    var yinv: f32 = -1f;
    var N: f32 = 24f;
    var m: mat3x3<f32>;
    var scale_4: f32;
    var phase_2: f32;
    var height_4: f32;
    var Y: f32;
    var range: vec2<f32>;
    var step: i32 = 0i;
    var i_2: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    color_1 = color;
    colorVariability_1 = colorVariability;
    randomSeed_1 = randomSeed;
    variability_7 = variability_6;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    m = _naga_inverse_3x3_f32(_e24);
    let _e29 = m[0];
    scale_4 = length(_e29.xy);
    let _e35 = m[2];
    phase_2 = _e35.x;
    let _e38 = yinv;
    let _e42 = m[2];
    height_4 = ((-(_e38) * _e42.y) * 0.05f);
    let _e48 = yinv;
    let _e49 = uv_1;
    Y = (_e48 * _e49.y);
    let _e53 = Y;
    let _e54 = scale_4;
    let _e55 = height_4;
    let _e56 = variability_7;
    let _e57 = getIndexRange(_e53, _e54, _e55, _e56);
    range = _e57;
    let _e61 = range;
    i_2 = _e61.x;
    loop {
        let _e64 = i_2;
        let _e65 = range;
        if !((_e64 <= _e65.y)) {
            break;
        }
        {
            let _e72 = Y;
            let _e73 = i_2;
            let _e74 = uv_1;
            let _e76 = scale_4;
            let _e77 = phase_2;
            let _e78 = height_4;
            let _e79 = variability_7;
            let _e80 = variability_7;
            let _e82 = wave(_e73, _e74.x, _e76, _e77, _e78, (_e79 * _e80));
            if (_e72 < _e82) {
                {
                    let _e85 = randomSeed_1;
                    let _e90 = colorVariability_1;
                    let _e92 = i_2;
                    let _e95 = color_1;
                    let _e98 = colorVariability_1;
                    let _e100 = getColor(((6.89f + (_e85 * 0.1f)) + ((0.1f * _e90) * _e92)), _e95.xyz, (0.5f * _e98));
                    let _e101 = color_1;
                    return vec4<f32>(_e100.x, _e100.y, _e100.z, _e101.w);
                }
            }
            let _e107 = step;
            step = (_e107 + 1i);
            if (_e107 > 100i) {
                break;
            }
        }
        continuing {
            let _e69 = i_2;
            i_2 = (_e69 + 1f);
        }
    }
    let _e112 = color_1;
    return _e112;
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
    let _e72 = global.U[7];
    let _e76 = global.U[8];
    let _e80 = global.U[9];
    let _e81 = _e80.xyz;
    let _e84 = global.U[10];
    let _e85 = _e84.xyz;
    let _e88 = global.U[11];
    let _e89 = _e88.xyz;
    let _e103 = genWaves((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65, _e68.x, _e72.x, _e76.x, mat3x3<f32>(vec3<f32>(_e81.x, _e81.y, _e81.z), vec3<f32>(_e85.x, _e85.y, _e85.z), vec3<f32>(_e89.x, _e89.y, _e89.z)));
    fragColor = _e103;
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
