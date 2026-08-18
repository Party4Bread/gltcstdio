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
var t_legacy_0_: texture_2d<f32>;

fn gaussian(x: f32) -> f32 {
    var x_1: f32;
    var local: f32;

    x_1 = x;
    let _e8 = x_1;
    if (_e8 > 0.5f) {
        let _e12 = x_1;
        let _e15 = x_1;
        local = (((1f - _e12) * (1f - _e15)) * 2f);
    } else {
        let _e21 = x_1;
        let _e22 = x_1;
        local = (1f - ((_e21 * _e22) * 2f));
    }
    let _e28 = local;
    return _e28;
}

fn blur(uv: vec2<f32>, outPos: vec2<f32>, radius: f32) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var radius_1: f32;
    var pixel: f32;
    var sizing: f32;
    var baseLod: f32;
    var total: vec4<f32>;
    var div: f32 = 1f;
    var d: f32;
    var step: f32;
    var lod: f32;
    var gInv: f32 = 1f;
    var u1_: vec2<f32>;
    var u2_: vec2<f32>;
    var g: f32;
    var col1_: vec4<f32>;
    var col2_: vec4<f32>;

    uv_1 = uv;
    outPos_1 = outPos;
    radius_1 = radius;
    let _e15 = global.U[5];
    pixel = (2f / _e15.y);
    let _e20 = radius_1;
    let _e22 = pixel;
    sizing = (_e20 / (80f * _e22));
    let _e26 = sizing;
    if (_e26 > 1f) {
        let _e29 = pixel;
        let _e30 = sizing;
        pixel = (_e29 * _e30);
    }
    let _e32 = sizing;
    baseLod = log(_e32);
    let _e37 = global.U[6];
    let _e38 = _e37.xyz;
    let _e41 = global.U[7];
    let _e42 = _e41.xyz;
    let _e45 = global.U[8];
    let _e46 = _e45.xyz;
    let _e60 = uv_1;
    let _e68 = textureSample(t_legacy_0_, samp, vec2<f32>((mat3x3<f32>(vec3<f32>(_e38.x, _e38.y, _e38.z), vec3<f32>(_e42.x, _e42.y, _e42.z), vec3<f32>(_e46.x, _e46.y, _e46.z)) * vec3<f32>(_e60.x, _e60.y, 1f)).xy));
    total = _e68;
    let _e70 = total;
    let _e71 = total;
    total = (_e70 * _e71);
    let _e75 = pixel;
    d = _e75;
    let _e77 = pixel;
    step = _e77;
    let _e79 = baseLod;
    lod = _e79;
    loop {
        let _e83 = d;
        let _e84 = radius_1;
        if !((_e83 < _e84)) {
            break;
        }
        {
            let _e87 = uv_1;
            let _e89 = d;
            u1_ = (_e87 - vec2<f32>(0f, _e89));
            let _e93 = uv_1;
            let _e95 = d;
            u2_ = (_e93 + vec2<f32>(0f, _e95));
            let _e99 = d;
            let _e100 = radius_1;
            let _e102 = gaussian((_e99 / _e100));
            g = _e102;
            let _e106 = global.U[6];
            let _e107 = _e106.xyz;
            let _e110 = global.U[7];
            let _e111 = _e110.xyz;
            let _e114 = global.U[8];
            let _e115 = _e114.xyz;
            let _e129 = u1_;
            let _e137 = lod;
            let _e138 = textureSampleBias(t_legacy_0_, samp, vec2<f32>((mat3x3<f32>(vec3<f32>(_e107.x, _e107.y, _e107.z), vec3<f32>(_e111.x, _e111.y, _e111.z), vec3<f32>(_e115.x, _e115.y, _e115.z)) * vec3<f32>(_e129.x, _e129.y, 1f)).xy), _e137);
            col1_ = _e138;
            let _e142 = global.U[6];
            let _e143 = _e142.xyz;
            let _e146 = global.U[7];
            let _e147 = _e146.xyz;
            let _e150 = global.U[8];
            let _e151 = _e150.xyz;
            let _e165 = u2_;
            let _e173 = lod;
            let _e174 = textureSampleBias(t_legacy_0_, samp, vec2<f32>((mat3x3<f32>(vec3<f32>(_e143.x, _e143.y, _e143.z), vec3<f32>(_e147.x, _e147.y, _e147.z), vec3<f32>(_e151.x, _e151.y, _e151.z)) * vec3<f32>(_e165.x, _e165.y, 1f)).xy), _e173);
            col2_ = _e174;
            let _e176 = total;
            let _e177 = col1_;
            let _e178 = col1_;
            let _e180 = col2_;
            let _e181 = col2_;
            total = (_e176 + ((_e177 * _e178) + (_e180 * _e181)));
            let _e185 = div;
            div = (_e185 + 2f);
            let _e189 = g;
            gInv = (1f / _e189);
            let _e191 = pixel;
            let _e192 = gInv;
            step = (_e191 * _e192);
            let _e194 = baseLod;
            let _e195 = gInv;
            lod = (_e194 + log(_e195));
            let _e198 = d;
            let _e199 = step;
            d = (_e198 + _e199);
        }
    }
    let _e201 = total;
    let _e202 = div;
    return sqrt((_e201 / vec4(_e202)));
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
    let _e66 = global.U[9];
    let _e68 = blur((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x);
    fragColor = _e68;
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
