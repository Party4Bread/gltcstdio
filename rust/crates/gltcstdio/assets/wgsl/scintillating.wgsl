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

fn rand2rel(co: vec2<f32>) -> vec2<f32> {
    var co_1: vec2<f32>;
    var x: f32;
    var y: f32;

    co_1 = co;
    let _e8 = co_1;
    x = fract((sin(dot(_e8.xy, vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e19 = x;
    let _e20 = co_1;
    y = fract((sin(dot(vec2<f32>(_e19, _e20.x), vec2<f32>(12.9898f, 78.233f))) * 43758.547f));
    let _e32 = x;
    let _e33 = y;
    return (vec2<f32>(_e32, _e33) - vec2<f32>(0.5f, 0.5f));
}

fn scintillatingIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, thickness: f32, radius: f32, radiusVariability: f32, colorIn: vec4<f32>, colorDots: vec4<f32>, colorBorder: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var thickness_1: f32;
    var radius_1: f32;
    var radiusVariability_1: f32;
    var colorIn_1: vec4<f32>;
    var colorDots_1: vec4<f32>;
    var colorBorder_1: vec4<f32>;
    var u: vec2<f32>;
    var id: vec2<f32> = vec2(0f);
    var d: f32;
    var col: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    thickness_1 = thickness;
    radius_1 = radius;
    radiusVariability_1 = radiusVariability;
    colorIn_1 = colorIn;
    colorDots_1 = colorDots;
    colorBorder_1 = colorBorder;
    let _e24 = uv_1;
    u = (fract(_e24) - vec2(0.5f));
    let _e33 = radiusVariability_1;
    if (_e33 != 0f) {
        let _e36 = uv_1;
        id = floor(_e36);
    }
    let _e38 = u;
    d = length(_e38);
    let _e42 = radius_1;
    radius_1 = (_e42 * 0.5f);
    let _e45 = radius_1;
    let _e47 = id;
    let _e48 = rand2rel(_e47);
    let _e50 = radiusVariability_1;
    radius_1 = (_e45 * (1f + (_e48.x * _e50)));
    let _e54 = d;
    let _e55 = radius_1;
    if (_e54 < _e55) {
        {
            let _e57 = colorDots_1;
            col = _e57;
        }
    } else {
        {
            let _e58 = u;
            let _e61 = thickness_1;
            let _e63 = u;
            let _e66 = thickness_1;
            if ((abs(_e58.x) < _e61) || (abs(_e63.y) < _e66)) {
                let _e69 = colorBorder_1;
                col = _e69;
            } else {
                let _e70 = colorIn_1;
                col = _e70;
            }
        }
    }
    let _e71 = source_specified_1;
    if (_e71 == 1i) {
        {
            let _e74 = uv_1;
            let _e78 = global.U[0];
            let _e81 = uv_1;
            let _e90 = textureSample(t_source, samp, ((vec2<f32>((_e74.x / _e78.x), _e81.y) / vec2(2f)) + vec2(0.5f)));
            let _e91 = col;
            let _e92 = mergeColor(_e90, _e91);
            col = _e92;
        }
    }
    let _e93 = col;
    return _e93;
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
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e86 = global.U[10];
    let _e89 = global.U[11];
    let _e90 = scintillatingIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), _e71.x, _e75.x, _e79.x, _e83, _e86, _e89);
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
