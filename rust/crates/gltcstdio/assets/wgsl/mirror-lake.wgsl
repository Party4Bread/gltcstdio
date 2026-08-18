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

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e18 = u_1;
    return vec2<f32>(fract((sin(dot(_e8.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e18.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var rnd: vec2<f32>;
    var len: f32;

    p_1 = p;
    let _e8 = p_1;
    let _e9 = hash22b(_e8);
    rnd = (_e9 - vec2(0.5f));
    let _e14 = rnd;
    len = length(_e14);
    let _e17 = len;
    if (_e17 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e23 = rnd;
        let _e24 = len;
        return (_e23 / vec2(_e24));
    }
}

fn dotGridGradient(g: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_1: vec2<f32>;
    var u_3: vec2<f32>;

    g_1 = g;
    u_3 = u_2;
    let _e10 = u_3;
    let _e11 = g_1;
    let _e13 = g_1;
    let _e14 = rndUnit(_e13);
    return dot((_e10 - _e11), _e14);
}

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e12 = a_1;
    let _e13 = b_1;
    let _e16 = k_1;
    return mix(_e12, _e13, smoothstep(0f, 1f, _e16));
}

fn perlinNoise(p_2: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var s: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_3 = p_2;
    let _e12 = p_3;
    f = floor(_e12);
    let _e15 = p_3;
    let _e16 = f;
    d = (_e15 - _e16);
    let _e19 = f;
    let _e20 = p_3;
    let _e21 = dotGridGradient(_e19, _e20);
    let _e22 = f;
    let _e23 = s;
    let _e25 = p_3;
    let _e26 = dotGridGradient((_e22 + _e23), _e25);
    let _e27 = d;
    let _e29 = smix(_e21, _e26, _e27.x);
    ix0_ = _e29;
    let _e31 = f;
    let _e32 = s;
    let _e35 = p_3;
    let _e36 = dotGridGradient((_e31 + _e32.yx), _e35);
    let _e37 = f;
    let _e38 = s;
    let _e41 = p_3;
    let _e42 = dotGridGradient((_e37 + _e38.xx), _e41);
    let _e43 = d;
    let _e45 = smix(_e36, _e42, _e43.x);
    ix1_ = _e45;
    let _e48 = ix0_;
    let _e49 = ix1_;
    let _e50 = d;
    let _e52 = smix(_e48, _e49, _e50.y);
    return (0.5f + (_e52 * 0.5f));
}

fn getSurface(xz: vec2<f32>, period: f32, ar: f32, intensity: f32, regularity: f32) -> f32 {
    var xz_1: vec2<f32>;
    var period_1: f32;
    var ar_1: f32;
    var intensity_1: f32;
    var regularity_1: f32;

    xz_1 = xz;
    period_1 = period;
    ar_1 = ar;
    intensity_1 = intensity;
    regularity_1 = regularity;
    let _e16 = intensity_1;
    let _e19 = xz_1;
    let _e21 = ar_1;
    let _e26 = period_1;
    let _e29 = perlinNoise(((_e19 * vec2<f32>((1f / _e21), 1f)) / vec2(_e26)));
    let _e31 = xz_1;
    let _e33 = period_1;
    let _e37 = regularity_1;
    return ((_e16 * 10f) * mix(_e29, (0.4f * sin((_e31.y / _e33))), _e37));
}

fn getNormal(p_4: vec3<f32>, period_2: f32, ar_2: f32, intensity_2: f32, regularity_2: f32) -> vec3<f32> {
    var p_5: vec3<f32>;
    var period_3: f32;
    var ar_3: f32;
    var intensity_3: f32;
    var regularity_3: f32;
    var d_1: f32;
    var y: f32;
    var yx: f32;
    var yz: f32;

    p_5 = p_4;
    period_3 = period_2;
    ar_3 = ar_2;
    intensity_3 = intensity_2;
    regularity_3 = regularity_2;
    let _e16 = period_3;
    d_1 = (_e16 * 0.001f);
    let _e20 = p_5;
    let _e22 = period_3;
    let _e23 = ar_3;
    let _e24 = intensity_3;
    let _e25 = regularity_3;
    let _e26 = getSurface(_e20.xz, _e22, _e23, _e24, _e25);
    y = _e26;
    let _e28 = p_5;
    let _e30 = d_1;
    let _e32 = p_5;
    let _e35 = period_3;
    let _e36 = ar_3;
    let _e37 = intensity_3;
    let _e38 = regularity_3;
    let _e39 = getSurface(vec2<f32>((_e28.x + _e30), _e32.z), _e35, _e36, _e37, _e38);
    yx = _e39;
    let _e41 = p_5;
    let _e43 = p_5;
    let _e45 = d_1;
    let _e48 = period_3;
    let _e49 = ar_3;
    let _e50 = intensity_3;
    let _e51 = regularity_3;
    let _e52 = getSurface(vec2<f32>(_e41.x, (_e43.z + _e45)), _e48, _e49, _e50, _e51);
    yz = _e52;
    let _e54 = yx;
    let _e55 = y;
    let _e57 = d_1;
    let _e60 = yz;
    let _e61 = y;
    let _e63 = d_1;
    return normalize(vec3<f32>(((_e54 - _e55) / _e57), 1f, ((_e60 - _e61) / _e63)));
}

fn getPlaneIntersection(y_1: f32, camera: vec3<f32>, dir: vec3<f32>) -> vec3<f32> {
    var y_2: f32;
    var camera_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var k_2: f32;

    y_2 = y_1;
    camera_1 = camera;
    dir_1 = dir;
    let _e12 = y_2;
    let _e13 = camera_1;
    let _e16 = dir_1;
    k_2 = ((_e12 - _e13.y) / _e16.y);
    let _e20 = k_2;
    if (_e20 > 0f) {
        let _e23 = camera_1;
        let _e24 = k_2;
        let _e25 = dir_1;
        return (_e23 + (_e24 * _e25));
    } else {
        return vec3(100000000000000000000f);
    }
}

fn tf(m: mat3x3<f32>, u_4: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_5: vec2<f32>;

    m_1 = m;
    u_5 = u_4;
    let _e10 = m_1;
    let _e11 = u_5;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn mirrorLake(uv: vec2<f32>, outPos: vec2<f32>, intensity_4: f32, shapeAspectRatio: f32, regularity_4: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_5: f32;
    var shapeAspectRatio_1: f32;
    var regularity_5: f32;
    var modelTransform_1: mat3x3<f32>;
    var zoom: f32;
    var dir_2: vec3<f32>;
    var camera_2: vec3<f32> = vec3<f32>(0f, -500f, 0f);
    var Y: f32 = 0f;
    var color: vec4<f32> = vec4(1f);
    var intersection: vec3<f32>;
    var normal: vec3<f32>;
    var u_6: vec2<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_5 = intensity_4;
    shapeAspectRatio_1 = shapeAspectRatio;
    regularity_5 = regularity_4;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = uv_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    uv_1 = _e21;
    let _e25 = modelTransform_1[0];
    zoom = (1f / pow(length(_e25.xy), 2f));
    let _e32 = uv_1;
    let _e33 = zoom;
    dir_2 = normalize(vec3<f32>(_e32.x, _e32.y, _e33));
    let _e50 = Y;
    let _e51 = camera_2;
    let _e52 = dir_2;
    let _e53 = getPlaneIntersection(_e50, _e51, _e52);
    intersection = _e53;
    let _e55 = intersection;
    if (_e55.x != 100000000000000000000f) {
        {
            let _e59 = intersection;
            let _e61 = shapeAspectRatio_1;
            let _e62 = intensity_5;
            let _e63 = regularity_5;
            let _e64 = getNormal(_e59, 100f, _e61, _e62, _e63);
            normal = _e64;
            let _e66 = dir_2;
            let _e67 = normal;
            dir_2 = reflect(_e66, _e67);
        }
    }
    let _e69 = dir_2;
    let _e71 = dir_2;
    let _e75 = zoom;
    u_6 = ((_e69.xy / vec2(_e71.z)) * _e75);
    let _e78 = modelTransform_1;
    let _e79 = u_6;
    let _e80 = tf(_e78, _e79);
    u_6 = _e80;
    let _e81 = u_6;
    let _e85 = global.U[0];
    let _e88 = u_6;
    let _e97 = _mirror_wrap(((vec2<f32>((_e81.x / _e85.x), _e88.y) / vec2(2f)) + vec2(0.5f)));
    let _e98 = textureSample(t_source, samp, _e97);
    return _e98;
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
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = mirrorLake((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
    fragColor = _e101;
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
