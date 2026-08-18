struct Params {
    U: array<vec4<f32>, 13>,
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

fn triangleTile(v: vec2<f32>) -> TriangleTile {
    var v_1: vec2<f32>;
    var r: vec2<f32> = vec2<f32>(1f, 0.8660254f);
    var offset: f32;
    var a: vec2<f32>;
    var up: bool;
    var local: f32;
    var local_1: vec2<f32>;
    var hv: vec2<f32>;
    var center: vec2<f32>;
    var local_2: f32;
    var borderDist: f32;
    var angle: f32;
    var dist: f32;

    v_1 = v;
    let _e12 = v_1;
    offset = (floor((_e12.y / 0.8660254f)) * 0.5f);
    let _e20 = v_1;
    let _e21 = offset;
    let _e24 = (_e20 + vec2<f32>(_e21, 0f));
    let _e25 = r;
    a = (_e24 - (floor((_e24 / _e25)) * _e25));
    let _e33 = a;
    let _e40 = a;
    up = ((0.8660254f - (abs((0.5f - _e33.x)) * 1.7320508f)) > _e40.y);
    let _e44 = up;
    if _e44 {
        let _e45 = a;
        let _e49 = a;
        local_1 = vec2<f32>((_e45.x - 0.5f), (_e49.y - 0.28867513f));
    } else {
        let _e54 = a;
        if (_e54.x < 0.5f) {
            let _e58 = a;
            local = _e58.x;
        } else {
            let _e60 = a;
            local = (_e60.x - 1f);
        }
        let _e65 = local;
        let _e66 = a;
        local_1 = vec2<f32>(_e65, (_e66.y - 0.57735026f));
    }
    let _e74 = local_1;
    hv = _e74;
    let _e76 = v_1;
    let _e77 = hv;
    center = (_e76 - _e77);
    let _e80 = up;
    if _e80 {
        let _e86 = hv;
        let _e93 = hv;
        let _e98 = hv;
        local_2 = min(min((0.28867513f - dot(vec2<f32>(-0.8660254f, 0.5f), _e86)), (0.28867513f - dot(vec2<f32>(0.8660254f, 0.5f), _e93))), (0.28867513f + _e98.y));
    } else {
        let _e108 = hv;
        let _e116 = hv;
        let _e121 = hv;
        local_2 = min(min((0.28867513f - dot(vec2<f32>(-0.8660254f, -0.5f), _e108)), (0.28867513f - dot(vec2<f32>(0.8660254f, -0.5f), _e116))), (0.28867513f - _e121.y));
    }
    let _e126 = local_2;
    borderDist = _e126;
    let _e128 = hv;
    let _e130 = hv;
    angle = atan2(_e128.y, _e130.x);
    let _e134 = hv;
    dist = length(_e134);
    let _e137 = up;
    let _e138 = center;
    let _e139 = hv;
    let _e140 = angle;
    let _e141 = dist;
    let _e142 = borderDist;
    return TriangleTile(_e137, _e138, _e139, _e140, _e141, _e142);
}

fn glassTriangleTiles(uv: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, outAspectRatio: f32, pixelation: f32, highFreqColor: vec4<f32>, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var uv_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var outAspectRatio_1: f32;
    var pixelation_1: f32;
    var highFreqColor_1: vec4<f32>;
    var modelTransform_1: mat3x3<f32>;
    var t: mat3x3<f32>;
    var u_2: vec2<f32>;
    var v_2: vec2<f32>;
    var tileSize: f32;
    var maxTileViewSize: f32;
    var viewSize: f32;
    var tile: TriangleTile;
    var distort: f32;
    var local_3: vec2<f32>;
    var center_1: vec2<f32>;
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
    modelTransform_1 = modelTransform;
    let _e22 = modelTransform_1;
    t = _naga_inverse_3x3_f32(_e22);
    let _e25 = uv_1;
    u_2 = _e25;
    let _e27 = t;
    let _e28 = uv_1;
    let _e29 = tf(_e27, _e28);
    v_2 = _e29;
    let _e33 = modelTransform_1[0];
    tileSize = ((length(_e33.xy) * 1f) / 0.8660254f);
    let _e41 = outAspectRatio_1;
    maxTileViewSize = min(_e41, 1f);
    let _e45 = tileSize;
    let _e46 = maxTileViewSize;
    let _e47 = intensity_1;
    viewSize = mix(_e45, _e46, _e47);
    let _e50 = v_2;
    let _e51 = triangleTile(_e50);
    tile = _e51;
    let _e54 = distortion_1;
    let _e55 = tile;
    distort = max(1f, (_e54 / _e55.borderDist));
    let _e60 = modelTransform_1;
    let _e61 = tile;
    let _e63 = tf(_e60, _e61.center);
    let _e64 = tileSize;
    let _e65 = maxTileViewSize;
    if (_e64 >= _e65) {
        local_3 = vec2(1f);
    } else {
        let _e69 = outAspectRatio_1;
        let _e72 = viewSize;
        let _e77 = outAspectRatio_1;
        let _e80 = tileSize;
        local_3 = ((vec2<f32>(_e69, 1f) - vec2((_e72 * 0.5f))) / (vec2<f32>(_e77, 1f) - vec2((_e80 * 0.5f))));
    }
    let _e87 = local_3;
    center_1 = (_e63 * _e87);
    let _e90 = viewSize;
    let _e91 = tileSize;
    scale = (_e90 / _e91);
    let _e94 = center_1;
    let _e98 = global.U[0];
    let _e101 = center_1;
    let _e110 = _mirror_wrap(((vec2<f32>((_e94.x / _e98.x), _e101.y) / vec2(2f)) + vec2(0.5f)));
    let _e111 = textureSample(t_source, samp, _e110);
    pixColor = _e111;
    let _e113 = center_1;
    let _e114 = modelTransform_1;
    let _e122 = tile;
    let _e125 = distort;
    let _e127 = scale;
    w = (_e113 + (((mat2x2<f32>(_e114[0].xy, _e114[1].xy) * _e122.pos) * _e125) * _e127));
    let _e131 = w;
    let _e135 = global.U[0];
    let _e138 = w;
    let _e147 = _mirror_wrap(((vec2<f32>((_e131.x / _e135.x), _e138.y) / vec2(2f)) + vec2(0.5f)));
    let _e148 = textureSample(t_source, samp, _e147);
    col = _e148;
    let _e152 = highFreqColor_1;
    if (_e152.w > 0f) {
        {
            let _e157 = highFreqColor_1;
            hfThreshold = (2f / _e157.w);
            let _e161 = hfThreshold;
            let _e162 = hfThreshold;
            let _e165 = distort;
            hf = smoothstep(_e161, (_e162 * 10f), _e165);
        }
    }
    let _e167 = col;
    let _e168 = pixColor;
    let _e169 = pixelation_1;
    let _e172 = highFreqColor_1;
    let _e173 = _e172.xyz;
    let _e174 = hf;
    let _e179 = mergeColor(mix(_e167, _e168, vec4(_e169)), vec4<f32>(_e173.x, _e173.y, _e173.z, _e174));
    return _e179;
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
    let _e86 = _e85.xyz;
    let _e89 = global.U[11];
    let _e90 = _e89.xyz;
    let _e93 = global.U[12];
    let _e94 = _e93.xyz;
    let _e108 = glassTriangleTiles((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, _e78.x, _e82, mat3x3<f32>(vec3<f32>(_e86.x, _e86.y, _e86.z), vec3<f32>(_e90.x, _e90.y, _e90.z), vec3<f32>(_e94.x, _e94.y, _e94.z)));
    fragColor = _e108;
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
