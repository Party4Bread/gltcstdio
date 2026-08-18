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
        let _e51 = textureSample(t_source, samp, _e50);
        return _e51;
    }
    let _e52 = p;
    pDist = length(_e52);
    let _e55 = hardness_1;
    let _e59 = pDist;
    k = smoothstep((_e55 * 0.999f), 1f, _e59);
    let _e62 = p;
    dir = normalize(_e62);
    let _e65 = dir;
    let _e66 = stepLen;
    step = (_e65 * _e66);
    let _e69 = k;
    let _e70 = intensity_1;
    distance = (_e69 * _e70);
    let _e73 = distance;
    halfDist = (_e73 * 0.5f);
    let _e88 = pDist;
    let _e89 = halfDist;
    start = max(0f, (_e88 - _e89));
    let _e93 = pDist;
    let _e94 = halfDist;
    end = (_e93 + _e94);
    let _e97 = end;
    let _e98 = start;
    actualDistance = (_e97 - _e98);
    let _e101 = actualDistance;
    let _e102 = stepLen;
    if (_e101 <= _e102) {
        let _e104 = pos_1;
        let _e108 = global.U[0];
        let _e111 = pos_1;
        let _e120 = _mirror_wrap(((vec2<f32>((_e104.x / _e108.x), _e111.y) / vec2(2f)) + vec2(0.5f)));
        let _e121 = textureSample(t_source, samp, _e120);
        return _e121;
    }
    let _e122 = start;
    d = _e122;
    loop {
        let _e124 = d;
        let _e125 = end;
        if !((_e124 < _e125)) {
            break;
        }
        {
            let _e131 = modelTransform_1;
            let _e132 = d;
            let _e133 = dir;
            let _e135 = tf(_e131, (_e132 * _e133));
            q = _e135;
            let _e137 = q;
            let _e141 = global.U[0];
            let _e144 = q;
            let _e153 = _mirror_wrap(((vec2<f32>((_e137.x / _e141.x), _e144.y) / vec2(2f)) + vec2(0.5f)));
            let _e154 = textureSample(t_source, samp, _e153);
            col = _e154;
            let _e156 = totalColor;
            let _e157 = col;
            let _e158 = col;
            totalColor = (_e156 + (_e157 * _e158));
            let _e161 = totalW;
            totalW = (_e161 + 1f);
        }
        continuing {
            let _e128 = d;
            let _e129 = stepLen;
            d = (_e128 + _e129);
        }
    }
    let _e164 = totalColor;
    let _e165 = totalW;
    dispersedColor = sqrt((_e164 / vec4(_e165)));
    let _e170 = dispersedColor;
    return _e170;
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
