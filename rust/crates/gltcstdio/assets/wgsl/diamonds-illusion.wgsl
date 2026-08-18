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

fn diamondsIllusion(uv: vec2<f32>, outPos: vec2<f32>, source_specified: i32, count: i32, power: f32, color1_: vec4<f32>, color2_: vec4<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var source_specified_1: i32;
    var count_1: i32;
    var power_1: f32;
    var color1_1: vec4<f32>;
    var color2_1: vec4<f32>;
    var u: vec2<f32>;
    var id: vec2<f32>;
    var m: f32;
    var p: f32;
    var strip: f32;
    var tileType: f32;
    var slope: f32;
    var outColor: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    source_specified_1 = source_specified;
    count_1 = count;
    power_1 = power;
    color1_1 = color1_;
    color2_1 = color2_;
    let _e20 = uv_1;
    u = ((fract(_e20) - vec2(0.5f)) * 2f);
    let _e28 = uv_1;
    id = floor(_e28);
    let _e31 = u;
    let _e34 = u;
    m = max(abs(_e31.x), abs(_e34.y));
    let _e40 = power_1;
    p = pow(1.5f, _e40);
    let _e43 = m;
    let _e44 = p;
    let _e46 = count_1;
    strip = floor((pow(_e43, _e44) * f32(_e46)));
    let _e51 = id;
    let _e53 = id;
    let _e55 = (_e51.x + _e53.y);
    tileType = (_e55 - (floor((_e55 / 2f)) * 2f));
    let _e62 = tileType;
    slope = ((_e62 - 0.5f) * 2f);
    let _e69 = strip;
    let _e77 = tileType;
    let _e81 = u;
    let _e83 = slope;
    let _e85 = u;
    let _e89 = id;
    if (((((_e69 - (floor((_e69 / 2f)) * 2f)) == 0f) != (_e77 == 0f)) != ((_e81.x * _e83) > _e85.y)) != ((_e89.y - (floor((_e89.y / 2f)) * 2f)) == 0f)) {
        let _e99 = color1_1;
        outColor = _e99;
    } else {
        let _e100 = color2_1;
        outColor = _e100;
    }
    let _e101 = source_specified_1;
    if (_e101 == 1i) {
        let _e104 = outPos_1;
        let _e108 = global.U[0];
        let _e111 = outPos_1;
        let _e120 = textureSample(t_source, samp, ((vec2<f32>((_e104.x / _e108.x), _e111.y) / vec2(2f)) + vec2(0.5f)));
        let _e121 = outColor;
        let _e122 = mergeColor(_e120, _e121);
        return _e122;
    } else {
        let _e123 = outColor;
        return _e123;
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
    let _e84 = diamondsIllusion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), i32(_e71.x), _e76.x, _e80, _e83);
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
