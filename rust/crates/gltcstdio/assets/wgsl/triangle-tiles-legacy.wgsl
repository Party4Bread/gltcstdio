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

fn triangleTilesLegacy(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, pixelation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var pixelation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var invMT: mat3x3<f32>;
    var u: vec2<f32>;
    var tileWidth: f32 = 2f;
    var halfTileWidth: f32 = 1f;
    var tileHeight: f32 = 1.7320508f;
    var centerHeight: f32;
    var tileSize: vec2<f32>;
    var s: f32;
    var row: f32;
    var column: f32;
    var dx0_: f32;
    var dy0_: f32;
    var rectDown: bool;
    var cx: f32;
    var cy: f32;
    var down: bool;
    var tileCenter: vec2<f32>;
    var v: vec2<f32>;
    var p: vec2<f32>;
    var local: f32;
    var ori: f32;
    var d: f32;
    var dx: f32;
    var dy: f32;
    var scaleK: f32;
    var r0_: f32;
    var r1_: f32;
    var dp: f32;
    var r2_: f32;
    var dp_1: f32;
    var outColor: vec4<f32>;
    var tileCenterTex: vec2<f32>;
    var pixelColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    distortion_1 = distortion;
    pixelation_1 = pixelation;
    modelTransform_1 = modelTransform;
    let _e18 = modelTransform_1;
    invMT = _naga_inverse_3x3_f32(_e18);
    let _e21 = invMT;
    let _e22 = pos_1;
    u = (_e21 * vec3<f32>(_e22.x, _e22.y, 1f)).xy;
    let _e38 = tileWidth;
    centerHeight = (_e38 / 3.4641016f);
    let _e48 = modelTransform_1[0][0];
    let _e53 = modelTransform_1[1][0];
    let _e56 = tileWidth;
    let _e62 = modelTransform_1[0][1];
    let _e67 = modelTransform_1[1][1];
    let _e70 = tileHeight;
    tileSize = vec2<f32>((length(vec2<f32>(_e48, _e53)) * _e56), (length(vec2<f32>(_e62, _e67)) * _e70));
    let _e75 = intensity_1;
    let _e79 = tileSize;
    let _e83 = tileSize;
    s = (1f + ((_e75 * 0.01f) * (max((2f / _e79.x), (2f / _e83.y)) - 1f)));
    let _e92 = u;
    let _e94 = tileHeight;
    row = floor((_e92.y / _e94));
    let _e98 = u;
    let _e100 = halfTileWidth;
    column = floor((_e98.x / _e100));
    let _e104 = u;
    let _e106 = column;
    let _e107 = halfTileWidth;
    dx0_ = (_e104.x - (_e106 * _e107));
    let _e111 = u;
    let _e113 = row;
    let _e114 = tileHeight;
    dy0_ = (_e111.y - (_e113 * _e114));
    let _e118 = row;
    let _e119 = column;
    let _e120 = (_e118 + _e119);
    rectDown = ((_e120 - (floor((_e120 / 2f)) * 2f)) == 0f);
    let _e132 = rectDown;
    if _e132 {
        {
            let _e133 = dy0_;
            let _e134 = tileHeight;
            let _e135 = dx0_;
            if (_e133 > (_e134 - (_e135 * 1.7320508f))) {
                {
                    let _e140 = row;
                    let _e143 = tileHeight;
                    let _e145 = centerHeight;
                    cy = (((_e140 + 1f) * _e143) - _e145);
                    let _e147 = column;
                    let _e150 = halfTileWidth;
                    cx = ((_e147 + 1f) * _e150);
                    down = true;
                }
            } else {
                {
                    let _e153 = row;
                    let _e154 = tileHeight;
                    let _e156 = centerHeight;
                    cy = ((_e153 * _e154) + _e156);
                    let _e158 = column;
                    let _e159 = halfTileWidth;
                    cx = (_e158 * _e159);
                    down = false;
                }
            }
        }
    } else {
        {
            let _e162 = dy0_;
            let _e163 = dx0_;
            if (_e162 > (_e163 * 1.7320508f)) {
                {
                    let _e167 = row;
                    let _e170 = tileHeight;
                    let _e172 = centerHeight;
                    cy = (((_e167 + 1f) * _e170) - _e172);
                    let _e174 = column;
                    let _e175 = halfTileWidth;
                    cx = (_e174 * _e175);
                    down = true;
                }
            } else {
                {
                    let _e178 = row;
                    let _e179 = tileHeight;
                    let _e181 = centerHeight;
                    cy = ((_e178 * _e179) + _e181);
                    let _e183 = column;
                    let _e186 = halfTileWidth;
                    cx = ((_e183 + 1f) * _e186);
                    down = false;
                }
            }
        }
    }
    let _e189 = cx;
    let _e190 = cy;
    tileCenter = vec2<f32>(_e189, _e190);
    let _e193 = u;
    let _e194 = tileCenter;
    v = (_e193 - _e194);
    let _e197 = modelTransform_1;
    let _e198 = v;
    let _e199 = s;
    let _e201 = tileCenter;
    let _e202 = ((_e198 * _e199) + _e201);
    p = (_e197 * vec3<f32>(_e202.x, _e202.y, 1f)).xy;
    let _e210 = distortion_1;
    if (_e210 > 0f) {
        {
            let _e213 = down;
            if _e213 {
                local = -1f;
            } else {
                local = 1f;
            }
            let _e218 = local;
            ori = _e218;
            let _e220 = distortion_1;
            d = (_e220 * 0.01f);
            let _e224 = v;
            let _e227 = centerHeight;
            dx = (-(_e224.x) / _e227);
            let _e230 = v;
            let _e233 = centerHeight;
            dy = (-(_e230.y) / _e233);
            let _e241 = invMT[0][0];
            let _e246 = invMT[0][0];
            let _e252 = invMT[0][1];
            let _e257 = invMT[0][1];
            scaleK = (2f / sqrt(((_e241 * _e246) + (_e252 * _e257))));
            let _e263 = ori;
            let _e264 = dy;
            r0_ = (_e263 * _e264);
            let _e268 = r0_;
            let _e270 = d;
            if ((1f - _e268) < _e270) {
                {
                    let _e273 = r0_;
                    let _e275 = d;
                    r0_ = ((1f - _e273) / _e275);
                    let _e278 = p;
                    let _e280 = ori;
                    let _e281 = tileWidth;
                    let _e284 = r0_;
                    let _e288 = r0_;
                    let _e291 = scaleK;
                    p.y = (_e278.y + ((((_e280 * _e281) * (1f - _e284)) / (0.5f + _e288)) * _e291));
                }
            }
            let _e294 = dx;
            let _e298 = ori;
            let _e299 = dy;
            r1_ = ((-(_e294) * 0.8660254f) - ((_e298 * _e299) * 0.5f));
            let _e306 = r1_;
            let _e308 = d;
            if ((1f - _e306) < _e308) {
                {
                    let _e311 = r1_;
                    let _e313 = d;
                    r1_ = ((1f - _e311) / _e313);
                    let _e315 = tileWidth;
                    let _e317 = r1_;
                    let _e321 = r1_;
                    let _e324 = scaleK;
                    dp = (((_e315 * (1f - _e317)) / (0.5f + _e321)) * _e324);
                    let _e328 = p;
                    let _e332 = dp;
                    p.x = (_e328.x + (-0.8660254f * _e332));
                    let _e336 = p;
                    let _e338 = ori;
                    let _e342 = dp;
                    p.y = (_e336.y + ((-(_e338) * 0.5f) * _e342));
                }
            }
            let _e345 = dx;
            let _e348 = ori;
            let _e349 = dy;
            r2_ = ((_e345 * 0.8660254f) - ((_e348 * _e349) * 0.5f));
            let _e356 = r2_;
            let _e358 = d;
            if ((1f - _e356) < _e358) {
                {
                    let _e361 = r2_;
                    let _e363 = d;
                    r2_ = ((1f - _e361) / _e363);
                    let _e365 = tileWidth;
                    let _e367 = r2_;
                    let _e371 = r2_;
                    let _e374 = scaleK;
                    dp_1 = (((_e365 * (1f - _e367)) / (0.5f + _e371)) * _e374);
                    let _e378 = p;
                    let _e381 = dp_1;
                    p.x = (_e378.x + (0.8660254f * _e381));
                    let _e385 = p;
                    let _e387 = ori;
                    let _e391 = dp_1;
                    p.y = (_e385.y + ((-(_e387) * 0.5f) * _e391));
                }
            }
        }
    }
    let _e394 = p;
    let _e398 = global.U[0];
    let _e401 = p;
    let _e410 = _mirror_wrap(((vec2<f32>((_e394.x / _e398.x), _e401.y) / vec2(2f)) + vec2(0.5f)));
    let _e411 = textureSample(t_source, samp, _e410);
    outColor = _e411;
    let _e413 = pixelation_1;
    if (_e413 != 0f) {
        {
            let _e416 = modelTransform_1;
            let _e417 = tileCenter;
            tileCenterTex = (_e416 * vec3<f32>(_e417.x, _e417.y, 1f)).xy;
            let _e425 = tileCenterTex;
            let _e429 = global.U[0];
            let _e432 = tileCenterTex;
            let _e441 = _mirror_wrap(((vec2<f32>((_e425.x / _e429.x), _e432.y) / vec2(2f)) + vec2(0.5f)));
            let _e442 = textureSample(t_source, samp, _e441);
            pixelColor = _e442;
            let _e444 = outColor;
            let _e445 = pixelColor;
            let _e446 = pixelation_1;
            outColor = mix(_e444, _e445, vec4(_e446));
        }
    }
    let _e449 = outColor;
    return _e449;
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
    let _e74 = global.U[7];
    let _e78 = global.U[8];
    let _e79 = _e78.xyz;
    let _e82 = global.U[9];
    let _e83 = _e82.xyz;
    let _e86 = global.U[10];
    let _e87 = _e86.xyz;
    let _e101 = triangleTilesLegacy((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
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
