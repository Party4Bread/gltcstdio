struct Params {
    U: array<vec4<f32>, 10>,
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

fn rand2_(v: vec2<f32>) -> vec2<f32> {
    var v_1: vec2<f32>;
    var x: f32;
    var y: f32;

    v_1 = v;
    let _e8 = v_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = v_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return vec2<f32>(_e32, _e33);
}

fn interpolatedRand2_(v_2: vec2<f32>) -> vec2<f32> {
    var v_3: vec2<f32>;
    var fractY: f32;

    v_3 = v_2;
    let _e8 = v_3;
    fractY = fract(_e8.y);
    let _e12 = v_3;
    let _e14 = rand2_(floor(_e12));
    let _e15 = v_3;
    let _e18 = v_3;
    let _e22 = rand2_(vec2<f32>(floor(_e15.x), ceil(_e18.y)));
    let _e23 = fractY;
    let _e26 = v_3;
    let _e29 = v_3;
    let _e33 = rand2_(vec2<f32>(ceil(_e26.x), floor(_e29.y)));
    let _e34 = v_3;
    let _e36 = rand2_(ceil(_e34));
    let _e37 = fractY;
    let _e40 = v_3;
    return mix(mix(_e14, _e22, vec2(_e23)), mix(_e33, _e36, vec2(_e37)), vec2(fract(_e40.x)));
}

fn fractalValueNoiseDisplace(u: vec2<f32>, v_4: vec2<f32>, count: i32, intensity: f32) -> vec2<f32> {
    var u_1: vec2<f32>;
    var v_5: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var s: f32 = 1f;
    var maxDisplacement: f32;
    var totalDisp: vec2<f32> = vec2(0f);
    var i: i32 = 0i;
    var disp: vec2<f32>;

    u_1 = u;
    v_5 = v_4;
    count_1 = count;
    intensity_1 = intensity;
    let _e16 = intensity_1;
    maxDisplacement = _e16;
    loop {
        let _e23 = i;
        let _e24 = count_1;
        if !((_e23 < _e24)) {
            break;
        }
        {
            let _e30 = v_5;
            let _e31 = s;
            let _e33 = interpolatedRand2_((_e30 * _e31));
            disp = _e33;
            let _e35 = totalDisp;
            let _e36 = maxDisplacement;
            let _e37 = disp;
            totalDisp = (_e35 + ((_e36 * (_e37 - vec2<f32>(0.5f, 0.5f))) * 2f));
            let _e46 = maxDisplacement;
            maxDisplacement = (_e46 * 0.5f);
            let _e49 = s;
            s = (_e49 * 2.1055472f);
        }
        continuing {
            let _e27 = i;
            i = (_e27 + 1i);
        }
    }
    let _e52 = u_1;
    let _e53 = totalDisp;
    return (_e52 + _e53);
}

fn marble(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, iterations: i32, intensity_2: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var iterations_1: i32;
    var intensity_3: f32;
    var t: vec2<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    iterations_1 = iterations;
    intensity_3 = intensity_2;
    let _e16 = modelTransform_1;
    let _e18 = pos_1;
    t = (_naga_inverse_3x3_f32(_e16) * vec3<f32>(_e18.x, _e18.y, 1f)).xy;
    let _e26 = intensity_3;
    if (_e26 != 0f) {
        {
            let _e29 = pos_1;
            let _e30 = t;
            let _e31 = iterations_1;
            let _e32 = intensity_3;
            let _e35 = fractalValueNoiseDisplace(_e29, _e30, _e31, (_e32 * 2f));
            pos_1 = _e35;
        }
    }
    let _e36 = pos_1;
    let _e40 = global.U[0];
    let _e43 = pos_1;
    let _e52 = _mirror_wrap(((vec2<f32>((_e36.x / _e40.x), _e43.y) / vec2(2f)) + vec2(0.5f)));
    let _e53 = textureSample(t_source, samp, _e52);
    return _e53;
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
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e96 = global.U[9];
    let _e98 = marble((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), i32(_e91.x), _e96.x);
    fragColor = _e98;
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
