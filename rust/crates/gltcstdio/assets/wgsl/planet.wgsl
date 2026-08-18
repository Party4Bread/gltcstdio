struct Params {
    U: array<vec4<f32>, 18>,
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

struct Intersection {
    p: vec3<f32>,
    material: f32,
    diffCol: vec4<f32>,
    minD: f32,
}

struct FragmentOutput {
    @location(0) fragColor: vec4<f32>,
}

const SKY: f32 = 0f;
const WATER: f32 = 10f;
const SHALLOWWATER: f32 = 11f;
const GROUND: f32 = 21f;
const CLOUD: f32 = 22f;
const RINGS: f32 = 50f;

var<private> v_uv_1: vec2<f32>;
var<private> fragColor: vec4<f32>;
@group(0) @binding(0) 
var<uniform> global: Params;
@group(0) @binding(1) 
var samp: sampler;

fn hash33_(u: vec3<f32>) -> vec3<f32> {
    var u_1: vec3<f32>;

    u_1 = u;
    let _e13 = u_1;
    let _e17 = u_1;
    let _e22 = u_1;
    let _e31 = u_1;
    let _e35 = u_1;
    let _e40 = u_1;
    let _e49 = u_1;
    let _e53 = u_1;
    let _e58 = u_1;
    return vec3<f32>(fract((sin((((_e13.x * 776.45f) + (_e17.y * 453.24f)) + (_e22.z * 553.25f))) * 45.77f)), fract((sin((((_e31.x * 376.45f) + (_e35.y * 853.24f)) + (_e40.z * 153.84f))) * 88.77f)), fract((sin((((_e49.x * 457.77f) + (_e53.y * 667.17f)) + (_e58.z * 355.94f))) * 65.57f)));
}

fn rotX(ang: f32) -> mat4x4<f32> {
    var ang_1: f32;

    ang_1 = ang;
    let _e18 = ang_1;
    let _e20 = ang_1;
    let _e24 = ang_1;
    let _e26 = ang_1;
    return mat4x4<f32>(vec4<f32>(1f, 0f, 0f, 0f), vec4<f32>(0f, cos(_e18), sin(_e20), 0f), vec4<f32>(0f, sin(_e24), -(cos(_e26)), 0f), vec4<f32>(0f, 0f, 0f, 1f));
}

fn rotZ(ang_2: f32) -> mat4x4<f32> {
    var ang_3: f32;

    ang_3 = ang_2;
    let _e13 = ang_3;
    let _e15 = ang_3;
    let _e19 = ang_3;
    let _e21 = ang_3;
    return mat4x4<f32>(vec4<f32>(cos(_e13), sin(_e15), 0f, 0f), vec4<f32>(sin(_e19), -(cos(_e21)), 0f, 0f), vec4<f32>(0f, 0f, 1f, 0f), vec4<f32>(0f, 0f, 0f, 1f));
}

fn sdSegment3_(u_2: vec3<f32>, a: vec3<f32>, b: vec3<f32>) -> f32 {
    var u_3: vec3<f32>;
    var a_1: vec3<f32>;
    var b_1: vec3<f32>;
    var ua: vec3<f32>;
    var ba: vec3<f32>;
    var h: f32;

    u_3 = u_2;
    a_1 = a;
    b_1 = b;
    let _e17 = u_3;
    let _e18 = a_1;
    ua = (_e17 - _e18);
    let _e21 = b_1;
    let _e22 = a_1;
    ba = (_e21 - _e22);
    let _e25 = ua;
    let _e26 = ba;
    let _e28 = ba;
    let _e29 = ba;
    h = clamp((dot(_e25, _e26) / dot(_e28, _e29)), 0f, 1f);
    let _e36 = ua;
    let _e37 = ba;
    let _e38 = h;
    return length((_e36 - (_e37 * _e38)));
}

fn clouds3_(p: vec3<f32>) -> vec2<f32> {
    var p_1: vec3<f32>;
    var N: i32 = 6i;
    var d: f32 = 1000000f;
    var i: i32 = 0i;
    var rnd: vec3<f32>;
    var t: mat4x4<f32>;
    var q: vec3<f32>;
    var l1_: f32;
    var a1_: f32;
    var delta: f32;
    var l2_: f32;
    var d2_: f32;

    p_1 = p;
    loop {
        let _e19 = i;
        let _e20 = N;
        if !((_e19 < _e20)) {
            break;
        }
        {
            let _e26 = i;
            let _e31 = hash33_(vec3(f32((_e26 - 13i))));
            rnd = _e31;
            let _e33 = rnd;
            let _e39 = rotX(((_e33.y - 0.5f) * 2f));
            let _e40 = rnd;
            let _e44 = rotZ((_e40.x * 6.28f));
            t = (_e39 * _e44);
            let _e47 = t;
            let _e48 = p_1;
            q = (_e47 * vec4<f32>(_e48.x, _e48.y, _e48.z, 1f)).xyz;
            let _e58 = rnd;
            l1_ = (0.05f + (_e58.y * 0.05f));
            let _e66 = rnd;
            a1_ = (1.02f + (0.05f * floor((_e66.z * 3f))));
            let _e74 = rnd;
            let _e80 = l1_;
            delta = ((pow(_e74.x, 0.2f) * 2f) * _e80);
            let _e84 = rnd;
            l2_ = (0.05f + (_e84.z * 0.05f));
            let _e90 = q;
            let _e91 = l1_;
            let _e93 = a1_;
            let _e96 = l1_;
            let _e97 = a1_;
            let _e100 = sdSegment3_(_e90, vec3<f32>(-(_e91), _e93, 0f), vec3<f32>(_e96, _e97, 0f));
            d2_ = _e100;
            let _e102 = d2_;
            let _e103 = q;
            let _e104 = delta;
            let _e105 = l2_;
            let _e107 = a1_;
            let _e108 = l1_;
            let _e112 = delta;
            let _e113 = l2_;
            let _e115 = a1_;
            let _e116 = l1_;
            let _e120 = sdSegment3_(_e103, vec3<f32>((_e104 - _e105), _e107, (_e108 * 0.9f)), vec3<f32>((_e112 + _e113), _e115, (_e116 * 0.9f)));
            d2_ = min(_e102, _e120);
            let _e122 = d2_;
            d2_ = (_e122 - 0.1f);
            let _e125 = d2_;
            let _e126 = q;
            let _e128 = a1_;
            d2_ = max(_e125, (abs((length(_e126) - _e128)) - 0f));
            let _e134 = d;
            let _e135 = d2_;
            d = min(_e134, _e135);
        }
        continuing {
            let _e23 = i;
            i = (_e23 + 1i);
        }
    }
    let _e137 = d;
    d = (_e137 - 0.01f);
    let _e140 = d;
    return vec2<f32>(_e140, CLOUD);
}

fn minMat(a_2: vec2<f32>, b_2: vec2<f32>) -> vec2<f32> {
    var a_3: vec2<f32>;
    var b_3: vec2<f32>;
    var local: vec2<f32>;

    a_3 = a_2;
    b_3 = b_2;
    let _e15 = a_3;
    let _e17 = b_3;
    if (_e15.x < _e17.x) {
        let _e20 = a_3;
        local = _e20;
    } else {
        let _e21 = b_3;
        local = _e21;
    }
    let _e23 = local;
    return _e23;
}

fn minMat3_(a_4: vec2<f32>, b_4: vec2<f32>, c: vec2<f32>) -> vec2<f32> {
    var a_5: vec2<f32>;
    var b_5: vec2<f32>;
    var c_1: vec2<f32>;

    a_5 = a_4;
    b_5 = b_4;
    c_1 = c;
    let _e17 = a_5;
    let _e18 = b_5;
    let _e19 = c_1;
    let _e20 = minMat(_e18, _e19);
    let _e21 = minMat(_e17, _e20);
    return _e21;
}

fn noclouds(p_2: vec3<f32>) -> vec2<f32> {
    var p_3: vec3<f32>;

    p_3 = p_2;
    return vec2<f32>(10000f, 22f);
}

fn rndUnit3_(p_4: vec3<f32>) -> vec3<f32> {
    var p_5: vec3<f32>;
    var u_4: vec3<f32>;
    var h_1: vec3<f32>;

    p_5 = p_4;
    let _e13 = p_5;
    u_4 = fract((_e13 * vec3<f32>(0.1031f, 0.103f, 0.0973f)));
    let _e21 = u_4;
    let _e22 = u_4;
    let _e23 = u_4;
    u_4 = (_e21 + vec3(dot(_e22, (_e23.yxz + vec3(33.33f)))));
    let _e31 = u_4;
    let _e33 = u_4;
    let _e36 = u_4;
    h_1 = fract(((_e31.xxy + _e33.yxx) * _e36.zyx));
    let _e41 = h_1;
    return normalize((_e41 - vec3(0.5f)));
}

fn dotGridGradient3_(g: vec3<f32>, u_5: vec3<f32>) -> f32 {
    var g_1: vec3<f32>;
    var u_6: vec3<f32>;

    g_1 = g;
    u_6 = u_5;
    let _e15 = u_6;
    let _e16 = g_1;
    let _e18 = g_1;
    let _e19 = rndUnit3_(_e18);
    return dot((_e15 - _e16), _e19);
}

fn smix(a_6: f32, b_6: f32, k: f32) -> f32 {
    var a_7: f32;
    var b_7: f32;
    var k_1: f32;

    a_7 = a_6;
    b_7 = b_6;
    k_1 = k;
    let _e17 = a_7;
    let _e18 = b_7;
    let _e21 = k_1;
    return mix(_e17, _e18, smoothstep(0f, 1f, _e21));
}

fn perlinRelNoise3_(p_6: vec3<f32>) -> f32 {
    var p_7: vec3<f32>;
    var s: vec3<f32> = vec3<f32>(1f, 0f, 0f);
    var f: vec3<f32>;
    var d_1: vec3<f32>;
    var ix00_: f32;
    var ix10_: f32;
    var ix01_: f32;
    var ix11_: f32;
    var iy0_: f32;
    var iy1_: f32;

    p_7 = p_6;
    let _e18 = p_7;
    f = floor(_e18);
    let _e21 = p_7;
    let _e22 = f;
    d_1 = (_e21 - _e22);
    let _e25 = f;
    let _e26 = p_7;
    let _e27 = dotGridGradient3_(_e25, _e26);
    let _e28 = f;
    let _e29 = s;
    let _e31 = p_7;
    let _e32 = dotGridGradient3_((_e28 + _e29), _e31);
    let _e33 = d_1;
    let _e35 = smix(_e27, _e32, _e33.x);
    ix00_ = _e35;
    let _e37 = f;
    let _e38 = s;
    let _e41 = p_7;
    let _e42 = dotGridGradient3_((_e37 + _e38.yxz), _e41);
    let _e43 = f;
    let _e44 = s;
    let _e47 = p_7;
    let _e48 = dotGridGradient3_((_e43 + _e44.xxz), _e47);
    let _e49 = d_1;
    let _e51 = smix(_e42, _e48, _e49.x);
    ix10_ = _e51;
    let _e53 = f;
    let _e54 = s;
    let _e57 = p_7;
    let _e58 = dotGridGradient3_((_e53 + _e54.yyx), _e57);
    let _e59 = f;
    let _e60 = s;
    let _e63 = p_7;
    let _e64 = dotGridGradient3_((_e59 + _e60.xyx), _e63);
    let _e65 = d_1;
    let _e67 = smix(_e58, _e64, _e65.x);
    ix01_ = _e67;
    let _e69 = f;
    let _e70 = s;
    let _e73 = p_7;
    let _e74 = dotGridGradient3_((_e69 + _e70.yxx), _e73);
    let _e75 = f;
    let _e76 = s;
    let _e79 = p_7;
    let _e80 = dotGridGradient3_((_e75 + _e76.xxx), _e79);
    let _e81 = d_1;
    let _e83 = smix(_e74, _e80, _e81.x);
    ix11_ = _e83;
    let _e85 = ix00_;
    let _e86 = ix10_;
    let _e87 = d_1;
    let _e89 = smix(_e85, _e86, _e87.y);
    iy0_ = _e89;
    let _e91 = ix01_;
    let _e92 = ix11_;
    let _e93 = d_1;
    let _e95 = smix(_e91, _e92, _e93.y);
    iy1_ = _e95;
    let _e97 = iy0_;
    let _e98 = iy1_;
    let _e99 = d_1;
    let _e101 = smix(_e97, _e98, _e99.z);
    return _e101;
}

fn planet2_(p_8: vec3<f32>) -> vec2<f32> {
    var p_9: vec3<f32>;
    var lp: f32;
    var main1_: f32;
    var main2_: f32;
    var main_1: f32;
    var q_1: vec3<f32>;

    p_9 = p_8;
    let _e13 = p_9;
    lp = length(_e13);
    let _e16 = lp;
    let _e23 = lp;
    if ((_e16 > 1.35f) || (_e23 < 1f)) {
        let _e27 = lp;
        return vec2<f32>((length(_e27) - 1f), WATER);
    }
    let _e33 = p_9;
    let _e36 = perlinRelNoise3_((_e33 * 1.56f));
    let _e39 = p_9;
    let _e42 = perlinRelNoise3_((_e39 * 4.79f));
    let _e46 = p_9;
    let _e49 = perlinRelNoise3_((_e46 * 10.3f));
    main1_ = (((0.05f + _e36) + (0.5f * _e42)) + (0.25f * _e49));
    let _e53 = main1_;
    let _e55 = p_9;
    let _e58 = perlinRelNoise3_((_e55 * 21f));
    main2_ = (_e53 + (0.125f * _e58));
    let _e62 = main2_;
    main_1 = _e62;
    let _e64 = p_9;
    let _e67 = main_1;
    q_1 = (_e64 * (1f + (0.175f * _e67)));
    let _e72 = q_1;
    let _e77 = lp;
    let _e81 = main1_;
    let _e87 = minMat(vec2<f32>((length(_e72) - 1f), GROUND), vec2<f32>((length(_e77) - 1f), (WATER + clamp(_e81, 0f, 1f))));
    return _e87;
}

fn rings(p_10: vec3<f32>) -> vec2<f32> {
    var p_11: vec3<f32>;
    var thickness: f32 = 0.008f;
    var width: f32 = 0.2f;
    var R: f32 = 1.8f;
    var r: f32;
    var a_8: f32;
    var q_2: vec2<f32>;
    var c1_: vec2<f32>;

    p_11 = p_10;
    let _e19 = thickness;
    r = _e19;
    let _e21 = p_11;
    let _e23 = p_11;
    let _e26 = p_11;
    let _e28 = p_11;
    let _e33 = R;
    a_8 = abs((sqrt(((_e21.x * _e23.x) + (_e26.y * _e28.y))) - _e33));
    let _e37 = a_8;
    let _e38 = p_11;
    q_2 = vec2<f32>(_e37, _e38.z);
    let _e42 = a_8;
    let _e43 = width;
    c1_ = vec2<f32>(min(_e42, _e43), 0f);
    let _e48 = q_2;
    let _e49 = c1_;
    let _e52 = r;
    return vec2<f32>((length((_e48 - _e49)) - _e52), RINGS);
}

fn sdf(p_12: vec3<f32>) -> vec2<f32> {
    var p_13: vec3<f32>;

    p_13 = p_12;
    let _e13 = p_13;
    let _e14 = planet2_(_e13);
    let _e15 = p_13;
    let _e16 = rings(_e15);
    let _e17 = p_13;
    let _e18 = noclouds(_e17);
    let _e19 = minMat3_(_e14, _e16, _e18);
    return _e19;
}

fn getNormal(p_14: vec3<f32>) -> vec3<f32> {
    var p_15: vec3<f32>;
    var d_2: f32 = 0.0001f;
    var d2_1: f32;

    p_15 = p_14;
    let _e15 = d_2;
    d2_1 = (_e15 * 2f);
    let _e19 = p_15;
    let _e21 = d_2;
    let _e23 = p_15;
    let _e25 = p_15;
    let _e28 = sdf(vec3<f32>((_e19.x - _e21), _e23.y, _e25.z));
    let _e30 = p_15;
    let _e32 = d_2;
    let _e34 = p_15;
    let _e36 = p_15;
    let _e39 = sdf(vec3<f32>((_e30.x + _e32), _e34.y, _e36.z));
    let _e42 = d2_1;
    let _e44 = p_15;
    let _e46 = p_15;
    let _e48 = d_2;
    let _e50 = p_15;
    let _e53 = sdf(vec3<f32>(_e44.x, (_e46.y - _e48), _e50.z));
    let _e55 = p_15;
    let _e57 = p_15;
    let _e59 = d_2;
    let _e61 = p_15;
    let _e64 = sdf(vec3<f32>(_e55.x, (_e57.y + _e59), _e61.z));
    let _e67 = d2_1;
    let _e69 = p_15;
    let _e71 = p_15;
    let _e73 = p_15;
    let _e75 = d_2;
    let _e78 = sdf(vec3<f32>(_e69.x, _e71.y, (_e73.z - _e75)));
    let _e80 = p_15;
    let _e82 = p_15;
    let _e84 = p_15;
    let _e86 = d_2;
    let _e89 = sdf(vec3<f32>(_e80.x, _e82.y, (_e84.z + _e86)));
    let _e92 = d2_1;
    return normalize(vec3<f32>(((_e28.x - _e39.x) / _e42), ((_e53.x - _e64.x) / _e67), ((_e78.x - _e89.x) / _e92)));
}

fn getRay(uv: vec2<f32>, camera: vec3<f32>, target_: vec3<f32>, focalDist: f32) -> vec3<f32> {
    var uv_1: vec2<f32>;
    var camera_1: vec3<f32>;
    var target_1: vec3<f32>;
    var focalDist_1: f32;
    var camZ: vec3<f32>;
    var camX: vec3<f32>;
    var camY: vec3<f32>;

    uv_1 = uv;
    camera_1 = camera;
    target_1 = target_;
    focalDist_1 = focalDist;
    let _e19 = target_1;
    let _e20 = camera_1;
    camZ = normalize((_e19 - _e20));
    let _e28 = camZ;
    camX = normalize(cross(vec3<f32>(0f, 1f, 0f), _e28));
    let _e32 = camZ;
    let _e33 = camX;
    camY = cross(_e32, _e33);
    let _e36 = camZ;
    let _e37 = focalDist_1;
    let _e39 = uv_1;
    let _e41 = camX;
    let _e44 = uv_1;
    let _e46 = camY;
    return normalize((((_e36 * _e37) + (_e39.x * _e41)) + (_e44.y * _e46)));
}

fn isWater(material: f32) -> bool {
    var material_1: f32;

    material_1 = material;
    let _e13 = material_1;
    let _e15 = material_1;
    return ((_e13 >= WATER) && (_e15 <= SHALLOWWATER));
}

fn getSpecular(material_2: f32, camDir: vec3<f32>, normal: vec3<f32>, lightDir: vec3<f32>) -> f32 {
    var material_3: f32;
    var camDir_1: vec3<f32>;
    var normal_1: vec3<f32>;
    var lightDir_1: vec3<f32>;
    var ref_: vec3<f32>;
    var k_2: f32 = 0f;

    material_3 = material_2;
    camDir_1 = camDir;
    normal_1 = normal;
    lightDir_1 = lightDir;
    let _e19 = lightDir_1;
    let _e20 = normal_1;
    ref_ = reflect(_e19, _e20);
    let _e25 = material_3;
    let _e26 = isWater(_e25);
    if _e26 {
        k_2 = 0.9f;
    } else {
        let _e28 = material_3;
        if (_e28 == GROUND) {
            k_2 = 0.1f;
        } else {
            let _e31 = material_3;
            if (_e31 == RINGS) {
                k_2 = 0.5f;
            }
        }
    }
    let _e35 = ref_;
    let _e36 = camDir_1;
    let _e41 = k_2;
    return (pow(max(0f, dot(_e35, _e36)), 9f) * _e41);
}

fn groundColor(p_16: vec3<f32>) -> vec3<f32> {
    var p_17: vec3<f32>;
    var col: vec3<f32>;
    var d_3: f32;
    var pole: f32;

    p_17 = p_16;
    let _e23 = p_17;
    let _e26 = perlinRelNoise3_((_e23 * 5.22f));
    col = mix(vec3<f32>(0.15f, 0.5f, 0.15f), vec3<f32>(0.55f, 0.44f, 0.39f), vec3(smoothstep(0.05f, 0.35f, _e26)));
    let _e31 = p_17;
    d_3 = ((length(_e31) - 1f) / 0.175f);
    let _e38 = d_3;
    if (_e38 < 0.1f) {
        let _e45 = col;
        let _e48 = d_3;
        col = mix(vec3<f32>(0.9f, 0.8f, 0.35f), _e45, vec3(smoothstep(0.05f, 0.06f, _e48)));
    } else {
        let _e52 = d_3;
        if (_e52 > 0.1f) {
            let _e55 = col;
            let _e60 = d_3;
            col = mix(_e55, vec3(1f), vec3(smoothstep(0.45f, 0.5f, _e60)));
        }
    }
    let _e66 = p_17;
    pole = smoothstep(0.8f, 0.9f, abs(_e66.z));
    let _e71 = col;
    let _e74 = pole;
    col = mix(_e71, vec3(1f), vec3(_e74));
    let _e77 = col;
    return _e77;
}

fn perlinNoise3_(p_18: vec3<f32>) -> f32 {
    var p_19: vec3<f32>;

    p_19 = p_18;
    let _e14 = p_19;
    let _e15 = perlinRelNoise3_(_e14);
    return (0.5f + (_e15 * 0.5f));
}

fn getCloudDensity(p_20: vec3<f32>) -> f32 {
    var p_21: vec3<f32>;
    var d_4: f32;

    p_21 = p_20;
    let _e13 = p_21;
    d_4 = length(_e13);
    let _e18 = d_4;
    let _e25 = p_21;
    let _e31 = p_21;
    let _e36 = perlinNoise3_(((_e25 * vec3<f32>(1.5f, 1.5f, 3f)) * pow(length(_e31), 3f)));
    return (smoothstep(0.1f, 0.05f, abs((_e18 - 1.05f))) * smoothstep(0.5f, 0.7f, _e36));
}

fn getDiffusion2_(diffCol: vec4<f32>, p_22: vec3<f32>, dist: f32, lightDir_2: vec3<f32>) -> vec4<f32> {
    var diffCol_1: vec4<f32>;
    var p_23: vec3<f32>;
    var dist_1: f32;
    var lightDir_3: vec3<f32>;
    var c_2: f32;
    var illum: f32;
    var cloud: f32;
    var base: vec3<f32>;
    var col_1: vec4<f32>;

    diffCol_1 = diffCol;
    p_23 = p_22;
    dist_1 = dist;
    lightDir_3 = lightDir_2;
    let _e22 = p_23;
    c_2 = (1.5f * smoothstep(1.5f, 1.08f, length(_e22)));
    let _e29 = p_23;
    let _e30 = lightDir_3;
    illum = pow(max(0f, (0.35f + dot(_e29, _e30))), 0.35f);
    let _e37 = p_23;
    let _e38 = getCloudDensity(_e37);
    cloud = _e38;
    let _e44 = illum;
    let _e46 = illum;
    let _e52 = cloud;
    base = mix((vec3<f32>(0.2f, 0.75f, 1.5f) * _e44), vec3(((_e46 * 0.8f) + 0.2f)), vec3(_e52));
    let _e56 = c_2;
    let _e58 = cloud;
    c_2 = mix(_e56, 25f, _e58);
    let _e60 = base;
    let _e61 = c_2;
    let _e62 = dist_1;
    let _e66 = illum;
    col_1 = vec4<f32>(_e60.x, _e60.y, _e60.z, min(((_e61 * _e62) * (0.5f + (0.5f * _e66))), 1f));
    let _e77 = diffCol_1;
    let _e79 = col_1;
    let _e81 = col_1;
    let _e84 = mix(_e77.xyz, _e79.xyz, vec3(_e81.w));
    let _e85 = diffCol_1;
    let _e88 = col_1;
    return vec4<f32>(_e84.x, _e84.y, _e84.z, mix(_e85.w, 1f, _e88.w));
}

fn rayMarch(p0_: vec3<f32>, dir: vec3<f32>, lightDir_4: vec3<f32>) -> Intersection {
    var p0_1: vec3<f32>;
    var dir_1: vec3<f32>;
    var lightDir_5: vec3<f32>;
    var d_5: vec2<f32>;
    var s_1: f32;
    var totalD: f32 = 0f;
    var step: i32 = 0i;
    var diffCol_2: vec4<f32> = vec4(0f);
    var minD: f32 = 1000000000f;
    var stepD: f32;
    var p_24: vec3<f32>;

    p0_1 = p0_;
    dir_1 = dir;
    lightDir_5 = lightDir_4;
    let _e17 = p0_1;
    let _e18 = sdf(_e17);
    d_5 = _e18;
    let _e20 = d_5;
    s_1 = sign(_e20.x);
    loop {
        let _e33 = step;
        let _e36 = d_5;
        if !(((_e33 < 1000i) && (_e36.x < 100f))) {
            break;
        }
        {
            let _e42 = d_5;
            stepD = (_e42.x * 0.85f);
            let _e47 = totalD;
            let _e48 = stepD;
            totalD = (_e47 + _e48);
            let _e50 = p0_1;
            let _e51 = totalD;
            let _e52 = dir_1;
            p_24 = (_e50 + (_e51 * _e52));
            let _e56 = p_24;
            let _e57 = sdf(_e56);
            d_5 = _e57;
            let _e58 = d_5;
            let _e60 = totalD;
            let _e62 = minD;
            minD = min((_e58.x / _e60), _e62);
            let _e64 = diffCol_2;
            let _e65 = p_24;
            let _e66 = stepD;
            let _e67 = lightDir_5;
            let _e68 = getDiffusion2_(_e64, _e65, _e66, _e67);
            diffCol_2 = _e68;
            let _e69 = diffCol_2;
            if (_e69.w > 0.95f) {
                let _e73 = p_24;
                let _e74 = d_5;
                let _e76 = diffCol_2;
                let _e77 = minD;
                return Intersection(_e73, _e74.y, _e76, _e77);
            }
            let _e79 = d_5;
            if (abs(_e79.x) < 0.0001f) {
                let _e84 = p_24;
                let _e85 = d_5;
                let _e87 = diffCol_2;
                let _e88 = minD;
                return Intersection(_e84, _e85.y, _e87, _e88);
            }
            let _e90 = step;
            step = (_e90 + 1i);
        }
    }
    let _e95 = diffCol_2;
    let _e96 = minD;
    return Intersection(vec3(100000000000000000000f), SKY, _e95, _e96);
}

fn ringsColor(p_25: vec3<f32>) -> vec3<f32> {
    var p_26: vec3<f32>;
    var d_6: f32;
    var col_2: vec3<f32>;

    p_26 = p_25;
    let _e13 = p_26;
    d_6 = length(_e13);
    let _e22 = d_6;
    let _e25 = d_6;
    col_2 = (vec3<f32>(0.5f, 0.6f, 0.7f) * (1.5f + (0.3f * pow(sin(((_e22 * 5f) + sin((_e25 * 40f)))), 3f))));
    let _e37 = col_2;
    return _e37;
}

fn planet(uv_2: vec2<f32>, outPos: vec2<f32>, model3DTransform: mat4x4<f32>, lightSourceTransform: mat4x4<f32>, camera3DTransform: mat4x4<f32>) -> vec4<f32> {
    var uv_3: vec2<f32>;
    var outPos_1: vec2<f32>;
    var model3DTransform_1: mat4x4<f32>;
    var lightSourceTransform_1: mat4x4<f32>;
    var camera3DTransform_1: mat4x4<f32>;
    var D: f32 = 0.5f;
    var camera_2: vec3<f32> = vec3<f32>(0f, 0f, 0f);
    var target_2: vec3<f32> = vec3(0f);
    var camDir_2: vec3<f32>;
    var invModelTransform: mat4x4<f32>;
    var model3DTransform3_: mat3x3<f32>;
    var dir_2: vec3<f32>;
    var lightPos: vec3<f32>;
    var lightDir_6: vec3<f32>;
    var p_27: vec3<f32>;
    var col_3: vec3<f32> = vec3(0f);
    var intersection: Intersection;
    var q_3: vec3<f32>;
    var material_4: f32;
    var normal_2: vec3<f32>;
    var illum_1: f32;
    var start: vec3<f32>;
    var intersection_1: Intersection;
    var diffCol_3: vec4<f32>;
    var spec: f32;

    uv_3 = uv_2;
    outPos_1 = outPos;
    model3DTransform_1 = model3DTransform;
    lightSourceTransform_1 = lightSourceTransform;
    camera3DTransform_1 = camera3DTransform;
    let _e28 = camera3DTransform_1;
    let _e29 = camera_2;
    camera_2 = (_e28 * vec4<f32>(_e29.x, _e29.y, _e29.z, 1f)).xyz;
    let _e40 = uv_3;
    let _e41 = camera_2;
    let _e42 = target_2;
    let _e44 = getRay(_e40, _e41, _e42, 1f);
    camDir_2 = _e44;
    let _e46 = model3DTransform_1;
    invModelTransform = _naga_inverse_4x4_f32(_e46);
    let _e49 = model3DTransform_1;
    model3DTransform3_ = mat3x3<f32>(_e49[0].xyz, _e49[1].xyz, _e49[2].xyz);
    let _e60 = invModelTransform;
    let _e61 = camera_2;
    camera_2 = (_e60 * vec4<f32>(_e61.x, _e61.y, _e61.z, 1f)).xyz;
    let _e69 = uv_3;
    let _e71 = D;
    let _e73 = uv_3;
    let _e75 = D;
    dir_2 = normalize(vec3<f32>((_e69.x * _e71), (_e73.y * _e75), -1f));
    let _e82 = camera3DTransform_1;
    let _e92 = dir_2;
    dir_2 = (mat3x3<f32>(_e82[0].xyz, _e82[1].xyz, _e82[2].xyz) * _e92);
    let _e94 = invModelTransform;
    let _e104 = dir_2;
    camDir_2 = normalize((mat3x3<f32>(_e94[0].xyz, _e94[1].xyz, _e94[2].xyz) * _e104));
    let _e107 = lightSourceTransform_1;
    lightPos = (_e107 * vec4<f32>(0f, 0f, 0f, 1f)).xyz;
    let _e116 = lightPos;
    lightDir_6 = -(_e116);
    let _e119 = camera_2;
    p_27 = _e119;
    let _e124 = p_27;
    let _e125 = camDir_2;
    let _e126 = lightDir_6;
    let _e127 = rayMarch(_e124, _e125, _e126);
    intersection = _e127;
    let _e129 = intersection;
    q_3 = _e129.p;
    let _e132 = intersection;
    material_4 = _e132.material;
    let _e135 = q_3;
    let _e136 = getNormal(_e135);
    normal_2 = _e136;
    let _e138 = material_4;
    if (_e138 == SKY) {
        col_3 = vec3<f32>(0.1f, 0.2f, 0.3f);
    } else {
        let _e144 = material_4;
        let _e145 = isWater(_e144);
        if _e145 {
            let _e156 = material_4;
            col_3 = mix(vec3<f32>(0.2f, 0.75f, 1f), vec3<f32>(0.1f, 0.2f, 0.8f), vec3(smoothstep(0.05f, 0.4f, (_e156 - WATER))));
        } else {
            let _e161 = material_4;
            if (_e161 == GROUND) {
                let _e163 = q_3;
                let _e164 = groundColor(_e163);
                col_3 = _e164;
            } else {
                let _e165 = material_4;
                if (_e165 == RINGS) {
                    let _e167 = q_3;
                    let _e168 = ringsColor(_e167);
                    col_3 = _e168;
                } else {
                    let _e169 = material_4;
                    if (_e169 == CLOUD) {
                        col_3 = vec3(1f);
                    } else {
                        let _e173 = q_3;
                        if (_e173.x != 100000000000000000000f) {
                            let _e177 = normal_2;
                            col_3 = ((_e177 * 0.5f) + vec3(0.5f));
                        }
                    }
                }
            }
        }
    }
    let _e184 = normal_2;
    let _e185 = lightDir_6;
    illum_1 = max(0f, dot(_e184, -(_e185)));
    let _e190 = q_3;
    if (_e190.x != 100000000000000000000f) {
        {
            let _e194 = q_3;
            let _e195 = camDir_2;
            start = (_e194 - (_e195 * 0.0005f));
            let _e200 = start;
            let _e201 = lightDir_6;
            let _e202 = lightDir_6;
            let _e203 = rayMarch(_e200, _e201, _e202);
            intersection_1 = _e203;
            let _e205 = intersection_1;
            if (_e205.p.x != 100000000000000000000f) {
                illum_1 = 0f;
            } else {
                let _e211 = illum_1;
                let _e212 = intersection_1;
                illum_1 = (_e211 * clamp((_e212.minD * 25f), 0f, 1f));
            }
        }
    }
    let _e220 = col_3;
    let _e223 = illum_1;
    col_3 = (_e220 * (0.15f + (1f * _e223)));
    let _e227 = intersection;
    diffCol_3 = _e227.diffCol;
    let _e230 = col_3;
    let _e232 = diffCol_3;
    let _e234 = diffCol_3;
    col_3 = mix(_e230.xyz, _e232.xyz, vec3(_e234.w));
    let _e238 = material_4;
    let _e239 = camDir_2;
    let _e240 = normal_2;
    let _e241 = lightDir_6;
    let _e242 = getSpecular(_e238, _e239, _e240, _e241);
    spec = _e242;
    let _e244 = col_3;
    let _e245 = spec;
    col_3 = (_e244 + vec3(_e245));
    let _e248 = col_3;
    return vec4<f32>(_e248.x, _e248.y, _e248.z, 1f);
}

fn main_2() {
    let _e13 = global.U[1];
    let _e14 = _e13.xyz;
    let _e17 = global.U[2];
    let _e18 = _e17.xyz;
    let _e21 = global.U[3];
    let _e22 = _e21.xyz;
    let _e37 = v_uv_1;
    let _e45 = global.U[0];
    let _e49 = (((_e37 - vec2(0.5f)) * 2f) * vec2<f32>(_e45.x, 1f));
    let _e56 = v_uv_1;
    let _e64 = global.U[0];
    let _e71 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e80 = global.U[9];
    let _e104 = global.U[10];
    let _e107 = global.U[11];
    let _e110 = global.U[12];
    let _e113 = global.U[13];
    let _e137 = global.U[14];
    let _e140 = global.U[15];
    let _e143 = global.U[16];
    let _e146 = global.U[17];
    let _e168 = planet((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z), vec3<f32>(_e22.x, _e22.y, _e22.z))) * vec3<f32>(_e49.x, _e49.y, 1f)).xy, (((_e56 - vec2(0.5f)) * 2f) * vec2<f32>(_e64.x, 1f)), mat4x4<f32>(vec4<f32>(_e71.x, _e71.y, _e71.z, _e71.w), vec4<f32>(_e74.x, _e74.y, _e74.z, _e74.w), vec4<f32>(_e77.x, _e77.y, _e77.z, _e77.w), vec4<f32>(_e80.x, _e80.y, _e80.z, _e80.w)), mat4x4<f32>(vec4<f32>(_e104.x, _e104.y, _e104.z, _e104.w), vec4<f32>(_e107.x, _e107.y, _e107.z, _e107.w), vec4<f32>(_e110.x, _e110.y, _e110.z, _e110.w), vec4<f32>(_e113.x, _e113.y, _e113.z, _e113.w)), mat4x4<f32>(vec4<f32>(_e137.x, _e137.y, _e137.z, _e137.w), vec4<f32>(_e140.x, _e140.y, _e140.z, _e140.w), vec4<f32>(_e143.x, _e143.y, _e143.z, _e143.w), vec4<f32>(_e146.x, _e146.y, _e146.z, _e146.w)));
    fragColor = _e168;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_2();
    let _e23 = fragColor;
    return FragmentOutput(_e23);
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
