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

fn hexTilesLegacy(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, pixelation: f32, modelTransform: mat3x3<f32>) -> vec4<f32> {
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
    var X: f32;
    var Y: f32;
    var row: f32;
    var column: f32;
    var dx0_: f32;
    var dy0_: f32;
    var rectDown: bool;
    var cx: f32;
    var cy: f32;
    var down: bool;
    var hcx: f32 = 0f;
    var hcy: f32 = 0f;
    var tripos: i32;
    var dx: f32;
    var dy: f32;
    var ccx: f32;
    var ccy: f32;
    var tileSize: vec2<f32>;
    var s: f32;
    var tileCenter: vec2<f32>;
    var v: vec2<f32>;
    var p: vec2<f32>;
    var d: f32;
    var ndx: f32;
    var ndy: f32;
    var ncx: f32;
    var ncy: f32;
    var r: f32;
    var scaleK: f32;
    var dp: f32;
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
    let _e44 = u;
    X = _e44.x;
    let _e47 = u;
    Y = _e47.y;
    let _e50 = Y;
    let _e51 = tileHeight;
    row = floor((_e50 / _e51));
    let _e55 = X;
    let _e56 = halfTileWidth;
    column = floor((_e55 / _e56));
    let _e60 = X;
    let _e61 = column;
    let _e62 = halfTileWidth;
    dx0_ = (_e60 - (_e61 * _e62));
    let _e66 = Y;
    let _e67 = row;
    let _e68 = tileHeight;
    dy0_ = (_e66 - (_e67 * _e68));
    let _e72 = row;
    let _e73 = column;
    let _e74 = (_e72 + _e73);
    rectDown = ((_e74 - (floor((_e74 / 2f)) * 2f)) == 0f);
    let _e86 = rectDown;
    if _e86 {
        {
            let _e87 = dy0_;
            let _e88 = tileHeight;
            let _e89 = dx0_;
            if (_e87 > (_e88 - (_e89 * 1.7320508f))) {
                {
                    let _e94 = row;
                    let _e97 = tileHeight;
                    let _e99 = centerHeight;
                    cy = (((_e94 + 1f) * _e97) - _e99);
                    let _e101 = column;
                    let _e104 = halfTileWidth;
                    cx = ((_e101 + 1f) * _e104);
                    down = true;
                }
            } else {
                {
                    let _e107 = row;
                    let _e108 = tileHeight;
                    let _e110 = centerHeight;
                    cy = ((_e107 * _e108) + _e110);
                    let _e112 = column;
                    let _e113 = halfTileWidth;
                    cx = (_e112 * _e113);
                    down = false;
                }
            }
        }
    } else {
        {
            let _e116 = dy0_;
            let _e117 = dx0_;
            if (_e116 > (_e117 * 1.7320508f)) {
                {
                    let _e121 = row;
                    let _e124 = tileHeight;
                    let _e126 = centerHeight;
                    cy = (((_e121 + 1f) * _e124) - _e126);
                    let _e128 = column;
                    let _e129 = halfTileWidth;
                    cx = (_e128 * _e129);
                    down = true;
                }
            } else {
                {
                    let _e132 = row;
                    let _e133 = tileHeight;
                    let _e135 = centerHeight;
                    cy = ((_e132 * _e133) + _e135);
                    let _e137 = column;
                    let _e140 = halfTileWidth;
                    cx = ((_e137 + 1f) * _e140);
                    down = false;
                }
            }
        }
    }
    let _e147 = column;
    let _e149 = row;
    let _e151 = (_e147 + (3f * _e149));
    tripos = i32((_e151 - (floor((_e151 / 6f)) * 6f)));
    let _e159 = tripos;
    if (_e159 == 2i) {
        {
            let _e162 = column;
            let _e163 = halfTileWidth;
            hcx = (_e162 * _e163);
            let _e165 = row;
            let _e168 = tileHeight;
            hcy = ((_e165 + 1f) * _e168);
        }
    } else {
        let _e170 = tripos;
        if (_e170 == 1i) {
            {
                let _e173 = column;
                let _e176 = halfTileWidth;
                hcx = ((_e173 + 1f) * _e176);
                let _e178 = row;
                let _e181 = tileHeight;
                hcy = ((_e178 + 1f) * _e181);
            }
        } else {
            let _e183 = tripos;
            if (_e183 == 0i) {
                {
                    let _e186 = down;
                    if _e186 {
                        {
                            let _e187 = column;
                            let _e190 = halfTileWidth;
                            hcx = ((_e187 + 2f) * _e190);
                            let _e192 = row;
                            let _e195 = tileHeight;
                            hcy = ((_e192 + 1f) * _e195);
                        }
                    } else {
                        {
                            let _e197 = column;
                            let _e200 = halfTileWidth;
                            hcx = ((_e197 - 1f) * _e200);
                            let _e202 = row;
                            let _e203 = tileHeight;
                            hcy = (_e202 * _e203);
                        }
                    }
                }
            } else {
                let _e205 = tripos;
                if (_e205 == 5i) {
                    {
                        let _e208 = column;
                        let _e209 = halfTileWidth;
                        hcx = (_e208 * _e209);
                        let _e211 = row;
                        let _e212 = tileHeight;
                        hcy = (_e211 * _e212);
                    }
                } else {
                    let _e214 = tripos;
                    if (_e214 == 4i) {
                        {
                            let _e217 = column;
                            let _e220 = halfTileWidth;
                            hcx = ((_e217 + 1f) * _e220);
                            let _e222 = row;
                            let _e223 = tileHeight;
                            hcy = (_e222 * _e223);
                        }
                    } else {
                        {
                            let _e225 = down;
                            if _e225 {
                                {
                                    let _e226 = column;
                                    let _e229 = halfTileWidth;
                                    hcx = ((_e226 - 1f) * _e229);
                                    let _e231 = row;
                                    let _e234 = tileHeight;
                                    hcy = ((_e231 + 1f) * _e234);
                                }
                            } else {
                                {
                                    let _e236 = column;
                                    let _e239 = halfTileWidth;
                                    hcx = ((_e236 + 2f) * _e239);
                                    let _e241 = row;
                                    let _e242 = tileHeight;
                                    hcy = (_e241 * _e242);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e244 = X;
    let _e245 = hcx;
    dx = (_e244 - _e245);
    let _e248 = Y;
    let _e249 = hcy;
    dy = (_e248 - _e249);
    let _e252 = cx;
    let _e253 = hcx;
    ccx = (_e252 - _e253);
    let _e256 = cy;
    let _e257 = hcy;
    ccy = (_e256 - _e257);
    let _e264 = modelTransform_1[0][0];
    let _e269 = modelTransform_1[1][0];
    let _e272 = tileWidth;
    let _e278 = modelTransform_1[0][1];
    let _e283 = modelTransform_1[1][1];
    let _e286 = tileHeight;
    tileSize = vec2<f32>((length(vec2<f32>(_e264, _e269)) * _e272), (length(vec2<f32>(_e278, _e283)) * _e286));
    let _e291 = intensity_1;
    let _e295 = tileSize;
    let _e299 = tileSize;
    s = (1f + ((_e291 * 0.01f) * (max((2f / _e295.x), (2f / _e299.y)) - 1f)));
    let _e308 = hcx;
    let _e309 = hcy;
    tileCenter = vec2<f32>(_e308, _e309);
    let _e312 = dx;
    let _e313 = dy;
    v = vec2<f32>(_e312, _e313);
    let _e316 = modelTransform_1;
    let _e317 = v;
    let _e318 = s;
    let _e320 = tileCenter;
    let _e321 = ((_e317 * _e318) + _e320);
    p = (_e316 * vec3<f32>(_e321.x, _e321.y, 1f)).xy;
    let _e329 = distortion_1;
    if (_e329 > 0f) {
        {
            let _e332 = distortion_1;
            d = (_e332 * 0.01f);
            let _e336 = dx;
            let _e337 = tileHeight;
            ndx = (_e336 / _e337);
            let _e340 = dy;
            let _e341 = tileHeight;
            ndy = (_e340 / _e341);
            let _e344 = ccx;
            let _e345 = tileHeight;
            let _e346 = centerHeight;
            ncx = (_e344 / (_e345 - _e346));
            let _e350 = ccy;
            let _e351 = tileHeight;
            let _e352 = centerHeight;
            ncy = (_e350 / (_e351 - _e352));
            let _e356 = ndx;
            let _e357 = ncx;
            let _e359 = ndy;
            let _e360 = ncy;
            r = ((_e356 * _e357) + (_e359 * _e360));
            let _e365 = r;
            let _e367 = d;
            if ((1f - _e365) < _e367) {
                {
                    let _e374 = invMT[0][0];
                    let _e379 = invMT[0][0];
                    let _e385 = invMT[0][1];
                    let _e390 = invMT[0][1];
                    scaleK = (2f / sqrt(((_e374 * _e379) + (_e385 * _e390))));
                    let _e397 = r;
                    let _e399 = d;
                    r = ((1f - _e397) / _e399);
                    let _e401 = tileWidth;
                    let _e403 = r;
                    let _e407 = r;
                    let _e410 = scaleK;
                    dp = (((_e401 * (1f - _e403)) / (0.5f + _e407)) * _e410);
                    let _e414 = p;
                    let _e416 = ncx;
                    let _e417 = dp;
                    p.x = (_e414.x + (_e416 * _e417));
                    let _e421 = p;
                    let _e423 = ncy;
                    let _e424 = dp;
                    p.y = (_e421.y + (_e423 * _e424));
                }
            }
        }
    }
    let _e427 = p;
    let _e431 = global.U[0];
    let _e434 = p;
    let _e443 = _mirror_wrap(((vec2<f32>((_e427.x / _e431.x), _e434.y) / vec2(2f)) + vec2(0.5f)));
    let _e444 = textureSample(t_source, samp, _e443);
    outColor = _e444;
    let _e446 = pixelation_1;
    if (_e446 != 0f) {
        {
            let _e449 = modelTransform_1;
            let _e450 = tileCenter;
            tileCenterTex = (_e449 * vec3<f32>(_e450.x, _e450.y, 1f)).xy;
            let _e458 = tileCenterTex;
            let _e462 = global.U[0];
            let _e465 = tileCenterTex;
            let _e474 = _mirror_wrap(((vec2<f32>((_e458.x / _e462.x), _e465.y) / vec2(2f)) + vec2(0.5f)));
            let _e475 = textureSample(t_source, samp, _e474);
            pixelColor = _e475;
            let _e477 = outColor;
            let _e478 = pixelColor;
            let _e479 = pixelation_1;
            outColor = mix(_e477, _e478, vec4(_e479));
        }
    }
    let _e482 = outColor;
    return _e482;
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
    let _e101 = hexTilesLegacy((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)));
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
