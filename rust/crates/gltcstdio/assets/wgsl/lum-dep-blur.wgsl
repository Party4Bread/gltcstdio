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
    let _e42 = textureSample(t_source, samp, _e41);
    let _e44 = luma(_e42.xyz);
    let _e46 = power_1;
    lum = pow(_e44, pow(1.1f, _e46));
    let _e50 = lum;
    k = _e50;
    let _e52 = radius_1;
    let _e53 = k;
    radius_1 = (_e52 * _e53);
    let _e58 = total;
    let _e59 = total;
    total = (_e58 * _e59);
    let _e63 = radius_1;
    let _e64 = pixel;
    N = i32(ceil((_e63 / _e64)));
    let _e69 = pixel;
    step = _e69;
    let _e73 = N;
    j = -(_e73);
    loop {
        let _e76 = j;
        let _e77 = N;
        if !((_e76 <= _e77)) {
            break;
        }
        {
            let _e83 = N;
            i = -(_e83);
            loop {
                let _e86 = i;
                let _e87 = N;
                if !((_e86 <= _e87)) {
                    break;
                }
                {
                    let _e93 = pixel;
                    let _e94 = i;
                    let _e96 = j;
                    delta = (_e93 * vec2<f32>(f32(_e94), f32(_e96)));
                    let _e101 = uv_1;
                    let _e102 = delta;
                    let _e107 = global.U[0];
                    let _e110 = uv_1;
                    let _e111 = delta;
                    let _e121 = _mirror_wrap(((vec2<f32>(((_e101 + _e102).x / _e107.x), (_e110 + _e111).y) / vec2(2f)) + vec2(0.5f)));
                    let _e122 = textureSample(t_source, samp, _e121);
                    col = _e122;
                    let _e124 = total;
                    let _e125 = col;
                    let _e126 = col;
                    total = (_e124 + (_e125 * _e126));
                    let _e129 = div;
                    div = (_e129 + 1f);
                }
                continuing {
                    let _e90 = i;
                    i = (_e90 + 1i);
                }
            }
        }
        continuing {
            let _e80 = j;
            j = (_e80 + 1i);
        }
    }
    let _e132 = total;
    let _e133 = div;
    return sqrt((_e132 / vec4(_e133)));
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
