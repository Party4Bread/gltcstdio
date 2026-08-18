struct Params {
    U: array<vec4<f32>, 8>,
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

fn lumGrad(uv: vec2<f32>, outPos: vec2<f32>, delta: f32, mode: f32, intensity: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var delta_1: f32;
    var mode_1: f32;
    var intensity_1: f32;
    var step: vec2<f32>;
    var grad: vec2<f32>;
    var l: f32;
    var ngrad: vec2<f32>;
    var rgb: vec3<f32>;
    var k: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    delta_1 = delta;
    mode_1 = mode;
    intensity_1 = intensity;
    let _e16 = delta_1;
    step = vec2<f32>((_e16 / 2f), 0f);
    let _e22 = uv_1;
    let _e23 = step;
    let _e28 = global.U[0];
    let _e31 = uv_1;
    let _e32 = step;
    let _e42 = textureSample(t_source, samp, ((vec2<f32>(((_e22 + _e23).x / _e28.x), (_e31 + _e32).y) / vec2(2f)) + vec2(0.5f)));
    let _e44 = luma(_e42.xyz);
    let _e45 = uv_1;
    let _e46 = step;
    let _e51 = global.U[0];
    let _e54 = uv_1;
    let _e55 = step;
    let _e65 = textureSample(t_source, samp, ((vec2<f32>(((_e45 - _e46).x / _e51.x), (_e54 - _e55).y) / vec2(2f)) + vec2(0.5f)));
    let _e67 = luma(_e65.xyz);
    let _e69 = uv_1;
    let _e70 = step;
    let _e76 = global.U[0];
    let _e79 = uv_1;
    let _e80 = step;
    let _e91 = textureSample(t_source, samp, ((vec2<f32>(((_e69 + _e70.yx).x / _e76.x), (_e79 + _e80.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e93 = luma(_e91.xyz);
    let _e94 = uv_1;
    let _e95 = step;
    let _e101 = global.U[0];
    let _e104 = uv_1;
    let _e105 = step;
    let _e116 = textureSample(t_source, samp, ((vec2<f32>(((_e94 - _e95.yx).x / _e101.x), (_e104 - _e105.yx).y) / vec2(2f)) + vec2(0.5f)));
    let _e118 = luma(_e116.xyz);
    let _e121 = delta_1;
    grad = (vec2<f32>((_e44 - _e67), (_e93 - _e118)) / vec2(_e121));
    let _e125 = grad;
    l = length(_e125);
    let _e128 = grad;
    let _e129 = l;
    ngrad = (_e128 / vec2(_e129));
    let _e135 = ngrad;
    let _e138 = (vec2(0.5f) + (0.5f * _e135));
    let _e139 = l;
    let _e140 = intensity_1;
    rgb = vec3<f32>(_e138.x, _e138.y, (_e139 * _e140));
    let _e146 = mode_1;
    k = fract(_e146);
    let _e149 = mode_1;
    mode_1 = (_e149 - (floor((_e149 / 6f)) * 6f));
    let _e155 = mode_1;
    if (_e155 <= 1f) {
        let _e158 = rgb;
        let _e159 = rgb;
        let _e161 = k;
        let _e163 = mix(_e158, _e159.xzy, vec3(_e161));
        return vec4<f32>(_e163.x, _e163.y, _e163.z, 1f);
    }
    let _e169 = mode_1;
    if (_e169 <= 2f) {
        let _e172 = rgb;
        let _e174 = rgb;
        let _e176 = k;
        let _e178 = mix(_e172.xzy, _e174.zxy, vec3(_e176));
        return vec4<f32>(_e178.x, _e178.y, _e178.z, 1f);
    }
    let _e184 = mode_1;
    if (_e184 <= 3f) {
        let _e187 = rgb;
        let _e189 = rgb;
        let _e191 = k;
        let _e193 = mix(_e187.zxy, _e189.zyx, vec3(_e191));
        return vec4<f32>(_e193.x, _e193.y, _e193.z, 1f);
    }
    let _e199 = mode_1;
    if (_e199 <= 4f) {
        let _e202 = rgb;
        let _e204 = rgb;
        let _e206 = k;
        let _e208 = mix(_e202.zyx, _e204.yzx, vec3(_e206));
        return vec4<f32>(_e208.x, _e208.y, _e208.z, 1f);
    }
    let _e214 = mode_1;
    if (_e214 <= 5f) {
        let _e217 = rgb;
        let _e219 = rgb;
        let _e221 = k;
        let _e223 = mix(_e217.yzx, _e219.yxz, vec3(_e221));
        return vec4<f32>(_e223.x, _e223.y, _e223.z, 1f);
    } else {
        let _e229 = rgb;
        let _e231 = rgb;
        let _e232 = k;
        let _e234 = mix(_e229.yxz, _e231, vec3(_e232));
        return vec4<f32>(_e234.x, _e234.y, _e234.z, 1f);
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
    let _e66 = global.U[5];
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e76 = lumGrad((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x);
    fragColor = _e76;
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
