struct Params {
    U: array<vec4<f32>, 9>,
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

fn pixelateGradient(pos: vec2<f32>, outPos: vec2<f32>, modelTransform: mat3x3<f32>, shapeAspectRatio: f32) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var modelTransform_1: mat3x3<f32>;
    var shapeAspectRatio_1: f32;
    var resolution: f32;
    var scale: f32;
    var scaleY: f32;
    var scaleX: f32;
    var scaleV: vec2<f32>;
    var uu: vec2<f32>;
    var du: vec2<f32>;
    var u: vec2<f32>;
    var delta: vec2<f32> = vec2<f32>(0.4f, 0f);
    var cx1_: vec4<f32>;
    var cx2_: vec4<f32>;
    var cy1_: vec4<f32>;
    var cy2_: vec4<f32>;
    var outCol: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    modelTransform_1 = modelTransform;
    shapeAspectRatio_1 = shapeAspectRatio;
    let _e18 = modelTransform_1[0][0];
    let _e23 = modelTransform_1[0][1];
    resolution = length(vec2<f32>(_e18, _e23));
    let _e28 = resolution;
    scale = (1f / _e28);
    let _e32 = shapeAspectRatio_1;
    scaleY = sqrt((1f / _e32));
    let _e37 = scaleY;
    scaleX = (1f / _e37);
    let _e40 = scaleX;
    let _e41 = scaleY;
    let _e43 = scale;
    scaleV = (vec2<f32>(_e40, _e41) * _e43);
    let _e46 = pos_1;
    let _e47 = scaleV;
    uu = floor(((_e46 / _e47) + vec2(0.5f)));
    let _e54 = pos_1;
    let _e55 = scaleV;
    let _e57 = uu;
    du = (((_e54 / _e55) - _e57) + vec2(0.5f));
    let _e63 = uu;
    let _e64 = scaleV;
    u = (_e63 * _e64);
    let _e71 = u;
    let _e72 = delta;
    let _e73 = scaleV;
    let _e79 = global.U[0];
    let _e82 = u;
    let _e83 = delta;
    let _e84 = scaleV;
    let _e95 = textureSample(t_source, samp, ((vec2<f32>(((_e71 - (_e72 * _e73)).x / _e79.x), (_e82 - (_e83 * _e84)).y) / vec2(2f)) + vec2(0.5f)));
    cx1_ = _e95;
    let _e97 = u;
    let _e98 = delta;
    let _e99 = scaleV;
    let _e105 = global.U[0];
    let _e108 = u;
    let _e109 = delta;
    let _e110 = scaleV;
    let _e121 = textureSample(t_source, samp, ((vec2<f32>(((_e97 + (_e98 * _e99)).x / _e105.x), (_e108 + (_e109 * _e110)).y) / vec2(2f)) + vec2(0.5f)));
    cx2_ = _e121;
    let _e123 = u;
    let _e124 = delta;
    let _e126 = scaleV;
    let _e132 = global.U[0];
    let _e135 = u;
    let _e136 = delta;
    let _e138 = scaleV;
    let _e149 = textureSample(t_source, samp, ((vec2<f32>(((_e123 - (_e124.yx * _e126)).x / _e132.x), (_e135 - (_e136.yx * _e138)).y) / vec2(2f)) + vec2(0.5f)));
    cy1_ = _e149;
    let _e151 = u;
    let _e152 = delta;
    let _e154 = scaleV;
    let _e160 = global.U[0];
    let _e163 = u;
    let _e164 = delta;
    let _e166 = scaleV;
    let _e177 = textureSample(t_source, samp, ((vec2<f32>(((_e151 + (_e152.yx * _e154)).x / _e160.x), (_e163 + (_e164.yx * _e166)).y) / vec2(2f)) + vec2(0.5f)));
    cy2_ = _e177;
    let _e180 = cx1_;
    let _e181 = cx2_;
    let _e184 = cy1_;
    let _e185 = cy2_;
    if (length((_e180 - _e181)) > length((_e184 - _e185))) {
        {
            let _e189 = cx1_;
            let _e190 = cx2_;
            let _e191 = du;
            outCol = mix(_e189, _e190, vec4(_e191.x));
        }
    } else {
        {
            let _e195 = cy1_;
            let _e196 = cy2_;
            let _e197 = du;
            outCol = mix(_e195, _e196, vec4(_e197.y));
        }
    }
    let _e201 = outCol;
    return _e201;
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
    let _e66 = global.U[5];
    let _e67 = _e66.xyz;
    let _e70 = global.U[6];
    let _e71 = _e70.xyz;
    let _e74 = global.U[7];
    let _e75 = _e74.xyz;
    let _e91 = global.U[8];
    let _e93 = pixelateGradient((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), mat3x3<f32>(vec3<f32>(_e67.x, _e67.y, _e67.z), vec3<f32>(_e71.x, _e71.y, _e71.z), vec3<f32>(_e75.x, _e75.y, _e75.z)), _e91.x);
    fragColor = _e93;
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
