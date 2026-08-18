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

fn hash21_(p: vec2<f32>) -> f32 {
    var p_1: vec2<f32>;
    var a: vec2<f32>;
    var b: vec2<f32>;

    p_1 = p;
    let _e10 = p_1;
    a = fract((-45.3277f * _e10.xy));
    let _e15 = a;
    let _e16 = a;
    let _e17 = a;
    b = (_e15 + vec2(dot(_e16, (_e17 + vec2(123.3371f)))));
    let _e25 = b;
    let _e27 = b;
    return fract((_e25.x * _e27.y));
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

fn max2_(u_2: vec2<f32>) -> f32 {
    var u_3: vec2<f32>;

    u_3 = u_2;
    let _e8 = u_3;
    let _e10 = u_3;
    return max(_e8.x, _e10.y);
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

fn squareLand(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, iterations: i32, coverage: f32, color: vec4<f32>, colorBkg: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var iterations_1: i32;
    var coverage_1: f32;
    var color_1: vec4<f32>;
    var colorBkg_1: vec4<f32>;
    var id: vec2<f32>;
    var col: vec4<f32>;
    var X: f32;
    var levels: f32;
    var i: i32 = 0i;
    var rnd: vec2<f32>;
    var d: f32;
    var d1_: f32;
    var d2_: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    iterations_1 = iterations;
    coverage_1 = coverage;
    color_1 = color;
    colorBkg_1 = colorBkg;
    let _e20 = uv_1;
    id = floor(_e20);
    let _e23 = colorBkg_1;
    col = _e23;
    let _e25 = id;
    X = (_e25.y - (floor((_e25.y / 64f)) * 64f));
    let _e33 = X;
    if (_e33 < 16f) {
        let _e37 = id;
        let _e39 = id;
        let _e41 = (_e37.x + _e39.y);
        let _e47 = X;
        let _e51 = vec3(mix(0.1f, (_e41 - (floor((_e41 / 2f)) * 2f)), (_e47 * 0.1f)));
        col = vec4<f32>(_e51.x, _e51.y, _e51.z, 1f);
    }
    let _e59 = iterations_1;
    levels = (2f * pow(2f, f32(_e59)));
    let _e64 = uv_1;
    let _e65 = levels;
    uv_1 = (_e64 / vec2(_e65));
    loop {
        let _e70 = i;
        let _e71 = iterations_1;
        if !((_e70 < _e71)) {
            break;
        }
        {
            let _e77 = uv_1;
            id = floor(_e77);
            let _e79 = id;
            let _e80 = hash22_(_e79);
            rnd = _e80;
            let _e82 = uv_1;
            let _e88 = max2_(abs((fract(_e82) - vec2(0.5f))));
            d = _e88;
            let _e90 = rnd;
            let _e92 = levels;
            let _e95 = levels;
            d1_ = (round((_e90.x * _e92)) / (_e95 * 2f));
            let _e100 = rnd;
            d2_ = (_e100.y * 0.5f);
            let _e105 = id;
            let _e106 = hash21_(_e105);
            let _e107 = coverage_1;
            let _e109 = d;
            let _e111 = levels;
            let _e113 = d1_;
            if ((_e106 < _e107) && (_e109 > max((1f / _e111), _e113))) {
                {
                    let _e117 = rnd;
                    let _e122 = rnd;
                    let _e124 = rnd;
                    col = vec4<f32>(fract((_e117.x * 10f)), _e122.y, fract((_e124.y * 10f)), 1f);
                    let _e131 = col;
                    let _e132 = col;
                    col = mix(_e131, round(_e132), vec4(0.5f));
                    let _e137 = col;
                    let _e138 = color_1;
                    let _e139 = mergeColor(_e137, _e138);
                    col = _e139;
                }
            }
            let _e140 = uv_1;
            uv_1 = (_e140 * 2f);
            let _e143 = levels;
            levels = (_e143 / 2f);
        }
        continuing {
            let _e74 = i;
            i = (_e74 + 1i);
        }
    }
    let _e146 = source_specified_1;
    if (_e146 == 1i) {
        let _e149 = outPos_1;
        let _e153 = global.U[0];
        let _e156 = outPos_1;
        let _e165 = textureSample(t_source, samp, ((vec2<f32>((_e149.x / _e153.x), _e156.y) / vec2(2f)) + vec2(0.5f)));
        let _e166 = col;
        let _e167 = mergeColor(_e165, _e166);
        return _e167;
    } else {
        let _e168 = col;
        return _e168;
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
    let _e76 = global.U[7];
    let _e80 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = squareLand((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80, _e83);
    fragColor = _e84;
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
