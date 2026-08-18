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

fn circleRippleIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, squish: f32, count: i32, colorIn: vec4<f32>, colorOut: vec4<f32>, colorTop: vec4<f32>, colorBottom: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var squish_1: f32;
    var count_1: i32;
    var colorIn_1: vec4<f32>;
    var colorOut_1: vec4<f32>;
    var colorTop_1: vec4<f32>;
    var colorBottom_1: vec4<f32>;
    var iy: f32;
    var y: f32;
    var x: f32;
    var u: vec2<f32>;
    var d: f32;
    var col: vec4<f32>;
    var radius: f32 = 0.45f;
    var up: bool;
    var local: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    squish_1 = squish;
    count_1 = count;
    colorIn_1 = colorIn;
    colorOut_1 = colorOut;
    colorTop_1 = colorTop;
    colorBottom_1 = colorBottom;
    let _e25 = uv_1;
    let _e27 = squish_1;
    uv_1.y = (_e25.y / _e27);
    let _e29 = uv_1;
    iy = floor(_e29.y);
    let _e33 = uv_1;
    y = fract(_e33.y);
    let _e37 = uv_1;
    let _e39 = iy;
    x = fract((_e37.x + (_e39 * 0.5f)));
    let _e45 = x;
    let _e46 = y;
    u = (vec2<f32>(_e45, _e46) - vec2(0.5f));
    let _e52 = u;
    d = length(_e52);
    let _e58 = d;
    let _e59 = radius;
    if (_e58 < _e59) {
        {
            let _e61 = d;
            let _e62 = radius;
            if (_e61 > (_e62 * 0.8f)) {
                {
                    let _e66 = iy;
                    let _e68 = count_1;
                    let _e74 = u;
                    up = ((((i32(_e66) / _e68) % 2i) == 0i) != (_e74.y < 0f));
                    let _e80 = up;
                    if _e80 {
                        let _e81 = colorTop_1;
                        local = _e81;
                    } else {
                        let _e82 = colorBottom_1;
                        local = _e82;
                    }
                    let _e84 = local;
                    col = _e84;
                }
            } else {
                {
                    let _e85 = colorIn_1;
                    col = _e85;
                }
            }
        }
    } else {
        {
            let _e86 = colorOut_1;
            col = _e86;
        }
    }
    let _e87 = source_specified_1;
    if (_e87 == 1i) {
        {
            let _e90 = uv_1;
            let _e94 = global.U[0];
            let _e97 = uv_1;
            let _e106 = textureSample(t_source, samp, ((vec2<f32>((_e90.x / _e94.x), _e97.y) / vec2(2f)) + vec2(0.5f)));
            let _e107 = col;
            let _e108 = mergeColor(_e106, _e107);
            col = _e108;
        }
    }
    let _e109 = col;
    return _e109;
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
    let _e75 = global.U[7];
    let _e80 = global.U[8];
    let _e83 = global.U[9];
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e90 = circleRippleIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, i32(_e75.x), _e80, _e83, _e86, _e89);
    fragColor = _e90;
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
