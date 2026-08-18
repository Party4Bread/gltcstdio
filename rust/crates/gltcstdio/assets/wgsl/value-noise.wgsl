struct Params {
    U: array<vec4<f32>, 9>,
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

fn rand21_(v: vec2<f32>) -> f32 {
    var v_1: vec2<f32>;

    v_1 = v;
    let _e7 = v_1;
    return fract((sin(dot(_e7.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
}

fn interpolatedRand21_(v_2: vec2<f32>) -> f32 {
    var v_3: vec2<f32>;
    var fractY: f32;

    v_3 = v_2;
    let _e7 = v_3;
    fractY = fract(_e7.y);
    let _e11 = v_3;
    let _e13 = rand21_(floor(_e11));
    let _e14 = v_3;
    let _e17 = v_3;
    let _e21 = rand21_(vec2<f32>(floor(_e14.x), ceil(_e17.y)));
    let _e22 = fractY;
    let _e24 = v_3;
    let _e27 = v_3;
    let _e31 = rand21_(vec2<f32>(ceil(_e24.x), floor(_e27.y)));
    let _e32 = v_3;
    let _e34 = rand21_(ceil(_e32));
    let _e35 = fractY;
    let _e37 = v_3;
    return mix(mix(_e13, _e21, _e22), mix(_e31, _e34, _e35), fract(_e37.x));
}

fn fractalValueNoise(v_4: vec2<f32>, count: i32, intensity: f32) -> f32 {
    var v_5: vec2<f32>;
    var count_1: i32;
    var intensity_1: f32;
    var s: f32 = 1f;
    var k: f32;
    var total: f32;
    var totalMul: f32 = 0f;
    var i: i32 = 0i;

    v_5 = v_4;
    count_1 = count;
    intensity_1 = intensity;
    let _e13 = intensity_1;
    k = _e13;
    loop {
        let _e20 = i;
        let _e21 = count_1;
        if !((_e20 < _e21)) {
            break;
        }
        {
            let _e27 = total;
            let _e28 = k;
            let _e29 = v_5;
            let _e30 = s;
            let _e32 = interpolatedRand21_((_e29 * _e30));
            total = (_e27 + (_e28 * _e32));
            let _e35 = totalMul;
            let _e36 = k;
            totalMul = (_e35 + _e36);
            let _e38 = k;
            k = (_e38 * 0.5f);
            let _e41 = s;
            s = (_e41 * 2.1055472f);
        }
        continuing {
            let _e24 = i;
            i = (_e24 + 1i);
        }
    }
    let _e44 = total;
    let _e45 = totalMul;
    return (_e44 / _e45);
}

fn valueNoise(pos: vec2<f32>, outPos: vec2<f32>, viewTransform: mat3x3<f32>, octaves: i32, color1_: vec4<f32>, color2_: vec4<f32>, contrast: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var viewTransform_1: mat3x3<f32>;
    var octaves_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var contrast_1: f32;
    var x: f32;
    var col: vec4<f32>;
    var local: f32;
    var c: f32;

    pos_1 = pos;
    outPos_1 = outPos;
    viewTransform_1 = viewTransform;
    octaves_1 = octaves;
    color1_1 = color1_;
    color2_1 = color2_;
    contrast_1 = contrast;
    let _e19 = pos_1;
    let _e20 = octaves_1;
    let _e22 = fractalValueNoise(_e19, _e20, 1f);
    x = _e22;
    let _e24 = color1_1;
    let _e25 = color2_1;
    let _e26 = x;
    col = mix(_e24, _e25, vec4(_e26));
    let _e30 = contrast_1;
    if (_e30 != 0f) {
        {
            let _e33 = contrast_1;
            if (abs(_e33) > 1f) {
                let _e37 = contrast_1;
                let _e39 = contrast_1;
                local = (sign(_e37) * pow(abs(_e39), 2f));
            } else {
                let _e44 = contrast_1;
                local = _e44;
            }
            let _e46 = local;
            c = _e46;
            let _e48 = col;
            let _e50 = col;
            let _e55 = c;
            let _e59 = (((_e50.xyz - vec3(0.5f)) * _e55) + vec3(0.5f));
            col.x = _e59.x;
            col.y = _e59.y;
            col.z = _e59.z;
        }
    }
    let _e66 = col;
    return _e66;
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
    let _e65 = global.U[1];
    let _e66 = _e65.xyz;
    let _e69 = global.U[2];
    let _e70 = _e69.xyz;
    let _e73 = global.U[3];
    let _e74 = _e73.xyz;
    let _e90 = global.U[5];
    let _e95 = global.U[6];
    let _e98 = global.U[7];
    let _e101 = global.U[8];
    let _e103 = valueNoise((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), mat3x3<f32>(vec3<f32>(_e66.x, _e66.y, _e66.z), vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z)), i32(_e90.x), _e95, _e98, _e101.x);
    fragColor = _e103;
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
