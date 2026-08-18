struct Params {
    U: array<vec4<f32>, 25>,
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

fn getColorAtLayer2_(col: vec4<f32>, z: f32, lighting: mat3x3<f32>) -> vec4<f32> {
    var col_1: vec4<f32>;
    var z_1: f32;
    var lighting_1: mat3x3<f32>;
    var lightAtSun: vec3<f32>;
    var lightAtTop: vec3<f32>;
    var sunPos: vec2<f32>;
    var midColor: vec3<f32>;
    var phaseOffset: f32;
    var kMoonPower: f32;
    var sunPower: f32;
    var lightedCol: vec4<f32>;
    var haze: vec4<f32>;

    col_1 = col;
    z_1 = z;
    lighting_1 = lighting;
    let _e13 = lighting_1[0];
    lightAtSun = _e13;
    let _e17 = lighting_1[1];
    lightAtTop = _e17;
    let _e21 = lighting_1[2];
    sunPos = _e21.xy;
    let _e24 = lightAtSun;
    let _e25 = lightAtTop;
    midColor = mix(_e24, _e25, vec3(0.5f));
    let _e32 = lighting_1[2];
    phaseOffset = _e32.z;
    let _e37 = phaseOffset;
    kMoonPower = (1f - min(1f, (abs(_e37) / 0.2f)));
    let _e52 = sunPos;
    sunPower = smoothstep(-0.3f, -0.75f, _e52.y);
    let _e56 = midColor;
    let _e73 = sunPos;
    midColor = mix(_e56, vec3<f32>(1.08f, 1.08f, 1.2960001f), vec3(smoothstep(-0.3f, -0.75f, _e73.y)));
    let _e78 = sunPos;
    if (_e78.y > 0f) {
        let _e82 = midColor;
        let _e89 = sunPos;
        let _e96 = kMoonPower;
        midColor = mix(_e82, vec3<f32>(0.62f, 0.78f, 1f), vec3((smoothstep(0f, 0.2f, _e89.y) * pow(mix(0.1f, 1f, max(0f, (1f - _e96))), 0.5f))));
    }
    let _e105 = z_1;
    let _e106 = z_1;
    let _e109 = sunPower;
    z_1 = mix(_e105, (_e106 * 0.15f), _e109);
    let _e111 = col_1;
    let _e112 = midColor;
    lightedCol = (_e111 * vec4<f32>(_e112.x, _e112.y, _e112.z, 1f));
    let _e123 = col_1;
    haze = vec4<f32>(0f, 0.02f, 0.04f, _e123.w);
    let _e127 = haze;
    let _e128 = lightedCol;
    let _e130 = z_1;
    return mix(_e127, _e128, vec4(pow(0.9f, _e130)));
}

fn interpolateCol5_(k0_: f32, col0_: vec3<f32>, k1_: f32, col1_: vec3<f32>, k2_: f32, col2_: vec3<f32>, k3_: f32, col3_: vec3<f32>, k4_: f32, col4_: vec3<f32>, k: f32) -> vec3<f32> {
    var k0_1: f32;
    var col0_1: vec3<f32>;
    var k1_1: f32;
    var col1_1: vec3<f32>;
    var k2_1: f32;
    var col2_1: vec3<f32>;
    var k3_1: f32;
    var col3_1: vec3<f32>;
    var k4_1: f32;
    var col4_1: vec3<f32>;
    var k_1: f32;

    k0_1 = k0_;
    col0_1 = col0_;
    k1_1 = k1_;
    col1_1 = col1_;
    k2_1 = k2_;
    col2_1 = col2_;
    k3_1 = k3_;
    col3_1 = col3_;
    k4_1 = k4_;
    col4_1 = col4_;
    k_1 = k;
    let _e27 = k_1;
    let _e28 = k1_1;
    if (_e27 < _e28) {
        let _e30 = col0_1;
        let _e31 = col1_1;
        let _e32 = k_1;
        let _e33 = k0_1;
        let _e35 = k1_1;
        let _e36 = k0_1;
        return mix(_e30, _e31, vec3(((_e32 - _e33) / (_e35 - _e36))));
    }
    let _e41 = k_1;
    let _e42 = k2_1;
    if (_e41 < _e42) {
        let _e44 = col1_1;
        let _e45 = col2_1;
        let _e46 = k_1;
        let _e47 = k1_1;
        let _e49 = k2_1;
        let _e50 = k1_1;
        return mix(_e44, _e45, vec3(((_e46 - _e47) / (_e49 - _e50))));
    }
    let _e55 = k_1;
    let _e56 = k3_1;
    if (_e55 < _e56) {
        let _e58 = col2_1;
        let _e59 = col3_1;
        let _e60 = k_1;
        let _e61 = k2_1;
        let _e63 = k3_1;
        let _e64 = k2_1;
        return mix(_e58, _e59, vec3(((_e60 - _e61) / (_e63 - _e64))));
    }
    let _e69 = col3_1;
    let _e70 = col4_1;
    let _e71 = k_1;
    let _e72 = k3_1;
    let _e74 = k4_1;
    let _e75 = k3_1;
    return mix(_e69, _e70, vec3(((_e71 - _e72) / (_e74 - _e75))));
}

fn getLighting(time: f32) -> mat3x3<f32> {
    var time_1: f32;
    var angle: f32;
    var moonPos: vec2<f32>;
    var sunPos_1: vec2<f32>;
    var lightAtSun_1: vec3<f32>;
    var lightAtTop_1: vec3<f32>;
    var phaseOffset_1: f32;

    time_1 = time;
    let _e7 = time_1;
    angle = _e7;
    let _e12 = angle;
    let _e14 = angle;
    moonPos = (vec2<f32>(0.75f, 0.75f) * vec2<f32>(sin(_e12), -(cos(_e14))));
    let _e20 = moonPos;
    sunPos_1 = -(_e20);
    let _e60 = sunPos_1;
    let _e62 = interpolateCol5_(-0.75f, vec3<f32>(0.1f, 0.4f, 1f), -0.22500001f, vec3<f32>(1f, 0.9f, 0.2f), 0.075f, vec3<f32>(0.5f, 0.1f, 0f), 0.15f, vec3<f32>(0.010000001f, 0.040000003f, 0.1f), 0.75f, vec3(0f), _e60.y);
    lightAtSun_1 = _e62;
    let _e101 = sunPos_1;
    let _e103 = interpolateCol5_(-0.75f, vec3<f32>(0.1f, 0.4f, 1f), -0.22500001f, vec3<f32>(0.3f, 0.1f, 0.8f), 0.075f, vec3<f32>(0.3f, 0.1f, 0.8f), 0.15f, vec3<f32>(0.010000001f, 0.040000003f, 0.1f), 0.75f, vec3(0f), _e101.y);
    lightAtTop_1 = _e103;
    let _e105 = time_1;
    phaseOffset_1 = ((fract((_e105 * 0.015f)) - 0.5f) * 0.46f);
    let _e116 = lightAtSun_1;
    let _e117 = lightAtTop_1;
    let _e118 = sunPos_1;
    let _e119 = phaseOffset_1;
    let _e122 = vec3<f32>(_e118.x, _e118.y, _e119);
    return mat3x3<f32>(vec3<f32>(_e116.x, _e116.y, _e116.z), vec3<f32>(_e117.x, _e117.y, _e117.z), vec3<f32>(_e122.x, _e122.y, _e122.z));
}

fn hash11_(x: f32) -> f32 {
    var x_1: f32;

    x_1 = x;
    let _e7 = x_1;
    return fract((sin(((_e7 * 45.34f) + 123.131f)) * 94.434f));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e9 = bkg_1;
    let _e11 = front_1;
    let _e13 = front_1;
    let _e16 = bkg_1;
    let _e20 = front_1;
    let _e26 = mix(_e9.xyz, _e11.xyz, vec3((_e13.w + ((1f - _e16.w) * (1f - _e20.w)))));
    let _e27 = bkg_1;
    let _e29 = front_1;
    return vec4<f32>(_e26.x, _e26.y, _e26.z, max(_e27.w, _e29.w));
}

fn hash22b(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e7 = u_1;
    let _e17 = u_1;
    return vec2<f32>(fract((sin(dot(_e7.xy, vec2<f32>(13.7545f, 78.224f))) * 43758.547f)), fract((sin(dot(_e17.xy, vec2<f32>(15.7545f, 73.224f))) * 43758.547f)));
}

fn rndUnit(p: vec2<f32>) -> vec2<f32> {
    var p_1: vec2<f32>;
    var rnd: vec2<f32>;
    var len: f32;

    p_1 = p;
    let _e7 = p_1;
    let _e8 = hash22b(_e7);
    rnd = (_e8 - vec2(0.5f));
    let _e13 = rnd;
    len = length(_e13);
    let _e16 = len;
    if (_e16 == 0f) {
        return vec2<f32>(0f, 1f);
    } else {
        let _e22 = rnd;
        let _e23 = len;
        return (_e22 / vec2(_e23));
    }
}

fn dotGridGradient(g: vec2<f32>, u_2: vec2<f32>) -> f32 {
    var g_1: vec2<f32>;
    var u_3: vec2<f32>;

    g_1 = g;
    u_3 = u_2;
    let _e9 = u_3;
    let _e10 = g_1;
    let _e12 = g_1;
    let _e13 = rndUnit(_e12);
    return dot((_e9 - _e10), _e13);
}

fn smix(a: f32, b: f32, k_2: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_3: f32;

    a_1 = a;
    b_1 = b;
    k_3 = k_2;
    let _e11 = a_1;
    let _e12 = b_1;
    let _e15 = k_3;
    return mix(_e11, _e12, smoothstep(0f, 1f, _e15));
}

fn perlinNoise(p_2: vec2<f32>) -> f32 {
    var p_3: vec2<f32>;
    var s: vec2<f32> = vec2<f32>(1f, 0f);
    var f: vec2<f32>;
    var d: vec2<f32>;
    var ix0_: f32;
    var ix1_: f32;

    p_3 = p_2;
    let _e11 = p_3;
    f = floor(_e11);
    let _e14 = p_3;
    let _e15 = f;
    d = (_e14 - _e15);
    let _e18 = f;
    let _e19 = p_3;
    let _e20 = dotGridGradient(_e18, _e19);
    let _e21 = f;
    let _e22 = s;
    let _e24 = p_3;
    let _e25 = dotGridGradient((_e21 + _e22), _e24);
    let _e26 = d;
    let _e28 = smix(_e20, _e25, _e26.x);
    ix0_ = _e28;
    let _e30 = f;
    let _e31 = s;
    let _e34 = p_3;
    let _e35 = dotGridGradient((_e30 + _e31.yx), _e34);
    let _e36 = f;
    let _e37 = s;
    let _e40 = p_3;
    let _e41 = dotGridGradient((_e36 + _e37.xx), _e40);
    let _e42 = d;
    let _e44 = smix(_e35, _e41, _e42.x);
    ix1_ = _e44;
    let _e47 = ix0_;
    let _e48 = ix1_;
    let _e49 = d;
    let _e51 = smix(_e47, _e48, _e49.y);
    return (0.5f + (_e51 * 0.5f));
}

fn perlinOctaveNoise(uv: vec2<f32>, n: i32) -> f32 {
    var uv_1: vec2<f32>;
    var n_1: i32;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_4: f32 = 1f;
    var x_2: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;

    uv_1 = uv;
    n_1 = n;
    loop {
        let _e43 = i;
        let _e44 = n_1;
        if !((_e43 < _e44)) {
            break;
        }
        {
            let _e50 = x_2;
            let _e51 = k_4;
            let _e52 = uv_1;
            let _e53 = perlinNoise(_e52);
            x_2 = (_e50 + (_e51 * _e53));
            let _e56 = total;
            let _e57 = k_4;
            total = (_e56 + _e57);
            let _e59 = k_4;
            k_4 = (_e59 * 0.5f);
            let _e62 = transform;
            let _e63 = uv_1;
            uv_1 = (_e62 * _e63);
        }
        continuing {
            let _e47 = i;
            i = (_e47 + 1i);
        }
    }
    let _e65 = x_2;
    let _e66 = total;
    x_2 = (_e65 / _e66);
    let _e68 = x_2;
    return _e68;
}

fn rotation2_(angle_1: f32) -> mat2x2<f32> {
    var angle_2: f32;
    var ca: f32;
    var sa: f32;

    angle_2 = angle_1;
    let _e7 = angle_2;
    ca = cos(_e7);
    let _e10 = angle_2;
    sa = sin(_e10);
    let _e13 = ca;
    let _e14 = sa;
    let _e15 = sa;
    let _e17 = ca;
    return mat2x2<f32>(vec2<f32>(_e13, _e14), vec2<f32>(-(_e15), _e17));
}

fn sdTriangleIsosceles(p_4: vec2<f32>, q: vec2<f32>) -> f32 {
    var p_5: vec2<f32>;
    var q_1: vec2<f32>;
    var a_2: vec2<f32>;
    var b_2: vec2<f32>;
    var s_1: f32;
    var d_1: vec2<f32>;

    p_5 = p_4;
    q_1 = q;
    let _e10 = p_5;
    p_5.x = abs(_e10.x);
    let _e13 = p_5;
    let _e14 = q_1;
    let _e15 = p_5;
    let _e16 = q_1;
    let _e18 = q_1;
    let _e19 = q_1;
    a_2 = (_e13 - (_e14 * clamp((dot(_e15, _e16) / dot(_e18, _e19)), 0f, 1f)));
    let _e28 = p_5;
    let _e29 = q_1;
    let _e30 = p_5;
    let _e32 = q_1;
    b_2 = (_e28 - (_e29 * vec2<f32>(clamp((_e30.x / _e32.x), 0f, 1f), 1f)));
    let _e43 = q_1;
    s_1 = -(sign(_e43.y));
    let _e48 = a_2;
    let _e49 = a_2;
    let _e51 = s_1;
    let _e52 = p_5;
    let _e54 = q_1;
    let _e57 = p_5;
    let _e59 = q_1;
    let _e65 = b_2;
    let _e66 = b_2;
    let _e68 = s_1;
    let _e69 = p_5;
    let _e71 = q_1;
    d_1 = min(vec2<f32>(dot(_e48, _e49), (_e51 * ((_e52.x * _e54.y) - (_e57.y * _e59.x)))), vec2<f32>(dot(_e65, _e66), (_e68 * (_e69.y - _e71.y))));
    let _e78 = d_1;
    let _e82 = d_1;
    return (-(sqrt(_e78.x)) * sign(_e82.y));
}

fn sdVesica(u_4: vec2<f32>, r: f32, d_2: f32) -> f32 {
    var u_5: vec2<f32>;
    var r_1: f32;
    var d_3: f32;
    var b_3: f32;
    var local: f32;

    u_5 = u_4;
    r_1 = r;
    d_3 = d_2;
    let _e11 = u_5;
    u_5 = abs(_e11);
    let _e13 = r_1;
    let _e14 = r_1;
    let _e16 = d_3;
    let _e17 = d_3;
    b_3 = sqrt(((_e13 * _e14) - (_e16 * _e17)));
    let _e22 = u_5;
    let _e24 = b_3;
    let _e26 = d_3;
    let _e28 = u_5;
    let _e30 = b_3;
    if (((_e22.y - _e24) * _e26) > (_e28.x * _e30)) {
        let _e33 = u_5;
        let _e35 = b_3;
        local = length((_e33 - vec2<f32>(0f, _e35)));
    } else {
        let _e39 = u_5;
        let _e40 = d_3;
        let _e46 = r_1;
        local = (length((_e39 - vec2<f32>(-(_e40), 0f))) - _e46);
    }
    let _e49 = local;
    return _e49;
}

fn rabbit(v: vec2<f32>, id: f32) -> vec4<f32> {
    var v_1: vec2<f32>;
    var id_1: f32;
    var mainCol: vec4<f32> = vec4<f32>(0.95f, 0.93f, 0.9f, 1f);
    var d_4: f32;
    var uv_2: vec2<f32>;
    var u_6: vec2<f32>;

    v_1 = v;
    id_1 = id;
    let _e16 = v_1;
    v_1.y = (_e16.y + -0.08f);
    let _e23 = v_1;
    uv_2 = (_e23 - vec2<f32>(0.03f, 0.2f));
    let _e28 = uv_2;
    let _e33 = uv_2;
    u_6 = vec2<f32>((abs(_e28.x) - 0.055f), (_e33.y - 0f));
    let _e39 = u_6;
    if ((length(_e39) - 0.0125f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e50 = uv_2;
    u_6 = (_e50 - vec2<f32>(0f, -0.06f));
    let _e56 = u_6;
    let _e60 = sdTriangleIsosceles(_e56, vec2<f32>(0.01f, 0.01f));
    if ((_e60 - 0.005f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e70 = uv_2;
    d_4 = (length((_e70 * vec2<f32>(1f, 1.1f))) - 0.1f);
    let _e78 = d_4;
    if (_e78 < 0f) {
        let _e81 = mainCol;
        return _e81;
    }
    let _e82 = uv_2;
    let _e87 = uv_2;
    u_6 = vec2<f32>((abs(_e82.x) - 0.06f), (_e87.y + 0.02f));
    let _e92 = u_6;
    if ((length(_e92) - 0.06f) < 0f) {
        let _e98 = mainCol;
        return _e98;
    }
    let _e99 = uv_2;
    d_4 = (length(((_e99 * vec2<f32>(1f, 3f)) + vec2<f32>(0f, 0.22f))) - 0.1f);
    let _e111 = d_4;
    if (_e111 < 0f) {
        let _e114 = mainCol;
        let _e117 = (_e114.xyz * 0.8f);
        return vec4<f32>(_e117.x, _e117.y, _e117.z, 1f);
    }
    let _e123 = uv_2;
    let _e128 = uv_2;
    uv_2 = vec2<f32>((abs(_e123.x) - 0.07f), (_e128.y - 0.13f));
    let _e133 = uv_2;
    let _e136 = rotation2_(-0.3f);
    uv_2 = (_e133 * _e136);
    let _e138 = uv_2;
    let _e141 = sdVesica(_e138, 0.18f, 0.15f);
    d_4 = _e141;
    let _e142 = d_4;
    if (_e142 < 0f) {
        let _e145 = mainCol;
        let _e151 = (_e145.xyz * vec3<f32>(1f, 0.9f, 0.9f));
        return vec4<f32>(_e151.x, _e151.y, _e151.z, 1f);
    }
    let _e157 = uv_2;
    let _e160 = sdVesica(_e157, 0.2f, 0.15f);
    d_4 = _e160;
    let _e161 = d_4;
    if (_e161 < 0f) {
        let _e164 = mainCol;
        let _e167 = (_e164.xyz * 0.8f);
        return vec4<f32>(_e167.x, _e167.y, _e167.z, 1f);
    }
    let _e173 = v_1;
    uv_2 = _e173;
    let _e174 = uv_2;
    let _e182 = uv_2;
    d_4 = min((length((_e174 * vec2<f32>(0.8f, 1f))) - 0.13f), (length((_e182 - vec2<f32>(0.03f, 0.064f))) - 0.13f));
    let _e199 = d_4;
    if (_e199 < 0f) {
        let _e202 = mainCol;
        return _e202;
    }
    let _e203 = uv_2;
    d_4 = (length((_e203 + vec2<f32>(0.15f, 0.05f))) - 0.05f);
    let _e211 = d_4;
    if (_e211 < 0f) {
        let _e214 = mainCol;
        let _e217 = (_e214.xyz * 0.95f);
        return vec4<f32>(_e217.x, _e217.y, _e217.z, 1f);
    } else {
        return vec4(0f);
    }
}

fn sdRectangle(u_7: vec2<f32>, halfSize: vec2<f32>) -> f32 {
    var u_8: vec2<f32>;
    var halfSize_1: vec2<f32>;
    var local_1: f32;

    u_8 = u_7;
    halfSize_1 = halfSize;
    let _e9 = u_8;
    let _e11 = halfSize_1;
    u_8 = (abs(_e9) - _e11);
    let _e13 = u_8;
    let _e17 = u_8;
    if ((_e13.x >= 0f) && (_e17.y >= 0f)) {
        let _e22 = u_8;
        local_1 = length(_e22);
    } else {
        let _e24 = u_8;
        let _e26 = u_8;
        local_1 = max(_e24.x, _e26.y);
    }
    let _e30 = local_1;
    return _e30;
}

fn snowman(v_2: vec2<f32>, id_2: f32) -> vec4<f32> {
    var v_3: vec2<f32>;
    var id_3: f32;
    var mainCol_1: vec4<f32> = vec4<f32>(0.9f, 0.9f, 0.9f, 1f);
    var d_5: f32;
    var uv_3: vec2<f32>;
    var u_9: vec2<f32>;

    v_3 = v_2;
    id_3 = id_2;
    let _e16 = v_3;
    v_3.y = (_e16.y + -1.23f);
    let _e26 = v_3;
    uv_3 = _e26;
    let _e29 = rotation2_(-0.4f);
    let _e30 = uv_3;
    u_9 = (_e29 * (_e30 - vec2<f32>(0.39f, -0.3f)));
    let _e37 = u_9;
    let _e41 = sdRectangle(_e37, vec2<f32>(0.2f, 0.03f));
    d_5 = _e41;
    let _e42 = d_5;
    if (_e42 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    let _e52 = rotation2_(-0.8f);
    let _e53 = uv_3;
    u_9 = (_e52 * (_e53 - vec2<f32>(0.6f, -0.15f)));
    let _e60 = u_9;
    let _e64 = sdRectangle(_e60, vec2<f32>(0.12f, 0.025f));
    d_5 = _e64;
    let _e65 = d_5;
    if (_e65 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    let _e75 = rotation2_(-0.2f);
    let _e76 = uv_3;
    u_9 = (_e75 * (_e76 - vec2<f32>(0.68f, -0.2f)));
    let _e83 = u_9;
    let _e87 = sdRectangle(_e83, vec2<f32>(0.15f, 0.027f));
    d_5 = _e87;
    let _e88 = d_5;
    if (_e88 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    let _e96 = uv_3;
    let _e103 = uv_3;
    u_9 = vec2<f32>((abs((_e96.x + 0.1f)) - 0.12f), (_e103.y - 0.05f));
    let _e108 = u_9;
    if ((length(_e108) - 0.04f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e120 = rotation2_(1f);
    let _e121 = uv_3;
    u_9 = (_e120 * (_e121 + vec2<f32>(0.35f, 0.2f)));
    let _e127 = u_9;
    let _e131 = sdTriangleIsosceles(_e127, vec2<f32>(0.04f, 0.32f));
    if ((_e131 - 0.01f) < 0f) {
        return vec4<f32>(0.7f, 0.4f, 0.1f, 1f);
    }
    let _e141 = uv_3;
    d_5 = (length(_e141) - 0.35f);
    let _e145 = d_5;
    if (_e145 < 0f) {
        let _e148 = mainCol_1;
        let _e149 = _e148.xyz;
        return vec4<f32>(_e149.x, _e149.y, _e149.z, 1f);
    }
    let _e156 = uv_3;
    uv_3.y = (_e156.y + 0.45f);
    let _e160 = uv_3;
    let _e164 = uv_3;
    u_9 = vec2<f32>((_e160.x + 0.2f), (_e164.y - 0.1f));
    let _e169 = u_9;
    if ((length(_e169) - 0.04f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e180 = uv_3;
    let _e184 = uv_3;
    u_9 = vec2<f32>((_e180.x + 0.215f), (_e184.y + 0.05f));
    let _e189 = u_9;
    if ((length(_e189) - 0.04f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e200 = uv_3;
    let _e204 = uv_3;
    u_9 = vec2<f32>((_e200.x + 0.2f), (_e204.y + 0.2f));
    let _e209 = u_9;
    if ((length(_e209) - 0.04f) < 0f) {
        return vec4<f32>(0.2f, 0.2f, 0.2f, 1f);
    }
    let _e220 = uv_3;
    d_5 = (length(_e220) - 0.4f);
    let _e224 = d_5;
    if (_e224 < 0f) {
        {
            let _e227 = uv_3;
            d_5 = (length((_e227 - vec2<f32>(0f, 0.4f))) - 0.35f);
            let _e235 = mainCol_1;
            let _e236 = _e235.xyz;
            return vec4<f32>(_e236.x, _e236.y, _e236.z, 1f);
        }
    }
    let _e243 = uv_3;
    uv_3.y = (_e243.y + 0.525f);
    let _e247 = uv_3;
    d_5 = (length(_e247) - 0.5f);
    let _e251 = d_5;
    if (_e251 < 0f) {
        {
            let _e254 = uv_3;
            d_5 = (length((_e254 - vec2<f32>(0f, 0.4f))) - 0.4f);
            let _e262 = mainCol_1;
            let _e263 = _e262.xyz;
            return vec4<f32>(_e263.x, _e263.y, _e263.z, 1f);
        }
    }
    let _e270 = uv_3;
    uv_3.y = (_e270.y - 0.9f);
    let _e276 = rotation2_(-2.7f);
    let _e277 = uv_3;
    u_9 = (_e276 * (_e277 - vec2<f32>(0.2f, 0.68f)));
    let _e283 = u_9;
    let _e287 = sdTriangleIsosceles(_e283, vec2<f32>(0.18f, 0.42f));
    d_5 = (_e287 - 0f);
    let _e290 = d_5;
    if (_e290 < 0f) {
        return vec4<f32>(0.8f, 0.1f, 0.1f, 1f);
    }
    let _e299 = uv_3;
    uv_3.x = -(_e299.x);
    let _e304 = rotation2_(-0.4f);
    let _e305 = uv_3;
    u_9 = (_e304 * (_e305 - vec2<f32>(0.39f, -0.3f)));
    let _e312 = u_9;
    let _e316 = sdRectangle(_e312, vec2<f32>(0.2f, 0.03f));
    d_5 = _e316;
    let _e317 = d_5;
    if (_e317 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    let _e327 = rotation2_(-0.8f);
    let _e328 = uv_3;
    u_9 = (_e327 * (_e328 - vec2<f32>(0.6f, -0.15f)));
    let _e335 = u_9;
    let _e339 = sdRectangle(_e335, vec2<f32>(0.12f, 0.025f));
    d_5 = _e339;
    let _e340 = d_5;
    if (_e340 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    let _e350 = rotation2_(-0.2f);
    let _e351 = uv_3;
    u_9 = (_e350 * (_e351 - vec2<f32>(0.68f, -0.2f)));
    let _e358 = u_9;
    let _e362 = sdRectangle(_e358, vec2<f32>(0.15f, 0.027f));
    d_5 = _e362;
    let _e363 = d_5;
    if (_e363 < 0f) {
        return vec4<f32>(0.5f, 0.3f, 0.05f, 1f);
    }
    return vec4(0f);
}

fn tf(m: mat3x3<f32>, u_10: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_11: vec2<f32>;

    m_1 = m;
    u_11 = u_10;
    let _e9 = m_1;
    let _e10 = u_11;
    return (_e9 * vec3<f32>(_e10.x, _e10.y, 1f)).xy;
}

fn sdStar5_(p_6: vec2<f32>, r_2: f32, rf: f32) -> f32 {
    var p_7: vec2<f32>;
    var r_3: f32;
    var rf_1: f32;
    var k1_2: vec2<f32> = vec2<f32>(0.809017f, -0.58778524f);
    var k2_2: vec2<f32>;
    var ba: vec2<f32>;
    var h: f32;

    p_7 = p_6;
    r_3 = r_2;
    rf_1 = rf;
    let _e16 = k1_2;
    let _e19 = k1_2;
    k2_2 = vec2<f32>(-(_e16.x), _e19.y);
    let _e24 = p_7;
    p_7.x = abs(_e24.x);
    let _e27 = p_7;
    let _e29 = k1_2;
    let _e30 = p_7;
    let _e35 = k1_2;
    p_7 = (_e27 - ((2f * max(dot(_e29, _e30), 0f)) * _e35));
    let _e38 = p_7;
    let _e40 = k2_2;
    let _e41 = p_7;
    let _e46 = k2_2;
    p_7 = (_e38 - ((2f * max(dot(_e40, _e41), 0f)) * _e46));
    let _e50 = p_7;
    p_7.x = abs(_e50.x);
    let _e54 = p_7;
    let _e56 = r_3;
    p_7.y = (_e54.y - _e56);
    let _e58 = rf_1;
    let _e59 = k1_2;
    let _e62 = k1_2;
    ba = ((_e58 * vec2<f32>(-(_e59.y), _e62.x)) - vec2<f32>(0f, 1f));
    let _e73 = p_7;
    let _e74 = ba;
    let _e76 = ba;
    let _e77 = ba;
    let _e81 = r_3;
    h = clamp((dot(_e73, _e74) / dot(_e76, _e77)), 0f, _e81);
    let _e84 = p_7;
    let _e85 = ba;
    let _e86 = h;
    let _e90 = p_7;
    let _e92 = ba;
    let _e95 = p_7;
    let _e97 = ba;
    return (length((_e84 - (_e85 * _e86))) * sign(((_e90.y * _e92.x) - (_e95.x * _e97.y))));
}

fn triangleToSquareWave(x_3: f32, k_5: f32) -> f32 {
    var x_4: f32;
    var k_6: f32;
    var s_2: f32 = 1f;
    var local_2: f32;
    var m_2: f32;

    x_4 = x_3;
    k_6 = k_5;
    let _e9 = x_4;
    x_4 = (_e9 - (floor((_e9 / 4f)) * 4f));
    let _e17 = x_4;
    if (_e17 > 2f) {
        {
            let _e20 = x_4;
            x_4 = (_e20 - 2f);
            s_2 = -1f;
        }
    }
    let _e25 = k_6;
    if (_e25 > 0f) {
        local_2 = 1f;
    } else {
        let _e31 = k_6;
        let _e34 = k_6;
        local_2 = pow(mix(5f, 40f, -(_e31)), -(_e34));
    }
    let _e38 = local_2;
    m_2 = _e38;
    let _e40 = m_2;
    let _e41 = s_2;
    let _e44 = x_4;
    let _e49 = k_6;
    return ((_e40 * _e41) * (1f - pow(abs((_e44 - 1f)), pow(100f, _e49))));
}

fn tree4_(uv_4: vec2<f32>, id_4: f32, treePattern: f32, treeColor: vec4<f32>, treeTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_5: vec2<f32>;
    var id_5: f32;
    var treePattern_1: f32;
    var treeColor_1: vec4<f32>;
    var treeTransform_1: mat3x3<f32>;
    var rnd_1: f32;
    var angle_3: f32;
    var treeProb: f32;
    var rot: mat2x2<f32>;
    var d_6: f32 = 0f;
    var dShade: f32;
    var col_2: vec4<f32> = vec4<f32>(0.1f, 0.6f, 0.3f, 1f);
    var colTransition: f32;
    var otherCol: vec4<f32>;
    var intensity: f32;
    var shape: f32;
    var u_12: vec2<f32>;

    uv_5 = uv_4;
    id_5 = id_4;
    treePattern_1 = treePattern;
    treeColor_1 = treeColor;
    treeTransform_1 = treeTransform;
    let _e15 = id_5;
    let _e16 = hash11_(_e15);
    rnd_1 = _e16;
    let _e18 = rnd_1;
    angle_3 = ((_e18 - 0.5f) * 0.15f);
    let _e24 = id_5;
    treeProb = sin((_e24 * 0.25f));
    let _e29 = rnd_1;
    let _e35 = treeProb;
    let _e37 = treeProb;
    let _e39 = treeProb;
    if (fract((_e29 * 11.1f)) > (0.25f + (((0.5f * _e35) * _e37) * _e39))) {
        return vec4(0f);
    }
    let _e45 = angle_3;
    let _e46 = rotation2_(_e45);
    let _e49 = angle_3;
    rot = (_e46 * (1.05f + (6f * _e49)));
    let _e54 = rot;
    let _e55 = uv_5;
    uv_5 = (_e54 * _e55);
    let _e57 = rnd_1;
    if (fract((_e57 * 10f)) < 0.015f) {
        {
            let _e63 = uv_5;
            if (length((_e63 - vec2<f32>(0.1f, 0.8f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.8f, 0.04f, 1f);
            }
            let _e76 = uv_5;
            if (length((_e76 - vec2<f32>(-0.1f, 1.2f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.8f, 0.04f, 1f);
            }
            let _e90 = uv_5;
            if (length((_e90 - vec2<f32>(0.1f, 1.7f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.8f, 0.04f, 1f);
            }
            let _e103 = uv_5;
            if (length((_e103 - vec2<f32>(-0.1f, 2f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.8f, 0.04f, 1f);
            }
            let _e117 = uv_5;
            if (length((_e117 - vec2<f32>(-0.2f, 0.7f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.1f, 0.04f, 1f);
            }
            let _e131 = uv_5;
            if (length((_e131 - vec2<f32>(0.2f, 1.3f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.1f, 0.04f, 1f);
            }
            let _e144 = uv_5;
            if (length((_e144 - vec2<f32>(0.05f, 2.3f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.1f, 0.04f, 1f);
            }
            let _e157 = uv_5;
            if (length((_e157 - vec2<f32>(-0.2f, 1.5f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.1f, 0.04f, 1f);
            }
            let _e171 = uv_5;
            if (length((_e171 - vec2<f32>(0.35f, 0.45f))) < 0.07f) {
                return vec4<f32>(0.9f, 0.1f, 0.04f, 1f);
            }
            let _e184 = uv_5;
            let _e191 = sdStar5_((_e184 - vec2<f32>(0f, 2.75f)), 0.25f, 0.45f);
            if (_e191 < 0f) {
                return vec4<f32>(0.9f, 0.8f, 0.04f, 1f);
            }
        }
    }
    let _e201 = d_6;
    if (_e201 < 0f) {
        return vec4<f32>(0.5f, 0.25f, 0.15f, 1f);
    }
    let _e209 = d_6;
    let _e210 = uv_5;
    let _e212 = uv_5;
    let _e221 = sdTriangleIsosceles(vec2<f32>(_e210.x, (-(_e212.y) + 2f)), vec2<f32>(0.5f, 1.5f));
    d_6 = min(_e209, (_e221 - 0.05f));
    let _e225 = d_6;
    let _e226 = uv_5;
    let _e228 = uv_5;
    let _e242 = sdTriangleIsosceles(vec2<f32>(_e226.x, (-(_e228.y) + 2.3f)), vec2<f32>(0.375f, 1.125f));
    d_6 = min(_e225, (_e242 - 0.05f));
    let _e246 = d_6;
    let _e247 = uv_5;
    let _e249 = uv_5;
    let _e263 = sdTriangleIsosceles(vec2<f32>(_e247.x, (-(_e249.y) + 2.6f)), vec2<f32>(0.25f, 0.75f));
    d_6 = min(_e246, (_e263 - 0.05f));
    let _e267 = d_6;
    if (_e267 < 0f) {
        {
            let _e270 = d_6;
            let _e271 = uv_5;
            let _e273 = uv_5;
            let _e287 = sdTriangleIsosceles(vec2<f32>(_e271.x, (-(_e273.y) + 1.85f)), vec2<f32>(0.5f, 1.5f));
            dShade = min(_e270, (_e287 - 0.05f));
            let _e298 = treePattern_1;
            if (_e298 > 1f) {
                {
                    let _e301 = treePattern_1;
                    colTransition = min((_e301 - 1f), 1f);
                    let _e307 = col_2;
                    let _e308 = treeColor_1;
                    let _e309 = _e308.xyz;
                    let _e310 = treeColor_1;
                    let _e312 = colTransition;
                    let _e318 = mergeColor(_e307, vec4<f32>(_e309.x, _e309.y, _e309.z, (_e310.w * _e312)));
                    otherCol = _e318;
                    let _e321 = treePattern_1;
                    intensity = (max(0f, (_e321 - 2f)) * 0.1f);
                    let _e328 = treePattern_1;
                    let _e332 = ((_e328 - 1f) * 2f);
                    shape = ((abs(((_e332 - (floor((_e332 / 2f)) * 2f)) - 1f)) * 2f) - 1f);
                    let _e346 = treeTransform_1;
                    let _e348 = uv_5;
                    let _e351 = tf(_naga_inverse_3x3_f32(_e346), (_e348 * 4f));
                    u_12 = _e351;
                    let _e353 = col_2;
                    let _e354 = otherCol;
                    let _e355 = u_12;
                    let _e357 = u_12;
                    let _e359 = shape;
                    let _e360 = triangleToSquareWave(_e357.x, _e359);
                    let _e361 = intensity;
                    let _e363 = (_e355.y + (_e360 * _e361));
                    col_2 = mix(_e353, _e354, vec4(floor((_e363 - (floor((_e363 / 2f)) * 2f)))));
                }
            }
            let _e372 = col_2;
            let _e381 = treePattern_1;
            let _e385 = dShade;
            let _e388 = (_e372.xyz * mix(0.8f, 1f, smoothstep(mix(-0.125f, -0.25f, min(1f, _e381)), 0f, _e385)));
            let _e389 = col_2;
            return vec4<f32>(_e388.x, _e388.y, _e388.z, _e389.w);
        }
    }
    let _e395 = uv_5;
    let _e403 = sdRectangle((_e395 - vec2<f32>(0f, 0f)), vec2<f32>(0.1f, 0.7f));
    d_6 = _e403;
    let _e404 = d_6;
    if (_e404 < 0f) {
        let _e419 = uv_5;
        return mix(vec4<f32>(0.5f, 0.25f, 0.15f, 1f), vec4<f32>(0.25f, 0.125f, 0.075f, 1f), vec4(smoothstep(0f, 0.5f, _e419.y)));
    } else {
        return vec4(0f);
    }
}

fn hills3_(uv_6: vec2<f32>, hillPattern: f32, hillColor: vec4<f32>, hillTransform: mat3x3<f32>, treePattern_2: f32, treeColor_2: vec4<f32>, treeTransform_2: mat3x3<f32>) -> vec4<f32> {
    var uv_7: vec2<f32>;
    var hillPattern_1: f32;
    var hillColor_1: vec4<f32>;
    var hillTransform_1: mat3x3<f32>;
    var treePattern_3: f32;
    var treeColor_3: vec4<f32>;
    var treeTransform_3: mat3x3<f32>;
    var y: f32;
    var h_1: f32;
    var dx: f32 = 0.02f;
    var h2_: f32;
    var dy: f32;
    var hh: f32;
    var col_3: vec4<f32> = vec4<f32>(0.9f, 0.9f, 0.9f, 1f);
    var otherCol_1: vec4<f32>;
    var X: f32;
    var x_5: f32;
    var hh_1: f32;
    var hh2_: f32;
    var rnd_2: f32;
    var rnd2_: f32;
    var dy_1: f32;
    var rabbitCol: vec4<f32>;
    var snowmanCol: vec4<f32>;
    var treeCol: vec4<f32>;
    var delta: f32 = 0.0625f;

    uv_7 = uv_6;
    hillPattern_1 = hillPattern;
    hillColor_1 = hillColor;
    hillTransform_1 = hillTransform;
    treePattern_3 = treePattern_2;
    treeColor_3 = treeColor_2;
    treeTransform_3 = treeTransform_2;
    let _e19 = uv_7;
    y = -(_e19.y);
    let _e23 = uv_7;
    let _e28 = perlinOctaveNoise(vec2<f32>(_e23.x, 0f), 1i);
    h_1 = (_e28 - 0.5f);
    let _e34 = uv_7;
    let _e36 = dx;
    let _e41 = perlinOctaveNoise(vec2<f32>((_e34.x + _e36), 0f), 1i);
    h2_ = (_e41 - 0.5f);
    let _e45 = h2_;
    let _e46 = h_1;
    let _e48 = dx;
    dy = ((_e45 - _e46) / _e48);
    let _e51 = h_1;
    let _e54 = h_1;
    let _e55 = dy;
    hh = min((_e51 - 0.04f), (_e54 + (_e55 * 2f)));
    let _e61 = y;
    let _e62 = h_1;
    if (_e61 < _e62) {
        {
            let _e70 = hillPattern_1;
            if (_e70 != 0f) {
                {
                    let _e73 = col_3;
                    let _e74 = hillColor_1;
                    let _e75 = mergeColor(_e73, _e74);
                    otherCol_1 = _e75;
                    let _e77 = col_3;
                    let _e78 = otherCol_1;
                    let _e79 = hillTransform_1;
                    let _e80 = uv_7;
                    let _e82 = uv_7;
                    let _e86 = tf(_e79, vec2<f32>(_e80.x, -(_e82.y)));
                    let _e88 = h_1;
                    let _e91 = hillPattern_1;
                    let _e96 = (pow(abs((_e86.y - _e88)), (_e91 * 2f)) * 20f);
                    col_3 = mix(_e77, _e78, vec4(floor((_e96 - (floor((_e96 / 2f)) * 2f)))));
                }
            }
            let _e105 = col_3;
            let _e107 = col_3;
            let _e111 = h_1;
            let _e112 = hh;
            let _e113 = y;
            let _e116 = (_e107.xyz * mix(1f, 0.9f, smoothstep(_e111, _e112, _e113)));
            col_3.x = _e116.x;
            col_3.y = _e116.y;
            col_3.z = _e116.z;
            let _e123 = col_3;
            return _e123;
        }
    } else {
        {
            let _e124 = y;
            let _e125 = h_1;
            if ((_e124 - _e125) > 0.32f) {
                return vec4(0f);
            }
            let _e135 = uv_7;
            X = ((round((_e135.x * 5f)) - 0f) / 5f);
            let _e144 = uv_7;
            let _e146 = X;
            let _e151 = y;
            let _e152 = h_1;
            if ((abs((_e144.x - _e146)) < 0.06f) && (abs((_e151 - _e152)) < 0.2f)) {
                {
                    let _e158 = X;
                    let _e159 = hash11_(_e158);
                    rnd_2 = _e159;
                    let _e161 = rnd_2;
                    rnd2_ = fract(((_e161 * 34.3f) + 0.333f));
                    let _e168 = rnd2_;
                    if (_e168 < 0.025f) {
                        {
                            let _e171 = uv_7;
                            let _e173 = X;
                            x_5 = ((_e171.x - _e173) * 5f);
                            let _e177 = X;
                            let _e181 = perlinOctaveNoise(vec2<f32>(_e177, 0f), 1i);
                            hh_1 = (_e181 - 0.5f);
                            let _e184 = X;
                            let _e185 = dx;
                            let _e190 = perlinOctaveNoise(vec2<f32>((_e184 + _e185), 0f), 1i);
                            hh2_ = (_e190 - 0.5f);
                            let _e193 = hh2_;
                            let _e194 = hh_1;
                            let _e196 = dx;
                            dy_1 = ((_e193 - _e194) / _e196);
                            let _e199 = dy_1;
                            if (abs(_e199) < 0.15f) {
                                {
                                    let _e204 = x_5;
                                    let _e205 = y;
                                    let _e206 = hh_1;
                                    let _e212 = X;
                                    let _e213 = rabbit((3f * vec2<f32>(_e204, ((_e205 - _e206) * 5f))), _e212);
                                    rabbitCol = _e213;
                                    let _e215 = rabbitCol;
                                    if (_e215.w != 0f) {
                                        let _e219 = rabbitCol;
                                        return _e219;
                                    }
                                }
                            }
                        }
                    }
                    let _e220 = rnd2_;
                    if (_e220 > 0.985f) {
                        {
                            let _e223 = uv_7;
                            let _e225 = X;
                            x_5 = ((_e223.x - _e225) * 5f);
                            let _e229 = X;
                            let _e233 = perlinOctaveNoise(vec2<f32>(_e229, 0f), 1i);
                            hh_1 = (_e233 - 0.5f);
                            let _e237 = x_5;
                            let _e238 = y;
                            let _e239 = hh_1;
                            let _e245 = X;
                            let _e246 = snowman((5f * vec2<f32>(_e237, ((_e238 - _e239) * 5f))), _e245);
                            snowmanCol = _e246;
                            let _e248 = snowmanCol;
                            if (_e248.w != 0f) {
                                let _e252 = snowmanCol;
                                return _e252;
                            }
                        }
                    }
                }
            }
            let _e253 = uv_7;
            X = ((round((_e253.x * 8f)) - 0f) / 8f);
            let _e262 = uv_7;
            let _e264 = X;
            x_5 = ((_e262.x - _e264) * 8f);
            let _e268 = X;
            let _e272 = perlinOctaveNoise(vec2<f32>(_e268, 0f), 1i);
            hh_1 = (_e272 - 0.5f);
            let _e276 = x_5;
            let _e277 = y;
            let _e278 = hh_1;
            let _e284 = X;
            let _e285 = treePattern_3;
            let _e286 = treeColor_3;
            let _e287 = treeTransform_3;
            let _e288 = tree4_((2f * vec2<f32>(_e276, ((_e277 - _e278) * 8f))), _e284, _e285, _e286, _e287);
            treeCol = _e288;
            let _e290 = treeCol;
            if (_e290.w != 0f) {
                let _e294 = treeCol;
                return _e294;
            }
            let _e297 = uv_7;
            let _e299 = delta;
            X = (round(((_e297.x + _e299) * 8f)) / 8f);
            let _e306 = uv_7;
            let _e308 = delta;
            let _e310 = X;
            x_5 = (((_e306.x + _e308) - _e310) * 8f);
            let _e314 = X;
            let _e315 = delta;
            let _e320 = perlinOctaveNoise(vec2<f32>((_e314 - _e315), 0f), 1i);
            hh_1 = (_e320 - 0.5f);
            let _e324 = x_5;
            let _e325 = y;
            let _e326 = hh_1;
            let _e332 = X;
            let _e333 = delta;
            let _e335 = treePattern_3;
            let _e336 = treeColor_3;
            let _e337 = treeTransform_3;
            let _e338 = tree4_((2f * vec2<f32>(_e324, ((_e325 - _e326) * 8f))), (_e332 - _e333), _e335, _e336, _e337);
            treeCol = (_e338 * vec4<f32>(0.9f, 0.9f, 0.9f, 1f));
            let _e344 = treeCol;
            if (_e344.w != 0f) {
                let _e348 = treeCol;
                return _e348;
            }
            return vec4(0f);
        }
    }
}

fn multiSine(x_6: f32, n_2: i32, kf: f32, power: f32) -> f32 {
    var x_7: f32;
    var n_3: i32;
    var kf_1: f32;
    var power_1: f32;
    var y_1: f32 = 0f;
    var k_7: f32 = 1f;
    var f_1: f32 = 1f;
    var totalK: f32 = 0f;
    var i_1: i32 = 0i;

    x_7 = x_6;
    n_3 = n_2;
    kf_1 = kf;
    power_1 = power;
    loop {
        let _e23 = i_1;
        let _e24 = n_3;
        if !((_e23 < _e24)) {
            break;
        }
        {
            let _e30 = y_1;
            let _e31 = k_7;
            let _e33 = x_7;
            let _e34 = f_1;
            y_1 = (_e30 + ((_e31 * (0.75f - abs((sin(((_e33 * _e34) + 1f)) - 0.5f)))) / 0.75f));
            let _e47 = totalK;
            let _e48 = k_7;
            totalK = (_e47 + _e48);
            let _e50 = k_7;
            k_7 = (_e50 * 0.35f);
            let _e53 = f_1;
            let _e54 = kf_1;
            f_1 = (_e53 * _e54);
        }
        continuing {
            let _e27 = i_1;
            i_1 = (_e27 + 1i);
        }
    }
    let _e56 = y_1;
    let _e57 = totalK;
    let _e60 = power_1;
    let _e62 = y_1;
    return (pow(abs((_e56 / _e57)), _e60) * sign(_e62));
}

fn mountains4_(uv_8: vec2<f32>, kf_2: f32, mountainPattern: f32, mountainDetail: f32, mountainColor: vec4<f32>, mountainTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_9: vec2<f32>;
    var kf_3: f32;
    var mountainPattern_1: f32;
    var mountainDetail_1: f32;
    var mountainColor_1: vec4<f32>;
    var mountainTransform_1: mat3x3<f32>;
    var y_2: f32;
    var N: i32 = 6i;
    var msd: f32;
    var h_2: f32;
    var dx_1: f32 = 0.02f;
    var msd2_: f32;
    var dy_2: f32;
    var snowloss: f32;
    var h2_1: f32;
    var col_4: vec4<f32>;
    var colTransition_1: f32;
    var otherCol_2: vec4<f32>;
    var intensity_1: f32;
    var shape_1: f32;
    var u_13: vec2<f32>;

    uv_9 = uv_8;
    kf_3 = kf_2;
    mountainPattern_1 = mountainPattern;
    mountainDetail_1 = mountainDetail;
    mountainColor_1 = mountainColor;
    mountainTransform_1 = mountainTransform;
    let _e17 = uv_9;
    y_2 = -(_e17.y);
    let _e21 = y_2;
    if (_e21 > 1f) {
        return vec4(0f);
    }
    let _e28 = uv_9;
    let _e30 = N;
    let _e31 = kf_3;
    let _e33 = multiSine(_e28.x, _e30, _e31, 2f);
    msd = _e33;
    let _e36 = msd;
    let _e39 = uv_9;
    let _e44 = perlinOctaveNoise(vec2<f32>(_e39.x, 0f), 1i);
    h_2 = (((0.75f * _e36) + (0.002f * (_e44 - 0.5f))) + 0.2f);
    let _e54 = uv_9;
    let _e56 = dx_1;
    let _e58 = N;
    let _e59 = kf_3;
    let _e61 = multiSine((_e54.x + _e56), _e58, _e59, 2f);
    msd2_ = _e61;
    let _e63 = msd2_;
    let _e64 = msd;
    let _e66 = dx_1;
    dy_2 = ((_e63 - _e64) / _e66);
    let _e70 = mountainDetail_1;
    if (_e70 <= 1f) {
        {
            let _e74 = h_2;
            let _e80 = mountainDetail_1;
            let _e83 = dy_2;
            let _e84 = dy_2;
            snowloss = (pow(0.5f, (_e74 * 10f)) - (mix(0f, 0.1f, _e80) * (1f + mix(_e83, abs(_e84), 0.45f))));
        }
    } else {
        let _e91 = mountainDetail_1;
        if (_e91 <= 2f) {
            {
                let _e95 = h_2;
                let _e102 = dy_2;
                let _e103 = dy_2;
                let _e111 = mountainDetail_1;
                let _e117 = y_2;
                let _e120 = uv_9;
                let _e124 = perlinOctaveNoise((_e120 * 15f), 2i);
                snowloss = (((pow(0.5f, (_e95 * 10f)) - 0.1f) - (0.1f * mix(_e102, abs(_e103), 0.45f))) + ((mix(0f, 1f, (_e111 - 1f)) * smoothstep(0f, 0.5f, _e117)) * (_e124 - 0.5f)));
            }
        } else {
            let _e129 = mountainDetail_1;
            if (_e129 <= 3f) {
                {
                    let _e133 = h_2;
                    let _e139 = mountainDetail_1;
                    let _e144 = dy_2;
                    let _e145 = dy_2;
                    let _e154 = mountainDetail_1;
                    let _e160 = y_2;
                    let _e163 = uv_9;
                    let _e167 = perlinOctaveNoise((_e163 * 15f), 2i);
                    snowloss = ((pow(0.5f, (_e133 * 10f)) - (mix(0.1f, 0f, (_e139 - 2f)) * (1f + mix(_e144, abs(_e145), 0.45f)))) + ((mix(1f, 0f, (_e154 - 2f)) * smoothstep(0f, 0.5f, _e160)) * (_e167 - 0.5f)));
                }
            }
        }
    }
    let _e172 = h_2;
    let _e173 = snowloss;
    h2_1 = (_e172 + _e173);
    let _e177 = y_2;
    let _e178 = h_2;
    if (_e177 > _e178) {
        col_4 = vec4(0f);
    } else {
        let _e182 = y_2;
        let _e183 = h2_1;
        if (_e182 < _e183) {
            col_4 = vec4<f32>(0.9f, 0.9f, 0.9f, 1f);
        } else {
            col_4 = vec4<f32>(0.5f, 0.5f, 0.5f, 1f);
        }
    }
    let _e195 = mountainPattern_1;
    let _e198 = y_2;
    let _e199 = h_2;
    if ((_e195 != 0f) && (_e198 <= _e199)) {
        {
            let _e202 = mountainPattern_1;
            colTransition_1 = min(_e202, 1f);
            let _e206 = col_4;
            let _e207 = mountainColor_1;
            let _e208 = _e207.xyz;
            let _e209 = mountainColor_1;
            let _e211 = colTransition_1;
            let _e217 = mergeColor(_e206, vec4<f32>(_e208.x, _e208.y, _e208.z, (_e209.w * _e211)));
            otherCol_2 = _e217;
            let _e220 = mountainPattern_1;
            intensity_1 = (max(0f, (_e220 - 2f)) * 0.1f);
            let _e227 = mountainPattern_1;
            let _e231 = ((_e227 - 1f) * 2f);
            shape_1 = ((abs(((_e231 - (floor((_e231 / 2f)) * 2f)) - 1f)) * 2f) - 1f);
            let _e245 = mountainTransform_1;
            let _e247 = uv_9;
            let _e249 = h_2;
            let _e252 = mountainPattern_1;
            let _e259 = tf(_naga_inverse_3x3_f32(_e245), ((_e247 + vec2<f32>(0f, (_e249 * smoothstep(2f, 1f, _e252)))) * 20f));
            u_13 = _e259;
            let _e261 = col_4;
            let _e262 = otherCol_2;
            let _e263 = u_13;
            let _e265 = u_13;
            let _e267 = shape_1;
            let _e268 = triangleToSquareWave(_e265.x, _e267);
            let _e269 = intensity_1;
            let _e271 = (_e263.y + (_e268 * _e269));
            col_4 = mix(_e261, _e262, vec4(floor((_e271 - (floor((_e271 / 2f)) * 2f)))));
        }
    }
    let _e280 = col_4;
    return _e280;
}

fn hash12_(x_8: f32) -> vec2<f32> {
    var x_9: f32;

    x_9 = x_8;
    let _e7 = x_9;
    let _e14 = x_9;
    return vec2<f32>(fract((sin((_e7 * 776.4577f)) * 45.77f)), fract((sin(((_e14 * 376.4517f) + 1.2524f)) * 88.77f)));
}

fn sdUnevenCapsule(p_8: vec2<f32>, r1_: f32, r2_: f32, h_3: f32) -> f32 {
    var p_9: vec2<f32>;
    var r1_1: f32;
    var r2_1: f32;
    var h_4: f32;
    var b_4: f32;
    var a_3: f32;
    var k_8: f32;

    p_9 = p_8;
    r1_1 = r1_;
    r2_1 = r2_;
    h_4 = h_3;
    let _e14 = p_9;
    p_9.x = abs(_e14.x);
    let _e17 = r1_1;
    let _e18 = r2_1;
    let _e20 = h_4;
    b_4 = ((_e17 - _e18) / _e20);
    let _e24 = b_4;
    let _e25 = b_4;
    a_3 = sqrt((1f - (_e24 * _e25)));
    let _e30 = p_9;
    let _e31 = b_4;
    let _e33 = a_3;
    k_8 = dot(_e30, vec2<f32>(-(_e31), _e33));
    let _e37 = k_8;
    if (_e37 < 0f) {
        let _e40 = p_9;
        let _e42 = r1_1;
        return (length(_e40) - _e42);
    }
    let _e44 = k_8;
    let _e45 = a_3;
    let _e46 = h_4;
    if (_e44 > (_e45 * _e46)) {
        let _e49 = p_9;
        let _e51 = h_4;
        let _e55 = r2_1;
        return (length((_e49 - vec2<f32>(0f, _e51))) - _e55);
    }
    let _e57 = p_9;
    let _e58 = a_3;
    let _e59 = b_4;
    let _e62 = r1_1;
    return (dot(_e57, vec2<f32>(_e58, _e59)) - _e62);
}

fn shootingStarLayer(uv_10: vec2<f32>, time_2: f32) -> vec4<f32> {
    var uv_11: vec2<f32>;
    var time_3: f32;
    var k_9: f32 = 0f;
    var N_1: f32 = 5f;
    var i_2: f32 = 0f;
    var rnd_3: vec2<f32>;
    var radius: f32;
    var strength: f32;
    var point: vec2<f32>;
    var dir: vec2<f32>;
    var center: vec2<f32>;
    var startAngle: f32;
    var angle_4: f32;
    var pos: vec2<f32>;
    var trailUv: vec2<f32>;
    var trailD: f32;

    uv_11 = uv_10;
    time_3 = time_2;
    loop {
        let _e15 = i_2;
        let _e16 = N_1;
        if !((_e15 < _e16)) {
            break;
        }
        {
            let _e22 = i_2;
            let _e23 = hash12_(_e22);
            rnd_3 = _e23;
            let _e26 = rnd_3;
            radius = ((1f + fract((_e26.x * 10f))) * 350f);
            let _e36 = rnd_3;
            strength = (0.2f + fract((_e36.x * 23.32f)));
            let _e43 = rnd_3;
            point = (((_e43 - vec2(0.5f)) * 40f) + vec2<f32>(0f, 0f));
            let _e54 = point;
            dir = normalize(_e54);
            let _e57 = point;
            let _e58 = dir;
            let _e59 = radius;
            center = (_e57 - (_e58 * _e59));
            let _e63 = rnd_3;
            startAngle = (fract((_e63.y * 10f)) * 6.28f);
            let _e71 = startAngle;
            let _e72 = time_3;
            angle_4 = (_e71 + (_e72 * 1f));
            let _e77 = center;
            let _e78 = radius;
            let _e79 = angle_4;
            let _e81 = angle_4;
            pos = (_e77 + (_e78 * vec2<f32>(cos(_e79), sin(_e81))));
            let _e87 = pos;
            let _e88 = center;
            dir = normalize((_e87 - _e88));
            let _e99 = dir;
            let _e100 = dir;
            let _e103 = dir;
            let _e105 = vec2<f32>(-(_e100.y), _e103.x);
            let _e115 = uv_11;
            let _e116 = pos;
            trailUv = ((mat2x2<f32>(vec2<f32>(1f, 0f), vec2<f32>(0f, -1f)) * _naga_inverse_2x2_f32(mat2x2<f32>(vec2<f32>(_e99.x, _e99.y), vec2<f32>(_e105.x, _e105.y)))) * (_e115 - _e116));
            let _e120 = k_9;
            let _e122 = trailUv;
            let _e127 = strength;
            k_9 = (_e120 + ((0.05f / pow(length(_e122), 2f)) * _e127));
            let _e130 = trailUv;
            let _e134 = sdUnevenCapsule(_e130, 0.5f, 0.005f, 15f);
            trailD = _e134;
            let _e136 = k_9;
            let _e138 = trailD;
            let _e144 = strength;
            k_9 = (_e136 + ((1f / pow((_e138 + 1.5f), 3f)) * _e144));
        }
        continuing {
            let _e19 = i_2;
            i_2 = (_e19 + 1f);
        }
    }
    let _e150 = k_9;
    return vec4<f32>(1f, 1f, 1f, _e150);
}

fn starLayer(uv_12: vec2<f32>) -> vec4<f32> {
    var uv_13: vec2<f32>;
    var N_2: f32 = 1f;
    var id_6: vec2<f32>;
    var total_1: f32 = 0f;
    var x_10: f32;
    var y_3: f32;
    var starId: vec2<f32>;
    var rnd_4: vec2<f32>;
    var starCenter: vec2<f32>;
    var r_4: f32;

    uv_13 = uv_12;
    let _e9 = uv_13;
    id_6 = round(_e9);
    let _e14 = N_2;
    x_10 = -(_e14);
    loop {
        let _e17 = x_10;
        let _e18 = N_2;
        if !((_e17 <= _e18)) {
            break;
        }
        {
            let _e24 = N_2;
            y_3 = -(_e24);
            loop {
                let _e27 = y_3;
                let _e28 = N_2;
                if !((_e27 <= _e28)) {
                    break;
                }
                {
                    let _e34 = id_6;
                    let _e36 = x_10;
                    let _e38 = id_6;
                    let _e40 = y_3;
                    starId = vec2<f32>((_e34.x + _e36), (_e38.y + _e40));
                    let _e44 = starId;
                    let _e45 = hash22b(_e44);
                    rnd_4 = _e45;
                    let _e47 = starId;
                    let _e48 = rnd_4;
                    starCenter = (_e47 + ((_e48 - vec2(0.5f)) * 2f));
                    let _e56 = rnd_4;
                    let _e58 = rnd_4;
                    r_4 = ((pow(fract(((_e56.x + _e58.y) * 10f)), 15f) * 0.15f) + 0.00001f);
                    let _e71 = total_1;
                    let _e72 = r_4;
                    let _e75 = r_4;
                    let _e78 = uv_13;
                    let _e79 = starCenter;
                    total_1 = (_e71 + smoothstep((_e72 * 1.5f), (_e75 * 0.5f), length((_e78 - _e79))));
                }
                continuing {
                    let _e31 = y_3;
                    y_3 = (_e31 + 1f);
                }
            }
        }
        continuing {
            let _e21 = x_10;
            x_10 = (_e21 + 1f);
        }
    }
    let _e87 = total_1;
    return vec4<f32>(1f, 1f, 1f, _e87);
}

fn skyWithMoon(uv_14: vec2<f32>, time_4: f32) -> vec4<f32> {
    var uv_15: vec2<f32>;
    var time_5: f32;
    var y_4: f32;
    var lighting_2: mat3x3<f32>;
    var lightAtSun_2: vec3<f32>;
    var lightAtTop_2: vec3<f32>;
    var sunPos_2: vec2<f32>;
    var phaseOffset_2: f32;
    var moonPos_1: vec2<f32>;
    var dMoon: f32;
    var dShadow: f32;
    var dd: f32;
    var kMoonPower_1: f32;
    var moonGlowCol: vec4<f32>;
    var dSun: f32;
    var sunGlowCol: vec4<f32> = vec4<f32>(1f, 1f, 0.8f, 1f);
    var dy_3: f32;
    var baseSky: vec4<f32>;
    var moonPower: f32;
    var sunPower_1: f32;
    var starUv: vec2<f32>;
    var kNight: f32;
    var withMoon: vec4<f32>;
    var withSun: vec4<f32>;

    uv_15 = uv_14;
    time_5 = time_4;
    let _e9 = uv_15;
    y_4 = clamp(((_e9.y * 0.5f) + 0.5f), 0f, 1f);
    let _e19 = time_5;
    let _e20 = getLighting(_e19);
    lighting_2 = _e20;
    let _e24 = lighting_2[0];
    lightAtSun_2 = _e24;
    let _e28 = lighting_2[1];
    lightAtTop_2 = _e28;
    let _e32 = lighting_2[2];
    sunPos_2 = _e32.xy;
    let _e37 = lighting_2[2];
    phaseOffset_2 = _e37.z;
    let _e40 = sunPos_2;
    moonPos_1 = -(_e40);
    let _e43 = uv_15;
    let _e44 = moonPos_1;
    dMoon = (length((_e43 - _e44)) - 0.1f);
    let _e50 = uv_15;
    let _e51 = moonPos_1;
    let _e52 = phaseOffset_2;
    dShadow = (length((_e50 - (_e51 + vec2<f32>(_e52, 0f)))) - 0.1f);
    let _e61 = dMoon;
    let _e62 = dShadow;
    dd = max(_e61, -(_e62));
    let _e66 = dd;
    if (_e66 < 0f) {
        return vec4(1f);
    }
    let _e73 = phaseOffset_2;
    kMoonPower_1 = (1f - min(1f, (abs(_e73) / 0.2f)));
    let _e89 = kMoonPower_1;
    moonGlowCol = (vec4<f32>(0.5f, 0.7f, 1f, 1f) * (1f - (0.8f * _e89)));
    let _e94 = uv_15;
    let _e95 = sunPos_2;
    dSun = (length((_e94 - _e95)) - 0.1f);
    let _e101 = dSun;
    if (_e101 < 0f) {
        return vec4(1f);
    }
    let _e112 = uv_15;
    let _e114 = sunPos_2;
    dy_3 = (_e112.y - _e114.y);
    let _e118 = lightAtSun_2;
    let _e119 = lightAtTop_2;
    let _e120 = dy_3;
    let _e123 = mix(_e118, _e119, vec3(-(_e120)));
    baseSky = vec4<f32>(_e123.x, _e123.y, _e123.z, 1f);
    let _e130 = dMoon;
    if (_e130 < 0f) {
        let _e135 = baseSky;
        let _e136 = moonGlowCol;
        let _e138 = dShadow;
        return mix(vec4(1f), (_e135 + _e136), vec4(clamp((-(_e138) / 0.005f), 0f, 1f)));
    }
    let _e149 = kMoonPower_1;
    moonPower = mix(2f, 12f, _e149);
    let _e160 = sunPos_2;
    sunPower_1 = mix(13f, 3f, smoothstep(-0.525f, -0.75f, _e160.y));
    let _e165 = time_5;
    let _e168 = rotation2_((_e165 * 0.5f));
    let _e169 = uv_15;
    starUv = (((_e168 * (_e169 - vec2<f32>(0f, -0.75f))) + vec2<f32>(0f, -0.75f)) * 50f);
    let _e191 = sunPos_2;
    kNight = smoothstep(-0.2625f, 0.22500001f, _e191.y);
    let _e195 = baseSky;
    let _e196 = starUv;
    let _e197 = starLayer(_e196);
    let _e200 = kNight;
    let _e203 = mergeColor(_e195, (_e197 * vec4<f32>(1f, 1f, 1f, _e200)));
    baseSky = _e203;
    let _e204 = baseSky;
    let _e205 = starUv;
    let _e206 = time_5;
    let _e207 = shootingStarLayer(_e205, _e206);
    let _e208 = kNight;
    let _e210 = mergeColor(_e204, (_e207 * _e208));
    baseSky = _e210;
    let _e211 = baseSky;
    let _e212 = baseSky;
    let _e213 = moonGlowCol;
    let _e215 = dMoon;
    let _e220 = moonPower;
    let _e233 = moonPos_1;
    withMoon = (_e211 + (mix(_e212, _e213, vec4((1f / pow(((_e215 + 1f) * 1f), _e220)))) * smoothstep(-0.15f, -0.375f, _e233.y)));
    let _e239 = withMoon;
    let _e240 = sunGlowCol;
    let _e242 = dSun;
    let _e247 = sunPower_1;
    withSun = mix(_e239, _e240, vec4((1f / pow(((_e242 + 1f) * 1f), _e247))));
    let _e253 = withSun;
    return _e253;
}

fn winterWonderland(uv_16: vec2<f32>, outPos: vec2<f32>, time_6: f32, modelTransform: mat3x3<f32>, treeColor_4: vec4<f32>, treePattern_4: f32, treeTransform_4: mat3x3<f32>, mountainColor_2: vec4<f32>, mountainPattern_2: f32, mountainDetail_2: f32, mountainTransform_2: mat3x3<f32>, hillColor_2: vec4<f32>, hillPattern_2: f32, hillTransform_2: mat3x3<f32>) -> vec4<f32> {
    var uv_17: vec2<f32>;
    var outPos_1: vec2<f32>;
    var time_7: f32;
    var modelTransform_1: mat3x3<f32>;
    var treeColor_5: vec4<f32>;
    var treePattern_5: f32;
    var treeTransform_5: mat3x3<f32>;
    var mountainColor_3: vec4<f32>;
    var mountainPattern_3: f32;
    var mountainDetail_3: f32;
    var mountainTransform_3: mat3x3<f32>;
    var hillColor_3: vec4<f32>;
    var hillPattern_3: f32;
    var hillTransform_3: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var delta_1: vec2<f32>;
    var scaling: f32;
    var col_5: vec4<f32> = vec4(0f);
    var t: f32;
    var lighting_3: mat3x3<f32>;

    uv_17 = uv_16;
    outPos_1 = outPos;
    time_7 = time_6;
    modelTransform_1 = modelTransform;
    treeColor_5 = treeColor_4;
    treePattern_5 = treePattern_4;
    treeTransform_5 = treeTransform_4;
    mountainColor_3 = mountainColor_2;
    mountainPattern_3 = mountainPattern_2;
    mountainDetail_3 = mountainDetail_2;
    mountainTransform_3 = mountainTransform_2;
    hillColor_3 = hillColor_2;
    hillPattern_3 = hillPattern_2;
    hillTransform_3 = hillTransform_2;
    let _e33 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e33);
    let _e37 = inverseModelTransform;
    let _e41 = tf(_e37, vec2<f32>(0f, 0f));
    delta_1 = (2.5f * _e41);
    let _e46 = inverseModelTransform[0];
    scaling = length(_e46.xy);
    let _e53 = time_7;
    t = ((_e53 * 3.1415927f) / 5f);
    let _e59 = t;
    let _e60 = getLighting(_e59);
    lighting_3 = _e60;
    let _e62 = col_5;
    if (_e62.w == 0f) {
        let _e66 = uv_17;
        let _e69 = scaling;
        let _e76 = delta_1;
        let _e80 = hillPattern_3;
        let _e81 = hillColor_3;
        let _e82 = hillTransform_3;
        let _e83 = treePattern_5;
        let _e84 = treeColor_5;
        let _e85 = treeTransform_5;
        let _e86 = hills3_(((((_e66 * 0.5f) * _e69) + vec2<f32>(11f, -0.2f)) + (_e76 * 1f)), _e80, _e81, _e82, _e83, _e84, _e85);
        let _e88 = lighting_3;
        let _e89 = getColorAtLayer2_(_e86, 1f, _e88);
        col_5 = _e89;
    }
    let _e90 = col_5;
    if (_e90.w == 0f) {
        let _e94 = uv_17;
        let _e95 = scaling;
        let _e97 = delta_1;
        let _e101 = hillPattern_3;
        let _e102 = hillColor_3;
        let _e103 = hillTransform_3;
        let _e104 = treePattern_5;
        let _e105 = treeColor_5;
        let _e106 = treeTransform_5;
        let _e107 = hills3_(((_e94 * _e95) + (_e97 * 0.75f)), _e101, _e102, _e103, _e104, _e105, _e106);
        let _e109 = lighting_3;
        let _e110 = getColorAtLayer2_(_e107, 3f, _e109);
        col_5 = _e110;
    }
    let _e111 = col_5;
    if (_e111.w == 0f) {
        let _e115 = uv_17;
        let _e118 = scaling;
        let _e124 = delta_1;
        let _e128 = hillPattern_3;
        let _e129 = hillColor_3;
        let _e130 = hillTransform_3;
        let _e131 = treePattern_5;
        let _e132 = treeColor_5;
        let _e133 = treeTransform_5;
        let _e134 = hills3_(((((_e115 * 1.5f) * _e118) + vec2<f32>(11f, 0.2f)) + (_e124 * 0.5f)), _e128, _e129, _e130, _e131, _e132, _e133);
        let _e136 = lighting_3;
        let _e137 = getColorAtLayer2_(_e134, 5f, _e136);
        col_5 = _e137;
    }
    let _e138 = col_5;
    if (_e138.w == 0f) {
        let _e142 = uv_17;
        let _e143 = scaling;
        let _e145 = delta_1;
        let _e150 = mountainPattern_3;
        let _e151 = mountainDetail_3;
        let _e152 = mountainColor_3;
        let _e153 = mountainTransform_3;
        let _e154 = mountains4_(((_e142 * _e143) + (_e145 * 0.1f)), 2.823f, _e150, _e151, _e152, _e153);
        let _e156 = lighting_3;
        let _e157 = getColorAtLayer2_(_e154, 7f, _e156);
        col_5 = _e157;
    }
    let _e158 = col_5;
    if (_e158.w == 0f) {
        let _e162 = uv_17;
        let _e165 = scaling;
        let _e171 = delta_1;
        let _e176 = mountainPattern_3;
        let _e177 = mountainDetail_3;
        let _e178 = mountainColor_3;
        let _e179 = mountainTransform_3;
        let _e180 = mountains4_(((((_e162 * 1.5f) * _e165) + vec2<f32>(11f, 0.2f)) + (_e171 * 0.075f)), 2.4754f, _e176, _e177, _e178, _e179);
        let _e182 = lighting_3;
        let _e183 = getColorAtLayer2_(_e180, 10f, _e182);
        col_5 = _e183;
    }
    let _e184 = col_5;
    if (_e184.w == 0f) {
        let _e188 = uv_17;
        let _e189 = t;
        let _e190 = skyWithMoon(_e188, _e189);
        col_5 = _e190;
    }
    let _e191 = col_5;
    return _e191;
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
    let _e69 = global.U[6];
    let _e70 = _e69.xyz;
    let _e73 = global.U[7];
    let _e74 = _e73.xyz;
    let _e77 = global.U[8];
    let _e78 = _e77.xyz;
    let _e94 = global.U[9];
    let _e97 = global.U[10];
    let _e101 = global.U[11];
    let _e102 = _e101.xyz;
    let _e105 = global.U[12];
    let _e106 = _e105.xyz;
    let _e109 = global.U[13];
    let _e110 = _e109.xyz;
    let _e126 = global.U[14];
    let _e129 = global.U[15];
    let _e133 = global.U[16];
    let _e137 = global.U[17];
    let _e138 = _e137.xyz;
    let _e141 = global.U[18];
    let _e142 = _e141.xyz;
    let _e145 = global.U[19];
    let _e146 = _e145.xyz;
    let _e162 = global.U[20];
    let _e165 = global.U[21];
    let _e169 = global.U[22];
    let _e170 = _e169.xyz;
    let _e173 = global.U[23];
    let _e174 = _e173.xyz;
    let _e177 = global.U[24];
    let _e178 = _e177.xyz;
    let _e192 = winterWonderland((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), _e65.x, mat3x3<f32>(vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z), vec3<f32>(_e78.x, _e78.y, _e78.z)), _e94, _e97.x, mat3x3<f32>(vec3<f32>(_e102.x, _e102.y, _e102.z), vec3<f32>(_e106.x, _e106.y, _e106.z), vec3<f32>(_e110.x, _e110.y, _e110.z)), _e126, _e129.x, _e133.x, mat3x3<f32>(vec3<f32>(_e138.x, _e138.y, _e138.z), vec3<f32>(_e142.x, _e142.y, _e142.z), vec3<f32>(_e146.x, _e146.y, _e146.z)), _e162, _e165.x, mat3x3<f32>(vec3<f32>(_e170.x, _e170.y, _e170.z), vec3<f32>(_e174.x, _e174.y, _e174.z), vec3<f32>(_e178.x, _e178.y, _e178.z)));
    fragColor = _e192;
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

fn _naga_inverse_2x2_f32(m: mat2x2<f32>) -> mat2x2<f32> {
    var adj: mat2x2<f32>;
    adj[0][0] = m[1][1];
    adj[0][1] = -m[0][1];
    adj[1][0] = -m[1][0];
    adj[1][1] = m[0][0];

    let det: f32 = m[0][0] * m[1][1] - m[1][0] * m[0][1];
    return adj * (1 / det);
}
