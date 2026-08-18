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

fn smix(a: f32, b: f32, k: f32) -> f32 {
    var a_1: f32;
    var b_1: f32;
    var k_1: f32;

    a_1 = a;
    b_1 = b;
    k_1 = k;
    let _e11 = a_1;
    let _e12 = b_1;
    let _e15 = k_1;
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

fn perlinNoise_1(pos: vec2<f32>, outPos: vec2<f32>, viewTransform: mat3x3<f32>, octaves: i32, color1_: vec4<f32>, color2_: vec4<f32>, contrast: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var viewTransform_1: mat3x3<f32>;
    var octaves_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var contrast_1: f32;
    var uv: vec2<f32>;
    var transform: mat2x2<f32> = mat2x2<f32>(vec2<f32>(1.7764293f, 1.1406322f), vec2<f32>(-1.1406322f, 1.7764293f));
    var k_2: f32 = 1f;
    var x: f32 = 0f;
    var total: f32 = 0f;
    var i: i32 = 0i;
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
    uv = _e19;
    loop {
        let _e55 = i;
        let _e56 = octaves_1;
        if !((_e55 < _e56)) {
            break;
        }
        {
            let _e62 = x;
            let _e63 = k_2;
            let _e64 = uv;
            let _e65 = perlinNoise(_e64);
            x = (_e62 + (_e63 * _e65));
            let _e68 = total;
            let _e69 = k_2;
            total = (_e68 + _e69);
            let _e71 = k_2;
            k_2 = (_e71 * 0.5f);
            let _e74 = transform;
            let _e75 = uv;
            uv = (_e74 * _e75);
        }
        continuing {
            let _e59 = i;
            i = (_e59 + 1i);
        }
    }
    let _e77 = x;
    let _e78 = total;
    x = (_e77 / _e78);
    let _e80 = color1_1;
    let _e81 = color2_1;
    let _e82 = x;
    col = mix(_e80, _e81, vec4(_e82));
    let _e86 = contrast_1;
    if (_e86 != 0f) {
        {
            let _e89 = contrast_1;
            if (abs(_e89) > 1f) {
                let _e93 = contrast_1;
                let _e95 = contrast_1;
                local = (sign(_e93) * pow(abs(_e95), 2f));
            } else {
                let _e100 = contrast_1;
                local = _e100;
            }
            let _e102 = local;
            c = _e102;
            let _e104 = col;
            let _e106 = col;
            let _e111 = c;
            let _e115 = (((_e106.xyz - vec3(0.5f)) * _e111) + vec3(0.5f));
            col.x = _e115.x;
            col.y = _e115.y;
            col.z = _e115.z;
        }
    }
    let _e122 = col;
    return _e122;
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
    let _e103 = perlinNoise_1((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)), mat3x3<f32>(vec3<f32>(_e66.x, _e66.y, _e66.z), vec3<f32>(_e70.x, _e70.y, _e70.z), vec3<f32>(_e74.x, _e74.y, _e74.z)), i32(_e90.x), _e95, _e98, _e101.x);
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
