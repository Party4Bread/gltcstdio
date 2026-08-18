struct Params {
    U: array<vec4<f32>, 5>,
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

fn borderKaleid3Mask(uv: vec2<f32>, outPos: vec2<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var PI: f32 = 3.1415927f;
    var COUNT: f32 = 6f;
    var halfAlpha: f32;
    var alpha: f32;
    var TX: f32 = 0f;
    var TY: f32 = 0.65f;
    var PHASE: f32;
    var K_SCALE: f32 = 2.64f;
    var d: f32;
    var sourceAngle: f32 = 0f;
    var ang: f32;
    var coord: vec2<f32>;
    var cp: f32;
    var sp: f32;
    var texSample: vec2<f32>;
    var RT_SCALE: f32 = 10f;
    var TILE_SIZE: f32 = 2f;
    var INV_RT: f32;
    var TILE_INTENSITY: f32 = 18f;
    var u_rt: vec2<f32>;
    var tileSpan: f32;
    var s: f32;
    var tileCenter: vec2<f32>;
    var v: vec2<f32>;
    var p: vec2<f32>;
    var m0_: f32;
    var m: f32;
    var kPost: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    let _e13 = PI;
    let _e14 = COUNT;
    halfAlpha = (_e13 / _e14);
    let _e17 = halfAlpha;
    alpha = (_e17 * 2f);
    let _e26 = PI;
    PHASE = (1.1f + _e26);
    let _e33 = uv_1;
    d = length(_e33);
    let _e38 = d;
    if (_e38 > 0f) {
        {
            let _e41 = uv_1;
            let _e43 = uv_1;
            ang = atan2(_e41.y, _e43.x);
            let _e47 = ang;
            if (_e47 < 0f) {
                let _e50 = ang;
                let _e52 = PI;
                ang = (_e50 + (2f * _e52));
            }
            let _e55 = ang;
            let _e56 = alpha;
            sourceAngle = (_e55 - (floor((_e55 / _e56)) * _e56));
        }
    }
    let _e61 = d;
    let _e62 = sourceAngle;
    let _e64 = sourceAngle;
    coord = (_e61 * vec2<f32>(cos(_e62), sin(_e64)));
    let _e69 = PHASE;
    cp = cos(_e69);
    let _e72 = PHASE;
    sp = sin(_e72);
    let _e75 = K_SCALE;
    let _e76 = cp;
    let _e77 = coord;
    let _e80 = sp;
    let _e81 = coord;
    let _e86 = TX;
    let _e88 = K_SCALE;
    let _e89 = sp;
    let _e90 = coord;
    let _e93 = cp;
    let _e94 = coord;
    let _e99 = TY;
    texSample = vec2<f32>(((_e75 * ((_e76 * _e77.x) - (_e80 * _e81.y))) + _e86), ((_e88 * ((_e89 * _e90.x) + (_e93 * _e94.y))) + _e99));
    let _e108 = RT_SCALE;
    INV_RT = (1f / _e108);
    let _e113 = RT_SCALE;
    let _e114 = texSample;
    u_rt = (_e113 * _e114);
    let _e117 = INV_RT;
    let _e118 = TILE_SIZE;
    tileSpan = (_e117 * _e118);
    let _e122 = TILE_INTENSITY;
    let _e126 = tileSpan;
    s = (1f + ((_e122 * 0.01f) * ((2f / _e126) - 1f)));
    let _e133 = u_rt;
    let _e135 = TILE_SIZE;
    let _e140 = TILE_SIZE;
    let _e142 = u_rt;
    let _e144 = TILE_SIZE;
    let _e149 = TILE_SIZE;
    tileCenter = vec2<f32>(((floor((_e133.x / _e135)) + 0.5f) * _e140), ((floor((_e142.y / _e144)) + 0.5f) * _e149));
    let _e153 = u_rt;
    let _e154 = tileCenter;
    v = (_e153 - _e154);
    let _e157 = INV_RT;
    let _e158 = v;
    let _e159 = s;
    let _e161 = tileCenter;
    p = (_e157 * ((_e158 * _e159) + _e161));
    let _e165 = p;
    let _e170 = ((_e165.y + 1f) / 2f);
    m0_ = (_e170 - (floor((_e170 / 2f)) * 2f));
    let _e178 = m0_;
    m = (1f - abs((_e178 - 1f)));
    let _e185 = m;
    kPost = step(0.5f, _e185);
    let _e189 = kPost;
    let _e191 = vec3((1f - _e189));
    return vec4<f32>(_e191.x, _e191.y, _e191.z, 1f);
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
    let _e63 = borderKaleid3Mask((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e8.x, _e8.y, _e8.z), vec3<f32>(_e12.x, _e12.y, _e12.z), vec3<f32>(_e16.x, _e16.y, _e16.z))) * vec3<f32>(_e43.x, _e43.y, 1f)).xy, (((_e50 - vec2(0.5f)) * 2f) * vec2<f32>(_e58.x, 1f)));
    fragColor = _e63;
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
