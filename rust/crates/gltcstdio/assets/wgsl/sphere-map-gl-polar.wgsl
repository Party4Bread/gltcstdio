struct Params {
    U: array<vec4<f32>, 11>,
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

fn projEquirectangular(dir: vec3<f32>) -> vec2<f32> {
    var dir_1: vec3<f32>;
    var u: vec3<f32>;
    var lambda: f32;
    var phi: f32;

    dir_1 = dir;
    let _e8 = dir_1;
    u = normalize(_e8);
    let _e11 = u;
    let _e13 = u;
    lambda = atan2(_e11.z, _e13.x);
    let _e17 = u;
    phi = asin(_e17.y);
    let _e21 = lambda;
    let _e22 = phi;
    return vec2<f32>(_e21, _e22);
}

fn sphereMapGlPolar(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, count: i32, model3DTransform: mat4x4<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var count_1: i32;
    var model3DTransform_1: mat4x4<f32>;
    var dir_2: vec3<f32>;
    var inv: mat4x4<f32>;
    var longLat: vec2<f32>;
    var nX: f32;
    var nY: f32;
    var u_1: vec2<f32>;
    var w: vec2<f32>;
    var ratio: f32;
    var srcPos: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    count_1 = count;
    model3DTransform_1 = model3DTransform;
    let _e16 = pos_1;
    let _e18 = pos_1;
    dir_2 = normalize(vec3<f32>(_e16.x, _e18.y, -1f));
    let _e25 = model3DTransform_1;
    inv = _naga_inverse_4x4_f32(_e25);
    let _e30 = inv[0];
    let _e31 = _e30.xyz;
    let _e34 = inv[1];
    let _e35 = _e34.xyz;
    let _e38 = inv[2];
    let _e39 = _e38.xyz;
    let _e53 = dir_2;
    dir_2 = (mat3x3<f32>(vec3<f32>(_e31.x, _e31.y, _e31.z), vec3<f32>(_e35.x, _e35.y, _e35.z), vec3<f32>(_e39.x, _e39.y, _e39.z)) * _e53);
    let _e55 = dir_2;
    let _e56 = projEquirectangular(_e55);
    longLat = _e56;
    let _e58 = count_1;
    nX = (f32(_e58) * 2f);
    let _e63 = count_1;
    nY = f32(_e63);
    let _e66 = longLat;
    let _e73 = nX;
    let _e76 = longLat;
    let _e78 = nY;
    u_1 = vec2<f32>((((-(_e66.x) / 3.1415927f) * 0.5f) * _e73), (0.5f + ((_e76.y * _e78) / 3.1415927f)));
    let _e85 = u_1;
    w = abs(_e85);
    let _e88 = w;
    let _e90 = w;
    w = (_e88 - (2f * floor((_e90 * 0.5f))));
    let _e96 = w;
    let _e98 = w;
    let _e102 = w;
    w = mix(_e96, (vec2(2f) - _e98), step(vec2(1f), _e102));
    let _e106 = sourceDim_1;
    let _e108 = sourceDim_1;
    ratio = (_e106.x / _e108.y);
    let _e112 = w;
    let _e118 = ratio;
    let _e120 = w;
    srcPos = vec2<f32>((((_e112.x - 0.5f) * 2f) * _e118), ((_e120.y - 0.5f) * 2f));
    let _e128 = srcPos;
    let _e132 = global.U[0];
    let _e135 = srcPos;
    let _e144 = _mirror_wrap(((vec2<f32>((_e128.x / _e132.x), _e135.y) / vec2(2f)) + vec2(0.5f)));
    let _e145 = textureSample(t_source, samp, _e144);
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
    let _e66 = global.U[4];
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e78 = global.U[8];
    let _e81 = global.U[9];
    let _e84 = global.U[10];
    let _e106 = sphereMapGlPolar((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), mat4x4<f32>(vec4<f32>(_e75.x, _e75.y, _e75.z, _e75.w), vec4<f32>(_e78.x, _e78.y, _e78.z, _e78.w), vec4<f32>(_e81.x, _e81.y, _e81.z, _e81.w), vec4<f32>(_e84.x, _e84.y, _e84.z, _e84.w)));
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

fn _naga_inverse_4x4_f32(m: mat4x4<f32>) -> mat4x4<f32> {
   let sub_factor00: f32 = m[2][2] * m[3][3] - m[3][2] * m[2][3];
   let sub_factor01: f32 = m[2][1] * m[3][3] - m[3][1] * m[2][3];
   let sub_factor02: f32 = m[2][1] * m[3][2] - m[3][1] * m[2][2];
   let sub_factor03: f32 = m[2][0] * m[3][3] - m[3][0] * m[2][3];
   let sub_factor04: f32 = m[2][0] * m[3][2] - m[3][0] * m[2][2];
   let sub_factor05: f32 = m[2][0] * m[3][1] - m[3][0] * m[2][1];
   let sub_factor06: f32 = m[1][2] * m[3][3] - m[3][2] * m[1][3];
   let sub_factor07: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor08: f32 = m[1][1] * m[3][2] - m[3][1] * m[1][2];
   let sub_factor09: f32 = m[1][0] * m[3][3] - m[3][0] * m[1][3];
   let sub_factor10: f32 = m[1][0] * m[3][2] - m[3][0] * m[1][2];
   let sub_factor11: f32 = m[1][1] * m[3][3] - m[3][1] * m[1][3];
   let sub_factor12: f32 = m[1][0] * m[3][1] - m[3][0] * m[1][1];
   let sub_factor13: f32 = m[1][2] * m[2][3] - m[2][2] * m[1][3];
   let sub_factor14: f32 = m[1][1] * m[2][3] - m[2][1] * m[1][3];
   let sub_factor15: f32 = m[1][1] * m[2][2] - m[2][1] * m[1][2];
   let sub_factor16: f32 = m[1][0] * m[2][3] - m[2][0] * m[1][3];
   let sub_factor17: f32 = m[1][0] * m[2][2] - m[2][0] * m[1][2];
   let sub_factor18: f32 = m[1][0] * m[2][1] - m[2][0] * m[1][1];

   var adj: mat4x4<f32>;
   adj[0][0] =   (m[1][1] * sub_factor00 - m[1][2] * sub_factor01 + m[1][3] * sub_factor02);
   adj[1][0] = - (m[1][0] * sub_factor00 - m[1][2] * sub_factor03 + m[1][3] * sub_factor04);
   adj[2][0] =   (m[1][0] * sub_factor01 - m[1][1] * sub_factor03 + m[1][3] * sub_factor05);
   adj[3][0] = - (m[1][0] * sub_factor02 - m[1][1] * sub_factor04 + m[1][2] * sub_factor05);
   adj[0][1] = - (m[0][1] * sub_factor00 - m[0][2] * sub_factor01 + m[0][3] * sub_factor02);
   adj[1][1] =   (m[0][0] * sub_factor00 - m[0][2] * sub_factor03 + m[0][3] * sub_factor04);
   adj[2][1] = - (m[0][0] * sub_factor01 - m[0][1] * sub_factor03 + m[0][3] * sub_factor05);
   adj[3][1] =   (m[0][0] * sub_factor02 - m[0][1] * sub_factor04 + m[0][2] * sub_factor05);
   adj[0][2] =   (m[0][1] * sub_factor06 - m[0][2] * sub_factor07 + m[0][3] * sub_factor08);
   adj[1][2] = - (m[0][0] * sub_factor06 - m[0][2] * sub_factor09 + m[0][3] * sub_factor10);
   adj[2][2] =   (m[0][0] * sub_factor11 - m[0][1] * sub_factor09 + m[0][3] * sub_factor12);
   adj[3][2] = - (m[0][0] * sub_factor08 - m[0][1] * sub_factor10 + m[0][2] * sub_factor12);
   adj[0][3] = - (m[0][1] * sub_factor13 - m[0][2] * sub_factor14 + m[0][3] * sub_factor15);
   adj[1][3] =   (m[0][0] * sub_factor13 - m[0][2] * sub_factor16 + m[0][3] * sub_factor17);
   adj[2][3] = - (m[0][0] * sub_factor14 - m[0][1] * sub_factor16 + m[0][3] * sub_factor18);
   adj[3][3] =   (m[0][0] * sub_factor15 - m[0][1] * sub_factor17 + m[0][2] * sub_factor18);

   let det = (m[0][0] * adj[0][0] + m[0][1] * adj[1][0] + m[0][2] * adj[2][0] + m[0][3] * adj[3][0]);

   return adj * (1 / det);
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
