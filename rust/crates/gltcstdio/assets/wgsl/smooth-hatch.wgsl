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

fn stepWiseSCurve(x: f32, k: f32) -> f32 {
    var x_1: f32;
    var k_1: f32;
    var y: f32;

    x_1 = x;
    k_1 = k;
    let _e10 = x_1;
    let _e12 = (_e10 + 1f);
    y = ((_e12 - (floor((_e12 / 2f)) * 2f)) - 1f);
    let _e21 = x_1;
    let _e29 = y;
    let _e31 = y;
    let _e34 = k_1;
    return ((floor(((_e21 * 0.5f) + 0.5f)) * 2f) + (sign(_e29) * pow(abs(_e31), pow(10f, _e34))));
}

fn triangleToSquareWave(x_2: f32, k_2: f32) -> f32 {
    var x_3: f32;
    var k_3: f32;
    var s: f32 = 1f;
    var local: f32;
    var m: f32;

    x_3 = x_2;
    k_3 = k_2;
    let _e10 = x_3;
    x_3 = (_e10 - (floor((_e10 / 4f)) * 4f));
    let _e18 = x_3;
    if (_e18 > 2f) {
        {
            let _e21 = x_3;
            x_3 = (_e21 - 2f);
            s = -1f;
        }
    }
    let _e26 = k_3;
    if (_e26 > 0f) {
        local = 1f;
    } else {
        let _e32 = k_3;
        let _e35 = k_3;
        local = pow(mix(5f, 40f, -(_e32)), -(_e35));
    }
    let _e39 = local;
    m = _e39;
    let _e41 = m;
    let _e42 = s;
    let _e45 = x_3;
    let _e50 = k_3;
    return ((_e41 * _e42) * (1f - pow(abs((_e45 - 1f)), pow(100f, _e50))));
}

fn smoothHatch(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, color1_: vec4<f32>, color2_: vec4<f32>, balance: f32, hardness: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var balance_1: f32;
    var hardness_1: f32;
    var k_4: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    color1_1 = color1_;
    color2_1 = color2_;
    balance_1 = balance;
    hardness_1 = hardness;
    let _e20 = uv_1;
    let _e24 = balance_1;
    let _e25 = stepWiseSCurve((_e20.x * 0.5f), _e24);
    let _e30 = hardness_1;
    let _e31 = triangleToSquareWave(((_e25 * 2f) - 1f), _e30);
    k_4 = ((_e31 * 0.5f) + 0.5f);
    let _e37 = color1_1;
    let _e38 = color2_1;
    let _e39 = k_4;
    outColor = mix(_e37, _e38, vec4(_e39));
    let _e43 = source_specified_1;
    if (_e43 == 1i) {
        let _e46 = outPos_1;
        let _e50 = global.U[0];
        let _e53 = outPos_1;
        let _e62 = textureSample(t_source, samp, ((vec2<f32>((_e46.x / _e50.x), _e53.y) / vec2(2f)) + vec2(0.5f)));
        let _e63 = outColor;
        let _e64 = mergeColor(_e62, _e63);
        return _e64;
    } else {
        let _e65 = outColor;
        return _e65;
    }
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
    let _e71 = global.U[6];
    let _e74 = global.U[7];
    let _e77 = global.U[8];
    let _e81 = global.U[9];
    let _e83 = smoothHatch((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71, _e74, _e77.x, _e81.x);
    fragColor = _e83;
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
