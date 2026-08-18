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
    let _e37 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e20.x / _e24.x), _e27.y) / vec2(2f)) + vec2(0.5f)), 0f);
    inc = _e37;
    let _e39 = modelTransform_1;
    pos = (_e39 * vec3<f32>(0f, 0f, 1f)).xy;
    let _e49 = modelTransform_1[0];
    radius = length(_e49.xy);
    let _e53 = radius;
    let _e55 = dampening_1;
    let _e56 = dampening_1;
    strongRadius = (_e53 * (1f - (_e55 * _e56)));
    let _e63 = uv_1;
    let _e64 = pos;
    dir = normalize((_e63 - _e64));
    let _e70 = pos;
    let _e71 = uv_1;
    dist = length((_e70 - _e71));
    loop {
        let _e77 = d;
        let _e78 = radius;
        let _e79 = dist;
        if !((_e77 < min(_e78, _e79))) {
            break;
        }
        {
            let _e86 = pos;
            let _e87 = dir;
            let _e88 = d;
            p = (_e86 + (_e87 * _e88));
            let _e92 = strongRadius;
            let _e95 = strongRadius;
            let _e96 = d;
            damp = smoothstep((_e92 * 0.25f), _e95, _e96);
            let _e100 = p;
            let _e104 = global.U[0];
            let _e107 = p;
            let _e117 = textureSampleLevel(t_source, samp, ((vec2<f32>((_e100.x / _e104.x), _e107.y) / vec2(2f)) + vec2(0.5f)), 0f);
            let _e119 = luma(_e117.xyz);
            let _e120 = damp;
            v = mix(1f, _e119, _e120);
            let _e123 = k;
            let _e125 = v;
            let _e126 = v;
            k = min(_e123, max(0f, (_e125 * _e126)));
        }
        continuing {
            let _e83 = d;
            let _e84 = step;
            d = (_e83 + _e84);
        }
    }
    let _e130 = k;
    let _e131 = intensity_1;
    k = ((_e130 * _e131) * 10f);
    let _e135 = k;
    let _e136 = color_1;
    light = (_e135 * _e136.xyz);
    let _e140 = inc;
    let _e142 = inc;
    let _e145 = inc;
    value = (((_e140.x + _e142.y) + _e145.z) / 3f);
    let _e153 = value;
    let _e156 = color_1;
    alpha = mix(smoothstep(1f, 0f, _e153), 1f, _e156.w);
    let _e163 = intensity_1;
    let _e168 = normalization_1;
    reduce = mix(1f, (1f / (1f + (_e163 * 10f))), _e168);
    let _e171 = inc;
    let _e173 = alpha;
    let _e174 = light;
    let _e177 = reduce;
    let _e178 = ((_e171.xyz + (_e173 * _e174)) * _e177);
    let _e179 = inc;
    return vec4<f32>(_e178.x, _e178.y, _e178.z, _e179.w);
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
