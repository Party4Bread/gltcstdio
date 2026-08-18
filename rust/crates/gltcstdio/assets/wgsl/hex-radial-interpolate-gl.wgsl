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

fn _mirror_wrap(c: vec2<f32>) -> vec2<f32> {
    var c_1: vec2<f32>;

    c_1 = c;
    let _e9 = c_1;
    let _e11 = vec2(2f);
    return (vec2(1f) - abs(((_e9 - (floor((_e9 / _e11)) * _e11)) - vec2(1f))));
}

fn hexRadialInterpolateGL(pos: vec2<f32>, outPos: vec2<f32>, count: i32, modelTransform: mat3x3<f32>) -> vec4<f32> {
    var pos_1: vec2<f32>;
    var outPos_1: vec2<f32>;
    var count_1: i32;
    var modelTransform_1: mat3x3<f32>;
    var gridTransform: mat3x3<f32>;
    var u: vec2<f32>;
    var tileWidth: f32 = 2f;
    var halfTileWidth: f32;
    var tileHeight: f32;
    var centerHeight: f32;
    var X: f32;
    var Y: f32;
    var row: f32;
    var column: f32;
    var dx: f32;
    var dy: f32;
    var down: bool;
    var cx: f32;
    var cy: f32;
    var hcx: f32;
    var hcy: f32;
    var tripos: i32;
    var relPos: vec2<f32>;
    var center: vec2<f32>;
    var c1_: vec2<f32>;
    var c2_: vec2<f32>;
    var c3_: vec2<f32>;
    var coord: vec2<f32>;
    var d: f32;
    var ha: f32 = 3.1415927f;
    var ang: f32;
    var cnt: f32;
    var angleRange: f32;
    var index: f32;
    var ang1_: f32;
    var ang2_: f32;
    var pos1_: vec2<f32>;
    var col1_: vec4<f32>;
    var pos2_: vec2<f32>;
    var col2_: vec4<f32>;

    pos_1 = pos;
    outPos_1 = outPos;
    count_1 = count;
    modelTransform_1 = modelTransform;
    let _e14 = modelTransform_1;
    gridTransform = _naga_inverse_3x3_f32(_e14);
    let _e17 = gridTransform;
    let _e18 = pos_1;
    u = (_e17 * vec3<f32>(_e18.x, _e18.y, 1f)).xy;
    let _e28 = tileWidth;
    halfTileWidth = (_e28 * 0.5f);
    let _e32 = tileWidth;
    tileHeight = (_e32 * 0.8660254f);
    let _e36 = tileWidth;
    centerHeight = (_e36 / 3.4641016f);
    let _e42 = u;
    X = _e42.x;
    let _e45 = u;
    Y = _e45.y;
    let _e48 = Y;
    let _e49 = tileHeight;
    row = floor((_e48 / _e49));
    let _e53 = X;
    let _e54 = halfTileWidth;
    column = floor((_e53 / _e54));
    let _e58 = X;
    let _e59 = column;
    let _e60 = halfTileWidth;
    dx = (_e58 - (_e59 * _e60));
    let _e64 = Y;
    let _e65 = row;
    let _e66 = tileHeight;
    dy = (_e64 - (_e65 * _e66));
    let _e70 = row;
    let _e71 = column;
    let _e72 = (_e70 + _e71);
    down = ((_e72 - (floor((_e72 / 2f)) * 2f)) == 0f);
    let _e83 = down;
    if _e83 {
        {
            let _e84 = dy;
            let _e85 = tileHeight;
            let _e86 = dx;
            if (_e84 > (_e85 - (_e86 * 1.7320508f))) {
                {
                    let _e91 = row;
                    let _e94 = tileHeight;
                    let _e96 = centerHeight;
                    cy = (((_e91 + 1f) * _e94) - _e96);
                    let _e98 = column;
                    let _e101 = halfTileWidth;
                    cx = ((_e98 + 1f) * _e101);
                    down = true;
                }
            } else {
                {
                    let _e104 = row;
                    let _e105 = tileHeight;
                    let _e107 = centerHeight;
                    cy = ((_e104 * _e105) + _e107);
                    let _e109 = column;
                    let _e110 = halfTileWidth;
                    cx = (_e109 * _e110);
                    down = false;
                }
            }
        }
    } else {
        {
            let _e113 = dy;
            let _e114 = dx;
            if (_e113 > (_e114 * 1.7320508f)) {
                {
                    let _e118 = row;
                    let _e121 = tileHeight;
                    let _e123 = centerHeight;
                    cy = (((_e118 + 1f) * _e121) - _e123);
                    let _e125 = column;
                    let _e126 = halfTileWidth;
                    cx = (_e125 * _e126);
                    down = true;
                }
            } else {
                {
                    let _e129 = row;
                    let _e130 = tileHeight;
                    let _e132 = centerHeight;
                    cy = ((_e129 * _e130) + _e132);
                    let _e134 = column;
                    let _e137 = halfTileWidth;
                    cx = ((_e134 + 1f) * _e137);
                    down = false;
                }
            }
        }
    }
    let _e142 = column;
    let _e144 = row;
    let _e146 = (_e142 + (3f * _e144));
    tripos = i32((_e146 - (floor((_e146 / 6f)) * 6f)));
    let _e154 = tripos;
    if (_e154 == 2i) {
        {
            let _e157 = column;
            let _e158 = halfTileWidth;
            hcx = (_e157 * _e158);
            let _e160 = row;
            let _e163 = tileHeight;
            hcy = ((_e160 + 1f) * _e163);
        }
    } else {
        let _e165 = tripos;
        if (_e165 == 1i) {
            {
                let _e168 = column;
                let _e171 = halfTileWidth;
                hcx = ((_e168 + 1f) * _e171);
                let _e173 = row;
                let _e176 = tileHeight;
                hcy = ((_e173 + 1f) * _e176);
            }
        } else {
            let _e178 = tripos;
            if (_e178 == 0i) {
                {
                    let _e181 = down;
                    if _e181 {
                        {
                            let _e182 = column;
                            let _e185 = halfTileWidth;
                            hcx = ((_e182 + 2f) * _e185);
                            let _e187 = row;
                            let _e190 = tileHeight;
                            hcy = ((_e187 + 1f) * _e190);
                        }
                    } else {
                        {
                            let _e192 = column;
                            let _e195 = halfTileWidth;
                            hcx = ((_e192 - 1f) * _e195);
                            let _e197 = row;
                            let _e198 = tileHeight;
                            hcy = (_e197 * _e198);
                        }
                    }
                }
            } else {
                let _e200 = tripos;
                if (_e200 == 5i) {
                    {
                        let _e203 = column;
                        let _e204 = halfTileWidth;
                        hcx = (_e203 * _e204);
                        let _e206 = row;
                        let _e207 = tileHeight;
                        hcy = (_e206 * _e207);
                    }
                } else {
                    let _e209 = tripos;
                    if (_e209 == 4i) {
                        {
                            let _e212 = column;
                            let _e215 = halfTileWidth;
                            hcx = ((_e212 + 1f) * _e215);
                            let _e217 = row;
                            let _e218 = tileHeight;
                            hcy = (_e217 * _e218);
                        }
                    } else {
                        {
                            let _e220 = down;
                            if _e220 {
                                {
                                    let _e221 = column;
                                    let _e224 = halfTileWidth;
                                    hcx = ((_e221 - 1f) * _e224);
                                    let _e226 = row;
                                    let _e229 = tileHeight;
                                    hcy = ((_e226 + 1f) * _e229);
                                }
                            } else {
                                {
                                    let _e231 = column;
                                    let _e234 = halfTileWidth;
                                    hcx = ((_e231 + 2f) * _e234);
                                    let _e236 = row;
                                    let _e237 = tileHeight;
                                    hcy = (_e236 * _e237);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    let _e239 = u;
    relPos = _e239;
    let _e241 = hcx;
    let _e242 = hcy;
    center = vec2<f32>(_e241, _e242);
    let _e245 = halfTileWidth;
    let _e247 = tileHeight;
    let _e250 = center;
    c1_ = (vec2<f32>(-(_e245), -(_e247)) + _e250);
    let _e253 = tileWidth;
    let _e256 = center;
    c2_ = (vec2<f32>(_e253, 0f) + _e256);
    let _e259 = halfTileWidth;
    let _e261 = tileHeight;
    let _e263 = center;
    c3_ = (vec2<f32>(-(_e259), _e261) + _e263);
    let _e266 = center;
    coord = _e266;
    let _e269 = c1_;
    let _e270 = relPos;
    let _e273 = tileWidth;
    if (length((_e269 - _e270)) <= _e273) {
        {
            let _e275 = relPos;
            let _e276 = c1_;
            relPos = (_e275 - _e276);
            let _e278 = relPos;
            d = length(_e278);
            let _e280 = c1_;
            coord = _e280;
        }
    } else {
        let _e281 = c2_;
        let _e282 = relPos;
        let _e285 = tileWidth;
        if (length((_e281 - _e282)) <= _e285) {
            {
                let _e287 = relPos;
                let _e288 = c2_;
                relPos = (_e287 - _e288);
                let _e290 = relPos;
                d = length(_e290);
                let _e292 = c2_;
                coord = _e292;
            }
        } else {
            {
                let _e293 = relPos;
                let _e294 = c3_;
                relPos = (_e293 - _e294);
                let _e296 = relPos;
                d = length(_e296);
                let _e298 = c3_;
                coord = _e298;
            }
        }
    }
    let _e301 = relPos;
    let _e303 = d;
    ang = acos((_e301.x / _e303));
    let _e307 = relPos;
    if (_e307.y < 0f) {
        let _e312 = ang;
        ang = (6.2831855f - _e312);
    }
    let _e314 = ang;
    let _e318 = ha;
    ang = (_e314 + (1.5707964f + _e318));
    let _e321 = ang;
    let _e323 = (_e321 + 6.2831855f);
    ang = (_e323 - (floor((_e323 / 6.2831855f)) * 6.2831855f));
    let _e330 = ang;
    ang = (6.2831855f - _e330);
    let _e332 = count_1;
    cnt = f32(_e332);
    let _e336 = cnt;
    angleRange = (6.2831855f / _e336);
    let _e339 = ang;
    let _e342 = cnt;
    index = floor(((_e339 / 6.2831855f) * _e342));
    let _e346 = ha;
    let _e348 = angleRange;
    let _e349 = index;
    ang1_ = (-(_e346) + (_e348 * _e349));
    let _e353 = ha;
    let _e355 = angleRange;
    let _e356 = index;
    ang2_ = (-(_e353) + (_e355 * (_e356 + 1f)));
    let _e362 = modelTransform_1;
    let _e363 = coord;
    let _e365 = d;
    let _e366 = ang1_;
    let _e370 = coord;
    let _e372 = d;
    let _e373 = ang1_;
    pos1_ = (_e362 * vec3<f32>((_e363.x - (_e365 * sin(_e366))), (_e370.y - (_e372 * cos(_e373))), 1f)).xy;
    let _e382 = pos1_;
    let _e386 = global.U[0];
    let _e389 = pos1_;
    let _e398 = _mirror_wrap(((vec2<f32>((_e382.x / _e386.x), _e389.y) / vec2(2f)) + vec2(0.5f)));
    let _e399 = textureSample(t_source, samp, _e398);
    col1_ = _e399;
    let _e401 = modelTransform_1;
    let _e402 = coord;
    let _e404 = d;
    let _e405 = ang2_;
    let _e409 = coord;
    let _e411 = d;
    let _e412 = ang2_;
    pos2_ = (_e401 * vec3<f32>((_e402.x - (_e404 * sin(_e405))), (_e409.y - (_e411 * cos(_e412))), 1f)).xy;
    let _e421 = pos2_;
    let _e425 = global.U[0];
    let _e428 = pos2_;
    let _e437 = _mirror_wrap(((vec2<f32>((_e421.x / _e425.x), _e428.y) / vec2(2f)) + vec2(0.5f)));
    let _e438 = textureSample(t_source, samp, _e437);
    col2_ = _e438;
    let _e440 = col1_;
    let _e441 = col2_;
    let _e442 = ang;
    let _e443 = angleRange;
    let _e444 = index;
    let _e447 = angleRange;
    return mix(_e440, _e441, vec4(((_e442 - (_e443 * _e444)) / _e447)));
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
    let _e71 = global.U[6];
    let _e72 = _e71.xyz;
    let _e75 = global.U[7];
    let _e76 = _e75.xyz;
    let _e79 = global.U[8];
    let _e80 = _e79.xyz;
    let _e94 = hexRadialInterpolateGL((_naga_inverse_3x3_f32(mat3x3<f32>(vec3<f32>(_e9.x, _e9.y, _e9.z), vec3<f32>(_e13.x, _e13.y, _e13.z), vec3<f32>(_e17.x, _e17.y, _e17.z))) * vec3<f32>(_e44.x, _e44.y, 1f)).xy, (((_e51 - vec2(0.5f)) * 2f) * vec2<f32>(_e59.x, 1f)), i32(_e66.x), mat3x3<f32>(vec3<f32>(_e72.x, _e72.y, _e72.z), vec3<f32>(_e76.x, _e76.y, _e76.z), vec3<f32>(_e80.x, _e80.y, _e80.z)));
    fragColor = _e94;
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
