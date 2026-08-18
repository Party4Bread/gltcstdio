struct Params {
    U: array<vec4<f32>, 14>,
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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn glassRectTiles(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, outAspectRatio: f32, pixelation: f32, highFreqColor: vec4<f32>, shapeAspectRatio: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var outAspectRatio_1: f32;
    var pixelation_1: f32;
    var highFreqColor_1: vec4<f32>;
    var shapeAspectRatio_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v: vec2<f32>;
    var tileDim: vec2<f32>;
    var tileSize: f32;
    var maxTileViewSize: f32;
    var viewSize: f32;
    var c_2: vec2<f32>;
    var pos: vec2<f32>;
    var borderDist: f32;
    var distort: f32;
    var local: vec2<f32>;
    var center: vec2<f32>;
    var scale: f32;
    var pixColor: vec4<f32>;
    var w: vec2<f32>;
    var col: vec4<f32>;
    var hf: f32 = 0f;
    var hfThreshold: f32;

    uv_1 = uv;
    outPos_1 = outPos;
    intensity_1 = intensity;
    distortion_1 = distortion;
    outAspectRatio_1 = outAspectRatio;
    pixelation_1 = pixelation;
    highFreqColor_1 = highFreqColor;
    shapeAspectRatio_1 = shapeAspectRatio;
    modelTransform_1 = modelTransform;
    let _e24 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e24);
    let _e27 = uv_1;
    u_2 = _e27;
    let _e29 = t;
    let _e30 = uv_1;
    let _e31 = tf(_e29, _e30);
    v = _e31;
    let _e34 = shapeAspectRatio_1;
    let _e37 = shapeAspectRatio_1;
    let _e42 = shapeAspectRatio_1;
    tileDim = vec2<f32>(((2f * _e34) / (1f + _e37)), (2f / (1f + _e42)));
    let _e49 = modelTransform_1[0];
    let _e52 = tileDim;
    let _e54 = tileDim;
    tileSize = (length(_e49.xy) * max(_e52.x, _e54.y));
    let _e59 = outAspectRatio_1;
    maxTileViewSize = min(_e59, 1f);
    let _e63 = tileSize;
    let _e64 = maxTileViewSize;
    let _e65 = intensity_1;
    viewSize = mix(_e63, _e64, _e65);
    let _e68 = v;
    let _e69 = tileDim;
    let _e72 = tileDim;
    c_2 = (round((_e68 / _e69)) * _e72);
    let _e75 = v;
    let _e76 = c_2;
    pos = (_e75 - _e76);
    let _e79 = tileDim;
    let _e83 = pos;
    let _e87 = tileDim;
    let _e91 = pos;
    borderDist = min(((_e79.x * 0.5f) - abs(_e83.x)), ((_e87.y * 0.5f) - abs(_e91.y)));
    let _e98 = distortion_1;
    let _e99 = borderDist;
    distort = max(1f, (_e98 / _e99));
    let _e103 = modelTransform_1;
    let _e104 = c_2;
    let _e105 = tf(_e103, _e104);
    let _e106 = tileSize;
    let _e107 = maxTileViewSize;
    if (_e106 >= _e107) {
        local = vec2(1f);
    } else {
        let _e111 = outAspectRatio_1;
        let _e114 = viewSize;
        let _e119 = outAspectRatio_1;
        let _e122 = tileSize;
        local = ((vec2<f32>(_e111, 1f) - vec2((_e114 * 0.5f))) / (vec2<f32>(_e119, 1f) - vec2((_e122 * 0.5f))));
    }
    let _e129 = local;
    center = (_e105 * _e129);
    let _e132 = viewSize;
    let _e133 = tileSize;
    scale = (_e132 / _e133);
    let _e136 = center;
    let _e140 = global.U[0];
    let _e143 = center;
    let _e152 = _mirror_wrap(((vec2<f32>((_e136.x / _e140.x), _e143.y) / vec2(2f)) + vec2(0.5f)));
    let _e153 = textureSample(t_source, samp, _e152);
    pixColor = _e153;
    let _e155 = center;
    let _e156 = modelTransform_1;
    let _e164 = pos;
    let _e166 = distort;
    let _e168 = scale;
    w = (_e155 + (((mat2x2<f32>(_e156[0].xy, _e156[1].xy) * _e164) * _e166) * _e168));
    let _e172 = w;
    let _e176 = global.U[0];
    let _e179 = w;
    let _e188 = _mirror_wrap(((vec2<f32>((_e172.x / _e176.x), _e179.y) / vec2(2f)) + vec2(0.5f)));
    let _e189 = textureSample(t_source, samp, _e188);
    col = _e189;
    let _e193 = highFreqColor_1;
    if (_e193.w > 0f) {
        {
            let _e198 = highFreqColor_1;
            hfThreshold = (2f / _e198.w);
            let _e202 = hfThreshold;
            let _e203 = hfThreshold;
            let _e206 = distort;
            hf = smoothstep(_e202, (_e203 * 10f), _e206);
        }
    }
    let _e208 = col;
    let _e209 = pixColor;
    let _e210 = pixelation_1;
    let _e213 = highFreqColor_1;
    let _e214 = _e213.xyz;
    let _e215 = hf;
    let _e220 = mergeColor(mix(_e208, _e209, vec4(_e210)), vec4<f32>(_e214.x, _e214.y, _e214.z, _e215));
    return _e220;
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
    let _e66 = global.U[6];
    let _e70 = global.U[7];
    let _e74 = global.U[4];
    let _e78 = global.U[8];
    let _e82 = global.U[9];
    let _e85 = global.U[10];
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e97 = global.U[13];
    let _e98 = _e97.xyz;
    let _e112 = glassRectTiles((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82, _e85.x, mat3x3<f32>(vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z), vec3<f32>(_e98.x, _e98.y, _e98.z)));
    fragColor = _e112;
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
