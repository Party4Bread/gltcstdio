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
var t_source1_: texture_2d<f32>;
@group(0) @binding(3) 
var t_source2_: texture_2d<f32>;

fn mergeColor(bkg: vec4<f32>, front: vec4<f32>) -> vec4<f32> {
    var bkg_1: vec4<f32>;
    var front_1: vec4<f32>;

    bkg_1 = bkg;
    front_1 = front;
    let _e11 = bkg_1;
    let _e13 = front_1;
    let _e15 = front_1;
    let _e18 = bkg_1;
    let _e22 = front_1;
    let _e28 = mix(_e11.xyz, _e13.xyz, vec3((_e15.w + ((1f - _e18.w) * (1f - _e22.w)))));
    let _e29 = bkg_1;
    let _e31 = front_1;
    return vec4<f32>(_e28.x, _e28.y, _e28.z, max(_e29.w, _e31.w));
}

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local: vec4<f32>;
    var P: vec4<f32>;
    var local_1: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e9 = RGB_1;
    let _e11 = RGB_1;
    if (_e9.y < _e11.z) {
        let _e14 = RGB_1;
        let _e15 = _e14.zy;
        local = vec4<f32>(_e15.x, _e15.y, -1f, 0.6666667f);
    } else {
        let _e24 = RGB_1;
        let _e25 = _e24.yz;
        local = vec4<f32>(_e25.x, _e25.y, 0f, -0.33333334f);
    }
    let _e35 = local;
    P = _e35;
    let _e37 = RGB_1;
    let _e39 = P;
    if (_e37.x < _e39.x) {
        let _e42 = P;
        let _e43 = _e42.xyw;
        let _e44 = RGB_1;
        local_1 = vec4<f32>(_e43.x, _e43.y, _e43.z, _e44.x);
    } else {
        let _e50 = RGB_1;
        let _e52 = P;
        let _e53 = _e52.yzx;
        local_1 = vec4<f32>(_e50.x, _e53.x, _e53.y, _e53.z);
    }
    let _e59 = local_1;
    Q = _e59;
    let _e61 = Q;
    let _e63 = Q;
    let _e65 = Q;
    C = (_e61.x - min(_e63.w, _e65.y));
    let _e70 = Q;
    let _e72 = Q;
    let _e76 = C;
    let _e81 = Q;
    H = abs((((_e70.w - _e72.y) / ((6f * _e76) + 0.0000000001f)) + _e81.z));
    let _e86 = H;
    let _e87 = C;
    let _e88 = Q;
    let _e90 = RGB_1;
    return vec4<f32>(_e86, _e87, _e88.x, _e90.w);
}

fn rgbToHsl(RGB_2: vec4<f32>) -> vec4<f32> {
    var RGB_3: vec4<f32>;
    var HCV: vec4<f32>;
    var L: f32;
    var S: f32;

    RGB_3 = RGB_2;
    let _e9 = RGB_3;
    let _e10 = rgbToHcv(_e9);
    HCV = _e10;
    let _e12 = HCV;
    let _e14 = HCV;
    L = (_e12.z - (_e14.y * 0.5f));
    let _e20 = HCV;
    let _e23 = L;
    S = (_e20.y / ((1f - abs(((_e23 * 2f) - 1f))) + 0.000001f));
    let _e34 = HCV;
    let _e38 = S;
    let _e39 = L;
    let _e40 = RGB_3;
    return vec4<f32>((_e34.x * 360f), _e38, _e39, _e40.w);
}

fn selectByHue(pos: vec2<f32>, outPos: vec2<f32>, colorIn: vec4<f32>, colorOut: vec4<f32>, source2_specified: i32, saturation: f32, tolerance: f32, hardness: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var source2_specified_1: i32;
    var saturation_1: f32;
    var tolerance_1: f32;
    var hardness_1: f32;
    var col1_: vec4<f32>;
    var local_2: vec4<f32>;
    var col2_: vec4<f32>;
    var col1Sat: f32;
    var d: f32;
    var maxD: f32;
    var local_3: f32;
    var k: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    source2_specified_1 = source2_specified;
    saturation_1 = saturation;
    tolerance_1 = tolerance;
    hardness_1 = hardness;
    let _e23 = pos_1;
    let _e27 = global.U[0];
    let _e30 = pos_1;
    let _e39 = textureSample(t_source1_, samp, ((vec2<f32>((_e23.x / _e27.x), _e30.y) / vec2(2f)) + vec2(0.5f)));
    col1_ = _e39;
    let _e41 = source2_specified_1;
    if (_e41 == 1i) {
        let _e44 = pos_1;
        let _e48 = global.U[0];
        let _e51 = pos_1;
        let _e60 = textureSample(t_source2_, samp, ((vec2<f32>((_e44.x / _e48.x), _e51.y) / vec2(2f)) + vec2(0.5f)));
        local_2 = _e60;
    } else {
        let _e61 = col1_;
        local_2 = _e61;
    }
    let _e63 = local_2;
    col2_ = _e63;
    let _e65 = col1_;
    let _e66 = rgbToHsl(_e65);
    col1Sat = _e66.y;
    let _e69 = col1Sat;
    let _e70 = saturation_1;
    d = abs((_e69 - _e70));
    let _e74 = tolerance_1;
    maxD = _e74;
    let _e76 = d;
    let _e77 = maxD;
    d = (_e76 / _e77);
    let _e79 = hardness_1;
    if (_e79 == 1f) {
        let _e84 = d;
        local_3 = step(-1f, -(_e84));
    } else {
        let _e88 = hardness_1;
        let _e89 = d;
        local_3 = smoothstep(1f, _e88, _e89);
    }
    let _e92 = local_3;
    k = _e92;
    let _e94 = col1_;
    let _e95 = colorOut_1;
    let _e96 = mergeColor(_e94, _e95);
    let _e97 = col2_;
    let _e98 = colorIn_1;
    let _e99 = mergeColor(_e97, _e98);
    let _e100 = k;
    return mix(_e96, _e99, vec4(_e100));
}

fn main_1() {
    let _e9 = global.U[1];
    let _e10 = _e9.xyz;
    let _e13 = global.U[2];
    let _e14 = _e13.xyz;
    let _e17 = global.U[3];
    let _e18 = _e17.xyz;
    let _e33 = v_uv_1;
    let _e41 = global.U[0];
    let _e45 = (((_e33 - vec2(0.5f)) * 2f) * vec2<f32>(_e41.x, 1f));
    let _e52 = v_uv_1;
    let _e60 = global.U[0];
    let _e67 = global.U[6];
    let _e70 = global.U[7];
    let _e73 = global.U[4];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e86 = global.U[10];
    let _e88 = selectByHue((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e10.x, _e10.y, _e10.z), vec3<f32>(_e14.x, _e14.y, _e14.z), vec3<f32>(_e18.x, _e18.y, _e18.z))) * vec3<f32>(_e45.x, _e45.y, 1f)).xy, (((_e52 - vec2(0.5f)) * 2f) * vec2<f32>(_e60.x, 1f)), _e67, _e70, i32(_e73.x), _e78.x, _e82.x, _e86.x);
    fragColor = _e88;
    return;
}

@fragment 
fn main(@location(0) v_uv: vec2<f32>) -> FragmentOutput {
    v_uv_1 = v_uv;
    main_1();
    let _e15 = fragColor;
    return FragmentOutput(_e15);
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
