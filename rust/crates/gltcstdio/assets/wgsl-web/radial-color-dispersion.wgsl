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
        let _e57 = textureSampleLevel(t_source, samp, _e55, 0f);
        return _e57;
    }
    let _e58 = p;
    pDist = length(_e58);
    let _e61 = p;
    let _e62 = shapeAspectRatio_1;
    let _e63 = withShapeAspectRatio(_e61, _e62);
    shapeDist = length(_e63);
    let _e66 = hardness_1;
    let _e70 = shapeDist;
    k = smoothstep((_e66 * 0.999f), 1f, _e70);
    let _e73 = p;
    dir = normalize(_e73);
    let _e76 = dir;
    let _e77 = stepLen;
    step = (_e76 * _e77);
    let _e80 = k;
    let _e81 = intensity_1;
    distance = (_e80 * _e81);
    let _e84 = distance;
    halfDist = (_e84 * 0.5f);
    let _e101 = pDist;
    let _e102 = halfDist;
    start = max(0f, (_e101 - _e102));
    let _e106 = pDist;
    let _e107 = halfDist;
    end = (_e106 + _e107);
    let _e110 = end;
    let _e111 = start;
    actualDistance = (_e110 - _e111);
    let _e114 = actualDistance;
    let _e115 = stepLen;
    if (_e114 <= _e115) {
        let _e117 = pos_1;
        let _e121 = global.U[0];
        let _e124 = pos_1;
        let _e133 = _mirror_wrap(((vec2<f32>((_e117.x / _e121.x), _e124.y) / vec2(2f)) + vec2(0.5f)));
        let _e135 = textureSampleLevel(t_source, samp, _e133, 0f);
        return _e135;
    }
    let _e136 = modelTransform_1;
    let _e137 = start;
    let _e138 = dir;
    let _e140 = tf(_e136, (_e137 * _e138));
    startQ = _e140;
    let _e142 = modelTransform_1;
    let _e143 = end;
    let _e144 = dir;
    let _e146 = tf(_e142, (_e143 * _e144));
    endQ = _e146;
    let _e149 = actualDistance;
    let _e150 = stepLen;
    n = max(3f, ceil((_e149 / _e150)));
    loop {
        let _e157 = i;
        let _e158 = n;
        if !((_e157 < _e158)) {
            break;
        }
        {
            let _e164 = i;
            let _e165 = n;
            k_1 = (_e164 / (_e165 - 1f));
            let _e170 = startQ;
            let _e171 = endQ;
            let _e172 = k_1;
            q = mix(_e170, _e171, vec2(_e172));
            let _e176 = k_1;
            let _e181 = getRGBWeights(((_e176 * 2f) - 1f));
            weights = _e181;
            let _e183 = q;
            let _e187 = global.U[0];
            let _e190 = q;
            let _e199 = _mirror_wrap(((vec2<f32>((_e183.x / _e187.x), _e190.y) / vec2(2f)) + vec2(0.5f)));
            let _e201 = textureSampleLevel(t_source, samp, _e199, 0f);
            col = _e201;
            let _e203 = totalColor;
            let _e204 = weights;
            let _e205 = col;
            let _e207 = col;
            totalColor = (_e203 + ((_e204 * _e205) * _e207));
            let _e210 = totalW;
            let _e211 = weights;
            totalW = (_e210 + _e211);
        }
        continuing {
            let _e161 = i;
            i = (_e161 + 1f);
        }
    }
    let _e213 = totalColor;
    let _e214 = totalW;
    dispersedColor = sqrt((_e213 / _e214));
    let _e218 = dispersedColor;
    return _e218;
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
