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
    let _e78 = textureSample(t_source, samp, _e77);
    col = _e78;
    let _e86 = coverage_1;
    let _e89 = streakCoverage_1;
    if ((_e86 > 0f) || (_e89 > 0f)) {
        {
            let _e93 = modelTransform_1;
            inverseModelTransform = _naga_inverse_3x3_f32(_e93);
            let _e98 = inverseModelTransform[0];
            startScale = length(_e98.xy);
            let _e103 = mode_1;
            if (_e103 < 16i) {
                {
                    loop {
                        let _e108 = i;
                        if !((_e108 < 4i)) {
                            break;
                        }
                        let _e115 = i;
                        let _e117 = mode_1;
                        modeMap[_e115] = _e117;
                        continuing {
                            let _e112 = i;
                            i = (_e112 + 1i);
                        }
                    }
                }
            } else {
                {
                    let _e118 = mode_1;
                    mode_1 = (_e118 - 16i);
                    let _e123 = mode_1;
                    modeMap[0i] = (_e123 & 15i);
                    let _e126 = mode_1;
                    mode_1 = (_e126 / 16i);
                    let _e131 = mode_1;
                    modeMap[1i] = (_e131 & 15i);
                    let _e134 = mode_1;
                    mode_1 = (_e134 / 16i);
                    let _e139 = mode_1;
                    modeMap[2i] = (_e139 & 15i);
                    let _e142 = mode_1;
                    mode_1 = (_e142 / 16i);
                    let _e147 = mode_1;
                    modeMap[3i] = (_e147 & 15i);
                }
            }
            let _e151 = inverseModelTransform;
            params.transform = _e151;
            let _e153 = modelTransform_1;
            params.inverseTransform = _e153;
            let _e155 = startScale;
            params.startScale = _e155;
            let _e157 = levels_1;
            params.subLevels = f32(_e157);
            let _e160 = threshold_1;
            params.subThreshold = _e160;
            let _e166 = modeMap[0];
            params.modeMap[0i] = _e166;
            let _e172 = modeMap[1];
            params.modeMap[1i] = _e172;
            let _e178 = modeMap[2];
            params.modeMap[2i] = _e178;
            let _e184 = modeMap[3];
            params.modeMap[3i] = _e184;
            let _e186 = coverage_1;
            params.coverage = _e186;
            let _e188 = streakCoverage_1;
            params.streakInterpolateCoverage = _e188;
            let _e190 = streakLevels_1;
            params.streakSubLevels = _e190;
            let _e192 = streakBalance_1;
            params.streakVerticality = ((_e192 + 1f) * 0.5f);
            let _e198 = randomSeed_1;
            params.seed = _e198;
            let _e200 = randomType_1;
            params.hashStyle = _e200;
            {
                let _e201 = pos_1;
                _uv = _e201;
                let _e203 = params;
                _params = _e203;
                let _e205 = col;
                _srcCol = _e205;
                let _e207 = _params;
                startScale_1 = _e207.startScale;
                let _e210 = _params;
                subLevels = _e210.subLevels;
                let _e213 = _params;
                subThreshold = _e213.subThreshold;
                let _e216 = _params;
                streakInterpolateCoverage = _e216.streakInterpolateCoverage;
                let _e219 = _params;
                streakSubLevels = _e219.streakSubLevels;
                let _e222 = _params;
                streakVerticality = _e222.streakVerticality;
                let _e225 = _params;
                seed = _e225.seed;
                let _e228 = _params;
                hashStyle_2 = _e228.hashStyle;
                let _e231 = _params;
                currentTransform = _e231.transform;
                let _e234 = _params;
                inverseCurrentTransform = _e234.inverseTransform;
                loop {
                    let _e244 = i_1;
                    let _e245 = streakSubLevels;
                    if !((_e244 < f32(_e245))) {
                        break;
                    }
                    {
                        let _e252 = i_1;
                        if (_e252 != 0f) {
                            {
                                let _e268 = currentTransform;
                                currentTransform = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e268);
                                let _e270 = inverseCurrentTransform;
                                inverseCurrentTransform = (_e270 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                            }
                        }
                        let _e285 = currentTransform;
                        let _e286 = _uv;
                        let _e287 = tf(_e285, _e286);
                        relId = floor(_e287);
                        let _e289 = relId;
                        let _e291 = (_e289 * 0.08845f);
                        let _e292 = i_1;
                        let _e293 = seed;
                        let _e297 = hashStyle_2;
                        let _e298 = hash42sp(vec4<f32>(_e291.x, _e291.y, _e292, _e293), _e297);
                        rnd = _e298;
                        let _e299 = rnd;
                        let _e301 = subThreshold;
                        if (_e299.x > _e301) {
                            {
                                break;
                            }
                        }
                        let _e303 = streakLevel;
                        streakLevel = (_e303 + 1i);
                    }
                    continuing {
                        let _e249 = i_1;
                        i_1 = (_e249 + 1f);
                    }
                }
                let _e306 = rnd;
                let _e308 = streakInterpolateCoverage;
                if (_e306.y <= _e308) {
                    {
                        let _e313 = currentTransform;
                        let _e314 = _uv;
                        let _e315 = tf(_e313, _e314);
                        let _e316 = relId;
                        v_1 = (_e315 - _e316);
                        let _e318 = rnd;
                        let _e323 = streakVerticality;
                        if (fract((_e318.y * 13.323f)) < _e323) {
                            {
                                let _e325 = v_1;
                                k = _e325.y;
                                let _e327 = inverseCurrentTransform;
                                let _e328 = relId;
                                let _e329 = v_1;
                                let _e335 = tf(_e327, (_e328 + vec2<f32>(_e329.x, -0.0001f)));
                                uu1_ = _e335;
                                let _e336 = inverseCurrentTransform;
                                let _e337 = relId;
                                let _e338 = v_1;
                                let _e343 = tf(_e336, (_e337 + vec2<f32>(_e338.x, 0.9999f)));
                                uu2_ = _e343;
                            }
                        } else {
                            {
                                let _e344 = v_1;
                                k = _e344.x;
                                let _e346 = inverseCurrentTransform;
                                let _e347 = relId;
                                let _e350 = v_1;
                                let _e354 = tf(_e346, (_e347 + vec2<f32>(-0.0001f, _e350.y)));
                                uu1_ = _e354;
                                let _e355 = inverseCurrentTransform;
                                let _e356 = relId;
                                let _e358 = v_1;
                                let _e362 = tf(_e355, (_e356 + vec2<f32>(0.9999f, _e358.y)));
                                uu2_ = _e362;
                            }
                        }
                        let _e363 = uu1_;
                        let _e367 = global.U[0];
                        let _e370 = uu1_;
                        let _e379 = _mirror_wrap(((vec2<f32>((_e363.x / _e367.x), _e370.y) / vec2(2f)) + vec2(0.5f)));
                        let _e380 = textureSample(t_source, samp, _e379);
                        src1_ = _e380;
                        let _e382 = uu2_;
                        let _e386 = global.U[0];
                        let _e389 = uu2_;
                        let _e398 = _mirror_wrap(((vec2<f32>((_e382.x / _e386.x), _e389.y) / vec2(2f)) + vec2(0.5f)));
                        let _e399 = textureSample(t_source, samp, _e398);
                        src2_ = _e399;
                        {
                            let _e401 = uu1_;
                            _uv_1 = _e401;
                            let _e403 = _params;
                            startScale_2 = _e403.startScale;
                            let _e406 = _params;
                            subLevels_1 = _e406.subLevels;
                            let _e409 = _params;
                            subThreshold_1 = _e409.subThreshold;
                            let _e412 = _params;
                            seed_1 = _e412.seed;
                            let _e415 = _params;
                            hashStyle_3 = _e415.hashStyle;
                            let _e418 = _params;
                            coverage_2 = _e418.coverage;
                            let _e421 = _params;
                            currentTransform_1 = _e421.transform;
                            let _e424 = _params;
                            inverseCurrentTransform_1 = _e424.inverseTransform;
                            let _e427 = startScale_2;
                            scale = _e427;
                            loop {
                                let _e435 = i_2;
                                let _e436 = subLevels_1;
                                if !((_e435 < _e436)) {
                                    break;
                                }
                                {
                                    let _e442 = i_2;
                                    if (_e442 != 0f) {
                                        {
                                            let _e458 = currentTransform_1;
                                            currentTransform_1 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e458);
                                            let _e460 = inverseCurrentTransform_1;
                                            inverseCurrentTransform_1 = (_e460 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e475 = currentTransform_1;
                                    let _e476 = _uv_1;
                                    let _e477 = tf(_e475, _e476);
                                    relId_1 = floor(_e477);
                                    let _e479 = relId_1;
                                    let _e481 = (_e479 * 0.13137f);
                                    let _e482 = i_2;
                                    let _e483 = seed_1;
                                    let _e487 = hashStyle_3;
                                    let _e488 = hash42sp(vec4<f32>(_e481.x, _e481.y, _e482, _e483), _e487);
                                    rnd_1 = _e488;
                                    let _e489 = i_2;
                                    let _e490 = subLevels_1;
                                    let _e494 = rnd_1;
                                    let _e496 = subThreshold_1;
                                    if ((_e489 == (_e490 - 1f)) || (_e494.x > _e496)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e499 = scale;
                                    scale = (_e499 * 2f);
                                }
                                continuing {
                                    let _e439 = i_2;
                                    i_2 = (_e439 + 1f);
                                }
                            }
                            let _e502 = inverseCurrentTransform_1;
                            let _e503 = relId_1;
                            let _e504 = tf(_e502, _e503);
                            id = _e504;
                            let _e506 = rnd_1;
                            modeIndex = i32(floor((_e506.y * 4f)));
                            let _e513 = modeIndex;
                            let _e516 = _params.modeMap[_e513];
                            mode_2 = _e516;
                            let _e519 = modeIndex;
                            if (_e519 == 0i) {
                                let _e522 = tileTransform1_1;
                                tileTransform = _e522;
                            } else {
                                let _e523 = modeIndex;
                                if (_e523 == 1i) {
                                    let _e526 = tileTransform2_1;
                                    tileTransform = _e526;
                                } else {
                                    let _e527 = modeIndex;
                                    if (_e527 == 2i) {
                                        let _e530 = tileTransform3_1;
                                        tileTransform = _e530;
                                    } else {
                                        let _e531 = tileTransform4_1;
                                        tileTransform = _e531;
                                    }
                                }
                            }
                            let _e532 = tileTransform;
                            inverseTileTransform = _naga_inverse_3x3_f32(_e532);
                            let _e535 = currentTransform_1;
                            let _e536 = _uv_1;
                            let _e537 = tf(_e535, _e536);
                            let _e538 = relId_1;
                            v_2 = ((_e537 - _e538) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e545 = rnd_1;
                            let _e549 = rnd_1;
                            let _e555 = coverage_2;
                            if (fract(((_e545.x * 6.222f) + (_e549.y * 8.233f))) <= _e555) {
                                {
                                    let _e557 = mode_2;
                                    if (_e557 == 0i) {
                                        {
                                            let _e562 = inverseTileTransform[0];
                                            w = _e562.xy;
                                            let _e565 = w;
                                            let _e569 = w;
                                            w = floor(vec2<f32>(dot(_e565, vec2(20f)), dot(_e569, vec2<f32>(20f, -20f))));
                                            let _e577 = relId_1;
                                            let _e579 = v_2;
                                            let _e580 = w;
                                            let _e585 = tileTransform[0];
                                            let _e592 = inverseTileTransform[2];
                                            let _e595 = w;
                                            pixId = (_e577 + (1.23f * (floor((_e579 * _e580)) + floor((((length(_e585.xy) * 5f) * _e592.xy) * _e595)))));
                                            let _e602 = pixId;
                                            let _e603 = hash22_(_e602);
                                            let _e607 = global.U[0];
                                            let _e610 = pixId;
                                            let _e611 = hash22_(_e610);
                                            let _e620 = _mirror_wrap(((vec2<f32>((_e603.x / _e607.x), _e611.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e621 = textureSample(t_source, samp, _e620);
                                            outCol = _e621;
                                        }
                                    } else {
                                        let _e622 = mode_2;
                                        if (_e622 == 1i) {
                                            {
                                                let _e626 = v_2;
                                                let _e629 = v_2;
                                                v_2 = vec2<f32>(0f, max(abs(_e626.x), abs(_e629.y)));
                                                let _e634 = inverseCurrentTransform_1;
                                                let _e635 = relId_1;
                                                let _e636 = inverseTileTransform;
                                                let _e637 = v_2;
                                                let _e638 = tf(_e636, _e637);
                                                let _e643 = tf(_e634, (_e635 + (_e638 + vec2(0.5f))));
                                                vv = _e643;
                                                let _e645 = vv;
                                                let _e649 = global.U[0];
                                                let _e652 = vv;
                                                let _e661 = _mirror_wrap(((vec2<f32>((_e645.x / _e649.x), _e652.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e662 = textureSample(t_source, samp, _e661);
                                                outCol = _e662;
                                            }
                                        } else {
                                            let _e663 = mode_2;
                                            if (_e663 == 2i) {
                                                {
                                                    let _e669 = inverseTileTransform[2];
                                                    size = (0.5f + _e669.y);
                                                    let _e673 = v_2;
                                                    d = length(_e673);
                                                    let _e676 = v_2;
                                                    let _e678 = v_2;
                                                    ang = atan2(_e676.y, _e678.x);
                                                    let _e682 = d;
                                                    let _e683 = size;
                                                    if (_e682 <= _e683) {
                                                        {
                                                            let _e688 = spikeCount;
                                                            anglePeriod = (6.2831855f / _e688);
                                                            let _e691 = ang;
                                                            let _e692 = anglePeriod;
                                                            let _e695 = anglePeriod;
                                                            a1_ = (floor((_e691 / _e692)) * _e695);
                                                            let _e698 = a1_;
                                                            let _e699 = anglePeriod;
                                                            a2_ = (_e698 + _e699);
                                                            let _e702 = ang;
                                                            let _e703 = a1_;
                                                            let _e705 = anglePeriod;
                                                            k_1 = ((_e702 - _e703) / _e705);
                                                            let _e708 = d;
                                                            let _e713 = inverseTileTransform[0];
                                                            ds = ((_e708 * 10f) * length(_e713.xy));
                                                            let _e718 = relId_1;
                                                            center = (_e718 + vec2(0.5f));
                                                            let _e723 = inverseCurrentTransform_1;
                                                            let _e724 = center;
                                                            let _e725 = ds;
                                                            let _e726 = a1_;
                                                            let _e728 = a1_;
                                                            let _e735 = inverseTileTransform[2];
                                                            let _e739 = tf(_e723, ((_e724 + (_e725 * vec2<f32>(cos(_e726), sin(_e728)))) + vec2(_e735.x)));
                                                            u1_ = _e739;
                                                            let _e741 = inverseCurrentTransform_1;
                                                            let _e742 = center;
                                                            let _e743 = ds;
                                                            let _e744 = a2_;
                                                            let _e746 = a2_;
                                                            let _e753 = inverseTileTransform[2];
                                                            let _e757 = tf(_e741, ((_e742 + (_e743 * vec2<f32>(cos(_e744), sin(_e746)))) + vec2(_e753.x)));
                                                            u2_ = _e757;
                                                            let _e759 = u1_;
                                                            let _e763 = global.U[0];
                                                            let _e766 = u1_;
                                                            let _e775 = _mirror_wrap(((vec2<f32>((_e759.x / _e763.x), _e766.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e776 = textureSample(t_source, samp, _e775);
                                                            col1_ = _e776;
                                                            let _e778 = u2_;
                                                            let _e782 = global.U[0];
                                                            let _e785 = u2_;
                                                            let _e794 = _mirror_wrap(((vec2<f32>((_e778.x / _e782.x), _e785.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e795 = textureSample(t_source, samp, _e794);
                                                            col2_ = _e795;
                                                            let _e797 = col1_;
                                                            let _e798 = col2_;
                                                            let _e799 = k_1;
                                                            outCol = mix(_e797, _e798, vec4(_e799));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e802 = mode_2;
                                                if (_e802 == 3i) {
                                                    {
                                                        let _e805 = v_2;
                                                        let _e808 = v_2;
                                                        vert = (abs(_e805.y) > abs(_e808.x));
                                                        let _e813 = vert;
                                                        if _e813 {
                                                            let _e814 = v_2;
                                                            local_3 = _e814.y;
                                                        } else {
                                                            let _e816 = v_2;
                                                            local_3 = _e816.x;
                                                        }
                                                        let _e819 = local_3;
                                                        a = _e819;
                                                        let _e821 = vert;
                                                        if _e821 {
                                                            let _e822 = a;
                                                            let _e824 = a;
                                                            local_4 = vec2<f32>(-(_e822), _e824);
                                                        } else {
                                                            let _e826 = a;
                                                            let _e827 = a;
                                                            local_4 = vec2<f32>(_e826, -(_e827));
                                                        }
                                                        let _e831 = local_4;
                                                        u1_1 = _e831;
                                                        let _e833 = a;
                                                        let _e834 = a;
                                                        u2_1 = vec2<f32>(_e833, _e834);
                                                        let _e837 = v_2;
                                                        let _e839 = v_2;
                                                        let _e843 = a;
                                                        k_2 = ((_e837.x + _e839.y) / (2f * _e843));
                                                        let _e847 = inverseCurrentTransform_1;
                                                        let _e848 = relId_1;
                                                        let _e849 = inverseTileTransform;
                                                        let _e850 = u1_1;
                                                        let _e851 = tf(_e849, _e850);
                                                        let _e856 = tf(_e847, (_e848 + (_e851 + vec2(0.5f))));
                                                        u1_1 = _e856;
                                                        let _e857 = inverseCurrentTransform_1;
                                                        let _e858 = relId_1;
                                                        let _e859 = inverseTileTransform;
                                                        let _e860 = u2_1;
                                                        let _e861 = tf(_e859, _e860);
                                                        let _e866 = tf(_e857, (_e858 + (_e861 + vec2(0.5f))));
                                                        u2_1 = _e866;
                                                        let _e867 = u1_1;
                                                        let _e871 = global.U[0];
                                                        let _e874 = u1_1;
                                                        let _e883 = _mirror_wrap(((vec2<f32>((_e867.x / _e871.x), _e874.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e884 = textureSample(t_source, samp, _e883);
                                                        col1_1 = _e884;
                                                        let _e886 = u2_1;
                                                        let _e890 = global.U[0];
                                                        let _e893 = u2_1;
                                                        let _e902 = _mirror_wrap(((vec2<f32>((_e886.x / _e890.x), _e893.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e903 = textureSample(t_source, samp, _e902);
                                                        col2_1 = _e903;
                                                        let _e905 = col1_1;
                                                        let _e906 = col2_1;
                                                        let _e907 = k_2;
                                                        outCol = mix(_e905, _e906, vec4(_e907));
                                                    }
                                                } else {
                                                    let _e910 = mode_2;
                                                    if (_e910 == 4i) {
                                                        {
                                                            let _e917 = inverseTileTransform[0];
                                                            let _e921 = inverseTileTransform[0];
                                                            ang_1 = atan2(_e917.y, _e921.x);
                                                            let _e925 = ang_1;
                                                            if (_e925 < 0f) {
                                                                let _e928 = relId_1;
                                                                let _e930 = relId_1;
                                                                let _e932 = (_e928.x + _e930.y);
                                                                local_5 = sign(((_e932 - (floor((_e932 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_5 = 1f;
                                                            }
                                                            let _e943 = local_5;
                                                            orientation = _e943;
                                                            let _e945 = rnd_1;
                                                            let _e947 = ang_1;
                                                            if (_e945.y > (abs(_e947) / 3.1415927f)) {
                                                                let _e952 = orientation;
                                                                orientation = -(_e952);
                                                            }
                                                            let _e954 = orientation;
                                                            let _e955 = v_2;
                                                            let _e958 = v_2;
                                                            if (((_e954 * _e955.x) * _e958.y) < 0f) {
                                                                local_6 = 40f;
                                                            } else {
                                                                local_6 = 2.5f;
                                                            }
                                                            let _e966 = local_6;
                                                            p_5 = _e966;
                                                            let _e968 = p_5;
                                                            if (_e968 > 30f) {
                                                                let _e971 = v_2;
                                                                let _e974 = v_2;
                                                                local_7 = max(abs(_e971.x), abs(_e974.y));
                                                            } else {
                                                                let _e978 = v_2;
                                                                let _e981 = p_5;
                                                                let _e983 = v_2;
                                                                let _e986 = p_5;
                                                                let _e990 = p_5;
                                                                local_7 = pow((pow(abs(_e978.x), _e981) + pow(abs(_e983.y), _e986)), (1f / _e990));
                                                            }
                                                            let _e994 = local_7;
                                                            d_1 = _e994;
                                                            let _e997 = d_1;
                                                            v_2 = vec2<f32>(0f, _e997);
                                                            let _e999 = v_2;
                                                            let _e1001 = size_1;
                                                            if (_e999.y <= _e1001) {
                                                                {
                                                                    let _e1003 = inverseCurrentTransform_1;
                                                                    let _e1004 = relId_1;
                                                                    let _e1005 = inverseTileTransform;
                                                                    let _e1006 = v_2;
                                                                    let _e1007 = tf(_e1005, _e1006);
                                                                    let _e1012 = tf(_e1003, (_e1004 + (_e1007 + vec2(0.5f))));
                                                                    vv_1 = _e1012;
                                                                    let _e1014 = vv_1;
                                                                    let _e1018 = global.U[0];
                                                                    let _e1021 = vv_1;
                                                                    let _e1030 = _mirror_wrap(((vec2<f32>((_e1014.x / _e1018.x), _e1021.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e1031 = textureSample(t_source, samp, _e1030);
                                                                    outCol = _e1031;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e1032 = mode_2;
                                                        if (_e1032 <= 6i) {
                                                            {
                                                                let _e1037 = inverseTileTransform[0];
                                                                scale_1 = length(_e1037.xy);
                                                                let _e1041 = scale_1;
                                                                invert = (_e1041 < 1f);
                                                                let _e1045 = invert;
                                                                if _e1045 {
                                                                    let _e1047 = scale_1;
                                                                    scale_1 = (1f / _e1047);
                                                                }
                                                                let _e1049 = scale_1;
                                                                ds_1 = fract(_e1049);
                                                                let _e1052 = scale_1;
                                                                N = max(floor(_e1052), 1f);
                                                                let _e1057 = v_2;
                                                                let _e1061 = N;
                                                                w_1 = (fract(((_e1057 + vec2(0.5f)) * _e1061)) - vec2(0.5f));
                                                                let _e1068 = v_2;
                                                                let _e1072 = N;
                                                                let _e1075 = N;
                                                                let _e1084 = N;
                                                                center_1 = ((((floor(((_e1068 + vec2(0.5f)) * _e1072)) / vec2(_e1075)) * 2f) - vec2(1f)) + vec2((1f / _e1084)));
                                                                let _e1091 = inverseTileTransform[0];
                                                                let _e1095 = inverseTileTransform[0];
                                                                ang_2 = atan2(_e1091.y, _e1095.x);
                                                                let _e1103 = ang_2;
                                                                if (_e1103 > 0f) {
                                                                    let _e1107 = ang_2;
                                                                    keepX = (1f - (_e1107 / 3.1415927f));
                                                                } else {
                                                                    let _e1112 = ang_2;
                                                                    keepY = (1f + (_e1112 / 3.1415927f));
                                                                }
                                                                let _e1116 = center_1;
                                                                let _e1119 = keepX;
                                                                let _e1121 = center_1;
                                                                let _e1124 = keepY;
                                                                hide = ((abs(_e1116.x) > _e1119) || (abs(_e1121.y) > _e1124));
                                                                let _e1130 = ds_1;
                                                                size_2 = mix(0.5f, 0.15f, _e1130);
                                                                let _e1133 = mode_2;
                                                                let _e1136 = w_1;
                                                                let _e1138 = size_2;
                                                                let _e1141 = mode_2;
                                                                let _e1144 = w_1;
                                                                let _e1147 = size_2;
                                                                let _e1149 = w_1;
                                                                let _e1152 = size_2;
                                                                outside = (((_e1133 == 6i) && (length(_e1136) > _e1138)) || ((_e1141 == 5i) && ((abs(_e1144.x) > _e1147) || (abs(_e1149.y) > _e1152))));
                                                                let _e1158 = hide;
                                                                let _e1159 = outside;
                                                                if !((_e1158 || _e1159)) {
                                                                    {
                                                                        let _e1162 = id;
                                                                        let _e1165 = inverseTileTransform[2];
                                                                        let _e1171 = global.U[0];
                                                                        let _e1174 = id;
                                                                        let _e1177 = inverseTileTransform[2];
                                                                        let _e1188 = _mirror_wrap(((vec2<f32>(((_e1162 + _e1165.xy).x / _e1171.x), (_e1174 + _e1177.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e1189 = textureSample(t_source, samp, _e1188);
                                                                        outCol = _e1189;
                                                                    }
                                                                } else {
                                                                    let _e1190 = invert;
                                                                    if _e1190 {
                                                                        {
                                                                            let _e1191 = id;
                                                                            let _e1195 = global.U[0];
                                                                            let _e1198 = id;
                                                                            let _e1207 = _mirror_wrap(((vec2<f32>((_e1191.x / _e1195.x), _e1198.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e1208 = textureSample(t_source, samp, _e1207);
                                                                            outCol = _e1208;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e1209 = mode_2;
                                                            if (_e1209 == 7i) {
                                                                {
                                                                    let _e1214 = inverseTileTransform[0];
                                                                    w_2 = _e1214.xy;
                                                                    let _e1217 = w_2;
                                                                    let _e1221 = w_2;
                                                                    w_2 = floor(vec2<f32>(dot(_e1217, vec2(16f)), dot(_e1221, vec2<f32>(16f, -16f))));
                                                                    let _e1229 = startScale_2;
                                                                    let _e1236 = inverseTileTransform[2];
                                                                    minScale = ((_e1229 * 2f) * pow(2f, floor((2f * _e1236.y))));
                                                                    let _e1243 = minScale;
                                                                    let _e1244 = startScale_2;
                                                                    let _e1251 = inverseTileTransform[2];
                                                                    maxScale = max(_e1243, ((_e1244 * 4f) * pow(2f, floor((2f * _e1251.x)))));
                                                                    let _e1259 = scale;
                                                                    let _e1260 = minScale;
                                                                    let _e1261 = maxScale;
                                                                    scale2_ = clamp(_e1259, _e1260, _e1261);
                                                                    let _e1264 = scale2_;
                                                                    let _e1265 = scale;
                                                                    invScaleRatio = (_e1264 / _e1265);
                                                                    let _e1268 = invScaleRatio;
                                                                    let _e1272 = invScaleRatio;
                                                                    let _e1281 = currentTransform_1;
                                                                    tr = (mat3x3<f32>(vec3<f32>(_e1268, 0f, 0f), vec3<f32>(0f, _e1272, 0f), vec3<f32>(0f, 0f, 1f)) * _e1281);
                                                                    let _e1284 = tr;
                                                                    let _e1285 = _uv_1;
                                                                    let _e1286 = tf(_e1284, _e1285);
                                                                    v_2 = (_e1286 - vec2(0.5f));
                                                                    let _e1290 = v_2;
                                                                    let _e1291 = w_2;
                                                                    pixId_1 = floor((_e1290 * _e1291));
                                                                    let _e1295 = pixId_1;
                                                                    let _e1297 = pixId_1;
                                                                    let _e1299 = (_e1295.x + _e1297.y);
                                                                    k_3 = (_e1299 - (floor((_e1299 / 2f)) * 2f));
                                                                    let _e1306 = k_3;
                                                                    let _e1307 = vec3(_e1306);
                                                                    outCol = vec4<f32>(_e1307.x, _e1307.y, _e1307.z, 1f);
                                                                }
                                                            } else {
                                                                let _e1313 = mode_2;
                                                                if (_e1313 == 8i) {
                                                                    {
                                                                        let _e1318 = startScale_2;
                                                                        scale2_1 = (_e1318 * 4f);
                                                                        let _e1322 = scale2_1;
                                                                        let _e1323 = scale;
                                                                        invScaleRatio_1 = (_e1322 / _e1323);
                                                                        let _e1326 = invScaleRatio_1;
                                                                        let _e1330 = invScaleRatio_1;
                                                                        let _e1339 = currentTransform_1;
                                                                        tr_1 = (mat3x3<f32>(vec3<f32>(_e1326, 0f, 0f), vec3<f32>(0f, _e1330, 0f), vec3<f32>(0f, 0f, 1f)) * _e1339);
                                                                        let _e1342 = tr_1;
                                                                        let _e1343 = _uv_1;
                                                                        let _e1344 = tf(_e1342, _e1343);
                                                                        v_2 = (_e1344 - vec2(0.5f));
                                                                        let _e1354 = inverseTileTransform[0];
                                                                        let _e1358 = inverseTileTransform[0];
                                                                        let _e1361 = piN;
                                                                        let _e1364 = piN;
                                                                        ang_3 = (floor((atan2(_e1354.y, _e1358.x) / _e1361)) * _e1364);
                                                                        let _e1367 = ang_3;
                                                                        let _e1368 = rotation2_(_e1367);
                                                                        let _e1369 = v_2;
                                                                        let _e1373 = inverseTileTransform[0];
                                                                        let _e1380 = inverseTileTransform[2];
                                                                        v_2 = (((_e1368 * _e1369) * length(_e1373.xy)) + (2f * _e1380.xy));
                                                                        let _e1384 = v_2;
                                                                        let _e1386 = v_2;
                                                                        let _e1388 = rnd_1;
                                                                        let _e1395 = Xn;
                                                                        let _e1397 = floor(((_e1384.x + (_e1386.y * sign((_e1388.y - 0.5f)))) * _e1395));
                                                                        k_4 = (_e1397 - (floor((_e1397 / 2f)) * 2f));
                                                                        let _e1404 = k_4;
                                                                        let _e1405 = vec3(_e1404);
                                                                        outCol = vec4<f32>(_e1405.x, _e1405.y, _e1405.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e1411 = mode_2;
                                                                    if (_e1411 == 9i) {
                                                                        {
                                                                            let _e1418 = inverseTileTransform[2];
                                                                            N_1 = floor((1000f * pow(0.25f, length(_e1418.xy))));
                                                                            let _e1429 = N_1;
                                                                            let _e1434 = inverseTileTransform[1];
                                                                            let _e1438 = inverseTileTransform[1];
                                                                            offset = ((1.5707964f + (3.1415927f / _e1429)) + atan2(_e1434.y, _e1438.x));
                                                                            let _e1443 = v_2;
                                                                            let _e1445 = v_2;
                                                                            ang_4 = atan2(_e1443.y, _e1445.x);
                                                                            let _e1449 = ang_4;
                                                                            let _e1450 = offset;
                                                                            let _e1454 = N_1;
                                                                            let _e1457 = N_1;
                                                                            let _e1461 = offset;
                                                                            ang_4 = (((round((((_e1449 - _e1450) / 6.2831855f) * _e1454)) / _e1457) * 6.2831855f) + _e1461);
                                                                            let _e1465 = inverseTileTransform[0];
                                                                            let _e1470 = ang_4;
                                                                            let _e1473 = ang_4;
                                                                            dist = ((length(_e1465.xy) * 0.5f) / max(abs(cos(_e1470)), abs(sin(_e1473))));
                                                                            let _e1479 = dist;
                                                                            let _e1480 = ang_4;
                                                                            let _e1482 = ang_4;
                                                                            v_2 = (_e1479 * vec2<f32>(cos(_e1480), sin(_e1482)));
                                                                            let _e1486 = inverseCurrentTransform_1;
                                                                            let _e1487 = relId_1;
                                                                            let _e1488 = v_2;
                                                                            let _e1493 = tf(_e1486, (_e1487 + (_e1488 + vec2(0.5f))));
                                                                            u_6 = _e1493;
                                                                            let _e1495 = u_6;
                                                                            let _e1499 = global.U[0];
                                                                            let _e1502 = u_6;
                                                                            let _e1511 = _mirror_wrap(((vec2<f32>((_e1495.x / _e1499.x), _e1502.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e1512 = textureSample(t_source, samp, _e1511);
                                                                            outCol = _e1512;
                                                                        }
                                                                    } else {
                                                                        let _e1513 = mode_2;
                                                                        if (_e1513 == 10i) {
                                                                            {
                                                                                let _e1518 = inverseTileTransform[0];
                                                                                s_1 = (length(_e1518.xy) * 0.05f);
                                                                                let _e1524 = v_2;
                                                                                v_2 = (_e1524 + vec2(0.5f));
                                                                                let _e1532 = inverseTileTransform[0];
                                                                                let _e1536 = inverseTileTransform[0];
                                                                                let _e1541 = N_2;
                                                                                let _e1546 = N_2;
                                                                                ang_5 = ((floor(((atan2(_e1532.y, _e1536.x) / 3.1415927f) * _e1541)) * 3.1415927f) / _e1546);
                                                                                let _e1549 = ang_5;
                                                                                let _e1550 = rotation2_(_e1549);
                                                                                let _e1551 = v_2;
                                                                                v_2 = (_e1550 * _e1551);
                                                                                let _e1553 = v_2;
                                                                                let _e1557 = inverseTileTransform[2];
                                                                                let _e1561 = tileTransform[0];
                                                                                let _e1569 = v_2;
                                                                                let _e1573 = inverseTileTransform[2];
                                                                                let _e1577 = tileTransform[0];
                                                                                let _e1584 = hslToRgb(vec4<f32>(((_e1553.x + (_e1557.x * length(_e1561.xy))) * 360f), 1f, (_e1569.y + (_e1573.y * length(_e1577.xy))), 1f));
                                                                                rgb = _e1584;
                                                                                let _e1586 = _uv_1;
                                                                                let _e1590 = global.U[0];
                                                                                let _e1593 = _uv_1;
                                                                                let _e1602 = _mirror_wrap(((vec2<f32>((_e1586.x / _e1590.x), _e1593.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e1603 = textureSample(t_source, samp, _e1602);
                                                                                inc_2 = _e1603;
                                                                                let _e1605 = inc_2;
                                                                                let _e1607 = rgb;
                                                                                dist_1 = length((_e1605.xyz - _e1607.xyz));
                                                                                let _e1615 = dist_1;
                                                                                let _e1617 = s_1;
                                                                                k_5 = (1f - (smoothstep(0f, 1.7f, _e1615) * _e1617));
                                                                                let _e1621 = inc_2;
                                                                                let _e1622 = rgb;
                                                                                let _e1623 = k_5;
                                                                                rgb = mix(_e1621, _e1622, vec4(_e1623));
                                                                                let _e1626 = rgb;
                                                                                outCol = _e1626;
                                                                            }
                                                                        } else {
                                                                            let _e1627 = mode_2;
                                                                            if (_e1627 == 11i) {
                                                                                {
                                                                                    let _e1633 = inverseTileTransform[0];
                                                                                    N_3 = round((4f * abs(_e1633.x)));
                                                                                    let _e1640 = v_2;
                                                                                    let _e1644 = N_3;
                                                                                    let _e1647 = N_3;
                                                                                    let _e1654 = N_3;
                                                                                    center_2 = (vec2<f32>(0f, ((((floor(((_e1640.y + 0.5f) * _e1644)) / _e1647) * 2f) - 1f) + (1f / _e1654))) * 0.5f);
                                                                                    let _e1661 = v_2;
                                                                                    let _e1662 = center_2;
                                                                                    dv = abs((_e1661 - _e1662));
                                                                                    let _e1666 = dv;
                                                                                    let _e1670 = dv;
                                                                                    let _e1673 = N_3;
                                                                                    if ((_e1666.x < 0.45f) && (_e1670.y < (0.4f / _e1673))) {
                                                                                        {
                                                                                            let _e1679 = inverseTileTransform[2];
                                                                                            s_2 = (_e1679.x + 1f);
                                                                                            let _e1684 = inverseCurrentTransform_1;
                                                                                            let _e1685 = relId_1;
                                                                                            let _e1686 = s_2;
                                                                                            let _e1696 = tf(_e1684, (_e1685 + ((_e1686 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_2 = _e1696;
                                                                                            let _e1698 = inverseCurrentTransform_1;
                                                                                            let _e1699 = relId_1;
                                                                                            let _e1700 = s_2;
                                                                                            let _e1709 = tf(_e1698, (_e1699 + ((_e1700 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_2 = _e1709;
                                                                                            let _e1711 = u1_2;
                                                                                            let _e1715 = global.U[0];
                                                                                            let _e1718 = u1_2;
                                                                                            let _e1727 = _mirror_wrap(((vec2<f32>((_e1711.x / _e1715.x), _e1718.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1728 = textureSample(t_source, samp, _e1727);
                                                                                            let _e1729 = u2_2;
                                                                                            let _e1733 = global.U[0];
                                                                                            let _e1736 = u2_2;
                                                                                            let _e1745 = _mirror_wrap(((vec2<f32>((_e1729.x / _e1733.x), _e1736.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1746 = textureSample(t_source, samp, _e1745);
                                                                                            let _e1747 = center_2;
                                                                                            outCol = mix(_e1728, _e1746, vec4((_e1747.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e1753 = mode_2;
                                                                                if (_e1753 == 12i) {
                                                                                    {
                                                                                        let _e1756 = v_2;
                                                                                        v_2 = (_e1756 * vec2<f32>(2f, 2f));
                                                                                        let _e1761 = inverseTileTransform;
                                                                                        let _e1762 = v_2;
                                                                                        let _e1763 = tf(_e1761, _e1762);
                                                                                        v_2 = _e1763;
                                                                                        let _e1764 = inverseCurrentTransform_1;
                                                                                        let _e1765 = relId_1;
                                                                                        let _e1766 = v_2;
                                                                                        let _e1771 = tf(_e1764, (_e1765 + (_e1766 + vec2(0.5f))));
                                                                                        let _e1775 = global.U[0];
                                                                                        let _e1778 = inverseCurrentTransform_1;
                                                                                        let _e1779 = relId_1;
                                                                                        let _e1780 = v_2;
                                                                                        let _e1785 = tf(_e1778, (_e1779 + (_e1780 + vec2(0.5f))));
                                                                                        let _e1794 = _mirror_wrap(((vec2<f32>((_e1771.x / _e1775.x), _e1785.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e1795 = textureSample(t_source, samp, _e1794);
                                                                                        outCol = _e1795;
                                                                                    }
                                                                                } else {
                                                                                    let _e1796 = mode_2;
                                                                                    if (_e1796 == 13i) {
                                                                                        {
                                                                                            let _e1799 = _uv_1;
                                                                                            let _e1803 = global.U[0];
                                                                                            let _e1806 = _uv_1;
                                                                                            let _e1815 = _mirror_wrap(((vec2<f32>((_e1799.x / _e1803.x), _e1806.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e1816 = textureSample(t_source, samp, _e1815);
                                                                                            let _e1818 = luma(_e1816.xyz);
                                                                                            lum = _e1818;
                                                                                            let _e1820 = inverseTileTransform;
                                                                                            let _e1821 = v_2;
                                                                                            let _e1826 = tf(_e1820, (_e1821 * vec2<f32>(8f, 8f)));
                                                                                            v_2 = _e1826;
                                                                                            let _e1827 = v_2;
                                                                                            let _e1830 = (_e1827.y + 1f);
                                                                                            y = abs(((_e1830 - (floor((_e1830 / 2f)) * 2f)) - 1f));
                                                                                            let _e1840 = lum;
                                                                                            let _e1841 = y;
                                                                                            if (_e1840 > _e1841) {
                                                                                                local_8 = 1f;
                                                                                            } else {
                                                                                                local_8 = 0f;
                                                                                            }
                                                                                            let _e1846 = local_8;
                                                                                            k_6 = _e1846;
                                                                                            let _e1848 = k_6;
                                                                                            let _e1849 = vec3(_e1848);
                                                                                            outCol = vec4<f32>(_e1849.x, _e1849.y, _e1849.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e1855 = mode_2;
                                                                                        if (_e1855 == 14i) {
                                                                                            {
                                                                                                let _e1858 = id;
                                                                                                let _e1862 = global.U[0];
                                                                                                let _e1865 = id;
                                                                                                let _e1874 = _mirror_wrap(((vec2<f32>((_e1858.x / _e1862.x), _e1865.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e1875 = textureSample(t_source, samp, _e1874);
                                                                                                let _e1877 = luma(_e1875.xyz);
                                                                                                lum_1 = _e1877;
                                                                                                let _e1881 = tileTransform[0];
                                                                                                contrast = length(_e1881.xy);
                                                                                                let _e1885 = v_2;
                                                                                                let _e1888 = (_e1885 + vec2(0.5f));
                                                                                                let _e1890 = contrast;
                                                                                                let _e1891 = lum_1;
                                                                                                outCol = vec4<f32>(_e1888.x, _e1888.y, (0.5f + (_e1890 * (_e1891 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e1900 = mode_2;
                                                                                            if (_e1900 == 15i) {
                                                                                                {
                                                                                                    let _e1903 = rnd_1;
                                                                                                    center_3 = (sign((_e1903 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e1911 = v_2;
                                                                                                    let _e1912 = center_3;
                                                                                                    dv_1 = (_e1911 - _e1912);
                                                                                                    let _e1918 = inverseTileTransform[0];
                                                                                                    N_4 = floor((16f * length(_e1918.xy)));
                                                                                                    let _e1926 = dv_1;
                                                                                                    let _e1928 = dv_1;
                                                                                                    let _e1931 = angOffset;
                                                                                                    ang_6 = (atan2(_e1926.y, _e1928.x) + _e1931);
                                                                                                    let _e1934 = ang_6;
                                                                                                    let _e1937 = N_4;
                                                                                                    let _e1940 = (((_e1934 / 3.1415927f) * _e1937) * 2f);
                                                                                                    k_7 = abs(((_e1940 - (floor((_e1940 / 2f)) * 2f)) - 1f));
                                                                                                    let _e1952 = inverseTileTransform[0];
                                                                                                    let _e1956 = inverseTileTransform[0];
                                                                                                    kCol = (atan2(_e1952.y, _e1956.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e1966 = i_3;
                                                                                                        if !((_e1966 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e1973 = inverseCurrentTransform_1;
                                                                                                            let _e1974 = relId_1;
                                                                                                            let _e1977 = i_3;
                                                                                                            let _e1981 = ang_6;
                                                                                                            let _e1983 = ang_6;
                                                                                                            let _e1988 = tf(_e1973, (_e1974 + ((0.1f + (0.15f * f32(_e1977))) * vec2<f32>(cos(_e1981), sin(_e1983)))));
                                                                                                            w_3 = _e1988;
                                                                                                            let _e1990 = lum_2;
                                                                                                            let _e1991 = w_3;
                                                                                                            let _e1995 = global.U[0];
                                                                                                            let _e1998 = w_3;
                                                                                                            let _e2007 = _mirror_wrap(((vec2<f32>((_e1991.x / _e1995.x), _e1998.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2008 = textureSample(t_source, samp, _e2007);
                                                                                                            let _e2010 = luma(_e2008.xyz);
                                                                                                            lum_2 = (_e1990 + _e2010);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e1970 = i_3;
                                                                                                            i_3 = (_e1970 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e2012 = lum_2;
                                                                                                    lum_2 = (_e2012 / 5f);
                                                                                                    let _e2015 = lum_2;
                                                                                                    let _e2016 = k_7;
                                                                                                    if (_e2015 > _e2016) {
                                                                                                        local_9 = 1f;
                                                                                                    } else {
                                                                                                        local_9 = 0f;
                                                                                                    }
                                                                                                    let _e2021 = local_9;
                                                                                                    k_7 = _e2021;
                                                                                                    let _e2022 = kCol;
                                                                                                    if (_e2022 == 0f) {
                                                                                                        {
                                                                                                            let _e2025 = k_7;
                                                                                                            let _e2026 = vec3(_e2025);
                                                                                                            outCol = vec4<f32>(_e2026.x, _e2026.y, _e2026.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e2034 = inverseTileTransform[2];
                                                                                                            u1_3 = vec2<f32>(_e2034.x, 0f);
                                                                                                            let _e2042 = inverseTileTransform[2];
                                                                                                            u2_3 = vec2<f32>(0f, _e2042.y);
                                                                                                            let _e2046 = kCol;
                                                                                                            if (_e2046 > 0f) {
                                                                                                                {
                                                                                                                    let _e2049 = u1_3;
                                                                                                                    let _e2050 = id;
                                                                                                                    u1_3 = (_e2049 + _e2050);
                                                                                                                    let _e2052 = u2_3;
                                                                                                                    let _e2053 = id;
                                                                                                                    u2_3 = (_e2052 + (_e2053 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e2058 = u1_3;
                                                                                                            let _e2062 = global.U[0];
                                                                                                            let _e2065 = u1_3;
                                                                                                            let _e2074 = _mirror_wrap(((vec2<f32>((_e2058.x / _e2062.x), _e2065.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2075 = textureSample(t_source, samp, _e2074);
                                                                                                            col1_2 = _e2075;
                                                                                                            let _e2077 = u2_3;
                                                                                                            let _e2081 = global.U[0];
                                                                                                            let _e2084 = u2_3;
                                                                                                            let _e2093 = _mirror_wrap(((vec2<f32>((_e2077.x / _e2081.x), _e2084.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e2094 = textureSample(t_source, samp, _e2093);
                                                                                                            col2_2 = _e2094;
                                                                                                            let _e2096 = col1_2;
                                                                                                            let _e2098 = luma(_e2096.xyz);
                                                                                                            let _e2099 = col2_2;
                                                                                                            let _e2101 = luma(_e2099.xyz);
                                                                                                            if (_e2098 > _e2101) {
                                                                                                                let _e2104 = k_7;
                                                                                                                k_7 = (1f - _e2104);
                                                                                                            }
                                                                                                            let _e2106 = k_7;
                                                                                                            let _e2107 = vec3(_e2106);
                                                                                                            outCol1_ = vec4<f32>(_e2107.x, _e2107.y, _e2107.z, 1f);
                                                                                                            let _e2114 = col1_2;
                                                                                                            let _e2115 = col2_2;
                                                                                                            let _e2116 = k_7;
                                                                                                            outCol2_ = mix(_e2114, _e2115, vec4(_e2116));
                                                                                                            let _e2120 = outCol1_;
                                                                                                            let _e2121 = outCol2_;
                                                                                                            let _e2122 = kCol;
                                                                                                            outCol = mix(_e2120, _e2121, vec4(abs(_e2122)));
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
                        let _e2126 = src1_;
                        let _e2127 = outCol;
                        let _e2128 = mergeColor(_e2126, _e2127);
                        col1_3 = _e2128;
                        {
                            let _e2130 = uu2_;
                            _uv_2 = _e2130;
                            let _e2132 = _params;
                            startScale_3 = _e2132.startScale;
                            let _e2135 = _params;
                            subLevels_2 = _e2135.subLevels;
                            let _e2138 = _params;
                            subThreshold_2 = _e2138.subThreshold;
                            let _e2141 = _params;
                            seed_2 = _e2141.seed;
                            let _e2144 = _params;
                            hashStyle_4 = _e2144.hashStyle;
                            let _e2147 = _params;
                            coverage_3 = _e2147.coverage;
                            let _e2150 = _params;
                            currentTransform_2 = _e2150.transform;
                            let _e2153 = _params;
                            inverseCurrentTransform_2 = _e2153.inverseTransform;
                            let _e2156 = startScale_3;
                            scale_2 = _e2156;
                            loop {
                                let _e2164 = i_4;
                                let _e2165 = subLevels_2;
                                if !((_e2164 < _e2165)) {
                                    break;
                                }
                                {
                                    let _e2171 = i_4;
                                    if (_e2171 != 0f) {
                                        {
                                            let _e2187 = currentTransform_2;
                                            currentTransform_2 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e2187);
                                            let _e2189 = inverseCurrentTransform_2;
                                            inverseCurrentTransform_2 = (_e2189 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e2204 = currentTransform_2;
                                    let _e2205 = _uv_2;
                                    let _e2206 = tf(_e2204, _e2205);
                                    relId_2 = floor(_e2206);
                                    let _e2208 = relId_2;
                                    let _e2210 = (_e2208 * 0.13137f);
                                    let _e2211 = i_4;
                                    let _e2212 = seed_2;
                                    let _e2216 = hashStyle_4;
                                    let _e2217 = hash42sp(vec4<f32>(_e2210.x, _e2210.y, _e2211, _e2212), _e2216);
                                    rnd_2 = _e2217;
                                    let _e2218 = i_4;
                                    let _e2219 = subLevels_2;
                                    let _e2223 = rnd_2;
                                    let _e2225 = subThreshold_2;
                                    if ((_e2218 == (_e2219 - 1f)) || (_e2223.x > _e2225)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e2228 = scale_2;
                                    scale_2 = (_e2228 * 2f);
                                }
                                continuing {
                                    let _e2168 = i_4;
                                    i_4 = (_e2168 + 1f);
                                }
                            }
                            let _e2231 = inverseCurrentTransform_2;
                            let _e2232 = relId_2;
                            let _e2233 = tf(_e2231, _e2232);
                            id_1 = _e2233;
                            let _e2235 = rnd_2;
                            modeIndex_1 = i32(floor((_e2235.y * 4f)));
                            let _e2242 = modeIndex_1;
                            let _e2245 = _params.modeMap[_e2242];
                            mode_3 = _e2245;
                            let _e2248 = modeIndex_1;
                            if (_e2248 == 0i) {
                                let _e2251 = tileTransform1_1;
                                tileTransform_1 = _e2251;
                            } else {
                                let _e2252 = modeIndex_1;
                                if (_e2252 == 1i) {
                                    let _e2255 = tileTransform2_1;
                                    tileTransform_1 = _e2255;
                                } else {
                                    let _e2256 = modeIndex_1;
                                    if (_e2256 == 2i) {
                                        let _e2259 = tileTransform3_1;
                                        tileTransform_1 = _e2259;
                                    } else {
                                        let _e2260 = tileTransform4_1;
                                        tileTransform_1 = _e2260;
                                    }
                                }
                            }
                            let _e2261 = tileTransform_1;
                            inverseTileTransform_1 = _naga_inverse_3x3_f32(_e2261);
                            let _e2264 = currentTransform_2;
                            let _e2265 = _uv_2;
                            let _e2266 = tf(_e2264, _e2265);
                            let _e2267 = relId_2;
                            v_3 = ((_e2266 - _e2267) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e2274 = rnd_2;
                            let _e2278 = rnd_2;
                            let _e2284 = coverage_3;
                            if (fract(((_e2274.x * 6.222f) + (_e2278.y * 8.233f))) <= _e2284) {
                                {
                                    let _e2286 = mode_3;
                                    if (_e2286 == 0i) {
                                        {
                                            let _e2291 = inverseTileTransform_1[0];
                                            w_4 = _e2291.xy;
                                            let _e2294 = w_4;
                                            let _e2298 = w_4;
                                            w_4 = floor(vec2<f32>(dot(_e2294, vec2(20f)), dot(_e2298, vec2<f32>(20f, -20f))));
                                            let _e2306 = relId_2;
                                            let _e2308 = v_3;
                                            let _e2309 = w_4;
                                            let _e2314 = tileTransform_1[0];
                                            let _e2321 = inverseTileTransform_1[2];
                                            let _e2324 = w_4;
                                            pixId_2 = (_e2306 + (1.23f * (floor((_e2308 * _e2309)) + floor((((length(_e2314.xy) * 5f) * _e2321.xy) * _e2324)))));
                                            let _e2331 = pixId_2;
                                            let _e2332 = hash22_(_e2331);
                                            let _e2336 = global.U[0];
                                            let _e2339 = pixId_2;
                                            let _e2340 = hash22_(_e2339);
                                            let _e2349 = _mirror_wrap(((vec2<f32>((_e2332.x / _e2336.x), _e2340.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e2350 = textureSample(t_source, samp, _e2349);
                                            outCol = _e2350;
                                        }
                                    } else {
                                        let _e2351 = mode_3;
                                        if (_e2351 == 1i) {
                                            {
                                                let _e2355 = v_3;
                                                let _e2358 = v_3;
                                                v_3 = vec2<f32>(0f, max(abs(_e2355.x), abs(_e2358.y)));
                                                let _e2363 = inverseCurrentTransform_2;
                                                let _e2364 = relId_2;
                                                let _e2365 = inverseTileTransform_1;
                                                let _e2366 = v_3;
                                                let _e2367 = tf(_e2365, _e2366);
                                                let _e2372 = tf(_e2363, (_e2364 + (_e2367 + vec2(0.5f))));
                                                vv_2 = _e2372;
                                                let _e2374 = vv_2;
                                                let _e2378 = global.U[0];
                                                let _e2381 = vv_2;
                                                let _e2390 = _mirror_wrap(((vec2<f32>((_e2374.x / _e2378.x), _e2381.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e2391 = textureSample(t_source, samp, _e2390);
                                                outCol = _e2391;
                                            }
                                        } else {
                                            let _e2392 = mode_3;
                                            if (_e2392 == 2i) {
                                                {
                                                    let _e2398 = inverseTileTransform_1[2];
                                                    size_3 = (0.5f + _e2398.y);
                                                    let _e2402 = v_3;
                                                    d_2 = length(_e2402);
                                                    let _e2405 = v_3;
                                                    let _e2407 = v_3;
                                                    ang_7 = atan2(_e2405.y, _e2407.x);
                                                    let _e2411 = d_2;
                                                    let _e2412 = size_3;
                                                    if (_e2411 <= _e2412) {
                                                        {
                                                            let _e2417 = spikeCount_1;
                                                            anglePeriod_1 = (6.2831855f / _e2417);
                                                            let _e2420 = ang_7;
                                                            let _e2421 = anglePeriod_1;
                                                            let _e2424 = anglePeriod_1;
                                                            a1_1 = (floor((_e2420 / _e2421)) * _e2424);
                                                            let _e2427 = a1_1;
                                                            let _e2428 = anglePeriod_1;
                                                            a2_1 = (_e2427 + _e2428);
                                                            let _e2431 = ang_7;
                                                            let _e2432 = a1_1;
                                                            let _e2434 = anglePeriod_1;
                                                            k_8 = ((_e2431 - _e2432) / _e2434);
                                                            let _e2437 = d_2;
                                                            let _e2442 = inverseTileTransform_1[0];
                                                            ds_2 = ((_e2437 * 10f) * length(_e2442.xy));
                                                            let _e2447 = relId_2;
                                                            center_4 = (_e2447 + vec2(0.5f));
                                                            let _e2452 = inverseCurrentTransform_2;
                                                            let _e2453 = center_4;
                                                            let _e2454 = ds_2;
                                                            let _e2455 = a1_1;
                                                            let _e2457 = a1_1;
                                                            let _e2464 = inverseTileTransform_1[2];
                                                            let _e2468 = tf(_e2452, ((_e2453 + (_e2454 * vec2<f32>(cos(_e2455), sin(_e2457)))) + vec2(_e2464.x)));
                                                            u1_4 = _e2468;
                                                            let _e2470 = inverseCurrentTransform_2;
                                                            let _e2471 = center_4;
                                                            let _e2472 = ds_2;
                                                            let _e2473 = a2_1;
                                                            let _e2475 = a2_1;
                                                            let _e2482 = inverseTileTransform_1[2];
                                                            let _e2486 = tf(_e2470, ((_e2471 + (_e2472 * vec2<f32>(cos(_e2473), sin(_e2475)))) + vec2(_e2482.x)));
                                                            u2_4 = _e2486;
                                                            let _e2488 = u1_4;
                                                            let _e2492 = global.U[0];
                                                            let _e2495 = u1_4;
                                                            let _e2504 = _mirror_wrap(((vec2<f32>((_e2488.x / _e2492.x), _e2495.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e2505 = textureSample(t_source, samp, _e2504);
                                                            col1_4 = _e2505;
                                                            let _e2507 = u2_4;
                                                            let _e2511 = global.U[0];
                                                            let _e2514 = u2_4;
                                                            let _e2523 = _mirror_wrap(((vec2<f32>((_e2507.x / _e2511.x), _e2514.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e2524 = textureSample(t_source, samp, _e2523);
                                                            col2_3 = _e2524;
                                                            let _e2526 = col1_4;
                                                            let _e2527 = col2_3;
                                                            let _e2528 = k_8;
                                                            outCol = mix(_e2526, _e2527, vec4(_e2528));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e2531 = mode_3;
                                                if (_e2531 == 3i) {
                                                    {
                                                        let _e2534 = v_3;
                                                        let _e2537 = v_3;
                                                        vert_1 = (abs(_e2534.y) > abs(_e2537.x));
                                                        let _e2542 = vert_1;
                                                        if _e2542 {
                                                            let _e2543 = v_3;
                                                            local_10 = _e2543.y;
                                                        } else {
                                                            let _e2545 = v_3;
                                                            local_10 = _e2545.x;
                                                        }
                                                        let _e2548 = local_10;
                                                        a_1 = _e2548;
                                                        let _e2550 = vert_1;
                                                        if _e2550 {
                                                            let _e2551 = a_1;
                                                            let _e2553 = a_1;
                                                            local_11 = vec2<f32>(-(_e2551), _e2553);
                                                        } else {
                                                            let _e2555 = a_1;
                                                            let _e2556 = a_1;
                                                            local_11 = vec2<f32>(_e2555, -(_e2556));
                                                        }
                                                        let _e2560 = local_11;
                                                        u1_5 = _e2560;
                                                        let _e2562 = a_1;
                                                        let _e2563 = a_1;
                                                        u2_5 = vec2<f32>(_e2562, _e2563);
                                                        let _e2566 = v_3;
                                                        let _e2568 = v_3;
                                                        let _e2572 = a_1;
                                                        k_9 = ((_e2566.x + _e2568.y) / (2f * _e2572));
                                                        let _e2576 = inverseCurrentTransform_2;
                                                        let _e2577 = relId_2;
                                                        let _e2578 = inverseTileTransform_1;
                                                        let _e2579 = u1_5;
                                                        let _e2580 = tf(_e2578, _e2579);
                                                        let _e2585 = tf(_e2576, (_e2577 + (_e2580 + vec2(0.5f))));
                                                        u1_5 = _e2585;
                                                        let _e2586 = inverseCurrentTransform_2;
                                                        let _e2587 = relId_2;
                                                        let _e2588 = inverseTileTransform_1;
                                                        let _e2589 = u2_5;
                                                        let _e2590 = tf(_e2588, _e2589);
                                                        let _e2595 = tf(_e2586, (_e2587 + (_e2590 + vec2(0.5f))));
                                                        u2_5 = _e2595;
                                                        let _e2596 = u1_5;
                                                        let _e2600 = global.U[0];
                                                        let _e2603 = u1_5;
                                                        let _e2612 = _mirror_wrap(((vec2<f32>((_e2596.x / _e2600.x), _e2603.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e2613 = textureSample(t_source, samp, _e2612);
                                                        col1_5 = _e2613;
                                                        let _e2615 = u2_5;
                                                        let _e2619 = global.U[0];
                                                        let _e2622 = u2_5;
                                                        let _e2631 = _mirror_wrap(((vec2<f32>((_e2615.x / _e2619.x), _e2622.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e2632 = textureSample(t_source, samp, _e2631);
                                                        col2_4 = _e2632;
                                                        let _e2634 = col1_5;
                                                        let _e2635 = col2_4;
                                                        let _e2636 = k_9;
                                                        outCol = mix(_e2634, _e2635, vec4(_e2636));
                                                    }
                                                } else {
                                                    let _e2639 = mode_3;
                                                    if (_e2639 == 4i) {
                                                        {
                                                            let _e2646 = inverseTileTransform_1[0];
                                                            let _e2650 = inverseTileTransform_1[0];
                                                            ang_8 = atan2(_e2646.y, _e2650.x);
                                                            let _e2654 = ang_8;
                                                            if (_e2654 < 0f) {
                                                                let _e2657 = relId_2;
                                                                let _e2659 = relId_2;
                                                                let _e2661 = (_e2657.x + _e2659.y);
                                                                local_12 = sign(((_e2661 - (floor((_e2661 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_12 = 1f;
                                                            }
                                                            let _e2672 = local_12;
                                                            orientation_1 = _e2672;
                                                            let _e2674 = rnd_2;
                                                            let _e2676 = ang_8;
                                                            if (_e2674.y > (abs(_e2676) / 3.1415927f)) {
                                                                let _e2681 = orientation_1;
                                                                orientation_1 = -(_e2681);
                                                            }
                                                            let _e2683 = orientation_1;
                                                            let _e2684 = v_3;
                                                            let _e2687 = v_3;
                                                            if (((_e2683 * _e2684.x) * _e2687.y) < 0f) {
                                                                local_13 = 40f;
                                                            } else {
                                                                local_13 = 2.5f;
                                                            }
                                                            let _e2695 = local_13;
                                                            p_6 = _e2695;
                                                            let _e2697 = p_6;
                                                            if (_e2697 > 30f) {
                                                                let _e2700 = v_3;
                                                                let _e2703 = v_3;
                                                                local_14 = max(abs(_e2700.x), abs(_e2703.y));
                                                            } else {
                                                                let _e2707 = v_3;
                                                                let _e2710 = p_6;
                                                                let _e2712 = v_3;
                                                                let _e2715 = p_6;
                                                                let _e2719 = p_6;
                                                                local_14 = pow((pow(abs(_e2707.x), _e2710) + pow(abs(_e2712.y), _e2715)), (1f / _e2719));
                                                            }
                                                            let _e2723 = local_14;
                                                            d_3 = _e2723;
                                                            let _e2726 = d_3;
                                                            v_3 = vec2<f32>(0f, _e2726);
                                                            let _e2728 = v_3;
                                                            let _e2730 = size_4;
                                                            if (_e2728.y <= _e2730) {
                                                                {
                                                                    let _e2732 = inverseCurrentTransform_2;
                                                                    let _e2733 = relId_2;
                                                                    let _e2734 = inverseTileTransform_1;
                                                                    let _e2735 = v_3;
                                                                    let _e2736 = tf(_e2734, _e2735);
                                                                    let _e2741 = tf(_e2732, (_e2733 + (_e2736 + vec2(0.5f))));
                                                                    vv_3 = _e2741;
                                                                    let _e2743 = vv_3;
                                                                    let _e2747 = global.U[0];
                                                                    let _e2750 = vv_3;
                                                                    let _e2759 = _mirror_wrap(((vec2<f32>((_e2743.x / _e2747.x), _e2750.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e2760 = textureSample(t_source, samp, _e2759);
                                                                    outCol = _e2760;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e2761 = mode_3;
                                                        if (_e2761 <= 6i) {
                                                            {
                                                                let _e2766 = inverseTileTransform_1[0];
                                                                scale_3 = length(_e2766.xy);
                                                                let _e2770 = scale_3;
                                                                invert_1 = (_e2770 < 1f);
                                                                let _e2774 = invert_1;
                                                                if _e2774 {
                                                                    let _e2776 = scale_3;
                                                                    scale_3 = (1f / _e2776);
                                                                }
                                                                let _e2778 = scale_3;
                                                                ds_3 = fract(_e2778);
                                                                let _e2781 = scale_3;
                                                                N_5 = max(floor(_e2781), 1f);
                                                                let _e2786 = v_3;
                                                                let _e2790 = N_5;
                                                                w_5 = (fract(((_e2786 + vec2(0.5f)) * _e2790)) - vec2(0.5f));
                                                                let _e2797 = v_3;
                                                                let _e2801 = N_5;
                                                                let _e2804 = N_5;
                                                                let _e2813 = N_5;
                                                                center_5 = ((((floor(((_e2797 + vec2(0.5f)) * _e2801)) / vec2(_e2804)) * 2f) - vec2(1f)) + vec2((1f / _e2813)));
                                                                let _e2820 = inverseTileTransform_1[0];
                                                                let _e2824 = inverseTileTransform_1[0];
                                                                ang_9 = atan2(_e2820.y, _e2824.x);
                                                                let _e2832 = ang_9;
                                                                if (_e2832 > 0f) {
                                                                    let _e2836 = ang_9;
                                                                    keepX_1 = (1f - (_e2836 / 3.1415927f));
                                                                } else {
                                                                    let _e2841 = ang_9;
                                                                    keepY_1 = (1f + (_e2841 / 3.1415927f));
                                                                }
                                                                let _e2845 = center_5;
                                                                let _e2848 = keepX_1;
                                                                let _e2850 = center_5;
                                                                let _e2853 = keepY_1;
                                                                hide_1 = ((abs(_e2845.x) > _e2848) || (abs(_e2850.y) > _e2853));
                                                                let _e2859 = ds_3;
                                                                size_5 = mix(0.5f, 0.15f, _e2859);
                                                                let _e2862 = mode_3;
                                                                let _e2865 = w_5;
                                                                let _e2867 = size_5;
                                                                let _e2870 = mode_3;
                                                                let _e2873 = w_5;
                                                                let _e2876 = size_5;
                                                                let _e2878 = w_5;
                                                                let _e2881 = size_5;
                                                                outside_1 = (((_e2862 == 6i) && (length(_e2865) > _e2867)) || ((_e2870 == 5i) && ((abs(_e2873.x) > _e2876) || (abs(_e2878.y) > _e2881))));
                                                                let _e2887 = hide_1;
                                                                let _e2888 = outside_1;
                                                                if !((_e2887 || _e2888)) {
                                                                    {
                                                                        let _e2891 = id_1;
                                                                        let _e2894 = inverseTileTransform_1[2];
                                                                        let _e2900 = global.U[0];
                                                                        let _e2903 = id_1;
                                                                        let _e2906 = inverseTileTransform_1[2];
                                                                        let _e2917 = _mirror_wrap(((vec2<f32>(((_e2891 + _e2894.xy).x / _e2900.x), (_e2903 + _e2906.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e2918 = textureSample(t_source, samp, _e2917);
                                                                        outCol = _e2918;
                                                                    }
                                                                } else {
                                                                    let _e2919 = invert_1;
                                                                    if _e2919 {
                                                                        {
                                                                            let _e2920 = id_1;
                                                                            let _e2924 = global.U[0];
                                                                            let _e2927 = id_1;
                                                                            let _e2936 = _mirror_wrap(((vec2<f32>((_e2920.x / _e2924.x), _e2927.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e2937 = textureSample(t_source, samp, _e2936);
                                                                            outCol = _e2937;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e2938 = mode_3;
                                                            if (_e2938 == 7i) {
                                                                {
                                                                    let _e2943 = inverseTileTransform_1[0];
                                                                    w_6 = _e2943.xy;
                                                                    let _e2946 = w_6;
                                                                    let _e2950 = w_6;
                                                                    w_6 = floor(vec2<f32>(dot(_e2946, vec2(16f)), dot(_e2950, vec2<f32>(16f, -16f))));
                                                                    let _e2958 = startScale_3;
                                                                    let _e2965 = inverseTileTransform_1[2];
                                                                    minScale_1 = ((_e2958 * 2f) * pow(2f, floor((2f * _e2965.y))));
                                                                    let _e2972 = minScale_1;
                                                                    let _e2973 = startScale_3;
                                                                    let _e2980 = inverseTileTransform_1[2];
                                                                    maxScale_1 = max(_e2972, ((_e2973 * 4f) * pow(2f, floor((2f * _e2980.x)))));
                                                                    let _e2988 = scale_2;
                                                                    let _e2989 = minScale_1;
                                                                    let _e2990 = maxScale_1;
                                                                    scale2_2 = clamp(_e2988, _e2989, _e2990);
                                                                    let _e2993 = scale2_2;
                                                                    let _e2994 = scale_2;
                                                                    invScaleRatio_2 = (_e2993 / _e2994);
                                                                    let _e2997 = invScaleRatio_2;
                                                                    let _e3001 = invScaleRatio_2;
                                                                    let _e3010 = currentTransform_2;
                                                                    tr_2 = (mat3x3<f32>(vec3<f32>(_e2997, 0f, 0f), vec3<f32>(0f, _e3001, 0f), vec3<f32>(0f, 0f, 1f)) * _e3010);
                                                                    let _e3013 = tr_2;
                                                                    let _e3014 = _uv_2;
                                                                    let _e3015 = tf(_e3013, _e3014);
                                                                    v_3 = (_e3015 - vec2(0.5f));
                                                                    let _e3019 = v_3;
                                                                    let _e3020 = w_6;
                                                                    pixId_3 = floor((_e3019 * _e3020));
                                                                    let _e3024 = pixId_3;
                                                                    let _e3026 = pixId_3;
                                                                    let _e3028 = (_e3024.x + _e3026.y);
                                                                    k_10 = (_e3028 - (floor((_e3028 / 2f)) * 2f));
                                                                    let _e3035 = k_10;
                                                                    let _e3036 = vec3(_e3035);
                                                                    outCol = vec4<f32>(_e3036.x, _e3036.y, _e3036.z, 1f);
                                                                }
                                                            } else {
                                                                let _e3042 = mode_3;
                                                                if (_e3042 == 8i) {
                                                                    {
                                                                        let _e3047 = startScale_3;
                                                                        scale2_3 = (_e3047 * 4f);
                                                                        let _e3051 = scale2_3;
                                                                        let _e3052 = scale_2;
                                                                        invScaleRatio_3 = (_e3051 / _e3052);
                                                                        let _e3055 = invScaleRatio_3;
                                                                        let _e3059 = invScaleRatio_3;
                                                                        let _e3068 = currentTransform_2;
                                                                        tr_3 = (mat3x3<f32>(vec3<f32>(_e3055, 0f, 0f), vec3<f32>(0f, _e3059, 0f), vec3<f32>(0f, 0f, 1f)) * _e3068);
                                                                        let _e3071 = tr_3;
                                                                        let _e3072 = _uv_2;
                                                                        let _e3073 = tf(_e3071, _e3072);
                                                                        v_3 = (_e3073 - vec2(0.5f));
                                                                        let _e3083 = inverseTileTransform_1[0];
                                                                        let _e3087 = inverseTileTransform_1[0];
                                                                        let _e3090 = piN_1;
                                                                        let _e3093 = piN_1;
                                                                        ang_10 = (floor((atan2(_e3083.y, _e3087.x) / _e3090)) * _e3093);
                                                                        let _e3096 = ang_10;
                                                                        let _e3097 = rotation2_(_e3096);
                                                                        let _e3098 = v_3;
                                                                        let _e3102 = inverseTileTransform_1[0];
                                                                        let _e3109 = inverseTileTransform_1[2];
                                                                        v_3 = (((_e3097 * _e3098) * length(_e3102.xy)) + (2f * _e3109.xy));
                                                                        let _e3113 = v_3;
                                                                        let _e3115 = v_3;
                                                                        let _e3117 = rnd_2;
                                                                        let _e3124 = Xn_1;
                                                                        let _e3126 = floor(((_e3113.x + (_e3115.y * sign((_e3117.y - 0.5f)))) * _e3124));
                                                                        k_11 = (_e3126 - (floor((_e3126 / 2f)) * 2f));
                                                                        let _e3133 = k_11;
                                                                        let _e3134 = vec3(_e3133);
                                                                        outCol = vec4<f32>(_e3134.x, _e3134.y, _e3134.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e3140 = mode_3;
                                                                    if (_e3140 == 9i) {
                                                                        {
                                                                            let _e3147 = inverseTileTransform_1[2];
                                                                            N_6 = floor((1000f * pow(0.25f, length(_e3147.xy))));
                                                                            let _e3158 = N_6;
                                                                            let _e3163 = inverseTileTransform_1[1];
                                                                            let _e3167 = inverseTileTransform_1[1];
                                                                            offset_1 = ((1.5707964f + (3.1415927f / _e3158)) + atan2(_e3163.y, _e3167.x));
                                                                            let _e3172 = v_3;
                                                                            let _e3174 = v_3;
                                                                            ang_11 = atan2(_e3172.y, _e3174.x);
                                                                            let _e3178 = ang_11;
                                                                            let _e3179 = offset_1;
                                                                            let _e3183 = N_6;
                                                                            let _e3186 = N_6;
                                                                            let _e3190 = offset_1;
                                                                            ang_11 = (((round((((_e3178 - _e3179) / 6.2831855f) * _e3183)) / _e3186) * 6.2831855f) + _e3190);
                                                                            let _e3194 = inverseTileTransform_1[0];
                                                                            let _e3199 = ang_11;
                                                                            let _e3202 = ang_11;
                                                                            dist_2 = ((length(_e3194.xy) * 0.5f) / max(abs(cos(_e3199)), abs(sin(_e3202))));
                                                                            let _e3208 = dist_2;
                                                                            let _e3209 = ang_11;
                                                                            let _e3211 = ang_11;
                                                                            v_3 = (_e3208 * vec2<f32>(cos(_e3209), sin(_e3211)));
                                                                            let _e3215 = inverseCurrentTransform_2;
                                                                            let _e3216 = relId_2;
                                                                            let _e3217 = v_3;
                                                                            let _e3222 = tf(_e3215, (_e3216 + (_e3217 + vec2(0.5f))));
                                                                            u_7 = _e3222;
                                                                            let _e3224 = u_7;
                                                                            let _e3228 = global.U[0];
                                                                            let _e3231 = u_7;
                                                                            let _e3240 = _mirror_wrap(((vec2<f32>((_e3224.x / _e3228.x), _e3231.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e3241 = textureSample(t_source, samp, _e3240);
                                                                            outCol = _e3241;
                                                                        }
                                                                    } else {
                                                                        let _e3242 = mode_3;
                                                                        if (_e3242 == 10i) {
                                                                            {
                                                                                let _e3247 = inverseTileTransform_1[0];
                                                                                s_3 = (length(_e3247.xy) * 0.05f);
                                                                                let _e3253 = v_3;
                                                                                v_3 = (_e3253 + vec2(0.5f));
                                                                                let _e3261 = inverseTileTransform_1[0];
                                                                                let _e3265 = inverseTileTransform_1[0];
                                                                                let _e3270 = N_7;
                                                                                let _e3275 = N_7;
                                                                                ang_12 = ((floor(((atan2(_e3261.y, _e3265.x) / 3.1415927f) * _e3270)) * 3.1415927f) / _e3275);
                                                                                let _e3278 = ang_12;
                                                                                let _e3279 = rotation2_(_e3278);
                                                                                let _e3280 = v_3;
                                                                                v_3 = (_e3279 * _e3280);
                                                                                let _e3282 = v_3;
                                                                                let _e3286 = inverseTileTransform_1[2];
                                                                                let _e3290 = tileTransform_1[0];
                                                                                let _e3298 = v_3;
                                                                                let _e3302 = inverseTileTransform_1[2];
                                                                                let _e3306 = tileTransform_1[0];
                                                                                let _e3313 = hslToRgb(vec4<f32>(((_e3282.x + (_e3286.x * length(_e3290.xy))) * 360f), 1f, (_e3298.y + (_e3302.y * length(_e3306.xy))), 1f));
                                                                                rgb_1 = _e3313;
                                                                                let _e3315 = _uv_2;
                                                                                let _e3319 = global.U[0];
                                                                                let _e3322 = _uv_2;
                                                                                let _e3331 = _mirror_wrap(((vec2<f32>((_e3315.x / _e3319.x), _e3322.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e3332 = textureSample(t_source, samp, _e3331);
                                                                                inc_3 = _e3332;
                                                                                let _e3334 = inc_3;
                                                                                let _e3336 = rgb_1;
                                                                                dist_3 = length((_e3334.xyz - _e3336.xyz));
                                                                                let _e3344 = dist_3;
                                                                                let _e3346 = s_3;
                                                                                k_12 = (1f - (smoothstep(0f, 1.7f, _e3344) * _e3346));
                                                                                let _e3350 = inc_3;
                                                                                let _e3351 = rgb_1;
                                                                                let _e3352 = k_12;
                                                                                rgb_1 = mix(_e3350, _e3351, vec4(_e3352));
                                                                                let _e3355 = rgb_1;
                                                                                outCol = _e3355;
                                                                            }
                                                                        } else {
                                                                            let _e3356 = mode_3;
                                                                            if (_e3356 == 11i) {
                                                                                {
                                                                                    let _e3362 = inverseTileTransform_1[0];
                                                                                    N_8 = round((4f * abs(_e3362.x)));
                                                                                    let _e3369 = v_3;
                                                                                    let _e3373 = N_8;
                                                                                    let _e3376 = N_8;
                                                                                    let _e3383 = N_8;
                                                                                    center_6 = (vec2<f32>(0f, ((((floor(((_e3369.y + 0.5f) * _e3373)) / _e3376) * 2f) - 1f) + (1f / _e3383))) * 0.5f);
                                                                                    let _e3390 = v_3;
                                                                                    let _e3391 = center_6;
                                                                                    dv_2 = abs((_e3390 - _e3391));
                                                                                    let _e3395 = dv_2;
                                                                                    let _e3399 = dv_2;
                                                                                    let _e3402 = N_8;
                                                                                    if ((_e3395.x < 0.45f) && (_e3399.y < (0.4f / _e3402))) {
                                                                                        {
                                                                                            let _e3408 = inverseTileTransform_1[2];
                                                                                            s_4 = (_e3408.x + 1f);
                                                                                            let _e3413 = inverseCurrentTransform_2;
                                                                                            let _e3414 = relId_2;
                                                                                            let _e3415 = s_4;
                                                                                            let _e3425 = tf(_e3413, (_e3414 + ((_e3415 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_6 = _e3425;
                                                                                            let _e3427 = inverseCurrentTransform_2;
                                                                                            let _e3428 = relId_2;
                                                                                            let _e3429 = s_4;
                                                                                            let _e3438 = tf(_e3427, (_e3428 + ((_e3429 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_6 = _e3438;
                                                                                            let _e3440 = u1_6;
                                                                                            let _e3444 = global.U[0];
                                                                                            let _e3447 = u1_6;
                                                                                            let _e3456 = _mirror_wrap(((vec2<f32>((_e3440.x / _e3444.x), _e3447.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3457 = textureSample(t_source, samp, _e3456);
                                                                                            let _e3458 = u2_6;
                                                                                            let _e3462 = global.U[0];
                                                                                            let _e3465 = u2_6;
                                                                                            let _e3474 = _mirror_wrap(((vec2<f32>((_e3458.x / _e3462.x), _e3465.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3475 = textureSample(t_source, samp, _e3474);
                                                                                            let _e3476 = center_6;
                                                                                            outCol = mix(_e3457, _e3475, vec4((_e3476.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e3482 = mode_3;
                                                                                if (_e3482 == 12i) {
                                                                                    {
                                                                                        let _e3485 = v_3;
                                                                                        v_3 = (_e3485 * vec2<f32>(2f, 2f));
                                                                                        let _e3490 = inverseTileTransform_1;
                                                                                        let _e3491 = v_3;
                                                                                        let _e3492 = tf(_e3490, _e3491);
                                                                                        v_3 = _e3492;
                                                                                        let _e3493 = inverseCurrentTransform_2;
                                                                                        let _e3494 = relId_2;
                                                                                        let _e3495 = v_3;
                                                                                        let _e3500 = tf(_e3493, (_e3494 + (_e3495 + vec2(0.5f))));
                                                                                        let _e3504 = global.U[0];
                                                                                        let _e3507 = inverseCurrentTransform_2;
                                                                                        let _e3508 = relId_2;
                                                                                        let _e3509 = v_3;
                                                                                        let _e3514 = tf(_e3507, (_e3508 + (_e3509 + vec2(0.5f))));
                                                                                        let _e3523 = _mirror_wrap(((vec2<f32>((_e3500.x / _e3504.x), _e3514.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e3524 = textureSample(t_source, samp, _e3523);
                                                                                        outCol = _e3524;
                                                                                    }
                                                                                } else {
                                                                                    let _e3525 = mode_3;
                                                                                    if (_e3525 == 13i) {
                                                                                        {
                                                                                            let _e3528 = _uv_2;
                                                                                            let _e3532 = global.U[0];
                                                                                            let _e3535 = _uv_2;
                                                                                            let _e3544 = _mirror_wrap(((vec2<f32>((_e3528.x / _e3532.x), _e3535.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e3545 = textureSample(t_source, samp, _e3544);
                                                                                            let _e3547 = luma(_e3545.xyz);
                                                                                            lum_3 = _e3547;
                                                                                            let _e3549 = inverseTileTransform_1;
                                                                                            let _e3550 = v_3;
                                                                                            let _e3555 = tf(_e3549, (_e3550 * vec2<f32>(8f, 8f)));
                                                                                            v_3 = _e3555;
                                                                                            let _e3556 = v_3;
                                                                                            let _e3559 = (_e3556.y + 1f);
                                                                                            y_1 = abs(((_e3559 - (floor((_e3559 / 2f)) * 2f)) - 1f));
                                                                                            let _e3569 = lum_3;
                                                                                            let _e3570 = y_1;
                                                                                            if (_e3569 > _e3570) {
                                                                                                local_15 = 1f;
                                                                                            } else {
                                                                                                local_15 = 0f;
                                                                                            }
                                                                                            let _e3575 = local_15;
                                                                                            k_13 = _e3575;
                                                                                            let _e3577 = k_13;
                                                                                            let _e3578 = vec3(_e3577);
                                                                                            outCol = vec4<f32>(_e3578.x, _e3578.y, _e3578.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e3584 = mode_3;
                                                                                        if (_e3584 == 14i) {
                                                                                            {
                                                                                                let _e3587 = id_1;
                                                                                                let _e3591 = global.U[0];
                                                                                                let _e3594 = id_1;
                                                                                                let _e3603 = _mirror_wrap(((vec2<f32>((_e3587.x / _e3591.x), _e3594.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e3604 = textureSample(t_source, samp, _e3603);
                                                                                                let _e3606 = luma(_e3604.xyz);
                                                                                                lum_4 = _e3606;
                                                                                                let _e3610 = tileTransform_1[0];
                                                                                                contrast_1 = length(_e3610.xy);
                                                                                                let _e3614 = v_3;
                                                                                                let _e3617 = (_e3614 + vec2(0.5f));
                                                                                                let _e3619 = contrast_1;
                                                                                                let _e3620 = lum_4;
                                                                                                outCol = vec4<f32>(_e3617.x, _e3617.y, (0.5f + (_e3619 * (_e3620 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e3629 = mode_3;
                                                                                            if (_e3629 == 15i) {
                                                                                                {
                                                                                                    let _e3632 = rnd_2;
                                                                                                    center_7 = (sign((_e3632 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e3640 = v_3;
                                                                                                    let _e3641 = center_7;
                                                                                                    dv_3 = (_e3640 - _e3641);
                                                                                                    let _e3647 = inverseTileTransform_1[0];
                                                                                                    N_9 = floor((16f * length(_e3647.xy)));
                                                                                                    let _e3655 = dv_3;
                                                                                                    let _e3657 = dv_3;
                                                                                                    let _e3660 = angOffset_1;
                                                                                                    ang_13 = (atan2(_e3655.y, _e3657.x) + _e3660);
                                                                                                    let _e3663 = ang_13;
                                                                                                    let _e3666 = N_9;
                                                                                                    let _e3669 = (((_e3663 / 3.1415927f) * _e3666) * 2f);
                                                                                                    k_14 = abs(((_e3669 - (floor((_e3669 / 2f)) * 2f)) - 1f));
                                                                                                    let _e3681 = inverseTileTransform_1[0];
                                                                                                    let _e3685 = inverseTileTransform_1[0];
                                                                                                    kCol_1 = (atan2(_e3681.y, _e3685.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e3695 = i_5;
                                                                                                        if !((_e3695 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e3702 = inverseCurrentTransform_2;
                                                                                                            let _e3703 = relId_2;
                                                                                                            let _e3706 = i_5;
                                                                                                            let _e3710 = ang_13;
                                                                                                            let _e3712 = ang_13;
                                                                                                            let _e3717 = tf(_e3702, (_e3703 + ((0.1f + (0.15f * f32(_e3706))) * vec2<f32>(cos(_e3710), sin(_e3712)))));
                                                                                                            w_7 = _e3717;
                                                                                                            let _e3719 = lum_5;
                                                                                                            let _e3720 = w_7;
                                                                                                            let _e3724 = global.U[0];
                                                                                                            let _e3727 = w_7;
                                                                                                            let _e3736 = _mirror_wrap(((vec2<f32>((_e3720.x / _e3724.x), _e3727.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3737 = textureSample(t_source, samp, _e3736);
                                                                                                            let _e3739 = luma(_e3737.xyz);
                                                                                                            lum_5 = (_e3719 + _e3739);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e3699 = i_5;
                                                                                                            i_5 = (_e3699 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e3741 = lum_5;
                                                                                                    lum_5 = (_e3741 / 5f);
                                                                                                    let _e3744 = lum_5;
                                                                                                    let _e3745 = k_14;
                                                                                                    if (_e3744 > _e3745) {
                                                                                                        local_16 = 1f;
                                                                                                    } else {
                                                                                                        local_16 = 0f;
                                                                                                    }
                                                                                                    let _e3750 = local_16;
                                                                                                    k_14 = _e3750;
                                                                                                    let _e3751 = kCol_1;
                                                                                                    if (_e3751 == 0f) {
                                                                                                        {
                                                                                                            let _e3754 = k_14;
                                                                                                            let _e3755 = vec3(_e3754);
                                                                                                            outCol = vec4<f32>(_e3755.x, _e3755.y, _e3755.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e3763 = inverseTileTransform_1[2];
                                                                                                            u1_7 = vec2<f32>(_e3763.x, 0f);
                                                                                                            let _e3771 = inverseTileTransform_1[2];
                                                                                                            u2_7 = vec2<f32>(0f, _e3771.y);
                                                                                                            let _e3775 = kCol_1;
                                                                                                            if (_e3775 > 0f) {
                                                                                                                {
                                                                                                                    let _e3778 = u1_7;
                                                                                                                    let _e3779 = id_1;
                                                                                                                    u1_7 = (_e3778 + _e3779);
                                                                                                                    let _e3781 = u2_7;
                                                                                                                    let _e3782 = id_1;
                                                                                                                    u2_7 = (_e3781 + (_e3782 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e3787 = u1_7;
                                                                                                            let _e3791 = global.U[0];
                                                                                                            let _e3794 = u1_7;
                                                                                                            let _e3803 = _mirror_wrap(((vec2<f32>((_e3787.x / _e3791.x), _e3794.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3804 = textureSample(t_source, samp, _e3803);
                                                                                                            col1_6 = _e3804;
                                                                                                            let _e3806 = u2_7;
                                                                                                            let _e3810 = global.U[0];
                                                                                                            let _e3813 = u2_7;
                                                                                                            let _e3822 = _mirror_wrap(((vec2<f32>((_e3806.x / _e3810.x), _e3813.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e3823 = textureSample(t_source, samp, _e3822);
                                                                                                            col2_5 = _e3823;
                                                                                                            let _e3825 = col1_6;
                                                                                                            let _e3827 = luma(_e3825.xyz);
                                                                                                            let _e3828 = col2_5;
                                                                                                            let _e3830 = luma(_e3828.xyz);
                                                                                                            if (_e3827 > _e3830) {
                                                                                                                let _e3833 = k_14;
                                                                                                                k_14 = (1f - _e3833);
                                                                                                            }
                                                                                                            let _e3835 = k_14;
                                                                                                            let _e3836 = vec3(_e3835);
                                                                                                            outCol1_1 = vec4<f32>(_e3836.x, _e3836.y, _e3836.z, 1f);
                                                                                                            let _e3843 = col1_6;
                                                                                                            let _e3844 = col2_5;
                                                                                                            let _e3845 = k_14;
                                                                                                            outCol2_1 = mix(_e3843, _e3844, vec4(_e3845));
                                                                                                            let _e3849 = outCol1_1;
                                                                                                            let _e3850 = outCol2_1;
                                                                                                            let _e3851 = kCol_1;
                                                                                                            outCol = mix(_e3849, _e3850, vec4(abs(_e3851)));
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
                        let _e3855 = src2_;
                        let _e3856 = outCol;
                        let _e3857 = mergeColor(_e3855, _e3856);
                        col2_6 = _e3857;
                        let _e3859 = col1_3;
                        let _e3861 = col2_6;
                        let _e3863 = k;
                        let _e3865 = mix(_e3859.xyz, _e3861.xyz, vec3(_e3863));
                        outCol = vec4<f32>(_e3865.x, _e3865.y, _e3865.z, 1f);
                    }
                } else {
                    {
                        {
                            let _e3871 = _uv;
                            _uv_3 = _e3871;
                            let _e3873 = _params;
                            startScale_4 = _e3873.startScale;
                            let _e3876 = _params;
                            subLevels_3 = _e3876.subLevels;
                            let _e3879 = _params;
                            subThreshold_3 = _e3879.subThreshold;
                            let _e3882 = _params;
                            seed_3 = _e3882.seed;
                            let _e3885 = _params;
                            hashStyle_5 = _e3885.hashStyle;
                            let _e3888 = _params;
                            coverage_4 = _e3888.coverage;
                            let _e3891 = _params;
                            currentTransform_3 = _e3891.transform;
                            let _e3894 = _params;
                            inverseCurrentTransform_3 = _e3894.inverseTransform;
                            let _e3897 = startScale_4;
                            scale_4 = _e3897;
                            loop {
                                let _e3905 = i_6;
                                let _e3906 = subLevels_3;
                                if !((_e3905 < _e3906)) {
                                    break;
                                }
                                {
                                    let _e3912 = i_6;
                                    if (_e3912 != 0f) {
                                        {
                                            let _e3928 = currentTransform_3;
                                            currentTransform_3 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e3928);
                                            let _e3930 = inverseCurrentTransform_3;
                                            inverseCurrentTransform_3 = (_e3930 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                        }
                                    }
                                    let _e3945 = currentTransform_3;
                                    let _e3946 = _uv_3;
                                    let _e3947 = tf(_e3945, _e3946);
                                    relId_3 = floor(_e3947);
                                    let _e3949 = relId_3;
                                    let _e3951 = (_e3949 * 0.13137f);
                                    let _e3952 = i_6;
                                    let _e3953 = seed_3;
                                    let _e3957 = hashStyle_5;
                                    let _e3958 = hash42sp(vec4<f32>(_e3951.x, _e3951.y, _e3952, _e3953), _e3957);
                                    rnd_3 = _e3958;
                                    let _e3959 = i_6;
                                    let _e3960 = subLevels_3;
                                    let _e3964 = rnd_3;
                                    let _e3966 = subThreshold_3;
                                    if ((_e3959 == (_e3960 - 1f)) || (_e3964.x > _e3966)) {
                                        {
                                            break;
                                        }
                                    }
                                    let _e3969 = scale_4;
                                    scale_4 = (_e3969 * 2f);
                                }
                                continuing {
                                    let _e3909 = i_6;
                                    i_6 = (_e3909 + 1f);
                                }
                            }
                            let _e3972 = inverseCurrentTransform_3;
                            let _e3973 = relId_3;
                            let _e3974 = tf(_e3972, _e3973);
                            id_2 = _e3974;
                            let _e3976 = rnd_3;
                            modeIndex_2 = i32(floor((_e3976.y * 4f)));
                            let _e3983 = modeIndex_2;
                            let _e3986 = _params.modeMap[_e3983];
                            mode_4 = _e3986;
                            let _e3989 = modeIndex_2;
                            if (_e3989 == 0i) {
                                let _e3992 = tileTransform1_1;
                                tileTransform_2 = _e3992;
                            } else {
                                let _e3993 = modeIndex_2;
                                if (_e3993 == 1i) {
                                    let _e3996 = tileTransform2_1;
                                    tileTransform_2 = _e3996;
                                } else {
                                    let _e3997 = modeIndex_2;
                                    if (_e3997 == 2i) {
                                        let _e4000 = tileTransform3_1;
                                        tileTransform_2 = _e4000;
                                    } else {
                                        let _e4001 = tileTransform4_1;
                                        tileTransform_2 = _e4001;
                                    }
                                }
                            }
                            let _e4002 = tileTransform_2;
                            inverseTileTransform_2 = _naga_inverse_3x3_f32(_e4002);
                            let _e4005 = currentTransform_3;
                            let _e4006 = _uv_3;
                            let _e4007 = tf(_e4005, _e4006);
                            let _e4008 = relId_3;
                            v_4 = ((_e4007 - _e4008) - vec2(0.5f));
                            outCol = vec4(0f);
                            let _e4015 = rnd_3;
                            let _e4019 = rnd_3;
                            let _e4025 = coverage_4;
                            if (fract(((_e4015.x * 6.222f) + (_e4019.y * 8.233f))) <= _e4025) {
                                {
                                    let _e4027 = mode_4;
                                    if (_e4027 == 0i) {
                                        {
                                            let _e4032 = inverseTileTransform_2[0];
                                            w_8 = _e4032.xy;
                                            let _e4035 = w_8;
                                            let _e4039 = w_8;
                                            w_8 = floor(vec2<f32>(dot(_e4035, vec2(20f)), dot(_e4039, vec2<f32>(20f, -20f))));
                                            let _e4047 = relId_3;
                                            let _e4049 = v_4;
                                            let _e4050 = w_8;
                                            let _e4055 = tileTransform_2[0];
                                            let _e4062 = inverseTileTransform_2[2];
                                            let _e4065 = w_8;
                                            pixId_4 = (_e4047 + (1.23f * (floor((_e4049 * _e4050)) + floor((((length(_e4055.xy) * 5f) * _e4062.xy) * _e4065)))));
                                            let _e4072 = pixId_4;
                                            let _e4073 = hash22_(_e4072);
                                            let _e4077 = global.U[0];
                                            let _e4080 = pixId_4;
                                            let _e4081 = hash22_(_e4080);
                                            let _e4090 = _mirror_wrap(((vec2<f32>((_e4073.x / _e4077.x), _e4081.y) / vec2(2f)) + vec2(0.5f)));
                                            let _e4091 = textureSample(t_source, samp, _e4090);
                                            outCol = _e4091;
                                        }
                                    } else {
                                        let _e4092 = mode_4;
                                        if (_e4092 == 1i) {
                                            {
                                                let _e4096 = v_4;
                                                let _e4099 = v_4;
                                                v_4 = vec2<f32>(0f, max(abs(_e4096.x), abs(_e4099.y)));
                                                let _e4104 = inverseCurrentTransform_3;
                                                let _e4105 = relId_3;
                                                let _e4106 = inverseTileTransform_2;
                                                let _e4107 = v_4;
                                                let _e4108 = tf(_e4106, _e4107);
                                                let _e4113 = tf(_e4104, (_e4105 + (_e4108 + vec2(0.5f))));
                                                vv_4 = _e4113;
                                                let _e4115 = vv_4;
                                                let _e4119 = global.U[0];
                                                let _e4122 = vv_4;
                                                let _e4131 = _mirror_wrap(((vec2<f32>((_e4115.x / _e4119.x), _e4122.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e4132 = textureSample(t_source, samp, _e4131);
                                                outCol = _e4132;
                                            }
                                        } else {
                                            let _e4133 = mode_4;
                                            if (_e4133 == 2i) {
                                                {
                                                    let _e4139 = inverseTileTransform_2[2];
                                                    size_6 = (0.5f + _e4139.y);
                                                    let _e4143 = v_4;
                                                    d_4 = length(_e4143);
                                                    let _e4146 = v_4;
                                                    let _e4148 = v_4;
                                                    ang_14 = atan2(_e4146.y, _e4148.x);
                                                    let _e4152 = d_4;
                                                    let _e4153 = size_6;
                                                    if (_e4152 <= _e4153) {
                                                        {
                                                            let _e4158 = spikeCount_2;
                                                            anglePeriod_2 = (6.2831855f / _e4158);
                                                            let _e4161 = ang_14;
                                                            let _e4162 = anglePeriod_2;
                                                            let _e4165 = anglePeriod_2;
                                                            a1_2 = (floor((_e4161 / _e4162)) * _e4165);
                                                            let _e4168 = a1_2;
                                                            let _e4169 = anglePeriod_2;
                                                            a2_2 = (_e4168 + _e4169);
                                                            let _e4172 = ang_14;
                                                            let _e4173 = a1_2;
                                                            let _e4175 = anglePeriod_2;
                                                            k_15 = ((_e4172 - _e4173) / _e4175);
                                                            let _e4178 = d_4;
                                                            let _e4183 = inverseTileTransform_2[0];
                                                            ds_4 = ((_e4178 * 10f) * length(_e4183.xy));
                                                            let _e4188 = relId_3;
                                                            center_8 = (_e4188 + vec2(0.5f));
                                                            let _e4193 = inverseCurrentTransform_3;
                                                            let _e4194 = center_8;
                                                            let _e4195 = ds_4;
                                                            let _e4196 = a1_2;
                                                            let _e4198 = a1_2;
                                                            let _e4205 = inverseTileTransform_2[2];
                                                            let _e4209 = tf(_e4193, ((_e4194 + (_e4195 * vec2<f32>(cos(_e4196), sin(_e4198)))) + vec2(_e4205.x)));
                                                            u1_8 = _e4209;
                                                            let _e4211 = inverseCurrentTransform_3;
                                                            let _e4212 = center_8;
                                                            let _e4213 = ds_4;
                                                            let _e4214 = a2_2;
                                                            let _e4216 = a2_2;
                                                            let _e4223 = inverseTileTransform_2[2];
                                                            let _e4227 = tf(_e4211, ((_e4212 + (_e4213 * vec2<f32>(cos(_e4214), sin(_e4216)))) + vec2(_e4223.x)));
                                                            u2_8 = _e4227;
                                                            let _e4229 = u1_8;
                                                            let _e4233 = global.U[0];
                                                            let _e4236 = u1_8;
                                                            let _e4245 = _mirror_wrap(((vec2<f32>((_e4229.x / _e4233.x), _e4236.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e4246 = textureSample(t_source, samp, _e4245);
                                                            col1_7 = _e4246;
                                                            let _e4248 = u2_8;
                                                            let _e4252 = global.U[0];
                                                            let _e4255 = u2_8;
                                                            let _e4264 = _mirror_wrap(((vec2<f32>((_e4248.x / _e4252.x), _e4255.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e4265 = textureSample(t_source, samp, _e4264);
                                                            col2_7 = _e4265;
                                                            let _e4267 = col1_7;
                                                            let _e4268 = col2_7;
                                                            let _e4269 = k_15;
                                                            outCol = mix(_e4267, _e4268, vec4(_e4269));
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e4272 = mode_4;
                                                if (_e4272 == 3i) {
                                                    {
                                                        let _e4275 = v_4;
                                                        let _e4278 = v_4;
                                                        vert_2 = (abs(_e4275.y) > abs(_e4278.x));
                                                        let _e4283 = vert_2;
                                                        if _e4283 {
                                                            let _e4284 = v_4;
                                                            local_17 = _e4284.y;
                                                        } else {
                                                            let _e4286 = v_4;
                                                            local_17 = _e4286.x;
                                                        }
                                                        let _e4289 = local_17;
                                                        a_2 = _e4289;
                                                        let _e4291 = vert_2;
                                                        if _e4291 {
                                                            let _e4292 = a_2;
                                                            let _e4294 = a_2;
                                                            local_18 = vec2<f32>(-(_e4292), _e4294);
                                                        } else {
                                                            let _e4296 = a_2;
                                                            let _e4297 = a_2;
                                                            local_18 = vec2<f32>(_e4296, -(_e4297));
                                                        }
                                                        let _e4301 = local_18;
                                                        u1_9 = _e4301;
                                                        let _e4303 = a_2;
                                                        let _e4304 = a_2;
                                                        u2_9 = vec2<f32>(_e4303, _e4304);
                                                        let _e4307 = v_4;
                                                        let _e4309 = v_4;
                                                        let _e4313 = a_2;
                                                        k_16 = ((_e4307.x + _e4309.y) / (2f * _e4313));
                                                        let _e4317 = inverseCurrentTransform_3;
                                                        let _e4318 = relId_3;
                                                        let _e4319 = inverseTileTransform_2;
                                                        let _e4320 = u1_9;
                                                        let _e4321 = tf(_e4319, _e4320);
                                                        let _e4326 = tf(_e4317, (_e4318 + (_e4321 + vec2(0.5f))));
                                                        u1_9 = _e4326;
                                                        let _e4327 = inverseCurrentTransform_3;
                                                        let _e4328 = relId_3;
                                                        let _e4329 = inverseTileTransform_2;
                                                        let _e4330 = u2_9;
                                                        let _e4331 = tf(_e4329, _e4330);
                                                        let _e4336 = tf(_e4327, (_e4328 + (_e4331 + vec2(0.5f))));
                                                        u2_9 = _e4336;
                                                        let _e4337 = u1_9;
                                                        let _e4341 = global.U[0];
                                                        let _e4344 = u1_9;
                                                        let _e4353 = _mirror_wrap(((vec2<f32>((_e4337.x / _e4341.x), _e4344.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4354 = textureSample(t_source, samp, _e4353);
                                                        col1_8 = _e4354;
                                                        let _e4356 = u2_9;
                                                        let _e4360 = global.U[0];
                                                        let _e4363 = u2_9;
                                                        let _e4372 = _mirror_wrap(((vec2<f32>((_e4356.x / _e4360.x), _e4363.y) / vec2(2f)) + vec2(0.5f)));
                                                        let _e4373 = textureSample(t_source, samp, _e4372);
                                                        col2_8 = _e4373;
                                                        let _e4375 = col1_8;
                                                        let _e4376 = col2_8;
                                                        let _e4377 = k_16;
                                                        outCol = mix(_e4375, _e4376, vec4(_e4377));
                                                    }
                                                } else {
                                                    let _e4380 = mode_4;
                                                    if (_e4380 == 4i) {
                                                        {
                                                            let _e4387 = inverseTileTransform_2[0];
                                                            let _e4391 = inverseTileTransform_2[0];
                                                            ang_15 = atan2(_e4387.y, _e4391.x);
                                                            let _e4395 = ang_15;
                                                            if (_e4395 < 0f) {
                                                                let _e4398 = relId_3;
                                                                let _e4400 = relId_3;
                                                                let _e4402 = (_e4398.x + _e4400.y);
                                                                local_19 = sign(((_e4402 - (floor((_e4402 / 2f)) * 2f)) - 0.5f));
                                                            } else {
                                                                local_19 = 1f;
                                                            }
                                                            let _e4413 = local_19;
                                                            orientation_2 = _e4413;
                                                            let _e4415 = rnd_3;
                                                            let _e4417 = ang_15;
                                                            if (_e4415.y > (abs(_e4417) / 3.1415927f)) {
                                                                let _e4422 = orientation_2;
                                                                orientation_2 = -(_e4422);
                                                            }
                                                            let _e4424 = orientation_2;
                                                            let _e4425 = v_4;
                                                            let _e4428 = v_4;
                                                            if (((_e4424 * _e4425.x) * _e4428.y) < 0f) {
                                                                local_20 = 40f;
                                                            } else {
                                                                local_20 = 2.5f;
                                                            }
                                                            let _e4436 = local_20;
                                                            p_7 = _e4436;
                                                            let _e4438 = p_7;
                                                            if (_e4438 > 30f) {
                                                                let _e4441 = v_4;
                                                                let _e4444 = v_4;
                                                                local_21 = max(abs(_e4441.x), abs(_e4444.y));
                                                            } else {
                                                                let _e4448 = v_4;
                                                                let _e4451 = p_7;
                                                                let _e4453 = v_4;
                                                                let _e4456 = p_7;
                                                                let _e4460 = p_7;
                                                                local_21 = pow((pow(abs(_e4448.x), _e4451) + pow(abs(_e4453.y), _e4456)), (1f / _e4460));
                                                            }
                                                            let _e4464 = local_21;
                                                            d_5 = _e4464;
                                                            let _e4467 = d_5;
                                                            v_4 = vec2<f32>(0f, _e4467);
                                                            let _e4469 = v_4;
                                                            let _e4471 = size_7;
                                                            if (_e4469.y <= _e4471) {
                                                                {
                                                                    let _e4473 = inverseCurrentTransform_3;
                                                                    let _e4474 = relId_3;
                                                                    let _e4475 = inverseTileTransform_2;
                                                                    let _e4476 = v_4;
                                                                    let _e4477 = tf(_e4475, _e4476);
                                                                    let _e4482 = tf(_e4473, (_e4474 + (_e4477 + vec2(0.5f))));
                                                                    vv_5 = _e4482;
                                                                    let _e4484 = vv_5;
                                                                    let _e4488 = global.U[0];
                                                                    let _e4491 = vv_5;
                                                                    let _e4500 = _mirror_wrap(((vec2<f32>((_e4484.x / _e4488.x), _e4491.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e4501 = textureSample(t_source, samp, _e4500);
                                                                    outCol = _e4501;
                                                                }
                                                            }
                                                        }
                                                    } else {
                                                        let _e4502 = mode_4;
                                                        if (_e4502 <= 6i) {
                                                            {
                                                                let _e4507 = inverseTileTransform_2[0];
                                                                scale_5 = length(_e4507.xy);
                                                                let _e4511 = scale_5;
                                                                invert_2 = (_e4511 < 1f);
                                                                let _e4515 = invert_2;
                                                                if _e4515 {
                                                                    let _e4517 = scale_5;
                                                                    scale_5 = (1f / _e4517);
                                                                }
                                                                let _e4519 = scale_5;
                                                                ds_5 = fract(_e4519);
                                                                let _e4522 = scale_5;
                                                                N_10 = max(floor(_e4522), 1f);
                                                                let _e4527 = v_4;
                                                                let _e4531 = N_10;
                                                                w_9 = (fract(((_e4527 + vec2(0.5f)) * _e4531)) - vec2(0.5f));
                                                                let _e4538 = v_4;
                                                                let _e4542 = N_10;
                                                                let _e4545 = N_10;
                                                                let _e4554 = N_10;
                                                                center_9 = ((((floor(((_e4538 + vec2(0.5f)) * _e4542)) / vec2(_e4545)) * 2f) - vec2(1f)) + vec2((1f / _e4554)));
                                                                let _e4561 = inverseTileTransform_2[0];
                                                                let _e4565 = inverseTileTransform_2[0];
                                                                ang_16 = atan2(_e4561.y, _e4565.x);
                                                                let _e4573 = ang_16;
                                                                if (_e4573 > 0f) {
                                                                    let _e4577 = ang_16;
                                                                    keepX_2 = (1f - (_e4577 / 3.1415927f));
                                                                } else {
                                                                    let _e4582 = ang_16;
                                                                    keepY_2 = (1f + (_e4582 / 3.1415927f));
                                                                }
                                                                let _e4586 = center_9;
                                                                let _e4589 = keepX_2;
                                                                let _e4591 = center_9;
                                                                let _e4594 = keepY_2;
                                                                hide_2 = ((abs(_e4586.x) > _e4589) || (abs(_e4591.y) > _e4594));
                                                                let _e4600 = ds_5;
                                                                size_8 = mix(0.5f, 0.15f, _e4600);
                                                                let _e4603 = mode_4;
                                                                let _e4606 = w_9;
                                                                let _e4608 = size_8;
                                                                let _e4611 = mode_4;
                                                                let _e4614 = w_9;
                                                                let _e4617 = size_8;
                                                                let _e4619 = w_9;
                                                                let _e4622 = size_8;
                                                                outside_2 = (((_e4603 == 6i) && (length(_e4606) > _e4608)) || ((_e4611 == 5i) && ((abs(_e4614.x) > _e4617) || (abs(_e4619.y) > _e4622))));
                                                                let _e4628 = hide_2;
                                                                let _e4629 = outside_2;
                                                                if !((_e4628 || _e4629)) {
                                                                    {
                                                                        let _e4632 = id_2;
                                                                        let _e4635 = inverseTileTransform_2[2];
                                                                        let _e4641 = global.U[0];
                                                                        let _e4644 = id_2;
                                                                        let _e4647 = inverseTileTransform_2[2];
                                                                        let _e4658 = _mirror_wrap(((vec2<f32>(((_e4632 + _e4635.xy).x / _e4641.x), (_e4644 + _e4647.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e4659 = textureSample(t_source, samp, _e4658);
                                                                        outCol = _e4659;
                                                                    }
                                                                } else {
                                                                    let _e4660 = invert_2;
                                                                    if _e4660 {
                                                                        {
                                                                            let _e4661 = id_2;
                                                                            let _e4665 = global.U[0];
                                                                            let _e4668 = id_2;
                                                                            let _e4677 = _mirror_wrap(((vec2<f32>((_e4661.x / _e4665.x), _e4668.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e4678 = textureSample(t_source, samp, _e4677);
                                                                            outCol = _e4678;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        } else {
                                                            let _e4679 = mode_4;
                                                            if (_e4679 == 7i) {
                                                                {
                                                                    let _e4684 = inverseTileTransform_2[0];
                                                                    w_10 = _e4684.xy;
                                                                    let _e4687 = w_10;
                                                                    let _e4691 = w_10;
                                                                    w_10 = floor(vec2<f32>(dot(_e4687, vec2(16f)), dot(_e4691, vec2<f32>(16f, -16f))));
                                                                    let _e4699 = startScale_4;
                                                                    let _e4706 = inverseTileTransform_2[2];
                                                                    minScale_2 = ((_e4699 * 2f) * pow(2f, floor((2f * _e4706.y))));
                                                                    let _e4713 = minScale_2;
                                                                    let _e4714 = startScale_4;
                                                                    let _e4721 = inverseTileTransform_2[2];
                                                                    maxScale_2 = max(_e4713, ((_e4714 * 4f) * pow(2f, floor((2f * _e4721.x)))));
                                                                    let _e4729 = scale_4;
                                                                    let _e4730 = minScale_2;
                                                                    let _e4731 = maxScale_2;
                                                                    scale2_4 = clamp(_e4729, _e4730, _e4731);
                                                                    let _e4734 = scale2_4;
                                                                    let _e4735 = scale_4;
                                                                    invScaleRatio_4 = (_e4734 / _e4735);
                                                                    let _e4738 = invScaleRatio_4;
                                                                    let _e4742 = invScaleRatio_4;
                                                                    let _e4751 = currentTransform_3;
                                                                    tr_4 = (mat3x3<f32>(vec3<f32>(_e4738, 0f, 0f), vec3<f32>(0f, _e4742, 0f), vec3<f32>(0f, 0f, 1f)) * _e4751);
                                                                    let _e4754 = tr_4;
                                                                    let _e4755 = _uv_3;
                                                                    let _e4756 = tf(_e4754, _e4755);
                                                                    v_4 = (_e4756 - vec2(0.5f));
                                                                    let _e4760 = v_4;
                                                                    let _e4761 = w_10;
                                                                    pixId_5 = floor((_e4760 * _e4761));
                                                                    let _e4765 = pixId_5;
                                                                    let _e4767 = pixId_5;
                                                                    let _e4769 = (_e4765.x + _e4767.y);
                                                                    k_17 = (_e4769 - (floor((_e4769 / 2f)) * 2f));
                                                                    let _e4776 = k_17;
                                                                    let _e4777 = vec3(_e4776);
                                                                    outCol = vec4<f32>(_e4777.x, _e4777.y, _e4777.z, 1f);
                                                                }
                                                            } else {
                                                                let _e4783 = mode_4;
                                                                if (_e4783 == 8i) {
                                                                    {
                                                                        let _e4788 = startScale_4;
                                                                        scale2_5 = (_e4788 * 4f);
                                                                        let _e4792 = scale2_5;
                                                                        let _e4793 = scale_4;
                                                                        invScaleRatio_5 = (_e4792 / _e4793);
                                                                        let _e4796 = invScaleRatio_5;
                                                                        let _e4800 = invScaleRatio_5;
                                                                        let _e4809 = currentTransform_3;
                                                                        tr_5 = (mat3x3<f32>(vec3<f32>(_e4796, 0f, 0f), vec3<f32>(0f, _e4800, 0f), vec3<f32>(0f, 0f, 1f)) * _e4809);
                                                                        let _e4812 = tr_5;
                                                                        let _e4813 = _uv_3;
                                                                        let _e4814 = tf(_e4812, _e4813);
                                                                        v_4 = (_e4814 - vec2(0.5f));
                                                                        let _e4824 = inverseTileTransform_2[0];
                                                                        let _e4828 = inverseTileTransform_2[0];
                                                                        let _e4831 = piN_2;
                                                                        let _e4834 = piN_2;
                                                                        ang_17 = (floor((atan2(_e4824.y, _e4828.x) / _e4831)) * _e4834);
                                                                        let _e4837 = ang_17;
                                                                        let _e4838 = rotation2_(_e4837);
                                                                        let _e4839 = v_4;
                                                                        let _e4843 = inverseTileTransform_2[0];
                                                                        let _e4850 = inverseTileTransform_2[2];
                                                                        v_4 = (((_e4838 * _e4839) * length(_e4843.xy)) + (2f * _e4850.xy));
                                                                        let _e4854 = v_4;
                                                                        let _e4856 = v_4;
                                                                        let _e4858 = rnd_3;
                                                                        let _e4865 = Xn_2;
                                                                        let _e4867 = floor(((_e4854.x + (_e4856.y * sign((_e4858.y - 0.5f)))) * _e4865));
                                                                        k_18 = (_e4867 - (floor((_e4867 / 2f)) * 2f));
                                                                        let _e4874 = k_18;
                                                                        let _e4875 = vec3(_e4874);
                                                                        outCol = vec4<f32>(_e4875.x, _e4875.y, _e4875.z, 1f);
                                                                    }
                                                                } else {
                                                                    let _e4881 = mode_4;
                                                                    if (_e4881 == 9i) {
                                                                        {
                                                                            let _e4888 = inverseTileTransform_2[2];
                                                                            N_11 = floor((1000f * pow(0.25f, length(_e4888.xy))));
                                                                            let _e4899 = N_11;
                                                                            let _e4904 = inverseTileTransform_2[1];
                                                                            let _e4908 = inverseTileTransform_2[1];
                                                                            offset_2 = ((1.5707964f + (3.1415927f / _e4899)) + atan2(_e4904.y, _e4908.x));
                                                                            let _e4913 = v_4;
                                                                            let _e4915 = v_4;
                                                                            ang_18 = atan2(_e4913.y, _e4915.x);
                                                                            let _e4919 = ang_18;
                                                                            let _e4920 = offset_2;
                                                                            let _e4924 = N_11;
                                                                            let _e4927 = N_11;
                                                                            let _e4931 = offset_2;
                                                                            ang_18 = (((round((((_e4919 - _e4920) / 6.2831855f) * _e4924)) / _e4927) * 6.2831855f) + _e4931);
                                                                            let _e4935 = inverseTileTransform_2[0];
                                                                            let _e4940 = ang_18;
                                                                            let _e4943 = ang_18;
                                                                            dist_4 = ((length(_e4935.xy) * 0.5f) / max(abs(cos(_e4940)), abs(sin(_e4943))));
                                                                            let _e4949 = dist_4;
                                                                            let _e4950 = ang_18;
                                                                            let _e4952 = ang_18;
                                                                            v_4 = (_e4949 * vec2<f32>(cos(_e4950), sin(_e4952)));
                                                                            let _e4956 = inverseCurrentTransform_3;
                                                                            let _e4957 = relId_3;
                                                                            let _e4958 = v_4;
                                                                            let _e4963 = tf(_e4956, (_e4957 + (_e4958 + vec2(0.5f))));
                                                                            u_8 = _e4963;
                                                                            let _e4965 = u_8;
                                                                            let _e4969 = global.U[0];
                                                                            let _e4972 = u_8;
                                                                            let _e4981 = _mirror_wrap(((vec2<f32>((_e4965.x / _e4969.x), _e4972.y) / vec2(2f)) + vec2(0.5f)));
                                                                            let _e4982 = textureSample(t_source, samp, _e4981);
                                                                            outCol = _e4982;
                                                                        }
                                                                    } else {
                                                                        let _e4983 = mode_4;
                                                                        if (_e4983 == 10i) {
                                                                            {
                                                                                let _e4988 = inverseTileTransform_2[0];
                                                                                s_5 = (length(_e4988.xy) * 0.05f);
                                                                                let _e4994 = v_4;
                                                                                v_4 = (_e4994 + vec2(0.5f));
                                                                                let _e5002 = inverseTileTransform_2[0];
                                                                                let _e5006 = inverseTileTransform_2[0];
                                                                                let _e5011 = N_12;
                                                                                let _e5016 = N_12;
                                                                                ang_19 = ((floor(((atan2(_e5002.y, _e5006.x) / 3.1415927f) * _e5011)) * 3.1415927f) / _e5016);
                                                                                let _e5019 = ang_19;
                                                                                let _e5020 = rotation2_(_e5019);
                                                                                let _e5021 = v_4;
                                                                                v_4 = (_e5020 * _e5021);
                                                                                let _e5023 = v_4;
                                                                                let _e5027 = inverseTileTransform_2[2];
                                                                                let _e5031 = tileTransform_2[0];
                                                                                let _e5039 = v_4;
                                                                                let _e5043 = inverseTileTransform_2[2];
                                                                                let _e5047 = tileTransform_2[0];
                                                                                let _e5054 = hslToRgb(vec4<f32>(((_e5023.x + (_e5027.x * length(_e5031.xy))) * 360f), 1f, (_e5039.y + (_e5043.y * length(_e5047.xy))), 1f));
                                                                                rgb_2 = _e5054;
                                                                                let _e5056 = _uv_3;
                                                                                let _e5060 = global.U[0];
                                                                                let _e5063 = _uv_3;
                                                                                let _e5072 = _mirror_wrap(((vec2<f32>((_e5056.x / _e5060.x), _e5063.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e5073 = textureSample(t_source, samp, _e5072);
                                                                                inc_4 = _e5073;
                                                                                let _e5075 = inc_4;
                                                                                let _e5077 = rgb_2;
                                                                                dist_5 = length((_e5075.xyz - _e5077.xyz));
                                                                                let _e5085 = dist_5;
                                                                                let _e5087 = s_5;
                                                                                k_19 = (1f - (smoothstep(0f, 1.7f, _e5085) * _e5087));
                                                                                let _e5091 = inc_4;
                                                                                let _e5092 = rgb_2;
                                                                                let _e5093 = k_19;
                                                                                rgb_2 = mix(_e5091, _e5092, vec4(_e5093));
                                                                                let _e5096 = rgb_2;
                                                                                outCol = _e5096;
                                                                            }
                                                                        } else {
                                                                            let _e5097 = mode_4;
                                                                            if (_e5097 == 11i) {
                                                                                {
                                                                                    let _e5103 = inverseTileTransform_2[0];
                                                                                    N_13 = round((4f * abs(_e5103.x)));
                                                                                    let _e5110 = v_4;
                                                                                    let _e5114 = N_13;
                                                                                    let _e5117 = N_13;
                                                                                    let _e5124 = N_13;
                                                                                    center_10 = (vec2<f32>(0f, ((((floor(((_e5110.y + 0.5f) * _e5114)) / _e5117) * 2f) - 1f) + (1f / _e5124))) * 0.5f);
                                                                                    let _e5131 = v_4;
                                                                                    let _e5132 = center_10;
                                                                                    dv_4 = abs((_e5131 - _e5132));
                                                                                    let _e5136 = dv_4;
                                                                                    let _e5140 = dv_4;
                                                                                    let _e5143 = N_13;
                                                                                    if ((_e5136.x < 0.45f) && (_e5140.y < (0.4f / _e5143))) {
                                                                                        {
                                                                                            let _e5149 = inverseTileTransform_2[2];
                                                                                            s_6 = (_e5149.x + 1f);
                                                                                            let _e5154 = inverseCurrentTransform_3;
                                                                                            let _e5155 = relId_3;
                                                                                            let _e5156 = s_6;
                                                                                            let _e5166 = tf(_e5154, (_e5155 + ((_e5156 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                            u1_10 = _e5166;
                                                                                            let _e5168 = inverseCurrentTransform_3;
                                                                                            let _e5169 = relId_3;
                                                                                            let _e5170 = s_6;
                                                                                            let _e5179 = tf(_e5168, (_e5169 + ((_e5170 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                            u2_10 = _e5179;
                                                                                            let _e5181 = u1_10;
                                                                                            let _e5185 = global.U[0];
                                                                                            let _e5188 = u1_10;
                                                                                            let _e5197 = _mirror_wrap(((vec2<f32>((_e5181.x / _e5185.x), _e5188.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5198 = textureSample(t_source, samp, _e5197);
                                                                                            let _e5199 = u2_10;
                                                                                            let _e5203 = global.U[0];
                                                                                            let _e5206 = u2_10;
                                                                                            let _e5215 = _mirror_wrap(((vec2<f32>((_e5199.x / _e5203.x), _e5206.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5216 = textureSample(t_source, samp, _e5215);
                                                                                            let _e5217 = center_10;
                                                                                            outCol = mix(_e5198, _e5216, vec4((_e5217.y + 0.5f)));
                                                                                        }
                                                                                    }
                                                                                }
                                                                            } else {
                                                                                let _e5223 = mode_4;
                                                                                if (_e5223 == 12i) {
                                                                                    {
                                                                                        let _e5226 = v_4;
                                                                                        v_4 = (_e5226 * vec2<f32>(2f, 2f));
                                                                                        let _e5231 = inverseTileTransform_2;
                                                                                        let _e5232 = v_4;
                                                                                        let _e5233 = tf(_e5231, _e5232);
                                                                                        v_4 = _e5233;
                                                                                        let _e5234 = inverseCurrentTransform_3;
                                                                                        let _e5235 = relId_3;
                                                                                        let _e5236 = v_4;
                                                                                        let _e5241 = tf(_e5234, (_e5235 + (_e5236 + vec2(0.5f))));
                                                                                        let _e5245 = global.U[0];
                                                                                        let _e5248 = inverseCurrentTransform_3;
                                                                                        let _e5249 = relId_3;
                                                                                        let _e5250 = v_4;
                                                                                        let _e5255 = tf(_e5248, (_e5249 + (_e5250 + vec2(0.5f))));
                                                                                        let _e5264 = _mirror_wrap(((vec2<f32>((_e5241.x / _e5245.x), _e5255.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e5265 = textureSample(t_source, samp, _e5264);
                                                                                        outCol = _e5265;
                                                                                    }
                                                                                } else {
                                                                                    let _e5266 = mode_4;
                                                                                    if (_e5266 == 13i) {
                                                                                        {
                                                                                            let _e5269 = _uv_3;
                                                                                            let _e5273 = global.U[0];
                                                                                            let _e5276 = _uv_3;
                                                                                            let _e5285 = _mirror_wrap(((vec2<f32>((_e5269.x / _e5273.x), _e5276.y) / vec2(2f)) + vec2(0.5f)));
                                                                                            let _e5286 = textureSample(t_source, samp, _e5285);
                                                                                            let _e5288 = luma(_e5286.xyz);
                                                                                            lum_6 = _e5288;
                                                                                            let _e5290 = inverseTileTransform_2;
                                                                                            let _e5291 = v_4;
                                                                                            let _e5296 = tf(_e5290, (_e5291 * vec2<f32>(8f, 8f)));
                                                                                            v_4 = _e5296;
                                                                                            let _e5297 = v_4;
                                                                                            let _e5300 = (_e5297.y + 1f);
                                                                                            y_2 = abs(((_e5300 - (floor((_e5300 / 2f)) * 2f)) - 1f));
                                                                                            let _e5310 = lum_6;
                                                                                            let _e5311 = y_2;
                                                                                            if (_e5310 > _e5311) {
                                                                                                local_22 = 1f;
                                                                                            } else {
                                                                                                local_22 = 0f;
                                                                                            }
                                                                                            let _e5316 = local_22;
                                                                                            k_20 = _e5316;
                                                                                            let _e5318 = k_20;
                                                                                            let _e5319 = vec3(_e5318);
                                                                                            outCol = vec4<f32>(_e5319.x, _e5319.y, _e5319.z, 1f);
                                                                                        }
                                                                                    } else {
                                                                                        let _e5325 = mode_4;
                                                                                        if (_e5325 == 14i) {
                                                                                            {
                                                                                                let _e5328 = id_2;
                                                                                                let _e5332 = global.U[0];
                                                                                                let _e5335 = id_2;
                                                                                                let _e5344 = _mirror_wrap(((vec2<f32>((_e5328.x / _e5332.x), _e5335.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                let _e5345 = textureSample(t_source, samp, _e5344);
                                                                                                let _e5347 = luma(_e5345.xyz);
                                                                                                lum_7 = _e5347;
                                                                                                let _e5351 = tileTransform_2[0];
                                                                                                contrast_2 = length(_e5351.xy);
                                                                                                let _e5355 = v_4;
                                                                                                let _e5358 = (_e5355 + vec2(0.5f));
                                                                                                let _e5360 = contrast_2;
                                                                                                let _e5361 = lum_7;
                                                                                                outCol = vec4<f32>(_e5358.x, _e5358.y, (0.5f + (_e5360 * (_e5361 - 0.5f))), 1f);
                                                                                            }
                                                                                        } else {
                                                                                            let _e5370 = mode_4;
                                                                                            if (_e5370 == 15i) {
                                                                                                {
                                                                                                    let _e5373 = rnd_3;
                                                                                                    center_11 = (sign((_e5373 - vec2(0.5f))) * 0.5f);
                                                                                                    let _e5381 = v_4;
                                                                                                    let _e5382 = center_11;
                                                                                                    dv_5 = (_e5381 - _e5382);
                                                                                                    let _e5388 = inverseTileTransform_2[0];
                                                                                                    N_14 = floor((16f * length(_e5388.xy)));
                                                                                                    let _e5396 = dv_5;
                                                                                                    let _e5398 = dv_5;
                                                                                                    let _e5401 = angOffset_2;
                                                                                                    ang_20 = (atan2(_e5396.y, _e5398.x) + _e5401);
                                                                                                    let _e5404 = ang_20;
                                                                                                    let _e5407 = N_14;
                                                                                                    let _e5410 = (((_e5404 / 3.1415927f) * _e5407) * 2f);
                                                                                                    k_21 = abs(((_e5410 - (floor((_e5410 / 2f)) * 2f)) - 1f));
                                                                                                    let _e5422 = inverseTileTransform_2[0];
                                                                                                    let _e5426 = inverseTileTransform_2[0];
                                                                                                    kCol_2 = (atan2(_e5422.y, _e5426.x) / 3.1415927f);
                                                                                                    loop {
                                                                                                        let _e5436 = i_7;
                                                                                                        if !((_e5436 < 5i)) {
                                                                                                            break;
                                                                                                        }
                                                                                                        {
                                                                                                            let _e5443 = inverseCurrentTransform_3;
                                                                                                            let _e5444 = relId_3;
                                                                                                            let _e5447 = i_7;
                                                                                                            let _e5451 = ang_20;
                                                                                                            let _e5453 = ang_20;
                                                                                                            let _e5458 = tf(_e5443, (_e5444 + ((0.1f + (0.15f * f32(_e5447))) * vec2<f32>(cos(_e5451), sin(_e5453)))));
                                                                                                            w_11 = _e5458;
                                                                                                            let _e5460 = lum_8;
                                                                                                            let _e5461 = w_11;
                                                                                                            let _e5465 = global.U[0];
                                                                                                            let _e5468 = w_11;
                                                                                                            let _e5477 = _mirror_wrap(((vec2<f32>((_e5461.x / _e5465.x), _e5468.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5478 = textureSample(t_source, samp, _e5477);
                                                                                                            let _e5480 = luma(_e5478.xyz);
                                                                                                            lum_8 = (_e5460 + _e5480);
                                                                                                        }
                                                                                                        continuing {
                                                                                                            let _e5440 = i_7;
                                                                                                            i_7 = (_e5440 + 1i);
                                                                                                        }
                                                                                                    }
                                                                                                    let _e5482 = lum_8;
                                                                                                    lum_8 = (_e5482 / 5f);
                                                                                                    let _e5485 = lum_8;
                                                                                                    let _e5486 = k_21;
                                                                                                    if (_e5485 > _e5486) {
                                                                                                        local_23 = 1f;
                                                                                                    } else {
                                                                                                        local_23 = 0f;
                                                                                                    }
                                                                                                    let _e5491 = local_23;
                                                                                                    k_21 = _e5491;
                                                                                                    let _e5492 = kCol_2;
                                                                                                    if (_e5492 == 0f) {
                                                                                                        {
                                                                                                            let _e5495 = k_21;
                                                                                                            let _e5496 = vec3(_e5495);
                                                                                                            outCol = vec4<f32>(_e5496.x, _e5496.y, _e5496.z, 1f);
                                                                                                        }
                                                                                                    } else {
                                                                                                        {
                                                                                                            let _e5504 = inverseTileTransform_2[2];
                                                                                                            u1_11 = vec2<f32>(_e5504.x, 0f);
                                                                                                            let _e5512 = inverseTileTransform_2[2];
                                                                                                            u2_11 = vec2<f32>(0f, _e5512.y);
                                                                                                            let _e5516 = kCol_2;
                                                                                                            if (_e5516 > 0f) {
                                                                                                                {
                                                                                                                    let _e5519 = u1_11;
                                                                                                                    let _e5520 = id_2;
                                                                                                                    u1_11 = (_e5519 + _e5520);
                                                                                                                    let _e5522 = u2_11;
                                                                                                                    let _e5523 = id_2;
                                                                                                                    u2_11 = (_e5522 + (_e5523 + vec2(1f)));
                                                                                                                }
                                                                                                            }
                                                                                                            let _e5528 = u1_11;
                                                                                                            let _e5532 = global.U[0];
                                                                                                            let _e5535 = u1_11;
                                                                                                            let _e5544 = _mirror_wrap(((vec2<f32>((_e5528.x / _e5532.x), _e5535.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5545 = textureSample(t_source, samp, _e5544);
                                                                                                            col1_9 = _e5545;
                                                                                                            let _e5547 = u2_11;
                                                                                                            let _e5551 = global.U[0];
                                                                                                            let _e5554 = u2_11;
                                                                                                            let _e5563 = _mirror_wrap(((vec2<f32>((_e5547.x / _e5551.x), _e5554.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                            let _e5564 = textureSample(t_source, samp, _e5563);
                                                                                                            col2_9 = _e5564;
                                                                                                            let _e5566 = col1_9;
                                                                                                            let _e5568 = luma(_e5566.xyz);
                                                                                                            let _e5569 = col2_9;
                                                                                                            let _e5571 = luma(_e5569.xyz);
                                                                                                            if (_e5568 > _e5571) {
                                                                                                                let _e5574 = k_21;
                                                                                                                k_21 = (1f - _e5574);
                                                                                                            }
                                                                                                            let _e5576 = k_21;
                                                                                                            let _e5577 = vec3(_e5576);
                                                                                                            outCol1_2 = vec4<f32>(_e5577.x, _e5577.y, _e5577.z, 1f);
                                                                                                            let _e5584 = col1_9;
                                                                                                            let _e5585 = col2_9;
                                                                                                            let _e5586 = k_21;
                                                                                                            outCol2_2 = mix(_e5584, _e5585, vec4(_e5586));
                                                                                                            let _e5590 = outCol1_2;
                                                                                                            let _e5591 = outCol2_2;
                                                                                                            let _e5592 = kCol_2;
                                                                                                            outCol = mix(_e5590, _e5591, vec4(abs(_e5592)));
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
            let _e5596 = col;
            let _e5597 = outCol;
            let _e5598 = mergeColor(_e5596, _e5597);
            col = _e5598;
        }
    }
    let _e5599 = modelTransform_1;
    let _e5600 = overTransform_1;
    overTransform_1 = (_e5599 * _e5600);
    let _e5602 = overTransform_1;
    inverseUnderTransform = _naga_inverse_3x3_f32(_e5602);
    let _e5607 = inverseUnderTransform[0];
    startScale_5 = length(_e5607.xy);
    let _e5612 = overMode_1;
    if (_e5612 < 16i) {
        {
            loop {
                let _e5617 = i_8;
                if !((_e5617 < 4i)) {
                    break;
                }
                let _e5624 = i_8;
                let _e5626 = overMode_1;
                modeMap_1[_e5624] = _e5626;
                continuing {
                    let _e5621 = i_8;
                    i_8 = (_e5621 + 1i);
                }
            }
        }
    } else {
        {
            let _e5627 = overMode_1;
            overMode_1 = (_e5627 - 16i);
            let _e5632 = overMode_1;
            modeMap_1[0i] = (_e5632 & 15i);
            let _e5635 = overMode_1;
            overMode_1 = (_e5635 / 16i);
            let _e5640 = overMode_1;
            modeMap_1[1i] = (_e5640 & 15i);
            let _e5643 = overMode_1;
            overMode_1 = (_e5643 / 16i);
            let _e5648 = overMode_1;
            modeMap_1[2i] = (_e5648 & 15i);
            let _e5651 = overMode_1;
            overMode_1 = (_e5651 / 16i);
            let _e5656 = overMode_1;
            modeMap_1[3i] = (_e5656 & 15i);
        }
    }
    let _e5660 = inverseUnderTransform;
    params.transform = _e5660;
    let _e5662 = overTransform_1;
    params.inverseTransform = _e5662;
    let _e5664 = startScale_5;
    params.startScale = _e5664;
    let _e5666 = overLevels_1;
    params.subLevels = f32(_e5666);
    let _e5669 = overThreshold_1;
    params.subThreshold = _e5669;
    let _e5675 = modeMap_1[0];
    params.modeMap[0i] = _e5675;
    let _e5681 = modeMap_1[1];
    params.modeMap[1i] = _e5681;
    let _e5687 = modeMap_1[2];
    params.modeMap[2i] = _e5687;
    let _e5693 = modeMap_1[3];
    params.modeMap[3i] = _e5693;
    let _e5695 = overCoverage_1;
    params.coverage = _e5695;
    let _e5697 = overStreakCoverage_1;
    params.streakInterpolateCoverage = _e5697;
    let _e5699 = overStreakLevels_1;
    params.streakSubLevels = _e5699;
    let _e5701 = overStreakBalance_1;
    params.streakVerticality = ((_e5701 + 1f) * 0.5f);
    let _e5707 = overRandomSeed_1;
    params.seed = _e5707;
    let _e5709 = overRandomType_1;
    params.hashStyle = _e5709;
    {
        let _e5710 = pos_1;
        _uv_4 = _e5710;
        let _e5712 = params;
        _params_1 = _e5712;
        let _e5717 = _params_1;
        startScale_6 = _e5717.startScale;
        let _e5720 = _params_1;
        subLevels_4 = _e5720.subLevels;
        let _e5723 = _params_1;
        subThreshold_4 = _e5723.subThreshold;
        let _e5726 = _params_1;
        streakInterpolateCoverage_1 = _e5726.streakInterpolateCoverage;
        let _e5729 = _params_1;
        streakSubLevels_1 = _e5729.streakSubLevels;
        let _e5732 = _params_1;
        streakVerticality_1 = _e5732.streakVerticality;
        let _e5735 = _params_1;
        seed_4 = _e5735.seed;
        let _e5738 = _params_1;
        hashStyle_6 = _e5738.hashStyle;
        let _e5741 = _params_1;
        currentTransform_4 = _e5741.transform;
        let _e5744 = _params_1;
        inverseCurrentTransform_4 = _e5744.inverseTransform;
        loop {
            let _e5754 = i_9;
            let _e5755 = streakSubLevels_1;
            if !((_e5754 < f32(_e5755))) {
                break;
            }
            {
                let _e5762 = i_9;
                if (_e5762 != 0f) {
                    {
                        let _e5778 = currentTransform_4;
                        currentTransform_4 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e5778);
                        let _e5780 = inverseCurrentTransform_4;
                        inverseCurrentTransform_4 = (_e5780 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                    }
                }
                let _e5795 = currentTransform_4;
                let _e5796 = _uv_4;
                let _e5797 = tf(_e5795, _e5796);
                relId_4 = floor(_e5797);
                let _e5799 = relId_4;
                let _e5801 = (_e5799 * 0.08845f);
                let _e5802 = i_9;
                let _e5803 = seed_4;
                let _e5807 = hashStyle_6;
                let _e5808 = hash42sp(vec4<f32>(_e5801.x, _e5801.y, _e5802, _e5803), _e5807);
                rnd_4 = _e5808;
                let _e5809 = rnd_4;
                let _e5811 = subThreshold_4;
                if (_e5809.x > _e5811) {
                    {
                        break;
                    }
                }
                let _e5813 = streakLevel_1;
                streakLevel_1 = (_e5813 + 1i);
            }
            continuing {
                let _e5759 = i_9;
                i_9 = (_e5759 + 1f);
            }
        }
        let _e5816 = rnd_4;
        let _e5818 = streakInterpolateCoverage_1;
        if (_e5816.y <= _e5818) {
            {
                let _e5823 = currentTransform_4;
                let _e5824 = _uv_4;
                let _e5825 = tf(_e5823, _e5824);
                let _e5826 = relId_4;
                v_5 = (_e5825 - _e5826);
                let _e5828 = rnd_4;
                let _e5833 = streakVerticality_1;
                if (fract((_e5828.y * 13.323f)) < _e5833) {
                    {
                        let _e5835 = v_5;
                        k_22 = _e5835.y;
                        let _e5837 = inverseCurrentTransform_4;
                        let _e5838 = relId_4;
                        let _e5839 = v_5;
                        let _e5845 = tf(_e5837, (_e5838 + vec2<f32>(_e5839.x, -0.0001f)));
                        uu1_1 = _e5845;
                        let _e5846 = inverseCurrentTransform_4;
                        let _e5847 = relId_4;
                        let _e5848 = v_5;
                        let _e5853 = tf(_e5846, (_e5847 + vec2<f32>(_e5848.x, 0.9999f)));
                        uu2_1 = _e5853;
                    }
                } else {
                    {
                        let _e5854 = v_5;
                        k_22 = _e5854.x;
                        let _e5856 = inverseCurrentTransform_4;
                        let _e5857 = relId_4;
                        let _e5860 = v_5;
                        let _e5864 = tf(_e5856, (_e5857 + vec2<f32>(-0.0001f, _e5860.y)));
                        uu1_1 = _e5864;
                        let _e5865 = inverseCurrentTransform_4;
                        let _e5866 = relId_4;
                        let _e5868 = v_5;
                        let _e5872 = tf(_e5865, (_e5866 + vec2<f32>(0.9999f, _e5868.y)));
                        uu2_1 = _e5872;
                    }
                }
                let _e5873 = uu1_1;
                let _e5877 = global.U[0];
                let _e5880 = uu1_1;
                let _e5889 = _mirror_wrap(((vec2<f32>((_e5873.x / _e5877.x), _e5880.y) / vec2(2f)) + vec2(0.5f)));
                let _e5890 = textureSample(t_source, samp, _e5889);
                src1_1 = _e5890;
                let _e5892 = uu2_1;
                let _e5896 = global.U[0];
                let _e5899 = uu2_1;
                let _e5908 = _mirror_wrap(((vec2<f32>((_e5892.x / _e5896.x), _e5899.y) / vec2(2f)) + vec2(0.5f)));
                let _e5909 = textureSample(t_source, samp, _e5908);
                src2_1 = _e5909;
                {
                    let _e5911 = uu1_1;
                    _uv_5 = _e5911;
                    let _e5913 = _params_1;
                    startScale_7 = _e5913.startScale;
                    let _e5916 = _params_1;
                    subLevels_5 = _e5916.subLevels;
                    let _e5919 = _params_1;
                    subThreshold_5 = _e5919.subThreshold;
                    let _e5922 = _params_1;
                    seed_5 = _e5922.seed;
                    let _e5925 = _params_1;
                    hashStyle_7 = _e5925.hashStyle;
                    let _e5928 = _params_1;
                    coverage_5 = _e5928.coverage;
                    let _e5931 = _params_1;
                    currentTransform_5 = _e5931.transform;
                    let _e5934 = _params_1;
                    inverseCurrentTransform_5 = _e5934.inverseTransform;
                    let _e5937 = startScale_7;
                    scale_6 = _e5937;
                    loop {
                        let _e5945 = i_10;
                        let _e5946 = subLevels_5;
                        if !((_e5945 < _e5946)) {
                            break;
                        }
                        {
                            let _e5952 = i_10;
                            if (_e5952 != 0f) {
                                {
                                    let _e5968 = currentTransform_5;
                                    currentTransform_5 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e5968);
                                    let _e5970 = inverseCurrentTransform_5;
                                    inverseCurrentTransform_5 = (_e5970 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e5985 = currentTransform_5;
                            let _e5986 = _uv_5;
                            let _e5987 = tf(_e5985, _e5986);
                            relId_5 = floor(_e5987);
                            let _e5989 = relId_5;
                            let _e5991 = (_e5989 * 0.13137f);
                            let _e5992 = i_10;
                            let _e5993 = seed_5;
                            let _e5997 = hashStyle_7;
                            let _e5998 = hash42sp(vec4<f32>(_e5991.x, _e5991.y, _e5992, _e5993), _e5997);
                            rnd_5 = _e5998;
                            let _e5999 = i_10;
                            let _e6000 = subLevels_5;
                            let _e6004 = rnd_5;
                            let _e6006 = subThreshold_5;
                            if ((_e5999 == (_e6000 - 1f)) || (_e6004.x > _e6006)) {
                                {
                                    break;
                                }
                            }
                            let _e6009 = scale_6;
                            scale_6 = (_e6009 * 2f);
                        }
                        continuing {
                            let _e5949 = i_10;
                            i_10 = (_e5949 + 1f);
                        }
                    }
                    let _e6012 = inverseCurrentTransform_5;
                    let _e6013 = relId_5;
                    let _e6014 = tf(_e6012, _e6013);
                    id_3 = _e6014;
                    let _e6016 = rnd_5;
                    modeIndex_3 = i32(floor((_e6016.y * 4f)));
                    let _e6023 = modeIndex_3;
                    let _e6026 = _params_1.modeMap[_e6023];
                    mode_5 = _e6026;
                    let _e6029 = modeIndex_3;
                    if (_e6029 == 0i) {
                        let _e6032 = tileTransform1_1;
                        tileTransform_3 = _e6032;
                    } else {
                        let _e6033 = modeIndex_3;
                        if (_e6033 == 1i) {
                            let _e6036 = tileTransform2_1;
                            tileTransform_3 = _e6036;
                        } else {
                            let _e6037 = modeIndex_3;
                            if (_e6037 == 2i) {
                                let _e6040 = tileTransform3_1;
                                tileTransform_3 = _e6040;
                            } else {
                                let _e6041 = tileTransform4_1;
                                tileTransform_3 = _e6041;
                            }
                        }
                    }
                    let _e6042 = tileTransform_3;
                    inverseTileTransform_3 = _naga_inverse_3x3_f32(_e6042);
                    let _e6045 = currentTransform_5;
                    let _e6046 = _uv_5;
                    let _e6047 = tf(_e6045, _e6046);
                    let _e6048 = relId_5;
                    v_6 = ((_e6047 - _e6048) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e6055 = rnd_5;
                    let _e6059 = rnd_5;
                    let _e6065 = coverage_5;
                    if (fract(((_e6055.x * 6.222f) + (_e6059.y * 8.233f))) <= _e6065) {
                        {
                            let _e6067 = mode_5;
                            if (_e6067 == 0i) {
                                {
                                    let _e6072 = inverseTileTransform_3[0];
                                    w_12 = _e6072.xy;
                                    let _e6075 = w_12;
                                    let _e6079 = w_12;
                                    w_12 = floor(vec2<f32>(dot(_e6075, vec2(20f)), dot(_e6079, vec2<f32>(20f, -20f))));
                                    let _e6087 = relId_5;
                                    let _e6089 = v_6;
                                    let _e6090 = w_12;
                                    let _e6095 = tileTransform_3[0];
                                    let _e6102 = inverseTileTransform_3[2];
                                    let _e6105 = w_12;
                                    pixId_6 = (_e6087 + (1.23f * (floor((_e6089 * _e6090)) + floor((((length(_e6095.xy) * 5f) * _e6102.xy) * _e6105)))));
                                    let _e6112 = pixId_6;
                                    let _e6113 = hash22_(_e6112);
                                    let _e6117 = global.U[0];
                                    let _e6120 = pixId_6;
                                    let _e6121 = hash22_(_e6120);
                                    let _e6130 = _mirror_wrap(((vec2<f32>((_e6113.x / _e6117.x), _e6121.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e6131 = textureSample(t_source, samp, _e6130);
                                    outCol = _e6131;
                                }
                            } else {
                                let _e6132 = mode_5;
                                if (_e6132 == 1i) {
                                    {
                                        let _e6136 = v_6;
                                        let _e6139 = v_6;
                                        v_6 = vec2<f32>(0f, max(abs(_e6136.x), abs(_e6139.y)));
                                        let _e6144 = inverseCurrentTransform_5;
                                        let _e6145 = relId_5;
                                        let _e6146 = inverseTileTransform_3;
                                        let _e6147 = v_6;
                                        let _e6148 = tf(_e6146, _e6147);
                                        let _e6153 = tf(_e6144, (_e6145 + (_e6148 + vec2(0.5f))));
                                        vv_6 = _e6153;
                                        let _e6155 = vv_6;
                                        let _e6159 = global.U[0];
                                        let _e6162 = vv_6;
                                        let _e6171 = _mirror_wrap(((vec2<f32>((_e6155.x / _e6159.x), _e6162.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e6172 = textureSample(t_source, samp, _e6171);
                                        outCol = _e6172;
                                    }
                                } else {
                                    let _e6173 = mode_5;
                                    if (_e6173 == 2i) {
                                        {
                                            let _e6179 = inverseTileTransform_3[2];
                                            size_9 = (0.5f + _e6179.y);
                                            let _e6183 = v_6;
                                            d_6 = length(_e6183);
                                            let _e6186 = v_6;
                                            let _e6188 = v_6;
                                            ang_21 = atan2(_e6186.y, _e6188.x);
                                            let _e6192 = d_6;
                                            let _e6193 = size_9;
                                            if (_e6192 <= _e6193) {
                                                {
                                                    let _e6198 = spikeCount_3;
                                                    anglePeriod_3 = (6.2831855f / _e6198);
                                                    let _e6201 = ang_21;
                                                    let _e6202 = anglePeriod_3;
                                                    let _e6205 = anglePeriod_3;
                                                    a1_3 = (floor((_e6201 / _e6202)) * _e6205);
                                                    let _e6208 = a1_3;
                                                    let _e6209 = anglePeriod_3;
                                                    a2_3 = (_e6208 + _e6209);
                                                    let _e6212 = ang_21;
                                                    let _e6213 = a1_3;
                                                    let _e6215 = anglePeriod_3;
                                                    k_23 = ((_e6212 - _e6213) / _e6215);
                                                    let _e6218 = d_6;
                                                    let _e6223 = inverseTileTransform_3[0];
                                                    ds_6 = ((_e6218 * 10f) * length(_e6223.xy));
                                                    let _e6228 = relId_5;
                                                    center_12 = (_e6228 + vec2(0.5f));
                                                    let _e6233 = inverseCurrentTransform_5;
                                                    let _e6234 = center_12;
                                                    let _e6235 = ds_6;
                                                    let _e6236 = a1_3;
                                                    let _e6238 = a1_3;
                                                    let _e6245 = inverseTileTransform_3[2];
                                                    let _e6249 = tf(_e6233, ((_e6234 + (_e6235 * vec2<f32>(cos(_e6236), sin(_e6238)))) + vec2(_e6245.x)));
                                                    u1_12 = _e6249;
                                                    let _e6251 = inverseCurrentTransform_5;
                                                    let _e6252 = center_12;
                                                    let _e6253 = ds_6;
                                                    let _e6254 = a2_3;
                                                    let _e6256 = a2_3;
                                                    let _e6263 = inverseTileTransform_3[2];
                                                    let _e6267 = tf(_e6251, ((_e6252 + (_e6253 * vec2<f32>(cos(_e6254), sin(_e6256)))) + vec2(_e6263.x)));
                                                    u2_12 = _e6267;
                                                    let _e6269 = u1_12;
                                                    let _e6273 = global.U[0];
                                                    let _e6276 = u1_12;
                                                    let _e6285 = _mirror_wrap(((vec2<f32>((_e6269.x / _e6273.x), _e6276.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e6286 = textureSample(t_source, samp, _e6285);
                                                    col1_10 = _e6286;
                                                    let _e6288 = u2_12;
                                                    let _e6292 = global.U[0];
                                                    let _e6295 = u2_12;
                                                    let _e6304 = _mirror_wrap(((vec2<f32>((_e6288.x / _e6292.x), _e6295.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e6305 = textureSample(t_source, samp, _e6304);
                                                    col2_10 = _e6305;
                                                    let _e6307 = col1_10;
                                                    let _e6308 = col2_10;
                                                    let _e6309 = k_23;
                                                    outCol = mix(_e6307, _e6308, vec4(_e6309));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e6312 = mode_5;
                                        if (_e6312 == 3i) {
                                            {
                                                let _e6315 = v_6;
                                                let _e6318 = v_6;
                                                vert_3 = (abs(_e6315.y) > abs(_e6318.x));
                                                let _e6323 = vert_3;
                                                if _e6323 {
                                                    let _e6324 = v_6;
                                                    local_24 = _e6324.y;
                                                } else {
                                                    let _e6326 = v_6;
                                                    local_24 = _e6326.x;
                                                }
                                                let _e6329 = local_24;
                                                a_3 = _e6329;
                                                let _e6331 = vert_3;
                                                if _e6331 {
                                                    let _e6332 = a_3;
                                                    let _e6334 = a_3;
                                                    local_25 = vec2<f32>(-(_e6332), _e6334);
                                                } else {
                                                    let _e6336 = a_3;
                                                    let _e6337 = a_3;
                                                    local_25 = vec2<f32>(_e6336, -(_e6337));
                                                }
                                                let _e6341 = local_25;
                                                u1_13 = _e6341;
                                                let _e6343 = a_3;
                                                let _e6344 = a_3;
                                                u2_13 = vec2<f32>(_e6343, _e6344);
                                                let _e6347 = v_6;
                                                let _e6349 = v_6;
                                                let _e6353 = a_3;
                                                k_24 = ((_e6347.x + _e6349.y) / (2f * _e6353));
                                                let _e6357 = inverseCurrentTransform_5;
                                                let _e6358 = relId_5;
                                                let _e6359 = inverseTileTransform_3;
                                                let _e6360 = u1_13;
                                                let _e6361 = tf(_e6359, _e6360);
                                                let _e6366 = tf(_e6357, (_e6358 + (_e6361 + vec2(0.5f))));
                                                u1_13 = _e6366;
                                                let _e6367 = inverseCurrentTransform_5;
                                                let _e6368 = relId_5;
                                                let _e6369 = inverseTileTransform_3;
                                                let _e6370 = u2_13;
                                                let _e6371 = tf(_e6369, _e6370);
                                                let _e6376 = tf(_e6367, (_e6368 + (_e6371 + vec2(0.5f))));
                                                u2_13 = _e6376;
                                                let _e6377 = u1_13;
                                                let _e6381 = global.U[0];
                                                let _e6384 = u1_13;
                                                let _e6393 = _mirror_wrap(((vec2<f32>((_e6377.x / _e6381.x), _e6384.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e6394 = textureSample(t_source, samp, _e6393);
                                                col1_11 = _e6394;
                                                let _e6396 = u2_13;
                                                let _e6400 = global.U[0];
                                                let _e6403 = u2_13;
                                                let _e6412 = _mirror_wrap(((vec2<f32>((_e6396.x / _e6400.x), _e6403.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e6413 = textureSample(t_source, samp, _e6412);
                                                col2_11 = _e6413;
                                                let _e6415 = col1_11;
                                                let _e6416 = col2_11;
                                                let _e6417 = k_24;
                                                outCol = mix(_e6415, _e6416, vec4(_e6417));
                                            }
                                        } else {
                                            let _e6420 = mode_5;
                                            if (_e6420 == 4i) {
                                                {
                                                    let _e6427 = inverseTileTransform_3[0];
                                                    let _e6431 = inverseTileTransform_3[0];
                                                    ang_22 = atan2(_e6427.y, _e6431.x);
                                                    let _e6435 = ang_22;
                                                    if (_e6435 < 0f) {
                                                        let _e6438 = relId_5;
                                                        let _e6440 = relId_5;
                                                        let _e6442 = (_e6438.x + _e6440.y);
                                                        local_26 = sign(((_e6442 - (floor((_e6442 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_26 = 1f;
                                                    }
                                                    let _e6453 = local_26;
                                                    orientation_3 = _e6453;
                                                    let _e6455 = rnd_5;
                                                    let _e6457 = ang_22;
                                                    if (_e6455.y > (abs(_e6457) / 3.1415927f)) {
                                                        let _e6462 = orientation_3;
                                                        orientation_3 = -(_e6462);
                                                    }
                                                    let _e6464 = orientation_3;
                                                    let _e6465 = v_6;
                                                    let _e6468 = v_6;
                                                    if (((_e6464 * _e6465.x) * _e6468.y) < 0f) {
                                                        local_27 = 40f;
                                                    } else {
                                                        local_27 = 2.5f;
                                                    }
                                                    let _e6476 = local_27;
                                                    p_8 = _e6476;
                                                    let _e6478 = p_8;
                                                    if (_e6478 > 30f) {
                                                        let _e6481 = v_6;
                                                        let _e6484 = v_6;
                                                        local_28 = max(abs(_e6481.x), abs(_e6484.y));
                                                    } else {
                                                        let _e6488 = v_6;
                                                        let _e6491 = p_8;
                                                        let _e6493 = v_6;
                                                        let _e6496 = p_8;
                                                        let _e6500 = p_8;
                                                        local_28 = pow((pow(abs(_e6488.x), _e6491) + pow(abs(_e6493.y), _e6496)), (1f / _e6500));
                                                    }
                                                    let _e6504 = local_28;
                                                    d_7 = _e6504;
                                                    let _e6507 = d_7;
                                                    v_6 = vec2<f32>(0f, _e6507);
                                                    let _e6509 = v_6;
                                                    let _e6511 = size_10;
                                                    if (_e6509.y <= _e6511) {
                                                        {
                                                            let _e6513 = inverseCurrentTransform_5;
                                                            let _e6514 = relId_5;
                                                            let _e6515 = inverseTileTransform_3;
                                                            let _e6516 = v_6;
                                                            let _e6517 = tf(_e6515, _e6516);
                                                            let _e6522 = tf(_e6513, (_e6514 + (_e6517 + vec2(0.5f))));
                                                            vv_7 = _e6522;
                                                            let _e6524 = vv_7;
                                                            let _e6528 = global.U[0];
                                                            let _e6531 = vv_7;
                                                            let _e6540 = _mirror_wrap(((vec2<f32>((_e6524.x / _e6528.x), _e6531.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e6541 = textureSample(t_source, samp, _e6540);
                                                            outCol = _e6541;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e6542 = mode_5;
                                                if (_e6542 <= 6i) {
                                                    {
                                                        let _e6547 = inverseTileTransform_3[0];
                                                        scale_7 = length(_e6547.xy);
                                                        let _e6551 = scale_7;
                                                        invert_3 = (_e6551 < 1f);
                                                        let _e6555 = invert_3;
                                                        if _e6555 {
                                                            let _e6557 = scale_7;
                                                            scale_7 = (1f / _e6557);
                                                        }
                                                        let _e6559 = scale_7;
                                                        ds_7 = fract(_e6559);
                                                        let _e6562 = scale_7;
                                                        N_15 = max(floor(_e6562), 1f);
                                                        let _e6567 = v_6;
                                                        let _e6571 = N_15;
                                                        w_13 = (fract(((_e6567 + vec2(0.5f)) * _e6571)) - vec2(0.5f));
                                                        let _e6578 = v_6;
                                                        let _e6582 = N_15;
                                                        let _e6585 = N_15;
                                                        let _e6594 = N_15;
                                                        center_13 = ((((floor(((_e6578 + vec2(0.5f)) * _e6582)) / vec2(_e6585)) * 2f) - vec2(1f)) + vec2((1f / _e6594)));
                                                        let _e6601 = inverseTileTransform_3[0];
                                                        let _e6605 = inverseTileTransform_3[0];
                                                        ang_23 = atan2(_e6601.y, _e6605.x);
                                                        let _e6613 = ang_23;
                                                        if (_e6613 > 0f) {
                                                            let _e6617 = ang_23;
                                                            keepX_3 = (1f - (_e6617 / 3.1415927f));
                                                        } else {
                                                            let _e6622 = ang_23;
                                                            keepY_3 = (1f + (_e6622 / 3.1415927f));
                                                        }
                                                        let _e6626 = center_13;
                                                        let _e6629 = keepX_3;
                                                        let _e6631 = center_13;
                                                        let _e6634 = keepY_3;
                                                        hide_3 = ((abs(_e6626.x) > _e6629) || (abs(_e6631.y) > _e6634));
                                                        let _e6640 = ds_7;
                                                        size_11 = mix(0.5f, 0.15f, _e6640);
                                                        let _e6643 = mode_5;
                                                        let _e6646 = w_13;
                                                        let _e6648 = size_11;
                                                        let _e6651 = mode_5;
                                                        let _e6654 = w_13;
                                                        let _e6657 = size_11;
                                                        let _e6659 = w_13;
                                                        let _e6662 = size_11;
                                                        outside_3 = (((_e6643 == 6i) && (length(_e6646) > _e6648)) || ((_e6651 == 5i) && ((abs(_e6654.x) > _e6657) || (abs(_e6659.y) > _e6662))));
                                                        let _e6668 = hide_3;
                                                        let _e6669 = outside_3;
                                                        if !((_e6668 || _e6669)) {
                                                            {
                                                                let _e6672 = id_3;
                                                                let _e6675 = inverseTileTransform_3[2];
                                                                let _e6681 = global.U[0];
                                                                let _e6684 = id_3;
                                                                let _e6687 = inverseTileTransform_3[2];
                                                                let _e6698 = _mirror_wrap(((vec2<f32>(((_e6672 + _e6675.xy).x / _e6681.x), (_e6684 + _e6687.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e6699 = textureSample(t_source, samp, _e6698);
                                                                outCol = _e6699;
                                                            }
                                                        } else {
                                                            let _e6700 = invert_3;
                                                            if _e6700 {
                                                                {
                                                                    let _e6701 = id_3;
                                                                    let _e6705 = global.U[0];
                                                                    let _e6708 = id_3;
                                                                    let _e6717 = _mirror_wrap(((vec2<f32>((_e6701.x / _e6705.x), _e6708.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e6718 = textureSample(t_source, samp, _e6717);
                                                                    outCol = _e6718;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e6719 = mode_5;
                                                    if (_e6719 == 7i) {
                                                        {
                                                            let _e6724 = inverseTileTransform_3[0];
                                                            w_14 = _e6724.xy;
                                                            let _e6727 = w_14;
                                                            let _e6731 = w_14;
                                                            w_14 = floor(vec2<f32>(dot(_e6727, vec2(16f)), dot(_e6731, vec2<f32>(16f, -16f))));
                                                            let _e6739 = startScale_7;
                                                            let _e6746 = inverseTileTransform_3[2];
                                                            minScale_3 = ((_e6739 * 2f) * pow(2f, floor((2f * _e6746.y))));
                                                            let _e6753 = minScale_3;
                                                            let _e6754 = startScale_7;
                                                            let _e6761 = inverseTileTransform_3[2];
                                                            maxScale_3 = max(_e6753, ((_e6754 * 4f) * pow(2f, floor((2f * _e6761.x)))));
                                                            let _e6769 = scale_6;
                                                            let _e6770 = minScale_3;
                                                            let _e6771 = maxScale_3;
                                                            scale2_6 = clamp(_e6769, _e6770, _e6771);
                                                            let _e6774 = scale2_6;
                                                            let _e6775 = scale_6;
                                                            invScaleRatio_6 = (_e6774 / _e6775);
                                                            let _e6778 = invScaleRatio_6;
                                                            let _e6782 = invScaleRatio_6;
                                                            let _e6791 = currentTransform_5;
                                                            tr_6 = (mat3x3<f32>(vec3<f32>(_e6778, 0f, 0f), vec3<f32>(0f, _e6782, 0f), vec3<f32>(0f, 0f, 1f)) * _e6791);
                                                            let _e6794 = tr_6;
                                                            let _e6795 = _uv_5;
                                                            let _e6796 = tf(_e6794, _e6795);
                                                            v_6 = (_e6796 - vec2(0.5f));
                                                            let _e6800 = v_6;
                                                            let _e6801 = w_14;
                                                            pixId_7 = floor((_e6800 * _e6801));
                                                            let _e6805 = pixId_7;
                                                            let _e6807 = pixId_7;
                                                            let _e6809 = (_e6805.x + _e6807.y);
                                                            k_25 = (_e6809 - (floor((_e6809 / 2f)) * 2f));
                                                            let _e6816 = k_25;
                                                            let _e6817 = vec3(_e6816);
                                                            outCol = vec4<f32>(_e6817.x, _e6817.y, _e6817.z, 1f);
                                                        }
                                                    } else {
                                                        let _e6823 = mode_5;
                                                        if (_e6823 == 8i) {
                                                            {
                                                                let _e6828 = startScale_7;
                                                                scale2_7 = (_e6828 * 4f);
                                                                let _e6832 = scale2_7;
                                                                let _e6833 = scale_6;
                                                                invScaleRatio_7 = (_e6832 / _e6833);
                                                                let _e6836 = invScaleRatio_7;
                                                                let _e6840 = invScaleRatio_7;
                                                                let _e6849 = currentTransform_5;
                                                                tr_7 = (mat3x3<f32>(vec3<f32>(_e6836, 0f, 0f), vec3<f32>(0f, _e6840, 0f), vec3<f32>(0f, 0f, 1f)) * _e6849);
                                                                let _e6852 = tr_7;
                                                                let _e6853 = _uv_5;
                                                                let _e6854 = tf(_e6852, _e6853);
                                                                v_6 = (_e6854 - vec2(0.5f));
                                                                let _e6864 = inverseTileTransform_3[0];
                                                                let _e6868 = inverseTileTransform_3[0];
                                                                let _e6871 = piN_3;
                                                                let _e6874 = piN_3;
                                                                ang_24 = (floor((atan2(_e6864.y, _e6868.x) / _e6871)) * _e6874);
                                                                let _e6877 = ang_24;
                                                                let _e6878 = rotation2_(_e6877);
                                                                let _e6879 = v_6;
                                                                let _e6883 = inverseTileTransform_3[0];
                                                                let _e6890 = inverseTileTransform_3[2];
                                                                v_6 = (((_e6878 * _e6879) * length(_e6883.xy)) + (2f * _e6890.xy));
                                                                let _e6894 = v_6;
                                                                let _e6896 = v_6;
                                                                let _e6898 = rnd_5;
                                                                let _e6905 = Xn_3;
                                                                let _e6907 = floor(((_e6894.x + (_e6896.y * sign((_e6898.y - 0.5f)))) * _e6905));
                                                                k_26 = (_e6907 - (floor((_e6907 / 2f)) * 2f));
                                                                let _e6914 = k_26;
                                                                let _e6915 = vec3(_e6914);
                                                                outCol = vec4<f32>(_e6915.x, _e6915.y, _e6915.z, 1f);
                                                            }
                                                        } else {
                                                            let _e6921 = mode_5;
                                                            if (_e6921 == 9i) {
                                                                {
                                                                    let _e6928 = inverseTileTransform_3[2];
                                                                    N_16 = floor((1000f * pow(0.25f, length(_e6928.xy))));
                                                                    let _e6939 = N_16;
                                                                    let _e6944 = inverseTileTransform_3[1];
                                                                    let _e6948 = inverseTileTransform_3[1];
                                                                    offset_3 = ((1.5707964f + (3.1415927f / _e6939)) + atan2(_e6944.y, _e6948.x));
                                                                    let _e6953 = v_6;
                                                                    let _e6955 = v_6;
                                                                    ang_25 = atan2(_e6953.y, _e6955.x);
                                                                    let _e6959 = ang_25;
                                                                    let _e6960 = offset_3;
                                                                    let _e6964 = N_16;
                                                                    let _e6967 = N_16;
                                                                    let _e6971 = offset_3;
                                                                    ang_25 = (((round((((_e6959 - _e6960) / 6.2831855f) * _e6964)) / _e6967) * 6.2831855f) + _e6971);
                                                                    let _e6975 = inverseTileTransform_3[0];
                                                                    let _e6980 = ang_25;
                                                                    let _e6983 = ang_25;
                                                                    dist_6 = ((length(_e6975.xy) * 0.5f) / max(abs(cos(_e6980)), abs(sin(_e6983))));
                                                                    let _e6989 = dist_6;
                                                                    let _e6990 = ang_25;
                                                                    let _e6992 = ang_25;
                                                                    v_6 = (_e6989 * vec2<f32>(cos(_e6990), sin(_e6992)));
                                                                    let _e6996 = inverseCurrentTransform_5;
                                                                    let _e6997 = relId_5;
                                                                    let _e6998 = v_6;
                                                                    let _e7003 = tf(_e6996, (_e6997 + (_e6998 + vec2(0.5f))));
                                                                    u_9 = _e7003;
                                                                    let _e7005 = u_9;
                                                                    let _e7009 = global.U[0];
                                                                    let _e7012 = u_9;
                                                                    let _e7021 = _mirror_wrap(((vec2<f32>((_e7005.x / _e7009.x), _e7012.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e7022 = textureSample(t_source, samp, _e7021);
                                                                    outCol = _e7022;
                                                                }
                                                            } else {
                                                                let _e7023 = mode_5;
                                                                if (_e7023 == 10i) {
                                                                    {
                                                                        let _e7028 = inverseTileTransform_3[0];
                                                                        s_7 = (length(_e7028.xy) * 0.05f);
                                                                        let _e7034 = v_6;
                                                                        v_6 = (_e7034 + vec2(0.5f));
                                                                        let _e7042 = inverseTileTransform_3[0];
                                                                        let _e7046 = inverseTileTransform_3[0];
                                                                        let _e7051 = N_17;
                                                                        let _e7056 = N_17;
                                                                        ang_26 = ((floor(((atan2(_e7042.y, _e7046.x) / 3.1415927f) * _e7051)) * 3.1415927f) / _e7056);
                                                                        let _e7059 = ang_26;
                                                                        let _e7060 = rotation2_(_e7059);
                                                                        let _e7061 = v_6;
                                                                        v_6 = (_e7060 * _e7061);
                                                                        let _e7063 = v_6;
                                                                        let _e7067 = inverseTileTransform_3[2];
                                                                        let _e7071 = tileTransform_3[0];
                                                                        let _e7079 = v_6;
                                                                        let _e7083 = inverseTileTransform_3[2];
                                                                        let _e7087 = tileTransform_3[0];
                                                                        let _e7094 = hslToRgb(vec4<f32>(((_e7063.x + (_e7067.x * length(_e7071.xy))) * 360f), 1f, (_e7079.y + (_e7083.y * length(_e7087.xy))), 1f));
                                                                        rgb_3 = _e7094;
                                                                        let _e7096 = _uv_5;
                                                                        let _e7100 = global.U[0];
                                                                        let _e7103 = _uv_5;
                                                                        let _e7112 = _mirror_wrap(((vec2<f32>((_e7096.x / _e7100.x), _e7103.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e7113 = textureSample(t_source, samp, _e7112);
                                                                        inc_5 = _e7113;
                                                                        let _e7115 = inc_5;
                                                                        let _e7117 = rgb_3;
                                                                        dist_7 = length((_e7115.xyz - _e7117.xyz));
                                                                        let _e7125 = dist_7;
                                                                        let _e7127 = s_7;
                                                                        k_27 = (1f - (smoothstep(0f, 1.7f, _e7125) * _e7127));
                                                                        let _e7131 = inc_5;
                                                                        let _e7132 = rgb_3;
                                                                        let _e7133 = k_27;
                                                                        rgb_3 = mix(_e7131, _e7132, vec4(_e7133));
                                                                        let _e7136 = rgb_3;
                                                                        outCol = _e7136;
                                                                    }
                                                                } else {
                                                                    let _e7137 = mode_5;
                                                                    if (_e7137 == 11i) {
                                                                        {
                                                                            let _e7143 = inverseTileTransform_3[0];
                                                                            N_18 = round((4f * abs(_e7143.x)));
                                                                            let _e7150 = v_6;
                                                                            let _e7154 = N_18;
                                                                            let _e7157 = N_18;
                                                                            let _e7164 = N_18;
                                                                            center_14 = (vec2<f32>(0f, ((((floor(((_e7150.y + 0.5f) * _e7154)) / _e7157) * 2f) - 1f) + (1f / _e7164))) * 0.5f);
                                                                            let _e7171 = v_6;
                                                                            let _e7172 = center_14;
                                                                            dv_6 = abs((_e7171 - _e7172));
                                                                            let _e7176 = dv_6;
                                                                            let _e7180 = dv_6;
                                                                            let _e7183 = N_18;
                                                                            if ((_e7176.x < 0.45f) && (_e7180.y < (0.4f / _e7183))) {
                                                                                {
                                                                                    let _e7189 = inverseTileTransform_3[2];
                                                                                    s_8 = (_e7189.x + 1f);
                                                                                    let _e7194 = inverseCurrentTransform_5;
                                                                                    let _e7195 = relId_5;
                                                                                    let _e7196 = s_8;
                                                                                    let _e7206 = tf(_e7194, (_e7195 + ((_e7196 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_14 = _e7206;
                                                                                    let _e7208 = inverseCurrentTransform_5;
                                                                                    let _e7209 = relId_5;
                                                                                    let _e7210 = s_8;
                                                                                    let _e7219 = tf(_e7208, (_e7209 + ((_e7210 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_14 = _e7219;
                                                                                    let _e7221 = u1_14;
                                                                                    let _e7225 = global.U[0];
                                                                                    let _e7228 = u1_14;
                                                                                    let _e7237 = _mirror_wrap(((vec2<f32>((_e7221.x / _e7225.x), _e7228.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7238 = textureSample(t_source, samp, _e7237);
                                                                                    let _e7239 = u2_14;
                                                                                    let _e7243 = global.U[0];
                                                                                    let _e7246 = u2_14;
                                                                                    let _e7255 = _mirror_wrap(((vec2<f32>((_e7239.x / _e7243.x), _e7246.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7256 = textureSample(t_source, samp, _e7255);
                                                                                    let _e7257 = center_14;
                                                                                    outCol = mix(_e7238, _e7256, vec4((_e7257.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e7263 = mode_5;
                                                                        if (_e7263 == 12i) {
                                                                            {
                                                                                let _e7266 = v_6;
                                                                                v_6 = (_e7266 * vec2<f32>(2f, 2f));
                                                                                let _e7271 = inverseTileTransform_3;
                                                                                let _e7272 = v_6;
                                                                                let _e7273 = tf(_e7271, _e7272);
                                                                                v_6 = _e7273;
                                                                                let _e7274 = inverseCurrentTransform_5;
                                                                                let _e7275 = relId_5;
                                                                                let _e7276 = v_6;
                                                                                let _e7281 = tf(_e7274, (_e7275 + (_e7276 + vec2(0.5f))));
                                                                                let _e7285 = global.U[0];
                                                                                let _e7288 = inverseCurrentTransform_5;
                                                                                let _e7289 = relId_5;
                                                                                let _e7290 = v_6;
                                                                                let _e7295 = tf(_e7288, (_e7289 + (_e7290 + vec2(0.5f))));
                                                                                let _e7304 = _mirror_wrap(((vec2<f32>((_e7281.x / _e7285.x), _e7295.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e7305 = textureSample(t_source, samp, _e7304);
                                                                                outCol = _e7305;
                                                                            }
                                                                        } else {
                                                                            let _e7306 = mode_5;
                                                                            if (_e7306 == 13i) {
                                                                                {
                                                                                    let _e7309 = _uv_5;
                                                                                    let _e7313 = global.U[0];
                                                                                    let _e7316 = _uv_5;
                                                                                    let _e7325 = _mirror_wrap(((vec2<f32>((_e7309.x / _e7313.x), _e7316.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e7326 = textureSample(t_source, samp, _e7325);
                                                                                    let _e7328 = luma(_e7326.xyz);
                                                                                    lum_9 = _e7328;
                                                                                    let _e7330 = inverseTileTransform_3;
                                                                                    let _e7331 = v_6;
                                                                                    let _e7336 = tf(_e7330, (_e7331 * vec2<f32>(8f, 8f)));
                                                                                    v_6 = _e7336;
                                                                                    let _e7337 = v_6;
                                                                                    let _e7340 = (_e7337.y + 1f);
                                                                                    y_3 = abs(((_e7340 - (floor((_e7340 / 2f)) * 2f)) - 1f));
                                                                                    let _e7350 = lum_9;
                                                                                    let _e7351 = y_3;
                                                                                    if (_e7350 > _e7351) {
                                                                                        local_29 = 1f;
                                                                                    } else {
                                                                                        local_29 = 0f;
                                                                                    }
                                                                                    let _e7356 = local_29;
                                                                                    k_28 = _e7356;
                                                                                    let _e7358 = k_28;
                                                                                    let _e7359 = vec3(_e7358);
                                                                                    outCol = vec4<f32>(_e7359.x, _e7359.y, _e7359.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e7365 = mode_5;
                                                                                if (_e7365 == 14i) {
                                                                                    {
                                                                                        let _e7368 = id_3;
                                                                                        let _e7372 = global.U[0];
                                                                                        let _e7375 = id_3;
                                                                                        let _e7384 = _mirror_wrap(((vec2<f32>((_e7368.x / _e7372.x), _e7375.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e7385 = textureSample(t_source, samp, _e7384);
                                                                                        let _e7387 = luma(_e7385.xyz);
                                                                                        lum_10 = _e7387;
                                                                                        let _e7391 = tileTransform_3[0];
                                                                                        contrast_3 = length(_e7391.xy);
                                                                                        let _e7395 = v_6;
                                                                                        let _e7398 = (_e7395 + vec2(0.5f));
                                                                                        let _e7400 = contrast_3;
                                                                                        let _e7401 = lum_10;
                                                                                        outCol = vec4<f32>(_e7398.x, _e7398.y, (0.5f + (_e7400 * (_e7401 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e7410 = mode_5;
                                                                                    if (_e7410 == 15i) {
                                                                                        {
                                                                                            let _e7413 = rnd_5;
                                                                                            center_15 = (sign((_e7413 - vec2(0.5f))) * 0.5f);
                                                                                            let _e7421 = v_6;
                                                                                            let _e7422 = center_15;
                                                                                            dv_7 = (_e7421 - _e7422);
                                                                                            let _e7428 = inverseTileTransform_3[0];
                                                                                            N_19 = floor((16f * length(_e7428.xy)));
                                                                                            let _e7436 = dv_7;
                                                                                            let _e7438 = dv_7;
                                                                                            let _e7441 = angOffset_3;
                                                                                            ang_27 = (atan2(_e7436.y, _e7438.x) + _e7441);
                                                                                            let _e7444 = ang_27;
                                                                                            let _e7447 = N_19;
                                                                                            let _e7450 = (((_e7444 / 3.1415927f) * _e7447) * 2f);
                                                                                            k_29 = abs(((_e7450 - (floor((_e7450 / 2f)) * 2f)) - 1f));
                                                                                            let _e7462 = inverseTileTransform_3[0];
                                                                                            let _e7466 = inverseTileTransform_3[0];
                                                                                            kCol_3 = (atan2(_e7462.y, _e7466.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e7476 = i_11;
                                                                                                if !((_e7476 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e7483 = inverseCurrentTransform_5;
                                                                                                    let _e7484 = relId_5;
                                                                                                    let _e7487 = i_11;
                                                                                                    let _e7491 = ang_27;
                                                                                                    let _e7493 = ang_27;
                                                                                                    let _e7498 = tf(_e7483, (_e7484 + ((0.1f + (0.15f * f32(_e7487))) * vec2<f32>(cos(_e7491), sin(_e7493)))));
                                                                                                    w_15 = _e7498;
                                                                                                    let _e7500 = lum_11;
                                                                                                    let _e7501 = w_15;
                                                                                                    let _e7505 = global.U[0];
                                                                                                    let _e7508 = w_15;
                                                                                                    let _e7517 = _mirror_wrap(((vec2<f32>((_e7501.x / _e7505.x), _e7508.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7518 = textureSample(t_source, samp, _e7517);
                                                                                                    let _e7520 = luma(_e7518.xyz);
                                                                                                    lum_11 = (_e7500 + _e7520);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e7480 = i_11;
                                                                                                    i_11 = (_e7480 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e7522 = lum_11;
                                                                                            lum_11 = (_e7522 / 5f);
                                                                                            let _e7525 = lum_11;
                                                                                            let _e7526 = k_29;
                                                                                            if (_e7525 > _e7526) {
                                                                                                local_30 = 1f;
                                                                                            } else {
                                                                                                local_30 = 0f;
                                                                                            }
                                                                                            let _e7531 = local_30;
                                                                                            k_29 = _e7531;
                                                                                            let _e7532 = kCol_3;
                                                                                            if (_e7532 == 0f) {
                                                                                                {
                                                                                                    let _e7535 = k_29;
                                                                                                    let _e7536 = vec3(_e7535);
                                                                                                    outCol = vec4<f32>(_e7536.x, _e7536.y, _e7536.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e7544 = inverseTileTransform_3[2];
                                                                                                    u1_15 = vec2<f32>(_e7544.x, 0f);
                                                                                                    let _e7552 = inverseTileTransform_3[2];
                                                                                                    u2_15 = vec2<f32>(0f, _e7552.y);
                                                                                                    let _e7556 = kCol_3;
                                                                                                    if (_e7556 > 0f) {
                                                                                                        {
                                                                                                            let _e7559 = u1_15;
                                                                                                            let _e7560 = id_3;
                                                                                                            u1_15 = (_e7559 + _e7560);
                                                                                                            let _e7562 = u2_15;
                                                                                                            let _e7563 = id_3;
                                                                                                            u2_15 = (_e7562 + (_e7563 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e7568 = u1_15;
                                                                                                    let _e7572 = global.U[0];
                                                                                                    let _e7575 = u1_15;
                                                                                                    let _e7584 = _mirror_wrap(((vec2<f32>((_e7568.x / _e7572.x), _e7575.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7585 = textureSample(t_source, samp, _e7584);
                                                                                                    col1_12 = _e7585;
                                                                                                    let _e7587 = u2_15;
                                                                                                    let _e7591 = global.U[0];
                                                                                                    let _e7594 = u2_15;
                                                                                                    let _e7603 = _mirror_wrap(((vec2<f32>((_e7587.x / _e7591.x), _e7594.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e7604 = textureSample(t_source, samp, _e7603);
                                                                                                    col2_12 = _e7604;
                                                                                                    let _e7606 = col1_12;
                                                                                                    let _e7608 = luma(_e7606.xyz);
                                                                                                    let _e7609 = col2_12;
                                                                                                    let _e7611 = luma(_e7609.xyz);
                                                                                                    if (_e7608 > _e7611) {
                                                                                                        let _e7614 = k_29;
                                                                                                        k_29 = (1f - _e7614);
                                                                                                    }
                                                                                                    let _e7616 = k_29;
                                                                                                    let _e7617 = vec3(_e7616);
                                                                                                    outCol1_3 = vec4<f32>(_e7617.x, _e7617.y, _e7617.z, 1f);
                                                                                                    let _e7624 = col1_12;
                                                                                                    let _e7625 = col2_12;
                                                                                                    let _e7626 = k_29;
                                                                                                    outCol2_3 = mix(_e7624, _e7625, vec4(_e7626));
                                                                                                    let _e7630 = outCol1_3;
                                                                                                    let _e7631 = outCol2_3;
                                                                                                    let _e7632 = kCol_3;
                                                                                                    outCol = mix(_e7630, _e7631, vec4(abs(_e7632)));
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
                let _e7636 = src1_1;
                let _e7637 = outCol;
                let _e7638 = mergeColor(_e7636, _e7637);
                col1_13 = _e7638;
                {
                    let _e7640 = uu2_1;
                    _uv_6 = _e7640;
                    let _e7642 = _params_1;
                    startScale_8 = _e7642.startScale;
                    let _e7645 = _params_1;
                    subLevels_6 = _e7645.subLevels;
                    let _e7648 = _params_1;
                    subThreshold_6 = _e7648.subThreshold;
                    let _e7651 = _params_1;
                    seed_6 = _e7651.seed;
                    let _e7654 = _params_1;
                    hashStyle_8 = _e7654.hashStyle;
                    let _e7657 = _params_1;
                    coverage_6 = _e7657.coverage;
                    let _e7660 = _params_1;
                    currentTransform_6 = _e7660.transform;
                    let _e7663 = _params_1;
                    inverseCurrentTransform_6 = _e7663.inverseTransform;
                    let _e7666 = startScale_8;
                    scale_8 = _e7666;
                    loop {
                        let _e7674 = i_12;
                        let _e7675 = subLevels_6;
                        if !((_e7674 < _e7675)) {
                            break;
                        }
                        {
                            let _e7681 = i_12;
                            if (_e7681 != 0f) {
                                {
                                    let _e7697 = currentTransform_6;
                                    currentTransform_6 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e7697);
                                    let _e7699 = inverseCurrentTransform_6;
                                    inverseCurrentTransform_6 = (_e7699 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e7714 = currentTransform_6;
                            let _e7715 = _uv_6;
                            let _e7716 = tf(_e7714, _e7715);
                            relId_6 = floor(_e7716);
                            let _e7718 = relId_6;
                            let _e7720 = (_e7718 * 0.13137f);
                            let _e7721 = i_12;
                            let _e7722 = seed_6;
                            let _e7726 = hashStyle_8;
                            let _e7727 = hash42sp(vec4<f32>(_e7720.x, _e7720.y, _e7721, _e7722), _e7726);
                            rnd_6 = _e7727;
                            let _e7728 = i_12;
                            let _e7729 = subLevels_6;
                            let _e7733 = rnd_6;
                            let _e7735 = subThreshold_6;
                            if ((_e7728 == (_e7729 - 1f)) || (_e7733.x > _e7735)) {
                                {
                                    break;
                                }
                            }
                            let _e7738 = scale_8;
                            scale_8 = (_e7738 * 2f);
                        }
                        continuing {
                            let _e7678 = i_12;
                            i_12 = (_e7678 + 1f);
                        }
                    }
                    let _e7741 = inverseCurrentTransform_6;
                    let _e7742 = relId_6;
                    let _e7743 = tf(_e7741, _e7742);
                    id_4 = _e7743;
                    let _e7745 = rnd_6;
                    modeIndex_4 = i32(floor((_e7745.y * 4f)));
                    let _e7752 = modeIndex_4;
                    let _e7755 = _params_1.modeMap[_e7752];
                    mode_6 = _e7755;
                    let _e7758 = modeIndex_4;
                    if (_e7758 == 0i) {
                        let _e7761 = tileTransform1_1;
                        tileTransform_4 = _e7761;
                    } else {
                        let _e7762 = modeIndex_4;
                        if (_e7762 == 1i) {
                            let _e7765 = tileTransform2_1;
                            tileTransform_4 = _e7765;
                        } else {
                            let _e7766 = modeIndex_4;
                            if (_e7766 == 2i) {
                                let _e7769 = tileTransform3_1;
                                tileTransform_4 = _e7769;
                            } else {
                                let _e7770 = tileTransform4_1;
                                tileTransform_4 = _e7770;
                            }
                        }
                    }
                    let _e7771 = tileTransform_4;
                    inverseTileTransform_4 = _naga_inverse_3x3_f32(_e7771);
                    let _e7774 = currentTransform_6;
                    let _e7775 = _uv_6;
                    let _e7776 = tf(_e7774, _e7775);
                    let _e7777 = relId_6;
                    v_7 = ((_e7776 - _e7777) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e7784 = rnd_6;
                    let _e7788 = rnd_6;
                    let _e7794 = coverage_6;
                    if (fract(((_e7784.x * 6.222f) + (_e7788.y * 8.233f))) <= _e7794) {
                        {
                            let _e7796 = mode_6;
                            if (_e7796 == 0i) {
                                {
                                    let _e7801 = inverseTileTransform_4[0];
                                    w_16 = _e7801.xy;
                                    let _e7804 = w_16;
                                    let _e7808 = w_16;
                                    w_16 = floor(vec2<f32>(dot(_e7804, vec2(20f)), dot(_e7808, vec2<f32>(20f, -20f))));
                                    let _e7816 = relId_6;
                                    let _e7818 = v_7;
                                    let _e7819 = w_16;
                                    let _e7824 = tileTransform_4[0];
                                    let _e7831 = inverseTileTransform_4[2];
                                    let _e7834 = w_16;
                                    pixId_8 = (_e7816 + (1.23f * (floor((_e7818 * _e7819)) + floor((((length(_e7824.xy) * 5f) * _e7831.xy) * _e7834)))));
                                    let _e7841 = pixId_8;
                                    let _e7842 = hash22_(_e7841);
                                    let _e7846 = global.U[0];
                                    let _e7849 = pixId_8;
                                    let _e7850 = hash22_(_e7849);
                                    let _e7859 = _mirror_wrap(((vec2<f32>((_e7842.x / _e7846.x), _e7850.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e7860 = textureSample(t_source, samp, _e7859);
                                    outCol = _e7860;
                                }
                            } else {
                                let _e7861 = mode_6;
                                if (_e7861 == 1i) {
                                    {
                                        let _e7865 = v_7;
                                        let _e7868 = v_7;
                                        v_7 = vec2<f32>(0f, max(abs(_e7865.x), abs(_e7868.y)));
                                        let _e7873 = inverseCurrentTransform_6;
                                        let _e7874 = relId_6;
                                        let _e7875 = inverseTileTransform_4;
                                        let _e7876 = v_7;
                                        let _e7877 = tf(_e7875, _e7876);
                                        let _e7882 = tf(_e7873, (_e7874 + (_e7877 + vec2(0.5f))));
                                        vv_8 = _e7882;
                                        let _e7884 = vv_8;
                                        let _e7888 = global.U[0];
                                        let _e7891 = vv_8;
                                        let _e7900 = _mirror_wrap(((vec2<f32>((_e7884.x / _e7888.x), _e7891.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e7901 = textureSample(t_source, samp, _e7900);
                                        outCol = _e7901;
                                    }
                                } else {
                                    let _e7902 = mode_6;
                                    if (_e7902 == 2i) {
                                        {
                                            let _e7908 = inverseTileTransform_4[2];
                                            size_12 = (0.5f + _e7908.y);
                                            let _e7912 = v_7;
                                            d_8 = length(_e7912);
                                            let _e7915 = v_7;
                                            let _e7917 = v_7;
                                            ang_28 = atan2(_e7915.y, _e7917.x);
                                            let _e7921 = d_8;
                                            let _e7922 = size_12;
                                            if (_e7921 <= _e7922) {
                                                {
                                                    let _e7927 = spikeCount_4;
                                                    anglePeriod_4 = (6.2831855f / _e7927);
                                                    let _e7930 = ang_28;
                                                    let _e7931 = anglePeriod_4;
                                                    let _e7934 = anglePeriod_4;
                                                    a1_4 = (floor((_e7930 / _e7931)) * _e7934);
                                                    let _e7937 = a1_4;
                                                    let _e7938 = anglePeriod_4;
                                                    a2_4 = (_e7937 + _e7938);
                                                    let _e7941 = ang_28;
                                                    let _e7942 = a1_4;
                                                    let _e7944 = anglePeriod_4;
                                                    k_30 = ((_e7941 - _e7942) / _e7944);
                                                    let _e7947 = d_8;
                                                    let _e7952 = inverseTileTransform_4[0];
                                                    ds_8 = ((_e7947 * 10f) * length(_e7952.xy));
                                                    let _e7957 = relId_6;
                                                    center_16 = (_e7957 + vec2(0.5f));
                                                    let _e7962 = inverseCurrentTransform_6;
                                                    let _e7963 = center_16;
                                                    let _e7964 = ds_8;
                                                    let _e7965 = a1_4;
                                                    let _e7967 = a1_4;
                                                    let _e7974 = inverseTileTransform_4[2];
                                                    let _e7978 = tf(_e7962, ((_e7963 + (_e7964 * vec2<f32>(cos(_e7965), sin(_e7967)))) + vec2(_e7974.x)));
                                                    u1_16 = _e7978;
                                                    let _e7980 = inverseCurrentTransform_6;
                                                    let _e7981 = center_16;
                                                    let _e7982 = ds_8;
                                                    let _e7983 = a2_4;
                                                    let _e7985 = a2_4;
                                                    let _e7992 = inverseTileTransform_4[2];
                                                    let _e7996 = tf(_e7980, ((_e7981 + (_e7982 * vec2<f32>(cos(_e7983), sin(_e7985)))) + vec2(_e7992.x)));
                                                    u2_16 = _e7996;
                                                    let _e7998 = u1_16;
                                                    let _e8002 = global.U[0];
                                                    let _e8005 = u1_16;
                                                    let _e8014 = _mirror_wrap(((vec2<f32>((_e7998.x / _e8002.x), _e8005.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e8015 = textureSample(t_source, samp, _e8014);
                                                    col1_14 = _e8015;
                                                    let _e8017 = u2_16;
                                                    let _e8021 = global.U[0];
                                                    let _e8024 = u2_16;
                                                    let _e8033 = _mirror_wrap(((vec2<f32>((_e8017.x / _e8021.x), _e8024.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e8034 = textureSample(t_source, samp, _e8033);
                                                    col2_13 = _e8034;
                                                    let _e8036 = col1_14;
                                                    let _e8037 = col2_13;
                                                    let _e8038 = k_30;
                                                    outCol = mix(_e8036, _e8037, vec4(_e8038));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e8041 = mode_6;
                                        if (_e8041 == 3i) {
                                            {
                                                let _e8044 = v_7;
                                                let _e8047 = v_7;
                                                vert_4 = (abs(_e8044.y) > abs(_e8047.x));
                                                let _e8052 = vert_4;
                                                if _e8052 {
                                                    let _e8053 = v_7;
                                                    local_31 = _e8053.y;
                                                } else {
                                                    let _e8055 = v_7;
                                                    local_31 = _e8055.x;
                                                }
                                                let _e8058 = local_31;
                                                a_4 = _e8058;
                                                let _e8060 = vert_4;
                                                if _e8060 {
                                                    let _e8061 = a_4;
                                                    let _e8063 = a_4;
                                                    local_32 = vec2<f32>(-(_e8061), _e8063);
                                                } else {
                                                    let _e8065 = a_4;
                                                    let _e8066 = a_4;
                                                    local_32 = vec2<f32>(_e8065, -(_e8066));
                                                }
                                                let _e8070 = local_32;
                                                u1_17 = _e8070;
                                                let _e8072 = a_4;
                                                let _e8073 = a_4;
                                                u2_17 = vec2<f32>(_e8072, _e8073);
                                                let _e8076 = v_7;
                                                let _e8078 = v_7;
                                                let _e8082 = a_4;
                                                k_31 = ((_e8076.x + _e8078.y) / (2f * _e8082));
                                                let _e8086 = inverseCurrentTransform_6;
                                                let _e8087 = relId_6;
                                                let _e8088 = inverseTileTransform_4;
                                                let _e8089 = u1_17;
                                                let _e8090 = tf(_e8088, _e8089);
                                                let _e8095 = tf(_e8086, (_e8087 + (_e8090 + vec2(0.5f))));
                                                u1_17 = _e8095;
                                                let _e8096 = inverseCurrentTransform_6;
                                                let _e8097 = relId_6;
                                                let _e8098 = inverseTileTransform_4;
                                                let _e8099 = u2_17;
                                                let _e8100 = tf(_e8098, _e8099);
                                                let _e8105 = tf(_e8096, (_e8097 + (_e8100 + vec2(0.5f))));
                                                u2_17 = _e8105;
                                                let _e8106 = u1_17;
                                                let _e8110 = global.U[0];
                                                let _e8113 = u1_17;
                                                let _e8122 = _mirror_wrap(((vec2<f32>((_e8106.x / _e8110.x), _e8113.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e8123 = textureSample(t_source, samp, _e8122);
                                                col1_15 = _e8123;
                                                let _e8125 = u2_17;
                                                let _e8129 = global.U[0];
                                                let _e8132 = u2_17;
                                                let _e8141 = _mirror_wrap(((vec2<f32>((_e8125.x / _e8129.x), _e8132.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e8142 = textureSample(t_source, samp, _e8141);
                                                col2_14 = _e8142;
                                                let _e8144 = col1_15;
                                                let _e8145 = col2_14;
                                                let _e8146 = k_31;
                                                outCol = mix(_e8144, _e8145, vec4(_e8146));
                                            }
                                        } else {
                                            let _e8149 = mode_6;
                                            if (_e8149 == 4i) {
                                                {
                                                    let _e8156 = inverseTileTransform_4[0];
                                                    let _e8160 = inverseTileTransform_4[0];
                                                    ang_29 = atan2(_e8156.y, _e8160.x);
                                                    let _e8164 = ang_29;
                                                    if (_e8164 < 0f) {
                                                        let _e8167 = relId_6;
                                                        let _e8169 = relId_6;
                                                        let _e8171 = (_e8167.x + _e8169.y);
                                                        local_33 = sign(((_e8171 - (floor((_e8171 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_33 = 1f;
                                                    }
                                                    let _e8182 = local_33;
                                                    orientation_4 = _e8182;
                                                    let _e8184 = rnd_6;
                                                    let _e8186 = ang_29;
                                                    if (_e8184.y > (abs(_e8186) / 3.1415927f)) {
                                                        let _e8191 = orientation_4;
                                                        orientation_4 = -(_e8191);
                                                    }
                                                    let _e8193 = orientation_4;
                                                    let _e8194 = v_7;
                                                    let _e8197 = v_7;
                                                    if (((_e8193 * _e8194.x) * _e8197.y) < 0f) {
                                                        local_34 = 40f;
                                                    } else {
                                                        local_34 = 2.5f;
                                                    }
                                                    let _e8205 = local_34;
                                                    p_9 = _e8205;
                                                    let _e8207 = p_9;
                                                    if (_e8207 > 30f) {
                                                        let _e8210 = v_7;
                                                        let _e8213 = v_7;
                                                        local_35 = max(abs(_e8210.x), abs(_e8213.y));
                                                    } else {
                                                        let _e8217 = v_7;
                                                        let _e8220 = p_9;
                                                        let _e8222 = v_7;
                                                        let _e8225 = p_9;
                                                        let _e8229 = p_9;
                                                        local_35 = pow((pow(abs(_e8217.x), _e8220) + pow(abs(_e8222.y), _e8225)), (1f / _e8229));
                                                    }
                                                    let _e8233 = local_35;
                                                    d_9 = _e8233;
                                                    let _e8236 = d_9;
                                                    v_7 = vec2<f32>(0f, _e8236);
                                                    let _e8238 = v_7;
                                                    let _e8240 = size_13;
                                                    if (_e8238.y <= _e8240) {
                                                        {
                                                            let _e8242 = inverseCurrentTransform_6;
                                                            let _e8243 = relId_6;
                                                            let _e8244 = inverseTileTransform_4;
                                                            let _e8245 = v_7;
                                                            let _e8246 = tf(_e8244, _e8245);
                                                            let _e8251 = tf(_e8242, (_e8243 + (_e8246 + vec2(0.5f))));
                                                            vv_9 = _e8251;
                                                            let _e8253 = vv_9;
                                                            let _e8257 = global.U[0];
                                                            let _e8260 = vv_9;
                                                            let _e8269 = _mirror_wrap(((vec2<f32>((_e8253.x / _e8257.x), _e8260.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e8270 = textureSample(t_source, samp, _e8269);
                                                            outCol = _e8270;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e8271 = mode_6;
                                                if (_e8271 <= 6i) {
                                                    {
                                                        let _e8276 = inverseTileTransform_4[0];
                                                        scale_9 = length(_e8276.xy);
                                                        let _e8280 = scale_9;
                                                        invert_4 = (_e8280 < 1f);
                                                        let _e8284 = invert_4;
                                                        if _e8284 {
                                                            let _e8286 = scale_9;
                                                            scale_9 = (1f / _e8286);
                                                        }
                                                        let _e8288 = scale_9;
                                                        ds_9 = fract(_e8288);
                                                        let _e8291 = scale_9;
                                                        N_20 = max(floor(_e8291), 1f);
                                                        let _e8296 = v_7;
                                                        let _e8300 = N_20;
                                                        w_17 = (fract(((_e8296 + vec2(0.5f)) * _e8300)) - vec2(0.5f));
                                                        let _e8307 = v_7;
                                                        let _e8311 = N_20;
                                                        let _e8314 = N_20;
                                                        let _e8323 = N_20;
                                                        center_17 = ((((floor(((_e8307 + vec2(0.5f)) * _e8311)) / vec2(_e8314)) * 2f) - vec2(1f)) + vec2((1f / _e8323)));
                                                        let _e8330 = inverseTileTransform_4[0];
                                                        let _e8334 = inverseTileTransform_4[0];
                                                        ang_30 = atan2(_e8330.y, _e8334.x);
                                                        let _e8342 = ang_30;
                                                        if (_e8342 > 0f) {
                                                            let _e8346 = ang_30;
                                                            keepX_4 = (1f - (_e8346 / 3.1415927f));
                                                        } else {
                                                            let _e8351 = ang_30;
                                                            keepY_4 = (1f + (_e8351 / 3.1415927f));
                                                        }
                                                        let _e8355 = center_17;
                                                        let _e8358 = keepX_4;
                                                        let _e8360 = center_17;
                                                        let _e8363 = keepY_4;
                                                        hide_4 = ((abs(_e8355.x) > _e8358) || (abs(_e8360.y) > _e8363));
                                                        let _e8369 = ds_9;
                                                        size_14 = mix(0.5f, 0.15f, _e8369);
                                                        let _e8372 = mode_6;
                                                        let _e8375 = w_17;
                                                        let _e8377 = size_14;
                                                        let _e8380 = mode_6;
                                                        let _e8383 = w_17;
                                                        let _e8386 = size_14;
                                                        let _e8388 = w_17;
                                                        let _e8391 = size_14;
                                                        outside_4 = (((_e8372 == 6i) && (length(_e8375) > _e8377)) || ((_e8380 == 5i) && ((abs(_e8383.x) > _e8386) || (abs(_e8388.y) > _e8391))));
                                                        let _e8397 = hide_4;
                                                        let _e8398 = outside_4;
                                                        if !((_e8397 || _e8398)) {
                                                            {
                                                                let _e8401 = id_4;
                                                                let _e8404 = inverseTileTransform_4[2];
                                                                let _e8410 = global.U[0];
                                                                let _e8413 = id_4;
                                                                let _e8416 = inverseTileTransform_4[2];
                                                                let _e8427 = _mirror_wrap(((vec2<f32>(((_e8401 + _e8404.xy).x / _e8410.x), (_e8413 + _e8416.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e8428 = textureSample(t_source, samp, _e8427);
                                                                outCol = _e8428;
                                                            }
                                                        } else {
                                                            let _e8429 = invert_4;
                                                            if _e8429 {
                                                                {
                                                                    let _e8430 = id_4;
                                                                    let _e8434 = global.U[0];
                                                                    let _e8437 = id_4;
                                                                    let _e8446 = _mirror_wrap(((vec2<f32>((_e8430.x / _e8434.x), _e8437.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e8447 = textureSample(t_source, samp, _e8446);
                                                                    outCol = _e8447;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e8448 = mode_6;
                                                    if (_e8448 == 7i) {
                                                        {
                                                            let _e8453 = inverseTileTransform_4[0];
                                                            w_18 = _e8453.xy;
                                                            let _e8456 = w_18;
                                                            let _e8460 = w_18;
                                                            w_18 = floor(vec2<f32>(dot(_e8456, vec2(16f)), dot(_e8460, vec2<f32>(16f, -16f))));
                                                            let _e8468 = startScale_8;
                                                            let _e8475 = inverseTileTransform_4[2];
                                                            minScale_4 = ((_e8468 * 2f) * pow(2f, floor((2f * _e8475.y))));
                                                            let _e8482 = minScale_4;
                                                            let _e8483 = startScale_8;
                                                            let _e8490 = inverseTileTransform_4[2];
                                                            maxScale_4 = max(_e8482, ((_e8483 * 4f) * pow(2f, floor((2f * _e8490.x)))));
                                                            let _e8498 = scale_8;
                                                            let _e8499 = minScale_4;
                                                            let _e8500 = maxScale_4;
                                                            scale2_8 = clamp(_e8498, _e8499, _e8500);
                                                            let _e8503 = scale2_8;
                                                            let _e8504 = scale_8;
                                                            invScaleRatio_8 = (_e8503 / _e8504);
                                                            let _e8507 = invScaleRatio_8;
                                                            let _e8511 = invScaleRatio_8;
                                                            let _e8520 = currentTransform_6;
                                                            tr_8 = (mat3x3<f32>(vec3<f32>(_e8507, 0f, 0f), vec3<f32>(0f, _e8511, 0f), vec3<f32>(0f, 0f, 1f)) * _e8520);
                                                            let _e8523 = tr_8;
                                                            let _e8524 = _uv_6;
                                                            let _e8525 = tf(_e8523, _e8524);
                                                            v_7 = (_e8525 - vec2(0.5f));
                                                            let _e8529 = v_7;
                                                            let _e8530 = w_18;
                                                            pixId_9 = floor((_e8529 * _e8530));
                                                            let _e8534 = pixId_9;
                                                            let _e8536 = pixId_9;
                                                            let _e8538 = (_e8534.x + _e8536.y);
                                                            k_32 = (_e8538 - (floor((_e8538 / 2f)) * 2f));
                                                            let _e8545 = k_32;
                                                            let _e8546 = vec3(_e8545);
                                                            outCol = vec4<f32>(_e8546.x, _e8546.y, _e8546.z, 1f);
                                                        }
                                                    } else {
                                                        let _e8552 = mode_6;
                                                        if (_e8552 == 8i) {
                                                            {
                                                                let _e8557 = startScale_8;
                                                                scale2_9 = (_e8557 * 4f);
                                                                let _e8561 = scale2_9;
                                                                let _e8562 = scale_8;
                                                                invScaleRatio_9 = (_e8561 / _e8562);
                                                                let _e8565 = invScaleRatio_9;
                                                                let _e8569 = invScaleRatio_9;
                                                                let _e8578 = currentTransform_6;
                                                                tr_9 = (mat3x3<f32>(vec3<f32>(_e8565, 0f, 0f), vec3<f32>(0f, _e8569, 0f), vec3<f32>(0f, 0f, 1f)) * _e8578);
                                                                let _e8581 = tr_9;
                                                                let _e8582 = _uv_6;
                                                                let _e8583 = tf(_e8581, _e8582);
                                                                v_7 = (_e8583 - vec2(0.5f));
                                                                let _e8593 = inverseTileTransform_4[0];
                                                                let _e8597 = inverseTileTransform_4[0];
                                                                let _e8600 = piN_4;
                                                                let _e8603 = piN_4;
                                                                ang_31 = (floor((atan2(_e8593.y, _e8597.x) / _e8600)) * _e8603);
                                                                let _e8606 = ang_31;
                                                                let _e8607 = rotation2_(_e8606);
                                                                let _e8608 = v_7;
                                                                let _e8612 = inverseTileTransform_4[0];
                                                                let _e8619 = inverseTileTransform_4[2];
                                                                v_7 = (((_e8607 * _e8608) * length(_e8612.xy)) + (2f * _e8619.xy));
                                                                let _e8623 = v_7;
                                                                let _e8625 = v_7;
                                                                let _e8627 = rnd_6;
                                                                let _e8634 = Xn_4;
                                                                let _e8636 = floor(((_e8623.x + (_e8625.y * sign((_e8627.y - 0.5f)))) * _e8634));
                                                                k_33 = (_e8636 - (floor((_e8636 / 2f)) * 2f));
                                                                let _e8643 = k_33;
                                                                let _e8644 = vec3(_e8643);
                                                                outCol = vec4<f32>(_e8644.x, _e8644.y, _e8644.z, 1f);
                                                            }
                                                        } else {
                                                            let _e8650 = mode_6;
                                                            if (_e8650 == 9i) {
                                                                {
                                                                    let _e8657 = inverseTileTransform_4[2];
                                                                    N_21 = floor((1000f * pow(0.25f, length(_e8657.xy))));
                                                                    let _e8668 = N_21;
                                                                    let _e8673 = inverseTileTransform_4[1];
                                                                    let _e8677 = inverseTileTransform_4[1];
                                                                    offset_4 = ((1.5707964f + (3.1415927f / _e8668)) + atan2(_e8673.y, _e8677.x));
                                                                    let _e8682 = v_7;
                                                                    let _e8684 = v_7;
                                                                    ang_32 = atan2(_e8682.y, _e8684.x);
                                                                    let _e8688 = ang_32;
                                                                    let _e8689 = offset_4;
                                                                    let _e8693 = N_21;
                                                                    let _e8696 = N_21;
                                                                    let _e8700 = offset_4;
                                                                    ang_32 = (((round((((_e8688 - _e8689) / 6.2831855f) * _e8693)) / _e8696) * 6.2831855f) + _e8700);
                                                                    let _e8704 = inverseTileTransform_4[0];
                                                                    let _e8709 = ang_32;
                                                                    let _e8712 = ang_32;
                                                                    dist_8 = ((length(_e8704.xy) * 0.5f) / max(abs(cos(_e8709)), abs(sin(_e8712))));
                                                                    let _e8718 = dist_8;
                                                                    let _e8719 = ang_32;
                                                                    let _e8721 = ang_32;
                                                                    v_7 = (_e8718 * vec2<f32>(cos(_e8719), sin(_e8721)));
                                                                    let _e8725 = inverseCurrentTransform_6;
                                                                    let _e8726 = relId_6;
                                                                    let _e8727 = v_7;
                                                                    let _e8732 = tf(_e8725, (_e8726 + (_e8727 + vec2(0.5f))));
                                                                    u_10 = _e8732;
                                                                    let _e8734 = u_10;
                                                                    let _e8738 = global.U[0];
                                                                    let _e8741 = u_10;
                                                                    let _e8750 = _mirror_wrap(((vec2<f32>((_e8734.x / _e8738.x), _e8741.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e8751 = textureSample(t_source, samp, _e8750);
                                                                    outCol = _e8751;
                                                                }
                                                            } else {
                                                                let _e8752 = mode_6;
                                                                if (_e8752 == 10i) {
                                                                    {
                                                                        let _e8757 = inverseTileTransform_4[0];
                                                                        s_9 = (length(_e8757.xy) * 0.05f);
                                                                        let _e8763 = v_7;
                                                                        v_7 = (_e8763 + vec2(0.5f));
                                                                        let _e8771 = inverseTileTransform_4[0];
                                                                        let _e8775 = inverseTileTransform_4[0];
                                                                        let _e8780 = N_22;
                                                                        let _e8785 = N_22;
                                                                        ang_33 = ((floor(((atan2(_e8771.y, _e8775.x) / 3.1415927f) * _e8780)) * 3.1415927f) / _e8785);
                                                                        let _e8788 = ang_33;
                                                                        let _e8789 = rotation2_(_e8788);
                                                                        let _e8790 = v_7;
                                                                        v_7 = (_e8789 * _e8790);
                                                                        let _e8792 = v_7;
                                                                        let _e8796 = inverseTileTransform_4[2];
                                                                        let _e8800 = tileTransform_4[0];
                                                                        let _e8808 = v_7;
                                                                        let _e8812 = inverseTileTransform_4[2];
                                                                        let _e8816 = tileTransform_4[0];
                                                                        let _e8823 = hslToRgb(vec4<f32>(((_e8792.x + (_e8796.x * length(_e8800.xy))) * 360f), 1f, (_e8808.y + (_e8812.y * length(_e8816.xy))), 1f));
                                                                        rgb_4 = _e8823;
                                                                        let _e8825 = _uv_6;
                                                                        let _e8829 = global.U[0];
                                                                        let _e8832 = _uv_6;
                                                                        let _e8841 = _mirror_wrap(((vec2<f32>((_e8825.x / _e8829.x), _e8832.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e8842 = textureSample(t_source, samp, _e8841);
                                                                        inc_6 = _e8842;
                                                                        let _e8844 = inc_6;
                                                                        let _e8846 = rgb_4;
                                                                        dist_9 = length((_e8844.xyz - _e8846.xyz));
                                                                        let _e8854 = dist_9;
                                                                        let _e8856 = s_9;
                                                                        k_34 = (1f - (smoothstep(0f, 1.7f, _e8854) * _e8856));
                                                                        let _e8860 = inc_6;
                                                                        let _e8861 = rgb_4;
                                                                        let _e8862 = k_34;
                                                                        rgb_4 = mix(_e8860, _e8861, vec4(_e8862));
                                                                        let _e8865 = rgb_4;
                                                                        outCol = _e8865;
                                                                    }
                                                                } else {
                                                                    let _e8866 = mode_6;
                                                                    if (_e8866 == 11i) {
                                                                        {
                                                                            let _e8872 = inverseTileTransform_4[0];
                                                                            N_23 = round((4f * abs(_e8872.x)));
                                                                            let _e8879 = v_7;
                                                                            let _e8883 = N_23;
                                                                            let _e8886 = N_23;
                                                                            let _e8893 = N_23;
                                                                            center_18 = (vec2<f32>(0f, ((((floor(((_e8879.y + 0.5f) * _e8883)) / _e8886) * 2f) - 1f) + (1f / _e8893))) * 0.5f);
                                                                            let _e8900 = v_7;
                                                                            let _e8901 = center_18;
                                                                            dv_8 = abs((_e8900 - _e8901));
                                                                            let _e8905 = dv_8;
                                                                            let _e8909 = dv_8;
                                                                            let _e8912 = N_23;
                                                                            if ((_e8905.x < 0.45f) && (_e8909.y < (0.4f / _e8912))) {
                                                                                {
                                                                                    let _e8918 = inverseTileTransform_4[2];
                                                                                    s_10 = (_e8918.x + 1f);
                                                                                    let _e8923 = inverseCurrentTransform_6;
                                                                                    let _e8924 = relId_6;
                                                                                    let _e8925 = s_10;
                                                                                    let _e8935 = tf(_e8923, (_e8924 + ((_e8925 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_18 = _e8935;
                                                                                    let _e8937 = inverseCurrentTransform_6;
                                                                                    let _e8938 = relId_6;
                                                                                    let _e8939 = s_10;
                                                                                    let _e8948 = tf(_e8937, (_e8938 + ((_e8939 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_18 = _e8948;
                                                                                    let _e8950 = u1_18;
                                                                                    let _e8954 = global.U[0];
                                                                                    let _e8957 = u1_18;
                                                                                    let _e8966 = _mirror_wrap(((vec2<f32>((_e8950.x / _e8954.x), _e8957.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e8967 = textureSample(t_source, samp, _e8966);
                                                                                    let _e8968 = u2_18;
                                                                                    let _e8972 = global.U[0];
                                                                                    let _e8975 = u2_18;
                                                                                    let _e8984 = _mirror_wrap(((vec2<f32>((_e8968.x / _e8972.x), _e8975.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e8985 = textureSample(t_source, samp, _e8984);
                                                                                    let _e8986 = center_18;
                                                                                    outCol = mix(_e8967, _e8985, vec4((_e8986.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e8992 = mode_6;
                                                                        if (_e8992 == 12i) {
                                                                            {
                                                                                let _e8995 = v_7;
                                                                                v_7 = (_e8995 * vec2<f32>(2f, 2f));
                                                                                let _e9000 = inverseTileTransform_4;
                                                                                let _e9001 = v_7;
                                                                                let _e9002 = tf(_e9000, _e9001);
                                                                                v_7 = _e9002;
                                                                                let _e9003 = inverseCurrentTransform_6;
                                                                                let _e9004 = relId_6;
                                                                                let _e9005 = v_7;
                                                                                let _e9010 = tf(_e9003, (_e9004 + (_e9005 + vec2(0.5f))));
                                                                                let _e9014 = global.U[0];
                                                                                let _e9017 = inverseCurrentTransform_6;
                                                                                let _e9018 = relId_6;
                                                                                let _e9019 = v_7;
                                                                                let _e9024 = tf(_e9017, (_e9018 + (_e9019 + vec2(0.5f))));
                                                                                let _e9033 = _mirror_wrap(((vec2<f32>((_e9010.x / _e9014.x), _e9024.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e9034 = textureSample(t_source, samp, _e9033);
                                                                                outCol = _e9034;
                                                                            }
                                                                        } else {
                                                                            let _e9035 = mode_6;
                                                                            if (_e9035 == 13i) {
                                                                                {
                                                                                    let _e9038 = _uv_6;
                                                                                    let _e9042 = global.U[0];
                                                                                    let _e9045 = _uv_6;
                                                                                    let _e9054 = _mirror_wrap(((vec2<f32>((_e9038.x / _e9042.x), _e9045.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e9055 = textureSample(t_source, samp, _e9054);
                                                                                    let _e9057 = luma(_e9055.xyz);
                                                                                    lum_12 = _e9057;
                                                                                    let _e9059 = inverseTileTransform_4;
                                                                                    let _e9060 = v_7;
                                                                                    let _e9065 = tf(_e9059, (_e9060 * vec2<f32>(8f, 8f)));
                                                                                    v_7 = _e9065;
                                                                                    let _e9066 = v_7;
                                                                                    let _e9069 = (_e9066.y + 1f);
                                                                                    y_4 = abs(((_e9069 - (floor((_e9069 / 2f)) * 2f)) - 1f));
                                                                                    let _e9079 = lum_12;
                                                                                    let _e9080 = y_4;
                                                                                    if (_e9079 > _e9080) {
                                                                                        local_36 = 1f;
                                                                                    } else {
                                                                                        local_36 = 0f;
                                                                                    }
                                                                                    let _e9085 = local_36;
                                                                                    k_35 = _e9085;
                                                                                    let _e9087 = k_35;
                                                                                    let _e9088 = vec3(_e9087);
                                                                                    outCol = vec4<f32>(_e9088.x, _e9088.y, _e9088.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e9094 = mode_6;
                                                                                if (_e9094 == 14i) {
                                                                                    {
                                                                                        let _e9097 = id_4;
                                                                                        let _e9101 = global.U[0];
                                                                                        let _e9104 = id_4;
                                                                                        let _e9113 = _mirror_wrap(((vec2<f32>((_e9097.x / _e9101.x), _e9104.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e9114 = textureSample(t_source, samp, _e9113);
                                                                                        let _e9116 = luma(_e9114.xyz);
                                                                                        lum_13 = _e9116;
                                                                                        let _e9120 = tileTransform_4[0];
                                                                                        contrast_4 = length(_e9120.xy);
                                                                                        let _e9124 = v_7;
                                                                                        let _e9127 = (_e9124 + vec2(0.5f));
                                                                                        let _e9129 = contrast_4;
                                                                                        let _e9130 = lum_13;
                                                                                        outCol = vec4<f32>(_e9127.x, _e9127.y, (0.5f + (_e9129 * (_e9130 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e9139 = mode_6;
                                                                                    if (_e9139 == 15i) {
                                                                                        {
                                                                                            let _e9142 = rnd_6;
                                                                                            center_19 = (sign((_e9142 - vec2(0.5f))) * 0.5f);
                                                                                            let _e9150 = v_7;
                                                                                            let _e9151 = center_19;
                                                                                            dv_9 = (_e9150 - _e9151);
                                                                                            let _e9157 = inverseTileTransform_4[0];
                                                                                            N_24 = floor((16f * length(_e9157.xy)));
                                                                                            let _e9165 = dv_9;
                                                                                            let _e9167 = dv_9;
                                                                                            let _e9170 = angOffset_4;
                                                                                            ang_34 = (atan2(_e9165.y, _e9167.x) + _e9170);
                                                                                            let _e9173 = ang_34;
                                                                                            let _e9176 = N_24;
                                                                                            let _e9179 = (((_e9173 / 3.1415927f) * _e9176) * 2f);
                                                                                            k_36 = abs(((_e9179 - (floor((_e9179 / 2f)) * 2f)) - 1f));
                                                                                            let _e9191 = inverseTileTransform_4[0];
                                                                                            let _e9195 = inverseTileTransform_4[0];
                                                                                            kCol_4 = (atan2(_e9191.y, _e9195.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e9205 = i_13;
                                                                                                if !((_e9205 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e9212 = inverseCurrentTransform_6;
                                                                                                    let _e9213 = relId_6;
                                                                                                    let _e9216 = i_13;
                                                                                                    let _e9220 = ang_34;
                                                                                                    let _e9222 = ang_34;
                                                                                                    let _e9227 = tf(_e9212, (_e9213 + ((0.1f + (0.15f * f32(_e9216))) * vec2<f32>(cos(_e9220), sin(_e9222)))));
                                                                                                    w_19 = _e9227;
                                                                                                    let _e9229 = lum_14;
                                                                                                    let _e9230 = w_19;
                                                                                                    let _e9234 = global.U[0];
                                                                                                    let _e9237 = w_19;
                                                                                                    let _e9246 = _mirror_wrap(((vec2<f32>((_e9230.x / _e9234.x), _e9237.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9247 = textureSample(t_source, samp, _e9246);
                                                                                                    let _e9249 = luma(_e9247.xyz);
                                                                                                    lum_14 = (_e9229 + _e9249);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e9209 = i_13;
                                                                                                    i_13 = (_e9209 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e9251 = lum_14;
                                                                                            lum_14 = (_e9251 / 5f);
                                                                                            let _e9254 = lum_14;
                                                                                            let _e9255 = k_36;
                                                                                            if (_e9254 > _e9255) {
                                                                                                local_37 = 1f;
                                                                                            } else {
                                                                                                local_37 = 0f;
                                                                                            }
                                                                                            let _e9260 = local_37;
                                                                                            k_36 = _e9260;
                                                                                            let _e9261 = kCol_4;
                                                                                            if (_e9261 == 0f) {
                                                                                                {
                                                                                                    let _e9264 = k_36;
                                                                                                    let _e9265 = vec3(_e9264);
                                                                                                    outCol = vec4<f32>(_e9265.x, _e9265.y, _e9265.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e9273 = inverseTileTransform_4[2];
                                                                                                    u1_19 = vec2<f32>(_e9273.x, 0f);
                                                                                                    let _e9281 = inverseTileTransform_4[2];
                                                                                                    u2_19 = vec2<f32>(0f, _e9281.y);
                                                                                                    let _e9285 = kCol_4;
                                                                                                    if (_e9285 > 0f) {
                                                                                                        {
                                                                                                            let _e9288 = u1_19;
                                                                                                            let _e9289 = id_4;
                                                                                                            u1_19 = (_e9288 + _e9289);
                                                                                                            let _e9291 = u2_19;
                                                                                                            let _e9292 = id_4;
                                                                                                            u2_19 = (_e9291 + (_e9292 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e9297 = u1_19;
                                                                                                    let _e9301 = global.U[0];
                                                                                                    let _e9304 = u1_19;
                                                                                                    let _e9313 = _mirror_wrap(((vec2<f32>((_e9297.x / _e9301.x), _e9304.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9314 = textureSample(t_source, samp, _e9313);
                                                                                                    col1_16 = _e9314;
                                                                                                    let _e9316 = u2_19;
                                                                                                    let _e9320 = global.U[0];
                                                                                                    let _e9323 = u2_19;
                                                                                                    let _e9332 = _mirror_wrap(((vec2<f32>((_e9316.x / _e9320.x), _e9323.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e9333 = textureSample(t_source, samp, _e9332);
                                                                                                    col2_15 = _e9333;
                                                                                                    let _e9335 = col1_16;
                                                                                                    let _e9337 = luma(_e9335.xyz);
                                                                                                    let _e9338 = col2_15;
                                                                                                    let _e9340 = luma(_e9338.xyz);
                                                                                                    if (_e9337 > _e9340) {
                                                                                                        let _e9343 = k_36;
                                                                                                        k_36 = (1f - _e9343);
                                                                                                    }
                                                                                                    let _e9345 = k_36;
                                                                                                    let _e9346 = vec3(_e9345);
                                                                                                    outCol1_4 = vec4<f32>(_e9346.x, _e9346.y, _e9346.z, 1f);
                                                                                                    let _e9353 = col1_16;
                                                                                                    let _e9354 = col2_15;
                                                                                                    let _e9355 = k_36;
                                                                                                    outCol2_4 = mix(_e9353, _e9354, vec4(_e9355));
                                                                                                    let _e9359 = outCol1_4;
                                                                                                    let _e9360 = outCol2_4;
                                                                                                    let _e9361 = kCol_4;
                                                                                                    outCol = mix(_e9359, _e9360, vec4(abs(_e9361)));
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
                let _e9365 = src2_1;
                let _e9366 = outCol;
                let _e9367 = mergeColor(_e9365, _e9366);
                col2_16 = _e9367;
                let _e9369 = col1_13;
                let _e9371 = col2_16;
                let _e9373 = k_22;
                let _e9375 = mix(_e9369.xyz, _e9371.xyz, vec3(_e9373));
                outCol = vec4<f32>(_e9375.x, _e9375.y, _e9375.z, 1f);
            }
        } else {
            {
                {
                    let _e9381 = _uv_4;
                    _uv_7 = _e9381;
                    let _e9383 = _params_1;
                    startScale_9 = _e9383.startScale;
                    let _e9386 = _params_1;
                    subLevels_7 = _e9386.subLevels;
                    let _e9389 = _params_1;
                    subThreshold_7 = _e9389.subThreshold;
                    let _e9392 = _params_1;
                    seed_7 = _e9392.seed;
                    let _e9395 = _params_1;
                    hashStyle_9 = _e9395.hashStyle;
                    let _e9398 = _params_1;
                    coverage_7 = _e9398.coverage;
                    let _e9401 = _params_1;
                    currentTransform_7 = _e9401.transform;
                    let _e9404 = _params_1;
                    inverseCurrentTransform_7 = _e9404.inverseTransform;
                    let _e9407 = startScale_9;
                    scale_10 = _e9407;
                    loop {
                        let _e9415 = i_14;
                        let _e9416 = subLevels_7;
                        if !((_e9415 < _e9416)) {
                            break;
                        }
                        {
                            let _e9422 = i_14;
                            if (_e9422 != 0f) {
                                {
                                    let _e9438 = currentTransform_7;
                                    currentTransform_7 = (mat3x3<f32>(vec3<f32>(2f, 0f, 0f), vec3<f32>(0f, 2f, 0f), vec3<f32>(0f, 0f, 1f)) * _e9438);
                                    let _e9440 = inverseCurrentTransform_7;
                                    inverseCurrentTransform_7 = (_e9440 * mat3x3<f32>(vec3<f32>(0.5f, 0f, 0f), vec3<f32>(0f, 0.5f, 0f), vec3<f32>(0f, 0f, 1f)));
                                }
                            }
                            let _e9455 = currentTransform_7;
                            let _e9456 = _uv_7;
                            let _e9457 = tf(_e9455, _e9456);
                            relId_7 = floor(_e9457);
                            let _e9459 = relId_7;
                            let _e9461 = (_e9459 * 0.13137f);
                            let _e9462 = i_14;
                            let _e9463 = seed_7;
                            let _e9467 = hashStyle_9;
                            let _e9468 = hash42sp(vec4<f32>(_e9461.x, _e9461.y, _e9462, _e9463), _e9467);
                            rnd_7 = _e9468;
                            let _e9469 = i_14;
                            let _e9470 = subLevels_7;
                            let _e9474 = rnd_7;
                            let _e9476 = subThreshold_7;
                            if ((_e9469 == (_e9470 - 1f)) || (_e9474.x > _e9476)) {
                                {
                                    break;
                                }
                            }
                            let _e9479 = scale_10;
                            scale_10 = (_e9479 * 2f);
                        }
                        continuing {
                            let _e9419 = i_14;
                            i_14 = (_e9419 + 1f);
                        }
                    }
                    let _e9482 = inverseCurrentTransform_7;
                    let _e9483 = relId_7;
                    let _e9484 = tf(_e9482, _e9483);
                    id_5 = _e9484;
                    let _e9486 = rnd_7;
                    modeIndex_5 = i32(floor((_e9486.y * 4f)));
                    let _e9493 = modeIndex_5;
                    let _e9496 = _params_1.modeMap[_e9493];
                    mode_7 = _e9496;
                    let _e9499 = modeIndex_5;
                    if (_e9499 == 0i) {
                        let _e9502 = tileTransform1_1;
                        tileTransform_5 = _e9502;
                    } else {
                        let _e9503 = modeIndex_5;
                        if (_e9503 == 1i) {
                            let _e9506 = tileTransform2_1;
                            tileTransform_5 = _e9506;
                        } else {
                            let _e9507 = modeIndex_5;
                            if (_e9507 == 2i) {
                                let _e9510 = tileTransform3_1;
                                tileTransform_5 = _e9510;
                            } else {
                                let _e9511 = tileTransform4_1;
                                tileTransform_5 = _e9511;
                            }
                        }
                    }
                    let _e9512 = tileTransform_5;
                    inverseTileTransform_5 = _naga_inverse_3x3_f32(_e9512);
                    let _e9515 = currentTransform_7;
                    let _e9516 = _uv_7;
                    let _e9517 = tf(_e9515, _e9516);
                    let _e9518 = relId_7;
                    v_8 = ((_e9517 - _e9518) - vec2(0.5f));
                    outCol = vec4(0f);
                    let _e9525 = rnd_7;
                    let _e9529 = rnd_7;
                    let _e9535 = coverage_7;
                    if (fract(((_e9525.x * 6.222f) + (_e9529.y * 8.233f))) <= _e9535) {
                        {
                            let _e9537 = mode_7;
                            if (_e9537 == 0i) {
                                {
                                    let _e9542 = inverseTileTransform_5[0];
                                    w_20 = _e9542.xy;
                                    let _e9545 = w_20;
                                    let _e9549 = w_20;
                                    w_20 = floor(vec2<f32>(dot(_e9545, vec2(20f)), dot(_e9549, vec2<f32>(20f, -20f))));
                                    let _e9557 = relId_7;
                                    let _e9559 = v_8;
                                    let _e9560 = w_20;
                                    let _e9565 = tileTransform_5[0];
                                    let _e9572 = inverseTileTransform_5[2];
                                    let _e9575 = w_20;
                                    pixId_10 = (_e9557 + (1.23f * (floor((_e9559 * _e9560)) + floor((((length(_e9565.xy) * 5f) * _e9572.xy) * _e9575)))));
                                    let _e9582 = pixId_10;
                                    let _e9583 = hash22_(_e9582);
                                    let _e9587 = global.U[0];
                                    let _e9590 = pixId_10;
                                    let _e9591 = hash22_(_e9590);
                                    let _e9600 = _mirror_wrap(((vec2<f32>((_e9583.x / _e9587.x), _e9591.y) / vec2(2f)) + vec2(0.5f)));
                                    let _e9601 = textureSample(t_source, samp, _e9600);
                                    outCol = _e9601;
                                }
                            } else {
                                let _e9602 = mode_7;
                                if (_e9602 == 1i) {
                                    {
                                        let _e9606 = v_8;
                                        let _e9609 = v_8;
                                        v_8 = vec2<f32>(0f, max(abs(_e9606.x), abs(_e9609.y)));
                                        let _e9614 = inverseCurrentTransform_7;
                                        let _e9615 = relId_7;
                                        let _e9616 = inverseTileTransform_5;
                                        let _e9617 = v_8;
                                        let _e9618 = tf(_e9616, _e9617);
                                        let _e9623 = tf(_e9614, (_e9615 + (_e9618 + vec2(0.5f))));
                                        vv_10 = _e9623;
                                        let _e9625 = vv_10;
                                        let _e9629 = global.U[0];
                                        let _e9632 = vv_10;
                                        let _e9641 = _mirror_wrap(((vec2<f32>((_e9625.x / _e9629.x), _e9632.y) / vec2(2f)) + vec2(0.5f)));
                                        let _e9642 = textureSample(t_source, samp, _e9641);
                                        outCol = _e9642;
                                    }
                                } else {
                                    let _e9643 = mode_7;
                                    if (_e9643 == 2i) {
                                        {
                                            let _e9649 = inverseTileTransform_5[2];
                                            size_15 = (0.5f + _e9649.y);
                                            let _e9653 = v_8;
                                            d_10 = length(_e9653);
                                            let _e9656 = v_8;
                                            let _e9658 = v_8;
                                            ang_35 = atan2(_e9656.y, _e9658.x);
                                            let _e9662 = d_10;
                                            let _e9663 = size_15;
                                            if (_e9662 <= _e9663) {
                                                {
                                                    let _e9668 = spikeCount_5;
                                                    anglePeriod_5 = (6.2831855f / _e9668);
                                                    let _e9671 = ang_35;
                                                    let _e9672 = anglePeriod_5;
                                                    let _e9675 = anglePeriod_5;
                                                    a1_5 = (floor((_e9671 / _e9672)) * _e9675);
                                                    let _e9678 = a1_5;
                                                    let _e9679 = anglePeriod_5;
                                                    a2_5 = (_e9678 + _e9679);
                                                    let _e9682 = ang_35;
                                                    let _e9683 = a1_5;
                                                    let _e9685 = anglePeriod_5;
                                                    k_37 = ((_e9682 - _e9683) / _e9685);
                                                    let _e9688 = d_10;
                                                    let _e9693 = inverseTileTransform_5[0];
                                                    ds_10 = ((_e9688 * 10f) * length(_e9693.xy));
                                                    let _e9698 = relId_7;
                                                    center_20 = (_e9698 + vec2(0.5f));
                                                    let _e9703 = inverseCurrentTransform_7;
                                                    let _e9704 = center_20;
                                                    let _e9705 = ds_10;
                                                    let _e9706 = a1_5;
                                                    let _e9708 = a1_5;
                                                    let _e9715 = inverseTileTransform_5[2];
                                                    let _e9719 = tf(_e9703, ((_e9704 + (_e9705 * vec2<f32>(cos(_e9706), sin(_e9708)))) + vec2(_e9715.x)));
                                                    u1_20 = _e9719;
                                                    let _e9721 = inverseCurrentTransform_7;
                                                    let _e9722 = center_20;
                                                    let _e9723 = ds_10;
                                                    let _e9724 = a2_5;
                                                    let _e9726 = a2_5;
                                                    let _e9733 = inverseTileTransform_5[2];
                                                    let _e9737 = tf(_e9721, ((_e9722 + (_e9723 * vec2<f32>(cos(_e9724), sin(_e9726)))) + vec2(_e9733.x)));
                                                    u2_20 = _e9737;
                                                    let _e9739 = u1_20;
                                                    let _e9743 = global.U[0];
                                                    let _e9746 = u1_20;
                                                    let _e9755 = _mirror_wrap(((vec2<f32>((_e9739.x / _e9743.x), _e9746.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e9756 = textureSample(t_source, samp, _e9755);
                                                    col1_17 = _e9756;
                                                    let _e9758 = u2_20;
                                                    let _e9762 = global.U[0];
                                                    let _e9765 = u2_20;
                                                    let _e9774 = _mirror_wrap(((vec2<f32>((_e9758.x / _e9762.x), _e9765.y) / vec2(2f)) + vec2(0.5f)));
                                                    let _e9775 = textureSample(t_source, samp, _e9774);
                                                    col2_17 = _e9775;
                                                    let _e9777 = col1_17;
                                                    let _e9778 = col2_17;
                                                    let _e9779 = k_37;
                                                    outCol = mix(_e9777, _e9778, vec4(_e9779));
                                                }
                                            }
                                        }
                                    } else {
                                        let _e9782 = mode_7;
                                        if (_e9782 == 3i) {
                                            {
                                                let _e9785 = v_8;
                                                let _e9788 = v_8;
                                                vert_5 = (abs(_e9785.y) > abs(_e9788.x));
                                                let _e9793 = vert_5;
                                                if _e9793 {
                                                    let _e9794 = v_8;
                                                    local_38 = _e9794.y;
                                                } else {
                                                    let _e9796 = v_8;
                                                    local_38 = _e9796.x;
                                                }
                                                let _e9799 = local_38;
                                                a_5 = _e9799;
                                                let _e9801 = vert_5;
                                                if _e9801 {
                                                    let _e9802 = a_5;
                                                    let _e9804 = a_5;
                                                    local_39 = vec2<f32>(-(_e9802), _e9804);
                                                } else {
                                                    let _e9806 = a_5;
                                                    let _e9807 = a_5;
                                                    local_39 = vec2<f32>(_e9806, -(_e9807));
                                                }
                                                let _e9811 = local_39;
                                                u1_21 = _e9811;
                                                let _e9813 = a_5;
                                                let _e9814 = a_5;
                                                u2_21 = vec2<f32>(_e9813, _e9814);
                                                let _e9817 = v_8;
                                                let _e9819 = v_8;
                                                let _e9823 = a_5;
                                                k_38 = ((_e9817.x + _e9819.y) / (2f * _e9823));
                                                let _e9827 = inverseCurrentTransform_7;
                                                let _e9828 = relId_7;
                                                let _e9829 = inverseTileTransform_5;
                                                let _e9830 = u1_21;
                                                let _e9831 = tf(_e9829, _e9830);
                                                let _e9836 = tf(_e9827, (_e9828 + (_e9831 + vec2(0.5f))));
                                                u1_21 = _e9836;
                                                let _e9837 = inverseCurrentTransform_7;
                                                let _e9838 = relId_7;
                                                let _e9839 = inverseTileTransform_5;
                                                let _e9840 = u2_21;
                                                let _e9841 = tf(_e9839, _e9840);
                                                let _e9846 = tf(_e9837, (_e9838 + (_e9841 + vec2(0.5f))));
                                                u2_21 = _e9846;
                                                let _e9847 = u1_21;
                                                let _e9851 = global.U[0];
                                                let _e9854 = u1_21;
                                                let _e9863 = _mirror_wrap(((vec2<f32>((_e9847.x / _e9851.x), _e9854.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e9864 = textureSample(t_source, samp, _e9863);
                                                col1_18 = _e9864;
                                                let _e9866 = u2_21;
                                                let _e9870 = global.U[0];
                                                let _e9873 = u2_21;
                                                let _e9882 = _mirror_wrap(((vec2<f32>((_e9866.x / _e9870.x), _e9873.y) / vec2(2f)) + vec2(0.5f)));
                                                let _e9883 = textureSample(t_source, samp, _e9882);
                                                col2_18 = _e9883;
                                                let _e9885 = col1_18;
                                                let _e9886 = col2_18;
                                                let _e9887 = k_38;
                                                outCol = mix(_e9885, _e9886, vec4(_e9887));
                                            }
                                        } else {
                                            let _e9890 = mode_7;
                                            if (_e9890 == 4i) {
                                                {
                                                    let _e9897 = inverseTileTransform_5[0];
                                                    let _e9901 = inverseTileTransform_5[0];
                                                    ang_36 = atan2(_e9897.y, _e9901.x);
                                                    let _e9905 = ang_36;
                                                    if (_e9905 < 0f) {
                                                        let _e9908 = relId_7;
                                                        let _e9910 = relId_7;
                                                        let _e9912 = (_e9908.x + _e9910.y);
                                                        local_40 = sign(((_e9912 - (floor((_e9912 / 2f)) * 2f)) - 0.5f));
                                                    } else {
                                                        local_40 = 1f;
                                                    }
                                                    let _e9923 = local_40;
                                                    orientation_5 = _e9923;
                                                    let _e9925 = rnd_7;
                                                    let _e9927 = ang_36;
                                                    if (_e9925.y > (abs(_e9927) / 3.1415927f)) {
                                                        let _e9932 = orientation_5;
                                                        orientation_5 = -(_e9932);
                                                    }
                                                    let _e9934 = orientation_5;
                                                    let _e9935 = v_8;
                                                    let _e9938 = v_8;
                                                    if (((_e9934 * _e9935.x) * _e9938.y) < 0f) {
                                                        local_41 = 40f;
                                                    } else {
                                                        local_41 = 2.5f;
                                                    }
                                                    let _e9946 = local_41;
                                                    p_10 = _e9946;
                                                    let _e9948 = p_10;
                                                    if (_e9948 > 30f) {
                                                        let _e9951 = v_8;
                                                        let _e9954 = v_8;
                                                        local_42 = max(abs(_e9951.x), abs(_e9954.y));
                                                    } else {
                                                        let _e9958 = v_8;
                                                        let _e9961 = p_10;
                                                        let _e9963 = v_8;
                                                        let _e9966 = p_10;
                                                        let _e9970 = p_10;
                                                        local_42 = pow((pow(abs(_e9958.x), _e9961) + pow(abs(_e9963.y), _e9966)), (1f / _e9970));
                                                    }
                                                    let _e9974 = local_42;
                                                    d_11 = _e9974;
                                                    let _e9977 = d_11;
                                                    v_8 = vec2<f32>(0f, _e9977);
                                                    let _e9979 = v_8;
                                                    let _e9981 = size_16;
                                                    if (_e9979.y <= _e9981) {
                                                        {
                                                            let _e9983 = inverseCurrentTransform_7;
                                                            let _e9984 = relId_7;
                                                            let _e9985 = inverseTileTransform_5;
                                                            let _e9986 = v_8;
                                                            let _e9987 = tf(_e9985, _e9986);
                                                            let _e9992 = tf(_e9983, (_e9984 + (_e9987 + vec2(0.5f))));
                                                            vv_11 = _e9992;
                                                            let _e9994 = vv_11;
                                                            let _e9998 = global.U[0];
                                                            let _e10001 = vv_11;
                                                            let _e10010 = _mirror_wrap(((vec2<f32>((_e9994.x / _e9998.x), _e10001.y) / vec2(2f)) + vec2(0.5f)));
                                                            let _e10011 = textureSample(t_source, samp, _e10010);
                                                            outCol = _e10011;
                                                        }
                                                    }
                                                }
                                            } else {
                                                let _e10012 = mode_7;
                                                if (_e10012 <= 6i) {
                                                    {
                                                        let _e10017 = inverseTileTransform_5[0];
                                                        scale_11 = length(_e10017.xy);
                                                        let _e10021 = scale_11;
                                                        invert_5 = (_e10021 < 1f);
                                                        let _e10025 = invert_5;
                                                        if _e10025 {
                                                            let _e10027 = scale_11;
                                                            scale_11 = (1f / _e10027);
                                                        }
                                                        let _e10029 = scale_11;
                                                        ds_11 = fract(_e10029);
                                                        let _e10032 = scale_11;
                                                        N_25 = max(floor(_e10032), 1f);
                                                        let _e10037 = v_8;
                                                        let _e10041 = N_25;
                                                        w_21 = (fract(((_e10037 + vec2(0.5f)) * _e10041)) - vec2(0.5f));
                                                        let _e10048 = v_8;
                                                        let _e10052 = N_25;
                                                        let _e10055 = N_25;
                                                        let _e10064 = N_25;
                                                        center_21 = ((((floor(((_e10048 + vec2(0.5f)) * _e10052)) / vec2(_e10055)) * 2f) - vec2(1f)) + vec2((1f / _e10064)));
                                                        let _e10071 = inverseTileTransform_5[0];
                                                        let _e10075 = inverseTileTransform_5[0];
                                                        ang_37 = atan2(_e10071.y, _e10075.x);
                                                        let _e10083 = ang_37;
                                                        if (_e10083 > 0f) {
                                                            let _e10087 = ang_37;
                                                            keepX_5 = (1f - (_e10087 / 3.1415927f));
                                                        } else {
                                                            let _e10092 = ang_37;
                                                            keepY_5 = (1f + (_e10092 / 3.1415927f));
                                                        }
                                                        let _e10096 = center_21;
                                                        let _e10099 = keepX_5;
                                                        let _e10101 = center_21;
                                                        let _e10104 = keepY_5;
                                                        hide_5 = ((abs(_e10096.x) > _e10099) || (abs(_e10101.y) > _e10104));
                                                        let _e10110 = ds_11;
                                                        size_17 = mix(0.5f, 0.15f, _e10110);
                                                        let _e10113 = mode_7;
                                                        let _e10116 = w_21;
                                                        let _e10118 = size_17;
                                                        let _e10121 = mode_7;
                                                        let _e10124 = w_21;
                                                        let _e10127 = size_17;
                                                        let _e10129 = w_21;
                                                        let _e10132 = size_17;
                                                        outside_5 = (((_e10113 == 6i) && (length(_e10116) > _e10118)) || ((_e10121 == 5i) && ((abs(_e10124.x) > _e10127) || (abs(_e10129.y) > _e10132))));
                                                        let _e10138 = hide_5;
                                                        let _e10139 = outside_5;
                                                        if !((_e10138 || _e10139)) {
                                                            {
                                                                let _e10142 = id_5;
                                                                let _e10145 = inverseTileTransform_5[2];
                                                                let _e10151 = global.U[0];
                                                                let _e10154 = id_5;
                                                                let _e10157 = inverseTileTransform_5[2];
                                                                let _e10168 = _mirror_wrap(((vec2<f32>(((_e10142 + _e10145.xy).x / _e10151.x), (_e10154 + _e10157.xy).y) / vec2(2f)) + vec2(0.5f)));
                                                                let _e10169 = textureSample(t_source, samp, _e10168);
                                                                outCol = _e10169;
                                                            }
                                                        } else {
                                                            let _e10170 = invert_5;
                                                            if _e10170 {
                                                                {
                                                                    let _e10171 = id_5;
                                                                    let _e10175 = global.U[0];
                                                                    let _e10178 = id_5;
                                                                    let _e10187 = _mirror_wrap(((vec2<f32>((_e10171.x / _e10175.x), _e10178.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e10188 = textureSample(t_source, samp, _e10187);
                                                                    outCol = _e10188;
                                                                }
                                                            }
                                                        }
                                                    }
                                                } else {
                                                    let _e10189 = mode_7;
                                                    if (_e10189 == 7i) {
                                                        {
                                                            let _e10194 = inverseTileTransform_5[0];
                                                            w_22 = _e10194.xy;
                                                            let _e10197 = w_22;
                                                            let _e10201 = w_22;
                                                            w_22 = floor(vec2<f32>(dot(_e10197, vec2(16f)), dot(_e10201, vec2<f32>(16f, -16f))));
                                                            let _e10209 = startScale_9;
                                                            let _e10216 = inverseTileTransform_5[2];
                                                            minScale_5 = ((_e10209 * 2f) * pow(2f, floor((2f * _e10216.y))));
                                                            let _e10223 = minScale_5;
                                                            let _e10224 = startScale_9;
                                                            let _e10231 = inverseTileTransform_5[2];
                                                            maxScale_5 = max(_e10223, ((_e10224 * 4f) * pow(2f, floor((2f * _e10231.x)))));
                                                            let _e10239 = scale_10;
                                                            let _e10240 = minScale_5;
                                                            let _e10241 = maxScale_5;
                                                            scale2_10 = clamp(_e10239, _e10240, _e10241);
                                                            let _e10244 = scale2_10;
                                                            let _e10245 = scale_10;
                                                            invScaleRatio_10 = (_e10244 / _e10245);
                                                            let _e10248 = invScaleRatio_10;
                                                            let _e10252 = invScaleRatio_10;
                                                            let _e10261 = currentTransform_7;
                                                            tr_10 = (mat3x3<f32>(vec3<f32>(_e10248, 0f, 0f), vec3<f32>(0f, _e10252, 0f), vec3<f32>(0f, 0f, 1f)) * _e10261);
                                                            let _e10264 = tr_10;
                                                            let _e10265 = _uv_7;
                                                            let _e10266 = tf(_e10264, _e10265);
                                                            v_8 = (_e10266 - vec2(0.5f));
                                                            let _e10270 = v_8;
                                                            let _e10271 = w_22;
                                                            pixId_11 = floor((_e10270 * _e10271));
                                                            let _e10275 = pixId_11;
                                                            let _e10277 = pixId_11;
                                                            let _e10279 = (_e10275.x + _e10277.y);
                                                            k_39 = (_e10279 - (floor((_e10279 / 2f)) * 2f));
                                                            let _e10286 = k_39;
                                                            let _e10287 = vec3(_e10286);
                                                            outCol = vec4<f32>(_e10287.x, _e10287.y, _e10287.z, 1f);
                                                        }
                                                    } else {
                                                        let _e10293 = mode_7;
                                                        if (_e10293 == 8i) {
                                                            {
                                                                let _e10298 = startScale_9;
                                                                scale2_11 = (_e10298 * 4f);
                                                                let _e10302 = scale2_11;
                                                                let _e10303 = scale_10;
                                                                invScaleRatio_11 = (_e10302 / _e10303);
                                                                let _e10306 = invScaleRatio_11;
                                                                let _e10310 = invScaleRatio_11;
                                                                let _e10319 = currentTransform_7;
                                                                tr_11 = (mat3x3<f32>(vec3<f32>(_e10306, 0f, 0f), vec3<f32>(0f, _e10310, 0f), vec3<f32>(0f, 0f, 1f)) * _e10319);
                                                                let _e10322 = tr_11;
                                                                let _e10323 = _uv_7;
                                                                let _e10324 = tf(_e10322, _e10323);
                                                                v_8 = (_e10324 - vec2(0.5f));
                                                                let _e10334 = inverseTileTransform_5[0];
                                                                let _e10338 = inverseTileTransform_5[0];
                                                                let _e10341 = piN_5;
                                                                let _e10344 = piN_5;
                                                                ang_38 = (floor((atan2(_e10334.y, _e10338.x) / _e10341)) * _e10344);
                                                                let _e10347 = ang_38;
                                                                let _e10348 = rotation2_(_e10347);
                                                                let _e10349 = v_8;
                                                                let _e10353 = inverseTileTransform_5[0];
                                                                let _e10360 = inverseTileTransform_5[2];
                                                                v_8 = (((_e10348 * _e10349) * length(_e10353.xy)) + (2f * _e10360.xy));
                                                                let _e10364 = v_8;
                                                                let _e10366 = v_8;
                                                                let _e10368 = rnd_7;
                                                                let _e10375 = Xn_5;
                                                                let _e10377 = floor(((_e10364.x + (_e10366.y * sign((_e10368.y - 0.5f)))) * _e10375));
                                                                k_40 = (_e10377 - (floor((_e10377 / 2f)) * 2f));
                                                                let _e10384 = k_40;
                                                                let _e10385 = vec3(_e10384);
                                                                outCol = vec4<f32>(_e10385.x, _e10385.y, _e10385.z, 1f);
                                                            }
                                                        } else {
                                                            let _e10391 = mode_7;
                                                            if (_e10391 == 9i) {
                                                                {
                                                                    let _e10398 = inverseTileTransform_5[2];
                                                                    N_26 = floor((1000f * pow(0.25f, length(_e10398.xy))));
                                                                    let _e10409 = N_26;
                                                                    let _e10414 = inverseTileTransform_5[1];
                                                                    let _e10418 = inverseTileTransform_5[1];
                                                                    offset_5 = ((1.5707964f + (3.1415927f / _e10409)) + atan2(_e10414.y, _e10418.x));
                                                                    let _e10423 = v_8;
                                                                    let _e10425 = v_8;
                                                                    ang_39 = atan2(_e10423.y, _e10425.x);
                                                                    let _e10429 = ang_39;
                                                                    let _e10430 = offset_5;
                                                                    let _e10434 = N_26;
                                                                    let _e10437 = N_26;
                                                                    let _e10441 = offset_5;
                                                                    ang_39 = (((round((((_e10429 - _e10430) / 6.2831855f) * _e10434)) / _e10437) * 6.2831855f) + _e10441);
                                                                    let _e10445 = inverseTileTransform_5[0];
                                                                    let _e10450 = ang_39;
                                                                    let _e10453 = ang_39;
                                                                    dist_10 = ((length(_e10445.xy) * 0.5f) / max(abs(cos(_e10450)), abs(sin(_e10453))));
                                                                    let _e10459 = dist_10;
                                                                    let _e10460 = ang_39;
                                                                    let _e10462 = ang_39;
                                                                    v_8 = (_e10459 * vec2<f32>(cos(_e10460), sin(_e10462)));
                                                                    let _e10466 = inverseCurrentTransform_7;
                                                                    let _e10467 = relId_7;
                                                                    let _e10468 = v_8;
                                                                    let _e10473 = tf(_e10466, (_e10467 + (_e10468 + vec2(0.5f))));
                                                                    u_11 = _e10473;
                                                                    let _e10475 = u_11;
                                                                    let _e10479 = global.U[0];
                                                                    let _e10482 = u_11;
                                                                    let _e10491 = _mirror_wrap(((vec2<f32>((_e10475.x / _e10479.x), _e10482.y) / vec2(2f)) + vec2(0.5f)));
                                                                    let _e10492 = textureSample(t_source, samp, _e10491);
                                                                    outCol = _e10492;
                                                                }
                                                            } else {
                                                                let _e10493 = mode_7;
                                                                if (_e10493 == 10i) {
                                                                    {
                                                                        let _e10498 = inverseTileTransform_5[0];
                                                                        s_11 = (length(_e10498.xy) * 0.05f);
                                                                        let _e10504 = v_8;
                                                                        v_8 = (_e10504 + vec2(0.5f));
                                                                        let _e10512 = inverseTileTransform_5[0];
                                                                        let _e10516 = inverseTileTransform_5[0];
                                                                        let _e10521 = N_27;
                                                                        let _e10526 = N_27;
                                                                        ang_40 = ((floor(((atan2(_e10512.y, _e10516.x) / 3.1415927f) * _e10521)) * 3.1415927f) / _e10526);
                                                                        let _e10529 = ang_40;
                                                                        let _e10530 = rotation2_(_e10529);
                                                                        let _e10531 = v_8;
                                                                        v_8 = (_e10530 * _e10531);
                                                                        let _e10533 = v_8;
                                                                        let _e10537 = inverseTileTransform_5[2];
                                                                        let _e10541 = tileTransform_5[0];
                                                                        let _e10549 = v_8;
                                                                        let _e10553 = inverseTileTransform_5[2];
                                                                        let _e10557 = tileTransform_5[0];
                                                                        let _e10564 = hslToRgb(vec4<f32>(((_e10533.x + (_e10537.x * length(_e10541.xy))) * 360f), 1f, (_e10549.y + (_e10553.y * length(_e10557.xy))), 1f));
                                                                        rgb_5 = _e10564;
                                                                        let _e10566 = _uv_7;
                                                                        let _e10570 = global.U[0];
                                                                        let _e10573 = _uv_7;
                                                                        let _e10582 = _mirror_wrap(((vec2<f32>((_e10566.x / _e10570.x), _e10573.y) / vec2(2f)) + vec2(0.5f)));
                                                                        let _e10583 = textureSample(t_source, samp, _e10582);
                                                                        inc_7 = _e10583;
                                                                        let _e10585 = inc_7;
                                                                        let _e10587 = rgb_5;
                                                                        dist_11 = length((_e10585.xyz - _e10587.xyz));
                                                                        let _e10595 = dist_11;
                                                                        let _e10597 = s_11;
                                                                        k_41 = (1f - (smoothstep(0f, 1.7f, _e10595) * _e10597));
                                                                        let _e10601 = inc_7;
                                                                        let _e10602 = rgb_5;
                                                                        let _e10603 = k_41;
                                                                        rgb_5 = mix(_e10601, _e10602, vec4(_e10603));
                                                                        let _e10606 = rgb_5;
                                                                        outCol = _e10606;
                                                                    }
                                                                } else {
                                                                    let _e10607 = mode_7;
                                                                    if (_e10607 == 11i) {
                                                                        {
                                                                            let _e10613 = inverseTileTransform_5[0];
                                                                            N_28 = round((4f * abs(_e10613.x)));
                                                                            let _e10620 = v_8;
                                                                            let _e10624 = N_28;
                                                                            let _e10627 = N_28;
                                                                            let _e10634 = N_28;
                                                                            center_22 = (vec2<f32>(0f, ((((floor(((_e10620.y + 0.5f) * _e10624)) / _e10627) * 2f) - 1f) + (1f / _e10634))) * 0.5f);
                                                                            let _e10641 = v_8;
                                                                            let _e10642 = center_22;
                                                                            dv_10 = abs((_e10641 - _e10642));
                                                                            let _e10646 = dv_10;
                                                                            let _e10650 = dv_10;
                                                                            let _e10653 = N_28;
                                                                            if ((_e10646.x < 0.45f) && (_e10650.y < (0.4f / _e10653))) {
                                                                                {
                                                                                    let _e10659 = inverseTileTransform_5[2];
                                                                                    s_12 = (_e10659.x + 1f);
                                                                                    let _e10664 = inverseCurrentTransform_7;
                                                                                    let _e10665 = relId_7;
                                                                                    let _e10666 = s_12;
                                                                                    let _e10676 = tf(_e10664, (_e10665 + ((_e10666 * vec2<f32>(0f, -0.5f)) + vec2(0.5f))));
                                                                                    u1_22 = _e10676;
                                                                                    let _e10678 = inverseCurrentTransform_7;
                                                                                    let _e10679 = relId_7;
                                                                                    let _e10680 = s_12;
                                                                                    let _e10689 = tf(_e10678, (_e10679 + ((_e10680 * vec2<f32>(0f, 0.5f)) + vec2(0.5f))));
                                                                                    u2_22 = _e10689;
                                                                                    let _e10691 = u1_22;
                                                                                    let _e10695 = global.U[0];
                                                                                    let _e10698 = u1_22;
                                                                                    let _e10707 = _mirror_wrap(((vec2<f32>((_e10691.x / _e10695.x), _e10698.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10708 = textureSample(t_source, samp, _e10707);
                                                                                    let _e10709 = u2_22;
                                                                                    let _e10713 = global.U[0];
                                                                                    let _e10716 = u2_22;
                                                                                    let _e10725 = _mirror_wrap(((vec2<f32>((_e10709.x / _e10713.x), _e10716.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10726 = textureSample(t_source, samp, _e10725);
                                                                                    let _e10727 = center_22;
                                                                                    outCol = mix(_e10708, _e10726, vec4((_e10727.y + 0.5f)));
                                                                                }
                                                                            }
                                                                        }
                                                                    } else {
                                                                        let _e10733 = mode_7;
                                                                        if (_e10733 == 12i) {
                                                                            {
                                                                                let _e10736 = v_8;
                                                                                v_8 = (_e10736 * vec2<f32>(2f, 2f));
                                                                                let _e10741 = inverseTileTransform_5;
                                                                                let _e10742 = v_8;
                                                                                let _e10743 = tf(_e10741, _e10742);
                                                                                v_8 = _e10743;
                                                                                let _e10744 = inverseCurrentTransform_7;
                                                                                let _e10745 = relId_7;
                                                                                let _e10746 = v_8;
                                                                                let _e10751 = tf(_e10744, (_e10745 + (_e10746 + vec2(0.5f))));
                                                                                let _e10755 = global.U[0];
                                                                                let _e10758 = inverseCurrentTransform_7;
                                                                                let _e10759 = relId_7;
                                                                                let _e10760 = v_8;
                                                                                let _e10765 = tf(_e10758, (_e10759 + (_e10760 + vec2(0.5f))));
                                                                                let _e10774 = _mirror_wrap(((vec2<f32>((_e10751.x / _e10755.x), _e10765.y) / vec2(2f)) + vec2(0.5f)));
                                                                                let _e10775 = textureSample(t_source, samp, _e10774);
                                                                                outCol = _e10775;
                                                                            }
                                                                        } else {
                                                                            let _e10776 = mode_7;
                                                                            if (_e10776 == 13i) {
                                                                                {
                                                                                    let _e10779 = _uv_7;
                                                                                    let _e10783 = global.U[0];
                                                                                    let _e10786 = _uv_7;
                                                                                    let _e10795 = _mirror_wrap(((vec2<f32>((_e10779.x / _e10783.x), _e10786.y) / vec2(2f)) + vec2(0.5f)));
                                                                                    let _e10796 = textureSample(t_source, samp, _e10795);
                                                                                    let _e10798 = luma(_e10796.xyz);
                                                                                    lum_15 = _e10798;
                                                                                    let _e10800 = inverseTileTransform_5;
                                                                                    let _e10801 = v_8;
                                                                                    let _e10806 = tf(_e10800, (_e10801 * vec2<f32>(8f, 8f)));
                                                                                    v_8 = _e10806;
                                                                                    let _e10807 = v_8;
                                                                                    let _e10810 = (_e10807.y + 1f);
                                                                                    y_5 = abs(((_e10810 - (floor((_e10810 / 2f)) * 2f)) - 1f));
                                                                                    let _e10820 = lum_15;
                                                                                    let _e10821 = y_5;
                                                                                    if (_e10820 > _e10821) {
                                                                                        local_43 = 1f;
                                                                                    } else {
                                                                                        local_43 = 0f;
                                                                                    }
                                                                                    let _e10826 = local_43;
                                                                                    k_42 = _e10826;
                                                                                    let _e10828 = k_42;
                                                                                    let _e10829 = vec3(_e10828);
                                                                                    outCol = vec4<f32>(_e10829.x, _e10829.y, _e10829.z, 1f);
                                                                                }
                                                                            } else {
                                                                                let _e10835 = mode_7;
                                                                                if (_e10835 == 14i) {
                                                                                    {
                                                                                        let _e10838 = id_5;
                                                                                        let _e10842 = global.U[0];
                                                                                        let _e10845 = id_5;
                                                                                        let _e10854 = _mirror_wrap(((vec2<f32>((_e10838.x / _e10842.x), _e10845.y) / vec2(2f)) + vec2(0.5f)));
                                                                                        let _e10855 = textureSample(t_source, samp, _e10854);
                                                                                        let _e10857 = luma(_e10855.xyz);
                                                                                        lum_16 = _e10857;
                                                                                        let _e10861 = tileTransform_5[0];
                                                                                        contrast_5 = length(_e10861.xy);
                                                                                        let _e10865 = v_8;
                                                                                        let _e10868 = (_e10865 + vec2(0.5f));
                                                                                        let _e10870 = contrast_5;
                                                                                        let _e10871 = lum_16;
                                                                                        outCol = vec4<f32>(_e10868.x, _e10868.y, (0.5f + (_e10870 * (_e10871 - 0.5f))), 1f);
                                                                                    }
                                                                                } else {
                                                                                    let _e10880 = mode_7;
                                                                                    if (_e10880 == 15i) {
                                                                                        {
                                                                                            let _e10883 = rnd_7;
                                                                                            center_23 = (sign((_e10883 - vec2(0.5f))) * 0.5f);
                                                                                            let _e10891 = v_8;
                                                                                            let _e10892 = center_23;
                                                                                            dv_11 = (_e10891 - _e10892);
                                                                                            let _e10898 = inverseTileTransform_5[0];
                                                                                            N_29 = floor((16f * length(_e10898.xy)));
                                                                                            let _e10906 = dv_11;
                                                                                            let _e10908 = dv_11;
                                                                                            let _e10911 = angOffset_5;
                                                                                            ang_41 = (atan2(_e10906.y, _e10908.x) + _e10911);
                                                                                            let _e10914 = ang_41;
                                                                                            let _e10917 = N_29;
                                                                                            let _e10920 = (((_e10914 / 3.1415927f) * _e10917) * 2f);
                                                                                            k_43 = abs(((_e10920 - (floor((_e10920 / 2f)) * 2f)) - 1f));
                                                                                            let _e10932 = inverseTileTransform_5[0];
                                                                                            let _e10936 = inverseTileTransform_5[0];
                                                                                            kCol_5 = (atan2(_e10932.y, _e10936.x) / 3.1415927f);
                                                                                            loop {
                                                                                                let _e10946 = i_15;
                                                                                                if !((_e10946 < 5i)) {
                                                                                                    break;
                                                                                                }
                                                                                                {
                                                                                                    let _e10953 = inverseCurrentTransform_7;
                                                                                                    let _e10954 = relId_7;
                                                                                                    let _e10957 = i_15;
                                                                                                    let _e10961 = ang_41;
                                                                                                    let _e10963 = ang_41;
                                                                                                    let _e10968 = tf(_e10953, (_e10954 + ((0.1f + (0.15f * f32(_e10957))) * vec2<f32>(cos(_e10961), sin(_e10963)))));
                                                                                                    w_23 = _e10968;
                                                                                                    let _e10970 = lum_17;
                                                                                                    let _e10971 = w_23;
                                                                                                    let _e10975 = global.U[0];
                                                                                                    let _e10978 = w_23;
                                                                                                    let _e10987 = _mirror_wrap(((vec2<f32>((_e10971.x / _e10975.x), _e10978.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e10988 = textureSample(t_source, samp, _e10987);
                                                                                                    let _e10990 = luma(_e10988.xyz);
                                                                                                    lum_17 = (_e10970 + _e10990);
                                                                                                }
                                                                                                continuing {
                                                                                                    let _e10950 = i_15;
                                                                                                    i_15 = (_e10950 + 1i);
                                                                                                }
                                                                                            }
                                                                                            let _e10992 = lum_17;
                                                                                            lum_17 = (_e10992 / 5f);
                                                                                            let _e10995 = lum_17;
                                                                                            let _e10996 = k_43;
                                                                                            if (_e10995 > _e10996) {
                                                                                                local_44 = 1f;
                                                                                            } else {
                                                                                                local_44 = 0f;
                                                                                            }
                                                                                            let _e11001 = local_44;
                                                                                            k_43 = _e11001;
                                                                                            let _e11002 = kCol_5;
                                                                                            if (_e11002 == 0f) {
                                                                                                {
                                                                                                    let _e11005 = k_43;
                                                                                                    let _e11006 = vec3(_e11005);
                                                                                                    outCol = vec4<f32>(_e11006.x, _e11006.y, _e11006.z, 1f);
                                                                                                }
                                                                                            } else {
                                                                                                {
                                                                                                    let _e11014 = inverseTileTransform_5[2];
                                                                                                    u1_23 = vec2<f32>(_e11014.x, 0f);
                                                                                                    let _e11022 = inverseTileTransform_5[2];
                                                                                                    u2_23 = vec2<f32>(0f, _e11022.y);
                                                                                                    let _e11026 = kCol_5;
                                                                                                    if (_e11026 > 0f) {
                                                                                                        {
                                                                                                            let _e11029 = u1_23;
                                                                                                            let _e11030 = id_5;
                                                                                                            u1_23 = (_e11029 + _e11030);
                                                                                                            let _e11032 = u2_23;
                                                                                                            let _e11033 = id_5;
                                                                                                            u2_23 = (_e11032 + (_e11033 + vec2(1f)));
                                                                                                        }
                                                                                                    }
                                                                                                    let _e11038 = u1_23;
                                                                                                    let _e11042 = global.U[0];
                                                                                                    let _e11045 = u1_23;
                                                                                                    let _e11054 = _mirror_wrap(((vec2<f32>((_e11038.x / _e11042.x), _e11045.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e11055 = textureSample(t_source, samp, _e11054);
                                                                                                    col1_19 = _e11055;
                                                                                                    let _e11057 = u2_23;
                                                                                                    let _e11061 = global.U[0];
                                                                                                    let _e11064 = u2_23;
                                                                                                    let _e11073 = _mirror_wrap(((vec2<f32>((_e11057.x / _e11061.x), _e11064.y) / vec2(2f)) + vec2(0.5f)));
                                                                                                    let _e11074 = textureSample(t_source, samp, _e11073);
                                                                                                    col2_19 = _e11074;
                                                                                                    let _e11076 = col1_19;
                                                                                                    let _e11078 = luma(_e11076.xyz);
                                                                                                    let _e11079 = col2_19;
                                                                                                    let _e11081 = luma(_e11079.xyz);
                                                                                                    if (_e11078 > _e11081) {
                                                                                                        let _e11084 = k_43;
                                                                                                        k_43 = (1f - _e11084);
                                                                                                    }
                                                                                                    let _e11086 = k_43;
                                                                                                    let _e11087 = vec3(_e11086);
                                                                                                    outCol1_5 = vec4<f32>(_e11087.x, _e11087.y, _e11087.z, 1f);
                                                                                                    let _e11094 = col1_19;
                                                                                                    let _e11095 = col2_19;
                                                                                                    let _e11096 = k_43;
                                                                                                    outCol2_5 = mix(_e11094, _e11095, vec4(_e11096));
                                                                                                    let _e11100 = outCol1_5;
                                                                                                    let _e11101 = outCol2_5;
                                                                                                    let _e11102 = kCol_5;
                                                                                                    outCol = mix(_e11100, _e11101, vec4(abs(_e11102)));
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
    let _e11106 = col;
    let _e11107 = outCol;
    let _e11108 = mergeColor(_e11106, _e11107);
    col = _e11108;
    let _e11109 = col;
    return _e11109;
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
