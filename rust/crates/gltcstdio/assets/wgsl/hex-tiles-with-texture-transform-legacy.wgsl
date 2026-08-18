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

fn hexTilesWithTextureTransformLegacy(pos: vec2<f32>, outPos: vec2<f32>, intensity: f32, distortion: f32, pixelation: f32, modelTransform: mat3x3<f32>, sampleTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var intensity_1: f32;
    var distortion_1: f32;
    var pixelation_1: f32;
    var modelTransform_1: mat3x3<f32>;
    var sampleTransform_1: mat3x3<f32>;
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
    var invST: mat3x3<f32>;
    var outColor: vec4<f32>;
    var tileCenterTex: vec2<f32>;
    var pixelColor: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    intensity_1 = intensity;
    distortion_1 = distortion;
    pixelation_1 = pixelation;
    modelTransform_1 = modelTransform;
    sampleTransform_1 = sampleTransform;
    let _e20 = modelTransform_1;
    invMT = _naga_inverse_3x3_f32(_e20);
    let _e23 = invMT;
    let _e24 = pos_1;
    u = (_e23 * vec3<f32>(_e24.x, _e24.y, 1f)).xy;
    let _e40 = tileWidth;
    centerHeight = (_e40 / 3.4641016f);
    let _e46 = u;
    X = _e46.x;
    let _e49 = u;
    Y = _e49.y;
    let _e52 = Y;
    let _e53 = tileHeight;
    row = floor((_e52 / _e53));
    let _e57 = X;
    let _e58 = halfTileWidth;
    column = floor((_e57 / _e58));
    let _e62 = X;
    let _e63 = column;
    let _e64 = halfTileWidth;
    dx0_ = (_e62 - (_e63 * _e64));
    let _e68 = Y;
    let _e69 = row;
    let _e70 = tileHeight;
    dy0_ = (_e68 - (_e69 * _e70));
    let _e74 = row;
    let _e75 = column;
    let _e76 = (_e74 + _e75);
    rectDown = ((_e76 - (floor((_e76 / 2f)) * 2f)) == 0f);
    let _e88 = rectDown;
    if _e88 {
        {
            let _e89 = dy0_;
            let _e90 = tileHeight;
            let _e91 = dx0_;
            if (_e89 > (_e90 - (_e91 * 1.7320508f))) {
                {
                    let _e96 = row;
                    let _e99 = tileHeight;
                    let _e101 = centerHeight;
                    cy = (((_e96 + 1f) * _e99) - _e101);
                    let _e103 = column;
                    let _e106 = halfTileWidth;
                    cx = ((_e103 + 1f) * _e106);
                    down = true;
                }
            } else {
                {
                    let _e109 = row;
                    let _e110 = tileHeight;
                    let _e112 = centerHeight;
                    cy = ((_e109 * _e110) + _e112);
                    let _e114 = column;
                    let _e115 = halfTileWidth;
                    cx = (_e114 * _e115);
                    down = false;
                }
            }
        }
    } else {
        {
            let _e118 = dy0_;
            let _e119 = dx0_;
            if (_e118 > (_e119 * 1.7320508f)) {
                {
                    let _e123 = row;
                    let _e126 = tileHeight;
                    let _e128 = centerHeight;
                    cy = (((_e123 + 1f) * _e126) - _e128);
                    let _e130 = column;
                    let _e131 = halfTileWidth;
                    cx = (_e130 * _e131);
                    down = true;
                }
            } else {
                {
                    let _e134 = row;
                    let _e135 = tileHeight;
                    let _e137 = centerHeight;
                    cy = ((_e134 * _e135) + _e137);
                    let _e139 = column;
                    let _e142 = halfTileWidth;
                    cx = ((_e139 + 1f) * _e142);
                    down = false;
                }
            }
        }
    }
    let _e149 = column;
    let _e151 = row;
    let _e153 = (_e149 + (3f * _e151));
    tripos = i32((_e153 - (floor((_e153 / 6f)) * 6f)));
    let _e161 = tripos;
    if (_e161 == 2i) {
        {
            let _e164 = column;
            let _e165 = halfTileWidth;
            hcx = (_e164 * _e165);
            let _e167 = row;
            let _e170 = tileHeight;
            hcy = ((_e167 + 1f) * _e170);
        }
    } else {
        let _e172 = tripos;
        if (_e172 == 1i) {
            {
                let _e175 = column;
                let _e178 = halfTileWidth;
                hcx = ((_e175 + 1f) * _e178);
                let _e180 = row;
                let _e183 = tileHeight;
                hcy = ((_e180 + 1f) * _e183);
            }
        } else {
            let _e185 = tripos;
            if (_e185 == 0i) {
                {
                    let _e188 = down;
                    if _e188 {
                        {
                            let _e189 = column;
                            let _e192 = halfTileWidth;
                            hcx = ((_e189 + 2f) * _e192);
                            let _e194 = row;
                            let _e197 = tileHeight;
                            hcy = ((_e194 + 1f) * _e197);
                        }
                    } else {
                        {
                            let _e199 = column;
                            let _e202 = halfTileWidth;
                            hcx = ((_e199 - 1f) * _e202);
                            let _e204 = row;
                            let _e205 = tileHeight;
                            hcy = (_e204 * _e205);
                        }
                    }
                }
            } else {
                let _e207 = tripos;
                if (_e207 == 5i) {
                    {
                        let _e210 = column;
                        let _e211 = halfTileWidth;
                        hcx = (_e210 * _e211);
                        let _e213 = row;
                        let _e214 = tileHeight;
                        hcy = (_e213 * _e214);
                    }
                } else {
                    let _e216 = tripos;
                    if (_e216 == 4i) {
                        {
                            let _e219 = column;
                            let _e222 = halfTileWidth;
                            hcx = ((_e219 + 1f) * _e222);
                            let _e224 = row;
                            let _e225 = tileHeight;
                            hcy = (_e224 * _e225);
                        }
                    } else {
                        {
                            let _e227 = down;
                            if _e227 {
                                {
                                    let _e228 = column;
                                    let _e231 = halfTileWidth;
                                    hcx = ((_e228 - 1f) * _e231);
                                    let _e233 = row;
                                    let _e236 = tileHeight;
                                    hcy = ((_e233 + 1f) * _e236);
                                }
                            } else {
                                {
                                    let _e238 = column;
                                    let _e241 = halfTileWidth;
                                    hcx = ((_e238 + 2f) * _e241);
                                    let _e243 = row;
                                    let _e244 = tileHeight;
                                    hcy = (_e243 * _e244);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e246 = X;
    let _e247 = hcx;
    dx = (_e246 - _e247);
    let _e250 = Y;
    let _e251 = hcy;
    dy = (_e250 - _e251);
    let _e254 = cx;
    let _e255 = hcx;
    ccx = (_e254 - _e255);
    let _e258 = cy;
    let _e259 = hcy;
    ccy = (_e258 - _e259);
    let _e266 = modelTransform_1[0][0];
    let _e271 = modelTransform_1[1][0];
    let _e274 = tileWidth;
    let _e280 = modelTransform_1[0][1];
    let _e285 = modelTransform_1[1][1];
    let _e288 = tileHeight;
    tileSize = vec2<f32>((length(vec2<f32>(_e266, _e271)) * _e274), (length(vec2<f32>(_e280, _e285)) * _e288));
    let _e293 = intensity_1;
    let _e297 = tileSize;
    let _e301 = tileSize;
    s = (1f + ((_e293 * 0.01f) * (max((2f / _e297.x), (2f / _e301.y)) - 1f)));
    let _e310 = hcx;
    let _e311 = hcy;
    tileCenter = vec2<f32>(_e310, _e311);
    let _e314 = dx;
    let _e315 = dy;
    v = vec2<f32>(_e314, _e315);
    let _e318 = modelTransform_1;
    let _e319 = v;
    let _e320 = s;
    let _e322 = tileCenter;
    let _e323 = ((_e319 * _e320) + _e322);
    p = (_e318 * vec3<f32>(_e323.x, _e323.y, 1f)).xy;
    let _e331 = distortion_1;
    if (_e331 > 0f) {
        {
            let _e334 = distortion_1;
            d = (_e334 * 0.01f);
            let _e338 = dx;
            let _e339 = tileHeight;
            ndx = (_e338 / _e339);
            let _e342 = dy;
            let _e343 = tileHeight;
            ndy = (_e342 / _e343);
            let _e346 = ccx;
            let _e347 = tileHeight;
            let _e348 = centerHeight;
            ncx = (_e346 / (_e347 - _e348));
            let _e352 = ccy;
            let _e353 = tileHeight;
            let _e354 = centerHeight;
            ncy = (_e352 / (_e353 - _e354));
            let _e358 = ndx;
            let _e359 = ncx;
            let _e361 = ndy;
            let _e362 = ncy;
            r = ((_e358 * _e359) + (_e361 * _e362));
            let _e367 = r;
            let _e369 = d;
            if ((1f - _e367) < _e369) {
                {
                    let _e376 = invMT[0][0];
                    let _e381 = invMT[0][0];
                    let _e387 = invMT[0][1];
                    let _e392 = invMT[0][1];
                    scaleK = (2f / sqrt(((_e376 * _e381) + (_e387 * _e392))));
                    let _e399 = r;
                    let _e401 = d;
                    r = ((1f - _e399) / _e401);
                    let _e403 = tileWidth;
                    let _e405 = r;
                    let _e409 = r;
                    let _e412 = scaleK;
                    dp = (((_e403 * (1f - _e405)) / (0.5f + _e409)) * _e412);
                    let _e416 = p;
                    let _e418 = ncx;
                    let _e419 = dp;
                    p.x = (_e416.x + (_e418 * _e419));
                    let _e423 = p;
                    let _e425 = ncy;
                    let _e426 = dp;
                    p.y = (_e423.y + (_e425 * _e426));
                }
            }
        }
    }
    let _e429 = sampleTransform_1;
    invST = _naga_inverse_3x3_f32(_e429);
    let _e432 = invST;
    let _e433 = p;
    let _e438 = (_e432 * vec3<f32>(_e433.x, _e433.y, 1f));
    let _e443 = global.U[0];
    let _e446 = invST;
    let _e447 = p;
    let _e452 = (_e446 * vec3<f32>(_e447.x, _e447.y, 1f));
    let _e462 = _mirror_wrap(((vec2<f32>((_e438.x / _e443.x), _e452.y) / vec2(2f)) + vec2(0.5f)));
    let _e463 = textureSample(t_source, samp, _e462);
    outColor = _e463;
    let _e465 = pixelation_1;
    if (_e465 != 0f) {
        {
            let _e468 = modelTransform_1;
            let _e469 = tileCenter;
            tileCenterTex = (_e468 * vec3<f32>(_e469.x, _e469.y, 1f)).xy;
            let _e477 = invST;
            let _e478 = tileCenterTex;
            let _e483 = (_e477 * vec3<f32>(_e478.x, _e478.y, 1f));
            let _e488 = global.U[0];
            let _e491 = invST;
            let _e492 = tileCenterTex;
            let _e497 = (_e491 * vec3<f32>(_e492.x, _e492.y, 1f));
            let _e507 = _mirror_wrap(((vec2<f32>((_e483.x / _e488.x), _e497.y) / vec2(2f)) + vec2(0.5f)));
            let _e508 = textureSample(t_source, samp, _e507);
            pixelColor = _e508;
            let _e510 = outColor;
            let _e511 = pixelColor;
            let _e512 = pixelation_1;
            outColor = mix(_e510, _e511, vec4(_e512));
        }
    }
    let _e515 = outColor;
    return _e515;
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
    let _e103 = global.U[11];
    let _e104 = _e103.xyz;
    let _e107 = global.U[12];
    let _e108 = _e107.xyz;
    let _e111 = global.U[13];
    let _e112 = _e111.xyz;
    let _e126 = hexTilesWithTextureTransformLegacy((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), _e66.x, _e70.x, _e74.x, mat3x3<f32>(vec3<f32>(_e79.x, _e79.y, _e79.z), vec3<f32>(_e83.x, _e83.y, _e83.z), vec3<f32>(_e87.x, _e87.y, _e87.z)), mat3x3<f32>(vec3<f32>(_e104.x, _e104.y, _e104.z), vec3<f32>(_e108.x, _e108.y, _e108.z), vec3<f32>(_e112.x, _e112.y, _e112.z)));
    fragColor = _e126;
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
