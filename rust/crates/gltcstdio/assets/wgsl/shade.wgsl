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

fn adjustGamma(col: vec4<f32>, gamma: f32) -> vec4<f32> {
    var col_1: vec4<f32>;
    var gamma_1: f32;
    var p: f32;

    col_1 = col;
    gamma_1 = gamma;
    let _e10 = gamma_1;
    if (_e10 != 0f) {
        {
            let _e14 = gamma_1;
            p = pow(2f, -(_e14));
            let _e19 = col_1;
            let _e21 = p;
            col_1.x = pow(_e19.x, _e21);
            let _e24 = col_1;
            let _e26 = p;
            col_1.y = pow(_e24.y, _e26);
            let _e29 = col_1;
            let _e31 = p;
            col_1.z = pow(_e29.z, _e31);
        }
    }
    let _e33 = col_1;
    return _e33;
}

fn luma(c: vec3<f32>) -> f32 {
    var c_1: vec3<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e13 = c_1;
    let _e18 = c_1;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn shade(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, height: f32, specular: f32, delta: f32, gamma_2: f32, lightSourceTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var height_1: f32;
    var specular_1: f32;
    var delta_1: f32;
    var gamma_3: f32;
    var lightSourceTransform_1: mat4x4<f32>;
    var step: vec2<f32>;
    var uv: vec2<f32>;
    var col_2: vec4<f32>;
    var h: f32;
    var pixel: f32;
    var grad: vec2<f32>;
    var normal: vec3<f32>;
    var lightPos: vec3<f32>;
    var lightDir: vec3<f32>;
    var illum: f32;
    var reflectedLightDir: vec3<f32>;
    var spec: f32;
    var k: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    height_1 = height;
    specular_1 = specular;
    delta_1 = delta;
    gamma_3 = gamma_2;
    lightSourceTransform_1 = lightSourceTransform;
    let _e24 = delta_1;
    step = vec2<f32>(_e24, 0f);
    let _e28 = pos_1;
    uv = _e28;
    let _e30 = uv;
    let _e34 = global.U[0];
    let _e37 = uv;
    let _e46 = textureSample(t_source, samp, ((vec2<f32>((_e30.x / _e34.x), _e37.y) / vec2(2f)) + vec2(0.5f)));
    col_2 = _e46;
    let _e48 = col_2;
    let _e50 = luma(_e48.xyz);
    h = _e50;
    let _e53 = sourceDim_1;
    pixel = (2f / _e53.y);
    let _e57 = h;
    let _e58 = dpdx(_e57);
    let _e59 = h;
    let _e60 = dpdy(_e59);
    let _e62 = pixel;
    grad = (vec2<f32>(_e58, _e60) / vec2(_e62));
    let _e66 = height_1;
    let _e67 = grad;
    let _e68 = (_e66 * _e67);
    normal = normalize(vec3<f32>(_e68.x, _e68.y, 1f));
    let _e75 = lightSourceTransform_1;
    lightPos = (_e75 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e84 = uv;
    let _e89 = lightPos;
    lightDir = normalize((vec3<f32>(_e84.x, _e84.y, 0f) - _e89));
    let _e93 = normal;
    let _e94 = lightDir;
    illum = dot(_e93, _e94);
    let _e97 = lightDir;
    let _e99 = normal;
    reflectedLightDir = reflect(-(_e97), _e99);
    let _e103 = reflectedLightDir;
    let _e104 = uv;
    let _e105 = -(_e104);
    let _e107 = height_1;
    spec = pow(max(0f, dot(_e103, normalize(vec3<f32>(_e105.x, _e105.y, (0.5f / _e107))))), 5f);
    let _e119 = illum;
    let _e120 = intensity_1;
    let _e124 = intensity_1;
    k = ((0.1f + (_e119 * _e120)) / (0.1f + _e124));
    let _e128 = col_2;
    let _e130 = k;
    let _e132 = spec;
    let _e133 = specular_1;
    let _e136 = ((_e128.xyz * _e130) + vec3((_e132 * _e133)));
    let _e137 = col_2;
    let _e143 = gamma_3;
    let _e144 = adjustGamma(vec4<f32>(_e136.x, _e136.y, _e136.z, _e137.w), _e143);
    return _e144;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e90 = global.U[11];
    let _e93 = global.U[12];
    let _e96 = global.U[13];
    let _e99 = global.U[14];
    let _e121 = shade((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, _e82.x, _e86.x, mat4x4<f32>(vec4<f32>(_e90.x, _e90.y, _e90.z, _e90.w), vec4<f32>(_e93.x, _e93.y, _e93.z, _e93.w), vec4<f32>(_e96.x, _e96.y, _e96.z, _e96.w), vec4<f32>(_e99.x, _e99.y, _e99.z, _e99.w)));
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
