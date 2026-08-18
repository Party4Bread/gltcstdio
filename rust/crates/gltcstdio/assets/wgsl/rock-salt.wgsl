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

fn tf(m: mat3x3<f32>, u: vec2<f32>) -> vec2<f32> {
    var m_1: mat3x3<f32>;
    var u_1: vec2<f32>;

    m_1 = m;
    u_1 = u;
    let _e10 = m_1;
    let _e11 = u_1;
    return (_e10 * vec3<f32>(_e11.x, _e11.y, 1f)).xy;
}

fn rockSalt(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, iterations: i32, shapeAspectRatio: f32, distortion: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var iterations_1: i32;
    var shapeAspectRatio_1: f32;
    var distortion_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var inverseModelTransform: mat3x3<f32>;
    var u_2: vec2<f32>;
    var tileWidth: f32 = 2f;
    var tileHeight: f32;
    var tileSize: vec2<f32>;
    var s: f32;
    var tileCenter: vec2<f32>;
    var p: vec2<f32>;
    var i: i32 = 0i;
    var row: f32;
    var column: f32;
    var v: vec2<f32>;
    var r: vec2<f32>;
    var borderX: bool;
    var borderY: bool;
    var d: f32;
    var outColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    iterations_1 = iterations;
    shapeAspectRatio_1 = shapeAspectRatio;
    distortion_1 = distortion;
    modelTransform_1 = modelTransform;
    let _e20 = modelTransform_1;
    inverseModelTransform = _naga_inverse_3x3_f32(_e20);
    let _e23 = inverseModelTransform;
    let _e24 = pos_1;
    let _e25 = tf(_e23, _e24);
    u_2 = _e25;
    let _e30 = shapeAspectRatio_1;
    tileHeight = (2f * _e30);
    let _e37 = modelTransform_1[0][0];
    let _e42 = modelTransform_1[1][0];
    let _e45 = tileWidth;
    let _e51 = modelTransform_1[0][1];
    let _e56 = modelTransform_1[1][1];
    let _e59 = tileHeight;
    tileSize = vec2<f32>((length(vec2<f32>(_e37, _e42)) * _e45), (length(vec2<f32>(_e51, _e56)) * _e59));
    let _e63 = intensity_1;
    intensity_1 = (_e63 * 0.1f);
    let _e67 = intensity_1;
    s = (1f + _e67);
    loop {
        let _e74 = i;
        let _e75 = iterations_1;
        if !((_e74 < _e75)) {
            break;
        }
        {
            let _e81 = u_2;
            let _e83 = tileHeight;
            row = floor((_e81.y / _e83));
            let _e87 = u_2;
            let _e89 = tileWidth;
            column = floor((_e87.x / _e89));
            let _e93 = column;
            let _e96 = tileWidth;
            let _e98 = row;
            let _e101 = tileHeight;
            tileCenter = vec2<f32>(((_e93 + 0.5f) * _e96), ((_e98 + 0.5f) * _e101));
            let _e104 = u_2;
            let _e105 = tileCenter;
            v = (_e104 - _e105);
            let _e108 = modelTransform_1;
            let _e109 = v;
            let _e110 = s;
            let _e112 = tileCenter;
            let _e113 = ((_e109 * _e110) + _e112);
            p = (_e108 * vec3<f32>(_e113.x, _e113.y, 1f)).xy;
            borderX = false;
            borderY = false;
            let _e125 = distortion_1;
            if (_e125 > 0f) {
                {
                    let _e128 = distortion_1;
                    d = _e128;
                    let _e130 = v;
                    let _e131 = tileWidth;
                    let _e132 = tileHeight;
                    r = ((_e130 / vec2<f32>(_e131, _e132)) + vec2<f32>(0.5f, 0.5f));
                    let _e139 = r;
                    let _e141 = d;
                    if (_e139.x < (_e141 / 2f)) {
                        {
                            let _e147 = r;
                            let _e150 = d;
                            r.x = ((2f * _e147.x) / _e150);
                            borderX = true;
                            let _e154 = p;
                            let _e156 = tileSize;
                            let _e159 = r;
                            let _e164 = r;
                            p.x = (_e154.x - ((_e156.x * (1f - _e159.x)) / (0.5f + _e164.x)));
                        }
                    } else {
                        let _e169 = r;
                        let _e172 = d;
                        if (_e169.x > (1f - (_e172 / 2f))) {
                            {
                                let _e180 = r;
                                let _e184 = d;
                                r.x = ((2f * (1f - _e180.x)) / _e184);
                                borderX = true;
                                let _e188 = p;
                                let _e190 = tileSize;
                                let _e193 = r;
                                let _e198 = r;
                                p.x = (_e188.x + ((_e190.x * (1f - _e193.x)) / (0.5f + _e198.x)));
                            }
                        }
                    }
                    let _e203 = r;
                    let _e205 = d;
                    if (_e203.y < (_e205 / 2f)) {
                        {
                            let _e211 = r;
                            let _e214 = d;
                            r.y = ((2f * _e211.y) / _e214);
                            borderY = true;
                            let _e218 = p;
                            let _e220 = tileSize;
                            let _e223 = r;
                            let _e228 = r;
                            p.y = (_e218.y - ((_e220.y * (1f - _e223.y)) / (0.5f + _e228.y)));
                        }
                    } else {
                        let _e233 = r;
                        let _e236 = d;
                        if (_e233.y > (1f - (_e236 / 2f))) {
                            {
                                let _e244 = r;
                                let _e248 = d;
                                r.y = ((2f * (1f - _e244.y)) / _e248);
                                borderY = true;
                                let _e252 = p;
                                let _e254 = tileSize;
                                let _e257 = r;
                                let _e262 = r;
                                p.y = (_e252.y + ((_e254.y * (1f - _e257.y)) / (0.5f + _e262.y)));
                            }
                        }
                    }
                }
            }
            let _e267 = inverseModelTransform;
            let _e268 = p;
            u_2 = (_e267 * vec3<f32>(_e268.x, _e268.y, 1f)).xy;
        }
        continuing {
            let _e78 = i;
            i = (_e78 + 1i);
        }
    }
    let _e275 = p;
    let _e279 = global.U[0];
    let _e282 = p;
    let _e291 = textureSample(t_source, samp, ((vec2<f32>((_e275.x / _e279.x), _e282.y) / vec2(2f)) + vec2(0.5f)));
    outColor = _e291;
    let _e293 = outColor;
    return _e293;
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
    let _e70 = global.U[6];
    let _e75 = global.U[7];
    let _e79 = global.U[8];
    let _e83 = global.U[9];
    let _e84 = _e83.xyz;
    let _e87 = global.U[10];
    let _e88 = _e87.xyz;
    let _e91 = global.U[11];
    let _e92 = _e91.xyz;
    let _e106 = rockSalt((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, i32(_e70.x), _e75.x, _e79.x, mat3x3<f32>(vec3<f32>(_e84.x, _e84.y, _e84.z), vec3<f32>(_e88.x, _e88.y, _e88.z), vec3<f32>(_e92.x, _e92.y, _e92.z)));
    fragColor = _e106;
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
