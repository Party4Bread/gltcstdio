struct Params {
    U: array<vec4<f32>, 11>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn radialColorDispersion(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, hardness: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var hardness_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var p: vec2<f32>;
    var stepLen: f32 = 0.002f;
    var pDist: f32;
    var k: f32;
    var dir: vec2<f32>;
    var step: vec2<f32>;
    var distance: f32;
    var halfDist: f32;
    var n: f32 = 0f;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalW: f32 = 0f;
    var start: f32;
    var end: f32;
    var actualDistance: f32;
    var d: f32;
    var q: vec2<f32>;
    var col: vec4<f32>;
    var dispersedColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    hardness_1 = hardness;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    let _e20 = pos_1;
    let _e21 = tf(_naga_inverse_3x3_f32(_e18), _e20);
    p = _e21;
    let _e25 = p;
    let _e29 = p;
    if ((_e25.x == 0f) && (_e29.y == 0f)) {
        let _e34 = pos_1;
        let _e38 = global.U[0];
        let _e41 = pos_1;
        let _e50 = _mirror_wrap(((vec2<f32>((_e34.x / _e38.x), _e41.y) / vec2(2f)) + vec2(0.5f)));
        let _e52 = textureSampleLevel(t_source, samp, _e50, 0f);
        return _e52;
    }
    let _e53 = p;
    pDist = length(_e53);
    let _e56 = hardness_1;
    let _e60 = pDist;
    k = smoothstep((_e56 * 0.999f), 1f, _e60);
    let _e63 = p;
    dir = normalize(_e63);
    let _e66 = dir;
    let _e67 = stepLen;
    step = (_e66 * _e67);
    let _e70 = k;
    let _e71 = intensity_1;
    distance = (_e70 * _e71);
    let _e74 = distance;
    halfDist = (_e74 * 0.5f);
    let _e89 = pDist;
    let _e90 = halfDist;
    start = max(0f, (_e89 - _e90));
    let _e94 = pDist;
    let _e95 = halfDist;
    end = (_e94 + _e95);
    let _e98 = end;
    let _e99 = start;
    actualDistance = (_e98 - _e99);
    let _e102 = actualDistance;
    let _e103 = stepLen;
    if (_e102 <= _e103) {
        let _e105 = pos_1;
        let _e109 = global.U[0];
        let _e112 = pos_1;
        let _e121 = _mirror_wrap(((vec2<f32>((_e105.x / _e109.x), _e112.y) / vec2(2f)) + vec2(0.5f)));
        let _e123 = textureSampleLevel(t_source, samp, _e121, 0f);
        return _e123;
    }
    let _e124 = start;
    d = _e124;
    loop {
        let _e126 = d;
        let _e127 = end;
        if !((_e126 < _e127)) {
            break;
        }
        {
            let _e133 = modelTransform_1;
            let _e134 = d;
            let _e135 = dir;
            let _e137 = tf(_e133, (_e134 * _e135));
            q = _e137;
            let _e139 = q;
            let _e143 = global.U[0];
            let _e146 = q;
            let _e155 = _mirror_wrap(((vec2<f32>((_e139.x / _e143.x), _e146.y) / vec2(2f)) + vec2(0.5f)));
            let _e157 = textureSampleLevel(t_source, samp, _e155, 0f);
            col = _e157;
            let _e159 = totalColor;
            let _e160 = col;
            let _e161 = col;
            totalColor = (_e159 + (_e160 * _e161));
            let _e164 = totalW;
            totalW = (_e164 + 1f);
        }
        continuing {
            let _e130 = d;
            let _e131 = stepLen;
            d = (_e130 + _e131);
        }
    }
    let _e167 = totalColor;
    let _e168 = totalW;
    dispersedColor = sqrt((_e167 / vec4(_e168)));
    let _e173 = dispersedColor;
    return _e173;
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
    let _e70 = global.U[6];
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = radialColorDispersion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
    fragColor = _e101;
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
