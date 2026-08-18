struct Params {
    U: array<vec4<f32>, 7>,
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

fn rgbToHcv(RGB: vec4<f32>) -> vec4<f32> {
    var RGB_1: vec4<f32>;
    var local: vec4<f32>;
    var P: vec4<f32>;
    var local_1: vec4<f32>;
    var Q: vec4<f32>;
    var C: f32;
    var H: f32;

    RGB_1 = RGB;
    let _e8 = RGB_1;
    let _e10 = RGB_1;
    if (_e8.y < _e10.z) {
        let _e13 = RGB_1;
        let _e14 = _e13.zy;
        local = vec4<f32>(_e14.x, _e14.y, -1f, 0.6666667f);
    } else {
        let _e23 = RGB_1;
        let _e24 = _e23.yz;
        local = vec4<f32>(_e24.x, _e24.y, 0f, -0.33333334f);
    }
    let _e34 = local;
    P = _e34;
    let _e36 = RGB_1;
    let _e38 = P;
    if (_e36.x < _e38.x) {
        let _e41 = P;
        let _e42 = _e41.xyw;
        let _e43 = RGB_1;
        local_1 = vec4<f32>(_e42.x, _e42.y, _e42.z, _e43.x);
    } else {
        let _e49 = RGB_1;
        let _e51 = P;
        let _e52 = _e51.yzx;
        local_1 = vec4<f32>(_e49.x, _e52.x, _e52.y, _e52.z);
    }
    let _e58 = local_1;
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

fn findMaxXYGL(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, phase: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var phase_1: f32;
    var inCol: vec4<f32>;
    var N: i32 = 25i;
    var delta: f32;
    var col: vec4<f32>;
    var step: vec2<f32>;
    var i: i32;
    var a: vec4<f32>;
    var b: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    phase_1 = phase;
    let _e14 = pos_1;
    let _e18 = global.U[0];
    let _e21 = pos_1;
    let _e30 = _mirror_wrap(((vec2<f32>((_e14.x / _e18.x), _e21.y) / vec2(2f)) + vec2(0.5f)));
    let _e31 = textureSample(t_source, samp, _e30);
    inCol = _e31;
    let _e35 = intensity_1;
    delta = (_e35 * 0.02f);
    let _e39 = inCol;
    col = _e39;
    let _e41 = phase_1;
    let _e43 = phase_1;
    let _e45 = phase_1;
    let _e47 = phase_1;
    let _e53 = delta;
    step = (mat2x2<f32>(vec2<f32>(cos(_e41), sin(_e43)), vec2<f32>(sin(_e45), -(cos(_e47)))) * vec2<f32>(_e53, 0f));
    let _e58 = N;
    i = -(_e58);
    loop {
        let _e61 = i;
        let _e62 = N;
        if !((_e61 < _e62)) {
            break;
        }
        {
            let _e68 = pos_1;
            let _e69 = i;
            let _e71 = step;
            let _e77 = global.U[0];
            let _e80 = pos_1;
            let _e81 = i;
            let _e83 = step;
            let _e94 = _mirror_wrap(((vec2<f32>(((_e68 + (f32(_e69) * _e71)).x / _e77.x), (_e80 + (f32(_e81) * _e83)).y) / vec2(2f)) + vec2(0.5f)));
            let _e95 = textureSample(t_source, samp, _e94);
            a = _e95;
            let _e97 = a;
            let _e98 = rgbToHsl(_e97);
            let _e100 = col;
            let _e101 = rgbToHsl(_e100);
            if (_e98.y > _e101.y) {
                let _e104 = a;
                col = _e104;
            }
            let _e105 = pos_1;
            let _e106 = i;
            let _e108 = step;
            let _e110 = step;
            let _e119 = global.U[0];
            let _e122 = pos_1;
            let _e123 = i;
            let _e125 = step;
            let _e127 = step;
            let _e141 = _mirror_wrap(((vec2<f32>(((_e105 + (f32(_e106) * vec2<f32>(_e108.y, -(_e110.x)))).x / _e119.x), (_e122 + (f32(_e123) * vec2<f32>(_e125.y, -(_e127.x)))).y) / vec2(2f)) + vec2(0.5f)));
            let _e142 = textureSample(t_source, samp, _e141);
            b = _e142;
            let _e144 = b;
            let _e145 = rgbToHsl(_e144);
            let _e147 = col;
            let _e148 = rgbToHsl(_e147);
            if (_e145.y > _e148.y) {
                let _e151 = b;
                col = _e151;
            }
        }
        continuing {
            let _e65 = i;
            i = (_e65 + 1i);
        }
    }
    let _e152 = col;
    return _e152;
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
    let _e72 = findMaxXYGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x);
    fragColor = _e72;
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
