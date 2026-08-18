struct Params {
    U: array<vec4<f32>, 12>,
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

fn luma(c_2: vec3<f32>) -> f32 {
    var c_3: vec3<f32>;

    c_3 = c_2;
    let _e9 = c_3;
    let _e13 = c_3;
    let _e18 = c_3;
    return (((0.2989f * _e9.x) + (0.587f * _e13.y)) + (0.114f * _e18.z));
}

fn lumDepBlur(uv: vec2<f32>, outPos: vec2<f32>, radius: f32, power: f32, hardness: f32, sourceDim: vec2<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_1: f32;
    var power_1: f32;
    var hardness_1: f32;
    var sourceDim_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var pixel: f32;
    var lum: f32;
    var k: f32;
    var total: vec4<f32> = vec4(0f);
    var div: f32 = 0f;
    var N: i32;
    var step: f32;
    var gInv: f32 = 1f;
    var j: i32;
    var i: i32;
    var delta: vec2<f32>;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    radius_1 = radius;
    power_1 = power;
    hardness_1 = hardness;
    sourceDim_1 = sourceDim;
    modelTransform_1 = modelTransform;
    let _e21 = sourceDim_1;
    pixel = (2f / _e21.y);
    let _e25 = uv_1;
    let _e29 = global.U[0];
    let _e32 = uv_1;
    let _e41 = _mirror_wrap(((vec2<f32>((_e25.x / _e29.x), _e32.y) / vec2(2f)) + vec2(0.5f)));
    let _e43 = textureSampleLevel(t_source, samp, _e41, 0f);
    let _e45 = luma(_e43.xyz);
    let _e47 = power_1;
    lum = pow(_e45, pow(1.1f, _e47));
    let _e51 = lum;
    k = _e51;
    let _e53 = radius_1;
    let _e54 = k;
    radius_1 = (_e53 * _e54);
    let _e59 = total;
    let _e60 = total;
    total = (_e59 * _e60);
    let _e64 = radius_1;
    let _e65 = pixel;
    N = i32(ceil((_e64 / _e65)));
    let _e70 = pixel;
    step = _e70;
    let _e74 = N;
    j = -(_e74);
    loop {
        let _e77 = j;
        let _e78 = N;
        if !((_e77 <= _e78)) {
            break;
        }
        {
            let _e84 = N;
            i = -(_e84);
            loop {
                let _e87 = i;
                let _e88 = N;
                if !((_e87 <= _e88)) {
                    break;
                }
                {
                    let _e94 = pixel;
                    let _e95 = i;
                    let _e97 = j;
                    delta = (_e94 * vec2<f32>(f32(_e95), f32(_e97)));
                    let _e102 = uv_1;
                    let _e103 = delta;
                    let _e108 = global.U[0];
                    let _e111 = uv_1;
                    let _e112 = delta;
                    let _e122 = _mirror_wrap(((vec2<f32>(((_e102 + _e103).x / _e108.x), (_e111 + _e112).y) / vec2(2f)) + vec2(0.5f)));
                    let _e124 = textureSampleLevel(t_source, samp, _e122, 0f);
                    col = _e124;
                    let _e126 = total;
                    let _e127 = col;
                    let _e128 = col;
                    total = (_e126 + (_e127 * _e128));
                    let _e131 = div;
                    div = (_e131 + 1f);
                }
                continuing {
                    let _e91 = i;
                    i = (_e91 + 1i);
                }
            }
        }
        continuing {
            let _e81 = j;
            j = (_e81 + 1i);
        }
    }
    let _e134 = total;
    let _e135 = div;
    return sqrt((_e134 / vec4(_e135)));
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
    let _e66 = global.U[6];
    let _e70 = global.U[7];
    let _e74 = global.U[8];
    let _e78 = global.U[4];
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = lumDepBlur((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.xy, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
