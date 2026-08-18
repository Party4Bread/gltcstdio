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

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn sunbeam(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, dampening: f32, normalization: f32, color: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var dampening_1: f32;
    var normalization_1: f32;
    var color_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var inc: vec4<f32>;
    var pos: vec2<f32>;
    var radius: f32;
    var strongRadius: f32;
    var step: f32 = 0.01f;
    var dir: vec2<f32>;
    var k: f32 = 1f;
    var dist: f32;
    var d: f32 = 0f;
    var p: vec2<f32>;
    var damp: f32;
    var v: f32;
    var light: vec3<f32>;
    var value: f32;
    var alpha: f32;
    var reduce: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    dampening_1 = dampening;
    normalization_1 = normalization;
    color_1 = color;
    modelTransform_1 = modelTransform;
    let _e20 = uv_1;
    let _e24 = global.U[0];
    let _e27 = uv_1;
    let _e36 = textureSample(t_source, samp, ((vec2<f32>((_e20.x / _e24.x), _e27.y) / vec2(2f)) + vec2(0.5f)));
    inc = _e36;
    let _e38 = modelTransform_1;
    pos = (_e38 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e48 = modelTransform_1[0];
    radius = length(_e48.xy);
    let _e52 = radius;
    let _e54 = dampening_1;
    let _e55 = dampening_1;
    strongRadius = (_e52 * (1f - (_e54 * _e55)));
    let _e62 = uv_1;
    let _e63 = pos;
    dir = normalize((_e62 - _e63));
    let _e69 = pos;
    let _e70 = uv_1;
    dist = length((_e69 - _e70));
    loop {
        let _e76 = d;
        let _e77 = radius;
        let _e78 = dist;
        if !((_e76 < min(_e77, _e78))) {
            break;
        }
        {
            let _e85 = pos;
            let _e86 = dir;
            let _e87 = d;
            p = (_e85 + (_e86 * _e87));
            let _e91 = strongRadius;
            let _e94 = strongRadius;
            let _e95 = d;
            damp = smoothstep((_e91 * 0.25f), _e94, _e95);
            let _e99 = p;
            let _e103 = global.U[0];
            let _e106 = p;
            let _e115 = textureSample(t_source, samp, ((vec2<f32>((_e99.x / _e103.x), _e106.y) / vec2(2f)) + vec2(0.5f)));
            let _e117 = luma(_e115.xyz);
            let _e118 = damp;
            v = mix(1f, _e117, _e118);
            let _e121 = k;
            let _e123 = v;
            let _e124 = v;
            k = min(_e121, max(0f, (_e123 * _e124)));
        }
        continuing {
            let _e82 = d;
            let _e83 = step;
            d = (_e82 + _e83);
        }
    }
    let _e128 = k;
    let _e129 = intensity_1;
    k = ((_e128 * _e129) * 10f);
    let _e133 = k;
    let _e134 = color_1;
    light = (_e133 * _e134.xyz);
    let _e138 = inc;
    let _e140 = inc;
    let _e143 = inc;
    value = (((_e138.x + _e140.y) + _e143.z) / 3f);
    let _e151 = value;
    let _e154 = color_1;
    alpha = mix(smoothstep(1f, 0f, _e151), 1f, _e154.w);
    let _e161 = intensity_1;
    let _e166 = normalization_1;
    reduce = mix(1f, (1f / (1f + (_e161 * 10f))), _e166);
    let _e169 = inc;
    let _e171 = alpha;
    let _e172 = light;
    let _e175 = reduce;
    let _e176 = ((_e169.xyz + (_e171 * _e172)) * _e175);
    let _e177 = inc;
    return vec4<f32>(_e176.x, _e176.y, _e176.z, _e177.w);
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
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e82 = _e81.xyz;
    let _e85 = global.U[10];
    let _e86 = _e85.xyz;
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e104 = sunbeam((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78, mat3x3<f32>(vec3<f32>(_e82.x, _e82.y, _e82.z), vec3<f32>(_e86.x, _e86.y, _e86.z), vec3<f32>(_e90.x, _e90.y, _e90.z)));
    fragColor = _e104;
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
