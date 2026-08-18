struct Params {
    U: array<vec4<f32>, 42>,
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

struct LevelParams {
    transform: mat3x3<f32>,
    inverseTransform: mat3x3<f32>,
    startScale: f32,
    subLevels: f32,
    subThreshold: f32,
    modeMap: array<i32, 4>,
    coverage: f32,
    streakInterpolateCoverage: f32,
    streakSubLevels: i32,
    streakVerticality: f32,
    seed: f32,
    hashStyle: f32,
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

fn hash22_(u: vec2<f32>) -> vec2<f32> {
    var u_1: vec2<f32>;

    u_1 = u;
    let _e8 = u_1;
    let _e12 = u_1;
    let _e21 = u_1;
    let _e25 = u_1;
    return vec2<f32>(fract((sin(((_e8.x * 776.45f) + (_e12.y * 453.24f))) * 45.77f)), fract((sin(((_e21.x * 376.45f) + (_e25.y * 853.24f))) * 88.77f)));
}

fn hash42sp(u_2: vec4<f32>, hashStyle: f32) -> vec2<f32> {
    var u_3: vec4<f32>;
    var hashStyle_1: f32;
    var r1_: vec2<f32>;
    var r2_: vec2<f32>;
    var v: vec2<f32>;
    var t: f32;
    var r3_: vec2<f32>;
    var r4_: vec2<f32>;
    var p: f32 = 10f;
    var k1_: f32;
    var k2_: f32;
    var k3_: f32;
    var k4_: f32;
    var kTotal: f32;

    u_3 = u_2;
    hashStyle_1 = hashStyle;
    let _e12 = u_3;
    let _e14 = u_3;
    let _e17 = u_3;
    let _e21 = u_3;
    let _e23 = u_3;
    r1_ = (vec2(0.5f) + (0.5f * sin((vec2((_e12.z + _e14.w)) + ((_e17.yx * 55f) * sin((vec2(_e21.w) + (_e23.xy * 15.88f))))))));
    let _e38 = u_3;
    let _e40 = u_3;
    let _e45 = u_3;
    r2_ = fract((((_e38.xy * _e40.yz) * 11.689f) + _e45.yw));
    let _e50 = u_3;
    let _e54 = u_3;
    v = abs((fract(((_e50.xy * 101f) + _e54.zw)) - vec2(0.5f)));
    let _e63 = v;
    let _e65 = v;
    let _e70 = u_3;
    let _e72 = u_3;
    t = (max(_e63.x, _e65.y) * (2f + (10f * sin((_e70.z + _e72.w)))));
    let _e80 = t;
    let _e81 = t;
    r3_ = fract(vec2<f32>(_e80, _e81));
    let _e85 = u_3;
    let _e87 = u_3;
    let _e90 = u_3;
    r4_ = fract((((_e85.xz + _e87.zy) + _e90.yw) * 3f));
    let _e101 = hashStyle_1;
    let _e107 = p;
    k1_ = pow((0.5f + (0.5f * sin((_e101 * 1.5f)))), _e107);
    let _e112 = hashStyle_1;
    let _e118 = p;
    k2_ = pow((0.5f + (0.5f * sin((_e112 * 2.7895f)))), _e118);
    let _e123 = hashStyle_1;
    let _e129 = p;
    k3_ = pow((0.5f + (0.5f * cos((_e123 * 1.5f)))), _e129);
    let _e134 = hashStyle_1;
    let _e140 = p;
    k4_ = pow((0.5f + (0.5f * cos((_e134 * 2.7895f)))), _e140);
    let _e143 = k1_;
    let _e144 = k2_;
    let _e146 = k3_;
    let _e148 = k4_;
    kTotal = (((_e143 + _e144) + _e146) + _e148);
    let _e151 = k1_;
    let _e152 = r1_;
    let _e154 = k2_;
    let _e155 = r2_;
    let _e158 = k3_;
    let _e159 = r3_;
    let _e162 = k4_;
    let _e163 = r4_;
    let _e166 = kTotal;
    return (((((_e151 * _e152) + (_e154 * _e155)) + (_e158 * _e159)) + (_e162 * _e163)) / vec2(_e166));
}

fn hsl2rgb(c_2: vec3<f32>) -> vec3<f32> {
    var c_3: vec3<f32>;
    var local: f32;
    var t_1: f32;
    var K: vec4<f32> = vec4<f32>(1f, 0.6666667f, 0.33333334f, 3f);
    var p_1: vec3<f32>;

    c_3 = c_2;
    let _e8 = c_3;
    let _e10 = c_3;
    if (_e10.z < 0.5f) {
        let _e14 = c_3;
        local = _e14.z;
    } else {
        let _e17 = c_3;
        local = (1f - _e17.z);
    }
    let _e21 = local;
    t_1 = (_e8.y * _e21);
    let _e34 = c_3;
    let _e36 = K;
    let _e42 = K;
    p_1 = abs(((fract((_e34.xxx + _e36.xyz)) * 6f) - _e42.www));
    let _e47 = c_3;
    let _e49 = t_1;
    let _e51 = K;
    let _e53 = p_1;
    let _e54 = K;
    let _e63 = t_1;
    let _e65 = c_3;
    return ((_e47.z + _e49) * mix(_e51.xxx, clamp((_e53 - _e54.xxx), vec3(0f), vec3(1f)), vec3(((2f * _e63) / _e65.z))));
}

fn hueToRgb(p_2: f32, q: f32, h: f32) -> f32 {
    var p_3: f32;
    var q_1: f32;
    var h_1: f32;

    p_3 = p_2;
    q_1 = q;
    h_1 = h;
    let _e12 = h_1;
    if (_e12 < 0f) {
        let _e15 = h_1;
        h_1 = (_e15 + 1f);
    }
    let _e18 = h_1;
    if (_e18 > 1f) {
        let _e21 = h_1;
        h_1 = (_e21 - 1f);
    }
    let _e25 = h_1;
    if ((6f * _e25) < 1f) {
        {
            let _e29 = p_3;
            let _e30 = q_1;
            let _e31 = p_3;
            let _e35 = h_1;
            return (_e29 + (((_e30 - _e31) * 6f) * _e35));
        }
    }
    let _e39 = h_1;
    if ((2f * _e39) < 1f) {
        {
            let _e43 = q_1;
            return _e43;
        }
    }
    let _e45 = h_1;
    if ((3f * _e45) < 2f) {
        {
            let _e49 = p_3;
            let _e50 = q_1;
            let _e51 = p_3;
            let _e58 = h_1;
            return (_e49 + (((_e50 - _e51) * 6f) * (0.6666667f - _e58)));
        }
    }
    let _e62 = p_3;
    return _e62;
}

fn hslToRgb(inc: vec4<f32>) -> vec4<f32> {
    var inc_1: vec4<f32>;
    var h_2: f32;
    var s: f32;
    var l: f32;
    var q_2: f32 = 0f;
    var p_4: f32;
    var r: f32;
    var g: f32;
    var b: f32;
    var outc: vec4<f32>;

    inc_1 = inc;
    let _e8 = inc_1;
    h_2 = (_e8.x - (floor((_e8.x / 360f)) * 360f));
    let _e16 = h_2;
    h_2 = (_e16 / 360f);
    let _e19 = inc_1;
    s = _e19.y;
    let _e22 = inc_1;
    l = _e22.z;
    let _e27 = l;
    if (_e27 < 0.5f) {
        let _e30 = l;
        let _e32 = s;
        q_2 = (_e30 * (1f + _e32));
    } else {
        let _e35 = l;
        let _e36 = s;
        let _e38 = s;
        let _e39 = l;
        q_2 = ((_e35 + _e36) - (_e38 * _e39));
    }
    let _e43 = l;
    let _e45 = q_2;
    p_4 = ((2f * _e43) - _e45);
    let _e49 = p_4;
    let _e50 = q_2;
    let _e51 = h_2;
    let _e56 = hueToRgb(_e49, _e50, (_e51 + 0.33333334f));
    r = max(0f, _e56);
    let _e60 = p_4;
    let _e61 = q_2;
    let _e62 = h_2;
    let _e63 = hueToRgb(_e60, _e61, _e62);
    g = max(0f, _e63);
    let _e67 = p_4;
    let _e68 = q_2;
    let _e69 = h_2;
    let _e74 = hueToRgb(_e67, _e68, (_e69 - 0.33333334f));
    b = max(0f, _e74);
    let _e79 = r;
    outc.x = min(_e79, 1f);
    let _e83 = g;
    outc.y = min(_e83, 1f);
    let _e87 = b;
    outc.z = min(_e87, 1f);
    let _e91 = inc_1;
    outc.w = _e91.w;
    let _e93 = outc;
    return _e93;
}

fn luma(c_4: vec3<f32>) -> f32 {
    var c_5: vec3<f32>;

    c_5 = c_4;
    let _e9 = c_5;
    let _e13 = c_5;
    let _e18 = c_5;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e10 = bkg_1;
    let _e12 = front_1;
    let _e14 = front_1;
    let _e17 = bkg_1;
    let _e21 = front_1;
    let _e27 = mix(_e10.xyz, _e12.xyz, vec3((_e14.w + ((1f - _e17.w) * (1f - _e21.w)))));
    let _e28 = bkg_1;
    let _e30 = front_1;
    return vec4<f32>(_e27.x, _e27.y, _e27.z, max(_e28.w, _e30.w));
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local_1: vec4<f32>;
    var P: vec4<f32>;
    var local_2: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e8 = RGB_1;
    let _e10 = RGB_1;
    if (_e8.y < _e10.z) {
        let _e13 = RGB_1;
        let _e14 = _e13.zy;
        local_1 = vec4<f32>(_e14.x, _e14.y, -1f, 0.6666667f);
    } else {
        let _e23 = RGB_1;
        let _e24 = _e23.yz;
        local_1 = vec4<f32>(_e24.x, _e24.y, 0f, -0.33333334f);
    }
    let _e34 = local_1;
    P = _e34;
    let _e36 = RGB_1;
    let _e38 = P;
    if (_e36.x < _e38.x) {
        let _e41 = P;
        let _e42 = _e41.xyw;
        let _e43 = RGB_1;
        local_2 = vec4<f32>(_e42.x, _e42.y, _e42.z, _e43.x);
    } else {
        let _e49 = RGB_1;
        let _e51 = P;
        let _e52 = _e51.yzx;
        local_2 = vec4<f32>(_e49.x, _e52.x, _e52.y, _e52.z);
    }
    let _e58 = local_2;
    Q = _e58;
    let _e60 = Q;
    let _e62 = Q;
    let _e64 = Q;
    C = (_e60.x - min(_e62.w, _e64.y));
    let _e69 = Q;
    let _e71 = Q;
    let _e75 = C;
    let _e80 = Q;
    H = abs((((_e69.w - _e71.y) / ((6f * _e75) + 0.0000000001f)) + _e80.z));
    let _e85 = H;
    let _e86 = C;
    let _e87 = Q;
    let _e89 = RGB_1;
    return vec4<f32>(_e85, _e86, _e87.x, _e89.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e8 = RGB_3;
    let _e9 = rgbToHcv(_e8);
    HCV = _e9;
    let _e11 = HCV;
    let _e13 = HCV;
    L = (_e11.z - (_e13.y * 0.5f));
    let _e19 = HCV;
    let _e22 = L;
    S = (_e19.y / ((1f - abs(((_e22 * 2f) - 1f))) + 0.000001f));
    let _e33 = HCV;
    let _e37 = S;
    let _e38 = L;
    let _e39 = RGB_3;
    return vec4<f32>((_e33.x * 360f), _e37, _e38, _e39.w);
}

fn rotation2_(angle: f32) -> mat2x2<f32> {
    var angle_1: f32;
    var ca: f32;
    var sa: f32;

    angle_1 = angle;
    let _e8 = angle_1;
    ca = cos(_e8);
    let _e11 = angle_1;
    sa = sin(_e11);
    let _e14 = ca;
    let _e15 = sa;
    let _e16 = sa;
    let _e18 = ca;
    return mat2x2<f32>(vec2<f32>(_e14, _e15), vec2<f32>(-(_e16), _e18));
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

fn multiGlitch(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, mode: i32, coverage: f32, randomSeed: f32, randomType: f32, levels: i32, threshold: f32, streakLevels: i32, streakBalance: f32, streakCoverage: f32, overMode: i32, overRandomSeed: f32, overRandomType: f32, overLevels: i32, overThreshold: f32, overCoverage: f32, overStreakCoverage: f32, overStreakLevels: i32, overStreakBalance: f32, overTransform: mat3x3<f32>, tileTransform1_: mat3x3<f32>, tileTransform2_: mat3x3<f32>, tileTransform3_: mat3x3<f32>, tileTransform4_: mat3x3<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var mode_1: i32;
    var coverage_1: f32;
    var randomSeed_1: f32;
    var randomType_1: f32;
    var levels_1: i32;
    var threshold_1: f32;
    var streakLevels_1: i32;
    var streakBalance_1: f32;
    var streakCoverage_1: f32;
    var overMode_1: i32;
    var overRandomSeed_1: f32;
    var overRandomType_1: f32;
    var overLevels_1: i32;
    var overThreshold_1: f32;
    var overCoverage_1: f32;
    var overStreakCoverage_1: f32;
    var overStreakLevels_1: i32;
    var overStreakBalance_1: f32;
    var overTransform_1: mat3x3<f32>;
    var tileTransform1_1: mat3x3<f32>;
    var tileTransform2_1: mat3x3<f32>;
    var tileTransform3_1: mat3x3<f32>;
    var tileTransform4_1: mat3x3<f32>;
    var modelTransform_1: mat3x3<f32>;
    var params: LevelParams;
    var col: vec4<f32>;
    var outCol: vec4<f32> = vec4<f32>(0f, 0f, 0f, 1f);
    var inverseModelTransform: mat3x3<f32>;
    var startScale: f32;
    var modeMap: array<i32, 4>;
    var i: i32 = 0i;
    var _uv: vec2<f32>;
    var _params: LevelParams;
    var _srcCol: vec4<f32>;
    var startScale_1: f32;
    var subLevels: f32;
    var subThreshold: f32;
    var streakInterpolateCoverage: f32;
    var streakSubLevels: i32;
    var streakVerticality: f32;
    var seed: f32;
    var hashStyle_2: f32;
    var currentTransform: mat3x3<f32>;
    var inverseCurrentTransform: mat3x3<f32>;
    var v_1: vec2<f32>;
    var relId: vec2<f32>;
    var rnd: vec2<f32>;
    var streakLevel: i32 = 1i;
    var i_1: f32 = 0f;
    var uu1_: vec2<f32>;
    var uu2_: vec2<f32>;
    var k: f32;
    var src1_: vec4<f32>;
    var src2_: vec4<f32>;
    var _uv_1: vec2<f32>;
    var startScale_2: f32;
    var subLevels_1: f32;
    var subThreshold_1: f32;
    var seed_1: f32;
    var hashStyle_3: f32;
    var coverage_2: f32;
    var currentTransform_1: mat3x3<f32>;
    var inverseCurrentTransform_1: mat3x3<f32>;
    var scale: f32;
    var v_2: vec2<f32>;
    var id: vec2<f32>;
    var relId_1: vec2<f32>;
    var rnd_1: vec2<f32>;
    var i_2: f32 = 0f;
    var col_1: vec3<f32>;
    var modeIndex: i32;
    var mode_2: i32;
    var tileTransform: mat3x3<f32>;
    var inverseTileTransform: mat3x3<f32>;
    var w: vec2<f32>;
    var pixId: vec2<f32>;
    var vv: vec2<f32>;
    var size: f32;
    var d: f32;
    var ang: f32;
    var spikeCount: f32 = 4f;
    var anglePeriod: f32;
    var a1_: f32;
    var a2_: f32;
    var k_1: f32;
    var ds: f32;
    var center: vec2<f32>;
    var u1_: vec2<f32>;
    var u2_: vec2<f32>;
    var col1_: vec4<f32>;
    var col2_: vec4<f32>;
    var vert: bool;
    var local_3: f32;
    var a: f32;
    var local_4: vec2<f32>;
    var u1_1: vec2<f32>;
    var u2_1: vec2<f32>;
    var k_2: f32;
    var col1_1: vec4<f32>;
    var col2_1: vec4<f32>;
    var size_1: f32 = 0.5f;
    var ang_1: f32;
    var local_5: f32;
    var orientation: f32;
    var local_6: f32;
    var p_5: f32;
    var local_7: f32;
    var d_1: f32;
    var vv_1: vec2<f32>;
    var scale_1: f32;
    var invert: bool;
    var ds_1: f32;
    var N: f32;
    var w_1: vec2<f32>;
    var center_1: vec2<f32>;
    var ang_2: f32;
    var keepX: f32 = 1f;
    var keepY: f32 = 1f;
    var hide: bool;
    var size_2: f32;
    var outside: bool;
    var w_2: vec2<f32>;
    var minScale: f32;
    var maxScale: f32;
    var scale2_: f32;
    var invScaleRatio: f32;
    var tr: mat3x3<f32>;
    var pixId_1: vec2<f32>;
    var k_3: f32;
    var Xn: f32 = 8f;
    var scale2_1: f32;
    var invScaleRatio_1: f32;
    var tr_1: mat3x3<f32>;
    var piN: f32 = 0.19634955f;
    var ang_3: f32;
    var k_4: f32;
    var N_1: f32;
    var offset: f32;
    var ang_4: f32;
    var dist: f32;
    var u_6: vec2<f32>;
    var s_1: f32;
    var N_2: f32 = 16f;
    var ang_5: f32;
    var rgb: vec4<f32>;
    var inc_2: vec4<f32>;
    var dist_1: f32;
    var k_5: f32;
    var N_3: f32;
    var center_2: vec2<f32>;
    var dv: vec2<f32>;
    var s_2: f32;
    var u1_2: vec2<f32>;
    var u2_2: vec2<f32>;
    var lum: f32;
    var y: f32;
    var local_8: f32;
    var k_6: f32;
    var lum_1: f32;
    var contrast: f32;
    var center_3: vec2<f32>;
    var dv_1: vec2<f32>;
    var N_4: f32;
    var angOffset: f32 = 0f;
    var ang_6: f32;
    var k_7: f32;
    var kCol: f32;
    var lum_2: f32 = 0f;
    var i_3: i32 = 0i;
    var w_3: vec2<f32>;
    var local_9: f32;
    var u1_3: vec2<f32>;
    var u2_3: vec2<f32>;
    var col1_2: vec4<f32>;
    var col2_2: vec4<f32>;
    var outCol1_: vec4<f32>;
    var outCol2_: vec4<f32>;
    var col1_3: vec4<f32>;
    var _uv_2: vec2<f32>;
    var startScale_3: f32;
    var subLevels_2: f32;
    var subThreshold_2: f32;
    var seed_2: f32;
    var hashStyle_4: f32;
    var coverage_3: f32;
    var currentTransform_2: mat3x3<f32>;
    var inverseCurrentTransform_2: mat3x3<f32>;
    var scale_2: f32;
    var v_3: vec2<f32>;
    var id_1: vec2<f32>;
    var relId_2: vec2<f32>;
    var rnd_2: vec2<f32>;
    var i_4: f32 = 0f;
    var col_2: vec3<f32>;
    var modeIndex_1: i32;
    var mode_3: i32;
    var tileTransform_1: mat3x3<f32>;
    var inverseTileTransform_1: mat3x3<f32>;
    var w_4: vec2<f32>;
    var pixId_2: vec2<f32>;
    var vv_2: vec2<f32>;
    var size_3: f32;
    var d_2: f32;
    var ang_7: f32;
    var spikeCount_1: f32 = 4f;
    var anglePeriod_1: f32;
    var a1_1: f32;
    var a2_1: f32;
    var k_8: f32;
    var ds_2: f32;
    var center_4: vec2<f32>;
    var u1_4: vec2<f32>;
    var u2_4: vec2<f32>;
    var col1_4: vec4<f32>;
    var col2_3: vec4<f32>;
    var vert_1: bool;
    var local_10: f32;
    var a_1: f32;
    var local_11: vec2<f32>;
    var u1_5: vec2<f32>;
    var u2_5: vec2<f32>;
    var k_9: f32;
    var col1_5: vec4<f32>;
    var col2_4: vec4<f32>;
    var size_4: f32 = 0.5f;
    var ang_8: f32;
    var local_12: f32;
    var orientation_1: f32;
    var local_13: f32;
    var p_6: f32;
    var local_14: f32;
    var d_3: f32;
    var vv_3: vec2<f32>;
    var scale_3: f32;
    var invert_1: bool;
    var ds_3: f32;
    var N_5: f32;
    var w_5: vec2<f32>;
    var center_5: vec2<f32>;
    var ang_9: f32;
    var keepX_1: f32 = 1f;
    var keepY_1: f32 = 1f;
    var hide_1: bool;
    var size_5: f32;
    var outside_1: bool;
    var w_6: vec2<f32>;
    var minScale_1: f32;
    var maxScale_1: f32;
    var scale2_2: f32;
    var invScaleRatio_2: f32;
    var tr_2: mat3x3<f32>;
    var pixId_3: vec2<f32>;
    var k_10: f32;
    var Xn_1: f32 = 8f;
    var scale2_3: f32;
    var invScaleRatio_3: f32;
    var tr_3: mat3x3<f32>;
    var piN_1: f32 = 0.19634955f;
    var ang_10: f32;
    var k_11: f32;
    var N_6: f32;
    var offset_1: f32;
    var ang_11: f32;
    var dist_2: f32;
    var u_7: vec2<f32>;
    var s_3: f32;
    var N_7: f32 = 16f;
    var ang_12: f32;
    var rgb_1: vec4<f32>;
    var inc_3: vec4<f32>;
    var dist_3: f32;
    var k_12: f32;
    var N_8: f32;
    var center_6: vec2<f32>;
    var dv_2: vec2<f32>;
    var s_4: f32;
    var u1_6: vec2<f32>;
    var u2_6: vec2<f32>;
    var lum_3: f32;
    var y_1: f32;
    var local_15: f32;
    var k_13: f32;
    var lum_4: f32;
    var contrast_1: f32;
    var center_7: vec2<f32>;
    var dv_3: vec2<f32>;
    var N_9: f32;
    var angOffset_1: f32 = 0f;
    var ang_13: f32;
    var k_14: f32;
    var kCol_1: f32;
    var lum_5: f32 = 0f;
    var i_5: i32 = 0i;
    var w_7: vec2<f32>;
    var local_16: f32;
    var u1_7: vec2<f32>;
    var u2_7: vec2<f32>;
    var col1_6: vec4<f32>;
    var col2_5: vec4<f32>;
    var outCol1_1: vec4<f32>;
    var outCol2_1: vec4<f32>;
    var col2_6: vec4<f32>;
    var _uv_3: vec2<f32>;
    var startScale_4: f32;
    var subLevels_3: f32;
    var subThreshold_3: f32;
    var seed_3: f32;
    var hashStyle_5: f32;
    var coverage_4: f32;
    var currentTransform_3: mat3x3<f32>;
    var inverseCurrentTransform_3: mat3x3<f32>;
    var scale_4: f32;
    var v_4: vec2<f32>;
    var id_2: vec2<f32>;
    var relId_3: vec2<f32>;
    var rnd_3: vec2<f32>;
    var i_6: f32 = 0f;
    var col_3: vec3<f32>;
    var modeIndex_2: i32;
    var mode_4: i32;
    var tileTransform_2: mat3x3<f32>;
    var inverseTileTransform_2: mat3x3<f32>;
    var w_8: vec2<f32>;
    var pixId_4: vec2<f32>;
    var vv_4: vec2<f32>;
    var size_6: f32;
    var d_4: f32;
    var ang_14: f32;
    var spikeCount_2: f32 = 4f;
    var anglePeriod_2: f32;
    var a1_2: f32;
    var a2_2: f32;
    var k_15: f32;
    var ds_4: f32;
    var center_8: vec2<f32>;
    var u1_8: vec2<f32>;
    var u2_8: vec2<f32>;
    var col1_7: vec4<f32>;
    var col2_7: vec4<f32>;
    var vert_2: bool;
    var local_17: f32;
    var a_2: f32;
    var local_18: vec2<f32>;
    var u1_9: vec2<f32>;
    var u2_9: vec2<f32>;
    var k_16: f32;
    var col1_8: vec4<f32>;
    var col2_8: vec4<f32>;
    var size_7: f32 = 0.5f;
    var ang_15: f32;
    var local_19: f32;
    var orientation_2: f32;
    var local_20: f32;
    var p_7: f32;
    var local_21: f32;
    var d_5: f32;
    var vv_5: vec2<f32>;
    var scale_5: f32;
    var invert_2: bool;
    var ds_5: f32;
    var N_10: f32;
    var w_9: vec2<f32>;
    var center_9: vec2<f32>;
    var ang_16: f32;
    var keepX_2: f32 = 1f;
    var keepY_2: f32 = 1f;
    var hide_2: bool;
    var size_8: f32;
    var outside_2: bool;
    var w_10: vec2<f32>;
    var minScale_2: f32;
    var maxScale_2: f32;
    var scale2_4: f32;
    var invScaleRatio_4: f32;
    var tr_4: mat3x3<f32>;
    var pixId_5: vec2<f32>;
    var k_17: f32;
    var Xn_2: f32 = 8f;
    var scale2_5: f32;
    var invScaleRatio_5: f32;
    var tr_5: mat3x3<f32>;
    var piN_2: f32 = 0.19634955f;
    var ang_17: f32;
    var k_18: f32;
    var N_11: f32;
    var offset_2: f32;
    var ang_18: f32;
    var dist_4: f32;
    var u_8: vec2<f32>;
    var s_5: f32;
    var N_12: f32 = 16f;
    var ang_19: f32;
    var rgb_2: vec4<f32>;
    var inc_4: vec4<f32>;
    var dist_5: f32;
    var k_19: f32;
    var N_13: f32;
    var center_10: vec2<f32>;
    var dv_4: vec2<f32>;
    var s_6: f32;
    var u1_10: vec2<f32>;
    var u2_10: vec2<f32>;
    var lum_6: f32;
    var y_2: f32;
    var local_22: f32;
    var k_20: f32;
    var lum_7: f32;
    var contrast_2: f32;
    var center_11: vec2<f32>;
    var dv_5: vec2<f32>;
    var N_14: f32;
    var angOffset_2: f32 = 0f;
    var ang_20: f32;
    var k_21: f32;
    var kCol_2: f32;
    var lum_8: f32 = 0f;
    var i_7: i32 = 0i;
    var w_11: vec2<f32>;
    var local_23: f32;
    var u1_11: vec2<f32>;
    var u2_11: vec2<f32>;
    var col1_9: vec4<f32>;
    var col2_9: vec4<f32>;
    var outCol1_2: vec4<f32>;
    var outCol2_2: vec4<f32>;
    var inverseUnderTransform: mat3x3<f32>;
    var startScale_5: f32;
    var modeMap_1: array<i32, 4>;
    var i_8: i32 = 0i;
    var _uv_4: vec2<f32>;
    var _params_1: LevelParams;
    var _srcCol_1: vec4<f32> = vec4(0f);
    var startScale_6: f32;
    var subLevels_4: f32;
    var subThreshold_4: f32;
    var streakInterpolateCoverage_1: f32;
    var streakSubLevels_1: i32;
    var streakVerticality_1: f32;
    var seed_4: f32;
    var hashStyle_6: f32;
    var currentTransform_4: mat3x3<f32>;
    var inverseCurrentTransform_4: mat3x3<f32>;
    var v_5: vec2<f32>;
    var relId_4: vec2<f32>;
    var rnd_4: vec2<f32>;
    var streakLevel_1: i32 = 1i;
    var i_9: f32 = 0f;
    var uu1_1: vec2<f32>;
    var uu2_1: vec2<f32>;
    var k_22: f32;
    var src1_1: vec4<f32>;
    var src2_1: vec4<f32>;
    var _uv_5: vec2<f32>;
    var startScale_7: f32;
    var subLevels_5: f32;
    var subThreshold_5: f32;
    var seed_5: f32;
    var hashStyle_7: f32;
    var coverage_5: f32;
    var currentTransform_5: mat3x3<f32>;
    var inverseCurrentTransform_5: mat3x3<f32>;
    var scale_6: f32;
    var v_6: vec2<f32>;
    var id_3: vec2<f32>;
    var relId_5: vec2<f32>;
    var rnd_5: vec2<f32>;
    var i_10: f32 = 0f;
    var col_4: vec3<f32>;
    var modeIndex_3: i32;
    var mode_5: i32;
    var tileTransform_3: mat3x3<f32>;
    var inverseTileTransform_3: mat3x3<f32>;
    var w_12: vec2<f32>;
    var pixId_6: vec2<f32>;
    var vv_6: vec2<f32>;
    var size_9: f32;
    var d_6: f32;
    var ang_21: f32;
    var spikeCount_3: f32 = 4f;
    var anglePeriod_3: f32;
    var a1_3: f32;
    var a2_3: f32;
    var k_23: f32;
    var ds_6: f32;
    var center_12: vec2<f32>;
    var u1_12: vec2<f32>;
    var u2_12: vec2<f32>;
    var col1_10: vec4<f32>;
    var col2_10: vec4<f32>;
    var vert_3: bool;
    var local_24: f32;
    var a_3: f32;
    var local_25: vec2<f32>;
    var u1_13: vec2<f32>;
    var u2_13: vec2<f32>;
    var k_24: f32;
    var col1_11: vec4<f32>;
    var col2_11: vec4<f32>;
    var size_10: f32 = 0.5f;
    var ang_22: f32;
    var local_26: f32;
    var orientation_3: f32;
    var local_27: f32;
    var p_8: f32;
    var local_28: f32;
    var d_7: f32;
    var vv_7: vec2<f32>;
    var scale_7: f32;
    var invert_3: bool;
    var ds_7: f32;
    var N_15: f32;
    var w_13: vec2<f32>;
    var center_13: vec2<f32>;
    var ang_23: f32;
    var keepX_3: f32 = 1f;
    var keepY_3: f32 = 1f;
    var hide_3: bool;
    var size_11: f32;
    var outside_3: bool;
    var w_14: vec2<f32>;
    var minScale_3: f32;
    var maxScale_3: f32;
    var scale2_6: f32;
    var invScaleRatio_6: f32;
    var tr_6: mat3x3<f32>;
    var pixId_7: vec2<f32>;
    var k_25: f32;
    var Xn_3: f32 = 8f;
    var scale2_7: f32;
    var invScaleRatio_7: f32;
    var tr_7: mat3x3<f32>;
    var piN_3: f32 = 0.19634955f;
    var ang_24: f32;
    var k_26: f32;
    var N_16: f32;
    var offset_3: f32;
    var ang_25: f32;
    var dist_6: f32;
    var u_9: vec2<f32>;
    var s_7: f32;
    var N_17: f32 = 16f;
    var ang_26: f32;
    var rgb_3: vec4<f32>;
    var inc_5: vec4<f32>;
    var dist_7: f32;
    var k_27: f32;
    var N_18: f32;
    var center_14: vec2<f32>;
    var dv_6: vec2<f32>;
    var s_8: f32;
    var u1_14: vec2<f32>;
    var u2_14: vec2<f32>;
    var lum_9: f32;
    var y_3: f32;
    var local_29: f32;
    var k_28: f32;
    var lum_10: f32;
    var contrast_3: f32;
    var center_15: vec2<f32>;
    var dv_7: vec2<f32>;
    var N_19: f32;
    var angOffset_3: f32 = 0f;
    var ang_27: f32;
    var k_29: f32;
    var kCol_3: f32;
    var lum_11: f32 = 0f;
    var i_11: i32 = 0i;
    var w_15: vec2<f32>;
    var local_30: f32;
    var u1_15: vec2<f32>;
    var u2_15: vec2<f32>;
    var col1_12: vec4<f32>;
    var col2_12: vec4<f32>;
    var outCol1_3: vec4<f32>;
    var outCol2_3: vec4<f32>;
    var col1_13: vec4<f32>;
    var _uv_6: vec2<f32>;
    var startScale_8: f32;
    var subLevels_6: f32;
    var subThreshold_6: f32;
    var seed_6: f32;
    var hashStyle_8: f32;
    var coverage_6: f32;
    var currentTransform_6: mat3x3<f32>;
    var inverseCurrentTransform_6: mat3x3<f32>;
    var scale_8: f32;
    var v_7: vec2<f32>;
    var id_4: vec2<f32>;
    var relId_6: vec2<f32>;
    var rnd_6: vec2<f32>;
    var i_12: f32 = 0f;
    var col_5: vec3<f32>;
    var modeIndex_4: i32;
    var mode_6: i32;
    var tileTransform_4: mat3x3<f32>;
    var inverseTileTransform_4: mat3x3<f32>;
    var w_16: vec2<f32>;
    var pixId_8: vec2<f32>;
    var vv_8: vec2<f32>;
    var size_12: f32;
    var d_8: f32;
    var ang_28: f32;
    var spikeCount_4: f32 = 4f;
    var anglePeriod_4: f32;
    var a1_4: f32;
    var a2_4: f32;
    var k_30: f32;
    var ds_8: f32;
    var center_16: vec2<f32>;
    var u1_16: vec2<f32>;
    var u2_16: vec2<f32>;
    var col1_14: vec4<f32>;
    var col2_13: vec4<f32>;
    var vert_4: bool;
    var local_31: f32;
    var a_4: f32;
    var local_32: vec2<f32>;
    var u1_17: vec2<f32>;
    var u2_17: vec2<f32>;
    var k_31: f32;
    var col1_15: vec4<f32>;
    var col2_14: vec4<f32>;
    var size_13: f32 = 0.5f;
    var ang_29: f32;
    var local_33: f32;
    var orientation_4: f32;
    var local_34: f32;
    var p_9: f32;
    var local_35: f32;
    var d_9: f32;
    var vv_9: vec2<f32>;
    var scale_9: f32;
    var invert_4: bool;
    var ds_9: f32;
    var N_20: f32;
    var w_17: vec2<f32>;
    var center_17: vec2<f32>;
    var ang_30: f32;
    var keepX_4: f32 = 1f;
    var keepY_4: f32 = 1f;
    var hide_4: bool;
    var size_14: f32;
    var outside_4: bool;
    var w_18: vec2<f32>;
    var minScale_4: f32;
    var maxScale_4: f32;
    var scale2_8: f32;
    var invScaleRatio_8: f32;
    var tr_8: mat3x3<f32>;
    var pixId_9: vec2<f32>;
    var k_32: f32;
    var Xn_4: f32 = 8f;
    var scale2_9: f32;
    var invScaleRatio_9: f32;
    var tr_9: mat3x3<f32>;
    var piN_4: f32 = 0.19634955f;
    var ang_31: f32;
    var k_33: f32;
    var N_21: f32;
    var offset_4: f32;
    var ang_32: f32;
    var dist_8: f32;
    var u_10: vec2<f32>;
    var s_9: f32;
    var N_22: f32 = 16f;
    var ang_33: f32;
    var rgb_4: vec4<f32>;
    var inc_6: vec4<f32>;
    var dist_9: f32;
    var k_34: f32;
    var N_23: f32;
    var center_18: vec2<f32>;
    var dv_8: vec2<f32>;
    var s_10: f32;
    var u1_18: vec2<f32>;
    var u2_18: vec2<f32>;
    var lum_12: f32;
    var y_4: f32;
    var local_36: f32;
    var k_35: f32;
    var lum_13: f32;
    var contrast_4: f32;
    var center_19: vec2<f32>;
    var dv_9: vec2<f32>;
    var N_24: f32;
    var angOffset_4: f32 = 0f;
    var ang_34: f32;
    var k_36: f32;
    var kCol_4: f32;
    var lum_14: f32 = 0f;
    var i_13: i32 = 0i;
    var w_19: vec2<f32>;
    var local_37: f32;
    var u1_19: vec2<f32>;
    var u2_19: vec2<f32>;
    var col1_16: vec4<f32>;
    var col2_15: vec4<f32>;
    var outCol1_4: vec4<f32>;
    var outCol2_4: vec4<f32>;
    var col2_16: vec4<f32>;
    var _uv_7: vec2<f32>;
    var startScale_9: f32;
    var subLevels_7: f32;
    var subThreshold_7: f32;
    var seed_7: f32;
    var hashStyle_9: f32;
    var coverage_7: f32;
    var currentTransform_7: mat3x3<f32>;
    var inverseCurrentTransform_7: mat3x3<f32>;
    var scale_10: f32;
    var v_8: vec2<f32>;
    var id_5: vec2<f32>;
    var relId_7: vec2<f32>;
    var rnd_7: vec2<f32>;
    var i_14: f32 = 0f;
    var col_6: vec3<f32>;
    var modeIndex_5: i32;
    var mode_7: i32;
    var tileTransform_5: mat3x3<f32>;
    var inverseTileTransform_5: mat3x3<f32>;
    var w_20: vec2<f32>;
    var pixId_10: vec2<f32>;
    var vv_10: vec2<f32>;
    var size_15: f32;
    var d_10: f32;
    var ang_35: f32;
    var spikeCount_5: f32 = 4f;
    var anglePeriod_5: f32;
    var a1_5: f32;
    var a2_5: f32;
    var k_37: f32;
    var ds_10: f32;
    var center_20: vec2<f32>;
    var u1_20: vec2<f32>;
    var u2_20: vec2<f32>;
    var col1_17: vec4<f32>;
    var col2_17: vec4<f32>;
    var vert_5: bool;
    var local_38: f32;
    var a_5: f32;
    var local_39: vec2<f32>;
    var u1_21: vec2<f32>;
    var u2_21: vec2<f32>;
    var k_38: f32;
    var col1_18: vec4<f32>;
    var col2_18: vec4<f32>;
    var size_16: f32 = 0.5f;
    var ang_36: f32;
    var local_40: f32;
    var orientation_5: f32;
    var local_41: f32;
    var p_10: f32;
    var local_42: f32;
    var d_11: f32;
    var vv_11: vec2<f32>;
    var scale_11: f32;
    var invert_5: bool;
    var ds_11: f32;
    var N_25: f32;
    var w_21: vec2<f32>;
    var center_21: vec2<f32>;
    var ang_37: f32;
    var keepX_5: f32 = 1f;
    var keepY_5: f32 = 1f;
    var hide_5: bool;
    var size_17: f32;
    var outside_5: bool;
    var w_22: vec2<f32>;
    var minScale_5: f32;
    var maxScale_5: f32;
    var scale2_10: f32;
    var invScaleRatio_10: f32;
    var tr_10: mat3x3<f32>;
    var pixId_11: vec2<f32>;
    var k_39: f32;
    var Xn_5: f32 = 8f;
    var scale2_11: f32;
    var invScaleRatio_11: f32;
    var tr_11: mat3x3<f32>;
    var piN_5: f32 = 0.19634955f;
    var ang_38: f32;
    var k_40: f32;
    var N_26: f32;
    var offset_5: f32;
    var ang_39: f32;
    var dist_10: f32;
    var u_11: vec2<f32>;
    var s_11: f32;
    var N_27: f32 = 16f;
    var ang_40: f32;
    var rgb_5: vec4<f32>;
    var inc_7: vec4<f32>;
    var dist_11: f32;
    var k_41: f32;
    var N_28: f32;
    var center_22: vec2<f32>;
    var dv_10: vec2<f32>;
    var s_12: f32;
    var u1_22: vec2<f32>;
    var u2_22: vec2<f32>;
    var lum_15: f32;
    var y_5: f32;
    var local_43: f32;
    var k_42: f32;
    var lum_16: f32;
    var contrast_5: f32;
    var center_23: vec2<f32>;
    var dv_11: vec2<f32>;
    var N_29: f32;
    var angOffset_5: f32 = 0f;
    var ang_41: f32;
    var k_43: f32;
    var kCol_5: f32;
    var lum_17: f32 = 0f;
    var i_15: i32 = 0i;
    var w_23: vec2<f32>;
    var local_44: f32;
    var u1_23: vec2<f32>;
    var u2_23: vec2<f32>;
    var col1_19: vec4<f32>;
    var col2_19: vec4<f32>;
    var outCol1_5: vec4<f32>;
    var outCol2_5: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    mode_1 = mode;
    coverage_1 = coverage;
    randomSeed_1 = randomSeed;
    randomType_1 = randomType;
    levels_1 = levels;
    threshold_1 = threshold;
    streakLevels_1 = streakLevels;
    streakBalance_1 = streakBalance;
    streakCoverage_1 = streakCoverage;
    overMode_1 = overMode;
    overRandomSeed_1 = overRandomSeed;
    overRandomType_1 = overRandomType;
    overLevels_1 = overLevels;
    overThreshold_1 = overThreshold;
    overCoverage_1 = overCoverage;
    overStreakCoverage_1 = overStreakCoverage;
    overStreakLevels_1 = overStreakLevels;
    overStreakBalance_1 = overStreakBalance;
    overTransform_1 = overTransform;
    tileTransform1_1 = tileTransform1_;
    tileTransform2_1 = tileTransform2_;
    tileTransform3_1 = tileTransform3_;
    tileTransform4_1 = tileTransform4_;
    modelTransform_1 = modelTransform;
    let _e61 = pos_1;
    let _e65 = global.U[0];
    let _e68 = pos_1;
    let _e77 = _mirror_wrap(((vec2<f32>((_e61.x / _e65.x), _e68.y) / vec2(2f)) + vec2(0.5f)));
    let _e79 = textureSampleLevel(t_source, samp, _e77, 0f);
    col = _e79;
    let _e87 = coverage_1;
    let _e90 = streakCoverage_1;
    if ((_e87 > 0f) || (_e90 > 0f)) {
        {
            let _e94 = modelTransform_1;
            inverseModelTransform = _naga_inverse_3x3_f32(_e94);
            let _e99 = inverseModelTransform[0];
            startScale = length(_e99.xy);
            let _e104 = mode_1;
            if (_e104 < 16i) {
                {
                    loop {
                        let _e109 = i;
                        if !((_e109 < 4i)) {
                            break;
                        }
                        let _e116 = i;
                        let _e118 = mode_1;
                        modeMap[_e116] = _e118;
                        continuing {
                            let _e113 = i;
                            i = (_e113 + 1i);
                        }
                    }
                }
            } else {
                {
                    let _e119 = mode_1;
                    mode_1 = (_e119 - 16i);
                    let _e124 = mode_1;
                    modeMap[0i] = (_e124 & 15i);
                    let _e127 = mode_1;
                    mode_1 = (_e127 / 16i);
                    let _e132 = mode_1;
                    modeMap[1i] = (_e132 & 15i);
                    let _e135 = mode_1;
                    mode_1 = (_e135 / 16i);
                    let _e140 = mode_1;
                    modeMap[2i] = (_e140 & 15i);
                    let _e143 = mode_1;
                    mode_1 = (_e143 / 16i);
                    let _e148 = mode_1;
                    modeMap[3i] = (_e148 & 15i);
                }
            }
            let _e152 = inverseModelTransform;
            params.transform = _e152;
            let _e154 = modelTransform_1;
            params.inverseTransform = _e154;
            let _e156 = startScale;
            params.startScale = _e156;
            let _e158 = levels_1;
            params.subLevels = f32(_e158);
            let _e161 = threshold_1;
            params.subThreshold = _e161;
            let _e167 = modeMap[0];
            params.modeMap[0i] = _e167;
            let _e173 = modeMap[1];
            params.modeMap[1i] = _e173;
            let _e179 = modeMap[2];
            params.modeMap[2i] = _e179;
            let _e185 = modeMap[3];
            params.modeMap[3i] = _e185;
            let _e187 = coverage_1;
            params.coverage = _e187;
            let _e189 = streakCoverage_1;
            params.streakInterpolateCoverage = _e189;
            let _e191 = streakLevels_1;
            params.streakSubLevels = _e191;
            let _e193 = streakBalance_1;
            params.streakVerticality = ((_e193 + 1f) * 0.5f);
            let _e199 = randomSeed_1;
            params.seed = _e199;
            let _e201 = randomType_1;
            params.hashStyle = _e201;
            {
                let _e202 = pos_1;
                _uv = _e202;
                let _e204 = params;
                _params = _e204;
                let _e206 = col;
                _srcCol = _e206;
                let _e208 = _params;
                startScale_1 = _e208.startScale;
                let _e211 = _params;
                subLevels = _e211.subLevels;
                let _e214 = _params;
                subThreshold = _e214.subThreshold;
                let _e217 = _params;
                streakInterpolateCoverage = _e217.streakInterpolateCoverage;
                let _e220 = _params;
                streakSubLevels = _e220.streakSubLevels;
                let _e223 = _params;
                streakVerticality = _e223.streakVerticality;
                let _e226 = _params;
                seed = _e226.seed;
                let _e229 = _params;
                hashStyle_2 = _e229.hashStyle;
                let _e232 = _params;
                currentTransform = _e232.transform;
                let _e235 = _params;
                inverseCurrentTransform = _e235.inverseTransform;
                loop {
                    let _e245 = i_1;
                    let _e246 = streakSubLevels;
                    if !((_e245 < f32(_e246))) {
                        break;
                    }
                    {
                        let _e253 = i_1;
                        if (_e253 != 0f) {
                            {
                                let _e269 = currentTransform;
                                currentTransform = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e269);
                                let _e271 = inverseCurrentTransform;
                                inverseCurrentTransform = (_e271 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                            }
                        }
                        let _e286 = currentTransform;
                        let _e287 = _uv;
                        let _e288 = tf(_e286, _e287);
                        relId = floor(_e288);
                        let _e290 = relId;
                        let _e292 = (_e290 * 0.08845f);
                        let _e293 = i_1;
                        let _e294 = seed;
                        let _e298 = hashStyle_2;
                        let _e299 = hash42sp(vec4<f32>(_e292.x, _e292.y, _e293, _e294), _e298);
                        rnd = _e299;
                        let _e300 = rnd;
                        let _e302 = subThreshold;
                        if (_e300.x > _e302) {
                            {
                                break;
                            }
                        }
                        let _e304 = streakLevel;
                        streakLevel = (_e304 + 1i);
                    }
                    continuing {
                        let _e250 = i_1;
                        i_1 = (_e250 + 1f);
                    }
                }
                let _e307 = rnd;
                let _e309 = streakInterpolateCoverage;
                if (_e307.y <= _e309) {
                    {
                        let _e314 = currentTransform;
                        let _e315 = _uv;
                        let _e316 = tf(_e314, _e315);
                        let _e317 = relId;
                        v_1 = (_e316 - _e317);
                        let _e319 = rnd;
                        let _e324 = streakVerticality;
                        if (fract((_e319.y * 13.323f)) < _e324) {
                            {
                                let _e326 = v_1;
                                k = _e326.y;
                                let _e328 = inverseCurrentTransform;
                                let _e329 = relId;
                                let _e330 = v_1;
                                let _e336 = tf(_e328, (_e329 + vec2<f32>(_e330.x, -0.0001f)));
                                uu1_ = _e336;
                                let _e337 = inverseCurrentTransform;
                                let _e338 = relId;
                                let _e339 = v_1;
                                let _e344 = tf(_e337, (_e338 + vec2<f32>(_e339.x, 0.9999f)));
                                uu2_ = _e344;
                            }
                        } else {
                            {
                                let _e345 = v_1;
                                k = _e345.x;
                                let _e347 = inverseCurrentTransform;
                                let _e348 = relId;
                                let _e351 = v_1;
                                let _e355 = tf(_e347, (_e348 + vec2<f32>(-0.0001f, _e351.y)));
                                uu1_ = _e355;
                                let _e356 = inverseCurrentTransform;
                                let _e357 = relId;
                                let _e359 = v_1;
                                let _e363 = tf(_e356, (_e357 + vec2<f32>(0.9999f, _e359.y)));
                                uu2_ = _e363;
                            }
                        }
                        let _e364 = uu1_;
                        let _e368 = global.U[0];
                        let _e371 = uu1_;
                        let _e380 = _mirror_wrap(((vec2<f32>((_e364.x / _e368.x), _e371.y) / vec2(2f)) + vec2(0.5f)));
                        let _e382 = textureSampleLevel(t_source, samp, _e380, 0f);
                        src1_ = _e382;
                        let _e384 = uu2_;
                        let _e388 = global.U[0];
                        let _e391 = uu2_;
                        let _e400 = _mirror_wrap(((vec2<f32>((_e384.x / _e388.x), _e391.y) / vec2(2f)) + vec2(0.5f)));
                        let _e402 = textureSampleLevel(t_source, samp, _e400, 0f);
                        src2_ = _e402;
                        {
                            let _e404 = uu1_;
                            _uv_1 = _e404;
                            let _e406 = _params;
                            startScale_2 = _e406.startScale;
                            let _e409 = _params;
                            subLevels_1 = _e409.subLevels;
                            let _e412 = _params;
                            subThreshold_1 = _e412.subThreshold;
                            let _e415 = _params;
                            seed_1 = _e415.seed;
                            let _e418 = _params;
                            hashStyle_3 = _e418.hashStyle;
                            let _e421 = _params;
                            coverage_2 = _e421.coverage;
                            let _e424 = _params;
                            currentTransform_1 = _e424.transform;
                            let _e427 = _params;
                            inverseCurrentTransform_1 = _e427.inverseTransform;
                            let _e430 = startScale_2;
                            scale = _e430;
                            loop {
                                let _e438 = i_2;
                                let _e439 = subLevels_1;
                                if !((_e438 < _e439)) {
                                    break;
                                }
                                {
                                    let _e445 = i_2;
                                    if (_e445 != 0f) {
                                        {
                                            let _e461 = currentTransform_1;
                                            currentTransform_1 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e461);
                                            let _e463 = inverseCurrentTransform_1;
                                            inverseCurrentTransform_1 = (_e463 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e478 = currentTransform_1;
                                    let _e479 = _uv_1;
                                    let _e480 = tf(_e478, _e479);
                                    relId_1 = floor(_e480);
                                    let _e482 = relId_1;
                                    let _e484 = (_e482 * 0.13137f);
                                    let _e485 = i_2;
                                    let _e486 = seed_1;
                                    let _e490 = hashStyle_3;
                                    let _e491 = hash42sp(vec4<f32>(_e484.x, _e484.y, _e485, _e486), _e490);
                                    rnd_1 = _e491;
                                    let _e492 = i_2;
                                    let _e493 = subLevels_1;
                                    let _e497 = rnd_1;
                                    let _e499 = subThreshold_1;
                                    if ((_e492 == (_e493 - 1f)) || (_e497.x > _e499)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e502 = scale;
                                    scale = (_e502 * 2f);
                                }
                                continuing {
                                    let _e442 = i_2;
                                    i_2 = (_e442 + 1f);
                                }
                            }
                            let _e505 = inverseCurrentTransform_1;
                            let _e506 = relId_1;
                            let _e507 = tf(_e505, _e506);
                            id = _e507;
                            let _e509 = rnd_1;
                            modeIndex = i32(floor((_e509.y * 4f)));
                            let _e516 = modeIndex;
                            let _e519 = _params.modeMap[_e516];
                            mode_2 = _e519;
                            let _e522 = modeIndex;
                            if (_e522 == 0i) {
                                let _e525 = tileTransform1_1;
                                tileTransform = _e525;
                            } else {
                                let _e526 = modeIndex;
                                if (_e526 == 1i) {
                                    let _e529 = tileTransform2_1;
                                    tileTransform = _e529;
                                } else {
                                    let _e530 = modeIndex;
                                    if (_e530 == 2i) {
                                        let _e533 = tileTransform3_1;
                                        tileTransform = _e533;
                                    } else {
                                        let _e534 = tileTransform4_1;
                                        tileTransform = _e534;
                                    }
                                }
                            }
                            let _e535 = tileTransform;
                            inverseTileTransform = _naga_inverse_3x3_f32(_e535);
                            let _e538 = currentTransform_1;
                            let _e539 = _uv_1;
                            let _e540 = tf(_e538, _e539);
                            let _e541 = relId_1;
                            v_2 = ((_e540 - _e541) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e548 = rnd_1;
                            let _e552 = rnd_1;
                            let _e558 = coverage_2;
                            if (fract(((_e548.x * 6.222f) + (_e552.y * 8.233f))) <= _e558) {
                                {
                                    let _e560 = mode_2;
                                    if (_e560 == 0i) {
                                        {
                                            let _e565 = inverseTileTransform[0];
                                            w = _e565.xy;
                                            let _e568 = w;
                                            let _e572 = w;
                                            w = floor(vec2<f32>(dot(_e568, vec2(20f)), dot(_e572, vec2<f32>(20f, -20f))));
                                            let _e580 = relId_1;
                                            let _e582 = v_2;
                                            let _e583 = w;
                                            let _e588 = tileTransform[0];
                                            let _e595 = inverseTileTransform[2];
                                            let _e598 = w;
                                            pixId = (_e580 + (1.23f * (floor((_e582 * _e583)) + floor((((length(_e588.xy) * 5f) * _e595.xy) * _e598)))));
                                            let _e605 = pixId;
                                            let _e606 = hash22_(_e605);
                                            let _e610 = global.U[0];
                                            let _e613 = pixId;
                                            let _e614 = hash22_(_e613);
                                            let _e623 = _mirror_wrap(((vec2<f32>((_e606.x / _e610.x), _e614.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e625 = textureSampleLevel(t_source, samp, _e623, 0f);
                                            outCol = _e625;
                                        }
                                    } else {
                                        let _e626 = mode_2;
                                        if (_e626 == 1i) {
                                            {
                                                let _e630 = v_2;
                                                let _e633 = v_2;
                                                v_2 = vec2<f32>(0f, max(abs(_e630.x), abs(_e633.y)));
                                                let _e638 = inverseCurrentTransform_1;
                                                let _e639 = relId_1;
                                                let _e640 = inverseTileTransform;
                                                let _e641 = v_2;
                                                let _e642 = tf(_e640, _e641);
                                                let _e647 = tf(_e638, (_e639 + (_e642 + vec2(0.5f))));
                                                vv = _e647;
                                                let _e649 = vv;
                                                let _e653 = global.U[0];
                                                let _e656 = vv;
                                                let _e665 = _mirror_wrap(((vec2<f32>((_e649.x / _e653.x), _e656.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e667 = textureSampleLevel(t_source, samp, _e665, 0f);
                                                outCol = _e667;
                                            }
                                        } else {
                                            let _e668 = mode_2;
                                            if (_e668 == 2i) {
                                                {
                                                    let _e674 = inverseTileTransform[2];
                                                    size = (0.5f + _e674.y);
                                                    let _e678 = v_2;
                                                    d = length(_e678);
                                                    let _e681 = v_2;
                                                    let _e683 = v_2;
                                                    ang = atan2(_e681.y, _e683.x);
                                                    let _e687 = d;
                                                    let _e688 = size;
                                                    if (_e687 <= _e688) {
                                                        {
                                                            let _e693 = spikeCount;
                                                            anglePeriod = (6.2831855f / _e693);
                                                            let _e696 = ang;
                                                            let _e697 = anglePeriod;
                                                            let _e700 = anglePeriod;
                                                            a1_ = (floor((_e696 / _e697)) * _e700);
                                                            let _e703 = a1_;
                                                            let _e704 = anglePeriod;
                                                            a2_ = (_e703 + _e704);
                                                            let _e707 = ang;
                                                            let _e708 = a1_;
                                                            let _e710 = anglePeriod;
                                                            k_1 = ((_e707 - _e708) / _e710);
                                                            let _e713 = d;
                                                            let _e718 = inverseTileTransform[0];
                                                            ds = ((_e713 * 10f) * length(_e718.xy));
                                                            let _e723 = relId_1;
                                                            center = (_e723 + vec2(0.5f));
                                                            let _e728 = inverseCurrentTransform_1;
                                                            let _e729 = center;
                                                            let _e730 = ds;
                                                            let _e731 = a1_;
                                                            let _e733 = a1_;
                                                            let _e740 = inverseTileTransform[2];
                                                            let _e744 = tf(_e728, ((_e729 + (_e730 * vec2<f32>(cos(_e731), sin(_e733)))) + vec2(_e740.x)));
                                                            u1_ = _e744;
                                                            let _e746 = inverseCurrentTransform_1;
                                                            let _e747 = center;
                                                            let _e748 = ds;
                                                            let _e749 = a2_;
                                                            let _e751 = a2_;
                                                            let _e758 = inverseTileTransform[2];
                                                            let _e762 = tf(_e746, ((_e747 + (_e748 * vec2<f32>(cos(_e749), sin(_e751)))) + vec2(_e758.x)));
                                                            u2_ = _e762;
                                                            let _e764 = u1_;
                                                            let _e768 = global.U[0];
                                                            let _e771 = u1_;
                                                            let _e780 = _mirror_wrap(((vec2<f32>((_e764.x / _e768.x), _e771.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e782 = textureSampleLevel(t_source, samp, _e780, 0f);
                                                            col1_ = _e782;
                                                            let _e784 = u2_;
                                                            let _e788 = global.U[0];
                                                            let _e791 = u2_;
                                                            let _e800 = _mirror_wrap(((vec2<f32>((_e784.x / _e788.x), _e791.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e802 = textureSampleLevel(t_source, samp, _e800, 0f);
                                                            col2_ = _e802;
                                                            let _e804 = col1_;
                                                            let _e805 = col2_;
                                                            let _e806 = k_1;
                                                            outCol = mix(_e804, _e805, vec4(_e806));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e809 = mode_2;
                                                if (_e809 == 3i) {
                                                    {
                                                        let _e812 = v_2;
                                                        let _e815 = v_2;
                                                        vert = (abs(_e812.y) > abs(_e815.x));
                                                        let _e820 = vert;
                                                        if _e820 {
                                                            let _e821 = v_2;
                                                            local_3 = _e821.y;
                                                        } else {
                                                            let _e823 = v_2;
                                                            local_3 = _e823.x;
                                                        }
                                                        let _e826 = local_3;
                                                        a = _e826;
                                                        let _e828 = vert;
                                                        if _e828 {
                                                            let _e829 = a;
                                                            let _e831 = a;
                                                            local_4 = vec2<f32>(-(_e829), _e831);
                                                        } else {
                                                            let _e833 = a;
                                                            let _e834 = a;
                                                            local_4 = vec2<f32>(_e833, -(_e834));
                                                        }
                                                        let _e838 = local_4;
                                                        u1_1 = _e838;
                                                        let _e840 = a;
                                                        let _e841 = a;
                                                        u2_1 = vec2<f32>(_e840, _e841);
                                                        let _e844 = v_2;
                                                        let _e846 = v_2;
                                                        let _e850 = a;
                                                        k_2 = ((_e844.x + _e846.y) / (2f * _e850));
                                                        let _e854 = inverseCurrentTransform_1;
                                                        let _e855 = relId_1;
                                                        let _e856 = inverseTileTransform;
                                                        let _e857 = u1_1;
                                                        let _e858 = tf(_e856, _e857);
                                                        let _e863 = tf(_e854, (_e855 + (_e858 + vec2(0.5f))));
                                                        u1_1 = _e863;
                                                        let _e864 = inverseCurrentTransform_1;
                                                        let _e865 = relId_1;
                                                        let _e866 = inverseTileTransform;
                                                        let _e867 = u2_1;
                                                        let _e868 = tf(_e866, _e867);
                                                        let _e873 = tf(_e864, (_e865 + (_e868 + vec2(0.5f))));
                                                        u2_1 = _e873;
                                                        let _e874 = u1_1;
                                                        let _e878 = global.U[0];
                                                        let _e881 = u1_1;
                                                        let _e890 = _mirror_wrap(((vec2<f32>((_e874.x / _e878.x), _e881.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e892 = textureSampleLevel(t_source, samp, _e890, 0f);
                                                        col1_1 = _e892;
                                                        let _e894 = u2_1;
                                                        let _e898 = global.U[0];
                                                        let _e901 = u2_1;
                                                        let _e910 = _mirror_wrap(((vec2<f32>((_e894.x / _e898.x), _e901.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e912 = textureSampleLevel(t_source, samp, _e910, 0f);
                                                        col2_1 = _e912;
                                                        let _e914 = col1_1;
                                                        let _e915 = col2_1;
                                                        let _e916 = k_2;
                                                        outCol = mix(_e914, _e915, vec4(_e916));
                                                    }
                                                } else {
                                                    let _e919 = mode_2;
                                                    if (_e919 == 4i) {
                                                        {
                                                            let _e926 = inverseTileTransform[0];
                                                            let _e930 = inverseTileTransform[0];
                                                            ang_1 = atan2(_e926.y, _e930.x);
                                                            let _e934 = ang_1;
                                                            if (_e934 < 0f) {
                                                                let _e937 = relId_1;
                                                                let _e939 = relId_1;
                                                                let _e941 = (_e937.x + _e939.y);
                                                                local_5 = sign(((_e941 - (floor((_e941 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_5 = 1f;
                                                            }
                                                            let _e952 = local_5;
                                                            orientation = _e952;
                                                            let _e954 = rnd_1;
                                                            let _e956 = ang_1;
                                                            if (_e954.y > (abs(_e956) / 3.1415927f)) {
                                                                let _e961 = orientation;
                                                                orientation = -(_e961);
                                                            }
                                                            let _e963 = orientation;
                                                            let _e964 = v_2;
                                                            let _e967 = v_2;
                                                            if (((_e963 * _e964.x) * _e967.y) < 0f) {
                                                                local_6 = 40f;
                                                            } else {
                                                                local_6 = 2.5f;
                                                            }
                                                            let _e975 = local_6;
                                                            p_5 = _e975;
                                                            let _e977 = p_5;
                                                            if (_e977 > 30f) {
                                                                let _e980 = v_2;
                                                                let _e983 = v_2;
                                                                local_7 = max(abs(_e980.x), abs(_e983.y));
                                                            } else {
                                                                let _e987 = v_2;
                                                                let _e990 = p_5;
                                                                let _e992 = v_2;
                                                                let _e995 = p_5;
                                                                let _e999 = p_5;
                                                                local_7 = pow((pow(abs(_e987.x), _e990) + pow(abs(_e992.y), _e995)), (1f / _e999));
                                                            }
                                                            let _e1003 = local_7;
                                                            d_1 = _e1003;
                                                            let _e1006 = d_1;
                                                            v_2 = vec2<f32>(0f, _e1006);
                                                            let _e1008 = v_2;
                                                            let _e1010 = size_1;
                                                            if (_e1008.y <= _e1010) {
                                                                {
                                                                    let _e1012 = inverseCurrentTransform_1;
                                                                    let _e1013 = relId_1;
                                                                    let _e1014 = inverseTileTransform;
                                                                    let _e1015 = v_2;
                                                                    let _e1016 = tf(_e1014, _e1015);
                                                                    let _e1021 = tf(_e1012, (_e1013 + (_e1016 + vec2(0.5f))));
                                                                    vv_1 = _e1021;
                                                                    let _e1023 = vv_1;
                                                                    let _e1027 = global.U[0];
                                                                    let _e1030 = vv_1;
                                                                    let _e1039 = _mirror_wrap(((vec2<f32>((_e1023.x / _e1027.x), _e1030.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e1041 = textureSampleLevel(t_source, samp, _e1039, 0f);
                                                                    outCol = _e1041;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e1042 = mode_2;
                                                        if (_e1042 <= 6i) {
                                                            {
                                                                let _e1047 = inverseTileTransform[0];
                                                                scale_1 = length(_e1047.xy);
                                                                let _e1051 = scale_1;
                                                                invert = (_e1051 < 1f);
                                                                let _e1055 = invert;
                                                                if _e1055 {
                                                                    let _e1057 = scale_1;
                                                                    scale_1 = (1f / _e1057);
                                                                }
                                                                let _e1059 = scale_1;
                                                                ds_1 = fract(_e1059);
                                                                let _e1062 = scale_1;
                                                                N = max(floor(_e1062), 1f);
                                                                let _e1067 = v_2;
                                                                let _e1071 = N;
                                                                w_1 = (fract(((_e1067 + vec2(0.5f)) * _e1071)) - vec2(0.5f));
                                                                let _e1078 = v_2;
                                                                let _e1082 = N;
                                                                let _e1085 = N;
                                                                let _e1094 = N;
                                                                center_1 = ((((floor(((_e1078 + vec2(0.5f)) * _e1082)) / vec2(_e1085)) * 2f) - vec2(1f)) + vec2((1f / _e1094)));
                                                                let _e1101 = inverseTileTransform[0];
                                                                let _e1105 = inverseTileTransform[0];
                                                                ang_2 = atan2(_e1101.y, _e1105.x);
                                                                let _e1113 = ang_2;
                                                                if (_e1113 > 0f) {
                                                                    let _e1117 = ang_2;
                                                                    keepX = (1f - (_e1117 / 3.1415927f));
                                                                } else {
                                                                    let _e1122 = ang_2;
                                                                    keepY = (1f + (_e1122 / 3.1415927f));
                                                                }
                                                                let _e1126 = center_1;
                                                                let _e1129 = keepX;
                                                                let _e1131 = center_1;
                                                                let _e1134 = keepY;
                                                                hide = ((abs(_e1126.x) > _e1129) || (abs(_e1131.y) > _e1134));
                                                                let _e1140 = ds_1;
                                                                size_2 = mix(0.5f, 0.15f, _e1140);
                                                                let _e1143 = mode_2;
                                                                let _e1146 = w_1;
                                                                let _e1148 = size_2;
                                                                let _e1151 = mode_2;
                                                                let _e1154 = w_1;
                                                                let _e1157 = size_2;
                                                                let _e1159 = w_1;
                                                                let _e1162 = size_2;
                                                                outside = (((_e1143 == 6i) && (length(_e1146) > _e1148)) || ((_e1151 == 5i) && ((abs(_e1154.x) > _e1157) || (abs(_e1159.y) > _e1162))));
                                                                let _e1168 = hide;
                                                                let _e1169 = outside;
                                                                if !((_e1168 || _e1169)) {
                                                                    {
                                                                        let _e1172 = id;
                                                                        let _e1175 = inverseTileTransform[2];
                                                                        let _e1181 = global.U[0];
                                                                        let _e1184 = id;
                                                                        let _e1187 = inverseTileTransform[2];
                                                                        let _e1198 = _mirror_wrap(((vec2<f32>(((_e1172 + _e1175.xy).x / _e1181.x), (_e1184 + _e1187.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e1200 = textureSampleLevel(t_source, samp, _e1198, 0f);
                                                                        outCol = _e1200;
                                                                    }
                                                                } else {
                                                                    let _e1201 = invert;
                                                                    if _e1201 {
                                                                        {
                                                                            let _e1202 = id;
                                                                            let _e1206 = global.U[0];
                                                                            let _e1209 = id;
                                                                            let _e1218 = _mirror_wrap(((vec2<f32>((_e1202.x / _e1206.x), _e1209.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e1220 = textureSampleLevel(t_source, samp, _e1218, 0f);
                                                                            outCol = _e1220;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e1221 = mode_2;
                                                            if (_e1221 == 7i) {
                                                                {
                                                                    let _e1226 = inverseTileTransform[0];
                                                                    w_2 = _e1226.xy;
                                                                    let _e1229 = w_2;
                                                                    let _e1233 = w_2;
                                                                    w_2 = floor(vec2<f32>(dot(_e1229, vec2(16f)), dot(_e1233, vec2<f32>(16f, -16f))));
                                                                    let _e1241 = startScale_2;
                                                                    let _e1248 = inverseTileTransform[2];
                                                                    minScale = ((_e1241 * 2f) * pow(2f, floor((2f * _e1248.y))));
                                                                    let _e1255 = minScale;
                                                                    let _e1256 = startScale_2;
                                                                    let _e1263 = inverseTileTransform[2];
                                                                    maxScale = max(_e1255, ((_e1256 * 4f) * pow(2f, floor((2f * _e1263.x)))));
                                                                    let _e1271 = scale;
                                                                    let _e1272 = minScale;
                                                                    let _e1273 = maxScale;
                                                                    scale2_ = clamp(_e1271, _e1272, _e1273);
                                                                    let _e1276 = scale2_;
                                                                    let _e1277 = scale;
                                                                    invScaleRatio = (_e1276 / _e1277);
                                                                    let _e1280 = invScaleRatio;
                                                                    let _e1284 = invScaleRatio;
                                                                    let _e1293 = currentTransform_1;
                                                                    tr = (mat3x3<f32>(vec3<f32>(_e1280, 0f, 0f), vec3<f32>(0f, _e1284, 0f), vec3<f32>(0f, 0f, 1f)) * _e1293);
                                                                    let _e1296 = tr;
                                                                    let _e1297 = _uv_1;
                                                                    let _e1298 = tf(_e1296, _e1297);
                                                                    v_2 = (_e1298 - vec2(0.5f));
                                                                    let _e1302 = v_2;
                                                                    let _e1303 = w_2;
                                                                    pixId_1 = floor((_e1302 * _e1303));
                                                                    let _e1307 = pixId_1;
                                                                    let _e1309 = pixId_1;
                                                                    let _e1311 = (_e1307.x + _e1309.y);
                                                                    k_3 = (_e1311 - (floor((_e1311 / 2f)) * 2f));
                                                                    let _e1318 = k_3;
                                                                    let _e1319 = vec3(_e1318);
                                                                    outCol = vec4<f32>(_e1319.x, _e1319.y, _e1319.z, 1f);
                                                                }
                                                            } else {
                                                                let _e1325 = mode_2;
                                                                if (_e1325 == 8i) {
                                                                    {
                                                                        let _e1330 = startScale_2;
                                                                        scale2_1 = (_e1330 * 4f);
                                                                        let _e1334 = scale2_1;
                                                                        let _e1335 = scale;
                                                                        invScaleRatio_1 = (_e1334 / _e1335);
                                                                        let _e1338 = invScaleRatio_1;
                                                                        let _e1342 = invScaleRatio_1;
                                                                        let _e1351 = currentTransform_1;
                                                                        tr_1 = (mat3x3<f32>(vec3<f32>(_e1338, 0f, 0f), vec3<f32>(0f, _e1342, 0f), vec3<f32>(0f, 0f, 1f)) * _e1351);
                                                                        let _e1354 = tr_1;
                                                                        let _e1355 = _uv_1;
                                                                        let _e1356 = tf(_e1354, _e1355);
                                                                        v_2 = (_e1356 - vec2(0.5f));
                                                                        let _e1366 = inverseTileTransform[0];
                                                                        let _e1370 = inverseTileTransform[0];
                                                                        let _e1373 = piN;
                                                                        let _e1376 = piN;
                                                                        ang_3 = (floor((atan2(_e1366.y, _e1370.x) / _e1373)) * _e1376);
                                                                        let _e1379 = ang_3;
                                                                        let _e1380 = rotation2_(_e1379);
                                                                        let _e1381 = v_2;
                                                                        let _e1385 = inverseTileTransform[0];
                                                                        let _e1392 = inverseTileTransform[2];
                                                                        v_2 = (((_e1380 * _e1381) * length(_e1385.xy)) + (2f * _e1392.xy));
                                                                        let _e1396 = v_2;
                                                                        let _e1398 = v_2;
                                                                        let _e1400 = rnd_1;
                                                                        let _e1407 = Xn;
                                                                        let _e1409 = floor(((_e1396.x + (_e1398.y * sign((_e1400.y - 0.5f)))) * _e1407));
                                                                        k_4 = (_e1409 - (floor((_e1409 / 2f)) * 2f));
                                                                        let _e1416 = k_4;
                                                                        let _e1417 = vec3(_e1416);
                                                                        outCol = vec4<f32>(_e1417.x, _e1417.y, _e1417.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e1423 = mode_2;
                                                                    if (_e1423 == 9i) {
                                                                        {
                                                                            let _e1430 = inverseTileTransform[2];
                                                                            N_1 = floor((1000f * pow(0.25f, length(_e1430.xy))));
                                                                            let _e1441 = N_1;
                                                                            let _e1446 = inverseTileTransform[1];
                                                                            let _e1450 = inverseTileTransform[1];
                                                                            offset = ((1.5707964f + (3.1415927f / _e1441)) + atan2(_e1446.y, _e1450.x));
                                                                            let _e1455 = v_2;
                                                                            let _e1457 = v_2;
                                                                            ang_4 = atan2(_e1455.y, _e1457.x);
                                                                            let _e1461 = ang_4;
                                                                            let _e1462 = offset;
                                                                            let _e1466 = N_1;
                                                                            let _e1469 = N_1;
                                                                            let _e1473 = offset;
                                                                            ang_4 = (((round((((_e1461 - _e1462) / 6.2831855f) * _e1466)) / _e1469) * 6.2831855f) + _e1473);
                                                                            let _e1477 = inverseTileTransform[0];
                                                                            let _e1482 = ang_4;
                                                                            let _e1485 = ang_4;
                                                                            dist = ((length(_e1477.xy) * 0.5f) / max(abs(cos(_e1482)), abs(sin(_e1485))));
                                                                            let _e1491 = dist;
                                                                            let _e1492 = ang_4;
                                                                            let _e1494 = ang_4;
                                                                            v_2 = (_e1491 * vec2<f32>(cos(_e1492), sin(_e1494)));
                                                                            let _e1498 = inverseCurrentTransform_1;
                                                                            let _e1499 = relId_1;
                                                                            let _e1500 = v_2;
                                                                            let _e1505 = tf(_e1498, (_e1499 + (_e1500 + vec2(0.5f))));
                                                                            u_6 = _e1505;
                                                                            let _e1507 = u_6;
                                                                            let _e1511 = global.U[0];
                                                                            let _e1514 = u_6;
                                                                            let _e1523 = _mirror_wrap(((vec2<f32>((_e1507.x / _e1511.x), _e1514.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e1525 = textureSampleLevel(t_source, samp, _e1523, 0f);
                                                                            outCol = _e1525;
                                                                        }
                                                                    } else {
                                                                        let _e1526 = mode_2;
                                                                        if (_e1526 == 10i) {
                                                                            {
                                                                                let _e1531 = inverseTileTransform[0];
                                                                                s_1 = (length(_e1531.xy) * 0.05f);
                                                                                let _e1537 = v_2;
                                                                                v_2 = (_e1537 + vec2(0.5f));
                                                                                let _e1545 = inverseTileTransform[0];
                                                                                let _e1549 = inverseTileTransform[0];
                                                                                let _e1554 = N_2;
                                                                                let _e1559 = N_2;
                                                                                ang_5 = ((floor(((atan2(_e1545.y, _e1549.x) / 3.1415927f) * _e1554)) * 3.1415927f) / _e1559);
                                                                                let _e1562 = ang_5;
                                                                                let _e1563 = rotation2_(_e1562);
                                                                                let _e1564 = v_2;
                                                                                v_2 = (_e1563 * _e1564);
                                                                                let _e1566 = v_2;
                                                                                let _e1570 = inverseTileTransform[2];
                                                                                let _e1574 = tileTransform[0];
                                                                                let _e1582 = v_2;
                                                                                let _e1586 = inverseTileTransform[2];
                                                                                let _e1590 = tileTransform[0];
                                                                                let _e1597 = hslToRgb(vec4<f32>(((_e1566.x + (_e1570.x * length(_e1574.xy))) * 360f), 1f, (_e1582.y + (_e1586.y * length(_e1590.xy))), 1f));
                                                                                rgb = _e1597;
                                                                                let _e1599 = _uv_1;
                                                                                let _e1603 = global.U[0];
                                                                                let _e1606 = _uv_1;
                                                                                let _e1615 = _mirror_wrap(((vec2<f32>((_e1599.x / _e1603.x), _e1606.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e1617 = textureSampleLevel(t_source, samp, _e1615, 0f);
                                                                                inc_2 = _e1617;
                                                                                let _e1619 = inc_2;
                                                                                let _e1621 = rgb;
                                                                                dist_1 = length((_e1619.xyz - _e1621.xyz));
                                                                                let _e1629 = dist_1;
                                                                                let _e1631 = s_1;
                                                                                k_5 = (1f - (smoothstep(0f, 1.7f, _e1629) * _e1631));
                                                                                let _e1635 = inc_2;
                                                                                let _e1636 = rgb;
                                                                                let _e1637 = k_5;
                                                                                rgb = mix(_e1635, _e1636, vec4(_e1637));
                                                                                let _e1640 = rgb;
                                                                                outCol = _e1640;
                                                                            }
                                                                        } else {
                                                                            let _e1641 = mode_2;
                                                                            if (_e1641 == 11i) {
                                                                                {
                                                                                    let _e1647 = inverseTileTransform[0];
                                                                                    N_3 = round((4f * abs(_e1647.x)));
                                                                                    let _e1654 = v_2;
                                                                                    let _e1658 = N_3;
                                                                                    let _e1661 = N_3;
                                                                                    let _e1668 = N_3;
                                                                                    center_2 = (vec2<f32>(0f, ((((floor(((_e1654.y + 0.5f) * _e1658)) / _e1661) * 2f) - 1f) + (1f / _e1668))) * 0.5f);
                                                                                    let _e1675 = v_2;
                                                                                    let _e1676 = center_2;
                                                                                    dv = abs((_e1675 - _e1676));
                                                                                    let _e1680 = dv;
                                                                                    let _e1684 = dv;
                                                                                    let _e1687 = N_3;
                                                                                    if ((_e1680.x < 0.45f) && (_e1684.y < (0.4f / _e1687))) {
                                                                                        {
                                                                                            let _e1693 = inverseTileTransform[2];
                                                                                            s_2 = (_e1693.x + 1f);
                                                                                            let _e1698 = inverseCurrentTransform_1;
                                                                                            let _e1699 = relId_1;
                                                                                            let _e1700 = s_2;
                                                                                            let _e1710 = tf(_e1698, (_e1699 + ((_e1700 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_2 = _e1710;
                                                                                            let _e1712 = inverseCurrentTransform_1;
                                                                                            let _e1713 = relId_1;
                                                                                            let _e1714 = s_2;
                                                                                            let _e1723 = tf(_e1712, (_e1713 + ((_e1714 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_2 = _e1723;
                                                                                            let _e1725 = u1_2;
                                                                                            let _e1729 = global.U[0];
                                                                                            let _e1732 = u1_2;
                                                                                            let _e1741 = _mirror_wrap(((vec2<f32>((_e1725.x / _e1729.x), _e1732.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1743 = textureSampleLevel(t_source, samp, _e1741, 0f);
                                                                                            let _e1744 = u2_2;
                                                                                            let _e1748 = global.U[0];
                                                                                            let _e1751 = u2_2;
                                                                                            let _e1760 = _mirror_wrap(((vec2<f32>((_e1744.x / _e1748.x), _e1751.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1762 = textureSampleLevel(t_source, samp, _e1760, 0f);
                                                                                            let _e1763 = center_2;
                                                                                            outCol = mix(_e1743, _e1762, vec4((_e1763.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e1769 = mode_2;
                                                                                if (_e1769 == 12i) {
                                                                                    {
                                                                                        let _e1772 = v_2;
                                                                                        v_2 = (_e1772 * vec2<f32>(2f, 2f));
                                                                                        let _e1777 = inverseTileTransform;
                                                                                        let _e1778 = v_2;
                                                                                        let _e1779 = tf(_e1777, _e1778);
                                                                                        v_2 = _e1779;
                                                                                        let _e1780 = inverseCurrentTransform_1;
                                                                                        let _e1781 = relId_1;
                                                                                        let _e1782 = v_2;
                                                                                        let _e1787 = tf(_e1780, (_e1781 + (_e1782 + vec2(0.5f))));
                                                                                        let _e1791 = global.U[0];
                                                                                        let _e1794 = inverseCurrentTransform_1;
                                                                                        let _e1795 = relId_1;
                                                                                        let _e1796 = v_2;
                                                                                        let _e1801 = tf(_e1794, (_e1795 + (_e1796 + vec2(0.5f))));
                                                                                        let _e1810 = _mirror_wrap(((vec2<f32>((_e1787.x / _e1791.x), _e1801.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e1812 = textureSampleLevel(t_source, samp, _e1810, 0f);
                                                                                        outCol = _e1812;
                                                                                    }
                                                                                } else {
                                                                                    let _e1813 = mode_2;
                                                                                    if (_e1813 == 13i) {
                                                                                        {
                                                                                            let _e1816 = _uv_1;
                                                                                            let _e1820 = global.U[0];
                                                                                            let _e1823 = _uv_1;
                                                                                            let _e1832 = _mirror_wrap(((vec2<f32>((_e1816.x / _e1820.x), _e1823.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1834 = textureSampleLevel(t_source, samp, _e1832, 0f);
                                                                                            let _e1836 = luma(_e1834.xyz);
                                                                                            lum = _e1836;
                                                                                            let _e1838 = inverseTileTransform;
                                                                                            let _e1839 = v_2;
                                                                                            let _e1844 = tf(_e1838, (_e1839 * vec2<f32>(8f, 8f)));
                                                                                            v_2 = _e1844;
                                                                                            let _e1845 = v_2;
                                                                                            let _e1848 = (_e1845.y + 1f);
                                                                                            y = abs(((_e1848 - (floor((_e1848 / 2f)) * 2f)) - 1f));
                                                                                            let _e1858 = lum;
                                                                                            let _e1859 = y;
                                                                                            if (_e1858 > _e1859) {
                                                                                                local_8 = 1f;
                                                                                            } else {
                                                                                                local_8 = 0f;
                                                                                            }
                                                                                            let _e1864 = local_8;
                                                                                            k_6 = _e1864;
                                                                                            let _e1866 = k_6;
                                                                                            let _e1867 = vec3(_e1866);
                                                                                            outCol = vec4<f32>(_e1867.x, _e1867.y, _e1867.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e1873 = mode_2;
                                                                                        if (_e1873 == 14i) {
                                                                                            {
                                                                                                let _e1876 = id;
                                                                                                let _e1880 = global.U[0];
                                                                                                let _e1883 = id;
                                                                                                let _e1892 = _mirror_wrap(((vec2<f32>((_e1876.x / _e1880.x), _e1883.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e1894 = textureSampleLevel(t_source, samp, _e1892, 0f);
                                                                                                let _e1896 = luma(_e1894.xyz);
                                                                                                lum_1 = _e1896;
                                                                                                let _e1900 = tileTransform[0];
                                                                                                contrast = length(_e1900.xy);
                                                                                                let _e1904 = v_2;
                                                                                                let _e1907 = (_e1904 + vec2(0.5f));
                                                                                                let _e1909 = contrast;
                                                                                                let _e1910 = lum_1;
                                                                                                outCol = vec4<f32>(_e1907.x, _e1907.y, (0.5f + (_e1909 * (_e1910 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e1919 = mode_2;
                                                                                            if (_e1919 == 15i) {
                                                                                                {
                                                                                                    let _e1922 = rnd_1;
                                                                                                    center_3 = (sign((_e1922 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e1930 = v_2;
                                                                                                    let _e1931 = center_3;
                                                                                                    dv_1 = (_e1930 - _e1931);
                                                                                                    let _e1937 = inverseTileTransform[0];
                                                                                                    N_4 = floor((16f * length(_e1937.xy)));
                                                                                                    let _e1945 = dv_1;
                                                                                                    let _e1947 = dv_1;
                                                                                                    let _e1950 = angOffset;
                                                                                                    ang_6 = (atan2(_e1945.y, _e1947.x) + _e1950);
                                                                                                    let _e1953 = ang_6;
                                                                                                    let _e1956 = N_4;
                                                                                                    let _e1959 = (((_e1953 / 3.1415927f) * _e1956) * 2f);
                                                                                                    k_7 = abs(((_e1959 - (floor((_e1959 / 2f)) * 2f)) - 1f));
                                                                                                    let _e1971 = inverseTileTransform[0];
                                                                                                    let _e1975 = inverseTileTransform[0];
                                                                                                    kCol = (atan2(_e1971.y, _e1975.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e1985 = i_3;
                                                                                                        if !((_e1985 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e1992 = inverseCurrentTransform_1;
                                                                                                            let _e1993 = relId_1;
                                                                                                            let _e1996 = i_3;
                                                                                                            let _e2000 = ang_6;
                                                                                                            let _e2002 = ang_6;
                                                                                                            let _e2007 = tf(_e1992, (_e1993 + ((0.1f + (0.15f * f32(_e1996))) * vec2<f32>(cos(_e2000), sin(_e2002)))));
                                                                                                            w_3 = _e2007;
                                                                                                            let _e2009 = lum_2;
                                                                                                            let _e2010 = w_3;
                                                                                                            let _e2014 = global.U[0];
                                                                                                            let _e2017 = w_3;
                                                                                                            let _e2026 = _mirror_wrap(((vec2<f32>((_e2010.x / _e2014.x), _e2017.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2028 = textureSampleLevel(t_source, samp, _e2026, 0f);
                                                                                                            let _e2030 = luma(_e2028.xyz);
                                                                                                            lum_2 = (_e2009 + _e2030);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e1989 = i_3;
                                                                                                            i_3 = (_e1989 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e2032 = lum_2;
                                                                                                    lum_2 = (_e2032 / 5f);
                                                                                                    let _e2035 = lum_2;
                                                                                                    let _e2036 = k_7;
                                                                                                    if (_e2035 > _e2036) {
                                                                                                        local_9 = 1f;
                                                                                                    } else {
                                                                                                        local_9 = 0f;
                                                                                                    }
                                                                                                    let _e2041 = local_9;
                                                                                                    k_7 = _e2041;
                                                                                                    let _e2042 = kCol;
                                                                                                    if (_e2042 == 0f) {
                                                                                                        {
                                                                                                            let _e2045 = k_7;
                                                                                                            let _e2046 = vec3(_e2045);
                                                                                                            outCol = vec4<f32>(_e2046.x, _e2046.y, _e2046.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e2054 = inverseTileTransform[2];
                                                                                                            u1_3 = vec2<f32>(_e2054.x, 0f);
                                                                                                            let _e2062 = inverseTileTransform[2];
                                                                                                            u2_3 = vec2<f32>(0f, _e2062.y);
                                                                                                            let _e2066 = kCol;
                                                                                                            if (_e2066 > 0f) {
                                                                                                                {
                                                                                                                    let _e2069 = u1_3;
                                                                                                                    let _e2070 = id;
                                                                                                                    u1_3 = (_e2069 + _e2070);
                                                                                                                    let _e2072 = u2_3;
                                                                                                                    let _e2073 = id;
                                                                                                                    u2_3 = (_e2072 + (_e2073 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e2078 = u1_3;
                                                                                                            let _e2082 = global.U[0];
                                                                                                            let _e2085 = u1_3;
                                                                                                            let _e2094 = _mirror_wrap(((vec2<f32>((_e2078.x / _e2082.x), _e2085.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2096 = textureSampleLevel(t_source, samp, _e2094, 0f);
                                                                                                            col1_2 = _e2096;
                                                                                                            let _e2098 = u2_3;
                                                                                                            let _e2102 = global.U[0];
                                                                                                            let _e2105 = u2_3;
                                                                                                            let _e2114 = _mirror_wrap(((vec2<f32>((_e2098.x / _e2102.x), _e2105.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2116 = textureSampleLevel(t_source, samp, _e2114, 0f);
                                                                                                            col2_2 = _e2116;
                                                                                                            let _e2118 = col1_2;
                                                                                                            let _e2120 = luma(_e2118.xyz);
                                                                                                            let _e2121 = col2_2;
                                                                                                            let _e2123 = luma(_e2121.xyz);
                                                                                                            if (_e2120 > _e2123) {
                                                                                                                let _e2126 = k_7;
                                                                                                                k_7 = (1f - _e2126);
                                                                                                            }
                                                                                                            let _e2128 = k_7;
                                                                                                            let _e2129 = vec3(_e2128);
                                                                                                            outCol1_ = vec4<f32>(_e2129.x, _e2129.y, _e2129.z, 1f);
                                                                                                            let _e2136 = col1_2;
                                                                                                            let _e2137 = col2_2;
                                                                                                            let _e2138 = k_7;
                                                                                                            outCol2_ = mix(_e2136, _e2137, vec4(_e2138));
                                                                                                            let _e2142 = outCol1_;
                                                                                                            let _e2143 = outCol2_;
                                                                                                            let _e2144 = kCol;
                                                                                                            outCol = mix(_e2142, _e2143, vec4(abs(_e2144)));
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        let _e2148 = src1_;
                        let _e2149 = outCol;
                        let _e2150 = mergeColor(_e2148, _e2149);
                        col1_3 = _e2150;
                        {
                            let _e2152 = uu2_;
                            _uv_2 = _e2152;
                            let _e2154 = _params;
                            startScale_3 = _e2154.startScale;
                            let _e2157 = _params;
                            subLevels_2 = _e2157.subLevels;
                            let _e2160 = _params;
                            subThreshold_2 = _e2160.subThreshold;
                            let _e2163 = _params;
                            seed_2 = _e2163.seed;
                            let _e2166 = _params;
                            hashStyle_4 = _e2166.hashStyle;
                            let _e2169 = _params;
                            coverage_3 = _e2169.coverage;
                            let _e2172 = _params;
                            currentTransform_2 = _e2172.transform;
                            let _e2175 = _params;
                            inverseCurrentTransform_2 = _e2175.inverseTransform;
                            let _e2178 = startScale_3;
                            scale_2 = _e2178;
                            loop {
                                let _e2186 = i_4;
                                let _e2187 = subLevels_2;
                                if !((_e2186 < _e2187)) {
                                    break;
                                }
                                {
                                    let _e2193 = i_4;
                                    if (_e2193 != 0f) {
                                        {
                                            let _e2209 = currentTransform_2;
                                            currentTransform_2 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e2209);
                                            let _e2211 = inverseCurrentTransform_2;
                                            inverseCurrentTransform_2 = (_e2211 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e2226 = currentTransform_2;
                                    let _e2227 = _uv_2;
                                    let _e2228 = tf(_e2226, _e2227);
                                    relId_2 = floor(_e2228);
                                    let _e2230 = relId_2;
                                    let _e2232 = (_e2230 * 0.13137f);
                                    let _e2233 = i_4;
                                    let _e2234 = seed_2;
                                    let _e2238 = hashStyle_4;
                                    let _e2239 = hash42sp(vec4<f32>(_e2232.x, _e2232.y, _e2233, _e2234), _e2238);
                                    rnd_2 = _e2239;
                                    let _e2240 = i_4;
                                    let _e2241 = subLevels_2;
                                    let _e2245 = rnd_2;
                                    let _e2247 = subThreshold_2;
                                    if ((_e2240 == (_e2241 - 1f)) || (_e2245.x > _e2247)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e2250 = scale_2;
                                    scale_2 = (_e2250 * 2f);
                                }
                                continuing {
                                    let _e2190 = i_4;
                                    i_4 = (_e2190 + 1f);
                                }
                            }
                            let _e2253 = inverseCurrentTransform_2;
                            let _e2254 = relId_2;
                            let _e2255 = tf(_e2253, _e2254);
                            id_1 = _e2255;
                            let _e2257 = rnd_2;
                            modeIndex_1 = i32(floor((_e2257.y * 4f)));
                            let _e2264 = modeIndex_1;
                            let _e2267 = _params.modeMap[_e2264];
                            mode_3 = _e2267;
                            let _e2270 = modeIndex_1;
                            if (_e2270 == 0i) {
                                let _e2273 = tileTransform1_1;
                                tileTransform_1 = _e2273;
                            } else {
                                let _e2274 = modeIndex_1;
                                if (_e2274 == 1i) {
                                    let _e2277 = tileTransform2_1;
                                    tileTransform_1 = _e2277;
                                } else {
                                    let _e2278 = modeIndex_1;
                                    if (_e2278 == 2i) {
                                        let _e2281 = tileTransform3_1;
                                        tileTransform_1 = _e2281;
                                    } else {
                                        let _e2282 = tileTransform4_1;
                                        tileTransform_1 = _e2282;
                                    }
                                }
                            }
                            let _e2283 = tileTransform_1;
                            inverseTileTransform_1 = _naga_inverse_3x3_f32(_e2283);
                            let _e2286 = currentTransform_2;
                            let _e2287 = _uv_2;
                            let _e2288 = tf(_e2286, _e2287);
                            let _e2289 = relId_2;
                            v_3 = ((_e2288 - _e2289) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e2296 = rnd_2;
                            let _e2300 = rnd_2;
                            let _e2306 = coverage_3;
                            if (fract(((_e2296.x * 6.222f) + (_e2300.y * 8.233f))) <= _e2306) {
                                {
                                    let _e2308 = mode_3;
                                    if (_e2308 == 0i) {
                                        {
                                            let _e2313 = inverseTileTransform_1[0];
                                            w_4 = _e2313.xy;
                                            let _e2316 = w_4;
                                            let _e2320 = w_4;
                                            w_4 = floor(vec2<f32>(dot(_e2316, vec2(20f)), dot(_e2320, vec2<f32>(20f, -20f))));
                                            let _e2328 = relId_2;
                                            let _e2330 = v_3;
                                            let _e2331 = w_4;
                                            let _e2336 = tileTransform_1[0];
                                            let _e2343 = inverseTileTransform_1[2];
                                            let _e2346 = w_4;
                                            pixId_2 = (_e2328 + (1.23f * (floor((_e2330 * _e2331)) + floor((((length(_e2336.xy) * 5f) * _e2343.xy) * _e2346)))));
                                            let _e2353 = pixId_2;
                                            let _e2354 = hash22_(_e2353);
                                            let _e2358 = global.U[0];
                                            let _e2361 = pixId_2;
                                            let _e2362 = hash22_(_e2361);
                                            let _e2371 = _mirror_wrap(((vec2<f32>((_e2354.x / _e2358.x), _e2362.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e2373 = textureSampleLevel(t_source, samp, _e2371, 0f);
                                            outCol = _e2373;
                                        }
                                    } else {
                                        let _e2374 = mode_3;
                                        if (_e2374 == 1i) {
                                            {
                                                let _e2378 = v_3;
                                                let _e2381 = v_3;
                                                v_3 = vec2<f32>(0f, max(abs(_e2378.x), abs(_e2381.y)));
                                                let _e2386 = inverseCurrentTransform_2;
                                                let _e2387 = relId_2;
                                                let _e2388 = inverseTileTransform_1;
                                                let _e2389 = v_3;
                                                let _e2390 = tf(_e2388, _e2389);
                                                let _e2395 = tf(_e2386, (_e2387 + (_e2390 + vec2(0.5f))));
                                                vv_2 = _e2395;
                                                let _e2397 = vv_2;
                                                let _e2401 = global.U[0];
                                                let _e2404 = vv_2;
                                                let _e2413 = _mirror_wrap(((vec2<f32>((_e2397.x / _e2401.x), _e2404.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e2415 = textureSampleLevel(t_source, samp, _e2413, 0f);
                                                outCol = _e2415;
                                            }
                                        } else {
                                            let _e2416 = mode_3;
                                            if (_e2416 == 2i) {
                                                {
                                                    let _e2422 = inverseTileTransform_1[2];
                                                    size_3 = (0.5f + _e2422.y);
                                                    let _e2426 = v_3;
                                                    d_2 = length(_e2426);
                                                    let _e2429 = v_3;
                                                    let _e2431 = v_3;
                                                    ang_7 = atan2(_e2429.y, _e2431.x);
                                                    let _e2435 = d_2;
                                                    let _e2436 = size_3;
                                                    if (_e2435 <= _e2436) {
                                                        {
                                                            let _e2441 = spikeCount_1;
                                                            anglePeriod_1 = (6.2831855f / _e2441);
                                                            let _e2444 = ang_7;
                                                            let _e2445 = anglePeriod_1;
                                                            let _e2448 = anglePeriod_1;
                                                            a1_1 = (floor((_e2444 / _e2445)) * _e2448);
                                                            let _e2451 = a1_1;
                                                            let _e2452 = anglePeriod_1;
                                                            a2_1 = (_e2451 + _e2452);
                                                            let _e2455 = ang_7;
                                                            let _e2456 = a1_1;
                                                            let _e2458 = anglePeriod_1;
                                                            k_8 = ((_e2455 - _e2456) / _e2458);
                                                            let _e2461 = d_2;
                                                            let _e2466 = inverseTileTransform_1[0];
                                                            ds_2 = ((_e2461 * 10f) * length(_e2466.xy));
                                                            let _e2471 = relId_2;
                                                            center_4 = (_e2471 + vec2(0.5f));
                                                            let _e2476 = inverseCurrentTransform_2;
                                                            let _e2477 = center_4;
                                                            let _e2478 = ds_2;
                                                            let _e2479 = a1_1;
                                                            let _e2481 = a1_1;
                                                            let _e2488 = inverseTileTransform_1[2];
                                                            let _e2492 = tf(_e2476, ((_e2477 + (_e2478 * vec2<f32>(cos(_e2479), sin(_e2481)))) + vec2(_e2488.x)));
                                                            u1_4 = _e2492;
                                                            let _e2494 = inverseCurrentTransform_2;
                                                            let _e2495 = center_4;
                                                            let _e2496 = ds_2;
                                                            let _e2497 = a2_1;
                                                            let _e2499 = a2_1;
                                                            let _e2506 = inverseTileTransform_1[2];
                                                            let _e2510 = tf(_e2494, ((_e2495 + (_e2496 * vec2<f32>(cos(_e2497), sin(_e2499)))) + vec2(_e2506.x)));
                                                            u2_4 = _e2510;
                                                            let _e2512 = u1_4;
                                                            let _e2516 = global.U[0];
                                                            let _e2519 = u1_4;
                                                            let _e2528 = _mirror_wrap(((vec2<f32>((_e2512.x / _e2516.x), _e2519.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e2530 = textureSampleLevel(t_source, samp, _e2528, 0f);
                                                            col1_4 = _e2530;
                                                            let _e2532 = u2_4;
                                                            let _e2536 = global.U[0];
                                                            let _e2539 = u2_4;
                                                            let _e2548 = _mirror_wrap(((vec2<f32>((_e2532.x / _e2536.x), _e2539.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e2550 = textureSampleLevel(t_source, samp, _e2548, 0f);
                                                            col2_3 = _e2550;
                                                            let _e2552 = col1_4;
                                                            let _e2553 = col2_3;
                                                            let _e2554 = k_8;
                                                            outCol = mix(_e2552, _e2553, vec4(_e2554));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e2557 = mode_3;
                                                if (_e2557 == 3i) {
                                                    {
                                                        let _e2560 = v_3;
                                                        let _e2563 = v_3;
                                                        vert_1 = (abs(_e2560.y) > abs(_e2563.x));
                                                        let _e2568 = vert_1;
                                                        if _e2568 {
                                                            let _e2569 = v_3;
                                                            local_10 = _e2569.y;
                                                        } else {
                                                            let _e2571 = v_3;
                                                            local_10 = _e2571.x;
                                                        }
                                                        let _e2574 = local_10;
                                                        a_1 = _e2574;
                                                        let _e2576 = vert_1;
                                                        if _e2576 {
                                                            let _e2577 = a_1;
                                                            let _e2579 = a_1;
                                                            local_11 = vec2<f32>(-(_e2577), _e2579);
                                                        } else {
                                                            let _e2581 = a_1;
                                                            let _e2582 = a_1;
                                                            local_11 = vec2<f32>(_e2581, -(_e2582));
                                                        }
                                                        let _e2586 = local_11;
                                                        u1_5 = _e2586;
                                                        let _e2588 = a_1;
                                                        let _e2589 = a_1;
                                                        u2_5 = vec2<f32>(_e2588, _e2589);
                                                        let _e2592 = v_3;
                                                        let _e2594 = v_3;
                                                        let _e2598 = a_1;
                                                        k_9 = ((_e2592.x + _e2594.y) / (2f * _e2598));
                                                        let _e2602 = inverseCurrentTransform_2;
                                                        let _e2603 = relId_2;
                                                        let _e2604 = inverseTileTransform_1;
                                                        let _e2605 = u1_5;
                                                        let _e2606 = tf(_e2604, _e2605);
                                                        let _e2611 = tf(_e2602, (_e2603 + (_e2606 + vec2(0.5f))));
                                                        u1_5 = _e2611;
                                                        let _e2612 = inverseCurrentTransform_2;
                                                        let _e2613 = relId_2;
                                                        let _e2614 = inverseTileTransform_1;
                                                        let _e2615 = u2_5;
                                                        let _e2616 = tf(_e2614, _e2615);
                                                        let _e2621 = tf(_e2612, (_e2613 + (_e2616 + vec2(0.5f))));
                                                        u2_5 = _e2621;
                                                        let _e2622 = u1_5;
                                                        let _e2626 = global.U[0];
                                                        let _e2629 = u1_5;
                                                        let _e2638 = _mirror_wrap(((vec2<f32>((_e2622.x / _e2626.x), _e2629.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e2640 = textureSampleLevel(t_source, samp, _e2638, 0f);
                                                        col1_5 = _e2640;
                                                        let _e2642 = u2_5;
                                                        let _e2646 = global.U[0];
                                                        let _e2649 = u2_5;
                                                        let _e2658 = _mirror_wrap(((vec2<f32>((_e2642.x / _e2646.x), _e2649.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e2660 = textureSampleLevel(t_source, samp, _e2658, 0f);
                                                        col2_4 = _e2660;
                                                        let _e2662 = col1_5;
                                                        let _e2663 = col2_4;
                                                        let _e2664 = k_9;
                                                        outCol = mix(_e2662, _e2663, vec4(_e2664));
                                                    }
                                                } else {
                                                    let _e2667 = mode_3;
                                                    if (_e2667 == 4i) {
                                                        {
                                                            let _e2674 = inverseTileTransform_1[0];
                                                            let _e2678 = inverseTileTransform_1[0];
                                                            ang_8 = atan2(_e2674.y, _e2678.x);
                                                            let _e2682 = ang_8;
                                                            if (_e2682 < 0f) {
                                                                let _e2685 = relId_2;
                                                                let _e2687 = relId_2;
                                                                let _e2689 = (_e2685.x + _e2687.y);
                                                                local_12 = sign(((_e2689 - (floor((_e2689 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_12 = 1f;
                                                            }
                                                            let _e2700 = local_12;
                                                            orientation_1 = _e2700;
                                                            let _e2702 = rnd_2;
                                                            let _e2704 = ang_8;
                                                            if (_e2702.y > (abs(_e2704) / 3.1415927f)) {
                                                                let _e2709 = orientation_1;
                                                                orientation_1 = -(_e2709);
                                                            }
                                                            let _e2711 = orientation_1;
                                                            let _e2712 = v_3;
                                                            let _e2715 = v_3;
                                                            if (((_e2711 * _e2712.x) * _e2715.y) < 0f) {
                                                                local_13 = 40f;
                                                            } else {
                                                                local_13 = 2.5f;
                                                            }
                                                            let _e2723 = local_13;
                                                            p_6 = _e2723;
                                                            let _e2725 = p_6;
                                                            if (_e2725 > 30f) {
                                                                let _e2728 = v_3;
                                                                let _e2731 = v_3;
                                                                local_14 = max(abs(_e2728.x), abs(_e2731.y));
                                                            } else {
                                                                let _e2735 = v_3;
                                                                let _e2738 = p_6;
                                                                let _e2740 = v_3;
                                                                let _e2743 = p_6;
                                                                let _e2747 = p_6;
                                                                local_14 = pow((pow(abs(_e2735.x), _e2738) + pow(abs(_e2740.y), _e2743)), (1f / _e2747));
                                                            }
                                                            let _e2751 = local_14;
                                                            d_3 = _e2751;
                                                            let _e2754 = d_3;
                                                            v_3 = vec2<f32>(0f, _e2754);
                                                            let _e2756 = v_3;
                                                            let _e2758 = size_4;
                                                            if (_e2756.y <= _e2758) {
                                                                {
                                                                    let _e2760 = inverseCurrentTransform_2;
                                                                    let _e2761 = relId_2;
                                                                    let _e2762 = inverseTileTransform_1;
                                                                    let _e2763 = v_3;
                                                                    let _e2764 = tf(_e2762, _e2763);
                                                                    let _e2769 = tf(_e2760, (_e2761 + (_e2764 + vec2(0.5f))));
                                                                    vv_3 = _e2769;
                                                                    let _e2771 = vv_3;
                                                                    let _e2775 = global.U[0];
                                                                    let _e2778 = vv_3;
                                                                    let _e2787 = _mirror_wrap(((vec2<f32>((_e2771.x / _e2775.x), _e2778.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e2789 = textureSampleLevel(t_source, samp, _e2787, 0f);
                                                                    outCol = _e2789;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e2790 = mode_3;
                                                        if (_e2790 <= 6i) {
                                                            {
                                                                let _e2795 = inverseTileTransform_1[0];
                                                                scale_3 = length(_e2795.xy);
                                                                let _e2799 = scale_3;
                                                                invert_1 = (_e2799 < 1f);
                                                                let _e2803 = invert_1;
                                                                if _e2803 {
                                                                    let _e2805 = scale_3;
                                                                    scale_3 = (1f / _e2805);
                                                                }
                                                                let _e2807 = scale_3;
                                                                ds_3 = fract(_e2807);
                                                                let _e2810 = scale_3;
                                                                N_5 = max(floor(_e2810), 1f);
                                                                let _e2815 = v_3;
                                                                let _e2819 = N_5;
                                                                w_5 = (fract(((_e2815 + vec2(0.5f)) * _e2819)) - vec2(0.5f));
                                                                let _e2826 = v_3;
                                                                let _e2830 = N_5;
                                                                let _e2833 = N_5;
                                                                let _e2842 = N_5;
                                                                center_5 = ((((floor(((_e2826 + vec2(0.5f)) * _e2830)) / vec2(_e2833)) * 2f) - vec2(1f)) + vec2((1f / _e2842)));
                                                                let _e2849 = inverseTileTransform_1[0];
                                                                let _e2853 = inverseTileTransform_1[0];
                                                                ang_9 = atan2(_e2849.y, _e2853.x);
                                                                let _e2861 = ang_9;
                                                                if (_e2861 > 0f) {
                                                                    let _e2865 = ang_9;
                                                                    keepX_1 = (1f - (_e2865 / 3.1415927f));
                                                                } else {
                                                                    let _e2870 = ang_9;
                                                                    keepY_1 = (1f + (_e2870 / 3.1415927f));
                                                                }
                                                                let _e2874 = center_5;
                                                                let _e2877 = keepX_1;
                                                                let _e2879 = center_5;
                                                                let _e2882 = keepY_1;
                                                                hide_1 = ((abs(_e2874.x) > _e2877) || (abs(_e2879.y) > _e2882));
                                                                let _e2888 = ds_3;
                                                                size_5 = mix(0.5f, 0.15f, _e2888);
                                                                let _e2891 = mode_3;
                                                                let _e2894 = w_5;
                                                                let _e2896 = size_5;
                                                                let _e2899 = mode_3;
                                                                let _e2902 = w_5;
                                                                let _e2905 = size_5;
                                                                let _e2907 = w_5;
                                                                let _e2910 = size_5;
                                                                outside_1 = (((_e2891 == 6i) && (length(_e2894) > _e2896)) || ((_e2899 == 5i) && ((abs(_e2902.x) > _e2905) || (abs(_e2907.y) > _e2910))));
                                                                let _e2916 = hide_1;
                                                                let _e2917 = outside_1;
                                                                if !((_e2916 || _e2917)) {
                                                                    {
                                                                        let _e2920 = id_1;
                                                                        let _e2923 = inverseTileTransform_1[2];
                                                                        let _e2929 = global.U[0];
                                                                        let _e2932 = id_1;
                                                                        let _e2935 = inverseTileTransform_1[2];
                                                                        let _e2946 = _mirror_wrap(((vec2<f32>(((_e2920 + _e2923.xy).x / _e2929.x), (_e2932 + _e2935.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e2948 = textureSampleLevel(t_source, samp, _e2946, 0f);
                                                                        outCol = _e2948;
                                                                    }
                                                                } else {
                                                                    let _e2949 = invert_1;
                                                                    if _e2949 {
                                                                        {
                                                                            let _e2950 = id_1;
                                                                            let _e2954 = global.U[0];
                                                                            let _e2957 = id_1;
                                                                            let _e2966 = _mirror_wrap(((vec2<f32>((_e2950.x / _e2954.x), _e2957.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e2968 = textureSampleLevel(t_source, samp, _e2966, 0f);
                                                                            outCol = _e2968;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e2969 = mode_3;
                                                            if (_e2969 == 7i) {
                                                                {
                                                                    let _e2974 = inverseTileTransform_1[0];
                                                                    w_6 = _e2974.xy;
                                                                    let _e2977 = w_6;
                                                                    let _e2981 = w_6;
                                                                    w_6 = floor(vec2<f32>(dot(_e2977, vec2(16f)), dot(_e2981, vec2<f32>(16f, -16f))));
                                                                    let _e2989 = startScale_3;
                                                                    let _e2996 = inverseTileTransform_1[2];
                                                                    minScale_1 = ((_e2989 * 2f) * pow(2f, floor((2f * _e2996.y))));
                                                                    let _e3003 = minScale_1;
                                                                    let _e3004 = startScale_3;
                                                                    let _e3011 = inverseTileTransform_1[2];
                                                                    maxScale_1 = max(_e3003, ((_e3004 * 4f) * pow(2f, floor((2f * _e3011.x)))));
                                                                    let _e3019 = scale_2;
                                                                    let _e3020 = minScale_1;
                                                                    let _e3021 = maxScale_1;
                                                                    scale2_2 = clamp(_e3019, _e3020, _e3021);
                                                                    let _e3024 = scale2_2;
                                                                    let _e3025 = scale_2;
                                                                    invScaleRatio_2 = (_e3024 / _e3025);
                                                                    let _e3028 = invScaleRatio_2;
                                                                    let _e3032 = invScaleRatio_2;
                                                                    let _e3041 = currentTransform_2;
                                                                    tr_2 = (mat3x3<f32>(vec3<f32>(_e3028, 0f, 0f), vec3<f32>(0f, _e3032, 0f), vec3<f32>(0f, 0f, 1f)) * _e3041);
                                                                    let _e3044 = tr_2;
                                                                    let _e3045 = _uv_2;
                                                                    let _e3046 = tf(_e3044, _e3045);
                                                                    v_3 = (_e3046 - vec2(0.5f));
                                                                    let _e3050 = v_3;
                                                                    let _e3051 = w_6;
                                                                    pixId_3 = floor((_e3050 * _e3051));
                                                                    let _e3055 = pixId_3;
                                                                    let _e3057 = pixId_3;
                                                                    let _e3059 = (_e3055.x + _e3057.y);
                                                                    k_10 = (_e3059 - (floor((_e3059 / 2f)) * 2f));
                                                                    let _e3066 = k_10;
                                                                    let _e3067 = vec3(_e3066);
                                                                    outCol = vec4<f32>(_e3067.x, _e3067.y, _e3067.z, 1f);
                                                                }
                                                            } else {
                                                                let _e3073 = mode_3;
                                                                if (_e3073 == 8i) {
                                                                    {
                                                                        let _e3078 = startScale_3;
                                                                        scale2_3 = (_e3078 * 4f);
                                                                        let _e3082 = scale2_3;
                                                                        let _e3083 = scale_2;
                                                                        invScaleRatio_3 = (_e3082 / _e3083);
                                                                        let _e3086 = invScaleRatio_3;
                                                                        let _e3090 = invScaleRatio_3;
                                                                        let _e3099 = currentTransform_2;
                                                                        tr_3 = (mat3x3<f32>(vec3<f32>(_e3086, 0f, 0f), vec3<f32>(0f, _e3090, 0f), vec3<f32>(0f, 0f, 1f)) * _e3099);
                                                                        let _e3102 = tr_3;
                                                                        let _e3103 = _uv_2;
                                                                        let _e3104 = tf(_e3102, _e3103);
                                                                        v_3 = (_e3104 - vec2(0.5f));
                                                                        let _e3114 = inverseTileTransform_1[0];
                                                                        let _e3118 = inverseTileTransform_1[0];
                                                                        let _e3121 = piN_1;
                                                                        let _e3124 = piN_1;
                                                                        ang_10 = (floor((atan2(_e3114.y, _e3118.x) / _e3121)) * _e3124);
                                                                        let _e3127 = ang_10;
                                                                        let _e3128 = rotation2_(_e3127);
                                                                        let _e3129 = v_3;
                                                                        let _e3133 = inverseTileTransform_1[0];
                                                                        let _e3140 = inverseTileTransform_1[2];
                                                                        v_3 = (((_e3128 * _e3129) * length(_e3133.xy)) + (2f * _e3140.xy));
                                                                        let _e3144 = v_3;
                                                                        let _e3146 = v_3;
                                                                        let _e3148 = rnd_2;
                                                                        let _e3155 = Xn_1;
                                                                        let _e3157 = floor(((_e3144.x + (_e3146.y * sign((_e3148.y - 0.5f)))) * _e3155));
                                                                        k_11 = (_e3157 - (floor((_e3157 / 2f)) * 2f));
                                                                        let _e3164 = k_11;
                                                                        let _e3165 = vec3(_e3164);
                                                                        outCol = vec4<f32>(_e3165.x, _e3165.y, _e3165.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e3171 = mode_3;
                                                                    if (_e3171 == 9i) {
                                                                        {
                                                                            let _e3178 = inverseTileTransform_1[2];
                                                                            N_6 = floor((1000f * pow(0.25f, length(_e3178.xy))));
                                                                            let _e3189 = N_6;
                                                                            let _e3194 = inverseTileTransform_1[1];
                                                                            let _e3198 = inverseTileTransform_1[1];
                                                                            offset_1 = ((1.5707964f + (3.1415927f / _e3189)) + atan2(_e3194.y, _e3198.x));
                                                                            let _e3203 = v_3;
                                                                            let _e3205 = v_3;
                                                                            ang_11 = atan2(_e3203.y, _e3205.x);
                                                                            let _e3209 = ang_11;
                                                                            let _e3210 = offset_1;
                                                                            let _e3214 = N_6;
                                                                            let _e3217 = N_6;
                                                                            let _e3221 = offset_1;
                                                                            ang_11 = (((round((((_e3209 - _e3210) / 6.2831855f) * _e3214)) / _e3217) * 6.2831855f) + _e3221);
                                                                            let _e3225 = inverseTileTransform_1[0];
                                                                            let _e3230 = ang_11;
                                                                            let _e3233 = ang_11;
                                                                            dist_2 = ((length(_e3225.xy) * 0.5f) / max(abs(cos(_e3230)), abs(sin(_e3233))));
                                                                            let _e3239 = dist_2;
                                                                            let _e3240 = ang_11;
                                                                            let _e3242 = ang_11;
                                                                            v_3 = (_e3239 * vec2<f32>(cos(_e3240), sin(_e3242)));
                                                                            let _e3246 = inverseCurrentTransform_2;
                                                                            let _e3247 = relId_2;
                                                                            let _e3248 = v_3;
                                                                            let _e3253 = tf(_e3246, (_e3247 + (_e3248 + vec2(0.5f))));
                                                                            u_7 = _e3253;
                                                                            let _e3255 = u_7;
                                                                            let _e3259 = global.U[0];
                                                                            let _e3262 = u_7;
                                                                            let _e3271 = _mirror_wrap(((vec2<f32>((_e3255.x / _e3259.x), _e3262.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e3273 = textureSampleLevel(t_source, samp, _e3271, 0f);
                                                                            outCol = _e3273;
                                                                        }
                                                                    } else {
                                                                        let _e3274 = mode_3;
                                                                        if (_e3274 == 10i) {
                                                                            {
                                                                                let _e3279 = inverseTileTransform_1[0];
                                                                                s_3 = (length(_e3279.xy) * 0.05f);
                                                                                let _e3285 = v_3;
                                                                                v_3 = (_e3285 + vec2(0.5f));
                                                                                let _e3293 = inverseTileTransform_1[0];
                                                                                let _e3297 = inverseTileTransform_1[0];
                                                                                let _e3302 = N_7;
                                                                                let _e3307 = N_7;
                                                                                ang_12 = ((floor(((atan2(_e3293.y, _e3297.x) / 3.1415927f) * _e3302)) * 3.1415927f) / _e3307);
                                                                                let _e3310 = ang_12;
                                                                                let _e3311 = rotation2_(_e3310);
                                                                                let _e3312 = v_3;
                                                                                v_3 = (_e3311 * _e3312);
                                                                                let _e3314 = v_3;
                                                                                let _e3318 = inverseTileTransform_1[2];
                                                                                let _e3322 = tileTransform_1[0];
                                                                                let _e3330 = v_3;
                                                                                let _e3334 = inverseTileTransform_1[2];
                                                                                let _e3338 = tileTransform_1[0];
                                                                                let _e3345 = hslToRgb(vec4<f32>(((_e3314.x + (_e3318.x * length(_e3322.xy))) * 360f), 1f, (_e3330.y + (_e3334.y * length(_e3338.xy))), 1f));
                                                                                rgb_1 = _e3345;
                                                                                let _e3347 = _uv_2;
                                                                                let _e3351 = global.U[0];
                                                                                let _e3354 = _uv_2;
                                                                                let _e3363 = _mirror_wrap(((vec2<f32>((_e3347.x / _e3351.x), _e3354.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e3365 = textureSampleLevel(t_source, samp, _e3363, 0f);
                                                                                inc_3 = _e3365;
                                                                                let _e3367 = inc_3;
                                                                                let _e3369 = rgb_1;
                                                                                dist_3 = length((_e3367.xyz - _e3369.xyz));
                                                                                let _e3377 = dist_3;
                                                                                let _e3379 = s_3;
                                                                                k_12 = (1f - (smoothstep(0f, 1.7f, _e3377) * _e3379));
                                                                                let _e3383 = inc_3;
                                                                                let _e3384 = rgb_1;
                                                                                let _e3385 = k_12;
                                                                                rgb_1 = mix(_e3383, _e3384, vec4(_e3385));
                                                                                let _e3388 = rgb_1;
                                                                                outCol = _e3388;
                                                                            }
                                                                        } else {
                                                                            let _e3389 = mode_3;
                                                                            if (_e3389 == 11i) {
                                                                                {
                                                                                    let _e3395 = inverseTileTransform_1[0];
                                                                                    N_8 = round((4f * abs(_e3395.x)));
                                                                                    let _e3402 = v_3;
                                                                                    let _e3406 = N_8;
                                                                                    let _e3409 = N_8;
                                                                                    let _e3416 = N_8;
                                                                                    center_6 = (vec2<f32>(0f, ((((floor(((_e3402.y + 0.5f) * _e3406)) / _e3409) * 2f) - 1f) + (1f / _e3416))) * 0.5f);
                                                                                    let _e3423 = v_3;
                                                                                    let _e3424 = center_6;
                                                                                    dv_2 = abs((_e3423 - _e3424));
                                                                                    let _e3428 = dv_2;
                                                                                    let _e3432 = dv_2;
                                                                                    let _e3435 = N_8;
                                                                                    if ((_e3428.x < 0.45f) && (_e3432.y < (0.4f / _e3435))) {
                                                                                        {
                                                                                            let _e3441 = inverseTileTransform_1[2];
                                                                                            s_4 = (_e3441.x + 1f);
                                                                                            let _e3446 = inverseCurrentTransform_2;
                                                                                            let _e3447 = relId_2;
                                                                                            let _e3448 = s_4;
                                                                                            let _e3458 = tf(_e3446, (_e3447 + ((_e3448 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_6 = _e3458;
                                                                                            let _e3460 = inverseCurrentTransform_2;
                                                                                            let _e3461 = relId_2;
                                                                                            let _e3462 = s_4;
                                                                                            let _e3471 = tf(_e3460, (_e3461 + ((_e3462 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_6 = _e3471;
                                                                                            let _e3473 = u1_6;
                                                                                            let _e3477 = global.U[0];
                                                                                            let _e3480 = u1_6;
                                                                                            let _e3489 = _mirror_wrap(((vec2<f32>((_e3473.x / _e3477.x), _e3480.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3491 = textureSampleLevel(t_source, samp, _e3489, 0f);
                                                                                            let _e3492 = u2_6;
                                                                                            let _e3496 = global.U[0];
                                                                                            let _e3499 = u2_6;
                                                                                            let _e3508 = _mirror_wrap(((vec2<f32>((_e3492.x / _e3496.x), _e3499.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3510 = textureSampleLevel(t_source, samp, _e3508, 0f);
                                                                                            let _e3511 = center_6;
                                                                                            outCol = mix(_e3491, _e3510, vec4((_e3511.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e3517 = mode_3;
                                                                                if (_e3517 == 12i) {
                                                                                    {
                                                                                        let _e3520 = v_3;
                                                                                        v_3 = (_e3520 * vec2<f32>(2f, 2f));
                                                                                        let _e3525 = inverseTileTransform_1;
                                                                                        let _e3526 = v_3;
                                                                                        let _e3527 = tf(_e3525, _e3526);
                                                                                        v_3 = _e3527;
                                                                                        let _e3528 = inverseCurrentTransform_2;
                                                                                        let _e3529 = relId_2;
                                                                                        let _e3530 = v_3;
                                                                                        let _e3535 = tf(_e3528, (_e3529 + (_e3530 + vec2(0.5f))));
                                                                                        let _e3539 = global.U[0];
                                                                                        let _e3542 = inverseCurrentTransform_2;
                                                                                        let _e3543 = relId_2;
                                                                                        let _e3544 = v_3;
                                                                                        let _e3549 = tf(_e3542, (_e3543 + (_e3544 + vec2(0.5f))));
                                                                                        let _e3558 = _mirror_wrap(((vec2<f32>((_e3535.x / _e3539.x), _e3549.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e3560 = textureSampleLevel(t_source, samp, _e3558, 0f);
                                                                                        outCol = _e3560;
                                                                                    }
                                                                                } else {
                                                                                    let _e3561 = mode_3;
                                                                                    if (_e3561 == 13i) {
                                                                                        {
                                                                                            let _e3564 = _uv_2;
                                                                                            let _e3568 = global.U[0];
                                                                                            let _e3571 = _uv_2;
                                                                                            let _e3580 = _mirror_wrap(((vec2<f32>((_e3564.x / _e3568.x), _e3571.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3582 = textureSampleLevel(t_source, samp, _e3580, 0f);
                                                                                            let _e3584 = luma(_e3582.xyz);
                                                                                            lum_3 = _e3584;
                                                                                            let _e3586 = inverseTileTransform_1;
                                                                                            let _e3587 = v_3;
                                                                                            let _e3592 = tf(_e3586, (_e3587 * vec2<f32>(8f, 8f)));
                                                                                            v_3 = _e3592;
                                                                                            let _e3593 = v_3;
                                                                                            let _e3596 = (_e3593.y + 1f);
                                                                                            y_1 = abs(((_e3596 - (floor((_e3596 / 2f)) * 2f)) - 1f));
                                                                                            let _e3606 = lum_3;
                                                                                            let _e3607 = y_1;
                                                                                            if (_e3606 > _e3607) {
                                                                                                local_15 = 1f;
                                                                                            } else {
                                                                                                local_15 = 0f;
                                                                                            }
                                                                                            let _e3612 = local_15;
                                                                                            k_13 = _e3612;
                                                                                            let _e3614 = k_13;
                                                                                            let _e3615 = vec3(_e3614);
                                                                                            outCol = vec4<f32>(_e3615.x, _e3615.y, _e3615.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e3621 = mode_3;
                                                                                        if (_e3621 == 14i) {
                                                                                            {
                                                                                                let _e3624 = id_1;
                                                                                                let _e3628 = global.U[0];
                                                                                                let _e3631 = id_1;
                                                                                                let _e3640 = _mirror_wrap(((vec2<f32>((_e3624.x / _e3628.x), _e3631.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e3642 = textureSampleLevel(t_source, samp, _e3640, 0f);
                                                                                                let _e3644 = luma(_e3642.xyz);
                                                                                                lum_4 = _e3644;
                                                                                                let _e3648 = tileTransform_1[0];
                                                                                                contrast_1 = length(_e3648.xy);
                                                                                                let _e3652 = v_3;
                                                                                                let _e3655 = (_e3652 + vec2(0.5f));
                                                                                                let _e3657 = contrast_1;
                                                                                                let _e3658 = lum_4;
                                                                                                outCol = vec4<f32>(_e3655.x, _e3655.y, (0.5f + (_e3657 * (_e3658 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e3667 = mode_3;
                                                                                            if (_e3667 == 15i) {
                                                                                                {
                                                                                                    let _e3670 = rnd_2;
                                                                                                    center_7 = (sign((_e3670 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e3678 = v_3;
                                                                                                    let _e3679 = center_7;
                                                                                                    dv_3 = (_e3678 - _e3679);
                                                                                                    let _e3685 = inverseTileTransform_1[0];
                                                                                                    N_9 = floor((16f * length(_e3685.xy)));
                                                                                                    let _e3693 = dv_3;
                                                                                                    let _e3695 = dv_3;
                                                                                                    let _e3698 = angOffset_1;
                                                                                                    ang_13 = (atan2(_e3693.y, _e3695.x) + _e3698);
                                                                                                    let _e3701 = ang_13;
                                                                                                    let _e3704 = N_9;
                                                                                                    let _e3707 = (((_e3701 / 3.1415927f) * _e3704) * 2f);
                                                                                                    k_14 = abs(((_e3707 - (floor((_e3707 / 2f)) * 2f)) - 1f));
                                                                                                    let _e3719 = inverseTileTransform_1[0];
                                                                                                    let _e3723 = inverseTileTransform_1[0];
                                                                                                    kCol_1 = (atan2(_e3719.y, _e3723.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e3733 = i_5;
                                                                                                        if !((_e3733 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e3740 = inverseCurrentTransform_2;
                                                                                                            let _e3741 = relId_2;
                                                                                                            let _e3744 = i_5;
                                                                                                            let _e3748 = ang_13;
                                                                                                            let _e3750 = ang_13;
                                                                                                            let _e3755 = tf(_e3740, (_e3741 + ((0.1f + (0.15f * f32(_e3744))) * vec2<f32>(cos(_e3748), sin(_e3750)))));
                                                                                                            w_7 = _e3755;
                                                                                                            let _e3757 = lum_5;
                                                                                                            let _e3758 = w_7;
                                                                                                            let _e3762 = global.U[0];
                                                                                                            let _e3765 = w_7;
                                                                                                            let _e3774 = _mirror_wrap(((vec2<f32>((_e3758.x / _e3762.x), _e3765.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3776 = textureSampleLevel(t_source, samp, _e3774, 0f);
                                                                                                            let _e3778 = luma(_e3776.xyz);
                                                                                                            lum_5 = (_e3757 + _e3778);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e3737 = i_5;
                                                                                                            i_5 = (_e3737 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e3780 = lum_5;
                                                                                                    lum_5 = (_e3780 / 5f);
                                                                                                    let _e3783 = lum_5;
                                                                                                    let _e3784 = k_14;
                                                                                                    if (_e3783 > _e3784) {
                                                                                                        local_16 = 1f;
                                                                                                    } else {
                                                                                                        local_16 = 0f;
                                                                                                    }
                                                                                                    let _e3789 = local_16;
                                                                                                    k_14 = _e3789;
                                                                                                    let _e3790 = kCol_1;
                                                                                                    if (_e3790 == 0f) {
                                                                                                        {
                                                                                                            let _e3793 = k_14;
                                                                                                            let _e3794 = vec3(_e3793);
                                                                                                            outCol = vec4<f32>(_e3794.x, _e3794.y, _e3794.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e3802 = inverseTileTransform_1[2];
                                                                                                            u1_7 = vec2<f32>(_e3802.x, 0f);
                                                                                                            let _e3810 = inverseTileTransform_1[2];
                                                                                                            u2_7 = vec2<f32>(0f, _e3810.y);
                                                                                                            let _e3814 = kCol_1;
                                                                                                            if (_e3814 > 0f) {
                                                                                                                {
                                                                                                                    let _e3817 = u1_7;
                                                                                                                    let _e3818 = id_1;
                                                                                                                    u1_7 = (_e3817 + _e3818);
                                                                                                                    let _e3820 = u2_7;
                                                                                                                    let _e3821 = id_1;
                                                                                                                    u2_7 = (_e3820 + (_e3821 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e3826 = u1_7;
                                                                                                            let _e3830 = global.U[0];
                                                                                                            let _e3833 = u1_7;
                                                                                                            let _e3842 = _mirror_wrap(((vec2<f32>((_e3826.x / _e3830.x), _e3833.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3844 = textureSampleLevel(t_source, samp, _e3842, 0f);
                                                                                                            col1_6 = _e3844;
                                                                                                            let _e3846 = u2_7;
                                                                                                            let _e3850 = global.U[0];
                                                                                                            let _e3853 = u2_7;
                                                                                                            let _e3862 = _mirror_wrap(((vec2<f32>((_e3846.x / _e3850.x), _e3853.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3864 = textureSampleLevel(t_source, samp, _e3862, 0f);
                                                                                                            col2_5 = _e3864;
                                                                                                            let _e3866 = col1_6;
                                                                                                            let _e3868 = luma(_e3866.xyz);
                                                                                                            let _e3869 = col2_5;
                                                                                                            let _e3871 = luma(_e3869.xyz);
                                                                                                            if (_e3868 > _e3871) {
                                                                                                                let _e3874 = k_14;
                                                                                                                k_14 = (1f - _e3874);
                                                                                                            }
                                                                                                            let _e3876 = k_14;
                                                                                                            let _e3877 = vec3(_e3876);
                                                                                                            outCol1_1 = vec4<f32>(_e3877.x, _e3877.y, _e3877.z, 1f);
                                                                                                            let _e3884 = col1_6;
                                                                                                            let _e3885 = col2_5;
                                                                                                            let _e3886 = k_14;
                                                                                                            outCol2_1 = mix(_e3884, _e3885, vec4(_e3886));
                                                                                                            let _e3890 = outCol1_1;
                                                                                                            let _e3891 = outCol2_1;
                                                                                                            let _e3892 = kCol_1;
                                                                                                            outCol = mix(_e3890, _e3891, vec4(abs(_e3892)));
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        let _e3896 = src2_;
                        let _e3897 = outCol;
                        let _e3898 = mergeColor(_e3896, _e3897);
                        col2_6 = _e3898;
                        let _e3900 = col1_3;
                        let _e3902 = col2_6;
                        let _e3904 = k;
                        let _e3906 = mix(_e3900.xyz, _e3902.xyz, vec3(_e3904));
                        outCol = vec4<f32>(_e3906.x, _e3906.y, _e3906.z, 1f);
                    }
                } else {
                    {
                        {
                            let _e3912 = _uv;
                            _uv_3 = _e3912;
                            let _e3914 = _params;
                            startScale_4 = _e3914.startScale;
                            let _e3917 = _params;
                            subLevels_3 = _e3917.subLevels;
                            let _e3920 = _params;
                            subThreshold_3 = _e3920.subThreshold;
                            let _e3923 = _params;
                            seed_3 = _e3923.seed;
                            let _e3926 = _params;
                            hashStyle_5 = _e3926.hashStyle;
                            let _e3929 = _params;
                            coverage_4 = _e3929.coverage;
                            let _e3932 = _params;
                            currentTransform_3 = _e3932.transform;
                            let _e3935 = _params;
                            inverseCurrentTransform_3 = _e3935.inverseTransform;
                            let _e3938 = startScale_4;
                            scale_4 = _e3938;
                            loop {
                                let _e3946 = i_6;
                                let _e3947 = subLevels_3;
                                if !((_e3946 < _e3947)) {
                                    break;
                                }
                                {
                                    let _e3953 = i_6;
                                    if (_e3953 != 0f) {
                                        {
                                            let _e3969 = currentTransform_3;
                                            currentTransform_3 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e3969);
                                            let _e3971 = inverseCurrentTransform_3;
                                            inverseCurrentTransform_3 = (_e3971 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e3986 = currentTransform_3;
                                    let _e3987 = _uv_3;
                                    let _e3988 = tf(_e3986, _e3987);
                                    relId_3 = floor(_e3988);
                                    let _e3990 = relId_3;
                                    let _e3992 = (_e3990 * 0.13137f);
                                    let _e3993 = i_6;
                                    let _e3994 = seed_3;
                                    let _e3998 = hashStyle_5;
                                    let _e3999 = hash42sp(vec4<f32>(_e3992.x, _e3992.y, _e3993, _e3994), _e3998);
                                    rnd_3 = _e3999;
                                    let _e4000 = i_6;
                                    let _e4001 = subLevels_3;
                                    let _e4005 = rnd_3;
                                    let _e4007 = subThreshold_3;
                                    if ((_e4000 == (_e4001 - 1f)) || (_e4005.x > _e4007)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e4010 = scale_4;
                                    scale_4 = (_e4010 * 2f);
                                }
                                continuing {
                                    let _e3950 = i_6;
                                    i_6 = (_e3950 + 1f);
                                }
                            }
                            let _e4013 = inverseCurrentTransform_3;
                            let _e4014 = relId_3;
                            let _e4015 = tf(_e4013, _e4014);
                            id_2 = _e4015;
                            let _e4017 = rnd_3;
                            modeIndex_2 = i32(floor((_e4017.y * 4f)));
                            let _e4024 = modeIndex_2;
                            let _e4027 = _params.modeMap[_e4024];
                            mode_4 = _e4027;
                            let _e4030 = modeIndex_2;
                            if (_e4030 == 0i) {
                                let _e4033 = tileTransform1_1;
                                tileTransform_2 = _e4033;
                            } else {
                                let _e4034 = modeIndex_2;
                                if (_e4034 == 1i) {
                                    let _e4037 = tileTransform2_1;
                                    tileTransform_2 = _e4037;
                                } else {
                                    let _e4038 = modeIndex_2;
                                    if (_e4038 == 2i) {
                                        let _e4041 = tileTransform3_1;
                                        tileTransform_2 = _e4041;
                                    } else {
                                        let _e4042 = tileTransform4_1;
                                        tileTransform_2 = _e4042;
                                    }
                                }
                            }
                            let _e4043 = tileTransform_2;
                            inverseTileTransform_2 = _naga_inverse_3x3_f32(_e4043);
                            let _e4046 = currentTransform_3;
                            let _e4047 = _uv_3;
                            let _e4048 = tf(_e4046, _e4047);
                            let _e4049 = relId_3;
                            v_4 = ((_e4048 - _e4049) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e4056 = rnd_3;
                            let _e4060 = rnd_3;
                            let _e4066 = coverage_4;
                            if (fract(((_e4056.x * 6.222f) + (_e4060.y * 8.233f))) <= _e4066) {
                                {
                                    let _e4068 = mode_4;
                                    if (_e4068 == 0i) {
                                        {
                                            let _e4073 = inverseTileTransform_2[0];
                                            w_8 = _e4073.xy;
                                            let _e4076 = w_8;
                                            let _e4080 = w_8;
                                            w_8 = floor(vec2<f32>(dot(_e4076, vec2(20f)), dot(_e4080, vec2<f32>(20f, -20f))));
                                            let _e4088 = relId_3;
                                            let _e4090 = v_4;
                                            let _e4091 = w_8;
                                            let _e4096 = tileTransform_2[0];
                                            let _e4103 = inverseTileTransform_2[2];
                                            let _e4106 = w_8;
                                            pixId_4 = (_e4088 + (1.23f * (floor((_e4090 * _e4091)) + floor((((length(_e4096.xy) * 5f) * _e4103.xy) * _e4106)))));
                                            let _e4113 = pixId_4;
                                            let _e4114 = hash22_(_e4113);
                                            let _e4118 = global.U[0];
                                            let _e4121 = pixId_4;
                                            let _e4122 = hash22_(_e4121);
                                            let _e4131 = _mirror_wrap(((vec2<f32>((_e4114.x / _e4118.x), _e4122.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e4133 = textureSampleLevel(t_source, samp, _e4131, 0f);
                                            outCol = _e4133;
                                        }
                                    } else {
                                        let _e4134 = mode_4;
                                        if (_e4134 == 1i) {
                                            {
                                                let _e4138 = v_4;
                                                let _e4141 = v_4;
                                                v_4 = vec2<f32>(0f, max(abs(_e4138.x), abs(_e4141.y)));
                                                let _e4146 = inverseCurrentTransform_3;
                                                let _e4147 = relId_3;
                                                let _e4148 = inverseTileTransform_2;
                                                let _e4149 = v_4;
                                                let _e4150 = tf(_e4148, _e4149);
                                                let _e4155 = tf(_e4146, (_e4147 + (_e4150 + vec2(0.5f))));
                                                vv_4 = _e4155;
                                                let _e4157 = vv_4;
                                                let _e4161 = global.U[0];
                                                let _e4164 = vv_4;
                                                let _e4173 = _mirror_wrap(((vec2<f32>((_e4157.x / _e4161.x), _e4164.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e4175 = textureSampleLevel(t_source, samp, _e4173, 0f);
                                                outCol = _e4175;
                                            }
                                        } else {
                                            let _e4176 = mode_4;
                                            if (_e4176 == 2i) {
                                                {
                                                    let _e4182 = inverseTileTransform_2[2];
                                                    size_6 = (0.5f + _e4182.y);
                                                    let _e4186 = v_4;
                                                    d_4 = length(_e4186);
                                                    let _e4189 = v_4;
                                                    let _e4191 = v_4;
                                                    ang_14 = atan2(_e4189.y, _e4191.x);
                                                    let _e4195 = d_4;
                                                    let _e4196 = size_6;
                                                    if (_e4195 <= _e4196) {
                                                        {
                                                            let _e4201 = spikeCount_2;
                                                            anglePeriod_2 = (6.2831855f / _e4201);
                                                            let _e4204 = ang_14;
                                                            let _e4205 = anglePeriod_2;
                                                            let _e4208 = anglePeriod_2;
                                                            a1_2 = (floor((_e4204 / _e4205)) * _e4208);
                                                            let _e4211 = a1_2;
                                                            let _e4212 = anglePeriod_2;
                                                            a2_2 = (_e4211 + _e4212);
                                                            let _e4215 = ang_14;
                                                            let _e4216 = a1_2;
                                                            let _e4218 = anglePeriod_2;
                                                            k_15 = ((_e4215 - _e4216) / _e4218);
                                                            let _e4221 = d_4;
                                                            let _e4226 = inverseTileTransform_2[0];
                                                            ds_4 = ((_e4221 * 10f) * length(_e4226.xy));
                                                            let _e4231 = relId_3;
                                                            center_8 = (_e4231 + vec2(0.5f));
                                                            let _e4236 = inverseCurrentTransform_3;
                                                            let _e4237 = center_8;
                                                            let _e4238 = ds_4;
                                                            let _e4239 = a1_2;
                                                            let _e4241 = a1_2;
                                                            let _e4248 = inverseTileTransform_2[2];
                                                            let _e4252 = tf(_e4236, ((_e4237 + (_e4238 * vec2<f32>(cos(_e4239), sin(_e4241)))) + vec2(_e4248.x)));
                                                            u1_8 = _e4252;
                                                            let _e4254 = inverseCurrentTransform_3;
                                                            let _e4255 = center_8;
                                                            let _e4256 = ds_4;
                                                            let _e4257 = a2_2;
                                                            let _e4259 = a2_2;
                                                            let _e4266 = inverseTileTransform_2[2];
                                                            let _e4270 = tf(_e4254, ((_e4255 + (_e4256 * vec2<f32>(cos(_e4257), sin(_e4259)))) + vec2(_e4266.x)));
                                                            u2_8 = _e4270;
                                                            let _e4272 = u1_8;
                                                            let _e4276 = global.U[0];
                                                            let _e4279 = u1_8;
                                                            let _e4288 = _mirror_wrap(((vec2<f32>((_e4272.x / _e4276.x), _e4279.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e4290 = textureSampleLevel(t_source, samp, _e4288, 0f);
                                                            col1_7 = _e4290;
                                                            let _e4292 = u2_8;
                                                            let _e4296 = global.U[0];
                                                            let _e4299 = u2_8;
                                                            let _e4308 = _mirror_wrap(((vec2<f32>((_e4292.x / _e4296.x), _e4299.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e4310 = textureSampleLevel(t_source, samp, _e4308, 0f);
                                                            col2_7 = _e4310;
                                                            let _e4312 = col1_7;
                                                            let _e4313 = col2_7;
                                                            let _e4314 = k_15;
                                                            outCol = mix(_e4312, _e4313, vec4(_e4314));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e4317 = mode_4;
                                                if (_e4317 == 3i) {
                                                    {
                                                        let _e4320 = v_4;
                                                        let _e4323 = v_4;
                                                        vert_2 = (abs(_e4320.y) > abs(_e4323.x));
                                                        let _e4328 = vert_2;
                                                        if _e4328 {
                                                            let _e4329 = v_4;
                                                            local_17 = _e4329.y;
                                                        } else {
                                                            let _e4331 = v_4;
                                                            local_17 = _e4331.x;
                                                        }
                                                        let _e4334 = local_17;
                                                        a_2 = _e4334;
                                                        let _e4336 = vert_2;
                                                        if _e4336 {
                                                            let _e4337 = a_2;
                                                            let _e4339 = a_2;
                                                            local_18 = vec2<f32>(-(_e4337), _e4339);
                                                        } else {
                                                            let _e4341 = a_2;
                                                            let _e4342 = a_2;
                                                            local_18 = vec2<f32>(_e4341, -(_e4342));
                                                        }
                                                        let _e4346 = local_18;
                                                        u1_9 = _e4346;
                                                        let _e4348 = a_2;
                                                        let _e4349 = a_2;
                                                        u2_9 = vec2<f32>(_e4348, _e4349);
                                                        let _e4352 = v_4;
                                                        let _e4354 = v_4;
                                                        let _e4358 = a_2;
                                                        k_16 = ((_e4352.x + _e4354.y) / (2f * _e4358));
                                                        let _e4362 = inverseCurrentTransform_3;
                                                        let _e4363 = relId_3;
                                                        let _e4364 = inverseTileTransform_2;
                                                        let _e4365 = u1_9;
                                                        let _e4366 = tf(_e4364, _e4365);
                                                        let _e4371 = tf(_e4362, (_e4363 + (_e4366 + vec2(0.5f))));
                                                        u1_9 = _e4371;
                                                        let _e4372 = inverseCurrentTransform_3;
                                                        let _e4373 = relId_3;
                                                        let _e4374 = inverseTileTransform_2;
                                                        let _e4375 = u2_9;
                                                        let _e4376 = tf(_e4374, _e4375);
                                                        let _e4381 = tf(_e4372, (_e4373 + (_e4376 + vec2(0.5f))));
                                                        u2_9 = _e4381;
                                                        let _e4382 = u1_9;
                                                        let _e4386 = global.U[0];
                                                        let _e4389 = u1_9;
                                                        let _e4398 = _mirror_wrap(((vec2<f32>((_e4382.x / _e4386.x), _e4389.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4400 = textureSampleLevel(t_source, samp, _e4398, 0f);
                                                        col1_8 = _e4400;
                                                        let _e4402 = u2_9;
                                                        let _e4406 = global.U[0];
                                                        let _e4409 = u2_9;
                                                        let _e4418 = _mirror_wrap(((vec2<f32>((_e4402.x / _e4406.x), _e4409.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4420 = textureSampleLevel(t_source, samp, _e4418, 0f);
                                                        col2_8 = _e4420;
                                                        let _e4422 = col1_8;
                                                        let _e4423 = col2_8;
                                                        let _e4424 = k_16;
                                                        outCol = mix(_e4422, _e4423, vec4(_e4424));
                                                    }
                                                } else {
                                                    let _e4427 = mode_4;
                                                    if (_e4427 == 4i) {
                                                        {
                                                            let _e4434 = inverseTileTransform_2[0];
                                                            let _e4438 = inverseTileTransform_2[0];
                                                            ang_15 = atan2(_e4434.y, _e4438.x);
                                                            let _e4442 = ang_15;
                                                            if (_e4442 < 0f) {
                                                                let _e4445 = relId_3;
                                                                let _e4447 = relId_3;
                                                                let _e4449 = (_e4445.x + _e4447.y);
                                                                local_19 = sign(((_e4449 - (floor((_e4449 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_19 = 1f;
                                                            }
                                                            let _e4460 = local_19;
                                                            orientation_2 = _e4460;
                                                            let _e4462 = rnd_3;
                                                            let _e4464 = ang_15;
                                                            if (_e4462.y > (abs(_e4464) / 3.1415927f)) {
                                                                let _e4469 = orientation_2;
                                                                orientation_2 = -(_e4469);
                                                            }
                                                            let _e4471 = orientation_2;
                                                            let _e4472 = v_4;
                                                            let _e4475 = v_4;
                                                            if (((_e4471 * _e4472.x) * _e4475.y) < 0f) {
                                                                local_20 = 40f;
                                                            } else {
                                                                local_20 = 2.5f;
                                                            }
                                                            let _e4483 = local_20;
                                                            p_7 = _e4483;
                                                            let _e4485 = p_7;
                                                            if (_e4485 > 30f) {
                                                                let _e4488 = v_4;
                                                                let _e4491 = v_4;
                                                                local_21 = max(abs(_e4488.x), abs(_e4491.y));
                                                            } else {
                                                                let _e4495 = v_4;
                                                                let _e4498 = p_7;
                                                                let _e4500 = v_4;
                                                                let _e4503 = p_7;
                                                                let _e4507 = p_7;
                                                                local_21 = pow((pow(abs(_e4495.x), _e4498) + pow(abs(_e4500.y), _e4503)), (1f / _e4507));
                                                            }
                                                            let _e4511 = local_21;
                                                            d_5 = _e4511;
                                                            let _e4514 = d_5;
                                                            v_4 = vec2<f32>(0f, _e4514);
                                                            let _e4516 = v_4;
                                                            let _e4518 = size_7;
                                                            if (_e4516.y <= _e4518) {
                                                                {
                                                                    let _e4520 = inverseCurrentTransform_3;
                                                                    let _e4521 = relId_3;
                                                                    let _e4522 = inverseTileTransform_2;
                                                                    let _e4523 = v_4;
                                                                    let _e4524 = tf(_e4522, _e4523);
                                                                    let _e4529 = tf(_e4520, (_e4521 + (_e4524 + vec2(0.5f))));
                                                                    vv_5 = _e4529;
                                                                    let _e4531 = vv_5;
                                                                    let _e4535 = global.U[0];
                                                                    let _e4538 = vv_5;
                                                                    let _e4547 = _mirror_wrap(((vec2<f32>((_e4531.x / _e4535.x), _e4538.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4549 = textureSampleLevel(t_source, samp, _e4547, 0f);
                                                                    outCol = _e4549;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e4550 = mode_4;
                                                        if (_e4550 <= 6i) {
                                                            {
                                                                let _e4555 = inverseTileTransform_2[0];
                                                                scale_5 = length(_e4555.xy);
                                                                let _e4559 = scale_5;
                                                                invert_2 = (_e4559 < 1f);
                                                                let _e4563 = invert_2;
                                                                if _e4563 {
                                                                    let _e4565 = scale_5;
                                                                    scale_5 = (1f / _e4565);
                                                                }
                                                                let _e4567 = scale_5;
                                                                ds_5 = fract(_e4567);
                                                                let _e4570 = scale_5;
                                                                N_10 = max(floor(_e4570), 1f);
                                                                let _e4575 = v_4;
                                                                let _e4579 = N_10;
                                                                w_9 = (fract(((_e4575 + vec2(0.5f)) * _e4579)) - vec2(0.5f));
                                                                let _e4586 = v_4;
                                                                let _e4590 = N_10;
                                                                let _e4593 = N_10;
                                                                let _e4602 = N_10;
                                                                center_9 = ((((floor(((_e4586 + vec2(0.5f)) * _e4590)) / vec2(_e4593)) * 2f) - vec2(1f)) + vec2((1f / _e4602)));
                                                                let _e4609 = inverseTileTransform_2[0];
                                                                let _e4613 = inverseTileTransform_2[0];
                                                                ang_16 = atan2(_e4609.y, _e4613.x);
                                                                let _e4621 = ang_16;
                                                                if (_e4621 > 0f) {
                                                                    let _e4625 = ang_16;
                                                                    keepX_2 = (1f - (_e4625 / 3.1415927f));
                                                                } else {
                                                                    let _e4630 = ang_16;
                                                                    keepY_2 = (1f + (_e4630 / 3.1415927f));
                                                                }
                                                                let _e4634 = center_9;
                                                                let _e4637 = keepX_2;
                                                                let _e4639 = center_9;
                                                                let _e4642 = keepY_2;
                                                                hide_2 = ((abs(_e4634.x) > _e4637) || (abs(_e4639.y) > _e4642));
                                                                let _e4648 = ds_5;
                                                                size_8 = mix(0.5f, 0.15f, _e4648);
                                                                let _e4651 = mode_4;
                                                                let _e4654 = w_9;
                                                                let _e4656 = size_8;
                                                                let _e4659 = mode_4;
                                                                let _e4662 = w_9;
                                                                let _e4665 = size_8;
                                                                let _e4667 = w_9;
                                                                let _e4670 = size_8;
                                                                outside_2 = (((_e4651 == 6i) && (length(_e4654) > _e4656)) || ((_e4659 == 5i) && ((abs(_e4662.x) > _e4665) || (abs(_e4667.y) > _e4670))));
                                                                let _e4676 = hide_2;
                                                                let _e4677 = outside_2;
                                                                if !((_e4676 || _e4677)) {
                                                                    {
                                                                        let _e4680 = id_2;
                                                                        let _e4683 = inverseTileTransform_2[2];
                                                                        let _e4689 = global.U[0];
                                                                        let _e4692 = id_2;
                                                                        let _e4695 = inverseTileTransform_2[2];
                                                                        let _e4706 = _mirror_wrap(((vec2<f32>(((_e4680 + _e4683.xy).x / _e4689.x), (_e4692 + _e4695.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4708 = textureSampleLevel(t_source, samp, _e4706, 0f);
                                                                        outCol = _e4708;
                                                                    }
                                                                } else {
                                                                    let _e4709 = invert_2;
                                                                    if _e4709 {
                                                                        {
                                                                            let _e4710 = id_2;
                                                                            let _e4714 = global.U[0];
                                                                            let _e4717 = id_2;
                                                                            let _e4726 = _mirror_wrap(((vec2<f32>((_e4710.x / _e4714.x), _e4717.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e4728 = textureSampleLevel(t_source, samp, _e4726, 0f);
                                                                            outCol = _e4728;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e4729 = mode_4;
                                                            if (_e4729 == 7i) {
                                                                {
                                                                    let _e4734 = inverseTileTransform_2[0];
                                                                    w_10 = _e4734.xy;
                                                                    let _e4737 = w_10;
                                                                    let _e4741 = w_10;
                                                                    w_10 = floor(vec2<f32>(dot(_e4737, vec2(16f)), dot(_e4741, vec2<f32>(16f, -16f))));
                                                                    let _e4749 = startScale_4;
                                                                    let _e4756 = inverseTileTransform_2[2];
                                                                    minScale_2 = ((_e4749 * 2f) * pow(2f, floor((2f * _e4756.y))));
                                                                    let _e4763 = minScale_2;
                                                                    let _e4764 = startScale_4;
                                                                    let _e4771 = inverseTileTransform_2[2];
                                                                    maxScale_2 = max(_e4763, ((_e4764 * 4f) * pow(2f, floor((2f * _e4771.x)))));
                                                                    let _e4779 = scale_4;
                                                                    let _e4780 = minScale_2;
                                                                    let _e4781 = maxScale_2;
                                                                    scale2_4 = clamp(_e4779, _e4780, _e4781);
                                                                    let _e4784 = scale2_4;
                                                                    let _e4785 = scale_4;
                                                                    invScaleRatio_4 = (_e4784 / _e4785);
                                                                    let _e4788 = invScaleRatio_4;
                                                                    let _e4792 = invScaleRatio_4;
                                                                    let _e4801 = currentTransform_3;
                                                                    tr_4 = (mat3x3<f32>(vec3<f32>(_e4788, 0f, 0f), vec3<f32>(0f, _e4792, 0f), vec3<f32>(0f, 0f, 1f)) * _e4801);
                                                                    let _e4804 = tr_4;
                                                                    let _e4805 = _uv_3;
                                                                    let _e4806 = tf(_e4804, _e4805);
                                                                    v_4 = (_e4806 - vec2(0.5f));
                                                                    let _e4810 = v_4;
                                                                    let _e4811 = w_10;
                                                                    pixId_5 = floor((_e4810 * _e4811));
                                                                    let _e4815 = pixId_5;
                                                                    let _e4817 = pixId_5;
                                                                    let _e4819 = (_e4815.x + _e4817.y);
                                                                    k_17 = (_e4819 - (floor((_e4819 / 2f)) * 2f));
                                                                    let _e4826 = k_17;
                                                                    let _e4827 = vec3(_e4826);
                                                                    outCol = vec4<f32>(_e4827.x, _e4827.y, _e4827.z, 1f);
                                                                }
                                                            } else {
                                                                let _e4833 = mode_4;
                                                                if (_e4833 == 8i) {
                                                                    {
                                                                        let _e4838 = startScale_4;
                                                                        scale2_5 = (_e4838 * 4f);
                                                                        let _e4842 = scale2_5;
                                                                        let _e4843 = scale_4;
                                                                        invScaleRatio_5 = (_e4842 / _e4843);
                                                                        let _e4846 = invScaleRatio_5;
                                                                        let _e4850 = invScaleRatio_5;
                                                                        let _e4859 = currentTransform_3;
                                                                        tr_5 = (mat3x3<f32>(vec3<f32>(_e4846, 0f, 0f), vec3<f32>(0f, _e4850, 0f), vec3<f32>(0f, 0f, 1f)) * _e4859);
                                                                        let _e4862 = tr_5;
                                                                        let _e4863 = _uv_3;
                                                                        let _e4864 = tf(_e4862, _e4863);
                                                                        v_4 = (_e4864 - vec2(0.5f));
                                                                        let _e4874 = inverseTileTransform_2[0];
                                                                        let _e4878 = inverseTileTransform_2[0];
                                                                        let _e4881 = piN_2;
                                                                        let _e4884 = piN_2;
                                                                        ang_17 = (floor((atan2(_e4874.y, _e4878.x) / _e4881)) * _e4884);
                                                                        let _e4887 = ang_17;
                                                                        let _e4888 = rotation2_(_e4887);
                                                                        let _e4889 = v_4;
                                                                        let _e4893 = inverseTileTransform_2[0];
                                                                        let _e4900 = inverseTileTransform_2[2];
                                                                        v_4 = (((_e4888 * _e4889) * length(_e4893.xy)) + (2f * _e4900.xy));
                                                                        let _e4904 = v_4;
                                                                        let _e4906 = v_4;
                                                                        let _e4908 = rnd_3;
                                                                        let _e4915 = Xn_2;
                                                                        let _e4917 = floor(((_e4904.x + (_e4906.y * sign((_e4908.y - 0.5f)))) * _e4915));
                                                                        k_18 = (_e4917 - (floor((_e4917 / 2f)) * 2f));
                                                                        let _e4924 = k_18;
                                                                        let _e4925 = vec3(_e4924);
                                                                        outCol = vec4<f32>(_e4925.x, _e4925.y, _e4925.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e4931 = mode_4;
                                                                    if (_e4931 == 9i) {
                                                                        {
                                                                            let _e4938 = inverseTileTransform_2[2];
                                                                            N_11 = floor((1000f * pow(0.25f, length(_e4938.xy))));
                                                                            let _e4949 = N_11;
                                                                            let _e4954 = inverseTileTransform_2[1];
                                                                            let _e4958 = inverseTileTransform_2[1];
                                                                            offset_2 = ((1.5707964f + (3.1415927f / _e4949)) + atan2(_e4954.y, _e4958.x));
                                                                            let _e4963 = v_4;
                                                                            let _e4965 = v_4;
                                                                            ang_18 = atan2(_e4963.y, _e4965.x);
                                                                            let _e4969 = ang_18;
                                                                            let _e4970 = offset_2;
                                                                            let _e4974 = N_11;
                                                                            let _e4977 = N_11;
                                                                            let _e4981 = offset_2;
                                                                            ang_18 = (((round((((_e4969 - _e4970) / 6.2831855f) * _e4974)) / _e4977) * 6.2831855f) + _e4981);
                                                                            let _e4985 = inverseTileTransform_2[0];
                                                                            let _e4990 = ang_18;
                                                                            let _e4993 = ang_18;
                                                                            dist_4 = ((length(_e4985.xy) * 0.5f) / max(abs(cos(_e4990)), abs(sin(_e4993))));
                                                                            let _e4999 = dist_4;
                                                                            let _e5000 = ang_18;
                                                                            let _e5002 = ang_18;
                                                                            v_4 = (_e4999 * vec2<f32>(cos(_e5000), sin(_e5002)));
                                                                            let _e5006 = inverseCurrentTransform_3;
                                                                            let _e5007 = relId_3;
                                                                            let _e5008 = v_4;
                                                                            let _e5013 = tf(_e5006, (_e5007 + (_e5008 + vec2(0.5f))));
                                                                            u_8 = _e5013;
                                                                            let _e5015 = u_8;
                                                                            let _e5019 = global.U[0];
                                                                            let _e5022 = u_8;
                                                                            let _e5031 = _mirror_wrap(((vec2<f32>((_e5015.x / _e5019.x), _e5022.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e5033 = textureSampleLevel(t_source, samp, _e5031, 0f);
                                                                            outCol = _e5033;
                                                                        }
                                                                    } else {
                                                                        let _e5034 = mode_4;
                                                                        if (_e5034 == 10i) {
                                                                            {
                                                                                let _e5039 = inverseTileTransform_2[0];
                                                                                s_5 = (length(_e5039.xy) * 0.05f);
                                                                                let _e5045 = v_4;
                                                                                v_4 = (_e5045 + vec2(0.5f));
                                                                                let _e5053 = inverseTileTransform_2[0];
                                                                                let _e5057 = inverseTileTransform_2[0];
                                                                                let _e5062 = N_12;
                                                                                let _e5067 = N_12;
                                                                                ang_19 = ((floor(((atan2(_e5053.y, _e5057.x) / 3.1415927f) * _e5062)) * 3.1415927f) / _e5067);
                                                                                let _e5070 = ang_19;
                                                                                let _e5071 = rotation2_(_e5070);
                                                                                let _e5072 = v_4;
                                                                                v_4 = (_e5071 * _e5072);
                                                                                let _e5074 = v_4;
                                                                                let _e5078 = inverseTileTransform_2[2];
                                                                                let _e5082 = tileTransform_2[0];
                                                                                let _e5090 = v_4;
                                                                                let _e5094 = inverseTileTransform_2[2];
                                                                                let _e5098 = tileTransform_2[0];
                                                                                let _e5105 = hslToRgb(vec4<f32>(((_e5074.x + (_e5078.x * length(_e5082.xy))) * 360f), 1f, (_e5090.y + (_e5094.y * length(_e5098.xy))), 1f));
                                                                                rgb_2 = _e5105;
                                                                                let _e5107 = _uv_3;
                                                                                let _e5111 = global.U[0];
                                                                                let _e5114 = _uv_3;
                                                                                let _e5123 = _mirror_wrap(((vec2<f32>((_e5107.x / _e5111.x), _e5114.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5125 = textureSampleLevel(t_source, samp, _e5123, 0f);
                                                                                inc_4 = _e5125;
                                                                                let _e5127 = inc_4;
                                                                                let _e5129 = rgb_2;
                                                                                dist_5 = length((_e5127.xyz - _e5129.xyz));
                                                                                let _e5137 = dist_5;
                                                                                let _e5139 = s_5;
                                                                                k_19 = (1f - (smoothstep(0f, 1.7f, _e5137) * _e5139));
                                                                                let _e5143 = inc_4;
                                                                                let _e5144 = rgb_2;
                                                                                let _e5145 = k_19;
                                                                                rgb_2 = mix(_e5143, _e5144, vec4(_e5145));
                                                                                let _e5148 = rgb_2;
                                                                                outCol = _e5148;
                                                                            }
                                                                        } else {
                                                                            let _e5149 = mode_4;
                                                                            if (_e5149 == 11i) {
                                                                                {
                                                                                    let _e5155 = inverseTileTransform_2[0];
                                                                                    N_13 = round((4f * abs(_e5155.x)));
                                                                                    let _e5162 = v_4;
                                                                                    let _e5166 = N_13;
                                                                                    let _e5169 = N_13;
                                                                                    let _e5176 = N_13;
                                                                                    center_10 = (vec2<f32>(0f, ((((floor(((_e5162.y + 0.5f) * _e5166)) / _e5169) * 2f) - 1f) + (1f / _e5176))) * 0.5f);
                                                                                    let _e5183 = v_4;
                                                                                    let _e5184 = center_10;
                                                                                    dv_4 = abs((_e5183 - _e5184));
                                                                                    let _e5188 = dv_4;
                                                                                    let _e5192 = dv_4;
                                                                                    let _e5195 = N_13;
                                                                                    if ((_e5188.x < 0.45f) && (_e5192.y < (0.4f / _e5195))) {
                                                                                        {
                                                                                            let _e5201 = inverseTileTransform_2[2];
                                                                                            s_6 = (_e5201.x + 1f);
                                                                                            let _e5206 = inverseCurrentTransform_3;
                                                                                            let _e5207 = relId_3;
                                                                                            let _e5208 = s_6;
                                                                                            let _e5218 = tf(_e5206, (_e5207 + ((_e5208 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_10 = _e5218;
                                                                                            let _e5220 = inverseCurrentTransform_3;
                                                                                            let _e5221 = relId_3;
                                                                                            let _e5222 = s_6;
                                                                                            let _e5231 = tf(_e5220, (_e5221 + ((_e5222 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_10 = _e5231;
                                                                                            let _e5233 = u1_10;
                                                                                            let _e5237 = global.U[0];
                                                                                            let _e5240 = u1_10;
                                                                                            let _e5249 = _mirror_wrap(((vec2<f32>((_e5233.x / _e5237.x), _e5240.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5251 = textureSampleLevel(t_source, samp, _e5249, 0f);
                                                                                            let _e5252 = u2_10;
                                                                                            let _e5256 = global.U[0];
                                                                                            let _e5259 = u2_10;
                                                                                            let _e5268 = _mirror_wrap(((vec2<f32>((_e5252.x / _e5256.x), _e5259.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5270 = textureSampleLevel(t_source, samp, _e5268, 0f);
                                                                                            let _e5271 = center_10;
                                                                                            outCol = mix(_e5251, _e5270, vec4((_e5271.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e5277 = mode_4;
                                                                                if (_e5277 == 12i) {
                                                                                    {
                                                                                        let _e5280 = v_4;
                                                                                        v_4 = (_e5280 * vec2<f32>(2f, 2f));
                                                                                        let _e5285 = inverseTileTransform_2;
                                                                                        let _e5286 = v_4;
                                                                                        let _e5287 = tf(_e5285, _e5286);
                                                                                        v_4 = _e5287;
                                                                                        let _e5288 = inverseCurrentTransform_3;
                                                                                        let _e5289 = relId_3;
                                                                                        let _e5290 = v_4;
                                                                                        let _e5295 = tf(_e5288, (_e5289 + (_e5290 + vec2(0.5f))));
                                                                                        let _e5299 = global.U[0];
                                                                                        let _e5302 = inverseCurrentTransform_3;
                                                                                        let _e5303 = relId_3;
                                                                                        let _e5304 = v_4;
                                                                                        let _e5309 = tf(_e5302, (_e5303 + (_e5304 + vec2(0.5f))));
                                                                                        let _e5318 = _mirror_wrap(((vec2<f32>((_e5295.x / _e5299.x), _e5309.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e5320 = textureSampleLevel(t_source, samp, _e5318, 0f);
                                                                                        outCol = _e5320;
                                                                                    }
                                                                                } else {
                                                                                    let _e5321 = mode_4;
                                                                                    if (_e5321 == 13i) {
                                                                                        {
                                                                                            let _e5324 = _uv_3;
                                                                                            let _e5328 = global.U[0];
                                                                                            let _e5331 = _uv_3;
                                                                                            let _e5340 = _mirror_wrap(((vec2<f32>((_e5324.x / _e5328.x), _e5331.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5342 = textureSampleLevel(t_source, samp, _e5340, 0f);
                                                                                            let _e5344 = luma(_e5342.xyz);
                                                                                            lum_6 = _e5344;
                                                                                            let _e5346 = inverseTileTransform_2;
                                                                                            let _e5347 = v_4;
                                                                                            let _e5352 = tf(_e5346, (_e5347 * vec2<f32>(8f, 8f)));
                                                                                            v_4 = _e5352;
                                                                                            let _e5353 = v_4;
                                                                                            let _e5356 = (_e5353.y + 1f);
                                                                                            y_2 = abs(((_e5356 - (floor((_e5356 / 2f)) * 2f)) - 1f));
                                                                                            let _e5366 = lum_6;
                                                                                            let _e5367 = y_2;
                                                                                            if (_e5366 > _e5367) {
                                                                                                local_22 = 1f;
                                                                                            } else {
                                                                                                local_22 = 0f;
                                                                                            }
                                                                                            let _e5372 = local_22;
                                                                                            k_20 = _e5372;
                                                                                            let _e5374 = k_20;
                                                                                            let _e5375 = vec3(_e5374);
                                                                                            outCol = vec4<f32>(_e5375.x, _e5375.y, _e5375.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e5381 = mode_4;
                                                                                        if (_e5381 == 14i) {
                                                                                            {
                                                                                                let _e5384 = id_2;
                                                                                                let _e5388 = global.U[0];
                                                                                                let _e5391 = id_2;
                                                                                                let _e5400 = _mirror_wrap(((vec2<f32>((_e5384.x / _e5388.x), _e5391.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e5402 = textureSampleLevel(t_source, samp, _e5400, 0f);
                                                                                                let _e5404 = luma(_e5402.xyz);
                                                                                                lum_7 = _e5404;
                                                                                                let _e5408 = tileTransform_2[0];
                                                                                                contrast_2 = length(_e5408.xy);
                                                                                                let _e5412 = v_4;
                                                                                                let _e5415 = (_e5412 + vec2(0.5f));
                                                                                                let _e5417 = contrast_2;
                                                                                                let _e5418 = lum_7;
                                                                                                outCol = vec4<f32>(_e5415.x, _e5415.y, (0.5f + (_e5417 * (_e5418 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e5427 = mode_4;
                                                                                            if (_e5427 == 15i) {
                                                                                                {
                                                                                                    let _e5430 = rnd_3;
                                                                                                    center_11 = (sign((_e5430 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e5438 = v_4;
                                                                                                    let _e5439 = center_11;
                                                                                                    dv_5 = (_e5438 - _e5439);
                                                                                                    let _e5445 = inverseTileTransform_2[0];
                                                                                                    N_14 = floor((16f * length(_e5445.xy)));
                                                                                                    let _e5453 = dv_5;
                                                                                                    let _e5455 = dv_5;
                                                                                                    let _e5458 = angOffset_2;
                                                                                                    ang_20 = (atan2(_e5453.y, _e5455.x) + _e5458);
                                                                                                    let _e5461 = ang_20;
                                                                                                    let _e5464 = N_14;
                                                                                                    let _e5467 = (((_e5461 / 3.1415927f) * _e5464) * 2f);
                                                                                                    k_21 = abs(((_e5467 - (floor((_e5467 / 2f)) * 2f)) - 1f));
                                                                                                    let _e5479 = inverseTileTransform_2[0];
                                                                                                    let _e5483 = inverseTileTransform_2[0];
                                                                                                    kCol_2 = (atan2(_e5479.y, _e5483.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e5493 = i_7;
                                                                                                        if !((_e5493 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e5500 = inverseCurrentTransform_3;
                                                                                                            let _e5501 = relId_3;
                                                                                                            let _e5504 = i_7;
                                                                                                            let _e5508 = ang_20;
                                                                                                            let _e5510 = ang_20;
                                                                                                            let _e5515 = tf(_e5500, (_e5501 + ((0.1f + (0.15f * f32(_e5504))) * vec2<f32>(cos(_e5508), sin(_e5510)))));
                                                                                                            w_11 = _e5515;
                                                                                                            let _e5517 = lum_8;
                                                                                                            let _e5518 = w_11;
                                                                                                            let _e5522 = global.U[0];
                                                                                                            let _e5525 = w_11;
                                                                                                            let _e5534 = _mirror_wrap(((vec2<f32>((_e5518.x / _e5522.x), _e5525.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5536 = textureSampleLevel(t_source, samp, _e5534, 0f);
                                                                                                            let _e5538 = luma(_e5536.xyz);
                                                                                                            lum_8 = (_e5517 + _e5538);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e5497 = i_7;
                                                                                                            i_7 = (_e5497 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e5540 = lum_8;
                                                                                                    lum_8 = (_e5540 / 5f);
                                                                                                    let _e5543 = lum_8;
                                                                                                    let _e5544 = k_21;
                                                                                                    if (_e5543 > _e5544) {
                                                                                                        local_23 = 1f;
                                                                                                    } else {
                                                                                                        local_23 = 0f;
                                                                                                    }
                                                                                                    let _e5549 = local_23;
                                                                                                    k_21 = _e5549;
                                                                                                    let _e5550 = kCol_2;
                                                                                                    if (_e5550 == 0f) {
                                                                                                        {
                                                                                                            let _e5553 = k_21;
                                                                                                            let _e5554 = vec3(_e5553);
                                                                                                            outCol = vec4<f32>(_e5554.x, _e5554.y, _e5554.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e5562 = inverseTileTransform_2[2];
                                                                                                            u1_11 = vec2<f32>(_e5562.x, 0f);
                                                                                                            let _e5570 = inverseTileTransform_2[2];
                                                                                                            u2_11 = vec2<f32>(0f, _e5570.y);
                                                                                                            let _e5574 = kCol_2;
                                                                                                            if (_e5574 > 0f) {
                                                                                                                {
                                                                                                                    let _e5577 = u1_11;
                                                                                                                    let _e5578 = id_2;
                                                                                                                    u1_11 = (_e5577 + _e5578);
                                                                                                                    let _e5580 = u2_11;
                                                                                                                    let _e5581 = id_2;
                                                                                                                    u2_11 = (_e5580 + (_e5581 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e5586 = u1_11;
                                                                                                            let _e5590 = global.U[0];
                                                                                                            let _e5593 = u1_11;
                                                                                                            let _e5602 = _mirror_wrap(((vec2<f32>((_e5586.x / _e5590.x), _e5593.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5604 = textureSampleLevel(t_source, samp, _e5602, 0f);
                                                                                                            col1_9 = _e5604;
                                                                                                            let _e5606 = u2_11;
                                                                                                            let _e5610 = global.U[0];
                                                                                                            let _e5613 = u2_11;
                                                                                                            let _e5622 = _mirror_wrap(((vec2<f32>((_e5606.x / _e5610.x), _e5613.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5624 = textureSampleLevel(t_source, samp, _e5622, 0f);
                                                                                                            col2_9 = _e5624;
                                                                                                            let _e5626 = col1_9;
                                                                                                            let _e5628 = luma(_e5626.xyz);
                                                                                                            let _e5629 = col2_9;
                                                                                                            let _e5631 = luma(_e5629.xyz);
                                                                                                            if (_e5628 > _e5631) {
                                                                                                                let _e5634 = k_21;
                                                                                                                k_21 = (1f - _e5634);
                                                                                                            }
                                                                                                            let _e5636 = k_21;
                                                                                                            let _e5637 = vec3(_e5636);
                                                                                                            outCol1_2 = vec4<f32>(_e5637.x, _e5637.y, _e5637.z, 1f);
                                                                                                            let _e5644 = col1_9;
                                                                                                            let _e5645 = col2_9;
                                                                                                            let _e5646 = k_21;
                                                                                                            outCol2_2 = mix(_e5644, _e5645, vec4(_e5646));
                                                                                                            let _e5650 = outCol1_2;
                                                                                                            let _e5651 = outCol2_2;
                                                                                                            let _e5652 = kCol_2;
                                                                                                            outCol = mix(_e5650, _e5651, vec4(abs(_e5652)));
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            let _e5656 = col;
            let _e5657 = outCol;
            let _e5658 = mergeColor(_e5656, _e5657);
            col = _e5658;
        }
    }
    let _e5659 = modelTransform_1;
    let _e5660 = overTransform_1;
    overTransform_1 = (_e5659 * _e5660);
    let _e5662 = overTransform_1;
    inverseUnderTransform = _naga_inverse_3x3_f32(_e5662);
    let _e5667 = inverseUnderTransform[0];
    startScale_5 = length(_e5667.xy);
    let _e5672 = overMode_1;
    if (_e5672 < 16i) {
        {
            loop {
                let _e5677 = i_8;
                if !((_e5677 < 4i)) {
                    break;
                }
                let _e5684 = i_8;
                let _e5686 = overMode_1;
                modeMap_1[_e5684] = _e5686;
                continuing {
                    let _e5681 = i_8;
                    i_8 = (_e5681 + 1i);
                }
            }
        }
    } else {
        {
            let _e5687 = overMode_1;
            overMode_1 = (_e5687 - 16i);
            let _e5692 = overMode_1;
            modeMap_1[0i] = (_e5692 & 15i);
            let _e5695 = overMode_1;
            overMode_1 = (_e5695 / 16i);
            let _e5700 = overMode_1;
            modeMap_1[1i] = (_e5700 & 15i);
            let _e5703 = overMode_1;
            overMode_1 = (_e5703 / 16i);
            let _e5708 = overMode_1;
            modeMap_1[2i] = (_e5708 & 15i);
            let _e5711 = overMode_1;
            overMode_1 = (_e5711 / 16i);
            let _e5716 = overMode_1;
            modeMap_1[3i] = (_e5716 & 15i);
        }
    }
    let _e5720 = inverseUnderTransform;
    params.transform = _e5720;
    let _e5722 = overTransform_1;
    params.inverseTransform = _e5722;
    let _e5724 = startScale_5;
    params.startScale = _e5724;
    let _e5726 = overLevels_1;
    params.subLevels = f32(_e5726);
    let _e5729 = overThreshold_1;
    params.subThreshold = _e5729;
    let _e5735 = modeMap_1[0];
    params.modeMap[0i] = _e5735;
    let _e5741 = modeMap_1[1];
    params.modeMap[1i] = _e5741;
    let _e5747 = modeMap_1[2];
    params.modeMap[2i] = _e5747;
    let _e5753 = modeMap_1[3];
    params.modeMap[3i] = _e5753;
    let _e5755 = overCoverage_1;
    params.coverage = _e5755;
    let _e5757 = overStreakCoverage_1;
    params.streakInterpolateCoverage = _e5757;
    let _e5759 = overStreakLevels_1;
    params.streakSubLevels = _e5759;
    let _e5761 = overStreakBalance_1;
    params.streakVerticality = ((_e5761 + 1f) * 0.5f);
    let _e5767 = overRandomSeed_1;
    params.seed = _e5767;
    let _e5769 = overRandomType_1;
    params.hashStyle = _e5769;
    {
        let _e5770 = pos_1;
        _uv_4 = _e5770;
        let _e5772 = params;
        _params_1 = _e5772;
        let _e5777 = _params_1;
        startScale_6 = _e5777.startScale;
        let _e5780 = _params_1;
        subLevels_4 = _e5780.subLevels;
        let _e5783 = _params_1;
        subThreshold_4 = _e5783.subThreshold;
        let _e5786 = _params_1;
        streakInterpolateCoverage_1 = _e5786.streakInterpolateCoverage;
        let _e5789 = _params_1;
        streakSubLevels_1 = _e5789.streakSubLevels;
        let _e5792 = _params_1;
        streakVerticality_1 = _e5792.streakVerticality;
        let _e5795 = _params_1;
        seed_4 = _e5795.seed;
        let _e5798 = _params_1;
        hashStyle_6 = _e5798.hashStyle;
        let _e5801 = _params_1;
        currentTransform_4 = _e5801.transform;
        let _e5804 = _params_1;
        inverseCurrentTransform_4 = _e5804.inverseTransform;
        loop {
            let _e5814 = i_9;
            let _e5815 = streakSubLevels_1;
            if !((_e5814 < f32(_e5815))) {
                break;
            }
            {
                let _e5822 = i_9;
                if (_e5822 != 0f) {
                    {
                        let _e5838 = currentTransform_4;
                        currentTransform_4 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e5838);
                        let _e5840 = inverseCurrentTransform_4;
                        inverseCurrentTransform_4 = (_e5840 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                    }
                }
                let _e5855 = currentTransform_4;
                let _e5856 = _uv_4;
                let _e5857 = tf(_e5855, _e5856);
                relId_4 = floor(_e5857);
                let _e5859 = relId_4;
                let _e5861 = (_e5859 * 0.08845f);
                let _e5862 = i_9;
                let _e5863 = seed_4;
                let _e5867 = hashStyle_6;
                let _e5868 = hash42sp(vec4<f32>(_e5861.x, _e5861.y, _e5862, _e5863), _e5867);
                rnd_4 = _e5868;
                let _e5869 = rnd_4;
                let _e5871 = subThreshold_4;
                if (_e5869.x > _e5871) {
                    {
                        break;
                    }
                }
                let _e5873 = streakLevel_1;
                streakLevel_1 = (_e5873 + 1i);
            }
            continuing {
                let _e5819 = i_9;
                i_9 = (_e5819 + 1f);
            }
        }
        let _e5876 = rnd_4;
        let _e5878 = streakInterpolateCoverage_1;
        if (_e5876.y <= _e5878) {
            {
                let _e5883 = currentTransform_4;
                let _e5884 = _uv_4;
                let _e5885 = tf(_e5883, _e5884);
                let _e5886 = relId_4;
                v_5 = (_e5885 - _e5886);
                let _e5888 = rnd_4;
                let _e5893 = streakVerticality_1;
                if (fract((_e5888.y * 13.323f)) < _e5893) {
                    {
                        let _e5895 = v_5;
                        k_22 = _e5895.y;
                        let _e5897 = inverseCurrentTransform_4;
                        let _e5898 = relId_4;
                        let _e5899 = v_5;
                        let _e5905 = tf(_e5897, (_e5898 + vec2<f32>(_e5899.x, -0.0001f)));
                        uu1_1 = _e5905;
                        let _e5906 = inverseCurrentTransform_4;
                        let _e5907 = relId_4;
                        let _e5908 = v_5;
                        let _e5913 = tf(_e5906, (_e5907 + vec2<f32>(_e5908.x, 0.9999f)));
                        uu2_1 = _e5913;
                    }
                } else {
                    {
                        let _e5914 = v_5;
                        k_22 = _e5914.x;
                        let _e5916 = inverseCurrentTransform_4;
                        let _e5917 = relId_4;
                        let _e5920 = v_5;
                        let _e5924 = tf(_e5916, (_e5917 + vec2<f32>(-0.0001f, _e5920.y)));
                        uu1_1 = _e5924;
                        let _e5925 = inverseCurrentTransform_4;
                        let _e5926 = relId_4;
                        let _e5928 = v_5;
                        let _e5932 = tf(_e5925, (_e5926 + vec2<f32>(0.9999f, _e5928.y)));
                        uu2_1 = _e5932;
                    }
                }
                let _e5933 = uu1_1;
                let _e5937 = global.U[0];
                let _e5940 = uu1_1;
                let _e5949 = _mirror_wrap(((vec2<f32>((_e5933.x / _e5937.x), _e5940.y) / vec2(2f)) + vec2(0.5f)));
                let _e5951 = textureSampleLevel(t_source, samp, _e5949, 0f);
                src1_1 = _e5951;
                let _e5953 = uu2_1;
                let _e5957 = global.U[0];
                let _e5960 = uu2_1;
                let _e5969 = _mirror_wrap(((vec2<f32>((_e5953.x / _e5957.x), _e5960.y) / vec2(2f)) + vec2(0.5f)));
                let _e5971 = textureSampleLevel(t_source, samp, _e5969, 0f);
                src2_1 = _e5971;
                {
                    let _e5973 = uu1_1;
                    _uv_5 = _e5973;
                    let _e5975 = _params_1;
                    startScale_7 = _e5975.startScale;
                    let _e5978 = _params_1;
                    subLevels_5 = _e5978.subLevels;
                    let _e5981 = _params_1;
                    subThreshold_5 = _e5981.subThreshold;
                    let _e5984 = _params_1;
                    seed_5 = _e5984.seed;
                    let _e5987 = _params_1;
                    hashStyle_7 = _e5987.hashStyle;
                    let _e5990 = _params_1;
                    coverage_5 = _e5990.coverage;
                    let _e5993 = _params_1;
                    currentTransform_5 = _e5993.transform;
                    let _e5996 = _params_1;
                    inverseCurrentTransform_5 = _e5996.inverseTransform;
                    let _e5999 = startScale_7;
                    scale_6 = _e5999;
                    loop {
                        let _e6007 = i_10;
                        let _e6008 = subLevels_5;
                        if !((_e6007 < _e6008)) {
                            break;
                        }
                        {
                            let _e6014 = i_10;
                            if (_e6014 != 0f) {
                                {
                                    let _e6030 = currentTransform_5;
                                    currentTransform_5 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e6030);
                                    let _e6032 = inverseCurrentTransform_5;
                                    inverseCurrentTransform_5 = (_e6032 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e6047 = currentTransform_5;
                            let _e6048 = _uv_5;
                            let _e6049 = tf(_e6047, _e6048);
                            relId_5 = floor(_e6049);
                            let _e6051 = relId_5;
                            let _e6053 = (_e6051 * 0.13137f);
                            let _e6054 = i_10;
                            let _e6055 = seed_5;
                            let _e6059 = hashStyle_7;
                            let _e6060 = hash42sp(vec4<f32>(_e6053.x, _e6053.y, _e6054, _e6055), _e6059);
                            rnd_5 = _e6060;
                            let _e6061 = i_10;
                            let _e6062 = subLevels_5;
                            let _e6066 = rnd_5;
                            let _e6068 = subThreshold_5;
                            if ((_e6061 == (_e6062 - 1f)) || (_e6066.x > _e6068)) {
                                {
                                    break;
                                }
                            }
                            let _e6071 = scale_6;
                            scale_6 = (_e6071 * 2f);
                        }
                        continuing {
                            let _e6011 = i_10;
                            i_10 = (_e6011 + 1f);
                        }
                    }
                    let _e6074 = inverseCurrentTransform_5;
                    let _e6075 = relId_5;
                    let _e6076 = tf(_e6074, _e6075);
                    id_3 = _e6076;
                    let _e6078 = rnd_5;
                    modeIndex_3 = i32(floor((_e6078.y * 4f)));
                    let _e6085 = modeIndex_3;
                    let _e6088 = _params_1.modeMap[_e6085];
                    mode_5 = _e6088;
                    let _e6091 = modeIndex_3;
                    if (_e6091 == 0i) {
                        let _e6094 = tileTransform1_1;
                        tileTransform_3 = _e6094;
                    } else {
                        let _e6095 = modeIndex_3;
                        if (_e6095 == 1i) {
                            let _e6098 = tileTransform2_1;
                            tileTransform_3 = _e6098;
                        } else {
                            let _e6099 = modeIndex_3;
                            if (_e6099 == 2i) {
                                let _e6102 = tileTransform3_1;
                                tileTransform_3 = _e6102;
                            } else {
                                let _e6103 = tileTransform4_1;
                                tileTransform_3 = _e6103;
                            }
                        }
                    }
                    let _e6104 = tileTransform_3;
                    inverseTileTransform_3 = _naga_inverse_3x3_f32(_e6104);
                    let _e6107 = currentTransform_5;
                    let _e6108 = _uv_5;
                    let _e6109 = tf(_e6107, _e6108);
                    let _e6110 = relId_5;
                    v_6 = ((_e6109 - _e6110) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e6117 = rnd_5;
                    let _e6121 = rnd_5;
                    let _e6127 = coverage_5;
                    if (fract(((_e6117.x * 6.222f) + (_e6121.y * 8.233f))) <= _e6127) {
                        {
                            let _e6129 = mode_5;
                            if (_e6129 == 0i) {
                                {
                                    let _e6134 = inverseTileTransform_3[0];
                                    w_12 = _e6134.xy;
                                    let _e6137 = w_12;
                                    let _e6141 = w_12;
                                    w_12 = floor(vec2<f32>(dot(_e6137, vec2(20f)), dot(_e6141, vec2<f32>(20f, -20f))));
                                    let _e6149 = relId_5;
                                    let _e6151 = v_6;
                                    let _e6152 = w_12;
                                    let _e6157 = tileTransform_3[0];
                                    let _e6164 = inverseTileTransform_3[2];
                                    let _e6167 = w_12;
                                    pixId_6 = (_e6149 + (1.23f * (floor((_e6151 * _e6152)) + floor((((length(_e6157.xy) * 5f) * _e6164.xy) * _e6167)))));
                                    let _e6174 = pixId_6;
                                    let _e6175 = hash22_(_e6174);
                                    let _e6179 = global.U[0];
                                    let _e6182 = pixId_6;
                                    let _e6183 = hash22_(_e6182);
                                    let _e6192 = _mirror_wrap(((vec2<f32>((_e6175.x / _e6179.x), _e6183.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e6194 = textureSampleLevel(t_source, samp, _e6192, 0f);
                                    outCol = _e6194;
                                }
                            } else {
                                let _e6195 = mode_5;
                                if (_e6195 == 1i) {
                                    {
                                        let _e6199 = v_6;
                                        let _e6202 = v_6;
                                        v_6 = vec2<f32>(0f, max(abs(_e6199.x), abs(_e6202.y)));
                                        let _e6207 = inverseCurrentTransform_5;
                                        let _e6208 = relId_5;
                                        let _e6209 = inverseTileTransform_3;
                                        let _e6210 = v_6;
                                        let _e6211 = tf(_e6209, _e6210);
                                        let _e6216 = tf(_e6207, (_e6208 + (_e6211 + vec2(0.5f))));
                                        vv_6 = _e6216;
                                        let _e6218 = vv_6;
                                        let _e6222 = global.U[0];
                                        let _e6225 = vv_6;
                                        let _e6234 = _mirror_wrap(((vec2<f32>((_e6218.x / _e6222.x), _e6225.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e6236 = textureSampleLevel(t_source, samp, _e6234, 0f);
                                        outCol = _e6236;
                                    }
                                } else {
                                    let _e6237 = mode_5;
                                    if (_e6237 == 2i) {
                                        {
                                            let _e6243 = inverseTileTransform_3[2];
                                            size_9 = (0.5f + _e6243.y);
                                            let _e6247 = v_6;
                                            d_6 = length(_e6247);
                                            let _e6250 = v_6;
                                            let _e6252 = v_6;
                                            ang_21 = atan2(_e6250.y, _e6252.x);
                                            let _e6256 = d_6;
                                            let _e6257 = size_9;
                                            if (_e6256 <= _e6257) {
                                                {
                                                    let _e6262 = spikeCount_3;
                                                    anglePeriod_3 = (6.2831855f / _e6262);
                                                    let _e6265 = ang_21;
                                                    let _e6266 = anglePeriod_3;
                                                    let _e6269 = anglePeriod_3;
                                                    a1_3 = (floor((_e6265 / _e6266)) * _e6269);
                                                    let _e6272 = a1_3;
                                                    let _e6273 = anglePeriod_3;
                                                    a2_3 = (_e6272 + _e6273);
                                                    let _e6276 = ang_21;
                                                    let _e6277 = a1_3;
                                                    let _e6279 = anglePeriod_3;
                                                    k_23 = ((_e6276 - _e6277) / _e6279);
                                                    let _e6282 = d_6;
                                                    let _e6287 = inverseTileTransform_3[0];
                                                    ds_6 = ((_e6282 * 10f) * length(_e6287.xy));
                                                    let _e6292 = relId_5;
                                                    center_12 = (_e6292 + vec2(0.5f));
                                                    let _e6297 = inverseCurrentTransform_5;
                                                    let _e6298 = center_12;
                                                    let _e6299 = ds_6;
                                                    let _e6300 = a1_3;
                                                    let _e6302 = a1_3;
                                                    let _e6309 = inverseTileTransform_3[2];
                                                    let _e6313 = tf(_e6297, ((_e6298 + (_e6299 * vec2<f32>(cos(_e6300), sin(_e6302)))) + vec2(_e6309.x)));
                                                    u1_12 = _e6313;
                                                    let _e6315 = inverseCurrentTransform_5;
                                                    let _e6316 = center_12;
                                                    let _e6317 = ds_6;
                                                    let _e6318 = a2_3;
                                                    let _e6320 = a2_3;
                                                    let _e6327 = inverseTileTransform_3[2];
                                                    let _e6331 = tf(_e6315, ((_e6316 + (_e6317 * vec2<f32>(cos(_e6318), sin(_e6320)))) + vec2(_e6327.x)));
                                                    u2_12 = _e6331;
                                                    let _e6333 = u1_12;
                                                    let _e6337 = global.U[0];
                                                    let _e6340 = u1_12;
                                                    let _e6349 = _mirror_wrap(((vec2<f32>((_e6333.x / _e6337.x), _e6340.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e6351 = textureSampleLevel(t_source, samp, _e6349, 0f);
                                                    col1_10 = _e6351;
                                                    let _e6353 = u2_12;
                                                    let _e6357 = global.U[0];
                                                    let _e6360 = u2_12;
                                                    let _e6369 = _mirror_wrap(((vec2<f32>((_e6353.x / _e6357.x), _e6360.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e6371 = textureSampleLevel(t_source, samp, _e6369, 0f);
                                                    col2_10 = _e6371;
                                                    let _e6373 = col1_10;
                                                    let _e6374 = col2_10;
                                                    let _e6375 = k_23;
                                                    outCol = mix(_e6373, _e6374, vec4(_e6375));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e6378 = mode_5;
                                        if (_e6378 == 3i) {
                                            {
                                                let _e6381 = v_6;
                                                let _e6384 = v_6;
                                                vert_3 = (abs(_e6381.y) > abs(_e6384.x));
                                                let _e6389 = vert_3;
                                                if _e6389 {
                                                    let _e6390 = v_6;
                                                    local_24 = _e6390.y;
                                                } else {
                                                    let _e6392 = v_6;
                                                    local_24 = _e6392.x;
                                                }
                                                let _e6395 = local_24;
                                                a_3 = _e6395;
                                                let _e6397 = vert_3;
                                                if _e6397 {
                                                    let _e6398 = a_3;
                                                    let _e6400 = a_3;
                                                    local_25 = vec2<f32>(-(_e6398), _e6400);
                                                } else {
                                                    let _e6402 = a_3;
                                                    let _e6403 = a_3;
                                                    local_25 = vec2<f32>(_e6402, -(_e6403));
                                                }
                                                let _e6407 = local_25;
                                                u1_13 = _e6407;
                                                let _e6409 = a_3;
                                                let _e6410 = a_3;
                                                u2_13 = vec2<f32>(_e6409, _e6410);
                                                let _e6413 = v_6;
                                                let _e6415 = v_6;
                                                let _e6419 = a_3;
                                                k_24 = ((_e6413.x + _e6415.y) / (2f * _e6419));
                                                let _e6423 = inverseCurrentTransform_5;
                                                let _e6424 = relId_5;
                                                let _e6425 = inverseTileTransform_3;
                                                let _e6426 = u1_13;
                                                let _e6427 = tf(_e6425, _e6426);
                                                let _e6432 = tf(_e6423, (_e6424 + (_e6427 + vec2(0.5f))));
                                                u1_13 = _e6432;
                                                let _e6433 = inverseCurrentTransform_5;
                                                let _e6434 = relId_5;
                                                let _e6435 = inverseTileTransform_3;
                                                let _e6436 = u2_13;
                                                let _e6437 = tf(_e6435, _e6436);
                                                let _e6442 = tf(_e6433, (_e6434 + (_e6437 + vec2(0.5f))));
                                                u2_13 = _e6442;
                                                let _e6443 = u1_13;
                                                let _e6447 = global.U[0];
                                                let _e6450 = u1_13;
                                                let _e6459 = _mirror_wrap(((vec2<f32>((_e6443.x / _e6447.x), _e6450.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e6461 = textureSampleLevel(t_source, samp, _e6459, 0f);
                                                col1_11 = _e6461;
                                                let _e6463 = u2_13;
                                                let _e6467 = global.U[0];
                                                let _e6470 = u2_13;
                                                let _e6479 = _mirror_wrap(((vec2<f32>((_e6463.x / _e6467.x), _e6470.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e6481 = textureSampleLevel(t_source, samp, _e6479, 0f);
                                                col2_11 = _e6481;
                                                let _e6483 = col1_11;
                                                let _e6484 = col2_11;
                                                let _e6485 = k_24;
                                                outCol = mix(_e6483, _e6484, vec4(_e6485));
                                            }
                                        } else {
                                            let _e6488 = mode_5;
                                            if (_e6488 == 4i) {
                                                {
                                                    let _e6495 = inverseTileTransform_3[0];
                                                    let _e6499 = inverseTileTransform_3[0];
                                                    ang_22 = atan2(_e6495.y, _e6499.x);
                                                    let _e6503 = ang_22;
                                                    if (_e6503 < 0f) {
                                                        let _e6506 = relId_5;
                                                        let _e6508 = relId_5;
                                                        let _e6510 = (_e6506.x + _e6508.y);
                                                        local_26 = sign(((_e6510 - (floor((_e6510 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_26 = 1f;
                                                    }
                                                    let _e6521 = local_26;
                                                    orientation_3 = _e6521;
                                                    let _e6523 = rnd_5;
                                                    let _e6525 = ang_22;
                                                    if (_e6523.y > (abs(_e6525) / 3.1415927f)) {
                                                        let _e6530 = orientation_3;
                                                        orientation_3 = -(_e6530);
                                                    }
                                                    let _e6532 = orientation_3;
                                                    let _e6533 = v_6;
                                                    let _e6536 = v_6;
                                                    if (((_e6532 * _e6533.x) * _e6536.y) < 0f) {
                                                        local_27 = 40f;
                                                    } else {
                                                        local_27 = 2.5f;
                                                    }
                                                    let _e6544 = local_27;
                                                    p_8 = _e6544;
                                                    let _e6546 = p_8;
                                                    if (_e6546 > 30f) {
                                                        let _e6549 = v_6;
                                                        let _e6552 = v_6;
                                                        local_28 = max(abs(_e6549.x), abs(_e6552.y));
                                                    } else {
                                                        let _e6556 = v_6;
                                                        let _e6559 = p_8;
                                                        let _e6561 = v_6;
                                                        let _e6564 = p_8;
                                                        let _e6568 = p_8;
                                                        local_28 = pow((pow(abs(_e6556.x), _e6559) + pow(abs(_e6561.y), _e6564)), (1f / _e6568));
                                                    }
                                                    let _e6572 = local_28;
                                                    d_7 = _e6572;
                                                    let _e6575 = d_7;
                                                    v_6 = vec2<f32>(0f, _e6575);
                                                    let _e6577 = v_6;
                                                    let _e6579 = size_10;
                                                    if (_e6577.y <= _e6579) {
                                                        {
                                                            let _e6581 = inverseCurrentTransform_5;
                                                            let _e6582 = relId_5;
                                                            let _e6583 = inverseTileTransform_3;
                                                            let _e6584 = v_6;
                                                            let _e6585 = tf(_e6583, _e6584);
                                                            let _e6590 = tf(_e6581, (_e6582 + (_e6585 + vec2(0.5f))));
                                                            vv_7 = _e6590;
                                                            let _e6592 = vv_7;
                                                            let _e6596 = global.U[0];
                                                            let _e6599 = vv_7;
                                                            let _e6608 = _mirror_wrap(((vec2<f32>((_e6592.x / _e6596.x), _e6599.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e6610 = textureSampleLevel(t_source, samp, _e6608, 0f);
                                                            outCol = _e6610;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e6611 = mode_5;
                                                if (_e6611 <= 6i) {
                                                    {
                                                        let _e6616 = inverseTileTransform_3[0];
                                                        scale_7 = length(_e6616.xy);
                                                        let _e6620 = scale_7;
                                                        invert_3 = (_e6620 < 1f);
                                                        let _e6624 = invert_3;
                                                        if _e6624 {
                                                            let _e6626 = scale_7;
                                                            scale_7 = (1f / _e6626);
                                                        }
                                                        let _e6628 = scale_7;
                                                        ds_7 = fract(_e6628);
                                                        let _e6631 = scale_7;
                                                        N_15 = max(floor(_e6631), 1f);
                                                        let _e6636 = v_6;
                                                        let _e6640 = N_15;
                                                        w_13 = (fract(((_e6636 + vec2(0.5f)) * _e6640)) - vec2(0.5f));
                                                        let _e6647 = v_6;
                                                        let _e6651 = N_15;
                                                        let _e6654 = N_15;
                                                        let _e6663 = N_15;
                                                        center_13 = ((((floor(((_e6647 + vec2(0.5f)) * _e6651)) / vec2(_e6654)) * 2f) - vec2(1f)) + vec2((1f / _e6663)));
                                                        let _e6670 = inverseTileTransform_3[0];
                                                        let _e6674 = inverseTileTransform_3[0];
                                                        ang_23 = atan2(_e6670.y, _e6674.x);
                                                        let _e6682 = ang_23;
                                                        if (_e6682 > 0f) {
                                                            let _e6686 = ang_23;
                                                            keepX_3 = (1f - (_e6686 / 3.1415927f));
                                                        } else {
                                                            let _e6691 = ang_23;
                                                            keepY_3 = (1f + (_e6691 / 3.1415927f));
                                                        }
                                                        let _e6695 = center_13;
                                                        let _e6698 = keepX_3;
                                                        let _e6700 = center_13;
                                                        let _e6703 = keepY_3;
                                                        hide_3 = ((abs(_e6695.x) > _e6698) || (abs(_e6700.y) > _e6703));
                                                        let _e6709 = ds_7;
                                                        size_11 = mix(0.5f, 0.15f, _e6709);
                                                        let _e6712 = mode_5;
                                                        let _e6715 = w_13;
                                                        let _e6717 = size_11;
                                                        let _e6720 = mode_5;
                                                        let _e6723 = w_13;
                                                        let _e6726 = size_11;
                                                        let _e6728 = w_13;
                                                        let _e6731 = size_11;
                                                        outside_3 = (((_e6712 == 6i) && (length(_e6715) > _e6717)) || ((_e6720 == 5i) && ((abs(_e6723.x) > _e6726) || (abs(_e6728.y) > _e6731))));
                                                        let _e6737 = hide_3;
                                                        let _e6738 = outside_3;
                                                        if !((_e6737 || _e6738)) {
                                                            {
                                                                let _e6741 = id_3;
                                                                let _e6744 = inverseTileTransform_3[2];
                                                                let _e6750 = global.U[0];
                                                                let _e6753 = id_3;
                                                                let _e6756 = inverseTileTransform_3[2];
                                                                let _e6767 = _mirror_wrap(((vec2<f32>(((_e6741 + _e6744.xy).x / _e6750.x), (_e6753 + _e6756.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e6769 = textureSampleLevel(t_source, samp, _e6767, 0f);
                                                                outCol = _e6769;
                                                            }
                                                        } else {
                                                            let _e6770 = invert_3;
                                                            if _e6770 {
                                                                {
                                                                    let _e6771 = id_3;
                                                                    let _e6775 = global.U[0];
                                                                    let _e6778 = id_3;
                                                                    let _e6787 = _mirror_wrap(((vec2<f32>((_e6771.x / _e6775.x), _e6778.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e6789 = textureSampleLevel(t_source, samp, _e6787, 0f);
                                                                    outCol = _e6789;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e6790 = mode_5;
                                                    if (_e6790 == 7i) {
                                                        {
                                                            let _e6795 = inverseTileTransform_3[0];
                                                            w_14 = _e6795.xy;
                                                            let _e6798 = w_14;
                                                            let _e6802 = w_14;
                                                            w_14 = floor(vec2<f32>(dot(_e6798, vec2(16f)), dot(_e6802, vec2<f32>(16f, -16f))));
                                                            let _e6810 = startScale_7;
                                                            let _e6817 = inverseTileTransform_3[2];
                                                            minScale_3 = ((_e6810 * 2f) * pow(2f, floor((2f * _e6817.y))));
                                                            let _e6824 = minScale_3;
                                                            let _e6825 = startScale_7;
                                                            let _e6832 = inverseTileTransform_3[2];
                                                            maxScale_3 = max(_e6824, ((_e6825 * 4f) * pow(2f, floor((2f * _e6832.x)))));
                                                            let _e6840 = scale_6;
                                                            let _e6841 = minScale_3;
                                                            let _e6842 = maxScale_3;
                                                            scale2_6 = clamp(_e6840, _e6841, _e6842);
                                                            let _e6845 = scale2_6;
                                                            let _e6846 = scale_6;
                                                            invScaleRatio_6 = (_e6845 / _e6846);
                                                            let _e6849 = invScaleRatio_6;
                                                            let _e6853 = invScaleRatio_6;
                                                            let _e6862 = currentTransform_5;
                                                            tr_6 = (mat3x3<f32>(vec3<f32>(_e6849, 0f, 0f), vec3<f32>(0f, _e6853, 0f), vec3<f32>(0f, 0f, 1f)) * _e6862);
                                                            let _e6865 = tr_6;
                                                            let _e6866 = _uv_5;
                                                            let _e6867 = tf(_e6865, _e6866);
                                                            v_6 = (_e6867 - vec2(0.5f));
                                                            let _e6871 = v_6;
                                                            let _e6872 = w_14;
                                                            pixId_7 = floor((_e6871 * _e6872));
                                                            let _e6876 = pixId_7;
                                                            let _e6878 = pixId_7;
                                                            let _e6880 = (_e6876.x + _e6878.y);
                                                            k_25 = (_e6880 - (floor((_e6880 / 2f)) * 2f));
                                                            let _e6887 = k_25;
                                                            let _e6888 = vec3(_e6887);
                                                            outCol = vec4<f32>(_e6888.x, _e6888.y, _e6888.z, 1f);
                                                        }
                                                    } else {
                                                        let _e6894 = mode_5;
                                                        if (_e6894 == 8i) {
                                                            {
                                                                let _e6899 = startScale_7;
                                                                scale2_7 = (_e6899 * 4f);
                                                                let _e6903 = scale2_7;
                                                                let _e6904 = scale_6;
                                                                invScaleRatio_7 = (_e6903 / _e6904);
                                                                let _e6907 = invScaleRatio_7;
                                                                let _e6911 = invScaleRatio_7;
                                                                let _e6920 = currentTransform_5;
                                                                tr_7 = (mat3x3<f32>(vec3<f32>(_e6907, 0f, 0f), vec3<f32>(0f, _e6911, 0f), vec3<f32>(0f, 0f, 1f)) * _e6920);
                                                                let _e6923 = tr_7;
                                                                let _e6924 = _uv_5;
                                                                let _e6925 = tf(_e6923, _e6924);
                                                                v_6 = (_e6925 - vec2(0.5f));
                                                                let _e6935 = inverseTileTransform_3[0];
                                                                let _e6939 = inverseTileTransform_3[0];
                                                                let _e6942 = piN_3;
                                                                let _e6945 = piN_3;
                                                                ang_24 = (floor((atan2(_e6935.y, _e6939.x) / _e6942)) * _e6945);
                                                                let _e6948 = ang_24;
                                                                let _e6949 = rotation2_(_e6948);
                                                                let _e6950 = v_6;
                                                                let _e6954 = inverseTileTransform_3[0];
                                                                let _e6961 = inverseTileTransform_3[2];
                                                                v_6 = (((_e6949 * _e6950) * length(_e6954.xy)) + (2f * _e6961.xy));
                                                                let _e6965 = v_6;
                                                                let _e6967 = v_6;
                                                                let _e6969 = rnd_5;
                                                                let _e6976 = Xn_3;
                                                                let _e6978 = floor(((_e6965.x + (_e6967.y * sign((_e6969.y - 0.5f)))) * _e6976));
                                                                k_26 = (_e6978 - (floor((_e6978 / 2f)) * 2f));
                                                                let _e6985 = k_26;
                                                                let _e6986 = vec3(_e6985);
                                                                outCol = vec4<f32>(_e6986.x, _e6986.y, _e6986.z, 1f);
                                                            }
                                                        } else {
                                                            let _e6992 = mode_5;
                                                            if (_e6992 == 9i) {
                                                                {
                                                                    let _e6999 = inverseTileTransform_3[2];
                                                                    N_16 = floor((1000f * pow(0.25f, length(_e6999.xy))));
                                                                    let _e7010 = N_16;
                                                                    let _e7015 = inverseTileTransform_3[1];
                                                                    let _e7019 = inverseTileTransform_3[1];
                                                                    offset_3 = ((1.5707964f + (3.1415927f / _e7010)) + atan2(_e7015.y, _e7019.x));
                                                                    let _e7024 = v_6;
                                                                    let _e7026 = v_6;
                                                                    ang_25 = atan2(_e7024.y, _e7026.x);
                                                                    let _e7030 = ang_25;
                                                                    let _e7031 = offset_3;
                                                                    let _e7035 = N_16;
                                                                    let _e7038 = N_16;
                                                                    let _e7042 = offset_3;
                                                                    ang_25 = (((round((((_e7030 - _e7031) / 6.2831855f) * _e7035)) / _e7038) * 6.2831855f) + _e7042);
                                                                    let _e7046 = inverseTileTransform_3[0];
                                                                    let _e7051 = ang_25;
                                                                    let _e7054 = ang_25;
                                                                    dist_6 = ((length(_e7046.xy) * 0.5f) / max(abs(cos(_e7051)), abs(sin(_e7054))));
                                                                    let _e7060 = dist_6;
                                                                    let _e7061 = ang_25;
                                                                    let _e7063 = ang_25;
                                                                    v_6 = (_e7060 * vec2<f32>(cos(_e7061), sin(_e7063)));
                                                                    let _e7067 = inverseCurrentTransform_5;
                                                                    let _e7068 = relId_5;
                                                                    let _e7069 = v_6;
                                                                    let _e7074 = tf(_e7067, (_e7068 + (_e7069 + vec2(0.5f))));
                                                                    u_9 = _e7074;
                                                                    let _e7076 = u_9;
                                                                    let _e7080 = global.U[0];
                                                                    let _e7083 = u_9;
                                                                    let _e7092 = _mirror_wrap(((vec2<f32>((_e7076.x / _e7080.x), _e7083.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e7094 = textureSampleLevel(t_source, samp, _e7092, 0f);
                                                                    outCol = _e7094;
                                                                }
                                                            } else {
                                                                let _e7095 = mode_5;
                                                                if (_e7095 == 10i) {
                                                                    {
                                                                        let _e7100 = inverseTileTransform_3[0];
                                                                        s_7 = (length(_e7100.xy) * 0.05f);
                                                                        let _e7106 = v_6;
                                                                        v_6 = (_e7106 + vec2(0.5f));
                                                                        let _e7114 = inverseTileTransform_3[0];
                                                                        let _e7118 = inverseTileTransform_3[0];
                                                                        let _e7123 = N_17;
                                                                        let _e7128 = N_17;
                                                                        ang_26 = ((floor(((atan2(_e7114.y, _e7118.x) / 3.1415927f) * _e7123)) * 3.1415927f) / _e7128);
                                                                        let _e7131 = ang_26;
                                                                        let _e7132 = rotation2_(_e7131);
                                                                        let _e7133 = v_6;
                                                                        v_6 = (_e7132 * _e7133);
                                                                        let _e7135 = v_6;
                                                                        let _e7139 = inverseTileTransform_3[2];
                                                                        let _e7143 = tileTransform_3[0];
                                                                        let _e7151 = v_6;
                                                                        let _e7155 = inverseTileTransform_3[2];
                                                                        let _e7159 = tileTransform_3[0];
                                                                        let _e7166 = hslToRgb(vec4<f32>(((_e7135.x + (_e7139.x * length(_e7143.xy))) * 360f), 1f, (_e7151.y + (_e7155.y * length(_e7159.xy))), 1f));
                                                                        rgb_3 = _e7166;
                                                                        let _e7168 = _uv_5;
                                                                        let _e7172 = global.U[0];
                                                                        let _e7175 = _uv_5;
                                                                        let _e7184 = _mirror_wrap(((vec2<f32>((_e7168.x / _e7172.x), _e7175.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e7186 = textureSampleLevel(t_source, samp, _e7184, 0f);
                                                                        inc_5 = _e7186;
                                                                        let _e7188 = inc_5;
                                                                        let _e7190 = rgb_3;
                                                                        dist_7 = length((_e7188.xyz - _e7190.xyz));
                                                                        let _e7198 = dist_7;
                                                                        let _e7200 = s_7;
                                                                        k_27 = (1f - (smoothstep(0f, 1.7f, _e7198) * _e7200));
                                                                        let _e7204 = inc_5;
                                                                        let _e7205 = rgb_3;
                                                                        let _e7206 = k_27;
                                                                        rgb_3 = mix(_e7204, _e7205, vec4(_e7206));
                                                                        let _e7209 = rgb_3;
                                                                        outCol = _e7209;
                                                                    }
                                                                } else {
                                                                    let _e7210 = mode_5;
                                                                    if (_e7210 == 11i) {
                                                                        {
                                                                            let _e7216 = inverseTileTransform_3[0];
                                                                            N_18 = round((4f * abs(_e7216.x)));
                                                                            let _e7223 = v_6;
                                                                            let _e7227 = N_18;
                                                                            let _e7230 = N_18;
                                                                            let _e7237 = N_18;
                                                                            center_14 = (vec2<f32>(0f, ((((floor(((_e7223.y + 0.5f) * _e7227)) / _e7230) * 2f) - 1f) + (1f / _e7237))) * 0.5f);
                                                                            let _e7244 = v_6;
                                                                            let _e7245 = center_14;
                                                                            dv_6 = abs((_e7244 - _e7245));
                                                                            let _e7249 = dv_6;
                                                                            let _e7253 = dv_6;
                                                                            let _e7256 = N_18;
                                                                            if ((_e7249.x < 0.45f) && (_e7253.y < (0.4f / _e7256))) {
                                                                                {
                                                                                    let _e7262 = inverseTileTransform_3[2];
                                                                                    s_8 = (_e7262.x + 1f);
                                                                                    let _e7267 = inverseCurrentTransform_5;
                                                                                    let _e7268 = relId_5;
                                                                                    let _e7269 = s_8;
                                                                                    let _e7279 = tf(_e7267, (_e7268 + ((_e7269 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_14 = _e7279;
                                                                                    let _e7281 = inverseCurrentTransform_5;
                                                                                    let _e7282 = relId_5;
                                                                                    let _e7283 = s_8;
                                                                                    let _e7292 = tf(_e7281, (_e7282 + ((_e7283 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_14 = _e7292;
                                                                                    let _e7294 = u1_14;
                                                                                    let _e7298 = global.U[0];
                                                                                    let _e7301 = u1_14;
                                                                                    let _e7310 = _mirror_wrap(((vec2<f32>((_e7294.x / _e7298.x), _e7301.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7312 = textureSampleLevel(t_source, samp, _e7310, 0f);
                                                                                    let _e7313 = u2_14;
                                                                                    let _e7317 = global.U[0];
                                                                                    let _e7320 = u2_14;
                                                                                    let _e7329 = _mirror_wrap(((vec2<f32>((_e7313.x / _e7317.x), _e7320.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7331 = textureSampleLevel(t_source, samp, _e7329, 0f);
                                                                                    let _e7332 = center_14;
                                                                                    outCol = mix(_e7312, _e7331, vec4((_e7332.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e7338 = mode_5;
                                                                        if (_e7338 == 12i) {
                                                                            {
                                                                                let _e7341 = v_6;
                                                                                v_6 = (_e7341 * vec2<f32>(2f, 2f));
                                                                                let _e7346 = inverseTileTransform_3;
                                                                                let _e7347 = v_6;
                                                                                let _e7348 = tf(_e7346, _e7347);
                                                                                v_6 = _e7348;
                                                                                let _e7349 = inverseCurrentTransform_5;
                                                                                let _e7350 = relId_5;
                                                                                let _e7351 = v_6;
                                                                                let _e7356 = tf(_e7349, (_e7350 + (_e7351 + vec2(0.5f))));
                                                                                let _e7360 = global.U[0];
                                                                                let _e7363 = inverseCurrentTransform_5;
                                                                                let _e7364 = relId_5;
                                                                                let _e7365 = v_6;
                                                                                let _e7370 = tf(_e7363, (_e7364 + (_e7365 + vec2(0.5f))));
                                                                                let _e7379 = _mirror_wrap(((vec2<f32>((_e7356.x / _e7360.x), _e7370.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e7381 = textureSampleLevel(t_source, samp, _e7379, 0f);
                                                                                outCol = _e7381;
                                                                            }
                                                                        } else {
                                                                            let _e7382 = mode_5;
                                                                            if (_e7382 == 13i) {
                                                                                {
                                                                                    let _e7385 = _uv_5;
                                                                                    let _e7389 = global.U[0];
                                                                                    let _e7392 = _uv_5;
                                                                                    let _e7401 = _mirror_wrap(((vec2<f32>((_e7385.x / _e7389.x), _e7392.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7403 = textureSampleLevel(t_source, samp, _e7401, 0f);
                                                                                    let _e7405 = luma(_e7403.xyz);
                                                                                    lum_9 = _e7405;
                                                                                    let _e7407 = inverseTileTransform_3;
                                                                                    let _e7408 = v_6;
                                                                                    let _e7413 = tf(_e7407, (_e7408 * vec2<f32>(8f, 8f)));
                                                                                    v_6 = _e7413;
                                                                                    let _e7414 = v_6;
                                                                                    let _e7417 = (_e7414.y + 1f);
                                                                                    y_3 = abs(((_e7417 - (floor((_e7417 / 2f)) * 2f)) - 1f));
                                                                                    let _e7427 = lum_9;
                                                                                    let _e7428 = y_3;
                                                                                    if (_e7427 > _e7428) {
                                                                                        local_29 = 1f;
                                                                                    } else {
                                                                                        local_29 = 0f;
                                                                                    }
                                                                                    let _e7433 = local_29;
                                                                                    k_28 = _e7433;
                                                                                    let _e7435 = k_28;
                                                                                    let _e7436 = vec3(_e7435);
                                                                                    outCol = vec4<f32>(_e7436.x, _e7436.y, _e7436.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e7442 = mode_5;
                                                                                if (_e7442 == 14i) {
                                                                                    {
                                                                                        let _e7445 = id_3;
                                                                                        let _e7449 = global.U[0];
                                                                                        let _e7452 = id_3;
                                                                                        let _e7461 = _mirror_wrap(((vec2<f32>((_e7445.x / _e7449.x), _e7452.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e7463 = textureSampleLevel(t_source, samp, _e7461, 0f);
                                                                                        let _e7465 = luma(_e7463.xyz);
                                                                                        lum_10 = _e7465;
                                                                                        let _e7469 = tileTransform_3[0];
                                                                                        contrast_3 = length(_e7469.xy);
                                                                                        let _e7473 = v_6;
                                                                                        let _e7476 = (_e7473 + vec2(0.5f));
                                                                                        let _e7478 = contrast_3;
                                                                                        let _e7479 = lum_10;
                                                                                        outCol = vec4<f32>(_e7476.x, _e7476.y, (0.5f + (_e7478 * (_e7479 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e7488 = mode_5;
                                                                                    if (_e7488 == 15i) {
                                                                                        {
                                                                                            let _e7491 = rnd_5;
                                                                                            center_15 = (sign((_e7491 - vec2(0.5f))) * 0.5f);
                                                                                            let _e7499 = v_6;
                                                                                            let _e7500 = center_15;
                                                                                            dv_7 = (_e7499 - _e7500);
                                                                                            let _e7506 = inverseTileTransform_3[0];
                                                                                            N_19 = floor((16f * length(_e7506.xy)));
                                                                                            let _e7514 = dv_7;
                                                                                            let _e7516 = dv_7;
                                                                                            let _e7519 = angOffset_3;
                                                                                            ang_27 = (atan2(_e7514.y, _e7516.x) + _e7519);
                                                                                            let _e7522 = ang_27;
                                                                                            let _e7525 = N_19;
                                                                                            let _e7528 = (((_e7522 / 3.1415927f) * _e7525) * 2f);
                                                                                            k_29 = abs(((_e7528 - (floor((_e7528 / 2f)) * 2f)) - 1f));
                                                                                            let _e7540 = inverseTileTransform_3[0];
                                                                                            let _e7544 = inverseTileTransform_3[0];
                                                                                            kCol_3 = (atan2(_e7540.y, _e7544.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e7554 = i_11;
                                                                                                if !((_e7554 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e7561 = inverseCurrentTransform_5;
                                                                                                    let _e7562 = relId_5;
                                                                                                    let _e7565 = i_11;
                                                                                                    let _e7569 = ang_27;
                                                                                                    let _e7571 = ang_27;
                                                                                                    let _e7576 = tf(_e7561, (_e7562 + ((0.1f + (0.15f * f32(_e7565))) * vec2<f32>(cos(_e7569), sin(_e7571)))));
                                                                                                    w_15 = _e7576;
                                                                                                    let _e7578 = lum_11;
                                                                                                    let _e7579 = w_15;
                                                                                                    let _e7583 = global.U[0];
                                                                                                    let _e7586 = w_15;
                                                                                                    let _e7595 = _mirror_wrap(((vec2<f32>((_e7579.x / _e7583.x), _e7586.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7597 = textureSampleLevel(t_source, samp, _e7595, 0f);
                                                                                                    let _e7599 = luma(_e7597.xyz);
                                                                                                    lum_11 = (_e7578 + _e7599);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e7558 = i_11;
                                                                                                    i_11 = (_e7558 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e7601 = lum_11;
                                                                                            lum_11 = (_e7601 / 5f);
                                                                                            let _e7604 = lum_11;
                                                                                            let _e7605 = k_29;
                                                                                            if (_e7604 > _e7605) {
                                                                                                local_30 = 1f;
                                                                                            } else {
                                                                                                local_30 = 0f;
                                                                                            }
                                                                                            let _e7610 = local_30;
                                                                                            k_29 = _e7610;
                                                                                            let _e7611 = kCol_3;
                                                                                            if (_e7611 == 0f) {
                                                                                                {
                                                                                                    let _e7614 = k_29;
                                                                                                    let _e7615 = vec3(_e7614);
                                                                                                    outCol = vec4<f32>(_e7615.x, _e7615.y, _e7615.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e7623 = inverseTileTransform_3[2];
                                                                                                    u1_15 = vec2<f32>(_e7623.x, 0f);
                                                                                                    let _e7631 = inverseTileTransform_3[2];
                                                                                                    u2_15 = vec2<f32>(0f, _e7631.y);
                                                                                                    let _e7635 = kCol_3;
                                                                                                    if (_e7635 > 0f) {
                                                                                                        {
                                                                                                            let _e7638 = u1_15;
                                                                                                            let _e7639 = id_3;
                                                                                                            u1_15 = (_e7638 + _e7639);
                                                                                                            let _e7641 = u2_15;
                                                                                                            let _e7642 = id_3;
                                                                                                            u2_15 = (_e7641 + (_e7642 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e7647 = u1_15;
                                                                                                    let _e7651 = global.U[0];
                                                                                                    let _e7654 = u1_15;
                                                                                                    let _e7663 = _mirror_wrap(((vec2<f32>((_e7647.x / _e7651.x), _e7654.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7665 = textureSampleLevel(t_source, samp, _e7663, 0f);
                                                                                                    col1_12 = _e7665;
                                                                                                    let _e7667 = u2_15;
                                                                                                    let _e7671 = global.U[0];
                                                                                                    let _e7674 = u2_15;
                                                                                                    let _e7683 = _mirror_wrap(((vec2<f32>((_e7667.x / _e7671.x), _e7674.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7685 = textureSampleLevel(t_source, samp, _e7683, 0f);
                                                                                                    col2_12 = _e7685;
                                                                                                    let _e7687 = col1_12;
                                                                                                    let _e7689 = luma(_e7687.xyz);
                                                                                                    let _e7690 = col2_12;
                                                                                                    let _e7692 = luma(_e7690.xyz);
                                                                                                    if (_e7689 > _e7692) {
                                                                                                        let _e7695 = k_29;
                                                                                                        k_29 = (1f - _e7695);
                                                                                                    }
                                                                                                    let _e7697 = k_29;
                                                                                                    let _e7698 = vec3(_e7697);
                                                                                                    outCol1_3 = vec4<f32>(_e7698.x, _e7698.y, _e7698.z, 1f);
                                                                                                    let _e7705 = col1_12;
                                                                                                    let _e7706 = col2_12;
                                                                                                    let _e7707 = k_29;
                                                                                                    outCol2_3 = mix(_e7705, _e7706, vec4(_e7707));
                                                                                                    let _e7711 = outCol1_3;
                                                                                                    let _e7712 = outCol2_3;
                                                                                                    let _e7713 = kCol_3;
                                                                                                    outCol = mix(_e7711, _e7712, vec4(abs(_e7713)));
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let _e7717 = src1_1;
                let _e7718 = outCol;
                let _e7719 = mergeColor(_e7717, _e7718);
                col1_13 = _e7719;
                {
                    let _e7721 = uu2_1;
                    _uv_6 = _e7721;
                    let _e7723 = _params_1;
                    startScale_8 = _e7723.startScale;
                    let _e7726 = _params_1;
                    subLevels_6 = _e7726.subLevels;
                    let _e7729 = _params_1;
                    subThreshold_6 = _e7729.subThreshold;
                    let _e7732 = _params_1;
                    seed_6 = _e7732.seed;
                    let _e7735 = _params_1;
                    hashStyle_8 = _e7735.hashStyle;
                    let _e7738 = _params_1;
                    coverage_6 = _e7738.coverage;
                    let _e7741 = _params_1;
                    currentTransform_6 = _e7741.transform;
                    let _e7744 = _params_1;
                    inverseCurrentTransform_6 = _e7744.inverseTransform;
                    let _e7747 = startScale_8;
                    scale_8 = _e7747;
                    loop {
                        let _e7755 = i_12;
                        let _e7756 = subLevels_6;
                        if !((_e7755 < _e7756)) {
                            break;
                        }
                        {
                            let _e7762 = i_12;
                            if (_e7762 != 0f) {
                                {
                                    let _e7778 = currentTransform_6;
                                    currentTransform_6 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e7778);
                                    let _e7780 = inverseCurrentTransform_6;
                                    inverseCurrentTransform_6 = (_e7780 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e7795 = currentTransform_6;
                            let _e7796 = _uv_6;
                            let _e7797 = tf(_e7795, _e7796);
                            relId_6 = floor(_e7797);
                            let _e7799 = relId_6;
                            let _e7801 = (_e7799 * 0.13137f);
                            let _e7802 = i_12;
                            let _e7803 = seed_6;
                            let _e7807 = hashStyle_8;
                            let _e7808 = hash42sp(vec4<f32>(_e7801.x, _e7801.y, _e7802, _e7803), _e7807);
                            rnd_6 = _e7808;
                            let _e7809 = i_12;
                            let _e7810 = subLevels_6;
                            let _e7814 = rnd_6;
                            let _e7816 = subThreshold_6;
                            if ((_e7809 == (_e7810 - 1f)) || (_e7814.x > _e7816)) {
                                {
                                    break;
                                }
                            }
                            let _e7819 = scale_8;
                            scale_8 = (_e7819 * 2f);
                        }
                        continuing {
                            let _e7759 = i_12;
                            i_12 = (_e7759 + 1f);
                        }
                    }
                    let _e7822 = inverseCurrentTransform_6;
                    let _e7823 = relId_6;
                    let _e7824 = tf(_e7822, _e7823);
                    id_4 = _e7824;
                    let _e7826 = rnd_6;
                    modeIndex_4 = i32(floor((_e7826.y * 4f)));
                    let _e7833 = modeIndex_4;
                    let _e7836 = _params_1.modeMap[_e7833];
                    mode_6 = _e7836;
                    let _e7839 = modeIndex_4;
                    if (_e7839 == 0i) {
                        let _e7842 = tileTransform1_1;
                        tileTransform_4 = _e7842;
                    } else {
                        let _e7843 = modeIndex_4;
                        if (_e7843 == 1i) {
                            let _e7846 = tileTransform2_1;
                            tileTransform_4 = _e7846;
                        } else {
                            let _e7847 = modeIndex_4;
                            if (_e7847 == 2i) {
                                let _e7850 = tileTransform3_1;
                                tileTransform_4 = _e7850;
                            } else {
                                let _e7851 = tileTransform4_1;
                                tileTransform_4 = _e7851;
                            }
                        }
                    }
                    let _e7852 = tileTransform_4;
                    inverseTileTransform_4 = _naga_inverse_3x3_f32(_e7852);
                    let _e7855 = currentTransform_6;
                    let _e7856 = _uv_6;
                    let _e7857 = tf(_e7855, _e7856);
                    let _e7858 = relId_6;
                    v_7 = ((_e7857 - _e7858) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e7865 = rnd_6;
                    let _e7869 = rnd_6;
                    let _e7875 = coverage_6;
                    if (fract(((_e7865.x * 6.222f) + (_e7869.y * 8.233f))) <= _e7875) {
                        {
                            let _e7877 = mode_6;
                            if (_e7877 == 0i) {
                                {
                                    let _e7882 = inverseTileTransform_4[0];
                                    w_16 = _e7882.xy;
                                    let _e7885 = w_16;
                                    let _e7889 = w_16;
                                    w_16 = floor(vec2<f32>(dot(_e7885, vec2(20f)), dot(_e7889, vec2<f32>(20f, -20f))));
                                    let _e7897 = relId_6;
                                    let _e7899 = v_7;
                                    let _e7900 = w_16;
                                    let _e7905 = tileTransform_4[0];
                                    let _e7912 = inverseTileTransform_4[2];
                                    let _e7915 = w_16;
                                    pixId_8 = (_e7897 + (1.23f * (floor((_e7899 * _e7900)) + floor((((length(_e7905.xy) * 5f) * _e7912.xy) * _e7915)))));
                                    let _e7922 = pixId_8;
                                    let _e7923 = hash22_(_e7922);
                                    let _e7927 = global.U[0];
                                    let _e7930 = pixId_8;
                                    let _e7931 = hash22_(_e7930);
                                    let _e7940 = _mirror_wrap(((vec2<f32>((_e7923.x / _e7927.x), _e7931.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e7942 = textureSampleLevel(t_source, samp, _e7940, 0f);
                                    outCol = _e7942;
                                }
                            } else {
                                let _e7943 = mode_6;
                                if (_e7943 == 1i) {
                                    {
                                        let _e7947 = v_7;
                                        let _e7950 = v_7;
                                        v_7 = vec2<f32>(0f, max(abs(_e7947.x), abs(_e7950.y)));
                                        let _e7955 = inverseCurrentTransform_6;
                                        let _e7956 = relId_6;
                                        let _e7957 = inverseTileTransform_4;
                                        let _e7958 = v_7;
                                        let _e7959 = tf(_e7957, _e7958);
                                        let _e7964 = tf(_e7955, (_e7956 + (_e7959 + vec2(0.5f))));
                                        vv_8 = _e7964;
                                        let _e7966 = vv_8;
                                        let _e7970 = global.U[0];
                                        let _e7973 = vv_8;
                                        let _e7982 = _mirror_wrap(((vec2<f32>((_e7966.x / _e7970.x), _e7973.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e7984 = textureSampleLevel(t_source, samp, _e7982, 0f);
                                        outCol = _e7984;
                                    }
                                } else {
                                    let _e7985 = mode_6;
                                    if (_e7985 == 2i) {
                                        {
                                            let _e7991 = inverseTileTransform_4[2];
                                            size_12 = (0.5f + _e7991.y);
                                            let _e7995 = v_7;
                                            d_8 = length(_e7995);
                                            let _e7998 = v_7;
                                            let _e8000 = v_7;
                                            ang_28 = atan2(_e7998.y, _e8000.x);
                                            let _e8004 = d_8;
                                            let _e8005 = size_12;
                                            if (_e8004 <= _e8005) {
                                                {
                                                    let _e8010 = spikeCount_4;
                                                    anglePeriod_4 = (6.2831855f / _e8010);
                                                    let _e8013 = ang_28;
                                                    let _e8014 = anglePeriod_4;
                                                    let _e8017 = anglePeriod_4;
                                                    a1_4 = (floor((_e8013 / _e8014)) * _e8017);
                                                    let _e8020 = a1_4;
                                                    let _e8021 = anglePeriod_4;
                                                    a2_4 = (_e8020 + _e8021);
                                                    let _e8024 = ang_28;
                                                    let _e8025 = a1_4;
                                                    let _e8027 = anglePeriod_4;
                                                    k_30 = ((_e8024 - _e8025) / _e8027);
                                                    let _e8030 = d_8;
                                                    let _e8035 = inverseTileTransform_4[0];
                                                    ds_8 = ((_e8030 * 10f) * length(_e8035.xy));
                                                    let _e8040 = relId_6;
                                                    center_16 = (_e8040 + vec2(0.5f));
                                                    let _e8045 = inverseCurrentTransform_6;
                                                    let _e8046 = center_16;
                                                    let _e8047 = ds_8;
                                                    let _e8048 = a1_4;
                                                    let _e8050 = a1_4;
                                                    let _e8057 = inverseTileTransform_4[2];
                                                    let _e8061 = tf(_e8045, ((_e8046 + (_e8047 * vec2<f32>(cos(_e8048), sin(_e8050)))) + vec2(_e8057.x)));
                                                    u1_16 = _e8061;
                                                    let _e8063 = inverseCurrentTransform_6;
                                                    let _e8064 = center_16;
                                                    let _e8065 = ds_8;
                                                    let _e8066 = a2_4;
                                                    let _e8068 = a2_4;
                                                    let _e8075 = inverseTileTransform_4[2];
                                                    let _e8079 = tf(_e8063, ((_e8064 + (_e8065 * vec2<f32>(cos(_e8066), sin(_e8068)))) + vec2(_e8075.x)));
                                                    u2_16 = _e8079;
                                                    let _e8081 = u1_16;
                                                    let _e8085 = global.U[0];
                                                    let _e8088 = u1_16;
                                                    let _e8097 = _mirror_wrap(((vec2<f32>((_e8081.x / _e8085.x), _e8088.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e8099 = textureSampleLevel(t_source, samp, _e8097, 0f);
                                                    col1_14 = _e8099;
                                                    let _e8101 = u2_16;
                                                    let _e8105 = global.U[0];
                                                    let _e8108 = u2_16;
                                                    let _e8117 = _mirror_wrap(((vec2<f32>((_e8101.x / _e8105.x), _e8108.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e8119 = textureSampleLevel(t_source, samp, _e8117, 0f);
                                                    col2_13 = _e8119;
                                                    let _e8121 = col1_14;
                                                    let _e8122 = col2_13;
                                                    let _e8123 = k_30;
                                                    outCol = mix(_e8121, _e8122, vec4(_e8123));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e8126 = mode_6;
                                        if (_e8126 == 3i) {
                                            {
                                                let _e8129 = v_7;
                                                let _e8132 = v_7;
                                                vert_4 = (abs(_e8129.y) > abs(_e8132.x));
                                                let _e8137 = vert_4;
                                                if _e8137 {
                                                    let _e8138 = v_7;
                                                    local_31 = _e8138.y;
                                                } else {
                                                    let _e8140 = v_7;
                                                    local_31 = _e8140.x;
                                                }
                                                let _e8143 = local_31;
                                                a_4 = _e8143;
                                                let _e8145 = vert_4;
                                                if _e8145 {
                                                    let _e8146 = a_4;
                                                    let _e8148 = a_4;
                                                    local_32 = vec2<f32>(-(_e8146), _e8148);
                                                } else {
                                                    let _e8150 = a_4;
                                                    let _e8151 = a_4;
                                                    local_32 = vec2<f32>(_e8150, -(_e8151));
                                                }
                                                let _e8155 = local_32;
                                                u1_17 = _e8155;
                                                let _e8157 = a_4;
                                                let _e8158 = a_4;
                                                u2_17 = vec2<f32>(_e8157, _e8158);
                                                let _e8161 = v_7;
                                                let _e8163 = v_7;
                                                let _e8167 = a_4;
                                                k_31 = ((_e8161.x + _e8163.y) / (2f * _e8167));
                                                let _e8171 = inverseCurrentTransform_6;
                                                let _e8172 = relId_6;
                                                let _e8173 = inverseTileTransform_4;
                                                let _e8174 = u1_17;
                                                let _e8175 = tf(_e8173, _e8174);
                                                let _e8180 = tf(_e8171, (_e8172 + (_e8175 + vec2(0.5f))));
                                                u1_17 = _e8180;
                                                let _e8181 = inverseCurrentTransform_6;
                                                let _e8182 = relId_6;
                                                let _e8183 = inverseTileTransform_4;
                                                let _e8184 = u2_17;
                                                let _e8185 = tf(_e8183, _e8184);
                                                let _e8190 = tf(_e8181, (_e8182 + (_e8185 + vec2(0.5f))));
                                                u2_17 = _e8190;
                                                let _e8191 = u1_17;
                                                let _e8195 = global.U[0];
                                                let _e8198 = u1_17;
                                                let _e8207 = _mirror_wrap(((vec2<f32>((_e8191.x / _e8195.x), _e8198.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e8209 = textureSampleLevel(t_source, samp, _e8207, 0f);
                                                col1_15 = _e8209;
                                                let _e8211 = u2_17;
                                                let _e8215 = global.U[0];
                                                let _e8218 = u2_17;
                                                let _e8227 = _mirror_wrap(((vec2<f32>((_e8211.x / _e8215.x), _e8218.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e8229 = textureSampleLevel(t_source, samp, _e8227, 0f);
                                                col2_14 = _e8229;
                                                let _e8231 = col1_15;
                                                let _e8232 = col2_14;
                                                let _e8233 = k_31;
                                                outCol = mix(_e8231, _e8232, vec4(_e8233));
                                            }
                                        } else {
                                            let _e8236 = mode_6;
                                            if (_e8236 == 4i) {
                                                {
                                                    let _e8243 = inverseTileTransform_4[0];
                                                    let _e8247 = inverseTileTransform_4[0];
                                                    ang_29 = atan2(_e8243.y, _e8247.x);
                                                    let _e8251 = ang_29;
                                                    if (_e8251 < 0f) {
                                                        let _e8254 = relId_6;
                                                        let _e8256 = relId_6;
                                                        let _e8258 = (_e8254.x + _e8256.y);
                                                        local_33 = sign(((_e8258 - (floor((_e8258 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_33 = 1f;
                                                    }
                                                    let _e8269 = local_33;
                                                    orientation_4 = _e8269;
                                                    let _e8271 = rnd_6;
                                                    let _e8273 = ang_29;
                                                    if (_e8271.y > (abs(_e8273) / 3.1415927f)) {
                                                        let _e8278 = orientation_4;
                                                        orientation_4 = -(_e8278);
                                                    }
                                                    let _e8280 = orientation_4;
                                                    let _e8281 = v_7;
                                                    let _e8284 = v_7;
                                                    if (((_e8280 * _e8281.x) * _e8284.y) < 0f) {
                                                        local_34 = 40f;
                                                    } else {
                                                        local_34 = 2.5f;
                                                    }
                                                    let _e8292 = local_34;
                                                    p_9 = _e8292;
                                                    let _e8294 = p_9;
                                                    if (_e8294 > 30f) {
                                                        let _e8297 = v_7;
                                                        let _e8300 = v_7;
                                                        local_35 = max(abs(_e8297.x), abs(_e8300.y));
                                                    } else {
                                                        let _e8304 = v_7;
                                                        let _e8307 = p_9;
                                                        let _e8309 = v_7;
                                                        let _e8312 = p_9;
                                                        let _e8316 = p_9;
                                                        local_35 = pow((pow(abs(_e8304.x), _e8307) + pow(abs(_e8309.y), _e8312)), (1f / _e8316));
                                                    }
                                                    let _e8320 = local_35;
                                                    d_9 = _e8320;
                                                    let _e8323 = d_9;
                                                    v_7 = vec2<f32>(0f, _e8323);
                                                    let _e8325 = v_7;
                                                    let _e8327 = size_13;
                                                    if (_e8325.y <= _e8327) {
                                                        {
                                                            let _e8329 = inverseCurrentTransform_6;
                                                            let _e8330 = relId_6;
                                                            let _e8331 = inverseTileTransform_4;
                                                            let _e8332 = v_7;
                                                            let _e8333 = tf(_e8331, _e8332);
                                                            let _e8338 = tf(_e8329, (_e8330 + (_e8333 + vec2(0.5f))));
                                                            vv_9 = _e8338;
                                                            let _e8340 = vv_9;
                                                            let _e8344 = global.U[0];
                                                            let _e8347 = vv_9;
                                                            let _e8356 = _mirror_wrap(((vec2<f32>((_e8340.x / _e8344.x), _e8347.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e8358 = textureSampleLevel(t_source, samp, _e8356, 0f);
                                                            outCol = _e8358;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e8359 = mode_6;
                                                if (_e8359 <= 6i) {
                                                    {
                                                        let _e8364 = inverseTileTransform_4[0];
                                                        scale_9 = length(_e8364.xy);
                                                        let _e8368 = scale_9;
                                                        invert_4 = (_e8368 < 1f);
                                                        let _e8372 = invert_4;
                                                        if _e8372 {
                                                            let _e8374 = scale_9;
                                                            scale_9 = (1f / _e8374);
                                                        }
                                                        let _e8376 = scale_9;
                                                        ds_9 = fract(_e8376);
                                                        let _e8379 = scale_9;
                                                        N_20 = max(floor(_e8379), 1f);
                                                        let _e8384 = v_7;
                                                        let _e8388 = N_20;
                                                        w_17 = (fract(((_e8384 + vec2(0.5f)) * _e8388)) - vec2(0.5f));
                                                        let _e8395 = v_7;
                                                        let _e8399 = N_20;
                                                        let _e8402 = N_20;
                                                        let _e8411 = N_20;
                                                        center_17 = ((((floor(((_e8395 + vec2(0.5f)) * _e8399)) / vec2(_e8402)) * 2f) - vec2(1f)) + vec2((1f / _e8411)));
                                                        let _e8418 = inverseTileTransform_4[0];
                                                        let _e8422 = inverseTileTransform_4[0];
                                                        ang_30 = atan2(_e8418.y, _e8422.x);
                                                        let _e8430 = ang_30;
                                                        if (_e8430 > 0f) {
                                                            let _e8434 = ang_30;
                                                            keepX_4 = (1f - (_e8434 / 3.1415927f));
                                                        } else {
                                                            let _e8439 = ang_30;
                                                            keepY_4 = (1f + (_e8439 / 3.1415927f));
                                                        }
                                                        let _e8443 = center_17;
                                                        let _e8446 = keepX_4;
                                                        let _e8448 = center_17;
                                                        let _e8451 = keepY_4;
                                                        hide_4 = ((abs(_e8443.x) > _e8446) || (abs(_e8448.y) > _e8451));
                                                        let _e8457 = ds_9;
                                                        size_14 = mix(0.5f, 0.15f, _e8457);
                                                        let _e8460 = mode_6;
                                                        let _e8463 = w_17;
                                                        let _e8465 = size_14;
                                                        let _e8468 = mode_6;
                                                        let _e8471 = w_17;
                                                        let _e8474 = size_14;
                                                        let _e8476 = w_17;
                                                        let _e8479 = size_14;
                                                        outside_4 = (((_e8460 == 6i) && (length(_e8463) > _e8465)) || ((_e8468 == 5i) && ((abs(_e8471.x) > _e8474) || (abs(_e8476.y) > _e8479))));
                                                        let _e8485 = hide_4;
                                                        let _e8486 = outside_4;
                                                        if !((_e8485 || _e8486)) {
                                                            {
                                                                let _e8489 = id_4;
                                                                let _e8492 = inverseTileTransform_4[2];
                                                                let _e8498 = global.U[0];
                                                                let _e8501 = id_4;
                                                                let _e8504 = inverseTileTransform_4[2];
                                                                let _e8515 = _mirror_wrap(((vec2<f32>(((_e8489 + _e8492.xy).x / _e8498.x), (_e8501 + _e8504.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e8517 = textureSampleLevel(t_source, samp, _e8515, 0f);
                                                                outCol = _e8517;
                                                            }
                                                        } else {
                                                            let _e8518 = invert_4;
                                                            if _e8518 {
                                                                {
                                                                    let _e8519 = id_4;
                                                                    let _e8523 = global.U[0];
                                                                    let _e8526 = id_4;
                                                                    let _e8535 = _mirror_wrap(((vec2<f32>((_e8519.x / _e8523.x), _e8526.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e8537 = textureSampleLevel(t_source, samp, _e8535, 0f);
                                                                    outCol = _e8537;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e8538 = mode_6;
                                                    if (_e8538 == 7i) {
                                                        {
                                                            let _e8543 = inverseTileTransform_4[0];
                                                            w_18 = _e8543.xy;
                                                            let _e8546 = w_18;
                                                            let _e8550 = w_18;
                                                            w_18 = floor(vec2<f32>(dot(_e8546, vec2(16f)), dot(_e8550, vec2<f32>(16f, -16f))));
                                                            let _e8558 = startScale_8;
                                                            let _e8565 = inverseTileTransform_4[2];
                                                            minScale_4 = ((_e8558 * 2f) * pow(2f, floor((2f * _e8565.y))));
                                                            let _e8572 = minScale_4;
                                                            let _e8573 = startScale_8;
                                                            let _e8580 = inverseTileTransform_4[2];
                                                            maxScale_4 = max(_e8572, ((_e8573 * 4f) * pow(2f, floor((2f * _e8580.x)))));
                                                            let _e8588 = scale_8;
                                                            let _e8589 = minScale_4;
                                                            let _e8590 = maxScale_4;
                                                            scale2_8 = clamp(_e8588, _e8589, _e8590);
                                                            let _e8593 = scale2_8;
                                                            let _e8594 = scale_8;
                                                            invScaleRatio_8 = (_e8593 / _e8594);
                                                            let _e8597 = invScaleRatio_8;
                                                            let _e8601 = invScaleRatio_8;
                                                            let _e8610 = currentTransform_6;
                                                            tr_8 = (mat3x3<f32>(vec3<f32>(_e8597, 0f, 0f), vec3<f32>(0f, _e8601, 0f), vec3<f32>(0f, 0f, 1f)) * _e8610);
                                                            let _e8613 = tr_8;
                                                            let _e8614 = _uv_6;
                                                            let _e8615 = tf(_e8613, _e8614);
                                                            v_7 = (_e8615 - vec2(0.5f));
                                                            let _e8619 = v_7;
                                                            let _e8620 = w_18;
                                                            pixId_9 = floor((_e8619 * _e8620));
                                                            let _e8624 = pixId_9;
                                                            let _e8626 = pixId_9;
                                                            let _e8628 = (_e8624.x + _e8626.y);
                                                            k_32 = (_e8628 - (floor((_e8628 / 2f)) * 2f));
                                                            let _e8635 = k_32;
                                                            let _e8636 = vec3(_e8635);
                                                            outCol = vec4<f32>(_e8636.x, _e8636.y, _e8636.z, 1f);
                                                        }
                                                    } else {
                                                        let _e8642 = mode_6;
                                                        if (_e8642 == 8i) {
                                                            {
                                                                let _e8647 = startScale_8;
                                                                scale2_9 = (_e8647 * 4f);
                                                                let _e8651 = scale2_9;
                                                                let _e8652 = scale_8;
                                                                invScaleRatio_9 = (_e8651 / _e8652);
                                                                let _e8655 = invScaleRatio_9;
                                                                let _e8659 = invScaleRatio_9;
                                                                let _e8668 = currentTransform_6;
                                                                tr_9 = (mat3x3<f32>(vec3<f32>(_e8655, 0f, 0f), vec3<f32>(0f, _e8659, 0f), vec3<f32>(0f, 0f, 1f)) * _e8668);
                                                                let _e8671 = tr_9;
                                                                let _e8672 = _uv_6;
                                                                let _e8673 = tf(_e8671, _e8672);
                                                                v_7 = (_e8673 - vec2(0.5f));
                                                                let _e8683 = inverseTileTransform_4[0];
                                                                let _e8687 = inverseTileTransform_4[0];
                                                                let _e8690 = piN_4;
                                                                let _e8693 = piN_4;
                                                                ang_31 = (floor((atan2(_e8683.y, _e8687.x) / _e8690)) * _e8693);
                                                                let _e8696 = ang_31;
                                                                let _e8697 = rotation2_(_e8696);
                                                                let _e8698 = v_7;
                                                                let _e8702 = inverseTileTransform_4[0];
                                                                let _e8709 = inverseTileTransform_4[2];
                                                                v_7 = (((_e8697 * _e8698) * length(_e8702.xy)) + (2f * _e8709.xy));
                                                                let _e8713 = v_7;
                                                                let _e8715 = v_7;
                                                                let _e8717 = rnd_6;
                                                                let _e8724 = Xn_4;
                                                                let _e8726 = floor(((_e8713.x + (_e8715.y * sign((_e8717.y - 0.5f)))) * _e8724));
                                                                k_33 = (_e8726 - (floor((_e8726 / 2f)) * 2f));
                                                                let _e8733 = k_33;
                                                                let _e8734 = vec3(_e8733);
                                                                outCol = vec4<f32>(_e8734.x, _e8734.y, _e8734.z, 1f);
                                                            }
                                                        } else {
                                                            let _e8740 = mode_6;
                                                            if (_e8740 == 9i) {
                                                                {
                                                                    let _e8747 = inverseTileTransform_4[2];
                                                                    N_21 = floor((1000f * pow(0.25f, length(_e8747.xy))));
                                                                    let _e8758 = N_21;
                                                                    let _e8763 = inverseTileTransform_4[1];
                                                                    let _e8767 = inverseTileTransform_4[1];
                                                                    offset_4 = ((1.5707964f + (3.1415927f / _e8758)) + atan2(_e8763.y, _e8767.x));
                                                                    let _e8772 = v_7;
                                                                    let _e8774 = v_7;
                                                                    ang_32 = atan2(_e8772.y, _e8774.x);
                                                                    let _e8778 = ang_32;
                                                                    let _e8779 = offset_4;
                                                                    let _e8783 = N_21;
                                                                    let _e8786 = N_21;
                                                                    let _e8790 = offset_4;
                                                                    ang_32 = (((round((((_e8778 - _e8779) / 6.2831855f) * _e8783)) / _e8786) * 6.2831855f) + _e8790);
                                                                    let _e8794 = inverseTileTransform_4[0];
                                                                    let _e8799 = ang_32;
                                                                    let _e8802 = ang_32;
                                                                    dist_8 = ((length(_e8794.xy) * 0.5f) / max(abs(cos(_e8799)), abs(sin(_e8802))));
                                                                    let _e8808 = dist_8;
                                                                    let _e8809 = ang_32;
                                                                    let _e8811 = ang_32;
                                                                    v_7 = (_e8808 * vec2<f32>(cos(_e8809), sin(_e8811)));
                                                                    let _e8815 = inverseCurrentTransform_6;
                                                                    let _e8816 = relId_6;
                                                                    let _e8817 = v_7;
                                                                    let _e8822 = tf(_e8815, (_e8816 + (_e8817 + vec2(0.5f))));
                                                                    u_10 = _e8822;
                                                                    let _e8824 = u_10;
                                                                    let _e8828 = global.U[0];
                                                                    let _e8831 = u_10;
                                                                    let _e8840 = _mirror_wrap(((vec2<f32>((_e8824.x / _e8828.x), _e8831.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e8842 = textureSampleLevel(t_source, samp, _e8840, 0f);
                                                                    outCol = _e8842;
                                                                }
                                                            } else {
                                                                let _e8843 = mode_6;
                                                                if (_e8843 == 10i) {
                                                                    {
                                                                        let _e8848 = inverseTileTransform_4[0];
                                                                        s_9 = (length(_e8848.xy) * 0.05f);
                                                                        let _e8854 = v_7;
                                                                        v_7 = (_e8854 + vec2(0.5f));
                                                                        let _e8862 = inverseTileTransform_4[0];
                                                                        let _e8866 = inverseTileTransform_4[0];
                                                                        let _e8871 = N_22;
                                                                        let _e8876 = N_22;
                                                                        ang_33 = ((floor(((atan2(_e8862.y, _e8866.x) / 3.1415927f) * _e8871)) * 3.1415927f) / _e8876);
                                                                        let _e8879 = ang_33;
                                                                        let _e8880 = rotation2_(_e8879);
                                                                        let _e8881 = v_7;
                                                                        v_7 = (_e8880 * _e8881);
                                                                        let _e8883 = v_7;
                                                                        let _e8887 = inverseTileTransform_4[2];
                                                                        let _e8891 = tileTransform_4[0];
                                                                        let _e8899 = v_7;
                                                                        let _e8903 = inverseTileTransform_4[2];
                                                                        let _e8907 = tileTransform_4[0];
                                                                        let _e8914 = hslToRgb(vec4<f32>(((_e8883.x + (_e8887.x * length(_e8891.xy))) * 360f), 1f, (_e8899.y + (_e8903.y * length(_e8907.xy))), 1f));
                                                                        rgb_4 = _e8914;
                                                                        let _e8916 = _uv_6;
                                                                        let _e8920 = global.U[0];
                                                                        let _e8923 = _uv_6;
                                                                        let _e8932 = _mirror_wrap(((vec2<f32>((_e8916.x / _e8920.x), _e8923.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e8934 = textureSampleLevel(t_source, samp, _e8932, 0f);
                                                                        inc_6 = _e8934;
                                                                        let _e8936 = inc_6;
                                                                        let _e8938 = rgb_4;
                                                                        dist_9 = length((_e8936.xyz - _e8938.xyz));
                                                                        let _e8946 = dist_9;
                                                                        let _e8948 = s_9;
                                                                        k_34 = (1f - (smoothstep(0f, 1.7f, _e8946) * _e8948));
                                                                        let _e8952 = inc_6;
                                                                        let _e8953 = rgb_4;
                                                                        let _e8954 = k_34;
                                                                        rgb_4 = mix(_e8952, _e8953, vec4(_e8954));
                                                                        let _e8957 = rgb_4;
                                                                        outCol = _e8957;
                                                                    }
                                                                } else {
                                                                    let _e8958 = mode_6;
                                                                    if (_e8958 == 11i) {
                                                                        {
                                                                            let _e8964 = inverseTileTransform_4[0];
                                                                            N_23 = round((4f * abs(_e8964.x)));
                                                                            let _e8971 = v_7;
                                                                            let _e8975 = N_23;
                                                                            let _e8978 = N_23;
                                                                            let _e8985 = N_23;
                                                                            center_18 = (vec2<f32>(0f, ((((floor(((_e8971.y + 0.5f) * _e8975)) / _e8978) * 2f) - 1f) + (1f / _e8985))) * 0.5f);
                                                                            let _e8992 = v_7;
                                                                            let _e8993 = center_18;
                                                                            dv_8 = abs((_e8992 - _e8993));
                                                                            let _e8997 = dv_8;
                                                                            let _e9001 = dv_8;
                                                                            let _e9004 = N_23;
                                                                            if ((_e8997.x < 0.45f) && (_e9001.y < (0.4f / _e9004))) {
                                                                                {
                                                                                    let _e9010 = inverseTileTransform_4[2];
                                                                                    s_10 = (_e9010.x + 1f);
                                                                                    let _e9015 = inverseCurrentTransform_6;
                                                                                    let _e9016 = relId_6;
                                                                                    let _e9017 = s_10;
                                                                                    let _e9027 = tf(_e9015, (_e9016 + ((_e9017 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_18 = _e9027;
                                                                                    let _e9029 = inverseCurrentTransform_6;
                                                                                    let _e9030 = relId_6;
                                                                                    let _e9031 = s_10;
                                                                                    let _e9040 = tf(_e9029, (_e9030 + ((_e9031 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_18 = _e9040;
                                                                                    let _e9042 = u1_18;
                                                                                    let _e9046 = global.U[0];
                                                                                    let _e9049 = u1_18;
                                                                                    let _e9058 = _mirror_wrap(((vec2<f32>((_e9042.x / _e9046.x), _e9049.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e9060 = textureSampleLevel(t_source, samp, _e9058, 0f);
                                                                                    let _e9061 = u2_18;
                                                                                    let _e9065 = global.U[0];
                                                                                    let _e9068 = u2_18;
                                                                                    let _e9077 = _mirror_wrap(((vec2<f32>((_e9061.x / _e9065.x), _e9068.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e9079 = textureSampleLevel(t_source, samp, _e9077, 0f);
                                                                                    let _e9080 = center_18;
                                                                                    outCol = mix(_e9060, _e9079, vec4((_e9080.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e9086 = mode_6;
                                                                        if (_e9086 == 12i) {
                                                                            {
                                                                                let _e9089 = v_7;
                                                                                v_7 = (_e9089 * vec2<f32>(2f, 2f));
                                                                                let _e9094 = inverseTileTransform_4;
                                                                                let _e9095 = v_7;
                                                                                let _e9096 = tf(_e9094, _e9095);
                                                                                v_7 = _e9096;
                                                                                let _e9097 = inverseCurrentTransform_6;
                                                                                let _e9098 = relId_6;
                                                                                let _e9099 = v_7;
                                                                                let _e9104 = tf(_e9097, (_e9098 + (_e9099 + vec2(0.5f))));
                                                                                let _e9108 = global.U[0];
                                                                                let _e9111 = inverseCurrentTransform_6;
                                                                                let _e9112 = relId_6;
                                                                                let _e9113 = v_7;
                                                                                let _e9118 = tf(_e9111, (_e9112 + (_e9113 + vec2(0.5f))));
                                                                                let _e9127 = _mirror_wrap(((vec2<f32>((_e9104.x / _e9108.x), _e9118.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e9129 = textureSampleLevel(t_source, samp, _e9127, 0f);
                                                                                outCol = _e9129;
                                                                            }
                                                                        } else {
                                                                            let _e9130 = mode_6;
                                                                            if (_e9130 == 13i) {
                                                                                {
                                                                                    let _e9133 = _uv_6;
                                                                                    let _e9137 = global.U[0];
                                                                                    let _e9140 = _uv_6;
                                                                                    let _e9149 = _mirror_wrap(((vec2<f32>((_e9133.x / _e9137.x), _e9140.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e9151 = textureSampleLevel(t_source, samp, _e9149, 0f);
                                                                                    let _e9153 = luma(_e9151.xyz);
                                                                                    lum_12 = _e9153;
                                                                                    let _e9155 = inverseTileTransform_4;
                                                                                    let _e9156 = v_7;
                                                                                    let _e9161 = tf(_e9155, (_e9156 * vec2<f32>(8f, 8f)));
                                                                                    v_7 = _e9161;
                                                                                    let _e9162 = v_7;
                                                                                    let _e9165 = (_e9162.y + 1f);
                                                                                    y_4 = abs(((_e9165 - (floor((_e9165 / 2f)) * 2f)) - 1f));
                                                                                    let _e9175 = lum_12;
                                                                                    let _e9176 = y_4;
                                                                                    if (_e9175 > _e9176) {
                                                                                        local_36 = 1f;
                                                                                    } else {
                                                                                        local_36 = 0f;
                                                                                    }
                                                                                    let _e9181 = local_36;
                                                                                    k_35 = _e9181;
                                                                                    let _e9183 = k_35;
                                                                                    let _e9184 = vec3(_e9183);
                                                                                    outCol = vec4<f32>(_e9184.x, _e9184.y, _e9184.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e9190 = mode_6;
                                                                                if (_e9190 == 14i) {
                                                                                    {
                                                                                        let _e9193 = id_4;
                                                                                        let _e9197 = global.U[0];
                                                                                        let _e9200 = id_4;
                                                                                        let _e9209 = _mirror_wrap(((vec2<f32>((_e9193.x / _e9197.x), _e9200.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e9211 = textureSampleLevel(t_source, samp, _e9209, 0f);
                                                                                        let _e9213 = luma(_e9211.xyz);
                                                                                        lum_13 = _e9213;
                                                                                        let _e9217 = tileTransform_4[0];
                                                                                        contrast_4 = length(_e9217.xy);
                                                                                        let _e9221 = v_7;
                                                                                        let _e9224 = (_e9221 + vec2(0.5f));
                                                                                        let _e9226 = contrast_4;
                                                                                        let _e9227 = lum_13;
                                                                                        outCol = vec4<f32>(_e9224.x, _e9224.y, (0.5f + (_e9226 * (_e9227 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e9236 = mode_6;
                                                                                    if (_e9236 == 15i) {
                                                                                        {
                                                                                            let _e9239 = rnd_6;
                                                                                            center_19 = (sign((_e9239 - vec2(0.5f))) * 0.5f);
                                                                                            let _e9247 = v_7;
                                                                                            let _e9248 = center_19;
                                                                                            dv_9 = (_e9247 - _e9248);
                                                                                            let _e9254 = inverseTileTransform_4[0];
                                                                                            N_24 = floor((16f * length(_e9254.xy)));
                                                                                            let _e9262 = dv_9;
                                                                                            let _e9264 = dv_9;
                                                                                            let _e9267 = angOffset_4;
                                                                                            ang_34 = (atan2(_e9262.y, _e9264.x) + _e9267);
                                                                                            let _e9270 = ang_34;
                                                                                            let _e9273 = N_24;
                                                                                            let _e9276 = (((_e9270 / 3.1415927f) * _e9273) * 2f);
                                                                                            k_36 = abs(((_e9276 - (floor((_e9276 / 2f)) * 2f)) - 1f));
                                                                                            let _e9288 = inverseTileTransform_4[0];
                                                                                            let _e9292 = inverseTileTransform_4[0];
                                                                                            kCol_4 = (atan2(_e9288.y, _e9292.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e9302 = i_13;
                                                                                                if !((_e9302 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e9309 = inverseCurrentTransform_6;
                                                                                                    let _e9310 = relId_6;
                                                                                                    let _e9313 = i_13;
                                                                                                    let _e9317 = ang_34;
                                                                                                    let _e9319 = ang_34;
                                                                                                    let _e9324 = tf(_e9309, (_e9310 + ((0.1f + (0.15f * f32(_e9313))) * vec2<f32>(cos(_e9317), sin(_e9319)))));
                                                                                                    w_19 = _e9324;
                                                                                                    let _e9326 = lum_14;
                                                                                                    let _e9327 = w_19;
                                                                                                    let _e9331 = global.U[0];
                                                                                                    let _e9334 = w_19;
                                                                                                    let _e9343 = _mirror_wrap(((vec2<f32>((_e9327.x / _e9331.x), _e9334.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9345 = textureSampleLevel(t_source, samp, _e9343, 0f);
                                                                                                    let _e9347 = luma(_e9345.xyz);
                                                                                                    lum_14 = (_e9326 + _e9347);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e9306 = i_13;
                                                                                                    i_13 = (_e9306 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e9349 = lum_14;
                                                                                            lum_14 = (_e9349 / 5f);
                                                                                            let _e9352 = lum_14;
                                                                                            let _e9353 = k_36;
                                                                                            if (_e9352 > _e9353) {
                                                                                                local_37 = 1f;
                                                                                            } else {
                                                                                                local_37 = 0f;
                                                                                            }
                                                                                            let _e9358 = local_37;
                                                                                            k_36 = _e9358;
                                                                                            let _e9359 = kCol_4;
                                                                                            if (_e9359 == 0f) {
                                                                                                {
                                                                                                    let _e9362 = k_36;
                                                                                                    let _e9363 = vec3(_e9362);
                                                                                                    outCol = vec4<f32>(_e9363.x, _e9363.y, _e9363.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e9371 = inverseTileTransform_4[2];
                                                                                                    u1_19 = vec2<f32>(_e9371.x, 0f);
                                                                                                    let _e9379 = inverseTileTransform_4[2];
                                                                                                    u2_19 = vec2<f32>(0f, _e9379.y);
                                                                                                    let _e9383 = kCol_4;
                                                                                                    if (_e9383 > 0f) {
                                                                                                        {
                                                                                                            let _e9386 = u1_19;
                                                                                                            let _e9387 = id_4;
                                                                                                            u1_19 = (_e9386 + _e9387);
                                                                                                            let _e9389 = u2_19;
                                                                                                            let _e9390 = id_4;
                                                                                                            u2_19 = (_e9389 + (_e9390 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e9395 = u1_19;
                                                                                                    let _e9399 = global.U[0];
                                                                                                    let _e9402 = u1_19;
                                                                                                    let _e9411 = _mirror_wrap(((vec2<f32>((_e9395.x / _e9399.x), _e9402.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9413 = textureSampleLevel(t_source, samp, _e9411, 0f);
                                                                                                    col1_16 = _e9413;
                                                                                                    let _e9415 = u2_19;
                                                                                                    let _e9419 = global.U[0];
                                                                                                    let _e9422 = u2_19;
                                                                                                    let _e9431 = _mirror_wrap(((vec2<f32>((_e9415.x / _e9419.x), _e9422.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9433 = textureSampleLevel(t_source, samp, _e9431, 0f);
                                                                                                    col2_15 = _e9433;
                                                                                                    let _e9435 = col1_16;
                                                                                                    let _e9437 = luma(_e9435.xyz);
                                                                                                    let _e9438 = col2_15;
                                                                                                    let _e9440 = luma(_e9438.xyz);
                                                                                                    if (_e9437 > _e9440) {
                                                                                                        let _e9443 = k_36;
                                                                                                        k_36 = (1f - _e9443);
                                                                                                    }
                                                                                                    let _e9445 = k_36;
                                                                                                    let _e9446 = vec3(_e9445);
                                                                                                    outCol1_4 = vec4<f32>(_e9446.x, _e9446.y, _e9446.z, 1f);
                                                                                                    let _e9453 = col1_16;
                                                                                                    let _e9454 = col2_15;
                                                                                                    let _e9455 = k_36;
                                                                                                    outCol2_4 = mix(_e9453, _e9454, vec4(_e9455));
                                                                                                    let _e9459 = outCol1_4;
                                                                                                    let _e9460 = outCol2_4;
                                                                                                    let _e9461 = kCol_4;
                                                                                                    outCol = mix(_e9459, _e9460, vec4(abs(_e9461)));
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                let _e9465 = src2_1;
                let _e9466 = outCol;
                let _e9467 = mergeColor(_e9465, _e9466);
                col2_16 = _e9467;
                let _e9469 = col1_13;
                let _e9471 = col2_16;
                let _e9473 = k_22;
                let _e9475 = mix(_e9469.xyz, _e9471.xyz, vec3(_e9473));
                outCol = vec4<f32>(_e9475.x, _e9475.y, _e9475.z, 1f);
            }
        } else {
            {
                {
                    let _e9481 = _uv_4;
                    _uv_7 = _e9481;
                    let _e9483 = _params_1;
                    startScale_9 = _e9483.startScale;
                    let _e9486 = _params_1;
                    subLevels_7 = _e9486.subLevels;
                    let _e9489 = _params_1;
                    subThreshold_7 = _e9489.subThreshold;
                    let _e9492 = _params_1;
                    seed_7 = _e9492.seed;
                    let _e9495 = _params_1;
                    hashStyle_9 = _e9495.hashStyle;
                    let _e9498 = _params_1;
                    coverage_7 = _e9498.coverage;
                    let _e9501 = _params_1;
                    currentTransform_7 = _e9501.transform;
                    let _e9504 = _params_1;
                    inverseCurrentTransform_7 = _e9504.inverseTransform;
                    let _e9507 = startScale_9;
                    scale_10 = _e9507;
                    loop {
                        let _e9515 = i_14;
                        let _e9516 = subLevels_7;
                        if !((_e9515 < _e9516)) {
                            break;
                        }
                        {
                            let _e9522 = i_14;
                            if (_e9522 != 0f) {
                                {
                                    let _e9538 = currentTransform_7;
                                    currentTransform_7 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e9538);
                                    let _e9540 = inverseCurrentTransform_7;
                                    inverseCurrentTransform_7 = (_e9540 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e9555 = currentTransform_7;
                            let _e9556 = _uv_7;
                            let _e9557 = tf(_e9555, _e9556);
                            relId_7 = floor(_e9557);
                            let _e9559 = relId_7;
                            let _e9561 = (_e9559 * 0.13137f);
                            let _e9562 = i_14;
                            let _e9563 = seed_7;
                            let _e9567 = hashStyle_9;
                            let _e9568 = hash42sp(vec4<f32>(_e9561.x, _e9561.y, _e9562, _e9563), _e9567);
                            rnd_7 = _e9568;
                            let _e9569 = i_14;
                            let _e9570 = subLevels_7;
                            let _e9574 = rnd_7;
                            let _e9576 = subThreshold_7;
                            if ((_e9569 == (_e9570 - 1f)) || (_e9574.x > _e9576)) {
                                {
                                    break;
                                }
                            }
                            let _e9579 = scale_10;
                            scale_10 = (_e9579 * 2f);
                        }
                        continuing {
                            let _e9519 = i_14;
                            i_14 = (_e9519 + 1f);
                        }
                    }
                    let _e9582 = inverseCurrentTransform_7;
                    let _e9583 = relId_7;
                    let _e9584 = tf(_e9582, _e9583);
                    id_5 = _e9584;
                    let _e9586 = rnd_7;
                    modeIndex_5 = i32(floor((_e9586.y * 4f)));
                    let _e9593 = modeIndex_5;
                    let _e9596 = _params_1.modeMap[_e9593];
                    mode_7 = _e9596;
                    let _e9599 = modeIndex_5;
                    if (_e9599 == 0i) {
                        let _e9602 = tileTransform1_1;
                        tileTransform_5 = _e9602;
                    } else {
                        let _e9603 = modeIndex_5;
                        if (_e9603 == 1i) {
                            let _e9606 = tileTransform2_1;
                            tileTransform_5 = _e9606;
                        } else {
                            let _e9607 = modeIndex_5;
                            if (_e9607 == 2i) {
                                let _e9610 = tileTransform3_1;
                                tileTransform_5 = _e9610;
                            } else {
                                let _e9611 = tileTransform4_1;
                                tileTransform_5 = _e9611;
                            }
                        }
                    }
                    let _e9612 = tileTransform_5;
                    inverseTileTransform_5 = _naga_inverse_3x3_f32(_e9612);
                    let _e9615 = currentTransform_7;
                    let _e9616 = _uv_7;
                    let _e9617 = tf(_e9615, _e9616);
                    let _e9618 = relId_7;
                    v_8 = ((_e9617 - _e9618) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e9625 = rnd_7;
                    let _e9629 = rnd_7;
                    let _e9635 = coverage_7;
                    if (fract(((_e9625.x * 6.222f) + (_e9629.y * 8.233f))) <= _e9635) {
                        {
                            let _e9637 = mode_7;
                            if (_e9637 == 0i) {
                                {
                                    let _e9642 = inverseTileTransform_5[0];
                                    w_20 = _e9642.xy;
                                    let _e9645 = w_20;
                                    let _e9649 = w_20;
                                    w_20 = floor(vec2<f32>(dot(_e9645, vec2(20f)), dot(_e9649, vec2<f32>(20f, -20f))));
                                    let _e9657 = relId_7;
                                    let _e9659 = v_8;
                                    let _e9660 = w_20;
                                    let _e9665 = tileTransform_5[0];
                                    let _e9672 = inverseTileTransform_5[2];
                                    let _e9675 = w_20;
                                    pixId_10 = (_e9657 + (1.23f * (floor((_e9659 * _e9660)) + floor((((length(_e9665.xy) * 5f) * _e9672.xy) * _e9675)))));
                                    let _e9682 = pixId_10;
                                    let _e9683 = hash22_(_e9682);
                                    let _e9687 = global.U[0];
                                    let _e9690 = pixId_10;
                                    let _e9691 = hash22_(_e9690);
                                    let _e9700 = _mirror_wrap(((vec2<f32>((_e9683.x / _e9687.x), _e9691.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e9702 = textureSampleLevel(t_source, samp, _e9700, 0f);
                                    outCol = _e9702;
                                }
                            } else {
                                let _e9703 = mode_7;
                                if (_e9703 == 1i) {
                                    {
                                        let _e9707 = v_8;
                                        let _e9710 = v_8;
                                        v_8 = vec2<f32>(0f, max(abs(_e9707.x), abs(_e9710.y)));
                                        let _e9715 = inverseCurrentTransform_7;
                                        let _e9716 = relId_7;
                                        let _e9717 = inverseTileTransform_5;
                                        let _e9718 = v_8;
                                        let _e9719 = tf(_e9717, _e9718);
                                        let _e9724 = tf(_e9715, (_e9716 + (_e9719 + vec2(0.5f))));
                                        vv_10 = _e9724;
                                        let _e9726 = vv_10;
                                        let _e9730 = global.U[0];
                                        let _e9733 = vv_10;
                                        let _e9742 = _mirror_wrap(((vec2<f32>((_e9726.x / _e9730.x), _e9733.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e9744 = textureSampleLevel(t_source, samp, _e9742, 0f);
                                        outCol = _e9744;
                                    }
                                } else {
                                    let _e9745 = mode_7;
                                    if (_e9745 == 2i) {
                                        {
                                            let _e9751 = inverseTileTransform_5[2];
                                            size_15 = (0.5f + _e9751.y);
                                            let _e9755 = v_8;
                                            d_10 = length(_e9755);
                                            let _e9758 = v_8;
                                            let _e9760 = v_8;
                                            ang_35 = atan2(_e9758.y, _e9760.x);
                                            let _e9764 = d_10;
                                            let _e9765 = size_15;
                                            if (_e9764 <= _e9765) {
                                                {
                                                    let _e9770 = spikeCount_5;
                                                    anglePeriod_5 = (6.2831855f / _e9770);
                                                    let _e9773 = ang_35;
                                                    let _e9774 = anglePeriod_5;
                                                    let _e9777 = anglePeriod_5;
                                                    a1_5 = (floor((_e9773 / _e9774)) * _e9777);
                                                    let _e9780 = a1_5;
                                                    let _e9781 = anglePeriod_5;
                                                    a2_5 = (_e9780 + _e9781);
                                                    let _e9784 = ang_35;
                                                    let _e9785 = a1_5;
                                                    let _e9787 = anglePeriod_5;
                                                    k_37 = ((_e9784 - _e9785) / _e9787);
                                                    let _e9790 = d_10;
                                                    let _e9795 = inverseTileTransform_5[0];
                                                    ds_10 = ((_e9790 * 10f) * length(_e9795.xy));
                                                    let _e9800 = relId_7;
                                                    center_20 = (_e9800 + vec2(0.5f));
                                                    let _e9805 = inverseCurrentTransform_7;
                                                    let _e9806 = center_20;
                                                    let _e9807 = ds_10;
                                                    let _e9808 = a1_5;
                                                    let _e9810 = a1_5;
                                                    let _e9817 = inverseTileTransform_5[2];
                                                    let _e9821 = tf(_e9805, ((_e9806 + (_e9807 * vec2<f32>(cos(_e9808), sin(_e9810)))) + vec2(_e9817.x)));
                                                    u1_20 = _e9821;
                                                    let _e9823 = inverseCurrentTransform_7;
                                                    let _e9824 = center_20;
                                                    let _e9825 = ds_10;
                                                    let _e9826 = a2_5;
                                                    let _e9828 = a2_5;
                                                    let _e9835 = inverseTileTransform_5[2];
                                                    let _e9839 = tf(_e9823, ((_e9824 + (_e9825 * vec2<f32>(cos(_e9826), sin(_e9828)))) + vec2(_e9835.x)));
                                                    u2_20 = _e9839;
                                                    let _e9841 = u1_20;
                                                    let _e9845 = global.U[0];
                                                    let _e9848 = u1_20;
                                                    let _e9857 = _mirror_wrap(((vec2<f32>((_e9841.x / _e9845.x), _e9848.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e9859 = textureSampleLevel(t_source, samp, _e9857, 0f);
                                                    col1_17 = _e9859;
                                                    let _e9861 = u2_20;
                                                    let _e9865 = global.U[0];
                                                    let _e9868 = u2_20;
                                                    let _e9877 = _mirror_wrap(((vec2<f32>((_e9861.x / _e9865.x), _e9868.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e9879 = textureSampleLevel(t_source, samp, _e9877, 0f);
                                                    col2_17 = _e9879;
                                                    let _e9881 = col1_17;
                                                    let _e9882 = col2_17;
                                                    let _e9883 = k_37;
                                                    outCol = mix(_e9881, _e9882, vec4(_e9883));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e9886 = mode_7;
                                        if (_e9886 == 3i) {
                                            {
                                                let _e9889 = v_8;
                                                let _e9892 = v_8;
                                                vert_5 = (abs(_e9889.y) > abs(_e9892.x));
                                                let _e9897 = vert_5;
                                                if _e9897 {
                                                    let _e9898 = v_8;
                                                    local_38 = _e9898.y;
                                                } else {
                                                    let _e9900 = v_8;
                                                    local_38 = _e9900.x;
                                                }
                                                let _e9903 = local_38;
                                                a_5 = _e9903;
                                                let _e9905 = vert_5;
                                                if _e9905 {
                                                    let _e9906 = a_5;
                                                    let _e9908 = a_5;
                                                    local_39 = vec2<f32>(-(_e9906), _e9908);
                                                } else {
                                                    let _e9910 = a_5;
                                                    let _e9911 = a_5;
                                                    local_39 = vec2<f32>(_e9910, -(_e9911));
                                                }
                                                let _e9915 = local_39;
                                                u1_21 = _e9915;
                                                let _e9917 = a_5;
                                                let _e9918 = a_5;
                                                u2_21 = vec2<f32>(_e9917, _e9918);
                                                let _e9921 = v_8;
                                                let _e9923 = v_8;
                                                let _e9927 = a_5;
                                                k_38 = ((_e9921.x + _e9923.y) / (2f * _e9927));
                                                let _e9931 = inverseCurrentTransform_7;
                                                let _e9932 = relId_7;
                                                let _e9933 = inverseTileTransform_5;
                                                let _e9934 = u1_21;
                                                let _e9935 = tf(_e9933, _e9934);
                                                let _e9940 = tf(_e9931, (_e9932 + (_e9935 + vec2(0.5f))));
                                                u1_21 = _e9940;
                                                let _e9941 = inverseCurrentTransform_7;
                                                let _e9942 = relId_7;
                                                let _e9943 = inverseTileTransform_5;
                                                let _e9944 = u2_21;
                                                let _e9945 = tf(_e9943, _e9944);
                                                let _e9950 = tf(_e9941, (_e9942 + (_e9945 + vec2(0.5f))));
                                                u2_21 = _e9950;
                                                let _e9951 = u1_21;
                                                let _e9955 = global.U[0];
                                                let _e9958 = u1_21;
                                                let _e9967 = _mirror_wrap(((vec2<f32>((_e9951.x / _e9955.x), _e9958.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e9969 = textureSampleLevel(t_source, samp, _e9967, 0f);
                                                col1_18 = _e9969;
                                                let _e9971 = u2_21;
                                                let _e9975 = global.U[0];
                                                let _e9978 = u2_21;
                                                let _e9987 = _mirror_wrap(((vec2<f32>((_e9971.x / _e9975.x), _e9978.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e9989 = textureSampleLevel(t_source, samp, _e9987, 0f);
                                                col2_18 = _e9989;
                                                let _e9991 = col1_18;
                                                let _e9992 = col2_18;
                                                let _e9993 = k_38;
                                                outCol = mix(_e9991, _e9992, vec4(_e9993));
                                            }
                                        } else {
                                            let _e9996 = mode_7;
                                            if (_e9996 == 4i) {
                                                {
                                                    let _e10003 = inverseTileTransform_5[0];
                                                    let _e10007 = inverseTileTransform_5[0];
                                                    ang_36 = atan2(_e10003.y, _e10007.x);
                                                    let _e10011 = ang_36;
                                                    if (_e10011 < 0f) {
                                                        let _e10014 = relId_7;
                                                        let _e10016 = relId_7;
                                                        let _e10018 = (_e10014.x + _e10016.y);
                                                        local_40 = sign(((_e10018 - (floor((_e10018 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_40 = 1f;
                                                    }
                                                    let _e10029 = local_40;
                                                    orientation_5 = _e10029;
                                                    let _e10031 = rnd_7;
                                                    let _e10033 = ang_36;
                                                    if (_e10031.y > (abs(_e10033) / 3.1415927f)) {
                                                        let _e10038 = orientation_5;
                                                        orientation_5 = -(_e10038);
                                                    }
                                                    let _e10040 = orientation_5;
                                                    let _e10041 = v_8;
                                                    let _e10044 = v_8;
                                                    if (((_e10040 * _e10041.x) * _e10044.y) < 0f) {
                                                        local_41 = 40f;
                                                    } else {
                                                        local_41 = 2.5f;
                                                    }
                                                    let _e10052 = local_41;
                                                    p_10 = _e10052;
                                                    let _e10054 = p_10;
                                                    if (_e10054 > 30f) {
                                                        let _e10057 = v_8;
                                                        let _e10060 = v_8;
                                                        local_42 = max(abs(_e10057.x), abs(_e10060.y));
                                                    } else {
                                                        let _e10064 = v_8;
                                                        let _e10067 = p_10;
                                                        let _e10069 = v_8;
                                                        let _e10072 = p_10;
                                                        let _e10076 = p_10;
                                                        local_42 = pow((pow(abs(_e10064.x), _e10067) + pow(abs(_e10069.y), _e10072)), (1f / _e10076));
                                                    }
                                                    let _e10080 = local_42;
                                                    d_11 = _e10080;
                                                    let _e10083 = d_11;
                                                    v_8 = vec2<f32>(0f, _e10083);
                                                    let _e10085 = v_8;
                                                    let _e10087 = size_16;
                                                    if (_e10085.y <= _e10087) {
                                                        {
                                                            let _e10089 = inverseCurrentTransform_7;
                                                            let _e10090 = relId_7;
                                                            let _e10091 = inverseTileTransform_5;
                                                            let _e10092 = v_8;
                                                            let _e10093 = tf(_e10091, _e10092);
                                                            let _e10098 = tf(_e10089, (_e10090 + (_e10093 + vec2(0.5f))));
                                                            vv_11 = _e10098;
                                                            let _e10100 = vv_11;
                                                            let _e10104 = global.U[0];
                                                            let _e10107 = vv_11;
                                                            let _e10116 = _mirror_wrap(((vec2<f32>((_e10100.x / _e10104.x), _e10107.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e10118 = textureSampleLevel(t_source, samp, _e10116, 0f);
                                                            outCol = _e10118;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e10119 = mode_7;
                                                if (_e10119 <= 6i) {
                                                    {
                                                        let _e10124 = inverseTileTransform_5[0];
                                                        scale_11 = length(_e10124.xy);
                                                        let _e10128 = scale_11;
                                                        invert_5 = (_e10128 < 1f);
                                                        let _e10132 = invert_5;
                                                        if _e10132 {
                                                            let _e10134 = scale_11;
                                                            scale_11 = (1f / _e10134);
                                                        }
                                                        let _e10136 = scale_11;
                                                        ds_11 = fract(_e10136);
                                                        let _e10139 = scale_11;
                                                        N_25 = max(floor(_e10139), 1f);
                                                        let _e10144 = v_8;
                                                        let _e10148 = N_25;
                                                        w_21 = (fract(((_e10144 + vec2(0.5f)) * _e10148)) - vec2(0.5f));
                                                        let _e10155 = v_8;
                                                        let _e10159 = N_25;
                                                        let _e10162 = N_25;
                                                        let _e10171 = N_25;
                                                        center_21 = ((((floor(((_e10155 + vec2(0.5f)) * _e10159)) / vec2(_e10162)) * 2f) - vec2(1f)) + vec2((1f / _e10171)));
                                                        let _e10178 = inverseTileTransform_5[0];
                                                        let _e10182 = inverseTileTransform_5[0];
                                                        ang_37 = atan2(_e10178.y, _e10182.x);
                                                        let _e10190 = ang_37;
                                                        if (_e10190 > 0f) {
                                                            let _e10194 = ang_37;
                                                            keepX_5 = (1f - (_e10194 / 3.1415927f));
                                                        } else {
                                                            let _e10199 = ang_37;
                                                            keepY_5 = (1f + (_e10199 / 3.1415927f));
                                                        }
                                                        let _e10203 = center_21;
                                                        let _e10206 = keepX_5;
                                                        let _e10208 = center_21;
                                                        let _e10211 = keepY_5;
                                                        hide_5 = ((abs(_e10203.x) > _e10206) || (abs(_e10208.y) > _e10211));
                                                        let _e10217 = ds_11;
                                                        size_17 = mix(0.5f, 0.15f, _e10217);
                                                        let _e10220 = mode_7;
                                                        let _e10223 = w_21;
                                                        let _e10225 = size_17;
                                                        let _e10228 = mode_7;
                                                        let _e10231 = w_21;
                                                        let _e10234 = size_17;
                                                        let _e10236 = w_21;
                                                        let _e10239 = size_17;
                                                        outside_5 = (((_e10220 == 6i) && (length(_e10223) > _e10225)) || ((_e10228 == 5i) && ((abs(_e10231.x) > _e10234) || (abs(_e10236.y) > _e10239))));
                                                        let _e10245 = hide_5;
                                                        let _e10246 = outside_5;
                                                        if !((_e10245 || _e10246)) {
                                                            {
                                                                let _e10249 = id_5;
                                                                let _e10252 = inverseTileTransform_5[2];
                                                                let _e10258 = global.U[0];
                                                                let _e10261 = id_5;
                                                                let _e10264 = inverseTileTransform_5[2];
                                                                let _e10275 = _mirror_wrap(((vec2<f32>(((_e10249 + _e10252.xy).x / _e10258.x), (_e10261 + _e10264.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e10277 = textureSampleLevel(t_source, samp, _e10275, 0f);
                                                                outCol = _e10277;
                                                            }
                                                        } else {
                                                            let _e10278 = invert_5;
                                                            if _e10278 {
                                                                {
                                                                    let _e10279 = id_5;
                                                                    let _e10283 = global.U[0];
                                                                    let _e10286 = id_5;
                                                                    let _e10295 = _mirror_wrap(((vec2<f32>((_e10279.x / _e10283.x), _e10286.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e10297 = textureSampleLevel(t_source, samp, _e10295, 0f);
                                                                    outCol = _e10297;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e10298 = mode_7;
                                                    if (_e10298 == 7i) {
                                                        {
                                                            let _e10303 = inverseTileTransform_5[0];
                                                            w_22 = _e10303.xy;
                                                            let _e10306 = w_22;
                                                            let _e10310 = w_22;
                                                            w_22 = floor(vec2<f32>(dot(_e10306, vec2(16f)), dot(_e10310, vec2<f32>(16f, -16f))));
                                                            let _e10318 = startScale_9;
                                                            let _e10325 = inverseTileTransform_5[2];
                                                            minScale_5 = ((_e10318 * 2f) * pow(2f, floor((2f * _e10325.y))));
                                                            let _e10332 = minScale_5;
                                                            let _e10333 = startScale_9;
                                                            let _e10340 = inverseTileTransform_5[2];
                                                            maxScale_5 = max(_e10332, ((_e10333 * 4f) * pow(2f, floor((2f * _e10340.x)))));
                                                            let _e10348 = scale_10;
                                                            let _e10349 = minScale_5;
                                                            let _e10350 = maxScale_5;
                                                            scale2_10 = clamp(_e10348, _e10349, _e10350);
                                                            let _e10353 = scale2_10;
                                                            let _e10354 = scale_10;
                                                            invScaleRatio_10 = (_e10353 / _e10354);
                                                            let _e10357 = invScaleRatio_10;
                                                            let _e10361 = invScaleRatio_10;
                                                            let _e10370 = currentTransform_7;
                                                            tr_10 = (mat3x3<f32>(vec3<f32>(_e10357, 0f, 0f), vec3<f32>(0f, _e10361, 0f), vec3<f32>(0f, 0f, 1f)) * _e10370);
                                                            let _e10373 = tr_10;
                                                            let _e10374 = _uv_7;
                                                            let _e10375 = tf(_e10373, _e10374);
                                                            v_8 = (_e10375 - vec2(0.5f));
                                                            let _e10379 = v_8;
                                                            let _e10380 = w_22;
                                                            pixId_11 = floor((_e10379 * _e10380));
                                                            let _e10384 = pixId_11;
                                                            let _e10386 = pixId_11;
                                                            let _e10388 = (_e10384.x + _e10386.y);
                                                            k_39 = (_e10388 - (floor((_e10388 / 2f)) * 2f));
                                                            let _e10395 = k_39;
                                                            let _e10396 = vec3(_e10395);
                                                            outCol = vec4<f32>(_e10396.x, _e10396.y, _e10396.z, 1f);
                                                        }
                                                    } else {
                                                        let _e10402 = mode_7;
                                                        if (_e10402 == 8i) {
                                                            {
                                                                let _e10407 = startScale_9;
                                                                scale2_11 = (_e10407 * 4f);
                                                                let _e10411 = scale2_11;
                                                                let _e10412 = scale_10;
                                                                invScaleRatio_11 = (_e10411 / _e10412);
                                                                let _e10415 = invScaleRatio_11;
                                                                let _e10419 = invScaleRatio_11;
                                                                let _e10428 = currentTransform_7;
                                                                tr_11 = (mat3x3<f32>(vec3<f32>(_e10415, 0f, 0f), vec3<f32>(0f, _e10419, 0f), vec3<f32>(0f, 0f, 1f)) * _e10428);
                                                                let _e10431 = tr_11;
                                                                let _e10432 = _uv_7;
                                                                let _e10433 = tf(_e10431, _e10432);
                                                                v_8 = (_e10433 - vec2(0.5f));
                                                                let _e10443 = inverseTileTransform_5[0];
                                                                let _e10447 = inverseTileTransform_5[0];
                                                                let _e10450 = piN_5;
                                                                let _e10453 = piN_5;
                                                                ang_38 = (floor((atan2(_e10443.y, _e10447.x) / _e10450)) * _e10453);
                                                                let _e10456 = ang_38;
                                                                let _e10457 = rotation2_(_e10456);
                                                                let _e10458 = v_8;
                                                                let _e10462 = inverseTileTransform_5[0];
                                                                let _e10469 = inverseTileTransform_5[2];
                                                                v_8 = (((_e10457 * _e10458) * length(_e10462.xy)) + (2f * _e10469.xy));
                                                                let _e10473 = v_8;
                                                                let _e10475 = v_8;
                                                                let _e10477 = rnd_7;
                                                                let _e10484 = Xn_5;
                                                                let _e10486 = floor(((_e10473.x + (_e10475.y * sign((_e10477.y - 0.5f)))) * _e10484));
                                                                k_40 = (_e10486 - (floor((_e10486 / 2f)) * 2f));
                                                                let _e10493 = k_40;
                                                                let _e10494 = vec3(_e10493);
                                                                outCol = vec4<f32>(_e10494.x, _e10494.y, _e10494.z, 1f);
                                                            }
                                                        } else {
                                                            let _e10500 = mode_7;
                                                            if (_e10500 == 9i) {
                                                                {
                                                                    let _e10507 = inverseTileTransform_5[2];
                                                                    N_26 = floor((1000f * pow(0.25f, length(_e10507.xy))));
                                                                    let _e10518 = N_26;
                                                                    let _e10523 = inverseTileTransform_5[1];
                                                                    let _e10527 = inverseTileTransform_5[1];
                                                                    offset_5 = ((1.5707964f + (3.1415927f / _e10518)) + atan2(_e10523.y, _e10527.x));
                                                                    let _e10532 = v_8;
                                                                    let _e10534 = v_8;
                                                                    ang_39 = atan2(_e10532.y, _e10534.x);
                                                                    let _e10538 = ang_39;
                                                                    let _e10539 = offset_5;
                                                                    let _e10543 = N_26;
                                                                    let _e10546 = N_26;
                                                                    let _e10550 = offset_5;
                                                                    ang_39 = (((round((((_e10538 - _e10539) / 6.2831855f) * _e10543)) / _e10546) * 6.2831855f) + _e10550);
                                                                    let _e10554 = inverseTileTransform_5[0];
                                                                    let _e10559 = ang_39;
                                                                    let _e10562 = ang_39;
                                                                    dist_10 = ((length(_e10554.xy) * 0.5f) / max(abs(cos(_e10559)), abs(sin(_e10562))));
                                                                    let _e10568 = dist_10;
                                                                    let _e10569 = ang_39;
                                                                    let _e10571 = ang_39;
                                                                    v_8 = (_e10568 * vec2<f32>(cos(_e10569), sin(_e10571)));
                                                                    let _e10575 = inverseCurrentTransform_7;
                                                                    let _e10576 = relId_7;
                                                                    let _e10577 = v_8;
                                                                    let _e10582 = tf(_e10575, (_e10576 + (_e10577 + vec2(0.5f))));
                                                                    u_11 = _e10582;
                                                                    let _e10584 = u_11;
                                                                    let _e10588 = global.U[0];
                                                                    let _e10591 = u_11;
                                                                    let _e10600 = _mirror_wrap(((vec2<f32>((_e10584.x / _e10588.x), _e10591.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e10602 = textureSampleLevel(t_source, samp, _e10600, 0f);
                                                                    outCol = _e10602;
                                                                }
                                                            } else {
                                                                let _e10603 = mode_7;
                                                                if (_e10603 == 10i) {
                                                                    {
                                                                        let _e10608 = inverseTileTransform_5[0];
                                                                        s_11 = (length(_e10608.xy) * 0.05f);
                                                                        let _e10614 = v_8;
                                                                        v_8 = (_e10614 + vec2(0.5f));
                                                                        let _e10622 = inverseTileTransform_5[0];
                                                                        let _e10626 = inverseTileTransform_5[0];
                                                                        let _e10631 = N_27;
                                                                        let _e10636 = N_27;
                                                                        ang_40 = ((floor(((atan2(_e10622.y, _e10626.x) / 3.1415927f) * _e10631)) * 3.1415927f) / _e10636);
                                                                        let _e10639 = ang_40;
                                                                        let _e10640 = rotation2_(_e10639);
                                                                        let _e10641 = v_8;
                                                                        v_8 = (_e10640 * _e10641);
                                                                        let _e10643 = v_8;
                                                                        let _e10647 = inverseTileTransform_5[2];
                                                                        let _e10651 = tileTransform_5[0];
                                                                        let _e10659 = v_8;
                                                                        let _e10663 = inverseTileTransform_5[2];
                                                                        let _e10667 = tileTransform_5[0];
                                                                        let _e10674 = hslToRgb(vec4<f32>(((_e10643.x + (_e10647.x * length(_e10651.xy))) * 360f), 1f, (_e10659.y + (_e10663.y * length(_e10667.xy))), 1f));
                                                                        rgb_5 = _e10674;
                                                                        let _e10676 = _uv_7;
                                                                        let _e10680 = global.U[0];
                                                                        let _e10683 = _uv_7;
                                                                        let _e10692 = _mirror_wrap(((vec2<f32>((_e10676.x / _e10680.x), _e10683.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e10694 = textureSampleLevel(t_source, samp, _e10692, 0f);
                                                                        inc_7 = _e10694;
                                                                        let _e10696 = inc_7;
                                                                        let _e10698 = rgb_5;
                                                                        dist_11 = length((_e10696.xyz - _e10698.xyz));
                                                                        let _e10706 = dist_11;
                                                                        let _e10708 = s_11;
                                                                        k_41 = (1f - (smoothstep(0f, 1.7f, _e10706) * _e10708));
                                                                        let _e10712 = inc_7;
                                                                        let _e10713 = rgb_5;
                                                                        let _e10714 = k_41;
                                                                        rgb_5 = mix(_e10712, _e10713, vec4(_e10714));
                                                                        let _e10717 = rgb_5;
                                                                        outCol = _e10717;
                                                                    }
                                                                } else {
                                                                    let _e10718 = mode_7;
                                                                    if (_e10718 == 11i) {
                                                                        {
                                                                            let _e10724 = inverseTileTransform_5[0];
                                                                            N_28 = round((4f * abs(_e10724.x)));
                                                                            let _e10731 = v_8;
                                                                            let _e10735 = N_28;
                                                                            let _e10738 = N_28;
                                                                            let _e10745 = N_28;
                                                                            center_22 = (vec2<f32>(0f, ((((floor(((_e10731.y + 0.5f) * _e10735)) / _e10738) * 2f) - 1f) + (1f / _e10745))) * 0.5f);
                                                                            let _e10752 = v_8;
                                                                            let _e10753 = center_22;
                                                                            dv_10 = abs((_e10752 - _e10753));
                                                                            let _e10757 = dv_10;
                                                                            let _e10761 = dv_10;
                                                                            let _e10764 = N_28;
                                                                            if ((_e10757.x < 0.45f) && (_e10761.y < (0.4f / _e10764))) {
                                                                                {
                                                                                    let _e10770 = inverseTileTransform_5[2];
                                                                                    s_12 = (_e10770.x + 1f);
                                                                                    let _e10775 = inverseCurrentTransform_7;
                                                                                    let _e10776 = relId_7;
                                                                                    let _e10777 = s_12;
                                                                                    let _e10787 = tf(_e10775, (_e10776 + ((_e10777 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_22 = _e10787;
                                                                                    let _e10789 = inverseCurrentTransform_7;
                                                                                    let _e10790 = relId_7;
                                                                                    let _e10791 = s_12;
                                                                                    let _e10800 = tf(_e10789, (_e10790 + ((_e10791 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_22 = _e10800;
                                                                                    let _e10802 = u1_22;
                                                                                    let _e10806 = global.U[0];
                                                                                    let _e10809 = u1_22;
                                                                                    let _e10818 = _mirror_wrap(((vec2<f32>((_e10802.x / _e10806.x), _e10809.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10820 = textureSampleLevel(t_source, samp, _e10818, 0f);
                                                                                    let _e10821 = u2_22;
                                                                                    let _e10825 = global.U[0];
                                                                                    let _e10828 = u2_22;
                                                                                    let _e10837 = _mirror_wrap(((vec2<f32>((_e10821.x / _e10825.x), _e10828.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10839 = textureSampleLevel(t_source, samp, _e10837, 0f);
                                                                                    let _e10840 = center_22;
                                                                                    outCol = mix(_e10820, _e10839, vec4((_e10840.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e10846 = mode_7;
                                                                        if (_e10846 == 12i) {
                                                                            {
                                                                                let _e10849 = v_8;
                                                                                v_8 = (_e10849 * vec2<f32>(2f, 2f));
                                                                                let _e10854 = inverseTileTransform_5;
                                                                                let _e10855 = v_8;
                                                                                let _e10856 = tf(_e10854, _e10855);
                                                                                v_8 = _e10856;
                                                                                let _e10857 = inverseCurrentTransform_7;
                                                                                let _e10858 = relId_7;
                                                                                let _e10859 = v_8;
                                                                                let _e10864 = tf(_e10857, (_e10858 + (_e10859 + vec2(0.5f))));
                                                                                let _e10868 = global.U[0];
                                                                                let _e10871 = inverseCurrentTransform_7;
                                                                                let _e10872 = relId_7;
                                                                                let _e10873 = v_8;
                                                                                let _e10878 = tf(_e10871, (_e10872 + (_e10873 + vec2(0.5f))));
                                                                                let _e10887 = _mirror_wrap(((vec2<f32>((_e10864.x / _e10868.x), _e10878.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e10889 = textureSampleLevel(t_source, samp, _e10887, 0f);
                                                                                outCol = _e10889;
                                                                            }
                                                                        } else {
                                                                            let _e10890 = mode_7;
                                                                            if (_e10890 == 13i) {
                                                                                {
                                                                                    let _e10893 = _uv_7;
                                                                                    let _e10897 = global.U[0];
                                                                                    let _e10900 = _uv_7;
                                                                                    let _e10909 = _mirror_wrap(((vec2<f32>((_e10893.x / _e10897.x), _e10900.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10911 = textureSampleLevel(t_source, samp, _e10909, 0f);
                                                                                    let _e10913 = luma(_e10911.xyz);
                                                                                    lum_15 = _e10913;
                                                                                    let _e10915 = inverseTileTransform_5;
                                                                                    let _e10916 = v_8;
                                                                                    let _e10921 = tf(_e10915, (_e10916 * vec2<f32>(8f, 8f)));
                                                                                    v_8 = _e10921;
                                                                                    let _e10922 = v_8;
                                                                                    let _e10925 = (_e10922.y + 1f);
                                                                                    y_5 = abs(((_e10925 - (floor((_e10925 / 2f)) * 2f)) - 1f));
                                                                                    let _e10935 = lum_15;
                                                                                    let _e10936 = y_5;
                                                                                    if (_e10935 > _e10936) {
                                                                                        local_43 = 1f;
                                                                                    } else {
                                                                                        local_43 = 0f;
                                                                                    }
                                                                                    let _e10941 = local_43;
                                                                                    k_42 = _e10941;
                                                                                    let _e10943 = k_42;
                                                                                    let _e10944 = vec3(_e10943);
                                                                                    outCol = vec4<f32>(_e10944.x, _e10944.y, _e10944.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e10950 = mode_7;
                                                                                if (_e10950 == 14i) {
                                                                                    {
                                                                                        let _e10953 = id_5;
                                                                                        let _e10957 = global.U[0];
                                                                                        let _e10960 = id_5;
                                                                                        let _e10969 = _mirror_wrap(((vec2<f32>((_e10953.x / _e10957.x), _e10960.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e10971 = textureSampleLevel(t_source, samp, _e10969, 0f);
                                                                                        let _e10973 = luma(_e10971.xyz);
                                                                                        lum_16 = _e10973;
                                                                                        let _e10977 = tileTransform_5[0];
                                                                                        contrast_5 = length(_e10977.xy);
                                                                                        let _e10981 = v_8;
                                                                                        let _e10984 = (_e10981 + vec2(0.5f));
                                                                                        let _e10986 = contrast_5;
                                                                                        let _e10987 = lum_16;
                                                                                        outCol = vec4<f32>(_e10984.x, _e10984.y, (0.5f + (_e10986 * (_e10987 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e10996 = mode_7;
                                                                                    if (_e10996 == 15i) {
                                                                                        {
                                                                                            let _e10999 = rnd_7;
                                                                                            center_23 = (sign((_e10999 - vec2(0.5f))) * 0.5f);
                                                                                            let _e11007 = v_8;
                                                                                            let _e11008 = center_23;
                                                                                            dv_11 = (_e11007 - _e11008);
                                                                                            let _e11014 = inverseTileTransform_5[0];
                                                                                            N_29 = floor((16f * length(_e11014.xy)));
                                                                                            let _e11022 = dv_11;
                                                                                            let _e11024 = dv_11;
                                                                                            let _e11027 = angOffset_5;
                                                                                            ang_41 = (atan2(_e11022.y, _e11024.x) + _e11027);
                                                                                            let _e11030 = ang_41;
                                                                                            let _e11033 = N_29;
                                                                                            let _e11036 = (((_e11030 / 3.1415927f) * _e11033) * 2f);
                                                                                            k_43 = abs(((_e11036 - (floor((_e11036 / 2f)) * 2f)) - 1f));
                                                                                            let _e11048 = inverseTileTransform_5[0];
                                                                                            let _e11052 = inverseTileTransform_5[0];
                                                                                            kCol_5 = (atan2(_e11048.y, _e11052.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e11062 = i_15;
                                                                                                if !((_e11062 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e11069 = inverseCurrentTransform_7;
                                                                                                    let _e11070 = relId_7;
                                                                                                    let _e11073 = i_15;
                                                                                                    let _e11077 = ang_41;
                                                                                                    let _e11079 = ang_41;
                                                                                                    let _e11084 = tf(_e11069, (_e11070 + ((0.1f + (0.15f * f32(_e11073))) * vec2<f32>(cos(_e11077), sin(_e11079)))));
                                                                                                    w_23 = _e11084;
                                                                                                    let _e11086 = lum_17;
                                                                                                    let _e11087 = w_23;
                                                                                                    let _e11091 = global.U[0];
                                                                                                    let _e11094 = w_23;
                                                                                                    let _e11103 = _mirror_wrap(((vec2<f32>((_e11087.x / _e11091.x), _e11094.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e11105 = textureSampleLevel(t_source, samp, _e11103, 0f);
                                                                                                    let _e11107 = luma(_e11105.xyz);
                                                                                                    lum_17 = (_e11086 + _e11107);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e11066 = i_15;
                                                                                                    i_15 = (_e11066 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e11109 = lum_17;
                                                                                            lum_17 = (_e11109 / 5f);
                                                                                            let _e11112 = lum_17;
                                                                                            let _e11113 = k_43;
                                                                                            if (_e11112 > _e11113) {
                                                                                                local_44 = 1f;
                                                                                            } else {
                                                                                                local_44 = 0f;
                                                                                            }
                                                                                            let _e11118 = local_44;
                                                                                            k_43 = _e11118;
                                                                                            let _e11119 = kCol_5;
                                                                                            if (_e11119 == 0f) {
                                                                                                {
                                                                                                    let _e11122 = k_43;
                                                                                                    let _e11123 = vec3(_e11122);
                                                                                                    outCol = vec4<f32>(_e11123.x, _e11123.y, _e11123.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e11131 = inverseTileTransform_5[2];
                                                                                                    u1_23 = vec2<f32>(_e11131.x, 0f);
                                                                                                    let _e11139 = inverseTileTransform_5[2];
                                                                                                    u2_23 = vec2<f32>(0f, _e11139.y);
                                                                                                    let _e11143 = kCol_5;
                                                                                                    if (_e11143 > 0f) {
                                                                                                        {
                                                                                                            let _e11146 = u1_23;
                                                                                                            let _e11147 = id_5;
                                                                                                            u1_23 = (_e11146 + _e11147);
                                                                                                            let _e11149 = u2_23;
                                                                                                            let _e11150 = id_5;
                                                                                                            u2_23 = (_e11149 + (_e11150 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e11155 = u1_23;
                                                                                                    let _e11159 = global.U[0];
                                                                                                    let _e11162 = u1_23;
                                                                                                    let _e11171 = _mirror_wrap(((vec2<f32>((_e11155.x / _e11159.x), _e11162.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e11173 = textureSampleLevel(t_source, samp, _e11171, 0f);
                                                                                                    col1_19 = _e11173;
                                                                                                    let _e11175 = u2_23;
                                                                                                    let _e11179 = global.U[0];
                                                                                                    let _e11182 = u2_23;
                                                                                                    let _e11191 = _mirror_wrap(((vec2<f32>((_e11175.x / _e11179.x), _e11182.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e11193 = textureSampleLevel(t_source, samp, _e11191, 0f);
                                                                                                    col2_19 = _e11193;
                                                                                                    let _e11195 = col1_19;
                                                                                                    let _e11197 = luma(_e11195.xyz);
                                                                                                    let _e11198 = col2_19;
                                                                                                    let _e11200 = luma(_e11198.xyz);
                                                                                                    if (_e11197 > _e11200) {
                                                                                                        let _e11203 = k_43;
                                                                                                        k_43 = (1f - _e11203);
                                                                                                    }
                                                                                                    let _e11205 = k_43;
                                                                                                    let _e11206 = vec3(_e11205);
                                                                                                    outCol1_5 = vec4<f32>(_e11206.x, _e11206.y, _e11206.z, 1f);
                                                                                                    let _e11213 = col1_19;
                                                                                                    let _e11214 = col2_19;
                                                                                                    let _e11215 = k_43;
                                                                                                    outCol2_5 = mix(_e11213, _e11214, vec4(_e11215));
                                                                                                    let _e11219 = outCol1_5;
                                                                                                    let _e11220 = outCol2_5;
                                                                                                    let _e11221 = kCol_5;
                                                                                                    outCol = mix(_e11219, _e11220, vec4(abs(_e11221)));
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e11225 = col;
    let _e11226 = outCol;
    let _e11227 = mergeColor(_e11225, _e11226);
    col = _e11227;
    let _e11228 = col;
    return _e11228;
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e87 = global.U[10];
    let _e92 = global.U[11];
    let _e96 = global.U[12];
    let _e101 = global.U[13];
    let _e105 = global.U[14];
    let _e109 = global.U[15];
    let _e114 = global.U[16];
    let _e118 = global.U[17];
    let _e122 = global.U[18];
    let _e127 = global.U[19];
    let _e131 = global.U[20];
    let _e135 = global.U[21];
    let _e139 = global.U[22];
    let _e144 = global.U[23];
    let _e148 = global.U[24];
    let _e149 = _e148.xyz;
    let _e152 = global.U[25];
    let _e153 = _e152.xyz;
    let _e156 = global.U[26];
    let _e157 = _e156.xyz;
    let _e173 = global.U[27];
    let _e174 = _e173.xyz;
    let _e177 = global.U[28];
    let _e178 = _e177.xyz;
    let _e181 = global.U[29];
    let _e182 = _e181.xyz;
    let _e198 = global.U[30];
    let _e199 = _e198.xyz;
    let _e202 = global.U[31];
    let _e203 = _e202.xyz;
    let _e206 = global.U[32];
    let _e207 = _e206.xyz;
    let _e223 = global.U[33];
    let _e224 = _e223.xyz;
    let _e227 = global.U[34];
    let _e228 = _e227.xyz;
    let _e231 = global.U[35];
    let _e232 = _e231.xyz;
    let _e248 = global.U[36];
    let _e249 = _e248.xyz;
    let _e252 = global.U[37];
    let _e253 = _e252.xyz;
    let _e256 = global.U[38];
    let _e257 = _e256.xyz;
    let _e273 = global.U[39];
    let _e274 = _e273.xyz;
    let _e277 = global.U[40];
    let _e278 = _e277.xyz;
    let _e281 = global.U[41];
    let _e282 = _e281.xyz;
    let _e296 = multiGlitch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, i32(_e70.x), _e75.x, _e79.x, _e83.x, i32(_e87.x), _e92.x, i32(_e96.x), _e101.x, _e105.x, i32(_e109.x), _e114.x, _e118.x, i32(_e122.x), _e127.x, _e131.x, _e135.x, i32(_e139.x), _e144.x, mat3x3<f32>(vec3<f32>(_e149.x, _e149.y, _e149.z), vec3<f32>(_e153.x, _e153.y, _e153.z), vec3<f32>(_e157.x, _e157.y, _e157.z)), mat3x3<f32>(vec3<f32>(_e174.x, _e174.y, _e174.z), vec3<f32>(_e178.x, _e178.y, _e178.z), vec3<f32>(_e182.x, _e182.y, _e182.z)), mat3x3<f32>(vec3<f32>(_e199.x, _e199.y, _e199.z), vec3<f32>(_e203.x, _e203.y, _e203.z), vec3<f32>(_e207.x, _e207.y, _e207.z)), mat3x3<f32>(vec3<f32>(_e224.x, _e224.y, _e224.z), vec3<f32>(_e228.x, _e228.y, _e228.z), vec3<f32>(_e232.x, _e232.y, _e232.z)), mat3x3<f32>(vec3<f32>(_e249.x, _e249.y, _e249.z), vec3<f32>(_e253.x, _e253.y, _e253.z), vec3<f32>(_e257.x, _e257.y, _e257.z)), mat3x3<f32>(vec3<f32>(_e274.x, _e274.y, _e274.z), vec3<f32>(_e278.x, _e278.y, _e278.z), vec3<f32>(_e282.x, _e282.y, _e282.z)));
    fragColor = _e296;
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
