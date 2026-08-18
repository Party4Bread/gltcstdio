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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn getRGBWeights(w: f32) -> vec4<f32> {
    var w_1: f32;

    w_1 = w;
    let _e9 = w_1;
    let _e14 = w_1;
    let _e19 = w_1;
    return vec4<f32>(max(0f, -(_e9)), max(0f, (1f - abs(_e14))), max(0f, _e19), 1f);
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

fn withShapeAspectRatio(u_2: vec2<f32>, ar: f32) -> vec2<f32> {
    var u_3: vec2<f32>;
    var ar_1: f32;

    u_3 = u_2;
    ar_1 = ar;
    let _e10 = u_3;
    let _e12 = ar_1;
    let _e14 = u_3;
    let _e20 = ar_1;
    return ((vec2<f32>((_e10.x * _e12), _e14.y) * 2f) / vec2((1f + _e20)));
}

fn radialColorDispersion(pos: vec2<f32>, outPos: vec2<f32>, sourceDim: vec2<f32>, intensity: f32, hardness: f32, shapeAspectRatio: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var sourceDim_1: vec2<f32>;
    var intensity_1: f32;
    var hardness_1: f32;
    var shapeAspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var p: vec2<f32>;
    var stepLen: f32;
    var pDist: f32;
    var shapeDist: f32;
    var k: f32;
    var dir: vec2<f32>;
    var step: vec2<f32>;
    var distance: f32;
    var halfDist: f32;
    var totalColor: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var totalW: vec4<f32> = vec4<f32>(0f, 0f, 0f, 0f);
    var start: f32;
    var end: f32;
    var actualDistance: f32;
    var startQ: vec2<f32>;
    var endQ: vec2<f32>;
    var n: f32;
    var i: f32 = 0f;
    var k_1: f32;
    var q: vec2<f32>;
    var weights: vec4<f32>;
    var col: vec4<f32>;
    var dispersedColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    sourceDim_1 = sourceDim;
    intensity_1 = intensity;
    hardness_1 = hardness;
    shapeAspectRatio_1 = shapeAspectRatio;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    let _e22 = pos_1;
    let _e23 = tf(_naga_inverse_3x3_f32(_e20), _e22);
    p = _e23;
    let _e26 = sourceDim_1;
    stepLen = (2f / _e26.y);
    let _e30 = p;
    let _e34 = p;
    if ((_e30.x == 0f) && (_e34.y == 0f)) {
        let _e39 = pos_1;
        let _e43 = global.U[0];
        let _e46 = pos_1;
        let _e55 = _mirror_wrap(((vec2<f32>((_e39.x / _e43.x), _e46.y) / vec2(2f)) + vec2(0.5f)));
        let _e56 = textureSample(t_source, samp, _e55);
        return _e56;
    }
    let _e57 = p;
    pDist = length(_e57);
    let _e60 = p;
    let _e61 = shapeAspectRatio_1;
    let _e62 = withShapeAspectRatio(_e60, _e61);
    shapeDist = length(_e62);
    let _e65 = hardness_1;
    let _e69 = shapeDist;
    k = smoothstep((_e65 * 0.999f), 1f, _e69);
    let _e72 = p;
    dir = normalize(_e72);
    let _e75 = dir;
    let _e76 = stepLen;
    step = (_e75 * _e76);
    let _e79 = k;
    let _e80 = intensity_1;
    distance = (_e79 * _e80);
    let _e83 = distance;
    halfDist = (_e83 * 0.5f);
    let _e100 = pDist;
    let _e101 = halfDist;
    start = max(0f, (_e100 - _e101));
    let _e105 = pDist;
    let _e106 = halfDist;
    end = (_e105 + _e106);
    let _e109 = end;
    let _e110 = start;
    actualDistance = (_e109 - _e110);
    let _e113 = actualDistance;
    let _e114 = stepLen;
    if (_e113 <= _e114) {
        let _e116 = pos_1;
        let _e120 = global.U[0];
        let _e123 = pos_1;
        let _e132 = _mirror_wrap(((vec2<f32>((_e116.x / _e120.x), _e123.y) / vec2(2f)) + vec2(0.5f)));
        let _e133 = textureSample(t_source, samp, _e132);
        return _e133;
    }
    let _e134 = modelTransform_1;
    let _e135 = start;
    let _e136 = dir;
    let _e138 = tf(_e134, (_e135 * _e136));
    startQ = _e138;
    let _e140 = modelTransform_1;
    let _e141 = end;
    let _e142 = dir;
    let _e144 = tf(_e140, (_e141 * _e142));
    endQ = _e144;
    let _e147 = actualDistance;
    let _e148 = stepLen;
    n = max(3f, ceil((_e147 / _e148)));
    loop {
        let _e155 = i;
        let _e156 = n;
        if !((_e155 < _e156)) {
            break;
        }
        {
            let _e162 = i;
            let _e163 = n;
            k_1 = (_e162 / (_e163 - 1f));
            let _e168 = startQ;
            let _e169 = endQ;
            let _e170 = k_1;
            q = mix(_e168, _e169, vec2(_e170));
            let _e174 = k_1;
            let _e179 = getRGBWeights(((_e174 * 2f) - 1f));
            weights = _e179;
            let _e181 = q;
            let _e185 = global.U[0];
            let _e188 = q;
            let _e197 = _mirror_wrap(((vec2<f32>((_e181.x / _e185.x), _e188.y) / vec2(2f)) + vec2(0.5f)));
            let _e198 = textureSample(t_source, samp, _e197);
            col = _e198;
            let _e200 = totalColor;
            let _e201 = weights;
            let _e202 = col;
            let _e204 = col;
            totalColor = (_e200 + ((_e201 * _e202) * _e204));
            let _e207 = totalW;
            let _e208 = weights;
            totalW = (_e207 + _e208);
        }
        continuing {
            let _e159 = i;
            i = (_e159 + 1f);
        }
    }
    let _e210 = totalColor;
    let _e211 = totalW;
    dispersedColor = sqrt((_e210 / _e211));
    let _e215 = dispersedColor;
    return _e215;
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
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e90 = global.U[11];
    let _e91 = _e90.xyz;
    let _e105 = radialColorDispersion((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.xy, _e70.x, _e74.x, _e78.x, mat3x3<f32>(vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z), vec3<f32>(_e91.x, _e91.y, _e91.z)));
    fragColor = _e105;
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
